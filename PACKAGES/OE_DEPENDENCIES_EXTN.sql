--------------------------------------------------------
--  DDL for Package OE_DEPENDENCIES_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEPENDENCIES_EXTN" AUTHID CURRENT_USER AS
/* $Header: OEXEDEPS.pls 120.0 2005/05/31 22:46:59 appldev noship $ */

TYPE Dep_Rec_Type IS RECORD
(source_attribute        NUMBER
,dependent_attribute     NUMBER
,enabled_flag            VARCHAR2(1) := 'Y'
);

TYPE Dep_Tbl_TYPE IS TABLE OF Dep_Rec_Type
INDEX BY BINARY_INTEGER;

PROCEDURE   Load_Entity_Attributes
(   p_entity_code	IN  VARCHAR2
,   x_extn_dep_tbl      OUT NOCOPY /* file.sql.39 change */ Dep_Tbl_TYPE);

END OE_Dependencies_Extn;

 

/
