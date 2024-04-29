--------------------------------------------------------
--  DDL for Package AR_MO_GLOBAL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_MO_GLOBAL_CACHE" AUTHID CURRENT_USER as
/*$Header: ARMOGLCS.pls 120.5 2006/07/28 05:14:23 apandit noship $ */

   /* --###***** AR Specific code to store and retrieve current context org  */
        g_current_org_id  Number;
        FUNCTION get_current_org_id
                RETURN number;
        PROCEDURE set_current_org_id(p_org_id number);

   /* --###***** AR Specific code to store and retrieve current context org   */

   /* -----------------------------------------------------------------------
      This procedure retrieves operating unit attributes and
      stores them in the cache.
      ----------------------------------------------------------------------- */
       PROCEDURE  populate(p_org_id IN NUMBER DEFAULT NULL);

   /* -----------------------------------------------------------------------
       This function returns one row of cached data.
      ----------------------------------------------------------------------- */
        FUNCTION get_org_attributes(p_org_id  NUMBER)
                RETURN ar_mo_cache_utils.GlobalsRecord;
END ar_mo_global_cache;

 

/
