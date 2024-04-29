--------------------------------------------------------
--  DDL for Package Body PJM_TASK_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_TASK_ATTRIBUTES_PKG" AS
/* $Header: PJMPTAB.pls 115.7 2003/02/15 06:49:31 alaw ship $ */

PROCEDURE LOAD_ROW
( X_Assignment_Type    IN VARCHAR2
, X_Attribute_Code     IN VARCHAR2
, X_Owner              IN VARCHAR2
, X_Attribute_Name     IN VARCHAR2
, X_Form_Field_Name    IN VARCHAR2
) IS

  user_id number;

BEGIN

  if (X_Owner = 'SEED') then
    user_id := 1;
  else
    user_id := 0;
  end if;

  --
  -- load the record
  --
  BEGIN
    --
    -- Update non-translated values in all languages
    --
    UPDATE pjm_task_attributes_tl
    SET    form_field_name  = X_Form_Field_Name
    ,      last_update_date = sysdate
    ,      last_updated_by  = user_id
    WHERE  assignment_type  = X_Assignment_Type
    AND    attribute_code   = X_Attribute_Code;

    --
    -- Update translated values in current language
    --
    UPDATE pjm_task_attributes_tl
    SET    attribute_name   = X_Attribute_Name
    ,      source_lang      = userenv('LANG')
    WHERE  assignment_type  = X_Assignment_Type
    AND    attribute_code   = X_Attribute_Code
    AND    userenv('LANG') in ( language , source_lang );

    --
    -- refresh translation in PJM_TASK_ATTR_USAGES_TL
    --
    UPDATE pjm_task_attr_usages_tl
    SET    prompt           = X_Attribute_Name
    ,      last_update_date = sysdate
    ,      last_updated_by  = user_id
    ,      source_lang      = userenv('LANG')
    WHERE  assignment_type  = X_Assignment_Type
    AND    attribute_code   = X_Attribute_Code
    AND    language         = userenv('LANG')
    AND    source_lang <> language;

    --
    -- Insert if missing
    --
    INSERT INTO pjm_task_attributes_tl
    (      assignment_type
    ,      attribute_code
    ,      last_update_date
    ,      last_updated_by
    ,      creation_date
    ,      created_by
    ,      last_update_login
    ,      attribute_name
    ,      form_field_name
    ,      language
    ,      source_lang )
    SELECT X_Assignment_Type
    ,      X_Attribute_Code
    ,      sysdate
    ,      user_id
    ,      sysdate
    ,      user_id
    ,      -1
    ,      X_Attribute_Name
    ,      X_Form_Field_Name
    ,      L.language_code
    ,      userenv('LANG')
    FROM   fnd_languages L
    WHERE  L.installed_flag in ('I' , 'B')
    AND NOT EXISTS (
        SELECT null
        FROM   pjm_task_attributes_tl
        WHERE  assignment_type = X_Assignment_Type
        AND    attribute_code = X_Attribute_Code
        AND    language = L.language_code
    );

  EXCEPTION
    when others then
      raise;

  END;

END LOAD_ROW;

PROCEDURE TRANSLATE_ROW
( X_Assignment_Type    IN VARCHAR2
, X_Attribute_Code     IN VARCHAR2
, X_Owner              IN VARCHAR2
, X_Attribute_Name     IN VARCHAR2
) IS

  user_id number;

BEGIN

  if (X_Owner = 'SEED') then
     user_id := 1;
  else
     user_id := 0;
  end if;

  --
  -- update the translation
  --
  UPDATE pjm_task_attributes_tl
  SET    attribute_name   = X_Attribute_Name
  ,      last_update_date = sysdate
  ,      last_updated_by  = user_id
  ,      source_lang      = userenv('LANG')
  WHERE  assignment_type  = X_Assignment_Type
  AND    attribute_code   = X_Attribute_Code
  AND    userenv('LANG') in ( language , source_lang );

  --
  -- refresh translation in PJM_TASK_ATTR_USAGES_TL
  --
  UPDATE pjm_task_attr_usages_tl
  SET    prompt           = X_Attribute_Name
  ,      last_update_date = sysdate
  ,      last_updated_by  = user_id
  ,      source_lang      = userenv('LANG')
  WHERE  assignment_type  = X_Assignment_Type
  AND    attribute_code   = X_Attribute_Code
  AND    language         = userenv('LANG')
  AND    source_lang <> language;

EXCEPTION
  when no_data_found then
    null;

END TRANSLATE_ROW;


PROCEDURE ADD_LANGUAGE
IS
BEGIN

  INSERT INTO pjm_task_attributes_tl
  ( assignment_type
  , attribute_code
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , form_field_name
  , attribute_name
  , language
  , source_lang
  )
  SELECT M.assignment_type
  ,      M.attribute_code
  ,      M.creation_date
  ,      M.created_by
  ,      M.last_update_date
  ,      M.last_updated_by
  ,      M.last_update_login
  ,      M.form_field_name
  ,      M.attribute_name
  ,      L.language_code
  ,      M.source_lang
  FROM   pjm_task_attributes_tl M
  ,      fnd_languages L
  WHERE  M.language = userenv('LANG')
  AND    L.installed_flag in ( 'I' , 'B' )
  AND NOT EXISTS (
      SELECT null
      FROM   pjm_task_attributes_tl
      WHERE  assignment_type = M.assignment_type
      AND    attribute_code = M.attribute_code
      AND    language = L.language_code );

END ADD_LANGUAGE;

END PJM_TASK_ATTRIBUTES_PKG;

/
