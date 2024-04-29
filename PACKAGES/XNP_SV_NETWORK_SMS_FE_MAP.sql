--------------------------------------------------------
--  DDL for Package XNP_SV_NETWORK$SMS_FE_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_NETWORK$SMS_FE_MAP" AUTHID CURRENT_USER as
/* $Header: XNPSVN3S.pls 120.0 2005/05/30 11:48:50 appldev noship $ */


   procedure Startup(
             P_SV_SMS_ID in varchar2,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_SV_SMS_ID in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_SV_SMS_ID in varchar2 default null) return number;
end;

 

/
