--------------------------------------------------------
--  DDL for Package Body CN_PAYMENT_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAYMENT_SECURITY_PVT" AS
-- $Header: cnvpmscb.pls 120.20.12010000.2 2008/09/18 20:29:09 rnagired ship $
   g_pkg_name           CONSTANT VARCHAR2 (30) := 'CN_PAYMENT_SECURITY_PVT';
   g_file_name          CONSTANT VARCHAR2 (12) := 'cnvpmscb.pls';


  PROCEDURE pmt_raise_event(
          p_type          VARCHAR2,
          p_event_name    VARCHAR2,
          p_payrun_id     NUMBER,
          p_salesrep_id   NUMBER := NULL )
  IS
      l_obj_id        NUMBER := -1 ;
      l_key           VARCHAR2(1000);
      l_list          wf_parameter_list_t;
      l_event_name    VARCHAR2(1000);
      g_evt_prefix         varchar2(1000) := 'oracle.apps.cn.payment.paysheet.' ;
      l_ovn         NUMBER := -1;
  BEGIN
     IF p_type = 'WORKSHEET' THEN
          SELECT payment_worksheet_id,  object_version_number
          INTO   l_obj_id, l_ovn
          FROM   cn_payment_worksheets
          WHERE  payrun_id = p_payrun_id
          AND    salesrep_id = p_salesrep_id
          AND    quota_id IS NULL ;

          l_key := p_event_name || '-' || l_obj_id || '-' || l_ovn ;
          wf_event.AddParameterToList('PAYRUN_ID'  ,  p_payrun_id,   l_list);
          wf_event.AddParameterToList('SALESREP_ID',  p_salesrep_id, l_list);
          wf_event.AddParameterToList('WORKSHEET_ID', l_obj_id, l_list) ;

     ELSIF p_type = 'PAYRUN' THEN
          SELECT payrun_id,  object_version_number
          INTO   l_obj_id, l_ovn
          FROM   cn_payruns
          WHERE  payrun_id = p_payrun_id ;

          l_key := p_event_name || '-' || l_obj_id || '-' || l_ovn ;
          wf_event.AddParameterToList('PAYRUN_ID'  ,  p_payrun_id,   l_list);
     END IF ;

     IF p_type IN ('PAYRUN', 'WORKSHEET') THEN
         l_event_name := g_evt_prefix || p_event_name ;
         -- Raise Event
         wf_event.raise
            (p_event_name        => l_event_name,
             p_event_key         => l_key,
             p_parameters        => l_list);
         l_list.DELETE;
     END IF ;
  END ;

