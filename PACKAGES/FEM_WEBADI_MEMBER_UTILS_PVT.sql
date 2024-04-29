--------------------------------------------------------
--  DDL for Package FEM_WEBADI_MEMBER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_WEBADI_MEMBER_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVADIMEMBUTILS.pls 120.0 2006/06/16 10:19:59 gdonthir noship $ */


--------------------------
-- Declare Object types --
--------------------------
--
-- This collection will contain 50 integer values starting from 1 to 50.
-- This table will be used to retrieve the available mapping sequences
-- for a given dimension.
g_sequences_tbl           FND_TABLE_OF_NUMBER := FND_TABLE_OF_NUMBER
                                                 ( 1,  2,  3,  4,  5,  6
                                                 , 7,  8,  9,  10, 11, 12
                                                 , 13, 14, 15, 16, 17, 18
                                                 , 19, 20, 21, 22, 23, 24
                                                 , 25, 26, 27, 28, 29, 30
                                                 , 31, 32, 33, 34, 35, 36
                                                 , 37, 38, 29, 40, 41, 42
                                                 , 45, 46, 47, 48, 49, 50
                                                 ) ;
--
g_changed_intf_col_tbl    FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30();
g_changed_dt_intf_col_tbl FND_TABLE_OF_VARCHAR2_30 := FND_TABLE_OF_VARCHAR2_30();
--
------------------------------
-- Declare Global variables --
------------------------------
G_LIMIT_BULK_NUMROWS CONSTANT NUMBER := 100 ; -- Limit to hold number of rows
--
-- Global variable to prevent the execution
-- of Populate_Dim_Metadata_Info API everytime.
g_is_context_info_present   BOOLEAN := FALSE ;
--
--------------------------
-- Declare Object types --
--------------------------
-- Define a record to hold Dimension Metadata global variables.
-- Bug#5331929: Increased the size of variables to match db col size.
TYPE g_global_val_rec_type
IS
RECORD
( dimension_id              NUMBER
, dimension_varchar_label   VARCHAR2(30)
, intf_member_b_table_name  VARCHAR2(30)
, intf_member_tl_table_name VARCHAR2(30)
, intf_attribute_table_name VARCHAR2(30)
, member_b_table_name       VARCHAR2(30)
, member_display_code_col   VARCHAR2(30)
, member_display_code       VARCHAR2(150)
, calendar_display_code     VARCHAR2(150)
, member_name_col           VARCHAR2(30)
, member_name               VARCHAR2(150)
, member_description        VARCHAR2(255)
, hierarchy_intf_table_name VARCHAR2(30)
, dimension_type_code       VARCHAR2(30)
, group_use_code            VARCHAR2(30)
, value_set_required_flag   VARCHAR2(1)
, value_set_display_code    VARCHAR2(150)
, dim_grp_disp_code         VARCHAR2(150)
, ledger_id                 NUMBER
) ;

TYPE g_global_val_tbl_type
IS
TABLE OF g_global_val_rec_type
INDEX BY PLS_INTEGER ;

g_global_val_tbl g_global_val_tbl_type ;
--
--
PROCEDURE Populate_Mem_WebADI_Metadata
( x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2
, p_commit                  IN         VARCHAR2
, p_dimension_varchar_label IN         VARCHAR2
);

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
) ;

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
) ;

/*===========================================================================+
Procedure Name       : Populate_Mem_ADI_Metadata_CP
Parameters           :
IN                   : p_dimension_varchar_label VARCHAR2
OUT                  : errbuf                    VARCHAR2
                       retcode                   VARCHAR2

Description          : This program calls Populate_Dim_WebADI_Metadata to
                       populate dimension Metadata

Modification History :
Date        Name       Desc
----------  ---------  -------------------------------------------------------
12/01/2005  SHTRIPAT   Created.
----------  ---------  -------------------------------------------------------
+===========================================================================*/
PROCEDURE Populate_Mem_ADI_Metadata_CP
( errbuf                         OUT NOCOPY VARCHAR2
, retcode                        OUT NOCOPY VARCHAR2
, p_dimension_varchar_label      IN         VARCHAR2
) ;


PROCEDURE Upload_Member_Header_Interface
(
  p_dimension_varchar_label      IN         VARCHAR2
);


--Bug#5186753

PROCEDURE Delete_Fem_Webadi_Seed (
  p_api_version                  IN           NUMBER  ,
  p_init_msg_list                IN           VARCHAR2,
  p_commit                       IN           VARCHAR2,
  x_return_status                OUT NOCOPY   VARCHAR2,
  x_msg_count                    OUT NOCOPY   NUMBER  ,
  x_msg_data                     OUT NOCOPY   VARCHAR2
);


END FEM_WEBADI_MEMBER_UTILS_PVT ;

 

/
