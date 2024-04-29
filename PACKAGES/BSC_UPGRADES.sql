--------------------------------------------------------
--  DDL for Package BSC_UPGRADES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPGRADES" AUTHID CURRENT_USER AS
  /* $Header: BSCUPGRS.pls 120.4 2006/03/31 04:13:42 akoduri noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCPBMSS.pls
---
---  DESCRIPTION
---     Package Specification File for Upgrade scripts
---
---  NOTES
---
---  HISTORY
---
---  26-Jun-2003 mdamle     Created
---  22-JUL-2003 Adeulgao   modified for bug fix#3047536
---  25-SEP-2003 mdamle         Bug#3160325 - Sync up measures for all installed languages
---  29-SEP-2003 adrao          Bug#3160325 - Sync up measures with source_lang
--   05-Oct-2004 ankgoel        Bug#3933075 - Moved Upgrade_Role_To_Tabs to BSCUPGNB.pls
--                              BSCUPGRB.pls will now be used for API calls from bscupmdd.sql only
---  10-JAN-2006 akoduri        Enh#4739401 Hide Dimensions and Dimension Objects
---  23-Jan-2006 akoduri        Bug#4958055  Dgrp dimension not getting deleted
---                             while disassociating from objective
---  31-MAR-06 akoduri          Bug #5048186 Dropping of BSC Views for obsoleted BIS dimension
---                             objets (Only those for which the underlying view will be dropped)
---===========================================================================

function synchronize_measures(
  x_error_msg   OUT NOCOPY VARCHAR2
) return boolean;

/*******************************************************************************
           FUNCTION TO SYNCHRONZIE DIMENSION OBJECTS BSC & PMF
********************************************************************************/
FUNCTION Synchronize_Dim_Objects
(
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

/*******************************************************************************
              FUNCTION TO SYNCHRONZIE DIMENSIONS IN BSC & PMF
********************************************************************************/
FUNCTION Synchronize_Dimensions
(
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

/*******************************************************************************
      FUNCTION TO ADD PERFORMANCE MANAGEMENT USER RESP TO ALL TABS AND KPIS
********************************************************************************/


FUNCTION Add_Access_To_Tabs_Kpis (
  x_error_msg   OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

-- mdamle 09/25/2003 - Sync up measures for all installed languages
Procedure lang_synch_BSC_To_PMF_measure(
      p_dataset_id      IN NUMBER := NULL
    , p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);

Procedure lang_synch_PMF_To_BSC_measure(
      p_indicator_id    IN NUMBER := NULL
    , p_Dataset_Rec         IN  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_msg_count       OUT NOCOPY NUMBER
    , x_msg_data        OUT NOCOPY VARCHAR2);

Procedure lang_synch_existing_measures(
      x_msg_count       OUT NOCOPY NUMBER
    , x_msg_data        OUT NOCOPY VARCHAR2
    , x_return_status   OUT NOCOPY VARCHAR2
    , x_error_tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);

function getUniqueDisplayName(
      p_dataset_name    IN VARCHAR2
    , p_language        IN VARCHAR2) return varchar2;

PROCEDURE Lang_Synch_BSC_To_PMF_DimObj
(
      p_level_short_name    IN VARCHAR2
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Lang_Synch_PMF_To_BSC_DimObj
(
      p_level_short_name    IN VARCHAR2
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
);

PROCEDURE Lang_Synch_BSC_To_PMF_Dim
(
      p_dim_short_name      IN VARCHAR2
    , x_return_status       OUT NOCOPY VARCHAR2
    , x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Lang_Synch_PMF_To_BSC_Dim
(
      p_dim_short_name      IN VARCHAR2
     ,x_return_status       OUT NOCOPY  VARCHAR2
     ,x_msg_count           OUT NOCOPY  NUMBER
     ,x_msg_data            OUT NOCOPY  VARCHAR2
);

FUNCTION Upgrade_Advanced_Profile(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION Add_Access_To_Launchpads(
    p_mgr_resp                      NUMBER
   ,p_pmd_resp                      NUMBER
   ,x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


FUNCTION Upgrade_Bsc_Pmf_dim_Views(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION Remove_Bsc_Pmf_Edw_dim_Views(
    x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

FUNCTION update_Bsc_Application_Ids
(
    x_error_msg  OUT NOCOPY VARCHAR2
)RETURN BOOLEAN;

FUNCTION Update_Dim_Hide_Properties
(
  x_error_msg   OUT NOCOPY VARCHAR2
)RETURN BOOLEAN ;

FUNCTION Hide_Unused_Import_Dim
(
  x_error_msg   OUT NOCOPY VARCHAR2
)RETURN BOOLEAN ;

PROCEDURE Drop_Update_Dim_Obj_Views(
    p_Dim_Obj_Sht_Name	    IN  OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
,   x_return_status         OUT NOCOPY  VARCHAR2
,   x_msg_count             OUT NOCOPY  NUMBER
,   x_msg_data              OUT NOCOPY  VARCHAR2
);

end BSC_UPGRADES;


 

/
