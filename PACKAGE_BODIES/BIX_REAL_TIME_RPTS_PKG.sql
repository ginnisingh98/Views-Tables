--------------------------------------------------------
--  DDL for Package Body BIX_REAL_TIME_RPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_REAL_TIME_RPTS_PKG" AS
/* $Header: bixxrtsb.pls 115.43 2003/01/10 18:39:55 achanda noship $ */

/* populate table for report: Queue Status Report	    			 */
/* component code: BIX_QUEUE_STATUS_RPT                	      */
/* component type: BIN 				               	      */

PROCEDURE pop_q_st_rpt(p_context VARCHAR2)
AS
l_session_id        number;
l_date_low 		date;
l_date_high		date;
loggedin		number;
callsWaiting		number;
longestCallWaiting	number;
l_string		varchar2(50);
l_string2           varchar2(50);
pstring             varchar(50);
callsOffered		number;
abandonCalls		number;
paraX			number := 20;
avgAbandonTime		number;
avgSpeedToAnswer	number;
avgTalkTime		number;
avgQtime            number;
totalWaitingTime    number;
callsSrvLevel		number;
talk                    number;
wrap                    number;
talk_graph              number;
wrap_graph              number;
activeAgent             number;
v_group_id number;
v_classification_id NUMBER;
v_classification VARCHAR2(64);
v_drill_class_id NUMBER;
v_site_id           number;
l_className         varchar2(100);
numRowRTmeasure     number;
i                   number;
j                   number;
calls_range1        number;
calls_range2        number;
calls_range3        number;
calls_range4        number;
calls_range5        number;
calls_range6        number;
calls_range7        number;
Cursor getClassList is
select classification className
from cct_classifications
where
       classification_id = v_classification_id;


/* calls in queue */
Cursor getCallsWaitingForClass is
Select count(distinct(C.MEDIA_ITEM_ID)) calls,
	  C.classification class
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
group by  C.classification
order by  count(C.MEDIA_ITEM_ID);


BEGIN

l_date_low  := trunc(sysdate);
l_date_high := sysdate;

l_session_id:= bix_util_pkg.get_icx_session_id;

  delete from BIX_DM_REPORT
  where session_id = l_session_id
  and report_code =  'BIX_QUEUE_STATUS_RPT';

/* drill down from queue status bin, queue status report itself.
		    to queue status report itself, agent status report, queue detail */

/* try to get incoming parameter(s) */
l_string := bix_util_pkg.get_parameter_value(p_context,'pContext');

if l_string is not null /*parameter got*/
   then
     l_string2 := substr(l_string,2,1);
	if l_string2 = 'G' then /* drill from Q Status Rpt */
         i := instr(l_string,'C',2) ;
	    v_group_id := to_number( substr(l_string,3,i-3));
	    j := instr(l_string,'S',i+1);
	    v_classification_id :=to_number(substr(l_string,i+1,j-i-1));
	    v_site_id :=to_number(substr(l_string,j+1));
	else  v_drill_class_id :=  to_number(l_string);/* from queue st bin */
		 v_classification_id := v_drill_class_id;
		 v_site_id := -999;
		 v_group_id := -999;
	end if;
else
  v_classification_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_CLASSIFICATION_ID'));
  v_site_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_SITE_ID'));
  v_group_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_GROUP_ID'));
end if;


  /* If the user has selected "All" for agent group paramter , display the default group
 of the user */
  IF (v_group_id = -999) THEN
    SELECT fnd_profile.value('BIX_DM_DEFAULT_GROUP')
    INTO   v_group_id
    FROM   dual;
  END IF;

  /* or the user has selected "all" as agent group paramter and (s)he is not assigned to
 any default group */
  IF (v_group_id IS NULL) THEN
    RETURN;
  END IF;

v_classification := NULL;
for rec in getClassList
        loop
          l_className :=rec.className;
		v_classification := l_className;
end loop;


/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range1
from CCT_MEDIA_ITEMS C
where C.status = 1
and   C.media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - C.last_update_date) * 24 * 60 <= 10;

/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range2
from CCT_MEDIA_ITEMS C
where C.status = 1
and   C.media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - C.last_update_date) * 24 * 60 <= 20
and (sysdate - C.last_update_date) * 24 * 60 > 10;

/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range3
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - last_update_date) * 24 * 60 <= 30
and (sysdate - last_update_date) * 24 * 60 > 20;


/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range4
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - last_update_date) * 24 * 60 <= 40
and (sysdate - last_update_date) * 24 * 60 > 30;

/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range5
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - last_update_date) * 24 * 60 <= 50
and (sysdate - last_update_date) * 24 * 60 > 40;

/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range6
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - last_update_date) * 24 * 60 <= 60
and (sysdate - last_update_date) * 24 * 60 > 50;

/* calls in queue by time ranges for graph */
Select count(distinct(C.MEDIA_ITEM_ID))
into calls_range7
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or (v_site_id=-999 or v_site_id is null))
and (C.classification = v_classification or (v_classification is null))
and (sysdate - last_update_date) * 24 * 60 > 60;

/*  get talking agents for graph  */
select count(distinct I1.resource_id) into talk_graph
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2,
     CCT_media_items M,
     JTF_RS_GROUP_MEMBERS J4,
	CCT_AGENT_RT_STATS C1
where I1.session_id = I2.session_id
	 and I1.application_id = 696
      and I1.active_flag ='T'
      and I1.end_date_time is NULL
      and I2.activity_type_code = 'MEDIA'
      and I2.active_flag = 'T'
      and I2.end_date_time is NULL
      and I2.deliver_date_time is not null
	 and C1.agent_id = I1.resource_id
	 and C1.has_call = 'T'
      and I1.begin_date_time between l_date_low and l_date_high
      and M.media_item_id = I2.media_id
      and I1.resource_id= J4.resource_id
      and (J4.group_id = v_group_id or v_group_id=-999)
      and (M.server_group_id= v_site_id or v_site_id=-999)
      and (M.classification = l_className or v_classification_id=-999);


