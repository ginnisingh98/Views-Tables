--------------------------------------------------------
--  DDL for Package Body OZF_THRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_THRESHOLD_PVT" AS
/* $Header: ozfvtreb.pls 120.4 2006/07/21 09:03:41 kpatro noship $*/

-- ===============================================================
-- Start of Comments
-- Package name
--          ozf_threshold_pvt
-- Purpose
--
-- History
--         Created By   - Siddharha Dutta
--         29/04/2001   Feliu updated
--         29/11/2001   Feliu Changed signature for  validate_threshold.
--         03/11/2002   Feliu Added start_process, call notification directly.
--                            Remove package ams_threshold_notify.
--         05/08/2002   Feliu Added re-calculated committed.
--         30/04/2004   Ribha Added Earned Amount.
--         10-May-2004  feliu add business event for notification.
--         08/24/2004   Ribha 3842318 fixed
--         06/08/2005   kdass Bug 4415878 SQL Repository Fix
--         12-May-2006  asylvia     Bug 5199719 - SQL Repository fixes
--         21-Jul-2006  kpatro      Bug 5390527 - fix for 'Validate Budget and Quota Thresholds' conc program
-- NOTE
--        Will prcess the thresholds and creates
--      - notification information in ams_act_logs
--      - table. Will make a call to notification
--      - package.
-- End of Comments
-- ===============================================================

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='OZF_THRESHOLD_PVT';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='ozfvtreb.pls';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


PROCEDURE start_process(
      p_api_version_number   IN       NUMBER
     ,x_msg_count            OUT NOCOPY      NUMBER
     ,x_msg_data             OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY     VARCHAR2
     ,p_owner_id             IN       NUMBER
     ,p_parent_owner_id      IN       NUMBER
     ,p_message_text         IN       VARCHAR2
     ,p_activity_log_id      IN       NUMBER
)
   IS
       l_api_name              CONSTANT VARCHAR2(30)   := 'Start_Process';
       l_return_status                  VARCHAR2(1);
      l_strSubject                     VARCHAR2(30);
      l_strChildSubject                VARCHAR2(30);
      l_notification_id                NUMBER;
      l_strBody               VARCHAR2(2000);

   BEGIN
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Entering ams_threshold_notify.Start_process : ');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      fnd_message.set_name('OZF', 'OZF_THRESHOLD_SUBJECT');
      l_strSubject := fnd_message.get;
      fnd_message.set_name('OZF', 'OZF_THRESHOLD_CHILDSUBJ');
      l_strChildSubject := fnd_message.get;

     -- fnd_message.set_name('OZF', 'OZF_NOTIFY_HEADERLINE');
      --l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10)||p_message_text;
      l_strBody := p_message_text;
      fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
      --l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;
      l_strBody := l_strBody ||fnd_message.get ;
      ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => p_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;


      IF p_parent_owner_id <>0 THEN
         ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strChildSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => p_parent_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
   END start_process; /*  START_PROCESS */


-----------------------------------------------------------------------
-- PROCEDURE
--    raise_business_event
--
-- HISTORY
--    05/08/2004  feliu  Created.
-----------------------------------------------------------------------


PROCEDURE raise_business_event(p_object_id IN NUMBER)
IS
l_item_key varchar2(30);
l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_object_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();


  IF G_DEBUG THEN
    ozf_utility_pvt.debug_message(' threshold Id is :'||p_object_id );
  END IF;

    wf_event.AddParameterToList(p_name           => 'P_THRESH_ID',
                              p_value          => p_object_id,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
  END IF;

    wf_event.raise( p_event_name =>'oracle.apps.ozf.fund.threshold.reach',
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);


EXCEPTION
WHEN OTHERS THEN
RAISE Fnd_Api.g_exc_error;
ozf_utility_pvt.debug_message('Exception in raising business event');
END;


  -----------------------------------------------------------------------
   -- PROCEDURE
   --    value_limit
   --
   -- HISTORY

   -----------------------------------------------------------------------
PROCEDURE value_limit
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id       IN NUMBER,
    p_value_limit_type IN VARCHAR2,
    p_off_on_line     IN VARCHAR2,
    x_result          OUT NOCOPY NUMBER)
