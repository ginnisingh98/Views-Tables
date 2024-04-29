--------------------------------------------------------
--  DDL for Package CCT_ROUTINGACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_ROUTINGACTIVITIES_PUB" AUTHID CURRENT_USER as
/* $Header: cctraccs.pls 120.0 2005/06/02 09:55:08 appldev noship $ */

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
     To compare if DATETIME is between STARTIME and ENDTIME
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    DATETIME    - Test Value
   ACTIVITY ATTRIBUTES REFERENCED
    STARTIME    - Start of Business for the day
    ENDTIME     - End of Business for the day
*-----------------------------------------------------------------------*/
procedure DuringBusinessHours (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) ;



/* -----------------------------------------------------------------------
   Activity Name : HourOfDay
--  Function to return time of day in 1 hour time slots.
-- IN
-   itemtype  - item type
--  itemkey   - item key
--  actid     - process activity instance id
--  funmode   - execution mode
-- OUT
--  result (CCT_HOUR_OF_DAY lookup code)
-- ITEM ATTRIBUTES REFERENCED
--  DATETIME  - Test Value
*-----------------------------------------------------------------------*/
procedure HourOfDay (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) ;



/* -----------------------------------------------------------------------
   Activity Name : BeforeTime
     To compare if DATETIME is before REFTIME
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
    REFTIME   - Reference Value
*-----------------------------------------------------------------------*/
procedure BeforeTime (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;



/* -----------------------------------------------------------------------
   Activity Name : AfterTime
     To compare if DATETIME is after REFTIME
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
    REFTIME  - Reference Value
*--------------------------------------------------------------------*/
procedure AfterTime (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


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
	, resultout in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : DayOfMonth
--  Function to return number in the month
-- IN
--  itemtype  - item type
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
	, resultout in out nocopy varchar2) ;

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
	, resultout in out nocopy varchar2) ;


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
	, resultout in out nocopy varchar2) ;

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
	, resultout in out nocopy varchar2);

/* -----------------------------------------------------------------------
   Activity Name : GetNumberOfAgentsReady
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
/*
procedure GetNumberOfAgentsReady (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) ;


procedure CallOnHoldXSec (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout in out nocopy varchar2) ;
*/


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
	, resultout 	in out nocopy varchar2) ;


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
	, resultout 	in out nocopy varchar2) ;

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
    LANGUAGE             - the Product
    COMPETENCY-PROD-F    - the product competency filter flag
    CALLID    - the call ID
*-----------------------------------------------------------------------*/
procedure Set_Prod_Comp_Filter (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

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
	, resultout 	in out nocopy varchar2) ;

/* -----------------------------------------------------------------------
   Activity Name : Get_Srv_Group_from_MCMID (branch node)
     Get the Server Group Name for a given MCM_ID
   IN
    itemtype  - item type
    itemkey   - item key
    actid     - process activity instance id
    funmode   - execution mode
   OUT
    comparison result (WFSTD_YES_NO lookup code)
   ITEM ATTRIBUTES REFERENCED
    SRVNAME  - the Server  Group Name
    MCMID   - the MCMID
*-----------------------------------------------------------------------*/
procedure Get_SRV_Group_From_MCMID (
 	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2
 );

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
procedure Get_Agents_logged_in (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;



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
	, resultout 	in out nocopy varchar2) ;

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
	, resultout 	in out nocopy varchar2) ;

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
	, resultout in out nocopy varchar2) ;

  /* -----------------------------------------------------------------------
   Activity Name : Get_agents_from_dyn_grp_num
    To filter the agents and return   agents who are defined in dynamic
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
*-----------------------------------------------------------------------*/
procedure Get_agents_from_dyn_grp_num (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;


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
	, resultout 	in out nocopy varchar2) ;

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
	, resultout 	in out nocopy varchar2) ;

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
	, resultout 	in out nocopy varchar2) ;

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
	, resultout 	in out nocopy varchar2) ;

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
procedure Get_Media_Type (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

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
procedure WF_AppFromClassification (
	itemtype   	in varchar2
	, itemkey  	in varchar2
	, actid    	in number
	, funmode 	in varchar2
	, resultout 	in out nocopy varchar2) ;

END CCT_RoutingActivities_PUB;

 

/
