--------------------------------------------------------
--  DDL for Package Body CCT_ROUTINGACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_ROUTINGACTIVITIES_PUB" as
/* $Header: cctraccb.pls 120.0 2005/06/02 09:43:34 appldev noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CCT_RoutingActivities_PUB';


/*------------------------------------------------------------------------
   Routing Workflow Activities
*------------------------------------------------------------------------*/

/*------------------------------------------------------------------------
     Group : Environmental Conditions
*------------------------------------------------------------------------*/
/*------------------------------------------------------------------------
       SubGroup : Time Based
*------------------------------------------------------------------------*/

/* -----------------------------------------------------------------------
   Activity Name : DuringBusinessHours
--  Function to return Yes or No depending on whether DATETIME
-- (when caller called) between two Ref Times
-- IN
-   itemtype  - item type
--  itemkey   - item key
--  actid     - process activity instance id
--  funmode   - execution mode
-- OUT
--  result (Yes or No)
-- ITEM ATTRIBUTES REFERENCED
--  DATETIME  - Test Value
*-----------------------------------------------------------------------*/
procedure DuringBusinessHours (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
IS
  l_proc_name   VARCHAR2(30) := 'DuringBusinessHours';
  l_startTime    date;
  l_endTime    date;
  l_TimeOfCall  date;
 BEGIN
  resultout := wf_engine.eng_null;

  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    return;
  end if;

  l_startTime  := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'START-TIME');

  l_endTime  := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid ,
			'END-TIME');

  l_TimeOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');

    -- Compare time of call to business open and close times
    IF (l_startTime is null or l_endTime is null) THEN
      resultout := wf_engine.eng_completed||':' || wf_engine.eng_null;
    ELSIF ( (l_TimeOfCall - TRUNC(l_TimeOfCall)) >=
	         (l_startTime  - TRUNC(l_startTime )) AND
	    (l_TimeOfCall - TRUNC(l_TimeOfCall)) <=
                 (l_endTime - TRUNC(l_endTime))) THEN

      resultout := wf_engine.eng_completed||':Y';

    ELSE
      resultout := wf_engine.eng_completed||':N';

    END IF;


EXCEPTION
  WHEN OTHERS THEN
      -- if the customer id is not found
      IF (WF_CORE.Error_Name = 'WFENG_ITEM_ATTR') then
         WF_CORE.CLEAR;
         -- default result returned
         RETURN;
      END IF;

      -- for other errors
      Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
      RAISE;
END DuringBusinessHours;



