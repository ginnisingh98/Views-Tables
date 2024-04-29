--------------------------------------------------------
--  DDL for Package ENG_CHANGE_ROLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_ROLES_PUB" AUTHID CURRENT_USER AS
/* $Header: ENGCMRLS.pls 120.0 2005/09/15 03:35:09 sdarbha noship $ */


  G_PKG_NAME 	CONSTANT VARCHAR2(30):= 'ENG_CHANGE_ROLES_PUB';

TYPE grantee_rec  IS RECORD
(
	role_name          VARCHAR2(30),
	role_display_name  VARCHAR2(120),
	grantee_type       VARCHAR2(30),
	grantee_name       VARCHAR2(120),
     default_access     VARCHAR2(50)
);

TYPE  grantees_tbl_type IS TABLE OF grantee_rec INDEX BY BINARY_INTEGER;

 --------------------------------------------------------------
PROCEDURE Get_Change_Users
  (
   p_api_version               IN  NUMBER,
   p_entity_name               IN  VARCHAR2,
   p_pk1_value                 IN  VARCHAR2,
   p_pk2_value                 IN  VARCHAR2,
   p_pk3_value                 IN  VARCHAR2,
   p_pk4_value                 IN  VARCHAR2,
   p_pk5_value                 IN  VARCHAR2,
   p_role_name                 IN  VARCHAR2 DEFAULT NULL,
   x_grantee_names             OUT NOCOPY FND_TABLE_OF_VARCHAR2_120,
   x_grantee_types             OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_role_names                OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_role_display_names        OUT NOCOPY FND_TABLE_OF_VARCHAR2_120,
   x_default_access            OUT NOCOPY FND_TABLE_OF_VARCHAR2_30,
   x_return_status             OUT NOCOPY VARCHAR2
  );
-----------------------------------------------------------------
PROCEDURE Get_Valid_Instance_Set_Ids
 (
   p_obj_name                   IN VARCHAR2,
   p_grantee_type               IN VARCHAR2,
   p_parent_obj_sql             IN VARCHAR2,
   p_bind1                      IN VARCHAR2,
   p_bind2                      IN VARCHAR2,
   p_bind3                      IN VARCHAR2,
   p_bind4                      IN VARCHAR2,
   p_bind5                      IN VARCHAR2,
   p_obj_ids                    IN VARCHAR2,
   x_inst_set_ids               OUT NOCOPY VARCHAR2
 );

-----------------------------------------------------------------
--PROCEDURE p( p_string in varchar2 );

------------------------------------------------------------------
--PROCEDURE Get_Default_Access(p_menu_id IN NUMBER, p_default_access OUT VARCHAR2);

------------------------------------------------------------------

END ENG_CHANGE_ROLES_PUB;


 

/
