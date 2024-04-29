--------------------------------------------------------
--  DDL for Package HR_DU_DI_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_DI_INSERT" AUTHID CURRENT_USER AS
/* $Header: perduext.pkh 120.1 2005/06/27 02:51:19 mroberts noship $ */

--global variable to count the number of lines down the spread sheet the
--program has travelled

g_counter		   NUMBER;
g_delimiter_count	   NUMBER;
g_flat_file_delimiter	   VARCHAR2(10);
g_current_delimiter	   VARCHAR2(10);
g_current_delimiter_string VARCHAR2(50);

g_tab_delimiter		   VARCHAR2(10)	 := hr_du_utility.local_CHR(9);
g_carr_delimiter           VARCHAR2(10)   := hr_du_utility.local_CHR(13);
g_linef_delimiter          VARCHAR2(10)   := hr_du_utility.local_CHR(10);

g_length_carr              NUMBER   := length(g_carr_delimiter);
g_length_linef 		   NUMBER   := length(g_linef_delimiter);



TYPE R_ORIGINAL_HEADER_TYPE IS RECORD
 (
  r_upload_header_id	NUMBER,
  r_api_module_id	NUMBER);

TYPE TABLE_HEADER_API_TYPE IS TABLE OF R_ORIGINAL_HEADER_TYPE
  INDEX BY BINARY_INTEGER;

TYPE TABLE_LOCAL_CHRS IS TABLE OF VARCHAR2(20)
  INDEX BY BINARY_INTEGER;

TYPE update_line_table IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

g_line_table  	UPDATE_LINE_TABLE;
g_header_table	TABLE_HEADER_API_TYPE;

Char_table	TABLE_LOCAL_CHRS;


FUNCTION WORDS_ON_LINE(p_line IN VARCHAR2)
                     RETURN NUMBER;

FUNCTION Return_Word(p_line IN varchar2,
                     p_word_num IN NUMBER)
 	             RETURN Varchar2;

PROCEDURE Extract_API_locations (
                     p_filehandle IN utl_file.file_type,
                     p_upload_id IN NUMBER);

PROCEDURE Extract_Headers (
                     p_filehandle IN utl_file.file_type,
                     p_upload_id IN NUMBER);

FUNCTION EXTRACT_DESCRIPTORS (
                     p_filehandle IN utl_file.file_type,
                     p_upload_id IN NUMBER,
                     p_upload_header_id IN NUMBER)
                     RETURN VARCHAR2;

PROCEDURE Handle_API_Files (
                     p_Location IN VARCHAR2,
                     p_upload_id IN NUMBER);

PROCEDURE Update_Upload_table (
                     p_upload_id IN NUMBER);

FUNCTION Return_File_Name(
                     p_upload_id IN NUMBER)
                     RETURN VARCHAR2;

FUNCTION Open_file ( p_file_location IN varchar2,
                     p_file_name IN varchar2)
                     RETURN utl_file.file_type;


PROCEDURE EXTRACT_LINES(
                     p_filehandle IN utl_file.file_type,
                     p_upload_id IN NUMBER,
                     p_original_upload_header_id IN NUMBER,
                     p_reference_type IN VARCHAR2,
                     p_api_module_id IN NUMBER,
                     p_upload_header_id IN NUMBER);

PROCEDURE ORDERED_SEQUENCE(
                     p_upload_id IN NUMBER);

PROCEDURE ROLLBACK(  p_upload_id IN NUMBER);

PROCEDURE VALIDATE(  p_upload_id IN NUMBER);

FUNCTION NUM_DELIMITERS(
                     p_line IN VARCHAR2)
                     RETURN NUMBER;

end hr_du_di_insert;

 

/