-- Start of comments
--    API name        : get_pay_by_mode
--    Type            : Public.
--    Function        : Pay By Mode for the payrun
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_payrun_id     IN NUMBER
--    OUT             :
-- End of comments
   FUNCTION get_pay_by_mode (p_payrun_id  IN  NUMBER)
   RETURN VARCHAR2
   IS
      l_ret_val  varchar2(1) ;
   BEGIN
      select payrun_mode
      into  l_ret_val
      from cn_payruns
      where payrun_id = p_payrun_id ;

      IF l_ret_val NOT IN ('Y','N')
      THEN
          -- resource not exist for this user
          fnd_message.set_name ('CN', 'CN_INVALID_PAYBYMODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END IF ;
      RETURN l_ret_val ;
   END;


-- Start of comments
--    API name        : Is_Superuser
--    Type            : Private.
--    Function        : Return 1 if current FND user is a super user in
--                      payment administartive hierarchy
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_period_id     IN NUMBER
--    OUT             :
--    Version :         Current version       1.0
--    Notes           : Return 1 if current fnd user is root node in
--                      Payment administrative hierarchy
--
-- End of comments
   FUNCTION is_superuser (
      p_period_id                IN       NUMBER,
	p_org_id                   IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_tmp                         NUMBER := 0;
      l_resource_id                 jtf_rs_resource_extns.resource_id%TYPE;
   BEGIN
      l_resource_id := NULL;

      BEGIN
         SELECT resource_id
           INTO l_resource_id
           FROM jtf_rs_resource_extns
          WHERE user_id = fnd_global.user_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- resource not exist for this user
            fnd_message.set_name ('CN', 'CN_USER_RESOURCE_NF');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      -- Get number of parent_resource for current resource
      SELECT SUM (DECODE (resource_id, parent_resource_id, 0, 1))
        INTO l_tmp
        FROM
             -- check if user is in analyst hierarchy in this period,
             -- if view empty, not exist and not a super user, l_tmp will become NULL
             (SELECT m1.parent_resource_id,
                     m1.resource_id
                FROM cn_period_statuses pr,
                     jtf_rs_group_usages u1,
                     jtf_rs_rep_managers m1
               WHERE p_period_id IS NOT NULL
                 AND pr.period_id = p_period_id
                 AND pr.org_id=p_org_id
                 AND u1.USAGE = 'COMP_PAYMENT'
                 AND ((m1.start_date_active <= pr.end_date) AND (pr.start_date <= NVL (m1.end_date_active, pr.start_date)))
                 AND u1.GROUP_ID = m1.GROUP_ID
                 AND m1.resource_id = l_resource_id
                 AND m1.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP')
                 AND m1.CATEGORY <> 'TBH') v1;

      IF l_tmp IS NULL OR l_tmp > 0
      THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END is_superuser;

-- Start of comments
--    API name        : Is_Manager
--    Type            : Private.
--    Function        : Return 1 if current FND user is a manager in
--                      payment administartive hierarchy
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--                      p_period_id     IN NUMBER
--    OUT             :
--    Version :         Current version       1.0
--    Notes           : Return 1 if current fnd user is a manager in
--                      Payment administrative hierarchy
--
-- End of comments
   FUNCTION is_manager (
      p_period_id                IN       NUMBER,
      p_org_id			   IN       NUMBER
   )
      RETURN NUMBER
   IS
      l_tmp                         NUMBER;
      l_resource_id                 jtf_rs_resource_extns.resource_id%TYPE;
   BEGIN
      l_resource_id := NULL;

      BEGIN
         SELECT resource_id
           INTO l_resource_id
           FROM jtf_rs_resource_extns
          WHERE user_id = fnd_global.user_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- resource not exist for this user
            fnd_message.set_name ('CN', 'CN_USER_RESOURCE_NF');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      SELECT 1
        INTO l_tmp
        FROM DUAL
       WHERE EXISTS (
                SELECT 1
                  FROM cn_period_statuses pr,
                       jtf_rs_group_usages u1,
                       jtf_rs_rep_managers m1
                 WHERE p_period_id IS NOT NULL
                   AND pr.period_id = p_period_id
                   AND pr.org_id=p_org_id
                   AND u1.USAGE = 'COMP_PAYMENT'
                   AND ((m1.start_date_active <= pr.end_date) AND (pr.start_date <= NVL (m1.end_date_active, pr.start_date)))
                   AND u1.GROUP_ID = m1.GROUP_ID
                   AND m1.parent_resource_id = l_resource_id
                   AND m1.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP')
                   AND m1.CATEGORY <> 'TBH');

      RETURN 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END is_manager;

--
-- Procedure : Paid_Payrun_Audit
-- This procedue will update payrun status to paid, insert audit record
--   into cn_reasons, update records in cn_pay_approval_flow
-- Should call this procedure at the end of pay_payrun procedure
--
   PROCEDURE paid_payrun_audit (
      p_payrun_id                IN       NUMBER,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Paid_Payrun_Audit';
      l_loading_status              VARCHAR2 (30);
      l_note_id                  NUMBER;
      l_msg_name                   VARCHAR2(200);
      l_note_msg                 VARCHAR2(240);

      CURSOR c_wksht_csr
      IS
         SELECT payment_worksheet_id
           FROM cn_payment_worksheets
          WHERE payrun_id = p_payrun_id;

      --R12
      l_ovn                         NUMBER;
      l_has_access                  BOOLEAN;

      CURSOR getobj
      IS
         SELECT object_version_number
           FROM cn_payruns
          WHERE payrun_id = p_payrun_id;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN getobj;

      FETCH getobj
       INTO l_ovn;

      --Added for R12 payment security check begin.
      l_has_access := get_security_access (g_type_payrun, g_access_payrun_pay);

      IF (l_has_access = FALSE)
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      fnd_message.set_name('CN', 'CN_PAYSHEET_PAY_NOTE');
      l_note_msg := fnd_message.get;

      -- for each worksheet in this payrun, add audit history to 'Pay Payrun'
      FOR l_wksht_csr IN c_wksht_csr
      LOOP

       jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => l_wksht_csr.payment_worksheet_id,
                            p_source_object_code      => 'CN_PAYMENT_WORKSHEETS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );

      END LOOP;

      -- call cn_pay_approval_flow_pvt.pay_payrun
      cn_pay_approval_flow_pvt.pay_payrun (p_api_version        => 1.0,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_payrun_id          => p_payrun_id
                                          );

      IF x_return_status <> fnd_api.g_ret_sts_success
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- update payrun status='PAID'
      cn_payruns_pkg.UPDATE_RECORD (x_payrun_id                  => p_payrun_id,
                                    x_status                     => 'PAID',
                                    x_last_updated_by            => fnd_global.user_id,
                                    x_last_update_date           => SYSDATE,
                                    x_last_update_login          => fnd_global.login_id,
                                    x_object_version_number      => l_ovn
                                   );

      -- raise wf event
      pmt_raise_event(
            p_type => 'PAYRUN',
            p_event_name  => 'pay' ,
            p_payrun_id   => p_payrun_id ) ;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END paid_payrun_audit;

--
-- Procedure : Payrun_Audit
--   Procedure to update payrun status and enter audit info into cn_reasons
--
   PROCEDURE payrun_audit (
      p_payrun_id                IN       NUMBER,
      p_action                   IN       VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Payrun_Audit';
      l_new_status                  cn_payruns.status%TYPE := NULL;
      l_loading_status              VARCHAR2 (30);
      l_ovn                         NUMBER;
      l_has_access                  BOOLEAN;
      l_event_name                 VARCHAR2 (30);
      CURSOR getobj
      IS
         SELECT object_version_number
           FROM cn_payruns
          WHERE payrun_id = p_payrun_id;
   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN getobj;

      FETCH getobj
       INTO l_ovn;

      -- pay apyrun should call paid_payrun_audit
      IF p_action <> 'PAY'
      THEN

         -- update payrun status
         IF p_action = 'FREEZE'
         THEN
            --Added for R12 payment security check begin.
            l_has_access := get_security_access (g_type_payrun, g_access_payrun_freeze);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            --Added for R12 payment security check end.
            l_new_status := 'FROZEN';
            l_event_name := 'freeze' ;

         ELSIF p_action = 'UNFREEZE' OR p_action = 'REFRESH' OR p_action = 'REMOVE'
         THEN
            --Added for R12 payment security check begin.
            IF p_action = 'UNFREEZE'
            THEN
               l_has_access := get_security_access (g_type_payrun, g_access_payrun_unfreeze);

               IF (l_has_access = FALSE)
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
               l_event_name :=  'unfreeze' ;

            ELSIF p_action = 'REFRESH'
            THEN
               l_has_access := get_security_access (g_type_payrun, g_access_payrun_refresh);

               IF (l_has_access = FALSE)
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
               l_event_name :=  'refresh' ;

            ELSIF p_action = 'REMOVE'
            THEN
               l_has_access := get_security_access (g_type_payrun, g_access_payrun_delete);

               IF (l_has_access = FALSE)
               THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
               l_event_name :=  'delete' ;

            END IF;

            --Added for R12 payment security check end.
            l_new_status := 'UNPAID';
         END IF;

         cn_payruns_pkg.UPDATE_RECORD (x_payrun_id                  => p_payrun_id,
                                       x_status                     => l_new_status,
                                       x_last_updated_by            => fnd_global.user_id,
                                       x_last_update_date           => SYSDATE,
                                       x_last_update_login          => fnd_global.login_id,
                                       x_object_version_number      => l_ovn
                                      );
          -- raise wf event
          pmt_raise_event(
                p_type => 'PAYRUN',
                p_event_name  => l_event_name ,
                p_payrun_id   => p_payrun_id ) ;

      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END payrun_audit;


--===================================================================================
-- Procedure : Worksheet_Audit
--   Procedure to update worksheet status and enter audit info into notes
--   This procedure expects validation to have been done already (worksheet_action p_do_audit => fnd_api.g_false)
--===================================================================================
   PROCEDURE worksheet_audit (
      p_worksheet_id             IN       NUMBER,
      p_payrun_id                IN       NUMBER,
      p_salesrep_id              IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_approval_flow         IN       VARCHAR2 := fnd_api.g_true,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Worksheet_Audit';
      l_new_status                  cn_payment_worksheets.worksheet_status%TYPE := NULL;
      l_loading_status              VARCHAR2 (30);
      l_org_id                      NUMBER;
      l_has_access                  BOOLEAN;
      l_ovn                         NUMBER ;
      l_note_msg                 VARCHAR2(240);
      l_note_id                  NUMBER;
      l_msg_name                   VARCHAR2(200);

      l_event_name         VARCHAR2(80);

   BEGIN
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- update worksheet status
      IF p_action = 'LOCK'
      THEN
        l_msg_name:='CN_PAYSHEET_LOCKED_NOTE';
        l_new_status := 'LOCKED';
        l_event_name :=  'lock' ;

      ELSIF p_action = 'UNLOCK' OR p_action = 'REFRESH' OR p_action = 'REMOVE' OR p_action = 'RELEASE_HOLD'
            OR p_action = 'RESET_TO_UNPAID'
      THEN
         IF p_action = 'UNLOCK'
         THEN
            l_msg_name:='CN_PAYSHEET_UNLOCK_NOTE';
            l_event_name :=  'unlock' ;

         ELSIF p_action = 'REFRESH'
         THEN
            l_msg_name:='CN_PAYSHEET_REFRESH_NOTE';
            l_event_name :=  'refresh' ;

         ELSIF p_action = 'REMOVE'
         THEN
            l_msg_name:='CN_PAYESHEET_REMOVE_NOTE';
            l_event_name :=  'delete' ;

         ELSIF p_action = 'RELEASE_HOLD'
         THEN
            l_msg_name:='CN_PAYSHEET_RELEASE_HOLD_NOTE';
            l_event_name :=  'release'  ;

         ELSIF p_action = 'RESET_TO_UNPAID'
         THEN
            l_msg_name:='CN_PAYSHEET_RESET_NOTE';
            l_event_name :=  'release'  ;

         END IF;

         l_new_status := 'UNPAID';

     ELSIF p_action IN ( 'HOLD_ALL', 'RELEASE_ALL' )
     THEN
        IF p_action = 'HOLD_ALL' THEN
            l_msg_name:='CN_PAYSHEET_HOLDALL_NOTE';
            l_event_name :=  'holdall'  ;
        ELSE
            l_msg_name:='CN_PAYSHEET_RELEASEALL_NOTE';
            l_event_name :=  'releaseall'  ;
        END IF ;
        l_new_status := 'PROCESSING' ;

      ELSIF p_action = 'SUBMIT'
      THEN
         l_new_status := 'SUBMITTED';

         IF p_do_approval_flow = fnd_api.g_true
         THEN
            cn_pay_approval_flow_pvt.submit_worksheet (p_api_version        => 1.0,
                                                       x_return_status      => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       p_worksheet_id       => p_worksheet_id
                                                      );

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
         l_msg_name:='CN_PAYSHEET_SUBMIT_NOTE';
         l_event_name :=  'submit'  ;

      ELSIF p_action = 'APPROVE'
      THEN
         l_new_status := 'APPROVED';

         IF p_do_approval_flow = fnd_api.g_true
         THEN
            cn_pay_approval_flow_pvt.approve_worksheet (p_api_version        => 1.0,
                                                        x_return_status      => x_return_status,
                                                        x_msg_count          => x_msg_count,
                                                        x_msg_data           => x_msg_data,
                                                        p_worksheet_id       => p_worksheet_id
                                                       );

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
         l_msg_name:='CN_PAYESHEET_APPROVE_NOTE';
         l_event_name :=  'approve'  ;

      ELSIF p_action = 'REJECT'
      THEN
         l_new_status := 'UNPAID';

         IF p_do_approval_flow = fnd_api.g_true
         THEN
            cn_pay_approval_flow_pvt.reject_worksheet (p_api_version        => 1.0,
                                                       x_return_status      => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       p_worksheet_id       => p_worksheet_id
                                                      );

            IF x_return_status <> fnd_api.g_ret_sts_success
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
         l_msg_name:='CN_PAYESHEET_REJECT_NOTE';
         l_event_name :=  'reject'  ;

      END IF;

      cn_payment_worksheets_pkg.UPDATE_STATUS (p_salesrep_id                => p_salesrep_id,
                                               p_payrun_id                  => p_payrun_id,
                                               p_worksheet_status           => l_new_status
                                              );

      fnd_message.set_name('CN', l_msg_name);
      l_note_msg := fnd_message.get;
      IF p_action <> 'REMOVE' THEN
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_worksheet_id,
                            p_source_object_code      => 'CN_PAYMENT_WORKSHEETS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
      ELSE
         jtf_notes_pub.create_note
                           (p_api_version             => 1.0,
                            x_return_status           => x_return_status,
                            x_msg_count               => x_msg_count,
                            x_msg_data                => x_msg_data,
                            p_source_object_id        => p_payrun_id,
                            p_source_object_code      => 'CN_PAYRUNS',
                            p_notes                   => l_note_msg,
                            p_notes_detail            => l_note_msg,
                            p_note_type               => 'CN_SYSGEN', -- for system generated
                            x_jtf_note_id             => l_note_id -- returned
                           );
      END IF;

      pmt_raise_event(
            p_type => 'WORKSHEET',
            p_event_name  => l_event_name,
            p_payrun_id   => p_payrun_id,
            p_salesrep_id => p_salesrep_id) ;

   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END worksheet_audit;

-- Start of comments
--    API name        : Payrun_Action
--    Type            : Private.
--    Function        : Procedure to check if the payrun action is valid.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_payrun_id       IN  NUMBER
--                      p_action          IN  VARCHAR2
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
   PROCEDURE payrun_action (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_payrun_id                IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_audit                 IN       VARCHAR2 := fnd_api.g_true
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Payrun_Action';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_period_id                   cn_period_statuses.period_id%TYPE;
      l_payrun_status               cn_payruns.status%TYPE;
      l_tmp                         NUMBER;
      l_temp                        NUMBER ;

      CURSOR c
      IS
         SELECT status
         FROM cn_payruns
         WHERE payrun_id = p_payrun_id
         FOR UPDATE OF status NOWAIT
         ;

      tlinfo                        c%ROWTYPE;

      CURSOR cw
      IS
         SELECT worksheet_status
         FROM   cn_payment_worksheets
         WHERE   payrun_id = p_payrun_id
         FOR UPDATE OF worksheet_status NOWAIT
         ;

      tlinfo2                       cw%ROWTYPE;
      err_num                       NUMBER;
      l_has_access                  BOOLEAN;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT payrun_action;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
      -- Get payrun information
      BEGIN
         SELECT pay_period_id,
                status
           INTO l_period_id,
                l_payrun_status
           FROM cn_payruns
          WHERE payrun_id = p_payrun_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PAYRUN_DOES_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
      END;

      BEGIN
         -- lock payrun for update
         OPEN c;

         FETCH c
          INTO tlinfo;

         CLOSE c;

         -- lock worksheet for preventing update while updating payrun
         OPEN cw;

         FETCH cw
          INTO tlinfo2;

         CLOSE cw;
      EXCEPTION
         WHEN OTHERS
         THEN
            err_num := SQLCODE;

            IF err_num = -54
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_OBJECT_VERSION');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE;
            END IF;
      END;

      -- Check if user is Super User. Only super user can perform payrun action
      /* Comment out for R12 payment security
      IF is_superuser(p_period_id => l_period_id) = 0 THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN','CN_PAYRUN_NOT_SU');
       FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_ERROR ;
      END IF;
      */

      -- cannot perform action on paid payrun
      IF l_payrun_status = 'PAID'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PAYRUN_PAID');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- should never perform any payrun action when one of the worksheets is processing
      SELECT COUNT(1)
      INTO l_temp
      FROM cn_payment_worksheets
      WHERE worksheet_status IN ('PROCESSING', 'FAILED')
      AND payrun_id = p_payrun_id
      AND rownum < 2;

      IF l_temp > 0 THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
        THEN
          fnd_message.set_name ('CN', 'CN_WKSHT_STILL_PROCESSING');
          fnd_msg_pub.ADD;
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;

      -- Check for each action
      -- p_action = 'REFRESH' OR 'REMOVE' OR 'FREEZE'
      IF p_action = 'REFRESH' OR p_action = 'REMOVE' OR p_action = 'FREEZE'
      THEN
         --Added for R12 payment security check begin.
         IF p_action = 'REFRESH'
         THEN
            l_has_access := get_security_access (g_type_payrun, g_access_payrun_refresh);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'REMOVE'
         THEN
            l_has_access := get_security_access (g_type_payrun, g_access_payrun_delete);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'FREEZE'
         THEN
            l_has_access := get_security_access (g_type_payrun, g_access_payrun_freeze);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         --Added for R12 payment security check end.
         IF l_payrun_status <> 'UNPAID'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PAYRUN_ACTION_UNPAID');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      -- p_action = 'UNFREEZE'
      ELSIF p_action = 'UNFREEZE'
      THEN
         --Added for R12 payment security check begin.
         l_has_access := get_security_access (g_type_payrun, g_access_payrun_unfreeze);

         IF (l_has_access = FALSE)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         --Added for R12 payment security check end.
         IF l_payrun_status <> 'FROZEN'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_PAYRUN_ACTION_UNFREEZE');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      -- p_action = 'PAY'
      ELSIF p_action = 'PAY'
      THEN
         --Added for R12 payment security check begin.
         l_has_access := get_security_access (g_type_payrun, g_access_payrun_pay);

         IF (l_has_access = FALSE)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         --Added for R12 payment security check end.
         IF NVL (fnd_profile.VALUE ('CN_CHK_WKSHT_STATUS'), 'Y') = 'Y'
         THEN
            -- all worksheet should be 'APPROVED' if profile = 'Y'
            BEGIN
               SELECT 1
                 INTO l_tmp
                 FROM DUAL
                WHERE EXISTS (SELECT 1
                                FROM cn_payment_worksheets
                               WHERE payrun_id = p_payrun_id AND worksheet_status <> 'APPROVED');

               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_PAYRUN_ACTION_PAY');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
         ELSE
            IF l_payrun_status <> 'FROZEN'
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_PAYRUN_ACTION_PAY_FRZ');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      ELSE
         -- invalid p_action
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PAYRUN_ACTION_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF fnd_api.to_boolean (p_do_audit)
      THEN
         -- update audit table and payrun status
         payrun_audit (p_payrun_id          => p_payrun_id,
                       p_action             => p_action,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data
                      );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO payrun_action;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO payrun_action;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO payrun_action;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END payrun_action;

-- Start of comments
--    API name        : Worksheet_action
--    Type            : Private.
--    Function        : Procedure to check if the worksheet action is valid.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_worksheet_id       IN  NUMBER
--                      p_action          IN  VARCHAR2
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--
--    Notes           : Note text
--
-- End of comments
   PROCEDURE worksheet_action (
      p_api_version              IN       NUMBER,
      p_init_msg_list            IN       VARCHAR2 := fnd_api.g_false,
      p_commit                   IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level         IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_worksheet_id             IN       NUMBER,
      p_action                   IN       VARCHAR2,
      p_do_audit                 IN       VARCHAR2 := fnd_api.g_true
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30) := 'Worksheet_action';
      l_api_version        CONSTANT NUMBER := 1.0;
      l_resource_id                 jtf_rs_resource_extns.resource_id%TYPE;
      l_period_id                   cn_period_statuses.period_id%TYPE;
      l_worksheet_rec               cn_payment_worksheets%ROWTYPE;
      l_payrun_status               cn_payruns.status%TYPE;
      l_pay_period_id               cn_payruns.pay_period_id%TYPE;
      l_assigned_to_user_id         cn_salesreps.assigned_to_user_id%TYPE := NULL;
      l_tmp                         NUMBER;
      l_org_id                      NUMBER;

      CURSOR c (
         c_payrun_id                         cn_payruns.payrun_id%TYPE
      )
      IS
         SELECT status
         FROM cn_payruns
         WHERE payrun_id = c_payrun_id
         --FOR UPDATE OF status NOWAIT
         ;

      tlinfo                        c%ROWTYPE;

      CURSOR cw
      IS
         SELECT worksheet_status
         FROM   cn_payment_worksheets
         WHERE  payment_worksheet_id = p_worksheet_id
         --FOR UPDATE OF worksheet_status NOWAIT
         ;

      tlinfo2                       cw%ROWTYPE;
      err_num                       NUMBER;
      l_has_access                  BOOLEAN;
   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT worksheet_action;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
      -- Get worksheet information
      BEGIN
         SELECT wk.payrun_id,
                wk.salesrep_id,
                wk.worksheet_status,
                pay.status,
                pay.pay_period_id,
                s.assigned_to_user_id,
		    pay.org_id
           INTO l_worksheet_rec.payrun_id,
                l_worksheet_rec.salesrep_id,
                l_worksheet_rec.worksheet_status,
                l_payrun_status,
                l_pay_period_id,
                l_assigned_to_user_id,
		    l_org_id
           FROM cn_payment_worksheets wk,
                cn_payruns pay,
                cn_salesreps s
          WHERE wk.payment_worksheet_id = p_worksheet_id
            AND pay.payrun_id = wk.payrun_id
            AND s.salesrep_id = wk.salesrep_id
            --R12
            AND wk.org_id = pay.org_id
            AND wk.org_id = s.org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_DOES_NOT_EXIST');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
      END;

      BEGIN
         -- lock payrun for preventing update while updating wksht
         OPEN c (l_worksheet_rec.payrun_id);

         FETCH c
          INTO tlinfo;

         CLOSE c;

         -- lock worksheet for update
         OPEN cw;

         FETCH cw
          INTO tlinfo2;

         CLOSE cw;
      EXCEPTION
         WHEN OTHERS
         THEN
            err_num := SQLCODE;

            IF err_num = -54
            THEN
               fnd_message.set_name ('CN', 'CN_INVALID_OBJECT_VERSION');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            ELSE
               RAISE;
            END IF;
      END;

      -- cannot perform action on paid payrun
      IF l_payrun_status = 'PAID'
      THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PAYRUN_PAID');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      -- Get login user resource_id
      l_resource_id := NULL;

      BEGIN
         SELECT resource_id
           INTO l_resource_id
           FROM jtf_rs_resource_extns
          WHERE user_id = fnd_global.user_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- resource not exist for this user
            fnd_message.set_name ('CN', 'CN_USER_RESOURCE_NF');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      -- check if user can access this worksheet when
      -- l_assigned_to_user_id is not null
      IF l_assigned_to_user_id IS NOT NULL
      THEN
         -- Bug 3498950 3/8/04 ACHUNG:skip check for super user
         IF (is_superuser (l_pay_period_id,l_org_id) = 1)
         THEN
            NULL;
         ELSE
            BEGIN
               SELECT 1
                 INTO l_tmp
                 FROM DUAL
                WHERE EXISTS (
                         SELECT 1
                           FROM jtf_rs_group_usages u2,
                                jtf_rs_rep_managers m2,
                                jtf_rs_resource_extns_vl re2,

                                -- start inline view
                                --  get all rows for a login user in jtf_rs_rep_managers
                                --  with period = p_period_id
                                (SELECT DISTINCT m1.resource_id,
                                                 GREATEST (pr.start_date, m1.start_date_active) start_date,
                                                 LEAST (pr.end_date, NVL (m1.end_date_active, pr.end_date)) end_date
                                            FROM cn_period_statuses pr,
                                                 jtf_rs_group_usages u1,
                                                 jtf_rs_rep_managers m1
                                           WHERE pr.period_id = l_pay_period_id
                                             AND pr.org_id=l_org_id
                                             AND u1.USAGE = 'COMP_PAYMENT'
                                             AND m1.resource_id = l_resource_id
                                             AND (    (m1.start_date_active <= pr.end_date)
                                                  AND (pr.start_date <= NVL (m1.end_date_active, pr.start_date))
                                                 )
                                             AND u1.GROUP_ID = m1.GROUP_ID
                                             AND m1.parent_resource_id = m1.resource_id
                                             AND m1.hierarchy_type IN ('MGR_TO_MGR', 'REP_TO_REP')
                                             AND m1.CATEGORY <> 'TBH') v3
                          -- end inlive view v3
                         WHERE  re2.user_id = l_assigned_to_user_id
                            AND u2.USAGE = 'COMP_PAYMENT'
                            AND u2.GROUP_ID = m2.GROUP_ID
                            AND m2.parent_resource_id = v3.resource_id
                            AND ((m2.start_date_active <= v3.end_date) AND (v3.start_date <= NVL (m2.end_date_active, v3.start_date)))
                            AND m2.CATEGORY <> 'TBH'
                            AND m2.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP', 'REP_TO_REP')
                            AND m2.resource_id = re2.resource_id);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                  THEN
                     fnd_message.set_name ('CN', 'CN_NO_SRP_ACCESS');
                     fnd_msg_pub.ADD;
                  END IF;

                  RAISE fnd_api.g_exc_error;
            END;

            NULL;
         END IF;                                                                                                                        -- Bug 3498950
      END IF;

      -- Check for each action
      -- p_action = 'REFRESH' OR 'REMOVE' OR 'LOCK' OR 'RELEASE_HOLD'
      IF p_action = 'REFRESH' OR p_action = 'REMOVE' OR p_action = 'LOCK' OR p_action = 'RELEASE_HOLD'
      THEN
         --Added for R12 payment security check begin.
         IF p_action = 'REFRESH'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_refresh);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'REMOVE'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_delete);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'LOCK'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_lock);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'RELEASE_HOLD'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_release_holds);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
        --fix for the Bug 7415126
        IF NVL (fnd_profile.VALUE ('CN_CHK_WKSHT_STATUS'), 'Y') = 'Y'
            THEN
         --Added for R12 payment security check end.
         IF l_payrun_status <> 'UNPAID' OR l_worksheet_rec.worksheet_status <> 'UNPAID'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_UNPAID');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         ELSE

            IF l_payrun_status = 'PAID' OR l_worksheet_rec.worksheet_status <> 'UNPAID'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_UNPAID');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         END IF;



      ELSIF p_action IN ( 'HOLD_ALL' , 'RELEASE_ALL' )
      THEN
        l_has_access := get_security_access (g_type_wksht, g_access_wksht_release_holds);

        IF (l_has_access = FALSE)
        THEN
           RAISE fnd_api.g_exc_error;
        END IF;

         --Added for R12 payment security check end.
         IF l_payrun_status <> 'UNPAID' OR l_worksheet_rec.worksheet_status NOT IN ('PROCESSING', 'UNPAID')
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_NOT_PROCESSING');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

      ELSIF p_action IN ( 'RESET_TO_UNPAID' )
      THEN
        l_has_access := get_security_access (g_type_wksht, g_access_wksht_release_holds);

        IF (l_has_access = FALSE)
        THEN
           RAISE fnd_api.g_exc_error;
        END IF;

         --Added for R12 payment security check end.
         IF l_payrun_status <> 'UNPAID' OR (l_worksheet_rec.worksheet_status NOT IN ('PROCESSING','FAILED'))
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_NOT_PROCESSING');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

      -- p_action = 'UNLOCK'
      ELSIF p_action = 'UNLOCK'
      THEN
         --Added for R12 payment security check begin.
         l_has_access := get_security_access (g_type_wksht, g_access_wksht_unlock);

         IF (l_has_access = FALSE)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         --Added for R12 payment security check end.
         IF l_payrun_status <> 'UNPAID' OR l_worksheet_rec.worksheet_status <> 'LOCKED'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_UNLOCK');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
      -- p_action = 'SUBMIT'
      ELSIF p_action = 'SUBMIT'
      THEN
         --Added for R12 payment security check begin.
         l_has_access := get_security_access (g_type_wksht, g_access_wksht_submit);

         IF (l_has_access = FALSE)
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;

         --Added for R12 payment security check end.
         IF l_worksheet_rec.worksheet_status <> 'LOCKED'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_SUBMIT');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

      ELSIF p_action = 'REJECT' OR p_action = 'APPROVE'
      THEN
         --Added for R12 payment security check begin.
         IF p_action = 'REJECT'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_reject);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF p_action = 'APPROVE'
         THEN
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_approve);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF NVL (fnd_profile.VALUE ('CN_CHK_WKSHT_STATUS'), 'Y') = 'Y'
         THEN

         --Added for R12 payment security check end.
         --- commented by fred
         IF l_worksheet_rec.worksheet_status <> 'SUBMITTED' AND l_worksheet_rec.worksheet_status <> 'APPROVED'
         THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
            THEN
               fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_APPROVE');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         END IF;

            -- only manager or superuser can perform submit and approve
            -- Check if user is manager
            /* comment out as R12 payment security has been changed.
            IF is_superuser(p_period_id => l_pay_period_id) = 0 AND is_manager(p_period_id => l_pay_period_id) = 0 THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.SET_NAME ('CN','CN_WKSHT_NOT_MGR');
                   FND_MSG_PUB.Add;
                END IF;
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            */

          -- l_assigned_to_user_id is null
          -- if wksht is submitted or approved, need to check in
          -- cn_pay_approval_flow table to find out which analysts this wksht
          -- submit_to and see if current user has access to these analyst
          -- only need to check if p_action = SUBMIT or APPROVE
         IF l_assigned_to_user_id IS NULL
         THEN
            -- Bug 3498950 3/8/04 ACHUNG:skip check for super user
            IF (is_superuser (l_pay_period_id,l_org_id) = 1)
            THEN
               NULL;
            ELSE
               BEGIN
                  SELECT 1
                    INTO l_tmp
                    FROM DUAL
                   WHERE EXISTS (
                            SELECT 1
                              FROM jtf_rs_group_usages u2,
                                   jtf_rs_rep_managers m2,

                                   -- start inline view
                                   --  get all rows for a login user in jtf_rs_rep_managers
                                   --  with period = p_period_id
                                   (SELECT DISTINCT m1.resource_id,
                                                    GREATEST (pr.start_date, m1.start_date_active) start_date,
                                                    LEAST (pr.end_date, NVL (m1.end_date_active, pr.end_date)) end_date
                                               FROM cn_period_statuses pr,
                                                    jtf_rs_group_usages u1,
                                                    jtf_rs_rep_managers m1
                                              WHERE pr.period_id = l_pay_period_id
                                                AND pr.org_id=l_org_id
                                                AND u1.USAGE = 'COMP_PAYMENT'
                                                AND m1.resource_id = l_resource_id
                                                AND (    (m1.start_date_active <= pr.end_date)
                                                     AND (pr.start_date <= NVL (m1.end_date_active, pr.start_date))
                                                    )
                                                AND u1.GROUP_ID = m1.GROUP_ID
                                                AND m1.parent_resource_id = m1.resource_id
                                                AND m1.hierarchy_type IN ('MGR_TO_MGR', 'REP_TO_REP')
                                                AND m1.CATEGORY <> 'TBH') v3
                             -- end inlive view v3
                            WHERE  u2.USAGE = 'COMP_PAYMENT'
                               AND u2.GROUP_ID = m2.GROUP_ID
                               AND m2.parent_resource_id = v3.resource_id
                               AND ((m2.start_date_active <= v3.end_date) AND (v3.start_date <= NVL (m2.end_date_active, v3.start_date)))
                               AND m2.CATEGORY <> 'TBH'
                               AND m2.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP', 'REP_TO_REP')
                               AND m2.resource_id IN (SELECT DISTINCT submit_to_resource_id
                                                                 FROM cn_pay_approval_flow
                                                                WHERE payment_worksheet_id = p_worksheet_id));
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
                     THEN
                        fnd_message.set_name ('CN', 'CN_NO_SRP_ACCESS');
                        fnd_msg_pub.ADD;
                     END IF;

                     RAISE fnd_api.g_exc_error;
               END;
            END IF;                                                                                                                     -- Bug 3498950
         END IF;

         -- Chekc if same user try to approve the wksht again
         IF p_action = 'APPROVE'
         THEN
            --Added for R12 payment security check begin.
            l_has_access := get_security_access (g_type_wksht, g_access_wksht_approve);

            IF (l_has_access = FALSE)
            THEN
               RAISE fnd_api.g_exc_error;
            END IF;

            --Added for R12 payment security check end.
            SELECT COUNT (1)
              INTO l_tmp
              FROM cn_pay_approval_flow
             WHERE payment_worksheet_id = p_worksheet_id
             AND submit_by_user_id = fnd_global.user_id AND approval_status = 'APPROVED';

            IF l_tmp > 0
            THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
               THEN
                  fnd_message.set_name ('CN', 'CN_SAME_USER_APPROVE');
                  fnd_msg_pub.ADD;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

      ELSE
         -- invalid p_action
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_WKSHT_ACTION_NOT_EXIST');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      IF fnd_api.to_boolean (p_do_audit)
      THEN
         -- update audit table and worksheet status
         worksheet_audit (p_worksheet_id       => p_worksheet_id,
                          p_payrun_id          => l_worksheet_rec.payrun_id,
                          p_salesrep_id        => l_worksheet_rec.salesrep_id,
                          p_action             => p_action,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data
                         );

         IF x_return_status <> fnd_api.g_ret_sts_success
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO worksheet_action;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO worksheet_action;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
      WHEN OTHERS
      THEN
         ROLLBACK TO worksheet_action;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data, p_encoded => fnd_api.g_false);
   END worksheet_action;

