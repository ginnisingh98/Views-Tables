--------------------------------------------------------
--  DDL for Package Body XLA_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PROFILES_PKG" AS
/* $Header: xlacmpro.pkb 120.4 2003/02/25 01:24:34 sasingha ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_profiles_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Profiles Package                                               |
|                                                                       |
|    Profile options handling.                                          |
|                                                                       |
| HISTORY                                                               |
|    01-Jan-97 P. Labrevois    Created                                  |
|    08-Feb-01 P. Labrevois    Created for XLA                          |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_value                                                             |
|                                                                       |
| Get a profile option value                                            |
|                                                                       |
+======================================================================*/
FUNCTION  get_value
  (p_profile                      IN  VARCHAR2)
RETURN VARCHAR2

IS

l_value                           VARCHAR2(255);

BEGIN
xla_utility_pkg.trace('> Package xla_profiles_pkg.profile'               , 20);

xla_utility_pkg.trace('Profile name               = '||p_profile        , 30);

l_value  := fnd_profile.value(p_profile);

xla_utility_pkg.trace('Profile Value              = '||l_value          , 30);

xla_utility_pkg.trace('< Package xla_profiles_pkg.profile'               , 20);

RETURN l_value;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;
WHEN NO_DATA_FOUND                           THEN
   xla_exceptions_pkg.raise_message
      ('AX'           , 'AX_56702_SETUP_NO_PROFILE'
      ,'PROFILE'      , p_profile);
WHEN OTHERS                                  THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_profiles_pkg.get_value');
END get_value;


END xla_profiles_pkg;

/
