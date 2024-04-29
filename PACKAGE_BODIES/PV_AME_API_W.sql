--------------------------------------------------------
--  DDL for Package Body PV_AME_API_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_AME_API_W" AS
/* $Header: pvapprlb.pls 120.21 2006/12/01 20:32:21 saarumug ship $*/

g_concurrent_update    EXCEPTION;
PRAGMA EXCEPTION_INIT(g_concurrent_update, -00054);

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_AME_API_W';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvapprlb.pls';

returnStatus CONSTANT VARCHAR2(10) := 'RETURN';

PROCEDURE DEL_PRIOR_REP_APPR(p_approval_entity     IN  VARCHAR2
                             , p_referral_id       IN  NUMBER
                             , p_approval_list     IN  JTF_NUMBER_TABLE);

PROCEDURE GET_APPROVERS(p_approval_entity     IN          VARCHAR2
                        ,p_referral_id        IN          NUMBER
                        ,p_mode                IN          VARCHAR2
                        ,x_approval_list      OUT  NOCOPY JTF_NUMBER_TABLE
                        ,x_approval_completed OUT  NOCOPY VARCHAR2
                        ,x_default_approver   OUT  NOCOPY VARCHAR2
                        ,x_user_id_exists     OUT  NOCOPY VARCHAR2);

FUNCTION VALIDATE_APPROVAL (p_transaction_id      IN NUMBER
                           , p_transaction_type  IN VARCHAR2
                           , p_user_id           IN NUMBER
                           , p_person_id         IN NUMBER
                           , p_mode              IN VARCHAR2
                           , p_approval_level    IN NUMBER
                           , x_approver          OUT NOCOPY ame_util.approverRecord2)
RETURN BOOLEAN;

PROCEDURE START_APPROVAL_PROCESS( p_api_version_number     IN  NUMBER
                                   , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
                                   , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
                                   , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                   , p_referral_id         IN  NUMBER
                                   , p_partner_id          IN  NUMBER   DEFAULT NULL
                                   , p_change_cntry_flag   IN  VARCHAR2  -- if ref country is changed set this to true
                                   , p_country_code        IN  VARCHAR2 -- new country code if change_country_flag is true
                                   , p_approval_entity     IN  VARCHAR2 -- PVREFFRL/PVDEALRN/PVDQMAPR
                                   , x_return_status       OUT  NOCOPY VARCHAR2
                                   , x_msg_count           OUT  NOCOPY NUMBER
                                   , x_msg_data            OUT  NOCOPY VARCHAR2
                                   ) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'START_APPROVAL_PROCESS';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

    CURSOR lc_referral_info (pc_referral_id NUMBER) IS
    SELECT partner_id ,benefit_id,benefit_type_code
    FROM pv_referrals_b
    WHERE referral_id = pc_referral_id;

    CURSOR lc_get_approver_name (pc_user_id NUMBER) IS
    SELECT source_name FROM jtf_rs_resource_extns WHERE user_id = pc_user_id;

    CURSOR lc_prior_approvers IS
    SELECT APPROVER_ID
    FROM   PV_GE_TEMP_APPROVERS
    WHERE  ARC_APPR_FOR_ENTITY_CODE = p_approval_entity
    AND    APPR_FOR_ENTITY_ID = p_referral_id;

    cursor lc_lock_approvals is
    SELECT entity_approver_id
    FROM   pv_ge_temp_approvers
    WHERE  arc_appr_for_entity_code = p_approval_entity
    AND    appr_for_entity_id = p_referral_id
    FOR    UPDATE NOWAIT;

    l_message_name     VARCHAR2(30);
    l_partner_id       NUMBER;
    l_log_params_tbl   pvx_utility_pvt.log_params_tbl_type;
    l_approver_name    varchar2(50);
    l_return_status    VARCHAR2(30);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1000);

    l_appr_usr_id                    NUMBER;
    l_isDefAppr                      BOOLEAN := false;
    l_appr_status                    VARCHAR2(30);
    l_benefit_id                     NUMBER;
    l_benefit_type_code              VARCHAR2(30);

    l_approval_completed             VARCHAR2(10);
    l_default_approver               VARCHAR2(10);

    approverUserIds                  JTF_NUMBER_TABLE;
    l_valid_users_flag               VARCHAR2(1);

