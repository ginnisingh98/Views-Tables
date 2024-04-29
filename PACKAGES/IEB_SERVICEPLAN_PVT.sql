--------------------------------------------------------
--  DDL for Package IEB_SERVICEPLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEB_SERVICEPLAN_PVT" AUTHID CURRENT_USER AS
/* $Header: IEBSVPS.pls 115.4 2003/11/07 17:29:31 gpagadal noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEB_ServicePlan_PVT
-- Purpose
--    To provide easy to use apis for Blending admin.
-- History
--    02-July-2003     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Create_ServicePlan(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id OUT NOCOPY NUMBER,
                       p_name IN VARCHAR2,
                       p_desc IN VARCHAR2,
                       p_direction IN VARCHAR2,
                       p_media_type_id IN NUMBER
                       );
PROCEDURE Create_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEB_SERVICE_COVERAGES_OBJ
                                );
PROCEDURE Update_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                rec_obj IN SYSTEM.IEB_SERVICE_COVERAGES_OBJ
                                );

PROCEDURE Delete_IOCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_direction IN VARCHAR2,
                                p_plan_id IN VARCHAR2
                                );

PROCEDURE Create_RegionalPlan(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id OUT NOCOPY NUMBER,
                       p_base_plan_id in NUMBER,
                       p_name IN VARCHAR2,
                       p_desc IN VARCHAR2,
                       p_direction IN VARCHAR2,
                       p_media_type_id IN NUMBER
                       );
PROCEDURE Create_GroupPlanMap(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_plan_id in  NUMBER,
                       p_server_group_id IN NUMBER
                       );

PROCEDURE Create_Classification(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_cat_id in  NUMBER,
                       p_classfn_name in VARCHAR2
                       );
PROCEDURE Delete_Classification(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_media_type_id in NUMBER
                       );
PROCEDURE Delete_Category(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_media_type_id in NUMBER
                       );

PROCEDURE Delete_Service_Plan (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,x_service_plan_id IN NUMBER);
PROCEDURE Create_CampCategory(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_svc_plan_id in  NUMBER,
                       p_name in VARCHAR2,
                       p_media_type_id in NUMBER
                        );


PROCEDURE Create_ClassfnCategory(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_cat_id OUT NOCOPY NUMBER,
                       p_svc_plan_id in  NUMBER,
                       p_name in VARCHAR2,
                       p_media_type_id in NUMBER,
                       p_server_id IN NUMBER
                        );


PROCEDURE Update_Category (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_base_plan_id in  NUMBER,
                                p_media_type_id in NUMBER,
                                p_reg_plan_id in  NUMBER
                                );


PROCEDURE Delete_Regional_Plan (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_base_plan_id IN NUMBER,
                       p_reg_plan_id IN NUMBER );

PROCEDURE Delete_SpecDateCoverages (   x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data OUT NOCOPY VARCHAR2,
                                p_direction IN VARCHAR2,
                                p_plan_id IN VARCHAR2,
                                p_spec_date IN VARCHAR2
                                );


PROCEDURE Delete_Regional_PlanMaps (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_reg_plan_id IN NUMBER,
                       p_base_plan_id IN NUMBER,
                       p_media_type_id IN NUMBER);

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Create_ServiceLevel
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_MACT_OBJ    Required
--  is_create   IN   VARCHAR2   Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Create_ServiceLevel (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       rec_obj IN SYSTEM.IEB_SERVICE_LEVELS_OBJ
                       );



PROCEDURE Update_ServiceLevel (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       rec_obj IN SYSTEM.IEB_SERVICE_LEVELS_OBJ
                       );


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Delete_Service_Level
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_service_level_id     IN   NUMBER    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE Delete_Service_Level (   x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2, x_service_level_id IN NUMBER);




END IEB_ServicePlan_PVT;


 

/
