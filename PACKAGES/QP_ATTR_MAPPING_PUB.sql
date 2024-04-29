--------------------------------------------------------
--  DDL for Package QP_ATTR_MAPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ATTR_MAPPING_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPSRCS.pls 120.2.12010000.3 2009/06/24 10:45:15 hmohamme ship $ */

--
g_dynamic_mapping_needed   varchar2(1) := 'Y';
--added for MOAC
G_ORG_ID NUMBER;
--
g_dynamic_mapping_count  BINARY_INTEGER:=0;  -- 7323926
TYPE Contexts_Result_Rec_Type IS RECORD
(	context_name		VARCHAR2(30)
,	attribute_name		VARCHAR2(240)
,	attribute_value	VARCHAR2(240)
);

TYPE Sourced_Contexts_Rec_Type IS RECORD
(	attribute_name		VARCHAR2(240)
,	src_type		VARCHAR2(30)
,	src_api_pkg		VARCHAR2(1000)
,	src_api_fn		VARCHAR2(1000)
,	src_profile_option	VARCHAR2(240)
,	src_system_variable	VARCHAR2(240)
,	src_constant_value	VARCHAR2(240)
,	context_name		VARCHAR2(240)
,	context_type		VARCHAR2(30)
);

TYPE New_Sourced_Contexts_Rec_Type IS RECORD
(       attribute_name          VARCHAR2(240)
,       src_type                VARCHAR2(30)
,       value_string            VARCHAR2(2000)
,       context_name            VARCHAR2(240)
,       context_type            VARCHAR2(30)
);

TYPE New_Sourced_Contexts_Tbl_Type IS TABLE OF New_Sourced_Contexts_Rec_Type INDEX BY BINARY_INTEGER;

TYPE t_Segment_Ctr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE Contexts_Result_Tbl_Type IS TABLE OF Contexts_Result_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Sourced_Contexts_Tbl_Type IS TABLE OF Sourced_Contexts_Rec_Type INDEX BY BINARY_INTEGER;

TYPE t_MultiRecord IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

TYPE User_Attribute_Rec_Type IS RECORD
(	context_name		VARCHAR2(30)
,	attribute_name		VARCHAR2(240)
);

TYPE User_Attribute_Tbl_Type IS TABLE OF User_Attribute_Rec_Type INDEX BY BINARY_INTEGER;

PROCEDURE Put_line (Text VARCHAR2);

PROCEDURE Print_Line(Text VARCHAR2); --Bug#4509601

PROCEDURE Init_Applsys_Schema;

PROCEDURE New_Line;

PROCEDURE Comment
(   p_comment      IN  VARCHAR2
,   p_level        IN  NUMBER default 1
);

PROCEDURE Text
(   p_string   IN  VARCHAR2
,   p_level    IN  NUMBER default 1
);

PROCEDURE Pkg_End
(   p_pkg_name IN  VARCHAR2
,   p_pkg_type IN  VARCHAR2
);

PROCEDURE Pkg_Header
(   p_pkg_name IN  VARCHAR2
,   p_pkg_type IN  VARCHAR2
);

PROCEDURE Create_Sourcing_Calls
(    p_request_type_code      IN   VARCHAR2
,    p_pricing_type           IN   VARCHAR2
,    p_HVOP_Call              IN   VARCHAR2 := 'N'
);

PROCEDURE Build_Sourcing_Package
(    err_buff                OUT NOCOPY VARCHAR2
,    retcode                 OUT NOCOPY NUMBER
);


PROCEDURE Build_Contexts
(	p_request_type_code			IN	VARCHAR2
,	p_pricing_type				IN	VARCHAR2
--added for MOAC
,       p_org_id                                IN      NUMBER DEFAULT NULL
,	x_price_contexts_result_tbl		OUT	NOCOPY CONTEXTS_RESULT_TBL_TYPE
,	x_qual_contexts_result_tbl		OUT	NOCOPY CONTEXTS_RESULT_TBL_TYPE
);

/*
overloading build_contexts for AG purpose performance fix
to insert into tmp tables directly for OM Integration
changes by spgopal
*/

PROCEDURE Build_Contexts
(       p_request_type_code               IN      VARCHAR2
,       p_line_index                      IN      NUMBER
,       p_pricing_type_code               IN      VARCHAR2
,       p_price_list_validated_flag       IN      VARCHAR2 DEFAULT NULL
--added for MOAC
,       p_org_id                          IN      NUMBER DEFAULT NULL
 );