BEGIN

    -- ********* Start Standard Initializations *******
    SAVEPOINT START_APPROVAL_PROCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            'PV_AME_API_W') THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
         fnd_msg_pub.initialize;
    END IF;

    x_return_status  :=  FND_API.G_RET_STS_SUCCESS;
    -- ********* End Standard Initializations *********
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_PROCEDURE
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,FALSE
                        );
    END IF;


    IF p_approval_entity not in ('PVREFFRL','PVDEALRN','PVDQMAPR') THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Invalid Approval Entity: ' || p_approval_entity);
        fnd_msg_pub.Add;
        RAISE FND_API.g_exc_error;
    END IF;

    -- This is to make sure that no other thread of execution
    -- can try to update the rows for this referrral in
    -- pv_ge_temp_approvers.
    -- Bug 4628929
    OPEN lc_lock_approvals;

    OPEN lc_referral_info(p_referral_id);
    FETCH lc_referral_info INTO l_partner_id, l_benefit_id, l_benefit_type_code;
    IF lc_referral_info%NOTFOUND THEN
        l_partner_id := p_partner_id;
        l_benefit_type_code := p_approval_entity;
    END IF;
    CLOSE lc_referral_info;


    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'After Getting partner Info..partner id:'|| l_partner_id ||
                        ' benefit type:' || l_benefit_type_code
                        );
    END IF;


    IF p_change_cntry_flag = 'Y' THEN

      OPEN lc_get_approver_name(pc_user_id => FND_GLOBAL.USER_ID);
      FETCH lc_get_approver_name INTO l_approver_name;
      CLOSE lc_get_approver_name;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'Approver name is: ' || l_approver_name);

      END IF;

      IF p_approval_entity = 'PVREFFRL' THEN
         l_message_name := 'PV_LG_REF_COUNTRY_CHANGE';
      ELSIF p_approval_entity = 'PVDEALRN' THEN
         l_message_name := 'PV_LG_DEAL_COUNTRY_CHANGE';
      END IF;

      l_log_params_tbl(1).param_name := 'COUNTRY';
      l_log_params_tbl(1).param_value := p_country_code;
      l_log_params_tbl(2).param_name := 'APPROVER';
      l_log_params_tbl(2).param_value := l_approver_name;

      update pv_referrals_b set customer_country = p_country_code where referral_id = p_referral_id;

      PVX_Utility_PVT.create_history_log(
            p_arc_history_for_entity_code => p_approval_entity,
            p_history_for_entity_id       => p_referral_id,
            p_history_category_code       => 'GENERAL',
            p_message_code                => l_message_name,
            p_partner_id                  => l_partner_id,
            p_access_level_flag           => 'V',
            p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_10,
            p_comments                    => NULL,
            p_log_params_tbl              => l_log_params_tbl,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);

   END IF;

   AME_API2.clearAllApprovals(applicationIdIn  => 691,
                             transactionTypeIn => p_approval_entity,
                             transactionIdIn   => p_referral_id);

   UPDATE pv_ge_temp_approvers
   SET    approval_status_code = 'PRIOR_APPROVER'
   WHERE  arc_appr_for_entity_code = p_approval_entity
   AND    appr_for_entity_id  = p_referral_id;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'B4 GET_APPROVERS....'
                        );
   END IF;

   approverUserIds := JTF_NUMBER_TABLE();

   GET_APPROVERS(p_approval_entity     => p_approval_entity
                 ,p_referral_id        => p_referral_id
                 ,p_mode               => 'START'
                 ,x_approval_list      => approverUserIds
                 ,x_approval_completed => l_approval_completed
                 ,x_default_approver   => l_default_approver
                 ,x_user_id_exists     => l_valid_users_flag
                 );

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'After GET_APPROVERS:l_approval_completed ' || l_approval_completed ||
                         ' l_default_approver ' || l_default_approver
                        );
   END IF;


   /**
   * This loop makes sure that if an approver from AME already exists in pv_ge_temp_approvers
   * then that approver must be removed from pv_ge_temp_approvers so that he/she is not added
   * again into the table.
   */
   FOR l_prior_appr IN lc_prior_approvers
   LOOP
       FOR x IN 1..approverUserIds.COUNT
       LOOP
           IF ( approverUserIds(x) = l_prior_appr.APPROVER_ID) THEN
               DELETE FROM pv_ge_temp_approvers
               WHERE  arc_appr_for_entity_code = p_approval_entity
               AND    appr_for_entity_id  = p_referral_id
               AND    approver_id = approverUserIds(x);
           END IF;
       END LOOP;
   END LOOP;

   IF l_default_approver = 'Y' THEN
       l_appr_status := 'PENDING_DEFAULT';

       IF approverUserIds(1) IS NULL THEN
           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
           fnd_message.Set_Token('TEXT', 'Could not find approver in either AME or profile');
           fnd_msg_pub.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
   ELSE
      l_appr_status := 'PENDING_APPROVAL';
   END IF;

   BEGIN
       FORALL i IN 1..approverUserIds.COUNT
          INSERT INTO pv_ge_temp_approvers
          (
           ENTITY_APPROVER_ID
           ,OBJECT_VERSION_NUMBER
           ,ARC_APPR_FOR_ENTITY_CODE
           ,APPR_FOR_ENTITY_ID
           ,APPROVER_ID
           ,APPROVER_TYPE_CODE
           ,APPROVAL_STATUS_CODE
           ,WORKFLOW_ITEM_KEY
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
          )
           VALUES
          (
           pv_ge_temp_approvers_s.NEXTVAL
           ,1
           ,p_approval_entity
           ,p_referral_id
           ,approverUserIds(i)
           ,'USER'
            ,l_appr_status
           ,null
           ,FND_GLOBAL.USER_ID
           ,sysdate
           ,FND_GLOBAL.USER_ID
           ,sysdate
           ,FND_GLOBAL.LOGIN_ID
          );
   EXCEPTION
       WHEN others THEN
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                ,'Bad row index = ' || (1 +sql%rowcount) ||' ' || sqlerrm
                                );
           END IF;
   END;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'Sucessfully inserted users into pv_ge_temp_approvers...'
                      );
   END IF;

    IF p_change_cntry_flag = 'Y' THEN
        -- Invoke notification API. This is to notify that the country has been changed
        -- So even thought there is no change in status i.e. it is still in SUBMITTED_FOR_APPROVAL
        -- there was an event of changing country which may have caused Approvers to change.
        -- So notification is called explicitly.

        PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_notification(p_api_version_number   => 1.0
                         ,p_init_msg_list       => FND_API.G_FALSE
                         ,p_commit              => FND_API.G_FALSE
                         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                         ,P_BENEFIT_ID          => l_benefit_id
                         ,P_STATUS              => 'SUBMITTED_FOR_APPROVAL'
                         ,P_ENTITY_ID           => p_referral_id
                         ,P_PARTNER_ID          => l_partner_id
                         ,p_user_callback_api   => 'PV_BENFT_STATUS_CHANGE.REFERRAL_RETURN_USERLIST'
                         ,p_msg_callback_api    => 'PV_BENFT_STATUS_CHANGE.REFERRAL_SET_MSG_ATTRS'
                         ,p_user_role           => 'BENEFIT_APPROVER'
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data);

         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

        -- Fix for Bug 5689433.
        l_message_name := null;

        IF p_approval_entity = 'PVREFFRL' then
            l_message_name :=   'PV_LG_REF_REQR_APPRVD_BY_USER';
        ELSIF p_approval_entity = 'PVDEALRN' then
            l_message_name :=   'PV_LG_DEAL_REQR_APPRVD_BY_USER';
        ELSIF p_approval_entity = 'PVDQMAPR' then
            l_message_name :=   'PV_LG_DQM_REQR_DEDUP_BY_USER';
        END IF;

        if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                           ,'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_LOGGING.start'
                           ,'Approvers notification Message:'||l_message_name);
        end if;

        FOR  apprCnt IN 1..approverUserIds.COUNT
        LOOP

            IF l_message_name IS NOT NULL THEN

                l_log_params_tbl.DELETE;
                FOR x in (SELECT source_name FROM jtf_rs_resource_extns B WHERE  user_id = approverUserIds(apprCnt) )
                LOOP
                    l_log_params_tbl(1).param_value := x.source_name;
                END LOOP;

                l_log_params_tbl(1).param_name := 'APPROVER';

                PVX_Utility_PVT.create_history_log(
                      p_arc_history_for_entity_code => l_benefit_type_code,
                      p_history_for_entity_id       => p_referral_id,
                      p_history_category_code       => 'GENERAL',
                      p_message_code                => l_message_name,
                      p_partner_id                  => l_partner_id,
                      p_access_level_flag           => 'V',
                      p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_10,
                      p_comments                    => NULL,
                      p_log_params_tbl              => l_log_params_tbl,
                      x_return_status               => l_return_status,
                      x_msg_count                   => l_msg_count,
                      x_msg_data                    => l_msg_data);

            END IF;

        END LOOP;

    END IF;

    CLOSE lc_lock_approvals;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                p_count     =>  x_msg_count,
                                p_data      =>  x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO START_APPROVAL_PROCESS;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                fnd_msg_pub.Count_And_Get(
                       p_encoded   =>  FND_API.G_FALSE,
                       p_count     =>  x_msg_count,
                       p_data      =>  x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO START_APPROVAL_PROCESS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                fnd_msg_pub.Count_And_Get(
                   p_encoded   =>  FND_API.G_FALSE,
                   p_count     =>  x_msg_count,
                   p_data      =>  x_msg_data);

        WHEN g_concurrent_update THEN
            fnd_message.Set_Name('PV', 'PV_REQUERY_THE_RECORD');
            fnd_msg_pub.Add;
            ROLLBACK TO UPDATE_APPROVER_RESPONSE;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            fnd_msg_pub.Count_And_Get(
                   p_encoded   =>  FND_API.G_FALSE,
                   p_count     =>  x_msg_count,
                   p_data      =>  x_msg_data);

        WHEN OTHERS THEN

                ROLLBACK TO START_APPROVAL_PROCESS;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MSG_PUB.Add_Exc_Msg(
                      'PV_AME_API_W',
                      l_api_name);

                fnd_msg_pub.Count_And_Get(
                  p_encoded   =>  FND_API.G_FALSE,
                  p_count     =>  x_msg_count,
                  p_data      =>  x_msg_data);

END START_APPROVAL_PROCESS;


/********************************************************************************
  This procedure starts the updates Responses given by approvers to the AME system.
*********************************************************************************/
PROCEDURE UPDATE_APPROVER_RESPONSE( p_api_version_number    IN  NUMBER
                                    , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
                                    , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
                                    , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                    , p_referral_id         IN  NUMBER
                                    , p_approval_entity     IN  VARCHAR2 -- PVREFFRL/PVDEALRN/PVDQMAPR
                                    , p_response            IN  VARCHAR2 -- refer to AME_UTIL.approverIn
                                    , p_approver_user_id    IN  NUMBER -- userID of the person sending approver resp
                                    , p_forwardee_user_id   IN  NUMBER   -- if forwarding then userID of the forwardee
                                    , p_note_added_flag     IN  VARCHAR2 DEFAULT 'N' -- If note was added as part of this response.
                                    , x_approval_done       OUT NOCOPY   VARCHAR2  -- True if approval process is finished False if not.
                                    , x_return_status       OUT NOCOPY  VARCHAR2
                                    , x_msg_count           OUT NOCOPY  NUMBER
                                    , x_msg_data            OUT NOCOPY  VARCHAR2
                                    ) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_APPROVER_RESPONSE';
    l_api_version_number  CONSTANT NUMBER       := 1.0;

    l_forwardee                      ame_util.approverRecord2;
    l_approver                       ame_util.approverRecord2;
    l_approval_status                VARCHAR2(30);
    l_appr_usr_id                    NUMBER;
    l_forwardee_user_id              NUMBER;
    l_benefit_id                     NUMBER;
    l_partner_id                     NUMBER;
    l_sec_lvl_reject                 BOOLEAN;
    l_temp                           VARCHAR2(5);
    l_isDefAppr                      BOOLEAN;
    l_appr_status                    VARCHAR2(20);
    l_log_params_tbl                 pvx_utility_pvt.log_params_tbl_type;
    l_message_code                   VARCHAR2(30);
    l_approver_name                  VARCHAR2(100);
    l_approver_category              VARCHAR2(30);
    l_approver_source_id             NUMBER;
    l_return_status                  VARCHAR2(30);
    l_msg_count                      NUMBER;
    l_msg_data                       VARCHAR2(1000);
    l_approver_current_status        VARCHAR2(30);
    l_pending_status                 VARCHAR2(30);
    l_approverInList                 BOOLEAN := false;
    l_ret_reason_code                VARCHAR2(30);
    l_return_note_id                 NUMBER;
    l_user_name                      VARCHAR2(100);

    l_approval_list                  JTF_NUMBER_TABLE;
    l_default_approver               VARCHAR2(10);
    l_valid_users_flag               VARCHAR2(1);
    l_response_to_ame                VARCHAR2(25);
    l_resp_count                     NUMBER;
    l_curr_appr_level                NUMBER;

    cursor lc_is_default_approver (pc_user_id number, pc_benefit_type varchar2, pc_entity_id number) is
    select approval_status_code from pv_ge_temp_approvers
    where arc_appr_for_entity_code = pc_benefit_type
    and appr_for_entity_id = pc_entity_id
    and approver_type_code = 'USER'
    and approver_id = pc_user_id
    and approval_status_code IN ('PENDING_APPROVAL','PENDING_DEFAULT');

    cursor lc_get_approver_details (pc_user_id number) is
    select decode(category, 'EMPLOYEE', source_id, null), category, source_name, user_name  from jtf_rs_resource_extns where user_id = pc_user_id;

    cursor lc_return_reason IS
    select return_reason_code from pv_referrals_b
    where  referral_id = p_referral_id;

    /**
    * In case of referral return the note added by the user on the Notes
    * region has to be added to the history log. This query finds that note
    *
    * It is mandatory to enter a note before returning a referral/deal
    * So the last note created when a return action is submitted will have to be
    * the note entered before returning the referral/deal. So this query
    * sorts all the notes for this referral in desc order of entered date
    * and picks up the first note.
    */
    cursor lc_return_note IS
    select  jtf_note_id
    from (select jtf_note_id
          from   jtf_notes_vl
          where  source_object_id = p_referral_id
          and    source_object_code = p_approval_entity
          order by entered_date desc)
    where rownum = 1;

    cursor lc_first_level_apporver is
    select count(entity_approver_id)
    from pv_ge_temp_approvers
    where arc_appr_for_entity_code = p_approval_entity
    and appr_for_entity_id = p_referral_id
    and approval_status_code in ('APPROVED','REJECTED');

    cursor lc_lock_approvals is
    SELECT entity_approver_id
    FROM   pv_ge_temp_approvers
    WHERE  arc_appr_for_entity_code = p_approval_entity
    AND    appr_for_entity_id = p_referral_id
    FOR    UPDATE NOWAIT;

    CURSOR lc_prior_approvers IS
    SELECT APPROVER_ID
    FROM   PV_GE_TEMP_APPROVERS
    WHERE  ARC_APPR_FOR_ENTITY_CODE = p_approval_entity
    AND    APPR_FOR_ENTITY_ID = p_referral_id;


BEGIN

    -- ********* Start Standard Initializations *******
    SAVEPOINT UPDATE_APPROVER_RESPONSE;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        'PV_AME_API_W') THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         fnd_msg_pub.initialize;
    END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_PROCEDURE
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,FALSE
                        );
    END IF;


    x_return_status  :=  FND_API.G_RET_STS_SUCCESS;
    -- ********* End Standard Initializations *********

    -- This is to make sure that no other thread of execution
    -- can try to update the rows for this referrral in
    -- pv_ge_temp_approvers.
    -- Bug 4628929
    OPEN lc_lock_approvals;

    x_approval_done := 'N';

    OPEN lc_get_approver_details(pc_user_id => p_approver_user_id);
    FETCH lc_get_approver_details INTO l_approver_source_id, l_approver_category, l_approver_name, l_user_name;
    CLOSE lc_get_approver_details;

    IF p_response = AME_UTIL.forwardStatus THEN -- FORWARD

        FOR x IN (SELECT employee_id,user_name FROM fnd_user WHERE user_id = p_forwardee_user_id
                  AND (end_date IS NULL OR end_date > sysdate-1))
        LOOP
            l_forwardee.orig_system_id := x.employee_id;
            l_forwardee.name := x.user_name;
        END LOOP;

        -- Forward case. create a forwadee record
        l_forwardee.orig_system := 'PER';
        l_forwardee.approver_category := ame_util.approvalApproverCategory;

        IF l_forwardee.orig_system_id IS NULL THEN
            fnd_message.Set_Name('PV', 'PV_NO_PERSON_ERROR');
            fnd_msg_pub.Add;
            RAISE FND_API.g_exc_error;
        END IF;

        l_approval_status := 'FORWARDED';
        IF p_approval_entity = 'PVREFFRL' then
           l_message_code :=  'PV_LG_REF_FORWARDED_BY_USER';
        ELSIF p_approval_entity = 'PVDEALRN' then
           l_message_code :=  'PV_LG_DEAL_FORWARDED_BY_USER';
        end if;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_PROCEDURE
                        ,'Forward case :b4 updateStatus call Forwardee ID :' || l_forwardee.orig_system_id||
                        ' l_forwardee.name '||l_forwardee.name,FALSE);
        END IF;

    ELSIF p_response = AME_UTIL.rejectStatus THEN

        OPEN lc_first_level_apporver;
        FETCH lc_first_level_apporver INTO l_resp_count;
        CLOSE lc_first_level_apporver;

        l_approval_status := 'REJECTED';
        IF p_approval_entity = 'PVREFFRL' then
           l_message_code :=   'PV_LG_REF_REJECTED_BY_USER';
        ELSIF p_approval_entity = 'PVDEALRN' then
           l_message_code :=   'PV_LG_DEAL_REJECTED_BY_USER';
        end if;

    ELSIF p_response = AME_UTIL.approvedStatus THEN

        l_approval_status := 'APPROVED';
        IF p_approval_entity = 'PVREFFRL' then
           l_message_code :=   'PV_LG_REF_APPRVD_BY_USER';
        ELSIF p_approval_entity = 'PVDEALRN' then
           l_message_code :=   'PV_LG_DEAL_APPRVD_BY_USER';
        end if;

    ELSIF p_response = returnStatus THEN

        l_approval_status := 'RETURNED';
        IF p_approval_entity = 'PVREFFRL' then
           l_message_code :=   'PV_LG_REF_RETURNED_BY_USER';
        ELSIF p_approval_entity = 'PVDEALRN' then
           l_message_code :=   'PV_LG_DEAL_RETURNED_BY_USER';
        end if;

        OPEN lc_return_reason;
        FETCH lc_return_reason INTO l_ret_reason_code;
        CLOSE lc_return_reason;

        l_log_params_tbl(2).param_name := 'RETURN_REASON';
        l_log_params_tbl(2).param_value := l_ret_reason_code;
        l_log_params_tbl(2).param_type := 'LOOKUP';
        l_log_params_tbl(2).param_lookup_type := 'PV_REFERRAL_RETURN_REASON';

        IF ( p_note_added_flag = 'Y' ) THEN
            OPEN lc_return_note;
            FETCH lc_return_note INTO l_return_note_id;
            CLOSE lc_return_note;
        ELSE
            l_return_note_id := -1;
        END IF;

        l_log_params_tbl(3).param_name := 'RETURN_NOTE';
        l_log_params_tbl(3).param_value := l_return_note_id;
        l_log_params_tbl(3).param_type := 'NOTE';

    END IF;

    -- If Approval Status was null it means that something other than
    -- AME_UTIL.forwardStatus / AME_UTIL.rejectStatus / AME_UTIL.approvedStatus
    -- was sent to the API. Hence error!!!
    IF l_approval_status IS NULL THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT', 'Possible error.  Invalid : Response ' || p_response);
        fnd_msg_pub.Add;
        RAISE FND_API.g_exc_error;
    END IF;

    IF p_response = AME_UTIL.forwardStatus and p_forwardee_user_id is null then
        fnd_message.Set_Name('PV', 'PV_REFERRAL_REASSIGN_APPROVER');
        fnd_msg_pub.Add;
        RAISE FND_API.g_exc_error;
    END IF;

    open lc_is_default_approver(pc_user_id      => p_approver_user_id,
                                pc_benefit_type => p_approval_entity,
                                pc_entity_id    => p_referral_id);
    fetch lc_is_default_approver into l_approver_current_status;
    close lc_is_default_approver;

    IF l_approver_current_status is null then

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'This user ' || p_approver_user_id || ' is not an approver for entity id: ' || p_referral_id
                      );
        END IF;

    END IF;

    FOR x IN (SELECT partner_id FROM pv_referrals_b WHERE referral_id = p_referral_id) LOOP
       l_partner_id := x.partner_id;
    END LOOP;

    -- Bug fix for bug 3495565. If the current approver gets removed from the
    -- list of approvers then skip the call to updateApprover. Treat it as a
    -- valid response as far as our system is concerned. This call is made to
    -- find out current user is still in the AME System.

    -- If the status is PENDING_DEFAULT then this approver did not come from
    -- AME so there is no point checking AME for validity of the approver.
    IF l_approver_current_status = 'PENDING_DEFAULT' THEN
        l_approverInList := true;
    ELSE
        l_approverInList := VALIDATE_APPROVAL(p_transaction_id => p_referral_id
                                         , p_transaction_type => p_approval_entity
                                         , p_user_id => p_approver_user_id
                                         , p_person_id => l_approver_source_id
                                         , p_mode => 'CHECK_CURRENT_APPROVER'
                                         , p_approval_level  => null
                                         , x_approver => l_approver);
    END IF;


    if l_message_code is not null then -- not logging for DQM approval

        l_log_params_tbl(1).param_name := 'APPROVER';
        l_log_params_tbl(1).param_value := l_approver_name;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'Logging approver response message: ' || l_message_code
                      );
        END IF;


        PVX_Utility_PVT.create_history_log(
                  p_arc_history_for_entity_code => p_approval_entity,
                  p_history_for_entity_id       => p_referral_id,
                  p_history_category_code       => 'GENERAL',
                  p_message_code                => l_message_code,
                  p_partner_id                  => l_partner_id,
                  p_access_level_flag           => 'V',
                  p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_10,
                  p_comments                    => NULL,
                  p_log_params_tbl              => l_log_params_tbl,
                  x_return_status               => l_return_status,
                  x_msg_count                   => l_msg_count,
                  x_msg_data                    => l_msg_data);

       if L_return_status <>  FND_API.G_RET_STS_SUCCESS then
           raise FND_API.G_EXC_ERROR;
       end if;

    end if;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                  ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                  ,'p_response ' || p_response);
    END IF;

    -- In case of forward even if the approver is not in the list
    -- an error will be thrown. In the other case i.e approve / reject
    -- the AME update call is circumvented
    IF (NOT l_approverInList AND (p_response = AME_UTIL.forwardStatus)) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,' The approver is NOT in the list. p_response ' || p_response);
        END IF;

        FND_MESSAGE.Set_Name('PV', 'PV_REFERRAL_REASSIGN_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;


    IF (l_approverInList) THEN

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'Current User is in AME system. Sending update reponse to AME...');
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'User name l_user_name '|| l_user_name ||
                      ' FND_GLOBAL.USER_NAME '|| FND_GLOBAL.USER_NAME
                      );

       END IF;
      IF l_approver_current_status = 'PENDING_APPROVAL' THEN

          IF p_response = AME_UTIL.forwardStatus THEN

              IF (l_approver.authority = ame_util.authorityApprover AND
                  (l_approver.api_insertion = ame_util.apiAuthorityInsertion
                   OR l_approver.api_insertion = ame_util.oamGenerated) ) THEN

                  l_forwardee.api_insertion := ame_util.apiAuthorityInsertion;

              ELSE

                  l_forwardee.api_insertion := ame_util.apiInsertion;

              END IF;

              l_forwardee.authority := l_approver.authority;

          END IF;


          /*
          * AME does not have the concept of RETURNing a transaction during approval
          * but PRM does. As far as AME is concerned a return is equivalent to a
          * Rejection. So we pass AME_UTIL.rejectStatus to AME in case of a RETURN
          */
          IF p_response = returnStatus THEN
              l_response_to_ame := AME_UTIL.rejectStatus;
          ELSE
              l_response_to_ame := p_response;
          END IF;

          ame_api2.updateApprovalStatus2
              (applicationIdIn     => 691
              , transactionTypeIn => p_approval_entity
              , transactionIdIn   => p_referral_id
              , approvalStatusIn  => l_response_to_ame
              , approverNameIn    => l_user_name
              , itemClassIn       => null
              , itemIdIn          => null
              , actionTypeIdIn    => null
              , groupOrChainIdIn  => null
              , occurrenceIn      => null
              , forwardeeIn       => l_forwardee
              , updateItemIn      => null
             );

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'After AME_API.updateApprovalStatus2 call...'
                      );
          END IF;

      END IF;

    ELSE

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'Current User is no more in the AME System as an approver. AME was not updated...'
                      );
       END IF;

    END IF; -- If current user is in AME system.

    -- Update pv_ge_temp_approvers to set the values of approval status to
    -- APPROVED/REJECTED/FORWARDED depending on the case for the approver id who
    -- took the action.
    UPDATE pv_ge_temp_approvers
    SET    approval_status_code = l_approval_status
    WHERE  arc_appr_for_entity_code = p_approval_entity
    AND    appr_for_entity_id = p_referral_id
    AND    approver_id = p_approver_user_id
    AND    approval_status_code IN ('PENDING_APPROVAL','PENDING_DEFAULT')
    AND    rownum = 1;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                      ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                      ,'Set the approval status for '|| p_approval_entity || ', ' || p_referral_id ||
                      'User id: ' || p_approver_user_id || ' to '||l_approval_status
                      );
    END IF;


    IF p_response = AME_UTIL.approvedStatus or p_response = AME_UTIL.forwardStatus THEN

        IF p_approval_entity = 'PVDQMAPR' THEN
           x_approval_done := 'Y';

           /* In case of DQM approval the first response is the only response
           *  that counts. So regardless of whether the approval is of type
           *  first responder wins / serial / consensus/order number
           *  the first person to respond closes the DQM approval process and
           *  all others will be marked as PEER_RESPONDED
           */
           IF l_approver_current_status = 'PENDING_APPROVAL' THEN

               UPDATE pv_ge_temp_approvers
               SET    approval_status_code = 'PEER_RESPONDED'
               WHERE  arc_appr_for_entity_code = p_approval_entity
               AND    appr_for_entity_id = p_referral_id
               AND    approval_status_code IN ('PENDING_APPROVAL');

           END IF;

        ELSE

            -- If it is PENDING_APPROVAL only then do we go to next level of
            -- Approval. If it is PENDING_DEFAULT then that level is
            -- considered the last level of approval
            IF l_approver_current_status = 'PENDING_APPROVAL' THEN

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                  ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                  ,'B4 getNextApprover....'
                                  );
                END IF;

                BEGIN
                    GET_APPROVERS(p_approval_entity => p_approval_entity
                              ,p_referral_id        => p_referral_id
                              ,p_mode               => 'UPDATE'
                              ,x_approval_list      => l_approval_list
                              ,x_approval_completed => x_approval_done
                              ,x_default_approver   => l_default_approver
                              ,x_user_id_exists     => l_valid_users_flag);
                EXCEPTION
                WHEN OTHERS THEN
                    -- log error message by AME
                    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        FND_MSG_PUB.Add_Exc_Msg('PV_AME_API_W',l_api_name);
                    END IF;
                    RAISE;
                END;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                  ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                  ,'After getNextApprover....l_approval_list '||l_approval_list.COUNT ||
                                  'After getNextApprover....x_approval_done '||x_approval_done||
                                  'After getNextApprover....l_default_approver '||l_default_approver ||
                                  'After getNextApprover....l_valid_users_flag '||l_valid_users_flag
                                  );
                END IF;

                IF ( l_valid_users_flag = 'N' ) THEN
                    FND_MESSAGE.Set_Name('PV', 'PV_NO_USER_FOR_PERSON_ERROR');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.g_exc_error;
                END IF;


                IF ((l_approval_list IS NULL OR l_approval_list.COUNT < 1)
                    AND p_response = AME_UTIL.forwardStatus)
                THEN

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                  ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                  ,'Even After forwarding l_approval_list is '||l_approval_list.COUNT);
                    END IF;

                    FND_MESSAGE.Set_Name('PV', 'PV_REFERRAL_NO_FORWARDEE');
                    FND_MSG_PUB.Add;
                    RAISE FND_API.g_exc_error;
                END IF;

                DEL_PRIOR_REP_APPR(p_approval_entity => p_approval_entity
                                   ,p_referral_id    => p_referral_id
                                   ,p_approval_list  => l_approval_list);

                l_curr_appr_level := l_approver.approver_order_number; -- Bug 5256368 (Consensus Issue)

                /*
                *  We need to set the approvers who did not respond to PEER_RESPONDED.
                *  However if there are any approvers who are yet to approve in AME we
                *  cannot set their status to PEER_RESPONDED. This case will occur in case
                *  of CONSENSUS where multiple approvers need to respond before the entity
                *  is APPROVED.
                *  So if approvers have been returned from AME check for consensus case and
                *  only then update current approvers to PEER_APPROVED
		*
		*   Bug fix 5256368: Remove approver from FRW case. If the current approver
		*   is no longer in the list then updates to other approvers rows is not to
		*   be allowed.
                */
                IF (NOT VALIDATE_APPROVAL(p_transaction_id => p_referral_id
                                         , p_transaction_type => p_approval_entity
                                         , p_user_id => p_approver_user_id
                                         , p_person_id => l_approver_source_id
                                         , p_mode => 'CHECK_PENDING_APPROVERS'
                                         , p_approval_level  => l_curr_appr_level
                                         , x_approver => l_approver) AND l_approverInList)
                THEN
                    UPDATE pv_ge_temp_approvers
                    SET    approval_status_code = 'PEER_RESPONDED'
                    WHERE  arc_appr_for_entity_code = p_approval_entity
                    AND    appr_for_entity_id = p_referral_id
                    AND    approval_status_code = 'PENDING_APPROVAL';
                END IF;

                l_pending_status := 'PENDING_APPROVAL';

            ELSE

                -- l_approver_current_status = 'PENDING_DEFAULT'
                IF p_response = AME_UTIL.forwardStatus THEN
                    x_approval_done := 'N';
                    l_approval_list := JTF_NUMBER_TABLE();
                    l_approval_list.EXTEND();
                    l_approval_list(1) := p_forwardee_user_id;
                    l_pending_status := 'PENDING_DEFAULT';

                    DEL_PRIOR_REP_APPR(p_approval_entity => p_approval_entity
                                       ,p_referral_id    => p_referral_id
                                       ,p_approval_list  => l_approval_list);

                ELSE
                    x_approval_done := 'Y';
                END IF;
            END IF;


            IF l_approval_list IS NOT NULL AND l_approval_list.COUNT > 0
            THEN
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                  ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                  ,'Inserting users into pv_ge_temp_approvers...'
                                  );
                END IF;

                BEGIN
                FORALL i IN 1..l_approval_list.COUNT


                    INSERT INTO pv_ge_temp_approvers(
                        ENTITY_APPROVER_ID
                        ,OBJECT_VERSION_NUMBER
                        ,ARC_APPR_FOR_ENTITY_CODE
                        ,APPR_FOR_ENTITY_ID
                        ,APPROVER_ID
                        ,APPROVER_TYPE_CODE
                        ,APPROVAL_STATUS_CODE
                        ,WORKFLOW_ITEM_KEY
                        ,CREATED_BY
                        ,CREATION_DATE
                        ,LAST_UPDATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
                    )VALUES(
                        pv_ge_temp_approvers_s.NEXTVAL
                        ,1
                        ,p_approval_entity
                        ,p_referral_id
                        ,l_approval_list(i)
                        ,'USER'
                        ,l_pending_status
                        ,null
                        ,FND_GLOBAL.USER_ID
                        ,sysdate
                        ,FND_GLOBAL.USER_ID
                        ,sysdate
                        ,FND_GLOBAL.LOGIN_ID
                    );

                EXCEPTION
                   WHEN others THEN
                       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                ,'Bad row index = ' || (1 +sql%rowcount) ||' ' || sqlerrm
                                );
                       END IF;

                END;

                IF p_approval_entity = 'PVREFFRL' then
                    l_message_code :=   'PV_LG_REF_REQR_APPRVD_BY_USER';
                ELSIF p_approval_entity = 'PVDEALRN' then
                    l_message_code :=   'PV_LG_DEAL_REQR_APPRVD_BY_USER';
                END IF;

                FOR  apprCnt IN 1..l_approval_list.COUNT
                LOOP

                    FOR x in (SELECT source_name FROM jtf_rs_resource_extns B WHERE  user_id = l_approval_list(apprCnt) )
                    LOOP
                       l_log_params_tbl(1).param_value := x.source_name;
                    END LOOP;

                    l_log_params_tbl(1).param_name := 'APPROVER';

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                ,'Logging who the next approver is: ' || l_approver_name
                                );
                    END IF;

                    PVX_Utility_PVT.create_history_log(
                            p_arc_history_for_entity_code => p_approval_entity,
                            p_history_for_entity_id       => p_referral_id,
                            p_history_category_code       => 'GENERAL',
                            p_message_code                => l_message_code,
                            p_partner_id                  => l_partner_id,
                            p_access_level_flag           => 'V',
                            p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_10,
                            p_comments                    => NULL,
                            p_log_params_tbl              => l_log_params_tbl,
                            x_return_status               => l_return_status,
                            x_msg_count                   => l_msg_count,
                            x_msg_data                    => l_msg_data);

                END LOOP;
            END IF; -- If Approval is done
        END IF; -- Id it is PENDING_APPROVAL

    ELSIF p_response = AME_UTIL.rejectStatus THEN -- never the case for DQM

        -- In Case of DECLINE the response is rejectStatus. In this case however the
        -- referral approval process is not to be restarted. Conversely, in all cases of
        -- rejectStatus response other than DECLINED the approval process is restarted.
        IF l_resp_count > 0 THEN
            -- When an approval is Reject the approval process has to be restarted
            -- as if it is being approved for the first time again.
            --
            -- So the referral goes back to SUBMITTED_FOR_APPROVAL and new approvers
            -- are notified.

            BEGIN

                -- restart approval process
                START_APPROVAL_PROCESS(p_api_version_number  => 1.0
                   ,p_init_msg_list       => FND_API.G_FALSE
                   ,p_commit              => FND_API.G_FALSE
                   ,p_validation_level    => 90 --fnd_api.g_valid_level_full,
                   ,p_referral_id         => p_referral_id
                   ,p_change_cntry_flag   => 'N'
                   ,p_country_code        => NULL
                   ,p_approval_entity     => p_approval_entity
                   ,x_return_status       => l_return_status
                   ,x_msg_count           => l_msg_count
                   ,x_msg_data            => l_msg_data);

                IF L_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                x_approval_done := 'N';
            EXCEPTION
                WHEN no_data_found THEN
                    x_approval_done := 'Y';
                WHEN OTHERS THEN
                    RAISE;
            END;

        END IF;

    END IF; -- End of REJECTED CASE

    CLOSE lc_lock_approvals;

    IF x_approval_done <> 'Y' THEN
        -- Send Notification
        FOR x IN (SELECT partner_id ,benefit_id FROM pv_referrals_b WHERE referral_id = p_referral_id) LOOP
            l_benefit_id := x.benefit_id;
            l_partner_id := x.partner_id;
        END LOOP;

        PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_notification(p_api_version_number   => 1.0
                                ,p_init_msg_list       => FND_API.G_FALSE
                                ,p_commit              => FND_API.G_FALSE
                                ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                                ,P_BENEFIT_ID          => l_benefit_id
                                ,P_STATUS              => 'SUBMITTED_FOR_APPROVAL'
                                ,P_ENTITY_ID           => p_referral_id
                                ,P_PARTNER_ID          => l_partner_id
                                ,p_user_callback_api   => 'PV_BENFT_STATUS_CHANGE.REFERRAL_RETURN_USERLIST'
                                ,p_msg_callback_api    => 'PV_BENFT_STATUS_CHANGE.REFERRAL_SET_MSG_ATTRS'
                                ,p_user_role           => 'BENEFIT_APPROVER'
                                ,x_return_status       => l_return_status
                                ,x_msg_count           => l_msg_count
                                ,x_msg_data            => l_msg_data);

        IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                p_count     =>  x_msg_count,
                                p_data      =>  x_msg_data);

EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

                ROLLBACK TO UPDATE_APPROVER_RESPONSE;
                x_return_status := FND_API.G_RET_STS_ERROR ;

                fnd_msg_pub.Count_And_Get(
                       p_encoded   =>  FND_API.G_FALSE,
                       p_count     =>  x_msg_count,
                       p_data      =>  x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                ROLLBACK TO UPDATE_APPROVER_RESPONSE;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                fnd_msg_pub.Count_And_Get(
                   p_encoded   =>  FND_API.G_FALSE,
                   p_count     =>  x_msg_count,
                   p_data      =>  x_msg_data);

        WHEN g_concurrent_update THEN
            fnd_message.Set_Name('PV', 'PV_REQUERY_THE_RECORD');
            fnd_msg_pub.Add;

            ROLLBACK TO UPDATE_APPROVER_RESPONSE;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            fnd_msg_pub.Count_And_Get(
                   p_encoded   =>  FND_API.G_FALSE,
                   p_count     =>  x_msg_count,
                   p_data      =>  x_msg_data);

        WHEN OTHERS THEN

                ROLLBACK TO UPDATE_APPROVER_RESPONSE;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MSG_PUB.Add_Exc_Msg('PV_AME_API_W', l_api_name);

                fnd_msg_pub.Count_And_Get(
                  p_encoded   =>  FND_API.G_FALSE,
                  p_count     =>  x_msg_count,
                  p_data      =>  x_msg_data);

END UPDATE_APPROVER_RESPONSE;

/*
* This function queries for the latest set of approvers pending approval
* in AME. With the list of approvers returned by AME we can perform certain
* validations.
* - CHECK_CURRENT_APPROVER: Validate if the current logged in user is a
*   a valid approver in AME.
* - CHECK_PENDING_APPROVERS: Check if AME is waiting for response from any of
*   the current set of approvers in pv_ge_temp_approvers. (Consensus case)
*/
FUNCTION VALIDATE_APPROVAL (p_transaction_id     IN NUMBER
                           , p_transaction_type  IN VARCHAR2
                           , p_user_id           IN NUMBER
                           , p_person_id         IN NUMBER
                           , p_mode              IN VARCHAR2
                           , p_approval_level    IN NUMBER
                           , x_approver          OUT NOCOPY ame_util.approverRecord2)
RETURN BOOLEAN IS

    CURSOR c_user(pc_person_id NUMBER) IS
    SELECT 'Y'
    FROM   fnd_user A , pv_ge_temp_approvers appr
    WHERE  A.employee_id = pc_person_id
    AND    ( A.end_date IS NULL OR A.end_date > sysdate-1)
    AND    A.user_id = appr.approver_id
    AND    appr.approval_status_code = 'PENDING_APPROVAL'
    AND    appr.APPR_FOR_ENTITY_ID = p_transaction_id
    AND    appr.ARC_APPR_FOR_ENTITY_CODE = p_transaction_type;

    l_is_valid  BOOLEAN := false;
    l_usr_resp_pending VARCHAR2(1) := 'N';
    l_approversOut      ame_util.approversTable;

    x_approvalProcessCompleteYNOut VARCHAR2(10);
    x_nextApproversOut ame_util.approversTable2; -- New API approverOut
    currApprRec ame_util.approverRecord2;

    xitemIndexesOut ame_util.idList;
    xitemClassesOut ame_util.stringList;
    xitemIdsOut ame_util.stringList;
    xitemSourcesOut ame_util.longStringList;

 BEGIN
     -- get all the approver list and loop till you find the matching
     -- and set the flag to true if you find any.
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.VALIDATE_APPROVAL'
                                ,'before  getPendingApprovers  ' || p_transaction_id ||
                                ' '|| p_transaction_type || ' p_user_id ' || p_user_id ||
                                ' p_person_id '|| p_person_id||' p_mode '|| p_mode ||
				' p_approval_level '|| p_approval_level
                                );
     END IF;


     ame_api2.getPendingApprovers(applicationIdIn => 691,
                                transactionTypeIn => p_transaction_type,
                                transactionIdIn => p_transaction_id,
                                approvalProcessCompleteYNOut => x_approvalProcessCompleteYNOut,
                                approversOut => x_nextApproversOut);

    IF ( p_mode = 'CHECK_CURRENT_APPROVER' ) THEN

        FOR i IN 1..x_nextApproversOut.count LOOP
            currApprRec := x_nextApproversOut(i);

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                        ,'pv.plsql.' || g_pkg_name || '.VALIDATE_APPROVAL'
                                        ,'currApprRec.orig_system_id ' || currApprRec.orig_system_id
                                        );
            END IF;

	    IF (p_person_id = currApprRec.orig_system_id)  THEN
                l_is_valid := true;
                x_approver := currApprRec;
                EXIT;
            END IF;
        END LOOP;

    ELSIF ( p_mode = 'CHECK_PENDING_APPROVERS' ) THEN

        FOR i IN 1..x_nextApproversOut.count LOOP
            currApprRec := x_nextApproversOut(i);

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                        ,'pv.plsql.' || g_pkg_name || '.VALIDATE_APPROVAL'
                                        ,'currApprRec.orig_system_id ' || currApprRec.orig_system_id||
					'currApprRec.orig_system_id ' || currApprRec.approver_order_number
                                        );
            END IF;

            /**
            * Consensus case is true if there are person/persons in AME
            * at the same approval level as the person currently approving
            * e.g. Say the approval process looks like this
            * Level 1 : A, B
            * Level 2 : A
            * A level 1 and A level 2 are distinct. If level 1 is consensus and B
            * approves the A returned by getPendingApprovers will have order number as 1
            * as opposed to FRW case where A will have an order number 2 since it will be
            * the A from level 2.
            */
            IF ( p_approval_level = currApprRec.approver_order_number )
            THEN
                OPEN c_user(currApprRec.orig_system_id);
                FETCH c_user INTO l_usr_resp_pending;
                CLOSE c_user;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                   ,'pv.plsql.' || g_pkg_name || '.VALIDATE_APPROVAL'
                                   ,'RESPONSES PENDING ? l_usr_resp_pending ' || l_usr_resp_pending
                                   );
                END IF;

                IF ( l_usr_resp_pending = 'Y' ) THEN
                    l_is_valid := true;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
    END IF;

    RETURN l_is_valid;

