--------------------------------------------------------
--  DDL for Package Body BSC_DESIGNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DESIGNER_PVT" AS
/* $Header: BSCDSGB.pls 120.14 2007/06/29 08:29:01 ankgoel ship $ */

g_kpi_metadata_tables         t_kpi_metadata_tables;
g_num_kpi_metadata_tables     NUMBER := 0;
g_obj_kpi_metadata_tables     t_kpi_metadata_tables;
g_num_obj_kpi_metadata_tables NUMBER := 0;


PROCEDURE Init_Kpi_Metadata_Tables_Array IS
BEGIN

/* TABLES TO BE COPIED BASED ON OBJECTIVE AND KPI_MEASURE_ID */
g_num_obj_kpi_metadata_tables := 0;

g_num_obj_kpi_metadata_tables := g_num_obj_kpi_metadata_tables + 1;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_MEASURES_B';
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_type   := C_KPI_MEAS_TABLE;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_column := C_INDICATOR;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_obj_kpi_metadata_tables := g_num_obj_kpi_metadata_tables + 1;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_name   := 'BSC_KPI_MEASURE_PROPS';
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_type   := C_KPI_MEAS_TABLE;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_column := C_INDICATOR;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_obj_kpi_metadata_tables := g_num_obj_kpi_metadata_tables + 1;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_name   := 'BSC_COLOR_TYPE_PROPS';
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_type   := C_KPI_MEAS_TABLE;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_column := C_INDICATOR;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_obj_kpi_metadata_tables := g_num_obj_kpi_metadata_tables + 1;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_name   := 'BSC_KPI_MEASURE_WEIGHTS';
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_type   := C_KPI_MEAS_TABLE;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_column := C_INDICATOR;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).copy_type := C_MASTER_KPI;

/* No need to copy calculated color data since the Shared Objective and KPIs
   are put to prototype mode, when duplicated.
g_num_obj_kpi_metadata_tables := g_num_obj_kpi_metadata_tables + 1;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_name   := 'BSC_SYS_KPI_COLORS';
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_type   := C_KPI_MEAS_TABLE;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).table_column := C_INDICATOR;
g_obj_kpi_metadata_tables(g_num_obj_kpi_metadata_tables).duplicate_data := bsc_utility.YES;*/

/* TABLES TO BE COPIED BASED ON OBJECTIVE */
g_num_kpi_metadata_tables := 0;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPIS_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPIS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_GROUPS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

/*g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_MEASURES_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;*/

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_MEASURES_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_OPTIONS_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_OPTIONS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_ANALYSIS_OPT_USER';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_CALCULATIONS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_CALCULATIONS_USER';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_CAUSE_EFFECT_RELS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_CAUSE_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_CAUSE_EFFECT_RELS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_EFFECT_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DATA_TABLES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DEFAULTS_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DEFAULTS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_GROUPS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_SHARED_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_LEVELS_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_LEVELS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
--g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_LEVELS_USER';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_LEVEL_PROPERTIES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_DIM_SETS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_GRAPHS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_MM_CONTROLS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_PERIODICITIES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_PERIODICITIES_USER';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_SHARED_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_PROPERTIES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_SERIES_COLORS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_SHELL_CMDS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_SHELL_CMDS_USER';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_SUBTITLES_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

--Removed this as the simulation tree tables are copied separately
/*g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_TREE_NODES_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_KPI_TREE_NODES_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;*/

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_FILES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

/* No need to copy calculated color data since the Shared Objective and KPIs
   are put to prototype mode, when duplicated.
g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_KPI_COLORS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_OBJECTIVE_COLORS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;*/

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_LABELS_B';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_SYSTEM_TABLE;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_SOURCE_CODE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_LABELS_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_SYSTEM_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_SOURCE_CODE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_LINES';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_SYSTEM_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_SOURCE_CODE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_SYS_USER_OPTIONS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_SYSTEM_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_SOURCE_CODE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_MASTER_KPI;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_TAB_INDICATORS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_TAB_VIEW_KPI_TL';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

--Bug #5955966. This table should not be copied while creating a shared indicator
/*g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_USER_KPIGRAPH_PLUGS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;*/

g_num_kpi_metadata_tables := g_num_kpi_metadata_tables + 1;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_name   := 'BSC_USER_KPI_ACCESS';
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_type   := C_KPI_TABLE ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).table_column := C_INDICATOR ;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).duplicate_data := bsc_utility.YES;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).mls_table := bsc_utility.NO;
g_kpi_metadata_tables(g_num_kpi_metadata_tables).copy_type := C_NO_COPY;

END Init_Kpi_Metadata_Tables_Array;
/********************************************************************************************/
PROCEDURE Copy_Record_by_Indicator_Table
( p_table_name      IN  VARCHAR2
, p_table_type      IN  VARCHAR2
, p_table_column    IN  VARCHAR2
, p_Src_kpi         IN  NUMBER
, p_Trg_kpi         IN  NUMBER
)IS

CURSOR c_column IS
SELECT column_name
FROM   all_tab_columns
WHERE  table_name = p_table_name
AND    owner = DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema,USER)
ORDER  BY column_name;

h_Trg_kpi_neg  NUMBER;

CURSOR c_userwizard IS
SELECT  ANALYSIS_GROUP_ID
       ,OPTION_ID
       ,PARENT_OPTION_ID
       ,GRANDPARENT_OPTION_ID
       ,USER_LEVEL0
       ,USER_LEVEL1
       ,USER_LEVEL1_DEFAULT
       ,USER_LEVEL2
       ,USER_LEVEL2_DEFAULT
FROM   BSC_KPI_ANALYSIS_OPTIONS_B
WHERE  INDICATOR = h_Trg_kpi_neg;

CURSOR c_Dim_level IS
SELECT  DIM_SET_ID
       ,DIM_LEVEL_INDEX
       ,USER_LEVEL0
       ,USER_LEVEL1
       ,USER_LEVEL1_DEFAULT
       ,USER_LEVEL2
       ,USER_LEVEL2_DEFAULT
       ,LEVEL_VIEW_NAME
FROM   BSC_KPI_DIM_LEVELS_B
WHERE  INDICATOR = h_Trg_kpi_neg;

CURSOR c_Periodicity IS
SELECT  PERIODICITY_ID
       ,USER_LEVEL0
       ,USER_LEVEL1
       ,USER_LEVEL1_DEFAULT
       ,USER_LEVEL2
       ,USER_LEVEL2_DEFAULT
FROM   BSC_KPI_PERIODICITIES
WHERE  INDICATOR = h_Trg_kpi_neg;

CURSOR c_Calculation IS
SELECT  CALCULATION_ID
       ,USER_LEVEL0
       ,USER_LEVEL1
       ,USER_LEVEL1_DEFAULT
       ,USER_LEVEL2
       ,USER_LEVEL2_DEFAULT
FROM   BSC_KPI_CALCULATIONS
WHERE  INDICATOR = h_Trg_kpi_neg;

CURSOR c_Dim_Level_Properties IS
SELECT  DIM_SET_ID
       ,DIM_LEVEL_ID
       ,USER_LEVEL0
       ,USER_LEVEL1
       ,USER_LEVEL1_DEFAULT
       ,USER_LEVEL2
       ,USER_LEVEL2_DEFAULT
FROM   BSC_KPI_DIM_LEVEL_PROPERTIES
WHERE  INDICATOR = h_Trg_kpi_neg;


  h_colum        VARCHAR2(100);
  h_key_name     VARCHAR2(30);
  h_condition    VARCHAR2(1000);
  h_sql          VARCHAR2(32000);
  x_arr_columns  BSC_UPDATE_UTIL.t_array_of_varchar2;
  x_num_columns  NUMBER;
  i              NUMBER;
  h_ag           NUMBER;
  h_aO           NUMBER;
  h_aOP          NUMBER;
  h_aOG          NUMBER;
  h_usl          NUMBER;
  h_count        NUMBER := 0;
BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    h_key_name := 'INDICATOR';
    IF( p_table_column = C_SOURCE_CODE )THEN
      h_key_name := 'SOURCE_CODE';
      h_condition := 'SOURCE_TYPE = 2 AND ' || h_key_name || '=' || p_Trg_kpi;
    ELSIF (p_table_column = C_INDICATOR) THEN
      h_condition := 'INDICATOR =' || p_Trg_kpi;
    ELSE
      h_condition := p_table_column ||' = ' || p_Trg_kpi;
    END IF;

    --Bug 2258410 don't override the user wizard preferences
    --Move the record to negative . to later restore the values
    h_Trg_kpi_neg := p_Trg_kpi * (-1);

    h_sql := 'DELETE ' ||  p_table_name || ' WHERE ' || h_condition;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    x_num_columns :=0;
    OPEN c_column;
    FETCH c_column INTO h_colum;
    WHILE c_column%FOUND LOOP
        x_num_columns := x_num_columns + 1;
        x_arr_columns(x_num_columns) := h_colum;
        FETCH c_column INTO h_colum;
    END LOOP;
    CLOSE c_column;

    IF x_num_columns > 0 THEN
      h_condition:= h_key_name || '=' || p_Src_kpi;
      IF  h_key_name = 'SOURCE_CODE' THEN
          h_condition:= h_condition || ' AND SOURCE_TYPE=2';
      END IF;
      h_sql:= 'INSERT INTO ( SELECT ';
      FOR i IN 1..x_num_columns LOOP
          IF i <> 1 THEN
              h_sql:= h_sql || ',';
          END IF;
              h_sql:= h_sql || x_arr_columns(i);
      END LOOP;
      h_sql:= h_sql || ' FROM  ' || p_table_name;
      h_sql:= h_sql || ' )';
      h_sql:= h_sql || ' SELECT ';
      FOR i IN 1..x_num_columns LOOP
          IF i <> 1 THEN
              h_sql:= h_sql || ',';
          END IF;
          IF UPPER(x_arr_columns(i)) = h_key_name THEN
                  h_sql:= h_sql || p_Trg_kpi || ' AS ' || x_arr_columns(i);
          ELSE
              h_sql:= h_sql || x_arr_columns(i) || ' AS ' || x_arr_columns(i);
          END IF;
      END LOOP;
      h_sql:= h_sql || ' FROM  ' || p_table_name;
      h_sql:= h_sql || ' WHERE ' || h_condition;
      BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
      --DBMS_OUTPUT.PUT_LINE(' Insertred into table :-' || p_table_name);
      --BUG 1224991
      IF UPPER(p_table_name) = 'BSC_KPI_DEFAULTS_B' Or UPPER(p_table_name) = 'BSC_KPI_DEFAULTS_TL' THEN
          h_sql:= 'UPDATE ' || p_table_name;
          h_sql:= h_sql || ' SET TAB_ID = (SELECT TAB_ID FROM BSC_TAB_INDICATORS WHERE INDICATOR =:1)';           --|| x_Trg_kpi || ')';
          h_sql:= h_sql || ' WHERE  INDICATOR = :2';                   --|| x_Trg_kpi;
          Execute Immediate h_sql USING p_Trg_kpi, p_Trg_kpi;
      END IF;

      --Bug 2258410 don't override the user wizard preferences
      IF  p_table_name = 'BSC_KPI_ANALYSIS_OPTIONS_B' THEN
          -- Take the Values from the temporal (negative) records
          FOR CD IN c_userwizard  LOOP
             UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
             SET    USER_LEVEL0           =  CD.USER_LEVEL0
                   ,USER_LEVEL1           =  CD.USER_LEVEL1
                   ,USER_LEVEL1_DEFAULT   =  CD.USER_LEVEL1_DEFAULT
                   ,USER_LEVEL2           =  CD.USER_LEVEL2
                   ,USER_LEVEL2_DEFAULT   =  CD.USER_LEVEL2_DEFAULT
             WHERE INDICATOR = p_Trg_kpi
             AND ANALYSIS_GROUP_ID =  CD.ANALYSIS_GROUP_ID
             AND OPTION_ID = CD.OPTION_ID
             AND PARENT_OPTION_ID = CD.PARENT_OPTION_ID
             AND GRANDPARENT_OPTION_ID = CD.GRANDPARENT_OPTION_ID;
          END LOOP;
      END IF;
      IF  p_table_name = 'BSC_KPI_DIM_LEVELS_B' THEN
      --DBMS_OUTPUT.PUT_LINE(' UPDATEIN BSC_KPI_DIM_LEVELS_B:-');
        FOR CD IN   c_Dim_level LOOP
           UPDATE BSC_KPI_DIM_LEVELS_B
           SET    USER_LEVEL0           =  CD.USER_LEVEL0
                 ,USER_LEVEL1           =  CD.USER_LEVEL1
                 ,USER_LEVEL1_DEFAULT   =  CD.USER_LEVEL1_DEFAULT
                 ,USER_LEVEL2           =  CD.USER_LEVEL2
                 ,USER_LEVEL2_DEFAULT   =  CD.USER_LEVEL2_DEFAULT
                 ,LEVEL_VIEW_NAME       =  CD.LEVEL_VIEW_NAME
           WHERE INDICATOR = p_Trg_kpi
           AND   DIM_SET_ID = CD.DIM_SET_ID
           AND   DIM_LEVEL_INDEX = CD.DIM_LEVEL_INDEX;
        END LOOP;
      END IF;

      IF  p_table_name = 'BSC_KPI_PERIODICITIES' THEN
--DBMS_OUTPUT.PUT_LINE(' UPDATEIN BSC_KPI_PERIODICITIES:-');
        FOR CD IN   c_Periodicity LOOP
           UPDATE BSC_KPI_PERIODICITIES
           SET    USER_LEVEL0           =  CD.USER_LEVEL0
                 ,USER_LEVEL1           =  CD.USER_LEVEL1
                 ,USER_LEVEL1_DEFAULT   =  CD.USER_LEVEL1_DEFAULT
                 ,USER_LEVEL2           =  CD.USER_LEVEL2
                 ,USER_LEVEL2_DEFAULT   =  CD.USER_LEVEL2_DEFAULT
           WHERE INDICATOR = p_Trg_kpi
           AND   PERIODICITY_ID = CD.PERIODICITY_ID;
        END LOOP;
      END IF;

      IF  p_table_name = 'BSC_KPI_CALCULATIONS' THEN
--DBMS_OUTPUT.PUT_LINE(' UPDATEIN BSC_KPI_CALCULATIONS:-');
        FOR CD IN   c_Calculation LOOP
           UPDATE BSC_KPI_CALCULATIONS
           SET    USER_LEVEL0           =  CD.USER_LEVEL0
                 ,USER_LEVEL1           =  CD.USER_LEVEL1
                 ,USER_LEVEL1_DEFAULT   =  CD.USER_LEVEL1_DEFAULT
                 ,USER_LEVEL2           =  CD.USER_LEVEL2
                 ,USER_LEVEL2_DEFAULT   =  CD.USER_LEVEL2_DEFAULT
           WHERE INDICATOR = p_Trg_kpi
           AND   CALCULATION_ID = CD.CALCULATION_ID;
        END LOOP;
      END IF;

      IF  p_table_name = 'BSC_KPI_DIM_LEVEL_PROPERTIES' THEN
