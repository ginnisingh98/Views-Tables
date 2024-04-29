--------------------------------------------------------
--  DDL for Package Body FA_SECURITY2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SECURITY2" as
/* $Header: faxsec2b.pls 120.5.12010000.2 2009/07/19 13:01:25 glchen ship $ */

/* =============================================================================

        Name: 		build_predicate

        Description: 	Using static predicate on the odd synonym FA_BOOK_CONTROLS_SEC

        Parameters:	obj_schema	VARCHAR2
			obj_name	VARCHAR2
============================================================================= */
FUNCTION build_predicate ( obj_schema VARCHAR2, obj_name VARCHAR2 )
RETURN VARCHAR2 IS

l_predicate VARCHAR2(5000)   := '';

BEGIN

      -- if the list hasn't already been initialized then set_fa_context
      -- wasn't called from the initialization profile and security by book
      -- is not activated, so use no predicate

      IF (G_predicate_init = FALSE) then
         G_predicate := '';
         G_predicate_init   := TRUE;
      END IF;

      l_predicate := G_predicate ;

      return l_predicate;

END build_predicate;

END fa_security2;


/
