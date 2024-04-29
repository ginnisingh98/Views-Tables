--------------------------------------------------------
--  DDL for Package Body PA_REV_INTERFACE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_REV_INTERFACE_UTIL" AS
/* $Header: PAXFRVUB.pls 120.3 2006/05/03 06:35:17 rkchoudh noship $ */

  PROCEDURE set_xfc_unrel_rev_flag
  IS
  BEGIN
    fnd_profile.get('PA_INTERFACE_UNRELEASED_REVENUE',
                        g_interface_unreleased_revenue);
  END set_xfc_unrel_rev_flag;

  FUNCTION allow_unreleased_rev ( released_date date ) return VARCHAR2
  IS
  BEGIN

      IF released_date is null THEN
        IF NVL(g_interface_unreleased_revenue,'N') = 'Y' THEN  -- Bug 5198467
         return 'Y';
        ELSE
         return  'N' ;
        END IF;
      ELSE
        return  'Y' ;
      END IF;

  END allow_unreleased_rev;

END PA_REV_INTERFACE_UTIL;

/
