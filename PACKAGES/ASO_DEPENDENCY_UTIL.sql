--------------------------------------------------------
--  DDL for Package ASO_DEPENDENCY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_DEPENDENCY_UTIL" AUTHID CURRENT_USER AS
/* $Header: asovdpus.pls 120.1 2005/06/29 12:41:38 appldev noship $ */
-- Package name     : ASO_DEPENDENCY_UTIL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--  Max number of dependent attributes.

G_MAX               NUMBER := 1000;

g_schema			      VARCHAR2(30);

--  Global table holding attribute dependencies.

TYPE Dep_Rec_Type IS RECORD
(attribute               NUMBER
);

TYPE Dep_Tbl_TYPE IS TABLE OF Dep_Rec_Type
INDEX BY BINARY_INTEGER;

g_dep_tbl          Dep_Tbl_Type;
g_dep_chain_tbl    Dep_Tbl_Type;


--  Generic table types
TYPE Boolean_Tbl_Type IS TABLE OF BOOLEAN
    INDEX BY BINARY_INTEGER;

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

PROCEDURE Make_Dependency_Engine_Body (
  Errbuf                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  RetCode                 OUT NOCOPY /* file.sql.39 change */ NUMBER,
  p_database_object_name  IN  VARCHAR2,
  p_primary_key_name      IN  VARCHAR2,
  p_last_update_date_name IN  VARCHAR2);

PROCEDURE Attribute_Code_To_Id
(   P_ATTRIBUTE_CODES_TBL           IN  ASO_DEFAULTING_INT.attribute_Codes_Tbl_Type
  , P_DATABASE_OBJECT_NAME          IN  VARCHAR2
  , X_ATTRIBUTE_IDS_TBL             OUT NOCOPY /* file.sql.39 change */ ASO_DEFAULTING_INT.attribute_Ids_Tbl_Type
);

END ASO_DEPENDENCY_UTIL;

 

/
