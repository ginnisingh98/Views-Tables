--------------------------------------------------------
--  DDL for Package JTF_TAE_INDEX_CREATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TAE_INDEX_CREATION_PVT" AUTHID CURRENT_USER AS
/*$Header: jtftaeis.pls 120.0 2005/06/02 18:21:12 appldev ship $*/
/* -- =========================================================================+
-- |               Copyright (c) 2002 Oracle Corporation                       |
-- |                  Redwood Shores, California, USA                          |
-- |                       All rights reserved.                                |
-- +===========================================================================
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TAE_INDEX_CREATION_PVT
--    ---------------------------------------------------
--    PURPOSE
--
--      This package is used to return a list of column in order of selectivity.
--      And create indices on columns in order of  input
--
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/02/2002    SHLI        Created
--
--    End of Comments  */

Type value_varray IS VARRAY (30) of integer;
TYPE name_varray  IS VARRAY (30) OF varchar2(25);

FUNCTION  SELECTIVITY(p_TABLE_NAME IN VARCHAR2)  return number;

procedure CREATE_INDEX ( p_table_name           IN  VARCHAR2,
                         p_trans_object_type_id IN  NUMBER,
                         p_source_id            IN  NUMBER,
                         x_Return_Status        OUT NOCOPY VARCHAR2,
                         p_run_mode             IN VARCHAR2 := 'TAP');

PROCEDURE DROP_TABLE_INDEXES( p_table_name     IN   VARCHAR2
                            , x_return_status  OUT NOCOPY  VARCHAR2 );

PROCEDURE ANALYZE_TABLE_INDEX( p_TABLE_NAME     IN   VARCHAR2,
                               P_PERCENT        IN   NUMBER,
                               x_return_status  OUT NOCOPY  VARCHAR2 );

PROCEDURE TRUNCATE_TABLE( p_TABLE_NAME     IN   VARCHAR2,
                          x_return_status  OUT NOCOPY  VARCHAR2 );

END JTF_TAE_INDEX_CREATION_PVT;


 

/
