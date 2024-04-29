--------------------------------------------------------
--  DDL for Package BIS_LOV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_LOV_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVLOVS.pls 115.18 2002/12/16 10:25:59 rchandra ship $ */
--  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--      BISVLOVS.pls
--
--  DESCRIPTION
--      Spec of list of values utilities package
--
--  HISTORY
--
--  MAR-2000 irchen created
--

DSP_NO_SELECTION_STRING CONSTANT VARCHAR2(10000)
  := BIS_UTILITIES_PVT.Get_FND_Message
   ( p_message_name => 'BIS_NO_SELECTION_MESSAGE' );

TYPE Value_Id_Record is Record (
  Value VARCHAR2(32000)
, Id    VARCHAR2(32000)
);
Type Value_Id_Table is table of Value_Id_Record
  index by binary_integer;

Procedure null_alert;

Procedure Dependent_LOVFunction
( p_lov_func_name       in varchar2
, p_attribute_app_id    in NUMBER
, p_attribute_code      in varchar2
, p_region_app_id       in number
, p_region_code         in varchar2
, p_form_name           in varchar2
, p_frame_name          in varchar2 default null
, p_where_clause        in varchar2 default null
, p_null_variable       in varchar2 default null
, p_null_alert_text     in varchar2 default null
);

Procedure get_List
( p_attributes        IN  varchar2 default null
, p_name              IN  varchar2 default null
, p_selected_value    IN  varchar2 default null
, p_no_selection_flag IN  varchar2 default FND_API.G_FALSE
, p_list              IN  value_id_table
, x_list_str          OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

Procedure get_List
( p_attributes        IN  varchar2 default null
, p_name              IN  varchar2 default null
, p_selected_value    IN  varchar2 default null
, p_no_selection_flag IN  varchar2 default FND_API.G_FALSE
, p_list              IN  value_id_table
, p_label             IN  varchar2
, x_list_str          OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);
--
procedure Get_List
( p_attribute_app_id    IN  NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute_code      IN  VARCHAR2
, p_attribute_name      IN  VARCHAR2
, p_region_app_id       IN  NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region_code         IN  VARCHAR2
, p_form_name           IN  VARCHAR2
, p_where_clause        IN  VARCHAR2  := NULL
, p_selected_value      IN  BIS_LOV_PVT.Value_id_record
, p_func                IN  VARCHAR2 DEFAULT NULL
, p_size                IN  NUMBER   DEFAULT 20
, x_list_str            OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

procedure Get_List
( p_attribute_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute_code      IN VARCHAR2
, p_attribute_name      IN VARCHAR2
, p_region_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region_code         IN VARCHAR2
, p_form_name           IN VARCHAR2
, p_label               IN VARCHAR2
, p_where_clause        IN VARCHAR2  := NULL
, p_selected_value      IN  BIS_LOV_PVT.Value_id_record
, p_func                IN  VARCHAR2 DEFAULT NULL
, p_size                IN  NUMBER   DEFAULT 20
, x_list_str            OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

procedure Get_List
( p_attribute1_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute1_code      IN VARCHAR2
, p_attribute1_name      IN VARCHAR2
, p_region1_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region1_code         IN VARCHAR2
, p_form1_name           IN VARCHAR2
, p_where_clause1        IN VARCHAR2  := NULL
, p_selected_value1      IN BIS_LOV_PVT.Value_id_record
, p_func1                IN  VARCHAR2 DEFAULT NULL
, p_size1                IN  NUMBER   DEFAULT 20
, p_attribute2_app_id    IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_attribute2_code      IN VARCHAR2
, p_attribute2_name      IN VARCHAR2
, p_region2_app_id       IN NUMBER    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_ID
, p_region2_code         IN VARCHAR2
, p_form2_name           IN VARCHAR2
, p_where_clause2        IN VARCHAR2  := NULL
, p_selected_value2      IN BIS_LOV_PVT.Value_id_record
, p_func2                IN  VARCHAR2 DEFAULT NULL
, p_size2                IN  NUMBER   DEFAULT 20
, p_label                IN VARCHAR2  := NULL
, p_separator            IN VARCHAR2  := BIS_UTILITIES_PVT.G_BIS_SEPARATOR
, x_list_str             OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
);

--
--
END BIS_LOV_PVT;

 

/
