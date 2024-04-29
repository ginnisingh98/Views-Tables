--------------------------------------------------------
--  DDL for Package XNP_SV_ORDERS$SOA_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_SV_ORDERS$SOA_EVENTS" AUTHID CURRENT_USER as
/* $Header: XNPSVO3S.pls 120.0 2005/05/30 11:49:27 appldev noship $ */


   procedure Startup(
             P_SV_SOA_ID in varchar2,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   procedure QueryList(
             P_SV_SOA_ID in varchar2 default null,
             Z_START in varchar2 default null,
             Z_ACTION in varchar2 default null,
             Z_DIRECT_CALL in boolean default false,
             Z_CHK in varchar2 default null);
   function QueryHits(
            P_SV_SOA_ID in varchar2 default null) return number;
end;

 

/
