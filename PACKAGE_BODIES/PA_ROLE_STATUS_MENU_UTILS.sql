--------------------------------------------------------
--  DDL for Package Body PA_ROLE_STATUS_MENU_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_STATUS_MENU_UTILS" AS
-- $Header: PAXRSMUB.pls 115.6 2003/08/21 07:14:28 nmishra ship $

--
--  PROCEDURE
--              check_dup_role_status
--  PURPOSE
--              This procedure checks to see that the same status
--              has not already been mapped to a menu for a given role.
--  HISTORY
--     22-May-2003      Ranjana Murthy    - Created
--
-- PROCEDURE check_dup_role_status
-- This procedure checks if the role already has a status mapping
-- for the specified status - a role can only have one mapping per status
-- It will be called from the private api before inserting
-- a new record into the role status menu table or before updating
-- an existing record

PROCEDURE check_dup_role_status(p_role_status_menu_id in number
                               ,p_role_id             in number
                               ,p_status_code         in varchar2
                               ,p_return_status       out NOCOPY varchar2
                               ,p_error_message_code  out NOCOPY varchar2) IS
cursor c_exists is
select 'Y'
from   pa_role_status_menu_map
where  role_id = p_role_id
and    status_code = p_status_code
and    status_type = 'PROJECT'
and    role_status_menu_id <> nvl(p_role_status_menu_id, -99);

l_dummy VARCHAR2(1) ;

BEGIN
OPEN c_exists;
FETCH c_exists into l_dummy;
IF c_exists%NOTFOUND THEN
    p_return_status := fnd_api.g_ret_sts_success;
ELSE
  p_return_status := fnd_api.g_ret_sts_error;
  p_error_message_code := 'PA_DUP_ROLE_STATUS_MAPPING';
END IF;
 CLOSE c_exists;
EXCEPTION
   WHEN OTHERS THEN
     CLOSE c_exists;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_message_code := SQLCODE;
END check_dup_role_status;

--
--  PROCEDURE
--              check_status_is_in_use
--  PURPOSE
--              This procedure checks to see that the given status
--              exists in pa_role_status_menu_map - if it does, it
--              cannot be deleted from the Project Status form.
--              Called from the PA_PROJECT_STUS_UTILS.Allow_Status_Deletion
--              procedure.
--  HISTORY
--     20-June-2003      Ranjana Murthy    - Created
--
PROCEDURE check_status_is_in_use(p_status_code        IN  VARCHAR2
                                ,p_in_use_flag        OUT NOCOPY VARCHAR2
                                ,p_return_status      OUT NOCOPY VARCHAR2
                                ,p_error_message_code OUT NOCOPY VARCHAR2) IS
cursor c_exists is
select 'Y'
from   pa_role_status_menu_map
where  status_code = p_status_code
and    status_type = 'PROJECT';

BEGIN

p_in_use_flag := 'N';

OPEN c_exists;
FETCH c_exists into p_in_use_flag;
IF c_exists%NOTFOUND THEN
    p_return_status := fnd_api.g_ret_sts_success;
ELSE
  p_return_status := fnd_api.g_ret_sts_error;
  p_error_message_code := 'PA_ROLE_STATUS_MAPPING_EXISTS';
END IF;
 CLOSE c_exists;
EXCEPTION
   WHEN OTHERS THEN
     CLOSE c_exists;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_error_message_code := SQLCODE;
END check_status_is_in_use;
--
--  PROCEDURE
--              get_role_status_menus
--  PURPOSE
--              This procedure checks is used by the pa_security API
--              to get all the status menu mappings for a given role.
--
--  HISTORY
--     22-May-2003      Ranjana Murthy    - Created
--
-- PROCEDURE get_role_status_menus
-- This API will return:
--   1. Status Level and Default Menu Id from PA_PROJECT_ROLE_TYPES_B for
--      the given role_id.
--   2. Tables of Status Codes, Status Type, and corresponding Menu Names
--      from PA_ROLE_STATUS_MENU_MAP for the given role_id.

PROCEDURE get_role_status_menus(
               p_role_id            IN  NUMBER
              ,x_role_status_menu_id_tbl  OUT NOCOPY SYSTEM.pa_num_tbl_type
              ,x_status_level       OUT NOCOPY VARCHAR2
              ,x_default_menu_name  OUT NOCOPY VARCHAR2
              ,x_status_type_tbl    OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_status_code_tbl    OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_menu_name_tbl      OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_return_status      OUT NOCOPY VARCHAR2
              ,x_error_message_code OUT NOCOPY VARCHAR2) IS

cursor csr_get_role_level_info is
select nvl(prt.status_level, 'SYSTEM'), fm.menu_name
from   pa_project_role_types_b prt, fnd_menus fm
where  prt.project_role_id = p_role_id
and    prt.menu_id = fm.menu_id(+);

cursor csr_get_role_status_info is
select prsm.role_status_menu_id, prsm.status_type,
       prsm.status_code, fm.menu_name
from   pa_role_status_menu_map prsm, fnd_menus fm
where  prsm.role_id = p_role_id
and    prsm.menu_id = fm.menu_id;

l_count NUMBER := 1;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN csr_get_role_level_info;
FETCH csr_get_role_level_info into x_status_level, x_default_menu_name;
IF csr_get_role_level_info%NOTFOUND THEN
    x_return_status := fnd_api.g_ret_sts_error;
    x_error_message_code := 'PA_INVALID_PROJECT_ROLE';
ELSE
   IF x_default_menu_name IS NOT NULL THEN
      OPEN csr_get_role_status_info;
      FETCH csr_get_role_status_info BULK COLLECT into
					     x_role_status_menu_id_tbl,
                                             x_status_type_tbl,
				             x_status_code_tbl,
				             x_menu_name_tbl;
      CLOSE csr_get_role_status_info;
   ELSE
      x_role_status_menu_id_tbl := NULL;
      x_status_type_tbl := NULL;
      x_status_code_tbl := NULL;
      x_menu_name_tbl := NULL;
      x_status_level := NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;
END IF;

CLOSE csr_get_role_level_info;


EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_error_message_code := SQLCODE;

END get_role_status_menus;

end pa_role_status_menu_utils ;

/
