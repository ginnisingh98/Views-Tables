--------------------------------------------------------
--  DDL for Package Body PA_HR_UPDATE_PA_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_UPDATE_PA_ENTITIES" AS
/* $Header: PAHRUPDB.pls 120.6.12010000.11 2010/06/15 00:38:54 snizam ship $ */

-- Global variable for debugging. Bug 4352236.
G_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
-- P_DEBUG_MODE varchar2(1); -- Bug 4352236 - use global variable G_DEBUG_MODE
BEGIN
    -- P_DEBUG_MODE := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
    IF (G_DEBUG_MODE ='Y') THEN
       pa_debug.write('PA_HR_UPDATE_PA_ENTITIES', 'log: ' || p_log_msg, 3);
    END IF;
END log_message;


-- -------------------------------------------------------------------------------------
-- Global Constants
-- -------------------------------------------------------------------------------------
-- G_USER_ID         CONSTANT NUMBER := FND_GLOBAL.user_id;
-- G_LOGIN_ID        CONSTANT NUMBER := FND_GLOBAL.login_id;

PROCEDURE update_project_entities    ( p_calling_mode              in  varchar2,
                                       p_table_name                in  varchar2,
                                       p_person_id                 in  number DEFAULT NULL,
                                       p_start_date_old            in  date DEFAULT NULL,
                                       p_start_date_new            in  date DEFAULT NULL,
                                       p_end_date_old              in  date DEFAULT NULL,
                                       p_end_date_new              in  date DEFAULT NULL,
                                       p_org_id_old                in  number DEFAULT NULL,
                                       p_org_id_new                in  number DEFAULT NULL,
                                       p_job_id_old                in  number DEFAULT NULL,
                                       p_job_id_new                in  number DEFAULT NULL,
                                       p_from_job_group_id         in  number DEFAULT NULL,
                                       p_to_job_group_id           in  number DEFAULT NULL,
                                       p_job_level_old             in  number DEFAULT NULL,
                                       p_job_level_new             in  number DEFAULT NULL,
                                       p_supervisor_old            in  number DEFAULT NULL,
                                       p_supervisor_new            in  number DEFAULT NULL,
                                       p_primary_flag_old          in  varchar2 DEFAULT NULL,
                                       p_primary_flag_new          in  varchar2 DEFAULT NULL,
                                       p_org_info1_old             in  varchar2 DEFAULT NULL,
                                       p_org_info1_new             in  varchar2 DEFAULT NULL,
                                       p_jei_information2_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information2_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information3_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information3_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information4_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information4_new      in  varchar2 DEFAULT NULL,
                                       p_jei_information6_old      in  varchar2 DEFAULT NULL,
                                       p_jei_information6_new      in  varchar2 DEFAULT NULL,
                                       p_grade_id_old              in  number DEFAULT NULL,
                                       p_grade_id_new              in  number DEFAULT NULL,
                                       p_full_name_old             in  varchar2 DEFAULT NULL,
                                       p_full_name_new             in  varchar2 DEFAULT NULL,
                                       p_country_old               in  varchar2 DEFAULT NULL,
                                       p_country_new               in  varchar2 DEFAULT NULL,
                                       p_city_old                  in  varchar2 DEFAULT NULL,
                                       p_city_new                  in  varchar2 DEFAULT NULL,
                                       p_region2_old               in  varchar2 DEFAULT NULL,
                                       p_region2_new               in  varchar2 DEFAULT NULL,
                                       p_org_struct_element_id     in  number DEFAULT NULL,
                                       p_organization_id_parent    in  number DEFAULT NULL,
                                       p_organization_id_child     in  number DEFAULT NULL,
                                       p_org_structure_version_id  in  number DEFAULT NULL,
                                       p_inactive_date_old         in  date DEFAULT NULL,
                                       p_inactive_date_new         in  date DEFAULT NULL,
                                       p_from_job_id_old           in  number DEFAULT NULL,
                                       p_from_job_id_new           in  number DEFAULT NULL,
                                       p_to_job_id_old             in  number DEFAULT NULL,
                                       p_to_job_id_new             in  number DEFAULT NULL,
                                       p_org_info_context          in  varchar2 DEFAULT NULL,
                                       x_return_status             out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                       x_error_message_code        out NOCOPY varchar2) --File.Sql.39 bug 4440895
               is
--
--
--

ItemType        varchar2(30) := 'PAXWFHRU';  -- Identifies the workflow that will be executed.
ItemKey                number ;
l_process                        VARCHAR2(30);

l_org_struct_element_id          NUMBER;
l_organization_id_child          NUMBER;
l_organization_id_parent         NUMBER;
l_org_structure_version_id       NUMBER;

l_msg_count                NUMBER;
l_msg_data                VARCHAR(2000);
l_return_status                VARCHAR2(1);
-- l_api_version_number        NUMBER                := 1.0;
l_data                        VARCHAR2(2000);
l_msg_index_out                NUMBER;
l_save_thresh           NUMBER ;