/*  get wrapping agents for graph  */
/* removed
Select count(distinct I1.resource_id) into wrap_graph
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2,
     CCT_AGENT_RT_STATS C1,
     CCT_media_items M,
     JTF_RS_GROUP_MEMBERS J4
where I1.session_id  = I2.session_id
	  and I1.application_id = 696
       and I2.active_flag ='T'
       and I2.activity_type_code = 'MEDIA'
       and I2.end_date_time is null
       and I2.deliver_date_time is not null
       and I1.resource_id = C1.agent_id
       and C1.has_call = 'F'
       and I1.begin_date_time between l_date_low and l_date_high
       and M.media_item_id = I2.media_id
       and C1.agent_id= J4.resource_id
       and (J4.group_id = v_group_id or v_group_id=-999)
       and (M.server_group_id= v_site_id or v_site_id=-999)
       and (M.classification = l_className or v_classification_id=-999);
*/


/*  get active agents  */
/* removed
activeAgent := talk_graph +wrap_graph;
*/


/* calls in queue */
Select count(distinct(C.MEDIA_ITEM_ID)) into callsWaiting
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or v_site_id=-999)
and (C.classification = l_className or v_classification_id=-999);

/* CCT_MEDIA_ITEMS.status
	0 Media item received, not yet routed ( active mode only )
	1 Media item routed, waiting in queue
	2 Email reserved by an agent ( email only )
	3 Media item dequeued and served by an agent
	4 Media item received in passive mode
	5 Media item served in passive mode
	6 Media item abandoned  */


/* longest call in queue */
Select max(l_date_high- C.last_update_date)*24*3600 into longestCallWaiting
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or v_site_id=-999)
and (C.classification = l_className or v_classification_id=-999);

/* total queue time */
select sum(l_date_high- C.last_update_date)*24*3600 into totalWaitingTime
from CCT_MEDIA_ITEMS C
where C.status = 1
and   media_type = 0
and   C.creation_date between l_date_low and l_date_high
and (C.server_group_id= v_site_id or v_site_id=-999)
and (C.classification = l_className or v_classification_id=-999);

if  totalWaitingTime is null then  totalWaitingTime :=0;
end if;
if callsWaiting is null then callsWaiting:=0; end if;
if longestCallWaiting is null then longestCallWaiting :=0;
end if;

/* get average queue time for calls */
if callsWaiting = 0 then avgQtime :=0;
else
avgQtime := trunc(totalWaitingTime / callsWaiting);
end if;


/******************  Daily measures : ***************************/

SELECT sum(DECODE(UPPER(ih_mitem.direction),'INBOUND',1,0)) ,
	  sum(DECODE(UPPER(ih_mitem.direction),'INBOUND',DECODE(UPPER(ih_mitem.media_abandon_flag),'Y',1,0),0))
into callsOffered, abandonCalls
FROM      JTF_IH_MEDIA_ITEMS ih_mitem
WHERE  ih_mitem.start_date_time BETWEEN l_date_low and l_date_high
 AND
  (
   ih_mitem.media_item_type = 'TELE_INB' or
   ih_mitem.media_item_type = 'TELE_DIRECT' or
   ih_mitem.media_item_type = 'TELE_MANUAL' or
   ih_mitem.media_item_type = 'TELE_WEB'
  )
AND    ih_mitem.active = 'N'
AND    (ih_mitem.classification = v_classification or v_classification is null)
AND    (ih_mitem.server_group_id = v_site_id or (v_site_id=-999 or v_site_id is null));

SELECT  SUM(DECODE(SIGN(msegs.duration -  goals.SL_SECONDS_GOAL),0,1,-1,1,0))
into callsSrvLevel
FROM   jtf_ih_media_items ih_mitem,
	  JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps,
        bix_dm_goals goals
where (ih_mitem.server_group_id =  v_site_id or (v_site_id is null or v_site_id = -999))
and   goals.call_type_id = v_classification_id
and   (ih_mitem.classification = v_classification or (v_classification is null))
and   ih_mitem.start_date_time BETWEEN l_date_low and l_date_high
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'IN_QUEUE'
and  ih_mitem.direction = 'INBOUND'
and  goals.end_date_active is null;

SELECT SUM(msegs.duration)/count(distinct(msegs.media_id))
INTO   avgAbandonTime
FROM   jtf_ih_media_items ih_mitem,
	  JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps
where   ih_mitem.start_date_time BETWEEN l_date_low and l_date_high
and  ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  mtyps.milcs_code = 'IN_QUEUE'
and  ih_mitem.direction = 'INBOUND'
and  ih_mitem.media_abandon_flag = 'Y'
and  ih_mitem.active = 'N'
and   (ih_mitem.classification = v_classification or (v_classification is null))
and (ih_mitem.server_group_id =  v_site_id or (v_site_id is null or v_site_id = -999));

SELECT   sum(msegs.duration)/count(distinct(msegs.media_id))
INTO   avgTalkTime
FROM   jtf_ih_media_items ih_mitem,
	  JTF_IH_MEDIA_ITEM_LC_SEGS msegs,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps,
       JTF_RS_GROUP_MEMBERS        gp
where   ih_mitem.start_date_time BETWEEN l_date_low and l_date_high
and    ih_mitem.media_id = msegs.media_id
and  mtyps.milcs_type_id = msegs.milcs_type_id
and  ih_mitem.active = 'N'
and   (ih_mitem.classification = v_classification or (v_classification is null ))
and (ih_mitem.server_group_id =  v_site_id or (v_site_id is null or v_site_id = -999))
and  mtyps.milcs_code = 'WITH_AGENT'
and gp.resource_id = msegs.resource_id
and  (gp.group_id = v_group_id  or (v_group_id = -999 or v_group_id is null));

