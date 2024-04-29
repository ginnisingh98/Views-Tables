--------------------------------------------------------
--  DDL for Package ASO_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_UPGRADE_PVT" AUTHID CURRENT_USER as
/* $Header: asovupgs.pls 115.4 2002/12/07 19:39:38 hagrawal ship $ */
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
  p_table_name  IN VARCHAR2 := NULL, -- Pass the table Name which raised the exception
  p_identifier  IN NUMBER := NULL -- Pass the corrosponding id here (e.g., quote_header_id,resource_id)
  );
END ASO_UPGRADE_PVT;

 

/
