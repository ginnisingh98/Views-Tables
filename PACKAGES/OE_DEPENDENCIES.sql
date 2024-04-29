--------------------------------------------------------
--  DDL for Package OE_DEPENDENCIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEPENDENCIES" AUTHID CURRENT_USER AS
/* $Header: OEXUDEPS.pls 120.0.12010000.1 2008/07/25 07:55:32 appldev ship $ */

--  Max number of dependent attributes.

G_MAX          CONSTANT    NUMBER := 100;

--  Global table holding attribute dependencies.

TYPE Dep_Rec_Type IS RECORD
(attribute               NUMBER
,enabled_flag            VARCHAR2(1) := 'Y'
);

TYPE Dep_Tbl_TYPE IS TABLE OF Dep_Rec_Type
INDEX BY BINARY_INTEGER;

g_dep_tbl          Dep_Tbl_Type;

g_entity_code      VARCHAR2(30) := NULL;


PROCEDURE   Mark_Dependent
(   p_entity_code	IN  VARCHAR2				,
    p_source_attr_tbl	IN  OE_GLOBALS.Number_Tbl_Type :=
				OE_GLOBALS.G_MISS_NUMBER_TBL	,
    p_dep_attr_tbl	OUT NOCOPY /* file.sql.39 change */  OE_GLOBALS.Number_Tbl_Type
);


PROCEDURE   Clear_Dependent_Table;

END OE_Dependencies;

/