IS
l_budget_amount_tc NUMBER := 0;
l_committed_amt NUMBER := 0;
l_commit_amt   NUMBER := 0;
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_api_name                CONSTANT VARCHAR2(30) := 'value_limit';

CURSOR c_committed_amt
IS
SELECT committed_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_planned_amt
IS
SELECT planned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;


CURSOR c_utilized_amt
IS
SELECT earned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_earned_amt
IS
SELECT earned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_paid_amt
IS
SELECT paid_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

--asylvia 12-May-2006 bug 5199719 - SQL ID  17780673
CURSOR c_balance_amt
IS
select (NVL(original_budget, 0) + (NVL(transfered_in_amt, 0) - NVL(transfered_out_amt, 0))) ,committed_amt
FROM ozf_funds_all_b
WHERE  fund_id = p_budget_id;

CURSOR c_re_committed_amt
IS
SELECT recal_committed
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
--      IF FND_API.to_Boolean( p_init_msg_list )
  --    THEN
       --  FND_MSG_PUB.initialize;
     -- END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Derive the value_limit amount based on value_limit_type

      IF p_value_limit_type = 'COMMITTED' THEN

         OPEN c_committed_amt;
         FETCH c_committed_amt INTO l_commit_amt;
         CLOSE c_committed_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

      ELSIF  p_value_limit_type = 'RECOMMITTED' THEN

         OPEN c_re_committed_amt;
         FETCH c_re_committed_amt INTO l_commit_amt;
         CLOSE c_re_committed_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

      ELSIF  p_value_limit_type = 'PLANNED' THEN

         OPEN c_planned_amt;
         FETCH c_planned_amt INTO l_commit_amt;
         CLOSE c_planned_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

      ELSIF  p_value_limit_type = 'UTILIZED' THEN

         OPEN c_utilized_amt;
         FETCH c_utilized_amt INTO l_commit_amt;
         CLOSE c_utilized_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

      ELSIF  p_value_limit_type = 'EARNED' THEN

         OPEN c_earned_amt;
         FETCH c_earned_amt INTO l_commit_amt;
         CLOSE c_earned_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
       END IF;

      ELSIF  p_value_limit_type = 'PAID' THEN

         OPEN c_paid_amt;
         FETCH c_paid_amt INTO l_commit_amt;
         CLOSE c_paid_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

      ELSIF  p_value_limit_type = 'BALANCE' THEN

         OPEN c_balance_amt;
         FETCH c_balance_amt INTO l_budget_amount_tc,l_committed_amt;
         CLOSE c_balance_amt;

         IF l_commit_amt is NULL THEN
           l_commit_amt := 0;
         END IF;

         l_commit_amt := l_budget_amount_tc - l_committed_amt;

      END IF; --for main IF/elsifs

        x_result := l_commit_amt;

      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
          --  p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            --p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
           -- p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END value_limit;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    base_line_amt
   --
   -- HISTORY

   -----------------------------------------------------------------------
PROCEDURE base_line_amt(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id       IN NUMBER,
    p_percent         IN NUMBER,
    p_base_line_type  IN VARCHAR2,
    x_result          OUT NOCOPY NUMBER)

IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'base_line_amt';
l_budget_amt          NUMBER := 0;

--asylvia 12-May-2006 bug 5199719 - SQL ID  17780673
CURSOR c_budgeted_amt
IS
select (NVL(original_budget, 0) + (NVL(transfered_in_amt, 0) - NVL(transfered_out_amt, 0)))
FROM ozf_funds_all_b
WHERE  fund_id = p_budget_id;


CURSOR c_committed_amt
IS
SELECT committed_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_planned_amt
IS
SELECT planned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;


CURSOR c_utilized_amt
IS
SELECT earned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_earned_amt
IS
SELECT earned_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_paid_amt
IS
SELECT paid_amt
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

