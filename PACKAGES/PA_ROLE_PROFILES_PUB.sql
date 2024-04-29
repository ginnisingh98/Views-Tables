--------------------------------------------------------
--  DDL for Package PA_ROLE_PROFILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_PROFILES_PUB" AUTHID CURRENT_USER AS
-- $Header: PARPRPPS.pls 120.1 2005/08/19 16:59:22 mwasowic noship $

PROCEDURE Add_Default_Profile
( p_business_group_id      IN  NUMBER DEFAULT NULL,
  p_business_group_name    IN  VARCHAR2 DEFAULT NULL,
  p_organization_id        IN  NUMBER DEFAULT NULL,
  p_organization_name      IN  VARCHAR2 DEFAULT NULL,
  p_job_id                 IN  NUMBER DEFAULT NULL,
  p_job_name               IN  VARCHAR2 DEFAULT NULL,
  p_position_id            IN  NUMBER DEFAULT NULL,
  p_position_name          IN  VARCHAR2 DEFAULT NULL,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE DEFAULT NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Update_Default_Profile
( p_profile_id             IN  NUMBER,
  p_business_group_id      IN  NUMBER DEFAULT NULL,
  p_business_group_name    IN  VARCHAR2 DEFAULT NULL,
  p_organization_id        IN  NUMBER DEFAULT NULL,
  p_organization_name      IN  VARCHAR2 DEFAULT NULL,
  p_job_id                 IN  NUMBER DEFAULT NULL,
  p_job_name               IN  VARCHAR2 DEFAULT NULL,
  p_position_id            IN  NUMBER DEFAULT NULL,
  p_position_name          IN  VARCHAR2 DEFAULT NULL,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE DEFAULT NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Delete_Profile
( p_profile_id             IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Create_Profile_for_Resource
( p_resource_id            IN  NUMBER,
  p_resource_start_date    IN  DATE,
  p_resource_end_date      IN  DATE,
  p_business_group_id      IN  NUMBER,
  p_organization_id        IN  NUMBER,
  p_job_id                 IN  NUMBER,
  p_position_id            IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

END PA_ROLE_PROFILES_PUB;
 

/
