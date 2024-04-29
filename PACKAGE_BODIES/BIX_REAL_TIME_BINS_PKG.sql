--------------------------------------------------------
--  DDL for Package Body BIX_REAL_TIME_BINS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_REAL_TIME_BINS_PKG" 
/* $Header: bixquebb.pls 115.38 2003/01/10 00:15:03 achanda ship $ */
AS

g_session_id NUMBER;

/******************************************** BINs **************************/

/* populates data for Queue Status Bin 					*/
/* component code: BIX_QUEUE_STATUS    					*/
/* component type: BIN                 	     			*/
PROCEDURE POPULATE_BIN(p_context IN VARCHAR2)
AS

 l_date_low    date;
 l_date_high   date;
 l_timestring  varchar2(10);
 l_classification_id number;
 l_count number;
 /* get calls in queue, average queue time by classification */
 Cursor getBinValue is
 Select count(C1.MEDIA_ITEM_ID)  calls_waiting,
        nvl(sum(sysdate - C1.last_update_date)*24*3600/decode(count(C1.MEDIA_ITEM_ID),0,1,null,1,count(C1.media_item_id)),0)
	   avg_queue_time,
	   C1.classification classification
 from CCT_MEDIA_ITEMS C1
 where C1.status = 1
 and   media_type = 0
 and C1.creation_date between l_date_low and l_date_high
 group by classification;
BEGIN

/* initialize date ranges for today */
l_date_low  := trunc(sysdate);
l_date_high := sysdate;

/* get the session identifier for the web session */
g_session_id := bix_util_pkg.get_icx_session_id;

/* delete data from previous runs */
delete from bix_dm_bin
where session_id = g_session_id
and bin_code = 'BIX_QUEUE_STATUS';

/* for all calls in queue */
for rec in getBinValue
Loop

/* retrieve the classification id given the classification */
select count(classification_id)
into   l_count
from   cct_classifications
where  classification = rec.classification;

if (l_count = 1) then
 select classification_id
 into   l_classification_id
 from   cct_classifications
 where  classification = rec.classification;
else
 l_classification_id := -999;
end if;

l_timestring := bix_util_pkg.get_hrmiss_frmt(rec.avg_queue_time);

/* insert the calls in queue in table for the reporting */
insert into bix_dm_bin (bin_code, session_id, col1, col2, col4, col6)
Values ('BIX_QUEUE_STATUS',g_session_id, l_classification_id, rec.classification,
         rec.calls_waiting,l_timestring);
end loop; /* end for all calls in queue */

END POPULATE_BIN;



/* populate data AGENT STATUS bin 						*/
/* component code: BIX_AGENT_STATUS    					*/
/* component type: BIN		 						*/

PROCEDURE populate_agent_status_bin(p_context IN VARCHAR2)
AS
 available     number;
 talk          number;
 wrap          number;
 idle          number;
 num_agents    number;
 out           number;
 loggedin      number;
 l_date_low    date;
 l_date_high   date;

BEGIN

/* get data date range for today */
l_date_low  := trunc(sysdate);
l_date_high := sysdate;

/* get session identifier for the web session calling this procedure */
g_session_id := bix_util_pkg.get_icx_session_id;

/* delete data from pervious runs */
delete from bix_dm_bin
where session_id = g_session_id
and bin_code = 'BIX_AGENT_STATUS';

/* get available agents */
select count(distinct I1.resource_id) into available
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
where I1.session_id = I2.session_id
	 and I1.application_id = 696
	 and I1.active_flag ='T'
      and I1.end_date_time is NULL
      and I2.activity_type_code = 'MEDIA'
      and I2.active_flag = 'T'
      and I2.end_date_time is NULL
	 and I2.deliver_date_time is NULL
      and I1.begin_date_time between l_date_low and l_date_high;

/* get talking agents */
Select count(distinct C1.agent_id) into talk
from CCT_AGENT_RT_STATS C1
where C1.has_call = 'T'
      and C1.last_update_date between  l_date_low and l_date_high;

/* get wrapping agents */
Select count(distinct I1.resource_id) into wrap
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2,
     CCT_AGENT_RT_STATS C1
where I1.session_id  = I2.session_id
	 and I1.application_id = 696
      and I2.active_flag ='T'
	 and I2.activity_type_code = 'MEDIA'
	 and I2.end_date_time is null
	 and I2.deliver_date_time is not null
      and I1.resource_id = C1.agent_id
      and C1.has_call = 'F'
      and I1.begin_date_time between l_date_low and l_date_high;

/* get agents who are logged into UWQ */
Select count(distinct I1.resource_id) into loggedin
from IEU_SH_SESSIONS I1
where I1.active_flag = 'T'
	 and I1.application_id = 696
      and I1.end_date_time is NULL
      and I1.begin_date_time between l_date_low and l_date_high;

/* get agents who are logged into UWQ */
Select count(distinct I1.resource_id) into out
from IEU_SH_SESSIONS I1
where I1.active_flag <> 'T'
	 and I1.application_id = 696
      and I1.end_date_time is not NULL
      and I1.begin_date_time between l_date_low and l_date_high
      and I1.resource_id not in(
		select distinct(resource_id) from IEU_SH_SESSIONS
		where  active_flag = 'T'
		and    application_id = 696
		and    end_date_time is null
		and    begin_date_time between l_date_low and l_date_high
   	);

idle := loggedin - talk - available - wrap;


/* insert the agent data into table for reporting */
insert into bix_dm_bin (bin_code, session_id, col1, col2, col4)
values ('BIX_AGENT_STATUS', g_session_id, '2', 'Available', available);

insert into bix_dm_bin (bin_code,  session_id, col1, col2, col4)
values ('BIX_AGENT_STATUS', g_session_id, '3', 'Talk', talk);

insert into bix_dm_bin (bin_code,  session_id, col1, col2, col4)
values ('BIX_AGENT_STATUS', g_session_id, '4', 'Wrap', wrap);

insert into bix_dm_bin (bin_code,  session_id, col1, col2, col4)
values ('BIX_AGENT_STATUS', g_session_id, '5', 'Out', out);

insert into bix_dm_bin (bin_code, session_id, col1, col2, col4)
values ('BIX_AGENT_STATUS', g_session_id, '1', 'Idle', idle);

END populate_agent_status_bin;

/******************************************** BINs **************************/
/******************************************** end **************************/


END BIX_REAL_TIME_BINS_PKG;

/
