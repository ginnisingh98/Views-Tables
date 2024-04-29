--------------------------------------------------------
--  DDL for Package OE_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GENERATE" AUTHID CURRENT_USER AS
/* $Header: OEXTGENS.pls 120.0 2005/06/01 00:40:39 appldev noship $ */

--  Attribute record type.

TYPE Attribute_Rec_Type IS RECORD
(   name		VARCHAR2(30)	:=  NULL
,   column		VARCHAR2(30)	:=  NULL
,   code		VARCHAR2(30)	:=  NULL
,   value		BOOLEAN		:=  FALSE
,   value_type		VARCHAR2(30)	:=  NULL
,   type		VARCHAR2(30)	:=  NULL
,   length		NUMBER		:=  NULL
,   context		BOOLEAN		:=  FALSE
,   category		NUMBER		:=  NULL
,   db_attr		BOOLEAN		:=  TRUE
,   pk_flag		BOOLEAN		:=  FALSE
,   text1		VARCHAR2(30)	:=  NULL
,   text2		VARCHAR2(30)	:=  NULL
,   text3		VARCHAR2(30)	:=  NULL
);

--  Attribute table type.

TYPE Attribute_Tbl_Type IS TABLE OF Attribute_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Gloabl attribute table.

g_attr_tbl	Attribute_Tbl_Type;

--  Missing constants

G_MISS_ATTR_REC			Attribute_Rec_Type;
G_MISS_ATTR_TBL			Attribute_Tbl_Type;

--  Entity record type.

TYPE Entity_Rec_Type IS RECORD
(   name	    VARCHAR2(30)    :=  NULL
,   plural_name	    VARCHAR2(30)    :=  NULL
,   tbl		    VARCHAR2(30)    :=  NULL
,   read_view	    VARCHAR2(30)    :=  NULL
,   parent	    NUMBER	    :=  NULL
,   multiple	    BOOLEAN	    :=  FALSE
,   code	    VARCHAR2(30)    :=  NULL
,   pk_column	    VARCHAR2(30)    :=	NULL	--  To be obsoleted
,   text1	    VARCHAR2(30)    :=  NULL
,   text2	    VARCHAR2(30)    :=  NULL
,   text3	    VARCHAR2(30)    :=  NULL
);

--  Entity table type.

TYPE Entity_Tbl_Type IS TABLE OF Entity_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Missing constants

G_MISS_ENTITY_REC		Entity_Rec_Type;
G_MISS_ENTITY_TBL		Entity_Tbl_Type;

--  Gloabl entity table.

g_entity_tbl	Entity_Tbl_Type;

--  Attribute types.

G_TYPE_NUMBER	    CONSTANT	VARCHAR2(30) := 'NUMBER';
G_TYPE_CHAR	    CONSTANT	VARCHAR2(30) := 'VARCHAR2';
G_TYPE_DATE	    CONSTANT	VARCHAR2(30) := 'DATE';
G_TYPE_KEY_FLEX	    CONSTANT	VARCHAR2(30) := 'KEY_FLEX';

--  Attribute categories

G_CAT_REGULAR		CONSTANT NUMBER := 1;
G_CAT_DESC_FLEX		CONSTANT NUMBER := 2;
G_CAT_KEY_FLEX		CONSTANT NUMBER := 3;
G_CAT_WHO		CONSTANT NUMBER := 4;
G_CAT_TEMP		CONSTANT NUMBER := 5;

--  Gloabl attribute table.

g_attr_value_tbl    Attribute_Tbl_Type;

--  Gloabl primary key attribute table.

g_pk_attr_tbl	Attribute_Tbl_Type;

--  Gloabl Flex attribute table.

g_flex_attr_tbl	Attribute_Tbl_Type;

--  Flexfield types

G_FLEX_TYPE_DESC	CONSTANT NUMBER := 1;
G_FLEX_TYPE_KEY		CONSTANT NUMBER := 2;

--  Flexfield record type

TYPE Flex_Rec_Type IS RECORD
(   name	    VARCHAR2(30)
,   seg_count	    NUMBER
);

--  Flex table type.

TYPE Flex_Tbl_Type IS TABLE OF Flex_Rec_Type
    INDEX BY BINARY_INTEGER;

--  Global flex table

g_desc_flex_tbl	    Flex_Tbl_Type;
g_key_flex_tbl	    Flex_Tbl_Type;

