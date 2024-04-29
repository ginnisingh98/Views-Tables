--------------------------------------------------------
--  DDL for Package CS_SR_EXTATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_EXTATTRIBUTES_PVT" AUTHID CURRENT_USER AS
/* $Header: csvexts.pls 120.7 2005/11/23 14:41 mviswana noship $ */

G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_SUCCESS;     --'S'
G_RET_STS_ERROR         CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_ERROR;       --'E'
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1)  :=  FND_API.g_RET_STS_UNEXP_ERROR; --'U'


-- ==============================================================================
--                 Private Record Structures
-- ==============================================================================
--
--This table will hold the extended attributes information
--for a Service Request
--
TYPE Ext_Attr_Audit_Rec_TYPE IS RECORD(
     EXTENSION_ID                    NUMBER
    ,ROW_IDENTIFIER                  NUMBER
    ,PK_COLUMN_1                     VARCHAR2(150)
    ,PK_COLUMN_2                     VARCHAR2(150)
    ,PK_COLUMN_3                     VARCHAR2(150)
    ,PK_COLUMN_4                     VARCHAR2(150)
    ,PK_COLUMN_5                     VARCHAR2(150)
    ,CONTEXT                         VARCHAR2(150)
    ,ATTR_GROUP_ID                   NUMBER
    ,C_EXT_ATTR1                     VARCHAR2(150)
    ,C_EXT_ATTR2                     VARCHAR2(150)
    ,C_EXT_ATTR3                     VARCHAR2(150)
    ,C_EXT_ATTR4                     VARCHAR2(150)
    ,C_EXT_ATTR5                     VARCHAR2(150)
    ,C_EXT_ATTR6                     VARCHAR2(150)
    ,C_EXT_ATTR7                     VARCHAR2(150)
    ,C_EXT_ATTR8                     VARCHAR2(150)
    ,C_EXT_ATTR9                     VARCHAR2(150)
    ,C_EXT_ATTR10                    VARCHAR2(150)
    ,C_EXT_ATTR11                    VARCHAR2(150)
    ,C_EXT_ATTR12                    VARCHAR2(150)
    ,C_EXT_ATTR13                    VARCHAR2(150)
    ,C_EXT_ATTR14                    VARCHAR2(150)
    ,C_EXT_ATTR15                    VARCHAR2(150)
    ,C_EXT_ATTR16                    VARCHAR2(150)
    ,C_EXT_ATTR17                    VARCHAR2(150)
    ,C_EXT_ATTR18                    VARCHAR2(150)
    ,C_EXT_ATTR19                    VARCHAR2(150)
    ,C_EXT_ATTR20                    VARCHAR2(150)
    ,C_EXT_ATTR21                    VARCHAR2(150)
    ,C_EXT_ATTR22                    VARCHAR2(150)
    ,C_EXT_ATTR23                    VARCHAR2(150)
    ,C_EXT_ATTR24                    VARCHAR2(150)
    ,C_EXT_ATTR25                    VARCHAR2(150)
    ,C_EXT_ATTR26                    VARCHAR2(150)
    ,C_EXT_ATTR27                    VARCHAR2(150)
    ,C_EXT_ATTR28                    VARCHAR2(150)
    ,C_EXT_ATTR29                    VARCHAR2(150)
    ,C_EXT_ATTR30                    VARCHAR2(150)
    ,C_EXT_ATTR31                    VARCHAR2(150)
    ,C_EXT_ATTR32                    VARCHAR2(150)
    ,C_EXT_ATTR33                    VARCHAR2(150)
    ,C_EXT_ATTR34                    VARCHAR2(150)
    ,C_EXT_ATTR35                    VARCHAR2(150)
    ,C_EXT_ATTR36                    VARCHAR2(150)
    ,C_EXT_ATTR37                    VARCHAR2(150)
    ,C_EXT_ATTR38                    VARCHAR2(150)
    ,C_EXT_ATTR39                    VARCHAR2(150)
    ,C_EXT_ATTR40                    VARCHAR2(150)
    ,C_EXT_ATTR41                    VARCHAR2(150)
    ,C_EXT_ATTR42                    VARCHAR2(150)
    ,C_EXT_ATTR43                    VARCHAR2(150)
    ,C_EXT_ATTR44                    VARCHAR2(150)
    ,C_EXT_ATTR45                    VARCHAR2(150)
    ,C_EXT_ATTR46                    VARCHAR2(150)
    ,C_EXT_ATTR47                    VARCHAR2(150)
    ,C_EXT_ATTR48                    VARCHAR2(150)
    ,C_EXT_ATTR49                    VARCHAR2(150)
    ,C_EXT_ATTR50                    VARCHAR2(150)
    ,N_EXT_ATTR1                     NUMBER
    ,N_EXT_ATTR2                     NUMBER
    ,N_EXT_ATTR3                     NUMBER
    ,N_EXT_ATTR4                     NUMBER
    ,N_EXT_ATTR5                     NUMBER
    ,N_EXT_ATTR6                     NUMBER
    ,N_EXT_ATTR7                     NUMBER
    ,N_EXT_ATTR8                     NUMBER
    ,N_EXT_ATTR9                     NUMBER
    ,N_EXT_ATTR10                    NUMBER
    ,N_EXT_ATTR11                    NUMBER
    ,N_EXT_ATTR12                    NUMBER
    ,N_EXT_ATTR13                    NUMBER
    ,N_EXT_ATTR14                    NUMBER
    ,N_EXT_ATTR15                    NUMBER
    ,N_EXT_ATTR16                    NUMBER
    ,N_EXT_ATTR17                    NUMBER
    ,N_EXT_ATTR18                    NUMBER
    ,N_EXT_ATTR19                    NUMBER
    ,N_EXT_ATTR20                    NUMBER
    ,N_EXT_ATTR21                    NUMBER
    ,N_EXT_ATTR22                    NUMBER
    ,N_EXT_ATTR23                    NUMBER
    ,N_EXT_ATTR24                    NUMBER
    ,N_EXT_ATTR25                    NUMBER
    ,D_EXT_ATTR1                     DATE
    ,D_EXT_ATTR2                     DATE
    ,D_EXT_ATTR3                     DATE
    ,D_EXT_ATTR4                     DATE
    ,D_EXT_ATTR5                     DATE
    ,D_EXT_ATTR6                     DATE
    ,D_EXT_ATTR7                     DATE
    ,D_EXT_ATTR8                     DATE
    ,D_EXT_ATTR9                     DATE
    ,D_EXT_ATTR10                    DATE
    ,D_EXT_ATTR11                    DATE
    ,D_EXT_ATTR12                    DATE
    ,D_EXT_ATTR13                    DATE
    ,D_EXT_ATTR14                    DATE
    ,D_EXT_ATTR15                    DATE
    ,D_EXT_ATTR16                    DATE
    ,D_EXT_ATTR17                    DATE
    ,D_EXT_ATTR18                    DATE
    ,D_EXT_ATTR19                    DATE
    ,D_EXT_ATTR20                    DATE
    ,D_EXT_ATTR21                    DATE
    ,D_EXT_ATTR22                    DATE
    ,D_EXT_ATTR23                    DATE
    ,D_EXT_ATTR24                    DATE
    ,D_EXT_ATTR25                    DATE
    ,UOM_EXT_ATTR1                   VARCHAR2(3)
    ,UOM_EXT_ATTR2                   VARCHAR2(3)
    ,UOM_EXT_ATTR3                   VARCHAR2(3)
    ,UOM_EXT_ATTR4                   VARCHAR2(3)
    ,UOM_EXT_ATTR5                   VARCHAR2(3)
    ,UOM_EXT_ATTR6                   VARCHAR2(3)
    ,UOM_EXT_ATTR7                   VARCHAR2(3)
    ,UOM_EXT_ATTR8                   VARCHAR2(3)
    ,UOM_EXT_ATTR9                   VARCHAR2(3)
    ,UOM_EXT_ATTR10                  VARCHAR2(3)
    ,UOM_EXT_ATTR11                  VARCHAR2(3)
    ,UOM_EXT_ATTR12                  VARCHAR2(3)
    ,UOM_EXT_ATTR13                  VARCHAR2(3)
    ,UOM_EXT_ATTR14                  VARCHAR2(3)
    ,UOM_EXT_ATTR15                  VARCHAR2(3)
    ,UOM_EXT_ATTR16                  VARCHAR2(3)
    ,UOM_EXT_ATTR17                  VARCHAR2(3)
    ,UOM_EXT_ATTR18                  VARCHAR2(3)
    ,UOM_EXT_ATTR19                  VARCHAR2(3)
    ,UOM_EXT_ATTR20                  VARCHAR2(3)
    ,UOM_EXT_ATTR21                  VARCHAR2(3)
    ,UOM_EXT_ATTR22                  VARCHAR2(3)
    ,UOM_EXT_ATTR23                  VARCHAR2(3)
    ,UOM_EXT_ATTR24                  VARCHAR2(3)
    ,UOM_EXT_ATTR25                  VARCHAR2(3)

);