/* -----------------------------------------------------------------------
   Activity Name : HourOfDay
--  Function to return hour of the day
-- IN
-   itemtype  - item type
--  itemkey   - item key
--  actid     - process activity instance id
--  funmode   - execution mode
-- OUT
--  result (WFSTD_DAY_OF_WEEK lookup code)
-- ITEM ATTRIBUTES REFERENCED
--  DATETIME  - Test Value
*-----------------------------------------------------------------------*/
procedure HourOfDay (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
is
  l_proc_name   VARCHAR2(30) := 'HourOfDay';
  l_dateval1    date;
  l_hour        varchar2(20);
 begin
  resultout := wf_engine.eng_null;

  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    return;
  end if;

  l_dateval1 := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');

  -- Need to make a 24 hour clock
  l_hour := to_char(l_dateval1, 'HOUR') ;
  resultout :=  wf_engine.eng_completed||':'||l_hour;

exception
  when others then
      -- if the customer id is not found
      if (WF_CORE.Error_Name = 'WFENG_ITEM_ATTR') then
         WF_CORE.CLEAR;
         -- default result returned
         return;
      end if;

      -- for other errors
      Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
      raise;
end HourOfDay;

/* -----------------------------------------------------------------------
   Activity Name : BeforeTime
     To compare if DATETIME (time of call) is before REF-TIME
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME  - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    REF-TIME  - Reference Value
*--------------------------------------------------------------------*/
procedure BeforeTime (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
is

  l_proc_name   VARCHAR2(30) := 'BeforeTime';
  l_TimeOfCall    date;
  l_refTime    date;
begin
  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;
/* **************** */
    -- Get the two date values
    l_TimeOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');
    l_refTime := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'REF-TIME');

    -- Compare
    if (l_TimeOfCall is null or l_refTime is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif ( (l_TimeOfCall - TRUNC(l_TimeOfCall)) <
	    (l_refTime - TRUNC(l_refTime)) ) then
      resultout := wf_engine.eng_completed||':Y';
    else
      resultout := wf_engine.eng_completed||':N';
    end if;

/* ************  */

Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end BeforeTime;

/* -----------------------------------------------------------------------
   Activity Name : AfterTime
     To compare if DATETIME (time of call) is after REF-TIME
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME  - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    REF-TIME  - Reference Value
*--------------------------------------------------------------------*/
procedure AfterTime (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
is

  l_proc_name   VARCHAR2(30) := 'AfterTime';
  l_timeOfCall    date;
  l_refTime    date;
begin
  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;
/* **************** */
    -- Get the two date values
    l_timeOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');
    l_refTime := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'REF-TIME');

    -- Compare
    if (l_timeOfCall is null or l_refTime is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif ( (l_timeOfCall - TRUNC(l_timeOfCall)) >
	    (l_refTime - TRUNC(l_refTime)) ) then
      resultout := wf_engine.eng_completed||':Y';
    else
      resultout := wf_engine.eng_completed||':N';
    end if;

/* ************  */

Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end AfterTime;


/*------------------------------------------------------------------------
       SubGroup : Date Based
*------------------------------------------------------------------------*/
/* -----------------------------------------------------------------------
   Activity Name : DayOfWeek
--  Function to return day of the week
-- IN
-   itemtype  - item type
--  itemkey   - item key
--  actid     - process activity instance id
--  funmode   - execution mode
-- OUT
--  result (WFSTD_DAY_OF_WEEK lookup code)
-- ITEM ATTRIBUTES REFERENCED
--  DATETIME  - Test Value
*-----------------------------------------------------------------------*/
procedure DayOfWeek (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
is
  l_proc_name   VARCHAR2(30) := 'DayOfWeek';
  l_dateval1    date;
  l_day         varchar2(20);
 begin
  resultout := wf_engine.eng_null;

  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    return;
  end if;

  l_dateval1 := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');

  if (l_dateval1 IS NULL) then
	return;
  end if;

  l_day := RTRIM(to_char(l_dateval1, 'DAY')) ;
  resultout :=  wf_engine.eng_completed||':'||l_day;
exception
  when others then
      Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
      raise;
end DayOfWeek;

/* -----------------------------------------------------------------------
   Activity Name : DayOfMonth
--  Function to return the day of the month
-- IN
-   itemtype  - item type
--  itemkey   - item key
--  actid     - process activity instance id
--  funmode   - execution mode
-- OUT
--  result (WFSTD_DAY_OF_MONTH lookup code)
-- ITEM ATTRIBUTES REFERENCED
--  DATETIME  - Test Value
*-----------------------------------------------------------------------*/
procedure DayOfMonth (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2)
is
  l_proc_name   VARCHAR2(30) := 'DayOfMonth';
  l_dateval1    date;
  l_day         varchar2(20);
 begin
  resultout := wf_engine.eng_null;

  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    return;
  end if;

  l_dateval1 := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');

  l_day      := to_char(l_dateval1, 'DD') ;
  l_day	   := LTRIM(RTRIM(l_day));
  resultout  := wf_engine.eng_completed||':'||l_day;

exception
  when others then
      -- if the customer id is not found
      if (WF_CORE.Error_Name = 'WFENG_ITEM_ATTR') then
         WF_CORE.CLEAR;
         -- default result returned
         return;
      end if;

      -- for other errors
      Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
      raise;
end DayOfMonth;

/* -----------------------------------------------------------------------
   Activity Name : BeforeDate
     To compare if DATETIME (time of call) is before REF-DATE
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME  - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    REF-DATE  - Reference Value
*-----------------------------------------------------------------------*/
procedure BeforeDate (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in  out nocopy varchar2)
is

  l_proc_name   VARCHAR2(30) := 'BeforeDate';
  l_dateOfCall    date;
  l_refDate    date;
begin
  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

    -- Get the two date values
    l_dateOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');

    l_refDate := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'REF-DATE');

    -- Compare l_dateOfCall (date of call) with l_refDate (REF-DATE)
    if (l_dateOfCall is null) or (l_refDate is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif ( l_dateOfCall < l_refDate ) then
      resultout := wf_engine.eng_completed||':Y';
    else
      resultout := wf_engine.eng_completed||':N';
    end if;

Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end BeforeDate;

/* -----------------------------------------------------------------------
   Activity Name : AfterDate
     To compare if DATETIME (time of call) is after REF-DATE
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME  - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    REF-DATE  - Reference Value
*-----------------------------------------------------------------------*/
procedure AfterDate (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2)
is

  l_proc_name   VARCHAR2(30) := 'AfterDate';
  l_dateOfCall    date;
  l_refDate    date;
begin
  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;
    -- Get the two date values
    l_dateOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');
    l_refDate := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'REF-DATE');

    -- Compare l_dateOfCall (date of call) with l_refDate (REF-DATE)
    if (l_dateOfCall is null) or (l_refDate is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif ( l_dateOfCall > l_refDate ) then
      resultout := wf_engine.eng_completed||':Y';
    else
      resultout := wf_engine.eng_completed||':N';
    end if;


Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end AfterDate;


/* -----------------------------------------------------------------------
   Activity Name : BetweenDates
     To compare if DATETIME (time of call) is between START-DATE and
	END-DATE
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME  - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    START-DATE  - Start Date Reference Value
    END-DATE  - End Date Reference Value
*-----------------------------------------------------------------------*/
procedure BetweenDates (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2)
is
  l_proc_name   VARCHAR2(30) := 'BetweenDates';
  l_startDate    date;
  l_endDate    date;
  l_dateOfCall    date;
begin
  -- Do nothing in cancel or timeout mode
  if (funmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;
    -- Get the two date values
    l_dateOfCall := Wf_Engine.GetItemAttrDate(itemtype,itemkey,
			'OCCTCREATIONTIME');
    l_startDate := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'START-DATE');
    l_endDate := Wf_Engine.GetActivityAttrDate(itemtype,itemkey,actid,
			'END-DATE');

    -- Compare l_dateOfCall with START-DATE and END-DATE
    if (l_startDate is null) or (l_endDate is null) then
      resultout := wf_engine.eng_completed||':NULL';
    elsif ( (TRUNC(l_dateOfCall) <= TRUNC(l_endDate)) AND
	    (TRUNC(l_dateOfCall) >= TRUNC(l_startDate))) then
      resultout := wf_engine.eng_completed||':Y';
    else
      resultout := wf_engine.eng_completed||':N';
    end if;

Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end BetweenDates;
-- Line 503



/* -----------------------------------------------------------------------
   Activity Name : Set_Lang_Comp_Filter
    To filter the agents by Language Comptency
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    LANGUAGE             - the language ID
    COMPETENCY-LANG-F    - the language competency filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_Lang_Comp_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
IS
    l_proc_name   VARCHAR2(30) := 'Set_Lang_Comp_Filter';
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_competency_name    VARCHAR2(32);
    l_call_ID     VARCHAR2(32);
    i             INTEGER;
    l_competency_type VARCHAR2(32):= 'LANG'; -- Changed Jun 27 2000
  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      l_competency_name := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'LANGUAGECOMPETENCY');

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_competency_name IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_Agents_For_Competency(
                      l_competency_type, l_competency_name , l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CCT_COMPETENCY_LANG_FILTER' , l_agents_tbl);

   end if;
  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_Lang_Comp_Filter;


/* -----------------------------------------------------------------------
   Activity Name : Set_Know_Comp_Filter
    To filter the agents by Knowledge Comptency
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    KNOWLEDGE             - the knowledge
    COMPETENCY-KNOW-F    - the knowledge competency filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_Know_Comp_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
IS
    l_proc_name   VARCHAR2(30) := 'Set_Know_Comp_Filter';
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_competency_name    VARCHAR2(32);
    l_call_ID     VARCHAR2(32);
    i             INTEGER;
    l_competency_type VARCHAR2(32):= 'KNOWLEDGE';

  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      l_competency_name := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'KNOWLEDGECOMPETENCY');

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_competency_name IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_Agents_For_Competency(
                      l_competency_type, l_competency_name , l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

     -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CCT_COMPETENCY_KNOW_FILTER' , l_agents_tbl);

   end if;
  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_Know_Comp_Filter;



/* -----------------------------------------------------------------------
   Activity Name : Set_Prod_Comp_Filter
    To filter the agents by Product Comptency
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    PRODUCT             - the product
    COMPETENCY-KNOW-F    - the product competency filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_Prod_Comp_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
IS
    l_proc_name   VARCHAR2(30) := 'Set_Prod_Comp_Filter';
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_competency_name    VARCHAR2(32);
    l_call_ID     VARCHAR2(32);
    i             INTEGER;
    l_competency_type VARCHAR2(32):= 'PRODUCT';
  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      l_competency_name := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'PRODUCTCOMPETENCY');

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_competency_name IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_Agents_For_Competency(
                      l_competency_type, l_competency_name , l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

     -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CCT_COMPETENCY_PROD_FILTER' , l_agents_tbl);

   end if;
  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_Prod_Comp_Filter;


/* -----------------------------------------------------------------------
   Activity Name : Set_DNIS_Comp_Filter
    To filter the agents by DNIS Comptency
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    DNIS             - the DNIS
    COMPETENCY-DNIS-F    - the DNIS competency filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_DNIS_Comp_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
IS
    l_proc_name   VARCHAR2(30) := 'Set_DNIS_Comp_Filter';
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
    l_num_agents  NUMBER := 0;
    l_competency_name    VARCHAR2(32);
    l_call_ID     VARCHAR2(32);
    i             INTEGER;
    l_competency_type VARCHAR2(32):= 'OCCTDNIS';
  BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   if (funmode = 'RUN') then
      l_competency_name := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTDNIS');

      l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

      IF ( (l_competency_name IS NULL) OR (l_call_ID IS NULL) ) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_Agents_For_Competency(
                      l_competency_type, l_competency_name , l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

     -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
	(l_call_ID, 'CCT_COMPETENCY_PROD_FILTER' , l_agents_tbl);

   end if;
  EXCEPTION
    WHEN OTHERS THEN
       WF_CORE.Context(G_PKG_NAME, l_proc_name,
                      itemtype, itemkey, to_char(actid), funmode);
      RAISE;

  END Set_DNIS_Comp_Filter;

/* -----------------------------------------------------------------------
   Activity Name : Get_Srv_Group_From_MCMID (branch node)
     Get the Server Group Name for a given MCM_ID
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SRVGROUP  - the Server Group Name
    MCMID   - the MCMID
*-----------------------------------------------------------------------*/
procedure Get_Srv_Group_from_MCMID (
 	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2
 ) IS
    l_proc_name     VARCHAR2(30) := 'Get_Srv_Group_from_MCMID' ;
    l_SrvGroup  VARCHAR2(50);
    l_MCM_ID   NUMBER;
    l_resultcode    VARCHAR2(30);
  BEGIN
    -- set default result
    resultout := wf_engine.eng_completed;

    IF (funmode = 'RUN') THEN

          l_MCM_ID := WF_ENGINE.GetItemAttrNumber(
					itemtype,itemkey,'MCM_ID' );

      IF (l_MCM_ID IS NOT NULL) THEN
          l_SrvGroup :=
              CCT_SERVERGROUPROUTING_PUB.Get_Srv_Group_From_MCMID
                             ( p_MCMID => l_MCM_ID ) ;

          IF (l_SrvGroup IS NOT NULL) THEN
             l_resultcode := CCT_RoutingWorkflow_UTL.Get_Result_Code(
		p_result_lookup_type => 'CCT_ServerGroup_Names'
                , p_result_display_name => l_SrvGroup
             );

             if (l_resultcode IS NULL) then
		l_resultcode := 'DEFAULT_ServerGroup';
             end if;

             resultout := wf_engine.eng_completed || ':' || l_resultcode ;

             WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SRVGROUP',
				l_SrvGroup );
          END IF;
      END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.Context(G_PKG_NAME, l_proc_name,  itemtype,
                        itemkey, to_char(actid), funmode);
      RAISE;

 END Get_Srv_Group_From_MCMID;

/* -----------------------------------------------------------------------
   Activity Name : Get_logged_in_Agents
    To filter the agents and return all logged in agents
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Get_agents_logged_in (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_MCM_ID     VARCHAR2(32);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_MCM_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'MCM_ID');

      IF  (l_MCM_ID IS NULL) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_SERVERGROUPROUTING_PUB.Get_agents_logged_in(
                      l_MCM_ID, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_LOGGED_IN_FILTER' , l_agents_tbl);
   END IF;
 END Get_Agents_logged_in;


/* -----------------------------------------------------------------------
   Activity Name : Get_agents_from_stat_grp_nam
    To filter the agents and return agents in a static group name
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID          - the call ID
    STATICGROUPNAME - Static Group Name
*-----------------------------------------------------------------------*/
procedure Get_agents_from_stat_grp_nam (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_group_name  VARCHAR2(200);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_name     := Wf_Engine.GetActivityAttrText(itemtype,itemkey
                                            ,actid,'STATICGROUPNAME');



      IF  (l_call_ID IS NULL) OR (l_group_name IS NULL)  THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_from_stat_grp_nam(
                      l_group_name, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_FROM_STAT_GRP_NAM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_from_stat_grp_nam;

/* -----------------------------------------------------------------------
   Activity Name : Get_agents_from_stat_grp_num
    To filter the agents and return   agents who are defined for a
    static group number
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    STATICGROUPNUMBER - Static Group Number
*-----------------------------------------------------------------------*/
procedure Get_agents_from_stat_grp_num (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents  NUMBER := 0;
    l_group_number NUMBER default NULL;
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_number     := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey
                                            ,actid,'STATICGROUPNUMBER');


      IF ((l_group_number IS NULL) OR (l_call_ID IS NULL)) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_from_stat_grp_num(
                      l_group_number,l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_FROM_STAT_GRP_NUM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_from_stat_grp_num;

 /* -----------------------------------------------------------------------
   Activity Name : Get_agents_from_dyn_grp_nam
    To filter the agents and return   agents who are defined in defined
    group num
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    DYNAMICGROUPNAME - Dynamic Group Name
*-----------------------------------------------------------------------*/
procedure Get_agents_from_dyn_grp_nam (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_group_name  VARCHAR2(200);
    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_name     := Wf_Engine.GetActivityAttrText(itemtype,itemkey
                                            ,actid,  'DYNAMICGROUPNAME');

      IF  (l_group_name IS NULL ) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_from_dyn_grp_nam(
                      l_group_name, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_FROM_DYN_GRP_NAM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_from_dyn_grp_nam;
 /* -----------------------------------------------------------------------
   Activity Name : Get_agents_from_dyn_grp_num
    To filter the agents and return   agents who are defined in dynamic
    group number
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    DYNAMICGROUPNUMBER - Dynamic Group Number
*-----------------------------------------------------------------------*/
procedure Get_agents_from_dyn_grp_num (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents   NUMBER := 0;
    l_group_number VARCHAR2(200);
    l_call_ID      VARCHAR2(32);
    l_agents_tbl   CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_number     := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey
                                            ,actid,'DYNAMICGROUPNUMBER');

      IF  (l_group_number IS NULL) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_from_dyn_grp_num(
                      l_group_number, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_FROM_DYN_GRP_NUM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_from_dyn_grp_num;

  /* -----------------------------------------------------------------------
   Activity Name : Get_agents_not_in_stat_grp_nam
    To filter the agents and return   agents who are defined not in static
    group name
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    STATICGROUPNAME - Static Group Name
*-----------------------------------------------------------------------*/
procedure Get_agents_not_in_stat_grp_nam (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_group_name  VARCHAR2(200);
    l_num_agents  NUMBER := 0;
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');

    l_group_name     := Wf_Engine.GetActivityAttrText(itemtype,itemkey
                                            ,actid,  'STATICGROUPNAME');

      IF  (l_group_name IS NULL ) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_not_in_stat_grp_nam(
                      l_group_name, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_NOT_IN_STAT_GRP_NAM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_not_in_stat_grp_nam;

/* -----------------------------------------------------------------------
   Activity Name : Get_agents_not_in_stat_grp_num
    To filter the agents and return   agents who are defined not in static
    group number
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    STATICGROUPNUMBER - Static Group Number
*-----------------------------------------------------------------------*/
procedure Get_agents_not_in_stat_grp_num (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents   NUMBER := 0;
    l_group_number VARCHAR2(200);
    l_call_ID      VARCHAR2(32);
    l_agents_tbl   CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_number     := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey
                                            ,actid,  'STATICGROUPNUMBER');

      IF  (l_group_number IS NULL) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_not_in_stat_grp_num(
                      l_group_number,l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_NOT_IN_STAT_GRP_NUM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_not_in_stat_grp_num;

/* -----------------------------------------------------------------------
   Activity Name : Get_agents_not_in_dyn_grp_nam
    To filter the agents and return   agents who are defined not in dynamic
    group name
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    DYNAMICGROUPNAME - Dynamic Group Name
*-----------------------------------------------------------------------*/
procedure Get_agents_not_in_dyn_grp_nam (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) IS

    l_num_agents  NUMBER := 0;
    l_group_name  VARCHAR2(200);
    l_call_ID     VARCHAR2(32);
    l_agents_tbl  CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_name     := Wf_Engine.GetActivityAttrText(itemtype,itemkey
                                            ,actid,  'DYNAMICGROUPNAME');
      IF  (l_group_name IS NULL) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_not_in_dyn_grp_nam(
                      l_group_name, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_NOT_IN_DYN_GRP_NUM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_not_in_dyn_grp_nam;
/* -----------------------------------------------------------------------
   Activity Name : Get_agents_not_in_dyn_grp_num
    To filter the agents and return   agents who are defined not in
    dynamic group number
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    DYNAMICGROUPNUMBER - Dynamic Group Number
*-----------------------------------------------------------------------*/
procedure Get_agents_not_in_dyn_grp_num (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) IS

    l_num_agents   NUMBER := 0;
    l_group_number VARCHAR2(200);
    l_call_ID      VARCHAR2(32);
    l_agents_tbl   CCT_RoutingWorkflow_UTL.agent_tbl_type;
 BEGIN
   -- set default result
   resultout := wf_engine.eng_completed ;

   IF (funmode = 'RUN') THEN
    l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
    l_group_number     := Wf_Engine.GetActivityAttrNumber(itemtype,itemkey
                                            ,actid,  'DYNAMICGROUPNUMBER');

      IF (l_group_number IS NULL) OR (l_call_ID IS NULL) THEN
         return;
      END IF;

      -- call CCT API
      l_num_agents := CCT_JTFRESOURCEROUTING_PUB.Get_agents_not_in_dyn_grp_num(
                      l_group_number, l_agents_tbl);
      IF (l_num_agents = 0) THEN
         return;
      END IF;

      -- insert the agents into the CCT_TEMPAGENTS table
      CCT_RoutingWorkflow_UTL.InsertResults
     (l_call_ID, 'CCT_AGENTS_NOT_IN_DYN_GRP_NUM_FILTER' , l_agents_tbl);
   END IF;
 END Get_agents_not_in_dyn_grp_num;

/* -----------------------------------------------------------------------
   Activity Name : Get_Media_type
    To determine the media_type of the inbound call
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    CALLID    - the call ID
    OCCTMEDIATYPE - Media type string (unique media type id)
*-----------------------------------------------------------------------*/
Procedure Get_Media_Type (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)
is

  l_proc_name   VARCHAR2(30) := 'Get_Media_Type';
  l_email       VARCHAR2(35) := '6010DA40B6F511D3A05000C04F53FBA6';
  l_phone       VARCHAR2(35) := '50BFCF20B6F511D3A05000C04F53FBA6';
  l_call_ID     VARCHAR2(32);
  l_media_type  VARCHAR2(50) := 'OTHER';
begin

  IF (funmode = 'RUN') THEN
        l_call_ID     := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIAITEMID');
        l_media_type := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIATYPE');
    IF  l_call_id IS NOT NULL THEN
    -- Compare
      IF l_media_type = l_email THEN
        resultout := wf_engine.eng_completed||':EMAIL';
      ELSIF l_media_type = l_phone then
        resultout := wf_engine.eng_completed||':PHONE';
      ELSE
        resultout := wf_engine.eng_completed||':OTHER';
      end if;
    END IF;
  END IF;
Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end Get_Media_Type;

/* -----------------------------------------------------------------------
   Activity Name : WF_AppFromClassification
    To determine the screenpop application of the inbound call
  IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    No output
   ITEM ATTRIBUTES REFERENCED
    Classification- Classification
    OCCTMEDIATYPE - Media type string (unique media type id)
*-----------------------------------------------------------------------*/
procedure WF_AppFromClassification(
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2)is
  l_proc_name   VARCHAR2(64) := 'WF_AppFromClassification';
  l_mediaType  VARCHAR2(255);
  l_classification VARCHAR2(255);
  l_appID NUMBER;
  l_appName  VARCHAR2(64);
Begin
  resultout := wf_engine.eng_completed||':OTHER';
  IF (funmode = 'RUN') THEN
        l_mediaType     :=WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTMEDIATYPE');
        l_Classification := WF_ENGINE.GetItemAttrText(
                       itemtype, itemkey,  'OCCTCLASSIFICATION');
  	If ((l_mediaType is not null) AND (l_classification is not null)) THEN
  		CCT_SERVERGROUPROUTING_PUB.Get_AppForClassification(l_classification
  														,l_mediaType
  														,l_appID
  														,l_appName);
  		If (l_appName is not Null) Then
			WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SCREENPOPAPP',l_appName);
  			resultout:=wf_engine.eng_completed||':'||l_appName;
  		End If;
  	End if;
  End if;
Exception
   when others then
    Wf_Core.Context(G_PKG_NAME, l_proc_name, itemtype,
                    itemkey, to_char(actid), funmode);
    raise;
end;


END CCT_RoutingActivities_PUB;

/
