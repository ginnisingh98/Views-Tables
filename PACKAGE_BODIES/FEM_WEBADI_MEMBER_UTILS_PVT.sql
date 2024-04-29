--------------------------------------------------------
--  DDL for Package Body FEM_WEBADI_MEMBER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_WEBADI_MEMBER_UTILS_PVT" AS
/* $Header: FEMVADIMEMBUTILB.pls 120.3.12010000.2 2008/12/08 13:30:03 lkiran ship $ */

------------------------------
-- Declare Global variables --
------------------------------
G_PKG_NAME CONSTANT         VARCHAR2(30) := 'FEM_WEBADI_MEMBER_UTILS_PVT' ;
--
g_session_language          VARCHAR2(30) ;
--
g_cal_pr_end_date_col_value VARCHAR2(30) ;
g_cal_pr_num_col_name_value VARCHAR2(30) ;
g_date_end_date_value       DATE;
--
--------------------------
-- Declare Object types --
--------------------------
--
-- Initialized table to clean above two collections.
g_initialized_table       FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
--
-- Declare variables to hold Map table column values.
g_dim_varchar_label_tbl     FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
g_interface_col_name_tbl    FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
g_attribute_name_tbl        FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
g_attribute_data_type_tbl   FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
g_not_null_attr_name_tbl    FND_TABLE_OF_VARCHAR2_30
  := FND_TABLE_OF_VARCHAR2_30() ;
TYPE
  g_not_null_attr_val_type
IS TABLE OF VARCHAR2(4000)
INDEX BY PLS_INTEGER ;

g_not_null_attr_val_tbl     g_not_null_attr_val_type ;

-- Bug#6446663 - Begin
g_attribute_vs_display_code FND_TABLE_OF_VARCHAR2_255
  := FND_TABLE_OF_VARCHAR2_255() ;
g_version_display_code      FND_TABLE_OF_VARCHAR2_255
  := FND_TABLE_OF_VARCHAR2_255() ;
-- Bug#6446663 - End
--
--
/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information used during only development.
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  --DBMS_OUTPUT.Put_Line(p_message) ;
  null;
END pd ;
/*---------------------------------------------------------------------------*/

/*===========================================================================+
 |                             PROCEDURE log_m                               |
 +===========================================================================*/
-- API to insert debug information in autonomous transaction mode.
-- Meant for development purposes only.
PROCEDURE log_m
( p_debug_message IN VARCHAR2
)
IS
  --
  PRAGMA AUTONOMOUS_TRANSACTION ;
  --
BEGIN
  --
  --INSERT INTO psbtest1 VALUES (test_seq.nextval, test_seq.nextval, p_debug_message) ;
  NULL ;
  --
  --COMMIT ;
  --
END ;
/*---------------------------------------------------------------------------*/

PROCEDURE Populate_Dim_Intf_Common_Cols (
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2,
  p_interface_code               IN           VARCHAR2,
  p_dimension_varchar_label      IN           VARCHAR2,
  p_group_use_code               IN           VARCHAR2
)
IS
  --
  l_api_name    CONSTANT         VARCHAR2(30) := 'Populate_Dim_Intf_Common_Cols';
  l_api_version CONSTANT         NUMBER := 1.0;
  --
  TYPE l_interface_col_rec IS    RECORD
    ( INTERFACE_COL_NAME         VARCHAR2(30)  ,
      INTERFACE_COL_TYPE         NUMBER(15)    ,
      DISPLAY_FLAG               VARCHAR2(1)   ,
      READ_ONLY_FLAG             VARCHAR2(1)   ,
      DATA_TYPE                  NUMBER(15)    ,
      FIELD_SIZE                 NUMBER(15)    ,
      SEGMENT_VALUE              NUMBER(15)    ,
      GROUP_NAME                 VARCHAR2(30)  ,
      VAL_TYPE                   VARCHAR2(20)  ,
      VAL_ID_COL                 VARCHAR2(240) ,
      VAL_MEAN_COL               VARCHAR2(240) ,
      VAL_DESC_COL               VARCHAR2(240) ,
      VAL_OBJ_NAME               VARCHAR2(240) ,
      VAL_ADDL_W_C               VARCHAR2(2000),
      VAL_COMPONENT_APP_ID       NUMBER(15)    ,
      VAL_COMPONENT_CODE         VARCHAR2(30)  ,
      DISPLAY_ORDER              NUMBER(15)    ,
      UPLOAD_PARAM_LIST_ITEM_NUM NUMBER(15)    ,
      SEQUENCE_NUM               NUMBER(15)    ,
      LOV_TYPE                   VARCHAR2(30)  ,
      OFFLINE_LOV_ENABLED_FLAG   VARCHAR2(1)   ,
      FND_MESSAGE_NAME           VARCHAR2(30)  ,
      USER_HINT_FND_MESSAGE_NAME VARCHAR2(30)
    );

  TYPE l_interface_cols_typ IS TABLE OF l_interface_col_rec
          INDEX BY BINARY_INTEGER;

  l_interface_cols_tbl           l_interface_cols_typ;
  l_user_id                      NUMBER(15)    := 2; --   (user name : initial setup)
  l_login_id                     NUMBER        := NVL(Fnd_Global.Login_Id, 0);

BEGIN

  --
  SAVEPOINT Dim_Intf_Common_Cols_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  -----------------------------------------------------------------------------
  -- Set up plsql table for interface column definition
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Set up for column P_INTERFACE_DIMENSION_NAME
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(1).INTERFACE_COL_NAME         := 'P_INTERFACE_DIMENSION_NAME';
  l_interface_cols_tbl(1).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(1).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(1).READ_ONLY_FLAG             := 'Y';
  l_interface_cols_tbl(1).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(1).FIELD_SIZE                 := 80;
  l_interface_cols_tbl(1).SEGMENT_VALUE              := NULL;
  l_interface_cols_tbl(1).GROUP_NAME                 := NULL;
  l_interface_cols_tbl(1).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(1).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(1).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(1).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(1).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(1).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(1).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(1).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(1).DISPLAY_ORDER              := 10; -- sequence_num * 10
  l_interface_cols_tbl(1).UPLOAD_PARAM_LIST_ITEM_NUM := 1;
  l_interface_cols_tbl(1).SEQUENCE_NUM               := 1;
  l_interface_cols_tbl(1).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(1).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(1).FND_MESSAGE_NAME           := 'FEM_ADI_DIMENSION_NAME';
  l_interface_cols_tbl(1).USER_HINT_FND_MESSAGE_NAME := NULL;

  -----------------------------------------------------
  -- Set up for column P_DIMENSION_VARCHAR_LABEL
  -----------------------------------------------------
  l_interface_cols_tbl(2).INTERFACE_COL_NAME         := 'P_DIMENSION_VARCHAR_LABEL';
  l_interface_cols_tbl(2).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(2).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(2).READ_ONLY_FLAG             := 'Y';
  l_interface_cols_tbl(2).DATA_TYPE                  := 2;
  l_interface_cols_tbl(2).FIELD_SIZE                 := 30;
  l_interface_cols_tbl(2).SEGMENT_VALUE              := NULL;
  l_interface_cols_tbl(2).GROUP_NAME                 := NULL;
  l_interface_cols_tbl(2).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(2).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(2).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(2).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(2).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(2).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(2).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(2).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(2).DISPLAY_ORDER              := 20; -- sequence_num * 10
  l_interface_cols_tbl(2).UPLOAD_PARAM_LIST_ITEM_NUM := 2;
  l_interface_cols_tbl(2).SEQUENCE_NUM               := 2;
  l_interface_cols_tbl(2).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(2).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(2).FND_MESSAGE_NAME           := 'FEM_ADI_DIMENSION_VARCHAR_LBL';
  l_interface_cols_tbl(2).USER_HINT_FND_MESSAGE_NAME := NULL;

  -----------------------------------------------------------------------------
  -- Set up for column MEMBER_GROUP_VALIDATOR
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(3).INTERFACE_COL_NAME         := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(3).INTERFACE_COL_TYPE         := 2;
  l_interface_cols_tbl(3).DISPLAY_FLAG               := 'N';
  l_interface_cols_tbl(3).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(3).DATA_TYPE                  := 2; -- VARCHAR
  l_interface_cols_tbl(3).FIELD_SIZE                 := 1;
  l_interface_cols_tbl(3).SEGMENT_VALUE              := 1;
  l_interface_cols_tbl(3).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(3).VAL_TYPE                   := 'GROUP';
  l_interface_cols_tbl(3).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(3).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(3).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(3).VAL_OBJ_NAME               := 'oracle.apps.fem.integrator.dimension.validators.FemMemberGroupValidator';
  l_interface_cols_tbl(3).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(3).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(3).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(3).DISPLAY_ORDER              := NULL;
  l_interface_cols_tbl(3).UPLOAD_PARAM_LIST_ITEM_NUM := NULL;
  l_interface_cols_tbl(3).SEQUENCE_NUM               := 3;
  l_interface_cols_tbl(3).LOV_TYPE                   := 'NONE';
  l_interface_cols_tbl(3).OFFLINE_LOV_ENABLED_FLAG   := 'N';
  l_interface_cols_tbl(3).FND_MESSAGE_NAME           := NULL;
  l_interface_cols_tbl(3).USER_HINT_FND_MESSAGE_NAME := NULL;

  -----------------------------------------------------------------------------
  -- Set up for column P_LEDGER_ID
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(4).INTERFACE_COL_NAME         := 'P_LEDGER_ID';
  l_interface_cols_tbl(4).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(4).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(4).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(4).DATA_TYPE                  := 1;  -- NUMBER
  l_interface_cols_tbl(4).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(4).SEGMENT_VALUE              := 4;
  l_interface_cols_tbl(4).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(4).VAL_TYPE                   := 'TABLE';
  l_interface_cols_tbl(4).VAL_ID_COL                 := 'LEDGER_ID';
  l_interface_cols_tbl(4).VAL_MEAN_COL               := 'LEDGER_NAME';
  l_interface_cols_tbl(4).VAL_DESC_COL               := 'DESCRIPTION';
  l_interface_cols_tbl(4).VAL_OBJ_NAME               := 'FEM_LEDGERS_VL';
  l_interface_cols_tbl(4).VAL_ADDL_W_C               := 'ENABLED_FLAG = ''Y'' AND PERSONAL_FLAG = ''N''';
  l_interface_cols_tbl(4).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(4).VAL_COMPONENT_CODE         := 'FEM_LEDGER';
  l_interface_cols_tbl(4).DISPLAY_ORDER              := 40;
  l_interface_cols_tbl(4).UPLOAD_PARAM_LIST_ITEM_NUM := 3;
  l_interface_cols_tbl(4).SEQUENCE_NUM               := 4;
  l_interface_cols_tbl(4).LOV_TYPE                   := 'POPLIST';
  l_interface_cols_tbl(4).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(4).FND_MESSAGE_NAME           := 'FEM_ADI_LEDGER_NAME';
  l_interface_cols_tbl(4).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_CALENDAR_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(5).INTERFACE_COL_NAME         := 'P_CALENDAR_DISPLAY_CODE';
  l_interface_cols_tbl(5).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(5).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(5).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(5).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(5).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(5).SEGMENT_VALUE              := 5;
  l_interface_cols_tbl(5).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(5).VAL_TYPE                   := 'TABLE';
  l_interface_cols_tbl(5).VAL_ID_COL                 := 'CALENDAR_DISPLAY_CODE';
  l_interface_cols_tbl(5).VAL_MEAN_COL               := 'CALENDAR_NAME';
  l_interface_cols_tbl(5).VAL_DESC_COL               := 'DESCRIPTION';
  l_interface_cols_tbl(5).VAL_OBJ_NAME               := 'FEM_CALENDARS_VL';
  l_interface_cols_tbl(5).VAL_ADDL_W_C               := 'ENABLED_FLAG = ''Y'' AND PERSONAL_FLAG = ''N''';
  l_interface_cols_tbl(5).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(5).VAL_COMPONENT_CODE         := 'FEM_CALENDAR';
  l_interface_cols_tbl(5).DISPLAY_ORDER              := 50;
  l_interface_cols_tbl(5).UPLOAD_PARAM_LIST_ITEM_NUM := 4;
  l_interface_cols_tbl(5).SEQUENCE_NUM               := 5;
  l_interface_cols_tbl(5).LOV_TYPE                   := 'POPLIST';
  l_interface_cols_tbl(5).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(5).FND_MESSAGE_NAME           := 'FEM_ADI_CALENDAR_NAME';
  l_interface_cols_tbl(5).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_MEMBER_NAME
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(6).INTERFACE_COL_NAME         := 'P_MEMBER_NAME';
  l_interface_cols_tbl(6).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(6).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(6).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(6).DATA_TYPE                  := 2;
  l_interface_cols_tbl(6).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(6).SEGMENT_VALUE              := 6;
  l_interface_cols_tbl(6).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(6).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(6).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(6).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(6).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(6).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(6).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(6).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(6).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(6).DISPLAY_ORDER              := 60;
  l_interface_cols_tbl(6).UPLOAD_PARAM_LIST_ITEM_NUM := 5;
  l_interface_cols_tbl(6).SEQUENCE_NUM               := 6;
  l_interface_cols_tbl(6).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(6).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(6).FND_MESSAGE_NAME           := 'FEM_ADI_MEMBER_NAME';
  l_interface_cols_tbl(6).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_TEXT_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_MEMBER_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(7).INTERFACE_COL_NAME         := 'P_MEMBER_DISPLAY_CODE';
  l_interface_cols_tbl(7).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(7).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(7).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(7).DATA_TYPE                  := 2;
  l_interface_cols_tbl(7).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(7).SEGMENT_VALUE              := 7;
  l_interface_cols_tbl(7).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(7).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(7).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(7).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(7).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(7).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(7).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(7).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(7).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(7).DISPLAY_ORDER              := 70;
  l_interface_cols_tbl(7).UPLOAD_PARAM_LIST_ITEM_NUM := 6;
  l_interface_cols_tbl(7).SEQUENCE_NUM               := 7;
  l_interface_cols_tbl(7).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(7).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(7).FND_MESSAGE_NAME           := 'FEM_ADI_MEMBER_CODE';
  l_interface_cols_tbl(7).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_TEXT_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_MEMBER_DESCRIPTION
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(8).INTERFACE_COL_NAME         := 'P_MEMBER_DESCRIPTION';
  l_interface_cols_tbl(8).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(8).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(8).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(8).DATA_TYPE                  := 2;
  l_interface_cols_tbl(8).FIELD_SIZE                 := 255;
  l_interface_cols_tbl(8).SEGMENT_VALUE              := NULL;
  l_interface_cols_tbl(8).GROUP_NAME                 := NULL;
  l_interface_cols_tbl(8).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(8).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(8).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(8).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(8).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(8).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(8).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(8).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(8).DISPLAY_ORDER              := 80;
  l_interface_cols_tbl(8).UPLOAD_PARAM_LIST_ITEM_NUM := 7;
  l_interface_cols_tbl(8).SEQUENCE_NUM               := 8;
  l_interface_cols_tbl(8).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(8).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(8).FND_MESSAGE_NAME           := 'FEM_ADI_DESCRIPTION';
  l_interface_cols_tbl(8).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_TEXT';

  -----------------------------------------------------------------------------
  -- Set up for column P_DIMENSION_GROUP_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(9).INTERFACE_COL_NAME         := 'P_DIMENSION_GROUP_DISPLAY_CODE';
  l_interface_cols_tbl(9).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(9).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(9).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(9).DATA_TYPE                  := 2;
  l_interface_cols_tbl(9).FIELD_SIZE                 := 80;
  l_interface_cols_tbl(9).SEGMENT_VALUE              := 9;
  l_interface_cols_tbl(9).GROUP_NAME                 := 'MEMBER_GROUP_VALIDATOR';
  l_interface_cols_tbl(9).VAL_TYPE                   := 'JAVA';
  l_interface_cols_tbl(9).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(9).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(9).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(9).VAL_OBJ_NAME               := 'oracle.apps.fem.integrator.dimension.validators.FemDimGroupValidator';
  l_interface_cols_tbl(9).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(9).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(9).VAL_COMPONENT_CODE         := 'FEM_DIM_GROUP';
  l_interface_cols_tbl(9).DISPLAY_ORDER              := 90;
  l_interface_cols_tbl(9).UPLOAD_PARAM_LIST_ITEM_NUM := 8;
  l_interface_cols_tbl(9).SEQUENCE_NUM               := 9;
  l_interface_cols_tbl(9).LOV_TYPE                   := 'STANDARD';
  l_interface_cols_tbl(9).OFFLINE_LOV_ENABLED_FLAG   := 'N';
  l_interface_cols_tbl(9).FND_MESSAGE_NAME           := 'FEM_ADI_LEVEL_NAME';
  IF (p_group_use_code = 'REQUIRED') THEN
    l_interface_cols_tbl(9).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';
  ELSE
    l_interface_cols_tbl(9).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV';
  END IF;
  /*
  -----------------------------------------------------------------------------
  -- Set up for column
  -----------------------------------------------------------------------------
  l_interface_cols_tbl().INTERFACE_COL_NAME         :=
  l_interface_cols_tbl().INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl().DISPLAY_FLAG               :=
  l_interface_cols_tbl().READ_ONLY_FLAG             :=
  l_interface_cols_tbl().DATA_TYPE                  :=
  l_interface_cols_tbl().FIELD_SIZE                 :=
  l_interface_cols_tbl().SEGMENT_VALUE              :=
  l_interface_cols_tbl().GROUP_NAME                 :=
  l_interface_cols_tbl().VAL_TYPE                   :=
  l_interface_cols_tbl().VAL_ID_COL                 :=
  l_interface_cols_tbl().VAL_MEAN_COL               :=
  l_interface_cols_tbl().VAL_DESC_COL               :=
  l_interface_cols_tbl().VAL_OBJ_NAME               :=
  l_interface_cols_tbl().VAL_ADDL_W_C               :=
  l_interface_cols_tbl().VAL_COMPONENT_APP_ID       :=
  l_interface_cols_tbl().VAL_COMPONENT_CODE         :=
  l_interface_cols_tbl().DISPLAY_ORDER              :=
  l_interface_cols_tbl().UPLOAD_PARAM_LIST_ITEM_NUM :=
  l_interface_cols_tbl().SEQUENCE_NUM               :=
  l_interface_cols_tbl().LOV_TYPE                   := ;
  l_interface_cols_tbl().OFFLINE_LOV_ENABLED_FLAG   := ;
  l_interface_cols_tbl().FND_MESSAGE_NAME           :=
  l_interface_cols_tbl().USER_HINT_FND_MESSAGE_NAME := ;
  */
  -----------------------------------------------------------------------------
  -- Inserting into BNE_INTERFACE_COLS and BNE_INTERFACE_COLS_TL
  -----------------------------------------------------------------------------
  FOR i IN l_interface_cols_tbl.FIRST .. l_interface_cols_tbl.LAST
  LOOP
    INSERT INTO BNE_INTERFACE_COLS_B (
      INTERFACE_COL_TYPE,
      INTERFACE_COL_NAME,
      ENABLED_FLAG,
      REQUIRED_FLAG,
      DISPLAY_FLAG,
      READ_ONLY_FLAG,
      NOT_NULL_FLAG,
      SUMMARY_FLAG,
      MAPPING_ENABLED_FLAG,
      DATA_TYPE,
      FIELD_SIZE,
      DEFAULT_TYPE,
      DEFAULT_VALUE,
      SEGMENT_NUMBER,
      GROUP_NAME,
      OA_FLEX_CODE,
      OA_CONCAT_FLEX,
      VAL_TYPE,
      VAL_ID_COL,
      VAL_MEAN_COL,
      VAL_DESC_COL,
      VAL_OBJ_NAME,
      VAL_ADDL_W_C,
      VAL_COMPONENT_APP_ID,
      VAL_COMPONENT_CODE,
      OA_FLEX_NUM,
      OA_FLEX_APPLICATION_ID,
      DISPLAY_ORDER,
      UPLOAD_PARAM_LIST_ITEM_NUM,
      EXPANDED_SQL_QUERY,
      APPLICATION_ID,
      INTERFACE_CODE,
      OBJECT_VERSION_NUMBER,
      SEQUENCE_NUM,
      LOV_TYPE,
      OFFLINE_LOV_ENABLED_FLAG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      VARIABLE_DATA_TYPE_CLASS
    )
    VALUES
    ( l_interface_cols_tbl(i).INTERFACE_COL_TYPE,
      l_interface_cols_tbl(i).INTERFACE_COL_NAME,
      'Y',
      'N',
      l_interface_cols_tbl(i).DISPLAY_FLAG,
      l_interface_cols_tbl(i).READ_ONLY_FLAG,
      'Y',
      'N',
      'N',
      l_interface_cols_tbl(i).DATA_TYPE,
      l_interface_cols_tbl(i).FIELD_SIZE,
      NULL,
      NULL,
      l_interface_cols_tbl(i).SEGMENT_VALUE,
      l_interface_cols_tbl(i).GROUP_NAME,
      NULL,
      NULL,
      l_interface_cols_tbl(i).VAL_TYPE,
      l_interface_cols_tbl(i).VAL_ID_COL,
      l_interface_cols_tbl(i).VAL_MEAN_COL,
      l_interface_cols_tbl(i).VAL_DESC_COL,
      l_interface_cols_tbl(i).VAL_OBJ_NAME,
      l_interface_cols_tbl(i).VAL_ADDL_W_C,
      l_interface_cols_tbl(i).VAL_COMPONENT_APP_ID,
      l_interface_cols_tbl(i).VAL_COMPONENT_CODE,
      NULL,
      NULL,
      l_interface_cols_tbl(i).DISPLAY_ORDER,
      l_interface_cols_tbl(i).UPLOAD_PARAM_LIST_ITEM_NUM,
      NULL,
      274,
      p_interface_code,
      1,
      l_interface_cols_tbl(i).SEQUENCE_NUM,
      l_interface_cols_tbl(i).LOV_TYPE,
      l_interface_cols_tbl(i).OFFLINE_LOV_ENABLED_FLAG,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_login_id,
      NULL
    );

    INSERT INTO BNE_INTERFACE_COLS_TL (
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      USER_HINT,
      PROMPT_LEFT,
      USER_HELP_TEXT,
      PROMPT_ABOVE,
      INTERFACE_CODE,
      SEQUENCE_NUM,
      APPLICATION_ID,
      LANGUAGE,
      SOURCE_LANG
    )
    SELECT l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      M2.MESSAGE_TEXT
    ,      M1.MESSAGE_TEXT
    ,      NULL
    ,      M1.MESSAGE_TEXT
    ,      p_interface_code
    ,      l_interface_cols_tbl(i).SEQUENCE_NUM
    ,      274
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M1,
           FND_NEW_MESSAGES M2,
           FND_LANGUAGES L
    WHERE  L.INSTALLED_FLAG IN ('I', 'B')
    AND    M1.MESSAGE_NAME (+)= l_interface_cols_tbl(i).FND_MESSAGE_NAME
    AND    M1.LANGUAGE_CODE (+)= L.LANGUAGE_CODE
    AND    M2.MESSAGE_NAME (+)= l_interface_cols_tbl(i).USER_HINT_FND_MESSAGE_NAME
    AND    M2.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

  END LOOP;

  IF ( FND_API.To_Boolean( p_char => p_commit) ) THEN
    COMMIT;
  END IF;


EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Dim_Intf_Common_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Dim_Intf_Common_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Dim_Intf_Common_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
   --
END Populate_Dim_Intf_Common_Cols;


PROCEDURE Populate_Dim_Intf_Attr_Cols (
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2,
  p_interface_code               IN           VARCHAR2,
  p_dimension_varchar_label      IN           VARCHAR2,
  p_dimension_id                 IN           NUMBER  ,
  x_updated_flag                 OUT NOCOPY   VARCHAR2
)
IS
  --
  l_api_name    CONSTANT         VARCHAR2(30) := 'Populate_Dim_Intf_Attr_Cols';
  l_api_version CONSTANT         NUMBER := 1.0;
  --

  l_user_id                      NUMBER(15)    := 2; --   (user name : initial setup)
  l_login_id                     NUMBER        := NVL(Fnd_Global.Login_Id, 0);
  l_index                        NUMBER        ;

  l_updated_flag                 VARCHAR2(1)   := 'N';
  l_max_sequence_num             BNE_INTERFACE_COLS_B.SEQUENCE_NUM%TYPE;
  l_sequence_num                 BNE_INTERFACE_COLS_B.SEQUENCE_NUM%TYPE;
  l_val_component_code           BNE_INTERFACE_COLS_B.VAL_COMPONENT_CODE%TYPE;

  TYPE l_sequence_num_tbl_typ       IS TABLE OF
         BNE_INTERFACE_COLS_B.SEQUENCE_NUM%TYPE  INDEX BY BINARY_INTEGER;

  TYPE l_data_type_tbl_typ          IS TABLE OF
         FEM_WEBADI_DIM_ATTR_MAPS.DATA_TYPE%TYPE INDEX BY BINARY_INTEGER;

  TYPE l_attr_varchar_label_tbl_typ IS TABLE OF
         FEM_WEBADI_DIM_ATTR_MAPS.ATTRIBUTE_VARCHAR_LABEL%TYPE
                                                 INDEX BY BINARY_INTEGER;

  l_map_sequence_num_tbl         l_sequence_num_tbl_typ;
  l_map_data_type_tbl            l_data_type_tbl_typ;
  l_map_attr_var_label_tbl       l_attr_varchar_label_tbl_typ;


  l_attr_intf_col_name_tbl FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30
                                                       ( 'P_ATTRIBUTE1'
                                                       , 'P_ATTRIBUTE2'
                                                       , 'P_ATTRIBUTE3'
                                                       , 'P_ATTRIBUTE4'
                                                       , 'P_ATTRIBUTE5'
                                                       , 'P_ATTRIBUTE6'
                                                       , 'P_ATTRIBUTE7'
                                                       , 'P_ATTRIBUTE8'
                                                       , 'P_ATTRIBUTE9'
                                                       , 'P_ATTRIBUTE10'
                                                       , 'P_ATTRIBUTE11'
                                                       , 'P_ATTRIBUTE12'
                                                       , 'P_ATTRIBUTE13'
                                                       , 'P_ATTRIBUTE14'
                                                       , 'P_ATTRIBUTE15'
                                                       , 'P_ATTRIBUTE16'
                                                       , 'P_ATTRIBUTE17'
                                                       , 'P_ATTRIBUTE18'
                                                       , 'P_ATTRIBUTE19'
                                                       , 'P_ATTRIBUTE20'
                                                       , 'P_ATTRIBUTE21'
                                                       , 'P_ATTRIBUTE22'
                                                       , 'P_ATTRIBUTE23'
                                                       , 'P_ATTRIBUTE24'
                                                       , 'P_ATTRIBUTE25'
                                                       , 'P_ATTRIBUTE26'
                                                       , 'P_ATTRIBUTE27'
                                                       , 'P_ATTRIBUTE28'
                                                       , 'P_ATTRIBUTE29'
                                                       , 'P_ATTRIBUTE30'
                                                       , 'P_ATTRIBUTE31'
                                                       , 'P_ATTRIBUTE32'
                                                       , 'P_ATTRIBUTE33'
                                                       , 'P_ATTRIBUTE34'
                                                       , 'P_ATTRIBUTE35'
                                                       , 'P_ATTRIBUTE36'
                                                       , 'P_ATTRIBUTE37'
                                                       , 'P_ATTRIBUTE38'
                                                       , 'P_ATTRIBUTE39'
                                                       , 'P_ATTRIBUTE40'
                                                       , 'P_ATTRIBUTE41'
                                                       , 'P_ATTRIBUTE42'
                                                       , 'P_ATTRIBUTE43'
                                                       , 'P_ATTRIBUTE44'
                                                       , 'P_ATTRIBUTE45'
                                                       , 'P_ATTRIBUTE46'
                                                       , 'P_ATTRIBUTE47'
                                                       , 'P_ATTRIBUTE48'
                                                       , 'P_ATTRIBUTE49'
                                                       , 'P_ATTRIBUTE50');
