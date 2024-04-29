--------------------------------------------------------
--  DDL for Package PN_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_MO_GLOBAL_CACHE" AUTHID CURRENT_USER AS
  -- $Header: PNMOGLCS.pls 115.3 2002/09/24 20:06:29 ftanudja noship $

   PROCEDURE populate;
   FUNCTION get_org_attributes(p_org_id NUMBER)
    RETURN pn_mo_cache_utils.GlobalsRecord;

END pn_mo_global_cache;

 

/
