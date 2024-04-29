--------------------------------------------------------
--  DDL for Package FEM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_UTILS" AUTHID CURRENT_USER as
--$Header: FEMUTILS.pls 120.0 2005/06/06 20:31:10 appldev noship $
   -- utility function used by both DSWG and RSM

   -- these variables must be kept in numerical order, with the lowest number indicating 'no error',
   -- and each variable after indicating a higher level of error (with the highest being utterly fatal..
   G_RSM_NO_ERR            CONSTANT NUMBER := 0;
   G_RSM_NONFATAL_ERR      CONSTANT NUMBER := 1;
   G_RSM_FATAL_ERR         CONSTANT NUMBER := 2;

   PROCEDURE set_master_err_state(  p_master_err_state   IN OUT NOCOPY  NUMBER,
                                    err_state            IN             NUMBER,
                                    p_app_name           IN             VARCHAR2,
                                    p_msg_name           IN             VARCHAR2,
                                    p_token1             IN             VARCHAR2 DEFAULT NULL,
                                    p_value1             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans1             IN             VARCHAR2 DEFAULT NULL,
                                    p_token2             IN             VARCHAR2 DEFAULT NULL,
                                    p_value2             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans2             IN             VARCHAR2 DEFAULT NULL,
                                    p_token3             IN             VARCHAR2 DEFAULT NULL,
                                    p_value3             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans3             IN             VARCHAR2 DEFAULT NULL,
                                    p_token4             IN             VARCHAR2 DEFAULT NULL,
                                    p_value4             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans4             IN             VARCHAR2 DEFAULT NULL,
                                    p_token5             IN             VARCHAR2 DEFAULT NULL,
                                    p_value5             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans5             IN             VARCHAR2 DEFAULT NULL,
                                    p_token6             IN             VARCHAR2 DEFAULT NULL,
                                    p_value6             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans6             IN             VARCHAR2 DEFAULT NULL,
                                    p_token7             IN             VARCHAR2 DEFAULT NULL,
                                    p_value7             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans7             IN             VARCHAR2 DEFAULT NULL,
                                    p_token8             IN             VARCHAR2 DEFAULT NULL,
                                    p_value8             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans8             IN             VARCHAR2 DEFAULT NULL,
                                    p_token9             IN             VARCHAR2 DEFAULT NULL,
                                    p_value9             IN             VARCHAR2 DEFAULT NULL,
                                    p_trans9             IN             VARCHAR2 DEFAULT NULL );

   Procedure GetObjNameandFolderUsingObj(p_Object_ID IN NUMBER
                                        ,x_Object_Name OUT NOCOPY VARCHAR2
                                        ,x_Folder_Name OUT NOCOPY VARCHAR2);
   Procedure GetObjNameandFolderUsingDef(p_Obj_Def_ID IN NUMBER
                                        ,x_Object_Name OUT NOCOPY VARCHAR2
                                        ,x_Folder_Name OUT NOCOPY VARCHAR2);
   Function getVersionCount(X_Object_ID NUMBER) RETURN NUMBER;
   FUNCTION get_user_name(l_user_id IN NUMBER) RETURN VARCHAR2;
   Function migrationEnabledForUser RETURN VARCHAR2;
   Function getRuleSetObjectDefID(X_RULE_SET_OBJECT_ID IN NUMBER) RETURN NUMBER;
   Function getFolderPrivilege(X_Object_ID IN NUMBER) RETURN VARCHAR2;

   FUNCTION getLookupMeaning(p_Application_ID IN NUMBER
                          ,p_Lookup_Type IN VARCHAR2
                          ,p_Lookup_Code IN VARCHAR2
                          ) RETURN VARCHAR2;


end FEM_UTILS;

 

/
