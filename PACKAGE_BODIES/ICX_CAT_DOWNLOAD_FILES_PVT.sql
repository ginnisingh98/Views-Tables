--------------------------------------------------------
--  DDL for Package Body ICX_CAT_DOWNLOAD_FILES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_DOWNLOAD_FILES_PVT" AS
/* $Header: ICXVDWNB.pls 120.0 2006/07/15 01:28:28 kaholee noship $*/

PROCEDURE insert_instruction_files
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  DELETE FROM icx_por_template_files;

  l_err_loc := 200;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_Spreadsheet.htm', 'TXT', 'ALL', 'Instructions for TXT upload.'
  FROM dual;

  l_err_loc := 300;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_XML.htm', 'XML', 'ALL', 'Instructions for XML upload.'
  FROM dual;

  l_err_loc := 400;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_cXML.htm', 'CXML', 'ALL', 'Instructions for cXML upload.'
  FROM dual;

  l_err_loc := 500;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_CIF.htm', 'CIF', 'ALL', 'Instructions for CIF upload.'
  FROM dual;

  l_err_loc := 600;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_Schema.htm', 'SCHEMA', 'ALL', 'Instructions for schema upload.'
  FROM dual;

  l_err_loc := 700;
  INSERT INTO icx_por_template_files
    (filename, usage, template_type, description)
  SELECT 'Readme_Converter.htm', 'CONVERTER', 'ALL', 'Instructions for converter.'
  FROM dual;

  l_err_loc := 800;
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
  ROLLBACK;
  RAISE_APPLICATION_ERROR
    (-20000,
     'Exception at ICX_CAT_DOWNLOAD_FILES_PVT.insert_instruction_files(' ||
     l_err_loc || '), ' || SQLERRM);

END insert_instruction_files;

END ICX_CAT_DOWNLOAD_FILES_PVT;

/
