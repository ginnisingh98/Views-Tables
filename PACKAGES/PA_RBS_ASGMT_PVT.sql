--------------------------------------------------------
--  DDL for Package PA_RBS_ASGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_ASGMT_PVT" AUTHID CURRENT_USER AS
/* $Header: PARASGVS.pls 120.0 2005/05/29 21:19:01 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

 /**********************************************************
 * Function : Check_Primary_rep_flag
 * Parameter: p_project_id,p_rbs_header_id
 * Return   : Varchar2
 * Desc     : The purpose of this Function is to determine if
 *            The Value of the Primary reporting RBS flag can be set to
 *            'Y' or not. It checks to see if any other RBS asso.
 *            to the project have the flag set to 'Y' already.
 *            If yes then we shouldn't allow the user to create/Update
 *            the value for the flag to 'Y'.
 *******************************************************************/
 FUNCTION Check_Primary_rep_flag
          (p_project_id  IN NUMBER,
           p_rbs_header_id IN NUMBER)
  RETURN VARCHAR2;

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
   p_rbs_prj_assignment_id  IN    NUMBER,
   x_return_status        OUT   NOCOPY      VARCHAR2,
   x_msg_count            OUT   NOCOPY      NUMBER,
   x_error_msg_data       OUT   NOCOPY      VARCHAR2   );

PROCEDURE Associate_Rbs_To_Program(
   p_rbs_header_id        IN    NUMBER,
   p_rbs_version_id       IN    NUMBER      DEFAULT NULL,
   p_project_id_tbl       IN    SYSTEM.PA_NUM_TBL_TYPE,
   x_return_status        OUT   NOCOPY   VARCHAR2);

PROCEDURE Assign_New_Version(
   p_rbs_new_version_id     IN  Number,
   p_project_id_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE,
   x_return_status          OUT NOCOPY Varchar2);

PROCEDURE Copy_Project_Assignment(
   p_rbs_src_project_id    IN         NUMBER,
   p_rbs_dest_project_id   IN         NUMBER,
   x_return_status         OUT NOCOPY Varchar2);


END PA_RBS_ASGMT_PVT;

 

/
