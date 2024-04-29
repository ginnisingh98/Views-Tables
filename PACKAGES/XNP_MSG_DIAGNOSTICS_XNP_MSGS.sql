--------------------------------------------------------
--  DDL for Package XNP_MSG_DIAGNOSTICS$XNP_MSGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MSG_DIAGNOSTICS$XNP_MSGS" AUTHID CURRENT_USER as
/* $Header: XNPMSG2S.pls 120.0 2005/05/30 11:51:24 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_MSG_ID in varchar2 default null,
             P_MSG_CODE in varchar2 default null,
             P_L_MTE_MSG_TYPE in varchar2 default null,
             P_MSG_STATUS in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_OPP_REFERENCE_ID in varchar2 default null,
             P_RECIPIENT_NAME in varchar2 default null,
             P_SENDER_NAME in varchar2 default null,
             P_ADAPTER_NAME in varchar2 default null,
             P_FE_NAME in varchar2 default null,
             P_ORDER_ID in varchar2 default null,
             P_WI_INSTANCE_ID in varchar2 default null,
             P_FA_INSTANCE_ID in varchar2 default null,
	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2 default null,
             Z_CHK in varchar2 default null);
   procedure FormQuery(             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryView(
             P_MSG_ID in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default XNP_WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_MSG_ID in varchar2 default null,
             P_MSG_CODE in varchar2 default null,
             P_L_MTE_MSG_TYPE in varchar2 default null,
             P_MSG_STATUS in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_OPP_REFERENCE_ID in varchar2 default null,
             P_RECIPIENT_NAME in varchar2 default null,
             P_SENDER_NAME in varchar2 default null,
             P_ADAPTER_NAME in varchar2 default null,
             P_FE_NAME in varchar2 default null,
             P_ORDER_ID in varchar2 default null,
             P_WI_INSTANCE_ID in varchar2 default null,
             P_FA_INSTANCE_ID in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryFirst(
             P_MSG_ID in varchar2 default null,
             P_MSG_CODE in varchar2 default null,
             P_L_MTE_MSG_TYPE in varchar2 default null,
             P_MSG_STATUS in varchar2 default null,
             P_REFERENCE_ID in varchar2 default null,
             P_OPP_REFERENCE_ID in varchar2 default null,
             P_RECIPIENT_NAME in varchar2 default null,
             P_SENDER_NAME in varchar2 default null,
             P_ADAPTER_NAME in varchar2 default null,
             P_FE_NAME in varchar2 default null,
             P_ORDER_ID in varchar2 default null,
             P_WI_INSTANCE_ID in varchar2 default null,
             P_FA_INSTANCE_ID in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_MSG_ID in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_L_MTE_MSG_TYPE in varchar2 default null,
            P_MSG_STATUS in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_OPP_REFERENCE_ID in varchar2 default null,
            P_RECIPIENT_NAME in varchar2 default null,
            P_SENDER_NAME in varchar2 default null,
            P_ADAPTER_NAME in varchar2 default null,
            P_FE_NAME in varchar2 default null,
            P_ORDER_ID in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null) return number;
   procedure msg_code_listofvalues(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
	procedure retry_message;
end;

 

/
