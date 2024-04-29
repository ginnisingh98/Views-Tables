--------------------------------------------------------
--  DDL for Package HR_DU_DP_PC_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_DP_PC_CONVERSION" AUTHID CURRENT_USER AS
/* $Header: perdupc.pkh 115.10 2002/11/28 16:57:08 apholt noship $ */


TYPE r_insert_statement_type IS RECORD(

  --api id for this record
  r_api_id		NUMBER,
  --string of none referencing columns (PVAL numbers)
  r_none_ref_PVAL	VARCHAR2(32767),
  --string of referencing columns (PVAL numbers)
  r_ref_PVAL		VARCHAR2(32767),
  --string of referencing columns (mapped column names)
  r_ref_Col_Names	VARCHAR2(32767),
  --string of comma separated entity id's relating to
  --appropriate referencing column's entities
  r_ref_Col_apis	VARCHAR2(300),
  --holds the current maximumn values of the id column
  r_id_curval		NUMBER(15),
  --holds a string of api_ids separated by commas
  r_string_apis		VARCHAR2(100),
  --holds a list of Pval's associated with the r_string_apis
  --to identify the correct location in the lines of the
  --column that will hold the value to point up to its parent
  r_api_PVALS	VARCHAR2(300),
  --holds a pval for the position in lines where the generic
  --location of the api table name is held. Used on such
  --api's as per_phones
  r_generic_pval	VARCHAR2(30));


TYPE R_MAPPED_TYPE IS RECORD(
  r_mapping_type	VARCHAR2(1),
  r_mapped_to_name	VARCHAR2(50),
  r_mapped_name		VARCHAR2(50));


TYPE insert_table_type IS TABLE OF R_INSERT_STATEMENT_TYPE
  INDEX BY BINARY_INTEGER;

--Holds all of the column headings
TYPE column_headings_table IS TABLE OF VARCHAR2(50)
  INDEX BY BINARY_INTEGER;

--Holds all of the mappedto names in the column mappings
--for a particular API
TYPE column_mapped_to_table IS TABLE OF R_MAPPED_TYPE
  INDEX BY BINARY_INTEGER;

--Holds all the upload_header_ids for the starting points
TYPE starting_point_table IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;



FUNCTION RETURN_PARENT_API_MODULE_ID (
                p_api_module_id  IN NUMBER,
                p_reference_string IN VARCHAR2)
                RETURN NUMBER;

PROCEDURE API_MODULE_ID_TO_TABLE_ID;

PROCEDURE SWITCH_REFERENCING_INITIAL(
                p_upload_id IN NUMBER);

PROCEDURE INSERT_API_MODULE_IDS (
                p_upload_id IN NUMBER);

PROCEDURE CREATE_INSERT_STRING(
                p_api_module_id  IN NUMBER,
                p_upload_header_id IN NUMBER,
                p_array_pos IN NUMBER);

FUNCTION RETURN_FIELD_VALUE (
                p_table IN VARCHAR2,
                p_record_id IN NUMBER,
                p_field_pk IN VARCHAR2,
                p_field_name IN VARCHAR2)
                RETURN VARCHAR2;

FUNCTION GENERAL_REFERENCING_COLUMN(
                p_pval_field IN VARCHAR2,
                p_api_module_id IN NUMBER,
                p_mapping_type IN VARCHAR2)
                RETURN VARCHAR2;

PROCEDURE VALIDATE(p_upload_id IN NUMBER);

PROCEDURE ROLLBACK(p_upload_id IN NUMBER);

PROCEDURE PROCESS_LINE(
                p_prev_upload_line_id IN NUMBER,
                p_prev_table_number IN NUMBER,
                p_target_ID IN NUMBER,
                p_target_api_module in NUMBER,
                p_upload_header_id IN NUMBER,
                p_upload_id IN NUMBER);

PROCEDURE REMOVE_SPACES (p_word IN OUT NOCOPY VARCHAR2,
                p_spaces OUT NOCOPY BOOLEAN);

END HR_DU_DP_PC_CONVERSION;

 

/
