--------------------------------------------------------
--  DDL for Package PA_ROLE_STATUS_MENU_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_STATUS_MENU_UTILS" AUTHID CURRENT_USER as
-- $Header: PAXRSMUS.pls 115.3 2003/08/20 06:47:15 adoraira ship $

--
--  PROCEDURE
--              check_dup_role_status
--  PURPOSE
--              This procedure checks to see that the same status
--              has not already been mapped to a menu for a given role.
--  HISTORY
--     22-May-2003      Ranjana Murthy    - Created
--
PROCEDURE check_dup_role_status(p_role_status_menu_id IN  NUMBER
                               ,p_role_id             IN  NUMBER
                               ,p_status_code         IN  VARCHAR2
                               ,p_return_status       OUT NOCOPY VARCHAR2
                               ,p_error_message_code  OUT NOCOPY VARCHAR2);

--
--  PROCEDURE
--              check_status_is_in_use
--  PURPOSE
--              This procedure checks to see that the given status
--              exists in pa_role_status_menu_map - if it does, it
--		cannot be deleted from the Project Status form.
--		Called from the PA_PROJECT_STUS_UTILS.Allow_Status_Deletion
--		procedure.
--  HISTORY
--     20-June-2003      Ranjana Murthy    - Created
--
PROCEDURE check_status_is_in_use(p_status_code        IN  VARCHAR2
                                ,p_in_use_flag        OUT NOCOPY VARCHAR2
                                ,p_return_status      OUT NOCOPY VARCHAR2
                                ,p_error_message_code OUT NOCOPY VARCHAR2);
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

PROCEDURE get_role_status_menus(
               p_role_id            IN  NUMBER
              ,x_role_status_menu_id_tbl  OUT NOCOPY SYSTEM.pa_num_tbl_type
              ,x_status_level       OUT NOCOPY VARCHAR2
              ,x_default_menu_name  OUT NOCOPY VARCHAR2
              ,x_status_type_tbl    OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_status_code_tbl    OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_menu_name_tbl      OUT NOCOPY SYSTEM.pa_varchar2_30_tbl_type
              ,x_return_status      OUT NOCOPY VARCHAR2
              ,x_error_message_code OUT NOCOPY VARCHAR2);

end pa_role_status_menu_utils;

 

/