--R12 payment security
   FUNCTION get_security_access (
      p_type                     IN       VARCHAR2,
      p_access                   IN       VARCHAR2
   )
      RETURN BOOLEAN
   IS
      l_ret_val                     BOOLEAN := FALSE;
      l_func_name                   VARCHAR2 (50) := 'CN_PMT';
      l_separator                   VARCHAR2 (1) := '_';
      l_type                        VARCHAR2 (20);
      l_access                      VARCHAR2 (20);
   BEGIN
      --Get permission.
      l_func_name := l_func_name || l_separator || p_type || l_separator || p_access;
      l_ret_val := fnd_function.test_instance (function_name => l_func_name, user_name => fnd_global.user_name);

      --If no access, then push the error on stacks.
      IF l_ret_val = FALSE
      THEN
         IF p_type = g_type_payrun
         THEN
            l_type := 'payment batch';
         ELSIF p_type = g_type_wksht
         THEN
            l_type := 'paysheet';
         END IF;

         l_access := LOWER (p_access);

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error)
         THEN
            fnd_message.set_name ('CN', 'CN_PMT_NO_ACCESS');
            fnd_message.set_token ('TYPE', l_type);
            fnd_message.set_token ('ACCESS', l_access);
            fnd_msg_pub.ADD;
         END IF;
      END IF;                                                                                                                      --l_ret_val = FALSE

      RETURN l_ret_val;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_ret_val := FALSE;
         RETURN l_ret_val;
   END get_security_access;

