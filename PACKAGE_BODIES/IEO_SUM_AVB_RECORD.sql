--------------------------------------------------------
--  DDL for Package Body IEO_SUM_AVB_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SUM_AVB_RECORD" AS
/* $Header: IEOSRECB.pls 115.10 2003/01/02 17:08:26 dolee ship $ */

------------------------------------------------------------------------------
-- Function   : TOTAL_RECORD_FOR_IEO_CAMP
------------------------------------------------------------------------------
function  TOTAL_RECORD_FOR_IEO_CAMP(LIST_SRV_NAME_Value 	IN  VARCHAR2)
	RETURN NUMBER
	IS
	ieototal	NUMBER(15) := 0;
BEGIN
	select sum(A.REC_AVAILABLE) into ieototal
	from IEO_CP_LIST_STATS_ALL A, IEO_CP_SVC_LISTS_ALL B
	where	A.LIST_SRV_NAME = LIST_SRV_NAME_Value
	    and A.LIST_SRV_NAME = B.LIST_SRV_NAME
	    and A.LIST_NAME = B.LIST_NAME
	    and B.LIST_STATUS ='O';
	if(ieototal is NULL) then return 0;
	else 	return(ieototal);
	end if;
END TOTAL_RECORD_FOR_IEO_CAMP;

------------------------------------------------------------------------------
--  Function   : TOTAL_RECORD_FOR_AMS_CAMP
------------------------------------------------------------------------------

function TOTAL_RECORD_FOR_AMS_CAMP(CAMPAIGN_ID_Value		IN  NUMBER)
	RETURN NUMBER
	IS
	amstotal	NUMBER(15):= 0;
	CURSOR	c_srvname IS
	select LIST_SRV_NAME from IEO_CP_SERVICES_ALL
	where CAMPAIGN_LIST_ID in
		(select DISTINCT(A.LIST_HEADER_ID)
		from 	AMS_LIST_HEADERS_ALL A,
			AMS_CAMPAIGN_SCHEDULES B
		where	A.LIST_USED_BY_ID = B.CAMPAIGN_SCHEDULE_ID
			and B.CAMPAIGN_ID  = CAMPAIGN_ID_Value);

BEGIN
	FOR v_srvname IN c_srvname LOOP
	amstotal := amstotal + TOTAL_RECORD_FOR_IEO_CAMP(v_srvname.LIST_SRV_NAME);
	END LOOP;
	return(amstotal);
END TOTAL_RECORD_FOR_AMS_CAMP;

END IEO_SUM_AVB_RECORD;

/