CURSOR c_re_committed_amt
IS
SELECT recal_committed
FROM    ozf_fund_details_v
WHERE  fund_id = p_budget_id;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_base_line_type = 'BUDGET' THEN
      -- Derive the percentage value on the base amount
         OPEN c_budgeted_amt;
         FETCH c_budgeted_amt INTO l_budget_amt;
         CLOSE c_budgeted_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      ELSIF p_base_line_type = 'COMMITTED' THEN

     OPEN c_committed_amt;
         FETCH c_committed_amt INTO l_budget_amt;
         CLOSE c_committed_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      ELSIF p_base_line_type = 'RECOMMITTED' THEN

     OPEN c_re_committed_amt;
         FETCH c_re_committed_amt INTO l_budget_amt;
         CLOSE c_re_committed_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      ELSIF  p_base_line_type = 'PLANNED' THEN
     OPEN c_planned_amt;
         FETCH c_planned_amt INTO l_budget_amt;
         CLOSE c_planned_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      ELSIF  p_base_line_type = 'UTILIZED' THEN
     OPEN c_utilized_amt;
         FETCH c_utilized_amt INTO l_budget_amt;
         CLOSE c_utilized_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

     ELSIF  p_base_line_type = 'EARNED' THEN
     OPEN c_earned_amt;
         FETCH c_earned_amt INTO l_budget_amt;
         CLOSE c_earned_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      ELSIF  p_base_line_type = 'PAID' THEN
     OPEN c_paid_amt;
         FETCH c_paid_amt INTO l_budget_amt;
         CLOSE c_paid_amt;

         IF l_budget_amt is NULL THEN
           l_budget_amt := 0;
         END IF;

      END IF;

      IF l_budget_amt <> 0 THEN
          x_result := (l_budget_amt*p_percent/100);
      ELSE
          x_result := 0;
      END IF;

      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END base_line_amt;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    operation_result
   --
   -- HISTORY

   -----------------------------------------------------------------------
PROCEDURE operation_result(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_lhs                IN NUMBER,
    p_rhs                IN NUMBER,
    p_operator_code      IN VARCHAR2,
    x_result          OUT NOCOPY VARCHAR2)
IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'operation_result';


BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Derive the result based on operator_code

      IF p_operator_code = '2' THEN
         IF p_lhs > p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;


      ELSIF p_operator_code = '0' THEN
         IF p_lhs < p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;

       ELSIF p_operator_code = '1' THEN
         IF p_lhs = p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;

       END IF; -- for main IF/ELSIF

      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END operation_result;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    verify_notification
   -- In Parozf
   -- p_api_version_number   IN       NUMBER
   -- p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false
   -- p_budget_id            IN       NUMBER -- budget to which the threshold applies
   -- p_threshold_id         IN       NUMBER -- threshold_id
   -- p_threshold_rule_id    IN       NUMBER -- threhold_rule_id
   -- p_frequency_period     IN       VARCHAR2 -- MONTHLY or DAILY
   -- p_repeat_frequency     IN       NUMBER
                            -- It is a number . It signifies the frequency of resending the notifications
   -- p_rule_start_date      IN       DATE
   -- Standard Out params
   -- x_msg_count            OUT      NUMBER
   -- x_msg_data             OUT      VARCHAR2
   -- x_return_status        OUT      VARCHAR2
   -- x_result               OUT      VARCHAR2 -- NOTIFY OR NO_NOTIFY

   -- Checks if there already is a notification sent to the budget owner or not
   -- for a threshold rule violation

   -----------------------------------------------------------------------
PROCEDURE verify_notification(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id          IN NUMBER,
    p_threshold_id       IN NUMBER,
    p_threshold_rule_id  IN NUMBER,
    p_frequency_period   IN VARCHAR2,
    p_repeat_frequency     IN NUMBER,
    p_rule_start_date     IN DATE,
    x_result          OUT NOCOPY VARCHAR2)
IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'verify_notification';
l_count                  NUMBER := 0;
l_notify_freq_days    NUMBER := 0;
l_notified_date          DATE     := SYSDATE;

