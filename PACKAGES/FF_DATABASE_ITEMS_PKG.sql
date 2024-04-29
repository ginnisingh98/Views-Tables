--------------------------------------------------------
--  DDL for Package FF_DATABASE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_DATABASE_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: ffdbi01t.pkh 120.5 2006/11/30 16:00:14 arashid noship $ */
--
-- Global Variables.
--

--
-- Flag to selectively disable triggers associated with this package.
--
g_disable_triggers varchar2(10) := 'N';

------------------------------ insert_tl_rows -----------------------------
--
-- NAME
--   insert_tl_rows
--
-- DESCRIPTION
--   Procedure for inserting _TL rows.
--
-- NOTES
--   Private routine for inserting _TL rows. For Oracle FF and Core PAY
--   use only.
--
procedure insert_tl_rows
(x_user_name            in varchar2
,x_user_entity_id       in number
,x_language             in varchar2
,x_translated_user_name in varchar2
,x_description          in varchar2
);
-------------------------------- insert_row -------------------------------
--
-- NAME
--   insert_row
--
-- DESCRIPTION
--   Standard row insert procedure. Creates the FF_DATABASE_ITEM_TL rows
--   also.
--
--   All parameters must be not NULL except for X_DESCRIPTION.
--
procedure insert_row
(x_rowid                in out nocopy varchar2
,x_user_name            in out nocopy varchar2
,x_user_entity_id       in            number
,x_data_type            in            varchar2
,x_definition_text      in            varchar2
,x_null_allowed_flag    in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
);
-------------------------------- update_row -------------------------------
--
-- NAME
--   update_row
--
-- DESCRIPTION
--   Standard update procedure. All parameters must be not NULL except
--   for X_DESCRIPTION.
--
procedure update_row
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_data_type            in            varchar2
,x_definition_text      in            varchar2
,x_null_allowed_flag    in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
);
------------------------- update_seeded_tl_rows ---------------------------
--
-- NAME
--   update_seeded_tl_rows
--
-- DESCRIPTION
--   Procedure for updating seeded _TL rows. This code does not raise
--   errors, but logs error messages for later processing and sets
--   x_got_error to TRUE upon error.
--
-- NOTES
--   If the old translated name will disappear after update, but is
--   referenced in a compiled Formula, the translated name is still
--   updated. The Formula information is saved for later processing.
--
--   Private routine for updating _TL rows. For Oracle FF and Core PAY
--   use only.
--
procedure update_seeded_tl_rows
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_language             in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
,x_got_error               out nocopy boolean
);
----------------------------- update_tl_rows ------------------------------
--
-- NAME
--   update_tl_rows
--
-- DESCRIPTION
--   Procedure for updating _TL rows.
--
-- NOTES
--   Private routine for updating _TL rows. For Oracle FF and Core PAY
--   use only.
--
procedure update_tl_rows
(x_user_name            in            varchar2
,x_user_entity_id       in            number
,x_language             in            varchar2
,x_translated_user_name in out nocopy varchar2
,x_description          in            varchar2
);
------------------------------ update_tl_row ------------------------------
--
-- NAME
--   update_tl_row
--
-- DESCRIPTION
--   Update procedure for an individual _TL row. All parameters must be
--   not NULL except for X_DESCRIPTION.
--
-- NOTES
--   Private routine for updating _TL row. For Oracle FF and Core PAY
--   use only.
--
procedure update_tl_row
(x_user_name            in varchar2
,x_user_entity_id       in number
,x_language             in varchar2
,x_source_lang          in varchar2
,x_translated_user_name in varchar2
,x_description          in varchar2
);
-------------------------------- delete_row -------------------------------
--
-- NAME
--   delete_row
--
-- DESCRIPTION
--   Standard delete procedure.
--
procedure delete_row
(x_user_name      in varchar2
,x_user_entity_id in number
);
--
------------------------------ delete_tl_rows -----------------------------
--
-- NAME
--   delete_tl_rows
--
-- DESCRIPTION
--   Procedure for deleting _TL rows.
--
-- NOTES
--   Private routine for deleting _TL rows. For Oracle FF and Core PAY
--   use only.
--
procedure delete_tl_rows
(x_user_name            in varchar2
,x_user_entity_id       in number
);
------------------------------- add_language ------------------------------
--
-- NAME
--   add_language
--
-- DESCRIPTION
--   Called from FFNLINS.sql when a new language is added.
--
-- NOTES
--   Performs internal COMMITs.
--
procedure add_language;
------------------------------ translate_row ------------------------------
--
-- NAME
--   translate_row
--
-- DESCRIPTION
--   Procedure to create a translated row. If X_LANGUAGE is NULL then
--   userenv('LANG') is used. This is effectively an update call.
--
procedure translate_row
(x_user_name            in varchar2
,x_legislation_code     in varchar2
,x_translated_user_name in varchar2
,x_description          in varchar2
,x_language             in varchar2
,x_owner                in varchar2
);

end ff_database_items_pkg;

 

/
