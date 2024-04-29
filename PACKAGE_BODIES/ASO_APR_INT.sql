--------------------------------------------------------
--  DDL for Package Body ASO_APR_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_INT" AS
  /*  $Header: asoiaprb.pls 120.7.12010000.2 2014/08/07 08:37:58 rassharm ship $ */
  g_pkg_name           CONSTANT VARCHAR2 (300) := 'ASO_APR_INT';
  g_file_name          CONSTANT VARCHAR2 (1000) := 'ASOIAPRB.PLS';
  g_user_id                     NUMBER;

  FUNCTION get_approver_name (
    p_user_id                            NUMBER,
    p_person_id                          NUMBER
  )
    RETURN VARCHAR2 IS
    l_user_id                     NUMBER;
    l_person_id                   NUMBER;
    no_user_id                    EXCEPTION;

    CURSOR get_person_name (
      c_person_id                          NUMBER
    ) IS
      SELECT full_name
      FROM per_all_people_f
      WHERE person_id = c_person_id
            AND SYSDATE BETWEEN effective_start_date
                            AND NVL (
                                  effective_end_date,
                                  SYSDATE
                                );

    -- hyang performance fix, bug 2860045
    CURSOR get_resource_name (
      c_user_id                            NUMBER
    ) IS
      SELECT source_name
      FROM jtf_rs_resource_extns
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Get approver name function ',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'p_user_id ' || p_user_id || ' p_person_id ' || p_person_id,
        1,
        'N'
      );
    END IF;

    IF (p_person_id = fnd_api.g_miss_num)
    THEN
      l_person_id  := NULL;
    ELSE
      l_person_id  := p_person_id;
    END IF;

    IF (p_user_id = fnd_api.g_miss_num)
    THEN
      l_user_id  := NULL;
    ELSE
      l_user_id  := p_user_id;
    END IF;

    IF ((l_person_id IS NULL)
        AND (l_user_id IS NULL)
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'The person id and user id are null',
          1,
          'N'
        );
      END IF;
      RAISE no_user_id;
    ELSIF l_person_id IS NOT NULL
    THEN
      FOR i IN get_person_name (
                 l_person_id
               )
      LOOP
        IF i.full_name IS NULL
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'full name is null for person_id :' || l_person_id,
              1,
              'N'
            );
          END IF;
          RAISE no_user_id;
        ELSE
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The approver name is from HR table ' || i.full_name,
              1,
              'N'
            );
          END IF;
          RETURN i.full_name;
        END IF;
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'person_id ' || l_person_id || ' does not exist in per_all_people_f',
          1,
          'N'
        );
      END IF;
      RAISE no_user_id;
    ELSE
      FOR k IN get_resource_name (
                 l_user_id
               )
      LOOP
        IF k.source_name IS NULL
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Resource  name is null for user_id :' || l_user_id,
              1,
              'N'
            );
          END IF;
          RAISE no_user_id;
        ELSE
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The approver name is from JTF table ' || k.source_name,
              1,
              'N'
            );
          END IF;
          RETURN k.source_name;
        END IF;
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'user_id ' || l_user_id || 'does not exist in jtf resources',
          1,
          'N'
        );
      END IF;
      RAISE no_user_id;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Should not be reached inside the get_approver_name',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN no_user_id
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'No username found from ids',
          1,
          'N'
        );
      END IF;
      fnd_message.set_name (
        'ASO',
        'ASO_APR_NO_USER_ID'
      );
      fnd_message.set_token (
        'USER_ID',
        p_user_id
      );
      fnd_message.set_token (
        'PERSON_ID',
        p_person_id
      );
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'No username found from ids',
          1,
          'N'
        );
      END IF;
      fnd_message.set_name (
        'ASO',
        'ASO_APR_NO_USER_ID'
      );
      fnd_message.set_token (
        'USER_ID',
        p_user_id
      );
      fnd_message.set_token (
        'PERSON_ID',
        p_person_id
      );
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
  END get_approver_name;

  PROCEDURE get_all_approvers (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_clear_transaction_flag    IN       VARCHAR2 := fnd_api.g_true,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_approvers_list            OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.approvers_list_tbl_type,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.rules_list_tbl_type
  ) IS
    l_api_name           CONSTANT VARCHAR2 (30) := 'GET_ALL_APPROVERS';
    l_api_version        CONSTANT NUMBER := 1.0;
    approvers                     ame_util.approverstable;
    ruleids                       ame_util.idlist;
    ruledescriptions              ame_util.stringlist;
    l_ruletypeout                 VARCHAR2 (240);
    l_conditionidsout             ame_util.idlist;
    l_approvaltypenameout         VARCHAR2 (240);
    l_approvaltypedescriptionout  VARCHAR2 (240);
    m                             integer;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin get_all_approvers',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Application ID : ' || p_application_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object ID : ' || p_object_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Type : ' || p_object_type,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Commit Flag : ' || p_commit,
        1,
        'N'
      );
    END IF;
    -- Standard  call to establisg savepoint .

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Establishing save point GET_ALL_APPROVERS_INT',
        1,
        'N'
      );
    END IF;
    SAVEPOINT get_all_approvers_int;

    -- Standard call to check for call compatibility.

    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'GET_ALL_APROVERS api call was not compatible pls check version ',
          1,
          'N'
        );
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE

    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Initializing the message list ',
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success

    x_return_status  := fnd_api.g_ret_sts_success;

    -- Clear all transactions if the flag is set to true

    IF fnd_api.to_boolean (
         p_clear_transaction_flag
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'clearing all previous transactions in AME ',
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling AME clearAllApprovals',
          1,
          'N'
        );
      END IF;
      ame_api.clearallapprovals (
        applicationidin              => p_application_id,
        transactionidin              => p_object_id,
        transactiontypein            => p_object_type
      );
    END IF;

    -- Calling the OAM API to get all the approvers  -----

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling AME get All Approvers Procedure',
        1,
        'N'
      );
    END IF;
    ame_api.getapproversandrules1 (
      applicationidin              => p_application_id,
      transactionidin              => p_object_id,
      transactiontypein            => p_object_type,
      approversout                 => approvers,
      ruleidsout                   => ruleids
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Approvers Count is ' || approvers.COUNT,
        1,
        'N'
      );
    END IF;


    -- Added code to check if it is a self-approval case
    IF ((approvers.count = 1) and (approvers(1).approval_status = ame_util.approvedStatus)) THEN

      -- the requester is approver in this case
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Self approval case -- requester is only approver', 1, 'N');
      END IF;
      NULL;

    ELSE



    -- Looping through the PL/SQL Table and assigning values to be passed OUT NOCOPY /* file.sql.39 change */ as
    -- list of approvers

    FOR i IN 1 .. approvers.COUNT
    LOOP


     /*  Added new logic for checking duplicates */

     /*  This logic is necessary as AME has made changes in 11.5.10 due to which
	    duplicate approvers can be returned from ame_api   */

   IF i > 1 THEN


         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (' Checking for duplicate approvers',1,'N');
         END IF;


    FOR j IN 1..x_approvers_list.COUNT LOOP

     IF (( approvers(i).user_id = x_approvers_list(j).approver_user_id ) OR
          ( approvers(i).person_id = x_approvers_list(j).approver_person_id ))  THEN


         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD ('Found a duplicate approver  ',1,'N');
            aso_debug_pub.ADD ('Duplicate approver person_id is   '|| approvers(i).person_id,1,'N');


         END IF;


		GOTO end_of_loop;

     END IF;
    END LOOP;

   END IF;

	 m  := x_approvers_list.count + 1;
	 x_approvers_list (
        m
      ).approver_user_id                       := approvers (
                                                    i
                                                  ).user_id;
      x_approvers_list (
        m
      ).approver_person_id                     := approvers (
                                                    i
                                                  ).person_id;
      x_approvers_list (
        m
      ).approver_sequence                      := m;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'The person_id is ' || approvers (
                                   i
                                 ).person_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'The user_id is ' || approvers (
                                 i
                               ).user_id,
          1,
          'N'
        );
      END IF;
      -- Calling the function to get the approver  name

      x_approvers_list (
        m
      ).approver_name                          :=
             get_approver_name (
               approvers (
                 i
               ).user_id,
               approvers (
                 i
               ).person_id
             );

    <<end_of_loop>>

    NULL;  -- if duplicate approver do nothing

    END LOOP;

    END IF;  -- end if for self approver case


    --  Calling the OAM API to get the rules

    --  Looping through the PL/SQL Table to assign values to be passed OUT NOCOPY /* file.sql.39 change */ as list
    --  of rules and their descriptions

    FOR i IN 1 .. ruleids.COUNT
    LOOP
      x_rules_list (
        i
      ).rule_id                 := ruleids (
                                     i
                                   );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Calling AME get applicable rules procedure',
          1,
          'N'
        );
      END IF;
      ame_api.getruledetails1 (
        ruleidin                     => ruleids (
                                          i
                                        ),
        ruletypeout                  => l_ruletypeout,
        ruledescriptionout           => x_rules_list (
                                          i
                                        ).rule_description,
        conditionidsout              => l_conditionidsout,
        approvaltypenameout          => l_approvaltypenameout,
        approvaltypedescriptionout   => l_approvaltypedescriptionout,
        approvaldescriptionout       => x_rules_list (
                                          i
                                        ).approval_level
      );
    END LOOP;

    -- commit the work

    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Commiting the work in get_all_approvers procedure  ',
          1,
          'N'
        );
      END IF;
      COMMIT WORK;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End get all approvers  procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  FND_API.G_EXC_ERROR  in get_all_approvers ',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  FND_API.G_EXC_UNEXPECTED_ERROR in get_all_approvers ',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'When Others Exception in get_all_approvers ',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END get_all_approvers;

  PROCEDURE start_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_approver_sequence         IN       NUMBER := fnd_api.g_miss_num,
    p_requester_comments        IN       VARCHAR2,
    x_object_approval_id        OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_approval_instance_id      OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
    l_api_name           CONSTANT VARCHAR2 (30) := 'START_APPROVAL_PROCESS';
    l_api_version        CONSTANT NUMBER := 1.0;
    p_approval_instance_id        NUMBER;
    p_object_approval_id          NUMBER;
    p_approval_det_id             NUMBER;
    p_rule_id                     NUMBER;
    l_return_status               VARCHAR2 (10);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2 (240);
    x_approvers_list              aso_apr_pub.approvers_list_tbl_type;
    x_rules_list                  aso_apr_pub.rules_list_tbl_type;
    l_approver_status             VARCHAR2 (30);
    l_approver_sequence           NUMBER;
    p_sender_name                 VARCHAR2 (240);
    l_requester_group_id          NUMBER;
    l_sales_group_role            VARCHAR2(250);

    l_obsolete_status             varchar2(1);
    l_employee_id                 NUMBER;
    l_dup_approval                NUMBER;

    l_requestor_comments           varchar2(2000):=null; -- bug 19353943

    CURSOR c2 (
      c_object_id                          NUMBER
    ) IS
      SELECT NVL (
               (MAX (
                  approval_instance_id
                ) + 1
               ),
               1
             )
      FROM aso_apr_obj_approvals
      WHERE object_id = c_object_id;

   cursor get_employee_id(l_user_id NUMBER) IS
   select employee_id
   from fnd_user
   where user_id = l_user_id;

    CURSOR C_get_duplicate_approval IS
    SELECT count(*)
    FROM   aso_apr_obj_approvals
    WHERE  object_id = p_object_id
    AND    approval_status = 'PEND';


 BEGIN
    g_user_id               := fnd_global.user_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin start_approval_process procedure ',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Application ID : ' || p_application_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object ID : ' || p_object_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Type : ' || p_object_type,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Commit Flag : ' || p_commit,
        1,
        'N'
      );
    END IF;
    -- Standard  call to establisg savepoint .

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Establishing save point START_APPROVAL_PROCESS_INT',
        1,
        'N'
      );
    END IF;
    SAVEPOINT start_approval_process_int;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'START_APPROVAL_PROCESS_PUB api call was not compatible pls check version ',
          1,
          'N'
        );
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE

    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Initializing the message list ',
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status         := fnd_api.g_ret_sts_success;


    OPEN C_get_duplicate_approval;
    FETCH C_get_duplicate_approval INTO l_dup_approval ;
    CLOSE C_get_duplicate_approval;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD('l_dup_approval: '|| l_dup_approval,1,'N');
    END IF;

 IF l_dup_approval = 0 THEN

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Parameter p_approver sequence is :' || p_approver_sequence,
        1,
        'N'
      );
    END IF;

    -- Initializing the approver sequnce , used later in skip logic
    IF (p_approver_sequence IS NULL)
       OR (p_approver_sequence = fnd_api.g_miss_num)
    THEN
      l_approver_sequence  := 0;
    ELSE
      l_approver_sequence  := p_approver_sequence;
    END IF;

    -- Get the Requester Group id
    begin

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Before calling aso_utility_pvt.Get_Profile_Obsolete_Status', 1, 'N');
    END IF;

    l_obsolete_status := aso_utility_pvt.Get_Profile_Obsolete_Status(p_profile_name   => 'AST_DEFAULT_ROLE_AND_GROUP',
                                                                     p_application_id => 521);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('After calling Get_Profile_Obsolete_Status: l_obsolete_status: ' || l_obsolete_status, 1, 'N');
    END IF;

    if l_obsolete_status = 'T' then

        l_sales_group_role := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('l_sales_group_role: ' || l_sales_group_role, 1, 'N');
        END IF;

        l_requester_group_id := SUBSTR(l_sales_group_role, 1, INSTR(l_sales_group_role,'(')-1);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('l_requester_group_id: ' || l_requester_group_id, 1, 'N');
        END IF;

        if l_requester_group_id is null then

            l_sales_group_role := FND_PROFILE.Value_Specific( 'AST_DEFAULT_GROUP', G_USER_ID, NULL, 521);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_sales_group_role: ' || l_sales_group_role, 1, 'N');
            END IF;

            l_requester_group_id := to_number(l_sales_group_role);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_requester_group_id: ' || l_requester_group_id, 1, 'N');
            END IF;

        end if;

    else

        l_sales_group_role := FND_PROFILE.Value_Specific( 'ASF_DEFAULT_GROUP_ROLE', G_USER_ID, NULL, 522);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('l_sales_group_role: ' || l_sales_group_role, 1, 'N');
        END IF;

        l_requester_group_id := SUBSTR(l_sales_group_role, 1, INSTR(l_sales_group_role,'(')-1);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('l_requester_group_id: ' || l_requester_group_id, 1, 'N');
        END IF;

        if l_requester_group_id is null then

            l_sales_group_role := FND_PROFILE.Value_Specific( 'AST_DEFAULT_ROLE_AND_GROUP', G_USER_ID, NULL, 521);

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_sales_group_role: ' || l_sales_group_role, 1, 'N');
            END IF;

            l_requester_group_id := substr(l_sales_group_role, instr(l_sales_group_role,':', -1) + 1, length(l_sales_group_role));

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('l_requester_group_id: ' || l_requester_group_id, 1, 'N');
            END IF;

        end if;

    end if;


    exception
    when others then
    l_requester_group_id := 0;
    end;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Requester Group ID is ' || l_requester_group_id,
        1,
        'N'
      );
    END IF;
    -- Generate a new value for the approval Instace ID
    OPEN c2 (
      p_object_id
    );
    FETCH c2 INTO p_approval_instance_id;
    CLOSE c2;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Approval Instance ID is ' || p_approval_instance_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Inserting a row into the header table ',
        1,
        'N'
      );
    END IF;

    l_requestor_comments:=substr(p_requester_comments,1,2000); -- bug 19353943
    -- Inserting a Row into the Header table by calling the Table Handler

    aso_apr_approvals_pkg.header_insert_row (
      p_object_approval_id,
      p_object_id,
      p_object_type,
      p_approval_instance_id,
      'PEND',
      p_application_id,
      SYSDATE -- p_START_DATE
      ,
      NULL -- p_END_DATE
      ,
      SYSDATE -- p_CREATION_DATE
      ,
      g_user_id -- p_CREATED_BY
      ,
      SYSDATE -- p_LAST_UPDATE_DATE
      ,
      g_user_id -- P_UPDATED_BY
      ,
      fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
      ,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
      NULL,
	 NULL -- p_CONTEXT
      ,
      NULL -- p_SECURITY_GROUP_ID
      ,
      NULL -- p_OBJECT_VERSION_NUMBER
      ,
      g_user_id -- p_REQUESTER_USERID
      ,
      l_requestor_comments -- l_REQUESTER_COMMENTS bug 19353943
      ,
      l_requester_group_id -- p_REQUESTER_GROUP_ID
    );
    -- Calling the API to get all the approvers  -----

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling get All Approvers Procedure',
        1,
        'N'
      );
    END IF;
    aso_apr_int.get_all_approvers (
      p_api_version_number,
      fnd_api.g_false,
      fnd_api.g_false,
      p_object_id,
      p_object_type,
      p_application_id,
      fnd_api.g_true, --  p_clear_transaction_flag
      l_return_status,
      l_msg_count,
      l_msg_data,
      x_approvers_list,
      x_rules_list
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Return Status from get_all_approvers is ' || l_return_status,
        1,
        'N'
      );
    END IF;

    -- Checking to find if the call to above API was successfull or not

    IF l_return_status <> fnd_api.g_ret_sts_success
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Return Status from get_all_approvers is ' || x_return_status,
          1,
          'N'
        );
      END IF;
      RAISE fnd_api.g_exc_error;
    ELSE
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'No of approvers is  ' || x_approvers_list.COUNT,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Object Approval ID is  ' || p_object_approval_id,
          1,
          'N'
        );
      END IF;

      -- Checking to see if the approver to be skipped is the last one
      FOR i IN 1 .. x_approvers_list.COUNT
      LOOP
        -- Checking if any approver is to be skipped or not
        IF (l_approver_sequence <> 0
            AND i < l_approver_sequence
           )
        THEN
          l_approver_status  := 'SKIP';
        ELSE
          l_approver_status  := 'NOSUBMIT';
        END IF;

       -- fix for bug 4590633
        l_employee_id := x_approvers_list(i).approver_person_id;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD ('person_id got from AME is: '||to_char(l_employee_id),1,'N');
        END IF;

        IF ((x_approvers_list(i).approver_person_id is null) or (x_approvers_list(i).approver_person_id = fnd_api.g_miss_num) and
            (x_approvers_list(i).approver_user_id is not null) and (x_approvers_list(i).approver_user_id <>  fnd_api.g_miss_num)) then

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.ADD ('Person_id is null from AME Hence deriving it from user_id',1,'N');
           END IF;

            open get_employee_id(x_approvers_list(i).approver_user_id);
            fetch get_employee_id into l_employee_id;
            close get_employee_id;

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.ADD ('Derived person_id is: '||to_char(l_employee_id),1,'N');
            END IF;

        END IF;

        -- end of fix for bug 4590633

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Inserting  rows into the detail table ',
            1,
            'N'
          );
        END IF;
        p_approval_det_id  := NULL;
        aso_apr_approvals_pkg.detail_insert_row (
          p_approval_det_id,
          p_object_approval_id,
          l_employee_id  --p_APPROVER_PERSON_ID
          ,
          x_approvers_list (
            i
          ).approver_user_id ---p_APPROVER_USER_ID
          ,
          i -- P_APPROVER_SEQUENCE
          ,
          l_approver_status -- p_APPROVER_STATUS
          ,
          NULL -- p_APPROVER_COMMENTS
          ,
          NULL -- p_DATE_SENT
          ,
          NULL -- p_DATE_RECEIVED
          ,
          SYSDATE -- p_CREATION_DATE
          ,
          SYSDATE -- p_LAST_UPDATE_DATE
          ,
          g_user_id -- P_CREATED_BY
          ,
          g_user_id -- P_UPDATED_BY
          ,
          fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
          ,
          NULL -- p_ATTRIBUTE1
          ,
          NULL -- p_ATTRIBUTE2
          ,
          NULL -- p_ATTRIBUTE3
          ,
          NULL -- p_ATTRIBUTE4
          ,
          NULL -- p_ATTRIBUTE5
          ,
          NULL -- p_ATTRIBUTE6
          ,
          NULL -- p_ATTRIBUTE7
          ,
          NULL -- p_ATTRIBUTE8
          ,
          NULL -- p_ATTRIBUTE9
          ,
          NULL -- p_ATTRIBUTE10
          ,
          NULL -- p_ATTRIBUTE11
          ,
          NULL -- p_ATTRIBUTE12
          ,
          NULL -- p_ATTRIBUTE13
          ,
          NULL -- p_ATTRIBUTE14
          ,
          NULL -- p_ATTRIBUTE15
          ,
          NULL -- p_Attribute16
		,
          NULL -- p_Attribute17
		,
          NULL  -- p_Attribute18
		,
          NULL -- p_Attribute19
		,
          NULL -- p_Attribute20
		,
		NULL   -- p_CONTEXT
          ,
          NULL -- p_SECURITY_GROUP_ID
          ,
          NULL -- p_OBJECT_VERSION_NUMBER
        );
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Inserting rows into the rule table ',
          1,
          'N'
        );
      END IF;

      FOR i IN 1 .. x_rules_list.COUNT
      LOOP
        aso_apr_approvals_pkg.rule_insert_row (
          p_rule_id,
          x_rules_list (
            i
          ).rule_id,
          x_rules_list (
            i
          ).rule_action_id,
          SYSDATE -- P_CREATION_DATE
          ,
          g_user_id -- P_CREATED_BY
          ,
          SYSDATE -- p_LAST_UPDATE_DATE
          ,
          g_user_id -- P_UPDATED_BY
          ,
          fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
          ,
          p_object_approval_id,
          NULL -- p_ATTRIBUTE1
          ,
          NULL -- p_ATTRIBUTE2
          ,
          NULL -- p_ATTRIBUTE3
          ,
          NULL -- p_ATTRIBUTE4
          ,
          NULL -- p_ATTRIBUTE5
          ,
          NULL -- p_ATTRIBUTE6
          ,
          NULL -- p_ATTRIBUTE7
          ,
          NULL -- p_ATTRIBUTE8
          ,
          NULL -- p_ATTRIBUTE9
          ,
          NULL -- p_ATTRIBUTE10
          ,
          NULL -- p_ATTRIBUTE11
          ,
          NULL -- p_ATTRIBUTE12
          ,
          NULL -- p_ATTRIBUTE13
          ,
          NULL -- p_ATTRIBUTE14
          ,
          NULL -- p_ATTRIBUTE15
          ,
          NULL -- p_Attribute16
          ,
          NULL -- p_Attribute17
          ,
          NULL  -- p_Attribute18
          ,
          NULL -- p_Attribute19
          ,
          NULL -- p_Attribute20
          ,
          NULL -- p_CONTEXT
          ,
          NULL -- p_SECURITY_GROUP_ID
          ,
          NULL -- p_OBJECT_VERSION_NUMBER
        );
      END LOOP;
    END IF;

    /*

     If the number of approvers is zero ( or no approvers are needed)
     then we need to set the status to Approved in the approval instance table
	This is the self approval case.
    */

    IF x_approvers_list.count = 0 then

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.ADD ('Self Approval Case: Updating to Approved',1,'N');
	 END IF;
      update aso_apr_obj_approvals
	 set approval_status = 'APPR',
	     end_date = sysdate
	 where object_approval_id = p_object_approval_id;
    END IF;

    -- Pass back the new approval id
    x_object_approval_id := p_object_approval_id;
    x_approval_instance_id  := p_approval_instance_id;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Object Approval ID :' || x_approval_instance_id,
        1,
        'N'
      );
	 aso_debug_pub.ADD (
        'Approval Instance ID :' || x_approval_instance_id,
        1,
        'N'
      );
    END IF;

 ELSE -- l_dup_approval is not 0

    -- return a dummy instance id
    x_approval_instance_id  := -1;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD(' Duplicate approval process FOUND , hence another process NOT Started',1,'N');
    END IF;
 END IF;

    -- commit the work

    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Commiting the work in START_APPROVAL_PROCESS procedure ',
          1,
          'N'
        );
      END IF;
      COMMIT WORK;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  Start_approval_process PROCEDURE  ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  FND_API.G_EXC_ERROR  in start_approval_process',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception FND_API.G_EXC_UNEXPECTED_ERROR in start_approval_process',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );

    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'When Others Exception in start_approval_process',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END start_approval_process;

  PROCEDURE cancel_approval_process (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_application_id            IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_object_approval_id        IN       NUMBER,
    p_user_id                   IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
    l_api_name           CONSTANT VARCHAR2 (3000) := 'cancel_approval_process';
    l_api_version        CONSTANT NUMBER := 1.0;
    l_cancellor_username          VARCHAR2 (240);

    CURSOR get_approval_id (
      c_object_id                          NUMBER,
      c_object_type                        VARCHAR2
    ) IS
      SELECT object_approval_id
      FROM aso_apr_obj_approvals
      WHERE object_id = c_object_id
            AND object_type = c_object_type
            AND approval_instance_id = (SELECT MAX (
                                                 approval_instance_id
                                               )
                                        FROM aso_apr_obj_approvals
                                        WHERE object_id = c_object_id
                                              AND object_type = c_object_type);
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin cancel_approval_process PROCEDURE ',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Application ID : ' || p_application_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object ID : ' || p_object_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Type : ' || p_object_type,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Commit Flag : ' || p_commit,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Approval Id : ' || p_object_approval_id,
        1,
        'N'
      );



   END IF;
    --  Set a save point
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Establishing save point CANCEL_APPROVAL_PROCESS_INT',
        1,
        'N'
      );
    END IF;
    SAVEPOINT cancel_approval_process_int;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'cancel_approval_process api call was not compatible pls check version ',
          1,
          'N'
        );
      END IF;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE

    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status       := fnd_api.g_ret_sts_success;

    -- Check to see if required parameters are passed
     IF ( ((P_Object_approval_id IS NULL) OR (P_Object_approval_id = FND_API.G_MISS_NUM)) AND
          ((p_object_id IS NULL) OR (p_object_id = FND_API.G_MISS_NUM)) AND
          ((p_object_type IS NULL) OR (p_object_type = FND_API.G_MISS_CHAR)) ) THEN

            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'P_Object_approval_id', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Object_approval_id ) , FALSE );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;

    IF (p_object_approval_id IS NULL)
       OR (p_object_approval_id = fnd_api.g_miss_num)
    THEN
      FOR i IN get_approval_id (
                 p_object_id,
                 p_object_type
               )
      LOOP
        -- calling the prccedure to cancel the workflow process

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Object approval ID :' || i.object_approval_id,
            1,
            'N'
          );
          aso_debug_pub.ADD (
            'Calling the wokflow procedure to start the cancellation process ',
            1,
            'N'
          );
        END IF;
        aso_apr_wf_pvt.cancelapproval (
          i.object_approval_id,
          p_itemtype,
		p_user_id
        );
      END LOOP;
    ELSE
      -- calling the prccedure to cancel the workflow process
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Object approval ID :' || p_object_approval_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling the wokflow procedure to start the cancellation process ',
          1,
          'N'
        );
      END IF;
      aso_apr_wf_pvt.cancelapproval (
        p_object_approval_id,
          p_itemtype,
          p_user_id
      );
    END IF;

    -- Commit the work

    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Committing the work in cancel approval procedure ',
          1,
          'N'
        );
      END IF;
      COMMIT WORK;
    END IF;

   fnd_msg_pub.count_and_get(p_encoded => 'F',
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   for k in 1..x_msg_count loop
    x_msg_data := fnd_msg_pub.get(p_msg_index => k,
                                  p_encoded   => 'F');
   end loop;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End CancelApproval procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception FND_API.G_EXC_ERROR  in CancelApproval',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception FND_API.G_EXC_UNEXPECTED_ERROR in CancelApproval',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'When Others Exception in CancelApproval',
          1,
          'N'
        );
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END cancel_approval_process;

  PROCEDURE skip_approver (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_object_id                 IN       NUMBER,
    p_object_type               IN       VARCHAR2,
    p_approver_id               IN       NUMBER,
    p_approval_instance_id      IN       NUMBER,
    p_application_id            IN       NUMBER,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
    l_api_name           CONSTANT VARCHAR2 (30) := 'skip_approver';
    l_api_version        CONSTANT NUMBER := 1.0;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of skip_approver',
        1,
        'N'
      );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE

    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END skip_approver;


  PROCEDURE get_rule_details (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_object_approval_id        IN       NUMBER,
    x_rules_list                OUT NOCOPY /* file.sql.39 change */       aso_apr_pub.rules_list_tbl_type,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
 IS
    l_api_name           CONSTANT VARCHAR2 (30) := 'get_rule_details';
    l_api_version        CONSTANT NUMBER := 1.0;
    ruledescriptions              ame_util.stringlist;
    l_ruletypeout                 VARCHAR2 (240);
    l_conditionidsout             ame_util.idlist;
    l_approvaltypenameout         VARCHAR2 (240);
    l_approvaltypedescriptionout  VARCHAR2 (240);
    j                             INTEGER:=1;
    CURSOR get_rule_ids( c_obj_app_id NUMBER)
    IS
     SELECT oam_rule_id,rule_id
     FROM   aso_apr_rules
     WHERE  object_approval_id = c_obj_app_id;


 BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of get_rule_details',
        1,
        'N'
      );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    FOR i IN get_rule_ids(p_object_approval_id)
    LOOP
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Calling AME get applicable rules procedure',
          1,
          'N'
        );
         aso_debug_pub.ADD (
          'Object_approval_id'||p_object_approval_id,
          1,
          'N'
        );

	 END IF;
      ame_api.getruledetails1 (
        ruleidin                     => i.oam_rule_id,
        ruletypeout                  => l_ruletypeout,
        ruledescriptionout           => x_rules_list (
                                          j
                                        ).rule_description,
        conditionidsout              => l_conditionidsout,
        approvaltypenameout          => l_approvaltypenameout,
        approvaltypedescriptionout   => l_approvaltypedescriptionout,
        approvaldescriptionout       => x_rules_list (
                                          j
                                        ).approval_level
        );

    x_rules_list(j).rule_id := i.rule_id;
    j:= j+1;

    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of get_rule_details',
        1,
        'N'
      );
    END IF;




 EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END get_rule_details;

  PROCEDURE start_approval_workflow (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    P_Object_approval_id        IN       NUMBER,
    P_itemtype                  IN       VARCHAR2,
    P_sender_name               IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  )
 IS

    l_api_name           CONSTANT VARCHAR2 (30) := 'start_approval_workflow';
    l_api_version        CONSTANT NUMBER := 1.0;

 BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of start_approval_workflow',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Approval ID : ' || P_Object_approval_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemType : ' || P_itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Sender name : ' || P_sender_name,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Commit Flag : ' || p_commit,
        1,
        'N'
      );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version_number,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- Check to see if required parameters are passed
     IF ((P_Object_approval_id IS NULL) OR (P_Object_approval_id = FND_API.G_MISS_NUM)) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'P_Object_approval_id', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Object_approval_id ) , FALSE );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     ELSIF ((P_itemtype IS NULL) OR (P_itemtype = FND_API.G_MISS_CHAR)) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'P_Object_approval_id', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Object_approval_id ) , FALSE );
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;

   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling procedure aso_apr_wf_pvt.start_aso_approvals',
        1,
        'N'
      );
    END IF;

   aso_apr_wf_pvt.start_aso_approvals (
    P_Object_approval_id,
    P_itemtype,
    P_sender_name);


   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'After Calling procedure aso_apr_wf_pvt.start_aso_approvals',
        1,
        'N'
      );
    END IF;


    -- Commit the work

    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Committing the work in  start_approval_workflow ',
          1,
          'N'
        );
      END IF;
      COMMIT WORK;
    END IF;

   fnd_msg_pub.count_and_get(p_encoded => 'F',
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   for k in 1..x_msg_count loop
    x_msg_data := fnd_msg_pub.get(p_msg_index => k,
                                  p_encoded   => 'F');
   end loop;



    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  start_approval_workflow  procedure ',
        1,
        'N'
      );
    END IF;


 EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END start_approval_workflow;


  PROCEDURE upd_status_self_appr
  ( p_qte_hdr_id                IN             NUMBER,
    p_obj_ver_num               IN             NUMBER,
    p_last_update_date          IN             DATE,
    x_obj_ver_num               OUT NOCOPY     NUMBER,
    x_last_update_date          OUT NOCOPY     DATE,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
  )
