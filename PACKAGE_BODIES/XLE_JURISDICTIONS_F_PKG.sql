--------------------------------------------------------
--  DDL for Package Body XLE_JURISDICTIONS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_JURISDICTIONS_F_PKG" AS
/* $Header: xlejurib.pls 120.7 2005/10/06 20:14:23 achiroma ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xle_jurisdictions                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xle_jurisdictions                         |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/
PROCEDURE add_language

IS

BEGIN

DELETE FROM xle_jurisdictions_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xle_jurisdictions_b                b
       WHERE  b.jurisdiction_id                  = t.jurisdiction_id);


UPDATE xle_jurisdictions_tl   t
SET   (name)
   = (SELECT b.name
      FROM   xle_jurisdictions_tl               b
      WHERE  b.jurisdiction_id                  = t.jurisdiction_id
        AND  b.language                         = t.source_lang)
WHERE (t.jurisdiction_id
      ,t.language)
    IN (SELECT subt.jurisdiction_id
              ,subt.language
        FROM   xle_jurisdictions_tl                   subb
              ,xle_jurisdictions_tl                   subt
        WHERE  subb.jurisdiction_id                  = subt.jurisdiction_id
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
      ))
;

INSERT INTO xle_jurisdictions_tl
(jurisdiction_id
,name
,last_updated_by
,creation_date
,last_update_login
,last_update_date
,created_by
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.jurisdiction_id
      ,b.name
      ,b.last_updated_by
      ,b.creation_date
      ,b.last_update_login
      ,b.last_update_date
      ,b.created_by
      ,l.language_code
      ,b.source_lang
FROM   xle_jurisdictions_tl             b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xle_jurisdictions_tl               t
       WHERE  t.jurisdiction_id                  = b.jurisdiction_id
         AND  t.language                         = l.language_code);


END add_language;

end xle_jurisdictions_f_PKG;

/
