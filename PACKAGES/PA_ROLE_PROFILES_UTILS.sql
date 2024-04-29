--------------------------------------------------------
--  DDL for Package PA_ROLE_PROFILES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_PROFILES_UTILS" AUTHID CURRENT_USER AS
-- $Header: PARPRPUS.pls 120.1 2005/08/19 16:59:31 mwasowic noship $

PROCEDURE Check_BusGroup_Name_Or_Id
( p_business_group_id       IN  NUMBER,
  p_business_group_name     IN  VARCHAR2,
  p_check_id_flag           IN  VARCHAR2 DEFAULT NULL,
  x_business_group_id       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code          OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Check_Position_Name_Or_Id
( p_position_id             IN  NUMBER,
  p_position_name           IN  VARCHAR2,
  p_check_id_flag           IN  VARCHAR2 DEFAULT NULL,
  x_position_id             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code          OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Check_Business_Level_Attrs
( p_business_group_id      IN  NUMBER,
  p_business_group_name    IN  VARCHAR2,
  p_organization_id        IN  NUMBER,
  p_organization_name      IN  VARCHAR2,
  p_job_id                 IN  NUMBER,
  p_job_name               IN  VARCHAR2,
  p_position_id            IN  NUMBER,
  p_position_name          IN  VARCHAR2,
  x_business_group_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_organization_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_job_id                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_position_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Validate_Profile_Lines
( p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_role_id_tbl            OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

END PA_ROLE_PROFILES_UTILS;
 

/
