--------------------------------------------------------
--  DDL for Package FEM_OBJECT_CATALOG_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_OBJECT_CATALOG_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_objcat_utl.pls 120.2 2005/07/26 13:59:38 appldev ship $ */
-- Declare package procedures
PROCEDURE create_object (x_object_id            OUT NOCOPY NUMBER,
                         x_object_definition_id OUT NOCOPY NUMBER,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         p_api_version          IN  NUMBER,
                         p_commit               IN  VARCHAR2,
                         p_object_type_code     IN  VARCHAR2,
                         p_folder_id            IN  NUMBER,
                         p_local_vs_combo_id    IN  NUMBER,
                         p_object_access_code   IN  VARCHAR2,
                         p_object_origin_code   IN  VARCHAR2,
                         p_object_name          IN  VARCHAR2,
                         p_description          IN  VARCHAR2,
                         p_effective_start_date IN  DATE DEFAULT sysdate,
                         p_effective_end_date   IN  DATE DEFAULT to_date('9999/01/01','YYYY/MM/DD'),
                         p_obj_def_name         IN  VARCHAR2);

PROCEDURE create_object_definition (x_object_definition_id OUT NOCOPY NUMBER,
                                    x_msg_count            OUT NOCOPY NUMBER,
                                    x_msg_data             OUT NOCOPY VARCHAR2,
                                    x_return_status        OUT NOCOPY VARCHAR2,
                                    p_api_version          IN  NUMBER,
                                    p_commit               IN  VARCHAR2,
                                    p_object_id            IN  NUMBER,
                                    p_effective_start_date IN  DATE,
                                    p_effective_end_date   IN  DATE,
                                    p_obj_def_name         IN  VARCHAR2,
                                    p_object_origin_code   IN VARCHAR2);

PROCEDURE validate_obj_def_effdate (x_date_range_is_valid  OUT NOCOPY VARCHAR2,
                                    x_msg_count            OUT NOCOPY NUMBER,
                                    x_msg_data             OUT NOCOPY VARCHAR2,
                                    p_object_id            IN  NUMBER,
                                    p_new_effective_start_date IN DATE,
                                    p_new_effective_end_date   IN DATE);

PROCEDURE delete_object (x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         p_api_version          IN  NUMBER,
                         p_commit               IN  VARCHAR2,
                         p_object_id            IN  NUMBER);


END fem_object_catalog_util_pkg;



 

/
