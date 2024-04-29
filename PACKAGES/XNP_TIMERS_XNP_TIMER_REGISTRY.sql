--------------------------------------------------------
--  DDL for Package XNP_TIMERS$XNP_TIMER_REGISTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TIMERS$XNP_TIMER_REGISTRY" AUTHID CURRENT_USER as
/* $Header: XNPWE2TS.pls 120.0 2005/05/30 11:50:56 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_ORDER_ID in varchar2 default null,
             U_ORDER_ID in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_TIMER_MESSAGE_CODE in varchar2 default null,
             P_STATUS in varchar2 default null,
             P_START_TIME in varchar2 default null,
             U_START_TIME in varchar2 default null,
             P_END_TIME in varchar2 default null,
             U_END_TIME in varchar2 default null,
             P_NEXT_TIMER in varchar2 default null,
	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2 default null,
             Z_CHK in varchar2 default null);
   procedure FormQuery(             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryView(
             P_TIMER_ID in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default XNP_WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_ORDER_ID in varchar2 default null,
             U_ORDER_ID in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_TIMER_MESSAGE_CODE in varchar2 default null,
             P_STATUS in varchar2 default null,
             P_START_TIME in varchar2 default null,
             U_START_TIME in varchar2 default null,
             P_END_TIME in varchar2 default null,
             U_END_TIME in varchar2 default null,
             P_NEXT_TIMER in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryFirst(
             P_ORDER_ID in varchar2 default null,
             U_ORDER_ID in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_TIMER_MESSAGE_CODE in varchar2 default null,
             P_STATUS in varchar2 default null,
             P_START_TIME in varchar2 default null,
             U_START_TIME in varchar2 default null,
             P_END_TIME in varchar2 default null,
             U_END_TIME in varchar2 default null,
             P_NEXT_TIMER in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_TIMER_MESSAGE_CODE in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_START_TIME in varchar2 default null,
            U_START_TIME in varchar2 default null,
            P_END_TIME in varchar2 default null,
            U_END_TIME in varchar2 default null,
            P_NEXT_TIMER in varchar2 default null) return number;
   procedure timer_message_code_listofvalue(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
   procedure next_timer_listofvalues(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
end;

 

/
