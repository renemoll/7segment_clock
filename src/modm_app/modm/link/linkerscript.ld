/*
 * Copyright (c) 2011-2012, 2019, Fabian Greif
 * Copyright (c) 2012, 2015-2022, Niklas Hauser
 * Copyright (c) 2013, Sascha Schade
 * Copyright (c) 2013, 2015, Kevin Läufer
 * Copyright (c) 2023, Christopher Durand
 *
 * This file is part of the modm project.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * ------------------------------------------------------------------------- */


OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(Reset_Handler)

MEMORY
{
	ITCM (rwx) : ORIGIN = 0x00000000, LENGTH = 16384
	FLASH (rx) : ORIGIN = 0x00200000, LENGTH = 2097152
	DTCM (rwx) : ORIGIN = 0x20000000, LENGTH = 131072
	SRAM1 (rwx) : ORIGIN = 0x20020000, LENGTH = 376832
	SRAM2 (rwx) : ORIGIN = 0x2007C000, LENGTH = 16384
	BACKUP (rwx) : ORIGIN = 0x40024000, LENGTH = 4096
	CONT_DTCM (rwx) : ORIGIN = 0x20000000, LENGTH = 524288
}

__itcm_start = ORIGIN(ITCM);
__itcm_end = ORIGIN(ITCM) + LENGTH(ITCM);
__flash_start = ORIGIN(FLASH);
__flash_end = ORIGIN(FLASH) + LENGTH(FLASH);
__dtcm_start = ORIGIN(DTCM);
__dtcm_end = ORIGIN(DTCM) + LENGTH(DTCM);
__sram1_start = ORIGIN(SRAM1);
__sram1_end = ORIGIN(SRAM1) + LENGTH(SRAM1);
__sram2_start = ORIGIN(SRAM2);
__sram2_end = ORIGIN(SRAM2) + LENGTH(SRAM2);
__backup_start = ORIGIN(BACKUP);
__backup_end = ORIGIN(BACKUP) + LENGTH(BACKUP);


MAIN_STACK_SIZE = 3072;
EXCEPTION_FRAME_SIZE = 108;

