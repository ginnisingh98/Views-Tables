--------------------------------------------------------
--  DDL for Package JTM_HOOK_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_HOOK_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: jtmhutls.pls 120.1 2005/08/24 02:14:37 saradhak noship $ */

/***
  Debug levels:
  0 = No debug
  1 = Log errors
  2 = Log errors and functional messages
  3 = Log errors, functional messages and SQL statements
  4 = Full Debug
***/
g_debug_level_none        CONSTANT NUMBER := 0;
g_debug_level_error       CONSTANT NUMBER := 1;
g_debug_level_medium      CONSTANT NUMBER := 2;
g_debug_level_sql         CONSTANT NUMBER := 3;
g_debug_level_full        CONSTANT NUMBER := 4;

/*** type containing list of publication items that use an ACC table ***/
TYPE t_publication_item_list IS TABLE OF VARCHAR2(30);

FUNCTION Get_Debug_Level
RETURN NUMBER;
/***
  Function that returns debug level.
  0 = No debug
  1 = Log errors
  2 = Log errors and replication info messages
  3 = Log errors, sql and replication info messages
  4 = Full Debug (including entering/leaving procedures)
***/

FUNCTION isMobileFSresource
  ( p_resource_id in NUMBER
  )
RETURN BOOLEAN;
/* Returns whether resource_id is mobile Field Service/Laptop resource */

FUNCTION Get_Resource_Id( p_client_name IN VARCHAR2
	           )
RETURN NUMBER;
/***
Procedure that returns resource_id for a given client_name.
***/

FUNCTION Get_User_Id( p_client_name IN VARCHAR2
	           )
RETURN NUMBER;
/***
Procedure that returns user_id for a given client_name.
***/

FUNCTION Get_Acc_Id
 (  p_acc_table_name     in VARCHAR2
  , p_resource_id        in NUMBER
  , p_pk1_name           in VARCHAR2
  , p_pk1_num_value      in NUMBER   DEFAULT NULL
  , p_pk1_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value     in DATE     DEFAULT NULL
  , p_pk2_name           in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value      in NUMBER   DEFAULT NULL
  , p_pk2_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value     in DATE     DEFAULT NULL
  , p_pk3_name           in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value      in NUMBER   DEFAULT NULL
  , p_pk3_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value     in DATE     DEFAULT NULL
 )
RETURN NUMBER;
/***
  Procedure that checks if an ACC record exists for a given resource_id.
  If so, it returns the ACC record's access_id.
  If not, it returns -1.
***/

PROCEDURE Get_Resource_Acc_List
 (  p_acc_table_name     in  VARCHAR2
  , p_pk1_name           in VARCHAR2
  , p_pk1_num_value      in NUMBER   DEFAULT NULL
  , p_pk1_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value     in DATE     DEFAULT NULL
  , p_pk2_name           in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value      in NUMBER   DEFAULT NULL
  , p_pk2_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value     in DATE     DEFAULT NULL
  , p_pk3_name           in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value      in NUMBER   DEFAULT NULL
  , p_pk3_char_value     in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value     in DATE     DEFAULT NULL
  , l_tab_resource_id    out nocopy dbms_sql.Number_Table
  , l_tab_access_id      out nocopy dbms_sql.Number_Table
 );
/***
  Procedure that returns all RESOURCE_ID, ACCESS_ID combinations present in ACC for a given
  table_name, primary key name and primary key value
***/

PROCEDURE Insert_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_resource_id            in NUMBER
  , p_pk1_name               in VARCHAR2
  , p_pk1_num_value          in NUMBER   DEFAULT NULL
  , p_pk1_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value         in DATE     DEFAULT NULL
  , p_pk2_name               in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value          in NUMBER   DEFAULT NULL
  , p_pk2_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value         in DATE     DEFAULT NULL
  , p_pk3_name               in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value          in NUMBER   DEFAULT NULL
  , p_pk3_char_value         in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value         in DATE     DEFAULT NULL
 );
/*** Procedure that inserts record into any ACC table ***/

PROCEDURE Update_Acc
 ( p_publication_item_names in t_publication_item_list
  ,p_acc_table_name         in VARCHAR2
  ,p_resource_id            in NUMBER
  ,p_access_id              in NUMBER
 );
/*** Procedure that re-sends a record with given acc_id to the mobile ***/

PROCEDURE Delete_Acc
 ( p_publication_item_names in t_publication_item_list
  , p_acc_table_name        in VARCHAR2
  , p_pk1_name              in VARCHAR2
  , p_pk1_num_value         in NUMBER   DEFAULT NULL
  , p_pk1_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk1_date_value        in DATE     DEFAULT NULL
  , p_pk2_name              in VARCHAR2 DEFAULT NULL
  , p_pk2_num_value         in NUMBER   DEFAULT NULL
  , p_pk2_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk2_date_value        in DATE     DEFAULT NULL
  , p_pk3_name              in VARCHAR2 DEFAULT NULL
  , p_pk3_num_value         in NUMBER   DEFAULT NULL
  , p_pk3_char_value        in VARCHAR2 DEFAULT NULL
  , p_pk3_date_value        in DATE     DEFAULT NULL
  , p_resource_id           in NUMBER   DEFAULT NULL
  , p_operator              in VARCHAR2 DEFAULT NULL
);
/***
 Procedure that deletes record(s) from any ACC table
 If p_resource_id is NULL, all ACC records that match the PK values are deleted.
 If p_resource_id is specified and p_operator='=' the ACC record is only deleted for that specific resource.
 If p_resource_id is specified and p_operator='<>' all ACC records with resource_id<>p_resource_id are deleted
***/

PROCEDURE DELETE_ACC_FOR_RESOURCE
( p_acc_table_name IN VARCHAR2
, p_resource_id IN NUMBER
);
/****
 Procedure that deletes all acc records for an acc table for a resource
****/

FUNCTION Get_Profile_Value( p_name        IN VARCHAR2
                          , p_site_id     IN NUMBER  DEFAULT NULL
	                  , p_appl_id     IN NUMBER  DEFAULT NULL
                          , p_user_id     IN NUMBER  DEFAULT NULL
                          , p_resp_id     IN NUMBER  DEFAULT NULL
	           )
RETURN VARCHAR2;
/***
Procedure that returns profile value with a given name.
The level from which the value is coming can be chosen by entering a site,appl,user or resp ID
***/

END JTM_HOOK_UTIL_PKG;

 

/