PROCEDURE Get_User_Item_Pricing_Attribs
(    p_request_type_code IN   VARCHAR2
,    p_item_id           IN   VARCHAR2
,    p_user_attribs_tbl  OUT NOCOPY USER_ATTRIBUTE_TBL_TYPE
);

PROCEDURE Get_User_Item_Pricing_Attribs
(    p_request_type_code IN   VARCHAR2
,    p_user_attribs_tbl  OUT NOCOPY USER_ATTRIBUTE_TBL_TYPE
);

PROCEDURE Get_User_Item_Pricing_Contexts
(    p_request_type_code IN   VARCHAR2
,    p_user_attribs_tbl  OUT NOCOPY USER_ATTRIBUTE_TBL_TYPE
);

FUNCTION Is_Attribute_Used (p_attribute_context IN VARCHAR2, p_attribute_code IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE Check_line_group_items(p_pricing_type_code IN VARCHAR2);

--Overloeaded in the pl/sql path for changed lines linegroup item dependency
PROCEDURE Build_Contexts
(       p_request_type_code             IN      VARCHAR2
,       p_pricing_type                  IN      VARCHAR2
,       p_check_line_flag               IN      VARCHAR2
,       p_pricing_event                 IN      VARCHAR2
--added for MOAC
,       p_org_id                        IN      NUMBER DEFAULT NULL
,       x_price_contexts_result_tbl     OUT NOCOPY    CONTEXTS_RESULT_TBL_TYPE
,       x_qual_contexts_result_tbl      OUT NOCOPY    CONTEXTS_RESULT_TBL_TYPE
,       x_pass_line                     OUT NOCOPY    VARCHAR2
);


PROCEDURE Build_Contexts
(       p_request_type_code               IN      VARCHAR2
,       p_line_index                      IN      NUMBER
,       p_check_line_flag                 IN      VARCHAR2
,       p_pricing_event                   IN      VARCHAR2
,       p_pricing_type_code               IN      VARCHAR2
,       p_price_list_validated_flag       IN      VARCHAR2 DEFAULT NULL
--added for MOAC
,       p_org_id                          IN      NUMBER DEFAULT NULL
,       x_pass_line                       OUT     NOCOPY        VARCHAR2
);

PROCEDURE Map_Used_But_Not_Mapped_Attrs
(    p_request_type_code           IN   VARCHAR2
,    p_pricing_type                IN   VARCHAR2
,    x_price_contexts_result_tbl   OUT  NOCOPY   CONTEXTS_RESULT_TBL_TYPE
,    x_qual_contexts_result_tbl    OUT  NOCOPY   CONTEXTS_RESULT_TBL_TYPE
);

PROCEDURE Check_All_Mapping
(    err_buff                OUT NOCOPY     VARCHAR2
,    retcode                 OUT NOCOPY     NUMBER
,    p_request_type_code     IN             VARCHAR2
);

G_Temp_Value	VARCHAR2(200);
G_Temp_MultiValue  t_MultiRecord;
G_Test_MultiValue  t_MultiRecord;
G_Segment_Ctr      t_Segment_Ctr;
G_User_Attribs_Tbl			  USER_ATTRIBUTE_TBL_TYPE;
G_Price_Contexts_Rslt_Tbl       Contexts_Result_Tbl_Type;
G_Qualf_Contexts_Rslt_Tbl       Contexts_Result_Tbl_Type;
G_Sourced_Contexts_Tbl       	Sourced_Contexts_Tbl_Type;
G_New_Sourced_Contexts_Tbl      New_Sourced_Contexts_Tbl_Type;
g_retcode	VARCHAR2(30);
g_errbuf	VARCHAR2(240);
G_ATTRMGR_INSTALLED  VARCHAR2(30);
G_Product_Attr_Tbl Contexts_Result_Tbl_Type;
G_PASS_THIS_LINE VARCHAR2(1) := 'Y';
G_CHECK_LINE_FLAG VARCHAR2(1) := 'N';
G_IGNORE_PRICE VARCHAR(1) := 'N';   --8589909

-- bug#3848849 Added global variable to store request type code
G_REQ_TYPE_CODE VARCHAR2(10);

END QP_Attr_Mapping_PUB;

/
