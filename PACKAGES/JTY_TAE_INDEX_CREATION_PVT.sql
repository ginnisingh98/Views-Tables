--------------------------------------------------------
--  DDL for Package JTY_TAE_INDEX_CREATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TAE_INDEX_CREATION_PVT" AUTHID CURRENT_USER AS
/*$Header: jtfyaeis.pls 120.2 2006/03/30 17:26:42 achanda noship $*/
/* -- =========================================================================+
-- |               Copyright (c) 2002 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TAE_INDEX_CREATION_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      This package has public api to do the following :
--      a) return a list of column in order of selectivity
--      b) create index on interface tables
--      c) drop indexes on a table
--      d) analyze a table
--      e) truncate a table
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/02/2005    achanda        Created
--
--    End of Comments  */

Type value_varray IS VARRAY (400) of integer;
TYPE name_varray  IS VARRAY (400) OF varchar2(30);

PROCEDURE  SELECTIVITY(
  p_TABLE_NAME IN VARCHAR2,
  p_mode       IN VARCHAR2,
  p_source_id  IN NUMBER,
  x_return_status  OUT NOCOPY  VARCHAR2);

PROCEDURE  DEA_SELECTIVITY(
  p_TABLE_NAME IN VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2);

procedure CREATE_INDEX (
  p_table_name    IN  VARCHAR2,
  p_trans_id      IN  NUMBER,
  p_source_id     IN  NUMBER,
  p_program_name  IN  VARCHAR2,
  p_mode          IN  VARCHAR2,
  x_Return_Status OUT NOCOPY VARCHAR2,
  p_run_mode      IN  VARCHAR2);

PROCEDURE DROP_TABLE_INDEXES(
  p_table_name     IN   VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2 );

PROCEDURE ANALYZE_TABLE_INDEX(
  p_TABLE_NAME     IN   VARCHAR2,
  P_PERCENT        IN   NUMBER,
  x_return_status  OUT NOCOPY  VARCHAR2 );

PROCEDURE TRUNCATE_TABLE(
  p_TABLE_NAME     IN   VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2 );

END JTY_TAE_INDEX_CREATION_PVT;

 

/