l_err_code              NUMBER := 0;
l_err_stage             VARCHAR2(2000);
l_err_stack             VARCHAR2(2000);
--
--
begin
        --
        -- bug 2840328:PA HR UPDATE TRIGGERS SHOULD NOT CREATE WF PROCESS IF NO RELEVANT CHANGES
        -- We should not start workflow when no attribute of interest to PA has not been
        -- changed on per_all_people_f, PER_ALL_ASSIGNMENTS_F.etc.
        IF ( nvl(p_start_date_old,FND_API.G_MISS_DATE) = nvl(p_start_date_new,FND_API.G_MISS_DATE) AND
             nvl(p_end_date_old,FND_API.G_MISS_DATE) = nvl(p_end_date_new,FND_API.G_MISS_DATE) AND
             nvl(p_org_id_old,FND_API.G_MISS_NUM) = nvl(p_org_id_new,FND_API.G_MISS_NUM) AND
             nvl(p_job_id_old,FND_API.G_MISS_NUM) = nvl(p_job_id_new,FND_API.G_MISS_NUM) AND
             nvl(p_job_level_old,FND_API.G_MISS_NUM) = nvl(p_job_level_new,FND_API.G_MISS_NUM) AND
             nvl(p_supervisor_old,FND_API.G_MISS_NUM) = nvl(p_supervisor_new,FND_API.G_MISS_NUM) AND
             nvl(p_primary_flag_old,FND_API.G_MISS_CHAR) = nvl(p_primary_flag_new,FND_API.G_MISS_CHAR) AND
             nvl(p_org_info1_old,FND_API.G_MISS_CHAR) = nvl(p_org_info1_new,FND_API.G_MISS_CHAR) AND
             nvl(p_jei_information2_old,FND_API.G_MISS_CHAR) = nvl(p_jei_information2_new,FND_API.G_MISS_CHAR) AND
             nvl(p_jei_information3_old,FND_API.G_MISS_CHAR) = nvl(p_jei_information3_new,FND_API.G_MISS_CHAR) AND
             nvl(p_jei_information4_old,FND_API.G_MISS_CHAR) = nvl(p_jei_information4_new,FND_API.G_MISS_CHAR) AND
             nvl(p_jei_information6_old,FND_API.G_MISS_CHAR) = nvl(p_jei_information6_new,FND_API.G_MISS_CHAR) AND
             nvl(p_grade_id_old,FND_API.G_MISS_NUM) = nvl(p_grade_id_new,FND_API.G_MISS_NUM) AND
             nvl(p_full_name_old,FND_API.G_MISS_CHAR) = nvl(p_full_name_new,FND_API.G_MISS_CHAR) AND
             nvl(p_country_old,FND_API.G_MISS_CHAR) = nvl(p_country_new,FND_API.G_MISS_CHAR) AND
             nvl(p_city_old,FND_API.G_MISS_CHAR) = nvl(p_city_new,FND_API.G_MISS_CHAR) AND
             nvl(p_region2_old,FND_API.G_MISS_CHAR) = nvl(p_region2_new,FND_API.G_MISS_CHAR) AND
             nvl(p_inactive_date_old,FND_API.G_MISS_DATE) = nvl(p_inactive_date_new,FND_API.G_MISS_DATE) AND
             nvl(p_from_job_id_old,FND_API.G_MISS_NUM) = nvl(p_from_job_id_new,FND_API.G_MISS_NUM) AND
             nvl(p_to_job_id_old,FND_API.G_MISS_NUM) = nvl(p_to_job_id_new,FND_API.G_MISS_NUM) ) THEN
          return;

        -- When the trigger on PER_JOB_EXTRA_INFO is fired, we won't launch the WF in following cases
        -- because we don't need to update pa_resources_denorm.
        -- If 'Include in Utilization' Falg=N, we don't need to pull thos corresponding resources. So
        -- there won't be any resources to update..
        ELSIF p_table_name= 'PER_JOB_EXTRA_INFO' THEN
          IF ( p_calling_mode='INSERT' AND (p_jei_information3_new='N' OR p_jei_information3_new IS NULL)) THEN
             return;
          END IF;
        END IF;

        --
        -- Get a unique identifier for this specific workflow
        --

        SELECT pa_workflow_itemkey_s.nextval
          INTO itemkey
          FROM dual;
        --
        -- Since this workflow needs to be executed in the background we need
        -- to change the threshold. So we save the current threshold which
        -- will be used later on to change it back to the current threshold.
        --

        l_save_thresh  := wf_engine.threshold ;


        IF wf_engine.threshold < 0 THEN
            wf_engine.threshold := l_save_thresh ;
        END IF;


        --
        -- Set the threshold to bellow 0 so that the process will be created
        -- in the background
        --

        wf_engine.threshold := -1 ;


        IF p_table_name = 'PER_ALL_ASSIGNMENTS_F' THEN
              l_process  := 'PROCESS_ASSIGNMENT_CHANGES' ;

        ELSIF p_table_name = 'PER_ORG_STRUCTURE_ELEMENTS' THEN

              l_process  := 'PROCESS_ORG_STRUCT_UPD';


        ELSIF p_table_name = 'PER_JOB_EXTRA_INFO' THEN

              l_process  := 'PROCESS_JOB_BILL_UPD' ;

        ELSIF p_table_name = 'PER_ALL_PEOPLE_F' THEN

              l_process  := 'PROCESS_FULL_NAME_UPD';

        ELSIF p_table_name = 'HR_ORGANIZATION_INFORMATION' THEN

              l_process  := 'PROCESS_ORG_INFO_UPD' ;

        ELSIF p_table_name = 'PER_VALID_GRADES' THEN

              l_process  := 'PROCESS_VALID_GRADE_UPD';

        ELSIF p_table_name = 'PER_GRADES' THEN

              l_process  := 'PROCESS_GRADE_UPD' ;

        ELSIF p_table_name = 'PER_ADDRESSES' THEN

              l_process  := 'PROCESS_ADDRESS_UPD' ;

        ELSIF p_table_name = 'PA_ALL_ORGANIZATIONS' THEN

              l_process  := 'PROCESS_PA_ALL_ORG_UPD' ;

        ELSIF p_table_name = 'PA_JOB_RELATIONSHIPS' THEN

              l_process  := 'PROCESS_JOB_REL_UPD' ;

        END IF ;

        --
        -- Create the appropriate process
        --

        wf_engine.CreateProcess( ItemType => ItemType,
                                 ItemKey  => ItemKey,
                                 process  => l_process );

        --
        -- Initialize workflow item attributes with the parameter values
        --

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                            itemkey          => itemkey,
                                            aname                 => 'PROJECT_RESOURCE_ADMINISTRATOR',
                                            avalue                => 'PASYSADMIN');

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'CALLING_MODE',
                                              avalue                => p_calling_mode);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_STRUCTURE_ELEMENT_ID',
                                              avalue                => p_org_struct_element_id);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORGANIZATION_ID_PARENT',
                                              avalue                => p_organization_id_parent);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORGANIZATION_ID_CHILD',
                                              avalue                => p_organization_id_child);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_STRUCTURE_VERSION_ID',
                                              avalue                => p_org_structure_version_id);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'PERSON_ID',
                                              avalue                => p_person_id);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'START_DATE_OLD',
                                              avalue                => p_start_date_old);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'START_DATE_NEW',
                                              avalue                => p_start_date_new);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'END_DATE_OLD',
                                              avalue                => p_end_date_old);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'END_DATE_NEW',
                                              avalue                => p_end_date_new);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_ID_OLD',
                                              avalue                => p_org_id_old);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_ID_NEW',
                                              avalue                => p_org_id_new);

        -- Bug 4575004 - removed the setting of attribute SEQUENCE_NEW and
        -- SEQUENCE_OLD since those attributes are not used and have been
        -- removed from the workflow.

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JOB_ID_OLD',
                                              avalue                => p_job_id_old);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JOB_ID_NEW',
                                              avalue                => p_job_id_new);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'FROM_JOB_GROUP_ID',
                                              avalue                => p_from_job_group_id);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'TO_JOB_GROUP_ID',
                                              avalue                => p_to_job_group_id);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'SUPERVISOR_OLD',
                                              avalue                => p_supervisor_old);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'SUPERVISOR_NEW',
                                              avalue                => p_supervisor_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'PRIMARY_FLAG_OLD',
                                              avalue                => p_primary_flag_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'PRIMARY_FLAG_NEW',
                                              avalue                => p_primary_flag_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_INFO1_OLD',
                                              avalue                => p_org_info1_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_INFO1_NEW',
                                              avalue                => p_org_info1_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION2_OLD',
                                              avalue                => p_jei_information2_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION2_NEW',
                                              avalue                => p_jei_information2_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION3_OLD',
                                              avalue                => p_jei_information3_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION3_NEW',
                                              avalue                => p_jei_information3_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION4_OLD',
                                              avalue                => p_jei_information4_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION4_NEW',
                                              avalue                => p_jei_information4_new);
        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION6_OLD',
                                              avalue                => p_jei_information6_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JEI_INFORMATION6_NEW',
                                              avalue                => p_jei_information6_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'FULL_NAME_OLD',
                                              avalue                => p_full_name_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'FULL_NAME_NEW',
                                              avalue                => p_full_name_new);

        -- Bug 4575004 - removed the setting of attribute GRADE_ID_OLD and
        -- GRADE_ID_NEW since those attributes are not used and have been
        -- removed from the workflow.

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'COUNTRY_OLD',
                                              avalue                => p_country_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'COUNTRY_NEW',
                                              avalue                => p_country_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'CITY_OLD',
                                              avalue                => p_city_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'CITY_NEW',
                                              avalue                => p_city_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'REGION2_OLD',
                                              avalue                => p_region2_old);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'REGION2_NEW',
                                              avalue                => p_region2_new);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'INACTIVE_DATE_OLD',
                                              avalue                => p_inactive_date_old);

        wf_engine.SetItemAttrDate (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'INACTIVE_DATE_NEW',
                                              avalue                => p_inactive_date_new);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'FROM_JOB_ID_OLD',
                                              avalue                => p_from_job_id_old);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'FROM_JOB_ID_NEW',
                                              avalue                => p_from_job_id_new);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'TO_JOB_ID_OLD',
                                              avalue                => p_to_job_id_old);

        wf_engine.SetItemAttrNumber (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'TO_JOB_ID_NEW',
                                              avalue                => p_to_job_id_new);

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORG_INFO_CONTEXT',
                                              avalue                => p_org_info_context);


        wf_engine.StartProcess(         itemtype        => itemtype,
                                              itemkey                => itemkey );


        -- Insert to PA tables wf process information.
        -- This is required for displaying notifications on PA pages.

        BEGIN

           PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'HR_CHANGE_MGMT'
                ,p_item_type           => itemtype
                ,p_item_key            => itemkey
                ,p_entity_key1         => to_char(p_person_id)
                ,p_entity_key2         => to_char(p_person_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

        EXCEPTION
           WHEN OTHERS THEN
                null;
        END;

        --
        wf_engine.threshold := l_save_thresh ;
exception
 when others then
       null;

END update_project_entities;

PROCEDURE org_struct_element_change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_org_struct_element_id          NUMBER;
l_organization_id_child          NUMBER;
l_organization_id_parent         NUMBER;
l_org_structure_version_id       NUMBER;

l_msg_count                NUMBER;
l_msg_data                VARCHAR(2000);
l_return_status                VARCHAR2(1);
l_api_version_number        NUMBER                := 1.0;
l_data                        VARCHAR2(2000);
l_msg_index_out                NUMBER;

v_err_code              NUMBER;
v_err_stage             VARCHAR2(300);
v_err_stack             VARCHAR2(2000);
l_savepoint             BOOLEAN;

--
--
begin


        --
        -- Get the workflow attribute values
        --

        l_org_struct_element_id  := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'ORG_STRUCTURE_ELEMENT_ID' );

        l_organization_id_parent := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'ORGANIZATION_ID_PARENT' );

        l_organization_id_child := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'ORGANIZATION_ID_CHILD' );

        l_org_structure_version_id := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'ORG_STRUCTURE_VERSION_ID' );

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORGANIZATION_NAME',
                                              avalue                => pa_hr_update_api.get_org_name(l_organization_id_child));

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'CHILD_ORGANIZATION_NAME',
                                              avalue                => pa_hr_update_api.get_org_name(l_organization_id_parent));

        --
        -- Call the api to populate the hierarchy denorm table
        --
        SAVEPOINT l_org_struct_element_change ;
        l_savepoint := true;
        pa_org_utils.populate_hierarchy_denorm(p_org_version_id         => l_org_structure_version_id,
                                               p_organization_id_child  => l_organization_id_child,
                                               p_organization_id_parent => l_organization_id_parent,
                                               x_err_code               => v_err_code,
                                               x_err_stage              => v_err_stage,
                                               x_err_stack              => v_err_stack);

         IF nvl(v_err_code, 0) = 0  THEN

            resultout := wf_engine.eng_completed||':'||'S';
         ELSE

            --
            -- Set any error messages
            --
            l_savepoint := false;
            rollback to l_org_struct_element_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

         END IF;

        --
