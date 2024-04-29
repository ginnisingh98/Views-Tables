--------------------------------------------------------
--  DDL for Package EGO_DOM_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DOM_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: EGODMSCS.pls 120.5 2006/09/20 13:20:38 sabatra noship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to resolve docuemnt security                   |
 | based on data security                                                    |
 +---------------------------------------------------------------------------*/
  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'EGO_DOM_SECURITY_PVT';

  TYPE   grantee_rec  IS RECORD
  (
     grantee_name       VARCHAR2(80),
     grantee_type       VARCHAR2(30),
     role_name          VARCHAR2(30),
     role_display_name  VARCHAR2(80),
     default_access     VARCHAR2(50)
  );
  TYPE   grantees_tbl_type IS TABLE OF grantee_rec INDEX BY BINARY_INTEGER;

 --------------------------------------------------------------
  PROCEDURE Get_Users
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

PROCEDURE GET_VALID_INSTANCE_SET_IDS
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

FUNCTION Get_Default_Access
 (
   p_menu_id IN NUMBER
 ) RETURN VARCHAR2;
-----------------------------------------------------------------

FUNCTION GET_ATTACHMENT_PRIVILAGES
(
p_entity_name IN VARCHAR2,
p_pk1_value IN VARCHAR2,
p_pk2_value IN VARCHAR2,
p_pk3_value IN VARCHAR2,
p_pk4_value IN VARCHAR2,
p_pk5_value IN VARCHAR2,
p_user_name IN VARCHAR2,
p_attachment_id IN NUMBER DEFAULT NULL
) RETURN VARCHAR2;

-----------------------------------------------------------------


END EGO_DOM_SECURITY_PVT;

 

/