SECTIONS
{
	__rom_start = ORIGIN(FLASH);


	/* Read-only vector table in FLASH */
	.text :
	{
		__vector_table_rom_start = .;
		__vector_table_ram_load = .;
		KEEP(*(.vector_rom))
		__vector_table_rom_end = .;
	} >FLASH


	/* build id directly after vector table */
	.build_id :
	{
		__build_id = .;
		KEEP(*(.note.gnu.build-id))
	} >FLASH

	/* Read-only sections in FLASH */
	.text :
	{
		*(.text .text.* .gnu.linkonce.t.*)
	} >FLASH

	.rodata :
	{
		*(.rodata .rodata.* .gnu.linkonce.r.*)
		KEEP(*(.init))

		. = ALIGN(4);
		__init_array_start = .;
		KEEP(*(SORT(.init_array.*)))
		KEEP(*(.init_array))
		. = ALIGN(4);
		__init_array_end = .;

		__hardware_init_start = .;
		KEEP(*(SORT(.hardware_init.order_*)))
		KEEP(*(SORT(.hardware_init)))
		. = ALIGN(4);
		__hardware_init_end = .;

		__assertion_table_start = .;
		KEEP(*(.assertion))
		. = ALIGN(4);
		__assertion_table_end = .;
	} >FLASH

	/DISCARD/ :
	{
		/* We do not call static destructors ever */
		*(.fini_array .fini_array.*)
		/* C++ exception unwind tables are discarded */
		*(.ARM.extab* .gnu.linkonce.armextab.*)
		*(.ARM.exidx* .gnu.linkonce.armexidx.*)
		*(.eh_frame*)
		/* Catch use of dynamic memory without `modm:platform:heap` module. */
		*(.Heap_is_not_implemented!__Please_include_the__modm:platform:heap__module_in_your_project!)
	}


	/* Read-Write vector table in ITCM */
	.vectors (NOLOAD) :
	{
		__vector_table_ram_start = .;
		KEEP(*(.vector_ram))
		. = ALIGN(4);
		__vector_table_ram_end = .;
	} >ITCM

	/* Sections in memory region ITCM */

	.fastcode :
	{
		__fastcode_load = LOADADDR(.fastcode);
		__fastcode_start = .;
		*(.fastcode .fastcode.*)
		. = ALIGN(4);
		__fastcode_end = .;
	} >ITCM AT >FLASH

	.data_itcm :
	{
		__data_itcm_load = LOADADDR(.data_itcm);
		__data_itcm_start = .;
		*(.data_itcm .data_itcm.*)
		. = ALIGN(4);
		__data_itcm_end = .;
	} >ITCM AT >FLASH


	.noinit_itcm (NOLOAD) :
	{
		. = ALIGN(4);
		__noinit_itcm_start = .;
		*(.noinit_itcm .noinit_itcm.*)
		. = ALIGN(4);
		__noinit_itcm_end = .;
	} >ITCM

	.heap_itcm (NOLOAD) :
	{
		. = ALIGN(4);
		__heap_itcm_start = .;
		. = MAX(ABSOLUTE(.), ORIGIN(ITCM) + LENGTH(ITCM));
		__heap_itcm_end = .;
	} >ITCM

	/* Main stack in CONT_DTCM */
	.stack (NOLOAD) :
	{
		__stack_start = .;
		__main_stack_bottom = .;
		/* main stack must fit one entire exception after the limit */
		__main_stack_limit = . + EXCEPTION_FRAME_SIZE;

		. += MAIN_STACK_SIZE;
		. = ALIGN(8);
		__main_stack_top = .;

		__stack_end = .;
	} >CONT_DTCM

	/* Read-write sections in CONT_DTCM */
	.data :
	{
		. = ALIGN(4);
		__data_load = LOADADDR(.data);
		__data_start = .;
		*(.data .data.* .gnu.linkonce.d.*)
		. = ALIGN(4);
		__data_end = .;
	} >CONT_DTCM AT >FLASH

	.fastdata :
	{
		__fastdata_load = LOADADDR(.fastdata);
		__fastdata_start = .;
		*(.fastdata .fastdata.*)
		. = ALIGN(4);
		__fastdata_end = .;
	} >CONT_DTCM AT >FLASH

	.data_dtcm :
	{
		__data_dtcm_load = LOADADDR(.data_dtcm);
		__data_dtcm_start = .;
		*(.data_dtcm .data_dtcm.*)
		. = ALIGN(4);
		__data_dtcm_end = .;
	} >CONT_DTCM AT >FLASH

	.bss (NOLOAD) :
	{
		__bss_start = . ;
		*(.bss .bss.* .gnu.linkonce.b.*)
		. = ALIGN(4);
	} >CONT_DTCM

	.bss_dtcm (NOLOAD) :
	{
		__bss_dtcm_start = . ;
		*(.bss_dtcm .bss_dtcm.*)
		. = ALIGN(4);
		__bss_dtcm_end = .;
		__bss_end = .;
	} >CONT_DTCM


	.noinit (NOLOAD) :
	{
		__noinit_start = . ;
		*(.noinit .noinit.*)
		. = ALIGN(4);
		__noinit_end = .;
	} >CONT_DTCM

	.faststack (NOLOAD) :
	{
		__faststack_start = . ;
		*(.faststack .faststack.*)
		. = ALIGN(4);
		__faststack_end = .;
	} >CONT_DTCM

	/* Sections in DTCM */
	.noinit_dtcm (NOLOAD) :
	{
		. = ALIGN(4);
		__noinit_dtcm_start = .;
		*(.noinit_dtcm .noinit_dtcm.*)
		. = ALIGN(4);
		__noinit_dtcm_end = .;
	} >CONT_DTCM

	.heap_dtcm (NOLOAD) :
	{
		. = ALIGN(4);
		__heap_dtcm_start = .;
		. = MAX(ABSOLUTE(.), ORIGIN(DTCM) + LENGTH(DTCM));
		__heap_dtcm_end = .;
	} >CONT_DTCM


	/* Sections in SRAM1 */

	.data_sram1 :
	{
		__data_sram1_load = LOADADDR(.data_sram1);
		__data_sram1_start = .;
		*(.data_sram1 .data_sram1.*)
		. = ALIGN(4);
		__data_sram1_end = .;
	} >CONT_DTCM AT >FLASH

	.bss_sram1 (NOLOAD) :
	{
		. = ALIGN(4);
		__bss_sram1_start = .;
		*(.bss_sram1 .bss_sram1.*)
		. = ALIGN(4);
		__bss_sram1_end = .;
	} >CONT_DTCM

	.noinit_sram1 (NOLOAD) :
	{
		. = ALIGN(4);
		__noinit_sram1_start = .;
		*(.noinit_sram1 .noinit_sram1.*)
		. = ALIGN(4);
		__noinit_sram1_end = .;
	} >CONT_DTCM

	.heap_sram1 (NOLOAD) :
	{
		. = ALIGN(4);
		__heap_sram1_start = .;
		. = MAX(ABSOLUTE(.), ORIGIN(SRAM1) + LENGTH(SRAM1));
		__heap_sram1_end = .;
	} >CONT_DTCM


	/* Sections in SRAM2 */

	.data_sram2 :
	{
		__data_sram2_load = LOADADDR(.data_sram2);
		__data_sram2_start = .;
		*(.data_sram2 .data_sram2.*)
		. = ALIGN(4);
		__data_sram2_end = .;
	} >CONT_DTCM AT >FLASH

	.bss_sram2 (NOLOAD) :
	{
		. = ALIGN(4);
		__bss_sram2_start = .;
		*(.bss_sram2 .bss_sram2.*)
		. = ALIGN(4);
		__bss_sram2_end = .;
	} >CONT_DTCM

	.noinit_sram2 (NOLOAD) :
	{
		. = ALIGN(4);
		__noinit_sram2_start = .;
		*(.noinit_sram2 .noinit_sram2.*)
		. = ALIGN(4);
		__noinit_sram2_end = .;
	} >CONT_DTCM

	.heap_sram2 (NOLOAD) :
	{
		. = ALIGN(4);
		__heap_sram2_start = .;
		. = MAX(ABSOLUTE(.), ORIGIN(SRAM2) + LENGTH(SRAM2));
		__heap_sram2_end = .;
	} >CONT_DTCM



	/* Sections in memory region BACKUP */

	.data_backup :
	{
		__data_backup_load = LOADADDR(.data_backup);
		__data_backup_start = .;
		*(.data_backup .data_backup.*)
		. = ALIGN(4);
		__data_backup_end = .;
	} >BACKUP AT >FLASH


	.bss_backup (NOLOAD) :
	{
		. = ALIGN(4);
		__bss_backup_start = .;
		*(.bss_backup .bss_backup.*)
		. = ALIGN(4);
		__bss_backup_end = .;
	} >BACKUP

	.noinit_backup (NOLOAD) :
	{
		. = ALIGN(4);
		__noinit_backup_start = .;
		*(.noinit_backup .noinit_backup.*)
		. = ALIGN(4);
		__noinit_backup_end = .;
	} >BACKUP

	.heap_backup (NOLOAD) :
	{
		. = ALIGN(4);
		__heap_backup_start = .;
		. = MAX(ABSOLUTE(.), ORIGIN(BACKUP) + LENGTH(BACKUP));
		__heap_backup_end = .;
	} >BACKUP

	/* Memory layout configuration tables */
	.rodata :
	{
		. = ALIGN(4);
		__table_zero_intern_start = .;
		LONG(__bss_start)
		LONG(__bss_end)
		LONG(__bss_sram1_start)
		LONG(__bss_sram1_end)
		LONG(__bss_sram2_start)
		LONG(__bss_sram2_end)
		LONG(__bss_backup_start)
		LONG(__bss_backup_end)
		__table_zero_intern_end = .;

		__table_copy_intern_start = .;
		LONG(__vector_table_ram_load)
		LONG(__vector_table_ram_start)
		LONG(__vector_table_ram_end)
		LONG(__fastcode_load)
		LONG(__fastcode_start)
		LONG(__fastcode_end)
		LONG(__data_itcm_load)
		LONG(__data_itcm_start)
		LONG(__data_itcm_end)
		LONG(__data_load)
		LONG(__data_start)
		LONG(__data_end)
		LONG(__fastdata_load)
		LONG(__fastdata_start)
		LONG(__fastdata_end)
		LONG(__data_dtcm_load)
		LONG(__data_dtcm_start)
		LONG(__data_dtcm_end)
		LONG(__data_sram1_load)
		LONG(__data_sram1_start)
		LONG(__data_sram1_end)
		LONG(__data_sram2_load)
		LONG(__data_sram2_start)
		LONG(__data_sram2_end)
		LONG(__data_backup_load)
		LONG(__data_backup_start)
		LONG(__data_backup_end)
		__table_copy_intern_end = .;

		__table_zero_extern_start = .;
		__table_zero_extern_end = .;

		__table_copy_extern_start = .;
		__table_copy_extern_end = .;

		/* See `modm:architecture:memory` for bitmask */
		__table_heap_start = .;
		LONG(0x202b)
		LONG(__heap_dtcm_start)
		LONG(__heap_dtcm_end)
		LONG(0x001f)
		LONG(__heap_sram1_start)
		LONG(__heap_sram1_end)
		LONG(0x001f)
		LONG(__heap_sram2_start)
		LONG(__heap_sram2_end)
		LONG(0x2005)
		LONG(__heap_itcm_start)
		LONG(__heap_itcm_end)
		LONG(0x4009)
		LONG(__heap_backup_start)
		LONG(__heap_backup_end)
		__table_heap_end = .;
	} >FLASH


	. = ALIGN(4);
	__rom_end = .;


	/* DWARF debug sections */
	.debug_abbrev   0 : { *(.debug_abbrev) }
	.debug_aranges  0 : { *(.debug_aranges) }
	.debug_frame    0 : { *(.debug_frame) }
	.debug_info     0 : { *(.debug_info) }
	.debug_line     0 : { *(.debug_line) }
	.debug_loc      0 : { *(.debug_loc) }
	.debug_macinfo  0 : { *(.debug_macinfo) }
	.debug_pubnames 0 : { *(.debug_pubnames) }
	.debug_pubtypes 0 : { *(.debug_pubtypes) }
	.debug_ranges   0 : { *(.debug_ranges) }
	.debug_str      0 : { *(.debug_str) }

	.comment 0 : { *(.comment) }
	.ARM.attributes 0 : { KEEP(*(.ARM.attributes)) }
	/DISCARD/ : { *(.note.GNU-stack)  }

}