--------------------------------------------------------
--  DDL for Package JL_ZZ_GL_SEGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GL_SEGS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzgsgs.pls 115.1 2002/10/08 11:20:09 rbasker ship $ */

  TYPE SegmentArray IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

  QUOTAMARK    CONSTANT VARCHAR2(4) := '''';

  NEWLINE      CONSTANT VARCHAR2(4) := '
';

  MAX_SEG_SIZE CONSTANT NUMBER := 150;

  -- Get segments
  CURSOR seg (app_id   NUMBER,
              cht_id   NUMBER,
              seg_type VARCHAR2) IS
  SELECT segment_num,
         application_column_name
    FROM fnd_id_flex_segments
   WHERE (application_id, id_flex_code,
          id_flex_num, application_column_name) =
         (SELECT application_id, id_flex_code,
                 id_flex_num, application_column_name
            FROM fnd_segment_attribute_values a
           WHERE application_id         = app_id
             AND id_flex_code           = 'GL#'
             AND id_flex_num            = cht_id
             AND segment_attribute_type = seg_type
             AND attribute_value        = 'Y');

  -- Build all of the concatened segments
  FUNCTION get_columns (structure_number IN NUMBER,   -- key flexfield structure number
                        alias            IN VARCHAR2, -- table alias
                        segment          IN VARCHAR2, -- Flexfield segment (ALL,GL_ACCOUNT)
                        descriptor       IN VARCHAR2) -- segment descriptor (LOW,HIGH,TYPE)
  RETURN VARCHAR2;

  -- Assemble WHERE segment BETWEEN 'value1' AND 'value2' with connect segments
  FUNCTION get_between (structure_number IN NUMBER,   -- key flexfield structure number
                        alias            IN VARCHAR2, -- table alias
                        catseg1          IN VARCHAR2, -- Concatenated segments low
                        catseg2          IN VARCHAR2, -- Concatenated segments high
                        segment          IN VARCHAR2) -- Flexfield segment (ALL,GL_ACCOUNT)
  RETURN VARCHAR2;

END jl_zz_gl_segs_pkg;

 

/