EXCEPTION
/*
    WHEN FND_API.G_EXC_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
           if (l_savepoint) then
               rollback to l_org_struct_element_change ;
           End if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                 rollback to l_org_struct_element_change ;
            End if;

*/
    WHEN OTHERS THEN
            wf_core.context('pa_forecast_test',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                   rollback to l_org_struct_element_change ;
           End if;
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

END org_struct_element_change;



PROCEDURE Job_Bill_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

l_job_id                  NUMBER;
l_jei_information2_old    VARCHAR2(150);
l_jei_information2_new    VARCHAR2(150);
l_jei_information3_old    VARCHAR2(150);
l_jei_information3_new    VARCHAR2(150);
l_jei_information4_old    VARCHAR2(150);
l_jei_information4_new    VARCHAR2(150);
l_jei_information6_old    VARCHAR2(150);
l_jei_information6_new    VARCHAR2(150);
l_calling_mode            VARCHAR2(10);

l_msg_count               NUMBER;
l_msg_data                VARCHAR(2000);
l_return_status           VARCHAR2(1);
l_api_version_number      NUMBER                := 1.0;
l_data                    VARCHAR2(2000);
l_msg_index_out           NUMBER;
l_savepoint               BOOLEAN;

begin
        --
        -- Get the workflow attribute values
        --
        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );
        l_job_id             := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'JOB_ID_NEW' );
        l_jei_information2_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'JEI_INFORMATION2_OLD' );
        l_jei_information2_new := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                           itemkey         => itemkey,
                                                           aname           => 'JEI_INFORMATION2_NEW' );
        l_jei_information3_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                           itemkey         => itemkey,
                                                           aname           => 'JEI_INFORMATION3_OLD' );
        l_jei_information3_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                          itemkey         => itemkey,
                                                          aname           => 'JEI_INFORMATION3_NEW' );
        l_jei_information4_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                           itemkey         => itemkey,
                                                           aname           => 'JEI_INFORMATION4_OLD' );
        l_jei_information4_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                          itemkey         => itemkey,
                                                          aname           => 'JEI_INFORMATION4_NEW' );
        l_jei_information6_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                           itemkey         => itemkey,
                                                           aname           => 'JEI_INFORMATION6_OLD' );
        l_jei_information6_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                          itemkey         => itemkey,
                                                          aname           => 'JEI_INFORMATION6_NEW' );

        wf_engine.SetItemAttrText (  itemtype        => itemtype,
                                     itemkey          => itemkey,
                                     aname                 => 'JOB_NAME',
                                     avalue                => pa_hr_update_api.get_job_name(l_job_id));

       log_message('before calling per_job_extra_billability');
       --
       -- Call api to process job billability
       --
       SAVEPOINT l_job_billability_change ;
       l_savepoint := true;
       pa_hr_update_api.per_job_extra_billability
                      (p_calling_mode           =>l_calling_mode
                      ,P_job_id                 =>l_job_id
                      ,P_billable_flag_new      =>l_jei_information2_new
                      ,P_billable_flag_old      =>l_jei_information2_old
                      ,P_utilize_flag_new       =>l_jei_information3_new
                      ,P_utilize_flag_old       =>l_jei_information3_old
                      ,P_job_level_new          =>l_jei_information4_new
                      ,P_job_level_old          =>l_jei_information4_old
                      ,p_schedulable_flag_new   =>l_jei_information6_new
                      ,p_schedulable_flag_old   =>l_jei_information6_old
                      ,x_return_status          =>l_return_status
                      ,x_msg_data               =>l_msg_data
                      ,x_msg_count              =>l_msg_count );

       log_message('after calling per_job_extra_billability, l_return_status: '
                                  ||l_return_status);
         IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
         ELSIF l_return_status = 'E' THEN
            --
            -- Set any error messages
            --
            l_savepoint  := false;
            rollback to l_job_billability_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

         ELSE
            --
            -- Set any error messages
            --
            l_savepoint  := false;
            rollback to l_job_billability_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

         END IF;
        log_message('l_return_status: '||l_return_status);

        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
               rollback to l_job_billability_change ;
            End if;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                rollback to l_job_billability_change ;
            End if;
            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
            log_message('Execption OTHERS, '||SQLERRM ||', '|| SQLCODE);
            wf_core.context('pa_forecast_test',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                 log_message('before rollback to l_job_billability_change');
                 rollback to l_job_billability_change ;
                 log_message('after rollback to l_job_billability_change');
            End if;
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then
            log_message('l_msg_data is NULL');
            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
            log_message('l_msg_data is not NULL');
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';
            log_message('resultout: '||resultout);
        --RAISE;

END Job_Bill_Change;

PROCEDURE Full_Name_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_person_id                      NUMBER;
l_person_name                    VARCHAR2(240);
l_full_name_old                  VARCHAR2(240);
l_full_name_new                  VARCHAR2(240);

l_msg_count                NUMBER;
l_msg_data                VARCHAR(2000);
l_return_status                VARCHAR2(1);
l_api_version_number        NUMBER                := 1.0;
l_data                        VARCHAR2(2000);
l_msg_index_out                NUMBER;
l_savepoint             Boolean;
v_err_code              NUMBER;
v_err_stage             VARCHAR2(300);
v_err_stack             VARCHAR2(2000);

--
--
begin

        --
        -- Get the workflow attribute values
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

        l_person_id     := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'PERSON_ID' );

        l_full_name_old := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                   aname    => 'FULL_NAME_OLD');

        l_full_name_new := wf_engine.GetItemAttrText(itemtype => itemtype,
                                           itemkey         => itemkey,
                                           aname           => 'FULL_NAME_NEW');

        -- Removing the setting of the FULL_NAME_NEW attribute - no need

        --
        -- Call the api to update full name
        --

        SAVEPOINT l_full_name_change ;
        l_savepoint := true;
        PA_HR_UPDATE_API.update_name ( p_person_id          => l_person_id
                                      ,p_old_name           => l_full_name_old
                                      ,p_new_name           => l_full_name_new
                                      ,x_return_status      => l_return_status
                                      ,x_msg_count          => l_msg_count
                                      ,x_msg_data           => l_msg_data);

        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSIF l_return_status = 'E' THEN
            --
            -- Set any error messages
            --
            l_savepoint  := false;
            rollback to l_full_name_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

        ELSE
            l_savepoint  := false;
            rollback to l_full_name_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

        END IF;


        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_entities',
                            'Full_Name_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                  rollback to l_full_name_change ;
            End if;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            wf_core.context('pa_hr_update_pa_entities',
                            'Full_Name_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                 rollback to l_full_name_change ;
            End if;
            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
            wf_core.context('pa_hr_update_pa_entities',
                            'Full_Name_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            If (l_savepoint) then
                    rollback to l_full_name_change ;
            End if;
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';

END Full_Name_Change;

PROCEDURE Default_OU_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_org_id                         NUMBER;
l_org_info1_old                  VARCHAR2(150);
l_org_info1_new                  VARCHAR2(150);
l_org_info_context               VARCHAR2(40);

l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

l_return_status                  VARCHAR2(1);
l_error_message_code             VARCHAR2(1000);
v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);
l_savepoint                         Boolean;
--
--
begin


--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

        l_org_id        := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'ORG_ID_NEW' );

        l_org_info1_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'ORG_INFO1_OLD' );

        l_org_info1_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'ORG_INFO1_NEW' );

        l_org_info_context := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'ORG_INFO_CONTEXT' );

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'ORGANIZATION_NAME',
                                        avalue                => pa_hr_update_api.get_org_name(l_org_id));

        SAVEPOINT l_ou_change ;
        l_savepoint := true;

        IF l_org_info_context = 'Exp Organization Defaults' THEN

              pa_hr_update_api.default_ou_change
                                     ( p_calling_mode          => l_calling_mode,
                                       p_organization_id       => l_org_id,
                                       p_default_ou_new        => l_org_info1_new,
                                       p_default_ou_old        => l_org_info1_old,
                                       x_return_status         => l_return_status,
                                       x_msg_count             => l_msg_count,
                                       x_msg_data              => l_msg_data
                                      ) ;

        ELSIF l_org_info_context = 'Project Resource Job Group' THEN

              pa_hr_update_api.proj_res_job_group_change
                                     ( p_calling_mode          => l_calling_mode,
                                       p_organization_id       => l_org_id,
                                       p_proj_job_group_new    => l_org_info1_new,
                                       p_proj_job_group_old    => l_org_info1_old,
                                       x_return_status         => l_return_status,
                                       x_msg_count             => l_msg_count,
                                       x_msg_data              => l_msg_data
                                      ) ;

        END IF;

         IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
         ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_ou_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

         ELSE
            l_savepoint  := false;
            rollback to l_ou_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

         END IF;

        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_ou_change ;
           End if;
--          wf_core.context('pa_hr_update_pa_entities',
--                          'Full_Name_Change',
--                           itemtype,
--                           itemkey,
--                           to_char(actid),
--                           funcmode);
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

            resultout := wf_engine.eng_completed||':'||'F';
--        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN

           If (l_savepoint) then
            rollback to l_ou_change ;
           End if;
--          wf_core.context('pa_hr_update_pa_entities',
--                          'Full_Name_Change',
--                           itemtype,
--                           itemkey,
--                           to_char(actid),
--                           funcmode);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );



            resultout := wf_engine.eng_completed||':'||'F';
            --RAISE ;
*/
    WHEN OTHERS THEN
          If (l_savepoint) then
            rollback to l_ou_change ;
          End if;
--          wf_core.context('pa_hr_update_pa_entities',
--                          'Full_Name_Change',
--                           itemtype,
--                           itemkey,
--                           to_char(actid),
--                           funcmode);
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';
--          RAISE ;

END Default_OU_Change;

-- This procedure will not get called anymore because the triggers
-- on per_valid_grades and per_grades have been removed
PROCEDURE Valid_Grade_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_org_id                         NUMBER;
l_org_info1_old                  VARCHAR2(150);
l_org_info1_new                  VARCHAR2(150);
l_org_info_context               VARCHAR2(40);
l_grade_id_old                   NUMBER;
l_grade_id_new                   NUMBER;
l_job_id_old                     NUMBER;
l_job_id_new                     NUMBER;
l_from_job_id_old                NUMBER;
l_from_job_id_new                NUMBER;
l_to_job_id_old                  NUMBER;
l_to_job_id_new                  NUMBER;
l_from_job_group_id              NUMBER;
l_to_job_group_id                NUMBER;


l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_return_status                         VARCHAR2(1);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);
l_savepoint                      Boolean;
--
--
begin


--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

