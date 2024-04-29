--------------------------------------------------------
--  DDL for Package AMW_OBJECT_ASSESSMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_OBJECT_ASSESSMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amwobasss.pls 120.0 2005/06/15 18:02:16 appldev noship $ */

FUNCTION check_object_assess_exists
(
    p_assessment_id	IN	   NUMBER,
    p_object_type       IN         VARCHAR2
)
RETURN VARCHAR2;

PROCEDURE create_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id	IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id		IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
);

PROCEDURE update_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id	IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id		IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
);

PROCEDURE remove_object_assessment
(
 p_api_version_number   IN NUMBER   := 1.0,
 p_init_msg_list        IN VARCHAR2 := FND_API.g_false,
 p_commit               IN VARCHAR2 := FND_API.g_false,
 p_validation_level     IN NUMBER   := fnd_api.g_valid_level_full,
 p_object_type          IN VARCHAR2,
 p_assessment_id	IN NUMBER,
 p_certification_id	IN NUMBER,
 p_org_id	        IN NUMBER,
 p_process_id		IN NUMBER,
 x_return_status        OUT nocopy VARCHAR2,
 x_msg_count            OUT nocopy NUMBER,
 x_msg_data             OUT nocopy VARCHAR2
);

END AMW_OBJECT_ASSESSMENTS_PVT;



 

/