CURSOR c_notification_exist(x_threshold_id NUMBER,
                             x_threshold_rule_id NUMBER,
                          x_budget_id NUMBER) IS
      SELECT Max(notification_creation_date)
      FROM     AMS_ACT_LOGS
      WHERE  arc_act_log_used_by = 'FTHO'
      AND     act_log_used_by_id  = x_threshold_rule_id
      AND     budget_id         = x_budget_id
      AND     threshold_id      = x_threshold_id;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF p_frequency_period = 'DAILY' THEN
            l_notify_freq_days := p_repeat_frequency;
         END IF;

         IF p_frequency_period ='WEEKLY' THEN
            l_notify_freq_days := p_repeat_frequency*7;

         END IF;

         IF p_frequency_period ='MONTHLY' THEN
            l_notify_freq_days := p_repeat_frequency * 30;
         END IF;

         IF p_frequency_period = 'QUARTERLY' THEN
           l_notify_freq_days :=  p_repeat_frequency * 30 * 3;
         END IF;

         IF p_frequency_period = 'YEARLY' THEN
           l_notify_freq_days :=  p_repeat_frequency * 365;
         END IF;

      -- checks entry in the ams_act_logs table for notification_purposes
        OPEN c_notification_exist(p_threshold_id,
                                  p_threshold_rule_id,
                                  p_budget_id);
        FETCH c_notification_exist INTO l_notified_date;
        CLOSE c_notification_exist;

      -- In case of no notification recorder.
      IF l_notified_date is NULL THEN
          l_notified_date := p_rule_start_date;
      END IF;


      IF SYSDATE - l_notified_date >= l_notify_freq_days THEN
           x_result := ('NOTIFY');
      ELSE
           x_result := ('NOT NOTIFY');
      END IF;

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: Notified day' || l_notify_freq_days || ' end ' ||x_result );
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END verify_notification;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    check_threshold_calendar
   --
   -- HISTORY

   -----------------------------------------------------------------------
PROCEDURE validate_threshold
(   /*p_api_version_number    IN  NUMBER,

    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_buffer        OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2
    */
     x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
   )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'validate_threshold';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_count                      NUMBER := 0;
l_value_limit             NUMBER := 0;
l_base_line_amt              NUMBER := 0;
l_value_limit_type          VARCHAR2(15);
l_operation_result          VARCHAR2(25);
l_notification_result      VARCHAR2(25);
l_return_status           VARCHAR2(2);
l_operator_meaning        VARCHAR2(25);
l_budget_name             VARCHAR2(240); -- fix for 3842318
l_parent_fund_id          NUMBER;
l_trans_id                NUMBER;
l_log_id                  NUMBER;
l_owner_id                NUMBER;
l_parent_owner_id         NUMBER;
l_message                 VARCHAR2(5000);
l_period_meaning          VARCHAR2(25);
l_msg_data               VARCHAR2 (2000);
l_msg_count              NUMBER;
l_errbuf                 VARCHAR2(2000);
l_retcode                NUMBER := 0;

-- This cursor gets the threshold rules which are in active status

CURSOR c_threshold_rules_cur IS
SELECT r.threshold_rule_id,
       r.threshold_id
FROM   ozf_threshold_rules_all r, ozf_thresholds_all_b t
WHERE  r.threshold_id = t.threshold_id
AND t.threshold_type = 'BUDGET'
AND r.enabled_flag = 'Y'
AND r.start_date <= SYSDATE
AND r.end_date >= SYSDATE;
--kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - removed the order by clause
--ORDER  BY r.threshold_rule_id;


--This cursor will get all the enabled budgets which are tied with the Thresholds

CURSOR c_threshold_funds(p_threshold_rule_id NUMBER)
IS
SELECT a.fund_id budget_id,
       a.fund_number budget_number,
       a.parent_fund_id parent_budget_id,
       a.planned_amt planned_amt,
       a.committed_amt committed_amt,
       a.paid_amt paid_amt,
       a.available_amount available_amt,
       a.budget_amount_tc budget_amount_tc,
       a.start_date_active budget_start_date,
       a.end_date_active budget_end_date,
       a.earned_amt     utilized_Amt,
       c.value_limit value_limit,
       c.start_period_name start_period_name,
       c.end_period_name end_period_name,
       c.operator_code operator_code,
       c.start_date rule_start_date,
       c.end_date rule_end_date,
       c.period_type period_type,
       c.threshold_id threshold_id,
       c.threshold_rule_id threshold_rule_id,
       c.percent_amount percent_amt,
       c.base_line base_line,
       c.frequency_period frequency_period,
       c.converted_days conv_frequency_period, --Not used in current version.
       c.repeat_frequency repeat_frequency
FROM   ozf_funds_all_b a,
       ozf_thresholds_all_b b,
       ozf_threshold_rules_all c
WHERE  a.threshold_id = b.threshold_id
AND    a.status_code = 'ACTIVE'
AND    b.enable_flag = 'Y'
AND    b.threshold_id = c.threshold_id
AND    c.threshold_rule_id = p_threshold_rule_id
AND    c.end_date >= SYSDATE;