/*
        l_grade_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'GRADE_ID_OLD' );

        l_grade_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'GRADE_ID_NEW' );

*/
        l_job_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'JOB_ID_OLD' );

        l_job_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'JOB_ID_NEW' );

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JOB_NAME',
                                              avalue                => pa_hr_update_api.get_job_name(l_job_id_new));

/*
        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'GRADE_NAME',
                                              avalue                => pa_hr_update_api.get_grade_name(l_grade_id_new));
*/

        SAVEPOINT l_valid_grade_change ;
        l_savepoint := true;
        PA_HR_UPDATE_API.update_job_levels( P_calling_mode              => l_calling_mode
                                           ,P_per_valid_grade_job_id    => l_job_id_New
                                           ,P_per_valid_grade_id_old    => l_grade_id_old
                                           ,P_per_valid_grade_id_new    => l_grade_id_New
                                           ,x_return_status             => l_return_status
                                           ,x_msg_count                 => l_msg_count
                                           ,x_msg_data                  => l_msg_data);


        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_valid_grade_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

        ELSE
            l_savepoint  := false;
            rollback to l_valid_grade_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

        END IF;


        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_valid_grade_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Valid_Grade_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_valid_grade_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Valid_Grade_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLERRM
                               );
            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
            If (l_savepoint) then
             rollback to l_valid_grade_change ;
            End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Valid_Grade_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';

END Valid_Grade_Change;

-- This procedure will not get called anymore because the triggers
-- on per_valid_grades and per_grades have been removed
PROCEDURE Job_Level_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_grade_id                       NUMBER;
l_job_level_old                  NUMBER;
l_job_level_new                  NUMBER;
l_org_info_context               VARCHAR2(40);

l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_return_status                         VARCHAR2(1);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);
l_savepoint                      Boolean;
--
--
begin



--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

/*
        l_grade_id := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'GRADE_ID_NEW' );

        l_job_level_old := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'SEQUENCE_OLD' );

        l_job_level_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'SEQUENCE_NEW' );

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'GRADE_NAME',
                                              avalue                => pa_hr_update_api.get_grade_name(l_grade_id));
*/

        SAVEPOINT l_job_level_change ;
        l_savepoint  := true;
        PA_HR_UPDATE_API.update_job_levels( P_calling_mode               => l_calling_mode
                                           ,P_per_grades_grade_id        => l_grade_id
                                           ,P_per_grades_sequence_old    => l_job_level_old
                                           ,P_per_grades_sequence_new    => l_job_level_new
                                           ,x_return_status              => l_return_status
                                           ,x_msg_count                  => l_msg_count
                                           ,x_msg_data                   => l_msg_data);

        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_job_level_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

        ELSE
            l_savepoint  := false;
            rollback to l_job_level_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

        END IF;


EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_job_level_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Job_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

            resultout := wf_engine.eng_completed||':'||'F';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
        If (l_savepoint) then
          rollback to l_job_level_change ;
        End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Job_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
           If (l_savepoint) then
             rollback to l_job_level_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Job_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';

END Job_Level_Change;

PROCEDURE Address_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_person_id                      NUMBER;
l_person_name                    VARCHAR2(240);
l_country_old                    VARCHAR2(60);
l_country_new                    VARCHAR2(60);
l_city_old                       VARCHAR2(30);
l_city_new                       VARCHAR2(30);
l_region2_old                    VARCHAR2(70);
l_region2_new                    VARCHAR2(70);
l_date_from_old                  DATE;
l_date_from_new                  DATE;
l_date_to_old                    DATE;
l_date_to_new                    DATE;
l_addr_prim_flag_old             VARCHAR2(20);
l_addr_prim_flag_new             VARCHAR2(20);
l_org_info_context               VARCHAR2(40);

l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_return_status                         VARCHAR2(1);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);
l_savepoint                      Boolean;
--
--
begin

--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

        l_person_id     := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'PERSON_ID' );

        l_country_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'COUNTRY_OLD' );

        l_country_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'COUNTRY_NEW' );

        l_city_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'CITY_OLD' );

        l_city_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'CITY_NEW' );

        l_region2_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'REGION2_OLD' );

        l_region2_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'REGION2_NEW' );

        l_date_from_old := wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'START_DATE_OLD');

        l_date_from_new :=  wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'START_DATE_NEW');

        l_date_to_old :=  wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'END_DATE_OLD');

        l_date_to_new :=  wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'END_DATE_NEW');

        l_addr_prim_flag_old := wf_engine.GetItemAttrText(itemtype   => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'PRIMARY_FLAG_OLD');

        l_addr_prim_flag_new :=  wf_engine.GetItemAttrText(itemtype  => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'PRIMARY_FLAG_NEW');

        -- Changed for bug 4354854 - performance improvement
        pa_resource_utils.get_person_name(p_person_id     => l_person_id,
                                          x_person_name   => l_person_name,
                                          x_return_status => l_return_status);

        IF l_return_status = 'E' THEN
            --
            l_savepoint  := false;
            rollback to l_address_change ;
            resultout := wf_engine.eng_completed||':'||'F';
        END IF;

         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'FULL_NAME_NEW',
                                   avalue   => l_person_name);


        SAVEPOINT l_address_change ;
        l_savepoint := true;

        --dbms_output.put_line('Calling address Update');
        pa_hr_update_api.address_change(  p_calling_mode           => l_calling_mode
                                        , p_person_id              => l_person_id
                                        , p_country_old            => l_country_old
                                        , p_country_new            => l_country_new
                                        , p_city_old               => l_city_old
                                        , p_city_new               => l_city_new
                                        , p_region2_old            => l_region2_old
                                        , p_region2_new            => l_region2_new
                                        , p_date_from_old          => l_date_from_old
                                        , p_date_from_new          => l_date_from_new
                                        , p_date_to_old            => l_date_to_old
                                        , p_date_to_new            => l_date_to_new
                                        , p_addr_prim_flag_old     => l_addr_prim_flag_old
                                        , p_addr_prim_flag_new     => l_addr_prim_flag_new
                                        , x_return_status          => l_return_status
                                        , x_msg_count              => l_msg_count
                                        , x_msg_data               => l_msg_data);

         IF l_return_status = 'S'  THEN

            --dbms_output.put_line('Address Update Success');

            resultout := wf_engine.eng_completed||':'||'S';
         ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_address_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

         ELSE
            l_savepoint  := false;
            rollback to l_address_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

         END IF;



EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
         If (l_savepoint) then
              rollback to l_address_change ;
         end if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);


            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

            resultout := wf_engine.eng_completed||':'||'F';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
          If (l_savepoint) then
           rollback to l_address_change ;
         End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
           If (l_savepoint) then
             rollback to l_address_change ;
               null;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';

END Address_Change;

PROCEDURE Project_Organization_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);
l_org_id                         NUMBER;
l_org_info1_old                  VARCHAR2(150);
l_org_info1_new                  VARCHAR2(150);
l_org_info_context               VARCHAR2(40);

l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_return_status                         VARCHAR2(1);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);

l_inactive_date_old              DATE;
l_inactive_date_new              DATE;
l_savepoint                      Boolean;
--
--

--rmunjulu bug 6815563
l_org_res_exists varchar2(3) := 'N';

--rmunjulu bug 6815563
cursor chk_org_res_exists_csr (l_org_id in NUMBER) is
select 'Y'
into l_org_res_exists
from dual
where exists (SELECT 'Y'
FROM   pa_resources_denorm
WHERE  resource_organization_id = l_org_id
and sysdate between resource_effective_start_date and
resource_effective_end_date
AND    rownum = 1
UNION ALL
SELECT 'Y'
FROM   pa_resources_denorm
WHERE  resource_organization_id = l_org_id
and resource_effective_start_date > sysdate
AND    rownum = 1);

begin


--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );



        l_org_id        := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'ORG_ID_NEW' );

        l_org_info1_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'ORG_INFO1_NEW' );

        l_inactive_date_old     := wf_engine.GetItemAttrDate( itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'INACTIVE_DATE_OLD' );

        l_inactive_date_new := wf_engine.GetItemAttrDate( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'INACTIVE_DATE_NEW' );

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey       => itemkey,
                                                aname       => 'ORGANIZATION_NAME',
                                              avalue        => pa_hr_update_api.get_org_name(l_org_id));


        IF l_calling_mode = 'UPDATE' THEN

        --dbms_output.put_line('Calling Mode is Update');

           SAVEPOINT l_project_org_change ;
           l_savepoint  := true;

           --The following code checks to see if the organization of the resource belongs
           --to some other expenditure hierarchy. The resource must be end_dated / inactivated
           --only if he does not belong to any expenditure hierarchy

           if(pa_hr_update_api.belongs_ExpOrg(l_org_id) = 'N') then
                 -- dbms_output.put_line('Making resources inactive');

                --rmunjulu bug 6815563 -- check if active org resource exists
                OPEN  chk_org_res_exists_csr(l_org_id);
                FETCH chk_org_res_exists_csr INTO l_org_res_exists;
                CLOSE chk_org_res_exists_csr;

                --rmunjulu bug 6815563 -- make resource inactive only if org resource exists
                IF nvl(l_org_res_exists,'N') = 'Y' THEN
                  PA_HR_UPDATE_API.make_resource_inactive( p_calling_mode       => l_calling_mode
                                                          ,P_Organization_id    => l_org_id
                                                          ,P_Default_OU         => l_org_info1_new
                                                          ,P_inactive_date      => l_inactive_date_new
                                                          ,x_return_status      => l_return_status
                                                          ,x_msg_count          => l_msg_count
                                                          ,x_msg_data           => l_msg_data);
                ELSE
                  l_return_status := 'S'; -- Bug : 8783780
                END IF; -- rmunjulu bug 6815563
           else

            IF (PA_HR_UPDATE_API.check_pjr_default_ou(l_org_id,l_org_info1_new) = 'Y') THEN /*Added for bug 8568641 */
                 --dbms_output.put_line('Pulling resources');
                 PA_HR_UPDATE_API.pull_resources( P_Organization_id    => l_org_id
                                                 ,x_return_status      => l_return_status
                                                 ,x_msg_count          => l_msg_count
                                                 ,x_msg_data           => l_msg_data);
             ELSE
                  l_return_status := 'S'; -- Bug : 8783780
             END IF;
           end if;

        ELSIF l_calling_mode = 'INSERT' THEN
                --dbms_output.put_line('Calling mode is Insert');

           SAVEPOINT l_project_org_change ;
           l_savepoint := true;
           pa_hr_update_api.default_ou_change( p_calling_mode          => l_calling_mode,
                                               p_organization_id       => l_org_id,
                                               p_default_ou_new        => l_org_info1_new,
                                               p_default_ou_old        => l_org_info1_old,
                                               x_return_status         => l_return_status,
                                               x_msg_count             => l_msg_count,
                                               x_msg_data              => l_msg_data
                                              ) ;
        END IF;


        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_project_org_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

        ELSE
            l_savepoint  := false;
            rollback to l_project_org_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

        END IF;

        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_project_org_change ;
          end if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

             set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                   p_item_key     =>  itemkey,
                                   p_msg_count    =>  l_msg_count,
                                   p_msg_data     =>  l_msg_data);

            resultout := wf_engine.eng_completed||':'||'F';
        --RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_project_org_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Project_Organization_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
        --RAISE;
