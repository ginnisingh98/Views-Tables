--------------------------------------------------------
--  DDL for Package Body PA_ROLE_JOB_BG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_JOB_BG_UTILS" AS
-- $Header: PAXRJBUB.pls 115.3 2003/08/25 19:01:25 ramurthy ship $

--
--  PROCEDURE
--              check_dup_job_bg_defaults
--  PURPOSE
--              This procedure checks to see that the same Business Group
--              has not already had job defaults specified for a given role.
--  HISTORY
--     17-Jul-2003      Ranjana Murthy    - Created
--
-- PROCEDURE check_dup_job_bg_defaults
-- This procedure checks if the role already has job defaults for the given
-- business group - a role can only have one set of job defaults
-- for a business group.
-- It will be called from the private api before inserting
-- a new record into the role job defaults table or before updating
-- an existing record

PROCEDURE check_dup_job_bg_defaults(
                        p_role_job_bg_id       IN  NUMBER
                       ,p_project_role_id      IN  NUMBER
                       ,p_business_group_id    IN  NUMBER
                       ,p_return_status        OUT NOCOPY VARCHAR2
                       ,p_error_message_code   OUT NOCOPY VARCHAR2) IS

cursor c_exists is
select 'Y'
from   pa_role_job_bgs
where  project_role_id = p_project_role_id
and    nvl(business_group_id, -99) = nvl(p_business_group_id, -99)
and    role_job_bg_id <> nvl(p_role_job_bg_id, -99);

l_dummy VARCHAR2(1) ;

BEGIN
-- hr_utility.trace_on(NULL, 'RMDUP');
    --hr_utility.trace('start');
    --hr_utility.trace('P_ROLE_JOB_BG_ID IS : ' || P_ROLE_JOB_BG_ID);
    --hr_utility.trace('P_PROJECT_ROLE_ID IS : ' || P_PROJECT_ROLE_ID);
    --hr_utility.trace('P_BUSINESS_GROUP_ID IS : ' || P_BUSINESS_GROUP_ID);

OPEN c_exists;
FETCH c_exists into l_dummy;
IF c_exists%NOTFOUND THEN
    p_return_status := fnd_api.g_ret_sts_success;
ELSE
  p_return_status := fnd_api.g_ret_sts_error;
  p_error_message_code := 'PA_DUP_ROLE_JOB_BG';
END IF;
 CLOSE c_exists;
EXCEPTION
   WHEN OTHERS THEN
     CLOSE c_exists;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_message_code := SQLCODE;
END check_dup_job_bg_defaults;

-- These functions are called from the view PA_PROJECT_ROLE_TYPES_VL
-- to get the job defaults based on the profile values for CBGA and
-- HR BG ID.

FUNCTION get_job_id(p_project_role_id IN  NUMBER) return NUMBER IS

l_job_id          NUMBER;
l_bg_id           NUMBER;

BEGIN

-- Using HR Profile BG ID for now - not sure where all this
-- is used; this may need to change to go off of implementation options.

IF PA_CROSS_BUSINESS_GRP.IsCrossBGProfile = 'N' THEN
   l_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
ELSE
   l_bg_id := -1;
END IF;

BEGIN

   SELECT job_id
   into   l_job_id
   FROM   pa_role_job_bgs
   WHERE  project_role_id = p_project_role_id
   AND    nvl(business_group_id, -1) = l_bg_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_job_id := NULL;
END;

RETURN l_job_id;

END get_job_id;

--
FUNCTION get_min_job_level(p_project_role_id IN  NUMBER) return NUMBER IS

l_min_job_level   NUMBER;
l_bg_id           NUMBER;

BEGIN

-- Using HR Profile BG ID for now - not sure where all this
-- is used; this may need to change to go off of implementation options.

IF PA_CROSS_BUSINESS_GRP.IsCrossBGProfile = 'N' THEN
   l_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
ELSE
   l_bg_id := -1;
END IF;

BEGIN

   SELECT min_job_level
   into   l_min_job_level
   FROM   pa_role_job_bgs
   WHERE  project_role_id = p_project_role_id
   AND    nvl(business_group_id, -1) = l_bg_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_min_job_level := NULL;
END;

RETURN l_min_job_level;

END get_min_job_level;

--
FUNCTION get_max_job_level(p_project_role_id IN  NUMBER) return NUMBER IS

l_max_job_level   NUMBER;
l_bg_id           NUMBER;

BEGIN

-- Using HR Profile BG ID for now - not sure where all this
-- is used; this may need to change to go off of implementation options.

IF PA_CROSS_BUSINESS_GRP.IsCrossBGProfile = 'N' THEN
   l_bg_id := fnd_profile.value('PER_BUSINESS_GROUP_ID');
ELSE
   l_bg_id := -1;
END IF;

BEGIN

   SELECT max_job_level
   into   l_max_job_level
   FROM   pa_role_job_bgs
   WHERE  project_role_id = p_project_role_id
   AND    nvl(business_group_id, -1) = l_bg_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_max_job_level := NULL;
END;

RETURN l_max_job_level;

END get_max_job_level;


end pa_role_job_bg_utils ;

/
