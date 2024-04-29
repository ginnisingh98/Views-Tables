--------------------------------------------------------
--  DDL for Package Body WSH_CALENDAR_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CALENDAR_ACTIONS" AS
/* $Header: WSHCAACB.pls 120.1 2005/08/12 14:21:48 sperera noship $ */
	-- standard global constants
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'WSH_CALENDAR_ACTIONS';
-------------------------------------------------------------------------------------------
-- Start of comments
-- API name                     : Get_Shift_Times
--      Type                            : public
--      Function                        : get the earliest shift times from
--                                        calendars greater than a given date/time
--                                        for a given location
--      Version                 : Initial version 1.0
--      Parameters              : IN:  p_location_id: Location for which we need the
--                                                    shift times.
--                                     p_date       : Date for which we need the
--                                                    shift times.
 --                             : OUT: x_from_time  : The start time of the earliest
--                                                    shift that ends after the given
--                                                    date time
--                                   : x_to_time    : The end time of the earliest
--                                                    shift that ends after the given
--                                                    date time
--     Notes                    : It is possible that a shift extends past midnight.
--                                In this case the x_to_time will be less than the x_from_time.
--                                If there are no shifts remaing after the date/time or
--                                Calendar not defined for the location, NULL will be
--                                returned for both the out dates.
-- End of comments
-- ------------------------------------------------------------------------------------------


Procedure Get_Shift_Times(p_location_id   IN NUMBER,
                          p_date          IN DATE,
                          x_from_time     OUT NOCOPY NUMBER,
                          x_to_time       OUT NOCOPY NUMBER,
                          x_return_status OUT NOCOPY VARCHAR2) IS


-- This cursor will get the earliest shift end time today greater than the given time for
-- that calendar.

 CURSOR get_shift_end_time_today(p_location_id in number, p_date in date) IS
 SELECT BSH.from_time, BSH.to_time
 FROM BOM_CALENDAR_SHIFTS BCA, BOM_SHIFT_TIMES BSH,
      BOM_SHIFT_DATES BDT,  WSH_CALENDAR_ASSIGNMENTS WCA
 WHERE WCA.LOCATION_ID = p_location_id and
       BCA.CALENDAR_CODE=WCA.CALENDAR_CODE and
       BSH.CALENDAR_CODE=WCA.CALENDAR_CODE and
       BCA.SHIFT_NUM = BSH.SHIFT_NUM and
       BDT.CALENDAR_CODE = WCA.CALENDAR_CODE and
       BDT.SHIFT_NUM = BCA.SHIFT_NUM and
       BDT.EXCEPTION_SET_ID = -1 and
       to_char(BDT.SHIFT_DATE, 'YYYY/MM/DD') = to_char(p_date, 'YYYY/MM/DD') and
       BSH.TO_TIME > BSH.FROM_TIME and
       BSH.TO_TIME > to_number(to_char(p_date, 'SSSSS'))
       ORDER BY BSH.to_time ASC;



-- This cursor will get the earliest shift end time from the given time tomorrow for
-- that calendar. This will be used when a shift may begin today, but
-- end tomorrow.
 CURSOR get_shift_end_time_tomorrow(p_location_id in number, p_date in date) IS
 SELECT BSH.from_time, BSH.to_time
 FROM BOM_CALENDAR_SHIFTS BCA, BOM_SHIFT_TIMES BSH,
      BOM_SHIFT_DATES BDT,  WSH_CALENDAR_ASSIGNMENTS WCA
 WHERE WCA.LOCATION_ID = p_location_id and
       BCA.CALENDAR_CODE=WCA.CALENDAR_CODE and
       BSH.CALENDAR_CODE=WCA.CALENDAR_CODE and
       BCA.SHIFT_NUM = BSH.SHIFT_NUM and
       BDT.CALENDAR_CODE = WCA.CALENDAR_CODE and
       BDT.SHIFT_NUM = BCA.SHIFT_NUM and
       BDT.EXCEPTION_SET_ID = -1 and
       to_char(BDT.SHIFT_DATE, 'YYYY/MM/DD')
       = to_char(p_date, 'YYYY/MM/DD') and
       BSH.TO_TIME < BSH.FROM_TIME
       ORDER BY BSH.to_time ASC;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'Get_Shift_Times';

BEGIN

  --
  -- Debug Statements
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.push(l_module_name);
    WSH_DEBUG_SV.log(l_module_name,'p_date',p_date);
    WSH_DEBUG_SV.log(l_module_name,'p_location_id',p_location_id);
    --
  END IF;

  x_return_status := wsh_util_core.g_ret_sts_success;
  x_from_time := NULL;
  x_to_time := NULL;

  OPEN get_shift_end_time_today(p_location_id, p_date);
  FETCH get_shift_end_time_today
  INTO x_from_time, x_to_time;
  IF get_shift_end_time_today%FOUND THEN
     CLOSE get_shift_end_time_today;
  ELSE
     CLOSE get_shift_end_time_today;
     OPEN get_shift_end_time_tomorrow(p_location_id, p_date);
     FETCH get_shift_end_time_tomorrow
     INTO x_from_time, x_to_time;
     CLOSE get_shift_end_time_tomorrow;
  END IF;

  IF l_debug_on THEN
    --
    WSH_DEBUG_SV.log(l_module_name,'x_from_time',x_from_time);
    WSH_DEBUG_SV.log(l_module_name,'x_to_time',x_to_time);
    WSH_DEBUG_SV.pop(l_module_name);
    --
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    wsh_util_core.default_handler('WSH_U_UTIL.Get_Shift_Times',l_module_name);
      --
    IF l_debug_on THEN
      wsh_debug_sv.pop(l_module_name, 'EXCEPTION:OTHERS');
    END IF;


END Get_Shift_Times;

END WSH_CALENDAR_ACTIONS;


/