*/
    WHEN OTHERS THEN

           If (l_savepoint) then
            rollback to l_project_org_change ;
           End if;

            wf_core.context('pa_hr_update_pa_entities',
                            'Project_Organization_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';
        --RAISE;

END Project_Organization_Change;

PROCEDURE Job_Rel_Change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS



l_calling_mode                   VARCHAR2(10);

l_msg_count                         NUMBER;
l_msg_data                         VARCHAR(2000);
l_return_status                         VARCHAR2(1);
l_api_version_number                 NUMBER                := 1.0;
l_data                                 VARCHAR2(2000);
l_msg_index_out                         NUMBER;

v_err_code                       NUMBER;
v_err_stage                      VARCHAR2(300);
v_err_stack                      VARCHAR2(2000);

l_from_job_id_old                NUMBER;
l_from_job_id_new                NUMBER;
l_to_job_id_old                  NUMBER;
l_to_job_id_new                  NUMBER;
l_from_job_group_id              NUMBER;
l_to_job_group_id                NUMBER;
l_savepoint                      Boolean;
--
--
begin


--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_calling_mode       := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                             itemkey         => itemkey,
                                                             aname           => 'CALLING_MODE' );

        l_from_job_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'FROM_JOB_ID_OLD' );

        l_from_job_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'FROM_JOB_ID_NEW' );

        l_to_job_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'TO_JOB_ID_OLD' );

        l_to_job_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                     aname           => 'TO_JOB_ID_NEW' );

        l_from_job_group_id := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                      itemkey         => itemkey,
                                                      aname           => 'FROM_JOB_GROUP_ID' );

        l_to_job_group_id := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                     itemkey         => itemkey,
                                                      aname           => 'TO_JOB_GROUP_ID' );


        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                              itemkey          => itemkey,
                                                aname                 => 'JOB_NAME',
                                              avalue                => pa_hr_update_api.get_job_name(l_from_job_id_new));

        wf_engine.SetItemAttrText (         itemtype        => itemtype,
                                            itemkey          => itemkey,
                                            aname                 => 'TO_JOB_NAME',
                                            avalue                => pa_hr_update_api.get_job_name(l_to_job_id_new));

        SAVEPOINT l_job_rel_change ;
        l_savepoint := true;
        PA_HR_UPDATE_API.update_job_levels( P_calling_mode       => l_calling_mode
                                           ,P_from_job_id_old    => l_from_job_id_old
                                           ,P_from_job_id_new    => l_from_job_id_new
                                           ,P_to_job_id_old      => l_to_job_id_old
                                           ,P_to_job_id_new      => l_to_job_id_new
                                           ,P_from_job_group_id  => l_from_job_group_id
                                           ,P_to_job_group_id    => l_to_job_group_id
                                           ,x_return_status      => l_return_status
                                           ,x_msg_count          => l_msg_count
                                           ,x_msg_data           => l_msg_data);


        IF l_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
        ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_job_rel_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

        ELSE
            l_savepoint  := false;
            rollback to l_job_rel_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

        END IF;

        --
