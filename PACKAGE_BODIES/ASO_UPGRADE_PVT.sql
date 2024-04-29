--------------------------------------------------------
--  DDL for Package Body ASO_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_UPGRADE_PVT" as
/* $Header: asovupgb.pls 115.6 2002/12/07 19:53:05 hagrawal ship $ */
-- Start of Comments
-- Package name     : ASO_UPGRADE_PVT
-- Purpose          :This package will be used to insert the data in all aso migration scripts.
-- History          :
-- NOTE             :Data will be inserted in ASO_UPGRADE_ERRORS table.
-- End of Comments

 Procedure add_message(
  p_module_name IN VARCHAR2, --Valid Module Names are 'ASO','QOT:FORMS','QOT:HTML'
  p_error_level IN VARCHAR2, -- Valid error Levels are 'ERROR','WARNING','INFORMATION'
  p_error_text  IN VARCHAR2,
  p_creation_date IN DATE := sysdate,
  p_source_name IN VARCHAR2, -- Pass the scriptname here like 'asopromg.sql'
  p_table_name  IN VARCHAR2  := NULL, -- Pass the table Name which raised the exception
  p_identifier  IN NUMBER := NULL -- Pass the corrosponding id here (e.g., quote_header_id,resource_id)
  )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO ASO_UPGRADE_ERRORS
  (UPGRADE_ID,
   MODULE_NAME,
   ERROR_LEVEL,
   ERROR_TEXT,
   CREATION_DATE,
   SOURCE_NAME,
   TABLE_NAME,
   IDENTIFIER
   )
   VALUES
  (
  ASO_UPGRADE_ERRORS_S.NEXTVAL,
  p_module_name,
  p_error_level,
  p_error_text,
  p_creation_date,
  p_source_name,
  p_table_name,
  p_identifier
  );
 COMMIT;
  EXCEPTION
   WHEN OTHERS THEN
     Raise;
END;
END ASO_UPGRADE_PVT;

/
