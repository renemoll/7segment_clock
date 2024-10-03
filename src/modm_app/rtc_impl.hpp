

void inline Rtc::unlock()
{
	// DBP bit must be set in order to enable RTC registers write access.
	PWR->CR1 |= PWR_CR1_DBP;

	// Unlock the write protection on the protected RTC registers.
	RTC->WPR = 0xCA;
	RTC->WPR = 0x53;
}

void inline Rtc::lock()
{
	// Lock the write protection on the protected RTC registers.
	RTC->WPR = 0xFF;

	// DBP bit must be reset in order to disable RTC registers write access.
	PWR->CR1 &= ~PWR_CR1_DBP;
}

bool inline Rtc::enterInitializationMode()
{
	uint32_t waitCycles = 2048U;
	if (!(RTC->ISR & RTC_ISR_INITF)) {
		RTC->ISR |= RTC_ISR_INIT;

		while (!(RTC->ISR & RTC_ISR_INITF))
			if (--waitCycles == 0)
				return false;
	}

	return true;
}

void inline Rtc::exitInitializationMode()
{
	RTC->ISR &= ~RTC_ISR_INIT;
}
