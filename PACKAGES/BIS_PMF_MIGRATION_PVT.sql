--------------------------------------------------------
--  DDL for Package BIS_PMF_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_MIGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVMIGS.pls 120.0 2005/06/01 15:41:00 appldev noship $ */
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
REM | 03-JUN-2004 ankgoel  Modified for bug#3583357. Added procedures for   |
REM |                      re-sequencing dimensions in                      |
REM |                      bis_indicator_dimensions using the dim level     |
REM |                      order in bis_target_levels.                      |
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
TYPE dim_values_rec   IS RECORD (
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
     BIS_PMF_MIGRATION_PVT.resequenced_dimensions
     INDEX BY BINARY_INTEGER;
--
TYPE reseq_dim_values IS RECORD (
     dim_level_name        VARCHAR2(20000)
    ,dim_level_value       VARCHAR2(2000)
);
--
TYPE reseq_dim_values_arr IS TABLE OF
     BIS_PMF_MIGRATION_PVT.reseq_dim_values
     INDEX BY BINARY_INTEGER;
--
PROCEDURE MIGRATE_PERFORMANCE_MEASURES
(
 x_return_status      OUT NOCOPY   VARCHAR2
,x_return_code        OUT NOCOPY   NUMBER
)
;
--
PROCEDURE migrate_indicator_dimensions(
 x_return_status      OUT NOCOPY   VARCHAR2
,x_return_code        OUT NOCOPY   NUMBER
);
--
PROCEDURE  RESEQUENCE_DIMENSION_LEVELS(
 p_target_level_rec       IN    BIS_PMF_MIGRATION_PVT.target_level_rec
,x_resequenced_dimensions OUT NOCOPY   BIS_PMF_MIGRATION_PVT.resequenced_dimensions_array
,x_dim_count		  OUT NOCOPY	NUMBER
,x_return_status          OUT NOCOPY   NUMBER
);
--
PROCEDURE RESEQUENCE_DIM_LEVEL_VALUES(
 p_dimvalues_rec          IN    BIS_PMF_MIGRATION_PVT.dim_values_rec
,p_dim_count		  IN	NUMBER
,x_reseq_dim_values       OUT NOCOPY   BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr
,x_return_status          OUT NOCOPY   NUMBER
);
--
PROCEDURE RESEQUENCE_IND_LEVEL_VALUES(
 p_dimvalues_rec          IN BIS_PMF_MIGRATION_PVT.dim_values_Rec
,p_dim_count              IN NUMBER
,x_reseq_dim_values       OUT NOCOPY BIS_PMF_MIGRATION_PVT.reseq_dim_values_arr
,x_return_status          OUT NOCOPY NUMBER
);
--
PROCEDURE update_bis_indicators (
 p_indicator_id  IN  NUMBER
,p_dim_level_id  IN  NUMBER
,p_sequence_no   IN  NUMBER
);
--
PROCEDURE resequence_ind_dimensions(
 p_indicator_id		IN	NUMBER
);
--
FUNCTION need_resequence (
 p_indicator_id  IN  NUMBER
,p_dim_level_id  IN  NUMBER
,p_sequence_no   IN  NUMBER
)
RETURN BOOLEAN;
--
FUNCTION GET_DIMENSION_ID
(p_dimension_level_id     IN    NUMBER
)
RETURN NUMBER;
FUNCTION NEEDS_MIGRaTION
(p_target_level_rec      IN     BIS_TARGET_LEVEL_PUB.TARGET_LEVEl_REC_TYPE
)
RETURN BOOLEAN;
END BIS_PMF_MIGRATION_PVT;
-- SHOW ERRORS

 

/
