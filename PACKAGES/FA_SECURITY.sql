--------------------------------------------------------
--  DDL for Package FA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SECURITY" AUTHID CURRENT_USER as
/* $Header: faxsecs.pls 120.2.12010000.2 2009/07/19 13:02:51 glchen ship $ */

  G_predicate_stmt     varchar2(4000);
  G_predicate_init     boolean := FALSE;
  G_user_id            number := -1;
  G_resp_id            number := -1;

  function build_predicate(
	obj_schema 	VARCHAR2,
	obj_name 	VARCHAR2
  ) RETURN VARCHAR2;

end fa_security;

/
