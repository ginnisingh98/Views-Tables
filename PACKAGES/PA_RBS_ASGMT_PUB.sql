--------------------------------------------------------
--  DDL for Package PA_RBS_ASGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ASGMT_PUB" AUTHID CURRENT_USER AS
/* $Header: PARASGPS.pls 120.0 2005/05/30 18:40:59 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/**************************************************************
 * Procedure   : Create_RBS_Assignment
 * Description : The purpose of this procedure is to associate
 *               an RBS to a project for any of the 4 uasges:-
 *               Reporting, Financial Plan, Workplan and
 *               Program Reporting.
 *               Reporting is the Default Usage type for all the
 *               associations.
 ****************************************************************/
PROCEDURE Create_RBS_Assignment(
   p_commit               IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_init_msg_list        IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_rbs_header_id        IN    NUMBER,
   p_rbs_version_id       IN    NUMBER      DEFAULT NULL,
   p_project_id           IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT NULL,
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT NULL,
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT NULL,
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   x_return_status        OUT   NOCOPY      VARCHAR2  ,
   x_msg_count            OUT   NOCOPY      NUMBER    ,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2  );

PROCEDURE Update_RBS_Assignment(
   p_commit               IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_init_msg_list        IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_rbs_prj_assignment_id  IN    NUMBER,
   p_wp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_fp_usage_flag        IN    VARCHAR2    DEFAULT 'N',
   p_prog_rep_usage_flag  IN    VARCHAR2    DEFAULT 'N',
   p_primary_rep_flag     IN    VARCHAR2    DEFAULT 'N',
   p_record_version_number IN   Number,
   p_set_as_primary        IN   Varchar2    DEFAULT 'N',
   x_return_status        OUT   NOCOPY      VARCHAR2,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   );


PROCEDURE Delete_RBS_Assignment(
   p_commit               IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_init_msg_list        IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_rbs_prj_assignment_id  IN    NUMBER,
   x_return_status        OUT   NOCOPY      VARCHAR2,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   );


PROCEDURE Copy_rbs_assignments(
     p_source_project_id         IN   Number,
     p_destination_project_id    IN   Number,
     x_return_status             OUT NOCOPY  Varchar2);


END PA_RBS_ASGMT_PUB;

 

/
