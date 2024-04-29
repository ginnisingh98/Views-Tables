--------------------------------------------------------
--  DDL for Package Body OZF_FUND_REQUEST_APR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_REQUEST_APR_PVT" AS
/* $Header: ozfvwfrb.pls 120.1.12010000.3 2009/05/13 12:04:04 nepanda ship $ */

   ----------------------------------------------------------
   --  Start of Comments
   --
   -- NAME
   --   OZF_fund_Request_Apr_PVT
   --
   -- PURPOSE
   --   This package contains all transactions to be done for
   --   Fund Request Approvals and Fund Transfer Approvals
   --   in Oracle Marketing(Funds and Budgets)
   --
   -- HISTORY
   -- 03/22/2001        MUMU PANDE        CREATION
   -- 07/09/2001        MUMU PANDE        Set the subjects in set_trans_Activity_details procedure
   -- 08/14/2001        MUMU PANDE        Updation for a approval_type
   -- 11/06/2001        MUMU PANDE        Updation for updating transferd in amount for child fund
   -- 02/26/2002        MUMU PANDE        Fixed BUG#2241661
   -- 06/18/2002        Mumu Pande        Fixed Bug# 2092868
   -- 07/01/2002        Ying Zhao         Fix bug 2352621
   -- 10/03/2002        Ying Zhao         Fix bug 2577992
   -- 01/27/2003        Ying Zhao         Fix bug 2771105(same as 11.5.8 bug 2753608) APPROVAL NOTE NOT SHOWING IN APPROVAL/REJECTION EMAIL
   -- 03/21/2003        Feliu             Fix bug 2861097.
   -- 01/22/2004        kdass             Fix bug 3390310. Changed the workflow attributes back to AMS from OZF
   -- 04/20/2004        Ribha Mehrotra	  Fix bug 3579649. Send the original amount as null to update_fund api.
   -- 06/17/2004        Ribha Mehrotra    Fix bug 3638512. Set the ams_amount when approver is the requestor.
   -- 29/07/2008        kpatro            Fix bug 7290977
   -- 5/13/2009         nepanda		  Fix for bug 8434546

   g_pkg_name                  CONSTANT VARCHAR2(30) := 'OZF_Fund_Request_Apr_PVT';
   g_file_name                 CONSTANT VARCHAR2(15) := 'ozfvwfrb.pls';
   g_cons_fund_mode            CONSTANT VARCHAR2(30) := 'WORKFLOW';
   -- changed by mpande 08/14/2001
   g_transfer_approval_type    CONSTANT VARCHAR2(30) := 'BUDGET';
   --g_transfer_approval_type    CONSTANT VARCHAR2(30) := 'BUDGET_REQUEST';
   g_budget_source_status      CONSTANT VARCHAR2(30) := 'OZF_BUDGETSOURCE_STATUS';
   g_workflow_process          CONSTANT VARCHAR2(30) := 'AMSGAPP';
   g_item_type                 CONSTANT VARCHAR2(30) := 'AMSGAPP';
   -- addded 08/14/2001 mpande
   g_activity_type             CONSTANT VARCHAR2(30) := 'FREQ';
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Approve_Request
   --
   --
   -- PURPOSE
   --   This Procedure will Update the source and target funds and update the fund_request.
   --
   -- IN
   --p_commit             IN       VARCHAR2 := fnd_api.g_false
   --p_update_status      IN       VARCHAR2 := 'Y'
   --p_fund_request_id    IN       NUMBER
   --p_target_fund_id     IN       NUMBER
   --p_source_fund_id     IN       NUMBER
   --p_requester_id       IN       NUMBER
   --p_approver_id        IN       NUMBER
   --p_requested_amount   IN       NUMBER  both in TRANSFER FROM fund currency
   --
   -- OUT
   --
   -- NOTES
   -- HISTORY
   --   02/20/2001        MUMU PANDE        CREATION
   --   10/22/2001   mpande    Changed code different owner allocation bug
   -- End of Comments
   ------------------------------------------------------------------------------


PROCEDURE approve_request(
      p_commit            IN       VARCHAR2 := fnd_api.g_false
     ,p_update_status     IN       VARCHAR2 := 'Y'
     ,p_act_budget_id     IN       NUMBER
     ,p_target_fund_id    IN       NUMBER
     ,p_source_fund_id    IN       NUMBER
     ,p_requester_id      IN       NUMBER
     ,p_approver_id       IN       NUMBER
     --  ,p_requested_amount   IN       NUMBER   -- both in TRANSFER FROM   fund currency ,(SOURCE)
     -- this is because the amount which goes to the workflow goes in TRANSFER FROM  currency
     -- and also returns in from fund currency
     ,p_requestor_owner   IN       VARCHAR2 := 'N'
     ,p_approved_amount   IN       NUMBER   -- in TARNSFER FROM  fund currency
     ,p_child_flag        IN       VARCHAR2 := 'N'
     ,p_note              IN       VARCHAR2
     ,p_workflow_flag     IN       VARCHAr2 := 'N'-- flag to indicate that th ereor is being updated from workflow
     ,x_return_status     OUT NOCOPY      VARCHAR2
     ,x_msg_count         OUT NOCOPY      NUMBER
     ,x_msg_data          OUT NOCOPY      VARCHAR2)
   IS
      -- Local variables
      l_api_name        CONSTANT VARCHAR2(30)                            := 'Approve_Request';
      l_full_name       CONSTANT VARCHAR2(60)
               := g_pkg_name || '.' || l_api_name;
      l_api_version     CONSTANT NUMBER                                  := 1.0;
      l_return_status            VARCHAR2(1);
      l_msg_count                NUMBER;
      l_msg_data                 VARCHAR2(4000);
      l_object_version_number    NUMBER;
      -- Record variables for creating the fund request.
      l_source_fund_rec          ozf_funds_pvt.fund_rec_type;   -- source fund record
      l_target_fund_rec          ozf_funds_pvt.fund_rec_type;   -- target fund record
      l_act_budget_rec           ozf_actbudgets_pvt.act_budgets_rec_type;   -- fund request record

      -- Cursor to find source fund details
      CURSOR c_fund_detail(
         cv_fund_id   IN   NUMBER)
      IS
         SELECT   original_budget source_org_budget
                 ,transfered_in_amt source_trans_in_amt
                 ,transfered_out_amt source_trans_out_amt
                 ,holdback_amt source_holdback_amt
                 ,currency_code_tc source_currency_code
                 ,object_version_number source_obj_num
         ,committed_amt
         FROM     ozf_funds_all_vl
         WHERE  fund_id = cv_fund_id;

      l_source_rec               c_fund_detail%ROWTYPE;
      l_act_budget_obj_num       NUMBER;

      -- Cursor records
      CURSOR c_target_fund_detail(
         cv_fund_id   IN   NUMBER)
      IS
         SELECT   original_budget target_org_budget
                 ,transfered_in_amt target_trans_in_amt
                 ,status_code target_status_code
                 ,user_status_id target_user_status_id
                 ,currency_code_tc target_currency_code
                 ,object_version_number target_obj_num
         FROM     ozf_funds_all_vl
         WHERE  fund_id = cv_fund_id;

      l_target_rec               c_target_fund_detail%ROWTYPE;

      -- Cursor to find fund_request details
      CURSOR c_act_budget_detail(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   object_version_number
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;

      CURSOR c_to_fund_currency(
         p_to_fund_id   IN   NUMBER)
      IS
         SELECT   currency_code_tc
         FROM     ozf_funds_all_vl
         WHERE  fund_id = p_to_fund_id;

      l_to_currency              VARCHAR2(3);
      l_rate                     NUMBER;
      l_to_curr_approved_amt     NUMBER                                  := 0;
   BEGIN
      SAVEPOINT approve_request;
      -- Initialize
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': start');
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
      OPEN c_fund_detail(p_source_fund_id);
      FETCH c_fund_detail INTO l_source_rec.source_org_budget,
                               l_source_rec.source_trans_in_amt,
                               l_source_rec.source_trans_out_amt,
                               l_source_rec.source_holdback_amt,
                               l_source_rec.source_currency_code,
                               l_source_rec.source_obj_num,
                               l_source_rec.committed_amt;
      IF (c_fund_detail%NOTFOUND) THEN
         CLOSE c_fund_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_fund_detail;

      IF (
            NVL(
               NVL(l_source_rec.source_org_budget, 0) -
               NVL(l_source_rec.source_holdback_amt, 0) +
               NVL(l_source_rec.source_trans_in_amt, 0) -
               NVL(l_source_rec.source_trans_out_amt, 0)-
               NVL(l_source_rec.committed_amt, 0)
              ,0)) <
            p_approved_amount THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_AMT_UNAVAILABLE');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      ----- Convert the approved amount to  the to_fund_currency
      OPEN c_to_fund_currency(p_target_fund_id);
      FETCH c_to_fund_currency INTO l_to_currency;

      IF (c_to_fund_currency%NOTFOUND) THEN
         CLOSE c_to_fund_currency;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_to_fund_currency;

      ---- if the two currncies are different then convert the approved amount into the Transfer to fund currency
      IF l_to_currency <> l_source_rec.source_currency_code THEN
         ozf_utility_pvt.convert_currency(
            x_return_status => l_return_status
           ,p_from_currency => l_source_rec.source_currency_code
           ,p_to_currency => l_to_currency
           ,p_from_amount => p_approved_amount
           ,x_to_amount => l_to_curr_approved_amt
           ,x_rate => l_rate);

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ELSE
         l_to_curr_approved_amt := p_approved_amount;
      END IF;   --/// end if transfer currency

      -- Initialize the fund records
      ozf_funds_pvt.init_fund_rec(x_fund_rec => l_source_fund_rec);
      -- Source record
      l_source_fund_rec.fund_id := p_source_fund_id;
      l_source_fund_rec.object_version_number := l_source_rec.source_obj_num;
      l_source_fund_rec.transfered_out_amt :=
         NVL(l_source_rec.source_trans_out_amt, 0) + p_approved_amount;   -- TRANSFERED IN  AMT
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(
         l_full_name || 'updating source_fund' || l_source_rec.source_obj_num);
      END IF;
      -- Update source fund
      -- Source record
      ozf_funds_pvt.update_fund(
         p_api_version => l_api_version
        ,p_init_msg_list => fnd_api.g_false
        ,p_commit => fnd_api.g_false
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_fund_rec => l_source_fund_rec
        ,p_mode => 'ADJUST');

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_target_fund_detail(p_target_fund_id);
      FETCH c_target_fund_detail INTO l_target_rec.target_org_budget,
                                      l_target_rec.target_trans_in_amt,
                                      l_target_rec.target_status_code,
                                      l_target_rec.target_user_status_id,
                                      l_target_rec.target_currency_code,
                                      l_target_rec.target_obj_num;

      IF (c_target_fund_detail%NOTFOUND) THEN
         CLOSE c_target_fund_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_target_fund_detail;
      ozf_funds_pvt.init_fund_rec(x_fund_rec => l_target_fund_rec);
      -- Target record

      l_target_fund_rec.fund_id := p_target_fund_id;
      l_target_fund_rec.object_version_number := l_target_rec.target_obj_num;

      IF p_child_flag = 'Y' THEN
         /*
         l_target_fund_rec.original_budget :=  NVL(l_to_curr_approved_amt, 0);   ---changed 21st JULY to accomodate
         l_target_fund_rec.transfered_in_amt := fnd_api.g_miss_num;
     */
     -- mpande 11/02/2001 changed
         l_target_fund_rec.original_budget :=  0;
         l_target_fund_rec.transfered_in_amt := NVL(l_to_curr_approved_amt, 0);

         l_target_fund_rec.status_code := 'ACTIVE';
         l_target_fund_rec.user_status_id :=
            ozf_utility_pvt.get_default_user_status(
               'OZF_FUND_STATUS'
              ,l_target_fund_rec.status_code);
      ELSE
         l_target_fund_rec.transfered_in_amt :=
            NVL(l_target_rec.target_trans_in_amt, 0) + l_to_curr_approved_amt;
         -- Transfered In AMT added in to fund currency
         --l_target_fund_rec.original_budget := fnd_api.g_miss_num; --bug fix 3579649:rimehrot
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(
         l_full_name ||
         'updating target_fund' ||
         l_target_fund_rec.status_code ||
         l_target_fund_rec.user_status_id);
      END IF;

      IF p_child_flag = 'Y' THEN
         IF p_requestor_owner = 'N' THEN
            -- Update target fund to active other wise the caller API ( OZF_FUNDRULES_PVT) will update the fund to active
            ozf_funds_pvt.update_fund(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_commit => fnd_api.g_false
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_fund_rec => l_target_fund_rec
              ,p_mode => g_cons_fund_mode);
         ELSIF p_requestor_owner = 'Y' THEN