EXCEPTION
    WHEN OTHERS THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.VALIDATE_APPROVAL'
                                ,'Error in getPendingApprovers '||SQLCODE ||
                                ': ' || SQLERRM);
        END IF;
        FND_MESSAGE.Set_Name('PV', 'PV_REFERRAL_APPROVAL_ERROR');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

END VALIDATE_APPROVAL;

PROCEDURE GET_APPROVERS(p_approval_entity     IN          VARCHAR2
                        ,p_referral_id        IN          NUMBER
                        ,p_mode               IN          VARCHAR2
                        ,x_approval_list      OUT  NOCOPY JTF_NUMBER_TABLE
                        ,x_approval_completed OUT  NOCOPY VARCHAR2
                        ,x_default_approver   OUT  NOCOPY VARCHAR2
                        ,x_user_id_exists     OUT  NOCOPY VARCHAR2)
IS
    l_api_name     VARCHAR2(20) := 'GET_APPROVERS';

    x_nextApproverOut                ame_util.approverRecord; -- Old API approverOut

    x_approvalProcessCompleteYNOut VARCHAR2(100);
    x_nextApproversOut ame_util.approversTable2; -- New API approverOut
    currApprRec ame_util.approverRecord2;

    xitemIndexesOut ame_util.idList;
    xitemClassesOut ame_util.stringList;
    xitemIdsOut ame_util.stringList;
    xitemSourcesOut ame_util.longStringList;
    xproductionIndexesOut ame_util.idList;
    xvariableNamesOut ame_util.stringList;
    xvariableValuesOut ame_util.stringList;
    xtransVariableNamesOut ame_util.stringList;
    xtransVariableValuesOut ame_util.stringList;

    l_valid_user_for_person VARCHAR2(1) :=  'Y';
    l_orig_system VARCHAR2(20);
    l_exception_flag VARCHAR2(1) := 'N';