--  Message types.

G_MSG_ERROR		CONSTANT    NUMBER := 1;
G_MSG_SUCCESS		CONSTANT    NUMBER := 2;
G_MSG_UNEXP_ERROR	CONSTANT    NUMBER := 3;

--  Package Types.

G_PKG_TYPE_BODY	    CONSTANT	VARCHAR2(30) := 'BODY';
G_PKG_TYPE_SPEC	    CONSTANT	VARCHAR2(30) := 'SPEC';

--  API Types.

G_API_TYPE_PUB	    CONSTANT	VARCHAR2(30) := 'PUB';
G_API_TYPE_PVT	    CONSTANT	VARCHAR2(30) := 'PVT';
G_API_TYPE_GRP	    CONSTANT	VARCHAR2(30) := 'GRP';


--  Varchar2 160 tbl type.

TYPE Varchar2_160_Tbl_Type IS TABLE OF VARCHAR2(160)
    INDEX BY BINARY_INTEGER;

--  Global src table.

g_src_tbl		Varchar2_160_Tbl_Type;

--  Global variables set by generation scripts.

g_product	    VARCHAR2(4);
g_product_file	    VARCHAR2(4);
g_file_location	    VARCHAR2(240);
g_form_code	    VARCHAR2(30);
g_object_code	    VARCHAR2(30);
g_object_name	    VARCHAR2(30);
g_current_entity    NUMBER;

--  Derived variables set by generation scripts.

CONS_l_g_rec		    VARCHAR2(30);
CONS_l_g_db_rec		    VARCHAR2(30);
CONS_l_l_rec		    VARCHAR2(30);
CONS_l_p_rec		    VARCHAR2(30);
CONS_l_l_x_rec		    VARCHAR2(30);
CONS_l_x_rec		    VARCHAR2(30);
CONS_l_l_old_rec	    VARCHAR2(30);
CONS_l_p_old_rec	    VARCHAR2(30);
CONS_l_x_old_rec	    VARCHAR2(30);
CONS_l_l_val_rec	    VARCHAR2(30);
CONS_l_p_val_rec	    VARCHAR2(30);
CONS_l_x_val_rec	    VARCHAR2(30);
CONS_l_g_val_rec	    VARCHAR2(30);
CONS_l_l_tbl		    VARCHAR2(30);
CONS_l_g_tbl		    VARCHAR2(30);
CONS_l_p_tbl		    VARCHAR2(30);
CONS_l_l_x_tbl		    VARCHAR2(30);
CONS_l_x_tbl		    VARCHAR2(30);
CONS_l_l_old_tbl	    VARCHAR2(30);
CONS_l_p_old_tbl	    VARCHAR2(30);
CONS_l_x_old_tbl	    VARCHAR2(30);
CONS_l_g_val_tbl	    VARCHAR2(30);
CONS_l_p_val_tbl	    VARCHAR2(30);
CONS_l_x_val_tbl	    VARCHAR2(30);
CONS_l_pub_bus_obj_pkg	    VARCHAR2(30);
CONS_l_pvt_bus_obj_pkg	    VARCHAR2(30);
CONS_l_entity_attr_pkg	    VARCHAR2(30);
CONS_l_util_pkg		    VARCHAR2(30);
CONS_l_val_to_id_pkg	    VARCHAR2(30);
CONS_l_def_pkg		    VARCHAR2(30);
CONS_l_val_pkg		    VARCHAR2(30);
CONS_l_glb_pkg		    VARCHAR2(30);
CONS_l_form_pkg		    VARCHAR2(30);
CONS_l_id_to_value_pkg	    VARCHAR2(30);
CONS_l_rec_type		    VARCHAR2(60);
CONS_l_tbl_type		    VARCHAR2(60);
CONS_l_val_rec_type	    VARCHAR2(60);
CONS_l_val_tbl_type	    VARCHAR2(60);
CONS_l_ctrl_rec_type	    VARCHAR2(60);
CONS_l_entity_prefix	    VARCHAR2(60);
CONS_l_miss_rec		    VARCHAR2(60);
CONS_l_miss_val_rec	    VARCHAR2(60);
CONS_l_miss_tbl		    VARCHAR2(60);
CONS_l_miss_val_tbl	    VARCHAR2(60);

