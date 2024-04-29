--------------------------------------------------------
--  DDL for Package HZ_BUS_OBJ_DEFINITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_BUS_OBJ_DEFINITIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHBODTS.pls 120.2 2006/04/22 00:47:38 smattegu noship $ */


PROCEDURE Insert_Row (
    x_business_object_code                  IN OUT NOCOPY VARCHAR2,
    x_child_bo_code                         IN OUT NOCOPY VARCHAR2,
    x_tca_mandated_flag                     IN     VARCHAR2,
    x_user_mandated_flag                    IN     VARCHAR2,
    x_root_node_flag                        IN     VARCHAR2,
    x_entity_name                           IN OUT NOCOPY VARCHAR2,
    x_bo_indicator_flag                     IN     VARCHAR2,
    x_display_flag                          IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
    x_bo_version_number                     IN     NUMBER,
    x_creation_date			        IN     DATE,
    x_created_by			              IN     NUMBER,
    x_last_update_date			        IN     DATE,
    x_last_updated_by			        IN     NUMBER,
    x_last_update_login			        IN     NUMBER,
    x_object_version_number                 IN     NUMBER
) ;

PROCEDURE Update_Row (
    x_business_object_code                  IN     VARCHAR2,
    x_child_bo_code                         IN     VARCHAR2,
    x_tca_mandated_flag                     IN     VARCHAR2,
    x_user_mandated_flag                    IN     VARCHAR2,
    x_root_node_flag                        IN     VARCHAR2,
    x_entity_name                           IN     VARCHAR2,
    x_bo_indicator_flag                     IN     VARCHAR2,
    x_display_flag                          IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
    x_bo_version_number                     IN     NUMBER,
    x_last_update_date			        IN     DATE,
    x_last_updated_by			   	  IN     NUMBER,
    x_last_update_login			    	  IN     NUMBER,
    x_object_version_number                 IN     NUMBER );

PROCEDURE LOAD_ROW (
    x_business_object_code                  IN OUT NOCOPY     VARCHAR2,
    x_child_bo_code                         IN OUT NOCOPY    VARCHAR2,
    x_entity_name                           IN OUT NOCOPY     VARCHAR2,
    x_tca_mandated_flag                     IN     VARCHAR2,
    x_user_mandated_flag                    IN     VARCHAR2,
    x_root_node_flag                        IN     VARCHAR2,
    x_bo_indicator_flag                     IN     VARCHAR2,
    x_display_flag                          IN     VARCHAR2,
    x_multiple_flag                         IN     VARCHAR2,
    x_bo_version_number                     IN     NUMBER,
    x_object_version_number                 IN     NUMBER,
    x_last_update_date                      IN     VARCHAR2,
    X_CUSTOM_MODE              IN     VARCHAR2,
    x_owner				    IN     VARCHAR2 );


PROCEDURE Select_Row (
    x_business_object_code                  IN OUT NOCOPY VARCHAR2,
    x_child_bo_code                         IN OUT NOCOPY VARCHAR2,
    x_tca_mandated_flag                     OUT    NOCOPY VARCHAR2,
    x_user_mandated_flag                    OUT    NOCOPY VARCHAR2,
    x_root_node_flag                        OUT    NOCOPY VARCHAR2,
    x_entity_name                           IN OUT NOCOPY VARCHAR2,
    x_bo_indicator_flag                     OUT    NOCOPY VARCHAR2,
    x_display_flag                          OUT    NOCOPY VARCHAR2,
    x_bo_version_number                     OUT    NOCOPY NUMBER,
    x_object_version_number                 OUT    NOCOPY NUMBER );

PROCEDURE Delete_Row (
    x_business_object_code                  IN     VARCHAR2,
    x_child_bo_code                         IN     VARCHAR2,
    x_entity_name                           IN     VARCHAR2

);
END HZ_BUS_OBJ_DEFINITIONS_PKG;

 

/
