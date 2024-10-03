
#include "rtc.hpp"

Rtc::DateTime Rtc::getDateTime()
{
	DateTime result;

	const uint32_t time = RTC->TR;
	result.hour = decodeBcd((time & (RTC_TR_HT_Msk | RTC_TR_HU_Msk)) >> RTC_TR_HU_Pos);
	result.minute = decodeBcd((time & (RTC_TR_MNT_Msk | RTC_TR_MNU_Msk)) >> RTC_TR_MNU_Pos);
	result.second = decodeBcd((time & (RTC_TR_ST_Msk | RTC_TR_SU_Msk)) >> RTC_TR_SU_Pos);

	const uint32_t date = RTC->DR;
	result.year = decodeBcd((date & (RTC_DR_YT_Msk | RTC_DR_YU_Msk)) >> RTC_DR_YU_Pos);
	result.month = decodeBcd((date & (RTC_DR_MT_Msk | RTC_DR_MU_Msk)) >> RTC_DR_MU_Pos);
	result.date = decodeBcd((date & (RTC_DR_DT_Msk | RTC_DR_DU_Msk)) >> RTC_DR_DU_Pos);
	result.weekday = ((date & RTC_DR_WDU_Msk) >> RTC_DR_WDU_Pos);
	return result;
}