TYPE Ext_Attr_Audit_Tbl_Type IS TABLE OF Ext_Attr_Audit_Rec_TYPE INDEX BY BINARY_INTEGER;


-- Record  and table structure to hold the attr group and attr information together.

TYPE Ext_Grp_Attr_Rec_TYPE IS RECORD
    ( ROW_IDENTIFIER       NUMBER,
      ATTR_GROUP_ID        NUMBER,
      ATTR_GROUP_TYPE      VARCHAR2(40),
      ATTR_GROUP_NAME      VARCHAR2(30),
      ATTR_GROUP_DISP_NAME VARCHAR2(150),
      COLUMN_NAME          VARCHAR2(30),
      ATTR_NAME            VARCHAR2(150),
      ATTR_VALUE_STR       VARCHAR2(150),
      ATTR_VALUE_NUM       NUMBER,
      ATTR_VALUE_DATE      DATE,
      ATTR_VALUE_DISPLAY   VARCHAR2(1000));

TYPE EXT_GRP_ATTR_TBL_TYPE IS TABLE OF Ext_Grp_Attr_Rec_TYPE INDEX BY BINARY_INTEGER;

-- =============================================================================
--                 Private Procedures
-- =============================================================================

-- -----------------------------------------------------------------------------
--  API Name:       get_Sr_ext_Attrs
--
--  Description:
--    Get User-Defined Attrs data for
--    the Service Request business object
-- -----------------------------------------------------------------------------
PROCEDURE Get_SR_Ext_Attrs
(p_api_version   	     IN           NUMBER
,p_init_msg_list             IN           VARCHAR2   := FND_API.G_FALSE
,p_commit                    IN           VARCHAR2   := FND_API.G_FALSE
,p_incident_id               IN           NUMBER
,p_object_name               IN           VARCHAR2
,x_ext_attr_grp_tbl          OUT  NOCOPY  CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
,x_ext_attr_tbl              OUT  NOCOPY  CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
,x_return_status             OUT  NOCOPY  VARCHAR2
,x_msg_count                 OUT  NOCOPY  NUMBER
,x_msg_data                  OUT  NOCOPY  VARCHAR2);



