--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUC_MAPPING_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUC_MAPPING_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPSMPUS.pls 120.1 2005/08/19 16:46:29 mwasowic noship $ */

  FUNCTION Check_Task_Has_Mapping
  (
       p_project_id             IN      NUMBER
     , p_proj_element_id        IN      NUMBER
 ) RETURN VARCHAR2;

  PROCEDURE CHECK_CREATE_MAPPING_OK
  (
       p_api_version            IN      NUMBER := 1.0
     , p_calling_module         IN      VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN      VARCHAR2 := 'N'
     , p_task_version_id_WP     IN      NUMBER
     , p_task_version_id_FP     IN      NUMBER
     , x_return_status          OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
     , x_error_message_code     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

TYPE  TASK_NAME_TABLE_TYPE IS TABLE OF PA_PROJ_ELEMENTS.NAME%TYPE INDEX BY BINARY_INTEGER;

FUNCTION PARSE_NAMES
   (
      p_wPlan                 IN   VARCHAR2
    , p_delim                 IN   VARCHAR2
   ) RETURN  PA_PROJ_STRUC_MAPPING_UTILS.TASK_NAME_TABLE_TYPE;

FUNCTION GET_TASK_NAME_FROM_VERSION
   ( p_task_version_id    IN   NUMBER
   ) RETURN  VARCHAR2;

FUNCTION GET_MAPPED_FIN_TASK_VERSION_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER;

FUNCTION GET_MAPPED_FIN_TASK_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER;

FUNCTION GET_MAPPED_FIN_TASK_NAME
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_MAPPED_STRUCT_VER_ID
   (p_element_version_id IN NUMBER
   ,p_structure_sharing_code IN VARCHAR2) RETURN NUMBER;

FUNCTION GET_MAPPED_FIN_TASK_NAME_AMG
   (
     p_mapped_wkp_task_version_id IN NUMBER
    ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2;

FUNCTION GET_MAPPED_FIN_TASK_ID_AMG
   (
     p_mapped_wkp_task_version_id IN NUMBER
    ,p_project_id  IN NUMBER
   ) RETURN NUMBER;
FUNCTION GET_MAPPED_WKP_TASK_IDS
   (
     p_mapped_fin_task_version_id IN NUMBER
    ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2;
FUNCTION GET_MAPPED_WKP_TASK_NAMES
   (
     p_mapped_fin_task_version_id IN NUMBER
    ,p_project_id  IN NUMBER
   ) RETURN VARCHAR2;


END PA_PROJ_STRUC_MAPPING_UTILS;


 

/
