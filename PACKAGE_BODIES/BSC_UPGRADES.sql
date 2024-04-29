--------------------------------------------------------
--  DDL for Package Body BSC_UPGRADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPGRADES" AS
  /* $Header: BSCUPGRB.pls 120.6.12000000.2 2007/06/19 13:33:16 ashankar ship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCPBMSB.pls
---
---  DESCRIPTION
---     Package body File for Upgrade scripts
---
---  NOTES
---
---  HISTORY
---
---  26-Jun-2003 mdamle         Created
---  22-JUL-2003 Adeulgao   modified for bug fix#3047536
---  24-JUL-2003 mdamle         Call api to create default calc. here
---  03-SEP-2003 mdamle         Do not create db measure col here for PMF
---             Do not set measure_col here for PMF
---  13-SEP-2003 mdamle         Bug#3134652 - Fix for indicator record not
---             being created when migrating from another system.
---  22-SEP-2003 mdamle         Bug#3154208 - > 1 dataset pointing to same measure
---  25-SEP-2003 mdamle         Bug#3160325 - Sync up measures for all installed languages
---  29-SEP-2003 adrao          Bug#3160325 - Sync up measures with source_lang
---  29-SEP-2003 mdamle         Bug#3168129 - Change l_pmf_disp_name to bsc_sys_datasets_tl.name%type
---  03-OCT-2003 mdamle         Bug#3172902 - Measure ID not being set before synch
--   07-OCT-2003 mdamle         Bug#3170184 - For BSC type measure, always use short name in PMF display name
--   04-DEC-2003 kyadamak       bug#3284202 - while sync'ing from BSC->PMF generate new short_name
--   22-DEC-2003 meastmon:      bug#3333957 - Pass application id 271(Balanced scorecard application Id)
--                                            when creating a BSC dimension level in BIS repository
--   02-MAR-2004 ankgoel        bug#3464470 - Forward port fix of bug#3450505
--   31-May-2004 Pradeep        Pefromance Bug #3634325 fix
--   09-Sep-2004 ankgoel        Bug#3874911 - Rollback & Validation issues in measures sync-up
--   20-Sep-2004 ankgoel        Bug#3759819 - Handled measures sync-up for Custom KPIs
--                              Code modularization and message logging
--   29-Sep-2004 ankgoel        Bug#3891748 - Synced-up WHO colums except DATES for measures, dimensions
--                              and dimension objects
--   05-Oct-2004 ankgoel        Bug#3933075 - Moved Upgrade_Role_To_Tabs to BSCUPGNB.pls
--                              BSCUPGRB.pls will now be used for API calls from bscupmdd.sql only
--   21-DEC-04 vtulasi          Modified for bug#4045278 - Addtion of LUD
--   21-FEB-05 ankagarw         changed dataset name and description column length for enh# 3862703
--   12-Apr-05 adrao            Added APIs Refresh_Measure_Col_Names and Gen_Existing_Measure_Cols
--                              For Enhancement#4239216
--   19-july-05 kyadamak        Modified for the bug#4477575
--   26-Sep-05  ankgoel         Bug#4625611 - sync-up dim-dimobject rel from BSC to PMF side
---  10-JAN-06 akoduri          Enh#4739401 Hide Dimensions and Dimension Objects
---  24-Jan-06 akoduri          Bug#4958055  Dgrp dimension not getting deleted
---                             while disassociating from objective
---  31-MAR-06 akoduri          Bug #5048186 Dropping of BSC Views for obsoleted BIS dimension
---                             objets (Only those for which the underlying view will be dropped)
---  18-JUN-07 ashankar         Bug#6129599 Added the API synch_measures_cds_to_pmf
---===========================================================================

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_UPGRADES';


FUNCTION Validate_And_Get_Short_Name
(
 p_Short_Name     IN   BIS_INDICATORS.short_name%TYPE
) RETURN VARCHAR2;
/*******************************************************************************
    Refresh_Measure_Col_Names API ensures that all the PMF measures that were
    generated using SHORT_NAME for BSC_SYS_MEASURES.MEASURE_COL is modified to
    more intelligible names which is ideally derived from the name of the measure.

    These columns that will be generated will ensure that the MEASURE_COL is derived
    from NAME of the measure uniquely. This API as standalone does not have any
    impact on the Existing source measure part of the world. This API should be used
    in combination with Gen_Existing_Measure_Cols to ensure corresponding
    measure columns are generated for the PMF Measure (Existing SourcE)

    Added as part of Enhancement Bug#4239216
********************************************************************************/


PROCEDURE Refresh_Measure_Col_Names;


/*******************************************************************************
    This PL/SQL API has been designer to generate new DB Column entries in
    BSC_DB_MEASURE_COLS_TL table, which will be used by Generate Database to
    directly run on exisitng type of measures.

    This API should not be called without calling Refresh_Measure_Col_Names,
    Though this API can run independently, it will generate column that are
    available directly in BSC_SYS_MEASURES.MEASURE_COL (which ideally may not
    be intelligible as a TABLE COLUMN). Hence it is *recommened* that
    the API Refresh_Measure_Col_Names is run before this API is run.

    Added as part of Enhancement Bug#4239216
********************************************************************************/


PROCEDURE Gen_Existing_Measure_Cols;

