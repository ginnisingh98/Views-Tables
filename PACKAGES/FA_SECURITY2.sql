--------------------------------------------------------
--  DDL for Package FA_SECURITY2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SECURITY2" AUTHID CURRENT_USER as
/* $Header: faxsec2s.pls 120.3.12010000.2 2009/07/19 13:01:54 glchen ship $ */

  G_predicate          VARCHAR2(5000);
  G_predicate_init     boolean := FALSE;


  function build_predicate(
	obj_schema 	VARCHAR2,
	obj_name 	VARCHAR2
  ) RETURN VARCHAR2;

end fa_security2;

/
