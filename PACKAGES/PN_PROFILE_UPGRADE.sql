--------------------------------------------------------
--  DDL for Package PN_PROFILE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_PROFILE_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: PNXPROFS.pls 120.0 2005/05/29 11:48:28 appldev noship $ */


   PROCEDURE init_lookup_vars;

   PROCEDURE populate_profile_tbl;


   FUNCTION  get_value(p_resp_id NUMBER,
                       p_parameter   VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_def_set_of_books_id(p_org_id NUMBER)
      RETURN NUMBER;

   PROCEDURE init_lookup_vars_migr;

   PROCEDURE update_profile_tbl;


END pn_profile_upgrade;

 

/