EXCEPTION
/*    WHEN FND_API.G_EXC_ERROR
        THEN
           If (l_savepoint) then
            rollback to l_job_rel_change ;
           End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

       set_nf_error_msg_attr(p_item_type    =>  itemtype,
                             p_item_key     =>  itemkey,
                             p_msg_count    =>  l_msg_count,
                             p_msg_data     =>  l_msg_data);

            resultout := wf_engine.eng_completed||':'||'F';

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
            If (l_savepoint) then
                rollback to l_job_rel_change ;
            End if;
            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

                   wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );

            resultout := wf_engine.eng_completed||':'||'F';
*/
    WHEN OTHERS THEN
            If (l_savepoint) then
                rollback to l_job_rel_change ;
            End if;

            wf_core.context('pa_hr_update_pa_entities',
                            'Address_Change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

            resultout := wf_engine.eng_completed||':'||'F';

END Job_Rel_Change;

PROCEDURE assignment_change
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS


l_calling_mode          VARCHAR2(10);
l_person_id             NUMBER;
l_person_name           VARCHAR2(240);
l_start_date_old        DATE;
l_start_date_new        DATE;
l_end_date_old          DATE;
l_end_date_new          DATE;
l_org_id_old            NUMBER;
l_org_id_new            NUMBER;
l_job_id_old            NUMBER;
l_job_id_new            NUMBER;
l_supervisor_old        NUMBER;
l_supervisor_new        NUMBER;
l_primary_flag_old      VARCHAR2(1);
l_primary_flag_new      VARCHAR2(1);
l_resource_id           NUMBER;
l_res_asgn_exists       VARCHAR2(1);

l_res_id  PA_RESOURCES.RESOURCE_ID%TYPE ; -- for bug 5683340
l_invol_term VARCHAR2(1) ; -- for bug 5683340

  v_return_status varchar2(2000);
  v_msg_count number;
  v_resource_id number;
  v_msg_data  varchar2(300);
  v_error_message_code varchar2(2000);
l_msg_count                NUMBER;
l_message_counter       NUMBER := 0 ;
l_msg_data                VARCHAR(2000);
l_message_data          VARCHAR(2000);
l_return_status                VARCHAR2(1);
l_final_return_status        VARCHAR2(1) := 'S';
l_api_version_number        NUMBER                := 1.0;
l_data                        VARCHAR2(2000);
l_msg_index_out                NUMBER;
l_savepoint             Boolean;
--
--
--Bug 9762784 Start
CURSOR chk_asgn (l_person_id NUMBER, l_start_date_new DATE) IS
select 'Y'
from per_all_assignments_f asgn,
     per_assignment_status_types status
where   asgn.person_id = l_person_id
  and   trunc(l_start_date_new) between trunc(asgn.effective_start_date) and trunc(asgn.effective_end_date)
  and   asgn.assignment_type in ('E', 'C')
  and   asgn.primary_flag ='Y'
  and   asgn.assignment_status_type_id  = status.assignment_status_type_id
  and   status.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK');

l_chk_asgn        VARCHAR2(1);
--Bug 9762784 End

begin


--get the unique identifier for this specific workflow
        --
        -- Initialize workflow item attributes
        --

        l_final_return_status := FND_API.G_RET_STS_SUCCESS ;

        l_calling_mode := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'CALLING_MODE' );

        l_person_id  := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'PERSON_ID' );
        l_start_date_old := wf_engine.GetItemAttrDate( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'START_DATE_OLD' );
        l_start_date_new := wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'START_DATE_NEW' );
        l_end_date_old := wf_engine.GetItemAttrDate( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'END_DATE_OLD' );
        l_end_date_new := wf_engine.GetItemAttrDate(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'END_DATE_NEW' );
        l_org_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'ORG_ID_OLD' );
        l_org_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'ORG_ID_NEW' );
        l_job_id_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'JOB_ID_OLD' );
        l_job_id_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'JOB_ID_NEW' );
        l_supervisor_old := wf_engine.GetItemAttrNumber( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'SUPERVISOR_OLD' );
        l_supervisor_new := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'SUPERVISOR_NEW' );
        l_primary_flag_old := wf_engine.GetItemAttrText( itemtype        => itemtype,
                                                         itemkey         => itemkey,
                                                         aname           => 'PRIMARY_FLAG_OLD' );
        l_primary_flag_new := wf_engine.GetItemAttrText(itemtype        => itemtype,
                                                        itemkey         => itemkey,
                                                        aname           => 'PRIMARY_FLAG_NEW' );


        -- Changed for bug 4354854 - performance improvement
        pa_resource_utils.get_person_name(p_person_id     => l_person_id,
                                          x_person_name   => l_person_name,
                                          x_return_status => l_return_status);

        IF l_return_status = 'E' THEN
            --
            l_savepoint  := false;
            rollback to l_address_change ;
            resultout := wf_engine.eng_completed||':'||'F';
        END IF;

        wf_engine.SetItemAttrText (itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'FULL_NAME_NEW',
                                   avalue    => l_person_name);

	--Start of addition for bug 3957522
	if l_calling_mode = 'DELETE'  then
		pa_hr_update_api.Delete_PA_Resource_Denorm (
                             p_person_id          => l_person_id
                            ,p_old_start_date     => l_start_date_old
                            ,p_old_end_date       => l_end_date_old
                            ,x_return_status      => l_return_status
                            ,x_msg_count          => l_msg_count
                            ,x_msg_data           => l_msg_data);


                 /*Call added for bug 5683340*/
                 pa_resource_utils.init_fte_sync_wf( p_person_id => l_person_id,
                                                     x_invol_term => l_invol_term,
                                                     x_return_status => l_return_status,
                                                     x_msg_data => l_msg_data ,
                                                     x_msg_count => l_msg_count
                                                     );

                 l_message_counter := l_message_counter + nvl(l_msg_count,0);
                 IF  l_return_status =  'U' THEN
                     app_exception.raise_exception;
                 ELSIF l_return_status = 'E' THEN
                     l_final_return_status := l_return_status;
                 END IF;

                /*IF - ELSIF block  added for bug 5683340*/
                IF ((l_invol_term = 'N') AND (l_return_status = 'S')) THEN

		   l_res_id := pa_resource_utils.get_resource_id(l_person_id);

                   PA_TIMELINE_PVT.Create_Timeline (
                            p_start_resource_name    => NULL,
                            p_end_resource_name      => NULL,
                            p_resource_id            => l_res_id,
                            p_start_date             => NULL,
                            p_end_date               => NULL,
                            x_return_status          => l_return_status,
                            x_msg_count              => l_msg_count,
                            x_msg_data               => l_msg_data);

                  l_message_counter := l_message_counter + nvl(l_msg_count,0);
                  if  l_return_status =  'U' then

                          app_exception.raise_exception;

                  elsif  l_return_status = 'E' then

                           l_final_return_status := l_return_status;
                  end if;

                END IF ; --IF ((l_invol_term = 'N') AND (l_return_status = 'S')) bug 5683340

       -- End of addition for bug 3957522.
       elsif  l_calling_mode = 'INSERT'  then

            if ( l_primary_flag_new = 'Y' and pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y') then
              -- Added new if condition for Bug 7423251
              IF (pa_hr_update_api.check_job_utilization (p_job_id     => l_job_id_new
                                                         ,p_person_id  => null
                                                         ,p_date       => null)) = 'Y'  then

                --Bug 9762784 Start
                OPEN chk_asgn(l_person_id, l_start_date_new);
                FETCH chk_asgn INTO l_chk_asgn;
                IF chk_asgn%NOTFOUND THEN
                l_chk_asgn := 'N';
                ELSE
                l_chk_asgn := 'Y';
                END IF;
                CLOSE chk_asgn;
                --Bug 9762784 End

                --Added another condition for bug 8227271
                IF (pa_hr_update_api.get_defaultou(l_org_id_new) <> -999 and l_chk_asgn = 'Y') THEN --Bug 9762784

                -- call the work flow to update pa objects
                SAVEPOINT l_assignment_change;
                l_savepoint := true;
                pa_r_project_resources_pub.create_resource (
                      p_api_version        => 1.0
                     ,p_init_msg_list      => NULL
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validate_only      => NULL
                     ,p_max_msg_count      => NULL
                     ,p_internal           => 'Y'
                     ,p_person_id          => l_person_id
                     ,p_individual         => 'Y'
                     ,p_resource_type      => 'EMPLOYEE'
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data
                     ,x_resource_id        => l_resource_id);


                -- call this procedure to update the forecast data for
                -- assigned time ONLY for this resource
                -- pass null to start date and end date
                -- this is called only if create_resource is a success
                if (l_return_status = 'S' and l_resource_id is not null) then
                      PA_FORECASTITEM_PVT.Create_Forecast_Item(
                                  p_person_id      => l_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data
                               ) ;
	      end if;
             END IF ; -- IF (pa_hr_update_api.get_defaultou(l_org_id_new) <> -999) THEN
            end if;


                l_message_counter := l_message_counter + nvl(l_msg_count,0);

                if  l_return_status =  'U' then
                    app_exception.raise_exception;
                elsif  l_return_status = 'E' then
                    l_final_return_status := l_return_status;
                end if;

            end if;

       elsif l_calling_mode = 'UPDATE' then
            SAVEPOINT l_assignment_change;
            l_savepoint := true;
            if ( l_primary_flag_new = 'Y' and  l_primary_flag_old = 'N'
      and pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y'
and pa_hr_update_api.check_job_utilization (
P_job_id    => l_job_id_new,
P_person_id => NULL,
p_date      => NULL )= 'Y'
and pa_hr_update_api.get_defaultou(l_org_id_new) <> -999) then -- bug 6886592
                 --dbms_output.put_line('Calling ind pull 1');

                 -- call the work flow to update pa objects
                 pa_r_project_resources_pub.create_resource (
                      p_api_version        => 1.0
                     ,p_init_msg_list      => NULL
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validate_only      => NULL
                     ,p_max_msg_count      => NULL
                     ,p_internal           => 'Y'
                     ,p_person_id          => l_person_id
                     ,p_individual         => 'Y'
                     ,p_resource_type      => 'EMPLOYEE'
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data
                     ,x_resource_id        => l_resource_id);

                 -- call this procedure to update the forecast data for
                 -- assigned time ONLY for this resource
                 -- pass null to start date and end date
                 -- this is called only if create_resource is a success
                 if (l_return_status = 'S' and l_resource_id is not null) then
                      PA_FORECASTITEM_PVT.Create_Forecast_Item(
                                  p_person_id      => l_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data
                               ) ;
                 end if;


                l_message_counter := l_message_counter + nvl(l_msg_count,0);

                if  l_return_status =  'U' then

                    app_exception.raise_exception;

                elsif  l_return_status = 'E' then

                    l_final_return_status := l_return_status;
                end if;

         elsif nvl(l_primary_flag_old,'N') <> nvl(l_primary_flag_new,'N') then

            --dbms_output.put_line('Primary flags differ');

               if (l_primary_flag_new = 'Y' and  l_primary_flag_old = 'N'
                                  and pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'N') then

                  /*If the assignments organization does not belong to expenditure hierarchy
                    then the corresponding assignment in pa_resources_denorm must be
                    end dated
                  */
                  pa_hr_update_api.Update_EndDate(
                          p_person_id => l_person_id,
                          p_old_start_date => l_start_date_old,
                          p_new_start_date => l_start_date_new,
                          p_old_end_date => l_end_date_old,
                          p_new_end_date => sysdate,
                          x_return_status => l_return_status,
                          x_msg_data => l_msg_data,
                          x_msg_count => l_msg_count);
                else

                  -- for all other cases, still need to call this API which will call
                  -- forecast items
                  -- call the work flow to update pa objects
                  pa_hr_update_api.Update_PrimaryFlag (
                     p_person_id          => l_person_id
                    ,p_old_start_date     => l_start_date_old
                    ,p_new_start_date     => l_start_date_new
                    ,p_old_end_date       => l_end_date_old
                    ,p_new_end_date       => l_end_date_new
                    ,x_return_status      => l_return_status
                    ,x_msg_count          => l_msg_count
                    ,x_msg_data           => l_msg_data);

                end if;

                l_message_counter := l_message_counter + nvl(l_msg_count,0);
                if  l_return_status =  'U' then

                    app_exception.raise_exception;

                elsif  l_return_status = 'E' then

                    l_final_return_status := l_return_status;
                end if;

         else --after primary flag

           --dbms_output.put_line('Primary flags are same');

            -- The code below checks if record exists for update in
            -- pa_resources_denorm.  This check is required because a new
            -- assignment creation in HR only updates the default HR
            -- assignment. So the new assignment will not exist in PRM

            -- Bug 4352255 - performance improvement - change to where exists
            -- instead of count. And move it to here from above.
            -- Bug 4668272 - Handle NO_DATA_FOUND exception.

            l_res_asgn_exists := 'N';

            BEGIN
            SELECT 'Y'
            INTO   l_res_asgn_exists
            FROM   dual
            WHERE EXISTS (SELECT 'Y'
                          FROM   pa_resources_denorm
                          WHERE  person_id                     = l_person_id
                          AND    resource_effective_start_date =
                                                             l_start_date_new);
           EXCEPTION WHEN NO_DATA_FOUND THEN
              l_res_asgn_exists := 'N';
           END;
           -- END -- Bug 4668272 - added exception handler

           -- Bug 4668272 change l_res_asgn_exists = 'Y' to 'N'
           /* if (l_res_asgn_exists = 'N' AND
               pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y') THEN commented and changed as below for bug 5665503 */

if ( (l_res_asgn_exists = 'N' OR (trunc( l_start_date_old) <> trunc(
l_start_date_new)) )
AND ( pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y')
and (pa_hr_update_api.check_job_utilization(
P_job_id    => l_job_id_new,
P_person_id => NULL,
p_date      => NULL )= 'Y')
and pa_hr_update_api.get_defaultou(l_org_id_new) <> -999)  /*bug6886592*/
	       THEN

           --dbms_output.put_line('Calling ind pull 2 as record does not exist or start date is changed');

                  pa_r_project_resources_pub.create_resource (
                      p_api_version        => 1.0
                     ,p_init_msg_list      => NULL
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validate_only      => NULL
                     ,p_max_msg_count      => NULL
                     ,p_internal           => 'Y'
                     ,p_person_id          => l_person_id
                     ,p_individual         => 'Y'
                     ,p_resource_type      => 'EMPLOYEE'
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => l_msg_count
                     ,x_msg_data           => l_msg_data
                     ,x_resource_id        => l_resource_id);

                   -- call this procedure to update the forecast data for
                   -- assigned time ONLY for this resource
                   -- pass null to start date and end date
                   -- this is called only if create_resource is a success
                   if (l_return_status = 'S' and l_resource_id is not null) then
                       PA_FORECASTITEM_PVT.Create_Forecast_Item(
                                  p_person_id      => l_person_id
                                 ,p_start_date     => null
                                 ,p_end_date       => null
                                 ,p_process_mode   => 'GENERATE_ASGMT'
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data
                               ) ;
                   end if;


                l_message_counter := l_message_counter + nvl(l_msg_count,0);

                if  l_return_status =  'U' then

                    app_exception.raise_exception;

                elsif  l_return_status = 'E' then

                    l_final_return_status := l_return_status;
                end if;

           else
                   if ( trunc( l_end_date_old) <> trunc( l_end_date_new)
AND l_res_asgn_exists = 'Y') /*bug 6886592*/ THEN

                        --dbms_output.put_line('Date Change');

                        -- call the work flow to update pa objects
                        pa_hr_update_api.Update_EndDate (
                             p_person_id          => l_person_id
                            ,p_old_start_date     => l_start_date_old
                            ,p_new_start_date     => l_start_date_new
                            ,p_old_end_date       => l_end_date_old
                            ,p_new_end_date       => l_end_date_new
                            ,x_return_status      => l_return_status
                            ,x_msg_count          => l_msg_count
                            ,x_msg_data           => l_msg_data);

                        l_message_counter := l_message_counter + nvl(l_msg_count,0);
                        if  l_return_status =  'U' then

                            app_exception.raise_exception;

                        elsif  l_return_status = 'E' then

                            l_final_return_status := l_return_status;
                        end if;
                    end if;

                    if (nvl(l_org_id_old,-1) <> nvl(l_org_id_new,-1) ) THEN

                      --dbms_output.put_line('Organization changed');

                        -- call the work flow to update pa objects
						--     Bug 9703979
						if ((pa_hr_update_api.belongs_ExpOrg(l_org_id_old) ='Y' and
pa_hr_update_api.get_defaultou(l_org_id_old) <> -999))  then
if ((pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y' and
pa_hr_update_api.get_defaultou(l_org_id_new) <> -999))
then
                        pa_hr_update_api.Update_Org (
                             p_person_id          => l_person_id
                            ,p_old_org_id         => l_org_id_old
                            ,p_new_org_id         => l_org_id_new
                            ,p_old_start_date     => l_start_date_old
                            ,p_new_start_date     => l_start_date_new
                            ,p_old_end_date       => l_end_date_old
                            ,p_new_end_date       => l_end_date_new
                            ,x_return_status      => l_return_status
                            ,x_msg_count          => l_msg_count
                            ,x_msg_data           => l_msg_data);

                        l_message_counter := l_message_counter + nvl(l_msg_count,0);
                        if  l_return_status =  'U' then

                            app_exception.raise_exception;

                        elsif  l_return_status = 'E' then

                            l_final_return_status := l_return_status;
                        end if;
                      end if;
                    end if;
        end if; -- bug 6886592

		/*bug 6886592*/
                    if (nvl(l_job_id_old,-1) <> nvl(l_job_id_new,-1) ) THEN
if ((pa_hr_update_api.check_job_utilization(
P_job_id    => l_job_id_old,
P_person_id => NULL,
p_date      => NULL ))= 'Y'
or
      (pa_hr_update_api.check_job_utilization(
P_job_id    => l_job_id_new,
P_person_id => NULL,
p_date      => NULL ))= 'Y' 	)				THEN
 -- bug 9687133
if (l_job_id_old is not null or (l_job_id_old is null and
pa_hr_update_api.belongs_ExpOrg(l_org_id_new) = 'Y' and
pa_hr_update_api.get_defaultou(l_org_id_new) <> -999))		THEN

                    --dbms_output.put_line('Job changed');

                        -- call the work flow to update pa objects
                        pa_hr_update_api.Update_Job (
                             p_person_id          => l_person_id
                            ,p_old_job            => l_job_id_old
                            ,p_new_job            => l_job_id_new
                            ,p_new_start_date     => l_start_date_new
                            ,p_new_end_date       => l_end_date_new
                            ,x_return_status      => l_return_status
                            ,x_msg_count          => l_msg_count
                            ,x_msg_data           => l_msg_data);

                        l_message_counter := l_message_counter + nvl(l_msg_count,0);
                        if  l_return_status =  'U' then

                            app_exception.raise_exception;

                        elsif  l_return_status = 'E' then

                            l_final_return_status := l_return_status;
                        end if;
                      end if;
                    end if;
        end if; --bug 6886592
                    if (nvl(l_supervisor_old,-1) <> nvl(l_supervisor_new,-1) ) THEN

                        --dbms_output.put_line('Supervisor changed');

                        -- call the work flow to update pa objects
                        pa_hr_update_api.Update_Supervisor (
                             p_person_id          => l_person_id
                            ,p_old_supervisor     => l_supervisor_old
                            ,p_new_supervisor     => l_supervisor_new
                            ,p_new_start_date     => l_start_date_new
                            ,p_new_end_date       => l_end_date_new
                            ,x_return_status      => l_return_status
                            ,x_msg_count          => l_msg_count
                            ,x_msg_data           => l_msg_data);

                        l_message_counter := l_message_counter + nvl(l_msg_count,0);
                        if  l_return_status =  'U' then

                            app_exception.raise_exception;

                        elsif  l_return_status = 'E' then

                            l_final_return_status := l_return_status;
                        end if;

                    end if;

            end if; --end after l_res_asgn_exists check
         end if;--end after primary flag
       end if; --end update


       IF l_final_return_status = 'S'  THEN

            resultout := wf_engine.eng_completed||':'||'S';
       ELSIF l_return_status = 'E' THEN
            l_savepoint  := false;
            rollback to l_assignment_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);
            resultout := wf_engine.eng_completed||':'||'F';

       ELSE
            l_savepoint  := false;
            rollback to l_assignment_change ;
            set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  fnd_msg_pub.count_msg,
                                  p_msg_data     =>  l_msg_data);

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => l_msg_data
                               );

            resultout := wf_engine.eng_completed||':'||'F';
       END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       If (l_savepoint) then
        rollback to l_assignment_change ;
       end if;

       wf_core.context     ('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);

        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

       resultout := wf_engine.eng_completed||':'||'F';
       --RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       If (l_savepoint) then
                rollback to l_assignment_change ;
       End if;

       wf_core.context('pa_hr_update_pa_objects',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

       resultout := wf_engine.eng_completed||':'||'U';
       --RAISE;

    WHEN OTHERS THEN
       If (l_savepoint) then
                rollback to l_assignment_change ;
       End if;
/*       wf_core.context     ('pa_forecast_test',
                            'start_date_change',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
*/
        If l_msg_data is NULL and nvl(l_msg_count,0) = 0 then

            wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname => 'ERROR_MSG1'
                               , avalue => SQLCODE||SQLERRM
                               );
        Else
                  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                                  p_item_key     =>  itemkey,
                                  p_msg_count    =>  l_msg_count,
                                  p_msg_data     =>  l_msg_data);

        End if;

       resultout := wf_engine.eng_completed||':'||'U';
       --RAISE;

