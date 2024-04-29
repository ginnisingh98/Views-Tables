--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_PVT" as
/*$Header: PAPMPRVB.pls 120.21.12010000.9 2010/03/17 23:26:08 rbruno ship $*/

--Global constants to be used in error messages
G_PKG_NAME        CONSTANT VARCHAR2(30)   :='PA_PROJECT_PVT';
G_PROJECT_CODE    CONSTANT VARCHAR2(100)  :='PROJECT';
G_TASK_CODE   CONSTANT VARCHAR2(100)  :='TASK';
G_KEY_MEMBER_CODE CONSTANT VARCHAR2(100)  :='KEY_MEMBER';
G_CLASS_CAT_CODE  CONSTANT VARCHAR2(100)  :='CLASS_CATEGORY';
G_USER_ID     CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID    CONSTANT NUMBER := FND_GLOBAL.login_id;
-- anlee org role changes
G_KEY_MEMBER_CODE CONSTANT VARCHAR2(100)  :='ORG_ROLE';
l_pm_product_code VARCHAR2(2) :='Z'; /*for bug 2413400 a new variable defined.*/

-- scope of these four global variables pertains within this package body
g_rev_ind_rate_sch_id   pa_ind_rate_schedules.ind_rate_sch_id%TYPE   := NULL;  -- added for bug 3975253  (or can also init to PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
g_rev_rate_sch_type     pa_ind_rate_schedules.ind_rate_schedule_type%TYPE  := NULL;   -- added for bug 3975253
g_inv_ind_rate_sch_id   pa_ind_rate_schedules.ind_rate_sch_id%TYPE   := NULL;   -- added for bug 3975253
g_inv_rate_sch_type     pa_ind_rate_schedules.ind_rate_schedule_type%TYPE  := NULL;   -- added for bug 3975253

/*code added for bug no:2413400 */
Cursor p_product_code_csr (p_pm_product_code IN VARCHAR2)
  Is
  Select 'X'
  from pa_lookups
  where lookup_type='PM_PRODUCT_CODE'
     and lookup_code = p_pm_product_code;


--====================================================================================
--Name:               add_key_members
--Type:               Procedure
--Description:        This procedure can be used to add key members
--            to a new or already existing project using
--            the overridable view.
--
--Called subprograms: none
--
--
--
--History:
--    15-AUG-1996        L. de Werker    Created
-- 17-JUL-2000 Mohnish
--             added code for ROLE BASED SECURITY:
--             added the call to PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY
--  19-JUL-2000 Mohnish incorporated PA_PROJECT_PARTIES_PUB API changes
--
PROCEDURE add_key_members
( p_return_status           OUT NOCOPY VARCHAR2                , --4537865 Added nocopy hint
  p_pa_source_template_id       IN  NUMBER                  ,
  p_project_id              IN  NUMBER                  ,
  p_key_members             IN  pa_project_pub.project_role_tbl_type    )
IS

   --needed to get the overridable fields for this project template source
/*  commented the code for the Bug#1891621, starts here */
/*   CURSOR l_override_fields_csr
        (p_pa_source_template_id NUMBER)
   IS
   SELECT   DISTINCT *
   FROM     pa_override_fields_v pof
   WHERE    pof.pa_source_template_id = p_pa_source_template_id;

   TYPE override_fields_table_type IS TABLE OF l_override_fields_csr%rowtype
    INDEX BY BINARY_INTEGER;
*/
/* commented the code for the Bug#1891621,  ends here  */

/* modified the following cursor for Bug#5196996
   CURSOR l_project_role_types_csr (p_role_type IN VARCHAR2)
   IS
   SELECT 'x' FROM
   pa_project_role_types
   WHERE project_role_type = p_role_type; */

--This is the modified cursor Bug#5196996

CURSOR l_project_role_types_csr(p_role_type IN VARCHAR2,p_project_id IN number)
IS
SELECT  'x'
FROM    pa_project_role_types_v roles,
        pa_role_controls controls,
        pa_projects_all proj
WHERE   proj.project_id                 =       p_project_id
 AND    proj.ROLE_LIST_ID                       is null
 AND    roles.project_role_id           =       controls.project_role_id
 AND    roles.PROJECT_ROLE_TYPE         =       p_role_type
 AND    controls.role_control_code      =       'ALLOW_AS_PROJ_MEMBER'
 AND    trunc(sysdate) between start_date_active and nvl(end_date_active,sysdate)
UNION  ALL
SELECT  'x'
FROM    pa_project_role_types_v roles,
        pa_role_controls controls,
        pa_projects_all proj,
        pa_role_list_members prlm
WHERE   proj.project_id                 =       p_project_id
 AND    proj.ROLE_LIST_ID               =       prlm.role_list_id
 AND    prlm.project_role_id            =       roles.project_role_id
 AND    roles.project_role_id           =       controls.project_role_id
 AND    roles.PROJECT_ROLE_TYPE         =       p_role_type
 AND    controls.role_control_code      =       'ALLOW_AS_PROJ_MEMBER'
 AND    trunc(sysdate) between start_date_active and nvl(end_date_active,sysdate);

 -- the above cusroe has been modified for Bug#5196996

/* Bug 2480072 - Modified the following cursor to add cursor
                parameters p_start_date and p_end_date and
               added the AND clause in where */

/* added the code for the Bug#1891621, starts here  */
  CURSOR l_project_manager_counter_csr( p_project_id NUMBER,
                                        p_start_date DATE,
                                        p_end_date DATE
                                         ) IS
   select count(*)
      from pa_project_players
     where project_id = p_project_id
       and project_role_type = 'PROJECT MANAGER'
       and (( nvl(end_date_active,nvl(p_start_date,sysdate)) between
                          nvl(p_start_date,sysdate) and nvl(p_end_date,sysdate))
                    OR
         (start_date_active between  nvl(p_start_date,sysdate) and nvl(p_end_date,sysdate)));
/*  added the code for the Bug#1891621, ends here  */

   l_api_name            CONSTANT   VARCHAR2(30)        := 'add_key_members';
--   l_override_fields_rec          l_override_fields_csr%rowtype;
--   l_override_fields_tab          override_fields_table_type;
   i                        BINARY_INTEGER :=0;
   j                        BINARY_INTEGER :=0;
--   l_field_is_overridable         BINARY_INTEGER :=0;
   l_project_manager_counter            NUMBER := 0;
   l_max_number_of_proj_managers CONSTANT   NUMBER := 1;
   l_dummy                      VARCHAR2(1);
   l_amg_segment1       VARCHAR2(25);
   l_completion_date    DATE;
   v_start_date_active  DATE;
   v_end_date_active    DATE;
   v_project_role_id    NUMBER;
   v_project_role_type  VARCHAR2(20);
   v_person_id          NUMBER;
   v_null_number        NUMBER;
   v_null_char          VARCHAR2(1);
   x_return_status      VARCHAR2(255);
   x_msg_count          NUMBER;
   x_msg_data           VARCHAR2(255);
   x_project_party_id   NUMBER;
   x_resource_id        NUMBER;
   l_wf_item_type          VARCHAR2(30);
   l_wf_type               VARCHAR2(30);
   l_wf_party_process      VARCHAR2(30);
   l_assignment_id         NUMBER;
   l_resource_id          NUMBER;


--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1,COMPLETION_DATE
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT add_key_members_pvt;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --get all the overridable fields for this project template source
/*  commented the code for the Bug#1891621, starts here  */
/*    OPEN l_override_fields_csr(p_pa_source_template_id);
    i := 0;
    LOOP
        i := i + 1;
        FETCH l_override_fields_csr INTO l_override_fields_rec;
        EXIT WHEN l_override_fields_csr%NOTFOUND;
        l_override_fields_tab(i) := l_override_fields_rec;

    END LOOP;

    CLOSE l_override_fields_csr;
*/
/*   commented the code for the Bug#1891621, ends here  */
-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1,l_completion_date;
   CLOSE l_amg_project_csr;

 /*  Bug 2480072 Commenting the open, fetch and close of the following cursor and
    shifting it to the inside while loop */

/* added the code for the Bug#1891621, starts here
   OPEN l_project_manager_counter_csr( p_project_id );
   FETCH l_project_manager_counter_csr INTO l_project_manager_counter;
   CLOSE l_project_manager_counter_csr;
   added the code for the Bug#1891621, ends here
*/
    i := p_key_members.first;

    WHILE i IS NOT NULL LOOP

   /*  Bug 2480072 - Added the following curosr fetch, open and close call */
   OPEN l_project_manager_counter_csr( p_project_id ,p_key_members(i).start_date,p_key_members(i).end_date);
   FETCH l_project_manager_counter_csr INTO l_project_manager_counter;
   CLOSE l_project_manager_counter_csr;

--      l_field_is_overridable := 0;
   -- Check whether this is a valid employee

 IF (p_key_members(i).person_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
      (p_key_members(i).person_id IS NOT NULL) THEN
       IF check_valid_employee (p_key_members(i).person_id) = 'N'
       THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_INVALID_KEY_MEMBER'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            END IF;
                RAISE  FND_API.G_EXC_ERROR;
       END IF;

  -- validate the role type
     OPEN l_project_role_types_csr (p_key_members(i).project_role_type,p_project_id); --New parameter for bug 5196996
     FETCH l_project_role_types_csr INTO l_dummy;
     IF l_project_role_types_csr%NOTFOUND THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_INVALID_ROLE_TYPE'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;
        CLOSE l_project_role_types_csr;
        RAISE  FND_API.G_EXC_ERROR;
     ELSE
        CLOSE l_project_role_types_csr;
     END IF;


       IF p_key_members(i).start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       AND p_key_members(i).end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       THEN
          IF  p_key_members(i).end_date < p_key_members(i).start_date
          THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_SU_INVALID_DATES'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                END IF;

                RAISE  FND_API.G_EXC_ERROR;
          END IF;
       END IF;
/*   commented the code for the Bug#1891621, starts here  */
/*       j := l_override_fields_tab.first;

    --check whether this project role type is overridable
    WHILE j IS NOT NULL LOOP
-- dbms_output.put_line('field_name =   '||l_override_fields_tab(j).pa_field_name);
-- dbms_output.put_line('display_name = '||l_override_fields_tab(j).pa_display_name);
        IF l_override_fields_tab(j).pa_field_name = 'KEY_MEMBER'
        AND upper(l_override_fields_tab(j).type) = upper(p_key_members(i).project_role_type)
        THEN
            l_field_is_overridable := 1;

            IF upper(p_key_members(i).project_role_type) = 'PROJECT MANAGER'
            THEN l_project_manager_counter := l_project_manager_counter + 1;
            END IF;

            EXIT;
        END IF;
        j := l_override_fields_tab.next(j);
    END LOOP;

    IF l_field_is_overridable <> 1
            --if not overridable RAISE ERROR else insert
    THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_ROLE_TYPE_NOT_OVERRIDABLE'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    ELSE
*/
/*  commented the code for the Bug#1891621, ends here  */

        IF upper(p_key_members(i).project_role_type) = 'PROJECT MANAGER'
        AND l_project_manager_counter > l_max_number_of_proj_managers
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PR_TOO_MANY_MGRS'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        ELSE

/*
-- begin OLD code before changes for ROLE BASED SECURITY
            INSERT INTO pa_project_players
                   (project_id
                   ,person_id
                   ,project_role_type
                   ,start_date_active
                   ,end_date_active
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,last_update_login              )
            VALUES
                 ( p_project_id
                  ,p_key_members(i).person_id
                  ,p_key_members(i).project_role_type
                  ,DECODE(p_key_members(i).start_date,
                   PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                   TRUNC(SYSDATE),
                                   NULL,TRUNC(SYSDATE),
                                   p_key_members(i).start_date)
                  ,p_key_members(i).end_date
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id      );
-- end OLD code before changes for ROLE BASED SECURITY
*/
-- begin NEW code for ROLE BASED SECURITY
/*        Select
           DECODE(p_key_members(i).start_date,
                  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE, TRUNC(SYSDATE),
                  NULL,TRUNC(SYSDATE),
                  p_key_members(i).start_date)
       Into     v_start_date_active
       From     dual;
*/    --commented and added following line. --Ansari

--       v_start_date_active := PA_PROJECT_PARTIES_PUB.GET_KEY_MEMBER_START_DATE (p_project_id);

     /*Commented the below code for the bug 2910972*/

      /* IF p_key_members(i).start_date is null OR
          p_key_members(i).start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       THEN
          v_start_date_active := PA_PROJECT_PARTIES_PUB.GET_KEY_MEMBER_START_DATE (p_project_id);
       ELSE
          Code addition starts for the bug 2686120
          IF p_key_members(i).start_date > sysdate THEN
        v_start_date_active := p_key_members(i).start_date;
      ELSE
        v_start_date_active := PA_PROJECT_PARTIES_PUB.GET_KEY_MEMBER_START_DATE (p_project_id);
      END IF;
      Code addition ends for the bug 2686120
        END IF; */

        /*Added the below code for the bug 2910972*/

         IF p_key_members(i).start_date is null OR
          p_key_members(i).start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       THEN
          v_start_date_active := NULL;
       ELSE
            v_start_date_active := p_key_members(i).start_date;
       END IF;

       /*End of the code added for the bug 2910972*/

       Select project_role_id
       Into   v_project_role_id
       From   pa_project_role_types
       Where  project_role_type=p_key_members(i).project_role_type;

          v_end_date_active   := p_key_members(i).end_date;
          v_project_role_type := p_key_members(i).project_role_type;
          v_person_id         := p_key_members(i).person_id;
          v_null_number       := to_number(NULL);

   PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
          p_api_version => 1.0           -- p_api_version
          , p_init_msg_list => FND_API.G_TRUE  -- p_init_msg_list
          , p_commit => FND_API.G_FALSE  -- p_commit
          , p_validate_only => FND_API.G_FALSE -- p_validate_only
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL  -- p_validation_level
          , p_debug_mode => 'N'          -- p_debug_mode
          , p_object_id => p_project_id  -- p_object_id
          , p_OBJECT_TYPE => 'PA_PROJECTS'  -- p_OBJECT_TYPE
          , p_project_role_id => v_project_role_id  -- p_project_role_id
          , p_project_role_type => NULL  -- p_project_role_type
          , p_RESOURCE_TYPE_ID => 101    -- p_RESOURCE_TYPE_ID
          , p_resource_source_id => v_person_id  -- p_resource_source_id
          , p_resource_name => v_null_char       -- p_resource_name
          , p_start_date_active => v_start_date_active  -- p_start_date_active
          , p_scheduled_flag => 'N'      -- p_scheduled_flag
--          , p_record_version_number => 1 -- p_record_version_number
          , p_calling_module => 'FORM'   -- p_calling_module
          , p_project_id => p_project_id -- p_project_id
          , p_project_end_date => l_completion_date  -- p_project_end_date
          , p_end_date_active => v_end_date_active  -- p_end_date_active
          , x_project_party_id => x_project_party_id  -- x_project_party_id
          , x_resource_id => x_resource_id      -- x_resource_id
          , x_wf_item_type     =>l_wf_item_type
          , x_wf_type          => l_wf_type
          , x_wf_process       => l_wf_party_process
          , x_assignment_id    => l_assignment_id
          , x_return_status => x_return_status  -- x_return_status
          , x_msg_count => x_msg_count          -- x_msg_count
          , x_msg_data => x_msg_data            -- x_msg_data
                             );
          IF    (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                p_return_status := x_return_status;
--                p_msg_count     := x_msg_count;
--                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
                if    (x_return_status = FND_API.G_RET_STS_ERROR) then
                      raise  FND_API.G_EXC_UNEXPECTED_ERROR;
                else  -- (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then
                      raise  FND_API.G_EXC_ERROR;
                end if;
         END IF;
-- end NEW code for ROLE BASED SECURITY
        END IF;

--  END IF;

END IF; -- IF(p_key_members(i).person_id <>
        -- PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    i := p_key_members.next(i);

    END LOOP; --key members


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */
    ROLLBACK TO add_key_members_pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */
    ROLLBACK TO add_key_members_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */
    ROLLBACK TO add_key_members_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END add_key_members;

--====================================================================================
--Name:               add_class_categories
--Type:               Procedure
--Description:        This procedure can be used to add class categories
--            to a new or already existing project using
--            the overridable view.
--
--Called subprograms: none
--
--
--
--History:
--    07-AUG-2002        gjain       Added code for Bug 2448159. Now if
--                   pick_one_code_only_flag for a class_category
--                   is 'Y' then no more than a single class code
--                   can be added for that class category
--
--    15-AUG-1996        L. de Werker    Created
--
PROCEDURE add_class_categories
( p_return_status           OUT NOCOPY VARCHAR2                , -- 4537865 Added the nocopy hint
  p_pa_source_template_id       IN  NUMBER                  ,
  p_project_id              IN  NUMBER                  ,
  p_class_categories            IN  pa_project_pub.class_category_tbl_type  )
IS

   --needed to get the overridable fields for this project template source
/*  code commented for the bug#1891621, starts here  */
/*   CURSOR l_override_fields_csr
        (p_pa_source_template_id NUMBER)
   IS
   SELECT   DISTINCT *
   FROM     pa_override_fields_v pof
   WHERE    pof.pa_source_template_id = p_pa_source_template_id;

   TYPE override_fields_table_type IS TABLE OF l_override_fields_csr%rowtype
    INDEX BY BINARY_INTEGER;
*/
/*  code commented for the bug#1891621, ends here  */
   l_api_name           CONSTANT    VARCHAR2(30)        := 'add_class_categories';
--   l_override_fields_rec          l_override_fields_csr%rowtype;
--   l_override_fields_tab          override_fields_table_type;
   i                        BINARY_INTEGER :=0;
   j                        BINARY_INTEGER :=0;
--   l_field_is_overridable         BINARY_INTEGER :=0;
   l_amg_segment1       VARCHAR2(25);

   /* added the below two local variables for bug 2448159 */
   l_pick_one_code_only  VARCHAR2(1);
   l_count       NUMBER;

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   p_multiple_task_msg           VARCHAR2(1) := 'T';

   /* Following Cursor l_valid_category_csr has been commented
      for Performance Bug # 3693217

      This cursor has been split into two for the Performance Fix


   CURSOR l_valid_category_csr (c_project_id NUMBER, c_class_category VARCHAR2)
   IS
   SELECT 'Y'
   FROM PA_VALID_CATEGORIES_V vc,
        PA_PROJECTS_ALL ppa,
        PA_PROJECT_TYPES_ALL ppta
   WHERE ppa.project_id = c_project_id
   AND   ppa.project_type = ppta.project_type
   AND   nvl(ppa.org_id, -99) = nvl(ppta.org_id, -99)
   AND   ppta.project_type_id = vc.object_type_id
   AND   vc.class_category = c_class_category; */

   /* Start of code for Performance Bug # 3693217*/
    CURSOR l_valid_category_csr1 (c_project_id NUMBER, c_class_category VARCHAR2)
    IS
    SELECT 'Y'
      FROM DUAL
     WHERE EXISTS
    (
    SELECT 'Y'
    FROM   PA_CLASS_CATEGORIES cc,
           PA_VALID_CATEGORIES vc,
           PA_PROJECT_TYPES_ALL PPTA,
           PA_PROJECTS_ALL PPA
    WHERE  PPA.PROJECT_ID = c_project_id
    AND    PPA.PROJECT_TYPE = PPTA.PROJECT_TYPE
--    AND    nvl(PPA.ORG_ID, -99) = nvl(PPTA.ORG_ID, -99) - R12: Bug 4364092
    AND    PPA.ORG_ID = PPTA.ORG_ID
    AND    VC.CLASS_CATEGORY = c_class_category
    AND    VC.CLASS_CATEGORY = cc.CLASS_CATEGORY
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(CC.START_DATE_ACTIVE)
                              AND TRUNC(NVL(CC.END_DATE_ACTIVE, SYSDATE))
    AND    VC.OBJECT_TYPE_ID = PPTA.PROJECT_TYPE_ID
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(PPTA.START_DATE_ACTIVE)
                              AND TRUNC(NVL(PPTA.END_DATE_ACTIVE, SYSDATE))
    ) ;

    CURSOR l_valid_category_csr2 ( c_class_category VARCHAR2)
    IS
    SELECT 'Y'
      FROM DUAL
     WHERE EXISTS
    (
    SELECT 'Y'
    FROM   PA_CLASS_CATEGORIES cc
    WHERE  CC.OBJECT_TYPE = 'PA_PROJECTS'
     AND   CC.ALL_TYPES_VALID_FLAG = 'Y'
     AND   TRUNC(SYSDATE) BETWEEN TRUNC(CC.START_DATE_ACTIVE)
                          AND TRUNC(NVL(CC.END_DATE_ACTIVE, SYSDATE))
     AND   cc.CLASS_CATEGORY = c_class_category
    ) ;

   /* End of code for Performance Bug # 3693217*/

   CURSOR l_check_percentage_csr (c_class_category VARCHAR2)
   IS
   SELECT 'Y'
   FROM PA_CLASS_CATEGORIES
   WHERE class_category = c_class_category
   AND allow_percent_flag = 'Y';

   CURSOR l_get_percent_flag_csr (c_class_category VARCHAR2)
   IS
   SELECT allow_percent_flag
   FROM PA_CLASS_CATEGORIES
   WHERE class_category = c_class_category;

   /* code addition for bug 2448159 starts*/
   CURSOR l_pick_one_code_only_flag (c_class_category VARCHAR2)
   IS
   SELECT PICK_ONE_CODE_ONLY_FLAG
   FROM PA_CLASS_CATEGORIES
   WHERE class_category = c_class_category;

   CURSOR l_get_code_count (c_project_id NUMBER, c_class_category VARCHAR2)
   IS
   select count(*)
   from PA_PROJECT_CLASSES
   WHERE Project_id = c_project_id
   AND class_category = c_class_category;
   /* code addition for bug 2448159 ends */

   l_dummy   VARCHAR2(1) := 'Y';
   l_dummy2  VARCHAR2(1) := 'Y';
   l_allow_percent_flag VARCHAR2(1);
   l_code_percentage NUMBER;

BEGIN


--  Standard begin of API savepoint

    SAVEPOINT add_class_categories_pvt;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

--  get all the overridable fields for this project template source
/* code commented for the Bug#1891621, starts here  */
/*    OPEN l_override_fields_csr(p_pa_source_template_id);
    i := 0;
    LOOP
        i := i + 1;
        FETCH l_override_fields_csr INTO l_override_fields_rec;
        EXIT WHEN l_override_fields_csr%NOTFOUND;
        l_override_fields_tab(i) := l_override_fields_rec;

    END LOOP;

    CLOSE l_override_fields_csr;
*/
/* code commented for the Bug#1891621, ends here  */
-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

    i := p_class_categories.first;

    WHILE i IS NOT NULL LOOP

 -- Process only if a class category and class code are filled up

IF (p_class_categories(i).class_category <>
    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) AND
   (p_class_categories(i).class_category IS NOT NULL )
AND (p_class_categories(i).class_code <>
    PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR ) AND
   (p_class_categories(i).class_code IS NOT NULL )

THEN
/* code commented for the bug#1891621, starts here  */
/*      l_field_is_overridable := 0;
    j := l_override_fields_tab.first;

    --check whether this class category type is overridable
    WHILE j IS NOT NULL LOOP
        IF l_override_fields_tab(j).pa_field_name = 'CLASSIFICATION'
        AND upper(l_override_fields_tab(j).type) = upper(p_class_categories(i).class_category)
        THEN
            l_field_is_overridable := 1;
            EXIT;

        END IF;
        j := l_override_fields_tab.next(j);
    END LOOP;

    IF l_field_is_overridable <> 1  --if not overridable error else insert
    THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_CLASS_CAT_NOT_OVERRIDABLE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

            p_multiple_task_msg := 'F';
--          RAISE FND_API.G_EXC_ERROR;

    ELSE
*/
/* code commented for the bug#1891621, ends here */
/* dbms_output.put_line('Trying to insert'); */

/*  dbms_output.put_line('1:'||p_class_categories(i).class_category
              ||'2:'||p_class_categories(i).class_code
              ||'3:'||fnd_global.user_id
              ||'4:'||sysdate
              ||'5:'||fnd_global.user_id
              ||'6:'||fnd_global.login_id
              ||'7:'||p_project_id
              ||'8:'||sysdate);     */


         -- Check whether the category is valid for this project type

      /* commented for performance bug fix 3693217
       OPEN l_valid_category_csr(p_project_id, p_class_categories(i).class_category);
       FETCH l_valid_category_csr INTO l_dummy;
       if l_valid_category_csr%NOTFOUND then
          l_dummy := 'N';
       end if;
       CLOSE l_valid_category_csr;*/

      /* Start of Code for Performance Bug Fix 3693217  */

       -- Review Comment Incorporated - If not found in Cursor1 ,then go for the cursor2
       --                               If not found in Cursor2 also ,then only set l_dummy as 'N'

       OPEN l_valid_category_csr1(p_project_id, p_class_categories(i).class_category);
       FETCH l_valid_category_csr1 INTO l_dummy;
       if l_valid_category_csr1%NOTFOUND then
          OPEN l_valid_category_csr2(p_class_categories(i).class_category);
      FETCH l_valid_category_csr2 INTO l_dummy;
      if l_valid_category_csr2%NOTFOUND then
             l_dummy := 'N';
          end if;
          CLOSE l_valid_category_csr2;
       end if;
       CLOSE l_valid_category_csr1;
      /* End of Code  for Performance Bug Fix 3693217  */

       -- Check whether percentage is allowed for this category
       -- Also check that percentage is between 0 and 100
  /* Bug#2474078 Added a condition to check whether code_percentage has been passed or not, the default value for
     this parameter is  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, hence code_percentage should not be equal to it */
       if p_class_categories(i).code_percentage is not null and
          p_class_categories(i).code_percentage <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM then
         OPEN l_check_percentage_csr(p_class_categories(i).class_category);
         FETCH l_check_percentage_csr INTO l_dummy2;
         if l_check_percentage_csr%NOTFOUND then
           l_dummy2 := 'N';
         elsif (p_class_categories(i).code_percentage < 0) OR
               (p_class_categories(i).code_percentage > 100) then
           l_dummy2 := 'N';
         end if;
         CLOSE l_check_percentage_csr;
       end if;

       IF (check_class_code_valid
          (p_class_categories(i).class_category,
           p_class_categories(i).class_code) = 'N') OR
          (l_dummy = 'N') OR (l_dummy2 = 'N')
       THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_CLASS_CATEGORY'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;

            p_multiple_task_msg := 'F';
--          RAISE FND_API.G_EXC_ERROR;

       END IF;

       /* Modified the following code for bug #3629840. */
       if p_class_categories(i).code_percentage = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM then
          l_code_percentage := NULL;
       else
          l_code_percentage := p_class_categories(i).code_percentage;
       end if;

       -- If allow_percent_flag is 'Y' and code_percentage is NULL, default to 0
       if p_class_categories(i).code_percentage is null then
         OPEN l_get_percent_flag_csr(p_class_categories(i).class_category);
         FETCH l_get_percent_flag_csr INTO l_allow_percent_flag;
         if l_get_percent_flag_csr%FOUND then
           if l_allow_percent_flag = 'Y' then
             l_code_percentage := 0;
           end if;
         end if;

     /* below line of code also added for Bug 2448159
         cursor l_get_percent_flag_csr should be closed otherwise we get error
        'ORA-06511: PL/SQL: cursor already open' while adding multiple class categories */
     CLOSE l_get_percent_flag_csr;
       end if;

       BEGIN -- 5348726 : Added for Bug#5294891
            INSERT INTO pa_project_classes
                   (project_id
                   ,class_category
                   ,class_code
                   ,code_percentage
                   ,object_id
                   ,object_type
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,last_update_login
                   ,record_version_number /* Added For bug#2766416 */
                   )
            VALUES
                 ( p_project_id
                  ,p_class_categories(i).class_category
                  ,p_class_categories(i).class_code
                  ,l_code_percentage
                  ,p_project_id
                  ,'PA_PROJECTS'
                  ,sysdate
                  ,fnd_global.user_id
                  ,sysdate
                  ,fnd_global.user_id
                  ,fnd_global.login_id
                  ,0 /* Added for bug#2766416 */
                 );

       EXCEPTION  -- 5348726 : Exception block added for Bug#5294891
           WHEN DUP_VAL_ON_INDEX THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_DUPLICATE_CLASS_CATG'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'Y'
                       ,p_msg_context      => ''
                       ,p_attribute1       => ''
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                     p_multiple_task_msg := 'F';
                     exit;
               END IF;
       END;

END IF;--IF (p_class_categories(i).class_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )

    i := p_class_categories.next(i);

    END LOOP; --class categories

   /* code addition for bug 2448159 starts*/
   /* check if after insertion the constraint is being violated or not */

    i := p_class_categories.first;

    WHILE i IS NOT NULL LOOP

           OPEN l_pick_one_code_only_flag (p_class_categories(i).class_category);
           FETCH l_pick_one_code_only_flag INTO l_pick_one_code_only;
           if l_pick_one_code_only_flag%NOTFOUND then
            l_pick_one_code_only := null;
           end if;
           CLOSE l_pick_one_code_only_flag;

           IF l_pick_one_code_only = 'Y' THEN

            Open l_get_code_count(p_project_id , p_class_categories(i).class_category);
            FETCH l_get_code_count into l_count;
            CLOSE l_get_code_count;

            IF l_count > 1 THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_ONE_CODE_ONLY_CLASS'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'Y'   /* Bug 2888297 Changed N to Y */
                       ,p_msg_context      => 'PROJ'
                       ,p_attribute1       => l_amg_segment1
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');

                                       p_multiple_task_msg := 'F';
                END IF;

            END IF;
           END IF;
           i := p_class_categories.next(i);
    END LOOP;
   /* code addition for bug 2448159 ends */

   IF p_multiple_task_msg = 'F'
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */
    ROLLBACK TO add_class_categories_pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */
    ROLLBACK TO add_class_categories_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */
    ROLLBACK TO add_class_categories_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END add_class_categories;

--====================================================================================
--Name:               add_task_round_one
--Type:               Procedure
--Description:        This procedure can be used to add a task to a new or already
--            existing project. This procedure should always be used together
--            with add_task_round_two.
--
--
--Called subprograms: none
--
--
--
--History:
--    15-AUG-1996        L. de Werker    Created
--    10_dec-1996    L. de Werker    Enabled the use of task addresses
--    09-01-2006    vkadimes    Changes are tagged with Bug Number 4689326.
PROCEDURE add_task_round_one
(p_return_status            OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy hint
,p_project_rec              IN  pa_projects%rowtype
,p_task_rec             IN  pa_project_pub.task_in_rec_type
,p_project_type_class_code      IN  pa_project_types.project_type_class_code%type
,p_service_type_code            IN  pa_project_types.service_type_code%type
,p_task_id              OUT NOCOPY NUMBER                      ) -- 4537865 Added nocopy hint
IS

   CURSOR l_customer_csr( p_project_id NUMBER )
   IS
   SELECT   customer_id
   FROM     pa_project_customers
   WHERE    project_id = p_project_id;

   -- 4363092 TCA changes, replaced RA views with HZ tables

   /*
   CURSOR l_address_csr(p_customer_id NUMBER, p_address_id NUMBER )
   IS
   SELECT   'x'
   FROM     ra_addresses
   WHERE    customer_id = p_customer_id
   AND      address_id = p_address_id;
   */

   CURSOR l_address_csr(p_customer_id NUMBER, p_address_id NUMBER )
   IS
   SELECT   'x'
   FROM
         hz_cust_acct_sites_all acct_site
   WHERE
         acct_site.cust_account_id = p_customer_id
   AND   acct_site.cust_acct_site_id = p_address_id;
   -- 4363092 end

   CURSOR l_service_type_csr( p_service_type_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM    pa_lookups
   WHERE  lookup_type = 'SERVICE TYPE'
   AND    lookup_code = p_service_type_code;

   l_api_name           CONSTANT    VARCHAR2(30)        := 'add_task_round_one';
   l_task_id            NUMBER;
   l_project_id         NUMBER;
   l_task_in_rec        pa_project_pub.task_in_rec_type;
   l_wbs_level          NUMBER :=1;
   l_dummy          VARCHAR2(1);
   l_customer_id        NUMBER;
   l_address_id         NUMBER;
   l_address_valid      VARCHAR2(1);
   l_attribute_category             VARCHAR2(30);
   l_attribute1                 VARCHAR2(150);
   l_attribute2                 VARCHAR2(150);
   l_attribute3                 VARCHAR2(150);
   l_attribute4                 VARCHAR2(150);
   l_attribute5                 VARCHAR2(150);
   l_attribute6                 VARCHAR2(150);
   l_attribute7                 VARCHAR2(150);
   l_attribute8                 VARCHAR2(150);
   l_attribute9                 VARCHAR2(150);
   l_attribute10                VARCHAR2(150);
   --bug 6153503
   l_return_msg                  varchar2(2000);
   l_validate_status             varchar2(1);
   --end bug 6153503
   l_allow_cross_charge_flag    VARCHAR2(1);
   l_project_rate_type   PA_PROJECTS.PROJECT_RATE_TYPE%type ; --bug2170388
   l_project_rate_date    DATE;
   l_actual_start_date                  DATE;
   l_actual_finish_date             DATE;
   l_early_start_date                   DATE;
   l_early_finish_date                  DATE;
   l_late_start_date                    DATE;
   l_late_finish_date                   DATE;
   l_scheduled_start_date           DATE;
   l_scheduled_finish_date          DATE;
   l_cc_process_labor_flag    VARCHAR2(1);
   l_labor_tp_schedule_id    NUMBER;
   l_labor_tp_fixed_date    DATE;
   l_cc_process_nl_flag    VARCHAR2(1);
   l_nl_tp_schedule_id    NUMBER;
   l_nl_tp_fixed_date    DATE;
   l_receive_project_invoice_flag    VARCHAR2(1);
   l_work_type_id         NUMBER;
   l_emp_bill_rate_schedule_id         NUMBER;
   l_job_bill_rate_schedule_id         NUMBER;

--Sakthi MCB
   l_non_lab_std_bill_rt_sch_id        NUMBER;
   l_taskfunc_cost_rate_date           DATE;
   l_taskfunc_cost_rate_type           VARCHAR2(30);

   l_non_labor_disc_reason_code        VARCHAR2(30);
   l_labor_disc_reason_code        VARCHAR2(30);

   l_competence_match_wt                    NUMBER;
   l_availability_match_wt                  NUMBER;
   l_job_level_match_wt                     NUMBER;
   l_enable_automated_search           VARCHAR2(1);
   l_search_min_availability                NUMBER;
   l_search_org_hier_id                     NUMBER;
   l_search_starting_org_id                 NUMBER;
   l_search_country_code               VARCHAR2(2);
   l_min_cand_score_reqd_for_num       NUMBER;
   l_invproc_currency_type             VARCHAR2(30);
   l_revproc_currency_code             VARCHAR2(15);
   l_project_bil_rate_date_code        VARCHAR2(30);
   l_project_bil_rate_type             VARCHAR2(30);
   l_project_bil_rate_date             DATE;
   l_project_bil_exchange_rate         NUMBER;
   l_projfunc_currency_code            VARCHAR2(15);
   l_projfunc_bil_rate_date_code       VARCHAR2(30);
   l_projfunc_bil_rate_type            VARCHAR2(30);
   l_projfunc_bil_rate_date            DATE;
   l_projfunc_bil_exchange_rate        NUMBER;
   l_funding_rate_date_code            VARCHAR2(30);
   l_funding_rate_type                 VARCHAR2(30);
   l_funding_rate_date                 DATE;
   l_funding_exchange_rate             NUMBER;
   l_baseline_funding_flag             VARCHAR2(1);
   l_projfunc_cost_rate_type           VARCHAR2(30);
   l_projfunc_cost_rate_date           DATE;
   l_inv_by_bill_trans_curr_flag       VARCHAR2(1);
   l_multi_currency_billing_flag       VARCHAR2(1);
--Sakthi MCB

--Sakthi Structure

   l_assign_precedes_task              VARCHAR2(1);
   l_split_cost_from_wokplan_flag     VARCHAR2(1);
   l_split_cost_from_bill_flag         VARCHAR2(1);

--Sakthi Structure

--PA L Changes 2872708
   l_retirement_cost_flag             VARCHAR2(1):= 'N';   --bug 2959252; defaulting to 'N'
   l_cint_eligible_flag               VARCHAR2(1):= 'N';   --bug 2959252; defaulting to 'N'
   l_cint_stop_date                   DATE;
--End PA L Changes 2872708


--Sakthi MCB

   l_out_start_date             DATE;
   l_out_completion_date        DATE;
   l_error_code               NUMBER;
   l_error_message              VARCHAR2(100);
   l_temp                     VARCHAR2(1);

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

--needed to get the default field values

   CURSOR   l_default_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   allow_cross_charge_flag,
            project_rate_date,
            project_rate_type,
            cc_process_labor_flag,
            labor_tp_schedule_id,
            labor_tp_fixed_date,
            cc_process_nl_flag,
            nl_tp_schedule_id,
            nl_tp_fixed_date,
            work_type_id,
            emp_bill_rate_schedule_id,
            job_bill_rate_schedule_id,
            projfunc_cost_rate_type,
            projfunc_cost_rate_date,
            non_lab_std_bill_rt_sch_id
--Sakthi MCB
/*
            competence_match_wt,
            availability_match_wt,
            job_level_match_wt,
            enable_automated_search,
            search_min_availability,
            search_org_hier_id,
            search_starting_org_id,
            search_country_code,
            min_cand_score_reqd_for_nom,
            non_lab_std_bill_rt_scr_id,
            invproc_currency_type,
            revproc_currency_code,
            project_bil_rate_date_code,
            project_bil_rate_type,
            project_bil_rate_date,
            project_bil_exchange_rate,
            profunc_currency_code,
            projfunc_bil_rate_date_Code,
            projfunc_bil_rate_type,
            projfunc_bil_rate_date,
            projfunc_bil_exchange_rate,
            funding_rate_date_Code,
            funding_rate_type,
            funding_rate_date,
            funding_exchange_rate,
            baseline_funding_flag,
            projfunc_cost_rate_type,
            projfunc_cost_rate_date,
            inv_by_bill_trans_curr_flag,
            multi_currency_billing_flag,
--Sakthi MCB
--Sakthi Structure
            assign_precedes_task,
            split_cost_from_workplan_flag,
            split_cost_from_bill_flag
--Sakthi Structure
*/
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

-- Fix for Bug # 1335417
-- needed for update of Fixed Date( p_cost_ind_sch_fixed_date)

   CURSOR l_ind_rate_schedule_type_csr( p_cost_ind_rate_sch_id NUMBER)
   IS
   SELECT       ind_rate_schedule_type
   FROM         pa_ind_rate_schedules
   WHERE        ind_rate_sch_id = p_cost_ind_rate_sch_id;

   --Bug 3279981
   --The revenue acrual method for the task needs to be defaulted from the (new) project
   CURSOR cur_get_rev_acc_mth IS
   SELECT revenue_accrual_method
   FROM   pa_projects_all
   WHERE project_id = p_project_rec.project_id;

   CURSOR cur_get_inv_mth IS
   SELECT invoice_method
   FROM   pa_projects_all
   WHERE project_id = p_project_rec.project_id;

   CURSOR cur_get_def_top_task_cust IS
   SELECT customer_id
   FROM   pa_project_customers
   WHERE  project_id = p_project_rec.project_id
   AND    default_top_task_cust_flag = 'Y';


-- Fix for Bug # 1335417
   l_temp_var_sch_type                         VARCHAR2(1);

-- (Begin Venkat) FP_M changes
   l_revenue_accrual_method    VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
   l_invoice_method            VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
   l_customer_id1              NUMBER;
   l_gen_etc_source_code       VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
-- (End Venkat) FP_M changes

-- rtarway, 3658479
   l_labor_cost_multiplier_name VARCHAR2(30) := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

   --BUG 3924597, added by rtarway for etc source default
   l_ref_task_id               NUMBER ;
   L_WP_SEPARATE_FROM_FIN      VARCHAR2(1);
   L_RETURN_STATUS             VARCHAR2(1);

   CURSOR get_gen_etc_source_code (l_task_id NUMBER, l_project_id NUMBER)
   IS
   select gen_etc_source_code
   from pa_tasks
   where
       task_id = l_task_id
   and project_id = l_project_id ;
   --End BUG 3924597, added by rtarway for etc source default

-- Start of addition for 4378507
   CURSOR   l_task_csr
        (p_project_id NUMBER
        ,p_pm_task_reference VARCHAR2)
   IS
   SELECT   t.TOP_TASK_ID
   FROM     pa_tasks t
   WHERE    t.project_id = p_project_id
   AND      t.pm_task_reference = p_pm_task_reference;


   CURSOR   l_task_id_csr
        (p_project_id NUMBER
        ,p_task_id NUMBER)
   IS
   SELECT   t.TOP_TASK_ID
   FROM     pa_tasks t
   WHERE    t.project_id = p_project_id
   AND      t.task_id = p_task_id;

   l_parent_TOP_TASK_ID pa_tasks.TOP_TASK_ID%type;
--End of addition for 4378507
-- Added for bug# 4689326
CURSOR l_customer_parent_task (l_p_parent_task_id NUMBER) IS
 SELECT customer_id FROM  pa_tasks WHERE task_id=l_p_parent_task_id;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT add_task_round_one_pvt;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- copy the incoming parameters to local variables
    l_task_in_rec   := p_task_rec;
    l_project_id    := p_project_rec.project_id;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> l_task_in_rec.task_name
    ,p_task_reference => l_task_in_rec.pm_task_reference
    ,p_task_id => '');

    --Refuse tasks if pm_task_reference is not provided
    --Refuse tasks if task_name is not provided

    IF l_task_in_rec.pm_task_reference IS NULL
    OR l_task_in_rec.pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_REF_IS_NULL'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF l_task_in_rec.task_name IS NULL
    OR l_task_in_rec.task_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
        p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_NAME_IS_NULL'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;
   IF l_task_in_rec.pa_task_number IS NULL OR
      l_task_in_rec.pa_task_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
      l_task_in_rec.pa_task_number   := l_task_in_rec.pm_task_reference;
   END IF;

    --setting defaults for MISSING values if appropriate
    IF l_task_in_rec.ready_to_bill_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    OR l_task_in_rec.ready_to_bill_flag IS NULL
    THEN
        l_task_in_rec.ready_to_bill_flag := 'N';   --will be defaulted to 'Y' for the top task
    END IF;                     -- in the second round

    IF l_task_in_rec.ready_to_distribute_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    OR l_task_in_rec.ready_to_distribute_flag IS NULL
    THEN
        l_task_in_rec.ready_to_distribute_flag := 'N'; -- will be defaulted to 'Y' for the top task
    END IF;                         -- in the second round

         /* Added for bug#2666913 */

    If l_task_in_rec.billable_flag = 'Y' and p_project_type_class_code = 'INDIRECT'
    THEN
                p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
        pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PR_INDIRECT_NO_BILLING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    /* end of code added for bug #2666913 */


    IF l_task_in_rec.billable_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND (l_task_in_rec.pm_parent_task_reference IS NULL
    OR l_task_in_rec.pm_parent_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
    THEN
        IF  p_project_type_class_code = 'INDIRECT'  --will be defaulted to the billable_flag of the
        THEN    l_task_in_rec.billable_flag := 'N'; --parent_task for non top_level tasks
        ELSE    l_task_in_rec.billable_flag := 'Y'; --in the second round
        END IF;
    END IF;

    IF l_task_in_rec.chargeable_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN l_task_in_rec.chargeable_flag := 'Y';
    END IF;

    IF l_task_in_rec.limit_to_txn_controls_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN l_task_in_rec.limit_to_txn_controls_flag := 'N';
    END IF;

    --Defaulting for task manager (same as task manager of the parent) is done in the second round.
    IF l_task_in_rec.task_manager_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
        l_task_in_rec.task_manager_person_id := NULL;
    END IF;


    --check whether this is the address of one of the project customers
/* dbms_output.put_line('Ref    : '||l_task_in_rec.pm_task_reference); */

    IF l_task_in_rec.address_id IS NOT NULL
    AND l_task_in_rec.address_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN

        OPEN l_customer_csr( p_project_rec.project_id );
        FETCH l_customer_csr INTO l_customer_id;

/* dbms_output.put_line('Customer: '||l_customer_id); */

        l_address_valid:= 'N';

        WHILE l_customer_csr%FOUND LOOP

            OPEN l_address_csr(l_customer_id, l_task_in_rec.address_id);
            FETCH l_address_csr INTO l_dummy;

            IF l_address_csr%FOUND
            THEN
                l_address_valid:= 'Y';
                EXIT;
                END IF;

                CLOSE l_address_csr;

                FETCH l_customer_csr INTO l_customer_id;
            END LOOP;

            CLOSE l_customer_csr;

        IF l_address_valid = 'N'
        THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_ADDRESS_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                    END IF;
                    RAISE  FND_API.G_EXC_ERROR;
        ELSE

                l_address_id := l_task_in_rec.address_id;
        END IF;


    ELSE
        l_address_id := NULL;
    END IF;

-- SERVICE_TYPE_CODE

       IF p_service_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_service_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_task_in_rec.service_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_service_type_code IS NOT NULL  --redundant, but added for clarity
       THEN

      OPEN l_service_type_csr( p_service_type_code );
      FETCH l_service_type_csr INTO l_temp;

      IF l_service_type_csr%NOTFOUND
      THEN

      CLOSE l_service_type_csr;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_SERVICE_TYPE_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
               END IF;
               RAISE  FND_API.G_EXC_ERROR;

      END IF;

      CLOSE l_service_type_csr;

     END IF;

-- Start fix for Bug #1335417

    IF  (l_task_in_rec.cost_ind_sch_fixed_date  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        AND (nvl(l_task_in_rec.cost_ind_sch_fixed_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
           <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        AND l_task_in_rec.cost_ind_sch_fixed_date IS NOT NULL  --redundant, but added for clarity
        THEN
           OPEN l_ind_rate_schedule_type_csr( l_task_in_rec.cost_ind_rate_sch_id);
           FETCH l_ind_rate_schedule_type_csr INTO l_temp_var_sch_type;
           IF l_temp_var_sch_type = 'P'
           THEN
                CLOSE l_ind_rate_schedule_type_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CANT_FIX_DATE_PROV_SCH'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
           CLOSE l_ind_rate_schedule_type_csr;
      END IF;

-- End fix for bug # 1335417


    --The following fields will be defaulted for non top_level tasks to be the same as their parent task
    --in the second ROUND.

        IF l_task_in_rec.service_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        OR l_task_in_rec.service_type_code IS NULL
        THEN
            l_task_in_rec.service_type_code := p_service_type_code; --defaulted from the project type
        END IF;
/* dbms_output.put_line('service_type_code: '||l_task_in_rec.service_type_code); */

/* dbms_output.put_line('org id (task rec): - before init- '||
                      to_char(l_task_in_rec.carrying_out_organization_id) ||
                     'org id of project rec before init- '||
                      to_char(p_project_rec.carrying_out_organization_id));
*/

        IF l_task_in_rec.carrying_out_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        OR l_task_in_rec.carrying_out_organization_id IS NULL
        THEN
            l_task_in_rec.carrying_out_organization_id := p_project_rec.carrying_out_organization_id;
        END IF;

/* dbms_output.put_line('Carrying out org id (task rec): '||l_task_in_rec.carrying_out_organization_id); */

               IF l_task_in_rec.task_description =
                  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
                  l_task_in_rec.task_description := NULL;
               END IF;
--  Call the client extension to override the default values for
--  project start/completion dates

 /*
       IF l_task_in_rec.actual_start_date IS NULL OR
          l_task_in_rec.actual_start_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_actual_start_date := NULL;
       ELSE
          l_actual_start_date := l_task_in_rec.actual_start_date;
       END IF;

       IF l_task_in_rec.actual_finish_date IS NULL OR
          l_task_in_rec.actual_finish_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_actual_finish_date := NULL;
       ELSE
          l_actual_finish_date := l_task_in_rec.actual_finish_date;
       END IF;
*/   --Task progress cahnegs : These dates should be passed from task progress and ignore from AMG

       l_actual_start_date := null;
       l_actual_finish_date := null;

       IF l_task_in_rec.early_start_date IS NULL OR
          l_task_in_rec.early_start_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_early_start_date := NULL;
       ELSE
          l_early_start_date := l_task_in_rec.early_start_date;
       END IF;


       IF l_task_in_rec.early_start_date IS NULL OR
          l_task_in_rec.early_start_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_early_start_date := NULL;
       ELSE
          l_early_start_date := l_task_in_rec.early_start_date;
       END IF;


       IF l_task_in_rec.early_finish_date IS NULL OR
          l_task_in_rec.early_finish_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_early_finish_date := NULL;
       ELSE
          l_early_finish_date := l_task_in_rec.early_finish_date;
       END IF;


       IF l_task_in_rec.late_start_date IS NULL OR
          l_task_in_rec.late_start_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_late_start_date := NULL;
       ELSE
          l_late_start_date := l_task_in_rec.late_start_date;
       END IF;

       IF l_task_in_rec.late_finish_date IS NULL OR
          l_task_in_rec.late_finish_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_late_finish_date := NULL;
       ELSE
          l_late_finish_date := l_task_in_rec.late_finish_date;
       END IF;

       IF l_task_in_rec.scheduled_start_date IS NULL OR
          l_task_in_rec.scheduled_start_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_scheduled_start_date := NULL;
       ELSE
          l_scheduled_start_date := l_task_in_rec.scheduled_start_date;
       END IF;

       IF l_task_in_rec.scheduled_finish_date IS NULL OR
          l_task_in_rec.scheduled_finish_date =
            PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
          l_scheduled_finish_date := NULL;
       ELSE
          l_scheduled_finish_date := l_task_in_rec.scheduled_finish_date;
       END IF;

       PA_Client_Extn_PM.customize_dates (
       p_pm_task_reference          => l_task_in_rec.pm_task_reference,
       p_pm_product_code            => p_project_rec.pm_product_code,
       p_in_start_date              => l_task_in_rec.task_start_date,
       p_in_completion_date         => l_task_in_rec.task_completion_date,
       p_actual_start_date          => l_actual_start_date,
       p_actual_finish_date         => l_actual_finish_date,
       p_early_start_date           => l_early_start_date,
       p_early_finish_date          => l_early_finish_date,
       p_late_start_date            => l_late_start_date,
       p_late_finish_date           => l_late_finish_date,
       p_scheduled_start_date       => l_scheduled_start_date,
       p_scheduled_finish_date      => l_scheduled_finish_date,
       p_out_start_date             => l_out_start_date,
       p_out_completion_date        => l_out_completion_date,
       p_error_code         => l_error_code,
       p_error_message          => l_error_message );

      IF l_error_code <> 0 THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_ERROR_IN_CLIENT_EXTN'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
         END IF;
         RAISE  FND_API.G_EXC_ERROR;
      END IF;
      l_task_in_rec.task_start_date := l_out_start_date;
      l_task_in_rec.task_completion_date := l_out_completion_date;

 --bug 2732788
      IF ( l_task_in_rec.task_start_date IS NULL  AND
           l_task_in_rec.task_completion_date IS NOT NULL )
      THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_ST_DATE_NULL'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
           END IF;
           RAISE  FND_API.G_EXC_ERROR;
      END IF;
 --bug 2732788

      IF ( l_task_in_rec.task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
         AND l_task_in_rec.task_start_date IS NOT NULL )
      THEN
         IF l_task_in_rec.task_completion_date
            <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
            l_task_in_rec.task_completion_date IS NOT NULL
         AND l_task_in_rec.task_completion_date < l_task_in_rec.task_start_date
         THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_DATES_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;

/* Bug#2530525-Commenting the condition which checks for date being null as project
start date should not be assigned when null is passed for the date variable */

     IF l_task_in_rec.task_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
/*           OR l_task_in_rec.task_start_date IS NULL Commented for bug#2530525 */
        THEN
    l_task_in_rec.task_start_date := p_project_rec.start_date;
     END IF;

     IF l_task_in_rec.task_completion_date =
        PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
/*          OR l_task_in_rec.task_completion_date IS NULL  Commented for bug#2530525 */
THEN
        l_task_in_rec.task_completion_date := p_project_rec.completion_date;
     END IF;

     IF l_task_in_rec.task_start_date < p_project_rec.start_date OR
        l_task_in_rec.task_start_date > p_project_rec.completion_date
        THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TK_OUTSIDE_PROJECT_RANGE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
     END IF;


     IF l_task_in_rec.task_completion_date < p_project_rec.start_date OR
        l_task_in_rec.task_completion_date > p_project_rec.completion_date
        THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TK_OUTSIDE_PROJECT_RANGE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
     END IF;

        IF l_task_in_rec.cost_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.cost_ind_rate_sch_id := p_project_rec.cost_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.cost_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.cost_ind_sch_fixed_date := p_project_rec.cost_ind_sch_fixed_date;
        END IF;

        IF l_task_in_rec.labor_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.labor_sch_type := p_project_rec.labor_sch_type;
        END IF;

        IF l_task_in_rec.labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.labor_bill_rate_org_id := p_project_rec.labor_bill_rate_org_id;
        END IF;

        IF l_task_in_rec.labor_std_bill_rate_schdl = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.labor_std_bill_rate_schdl := p_project_rec.labor_std_bill_rate_schdl;
        END IF;

        IF l_task_in_rec.labor_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.labor_schedule_discount := p_project_rec.labor_schedule_discount;
        END IF;

        IF l_task_in_rec.labor_schedule_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.labor_schedule_fixed_date := p_project_rec.labor_schedule_fixed_date;
        END IF;

        IF l_task_in_rec.non_labor_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.non_labor_sch_type := p_project_rec.non_labor_sch_type;
        END IF;

        IF l_task_in_rec.non_labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.non_labor_bill_rate_org_id := p_project_rec.non_labor_bill_rate_org_id;
        END IF;

        IF l_task_in_rec.non_labor_std_bill_rate_schdl = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.non_labor_std_bill_rate_schdl := p_project_rec.non_labor_std_bill_rate_schdl;
        END IF;

        IF l_task_in_rec.non_labor_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.non_labor_schedule_discount := p_project_rec.non_labor_schedule_discount;
        END IF;

        IF l_task_in_rec.non_labor_schedule_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.non_labor_schedule_fixed_date := p_project_rec.non_labor_schedule_fixed_date;
        END IF;

        IF l_task_in_rec.rev_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.rev_ind_rate_sch_id := p_project_rec.rev_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.rev_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.rev_ind_sch_fixed_date := p_project_rec.rev_ind_sch_fixed_date;
        END IF;

        IF l_task_in_rec.inv_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.inv_ind_rate_sch_id := p_project_rec.inv_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.inv_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.inv_ind_sch_fixed_date := p_project_rec.inv_ind_sch_fixed_date;
        END IF;
    --bug 6153503 added below if condition
    IF l_task_in_rec.tasks_dff = 'Y' THEN
     --When descriptive flex fields are not passed set them to NULL
     IF l_task_in_rec.attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute_category := NULL;
     ELSE
    l_attribute_category := l_task_in_rec.attribute_category;
     END IF;
     IF l_task_in_rec.attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute1 := NULL;
     ELSE
    l_attribute1 := l_task_in_rec.attribute1;
     END IF;
     IF l_task_in_rec.attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute2 := NULL;
     ELSE
    l_attribute2 := l_task_in_rec.attribute2;
     END IF;
     IF l_task_in_rec.attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute3 := NULL;
     ELSE
    l_attribute3 := l_task_in_rec.attribute3;
     END IF;
     IF l_task_in_rec.attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute4 := NULL;
     ELSE
    l_attribute4 := l_task_in_rec.attribute4;
     END IF;

     IF l_task_in_rec.attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute5 := NULL;
     ELSE
    l_attribute5 := l_task_in_rec.attribute5;
     END IF;

     IF l_task_in_rec.attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute6 := NULL;
     ELSE
    l_attribute6 := l_task_in_rec.attribute6;
     END IF;

     IF l_task_in_rec.attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute7 := NULL;
     ELSE
    l_attribute7 := l_task_in_rec.attribute7;
     END IF;

     IF l_task_in_rec.attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute8 := NULL;
     ELSE
    l_attribute8 := l_task_in_rec.attribute8;
     END IF;
     IF l_task_in_rec.attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute9 := NULL;
     ELSE
    l_attribute9 := l_task_in_rec.attribute9;
     END IF;
     IF l_task_in_rec.attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_attribute10 := NULL;
     ELSE
    l_attribute10 := l_task_in_rec.attribute10;
     END IF;

          --bug 6153503 added below validation.
         pa_task_utils.validate_flex_fields(
              p_desc_flex_name        => 'PA_TASKS_DESC_FLEX'
             ,p_attribute_category    => l_attribute_category
             ,p_attribute1            => l_attribute1
             ,p_attribute2            => l_attribute2
             ,p_attribute3            => l_attribute3
             ,p_attribute4            => l_attribute4
             ,p_attribute5            => l_attribute5
             ,p_attribute6            => l_attribute6
             ,p_attribute7            => l_attribute7
             ,p_attribute8            => l_attribute8
             ,p_attribute9            => l_attribute9
             ,p_attribute10           => l_attribute10
             ,p_RETURN_msg            => l_return_msg
             ,p_validate_status       => l_validate_status
             );

         IF l_validate_status = 'N'
            THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                      pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_INVALID_FF_VALUES'
                                ,p_msg_attribute    => 'CHANGE'
                                ,p_resize_flag      => 'N'
                                ,p_msg_context      => 'FLEX'
                                ,p_attribute1       => l_return_msg
                                ,p_attribute2       => ''
                                ,p_attribute3       => ''
                                ,p_attribute4       => ''
                                ,p_attribute5       => '');
                END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

-- Multi National Currency changes Starts ...

-- Get segment1 for AMG messages

   OPEN l_default_project_csr( l_project_id );
   FETCH l_default_project_csr
    INTO l_allow_cross_charge_flag,
         l_project_rate_date,
         l_project_rate_type,
         l_cc_process_labor_flag,
         l_labor_tp_schedule_id,
         l_labor_tp_fixed_date,
         l_cc_process_nl_flag,
         l_nl_tp_schedule_id,
         l_nl_tp_fixed_date,
         l_work_type_id,
         l_emp_bill_rate_schedule_id,
         l_job_bill_rate_schedule_id,
         l_taskfunc_cost_rate_type,
         l_taskfunc_cost_rate_date,
         l_non_lab_std_bill_rt_sch_id;
   CLOSE l_default_project_csr;

     IF l_task_in_rec.allow_cross_charge_flag <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
   l_allow_cross_charge_flag := l_task_in_rec.allow_cross_charge_flag;
     END IF;

     IF l_task_in_rec.project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
   l_project_rate_type := l_task_in_rec.project_rate_type;
     END IF;

     IF l_task_in_rec.project_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     THEN
   l_project_rate_date := l_task_in_rec.project_rate_date;
     END IF;

-- Multi National Currency changes Ends ...

-- IC_CHANGES Starts ...

     IF l_task_in_rec.cc_process_labor_flag <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
   l_cc_process_labor_flag := l_task_in_rec.cc_process_labor_flag;
     END IF;

     --Added NVL for Bug 6026370
     IF nvl( l_task_in_rec.labor_tp_schedule_id,-999) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_labor_tp_schedule_id := l_task_in_rec.labor_tp_schedule_id;
     END IF;

     --Added NVL for Bug 6026370
     IF nvl(l_task_in_rec.labor_tp_fixed_date,sysdate) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     THEN
      l_labor_tp_fixed_date := l_task_in_rec.labor_tp_fixed_date;
     END IF;

     IF l_task_in_rec.cc_process_nl_flag <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
   l_cc_process_nl_flag := l_task_in_rec.cc_process_nl_flag;
     END IF;

     --Added NVL for Bug 6026370
     IF nvl(l_task_in_rec.nl_tp_schedule_id,-999) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_nl_tp_schedule_id := l_task_in_rec.nl_tp_schedule_id;
     END IF;

     --Added NVL for Bug 6026370
     IF nvl(l_task_in_rec.nl_tp_fixed_date,sysdate) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     THEN
      l_nl_tp_fixed_date := l_task_in_rec.nl_tp_fixed_date;
     END IF;

     IF l_task_in_rec.receive_project_invoice_flag =
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
      l_receive_project_invoice_flag := 'N';
     ELSE
      l_receive_project_invoice_flag := l_task_in_rec.receive_project_invoice_flag;
     END IF;

     IF l_task_in_rec.work_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_work_type_id := l_task_in_rec.work_type_id;
     END IF;

-- IC_CHANGES Ends ...

     IF l_task_in_rec.emp_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_emp_bill_rate_schedule_id := l_task_in_rec.emp_bill_rate_schedule_id;
     END IF;

     IF l_task_in_rec.job_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_job_bill_rate_schedule_id := l_task_in_rec.job_bill_rate_schedule_id;
     END IF;

--Sakthi MCB

     IF l_task_in_rec.non_lab_std_bill_rt_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_non_lab_std_bill_rt_sch_id := l_task_in_rec.non_lab_std_bill_rt_sch_id;
     END IF;

    IF l_task_in_rec.taskfunc_cost_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     THEN
      l_taskfunc_cost_rate_date := l_task_in_rec.taskfunc_cost_rate_date;
     END IF;

     IF l_task_in_rec.taskfunc_cost_rate_type <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
   l_taskfunc_cost_rate_type := l_task_in_rec.taskfunc_cost_rate_type;
     END IF;

--Sakthi MCB

     IF l_task_in_rec.labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_labor_disc_reason_code := l_task_in_rec.labor_disc_reason_code;
     END IF;

     IF l_task_in_rec.non_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
      l_non_labor_disc_reason_code := l_task_in_rec.non_labor_disc_reason_code;
     END IF;


--PA L Changes 2872708

     IF l_task_in_rec.retirement_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_retirement_cost_flag := l_task_in_rec.retirement_cost_flag;
     END IF;

     IF l_task_in_rec.cint_eligible_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_cint_eligible_flag := l_task_in_rec.cint_eligible_flag;
     END IF;

     IF l_task_in_rec.cint_stop_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     THEN
        l_cint_stop_date := l_task_in_rec.cint_stop_date;
     END IF;

--End PA L Changes 2872708

--(Begin Venkat) FP_M changes -------------------------------------

     IF l_task_in_rec.invoice_method <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_invoice_method := l_task_in_rec.invoice_method;
     END IF;

   /* Commented For Bug 4689326
     IF l_task_in_rec.customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
        l_customer_id1 := l_task_in_rec.customer_id;
     END IF;*/
     --null check added , BUg # 4101696, rtarway
     IF l_task_in_rec.gen_etc_source_code is not null and
        l_task_in_rec.gen_etc_source_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
        l_gen_etc_source_code := l_task_in_rec.gen_etc_source_code;
     --BUG 3924597, added by rtarway for etc source default
     else
          --Add the logic to default the gen_etc_source_code
          --1. get the structure sharing type
             l_wp_separate_from_fin := PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN( l_project_id );
          --2. get if it is top task, assuming for top task, p_pa_parent_task_id/P_pm_parent_task_reference is null
             if (
                  (     l_task_in_rec.pa_parent_task_id is null
                    or  l_task_in_rec.pa_parent_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                  )
                 and
                 (   l_task_in_rec.pm_parent_task_reference is null
                  or l_task_in_rec.pm_parent_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 )
                )
             then
                 if (nvl(l_wp_separate_from_fin,'N') = 'N')
                 then
                     l_gen_etc_source_code := 'WORKPLAN_RESOURCES';
                 else
                     l_gen_etc_source_code := 'FINANCIAL_PLAN';
                 end if;
             else
                 --if not top task , get the l_gen_etc_source_code from its parent task
                      if l_task_in_rec.pa_parent_task_id is not null
                      then
                          l_ref_task_id  :=  l_task_in_rec.pa_parent_task_id ;
                      elsif (
                      l_task_in_rec.pm_parent_task_reference is not null
                      and l_task_in_rec.pm_parent_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                      )
                      then
                              -- 5262740 Changed Convert_pm_taskref_to_id to PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                              PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
                             ( p_pa_project_id => l_project_id
                             , p_pa_task_id    => l_task_in_rec.pa_parent_task_id
                             , p_pm_task_reference  => l_task_in_rec.pm_parent_task_reference
                             , p_out_task_id      => l_ref_task_id
                             , p_return_status => l_return_status    );
                             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                             THEN
                                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                             END IF;
                      end if;
                      OPEN get_gen_etc_source_code(l_ref_task_id,l_project_id );
                      FETCH  get_gen_etc_source_code into l_gen_etc_source_code;
                      CLOSE get_gen_etc_source_code;
                      if (l_gen_etc_source_code is null or l_gen_etc_source_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
                      then
                           if (nvl(l_wp_separate_from_fin,'N') = 'N')
                           then
                               l_gen_etc_source_code := 'WORKPLAN_RESOURCES';
                           else
                               l_gen_etc_source_code := 'FINANCIAL_PLAN';
                           end if;
                      end if;
             end if;
     --End  BUG 3924597, added by rtarway for etc source default
     END IF;
--(End Venkat) FP_M changes ---------------------------------------
--( Begin Changes by rtarway for BUG 3658479 )
     -- Bug No 3798594 Added elsif to the following if block
     IF   l_task_in_rec.labor_cost_multiplier_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
         l_labor_cost_multiplier_name := l_task_in_rec.labor_cost_multiplier_name ;
     ELSIF(l_task_in_rec.labor_cost_multiplier_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR  l_task_in_rec.labor_cost_multiplier_name is null) THEN
-- Bug No 4609326  Added 'or' condition
     l_labor_cost_multiplier_name := null;
     END IF;
--( End Changes by rtarway for BUG 3658479 )



     --get the unique task id from the Oracle Sequence

    SELECT pa_tasks_s.nextval
    INTO l_task_id
    FROM DUAL;
/* dbms_output.put_line('Task ID:'||l_task_id); */

    --insert the intermediate result in the database

/* dbms_output.put_line('Task Ref:'||l_task_in_rec.pm_task_reference); */
/* dbms_output.put_line('Task Name:'||l_task_in_rec.task_name); */

     --Bug 3279981
     --The revenue acrual method for the task needs to be defaulted from the project
     --Default the invoice method if it has not been passed as a parameter
     --Set the customer_id if it has not been passed as a parameter
     OPEN  cur_get_rev_acc_mth;
     FETCH cur_get_rev_acc_mth INTO l_revenue_accrual_method;
     CLOSE cur_get_rev_acc_mth;

     IF l_task_in_rec.invoice_method = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        l_task_in_rec.invoice_method IS Null THEN --For bug 4273729
          OPEN  cur_get_inv_mth;
          FETCH cur_get_inv_mth INTO l_invoice_method;
          CLOSE cur_get_inv_mth;
     END IF;

     /* Commented for Bug 4689326
     IF l_task_in_rec.customer_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          OPEN  cur_get_def_top_task_cust;
          FETCH cur_get_def_top_task_cust INTO l_customer_id1;
          CLOSE cur_get_def_top_task_cust;
     END IF;*/
     -- Start of Bug Number 4689326 Added this Part of Code
     -- to check its a parent task or child task and to add customers accodingly.
     IF (l_task_in_rec.pa_parent_task_id IS NULL OR
         l_task_in_rec.pa_parent_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
        (l_task_in_rec.pm_parent_task_reference is NULL OR
            l_task_in_rec.pm_parent_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          IF l_task_in_rec.customer_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
             OPEN  cur_get_def_top_task_cust;
             FETCH cur_get_def_top_task_cust INTO l_customer_id1;
             CLOSE cur_get_def_top_task_cust;
          ELSE
          l_customer_id1 := l_task_in_rec.customer_id;
          END IF;
     ELSE
                 OPEN l_customer_parent_task(l_task_in_rec.pa_parent_task_id);
                 FETCH l_customer_parent_task INTO l_customer_id1;
                 CLOSE l_customer_parent_task;
     END IF;
-- End of Bug Number 4689326 .
-- Start of Addition for Bug 4378507.

 IF (l_task_in_rec.pa_parent_task_id IS NOT NULL
    AND l_task_in_rec.pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)     OR
    (l_task_in_rec.pm_parent_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND l_task_in_rec.pm_parent_task_reference IS NOT NULL)
    THEN
      IF(l_task_in_rec.pm_parent_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      AND l_task_in_rec.pm_parent_task_reference IS NOT NULL)
      THEN
        OPEN l_task_csr(p_project_rec.project_id,l_task_in_rec.pm_parent_task_reference);
        FETCH l_task_csr INTO l_parent_TOP_TASK_ID;

        IF l_task_csr%NOTFOUND
        THEN
            CLOSE l_task_csr;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
            CLOSE l_task_csr;
      ELSE
            IF (l_task_in_rec.pa_parent_task_id IS NOT NULL AND
                   l_task_in_rec.pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                THEN
                OPEN l_task_id_csr(p_project_rec.project_id,l_task_in_rec.pa_parent_task_id);
            FETCH l_task_id_csr INTO l_parent_TOP_TASK_ID;  --l_parent_task_id_rec;
            IF l_task_id_csr%NOTFOUND
            THEN
                CLOSE l_task_id_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                         pa_interface_utils_pub.map_new_amg_msg
                          ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
                           ,p_msg_attribute    => 'CHANGE'
                           ,p_resize_flag      => 'N'
                           ,p_msg_context      => 'TASK'
                           ,p_attribute1       => l_amg_segment1
                           ,p_attribute2       => l_amg_task_number
                           ,p_attribute3       => ''
                           ,p_attribute4       => ''
                           ,p_attribute5       => '');
                  END IF;
                  RAISE  FND_API.G_EXC_ERROR;
             END IF;
                CLOSE l_task_id_csr;
            Else
           l_parent_TOP_TASK_ID := l_task_id;
            END IF;
        END IF ;
    Else
       l_parent_TOP_TASK_ID := l_task_id;
    END IF;

    -- End of Addition for Bug 4378507.

    INSERT INTO pa_tasks
    (           task_id
               ,project_id
           ,pm_task_reference
               ,task_number
               ,task_name
               ,long_task_name
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,wbs_level
               ,top_task_id
               ,parent_task_id
           ,address_id
               ,ready_to_bill_flag
               ,ready_to_distribute_flag
               ,billable_flag
               ,chargeable_flag
               ,limit_to_txn_controls_flag
               ,description
               ,service_type_code
               ,task_manager_person_id
               ,carrying_out_organization_id
               ,start_date
               ,completion_date
               ,labor_std_bill_rate_schdl
               ,labor_bill_rate_org_id
               ,labor_schedule_fixed_date
               ,labor_schedule_discount
               ,non_labor_std_bill_rate_schdl
               ,non_labor_bill_rate_org_id
               ,non_labor_schedule_fixed_date
               ,non_labor_schedule_discount
           ,cost_ind_rate_sch_id
               ,rev_ind_rate_sch_id
               ,inv_ind_rate_sch_id
               ,cost_ind_sch_fixed_date
               ,rev_ind_sch_fixed_date
               ,inv_ind_sch_fixed_date
               ,labor_sch_type
               ,non_labor_sch_type
                   ,attribute_category
                   ,attribute1
                   ,attribute2
                   ,attribute3
                   ,attribute4
                   ,attribute5
                   ,attribute6
                   ,attribute7
                   ,attribute8
                   ,attribute9
                   ,attribute10
                   ,allow_cross_charge_flag
                   ,project_rate_type
                   ,project_rate_date
                      ,pm_product_code
                   ,actual_start_date
                   ,actual_finish_date
                   ,early_start_date
                   ,early_finish_date
                   ,late_start_date
                   ,late_finish_date
                   ,scheduled_start_date
                   ,scheduled_finish_date
                   ,cc_process_labor_flag
                   ,labor_tp_schedule_id
                   ,labor_tp_fixed_date
                   ,cc_process_nl_flag
                   ,nl_tp_schedule_id
                   ,nl_tp_fixed_date
                   ,receive_project_invoice_flag
                   ,work_type_id
                   ,emp_bill_rate_schedule_id
                   ,job_bill_rate_schedule_id
                   ,non_lab_std_bill_rt_sch_id
                   ,taskfunc_cost_rate_type
                   ,taskfunc_cost_rate_date
                   ,labor_disc_reason_code
                   ,non_labor_disc_reason_code
--PA L 2872708
                   ,retirement_cost_flag
                   ,cint_eligible_flag
                   ,cint_stop_date
--PA L 2872708

--(Begin Venkat) FP_M changes --------------------------------
           ,revenue_accrual_method
           ,invoice_method
                   ,customer_id
                   ,gen_etc_source_code
--(End Venkat) FP_M changes --------------------------------
--(Begin Rtarway)
                  , LABOR_COST_MULTIPLIER_NAME
                  , RECORD_VERSION_NUMBER
--(End rtarway)


)
    VALUES
    (       l_task_id
           ,l_project_id
           ,rtrim(l_task_in_rec.pm_task_reference)
              ,substrb(rtrim(l_task_in_rec.pa_task_number),1,25) -- bug 6193314 . added substrb
           ,substrb(rtrim(l_task_in_rec.task_name),1,20)      -- bug 6193314 . added substrb
           ,rtrim(l_task_in_rec.long_task_name)
           ,sysdate
           ,fnd_global.user_id
           ,sysdate
           ,fnd_global.user_id
           ,fnd_global.login_id
           ,l_wbs_level         --wbs_level will be updated in the 2 round.
       ,l_parent_TOP_TASK_ID -- top task id is updated in this  round itself Bug 4378507
           --,l_task_id           -- Commented for Bug 4378507 top task id will be updated in the 2 round.
           ,null            --parent task id, will be updated in the 2 round
           ,l_address_id
           ,l_task_in_rec.ready_to_bill_flag
           ,l_task_in_rec.ready_to_distribute_flag
           ,l_task_in_rec.billable_flag
           ,l_task_in_rec.chargeable_flag
           ,l_task_in_rec.limit_to_txn_controls_flag
           ,rtrim(l_task_in_rec.task_description)
           ,l_task_in_rec.service_type_code
           ,l_task_in_rec.task_manager_person_id
           ,l_task_in_rec.carrying_out_organization_id
           ,l_task_in_rec.task_start_date
           ,l_task_in_rec.task_completion_date
           ,l_task_in_rec.labor_std_bill_rate_schdl
           ,l_task_in_rec.labor_bill_rate_org_id
           ,l_task_in_rec.labor_schedule_fixed_date
           ,l_task_in_rec.labor_schedule_discount
           ,l_task_in_rec.non_labor_std_bill_rate_schdl
           ,l_task_in_rec.non_labor_bill_rate_org_id
           ,l_task_in_rec.non_labor_schedule_fixed_date
           ,l_task_in_rec.non_labor_schedule_discount
           ,l_task_in_rec.cost_ind_rate_sch_id
           ,l_task_in_rec.rev_ind_rate_sch_id
           ,l_task_in_rec.inv_ind_rate_sch_id
           ,l_task_in_rec.cost_ind_sch_fixed_date
           ,l_task_in_rec.rev_ind_sch_fixed_date
           ,l_task_in_rec.inv_ind_sch_fixed_date
           ,l_task_in_rec.labor_sch_type
           ,l_task_in_rec.non_labor_sch_type
                   ,rtrim(l_attribute_category)
                   ,rtrim(l_attribute1)
                   ,rtrim(l_attribute2)
                   ,rtrim(l_attribute3)
                   ,rtrim(l_attribute4)
                   ,rtrim(l_attribute5)
                   ,rtrim(l_attribute6)
                   ,rtrim(l_attribute7)
                   ,rtrim(l_attribute8)
                   ,rtrim(l_attribute9)
                   ,rtrim(l_attribute10)
                   ,l_allow_cross_charge_flag
                   ,l_project_rate_type
                   ,l_project_rate_date
           ,p_project_rec.pm_product_code
                   ,l_actual_start_date
                   ,l_actual_finish_date
                   ,l_early_start_date
                   ,l_early_finish_date
                   ,l_late_start_date
                   ,l_late_finish_date
                   ,l_scheduled_start_date
                   ,l_scheduled_finish_date
                   ,l_cc_process_labor_flag
                   ,l_labor_tp_schedule_id
                   ,l_labor_tp_fixed_date
                   ,l_cc_process_nl_flag
                   ,l_nl_tp_schedule_id
                   ,l_nl_tp_fixed_date
                   ,l_receive_project_invoice_flag
                   ,l_work_type_id
                   ,l_emp_bill_rate_schedule_id
                   ,l_job_bill_rate_schedule_id
                   ,l_non_lab_std_bill_rt_sch_id
                   ,l_taskfunc_cost_rate_type
                   ,l_taskfunc_cost_rate_date
                   ,l_labor_disc_reason_code
                   ,l_non_labor_disc_reason_code
--PA L 2872708
                   ,l_retirement_cost_flag
                   ,l_cint_eligible_flag
                   ,l_cint_stop_date
--PA L 2872708

--(Begin Venkat) FP_M changes --------------------------------
                   ,l_revenue_accrual_method
                   ,l_invoice_method
                   ,l_customer_id1
                   ,l_gen_etc_source_code
--(End Venkat) FP_M changes --------------------------------
--(Begin Rtarway, 3658479)
                  , l_labor_cost_multiplier_name
                  , 1
--(End rtarway , 3658479)
                     );
    p_task_id := l_task_id;

EXCEPTION
    /* Added for Bug 6497559 */
    WHEN DUP_VAL_ON_INDEX THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        IF p_project_rec.pm_product_code = 'MSPROJECT'
        THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NOT_NUM_UNIQ_MSP',
                               p_token1 => 'TASK_NAME',
                               p_value1 => l_task_in_rec.task_name,
                               p_token2 => 'TASK_NUMBER',
                               p_value2 => l_task_in_rec.pa_task_number
                              );
          raise FND_API.G_EXC_ERROR;
        ELSE
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_PS_TASK_NOT_NUM_UNIQ_AMG',
                               p_token1 => 'TASK_ID',
                               p_value1 => l_task_id
                              );
          raise FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */
    ROLLBACK TO add_task_round_one_pvt;
    p_return_status := FND_API.G_RET_STS_ERROR;
     -- 4537865 RESET OUT PARAMS
    p_task_id := NULL ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */
    ROLLBACK TO add_task_round_one_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- 4537865 RESET OUT PARAMS
    p_task_id := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */
    ROLLBACK TO add_task_round_one_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- 4537865 RESET OUT PARAMS
    p_task_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END add_task_round_one;

--====================================================================================
--Name:               add_task_round_two
--Type:               Procedure
--Description:        This procedure can be used to add a task to a new or already
--            existing project. This procedure should always be used together
--            with add_task_round_one.
--
--
--Called subprograms: none
--
--
--
--History:
--    15-AUG-1996        L. de Werker    Created
--    28-MAY-1999    ODEO            Fixed the three bugs mentioned in header
--
PROCEDURE add_task_round_two
(p_return_status            OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy hint
,p_project_rec              IN  pa_projects%rowtype
,p_task_id              IN  NUMBER
,p_task_rec             IN  pa_project_pub.task_in_rec_type
--Project Structures
,p_ref_task_id                          IN      NUMBER
,p_tasks_in                             IN      pa_project_pub.task_in_tbl_type
,p_tasks_out                            IN      pa_project_pub.task_out_tbl_type
,p_task_version_id                      OUT     NOCOPY NUMBER -- 4537865 Added nocopy hint
,p_create_task_structure                IN      VARCHAR2          -- Added new parameter for performance changes. Bug 2931183
--Project Structures
    )

IS

   --needed to get data of a task using project_id and task_reference.

   CURSOR   l_task_csr
        (p_project_id NUMBER
        ,p_pm_task_reference VARCHAR2)
   IS
   SELECT   *
   FROM     pa_tasks t
   WHERE    t.project_id = p_project_id
   AND      t.pm_task_reference = p_pm_task_reference;

   --*O
   CURSOR   l_task_id_csr
        (p_project_id NUMBER
        ,p_task_id NUMBER)
   IS
   SELECT   *
   FROM     pa_tasks t
   WHERE    t.project_id = p_project_id
   AND      t.task_id = p_task_id;


   l_api_name           CONSTANT    VARCHAR2(30)        := 'add_task_round_two';
   l_parent_task_rec        l_task_csr%rowtype;
   l_task_id            NUMBER;

   -- 4537865
   l_new_task_id            NUMBER;

   l_task_in_rec        pa_project_pub.task_in_rec_type;
   l_wbs_level          NUMBER :=1;
   l_project_id         NUMBER;
   l_top_task_id        NUMBER;
   l_parent_task_id     NUMBER;
   l_customer_id        NUMBER;                       /* added variable for bug 7495993*/
--   l_address_id           NUMBER;  --address does not get inherited
l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--bug 6153503 added below variables
l_validate_dff               VARCHAR2(1);
l_attribute_category             VARCHAR2(30);
l_attribute1                 VARCHAR2(150);
l_attribute2                 VARCHAR2(150);
l_attribute3                 VARCHAR2(150);
l_attribute4                 VARCHAR2(150);
l_attribute5                 VARCHAR2(150);
l_attribute6                 VARCHAR2(150);
l_attribute7                 VARCHAR2(150);
l_attribute8                 VARCHAR2(150);
l_attribute9                 VARCHAR2(150);
l_attribute10                VARCHAR2(150);
l_attribute11                 VARCHAR2(150);
l_attribute12                 VARCHAR2(150);
l_attribute13                 VARCHAR2(150);
l_attribute14                 VARCHAR2(150);
l_attribute15                 VARCHAR2(150);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT add_task_round_two_pvt;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --copy the incoming parameters to local variables
    l_task_in_rec   := p_task_rec;
    l_task_id   := p_task_id;
    l_project_id    := p_project_rec.project_id;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> l_task_in_rec.task_name
    ,p_task_reference => l_task_in_rec.pm_task_reference
    ,p_task_id => l_task_id);

    --get the task data of the parent task when task is not top task
    -- *O
    IF (l_task_in_rec.pa_parent_task_id IS NOT NULL
    AND l_task_in_rec.pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)     OR
    (l_task_in_rec.pm_parent_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND l_task_in_rec.pm_parent_task_reference IS NOT NULL)
    THEN
      IF(l_task_in_rec.pm_parent_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      AND l_task_in_rec.pm_parent_task_reference IS NOT NULL)
      THEN
        OPEN l_task_csr(p_project_rec.project_id,l_task_in_rec.pm_parent_task_reference);
        FETCH l_task_csr INTO l_parent_task_rec;

        IF l_task_csr%NOTFOUND
        THEN
            CLOSE l_task_csr;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
                    END IF;
                    RAISE  FND_API.G_EXC_ERROR;
            END IF;
            CLOSE l_task_csr;
           ELSE
            IF (l_task_in_rec.pa_parent_task_id IS NOT NULL AND
                   l_task_in_rec.pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                THEN
                OPEN l_task_id_csr(p_project_rec.project_id,l_task_in_rec.pa_parent_task_id);
            FETCH l_task_id_csr INTO l_parent_task_rec;  --l_parent_task_id_rec;

            IF l_task_id_csr%NOTFOUND
            THEN
                CLOSE l_task_id_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                         pa_interface_utils_pub.map_new_amg_msg
                          ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
                           ,p_msg_attribute    => 'CHANGE'
                           ,p_resize_flag      => 'N'
                           ,p_msg_context      => 'TASK'
                           ,p_attribute1       => l_amg_segment1
                           ,p_attribute2       => l_amg_task_number
                           ,p_attribute3       => ''
                           ,p_attribute4       => ''
                           ,p_attribute5       => '');
                        END IF;
                        RAISE  FND_API.G_EXC_ERROR;
                END IF;
                CLOSE l_task_id_csr;
                --l_parent_task_rec := l_parent_task_id_rec; -- assign to this rec, because rest of code uses this
            END IF;
        END IF ;
          END IF;

    --make a distinction between "top level tasks" and "non top level tasks"
    -- *O

    IF (l_task_in_rec.pa_parent_task_id IS NULL
    OR l_task_in_rec.pa_parent_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  AND
    (l_task_in_rec.pm_parent_task_reference IS NULL
    OR l_task_in_rec.pm_parent_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
        l_wbs_level         := 1;
        l_top_task_id       := l_task_id;
        l_parent_task_id    := NULL;

        IF l_task_in_rec.ready_to_bill_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        OR l_task_in_rec.ready_to_bill_flag IS NULL
        THEN l_task_in_rec.ready_to_bill_flag := 'Y';
        END IF;

        IF l_task_in_rec.ready_to_distribute_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        OR l_task_in_rec.ready_to_distribute_flag IS NULL
        THEN l_task_in_rec.ready_to_distribute_flag := 'Y';
        END IF;


        UPDATE PA_TASKS
        SET
         wbs_level          = l_wbs_level
        ,top_task_id            = l_top_task_id
        ,parent_task_id         = l_parent_task_id
        ,ready_to_bill_flag     = l_task_in_rec.ready_to_bill_flag
        ,ready_to_distribute_flag   = l_task_in_rec.ready_to_distribute_flag
        WHERE project_id = l_project_id
        AND task_id = l_task_id;

    ELSE

        l_wbs_level         := l_parent_task_rec.wbs_level + 1;
        l_top_task_id       := l_parent_task_rec.top_task_id;
        l_parent_task_id    := l_parent_task_rec.task_id;

        select customer_id into l_customer_id
        from pa_tasks where task_id =l_parent_task_id;                      /* added for bug 7495993 */

        IF l_task_in_rec.service_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        OR l_task_in_rec.service_type_code IS NULL
        THEN
            l_task_in_rec.service_type_code :=
                        l_parent_task_rec.service_type_code;
        END IF;

        IF l_task_in_rec.billable_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.billable_flag :=
                        l_parent_task_rec.billable_flag;
        END IF;

        IF l_task_in_rec.task_manager_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.task_manager_person_id :=
                        l_parent_task_rec.task_manager_person_id;
        END IF;

        IF l_task_in_rec.carrying_out_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        OR l_task_in_rec.carrying_out_organization_id IS NULL
        THEN
            l_task_in_rec.carrying_out_organization_id :=
                        l_parent_task_rec.carrying_out_organization_id;
        END IF;

        IF l_task_in_rec.task_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.task_start_date := l_parent_task_rec.start_date;
        END IF;

        IF l_task_in_rec.task_completion_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.task_completion_date := l_parent_task_rec.completion_date;
        END IF;

        IF l_task_in_rec.cost_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.cost_ind_rate_sch_id := l_parent_task_rec.cost_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.cost_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.cost_ind_sch_fixed_date := l_parent_task_rec.cost_ind_sch_fixed_date;
        END IF;

--      l_address_id := l_parent_task_rec.address_id;  --address does not get inherited

        IF l_task_in_rec.labor_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.labor_sch_type := l_parent_task_rec.labor_sch_type;
        END IF;

        IF l_task_in_rec.labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.labor_bill_rate_org_id := l_parent_task_rec.labor_bill_rate_org_id;
        END IF;

        IF l_task_in_rec.labor_std_bill_rate_schdl = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.labor_std_bill_rate_schdl := l_parent_task_rec.labor_std_bill_rate_schdl;
        END IF;

        IF l_task_in_rec.labor_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.labor_schedule_discount := l_parent_task_rec.labor_schedule_discount;
        END IF;

        IF l_task_in_rec.labor_schedule_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.labor_schedule_fixed_date := l_parent_task_rec.labor_schedule_fixed_date;
        END IF;

        IF l_task_in_rec.non_labor_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.non_labor_sch_type := l_parent_task_rec.non_labor_sch_type;
        END IF;

        IF l_task_in_rec.non_labor_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.non_labor_bill_rate_org_id := l_parent_task_rec.non_labor_bill_rate_org_id;
        END IF;

        IF l_task_in_rec.non_labor_std_bill_rate_schdl = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            l_task_in_rec.non_labor_std_bill_rate_schdl := l_parent_task_rec.non_labor_std_bill_rate_schdl;
        END IF;

        IF l_task_in_rec.non_labor_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.non_labor_schedule_discount := l_parent_task_rec.non_labor_schedule_discount;
        END IF;

        IF l_task_in_rec.non_labor_schedule_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.non_labor_schedule_fixed_date := l_parent_task_rec.non_labor_schedule_fixed_date;
        END IF;

        IF l_task_in_rec.rev_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.rev_ind_rate_sch_id := l_parent_task_rec.rev_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.rev_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.rev_ind_sch_fixed_date := l_parent_task_rec.rev_ind_sch_fixed_date;
        END IF;

        IF l_task_in_rec.inv_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
        THEN
            l_task_in_rec.inv_ind_rate_sch_id := l_parent_task_rec.inv_ind_rate_sch_id;
        END IF;

        IF l_task_in_rec.inv_ind_sch_fixed_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        THEN
            l_task_in_rec.inv_ind_sch_fixed_date :=
                        l_parent_task_rec.inv_ind_sch_fixed_date;
        END IF;
        --BUG 3924597 Added by rtarway for FP.M, etc_source defaulting changes
        --null check added , bug # 4101696, rtarway,
        --since gen_etc_source_code will never be null, we should default it in case it is passed as null.
        IF l_task_in_rec.gen_etc_source_code  is null OR
           l_task_in_rec.gen_etc_source_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        THEN
            if ( l_parent_task_rec.gen_etc_source_code is not null AND --BUG 4101696 , rtarway , or modified to and
                 l_parent_task_rec.gen_etc_source_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
            then l_task_in_rec.gen_etc_source_code :=
                        l_parent_task_rec.gen_etc_source_code;
            else
                 if (nvl (PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN ( l_project_id ), 'N') = 'N')
                 then
                  l_task_in_rec.gen_etc_source_code := 'WORKPLAN_RESOURCES';
                 else
                  l_task_in_rec.gen_etc_source_code := 'FINANCIAL_PLAN';
                 end if;
            end if;
        END IF;
        --End Add BUG 3924597 Added by rtarway for FP.M, etc_source defaulting changes

                /* Added following code to fix the bug # 878682 */
                /* This code was added to validate child task dates with its
                   parent task. Child Task should always fall in the date range
                   of its parent task. */

                IF l_task_in_rec.task_start_date < l_parent_task_rec.start_date OR
                    l_task_in_rec.task_start_date > l_parent_task_rec.completion_date

                THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                   pa_interface_utils_pub.map_new_amg_msg
                   ( p_old_message_code => 'PA_PARENT_START_LATER'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'TASK'
                     ,p_attribute1       => l_amg_segment1
                     ,p_attribute2       => l_amg_task_number
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
                END IF;

                IF l_task_in_rec.task_completion_date < l_parent_task_rec.start_date OR
                   l_task_in_rec.task_completion_date > l_parent_task_rec.completion_date

                 THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                     pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PARENT_COMPL_EARLIER'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'TASK'
                     ,p_attribute1       => l_amg_segment1
                     ,p_attribute2       => l_amg_task_number
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
                  END IF;
                  RAISE  FND_API.G_EXC_ERROR;
                END IF;

                /* Patch ends for the bug # 878682 */

        UPDATE  PA_TASKS
        SET
         wbs_level          = l_wbs_level
        ,top_task_id            = l_top_task_id
        ,parent_task_id         = l_parent_task_id
        ,billable_flag          = l_task_in_rec.billable_flag
        ,customer_id = l_customer_id                              /* added for bug 7495993*/
        ,service_type_code      = l_task_in_rec.service_type_code
        ,task_manager_person_id     = l_task_in_rec.task_manager_person_id
        ,carrying_out_organization_id   = l_task_in_rec.carrying_out_organization_id
        ,start_date         = l_task_in_rec.task_start_date
        ,completion_date        = l_task_in_rec.task_completion_date
        ,labor_std_bill_rate_schdl  = l_task_in_rec.labor_std_bill_rate_schdl
        ,labor_bill_rate_org_id     = l_task_in_rec.labor_bill_rate_org_id
        ,labor_schedule_fixed_date  = l_task_in_rec.labor_schedule_fixed_date
        ,labor_schedule_discount    = l_task_in_rec.labor_schedule_discount
        ,non_labor_std_bill_rate_schdl  = l_task_in_rec.non_labor_std_bill_rate_schdl
        ,non_labor_bill_rate_org_id = l_task_in_rec.non_labor_bill_rate_org_id
        ,non_labor_schedule_fixed_date  = l_task_in_rec.non_labor_schedule_fixed_date
        ,non_labor_schedule_discount    = l_task_in_rec.non_labor_schedule_discount
        ,cost_ind_rate_sch_id       = l_task_in_rec.cost_ind_rate_sch_id
        ,rev_ind_rate_sch_id        = l_task_in_rec.rev_ind_rate_sch_id
        ,inv_ind_rate_sch_id        = l_task_in_rec.inv_ind_rate_sch_id
        ,cost_ind_sch_fixed_date    = l_task_in_rec.cost_ind_sch_fixed_date
        ,rev_ind_sch_fixed_date     = l_task_in_rec.rev_ind_sch_fixed_date
        ,inv_ind_sch_fixed_date     = l_task_in_rec.inv_ind_sch_fixed_date
        ,labor_sch_type         = l_task_in_rec.labor_sch_type
        ,non_labor_sch_type         = l_task_in_rec.non_labor_sch_type
        ,gen_etc_source_code        = l_task_in_rec.gen_etc_source_code -- BUG 3924597 Added by rtarway for FP.M, etc_source defaulting changes
        WHERE project_id = l_project_id
        AND   task_id    = l_task_id;

-- Update chargeable_flag for parent if chargeable_flag = 'Y' since
-- we have now created a sub-task
               IF l_parent_task_rec.chargeable_flag = 'Y' THEN
                  UPDATE pa_tasks
                  SET chargeable_flag = 'N'
                  WHERE task_id =  l_parent_task_rec.task_id;
               END IF;

    END IF;  --distinction between top level tasks and non top level tasks

/* 4490532
    --bug 4279634
    --if a lowest level task has sub-projects then make the chargeable flag to 'N'
    IF PA_RELATIONSHIP_UTILS.check_task_has_sub_proj(l_project_id,l_task_id,null) = 'Y'
    THEN
        UPDATE pa_tasks
           SET chargeable_flag = 'N'
         WHERE task_id =  l_task_id;
    END IF;
    --end bug 4279634
*/

        --Project Structures Changes

     IF p_create_task_structure <> 'N' THEN -- Performance changes. Bug 2931183
                                      -- Donot do any structures processing in bulk calling context ie from create_project.
        DECLARE
            CURSOR cur_pa_tasks
            IS
              SELECT task_number, long_task_name, description,    --bug 2833194
                     parent_task_id,carrying_out_organization_id,
                     pm_task_reference, address_id, task_manager_person_id
                FROM pa_tasks
               WHERE project_id = l_project_id
                 AND task_id = l_task_id;

            l_pa_tasks_rec   cur_pa_tasks%ROWTYPE;
            v_task_id_above   NUMBER;
            l_msg_count       NUMBER ;
            l_msg_data        VARCHAR2(2000);
            l_return_status   VARCHAR2(1);

            l_last_index1      Number;
            l_first_index1      Number;

            l_index_number    number;
            l_task_version_id  NUMBER;
        BEGIN

            l_first_index1 := p_tasks_in.first;
            l_last_index1 := p_tasks_in.last;

        IF   l_first_index1 IS NOT NULL AND l_last_index1 IS NOT NULL
        THEN
            for i in l_first_index1..l_last_index1 loop

                IF l_task_id IS NOT NULL AND  p_tasks_out(i).pa_task_id IS NOT NULL AND
                   l_task_id = p_tasks_out(i).pa_task_id
                THEN
                    l_index_number := i;
                    exit;
                END IF;
            end loop;
        END IF;

--            IF p_ref_task_id IS NULL --called from create_project or update_proejct.
            IF l_task_id IS NOT NULL AND p_ref_task_id IS NULL AND
               l_first_index1 IS NOT NULL AND l_last_index1 IS NOT NULL --called from create_project or update_proejct.
            THEN
                IF l_index_number > l_first_index1 AND
                   p_tasks_in(l_index_number-1).pa_task_id IS NOT NULL AND
                   p_tasks_in(l_index_number-1).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                    --existing task becomes the ref_task_id
                THEN
                   v_task_id_above := p_tasks_in(l_index_number-1).pa_task_id;  --Get the task above.
                ELSIF l_index_number > l_first_index1 AND
                      p_tasks_out(l_index_number-1).pa_task_id IS NOT NULL AND
                      p_tasks_out(l_index_number-1).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
                        --new task becomes the ref_task_id
                THEN
                   v_task_id_above := p_tasks_out(l_index_number-1).pa_task_id;  --Get the task above created newly
                ELSIF  ( p_tasks_in(l_index_number).pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                         p_tasks_in(l_index_number).pa_task_id IS NULL
                          ) AND
                       l_index_number = l_first_index1
                THEN
                    v_task_id_above := null;  --ref is the structure version. structure version is
                                              --derived in PA_PROJ_TASK_STRUC_PUB.create_task_structure API.
                END IF;
            ELSE --Called from PA_PROJECT_PUB.ADD_TASK API.
                  v_task_id_above := p_ref_task_id;
            END IF;

            IF l_task_id IS NOT NULL
            THEN
                OPEN cur_pa_tasks;
                FETCH cur_pa_tasks INTO l_pa_tasks_rec;
                CLOSE cur_pa_tasks;

                --bug 6153503 added below code
                IF l_task_in_rec.tasks_dff = 'Y' THEN
                        l_validate_dff          := 'N';
                        l_attribute_category     := null;
                        l_attribute1             := null;
                        l_attribute2             := null;
                        l_attribute3             := null;
                        l_attribute4             := null;
                        l_attribute5             := null;
                        l_attribute6             := null;
                        l_attribute7             := null;
                        l_attribute8             := null;
                        l_attribute9             := null;
                        l_attribute10            := null;
                        l_attribute11            := null;
                        l_attribute12            := null;
                        l_attribute13            := null;
                        l_attribute14            := null;
                        l_attribute15            := null;

                ELSIF l_task_in_rec.tasks_dff = 'N' THEN

                        l_validate_dff           := 'Y';
                        l_attribute_category     := l_task_in_rec.attribute_category;
                        l_attribute1             := l_task_in_rec.attribute1;
                        l_attribute2             := l_task_in_rec.attribute2;
                        l_attribute3             := l_task_in_rec.attribute3;
                        l_attribute4             := l_task_in_rec.attribute4;
                        l_attribute5             := l_task_in_rec.attribute5;
                        l_attribute6             := l_task_in_rec.attribute6;
                        l_attribute7             := l_task_in_rec.attribute7;
                        l_attribute8             := l_task_in_rec.attribute8;
                        l_attribute9             := l_task_in_rec.attribute9;
                        l_attribute10            := l_task_in_rec.attribute10;
                        l_attribute11            := l_task_in_rec.attribute11;
                        l_attribute12            := l_task_in_rec.attribute12;
                        l_attribute13            := l_task_in_rec.attribute13;
                        l_attribute14            := l_task_in_rec.attribute14;
                        l_attribute15            := l_task_in_rec.attribute15;
                END IF;

                PA_PROJ_TASK_STRUC_PUB.CREATE_TASK_STRUCTURE(
                      p_calling_module               => 'AMG'
                     ,p_project_id                   => l_project_id
                     ,p_task_id                      => l_task_id
                     ,p_parent_task_id               => l_pa_tasks_rec.parent_task_id
                     ,p_ref_task_id                  => v_task_id_above
                     ,p_task_number                  => l_pa_tasks_rec.task_number
                     ,p_task_name                    => l_pa_tasks_rec.long_task_name   --bug 2833194
                     ,p_task_description             => l_pa_tasks_rec.description
                     ,p_carrying_out_organization_id => l_pa_tasks_rec.carrying_out_organization_id
                     ,p_structure_type               => 'FINANCIAL'
                     ,P_PM_SOURCE_CODE               => p_project_rec.pm_product_code
                     ,P_PM_SOURCE_reference          => l_pa_tasks_rec.pm_task_reference
                     ,p_location_id                  => l_pa_tasks_rec.address_id
                     ,p_manager_person_id            => l_pa_tasks_rec.task_manager_person_id
                     ,x_task_version_id              => l_task_version_id
                     ,x_task_id                      => l_new_task_id -- 4537865 Replaced l_task_id with l_new_task_id
                        --for shared structures
                        ,p_OBLIGATION_START_DATE        => l_task_in_rec.OBLIGATION_START_DATE
                        ,p_OBLIGATION_FINISH_DATE       => l_task_in_rec.OBLIGATION_FINISH_DATE
                        ,p_ESTIMATED_START_DATE         => l_task_in_rec.ESTIMATED_START_DATE
                        ,p_ESTIMATED_FINISH_DATE        => l_task_in_rec.ESTIMATED_FINISH_DATE
                        ,p_BASELINE_START_DATE          => l_task_in_rec.BASELINE_START_DATE
                        ,p_BASELINE_FINISH_DATE         => l_task_in_rec.BASELINE_FINISH_DATE
                        ,p_CLOSED_DATE                  => l_task_in_rec.CLOSED_DATE
                        ,p_WQ_UOM_CODE                  => l_task_in_rec.WQ_UOM_CODE
                        ,p_WQ_ITEM_CODE                 => l_task_in_rec.WQ_ITEM_CODE
                        ,p_STATUS_CODE                  => l_task_in_rec.STATUS_CODE
                        ,p_WF_STATUS_CODE               => l_task_in_rec.WF_STATUS_CODE
                        ,p_PRIORITY_CODE                => l_task_in_rec.PRIORITY_CODE
                        ,p_MILESTONE_FLAG               => l_task_in_rec.MILESTONE_FLAG
                        ,p_CRITICAL_FLAG                => l_task_in_rec.CRITICAL_FLAG
                        ,p_INC_PROJ_PROGRESS_FLAG       => l_task_in_rec.INC_PROJ_PROGRESS_FLAG
                        ,p_LINK_TASK_FLAG               => l_task_in_rec.LINK_TASK_FLAG
                        ,p_CALENDAR_ID                  => l_task_in_rec.CALENDAR_ID
                        ,p_PLANNED_EFFORT               => l_task_in_rec.PLANNED_EFFORT
                        ,p_DURATION                     => l_task_in_rec.DURATION
                        ,p_PLANNED_WORK_QUANTITY        => l_task_in_rec.PLANNED_WORK_QUANTITY
                        ,p_TASK_TYPE                    => l_task_in_rec.TASK_TYPE
                        ,p_actual_start_date                  => l_task_in_rec.actual_start_date
                        ,p_actual_finish_date                 => l_task_in_rec.actual_finish_date
                        ,p_early_start_date                   => l_task_in_rec.early_start_date
                        ,p_early_finish_date                  => l_task_in_rec.early_finish_date
                        ,p_late_start_date                    => l_task_in_rec.late_start_date
                        ,p_late_finish_date                   => l_task_in_rec.late_finish_date
                        ,p_scheduled_start_date               => l_task_in_rec.scheduled_start_date
                        ,p_scheduled_finish_date              => l_task_in_rec.scheduled_finish_date
-- (Begin venkat) new params for bug #3450684 ----------------------------------------------
            ,p_ext_act_duration         => l_task_in_rec.ext_act_duration
            ,p_ext_remain_duration      => l_task_in_rec.ext_remain_duration
            ,p_ext_sch_duration     => l_task_in_rec.ext_sch_duration
-- (End venkat) new params for bug #3450684 -------------------------------------------------

-- set the new params - bug #3654243 ----------------------------------------------
            ,p_base_percent_comp_deriv_code => l_task_in_rec.base_percent_comp_deriv_code
            ,p_sch_tool_tsk_type_code       => l_task_in_rec.sch_tool_tsk_type_code
            ,p_constraint_type_code         => l_task_in_rec.constraint_type_code
            ,p_constraint_date              => l_task_in_rec.constraint_date
            ,p_free_slack                   => l_task_in_rec.free_slack
            ,p_total_slack                  => l_task_in_rec.total_slack
            ,p_effort_driven_flag           => l_task_in_rec.effort_driven_flag
            ,p_level_assignments_flag       => l_task_in_rec.level_assignments_flag
            ,p_invoice_method               => l_task_in_rec.invoice_method
            ,p_customer_id                  => l_task_in_rec.customer_id
            ,p_gen_etc_source_code          => l_task_in_rec.gen_etc_source_code
-- set the new params - bug #3654243 -------------------------------------------------
                     --bug 6153503
                     ,p_validate_dff        => l_validate_dff
                     ,p_attribute_category  => l_attribute_category
                     ,p_attribute1          => l_attribute1
                     ,p_attribute2          => l_attribute2
                     ,p_attribute3          => l_attribute3
                     ,p_attribute4          => l_attribute4
                     ,p_attribute5          => l_attribute5
                     ,p_attribute6          => l_attribute6
                     ,p_attribute7          => l_attribute7
                     ,p_attribute8          => l_attribute8
                     ,p_attribute9          => l_attribute9
                     ,p_attribute10         => l_attribute10
                     ,p_attribute11         => l_attribute11
                     ,p_attribute12         => l_attribute12
                     ,p_attribute13         => l_attribute13
                     ,p_attribute14         => l_attribute14
                     ,p_attribute15         => l_attribute15
                     ,x_msg_count                    => l_msg_count
                     ,x_msg_data                     => l_msg_data
                     ,x_return_status                => l_return_status
                     );

        l_task_id := l_new_task_id ; -- 4537865
               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
               THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR
               THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
               p_task_version_id := l_task_version_id;

           END IF;
        END;
     END IF; -- p_create_task_structure <> 'N'  Performance change. Bug 2931183
        --Project Structures Changes


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */
    ROLLBACK TO add_task_round_two_pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_task_version_id := NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */
    ROLLBACK TO add_task_round_two_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_task_version_id := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */
    ROLLBACK TO add_task_round_two_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_task_version_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END add_task_round_two;

--====================================================================================
--
--Name:               fetch_project_id
--Type:               Function
--Description:        This function will return the project ID
--            when giving it the project reference
--
--
--Called subprograms: none
--
--
--
--History:
--    19-AUG-1996        R. Krishna.    Created
--
FUNCTION Fetch_project_id
(p_pm_project_reference IN VARCHAR2 ) RETURN NUMBER

IS

CURSOR c_projects_csr IS
SELECT project_id
FROM
pa_projects
WHERE
pm_project_reference = p_pm_project_reference;

l_project_rec      c_projects_csr%ROWTYPE;

BEGIN

      OPEN c_projects_csr;
      FETCH  c_projects_csr INTO l_project_rec.project_id;
      IF c_projects_csr%NOTFOUND THEN
         CLOSE c_projects_csr;
         RETURN NULL;
      ELSE
         CLOSE c_projects_csr;
         RETURN l_project_rec.project_id;
      END IF;

END Fetch_project_id;

--====================================================================================
--
--Name:               fetch_task_id
--Type:               Function
--Description:        This function will return the task ID
--            when giving it the task reference
--
--
--Called subprograms: none
--
--
--
--History:
--    19-AUG-1996        R. Krishna.    Created
--
FUNCTION Fetch_task_id
( p_pa_project_id        IN NUMBER
 ,p_pm_task_reference    IN VARCHAR2 ) RETURN NUMBER

IS

CURSOR c_task_csr IS
SELECT task_id
FROM
pa_tasks
WHERE project_id           = p_pa_project_id
AND   pm_task_reference    = p_pm_task_reference;

l_task_rec      c_task_csr%ROWTYPE;

BEGIN

      OPEN c_task_csr;
      FETCH  c_task_csr INTO l_task_rec.task_id;
      IF c_task_csr%NOTFOUND THEN
         CLOSE c_task_csr;
         RETURN NULL;
      ELSE
         CLOSE c_task_csr;
         RETURN l_task_rec.task_id;
      END IF;

END Fetch_task_id;

--====================================================================================
--Name:               convert_pm_projref_to_id
--Type:               Procedure
--Description:        This procedure can be used to converse
--            an incoming project reference to
--            a project ID.
--
--Called subprograms: none
--
--
--
--History:
--    19-AUG-1996        R. Krishna.    Created
--    02-DEC-1996    L de Werker    Removed value_not_used message
--                  Added validity check for project_id
--
PROCEDURE Convert_pm_projref_to_id
(p_pm_project_reference IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_pa_project_id        IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_out_project_id       OUT NOCOPY NUMBER -- 4537865 Added nocopy
,p_return_status        OUT NOCOPY VARCHAR2                ) -- 4537865 Added nocopy

IS

CURSOR  l_project_id_csr
IS
SELECT  'X'
FROM    pa_projects
where   project_id = p_pa_project_id;

l_api_name  CONSTANT    VARCHAR2(30) := 'Convert_pm_projref_to_id';
l_project_id            NUMBER ;
l_dummy             VARCHAR2(1);

BEGIN

    p_return_status :=  FND_API.G_RET_STS_SUCCESS;

    IF p_pa_project_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    AND p_pa_project_id IS NOT NULL
    THEN

        --check validity of this ID
        OPEN l_project_id_csr;
        FETCH l_project_id_csr INTO l_dummy;

        IF l_project_id_csr%NOTFOUND
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_PROJECT_ID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        CLOSE l_project_id_csr;
        RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE l_project_id_csr;
        p_out_project_id := p_pa_project_id;

    ELSIF  p_pm_project_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND p_pm_project_reference IS NOT NULL
    THEN
         l_project_id  :=  Fetch_project_id
                       (p_pm_project_reference => p_pm_project_reference);

         IF  l_project_id IS NULL
         THEN
             IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- bug 2257612
                FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Project Reference');
                FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_project_reference);
                FND_MSG_PUB.add;
              END IF;

              RAISE FND_API.G_EXC_ERROR;
         ELSE
                p_out_project_id := l_project_id;

         END IF;
     ELSE

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PROJECT_REF_AND_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

     END IF; -- If p_pa_project_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865
    p_out_project_id := NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865
    p_out_project_id := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865
    p_out_project_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END Convert_pm_projref_to_id;

--====================================================================================
--Name:               convert_pm_taskref_to_id
--Type:               Procedure
--Description:        This procedure can be used to converse
--            an incoming task reference to
--            a task ID.
--
--Called subprograms: none
--
--
--
--History:
--  19-AUG-1996 R. Krishna.     Created
--      02-DEC-1996 L. de Werker    Removed value_not_used message
--                  Added validation for project_id
--                  Added validation for task_id
--
Procedure Convert_pm_taskref_to_id (
 p_pa_project_id        IN NUMBER,
 p_pa_task_id           IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pm_task_reference    IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_out_task_id          OUT NOCOPY NUMBER,  -- 4537865
 p_return_status        OUT NOCOPY VARCHAR2 )  -- 4537865

IS

CURSOR  l_project_id_csr
IS
SELECT  'X'
FROM    pa_projects
where   project_id = p_pa_project_id;

CURSOR  l_task_id_csr
IS
SELECT  'X'
FROM    pa_tasks
WHERE   task_id = p_pa_task_id
AND     project_id = p_pa_project_id;


l_api_name  CONSTANT    VARCHAR2(30) := 'Convert_pm_taskref_to_id';
l_task_id                   NUMBER ;
l_dummy             VARCHAR2(1);
--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);

BEGIN

   p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_pa_project_id IS NOT NULL
   THEN

        OPEN l_project_id_csr;
        FETCH l_project_id_csr INTO l_dummy;

        IF l_project_id_csr%NOTFOUND
        THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_PROJECT_ID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
      END IF;

      CLOSE l_project_id_csr;
      RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE l_project_id_csr;
   ELSE

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PROJECT_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
    END IF;

    RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_pa_task_id IS NOT NULL
   THEN

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_pa_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

    OPEN l_task_id_csr;
    FETCH l_task_id_csr INTO l_dummy;

    IF l_task_id_csr%NOTFOUND
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_ID_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        CLOSE l_task_id_csr;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    CLOSE l_task_id_csr;

        p_out_task_id := p_pa_task_id;

    ELSIF p_pm_task_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND p_pm_task_reference IS NOT NULL
    THEN
         l_task_id  :=  Fetch_task_id
                       (p_pa_project_id     => p_pa_project_id,
                        p_pm_task_reference => p_pm_task_reference);
         IF  l_task_id IS NULL
         THEN
             IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Reference');
                FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_reference);
                FND_MSG_PUB.add;

        RAISE FND_API.G_EXC_ERROR;

              END IF;
         ELSE
                p_out_task_id := l_task_id;

         END IF;
     ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TASK_REF_AND_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'PROJ'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;

            RAISE FND_API.G_EXC_ERROR;

     END IF; -- If p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END Convert_pm_taskref_to_id;

--====================================================================================
--Name:               convert_pm_taskref_to_id
--Type:               Procedure
--Description:        This procedure can be used to converse
--            an incoming task reference to
--            a task ID.
--
--Called subprograms: none
--
--
--
--History:
--  19-AUG-1996 R. Krishna.     Created
--      02-DEC-1996 L. de Werker    Removed value_not_used message
--                  Added validation for project_id
--                  Added validation for task_id
--
Procedure Convert_pm_taskref_to_id_all (
 p_pa_project_id        IN NUMBER,
 p_structure_type       IN VARCHAR2 := 'FINANCIAL',
 p_pa_task_id           IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_pm_task_reference    IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_out_task_id          OUT NOCOPY NUMBER, -- 4537865 Added nocopy hint
 p_return_status        OUT NOCOPY VARCHAR2 ) -- 4537865 Added nocopy hint

IS

CURSOR  l_project_id_csr
IS
SELECT  'X'
FROM    pa_projects
where   project_id = p_pa_project_id;

CURSOR  l_task_id_csr
IS
SELECT  'X'
FROM    pa_tasks
WHERE   task_id = p_pa_task_id
AND     project_id = p_pa_project_id;

CURSOR  l_proj_element_id_csr
IS
SELECT  'X'
FROM    pa_proj_elements
WHERE   proj_element_id = p_pa_task_id
AND     project_id = p_pa_project_id;

CURSOR cur_pa_proj_elems
IS
  SELECT proj_element_id
    FROM pa_proj_elements
   WHERE PM_SOURCE_REFERENCE = p_pm_task_reference
     AND project_id = p_pa_project_id
    AND parent_structure_id = ( SELECT ppe.proj_element_id   --Added this subQry for bug#3653517
                                FROM   pa_proj_elements ppe,
                                       pa_proj_structure_types ppst,
                                       pa_structure_types pst
                                WHERE  ppe.proj_element_id = ppst.proj_element_id
                                AND    ppe.project_id = p_pa_project_id
                                AND    ppst.structure_type_id = pst.structure_type_id
                                AND    pst.structure_type = p_structure_type)
     AND OBJECT_TYPE = 'PA_TASKS';

l_api_name  CONSTANT    VARCHAR2(30) := 'Convert_pm_taskref_to_id_all';
l_task_id                   NUMBER ;
l_dummy             VARCHAR2(1);
--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);
   --Added by rtarway for BUG 3919800
   l_project_sharing_type VARCHAR2(250);

BEGIN

   p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   IF p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_pa_project_id IS NOT NULL
   THEN

        OPEN l_project_id_csr;
        FETCH l_project_id_csr INTO l_dummy;

        IF l_project_id_csr%NOTFOUND
        THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_PROJECT_ID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
      END IF;

      CLOSE l_project_id_csr;
      RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE l_project_id_csr;
   ELSE

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PROJECT_ID_MISSING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
    END IF;

    RAISE FND_API.G_EXC_ERROR;

   END IF;

   IF (p_structure_type = 'FINANCIAL') THEN

      --Added by rtarway, for BUG 3919800
      --Get the structure sharing type, if its partial shared structure, check for the task in
      --pa_proj_elements too.

      l_project_sharing_type := PA_PROJ_TASK_STRUC_PUB.GET_SHARE_TYPE(p_pa_project_id);

      IF p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      AND p_pa_task_id IS NOT NULL
      THEN

   -- Get segment1 for AMG messages

      OPEN l_amg_project_csr( p_pa_project_id );
      FETCH l_amg_project_csr INTO l_amg_segment1;
      CLOSE l_amg_project_csr;

        OPEN l_task_id_csr;
        FETCH l_task_id_csr INTO l_dummy;

        IF l_task_id_csr%NOTFOUND
        THEN
             --Added by rtarway, for BUG 3919800
            -- bug 8325536 - skkoppul : added SHARE_FULL structure_type condition. Update_task will
            -- always be called with structure_type as FINANCIAL in case of fully shared structure
            -- hence task_id needs to be validaetd against pa_proj_elements if it does not exist in
            -- pa_tasks table which is the case when task is never published.
            IF (l_project_sharing_type = 'SHARE_PARTIAL' OR l_project_sharing_type = 'SHARE_FULL')
            THEN
                    OPEN l_proj_element_id_csr;
                    FETCH l_proj_element_id_csr INTO l_dummy;

                    IF l_proj_element_id_csr%NOTFOUND
                    THEN

                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                        THEN
                               pa_interface_utils_pub.map_new_amg_msg
                                ( p_old_message_code => 'PA_TASK_ID_INVALID'
                                 ,p_msg_attribute    => 'CHANGE'
                                 ,p_resize_flag      => 'N'
                                 ,p_msg_context      => 'PROJ'
                                 ,p_attribute1       => l_amg_segment1
                                 ,p_attribute2       => ''
                                 ,p_attribute3       => ''
                                 ,p_attribute4       => ''
                                 ,p_attribute5       => '');
                       END IF;
                       CLOSE l_proj_element_id_csr;
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    CLOSE l_proj_element_id_csr;
                    p_out_task_id := p_pa_task_id;
            ELSE
            --End Added by rtarway, for BUG 3919800
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_TASK_ID_INVALID'
                       ,p_msg_attribute    => 'CHANGE'
                       ,p_resize_flag      => 'N'
                       ,p_msg_context      => 'PROJ'
                       ,p_attribute1       => l_amg_segment1
                       ,p_attribute2       => ''
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                 END IF;

                  CLOSE l_task_id_csr;
                  RAISE FND_API.G_EXC_ERROR;
            --Added by rtarway, for BUG 3919800
            END IF;
            --End Added by rtarway, for BUG 3919800
        END IF;

        CLOSE l_task_id_csr;

           p_out_task_id := p_pa_task_id;

       ELSIF p_pm_task_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_pm_task_reference IS NOT NULL
       THEN
            l_task_id  :=  Fetch_task_id
                          (p_pa_project_id     => p_pa_project_id,
                           p_pm_task_reference => p_pm_task_reference);
            IF  l_task_id IS NULL
            THEN

                --Added by rtarway, for BUG 3919800
                IF (l_project_sharing_type = 'SHARE_PARTIAL')
                THEN
                         OPEN cur_pa_proj_elems;
                         FETCH cur_pa_proj_elems INTO p_out_task_id;
                         IF cur_pa_proj_elems%NOTFOUND
                         THEN
                              IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                              THEN
                                 FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                                 FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Reference');
                                 FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_reference);
                                 FND_MSG_PUB.add;
                                 CLOSE cur_pa_proj_elems;
                                 RAISE FND_API.G_EXC_ERROR;
                              END IF;
                         END IF;
                         CLOSE cur_pa_proj_elems;
                ELSE
                --End Add by rtarway,for BUG 3919800

                     IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                     THEN
                        FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                        FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Reference');
                        FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_reference);
                        FND_MSG_PUB.add;

                        RAISE FND_API.G_EXC_ERROR;

                      END IF;
               END IF;--Added by rtarway for BUG 3919800
            ELSE
                   p_out_task_id := l_task_id;
            END IF;
        ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                 ( p_old_message_code => 'PA_TASK_REF_AND_ID_MISSING'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'PROJ'
                  ,p_attribute1       => l_amg_segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
                END IF;

                RAISE FND_API.G_EXC_ERROR;

        END IF; -- If p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      ELSIF (p_structure_type = 'WORKPLAN') THEN
         IF p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
         AND p_pa_task_id IS NOT NULL
         THEN

         -- Get segment1 for AMG messages
         OPEN l_amg_project_csr( p_pa_project_id );
         FETCH l_amg_project_csr INTO l_amg_segment1;
         CLOSE l_amg_project_csr;

        OPEN l_proj_element_id_csr;
        FETCH l_proj_element_id_csr INTO l_dummy;

        IF l_proj_element_id_csr%NOTFOUND
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                 ( p_old_message_code => 'PA_TASK_ID_INVALID'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'PROJ'
                  ,p_attribute1       => l_amg_segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
        END IF;

        CLOSE l_proj_element_id_csr;
        RAISE FND_API.G_EXC_ERROR;
        END IF;

        CLOSE l_proj_element_id_csr;

           p_out_task_id := p_pa_task_id;

       ELSIF p_pm_task_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_pm_task_reference IS NOT NULL
         THEN
            OPEN cur_pa_proj_elems;
            FETCH cur_pa_proj_elems INTO p_out_task_id;

            IF cur_pa_proj_elems%NOTFOUND
            THEN
               p_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
                  FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                  FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Task Reference');
                  FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_task_reference);
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF;
            CLOSE cur_pa_proj_elems;

        ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                 ( p_old_message_code => 'PA_TASK_REF_AND_ID_MISSING'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'PROJ'
                  ,p_attribute1       => l_amg_segment1
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
                END IF;

                RAISE FND_API.G_EXC_ERROR;

        END IF; -- If p_pa_task_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_task_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END Convert_pm_taskref_to_id_all;

--====================================================================================
--Name:               check_valid_message
--Type:               Function
--Description:        Checks whether procedure in core package returns valid message.
--
--Called subprograms: none
--
--
--
--History:
--  autumn-96   R. Krishna.     Created
--
FUNCTION check_valid_message (p_message IN VARCHAR2) RETURN BOOLEAN
IS

BEGIN
      IF p_message NOT LIKE 'PA_%'
      THEN
         RETURN FALSE;
      END IF;

      FND_MESSAGE.SET_NAME ('PA',p_message);
      RETURN TRUE;

EXCEPTION
  WHEN VALUE_ERROR
  THEN
       RETURN FALSE;
END check_valid_message;

--====================================================================================
--Name:               check_valid_org
--Type:               Function
--Description:        Checks whether this is a valid organization
--
--Called subprograms: none
--
--
--
--History:
--  automn-1996 R. Krishna.     Created
--  05-DEC-1996 L. de Werker    Changed cursor
--
FUNCTION check_valid_org (p_org_id IN NUMBER ) RETURN VARCHAR2
IS

   CURSOR l_get_org_csr (p_organization_id NUMBER )
   IS
   SELECT 1
   FROM  pa_organizations_project_v
   WHERE organization_id = p_organization_id
   AND   active_flag = 'Y'
   AND   TRUNC(SYSDATE) BETWEEN
   TRUNC(date_from) AND NVL(date_to, TRUNC(SYSDATE));


l_dummy  NUMBER;

BEGIN

    OPEN l_get_org_csr(p_org_id);
    FETCH l_get_org_csr INTO l_dummy;
    IF l_get_org_csr%NOTFOUND
    THEN
            CLOSE l_get_org_csr;
            RETURN 'N';
    ELSE
            CLOSE l_get_org_csr;
            RETURN 'Y';
    END IF;


EXCEPTION
    WHEN OTHERS
    THEN
        RAISE;

END check_valid_org;


--====================================================================================
--Name:               check_valid_project_status
--Type:               Function
--Description:        This function can be used to check for validity of
--            a project status
--
--Called subprograms: none
--
--
--
--History:
--    02-DEC-1996        L. de Werker    Created
--
FUNCTION check_valid_project_status
    ( p_project_status          IN  VARCHAR2    )
RETURN VARCHAR2
IS

CURSOR  l_project_status_csr
IS
SELECT  'x'
FROM    pa_project_statuses
WHERE   project_status_code = p_project_status
AND     trunc(sysdate) BETWEEN start_date_active and
        nvl(end_date_active,trunc(sysdate));

l_dummy     VARCHAR2(1);

BEGIN

    OPEN l_project_status_csr;
    FETCH l_project_status_csr INTO l_dummy;
    IF l_project_status_csr%FOUND
    THEN
        CLOSE l_project_status_csr;
        RETURN 'Y';
    ELSE
        CLOSE l_project_status_csr;
        RETURN 'N';
    END IF;


EXCEPTION
    WHEN OTHERS THEN RAISE;

END check_valid_project_status;


--====================================================================================
--Name:               check_valid_dist_rule
--
--Type:               Function
--Description:        This function can be used to check for validity of
--            a distribution rule
--
--Called subprograms: none
--
--
--
--History:
--    Fall-1996         Ramesh K.    Created
--    29-Apr-04         sabansal     Bug 3279981. Added p_en_top_task_inv_mth_flag IN parameter
FUNCTION check_valid_dist_rule (p_project_type IN VARCHAR2,
                                p_dist_rule IN VARCHAR2,
                                p_en_top_task_inv_mth_flag IN VARCHAR2 := 'N' ) RETURN VARCHAR2
IS
   CURSOR l_get_dist_rule_csr (l_project_type VARCHAR2,l_dist_rule VARCHAR2)
   IS
   SELECT 'x' FROM
   pa_project_type_distributions d
   WHERE d.project_type = l_project_type
   AND   d.distribution_rule = l_dist_rule;

   --bug 3279981 Invoice Method cannot be cost if invoice method at top task is checked
   CURSOR cur_get_valid_rules IS
   SELECT 'x'
   FROM   PA_PROJECT_TYPE_DISTRIBUTIONS ppd
   WHERE  ppd.project_type      = p_project_type
   AND    ppd.distribution_rule = p_dist_rule
   AND    substr(ppd.Distribution_Rule, instr(ppd.Distribution_Rule,'/')+1) <> 'COST';

l_temp VARCHAR2(30);
BEGIN
     --Foll condition added for 3279981
     IF 'Y' = p_en_top_task_inv_mth_flag THEN
             OPEN  cur_get_valid_rules;
             FETCH cur_get_valid_rules INTO l_temp;
             IF cur_get_valid_rules%NOTFOUND THEN
               CLOSE cur_get_valid_rules;
               RETURN 'N';
             ELSE
               CLOSE cur_get_valid_rules;
               RETURN 'Y';
             END IF;
     ELSE
             OPEN l_get_dist_rule_csr (p_project_type,p_dist_rule);
             FETCH l_get_dist_rule_csr INTO l_temp;
             IF l_get_dist_rule_csr%NOTFOUND THEN
                CLOSE l_get_dist_rule_csr;
                RETURN 'N';
             ELSE
                CLOSE l_get_dist_rule_csr;
                RETURN 'Y';
             END IF;
     END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END check_valid_dist_rule;

--====================================================================================
--Name:               check_valid_employee
--
--Type:               Function
--Description:        This function can be used to check for validity of
--            an employee
--
--Called subprograms: none
--
--
--
--History:
--    automn-1996        Ramesh K.    Created
--
FUNCTION check_valid_employee (p_person_id IN NUMBER )  RETURN VARCHAR2
IS
    CURSOR l_get_employees_csr (l_person_id NUMBER)
    IS
    SELECT 'x' FROM
    pa_employees
    WHERE person_id = l_person_id;

l_temp VARCHAR2(1);
BEGIN
             OPEN l_get_employees_csr (p_person_id);
             FETCH l_get_employees_csr INTO l_temp;

             IF l_get_employees_csr%NOTFOUND
             THEN
                CLOSE l_get_employees_csr;
                RETURN 'N';
             ELSE
                CLOSE l_get_employees_csr;
                RETURN 'Y';
             END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END check_valid_employee;

--====================================================================================
--Name:               check_class_code_valid
--
--Type:               Function
--Description:        This function can be used to check for validity of
--            a class code
--
--Called subprograms: none
--
--
--
--History:
--    automn-1996        Ramesh K.    Created
--
FUNCTION check_class_code_valid (p_class_category IN VARCHAR2,
                                 p_class_code     IN VARCHAR2 )
RETURN VARCHAR2
IS

CURSOR l_get_class_codes_csr (l_class_category IN VARCHAR2,
                              l_class_code     IN VARCHAR2 )
IS
SELECT 'x'
FROM pa_class_codes
WHERE class_category = l_class_category
AND   class_code     = l_class_code ;

l_temp VARCHAR2(1);
BEGIN
    OPEN l_get_class_codes_csr (p_class_category,p_class_code);
    FETCH l_get_class_codes_csr INTO l_temp;

    IF l_get_class_codes_csr%NOTFOUND
    THEN
       CLOSE l_get_class_codes_csr;
       RETURN 'N';
    ELSE
       CLOSE l_get_class_codes_csr;
       RETURN 'Y';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END check_class_code_valid;

--====================================================================================
--Name:               Delete_One_Task
--
--Type:               Procedure
--Description:        This procedure can be used to delete 1 task, and move all it's
--            children to belang to it's parent
--
--Called subprograms: none
--
--
--
--History:
--    automn-1996       Ramesh K.       Created
--    08-DEC-1996   L. de Werker    Fixed some errors
--    11-DEC-1996   L. de Werker    Changed, only top tasks without any children can be single deleted
--                   (not cascade deleted)
--    13-Dec-2005   Sunkalya   Bug#4878754. Modified the where condition for Improving Performance under Sql Repository work.Change Tagged.
--
PROCEDURE Delete_One_Task
          (p_task_id             IN NUMBER,
           p_return_status      OUT NOCOPY VARCHAR2, -- 4537865
           p_msg_count          OUT NOCOPY NUMBER, -- 4537865
           p_msg_data           OUT NOCOPY VARCHAR2 ) IS -- 4537865

CURSOR l_get_task_det_csr IS
SELECT project_id,
       task_id,
       parent_task_id,
       top_task_id,
       TASK_NAME,
       PM_TASK_REFERENCE
FROM
       pa_tasks
WHERE  task_id = p_task_id;

CURSOR l_get_lower_task_det_csr (l_project_id     IN NUMBER,
                                 l_task_id        IN NUMBER )
IS
SELECT  task_id
FROM    pa_tasks
WHERE   project_id = l_project_id
AND     parent_task_id = l_task_id;

l_task_rec   l_get_task_det_csr%ROWTYPE;
l_parent_task_rec l_get_lower_task_det_csr%ROWTYPE;

l_api_name  CONSTANT    VARCHAR2(30) := 'Delete_One_Task';
l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

-- 4537865 Start
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

-- 4537865 End

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

BEGIN

      SAVEPOINT delete_one_task;

      OPEN l_get_task_det_csr;
      FETCH l_get_task_det_csr INTO l_task_rec;
      CLOSE l_get_task_det_csr;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_task_rec.project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_rec.task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> l_task_rec.task_name
    ,p_task_reference => l_task_rec.pm_task_reference
    ,p_task_id => l_task_rec.task_id);

      IF l_task_rec.task_id = l_task_rec.top_task_id
      THEN

         -- A top task is getting deleted
         OPEN l_get_lower_task_det_csr(l_task_rec.project_id,
                                       l_task_rec.task_id );
         FETCH l_get_lower_task_det_csr INTO l_parent_task_rec;

     IF l_get_lower_task_det_csr%FOUND
     THEN
        CLOSE l_get_lower_task_det_csr;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_TOP_TASK_CHILD_NO_DELETE'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;

         CLOSE l_get_lower_task_det_csr;

      ELSE   -- if this is not a top task check whether this
             -- is a parent task
         OPEN l_get_lower_task_det_csr(l_task_rec.project_id,
                                       l_task_rec.task_id );
         FETCH l_get_lower_task_det_csr INTO l_parent_task_rec;

         IF l_get_lower_task_det_csr%FOUND
         THEN -- This task is a parent
            -- hence update all first line children as follows
            -- parent task id = the parent task id of the task that is
            -- being deleted

            UPDATE pa_tasks
            SET   parent_task_id = l_task_rec.parent_task_id,
                  wbs_level      = Decode(wbs_level,1,1,wbs_level-1)
            WHERE project_id = l_task_rec.project_id
            AND   parent_task_id = l_task_rec.task_id;
            CLOSE l_get_lower_task_det_csr;
         ELSE
            CLOSE l_get_lower_task_det_csr;
         END IF;
      END IF ;

      DELETE FROM pa_transaction_controls WHERE task_id = p_task_id;

      --Modified the where condition for Improving Performance under Sql Repository work.Bug#4878754.
      DELETE FROM pa_billing_assignments WHERE
          top_task_id = p_task_id
      AND project_id  = l_task_rec.project_id;

      DELETE FROM pa_labor_multipliers WHERE task_id = p_task_id;

      DELETE FROM pa_job_bill_rate_overrides WHERE task_id = p_task_id;

      DELETE FROM pa_job_bill_title_overrides WHERE task_id = p_task_id;

      DELETE FROM pa_job_assignment_overrides WHERE task_id = p_task_id;

      DELETE FROM pa_emp_bill_rate_overrides WHERE task_id = p_task_id;

      DELETE FROM pa_nl_bill_rate_overrides WHERE task_id = p_task_id;

      DELETE FROM pa_compiled_multipliers
      WHERE ind_compiled_set_id IN
                      (SELECT ics.ind_compiled_set_id
                       FROM   pa_ind_compiled_sets ics,
                              pa_ind_rate_sch_revisions rev,
                              pa_ind_rate_schedules sch
                       WHERE  ics.ind_rate_sch_revision_id =
                              rev.ind_rate_sch_revision_id
                       AND    rev.ind_rate_sch_id = sch.ind_rate_sch_id
                       AND    sch.task_id = p_task_id);

      DELETE FROM pa_ind_compiled_sets
      WHERE ind_rate_sch_revision_id  IN
                (SELECT rev.ind_rate_sch_revision_id
                 FROM   pa_ind_rate_sch_revisions rev,
                        pa_ind_rate_schedules sch
                 WHERE  rev.ind_rate_sch_id = sch.ind_rate_sch_id
                 AND    sch.task_id         = p_task_id );

      DELETE FROM pa_ind_rate_sch_revisions
      WHERE ind_rate_sch_id IN
                (SELECT ind_rate_sch_id
                 FROM pa_ind_rate_schedules
                 WHERE task_id = p_task_id );

      DELETE FROM pa_ind_rate_schedules        WHERE task_id = p_task_id;

      DELETE FROM pa_project_asset_assignments WHERE task_id = p_task_id;

      DELETE FROM pa_percent_completes         WHERE task_id = p_task_id;

      DELETE FROM pa_tasks WHERE task_id = p_task_id;

     p_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR
   THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        p_msg_count     :=  Fnd_Msg_Pub.count_msg;  -- 4537865

    IF p_msg_count = 1 AND p_msg_data IS NULL
        THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => p_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          p_msg_data := l_data;
        END IF;

    ROLLBACK TO delete_one_task;

   WHEN OTHERS
   THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- 4537865
    p_msg_count     := 1;
    p_msg_data      := SQLERRM;

        ROLLBACK TO delete_one_task;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name
        , p_error_text      => p_msg_data
        );

    END IF;

END Delete_One_Task;


--====================================================================================
--Name:               Validate_billing_info
--
--Type:               Procedure
--Description:        This procedure can be used to validate billing information
--            for contract type projects
--
--
--Called subprograms: none
--
--
--
--History:
--    automn-1996        Ramesh K.    Created
--
PROCEDURE Validate_billing_info
          (p_project_id             IN    NUMBER,  -- Added for Bug 5643876
	   p_project_class_code     IN    VARCHAR2,
           p_in_task_rec            IN    pa_project_pub.task_in_rec_type,
           p_return_status         OUT NOCOPY   VARCHAR2 ) IS -- 4537865 Added nocopy

BEGIN

pa_project_check_pvt.Validate_billing_info_pvt
(p_project_id               => p_project_id   -- Added for Bug 5643876
,p_project_class_code       => p_project_class_code
,p_in_task_rec                  => p_in_task_rec
,p_return_status                => p_return_status);

-- 4537865
EXCEPTION
    WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => 'Validate_billing_info'
                , p_error_text          => SUBSTRB(SQLERRM,1,240));

             END IF;
    -- Didnt include RAISE because pa_project_check_pvt.Validate_billing_info_pvt also doesnt RAISE
END Validate_billing_info;

--====================================================================================
--Name:               check_start_end_date
--Type:               Procedure
--Description:        This procedure can be used to pass old and new start_dates
--            and old and new end_dates, from the PUBLIC API's. This procedure
--            will check whether the new situation is going to be valid, and returns
--            flags indicating whether start_date or end_date needs updating.
--
--
--Called subprograms: none
--
--
--
--History:
--    03-DEC-1996        L. de Werker    Created
--
PROCEDURE check_start_end_date
( p_return_status           OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy
 ,p_old_start_date          IN  DATE
 ,p_new_start_date          IN  DATE
 ,p_old_end_date            IN  DATE
 ,p_new_end_date            IN  DATE
 ,p_update_start_date_flag      OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy
 ,p_update_end_date_flag        OUT NOCOPY VARCHAR2        ) -- 4537865 Added nocopy
IS

   l_api_name            CONSTANT   VARCHAR2(30)        := 'check_start_end_date';

   l_start_date         DATE;
   l_end_date           DATE;

BEGIN

pa_project_check_pvt.check_start_end_date_pvt
(p_return_status                    => p_return_status
,p_old_start_date                   => p_old_start_date
,p_new_start_date               => p_new_start_date
,p_old_end_date                 => p_old_end_date
,p_new_end_date                 => p_new_end_date
,p_update_start_date_flag       => p_update_start_date_flag
,p_update_end_date_flag         => p_update_end_date_flag);
-- 4537865
EXCEPTION
        WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_update_end_date_flag := NULL  ;
        p_update_start_date_flag := NULL ;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => l_api_name
                , p_error_text      => SUBSTRB(SQLERRM,1,240)
                );

        END IF;
-- Didnt include RAISE because pa_project_check_pvt.check_start_end_date_pvt also doesnt RAISE
END check_start_end_date;

--------------------------------------------------------------------------------
--Name:               check_for_one_manager
--Type:               Procedure
--Description:        See below.
--
--Called subprograms:
--
--
--
--History:
--      31-JUL-1996     R. Krishnamurthy        Created
--  03-DEC-1996 L. de Werker        Moved from pa_project_pub to pa_project_pvt
--
PROCEDURE check_for_one_manager
(p_project_id       IN  NUMBER
,p_person_id        IN  NUMBER
,p_key_members      IN  pa_project_pub.project_role_tbl_type
,p_start_date       IN  DATE
,p_end_date         IN  DATE
,p_return_status    OUT NOCOPY    VARCHAR2 ) -- 4537865  Added nocopy hint
IS

BEGIN
/*
   If a project manager is sought to be created, then check whether
   there is already a project manager for the project. If so, check
   whether this is the same person. If not,then check the start and
   end dates for the existing manager. If dates overlap,then
   check the input table to see whether the existing project manager
   is being de-activated. If so,go ahead and create a new project manager and
   update the end date of the existing manager with the date provided
   Else update the end date of the existing manager to either
   (a) new manager's start date -1 or (b) sysdate -1
   (being done in check_for_one_manager);
*/

pa_project_check_pvt.check_for_one_manager_pvt
(p_project_id       => p_project_id
,p_person_id        => p_person_id
,p_key_members      => p_key_members
,p_start_date       => p_start_date
,p_end_date         => p_end_date
,p_return_status    => p_return_status);
 -- 4537865
EXCEPTION
        WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => 'check_for_one_manager'
                                , p_error_text          => SUBSTRB(SQLERRM,1,240)
                );

        END IF;
-- Didnt include RAISE because pa_project_check_pvt.check_for_one_manager_pvt also doesnt RAISE
END check_for_one_manager;

Procedure handle_task_number_change
          (p_project_id                   IN NUMBER,
           p_task_id                      IN NUMBER,
           p_array_cell_number            IN NUMBER,
           p_in_task_number               IN VARCHAR2,
           p_in_task_tbl                  IN pa_project_pub.task_in_tbl_type,
           p_proceed_with_update_flag    OUT NOCOPY VARCHAR2,  -- 4537865
           p_return_status               OUT NOCOPY VARCHAR2 )  -- 4537865
IS

BEGIN

pa_project_check_pvt.handle_task_number_change_pvt
(p_project_id                       => p_project_id
,p_task_id                          => p_task_id
,p_array_cell_number                => p_array_cell_number
,p_in_task_number             => p_in_task_number
,p_in_task_tbl                      => p_in_task_tbl
,p_proceed_with_update_flag => p_proceed_with_update_flag
,p_return_status                    => p_return_status);
 -- 4537865
EXCEPTION
        WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_proceed_with_update_flag := NULL ;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => 'handle_task_number_change'
                                , p_error_text          => SUBSTRB(SQLERRM,1,240)
                                );

        END IF;
-- Didnt include RAISE because pa_project_check_pvt.handle_task_number_change_pvt also doesnt RAISE
END handle_task_number_change;

Procedure check_parent_child_task_dates
          (p_project_id                   IN NUMBER,
           p_return_status               OUT NOCOPY VARCHAR2 ) -- 4537865
IS

BEGIN

pa_project_check_pvt.check_parent_child_tk_dts_Pvt
(p_project_id           => p_project_id
,p_return_status        => p_return_status);
 -- 4537865
EXCEPTION
        WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => 'check_parent_child_task_dates'
                                , p_error_text          => SUBSTRB(SQLERRM,1,240)
                                );

        END IF;
-- Didnt include RAISE because pa_project_check_pvt.check_parent_child_task_dates also doesnt RAISE
END check_parent_child_task_dates;

Procedure Update_One_Task
( p_api_version_number          IN  NUMBER      :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_commit              IN  VARCHAR2    := FND_API.G_FALSE,
  p_init_msg_list           IN  VARCHAR2    := FND_API.G_FALSE,
  p_msg_count               OUT NOCOPY NUMBER, -- 4537865
  p_msg_data                OUT NOCOPY VARCHAR2, -- 4537865
  p_return_status           OUT NOCOPY VARCHAR2, -- 4537865
  p_pm_product_code         IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pm_project_reference            IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_project_id                   IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_pm_task_reference               IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_number                     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_task_id                      IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_task_name                       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_long_task_name                      IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_description                IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_start_date                 IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_task_completion_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_pm_parent_task_reference        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_pa_parent_task_id           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_address_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_carrying_out_organization_id    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_service_type_code               IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_task_manager_person_id          IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_billable_flag                   IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_chargeable_flag                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_bill_flag              IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_ready_to_distribute_flag        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_limit_to_txn_controls_flag      IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_bill_rate_org_id          IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_std_bill_rate_schdl       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_labor_schedule_fixed_date       IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_schedule_discount         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_bill_rate_org_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_nl_std_bill_rate_schdl          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_schedule_fixed_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_nl_schedule_discount            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_labor_cost_multiplier_name      IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_cost_ind_rate_sch_id            IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_rev_ind_rate_sch_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_inv_ind_rate_sch_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
  p_cost_ind_sch_fixed_date         IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_rev_ind_sch_fixed_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_inv_ind_sch_fixed_date          IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_labor_sch_type                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_nl_sch_type                     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_actual_start_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_actual_finish_date                  IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_start_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_early_finish_date                   IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_start_date                     IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_late_finish_date                    IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_start_date                IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_scheduled_finish_date               IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_attribute_category          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute1              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute2              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute3              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute4              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute5              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute6              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute7              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute8              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute9              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_attribute10             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_allow_cross_charge_flag            IN VARCHAR2 :=
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
  p_project_rate_date      IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
  p_project_rate_type      IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cc_process_labor_flag  IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_labor_tp_schedule_id   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_labor_tp_fixed_date    IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_cc_process_nl_flag     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_nl_tp_schedule_id      IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_nl_tp_fixed_date       IN DATE     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
 p_receive_project_invoice_flag IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_work_type_id           IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_emp_bill_rate_schedule_id  IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_job_bill_rate_schedule_id  IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
--Sakthi  MCB
 p_non_lab_std_bill_rt_sch_id  IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_taskfunc_cost_rate_type     IN VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_taskfunc_cost_rate_date     IN DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--Sakthi  MCB
 p_labor_disc_reason_code       IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_non_labor_disc_reason_code   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--PA L changes -- bug 2872708  --update_task
 p_retirement_cost_flag          VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_eligible_flag            VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_cint_stop_date                DATE         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
--end PA L changes -- bug 2872708

--(Begin Venkat) FP_M changes ----------------------------------------------
 p_invoice_method                IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
 p_customer_id                   IN NUMBER   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 p_gen_etc_source_code           IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
--(End Venkat) FP_M changes ------------------------------------------------

  p_out_pa_task_id                  OUT    NOCOPY NUMBER, -- 4537865
  p_out_pm_task_reference           OUT    NOCOPY VARCHAR2            ) -- 4537865

IS
   CURSOR l_get_project_info_csr (l_project_id IN NUMBER)
   IS
   SELECT project_type,pm_project_reference
   FROM   pa_projects
   WHERE  project_id = l_project_id;

   /* Added for bug#2666913 to get the project type*/
   CURSOR l_get_project_type_info_csr (l_project_id IN NUMBER)
   IS
   SELECT project_type_class_code
   FROM   pa_project_types pt, pa_projects p
   WHERE  p.project_id = l_project_id
   and    p.project_type = pt.project_type;


   CURSOR l_service_type_csr( p_service_type_code VARCHAR2 )
   IS
   SELECT 'x'
   FROM   pa_lookups
   WHERE  lookup_type = 'SERVICE TYPE'
   AND    lookup_code = p_service_type_code;

   CURSOR l_task_rec_csr (l_project_id NUMBER ,l_task_id NUMBER)
   IS
   SELECT *
   FROM pa_tasks
   WHERE project_id = l_project_id
   AND   task_id    = l_task_id;

   CURSOR l_check_child_exists_csr (l_project_id NUMBER,l_task_id NUMBER )
   IS
   SELECT 'x' FROM
   PA_TASKS
   WHERE project_id = l_project_id
   AND   parent_task_id = l_task_id;

   CURSOR l_outer_child_dates_csr (l_project_id NUMBER,l_task_id NUMBER)
   IS
   SELECT MIN(TRUNC(start_date))
   ,      MAX(TRUNC(completion_date)) -- Bug Fix 4705139
   FROM pa_tasks
   WHERE project_id = l_project_id
   AND   parent_task_id = l_task_id;

   CURSOR l_outer_parent_dates_csr (l_project_id NUMBER,l_task_id NUMBER)
   IS
   SELECT MIN(TRUNC(start_date))
   ,      MAX(TRUNC(completion_date)) -- Bug Fix 4705139
   FROM pa_tasks
   WHERE project_id = l_project_id
   AND   task_id = l_task_id;

   CURSOR l_project_date_csr (l_project_id NUMBER )
   IS
   SELECT trunc(start_date) start_date,trunc(completion_date) completion_date -- Bug Fix 4705139
   FROM   pa_projects
   WHERE  project_id = l_project_id;

   CURSOR l_top_task_csr (p_task_id NUMBER)
   IS
   SELECT top_task_id
   FROM pa_tasks
   WHERE task_id = p_task_id;

   --needed to convert pm_parent_task_reference to parent_task_id
   --convert_pm_taskref_to_id can not be used because parent_id can be NULL

   CURSOR l_convert_pm_parent_to_id_csr( p_project_id NUMBER, p_pm_task_reference VARCHAR2 )
   IS
   SELECT   task_id
   FROM     pa_tasks
   WHERE    pm_task_reference = p_pm_task_reference
   AND      project_id = p_project_id;

   CURSOR l_parent_wbs_csr ( p_project_id NUMBER, p_pa_task_id NUMBER )
   IS
   SELECT   wbs_level
   FROM     pa_tasks
   WHERE    task_id = p_pa_task_id
   AND      project_id = p_project_id;

   CURSOR l_validate_parent_id_csr( p_project_id NUMBER, p_task_id NUMBER)
   IS
   SELECT   'x'
   FROM     pa_tasks
   WHERE    task_id = p_task_id
   AND      project_id = p_project_id;

   CURSOR l_lock_rows_csr( p_task_id NUMBER)
   IS
   SELECT 'x'
   FROM   pa_tasks
   WHERE  task_id = p_task_id
   FOR UPDATE NOWAIT;

-- Used when parent_id is changed, and the task (and it's children) is on a different wbs level

   CURSOR l_wbs_level_csr( p_task_id NUMBER)
   IS
   SELECT   task_id
   FROM     pa_tasks
   START WITH   task_id=p_task_id
   CONNECT BY PRIOR task_id=parent_task_id
   FOR UPDATE NOWAIT;

-- *O
-- Used to check if task is being moved to a lower level within it's own hierarchy.

   CURSOR l_chk_chlds_parent_id_csr( p_task_id NUMBER, p_new_parent_task_id NUMBER)
   IS
   SELECT   'x'
   FROM     pa_tasks
   WHERE    task_id=p_new_parent_task_id
   START WITH   task_id=p_task_id
   CONNECT BY PRIOR task_id=parent_task_id
   FOR UPDATE NOWAIT;

   --needed for update of address_id

   CURSOR l_customer_csr( p_project_id NUMBER )
   IS
   SELECT   customer_id
   FROM     pa_project_customers
   WHERE    project_id = p_project_id;

   -- 4363092 TCA changes, replaced RA views with HZ tables
   /*
   CURSOR l_address_csr(p_customer_id NUMBER, p_address_id NUMBER )
   IS
   SELECT   'x'
   FROM     ra_addresses
   WHERE    customer_id = p_customer_id
   AND      address_id = p_address_id;
   */

   CURSOR l_address_csr(p_customer_id NUMBER, p_address_id NUMBER )
   IS
   SELECT   'x'
   FROM
         hz_cust_acct_sites_all acct_site
   WHERE
         acct_site.cust_account_id = p_customer_id
   AND   acct_site.cust_acct_site_id = p_address_id;

   -- 4363092 end

l_min_child_start_date          DATE;
l_max_child_completion_date     DATE;
l_min_parent_start_date         DATE;
l_max_parent_completion_date        DATE;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

-- Fix for Bug # 1335417
-- needed for update of Fixed Date( p_cost_ind_sch_fixed_date)

   CURSOR l_ind_rate_schedule_type_csr( p_cost_ind_rate_sch_id NUMBER)
   IS
   SELECT       ind_rate_schedule_type
   FROM         pa_ind_rate_schedules
   WHERE        ind_rate_sch_id = p_cost_ind_rate_sch_id;

-- Fix for Bug # 1335417
   l_temp_var_sch_type                         VARCHAR2(1);

-- Fix for Bug # 1272548

-- needed for update of Schedule Id( p_cost_ind_rate_sch_id)

   CURSOR l_cost_ind_rate_sch_id_csr( p_cost_ind_rate_sch_id NUMBER)
   IS
   SELECT       'x'
   FROM         pa_ind_rate_schedules
   WHERE        ind_rate_sch_id = p_cost_ind_rate_sch_id;

-- Fix for Bug # 1272548
   l_temp_var                          VARCHAR2(1);

l_project_date_rec                  l_project_date_csr%ROWTYPE;

l_api_name              CONSTANT        VARCHAR2(30):=  'update_one_task';

l_return_status                         VARCHAR2(1);
l_index                                 NUMBER;
l_err_code                              NUMBER := 0;
l_err_stage                             VARCHAR2(2000);
l_err_stack                             VARCHAR2(2000);
l_project_id                    NUMBER ;
l_cursor                                INTEGER;
--l_statement                           VARCHAR2(2000);  --bug 2955326
l_statement                         VARCHAR2(30000);  --bug 2955326
l_rows                                  INTEGER;
l_task_rec                              l_task_rec_csr%ROWTYPE;
l_temp                                  VARCHAR2(1);
l_children_exist                        VARCHAR2(1) := 'N';
l_new_start_date                        DATE;
l_temp_parent_task_id                   NUMBER := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
l_new_parent_task_id                    NUMBER;
l_top_task_id                   NUMBER;
l_task_id                   NUMBER;
l_update_yes_flag                       VARCHAR2(1) := 'N';
l_pm_task_reference         VARCHAR2(30);
l_update_start_date_flag        VARCHAR2(1);
l_update_end_date_flag          VARCHAR2(1);
l_new_parent_wbs_level          NUMBER;
l_wbs_change_task_id            NUMBER;
l_delta_level               NUMBER;
l_customer_id               NUMBER;
l_address_valid             VARCHAR2(1);
l_msg_count             NUMBER ;
l_msg_data              VARCHAR2(2000);
l_function_allowed          VARCHAR2(1);
l_resp_id               NUMBER := 0;
l_user_id                       NUMBER := 0;
l_module_name                           VARCHAR2(80);
l_tasks_restructured_flag               VARCHAR2(1) := 'N';
l_project_type              VARCHAR2(30);
l_project_type_class_code VARCHAR2(30);         /* Added for bug#2666913 */
l_pm_project_reference          VARCHAR2(30);
l_org_func_security                     VARCHAR2(1);  /*bug#1968394  */
/*Added for bug 2802984 */
l_out_labor_sch_type                    VARCHAR2(1);
l_out_nl_labor_sch_type                 VARCHAR2(1);
l_rev_rate_sch_type                     VARCHAR2(1);
l_inv_rate_sch_type                     VARCHAR2(1);
l_std_bill_rate_schedule                VARCHAR2(30);

-- (Begin Venkat) FP_M changes ------------------------------------------
l_revenue_accrual_method        VARCHAR2(30);
l_invoice_method            VARCHAR2(30); -- 4177105 this var is unitialized , use p_invoice_method var
l_gen_etc_source_code           VARCHAR2(30);
-- (End Venkat) FP_M changes --------------------------------------------

--bug 2955326
l_b_pm_tk_ref_flag             VARCHAR2(1) := 'N';
l_b_tk_nm_flag                 VARCHAR2(1) := 'N';
l_b_ln_tk_nm_flag              VARCHAR2(1) := 'N';
l_b_tk_desc_flag               VARCHAR2(1) := 'N';
l_b_rdy_to_bill_flag           VARCHAR2(1) := 'N';
l_b_rdy_to_dist_flag           VARCHAR2(1) := 'N';
l_b_lmt_to_txn_ctrl_fg         VARCHAR2(1) := 'N';
l_b_cryng_out_org_id_flag      VARCHAR2(1) := 'N';
l_b_chgble_fg                  VARCHAR2(1) := 'N';
l_b_billable_fg                VARCHAR2(1) := 'N';
l_b_srv_tp_cd_fg               VARCHAR2(1) := 'N';
l_b_tk_num_fg                  VARCHAR2(1) := 'N';
l_b_tk_st_dt_flag              VARCHAR2(1) := 'N';
l_b_comp_dt_fg                 VARCHAR2(1) := 'N';
l_b_prt_tk_id_fg               VARCHAR2(1) := 'N';
l_b_addr_id_fg                 VARCHAR2(1) := 'N';
l_b_attr_cat_fg                VARCHAR2(1) := 'N';
l_b_attr1_fg                   VARCHAR2(1) := 'N';
l_b_attr2_fg                   VARCHAR2(1) := 'N';
l_b_attr3_fg                   VARCHAR2(1) := 'N';
l_b_attr4_fg                   VARCHAR2(1) := 'N';
l_b_attr5_fg                   VARCHAR2(1) := 'N';
l_b_attr6_fg                   VARCHAR2(1) := 'N';
l_b_attr7_fg                   VARCHAR2(1) := 'N';
l_b_attr8_fg                   VARCHAR2(1) := 'N';
l_b_attr9_fg                   VARCHAR2(1) := 'N';
l_b_attr10_fg                  VARCHAR2(1) := 'N';
l_b_al_x_chg_fg                VARCHAR2(1) := 'N';
l_b_prj_rt_tp_fg               VARCHAR2(1) := 'N';
l_b_prj_rt_dt_fg               VARCHAR2(1) := 'N';
l_b_cc_proc_lbr_fg             VARCHAR2(1) := 'N';
l_b_lbr_tp_sch_id_fg           VARCHAR2(1) := 'N';
l_b_lbr_tp_fx_dt_fg            VARCHAR2(1) := 'N';
l_b_cc_proc_nl_fg              VARCHAR2(1) := 'N';
l_b_nl_tp_sch_id_fg            VARCHAR2(1) := 'N';
l_b_nl_tp_fx_dt_fg             VARCHAR2(1) := 'N';
l_b_rcv_prj_inv_fg             VARCHAR2(1) := 'N';
l_b_wk_tp_id_fg                VARCHAR2(1) := 'N';
l_b_emp_bill_rt_sch_id_fg      VARCHAR2(1) := 'N';
l_b_jb_bill_rt_sch_id_fg       VARCHAR2(1) := 'N';
l_b_nn_lb_std_bl_rt_sch_id_fg  VARCHAR2(1) := 'N';
l_b_tkfnc_cst_rt_dt_fg         VARCHAR2(1) := 'N';
l_b_tkfnc_cst_rt_tp_fg         VARCHAR2(1) := 'N';
l_b_lbr_disc_rsn_cd_fg         VARCHAR2(1) := 'N';
l_b_nn_lbr_disc_rsn_cd_fg      VARCHAR2(1) := 'N';
l_b_act_st_dt_fg               VARCHAR2(1) := 'N';
l_b_act_fn_dt_fg               VARCHAR2(1) := 'N';
l_b_erly_st_dt_fg              VARCHAR2(1) := 'N';
l_b_erly_fn_dt_fg              VARCHAR2(1) := 'N';
l_b_lt_st_dt_fg                VARCHAR2(1) := 'N';
l_b_lt_fn_dt_fg                VARCHAR2(1) := 'N';
l_b_sch_st_dt_fg               VARCHAR2(1) := 'N';
l_b_sch_fn_dt_fg               VARCHAR2(1) := 'N';
l_b_cst_ind_rt_sch_id_fg       VARCHAR2(1) := 'N';
l_b_cst_ind_sch_fx_dt_fg       VARCHAR2(1) := 'N';

l_b_ret_cst_fg                 VARCHAR2(1) := 'N';
l_b_cint_elg_fg                VARCHAR2(1) := 'N';
l_b_cint_stp_dt_fg             VARCHAR2(1) := 'N';
l_b_lbr_sch_tp_fg              VARCHAR2(1) := 'N';
l_b_n_lbr_sch_tp_fg            VARCHAR2(1) := 'N';
l_b_jb_bill_rt_sch_id_fg2      VARCHAR2(1) := 'N';
l_b_emp_bill_rt_sch_id_fg2     VARCHAR2(1) := 'N';
l_b_lbr_sch_fx_dt              VARCHAR2(1) := 'N';
l_b_lbr_sch_dsnt               VARCHAR2(1) := 'N';
l_b_rv_ind_rt_sch_id_fg        VARCHAR2(1) := 'N';
l_b_inv_ind_rt_sch_id_fg       VARCHAR2(1) := 'N';
l_b_rv_ind_sch_fx_dt_fg        VARCHAR2(1) := 'N';
l_b_iv_ind_sch_fx_dt_fg        VARCHAR2(1) := 'N';
l_b_nl_bl_rt_org_id_fg         VARCHAR2(1) := 'N';
l_b_nl_std_bl_rt_sch_fg        VARCHAR2(1) := 'N';
l_b_nl_sch_fx_dt_fg            VARCHAR2(1) := 'N';
l_b_nl_sch_dsnt_fg             VARCHAR2(1) := 'N';
l_b_nl_disc_rsn_cd_fg          VARCHAR2(1) := 'N';
l_b_tk_mgr_id_fg               VARCHAR2(1) := 'N';
--end bug 2955326

--(Begin Venkat) FP_M changes --------------------------------------------
l_inv_md_fg            VARCHAR2(1) := 'N';
l_cust_id_fg               VARCHAR2(1) := 'N';
l_gen_etc_src_co_fg            VARCHAR2(1) := 'N';
--(End Venkat) FP_M changes ----------------------------------------------

l_warnings_only_flag VARCHAR2(1) := 'N'; --bug3134205
--rtarway BUG 3908013
l_return_msg                  varchar2(2000);
l_validate_status             varchar2(1);
/* bug#5243018 : Reverting the fix in Bug 4120380
task_number_change_Ok_flag    varchar2(1); --Added for Bug 4120380 */

l_cc_process_labor_flag  varchar2(1) := p_cc_process_labor_flag; /* Added for Bug 5395048 */
l_cc_process_nl_flag  varchar2(1) := p_cc_process_nl_flag; /* Added for Bug 5395048 */

 --bug 6153503
l_attribute_category          VARCHAR2(30);
l_attribute1                  VARCHAR2(150);
l_attribute2                  VARCHAR2(150);
l_attribute3                  VARCHAR2(150);
l_attribute4                  VARCHAR2(150);
l_attribute5                  VARCHAR2(150);
l_attribute6                  VARCHAR2(150);
l_attribute7                  VARCHAR2(150);
l_attribute8                  VARCHAR2(150);
l_attribute9                  VARCHAR2(150);
l_attribute10                 VARCHAR2(150);
l_project_type2    VARCHAR2(20);-- for bug 7403227
  BEGIN

--  Standard begin of API savepoint

    SAVEPOINT update_task_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --pm_product_code is mandatory

    l_tasks_restructured_flag := 'N';
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    --l_module_name := p_pm_product_code||'.'||'PA_PM_UPDATE_TASK';
    l_module_name := 'PA_PM_UPDATE_TASK';

    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the task
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_TASK',
       p_msg_count      => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'Y'
           ,p_msg_context      => 'GENERAL'
           ,p_attribute1       => ''
           ,p_attribute2       => ''
           ,p_attribute3       => ''
           ,p_attribute4       => ''
           ,p_attribute5       => '');
       p_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
        END IF;

--bug 2841158
--    IF p_pm_product_code IS NULL
--    OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    IF p_pm_product_code IS NOT NULL
    AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--bug 2841158
       AND p_pm_product_code <> 'WORKPLAN'    --bug 2665656
    THEN

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'N'
           ,p_msg_context      => 'GENERAL'
           ,p_attribute1       => ''
           ,p_attribute2       => ''
           ,p_attribute3       => ''
           ,p_attribute4       => ''
           ,p_attribute5       => '');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
    END IF;

--bug 2841158
    IF p_pm_product_code <> 'WORKPLAN'
       AND p_pm_product_code IS NOT NULL
       AND p_pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
--bug 2841158

         /*added for bug no :2413400*/
        OPEN p_product_code_csr (p_pm_product_code);
        FETCH p_product_code_csr INTO l_pm_product_code;
        CLOSE p_product_code_csr;

        IF l_pm_product_code <> 'X'
           AND p_pm_product_code <> 'WORKPLAN'    --bug 2665656
        THEN

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           END IF;
        p_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF;  --bug 2841158

--  convert pm_project_reference to id

    Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => p_pa_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => l_return_status );

    IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
    THEN

            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    THEN

            RAISE  FND_API.G_EXC_ERROR;
    END IF;

      -- Now verify whether project security allows the user to update
      -- the task

      IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN


         -- The user does not have query privileges on this project
         -- Hence, cannot update the task.Raise error

          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'Y'
           ,p_msg_context      => 'GENERAL'
           ,p_attribute1       => ''
           ,p_attribute2       => ''
           ,p_attribute3       => ''
           ,p_attribute4       => ''
           ,p_attribute5       => '');
       p_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'Y'
           ,p_msg_context      => 'GENERAL'
           ,p_attribute1       => ''
           ,p_attribute2       => ''
           ,p_attribute3       => ''
           ,p_attribute4       => ''
           ,p_attribute5       => '');
       p_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;
    --5262740 Changed PA_PROJECT_PVT.Convert_pm_taskref_to_id to PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
    Pa_project_pvt.Convert_pm_taskref_to_id_all (
        p_pa_project_id       => l_project_id,
        p_pa_task_id          => p_pa_task_id,
        p_pm_task_reference   => p_pm_task_reference,
        p_out_task_id         => l_task_id,
        p_return_status       => l_return_status );

    IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
    THEN

            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    THEN

            RAISE  FND_API.G_EXC_ERROR;
    END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number => p_task_name
    ,p_task_reference =>p_pm_task_reference
    ,p_task_id => l_task_id);



--  Lock the task for update
    OPEN l_lock_rows_csr( l_task_id );


--     get the current data of this task
       OPEN l_task_rec_csr (l_project_id,l_task_id );
       FETCH l_task_rec_csr INTO l_task_rec;
       CLOSE l_task_rec_csr;


--     Check for existing children

       OPEN l_check_child_exists_csr(l_project_id,l_task_id);
       FETCH l_check_child_exists_csr INTO l_temp;
       IF l_check_child_exists_csr%FOUND
       THEN
          l_children_exist := 'Y';
       ELSE
          l_children_exist := 'N';
       END IF;

       CLOSE l_check_child_exists_csr;

--     Building the dynamic SQL statement

       l_statement := ' UPDATE PA_TASKS SET ';

--  TASK REFERENCE

       IF   p_pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND  nvl(p_pm_task_reference,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
            nvl(l_task_rec.pm_task_reference, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       AND  p_pm_task_reference IS NOT NULL --redundant, but added for clarity
       THEN

--bug 2955326
/*
            l_statement := l_statement ||
                           ' PM_TASK_REFERENCE = '||''''||
                           RTRIM(p_pm_task_reference)||''''||',';
*/
            l_statement := l_statement ||
                           ' PM_TASK_REFERENCE = :pm_tk_ref ,';
            l_b_pm_tk_ref_flag := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

            l_pm_task_reference := p_pm_task_reference;
       ELSE
            l_pm_task_reference := l_task_rec.pm_task_reference;

       END IF;

--  TASK NAME

       IF p_task_name <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_task_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> nvl(l_task_rec.task_name, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_task_name IS NOT NULL --redundant, but added for clarity
       THEN

--bug 2955326
/*
            l_statement := l_statement ||
                           ' TASK_NAME = '||''''||
                           RTRIM(p_task_name)||''''||',';
*/
            l_statement := l_statement ||
                           ' TASK_NAME = :tk_name ,';
            l_b_tk_nm_flag := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

--     LONG TASK NAME

       IF p_long_task_name <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_long_task_name,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        <> nvl(l_task_rec.long_task_name, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_long_task_name IS NOT NULL --redundant, but added for clarity
       THEN

--bug 2955326
/*
            l_statement := l_statement ||
                           ' LONG_TASK_NAME = '||''''||
                           RTRIM(p_long_task_name)||''''||',';
*/
            l_statement := l_statement ||
                           ' LONG_TASK_NAME = :ln_tk_name ,';
            l_b_ln_tk_nm_flag := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

--  DESCRIPTION
   /*   IF (p_task_description <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
          p_task_description IS NOT NULL)*/ /*Changed the above code for
          p_task_description IS NOT NULL to p_task_description IS NULL,
          I reverted back the changes done for bug 1210276 for bug 3321980 */
         /* Fix for Bug # 1210276: condition changed to IS NOT NULL from
           IS NULL- so that the description column is not updated to NULL
           when no value is passed. */
        IF (p_task_description <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
            p_task_description IS NULL) /* The new change for bug 3321980 */
       AND nvl(p_task_description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.description,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
           l_statement := l_statement ||
                           ' DESCRIPTION  = '||''''||
                           RTRIM(p_task_description)||''''||',';
*/
            l_statement := l_statement ||
                           ' DESCRIPTION  = :descrp ,';
            l_b_tk_desc_flag := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

--  READY_TO_BILL

       IF p_ready_to_bill_flag <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_ready_to_bill_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> nvl(l_task_rec.ready_to_bill_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_ready_to_bill_flag IS NOT NULL --redundant, but added for clarity
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' READY_TO_BILL_FLAG  = '||''''||
                             p_ready_to_bill_flag||''''||',';
*/
            l_statement := l_statement ||
                           ' READY_TO_BILL_FLAG  = :rdy_to_bill_fg ,';
            l_b_rdy_to_bill_flag := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

--  READY_TO_DISTRIBUTE

       IF p_ready_to_distribute_flag <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_ready_to_distribute_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> nvl(l_task_rec.ready_to_distribute_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_ready_to_distribute_flag IS NOT NULL --redundant, but added for clarity
       THEN
--bug 2955326
/*
           l_statement := l_statement ||
                  ' READY_TO_DISTRIBUTE_FLAG  = '||''''||
                      p_ready_to_distribute_flag||''''||',';
*/
           l_statement := l_statement ||
                  ' READY_TO_DISTRIBUTE_FLAG  = :rdy_to_dist_fg ,';
           l_b_rdy_to_dist_flag := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

--  LIMIT_TO_TXN_CONTROLS

       IF (p_limit_to_txn_controls_flag <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_limit_to_txn_controls_flag IS NULL )
       AND nvl(p_limit_to_txn_controls_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> nvl(l_task_rec.limit_to_txn_controls_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
--bug 2955326
/*
           l_statement := l_statement ||
                  ' LIMIT_TO_TXN_CONTROLS_FLAG  = '||''''||
                      p_limit_to_txn_controls_flag||''''||',';
*/
           l_statement := l_statement ||
                  ' LIMIT_TO_TXN_CONTROLS_FLAG  = :lmt_to_txn_ctrl_fg ,';
           l_b_lmt_to_txn_ctrl_fg:='Y';  -- Added for bug 3464187
           l_update_yes_flag := 'Y';

       END IF;

--  CARRYING_OUT_ORGANIZATION_ID

       IF p_carrying_out_organization_id <>
          PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND nvl(p_carrying_out_organization_id,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
          <> nvl(l_task_rec.carrying_out_organization_id,
                PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
       AND p_carrying_out_organization_id IS NOT NULL THEN
           OPEN l_get_project_info_csr (l_task_rec.project_id);
           FETCH l_get_project_info_csr INTO
                 l_project_type,l_pm_project_reference;
           CLOSE l_get_project_info_csr;

           --  Code Added for the bug#1968394
           -- Test the function security for Org changes
           --
           IF (fnd_function.test('PA_PAXPREPR_UPDATE_ORG') = TRUE) THEN
             l_org_func_security := 'Y';
           ELSE
             l_org_func_security := 'N';
           END IF;

           pa_project_utils2.validate_attribute_change(
           X_Context                => 'ORGANIZATION_VALIDATION'
          ,X_insert_update_mode     => NULL
          ,X_calling_module         => 'UPDATE_TASK'
          ,X_project_id             => l_task_rec.project_id
          ,X_task_id                => l_task_id
          ,X_old_value              =>
                    To_char(l_task_rec.carrying_out_organization_id)
          ,X_new_value              =>
                    To_char(p_carrying_out_organization_id)
          ,X_project_type           => l_project_type
          ,X_project_start_date     => NULL
          ,X_project_end_date       => NULL
          ,X_public_sector_flag     => NULL
          ,X_task_manager_person_id => l_task_rec.task_manager_person_id
          ,X_Service_type           => l_task_rec.service_type_code
          ,X_task_start_date        => l_task_rec.start_date
          ,X_task_end_date          => l_task_rec.completion_date
          ,X_entered_by_user_id     => FND_GLOBAL.USER_ID
          ,X_attribute_category     => l_task_rec.attribute_category
          ,X_attribute1             => l_task_rec.attribute1
          ,X_attribute2             => l_task_rec.attribute2
          ,X_attribute3             => l_task_rec.attribute3
          ,X_attribute4             => l_task_rec.attribute4
          ,X_attribute5             => l_task_rec.attribute5
          ,X_attribute6             => l_task_rec.attribute6
          ,X_attribute7             => l_task_rec.attribute7
          ,X_attribute8             => l_task_rec.attribute8
          ,X_attribute9             => l_task_rec.attribute9
          ,X_attribute10            => l_task_rec.attribute10
          ,X_pm_product_code        => l_task_rec.pm_product_code
          ,X_pm_project_reference   => l_pm_project_reference
          ,X_pm_task_reference      => l_task_rec.pm_task_reference
--          ,X_functional_security_flag => NULL  /* Bug#1968394  */
          ,X_functional_security_flag => l_org_func_security  /* Bug#1968394  */
          ,x_warnings_only_flag     => l_warnings_only_flag --bug3134205
          ,X_err_code               => l_err_code
          ,X_err_stage              => l_err_stage
          ,X_err_stack              => l_err_stack );

           IF l_err_code > 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                    IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                    THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_TK_CANT_CHG_TASK_ORG'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                    ELSE
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => l_err_stage
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                    END IF;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

           ELSIF l_err_code < 0
           THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

--bug 2955326
/*
           l_statement :=   l_statement ||
                        ' CARRYING_OUT_ORGANIZATION_ID = '||
                        TO_CHAR(p_carrying_out_organization_id)||',';
*/
           l_statement :=   l_statement ||
                        ' CARRYING_OUT_ORGANIZATION_ID = :cryng_out_org_id ,';
           l_b_cryng_out_org_id_flag := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

--  CHARGEABLE_FLAG

       IF  p_chargeable_flag <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
           nvl(p_chargeable_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> nvl(l_task_rec.chargeable_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN

--         Cannot update chargeable flag for parent tasks

           IF l_children_exist = 'Y'
           THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CANNOT_CHANGE_CHRG_FLAG'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
--bug 2955326
/*
           l_statement :=   l_statement ||
                        ' CHARGEABLE_FLAG  = '||''''||p_chargeable_flag||''''||',';
*/
           l_statement :=   l_statement ||
                        ' CHARGEABLE_FLAG  = :chgble_fg ,';
           l_b_chgble_fg := 'Y';
--end bug  2955326
           l_update_yes_flag := 'Y';

       END IF;

--  BILLABLE FLAG
         /* Added for bug#2666913 */

       OPEN l_get_project_type_info_csr (l_task_rec.project_id);
           FETCH l_get_project_type_info_csr INTO l_project_type_class_code;
           CLOSE l_get_project_type_info_csr;

    If p_billable_flag = 'Y' and l_project_type_class_code = 'INDIRECT'
    THEN
                p_return_status := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
        pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PR_INDIRECT_NO_BILLING'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'TASK'
               ,p_attribute1       => l_amg_segment1
               ,p_attribute2       => l_amg_task_number
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    /* end of code added for bug #2666913 */

       IF  p_billable_flag <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
           nvl(p_billable_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.billable_flag,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN

--bug 2955326
/*
           l_statement :=l_statement ||
                    ' BILLABLE_FLAG  = '||''''||p_billable_flag||''''||',';
*/
           l_statement :=l_statement ||
                    ' BILLABLE_FLAG  = :bil_fg ,';
           l_b_billable_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

--  SERVICE_TYPE_CODE

       IF p_service_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       AND nvl(p_service_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> nvl(l_task_rec.service_type_code,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_service_type_code IS NOT NULL  --redundant, but added for clarity
       THEN

       OPEN l_service_type_csr( p_service_type_code );
       FETCH l_service_type_csr INTO l_temp;

       IF l_service_type_csr%NOTFOUND
       THEN

        CLOSE l_service_type_csr;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_SERVICE_TYPE_INVALID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

       END IF;

       CLOSE l_service_type_csr;

--bug 2955326
/*
           l_statement :=   l_statement ||
                    ' SERVICE_TYPE_CODE = '||''''|| p_service_type_code||''''||',';
*/
           l_statement :=   l_statement ||
                    ' SERVICE_TYPE_CODE = :srv_tp_cd ,';
           l_b_srv_tp_cd_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

--  TASK NUMBER
--dbms_output.put_line('value of p_task_number'||p_task_number);
--dbms_output.put_line('value l_task_rec.task_number'||l_task_rec.task_number);
       IF p_task_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
        AND nvl(substrb(p_task_number,1,25),PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>   --Bug 6193314 . Added Substrb
           nvl(l_task_rec.task_number,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       AND p_task_number IS NOT NULL
       THEN

          IF pa_task_utils.check_unique_task_number
              (l_project_id,p_task_number,NULL) = 0
           THEN
       /* CODE CHANGE BEGIN BY ADITI for Bug 4120380 **/
          --dbms_output.put_line('before caling CHECK_TASK_NUMBER_CHANGE_OK');
 /* bug #5243018: Reverting the fix in bug 4120380.
          PA_PROJECT_PUB.CHECK_TASK_NUMBER_CHANGE_OK
        ( p_api_version_number => p_api_version_number
                 , p_return_status    => L_RETURN_STATUS
                 , p_msg_count      => l_msg_count
                 , p_msg_data        => l_msg_data
                 , p_project_id      => p_pa_project_id
                 , p_task_id      => p_pa_task_id
                 , p_task_number_change_Ok_flag  => task_number_change_Ok_flag
             );
       IF task_number_change_Ok_flag = 'N' then */
       /** CODE CHANGE END BY ADITI for Bug 4120380 **/
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_TASK_NUMBER_NOT_UNIQUE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           /* bug #5243018: Reverting the fix in bug 4120380.
           END IF; -- END OF IF task_number_change_Ok_flag = 'N' */
          END IF;
           IF l_children_exist = 'N'
           THEN
              pa_task_utils.change_lowest_task_num_ok
                 ( x_task_id       => l_task_id,
                   x_err_code      => l_err_code,
                   x_err_stage     => l_err_stage,
                   x_err_stack     => l_err_stack );

              IF l_err_code > 0
              THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                    IF NOT pa_project_pvt.check_valid_message (l_err_stage)
                    THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CANT_ADD_SUBTASK'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                    ELSE
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => l_err_stage
                      ,p_msg_attribute    => 'SPLIT'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'MODT'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                    END IF;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

              ELSIF l_err_code < 0
              THEN

                 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
           END IF;
--bug 2955326
/*
             l_statement :=     l_statement ||
                        ' TASK_NUMBER = '||''''|| p_task_number||''''||',';
*/
           l_statement :=   l_statement ||
                        ' TASK_NUMBER = :tk_num ,';
           l_b_tk_num_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';
           --dbms_output.put_line('Value of l_update_yes_flag in update_one_task'||l_update_yes_flag);
           --dbms_output.put_line('Value of l_b_tk_num_fg in update_one_task'||l_b_tk_num_fg);

        END IF;


     -- If task start date or completion date is to be changed
     -- need to compare it with the project dates and hence
     -- first fetch the project dates
/* Fix for the Bug 1210276- the following If condition was modified by adding
  NVL to the statment to prevent the updation of the start date and end date
  column with null values when no values are passed for these variables */

        IF (NVL(p_task_start_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
        OR  NVL(p_task_completion_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        THEN
            OPEN  l_project_date_csr (l_project_id);
            FETCH l_project_date_csr INTO l_project_date_rec;
            CLOSE l_project_date_csr;
     --   END IF;
/* Fix for the Bug 1210276- relocated this END IF to the logical end of the
   block so that the update would only happen when the above conditions
   are true */
    --Check validity of start and completion date (e.g. start_date can not be later than completion_date)

pa_project_pvt.check_start_end_date(     p_old_start_date       => l_task_rec.start_date
                    ,p_new_start_date       => p_task_start_date
                    ,p_old_end_date         => l_task_rec.completion_date
                    ,p_new_end_date         => p_task_completion_date
                    ,p_update_start_date_flag   => l_update_start_date_flag
                    ,p_update_end_date_flag     => l_update_end_date_flag
                    ,p_return_status        => l_return_status  );

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF pa_project_pub.G_ParChildTsk_chks_deferred = 'N' THEN
      IF l_children_exist = 'Y' THEN
         OPEN l_outer_child_dates_csr (l_project_id,l_task_id);
         FETCH l_outer_child_dates_csr INTO
               l_min_child_start_date, l_max_child_completion_date;
         CLOSE l_outer_child_dates_csr;
      END IF;

      IF l_task_rec.parent_task_id IS NOT NULL THEN
              OPEN l_outer_parent_dates_csr
                   (l_project_id,l_task_rec.parent_task_id );
              FETCH l_outer_parent_dates_csr INTO
                    l_min_parent_start_date,l_max_parent_completion_date;
              CLOSE l_outer_parent_dates_csr;
      END IF;
 END IF;
       IF l_update_start_date_flag = 'Y'
       THEN

           IF p_task_start_date < l_project_date_rec.start_date OR
              p_task_start_date > l_project_date_rec.completion_date
           THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_TK_OUTSIDE_PROJECT_RANGE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;

  -- Do the comparison between parent and child task dates only if
  -- the global variable is set to 'N'

  IF pa_project_pub.G_ParChildTsk_chks_deferred = 'N' THEN
      IF l_children_exist = 'Y' THEN
         IF l_min_child_start_date < p_task_start_date THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CHILD_START_EARLIER'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      IF l_task_rec.parent_task_id IS NOT NULL THEN
         IF l_min_parent_start_date > p_task_start_date THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PARENT_START_LATER'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
            END IF;
            RAISE  FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END IF;  -- End if pa_project_pub.G_ParChildTsk_chks_deferred

--BUG 4081329 rtarway, validate for EI date also
PA_TASKS_MAINT_UTILS.Check_Start_Date_EI(
          p_project_id => l_project_id,
          p_task_id => l_task_id,
          p_start_date => p_task_start_date,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);
IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
END IF;
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' START_DATE = to_date('''||
                          to_char(p_task_start_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
           l_statement :=   l_statement ||
                     ' START_DATE = :st_dt ,';
           l_b_tk_st_dt_flag := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

       IF l_update_end_date_flag = 'Y'
       THEN
           IF p_task_completion_date < l_project_date_rec.start_date OR
              p_task_completion_date > l_project_date_rec.completion_date
           THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_TK_OUTSIDE_PROJECT_RANGE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;

  -- Do the comparison between parent and child task dates only if
  -- the global variable is set to 'N'

        IF pa_project_pub.G_ParChildTsk_chks_deferred = 'N' THEN
           IF l_children_exist = 'Y' THEN
              IF l_max_child_completion_date > p_task_completion_date THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CHILD_COMPLETION_LATER'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
              END IF;
           END IF;

           IF l_task_rec.parent_task_id IS NOT NULL
           THEN
            IF l_max_parent_completion_date < p_task_completion_date
              THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PARENT_COMPLETION_EARLIER'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
             END IF;
           END IF;
        END IF;  -- End if pa_project_pub.G_ParChildTsk_chks_deferred;

--BUG 4081329, rtarway
-- Validate for END EI dates too

PA_TASKS_MAINT_UTILS.Check_End_Date_EI(
          p_project_id => l_project_id,
          p_task_id => l_task_id,
          p_end_date => p_task_completion_date,
          x_return_status => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data);
IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
END IF;
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' COMPLETION_DATE = to_date('''||
                          to_char(p_task_completion_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';

*/
           l_statement :=   l_statement ||
                     ' COMPLETION_DATE = :cmp_dt ,';
           l_b_comp_dt_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

        END IF;
END IF;
/* Fix for the Bug 1210276- relocated this END IF here
   so that the update would only happen when the above conditions
   are true */

--PARENT TASK

    --convert_taskref_to_id can not be used because NULL is allowed for the pa_parent_task_id!!!

    --rtarway, for DHI ER, BUG 4413568 , following section will be changing the WBS , it involves, moving
    --a task. This should not be allowed when p_update_mode is PA_UPD_TASK_ATTR
    --Error will be raised , when parent_task_id is different than existing.


    l_new_parent_task_id := NULL;
        IF p_pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
           AND p_pa_parent_task_id IS NOT NULL THEN
           IF p_pa_parent_task_id <> NVL( l_task_rec.parent_task_id, -9999 ) THEN
         OPEN l_validate_parent_id_csr( l_project_id, p_pa_parent_task_id );
             FETCH l_validate_parent_id_csr INTO l_temp;
         IF l_validate_parent_id_csr%NOTFOUND
        THEN
        CLOSE l_validate_parent_id_csr;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PARENT_TASK_ID_INVALID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         ELSE
        CLOSE l_validate_parent_id_csr;
        l_new_parent_task_id := p_pa_parent_task_id;
         END IF;
           END IF;
        ELSE
             IF p_pm_parent_task_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
                p_pm_parent_task_reference IS NOT NULL THEN
        OPEN l_convert_pm_parent_to_id_csr
                     (l_project_id, p_pm_parent_task_reference );
        FETCH l_convert_pm_parent_to_id_csr INTO l_new_parent_task_id;
        IF l_convert_pm_parent_to_id_csr%NOTFOUND THEN
           CLOSE l_convert_pm_parent_to_id_csr;
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PARENT_TASK_MISSING'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                   END IF;
                   RAISE  FND_API.G_EXC_ERROR;
        END IF;
        CLOSE l_convert_pm_parent_to_id_csr;
             END IF;
        END IF;


/* dbms_output.put_line('Task id            : '||l_task_id); */
/* dbms_output.put_line('pm_parent_task_ref : '||p_pm_parent_task_reference); */
/* dbms_output.put_line('p_pa_parent_task_id    : '||p_pa_parent_task_id); */
/* dbms_output.put_line('Old Task Name      : '||l_task_rec.task_name); */
/* dbms_output.put_line('New parent id      : '||l_new_parent_task_id); */
/* dbms_output.put_line('Old parent id      : '|| */
--         Nvl(l_task_rec.parent_task_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM));

      IF p_pm_parent_task_reference IS NULL AND
         l_task_rec.parent_task_id IS NOT NULL THEN

       -- this means that a sub task is being changed to become a top task
       -- which is not allowed

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_TOP_TASK_NOT_ALLOWED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
          END IF;
          RAISE  FND_API.G_EXC_ERROR;
      END IF;


        IF l_new_parent_task_id IS NOT NULL
           AND l_new_parent_task_id <> NVL(l_task_rec.parent_task_id,
                   PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        THEN
        --rtarway, for DHI ER, BUG 4413568
    IF ( PA_PROJECT_PUB.G_TASK_STR_UPDATE_MODE = 'PA_UPD_TASK_ATTR' ) THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
              p_msg_name => 'PA_WBS_CANT_CHANGE');
              RAISE FND_API.G_EXC_ERROR;
    END IF;

           -- get the wbs_level for the new parent task
       OPEN l_parent_wbs_csr ( l_project_id, l_new_parent_task_id );
       FETCH l_parent_wbs_csr INTO l_new_parent_wbs_level;
       CLOSE l_parent_wbs_csr;

/*
           --bug 2947492
            PA_FIN_PLAN_UTILS.CHECK_REPARENT_TASK_OK(
                     p_task_id                    => l_task_id
                    ,p_old_parent_task_id         => l_task_rec.parent_task_id
                    ,p_new_parent_task_id         => l_new_parent_task_id
                    ,x_return_status              => l_return_status
                    ,x_msg_count                  => l_msg_count
                    ,x_msg_data                   => l_msg_data
                );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
            THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_ERROR
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
           --End bug 2947492
*/  --commented out as per mail from venkatesh dated 22 jan 2004 -- maansari
       --bug 3010538
       --The following code should be executed when a task's parent is modified
       --in a working version( with already existing a published ver ) and
       --then its published.
       --In other words the code is executed while publishing to sync up with
       --pa_tasks. In regular flow for updating parent of a task we call this api
       --from the wrapper process_task_structure_bulk api.
       --
       IF p_pm_product_code = 'WORKPLAN'
       THEN
          pa_fp_refresh_elements_pub.set_process_flag_proj(
              p_project_id               => l_project_id
             ,p_request_id               => null
             ,p_process_code             => null
             ,p_refresh_required_flag    => 'Y'
             ,x_return_status            => l_return_status
             ,x_msg_count                => l_msg_count
             ,x_msg_data                 => l_msg_data );

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             RAISE FND_API.G_EXC_ERROR;
          end if;
       END IF;
       --bug 3010538


           -- If the parent task id is to be changed, then need to check
           -- whether it is ok the change the parent

-- *O
       -- Check if task is being moved to lower level within it's own hierarchy
       --//For the task being moved check if the new_parent_task_id already exists in the children.

        OPEN l_chk_chlds_parent_id_csr (l_task_id, l_new_parent_task_id);
        FETCH l_chk_chlds_parent_id_csr INTO l_temp;

        IF l_chk_chlds_parent_id_csr%FOUND
        THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                    pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_TSK_MV_BELOW_SELF'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                     ,p_msg_context     => 'TASK'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => l_amg_task_number
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                    END IF;
                    RAISE  FND_API.G_EXC_ERROR;
        END IF;
        CLOSE l_chk_chlds_parent_id_csr;


           -- Check If new parent has  Expenditure Item.
        PA_TASK_UTILS.Check_Create_Subtask_Ok
            ( x_task_id =>  l_new_parent_task_id
--bug 3010538                        , x_validation_mode => 'R'    --bug 2947492
            , x_err_code    =>  l_err_code
            , x_err_stage   =>  l_err_stage
            , x_err_stack   =>  l_err_stack );

          IF l_err_code > 0
              THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                  IF NOT pa_project_pvt.check_valid_message(l_err_stage)
                  THEN
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => 'PA_CHECK_ADD_SUBTASK_FAILED'
                           ,p_msg_attribute    => 'CHANGE'
                           ,p_resize_flag      => 'Y'
                           ,p_msg_context      => 'ADDT'
                           ,p_attribute1       => l_amg_segment1
                           ,p_attribute2       => l_amg_task_number
                           ,p_attribute3       => ''
                           ,p_attribute4       => ''
                           ,p_attribute5       => '');
                  ELSE
                     pa_interface_utils_pub.map_new_amg_msg
                      ( p_old_message_code => l_err_stage
                       ,p_msg_attribute    => 'SPLIT'
                       ,p_resize_flag      => 'Y'
                       ,p_msg_context      => 'ADDST'
                       ,p_attribute1       => l_amg_segment1
                       ,p_attribute2       => l_amg_task_number
                       ,p_attribute3       => ''
                       ,p_attribute4       => ''
                       ,p_attribute5       => '');
                  END IF; -- IF Pa_project_pvt.check_valid_message

                 END IF; -- IF Check_msg_Level

                 RAISE FND_API.G_EXC_ERROR;

          END IF;
-- *O


           IF l_task_rec.parent_task_id IS NULL
           THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_CANT_MOVE_TOP_TASK'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

       ELSIF l_new_parent_task_id IS NULL
       THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_TOP_TASK_NOT_ALLOWED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => p_pm_task_reference
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
       ELSE

              OPEN l_top_task_csr (l_new_parent_task_id);
              FETCH l_top_task_csr INTO l_top_task_id;
              CLOSE l_top_task_csr;

/*             dbms_output.put_line('Current top task:'||l_task_rec.top_task_id); */
/*             dbms_output.put_line('New top task    :'||l_top_task_id); */

              IF l_top_task_id <> l_task_rec.top_task_id
              THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_CANT_CHANGE_PARENT'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                    END IF;
                    RAISE  FND_API.G_EXC_ERROR;
              END IF;

           END IF;

--bug 2955326
/*
           l_statement :=   l_statement ||
                    ' PARENT_TASK_ID = '||TO_CHAR(l_new_parent_task_id)||',';
*/
           l_statement :=   l_statement ||
                    ' PARENT_TASK_ID = :prt_tk_id ,';
           l_b_prt_tk_id_fg := 'Y';
--end bug 2955326
           l_tasks_restructured_flag := 'Y';
           l_update_yes_flag := 'Y';

       --check whether the WBS level was changed
/* dbms_output.put_line('current level  : '||l_task_rec.wbs_level); */
/* dbms_output.put_line('New parent level  : '||l_new_parent_wbs_level); */

       IF l_task_rec.wbs_level <> l_new_parent_wbs_level + 1
       THEN

        l_delta_level := (l_new_parent_wbs_level + 1) - l_task_rec.wbs_level;

        OPEN l_wbs_level_csr( l_task_id );
        FETCH l_wbs_level_csr INTO l_wbs_change_task_id;

        WHILE l_wbs_level_csr%FOUND LOOP

            UPDATE pa_tasks
            SET wbs_level = wbs_level + l_delta_level
            WHERE task_id = l_wbs_change_task_id;

            FETCH l_wbs_level_csr INTO l_wbs_change_task_id;
        END LOOP;

       END IF;
        END IF;

--ADDRESS
/* dbms_output.put_line('New Address: '||p_address_id); */
/* dbms_output.put_line('Current Addres: '||l_task_rec.address_id); */
    IF ( p_address_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_address_id IS NULL )
    AND nvl(p_address_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> nvl(l_task_rec.address_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN

        IF p_address_id IS NOT NULL
        THEN

            --check whether this is the address of one of the project customers

            OPEN l_customer_csr( l_project_id );
            FETCH l_customer_csr INTO l_customer_id;

/* dbms_output.put_line('Customer: '||l_customer_id); */

            l_address_valid:= 'N';

            WHILE l_customer_csr%FOUND LOOP

                OPEN l_address_csr(l_customer_id, p_address_id);
                FETCH l_address_csr INTO l_temp;

                IF l_address_csr%FOUND
                THEN
                    l_address_valid:= 'Y';
                    EXIT; END IF;

                    CLOSE l_address_csr;

                    FETCH l_customer_csr INTO l_customer_id;
                END LOOP;

                CLOSE l_customer_csr;

            IF l_address_valid = 'N'
            THEN
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_TASK_ADDRESS_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                        END IF;
                        RAISE  FND_API.G_EXC_ERROR;

            END IF;
        END IF;

--bug 2955326
/*
            l_statement :=  l_statement ||
                    ' ADDRESS_ID = '||''''||TO_CHAR(p_address_id)||''''||',';
*/
            l_statement :=  l_statement ||
                    ' ADDRESS_ID = :addr_id ,';
                l_b_addr_id_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

    END IF;


 --bug 6153503
    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute_category IS NULL) THEN

           l_attribute_category := p_attribute_category;
    ELSE
           l_attribute_category := l_task_rec.attribute_category;
    END IF;


    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute1 IS NULL)  THEN

           l_attribute1 := p_attribute1;
    ELSE
           l_attribute1 := l_task_rec.attribute1;
    END IF;

    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute2 IS NULL)  THEN

           l_attribute2 := p_attribute2;
    ELSE
           l_attribute2 := l_task_rec.attribute2;
    END IF;

    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute3 IS NULL)  THEN

           l_attribute3 := p_attribute3;
    ELSE
           l_attribute3 := l_task_rec.attribute3;
    END IF;

    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute4 IS NULL)  THEN

           l_attribute4 := p_attribute4;
    ELSE
           l_attribute4 := l_task_rec.attribute4;
    END IF;

    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute5 IS NULL)  THEN

           l_attribute5 := p_attribute5;
    ELSE
           l_attribute5 := l_task_rec.attribute5;
    END IF;

    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute6 IS NULL)  THEN

           l_attribute6:= p_attribute6;
    ELSE
           l_attribute6 := l_task_rec.attribute6;
    END IF;

    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute7 IS NULL)  THEN

           l_attribute7:= p_attribute7;
    ELSE
           l_attribute7 := l_task_rec.attribute7;
    END IF;

    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute8 IS NULL)  THEN

           l_attribute8:= p_attribute8;
    ELSE
           l_attribute8 := l_task_rec.attribute8;
    END IF;

    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute9 IS NULL)  THEN

           l_attribute9:= p_attribute9;
    ELSE
           l_attribute9 := l_task_rec.attribute9;
    END IF;

    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute10 IS NULL)  THEN

           l_attribute10 := p_attribute10;
    ELSE
           l_attribute10 := l_task_rec.attribute10;
    END IF;
    /* Bug 7403227 start */
BEGIN
 IF p_pa_project_id IS NOT NULL THEN
  SELECT PROJECT_TYPE
    INTO l_project_type2
    FROM PA_PROJECTS
   WHERE PROJECT_ID = p_pa_project_id;
 ELSE
  SELECT PROJECT_TYPE
    INTO l_project_type2
    FROM PA_PROJECTS
   WHERE PROJECT_ID IN (SELECT PROJECT_ID
                          FROM PA_TASKS
                         WHERE TASK_ID = p_pa_task_id);
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  RAISE FND_API.G_EXC_ERROR; /* Raise error unknown if the query fails! */
END;
/* Bug 7403227 end */

/*
            l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY  = '||''''||
                           RTRIM(p_attribute_category)||''''||',';
*/
            --BUG 3908013, rtarway, Validate for financial dff
             --bug 6153503
IF l_project_type2 <> 'AWARD_PROJECT' THEN /* Bug 7403227*/
             pa_task_utils.validate_flex_fields(
                  p_desc_flex_name        => 'PA_TASKS_DESC_FLEX'
                 ,p_attribute_category    => l_attribute_category
                 ,p_attribute1            => l_attribute1
                 ,p_attribute2            => l_attribute2
                 ,p_attribute3            => l_attribute3
                 ,p_attribute4            => l_attribute4
                 ,p_attribute5            => l_attribute5
                 ,p_attribute6            => l_attribute6
                 ,p_attribute7            => l_attribute7
                 ,p_attribute8            => l_attribute8
                 ,p_attribute9            => l_attribute9
                 ,p_attribute10           => l_attribute10
                 ,p_RETURN_msg            => l_return_msg
                 ,p_validate_status       => l_validate_status
                 );
                 IF l_validate_status = 'N'
                    THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                         THEN
                              pa_interface_utils_pub.map_new_amg_msg
                                        ( p_old_message_code => 'PA_INVALID_FF_VALUES'
                                        ,p_msg_attribute    => 'CHANGE'
                                        ,p_resize_flag      => 'N'
                                        ,p_msg_context      => 'FLEX'
                                        ,p_attribute1       => l_return_msg
                                        ,p_attribute2       => ''
                                        ,p_attribute3       => ''
                                        ,p_attribute4       => ''
                                        ,p_attribute5       => '');
                        END IF;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
END IF; /* Bug 7403227 */
--  Update the dff fields  - 04/11/97
         --bug 6153503 start
       IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute_category IS NULL)
       AND nvl(p_attribute_category,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute_category,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326

            l_statement := l_statement ||
                           ' ATTRIBUTE_CATEGORY  = :attr_cat ,';
            l_b_attr_cat_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;


       IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute1 IS NULL)
       AND nvl(p_attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute1,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE1  = '||''''||
                           RTRIM(p_attribute1)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE1  = :attr1 ,';
            l_b_attr1_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute2 IS NULL)
       AND nvl(p_attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute2,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE2  = '||''''||
                           RTRIM(p_attribute2)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE2  = :attr2 ,';
            l_b_attr2_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute3 IS NULL)
       AND nvl(p_attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute3,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE3  = '||''''||
                           RTRIM(p_attribute3)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE3  = :attr3 ,';
            l_b_attr3_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute4 IS NULL)
       AND nvl(p_attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute4,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE4  = '||''''||
                           RTRIM(p_attribute4)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE4  = :attr4 ,';
            l_b_attr4_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute5 IS NULL)
       AND nvl(p_attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute5,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE5  = '||''''||
                           RTRIM(p_attribute5)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE5  = :attr5 ,';
            l_b_attr5_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute6 IS NULL)
       AND nvl(p_attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute6,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE6  = '||''''||
                           RTRIM(p_attribute6)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE6  = :attr6 ,';
            l_b_attr6_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute7 IS NULL)
       AND nvl(p_attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute7,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE7  = '||''''||
                           RTRIM(p_attribute7)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE7  = :attr7 ,';
            l_b_attr7_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute8 IS NULL)
       AND nvl(p_attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute8,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE8  = '||''''||
                           RTRIM(p_attribute8)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE8  = :attr8 ,';
            l_b_attr8_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute9 IS NULL)
       AND nvl(p_attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute9,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE9  = '||''''||
                           RTRIM(p_attribute9)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE9  = :attr9 ,';
            l_b_attr9_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
           p_attribute10 IS NULL)
       AND nvl(p_attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.attribute10,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ATTRIBUTE10  = '||''''||
                           RTRIM(p_attribute10)||''''||',';
*/
            l_statement := l_statement ||
                           ' ATTRIBUTE10  = :attr10 ,';
            l_b_attr10_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;
 --bug 6153503 end
-- IC and Multi National Currency changes Starts ...

       IF (p_allow_cross_charge_flag <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
           p_allow_cross_charge_flag IS NOT NULL)
       AND nvl(p_allow_cross_charge_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.allow_cross_charge_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' ALLOW_CROSS_CHARGE_FLAG  = '||''''||
                           RTRIM(p_allow_cross_charge_flag)||''''||',';
*/
            l_statement := l_statement ||
                           ' ALLOW_CROSS_CHARGE_FLAG  = :all_x_chg_fg ,';
            l_b_al_x_chg_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR AND
           p_project_rate_type IS NOT NULL)
       AND nvl(p_project_rate_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <>
           nvl(l_task_rec.project_rate_type,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR )
       THEN
--bug 2955326
/*
            l_statement := l_statement ||
                           ' PROJECT_RATE_TYPE  = '||''''||
                           RTRIM(p_project_rate_type)||''''||',';
*/
            l_statement := l_statement ||
                           ' PROJECT_RATE_TYPE  = :prj_rt_tp ,';
            l_b_prj_rt_tp_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF (p_project_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
           p_project_rate_date IS NOT NULL)
       AND nvl(p_project_rate_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
           nvl(l_task_rec.project_rate_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE )
       THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' PROJECT_RATE_DATE = to_date('''||
                          to_char(p_project_rate_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
            l_statement :=   l_statement ||
                     ' PROJECT_RATE_DATE = :prj_rt_dt ,';
            l_b_prj_rt_dt_fg := 'Y';
--end bug 2955326
            l_update_yes_flag := 'Y';

       END IF;

       IF p_cc_process_labor_flag  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_cc_process_labor_flag IS NOT NULL  THEN
          IF NVL(p_cc_process_labor_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.cc_process_labor_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' CC_PROCESS_LABOR_FLAG =  '||''''||
             RTRIM(p_cc_process_labor_flag)||''''||',';
*/
             l_statement  := l_statement ||
                       ' CC_PROCESS_LABOR_FLAG = :cc_proc_lbr_fg ,';
             l_b_cc_proc_lbr_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
-- 5402979 for pqe bug 5395048 :: added p_project_in.labor_tp_schedule_id IS NULL condition
IF (   (p_labor_tp_schedule_id  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_labor_tp_schedule_id IS NOT NULL)
    OR (p_labor_tp_schedule_id IS NULL) )
   THEN
       -- 5402979 for pqe bug 5395048 :: added p_project_in.labor_tp_schedule_id IS NULL condition
       IF ( (p_labor_tp_schedule_id <> NVL(l_task_rec.labor_tp_schedule_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
            OR (p_labor_tp_schedule_id IS NULL) )
              THEN
--bug 2955326
/*
             l_statement := l_statement || ' LABOR_TP_SCHEDULE_ID = ' ||
                  TO_CHAR(p_labor_tp_schedule_id)||',';
*/
             l_statement := l_statement || ' LABOR_TP_SCHEDULE_ID = :lbr_tp_sch_id ,';
             l_b_lbr_tp_sch_id_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
             -- 5402979 Added the code below for Bug 5395048. If labor schedule id is being NULLed out, then
             -- we need to set the project cross charge process labor flag to 'N'
             IF p_labor_tp_schedule_id IS NULL THEN
                 l_cc_process_labor_flag := 'N';

                 IF l_b_cc_proc_lbr_fg = 'N' THEN
                         l_statement  := l_statement ||
                               ' CC_PROCESS_LABOR_FLAG = :cc_proc_lbr_fg ,';
                 End if;

                 l_b_cc_proc_lbr_fg := 'Y';
                 l_update_yes_flag := 'Y';
             END IF;
             -- Code changes end for Bug 5395048
          END IF;
       END IF;

       IF p_labor_tp_fixed_date  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_labor_tp_fixed_date IS NOT NULL  THEN
          IF NVL(p_labor_tp_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
           <> NVL(l_task_rec.labor_tp_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' LABOR_TP_FIXED_DATE =  to_date('''||
                     to_char(p_labor_tp_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' LABOR_TP_FIXED_DATE = :lbr_tp_fx_dt ,';
             l_b_lbr_tp_fx_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_cc_process_nl_flag  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_cc_process_nl_flag IS NOT NULL  THEN
          IF NVL(p_cc_process_nl_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.cc_process_nl_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' CC_PROCESS_NL_FLAG =  '||''''||
             RTRIM(p_cc_process_nl_flag)||''''||',';
*/
             l_statement  := l_statement ||
                       ' CC_PROCESS_NL_FLAG = :cc_proc_nl_fg ,';
             l_b_cc_proc_nl_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
-- 5402979 for pqe bug 5395048 :: added p_project_in.labor_tp_schedule_id IS NULL condition
IF ( ( p_nl_tp_schedule_id  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_nl_tp_schedule_id IS NOT NULL )
     OR (p_nl_tp_schedule_id IS NULL) )
   THEN
       -- 5402979 for pqe bug 5395048 :: added p_project_in.labor_tp_schedule_id IS NULL condition
       IF ( (p_nl_tp_schedule_id <> NVL(l_task_rec.nl_tp_schedule_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
           OR (p_nl_tp_schedule_id IS NULL))
           THEN
--bug 2955326
/*
             l_statement := l_statement || ' NL_TP_SCHEDULE_ID = ' ||
                  TO_CHAR(p_nl_tp_schedule_id)||',';
*/
             l_statement := l_statement || ' NL_TP_SCHEDULE_ID = :nl_tp_sch_id ,';
             l_b_nl_tp_sch_id_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
             -- 5402979 Added the code below for Bug 5395048. If labor schedule id is being NULLed out, then
             -- we need to set the project cross charge process labor flag to 'N'
             IF p_nl_tp_schedule_id IS NULL THEN
                 l_cc_process_nl_flag := 'N';

                 IF l_b_cc_proc_nl_fg = 'N' THEN
                         l_statement  := l_statement ||
                               ' CC_PROCESS_NL_FLAG = :CC_PROC_NL_FG ,';
                 End if;

                 l_b_cc_proc_nl_fg := 'Y';
                 l_update_yes_flag := 'Y';
             END IF;
             -- Code changes end for Bug 5395048
          END IF;
       END IF;

       IF p_nl_tp_fixed_date  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_nl_tp_fixed_date IS NOT NULL  THEN
          IF NVL(p_nl_tp_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
           <> NVL(l_task_rec.nl_tp_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' NL_TP_FIXED_DATE =  to_date('''||
                     to_char(p_nl_tp_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' NL_TP_FIXED_DATE = :nl_tp_fx_dt ,';
             l_b_nl_tp_fx_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_receive_project_invoice_flag  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_receive_project_invoice_flag IS NOT NULL  THEN
          IF NVL(p_receive_project_invoice_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.receive_project_invoice_flag,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' RECEIVE_PROJECT_INVOICE_FLAG =  '||''''||
             RTRIM(p_receive_project_invoice_flag)||''''||',';
*/
             l_statement  := l_statement ||
                       ' RECEIVE_PROJECT_INVOICE_FLAG = :rcv_prj_inv_fg ,';
             l_b_rcv_prj_inv_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

--Added for bug 5745545
       IF nvl(p_work_type_id,-999)  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		IF (nvl(fnd_profile.value('PA_EN_NEW_WORK_TYPE_PROCESS'),'N') = 'Y') OR (nvl(pa_install.is_prm_licensed(),'N') = 'Y' ) THEN
				IF p_work_type_id IS NULL AND (NOT (PA_GMS_API.vert_install)) THEN
					      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
						   pa_interface_utils_pub.map_new_amg_msg
						   ( p_old_message_code => 'PA_TASK_WORK_TYPE_MAND'
						    ,p_msg_attribute    => 'CHANGE'
						    ,p_resize_flag      => 'N'
						    ,p_msg_context      => 'TASK'
						    ,p_attribute1       => l_amg_segment1
						    ,p_attribute2       => l_amg_task_number
						    ,p_attribute3       => ''
						    ,p_attribute4       => ''
						    ,p_attribute5       => '');
					      END IF;
					      RAISE  FND_API.G_EXC_ERROR;
			        ELSE
					IF nvl(p_work_type_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> nvl(l_task_rec.work_type_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
					--bug 2955326
					/*
						     l_statement := l_statement || ' WORK_TYPE_ID = ' ||
							  TO_CHAR(p_work_type_id)||',';
					*/
						     l_statement := l_statement || ' WORK_TYPE_ID = :wk_tp_id ,';
						     l_b_wk_tp_id_fg := 'Y';
					--end bug 2955326
						     l_update_yes_flag := 'Y';
					END IF;
				END IF;
		ELSE  -- Null work_type_id is allowed
			IF nvl(p_work_type_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> nvl(l_task_rec.work_type_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
			     l_statement := l_statement || ' WORK_TYPE_ID = :wk_tp_id ,';
			     l_b_wk_tp_id_fg := 'Y';
			     l_update_yes_flag := 'Y';
			END IF;
		END IF;
	END IF;
--End for bug 5745545

-- IC and Multi National Currency changes Ends ...
/* Commented for bug 2802984 starts*/
       /*IF p_emp_bill_rate_schedule_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_emp_bill_rate_schedule_id IS NOT NULL  THEN
          IF p_emp_bill_rate_schedule_id <> l_task_rec.emp_bill_rate_schedule_id
              THEN
             l_statement := l_statement || ' EMP_BILL_RATE_SCHEDULE_ID = ' ||
                  TO_CHAR(p_emp_bill_rate_schedule_id)||',';
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_job_bill_rate_schedule_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_job_bill_rate_schedule_id IS NOT NULL  THEN
          IF p_job_bill_rate_schedule_id <> l_task_rec.job_bill_rate_schedule_id
              THEN
             l_statement := l_statement || ' JOB_BILL_RATE_SCHEDULE_ID = ' ||
                  TO_CHAR(p_job_bill_rate_schedule_id)||',';
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_non_lab_std_bill_rt_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_non_lab_std_bill_rt_sch_id IS NOT NULL  THEN
          IF p_non_lab_std_bill_rt_sch_id <> l_task_rec.non_lab_std_bill_rt_sch_id
              THEN
             l_statement := l_statement || ' NON_LAB_STD_BILL_RT_SCH_ID = ' ||
                  TO_CHAR(p_non_lab_std_bill_rt_sch_id)||',';
             l_update_yes_flag := 'Y';
          END IF;
       END IF;*/
  /* Commented for bug 2802984 ends*/

       IF p_taskfunc_cost_rate_date  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_taskfunc_cost_rate_date IS NOT NULL  THEN
          IF NVL(p_taskfunc_cost_rate_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
           <> NVL(l_task_rec.taskfunc_cost_rate_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' TASKFUNC_COST_RATE_DATE =  to_date('''||
                     to_char(p_taskfunc_cost_rate_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' TASKFUNC_COST_RATE_DATE = :tkfnc_cst_rt_dt ,';
             l_b_tkfnc_cst_rt_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_taskfunc_cost_rate_type  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_taskfunc_cost_rate_type IS NOT NULL  THEN
          IF NVL(p_taskfunc_cost_rate_type,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.taskfunc_cost_rate_type,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' TASKFUNC_COST_RATE_TYPE =  '||''''||
             RTRIM(p_taskfunc_cost_rate_type)||''''||',';
*/
             l_statement  := l_statement ||
                       ' TASKFUNC_COST_RATE_TYPE = :tkfnc_cst_rt_tp ,';
             l_b_tkfnc_cst_rt_tp_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

--Sakthi MCB

--PA L Changes 2872708

       IF p_retirement_cost_flag  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_retirement_cost_flag IS NOT NULL  THEN
          IF NVL(p_retirement_cost_flag, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.retirement_cost_flag, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' RETIREMENT_COST_FLAG =  '||''''||
             RTRIM(p_retirement_cost_flag)||''''||',';
*/
             l_statement  := l_statement ||
                       ' RETIREMENT_COST_FLAG = :ret_cst_fg ,';
             l_b_ret_cst_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_cint_eligible_flag  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_cint_eligible_flag IS NOT NULL  THEN
          IF NVL(p_cint_eligible_flag, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.cint_eligible_flag, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' CINT_ELIGIBLE_FLAG =  '||''''||
             RTRIM(p_cint_eligible_flag)||''''||',';
*/
             l_statement  := l_statement ||
                       ' CINT_ELIGIBLE_FLAG = :cint_elg_fg ,';
             l_b_cint_elg_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_cint_stop_date  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_cint_stop_date IS NOT NULL  THEN
          IF NVL(p_cint_stop_date, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
           <> NVL(l_task_rec.cint_stop_date, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' CINT_STOP_DATE =  '||''''||
             RTRIM(p_cint_stop_date)||''''||',';
*/
             l_statement  := l_statement ||
                       ' CINT_STOP_DATE = :cint_stp_dt ,';
             l_b_cint_stp_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
--End PA L Changes 2872708


 /* Commented for bug 2802984 starts*/

     /*  IF p_labor_disc_reason_code  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_labor_disc_reason_code IS NOT NULL  THEN
          IF NVL(p_labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN

             l_statement  := l_statement ||
                       ' LABOR_DISC_REASON_CODE =  '||''''||
             RTRIM(p_labor_disc_reason_code)||''''||',';
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

       IF p_non_labor_disc_reason_code  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_non_labor_disc_reason_code IS NOT NULL  THEN
          IF NVL(p_non_labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.non_labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
             l_statement  := l_statement ||
                       ' NON_LABOR_DISC_REASON_CODE =  '||''''||
             RTRIM(p_non_labor_disc_reason_code)||''''||',';
             l_update_yes_flag := 'Y';
          END IF;
       END IF;*/

 /* Commented for bug 2802984 ends*/

 /*Code for bug 2802984 starts*/

  Check_Schedule_type
     (p_pa_task_id             => l_task_id,
      p_pa_project_id          => l_project_id,
      p_in_labor_sch_type      => p_labor_sch_type,
      p_in_nl_sch_type         => p_nl_sch_type,
      p_task_name              => p_task_name,
      p_pm_task_reference      => p_pm_task_reference,
      p_out_labor_sch_type     => l_out_labor_sch_type,
      p_out_nl_labor_sch_type  => l_out_nl_labor_sch_type,
      p_return_status          => l_return_status
      );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

   validate_schedule_values
   (p_pa_project_id                  => l_project_id,
    p_pa_task_id                     => l_task_id,
    p_task_name                      => p_task_name,
    p_pm_task_reference              => p_pm_task_reference,
    p_lab_db_sch_type                => l_task_rec.labor_sch_type,
    p_nl_db_sch_type                 => l_task_rec.non_labor_sch_type,
    p_labor_sch_type                 => l_out_labor_sch_type,
    p_nl_sch_type            => l_out_nl_labor_sch_type,
    p_emp_bill_rate_schedule_id      => p_emp_bill_rate_schedule_id,
    p_job_bill_rate_schedule_id      => p_job_bill_rate_schedule_id,
    p_labor_schedule_fixed_date      => p_labor_schedule_fixed_date,
    p_labor_schedule_discount        => p_labor_schedule_discount,
    p_labor_disc_reason_code         => p_labor_disc_reason_code,
    p_nl_bill_rate_org_id            => p_nl_bill_rate_org_id,
    p_non_lab_std_bill_rt_sch_id     => p_non_lab_std_bill_rt_sch_id,
    p_nl_schedule_fixed_date         => p_nl_schedule_fixed_date,
    p_nl_schedule_discount           => p_nl_schedule_discount,
    p_non_labor_disc_reason_code     => p_non_labor_disc_reason_code,
    p_rev_ind_rate_sch_id            => p_rev_ind_rate_sch_id,
    p_inv_ind_rate_sch_id            => p_inv_ind_rate_sch_id,
    p_rev_ind_sch_fixed_date         => p_rev_ind_sch_fixed_date,
    p_inv_ind_sch_fixed_date         => p_inv_ind_sch_fixed_date,
    p_return_status                  => l_return_status
    );

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN

            RAISE FND_API.G_EXC_ERROR;
        END IF;


 IF p_labor_sch_type  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_labor_sch_type IS NOT NULL
  THEN
          IF p_labor_sch_type <> NVL(l_task_rec.LABOR_SCH_TYPE,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
         l_statement  := l_statement ||' LABOR_SCH_TYPE =  '||''''||
             RTRIM(p_labor_sch_type)||''''||',';
*/
         l_statement  := l_statement ||' LABOR_SCH_TYPE = :lbr_sch_tp ,';
             l_b_lbr_sch_tp_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

  IF p_nl_sch_type  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_nl_sch_type IS NOT NULL
  THEN
   IF p_nl_sch_type
           <> NVL(l_task_rec.NON_LABOR_SCH_TYPE,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
         l_statement  := l_statement ||
--bug 2955326
/*
                       ' NON_LABOR_SCH_TYPE =  '||''''||
             RTRIM(p_nl_sch_type)||''''||',';
*/
                       ' NON_LABOR_SCH_TYPE = :n_lbr_sch_tp,';
             l_b_n_lbr_sch_tp_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

IF l_out_labor_sch_type = 'B' THEN


/* Should be able to update null since this is not mandatory*/
IF ((p_emp_bill_rate_schedule_id  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_emp_bill_rate_schedule_id IS NOT NULL ) OR (p_emp_bill_rate_schedule_id IS NULL))
   THEN
       IF ((p_emp_bill_rate_schedule_id <> NVL(l_task_rec.EMP_BILL_RATE_SCHEDULE_ID,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
         OR (p_emp_bill_rate_schedule_id IS NULL))
              THEN
--bug 2955326
/*
         l_statement  := l_statement ||
                       ' EMP_BILL_RATE_SCHEDULE_ID =  '||''''||
             TO_CHAR(p_emp_bill_rate_schedule_id)||''''||',';
*/
             l_statement := l_statement || ' EMP_BILL_RATE_SCHEDULE_ID = :emp_bill_rt_sch_id2 ,';
             l_b_emp_bill_rt_sch_id_fg2 := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

 /*
       1)Should be able to update null when prm is not licensed.
       2) When prm is licensed then it is mandatory.
       */

IF ((p_job_bill_rate_schedule_id  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
  AND p_job_bill_rate_schedule_id IS NOT NULL )
   OR (p_job_bill_rate_schedule_id is NULL and pa_install.is_prm_licensed = 'N'))
       THEN
          IF ((p_job_bill_rate_schedule_id <> NVL(l_task_rec.JOB_BILL_RATE_SCHEDULE_ID,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)) OR (p_job_bill_rate_schedule_id is NULL))
              THEN
--bug 2955326
/*
         l_statement  := l_statement ||
                       ' JOB_BILL_RATE_SCHEDULE_ID =  '||''''||
             TO_CHAR(p_job_bill_rate_schedule_id)||''''||',';
*/
             l_statement := l_statement || ' JOB_BILL_RATE_SCHEDULE_ID = :jb_bill_rt_sch_id2 ,';
             l_b_jb_bill_rt_sch_id_fg2 := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

/* Should be able to update null*/

          IF ((p_labor_schedule_fixed_date  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_labor_schedule_fixed_date IS NOT NULL)  OR p_labor_schedule_fixed_date IS NULL) THEN
          IF p_labor_schedule_fixed_date
           <> NVL(l_task_rec.LABOR_SCHEDULE_FIXED_DATE,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) OR (p_labor_schedule_fixed_date IS NULL)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_FIXED_DATE =  to_date('''||
                          to_char(p_labor_schedule_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_FIXED_DATE = :lbr_sch_fx_dt,';
             l_b_lbr_sch_fx_dt := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

      /* Should be able to update null*/
        IF ((p_labor_schedule_discount  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_labor_schedule_discount IS NOT NULL  ) OR (p_labor_schedule_discount IS NULL ))
      THEN
     IF ((p_labor_schedule_discount <> NVL(l_task_rec.LABOR_SCHEDULE_DISCOUNT,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM))
       OR (p_labor_schedule_discount IS NULL))
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_DISCOUNT =  '||''''||
             TO_CHAR(p_labor_schedule_discount)||''''||',';
*/
             l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_DISCOUNT = :lbr_sch_dsnt,';
             l_b_lbr_sch_dsnt := 'Y';
--end bug 2955326
      END IF;
       END IF;

 IF  p_labor_schedule_discount IS NULL THEN
   l_statement  := l_statement ||
                       ' LABOR_DISC_REASON_CODE =  '''''||',';
   l_update_yes_flag := 'Y';
ELSE
 IF p_labor_disc_reason_code  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_labor_disc_reason_code IS NOT NULL
       OR p_labor_disc_reason_code IS NULL THEN
          IF (p_labor_disc_reason_code
           <> NVL(l_task_rec.labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) OR (p_labor_disc_reason_code IS NULL))
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' LABOR_DISC_REASON_CODE =  '||''''||
             RTRIM(p_labor_disc_reason_code)||''''||',';
*/
             l_statement  := l_statement ||
                       ' LABOR_DISC_REASON_CODE = :lbr_disc_rsn_cd,';
             l_b_lbr_disc_rsn_cd_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
  END IF;

   ELSE  /*Else when labor_sch_type <> B*/
      l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_FIXED_DATE =  '''''||',';

      l_statement  := l_statement ||
                       ' LABOR_SCHEDULE_DISCOUNT =  '''''||',';

      l_statement  := l_statement ||
                       ' LABOR_DISC_REASON_CODE =  '''''||',';

      l_statement  := l_statement ||
                       ' EMP_BILL_RATE_SCHEDULE_ID =  '''''||',';

      l_statement  := l_statement ||
                       ' JOB_BILL_RATE_SCHEDULE_ID =  '''''||',';


     l_update_yes_flag := 'Y';
END IF;

  IF l_out_labor_sch_type = 'I' OR l_out_nl_labor_sch_type ='I' THEN

      IF p_rev_ind_rate_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_rev_ind_rate_sch_id IS NOT NULL  THEN
          IF NVL(p_rev_ind_rate_sch_id,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           <> NVL(l_task_rec.REV_IND_RATE_SCH_ID,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
              THEN

--bug 2955326
/*
             l_statement  := l_statement ||
                       ' REV_IND_RATE_SCH_ID =  '||''''||
             TO_CHAR(p_rev_ind_rate_sch_id)||''''||',';
*/
             l_statement  := l_statement ||
                       ' REV_IND_RATE_SCH_ID = :rv_ind_rt_sch_id,';
             l_b_rv_ind_rt_sch_id_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;


        IF p_inv_ind_rate_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_inv_ind_rate_sch_id IS NOT NULL  THEN
          IF NVL(p_inv_ind_rate_sch_id,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           <> NVL(l_task_rec.INV_IND_RATE_SCH_ID,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' INV_IND_RATE_SCH_ID =  '||''''||
             TO_CHAR(p_inv_ind_rate_sch_id)||''''||',';
*/
             l_statement  := l_statement ||
                       ' INV_IND_RATE_SCH_ID = :inv_ind_rt_sch_id,';
             l_b_inv_ind_rt_sch_id_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;



IF p_rev_ind_rate_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_rev_ind_rate_sch_id IS NOT NULL  THEN
if p_rev_ind_rate_sch_id  <> g_rev_ind_rate_sch_id then -- added for bug 3795253
BEGIN

SELECT       ind_rate_schedule_type INTO l_rev_rate_sch_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = p_rev_ind_rate_sch_id
AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate));
g_rev_rate_sch_type := l_rev_rate_sch_type;       -- added for bug 3795253
g_rev_ind_rate_sch_id := p_rev_ind_rate_sch_id;   -- added for bug 3795253
EXCEPTION
    WHEN NO_DATA_FOUND THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_REV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  END;

   -- start of bug 3795253
  else
     l_rev_rate_sch_type := g_rev_rate_sch_type;
  end if;
  -- end of bug  3795253

ELSE

IF l_task_rec.REV_IND_RATE_SCH_ID IS NOT NULL
and l_task_rec.REV_IND_RATE_SCH_ID <> g_rev_ind_rate_sch_id  -- Added for bug 3795253
THEN

SELECT       ind_rate_schedule_type INTO l_rev_rate_sch_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = l_task_rec.REV_IND_RATE_SCH_ID;

g_rev_rate_sch_type := l_rev_rate_sch_type;                -- added for bug 3795253
g_rev_ind_rate_sch_id := l_task_rec.REV_IND_RATE_SCH_ID;   -- added for bug 3795253

-- Bug 3657709
/* AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate)); */

-- start of bug 3795253
else
   l_rev_rate_sch_type := g_rev_rate_sch_type;
  end if;
  -- end of bug  3795253

END IF;


 IF p_inv_ind_rate_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_inv_ind_rate_sch_id IS NOT NULL  THEN
if p_inv_ind_rate_sch_id  <> g_inv_ind_rate_sch_id then   -- added for bug 3795253

BEGIN

SELECT       ind_rate_schedule_type INTO l_inv_rate_sch_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = p_inv_ind_rate_sch_id
AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate));

 g_inv_rate_sch_type := l_inv_rate_sch_type;       -- added for bug 3795253
 g_inv_ind_rate_sch_id := p_inv_ind_rate_sch_id;   -- added for bug 3795253

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_INV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  END;
  -- start of bug 3795253
  else
     l_inv_rate_sch_type := g_inv_rate_sch_type;
  end if;
  -- end of bug  3795253

  ELSE
  IF l_task_rec.INV_IND_RATE_SCH_ID IS NOT NULL
   and l_task_rec.INV_IND_RATE_SCH_ID <> g_inv_ind_rate_sch_id  -- Added for bug 3795253
    THEN


SELECT       ind_rate_schedule_type INTO l_inv_rate_sch_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = l_task_rec.INV_IND_RATE_SCH_ID;
g_inv_rate_sch_type := l_inv_rate_sch_type;                -- added for bug 3795253
g_inv_ind_rate_sch_id := l_task_rec.INV_IND_RATE_SCH_ID;   -- added for bug 3795253
-- Bug 3657709
/* AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate)); */
-- start of bug 3795253
else
   l_inv_rate_sch_type := g_inv_rate_sch_type;
  end if;
  -- end of bug  3795253
END IF;

/*
 If the burden rate schedule type is of Provisional type then the revenue schedule date has to be nullified.
 */

IF l_rev_rate_sch_type = 'P' AND l_task_rec.REV_IND_SCH_FIXED_DATE IS NOT NULL THEN
     l_statement  := l_statement ||
                       ' REV_IND_SCH_FIXED_DATE =  '''''||',';
    l_update_yes_flag := 'Y';
ELSE

  IF ((p_rev_ind_sch_fixed_date  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
  AND p_rev_ind_sch_fixed_date IS NOT NULL) OR (p_rev_ind_sch_fixed_date IS NULL))
   THEN
        IF (p_rev_ind_sch_fixed_date <> NVL(l_task_rec.rev_ind_sch_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) OR (p_rev_ind_sch_fixed_date IS NULL))
              THEN
             l_statement  := l_statement ||
--bug 2955326
/*
                       ' rev_ind_sch_fixed_date =  to_date('''||
                          to_char(p_rev_ind_sch_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
                       ' rev_ind_sch_fixed_date = :rv_ind_sch_fx_dt,';
             l_b_rv_ind_sch_fx_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
 END IF;

IF l_inv_rate_sch_type = 'P' and l_task_rec.INV_IND_SCH_FIXED_DATE IS NOT NULL
  THEN
    l_statement  := l_statement ||
                       ' INV_IND_SCH_FIXED_DATE =  '''''||',';
    l_update_yes_flag := 'Y';
ELSE
    IF ((p_inv_ind_sch_fixed_date  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
   AND p_inv_ind_sch_fixed_date IS NOT NULL) OR (p_inv_ind_sch_fixed_date IS NULL))
     THEN
          IF (p_inv_ind_sch_fixed_date <> NVL(l_task_rec.inv_ind_sch_fixed_date,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) OR (p_inv_ind_sch_fixed_date IS NULL))
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' inv_ind_sch_fixed_date =  to_date('''||
                          to_char(p_inv_ind_sch_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' inv_ind_sch_fixed_date =  :iv_ind_sch_fx_dt,';
             l_b_iv_ind_sch_fx_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
 END IF;

  ELSE  /*Else when laboR schedule type and non labor schedule type are both <> 'I'*/

      l_statement  := l_statement ||
                       ' REV_IND_RATE_SCH_ID =  '''''||',';


     l_statement  := l_statement ||
                       ' INV_IND_RATE_SCH_ID =  '''''||',';


     l_statement  := l_statement ||
                       ' REV_IND_SCH_FIXED_DATE =  '''''||',';

     l_statement  := l_statement ||
                       ' INV_IND_SCH_FIXED_DATE =  '''''||',';
     l_update_yes_flag := 'Y';
END IF;

     IF l_out_nl_labor_sch_type ='B' THEN

        IF p_nl_bill_rate_org_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_nl_bill_rate_org_id IS NOT NULL  THEN
          IF p_nl_bill_rate_org_id <> NVL(l_task_rec.NON_LABOR_BILL_RATE_ORG_ID,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
              THEN
--bug 2955326
/*
             l_statement := l_statement || ' NON_LABOR_BILL_RATE_ORG_ID = ' ||
                  TO_CHAR(p_nl_bill_rate_org_id)||',';
*/
             l_statement := l_statement || ' NON_LABOR_BILL_RATE_ORG_ID = :nl_bl_rt_org_id ,';
             l_b_nl_bl_rt_org_id_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

    IF p_non_lab_std_bill_rt_sch_id  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_non_lab_std_bill_rt_sch_id IS NOT NULL  THEN
          IF NVL(p_non_lab_std_bill_rt_sch_id,
      PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
      <> NVL(l_task_rec.non_lab_std_bill_rt_sch_id,
          PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
              THEN

/*No data found is already handled in Validate_Schedule_Values*/

BEGIN
         SELECT std_bill_rate_schedule INTO l_std_bill_rate_schedule
     FROM pa_std_bill_rate_schedules_all
     WHERE bill_rate_sch_id=p_non_lab_std_bill_rt_sch_id;

--bug 2955326
/*
      l_statement := l_statement || ' NON_LAB_STD_BILL_RT_SCH_ID = ' ||''''||
                  TO_CHAR(p_non_lab_std_bill_rt_sch_id)||''''||',';
      l_statement := l_statement || ' NON_LABOR_STD_BILL_RATE_SCHDL = ' ||''''||
                  RTRIM(l_std_bill_rate_schedule)||''''||',';
*/
--end bug 2955326
      l_statement := l_statement || ' NON_LAB_STD_BILL_RT_SCH_ID = :nl_std_bl_rt_sch_id,';
      l_statement := l_statement || ' NON_LABOR_STD_BILL_RATE_SCHDL = :nl_std_bl_rt_sch,';
             l_b_nl_std_bl_rt_sch_fg := 'Y';
             l_update_yes_flag := 'Y';
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PRJ_NL_SCHEDULE_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  END;
 END IF;
END IF;

 /* Should be able to update null*/
        IF ((p_nl_schedule_fixed_date  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          AND p_nl_schedule_fixed_date IS NOT NULL)  OR (p_nl_schedule_fixed_date IS NULL)) THEN
          IF (p_nl_schedule_fixed_date
           <> NVL(l_task_rec.NON_LABOR_SCHEDULE_FIXED_DATE,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) OR (p_nl_schedule_fixed_date IS NULL))
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' NON_LABOR_SCHEDULE_FIXED_DATE =  to_date('''||
                          to_char(p_nl_schedule_fixed_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement  := l_statement ||
                       ' NON_LABOR_SCHEDULE_FIXED_DATE = :nl_sch_fx_dt,';
             l_b_nl_sch_fx_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;

 /* Should be able to update null*/
  IF ((p_nl_schedule_discount  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
          AND p_nl_schedule_discount IS NOT NULL)  OR (p_nl_schedule_discount IS NULL)) THEN
         -- Bug 9073661
          IF (p_nl_schedule_discount <> NVL(l_task_rec.non_labor_schedule_discount,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        OR p_nl_schedule_discount IS NULL)
              THEN
--bug 2955326
/*
           l_statement  := l_statement ||
                       '  NON_LABOR_SCHEDULE_DISCOUNT    =  '||''''||
             TO_CHAR(p_nl_schedule_discount)||''''||',';
*/
             l_statement  := l_statement ||
                       '  NON_LABOR_SCHEDULE_DISCOUNT = :nl_sch_dsnt,';
             l_b_nl_sch_dsnt_fg := 'Y';
             l_update_yes_flag := 'Y';
--end bug 2955326
          END IF;
       END IF;

IF p_nl_schedule_discount IS NULL
THEN
    l_statement := l_statement || ' NON_LABOR_DISC_REASON_CODE = ''''' ||',';
    l_update_yes_flag := 'Y';
ELSE
       IF p_non_labor_disc_reason_code  <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
          AND p_non_labor_disc_reason_code IS NOT NULL  THEN
          IF NVL(p_non_labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
           <> NVL(l_task_rec.non_labor_disc_reason_code,
PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
              THEN
--bug 2955326
/*
             l_statement  := l_statement ||
                       ' NON_LABOR_DISC_REASON_CODE =  '||''''||
             RTRIM(p_non_labor_disc_reason_code)||''''||',';
*/
             l_statement  := l_statement ||
                       ' NON_LABOR_DISC_REASON_CODE = :nl_disc_rsn_cd ,';
             l_b_nl_disc_rsn_cd_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
          END IF;
       END IF;
 END IF;

   ELSE   /*Else when the non labor schedule type <> 'B'*/

      l_statement := l_statement || ' NON_LAB_STD_BILL_RT_SCH_ID = '''''||',';

      l_statement := l_statement || ' NON_LABOR_SCHEDULE_FIXED_DATE = ''''' ||',';

      l_statement := l_statement || ' NON_LABOR_SCHEDULE_DISCOUNT = '''''||',';

      l_statement := l_statement || ' NON_LABOR_DISC_REASON_CODE = ''''' ||',';

      l_statement := l_statement || ' NON_LABOR_STD_BILL_RATE_SCHDL = ''''' ||',';

      l_statement := l_statement || ' NON_LABOR_BILL_RATE_ORG_ID = ''''' ||',';
     l_update_yes_flag := 'Y';
END IF;

/*Code for bug 2802984 ends*/

 -- Update other date fields which are maintained only  in the external system

-- update Actual start date and actual finish date

       IF (p_actual_start_date IS NOT NULL AND
           p_actual_start_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.actual_start_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_actual_start_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' ACTUAL_START_DATE = to_date('''||
                          to_char(p_actual_start_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' ACTUAL_START_DATE = :act_st_dt ,';
             l_b_act_st_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;


       IF (p_actual_finish_date IS NOT NULL AND
           p_actual_finish_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.actual_finish_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_actual_finish_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' ACTUAL_FINISH_DATE = to_date('''||
                          to_char(p_actual_finish_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' ACTUAL_FINISH_DATE = :act_fn_dt ,';
             l_b_act_fn_dt_fg := 'Y';
          l_update_yes_flag := 'Y';
       END IF;

-- update early start date and early finish date
       IF (p_early_start_date IS NOT NULL AND
           p_early_start_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.early_start_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_early_start_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' EARLY_START_DATE = to_date('''||
                          to_char(p_early_start_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' EARLY_START_DATE = :erly_st_dt ,';
             l_b_erly_st_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;

       IF (p_early_finish_date IS NOT NULL AND
           p_early_finish_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.early_finish_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_early_finish_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' EARLY_FINISH_DATE = to_date('''||
                          to_char(p_early_finish_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' EARLY_FINISH_DATE = :erly_fn_dt ,';
             l_b_erly_fn_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;

-- update Late start date and Late finish date

       IF (p_late_start_date IS NOT NULL AND
           p_late_start_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.late_start_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_late_start_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' LATE_START_DATE = to_date('''||
                          to_char(p_late_start_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' LATE_START_DATE = :lt_st_dt ,';
             l_b_lt_st_dt_fg := 'Y';
--end bug 2955326

             l_update_yes_flag := 'Y';
       END IF;


       IF (p_late_finish_date IS NOT NULL AND
           p_late_finish_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.late_finish_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_late_finish_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' LATE_FINISH_DATE = to_date('''||
                          to_char(p_late_finish_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' LATE_FINISH_DATE = :lt_fn_dt ,';
             l_b_lt_fn_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;


-- update scheduled start date and scheduled finish date

       IF (p_scheduled_start_date IS NOT NULL AND
           p_scheduled_start_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.scheduled_start_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_scheduled_start_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' SCHEDULED_START_DATE = to_date('''||
                          to_char(p_scheduled_start_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' SCHEDULED_START_DATE = :sch_st_dt ,';
             l_b_sch_st_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;


       IF (p_scheduled_finish_date IS NOT NULL AND
           p_scheduled_finish_date <>
           PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) AND
           NVL(l_task_rec.scheduled_finish_date,
               PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
               p_scheduled_finish_date THEN
--bug 2955326
/*
             l_statement :=   l_statement ||
                     ' SCHEDULED_FINISH_DATE = to_date('''||
                          to_char(p_scheduled_finish_date,'YYYY/MM/DD')||
                             ''', ''YYYY/MM/DD''),';
*/
             l_statement :=   l_statement ||
                     ' SCHEDULED_FINISH_DATE = :sch_fn_dt ,';
             l_b_sch_fn_dt_fg := 'Y';
--end bug 2955326
             l_update_yes_flag := 'Y';
       END IF;

       IF p_task_manager_person_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       AND nvl(p_task_manager_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           <> nvl(l_task_rec.task_manager_person_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       AND p_task_manager_person_id IS NOT NULL --redundant, but added for clarity
       THEN
/* code commented and added for the Bug#1688735, starts here */
/*           l_statement :=  l_statement ||
                  ' TASK_MANAGER_PERSON_ID = '||TO_CHAR(l_new_parent_task_id)||','; */
--bug 2955326
/*
           l_statement :=  l_statement ||
                  ' TASK_MANAGER_PERSON_ID = '||TO_CHAR(p_task_manager_person_id)||',';
*/
           l_statement :=  l_statement ||
                  ' TASK_MANAGER_PERSON_ID = :tk_mgr_id ,';
           l_b_tk_mgr_id_fg := 'Y';
--end bug 2955326;
/* code commented and added for the Bug#1688735, ends here */
            l_update_yes_flag := 'Y';

       END IF;


-- Fix for Bug #1272548
-- BURDEN SCHEDULE AND FIXED DATE

       IF  (p_cost_ind_rate_sch_id  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       AND (nvl(p_cost_ind_rate_sch_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       AND p_cost_ind_rate_sch_id IS NOT NULL  --redundant, but added for clarity
       THEN
           OPEN l_cost_ind_rate_sch_id_csr( p_cost_ind_rate_sch_id);
           FETCH l_cost_ind_rate_sch_id_csr INTO l_temp_var;
           IF l_cost_ind_rate_sch_id_csr%NOTFOUND
           THEN
                CLOSE l_cost_ind_rate_sch_id_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_PRJ_INV_BURDEN_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
           CLOSE l_cost_ind_rate_sch_id_csr;

-- Add the Schedule ID to the update statement.

--bug 2955326
/*
           l_statement :=       l_statement ||
                                ' COST_IND_RATE_SCH_ID = '||''''||TO_CHAR(p_cost_ind_rate_sch_id)||''''||',';
*/
           l_statement :=       l_statement ||
                                ' COST_IND_RATE_SCH_ID = :cst_ind_rt_sch_id ,';
           l_b_cst_ind_rt_sch_id_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

-- Start fix for Bug #1335417

    IF  (p_cost_ind_sch_fixed_date  <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        AND (nvl(p_cost_ind_sch_fixed_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
            <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
        AND p_cost_ind_sch_fixed_date IS NOT NULL  --redundant, but added for clarity
        THEN
           OPEN l_ind_rate_schedule_type_csr( p_cost_ind_rate_sch_id);
           FETCH l_ind_rate_schedule_type_csr INTO l_temp_var_sch_type;
           IF l_temp_var_sch_type = 'P'
           THEN
                CLOSE l_ind_rate_schedule_type_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CANT_FIX_DATE_PROV_SCH'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'N'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
           CLOSE l_ind_rate_schedule_type_csr;

-- End fix for bug # 1335417

-- Add the Fixed Date to the update statement.
--bug 2955326
/*
           l_statement :=       l_statement ||
                                ' COST_IND_SCH_FIXED_DATE = '||''''||TO_CHAR(p_cost_ind_sch_fixed_date)||''''||',';

*/
           l_statement :=       l_statement ||
                                ' COST_IND_SCH_FIXED_DATE = :cst_ind_sch_fx_dt ,';
           l_b_cst_ind_sch_fx_dt_fg := 'Y';
--end bug 2955326
           l_update_yes_flag := 'Y';

       END IF;

-- End Fix for Bug # 1272548


      IF l_update_yes_flag = 'Y'
      THEN
            -- 4156036 Moved the below code to set invoice_method, customer_id and get_etc_source_code columns
            -- before setting the where clause
            -- wrong update sql statment was getting generated

            IF (p_invoice_method IS NOT NULL AND p_invoice_method <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.invoice_method, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_invoice_method
            THEN
                     l_statement :=   l_statement || ' INVOICE_METHOD = :inv_md ,';
                     l_inv_md_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;
/* Commented for Bug 4689326.
            IF (p_customer_id IS NOT NULL AND p_customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                  NVL(l_task_rec.customer_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> p_customer_id
            THEN
                     l_statement :=   l_statement || ' CUSTOMER_ID = :cust_id ,';
                     l_cust_id_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;*/
-- Start of Bug Number 4689326
-- Cheking is done whether its a Parent task or child task .If it is Parent task changing all the child tasks customers also.
            IF (p_customer_id IS NOT NULL AND p_customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                  NVL(l_task_rec.customer_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> p_customer_id
            THEN
                    IF l_task_rec.parent_task_id IS NULL THEN
                       IF  l_children_exist ='Y' THEN
                         UPDATE PA_TASKS SET customer_id = p_customer_id
                         WHERE top_task_id=l_task_rec.task_id AND not(task_id =l_task_rec.task_id);
                       END IF;
                     l_statement :=   l_statement || ' CUSTOMER_ID = :cust_id ,';
                     l_cust_id_fg := 'Y';
                     l_update_yes_flag := 'Y';
                    END IF;
            END IF;

            IF (P_gen_etc_source_code IS NOT NULL AND p_gen_etc_source_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.gen_etc_source_code, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_gen_etc_source_code
            THEN
                     l_statement :=   l_statement || ' GEN_ETC_SOURCE_CODE = :gen_etc_src_co ,';
                     l_gen_etc_src_co_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

            -- 4156036 end

/* code commented and added for the bug#1723839, starts here  */

/*                      l_statement :=  l_statement ||
                                ' LAST_UPDATE_DATE = '||''''||
                                SYSDATE||''''||',';
*/
                l_statement :=  l_statement ||
                                ' LAST_UPDATE_DATE = SYSDATE'||',';

/* code commented and added for the bug#1723839, ends here  */


                l_statement :=  l_statement ||
                            ' LAST_UPDATED_BY = :g_usr_id,'; --bug 2955326
--                              ' LAST_UPDATED_BY = '||G_USER_ID||','; --bug 2955326

                l_statement :=  l_statement ||
                            ' LAST_UPDATE_LOGIN = :g_login_id ';
--                              ' LAST_UPDATE_LOGIN = '||G_LOGIN_ID; --bug 2955326


            l_statement :=  l_statement ||
                        ' WHERE PROJECT_ID  = :prj_id ' ||
                        ' AND TASK_ID = :tk_id ';
--                      ' WHERE PROJECT_ID  = '||TO_CHAR(l_project_id) || --bug 2955326
--                      ' AND TASK_ID = '||TO_CHAR(l_task_id);            --bug 2955326

           -- 4156036 commented below code and added it above ( before setting the where clause of the update statement
/*
--Added by rtarway for BUG 4106154, copied from venkat's FP_M chnages. These should be before sql statement is parsed.
           IF (p_invoice_method IS NOT NULL AND p_invoice_method <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.invoice_method, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_invoice_method
            THEN
                     l_statement :=   l_statement || ' INVOICE_METHOD = :inv_md ,';
                     l_inv_md_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

            IF (p_customer_id IS NOT NULL AND p_customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                  NVL(l_task_rec.customer_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> p_customer_id
            THEN
                     l_statement :=   l_statement || ' CUSTOMER_ID = :cust_id ,';
                     l_cust_id_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

            IF (P_gen_etc_source_code IS NOT NULL AND p_gen_etc_source_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.gen_etc_source_code, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_gen_etc_source_code
            THEN
                     l_statement :=   l_statement || ' GEN_ETC_SOURCE_CODE = :gen_etc_src_co ,';
                     l_gen_etc_src_co_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;
--end add by rtarway for BUG 4106154
*/
           -- 4156036 end

/* dbms_output.put_line('Opening the cursor'); */
/* dbms_output.put_line(to_char(length(l_statement))); */
/* dbms_output.put_line('Statement: '||substr(l_statement,1,100)); */
/* dbms_output.put_line('Statement: '||substr(l_statement,101,100)); */
/* dbms_output.put_line('Statement: '||substr(l_statement,201,100)); */

            l_cursor := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor, l_statement, dbms_sql.native);

/* -- Commented by rtarway for BUG 4106154, this should be before opening the curosr, otherwise ora error 'variables not bound' is thrown
   -- if we try to bind any of following params
----(Begin Venkat) FP_M changes ------------------------------------------------------------

            IF (p_invoice_method IS NOT NULL AND p_invoice_method <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.invoice_method, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_invoice_method
            THEN
                     l_statement :=   l_statement || ' INVOICE_METHOD = :inv_md ,';
                     l_inv_md_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

            IF (p_customer_id IS NOT NULL AND p_customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
                  NVL(l_task_rec.customer_id, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) <> p_customer_id
            THEN
                     l_statement :=   l_statement || ' CUSTOMER_ID = :cust_id ,';
                     l_cust_id_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

            IF (P_gen_etc_source_code IS NOT NULL AND p_gen_etc_source_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
                  NVL(l_task_rec.gen_etc_source_code, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) <> p_gen_etc_source_code
            THEN
                     l_statement :=   l_statement || ' GEN_ETC_SOURCE_CODE = :gen_etc_src_co ,';
                     l_gen_etc_src_co_fg := 'Y';
                     l_update_yes_flag := 'Y';
            END IF;

----(End Venkat) FP_M changes ------------------------------------------------------------
*/
--bug 2955326
                IF l_b_pm_tk_ref_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':pm_tk_ref', RTRIM(p_pm_task_reference));
                END IF;

                IF l_b_tk_nm_flag = 'Y' THEN
                   DBMS_SQL.BIND_VARIABLE(l_cursor, ':tk_name', substrb(RTRIM(p_task_name),1,20)); -- bug 6193314
                END IF;

                IF l_b_ln_tk_nm_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':ln_tk_name', RTRIM(p_long_task_name));
                END IF;

                IF l_b_tk_desc_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':descrp', substrb(RTRIM(p_task_description),1,250)); --Bug 8821275
                END IF;

                IF l_b_rdy_to_bill_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':rdy_to_bill_fg', p_ready_to_bill_flag);
                END IF;

                IF l_b_rdy_to_dist_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':rdy_to_dist_fg', p_ready_to_distribute_flag);
                END IF;

                IF l_b_lmt_to_txn_ctrl_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lmt_to_txn_ctrl_fg', p_limit_to_txn_controls_flag);
                END IF;

                IF l_b_cryng_out_org_id_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cryng_out_org_id', p_carrying_out_organization_id);
                END IF;

                IF l_b_chgble_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':chgble_fg', p_chargeable_flag);
                END IF;

                IF l_b_billable_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':bil_fg', p_billable_flag);
                END IF;

                IF l_b_srv_tp_cd_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':srv_tp_cd', p_service_type_code);
                END IF;

                IF l_b_tk_num_fg = 'Y' THEN
         --dbms_output.put_line('adding the bind variable'||'-'||p_task_number);
         /* bug #5243018: Reverting the fix in bug 4120380.
       DBMS_SQL.BIND_VARIABLE(l_cursor, ':tk_num','-'||p_task_number); */
                       DBMS_SQL.BIND_VARIABLE(l_cursor, ':tk_num', substrb(p_task_number,1,25)); --bug 5733285
          /** CODE CHANGE BY ADITI for Bug 4120380.This is to prefix task_number with '-' so that
          PA_TASKS_U2 constraint can be overcome.After updating all the tasks in the script,
          code again updates the task_number, trimming the '-' added.**/
                END IF;

                IF l_b_tk_st_dt_flag = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':st_dt', p_task_start_date);
                END IF;

                IF l_b_comp_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cmp_dt', p_task_completion_date);
                END IF;

                IF l_b_prt_tk_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':prt_tk_id', l_new_parent_task_id);
                END IF;

                IF l_b_addr_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':addr_id', p_address_id);
                END IF;

                IF l_b_attr_cat_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr_cat', RTRIM(l_attribute_category));
                END IF;
                 --bug 6153503 start
                IF l_b_attr1_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr1', RTRIM(l_attribute1));
                END IF;

                IF l_b_attr2_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr2', RTRIM(l_attribute2));
                END IF;

                IF l_b_attr3_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr3', RTRIM(l_attribute3));
                END IF;

                IF l_b_attr4_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr4', RTRIM(l_attribute4));
                END IF;

                IF l_b_attr5_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr5', RTRIM(l_attribute5));
                END IF;

                IF l_b_attr6_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr6', RTRIM(l_attribute6));
                END IF;

                IF l_b_attr7_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr7', RTRIM(l_attribute7));
                END IF;

                IF l_b_attr8_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr8', RTRIM(l_attribute8));
                END IF;

                IF l_b_attr9_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr9', RTRIM(l_attribute9));
                END IF;

                IF l_b_attr10_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':attr10', RTRIM(l_attribute10));
                END IF;
                 --bug 6153503 end

                IF l_b_al_x_chg_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':all_x_chg_fg', RTRIM(p_allow_cross_charge_flag));
                END IF;

                IF l_b_prj_rt_tp_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':prj_rt_tp', RTRIM(p_project_rate_type));
                END IF;

                IF l_b_prj_rt_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':prj_rt_dt', p_project_rate_date);
                END IF;

                IF l_b_cc_proc_lbr_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cc_proc_lbr_fg', RTRIM(l_cc_process_labor_flag)); -- Changed to local variable for Bug 5395048
                END IF;

                IF l_b_lbr_tp_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_tp_sch_id', p_labor_tp_schedule_id);
                END IF;

                IF l_b_lbr_tp_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_tp_fx_dt', p_labor_tp_fixed_date);
                END IF;

                IF l_b_cc_proc_nl_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cc_proc_nl_fg', RTRIM(l_cc_process_nl_flag)); -- Changed to local variable for Bug 5395048
                END IF;

                IF l_b_nl_tp_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_tp_sch_id', p_nl_tp_schedule_id);
                END IF;

                IF l_b_nl_tp_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_tp_fx_dt', p_nl_tp_fixed_date);
                END IF;

                IF l_b_rcv_prj_inv_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':rcv_prj_inv_fg', RTRIM(p_receive_project_invoice_flag));
                END IF;

                IF l_b_wk_tp_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':wk_tp_id', p_work_type_id);
                END IF;

                IF l_b_emp_bill_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':emp_bill_rt_sch_id', p_emp_bill_rate_schedule_id);
                END IF;

                IF l_b_jb_bill_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':jb_bill_rt_sch_id', p_job_bill_rate_schedule_id);
                END IF;

                IF l_b_nn_lb_std_bl_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nn_lb_std_bl_rt_sch_id', p_non_lab_std_bill_rt_sch_id);
                END IF;

                IF l_b_tkfnc_cst_rt_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':tkfnc_cst_rt_dt', p_taskfunc_cost_rate_date);
                END IF;

                IF l_b_tkfnc_cst_rt_tp_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':tkfnc_cst_rt_tp', RTRIM(p_taskfunc_cost_rate_type));
                END IF;

                IF l_b_lbr_disc_rsn_cd_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_disc_rsn_cd', RTRIM(p_labor_disc_reason_code));
                END IF;

                IF l_b_nn_lbr_disc_rsn_cd_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nn_lbr_disc_rsn_cd', RTRIM(p_non_labor_disc_reason_code));
                END IF;

                IF l_b_act_st_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':act_st_dt', p_actual_start_date);
                END IF;

                IF l_b_act_fn_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':act_fn_dt', p_actual_finish_date);
                END IF;

                IF l_b_erly_st_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':erly_st_dt', p_early_start_date);
                END IF;

                IF l_b_erly_fn_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':erly_fn_dt', p_early_finish_date);
                END IF;

                IF l_b_lt_st_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lt_st_dt', p_late_start_date);
                END IF;

                IF l_b_lt_fn_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lt_fn_dt', p_late_finish_date);
                END IF;

                IF l_b_sch_st_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':sch_st_dt', p_scheduled_start_date);
                END IF;

                IF l_b_sch_fn_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':sch_fn_dt', p_scheduled_finish_date);
                END IF;

                IF l_b_cst_ind_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cst_ind_rt_sch_id', p_cost_ind_rate_sch_id);
                END IF;

                IF l_b_cst_ind_sch_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cst_ind_sch_fx_dt', p_cost_ind_sch_fixed_date);
                END IF;

                IF l_b_ret_cst_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':ret_cst_fg', RTRIM(p_retirement_cost_flag));
                END IF;

                IF l_b_cint_elg_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cint_elg_fg', RTRIM(p_cint_eligible_flag));
                END IF;

                IF l_b_cint_stp_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':cint_stp_dt', RTRIM(p_cint_stop_date));
                END IF;

                IF l_b_lbr_sch_tp_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_sch_tp', RTRIM(p_labor_sch_type));
                END IF;

                IF l_b_n_lbr_sch_tp_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':n_lbr_sch_tp', RTRIM(p_nl_sch_type));
                END IF;

                IF l_b_emp_bill_rt_sch_id_fg2 = 'Y' THEN  --IF l_b_jb_bill_rt_sch_id_fg2 = 'Y' THEN - Changed the IF Condition for the Bug:4692368
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':emp_bill_rt_sch_id2', p_emp_bill_rate_schedule_id);
                END IF;

                IF l_b_jb_bill_rt_sch_id_fg2 = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':jb_bill_rt_sch_id2', p_job_bill_rate_schedule_id);
                END IF;

                IF l_b_lbr_sch_fx_dt = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_sch_fx_dt', p_labor_schedule_fixed_date);
                END IF;

                IF l_b_lbr_sch_dsnt = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':lbr_sch_dsnt', p_labor_schedule_discount);
                END IF;

                IF l_b_rv_ind_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':rv_ind_rt_sch_id', p_rev_ind_rate_sch_id);
                END IF;

                IF l_b_inv_ind_rt_sch_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':inv_ind_rt_sch_id', p_inv_ind_rate_sch_id);
                END IF;

                IF l_b_rv_ind_sch_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':rv_ind_sch_fx_dt', p_rev_ind_sch_fixed_date);
                END IF;

                IF l_b_iv_ind_sch_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':iv_ind_sch_fx_dt', p_inv_ind_sch_fixed_date);
                END IF;

                IF l_b_nl_bl_rt_org_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_bl_rt_org_id', p_nl_bill_rate_org_id);
                END IF;

                IF l_b_nl_std_bl_rt_sch_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_std_bl_rt_sch_id', p_non_lab_std_bill_rt_sch_id);
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_std_bl_rt_sch', RTRIM(l_std_bill_rate_schedule));
                END IF;

                IF l_b_nl_sch_fx_dt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_sch_fx_dt', p_nl_schedule_fixed_date);
                END IF;

                IF l_b_nl_sch_dsnt_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_sch_dsnt', p_nl_schedule_discount);
                END IF;

                IF l_b_nl_disc_rsn_cd_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':nl_disc_rsn_cd', RTRIM(p_non_labor_disc_reason_code));
                END IF;

                IF l_b_tk_mgr_id_fg = 'Y' THEN
                  DBMS_SQL.BIND_VARIABLE(l_cursor, ':tk_mgr_id', p_task_manager_person_id); --Changed from l_new_parent_task_id to p_task_manager_person_id for Bug 3913251
                END IF;

----(Begin Venkat) FP_M changes ------------------------------------------------------------

        IF l_inv_md_fg = 'Y'
        THEN
            -- 4177105 changed usage from l_invoice_method to p_invoice_method
            -- because l_invoice_method is unitialized
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':inv_md', p_invoice_method);
        END IF;

        IF l_cust_id_fg = 'Y'
        THEN
        -- Bug 4193259: Changed l_customer_id to p_customer_id
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':cust_id', p_customer_id);
        END IF;

        IF l_gen_etc_src_co_fg = 'Y'
        THEN
            DBMS_SQL.BIND_VARIABLE(l_cursor, ':gen_etc_src_co', p_gen_etc_source_code); /* Changed from l_gen_etc_source_code to p_gen_etc_source_code for bug 6025667 */
        END IF;

----(End Venkat) FP_M changes ------------------------------------------------------------

                DBMS_SQL.BIND_VARIABLE(l_cursor, ':g_usr_id', G_USER_ID);
                DBMS_SQL.BIND_VARIABLE(l_cursor, ':g_login_id', G_LOGIN_ID);
                DBMS_SQL.BIND_VARIABLE(l_cursor, ':prj_id', l_project_id);
                DBMS_SQL.BIND_VARIABLE(l_cursor, ':tk_id', l_task_id);

--end bug 2955326

            l_rows   := dbms_sql.execute(l_cursor);
                IF dbms_sql.is_open (l_cursor)
            THEN
        dbms_sql.close_cursor (l_cursor);
            END IF;

      END IF;

/* 4490532
    --bug 4279634
    --if a lowest level task has sub-projects then make the chargeable flag to 'N'
    --This should be indepenedent of the above update.
    IF PA_RELATIONSHIP_UTILS.check_task_has_sub_proj(l_project_id,l_task_id,null) = 'Y'
    THEN
        UPDATE pa_tasks
           SET chargeable_flag = 'N'
         WHERE task_id =  l_task_id;
    END IF;
    --end bug 4279634
*/


      p_out_pa_task_id         := l_task_id;
      p_out_pm_task_reference  := l_pm_task_reference;

      CLOSE l_lock_rows_csr;  --FYI: doesn't remove locks

      IF l_tasks_restructured_flag = 'Y' THEN
         -- If a task has been moved to under another parent
         -- in the WBS structure, then need to indicate that
         -- Accumulation figures need to be refreshed for the project
         -- Hence modify the project level record in PA_PROJECT_ACCUM_HEADERS
         -- No need to check whether the project has been accumulated,since
         -- Update will not fail if the record is not found

         UPDATE pa_project_accum_headers
         SET  tasks_restructured_flag = 'Y' ,
              last_update_login       = l_user_id,
              last_update_date        = SYSDATE,
              last_updated_by         = l_user_id
         WHERE project_id = l_project_id
         AND   task_id    = 0
         AND   resource_list_member_id = 0;
     END IF;


      IF FND_API.to_boolean( p_commit )
      THEN
      COMMIT;
      END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR ;

    -- 4537865 RESET OUT PARAMS
    p_out_pa_task_id             := NULL ;
    p_out_pm_task_reference      := NULL ;

        ROLLBACK TO Update_Task_pub;

        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        -- 4537865 RESET OUT PARAMS
        p_out_pa_task_id             := NULL ;
        p_out_pm_task_reference      := NULL ;

    ROLLBACK TO Update_Task_pub;


        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN ROW_ALREADY_LOCKED THEN

    ROLLBACK TO update_task_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;
        -- 4537865 RESET OUT PARAMS
        p_out_pa_task_id             := NULL ;
        p_out_pm_task_reference      := NULL ;


    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
      FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_T_AMG');
      FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
      FND_MESSAGE.SET_TOKEN('TASK',    l_amg_task_number);
      FND_MESSAGE.SET_TOKEN('ENTITY', G_TASK_CODE);
      FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN OTHERS THEN

        ROLLBACK TO Update_Task_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- 4537865 RESET OUT PARAMS
        p_out_pa_task_id             := NULL ;
        p_out_pm_task_reference      := NULL ;


        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

END update_one_task;

PROCEDURE delete_task1
( p_api_version_number      IN  NUMBER
 ,p_commit          IN  VARCHAR2    := FND_API.G_FALSE
 ,p_init_msg_list       IN  VARCHAR2    := FND_API.G_FALSE
 ,p_msg_count           OUT NOCOPY NUMBER -- 4537865 Added nocopy hint
 ,p_msg_data            OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy hint
 ,p_return_status       OUT NOCOPY VARCHAR2 -- 4537865 Added nocopy hint
 ,p_pm_product_code     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id          IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_cascaded_delete_flag    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_id          OUT NOCOPY NUMBER -- 4537865 Added nocopy hint
 ,p_task_id         OUT NOCOPY NUMBER -- 4537865 Added nocopy hint
 ,p_task_version_id             IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_structure_type              IN      VARCHAR2        := 'FINANCIAL'
)
IS

   CURSOR lock_tasks_csr ( p_task_id IN NUMBER )
   IS
   SELECT   'x'
   FROM     pa_tasks
   START WITH   task_id=p_task_id
   CONNECT BY PRIOR task_id=parent_task_id
   FOR UPDATE NOWAIT;


   l_api_name           CONSTANT    VARCHAR2(30)        := 'delete_task';
   l_project_id                 NUMBER;
   l_task_id                    NUMBER;
   l_return_status              VARCHAR2(1);
   l_message                    VARCHAR2(2000);
   l_delete_task_ok_flag            VARCHAR2(1);
   l_cascaded_delete_flag           VARCHAR2(1);
   l_err_code                   NUMBER(15);
   l_err_stage                      VARCHAR2(120);
   l_err_stack                  VARCHAR2(630);
   l_dummy                  VARCHAR2(1);
   l_msg_count                  NUMBER ;
   l_msg_data                   VARCHAR2(2000);
   l_function_allowed               VARCHAR2(1);
   l_resp_id                    NUMBER := 0;

l_amg_segment1       VARCHAR2(25);
l_amg_task_number       VARCHAR2(50);

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   CURSOR   l_amg_task_csr
      (p_pa_task_id pa_tasks.task_id%type)
   IS
   SELECT   task_number
   FROM     pa_tasks p
   WHERE p.task_id = p_pa_task_id;

   -- 3801426 added local variable
   l_task_source_reference VARCHAR2(240);

   -- 5263429 added local variable
   l_task_id_out pa_tasks.task_id%TYPE;

BEGIN


--  Standard begin of API savepoint

    SAVEPOINT delete_task_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME         )
    THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

--  pm_product_code is mandatory

--bug 2841158
--    IF p_pm_product_code IS NULL
--    OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    IF p_pm_product_code IS NOT NULL
    AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--bug 2841158
    THEN

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
    END IF;
    RAISE FND_API.G_EXC_ERROR;
    END IF;

--bug 2841158
    IF p_pm_product_code <> 'WORKPLAN'
       AND p_pm_product_code IS NOT NULL
       AND p_pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
--bug 2841158
         /*added for bug no :2413400*/
        OPEN p_product_code_csr (p_pm_product_code);
        FETCH p_product_code_csr INTO l_pm_product_code;
        CLOSE p_product_code_csr;
        IF l_pm_product_code <> 'X'
        THEN

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           END IF;
        p_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF; --bug 2841158


    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DELETE_TASK',
       p_msg_count      => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
       p_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

    FND_MSG_PUB.initialize;

    END IF;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;


-- Assumption: the convert API's will do validity checks for project_id and task_id


        pa_project_pvt.convert_pm_projref_to_id
                (p_pm_project_reference => p_pm_project_reference
                ,p_pa_project_id    => p_pa_project_id
                ,p_out_project_id   => l_project_id
                ,p_return_status    => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

   IF p_structure_type = 'FINANCIAL'
   THEN
        -- 5262740 Changed PA_PROJECT_PVT.Convert_pm_taskref_to_id to PA_PROJECT_PVT.Convert_pm_taskref_to_id_all
        pa_project_pvt.convert_pm_taskref_to_id_all
                (p_pa_project_id    => l_project_id
                ,p_pa_task_id       => p_pa_task_id
                ,p_pm_task_reference    => p_pm_task_reference
                ,p_out_task_id      => l_task_id
                ,p_return_status    => l_return_status );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;
/*
   OPEN l_amg_task_csr( l_task_id );
   FETCH l_amg_task_csr INTO l_amg_task_number;
   CLOSE l_amg_task_csr;
*/
   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number=> ''
    ,p_task_reference => p_pm_task_reference
    ,p_task_id => l_task_id);

    pa_task_utils.check_delete_task_ok(x_task_id        => l_task_id,
--bug 3010538                                       x_validation_mode           => 'R',          --bug 2947492
                                       x_err_code       => l_err_code,
                                       x_err_stage      => l_err_stage,
                                       x_err_stack      => l_err_stack);
    IF l_err_code > 0
    then

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN

        IF NOT pa_project_pvt.check_valid_message(l_err_stage)
        THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_DELETE_TASK_FAILED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        ELSE
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => l_err_stage
            ,p_msg_attribute    => 'SPLIT'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'DELT'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;

    END IF;

    RAISE FND_API.G_EXC_ERROR;

    ELSIF l_err_code < 0
    then

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_DELETE_TASK_FAILED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    end IF;

--Call plannable task api here bug 2947492

    PA_PROJ_TASK_STRUC_PUB.delete_fin_plan_from_task(
                  p_task_id                       => l_task_id
                 ,p_project_id                    => l_project_id
                 ,P_calling_module                => 'AMG'
                 ,x_msg_count                     => l_msg_count
                 ,x_msg_data                      => l_msg_data
                 ,x_return_status                 => l_return_status);

     IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE  FND_API.G_EXC_ERROR;
     END IF;
--End bug 2947492

    --lock the task row and all it's children before it is going to be deleted / updated
    OPEN lock_tasks_csr( l_task_id );


    --when p_cascaded_delete_flag is not passed or NULL, default to 'N'
    --if not correct value is passed, error out.

    IF p_cascaded_delete_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    OR p_cascaded_delete_flag IS NULL
    THEN
        l_cascaded_delete_flag := 'N';

    ELSIF p_cascaded_delete_flag NOT IN ('Y','y','N','n')
    THEN

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_CASCADE_FLAG_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
    END IF;

    RAISE FND_API.G_EXC_ERROR;

    ELSE
        l_cascaded_delete_flag := p_cascaded_delete_flag;

    END IF;

    IF l_cascaded_delete_flag IN ('Y','y')
    THEN

        pa_project_core.delete_task( x_task_id  => l_task_id
--bug 3010538                                ,x_validation_mode => 'R'     --bug 2947492
                    ,x_err_code => l_err_code
                    ,x_err_stage    => l_err_stage
                    ,x_err_stack    => l_err_stack  );

        IF l_err_code > 0
        THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            IF NOT pa_project_pvt.check_valid_message(l_err_stage)
            THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_DELETE_TASK_FAILED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            ELSE
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => l_err_stage
            ,p_msg_attribute    => 'SPLIT'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'DELT'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            END IF;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

        ELSIF l_err_code < 0
        THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_DELETE_TASK_FAILED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'TASK'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => l_amg_task_number
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

    ELSE

        pa_project_pvt.Delete_One_Task
              (p_task_id             => l_task_id,
               p_return_status       => l_return_status,
               p_msg_count           => p_msg_count,
               p_msg_data            => p_msg_data );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
        RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    CLOSE lock_tasks_csr;

--bug 2765115

    --only deletes from pa_proj_elements. There is a check in pa_task_pvt1.delete_task_version api not to delete from pa_tasks if called from AMG.
        PA_PROJ_TASK_STRUC_PUB.delete_task_structure
               (
                p_calling_module                  => 'AMG'
               ,p_task_id                         => l_task_id
               ,p_task_version_id                 => p_task_version_id
               ,p_project_id                      => l_project_id
               ,x_msg_count                       => l_msg_count
               ,x_msg_data                        => l_msg_data
               ,x_return_status                   => l_return_status);

     IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

--bug 2765115

    p_project_id := l_project_id;
    p_task_id    := l_task_id;

 -- rbruno bug 9484327 - start
  ELSIF p_structure_type = 'WORKPLAN'  OR p_structure_type = 'SHARED' THEN
 -- rbruno bug 9484327 - end

    -- added for bug# 3801426
    -- validating task reference to id

    IF p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
       l_task_id := NULL;
    ELSE
       l_task_id := p_pa_task_id;
    END IF;


    IF p_pm_task_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       l_task_source_reference := NULL;
    ELSE
       l_task_source_reference := p_pm_task_reference;
    END IF;

    IF ( l_task_id IS NOT NULL OR l_task_source_reference IS NOT NULL ) THEN

/* Bug Fix 5263429

Issue:

 The task deletion from MSP was erroring out.

Analysis:

 The task deletion calls the PA_PROJECT_PUB.DELETE_TASK  API. This was returning an error with status 'E' and error
 message  PA_TASK_REF_AND_ID_MISSING. There is a call to Convert_pm_taskref_to_id_all API in the PA_PROJECT_PVT.DELETE_TASK1
 in the WORKPLAN portion of the code.
 Please note that the same local variable l_task_id is used for both IN and OUT parameters. Due to the NOCOPY hint the  variable
 l_task_id was becoming null when the control enters into the Convert_pm_taskref_to_id_all API. As the required  parameter was
 NULL the API was raising the above error resulting into an error and stopping the task deletion.

Solution:

 In order to avoid this issue a new local variable is created and used to capture the OUT parameters value in the call and
 then assign the value back to the old l_task_id variable.
*/

       PA_PROJECT_PVT.Convert_pm_taskref_to_id_all (
                   p_pa_project_id      => l_project_id
                 , p_structure_type     => 'WORKPLAN'
                 , p_pa_task_id         => l_task_id
                 , p_pm_task_reference  => l_task_source_reference
                 , p_out_task_id        => l_task_id_out
                 , p_return_status      => l_return_status );

       l_task_id:= l_task_id_out;
       -- End of Bug Fix 5263429

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR      THEN
             RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- end for bug# 3801426

     --Project Structures Integration

     PA_PROJ_TASK_STRUC_PUB.delete_task_structure
               (
                p_calling_module                  => 'AMG'
               ,p_task_id                         => l_task_id          -- changed bug# 3801426 earlierr p_task_id was used
               ,p_task_version_id                 => p_task_version_id
               ,p_project_id                      => l_project_id      --bug 2765115
               ,p_structure_type                  => p_structure_type   -- added for bug# 3801426 , earlier structure_type was not passed
               ,x_msg_count                       => l_msg_count
               ,x_msg_data                        => l_msg_data
               ,x_return_status                   => l_return_status);

     IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE  FND_API.G_EXC_ERROR;
     END IF;

    p_project_id := l_project_id;
    p_task_id    := p_task_id;

--Project Structures Integration
  END IF; --<< p_structrue_type >>

    IF FND_API.to_boolean( p_commit )
    THEN
    COMMIT;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
    ROLLBACK TO delete_task_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_project_id := NULL ;
    p_task_id := NULL ;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
    ROLLBACK TO delete_task_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_project_id := NULL ;
    p_task_id := NULL ;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN ROW_ALREADY_LOCKED
    THEN
    ROLLBACK TO delete_task_pub;

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_project_id := NULL ;
    p_task_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    THEN
      FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_T_AMG');
      FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
      FND_MESSAGE.SET_TOKEN('TASK',    l_amg_task_number);
      FND_MESSAGE.SET_TOKEN('ENTITY', G_TASK_CODE);
      FND_MSG_PUB.ADD;
    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

    WHEN OTHERS THEN
    ROLLBACK TO delete_task_pub;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_project_id := NULL ;
    p_task_id := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

    FND_MSG_PUB.Count_And_Get
            (   p_count     =>  p_msg_count ,
                p_data      =>  p_msg_data  );

END delete_task1;

--------------------------------------------------------------------------------
-- Name:    approve_project1
-- Type:    PL/SQL Procedure
-- Decscription:  This procedure will set the project status to approved.
--
-- Called Subprograms:
--
-- History: 27-FEB-97   L. de Werker   Created
--
--
PROCEDURE approve_project1
( p_api_version_number     IN NUMBER
 ,p_commit        IN VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count        OUT NOCOPY   NUMBER -- 4537865 Added nocopy hint
 ,p_msg_data         OUT NOCOPY  VARCHAR2 -- 4537865 Added nocopy hint
 ,p_return_status    OUT NOCOPY  VARCHAR2 -- 4537865 Added nocopy hint
 ,p_pm_product_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 )
IS

BEGIN

NULL;

END approve_project1;


--------------------------------------------------------------------------------
--Name:               delete_project1
--Type:               Procedure
--Description:        This procedure can be used to delete a project
--
--
--Called subprograms:
--
--
--
--History:
--    19-AUG-1996        R. Krishnamurthy    Created
--

PROCEDURE delete_project1
( p_api_version_number     IN NUMBER
 ,p_commit        IN VARCHAR2 := FND_API.G_FALSE
 ,p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
 ,p_msg_count        OUT NOCOPY  NUMBER -- 4537865 Added nocopy hint
 ,p_msg_data         OUT NOCOPY  VARCHAR2 -- 4537865 Added nocopy hint
 ,p_return_status    OUT NOCOPY  VARCHAR2 -- 4537865 Added nocopy hint
 ,p_pm_product_code     IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference   IN VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id    IN NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 )
IS

   CURSOR l_lock_rows_csr( p_project_id NUMBER)
   IS
   SELECT 'x'
   FROM    pa_projects
   WHERE  project_id = p_project_id
   FOR UPDATE NOWAIT;

--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

   l_amg_segment1       VARCHAR2(25);

   l_api_name        CONSTANT      VARCHAR2(30) := 'delete_project';
   l_project_id                          NUMBER;
   l_return_status            VARCHAR2(1);
   l_message               VARCHAR2(2000);
   l_err_code              NUMBER(15);
   l_err_stage                   VARCHAR2(120);
   l_err_stack             VARCHAR2(630);
   l_dummy              VARCHAR2(1);
   l_msg_count                  NUMBER ;
   l_msg_data                   VARCHAR2(2000);
   l_function_allowed                 VARCHAR2(1);
   l_resp_id                    NUMBER := 0;
   l_user_id                              NUMBER := 0;
   l_module_name                                VARCHAR2(80);

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT delete_project_pub;

--  Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( g_api_version_number  ,
                               p_api_version_number   ,
                               l_api_name          ,
                               G_PKG_NAME          )
    THEN

   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


    END IF;

    --   Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

   FND_MSG_PUB.initialize;

    END IF;

--  pm_product_code is mandatory

--bug 2841158
--    IF p_pm_product_code IS NULL
--    OR p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    IF p_pm_product_code IS NOT NULL
    AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--bug 2841158
    THEN

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
   THEN
      pa_interface_utils_pub.map_new_amg_msg
       ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
         ,p_msg_attribute    => 'CHANGE'
         ,p_resize_flag      => 'N'
         ,p_msg_context      => 'GENERAL'
         ,p_attribute1       => ''
         ,p_attribute2       => ''
         ,p_attribute3       => ''
         ,p_attribute4       => ''
         ,p_attribute5       => '');
   END IF;
   RAISE FND_API.G_EXC_ERROR;
    END IF;

--bug 2841158
    IF p_pm_product_code <> 'WORKPLAN'
       AND p_pm_product_code IS NOT NULL
       AND p_pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    THEN
--bug 2841158
         /*added for bug no :2413400*/
        OPEN p_product_code_csr (p_pm_product_code);
        FETCH p_product_code_csr INTO l_pm_product_code;
        CLOSE p_product_code_csr;
        IF l_pm_product_code <> 'X'
        THEN

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
           pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_INVALID'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           END IF;
        p_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;
   END IF; --bug 2841158

--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;
    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;
    --l_module_name := p_pm_product_code||'.'||'PA_PM_DELETE_PROJECT';
    l_module_name := 'PA_PM_DELETE_PROJECT';


    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to delete the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_DELETE_PROJECT',
       p_msg_count       => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        p_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
        END IF;


--Assumption: convert API will do validity check for project_id


      pa_project_pvt.convert_pm_projref_to_id
            (p_pm_project_reference => p_pm_project_reference
            ,p_pa_project_id  => p_pa_project_id
            ,p_out_project_id => l_project_id
            ,p_return_status  => l_return_status );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Now verify whether project security allows the user to delete
      -- the project

      IF pa_security.allow_query (x_project_id => l_project_id ) = 'N' THEN

         -- The user does not have query privileges on this project
         -- Hence, cannot delete the project.Raise error

         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
      p_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
      ELSE
            -- If the user has query privileges, then check whether
            -- update privileges are also available
         IF pa_security.allow_update (x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error

         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
      p_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( l_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;

   --lock the project
   OPEN l_lock_rows_csr( l_project_id );
   CLOSE l_lock_rows_csr;


      pa_project_utils.check_delete_project_ok
                         (x_project_id        => l_project_id,
--bug 3010538                          x_validation_mode   => 'R',    --bug 2947492
                          x_err_code          => l_err_code,
                          x_err_stage         => l_err_stage,
                          x_err_stack         => l_err_stack);

       IF l_err_code <> 0 THEN

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

      IF NOT pa_project_pvt.check_valid_message(l_err_stage)
      THEN
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_DELETE_PROJECT_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELP'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      END IF;

       END IF;

            IF l_err_code > 0 THEN

           RAISE FND_API.G_EXC_ERROR;

            ELSIF l_err_code < 0 THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

       END IF;

       pa_project_core.delete_project (x_project_id => l_project_id,
--bug 3010538                                       x_validation_mode => 'R',     --bug 2947492
                                       x_err_code   => l_err_code,
                                       x_err_stage  => l_err_stage,
                                       x_err_stack  => l_err_stack );
      IF l_err_code > 0 THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      IF NOT pa_project_pvt.check_valid_message(l_err_stage) THEN

         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_DELETE_PROJECT_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
      ELSE
         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => l_err_stage
                        ,p_msg_attribute    => 'SPLIT'
                        ,p_resize_flag      => 'Y'
                        ,p_msg_context      => 'DELP'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');

      END IF;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
      ELSIF l_err_code < 0 THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN

         pa_interface_utils_pub.map_new_amg_msg
                       ( p_old_message_code => 'PA_DELETE_PROJECT_FAILED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'PROJ'
                        ,p_attribute1       => l_amg_segment1
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   IF FND_API.to_boolean( p_commit )
   THEN
      COMMIT;
   END IF;

EXCEPTION

        WHEN FND_API.G_EXC_ERROR
        THEN
        ROLLBACK TO delete_project_pub;

        p_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
        ROLLBACK TO delete_project_pub;

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

      WHEN ROW_ALREADY_LOCKED THEN

   ROLLBACK TO delete_project_pub;

   p_return_status := FND_API.G_RET_STS_ERROR;

   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
   THEN
      FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_P_AMG');
      FND_MESSAGE.SET_TOKEN('PROJECT', l_amg_segment1);
      FND_MESSAGE.SET_TOKEN('ENTITY', G_PROJECT_CODE);
      FND_MSG_PUB.ADD;
   END IF;
   FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

        WHEN OTHERS THEN

        ROLLBACK TO delete_project_pub;

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                FND_MSG_PUB.add_exc_msg
            ( p_pkg_name      => G_PKG_NAME
            , p_procedure_name   => l_api_name
            , p_error_text    => SUBSTRB(SQLERRM, 1, 240) ); -- 4537865 Changed substr to substrb

                FND_MSG_PUB.add;
        END IF;

        FND_MSG_PUB.Count_And_Get
         (   p_count    => p_msg_count ,
             p_data     => p_msg_data  );

END delete_project1;

--------------------------------------------------------------------------------


-- anlee org role changes
--====================================================================================
--Name:               add_org_roles
--Type:               Procedure
--Description:        This procedure can be used to add org roles
--            to a new or already existing project using
--            the overridable view.
--
--Called subprograms: none
--
--
--
--History:
--    20-MAR-2002        anlee    Created

PROCEDURE add_org_roles
( p_return_status           OUT NOCOPY VARCHAR2                , -- 4537865 Added nocopy hint
  p_pa_source_template_id       IN  NUMBER                  ,
  p_project_id              IN  NUMBER                  ,
  p_org_roles               IN  pa_project_pub.project_role_tbl_type    )
IS

   CURSOR l_project_role_types_csr (p_role_type IN VARCHAR2)
   IS
   SELECT 'x' FROM
   pa_project_role_types
   WHERE project_role_type = p_role_type;



   l_api_name            CONSTANT   VARCHAR2(30)        := 'add_org_roles';
   i                        BINARY_INTEGER :=0;
   j                        BINARY_INTEGER :=0;

   l_dummy                      VARCHAR2(1);
   l_amg_segment1       VARCHAR2(25);
   l_completion_date    DATE;
   v_start_date_active  DATE;
   v_end_date_active    DATE;
   v_project_role_id    NUMBER;
   v_project_role_type  VARCHAR2(20);
   v_person_id          NUMBER;
   v_null_number        NUMBER;
   v_null_char          VARCHAR2(1);
   x_return_status      VARCHAR2(255);
   x_msg_count          NUMBER;
   x_msg_data           VARCHAR2(255);
   x_project_party_id   NUMBER;
   x_resource_id        NUMBER;
   l_wf_item_type          VARCHAR2(30);
   l_wf_type               VARCHAR2(30);
   l_wf_party_process      VARCHAR2(30);
   l_assignment_id         NUMBER;
--needed to get the field values associated to a AMG message

   CURSOR   l_amg_project_csr
      (p_pa_project_id pa_projects.project_id%type)
   IS
   SELECT   segment1,COMPLETION_DATE
   FROM     pa_projects p
   WHERE p.project_id = p_pa_project_id;

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT add_org_roles_pvt;


--  Set API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Get segment1 for AMG messages

   OPEN l_amg_project_csr( p_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1,l_completion_date;
   CLOSE l_amg_project_csr;

    i := p_org_roles.first;

    WHILE i IS NOT NULL LOOP

   -- Check whether this is a valid organization

 IF (p_org_roles(i).person_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
      (p_org_roles(i).person_id IS NOT NULL) THEN
       IF check_valid_organization (p_org_roles(i).person_id) = 'N'
       THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_INVALID_ORGANIZATION'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
            END IF;
                RAISE  FND_API.G_EXC_ERROR;
       END IF;

  -- validate the role type
     OPEN l_project_role_types_csr (p_org_roles(i).project_role_type);
     FETCH l_project_role_types_csr INTO l_dummy;
     IF l_project_role_types_csr%NOTFOUND THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_INVALID_ROLE_TYPE'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
        END IF;
        CLOSE l_project_role_types_csr;
        RAISE  FND_API.G_EXC_ERROR;
     ELSE
        CLOSE l_project_role_types_csr;
     END IF;


       IF p_org_roles(i).start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       AND p_org_roles(i).end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
       THEN
          IF  p_org_roles(i).end_date < p_org_roles(i).start_date
          THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_SU_INVALID_DATES'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'PROJ'
            ,p_attribute1       => l_amg_segment1
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
                END IF;

                RAISE  FND_API.G_EXC_ERROR;
          END IF;
       END IF;



/*        Select
           DECODE(p_org_roles(i).start_date,
                  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE, TRUNC(SYSDATE),
                  NULL,TRUNC(SYSDATE),
                  p_org_roles(i).start_date)
       Into     v_start_date_active
       From     dual;
*/     --Commented and added the following line -- By Ansari
       v_start_date_active := null;

       Select project_role_id
       Into   v_project_role_id
       From   pa_project_role_types
       Where  project_role_type=p_org_roles(i).project_role_type;

          v_end_date_active   := p_org_roles(i).end_date;
          v_project_role_type := p_org_roles(i).project_role_type;
          v_person_id         := p_org_roles(i).person_id;
          v_null_number       := to_number(NULL);

/*   PA_PROJECT_PARTIES_PUB.CREATE_PROJECT_PARTY(
          p_api_version => 1.0           -- p_api_version
          , p_init_msg_list => FND_API.G_TRUE  -- p_init_msg_list
          , p_commit => FND_API.G_FALSE  -- p_commit
          , p_validate_only => FND_API.G_FALSE -- p_validate_only
          , p_validation_level => FND_API.G_VALID_LEVEL_FULL  -- p_validation_level
          , p_debug_mode => 'N'          -- p_debug_mode
          , p_object_id => p_project_id  -- p_object_id
          , p_OBJECT_TYPE => 'PA_PROJECTS'  -- p_OBJECT_TYPE
          , p_project_role_id => v_project_role_id  -- p_project_role_id
          , p_project_role_type => NULL  -- p_project_role_type
          , p_RESOURCE_TYPE_ID => 112    -- p_RESOURCE_TYPE_ID
          , p_resource_source_id => v_person_id  -- p_resource_source_id
          , p_resource_name => v_null_char       -- p_resource_name
          , p_start_date_active => v_start_date_active  -- p_start_date_active
          , p_scheduled_flag => 'N'      -- p_scheduled_flag
--          , p_record_version_number => 1 -- p_record_version_number
          , p_calling_module => 'FORM'   -- p_calling_module
          , p_project_id => p_project_id -- p_project_id
          , p_project_end_date => l_completion_date  -- p_project_end_date
          , p_end_date_active => v_end_date_active  -- p_end_date_active
          , x_project_party_id => x_project_party_id  -- x_project_party_id
          , x_resource_id => x_resource_id      -- x_resource_id
          , x_wf_item_type     =>l_wf_item_type
          , x_wf_type          => l_wf_type
          , x_wf_process       => l_wf_party_process
          , x_assignment_id    => l_assignment_id
          , x_return_status => x_return_status  -- x_return_status
          , x_msg_count => x_msg_count          -- x_msg_count
          , x_msg_data => x_msg_data            -- x_msg_data
                             );
*/
  PA_PROJECTS_MAINT_PUB.CREATE_ORG_ROLE(
            p_api_version                     => 1.0           -- p_api_version
          , p_init_msg_list                   => FND_API.G_TRUE  -- p_init_msg_list
          , p_commit                          => FND_API.G_FALSE  -- p_commit
          , p_validate_only                   => FND_API.G_FALSE -- p_validate_only
          , p_validation_level                => FND_API.G_VALID_LEVEL_FULL  -- p_validation_level
          , p_debug_mode                      => 'N'          -- p_debug_mode
          , p_object_id                       => p_project_id  -- p_object_id
          , p_OBJECT_TYPE                     => 'PA_PROJECTS'  -- p_OBJECT_TYPE
          , p_project_role_id                 => v_project_role_id  -- p_project_role_id
          , p_project_role_type               => NULL  -- p_project_role_type
          , p_RESOURCE_TYPE_ID                => 112    -- p_RESOURCE_TYPE_ID
          , p_resource_source_id              => v_person_id  -- p_resource_source_id
          , p_resource_name                   => v_null_char       -- p_resource_name
          , p_start_date_active               => v_start_date_active  -- p_start_date_active
          , p_scheduled_flag                  => 'N'      -- p_scheduled_flag
          , p_calling_module                  => 'FORM'   -- p_calling_module
          , p_project_id                      => p_project_id -- p_project_id
          , p_project_end_date                => l_completion_date  -- p_project_end_date
          , p_end_date_active                 => v_end_date_active  -- p_end_date_active
          , x_return_status                   => x_return_status  -- x_return_status
          , x_msg_count                       => x_msg_count          -- x_msg_count
          , x_msg_data                        => x_msg_data            -- x_msg_data
                             );

          IF    (x_return_status <> FND_API.G_RET_STS_SUCCESS) Then
                p_return_status := x_return_status;
--                p_msg_count     := x_msg_count;
--                p_msg_data      := SUBSTR(p_msg_data||x_msg_data,1,2000);
                if    (x_return_status = FND_API.G_RET_STS_ERROR) then
                      raise  FND_API.G_EXC_UNEXPECTED_ERROR;
                else  -- (x_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then
                      raise  FND_API.G_EXC_ERROR;
                end if;
         END IF;

END IF; -- IF(p_org_roles(i).person_id <>
        -- PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    i := p_org_roles.next(i);

    END LOOP; --org roles


EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */
    ROLLBACK TO add_org_roles_pvt;

    p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */
    ROLLBACK TO add_org_roles_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */
    ROLLBACK TO add_org_roles_pvt;

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

END add_org_roles;


-- anlee org role changes
--====================================================================================
--Name:               check_valid_organization
--
--Type:               Function
--Description:        This function can be used to check for validity of
--            an organization
--
--Called subprograms: none
--
--
--
--History:
--    20-MAR-2002       anlee    Created
--
FUNCTION check_valid_organization (p_party_id IN NUMBER )  RETURN VARCHAR2
IS
    CURSOR l_get_organizations_csr (l_party_id NUMBER)
    IS
    SELECT 'x' FROM
    hz_parties
    WHERE party_id = l_party_id
    AND party_type = 'ORGANIZATION';

l_temp VARCHAR2(1);
BEGIN
             OPEN l_get_organizations_csr (p_party_id);
             FETCH l_get_organizations_csr INTO l_temp;

             IF l_get_organizations_csr%NOTFOUND
             THEN
                CLOSE l_get_organizations_csr;
                RETURN 'N';
             ELSE
                CLOSE l_get_organizations_csr;
                RETURN 'Y';
             END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END check_valid_organization;

--Project Connect 4.0

PROCEDURE get_structure_version(
   p_project_id              IN NUMBER
  ,p_structure_versions_out  OUT NOCOPY PA_PROJECT_PUB.struc_out_tbl_type )
IS
   CURSOR cur_proj_elems
   IS
   SELECT ppe.proj_element_id
     FROM pa_proj_elements ppe, pa_proj_structure_types ppst
    WHERE ppe.proj_element_id = ppst.proj_element_id
      AND ppe.project_id = p_project_id
      AND ppe.object_type = 'PA_STRUCTURES'
      AND ppst.structure_type_id = 1 ;

   CURSOR c1( c_proj_element_id NUMBER ) is
   SELECT d.element_version_id
     FROM pa_proj_structure_types b
          ,pa_proj_elem_ver_structure d
    WHERE d.project_id = p_project_id
      AND 1 = b.structure_type_id
      AND b.proj_element_id = c_proj_element_id
      AND d.proj_element_id = c_proj_element_id
      AND d.status_code = 'STRUCTURE_PUBLISHED'
                     ;

   l_fin_str_ver_id    NUMBER;
   l_wp_str_ver_id    NUMBER;
   l_wp_str_id         NUMBER;
   l_index             NUMBER := 1;

BEGIN

     l_fin_str_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_FIN_STRUC_VER_ID( p_project_id );

     IF l_fin_str_ver_id IS NOT NULL
     THEN
         p_structure_versions_out(l_index).structure_version_id := l_fin_str_ver_id;
         p_structure_versions_out(l_index).structure_type := 'FINANCIAL';
     END IF;

     OPEN cur_proj_elems;
     FETCH cur_proj_elems INTO l_wp_str_id;
     CLOSE cur_proj_elems;

     l_wp_str_ver_id := PA_PROJECT_STRUCTURE_UTILS.GET_LAST_UPDATED_WORKING_VER( l_wp_str_id );

     IF l_wp_str_ver_id IS NULL
     THEN
         OPEN c1(l_wp_str_id );
         FETCH c1 into l_wp_str_ver_id;
         CLOSE c1;
     END IF;

     IF p_structure_versions_out.exists(1)
     THEN
        l_index := l_index + 1;
     END IF;

     IF l_wp_str_ver_id IS NOT NULL
     THEN
         p_structure_versions_out(l_index).structure_version_id := l_wp_str_ver_id;
         p_structure_versions_out(l_index).structure_type := 'WORKPLAN';
         --For shared and versioning enabled structures
         IF l_fin_str_ver_id IS NULL
         THEN
             p_structure_versions_out(l_index+1).structure_version_id := l_wp_str_ver_id;
             p_structure_versions_out(l_index+1).structure_type := 'FINANCIAL';
         END IF;
     END IF;

END get_structure_version;

--Project Connect 4.0
/*Added the procedure for the bug 2802984
This Procedure returns the labor sch type and non labor sch type from the database in the corresponding
out parameters for the related project id and task id if the parameter p_in_labor_sch_type or
p_in_nl_sch_type is PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR else the same values are passed back in the out paramters.
*/

PROCEDURE Check_Schedule_type
     (p_pa_task_id              IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_pa_project_id           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_in_labor_sch_type       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_in_nl_sch_type          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_task_name               IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_pm_task_reference       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_out_labor_sch_type      OUT NOCOPY VARCHAR, -- 4537865 Added the nocopy hint
      p_out_nl_labor_sch_type   OUT NOCOPY VARCHAR, -- 4537865 Added the nocopy hint
      p_return_status           OUT NOCOPY VARCHAR2 -- 4537865 Added the nocopy hint
      )

     IS

CURSOR  l_prj_labor_sch_type_csr(p_pa_project_id VARCHAR2)
IS
SELECT  labor_sch_type
FROM    pa_projects
where   project_id = p_pa_project_id;

CURSOR  l_tsk_lb_sch_type_task_csr(p_pa_project_id VARCHAR2,p_pa_task_id VARCHAR2)
IS
SELECT  labor_sch_type
FROM    pa_tasks
where   project_id = p_pa_project_id
and     task_id= p_pa_task_id;

CURSOR  l_prj_nl_sch_type_csr(p_pa_project_id VARCHAR2)
IS
SELECT  non_labor_sch_type
FROM    pa_projects
where   project_id = p_pa_project_id;

CURSOR  l_tsk_nl_sch_type_task_csr(p_pa_project_id VARCHAR2,p_pa_task_id VARCHAR2)
IS
SELECT  non_labor_sch_type
FROM    pa_tasks
where   project_id = p_pa_project_id
and    task_id = p_pa_task_id;

CURSOR   l_amg_project_csr(p_pa_project_id pa_projects.project_id%type)
IS
SELECT   segment1
FROM     pa_projects p
WHERE    p.project_id = p_pa_project_id;



    l_api_name  CONSTANT     VARCHAR2(30) := 'Check Schedule';
    l_out_labor_sch_type         VARCHAR(1);
    l_out_nl_labor_sch_type      VARCHAR(1);
    l_prj_lab_sch_type           VARCHAR2(1);
    l_tsk_lab_sch_type           VARCHAR2(1);
    l_prj_nl_sch_type            VARCHAR2(1);
    l_tsk_nl_sch_type            VARCHAR2(1);
    l_amg_segment1               VARCHAR(50);
    l_amg_task_number            VARCHAR2(50);

  BEGIN

     p_return_status :=  FND_API.G_RET_STS_SUCCESS;

   OPEN l_amg_project_csr( p_pa_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;


l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number => p_task_name
    ,p_task_reference =>p_pm_task_reference
    ,p_task_id => p_pa_task_id);

    IF p_in_labor_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       IF p_pa_task_id IS NULL THEN

         OPEN l_prj_labor_sch_type_csr(p_pa_project_id);
     FETCH l_prj_labor_sch_type_csr into l_prj_lab_sch_type;
     CLOSE l_prj_labor_sch_type_csr;

     p_out_labor_sch_type := l_prj_lab_sch_type;

       ELSE

         OPEN l_tsk_lb_sch_type_task_csr(p_pa_project_id,p_pa_task_id);
     FETCH l_tsk_lb_sch_type_task_csr into l_tsk_lab_sch_type;
     CLOSE l_tsk_lb_sch_type_task_csr;

         p_out_labor_sch_type := l_tsk_lab_sch_type;

       END IF;

   ELSIF  p_in_labor_sch_type IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_LAB_SCH_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;

    ELSE

     p_out_labor_sch_type := p_in_labor_sch_type;

   END IF;
      IF p_in_nl_sch_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
       IF p_pa_task_id IS NULL THEN

         OPEN l_prj_nl_sch_type_csr(p_pa_project_id);
     FETCH l_prj_nl_sch_type_csr into l_prj_nl_sch_type;
     CLOSE l_prj_nl_sch_type_csr;

    p_out_nl_labor_sch_type := l_prj_nl_sch_type;

       ELSE

         OPEN l_tsk_nl_sch_type_task_csr(p_pa_project_id,p_pa_task_id);
     FETCH l_tsk_nl_sch_type_task_csr into l_tsk_nl_sch_type;
     CLOSE l_tsk_nl_sch_type_task_csr;

     p_out_nl_labor_sch_type := l_tsk_nl_sch_type;

       END IF;

   ELSIF  p_in_nl_sch_type IS NULL THEN

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NL_SCH_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  ELSE

 p_out_nl_labor_sch_type := p_in_nl_sch_type;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_ERROR;

    -- 4537865 RESET OUT PARAMS
    p_out_nl_labor_sch_type := NULL ;
    p_out_labor_sch_type := NULL ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- 4537865 RESET OUT PARAMS
    p_out_nl_labor_sch_type := NULL ;
    p_out_labor_sch_type := NULL ;

    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- 4537865 RESET OUT PARAMS
    p_out_nl_labor_sch_type := NULL ;
    p_out_labor_sch_type := NULL ;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;
  end Check_Schedule_type;

/*Added the procedure for the bug 2802984
This procedure validates all the parameters related to labor schedule and non labor schedule.
Refer bug for more details.
*/

PROCEDURE validate_schedule_values
   (p_pa_project_id                     IN      NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_pa_task_id                        IN      NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_task_name                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_pm_task_reference                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_lab_db_sch_type                   IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_db_sch_type                    IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_labor_sch_type                    IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_sch_type                       IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_emp_bill_rate_schedule_id         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_job_bill_rate_schedule_id         IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_labor_schedule_fixed_date         IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_labor_schedule_discount           IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_labor_disc_reason_code            IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_nl_bill_rate_org_id               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_non_lab_std_bill_rt_sch_id        IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_nl_schedule_fixed_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_nl_schedule_discount              IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_non_labor_disc_reason_code        IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
    p_rev_ind_rate_sch_id               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_inv_ind_rate_sch_id               IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
    p_rev_ind_sch_fixed_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_inv_ind_sch_fixed_date            IN      DATE            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
    p_return_status                     OUT NOCOPY     VARCHAR2 -- 4537865 Added the nocopy hint
    )

IS

CURSOR l_rev_rate_schedule_type_csr( p_rev_ind_rate_sch_id NUMBER)
IS
SELECT       ind_rate_schedule_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = p_rev_ind_rate_sch_id
AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate));

CURSOR l_inv_rate_schedule_type_csr( p_inv_ind_rate_sch_id NUMBER)
IS
SELECT       ind_rate_schedule_type
FROM         pa_ind_rate_schedules
WHERE        ind_rate_sch_id = p_inv_ind_rate_sch_id
AND          trunc(sysdate) between trunc(start_date_active) and nvl(end_date_active,trunc(sysdate));

--R12: Bug 4363092 - removed nvl for org_id in below cursor
CURSOR l_emp_rate_sch_id_csr( p_emp_bill_rate_schedule_id NUMBER)
IS
SELECT       'x'
FROM         pa_std_bill_rate_schedules_all brs, pa_projects pa
WHERE        brs.bill_rate_sch_id = p_emp_bill_rate_schedule_id
AND          pa.project_id=p_pa_project_id
and          brs.schedule_type = 'EMPLOYEE'
AND          ( pa.multi_currency_BILLING_flag='Y'
OR           (pa.multi_currency_billing_flag='N'
AND          brs.rate_sch_currency_code=pa.project_currency_code))
AND          ((pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'Y')
or  (pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id)='N'
and              brs.org_id=pa.org_id))
and (brs.share_across_ou_flag = 'Y'
     OR  (brs.share_across_ou_flag = 'N'
          and brs.org_id = pa.org_id
          ));

--R12: Bug 4363092 - removed nvl for org_id in below cursor
CURSOR l_job_rate_sch_id_csr( p_job_bill_rate_schedule_id NUMBER)
IS
SELECT       'x'
FROM         pa_std_bill_rate_schedules_all brs, pa_project_types_all pt, pa_projects pa
WHERE        bill_rate_sch_id = p_job_bill_rate_schedule_id
AND          brs.job_group_id=pt.bill_job_group_id
and          brs.schedule_type = 'JOB'
AND          pa.project_type=pt.project_type
AND          pa.org_id = pt.org_id    -- added for Bug 5675391
AND          ( pa.multi_currency_BILLING_flag='Y'
OR           (pa.multi_currency_billing_flag='N'
AND          brs.rate_sch_currency_code=pa.project_currency_code))
AND          ((pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'Y')
or  (pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id)='N'
and              brs.org_id=pa.org_id))
and (brs.share_across_ou_flag = 'Y'
     OR  (brs.share_across_ou_flag = 'N'
          and brs.org_id = pa.org_id
          ))
AND          pa.project_id=p_pa_project_id;

--R12: Bug 4363092 - removed nvl for org_id in below cursor
CURSOR l_nl_org_sch_id_csr( p_nl_bill_rate_org_id NUMBER,p_non_lab_std_bill_rt_sch_id NUMBER)
IS
SELECT       'x'
FROM         pa_std_bill_rate_schedules_all brs, pa_projects pa
WHERE        brs.organization_id = p_nl_bill_rate_org_id
AND          bill_rate_sch_id = p_non_lab_std_bill_rt_sch_id
and          brs.schedule_type = 'NON-LABOR'
and  (brs.schedule_type <> 'JOB'
 or  (brs.schedule_type = 'JOB'
and   brs.job_group_id = pa.bill_job_group_id))
AND          ( pa.multi_currency_BILLING_flag='Y'
OR           (pa.multi_currency_billing_flag='N'
AND          brs.rate_sch_currency_code=pa.project_currency_code))
AND          ((pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id) = 'Y')
or  (pa_multi_currency_billing.is_sharing_bill_rates_allowed(pa.org_id)='N'
and              brs.org_id=pa.org_id))
and (brs.share_across_ou_flag = 'Y'
     OR  (brs.share_across_ou_flag = 'N'
          and brs.org_id = pa.org_id
          ))
AND          pa.project_id=p_pa_project_id;


CURSOR   l_amg_project_csr(p_pa_project_id pa_projects.project_id%type)
IS
SELECT   segment1
FROM     pa_projects p
WHERE    p.project_id = p_pa_project_id;

CURSOR   get_lab_disc_reason_code_csr(p_labor_disc_reason_code VARCHAR2)
IS
SELECT   'x'
FROM     pa_lookups
WHERE    lookup_type ='RATE AND DISCOUNT REASON'
AND      lookup_code=p_labor_disc_reason_code
AND    trunc(nvl(end_date_active,sysdate)) >= trunc(sysdate);

CURSOR   get_nl_disc_reason_code_csr(p_non_labor_disc_reason_code VARCHAR2)
IS
SELECT   'x'
FROM     pa_lookups
WHERE    lookup_type ='RATE AND DISCOUNT REASON'
AND      lookup_code=p_non_labor_disc_reason_code
AND    trunc(nvl(end_date_active,sysdate)) >= trunc(sysdate);


l_api_name  CONSTANT     VARCHAR2(30) := 'Validate Schedule Values';
l_rev_rate_schedule_type     VARCHAR2(1);
l_inv_rate_schedule_type     VARCHAR2(1);
l_temp_dummy                 VARCHAR2(1) := null;
l_non_lab_std_bill_schdl     VARCHAR2(40);
l_amg_segment1               VARCHAR2(50);
l_amg_task_number            VARCHAR2(50);

BEGIN

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN l_amg_project_csr( p_pa_project_id );
   FETCH l_amg_project_csr INTO l_amg_segment1;
   CLOSE l_amg_project_csr;


   l_amg_task_number := pa_interface_utils_pub.get_task_number_amg
    (p_task_number => p_task_name
    ,p_task_reference =>p_pm_task_reference
    ,p_task_id => p_pa_task_id);


 IF  p_nl_sch_type = 'B' then  /* Basically B is passed through the script or value in DataBase is 'B' */

 /*Give an error when non_lab_std_bill_rt_sch_id is null and give an error
 if non_labor_std_bill_rt_sch_id is PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 when the Schedule is being changed from 'I' (burden) to 'B' (bill) */

 IF p_non_lab_std_bill_rt_sch_id IS NULL THEN  /* Explicitly passed as NULL, hence Error */
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NL_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  ELSIF p_non_lab_std_bill_rt_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
           IF p_nl_db_sch_type = 'I'  THEN /* Schedule is being changed from 'I' (burden) to 'B' (bill) */
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NL_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
             END IF;
  END IF;

    /*Give an error when non_lab_bill_rt_org_id is null and give an error
 if non_labor_bill_rt_org_id is PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 when the Schedule is being changed from 'I' to 'B'*/

   IF  p_nl_bill_rate_org_id IS NULL
        THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_BILL_RT_ORG_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
    ELSIF p_nl_bill_rate_org_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
      IF p_nl_db_sch_type = 'I'  THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_BILL_RT_ORG_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
         END IF;

/*Give an error if the combination of non_labor_bill_rt_sch_id and nl_bill_rate_org_id is invalid*/

 IF (p_non_lab_std_bill_rt_sch_id IS NOT NULL
 AND p_non_lab_std_bill_rt_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
    AND (p_nl_bill_rate_org_id IS NOT NULL AND p_nl_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
        THEN
           OPEN l_nl_org_sch_id_csr( p_nl_bill_rate_org_id,p_non_lab_std_bill_rt_sch_id);
           FETCH l_nl_org_sch_id_csr INTO l_temp_dummy;
      IF l_nl_org_sch_id_csr%NOTFOUND
           THEN
         CLOSE l_nl_org_sch_id_csr;
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_NL_ORG_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
         CLOSE l_nl_org_sch_id_csr;
 END IF;

/*
1) Give an error when the nl_schedule_discount is null or PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and a value is being
   passed to non_labor_disc_reason_code as cannot pass disc reason code with schedule discount
2) Give an error when nl_schedule_discount is not null and <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    and non_labor_disc_reason_code is null or =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
3) Give an error when nl_schedule_discount is not null and <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   and the non_labor_disc_reason_code passed is invalid
*/

 l_temp_dummy := NULL;

  IF p_nl_schedule_discount IS NULL OR p_nl_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
        IF p_non_labor_disc_reason_code IS NOT NULL
        AND p_non_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
     THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NL_DISC_REASON_CODE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
elsif  (p_nl_schedule_discount IS NOT NULL
       AND p_nl_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  THEN
  IF (p_non_labor_disc_reason_code IS NULL
     OR p_non_labor_disc_reason_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_NL_DISC_CODE_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSE
      OPEN get_nl_disc_reason_code_csr(p_non_labor_disc_reason_code);
      FETCH get_nl_disc_reason_code_csr INTO l_temp_dummy;
           IF get_nl_disc_reason_code_csr%NOTFOUND THEN
          CLOSE get_nl_disc_reason_code_csr;
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_NLDISC_RN_CODE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
         CLOSE get_nl_disc_reason_code_csr;
     END IF;
 END IF;

ELSE  /* Else for if non_labor_sch_type = 'B'*/

/*
1) Give an error when p_rev_ind_rate_sch_id is null
2) Give an error when p_rev_ind_rate_sch_id not passed(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   and the schedule_type is being changed from 'B' to 'I'
*/

  IF p_rev_ind_rate_sch_id IS  NULL THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_REV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_rev_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        IF p_nl_db_sch_type = 'B'  THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_REV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
    END IF;


 /*
 1) Give an error when a value is passed to p_rev_ind_rate_sch_id and it is invalid.
 2) Give an error when the Burden Schedule type is P (Provisional) for the attached revenue burden schedule
  and the p_rev_ind_sch_fixed_date date is being passed.
 */

  IF (p_rev_ind_rate_sch_id IS NOT NULL
   AND p_rev_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       THEN
       OPEN l_rev_rate_schedule_type_csr(p_rev_ind_rate_sch_id);
       FETCH l_rev_rate_schedule_type_csr INTO l_rev_rate_schedule_type;
      IF l_rev_rate_schedule_type_csr%NOTFOUND THEN
        CLOSE l_rev_rate_schedule_type_csr;
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_REV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
     CLOSE l_rev_rate_schedule_type_csr;
       IF l_rev_rate_schedule_type = 'P'
           THEN
              IF p_rev_ind_sch_fixed_date IS NOT NULL
           AND p_rev_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CNT_FIX_REV_DTE_PROV'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
        END IF;
      END IF;


    l_temp_dummy :=null;

/*
1) Give an error when p_inv_ind_rate_sch_id is null
2) Give an error when p_inv_ind_rate_sch_id not passed(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   and the schedule_type is being changed from 'B' to 'I'
*/

  IF p_inv_ind_rate_sch_id IS  NULL THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_inv_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        IF p_nl_db_sch_type = 'B'  THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
    END IF;


 /*
 1) Give an error when a value is passed to p_inv_ind_rate_sch_id and it is invalid.
 2) Give an error when the Burden Schedule type is (Provisional) for the attached invoice burden schedule
  and the p_inv_ind_sch_fixed_date date is being passed.
 */

  IF p_inv_ind_rate_sch_id IS NOT NULL
   AND p_inv_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       THEN

       OPEN l_inv_rate_schedule_type_csr(p_inv_ind_rate_sch_id);
       FETCH l_inv_rate_schedule_type_csr INTO l_inv_rate_schedule_type;
      IF l_inv_rate_schedule_type_csr%NOTFOUND THEN
        CLOSE l_inv_rate_schedule_type_csr;
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_INV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
     CLOSE l_inv_rate_schedule_type_csr;
       IF l_inv_rate_schedule_type = 'P'
           THEN
              IF p_inv_ind_sch_fixed_date IS NOT NULL
           AND p_inv_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CNT_FIX_INV_DTE_PROV'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
        END IF;
      END IF;

 END IF;         /*END IF OF NON LAB SCH TYPE = 'B'*/

/*START OF VALIDATIONS FOR LABOR_SCH_TYPE = B*/

 IF p_labor_sch_type = 'B' THEN

 /*
  Give an error only when if employee_bill_rate_sch_id passed is invalid
 */

  IF p_emp_bill_rate_schedule_id IS NOT NULL
 AND p_emp_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
           OPEN l_emp_rate_sch_id_csr( p_emp_bill_rate_schedule_id);
           FETCH l_emp_rate_sch_id_csr INTO l_temp_dummy;
      IF l_emp_rate_sch_id_csr%NOTFOUND
           THEN
         CLOSE l_emp_rate_sch_id_csr;

                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_EMP_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
       CLOSE l_emp_rate_sch_id_csr;
     END IF;

 /*
 1) If prm is not licensed then job_bill_rate_schedule_id is not mandatory
 2) when prm is licensed then
    - Give an error when job_bill_rate_schedule_id is null.
    - Give an error when job_bill_rate_schedule_id is not passed and
      the the labor schedule type is changed from 'I' to 'B'
 */

IF pa_install.is_prm_licensed='Y' THEN
 IF p_job_bill_rate_schedule_id IS NULL
    THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_JOB_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
  ELSIF p_job_bill_rate_schedule_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
      IF  p_lab_db_sch_type = 'I' THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_JOB_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
        END IF;
     END IF;
 END IF;

  /*
 Give an error when the job_bill_rate_schedule_id is invalid
 */

    IF p_job_bill_rate_schedule_id IS NOT NULL
     AND p_job_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
     l_temp_dummy:=null;
           OPEN l_job_rate_sch_id_csr( p_job_bill_rate_schedule_id);
           FETCH l_job_rate_sch_id_csr INTO l_temp_dummy;
      IF l_job_rate_sch_id_csr%NOTFOUND
           THEN
          CLOSE l_job_rate_sch_id_csr;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_JOB_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
           END IF;
       CLOSE l_job_rate_sch_id_csr;
         END IF;


l_temp_dummy := null;


/*
1) Give an error when the labor_schedule_discount is null or PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and
   a value is being passed to non_labor_disc_reason_code.
2) Give an error when labor_schedule_discount is not null and <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    and labor_disc_reason_code is null or =PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
3) Give an error when labor_schedule_discount is not null and <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   and the labor_disc_reason_code passed is invalid
*/

  IF (p_labor_schedule_discount IS NULL OR
    p_labor_schedule_discount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
      THEN
        IF p_labor_disc_reason_code IS NOT NULL
        AND p_labor_disc_reason_code<> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
       THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_LAB_DISC_REASON_CODE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
elsif (p_labor_schedule_discount IS NOT NULL
       AND p_labor_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
  THEN
  IF p_labor_disc_reason_code IS NULL
  OR p_labor_disc_reason_code= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_LAB_DISC_CODE_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSE
      OPEN get_lab_disc_reason_code_csr(p_labor_disc_reason_code);
      FETCH get_lab_disc_reason_code_csr INTO l_temp_dummy;
           IF get_lab_disc_reason_code_csr%NOTFOUND THEN
          CLOSE get_lab_disc_reason_code_csr;
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_LDISC_RN_CODE'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
            END IF;
             CLOSE get_lab_disc_reason_code_csr;
    END IF;
 END IF;



  ELSE  /*ELSE OF LABOR SCH TYPE = 'B'*/


/*
1) Give an error when p_rev_ind_rate_sch_id is null
2) Give an error when p_rev_ind_rate_sch_id not passed(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   and the schedule_type is being changed from 'B' to 'I'
*/

  IF p_rev_ind_rate_sch_id IS  NULL THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_REV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_rev_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
        IF p_lab_db_sch_type = 'B' THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_REV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
    END IF;


 /*
 1) Give an error when a value is passed to p_rev_ind_rate_sch_id and it is invalid.
 2) Give an error when the Burden Schedule type is P (Provisional) for the attached revenue burden schedule
    and the p_rev_ind_sch_fixed_date date is being passed.
 */

  IF p_rev_ind_rate_sch_id IS NOT NULL
   AND p_rev_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
       THEN

       OPEN l_rev_rate_schedule_type_csr(p_rev_ind_rate_sch_id);
       FETCH l_rev_rate_schedule_type_csr INTO l_rev_rate_schedule_type;
      IF l_rev_rate_schedule_type_csr%NOTFOUND THEN
        CLOSE l_rev_rate_schedule_type_csr;
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_REV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
        END IF;
     CLOSE l_rev_rate_schedule_type_csr;
       IF l_rev_rate_schedule_type = 'P'
           THEN
              IF p_rev_ind_sch_fixed_date IS NOT NULL
           AND p_rev_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CNT_FIX_REV_DTE_PROV'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
        END IF;
      END IF;


    l_temp_dummy :=null;

/*
1) Give an error when p_inv_ind_rate_sch_id is null
2) Give an error when p_inv_ind_rate_sch_id not passed(PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   and the schedule_type is being changed from 'B'(bill) to 'I'(burden)
*/

  IF p_inv_ind_rate_sch_id IS  NULL THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
   ELSIF p_inv_ind_rate_sch_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
       IF  p_lab_db_sch_type = 'B' THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INV_SCH_ID_NOT_NULL'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
          END IF;
    END IF;


 /*
 1) Give an error when a value is passed to p_inv_ind_rate_sch_id and it is invalid.
 2) Give an error when the Burden Schedule type is P(Provisional) for the attached invoice burden schedule
   and the p_inv_ind_sch_fixed_date date is being passed.
 */

  IF (p_inv_ind_rate_sch_id IS NOT NULL
   AND p_inv_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
       THEN

       OPEN l_inv_rate_schedule_type_csr(p_inv_ind_rate_sch_id);
       FETCH l_inv_rate_schedule_type_csr INTO l_inv_rate_schedule_type;
      IF l_inv_rate_schedule_type_csr%NOTFOUND THEN
        CLOSE l_inv_rate_schedule_type_csr;
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_INVALID_INV_SCH_ID'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
        END IF;
     CLOSE l_inv_rate_schedule_type_csr;
       IF l_inv_rate_schedule_type = 'P'
           THEN
              IF p_inv_ind_sch_fixed_date IS NOT NULL
           AND p_inv_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
          THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                     pa_interface_utils_pub.map_new_amg_msg
                     ( p_old_message_code => 'PA_CNT_FIX_INV_DTE_PROV'
                      ,p_msg_attribute    => 'CHANGE'
                      ,p_resize_flag      => 'Y'
                      ,p_msg_context      => 'TASK'
                      ,p_attribute1       => l_amg_segment1
                      ,p_attribute2       => l_amg_task_number
                      ,p_attribute3       => ''
                      ,p_attribute4       => ''
                      ,p_attribute5       => '');
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
         END IF;
        END IF;
      END IF;



END IF;         /*END IF OF LAB SCH TYPE = 'B'*/





EXCEPTION

    WHEN FND_API.G_EXC_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
/* dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
/* dbms_output.put_line('handling an OTHERS exception'); */

    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
        FND_MSG_PUB.add_exc_msg
                ( p_pkg_name        => G_PKG_NAME
                , p_procedure_name  => l_api_name   );

    END IF;

end validate_schedule_values;

--====================================================================================
--Name:               VALIDATE_DATA
--
--Type:               Procedure
--Description:        This procedure is to do different kinds of data validation
--                    while creating, updating a project or task.
--
--Validations         1) Validating if all the customers added to tasks
--                       in a project are project customers or not if enable top task
--                       customer flag is set at project level.
--                    2) Validating that only one project customer is marked as
--                       default top task customer if enable top task
--                       customer flag is set at project level.
--History:
--    08-Jan-2007       apangana    Created validation 1, 2
--    10-Oct-2008       rthumma     Bug 7255015 : Modified cursor any_invalid_customer
--                                  in procedure VALIDATE_DATA
--====================================================================================
PROCEDURE VALIDATE_DATA
          (p_project_id          IN         NUMBER  ,
           p_calling_context     IN         VARCHAR2,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER  ,
           x_msg_data           OUT NOCOPY VARCHAR2  ) IS

    -- Bug 7255015
    cursor any_invalid_customer is
    SELECT 'Y' FROM pa_tasks
    WHERE project_id = p_project_id
    AND parent_task_id IS NULL
    AND nvl(customer_id, -1) NOT IN (select customer_id
                      from pa_project_customers
                      where project_id=p_project_id);

    l_any_invalid_customer varchar2(1) :='N';

    valid_def_ttsk_cust   VARCHAR2(1) :='N';

    cursor project_data is
    select enable_top_task_customer_flag
    from pa_projects_all
    where project_id=p_project_id;

    l_enable_tt_cust_flag varchar2(1) :='N';
    l_cust_count          number;

    l_msg_count                      NUMBER := 0;
    l_data                           VARCHAR2(2000);
    l_msg_data                       VARCHAR2(2000);
    l_msg_index_out                  NUMBER;
    l_debug_mode                     VARCHAR2(1);
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count :=0;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'VALIDATE_DATA',
                                    p_debug_mode => l_debug_mode );
        pa_debug.g_err_stage:= 'Entered VALIDATE_DATA';
        pa_debug.write('PA_PROJECT_PVT.VALIDATE_DATA',pa_debug.g_err_stage,3);
    END IF;
    --validation 1

    open project_data;
    fetch project_data into l_enable_tt_cust_flag;
    close project_data;

    if (p_calling_context in ('CREATE_PROJECT','UPDATE_PROJECT')
        and l_enable_tt_cust_flag = 'Y') then
            open any_invalid_customer;
            fetch any_invalid_customer into l_any_invalid_customer;
            close any_invalid_customer;

            if l_any_invalid_customer = 'Y' then
                select count(*) into l_cust_count
                from pa_project_customers
                where project_id=p_project_id;

                if l_cust_count > 0 then
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_INVALID_TASK_CUSTOMER');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                end if;
            end if;
    end if;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validation for invalid task customers was done';
        pa_debug.write('PA_PROJECT_PVT.VALIDATE_DATA',pa_debug.g_err_stage,3);
    END IF;

    --validation 2
    if (p_calling_context = 'UPDATE_PROJECT' and l_enable_tt_cust_flag = 'Y') then
        begin
            select 'Y' into valid_def_ttsk_cust
            from pa_project_customers
            where project_id=p_project_id
            and default_top_task_cust_flag='Y';
        exception
            when NO_DATA_FOUND then

                select count(*) into l_cust_count
                from pa_project_customers
                where project_id=p_project_id;

                if l_cust_count > 0 then
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_INC_NUM_DEF_TT_CUST');
                    RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                end if;
            when TOO_MANY_ROWS  then
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_INC_NUM_DEF_TT_CUST');
                RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
        end;
    end if;

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validation for single default top task customer was done';
        pa_debug.write('PA_PROJECT_PVT.VALIDATE_DATA',pa_debug.g_err_stage,3);
    END IF;

    IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
    END IF;

    EXCEPTION
        WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
            IF x_return_status IS NULL OR
               x_return_status =  FND_API.G_RET_STS_SUCCESS THEN
                  x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                  PA_INTERFACE_UTILS_PUB.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => l_msg_count,
                        p_msg_data       => l_msg_data,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out);

                  x_msg_data  := l_data;
                  x_msg_count := l_msg_count;
            ELSE
                  x_msg_count := l_msg_count;
            END IF;

        IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
        END IF;
            RETURN;
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_PROJECT_PVT'
                                    ,p_procedure_name  => 'VALIDATE_DATA'
                                    ,p_error_text      => sqlerrm);

            IF l_debug_mode = 'Y' THEN
                  pa_debug.G_Err_Stack := SQLERRM;
                  pa_debug.write('PA_PROJECT_PVT.VALIDATE_DATA' ,pa_debug.G_Err_Stack,4);
                  pa_debug.reset_curr_function;
            END IF;
            RAISE;

END VALIDATE_DATA;

end PA_PROJECT_PVT;

/
