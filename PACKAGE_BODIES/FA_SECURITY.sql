--------------------------------------------------------
--  DDL for Package Body FA_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SECURITY" AS
/* $Header: faxsecb.pls 120.8.12010000.2 2009/07/19 13:02:22 glchen ship $ */

/* =============================================================================
        Name:           build_predicate

        Description:    Different object has a different predicate.  After the
                        object is identified, construct the predicate with the
                        org_id_list from the application context.

        Parameters:     obj_schema      VARCHAR2
                        obj_name        VARCHAR2
============================================================================= */FUNCTION build_predicate (obj_schema VARCHAR2, obj_name VARCHAR2 )
RETURN VARCHAR2 IS

    l_security_profile_id 	number := NULL;

BEGIN

   if (not G_predicate_init or
       G_user_id <> fnd_global.user_id or
       G_resp_id <> fnd_global.resp_id) then

      fnd_profile.get('FA_SECURITY_PROFILE_ID', l_security_profile_id);

      IF (l_security_profile_id is NULL) THEN

         G_predicate_stmt := '';

      ELSE

         DBMS_SESSION.SET_CONTEXT('fixed_assets',
                                  'fa_security_profile_id',
                                  l_security_profile_id);

         G_predicate_stmt :=
           'org_id is null or
            org_id in
             (SELECT organization_id
                FROM per_organization_list
               WHERE security_profile_id =
                     SYS_CONTEXT(''fixed_assets'', ''fa_security_profile_id''))';

      END IF;

      G_predicate_init := TRUE;
      G_user_id        := fnd_global.user_id;
      G_resp_id        := fnd_global.resp_id;

   END IF;

   return g_predicate_stmt;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_SESSION.SET_CONTEXT('fixed_assets', 'fa_org_id_list', NULL);
        return g_predicate_stmt;

END build_predicate;

END fa_security;


/
