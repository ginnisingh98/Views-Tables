--------------------------------------------------------
--  DDL for Package BIS_AK_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_AK_REGION_PUB" AUTHID CURRENT_USER as
/* $Header: BISPAKRS.pls 120.5.12000000.2 2007/01/30 10:07:27 akoduri ship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_AK_REGION_PUB                                       --
--                                                                        --
--  DESCRIPTION:  Private package that calls the AK packages to           --
--        insert/update/delete records in the AK tables.          --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  01/10/03   nbarik     Enhancement : 2638594  Portlet Builder          --
--                        Added DELETE_REGION_ITEM_ROW                    --
--  12/25/03   mdamle     Page Definer Integration - overloaded for       --
--            functionality and error messaging       --
--  02/10/03   nbarik     BSC/PMV Integration - Overloaded Procedures     --
--  05/12/04   adrao      added Nested Region Items into table            --
--                        Bis_Region_Item_Rec_Type for Start-to-end KPI   --
--  06/07/04   mdamle     Added DELETE_REGION_AND_REGION_ITEMS            --
--  06/29/04   mdamle     Added AK_OBJECT_EXISTS and INSERT_AK_OBJECT     --
--  30-JUL-2004  rpenneru Modified for enhancemen#3748519                 --
--  08/04/04   mdamle     Bug#3823878 - Add lock_row                      --
--  08/18/04   sawu       Bug#3822777 - added constants                   --
--  09/01/04   sawu       Bug#3859267 - added constants                   --
--  08/16/04   sawu       Bug#3859267 - Added IS_COMPARE_TYPE and VALIDATE_COMPARE,
--                        overloaded UPDATE_REGION_ITEM_ATTR
--  11/05/04   ankgoel    Bug#3937907 - Added AK_DATA_SET to verify if AK data
--                        will be modified for the source and compare-to columns
--  11/18/04   sawu       Bug#4018318 - Added api Is_View_Based_Report and
--                        set node_display_flag to 'N' for C_COMPARE_TO_MEASURE_NO_TARGET
--  11/24/04   sawu       Bug#4028958: added IS_VIEW_BY_REPORT, IS_AGGREGATE_DEFINED
--                        and updated UPDATE_REGION_ITEM_ATTR
--  01/08/05   mdamle     Add Url to AK_REGION_ITEMS routines              --
--  02/01/05   mdamle     Add order_sequence, direction to AK_REGION_ITEMS --
--  04/26/05   ankagarw   bug#4194925 - saving measure display name as     --
--                        attribute long label in ak_region_items          --
--  19-MAY-2005  visuri   GSCC Issues bug 4363854                          --
--  07/14/05   adrao      Bug#4448994   added API  Get_Region_Code_TL_Data --
--  10/04/05   adrao      Added field Grand_Total_Flag to Bis_Region_Item_Rec_Type
--                        for Bug#4594984
--  01/20/2006 psomesul Bug#4652028 added a new Function GetMeasureName |
--  02/07/2006 hengliu  Bug#4955493 Do not overwrite global menu/title     --
--  06/19/2006 ankgoel  Bug#5256605 - Support MLS for AK Region Items      --
--  10/20/06   akoduri    Bug#5584162 - Enable Sort For Percent Of Total
----------------------------------------------------------------------------
-- Defaults
c_BOLD          constant varchar2(1)    := 'N';
c_ITALIC        constant varchar2(1)    := 'N';
c_VERTICAL_ALIGNMENT    constant varchar2(30)   := 'TOP';
c_HORIZONTAL_ALIGNMENT  constant varchar2(30)   := 'LEFT';
c_OBJECT_ATTRIBUTE_FLAG constant varchar2(1)    := 'N';
c_UPDATE_FLAG       constant varchar2(1)    := 'N';
c_DISPLAY_HEIGHT    constant varchar2(1)    := '1';
c_SUBMIT        constant varchar2(1)    := 'N';
c_ENCRYPT       constant varchar2(1)    := 'N';
c_ADMIN_CUSTOMIZABLE    constant varchar2(1)    := 'Y';
c_ATTR_LABEL_LENGTH     constant number     := 0;
c_ATTR_VALUE_LENGTH     constant number     := 30;
c_ATTR_DATATYPE     constant varchar2(8)    := 'VARCHAR2';
c_UPPER_CASE_FLAG   constant varchar2(1)    := 'N';

c_ISFORM_FLAG       constant varchar2(1)    := 'N';
c_TABLE_LAYOUT_STYLE    constant varchar2(12)   := 'TABLE_LAYOUT';
c_PAGE_LAYOUT_STYLE constant varchar2(11)   := 'PAGE_LAYOUT';
c_NODE_DISPLAY_FLAG     constant varchar2(1)    := 'Y';
c_NODE_QUERY_FLAG   constant varchar2(1)    := 'N';
c_REQUIRED_FLAG     constant varchar2(1)    := 'N';
c_TEXT_STYLE        constant varchar2(4)    := 'TEXT';
c_NESTED_REGION_STYLE   constant varchar2(13)   := 'NESTED_REGION';
c_ADD_INDEXED_CHILDREN  constant varchar2(11)   := 'Y';
c_IMAGE_FILE_NAME   constant varchar2(22)   := 'biscollg.gif';
C_ATTRIBUTE_CATEGORY  CONSTANT VARCHAR2(22)     := 'BIS PM Viewer';

C_MEASURE                      CONSTANT VARCHAR2(7) := 'MEASURE';
C_MEASURE_NO_TARGET            CONSTANT VARCHAR(16) := 'MEASURE_NOTARGET';
C_COMPARE_TO_MEASURE_NO_TARGET CONSTANT VARCHAR(28) := 'COMPARE_TO_MEASURE_NO_TARGET';
C_CHANGE_MEASURE_NO_TARGET     CONSTANT VARCHAR(25) := 'CHANGE_MEASURE_NO_TARGET';
C_PERCENT_OF_TOTAL             CONSTANT VARCHAR(16) := 'PERCENT OF TOTAL';
C_SUM                          CONSTANT VARCHAR(3)  := 'SUM';

TYPE Bis_Region_Rec_Type IS RECORD(
   Region_Code               VARCHAR2(30)
 , Region_Name               VARCHAR2(80)
 , Region_Description        VARCHAR2(2000)
 , Region_Application_Id     NUMBER
 , Database_Object_Name      VARCHAR2(30)
 , Region_Style              VARCHAR2(30)
 , Region_Object_Type        VARCHAR2(30)
 , Help_Target               VARCHAR2(30)
 , Display_Rows              NUMBER
 , Disable_View_By           VARCHAR2(1)
 , No_Of_Portlet_Rows        NUMBER
 , Schedule                  VARCHAR2(150)
 , Header_File_Procedure     VARCHAR2(150)
 , Footer_File_Procedure     VARCHAR2(150)
 , Group_By                  VARCHAR2(150)
 , Order_By                  VARCHAR2(150)
 , Plsql_For_Report_Query    VARCHAR2(150)
 , Display_Subtotals         VARCHAR2(1)
 , Data_Source               VARCHAR2(150)
 , Where_Clause              VARCHAR2(150)
 , Dimension_Group           VARCHAR2(150)
 , Parameter_Layout          VARCHAR2(1)
 , Kpi_Id                    NUMBER
 , Analysis_Option_Id        NUMBER
 , Dim_Set_Id                NUMBER
 , Global_Menu               VARCHAR2(150)
 , Global_Title              VARCHAR2(150)
);

TYPE Bis_Region_Tbl_Type IS TABLE OF Bis_Region_Rec_Type
  INDEX BY BINARY_INTEGER;

-- Added Grandtotal items for Bug#4594984
-- Added Nested Regions for Start to End KPI Enhancement

TYPE Bis_Region_Item_Rec_Type IS RECORD(
   Attribute_Code                VARCHAR2(30)
 , Attribute_Application_Id      NUMBER
 , Display_Sequence              NUMBER
 , Node_Display_Flag             VARCHAR2(1)
 , Required_Flag                 VARCHAR2(1)
 , Queryable_Flag                VARCHAR2(1)
 , Display_Length                NUMBER
 , Long_Label                    VARCHAR2(80)
 , Sort_Sequence                 NUMBER
 , Initial_Sort_Sequence         VARCHAR2(30)
 , Sort_Direction                VARCHAR2(30)
 , Url                           VARCHAR2(2000)
 , Attribute_Type                VARCHAR2(150)
 , Display_Format                VARCHAR2(150)
 , Display_Type                  VARCHAR2(3)
 , Measure_Level                 VARCHAR2(150)
 , Base_Column                   VARCHAR2(150)
 , Lov_Where_Clause              VARCHAR2(150)
 , Graph_Position                VARCHAR2(1)
 , Graph_Style                   VARCHAR2(5)
 , Lov_Table                     VARCHAR2(150)
 , Aggregate_Function            VARCHAR2(30)
 , Display_Total                 VARCHAR2(1)
 , Variance                      VARCHAR2(150)
 , Schedule                      VARCHAR2(150)
 , Override_Hierarchy            VARCHAR2(150)
 , Additional_View_By            VARCHAR2(150)
 , Rolling_Lookup                VARCHAR2(150)
 , Operator_Lookup               VARCHAR2(150)
 , Dual_YAxis_Graphs             VARCHAR2(150)
 , Custom_View_Name              VARCHAR2(150)
 , Graph_Measure_Type            VARCHAR2(150)
 , Hide_Target_In_Table          VARCHAR2(1)
 , Parameter_Render_Type         VARCHAR2(30)
 , Privilege                     VARCHAR2(150)
 , Grand_Total_Flag              BIS_AK_REGION_ITEM_EXTENSION.ATTRIBUTE26%TYPE
 , Item_Style                    AK_REGION_ITEMS.ITEM_STYLE%TYPE
 , Nested_Region_Code            AK_REGION_ITEMS.NESTED_REGION_CODE%TYPE
 , Nested_Region_Application_Id  AK_REGION_ITEMS.NESTED_REGION_APPLICATION_ID%TYPE
);

TYPE Bis_Region_Item_Tbl_Type IS TABLE OF Bis_Region_Item_Rec_Type
  INDEX BY BINARY_INTEGER;


c_RECORD_DELETED            constant varchar2(7)    := 'DELETED';
c_RECORD_CHANGED            constant varchar2(7)    := 'CHANGED';
C_LAST_UPDATE_DATE_FORMAT varchar2(21) := 'YYYY/MM/DD-HH24:MI:SS';

procedure INSERT_REGION_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_DATABASE_OBJECT_NAME in VARCHAR2,
    X_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_NUM_ROWS_DISPLAY in NUMBER,
    X_REGION_STYLE in VARCHAR2,
    X_REGION_OBJECT_TYPE in VARCHAR2,
    X_ISFORM_FLAG in VARCHAR2,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2);

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure INSERT_REGION_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_DATABASE_OBJECT_NAME     in VARCHAR2
,p_NAME             in VARCHAR2
,p_REGION_STYLE         in VARCHAR2 := c_TABLE_LAYOUT_STYLE
,p_DESCRIPTION          in VARCHAR2 := NULL
,p_APPL_MODULE_OBJECT_TYPE  in VARCHAR2 := NULL
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := NULL
,p_ATTRIBUTE1           in VARCHAR2 := NULL
,p_ATTRIBUTE2           in VARCHAR2 := NULL
,p_ATTRIBUTE3           in VARCHAR2 := NULL
,p_ATTRIBUTE4           in VARCHAR2 := NULL
,p_ATTRIBUTE5           in VARCHAR2 := NULL
,p_ATTRIBUTE6           in VARCHAR2 := NULL
,p_ATTRIBUTE7           in VARCHAR2 := NULL
,p_ATTRIBUTE8           in VARCHAR2 := NULL
,p_ATTRIBUTE9           in VARCHAR2 := NULL
,p_ATTRIBUTE10          in VARCHAR2 := NULL
,p_ATTRIBUTE11          in VARCHAR2 := NULL
,p_ATTRIBUTE12          in VARCHAR2 := NULL
,p_ATTRIBUTE13          in VARCHAR2 := NULL
,p_ATTRIBUTE14          in VARCHAR2 := NULL
,p_ATTRIBUTE15          in VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- nbarik 02/10/04 - overloaded for region record type
procedure INSERT_REGION_ROW
(  p_commit                       IN  VARCHAR2   := FND_API.G_TRUE
 , p_Report_Region_Rec            IN  BIS_AK_REGION_PUB.Bis_Region_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);

procedure UPDATE_REGION_ROW (
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_DATABASE_OBJECT_NAME in VARCHAR2,
    X_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2,
    X_NUM_ROWS_DISPLAY in NUMBER,
    X_REGION_STYLE in VARCHAR2,
    X_REGION_OBJECT_TYPE in VARCHAR2,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2);

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure UPDATE_REGION_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_DATABASE_OBJECT_NAME     in VARCHAR2
,p_NAME             in VARCHAR2
,p_REGION_STYLE         in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_APPL_MODULE_OBJECT_TYPE  in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE1           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE2           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE3           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE4           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE5           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE6           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE7           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE8           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE9           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE10          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE11          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE12          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE13          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE14          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_ATTRIBUTE15          in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- mdamle 12/25/2003
-- nbarik - 04/05/04 - Enh 3546750 - BSC/PMV Integration - Added p_commit
PROCEDURE DELETE_REGION_ROW
(p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
,p_commit                 IN    VARCHAR2   := FND_API.G_FALSE
 );

procedure INSERT_REGION_ITEM_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_ATTRIBUTE_APPLICATION_ID in NUMBER,
    X_ATTRIBUTE_CODE in VARCHAR2,
    X_DISPLAY_SEQUENCE in NUMBER,
    X_NODE_DISPLAY_FLAG in VARCHAR2,
    X_NODE_QUERY_FLAG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
    X_DISPLAY_VALUE_LENGTH in number,
    X_ITEM_STYLE in VARCHAR2,
    X_REQUIRED_FLAG in VARCHAR2,
    X_NESTED_REGION_CODE IN VARCHAR2,
    X_NESTED_REGION_APPL_ID IN NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_URL in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_SEQUENCE in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_DIRECTION in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR);

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure INSERT_REGION_ITEM_ROW (
 p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_ATTRIBUTE_CODE       in VARCHAR2
,p_ATTRIBUTE_APPLICATION_ID     in NUMBER
,p_DISPLAY_SEQUENCE         in number
,p_NODE_DISPLAY_FLAG        in VARCHAR2 := 'Y'
,p_ATTRIBUTE_LABEL_LONG     in VARCHAR2 := NULL
,p_NESTED_REGION_CODE       in VARCHAR2 := NULL
,p_NESTED_REGION_APPL_ID    in NUMBER   := NULL
,p_ATTRIBUTE_CATEGORY       in VARCHAR2 := NULL
,p_ATTRIBUTE1           in VARCHAR2 := NULL
,p_ATTRIBUTE2           in VARCHAR2 := NULL
,p_ATTRIBUTE3           in VARCHAR2 := NULL
,p_ATTRIBUTE4           in VARCHAR2 := NULL
,p_ATTRIBUTE5           in VARCHAR2 := NULL
,p_ATTRIBUTE6           in VARCHAR2 := NULL
,p_ATTRIBUTE7           in VARCHAR2 := NULL
,p_ATTRIBUTE8           in VARCHAR2 := NULL
,p_ATTRIBUTE9           in VARCHAR2 := NULL
,p_ATTRIBUTE10          in VARCHAR2 := NULL
,p_ATTRIBUTE11          in VARCHAR2 := NULL
,p_ATTRIBUTE12          in VARCHAR2 := NULL
,p_ATTRIBUTE13          in VARCHAR2 := NULL
,p_ATTRIBUTE14          in VARCHAR2 := NULL
,p_ATTRIBUTE15          in VARCHAR2 := NULL
,p_URL              in VARCHAR2 := NULL
,p_ORDER_SEQUENCE       in VARCHAR2 := NULL
,p_ORDER_DIRECTION      in VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE INSERT_REGION_ITEM_ROW
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Region_Item_Rec              IN         BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);


procedure UPDATE_REGION_ITEM_ROW (
    X_USER_ID in NUMBER,
    X_REGION_APPLICATION_ID in NUMBER,
    X_REGION_CODE in VARCHAR2,
    X_ATTRIBUTE_APPLICATION_ID in NUMBER,
    X_ATTRIBUTE_CODE in VARCHAR2,
    X_DISPLAY_SEQUENCE in VARCHAR2,
    X_NODE_DISPLAY_FLAG in VARCHAR2,
    X_NODE_QUERY_FLAG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
    X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
    X_DISPLAY_VALUE_LENGTH in number,
    X_ITEM_STYLE in VARCHAR2,
    X_REQUIRED_FLAG in VARCHAR2,
    X_NESTED_REGION_CODE IN VARCHAR2,
    X_NESTED_REGION_APPL_ID IN NUMBER,
    X_ATTRIBUTE_CATEGORY in VARCHAR2,
    X_ATTRIBUTE1 in VARCHAR2,
    X_ATTRIBUTE2 in VARCHAR2,
    X_ATTRIBUTE3 in VARCHAR2,
    X_ATTRIBUTE4 in VARCHAR2,
    X_ATTRIBUTE5 in VARCHAR2,
    X_ATTRIBUTE6 in VARCHAR2,
    X_ATTRIBUTE7 in VARCHAR2,
    X_ATTRIBUTE8 in VARCHAR2,
    X_ATTRIBUTE9 in VARCHAR2,
    X_ATTRIBUTE10 in VARCHAR2,
    X_ATTRIBUTE11 in VARCHAR2,
    X_ATTRIBUTE12 in VARCHAR2,
    X_ATTRIBUTE13 in VARCHAR2,
    X_ATTRIBUTE14 in VARCHAR2,
    X_ATTRIBUTE15 in VARCHAR2,
    X_URL in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR,
    X_ORDER_SEQUENCE in VARCHAR2 := NULL,
    X_ORDER_DIRECTION in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR);


-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE UPDATE_REGION_ITEM_ROW
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Region_Item_Rec              IN         BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);

-- nbarik 02/10/04 - overloaded for region record type
PROCEDURE UPDATE_REGION_ROW
(  p_commit                       IN  VARCHAR2   := FND_API.G_TRUE
 , p_Report_Region_Rec            IN  BIS_AK_REGION_PUB.Bis_Region_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);

--nbarik 10/01/03 - Delete AK region item
PROCEDURE DELETE_REGION_ITEM_ROW (
   X_REGION_APPLICATION_ID IN NUMBER,
   X_REGION_CODE IN VARCHAR2,
   X_ATTRIBUTE_APPLICATION_ID IN NUMBER,
   X_ATTRIBUTE_CODE IN VARCHAR2
 );

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
-- nbarik - 04/05/04 - Enh 3546750 - BSC/PMV Integration - Added p_commit
PROCEDURE DELETE_REGION_ITEM_ROW
(p_REGION_CODE          in VARCHAR2
,p_REGION_APPLICATION_ID    in NUMBER
,p_ATTRIBUTE_CODE       in VARCHAR2
,p_ATTRIBUTE_APPLICATION_ID     in NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
,p_commit               IN  VARCHAR2   := FND_API.G_FALSE
 );


PROCEDURE DELETE_REGION_AND_REGION_ITEMS(
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE DELETE_REGION_ITEMS (
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE DELETE_EXT_REGION_ITEMS (
 p_REGION_CODE                  IN VARCHAR2
,p_REGION_APPLICATION_ID        IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
);

function VALID_DATABASE_OBJECT (
 P_DATABASE_OBJECT_NAME IN VARCHAR2) return boolean;

function AK_OBJECT_EXISTS (
 P_DATABASE_OBJECT_NAME IN VARCHAR2) return boolean;

procedure INSERT_AK_OBJECT (
 P_DATABASE_OBJECT_NAME IN VARCHAR2
,P_APPLICATION_ID IN NUMBER);

-- rpenneru Added for enh#3757005
PROCEDURE GET_REGION_ITEM_REC
(  p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , x_Region_Item_Rec              OUT NOCOPY BIS_AK_REGION_PUB.Bis_Region_Item_Rec_Type
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_REGION_ITEM_ATTR
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , p_Short_Name                   IN         VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_REGION_ITEM_ATTR
(  p_commit                       IN         VARCHAR2   := FND_API.G_TRUE
 , p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_Attribute_Code               IN         AK_REGION_ITEMS.ATTRIBUTE_CODE%TYPE
 , p_Attribute_Application_Id     IN         AK_REGION_ITEMS.ATTRIBUTE_APPLICATION_ID%TYPE
 , p_Short_Name                   IN         VARCHAR2
 , p_type                         IN         VARCHAR2
 , p_Meas_Name            IN         VARCHAR2
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2
);


PROCEDURE LOCK_REGION_ROW
(  p_region_code                  IN         VARCHAR2
 , p_region_application_id        IN         NUMBER
 , p_last_update_date             IN         VARCHAR2
 , x_record_status                OUT NOCOPY VARCHAR2
);

--return true if and only if p_attribute_type is one of C_MEASURE or C_MEASURE_NO_TARGET
FUNCTION IS_MEASURE_TYPE(
    p_attribute_type IN VARCHAR2
) RETURN BOOLEAN;

--return true if and only if p_attribute_type is C_COMPARE_TO_MEASURE_NO_TARGET
FUNCTION IS_COMPARE_TYPE(
    p_attribute_type IN VARCHAR2
) RETURN BOOLEAN;

--return true if and only if given measure short name exists
FUNCTION VALIDATE_MEASURE(
  p_short_name          IN         Bisbv_Performance_Measures.MEASURE_SHORT_NAME%Type
 ,x_measure_short_name  OUT NOCOPY Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN BOOLEAN;

--return true if any only if p_compare_code refers to a valid entry in ak_region_items which
--subsequently refers to a valid measure
FUNCTION VALIDATE_COMPARE(
  p_region_code         IN          Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN          Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_compare_code        IN          Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,x_measure_short_name  OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
 ,x_measure_name        OUT NOCOPY  Bisbv_Performance_Measures.MEASURE_NAME%TYPE
) RETURN BOOLEAN;

FUNCTION AK_DATA_SET(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
 ,p_source_code         IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_compare_code        IN  Ak_Region_Items.ATTRIBUTE_CODE%Type
 ,p_measure_short_name  IN  Bisbv_Performance_Measures.MEASURE_SHORT_NAME%TYPE
) RETURN VARCHAR2;

--return 'T' if given report is view based, 'F' otherwise
FUNCTION IS_VIEW_BASED_REPORT(
  p_region_code         IN  Ak_Regions.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Regions.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2;

--return 'T' if given report is view-by, 'F' otherwise
FUNCTION IS_VIEW_BY_REPORT(
  p_region_code         IN  Ak_Regions.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Regions.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2;

--return 'T' if at least one aggregate function is defined in any column
--for the given report, 'F' otherwise
FUNCTION IS_AGGREGATE_DEFINED(
  p_region_code         IN  Ak_Region_Items.REGION_CODE%TYPE
 ,p_region_app_id       IN  Ak_Region_Items.REGION_APPLICATION_ID%Type
) RETURN VARCHAR2;


-- added for Bug#4448994 and as a general utility file.
PROCEDURE Get_Region_Code_TL_Data (
    p_Region_Code              IN         Ak_Regions.REGION_CODE%TYPE
  , p_Region_Application_Id    IN         Ak_Regions.REGION_APPLICATION_ID%TYPE
  , x_Region_Name              OUT NOCOPY Ak_Regions_Tl.NAME%TYPE
  , x_Region_Description       OUT NOCOPY Ak_Regions_Tl.DESCRIPTION%TYPE
  , x_Region_Created_By        OUT NOCOPY Ak_Regions_Tl.CREATED_BY%TYPE
  , x_Region_Creation_Date     OUT NOCOPY Ak_Regions_Tl.CREATION_DATE%TYPE
  , x_Region_Last_Updated_By   OUT NOCOPY Ak_Regions_Tl.LAST_UPDATED_BY%TYPE
  , x_Region_Last_Update_Date  OUT NOCOPY Ak_Regions_Tl.LAST_UPDATE_DATE%TYPE
  , x_Region_Last_Update_Login OUT NOCOPY Ak_Regions_Tl.LAST_UPDATE_LOGIN%TYPE
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE reset_ak_items_display_seq (
  p_region_code                  IN VARCHAR2
, p_region_application_id        IN NUMBER
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
);

END BIS_AK_REGION_PUB;

 

/
