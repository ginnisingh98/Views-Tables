--------------------------------------------------------
--  DDL for Package XNP_SV_ORDERS$SOA_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_ORDERS$SOA_SV" AUTHID CURRENT_USER as
/* $Header: XNPSVO2S.pls 120.0 2005/05/30 11:51:10 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_STATUS_DISPLAY_NAME in varchar2 default null,
             P_CUSTOMER_ID in varchar2 default null,
             P_CUSTOMER_NAME in varchar2 default null,
             P_REC_CODE in varchar2 default null,
             P_DON_CODE in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
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
             P_SV_SOA_ID in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default XNP_WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_STATUS_DISPLAY_NAME in varchar2 default null,
             P_CUSTOMER_ID in varchar2 default null,
             P_CUSTOMER_NAME in varchar2 default null,
             P_REC_CODE in varchar2 default null,
             P_DON_CODE in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryFirst(
             P_PORTING_ID in varchar2 default null,
             P_SUBSCRIPTION_TYPE in varchar2 default null,
             P_SUBSCRIPTION_TN in varchar2 default null,
             P_STATUS_DISPLAY_NAME in varchar2 default null,
             P_CUSTOMER_ID in varchar2 default null,
             P_CUSTOMER_NAME in varchar2 default null,
             P_REC_CODE in varchar2 default null,
             P_DON_CODE in varchar2 default null,
             P_NRC_CODE in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_STATUS_DISPLAY_NAME in varchar2 default null,
            P_CUSTOMER_ID in varchar2 default null,
            P_CUSTOMER_NAME in varchar2 default null,
            P_REC_CODE in varchar2 default null,
            P_DON_CODE in varchar2 default null,
            P_NRC_CODE in varchar2 default null) return number;
end;

 

/
