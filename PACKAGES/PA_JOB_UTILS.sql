--------------------------------------------------------
--  DDL for Package PA_JOB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_JOB_UTILS" AUTHID CURRENT_USER AS
-- $Header: PAJBUTLS.pls 120.3 2007/11/19 15:43:49 rthumma ship $

--
--  PROCEDURE
--              Check_JobName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Job name is passed converts it to the id
--		If Job Id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      P.Bandla		       Created
--
 PROCEDURE Check_JobName_Or_Id (
			 p_job_id		IN	NUMBER,
			 p_job_name		IN	VARCHAR2,
			 p_check_id_flag	IN	VARCHAR2,
			 p_job_group_id         IN      NUMBER := NULL, -- 5130421
			 x_job_id		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_error_message_code	OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              Check_JobLevel
--  PURPOSE
--              This procedure validates the job level.
--  HISTORY
--   04-AUG-2000      P.Bandla	 Created
--
 PROCEDURE Check_JobLevel (
			 p_level		IN	NUMBER,
			 x_valid		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			 x_error_message_code	OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              Check_Job_GroupName_Or_Id
--  PURPOSE
--              This procedure validates the job group.
--  HISTORY
--   21-NOV-2000      P.Bandla	 Created
--
 PROCEDURE Check_Job_GroupName_Or_Id(
			p_job_group_id		IN	NUMBER,
			p_job_group_name	IN	VARCHAR2,
			p_check_id_flag		IN	VARCHAR2,
			x_job_group_id		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
			x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_error_message_code	OUT	NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure
-- created by Ranga Iyengar  : 05-DEC-2000
-- This Api validates the given job_id and job_group_id is a part of
-- the pa_job_relationships entity.the IN parameters will be job_id and
-- job_group_id
--
PROCEDURE validate_job_relationship
            ( p_job_id             IN  per_jobs.job_id%type
             ,p_job_group_id       IN  per_jobs.job_group_id%type
             ,x_return_status      OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY varchar2 --File.Sql.39 bug 4440895
            );


-- This Function returns the job level(sequence) based on the job_id
-- and Job_group_id
FUNCTION get_job_level(P_job_id         IN   per_jobs.job_id%type
                      ,P_job_group_id   IN  per_job_groups.job_group_id%type)
RETURN NUMBER;

-- This function returns the Job Level of the job passed in
-- by looking at the 'Project Job Level' DFF segmeent of the
-- 'Job Category' DFF.
--------------------------------------------------------------------------------

FUNCTION get_job_level(p_job_id IN NUMBER)
RETURN NUMBER;


-- This Function returns boolean value of true if a job is master job otherwise
-- it returns false -- IN parameter will be job_id
FUNCTION check_master_job(P_job_id  IN per_Jobs.job_id%type)
RETURN  boolean;


-- This API returns the job group id for the corresponding Job
FUNCTION get_job_group_id(P_job_id  IN   per_jobs.job_id%type)
RETURN per_job_groups.job_group_id%type;


-- This function checks if a Project Resource Job Group Exists
-- in the system. Returns 'Y' if it does and returns 'N' if it does not
FUNCTION Proj_Res_Job_Group_Exists(p_job_id IN NUMBER)
RETURN VARCHAR2;


-- This function checks if a job group passed in is a
-- Project Resource Job Group.
-- Returns 'Y' if it is and returns 'N' if it is not
Function Is_Proj_Res_Job_Group(p_job_id       IN NUMBER,
                               p_job_group_id IN NUMBER)
RETURN VARCHAR2;


-- This function returns the project resource job group in the system
Function Get_Proj_Res_Job_Group(p_job_id IN NUMBER)
RETURN NUMBER;


FUNCTION get_job_name (P_job_id       IN  per_jobs.job_id%type,
                       P_job_group_id IN  per_job_groups.job_group_id%type)
RETURN VARCHAR2;


-- This function returns the job in the Project Resource Job
-- Group towhich p_job_id is mapped. Returns the job_id of
-- the job in PRJG
Function Get_Job_Mapping(p_job_id       IN NUMBER,
                         p_job_group_id IN NUMBER)
RETURN NUMBER;

/* Added for bug 6405426 */
PROCEDURE check_job_relationships (p_job_id IN number);

END pa_job_utils;

/