END assignment_change;

PROCEDURE set_nf_error_msg_attr (p_item_type IN VARCHAR2,
                                 p_item_key  IN VARCHAR2,
                                 p_msg_count IN NUMBER,
                                 p_msg_data IN VARCHAR2 ) IS

l_msg_index_out           NUMBER ;
l_msg_data           VARCHAR2(2000);
l_data                   VARCHAR2(2000);
l_item_attr_name   VARCHAR2(30);
BEGIN
          IF nvl(p_msg_count,0)  = 0 and p_msg_data is NULL THEN
               RETURN;
          Elsif nvl(p_msg_count,0)  = 0 and p_msg_data is NOT NULL then
               l_data := FND_MESSAGE.get_string('PA',p_msg_data);
                wf_engine.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG1'
                               , avalue => l_data
                               );


               RETURN;
          END IF;

          IF p_msg_count = 1 THEN
            /* -- this is commented as p_msg_data is string or code cannot be determined
               -- so fnd_message.get_string is used instead of fnd_message.set encoded
               -- IF p_msg_data IS NOT NULL THEN
               -- FND_MESSAGE.SET_ENCODED (p_msg_data);
               -- l_data := FND_MESSAGE.GET;
            */

             -- Added to fix the Bug 1563218
               If   p_msg_count = 1 and p_msg_data is not NULL then
                 -- Added this to identify whether the incoming message is ENCODED or DECODED. Bug 8986089
                  IF (Upper(p_msg_data) = p_msg_data) THEN
                    l_data := FND_MESSAGE.get_string('PA',p_msg_data);
                  ELSE
                    l_data := p_msg_data;
                  END IF;
               End if;

                wf_engine.SetItemAttrText
                                              ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_MSG1'
                               , avalue => l_data
                               );

             RETURN ;
          END IF;

               IF p_msg_count > 1 THEN
              FOR i in 1..p_msg_count
            LOOP
              IF i > 5 THEN
                   EXIT;
              END IF;

              pa_interface_utils_pub.get_messages
                (p_encoded        => FND_API.G_FALSE,
                  p_msg_index      => i,
                 p_msg_count      => p_msg_count ,
                 p_msg_data       => p_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );

              -- Added to fix the Bug 1563218
              if l_data is NULL then
                 l_data := FND_MESSAGE.get_string('PA',p_msg_data);
              end if;

                 l_item_attr_name := 'ERROR_MSG'||i;
                   wf_engine.SetItemAttrText
                               ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_item_attr_name
                               , avalue => l_data
                               );
            END LOOP;
          END IF;