BEGIN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_PROCEDURE
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,FALSE
                        );
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'inside GET_APPROVERS p_approval_entity '||p_approval_entity ||
                          ' p_referral_id ' || p_referral_id
                        );
    END IF;

    -- This BEGIN ... END is to trap any errors that is thrown from AME. In that
    -- case the list of approvers will be empty and approval would not be
    -- marked as complete. In those cases the default approver is to be picked up.
    BEGIN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'GET_APPROVERS Calling new APIs '
                        );
        END IF;
        x_approval_list := JTF_NUMBER_TABLE();

        AME_API2.getNextApprovers3(applicationIdIn => 691
                                    ,transactionTypeIn => p_approval_entity
                                    ,transactionIdIn => p_referral_id
                                    ,flagApproversAsNotifiedIn => ame_util.booleanTrue
                                    ,approvalProcessCompleteYNOut => x_approvalProcessCompleteYNOut
                                    ,nextApproversOut => x_nextApproversOut
                                    ,itemIndexesOut => xitemIndexesOut
                                    ,itemClassesOut => xitemClassesOut
                                    ,itemIdsOut => xitemIdsOut
                                    ,itemSourcesOut => xitemSourcesOut
                                    ,productionIndexesOut => xproductionIndexesOut
                                    ,variableNamesOut => xvariableNamesOut
                                    ,variableValuesOut => xvariableValuesOut
                                    ,transVariableNamesOut => xtransVariableNamesOut
                                    ,transVariableValuesOut => xtransVariableValuesOut);

        --x_approval_list.EXTEND(x_nextApproversOut.COUNT);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'GET_APPROVERS x_nextApproversOut.COUNT '||x_nextApproversOut.COUNT
                        );
        END IF;

        FOR i IN 1..x_nextApproversOut.COUNT
        LOOP

            currApprRec := x_nextApproversOut(i);
            l_orig_system    := currApprRec.orig_system;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'GET_APPROVERS l_orig_system '||l_orig_system
                        );
            END IF;

            /**
            * Referral/Deals support only internal users as approvers.
            *
            * AME supports the following types of approvers
            * Persons, Users , Workflow Roles
            *
            * Persons are always internal users so Refereals can support all PER.
            * However Referral/Deal module convers all person_id to user_id
            * before saving to PV_GE_TEMP_APPROVERS. All of the queries in this
            * module is centered around the assumption that approver column will always
            * have a USER_ID. Also in order to approve referrals and deals the user
            * has to login to the system and approve. It is not possible to do it
            * from an email or any other way without logging into the system. So
            * it is safe to assume that only persons with valid USER accounts can
            * be approvers in case of Referrals/Deals
            *
            * Users from AME are all users that are not internal users. These are not
            * supported since only internal users can be approvers.
            *
            * Workflow roles. PRM does not support this type.
            * --------------------------------------------------------------
            * -- IN SHORT ONLY 'PER' WITH VALID USER ACCOUNT IS SUPPORTED --
            * --------------------------------------------------------------
            **/
            x_user_id_exists := 'N';

            IF (l_orig_system = 'PER') THEN

                FOR x IN (SELECT A.user_id FROM fnd_user A, jtf_rs_resource_extns B
                          WHERE  employee_id = currApprRec.orig_system_id
                          AND    A.user_id = B.user_id
                          AND    ( A.end_date IS NULL OR A.end_date > sysdate-1) )
                LOOP

                    x_approval_list.EXTEND();
                    x_approval_list(x_approval_list.COUNT) := x.user_id;
                    x_user_id_exists := 'Y';
                END LOOP;

                IF (x_user_id_exists = 'N') THEN
                    EXIT;
                END IF;
            END IF;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'GET_APPROVERS x_approval_completed '||x_approval_completed
                        );
            END IF;

        END LOOP;

        x_approval_completed := x_approvalProcessCompleteYNOut;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                        ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                        ,'GET_APPROVERS x_approval_completed '||x_approval_completed
                        );
        END IF;


    EXCEPTION
    WHEN OTHERS THEN
        -- log error message by AME
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MSG_PUB.Add_Exc_Msg('PV_AME_API_W',l_api_name);
        END IF;
        l_exception_flag := 'Y';

        IF p_mode = 'UPDATE' THEN
            RAISE;
        END IF;
    END;

    /**
    *  Default approver needs to be picked up under the following conditions
    *
    *  IF AME IS BEING CALLED FOR THE FIRST TIME FOR THIS ENTITY
    *  AND ANY ONE OF THE BELOW CASES
    *    - AME DID NOT RETURN ANY ONE (MAYBE NO RULE WAS SETUP OR ANY OTHER REASON)
    *    OR
    *    - THERE WAS SOME EXCEPTION IN AME
    *    OR
    *    - AME RETURNED A PERSON WITH INVALID USER ACCOUNT
    *
    *  A DEFAULT APPROVER IS NEVER CHOSEN IN CASE OF A SUBSEQUENT LEVEL APPROVAL
    **/

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'p_mode '||p_mode||' x_nextApproversOut.COUNT ' || x_nextApproversOut.COUNT ||
                       ' l_exception_flag '||l_exception_flag||' x_user_id_exists ' || x_user_id_exists);
    END IF;

    IF (p_mode = 'START') THEN

         IF (x_nextApproversOut.COUNT < 1 --x_approval_completed = 'Y' AME changed
             OR l_exception_flag = 'Y'
             OR x_user_id_exists = 'N') THEN

                x_default_approver := 'Y';

                -- clearing the table in case there were any already existing
                -- valid users in list.
                x_approval_list := JTF_NUMBER_TABLE();
                x_approval_list.EXTEND(1);

                IF p_approval_entity = 'PVREFFRL' THEN
                    x_approval_list(1) := FND_PROFILE.Value('PV_DEFAULT_REFERRAL_APPROVER');
                ELSIF p_approval_entity = 'PVDEALRN' THEN
                    x_approval_list(1) := FND_PROFILE.Value('PV_DEFAULT_DEAL_APPROVER');
                ELSIF p_approval_entity = 'PVDQMAPR' THEN
                    x_approval_list(1) := FND_PROFILE.Value('PV_DEFAULT_DQM_APPROVER');
                END IF;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                                ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                                ,'Approver from profile for '||p_approval_entity||' is ' || x_approval_list(1)
                                );
                END IF;
        END IF; -- completed or exception or invalid user

    END IF; -- p_mode is START