SELECT   sum(msegs1.duration)/count(distinct(msegs1.media_id))
INTO   avgSpeedToAnswer
FROM   jtf_ih_media_items ih_mitem,
	  JTF_IH_MEDIA_ITEM_LC_SEGS msegs1,
	  JTF_IH_MEDIA_ITEM_LC_SEGS msegs2,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps1,
       JTF_IH_MEDIA_ITM_LC_SEG_TYS mtyps2,
       JTF_RS_GROUP_MEMBERS        gp
where   ih_mitem.start_date_time BETWEEN l_date_low and l_date_high
and    ih_mitem.media_id = msegs1.media_id
and    ih_mitem.media_id = msegs2.media_id
and  mtyps1.milcs_type_id = msegs1.milcs_type_id
and  mtyps2.milcs_type_id = msegs2.milcs_type_id
and  ih_mitem.active = 'N'
and   (ih_mitem.classification = v_classification or (v_classification is null ))
and (ih_mitem.server_group_id =  v_site_id or (v_site_id is null or v_site_id = -999))
and  mtyps1.milcs_code = 'IN_QUEUE'
and  mtyps2.milcs_code = 'WITH_AGENT'
and  gp.resource_id = msegs2.resource_id
and  (gp.group_id = v_group_id or (v_group_id = -999 or v_group_id is null));


if callsOffered is null then  callsOffered:=0;
end if;
if  abandonCalls is null then  abandonCalls :=0;
end if;
if callsSrvLevel is null then callsSrvLevel :=0;
end if;
if  avgAbandonTime is null then  avgAbandonTime  :=0;
end if;
if avgSpeedToAnswer is null then  avgSpeedToAnswer :=0;
end if;
if avgTalkTime is null then avgTalkTime:=0;
end if;

/* insert data into table for reporting */

/* for parameter passing */
pstring := 'G' || to_char(v_group_id) || 'C' ||to_char(v_classification_id) || 'S' || to_char(v_site_id) ;

/* Make sure check col1 for bixxqstr.jsp seeding */
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8, col10, col12, col14, col16, col18, col20, col22, col24)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','1' || pstring , 'Calls Waiting', callsWaiting,
	   'Calls Offered', callsOffered,'', calls_range1, calls_range2, calls_range3, calls_range4, calls_range5, calls_range6, calls_range7);

l_string2:=  bix_util_pkg.get_hrmiss_frmt(longestCallWaiting);

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','2' || pstring, 'Longest Call Waiting', l_string2,
	   'Abandon Calls', abandonCalls, null, null);

l_string2:=  bix_util_pkg.get_hrmiss_frmt(avgQtime);

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','3' || pstring, 'Average Queue Time', l_string2,
 'Calls within Service Level', callsSrvLevel,null, null);


l_string:=  bix_util_pkg.get_hrmiss_frmt(avgAbandonTime);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','4'|| pstring, 'Talking Agents', talk_graph,
'Average abandon Time', l_string, null, null);

l_string :=  bix_util_pkg.get_hrmiss_frmt(avgSpeedToAnswer);


insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','5',  '', null,
	   'Average Speed To Answer', l_string,null, null);

l_string :=  bix_util_pkg.get_hrmiss_frmt(avgTalkTime);

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
values (l_session_id,'BIX_QUEUE_STATUS_RPT','6',  '', null,
        'Average Talk Time', l_string,null, null);

/*
numRowRTmeasure := 6;
 i :=0;
 select bix_util_pkg.get_null_lookup into l_string2 from dual;
 for rec in  getCallsWaitingForClass loop
    if rec.class is null then  l_string:= l_string2;
	  else l_string :=rec.class;
    end if;
    i :=i+1;
    if i<=numRowRTmeasure then
    update BIX_DM_REPORT set col10=l_string, col12=calls_range1
    where col1 like to_char(i) || '%';
    else insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4, col6, col8,col10, col12)
	    values (l_session_id,'BIX_QUEUE_STATUS_RPT', i ,null,null,null,null,l_string,rec.calls);
    end if;
 end loop;
*/
END pop_q_st_rpt;



/* utility procedure to get agents in idle, available, wrap, talk status */
PROCEDURE getTimeOfStatus (v_agent_id in number,
 available     out nocopy number,
 talk          out nocopy number,
 wrap          out nocopy number,
 idle          out nocopy number,
 p_out           out nocopy number,
 loggedin      out nocopy number)

AS
 l_date_low    date;
 l_date_high   date;
 num_agents    number;
 g_session_id NUMBER;
 talk_now      number;
 talk_past     number;
 wrap_now      number;
 wrap_past     number;

BEGIN
l_date_low  := trunc(sysdate);
l_date_high := sysdate;

/*loggined in time
------------------*/

select sum(decode(end_date_time, null, l_date_high-begin_date_time,
end_date_time-begin_date_time))*3600*24 into loggedin
from ieu_sh_sessions
where resource_id = v_agent_id
      and begin_date_time between l_date_low and l_date_high
      and application_id = 696;

if loggedin is null then loggedin :=0;
end if;

/*
available:
----------*/
select sum(decode(I1.deliver_date_time,null,l_date_high-I1.begin_date_time,
       I1.deliver_date_time-I1.begin_date_time))*3600*24 into available
from ieu_sh_activities I1,
     ieu_sh_sessions I2
where I1.session_id = I2.session_id
      and I2.resource_id = v_agent_id
      and I2.begin_date_time between l_date_low and l_date_high
      and I2.application_id = 696
      /* and I1.deliver_date_time is not null */
      and I1.activity_type_code = 'MEDIA';

if available is null then available :=0;
end if;