CURSOR c_log_seq IS
SELECT ams_act_logs_s.NEXTVAL
FROM DUAL;

CURSOR c_trans_seq IS
SELECT ams_act_logs_transaction_id_s.NEXTVAL
FROM DUAL;


CURSOR c_log_message (p_trans_id NUMBER)
IS
SELECT budget_id, log_message_text
FROM ams_act_logs
WHERE log_transaction_id = p_trans_id;

CURSOR c_owner(p_budget_id NUMBER)
IS
SELECT owner,parent_fund_id
FROM ozf_Funds_All_b
WHERE fund_id = p_budget_id;

CURSOR c_parent_owner(p_budget_id NUMBER)
IS
SELECT owner
FROM ozf_Funds_All_b
WHERE fund_id = p_budget_id;

CURSOR c_budget_name(p_budget_id NUMBER)
IS
SELECT short_name
FROM ozf_fund_details_v
WHERE fund_id = p_budget_id;

CURSOR c_valuelimit_name(p_lkup_code VARCHAR2)
IS
SELECT meaning
FROM ozf_lookups
WHERE lookup_type = 'OZF_VALUE_LIMIT'
AND lookup_code = p_lkup_code;

TYPE owner_record_type IS RECORD
 (owner NUMBER,
  parent_owner NUMBER,
  message_text VARCHAR2(5000),
  remove_flag  VARCHAR2(1));

l_owner_record       owner_record_type;

TYPE owner_table_type IS TABLE OF owner_record_type
     INDEX BY BINARY_INTEGER;