IS

    l_api_name                  CONSTANT VARCHAR2 (240) := 'upd_status_self_appr';
    l_last_update_date          DATE;
    l_object_version_number     NUMBER;
    l_status_id                 NUMBER;

   cursor c_get_qte_info ( l_qte_hdr_id  number) is
    select last_update_date,object_version_number
    from aso_quote_headers_all
    where quote_header_id = l_qte_hdr_id;

    CURSOR C_Get_Status IS
    SELECT Quote_Status_Id
    FROM ASO_QUOTE_STATUSES_B
    WHERE Status_Code = 'APPROVAL PENDING';

BEGIN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('upd_status_self_appr: BEGIN ', 1, 'Y');
    END IF;

    --  Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    SAVEPOINT upd_status_self_appr_int;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('upd_status_self_appr: p_qte_hdr_id:       '|| p_qte_hdr_id , 1, 'Y');
       aso_debug_pub.add('upd_status_self_appr: p_obj_ver_num:       || p_obj_ver_num ', 1, 'Y');
       aso_debug_pub.add('upd_status_self_appr: p_last_update_date:  || p_last_update_date ', 1, 'Y');
    END IF;

      Open c_get_qte_info(p_qte_hdr_id);
      Fetch c_get_qte_info into l_LAST_UPDATE_DATE,l_object_version_number;
      If ( c_get_qte_info%NOTFOUND) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_UPDATE_TARGET');
              FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
              FND_MSG_PUB.Add;
          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;
      Close c_get_qte_info;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('upd_status_self_appr: l_LAST_UPDATE_DATE:      '|| l_LAST_UPDATE_DATE, 1, 'Y');
          aso_debug_pub.add('upd_status_self_appr: l_object_version_number: '|| l_object_version_number,1,'Y');
      END IF;

      If (l_last_update_date is NULL or l_last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If ( (l_last_update_date <> p_last_update_date ) OR (l_object_version_number <> p_obj_ver_num ) ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

     OPEN C_Get_Status;
     FETCH C_Get_Status into l_status_id;
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('upd_status_self_appr: l_status_id:      '|| l_status_id, 1, 'Y');
      END IF;

     CLOSE C_Get_Status;
    -- set the out variables
     x_last_update_date := sysdate;
     x_obj_ver_num := l_object_version_number + 1;

     -- update the quote status to approval pending
    update aso_quote_headers_all
    set    quote_status_id       = l_status_id,
           object_version_number = x_obj_ver_num,
           last_update_date      = x_last_update_date
    where  quote_header_id = p_qte_hdr_id;


   fnd_msg_pub.count_and_get(p_encoded => 'F',
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   for k in 1..x_msg_count loop
    x_msg_data := fnd_msg_pub.get(p_msg_index => k,
                                  p_encoded   => 'F');
   end loop;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('upd_status_self_appr: END ', 1, 'Y');
    END IF;

EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
END upd_status_self_appr;


END aso_apr_int;

/
