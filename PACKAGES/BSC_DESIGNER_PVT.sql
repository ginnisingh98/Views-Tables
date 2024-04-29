--------------------------------------------------------
--  DDL for Package BSC_DESIGNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DESIGNER_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCDSGS.pls 120.5 2007/04/02 18:22:48 akoduri ship $ */
  -- Bug#4587160 changed size
  C_INDICATOR     CONSTANT VARCHAR2(30)  := 'INDICATOR';
  C_KPI_TABLE     CONSTANT VARCHAR2(30)  := 'KPI_TABLE';
  C_KPI_MEAS_TABLE CONSTANT VARCHAR2(30)  := 'KPI_MEAS_TABLE';
  C_SOURCE_CODE   CONSTANT VARCHAR2(30) := 'SOURCE_CODE';
  C_SYSTEM_TABLE  CONSTANT VARCHAR2(30) := 'SYSTEM_TABLE';
  C_CAUSE_INDICATOR CONSTANT VARCHAR2(30) := 'CAUSE_INDICATOR';
  C_EFFECT_INDICATOR CONSTANT VARCHAR2(30) := 'EFFECT_INDICATOR';

  C_COLOR_CHANGE  CONSTANT NUMBER := 7;
  C_PRODUCTION    CONSTANT NUMBER := 0;

  C_MASTER_KPI    CONSTANT NUMBER := 5;
  C_SHARED_KPI    CONSTANT NUMBER := 3;
  C_NO_COPY       CONSTANT NUMBER := 0;

  C_SOURCE_TYPE_SYSTEM CONSTANT NUMBER :=  0;
  C_SOURCE_TYPE_TAB CONSTANT NUMBER := 1;
  C_SOURCE_TYPE_INDICATOR CONSTANT NUMBER :=  2;
  g_DbLink_Name all_db_links.db_link%TYPE := NULL;


-- Global types
  TYPE r_kpi_metadata_tables IS RECORD (
      table_name     VARCHAR2(30),
      table_type     VARCHAR2(30),
      table_column   VARCHAR2(30),
      duplicate_data VARCHAR2(1),
      mls_table      VARCHAR2(1),
      copy_type      NUMBER
  );

  TYPE t_kpi_metadata_tables IS TABLE OF r_kpi_metadata_tables
    INDEX BY BINARY_INTEGER;
   -- Procedures/Functions specification
   PROCEDURE Init_variables(x_indicator IN NUMBER);
   -- Deflt : Kpis Default functionality
   PROCEDURE Deflt_RefreshInvalidKpis;
   PROCEDURE Deflt_RefreshKpi(x_indicator IN NUMBER);
   PROCEDURE Deflt_Clear(x_indicator IN NUMBER);
   PROCEDURE Deflt_Update_AOPTS(x_indicator IN NUMBER);
   PROCEDURE Deflt_Update_SN_FM_CM(x_indicator IN NUMBER);
   PROCEDURE Deflt_Update_DIM_SET(x_indicator IN NUMBER);
   PROCEDURE Deflt_Update_DIM_VALUES(x_indicator IN NUMBER);
   PROCEDURE Deflt_Update_DIM_NAMES(x_indicator IN NUMBER);
   FUNCTION getItemfromMasterTable(MASTER IN VARCHAR2, ORDER_BY IN NUMBER) RETURN VARCHAR2;
   PROCEDURE Deflt_Update_PERIOD_NAME(x_indicator IN NUMBER);
   --Synch shared Kpis
   PROCEDURE Duplicate_Record_by_Indicator(x_table_name IN VARCHAR2, x_Src_kpi IN NUMBER, x_Trg_kpi IN NUMBER );
   PROCEDURE Duplicate_KPI_Metadata(x_Src_kpi IN NUMBER, x_Trg_kpi IN NUMBER,x_Shared_apply IN NUMBER,x_Shared_tables IN VARCHAR2);
   PROCEDURE BscKpisB_Update(x_Ind IN NUMBER, x_Field IN VARCHAR, x_Val IN VARCHAR);
   --Utils
   FUNCTION Decompose_Varchar_List(x_string IN VARCHAR2,    x_array IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,x_separator IN VARCHAR2) RETURN NUMBER;

   -- List Button - common dimension functions
   FUNCTION Commdim_DefltDSetisPMFbyTab(x_Tab_id IN NUMBER) RETURN VARCHAR2;

   -- Variables
   l_indicator NUMBER;
   l_ind_type NUMBER;
   l_ind_config NUMBER;
   l_current_user  NUMBER;
   l_base_lang VARCHAR2(4);

   --Records
   -- Incremental Changes Flag
    TYPE t_ActionFlag IS RECORD(
    Normal     NUMBER := 0,
    Prototype  NUMBER := 1,
    Delete_kpi     NUMBER := 2,
    GAA_Structure  NUMBER := 3,
    GAA_Update NUMBER := 4,
    GAA_Color  NUMBER := 7,
    Update_Update  NUMBER := 6,
    Update_color  NUMBER := 7
    );
     --Global Variable

   G_ActionFlag  t_ActionFlag;
  -- Incremental Changes Flag
   PROCEDURE ActionFlag_Change(x_indicator IN NUMBER, x_newflag IN NUMBER);

   -- Incremental Changes Flag
   -- Added by Aditya for PMD

   PROCEDURE Dim_Object_Change(x_dim_level_id IN NUMBER);
   PROCEDURE Dimension_Change(x_grp_short_name IN VARCHAR2, x_flag IN NUMBER);
   PROCEDURE Dimension_Change(x_dim_group_id IN NUMBER, x_flag IN NUMBER);
   FUNCTION FND_PROFILE_GET (name VARCHAR2) RETURN VARCHAR2;

  PROCEDURE ActionFlag_Change_Cascade (
    p_indicator      IN NUMBER
  , p_newflag        IN NUMBER
  , p_cascade_color  IN BOOLEAN
  );

  PROCEDURE Update_Kpi_Prototype_Flag (
    p_objective_id    IN NUMBER
  , p_kpi_measure_id  IN NUMBER := NULL
  , p_flag            IN NUMBER
  );

  PROCEDURE Copy_Records_by_Obj_Kpi_Meas (
    p_src_kpi IN NUMBER
  , p_trg_kpi IN NUMBER
  );

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
);

PROCEDURE Copy_Kpi_Metadata (
  p_commit                   IN    VARCHAR2 := FND_API.G_FALSE
, p_DbLink_Name              IN    VARCHAR2
, p_Source_Indicator         IN    NUMBER
, x_Target_Indicator         OUT   NOCOPY  NUMBER
, x_return_status            OUT   NOCOPY  VARCHAR2
, x_msg_count                OUT   NOCOPY  NUMBER
, x_msg_data                 OUT   NOCOPY  VARCHAR2
);

FUNCTION Format_DbLink_String (
  p_Sql      IN    VARCHAR2
) RETURN VARCHAR2;

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
);
END BSC_DESIGNER_PVT;

/