/*
talk time
----------*/
select sum(J1.duration) *3600*24 into talk_past
from jtf_ih_media_item_lc_segs J1,
     jtf_ih_media_itm_lc_seg_tys J2,
     jtf_ih_media_items J3
where J1.resource_id = v_agent_id
      and J1.milcs_type_id = J2.milcs_type_id
      and J2.milcs_code = 'WITH_AGENT'
      and J1.start_date_time between l_date_low and l_date_high
      and J3.media_id = J1.media_id
      and J3.media_item_type = 'TELEPHONE';

select sum(l_date_high-I2.deliver_date_time)*3600*24 into talk_now
from ieu_sh_activities I2,
     ieu_sh_sessions I1
where I1.session_id = I2.session_id
      and I1.resource_id = v_agent_id
      and I1.application_id = 696
      and I1.active_flag = 'T'
      and I1.end_Date_time is null
      and I2.activity_type_code = 'MEDIA'
      and I2.active_flag = 'T'
      and I2.end_date_time is null
      and I2.deliver_date_time is not null
      and I1.begin_date_time between l_date_low and l_date_high;

talk := nvl(talk_past,0)+ nvl(talk_now,0);

/*
wrap: wrap_now + wrap_past
--------------------------*/

Select sum(l_date_high - C1.last_update_date)*24*3600 into wrap_now
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
      and I1.resource_id = v_agent_id
      and C1.has_call = 'F'
      and I1.begin_date_time between l_date_low and l_date_high;



 select sum(J1.end_date_time - J2.end_date_time)*24*3600 into wrap_past
 from jtf_ih_media_item_lc_segs J2,
      jtf_ih_interactions J1,
      jtf_ih_media_itm_lc_seg_tys J3
 where J1.resource_id        = v_agent_id
       and J1.resource_id    = J2.resource_id
       and J2.media_id       = J1.productive_time_amount
       and J2.milcs_type_id  = J3.milcs_type_id
       and J3.milcs_code     = 'WITH_AGENT'
       and J1.start_date_time  between l_date_low and l_date_high;

wrap := nvl(wrap_now,0) + nvl(wrap_past,0);


idle := loggedin - available - talk - wrap;

/*
loggoutTime
-----------*/
p_out := (l_date_high-l_date_low)*3600*24 -loggedin;

END getTimeOfStatus;


/* utility procedure to insert data for agent time spent graph in agent */
/* detail report                                                        */

PROCEDURE insertRowsForGraph( i in number,
                              l_session_id in number,
                              available  in number,
                              talk       in number,
                              wrap       in number,
                              idle       in number,
                              p_out        in number)

AS
 j number;

BEGIN

if i=3 then
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',5,null, null,
                            'Out', p_out);
elsif i=2 then
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',4,null, null,
                            'Idle', idle);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',5,null, null,
                            'Out', p_out);
elsif i=1 then
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',3,null, null,
                            'Available', available);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',4,null, null,
                            'Idle', idle);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
            values (l_session_id,'BIX_AGENT_DETAIL_RPT',5,null, null,
                            'Out', p_out);
elsif i=0 then
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',2,null, null,
                            'Wrap', wrap);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',3,null, null,
                            'Available', available);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
             values (l_session_id,'BIX_AGENT_DETAIL_RPT',4,null, null,
                           'Idle', idle);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
             values (l_session_id,'BIX_AGENT_DETAIL_RPT',5,null, null,
                           'Out', p_out);
end if;

end insertRowsForGraph;



/* populate table for report: Agent Detail Report	    			 */
/* component code: BIX_AGENT_DETAIL_RPT                	      */
/* component type: REPORT 			               	      */
PROCEDURE pop_agt_dtl_rpt(p_context VARCHAR2)
AS

l_session_id  number;
v_resource_id number;
l_date_low    date;
l_date_high   date;
l_string      varchar2(100);
l_agent_name  varchar2(100);
v_status      varchar2(100);
v_duration    number;
v_display_id  number;
v_found       number;
CallsHandled  number;
LoginTime     number;
TodayLoginTime     number;
LogoutTime    number;
LogoutDate    Date;
LogoutReason  varchar2(100);
l_string2     varchar2(100);
l_string3     varchar2(100);
i             number;
j             number;

/* for graph */

 available     number;
 talk          number;
 wrap          number;
 idle          number;
 l_out           number;
 loggedin      number;


 Cursor getAvailableAgentList is
  Select
          (l_date_high - I2.begin_date_time)*24*3600 duration
  from IEU_SH_SESSIONS I1,
       IEU_SH_ACTIVITIES I2
  where I1.session_id = I2.session_id
	 and I1.application_id = 696
      and I1.active_flag ='T'
      and I1.end_date_time is NULL
      and I2.activity_type_code = 'MEDIA'
      and I2.deliver_date_time is null
      and I2.completion_code is null
      and I2.active_flag ='T'
      and I2.end_date_time is NULL
      and I1.begin_date_time between l_date_low and l_date_high
      and I1.resource_id = v_resource_id;

Cursor getTalkAgentList is
 Select
	(l_date_high - C1.last_update_date)*24*3600 duration
from CCT_AGENT_RT_STATS C1
where C1.has_call = 'T'
      and C1.agent_id =  v_resource_id
      and C1.last_update_date between l_date_low and l_date_high;


Cursor getWrapAgentList is
 Select
	 (l_date_high - C1.last_update_date)*24*3600 duration
 from CCT_AGENT_RT_STATS C1,
      /* CCT_MEDIA_ITEMS C2,*/
      IEU_SH_SESSIONS I1,
      IEU_SH_ACTIVITIES I2
 where C1.has_call = 'F'
           and C1.agent_id = v_resource_id
           /*and C2.media_item_id = I2.media_id*/
           and I1.session_id = I2.session_id
	      and I1.application_id = 696
           and I1.resource_id = C1.agent_id
           and I2.active_flag = 'T'
           and I2.completion_code is null
           and I2.deliver_date_time  is not null
           and C1.last_update_date between l_date_low and l_date_high;


