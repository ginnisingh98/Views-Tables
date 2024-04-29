--------------------------------------------------------
--  DDL for Package XNP_CALLBACK_EVENTS$XNP_CALLBA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_CALLBACK_EVENTS$XNP_CALLBA" AUTHID CURRENT_USER as
/* $Header: XNPWE2CS.pls 120.0 2005/05/30 11:44:09 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_ORDER_ID in varchar2 default null,
             U_ORDER_ID in varchar2 default null,
             P_STATUS in varchar2 default null,
             P_MSG_CODE in varchar2 default null,
             P_CALLBACK_PROC_NAME in varchar2 default null,
             P_CALLBACK_TYPE in varchar2 default null,
             P_PROCESS_REFERENCE in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_CALLBACK_TIMESTAMP in varchar2 default null,
             U_CALLBACK_TIMESTAMP in varchar2 default null,
             P_REGISTERED_TIMESTAMP in varchar2 default null,
             U_REGISTERED_TIMESTAMP in varchar2 default null,
             P_WI_INSTANCE_ID in varchar2 default null,
             U_WI_INSTANCE_ID in varchar2 default null,
             P_FA_INSTANCE_ID in varchar2 default null,
             U_FA_INSTANCE_ID in varchar2 default null,
	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2 default null,
             Z_CHK in varchar2 default null);
   procedure FormQuery(             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_ORDER_ID in varchar2 default null,
             U_ORDER_ID in varchar2 default null,
             P_STATUS in varchar2 default null,
             P_MSG_CODE in varchar2 default null,
             P_CALLBACK_PROC_NAME in varchar2 default null,
             P_CALLBACK_TYPE in varchar2 default null,
             P_PROCESS_REFERENCE in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_CALLBACK_TIMESTAMP in varchar2 default null,
             U_CALLBACK_TIMESTAMP in varchar2 default null,
             P_REGISTERED_TIMESTAMP in varchar2 default null,
             U_REGISTERED_TIMESTAMP in varchar2 default null,
             P_WI_INSTANCE_ID in varchar2 default null,
             U_WI_INSTANCE_ID in varchar2 default null,
             P_FA_INSTANCE_ID in varchar2 default null,
             U_FA_INSTANCE_ID in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_CALLBACK_PROC_NAME in varchar2 default null,
            P_CALLBACK_TYPE in varchar2 default null,
            P_PROCESS_REFERENCE in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_CALLBACK_TIMESTAMP in varchar2 default null,
            U_CALLBACK_TIMESTAMP in varchar2 default null,
            P_REGISTERED_TIMESTAMP in varchar2 default null,
            U_REGISTERED_TIMESTAMP in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            U_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null,
            U_FA_INSTANCE_ID in varchar2 default null) return number;
   procedure msg_code_listofvalues(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
end;

 

/
