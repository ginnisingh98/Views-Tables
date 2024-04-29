--------------------------------------------------------
--  DDL for Package XNP_NUMBER_SPLITS$NUMBER_SPLIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_NUMBER_SPLITS$NUMBER_SPLIT" AUTHID CURRENT_USER as
/* $Header: XNPNUM2S.pls 120.0 2005/05/30 11:44:15 appldev noship $ */


   procedure Startup(
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure ActionQuery(
             P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
             P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
             P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             P_L_NRE_STARTING_NUMBER in varchar2 default null,
             P_L_NRE_ENDING_NUMBER in varchar2 default null,
             P_L_NRE2_STARTING_NUMBER in varchar2 default null,
             P_L_NRE2_ENDING_NUMBER in varchar2 default null,
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
             P_NUMBER_SPLIT_ID in varchar2 default null,
             Z_POST_DML in boolean default false,
             Z_FORM_STATUS in number default XNP_WSGL.FORM_STATUS_OK,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
             P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
             P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             P_L_NRE_STARTING_NUMBER in varchar2 default null,
             P_L_NRE_ENDING_NUMBER in varchar2 default null,
             P_L_NRE2_STARTING_NUMBER in varchar2 default null,
             P_L_NRE2_ENDING_NUMBER in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryFirst(
             P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
             P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
             P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
             P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
             P_L_NRE_STARTING_NUMBER in varchar2 default null,
             P_L_NRE_ENDING_NUMBER in varchar2 default null,
             P_L_NRE2_STARTING_NUMBER in varchar2 default null,
             P_L_NRE2_ENDING_NUMBER in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
            P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
            P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            P_L_NRE_STARTING_NUMBER in varchar2 default null,
            P_L_NRE_ENDING_NUMBER in varchar2 default null,
            P_L_NRE2_STARTING_NUMBER in varchar2 default null,
            P_L_NRE2_ENDING_NUMBER in varchar2 default null) return number;
   procedure l_nre2_object_reference_listof(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
   procedure l_nre_object_reference_listofv(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2 default null);
end;

 

/
