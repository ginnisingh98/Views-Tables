--------------------------------------------------------
--  DDL for Package PA_ROLE_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_PROFILES_PKG" AUTHID CURRENT_USER AS
-- $Header: PARPRPKS.pls 120.1 2005/08/19 16:59:14 mwasowic noship $

PROCEDURE Insert_Row1
( p_profile_name            IN  VARCHAR,
  p_description             IN  VARCHAR2,
  p_effective_start_date    IN  DATE,
  p_effective_end_date      IN  DATE DEFAULT NULL,
  p_profile_type_code       IN  VARCHAR2 DEFAULT NULL,
  p_approval_status_code    IN  VARCHAR2 DEFAULT NULL,
  p_business_group_id       IN  NUMBER DEFAULT NULL,
  p_organization_id         IN  NUMBER DEFAULT NULL,
  p_job_id                  IN  NUMBER DEFAULT NULL,
  p_position_id             IN  NUMBER DEFAULT NULL,
  p_resource_id             IN  NUMBER DEFAULT NULL,
  x_profile_id              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Insert_Row2
( p_profile_id              IN  NUMBER,
  p_project_role_id         IN  NUMBER,
  p_role_weighting          IN  NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2);   --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_profile_id              IN  NUMBER,
  p_profile_name            IN  VARCHAR,
  p_description             IN  VARCHAR2,
  p_effective_start_date    IN  DATE,
  p_effective_end_date      IN  DATE DEFAULT NULL,
  --p_profile_type_code       IN  VARCHAR2 DEFAULT NULL,
  p_approval_status_code    IN  VARCHAR2 DEFAULT NULL,
  p_business_group_id       IN  NUMBER DEFAULT NULL,
  p_organization_id         IN  NUMBER DEFAULT NULL,
  p_job_id                  IN  NUMBER DEFAULT NULL,
  p_position_id             IN  NUMBER DEFAULT NULL,
  p_resource_id             IN  NUMBER DEFAULT NULL,
  x_return_status           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Angie added code for saving purpose but need to verify/change/test later

PROCEDURE Validate_Profile_Lines
( p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_role_id_tbl            OUT SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT VARCHAR2);
--  x_msg_count              OUT NUMBER,
--  x_msg_data               OUT VARCHAR2) ;


PROCEDURE Add_Res_Profiles
( p_resource_id            IN  NUMBER,
  p_profile_name           IN  VARCHAR2,
  p_profile_type_code      IN  VARCHAR2,
  p_description            IN  VARCHAR2         := NULL,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE             := NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_commit                 IN  VARCHAR2         := FND_API.G_FALSE,
  x_return_status          OUT VARCHAR2,
  x_msg_count              OUT NUMBER,
  x_msg_data               OUT VARCHAR2) ;

PROCEDURE Update_Res_Profiles
( p_profile_id             IN  NUMBER,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2         := NULL,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE             := NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_commit                 IN  VARCHAR2         := FND_API.G_FALSE,
  x_return_status          OUT VARCHAR2,
  x_msg_count              OUT NUMBER,
  x_msg_data               OUT VARCHAR2) ;
*/

END PA_ROLE_PROFILES_PKG;
 

/