l_owner_table        owner_table_type;
l_notify_table       owner_table_type;
l_valuelimit_name        VARCHAR2(60);
l_baseline_name        VARCHAR2(60);
l_today_date           VARCHAR2(20);
l_counter              NUMBER;


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_THRESHOLD_RULE_PVT;

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
   --   x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_trans_seq;
      FETCH c_trans_seq INTO l_trans_id;
      CLOSE c_trans_seq;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of Budget Threshold ........ ');
      FOR rule IN c_threshold_rules_cur
        LOOP
          BEGIN
          FOR budget IN c_threshold_funds(rule.threshold_rule_id)
           LOOP
             BEGIN
                    value_limit(l_api_version_number,
                                FND_API.G_FALSE,
                                l_Msg_Count,
                                l_Msg_Data,
                                l_return_status,
                                budget.budget_id,
                                budget.value_limit,
                                'OFFLINE',
                                l_value_limit);
                    IF G_DEBUG THEN
                       OZF_UTILITY_PVT.debug_message('Value limit: ' || l_value_limit);
                    END IF;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;

                  --l_value_limit is lhs for operation_result input.

                    base_line_amt(l_api_version_number,
                                  FND_API.G_FALSE,
                                  l_Msg_Count,
                                  l_Msg_Data,
                                  l_return_status,
                                  budget.budget_id,
                                  budget.percent_amt,
                                  budget.base_line,
                                  l_base_line_amt);
                    IF G_DEBUG THEN
                       OZF_UTILITY_PVT.debug_message('Base limit: ' || l_base_line_amt);
                    END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                 --l_base_line_amt is rhs for operation_result imput.

                   operation_result(l_api_version_number,
                                    FND_API.G_FALSE,
                                    l_Msg_Count,
                                    l_Msg_Data,
                                    l_return_status,
                                    l_value_limit,
                                    l_base_line_amt,
                                    budget.operator_code,
                                    l_operation_result);
                    IF G_DEBUG THEN
                       OZF_UTILITY_PVT.debug_message('Operator: ' || l_operation_result);
                    END IF;
                   --Get operator meaning.
                   IF budget.operator_code = '0' THEN
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_LESS');
                      l_operator_meaning := fnd_message.get;
                   ELSIF budget.operator_code = '1' THEN
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_EQUAL');
                      l_operator_meaning := fnd_message.get;
                   ELSE
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_LARGER');
                      l_operator_meaning := fnd_message.get;
                   END IF;

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                 /* l_operation_result is deciding factor in calling verify_notification.
                  if l_operation_result is 'VIOLATED' then we will call verify_notification
                  else if the l_opearation_result is 'NOT VIOLATED' then we will not call verify_notification*/

                  IF l_operation_result = 'VIOLATED' THEN
                     verify_notification( l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        budget.budget_id,
                                        budget.threshold_id,
                                        budget.threshold_rule_id,
                                        budget.frequency_period,
                                        budget.repeat_frequency,
                                        budget.rule_start_date,
                                        l_notification_result);

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                    --l_notification_result will drive write_to_log
                  IF G_DEBUG THEN
                     OZF_UTILITY_PVT.debug_message('Notify result: ' || l_notification_result );
                  END IF;

                   --Get lookup meaning

                   l_period_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_TRIGGER_FREQUENCY_TYPE'
                                                                         ,budget.frequency_period);

                   IF l_notification_result = 'NOTIFY' THEN
                     -- raise business event.
                      raise_business_event(p_object_id => budget.threshold_rule_id );

                      OPEN c_budget_name(budget.budget_id);
                      FETCH c_budget_name INTO l_budget_name;
                      CLOSE c_budget_name;
                      OPEN c_valuelimit_name(budget.value_limit);
                      FETCH c_valuelimit_name INTO l_valuelimit_name;
                      CLOSE c_valuelimit_name;

                      select to_char(sysdate, 'dd-Mon-yyyy' ) into l_today_date from dual;

                      fnd_message.set_name ('OZF', 'OZF_WF_NTF_THRESHOLD_FYI');
                      fnd_message.set_token ('BUDGET_NAME', l_budget_name, FALSE);
                      fnd_message.set_token ('VALUE_LIMIT', l_valuelimit_name, FALSE);
                      fnd_message.set_token ('OPERATOR', l_operator_meaning, FALSE);
                      fnd_message.set_token ('PERCENT_AMOUNT', budget.percent_amt, FALSE);
                      fnd_message.set_token ('BASE_LINE', budget.base_line, FALSE);
                      fnd_message.set_token ('DATE', l_today_date, FALSE);

                      l_message := fnd_message.get;

                     OZF_Utility_PVT.create_log(l_return_status,
                                                'FTHO',
                                                budget.threshold_rule_id,
                                                l_message,
                                                1,
                                                'GENERAL',
                                                'NOTIFY',
                                                budget.budget_id,
                                                budget.threshold_id,
                                                l_trans_id,
                                                SYSDATE
                                                );

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                    END IF;
                  END IF;

                    l_value_limit := 0;
                    l_base_line_amt := 0;
                    l_value_limit_type := '';
                    l_operation_result := '';
                    l_notification_result := '';

             --######
            END;
          END LOOP;
         END;
        END LOOP;
      l_owner_table.delete;

      --Create owner_message table.
      FOR logs IN c_log_message(l_trans_id) LOOP
       OPEN c_owner(logs.budget_id);
       FETCH c_owner INTO l_owner_id,l_parent_fund_id;
       CLOSE c_owner;

       OPEN c_parent_owner(l_parent_fund_id);
       FETCH c_parent_owner INTO l_parent_owner_id;
       CLOSE c_parent_owner;

       l_owner_table(l_count).owner := l_owner_id;
       l_owner_table(l_count).parent_owner := NVL(l_parent_owner_id,0);
       l_owner_table(l_count).message_text := logs.log_message_text;
       l_owner_table(l_count).remove_flag := 'F';

       l_count := l_count +1;
      END LOOP;
      --Combine message for same owner and parent owner and create notify_tabel.
      l_count := 1;
      IF l_owner_table.FIRST IS NOT NULL AND l_owner_table.LAST IS NOT NULL THEN
      FOR i IN NVL(l_owner_table.FIRST, 1) .. NVL(l_owner_table.LAST, 0) LOOP
         l_counter := 1;

         IF l_owner_table(i).remove_flag = 'F' THEN
            --l_message := l_owner_table(i).message_text;
            l_message := l_owner_table(i).message_text|| fnd_global.local_chr(10);
            l_notify_table(l_count).owner :=  l_owner_table(i).owner;
            l_notify_table(l_count).parent_owner :=l_owner_table(i).parent_owner;
            l_parent_owner_id := l_owner_table(i).parent_owner;
            l_owner_table(i).remove_flag := 'T';

            FOR j IN NVL(l_owner_table.FIRST, 1) .. NVL(l_owner_table.LAST, 0) LOOP
                 IF j <> i AND l_owner_table(j).remove_flag = 'F' AND l_parent_owner_id = l_owner_table(j).parent_owner THEN
                     --l_message := l_message || fnd_global.local_chr(10)|| l_owner_table(j).message_text || '. ' || fnd_global.local_chr(10);
                     l_message := l_message || l_owner_table(j).message_text || fnd_global.local_chr(10);
                     l_owner_table(j).remove_flag := 'T';

                     --restricting 15 messages to notification -bug 5390527
                     l_counter := l_counter+1;
                     IF l_counter = 15 THEN
                        EXIT;
                     END IF;
                 END IF;
            END LOOP;
            l_notify_table(l_count).message_text := l_message;
            l_count := l_count + 1;
         END IF;
        EXIT WHEN l_owner_table.COUNT = 0;
      END LOOP;
      END IF;

      IF l_notify_table.FIRST IS NOT NULL AND l_notify_table.LAST IS NOT NULL THEN
        --MAKE A CALL TO NOTIFICATION PROGRAM WHEN READY
        FOR i IN  NVL(l_notify_table.FIRST, 0)..NVL(l_notify_table.LAST, 0) LOOP

        OPEN c_log_seq;
        FETCH c_log_seq INTO l_log_id;
        CLOSE c_log_seq;

       /* No need to store all the combined messages in log table -bug 5390527
          OZF_Utility_PVT.create_log(x_return_status =>l_return_status,
                                     p_arc_log_used_by =>'FTHO',
                                     p_log_used_by_id => l_notify_table(i).owner,
                                     p_msg_data =>l_notify_table(i).message_text,
                                     p_msg_level =>1,
                                     p_msg_type => 'COMBINED',
                                     p_desc =>'NOTIFY',
                                     --p_budget_id =>null,
                                     --p_threshold_id => null,
                                     --p_transaction_id => null,
                                     p_notification_creat_date => SYSDATE,
                                     p_activity_log_id => l_log_id
                                     );*/
        IF G_DEBUG THEN
           OZF_UTILITY_PVT.debug_message('Call workflow: ' || l_return_status );
        END IF;

        start_process(l_api_version_number,
                                            l_Msg_Count,
                                            l_Msg_Data,
                                            l_return_status,
                                            l_notify_table(i).owner,
                                            l_notify_table(i).parent_owner,
                                            l_notify_table(i).message_text,
                                            l_log_id
                                           );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;
       END LOOP;
       END IF;


      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('PUBLIC API: ' || l_api_name || 'END');
      END IF;
      x_retcode                  := 0;

      ozf_utility_pvt.write_conc_log(l_msg_data);
      OZF_UTILITY_PVT.debug_message( 'End of Budget Threshold ........ ');
      OZF_UTILITY_PVT.debug_message( 'Start of Quota Threshold ........ ');

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'End of Budget Threshold ........ ');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of Quota Threshold ........ ');
      OZF_QUOTA_THRESHOLD_PVT.validate_quota_threshold(
                  x_errbuf => l_errbuf,
                  x_retcode => l_retcode);
      IF l_retcode <> 0 THEN
          x_errbuf := l_errbuf;
          x_retcode := l_retcode;
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN Quota Threshold ........ l_errbuf :' || l_errbuf);
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      COMMIT;
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'End of Quota Threshold ........ ');
      OZF_UTILITY_PVT.debug_message( 'End of Quota Threshold ........ ');
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_THRESHOLD_RULE_PVT;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception G_EXC_ERROR '||l_api_name);
     x_retcode                  := 1;
     x_errbuf                   := l_msg_data;
     ozf_utility_pvt.write_conc_log(x_errbuf);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_THRESHOLD_RULE_PVT;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception G_EXC_UNEXPECTED_ERROR '||l_api_name);
    x_retcode                  := 1;
    x_errbuf                   := l_msg_data;
    ozf_utility_pvt.write_conc_log(x_errbuf);

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_THRESHOLD_RULE_PVT;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception OTHERS '||l_api_name);
     x_retcode                  := 1;
     x_errbuf                   := l_msg_data;
     ozf_utility_pvt.write_conc_log(x_errbuf);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : ' || SQLCODE||SQLERRM);
END validate_threshold;

END Ozf_Threshold_Pvt;


/