Cursor getLoggedinAgentList is /* for idle*/
  Select
         (l_date_high-I1.begin_date_time)*24*3600 duration
  from IEU_SH_SESSIONS I1
  where
      I1.active_flag = 'T'
	 and I1.application_id = 696
      and I1.end_date_time is NULL
      and I1.begin_date_time between l_date_low and l_date_high
      and I1.resource_id = v_resource_id;

Cursor getLogoutList is
select
     (l_date_high-I1.end_date_time)*24*3600 duration
from IEU_SH_SESSIONS I1
where  (I1.active_flag is null or I1.active_flag = 'F')
       /* I1.begin_date_time between l_date_low and l_date_high */
       /* the agent logged not necessary in today */
       and I1.resource_id = v_resource_id
	  and I1.application_id = 696
       and I1.resource_id not in  /* make sure no new sessoin logged in by this agent */
          (
           select distinct(resource_id)
           from IEU_SH_SESSIONS
           where end_date_time is null
          );

/* there should be only one current login for an agent */
/* today: does not make sense
Cursor getTodayLoginTime is
select l_date_high-I1.begin_date_time loginTime
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
where I1.session_id = I2.session_id
	 and I1.application_id = 696
       and I1.begin_date_time between l_date_low and l_date_high
       and I1.resource_id = v_resource_id
       and I1.active_flag = 'T';
*/

Cursor getLoginTime is
select min(l_date_high-I1.begin_date_time)*24*3600 loginTime
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
where I1.session_id = I2.session_id
	 and I1.application_id = 696
       and I1.resource_id = v_resource_id
       and I1.active_flag = 'T';

Cursor getLogoutTime is
select
    (I1.begin_date_time-l_date_low)*3600*24 loginTime,
    (I1.end_date_time-l_date_low)*3600*24 logoutTime,
    I1.end_reason_code reason
from IEU_SH_SESSIONS I1
where
  I1.begin_date_time between l_date_low and l_date_high
  and I1.resource_id = v_resource_id
  and I1.application_id = 696
  and (I1.active_flag is null or I1.active_flag='F')
  order by I1.begin_date_time;

cursor getAgentSkills IS
select  p1.name skillname,p3.NAME skilllevel
from per_competences p1, per_competence_elements p2, jtf_rs_resource_extns j1,
 PER_COMPETENCE_LEVELS_V p3
where p1.competence_id = p2.competence_id
and   j1.resource_id = v_resource_id
and   p2.person_id = j1.source_id
and   (p2.EFFECTIVE_DATE_TO is null or p2.EFFECTIVE_DATE_TO >= sysdate)
and   p3.competence_id = p1.competence_id
and   p3.rating_level_id = p2.PROFICIENCY_LEVEL_ID;


BEGIN

   l_date_low  := trunc(sysdate);
   l_date_high := sysdate;

   l_session_id:= bix_util_pkg.get_icx_session_id;

  delete from BIX_DM_REPORT
  where session_id = l_session_id
  and report_code =  'BIX_AGENT_DETAIL_RPT';

/* check if drilled down from q status or agent status report */
     l_string :=  bix_util_pkg.get_parameter_value(p_context,'pContext');
     if l_string is null then /* not drilled down */
       v_display_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_DISPLAY_ID'));
       v_resource_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_RESOURCE_ID'));
     else
        if l_string= 'BIX_AGENT_DETAIL_RPT' then v_resource_id := NULL;
        else v_resource_id  :=  to_number(l_string);
             v_display_id := 1;
        end if;
     end if;


/****************** for graph *************************************/
getTimeOfStatus( v_resource_id, available,  talk     ,
                        wrap, idle, l_out, loggedin);

/**********************  Measure Value ****************************/
if v_display_id = 1 then

v_found:=0;
for rec in getAvailableAgentList
loop
  v_found :=1;
  v_status := 'AVAILABLE';
  v_duration := rec.duration;
end loop;

if v_found=0 then
for rec in getTalkAgentList
loop
  v_found :=1;
  v_status := 'TALK';
  v_duration := rec.duration;
end loop;
end if;

if v_found=0 then
for rec in getWrapAgentList
loop
  v_found :=1;
  v_status := 'TALK';
  v_duration := rec.duration;
end loop;
end if;

if v_found=0 then
for rec in getLoggedinAgentList
loop
  v_found :=1;
  v_status := 'IDLE';
  v_duration := rec.duration;
end loop;
end if;


if v_found=0 then
 for rec in getLogoutList
 loop
  v_found :=1;
  v_status := 'OUT';
  v_duration := rec.duration;
 end loop;
end if;

if v_found=0 then
 v_status := 'None';
 v_duration := null;
end if;

if (v_duration>60*60*24) then l_string := '>24 Hours';
else
l_string := bix_util_pkg.get_hrmiss_frmt(v_duration);
end if;

select count(I2.media_id) into CallsHandled
from IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
where I1.session_id = I2.session_id
      and I1.application_id = 696
      and I1.begin_date_time between l_date_low and l_date_high
      and I1.resource_id = v_resource_id;

if  v_status = 'None' then  LoginTime :=null;
else
 for rec in getLoginTime loop

  LoginTime := rec.loginTime;
 end loop;

 if LoginTime is null then
   LoginTime :=0;
 end if;
end if;

select agent_name into l_agent_name
from BIX_DM_AGENT_PARAM_V
where agent_id = v_resource_id;

l_string := bix_util_pkg.get_hrmiss_frmt(v_duration);

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
 values (l_session_id,'BIX_AGENT_DETAIL_RPT',1, 'Agent Name', l_agent_name,'Talk',
 talk);

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
 values (l_session_id,'BIX_AGENT_DETAIL_RPT',2, 'Current  Status', v_status,'Wrap',
 wrap);
insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
  values (l_session_id,'BIX_AGENT_DETAIL_RPT',3, 'Duration in Status', l_string,'Available',available);

 insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
  values (l_session_id,'BIX_AGENT_DETAIL_RPT',4,'Calls Handled',CallsHandled,'Idle',
   idle);

 if LoginTime>24*3600 then l_string := '>24 Hours';
 else
 l_string := bix_util_pkg.get_hrmiss_frmt(LoginTime);
end if;

 insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
values (l_session_id,'BIX_AGENT_DETAIL_RPT',5,'Login Time', l_string,'Out',l_out);

end if; /* of display 1 */

/******************time Card *********************************************/

if v_display_id= 2 then

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
        values (l_session_id,'BIX_AGENT_DETAIL_RPT',1,'Login/Logout Time', 'Reason',
                'Talk',talk);

i:=0;
for rec in getLogoutTime
loop

l_string  :=  bix_util_pkg.get_hrmiss_frmt(rec.LoginTime);
l_string2 :=  bix_util_pkg.get_hrmiss_frmt(rec.LogoutTime);

select    F.meaning into LogoutReason
          from FND_LOOKUP_VALUES F
          where F.lookup_code = rec.reason
		and   F.lookup_type = 'IEU_CTRL_BREAK_REASON';
i := i+1;

if i=1 then l_string3 := 'Wrap'; j:=wrap;
elsif i=2 then l_string3 := 'Available'; j:=available;
elsif i=3  then l_string3 := 'Idle'; j:=idle;
else l_string3 := 'Out'; j:=l_out;
end if;

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
		values (l_session_id,'BIX_AGENT_DETAIL_RPT',i+1,l_string || '/' || l_string2, LogoutReason,
			   l_string3, j);

end loop;

insertRowsForGraph(i, l_session_id, available, talk, wrap, idle, l_out);

end if; /*display 2*/

/******************Checkout duration**************************************/
if v_display_id=3 then

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
                values (l_session_id,'BIX_AGENT_DETAIL_RPT',1,'Check Out Reason', 'Duration',
                                                                'Talk',talk);
i:=0;
for rec in getLogoutTime
loop

l_string  :=  bix_util_pkg.get_hrmiss_frmt(rec.LogoutTime-rec.LoginTime);

select    F.meaning into LogoutReason
          from FND_LOOKUP_VALUES F
          where F.lookup_code = rec.reason
		and   F.lookup_type = 'IEU_CTRL_BREAK_REASON';
i := i+1;

if i=1 then l_string3 := 'Wrap'; j:=wrap;
elsif i=2 then l_string3 := 'Available'; j:=available;
elsif i=3  then l_string3 := 'Idle'; j:=idle;
else l_string3 := 'Out'; j:=l_out;
end if;

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
	values (l_session_id,'BIX_AGENT_DETAIL_RPT', i+1, LogoutReason, l_string ,l_string3,j);
end loop;

insertRowsForGraph(i, l_session_id, available, talk, wrap, idle, l_out);

end if; /*display 3*/

/**********************Skill*************************************/
if v_display_id =4 then

i:=0;

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
	values (l_session_id,'BIX_AGENT_DETAIL_RPT',1,'Skill', 'Level',
		null,null);
for skilldata in getAgentSkills LOOP
   insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
	values (l_session_id,'BIX_AGENT_DETAIL_RPT',i,skilldata.skillname,skilldata.skilllevel, null, null);
		i := i + 1;
end loop;

insert into BIX_DM_REPORT(session_id,report_code, col1, col2, col4,col6,col8)
	values (l_session_id,'BIX_AGENT_DETAIL_RPT',1,'', '',
		'Talk',talk);
i:=0;
/* for ... */
insertRowsForGraph(i, l_session_id, available, talk, wrap, idle, l_out);


end if; /*display 4 */

END pop_agt_dtl_rpt;


/* populate table for report: Agent status Report	    			 */
/* component code: BIX_AGENT_STATUS_REPORT                	      */
/* component type: REPORT
*/
PROCEDURE pop_agt_st_rpt(p_context VARCHAR2)
AS
 reportcode    number;
 l_date_low    date;
 l_date_high   date;
 l_timestring  varchar2(10);
 v_group_id number;
 v_status_id number;
 v_classification number;
 l_className varchar2(100);
 logoutreason varchar2(100);
 l_session_id  number;
 l_groupName   varchar2(100);
 l_agentId     number;
 l_unknown  varchar2(100);
 v_show     number;
 l_string   varchar2(100);
 l_string2  varchar2(100);
 i          number;
 j          number;
 v_site_id  number;

/* get available agents */
 Cursor getAvailableAgentList is
  Select  distinct(I1.resource_id) agentID,
		J.resource_name agentName,
		(l_date_high - I2.begin_date_time)*24*3600 availTime,
		/* J1.group_name groupName,*/
                I1.extension extension
  from IEU_SH_SESSIONS I1,
	  IEU_SH_ACTIVITIES I2,
	  JTF_RS_RESOURCE_EXTNS_VL J,
	  JTF_RS_GROUPS_VL J1,
	  JTF_RS_GROUP_MEMBERS J2
  where I1.session_id = I2.session_id
	   and I1.application_id = 696
         and I1.active_flag ='T'
	 and I1.end_date_time is NULL
         and I2.activity_type_code = 'MEDIA'
         and I2.deliver_date_time is null
         and I2.completion_code is null
         and I2.active_flag ='T'
         and I2.end_date_time is NULL
	 and I1.begin_date_time between l_date_low and l_date_high
	 and I1.resource_id = J.resource_id
	 and (J.resource_id = J2.resource_id)
	 and (J1.group_id = J2.group_id)
	 and (J1.group_id = v_group_id)
      and (J.server_group_id = v_site_id or (v_site_id = -999 or v_site_id is null))  /* new */
   order by J.resource_name;