TYPE gen_pkg_rec_type IS RECORD
(   name	VARCHAR2(30)
,   type	VARCHAR2(30)
,   filename	VARCHAR2(30)
);

TYPE gen_pkg_tbl_type IS TABLE OF gen_pkg_rec_type
    INDEX BY BINARY_INTEGER;

--  Global generated package table.

g_gen_pkg_tbl	gen_pkg_tbl_type;

--  Global results file handlers.

g_results_file	    UTL_FILE.file_type;

--  Prototypes.

PROCEDURE API_Parameters
(   p_file	    IN  UTL_FILE.file_type
,   p_product	    IN	VARCHAR2
,   p_object	    IN	VARCHAR2
,   p_name	    IN  VARCHAR2
,   p_type	    IN  VARCHAR2
,   p_entity_tbl    IN	Entity_Tbl_Type
,   p_lock_api	    IN	BOOLEAN := FALSE
);

PROCEDURE API_Header
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_type	IN  VARCHAR2
);

PROCEDURE Pkg_Header
(   p_file	IN  UTL_FILE.file_type
,   p_filename	IN  VARCHAR2
,   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
);

PROCEDURE Pkg_End
(   p_file	IN  UTL_FILE.file_type
,   p_pkg_name	IN  VARCHAR2
,   p_pkg_type	IN  VARCHAR2
,   p_filename	IN  VARCHAR2 := NULL
);

PROCEDURE Log_Compile
(   p_pkg_name	    IN	VARCHAR2
,   p_filename	    IN	VARCHAR2
,   p_pkg_type	    IN	VARCHAR2
);

PROCEDURE Parameter
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'IN'
,   p_type	IN  VARCHAR2 := G_TYPE_NUMBER
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
);

PROCEDURE Element
(   p_file	IN  UTL_FILE.file_type
,   p_element	IN  VARCHAR2
,   p_type	IN  VARCHAR2 := G_TYPE_NUMBER
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
);

PROCEDURE Variable
(   p_file	IN  UTL_FILE.file_type
,   p_var	IN  VARCHAR2
,   p_type	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
);

PROCEDURE Assign
(   p_file	IN  UTL_FILE.file_type
,   p_left	IN  VARCHAR2
,   p_right	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
);

PROCEDURE Check_Status
(   p_file	IN  UTL_FILE.file_type
,   p_variable	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
);

PROCEDURE Call_Param
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_val	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
);

PROCEDURE End_Call
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

PROCEDURE Get_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

PROCEDURE Comment
(   p_file	    IN  UTL_FILE.file_type
,   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER := 1
,   p_line_before   IN	BOOLEAN := TRUE
,   p_line_after    IN	BOOLEAN := TRUE
);

PROCEDURE Text
(   p_file	IN  UTL_FILE.file_type
,   p_string	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
);

PROCEDURE Msg
(   p_file	IN  UTL_FILE.file_type
,   p_product	IN  VARCHAR2
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 2
,   p_tk1	IN  VARCHAR2 := NULL
,   p_tk1_val	IN  VARCHAR2 := NULL
,   p_tk2	IN  VARCHAR2 := NULL
,   p_tk2_val	IN  VARCHAR2 := NULL
,   p_tk3	IN  VARCHAR2 := NULL
,   p_tk3_val	IN  VARCHAR2 := NULL
,   p_tk4	IN  VARCHAR2 := NULL
,   p_tk4_val	IN  VARCHAR2 := NULL
,   p_tk5	IN  VARCHAR2 := NULL
,   p_tk5_val	IN  VARCHAR2 := NULL
,   p_type	IN  NUMBER   := G_MSG_ERROR
,   p_tk1_is_text IN  BOOLEAN := TRUE
,   p_tk2_is_text IN  BOOLEAN := TRUE
,   p_tk3_is_text IN  BOOLEAN := TRUE
,   p_tk4_is_text IN  BOOLEAN := TRUE
,   p_tk5_is_text IN  BOOLEAN := TRUE
);

