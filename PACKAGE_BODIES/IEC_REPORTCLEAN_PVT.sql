--------------------------------------------------------
--  DDL for Package Body IEC_REPORTCLEAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_REPORTCLEAN_PVT" AS
/* $Header: IECVRPCB.pls 120.1 2006/01/16 09:06:00 minwang noship $ */

PROCEDURE CLEAN_DATA
   (P_SCHEDULE_ID            NUMBER
   ,P_RESET_TIME		    DATE
   )
AS
l_count NUMBER := 0;
BEGIN
  delete from iec_rep_cpn_dial_stats where campaign_schedule_id = P_SCHEDULE_ID;
	delete from iec_rep_agent_status where campaign_schedule_id = P_SCHEDULE_ID;
	delete from iec_rep_campaign_details where campaign_schedule_id = P_SCHEDULE_ID;
	delete from iec_rep_agent_cpn_details where campaign_schedule_id = P_SCHEDULE_ID;

  select count(*) into l_count from iec_g_cpn_schedule_reset where campaign_schedule_id = P_SCHEDULE_ID;
	if l_count = 0  then
	insert into
				iec_g_cpn_schedule_reset(CPN_SCHEDULE_RESET_ID,
																CAMPAIGN_SCHEDULE_ID,
																LAST_RESET_TIME,
																CREATED_BY,
																CREATION_DATE,
																LAST_UPDATED_BY,
																LAST_UPDATE_DATE,
																LAST_UPDATE_LOGIN)
												values (iec_g_cpn_schedule_reset_s.nextval,
																P_SCHEDULE_ID,
																P_RESET_TIME,
																nvl(FND_GLOBAL.USER_ID,-1),
																sysdate,
																nvl(FND_GLOBAL.USER_ID,-1),
																sysdate,
																nvl(FND_GLOBAL.CONC_LOGIN_ID,-1));
  else
	update iec_g_cpn_schedule_reset set last_reset_time = P_RESET_TIME,last_update_date = sysdate where campaign_schedule_id = P_SCHEDULE_ID;
  end if;
END;

PROCEDURE CLEANUP
AS
l_count NUMBER := 0;
BEGIN
  delete from iec_rep_cpn_dial_stats;
	delete from iec_rep_agent_status;
	delete from iec_rep_campaign_details;
	delete from iec_rep_agent_cpn_details;
  update iec_g_cpn_schedule_reset set last_update_date = sysdate;
END;

END IEC_REPORTCLEAN_PVT;


/