--DBMS_OUTPUT.PUT_LINE(' UPDATEIN BSC_KPI_DIM_LEVEL_PROPERTIES:-');

        FOR CD IN   c_Dim_Level_Properties LOOP
           UPDATE BSC_KPI_DIM_LEVEL_PROPERTIES
           SET    USER_LEVEL0           =  CD.USER_LEVEL0
                 ,USER_LEVEL1           =  CD.USER_LEVEL1
                 ,USER_LEVEL1_DEFAULT   =  CD.USER_LEVEL1_DEFAULT
                 ,USER_LEVEL2           =  CD.USER_LEVEL2
                 ,USER_LEVEL2_DEFAULT   =  CD.USER_LEVEL2_DEFAULT
           WHERE INDICATOR = p_Trg_kpi
           AND   DIM_SET_ID = CD.DIM_SET_ID
           AND   DIM_LEVEL_ID = CD.DIM_LEVEL_ID;
        END LOOP;
      END IF;

    END IF;


EXCEPTION
    WHEN OTHERS THEN
       IF(c_userwizard%ISOPEN) THEN
        CLOSE c_userwizard;
       END IF;
       IF(c_column%ISOPEN) THEN
        CLOSE c_column;
       END IF;
       --DBMS_OUTPUT.PUT_LINE('error occured in s' || substr(SQLERRM,1,255));
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Copy_Record_by_Indicator_Table');
        RAISE;
END Copy_Record_by_Indicator_Table;




PROCEDURE Init_variables(x_indicator IN NUMBER) IS

CURSOR c_kpi IS
        SELECT INDICATOR_TYPE,CONFIG_TYPE
        FROM BSC_KPIS_B
        WHERE INDICATOR = x_indicator;

h_msg VARCHAR2(1000);

BEGIN
    --Need to initiliaze in order to Do_DDL works fine
    BSC_APPS.Init_Bsc_Apps;

    IF l_indicator = x_indicator THEN
        --h_msg := 'Loaded';
        --DBMS_OUTPUT.PUT_LINE(h_msg);
        RETURN;
    END IF;

    l_indicator := x_indicator;
   --h_msg := 'Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

    --Get indicator configuration and type
    OPEN c_kpi;
    FETCH c_kpi INTO l_ind_type,l_ind_config;
    CLOSE c_kpi;

    --Init current user
    l_current_user := 0;

    SELECT LANGUAGE_CODE INTO
    l_base_lang
    FROM FND_LANGUAGES
    WHERE INSTALLED_FLAG IN ('B');
   --h_msg := 'Testing Indicator:' || l_indicator || '/Type:' || l_ind_type || '/Config:' || l_ind_config || '/user:' || l_current_user || '/Lan:' || l_base_lang;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

EXCEPTION
    WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('Init' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Init_variables');
END Init_variables;

/*===========================================================================+
|    PROCEDURE
|      Deflt_RefreshInvalidKpis
|
|    PURPOSE
|         It refresh the information in KPI_DEFAULTS table for all
|        the invalid kpis.
|    PARAMETERS
|
|    HISTORY
|     12-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Deflt_RefreshInvalidKpis IS

CURSOR c_kpi_invalid IS
        SELECT INDICATOR FROM BSC_KPIS_B
        WHERE PROTOTYPE_FLAG<>2 AND
        INDICATOR NOT IN (SELECT INDICATOR FROM BSC_KPI_DEFAULTS_VL);

h_msg VARCHAR2(1000);
h_indicator NUMBER;

BEGIN
     --Clean invalid record in
        DELETE  BSC_KPI_DEFAULTS_B
        WHERE  (TAB_ID,INDICATOR) IN
        (SELECT TAB_ID,INDICATOR
        FROM BSC_KPI_DEFAULTS_B
        WHERE (TAB_ID,INDICATOR) NOT IN
        (SELECT TAB_ID,INDICATOR FROM BSC_TAB_INDICATORS));

    --Need to initiliaze in order to Do_DDL works fine
    BSC_APPS.Init_Bsc_Apps;
    --Get indicator configuration and type
    OPEN c_kpi_invalid;
    FETCH c_kpi_invalid INTO h_indicator;
    WHILE c_kpi_invalid%FOUND LOOP
        -- Refresh the data for this kpi
        Deflt_RefreshKpi(h_indicator);
        FETCH c_kpi_invalid INTO h_indicator;
    END LOOP;
    CLOSE c_kpi_invalid ;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('a' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_RefreshInvalidKpis');
END Deflt_RefreshInvalidKpis;
/*===========================================================================+
|    PROCEDURE
|      Deflt_RefreshKpi
|
|    PURPOSE
|         It refresh the information in KPI_DEFAULTS table
|    PARAMETERS
|
|    HISTORY
|     12-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Deflt_RefreshKpi(x_indicator IN NUMBER) IS

CURSOR c_kpi IS
        SELECT INDICATOR_TYPE,CONFIG_TYPE
        FROM BSC_KPIS_B
        WHERE INDICATOR = x_indicator;

h_msg VARCHAR2(1000);
h_exist NUMBER(1);

BEGIN

    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
   --h_msg := 'Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);
    h_exist := 1;
    --Get indicator configuration and type
    OPEN c_kpi;
    FETCH c_kpi INTO l_ind_type,l_ind_config;
    IF NOT(c_kpi%FOUND) THEN
        h_exist := 0;
    END IF;
    CLOSE c_kpi;
  --DBMS_OUTPUT.PUT_LINE('exist:' || h_exist);
    -- Execute all the steps only if the kpi exist
    IF h_exist = 1 THEN
           --h_msg := 'Testing Indicator:' || l_indicator || '/Type:' || l_ind_type || '/Config:' || l_ind_config || '/user:' || l_current_user || '/Lan:' || l_base_lang;
           --DBMS_OUTPUT.PUT_LINE(h_msg);

            --Reset Values
           Deflt_Clear(x_indicator);
           Deflt_Update_AOPTS(x_indicator);
           Deflt_Update_SN_FM_CM(x_indicator);
           Deflt_Update_DIM_SET(x_indicator);
           Deflt_Update_DIM_VALUES(x_indicator);
           Deflt_Update_DIM_NAMES(x_indicator);
           Deflt_Update_PERIOD_NAME(x_indicator);
           --COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('c' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_RefreshKpi');
END Deflt_RefreshKpi;

/*===========================================================================+
|    PROCEDURE
|      Deflt_Clear
|
|    PURPOSE
|         Delete the previous and insert a clean records
|    PARAMETERS
|
|    HISTORY
|     12-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Deflt_Clear(x_indicator IN NUMBER) IS

CURSOR c_tab_kpi IS
        SELECT TAB_ID
        FROM BSC_TAB_INDICATORS
        WHERE INDICATOR = l_indicator;

h_msg VARCHAR2(1000);
h_sql VARCHAR2(2000);
h_tab_id NUMBER;
h_tmp  VARCHAR2(255); /* Bug Fix #2691601  changine size from 80 to 255 */
BEGIN

    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
   --h_msg := 'Clear Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

    OPEN c_tab_kpi;
    FETCH c_tab_kpi INTO h_tab_id;
    IF NOT(c_tab_kpi%FOUND)  THEN
        h_tab_id := -1;
    END IF;
    CLOSE c_tab_kpi;

         --h_msg := 'Reset_BscKpiDefaults Tab:' || h_tab_id;
         --DBMS_OUTPUT.PUT_LINE(h_msg);
         --Delete Records
         h_sql :='DELETE BSC_KPI_DEFAULTS_B WHERE INDICATOR= :1';  --|| l_indicator;
         --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
         Execute Immediate h_sql USING l_indicator;
         --DBMS_OUTPUT.PUT_LINE(h_sql);

         h_sql :='DELETE BSC_KPI_DEFAULTS_TL WHERE INDICATOR= :1';-- || l_indicator;
         --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
         EXECUTE IMMEDIATE h_sql USING l_indicator;
         --DBMS_OUTPUT.PUT_LINE(h_sql);

         -- Insert Defaults BSC_KPI_DEFAULTS_B
         h_sql :='INSERT INTO BSC_KPI_DEFAULTS_B (TAB_ID,INDICATOR,' ||
                  'LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)' ||
                     'VALUES ('|| h_tab_id ||',' || l_indicator ||',SYSDATE,' || l_current_user ||',SYSDATE,' || l_current_user || ')';
         BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
         --DBMS_OUTPUT.PUT_LINE(h_sql);

         -- Insert Defaults BSC_KPI_DEFAULTS_TL
        h_sql :='INSERT INTO BSC_KPI_DEFAULTS_TL (TAB_ID,INDICATOR,LANGUAGE,SOURCE_LANG)' ||
                ' SELECT '|| h_tab_id ||' TAB_ID,' || l_indicator || ' INDICATOR,' ||
                ' LANGUAGE_CODE,' || '''' || l_base_lang || '''' ||
                ' FROM FND_LANGUAGES ' ||
                ' WHERE INSTALLED_FLAG IN (''B'',''I'')';
         BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
         --DBMS_OUTPUT.PUT_LINE(h_sql);
EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('d' || SQLERRM);
                BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_Clear');
END Deflt_Clear;

/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         To update the ANALYSIS OPTIONS COLUMNS
|    PARAMETERS
|
|    HISTORY
|     12-NOV-2001   Henry Camacho                         Created
|     09-JAN-2003   Malcoln Leung                         bug fix #2740431
+---------------------------------------------------------------------------*/
PROCEDURE Deflt_Update_AOPTS(x_indicator IN NUMBER) IS


s_node NUMBER;
h_a_grp NUMBER;
h_a_opt NUMBER;
h_a_parent_opt NUMBER;
h_a_grandparent_opt NUMBER;

CURSOR c_kpi_tree IS
        SELECT LANGUAGE,SOURCE_LANG,NAME
        FROM BSC_KPI_TREE_NODES_TL
        WHERE INDICATOR = l_indicator AND NODE_ID = s_node;

CURSOR c_color_AO_DEFAULT IS
        SELECT A0_DEFAULT,A1_DEFAULT,A2_DEFAULT
        FROM BSC_DB_COLOR_AO_DEFAULTS_V
        WHERE INDICATOR = l_indicator;

CURSOR c_kpi_analysis IS
        SELECT LANGUAGE,SOURCE_LANG,NAME
        FROM BSC_KPI_ANALYSIS_OPTIONS_TL
        WHERE INDICATOR = l_indicator AND
        ANALYSIS_GROUP_ID = h_a_grp AND
        --OPTION_ID = h_a_opt; //bug#2740431
        OPTION_ID = h_a_opt AND
        PARENT_OPTION_ID = h_a_parent_opt AND
        GRANDPARENT_OPTION_ID =h_a_grandparent_opt;

--bug#2740431, check dependency between analysis groups
CURSOR c_kpi_group_dependency IS
    SELECT ANALYSIS_GROUP_ID,DEPENDENCY_FLAG
    FROM BSC_KPI_ANALYSIS_GROUPS
    WHERE INDICATOR = l_indicator;


h_msg VARCHAR2(1000);
h_sql VARCHAR2(2000);
--
h_name BSC_KPI_ANALYSIS_OPTIONS_TL.NAME%TYPE;
h_lang VARCHAR2(4);
h_source_lang VARCHAR2(4);
h_tmp  VARCHAR2(255); /* Bug Fix #2691601  changine size from 80 to 255 */
--
h_a0 NUMBER;
h_a1 NUMBER;
h_a2 NUMBER;

a_temp NUMBER;
dep_temp NUMBER;
dep_a0 NUMBER;
dep_a1 NUMBER;
dep_a2 NUMBER;




BEGIN
    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
   --h_msg := 'Update aoptsInitialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

    -- Set To Null----------------------------
    h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ANALYSIS_OPTION0_NAME =NULL,' ||
             ' ANALYSIS_OPTION1_NAME=NULL,ANALYSIS_OPTION2_NAME=NULL '||
             ' WHERE INDICATOR = :1'; -- || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_sql);
   --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); -- bug 3111300
    Execute Immediate h_sql USING l_indicator;


    --Simulation Tree, Retrieve the default node captions----------------------------
    IF  l_ind_type = 1 AND l_ind_config = 7 THEN
            --Init s_node
            s_node := 0;
            SELECT  PROPERTY_VALUE
            INTO s_node
            FROM BSC_KPI_PROPERTIES WHERE PROPERTY_CODE='S_NODE_ID'
            AND INDICATOR=l_indicator;
            --h_msg := '    s_node:' || s_node;
                --DBMS_OUTPUT.PUT_LINE(h_msg);

            --Analysis 0----------------------------
            OPEN c_kpi_tree  ;
            FETCH c_kpi_tree INTO h_lang,h_source_lang,h_name;
            WHILE c_kpi_tree%FOUND LOOP
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                    h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                        'SOURCE_LANG = :1' ||             --'''' ||  h_source_lang  || '''' ||
                        ',ANALYSIS_OPTION0_NAME= :2' ||   --'''' || h_tmp || '''' ||
                        ' WHERE INDICATOR= :3' ||         --l_indicator ||
                        ' AND LANGUAGE= :4';              --|| '''' || h_lang || '''';
                    --DBMS_OUTPUT.PUT_LINE('A' || h_sql);
                    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); -- bug 3111300
                    Execute Immediate h_sql USING h_source_lang, h_tmp, l_indicator, h_lang;


                   --BUG 2610065 FETCH c_kpi_tree INTO h_name,h_lang,h_source_lang;
                    FETCH c_kpi_tree INTO h_lang,h_source_lang,h_name;
            END LOOP;
            CLOSE c_kpi_tree;
            -- series name is null for a tree
            h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET SERIES_NAME=NULL' ||
                     ' WHERE INDICATOR=:1'; --|| l_indicator;
           --DBMS_OUTPUT.PUT_LINE(h_sql);
           --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); -- bug 3111300
           Execute Immediate h_sql USING l_indicator;
     ELSE
        -- Get the default
        OPEN c_color_AO_DEFAULT;
        FETCH c_color_AO_DEFAULT INTO h_a0,h_a1,h_a2;
        WHILE c_color_AO_DEFAULT%FOUND LOOP
            --h_msg := ' a0:' || h_a0 || '/a1:' || h_a1 || '/a2:' || h_a2;

        OPEN c_kpi_group_dependency;
        FETCH c_kpi_group_dependency INTO a_temp, dep_temp;
        WHILE c_kpi_group_dependency%FOUND LOOP
        IF a_temp = 0 THEN
          dep_a0 := dep_temp;
        ELSIF a_temp =1 THEN
          dep_a1 := dep_temp;
        ELSIF a_temp =2 THEN
          dep_a2 := dep_temp;
        END IF;
        FETCH c_kpi_group_dependency INTO a_temp, dep_temp;
        END LOOP;
        CLOSE c_kpi_group_dependency;
        --h_msg:=' dep_a0:' || dep_a0 || '/dep_a1:' || dep_a1 || '/dep_a2:' || dep_a2;


            --DBMS_OUTPUT.PUT_LINE(h_msg);
        ---A0----------------------------
        h_a_grp := 0;
            h_a_opt := h_a0;
        h_a_parent_opt :=0;
        h_a_grandparent_opt :=0;
            OPEN c_kpi_analysis;
            FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            WHILE c_kpi_analysis%FOUND LOOP
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                        'SOURCE_LANG = :1' ||             --'''' ||  h_source_lang  || '''' ||
                        ',ANALYSIS_OPTION0_NAME= :2' ||   --'''' || h_tmp || '''' ||
                        ' WHERE INDICATOR= :3' ||         --l_indicator ||
                        ' AND LANGUAGE= :4';              --|| '''' || h_lang || '''';
                --DBMS_OUTPUT.PUT_LINE(h_sql);
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); -- bug 3111300
                Execute Immediate h_sql USING h_source_lang, h_tmp, l_indicator, h_lang;

                FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            END LOOP;
            CLOSE c_kpi_analysis;
            ---A1----------------------------
        h_a_grp := 1;
            h_a_opt := h_a1;
        -- if a1 is depends on a0, then we need to set grand/parents ID for query
        -- else, independent group, grand/parents ID is 0
        IF dep_a1 =1 THEN
           h_a_parent_opt := h_a0;
           h_a_grandparent_opt :=0;
        END IF;
            OPEN c_kpi_analysis;
            FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            WHILE c_kpi_analysis%FOUND LOOP
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                        'SOURCE_LANG = :1' ||             --'''' ||  h_source_lang  || '''' ||
                        ',ANALYSIS_OPTION0_NAME= :2' ||   --'''' || h_tmp || '''' ||
                        ' WHERE INDICATOR= :3' ||         --l_indicator ||
                        ' AND LANGUAGE= :4';              --|| '''' || h_lang || '''';
                --DBMS_OUTPUT.PUT_LINE(h_sql);
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
                Execute Immediate h_sql USING h_source_lang, h_tmp, l_indicator, h_lang;

                FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            END LOOP;
            CLOSE c_kpi_analysis;
            ---A2----------------------------
        h_a_grp := 2;
            h_a_opt := h_a2;
        IF dep_a2 =1 THEN
            h_a_parent_opt := h_a1;
            h_a_grandparent_opt := h_a0;
        END IF;
            OPEN c_kpi_analysis;
            FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            WHILE c_kpi_analysis%FOUND LOOP
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                        'SOURCE_LANG = :1' ||             --'''' ||  h_source_lang  || '''' ||
                        ',ANALYSIS_OPTION0_NAME= :2' ||   --'''' || h_tmp || '''' ||
                        ' WHERE INDICATOR= :3' ||         --l_indicator ||
                        ' AND LANGUAGE= :4';              --|| '''' || h_lang || '''';
                --DBMS_OUTPUT.PUT_LINE(h_sql);
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); -- bug 3111300
                Execute Immediate h_sql USING h_source_lang, h_tmp, l_indicator, h_lang;

                FETCH c_kpi_analysis INTO h_lang,h_source_lang,h_name;
            END LOOP;
            CLOSE c_kpi_analysis;

            FETCH c_color_AO_DEFAULT INTO h_a0,h_a1,h_a2;
        END LOOP;
        CLOSE c_color_AO_DEFAULT;
     END IF;
     --DBMS_OUTPUT.PUT_LINE('end of Deflt_Update_AOPTS');
EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('e' || SQLERRM);
               BSC_MESSAGE.Add(x_message => SQLERRM,
                       x_source => 'Deflt_Update_AOPTS');
END Deflt_Update_AOPTS;

/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         To update the SERIES_NAME, FORMAT_MASK,COLOR_METHOD,
|         MEASURE_SOURCE 06/06/02
|    PARAMETERS
|
|    HISTORY
|     12-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Deflt_Update_SN_FM_CM(x_indicator IN NUMBER) IS


h_msg VARCHAR2(1000);
h_sql VARCHAR2(2000);
s_node NUMBER;
--
h_color_method NUMBER;
h_format_mask VARCHAR2(20);
--
h_a0 NUMBER;
h_a1 NUMBER;
h_a2 NUMBER;

--
h_name BSC_KPI_ANALYSIS_MEASURES_TL.NAME%TYPE;
h_lang VARCHAR2(4);
h_source_lang VARCHAR2(4);
--08/30/02
h_tmp  VARCHAR2(255); /* Bug Fix #2691601  changine size from 80 to 255 */
--

CURSOR c_kpi_tree IS
        SELECT F.FORMAT,COLOR_METHOD
        FROM BSC_KPI_TREE_NODES_B B,
            BSC_SYS_FORMATS F
        WHERE INDICATOR = l_indicator AND NODE_ID = s_node
        AND F.FORMAT_ID = B.FORMAT_ID;
CURSOR c_color_AO_DEFAULT IS
        SELECT A0_DEFAULT,A1_DEFAULT,A2_DEFAULT
        FROM BSC_DB_COLOR_AO_DEFAULTS_V
        WHERE INDICATOR = l_indicator;

CURSOR c_analisys_measure IS
        SELECT B.SERIES_ID,F.FORMAT,DS.COLOR_METHOD
        FROM BSC_KPI_ANALYSIS_MEASURES_B B,BSC_SYS_FORMATS F,BSC_SYS_DATASETS_B DS
        WHERE INDICATOR = l_indicator
        AND B.ANALYSIS_OPTION0= h_a0
        AND B.ANALYSIS_OPTION1= h_a1
        AND B.ANALYSIS_OPTION2= h_a2
        AND F.FORMAT_ID = DS.FORMAT_ID
        AND B.DATASET_ID = DS.DATASET_ID
        AND B.DEFAULT_VALUE = 1;

h_serie_id NUMBER;
CURSOR c_analisys_measure_tl IS
        SELECT LANGUAGE,SOURCE_LANG,NAME
        FROM BSC_KPI_ANALYSIS_MEASURES_TL
        WHERE INDICATOR = l_indicator
        AND ANALYSIS_OPTION0= h_a0
        AND ANALYSIS_OPTION1= h_a1
        AND ANALYSIS_OPTION2= h_a2
        AND SERIES_ID = h_serie_id;
--06/06/02
h_kpi_measure_source VARCHAR2(10);
BEGIN
    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
    --h_msg := 'Upadte FM Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

    -- Set To Null-----------------------
    h_sql := 'UPDATE BSC_KPI_DEFAULTS_B SET ' ||
             ' FORMAT_MASK =NULL,' ||
             ' COLOR_METHOD=NULL, ' ||
             ' MEASURE_SOURCE = ''BSC''' ||
             ' WHERE INDICATOR =:1';       -- || l_indicator;
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
    Execute Immediate h_sql USING l_indicator;
    --DBMS_OUTPUT.PUT_LINE(h_sql);

    h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
             ' SERIES_NAME= NULL' ||
             ' WHERE INDICATOR =:1';                    --|| l_indicator;
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);  --bug 3111300
    Execute Immediate h_sql USING l_indicator;
    --DBMS_OUTPUT.PUT_LINE(h_sql);

    --Simulation Tree, Retrieve the default node captions----------------------------
    IF  l_ind_type = 1 AND l_ind_config = 7 THEN
            --Init s_node
            s_node := 0;
            SELECT  PROPERTY_VALUE
            INTO s_node
            FROM BSC_KPI_PROPERTIES WHERE PROPERTY_CODE='S_NODE_ID'
            AND INDICATOR = l_indicator;
            --h_msg := '    s_node:' || s_node;
                --DBMS_OUTPUT.PUT_LINE(h_msg);

            --FORMAT AND METHOD----------------------------
            OPEN c_kpi_tree  ;
            FETCH c_kpi_tree INTO h_format_mask,h_color_method;
            IF c_kpi_tree%FOUND THEN
                    h_sql := 'UPDATE BSC_KPI_DEFAULTS_B SET ' ||
                        ' FORMAT_MASK = :1' ||    --'''' ||  h_format_mask  || '''' ||
                        ',COLOR_METHOD=:2' ||     --h_color_method ||
                        ' WHERE INDICATOR=:3';    --|| l_indicator;
                    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
                    Execute Immediate h_sql USING h_format_mask, h_color_method, l_indicator;
                    --DBMS_OUTPUT.PUT_LINE(h_sql);
            END IF;
            CLOSE c_kpi_tree;
            -- series name is null for a tree
            h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET SERIES_NAME=NULL' ||
                     ' WHERE INDICATOR=:1';  -- || l_indicator;
            --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
            Execute Immediate h_sql USING l_indicator;
           --DBMS_OUTPUT.PUT_LINE(h_sql);
  ELSE
        --Get defaults
        OPEN c_color_AO_DEFAULT;
        FETCH c_color_AO_DEFAULT INTO h_a0,h_a1,h_a2;
        IF c_color_AO_DEFAULT%FOUND THEN
            --h_msg := ' a0:' || h_a0 || '/a1:' || h_a1 || '/a2:' || h_a2;
            --DBMS_OUTPUT.PUT_LINE(h_msg);
            ---Get The captions-------------------------
            OPEN c_analisys_measure;
            FETCH c_analisys_measure INTO h_serie_id,h_format_mask,h_color_method;
            IF c_analisys_measure%FOUND THEN
                 h_sql := 'UPDATE BSC_KPI_DEFAULTS_B SET ' ||
                        ' FORMAT_MASK = :1' ||    --'''' ||  h_format_mask  || '''' ||
                        ',COLOR_METHOD=:2' ||     --h_color_method ||
                        ' WHERE INDICATOR=:3';    --|| l_indicator;
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
                Execute Immediate h_sql USING h_format_mask, h_color_method, l_indicator;
                --DBMS_OUTPUT.PUT_LINE(h_sql);
            END IF;
            CLOSE c_analisys_measure;
            -- Serie Name
            OPEN c_analisys_measure_tl;
            FETCH c_analisys_measure_tl INTO h_lang,h_source_lang,h_name;
            WHILE c_analisys_measure_tl%FOUND LOOP
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                        'SOURCE_LANG = :1' ||    --'''' ||  h_source_lang  || '''' ||
                        ',SERIES_NAME=:2' ||     --'''' || h_tmp || '''' ||
                        ' WHERE INDICATOR=:3' || --l_indicator ||
                        ' AND LANGUAGE=:4';      --|| '''' || h_lang || '''';
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
                Execute Immediate h_sql USING h_source_lang, h_tmp, l_indicator, h_lang;
                --DBMS_OUTPUT.PUT_LINE(h_sql);


                FETCH c_analisys_measure_tl INTO h_lang,h_source_lang,h_name;
            END LOOP;
            CLOSE c_analisys_measure_tl;

        END IF;
        CLOSE c_color_AO_DEFAULT;

        -- MEASURE_SOURCE  06/06/02
        -- Changed for Bug#3753735
        h_kpi_measure_source :='BSC';
        SELECT NVL(SOURCE,'BSC')
        INTO h_Kpi_Measure_Source
        FROM BSC_SYS_DATASETS_B A,
        (SELECT DATASET_ID
                FROM BSC_KPI_ANALYSIS_MEASURES_B MS,
                        BSC_DB_COLOR_AO_DEFAULTS_V  DF
                WHERE ANALYSIS_OPTION0 = DF.A0_DEFAULT
                AND ANALYSIS_OPTION1 = DF.A1_DEFAULT
                AND ANALYSIS_OPTION2=  DF.A2_DEFAULT
                AND DEFAULT_VALUE = 1
                AND MS.INDICATOR = DF.INDICATOR
                AND MS.INDICATOR= x_indicator) B
        WHERE A.DATASET_ID = B.DATASET_ID;

        h_sql := 'UPDATE BSC_KPI_DEFAULTS_B SET ' ||
        ' MEASURE_SOURCE = :1' ||      --'''' ||  h_kpi_measure_source  || '''' ||
        ' WHERE INDICATOR=:2';         --|| l_indicator;

        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
        Execute Immediate h_sql USING h_kpi_measure_source, l_indicator;


  END IF;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('d' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                x_source => 'Deflt_Update_SN_FM_CM');
END Deflt_Update_SN_FM_CM;


/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         To update the DIM_SET
|    PARAMETERS
|
|    HISTORY
|     13-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Deflt_Update_DIM_SET(x_indicator IN NUMBER) IS

h_msg VARCHAR2(1000);
h_sql VARCHAR2(2000);
BEGIN
    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
    --h_msg := 'Upadte DIM SET Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);


    -- Update DIM SET
    h_sql := 'UPDATE BSC_KPI_DEFAULTS_B KD SET ' ||
                ' DIM_SET_ID = (SELECT DIM_SET_ID ' ||
                '       FROM BSC_DB_COLOR_KPI_DEFAULTS_V DB ' ||
                '       WHERE KD.INDICATOR = DB.INDICATOR (+)) ' ||
                ' WHERE KD.INDICATOR =:1';               --|| l_indicator;
     --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
     Execute Immediate h_sql USING l_indicator;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('g' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_Update_DIM_SET');
END Deflt_Update_DIM_SET;

/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         To update the Dimension values
|    PARAMETERS
|
|    HISTORY
|     13-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Deflt_Update_DIM_VALUES(x_indicator IN NUMBER) IS

h_msg VARCHAR2(1000);
h_sql VARCHAR2(32000);
BEGIN

    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
    --h_msg := 'Update DIM VALUES Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

    -- Update dimension values

    h_sql := 'UPDATE BSC_KPI_DEFAULTS_B KD SET ' ||
                ' DIM_LEVEL1_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                    ' WHERE KDL.DIM_LEVEL_INDEX = 0 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID),' ||
                ' DIM_LEVEL2_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' where KDL.DIM_LEVEL_INDEX = 1 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL3_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 2 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL4_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 3 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL5_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 4 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL6_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 5 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL7_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 6 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID), ' ||
                ' DIM_LEVEL8_VALUE = (SELECT DECODE(DEFAULT_KEY_VALUE, NULL, DECODE(DEFAULT_VALUE,''C'',-1,0), DEFAULT_KEY_VALUE) VALUE ' ||
                ' FROM BSC_KPI_DIM_LEVELS_B KDL ' ||
                ' WHERE KDL.DIM_LEVEL_INDEX = 7 ' ||
                ' AND KDL.INDICATOR = KD.INDICATOR ' ||
                ' AND KDL.DIM_SET_ID = KD.DIM_SET_ID) ' ||
                ' WHERE KD.INDICATOR =:1';               --|| l_indicator;
       --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);  --bug 3111300 ,part2
       Execute Immediate h_sql USING l_indicator;
EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('h' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_Update_DIM_VALUES');
END Deflt_Update_DIM_VALUES;
/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         To update the Dimension names
|    PARAMETERS
|
|    HISTORY
|     13-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Deflt_Update_DIM_NAMES(x_indicator IN NUMBER) IS

h_msg VARCHAR2(1000);
h_sql VARCHAR2(32000);
h_i  NUMBER(1);
h_drill  NUMBER;
--08/30/02
h_tmp  VARCHAR2(270);  /* Bug Fix #2691601  changine size from 80 to 255 */
h_tmp1  VARCHAR2(270); /* Bug Fix #2691601  changine size from 80 to 255 */
CURSOR c_kpi_dim IS
        SELECT VL.DIM_SET_ID,VL.DIM_LEVEL_INDEX, VL.LEVEL_VIEW_NAME,VL.VALUE_ORDER_BY
        FROM BSC_KPI_DIM_LEVELS_VL VL,
        BSC_KPI_DEFAULTS_B DF
        WHERE VL.INDICATOR =l_indicator
        AND VL.INDICATOR = DF.INDICATOR
        AND VL.DIM_SET_ID = DF.DIM_SET_ID
        AND VL.DEFAULT_VALUE='T'
        AND VL.TOTAL_DISP_NAME  IS NULL
        AND VL.PARENT_LEVEL_INDEX IS NULL
        AND VL.DIM_LEVEL_INDEX <8;

CURSOR c_dimnames IS
        SELECT  B.DIM_SET_ID,TL.LANGUAGE,
        DECODE(B.STATUS,2,TL.NAME,NULL) AS NAME,
        DECODE(DEFAULT_KEY_VALUE,NULL,
                DECODE(DEFAULT_VALUE,
                 'C',COMP_DISP_NAME,TOTAL_DISP_NAME),NULL) TEXT
        FROM BSC_KPI_DIM_LEVELS_B B,
             BSC_KPI_DIM_LEVELS_TL TL,
             BSC_KPI_DEFAULTS_B  DF
        WHERE B.INDICATOR = l_indicator AND
                 B.INDICATOR = TL.INDICATOR AND
                 B.INDICATOR = DF.INDICATOR AND
                 B.DIM_SET_ID =DF.DIM_SET_ID AND
                 B.DIM_SET_ID =TL.DIM_SET_ID AND
                 B.DIM_LEVEL_INDEX = TL.DIM_LEVEL_INDEX AND
                 B.DIM_LEVEL_INDEX = h_drill;
--Set text for key item
CURSOR c_key_item IS
        SELECT DIM_SET_ID,DIM_LEVEL_INDEX,LEVEL_TABLE_NAME,DEFAULT_KEY_VALUE
        FROM BSC_KPI_DIM_LEVELS_VL
        WHERE INDICATOR=l_indicator
        AND DEFAULT_KEY_VALUE>0
        AND DIM_LEVEL_INDEX<8;

l_LEVEL_TABLE_NAME  VARCHAR2(30);
l_DEFAULT_KEY_VALUE NUMBER;

h_dim_set_id NUMBER(3);
h_dim_level_index NUMBER(3);
h_level_view_name VARCHAR2(30);
h_value_order_by  NUMBER(5);
h_dim_txt VARCHAR2(100);
h_lang VARCHAR2(4);
h_name BSC_KPI_DIM_LEVELS_TL.NAME%TYPE;
h_text VARCHAR2(240);
BEGIN

    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
    --h_msg := 'Update DIM NAME Initialzie' || l_indicator;
    --Reset
    h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET DIM_LEVEL1_NAME=NULL,'||
             ' DIM_LEVEL2_NAME=NULL,DIM_LEVEL3_NAME=NULL,'||
             ' DIM_LEVEL4_NAME=NULL,DIM_LEVEL5_NAME=NULL,'||
             ' DIM_LEVEL6_NAME=NULL,DIM_LEVEL7_NAME=NULL,'||
             ' DIM_LEVEL8_NAME=NULL ' ||
             ' WHERE INDICATOR =:1';       --|| l_indicator;
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);  --bug 3111300
    Execute Immediate h_sql USING l_indicator;

    FOR  h_i IN 0..7 LOOP
        --New
        h_drill := h_i;
        --DBMS_OUTPUT.PUT_LINE('h_i:' || h_i);
        OPEN c_dimnames;
        FETCH  c_dimnames INTO h_dim_set_id,h_lang,h_name,h_text;
        WHILE c_dimnames%FOUND LOOP
                -- bug 2479254
                h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET ' ||
                         ' DIM_LEVEL' || TO_CHAR(h_i + 1) || '_NAME= ';
                        IF h_name IS NULL THEN
                h_sql := h_sql || 'NULL';
                        ELSE