EXCEPTION
        WHEN OTHERS THEN
           RAISE;
END set_nf_error_msg_attr;

--
--  PROCEDURE
--              create_fte_sync_wf
--  PURPOSE
--              This procedure creates a wf process for termination of employee/contingent worker
--
--  HISTORY
--  27-MAR-207       kjai       Created for Bug 5683340
PROCEDURE create_fte_sync_wf
(p_person_id    IN  PA_EMPLOYEES.PERSON_ID%TYPE
,p_wait_days    IN NUMBER
,x_return_status      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_data           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
)
IS

l_msg_index_out         NUMBER;
l_save_thresh           NUMBER ;

l_item_type VARCHAR2(8):='PAXWFHRU';

l_item_key  NUMBER ;

l_person_name VARCHAR2(240);
l_return_status         VARCHAR2(1);

l_err_code              NUMBER := 0;
l_err_stage             VARCHAR2(2000);
l_err_stack             VARCHAR2(2000);

BEGIN

x_return_status    := FND_API.G_RET_STS_SUCCESS;

-- Get a unique identifier for this specific workflow
--
   SELECT pa_workflow_itemkey_s.nextval
   INTO l_item_key
   FROM dual;

-- Since this workflow needs to be executed in Non deferred mode,
-- we need to change the threshold. So we save the current threshold which
-- will be used later on to change it back to the current threshold.
--
   l_save_thresh  := wf_engine.threshold ;

--
-- Set the threshold to 50 so that the process will not be deferred
--
   wf_engine.threshold := 50 ;


-- Create the appropriate process
--
   wf_engine.CreateProcess( ItemType => l_item_type,
                            ItemKey  => l_item_key,
                            process  => 'TIMEOUT_TERMINATION_PROCESS' );



-- Initialize workflow item attributes with the parameter values
--
   wf_engine.SetItemAttrText(itemtype        => l_item_type,
                             itemkey         => l_item_key,
                             aname           => 'PROJECT_RESOURCE_ADMINISTRATOR',
                             avalue          => 'PASYSADMIN');

   wf_engine.SetItemAttrNumber(itemtype         => l_item_type,
                               itemkey          => l_item_key,
                               aname            => 'PERSON_ID',
                               avalue           => p_person_id);

   wf_engine.SetItemAttrNumber(itemtype          => l_item_type,
                               itemkey           => l_item_key,
                               aname             => 'WAIT_DAYS',
                               avalue            => p_wait_days);

--call the api to get person name
pa_resource_utils.get_person_name(p_person_id     => p_person_id,
                                  x_person_name   => l_person_name,
                                  x_return_status => l_return_status);


IF l_return_status = 'S' THEN
  --Set the wf name attribute for display of name , if any error occurs
  wf_engine.SetItemAttrText (itemtype        => l_item_type,
                             itemkey          => l_item_key,
                             aname                 => 'FULL_NAME_NEW',
                             avalue                => l_person_name);

END IF ;



-- Starting the work flow process and calling work flow api internaly
--
   WF_ENGINE.StartProcess( itemtype => l_item_type,
                           itemkey  => l_item_key);

        -- Insert to PA tables wf process information.
        -- This is required for displaying notifications on PA pages.

        BEGIN

           PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'HR_CHANGE_MGMT'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(p_person_id)
                ,p_entity_key2         => to_char(p_person_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

        EXCEPTION
           WHEN OTHERS THEN
                null;
        END;



--Setting the original value
   wf_engine.threshold := l_save_thresh;


EXCEPTION
WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_HR_UPDATE_PA_ENTITIES',
                              p_procedure_name   => 'create_fte_sync_wf');
     If x_msg_count = 1 THEN
     pa_interface_utils_pub.get_messages
       (p_encoded        => FND_API.G_TRUE,
        p_msg_index      => 1,
        p_msg_count      => x_msg_count,
        p_msg_data       => x_msg_data,
        p_data           => x_msg_data,
        p_msg_index_out  => l_msg_index_out );
     End If;
     RAISE ;

END create_fte_sync_wf;


--
--  PROCEDURE
--              start_fte_sync_wf
--  PURPOSE
--              This procedure starts wf process for termination of employee/contingent worker
--
--  HISTORY
--  27-MAR-207       kjai       Created for Bug 5683340
PROCEDURE start_fte_sync_wf
(itemtype                       IN      VARCHAR2
, itemkey                       IN      VARCHAR2
, actid                         IN      NUMBER
, funcmode                      IN      VARCHAR2
, resultout                     OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

l_person_id             NUMBER;

l_msg_count             NUMBER;
l_msg_data              VARCHAR(2000);
l_return_status         VARCHAR2(1);
l_api_version_number    NUMBER := 1.0;
l_data                  VARCHAR2(2000);
l_msg_index_out         NUMBER;

l_resource_effective_end_date DATE ;

l_resource_id	        pa_resources.resource_id%TYPE ;

l_invol_term            VARCHAR2(1);

l_savepoint             BOOLEAN;

BEGIN

-- Get the workflow attribute values
--
l_person_id  := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                            itemkey         => itemkey,
                                            aname           => 'PERSON_ID' );


SAVEPOINT l_termination_change ;
l_savepoint := true;

  log_message('before calling PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE');
  PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE( p_api_version => 1.0,
                                              p_internal => 'Y',
                                              p_individual => 'Y',
                                              P_PERSON_ID => l_person_id,
                                              p_scheduled_member_flag => 'Y',
					      P_PULL_TERM_RES  => 'Y',
                                              x_return_status    => l_return_status,
                                              x_msg_data         => l_msg_data,
					      x_msg_count        => l_msg_count,
                                              x_resource_id      => l_resource_id);
  log_message('after calling PA_R_PROJECT_RESOURCES_PUB.CREATE_RESOURCE, l_return_status: '||l_return_status);



IF l_return_status = 'S' THEN
  SELECT max(resource_effective_end_date)
  INTO l_resource_effective_end_date
  FROM pa_resources_denorm
  WHERE person_id = l_person_id;

  log_message('before calling PA_HR_UPDATE_API.withdraw_cand_nominations, l_resource_effective_end_date: '||l_resource_effective_end_date);
  PA_HR_UPDATE_API.withdraw_cand_nominations
                 ( p_person_id        => l_person_id,
                   p_effective_date   => l_resource_effective_end_date,
                   x_return_status    => l_return_status,
                   x_msg_data         => l_msg_data,
                   x_msg_count        => l_msg_count);
  log_message('after calling PA_HR_UPDATE_API.withdraw_cand_nominations, l_return_status: '||l_return_status);
END IF ;


IF l_return_status = 'S' THEN
  log_message('before calling pa_resource_utils.set_fte_flag');
  pa_resource_utils.set_fte_flag(p_person_id  => l_person_id,
                                 p_future_term_wf_flag => NULL,
                                 x_msg_data => l_msg_data,
                                 x_return_status => l_return_status,
				 x_msg_count => l_msg_count) ;
  log_message('after calling pa_resource_utils.set_fte_flag, l_return_status: '||l_return_status);
END IF ;


IF l_return_status = 'S'  THEN
  resultout := wf_engine.eng_completed||':'||'S';
ELSIF l_return_status = 'E' THEN

  -- Set any error messages
  --
  l_savepoint  := false;
  ROLLBACK to l_termination_change ;
  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                        p_item_key     =>  itemkey,
                        p_msg_count    =>  l_msg_count,
                        p_msg_data     =>  l_msg_data);
  resultout := wf_engine.eng_completed||':'||'E';

ELSE
  --
  -- Set any error messages
  --
  l_savepoint  := false;
  ROLLBACK to l_termination_change ;
  set_nf_error_msg_attr(p_item_type    =>  itemtype,
                        p_item_key     =>  itemkey,
                        p_msg_count    =>  fnd_msg_pub.count_msg,
                        p_msg_data     =>  l_msg_data);

 resultout := wf_engine.eng_completed||':'||'E';

END IF;

EXCEPTION
WHEN OTHERS THEN
  log_message('Execption OTHERS, '||SQLERRM ||', '|| SQLCODE);
  wf_core.context('pa_hr_update_pa_entities',
                  'Start_fte_sync_wf',
		  itemtype,
                  itemkey,
                  to_char(actid),
                  funcmode);
  IF  (l_savepoint) THEN
   log_message('before rollback to l_termination_change');
   ROLLBACK to l_termination_change ;
   log_message('after rollback to l_termination_change');
  END IF;

  IF l_msg_data is NULL and nvl(l_msg_count,0) = 0 then
   log_message('l_msg_data is NULL');
   wf_engine.SetItemAttrText( itemtype => itemtype
                            , itemkey =>  itemkey
                            , aname => 'ERROR_MSG1'
                            , avalue => SQLCODE||SQLERRM
                            );
  ELSE log_message('l_msg_data is not NULL');
   set_nf_error_msg_attr(p_item_type    =>  itemtype,
                         p_item_key     =>  itemkey,
                         p_msg_count    =>  l_msg_count,
                         p_msg_data     =>  l_msg_data);

  END IF ;

  resultout := wf_engine.eng_completed||':'||'U';
  log_message('resultout: '||resultout);
  --RAISE;

END start_fte_sync_wf;

END ;

/