/* get talking agents */
Cursor getTalkAgentList is
 Select distinct(C1.agent_id) agentID,
	   J.resource_name agentName,
	   (l_date_high - C1.last_update_date)*24*3600 talkTime,
	   /* J3.group_name groupName,*/
           I1.extension extension,
           C2.classification class
from CCT_AGENT_RT_STATS C1,
     CCT_MEDIA_ITEMS C2,
     JTF_RS_RESOURCE_EXTNS_VL J,
     JTF_RS_GROUPS_VL J3,
     JTF_RS_GROUP_MEMBERS J4,
     IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
	where C1.has_call = 'T'
           and C1.agent_id = J.resource_id
           and C2.media_item_id = I2.media_id
           and I1.session_id = I2.session_id
	      and I1.application_id = 696
           and I1.resource_id = C1.agent_id
           and (J.resource_id = J4.resource_id)
	      and (J3.group_id = J4.group_id)
           and (J3.group_id = v_group_id)
		 and (C2.server_group_id = v_site_id or (v_site_id =-999 or v_site_id is null))
	   and C1.last_update_date between l_date_low and l_date_high
    order by J.resource_name;

/* get wrapping agents */
Cursor getWrapAgentList is
 Select distinct(C1.agent_id) agentID,
	   J.resource_name agentName,
	   (l_date_high - C1.last_update_date)*24*3600 wrapTime,
	   /* J3.group_name groupName,*/
           I1.extension extension
from CCT_AGENT_RT_STATS C1,
     JTF_RS_RESOURCE_EXTNS_VL J,
     JTF_RS_GROUPS_VL J3,
     JTF_RS_GROUP_MEMBERS J4,
     IEU_SH_SESSIONS I1,
     IEU_SH_ACTIVITIES I2
	where C1.has_call = 'F'
           and C1.agent_id = J.resource_id
           /* and C2.media_item_id = I2.media_id */
           and I1.session_id = I2.session_id
	      and I1.application_id = 696
           and I1.resource_id = C1.agent_id
           and (J.resource_id = J4.resource_id)
	      and (J3.group_id = J4.group_id)
           and (J3.group_id = v_group_id)
      and (J.server_group_id = v_site_id  or (v_site_id =-999 or v_site_id is null))
           and I2.active_flag = 'T'
           and I2.completion_code is null
           and I2.deliver_date_time  is not null
	   and C1.last_update_date between l_date_low and l_date_high
    order by J.resource_name;

/* get idle agents ??? need calculation*/
Cursor getIdleAgentList is
  Select distinct(I1.resource_id) agentID,
         J5.resource_name agentName,
         (l_date_high-I1.begin_date_time)*24*3600 idleTime,
         /* J3.group_name groupName,*/
         I1.extension extension
  from IEU_SH_SESSIONS I1,
       JTF_RS_GROUP_MEMBERS J4,
       JTF_RS_RESOURCE_EXTNS_VL J5,
       JTF_RS_GROUPS_VL J3
  where  I1.active_flag = 'T'
	 and I1.application_id = 696
      and I1.end_date_time is NULL
      and I1.begin_date_time between l_date_low and l_date_high
      and I1.resource_id = J5.resource_id
      and (J5.resource_id = J4.resource_id)
      and (J3.group_id = J4.group_id)
      and (J3.group_id = v_group_id)
      and (J5.server_group_id = v_site_id  or (v_site_id =-999 or v_site_id is null))
      and I1.resource_id not in
       ( select col3 from BIX_DM_REPORT
        where report_code = 'BIX_AGENT_STATUS_REPORT'
        and session_id = l_session_id
        and (col8 = 'TALK' or col8='WRAP' or col8='AVAILABLE')
      )
  order by J5.resource_name;


/* get out agents */
Cursor getOutAgentList is
  Select distinct(I1.resource_id) agentID,
         J5.resource_name agentName,
         (l_date_high-I1.end_date_time)*24*3600 loggedoutTime,
         /* J3.group_name groupName,*/
         I1.extension extension,
         I1.end_reason_code reasoncode
  from IEU_SH_SESSIONS I1,
       JTF_RS_GROUP_MEMBERS J4,
       JTF_RS_RESOURCE_EXTNS_VL J5,
       JTF_RS_GROUPS_VL J3
       /* , FND_LOOKUPS F */
  where
      (I1.active_flag is null or I1.active_flag='F') /* 'N' */
	 and I1.application_id = 696
      and I1.resource_id = J5.resource_id
      and (J5.resource_id  = J4.resource_id)
      and (J3.group_id = J4.group_id)
      and (J3.group_id = v_group_id)
      and (J5.server_group_id = v_site_id or (v_site_id =-999 or v_site_id is null)) /* no classification assigned */
      and I1.resource_id not in  /* make sure no new sessoin logged in by this agent */
	  (
	   select distinct(resource_id)
	   from IEU_SH_SESSIONS
	   where end_date_time is null
	  )
order by J5.resource_name;


Cursor getNoneStatusAgentList is
select
        J5.resource_name agentName,
        J4.resource_id  agentID
from JTF_RS_GROUP_MEMBERS J4,
     JTF_RS_RESOURCE_EXTNS_VL J5
where J4.group_id = v_group_id
      and J5.resource_id  = J4.resource_id
      and J5.resource_id not in
         (select  col3
          from BIX_DM_REPORT
          where report_code = 'BIX_AGENT_STATUS_REPORT'
                and session_id = l_session_id
          )
order by J5.resource_name;

/*************** begin ************************/
BEGIN

l_session_id:= bix_util_pkg.get_icx_session_id;

  delete from BIX_DM_REPORT
  where session_id = l_session_id
  and report_code =  'BIX_AGENT_STATUS_REPORT';

