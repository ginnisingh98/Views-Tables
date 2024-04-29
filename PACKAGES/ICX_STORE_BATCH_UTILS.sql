--------------------------------------------------------
--  DDL for Package ICX_STORE_BATCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_STORE_BATCH_UTILS" AUTHID CURRENT_USER AS
/* $Header: ICXSTBUS.pls 115.2 99/07/17 03:26:07 porting ship $ */

-- Define  tab character
-- LSH removed CHR: C_TAB  CONSTANT VARCHAR2(10) := CHR(9);
C_TAB  CONSTANT VARCHAR2(10) := '	';
-- Define carriage return and line feed
-- LSH removed CHR: C_CR_LF  CONSTANT VARCHAR2(10) := CHR(13) || CHR(10);
C_CR_LF  CONSTANT VARCHAR2(10) := '
';

-- Define the field separator for the spread sheet
g_field_sep  VARCHAR2(10) := C_TAB;
g_line_sep  VARCHAR2(10) := C_CR_LF;

TYPE PROMPT_REC IS RECORD (
  attribute_label      VARCHAR2(80) := NULL,
  attribute_code       VARCHAR2(32) := NULL,
  display_value_length NUMBER(15)   := NULL
);

TYPE ITEM_PROMPTS_TABLE IS TABLE OF PROMPT_REC
  INDEX BY BINARY_INTEGER;

PROCEDURE get_prompts_table  (p_region_code IN VARCHAR2,
                              p_prompts_table OUT item_prompts_table);

PROCEDURE get_line  (p_text IN OUT LONG,
                     p_line IN OUT LONG);

PROCEDURE get_field  (p_line IN OUT LONG,
                      p_field OUT LONG);

PROCEDURE convert_to_date  (p_field IN VARCHAR2,
                            p_date_format IN VARCHAR2,
                            p_date OUT DATE,
                            p_error_flag OUT VARCHAR2);

PROCEDURE get_prompts_info  (p_prompts_table IN item_prompts_table,
                             p_attribute_code IN VARCHAR2,
                             p_attribute_info_record OUT prompt_rec);

FUNCTION replace_crlf (p_string IN VARCHAR2)
 RETURN VARCHAR2;

END icx_store_batch_utils;

 

/
