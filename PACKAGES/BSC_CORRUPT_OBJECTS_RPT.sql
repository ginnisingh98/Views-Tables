--------------------------------------------------------
--  DDL for Package BSC_CORRUPT_OBJECTS_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CORRUPT_OBJECTS_RPT" AUTHID CURRENT_USER AS
/* $Header: BSCCOBJS.pls 120.1.12000000.1 2007/08/09 09:54:35 appldev noship $ */
g_dang_measure_sql1 CONSTANT VARCHAR2(400) := ' SELECT indicator_id, short_name, actual_data_source_type, actual_data_source, dataset_id,'||
                                             ' creation_date, last_update_date,  created_by, last_updated_by FROM BIS_INDICATORS BI '||
                                             ' WHERE BI.DATASET_ID IS NULL OR NOT EXISTS (SELECT 1 FROM BSC_SYS_DATASETS_B BSD WHERE '||
                                             ' BSD.DATASET_ID = BI.DATASET_ID)';

g_dang_measure_sql2 CONSTANT VARCHAR2(200) := 'SELECT * FROM BSC_SYS_DATASETS_B BSD WHERE NOT EXISTS (SELECT 1 FROM BIS_INDICATORS BI '||
                                           ' WHERE BSD.DATASET_ID = BI.DATASET_ID)';

g_dang_measure_sql3 CONSTANT VARCHAR2(400) := 'SELECT measure_id, mc.measure_col "DB_MEASURE_COL", me2.measure_col "MEAS_MEASURE_COL" '||
                                             ' FROM bsc_db_measure_cols_vl mc, bsc_sys_measures me2 WHERE NOT EXISTS (SELECT 1 FROM '||
                                             ' bsc_sys_measures me WHERE me.measure_col = mc.measure_col) AND '||
                                             ' me2.measure_col LIKE ''%''||mc.measure_col ||''%'' ' ;

g_dang_per_sql CONSTANT VARCHAR2(400) := 'SELECT periodicity_id, source, num_of_periods, calendar_id, periodicity_type, period_type_id, '||
                                       'xtd_pattern,short_name FROM bsc_sys_periodicities_vl pe WHERE short_name IS NULL OR NOT EXISTS '||
                                       '(SELECT 1 FROM bsc_sys_dim_levels_b dl WHERE dl.short_name = pe.short_name)';
g_dang_cal_sql CONSTANT VARCHAR2(400) := 'SELECT calendar_id,edw_flag, fiscal_year, current_year, creation_date, last_update_date, created_by,'||
                                         ' last_updated_by FROM bsc_sys_calendars_vl pe WHERE short_name IS NULL OR NOT EXISTS (SELECT 1 '||
                                         ' FROM bsc_sys_dim_groups_vl dim WHERE dim.short_name = pe.short_name)';
g_dang_rpt_sql CONSTANT VARCHAR2(200) := 'SELECT * FROM bsc_kpis_b WHERE short_name IS NOT NULL AND NOT EXISTS (SELECT 1 '||
                                         ' FROM ak_regions WHERE short_name = region_code)';
g_dang_tab_sql CONSTANT VARCHAR2(400) := 'SELECT tab_id, short_name, name, tab_index, parent_tab_id, creation_date, last_update_date,'||
                                         'created_by, last_updated_by FROM bsc_tabs_vl WHERE short_name IS NOT NULL AND NOT EXISTS '||
                                         ' (SELECT 1 FROM ak_regions WHERE short_name = region_code)';


PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runtest(inputs IN JTF_DIAG_INPUTTBL,
report OUT NOCOPY JTF_DIAG_REPORT,
reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/