-- -----------------------------------------------------------------------------
--  API Name:       Process_Sr_ext_Attrs
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Service Request business object
-- -----------------------------------------------------------------------------





PROCEDURE Process_SR_Ext_Attrs(
        p_api_version      	        IN   NUMBER
       ,p_init_msg_list    	        IN   VARCHAR2 	:= FND_API.G_FALSE
       ,p_commit           	        IN   VARCHAR2 	:= FND_API.G_FALSE
       ,p_incident_id                   IN   NUMBER
       ,p_ext_attr_grp_tbl              IN   CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
       ,p_ext_attr_tbl                  IN   CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
       ,p_modified_by                   IN   NUMBER := FND_GLOBAL.USER_ID
       ,p_modified_on                   IN   DATE := SYSDATE
       ,x_failed_row_id_list            OUT  NOCOPY VARCHAR2
       ,x_return_status                 OUT  NOCOPY VARCHAR2
       ,x_errorcode                     OUT  NOCOPY NUMBER
       ,x_msg_count                     OUT  NOCOPY NUMBER
       ,x_msg_data                      OUT  NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------------
--  API Name:       Create_Ext_Attr_Audit
--
--  Description:
--    Create Extensible Attributes Audit Record
-- -----------------------------------------------------------------------------
PROCEDURE Create_Ext_Attr_Audit(
        p_sr_ea_new_audit_rec_table    IN   Ext_Attr_Audit_Tbl_Type
       ,p_sr_ea_old_audit_rec_table    IN   Ext_Attr_Audit_Tbl_Type
       ,p_object_name                  IN   VARCHAR2
       ,p_modified_by                   IN   NUMBER := FND_GLOBAL.USER_ID
       ,p_modified_on                   IN   DATE := SYSDATE
       ,x_return_status                OUT  NOCOPY VARCHAR2
       ,x_msg_count                    OUT  NOCOPY NUMBER
       ,x_msg_data                     OUT  NOCOPY VARCHAR2
);


-- -----------------------------------------------------------------------------
--  API Name:       Merge_Ext_Attrs_Details
--
--  Description:
--    This procedure is created to merge the group table and the attr. table in to one table structure.
-- -----------------------------------------------------------------------------

Procedure Merge_Ext_Attrs_Details
        (p_ext_attr_grp_tbl          IN           CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
        ,p_ext_attr_tbl              IN           CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
        ,x_ext_grp_attr_tbl          OUT  NOCOPY  EXT_GRP_ATTR_TBL_TYPE
        ,x_return_status             OUT  NOCOPY  VARCHAR2
        ,x_msg_count                 OUT  NOCOPY  NUMBER
        ,x_msg_data                  OUT  NOCOPY  VARCHAR2);


-- -----------------------------------------------------------------------------
--  API Name:       Insert_Sr_Row
--
--  Description:
--    Inserts Extensible Attributes Audit Record
-- -----------------------------------------------------------------------------

PROCEDURE insert_sr_row
( P_NEW_EXT_ATTRS         IN Ext_Attr_Audit_Tbl_Type
, P_OLD_EXT_ATTRS         IN Ext_Attr_Audit_Tbl_Type
, P_MODIFIED_BY           IN NUMBER
, P_MODIFIED_ON           IN DATE
, X_RETURN_STATUS        OUT NOCOPY VARCHAR2
, X_MSG_COUNT            OUT NOCOPY NUMBER
, X_MSG_DATA             OUT NOCOPY VARCHAR2
);



-------------------------------------------------------------------------------
-- Procedure Name : insert_pr_row
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description : Procedure to create audit of party role extensible attributes.
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 06/06/05 pkesani   Created
--------------------------------------------------------------------------------
PROCEDURE insert_pr_row
( P_NEW_EXT_ATTRS         IN Ext_Attr_Audit_Tbl_Type
, P_OLD_EXT_ATTRS         IN Ext_Attr_Audit_Tbl_Type
, P_MODIFIED_BY           IN NUMBER
, P_MODIFIED_ON           IN DATE
, X_RETURN_STATUS        OUT NOCOPY VARCHAR2
, X_MSG_COUNT            OUT NOCOPY NUMBER
, X_MSG_DATA             OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------------------
-- Procedure Name : Populate_Ext_Attr_Audit_Tbl
-- Parameters     :
-- IN             : P_EXTENSION_ID
-- OUT            : X_EXT_ATTRS_TBL
--
-- Description : Procedure to populate ext. attr. audit table structure for a given extension_id.
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 11/21/2005   spusegao Created
--------------------------------------------------------------------------------
PROCEDURE Populate_Ext_Attr_Audit_Tbl
( P_EXTENSION_ID   IN         NUMBER
, X_EXT_ATTRS_TBL  OUT NOCOPY Ext_Attr_Audit_Tbl_Type
, X_RETURN_STATUS  OUT NOCOPY VARCHAR2
, X_MSG_COUNT      OUT NOCOPY NUMBER
, X_MSG_DATA       OUT NOCOPY VARCHAR2);

END CS_SR_EXTATTRIBUTES_PVT;

 

/
