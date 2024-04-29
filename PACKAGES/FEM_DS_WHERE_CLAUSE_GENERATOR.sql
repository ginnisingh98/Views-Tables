--------------------------------------------------------
--  DDL for Package FEM_DS_WHERE_CLAUSE_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DS_WHERE_CLAUSE_GENERATOR" AUTHID CURRENT_USER AS
--$Header: FEMDSWGS.pls 120.2 2006/08/08 23:08:32 gcheng ship $

G_LEDGER_REQD_FOR_LEDG_TABS   VARCHAR2(30) := 'FEM_LEDG_REQD_FOR_LEDG_TAB';
G_NO_EFFECTIVE_CAL_PERIOD     VARCHAR2(30) := 'FEM_NO_EFFECTIVE_CAL_PERIOD';
G_DUPLICATE_INPUT_LIST_ENTRY  VARCHAR2(30) := 'FEM_DUP_INPUT_LIST_ENTRY';
G_MACRO_DATASET               VARCHAR2(20) := 'DATASET';
G_MACRO_EFF_CAL_PERIOD        VARCHAR2(20) := 'EFF_CAL_PERIOD';

DEF_FOLDER_NAME	     FEM_FOLDERS_VL.FOLDER_NAME%TYPE;
DEF_OBJECT_ID	     FEM_OBJECT_CATALOG_B.OBJECT_ID%TYPE;
DEF_OBJECT_NAME	     FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
DEF_OBJ_DEF_ID	     FEM_OBJECT_DEFINITION_B.OBJECT_ID%TYPE;
DEF_IODD_DEF_ID      FEM_DS_INPUT_OUTPUT_DEFS.DATASET_IO_OBJ_DEF_ID%TYPE;
DEF_DATASET_CODE     FEM_DATASETS_VL.DATASET_CODE%TYPE;
DEF_DATASET_NAME     FEM_DATASETS_VL.DATASET_NAME%TYPE;
DEF_CAL_PERIOD_ID    FEM_CAL_PERIODS_VL.CAL_PERIOD_ID%TYPE;
DEF_CAL_PERIOD_NAME  FEM_CAL_PERIODS_VL.CAL_PERIOD_NAME%TYPE;
DEF_DIM_GRP_ID	     FEM_DIMENSION_GRPS_VL.DIMENSION_GROUP_ID%TYPE;
DEF_DIM_GRP_NAME     FEM_DIMENSION_GRPS_VL.DIMENSION_GROUP_NAME%TYPE;
DEF_ABS_CAL_PERIOD_FLAG FEM_DS_INPUT_LISTS.ABSOLUTE_CAL_PERIOD_FLAG%TYPE;
DEF_REL_CAL_PERIOD_OFFSET FEM_DS_INPUT_LISTS.RELATIVE_CAL_PERIOD_OFFSET%TYPE;

TYPE List_B_Record IS
     RECORD(X_Dataset_Code DEF_DATASET_CODE%TYPE
           ,X_Cal_Period_ID DEF_CAL_PERIOD_ID%TYPE);
TYPE List_B IS TABLE of List_B_Record INDEX BY BINARY_INTEGER;

TYPE Skipped_Data_List_Entries_Rec IS RECORD
  (Input_Dataset_Name DEF_DATASET_NAME%TYPE
  ,Absolute_Cal_Period_Flag DEF_ABS_CAL_PERIOD_FLAG%TYPE
  ,Abs_Cal_Period_Name DEF_CAL_PERIOD_NAME%TYPE
  ,Relative_Dim_Grp_Name DEF_DIM_GRP_NAME%TYPE
  ,Relative_Cal_Period_Offset DEF_REL_CAL_PERIOD_OFFSET%TYPE
  ,Eff_Cal_Period_Name DEF_CAL_PERIOD_NAME%TYPE);

TYPE Skipped_Data_List_Entries_Tab IS TABLE OF Skipped_Data_List_Entries_Rec INDEX BY BINARY_INTEGER;


PROCEDURE FEM_Gen_DS_WClause_PVT(
                              p_api_version                 IN             NUMBER
                             ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                             ,x_return_status               OUT   NOCOPY   VARCHAR2
                             ,x_msg_count                   OUT   NOCOPY   NUMBER
                             ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                             ,p_DS_IO_Def_ID                IN             NUMBER
                             ,p_Output_Period_ID            IN             NUMBER
                             ,p_Table_Alias                 IN             VARCHAR2 DEFAULT NULL
                             ,p_Table_Name                  IN             VARCHAR2
                             ,p_Ledger_ID                   IN             NUMBER DEFAULT NULL
                             ,p_where_clause                OUT   NOCOPY   LONG
                             );

PROCEDURE FEM_GetOutputDS_PVT(p_api_version                 IN             NUMBER
                             ,p_init_msg_list               IN             VARCHAR2 := FND_API.G_FALSE
                             ,p_encoded                     IN             VARCHAR2 := FND_API.G_TRUE
                             ,x_return_status               OUT   NOCOPY   VARCHAR2
                             ,x_msg_count                   OUT   NOCOPY   NUMBER
                             ,x_msg_data                    OUT   NOCOPY   VARCHAR2
                             ,p_DSGroup_Def_ID              IN             NUMBER
                             ,x_Output_DS_ID                OUT   NOCOPY   NUMBER
                             ,p_pop_messages_at_exit        IN             VARCHAR2 := FND_API.G_TRUE  );

end FEM_DS_WHERE_CLAUSE_GENERATOR;
--end FEM_DS_WHERE_CLAUSE_G_RJK;

 

/