l_date_low  := trunc(sysdate);
l_date_high := sysdate;



/* drill down from agent status bin, q status report */
/* try to get incoming parameter(s) */
l_string := bix_util_pkg.get_parameter_value(p_context,'pContext');

if l_string is not null /*parameter got*/
   then
	   l_string2 := substr(l_string,2,1);
	   if l_string2 = 'G' then /* drill from Q Status Rpt */
		  i := instr(l_string,'C',2) ;
		  v_group_id := to_number( substr(l_string,3,i-3));
		  j := instr(l_string,'S',i+1);
		  v_classification :=to_number(substr(l_string,i+1,j-i-1));
		  v_site_id :=to_number(substr(l_string,j+1));
	   else  /* drill from bin */
		  v_classification := to_number(l_string);
	       v_site_id := -999;
		  v_group_id := -999;
	   end if;
else
/*
   v_classification:=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_CLASSIFICATION_ID'));
   */
   v_site_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_SITE_ID'));
   v_status_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_STATUS_ID'));
   v_group_id :=  to_number(bix_util_pkg.get_parameter_value(p_context,'P_GROUP_ID'));
end if;


 select bix_util_pkg.get_null_lookup into l_unknown
 from dual;

  /* If the user has selected "All" for agent group paramter , display the default group of the user */
  IF (v_group_id = -999 or v_group_id is null) THEN
    SELECT fnd_profile.value('BIX_DM_DEFAULT_GROUP')
    INTO   v_group_id
    FROM   dual;
  END IF;

  /* or the user has selected "all" as agent group paramter and (s)he is not assigned to any default group */
  IF (v_group_id IS NULL) THEN
    RETURN;
  END IF;

   Select group_name into l_groupName
   from JTF_RS_GROUPS_VL
   where group_id = v_group_id;

   if l_groupName is null
    then l_groupName:=  l_unknown;
   end if;

/* get class name */
/*
if v_classification=-999 then l_className := null;
else
select classification into l_className
from cct_classifications
where
      classification_id = v_classification;
end if;
*/


/******* start check each status *************/
reportcode:=0;
v_show :=0;


if (v_status_id=3 or v_status_id=-999) then
for rec in getTalkAgentList
loop
reportcode := reportcode +1;
l_timestring := bix_util_pkg.get_hrmiss_frmt(rec.talkTime);
/* for null group name or an agent is not assigned to any group */
/*
l_groupName := l_unknown;
l_agentId := rec.agentID;
   for rcd in getGroupName
   loop
     l_groupName := rcd.groupName;
   end loop;
*/
if v_show=1 then l_groupName :=null;
end if; /* only one group name is showing */

insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,  col8, col10, col12,col14)
          values (l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName, rec.agentID,
                         rec.agentName, rec.extension,'TALK','TALK',l_timestring,' ', rec.class);
v_show:=1;
end loop;
end if;


if (v_status_id=4 or v_status_id=-999) then

for rec in getWrapAgentList
loop
reportcode := reportcode +1;
l_timestring := bix_util_pkg.get_hrmiss_frmt(rec.wrapTime);
if v_show=1 then l_groupName :=null;
end if;
insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,  col8, col10,col12,col14)
          values (l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName, rec.agentID,rec.agentName,
                   rec.extension,'WRAP','WRAP',l_timestring,'', '');
v_show :=1;
end loop;
end if;


if (v_status_id=2 or v_status_id=-999) then
 for rec in getAvailableAgentList
 loop
 reportcode := reportcode +1;
 l_timestring := bix_util_pkg.get_hrmiss_frmt(rec.availTime);
 if v_show=1 then l_groupName :=null;
 end if;
 insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,  col8,
                          col10,col12, col14)
       values (l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName, rec.agentID,
               rec.agentName, rec.extension,'AVAIL','AVAILABLE',l_timestring,' ',' ');
 v_show :=1;
 end loop;
end if;


if (v_status_id=1 or v_status_id=-999) then
for rec in getIdleAgentList
loop
reportcode := reportcode +1;
if v_show=1 then l_groupName :=null;
end if;
l_timestring := bix_util_pkg.get_hrmiss_frmt(trunc(rec.idleTime));
insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,  col8, col10,col12,col14)
          values (l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName, rec.agentID,
                         rec.agentName, rec.extension,'IDLE','IDLE',
                         l_timestring,' ',' ');

v_show :=1;
end loop;
end if;



if (v_status_id=5 or v_status_id=-999) then

  for rec in getOutAgentList
    loop
    reportcode := reportcode +1;

    select F.meaning into logoutreason
    from FND_LOOKUP_VALUES F
    where F.lookup_code = rec.reasoncode
    and   F.lookup_type = 'IEU_CTRL_BREAK_REASON';

    if v_show=1 then l_groupName :=null;
    end if;

    insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,  col8, col10,col12,col14)
          values (l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName, rec.agentID,rec.agentName,                   rec.extension,'Out','Out',
                  bix_util_pkg.get_hrmiss_frmt(rec.loggedoutTime),' ',logoutreason);
    v_show :=1;
    end loop;
end if;



/* list all agent without status        */
/* if 'ALL' is selected for status      */
if (v_status_id=-999) then
  for rec in getNoneStatusAgentList
  loop
    reportcode := reportcode +1;

  if v_show=1 then l_groupName :=null;
  end if;

  insert into BIX_DM_REPORT(session_id,report_code, col1, col2,col3, col4,col6, col7,
                            col8, col10,col12,col14)
  values(l_session_id,'BIX_AGENT_STATUS_REPORT',reportcode,l_groupName,rec.agentID,rec.agentName,
         ' ','None','None',' ',' ',' ');
  v_show :=1;
  end loop;
end if;


END pop_agt_st_rpt;


END BIX_REAL_TIME_RPTS_PKG;

/