PROCEDURE Error_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_product	IN  VARCHAR2
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 2
,   p_tk1	IN  VARCHAR2 := NULL
,   p_tk1_val	IN  VARCHAR2 := NULL
,   p_tk2	IN  VARCHAR2 := NULL
,   p_tk2_val	IN  VARCHAR2 := NULL
,   p_tk3	IN  VARCHAR2 := NULL
,   p_tk3_val	IN  VARCHAR2 := NULL
,   p_tk4	IN  VARCHAR2 := NULL
,   p_tk4_val	IN  VARCHAR2 := NULL
,   p_tk5	IN  VARCHAR2 := NULL
,   p_tk5_val	IN  VARCHAR2 := NULL
,   p_tk1_is_text IN  BOOLEAN := TRUE
,   p_tk2_is_text IN  BOOLEAN := TRUE
,   p_tk3_is_text IN  BOOLEAN := TRUE
,   p_tk4_is_text IN  BOOLEAN := TRUE
,   p_tk5_is_text IN  BOOLEAN := TRUE
);

PROCEDURE Exc_Msg
(   p_file	IN  UTL_FILE.file_type
,   p_procedure	IN  VARCHAR2
,   p_error	IN  VARCHAR2 := NULL
,   p_level	IN  NUMBER := 2
,   p_text	IN  BOOLEAN := FALSE
);

PROCEDURE Std_Exc_Handler
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2 := NULL
,   p_savepoint	IN  VARCHAR2 := NULL
);

PROCEDURE Others_Exc
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2	:= NULL
,   p_level	IN  NUMBER	:= 0
,   p_raise_exc	IN  BOOLEAN	:= TRUE
);

PROCEDURE Client_Exception
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2	:=  NULL
,   p_level	IN  NUMBER	:= 0
);

PROCEDURE Comp_Check
(   p_file	IN  UTL_FILE.file_type
);

PROCEDURE API_Local_Vars
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_pkg	    IN	VARCHAR2
);

PROCEDURE API_Out_Vars
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_pkg	    IN	VARCHAR2
,   p_level	    IN  NUMBER := 1
);

PROCEDURE API_Out_Param
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_level	    IN  NUMBER := 1
,   p_entity_prefix IN	VARCHAR2 := 'l_'
,   p_type	    IN	VARCHAR2 := G_API_TYPE_PVT
);

PROCEDURE API_In_Param
(   p_file	    IN  UTL_FILE.file_type
,   p_entity_tbl    IN  Entity_Tbl_Type
,   p_level	    IN  NUMBER := 1
,   p_entity_prefix IN	VARCHAR2 := 'l_'
,   p_old_param	    IN	BOOLEAN := TRUE
,   p_val_param     IN	BOOLEAN := FALSE
,   p_id_param      IN	BOOLEAN := FALSE
);

FUNCTION Gen_Start_Token
(   p_text	IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Gen_End_Token
(   p_text	IN  VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Is_Gen_Start
(   p_text	IN  VARCHAR2
)
RETURN BOOLEAN;

FUNCTION Is_Gen_End
(   p_text	IN  VARCHAR2
)
RETURN BOOLEAN;

PROCEDURE Start_Gen
(   p_file	IN  UTL_FILE.file_type
,   p_text	IN  VARCHAR2
);

PROCEDURE End_Gen
(   p_file	IN  UTL_FILE.file_type
,   p_text	IN  VARCHAR2
);

PROCEDURE Load_File
(   p_file	IN  UTL_FILE.file_type
);

PROCEDURE Load_PK_Attr_Tbl;
PROCEDURE Load_Flex_Tables;
PROCEDURE Load_Flex_Attr_Tbl
(   p_flex_name	    IN	VARCHAR2
);

PROCEDURE Parameter_PK
(   p_file	   IN  UTL_FILE.file_type
,   p_mode	   IN  VARCHAR2 := 'IN'
,   p_level	   IN  NUMBER := 0
,   p_rpad	   IN  NUMBER := 30
,   p_first	   IN  BOOLEAN := FALSE

    -- Should defaults be given to PK's
,   p_default_miss IN  BOOLEAN := FALSE

    -- Should VALUE fields of PK's be added
,   p_value	   IN  BOOLEAN := FALSE

    -- Use this table to generate parameters
    -- else use the pk_attribute table
,   p_attr_tbl	   IN  Attribute_Tbl_Type :=
		       G_MISS_ATTR_TBL
);

PROCEDURE Call_Param_PK
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2 := NULL
,   p_val	IN  VARCHAR2 := NULL
,   p_level	IN  NUMBER := 1
,   p_rpad	IN  NUMBER := 30
,   p_first	IN  BOOLEAN := FALSE
);

PROCEDURE Add_Savepoint
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
);

