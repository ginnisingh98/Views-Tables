--------------------------------------------------------
--  DDL for Package BIS_PMF_MIGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_MIGRATION_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPMIGS.pls 115.7 2002/12/16 10:23:41 rchandra ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMIGS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Package Spec for Migration of PMF data .
REM |     Please refer to the datamodel for the changes.
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 21-July-2000 amkulkar Creation                                        |
REM |                                                                       |
REM +=======================================================================+
*/
--
--
/*Record type for all the dimension level ids.
  This record type may already be there but did not have time to dig thru
*/
TYPE target_level_rec IS RECORD(
     measure_id            BIS_INDICATORS.INDICATOR_ID%TYPE
    ,target_level_id       BIS_TARGET_LEVELS.TARGET_LEVEL_ID%TYPE
    ,org_levelid           BIS_TARGET_LEVELS.ORG_LEVEL_ID%TYPE
    ,time_levelid          BIS_TARGET_LEVELS.TIME_LEVEL_ID%TYPE
    ,dimension1_levelid    BIS_TARGET_LEVELS.DIMENSION1_LEVEL_ID%TYPE
    ,dimension2_levelid    BIS_TARGET_LEVELS.DIMENSION2_LEVEL_ID%TYPE
    ,dimension3_levelid    BIS_TARGET_LEVELS.DIMENSION3_LEVEL_ID%TYPE
    ,dimension4_levelid    BIS_TARGET_LEVELS.DIMENSION4_LEVEL_ID%TYPE
    ,dimension5_levelid    BIS_TARGET_LEVELS.DIMENSION5_LEVEL_ID%TYPE
);
--
TYPE target_rec   IS RECORD (
     measure_id		      BIS_INDICATORS.INDICATOR_ID%TYPE
    ,target_level_id	      BIS_TARGET_LEVELS.TARGET_LEVEL_ID%TYPE
    ,target_id                BIS_TARGET_VALUES.TARGET_ID%TYPE
    ,org_level_value          BIS_TARGET_VALUES.ORG_LEVEL_VALUE%TYPE
    ,time_level_value         BIS_TARGET_VALUES.TIME_LEVEL_VALUE%TYPE
    ,dimension1_level_value   BIS_TARGET_VALUES.DIMENSION1_LEVEL_VALUE%TYPE
    ,dimension2_level_value   BIS_TARGET_VALUES.DIMENSION2_LEVEL_VALUE%TYPE
    ,dimension3_level_value   BIS_TARGET_VALUES.DIMENSION3_LEVEL_VALUE%TYPE
    ,dimension4_level_value   BIS_TARGET_VALUES.DIMENSION4_LEVEL_VALUE%TYPE
    ,dimension5_level_value   BIS_TARGET_VALUES.DIMENSION5_LEVEL_VALUE%TYPE
);
--
TYPE resequenced_dimensions IS RECORD (
    dim_level_col       VARCHAR2(20000)
   ,dim_level_col_val   NUMBER
   ,dim_id		NUMBER
   ,seq_no		NUMBER
);
--
TYPE resequenced_dimensions_array IS TABLE OF
     BIS_PMF_MIGRATION_PUB.resequenced_dimensions
     INDEX BY BINARY_INTEGER;
--
TYPE reseq_target_values IS RECORD (
     target_level        VARCHAR2(20000)
    ,target_level_value  VARCHAR2(2000)
);
--
TYPE reseq_target_values_arr IS TABLE OF
     BIS_PMF_MIGRATION_PUB.reseq_target_values
     INDEX BY BINARY_INTEGER;
--
PROCEDURE MIGRATE_PERFORMANCE_MEASURES
(
 p_measure_short_name IN    VARCHAR2 DEFAULT NULL
,x_return_status      OUT NOCOPY   VARCHAR2
)
;
--
PROCEDURE  RESEQUENCE_DIMENSION_LEVELS(
 p_target_level_rec       IN    BIS_PMF_MIGRATION_PUB.target_level_rec
,x_resequenced_dimensions OUT NOCOPY   BIS_PMF_MIGRATION_PUB.resequenced_dimensions_array
,x_dim_count		  OUT NOCOPY	NUMBER
,x_return_status          OUT NOCOPY   NUMBER
);
--
PROCEDURE RESEQUENCE_TARGET_LEVEL_VALUES(
 p_target_rec		  IN    BIS_PMF_MIGRATION_PUB.target_rec
,p_dim_count		  IN	NUMBER
,x_reseq_target_values    OUT NOCOPY   BIS_PMF_MIGRATION_PUB.reseq_target_values_arr
,x_return_status          OUT NOCOPY   NUMBER
);
--
FUNCTION GET_DIMENSION_ID
(p_dimension_level_id     IN    NUMBER
)
RETURN NUMBER;
END BIS_PMF_MIGRATION_PUB;
-- SHOW ERRORS

 

/
