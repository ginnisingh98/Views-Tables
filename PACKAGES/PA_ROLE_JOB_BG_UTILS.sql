--------------------------------------------------------
--  DDL for Package PA_ROLE_JOB_BG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_JOB_BG_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXRJBUS.pls 115.1 2003/08/25 19:01:36 ramurthy ship $

--
--  PROCEDURE
--              check_dup_job_bg_defaults
--  PURPOSE
--              This procedure checks to see that the same Business Group
--              has not already had job defaults specified for a given role.
--  HISTORY
--     17-Jul-2003      Ranjana Murthy    - Created
--
PROCEDURE check_dup_job_bg_defaults(
			p_role_job_bg_id       IN  NUMBER
                       ,p_project_role_id      IN  NUMBER
                       ,p_business_group_id    IN  NUMBER
                       ,p_return_status        OUT NOCOPY VARCHAR2
                       ,p_error_message_code   OUT NOCOPY VARCHAR2);

-- These functions are called from the view PA_PROJECT_ROLE_TYPES_VL
-- to get the job defaults based on the profile values for CBGA and
-- HR BG ID.

FUNCTION get_job_id(p_project_role_id             IN  NUMBER) return NUMBER;
FUNCTION get_min_job_level(p_project_role_id      IN  NUMBER) return NUMBER;
FUNCTION get_max_job_level(p_project_role_id      IN  NUMBER) return NUMBER;

end pa_role_job_bg_utils;

 

/
