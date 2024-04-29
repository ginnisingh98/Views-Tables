--------------------------------------------------------
--  DDL for Package Body INL_SHIP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INL_SHIP_TYPES_PKG" AS
/* $Header: INLTSHTB.pls 120.0.12010000.1 2008/11/27 19:42:37 ebarbosa noship $ */

  --
  -- This procedure encapsulates MLS operations
  -- for INL_SHIP_TYPES_TL table.
  --
  PROCEDURE ADD_LANGUAGE IS
BEGIN

  DELETE FROM inl_ship_types_tl tl
  WHERE NOT EXISTS (SELECT NULL
                    FROM inl_ship_types_b b
                    WHERE b.ship_type_id = tl.ship_type_id);

  UPDATE inl_ship_types_tl tl
     SET (ship_type_name) = (SELECT b.ship_type_name
                             FROM inl_ship_types_tl b
                             WHERE b.ship_type_id = tl.ship_type_id
                             AND b.language = tl.source_lang)
  WHERE (tl.ship_type_id, tl.language) IN (SELECT subt.ship_type_id,
                                                  subt.language
                                           FROM inl_ship_types_tl subb, inl_ship_types_tl subt
                                           WHERE subb.ship_type_id = subt.ship_type_id
                                           AND subb.language = subt.source_lang
                                           AND (subb.ship_type_name <> subt.ship_type_name
                                           OR (subb.ship_type_name IS NULL AND subt.ship_type_name IS NOT NULL)
                                           OR (subb.ship_type_name IS NOT NULL AND subt.ship_type_name IS NULL)));

  INSERT INTO inl_ship_types_tl (ship_type_id,
                                 ship_type_name,
                                 created_by,
                                 creation_date,
                                 last_updated_by,
                                 last_update_date,
                                 last_update_login,
                                 language,
                                 source_lang)
                          SELECT b.ship_type_id,
                                 b.ship_type_name,
                                 b.created_by,
                                 b.creation_date,
                                 b.last_updated_by,
                                 b.last_update_date,
                                 b.last_update_login,
                                 l.language_code,
                                 b.source_lang
                          FROM inl_ship_types_tl b, fnd_languages l
                          WHERE l.installed_flag IN ('I', 'B')
                          AND b.language = userenv('LANG')
                          AND NOT EXISTS (SELECT NULL
                                          FROM inl_ship_types_tl t
                                          WHERE t.ship_type_id = b.ship_type_id
                                          AND t.language = l.language_code);
END ADD_LANGUAGE;


END INL_SHIP_TYPES_PKG;

/