PROCEDURE Add_Rollback
(   p_file	IN  UTL_FILE.file_type
,   p_name	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
);

PROCEDURE Load_Constants
(   p_entity_name	    IN	VARCHAR2
);

PROCEDURE End_If
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

PROCEDURE Add_Then
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

PROCEDURE Add_Is
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 0
);

PROCEDURE Add_Begin
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 0
);

PROCEDURE Add_Else
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

PROCEDURE End_Loop
(   p_file	IN  UTL_FILE.file_type
,   p_level	IN  NUMBER := 1
);

FUNCTION Get_Name_In
(   p_attr_rec	    IN	Attribute_Rec_type
,   p_block_name    IN	VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE Add_Copy
(   p_file	    IN	UTL_FILE.file_type
,   p_source	    IN	VARCHAR2
,   p_dest	    IN	VARCHAR2
,   p_type	    IN	VARCHAR2 := G_TYPE_CHAR
,   p_level	    IN	NUMBER := 1
);

PROCEDURE IDL_Comment
(   p_file	    IN  UTL_FILE.file_type
,   p_comment	    IN  VARCHAR2
,   p_level	    IN  NUMBER := 1
,   p_line_before   IN	BOOLEAN := TRUE
,   p_line_after    IN	BOOLEAN := TRUE
);

PROCEDURE IDL_Header
(   p_file	    IN  UTL_FILE.file_type
,   p_filename	    IN  VARCHAR2
,   p_object_name   IN  VARCHAR2
);

FUNCTION Strip_Underscore
(   p_string	    IN	VARCHAR2
)
RETURN VARCHAR2 ;

PROCEDURE Strip_Entities;

FUNCTION Strip_Attributes
(   p_attr_tbl	    IN	Attribute_Tbl_Type
)
RETURN Attribute_Tbl_Type;

PROCEDURE IDL_Parameter
(   p_file	IN  UTL_FILE.file_type
,   p_param	IN  VARCHAR2
,   p_mode	IN  VARCHAR2 := 'in'
,   p_type	IN  VARCHAR2
,   p_level	IN  NUMBER := 1
,   p_first	IN  BOOLEAN := FALSE
);

FUNCTION Get_Attr_Values
(   p_attr_code	    IN	VARCHAR2
) RETURN Attribute_Tbl_Type;

PROCEDURE Get_Api_Parameters
(   p_file	    IN  UTL_FILE.file_type
,   p_product	    IN	VARCHAR2
,   p_object	    IN	VARCHAR2
,   p_name	    IN  VARCHAR2
,   p_type	    IN  VARCHAR2 := G_API_TYPE_PVT
,   p_entity_tbl    IN	Entity_Tbl_Type
);

PROCEDURE Null_Or_Missing
(  p_file		IN  UTL_FILE.file_type
,  p_attribute		IN  attribute_rec_type
,  p_prefix_text	IN  VARCHAR2 := NULL
,  p_not		IN  BOOLEAN := TRUE
,  p_and		IN  BOOLEAN := TRUE
,  p_level		IN  NUMBER  := 1
,  p_first		IN  BOOLEAN := FALSE
);

PROCEDURE Load_Entity_Attributes
(   p_entity_rec    IN  Entity_Rec_Type
);

PROCEDURE Load_Entity_Attribute_Values
(   p_entity_rec    IN  Entity_Rec_Type
);

-- The function returns true if
-- ENTITY AT CURRENT INDEX
-- OR
-- ANY PARENT OF CURRENT INDEX
-- is a multiple

FUNCTION Multiple_Branch
(   p_index	    IN	NUMBER
)   RETURN BOOLEAN;

FUNCTION Multiple_Branch
(   p_entity_name    IN  VARCHAR2
) RETURN BOOLEAN;


FUNCTION Convert_Entity_Rec_Type
(   p_runtime_entity_rec	    IN	FND_API.Entity_Rec_Type
) RETURN OE_GENERATE.Entity_Rec_Type;

FUNCTION Convert_Entity_Tbl_Type
(   p_runtime_entity_tbl	    IN	FND_API.Entity_Tbl_Type
) RETURN OE_GENERATE.Entity_Tbl_Type;

END OE_GENERATE;

 

/