EXCEPTION

    WHEN OTHERS THEN
        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MSG_PUB.Add_Exc_Msg('PV_AME_API_W',l_api_name);
        END IF;
END GET_APPROVERS;


PROCEDURE DEL_PRIOR_REP_APPR(p_approval_entity     IN  VARCHAR2
                             , p_referral_id       IN  NUMBER
                             , p_approval_list     IN  JTF_NUMBER_TABLE)
IS
    CURSOR lc_prior_approvers IS
    SELECT APPROVER_ID
    FROM   PV_GE_TEMP_APPROVERS
    WHERE  ARC_APPR_FOR_ENTITY_CODE = p_approval_entity
    AND    APPR_FOR_ENTITY_ID = p_referral_id;

BEGIN

    /** BUG 5523142
    * To open up the visibility of the deal/referral to approvers who had rejected before we need to
    * maintain all the rows that were previously created for a prior approval process. If the people
    * on the current approvers list from AME are in the prior approver list they need to be removed
    * before rows for new set of approvers are created.
    */
    FOR l_prior_appr IN lc_prior_approvers
    LOOP
        FOR x IN 1..p_approval_list.COUNT
        LOOP
            IF ( p_approval_list(x) = l_prior_appr.APPROVER_ID) THEN
                DELETE FROM pv_ge_temp_approvers
                WHERE  arc_appr_for_entity_code = p_approval_entity
                AND    appr_for_entity_id  = p_referral_id
                AND    approver_id = p_approval_list(x)
                AND    approval_status_code IN ('PRIOR_APPROVER');
            END IF;
        END LOOP;
    END LOOP;

END DEL_PRIOR_REP_APPR;

END PV_AME_API_W;

/