BEGIN

  --
  SAVEPOINT Dim_Intf_Attr_Cols_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  x_updated_flag := 'N';

  -----------------------------------------------------------------------------
  -- Update the records that are not stored in the mapping tables
  -----------------------------------------------------------------------------
  -- Bulk collect l_map_sequence_num_tbl


  IF (l_map_sequence_num_tbl.COUNT > 0) THEN

    IF (x_updated_flag = 'N') THEN
      x_updated_flag := 'Y';
    END IF;
  END IF;


  FOR del_rec IN
  (
    SELECT I.SEQUENCE_NUM
    ,      I.INTERFACE_COL_NAME
    FROM   BNE_LAYOUT_COLS L
    ,      BNE_INTERFACE_COLS_B I
    WHERE  L.APPLICATION_ID = 274
    AND    L.INTERFACE_APP_ID = 274
    AND    L.INTERFACE_CODE = p_interface_code
    AND    I.APPLICATION_ID = L.INTERFACE_APP_ID
    AND    I.INTERFACE_CODE = L.INTERFACE_CODE
    AND    I.SEQUENCE_NUM = L.INTERFACE_SEQ_NUM
    AND    I.INTERFACE_COL_NAME LIKE 'P_ATTRIBUTE%'
    AND    NOT EXISTS
    (
      SELECT 1
      FROM   FEM_WEBADI_DIM_ATTR_MAPS M
      WHERE  M.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
      AND    M.INTERFACE_COL = I.INTERFACE_COL_NAME
    )
  )
  LOOP

    IF (x_updated_flag = 'N') THEN
      x_updated_flag := 'Y';
    END IF;

    UPDATE BNE_INTERFACE_COLS_B
    SET    VAL_TYPE = NULL
    ,      VAL_OBJ_NAME = NULL
    ,      VAL_COMPONENT_APP_ID = NULL
    ,      VAL_COMPONENT_CODE = NULL
    ,      LOV_TYPE = NULL
    ,      OFFLINE_LOV_ENABLED_FLAG = NULL
    ,      SEGMENT_NUMBER = NULL
    ,      GROUP_NAME = NULL
    ,      VARIABLE_DATA_TYPE_CLASS = NULL
    WHERE  APPLICATION_ID = 274
    AND    INTERFACE_CODE = p_interface_code
    AND    SEQUENCE_NUM = del_rec.SEQUENCE_NUM
    AND    INTERFACE_COL_NAME IS NOT NULL;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    UPDATE BNE_INTERFACE_COLS_TL
    SET    USER_HINT = NULL
    ,      PROMPT_LEFT = del_rec.INTERFACE_COL_NAME
    ,      USER_HELP_TEXT = NULL
    ,      PROMPT_ABOVE = del_rec.INTERFACE_COL_NAME
    WHERE  APPLICATION_ID = 274
    AND    INTERFACE_CODE = p_interface_code
    AND    SEQUENCE_NUM = del_rec.SEQUENCE_NUM;

  END LOOP;


  -----------------------------------------------------------------------------
  -- Update those interface column whose data type has changed in
  -- FEM_WEBADI_DIM_ATTR_MAPS table.
  -----------------------------------------------------------------------------

  IF (g_changed_dt_intf_col_tbl.COUNT > 0) THEN

    IF (x_updated_flag = 'N') THEN
      x_updated_flag := 'Y';
    END IF;


    FOR dt_changed_rec IN
    (
      SELECT REF.column_value AS INTERFACE_COL
      ,      DATA_TYPE
      ,      MAP.ATTRIBUTE_VARCHAR_LABEL
      ,      ATTRIBUTE_REQUIRED_FLAG
      FROM  TABLE(CAST(g_changed_dt_intf_col_tbl AS FND_TABLE_OF_VARCHAR2_30)) REF
      ,     FEM_WEBADI_DIM_ATTR_MAPS MAP
      ,     FEM_DIM_ATTRIBUTES_B A
      WHERE MAP.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
      AND   MAP.INTERFACE_COL = REF.column_value
      AND   A.DIMENSION_ID = p_dimension_id
      AND   A.ATTRIBUTE_VARCHAR_LABEL = MAP.ATTRIBUTE_VARCHAR_LABEL
    )
    LOOP

      l_sequence_num := NULL;
      l_val_component_code := NULL;

      FOR intf_rec IN (
        SELECT SEQUENCE_NUM
        ,      VAL_COMPONENT_CODE
        FROM   BNE_INTERFACE_COLS_B
        WHERE  APPLICATION_ID = 274
        AND    INTERFACE_CODE = p_interface_code
        AND    INTERFACE_COL_NAME = dt_changed_rec.INTERFACE_COL
      )
      LOOP
        l_sequence_num := intf_rec.SEQUENCE_NUM;
        l_val_component_code := intf_rec.VAL_COMPONENT_CODE;
      END LOOP;

      -----------------------------------------------------------------------
      -- Delete records in BNE_INTERFACE_COLS_TL and insert the new records.
      -----------------------------------------------------------------------
      DELETE BNE_INTERFACE_COLS_TL
      WHERE  APPLICATION_ID = 274
      AND    INTERFACE_CODE = p_interface_code
      AND    SEQUENCE_NUM = l_sequence_num;

      INSERT INTO BNE_INTERFACE_COLS_TL
      (
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        USER_HINT,
        PROMPT_LEFT,
        USER_HELP_TEXT,
        PROMPT_ABOVE,
        INTERFACE_CODE,
        SEQUENCE_NUM,
        APPLICATION_ID,
        LANGUAGE,
        SOURCE_LANG
      )
      SELECT l_user_id
      ,      SYSDATE
      ,      l_user_id
      ,      l_login_id
      ,      SYSDATE
      ,      M.MESSAGE_TEXT
      ,      B.ATTRIBUTE_NAME
      ,      NULL
      ,      B.ATTRIBUTE_NAME
      ,      p_interface_code
      ,      l_sequence_num
      ,      274
      ,      L.LANGUAGE_CODE
      ,      B.SOURCE_LANG
      FROM   FEM_XDIM_DIMENSIONS_VL D
      ,      FEM_DIM_ATTRIBUTES_B A
      ,      FEM_DIM_ATTRIBUTES_TL B
      ,      FND_NEW_MESSAGES M
      ,      FND_LANGUAGES L
      WHERE  L.INSTALLED_FLAG IN ('I', 'B')
      AND    D.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
      AND    D.DIMENSION_ID = A.DIMENSION_ID
      AND    A.ATTRIBUTE_VARCHAR_LABEL = dt_changed_rec.ATTRIBUTE_VARCHAR_LABEL
      AND    A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
      AND    B.LANGUAGE (+) = L.LANGUAGE_CODE
      AND    M.MESSAGE_NAME (+)=
             DECODE(dt_changed_rec.DATA_TYPE, 'DIMENSION',
               DECODE(dt_changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_LOV_REQ', 'FEM_ADI_USER_HINT_LOV'),
             DECODE(dt_changed_rec.DATA_TYPE, 'VARCHAR2',
               DECODE(dt_changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_TEXT_REQ', 'FEM_ADI_USER_HINT_TEXT'),
             DECODE(dt_changed_rec.DATA_TYPE, 'NUMBER',
               DECODE(dt_changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_NUMBER_REQ', 'FEM_ADI_USER_HINT_NUMBER'),
             DECODE(dt_changed_rec.DATA_TYPE, 'DATE',
               DECODE(dt_changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_DATE_REQ', 'FEM_ADI_USER_HINT_DATE'), NULL))))
      AND    M.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

      IF (dt_changed_rec.DATA_TYPE = 'DIMENSION') THEN

        UPDATE BNE_INTERFACE_COLS_B
        SET    VAL_TYPE = 'JAVA'
        ,      VAL_OBJ_NAME = 'oracle.apps.fem.integrator.dimension.validators.FemAttributeValidator'
        ,      VAL_COMPONENT_APP_ID = 274
        ,      VAL_COMPONENT_CODE = 'FEM_ATTRIBUTE'
        ,      LOV_TYPE = 'STANDARD'
        ,      OFFLINE_LOV_ENABLED_FLAG = 'N'
        ,      VARIABLE_DATA_TYPE_CLASS = NULL
        WHERE  APPLICATION_ID = 274
        AND    INTERFACE_CODE = p_interface_code
        AND    INTERFACE_COL_NAME = dt_changed_rec.INTERFACE_COL;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;

      ELSE
        UPDATE BNE_INTERFACE_COLS_B
        SET    VAL_TYPE = NULL
        ,      VAL_OBJ_NAME = NULL
        ,      VAL_COMPONENT_APP_ID = NULL
        ,      VAL_COMPONENT_CODE = NULL
        ,      LOV_TYPE = NULL
        ,      OFFLINE_LOV_ENABLED_FLAG = NULL
        ,      VARIABLE_DATA_TYPE_CLASS =
               DECODE(dt_changed_rec.DATA_TYPE, 'DATE',
               'oracle.apps.fem.integrator.dimension.validators.FemAttributeDateTypeValidator',
               DECODE(dt_changed_rec.DATA_TYPE, 'NUMBER',
               'oracle.apps.fem.integrator.dimension.validators.FemAttributeNumericTypeValidator', NULL))
        WHERE  APPLICATION_ID = 274
        AND    INTERFACE_CODE = p_interface_code
        AND    INTERFACE_COL_NAME = dt_changed_rec.INTERFACE_COL;

        IF (SQL%NOTFOUND) THEN
         RAISE NO_DATA_FOUND;
        END IF;

      END IF;

    END LOOP;
  END IF;

  -----------------------------------------------------------------------------
  -- Upsert BNE_INTERFACE_COLS_B and BNE_INTERFACE_COLS_TL table based on the
  -- data populated in the g_changed_intf_col_tbl that is generated through
  -- Populate_Dim_Attribute_Maps
  -----------------------------------------------------------------------------

  -- The interface col will not be found when the metadata is populated for the
  -- first time.
  -- The interface col will always be found when there is metadata populated
  -- before.

  SELECT MAX(SEQUENCE_NUM)
  INTO   l_max_sequence_num
  FROM   BNE_INTERFACE_COLS_B
  WHERE  APPLICATION_ID = 274
  AND    INTERFACE_CODE = p_interface_code;

  IF (g_changed_intf_col_tbl.COUNT > 0) THEN

    SELECT MAX(SEQUENCE_NUM)
    INTO   l_max_sequence_num
    FROM   BNE_INTERFACE_COLS_B
    WHERE  APPLICATION_ID = 274
    AND    INTERFACE_CODE = p_interface_code;

    IF (x_updated_flag = 'N') THEN
      x_updated_flag := 'Y';
    END IF;

    FOR changed_rec IN
    (
      SELECT REF.column_value AS INTERFACE_COL
      ,      DATA_TYPE
      ,      MAP.ATTRIBUTE_VARCHAR_LABEL
      ,      ATTRIBUTE_REQUIRED_FLAG
      FROM  TABLE(CAST(g_changed_intf_col_tbl AS FND_TABLE_OF_VARCHAR2_30)) REF
      ,     FEM_WEBADI_DIM_ATTR_MAPS MAP
      ,     FEM_DIM_ATTRIBUTES_B A
      WHERE MAP.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
      AND   MAP.INTERFACE_COL = REF.column_value
      AND   A.DIMENSION_ID = p_dimension_id
      AND   A.ATTRIBUTE_VARCHAR_LABEL = MAP.ATTRIBUTE_VARCHAR_LABEL
    )
    LOOP
      l_sequence_num := NULL;
      l_val_component_code := NULL;

      FOR intf_rec IN (
        SELECT SEQUENCE_NUM
        ,      VAL_COMPONENT_CODE
        FROM   BNE_INTERFACE_COLS_B
        WHERE  APPLICATION_ID = 274
        AND    INTERFACE_CODE = p_interface_code
        AND    INTERFACE_COL_NAME = changed_rec.INTERFACE_COL
      )
      LOOP
        l_sequence_num := intf_rec.SEQUENCE_NUM;
        l_val_component_code := intf_rec.VAL_COMPONENT_CODE;
      END LOOP;

      IF (l_sequence_num is not null) THEN

        -----------------------------------------------------------------------
        -- Delete records in BNE_INTERFACE_COLS_TL and insert the new records.
        -----------------------------------------------------------------------
        DELETE BNE_INTERFACE_COLS_TL
        WHERE  APPLICATION_ID = 274
        AND    INTERFACE_CODE = p_interface_code
        AND    SEQUENCE_NUM = l_sequence_num;

        INSERT INTO BNE_INTERFACE_COLS_TL
        (
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          USER_HINT,
          PROMPT_LEFT,
          USER_HELP_TEXT,
          PROMPT_ABOVE,
          INTERFACE_CODE,
          SEQUENCE_NUM,
          APPLICATION_ID,
          LANGUAGE,
          SOURCE_LANG
        )
        SELECT l_user_id
        ,      SYSDATE
        ,      l_user_id
        ,      l_login_id
        ,      SYSDATE
        ,      M.MESSAGE_TEXT
        ,      B.ATTRIBUTE_NAME
        ,      NULL
        ,      B.ATTRIBUTE_NAME
        ,      p_interface_code
        ,      l_sequence_num
        ,      274
        ,      L.LANGUAGE_CODE
        ,      B.SOURCE_LANG
        FROM   FEM_XDIM_DIMENSIONS_VL D
        ,      FEM_DIM_ATTRIBUTES_B A
        ,      FEM_DIM_ATTRIBUTES_TL B
        ,      FND_NEW_MESSAGES M
        ,      FND_LANGUAGES L
        WHERE  L.INSTALLED_FLAG IN ('I', 'B')
        AND    D.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
        AND    D.DIMENSION_ID = A.DIMENSION_ID
        AND    A.ATTRIBUTE_VARCHAR_LABEL = changed_rec.ATTRIBUTE_VARCHAR_LABEL
        AND    A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
        AND    B.LANGUAGE (+) = L.LANGUAGE_CODE
        AND    M.MESSAGE_NAME (+)=
               DECODE(changed_rec.DATA_TYPE, 'DIMENSION',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_LOV_REQ', 'FEM_ADI_USER_HINT_LOV'),
               DECODE(changed_rec.DATA_TYPE, 'VARCHAR2',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_TEXT_REQ', 'FEM_ADI_USER_HINT_TEXT'),
               DECODE(changed_rec.DATA_TYPE, 'NUMBER',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_NUMBER_REQ', 'FEM_ADI_USER_HINT_NUMBER'),
               DECODE(changed_rec.DATA_TYPE, 'DATE',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_DATE_REQ', 'FEM_ADI_USER_HINT_DATE'), NULL))))
        AND    M.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

        ---------------------------------------------------------------------
        -- Update BNE_INTERFACE_COLS_B when required
        ---------------------------------------------------------------------

        IF (changed_rec.DATA_TYPE = 'DIMENSION' AND
             (l_val_component_code IS NULL OR
              l_val_component_code <> 'FEM_ATTRIBUTE')) THEN

          UPDATE BNE_INTERFACE_COLS_B
          SET    VAL_TYPE = 'JAVA'
          ,      VAL_OBJ_NAME = 'oracle.apps.fem.integrator.dimension.validators.FemAttributeValidator'
          ,      VAL_COMPONENT_APP_ID = 274
          ,      VAL_COMPONENT_CODE = 'FEM_ATTRIBUTE'
          ,      LOV_TYPE = 'STANDARD'
          ,      OFFLINE_LOV_ENABLED_FLAG = 'N'
          ,      SEGMENT_NUMBER = 100 + ((UPLOAD_PARAM_LIST_ITEM_NUM -8) * 10)
          ,      GROUP_NAME = 'MEMBER_GROUP_VALIDATOR'
          ,      VARIABLE_DATA_TYPE_CLASS = NULL
          WHERE  APPLICATION_ID = 274
          AND    INTERFACE_CODE = p_interface_code
          AND    SEQUENCE_NUM = l_sequence_num;

        ELSIF (changed_rec.DATA_TYPE <> 'DIMENSION' AND l_val_component_code = 'FEM_ATTRIBUTE') THEN

          UPDATE BNE_INTERFACE_COLS_B
          SET    VAL_TYPE = NULL
          ,      VAL_OBJ_NAME = NULL
          ,      VAL_COMPONENT_APP_ID = NULL
          ,      VAL_COMPONENT_CODE = NULL
          ,      LOV_TYPE = NULL
          ,      OFFLINE_LOV_ENABLED_FLAG = NULL
          ,      SEGMENT_NUMBER = 100 + ((UPLOAD_PARAM_LIST_ITEM_NUM -8) * 10)
          ,      GROUP_NAME = 'MEMBER_GROUP_VALIDATOR'
          ,      VARIABLE_DATA_TYPE_CLASS =
                 DECODE(changed_rec.DATA_TYPE, 'DATE',
                 'oracle.apps.fem.integrator.dimension.validators.FemAttributeDateTypeValidator',
                 DECODE(changed_rec.DATA_TYPE, 'NUMBER',
                 'oracle.apps.fem.integrator.dimension.validators.FemAttributeNumericTypeValidator',
                 NULL))
          WHERE  APPLICATION_ID = 274
          AND    INTERFACE_CODE = p_interface_code
          AND    SEQUENCE_NUM = l_sequence_num;

        ELSE
          -- Need to update the segment and group name because they are not
          -- previously set.
          UPDATE BNE_INTERFACE_COLS_B
          SET    SEGMENT_NUMBER = 100 + ((UPLOAD_PARAM_LIST_ITEM_NUM -8) * 10)
          ,      GROUP_NAME = 'MEMBER_GROUP_VALIDATOR'
          ,      VARIABLE_DATA_TYPE_CLASS =
                 DECODE(changed_rec.DATA_TYPE, 'DATE',
                 'oracle.apps.fem.integrator.dimension.validators.FemAttributeDateTypeValidator',
                 DECODE(changed_rec.DATA_TYPE, 'NUMBER',
                 'oracle.apps.fem.integrator.dimension.validators.FemAttributeNumericTypeValidator',
                 NULL))
          WHERE  APPLICATION_ID = 274
          AND    INTERFACE_CODE = p_interface_code
          AND    SEQUENCE_NUM = l_sequence_num;

        END IF;

      ELSE

        ------------------------------------------------------------------------
        -- Insert records to both BNE_INTERFACE_COLS_B and BNE_INTERFACE_COLS_TL
        ------------------------------------------------------------------------
        l_max_sequence_num := l_max_sequence_num + 1;

        INSERT INTO BNE_INTERFACE_COLS_B (
          INTERFACE_COL_TYPE,
          INTERFACE_COL_NAME,
          ENABLED_FLAG,
          REQUIRED_FLAG,
          DISPLAY_FLAG,
          READ_ONLY_FLAG,
          NOT_NULL_FLAG,
          SUMMARY_FLAG,
          MAPPING_ENABLED_FLAG,
          DATA_TYPE,
          FIELD_SIZE,
          DEFAULT_TYPE,
          DEFAULT_VALUE,
          SEGMENT_NUMBER,
          GROUP_NAME,
          OA_FLEX_CODE,
          OA_CONCAT_FLEX,
          VAL_TYPE,
          VAL_ID_COL,
          VAL_MEAN_COL,
          VAL_DESC_COL,
          VAL_OBJ_NAME,
          VAL_ADDL_W_C,
          VAL_COMPONENT_APP_ID,
          VAL_COMPONENT_CODE,
          OA_FLEX_NUM,
          OA_FLEX_APPLICATION_ID,
          DISPLAY_ORDER,
          UPLOAD_PARAM_LIST_ITEM_NUM,
          EXPANDED_SQL_QUERY,
          APPLICATION_ID,
          INTERFACE_CODE,
          OBJECT_VERSION_NUMBER,
          SEQUENCE_NUM,
          LOV_TYPE,
          OFFLINE_LOV_ENABLED_FLAG,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          VARIABLE_DATA_TYPE_CLASS
        )
        VALUES
        ( 1,
          changed_rec.INTERFACE_COL,
          'Y',
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          2,
          2000,
          NULL,
          NULL,
          100+(TO_NUMBER(SUBSTR(changed_rec.INTERFACE_COL, 12))*10),
          'MEMBER_GROUP_VALIDATOR',
          NULL,
          NULL,
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 'JAVA', NULL),
          NULL,
          NULL ,
          NULL,
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 'oracle.apps.fem.integrator.dimension.validators.FemAttributeValidator', NULL),
          NULL,
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 274, NULL),
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 'FEM_ATTRIBUTE', NULL),
          NULL,
          NULL,
          l_max_sequence_num*10,
          TO_NUMBER(SUBSTR(changed_rec.INTERFACE_COL, 12)) + 8,
          NULL,
          274,
          p_interface_code,
          1,
          l_max_sequence_num,
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 'STANDARD', NULL),
          DECODE(changed_rec.DATA_TYPE, 'DIMENSION', 'N', NULL),
          SYSDATE,
          l_user_id,
          SYSDATE,
          l_user_id,
          l_login_id,
          DECODE(changed_rec.DATA_TYPE, 'DATE',
          'oracle.apps.fem.integrator.dimension.validators.FemAttributeDateTypeValidator',
          DECODE(changed_rec.DATA_TYPE, 'NUMBER',
          'oracle.apps.fem.integrator.dimension.validators.FemAttributeNumericTypeValidator',
          NULL))
        );

        INSERT INTO BNE_INTERFACE_COLS_TL
        (
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          USER_HINT,
          PROMPT_LEFT,
          USER_HELP_TEXT,
          PROMPT_ABOVE,
          INTERFACE_CODE,
          SEQUENCE_NUM,
          APPLICATION_ID,
          LANGUAGE,
          SOURCE_LANG
        )
        SELECT l_user_id
        ,      SYSDATE
        ,      l_user_id
        ,      l_login_id
        ,      SYSDATE
        ,      M.MESSAGE_TEXT
        ,      B.ATTRIBUTE_NAME
        ,      NULL
        ,      B.ATTRIBUTE_NAME
        ,      p_interface_code
        ,      l_max_sequence_num
        ,      274
        ,      L.LANGUAGE_CODE
        ,      B.SOURCE_LANG
        FROM   FEM_XDIM_DIMENSIONS_VL D
        ,      FEM_DIM_ATTRIBUTES_B A
        ,      FEM_DIM_ATTRIBUTES_TL B
        ,      FND_NEW_MESSAGES M
        ,      FND_LANGUAGES L
        WHERE  L.INSTALLED_FLAG IN ('I', 'B')
        AND    D.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
        AND    D.DIMENSION_ID = A.DIMENSION_ID
        AND    A.ATTRIBUTE_VARCHAR_LABEL = changed_rec.ATTRIBUTE_VARCHAR_LABEL
        AND    A.ATTRIBUTE_ID = B.ATTRIBUTE_ID
        AND    B.LANGUAGE (+) = L.LANGUAGE_CODE
        AND    M.MESSAGE_NAME (+)=
               DECODE(changed_rec.DATA_TYPE, 'DIMENSION',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_LOV_REQ', 'FEM_ADI_USER_HINT_LOV'),
               DECODE(changed_rec.DATA_TYPE, 'VARCHAR2',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_TEXT_REQ', 'FEM_ADI_USER_HINT_TEXT'),
               DECODE(changed_rec.DATA_TYPE, 'NUMBER',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_NUMBER_REQ',  'FEM_ADI_USER_HINT_NUMBER'),
               DECODE(changed_rec.DATA_TYPE, 'DATE',
                 DECODE(changed_rec.ATTRIBUTE_REQUIRED_FLAG, 'Y', 'FEM_ADI_USER_HINT_DATE_REQ', 'FEM_ADI_USER_HINT_DATE'), NULL))))
        AND    M.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

        if (SQL%NOTFOUND) then
          RAISE NO_DATA_FOUND;
        end if;
      END IF;

    END LOOP;
  END IF;

  -----------------------------------------------------------------------------
  -- Maintain remaining interface columns if they are missing
  -----------------------------------------------------------------------------
  FOR intf_rec IN (
    SELECT REF.column_value AS INTERFACE_COL_NAME
    FROM   TABLE(CAST(l_attr_intf_col_name_tbl AS FND_TABLE_OF_VARCHAR2_30)) REF
    WHERE  NOT EXISTS
    (
      SELECT INTERFACE_COL_NAME
      FROM   BNE_INTERFACE_COLS_B
      WHERE  APPLICATION_ID = 274
      AND    INTERFACE_CODE = p_interface_code
      AND    INTERFACE_COL_NAME = REF.column_value
    ))
  LOOP

    l_max_sequence_num := l_max_sequence_num + 1;

    INSERT INTO BNE_INTERFACE_COLS_B (
      INTERFACE_COL_TYPE,
      INTERFACE_COL_NAME,
      ENABLED_FLAG,
      REQUIRED_FLAG,
      DISPLAY_FLAG,
      READ_ONLY_FLAG,
      NOT_NULL_FLAG,
      SUMMARY_FLAG,
      MAPPING_ENABLED_FLAG,
      DATA_TYPE,
      FIELD_SIZE,
      DISPLAY_ORDER,
      UPLOAD_PARAM_LIST_ITEM_NUM,
      APPLICATION_ID,
      INTERFACE_CODE,
      OBJECT_VERSION_NUMBER,
      SEQUENCE_NUM,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
    )
    VALUES
    ( 1,
      intf_rec.INTERFACE_COL_NAME,
      'Y',
      'N',
      'Y',
      'N',
      'Y',
      'N',
      'N',
      2,
      2000,
      l_max_sequence_num*10,
      TO_NUMBER(SUBSTR(intf_rec.INTERFACE_COL_NAME, 12)) + 8,
      274,
      p_interface_code,
      1,
      l_max_sequence_num,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_login_id
    );

    INSERT INTO BNE_INTERFACE_COLS_TL
    (
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      USER_HINT,
      PROMPT_LEFT,
      USER_HELP_TEXT,
      PROMPT_ABOVE,
      INTERFACE_CODE,
      SEQUENCE_NUM,
      APPLICATION_ID,
      LANGUAGE,
      SOURCE_LANG
    )
    SELECT l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      NULL
    ,      intf_rec.INTERFACE_COL_NAME
    ,      NULL
    ,      intf_rec.INTERFACE_COL_NAME
    ,      p_interface_code
    ,      l_max_sequence_num
    ,      274
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_LANGUAGES L
    WHERE  L.INSTALLED_FLAG IN ('I', 'B');

    END LOOP;

  IF ( FND_API.To_Boolean( p_char => p_commit) ) THEN
    COMMIT;
  END IF;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Dim_Intf_Attr_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Dim_Intf_Attr_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Dim_Intf_Attr_Cols_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
   --
END Populate_Dim_Intf_Attr_Cols;


PROCEDURE Populate_Dim_Layout (
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2,
  p_integrator_code              IN           VARCHAR2,
  p_interface_code               IN           VARCHAR2,
  p_dimension_varchar_label      IN           VARCHAR2,
  p_dimension_name               IN           VARCHAR2,
  p_object_code                  IN           VARCHAR2,
  p_dimension_type_code          IN           VARCHAR2,
  p_value_set_required_flag      IN           VARCHAR2,
  p_group_use_code               IN           VARCHAR2
)
IS
  --
  l_api_name    CONSTANT      VARCHAR2(30) := 'Populate_Dim_Layout';
  l_api_version CONSTANT      NUMBER := 1.0;
  --
  l_user_id                      NUMBER(15)    := 2; --   (user name : initial setup)
  l_login_id                     NUMBER        := NVL(Fnd_Global.Login_Id, 0);

  l_existed_flag                 VARCHAR2(1)   := 'N';
  l_layout_code                  BNE_LAYOUTS_B.LAYOUT_CODE%TYPE;
  l_header_block_id              BNE_LAYOUT_BLOCKS_B.BLOCK_ID%TYPE;
  l_line_block_id                BNE_LAYOUT_BLOCKS_B.BLOCK_ID%TYPE;
  l_interface_seq_num            BNE_LAYOUT_COLS.SEQUENCE_NUM%TYPE;

  l_header_block_cols FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30
                                                  ( 'P_DIMENSION_VARCHAR_LABEL'
                                                  , 'MEMBER_GROUP_VALIDATOR'
                                                  , 'P_LEDGER_ID'
                                                  , 'P_CALENDAR_DISPLAY_CODE');

  l_line_block_cols   FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30
                                                  ( 'P_MEMBER_NAME'
                                                  , 'P_MEMBER_DISPLAY_CODE'
                                                  , 'P_MEMBER_DESCRIPTION'
                                                  , 'P_DIMENSION_GROUP_DISPLAY_CODE');

  l_default_ledger_query VARCHAR2(150) := 'select ledger_name from fem_ledgers_vl where ledger_id =
  (select FND_PROFILE.VALUE_SPECIFIC(''FEM_LEDGER'') from dual)'; -- Bug#5533480


BEGIN
  --
  SAVEPOINT Dim_Layout_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  l_layout_code := p_object_code || '_LAYOUT';

  BEGIN
    SELECT 'Y'
    INTO   l_existed_flag
    FROM   BNE_LAYOUTS_B
    WHERE  APPLICATION_ID = 274
    AND    LAYOUT_CODE = l_layout_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_existed_flag = 'N') THEN
    ---------------------------------------------------------------------------
    -- Create Layout in BNE_LAYOUTS_B and BNE_LAYOUTS_TL
    ---------------------------------------------------------------------------
    INSERT INTO BNE_LAYOUTS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , OBJECT_VERSION_NUMBER
    , STYLESHEET_APP_ID
    , STYLESHEET_CODE
    , INTEGRATOR_APP_ID
    , INTEGRATOR_CODE
    , STYLE
    , STYLE_CLASS
    , REPORTING_FLAG
    , REPORTING_INTERFACE_APP_ID
    , REPORTING_INTERFACE_CODE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , CREATE_DOC_LIST_APP_ID
    , CREATE_DOC_LIST_CODE
    )
    VALUES
    ( 274
    , l_layout_code
    , 1
    , 231
    , 'DEFAULT'
    , 274
    , p_integrator_code
    , NULL
    , 'BNE_PAGE'
    , 'N'
    , NULL
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    , NULL
    , NULL
    );

    INSERT INTO BNE_LAYOUTS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      SUBSTR(M.MESSAGE_TEXT,0, INSTR(M.MESSAGE_TEXT, 'DIM_NAME')-2) ||
           DT.DIMENSION_NAME ||
           SUBSTR(M.MESSAGE_TEXT,INSTR(M.MESSAGE_TEXT, 'DIM_NAME')+8)
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      DT.LANGUAGE
    ,      DT.SOURCE_LANG
    FROM   FEM_DIMENSIONS_TL DT
    ,      FEM_DIMENSIONS_B DB
    ,      FND_NEW_MESSAGES M
    ,      FND_LANGUAGES L
    WHERE  DB.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
    AND    DT.DIMENSION_ID = DB.DIMENSION_ID
    AND    M.APPLICATION_ID= 274
    AND    M.MESSAGE_NAME = 'FEM_ADI_MEMBER_LAYOUT'
    AND    M.LANGUAGE_CODE = DT.LANGUAGE
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;

  -----------------------------------------------------------------------------
  -- Creaate header block within the layout
  -----------------------------------------------------------------------------
  BEGIN
    SELECT B.BLOCK_ID
    INTO   l_header_block_id
    FROM   BNE_LAYOUT_BLOCKS_B B
    WHERE  B.APPLICATION_ID = 274
    AND    B.LAYOUT_CODE = l_layout_code
    AND    B.LAYOUT_ELEMENT = 'HEADER';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_header_block_id IS NULL) THEN
    ---------------------------------------------------------------------------
    -- Insert a new block into BNE_LAYOUT_BLOCKS_B
    ---------------------------------------------------------------------------
    l_header_block_id := 1;

    INSERT INTO BNE_LAYOUT_BLOCKS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , OBJECT_VERSION_NUMBER
    , PARENT_ID
    , LAYOUT_ELEMENT
    , STYLE_CLASS
    , STYLE
    , ROW_STYLE_CLASS
    , ROW_STYLE
    , COL_STYLE_CLASS
    , COL_STYLE
    , PROMPT_DISPLAYED_FLAG
    , PROMPT_STYLE_CLASS
    , PROMPT_STYLE
    , HINT_DISPLAYED_FLAG
    , HINT_STYLE_CLASS
    , HINT_STYLE
    , ORIENTATION
    , LAYOUT_CONTROL
    , DISPLAY_FLAG
    , BLOCKSIZE
    , MINSIZE
    , MAXSIZE
    , SEQUENCE_NUM
    , PROMPT_COLSPAN
    , HINT_COLSPAN
    , ROW_COLSPAN
    , SUMMARY_STYLE_CLASS
    , SUMMARY_STYLE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    ) VALUES
    ( 274
    , l_layout_code
    , l_header_block_id
    , 1
    , NULL
    , 'HEADER'
    , 'BNE_HEADER'
    , NULL
    , 'BNE_HEADER_ROW'
    , NULL
    , NULL
    , NULL
    , 'Y'
    , 'BNE_HEADER_HEADER'
    , NULL
    , 'Y'
    , 'BNE_HEADER_HINT'
    , NULL
    , 'HORIZONTAL'
    , 'COLUMN_FLOW'
    , 'Y'
    , 1
    , 1
    , 1
    , 10
    , 3
    , 1
    , 2
    , 'BNE_LINES_TOTAL'
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    );

    INSERT INTO BNE_LAYOUT_BLOCKS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      l_header_block_id
    ,      M.MESSAGE_TEXT
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M,
           FND_LANGUAGES L
    WHERE  M.MESSAGE_NAME = 'LAY_LB_HEADER'
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;


  -----------------------------------------------------------------------------
  -- Creaate line block within the layout
  -----------------------------------------------------------------------------
  BEGIN
    SELECT B.BLOCK_ID
    INTO   l_line_block_id
    FROM   BNE_LAYOUT_BLOCKS_B B
    WHERE  B.APPLICATION_ID = 274
    AND    B.LAYOUT_CODE = l_layout_code
    AND    B.LAYOUT_ELEMENT = 'LINE'
    AND    B.PARENT_ID =
    (
      SELECT BLOCK_ID
      FROM   BNE_LAYOUT_BLOCKS_B
      WHERE  APPLICATION_ID = B.APPLICATION_ID
      AND    LAYOUT_CODE = B.LAYOUT_CODE
      AND    LAYOUT_ELEMENT = 'HEADER'
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_line_block_id IS NULL) THEN
    ---------------------------------------------------------------------------
    -- Insert Line block into the layout
    ---------------------------------------------------------------------------
    l_line_block_id := 2;
    INSERT INTO BNE_LAYOUT_BLOCKS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , OBJECT_VERSION_NUMBER
    , PARENT_ID
    , LAYOUT_ELEMENT
    , STYLE_CLASS
    , STYLE
    , ROW_STYLE_CLASS
    , ROW_STYLE
    , COL_STYLE_CLASS
    , COL_STYLE
    , PROMPT_DISPLAYED_FLAG
    , PROMPT_STYLE_CLASS
    , PROMPT_STYLE
    , HINT_DISPLAYED_FLAG
    , HINT_STYLE_CLASS
    , HINT_STYLE
    , ORIENTATION
    , LAYOUT_CONTROL
    , DISPLAY_FLAG
    , BLOCKSIZE
    , MINSIZE
    , MAXSIZE
    , SEQUENCE_NUM
    , PROMPT_COLSPAN
    , HINT_COLSPAN
    , ROW_COLSPAN
    , SUMMARY_STYLE_CLASS
    , SUMMARY_STYLE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    ) VALUES
    ( 274
    , l_layout_code
    , l_line_block_id
    , 1
    , l_header_block_id
    , 'LINE'
    , 'BNE_LINES'
    , NULL
    , 'BNE_LINES_ROW'
    , NULL
    , NULL
    , NULL
    , 'Y'
    , 'BNE_LINES_HEADER'
    , NULL
    , 'Y'
    , 'BNE_LINES_HINT'
    , NULL
    , 'VERTICAL'
    , 'TABLE_FLOW'
    , 'Y'
    , 10
    , 1
    , 1
    , 20
    , NULL
    , NULL
    , NULL
    , 'BNE_LINES_TOTAL'
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    );

    INSERT INTO BNE_LAYOUT_BLOCKS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      l_line_block_id
    ,      M.MESSAGE_TEXT
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M,
           FND_LANGUAGES L
    WHERE  M.MESSAGE_NAME = 'LAY_LB_LINE'
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;

  -----------------------------------------------------------------------------
  -- Insert into BNE_LAYOUT_COLS
  -----------------------------------------------------------------------------
  BEGIN
    SELECT NVL(MAX(A.INTERFACE_SEQ_NUM), 0)
    INTO   l_interface_seq_num
    FROM   BNE_LAYOUT_COLS A
    WHERE  A.APPLICATION_ID = 274
    AND    A.BLOCK_ID = l_header_block_id
    AND    A.LAYOUT_CODE = l_layout_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF(l_interface_seq_num = 0) THEN
    ---------------------------------------------------------------------------
    -- Insert into BNE_LAYOUT_COLS for the header block
    ---------------------------------------------------------------------------
    INSERT INTO BNE_LAYOUT_COLS
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , OBJECT_VERSION_NUMBER
    , INTERFACE_APP_ID
    , INTERFACE_CODE
    , INTERFACE_SEQ_NUM
    , SEQUENCE_NUM
    , STYLE
    , STYLE_CLASS
    , HINT_STYLE
    , HINT_STYLE_CLASS
    , PROMPT_STYLE
    , PROMPT_STYLE_CLASS
    , DEFAULT_TYPE
    , DEFAULT_VALUE
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    )
    VALUES
    ( 274
    , l_layout_code
    , l_header_block_id
    , 1
    , 274
    , 'FEM_DIM_MEMBER_HEADER_INTF'
    , 1
    , 1
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    , SYSDATE
    );

  END IF;

  ------------------------------------------------------------------------------
  -- Update the block id for header block
  ------------------------------------------------------------------------------
  UPDATE BNE_LAYOUT_COLS
  SET    BLOCK_ID = l_header_block_id
  WHERE  APPLICATION_ID = 274
  AND    LAYOUT_CODE = l_layout_code
  AND    INTERFACE_APP_ID = 274
  AND    INTERFACE_CODE = p_interface_code
  AND    INTERFACE_SEQ_NUM IN
  (
      SELECT SEQUENCE_NUM
      FROM BNE_INTERFACE_COLS_B I
      WHERE I.APPLICATION_ID = 274
      AND   I.INTERFACE_CODE = p_interface_code
      AND   I.INTERFACE_COL_NAME IN (
            SELECT column_value
            FROM TABLE(CAST(l_header_block_cols AS FND_TABLE_OF_VARCHAR2_30))
            )
  )
  AND   BLOCK_ID <> l_header_block_id;

  ------------------------------------------------------------------------------
  -- Insert into the header block if the columns are not existed
  ------------------------------------------------------------------------------

  FOR intf_rec IN
  (
    SELECT INTERFACE_COL_NAME
    ,      SEQUENCE_NUM
    ,      DECODE (INTERFACE_COL_NAME, 'P_DIMENSION_VARCHAR_LABEL', 'CONSTANT','P_LEDGER_ID','SQL',
           NULL) AS DEFAULT_TYPE
    ,      DECODE (INTERFACE_COL_NAME, 'P_DIMENSION_VARCHAR_LABEL', p_dimension_varchar_label,'P_LEDGER_ID',l_default_ledger_query,
           NULL) AS DEFAULT_VALUE  /* Bug#5533480 */
    FROM BNE_INTERFACE_COLS_B IC
    WHERE APPLICATION_ID = 274
    AND   INTERFACE_CODE = p_interface_code
    AND   INTERFACE_COL_NAME IN (
          SELECT column_value
          FROM TABLE(CAST(l_header_block_cols AS FND_TABLE_OF_VARCHAR2_30))
          )
    AND   NOT EXISTS
          (
            SELECT 1
                FROM   BNE_LAYOUT_COLS
                WHERE  APPLICATION_ID = 274
                AND    LAYOUT_CODE = l_layout_code
                AND    INTERFACE_APP_ID = 274
              AND    INTERFACE_CODE = p_interface_code
                AND    INTERFACE_SEQ_NUM = IC.SEQUENCE_NUM
                AND    BLOCK_ID = l_header_block_id
          )
  )
  LOOP
    IF NOT((p_dimension_type_code <> 'TIME' AND intf_rec.INTERFACE_COL_NAME = 'P_CALENDAR_DISPLAY_CODE') OR
      (p_value_set_required_flag = 'N' AND intf_rec.INTERFACE_COL_NAME = 'P_LEDGER_ID')) THEN
      INSERT INTO BNE_LAYOUT_COLS
      ( APPLICATION_ID
      , LAYOUT_CODE
      , BLOCK_ID
      , OBJECT_VERSION_NUMBER
      , INTERFACE_APP_ID
      , INTERFACE_CODE
      , INTERFACE_SEQ_NUM
      , SEQUENCE_NUM
      , STYLE
      , STYLE_CLASS
      , HINT_STYLE
      , HINT_STYLE_CLASS
      , PROMPT_STYLE
      , PROMPT_STYLE_CLASS
      , DEFAULT_TYPE
      , DEFAULT_VALUE
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , LAST_UPDATE_DATE
      )
      VALUES
      ( 274
      , l_layout_code
      , l_header_block_id
      , 1
      , 274
      , p_interface_code
      , intf_rec.SEQUENCE_NUM
      , intf_rec.SEQUENCE_NUM * 10
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , NULL
      , intf_rec.DEFAULT_TYPE
      , intf_rec.DEFAULT_VALUE
      , l_user_id
      , SYSDATE
      , l_user_id
      , l_login_id
      , SYSDATE
      );
    END IF;

  END LOOP;

  ------------------------------------------------------------------------------
  -- Update the block id for line block
  ------------------------------------------------------------------------------
  UPDATE BNE_LAYOUT_COLS
  SET    BLOCK_ID = l_line_block_id
  WHERE  APPLICATION_ID = 274
  AND    LAYOUT_CODE = l_layout_code
  AND    INTERFACE_APP_ID = 274
  AND    INTERFACE_CODE = p_interface_code
  AND    INTERFACE_SEQ_NUM IN
  (
      SELECT SEQUENCE_NUM
      FROM BNE_INTERFACE_COLS_B I
      WHERE I.APPLICATION_ID = 274
      AND   I.INTERFACE_CODE = p_interface_code
      AND   I.INTERFACE_COL_NAME IN (
             SELECT column_value
             FROM TABLE(CAST(l_line_block_cols AS FND_TABLE_OF_VARCHAR2_30))
            )
  )
  AND   BLOCK_ID <> l_line_block_id;

  -----------------------------------------------------------------------------
  -- Assign value to the BNE_LAYOUT_COLS for the line block
  -----------------------------------------------------------------------------
  -- Delete those columns that are not stored in the FEM_WEBADI_DIM_ATTR_MAPS
  DELETE BNE_LAYOUT_COLS
  WHERE  APPLICATION_ID = 274
  AND    INTERFACE_CODE = p_interface_code
  AND    INTERFACE_SEQ_NUM IN
  ( SELECT I.SEQUENCE_NUM
    FROM   BNE_INTERFACE_COLS_B I
    WHERE  I.APPLICATION_ID = INTERFACE_APP_ID
    AND    I.INTERFACE_CODE = INTERFACE_CODE
    AND    I.INTERFACE_COL_NAME LIKE 'P_ATTRIBUTE%'
    AND   NOT EXISTS
    (
      SELECT 1
      FROM   FEM_WEBADI_DIM_ATTR_MAPS M
      WHERE  M.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
      AND    M.INTERFACE_COL = I.INTERFACE_COL_NAME
    )
  );


  ------------------------------------------------------------------------------
  -- Delete from layout_cols for both blocks
  ------------------------------------------------------------------------------
  DELETE BNE_LAYOUT_COLS
  WHERE  APPLICATION_ID = 274
  AND    LAYOUT_CODE = l_layout_code
  AND    INTERFACE_APP_ID = 274
  AND    INTERFACE_CODE = p_interface_code
  AND    INTERFACE_SEQ_NUM NOT IN
  (
      SELECT SEQUENCE_NUM
      FROM BNE_INTERFACE_COLS_B I
      WHERE I.APPLICATION_ID = 274
      AND   I.INTERFACE_CODE = p_interface_code
      AND   (I.INTERFACE_COL_NAME IN (
             SELECT column_value
             FROM TABLE(CAST(l_header_block_cols AS FND_TABLE_OF_VARCHAR2_30))
            )
            OR
            I.INTERFACE_COL_NAME IN (
             SELECT column_value
             FROM TABLE(CAST(l_line_block_cols AS FND_TABLE_OF_VARCHAR2_30))
            )
            OR I.INTERFACE_COL_NAME LIKE 'P_ATTRIBUTE%'
            )
  );

  -----------------------------------------------------------------------------
  -- Insert into BNE_LAYOUT_COLS for the line block
  -----------------------------------------------------------------------------
  -- Insert the common interface column first
  INSERT INTO BNE_LAYOUT_COLS
  ( APPLICATION_ID
  , LAYOUT_CODE
  , BLOCK_ID
  , OBJECT_VERSION_NUMBER
  , INTERFACE_APP_ID
  , INTERFACE_CODE
  , INTERFACE_SEQ_NUM
  , SEQUENCE_NUM
  , STYLE
  , STYLE_CLASS
  , HINT_STYLE
  , HINT_STYLE_CLASS
  , PROMPT_STYLE
  , PROMPT_STYLE_CLASS
  , DEFAULT_TYPE
  , DEFAULT_VALUE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , LAST_UPDATE_DATE
  )
  SELECT 274
  ,      l_layout_code
  ,      l_line_block_id
  ,      1
  ,      274
  ,      p_interface_code
  ,      IC.SEQUENCE_NUM
  ,      IC.SEQUENCE_NUM * 10
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      l_user_id
  ,      SYSDATE
  ,      l_user_id
  ,      l_login_id
  ,      SYSDATE
  FROM   BNE_INTERFACE_COLS_B IC
  WHERE  APPLICATION_ID = 274
  AND    IC.INTERFACE_CODE = p_interface_code
  AND (  ( p_group_use_code = 'NOT_SUPPORTED'
           AND NOT IC.INTERFACE_COL_NAME =
                  DECODE(p_group_use_code, 'NOT_SUPPORTED', 'P_DIMENSION_GROUP_DISPLAY_CODE', IC.INTERFACE_COL_NAME)
         )
         OR
         ( p_group_use_code <> 'NOT_SUPPORTED'
           AND IC.INTERFACE_COL_NAME =
               DECODE(p_group_use_code, 'NOT_SUPPORTED', 'P_DIMENSION_GROUP_DISPLAY_CODE', IC.INTERFACE_COL_NAME)
        )
      )
  AND    INTERFACE_COL_NAME IN (
           SELECT column_value
           FROM TABLE(CAST(l_line_block_cols AS FND_TABLE_OF_VARCHAR2_30))
         )
  AND    NOT EXISTS
  ( SELECT 1
    FROM   BNE_LAYOUT_COLS LC
    WHERE  LC.APPLICATION_ID = IC.APPLICATION_ID
    AND    LC.LAYOUT_CODE = l_layout_code
    AND    LC.BLOCK_ID = l_line_block_id
    AND    LC.INTERFACE_APP_ID = IC.APPLICATION_ID
    AND    LC.INTERFACE_CODE = IC.INTERFACE_CODE
    AND    LC.INTERFACE_SEQ_NUM = IC. SEQUENCE_NUM
  );

   --Bug#6474936:Delete Member Display Code layout col for Calendar period
   IF(p_dimension_varchar_label = 'CAL_PERIOD') THEN
     DELETE FROM BNE_LAYOUT_COLS WHERE LAYOUT_CODE = l_layout_code AND INTERFACE_CODE = p_interface_code
     AND INTERFACE_SEQ_NUM = (SELECT SEQUENCE_NUM FROM BNE_INTERFACE_COLS_B WHERE INTERFACE_CODE = p_interface_code
     AND INTERFACE_COL_NAME = 'P_MEMBER_DISPLAY_CODE');
   END IF;

  -- Inser the attribute interface columns
  INSERT INTO BNE_LAYOUT_COLS
  ( APPLICATION_ID
  , LAYOUT_CODE
  , BLOCK_ID
  , OBJECT_VERSION_NUMBER
  , INTERFACE_APP_ID
  , INTERFACE_CODE
  , INTERFACE_SEQ_NUM
  , SEQUENCE_NUM
  , STYLE
  , STYLE_CLASS
  , HINT_STYLE
  , HINT_STYLE_CLASS
  , PROMPT_STYLE
  , PROMPT_STYLE_CLASS
  , DEFAULT_TYPE
  , DEFAULT_VALUE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , LAST_UPDATE_DATE
  )
  SELECT 274
  ,      l_layout_code
  ,      l_line_block_id
  ,      1
  ,      274
  ,      p_interface_code
  ,      IC.SEQUENCE_NUM
  ,      IC.SEQUENCE_NUM * 10
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      NULL
  ,      l_user_id
  ,      SYSDATE
  ,      l_user_id
  ,      l_login_id
  ,      SYSDATE
  FROM  BNE_INTERFACE_COLS_B IC
  WHERE APPLICATION_ID = 274
  AND   IC.INTERFACE_CODE = p_interface_code
  AND   EXISTS
  ( SELECT 1
    FROM   FEM_WEBADI_DIM_ATTR_MAPS M
    WHERE  M.DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label
    AND    M.INTERFACE_COL = INTERFACE_COL_NAME
  )
  AND    NOT EXISTS
  ( SELECT 1
    FROM   BNE_LAYOUT_COLS LC
    WHERE  LC.APPLICATION_ID = IC.APPLICATION_ID
    AND    LC.LAYOUT_CODE = l_layout_code
    AND    LC.BLOCK_ID = l_line_block_id
    AND    LC.INTERFACE_APP_ID = IC.APPLICATION_ID
    AND    LC.INTERFACE_CODE = IC.INTERFACE_CODE
    AND    LC.INTERFACE_SEQ_NUM = IC. SEQUENCE_NUM
  );

  IF ( FND_API.To_Boolean( p_char => p_commit) ) THEN
    COMMIT;
  END IF;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Dim_Layout_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Dim_Layout_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Dim_Layout_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
   --
END Populate_Dim_Layout;


PROCEDURE Populate_Mem_WebADI_Metadata (
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2,
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  p_dimension_varchar_label      IN           VARCHAR2
)
IS
  --
  l_api_name    CONSTANT      VARCHAR2(30) := 'Populate_Mem_WebADI_Metadata';
  l_api_version CONSTANT      NUMBER := 1.0;
  --
  l_dimension_id              NUMBER(9)     ;
  l_user_id                   NUMBER(15)    := 2; --   (user name : initial setup)

  l_object_code               VARCHAR2(30)  ;
  l_dimension_type_code       VARCHAR2(30)  ;
  l_dimension_name            VARCHAR2(80)  ;
  l_group_use_code            VARCHAR2(30)  ;
  l_value_set_required_flag   VARCHAR2(1)   ;
  l_integrator_code           VARCHAR2(30)  := 'FEM_DIM_MEMBER_INTG';
  l_interface_code            VARCHAR2(30)  ;
  l_interface_name            VARCHAR2(50)  ;
  l_intg_upl_param_list_code  VARCHAR2(30)  := 'FEM_DIM_MEMBER_UPL_LIST';
  l_intg_imp_param_list_code  VARCHAR2(30)  := 'FEM_DIM_MEMBER_IMP_LIST';
  l_intf_upl_param_list_code  VARCHAR2(30)  := 'FEM_DIM_MEMBER';
  l_row_id                    VARCHAR2(30)  ;
  l_existed_flag              VARCHAR2(1)   ;
  l_updated_flag              VARCHAR2(10)  ;
  l_order_seq                 NUMBER(9)     ;

  --
  l_return_status             VARCHAR2(1) ;
  l_msg_count                 NUMBER ;
  l_msg_data                  VARCHAR2(2000) ;

  TYPE l_dim_name_tbl_type is TABLE of
    FEM_DIMENSIONS_TL.DIMENSION_NAME%TYPE index by BINARY_INTEGER;

  TYPE l_dim_lang_tbl_type is TABLE of
    FEM_DIMENSIONS_TL.LANGUAGE%TYPE index by BINARY_INTEGER;

  TYPE l_dim_src_lang_tbl_type is TABLE of
    FEM_DIMENSIONS_TL.SOURCE_LANG%TYPE index by BINARY_INTEGER;

BEGIN
  --
  SAVEPOINT Dim_WebADI_Metadata_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  SELECT DIMENSION_ID
  ,      DIMENSION_NAME
  ,      'FEM_DIM_' || DIMENSION_ID
  ,      'UPLOAD_MEMBER_INTERFACE' || DIMENSION_ID
  ,      DIMENSION_TYPE_CODE
  ,      VALUE_SET_REQUIRED_FLAG
  ,      GROUP_USE_CODE
  INTO   l_dimension_id
  ,      l_dimension_name
  ,      l_object_code
  ,      l_interface_name
  ,      l_dimension_type_code
  ,      l_value_set_required_flag
  ,      l_group_use_code
  FROM FEM_XDIM_DIMENSIONS_VL
  WHERE DIMENSION_VARCHAR_LABEL = p_dimension_varchar_label;


  IF SQL%NOTFOUND THEN
    RAISE NO_DATA_FOUND;
  END IF;

  /*
  -- print out the fetched metadata
  IF SQL%FOUND THEN
    pd('l_dimension_id            = ' || TO_CHAR(l_dimension_id));
    pd('l_object_code             = ' || l_object_code);
    pd('l_dimension_type_code     = ' || l_dimension_type_code);
    pd('l_value_set_required_flag = ' || l_value_set_required_flag);
  END IF;
  */

  -----------------------------------------------------------------------------
  -- Handling Integrator
  -----------------------------------------------------------------------------
  BEGIN
    SELECT 'Y'
    INTO   l_existed_flag
    FROM   BNE_INTEGRATORS_B
    WHERE  APPLICATION_ID = 274
    AND    INTEGRATOR_CODE = l_integrator_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- If the Integrator does not exist then insert the integrator

  IF (l_existed_flag IS NULL) THEN

    INSERT INTO BNE_INTEGRATORS_B
      ( APPLICATION_ID
      , INTEGRATOR_CODE
      , OBJECT_VERSION_NUMBER
      , UPLOAD_PARAM_LIST_APP_ID
      , UPLOAD_PARAM_LIST_CODE
      , UPLOAD_SERV_PARAM_LIST_APP_ID
      , UPLOAD_SERV_PARAM_LIST_CODE
      , IMPORT_PARAM_LIST_APP_ID
      , IMPORT_PARAM_LIST_CODE
      , IMPORT_TYPE
      , UPLOADER_CLASS
      , DATE_FORMAT
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , ENABLED_FLAG)
    VALUES
      ( 274
      , l_integrator_code
      , 1
      , 274
      , l_intg_upl_param_list_code
      , 231
      , 'UPL_SERV_INTERF_COLS'
      , 274
      , l_intg_imp_param_list_code
      , 1
      , 'oracle.apps.bne.integrator.upload.BneUploader'
      , 'yyyy-MM-dd'
      , l_user_id
      , SYSDATE
      , l_user_id
      , SYSDATE
      , 'Y');

    INSERT INTO BNE_INTEGRATORS_TL
      ( APPLICATION_ID
      , INTEGRATOR_CODE
      , LANGUAGE
      , SOURCE_LANG
      , USER_NAME
      , UPLOAD_HEADER
      , UPLOAD_TITLE_BAR
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE)
    SELECT 274
    ,      l_integrator_code
    ,      M.LANGUAGE_CODE
    ,      userenv('LANG')
    ,      M.MESSAGE_TEXT
    ,      'Upload Parameters'
    ,      'Upload Parameters'
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      SYSDATE
    FROM   FND_NEW_MESSAGES M,
           FND_LANGUAGES L
    WHERE  M.MESSAGE_NAME = 'FEM_ADI_MEMBER_INTEGRATOR'
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');
  END IF;

  -----------------------------------------------------------------------------
  -- Handling Interface
  -----------------------------------------------------------------------------

  -- populate attribute maps
  Populate_Dim_Attribute_Maps
  ( x_return_status                => l_return_status,
    x_msg_count                    => l_msg_count,
    x_msg_data                     => l_msg_data,
    p_api_version                  => 1.0,
    p_init_msg_list                => FND_API.G_TRUE,
    p_commit                       => FND_API.G_FALSE,
    p_dimension_varchar_label      => p_dimension_varchar_label
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  l_interface_code := l_object_code || '_INTF';
  l_existed_flag := NULL;

  BEGIN
    SELECT 'Y'
    INTO   l_existed_flag
    FROM   BNE_INTERFACES_B
    WHERE  APPLICATION_ID = 274
    AND    INTERFACE_CODE = l_interface_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  -- If the Interface does not exist then insert the interface

  IF (l_existed_flag IS NULL) THEN

    SELECT NVL(MAX(UPLOAD_ORDER), 0) + 1
    INTO   l_order_seq
    FROM   BNE_INTERFACES_B
    WHERE  APPLICATION_ID = 274
    AND    INTEGRATOR_APP_ID = 274
    AND    INTEGRATOR_CODE = l_integrator_code;

    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

    INSERT INTO BNE_INTERFACES_B
      (APPLICATION_ID,
       INTERFACE_CODE,
       OBJECT_VERSION_NUMBER,
       INTEGRATOR_APP_ID,
       INTEGRATOR_CODE,
       INTERFACE_NAME,
       UPLOAD_TYPE,
       UPLOAD_PARAM_LIST_APP_ID,
       UPLOAD_PARAM_LIST_CODE,
       UPLOAD_ORDER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE)
    VALUES
      (274,
       l_interface_code,
       1,
       274,
       l_integrator_code,
       l_interface_name,
       2,
       274,
       l_intf_upl_param_list_code,
       l_order_seq,
       l_user_id,
       SYSDATE,
       l_user_id,
       SYSDATE);

    -- Create the interface in the BNE_INTERFACES_TL table

    INSERT INTO BNE_INTERFACES_TL
      ( APPLICATION_ID,
        INTERFACE_CODE,
        LANGUAGE,
        SOURCE_LANG,
        USER_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
    SELECT 274
    ,      l_interface_code
    ,      D.LANGUAGE
    ,      D.SOURCE_LANG
    ,      SUBSTR(M.MESSAGE_TEXT,0, INSTR(M.MESSAGE_TEXT, 'DIM_NAME')-2) ||
           D.DIMENSION_NAME ||
           SUBSTR(M.MESSAGE_TEXT,INSTR(M.MESSAGE_TEXT, 'DIM_NAME')+8)
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      SYSDATE
    FROM   FEM_DIMENSIONS_TL D, FND_NEW_MESSAGES M, FND_LANGUAGES L
    WHERE  D.DIMENSION_ID = l_dimension_id
    AND    M.APPLICATION_ID= 274
    AND    M.MESSAGE_NAME = 'FEM_ADI_MEMBER_INTERFACE'
    AND    M.LANGUAGE_CODE = D.LANGUAGE
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');


    -- Update common interface columns

    ---------------------------------------------------------------------------
    -- Populate the common interface columns
    ---------------------------------------------------------------------------

    Populate_Dim_Intf_Common_Cols (
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_interface_code               => l_interface_code,
      p_dimension_varchar_label      => p_dimension_varchar_label,
      p_group_use_code               => l_group_use_code
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;


    ---------------------------------------------------------------------------
    -- Populate the attribute related interface columns
    ---------------------------------------------------------------------------

    Populate_Dim_Intf_Attr_Cols (
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_interface_code               => l_interface_code,
      p_dimension_varchar_label      => p_dimension_varchar_label,
      p_dimension_id                 => l_dimension_id,
      x_updated_flag                 => l_updated_flag
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    l_updated_flag := 'Y';

  ELSE
    -- Update the attribute interface columns

    ---------------------------------------------------------------------------
    -- Populate the attribute related interface columns
    ---------------------------------------------------------------------------
    Populate_Dim_Intf_Attr_Cols (
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_interface_code               => l_interface_code,
      p_dimension_varchar_label      => p_dimension_varchar_label,
      p_dimension_id                 => l_dimension_id,
      x_updated_flag                 => l_updated_flag
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

  END IF;

  -----------------------------------------------------------------------------
  -- Create Layout
  -----------------------------------------------------------------------------
  IF (l_updated_flag = 'Y') THEN

    Populate_Dim_Layout (
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_integrator_code              => l_integrator_code,
      p_interface_code               => l_interface_code,
      p_dimension_varchar_label      => p_dimension_varchar_label,
      p_dimension_name               => l_dimension_name,
      p_object_code                  => l_object_code,
      p_dimension_type_code          => l_dimension_type_code,
      p_value_set_required_flag      => l_value_set_required_flag,
      p_group_use_code               => l_group_use_code
    );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF;

    -- update the object version number in the bne_integrators_b table.
    -- This will fix the new interface caching issue.

    UPDATE BNE_INTEGRATORS_B
    SET    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    --,      LAST_UPDATE_DATE = last_update_date + 1
    WHERE  APPLICATION_ID = 274
    AND    INTEGRATOR_CODE = l_integrator_code;

  END IF;

  IF ( FND_API.To_Boolean( p_char => p_commit) ) THEN
    COMMIT;
  END IF;


EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Dim_WebADI_Metadata_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Dim_WebADI_Metadata_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Dim_WebADI_Metadata_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
   --
END Populate_Mem_WebADI_Metadata;

/*===========================================================================+
Procedure Name       : Populate_Dim_Metadata_Info
Parameters           :
IN                   : p_dimension_varchar_label VARCHAR2
OUT                  : x_return_status           VARCHAR2

Description          : Populates global variables with metadata information
                       of the supplied p_dimension_varchar_label.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Populate_Dim_Metadata_Info
( x_return_status           OUT NOCOPY VARCHAR2
, p_dimension_varchar_label IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT VARCHAR2(30) := 'Populate_Dim_Metadata_Info';
  --
  l_param_info        VARCHAR2(4000) ;
  l_curr_activity     VARCHAR2(4000) ;
  --
  -- Retrieve the metadata information of
  -- the supplied p_dimension_varchar_label.
  CURSOR l_Ret_Dim_Metadata_csr
  IS
  SELECT
    dimension_id
  , intf_member_b_table_name
  , intf_member_tl_table_name
  , intf_attribute_table_name
  , member_b_table_name
  , member_display_code_col
  , member_name_col
  , hierarchy_table_name
  , dimension_type_code
  , group_use_code
  , value_set_required_flag
  FROM
    fem_xdim_dimensions_vl xDimVL
  WHERE
    xDimVL.dimension_varchar_label = p_dimension_varchar_label ;

  -- Retrieve all the mappings for
  -- the supplied dimension to reuse
  -- accross the APIs.
  CURSOR l_Ret_Attr_Mapp_csr
  IS
  SELECT
    AttrMaps.interface_col
  , AttrMaps.attribute_varchar_label
  , AttrMaps.data_type
  FROM
    fem_webadi_dim_attr_maps AttrMaps
  WHERE
    AttrMaps.dimension_varchar_label = p_dimension_varchar_label ;
  --
BEGIN
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_param_info    := 'p_dimension_varchar_label='||p_dimension_varchar_label ;
    l_curr_activity := 'Starting Populate_Dim_Metadata_Info API ' ;
    --
    -- Put the param info into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Parametr Info: ' || l_param_info
    ) ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Initialize object types
  g_interface_col_name_tbl  := FND_TABLE_OF_VARCHAR2_30() ;
  g_attribute_name_tbl      := FND_TABLE_OF_VARCHAR2_30() ;
  g_attribute_data_type_tbl := FND_TABLE_OF_VARCHAR2_30() ;
  --
  g_global_val_tbl.DELETE ;
  --
  -- Bulk collect all attribute mappings into
  -- global PL/SQL tables for further usage.
  OPEN l_Ret_Attr_Mapp_csr ;
  LOOP
    FETCH l_Ret_Attr_Mapp_csr
    BULK COLLECT INTO
      g_interface_col_name_tbl
    , g_attribute_name_tbl
    , g_attribute_data_type_tbl ;
    EXIT WHEN l_Ret_Attr_Mapp_csr%NOTFOUND;
  END LOOP ;
  CLOSE l_Ret_Attr_Mapp_csr ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Bulk operation completed successfully.' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Populate global variables with Dimemension metadata.
  FOR l_ret_dim_metadata_csr_rec IN l_Ret_Dim_Metadata_csr
  LOOP
    g_global_val_tbl(1).dimension_id              :=
      l_ret_dim_metadata_csr_rec.dimension_id ;
    g_global_val_tbl(1).dimension_varchar_label   :=
      p_dimension_varchar_label ;
    g_global_val_tbl(1).intf_member_b_table_name :=
      l_ret_dim_metadata_csr_rec.intf_member_b_table_name ;
    g_global_val_tbl(1).intf_member_tl_table_name :=
      l_ret_dim_metadata_csr_rec.intf_member_tl_table_name ;
    g_global_val_tbl(1).intf_attribute_table_name :=
      l_ret_dim_metadata_csr_rec.intf_attribute_table_name ;
    g_global_val_tbl(1).member_b_table_name       :=
      l_ret_dim_metadata_csr_rec.member_b_table_name ;
    g_global_val_tbl(1).member_display_code_col   :=
      l_ret_dim_metadata_csr_rec.member_display_code_col ;
    g_global_val_tbl(1).member_name_col           :=
      l_ret_dim_metadata_csr_rec.member_name_col ;
    g_global_val_tbl(1).hierarchy_intf_table_name :=
      l_ret_dim_metadata_csr_rec.hierarchy_table_name || '_T' ;
    g_global_val_tbl(1).dimension_type_code       :=
      NVL( l_ret_dim_metadata_csr_rec.dimension_type_code, 'XYZ' ) ;
    g_global_val_tbl(1).group_use_code            :=
      NVL( l_ret_dim_metadata_csr_rec.group_use_code, 'NOT_SUPPORTED' ) ;
    g_global_val_tbl(1).value_set_required_flag   :=
      NVL( l_ret_dim_metadata_csr_rec.value_set_required_flag, 'N' ) ;
  END LOOP ;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Populate_Dim_Metadata_Info API completed ' ||
                       'successfully' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
    END IF ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
    END IF ;
    --
  WHEN OTHERS THEN
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
    END IF ;
    --
END Populate_Dim_Metadata_Info ;

-----------------------------
-- Write Public Procedures --
-----------------------------

/*===========================================================================+
Procedure Name       : Populate_Dim_Attribute_Maps
Parameters           :
IN                   : p_dimension_varchar_label VARCHAR2
                       p_api_version             NUMBER
                       p_init_msg_list           VARCHAR2
                       p_commit                  VARCHAR2
OUT                  : All standard parameters.

Description          : This procedure stores attributes to the
                       FEM_WebADI_attr_map table for a dimension.
                       Note that this API will be called well
                       before actual upload process to setup the
                       mappings.
Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/22/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Populate_Dim_Attribute_Maps
( x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2
, p_commit                  IN         VARCHAR2
, p_dimension_varchar_label IN         VARCHAR2
)
IS
  --
  l_api_name CONSTANT VARCHAR2(30) := 'Populate_Dim_Attribute_Maps' ;
  l_param_info        VARCHAR2(4000) ;
  l_curr_activity     VARCHAR2(4000) ;
  --
  l_return_status     VARCHAR2(1) ;
  l_msg_count         NUMBER ;
  l_msg_data          VARCHAR2(2000) ;
  --
  l_record_count      NUMBER ;
  --
  l_max_attr_seq      NUMBER  := 0 ;
  l_avlbl_attr_seq    NUMBER  := 0 ;
  l_start_seq         NUMBER  := 1 ;
  l_cnt_rec           NUMBER  := 0 ;
  l_gap_logic_req     BOOLEAN := FALSE ;
  l_used_seq_flag     BOOLEAN := FALSE ;
  --
  l_data_type_tbl     FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30() ;
  l_attr_label_tbl    FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30() ;
  l_avlbl_attrseq_tbl FND_TABLE_OF_NUMBER      := FND_TABLE_OF_NUMBER() ;
  --
  -- Retrieve all mappings for which datatypes are not matching
  -- with corresponding record in dim attribute table for the
  -- input dimension varchar label.
  CURSOR l_changed_datatype_map_csr
  IS
  SELECT
    attrmap.interface_col
  , dimattr.attribute_data_type_code
  FROM
    fem_dim_attributes_b     dimattr
  , fem_xdim_dimensions_vl   xdim
  , fem_webadi_dim_attr_maps attrmap
  WHERE
    attrmap.dimension_varchar_label      =  p_dimension_varchar_label
    AND xdim.dimension_varchar_label     =  attrmap.dimension_varchar_label
    AND dimattr.dimension_id             =  xdim.dimension_id
    AND dimattr.attribute_varchar_label  =  attrmap.attribute_varchar_label
    AND dimattr.attribute_data_type_code <> attrmap.data_type ;
  --
  -- Retrieve all records present in dim attribute table but
  -- absent in attribute mapping table for the input
  -- dimension varchar label.
  CURSOR l_new_dim_attr_rec_csr
  IS
  SELECT
    dimattr.attribute_varchar_label
  , dimattr.attribute_data_type_code
  FROM
    fem_dim_attributes_b   dimattr
  , fem_xdim_dimensions_vl xdim
  WHERE
    xdim.dimension_varchar_label = p_dimension_varchar_label
  AND xdim.dimension_id          = dimattr.dimension_id
  AND NOT EXISTS
  ( SELECT
      attrmap.attribute_varchar_label
    FROM
      fem_webadi_dim_attr_maps attrmap
    WHERE
      attrmap.dimension_varchar_label      = xdim.dimension_varchar_label
      AND attrmap.attribute_varchar_label  = dimattr.attribute_varchar_label
  )
  ORDER BY dimattr.attribute_required_flag DESC;
  --
  -- Retrieve all available mapping sequences for given dimension
  CURSOR l_avlble_col_map_seq_csr
  IS
    SELECT
      VALUE(avlble_seq) col_map_seq
    FROM
      TABLE( CAST( g_sequences_tbl AS FND_TABLE_OF_NUMBER ) ) avlble_seq
    MINUS
    SELECT
      TO_NUMBER( SUBSTR( attrmap.interface_col, 12 ) ) col_map_seq
    FROM
      fem_webadi_dim_attr_maps attrmap
    WHERE
      attrmap.dimension_varchar_label = p_dimension_varchar_label ;
  --
BEGIN
  --
  SAVEPOINT Populate_Dim_Attribute_Maps ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_param_info    := 'p_dimension_varchar_label='||p_dimension_varchar_label ;
    l_curr_activity := 'Starting Populate_Dim_Attribute_Maps API ' ;
    --
    -- Put the param info into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Parametr Info: ' || l_param_info
    ) ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Initialize global PL/SQL tables being used by other APIs.
  g_changed_intf_col_tbl    := g_initialized_table ;
  g_changed_dt_intf_col_tbl := g_initialized_table ;
  --
  -- Delete records present in Mapping table but not in
  -- FEM_DIM_ATTRIBUTES_B table.
  DELETE
  FROM
    fem_webadi_dim_attr_maps attrmap
  WHERE
    attrmap.dimension_varchar_label = p_dimension_varchar_label
    AND attrmap.attribute_varchar_label NOT IN
    ( SELECT
        attr.attribute_varchar_label
      FROM
        fem_dim_attributes_b   attr
      , fem_xdim_dimensions_vl xdim
      WHERE
        xdim.dimension_varchar_label        = attrmap.dimension_varchar_label
          AND attr.dimension_id             = xdim.dimension_id
    ) ;
  --
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Stale records deleted. Now Updating records with ' ||
                       'changed datatype.' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Bulk collect records with changed data type.
  OPEN l_changed_datatype_map_csr ;
  LOOP
    FETCH l_changed_datatype_map_csr
    BULK COLLECT INTO
      g_changed_dt_intf_col_tbl
    , l_data_type_tbl
    LIMIT G_LIMIT_BULK_NUMROWS ;
    --

    IF ( g_changed_dt_intf_col_tbl.COUNT >= 1 )
    THEN
      FORALL l_indx IN 1..g_changed_dt_intf_col_tbl.COUNT
        UPDATE
          fem_webadi_dim_attr_maps attrmap
        SET
          attrmap.data_type = l_data_type_tbl(l_indx)
        WHERE
          attrmap.dimension_varchar_label = p_dimension_varchar_label
          AND attrmap.interface_col       = g_changed_dt_intf_col_tbl(l_indx) ;
    END IF ;
    --
    EXIT WHEN l_changed_datatype_map_csr%NOTFOUND ;
  END LOOP ;
  CLOSE l_changed_datatype_map_csr ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Update of records with changed data type done.' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Find the maximum interface column number
  -- being used by mapping table for the input
  -- dimension varchar label.
  SELECT
    NVL( MAX ( TO_NUMBER( SUBSTR( attrmap.interface_col, 12 ) ) ), 0 )
  , COUNT(1)
  INTO
    l_max_attr_seq
  , l_cnt_rec
  FROM
    fem_webadi_dim_attr_maps attrmap
  WHERE
    attrmap.dimension_varchar_label = p_dimension_varchar_label ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Maximum seq is ' || l_max_attr_seq ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Reinitialize l_data_type_tbl
  l_data_type_tbl.DELETE ;
  --
  -- Bulk collect new mappings present in dim attr table only.
  OPEN l_new_dim_attr_rec_csr ;
  FETCH l_new_dim_attr_rec_csr
  BULK COLLECT INTO
    l_attr_label_tbl
  , l_data_type_tbl ;
  CLOSE l_new_dim_attr_rec_csr ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    FOR l_indx IN 1..l_attr_label_tbl.COUNT
    LOOP
      -- Put attribute details into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Attr_Label: ' || l_attr_label_tbl(l_indx) ||
                     'Attr_Datatype ' ||l_data_type_tbl(l_indx)
      ) ;
      --
    END LOOP ;
  END IF ;
  --
  -- Check whether there is any gap in P_ATTRIBUTE indexes.
  -- If count of records present in map table is lesser than
  -- the highest sequence being used, gap logic should be used.
  IF ( l_max_attr_seq > l_cnt_rec )
  THEN
    l_gap_logic_req := TRUE ;
    --
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Gap logic is required' ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
  END IF ;
  --
  -- If there is no gap, insert the records directly.
  IF ( l_gap_logic_req = FALSE )
  THEN
    --
    -- Populate global table with changed
    -- attributes
    FOR l_indx IN 1..l_attr_label_tbl.COUNT
    LOOP
      g_changed_intf_col_tbl.EXTEND ;
      g_changed_intf_col_tbl(l_indx) :=
        'P_ATTRIBUTE'||(l_max_attr_seq + l_indx) ;
    END LOOP ;
    --
    -- Now Bulk insert attributes in mapping table.
    FORALL l_indx IN 1..l_attr_label_tbl.COUNT
      INSERT INTO
        fem_webadi_dim_attr_maps
        ( interface_col
        , dimension_varchar_label
        , attribute_varchar_label
        , data_type
        )
      VALUES
      ( g_changed_intf_col_tbl( l_indx )
      , p_dimension_varchar_label
      , l_attr_label_tbl(l_indx)
      , l_data_type_tbl(l_indx)
      ) ;
      --
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        --
        l_curr_activity := 'Bulk inserting with no gap logic done.' ;
        --
        -- Put the current activity into log.
        FND_LOG.String
        ( log_level => FND_LOG.LEVEL_STATEMENT
        , module    => l_api_name
        , message   => 'Activity: ' || l_curr_activity
        ) ;
        --
      END IF ;
      --
  ELSE
    -- Retrieve all available mapping sequences for given dimension.
    OPEN l_avlble_col_map_seq_csr ;
    FETCH l_avlble_col_map_seq_csr
    BULK COLLECT INTO
      l_avlbl_attrseq_tbl ;
    CLOSE l_avlble_col_map_seq_csr ;
    --
    IF ( l_avlbl_attrseq_tbl.COUNT < l_attr_label_tbl.COUNT )
    THEN
      APP_EXCEPTION.Raise_Exception ;
    ELSE
      --
      -- Populate global table with changed
      -- attributes
      FOR l_indx IN 1..l_attr_label_tbl.COUNT
      LOOP
        g_changed_intf_col_tbl.EXTEND ;
        g_changed_intf_col_tbl(l_indx) :=
          'P_ATTRIBUTE'||( l_avlbl_attrseq_tbl( l_indx ) ) ;
      END LOOP ;
      -- Now bulk insert records in MApping table.
      FORALL l_indx IN 1..l_attr_label_tbl.COUNT
        INSERT INTO
          fem_webadi_dim_attr_maps
          ( interface_col
          , dimension_varchar_label
          , attribute_varchar_label
          , data_type
          )
        VALUES
        ( g_changed_intf_col_tbl(l_indx)
        , p_dimension_varchar_label
        , l_attr_label_tbl(l_indx)
        , l_data_type_tbl(l_indx)
        ) ;
      --
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        --
        l_curr_activity := 'Bulk insertion with gap logic done.' ;
        --
        -- Put the current activity into log.
        FND_LOG.String
        ( log_level => FND_LOG.LEVEL_STATEMENT
        , module    => l_api_name
        , message   => 'Activity: ' || l_curr_activity
        ) ;
        --
      END IF ;
      --
    END IF ;
  END IF ;
  --
  IF ( FND_API.To_Boolean (p_commit) )
  THEN
    COMMIT ;
  END IF ;
  --
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Populate_Dim_Attribute_Maps completed successfully' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Populate_Dim_Attribute_Maps ;
    --
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
      --
    END IF ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Populate_Dim_Attribute_Maps ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
      --
    END IF ;
    --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Populate_Dim_Attribute_Maps ;
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put exact error message into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
      --
    END IF ;
    --
END Populate_Dim_Attribute_Maps ;

/*===========================================================================+
Procedure Name       : Pop_NonSimple_Dim_Intf_tables
Parameters           :
IN                   : p_dim_grp_disp_code        VARCHAR2
                       p_value_set_required_flag  VARCHAR2
OUT                  : None

Description          : This program populates member interface tables for
                       non TIME dimensions. These tables involve B and TL
                       tables only. The attribute interface table will be
                       populated in Process_Atrribute API.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Pop_NonSimple_Dim_Intf_tables
( p_dim_grp_disp_code       IN VARCHAR2
, p_value_set_required_flag IN VARCHAR2
)
IS
  --
  l_api_name CONSTANT    VARCHAR2(30)   := 'Pop_NonSimple_Dim_Intf_tables';
  l_param_info           VARCHAR2(4000) ;
  l_curr_activity        VARCHAR2(4000) ;
  --
  l_b_table_str          VARCHAR2(4000) := NULL ;
  l_tl_table_str         VARCHAR2(4000) := NULL ;
  l_update_str           VARCHAR2(4000) := NULL ;
  l_b_table_ins_clause   VARCHAR2(4000) := NULL ;
  l_b_table_bind_clause  VARCHAR2(4000) := NULL ;
  l_tl_table_ins_clause  VARCHAR2(4000) := NULL ;
  l_tl_table_bind_clause VARCHAR2(4000) := NULL ;
  --
  l_record_found_count NUMBER         := 0 ;
  --
BEGIN
  --
  l_b_table_ins_clause   := 'INSERT INTO ' ||
                             g_global_val_tbl(1).intf_member_b_table_name ||
                             '( ' ||
                             g_global_val_tbl(1).member_display_code_col ||
                             ', status' ;

  l_b_table_bind_clause  := 'VALUES' ||
                            '( :b_member_display_code' ||
                            ', :b_status' ;
  --
  l_tl_table_ins_clause  := 'INSERT INTO ' ||
                            g_global_val_tbl(1).intf_member_tl_table_name ||
                            '( ' ||
                            g_global_val_tbl(1).member_display_code_col ||
                            ', language' ||
                            ',' ||g_global_val_tbl(1).member_name_col ||
                            ', description' ||
                            ', status' ;

  l_tl_table_bind_clause := 'VALUES' ||
                            '( :b_member_display_code '||
                            ', :b_language' ||
                            ', :b_member_name' ||
                            ', :b_description' ||
                            ', :b_status' ;
  --
  IF ( p_value_set_required_flag = 'Y' ) -- VSR Yes
  THEN
    --
    -- 1st Case:: VSR Yes and Level Yes.
    --
    IF ( p_dim_grp_disp_code IS NOT NULL ) -- Levels Yes
    THEN
      --
      l_b_table_ins_clause  := l_b_table_ins_clause ||
                               ', value_set_display_code' ||
                               ', dimension_group_display_code' ||
                               ')' ;
      --
      l_b_table_bind_clause := l_b_table_bind_clause ||
                               ', :b_value_set_display_code' ||
                               ', :b_dimension_group_display_code' ||
                               ')' ;
      --
      l_b_table_str         := l_b_table_ins_clause || l_b_table_bind_clause ;
      --
      BEGIN
        --
        EXECUTE IMMEDIATE
          l_b_table_str
        USING
          g_global_val_tbl(1).member_display_code
        , 'LOAD'
        , g_global_val_tbl(1).value_set_display_code
        , g_global_val_tbl(1).dim_grp_disp_code ;
        --
      EXCEPTION
        --
        WHEN DUP_VAL_ON_INDEX THEN
          --
          l_update_str := 'UPDATE ' ||
                             g_global_val_tbl(1).intf_member_b_table_name ||
                          ' SET ' ||
                            'status = :b_status' ||
                            ', dimension_group_display_code = ' ||
                            ':b_dimension_group_display_code' ||
                          ' WHERE ' ||
                            g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_display_code' ||
                            ' AND value_set_display_code = ' ||
                            ':b_value_set_display_code' ;
        --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            'LOAD'
          , g_global_val_tbl(1).dim_grp_disp_code
          , g_global_val_tbl(1).member_display_code
          , g_global_val_tbl(1).value_set_display_code ;
          --
      END ;
      --
    ELSE --IF ( p_dim_grp_disp_code IS NULL ) -- Levels No
      --
      -- 2nd Case:: VSR Yes and Level No.
      --
      l_b_table_ins_clause  := l_b_table_ins_clause ||
                              ', value_set_display_code' ||
                              ')' ;
      --
      l_b_table_bind_clause := l_b_table_bind_clause ||
                               ', :b_value_set_display_code' ||
                               ')' ;
      --
      l_b_table_str         := l_b_table_ins_clause || l_b_table_bind_clause ;
      --
      BEGIN
        --
        EXECUTE IMMEDIATE
          l_b_table_str
        USING
           g_global_val_tbl(1).member_display_code
        , 'LOAD'
        , g_global_val_tbl(1).value_set_display_code ;
        --
      EXCEPTION
        --
        WHEN DUP_VAL_ON_INDEX THEN
          --
          l_update_str := 'UPDATE ' ||
                             g_global_val_tbl(1).intf_member_b_table_name ||
                          ' SET ' ||
                            'status = :b_status' ||
                          ' WHERE ' ||
                            g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_display_code' ||
                            ' AND value_set_display_code = ' ||
                            ':b_value_set_display_code' ;
          --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            'LOAD'
          , g_global_val_tbl(1).member_display_code
          , g_global_val_tbl(1).value_set_display_code ;
          --
      END ;
      --
    END IF ;  --IF ( p_dim_grp_disp_code IS NOT NULL ) Ends
    --
    -- Now put the data into TL table.
    --
    l_tl_table_ins_clause  := l_tl_table_ins_clause ||
                            ', value_set_display_code' ||
                            ')' ;
    --
    l_tl_table_bind_clause := l_tl_table_bind_clause ||
                             ', :b_value_set_display_code' ||
                             ')' ;
    --
    l_tl_table_str         := l_tl_table_ins_clause || l_tl_table_bind_clause ;
    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_tl_table_str
      USING
        g_global_val_tbl(1).member_display_code
      , g_session_language
      , g_global_val_tbl(1).member_name
      , g_global_val_tbl(1).member_description
      , 'LOAD'
      , g_global_val_tbl(1).value_set_display_code ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                           g_global_val_tbl(1).intf_member_tl_table_name ||
                        ' SET ' ||
                        g_global_val_tbl(1).member_name_col ||
                        ' = :b_member_name ' ||
                        ', description   = :b_description ' ||
                        ', status        = :b_status ' ||
                        ' WHERE ' ||
                          g_global_val_tbl(1).member_display_code_col ||
                          ' = :b_member_display_code' ||
                          ' AND value_set_display_code = ' ||
                          ':b_value_set_display_code' ||
                          ' AND language = :b_language ' ;
        --
        EXECUTE IMMEDIATE
          l_update_str
        USING
          g_global_val_tbl(1).member_name
        , g_global_val_tbl(1).member_description
        , 'LOAD'
        , g_global_val_tbl(1).member_display_code
        , g_global_val_tbl(1).value_set_display_code
        , g_session_language ;
        --
        IF ( SQL%ROWCOUNT = 0 )
        THEN
          --
          RAISE ;
          --
        END IF ;
        --
    END ;
    --
  ELSE  -- IF ( p_value_set_required_flag <> 'Y' )
    --
    -- 3rd Case:: VSR No and Level Yes.
    --
    IF ( p_dim_grp_disp_code IS NOT NULL )
    THEN
      --
      l_b_table_ins_clause := l_b_table_ins_clause ||
                              ', dimension_group_display_code' ||
                              ')' ;
      --
      l_b_table_bind_clause := l_b_table_bind_clause ||
                               ', :b_dimension_group_display_code' ||
                               ')' ;
      --
      l_b_table_str         := l_b_table_ins_clause || l_b_table_bind_clause ;
      --
      BEGIN
        --
        EXECUTE IMMEDIATE
          l_b_table_str
        USING
          g_global_val_tbl(1).member_display_code
        , 'LOAD'
        , g_global_val_tbl(1).dim_grp_disp_code ;
        --
      EXCEPTION
        --
        WHEN DUP_VAL_ON_INDEX THEN
          --
          l_update_str := 'UPDATE ' ||
                             g_global_val_tbl(1).intf_member_b_table_name ||
                          ' SET ' ||
                            'status = :b_status' ||
                            ', dimension_group_display_code = ' ||
                            ':b_dimension_group_display_code' ||
                          ' WHERE ' ||
                            g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_display_code' ;
          --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            'LOAD'
          , g_global_val_tbl(1).dim_grp_disp_code
          , g_global_val_tbl(1).member_display_code ;
          --
      END ;
      --
    ELSE  -- IF ( p_dim_grp_disp_code IS NULL )
      --
      -- 4th Case:: VSR No and Level No.
      --
      l_b_table_ins_clause := l_b_table_ins_clause ||
                              ')' ;
      --
      l_b_table_bind_clause := l_b_table_bind_clause ||
                               ')' ;
      --
      l_b_table_str         := l_b_table_ins_clause || l_b_table_bind_clause ;
      --
      BEGIN
        --
        EXECUTE IMMEDIATE
          l_b_table_str
        USING
          g_global_val_tbl(1).member_display_code
        , 'LOAD' ;
        --
      EXCEPTION
        --
        WHEN DUP_VAL_ON_INDEX THEN
          --
          l_update_str := 'UPDATE ' ||
                             g_global_val_tbl(1).intf_member_b_table_name ||
                          ' SET ' ||
                            'status = :b_status' ||
                          ' WHERE ' ||
                            g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_display_code' ;
          --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            'LOAD'
          , g_global_val_tbl(1).member_display_code ;
          --
      END ;
      --
    END IF ;
    -- Now for TL table.
    --
    l_tl_table_ins_clause  := l_tl_table_ins_clause ||
                              ')' ;
    --
    l_tl_table_bind_clause := l_tl_table_bind_clause ||
                              ')' ;
    --
    l_tl_table_str         := l_tl_table_ins_clause || l_tl_table_bind_clause ;
    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_tl_table_str
      USING
        g_global_val_tbl(1).member_display_code
      , g_session_language
      , g_global_val_tbl(1).member_name
      , g_global_val_tbl(1).member_description
      , 'LOAD' ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                           g_global_val_tbl(1).intf_member_tl_table_name ||
                        ' SET ' ||
                        g_global_val_tbl(1).member_name_col ||
                        ' = :b_member_name ' ||
                        ', description   = :b_description ' ||
                        ', status        = :b_status ' ||
                        ' WHERE ' ||
                          g_global_val_tbl(1).member_display_code_col ||
                          ' = :b_member_display_code' ||
                          ' AND language = :b_language ' ;
        --
        EXECUTE IMMEDIATE
          l_update_str
        USING
          g_global_val_tbl(1).member_name
        , g_global_val_tbl(1).member_description
        , 'LOAD'
        , g_global_val_tbl(1).member_display_code
        , g_session_language ;
        --
        IF ( SQL%ROWCOUNT = 0 )
        THEN
          --
          RAISE ;
          --
        END IF ;
        --
    END ;
    --
  END IF ;  -- IF ( p_value_set_required_flag <> 'Y' ) Ends
  --
END Pop_NonSimple_Dim_Intf_tables ;

/*===========================================================================+
Procedure Name       : Pop_Other_Dim_Mem_Intf_table
Parameters           :
IN                   : None
OUT                  : x_cal_pr_end_date_col_name VARCHAR2
                       x_gl_pr_num_col_name       VARCHAR2

Description          : This program populates member interface tables for
                       non TIME dimensions. These tables involve B and TL
                       tables only. The attribute interface table will be
                       populated in Process_Atrribute API.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Pop_Other_Dim_Mem_Intf_table
IS
  --
  l_api_name CONSTANT  VARCHAR2(30)   := 'Pop_Other_Dim_Mem_Intf_table';
  l_param_info         VARCHAR2(4000) ;
  l_curr_activity      VARCHAR2(4000) ;
  --
  l_b_table_str        VARCHAR2(4000) := NULL ;
  l_tl_table_str       VARCHAR2(4000) := NULL ;
  l_update_str         VARCHAR2(4000) := NULL ;
  --
  l_record_found_count NUMBER         := 0 ;
  --
BEGIN
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_param_info    := null ;
    l_curr_activity := 'Starting Pop_Other_Dim_Mem_Intf_table API ' ;
    --
    -- Put parameter information.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Parametr Info: ' || l_param_info
    ) ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Not a time dimension. Insert in member b table' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Frame the dynamic insert sql
  -- to insert into B member table.
  -- ! IF the dimension is not of type "Simple Dimension"...
  IF ( g_global_val_tbl(1).intf_member_b_table_name <> 'FEM_SIMPLE_DIMS_B_T' )
  THEN
    --
    Pop_NonSimple_Dim_Intf_tables
    ( p_dim_grp_disp_code       => g_global_val_tbl(1).dim_grp_disp_code
    , p_value_set_required_flag => g_global_val_tbl(1).value_set_required_flag
    ) ;
    --
  ELSE -- Dimension type is "Simple Dimension"
    l_b_table_str := 'INSERT INTO ' ||
                        g_global_val_tbl(1).intf_member_b_table_name ||
                        '( dimension_varchar_label' ||
                        ', member_code' ||
                        ', status' ||
                        ')' ||
                     'VALUES' ||
                     '( :b_dim_varchar_label' ||
                     ', :b_member_code' ||
                     ', :b_status' ||
                     ')' ;
    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_b_table_str
      USING
        g_global_val_tbl(1).dimension_varchar_label
      , g_global_val_tbl(1).member_display_code
      , 'LOAD' ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                           g_global_val_tbl(1).intf_member_b_table_name ||
                        ' SET ' ||
                          'status = :b_status' ||
                        ' WHERE ' ||
                        '   dimension_varchar_label' ||
                          ' = :b_dimension_varchar_label' ||
                          ' AND member_code = ' ||
                          ':b_member_code' ;
        --
        EXECUTE IMMEDIATE
          l_update_str
        USING
          'LOAD'
        , g_global_val_tbl(1).dimension_varchar_label
        , g_global_val_tbl(1).member_display_code ;
        --
    END ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Insert in member b table done, do it for TL table' ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
    -- Now frame the dynamic insert sql
    -- to insert into TL member table.
    l_tl_table_str := 'INSERT INTO ' ||
                         g_global_val_tbl(1).intf_member_tl_table_name ||
                         '( dimension_varchar_label' ||
                         ', member_code' ||
                         ', language' ||
                         ', member_name' ||
                         ', description' ||
                         ', status' ||
                         ')' ||
                      'VALUES' ||
                      '( :b_dimension_varchar_label' ||
                      ', :b_member_code' ||
                      ', :b_language' ||
                      ', :b_member_name' ||
                      ', :b_description' ||
                      ', :b_status' ||
                      ')' ;
    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_tl_table_str
      USING
        g_global_val_tbl(1).dimension_varchar_label
      , g_global_val_tbl(1).member_display_code
      , g_session_language
      , g_global_val_tbl(1).member_name
      , g_global_val_tbl(1).member_description
      , 'LOAD' ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                           g_global_val_tbl(1).intf_member_tl_table_name ||
                        ' SET ' ||
                          'status = :b_status' ||
                          ', description = :b_description' ||
                          ', member_name' ||
                          ' = :b_member_name ' ||
                        ' WHERE ' ||
                          '  dimension_varchar_label' ||
                          '    = :b_dimension_varchar_label' ||
                          ' AND member_code = :b_member_code ' ||
                          ' AND language = :b_language';
        --
        BEGIN
          --
          EXECUTE IMMEDIATE --Update#1
            l_update_str
          USING
            'LOAD'
          , g_global_val_tbl(1).member_description
          , g_global_val_tbl(1).member_name
          , g_global_val_tbl(1).dimension_varchar_label
          , g_global_val_tbl(1).member_display_code
          , g_session_language ;
          --
          -- If no records updated.
          IF (SQL%ROWCOUNT = 0 )
          THEN
            RAISE ;
          END IF ;
          --
        -- Commenting the exception block. Will discuss it and finalize later.
        /*EXCEPTION
          --
          WHEN OTHERS THEN
            --
            -- Need to decide.
            APP_EXCEPTION.Raise_Exception ; */
        END ;
        --
    END ;
    --
  END IF ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Pop_Other_Dim_Mem_Intf_table API completed ' ||
                       'successfully' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
   --
  END IF ;
  --
END Pop_Other_Dim_Mem_Intf_table ;

/*===========================================================================+
Procedure Name       : Process_Attribute
Parameters           :
IN                   : p_attribute_value          VARCHAR2
                       p_attribute_index          NUMBER
                       p_cal_pr_end_date_col_name VARCHAR2
                       p_gl_pr_num_col_name       VARCHAR2
IN OUT               : x_period_end_date_found    BOOLEAN
                       x_GL_period_num_found      BOOLEAN

Description          : This API does following tasks...
                       1. Finds out attribute varchar label for each supplied
                          attribute and its value.
                       2. It populates TIME dimension's B and TL tables.
                       3. It populates Non TIME dimensions' attribute intf
                          table.

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Process_Attribute
( x_period_end_date_found    IN OUT NOCOPY BOOLEAN
, x_GL_period_num_found      IN OUT NOCOPY BOOLEAN
, p_attribute_value          IN            VARCHAR2
, p_attribute_index          IN            NUMBER
, p_cal_pr_end_date_col_name IN            VARCHAR2
, p_gl_pr_num_col_name       IN            VARCHAR2
)
IS
  --
  l_api_name CONSTANT         VARCHAR2(30)   := 'Process_Attribute';
  l_param_info                VARCHAR2(4000) ;
  l_curr_activity             VARCHAR2(4000) ;
  --
  l_cal_pr_end_date_col_name  VARCHAR2(30) ;
  l_cal_pr_num_col_name       VARCHAR2(30) ;
  l_cal_pr_end_date_col_value VARCHAR2(30) ;
  l_cal_pr_num_col_name_value VARCHAR2(30) ;
  l_attribute_varchar_label   VARCHAR2(30) ;
  --
  l_attr_t_str                VARCHAR2(4000) := NULL ;
  l_b_table_str               VARCHAR2(4000) := NULL ;
  l_tl_table_str              VARCHAR2(4000) := NULL ;
  l_update_str                VARCHAR2(4000) := NULL ;
  --
  l_match_found               BOOLEAN ;
  l_default_version_flag      VARCHAR2(1)    := 'Y' ;
  --
  l_required_flag             VARCHAR2(1)    := 'N' ;
  --
  l_attribute_dimension_id  fem_dim_attributes_b.attribute_dimension_id%TYPE ;
  l_value_set_required_flag   VARCHAR2(1) ;
  --
  l_attr_asgn_vs_disp_code    VARCHAR2(150)  := NULL ;
  l_attr_value_set_id         NUMBER ;
  --
  l_attribute_id              NUMBER ;
  l_attribute_required_flag   VARCHAR2(1)    := 'Y' ;
  l_populate_attribute_table  VARCHAR2(1)    := 'Y' ;
  l_date_attribute_value      DATE;
  l_adi_format_mask           VARCHAR2(20)   := FND_PROFILE.VALUE('FEM_INTF_ATTR_DATE_FORMAT_MASK');
-- Find out attribute_dimension_id, version_display_code,
  -- attribute_value_set_required_flag.
  -- This information needs outer join with fem_xdim_dimensions
  -- table as attribute_dimension_id might be null in
  -- fem_dim_attributes_b table.
  CURSOR l_attr_csr
         ( dim_id       NUMBER
         , attr_label   VARCHAR2
         , requied_flag VARCHAR2
         )
  IS
  SELECT
    Attr.attribute_dimension_id
  , AttrVer.version_display_code
  , xDim.value_set_required_flag
  FROM
    fem_dim_attributes_b Attr
  , fem_dim_attr_versions_b AttrVer
  , fem_xdim_dimensions xDim
  WHERE
    Attr.dimension_id                = dim_id
    AND Attr.attribute_varchar_label = attr_label
    AND Attr.attribute_id            = AttrVer.attribute_id
    AND AttrVer.default_version_flag = requied_flag
    AND Attr.attribute_dimension_id  = xDim.dimension_id(+) ; -- ** --
  --
  -- Retrieve attribute details.
  CURSOR l_retrieve_attr_details_csr
         ( attr_label VARCHAR2
         , dim_id     NUMBER
         )
  IS
  SELECT
    dimattr.attribute_id
  , dimattr.attribute_required_flag
  FROM
    fem_dim_attributes_b dimattr
  WHERE
    dimattr.attribute_varchar_label = attr_label
    AND dimattr.dimension_id        = dim_id ;
  --
  -- Check whether the attribute is associated
  -- with specified level.
  CURSOR l_chk_level_attr_existnce_csr
         ( attr_id           NUMBER
         , dim_grp_disp_code VARCHAR2
         )
  IS
  SELECT
    1
  FROM
    fem_dim_attr_grps    attrgrp
  , fem_dimension_grps_b dimgrp
  WHERE
    dimgrp.dimension_group_display_code = dim_grp_disp_code
    AND attrgrp.dimension_group_id      = dimgrp.dimension_group_id
    AND attrgrp.attribute_id            = attr_id ;
  -- **
  -- Just check whether inclusion of fem_dimension_grps_b.dimension_id
  -- in above cursor will quickly filter the records.
  -- **
  --
  -- Check whether the attribute is associated
  -- with any level.
  CURSOR l_check_attr_level_asso_csr
         ( attr_id NUMBER
         )
  IS
  SELECT
    1
  FROM
    fem_dim_attr_grps attrgrp
  WHERE
    attrgrp.attribute_id = attr_id ;
  --
BEGIN
  --
  SAVEPOINT Process_Attribute ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_param_info    := null ;
    l_curr_activity := 'Starting Process_Attribute API for ' ||
                       'p_attribute_'||p_attribute_index ;
    --
    -- Put parameter information.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Parametr Info: ' || l_param_info
    ) ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  --
  -- Initialize the variable to FALSE.
  -- This variable will be used to exit
  -- out of the loop when the matching
  -- attribute_varchar_label is found.
  l_match_found := FALSE ;

  -- Go ahead only if attribute value is null.

  -- Loop through all defined mappings of dimension.
  -- If found then get the attribute varchar label.
  -- Common for both Time and other dimensions.
  FOR l_indx IN 1..g_interface_col_name_tbl.COUNT
  LOOP
    --
    IF ( g_interface_col_name_tbl( l_indx ) =
           'P_ATTRIBUTE'||p_attribute_index
       )
    THEN
      --
      l_attribute_varchar_label := g_attribute_name_tbl( l_indx ) ;
      l_match_found             := TRUE ;
      --
      ------------- ********************** -------------------
      -- For Time Dimension, we need to populate attribute
      -- interface table along with two more records, one
      -- for CAL_PERIOD_END_DATE and another for GL_PERIOD_NUM
      -- , so populating global table here and will finally
      -- put into interface table in main API. this approach
      -- will avoid multiple execution of same code.
      ------------- ********************** -------------------
      g_not_null_attr_name_tbl.EXTEND ;
      --
      g_not_null_attr_name_tbl( g_not_null_attr_name_tbl.COUNT )   :=
        l_attribute_varchar_label ;
      g_not_null_attr_val_tbl( g_not_null_attr_val_tbl.COUNT + 1 ) :=
        p_attribute_value ;
      --
      -- Check whether the current attribute value is for
      -- Calander Period dimension's "CAL_PERIOD_END_DATE" attribute?
      IF ( x_period_end_date_found = FALSE
         AND
         l_attribute_varchar_label = 'CAL_PERIOD_END_DATE'
         )
      THEN
        --
        x_period_end_date_found     := TRUE ;
        g_cal_pr_end_date_col_value := p_attribute_value ;
        g_date_end_date_value       := to_date(g_cal_pr_end_date_col_value,l_adi_format_mask);
        --
        -- Check whether the current attribute value is for
        -- Calander Period dimension's "GL_PERIOD_NUM" attribute?
      ELSIF ( x_GL_period_num_found = FALSE
            AND
            l_attribute_varchar_label = 'GL_PERIOD_NUM'
            )
      THEN
        --
        x_GL_period_num_found       := TRUE ;
        g_cal_pr_num_col_name_value := p_attribute_value ;
        --
      END IF ;
      --
      -- Corresponding attribute varchar label found,
      -- exit out of the loop now.
      EXIT ;
      --
    END IF ;
  END LOOP ;
  --
  --
  g_attribute_vs_display_code.EXTEND ;
  g_version_display_code.EXTEND ;
  --
  FOR l_attr_csr_rec IN l_attr_csr
                        ( g_global_val_tbl(1).dimension_id
                        , l_attribute_varchar_label
                        , l_default_version_flag
                        )
  LOOP
    --
    --
    l_attribute_dimension_id                             :=
      l_attr_csr_rec.attribute_dimension_id ;
    g_version_display_code(g_version_display_code.COUNT) :=
      l_attr_csr_rec.version_display_code ;
    l_value_set_required_flag                            :=
      l_attr_csr_rec.value_set_required_flag ;
    --
  END LOOP ;

  -- If this is VSR attribute,
  -- get value set id and its display code.
  --
  IF ( l_value_set_required_flag = 'Y' )
  THEN
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Value Set Required Attribute. Get the display code';
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
    l_attr_value_set_id := FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id
                           ( l_attribute_dimension_id      -- p_dimension_id
                           , g_global_val_tbl(1).ledger_id -- p_ledger_id
                           ) ;
    --
    g_attribute_vs_display_code(g_attribute_vs_display_code.COUNT) := NULL ;
    --
    SELECT
      ValSet.value_set_display_code
    INTO
      l_attr_asgn_vs_disp_code
    FROM
      fem_value_sets_b ValSet
    WHERE
      ValSet.value_set_id = l_attr_value_set_id ;
    --
    -- Bug#5056895
    -- Removed unnecessary IF condition.
    g_attribute_vs_display_code(g_attribute_vs_display_code.COUNT) :=
      l_attr_asgn_vs_disp_code ;
    --
  END IF ;
  --
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'VS display code=' ||
                       g_attribute_vs_display_code
                       (g_attribute_vs_display_code.COUNT) ||
                       ', attribute_dimension_id='||l_attribute_dimension_id||
                       ', attr_asgn_vs_disp_code='||l_attr_asgn_vs_disp_code ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- ( ONLY FOR TIME DIMENSION )
  -- Now frame the dynamic insert sql
  -- to insert into B and TL member attribute tables.

  -- If both values have been found then
  -- execute the insert statement.
  IF ( x_period_end_date_found AND x_GL_period_num_found ) --Condition#1 Start
  THEN
    l_b_table_str := 'INSERT INTO ' ||
                        g_global_val_tbl(1).intf_member_b_table_name ||
                        '( cal_period_end_date' ||
                        ', cal_period_number' ||
                        ', status' ||
                        ', dimension_group_display_code' ||
                        ', calendar_display_code' ||
                        ')' ||
                     'VALUES' ||
                     '( :b_cal_period_end_date' ||
                     ', :b_cal_period_number' ||
                     ', :b_status' ||
                     ', :b_dimension_group_display_code' ||
                     ', :b_calendar_display_code' ||
                     ')' ;

    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_b_table_str
      USING
        g_date_end_date_value
      , g_cal_pr_num_col_name_value
      , 'LOAD'
      , g_global_val_tbl(1).dim_grp_disp_code
      , g_global_val_tbl(1).calendar_display_code ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                          g_global_val_tbl(1).intf_member_b_table_name ||
                        ' SET ' ||
                        'status = :b_status ' ||
                        'WHERE ' ||
                        'calendar_display_code = :b_calendar_display_code ' ||
                        ' AND dimension_group_display_code = ' ||
                        ' :b_dimension_group_display_code AND ' ||
                        'cal_period_end_date = :b_cal_period_end_date AND ' ||
                        'cal_period_number = :b_cal_period_number' ;
        --
        EXECUTE IMMEDIATE
          l_update_str
        USING
          'LOAD'
        , g_global_val_tbl(1).calendar_display_code
        , g_global_val_tbl(1).dim_grp_disp_code
        , g_date_end_date_value
        , g_cal_pr_num_col_name_value ;
        --
    END ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Insert in member b table done. Do it for TL table' ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
    l_tl_table_str := 'INSERT INTO ' ||
                         g_global_val_tbl(1).intf_member_tl_table_name ||
                         '( cal_period_end_date' ||
                         ', cal_period_number' ||
                         ', language'||
                         ', cal_period_name' ||
                         ', description' ||
                         ', status' ||
                         ', calendar_display_code' ||
                         ', dimension_group_display_code' ||
                         ')' ||
                      'VALUES' ||
                      '( :b_cal_period_end_date' ||
                      ', :b_cal_period_number' ||
                      ', :b_language' ||
                      ', :b_cal_period_name' ||
                      ', :b_description'||
                      ', :b_status' ||
                      ', :b_calendar_display_code' ||
                      ', :b_dimension_group_display_code' ||
                      ')' ;

    --
    BEGIN
      --
      EXECUTE IMMEDIATE
        l_tl_table_str
      USING
        g_date_end_date_value
      , g_cal_pr_num_col_name_value
      , g_session_language
      , g_global_val_tbl(1).member_name
      , g_global_val_tbl(1).member_description
      , 'LOAD'
      , g_global_val_tbl(1).calendar_display_code
      , g_global_val_tbl(1).dim_grp_disp_code ;
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        --
        l_update_str := 'UPDATE ' ||
                          g_global_val_tbl(1).intf_member_tl_table_name ||
                        ' SET ' ||
                        'cal_period_name = :b_cal_period_name ' ||
                        ', description   = :b_description ' ||
                        ', status        = :b_status ' ||
                        'WHERE ' ||
                        'calendar_display_code = :b_calendar_display_code ' ||
                        ' AND dimension_group_display_code = ' ||
                        ' :b_dimension_group_display_code AND ' ||
                        'cal_period_end_date = :b_cal_period_end_date AND ' ||
                        'cal_period_number   = :b_cal_period_number AND ' ||
                        'language            = :b_language' ;
        --
        BEGIN
          --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            g_global_val_tbl(1).member_name
          , g_global_val_tbl(1).member_description
          , 'LOAD'
          , g_global_val_tbl(1).calendar_display_code
          , g_global_val_tbl(1).dim_grp_disp_code
          , g_date_end_date_value
          , g_cal_pr_num_col_name_value
          , g_session_language ;
          --
          -- If no records updated.
          IF (SQL%ROWCOUNT = 0 )
          THEN
            RAISE ;
          END IF ;
          --
        -- Commenting the exception block. Will discuss it and finalize later.
        /*EXCEPTION
          --
          -- Give up now. Report the exception back to Web ADI.
           WHEN OTHERS THEN
             --
             APP_EXCEPTION.Raise_Exception ;*/
             --
        END ;
        --
    END ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Insert in TL done. For time attrib intf table' ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
  ELSIF ( g_global_val_tbl(1).dimension_type_code <> 'TIME' ) -- Non Time dim
  THEN
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Insert in TL done. For non-time attrib intf table' ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
    -- Now frame the insert statement for
    -- member attribute interface table.
    --
    -- Bug in FEM, for some dimensions, Attribute table is
    -- absent. So putting the following check.
    -- Condition#2 Start
    IF ( g_global_val_tbl(1).intf_attribute_table_name IS NOT NULL )
    THEN
      --
      -- We will populate only those attributes into table which are
      -- 1.. Associated to a level in case dim_grp_disp_code is not null.
      -- 2.. Not associated to any level in case dim_grp_disp_code is null
      --     and group_use_code is 'OPTIONAL' for the dimension.
      --
      -- Check whether the attribute is required or not.
      -- Check it's association with level only when its optional.
      FOR l_attr_rec IN l_retrieve_attr_details_csr
                        ( l_attribute_varchar_label
                        , g_global_val_tbl(1).dimension_id
                        )
      LOOP
        --
        l_attribute_id            := l_attr_rec.attribute_id ;
        l_attribute_required_flag := l_attr_rec.attribute_required_flag ;
        --
      END LOOP ;
      --
      -- Optional Attribute, go ahead.
      IF ( l_attribute_required_flag = 'N' )
      THEN
        --
        -- CASE#1 --
        -- Level is being used.
        IF ( g_global_val_tbl(1).dim_grp_disp_code IS NOT NULL )
        THEN
          --
          l_populate_attribute_table := 'N' ;
          --
          FOR l_rec IN l_chk_level_attr_existnce_csr
                       ( l_attribute_id
                       , g_global_val_tbl(1).dim_grp_disp_code
                       )
          LOOP
            --
            l_populate_attribute_table := 'Y' ;
            --
          END LOOP ;
          --
        -- CASE#2 --
        -- No Level is specified.
        ELSIF ( g_global_val_tbl(1).dim_grp_disp_code IS NULL
                AND
                g_global_val_tbl(1).group_use_code = 'OPTIONAL'
              )
        THEN
          --
          FOR l_rec IN l_check_attr_level_asso_csr
                       ( l_attribute_id
                       )
          LOOP
            --
            l_populate_attribute_table := 'N' ;
            --
          END LOOP ;
          --
        END IF ;
        --
      END IF ;
      --
      IF ( l_populate_attribute_table = 'Y' ) -- Condition#3 Start
      THEN
        -- If attribute table is not FEM_SHARED_ATTR_T
        --
        --Condition#4 Start
        IF ( g_global_val_tbl(1).intf_attribute_table_name
             <>
             'FEM_SHARED_ATTR_T'
           )
        THEN
          --
          IF ( g_global_val_tbl(1).value_set_required_flag = 'Y' )
          THEN
            --
            l_update_str := 'UPDATE ' ||
                            g_global_val_tbl(1).intf_attribute_table_name ||
                            ' SET ' ||
                            '   status = :b_status ' ||
                            ' , attribute_assign_value ' ||
                            '     = :b_attrib_asgn_value ' ||
                            'WHERE ' ||
                              g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_disp_code ' ||
                            'AND value_set_display_code ' ||
                            ' = :b_vs_disp_code ' ||
                            'AND attribute_varchar_label ' ||
                            ' = :b_attrib_varchar_label '||
                            'AND version_display_code ' ||
                            ' = :b_ver_disp_code ' ||
                            'AND NVL(attr_assign_vs_display_code, ''XYZ'') ' ||
                            ' = NVL(:b_asgn_vs_disp_code, ''XYZ'')' ;
            --
            -- Bug#5056895
            -- Replaced g_attribute_vs_display_code by
            -- g_global_val_tbl(1).value_set_display_code.
            EXECUTE IMMEDIATE
              l_update_str
            USING
              'LOAD'
            , p_attribute_value
            , g_global_val_tbl(1).member_display_code
            , g_global_val_tbl(1).value_set_display_code
            , l_attribute_varchar_label
            , g_version_display_code(g_version_display_code.COUNT)
            , l_attr_asgn_vs_disp_code ;
            --
            -- No record exists for the condtion. Insert the record.
            IF ( SQL%ROWCOUNT = 0 )
            THEN
              --
              l_attr_t_str := 'INSERT INTO ' ||
                               g_global_val_tbl(1).intf_attribute_table_name ||
                               '( ' ||
                               g_global_val_tbl(1).member_display_code_col ||
                               ', attribute_varchar_label' ||
                               ', value_set_display_code' ||
                               ', attribute_assign_value' ||
                               ', attr_assign_vs_display_code' ||
                               ', status' ||
                               ', version_display_code' ||
                              ')' ||
                              'VALUES' ||
                              '( :b_member_display_code' ||
                              ', :b_attribute_varchar_label' ||
                              ', :b_value_set_display_code' ||
                              ', :b_attribute_assign_value' ||
                              ', :b_attr_assign_vs_display_code' ||
                              ', :b_status' ||
                              ', :b_version_display_code' ||
                              ')' ;
              --
              -- Bug#5056895
              -- Replaced g_attribute_vs_display_code by
              -- g_global_val_tbl(1).value_set_display_code.
              EXECUTE IMMEDIATE
                l_attr_t_str
              USING
                g_global_val_tbl(1).member_display_code
              , l_attribute_varchar_label
              , g_global_val_tbl(1).value_set_display_code
              , p_attribute_value
              , l_attr_asgn_vs_disp_code
              , 'LOAD'
              , g_version_display_code(g_version_display_code.COUNT) ;
              --
            END IF ;
            --
          ELSE
            --
            l_update_str := 'UPDATE ' ||
                             g_global_val_tbl(1).intf_attribute_table_name ||
                            ' SET ' ||
                            '   status = :b_status ' ||
                            ' , attribute_assign_value ' ||
                            '    = :b_attrib_asgn_value ' ||
                            'WHERE ' ||
                              g_global_val_tbl(1).member_display_code_col ||
                            ' = :b_member_disp_code AND ' ||
                            'attribute_varchar_label ' ||
                            ' = :b_attrib_varchar_label '||
                            'AND version_display_code ' ||
                            ' = :b_ver_disp_code ' ||
                            'AND NVL(attr_assign_vs_display_code, ''XYZ'') ' ||
                            ' = NVL(:b_asgn_vs_disp_code, ''XYZ'') ' ;
            --
            EXECUTE IMMEDIATE
              l_update_str
            USING
              'LOAD'
            , p_attribute_value
            , g_global_val_tbl(1).member_display_code
            , l_attribute_varchar_label
            , g_version_display_code(g_version_display_code.COUNT)
            , l_attr_asgn_vs_disp_code ;
            --
            -- No record exists for the condtion. Insert the record.
            IF ( SQL%ROWCOUNT = 0 )
            THEN
              --
              l_attr_t_str := 'INSERT INTO ' ||
                                 g_global_val_tbl(1).intf_attribute_table_name ||
                              '( ' ||
                               g_global_val_tbl(1).member_display_code_col ||
                               ', attribute_varchar_label' ||
                               ', attribute_assign_value' ||
                               ', attr_assign_vs_display_code' ||
                               ', status' ||
                               ', version_display_code' ||
                               ')' ||
                               'VALUES' ||
                               '( :b_member_display_code' ||
                               ', :b_attribute_varchar_label' ||
                               ', :b_attribute_assign_value' ||
                               ', :b_attr_assign_vs_display_code' ||
                               ', :b_status' ||
                               ', :b_version_display_code' ||
                               ')' ;
              --
              EXECUTE IMMEDIATE
                l_attr_t_str
              USING
                g_global_val_tbl(1).member_display_code
              , l_attribute_varchar_label
              , p_attribute_value
              , l_attr_asgn_vs_disp_code
              , 'LOAD'
              , g_version_display_code(g_version_display_code.COUNT) ;
              --
            END IF ;
            --
          END IF ;
          --
        ELSE -- For Simple Dim
          --
          l_update_str := 'UPDATE ' ||
                          'FEM_SHARED_ATTR_T' ||
                          ' SET ' ||
                          '   status = :b_status ' ||
                          ' , attribute_assign_value ' ||
                          '     = :b_attribute_assign_value ' ||
                          'WHERE ' ||
                          '  dimension_varchar_label         = ' ||
                          ':b_dimension_varchar_label' ||
                          '  AND member_code                 = ' ||
                          ':b_member_code' ||
                          '  AND attribute_varchar_label     = ' ||
                          ':b_attribute_varchar_label '||
                          '  AND version_display_code        = ' ||
                          ':b_version_display_code' ||
                          '  AND NVL(attr_assign_vs_display_code, ''XYZ'')' ||
                          '  = NVL(:b_attr_assign_vs_display_code, ''XYZ'') ' ;

          --
          EXECUTE IMMEDIATE
            l_update_str
          USING
            'LOAD'
          , p_attribute_value
          , g_global_val_tbl(1).dimension_varchar_label
          , g_global_val_tbl(1).member_display_code
          , l_attribute_varchar_label
          , g_version_display_code(g_version_display_code.COUNT)
          , l_attr_asgn_vs_disp_code ;
          --
          -- No record exists for the condtion. Insert the record.
          IF ( SQL%ROWCOUNT = 0 )
          THEN
            --
            l_attr_t_str := 'INSERT INTO ' ||
                            'FEM_SHARED_ATTR_T' ||
                            '( dimension_varchar_label' ||
                            ', member_code' ||
                            ', attribute_varchar_label' ||
                            ', version_display_code' ||
                            ', attribute_assign_value' ||
                            ', attr_assign_vs_display_code' ||
                            ', status' ||
                            ')' ||
                            'VALUES' ||
                            '( :dimension_varchar_label' ||
                            ', :b_member_code' ||
                            ', :b_attribute_varchar_label' ||
                            ', :b_version_display_code' ||
                            ', :b_attribute_assign_value' ||
                            ', :b_attr_assign_vs_display_code' ||
                            ', :b_status' ||
                            ')' ;
            --
            EXECUTE IMMEDIATE
              l_attr_t_str
            USING
              g_global_val_tbl(1).dimension_varchar_label
            , g_global_val_tbl(1).member_display_code
            , l_attribute_varchar_label
            , g_version_display_code(g_version_display_code.COUNT)
            , p_attribute_value
            , l_attr_asgn_vs_disp_code
            , 'LOAD' ;
            --
          END IF ;
          --
        END IF ; --Condition#4 End ( Check for attribute table type   )
        --
      END IF ;   --Condition#3 End ( Conditional attribute population )
      --
    END IF ;     --Condition#2 End ( Existence of attribute table     )
    --
  END IF ;       --Condition#1 End ( TIME or Non TIME dimension       )
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Process_Attribute API for ' ||
                       'p_attribute_'||p_attribute_index ||
                       ' completed successfully.' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
END Process_Attribute ;

/*===========================================================================+
Procedure Name       : Upload_Member_Interface
Parameters           :
IN                   : p_interface_dimension_name     VARCHAR2
                       p_dimension_varchar_label      VARCHAR2
                       p_ledger_id                    VARCHAR2
                       p_calendar_display_code        VARCHAR2
                       p_member_name                  VARCHAR2
                       p_member_display_code          VARCHAR2
                       p_member_description           VARCHAR2
                       p_dimension_group_display_code VARCHAR2
                       P_ATTRIBUTE1..50               VARCHAR2
OUT                  : None

Description          : This program creates members in member interface table
                       and attribute information in dimension member attribute
                       interface table.
Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
09/23/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Upload_Member_Interface
( p_interface_dimension_name     IN VARCHAR2
, p_dimension_varchar_label      IN VARCHAR2
, p_ledger_id                    IN NUMBER
, p_calendar_display_code        IN VARCHAR2
, p_member_name                  IN VARCHAR2
, p_member_display_code          IN VARCHAR2
, p_member_description           IN VARCHAR2
, p_dimension_group_display_code IN VARCHAR2
, P_ATTRIBUTE1                   IN VARCHAR2
, P_ATTRIBUTE2                   IN VARCHAR2
, P_ATTRIBUTE3                   IN VARCHAR2
, P_ATTRIBUTE4                   IN VARCHAR2
, P_ATTRIBUTE5                   IN VARCHAR2
, P_ATTRIBUTE6                   IN VARCHAR2
, P_ATTRIBUTE7                   IN VARCHAR2
, P_ATTRIBUTE8                   IN VARCHAR2
, P_ATTRIBUTE9                   IN VARCHAR2
, P_ATTRIBUTE10                  IN VARCHAR2
, P_ATTRIBUTE11                  IN VARCHAR2
, P_ATTRIBUTE12                  IN VARCHAR2
, P_ATTRIBUTE13                  IN VARCHAR2
, P_ATTRIBUTE14                  IN VARCHAR2
, P_ATTRIBUTE15                  IN VARCHAR2
, P_ATTRIBUTE16                  IN VARCHAR2
, P_ATTRIBUTE17                  IN VARCHAR2
, P_ATTRIBUTE18                  IN VARCHAR2
, P_ATTRIBUTE19                  IN VARCHAR2
, P_ATTRIBUTE20                  IN VARCHAR2
, P_ATTRIBUTE21                  IN VARCHAR2
, P_ATTRIBUTE22                  IN VARCHAR2
, P_ATTRIBUTE23                  IN VARCHAR2
, P_ATTRIBUTE24                  IN VARCHAR2
, P_ATTRIBUTE25                  IN VARCHAR2
, P_ATTRIBUTE26                  IN VARCHAR2
, P_ATTRIBUTE27                  IN VARCHAR2
, P_ATTRIBUTE28                  IN VARCHAR2
, P_ATTRIBUTE29                  IN VARCHAR2
, P_ATTRIBUTE30                  IN VARCHAR2
, P_ATTRIBUTE31                  IN VARCHAR2
, P_ATTRIBUTE32                  IN VARCHAR2
, P_ATTRIBUTE33                  IN VARCHAR2
, P_ATTRIBUTE34                  IN VARCHAR2
, P_ATTRIBUTE35                  IN VARCHAR2
, P_ATTRIBUTE36                  IN VARCHAR2
, P_ATTRIBUTE37                  IN VARCHAR2
, P_ATTRIBUTE38                  IN VARCHAR2
, P_ATTRIBUTE39                  IN VARCHAR2
, P_ATTRIBUTE40                  IN VARCHAR2
, P_ATTRIBUTE41                  IN VARCHAR2
, P_ATTRIBUTE42                  IN VARCHAR2
, P_ATTRIBUTE43                  IN VARCHAR2
, P_ATTRIBUTE44                  IN VARCHAR2
, P_ATTRIBUTE45                  IN VARCHAR2
, P_ATTRIBUTE46                  IN VARCHAR2
, P_ATTRIBUTE47                  IN VARCHAR2
, P_ATTRIBUTE48                  IN VARCHAR2
, P_ATTRIBUTE49                  IN VARCHAR2
, P_ATTRIBUTE50                  IN VARCHAR2
)
IS
  --
  l_api_name CONSTANT        VARCHAR2(30) := 'Upload_Member_Interface';
  l_param_info               VARCHAR2(4000) ;
  l_curr_activity            VARCHAR2(4000) ;
  --
  l_return_status            VARCHAR2(1) ;
  l_msg_count                NUMBER ;
  l_msg_data                 VARCHAR2(2000) ;
  --
  l_attr_t_str               VARCHAR2(4000) := NULL ;
  l_update_str               VARCHAR2(4000) := NULL ;
  --
  l_curr_attr_label          VARCHAR2(30)   := NULL ;
  l_curr_attr_value          VARCHAR2(4000) := NULL ;
  --
  l_cal_pr_end_date_col_name VARCHAR2(30) ;
  l_cal_pr_num_col_name      VARCHAR2(30) ;
  l_period_end_date_found    BOOLEAN        := FALSE ;
  l_cal_period_num_found     BOOLEAN        := FALSE ;
  l_not_null_attr_count      NUMBER         := -1 ;
  --
  l_populate_attribute_table VARCHAR2(1)    := 'Y' ;
  --
  l_attribute_id             NUMBER ;
  l_attribute_required_flag  VARCHAR2(1)    := 'Y' ;
  l_cal_period_end_date      DATE;
  l_adi_format_mask          VARCHAR2(20)   := FND_PROFILE.VALUE('FEM_INTF_ATTR_DATE_FORMAT_MASK');
  --
  -- Retrieve the value_set_display_code for given ledger_id
  -- and dimension_id.
  CURSOR l_VS_Disp_Code_csr
         ( dim_id NUMBER
         , ledger NUMBER
         )
  IS
  SELECT
    VS.value_set_display_code
  FROM
    fem_Value_Sets_vl VS
  WHERE
    VS.value_set_id = ( FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id
                        ( dim_id -- p_dimension_id
                        , ledger -- p_ledger_id
                        )
                      ) ;
  --
  -- Retrieve attribute details.
  CURSOR l_retrieve_attr_details_csr
         ( attr_label VARCHAR2
         , dim_id     NUMBER
         )
  IS
  SELECT
    dimattr.attribute_id
    ,dimattr.attribute_required_flag, dimattr.attribute_data_type_code
  FROM
    fem_dim_attributes_b dimattr
  WHERE
    dimattr.attribute_varchar_label = attr_label
    AND dimattr.dimension_id        = dim_id ;
  --
  -- Check whether the attribute is associated
  -- with specified level.
  CURSOR l_chk_level_attr_existnce_csr
         ( attr_id           NUMBER
         , dim_grp_disp_code VARCHAR2
         )
  IS
  SELECT
    1
  FROM
    fem_dim_attr_grps    attrgrp
  , fem_dimension_grps_b dimgrp
  WHERE
    dimgrp.dimension_group_display_code = dim_grp_disp_code
    AND attrgrp.dimension_group_id      = dimgrp.dimension_group_id
    AND attrgrp.attribute_id            = attr_id ;
  -- **
  -- Just check whether inclusion of fem_dimension_grps_b.dimension_id
  -- in above cursor will quickly filter the records.
  -- **
  --
BEGIN
  --
  SAVEPOINT Upload_Member_Interface ;
  --
  l_param_info    := NULL ;
  l_curr_activity := NULL ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_param_info := ' p_dimension_varchar_label='||p_dimension_varchar_label||
                    ',p_ledger_id = ' || p_ledger_id ||
                    ',p_calendar_display_code = ' ||p_calendar_display_code||
                    ',p_member_name = ' ||p_member_name ||
                    ',p_member_display_code = '|| p_member_display_code ||
                    ',p_dimension_group_display_code='||
                    p_dimension_group_display_code ;
    l_curr_activity := 'Starting Upload_Member_Interface API ' ;
    --
    -- Put parameter information.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Parametr Info: ' || l_param_info
    ) ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- Exit if P_DIMENSION_VARCHAR_LABEL parameter
  -- contains NULL value. This will happen in case
  -- of multiple dimension interfaces. This is Web ADI
  -- limitation.
  --
  IF ( p_dimension_varchar_label IS NULL )
  THEN
    --
    RETURN ;
    --
  END IF ;
  --
  -- Retrieve user's langauge value.
  --
  g_session_language := USERENV('LANG') ;
  --
  g_not_null_attr_name_tbl    := FND_TABLE_OF_VARCHAR2_30() ;
  g_not_null_attr_val_tbl.DELETE ;

  -- Bug#6446663 - Begin
  g_attribute_vs_display_code := FND_TABLE_OF_VARCHAR2_255() ;
  g_version_display_code      := FND_TABLE_OF_VARCHAR2_255() ;
  -- Bug#6446663 - Begin

  --
  -- Check whether API has been run for p_dimension_varchar_label before.
  -- If not then populate dimension metadata information once.
  IF ( ( g_global_val_tbl.EXISTS(1)
         AND
         g_global_val_tbl(1).dimension_varchar_label <>
           p_dimension_varchar_label
       )
       OR
       g_global_val_tbl.COUNT = 0
     )
  THEN
    --
    -- Populate global variables with metadata information of
    -- the supplied p_dimension_varchar_label.
    -- Other APIs can reuse the populated global variables.
    -- This will be done only once.
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      --
      l_curr_activity := 'Calling Populate_Dim_Metadata_Info API ' ||
                         'for ' || p_dimension_varchar_label ;
      --
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'Activity: ' || l_curr_activity
      ) ;
      --
    END IF ;
    --
    Populate_Dim_Metadata_Info
    ( x_return_status           => l_return_status
    , p_dimension_varchar_label => p_dimension_varchar_label
    ) ;
    --
    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
    THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF ;
    --
  END IF ;
  --
  -- Put the Dimension parameter information into global table.
  g_global_val_tbl(1).ledger_id             := p_ledger_id ;
  g_global_val_tbl(1).member_display_code   := p_member_display_code ;
  g_global_val_tbl(1).calendar_display_code := p_calendar_display_code ;
  g_global_val_tbl(1).member_name           := p_member_name ;
  g_global_val_tbl(1).member_description    := p_member_description ;
  --
  -- Get the Value_Set_Display_code if
  -- g_global_val_tbl(1).value_set_required_flag is Y.
  g_global_val_tbl(1).value_set_display_code := NULL ;
  IF ( g_global_val_tbl(1).value_set_required_flag = 'Y' )
  THEN
    --
    FOR l_VS_Disp_Code_csr_rec IN l_VS_Disp_Code_csr
                                  ( g_global_val_tbl(1).dimension_id
                                  , g_global_val_tbl(1).ledger_id
                                  )
    LOOP
      g_global_val_tbl(1).value_set_display_code :=
        l_VS_Disp_Code_csr_rec.value_set_display_code ;
    END LOOP ;
    --
  END IF ;
  --
  g_global_val_tbl(1).dim_grp_disp_code := NULL ;
  -- If group_use_code is <> NOT_SUPPORTED, then
  -- assign p_dimension_group_display_code.
  IF ( g_global_val_tbl(1).group_use_code <> 'NOT_SUPPORTED' )
  THEN
    g_global_val_tbl(1).dim_grp_disp_code :=
      p_dimension_group_display_code ;
  END IF ;
  --
  -- Populate Members Process Starts.
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Calling Pop_Other_Dim_Mem_Intf_table API ' ||
                       ' for '||l_cal_pr_end_date_col_name ||' and ' ||
                       l_cal_pr_num_col_name ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
  -- If not a TIME dimension, then proceed.
  IF ( g_global_val_tbl(1).dimension_type_code <> 'TIME' )
  THEN
    --
    Pop_Other_Dim_Mem_Intf_table ;
    --
  END IF ;
  --
  --
  -- Populate Members Process Ends, though the insert
  -- statements will be placed alongwith attribute
  -- population.
  --
  --
  -- Populate Attribute Process Starts.
  --
  -- l_period_end_date_found and l_cal_period_num_found
  -- IN OUT parameters are being used for performance
  -- purposes. Once CAL_PERIOD dim related attribute
  -- values are found, no need to check them again.
  --
  -- Process P_ATTRIBUTE1
  IF ( P_ATTRIBUTE1 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE1
    , p_attribute_index          => 1
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE2
  IF ( P_ATTRIBUTE2 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE2
    , p_attribute_index          => 2
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE3
  IF ( P_ATTRIBUTE3 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE3
    , p_attribute_index          => 3
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE4
  IF ( P_ATTRIBUTE4 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE4
    , p_attribute_index          => 4
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE5
  IF ( P_ATTRIBUTE5 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE5
    , p_attribute_index          => 5
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE6
  IF ( P_ATTRIBUTE6 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE6
    , p_attribute_index          => 6
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE7
  IF ( P_ATTRIBUTE7 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE7
    , p_attribute_index          => 7
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE8
  IF ( P_ATTRIBUTE8 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE8
    , p_attribute_index          => 8
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE9
  IF ( P_ATTRIBUTE9 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE9
    , p_attribute_index          => 9
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE10
  IF ( P_ATTRIBUTE10 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE10
    , p_attribute_index          => 10
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE11
  IF ( P_ATTRIBUTE11 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE11
    , p_attribute_index          => 11
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE12
  IF ( P_ATTRIBUTE12 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE12
    , p_attribute_index          => 12
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE13
  IF ( P_ATTRIBUTE13 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE13
    , p_attribute_index          => 13
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE14
  IF ( P_ATTRIBUTE14 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE14
    , p_attribute_index          => 14
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE15
  IF ( P_ATTRIBUTE15 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE15
    , p_attribute_index          => 15
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE16
  IF ( P_ATTRIBUTE16 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE16
    , p_attribute_index          => 16
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE17
  IF ( P_ATTRIBUTE17 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE17
    , p_attribute_index          => 17
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE18
  IF ( P_ATTRIBUTE18 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE18
    , p_attribute_index          => 18
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE19
  IF ( P_ATTRIBUTE19 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE19
    , p_attribute_index          => 19
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE20
  IF ( P_ATTRIBUTE20 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE20
    , p_attribute_index          => 20
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE21
  IF ( P_ATTRIBUTE21 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE21
    , p_attribute_index          => 21
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE22
  IF ( P_ATTRIBUTE22 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE22
    , p_attribute_index          => 22
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE23
  IF ( P_ATTRIBUTE23 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE23
    , p_attribute_index          => 23
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE24
  IF ( P_ATTRIBUTE24 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE24
    , p_attribute_index          => 24
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE25
  IF ( P_ATTRIBUTE25 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE25
    , p_attribute_index          => 25
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE26
  IF ( P_ATTRIBUTE26 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE26
    , p_attribute_index          => 26
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE27
  IF ( P_ATTRIBUTE27 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE27
    , p_attribute_index          => 27
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE28
  IF ( P_ATTRIBUTE28 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE28
    , p_attribute_index          => 28
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE29
  IF ( P_ATTRIBUTE29 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE29
    , p_attribute_index          => 29
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE30
  IF ( P_ATTRIBUTE30 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE30
    , p_attribute_index          => 30
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE31
  IF ( P_ATTRIBUTE31 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE31
    , p_attribute_index          => 31
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE32
  IF ( P_ATTRIBUTE32 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE32
    , p_attribute_index          => 32
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE33
  IF ( P_ATTRIBUTE33 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE33
    , p_attribute_index          => 33
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE34
  IF ( P_ATTRIBUTE34 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE34
    , p_attribute_index          => 34
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE35
  IF ( P_ATTRIBUTE35 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE35
    , p_attribute_index          => 35
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE36
  IF ( P_ATTRIBUTE36 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE36
    , p_attribute_index          => 36
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE37
  IF ( P_ATTRIBUTE37 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE37
    , p_attribute_index          => 37
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE38
  IF ( P_ATTRIBUTE38 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE38
    , p_attribute_index          => 38
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE39
  IF ( P_ATTRIBUTE39 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE39
    , p_attribute_index          => 39
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE40
  IF ( P_ATTRIBUTE40 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE40
    , p_attribute_index          => 40
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE41
  IF ( P_ATTRIBUTE41 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE41
    , p_attribute_index          => 41
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE42
  IF ( P_ATTRIBUTE42 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE42
    , p_attribute_index          => 42
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE43
  IF ( P_ATTRIBUTE43 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE43
    , p_attribute_index          => 43
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE44
  IF ( P_ATTRIBUTE44 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE44
    , p_attribute_index          => 44
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE45
  IF ( P_ATTRIBUTE45 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE45
    , p_attribute_index          => 45
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE46
  IF ( P_ATTRIBUTE46 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE46
    , p_attribute_index          => 46
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE47
  IF ( P_ATTRIBUTE47 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE47
    , p_attribute_index          => 47
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE48
  IF ( P_ATTRIBUTE48 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE48
    , p_attribute_index          => 48
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE49
  IF ( P_ATTRIBUTE49 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE49
    , p_attribute_index          => 49
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;

  -- Process P_ATTRIBUTE50
  IF ( P_ATTRIBUTE50 IS NOT NULL )
  THEN
    Process_Attribute
    ( x_period_end_date_found    => l_period_end_date_found
    , x_GL_period_num_found      => l_cal_period_num_found
    , p_attribute_value          => P_ATTRIBUTE50
    , p_attribute_index          => 50
    , p_cal_pr_end_date_col_name => l_cal_pr_end_date_col_name
    , p_gl_pr_num_col_name       => l_cal_pr_num_col_name
    ) ;
  END IF ;
  --
  -- Populate Attribute Process Ends.
  --
  -- Now frame the insert statement for member attribute
  --interface table for CAL_PERIOD.
  --
  IF ( g_global_val_tbl(1).dimension_type_code = 'TIME' )
  THEN
    --
    l_not_null_attr_count := g_not_null_attr_name_tbl.COUNT ;
    l_cal_period_end_date := to_date(g_cal_pr_end_date_col_value,l_adi_format_mask);
    --
    FOR l_att_indx IN 1..l_not_null_attr_count
    LOOP
      --
      IF ( g_not_null_attr_name_tbl(l_att_indx) = 'CAL_PERIOD_END_DATE' )
      THEN
        --
        l_curr_attr_label := 'CAL_PERIOD_END_DATE' ;
        l_curr_attr_value := g_cal_pr_end_date_col_value ;
        --
      ELSIF ( g_not_null_attr_name_tbl(l_att_indx) = 'GL_PERIOD_NUM' )
      THEN
        --
        l_curr_attr_label := 'GL_PERIOD_NUM' ;
        l_curr_attr_value := g_cal_pr_num_col_name_value ;
      ELSE
        --
        l_curr_attr_label := g_not_null_attr_name_tbl(l_att_indx) ;
        l_curr_attr_value := g_not_null_attr_val_tbl(l_att_indx) ;
        --
      END IF ;
      --
      -- Check whether the attribute is required or not.
      -- Check it's association with level only when its optional.
      FOR l_attr_rec IN l_retrieve_attr_details_csr
                        ( l_curr_attr_label
                        , g_global_val_tbl(1).dimension_id
                        )
      LOOP
        --
        l_attribute_id            := l_attr_rec.attribute_id ;
        l_attribute_required_flag := l_attr_rec.attribute_required_flag ;
        --
      END LOOP ;
      --
      -- Optional Attribute, go ahead.
      IF ( l_attribute_required_flag = 'N' )
      THEN
        --
        -- Though not required to check.
        IF ( g_global_val_tbl(1).dim_grp_disp_code IS NOT NULL )
        THEN
          --
          l_populate_attribute_table := 'N' ;
          --
          FOR l_rec IN l_chk_level_attr_existnce_csr
                       ( l_attribute_id
                       , g_global_val_tbl(1).dim_grp_disp_code
                       )
          LOOP
            --
            l_populate_attribute_table := 'Y' ;
            --
          END LOOP ;
          --
        END IF ;
        --
      END IF ;
      --
      IF ( l_populate_attribute_table = 'Y' )
      THEN
        --
        l_update_str := 'UPDATE ' ||
                           g_global_val_tbl(1).intf_attribute_table_name ||
                        ' SET ' ||
                        '   status = :b_status ' ||
                        ' , attribute_assign_value ' ||
                        '     = :b_attrib_asgn_value ' ||
                        'WHERE ' ||
                        'cal_period_end_date ' ||
                        ' = :b_cal_period_end_date AND ' ||
                        'cal_period_number  = :b_cal_period_number AND ' ||
                        'calendar_display_code = ' ||
                        ' :b_calendar_display_code '||
                        'AND dimension_group_display_code = ' ||
                        ' :b_dimension_group_display_code AND ' ||
                        'attribute_varchar_label  = ' ||
                        ' :b_attribute_varchar_label ' ||
                        'AND version_display_code = ' ||
                        ' :b_version_display_code AND ' ||
                        'NVL(attr_assign_vs_display_code, ''XYZ'') = ' ||
                        ' NVL(:b_attr_assign_vs_display_code, ''XYZ'') ' ;
        --
        EXECUTE IMMEDIATE
          l_update_str
        USING
          'LOAD'
        , l_curr_attr_value
        , l_cal_period_end_date
        , g_cal_pr_num_col_name_value
        , g_global_val_tbl(1).calendar_display_code
        , g_global_val_tbl(1).dim_grp_disp_code
        , l_curr_attr_label
        , g_version_display_code(l_att_indx)
        , g_attribute_vs_display_code(l_att_indx) ;
        --
        -- No record exists. Insert record.
        IF ( SQL%ROWCOUNT = 0 )
        THEN
          --
          l_attr_t_str := 'INSERT INTO ' ||
                           g_global_val_tbl(1).intf_attribute_table_name ||
                           '( cal_period_end_date ' ||
                           ', cal_period_number' ||
                           ', attribute_varchar_label' ||
                           ', attribute_assign_value' ||
                           ', attr_assign_vs_display_code' ||
                           ', status' ||
                           ', calendar_display_code' ||
                           ', dimension_group_display_code' ||
                           ', version_display_code' ||
                           ')' ||
                          'VALUES' ||
                          '( :b_cal_period_end_date' ||
                          ', :b_cal_period_number' ||
                          ', :b_attribute_varchar_label' ||
                          ', :b_attribute_assign_value' ||
                          ', :b_attr_assign_vs_display_code' ||
                          ', :b_status' ||
                          ', :b_calendar_display_code' ||
                          ', :b_dimension_group_display_code' ||
                          ', :b_version_display_code' ||
                          ')' ;
          --
          EXECUTE IMMEDIATE
            l_attr_t_str
          USING
            l_cal_period_end_date
          , g_cal_pr_num_col_name_value
          , l_curr_attr_label
          , l_curr_attr_value
          , g_attribute_vs_display_code(l_att_indx)
          , 'LOAD'
          , g_global_val_tbl(1).calendar_display_code
          , g_global_val_tbl(1).dim_grp_disp_code
          , g_version_display_code(l_att_indx) ;
          --
        END IF ;
        --
      END IF ;
      --
    END LOOP ;
    --
  END IF ;
  --
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
  THEN
    --
    l_curr_activity := 'Upload_Member_Interface API comnpleted successfully.' ;
    --
    -- Put the current activity into log.
    FND_LOG.String
    ( log_level => FND_LOG.LEVEL_STATEMENT
    , module    => l_api_name
    , message   => 'Activity: ' || l_curr_activity
    ) ;
    --
  END IF ;
  --
/*EXCEPTION
  --
  WHEN OTHERS THEN
    ROLLBACK TO Upload_Member_Interface ;
    --
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
    THEN
      -- Put the current activity into log.
      FND_LOG.String
      ( log_level => FND_LOG.LEVEL_STATEMENT
      , module    => l_api_name
      , message   => 'SQL Error ' || sqlerrm
      ) ;
      --
    END IF ;
    --
    -- *********************
    -- ***** IMPORTANT *****
    -- *********************

    -- For the time being, using Raise_Exception
    -- to raise the exception to Excel. Need to
    -- decide the text of error message.
    APP_EXCEPTION.Raise_Exception() ;
    --*/
END Upload_Member_Interface ;


PROCEDURE Upload_Member_Header_Interface
(
  p_dimension_varchar_label      IN         VARCHAR2
)
IS
BEGIN

  NULL;

END Upload_Member_Header_Interface;

/*===========================================================================+
Procedure Name       : Populate_Mem_ADI_Metadata_CP
Parameters           :
IN                   : p_dimension_varchar_label VARCHAR2
OUT                  : errbuf                    VARCHAR2
                       retcode                   VARCHAR2

Description          : This program calls Populate_Mem_WebADI_Metadata to
                       populate dimension Metadata

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
12/01/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Populate_Mem_ADI_Metadata_CP
( errbuf                    OUT NOCOPY VARCHAR2
, retcode                   OUT NOCOPY VARCHAR2
, p_dimension_varchar_label IN         VARCHAR2
)
IS
  --
  l_api_name    CONSTANT VARCHAR2(30) := 'Populate_Mem_ADI_Metadata_CP' ;
  l_api_version CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status        VARCHAR2(1) ;
  l_msg_count            NUMBER ;
  l_msg_data             VARCHAR2(4000) ;
  --
  x_exception_msg        VARCHAR2(4000) ;
BEGIN
  --
  Populate_Mem_WebADI_Metadata
  ( x_return_status           => l_return_status
  , x_msg_count               => l_msg_count
  , x_msg_data                => l_msg_data
  , p_api_version             => l_api_version
  , p_init_msg_list           => FND_API.G_FALSE
  , p_commit                  => FND_API.G_TRUE
  , p_dimension_varchar_label => p_dimension_varchar_label
  ) ;
  --
  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS )
  THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;
  --
  retcode := 0;
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    retcode := 2 ;
    errbuf  := l_msg_data ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    retcode := 2 ;
    errbuf  := l_msg_data ;
    --
  WHEN OTHERS THEN
    --
    retcode := 2 ;
    errbuf  := l_msg_data ;
  --
END Populate_Mem_ADI_Metadata_CP ;
--

--Bug#5186753: Proc to delete all the dynamically
--created seed data.

PROCEDURE Delete_Fem_Webadi_Seed (
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2
) IS

l_api_name    CONSTANT         VARCHAR2(30) := 'Delete_Fem_Webadi_Seed';
l_api_version CONSTANT         NUMBER := 1.0;

CURSOR dimintg_lyts_csr IS
SELECT layout_code FROM bne_layouts_b WHERE integrator_code = 'FEM_DIM_MEMBER_INTG';

CURSOR dimintg_intfs_csr IS
SELECT interface_code FROM bne_interfaces_b WHERE integrator_code = 'FEM_DIM_MEMBER_INTG'
 AND interface_code <> 'FEM_DIM_MEMBER_HEADER_INTF';

BEGIN

SAVEPOINT Delete_Fem_Webadi_Seed_Pvt;

IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME )
THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
END IF;
  --

IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
END IF;
--
x_return_status := FND_API.G_RET_STS_SUCCESS ;
--

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleting layout blocks and layout cols...');

FOR dimintg_lyts_csr_rec IN dimintg_lyts_csr
LOOP
 DELETE FROM bne_layout_cols WHERE layout_code = dimintg_lyts_csr_rec.layout_code
  AND interface_code <> 'FEM_DIM_MEMBER_HEADER_INTF';
 DELETE FROM bne_layout_blocks_b WHERE layout_code = dimintg_lyts_csr_rec.layout_code;
 DELETE FROM bne_layout_blocks_tl WHERE layout_code = dimintg_lyts_csr_rec.layout_code;
END LOOP;

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleted...');

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleting layouts...');


FOR dimintg_lyts_csr_rec IN dimintg_lyts_csr
LOOP
 DELETE FROM  bne_layouts_tl WHERE layout_code = dimintg_lyts_csr_rec.layout_code;
END LOOP;

DELETE FROM bne_layouts_b WHERE integrator_code = 'FEM_DIM_MEMBER_INTG';

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleted...');

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleting interface cols');

FOR dimintg_intfs_csr_rec IN dimintg_intfs_csr
LOOP
DELETE FROM bne_interface_cols_b WHERE interface_code = dimintg_intfs_csr_rec.interface_code;
DELETE FROM bne_interface_cols_tl WHERE interface_code = dimintg_intfs_csr_rec.interface_code;
END LOOP;

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleted...');

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleting interfaces...');

FOR dimintg_intfs_csr_rec IN dimintg_intfs_csr
LOOP
DELETE FROM bne_interfaces_tl WHERE interface_code = dimintg_intfs_csr_rec.interface_code;
END LOOP;

DELETE FROM bne_interfaces_b WHERE integrator_code = 'FEM_DIM_MEMBER_INTG'
 AND interface_code <> 'FEM_DIM_MEMBER_HEADER_INTF';

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleted...');

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleting attr maps');

DELETE FROM fem_webadi_dim_attr_maps;

FEM_ENGINES_PKG.User_Message (
           p_app_name => 'FEM'
          ,p_msg_text => 'Deleted...');

IF ( FND_API.To_Boolean( p_char => p_commit) ) THEN
    COMMIT;
  END IF;

EXCEPTION


WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Fem_Webadi_Seed_pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Fem_Webadi_Seed_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Fem_Webadi_Seed_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END IF;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
   --
END Delete_Fem_Webadi_Seed;




END FEM_WEBADI_MEMBER_UTILS_PVT;

/
