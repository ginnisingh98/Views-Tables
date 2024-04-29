--------------------------------------------------------
--  DDL for Package ZPB_TRANSFORM_IO_TABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_TRANSFORM_IO_TABLES" AUTHID CURRENT_USER AS
/* $Header: zpblevels.pls 115.10 2004/05/13 18:28:03 memayer ship $ */
TYPE DimRecTyp IS RECORD (
              dimension   zpb_solve_input_levels.dimension%TYPE,
              io_level    VARCHAR2(2000),
              loaded      zpb_solve_member_defs.SOURCE_TYPE%TYPE);
          TYPE DimTabTyp IS TABLE OF DimRecTyp
              INDEX BY BINARY_INTEGER;
          TYPE ref_cursor IS REF CURSOR;
          TYPE curr_dims_table IS TABLE OF zpb_solve_output_levels.DIMENSION%TYPE;
          dimname                CONSTANT CHAR(10) := 'Dim';
          INPUT_TYPE             CONSTANT VARCHAR2(10) := 'INPUT';
          OUTPUT_TYPE            CONSTANT VARCHAR2(10) := 'OUTPUT';

          PROCEDURE ZPB_TRANSFORM_INPUT_TABLE (p_ac_id IN NUMBER,
                                              p_line_dim IN VARCHAR2,
                                              p_temp_table IN VARCHAR2,
                                              p_userid  IN NUMBER,
                                              p_view_dim_name IN VARCHAR2,
                                              p_view_member_column IN VARCHAR2,
                                              p_view_long_lbl_column IN VARCHAR2,
                                              labelCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor,
                                              dataCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor);

          PROCEDURE ZPB_TRANSFORM_OUTPUT_TABLE (p_ac_id IN NUMBER,
                                               p_line_dim IN VARCHAR2,
                                               p_temp_table IN VARCHAR2,
                                               p_userid  IN NUMBER,
                                               p_view_dim_name IN VARCHAR2,
                                               p_view_member_column IN VARCHAR2,
                                               p_view_long_lbl_column IN VARCHAR2,
                                               labelCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor,
                                               dataCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor);

        END ZPB_TRANSFORM_IO_TABLES;


 

/
