--------------------------------------------------------
--  DDL for Package Body ASO_APR_RESOURCE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_RESOURCE_HANDLER" AS
  /*  $Header: asoiarhb.pls 120.1 2005/06/29 12:32:21 appldev ship $   */
  g_last_approver_group_id      NUMBER := 0;
  g_approval_type_id            INTEGER := 0;

  FUNCTION get_manager (
    p_group_id                  IN       NUMBER
  )
    RETURN NUMBER IS

  /*
    Logic has been commented OUT as per bug 3405904



    l_manager_resource_id         NUMBER;
    l_unique_role_code            VARCHAR2 (240);

    CURSOR get_manager (
      c_group_id                           NUMBER
    ) IS
      SELECT parent_resource_id
      FROM jtf_rs_rep_managers mgr, jtf_rs_group_usages u
      WHERE u.usage = 'SALES'
            AND u.GROUP_ID = mgr.GROUP_ID
            AND resource_id = parent_resource_id
            AND par_role_relate_id = child_role_relate_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                )
            AND mgr.GROUP_ID = c_group_id
            AND hierarchy_type IN ('MGR_TO_MGR');

    CURSOR get_manager_with_role (
      c_group_id                           NUMBER,
      c_role_code                          VARCHAR2
    ) IS
      SELECT mgr.parent_resource_id
      FROM jtf_rs_rep_managers mgr,
           jtf_rs_group_usages u,
           jtf_rs_role_relations rel,
           jtf_rs_roles_b rol
      WHERE u.usage = 'SALES'
            AND u.GROUP_ID = mgr.GROUP_ID
            AND mgr.resource_id = mgr.parent_resource_id
            AND par_role_relate_id = child_role_relate_id
            AND SYSDATE BETWEEN mgr.start_date_active
                            AND NVL (
                                  mgr.end_date_active,
                                  SYSDATE
                                )
            AND mgr.GROUP_ID = c_group_id
            AND hierarchy_type IN ('MGR_TO_MGR')
            AND rol.role_id = rel.role_id
            AND rol.role_code = c_role_code
            AND rel.role_resource_type = 'RS_INDIVIDUAL'
            AND rel.role_resource_id = mgr.parent_resource_id
            AND SYSDATE BETWEEN rel.start_date_active
                            AND NVL (
                                  rel.end_date_active,
                                  SYSDATE
                                )
            AND delete_flag <> 'Y';

   */

  BEGIN
  NULL;

  /*
  Logic has been commented OUT as per bug 3405904



   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of Get_Manager',
        1,
        'N'
      );
    END IF;

    FOR i IN get_manager (
               p_group_id
             )
    LOOP
      l_manager_resource_id  := i.parent_resource_id;

      -- If there are more than one managers in the group
      IF ((get_manager%ROWCOUNT) > 1)
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Get_Manager: More than one manager in group : ' || p_group_id,
            1,
            'N'
          );
        END IF;
        -- get the unique role code used to identify the correct manager
        l_unique_role_code  :=
          ame_engine.getattributevaluebyname (
            attributenamein              => 'UNIQUE_APPROVER_IDENTIFICATION_ROLE_CODE'
          );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Get_Manager: Unique Role Code : ' || l_unique_role_code,
            1,
            'N'
          );
        END IF;

        IF l_unique_role_code IS NOT NULL
        THEN
          -- get the manger with that role code
          OPEN get_manager_with_role (
            p_group_id,
            l_unique_role_code
          );
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Get_Manager: Trying to get manager with the unique role code',
              1,
              'N'
            );
          END IF;
          FETCH get_manager_with_role INTO l_manager_resource_id;
          CLOSE get_manager_with_role;
        END IF;

        EXIT;
      END IF;
    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Get_Manager: Manager Resource ID : ' || l_manager_resource_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'End of Get_Manager',
        1,
        'N'
      );
    END IF;
    RETURN l_manager_resource_id;

    */
    RETURN NULL;
  END get_manager;

  FUNCTION check_approver_exists (
    p_approver_user_id          IN       NUMBER
  )
    RETURN BOOLEAN IS
  BEGIN

  null;

  /*
  Logic has been commented OUT as per bug 3405904




    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of check_approver_exists',
        1,
        'N'
      );
    END IF;

    FOR i IN 1 .. ame_engine.tempapproverlist.COUNT
    LOOP
      IF (ame_engine.tempapproverlist (
            i
          ).user_id = p_approver_user_id
         )
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'check_approver_exists : Approver Exists in list',
            1,
            'N'
          );
        END IF;
        RETURN (TRUE );
      END IF;
    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'check_approver_exists : Approver does not Exists in list',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'End of check_approver_exists',
        1,
        'N'
      );
    END IF;
    RETURN (FALSE );
    */
   RETURN NULL;
  END check_approver_exists;

  PROCEDURE getfirstapprover (
    approvaltypeidin            IN       INTEGER,
    parametersin                IN       VARCHAR2,
                                         /* parametersIn not used, IN this case */
    sourceruleidlistin          IN       VARCHAR2,
    firstapproverout            OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) AS

      /*
     has been commented OUT as per bug 3405904


    approver                      ame_util.approverrecord;
    errorcode                     INTEGER;
    errormessage                  VARCHAR2 (2000);
    nvl_user_or_groupid           EXCEPTION;
    nvlusrperidexception          EXCEPTION;
    requester_res_id_not_found    EXCEPTION;
    no_parent_group_found         EXCEPTION;
    unending_loop                 EXCEPTION;
    l_user_id                     NUMBER;
    l_resource_id                 NUMBER;
    l_manager_resource_id         NUMBER := 0;
    l_resource_name               VARCHAR2 (240);
    l_group_name                  VARCHAR2 (240);
    l_user_name                   VARCHAR2 (240);
    l_parent_group_id             NUMBER;
    l_loop_counter                NUMBER := 0;

    CURSOR get_user_resource_id (
      c_user_id                            NUMBER
    ) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_user_id (
      c_manager_resource_id                NUMBER
    ) IS
      SELECT user_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_manager_resource_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_person_id (
      c_manager_resource_id                NUMBER
    ) IS
      SELECT source_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_manager_resource_id
            AND CATEGORY = 'EMPLOYEE'
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_resource_name (
      c_resource_id                        NUMBER
    ) IS
      SELECT resource_name
      FROM jtf_rs_resource_extns_vl
      WHERE resource_id = c_resource_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_group_name (
      c_group_id                           NUMBER
    ) IS
      SELECT group_name
      FROM jtf_rs_groups_tl
      WHERE GROUP_ID = c_group_id
            AND LANGUAGE = USERENV (
                             'LANG'
                           );

    CURSOR get_user_name (
      c_user_id                            NUMBER
    ) IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date AND NVL (
                                                 end_date,
                                                 SYSDATE
                                               );

    CURSOR get_parent_group_id (
      c_group_id                           NUMBER
    ) IS
      SELECT grp.parent_group_id
      FROM jtf_rs_groups_denorm grp, jtf_rs_group_usages u
      WHERE u.usage = 'SALES'
            AND u.GROUP_ID = grp.GROUP_ID
            AND grp.GROUP_ID = c_group_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                )
            AND grp.immediate_parent_flag = 'Y';

    */


  BEGIN
  NULL;

  /*
  Logic has been commented OUT as per bug 3405904




    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin getFirstApprover PROCEDURE ',
        1,
        'N'
      );
    END IF;
    -- get the user id AND group id  FROM the atrributes

    l_user_id                   :=
      TO_NUMBER (
        ame_engine.getattributevaluebyname (
          attributenamein              => ame_util.transactionrequserattribute
        )
      );
    g_last_approver_group_id    :=
      TO_NUMBER (
        ame_engine.getattributevaluebyname (
          attributenamein              => 'TRANSACTION_REQUESTOR_GROUP_ID'
        )
      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'getFirstApprover : Requester UserID IS : ' || l_user_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'getFirstApprover : Requester GroupID IS : ' || g_last_approver_group_id,
        1,
        'N'
      );
    END IF;

    --  Check IF the values fetched FROM attributes exists or not
    IF ((l_user_id IS NULL)
        OR (g_last_approver_group_id IS NULL)
       )
    THEN
      RAISE nvl_user_or_groupid;
    END IF;

    -- get the resource id based upon the user id
    OPEN get_user_resource_id (
      l_user_id
    );
    FETCH get_user_resource_id INTO l_resource_id;
    CLOSE get_user_resource_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'getFirstApprover : Requester ResourceID IS : ' || l_resource_id,
        1,
        'N'
      );
    END IF;

    IF l_resource_id IS NULL
    THEN
      RAISE requester_res_id_not_found;
    END IF;

    -- Initialize the approver record
    approver.person_id          := NULL;
    approver.user_id            := NULL;
    approver.first_name         := NULL;
    approver.last_name          := NULL;
    approver.authority          := ame_util.authorityapprover;
    approver.api_insertion      := ame_util.oamgenerated;
    approver.approval_status    := ame_util.exceptionstatus;
    -- approver.approval_type_id := G_APPROVAL_TYPE_ID;
    approver.approval_type_id   := 0;
    approver.group_or_chain_id  := 1;
    approver.occurrence         := NULL;
    approver.SOURCE             := NULL;
    -- call the function to get the manager
    l_manager_resource_id       :=
                   aso_apr_resource_handler.get_manager (
                     g_last_approver_group_id
                   );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'getFirstApprover : Manager ResourceID IS : ' || l_manager_resource_id,
        1,
        'N'
      );
    END IF;

    IF (l_resource_id = l_manager_resource_id)
       OR (l_manager_resource_id IS NULL)
    THEN
      WHILE TRUE
      LOOP
        -- this means  that the resource IS a manager
        -- get the manager of the parent group for first approver

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'getFirstApprover : Resource IS a manager',
            1,
            'N'
          );
        END IF;
        -- get the parent group
        OPEN get_parent_group_id (
          g_last_approver_group_id
        );
        FETCH get_parent_group_id INTO l_parent_group_id;

        IF (get_parent_group_id%ROWCOUNT = 0)
        THEN -- No Parent Group Found
          CLOSE get_parent_group_id;
          RAISE no_parent_group_found;
        END IF;

        CLOSE get_parent_group_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'getFirstApprover : Parent GroupId IS : ' || l_parent_group_id,
            1,
            'N'
          );
        END IF;
        -- Store the group id in a global variable
        g_last_approver_group_id  := l_parent_group_id;
        -- call the function to get the manager
        l_manager_resource_id     :=
                          aso_apr_resource_handler.get_manager (
                            l_parent_group_id
                          );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'getFirstApprover : Manager ResourceID IS : ' || l_manager_resource_id,
            1,
            'N'
          );
        END IF;

        IF (l_resource_id <> l_manager_resource_id)
           AND (l_manager_resource_id IS NOT NULL)
        THEN
          EXIT;
        END IF;

        l_loop_counter            := l_loop_counter + 1;

        IF (l_loop_counter > 20)
        THEN
          RAISE unending_loop;
        END IF;
      END LOOP;
    END IF;

    -- get the user id FROM the resource id
    OPEN get_user_id (
      l_manager_resource_id
    );
    FETCH get_user_id INTO approver.user_id;
    CLOSE get_user_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'getFirstApprover : Manager UserID IS : ' || approver.user_id,
        1,
        'N'
      );
    END IF;
    OPEN get_person_id (
      l_manager_resource_id
    );
    FETCH get_person_id INTO approver.person_id;
    CLOSE get_person_id;

    -- IF both are null, we can not proceed
    IF (approver.person_id IS NULL
        AND approver.user_id IS NULL
       )
    THEN
      RAISE nvlusrperidexception;
    END IF;

     -- Set the approval status to null for the approver record
    -- approver.approval_status := null;
    approver.occurrence         :=
            ame_engine.getnextapproveroccurrence (
              approverin                   => approver,
              excludeapproverindexin       => NULL
            );
    approver.SOURCE             := sourceruleidlistin;
    approver.approval_status    :=
                          ame_engine.getoldapproverstatus (
                            approverin                   => approver
                          );
    -- convert Approver Record FROM PL/SQL record format to comma seperated format

    firstapproverout            :=
                   ame_util.serializeapproverrecord (
                     approverrecordin             => approver
                   );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END  getFirstApprover PROCEDURE ',
        1,
        'N'
      );
    END IF;



  EXCEPTION

  WHEN nvl_user_or_groupid
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover: Exception nvl_user_or_groupid raised in getFirstApprover procedure ',
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'getFirstApprover: user_id : ' || l_user_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'getFirstApprover: group_id : ' || g_last_approver_group_id,
          1,
          'N'
        );
      END IF;
      errorcode         := -20001;
      errormessage      :=
            'This transaction''s requestor does not have a user id or group id';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN nvlusrperidexception
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover: Exception  nvlusrperIdException  raised in getFirstApprover procedure ',
          1,
          'N'
        );
      END IF;
      OPEN get_resource_name (
        l_manager_resource_id
      );
      FETCH get_resource_name INTO l_resource_name;
      CLOSE get_resource_name;
      errorcode         := -20002;
      errormessage      := 'The resource:  '
                           || l_resource_name
                           || ' does not have a user id AND person id.'
                           || ' Unable to traverse heirarchy for this resource ';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN requester_res_id_not_found
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover : Exception   requester_res_id_not_found  raised in getFirstApprover procedure ',
          1,
          'N'
        );
      END IF;
      OPEN get_user_name (
        l_user_id
      );
      FETCH get_user_name INTO l_user_name;
      CLOSE get_user_name;
      errorcode         := -20003;
      errormessage      := 'The transaction''s requester ( username =  '
                           || l_user_name
                           || ' ) does not have a resource id.'
                           || ' Unable to traverse heirarchy for this resource ';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN no_parent_group_found
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover : Exception   no_parent_group_found  raised in getFirstApprover procedure ',
          1,
          'N'
        );
      END IF;
      OPEN get_group_name (
        g_last_approver_group_id
      );
      FETCH get_group_name INTO l_group_name;
      CLOSE get_group_name;
      errorcode         := -20004;
      errormessage      := 'Cannot find parent group for group:   '
                           || l_group_name;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN unending_loop
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover : Exception Unending_Loop  raised in getFirstApprover procedure ',
          1,
          'N'
        );
      END IF;
      errorcode         := -20005;
      errormessage      := 'Please check the group heirarchy';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getFirstApprover : Exception   WHEN others  raised in getFirstApprover procedure ',
          1,
          'N'
        );
      END IF;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getFirstApprover',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      firstapproverout  :=
                  ame_util.serializeapproverrecord (
                    approverrecordin             => approver
                  );
      raise_application_error (
        errorcode,
        errormessage
      );

   */

  END getfirstapprover;

  PROCEDURE getnextapprover (
    approvaltypeidin            IN       INTEGER,
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
                              /* not used IN this case, but a required argument */
    sourceruleidlistin          IN       VARCHAR2,
    nextapproverout             OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS

  /*
   Has been commented OUT as per bug 3405904



    nextapprover                  ame_util.approverrecord;
    errorcode                     INTEGER;
    errormessage                  VARCHAR2 (2000);
    nvlusrperidexception          EXCEPTION;
    no_parent_group_found         EXCEPTION;
    unending_loop                 EXCEPTION;
    l_user_id                     NUMBER;
    l_resource_id                 NUMBER;
    l_manager_resource_id         NUMBER;
    l_parent_group_id             NUMBER;
    l_resource_name               VARCHAR2 (240);
    l_group_name                  VARCHAR2 (240);
    l_user_name                   VARCHAR2 (240);
    l_loop_counter                NUMBER := 0;

    CURSOR get_user_resource_id (
      c_user_id                            NUMBER
    ) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_person_resource_id (
      c_person_id                          NUMBER
    ) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE source_id = c_person_id
            AND CATEGORY = 'EMPLOYEE'
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_user_id (
      c_manager_resource_id                NUMBER
    ) IS
      SELECT user_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_manager_resource_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_person_id (
      c_manager_resource_id                NUMBER
    ) IS
      SELECT source_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_manager_resource_id
            AND CATEGORY = 'EMPLOYEE'
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_parent_group_id (
      c_group_id                           NUMBER
    ) IS
      SELECT grp.parent_group_id
      FROM jtf_rs_groups_denorm grp, jtf_rs_group_usages u
      WHERE u.usage = 'SALES'
            AND u.GROUP_ID = grp.GROUP_ID
            AND grp.GROUP_ID = c_group_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                )
            AND grp.immediate_parent_flag = 'Y';

    CURSOR get_resource_name (
      c_resource_id                        NUMBER
    ) IS
      SELECT resource_name
      FROM jtf_rs_resource_extns_vl
      WHERE resource_id = c_resource_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_group_name (
      c_group_id                           NUMBER
    ) IS
      SELECT group_name
      FROM jtf_rs_groups_tl
      WHERE GROUP_ID = c_group_id
            AND LANGUAGE = USERENV (
                             'LANG'
                           );

    CURSOR get_user_name (
      c_user_id                            NUMBER
    ) IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date AND NVL (
                                                 end_date,
                                                 SYSDATE
                                               );
  */

  BEGIN

  NULL;

  /*
  Logic has been commented OUT as per bug 3405904



   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        ' Begin getNextApprover',
        1,
        'N'
      );
    END IF;
    -- Intialize the rest of the columns for the next approver
    nextapprover.person_id          := NULL;
    nextapprover.user_id            := NULL;
    nextapprover.first_name         := NULL;
    nextapprover.last_name          := NULL;
    nextapprover.authority          := ame_util.authorityapprover;
    nextapprover.api_insertion      := ame_util.oamgenerated;
    nextapprover.approval_status    := ame_util.exceptionstatus;

    IF approvaltypeidin IS NULL
    THEN
      nextapprover.approval_type_id  := 0;
    ELSE
      nextapprover.approval_type_id  := approvaltypeidin;
    END IF;

    nextapprover.group_or_chain_id  := 1;
    nextapprover.occurrence         := NULL;
    nextapprover.SOURCE             := NULL;

    WHILE TRUE
    LOOP
      OPEN get_parent_group_id (
        g_last_approver_group_id
      );
      FETCH get_parent_group_id INTO l_parent_group_id;

      IF (get_parent_group_id%ROWCOUNT = 0)
      THEN -- No Parent Group Found
        CLOSE get_parent_group_id;
        RAISE no_parent_group_found;
      END IF;

      CLOSE get_parent_group_id;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getNextApprover : Parent GroupId IS : ' || l_parent_group_id,
          1,
          'N'
        );
      END IF;
      -- Store the group id in a global variable
      g_last_approver_group_id  := l_parent_group_id;
      -- call the function to get the manager
      l_manager_resource_id     :=
                          aso_apr_resource_handler.get_manager (
                            l_parent_group_id
                          );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'getNextApprover : Manager ResourceID IS : ' || l_manager_resource_id,
          1,
          'N'
        );
      END IF;

      IF (l_manager_resource_id IS NOT NULL)
      THEN
        -- get the user id FROM the resource id
        OPEN get_user_id (
          l_manager_resource_id
        );
        FETCH get_user_id INTO nextapprover.user_id;
        CLOSE get_user_id;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'getNextApprover : Manager UserID IS : ' || nextapprover.user_id,
            1,
            'N'
          );
        END IF;

        -- Check to see if the approver already exists
        IF (check_approver_exists (
              nextapprover.user_id
            ) = FALSE
           )
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'getNextApprover : Approver does not exists in the list',
              1,
              'N'
            );
          END IF;
          EXIT;
        END IF;
      END IF; -- No Manager Found Condition
      l_loop_counter            := l_loop_counter + 1;

      IF (l_loop_counter > 20)
      THEN
        RAISE unending_loop;
      END IF;
    END LOOP;

    OPEN get_person_id (
      l_manager_resource_id
    );
    FETCH get_person_id INTO nextapprover.person_id;
    CLOSE get_person_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'getNextApprover : Manager PersonId IS : ' || nextapprover.person_id,
        1,
        'N'
      );
    END IF;

    -- IF both are null; we can not proceed
    IF (nextapprover.person_id IS NULL
        AND nextapprover.user_id IS NULL
       )
    THEN
      RAISE nvlusrperidexception;
    END IF;

     -- Intialize approval status for the next approver
    -- nextApprover.approval_status := null;
    nextapprover.occurrence         :=
            ame_engine.getnextapproveroccurrence (
              approverin                   => nextapprover,
              excludeapproverindexin       => NULL
            );
    nextapprover.SOURCE             := sourceruleidlistin;
    nextapprover.approval_status    :=
                      ame_engine.getoldapproverstatus (
                        approverin                   => nextapprover
                      );
    -- Convert the nextapprover record FROM PL/SQL Record to flat structure
    nextapproverout                 :=
               ame_util.serializeapproverrecord (
                 approverrecordin             => nextapprover
               );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END getNextApprover',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN nvlusrperidexception
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  nvlusrperIdException  raised in  getNextApprover procedure',
          1,
          'N'
        );
      END IF;
      OPEN get_resource_name (
        l_manager_resource_id
      );
      FETCH get_resource_name INTO l_resource_name;
      CLOSE get_resource_name;
      errorcode        := -20001;
      errormessage     := 'The resource :'
                          || l_resource_name
                          || ' does not have a user id AND person id.'
                          || ' Unable to traverse heirarchy for this resource ';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getNextApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      nextapproverout  :=
              ame_util.serializeapproverrecord (
                approverrecordin             => nextapprover
              );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN no_parent_group_found
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception   no_parent_group_found  raised in getNextApprover procedure ',
          1,
          'N'
        );
      END IF;
      OPEN get_group_name (
        g_last_approver_group_id
      );
      FETCH get_group_name INTO l_group_name;
      CLOSE get_group_name;
      errorcode        := -20001;
      errormessage     := 'Cannot find parent group for group:   '
                          || l_group_name;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getNextApprover',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      nextapproverout  :=
              ame_util.serializeapproverrecord (
                approverrecordin             => nextapprover
              );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN unending_loop
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception Unending_Loop  raised in getNextApprover procedure ',
          1,
          'N'
        );
      END IF;
      errorcode        := -20003;
      errormessage     := 'Please check the group heirarchy';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getNextApprover',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      nextapproverout  :=
              ame_util.serializeapproverrecord (
                approverrecordin             => nextapprover
              );
      raise_application_error (
        errorcode,
        errormessage
      );
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception   WHEN others  raised in  getNextApprover procedure ',
          1,
          'N'
        );
      END IF;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getNextApprover',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      nextapproverout  :=
              ame_util.serializeapproverrecord (
                approverrecordin             => nextapprover
              );
      raise_application_error (
        errorcode,
        errormessage
      );
    */

  END getnextapprover;

  PROCEDURE getsurrogate (
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
    surrogateout                OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) AS
 --   surrogate                     ame_util.approverrecord;
 --   approver                      ame_util.approverrecord;
  BEGIN

  NULL;
  /*
  Logic has been commented OUT as per bug 3405904


    ame_util.deserializeapproverrecord (
      approverrecordin             => approverin,
      approverrecordout            => approver
    );
    getnextapprover (
      approvaltypeidin             => approver.approval_type_id,
      approverin                   => approverin,
      parametersin                 => parametersin,
      sourceruleidlistin           => approver.SOURCE,
      nextapproverout              => surrogateout
    );
  EXCEPTION
    WHEN OTHERS
    THEN
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'getSurrogate',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      surrogate.person_id          := NULL;
      surrogate.user_id            := NULL;
      surrogate.first_name         := NULL;
      surrogate.last_name          := NULL;
      surrogate.authority          := ame_util.authorityapprover;
      surrogate.api_insertion      := ame_util.oamgenerated;
      surrogate.approval_status    := ame_util.exceptionstatus;
      surrogate.approval_type_id   := approver.approval_type_id;
      surrogate.group_or_chain_id  := approver.group_or_chain_id;
      surrogate.occurrence         := NULL;
      surrogate.SOURCE             := NULL;
      surrogateout                 :=
                 ame_util.serializeapproverrecord (
                   approverrecordin             => surrogate
                 );
      RAISE;
  */

  END getsurrogate;

  PROCEDURE hasfinalauthority (
    approverin                  IN       VARCHAR2,
    parametersin                IN       VARCHAR2,
    hasfinalauthorityynout      OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) AS

    /*
    badparameterexception         EXCEPTION;
    no_resource_id_for_usr_id     EXCEPTION;
    no_resource_id_for_per_id     EXCEPTION;
    deserializedapproverin        ame_util.approverrecord;
    errorcode                     INTEGER;
    errormessage                  VARCHAR2 (2000);
    PARAMETERS                    ame_util.parameterstable;
    parametercount                INTEGER;
    l_role_code                   VARCHAR2 (240);
    l_level                       NUMBER := 0;
    l_temp_role_code              VARCHAR2 (240);
    l_temp_level                  NUMBER := 0;
    l_coloncount                  NUMBER := 0;
    l_resource_id                 NUMBER;
    l_role_exist                  NUMBER;
    l_subordinate_role_exists     NUMBER;
    l_user_name                   VARCHAR2 (240);

    CURSOR get_user_resource_id (
      c_user_id                            NUMBER
    ) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR get_person_resource_id (
      c_person_id                          NUMBER
    ) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE source_id = c_person_id
            AND CATEGORY = 'EMPLOYEE'
            AND SYSDATE BETWEEN start_date_active
                            AND NVL (
                                  end_date_active,
                                  SYSDATE
                                );

    CURSOR check_role (
      c_resource_id                        NUMBER,
      c_role_code                          VARCHAR2
    ) IS
      SELECT COUNT (
               *
             )
      FROM jtf_rs_role_relations rel, jtf_rs_roles_b rol
      WHERE rol.role_id = rel.role_id
            AND rol.role_code = c_role_code
            AND rel.role_resource_type = 'RS_INDIVIDUAL'
            AND rel.role_resource_id = c_resource_id
            AND SYSDATE BETWEEN rel.start_date_active
                            AND NVL (
                                  rel.end_date_active,
                                  SYSDATE
                                )
            AND delete_flag <> 'Y';

    CURSOR check_subordinates_role (
      c_role_code                          VARCHAR2,
      c_resource_id                        NUMBER
    ) IS

	*/
	 --SELECT /*+  ordered */ COUNT (*)
      /*
	 FROM jtf_rs_rep_managers mgr,
           jtf_rs_group_usages u,
           jtf_rs_role_relations rel,
           jtf_rs_roles_b rol
      WHERE u.usage = 'SALES'
            AND u.GROUP_ID = mgr.GROUP_ID
            AND SYSDATE BETWEEN rel.start_date_active
                            AND NVL ( rel.end_date_active, SYSDATE)
            AND delete_flag <> 'Y'
            AND rol.role_id = rel.role_id
            AND rol.role_code = c_role_code
            AND rel.role_resource_type = 'RS_INDIVIDUAL'
            AND rel.role_resource_id = mgr.resource_id
            AND SYSDATE BETWEEN mgr.start_date_active
                            AND NVL ( mgr.end_date_active, SYSDATE)
            AND mgr.parent_resource_id = c_resource_id
            AND mgr.hierarchy_type = 'MGR_TO_MGR';

    CURSOR get_user_name (
      c_user_id                            NUMBER
    ) IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = c_user_id
            AND SYSDATE BETWEEN start_date AND NVL (
                                                 end_date,
                                                 SYSDATE
                                               );
   */

  BEGIN

  NULL;

    /*
  Logic has been commented OUT as per bug 3405904



    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin hasFinalAuthority',
        1,
        'N'
      );
    END IF;
    -- convert the approver record FROM flat data structure to PL/SQL Record

    ame_util.deserializeapproverrecord (
      approverrecordin             => approverin,
      approverrecordout            => deserializedapproverin
    );
    ame_util.deserializeparameterstable (
      parameterstablein            => parametersin,
      parameterstableout           => PARAMETERS
    );
    g_approval_type_id  := deserializedapproverin.approval_type_id;

   --The action parameters for jtf resource handler are of the form
   --<role code>:<level>where role id IS the resource role to look for
   --WHERE <level> IS a positive INTEGER, identifies authority level
    -- Find higher authority role code
    parametercount      := PARAMETERS.COUNT;

    FOR i IN 1 .. parametercount
    LOOP
      l_coloncount  := INSTR (
                         PARAMETERS (
                           i
                         ),
                         ':',
                         1,
                         1
                       );
      l_role_code   := SUBSTR (
                         PARAMETERS (
                           i
                         ),
                         1,
                         l_coloncount - 1
                       );
      l_level       := TO_NUMBER (
                         SUBSTR (
                           PARAMETERS (
                             i
                           ),
                           l_coloncount + 1
                         )
                       );

      IF ((l_coloncount = 0)
          OR (l_role_code IS NULL)
          OR (l_level = 0)
         )
      THEN
        RAISE badparameterexception;
      END IF;

      IF (l_level > l_temp_level)
      THEN
        l_temp_level      := l_level;
        l_temp_role_code  := l_role_code;
      END IF;
    END LOOP; -- End of Parameter extraction Loop
    -- get the resource id based upon the user id

    OPEN get_user_resource_id (
      deserializedapproverin.user_id
    );
    FETCH get_user_resource_id INTO l_resource_id;
    CLOSE get_user_resource_id;

    -- Check IF the resource id IS null
    IF l_resource_id IS NULL
    THEN
      RAISE no_resource_id_for_usr_id;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'hasFinalAuthority : Resource ID IS : ' || l_resource_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'hasFinalAuthority : Role Code IS : ' || l_temp_role_code,
        1,
        'N'
      );
    END IF;
    -- Check whether the apporverin has the highest authoriy role ?

    OPEN check_role (
      l_resource_id,
      l_temp_role_code
    );
    FETCH check_role INTO l_role_exist;
    CLOSE check_role;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'hasFinalAuthority : Role Exists : ' || l_role_exist,
        1,
        'N'
      );
    END IF;

    IF (l_role_exist > 0)
    THEN
      hasfinalauthorityynout  := ame_util.booleantrue;
    ELSE
      --  Checking to see IF one of the subordinates has this role, IF so, honour it
      IF (ame_engine.tempapproverlist.COUNT = 0)
      THEN -- Only first time we check
        OPEN check_subordinates_role (
          l_temp_role_code,
          l_resource_id
        );
        FETCH check_subordinates_role INTO l_subordinate_role_exists;
        CLOSE check_subordinates_role;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Subordinate Role Exists : ' || l_subordinate_role_exists,
            1,
            'N'
          );
        END IF;

        IF l_subordinate_role_exists > 0
        THEN
          hasfinalauthorityynout  := ame_util.booleantrue; -- Some subordinate has the Role
        ELSE
          hasfinalauthorityynout  := ame_util.booleanfalse; -- No subordinate has the Role
        END IF;
      ELSE
        hasfinalauthorityynout  := ame_util.booleanfalse; -- Not first time
      END IF;
    END IF; -- End if for l_role_Exist
    RETURN;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'END hasFinalAuthority',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN badparameterexception
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  badParameterException raised in  hasFinalAuthority procedure ',
          1,
          'N'
        );
      END IF;
      errorcode               := -20001;
      errormessage            := 'Parameters for approval IS wrong';
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'hasFinalAuthority',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      raise_application_error (
        errorcode,
        errormessage
      );
      hasfinalauthorityynout  := ame_util.booleanfalse;
    WHEN no_resource_id_for_usr_id
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  no_resource_id_for_usr_id raised in  hasFinalAuthority procedure ',
          1,
          'N'
        );
      END IF;
      OPEN get_user_name (
        deserializedapproverin.user_id
      );
      FETCH get_user_name INTO l_user_name;
      CLOSE get_user_name;
      errorcode               := -20002;
      errormessage            := 'Cannot get resource id for Username : '
                                 || l_user_name;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'hasFinalAuthority',
        exceptionnumberin            => errorcode,
        exceptionstringin            => errormessage,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      raise_application_error (
        errorcode,
        errormessage
      );
      hasfinalauthorityynout  := ame_util.booleanfalse;
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception  WHEN others raised in  hasFinalAuthority procedure ',
          1,
          'N'
        );
      END IF;
      ame_util.runtimeexception (
        packagenamein                => 'ASO_APR_RESOURCE_HANDLER',
        routinenamein                => 'hasFinalAuthority',
        exceptionnumberin            => SQLCODE,
        exceptionstringin            => SQLERRM,
        transactionidin              => ame_engine.temptransactionid,
        applicationidin              => ame_engine.tempameapplicationid,
        localerrorin                 => FALSE
      );
      raise_application_error (
        errorcode,
        errormessage
      );
      hasfinalauthorityynout  := ame_util.booleanfalse;

   */

  END hasfinalauthority;

  PROCEDURE isasubordinate (
    subordinatein               IN       VARCHAR2,
    supervisorin                IN       VARCHAR2,
    isasubordinateynout         OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) AS
  BEGIN

  NULL;
     /*
  Logic has been commented as per bug 3405904


    isasubordinateynout  := ame_util.booleanfalse;

  */
  END isasubordinate;
END aso_apr_resource_handler;

/