-- mpande 10/19/2001 commented
/*
        OPEN c_act_budget_detail(p_act_budget_id);
            FETCH c_act_budget_detail INTO l_act_budget_obj_num;

            IF (c_act_budget_detail%NOTFOUND) THEN
               CLOSE c_act_budget_detail;

               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
                  fnd_msg_pub.add;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

            CLOSE c_act_budget_detail;
            --- update th erequest stauts to approved
            ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
            l_act_budget_rec.activity_budget_id := p_act_budget_id;
            l_act_budget_rec.object_version_number := l_act_budget_obj_num;
            -- this will set the status to approved
            l_act_budget_rec.status_code := 'APPROVED';   -- Approved amount
            l_act_budget_rec.comment := p_note;
            l_act_budget_rec.user_status_id :=
               ozf_utility_pvt.get_default_user_status(
                  g_budget_source_status
                 ,l_act_budget_rec.status_code);
            -- Fund request record
            ozf_actbudgets_pvt.update_act_budgets(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_commit => fnd_api.g_false
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_act_budgets_rec => l_act_budget_rec
              ,p_child_approval_flag    => FND_API.g_false
              ,p_requestor_owner_flag   => p_requestor_owner
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
*/
        NULL;
         END IF;
      ELSIF p_child_flag = 'N' THEN
        -- if not a child transfer always update the target fund
         ozf_funds_pvt.update_fund(
            p_api_version => l_api_version
           ,p_init_msg_list => fnd_api.g_false
           ,p_commit => fnd_api.g_false
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
           ,p_fund_rec => l_target_fund_rec
           ,p_mode => 'ADJUST');
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- if the fund transfer is being updated from workflow the request record should be approved
      -- other wise the caller API will make it approved
      -- mpande 09/06/2001 IF p_child_flag = 'N' AND p_workflow_flag = 'Y' THEN
      IF  p_workflow_flag = 'Y' THEN
      -- Fund Request Detail
      OPEN c_act_budget_detail(p_act_budget_id);
      FETCH c_act_budget_detail INTO l_act_budget_obj_num;

      IF (c_act_budget_detail%NOTFOUND) THEN
         CLOSE c_act_budget_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_act_budget_detail;
      ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
      l_act_budget_rec.activity_budget_id := p_act_budget_id;
      l_act_budget_rec.object_version_number := l_act_budget_obj_num;
      l_act_budget_rec.approver_id := p_approver_id;
      l_act_budget_rec.approved_in_currency := l_source_rec.source_currency_code;
      l_act_budget_rec.approved_original_amount := p_approved_amount;
      l_act_budget_rec.status_code := 'APPROVED';   -- Approved amount
      l_act_budget_rec.comment := p_note;
      l_act_budget_rec.user_status_id :=
         ozf_utility_pvt.get_default_user_status(
            g_budget_source_status
           ,l_act_budget_rec.status_code);
      -- Fund request record
      ozf_actbudgets_pvt.update_act_budgets(
         p_api_version => l_api_version
        ,p_init_msg_list => fnd_api.g_false
        ,p_commit => fnd_api.g_false
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_act_budgets_rec => l_act_budget_rec);

      -- Set the return status
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
     END IF ;
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

      -- Conditional commit;
      IF     fnd_api.to_boolean(p_commit)
         AND x_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO approve_request;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO approve_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO approve_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   END approve_request;

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   negative_request
   --
   --
   -- PURPOSE
   --   This Procedure will Update the source and target funds and update the fund_request.
   --   called only when the request is rejected or error occured in approval process
   --   for successful approval, approve_request() is called.
   --
   -- IN
   --p_commit             IN       VARCHAR2 := fnd_api.g_false
   --p_update_status      IN       VARCHAR2 := 'Y'
   --p_fund_request_id    IN       NUMBER
   --p_target_fund_id     IN       NUMBER
   --p_source_fund_id     IN       NUMBER
   --p_requester_id       IN       NUMBER
   --p_approver_id        IN       NUMBER
   --p_requested_amount   IN       NUMBER  both in TRANSFER FROM fund currency
   --p_status_code        IN       VARCAHR2(30)
   --p_user_status_id     IN       NUMBER

   --
   -- OUT
   --
   -- NOTES
   -- HISTORY
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   ------------------------------------------------------------------------------


   PROCEDURE negative_request(
      p_commit            IN       VARCHAR2 := fnd_api.g_false
     ,p_act_budget_id     IN       NUMBER
     ,p_target_fund_id    IN       NUMBER
     ,p_source_fund_id    IN       NUMBER
     ,p_requester_id      IN       NUMBER
     ,p_approver_id       IN       NUMBER
     --  ,p_requested_amount   IN       NUMBER   -- both in TRANSFER FROM   fund currency ,(SOURCE)
     -- this is because the amount which goes to the workflow goes in TRANSFER FROM  currency
     -- and also returns in from fund currency
     ,p_requestor_owner   IN       VARCHAR2 := 'N'
     ,p_approved_amount   IN       NUMBER   -- in TARNSFER FROM  fund currency
     ,p_child_flag        IN       VARCHAR2 := 'N'
     ,p_note              IN       VARCHAR2
     ,p_status_code       IN       VARCHAR2
     ,p_user_status_id    IN       NUMBER
     ,x_return_status     OUT NOCOPY      VARCHAR2
     ,x_msg_count         OUT NOCOPY      NUMBER
     ,x_msg_data          OUT NOCOPY      VARCHAR2
     )
   IS
      -- Local variables
      l_api_name        CONSTANT VARCHAR2(30)                            := 'Rejected_Request';
      l_full_name       CONSTANT VARCHAR2(60)
               := g_pkg_name || '.' || l_api_name;
      l_api_version     CONSTANT NUMBER                                  := 1.0;
      l_return_status            VARCHAR2(1);
      l_msg_count                NUMBER;
      l_msg_data                 VARCHAR2(4000);
      l_object_version_number    NUMBER;
      -- Record variables for creating the fund request.
      l_target_fund_rec          ozf_funds_pvt.fund_rec_type;   -- target fund record
      l_act_budget_rec           ozf_actbudgets_pvt.act_budgets_rec_type;   -- fund request record
      l_act_budget_obj_num       NUMBER;

      -- Cursor records
      CURSOR c_target_fund_detail(
         cv_fund_id   IN   NUMBER)
      IS
         SELECT   original_budget target_org_budget
                 ,transfered_in_amt target_trans_in_amt
                 ,status_code target_status_code
                 ,user_status_id target_user_status_id
                 ,currency_code_tc target_currency_code
                 ,object_version_number target_obj_num
         FROM     ozf_funds_all_vl
         WHERE  fund_id = cv_fund_id;

      l_target_rec               c_target_fund_detail%ROWTYPE;

      -- Cursor to find fund_request details
      CURSOR c_act_budget_detail(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   object_version_number
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;

      CURSOR c_to_fund_currency(
         p_to_fund_id   IN   NUMBER)
      IS
         SELECT   currency_code_tc
         FROM     ozf_funds_all_vl
         WHERE  fund_id = p_to_fund_id;

      l_to_currency              VARCHAR2(3);
      l_rate                     NUMBER;
      l_to_curr_approved_amt     NUMBER                                  := 0;
   BEGIN
      SAVEPOINT negative_request;
      -- Initialize
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': start');
      END IF;
      OPEN c_target_fund_detail(p_target_fund_id);
      FETCH c_target_fund_detail INTO l_target_rec.target_org_budget,
                                      l_target_rec.target_trans_in_amt,
                                      l_target_rec.target_status_code,
                                      l_target_rec.target_user_status_id,
                                      l_target_rec.target_currency_code,
                                      l_target_rec.target_obj_num;

      IF (c_target_fund_detail%NOTFOUND) THEN
         CLOSE c_target_fund_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_target_fund_detail;
      ozf_funds_pvt.init_fund_rec(x_fund_rec => l_target_fund_rec);
      -- Target record

      l_target_fund_rec.fund_id := p_target_fund_id;
      l_target_fund_rec.object_version_number := l_target_rec.target_obj_num;

      /*
      IF p_child_flag = 'Y' THEN
         IF p_status_code = 'REJECTED' THEN
            l_target_fund_rec.status_code := 'REJECTED';
         ELSE
            l_target_fund_rec.status_code := 'DRAFT';
         END IF;
         l_target_fund_rec.user_status_id :=       ozf_utility_pvt.get_default_user_status(
          'OZF_FUND_STATUS'
           ,l_target_fund_rec.status_code);
      ELSE
         l_target_fund_rec.transfered_in_amt :=
            NVL(l_target_rec.target_trans_in_amt, 0) + l_to_curr_approved_amt;
         -- Transfered In AMT added in to fund currency
         l_target_fund_rec.original_budget := fnd_api.g_miss_num;
      END IF;
      */
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(
         l_full_name ||
         'updating target_fund' ||
         l_target_fund_rec.status_code ||
         l_target_fund_rec.user_status_id);
      END IF;

      IF p_child_flag = 'Y' THEN
         IF p_requestor_owner = 'N' THEN
            -- yzhao: 06/28/2002
            IF p_status_code = 'REJECTED' THEN
               l_target_fund_rec.status_code := 'REJECTED';
            ELSE
               l_target_fund_rec.status_code := 'DRAFT';
            END IF;
            l_target_fund_rec.user_status_id := ozf_utility_pvt.get_default_user_status(
                    'OZF_FUND_STATUS'
                  , l_target_fund_rec.status_code);
           -- yzhao: 06/28/2002 end

            -- Update target fund
            ozf_funds_pvt.update_fund(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_commit => fnd_api.g_false
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_fund_rec => l_target_fund_rec
              ,p_mode => g_cons_fund_mode);
         /* -- should never enter in this because reject is never called
       ELSIF p_requestor_owner = 'Y' THEN
            OPEN c_act_budget_detail(p_act_budget_id);
            FETCH c_act_budget_detail INTO l_act_budget_obj_num;

            IF (c_act_budget_detail%NOTFOUND) THEN
               CLOSE c_act_budget_detail;

               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
                  fnd_msg_pub.add;
               END IF;

               RAISE fnd_api.g_exc_error;
            END IF;

            CLOSE c_act_budget_detail;
            --- update th erequest stauts to pending before submitting
            ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
            l_act_budget_rec.activity_budget_id := p_act_budget_id;
            l_act_budget_rec.object_version_number := l_act_budget_obj_num;
            -- this will set the status to pending
            l_act_budget_rec.status_code := 'APPROVED';   -- Approved amount
            l_act_budget_rec.user_status_id :=
               ozf_utility_pvt.get_default_user_status(
                  g_budget_source_status
                 ,l_act_budget_rec.status_code);
            -- Fund request record
            ozf_actbudgets_pvt.update_act_budgets(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_commit => fnd_api.g_false
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_act_budgets_rec => l_act_budget_rec
              ,p_child_approval_flag => FND_API.g_true
          );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         END IF;

      ELSIF p_child_flag = 'N' THEN
         ozf_funds_pvt.update_fund(
            p_api_version => l_api_version
           ,p_init_msg_list => fnd_api.g_false
           ,p_commit => fnd_api.g_false
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
           ,p_fund_rec => l_target_fund_rec
           ,p_mode => 'ADJUST');
         */
         END IF;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Fund Request Detail
      OPEN c_act_budget_detail(p_act_budget_id);
      FETCH c_act_budget_detail INTO l_act_budget_obj_num;

      IF (c_act_budget_detail%NOTFOUND) THEN
         CLOSE c_act_budget_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_act_budget_detail;
      ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
      l_act_budget_rec.activity_budget_id := p_act_budget_id;
      l_act_budget_rec.object_version_number := l_act_budget_obj_num;
      --   l_act_budget_rec.approved_amount := p_approved_amount;   -- Approved amount
      --   l_act_budget_rec.approver_id := p_approver_id;   -- Approved amount
      -- changed on 6/24/2002 for ENH#2352621
      l_act_budget_rec.status_code := p_status_code;
      l_act_budget_rec.user_status_id :=
         ozf_utility_pvt.get_default_user_status(
            g_budget_source_status
           ,l_act_budget_rec.status_code);
      l_act_budget_rec.comment := p_note;
      -- Fund request record
      ozf_actbudgets_pvt.update_act_budgets(
         p_api_version => l_api_version
        ,p_init_msg_list => fnd_api.g_false
        ,p_commit => fnd_api.g_false
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_act_budgets_rec => l_act_budget_rec);

      -- Set the return status
      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

      -- Conditional commit;
      IF     fnd_api.to_boolean(p_commit)
         AND x_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO negative_request;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO negative_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO negative_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   END negative_request;

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Create_Fund_Request
   --
   --
   -- PURPOSE
   --   This Procedure will create the fund request
   --
   --
   -- IN
   --  p_commit               IN       VARCHAR2 := fnd_api.g_false
   --  p_update_status        IN       VARCHAR2 := 'Y'
   --  p_approval_for         IN       VARCHAR2 := 'FUND'
   --  p_approval_for_id      IN       NUMBER
   --  p_requester_id         IN       NUMBER
   --  p_requested_amount     IN       NUMBER
   --  p_approval_fm          IN       VARCHAR2 := 'FUND'
   --  p_approval_fm_id       IN       NUMBER DEFAULT NULL
   --  p_transfer_type        IN       VARCHAR2 := 'TRANSFER'   --- 'REQUEST' OR 'TRANSFER'
   --  p_child_flag           IN       VARCHAR2 := 'N'   -- flag to indicate wether it is a child fund creation
   --  p_act_budget_id        IN       NUMBER := NULL   -- request_id ( for a child fund it is null)
   --  p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false
   --  p_justification        IN       VARCHAR2
   --
   -- OUT
   --  x_return_status        OUT      VARCHAR2
   --  x_msg_count            OUT      NUMBER
   --  x_msg_data             OUT      VARCHAR2
   --  x_request_id           OUT      NUMBER
   --  x_approver_id          OUT      NUMBER
   --  x_is_requester_owner   OUT      VARCHAR2   -- Use this variable to conditionally trigger the workflow if value ='NO'

   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   PROCEDURE create_fund_request(
      p_commit               IN       VARCHAR2 := fnd_api.g_false
     ,p_update_status        IN       VARCHAR2 := 'Y'
     ,p_approval_for         IN       VARCHAR2 := 'FUND'
     ,p_approval_for_id      IN       NUMBER
     ,p_requester_id         IN       NUMBER
     ,p_requested_amount     IN       NUMBER
     ,p_approval_fm          IN       VARCHAR2 := 'FUND'
     -- ,p_approval_fm_id       IN       NUMBER DEFAULT NULL   yzhao: fix GSCC. default can only be defined in spec.
     ,p_approval_fm_id       IN       NUMBER
     ,p_transfer_type        IN       VARCHAR2 := 'REQUEST'   --- 'REQUEST' OR 'TRANSFER'
     ,p_child_flag           IN       VARCHAR2 := 'N'  -- flag to indicate whether it is a child fund creation
     ,p_act_budget_id        IN       NUMBER := NULL   -- request_id ( for a child fund it is null)
     ,p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false
     ,p_justification        IN       VARCHAR2
     ,p_allocation_flag      IN       VARCHAR2 := 'N'  -- flag to indicate whether it is an allocation or not
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_msg_count            OUT NOCOPY      NUMBER
     ,x_msg_data             OUT NOCOPY      VARCHAR2
     ,x_request_id           OUT NOCOPY      NUMBER
     ,x_approver_id          OUT NOCOPY      NUMBER
     ,x_is_requester_owner   OUT NOCOPY      VARCHAR2   -- Use this variable to conditionally trigger the workflow if value ='NO'
                                              )
   IS
      -- Local variables
      l_api_version        CONSTANT NUMBER                                  := 1.0;
      l_return_status               VARCHAR2(1)
            := fnd_api.g_ret_sts_success;
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2(4000);
      l_api_name           CONSTANT VARCHAR2(30)
               := 'Create_Fund_Request';
      l_full_name          CONSTANT VARCHAR2(60)
               := g_pkg_name || '.' || l_api_name;
      -- Record variables for creating the fund request.
      l_act_budget_rec              ozf_actbudgets_pvt.act_budgets_rec_type;
      l_target_fund_rec             ozf_funds_pvt.fund_rec_type;
      l_object_version_number       NUMBER;
      l_to_currency                 VARCHAR2(30);
      l_rate                        NUMBER;
      --- local variable to hold the requested amount converted in transfer from fund currency
      l_fm_curr_requested_amount    NUMBER;
      l_fm_currency                 VARCHAR2(30);
      l_fund_objvernum              NUMBER;
      l_act_budget_id               NUMBER                                  := p_act_budget_id;
      l_reject_status_id            NUMBER;
      l_new_status_id               NUMBER;
      x_child_approver_id           NUMBER;

      CURSOR c_fund_detail(
         cv_fund_id   NUMBER)
      IS
         SELECT   object_version_number
         FROM     ozf_funds_all_b
         WHERE  fund_id = cv_fund_id;

      -- Cursor to find the owner of the parent fund
      CURSOR c_parent_fund_owner(
         p_parent_fund_id   NUMBER)
      IS
         SELECT   owner
         FROM     ozf_funds_all_b
         WHERE  fund_id = p_parent_fund_id;

      -- cursors to get the transfer from and transfer to currency
      CURSOR c_fm_fund_currency(
         p_fm_fund_id   IN   NUMBER)
      IS
         SELECT   currency_code_tc
         FROM     ozf_funds_all_vl
         WHERE  fund_id = p_fm_fund_id;

      -- cursors to get the transfer from and transfer to currency
      CURSOR c_to_fund_currency(
         p_to_fund_id   IN   NUMBER)
      IS
         SELECT   currency_code_tc
         FROM     ozf_funds_all_vl
         WHERE  fund_id = p_to_fund_id;

      -- cursor to get the act_budget_rec info ( request info)
      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   object_version_number
                 ,request_amount
                 ,user_status_id
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;

      l_act_budget_appr_rec         c_act_budget_rec%ROWTYPE;
   BEGIN
      SAVEPOINT create_fund_request;
      x_return_status := fnd_api.g_ret_sts_success;
      -- Initialize
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF p_child_flag = 'Y' THEN
         -- Initialize the request variable prior to creating the request
         l_act_budget_rec.status_code := 'NEW';
         l_act_budget_rec.user_status_id :=
            ozf_utility_pvt.get_default_user_status(
               g_budget_source_status
              ,l_act_budget_rec.status_code);
         l_act_budget_rec.arc_act_budget_used_by := 'FUND';   -- hardcoded to fund
         l_act_budget_rec.act_budget_used_by_id := p_approval_for_id;
         l_act_budget_rec.requester_id := p_requester_id;
         l_act_budget_rec.request_amount := p_requested_amount;   --- in transferring to fund currency
         l_act_budget_rec.budget_source_type := p_approval_fm;
         l_act_budget_rec.budget_source_id := p_approval_fm_id;
         l_act_budget_rec.justification := p_justification;
         l_act_budget_rec.transfer_type := p_transfer_type;
         l_act_budget_rec.transaction_type := 'CREDIT';
         --l_act_budget_rec.date_required_by := p_needbydate;
         -- Create_transfer record
         ozf_actbudgets_pvt.create_act_budgets(
            p_api_version => l_api_version
           ,x_return_status => l_return_status
           ,x_msg_count => l_msg_count
           ,x_msg_data => l_msg_data
           ,p_act_budgets_rec => l_act_budget_rec
           ,x_act_budget_id => l_act_budget_id);

         ------------if no request is created terminate the process
         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message(l_full_name || ': end creating request');
         END IF;
      END IF;

      -- Get parent fund owner for the p_approval_fm_id
      OPEN c_parent_fund_owner(p_approval_fm_id);
      FETCH c_parent_fund_owner INTO x_approver_id;

      IF (c_parent_fund_owner%NOTFOUND) THEN
         CLOSE c_parent_fund_owner;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_parent_fund_owner;

	-- nepanda : fix for bug # 8434546 : start
        -- Get current fund owner
 	       OPEN c_parent_fund_owner(p_approval_for_id);
 	       FETCH c_parent_fund_owner INTO x_child_approver_id;

 	        IF (c_parent_fund_owner%NOTFOUND) THEN
 	          CLOSE c_parent_fund_owner;

 	          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
 	             fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
 	             fnd_msg_pub.add;
 	          END IF;

 	          RAISE fnd_api.g_exc_error;
 	       END IF;

 	       CLOSE c_parent_fund_owner;
   -- 10/22/2001   mpande    Changed code different owner allocation bug
      IF p_allocation_flag = 'Y' THEN
         -- no approval required for allocation
         x_is_requester_owner := 'Y';
      ELSE
          -- Check if requester is also the owner of the parent fund OR child fund owner is same as parent fund owner
         IF x_approver_id = p_requester_id OR x_approver_id = x_child_approver_id THEN
            x_is_requester_owner := 'Y';
         ELSE
            x_is_requester_owner := 'N';
         END IF;
      END IF;

      ----- check if the from and to currency are same
         OPEN c_fm_fund_currency(p_approval_fm_id);
         FETCH c_fm_fund_currency INTO l_fm_currency;

         IF (c_fm_fund_currency%NOTFOUND) THEN
            CLOSE c_fm_fund_currency;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_fm_fund_currency;
         OPEN c_to_fund_currency(p_approval_for_id);
         FETCH c_to_fund_currency INTO l_to_currency;

         IF (c_to_fund_currency%NOTFOUND) THEN
            CLOSE c_to_fund_currency;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_to_fund_currency;

         ---- if the two currncies are different then convert the requested amount into the Transfer from fund currency
         IF l_to_currency <> l_fm_currency THEN
            ozf_utility_pvt.convert_currency(
               x_return_status => l_return_status
              ,p_from_currency => l_to_currency
              ,p_to_currency => l_fm_currency
              ,p_from_amount => p_requested_amount
              ,x_to_amount => l_fm_curr_requested_amount
              ,x_rate => l_rate);

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
         ELSE
            l_fm_curr_requested_amount := NVL(p_requested_amount, 0);   -- when currencies are the same the
         END IF;   -- end if transfer currency
         OPEN c_act_budget_rec(l_act_budget_id);
         FETCH c_act_budget_rec INTO l_act_budget_appr_rec.object_version_number,
                                     l_act_budget_appr_rec.request_amount,
                                     l_act_budget_appr_rec.user_status_id;

         IF (c_act_budget_rec%NOTFOUND) THEN
            CLOSE c_act_budget_rec;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         CLOSE c_act_budget_rec;

         IF p_child_flag = 'Y' THEN
            -- change the act_budget statuscdode = 'PENDING'
            ---update the request stauts to pending before submitting if requestor owner is same then the
        -- transfer would become approved directly
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': beforing updating child approval to pending');
      END IF;
            ozf_actbudgets_pvt.init_act_budgets_rec(l_act_budget_rec);
            l_act_budget_rec.activity_budget_id := l_act_budget_id;
            l_act_budget_rec.object_version_number := l_act_budget_appr_rec.object_version_number;
            l_act_budget_rec.status_code := 'APPROVED';   -- Approved amount
            l_act_budget_rec.user_status_id :=
               ozf_utility_pvt.get_default_user_status(
                  g_budget_source_status
                 ,l_act_budget_rec.status_code);
            -- Fund request record
            ozf_actbudgets_pvt.update_act_budgets(
               p_api_version => l_api_version
              ,p_init_msg_list => fnd_api.g_false
              ,p_commit => fnd_api.g_false
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_act_budgets_rec => l_act_budget_rec
              ,p_child_approval_flag => FND_API.g_true
              -- 10/22/2001   mpande    Changed code different owner allocation bug
              ,p_requestor_owner_flag =>x_is_requester_owner );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            -- if child fund the object veriosn number is +1
            l_act_budget_appr_rec.object_version_number := l_act_budget_appr_rec.object_version_number +1 ;
         END IF;   -- end if for child fund

      -- If the parent fund owner and the requester are the same then call Approve_Request
      -- else trigger the workflow
      IF x_is_requester_owner = 'Y' THEN
         -- apporve it directly if requester and owner is the same
            approve_request(
               p_commit => fnd_api.g_false
              ,p_update_status => p_update_status
              ,p_act_budget_id => l_act_budget_id
              ,p_target_fund_id => p_approval_for_id
              ,p_source_fund_id => p_approval_fm_id
              ,p_requester_id => p_requester_id
              ,p_requestor_owner => x_is_requester_owner
              ,p_approver_id => x_approver_id
              --          ,p_requested_amount => l_fm_curr_requested_amount   -- should be passed transferring fm fund_currency
              ,p_approved_amount => l_fm_curr_requested_amount   -- in transferring fm fund_currency
              ,p_note => NULL
              ,p_child_flag => p_child_flag
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data);

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
      ELSIF x_is_requester_owner = 'N' THEN

         l_new_status_id :=
            ozf_utility_pvt.get_default_user_status(g_budget_source_status, 'APPROVED');
         l_reject_status_id :=
            ozf_utility_pvt.get_default_user_status(g_budget_source_status, 'REJECTED');
         -- 08/14/2001 mpande changed activity type
          --only for child budget creation.
	 IF p_child_flag = 'Y' THEN

	   ams_gen_approval_pvt.startprocess(
            p_activity_type => g_activity_type
           ,p_activity_id => l_act_budget_id
           ,p_approval_type => g_transfer_approval_type
           ,p_object_version_number => l_act_budget_appr_rec.object_version_number + 1
           ,p_orig_stat_id => l_act_budget_appr_rec.user_status_id
           ,p_new_stat_id => l_new_status_id
           ,p_reject_stat_id => l_reject_status_id
           ,p_requester_userid => p_requester_id
           ,p_notes_from_requester => p_justification
           ,p_workflowprocess => g_workflow_process
           ,p_item_type => g_item_type
           ,p_gen_process_flag => p_child_flag);
         -- update the request status to pending here.
        END IF; -- end of child flag.

      END IF;   -- ENDIF x_is_requester_owner

      -- Conditional commit;
      IF     fnd_api.to_boolean(p_commit)
         AND x_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_fund_request;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_fund_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO create_fund_request;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   END create_fund_request;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_FYI
   --
   -- PURPOSE
   --   Generate the FYI Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION

   PROCEDURE notify_requestor_fyi(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2)
   IS
      l_api_name            VARCHAR2(61)             := g_pkg_name || 'Notify_Requestor_FYI';
      l_hyphen_pos1         NUMBER;
      l_fyi_notification    VARCHAR2(10000);
      l_activity_type       VARCHAR2(30);
      l_item_type           VARCHAR2(30);
      l_item_key            VARCHAR2(30);
      l_approval_type       VARCHAR2(30);
      l_approver            VARCHAR2(200);
      l_note                VARCHAR2(4000);
      l_string              VARCHAR2(2500);
      l_string1             VARCHAR2(2500);
      l_requester           VARCHAR2(360);
      l_string2             VARCHAR2(2500);
      l_requested_amt       NUMBER;
      l_reason_meaning      VARCHAR2(2000);
      l_act_budget_id       NUMBER;

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act.request_date
                 ,act.budget_source_id approval_from_id
                 ,fund1.short_name from_budget_name
                 ,fund1.owner_full_name from_budget_owner_name
                 ,fund1.fund_number from_budget_number
                 ,fund1.currency_code_tc from_budget_curr
                 ,act.act_budget_used_by_id approval_for_id
                 ,fund2.short_name to_budget_name
                 ,fund2.owner_full_name to_budget_owner_name
                 ,fund2.fund_number to_budget_number
                 ,fund2.currency_code_tc to_budget_curr
                 ,act.date_required_by
                 ,act.reason_code
         FROM     ozf_act_budgets act
                 ,ozf_fund_details_v fund1
                 ,ozf_fund_details_v fund2
         WHERE  activity_budget_id = p_act_budget_id
            AND act.budget_source_id = fund1.fund_id
            AND act.act_budget_used_by_id = fund2.fund_id;

      l_request_rec         c_act_budget_rec%ROWTYPE;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      END IF;
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
      l_activity_type :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_TYPE');
      l_act_budget_id :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_ID');
      l_requested_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_REQUESTED_AMOUNT');
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'AMS_NOTES_FROM_REQUESTOR');
      l_approver :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_APPROVER_DISPLAY_NAME');
      OPEN c_act_budget_rec(l_act_budget_id);
      FETCH c_act_budget_rec INTO l_request_rec;
      CLOSE c_act_budget_rec;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_FYI_SUB');
      fnd_message.set_token('BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string := fnd_message.get;
      wf_engine.setitemattrtext(
         itemtype => l_item_type
        ,itemkey => l_item_key
        ,aname => 'FYI_SUBJECT'
        ,avalue => l_string);
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUEST_INFO');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      fnd_message.set_token('REQUEST_DATE', l_request_rec.request_date, FALSE);
      fnd_message.set_token('FROM_BUDGET_NAME', l_request_rec.from_budget_name, FALSE);
      fnd_message.set_token('FROM_BUDGET_NUMBER', l_request_rec.from_budget_number, FALSE);
      fnd_message.set_token('FROM_BUDGET_OWNER', l_request_rec.from_budget_owner_name, FALSE);
      fnd_message.set_token('TO_BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('To_BUDGET_NUMBER', l_request_rec.to_budget_number, FALSE);
      fnd_message.set_token('TO_BUDGET_OWNER', l_request_rec.to_budget_owner_name, FALSE);
      fnd_message.set_token('REQUIRED_BY_DATE', l_request_rec.date_required_by, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('REQUEST_AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('JUSTIFICATION', l_note, FALSE);
      l_reason_meaning :=
         ozf_utility_pvt.get_lookup_meaning('AMS_TRANSFER_REASON', l_request_rec.reason_code);
      fnd_message.set_token('REASON', l_reason_meaning, FALSE);
      l_string1 := fnd_message.get;

      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'APPROVAL_NOTE');

      /*
      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
     */
      --  IF (display_type = 'text/plain') THEN
      l_fyi_notification :=
         l_string || fnd_global.local_chr(10) || l_string1 || fnd_global.local_chr(10) || l_string2;
      document := document || l_fyi_notification;
      document_type := 'text/plain';
      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_fyi_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'Notify_requestor_FYI', l_item_type, l_item_key);
         RAISE;
   END notify_requestor_fyi;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of Approval
   --
   -- PURPOSE
   --   Generate the Approval Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
   ----------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_approval(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2)
   IS
      l_api_name             VARCHAR2(100)
            := g_pkg_name || 'Notify_Requestor_of_approval';
      l_hyphen_pos1          NUMBER;
      l_appr_notification    VARCHAR2(10000);
      l_activity_type        VARCHAR2(30);
      l_item_type            VARCHAR2(30);
      l_item_key             VARCHAR2(30);
      l_approval_type        VARCHAR2(30);
      l_approver             VARCHAR2(200);
      l_note                 VARCHAR2(4000);
      l_approver_note        VARCHAR2(4000);
      l_approved_amt         NUMBER;
      l_string               VARCHAR2(2500);
      l_string1              VARCHAR2(2500);
      l_requester            VARCHAR2(360);
      l_string2              VARCHAR2(2500);
      l_requested_amt        NUMBER;
      l_reason_meaning       VARCHAR2(2000);
      l_act_budget_id        NUMBER;

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act.request_date
                 ,act.budget_source_id approval_from_id
                 ,fund1.short_name from_budget_name
                 ,fund1.owner_full_name from_budget_owner_name
                 ,fund1.fund_number from_budget_number
                 ,fund1.currency_code_tc from_budget_curr
                 ,act.act_budget_used_by_id approval_for_id
                 ,fund2.short_name to_budget_name
                 ,fund2.owner_full_name to_budget_owner_name
                 ,fund2.fund_number to_budget_number
                 ,fund2.currency_code_tc to_budget_curr
                 ,act.date_required_by
                 ,act.reason_code
         FROM     ozf_act_budgets act
                 ,ozf_fund_details_v fund1
                 ,ozf_fund_details_v fund2
         WHERE  activity_budget_id = p_act_budget_id
            AND act.budget_source_id = fund1.fund_id
            AND act.act_budget_used_by_id = fund2.fund_id;

      l_request_rec          c_act_budget_rec%ROWTYPE;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      END IF;
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
      l_activity_type :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_TYPE');
      l_act_budget_id :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_ID');
      l_requested_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_REQUESTED_AMOUNT');
      l_approved_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_AMOUNT');
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'AMS_NOTES_FROM_REQUESTOR');
      l_approver :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_APPROVER');

      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) APPROVAL NOTE NOT SHOWING IN APPROVAL EMAIL */
      l_approver_note          :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) ends - APPROVAL NOTE NOT SHOWING IN APPROVAL EMAIL */

      OPEN c_act_budget_rec(l_act_budget_id);
      FETCH c_act_budget_rec INTO l_request_rec;
      CLOSE c_act_budget_rec;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_APP_SUB');
      fnd_message.set_token('BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      -- fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      -- fnd_message.set_token('AMOUNT', l_approved_amt, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string := fnd_message.get;
      wf_engine.setitemattrtext(
         itemtype => l_item_type
        ,itemkey => l_item_key
        ,aname => 'APRV_SUBJECT'
        ,avalue => l_string);
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUEST_INFO');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      fnd_message.set_token('REQUEST_DATE', l_request_rec.request_date, FALSE);
      fnd_message.set_token('FROM_BUDGET_NAME', l_request_rec.from_budget_name, FALSE);
      fnd_message.set_token('FROM_BUDGET_NUMBER', l_request_rec.from_budget_number, FALSE);
      fnd_message.set_token('FROM_BUDGET_OWNER', l_request_rec.from_budget_owner_name, FALSE);
      fnd_message.set_token('TO_BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('To_BUDGET_NUMBER', l_request_rec.to_budget_number, FALSE);
      fnd_message.set_token('TO_BUDGET_OWNER', l_request_rec.to_budget_owner_name, FALSE);
      fnd_message.set_token('REQUIRED_BY_DATE', l_request_rec.date_required_by, FALSE);
      -- commented on 10/22/2001 mpande
      -- yzhao: 01/23/2003 uncomment following 2 lines as tokens are defined in message
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('REQUEST_AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('JUSTIFICATION', l_note, FALSE);
      l_reason_meaning :=
         ozf_utility_pvt.get_lookup_meaning('AMS_TRANSFER_REASON', l_request_rec.reason_code);
      fnd_message.set_token('REASON', l_reason_meaning, FALSE);
      l_string1 := fnd_message.get;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_ADDENDUM');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('AMOUNT', l_approved_amt, FALSE);
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) APPROVAL NOTE NOT SHOWING IN APPROVAL EMAIL
      fnd_message.set_token('NOTES_FROM_APPROVER', l_note, FALSE); */
      fnd_message.set_token('NOTES_FROM_APPROVER', l_approver_note, FALSE);
      l_string2 := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');


      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      --  IF (display_type = 'text/plain') THEN
      l_appr_notification :=
         l_string || fnd_global.local_chr(10) || l_string1 || fnd_global.local_chr(10) || l_string2;
      document := document || l_appr_notification;
      document_type := 'text/plain';
      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'Notify_requestor_FYI', l_item_type, l_item_key);
         RAISE;
   END notify_requestor_of_approval;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_requestor_of rejection
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION
   -------------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_rejection(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2)
   IS
      l_api_name            VARCHAR2(100)
            := g_pkg_name || 'Notify_Requestor_of_rejection';
      l_act_budget_id       NUMBER;
      l_hyphen_pos1         NUMBER;
      l_rej_notification    VARCHAR2(10000);
      l_activity_type       VARCHAR2(30);
      l_item_type           VARCHAR2(30);
      l_item_key            VARCHAR2(30);
      l_approval_type       VARCHAR2(30);
      l_approver            VARCHAR2(200);
      l_note                VARCHAR2(4000);
      l_approved_amt        NUMBER;
      l_string              VARCHAR2(2500);
      l_string1             VARCHAR2(2500);
      l_start_date          DATE;
      l_requester           VARCHAR2(360);
      l_string2             VARCHAR2(2500);
      l_requested_amt       NUMBER;
      l_reason_meaning      VARCHAR2(2000);

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act.request_date
                 ,act.budget_source_id approval_from_id
                 ,fund1.short_name from_budget_name
                 ,fund1.owner_full_name from_budget_owner_name
                 ,fund1.fund_number from_budget_number
                 ,fund1.currency_code_tc from_budget_curr
                 ,act.act_budget_used_by_id approval_for_id
                 ,fund2.short_name to_budget_name
                 ,fund2.owner_full_name to_budget_owner_name
                 ,fund2.fund_number to_budget_number
                 ,fund2.currency_code_tc to_budget_curr
                 ,act.date_required_by
                 ,act.reason_code
         FROM     ozf_act_budgets act
                 ,ozf_fund_details_v fund1
                 ,ozf_fund_details_v fund2
         WHERE  activity_budget_id = p_act_budget_id
            AND act.budget_source_id = fund1.fund_id
            AND act.act_budget_used_by_id = fund2.fund_id;

      l_request_rec         c_act_budget_rec%ROWTYPE;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      END IF;
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
      l_activity_type :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_TYPE');
      l_act_budget_id :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_ID');
      l_requested_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_REQUESTED_AMOUNT');
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'AMS_NOTES_FROM_REQUESTOR');
      l_approver :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_APPROVER');
      OPEN c_act_budget_rec(l_act_budget_id);
      FETCH c_act_budget_rec INTO l_request_rec;
      CLOSE c_act_budget_rec;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_REJ_SUB');
      fnd_message.set_token('BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string := fnd_message.get;
      wf_engine.setitemattrtext(
         itemtype => l_item_type
        ,itemkey => l_item_key
        ,aname => 'REJECT_SUBJECT'
        ,avalue => l_string);
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUEST_INFO');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      fnd_message.set_token('REQUEST_DATE', l_request_rec.request_date, FALSE);
      fnd_message.set_token('FROM_BUDGET_NAME', l_request_rec.from_budget_name, FALSE);
      fnd_message.set_token('FROM_BUDGET_NUMBER', l_request_rec.from_budget_number, FALSE);
      fnd_message.set_token('FROM_BUDGET_OWNER', l_request_rec.from_budget_owner_name, FALSE);
      fnd_message.set_token('TO_BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('To_BUDGET_NUMBER', l_request_rec.to_budget_number, FALSE);
      fnd_message.set_token('TO_BUDGET_OWNER', l_request_rec.to_budget_owner_name, FALSE);
      fnd_message.set_token('REQUIRED_BY_DATE', l_request_rec.date_required_by, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('REQUEST_AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('JUSTIFICATION', l_note, FALSE);
      l_reason_meaning :=
         ozf_utility_pvt.get_lookup_meaning('AMS_TRANSFER_REASON', l_request_rec.reason_code);
      fnd_message.set_token('REASON', l_reason_meaning, FALSE);
      --               l_string1 := Substr(FND_MESSAGE.Get,1,2500);
      l_string1 := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');


      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */

      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) APPROVer's NOTE NOT SHOWING IN rejection EMAIL */
      l_note          :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );
      fnd_message.set_name ('OZF', 'OZF_WF_NTF_APPROVER_NOTE');
      fnd_message.set_token ('NOTES_FROM_APPROVER', l_note, FALSE);
      l_string2 := SUBSTR(FND_MESSAGE.Get, 1, 2500);
      /* yzhao: 01/23/2003 fix bug 2771105(same as 11.5.8 bug 2753608) ends - APPROVer's NOTE NOT SHOWING IN rejection EMAIL */

      --  IF (display_type = 'text/plain') THEN
      l_rej_notification :=
         l_string || fnd_global.local_chr(10) || l_string1 || fnd_global.local_chr(10) || l_string2;
      document := document || l_rej_notification;
      document_type := 'text/plain';
      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'Notify_requestor_of_rejection', l_item_type, l_item_key);
         RAISE;
   END notify_requestor_of_rejection;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Notify_approval_required
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION


   PROCEDURE notify_approval_required(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2)
   IS
      l_api_name               VARCHAR2(100)            := g_pkg_name || 'Notify_approval_required';
      l_hyphen_pos1            NUMBER;
      l_appreq_notification    VARCHAR2(10000);
      l_activity_type          VARCHAR2(30);
      l_item_type              VARCHAR2(30);
      l_item_key               VARCHAR2(30);
      l_approval_type          VARCHAR2(30);
      l_forwarder              VARCHAR2(360);
      l_note                   VARCHAR2(4000);
      l_requested_amt          NUMBER;
      l_approved_amt           NUMBER;
      l_string                 VARCHAR2(2500);
      l_string1                VARCHAR2(2500);
      l_approver               VARCHAR2(200);
      l_requester              VARCHAR2(360);
      l_string2                VARCHAR2(2500);
      l_reason_meaning         VARCHAR2(2000);
      l_act_budget_id          NUMBER;

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act.request_date
                 ,act.budget_source_id approval_from_id
                 ,fund1.short_name from_budget_name
                 ,fund1.owner_full_name from_budget_owner_name
                 ,fund1.fund_number from_budget_number
                 ,fund1.currency_code_tc from_budget_curr
                 ,act.act_budget_used_by_id approval_for_id
                 ,fund2.short_name to_budget_name
                 ,fund2.owner_full_name to_budget_owner_name
                 ,fund2.fund_number to_budget_number
                 ,fund2.currency_code_tc to_budget_curr
                 ,act.date_required_by
                 ,act.reason_code
         FROM     ozf_act_budgets act
                 ,ozf_fund_details_v fund1
                 ,ozf_fund_details_v fund2
         WHERE  activity_budget_id = p_act_budget_id
            AND act.budget_source_id = fund1.fund_id
            AND act.act_budget_used_by_id = fund2.fund_id;

      l_request_rec            c_act_budget_rec%ROWTYPE;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      END IF;
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
      l_activity_type :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_TYPE');
      l_act_budget_id :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_ID');
      l_requested_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_REQUESTED_AMOUNT');
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'AMS_NOTES_FROM_REQUESTOR');
      l_approver :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_APPROVER_DISPLAY_NAME');
      OPEN c_act_budget_rec(l_act_budget_id);
      FETCH c_act_budget_rec INTO l_request_rec;
      CLOSE c_act_budget_rec;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token('BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string := fnd_message.get;
      wf_engine.setitemattrtext(
         itemtype => l_item_type
        ,itemkey => l_item_key
        ,aname => 'APP_SUBJECT'
        ,avalue => l_string);
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUEST_INFO');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      fnd_message.set_token('REQUEST_DATE', l_request_rec.request_date, FALSE);
      fnd_message.set_token('FROM_BUDGET_NAME', l_request_rec.from_budget_name, FALSE);
      fnd_message.set_token('FROM_BUDGET_NUMBER', l_request_rec.from_budget_number, FALSE);
      fnd_message.set_token('FROM_BUDGET_OWNER', l_request_rec.from_budget_owner_name, FALSE);
      fnd_message.set_token('TO_BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('To_BUDGET_NUMBER', l_request_rec.to_budget_number, FALSE);
      fnd_message.set_token('TO_BUDGET_OWNER', l_request_rec.to_budget_owner_name, FALSE);
      fnd_message.set_token('REQUIRED_BY_DATE', l_request_rec.date_required_by, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('REQUEST_AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('JUSTIFICATION', l_note, FALSE);
      l_reason_meaning :=
         ozf_utility_pvt.get_lookup_meaning('AMS_TRANSFER_REASON', l_request_rec.reason_code);
      fnd_message.set_token('REASON', l_reason_meaning, FALSE);
      l_string1 := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');


      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      --  IF (display_type = 'text/plain') THEN
      l_appreq_notification :=
         l_string || fnd_global.local_chr(10) || l_string1 || fnd_global.local_chr(10) || l_string2;
      document := document || l_appreq_notification;
      document_type := 'text/plain';
      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'Notify_requestor_FYI', l_item_type, l_item_key);
         RAISE;
   END notify_approval_required;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   notify_appr_req_reminder
   --
   -- PURPOSE
   --   Generate the Rejection Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   03/15/2001        MUMU PANDE        CREATION

   PROCEDURE notify_appr_req_reminder(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT NOCOPY   VARCHAR2
     ,document_type   IN OUT NOCOPY   VARCHAR2)
   IS
      l_api_name               VARCHAR2(100)            := g_pkg_name || 'notify_appr_req_reminder';
      l_hyphen_pos1            NUMBER;
      l_apprem_notification    VARCHAR2(10000);
      l_activity_type          VARCHAR2(30);
      l_item_type              VARCHAR2(30);
      l_item_key               VARCHAR2(30);
      l_approval_type          VARCHAR2(30);
      l_note                   VARCHAR2(4000);
      l_approved_amt           NUMBER;
      l_forwarder              VARCHAR2(360);
      l_string                 VARCHAR2(2500);
      l_string1                VARCHAR2(2500);
      l_approver               VARCHAR2(200);
      l_requester              VARCHAR2(360);
      l_string2                VARCHAR2(2500);
      l_reason_meaning         VARCHAR2(2000);
      l_act_budget_id          NUMBER;
      l_requested_amt          NUMBER;

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act.request_date
                 ,act.budget_source_id approval_from_id
                 ,fund1.short_name from_budget_name
                 ,fund1.owner_full_name from_budget_owner_name
                 ,fund1.fund_number from_budget_number
                 ,fund1.currency_code_tc from_budget_curr
                 ,act.act_budget_used_by_id approval_for_id
                 ,fund2.short_name to_budget_name
                 ,fund2.owner_full_name to_budget_owner_name
                 ,fund2.fund_number to_budget_number
                 ,fund2.currency_code_tc to_budget_curr
                 ,act.date_required_by
                 ,act.reason_code
         FROM     ozf_act_budgets act
                 ,ozf_fund_details_v fund1
                 ,ozf_fund_details_v fund2
         WHERE  activity_budget_id = p_act_budget_id
            AND act.budget_source_id = fund1.fund_id
            AND act.act_budget_used_by_id = fund2.fund_id;

      l_request_rec            c_act_budget_rec%ROWTYPE;
   BEGIN
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      END IF;
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
      l_activity_type :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_TYPE');
      l_act_budget_id :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_ACTIVITY_ID');
      l_requested_amt :=
         wf_engine.getitemattrnumber(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_REQUESTED_AMOUNT');
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'AMS_NOTES_FROM_REQUESTOR');
      l_approver :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_APPROVER');
      OPEN c_act_budget_rec(l_act_budget_id);
      FETCH c_act_budget_rec INTO l_request_rec;
      CLOSE c_act_budget_rec;
      fnd_message.set_name('OZF', 'OZF_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token('BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      --                  l_string := Substr(FND_MESSAGE.Get,1,2500);
      l_string := fnd_message.get;
      wf_engine.setitemattrtext(
         itemtype => l_item_type
        ,itemkey => l_item_key
        ,aname => 'FYI_SUBJECT'
        ,avalue => l_string);
      fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUEST_INFO');
      fnd_message.set_token('APPROVER_NAME', l_approver, FALSE);
      fnd_message.set_token('REQUEST_NUMBER', l_act_budget_id, FALSE);
      fnd_message.set_token('REQUEST_DATE', l_request_rec.request_date, FALSE);
      fnd_message.set_token('FROM_BUDGET_NAME', l_request_rec.from_budget_name, FALSE);
      fnd_message.set_token('FROM_BUDGET_NUMBER', l_request_rec.from_budget_number, FALSE);
      fnd_message.set_token('FROM_BUDGET_OWNER', l_request_rec.from_budget_owner_name, FALSE);
      fnd_message.set_token('TO_BUDGET_NAME', l_request_rec.to_budget_name, FALSE);
      fnd_message.set_token('To_BUDGET_NUMBER', l_request_rec.to_budget_number, FALSE);
      fnd_message.set_token('TO_BUDGET_OWNER', l_request_rec.to_budget_owner_name, FALSE);
      fnd_message.set_token('REQUIRED_BY_DATE', l_request_rec.date_required_by, FALSE);
      fnd_message.set_token('CURRENCY_CODE', l_request_rec.to_budget_curr, FALSE);
      fnd_message.set_token('REQUEST_AMOUNT', l_requested_amt, FALSE);
      fnd_message.set_token('JUSTIFICATION', l_note, FALSE);
      l_reason_meaning :=
         ozf_utility_pvt.get_lookup_meaning('AMS_TRANSFER_REASON', l_request_rec.reason_code);
      fnd_message.set_token('REASON', l_reason_meaning, FALSE);
      l_string1 := fnd_message.get;
      /*
      l_note := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey => l_item_key
                  ,aname => 'NOTE');


      l_forwarder :=
         wf_engine.getitemattrtext(
            itemtype => l_item_type
           ,itemkey => l_item_key
           ,aname => 'AMS_FORWARD_FROM_USERNAME');
    */
      --  IF (display_type = 'text/plain') THEN
      l_apprem_notification :=
         l_string || fnd_global.local_chr(10) || l_string1 || fnd_global.local_chr(10) || l_string2;
      document := document || l_apprem_notification;
      document_type := 'text/plain';
      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_appreq_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'notify_appr_req_reminder', l_item_type, l_item_key);
         RAISE;
   END notify_appr_req_reminder;

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Set_trans_Activity_details
   --
   --
   -- PURPOSE
   --   This Procedure will set all the item attribute details
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   02/20/2001        MUMU PANDE        CREATION
   --   07/09/2001        MUMU PANDE        Modified to set all subjects
   -- End of Comments
   --------------------------------------------------------------------
   PROCEDURE set_trans_activity_details(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2)
   IS
      l_activity_id            NUMBER;
       /*
      l_activity_type          VARCHAR2(30)                   := 'FUND';
      l_approval_type          VARCHAR2(30)                   := 'ROOT_BUDGET';
      */
      -- mpande 08/14/2001 cahnged as per new reqmts.
      l_activity_type          VARCHAR2(30)                   := 'FREQ';
      l_approval_type          VARCHAR2(30)                   := 'BUDGET';

      l_object_details         ams_gen_approval_pvt.objrectyp;
      l_approval_detail_id     NUMBER;
      l_approver_seq           NUMBER;
      l_return_status          VARCHAR2(1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(4000);
      l_error_msg              VARCHAR2(4000);
      l_orig_stat_id           NUMBER;
      x_resource_id            NUMBER;
      l_full_name              VARCHAR2(240);
      l_fund_number            VARCHAR2(30);
      l_requested_amt          NUMBER;
      l_fund_id                NUMBER;
      l_child_transfer_flag    VARCHAR2(3);
      l_string                 VARCHAR2(3000);
      l_budget_source_id       NUMBER;
      -- l_approver               VARCHAR2(300);
      l_lookup_meaning         VARCHAR2(240);
      l_justification          VARCHAR2(4000);

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   act_budget_used_by_id
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;
      /* 02/26/2002 mpande added for budget transfer not picking up correct approval rules
        with category */
      CURSOR c_budget_src_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   budget_source_id
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;

      CURSOR c_src_category(
         p_src_id   IN   NUMBER)
      IS
         SELECT   to_char(category_id)
         FROM     ozf_funds_all_b
         WHERE    fund_id = p_src_id;
      /* End of Addition for category-approval*/

      CURSOR c_fund_rec(
         p_act_id   IN   NUMBER)
      IS
         SELECT   short_name
                 ,custom_setup_id
                 ,original_budget
                 ,org_id
                 ,to_char(category_id)
                 ,start_date_active
                 ,end_date_active
                 ,owner
                 ,currency_code_tc
         FROM     ozf_funds_all_vl
         WHERE  fund_id = p_act_id;

      CURSOR c_transfer_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   fund.short_name
                 ,fund.custom_setup_id
                 ,act1.request_amount
                 ,fund.org_id
                 ,'FUND'
                 ,fund.start_date_active
                 ,fund.end_date_active
                 ,act1.requester_id
                 ,act1.request_currency
         FROM     ozf_act_budgets act1
                 ,ozf_funds_all_vl fund
         WHERE  activity_budget_id = p_act_budget_id
            AND act1.act_budget_used_by_id = fund.fund_id;

     -- yzhao: 01/28/2003 get budget request's justification
     CURSOR c_get_justification(p_act_budget_id   IN   NUMBER) IS
        SELECT  notes
        FROM    jtf_notes_vl
        WHERE   source_object_code = 'AMS_FREQ'
        AND     note_type = 'AMS_JUSTIFICATION'
        AND     source_object_id = p_act_budget_id;

   BEGIN
      fnd_msg_pub.initialize;
      l_activity_id :=
         wf_engine.getitemattrnumber(
            itemtype => itemtype
           ,itemkey => itemkey
           ,aname => 'AMS_ACTIVITY_ID');
      l_child_transfer_flag :=
         wf_engine.getitemattrtext(
            itemtype => itemtype
           ,itemkey => itemkey
           ,aname => 'AMS_GENERIC_FLAG');

      IF l_child_transfer_flag = 'Y' THEN
         OPEN c_act_budget_rec(l_activity_id);
         FETCH c_act_budget_rec INTO l_fund_id;


         IF (c_act_budget_rec%NOTFOUND) THEN
            CLOSE c_act_budget_rec;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE c_act_budget_rec;
         OPEN c_fund_rec(l_fund_id);
         FETCH c_fund_rec INTO l_object_details.name,
                               l_object_details.setup_type_id,
                               l_object_details.total_header_amount,
                               l_object_details.org_id,
                               l_object_details.object_type,
                               l_object_details.start_date,
                               l_object_details.end_date,
                               l_object_details.owner_id,
                               l_object_details.currency;

         IF (c_fund_rec%NOTFOUND) THEN
            CLOSE c_fund_rec;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
          CLOSE c_fund_rec;
      ELSE
         OPEN c_transfer_rec(l_activity_id);
         FETCH c_transfer_rec INTO l_object_details.name,
                                   l_object_details.setup_type_id,
                                   l_object_details.total_header_amount,
                                   l_object_details.org_id,
                                   l_object_details.object_type,
                                   l_object_details.start_date,
                                   l_object_details.end_date,
                                   l_object_details.owner_id,
                                   l_object_details.currency;
         IF (c_transfer_rec%NOTFOUND) THEN
            CLOSE c_fund_rec;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE c_transfer_rec;

      END IF;
      /* 02/26/2002 mpande added for budget transfer not going to the correct approver */
      OPEN c_budget_src_rec(l_activity_id);
      FETCH c_budget_src_rec INTO l_budget_source_id;


      IF (c_budget_src_rec%NOTFOUND) THEN
         CLOSE c_budget_src_rec;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_budget_src_rec;

      /*Fix for Bug 7290977*/

        OPEN c_act_budget_rec(l_activity_id);
        FETCH c_act_budget_rec INTO l_fund_id;
        CLOSE c_act_budget_rec;

	OPEN c_src_category(l_fund_id);
	FETCH c_src_category INTO l_object_details.object_type;
	CLOSE c_src_category;

      /*End of Addition for budget category */


      IF (funcmode = 'RUN') THEN
         ams_gen_approval_pvt.get_approval_details(
            p_activity_id => l_activity_id
           ,p_activity_type => g_activity_type
           ,p_approval_type => g_transfer_approval_type
           ,p_object_details => l_object_details
           ,x_approval_detail_id => l_approval_detail_id
           ,x_approver_seq => l_approver_seq
           ,x_return_status => l_return_status);

         IF l_return_status = fnd_api.g_ret_sts_success THEN
            wf_engine.setitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_APPROVAL_DETAIL_ID'
              ,avalue => l_approval_detail_id);
            wf_engine.setitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_APPROVER_SEQ'
              ,avalue => l_approver_seq);
            wf_engine.setitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_REQUESTED_AMOUNT'
              ,avalue => l_object_details.total_header_amount);

            -- yzhao: 01/28/2003 set justfication
            OPEN c_get_justification(l_activity_id);
            FETCH c_get_justification INTO l_justification;
            CLOSE c_get_justification;
            wf_engine.setitemattrtext(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_NOTES_FROM_REQUESTOR'
              ,avalue => l_justification);

            /* set the fyi subject
            l_approver :=
            wf_engine.getitemattrtext(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_APPROVER');
            */

            fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_FYI_SUB');
            fnd_message.set_token('BUDGET_NAME', l_object_details.name, FALSE);
            fnd_message.set_token('CURRENCY_CODE', l_object_details.currency, FALSE);
            fnd_message.set_token('AMOUNT', l_object_details.total_header_amount, FALSE);
            fnd_message.set_token('REQUEST_NUMBER', l_activity_id, FALSE);
            --    l_string := Substr(FND_MESSAGE.Get,1,2500);
            l_string := fnd_message.get;
            wf_engine.setitemattrtext(
               itemtype => itemtype
               ,itemkey => itemkey
               ,aname => 'FYI_SUBJECT'
              ,avalue => l_string);

            -- set the approval subject
            fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_APP_SUB');
            fnd_message.set_token('BUDGET_NAME', l_object_details.name, FALSE);
            -- fnd_message.set_token('CURRENCY_CODE', l_object_details.currency, FALSE);
            -- fnd_message.set_token('AMOUNT', l_object_details.total_header_amount, FALSE);
            fnd_message.set_token('REQUEST_NUMBER', l_activity_id, FALSE);
            --    l_string := Substr(FND_MESSAGE.Get,1,2500);
            l_string := fnd_message.get;
            wf_engine.setitemattrtext(
               itemtype => itemtype
               ,itemkey => itemkey
               ,aname => 'APRV_SUBJECT'
               ,avalue => l_string);
            -- set the reject subject
            fnd_message.set_name('OZF', 'OZF_WF_NTF_REQUESTER_REJ_SUB');
            fnd_message.set_token('BUDGET_NAME', l_object_details.name, FALSE);
            fnd_message.set_token('CURRENCY_CODE', l_object_details.currency, FALSE);
            fnd_message.set_token('AMOUNT', l_object_details.total_header_amount, FALSE);
            fnd_message.set_token('REQUEST_NUMBER', l_activity_id, FALSE);
            --     l_string := Substr(FND_MESSAGE.Get,1,2500);
            l_string := fnd_message.get;
            wf_engine.setitemattrtext(
              itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'REJECT_SUBJECT'
              ,avalue => l_string);
            -- set the approval requred subject
            fnd_message.set_name('OZF', 'OZF_WF_NTF_APPROVER_OF_REQ_SUB');
            fnd_message.set_token('BUDGET_NAME', l_object_details.name, FALSE);
            fnd_message.set_token('CURRENCY_CODE', l_object_details.currency, FALSE);
            fnd_message.set_token('AMOUNT', l_object_details.total_header_amount, FALSE);
            fnd_message.set_token('REQUEST_NUMBER', l_activity_id, FALSE);
            --  l_string := Substr(FND_MESSAGE.Get,1,2500);
            l_string := fnd_message.get;
           wf_engine.setitemattrtext(
              itemtype =>  itemtype
              ,itemkey => itemkey
              ,aname => 'APP_SUBJECT'
              ,avalue => l_string);
           /* mpande added for implementation of BUG#2352621*/
           l_lookup_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER','FREQ');
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_OBJECT_MEANING',
               avalue=> l_lookup_meaning
            );
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_OBJECT_NAME',
               avalue=> l_object_details.name
            );
            /* End of Addition for Bug#2352621*/


            resultout := 'COMPLETE:SUCCESS';
         ELSE
            fnd_msg_pub.count_and_get(
               p_encoded => fnd_api.g_false
              ,p_count => l_msg_count
              ,p_data => l_msg_data);
            ams_gen_approval_pvt.handle_err(
               p_itemtype => itemtype
              ,p_itemkey => itemkey
              ,p_msg_count => l_msg_count
              ,   -- Number of error Messages
               p_msg_data => l_msg_data
              ,p_attr_name => 'AMS_ERROR_MSG'
              ,x_error_msg => l_error_msg);
            wf_core.context(
               'ozf_fund_request_apr_pvt'
              ,'Set_trans_Activity_Details'
              ,itemtype
              ,itemkey
              ,actid
              ,l_error_msg);
            -- RAISE FND_API.G_EXC_ERROR;
            resultout := 'COMPLETE:ERROR';
         END IF;
      END IF;

      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout := 'COMPLETE:';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout := 'COMPLETE:';
         RETURN;
      END IF;
   --

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         wf_core.context(
            'ozf_fund_request_apr_pvt'
           ,'Set_trans_Activity_Detail'
           ,itemtype
           ,itemkey
           ,actid
           ,funcmode
           ,l_error_msg);
         RAISE;
      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => l_msg_count
           ,p_data => l_msg_data);
            ams_gen_approval_pvt.handle_err(
               p_itemtype => itemtype
              ,p_itemkey => itemkey
              ,p_msg_count => l_msg_count
              ,   -- Number of error Messages
               p_msg_data => l_msg_data
              ,p_attr_name => 'AMS_ERROR_MSG'
              ,x_error_msg => l_error_msg);
            resultout := 'COMPLETE:ERROR';

         RAISE;
   END set_trans_activity_details;