FUNCTION getPermission(funcName in varchar2)
RETURN varchar2
IS
    l_ret_val BOOLEAN            := FALSE;
    ret VARCHAR2(1)              :='N';

Begin

  l_ret_val := fnd_function.test_instance
                (
                    function_name => funcName,
                    user_name=> fnd_global.user_name
                );

    --If no access, then push the error on stacks.
    IF l_ret_val = TRUE
    THEN
       ret:='Y';
      RETURN ret;
    else
      RETURN ret;
    END IF; --l_ret_val = FALSE


EXCEPTION
    WHEN OTHERS
    THEN
        ret := 'N';

    RETURN ret;

END getPermission;






FUNCTION getDataAccess(p_payrun_id in number,p_assigned_to_user_id  in number,p_user_id in number) return varchar2
as
ret     varchar2(1);
begin
SELECT      DECODE( (SELECT 1 FROM dual WHERE EXISTS ( SELECT 1
                                                   FROM jtf_rs_group_usages u2,jtf_rs_rep_managers m2,jtf_rs_resource_extns_vl re2,
                                                                                  (SELECT DISTINCT m1.resource_id, GREATEST(pr.start_date,m1.start_date_active) start_date,LEAST(pr.end_date,Nvl(m1.end_date_active,pr.end_date)) end_date
                                                                                   FROM cn_period_statuses pr,jtf_rs_group_usages u1, jtf_rs_rep_managers m1
                                                                                   WHERE pr.period_id = (SELECT p1.pay_period_id FROM cn_payruns p1 WHERE p1.payrun_id = p_payrun_id)
													     AND   pr.org_id    =(SELECT org_id FROM cn_payruns where payrun_id=p_payrun_id)
                                                                                   AND u1.usage = 'COMP_PAYMENT'
                                                                                   AND m1.resource_id = ( SELECT resource_id FROM jtf_rs_resource_extns  WHERE user_id = p_user_id)
                                                                                   AND ((m1.start_date_active <= pr.end_date) AND (pr.start_date <= Nvl(m1.end_date_active,pr.start_date)))
                                                                                   AND u1.group_id = m1.group_id
                                                                                   AND m1.parent_resource_id = m1.resource_id
                                                                                   AND m1.hierarchy_type IN ('MGR_TO_MGR','REP_TO_REP') AND m1.category <> 'TBH' ) v3
                                                    WHERE u2.usage = 'COMP_PAYMENT'
                                                    AND   u2.group_id = m2.group_id
                                                    AND   m2.parent_resource_id = v3.resource_id AND ((m2.start_date_active <= v3.end_date)
                                                    AND   (v3.start_date <= Nvl(m2.end_date_active,v3.start_date))) AND m2.category <> 'TBH'
                                                    AND    m2.hierarchy_type IN ('MGR_TO_MGR','MGR_TO_REP','REP_TO_REP')
                                                    AND    m2.resource_id = re2.resource_id
                                                    AND re2.user_id = Nvl(p_assigned_to_user_id,re2.user_id))) ,1,'Y',NULL,'N','N')
                                                    into ret
                                                    from dual;
                                                    return nvl(ret,'N');
end getDataAccess;




FUNCTION UpdPayShtAccess(p_payrun_id in number,p_assigned_to_user_id  in number,p_user_id in number)
return varchar2
as
l_dret     varchar2(1):='Y';
l_sret     varchar2(1):='Y';
begin
l_dret :=getDataAccess(p_payrun_id,p_assigned_to_user_id,p_user_id);
l_sret :=getPermission('CN_PMT_WKSHT_VIEW');


select decode(l_dret,l_sret,decode(l_dret,'Y','Y','N'),'N') into l_sret from dual;
return l_sret;

EXCEPTION
    WHEN OTHERS
    THEN
        l_sret := 'N';

    RETURN l_sret;
end UpdPayShtAccess;

END cn_payment_security_pvt;

/
