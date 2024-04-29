--------------------------------------------------------
--  DDL for Package XNP_SV_NETWORK$SMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_NETWORK$SMS_SV" AUTHID CURRENT_USER as
/* $Header: XNPSVN2S.pls 120.0 2005/05/30 11:49:36 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
             P_REC_CODE in varchar2 default null,
	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2 default null,
             Z_CHK in varchar2 default null);
   procedure TextFrame(Z_HEADER in varchar2 default null,
                       Z_FIRST  in varchar2 default null,
                       Z_TEXT   in varchar2 default null,
                       Z_FOOTER in varchar2 default null);
   procedure FormQuery(             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryView(
             P_SV_SMS_ID in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default XNP_WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
             P_REC_CODE in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryFirst(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
             P_REC_CODE in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_NRC_CODE in varchar2 default null,
            P_REC_CODE in varchar2 default null) return number;
end;

 

/
