--------------------------------------------------------
--  DDL for Package Body OE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UTIL" AS
/* $Header: oexutlb.pls 115.1 99/07/16 08:30:36 porting shi $ */

  PROCEDURE Set_Schedule_Date_Window (
		P_Result		OUT VARCHAR2
  ) is
    Schedule_Window_Profile   NUMBER := To_Number(FND_PROFILE.Value('OE_SCHEDULE_DATE_WINDOW'));
  begin
    P_Result := 'Y';

    if (Schedule_Window_Profile is NULL) then
      Return;
    end if;

    if (Schedule_Window_Profile > 1) then
      FND_PROFILE.Put('OE_SCHEDULE_DATE_WINDOW', '1');
      OE_MSG.Set_Buffer_Message('OE_SCH_WINDOW_IGNORED');
    end if;

    Return;

  exception
    when others then
      OE_MSG.Internal_Exception('OE_UTIL.Set_Schedule_Date_Window',
				'Setting Schedule Window', '');
      P_Result  := 'N';

  end Set_Schedule_Date_Window;


  PROCEDURE Reset_Schedule_Date_Window (
		Original_Sch_Window     IN  VARCHAR2,
		P_Result		OUT VARCHAR2
  ) is
    Schedule_Window_Profile   NUMBER := To_Number(FND_PROFILE.Value('OE_SCHEDULE_DATE_WINDOW'));
  begin
    P_Result := 'Y';

    if (Schedule_Window_Profile is NULL or
	Original_Sch_Window     is NULL or
        (Schedule_Window_Profile  = To_Number(Original_Sch_Window))) then
      Return;
    end if;

    FND_PROFILE.Put('OE_SCHEDULE_DATE_WINDOW', Original_Sch_Window);

    Return;

  exception
    when others then
      OE_MSG.Internal_Exception('OE_UTIL.Reset_Schedule_Date_Window',
				'Resetting Schedule Window', Original_Sch_Window);
      P_Result  := 'N';

  end Reset_Schedule_Date_Window;

END OE_UTIL;

/