--08/30/02
h_tmp := REPLACE(h_name,'''','''''');
                h_sql := h_sql || ' ''' || h_tmp || '''';
                        END IF;

                h_sql := h_sql || ',DIM_LEVEL' || TO_CHAR(h_i + 1) || '_TEXT=';
                        IF h_text IS NULL THEN
                h_sql := h_sql || 'NULL';
                        ELSE
--08/30/02
h_tmp1 := REPLACE(h_text,'''','''''');
                h_sql := h_sql || ' ''' || h_tmp1 || '''';
                        END IF;
                h_sql := h_sql ||' WHERE INDICATOR = :1' ||       --l_indicator ||
                        ' AND LANGUAGE = :2';                     --|| ' ''' || h_lang || '''';

                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
                Execute  Immediate h_sql USING l_indicator, h_lang;

                --DBMS_OUTPUT.PUT_LINE(h_sql);
                FETCH c_dimnames INTO h_dim_set_id,h_lang,h_name,h_text;
        END LOOP;
        CLOSE c_dimnames;
    END LOOP;

     --1759829 Update the DIM_LEVELS_#_TEXT when the drill doesn't have all and it should be select the first item
     OPEN c_kpi_dim;
     FETCH c_kpi_dim INTO h_dim_set_id,h_dim_level_index,h_level_view_name,h_value_order_by;
     WHILE c_kpi_dim%FOUND LOOP
        --Get The Value
        h_dim_txt := getItemfromMasterTable(h_level_view_name, h_value_order_by);
      --Assigned
        h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL SET DIM_LEVEL' || (h_dim_level_index + 1) || '_TEXT= :1' ||    --'''' || h_dim_txt  || '''' ||
                 ' WHERE  INDICATOR =:2';           --|| l_indicator;

        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
        Execute Immediate h_sql USING h_dim_txt, l_indicator;
        --DBMS_OUTPUT.PUT_LINE(h_sql);

        FETCH c_kpi_dim INTO h_dim_set_id,h_dim_level_index,h_level_view_name,h_value_order_by;
    END LOOP;
    CLOSE c_kpi_dim;
    -- bug 2424070
    OPEN c_key_item;
    FETCH c_key_item INTO h_dim_set_id,h_dim_level_index,l_LEVEL_TABLE_NAME,l_DEFAULT_KEY_VALUE;
    WHILE c_key_item%FOUND LOOP
        h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL DTL SET DIM_LEVEL' || (h_dim_level_index + 1) || '_TEXT=( ' ||
        ' SELECT NAME FROM ' || l_LEVEL_TABLE_NAME ||
        ' WHERE CODE = :1' ||                                            --l_DEFAULT_KEY_VALUE ||
        ' AND '||
        ' DTL.LANGUAGE =LANGUAGE) WHERE  INDICATOR = :2';                --|| l_indicator;

        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
        Execute Immediate h_sql USING l_DEFAULT_KEY_VALUE, l_indicator;


        FETCH  c_key_item INTO h_dim_set_id,h_dim_level_index,l_LEVEL_TABLE_NAME,l_DEFAULT_KEY_VALUE;
    END LOOP;
    CLOSE c_key_item;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('j' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_Update_DIM_NAMES');
END Deflt_Update_DIM_NAMES;
/*===========================================================================+
|    FUNCTION
|
|
|    PURPOSE
|         To get the first Item from the Master Table
|    PARAMETERS
|
|    HISTORY
|     13-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
FUNCTION getItemfromMasterTable(MASTER IN VARCHAR2, ORDER_BY IN NUMBER)
        RETURN VARCHAR2 IS

 h_sql VARCHAR2(2000);
 h_msg VARCHAR2(1000);
 h_cursor INTEGER;
 h_name VARCHAR2(255);
 h_ret INTEGER;
BEGIN
    h_name := ' ';

    IF (master = 'BSC_D_HRI_PER_USRDR_H_V') THEN
      return ' ';
      /*h_sql := 'SELECT NAME FROM ' || master ||
               ' WHERE CODE = FND_GLOBAL.EMPLOYEE_ID';*/
    ELSE
      h_sql := 'SELECT NAME FROM ' || master ||
               ' WHERE CODE <> 0 ';
    END IF;

    IF  ORDER_BY = 0 THEN
        h_sql := h_sql || ' ORDER BY NAME';
    END IF;
    IF  ORDER_BY = 1 THEN
        h_sql := h_sql || ' ORDER BY CODE';
    END IF;
    IF  ORDER_BY = 2 THEN
        h_sql := h_sql || ' ORDER BY USER_CODE';
    END IF;
    --DBMS_OUTPUT.PUT_LINE(h_sql);

     h_cursor := DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.PARSE(h_cursor, h_sql, DBMS_SQL.NATIVE);
     DBMS_SQL.DEFINE_COLUMN(h_cursor,1,h_name,100);
     h_ret := DBMS_SQL.EXECUTE(h_cursor);
    IF DBMS_SQL.FETCH_ROWS(h_cursor) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(h_cursor, 1, h_name);
    ELSE
        h_name := ' ';
    END IF;
    DBMS_SQL.CLOSE_CURSOR(h_cursor);

    RETURN  h_name;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('k' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'getItemfromMasterTable');
END getItemfromMasterTable;
/*===========================================================================+
|    PROCEDURE
|
|
|    PURPOSE
|         update period_name
|    PARAMETERS
|
|    HISTORY
|     14-NOV-2001   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Deflt_Update_PERIOD_NAME(x_indicator IN NUMBER) IS

h_msg VARCHAR2(1000);
h_sql VARCHAR2(32000);
h_year  NUMBER;
h_cur_period NUMBER;
h_periodicity NUMBER;

CURSOR c_cur_year IS
        SELECT FISCAL_YEAR FROM
        BSC_KPIS_VL
        WHERE INDICATOR= l_indicator;
CURSOR c_periodicity IS
        SELECT P.PERIODICITY_ID,P.CURRENT_PERIOD
        FROM BSC_KPIS_B B, BSC_KPI_PERIODICITIES P
        WHERE P.INDICATOR= l_indicator
        AND P.INDICATOR= B.INDICATOR AND
        P.PERIODICITY_ID = B.PERIODICITY_ID;

h_str VARCHAR2(90);
BEGIN

    --Initiliaze the inetrnal variable by kpis
    Init_variables(x_indicator);
   --h_msg := 'Upadte Period Name Initialzie' || l_indicator;
   --DBMS_OUTPUT.PUT_LINE(h_msg);

   --Current Year
    h_year := 2001;
    OPEN c_cur_year;
    FETCH c_cur_year INTO h_year;
    CLOSE c_cur_year;
    --DBMS_OUTPUT.PUT_LINE('Year:' || h_year);

   -- get periodicity and period
   h_periodicity := 5;
   h_cur_period := 1;
   OPEN c_periodicity;
   FETCH c_periodicity INTO h_periodicity,h_cur_period;
   CLOSE c_periodicity;
   --DBMS_OUTPUT.PUT_LINE('Periodicity:' || h_periodicity || '/Period:' || h_cur_period);

  --get Label
   IF h_periodicity = 1 THEN
        h_str  := h_periodicity || '-' || h_year;
        --DBMS_OUTPUT.PUT_LINE('h_str:' || h_str);

        h_sql := 'UPDATE BSC_KPI_DEFAULTS_TL KD SET '||
                 ' PERIOD_NAME  =:1' ||       --'''' || h_str || '''' ||
                 ' WHERE KD.INDICATOR =:2';   --|| l_indicator;

        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
        Execute Immediate h_sql USING h_str, l_indicator;

        --DBMS_OUTPUT.PUT_LINE(h_sql);
   ELSE
        h_str  := 'CONCAT(CONCAT(''' || h_periodicity || ''',''-''),P.NAME)';
        --DBMS_OUTPUT.PUT_LINE('h_str:' || h_str);
        h_sql := ' UPDATE BSC_KPI_DEFAULTS_TL KD SET '||
                 ' PERIOD_NAME  = ( '||
                 ' SELECT ' || h_str ||
                 ' FROM BSC_SYS_PERIODS_TL P '||
                 ' WHERE ' ||
                 ' P.YEAR= :1' ||                               --h_year ||
                 ' AND P.LANGUAGE = KD.LANGUAGE  '||
                 ' AND P.PERIODICITY_ID = :2' ||                --h_periodicity ||
                 ' AND P.PERIOD_ID = :3' || ')' ||              --h_cur_period || ')' ||
                 ' WHERE KD.INDICATOR = :4';                    --|| l_indicator;

        --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300
        Execute Immediate h_sql USING h_year , h_periodicity, h_cur_period, l_indicator;
        --DBMS_OUTPUT.PUT_LINE(h_sql);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('m' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Deflt_Update_PERIOD');
END Deflt_Update_PERIOD_NAME;
/*===========================================================================+
|    PROCEDURE
|    PURPOSE
|         Replicate the metadata records for a particular Table
|    PARAMETERS
|
|    HISTORY
|     04-FEB-2002   Henry Camacho                         Created
+---------------------------------------------------------------------------*/

PROCEDURE Duplicate_Record_by_Indicator(x_table_name IN VARCHAR2, x_Src_kpi IN NUMBER, x_Trg_kpi IN NUMBER ) IS

CURSOR c_column IS
        SELECT COLUMN_NAME FROM ALL_TAB_COLUMNS
        WHERE TABLE_NAME = x_table_name
        AND OWNER = DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema,USER)
        ORDER BY COLUMN_NAME;

h_Trg_kpi_neg NUMBER;
CURSOR c_userwizard IS
        SELECT
            TRG.ANALYSIS_GROUP_ID,
            TRG.OPTION_ID,
            TRG.PARENT_OPTION_ID,
            TRG.GRANDPARENT_OPTION_ID,
            TRG.USER_LEVEL1
        FROM BSC_KPI_ANALYSIS_OPTIONS_VL SRC,
             BSC_KPI_ANALYSIS_OPTIONS_VL TRG
        WHERE
            SRC.ANALYSIS_GROUP_ID= TRG.ANALYSIS_GROUP_ID AND
            SRC.PARENT_OPTION_ID= TRG.PARENT_OPTION_ID   AND
            SRC.GRANDPARENT_OPTION_ID= TRG.GRANDPARENT_OPTION_ID AND
            SRC.NAME = TRG.NAME AND
            SRC.USER_LEVEL1 <> 1 AND
            SRC.INDICATOR = x_Src_kpi AND
            TRG.INDICATOR = h_Trg_kpi_neg;
h_colum VARCHAR2(100);
h_key_name VARCHAR2(30);
h_condition VARCHAR2(1000);
h_sql VARCHAR2(32000);
x_arr_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
x_num_columns NUMBER;
i NUMBER;
h_ag NUMBER;
h_aO NUMBER;
h_aOP NUMBER;
h_aOG NUMBER;
h_usl NUMBER;
BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;

    h_key_name := 'INDICATOR';
    IF  SUBSTR(x_table_name, 1, 7) = 'BSC_SYS' THEN
        h_key_name := 'SOURCE_CODE';
        -- Delete the Target Records
        h_condition := 'SOURCE_TYPE=2 AND ' || h_key_name || '=' || x_Trg_kpi;
    ELSE
        h_condition := 'INDICATOR=' || x_Trg_kpi;
    END IF;

    --Bug 2258410 don't override the user wizard preferences
    --Move the record to negative . to later restore the values
    h_Trg_kpi_neg := x_Trg_kpi * -1;

    h_sql := 'DELETE ' || x_table_name || ' WHERE ' || h_condition;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    --Open COLUMNS by table cursor
    x_num_columns :=0;
    OPEN c_column;
    FETCH c_column INTO h_colum;
    WHILE c_column%FOUND LOOP
        x_num_columns := x_num_columns + 1;
        x_arr_columns(x_num_columns) := h_colum;
        FETCH c_column INTO h_colum;
    END LOOP;
    CLOSE c_column;

    IF x_num_columns > 0 THEN
        --Create the sql to insert
        h_condition:= h_key_name || '=' || x_Src_kpi;
        IF  h_key_name = 'SOURCE_CODE' THEN
            h_condition:= h_condition || ' AND SOURCE_TYPE=2';
        END IF;
        h_sql:= 'INSERT INTO ( SELECT ';
        FOR i IN 1..x_num_columns LOOP
            IF i <> 1 THEN
                h_sql:= h_sql || ',';
            END IF;
                h_sql:= h_sql || x_arr_columns(i);
        END LOOP;
        h_sql:= h_sql || ' FROM  ' || x_table_name;
        h_sql:= h_sql || ' )';
        h_sql:= h_sql || ' SELECT ';
        FOR i IN 1..x_num_columns LOOP
            IF i <> 1 THEN
                h_sql:= h_sql || ',';
            END IF;
            --Replace
            IF UPPER(x_arr_columns(i)) = h_key_name THEN
                    h_sql:= h_sql || x_Trg_kpi || ' AS ' || x_arr_columns(i);
            ELSE
                h_sql:= h_sql || x_arr_columns(i) || ' AS ' || x_arr_columns(i);
            END IF;
        END LOOP;
        h_sql:= h_sql || ' FROM  ' || x_table_name;
        h_sql:= h_sql || ' WHERE ' || h_condition;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        --BUG 1224991
        IF UPPER(x_table_name) = 'BSC_KPI_DEFAULTS_B' Or UPPER(x_table_name) = 'BSC_KPI_DEFAULTS_TL' THEN
            h_sql:= 'UPDATE ' || x_table_name;
            h_sql:= h_sql || ' SET TAB_ID = (SELECT TAB_ID FROM BSC_TAB_INDICATORS WHERE INDICATOR =:1)';           --|| x_Trg_kpi || ')';
            h_sql:= h_sql || ' WHERE  INDICATOR = :2';                   --|| x_Trg_kpi;
            --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);  --bug 3111300 ,part2
            Execute Immediate h_sql USING x_Trg_kpi, x_Trg_kpi;
        END IF;

        --Bug 2258410 don't override the user wizard preferences
        IF  x_table_name = 'BSC_KPI_ANALYSIS_OPTIONS_B' THEN
            -- Take the Values from the temporal (negative) records
            OPEN c_userwizard;
            FETCH c_userwizard INTO h_ag,h_aO,h_aOP,h_aOG,h_usl;
            WHILE c_userwizard%FOUND LOOP
                --Update the USER_LEVEL1 to this value
                h_sql := 'UPDATE  ' || x_table_name;
                h_sql :=  h_sql || ' SET USER_LEVEL1 = :1';            --|| h_usl;
                h_sql :=  h_sql || ' WHERE INDICATOR = :2';            --|| x_Trg_kpi ;
                h_sql :=  h_sql || ' AND ANALYSIS_GROUP_ID = :3';      --|| h_ag ;
                h_sql :=  h_sql || ' AND OPTION_ID = :4';              --|| h_aO ;
                h_sql :=  h_sql || ' AND PARENT_OPTION_ID = :5';       --|| h_aOP ;
                h_sql :=  h_sql || ' AND GRANDPARENT_OPTION_ID = :6';  --|| h_aOG ;
                --BSC_UPDATE_UTIL.Execute_Immediate(h_sql);  -bug 3111300 ,part2
                Execute Immediate h_sql USING h_usl, x_Trg_kpi, h_ag, h_aO, h_aOP, h_aOG;

                FETCH c_userwizard INTO h_ag,h_aO,h_aOP,h_aOG,h_usl;
            END LOOP;
            CLOSE c_userwizard;
        END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('n' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Duplicate_Record_by_Indicator');
        RAISE;
END Duplicate_Record_by_Indicator;


PROCEDURE insert_kpi_meas_data (
  p_table_name          IN VARCHAR2
, p_src_kpi             IN NUMBER
, p_trg_kpi             IN NUMBER
, p_src_kpi_measure_id  IN NUMBER
, p_trg_kpi_measure_id  IN NUMBER
)
IS
  CURSOR c_column IS
    SELECT column_name
    FROM all_tab_columns
    WHERE table_name = p_table_name
    AND owner = DECODE(USER, BSC_APPS.get_user_schema('APPS'), BSC_APPS.get_user_schema, USER)
    AND UPPER(column_name) <> 'KPI_MEASURE_ID'
    AND UPPER(column_name) <> 'INDICATOR'
    ORDER BY column_name;

  h_sql         VARCHAR2(32000);
  h_column      VARCHAR2(100);
  x_arr_columns BSC_UPDATE_UTIL.t_array_of_varchar2;
  x_num_columns NUMBER;

BEGIN
  -- Initialize BSC/APPS global variables
  BSC_APPS.Init_Bsc_Apps;

  --Open COLUMNS by table cursor
  x_num_columns := 0;
  IF c_column%ISOPEN THEN
    CLOSE c_column;
  END IF;
  OPEN c_column;
  FETCH c_column INTO h_column;
  WHILE c_column%FOUND LOOP
    x_num_columns := x_num_columns + 1;
    x_arr_columns(x_num_columns) := h_column;
    FETCH c_column INTO h_column;
  END LOOP;
  CLOSE c_column;

  IF x_num_columns > 0 THEN

    --Create the sql to insert
    h_sql:= 'INSERT INTO ' || p_table_name || ' ( indicator, kpi_measure_id, ';
    FOR i IN 1..x_num_columns LOOP
      IF i <> 1 THEN
        h_sql:= h_sql || ',';
      END IF;
      h_sql:= h_sql || x_arr_columns(i);
    END LOOP;
    h_sql:= h_sql || ' ) ';
    h_sql:= h_sql || ' SELECT ' || p_trg_kpi || ' AS indicator, ' ;
    IF p_trg_kpi_measure_id IS NULL THEN
       h_sql:= h_sql || ' NULL AS kpi_measure_id, ';
    ELSE
       h_sql:= h_sql || p_trg_kpi_measure_id || ' AS kpi_measure_id, ';
    END IF;
    FOR i IN 1..x_num_columns LOOP
      IF i <> 1 THEN
        h_sql:= h_sql || ',';
      END IF;
      h_sql:= h_sql || x_arr_columns(i) || ' AS ' || x_arr_columns(i);
    END LOOP;

    h_sql:= h_sql || ' FROM  ' || BSC_DESIGNER_PVT.Format_DbLink_String(p_table_name);
    h_sql:= h_sql || ' WHERE indicator = ' || p_src_kpi ;
    IF p_src_kpi_measure_id IS NULL THEN
      h_sql:= h_sql || ' AND kpi_measure_id IS NULL';
    ELSE
      h_sql:= h_sql || ' AND kpi_measure_id = ' || p_src_kpi_measure_id;
    END IF;
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_column%ISOPEN THEN
      CLOSE c_column;
    END IF;
    BSC_MESSAGE.Add( x_message => SQLERRM
                   , x_source  => 'BSC_DESIGNER_PVT.insert_kpi_meas_data'
                   );
    RAISE;
END insert_kpi_meas_data;



PROCEDURE Copy_Thresholds (
  p_src_kpi            IN NUMBER
, p_trg_kpi            IN NUMBER
, p_src_kpi_measure_id IN NUMBER := NULL
, p_trg_kpi_measure_id IN NUMBER := NULL
)
IS
  l_sql                 VARCHAR2(32000);
  l_src_color_range_id  NUMBER;
  l_trg_color_range_id  NUMBER;
  l_src_property_value  NUMBER;
  TYPE c_cur_type IS REF CURSOR;
  c_color_range c_cur_type;
BEGIN
  l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT color_range_id, property_value FROM bsc_color_type_props');
  l_sql := l_sql || 'WHERE indicator = :1';

  IF p_src_kpi_measure_id IS NULL THEN
    l_sql := l_sql || ' AND  kpi_measure_id IS NULL';
    OPEN c_color_range FOR l_sql USING p_src_kpi;
  ELSE
    l_sql := l_sql || ' AND  kpi_measure_id = :2';
    OPEN c_color_range FOR l_sql USING p_src_kpi, p_src_kpi_measure_id;
  END IF;
  FETCH c_color_range INTO l_src_color_range_id, l_src_property_value;
  WHILE c_color_range%FOUND LOOP

    SELECT bsc_color_range_id_s.NEXTVAL INTO l_trg_color_range_id from dual;

    IF p_trg_kpi_measure_id IS NOT NULL THEN
      UPDATE bsc_color_type_props
      SET color_range_id = l_trg_color_range_id
      WHERE indicator = p_trg_kpi
      AND   kpi_measure_id = p_trg_kpi_measure_id
      AND   NVL(property_value, -1) = DECODE(l_src_property_value, NULL, -1, l_src_property_value);
    ELSE
      UPDATE bsc_color_type_props
      SET color_range_id = l_trg_color_range_id
      WHERE indicator = p_trg_kpi
      AND   kpi_measure_id IS NULL;
    END IF;


    l_sql := 'INSERT INTO bsc_color_ranges (color_range_id, color_range_sequence, low, high, color_id)';
    l_sql := l_sql || 'SELECT '|| l_trg_color_range_id || ' AS color_range_id, color_range_sequence';
    l_sql := l_sql || BSC_DESIGNER_PVT.Format_DbLink_String(', low , high , color_id FROM bsc_color_ranges');
    l_sql := l_sql || 'WHERE color_range_id = :1';

    EXECUTE IMMEDIATE l_sql USING l_src_color_range_id;

    FETCH c_color_range INTO l_src_color_range_id, l_src_property_value;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF c_color_range%ISOPEN THEN
      CLOSE c_color_range;
    END IF;
    BSC_MESSAGE.Add( x_message => SQLERRM
                   , x_source  => 'BSC_DESIGNER_PVT.Copy_Thresholds'
                   );
    RAISE;
END Copy_Thresholds;


PROCEDURE Copy_Records_by_Obj_Kpi_Meas (
  p_src_kpi IN NUMBER
, p_trg_kpi IN NUMBER
)
IS
  l_trg_kpi_measure_id  NUMBER;
  h_sql                 VARCHAR2(32000);
  l_ao_comb_sql         VARCHAR2(32000);
  TYPE c_cur_type IS REF CURSOR;
  c_src_ao_comb c_cur_type;
  l_src_kpi_measure_id NUMBER;
  l_Count NUMBER := 0;
BEGIN
  -- Initialize BSC/APPS global variables
  BSC_APPS.Init_Bsc_Apps;
  Init_Kpi_Metadata_Tables_Array();

  -- Delete all the existing rows for the Target Objective (if any)
  FOR i IN 1 .. g_num_obj_kpi_metadata_tables LOOP
    IF (g_obj_kpi_metadata_tables(i).duplicate_data = BSC_UTILITY.YES) THEN
      h_sql := 'DELETE ' || g_obj_kpi_metadata_tables(i).table_name ||
               ' WHERE indicator = ' || p_trg_kpi;
      BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    END IF;
  END LOOP;

  l_ao_comb_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT distinct kpi_measure_id FROM bsc_kpi_analysis_measures_b');
  l_ao_comb_sql := l_ao_comb_sql || 'WHERE indicator = :1';
  OPEN c_src_ao_comb FOR l_ao_comb_sql USING p_src_kpi;
  LOOP
    FETCH c_src_ao_comb INTO l_src_kpi_measure_id;
    EXIT WHEN c_src_ao_comb%NOTFOUND;

    SELECT bsc_kpi_measure_s.NEXTVAL INTO l_trg_kpi_measure_id from dual;

    FOR i IN 1 .. g_num_obj_kpi_metadata_tables LOOP
      IF (g_obj_kpi_metadata_tables(i).duplicate_data = BSC_UTILITY.YES) THEN
        insert_kpi_meas_data (
          p_table_name => g_obj_kpi_metadata_tables(i).table_name
        , p_src_kpi => p_src_kpi
        , p_trg_kpi => p_trg_kpi
        , p_src_kpi_measure_id => l_src_kpi_measure_id
        , p_trg_kpi_measure_id => l_trg_kpi_measure_id
        );
      END IF;
    END LOOP;

    -- Copy color thresholds/ranges
    Copy_Thresholds (
       p_src_kpi => p_src_kpi
     , p_trg_kpi => p_trg_kpi
     , p_src_kpi_measure_id => l_src_kpi_measure_id
     , p_trg_kpi_measure_id => l_trg_kpi_measure_id
    );
  END LOOP;

  -- Check whether thresholds are specified at objective level.
  insert_kpi_meas_data (
    p_table_name => 'BSC_COLOR_TYPE_PROPS'
  , p_src_kpi => p_src_kpi
  , p_trg_kpi => p_trg_kpi
  , p_src_kpi_measure_id => NULL
  , p_trg_kpi_measure_id => NULL
  );
  SELECT COUNT(1) INTO  l_Count
  FROM bsc_color_type_props
  WHERE indicator = p_trg_kpi AND kpi_measure_id IS NULL;

  IF l_Count = 1 THEN
    Copy_Thresholds (
       p_src_kpi => p_src_kpi
     , p_trg_kpi => p_trg_kpi
    );
  END IF;

  -- Update Prototype flag for all KPIs for the Shared objective to re-calculate color (non-production)
  UPDATE bsc_kpi_analysis_measures_b
    SET prototype_flag = 7
    WHERE indicator = p_trg_kpi;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add( x_message => SQLERRM
                   , x_source  => 'BSC_DESIGNER_PVT.Copy_Records_by_Obj_Kpi_Meas'
                   );
    RAISE;
END Copy_Records_by_Obj_Kpi_Meas;

/*===========================================================================+
|    DESCRIPTION:
|       This fucntion made a copy of all the metadata table for kpi from one kpi to other kpi.,
|       1- Fisrt get all the KPI metadata tables
|       2- Duplicate record for all of them
|
|    NOTE : This function allways expect the INDICATOR columns as part of the table.
|         - BSC_KPIS_B is a special case
|
|    HISTORY
|     05-FEB-2002   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Duplicate_KPI_Metadata (
  x_Src_kpi IN NUMBER
, x_Trg_kpi IN NUMBER
, x_Shared_apply IN NUMBER
, x_Shared_tables IN VARCHAR2
) IS

l_kpi_metadata_tables       t_kpi_metadata_tables;
l_num_kpi_metadata_tables  NUMBER := 0;
h_table_name VARCHAR2(30);
h_condition VARCHAR2(1000);
h_sql VARCHAR2(32000);
x_arr BSC_UPDATE_UTIL.t_array_of_varchar2;
x_arrayShared_tables BSC_UPDATE_UTIL.t_array_of_varchar2;
x_num NUMBER;
i NUMBER;
h_CSF_id NUMBER;
h_Ind_group_id NUMBER;
h_Disp_Order NUMBER;
h_Source_Flag NUMBER;
h_Source_Indicator NUMBER;
h_SRC_Flag NUMBER;

h_aopt_table NUMBER;
h_Trg_kpi_neg NUMBER;

h_TRG_Flag NUMBER;
BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;
    Init_Kpi_Metadata_Tables_Array();

    SELECT NVL(CSF_ID,1)
            INTO h_CSF_id
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;
    SELECT NVL(IND_GROUP_ID,1)
            INTO h_Ind_group_id
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;
    SELECT NVL(DISP_ORDER,1)
            INTO h_Disp_Order
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;
    SELECT NVL(SHARE_FLAG,0)
            INTO h_Source_Flag
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;
    SELECT SOURCE_INDICATOR
            INTO h_Source_Indicator
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;
     --Get Prototype Flag 04/26/02
    -- Get the status
    SELECT NVL(PROTOTYPE_FLAG,1)
            INTO h_TRG_Flag
    FROM BSC_KPIS_B WHERE INDICATOR = x_Trg_kpi;

    --Fisrt Duplicate the data to BSC_KPIS_B
    Duplicate_Record_by_Indicator('BSC_KPIS_B', x_Src_kpi, x_Trg_kpi);

    --Restore the properties
    BscKpisB_Update(x_Trg_kpi, 'CSF_ID', h_CSF_id);
    BscKpisB_Update(x_Trg_kpi, 'IND_GROUP_ID', h_Ind_group_id);
    BscKpisB_Update(x_Trg_kpi, 'DISP_ORDER', h_Disp_Order);
    BscKpisB_Update(x_Trg_kpi, 'SHARE_FLAG', h_Source_Flag);
    BscKpisB_Update(x_Trg_kpi, 'SOURCE_INDICATOR', h_Source_Indicator);

    --UPDATE SHARE_FLAG
    h_condition := 'WHERE INDICATOR = :1 ';       --|| x_Trg_kpi;
    h_sql := 'UPDATE BSC_KPIS_B SET SHARE_FLAG =3 ' || h_condition;
    Execute Immediate h_sql USING x_Trg_kpi;

    h_condition := 'WHERE INDICATOR = :2 ';                  --|| x_Trg_kpi;
    h_sql := 'UPDATE BSC_KPIS_B SET SOURCE_INDICATOR =:1 '  --|| x_Src_kpi
             ||  h_condition;
    Execute Immediate h_sql USING x_Src_kpi, x_Trg_kpi;

    -- Get the status
    SELECT NVL(PROTOTYPE_FLAG,1)
            INTO h_SRC_Flag
    FROM BSC_KPIS_B WHERE INDICATOR = x_Src_kpi;

    ---04/26/02 Validate the prototype flag
    IF h_SRC_Flag  <> h_TRG_Flag THEN
         -- Critical status are propage to the child
         -- Bug #2652366 fix (added h_SRC_Flag = 7 condition)
         IF  h_SRC_Flag = 1 OR h_SRC_Flag = 3 OR h_SRC_Flag = 7 THEN
             BscKpisB_Update(x_Trg_kpi, 'PROTOTYPE_FLAG', h_SRC_Flag);
         ELSE
             BscKpisB_Update(x_Trg_kpi, 'PROTOTYPE_FLAG', h_TRG_Flag);
         END IF;
    END IF;


    x_num := 0;
    IF x_Shared_apply = 0 THEN
      FOR i IN 1..g_num_kpi_metadata_tables LOOP
        IF(g_kpi_metadata_tables(i).duplicate_data = bsc_utility.YES) THEN
          l_num_kpi_metadata_tables := l_num_kpi_metadata_tables  + 1;
          l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_name   := g_kpi_metadata_tables(i).table_name;
          l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_type   := g_kpi_metadata_tables(i).table_type;
          l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_column := g_kpi_metadata_tables(i).table_column;
        END IF;
      END LOOP;

    ELSE
        x_num := Decompose_Varchar_List(x_Shared_tables,x_arrayShared_tables ,',');
        FOR i IN 1..x_num LOOP
           FOR j IN 1..g_num_kpi_metadata_tables LOOP
             IF(g_kpi_metadata_tables(j).table_name = x_arrayShared_tables(i)) THEN
                l_num_kpi_metadata_tables := l_num_kpi_metadata_tables + 1;
                l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_name   := g_kpi_metadata_tables(j).table_name;
                l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_type   := g_kpi_metadata_tables(j).table_type;
                l_kpi_metadata_tables(l_num_kpi_metadata_tables).table_column := g_kpi_metadata_tables(j).table_column;
             END IF;
           END LOOP;
        END LOOP;
    END IF;

   h_Trg_kpi_neg := -1 * x_Trg_kpi;
   FOR i IN 1..l_num_kpi_metadata_tables LOOP
    IF(l_kpi_metadata_tables(i).table_name = 'BSC_KPI_ANALYSIS_OPTIONS_B') THEN
       UPDATE BSC_KPI_ANALYSIS_OPTIONS_B
       SET    INDICATOR = h_Trg_kpi_neg
       WHERE  INDICATOR = x_Trg_kpi;
    END IF;
    IF(l_kpi_metadata_tables(i).table_name = 'BSC_KPI_PERIODICITIES') THEN
       UPDATE BSC_KPI_PERIODICITIES
       SET    INDICATOR = h_Trg_kpi_neg
       WHERE  INDICATOR = x_Trg_kpi;
    END IF;
    IF(l_kpi_metadata_tables(i).table_name = 'BSC_KPI_CALCULATIONS') THEN
       UPDATE BSC_KPI_CALCULATIONS
       SET    INDICATOR = h_Trg_kpi_neg
       WHERE  INDICATOR = x_Trg_kpi;
    END IF;
    IF(l_kpi_metadata_tables(i).table_name = 'BSC_KPI_DIM_LEVELS_B') THEN
       UPDATE BSC_KPI_DIM_LEVELS_B
       SET    INDICATOR = h_Trg_kpi_neg
       WHERE  INDICATOR = x_Trg_kpi;
    END IF;
    IF(l_kpi_metadata_tables(i).table_name = 'BSC_KPI_DIM_LEVEL_PROPERTIES') THEN
       UPDATE BSC_KPI_DIM_LEVEL_PROPERTIES
       SET    INDICATOR = h_Trg_kpi_neg
       WHERE  INDICATOR = x_Trg_kpi;
    END IF;

   END LOOP;

   FOR i IN 1..l_num_kpi_metadata_tables  LOOP
     IF ((l_kpi_metadata_tables(i).table_name <> 'BSC_KPIS_B' )
      AND (l_kpi_metadata_tables(i).table_name <> 'BSC_KPIS_TL' )
      AND (l_kpi_metadata_tables(i).table_name <> 'BSC_KPI_CAUSE_EFFECT_RELS' )
      AND (l_kpi_metadata_tables(i).table_name <> 'BSC_KPI_DATA_TABLES') )THEN
       Copy_Record_by_Indicator_Table(l_kpi_metadata_tables(i).table_name,l_kpi_metadata_tables(i).table_type,l_kpi_metadata_tables(i).table_column, x_Src_kpi, x_Trg_kpi);
     ELSE
       IF l_kpi_metadata_tables(i).table_name = 'BSC_KPI_DATA_TABLES' THEN
         IF h_SRC_Flag <> 0  THEN  --gActionFlag.Normal =0
           Copy_Record_by_Indicator_Table(l_kpi_metadata_tables(i).table_name,l_kpi_metadata_tables(i).table_type,l_kpi_metadata_tables(i).table_column, x_Src_kpi, x_Trg_kpi);
         END IF;
       END IF;
     END IF;
  END LOOP;

  -- Copy records per KPI Measure
   Copy_Records_by_Obj_Kpi_Meas(x_src_kpi, x_trg_kpi);

   --DBMS_OUTPUT.PUT_LINE(' DELETEING BSC_KPI_ANALYSIS_OPTIONS_B:-' );
    h_sql := 'DELETE BSC_KPI_ANALYSIS_OPTIONS_B WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;
    h_sql := 'DELETE BSC_KPI_ANALYSIS_OPTIONS_TL WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;
    h_sql := 'DELETE BSC_KPI_PERIODICITIES WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;
    h_sql := 'DELETE BSC_KPI_CALCULATIONS WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;
    h_sql := 'DELETE BSC_KPI_DIM_LEVELS_B WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;
    h_sql := 'DELETE BSC_KPI_DIM_LEVEL_PROPERTIES WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
    Execute Immediate h_sql USING h_Trg_kpi_neg;

    --UPDATE SHARE_FLAG
    h_condition := 'WHERE INDICATOR = :1';   --|| x_Trg_kpi;
    h_sql := 'UPDATE BSC_KPIS_B SET SHARE_FLAG =2 ' || h_condition;
    Execute Immediate h_sql USING x_Trg_kpi;


EXCEPTION
    WHEN OTHERS THEN
            h_sql := 'DELETE BSC_KPI_ANALYSIS_OPTIONS_B WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
            h_sql := 'DELETE BSC_KPI_ANALYSIS_OPTIONS_TL WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
            h_sql := 'DELETE BSC_KPI_PERIODICITIES WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
            h_sql := 'DELETE BSC_KPI_CALCULATIONS WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
            h_sql := 'DELETE BSC_KPI_DIM_LEVELS_B WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
            h_sql := 'DELETE BSC_KPI_DIM_LEVEL_PROPERTIES WHERE INDICATOR=:1';   --|| h_Trg_kpi_neg;
            Execute Immediate h_sql USING h_Trg_kpi_neg;
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Duplicate_KPI_Metadata');
        RAISE;
END Duplicate_KPI_Metadata;



PROCEDURE BscKpisB_Update(x_Ind IN NUMBER, x_Field IN VARCHAR, x_Val IN VARCHAR) IS
/*===========================================================================+
|    DESCRIPTION:
|       Updates a record in the BSC_KPIS_B table.
|    PARAMETERS:
|       Ind         Indicator Code
|       VARIABLE    Variable name
|       Valor       Value
|    OUTPUT:
|    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
|       henry camacho 03/17/99
|       hcc.   12/01/99         Data Model 4.0
+---------------------------------------------------------------------------*/
h_sql VARCHAR2(32000);
BEGIN
    --Validation
    h_sql := 'UPDATE BSC_KPIS_B SET ' || x_Field || ' = :1 '
          || ' WHERE INDICATOR=:2';                            --|| x_Ind;
    --BSC_UPDATE_UTIL.Execute_Immediate(h_sql); --bug 3111300 ,part2
    Execute Immediate h_sql USING x_Val, x_Ind;
   --DBMS_OUTPUT.PUT_LINE('h_sql :' || h_sql );

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('p' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BscKpisB_Update');
        RAISE;
END BscKpisB_Update;

/*===========================================================================+
| FUNCTION Decompose_Varchar_List
+============================================================================*/
FUNCTION Decompose_Varchar_List(
        x_string IN VARCHAR2,
        x_array IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_separator IN VARCHAR2
        ) RETURN NUMBER IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN
    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_array(h_num_items) := RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1)));
            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_array(h_num_items) := RTRIM(LTRIM(h_sub_string));
    END IF;
    RETURN h_num_items;
END Decompose_Varchar_List;

/*===========================================================================+
| FUNCTION Commdim_DimSetDefaulisPMFbyTab
|    DESCRIPTION:
|       Validate if the Default dimension set is or is not PMF. by Tab
|
|    USAGE :
|        It is to effort a PFM rule, If there is PMF dim set as default-disable the list Button
|    PARAMETERS:
|       Tab Id     : Tab Id
|    RETURN  'T'rue or 'F'alse,
|    OUTPUT:
|    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
|       henry camacho 02/07/02
+---------------------------------------------------------------------------*/
FUNCTION Commdim_DefltDSetisPMFbyTab(
        x_Tab_id IN NUMBER
        ) RETURN VARCHAR2 IS

CURSOR c_dimset IS
        SELECT DFT.INDICATOR
        FROM  BSC_DB_COLOR_KPI_V DFT,
        (SELECT DISTINCT INDICATOR,DIM_SET_ID,NVL(LEVEL_SOURCE,'BSC') SOURCE
                FROM BSC_KPI_DIM_LEVELS_VL) DIM
        WHERE DFT.INDICATOR = DIM .INDICATOR
        AND  DFT.DIM_SET_ID = DIM .DIM_SET_ID
        AND DFT.TAB_ID = x_Tab_id
        AND DIM.SOURCE ='PMF';
    h_val VARCHAR2(1);
    h_kpi NUMBER;

BEGIN
            h_val :='F';
        OPEN c_dimset;
        FETCH c_dimset INTO h_kpi;
        IF c_dimset%FOUND THEN
            h_val :='T';
        END IF;
        CLOSE c_dimset;
       RETURN h_val;
END Commdim_DefltDSetisPMFbyTab;


-- Color By KPI: Mark KPI Prototype Flag
PROCEDURE Update_Kpi_Prototype_Flag (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER := NULL
, p_flag            IN NUMBER
) IS

  l_anal_measure_rec  BSC_ANALYSIS_OPTION_PUB.bsc_option_rec_type;

BEGIN

  IF p_objective_id IS NOT NULL AND p_kpi_measure_id IS NOT NULL THEN
    UPDATE bsc_kpi_analysis_measures_b
      SET prototype_flag = p_flag
      WHERE indicator = p_objective_id
      AND kpi_measure_id = p_kpi_measure_id;
  ELSIF p_objective_id IS NOT NULL THEN
    UPDATE bsc_kpi_analysis_measures_b
      SET prototype_flag = p_flag
      WHERE indicator = p_objective_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_DESIGNER_PVT.Update_Kpi_Prototype_Flag');
END Update_Kpi_Prototype_Flag;


/*===========================================================================+
|    PROCEDURE
|      ActionFlag_Change
|
|    PURPOSE
|         It control the incremental change flags.
|    PARAMETERS
|        x_indicator
|        x_newflag   : New action flag
|    HISTORY
|     19-APR-2002   Henry Camacho                         Created
+---------------------------------------------------------------------------*/
PROCEDURE ActionFlag_Change (
  x_indicator IN NUMBER
, x_newflag   IN NUMBER
) IS
BEGIN
  ActionFlag_Change_Cascade (
    p_indicator     => x_indicator
  , p_newflag       => x_newflag
  , p_cascade_color => TRUE
  );
EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'ActionFlag_Change_Cascade');
END ActionFlag_Change;


/* If p_cascade_color is TRUE, then the color_change flag (7) will be cascaded to KPI
 * Prototype flag too.
 * p_cascade_color will be FALSE for :
 * 1. Color rollup type change for the Objective
 * 2. Change in the WA properties for the Objective (weights, color method & color thresholds etc.)
 * 3. Change of the default KPI for the Objective
 * 4. Change in the numeric equivalent of the system level colors for WA rollup
 */
PROCEDURE ActionFlag_Change_Cascade (
  p_indicator      IN NUMBER
, p_newflag        IN NUMBER
, p_cascade_color  IN BOOLEAN
) IS

h_stage NUMBER(1);
h_structure NUMBER(1);
h_currentFlag NUMBER(1);
h_newflag NUMBER(1);
h_tmp NUMBER(1);

-- Time stamp
l_commit         varchar2(10);
my_kpi_Record    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_return_status  varchar2(100);
l_msg_data       varchar2(1000);
l_msg_count      number;
l_count_kpis     number;

BEGIN

   -- Current stage
    h_stage := 1;
    SELECT PROPERTY_VALUE
    INTO  h_stage
    FROM BSC_SYS_INIT
    WHERE PROPERTY_CODE = 'SYSTEM_STAGE';

    --DBMS_OUTPUT.PUT_LINE('1. System Stage = ' || h_stage);

    IF  h_stage = 1 THEN
        -- In stage 1 flag to prototype
        h_structure := G_ActionFlag.Prototype;
    ELSE
        --In stage 2 flag structure change
        h_structure := G_ActionFlag.GAA_Structure;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('2. h_structure := ' || h_structure);

   -- Get the current indicator status
    h_currentFlag := 1;
    SELECT PROTOTYPE_FLAG
    INTO  h_currentFlag
    FROM BSC_KPIS_B
    WHERE INDICATOR = p_indicator;

    --DBMS_OUTPUT.PUT_LINE('3. Current KPI Deflt values (' || p_indicator || ') = ' || h_currentFlag);

    --Refresh The Kpi Defaults
    Deflt_RefreshKpi(p_indicator);

    --DBMS_OUTPUT.PUT_LINE('4. Refreshed the KPI Defaults');

    -- Update the kpi timestamp
    my_kpi_Record.Bsc_Kpi_Id := p_indicator;
    l_commit := FND_API.G_FALSE;
    BSC_KPI_PUB.Update_Kpi_Time_Stamp( l_commit,my_kpi_Record,l_return_status,l_msg_count,l_msg_data);

    -- Not change in the status
    IF p_newflag = h_currentFlag THEN
        --DBMS_OUTPUT.PUT_LINE('exit p_newflag = h_currentFlag');
        RETURN;
    END IF;

    -- We can't  change this flag (Structure changes)
    IF h_currentFlag = h_structure THEN
        --DBMS_OUTPUT.PUT_LINE('exit h_currentFlag = h_structure ');
        RETURN;
    END IF;

    -- For Indicator deleted, don't change
    IF h_currentFlag = G_ActionFlag.Delete_kpi THEN
        --DBMS_OUTPUT.PUT_LINE('exit h_currentFlag = G_ActionFlag.Delete_kpi ');
        RETURN;
    END IF;
    -- Don't change in the flag values

    --DBMS_OUTPUT.PUT_LINE('5a. p_newflag = ' || p_newflag  || '   , h_currentFlag = ' || h_currentFlag);
    IF p_newflag <> h_currentFlag THEN
        -- Normal Indicator
        --DBMS_OUTPUT.PUT_LINE('5. Normal Indicator');
        h_newflag := p_newflag;
        IF p_newflag = G_ActionFlag.Normal THEN
                --DBMS_OUTPUT.PUT_LINE('6. p_newflag = G_ActionFlag.Normal ');
                RETURN;
        ELSIF p_newflag = G_ActionFlag.Delete_kpi THEN
                --DBMS_OUTPUT.PUT_LINE('7. p_newflag = G_ActionFlag.Delete_kpi ');
                RETURN;
        -- The mayor Hierarchy is GAA_STRUCTURE (3)
        ELSIF p_newflag = G_ActionFlag.GAA_Structure THEN
                --DBMS_OUTPUT.PUT_LINE('8. p_newflag = G_ActionFlag.GAA_Structure');
                h_newflag := h_structure;
        -- Prototype Hierarchy
        ELSIF  p_newflag = G_ActionFlag.Prototype THEN
                --DBMS_OUTPUT.PUT_LINE('9. p_newflag = G_ActionFlag.Prototype');
                h_newflag := h_structure;
        -- Reconfigurate  the update process
        ELSIF p_newflag = G_ActionFlag.GAA_Update THEN
            -- CHANGE FOR  Normal,GAA_color,Update_Update,Update_color
                IF h_currentFlag = G_ActionFlag.Normal OR
                           h_currentFlag = G_ActionFlag.GAA_Color OR
                           h_currentFlag = G_ActionFlag.Update_Update OR
                           h_currentFlag = G_ActionFlag.Update_color THEN
                    h_newflag := G_ActionFlag.GAA_Update;
                ELSE
                   -- G_ActionFlag.Delete,G_ActionFlag.GAA_Structure G_ActionFlag.Prototype
                   h_newflag := h_currentFlag;
                END IF;
            -- Reconfigurate  color process
        ELSIF p_newflag = G_ActionFlag.GAA_Color THEN
            -- CHANGE FOR NORMAL, UPDATE_COLOR
                IF h_currentFlag = G_ActionFlag.Normal OR h_currentFlag = G_ActionFlag.Update_color THEN
                    h_newflag := G_ActionFlag.GAA_Color;
                ELSE
                    -- Dont' change for Prototype,delte, structure
                    h_newflag := h_currentFlag;
                END IF;
        -- ELSIF  p_newflag = G_ActionFlag.Update_Update  THEN -- Re-Color process
        -- ELSIF  p_newflag = G_ActionFlag.Update_color THEN -- Color Update process
             END IF;
    END IF;

    -- Changes or not
    IF h_currentFlag <> h_newflag THEN
        -- Refresh the tab panel
    --- ======>ON HOLD    gRefresh_type.tab = True

        -- Call BscKpisB_Update(indicator, "PROTOTYPE_FLAG", h_newflag)
        UPDATE BSC_KPIS_B SET PROTOTYPE_FLAG =h_newflag
        WHERE INDICATOR = p_indicator;

        -- RECORD IN MIND_TABLES_NEW
        -- Recreate the Information for MIND_TABLES_NEW
        -- BUG 2629725 this IF was comment out NOCOPY
        IF h_newflag = h_structure THEN  -- Structure Change . to Prototype
            -- Insert at least one record in the KPI_DATA_TABLES
            SELECT  COUNT(INDICATOR)
            INTO    l_count_kpis
            FROM    BSC_KPI_DATA_TABLES
            WHERE   INDICATOR = p_indicator
            AND     TABLE_NAME IS NOT NULL;

            IF(l_count_kpis = 0) THEN
                DELETE BSC_KPI_DATA_TABLES WHERE DIM_SET_ID =0 AND INDICATOR = p_indicator;
                INSERT INTO BSC_KPI_DATA_TABLES
                                (INDICATOR,PERIODICITY_ID,DIM_SET_ID,LEVEL_COMB,TABLE_NAME,FILTER_CONDITION)
                (SELECT  INDICATOR INDICATOR,PERIODICITY_ID PERIODICITY_ID,0 DIM_SET_ID,'?' LEVEL_COMB,
                                NULL TABLE_NAME,NULL FILTER_CONDITION FROM BSC_KPI_PERIODICITIES
                        WHERE INDICATOR = p_indicator);
            END IF;

        END IF;

        -- Change from Production to Prototype
        IF h_currentFlag = G_ActionFlag.Normal AND h_newflag = h_structure THEN
             h_tmp := 1;
    --- ======>ON HOLD    msg_tmp = Get_FEM_MESSAGES("BSC_MUSERS_KPI_TO_PUBLISH")
    --- ======>ON HOLD    msg_tmp.Text = ReplaceToken(msg_tmp.Text, "INDICATOR_NAME", Get_IndicatorName(indicator))
    --- ======>ON HOLD    tmp = MsgBox(msg_tmp.Text, vbYesNo, gKpiDesignerTitle)
            --YES
            IF h_tmp = 1 THEN
                -- Call BscKpisB_Update(indicator, "PUBLISH_FLAG", 1)
                UPDATE BSC_KPIS_B SET PUBLISH_FLAG = 1
                WHERE INDICATOR = p_indicator;
            ELSE
                -- Call BscKpisB_Update(indicator, "PUBLISH_FLAG", 0)
                UPDATE BSC_KPIS_B SET PUBLISH_FLAG = 0
                WHERE INDICATOR = p_indicator;
            END IF;
        END IF;
    END IF;

    IF p_cascade_color THEN
      IF p_newflag <> G_ActionFlag.Normal THEN
      --IF p_newflag <> 0 THEN
        -- Update KPI level prototype_flag to 7
        Update_Kpi_Prototype_Flag( p_objective_id => p_indicator
                                 , p_flag         => C_COLOR_CHANGE
                                 );
      END IF;
    ELSE
      IF p_newflag <> G_ActionFlag.Normal AND p_newflag <> G_ActionFlag.Update_color THEN
      --IF p_newflag <> 0 AND p_newflag <> 7 THEN
        -- Update KPI level prototype_flag to 7
        Update_Kpi_Prototype_Flag( p_objective_id => p_indicator
                                 , p_flag         => C_COLOR_CHANGE
                                 );
      END IF;
    END IF;

   --DBMS_OUTPUT.PUT_LINE('p_indicator' || p_indicator);
   --DBMS_OUTPUT.PUT_LINE('h_stage' || h_stage);
   --DBMS_OUTPUT.PUT_LINE('h_structure' || h_structure);
   --DBMS_OUTPUT.PUT_LINE('h_currentFlag '|| h_currentFlag);
   --DBMS_OUTPUT.PUT_LINE('p_newflag '|| p_newflag);
   --DBMS_OUTPUT.PUT_LINE('h_newflag '|| h_newflag);

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('q' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'ActionFlag_Change_Cascade');
END ActionFlag_Change_Cascade;


/*********************************************************************************
                      INCREMENTAL CHANGES FOR DIMENSION OBJECTS
*********************************************************************************/


/*===========================================================================+
|    PROCEDURE
|      Dim_Object_Change
|
|    PURPOSE
|         This procedure takes care of Incremental Changes, when the Dimension
|        object is modified
|    SEUDO CODE
|         -Search for all the KPIs that are using this Dimension Object as Default
|         -Change the Action Flag
|    PARAMETERS
|        x_dim_level_id
|    HISTORY
|     15-MAY-2003   Aditya Rao                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Dim_Object_Change(x_dim_level_id IN NUMBER) IS

CURSOR c_kpi_dim_level IS

        SELECT distinct(INDICATOR)
        FROM BSC_KPI_DIM_LEVEL_PROPERTIES
        WHERE DIM_LEVEL_ID = x_dim_level_id;

    h_kpi NUMBER;

BEGIN
   -- testing
   --DBMS_OUTPUT.PUT_LINE('x_dataset_id' || x_dataset_id);

   --Search for all the Kpi that are affectec
    OPEN c_kpi_dim_level;

    FETCH c_kpi_dim_level INTO h_kpi;
    WHILE c_kpi_dim_level%FOUND LOOP
        --Testing
        --DBMS_OUTPUT.PUT_LINE('-----------------------( '|| h_kpi || ' )------------------------');

        --Change the Action Flag

        ActionFlag_Change(h_kpi, G_ActionFlag.GAA_Structure);

        FETCH c_kpi_dim_level INTO h_kpi;
    END LOOP;
    CLOSE c_kpi_dim_level;


EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('s' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Dim_Object_Change');
END Dim_Object_Change;



/*********************************************************************************
                      INCREMENTAL CHANGES FOR DIMENSIONS (GROUPS)
*********************************************************************************/


/*===========================================================================+
|    PROCEDURE
|      Dimension_Change
|
|    PURPOSE
|         This procedure takes care of Incremental Changes, when the Dimension
|        (Group) is modified for the following conditions
|
|         - Delete Dimension Group
|         - Add or Delete Dimension in a Dimension Group
|         - Edit Dimension Properties inside a Dimension Group
|
|    PSEUDO CODE
|
|         -Search for all the KPIs that are using this Dimension (Group)
|         -Change the Action Flag
|
|    PARAMETERS
|        x_dim_level_id
|    HISTORY
|     15-MAY-2003   Aditya Rao                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Dimension_Change(x_dim_group_id IN NUMBER, x_flag IN NUMBER) IS

CURSOR c_kpi_dim_group_id IS

        SELECT DISTINCT(INDICATOR)
        FROM BSC_KPI_DIM_GROUPS
        WHERE DIM_GROUP_ID = x_dim_group_id;

    h_kpi NUMBER;

BEGIN
   -- testing
   --DBMS_OUTPUT.PUT_LINE('Inside dimension_change ');

   --Search for all the Kpi that are affectec
    OPEN c_kpi_dim_group_id;

    -- Fetch the Indicators that house the Group into h_kpi
    FETCH c_kpi_dim_group_id INTO h_kpi;

    WHILE c_kpi_dim_group_id%FOUND LOOP
        --Testing
         --DBMS_OUTPUT.PUT_LINE('h_kpi' || h_kpi);

        --Change the Action Flag for the KPI
        ActionFlag_Change(h_kpi, x_flag);


        FETCH c_kpi_dim_group_id INTO h_kpi;
    END LOOP;
    CLOSE c_kpi_dim_group_id;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('s' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Dimension_Change');
END Dimension_Change;


/*===========================================================================+
|    PROCEDURE
|      Dimension_Change (takes a short_name)
|
|    PURPOSE
|         This procedure takes care of Incremental Changes, when the Dimension
|        (Group) is modified for the following conditions
|
|         - Delete Dimension Group
|         - Add or Delete Dimension in a Dimension Group
|         - Edit Dimension Properties inside a Dimension Group
|
|    PSEUDO CODE
|
|         -Search for all the KPIs that are using this Dimension (Group)
|         -Change the Action Flag
|
|    PARAMETERS
|        x_grp_short_name
|    HISTORY
|     15-MAY-2003   Aditya Rao                         Created
+---------------------------------------------------------------------------*/
PROCEDURE Dimension_Change(x_grp_short_name IN VARCHAR2, x_flag IN NUMBER) IS

CURSOR c_group_id IS

        SELECT DIM_GROUP_ID
        FROM BSC_SYS_DIM_GROUPS_VL
        WHERE SHORT_NAME = x_grp_short_name;

    h_grp_id NUMBER;

BEGIN
   -- testing
   --DBMS_OUTPUT.PUT_LINE('Inside dimension_change ');

   --Search for all the Kpi that are affectec
    OPEN c_group_id;

    -- Fetch the Indicators that house the Group into h_kpi
    FETCH c_group_id INTO h_grp_id;

        -- --DBMS_OUTPUT.PUT_LINE('h_kpi' || h_kpi);

    BSC_DESIGNER_PVT.Dimension_Change(h_grp_id, x_flag);

    CLOSE c_group_id;

EXCEPTION
    WHEN OTHERS THEN
       --DBMS_OUTPUT.PUT_LINE('s' || SQLERRM);
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'Dimension_Change');
END Dimension_Change;

/*-------------------------------------------------------
  This is wrapper for query fnd_profile.get from VB
---------------------------------------------------------*/
FUNCTION FND_PROFILE_GET (name VARCHAR2)
  RETURN VARCHAR2 is
    val VARCHAR2(32767);
  BEGIN
  -- Now call the stored program
  fnd_profile.get(name,val);
  --DBMS_OUTPUT.PUT_LINE(SubStr('val = '||val,1,255));
    RETURN nvl(val, '');
  EXCEPTION
    WHEN OTHERS THEN
    RETURN '';
END FND_PROFILE_GET;

/************************************************************************************
--	API name 	: Copy_Objective_Recors
--	Type		: Private
--	Function	:
--      This API is used to copy records of any table that satisfies the clause
--      "p_column_name = p_Source_Value'
--      It will copy all the records but replaces the p_Source_Value with
--      p_Target_value
--      Also for columns like creation_date and last_update_date the system date
--      will be inserted.
************************************************************************************/

PROCEDURE Copy_Objective_Record (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Table_Name               IN    VARCHAR2
, p_Table_column             IN    VARCHAR2
, p_Source_Value             IN    NUMBER
, p_Target_Value             IN    NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS

  CURSOR  c_column IS
  SELECT
    column_name
  FROM
    all_tab_columns
  WHERE
    table_name = p_table_name
  AND
    owner = DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema,USER)
  ORDER  BY column_name;

  l_colum        VARCHAR2(100);
  l_key_name     VARCHAR2(30);
  l_condition    VARCHAR2(1000);
  l_sql          VARCHAR2(32000);
  l_arr_columns  BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_columns  NUMBER;
  i              NUMBER;
BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;
    SAVEPOINT BscCopyObjRecordPub;

    l_key_name := p_Table_column;
    IF( p_table_column = C_SOURCE_CODE )THEN
      l_key_name := 'SOURCE_CODE';
    END IF;

    l_num_columns :=0;
    OPEN c_column;
    FETCH c_column INTO l_colum;
    WHILE c_column%FOUND LOOP
        l_num_columns := l_num_columns + 1;
        l_arr_columns(l_num_columns) := l_colum;
        FETCH c_column INTO l_colum;
    END LOOP;
    CLOSE c_column;


    IF l_num_columns > 0 THEN
        l_condition:= l_key_name || '=' || p_Source_Value;
      IF  l_key_name = 'SOURCE_CODE' THEN
          l_condition:= l_condition || ' AND SOURCE_TYPE=2';
      END IF;
      l_sql:= 'INSERT INTO ( SELECT ';
      FOR i IN 1..l_num_columns LOOP
          IF i <> 1 THEN
              l_sql:= l_sql || ',';
          END IF;
              l_sql:= l_sql || l_arr_columns(i);
      END LOOP;
      l_sql:= l_sql || ' FROM  ' || p_table_name;
      l_sql:= l_sql || ' )';
      l_sql:= l_sql || ' SELECT ';
      FOR i IN 1..l_num_columns LOOP
          IF i <> 1 THEN
              l_sql:= l_sql || ',';
          END IF;
          IF UPPER(l_arr_columns(i)) = l_key_name THEN
              l_sql:= l_sql || p_Target_Value || ' AS ' || l_arr_columns(i);
          ELSE
              l_sql:= l_sql || l_arr_columns(i) || ' AS ' || l_arr_columns(i);
          END IF;
      END LOOP;
      l_sql:= l_sql || ' FROM  ' || Format_DbLink_String(p_table_name);
      l_sql:= l_sql || ' WHERE ' || l_condition;

      EXECUTE IMMEDIATE l_sql;
    END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyObjRecordPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyObjRecordPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyObjRecordPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || p_table_name || '  ->BSC_DESIGNER_PVT.Copy_Objective_Record ';
    ELSE
      x_msg_data := SQLERRM || p_table_name || ' at BSC_DESIGNER_PVT.Copy_Objective_Record ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyObjRecordPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||p_table_name ||  ' -> BSC_DESIGNER_PVT.Copy_Objective_Record ';
    ELSE
      x_msg_data := SQLERRM || p_table_name || ' at BSC_DESIGNER_PVT.Copy_Objective_Record ';
    END IF;
END Copy_Objective_Record;

/************************************************************************************
--	API name 	: Item_Belong_To_Array_Varchar2
--	Type		: Private
--	Function	:
***********************************************************************************/
FUNCTION Item_Belong_To_Array_Varchar2(
  x_item IN VARCHAR2,
  x_array IN BSC_UPDATE_UTIL.t_array_of_varchar2,
  x_num_items IN NUMBER
  ) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. x_num_items LOOP
        IF UPPER(x_array(h_i)) = UPPER(x_item) THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Varchar2;

/************************************************************************************
--	API name 	: Process_TL_Table
--	Type		: Public
--	Function	:
--      This API checks whether the source and target language entries are in sync
--      1. Copies all the entries from source
--      2. Deletes off any entries that are not installed in target environment
--      3. Creates entries for languages that are installed only in target by
--         copying from the base language entry
************************************************************************************/

PROCEDURE Process_TL_Table (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Table_Name               IN    VARCHAR2
, p_Table_column             IN    VARCHAR2
, p_Target_Value             IN    NUMBER
, p_Target_Value_Char        IN    VARCHAR2
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS

  TYPE t_cursor IS REF CURSOR;
  c_cursor t_cursor;

  l_src_languages BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_src_languages NUMBER := 0;
  l_trg_languages BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_trg_languages NUMBER := 0;

  l_src_base_language VARCHAR2(4);
  l_owner             all_tab_columns.owner%TYPE;

  CURSOR c_columns_apps IS
  SELECT
    column_name
  FROM
    all_tab_columns
  WHERE
    table_name = p_table_name
  AND
    owner = l_owner
  ORDER BY column_name;

  l_lang_code VARCHAR2(4);
  l_installed_flag VARCHAR2(1);
  l_colum        VARCHAR2(100);
  l_key_name     VARCHAR2(30);
  l_condition    VARCHAR2(1000);
  l_sql          VARCHAR2(32000);
  l_insert       VARCHAR2(32000);
  l_select       VARCHAR2(32000);
  l_arr_columns  BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_columns  NUMBER;
  i              NUMBER;
  l_Count        NUMBER := 0;
BEGIN
    -- Initialize BSC/APPS global variables
    BSC_APPS.Init_Bsc_Apps;
    SAVEPOINT BscProcessTLTableInfo;

    IF(INSTR(p_table_name,'BSC') = 1)THEN
       SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('BSC'),USER)
       INTO l_owner FROM DUAL;
    ELSIF(INSTR(p_table_name,'BIS') = 1)THEN
       SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('BIS'),USER)
       INTO l_owner FROM DUAL;
    ELSIF(INSTR(p_table_name,'FND') = 1) THEN
       SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('FND'),USER)
       INTO l_owner FROM DUAL;
    ELSE
       SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('AK'),USER)
       INTO l_owner FROM DUAL;
    END IF;

    -- Get supported languages in source system
    l_sql := 'SELECT DISTINCT language_code, installed_flag'||
             ' FROM fnd_languages';
    IF p_DbLink_Name IS NOT NULL THEN
      l_sql := l_sql || '@'||p_DbLink_Name;
    END IF;
    l_sql := l_sql ||' WHERE installed_flag IN (:1, :2)';
    OPEN c_cursor FOR l_sql USING 'B', 'I';
    l_num_src_languages := 0;
    LOOP
        FETCH c_cursor INTO l_lang_code, l_installed_flag;
        EXIT WHEN c_cursor%NOTFOUND;

        l_num_src_languages := l_num_src_languages + 1;
        l_src_languages(l_num_src_languages) := l_lang_code;

        IF l_installed_flag = 'B' THEN
            l_src_base_language := l_lang_code;
        END IF;
    END LOOP;
    CLOSE c_cursor;

    -- Get supported languages in target system
    l_sql := 'SELECT DISTINCT language_code'||
             ' FROM fnd_languages'||
             ' WHERE installed_flag IN (:1, :2)';
    OPEN c_cursor FOR l_sql USING 'B', 'I';
    l_num_trg_languages := 0;
    LOOP
        FETCH c_cursor INTO l_lang_code;
        EXIT WHEN c_cursor%NOTFOUND;

        l_num_trg_languages := l_num_trg_languages + 1;
        l_trg_languages(l_num_trg_languages) := l_lang_code;
    END LOOP;
    CLOSE c_cursor;

    l_key_name := p_Table_column;
    IF( p_table_column = C_SOURCE_CODE )THEN
      l_key_name := 'SOURCE_CODE';
    END IF;
    IF p_Target_Value_Char IS NOT NULL THEN
      l_condition:= l_key_name || '=''' || p_Target_Value_Char || '''';
    ELSE
      l_condition:= l_key_name || '=' || p_Target_Value;
    END IF;
    IF  l_key_name = 'SOURCE_CODE' THEN
      l_condition:= l_condition || ' AND SOURCE_TYPE = 2';
    END IF;
    FOR i IN 1..l_num_trg_languages LOOP
      l_sql := 'SELECT COUNT(1) FROM ' || p_Table_Name || ' WHERE '|| l_condition ;
      l_sql := l_sql || ' AND language = :1';
      l_Count := 0;
      OPEN c_cursor FOR l_sql USING l_trg_languages(i);
      FETCH c_cursor INTO l_Count;
      CLOSE c_cursor;

      IF l_Count = 0 AND NOT Item_Belong_To_Array_Varchar2(l_trg_languages(i),
                                           l_src_languages,
                                           l_num_src_languages) THEN
        l_insert := NULL;
        l_select := NULL;
        OPEN c_columns_apps;
        FETCH c_columns_apps INTO l_colum;
        WHILE c_columns_apps%FOUND LOOP
          IF l_insert IS NOT NULL THEN
              l_insert := l_insert||', ';
              l_select := l_select||', ';
          END IF;

          l_insert := l_insert||l_colum;

          IF UPPER(l_colum) = 'LANGUAGE' THEN
              l_select := l_select||''''||l_trg_languages(i)||'''';
          ELSE
              l_select := l_select||l_colum;
          END IF;

          FETCH c_columns_apps INTO l_colum;
        END LOOP;
        CLOSE c_columns_apps;

        l_sql := 'INSERT INTO '||p_Table_Name||' ('||l_insert||')'||
                 ' SELECT '||l_select||
                 ' FROM '||p_Table_Name||
                 ' WHERE LANGUAGE = :1 AND ' || l_condition;
        EXECUTE IMMEDIATE l_sql USING l_src_base_language;
      END IF;
    END LOOP;

    FOR i IN 1..l_num_src_languages LOOP
      IF NOT Item_Belong_To_Array_Varchar2(l_src_languages(i),
                                           l_trg_languages,
                                           l_num_trg_languages) THEN
        l_sql := 'DELETE FROM '||p_Table_Name||
                 ' WHERE LANGUAGE = :1 AND ' || l_condition;
        EXECUTE IMMEDIATE l_sql USING l_src_languages(i);
      END IF;
    END LOOP;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscProcessTLTableInfo;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscProcessTLTableInfo;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscProcessTLTableInfo;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || p_table_name || '  ->BSC_DESIGNER_PVT.Process_TL_Table ';
    ELSE
      x_msg_data := SQLERRM || p_table_name || ' at BSC_DESIGNER_PVT.Process_TL_Table ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscProcessTLTableInfo;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||p_table_name ||  ' -> BSC_DESIGNER_PVT.Process_TL_Table ';
    ELSE
      x_msg_data := SQLERRM || p_table_name || ' at BSC_DESIGNER_PVT.Process_TL_Table ';
    END IF;
END Process_TL_Table;


/************************************************************************************
--	API name 	: Copy_Kpi_Metadata
--	Type		: Public
--	Function	:
--      This API is used to copy entire bsc side metadata of an indicator via dblink
--      or within the system
************************************************************************************/
PROCEDURE Copy_Kpi_Metadata (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Source_Indicator         IN    NUMBER
, x_Target_Indicator         OUT   NOCOPY  NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
) IS
  l_Copy_Type NUMBER := 5;
  l_Where_Clause VARCHAR2(2000);
  l_Record_Count NUMBER;
  l_Target_Value NUMBER;
  l_Sql VARCHAR2(2000);
  TYPE t_cursor IS REF CURSOR;
  l_cursor t_cursor;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscCopyKpiMetadataPub;

  BSC_APPS.Init_Bsc_Apps;
  Init_Kpi_Metadata_Tables_Array();

  l_sql := BSC_DESIGNER_PVT.Format_DbLink_String('SELECT DECODE(share_flag, 2, 3, 5) FROM bsc_kpis_vl');
  l_sql := l_sql || 'WHERE indicator = :1';
  OPEN l_cursor FOR l_sql USING p_Source_Indicator;
  FETCH l_cursor INTO l_Copy_Type;
  CLOSE l_cursor;

  SELECT
    BSC_INDICATOR_ID_S.NEXTVAL
  INTO
    l_Target_Value
  FROM DUAL;

  IF l_Target_Value IS NOT NULL THEN
    FOR i IN 1..g_num_kpi_metadata_tables LOOP
      IF g_kpi_metadata_tables(i).copy_type >= l_Copy_Type THEN
        Copy_Objective_Record (
           p_commit          =>  FND_API.G_FALSE
          ,p_DbLink_Name     =>  p_DbLink_Name
          ,p_Table_Name      =>  g_kpi_metadata_tables(i).table_name
          ,p_Table_column    =>  g_kpi_metadata_tables(i).table_column
          ,p_Source_Value    =>  p_Source_Indicator
          ,p_Target_Value    =>  l_Target_Value
          ,x_return_status   =>  x_return_status
          ,x_msg_count       =>  x_msg_count
          ,x_msg_data        =>  x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF g_kpi_metadata_tables(i).mls_table IS NOT NULL AND
           g_kpi_metadata_tables(i).mls_table = bsc_utility.YES THEN
           Process_TL_Table(
             p_commit                => FND_API.G_FALSE
            ,p_DbLink_Name           => p_DbLink_Name
            ,p_Table_Name            => g_kpi_metadata_tables(i).table_name
            ,p_Table_column          => g_kpi_metadata_tables(i).table_column
            ,p_Target_Value          => l_Target_Value
            ,p_Target_Value_Char     => NULL
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
           );
           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;
      END IF;
    END LOOP;

    Copy_Records_by_Obj_Kpi_Meas(
      p_src_kpi      => p_Source_Indicator
     ,p_trg_kpi      => l_Target_Value
    );
    x_Target_Indicator := l_Target_Value;
  END IF;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscCopyKpiMetadataPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscCopyKpiMetadataPub;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscCopyKpiMetadataPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_DESIGNER_PVT.Copy_Kpi_Metadata ';
    ELSE
      x_msg_data := SQLERRM || 'BSC_DESIGNER_PVT.Copy_Kpi_Metadata ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscCopyKpiMetadataPub;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_DESIGNER_PVT.Copy_Kpi_Metadata ';
    ELSE
      x_msg_data := SQLERRM || 'BSC_DESIGNER_PVT.Copy_Kpi_Metadata ';
    END IF;
END Copy_Kpi_Metadata;

/************************************************************************************
--	API name 	: Format_DbLink_String
--	Type		: Public
--	Function	:
************************************************************************************/
FUNCTION Format_DbLink_String (
  p_Sql      IN    VARCHAR2
) RETURN VARCHAR2 IS

BEGIN
  IF g_DbLink_Name IS NOT NULL THEN
    RETURN p_Sql || '@'|| g_DbLink_Name || ' ';
  END IF;
  RETURN p_Sql || ' ';
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_Sql|| ' ';
END Format_DbLink_String;


END BSC_DESIGNER_PVT;

/