---------------------------------------------------------------------
-- PROCEDURE
--  Get_Ntf_Rule_Values
--
-- PURPOSE
--   This Procedure will check the value apporved_amount in the
--   of the notification rule of the approver
-- IN
--    p_approver_name IN VARCHAR2,
--    p_result IN VARCHAR2 --
-- OUT
--    x_text_value OUT VARCHAR2
--    x_number_value OUT NUMBER
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   10/2/2002        MUMU PANDE        CREATION
-- End of Comments
-------------------------------------------------------------------
   PROCEDURE Get_Ntf_Rule_Values
      (p_approver_name IN VARCHAR2,
       x_text_value OUT NOCOPY VARCHAR2,
       x_number_value OUT NOCOPY NUMBER)
   IS
      CURSOR c_get_rule IS
      SELECT b.text_value, b.number_value
        FROM wf_routing_rules a, wf_routing_rule_attributes b
       WHERE a.rule_id = b.rule_id
         AND a.role = p_approver_name
         AND TRUNC(sysdate) BETWEEN TRUNC(NVL(begin_date, sysdate -1)) AND
             TRUNC(NVL(end_date,sysdate+1))
         AND a.message_name = 'AMS_APPROVAL_REQUIRED_OZF'
         AND b.name = 'AMS_AMOUNT';

   BEGIN
      x_text_value := null;
      x_number_value := null;
      OPEN c_get_rule;
      FETCH c_get_rule INTO x_text_value, x_number_value;
      IF c_get_rule%NOTFOUND THEN
          x_text_value := NULL;
          x_number_value := 0;
      END IF;
      CLOSE c_get_rule;
   EXCEPTION
     WHEN OTHERS THEN
        IF G_DEBUG THEN
           ozf_utility_pvt.debug_message ('ozf_fund_approval_pvt.get_ntf_rule_values() exception.' || SQLERRM);
        END IF;
   END Get_Ntf_Rule_Values;


    --------------------------------------------------------------------------
    --  yzhao: internal procedure called by update_budgettrans_status() to fix bug 2750841(same as 2741039)
    --------------------------------------------------------------------------
    FUNCTION find_org_id (p_fund_id IN NUMBER) RETURN number IS
      l_org_id number := NULL;

      CURSOR get_fund_org_csr(p_id in number) IS
      SELECT org_id
      FROM ozf_funds_all_b
      WHERE fund_id = p_id;

    BEGIN

     OPEN  get_fund_org_csr(p_fund_id);
     FETCH get_fund_org_csr INTO l_org_id;
     CLOSE get_fund_org_csr;

     RETURN l_org_id;

    END find_org_id;
    --------------------------------------------------------------------------
    --------------------------------------------------------------------------
    --  yzhao: internal procedure called by update_budgettrans_status() to fix bug 2750841(same as 2741039)
    --------------------------------------------------------------------------
    PROCEDURE set_org_ctx (p_org_id IN NUMBER) IS
    BEGIN

         IF p_org_id is not NULL THEN
           fnd_client_info.set_org_context(to_char(p_org_id));
         END IF;

    END set_org_ctx;
    --------------------------------------------------------------------------

   ---------------------------------------------------------------------
   -- PROCEDURE
   --  Update_Budgettrans_Statas
   --
   --
   -- PURPOSE
   --   This Procedure will update the status
   --
   --
   -- IN
   --
   --
   -- OUT
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   02/20/2001        MUMU PANDE        CREATION
   -- End of Comments
   -------------------------------------------------------------------

   PROCEDURE update_budgettrans_status(
      itemtype    IN       VARCHAR2
     ,itemkey     IN       VARCHAR2
     ,actid       IN       NUMBER
     ,funcmode    IN       VARCHAR2
     ,resultout   OUT NOCOPY      VARCHAR2)
   IS
      l_status_code              VARCHAR2(30);
      l_api_version     CONSTANT NUMBER                      := 1.0;
      l_return_status            VARCHAR2(1)                 := fnd_api.g_ret_sts_success;
      l_msg_count                NUMBER;
      l_msg_data                 VARCHAR2(4000);
      l_api_name        CONSTANT VARCHAR2(30)                := 'Update_ParBudget_Status';
      l_full_name       CONSTANT VARCHAR2(60)                := g_pkg_name || '.' || l_api_name;
      l_next_status_id           NUMBER;
      l_approved_amount          NUMBER;
      l_update_status            VARCHAR2(30);
      l_error_msg                VARCHAR2(4000);
      l_object_version_number    NUMBER;
      l_act_budget_id            NUMBER;
      l_approver_id              NUMBER;
      l_approval_for_id          NUMBER;
      l_approval_fm_id           NUMBER;
      l_requester_id             NUMBER;
      l_requested_amt            NUMBER;
      l_approver                 VARCHAR2(320);
      l_text_value               VARCHAR2(2000);
      l_number_value             NUMBER;
      l_note                     VARCHAR2(4000);
      l_child_transfer_flag      VARCHAR2(3);
      l_to_currency              VARCHAR2(15);
      l_from_currency            VARCHAR2(15);
      l_approved_amt_in_from_curr  NUMBER;
      l_org_id                   NUMBER;

      CURSOR c_act_budget_rec(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   budget_source_id approval_from_id
                 ,act_budget_used_by_id approval_for_id
                 ,request_currency
                 ,fund.currency_code_tc
         FROM     ozf_act_budgets  act
                 ,ozf_funds_all_b  fund
         WHERE  activity_budget_id = p_act_budget_id
           AND  act.budget_source_id = fund.fund_id;

   BEGIN
      IF funcmode = 'RUN' THEN
         l_update_status :=
            wf_engine.getitemattrtext(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'UPDATE_GEN_STATUS');
         l_approved_amount :=
            wf_engine.getitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_AMOUNT');
         l_approver_id :=
            wf_engine.getitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_APPROVER_ID');
         l_requester_id :=
            wf_engine.getitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_REQUESTER_ID');

         IF l_update_status = 'APPROVED' THEN
            l_next_status_id :=
               wf_engine.getitemattrnumber(
                  itemtype => itemtype
                 ,itemkey => itemkey
                 ,aname => 'AMS_NEW_STAT_ID');

            /* yzhao 10/03/2002 bug#2577992   when automatic approval notification rule is set
                     if auto approval amount > request amount, then final approval amount := request amount
                     else final approval amount := auto approval amount
             */
            l_approver            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_APPROVER'
               );
            l_requested_amt :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_REQUESTED_AMOUNT'
               );

	   /* Approved Amount is null in the following cases
                 when requester and approver are the same, no approval is required and AMS_AMOUNT is not set
                 should take AMS_REQUESTED_AMOUNT. Fix for 3638512
            */

            IF l_approved_amount IS NULL THEN
               IF l_approver_id = l_requester_id THEN
                  l_approved_amount := l_requested_amt;
               END IF;
            END IF;

            Get_Ntf_Rule_Values
                 (p_approver_name   => l_approver,
                  x_text_value      => l_text_value ,
                  x_number_value    => l_number_value);

            IF NVL(l_number_value, 0) > 0 THEN
                  IF l_number_value > l_requested_amt THEN
                     l_approved_amount := l_requested_amt;
                  ELSE
                     l_approved_amount := l_number_value;
                  END IF;

                  -- set approval amount to workflow so notificaiton gets the correct amount
                  wf_engine.setitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_AMOUNT',
                     avalue=> l_approved_amount
                  );
            END IF;
            -- End of fix for bug#2577792

         -- mpande 6/11/2002 bug#2352621
         ELSIF l_update_status = 'REJECTED' THEN
            l_next_status_id           :=
                  wf_engine.getitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_REJECT_STAT_ID'
                  );
         -- yzhao 6/28/2002 bug#2352621 revert status
         ELSE
            l_next_status_id           :=
               ozf_utility_pvt.get_default_user_status(
                  g_budget_source_status
                , 'NEW');
         END IF;


         l_child_transfer_flag :=
            wf_engine.getitemattrtext(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_GENERIC_FLAG');

              l_note :=     wf_engine.getitemattrtext(
                    itemtype => itemtype
                   ,itemkey => itemkey
                   ,aname => 'APPROVAL_NOTE');

         l_object_version_number :=
            wf_engine.getitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_OBJECT_VERSION_NUMBER');
         l_act_budget_id :=
            wf_engine.getitemattrnumber(
               itemtype => itemtype
              ,itemkey => itemkey
              ,aname => 'AMS_ACTIVITY_ID');
         OPEN c_act_budget_rec(l_act_budget_id);
         FETCH c_act_budget_rec INTO l_approval_fm_id, l_approval_for_id, l_to_currency, l_from_currency;
         IF (c_act_budget_rec%NOTFOUND) THEN
            CLOSE c_act_budget_rec;

            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE c_act_budget_rec;

         -- [BEGIN OF BUG 2750841(same as 2741039) FIXING by yzhao 01/10/2003]
         -- get source budget's org_id so workflow resumes requestor's responsibility
         l_org_id := find_org_id (l_approval_for_id);
         -- set org_context since workflow mailer does not set the context
         set_org_ctx (l_org_id);
         -- [END OF BUG 2750841(same as 2741039) FIXING by yzhao 01/10/2003]

         IF l_to_currency <> l_from_currency THEN
            -- 08/16/2001  yzhao: convert the request amount to source fund's(approver) currency.
            ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_to_currency
                 ,p_to_currency=> l_from_currency
                 ,p_from_amount=> l_approved_amount
                 ,x_to_amount=> l_approved_amt_in_from_curr
            );

            IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;

         ELSE
            l_approved_amt_in_from_curr :=  l_approved_amount;
         END IF;

         --   x_return_status := fnd_api.g_ret_sts_success;
         l_status_code := ozf_utility_pvt.get_system_status_code(l_next_status_id);

         IF l_update_status = 'APPROVED' THEN
            approve_request(
               p_commit => fnd_api.g_false
              ,p_update_status => 'Y'
              ,p_act_budget_id => l_act_budget_id
              ,p_target_fund_id => l_approval_for_id
              ,p_source_fund_id => l_approval_fm_id
              ,p_requester_id => l_requester_id
              ,p_requestor_owner => 'N'
              ,p_approver_id => l_approver_id
              --           ,p_requested_amount => l_fm_curr_requested_amount   -- should be passed transferring fm fund_currency
              ,p_approved_amount => l_approved_amt_in_from_curr   -- in transferring fm fund_currency
              ,p_child_flag => l_child_transfer_flag
              ,p_workflow_flag => 'Y'
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data
              ,p_note => l_note);
         ELSE
          -- 6/14/2002 mpande changed for implementaion of ENH#2352621
            negative_request(
               p_commit => fnd_api.g_false
              ,p_act_budget_id => l_act_budget_id
              ,p_target_fund_id => l_approval_for_id
              ,p_source_fund_id => l_approval_fm_id
              ,p_requester_id => l_requester_id
              ,p_requestor_owner => 'N'
              ,p_approver_id => l_approver_id
              --           ,p_requested_amount => l_fm_curr_requested_amount   -- should be passed transferring fm fund_currency
              ,p_approved_amount => l_approved_amt_in_from_curr   -- in transferring fm fund_currency
              ,p_child_flag => l_child_transfer_flag
              ,p_note => l_note
              ,p_status_code => l_status_code
              ,p_user_status_id => l_next_status_id
              ,x_return_status => l_return_status
              ,x_msg_count => l_msg_count
              ,x_msg_data => l_msg_data);
         END IF;

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            ams_gen_approval_pvt.handle_err(
               p_itemtype => itemtype
              ,p_itemkey => itemkey
              ,p_msg_count => l_msg_count
              ,   -- Number of error Messages
               p_msg_data => l_msg_data
              ,p_attr_name => 'AMS_ERROR_MSG'
              ,x_error_msg => l_error_msg);
            -- mpande 6/11/2002 bug#2352621
            resultout := 'COMPLETE:ERROR';
         ELSE
            resultout := 'COMPLETE:SUCCESS';
         END IF;

      END IF;

      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout := 'COMPLETE:';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout := 'COMPLETE:';
         RETURN;
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => l_msg_count
        ,p_data => l_msg_data);
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': l_return_status' || l_return_status);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         --      x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => l_msg_count
           ,p_data => l_msg_data);
              ams_gen_approval_pvt.handle_err(
               p_itemtype => itemtype
              ,p_itemkey => itemkey
              ,p_msg_count => l_msg_count
              ,   -- Number of error Messages
               p_msg_data => l_msg_data
              ,p_attr_name => 'AMS_ERROR_MSG'
              ,x_error_msg => l_error_msg);
            resultout := 'COMPLETE:ERROR';
         RAISE;
   END update_budgettrans_status;

   ---------------------------------------------------------------------
   -- PROCEDURE
   --   Approve_holdback
   --
   --
   -- PURPOSE
   --   This Procedure will Update the fund where reserve is done to holdback from
   --   available amount
   --
   -- IN
   -- p_commit           IN  VARCHAR2 -- Transaction commit identifier
   -- p_act_budget_id  IN  NUMBER -- Fund request identifier having the request details
   -- p_transac_fund_id   IN  NUMBER -- transaction fund
   -- p_requester_id     IN  NUMBER -- Person initiating the fund release --should always be the owner of the fund
   -- p_requested_amount IN  NUMBER -- Requested amount
   -- p_transfer_type   In VARCHAR2
   -- OUT
   -- x_return_status    OUT VARCHAR2
   -- x_msg_count        OUT NUMBER
   -- x_msg_data         OUT VARCHAR2
   --
   -- Used By Activities
   --
   -- NOTES
   --
   --
   --
   -- HISTORY
   --   06/07/2000        MPANDE        CREATION
   --
   -- End of Comments

   PROCEDURE approve_holdback(
      p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_act_budget_id      IN       NUMBER
     ,p_transfer_type      IN       VARCHAR2
     ,p_transac_fund_id    IN       NUMBER
     ,p_requester_id       IN       NUMBER
     ,p_approver_id        IN       NUMBER
     ,p_requested_amount   IN       NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2)
   IS
      -- Local variables
      l_api_name            CONSTANT VARCHAR2(30)                            := 'Approve_Holdback';
      l_full_name           CONSTANT VARCHAR2(60)
               := g_pkg_name || '.' || l_api_name;
      l_api_version         CONSTANT NUMBER                                  := 1.0;
      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2(4000);
      l_return_status                VARCHAR2(1)
            := fnd_api.g_ret_sts_success;
      l_object_version_number        NUMBER;
      -- Record variables for creating the fund request.
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;   -- transaction fund record
      l_act_budget_rec               ozf_actbudgets_pvt.act_budgets_rec_type;   -- fund request record

      -- Cursor to find fund details
      -- sql repository 14894880
      CURSOR c_fund_detail(
         cv_fund_id   NUMBER)
      IS
         SELECT   fund_id
                 ,(NVL(original_budget, 0) - NVL(holdback_amt, 0) + NVL(transfered_in_amt,0) - NVL(transfered_out_amt, 0)- NVL(committed_amt,0)) available_budget
                 ,holdback_amt
                 ,object_version_number
         FROM     ozf_funds_all_b
         WHERE  fund_id = cv_fund_id;

      l_holdback_amt                 NUMBER;
      l_available_amt                NUMBER;
      --      cr_transac_detail c_fund_detail%ROWTYPE;

      l_obj_number                   NUMBER;
      l_fund_id                      NUMBER;

      -- Cursor to find fund_request details
      CURSOR c_request_detail(
         p_act_budget_id   IN   NUMBER)
      IS
         SELECT   activity_budget_id
                 ,status_code
                 ,object_version_number
         FROM     ozf_act_budgets
         WHERE  activity_budget_id = p_act_budget_id;

      -- Cursor records
      l_request_status               VARCHAR2(10);
      l_request_id                   NUMBER;
      l_req_user_status_id           NUMBER;
      l_req_object_version_number    NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      -- Initialize
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || ': start');
      END IF;
      -- Source Fund Details
      OPEN c_fund_detail(p_transac_fund_id);
      FETCH c_fund_detail INTO l_fund_id, l_available_amt, l_holdback_amt, l_obj_number;

      IF (c_fund_detail%NOTFOUND) THEN
         CLOSE c_fund_detail;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_fund_detail;
      -- Check to see whether the fund has sufficient available amount to reserve/release
      -- Initialize the fund records
      ozf_funds_pvt.init_fund_rec(x_fund_rec => l_fund_rec);

      IF p_transfer_type = 'RESERVE' THEN
         IF NVL(l_available_amt, 0) < NVL(p_requested_amount, 0) THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_AMT_UNAVAILABLE');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         l_fund_rec.holdback_amt := NVL(l_holdback_amt, 0) + NVL(p_requested_amount, 0);   -- HOLDBACK AMT
      ELSIF p_transfer_type = 'RELEASE' THEN
         IF NVL(l_holdback_amt, 0) < NVL(p_requested_amount, 0) THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_AMT_UNAVAILABLE');
               fnd_msg_pub.add;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;

         l_fund_rec.holdback_amt := NVL(l_holdback_amt, 0) - NVL(p_requested_amount, 0);   -- HOLDBACK AMT
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name || l_fund_id || l_obj_number);
      END IF;
      -- Transaction Fund record
      l_fund_rec.fund_id := l_fund_id;
      l_fund_rec.object_version_number := l_obj_number;
      -- Update source fund
      ozf_funds_pvt.update_fund(
         p_api_version => l_api_version
        ,p_commit => fnd_api.g_false
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_fund_rec => l_fund_rec
        ,p_mode => 'ADJUST');

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Conditional commit
      IF     fnd_api.to_boolean(p_commit)
         AND l_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
   END approve_holdback;
END ozf_fund_request_apr_pvt;

/
