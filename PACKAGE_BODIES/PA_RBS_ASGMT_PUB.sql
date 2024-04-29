--------------------------------------------------------
--  DDL for Package Body PA_RBS_ASGMT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ASGMT_PUB" AS
/* $Header: PARASGPB.pls 120.0 2005/06/03 17:53:25 appldev noship $*/

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
 *               This Procedure would Call the PA_RBS_ASGMT_Pvt pkg.
 ****************************************************************/
PROCEDURE Create_RBS_Assignment
(  p_commit                IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
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
   x_error_msg_data       OUT   NOCOPY      VARCHAR2)
IS
BEGIN
   /****************************************
    * First Initialize the message list.
    ****************************************/
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   --Call to the Pvt Pkg Pa_Rbs_Asgmt_Pvt.Create_RBS_Assignment
 Pa_Rbs_Asgmt_Pvt.Create_RBS_Assignment(
   p_rbs_header_id        => p_rbs_header_id,
   p_rbs_version_id       => p_rbs_version_id      ,
   p_project_id           => p_project_id,
   p_wp_usage_flag        => p_wp_usage_flag   ,
   p_fp_usage_flag        => p_fp_usage_flag   ,
   p_prog_rep_usage_flag  => p_prog_rep_usage_flag   ,
   p_primary_rep_flag     => p_primary_rep_flag   ,
   x_return_status        => x_return_status    ,
   x_msg_count            => x_msg_count    ,
   x_error_msg_data       => x_error_msg_data    );



/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;

END Create_RBS_Assignment;
/***************************/

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
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   )
IS

BEGIN
  /****************************************
   * First Initialize the message list.
   ****************************************/
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   --Call to the Pvt Pkg Pa_Rbs_Asgmt_Pvt.Update_RBS_Assignment
   Pa_Rbs_Asgmt_Pvt.Update_RBS_Assignment(
     p_rbs_prj_assignment_id  => p_rbs_prj_assignment_id ,
     p_wp_usage_flag          => p_wp_usage_flag ,
     p_fp_usage_flag          => p_fp_usage_flag,
     p_prog_rep_usage_flag    => p_prog_rep_usage_flag,
     p_primary_rep_flag       => p_primary_rep_flag,
     p_record_version_number  => p_record_version_number,
     p_set_as_primary         => p_set_as_primary,
     x_return_status          => x_return_status,
     x_msg_count              => x_msg_count,
     x_error_msg_data         => x_error_msg_data   );


   /************************************************
   * Check the Commit flag. if it is true then Commit.
   ***********************************************/
    IF FND_API.to_boolean( p_commit )
    THEN
           COMMIT;
    END IF;


END Update_RBS_Assignment;


PROCEDURE Delete_RBS_Assignment(
   p_commit               IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_init_msg_list        IN    VARCHAR2    DEFAULT FND_API.G_FALSE,
   p_rbs_prj_assignment_id  IN    NUMBER,
   x_return_status        OUT   NOCOPY      VARCHAR2,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   )
IS

BEGIN

  /****************************************
   * First Initialize the message list.
   ****************************************/
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   --Call to the Pvt Pkg Pa_Rbs_Asgmt_Pvt.Delete_RBS_Assignment
   Pa_Rbs_Asgmt_Pvt.Delete_RBS_Assignment(
   p_rbs_prj_assignment_id  => p_rbs_prj_assignment_id,
   x_return_status          => x_return_status,
   x_msg_count              => x_msg_count,
   x_error_msg_data         => x_error_msg_data   );


   /************************************************
   * Check the Commit flag. if it is true then Commit.
   ***********************************************/
    IF FND_API.to_boolean( p_commit )
    THEN
           COMMIT;
    END IF;

END Delete_RBS_Assignment;

PROCEDURE Copy_rbs_assignments(
     p_source_project_id         IN   Number,
     p_destination_project_id    IN   Number,
     x_return_status             OUT NOCOPY  Varchar2)
IS

BEGIN
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;

     INSERT INTO pa_rbs_prj_assignments
        (RBS_PRJ_ASSIGNMENT_ID,
         PROJECT_ID,
         RBS_VERSION_ID,
         RBS_HEADER_ID,
         REPORTING_USAGE_FLAG,
         WP_USAGE_FLAG,
         FP_USAGE_FLAG,
         PROG_REP_USAGE_FLAG,
         PRIMARY_REPORTING_RBS_FLAG,
         ASSIGNMENT_STATUS,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         RECORD_VERSION_NUMBER)
     SELECT
          PA_RBS_PRJ_ASSIGNMENTS_S.NEXTVAL,
         p_destination_project_id,
         a.RBS_VERSION_ID,
         a.RBS_HEADER_ID,
         a.REPORTING_USAGE_FLAG,
         a.WP_USAGE_FLAG,
         a.FP_USAGE_FLAG,
         a.PROG_REP_USAGE_FLAG,
         a.PRIMARY_REPORTING_RBS_FLAG,
         a.ASSIGNMENT_STATUS,
         sysdate,
         a.LAST_UPDATED_BY,
         sysdate,
         a.CREATED_BY,
         a.LAST_UPDATE_LOGIN,
         1
     FROM pa_rbs_prj_assignments a
     WHERE a.project_id = p_source_project_id
     AND   a.assignment_status = 'ACTIVE'
     AND   NOT EXISTS
          (select rbs_prj_assignment_id
           from pa_rbs_prj_assignments b
           where a.rbs_header_id = b.rbs_header_id
           and   a.rbs_version_id = b.rbs_version_id
           and b.project_id = p_destination_project_id);
EXCEPTION
WHEN OTHERS THEN
        x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
END Copy_rbs_assignments;


END PA_RBS_ASGMT_PUB;

/
