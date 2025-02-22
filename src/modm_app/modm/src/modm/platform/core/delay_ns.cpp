/*
 * Copyright (c) 2015-2016, 2021 Niklas Hauser
 *
 * This file is part of the modm project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */
// ----------------------------------------------------------------------------

#include "../device.hpp"
#include "hardware_init.hpp"
#include "delay_impl.hpp"

namespace modm
{

// Only call via modm::delay_ns wrapper, since this function clobbers r0, r1, r2!!!
void modm_naked modm_aligned(4) modm_fastcode
platform::delay_ns(uint32_t)
{
	// ns_per_loop = nanoseconds per cycle times cycles per loop
	asm volatile (
		".syntax unified"		"\n\t"
		"ldr.n  r2, =_ZN4modm8platform17delay_ns_per_loopE" "\n\t"
		"ldrh.n r2, [r2, #0]"	"\n\t"
		"lsls.n	r1, r2, #2"	"\n\t"	// multiply the overhead cycles with the ns per cycle:  1 cycle
		"subs.n	r0, r0, r1"		"\n\t"	// subtract the overhead in ns from the input:          1 cycle
	"1:  subs.n	r0, r0, r2"		"\n\t"	// subtract the ns per loop from the input:             1 cycle
		"nop.n"					"\n\t"	// folded into previous sub
		"nop.n"					"\n\t"	// +1 cycle
		"nop.n"					"\n\t"	// folded into previous nop
		"nop.n"					"\n\t"	// +1 cycle
		"nop.n"					"\n\t"	// folded into previous nop
		"nop.n"					"\n\t"	// folded into next bpl
		"bpl.n	1b"				"\n\t"	// keep doing that while result is still positive:      2 cycles (when taken)
		"bx lr"
	);
}

}