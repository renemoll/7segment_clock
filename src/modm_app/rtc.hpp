#ifndef RTC_H
#define RTC_H

#include <inttypes.h>
#include <optional>
#include "modm/platform/device.hpp"
#include "modm/architecture/interface/peripheral.hpp"
#include "modm/platform/clock/rcc.hpp"

// TODO: re-used from Mcp7941x
constexpr uint8_t decodeBcd(uint8_t bcd)
{
	return (bcd / 16 * 10) + (bcd % 16);
}

// TODO: re-used from Mcp7941x
constexpr uint8_t encodeBcd(uint8_t decimal)
{
	return (decimal / 10 * 16) + (decimal % 10);
}

class Rtc : public ::modm::PeripheralDriver {
public:
	struct DateTime {
		uint8_t year;
		uint8_t month;
		uint8_t date;
		uint8_t weekday;
		uint8_t hour;
		uint8_t minute;
		uint8_t second;
	};

	/**
	 * @todo Make RTC clock source configurable
	 * @todo rtcclk should be LSE/LSI/HSE
	 */
	template<class SystemClock /*, frequency_t rtcclk = 1_Hz, percent_t tolerance = pct(5)*/>
	static bool initialize()
	{
		// TODO: factor 7?
		// static_assert(rtcclk < SystemClock::Apb1,
		// "The APB1 clock frequency must never be lower than the RTC clock frequency!");

		// TODO: calculate prescalers (these are default values)
		constexpr uint32_t prediv_a = 0x007F;
		constexpr uint32_t prediv_s = 0x00FF;
		// modm::Prescaler::from_power
		// modm::Prescaler::from_linear
		// PeripheralDriver::assertBaudrateInTolerance< result.frequency, 1, tolerance >();

		// rtc_ker_ck = rtcclk;
		// ck_apre = rtcclk / (prediv_a + 1);
		// ck_spre = ck_apre / (prediv_s + 1);
		// END TODO

		// TODO: this could be a precondition
		// Rcc::enableLowSpeedInternalClock();
		modm::platform::Rcc::enableLowSpeedExternalCrystal();

		// TODO: this could be a precondition or argument
		// Enable LSE as RTC clock
		modm::platform::Rcc::enableRealTimeClock(modm::platform::Rcc::RealTimeClockSource::Lse);

		// Gate bus clock to RTC (should be part of Rcc::enable<Peripheral::Rtc>())
		// RCC->APB1ENR |= RCC_APB1ENR_RTCEN;

		unlock();
		if (!enterInitializationMode()) {
			lock();
		}

		// To generate a 1 Hz clock for the calendar counter, program both prescaler factors
		RTC->PRER = ((prediv_a << RTC_PRER_PREDIV_A_Pos) & RTC_PRER_PREDIV_A_Msk)
			| ((prediv_s << RTC_PRER_PREDIV_S_Pos) & RTC_PRER_PREDIV_S_Msk);

		// Configure 24 hour format
		RTC->CR &= ~RTC_CR_FMT;

		exitInitializationMode();
		lock();

		return true;
	}

	// TODO: allow for both a human readable and BCD output variant, as BCD can be passed directly
	// to other devices...
	static DateTime getDateTime();

	static bool setDateTime(DateTime& dateTime)
	{
		unlock();
		if (!enterInitializationMode()) {
			lock();
			return false;
		}

		RTC->TR = ((encodeBcd(dateTime.hour) << RTC_TR_HU_Pos) & (RTC_TR_HT_Msk | RTC_TR_HU_Msk))
			| ((encodeBcd(dateTime.minute) << RTC_TR_MNU_Pos) & (RTC_TR_MNT_Msk | RTC_TR_MNU_Msk))
			| ((encodeBcd(dateTime.second) << RTC_TR_SU_Pos) & (RTC_TR_ST_Msk | RTC_TR_SU_Msk));

		RTC->DR = ((encodeBcd(dateTime.year) << RTC_DR_YU_Pos) & (RTC_DR_YT_Msk | RTC_DR_YU_Msk))
			| ((encodeBcd(dateTime.month) << RTC_DR_MU_Pos) & (RTC_DR_MT_Msk | RTC_DR_MU_Msk))
			| ((encodeBcd(dateTime.date) << RTC_DR_DU_Pos) & (RTC_DR_DT_Msk | RTC_DR_DU_Msk))
			| ((dateTime.weekday << RTC_DR_WDU_Pos) & RTC_DR_WDU_Msk);

		exitInitializationMode();
		lock();
		return true;
	}
private:
	static void unlock();
	static void lock();

	static bool enterInitializationMode();
	static void exitInitializationMode();
};

#include "rtc_impl.hpp"

#endif