PROCEDURE sync_dim_object_mappings
( p_dim_short_name  IN  VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-- ankgoel: bug#3874911
-- Validate and re-generate dataset names untill unique
-- This validation is uses the same logic while creating/updating measures
-- through UI/ldt. For this, BSC_BIS_MEASURE_PUB.get_Measure_Name is re-used.
FUNCTION get_dataset_name(
  p_dataset_name  IN VARCHAR2
)
RETURN VARCHAR2
IS
l_dataset_name  bsc_sys_datasets_tl.name%TYPE;
l_return_name   bsc_sys_datasets_tl.name%TYPE;
l_flag          VARCHAR2(10);
BEGIN
  l_flag := 'F';
  l_dataset_name := p_dataset_name;
  l_return_name := p_dataset_name;

  WHILE (l_flag = 'F') LOOP
    BEGIN
      -- Validate Measure Name
      BSC_BIS_MEASURE_PUB.get_Measure_Name( p_dataset_id     => NULL
                                          , p_ui_flag        => 'N'
                          , p_dataset_source => 'PMF'
                          , p_dataset_name   => l_dataset_name
                          , x_measure_name   => l_return_name);
      l_flag := 'T';
    EXCEPTION
      -- Exception is thrown when the measure name fails during validation
      -- WHEN FND_API.G_EXC_ERROR THEN
      WHEN OTHERS THEN
        l_dataset_name := BSC_UTILITY.get_Next_DispName(l_dataset_name);
    END;
  END LOOP;

  RETURN l_return_name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_dataset_name;
END get_dataset_name;
--

PROCEDURE delete_bsc_measures_from_pmf
IS
  -- part of bug#3436393: the previous query was not getting all
  -- the bsc datasets from pmf repository. It was joining with bsc_sys_measures
  -- but in case of datasets that are formulas between measures
  -- they were not fetched. We need to join is with bsc_sys_datasets_b
  CURSOR c_bsc_measures_in_pmf IS
    SELECT indicator_id, measure_id1, i.short_name
    FROM   bis_indicators i, bsc_sys_datasets_b d
    WHERE  d.dataset_id = i.dataset_id
    AND    d.source = 'BSC';

  CURSOR c_s2e_kpis(p_indicator_id NUMBER) IS
    SELECT count(1)
    FROM   bis_indicators BIS_IND
          ,bsc_sys_datasets_b BSC_DTS
          ,bsc_sys_measures BSC_MEAS
    WHERE  BIS_IND.dataset_id = BSC_DTS.dataset_id
    AND    BSC_DTS.measure_id1 = BSC_MEAS.measure_id
    AND    BIS_IND.indicator_id = p_indicator_id;
--    AND   BIS_IND.short_name = BSC_MEAS.short_name --kyadamak commented out as this resulted in bad datacorruption 'we should never join by meausre short name'

  TYPE t_array_of_number IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  l_num_ids         NUMBER;
  l_arr_ids         t_array_of_number;
  l_arr_short_name  t_array_of_varchar2;
  l_max_ds_id_bis   NUMBER;
  l_max_ds_id_bsc   NUMBER;
  l_indicator_id    NUMBER;
  l_count           NUMBER;
  l_bis_measure_rec bis_measure_pub.measure_rec_type;
  l_return_status   VARCHAR2(1);
  l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_err             VARCHAR2(2000);
BEGIN
    l_num_ids := 0;

    SELECT nvl(max(dataset_id),0) INTO l_max_ds_id_bis
      FROM bis_indicators;

    SELECT nvl(max(dataset_id),0) INTO l_max_ds_id_bsc
      FROM bsc_sys_datasets_b;

    IF (l_max_ds_id_bis <> l_max_ds_id_bsc) THEN        -- dataset ids are out of synch
        -- remove BSC measures from pmf repository
    -- Exclude non-corrupt s2e measures.
        FOR c_meas IN c_bsc_measures_in_pmf LOOP
          IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_KPI_EndToEnd_Measure(c_meas.short_name) = FND_API.G_TRUE) THEN  -- custom KPI
        OPEN c_s2e_kpis(c_meas.indicator_id);
            FETCH c_s2e_kpis INTO l_count;
        IF (l_count = 0) THEN  -- custom KPI is corrupt, delete it from PMF side (should not happen ideally)
              l_num_ids := l_num_ids + 1;
              l_arr_ids(l_num_ids) := c_meas.indicator_id;
          l_arr_short_name(l_num_ids) := c_meas.short_name;
        END IF;
        CLOSE c_s2e_kpis;
      ELSE
        l_num_ids := l_num_ids + 1;
            l_arr_ids(l_num_ids) := c_meas.indicator_id;
        l_arr_short_name(l_num_ids) := c_meas.short_name;
      END IF;
        END LOOP;

        FOR i IN 1..l_num_ids LOOP
      BEGIN
            l_bis_measure_rec.measure_id := l_arr_ids(i);

            BIS_MEASURE_PUB.Delete_Measure(
                p_api_version => 1.0
               ,p_commit => FND_API.G_FALSE
               ,p_Measure_Rec => l_bis_measure_rec
               ,x_return_status => l_return_status
               ,x_error_Tbl => l_error_tbl);
            IF ((l_return_status IS NOT NULL) AND (l_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            BEGIN
              BSC_MESSAGE.Add(x_message => 'Deleted measure: ' || l_arr_short_name(i) || ' : Successfully',
                x_source => 'BSCUPGRB.delete_bsc_measures_from_pmf',
                x_mode => 'I');
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

      EXCEPTION
        WHEN OTHERS THEN
          l_err := l_arr_short_name(i) ;
          IF (l_error_tbl.COUNT > 0) THEN
            l_err := l_err || ' : ' || l_error_tbl(1).Error_Description;
          END IF;
          BSC_MESSAGE.Add(x_message => 'Could not delete measure: ' || l_err,
                x_source => 'BSCUPGRB.delete_bsc_measures_from_pmf',
                x_mode => 'I');
      END;
    END LOOP;

        COMMIT;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF(c_s2e_kpis%ISOPEN) THEN
      CLOSE c_s2e_kpis;
    END IF;
    l_err := SQLERRM;
    BSC_MESSAGE.Add(x_message => 'Failed: ' || l_err,
                x_source => 'BSCUPGRB.delete_bsc_measures_from_pmf',
                x_mode => 'I');
END delete_bsc_measures_from_pmf;
--

PROCEDURE sync_measures_pmf_to_bsc
IS
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_Dataset_id     NUMBER;
  l_Dataset_Rec    BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

  TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;

  l_arr_short_name t_array_of_varchar2;
  l_num            NUMBER;
  i                NUMBER;
  l_err            VARCHAR2(2000);

  l_Measure_Col       BSC_SYS_MEASURES.MEASURE_COL%TYPE;
  l_Measure_Group_Id  BSC_DB_MEASURE_COLS_TL.MEASURE_GROUP_ID%TYPE;
  l_Projection_Id     BSC_DB_MEASURE_COLS_TL.PROJECTION_ID%TYPE;
  l_Measure_Type      BSC_DB_MEASURE_COLS_TL.MEASURE_TYPE%TYPE;
  CURSOR bsc_indicators_cursor IS
    SELECT  d.dataset_id, i.name as measure_name, i.description, i.short_name as measure_short_name, i.indicator_id measure_id, i.created_by created_by, i.last_updated_by last_updated_by, i.last_update_login last_update_login
    FROM bsc_sys_datasets_vl d, bis_indicators_vl i, bsc_sys_measures m
    WHERE i.short_name = m.short_name (+)
    and (d.source is null or d.source = 'PMF')
    and m.measure_id = d.measure_id1 (+)
    and (i.dataset_id is null or d.dataset_id <> i.dataset_id);
BEGIN
    l_num := 0;
    -- setup defaults, added for Enhancement#4239216
    l_Measure_Group_Id  := -1; -- default group
    l_Projection_Id     := 0; -- Indicates no projection
    l_Measure_Type      := 1; -- activity type by default
    -- ankgoel: bug#3874911
    -- Ideally, in no case should sync-up fail. Still use individual rollback for each measure getting synced-up.
    FOR icr IN bsc_indicators_cursor LOOP
      BEGIN
        SAVEPOINT SP_SYNC_MEASURE;
        IF (icr.dataset_id is null) then
          l_Dataset_Rec.Bsc_Source := BSC_BIS_MEASURE_PUB.c_PMF;
          --l_Dataset_Rec.Bsc_Dataset_Name := icr.measure_name;
      l_Dataset_Rec.Bsc_Dataset_Name := get_dataset_name(icr.measure_name);
          l_Dataset_Rec.Bsc_Dataset_Help := icr.description;
          l_Dataset_Rec.Bsc_Measure_Short_Name := icr.measure_short_name;
          l_Dataset_Rec.Bsc_Measure_Long_Name := icr.measure_name;
          l_Dataset_Rec.Bsc_Measure_Operation := BSC_BIS_MEASURE_PUB.c_SUM;
          -- ankgoel: bug#3891748 - Creation_Date and Last_Update_Date will not be synced-up
          -- They might be useful in debugging
      l_Dataset_Rec.Bsc_Measure_Created_By := icr.created_by;
          l_Dataset_Rec.Bsc_Measure_Last_Update_By := icr.last_updated_by;
      l_Dataset_Rec.Bsc_Measure_Last_Update_Login := icr.last_update_login;
      l_Dataset_Rec.Bsc_Dataset_Created_By := icr.created_by;
      l_Dataset_Rec.Bsc_Dataset_Last_Update_By := icr.last_updated_by;
      l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := icr.last_update_login;

      -- added for Enhancement#4239216
      l_Measure_Col := BSC_BIS_MEASURE_PUB.Get_Measure_Col(
                             l_Dataset_Rec.Bsc_Dataset_Name,
                             l_Dataset_Rec.Bsc_Source,
                             NULL,
                             l_Dataset_Rec.Bsc_Measure_Short_Name
                        );
      l_Dataset_Rec.Bsc_Measure_Col := l_Measure_Col;
      BSC_DATASETS_PUB.Create_Measures(
                 p_commit => FND_API.G_FALSE
                ,p_Dataset_Rec => l_Dataset_Rec
                ,x_Dataset_Id => l_Dataset_Id
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data);
          IF ((l_return_status IS NOT NULL) AND (l_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      l_Dataset_Rec.Bsc_Dataset_Id := l_Dataset_Id;
          BSC_DATASETS_PUB.Create_Dataset_Calc(FND_API.G_FALSE
                        ,l_Dataset_Rec
                        ,l_return_status
                        ,l_msg_count
                        ,l_msg_data);
          IF ((l_return_status IS NOT NULL) AND (l_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      -- added for Enhancement#4239216
      BEGIN
           IF (l_Measure_Col IS NOT NULL) THEN
               BSC_DB_MEASURE_COLS_PKG.INSERT_ROW (
                  x_Measure_Col      => l_Measure_Col
                , x_Measure_Group_Id => l_Measure_Group_Id
                , x_Projection_Id    => l_Projection_Id
                , x_Measure_Type     => l_Measure_Type
                , x_Help             => l_Measure_Col
               );
           END IF;
      EXCEPTION
           WHEN OTHERS THEN
               BSC_MESSAGE.Add (
                     x_message => SQLERRM || '  -  ERROR ADDING COL : ' || l_Measure_Col
                   , x_source  => 'BSC_DB_MEASURE_COLS_PKG.INSERT_ROW'
                   , x_mode    => 'I'
               );
      END;
      UPDATE bis_indicators
            SET dataset_id = l_Dataset_id
            WHERE indicator_id = icr.measure_id;

          -- mdamle 09/25/2003 - Sync up measures for all installed languages
          lang_synch_PMF_To_BSC_measure(
                      p_indicator_id    => icr.measure_id
                    , p_Dataset_Rec     => l_dataset_rec
                    , x_return_status   => l_return_status
                    , x_msg_count       => l_msg_count
                    , x_msg_data        => l_msg_data);

        ELSE
          UPDATE bis_indicators
            SET dataset_id = icr.dataset_id
            WHERE indicator_id = icr.measure_id;
        END IF;

    BEGIN
          BSC_MESSAGE.Add(x_message => 'Synchronized measure: ' || icr.measure_short_name || ' : ' || 'Successfully',
                x_source => 'BSCUPGRB.sync_measures_pmf_to_bsc',
                x_mode => 'I');
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

    COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
      l_num := l_num + 1;
      IF (l_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get (
             p_encoded   =>  FND_API.G_FALSE
               , p_count     =>  l_msg_count
               , p_data      =>  l_msg_data );
          END IF;
          l_arr_short_name(l_num) := icr.measure_short_name || ' : ' || l_msg_data;
      ROLLBACK TO SP_SYNC_MEASURE;
      END;
    END LOOP;

    BEGIN
      FOR i IN 1..l_num LOOP
        BSC_MESSAGE.Add(x_message => 'Failed measure: ' || l_arr_short_name(i),
                x_source => 'BSCUPGRB.sync_measures_pmf_to_bsc',
                x_mode => 'I');
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
    NULL;
    END;

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLERRM;
    BSC_MESSAGE.Add(x_message => 'Failed: ' || l_err,
                x_source => 'BSCUPGRB.sync_measures_pmf_to_bsc',
                x_mode => 'I');
END sync_measures_pmf_to_bsc;
--

PROCEDURE sync_measures_bsc_to_pmf_51
IS
  l_return_status         varchar2(1);
  l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec           BIS_MEASURE_PUB.Measure_rec_type;

  TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;

  l_arr_short_name t_array_of_varchar2;
  l_num            NUMBER;
  i                NUMBER;
  l_err            VARCHAR2(2000);
  l_Count          NUMBER;
  l_Short_Name     BIS_INDICATORS.short_name%TYPE;

  CURSOR bsc_datasets_cursor_1 IS
    SELECT d.dataset_id, name, m.measure_id, m.created_by created_by, m.last_updated_by last_updated_by, m.last_update_login last_update_login
    FROM bsc_sys_datasets_vl d, bsc_sys_measures m, bisbv_performance_measures pm
    WHERE d.measure_id1 = m.measure_id
    AND m.short_name is null
    AND d.source = 'BSC'
    AND d.dataset_id = pm.dataset_id (+)
    AND pm.dataset_id is null;
BEGIN
  l_num := 0;
  FOR cr IN bsc_datasets_cursor_1 LOOP
      BEGIN
        SAVEPOINT SP_SYNC_MEASURE;
        l_measure_rec.Measure_Short_Name := BSC_BIS_MEASURE_PUB.c_PMD||cr.dataset_id;

        /**************************************************************************
         We need to validate that the Short Name we are going to create already exists
         in PMF data model.If yes then we have to suffix the short_name with A or B
         We already faced the problem when we did the migration from BSCUPG9 environment
         to BSCUPG19 environment.
         For more info on what actaully happened visit

         http://files.oraclecorp.com/content/MySharedFolders/E-BI%20Core%20Status%20Rep
         orts/Development/Vinod%20Bansal/Sudharsan%20Krishnamurthy%20%28Kris%29/Sathis%
         20Kumar/Ravi%20shankar/MIGRATIONISSUE/MigrationIssue.doc
        /**************************************************************************/
        l_measure_rec.Measure_Short_Name := Validate_And_Get_Short_Name(p_Short_Name => l_measure_rec.Measure_Short_Name);

        -- mdamle 10/07/2003 - Bug#3170184 - For BSC type measure, always use short name in PMF display name
        l_measure_rec.Measure_name := l_measure_rec.Measure_short_name;

        l_measure_rec.Application_Id := 271;
        l_measure_rec.Dataset_id := cr.dataset_id;
        -- ankgoel: bug#3891748 - Creation_Date and Last_Update_Date will not be synced-up
        -- They might be useful in debugging
        l_measure_rec.Created_By := cr.created_by;
        l_measure_rec.Last_Updated_By := cr.last_updated_by;
        l_measure_rec.Last_Update_Login := cr.last_update_login;

        BIS_MEASURE_PUB.Create_Measure(
                         p_api_version   => 1.0
                        ,p_commit        => FND_API.G_FALSE
                        ,p_Measure_Rec   => l_measure_rec
            ,p_owner         => FND_LOAD_UTIL.OWNER_NAME(cr.created_by)
                        ,x_return_status => l_return_status
                        ,x_error_tbl     => l_error_tbl);
        IF ((l_return_status IS NOT NULL) AND (l_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        UPDATE bsc_sys_measures
         SET short_name = l_measure_rec.Measure_Short_Name
         WHERE measure_id = cr.measure_id;

    BEGIN
          BSC_MESSAGE.Add(x_message => 'Synchronized measure: ' || l_measure_rec.Measure_short_name || ' : ' || 'Successfully',
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf_51',
                x_mode => 'I');
        EXCEPTION
          WHEN OTHERS THEN
        NULL;
        END;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
      l_num := l_num + 1;
      l_err := l_measure_rec.Measure_Short_Name;
      IF (l_error_tbl.COUNT > 0) THEN
        l_err := l_err || ' : ' || l_error_tbl(1).Error_Description;
      END IF;
      l_arr_short_name(l_num) := l_err;
          ROLLBACK TO SP_SYNC_MEASURE;
      END;
  END LOOP;

  BEGIN
    FOR i IN 1..l_num LOOP
      BSC_MESSAGE.Add(x_message => 'Failed measure: ' || l_arr_short_name(i),
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf_51',
                x_mode => 'I');
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLERRM;
    BSC_MESSAGE.Add(x_message => 'Failed: ' || l_err,
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf_51',
                x_mode => 'I');
END sync_measures_bsc_to_pmf_51;



PROCEDURE synch_measures_cds_to_pmf
IS
  l_return_status  varchar2(1);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec    BIS_MEASURE_PUB.Measure_rec_type;
  l_count          NUMBER;
  l_Kpi_Id         NUMBER;

  TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  l_arr_short_name t_array_of_varchar2;
  l_num            NUMBER;
  i                NUMBER;
  l_err            VARCHAR2(2000);

  CURSOR cds_datasets_cursor IS
  SELECT d.dataset_id, m.short_name
  FROM bsc_sys_datasets_vl d, bsc_sys_measures m, bisbv_performance_measures pm
  WHERE d.measure_id1 = m.measure_id
  AND m.short_name = pm.measure_short_name (+)
  AND m.short_name IS NOT NULL
  AND d.source = 'CDS'
  AND (pm.dataset_id IS NULL);

BEGIN
--For CDS type of measures we need to check if that measure id
-- exits in bis_indicators or not.if the measure exists and its dataset_id
-- is set to NULL then we need to populate
  l_num := 0;
  FOR cd IN cds_datasets_cursor LOOP
   BEGIN
    SAVEPOINT SP_SYNC_CDS_MEASURE;
    IF(cd.short_name IS NOT NULL)THEN

     UPDATE bis_indicators
     SET    dataset_id =cd.dataset_id
     WHERE  short_name =cd.short_name;

    END IF;
   EXCEPTION
    WHEN OTHERS THEN
      l_num := l_num + 1;
      l_err := cd.Short_Name;
      IF (l_error_tbl.COUNT > 0) THEN
       l_err := l_err || ' : ' || l_error_tbl(1).Error_Description;
      END IF;
      l_arr_short_name(l_num) := l_err;
      ROLLBACK TO SP_SYNC_CDS_MEASURE;
   END;
  END LOOP;
 --LOG THE Measures which were failed
  BEGIN
    FOR i IN 1..l_num LOOP
     BSC_MESSAGE.Add(x_message => 'Failed measure: ' || l_arr_short_name(i),
                     x_source => 'BSCUPGRB.synch_measures_cds_to_pmf',
                     x_mode => 'I');
    END LOOP;
  EXCEPTION
   WHEN OTHERS THEN
    NULL;
  END;
--commit the changes

 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLERRM;
    BSC_MESSAGE.Add(x_message => 'Failed: ' || l_err,
                x_source => 'BSCUPGRB.synch_measures_cds_to_pmf',
                x_mode => 'I');

END synch_measures_cds_to_pmf;



--

PROCEDURE sync_measures_bsc_to_pmf
IS
  l_return_status  varchar2(1);
  l_error_tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec    BIS_MEASURE_PUB.Measure_rec_type;
  l_count          NUMBER;
  l_Kpi_Id         NUMBER;

  TYPE t_array_of_varchar2 IS TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;

  l_arr_short_name t_array_of_varchar2;
  l_num            NUMBER;
  i                NUMBER;
  l_err            VARCHAR2(2000);

  CURSOR bsc_datasets_cursor_2 IS
    SELECT d.dataset_id, name, m.short_name, m.measure_id, pm.measure_short_name, m.created_by created_by, m.last_updated_by last_updated_by, m.last_update_login last_update_login
    FROM bsc_sys_datasets_vl d, bsc_sys_measures m, bisbv_performance_measures pm
    WHERE d.measure_id1 = m.measure_id
    AND m.short_name = pm.measure_short_name (+)
    AND m.short_name IS NOT NULL
    AND d.source = 'BSC'
    AND (pm.dataset_id IS NULL OR pm.dataset_id <> d.dataset_id);
BEGIN
    l_num := 0;
    -- If measure already exists, then just update the dataset_id
    FOR cr IN bsc_datasets_cursor_2 LOOP
      BEGIN
        SAVEPOINT SP_SYNC_MEASURE;
        IF cr.measure_short_name is not null then
          -- mdamle 09/22/2003 - First check if the dataset already exists in bis_indicators
          -- When more than 1 dataset points to the same measure, the short_name in measures
          -- will match with only one of the datasets.
          -- If these datasets were already synchronized above, then there would be a record
          -- in bis_indicators for every dataset. Hence, added the check here so that
          -- update is done only if that dataset id is not already set in bis_indicators
          SELECT count(1) INTO l_count
            FROM    BISBV_PERFORMANCE_MEASURES
            WHERE dataset_id = cr.dataset_id;

          IF (l_count = 0) THEN
            UPDATE BIS_INDICATORS
              SET dataset_id = cr.dataset_id
              WHERE short_name = cr.measure_short_name;
          END IF;
        ELSE
          l_measure_rec.Measure_Short_Name := BSC_BIS_MEASURE_PUB.c_PMD||cr.dataset_id;
            /****************************************************************************
            One more thing we have to notive here is that short_names for BSC measures
            will not be same in both the data models.
            Its possible that the same measure can be attached to many datasets.
            So in that case the short_name at BSC end will be different and that at PMF end will
            be different.

            But hold on ,they wil have the same dataset_id.
            So while making a join between both the tables we have to take into account
            dataset_id.
            /****************************************************************************/
            l_measure_rec.Measure_Short_Name := Validate_And_Get_Short_Name(p_Short_Name => l_measure_rec.Measure_Short_Name);

          -- mdamle 10/07/2003 - Bug#3170184 - For BSC type measure, always use short name in PMF display name
          l_measure_rec.Measure_name := l_measure_rec.Measure_short_name;

          l_measure_rec.Application_Id := 271;
          l_measure_rec.dataset_id := cr.dataset_id;
          -- ankgoel: bug#3891748 - Creation_Date and Last_Update_Date will not be synced-up
          -- They might ne useful in debugging
      l_measure_rec.Created_By := cr.created_by;
          l_measure_rec.Last_Updated_By := cr.last_updated_by;
          l_measure_rec.Last_Update_Login := cr.last_update_login;

          -- Get the actual_data_source, actual_data_source_type and function name for custom KPIs
      IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.is_KPI_EndToEnd_Measure(cr.Measure_Id) = FND_API.G_TRUE) THEN
        BEGIN
              BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Pmf_Metadata_By_Objective (
                      p_Dataset_Id         => cr.dataset_Id
                    , p_Measure_Short_Name => cr.short_name
                    , x_Actual_Source_Type => l_measure_rec.Actual_Data_Source_Type
                    , x_Actual_Source      => l_measure_rec.Actual_Data_Source
                    , x_Function_Name      => l_measure_rec.Function_Name
               );
              -- enable to report
              l_measure_rec.Enable_Link := 'Y';
        EXCEPTION
          WHEN OTHERS THEN
            BSC_MESSAGE.Add(x_message => 'Custom KPI: ' || cr.Short_Name || ' : ' || 'Failed to get PMF Metadata',
                  x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf',
                  x_mode => 'I');
        END;
          END IF;

          BIS_MEASURE_PUB.Create_Measure(
                         p_api_version   => 1.0
                        ,p_commit        => FND_API.G_FALSE
                        ,p_Measure_Rec   => l_measure_rec
            ,p_owner         => FND_LOAD_UTIL.OWNER_NAME(cr.created_by)
                        ,x_return_status => l_return_status
                        ,x_error_tbl     => l_error_tbl);
          IF ((l_return_status IS NOT NULL) AND (l_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

            UPDATE  BSC_SYS_MEASURES
            SET     short_name = l_measure_rec.Measure_Short_Name
            WHERE   measure_id = cr.measure_id;
        END IF;

    BEGIN
          BSC_MESSAGE.Add(x_message => 'Synchronized measure: ' || cr.Short_Name || ' : ' || 'Successfully',
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf',
                x_mode => 'I');
        EXCEPTION
          WHEN OTHERS THEN
        NULL;
        END;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
      l_num := l_num + 1;
      l_err := cr.Short_Name;
      IF (l_error_tbl.COUNT > 0) THEN
        l_err := l_err || ' : ' || l_error_tbl(1).Error_Description;
      END IF;
      l_arr_short_name(l_num) := l_err;
          ROLLBACK TO SP_SYNC_MEASURE;
      END;
    END LOOP;

    BEGIN
      FOR i IN 1..l_num LOOP
        BSC_MESSAGE.Add(x_message => 'Failed measure: ' || l_arr_short_name(i),
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf',
                x_mode => 'I');
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
    NULL;
    END;

    COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    l_err := SQLERRM;
    BSC_MESSAGE.Add(x_message => 'Failed: ' || l_err,
                x_source => 'BSCUPGRB.sync_measures_bsc_to_pmf',
                x_mode => 'I');
END sync_measures_bsc_to_pmf;
--
/***************************************************************************************************

    if the short name sent already exists in bsc_sys_measures it gets time based unique short_name

***************************************************************************************************/
FUNCTION getUniqueShtNameSysMeasure(p_Short_Name IN VARCHAR2)
RETURN   VARCHAR2
IS
l_count  NUMBER;
BEGIN
  SELECT COUNT(1)
  INTO   l_count
  FROM   BSC_SYS_MEASURES
  WHERE  SHORT_NAME = p_Short_Name;

  IF(l_count > 0) THEN
    RETURN bsc_utility.Get_Unique_Sht_Name_By_Obj_Typ(p_Object_Type => bsc_utility.c_BSC_MEASURE);
  ELSE
    RETURN p_Short_Name;
  END IF;
END getUniqueShtNameSysMeasure;

/***************************************************************************************************/



/***************************************************************************************************
Added for the bug#4477575
 This function populates short_name in bsc_sys_measures if it is null.
 we found that there may be case where short_name can be null after syncup is run as migration
is putting null for all bsc_short_names
***************************************************************************************************/
PROCEDURE update_short_name_bsc_sys_mes
IS
  CURSOR cBscSysMeasures IS
  SELECT M.short_name bscShortName
        ,B.short_name bisShortName
        ,B.dataset_id
        ,M.measure_id
  FROM   bsc_sys_measures M
        ,bsc_sys_datasets_vl V
        ,bis_indicators_Vl B
  WHERE M.measure_id = V.measure_id1
  AND   B.dataset_id = V.dataset_id
  AND   V.SOURCE     = 'BSC'
  AND   M.short_name IS NULL;

  l_Measure_Short_Name     BIS_INDICATORS.SHORT_NAME%TYPE;
  l_Bsc_Measure_Short_Name BSC_SYS_MEASURES.SHORT_NAME%TYPE;
BEGIN
  SAVEPOINT SP_UPDATE_SHORT_NAME;
  FOR cBSCM IN cBscSysMeasures LOOP
    l_Bsc_Measure_Short_Name := getUniqueShtNameSysMeasure(p_Short_Name => cBSCM.bisShortName);

    UPDATE bsc_sys_measures
    SET    short_name = l_Bsc_Measure_Short_Name
    WHERE  measure_id = cBSCM.measure_id;

  END LOOP;
  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SP_UPDATE_SHORT_NAME;
        BSC_MESSAGE.Add (
              x_message => SQLERRM
            , x_source  => 'Update short names in bsc_sys_measures'
            , x_mode    => 'I'
        );
END update_short_name_bsc_sys_mes;
/**********************************************************************************************/

FUNCTION synchronize_measures(
  x_error_msg   OUT NOCOPY VARCHAR2
) return boolean is

l_return_status         varchar2(1);
l_msg_count             number;
l_msg_data              varchar2(2000);
l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    -- meastmon bug#3379110 --------------------------------------------------------------------
    -- If the dataset_ids from BIS_INDICATORS and BSC_SYS_DATASETS_VL are not in synch
    -- we are going to:
    -- 1. Remove BSC measures from PMF repository
    -- 2. Update all the dataset_ids to NULL.
    -- Then synchronization will refresh the dataset_id in BIS_INDICATORS with the correct value
    -- from BSC_SYS_DATASETS_VL
    delete_bsc_measures_from_pmf;

    -- For every PMF record that does not exist in bsc_sys_datasets, create one in bsc_sys_datasets and bsc_sys_measures
    sync_measures_pmf_to_bsc;


    -- For every dataset, create a record in bis_indicator table.
    -- Short Name is null (for Pre-51 release measures)
    sync_measures_bsc_to_pmf_51;


    -- For every dataset, create a record in bis_indicator table.
    -- For post-51 release migration from another db - short_name is not null
    sync_measures_bsc_to_pmf;

    --Modified for the bug#4477575
    update_short_name_bsc_sys_mes;

    --For CDS type of measures we will check only the dataset_id is populated
    -- or not. if not then we will update it.It will happen during migration
    -- process.
    synch_measures_cds_to_pmf;

    -- mdamle 09/25/2003 - Sync up measures for all installed languages
    -- This is used to fix language data that was generated before the synchronize routines were added in
    lang_synch_existing_measures(
                  x_msg_count       => l_msg_count
                , x_msg_data        => l_msg_data
                , x_return_status   => l_return_status
                , x_error_tbl       => l_error_tbl);

    -- mdamle 09/25/2003 - BIS messages need to be added to the FND stack
    --Added for Enhancement#4239216
        Refresh_Measure_Col_Names;
        --Added for Enhancement#4239216
        Gen_Existing_Measure_Cols;
    BSC_UTILITY.Add_To_Fnd_Msg_Stack(
             p_error_tbl       => l_error_tbl
            ,x_return_status   => l_return_status
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data);

    IF (l_return_status IS NOT NULL AND l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    COMMIT;
    RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    IF (l_msg_data IS NULL) THEN
      l_msg_data := SQLERRM;
    END IF;
    x_error_msg := l_msg_data;
    RETURN FALSE;
END synchronize_measures;


-- mdamle 09/25/2003 - Sync up measures for all installed languages
-- ashankar: bug#390429 - Used by bscup.sql in create_template process
Procedure lang_synch_BSC_To_PMF_measure(
      p_dataset_id      IN NUMBER := NULL
    , p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type)
is

cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');


 l_name     bsc_sys_datasets_tl.name%type;
 l_help     bsc_sys_datasets_tl.help%type;
 l_source_lang  bsc_sys_datasets_tl.source_lang%type;
 l_Measure_Rec  BIS_MEASURE_PUB.Measure_Rec_Type;
 l_count    number;

BEGIN

    l_measure_rec := p_measure_rec;
    for cr in installed_languages_cursor loop
        select name, help, source_lang into l_name, l_help, l_source_lang
        from bsc_sys_datasets_tl
        where dataset_id = p_dataset_id
        and language = cr.language_code;

        l_measure_rec.measure_name := l_name;
        l_measure_rec.description := l_help;

        -- mdamle 10/07/2003 - Bug#3170184 - For BSC type measure, always use short name in PMF display name
        l_measure_rec.Measure_name := l_measure_rec.Measure_short_name;

        BIS_MEASURE_PUB.Translate_Measure_By_lang
            ( p_api_version       => 1.0
            , p_commit            => FND_API.G_FALSE
            , p_Measure_Rec       => l_Measure_Rec
            , p_lang              => cr.language_code
            , p_source_lang       => l_source_lang
            , x_return_status     => x_return_status
            , x_error_Tbl         => x_error_tbl
            );
    end loop;

        if installed_languages_cursor%ISOPEN THEN
            CLOSE installed_languages_cursor;
        end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    RAISE;

END lang_synch_BSC_To_PMF_measure;



-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure lang_synch_PMF_To_BSC_measure(
      p_indicator_id    IN NUMBER -- := NULL
    , p_Dataset_Rec         IN  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_msg_count       OUT NOCOPY NUMBER
    , x_msg_data        OUT NOCOPY VARCHAR2)
is

cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');

 l_name     bis_indicators_tl.name%type;
 l_description  bis_indicators_tl.description%type;
 l_measure_name bis_indicators_tl.name%type;
 l_source_lang  bis_indicators_tl.source_lang%type;
 l_Dataset_Rec  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
BEGIN

    l_dataset_rec := p_dataset_rec;

    SELECT name INTO l_measure_name
      FROM bis_indicators_tl
      WHERE indicator_id = p_indicator_id
      AND language = userenv('LANG');

    for cr in installed_languages_cursor loop
        select name, description, source_lang
        into l_name, l_description, l_source_lang
        from bis_indicators_tl
        where indicator_id = p_indicator_id
        and language = cr.language_code;

    -- ankgoel: bug#3874911
    -- Get the name from BIS end only when it's not changed during validations
    IF (l_dataset_rec.Bsc_Dataset_Name = l_measure_name) THEN
          l_dataset_rec.Bsc_Dataset_Name := l_name;
    END IF;
        l_dataset_rec.Bsc_Dataset_help := l_description;

        BSC_DATASETS_PUB.Translate_Measure_By_Lang
            ( p_commit      => FND_API.G_FALSE
            , p_Dataset_Rec     => l_Dataset_Rec
            , p_lang        => cr.language_code
            , p_source_lang     => l_source_lang
            , x_return_status   => x_return_status
            , x_msg_count       => x_msg_count
            , x_msg_data        => x_msg_data);

    end loop;

        if installed_languages_cursor%ISOPEN THEN
            CLOSE installed_languages_cursor;
        end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END lang_synch_PMF_To_BSC_measure;


-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure lang_synch_existing_measures(
      x_msg_count       OUT NOCOPY NUMBER
    , x_msg_data        OUT NOCOPY VARCHAR2
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type)
is

cursor synch_lang_cursor is
    select i.indicator_id, itl.language, itl.source_lang, i.short_name, d.source, d.dataset_id,
    itl.name indicator_name, dtl.name dataset_name,
    itl.description, dtl.help
    from bis_indicators i, bis_indicators_tl itl, bsc_sys_datasets_b d, bsc_sys_datasets_tl dtl
    where i.indicator_id = itl.indicator_id
    and i.dataset_id = dtl.dataset_id
    and d.dataset_id = dtl.dataset_id
    and itl.language = dtl.language
    and itl.name <> dtl.name;

 l_Dataset_Rec  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
 l_Measure_Rec  BIS_MEASURE_PUB.Measure_Rec_Type;
 l_measure_name BIS_INDICATORS_TL.Name%TYPE;
 l_count        number;
BEGIN

    for scr in synch_lang_cursor loop
    if scr.source = BSC_BIS_MEASURE_PUB.c_BSC then
        -- ankgoel: Since name is same as short name and will not get
        -- re-generated unlike PMF to BSC sync-up, no conditions reqd. here
        l_measure_rec.measure_id := scr.indicator_id;
        l_measure_rec.description := scr.help;

        -- mdamle 10/07/2003 - Bug#3170184 - For BSC type measure, always use short name in PMF display name
        l_measure_rec.Measure_name := scr.short_name;

        BIS_MEASURE_PUB.Translate_Measure_By_lang
            ( p_api_version       => 1.0
            , p_commit            => FND_API.G_FALSE
            , p_Measure_Rec       => l_Measure_Rec
            , p_lang              => scr.language
            , p_source_lang       => scr.source_lang
            , x_return_status     => x_return_status
            , x_error_Tbl         => x_error_tbl
            );
    else
        SELECT name INTO l_measure_name
          FROM bis_indicators_tl
          WHERE indicator_id = scr.indicator_id
          AND language = userenv('LANG');

        l_dataset_rec.bsc_dataset_id := scr.dataset_id;

        -- ankgoel: bug#3874911
    -- Get the name from BIS end only when it's not changed during validations
    IF(l_dataset_rec.Bsc_Dataset_Name = l_measure_name) THEN
          l_dataset_rec.bsc_dataset_name := scr.indicator_name;
    END IF;

        if (scr.description is null) then
            l_dataset_rec.bsc_dataset_help := l_dataset_rec.bsc_dataset_name;
        else
            l_dataset_rec.bsc_dataset_help := scr.description;
        end if;

        BSC_DATASETS_PUB.Translate_Measure_By_Lang
            ( p_commit          => FND_API.G_FALSE
            , p_Dataset_Rec     => l_Dataset_Rec
            , p_lang            => scr.language
            , p_source_lang     => scr.source_lang
            , x_return_status   => x_return_status
            , x_msg_count       => x_msg_count
            , x_msg_data        => x_msg_data);

        end if;
    end loop;

    if synch_lang_cursor%ISOPEN THEN
       CLOSE synch_lang_cursor;
    end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if synch_lang_cursor%ISOPEN THEN
       CLOSE synch_lang_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if synch_lang_cursor%ISOPEN THEN
       CLOSE synch_lang_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if synch_lang_cursor%ISOPEN THEN
       CLOSE synch_lang_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if synch_lang_cursor%ISOPEN THEN
       CLOSE synch_lang_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END lang_synch_existing_measures;

-- Not Used anymore
function getUniqueDisplayName(
      p_dataset_name    IN VARCHAR2
    , p_language        IN VARCHAR2) return varchar2
IS
l_pmf_disp_name         bsc_sys_datasets_tl.name%type;
l_count             number;
begin
    l_pmf_disp_name := trim(p_dataset_name);

        select count(indicator_id) into l_count
        from bis_indicators_tl
        where upper(name) = upper(l_pmf_disp_name)
        and language = p_language;

        while(l_count > 0) loop
            l_pmf_disp_name := bsc_utility.get_Next_DispName(l_pmf_disp_name);

            select count(indicator_id) into l_count
            from bis_indicators_tl
            where upper(name) = upper(l_pmf_disp_name)
            and language = p_language;
        end loop;

    return l_pmf_disp_name;

EXCEPTION
    when others then return null;

end getUniqueDisplayName;



/*******************************************************************************
           FUNCTION TO SYNCHRONZIE DIMENSION OBJECTS BSC & PMF
********************************************************************************/
FUNCTION Synchronize_Dim_Objects
(
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_return_status     VARCHAR2(30);
    l_msg_count         NUMBER;
    l_dimension_id      NUMBER;

    CURSOR   c_bis_dim_objs IS
    SELECT   Short_Name
          ,  Dimension_Id
          ,  Level_Values_View_Name
          ,  Where_Clause
          ,  Created_By
          ,  Last_Updated_By
          ,  Last_Update_Date
          ,  Last_Update_Login
          ,  Name
          ,  Description
          ,  Source
          ,  Comparison_Label_Code
          ,  Attribute_Code
          ,  Application_Id
    FROM  BIS_LEVELS_VL;

    CURSOR  c_bsc_dim_objs IS
    SELECT  Dim_Level_Id
         ,  Name
         ,  Help
         ,  Total_Disp_Name
         ,  Comp_Disp_Name
         ,  Level_Table_Name
         ,  Table_Type
         ,  Level_Pk_Col
         ,  Abbreviation
         ,  Value_Order_By
         ,  Comp_Order_By
         ,  Custom_Group
         ,  User_Key_Size
         ,  Disp_Key_Size
         ,  Edw_Flag
         ,  Edw_Dim_Id
         ,  Edw_Dim_Level_Id
         ,  Level_View_Name
         ,  Short_Name
         ,  Source
     ,  Created_By
     ,  Last_Updated_By
     ,  Last_Update_Date
     ,  Last_Update_Login
    FROM BSC_SYS_DIM_LEVELS_VL;

    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_bis_dim_level_rec     BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;

    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;

    l_flag                  BOOLEAN;
    l_count                 NUMBER;
    l_sql                   VARCHAR2(32000);

    CURSOR  c_oltp_level_name  IS
    SELECT  level_values_view_name
    FROM    BIS_LEVELS
    WHERE   SOURCE = 'OLTP'
    AND     level_values_view_name NOT LIKE 'BSC_D_%'
    AND     level_values_view_name IS NOT NULL;
BEGIN
    BSC_APPS.Init_Bsc_Apps;
    FND_MSG_PUB.Initialize;
    SAVEPOINT BscSyncDimeObjects;

    --Modify level_table_names in BSC tables to Upper case
    UPDATE BSC_SYS_DIM_LEVELS_B
    SET    Level_Table_Name = UPPER(Level_Table_Name)
    WHERE LEVEL_TABLE_NAME <> UPPER(LEVEL_TABLE_NAME);

    UPDATE BSC_KPI_DIM_LEVELS_B
    SET    Level_Table_Name = UPPER(Level_Table_Name)
    WHERE LEVEL_TABLE_NAME <> UPPER(LEVEL_TABLE_NAME);

    UPDATE BSC_DB_TABLES_RELS
    SET    Table_Name = UPPER(Table_Name)
    WHERE Table_Name <> UPPER(Table_Name);

    UPDATE BSC_SYS_DIM_LEVELS_B
    SET    SHORT_NAME   = 'BSC_DIM_OBJ_'||Dim_Level_Id||'_'||ROWNUM
    WHERE  short_name IS NULL;

    FOR cd IN c_bsc_dim_objs LOOP
        SELECT COUNT(1) INTO l_count
          FROM   BIS_LEVELS
          WHERE  short_name = cd.Short_Name;
        IF (l_count = 0) THEN
          SELECT COUNT(1) INTO l_count
            FROM   BIS_LEVELS_TL
            WHERE  Name = cd.Name
            AND language = userenv('LANG');

            IF (l_count = 0) THEN
              l_bis_dim_level_rec.Dimension_Level_Name      :=   cd.Name;    -- Bug 3172231, should use Dimension_Level_Name instaed of Dimension_Name
            ELSE
              l_bis_dim_level_rec.Dimension_Level_Name      :=   cd.Short_Name; -- Bug 3172231, should use Dimension_Level_Name instaed of Dimension_Name
            END IF;
            l_bis_dim_level_rec.Dimension_Name              :=   'unassigned';
            l_bis_dim_level_rec.Dimension_Short_Name        :=   'DUMMY_NAME';
            l_bis_dim_level_rec.Dimension_ID                :=   -1;
            l_bis_dim_level_rec.Dimension_Level_Short_Name  :=   cd.short_name;
            --l_bis_dim_level_rec.Dimension_Level_Name      :=   cd.Name; -- Bug 3172231
            l_bis_dim_level_rec.Description                 :=   cd.Help;
            l_bis_dim_level_rec.Level_Values_View_Name      :=   cd.level_table_name;
            l_bis_dim_level_rec.where_Clause                :=   NULL;
            l_bis_dim_level_rec.Source                      :=  'OLTP';
            -- 12/22/03 meastmon: Bug#3333957 Pass application id 271(Balanced scorecard application Id)
            -- when creating a BSC dimension level
            l_bis_dim_level_rec.Application_ID              := 271;
            -- ankgoel: bug#3891748 - Creation_Date and Last_Update_Date will not be synced-up
            -- They might ne useful in debugging
            -- But now syncing-up for bug#4045278
            l_bis_dim_level_rec.Created_By                  := cd.Created_By;
            l_bis_dim_level_rec.Last_Updated_By             := cd.Last_Updated_By;
            l_bis_dim_level_rec.Last_Update_Date            := cd.Last_Update_Date;
            l_bis_dim_level_rec.Last_Update_Login           := cd.Last_Update_Login;
      -- ankgoel: bug#4625611 - dim object should be enabled by default
            l_bis_dim_level_rec.enabled                     := FND_API.G_TRUE;

            BIS_DIMENSION_LEVEL_PUB.Create_Dimension_Level
            (
                    p_api_version           =>  1.0
                ,   p_commit                =>  FND_API.G_FALSE
                ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
                ,   p_Dimension_Level_Rec   =>  l_bis_dim_level_rec
                ,   x_return_status         =>  l_return_status
                ,   x_error_Tbl             =>  l_error_tbl
            );

            Lang_Synch_BSC_To_PMF_DimObj
            (
                p_level_short_name    =>  l_bis_dim_level_rec.Dimension_Level_Short_Name
              , x_return_status       =>  l_return_status
              , x_error_Tbl           =>  l_error_tbl
            );

        END IF;
    END LOOP;

    FOR cd IN c_bis_dim_objs LOOP
        SELECT COUNT(1) INTO l_count
        FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  short_name = cd.Short_Name;

        IF(l_count = 0) THEN
            l_bsc_dim_obj_rec.Source                    :=   cd.Source;
            l_bsc_dim_obj_rec.Bsc_Level_Id              :=   BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_SYS_DIM_LEVELS_B', 'DIM_LEVEL_ID');
            l_bsc_dim_obj_rec.Bsc_Source                :=  'PMF';
            l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size   :=   5;
            l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size   :=   15;
            l_bsc_dim_obj_rec.Bsc_Level_Abbreviation    :=   SUBSTR(REPLACE(cd.Short_Name, ' ', ''), 1, 5);
            l_bsc_dim_obj_rec.Bsc_Level_Short_Name      :=   cd.Short_Name;
            l_bsc_dim_obj_rec.Bsc_Pk_Col                :=   cd.Short_Name; -- Start to End KPI -- NULL; --fetch from IN-OUT Parameter
            l_bsc_dim_obj_rec.Bsc_Level_Name            :=   cd.Level_Values_View_Name;
            l_bsc_dim_obj_rec.Bsc_Dim_Comp_Disp_Name    :=  'COMPARISON';
            l_bsc_dim_obj_rec.Bsc_Dim_Level_Long_Name   :=   SUBSTR(cd.Name, 1, 60);
            l_bsc_dim_obj_rec.Bsc_Dim_Level_Help        :=   NVL(cd.Description, cd.Name);
            l_bsc_dim_obj_rec.Bsc_Dim_Tot_Disp_Name     :=  'ALL';
            l_bsc_dim_obj_rec.Bsc_Level_Comp_Order_By   :=   0;
            l_bsc_dim_obj_rec.Bsc_Level_Custom_Group    :=   0;
            l_bsc_dim_obj_rec.Bsc_Level_Index           :=   0;
            l_bsc_dim_obj_rec.Bsc_Level_Table_Type      :=   -1; --view will not be created at this point
            l_bsc_dim_obj_rec.Bsc_Level_Value_Order_By  :=   0;
            l_bsc_dim_obj_rec.Bsc_Created_By            :=  cd.Created_By;
            l_bsc_dim_obj_rec.Bsc_Last_Updated_By       :=  cd.Last_Updated_By;
            l_bsc_dim_obj_rec.Bsc_Last_Update_Date      :=  cd.Last_Update_Date;
            l_bsc_dim_obj_rec.Bsc_Last_Update_Login     :=  cd.Last_Update_Login;

            l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs
                        (
                                p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                            ,   x_return_status     =>  l_return_status
                            ,   x_msg_count         =>  l_msg_count
                            ,   x_msg_data          =>  x_error_msg
                        );

            l_bsc_dim_obj_rec.Bsc_Level_Name  :=  l_bsc_dim_obj_rec.Bsc_Level_View_Name;
            BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level
            (
                    p_commit        =>  FND_API.G_FALSE
                 ,  p_Dim_Level_Rec =>  l_bsc_dim_obj_rec
                 ,  p_create_tables =>  FALSE
                 ,  x_return_status =>  l_return_status
                 ,  x_msg_count     =>  l_msg_count
                 ,  x_msg_data      =>  x_error_msg
            );

            --
            Lang_Synch_PMF_To_BSC_DimObj
            (
                 p_level_short_name    =>  l_bsc_dim_obj_rec.Bsc_Level_Short_Name
              ,  x_return_status       =>  l_return_status
              ,  x_msg_count           =>  l_msg_count
              ,  x_msg_data            =>  x_error_msg
            );

        END IF;
    END LOOP;
    COMMIT;
    x_error_msg :=  'BSC_UPGRADES.Synchronize_Dim_Objects Successfully Completed';
    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_bis_dim_objs%ISOPEN) THEN
            CLOSE c_bis_dim_objs;
        END IF;
        IF (c_bsc_dim_objs%ISOPEN) THEN
            CLOSE c_bsc_dim_objs;
        END IF;
        ROLLBACK TO BscSyncDimeObjects;
        IF (x_error_msg IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_error_msg
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_error_msg);
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_bis_dim_objs%ISOPEN) THEN
            CLOSE c_bis_dim_objs;
        END IF;
        IF (c_bsc_dim_objs%ISOPEN) THEN
            CLOSE c_bsc_dim_objs;
        END IF;
        ROLLBACK TO BscSyncDimeObjects;
        IF (x_error_msg IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_error_msg
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_error_msg);
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        IF (c_bis_dim_objs%ISOPEN) THEN
            CLOSE c_bis_dim_objs;
        END IF;
        IF (c_bsc_dim_objs%ISOPEN) THEN
            CLOSE c_bsc_dim_objs;
        END IF;
        ROLLBACK TO BscSyncDimeObjects;
        IF (x_error_msg IS NOT NULL) THEN
            x_error_msg      :=  x_error_msg||' -> BSC_BIS_DIMENSION_PUB.Synchronize_Dim_Objects ';
        ELSE
            x_error_msg      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Synchronize_Dim_Objects ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_error_msg);
        RETURN FALSE;
    WHEN OTHERS THEN
        IF (c_bis_dim_objs%ISOPEN) THEN
            CLOSE c_bis_dim_objs;
        END IF;
        IF (c_bsc_dim_objs%ISOPEN) THEN
            CLOSE c_bsc_dim_objs;
        END IF;
        ROLLBACK TO BscSyncDimeObjects;
        IF (x_error_msg IS NOT NULL) THEN
            x_error_msg      :=  x_error_msg||' -> BSC_BIS_DIMENSION_PUB.Synchronize_Dim_Objects ';
        ELSE
            x_error_msg      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Synchronize_Dim_Objects ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_error_msg);
        RETURN FALSE;
END Synchronize_Dim_Objects;




/*******************************************************************************
              FUNCTION TO SYNCHRONZIE DIMENSIONS IN BSC & PMF
********************************************************************************/
FUNCTION Synchronize_Dimensions
(
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_return_status     VARCHAR2(30);
    l_msg_count         NUMBER;
    l_dimension_id      NUMBER;
    l_cn_dim_level_id NUMBER;

    CURSOR   c_bis_dims IS
    SELECT   Dimension_Id
        ,    Short_Name
        ,    Created_By
        ,    Last_Updated_By
        ,    Last_Update_Date
        ,    Last_Update_Login
        ,    Name
        ,    Description
        ,    Application_Id
    FROM     BIS_DIMENSIONS_VL
    WHERE    DIM_GRP_ID IS NULL;

    CURSOR   c_bsc_dims  IS
    SELECT   Dim_Group_Id
        ,    Name
        ,    Short_Name
    ,    Created_By
    ,    Last_Updated_By
    ,    Last_Update_Date
    ,    Last_Update_Login
    FROM     BSC_SYS_DIM_GROUPS_VL;

    CURSOR   dim_obj_short_name IS
    SELECT   A.short_name       short_name
    FROM     BIS_LEVELS               A
    WHERE    A.dimension_id = l_dimension_id;


    l_bis_dimension_rec     BIS_DIMENSION_PUB.Dimension_Rec_Type;
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;

    l_flag                  BOOLEAN;
    l_count                 NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    SAVEPOINT   BscSyncDimensions;

    UPDATE      BSC_SYS_DIM_GROUPS_TL
    SET         SHORT_NAME   = 'BSC_DIM_'||Dim_Group_Id
    WHERE       short_name IS NULL;

    FOR cd IN c_bis_dims LOOP
        SELECT COUNT(1) INTO l_count
        FROM   BSC_SYS_DIM_GROUPS_VL
        WHERE  short_name = cd.Short_Name;

        IF (l_count = 0) THEN
            IF (cd.Dimension_Id <> -1) THEN
                SELECT COUNT(1) INTO l_count
                  FROM   BSC_SYS_DIM_GROUPS_TL
                  WHERE  name = cd.Name
                  AND  language = userenv('LANG');

                IF (l_count = 0) THEN
                    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name   :=  cd.Name;
                ELSE
                    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name   :=  cd.Short_Name;
                END IF;
                l_dimension_id                                     :=  cd.Dimension_Id;
                l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id         :=  NULL;
                l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name :=  cd.Short_Name;
                l_bsc_dimension_rec.Bsc_Dim_Level_Index            :=   1;
                l_bsc_dimension_rec.Bsc_Group_Level_Comp_Flag      :=  -1;
                l_bsc_dimension_rec.Bsc_Group_Level_Default_Value  :=  'T';
                l_bsc_dimension_rec.Bsc_Group_Level_Default_Type   :=   0;
                l_bsc_dimension_rec.Bsc_Group_Level_Filter_Col     :=  NULL;
                l_bsc_dimension_rec.Bsc_Group_Level_Filter_Value   :=   0;
                l_bsc_dimension_rec.Bsc_Group_Level_No_Items       :=   0;
                l_bsc_dimension_rec.Bsc_Group_Level_Parent_In_Tot  :=   2;
                l_bsc_dimension_rec.Bsc_Group_Level_Total_Flag     :=  -1;
                l_bsc_dimension_rec.Bsc_Language                   :=  NULL;
                l_bsc_dimension_rec.Bsc_Level_Id                   :=  NULL;
                l_bsc_dimension_rec.Bsc_Source_Language            :=  NULL;
                l_bsc_dimension_rec.Bsc_Created_By                 :=  cd.Created_By;
                l_bsc_dimension_rec.Bsc_Last_Updated_By            :=  cd.Last_Updated_By;
                l_bsc_dimension_rec.Bsc_Last_Update_Date           :=  cd.Last_Update_Date;
                l_bsc_dimension_rec.Bsc_Last_Update_Login          :=  cd.Last_Update_Login;

                BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group
                (
                        p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
                    ,   p_create_Dim_Levels     =>  FALSE
                    ,   x_return_status         =>  l_return_status
                    ,   x_msg_count             =>  l_msg_count
                    ,   x_msg_data              =>  x_error_msg
                );


                Lang_Synch_PMF_To_BSC_Dim
                (
                        p_dim_short_name    =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Short_Name
                    ,   x_return_status     =>  l_return_status
                    ,   x_msg_count         =>  l_msg_count
                    ,   x_msg_data          =>  x_error_msg
                );

                -- sync-up dimension - dimension objects relationship to BSC side.
                FOR dim_cn IN dim_obj_short_name LOOP
                  -- Added because join to bis_levels is causing FTS.
                  BEGIN
                    SELECT dim_level_id
                      INTO l_cn_dim_level_id
                      FROM BSC_SYS_DIM_LEVELS_B
                      WHERE short_name = dim_cn.short_name;
                  EXCEPTION WHEN OTHERS THEN
                    NULL;
                  END;
                  SELECT COUNT(1) INTO l_count
                    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
                    WHERE  dim_level_id = l_cn_dim_level_id
                    AND    dim_group_id = (SELECT Dim_Group_Id
                        FROM  BSC_SYS_DIM_GROUPS_VL WHERE SHORT_NAME = cd.Short_Name);

                    IF (l_count = 0) THEN
                        BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object
                        (
                                p_commit              =>  FND_API.G_FALSE
                            ,   p_dim_short_name      =>  cd.Short_Name
                            ,   p_dim_obj_short_name  =>  dim_cn.Short_Name
                            ,   p_comp_flag           => -1
                            ,   p_no_items            =>  0
                            ,   p_parent_in_tot       =>  2
                            ,   p_total_flag          => -1
                            ,   p_default_value       => 'T'
                            ,   p_time_stamp          =>  NULL     -- Granular Locking
                            ,   x_return_status       =>  l_return_status
                            ,   x_msg_count           =>  l_msg_count
                            ,   x_msg_data            =>  x_error_msg
                        );
                    END IF;
                END LOOP;
            END IF;
        END IF;


    END LOOP;

    FOR cd IN c_bsc_dims LOOP
        SELECT COUNT(1) INTO l_count
          FROM   BIS_DIMENSIONS
          WHERE  short_name = cd.Short_Name;

        IF (l_count = 0) THEN
          SELECT COUNT(1) INTO l_count
            FROM   BIS_DIMENSIONS_TL
            WHERE  Name = cd.Name
            AND language = userenv('LANG');

            IF (l_count = 0) THEN
                l_bis_dimension_rec.Dimension_Name   :=  cd.Name;
            ELSE
                l_bis_dimension_rec.Dimension_Name   :=  cd.short_name;
            END IF;
            l_bis_dimension_rec.Dimension_Short_Name :=  cd.short_name;
            l_bis_dimension_rec.Description          :=  cd.Name;
            l_bis_dimension_rec.Application_ID       :=  271;
            -- ankgoel: bug#3891748 - Creation_Date and Last_Update_Date will not be synced-up
            -- They might ne useful in debugging
            -- But now syncing-up for bug#4045278
            l_bis_dimension_rec.Created_By           :=  cd.Created_By;
            l_bis_dimension_rec.Last_Updated_By      :=  cd.Last_Updated_By;
            l_bis_dimension_rec.Last_Update_Date     :=  cd.Last_Update_Date;
            l_bis_dimension_rec.Last_Update_Login    :=  cd.Last_Update_Login;

            BIS_DIMENSION_PUB.Create_Dimension
            ( p_api_version       =>  1.0
            , p_commit            =>  FND_API.G_FALSE
            , p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL
            , p_Dimension_Rec     =>  l_bis_dimension_rec
            , x_return_status     =>  l_return_status
            , x_error_Tbl         =>  l_error_tbl
            );

            Lang_Synch_BSC_To_PMF_Dim
            ( p_dim_short_name  => l_bis_dimension_rec.Dimension_Short_Name
            , x_return_status   =>  l_return_status
            , x_error_Tbl       =>  l_error_tbl
            );

            -- sync-up dimension - dimension objects relationship to PMF side.
      sync_dim_object_mappings
      ( p_dim_short_name  => l_bis_dimension_rec.Dimension_Short_Name
            , x_return_status   =>  l_return_status
            , x_error_Tbl       =>  l_error_tbl
            );

        END IF;

        UPDATE BIS_DIMENSIONS
        SET    Dim_Grp_ID        = cd.Dim_Group_Id
        WHERE  Short_Name = cd.short_name;

    END LOOP;
    COMMIT;
    x_error_msg :=  'BSC_UPGRADES.Synchronize_Dimensions Successfully Completed';
    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_bsc_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (c_bis_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (dim_obj_short_name%ISOPEN) THEN
            CLOSE dim_obj_short_name;
        END IF;
        ROLLBACK TO BscSyncDimensions;
        IF (x_error_msg IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_error_msg
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_error_msg);
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_bsc_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (c_bis_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (dim_obj_short_name%ISOPEN) THEN
            CLOSE dim_obj_short_name;
        END IF;
        ROLLBACK TO BscSyncDimensions;
        IF (x_error_msg IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   => 'F'
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  x_error_msg
            );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_error_msg);
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        IF (c_bsc_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (c_bis_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (dim_obj_short_name%ISOPEN) THEN
            CLOSE dim_obj_short_name;
        END IF;
        ROLLBACK TO BscSyncDimensions;
        IF (x_error_msg IS NOT NULL) THEN
            x_error_msg      :=  x_error_msg||' -> BSC_UPGRADES.Synchronize_Dimensions ';
        ELSE
            x_error_msg      :=  SQLERRM||' at BSC_UPGRADES.Synchronize_Dimensions ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_error_msg);
        RETURN FALSE;
    WHEN OTHERS THEN
        IF (c_bsc_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (c_bis_dims%ISOPEN) THEN
            CLOSE c_bsc_dims;
        END IF;
        IF (dim_obj_short_name%ISOPEN) THEN
            CLOSE dim_obj_short_name;
        END IF;
        ROLLBACK TO BscSyncDimensions;
        IF (x_error_msg IS NOT NULL) THEN
            x_error_msg      :=  x_error_msg||' -> BSC_UPGRADES.Synchronize_Dimensions ';
        ELSE
            x_error_msg      :=  SQLERRM||' at BSC_UPGRADES.Synchronize_Dimensions ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_error_msg);
        RETURN FALSE;
END Synchronize_Dimensions;


/*******************************************************************************
              Procedure to sync dimension objects lang data
********************************************************************************/

PROCEDURE Lang_Synch_BSC_To_PMF_DimObj
(
      p_level_short_name    IN VARCHAR2
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

   l_Dim_Level_Rec       BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
   l_level_id            NUMBER;
   l_error_tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;

   cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');

BEGIN

    SELECT DIM_LEVEL_ID
    INTO l_level_id
    FROM BSC_SYS_DIM_LEVELS_B
    WHERE SHORT_NAME = p_level_short_name;

    l_Dim_Level_Rec.Dimension_Short_Name := p_level_short_name;

    FOR cd in installed_languages_cursor LOOP
        SELECT NAME, HELP, LANGUAGE, SOURCE_LANG
        INTO l_Dim_Level_Rec.Dimension_Name,
             l_Dim_Level_Rec.Description,
             l_Dim_Level_Rec.Language,
             l_Dim_Level_Rec.Source_Lang
        FROM BSC_SYS_DIM_LEVELS_TL
        WHERE DIM_LEVEL_ID = l_level_id
        AND   LANGUAGE = cd.language_code;

        BIS_DIMENSION_LEVEL_PUB.Trans_DimObj_By_Given_Lang
        (
                    p_commit                =>  FND_API.G_FALSE
                ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
                ,   p_Dimension_Level_Rec   =>  l_Dim_Level_Rec
                ,   x_return_status         =>  x_return_status
                ,   x_error_Tbl             =>  x_error_tbl
        );
    END LOOP;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_Tbl;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;

      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Lang_Synch_BSC_To_PMF_Dim'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Lang_Synch_BSC_To_PMF_DimObj;



/*******************************************************************************
              Procedure to sync dimension objects lang data
********************************************************************************/

PROCEDURE Lang_Synch_PMF_To_BSC_DimObj
(
       p_level_short_name    IN VARCHAR2
     , x_return_status       OUT NOCOPY  VARCHAR2
     , x_msg_count           OUT NOCOPY  NUMBER
     , x_msg_data            OUT NOCOPY  VARCHAR2
)
IS

   l_Dim_Level_Rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
   l_level_id            NUMBER;

   cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');

BEGIN

    SELECT LEVEL_ID
    INTO l_level_id
    FROM BIS_LEVELS
    WHERE SHORT_NAME = p_level_short_name;

    l_Dim_Level_Rec.Bsc_Level_Short_Name := p_level_short_name;
    --As of now LUD is not being updated, but populated for future use
    FOR cd in installed_languages_cursor LOOP
        SELECT NAME, DESCRIPTION, LANGUAGE, LAST_UPDATE_DATE, SOURCE_LANG
        INTO l_Dim_Level_Rec.Bsc_Dim_Level_Long_Name,
             l_Dim_Level_Rec.Bsc_Dim_Level_Help,
             l_Dim_Level_Rec.Bsc_Language,
             l_Dim_Level_Rec.Bsc_Last_Update_Date,
             l_Dim_Level_Rec.Bsc_Source_Language
        FROM BIS_LEVELS_TL
        WHERE LEVEL_ID = l_level_id
        AND LANGUAGE = cd.language_code;

        BSC_DIMENSION_LEVELS_PUB.Trans_DimObj_By_Given_Lang
        (
             p_commit              =>  FND_API.G_FALSE
          ,  p_dim_level_rec       =>  l_Dim_Level_Rec
          ,  x_return_status       =>  x_return_status
          ,  x_msg_count           =>  x_msg_count
          ,  x_msg_data            =>  x_msg_data
        );

    END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END Lang_Synch_PMF_To_BSC_DimObj;


/*******************************************************************************
********************************************************************************/


PROCEDURE Lang_Synch_BSC_To_PMF_Dim
(
      p_dim_short_name  IN VARCHAR2
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

   l_Dim_Grp_Rec     BIS_DIMENSION_PUB.Dimension_Rec_Type;
   l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

   cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');

BEGIN
    FOR cd IN installed_languages_cursor LOOP

        SELECT SHORT_NAME, NAME, LANGUAGE, LAST_UPDATE_DATE, SOURCE_LANG
        INTO l_Dim_Grp_Rec.Dimension_Short_Name,
             l_Dim_Grp_Rec.Dimension_Name,
             l_Dim_Grp_Rec.Language,
             l_Dim_Grp_Rec.Last_Update_Date,
             l_Dim_Grp_Rec.Source_Lang
        FROM  BSC_SYS_DIM_GROUPS_TL
        WHERE SHORT_NAME = p_dim_short_name
        AND   LANGUAGE = cd.language_code;

        BIS_DIMENSION_PUB.Translate_Dim_By_Given_Lang
        (
               p_commit                =>  FND_API.G_FALSE
           ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
           ,   p_Dimension_Rec         =>  l_Dim_Grp_Rec
           ,   x_return_status         =>  x_return_status
           ,   x_error_Tbl             =>  x_error_tbl
        );

    END LOOP;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_Tbl;
      if installed_languages_cursor%ISOPEN THEN
          CLOSE installed_languages_cursor;
      end if;

      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Lang_Synch_BSC_To_PMF_Dim'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END Lang_Synch_BSC_To_PMF_Dim;


/*******************************************************************************
********************************************************************************/


PROCEDURE Lang_Synch_PMF_To_BSC_Dim
(
      p_dim_short_name  IN VARCHAR2
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2

)
IS

   l_Dim_Grp_Rec    BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
   l_dim_id             NUMBER;

   cursor installed_languages_cursor is
   select L.language_code
   from FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and language_code <> userenv('LANG');


BEGIN

    SELECT DIMENSION_ID
    INTO l_dim_id
    FROM  BIS_DIMENSIONS
    WHERE SHORT_NAME = p_dim_short_name;

    l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Short_Name := p_dim_short_name;

    FOR cd IN installed_languages_cursor LOOP
        SELECT NAME, LANGUAGE, LAST_UPDATE_DATE, SOURCE_LANG
        INTO l_Dim_Grp_Rec.Bsc_Dim_Level_Group_Name,
             l_Dim_Grp_Rec.Bsc_Language,
             l_Dim_Grp_Rec.Bsc_Last_Update_Date,
             l_Dim_Grp_Rec.Bsc_Source_Language
                FROM BIS_DIMENSIONS_TL
        WHERE DIMENSION_ID = l_dim_id
        AND LANGUAGE = cd.language_code;

        BSC_DIMENSION_GROUPS_PUB.Translate_Dim_By_Given_Lang
        (
                 p_commit              =>  FND_API.G_FALSE
              ,  p_Dim_Grp_Rec         =>  l_Dim_Grp_Rec
              ,  x_return_status       =>  x_return_status
              ,  x_msg_count           =>  x_msg_count
              ,  x_msg_data            =>  x_msg_data
        );

    END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if installed_languages_cursor%ISOPEN THEN
        CLOSE installed_languages_cursor;
    end if;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;

END Lang_Synch_PMF_To_BSC_Dim;




/*******************************************************************************
********************************************************************************/

--  Function to give all tabs and kpis access to Performance Management User


FUNCTION Add_Access_To_Tabs_Kpis
(
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;
    l_Bsc_Kpi_Entity_Rec            BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
    l_mgr_resp                      NUMBER ;
    l_pmd_resp                      NUMBER ;
    l_count                         NUMBER ;
    l_valid                         NUMBER ;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    x_return_status                 VARCHAR2(5000);
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(5000);
    CURSOR c_get_upgrade_tabs (c_mgr_resp NUMBER) IS
        SELECT * FROM BSC_USER_TAB_ACCESS
        WHERE RESPONSIBILITY_ID = c_mgr_resp;

    CURSOR c_get_upgrade_kpis(c_mgr_resp NUMBER) IS
        SELECT * FROM BSC_USER_KPI_ACCESS
        WHERE RESPONSIBILITY_ID = c_mgr_resp;
BEGIN
    SELECT responsibility_id
    INTO   l_pmd_resp
    FROM   FND_RESPONSIBILITY
    WHERE  responsibility_key = 'BSC_PMD_USER';

    SELECT responsibility_id
    INTO   l_mgr_resp
    FROM   FND_RESPONSIBILITY
    WHERE  responsibility_key = 'BSC_Manager';

    FOR c_tab_recs IN c_get_upgrade_tabs(l_mgr_resp) LOOP
        SELECT COUNT(1)
        INTO   l_count
        FROM   BSC_USER_TAB_ACCESS
        WHERE  TAB_ID = c_tab_recs.TAB_ID
        AND    RESPONSIBILITY_ID = l_pmd_resp;

        SELECT COUNT(1)
        INTO   l_valid
        FROM   BSC_TABS_B
        WHERE  TAB_ID = c_tab_recs.TAB_ID;
        IF ( l_count = 0 and l_valid > 0 ) THEN
            l_Bsc_Tab_Entity_Rec.Bsc_Responsibility_Id :=  l_pmd_resp;
            l_Bsc_Tab_Entity_Rec.Bsc_Tab_Id            :=  c_tab_recs.TAB_ID;
            l_Bsc_Tab_Entity_Rec.Bsc_Created_By        :=  c_tab_recs.CREATED_BY;
            l_Bsc_Tab_Entity_Rec.Bsc_Last_Updated_By   :=  c_tab_recs.CREATED_BY;
            l_Bsc_Tab_Entity_Rec.Bsc_Last_Update_Login :=  c_tab_recs.LAST_UPDATE_LOGIN;
            l_Bsc_Tab_Entity_Rec.Bsc_Resp_End_Date     :=  c_tab_recs.END_DATE;
            BEGIN
                BSC_SCORECARD_PVT.Create_Tab_Access
                (   FND_API.G_FALSE
                 ,  l_Bsc_Tab_Entity_Rec
                 ,  x_return_status
                 ,  x_msg_count
                 ,  x_msg_data
                );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END IF;
    END LOOP;
    FOR c_kpi_recs IN c_get_upgrade_kpis(l_mgr_resp) LOOP
        SELECT COUNT(1)
        INTO   l_count
        FROM   BSC_USER_KPI_ACCESS
        WHERE  INDICATOR = c_kpi_recs.INDICATOR
        AND    RESPONSIBILITY_ID = l_pmd_resp;

        SELECT COUNT(1)
        INTO   l_valid
        FROM   BSC_KPIS_B
        WHERE  INDICATOR = c_kpi_recs.INDICATOR;

        IF ( l_count = 0 and l_valid > 0 ) THEN
            l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id := l_pmd_resp;
            l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id            := c_kpi_recs.INDICATOR;
            l_Bsc_Kpi_Entity_Rec.Created_By            := c_kpi_recs.CREATED_BY;
            l_Bsc_Kpi_Entity_Rec.Last_Updated_By       := c_kpi_recs.CREATED_BY;
            l_Bsc_Kpi_Entity_Rec.Last_Update_Login     := c_kpi_recs.LAST_UPDATE_LOGIN;
            l_Bsc_Kpi_Entity_Rec.Bsc_Resp_Start_Date   := c_kpi_recs.START_DATE;
            l_Bsc_Kpi_Entity_Rec.Bsc_Resp_End_Date     := c_kpi_recs.END_DATE;
            BEGIN
                BSC_KPI_PVT.Create_Kpi_User_Access
                (   FND_API.G_FALSE
                 ,  l_Bsc_Kpi_Entity_Rec
                 ,  x_return_status
                 ,  x_msg_count
                 ,  x_msg_data
                );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            -- dbms_output.put_line('tab_id = '||c_kpi_recs.INDICATOR);
        END IF;
    END LOOP;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        FND_MSG_PUB.Count_And_Get
        ( p_count    =>      l_msg_count
         ,p_data     =>      l_msg_data
        );
        IF (l_msg_data IS NULL) THEN
            l_msg_data := SQLERRM;
        end if;
        x_error_msg := l_msg_data;
        RETURN FALSE;
END Add_Access_To_Tabs_Kpis;

/*******************************************************************************
********************************************************************************/

-- Upgrade for BS 5.1.0 to 5.1.1 to seperate Summization and UI Features(Max Fetching) Profiles
FUNCTION Upgrade_Advanced_Profile(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

    l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_return_status   boolean;
    l_summerization_value VARCHAR2(240);
    l_ui_features_value VARCHAR2(240);

BEGIN

    l_ui_features_value := FND_PROFILE.value('BSC_ADVANCED_UI_FEATURES');

    IF l_ui_features_value IS NULL THEN -- first time setup value

        l_summerization_value :=FND_PROFILE.value('BSC_ADVANCED_SUMMARIZATION_LEVEL');
        IF l_summerization_value IS NULL THEN
            l_return_status := FND_PROFILE.save('BSC_ADVANCED_UI_FEATURES','No', 'SITE');
        ELSE
            l_return_status := FND_PROFILE.save('BSC_ADVANCED_UI_FEATURES','Yes', 'SITE');
        END IF;

        COMMIT;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        x_error_msg := SQLERRM;
        RETURN FALSE;
END Upgrade_Advanced_Profile;

/*******************************************************************************
********************************************************************************/

FUNCTION get_next_entry_sequence
(
    p_Menu_Id      FND_MENUS.menu_id%TYPE
)RETURN NUMBER
IS
    l_count     NUMBER;
BEGIN

   SELECT NVL(MAX(Entry_Sequence),0)Entry_Sequence
   INTO   l_count
   FROM   FND_MENU_ENTRIES
   WHERE  Menu_Id =p_Menu_Id;

   RETURN  (l_count + 1);

END get_next_entry_sequence;


-- Upgrade for BS 5.1.0 to 5.1.1 to sync up Lanuchpad from BSC_Manger to other pmd resps.
FUNCTION Add_Access_To_Launchpads
(
   p_mgr_resp                      NUMBER,
   p_pmd_resp                      NUMBER,
   x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_count                         NUMBER ;
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(2000);
    x_return_status                 VARCHAR2(5000);
    x_msg_count                     NUMBER;
    x_msg_data                      VARCHAR2(5000);

    l_mgr_menu                      NUMBER ;
    l_pmd_menu                      NUMBER ;
    h_launchpad_id                  NUMBER ;
    h_launchpad_desc                VARCHAR2(240);
    h_user_id                       NUMBER ;


   CURSOR c_synch_launchpad IS
   SELECT A.MENU_ID
       ,  A.DESCRIPTION
       ,  A.CREATED_BY
   FROM   FND_MENUS_VL         A
       ,  FND_MENU_ENTRIES     B
   WHERE A.MENU_NAME LIKE 'BSC_LAUNCHPAD_%'
   AND   A.MENU_ID  =  B.SUB_MENU_ID
   AND   B.MENU_ID  =  l_mgr_menu;

BEGIN
    --BSC_Manager
    SELECT MENU_ID
    INTO l_mgr_menu
    FROM FND_RESPONSIBILITY_VL
    WHERE RESPONSIBILITY_ID = p_mgr_resp;

    --BSC_PMD_USER/BSC_DESIGNER (called two time from bscup.sql)
    --once for BSC_PMD_USER and once for BSC_DESIGNER
    SELECT MENU_ID
    INTO l_pmd_menu
    FROM FND_RESPONSIBILITY_VL
    WHERE RESPONSIBILITY_ID = p_pmd_resp;


    FOR cd IN c_synch_launchpad LOOP
      SELECT COUNT(0)
      INTO   l_count
      FROM   FND_MENU_ENTRIES
      WHERE  MENU_ID     = l_pmd_menu
      AND    SUB_MENU_ID = cd.menu_id;

      IF (l_count = 0) THEN
         BSC_LAUNCH_PAD_PVT.INSERT_APP_MENU_ENTRIES_VB
        (    X_Menu_Id           => l_pmd_menu
       , X_Entry_Sequence    => get_next_entry_sequence(l_pmd_menu)
       , X_Sub_Menu_Id       => cd.menu_id
       , X_Function_Id       => NULL
       , X_Grant_Flag        =>'Y'
       , X_Prompt            => NULL
       , X_Description       => cd.description
       , X_User_Id           => cd.created_by
        );
      END IF;
    END LOOP;

RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN

        IF(c_synch_launchpad%ISOPEN) THEN
         CLOSE c_synch_launchpad;
        END IF;

        ROLLBACK;
        FND_MSG_PUB.Count_And_Get
        ( p_count    =>      l_msg_count
         ,p_data     =>      l_msg_data
        );
        IF (l_msg_data IS NULL) THEN
            l_msg_data := SQLERRM;
        end if;
        x_error_msg := l_msg_data;
        RETURN FALSE;
END Add_Access_To_Launchpads;


/*******************************************************************************
********************************************************************************/

FUNCTION Upgrade_Bsc_Pmf_dim_Views(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_return_status  VARCHAR2(3000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(3000);
BEGIN
      -- ADRAO modified signature for modularization, Bug#3739872
      -- NULL indicates process 'all' the dimension object views
      BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View
      (     p_Short_Name        =>  NULL
          , x_return_status     =>  l_return_status
          , x_msg_count         =>  l_msg_count
          , x_msg_data          =>  l_msg_data
      );
    COMMIT;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END Upgrade_Bsc_Pmf_dim_Views;

/*******************************************************************************
********************************************************************************/

FUNCTION Remove_Bsc_Pmf_Edw_dim_Views(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_return_status  VARCHAR2(3000);
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(3000);
BEGIN
      BSC_BIS_DIM_OBJ_PUB.Remove_BSC_PMF_EDW_Dim_View
      (     x_return_status     =>  l_return_status
          , x_msg_count         =>  l_msg_count
          , x_msg_data          =>  x_error_msg
      );
    COMMIT;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END Remove_Bsc_Pmf_Edw_dim_Views;

/********************************************************************************************
  This procedure identifies the BSC Measures with application_ids -1 and updates them
  to 271.
********************************************************************************************/
FUNCTION update_Bsc_Application_Ids
(
    x_error_msg  OUT NOCOPY VARCHAR2
)RETURN BOOLEAN IS
    l_return_Status     BOOLEAN;
    CURSOR c_update_appid IS
    SELECT bisapp.indicator_id
    FROM   bis_application_measures bisapp,
           bis_indicators  bisindic,
           bsc_sys_datasets_vl bsc
    WHERE  bisapp.indicator_id = bisindic.indicator_id
    AND    bisindic.dataset_id = bsc.dataset_id
    AND    bsc.source= 'BSC'
    AND    (bisapp.application_id = -1 OR bisapp.application_id IS NULL);

BEGIN
   l_return_Status := TRUE;
   FOR cd IN c_update_appid LOOP
        UPDATE bis_application_measures
        SET application_id = 271
        where indicator_id = cd.indicator_id;
   END LOOP;

   COMMIT;
   RETURN l_return_Status;
EXCEPTION
    WHEN OTHERS THEN
        IF(c_update_appid%ISOPEN) THEN
            CLOSE c_update_appid;
        END IF;
        ROLLBACK;
        x_error_msg := SQLERRM;
    RETURN FALSE;
END update_Bsc_Application_Ids;



/************************************************************************
 Fucntion   : Validate_And_Get_Short_Name
 Parameters : p_Short_Name  --> Measure Short Name
 Description    :This function will return the unique measure short_name
 Author     : Ashankar fix for the bug 4054812
/************************************************************************/

FUNCTION Validate_And_Get_Short_Name
(
 p_Short_Name     IN   BIS_INDICATORS.short_name%TYPE
) RETURN VARCHAR2
IS
    l_measure_short_name    BIS_INDICATORS.short_name%TYPE;
    l_temp_var              BIS_INDICATORS.short_name%TYPE;
    l_alias                 VARCHAR2(5);
    l_flag                  BOOLEAN;
    l_count                 NUMBER;

BEGIN
    l_flag              :=  TRUE;
    l_alias             :=  NULL;
    l_temp_var          :=  p_Short_Name;

    WHILE (l_flag) LOOP
        SELECT count(1)
        INTO   l_count
        FROM   BIS_INDICATORS
        WHERE  UPPER(TRIM(Short_Name)) = UPPER(TRIM(l_temp_var));

        IF (l_count = 0) THEN
            l_flag               :=  FALSE;
            l_measure_short_name :=  l_temp_var;
        END IF;
        l_alias         :=  BSC_UTILITY.get_Next_Alias(l_alias);
        l_temp_var      :=  l_measure_short_name||l_alias;
    END LOOP;

    RETURN  l_measure_short_name;

EXCEPTION
        WHEN OTHERS THEN
         RETURN l_measure_short_name;

END Validate_And_Get_Short_Name;


/*******************************************************************************
    Refresh_Measure_Col_Names API ensures that all the PMF measures that were
    generated using SHORT_NAME for BSC_SYS_MEASURES.MEASURE_COL is modified to
    more intelligible names which is ideally derived from the name of the measure.

    These columns that will be generated will ensure that the MEASURE_COL is derived
    from NAME of the measure uniquely. This API as standalone does not have any
    impact on the Existing source measure part of the world. This API should be used
    in combination with Gen_Existing_Measure_Cols to ensure corresponding
    measure columns are generated for the PMF Measure (Existing SourcE)
    Added as part of Enhancement Bug#4239216
********************************************************************************/
PROCEDURE Refresh_Measure_Col_Names
IS
    CURSOR cPMFMeasures IS
        SELECT
            M.MEASURE_ID,
            M.MEASURE_COL,
            M.SOURCE,
            I.SHORT_NAME,
            I.DATASET_ID,
            I.NAME
          FROM
            BSC_SYS_MEASURES M,
          BSC_SYS_DATASETS_VL D,
            BIS_INDICATORS_VL I
          WHERE
            M.MEASURE_ID = D.MEASURE_ID1 AND
            D.DATASET_ID=I.DATASET_ID  AND
            M.SOURCE = BSC_BIS_MEASURE_PUB.c_PMF AND
            M.MEASURE_COL = I.SHORT_NAME  ORDER BY I.DATASET_ID;
        /*SELECT
          M.MEASURE_ID,
          M.MEASURE_COL,
          M.SOURCE,
          I.SHORT_NAME,
          I.DATASET_ID,
          I.NAME
        FROM
          BSC_SYS_MEASURES M,
          BIS_INDICATORS_VL I
        WHERE
          M.SHORT_NAME = I.SHORT_NAME  AND
          M.SOURCE = BSC_BIS_MEASURE_PUB.c_PMF  AND
          M.MEASURE_COL = I.SHORT_NAME  ORDER BY I.DATASET_ID;*/
    l_Measure_Col       BSC_SYS_MEASURES.MEASURE_COL%TYPE;
    l_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
    l_Return_Status     VARCHAR2(1);
    l_Msg_Count         NUMBER;
    l_Msg_Data          VARCHAR2(2000);
BEGIN
    SAVEPOINT SP_REFRESH_MEAS;
    FOR cPMFM IN cPMFMeasures LOOP
        l_Measure_Col := BSC_BIS_MEASURE_PUB.Get_Measure_Col(
                               cPMFM.NAME,
                               cPMFM.SOURCE,
                               cPMFM.MEASURE_ID,
                               cPMFM.SHORT_NAME
                          );
        IF(l_Measure_Col IS NOT NULL) THEN
            l_Dataset_Rec.Bsc_Measure_Id  := cPMFM.MEASURE_ID;
            l_Dataset_Rec.Bsc_Measure_Col := l_Measure_Col;
            BSC_DATASETS_PVT.Update_Measures(
                 p_commit        => FND_API.G_FALSE
                ,p_Dataset_Rec   => l_Dataset_Rec
                ,x_return_status => l_Return_Status
                ,x_msg_count     => l_Msg_Count
                ,x_msg_data      => l_Msg_Data
            );
            IF ((l_Return_Status IS NOT NULL) AND (l_Return_Status <> FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SP_REFRESH_MEAS;
        --x_error_msg := SQLERRM;
        IF (l_Msg_Data IS NULL) THEN
            l_Msg_Data  := SQLERRM;
        END IF;
        BSC_MESSAGE.Add (
              x_message => l_Msg_Data
            , x_source  => 'Refresh_Measure_Col_Names'
            , x_mode    => 'I'
        );
END Refresh_Measure_Col_Names;
/*******************************************************************************
    This PL/SQL API has been designer to generate new DB Column entries in
    BSC_DB_MEASURE_COLS_TL table, which will be used by Generate Database to
    directly run on exisitng type of measures.
    This API should not be called without calling Refresh_Measure_Col_Names,
    Though this API can run independently, it will generate column that are
    available directly in BSC_SYS_MEASURES.MEASURE_COL (which ideally may not
    be intelligible as a TABLE COLUMN). Hence it is *recommened* that
    the API Refresh_Measure_Col_Names is run before this API is run.
    Added as part of Enhancement Bug#4239216
********************************************************************************/
PROCEDURE Gen_Existing_Measure_Cols
IS
    CURSOR cPMFMeasures IS
        SELECT
          D.MEASURE_ID1,
          M.MEASURE_COL,
          D.SOURCE
        FROM
          BSC_SYS_DATASETS_B D,
          BSC_SYS_MEASURES M
        WHERE
          D.SOURCE = BSC_BIS_MEASURE_PUB.c_PMF AND
          M.MEASURE_ID = D.MEASURE_ID1;
    l_Measure_Col       BSC_SYS_MEASURES.MEASURE_COL%TYPE;
    l_Return_Status     VARCHAR2(1);
    l_Msg_Count         NUMBER;
    l_Msg_Data          VARCHAR2(2000);
    l_Count             NUMBER;
    l_Measure_Group_Id  BSC_DB_MEASURE_COLS_TL.MEASURE_GROUP_ID%TYPE;
    l_Projection_Id     BSC_DB_MEASURE_COLS_TL.PROJECTION_ID%TYPE;
    l_Measure_Type      BSC_DB_MEASURE_COLS_TL.MEASURE_TYPE%TYPE;
BEGIN
    SAVEPOINT SP_GEN_EXISTING;
    l_Count := 0; -- BSC_DB_MEASURE_COLS_PKG
    -- setup defaults
    l_Measure_Group_Id  := -1; -- default group
    l_Projection_Id     := 0; -- Indicates no projection
    l_Measure_Type      := 1; -- activity type by default
    FOR cPMFM IN cPMFMeasures LOOP
        SELECT COUNT(1) INTO l_Count
        FROM   BSC_DB_MEASURE_COLS_VL B
        WHERE  UPPER(B.MEASURE_COL) = UPPER(cPMFM.MEASURE_COL);
        -- need to create a new MEASURE COULIMN
        IF(l_Count = 0) THEN
            BEGIN
                BSC_DB_MEASURE_COLS_PKG.INSERT_ROW (
                    x_Measure_Col      => cPMFM.MEASURE_COL
                  , x_Measure_Group_Id => l_Measure_Group_Id
                  , x_Projection_Id    => l_Projection_Id
                  , x_Measure_Type     => l_Measure_Type
                  , x_Help             => cPMFM.MEASURE_COL
                );
            EXCEPTION
                WHEN OTHERS THEN
                    BSC_MESSAGE.Add (
                          x_message => SQLERRM || '  -  ERROR ADDING COL : ' || cPMFM.MEASURE_COL
                        , x_source  => 'BSC_DB_MEASURE_COLS_PKG.INSERT_ROW'
                        , x_mode    => 'I'
                    );
            END;
        END IF;
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SP_GEN_EXISTING;
        IF (l_Msg_Data IS NULL) THEN
            l_Msg_Data := SQLERRM;
        END IF;
        BSC_MESSAGE.Add (
              x_message => l_Msg_Data
            , x_source  => 'Gen_Existing_Measure_Cols'
            , x_mode    => 'I'
        );
END Gen_Existing_Measure_Cols;


PROCEDURE sync_dim_object_mappings
( p_dim_short_name  IN VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

  CURSOR c_bsc_rel is
    SELECT bsc_lvl.short_name, bis_dim.dimension_id
      FROM bsc_sys_dim_groups_vl bsc_dim,
           bsc_sys_dim_levels_b bsc_lvl,
     bsc_sys_dim_levels_by_group lvl_by_grp,
     bis_dimensions bis_dim
      WHERE bsc_dim.dim_group_id = lvl_by_grp.dim_group_id
      AND   bsc_lvl.dim_level_id = lvl_by_grp.dim_level_id
      /* AND bsc_dim.dim_group_id = bis_dim.dim_grp_id   cannot use since dim_group_id is not updated on BIS side yet */
      AND   bsc_dim.short_name = bis_dim.short_name      /* can assume here since short name are same on both side */
      AND   bsc_dim.short_name = p_dim_short_name ;

BEGIN

  FOR l_bsc_rel_rec IN c_bsc_rel LOOP

    UPDATE bis_levels
      SET dimension_id = l_bsc_rel_rec.dimension_id
      WHERE short_name = l_bsc_rel_rec.short_name
      AND dimension_id = -1 ;

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.sync_dim_object_mappings'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
END sync_dim_object_mappings;

FUNCTION Update_Dim_Hide_Properties (
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  TYPE t_short_names  IS TABLE OF BIS_DIMENSIONS.SHORT_NAME%TYPE INDEX BY BINARY_INTEGER;
  l_dim_short_names t_short_names;
  l_row_count NUMBER := 0;

  CURSOR cr_internal_dimensions IS
  SELECT
    short_name
  FROM
    bis_dimensions
  WHERE
    (bsc_utility.Is_Internal_AG_Dim(short_name) IS NOT NULL OR
     bsc_utility.Is_Internal_BIS_Import_Dim(short_name) IS NOT NULL OR
     bsc_utility.Is_Internal_WKPI_Dim(short_name) IS NOT NULL)
    AND bis_util.is_Seeded(created_by,'T','F') = 'F'
    AND NVL(hide_in_design,'F') = 'F';
BEGIN
  FND_MSG_PUB.Initialize;
  SAVEPOINT BisHideInDesignUpdate;
  OPEN cr_internal_dimensions;
  LOOP
    FETCH cr_internal_dimensions
    BULK COLLECT INTO l_dim_short_names
    LIMIT 100;
    EXIT WHEN l_row_count = cr_internal_dimensions%ROWCOUNT;
    l_row_count := cr_internal_dimensions%ROWCOUNT;

    FORALL i in 1..l_dim_short_names.COUNT
      UPDATE BIS_DIMENSIONS
      SET HIDE_IN_DESIGN = FND_API.G_TRUE
      WHERE SHORT_NAME = l_dim_short_names(i);
  END LOOP;

  CLOSE cr_internal_dimensions;
  x_error_msg :=  'BSC_UPGRADES.Update_Dim_Hide_Properties Successfully Completed';
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF (cr_internal_dimensions%ISOPEN) THEN
      CLOSE cr_internal_dimensions;
    END IF;
    ROLLBACK TO BisHideInDesignUpdate;
    IF (x_error_msg IS NOT NULL) THEN
       x_error_msg      :=  x_error_msg||' -> BSC_UPGRADES.Update_Dim_Hide_Properties ';
    ELSE
       x_error_msg      :=  SQLERRM||' at BSC_UPGRADES.Update_Dim_Hide_Properties ';
    END IF;
    RETURN FALSE;
END Update_Dim_Hide_Properties;

FUNCTION Hide_Unused_Import_Dim(
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  TYPE t_short_names  IS TABLE OF BSC_SYS_DIM_GROUPS_VL.SHORT_NAME%TYPE INDEX BY BINARY_INTEGER;
  l_dim_short_names t_short_names;
  l_row_count NUMBER := 0;
  l_region_count NUMBER;

  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(3200);

  CURSOR cr_pmf_import_dims IS
  SELECT
    short_name
  FROM
    bsc_sys_dim_groups_vl grp
  WHERE
    bsc_bis_dimension_pub.get_dimension_source(short_name)='PMF' AND
    short_name LIKE 'DGRP_%' AND
    name = short_name AND
    bis_util.is_seeded(created_by,'T','F') = 'F' AND
    (SELECT COUNT(1) FROM bsc_kpi_dim_groups WHERE dim_group_id = grp.dim_group_id) = 0;
BEGIN
  FND_MSG_PUB.Initialize;
  SAVEPOINT BisUpdateImportDim;
  OPEN cr_pmf_import_dims;
  LOOP
    FETCH cr_pmf_import_dims
    BULK COLLECT INTO l_dim_short_names
    LIMIT 100;
    EXIT WHEN l_row_count = cr_pmf_import_dims%ROWCOUNT;
    l_row_count := cr_pmf_import_dims%ROWCOUNT;

    FOR i in 1..l_dim_short_names.COUNT LOOP
      UPDATE BIS_DIMENSIONS
      SET HIDE_IN_DESIGN = FND_API.G_TRUE
      WHERE SHORT_NAME = l_dim_short_names(i);
    END LOOP;
  END LOOP;
  CLOSE cr_pmf_import_dims;
  x_error_msg :=  'BSC_UPGRADES.Hide_Unused_Pmf_Import_Dim Successfully Completed';
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF (cr_pmf_import_dims%ISOPEN) THEN
      CLOSE cr_pmf_import_dims;
    END IF;
    ROLLBACK TO BisUpdateImportDim;
    IF (x_error_msg IS NOT NULL) THEN
       x_error_msg      :=  x_error_msg||' -> BSC_UPGRADES.Hide_Unused_Import_Dim';
    ELSE
       x_error_msg      :=  SQLERRM||' at BSC_UPGRADES.Hide_Unused_Import_Dim';
    END IF;
    RETURN FALSE;
END Hide_Unused_Import_Dim;

PROCEDURE Drop_Update_Dim_Obj_Views(
    p_Dim_Obj_Sht_Name      IN  OUT NOCOPY  FND_TABLE_OF_VARCHAR2_30
,   x_return_status         OUT NOCOPY  VARCHAR2
,   x_msg_count             OUT NOCOPY  NUMBER
,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_sql VARCHAR2(2000);
  l_level_view_name bsc_sys_dim_levels_b.level_view_name%TYPE;
  l_table_type      bsc_sys_dim_levels_b.table_type%TYPE;

  CURSOR c_dim_obj(p_sht_name VARCHAR2) IS
  SELECT level_view_name,table_type
  FROM bsc_sys_dim_levels_b
  WHERE short_name = p_sht_name;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i in p_Dim_Obj_Sht_Name.FIRST..p_Dim_Obj_Sht_Name.LAST
  LOOP
    l_level_view_name := NULL;
    OPEN c_dim_obj(p_Dim_Obj_Sht_Name(i));
    FETCH c_dim_obj INTO l_level_view_name,l_table_type;
    CLOSE c_dim_obj;
    IF (l_level_view_name IS NOT NULL AND l_table_type = 1) THEN
      l_sql := 'DROP VIEW '||l_level_view_name;
      BEGIN
        BSC_APPS.Do_DDL(l_sql, AD_DDL.DROP_VIEW, l_level_view_name);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      UPDATE bsc_sys_dim_levels_b
      SET table_type = -1
      WHERE short_name = p_Dim_Obj_Sht_Name(i);
    END IF;
  END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Drop_Update_Dim_Obj_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Drop_Update_Dim_Obj_Views ';
        END IF;
END Drop_Update_Dim_Obj_Views;

end BSC_UPGRADES;

/
