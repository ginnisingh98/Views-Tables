--------------------------------------------------------
--  DDL for Package Body XLA_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_LOOKUPS_PKG" AS
/* $Header: xlacmlkp.pkb 120.3 2003/03/18 00:40:30 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_lookup_pkg                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Lookups Package                                                |
|                                                                       |
| HISTORY                                                               |
|    07-Dec-95 P. Labrevois    Created                                  |
|    08-Feb-01                 Converted to XLA                         |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_meaning                                                           |
|                                                                       |
| Get the meaning for an lookup type and lookup code.                   |
|                                                                       |
+======================================================================*/
FUNCTION  get_meaning
  (p_lookup_type                  IN  VARCHAR2
  ,p_lookup_code                  IN  VARCHAR2)
RETURN VARCHAR2

IS

l_meaning                         VARCHAR2(80);

BEGIN
xla_utility_pkg.trace('> xla_lookups_pkg.get_meaning'                       , 10);

xla_utility_pkg.trace('Lookup type               = '||p_lookup_type     , 20);
xla_utility_pkg.trace('Lookup_code               = '||p_lookup_code     , 20);

SELECT meaning
INTO   l_meaning
FROM   xla_lookups
WHERE  lookup_type = p_lookup_type
  AND  lookup_code = p_lookup_code
;

xla_utility_pkg.trace('Meaning                   = '||l_meaning         , 20);

xla_utility_pkg.trace('< xla_lookups_pkg.get_meaning'                       , 10);

RETURN l_meaning;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_lookups_pkg.get_meaning');
END get_meaning;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_lookuptype_meaning                                                |
|                                                                       |
| Get the meaning for an lookup type                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_lookuptype_meaning
  (p_view_application_id          IN  NUMBER
  ,p_lookup_type                  IN  VARCHAR2)
RETURN VARCHAR2

IS

l_meaning                         VARCHAR2(80);

BEGIN
xla_utility_pkg.trace('> xla_lookups_pkg.get_lookuptype_meaning'                       , 10);

xla_utility_pkg.trace('Lookup type               = '||p_lookup_type     , 20);
xla_utility_pkg.trace('Lookup_code               = '||p_view_application_id   , 20);

SELECT meaning
INTO   l_meaning
FROM   fnd_lookup_types_vl
WHERE  lookup_type = p_lookup_type
  AND  view_application_id = p_view_application_id
;

xla_utility_pkg.trace('Meaning                   = '||l_meaning         , 20);

xla_utility_pkg.trace('< xla_lookups_pkg.get_lookuptype_meaning'                , 10);

RETURN l_meaning;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_lookups_pkg.get_lookuptype_meaning');
END get_lookuptype_meaning;

END xla_lookups_pkg;

/
