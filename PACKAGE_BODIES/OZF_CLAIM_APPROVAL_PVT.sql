--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_APPROVAL_PVT" AS
/* $Header: ozfvcawb.pls 120.7.12010000.6 2009/07/27 06:46:09 muthsubr ship $ */

g_pkg_name     CONSTANT VARCHAR2(30) := 'OZF_Claim_Approval_PVT';
g_file_name    CONSTANT VARCHAR2(15) := 'ozfvcawb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

--------------------------------------------------------------------------
function find_org_id (p_claim_id IN NUMBER)
return number is

l_org_id number;

cursor get_claim_org_csr(p_id in number) is
select org_id
from ozf_claims_all
where claim_id = p_id;

begin

 open get_claim_org_csr(p_claim_id);
    fetch get_claim_org_csr into l_org_id;
 close get_claim_org_csr;

 return l_org_id;

end find_org_id;
--------------------------------------------------------------------------
procedure set_org_ctx (p_org_id IN NUMBER) is

begin

     if p_org_id is not NULL then
       MO_GLOBAL.set_policy_context('S', p_org_id);  -- R12 Enhancements
     end if;

end set_org_ctx;

PROCEDURE make_history_data(
  p_activity_id    IN NUMBER,
  p_requester_id   IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2
) IS

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_approval_detail_id    NUMBER;
  l_appr_seq                NUMBER;
  l_appr_type               VARCHAR2(30);
  l_obj_appr_id             NUMBER;
  l_appr_hist_rec           AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;

CURSOR c_approver(rule_id IN NUMBER) IS
     SELECT approver_seq, approver_type, object_approver_id
       FROM ams_approvers
      WHERE ams_approval_detail_id = rule_id
       AND  active_flag = 'Y'
       AND  TRUNC(SYSDATE) BETWEEN NVL(start_date_active,SYSDATE -1 )
       AND TRUNC(NVL(end_date_active,SYSDATE + 1));


BEGIN
          x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

       -- The data Deletion is necessary if Claim is Resubmitted for Approval
       -- Processign is only required for Earning and Performance

	   AMS_Appr_Hist_PVT.Delete_Appr_Hist(
	     p_api_version_number => 1.0,
	     p_init_msg_list      => FND_API.G_FALSE,
	     p_commit             => FND_API.G_FALSE,
	     p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
	     x_return_status      => l_return_status,
	     x_msg_count          => l_msg_count,
	     x_msg_data           => l_msg_data,
	     p_object_id          => p_activity_id,
	     p_object_type_code   => 'CLAM',
	     p_sequence_num       => null,
	     p_action_code        => null,
	     p_object_version_num => null,
	     p_approval_type      => 'EARNING'
	   );

	   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	      x_return_status := Fnd_Api.G_RET_STS_ERROR;
	      RETURN;
	   END IF;

      	   AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
	     p_object_id          => p_activity_id,
             p_object_type_code   => 'CLAM',
             p_sequence_num       => null,
	     p_action_code        => null,
             p_object_version_num => null,
             p_approval_type      => 'PERFORMANCE'
	   );

	   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	      x_return_status := Fnd_Api.G_RET_STS_ERROR;
	      RETURN;
	   END IF;
         --Populate the History Table with Approval Data  for EARNING and PERFORMANCE
	   l_appr_hist_rec.object_id        := p_activity_id;
	   l_appr_hist_rec.object_type_code := 'CLAM';
	   l_appr_hist_rec.sequence_num     := 0;
	   l_appr_hist_rec.object_version_num := 100;
	   l_appr_hist_rec.action_code      := 'OPEN';
	   l_appr_hist_rec.action_date      := sysdate;
	   l_appr_hist_rec.approver_id      := p_requester_id;
	   l_appr_hist_rec.note             := null;
	   l_appr_hist_rec.approval_type    := 'EARNING';
	   l_appr_hist_rec.approver_type    := 'USER'; -- User always submits



       IF OZF_Claim_Accrual_PVT.Earnings_Approval_Required(p_activity_id) = FND_API.g_true THEN
	   AMS_Gen_Approval_Pvt.Get_Approval_Rule(p_activity_id ,
	   'CLAM',
	   'EARNING',
	   null,
	   x_approval_detail_id  => l_approval_detail_id,
	   x_return_status       => l_return_status);

l_appr_hist_rec.approval_detail_id    := l_approval_detail_id;


	 OPEN c_approver(l_approval_detail_id);
         LOOP
         FETCH c_approver INTO l_appr_seq, l_appr_type, l_obj_appr_id;
         EXIT WHEN c_approver%NOTFOUND;

		 -- Set Record Attributes that will change for each approver
		 l_appr_hist_rec.sequence_num  := l_appr_seq;
		 l_appr_hist_rec.approver_type := l_appr_type;
		 l_appr_hist_rec.approver_id   := l_obj_appr_id;

		 AMS_Appr_Hist_PVT.Create_Appr_Hist(
		    p_api_version_number => 1.0,
		    p_init_msg_list      => FND_API.G_FALSE,
		    p_commit             => FND_API.G_FALSE,
		    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		    x_return_status      => l_return_status,
		    x_msg_count          => l_msg_count,
		    x_msg_data           => l_msg_data,
		    p_appr_hist_rec      => l_appr_hist_rec
		    );

		 IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		    x_return_status := Fnd_Api.G_RET_STS_ERROR;
		    RETURN;
		 END IF;

         END LOOP;
         CLOSE c_approver;
      END IF;

	   l_appr_hist_rec.approval_type    := 'PERFORMANCE';
	   l_appr_hist_rec.sequence_num     := 0;

     IF OZF_Claim_Accrual_PVT.Perform_Approval_Required(p_activity_id) = FND_API.g_true THEN
	   AMS_Gen_Approval_Pvt.Get_Approval_Rule(p_activity_id ,
	   'CLAM',
	   'PERFORMANCE',
	   null,
	   x_approval_detail_id  => l_approval_detail_id,
	   x_return_status       => l_return_status);

	   l_appr_hist_rec.approval_detail_id    := l_approval_detail_id;


         OPEN c_approver(l_approval_detail_id);
         LOOP
		 FETCH c_approver INTO l_appr_seq, l_appr_type, l_obj_appr_id;
		 EXIT WHEN c_approver%NOTFOUND;

		 -- Set Record Attributes that will change for each approver
		 l_appr_hist_rec.sequence_num  := l_appr_seq;
		 l_appr_hist_rec.approver_type := l_appr_type;
		 l_appr_hist_rec.approver_id   := l_obj_appr_id;

		 AMS_Appr_Hist_PVT.Create_Appr_Hist(
		    p_api_version_number => 1.0,
		    p_init_msg_list      => FND_API.G_FALSE,
		    p_commit             => FND_API.G_FALSE,
		    p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
		    x_return_status      => l_return_status,
		    x_msg_count          => l_msg_count,
		    x_msg_data           => l_msg_data,
		    p_appr_hist_rec      => l_appr_hist_rec
		    );

		 IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		    x_return_status := Fnd_Api.G_RET_STS_ERROR;
		    RETURN;
		 END IF;

         END LOOP;
         CLOSE c_approver;
    END IF;
END make_history_data;

--------------------------------------------------------------------------
PROCEDURE get_offer_perf_req(
   p_claim_id           IN NUMBER
  ,x_offer_perf_req     OUT NOCOPY VARCHAR2
)
IS
l_offer_perf_tbl     OZF_Claim_Accrual_PVT.offer_performance_tbl_type;
l_offer_name         VARCHAR2(30);

CURSOR csr_offer_name(cv_offer_id IN NUMBER) IS
  SELECT o.offer_code
  FROM ozf_offers o
  WHERE o.qp_list_header_id = cv_offer_id;

BEGIN
   OZF_Claim_Accrual_PVT.Check_Offer_Performance_Tbl(
      p_claim_id       => p_claim_id
     ,x_offer_perf_tbl => l_offer_perf_tbl
   );

   IF l_offer_perf_tbl.count > 0 THEN
      FOR j IN l_offer_perf_tbl.FIRST..l_offer_perf_tbl.LAST LOOP
         OPEN csr_offer_name(l_offer_perf_tbl(j).offer_id);
         FETCH csr_offer_name INTO l_offer_name;
         CLOSE csr_offer_name;

         FND_MESSAGE.set_name('OZF', 'OZF_EARN_OFFER_PERF_NTF');
         FND_MESSAGE.set_token('OFFER', l_offer_name, false);

         x_offer_perf_req := x_offer_perf_req || FND_MESSAGE.get;
      END LOOP;
   END IF;
END get_offer_perf_req;

--------------------------------------------------------------------------
PROCEDURE get_offer_earn_req(
   p_claim_id           IN NUMBER
  ,x_offer_earn_req     OUT NOCOPY VARCHAR2
)
IS
l_offer_earn_tbl     OZF_Claim_Accrual_PVT.offer_earning_tbl_type;
l_offer_name         VARCHAR2(30);

CURSOR csr_offer_name(cv_offer_id IN NUMBER) IS
  SELECT o.offer_code
  FROM ozf_offers o
  WHERE o.qp_list_header_id = cv_offer_id;

BEGIN
   OZF_Claim_Accrual_PVT.Check_Offer_Earning_Tbl(
      p_claim_id       => p_claim_id
     ,x_offer_earn_tbl => l_offer_earn_tbl
   );

   IF l_offer_earn_tbl.count > 0 THEN
      FOR j IN l_offer_earn_tbl.FIRST..l_offer_earn_tbl.LAST LOOP
         FND_MESSAGE.set_name('OZF', 'OZF_EARN_OFFER_EARN_NTF');
         FND_MESSAGE.set_token('AMOUNT', l_offer_earn_tbl(j).acctd_amount_over, false);

         OPEN csr_offer_name(l_offer_earn_tbl(j).offer_id);
         FETCH csr_offer_name INTO l_offer_name;
         CLOSE csr_offer_name;
         FND_MESSAGE.set_token('OFFER', l_offer_name, false);

         x_offer_earn_req := x_offer_earn_req || FND_MESSAGE.get;
      END LOOP;
   END IF;

END get_offer_earn_req;

--------------------------------------------------------------------------
-- PROCEDURE
--   notify_requestor_fyi
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either text or html
--
-- IN
--   document_id   - Item Key
--   display_type  - either 'text/plain' or 'text/html'
--   document      - document buffer
--   document_type - type of document buffer created, either 'text/plain'
--                   or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001  Prashanth Nerella     CREATION
--   05/29/2001  MICHELLE CHANG        MODIFIED
--------------------------------------------------------------------------
PROCEDURE notify_requestor_fyi(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)    := g_pkg_name || 'Notify_Requestor_FYI';
l_hyphen_pos1         NUMBER;
l_fyi_notification    VARCHAR2(10000);
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approval_type       VARCHAR2(30);
l_approver            VARCHAR2(200);
l_note                VARCHAR2(3000);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);
l_requested_amt       NUMBER;
l_claim_id            NUMBER;
l_claim_number        VARCHAR2(30);
l_account_number      VARCHAR2(30);
l_account_name        VARCHAR2(360);
l_currency            VARCHAR2(80);
l_amount_settled      NUMBER;
l_claim_date          DATE;
l_due_date            DATE;
l_claim_type          VARCHAR2(30);
l_billto_site         VARCHAR2(40);
l_cm_reason           VARCHAR2(80);
l_adj_reason          VARCHAR2(80);
l_payment_method      VARCHAR2(80);
l_claim_source        VARCHAR2(30);
l_offer_req           VARCHAR2(2000);

CURSOR c_claim_rec(p_claim_id IN NUMBER) IS
  SELECT c.claim_number
  ,      a.account_number
  ,      hp.party_name
  ,      curr.name
  ,      c.amount_settled
  ,      c.claim_date
  ,      c.due_date
  ,      ct.name
  ,      hc.location
  ,      rlk_cm.meaning
  ,      rlk_adj.meaning
  ,      lk_pm.meaning
  ,      'resource_name'
  FROM ozf_claims_all c
  ,    hz_cust_accounts a
  ,    hz_parties hp
  ,    ozf_claim_types_all_vl ct
  ,    hz_cust_site_uses_all hc
  ,    ozf_reason_codes_all_b rc
  ,    ar_lookups rlk_cm
  ,    ar_lookups rlk_adj
  ,    ozf_lookups lk_pm
  ,    fnd_currencies_vl curr
  WHERE c.claim_id = p_claim_id
  AND c.cust_account_id = a.cust_account_id
  AND a.party_id = hp.party_id
  AND c.currency_code = curr.currency_code
  AND c.claim_type_id = ct.claim_type_id
  AND c.cust_billto_acct_site_id = hc.site_use_id(+)
  AND c.reason_code_id = rc.reason_code_id
  AND c.payment_method = lk_pm.lookup_code
  AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
  AND rc.reason_code = rlk_cm.lookup_code(+)
  AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
  AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
  AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  END IF;
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_claim_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_requested_amt := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_REQUESTED_AMOUNT'
                     );

  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'AMS_PREV_APPROVER_NOTE'
            );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_APPROVER_DISPLAY_NAME'
                );

  l_approval_type := wf_engine.GetItemAttrText(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_APPROVAL_TYPE'
                     );

-- Start Bug fix for 8656583
/*   l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'AMS_NOTES_FROM_REQUESTOR'
            );
*/
-- End Bug fix for 8656583

  OPEN c_claim_rec(l_claim_id);
  FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_settled
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source;
  CLOSE c_claim_rec;

  IF l_approval_type = 'PERFORMANCE' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_FORD_SUBJ');
  ELSIF l_approval_type = 'EARNING' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_FORD_SUBJ');
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_FORWARD_SUBJ');
     fnd_message.set_token('CURRENCY_CODE', l_currency, false);
     fnd_message.set_token('AMOUNT', l_requested_amt, false);
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  --fnd_message.set_token('APPROVER', l_approver, false);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'FYI_SUBJECT'
    ,avalue   => l_subject
  );

  IF l_approval_type = 'PERFORMANCE' THEN
     get_offer_perf_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_FORD_INFO');
     fnd_message.set_token('OFFR_PERF_REQ', l_offer_req, false);
  ELSIF l_approval_type = 'EARNING' THEN
     get_offer_earn_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_FORD_INFO');
     fnd_message.set_token('OFFR_EARN_REQ', l_offer_req, false);
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPROVAL_INFO');
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_FORWARD_INFO');
  END IF;
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('DATE', TO_CHAR(SYSDATE, 'MM-DD-YYYY'), false);
  fnd_message.set_token('TIME', TO_CHAR(SYSDATE, 'HH24:MI'), false);
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  fnd_message.set_token('CLAIM_TYPE', l_claim_type, false);
  fnd_message.set_token('CLAIM_DATE', l_claim_date, false);
  fnd_message.set_token('DUE_DATE', l_due_date, false);
  fnd_message.set_token('CUSTOMER_NAME', l_account_name, false);
  fnd_message.set_token('CUST_ACCT_NUMBER', l_account_number, false);
  fnd_message.set_token('BILL_TO_SITE', l_billto_site, false);
  fnd_message.set_token('CM_REASON', l_cm_reason, false);
  fnd_message.set_token('ADJ_REASON', l_adj_reason, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('AMOUNT', l_requested_amt, false);
  fnd_message.set_token('SETTLEMENT_METHOD', l_payment_method, false);
  fnd_message.set_token('JUSTIFICATION_NOTES', l_note, false);
  -- l_string1 := Substr(FND_MESSAGE.Get,1,2500);
  l_body := fnd_message.get;
  /*
  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey => l_item_key
              ,aname => 'NOTE');


  l_forwarder :=
     wf_engine.getitemattrtext(
        itemtype => l_item_type
       ,itemkey => l_item_key
       ,aname => 'OZF_FORWARD_FROM_USERNAME');
*/
  --  IF (display_type = 'text/plain') THEN
  -- l_fyi_notification := l_subject || FND_GLOBAL.LOCAL_CHR(10) || l_body;
  l_fyi_notification := l_body;
  document := document || l_fyi_notification;
  document_type := 'text/plain';
  RETURN;
  --  END IF;
  /*
  IF (display_type = 'text/html') THEN
    l_fyi_notification := l_string ||
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
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'NOTIFY_REQUESTOR_FYI'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_fyi;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_approval_required
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
--
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella   CREATION
--   05/29/2001   MICHELLE CHANG      MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_approval_required(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)   := g_pkg_name || 'notify_approval_required';
l_hyphen_pos1         NUMBER;
l_appreq_notification VARCHAR2(10000);
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approval_type       VARCHAR2(30);
l_approver            VARCHAR2(200);
l_forwarder           VARCHAR2(30);
l_note                VARCHAR2(3000);
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3500);
l_requester           VARCHAR2(30);
l_requested_amt       NUMBER;
l_approved_amt        NUMBER;

l_claim_id            NUMBER;
l_claim_number        VARCHAR2(30);
l_account_number      VARCHAR2(30);
l_account_name        VARCHAR2(360);
l_currency            VARCHAR2(80);
l_amount_remaining    NUMBER;
l_claim_date          DATE;
l_due_date            DATE;
l_claim_type          VARCHAR2(30);
l_billto_site         VARCHAR2(40);
l_cm_reason           VARCHAR2(80);
l_adj_reason          VARCHAR2(80);
l_payment_method      VARCHAR2(80);
l_claim_source        VARCHAR2(30);
l_pre_approver        VARCHAR2(360);
l_offer_req           VARCHAR2(2000);

CURSOR c_claim_rec(p_claim_id IN NUMBER) IS
  SELECT c.claim_number
  ,      a.account_number
  ,      hp.party_name
  ,      curr.name
  ,      c.amount_settled
  ,      c.claim_date
  ,      c.due_date
  ,      ct.name
  ,      hc.location
  ,      rlk_cm.meaning
  ,      rlk_adj.meaning
  ,      lk_pm.meaning
  ,      'resource_name'
  FROM ozf_claims_all c
  ,    hz_cust_accounts a
  ,    hz_parties hp
  ,    ozf_claim_types_all_vl ct
  ,    hz_cust_site_uses_all hc
  ,    ozf_reason_codes_all_b rc
  ,    ar_lookups rlk_cm
  ,    ar_lookups rlk_adj
  ,    ozf_lookups lk_pm
  ,    fnd_currencies_vl curr
  WHERE c.claim_id = p_claim_id
  AND c.cust_account_id = a.cust_account_id
  AND a.party_id = hp.party_id
  AND c.currency_code = curr.currency_code
  AND c.claim_type_id = ct.claim_type_id
  AND c.cust_billto_acct_site_id = hc.site_use_id(+)
  AND c.reason_code_id = rc.reason_code_id
  AND c.payment_method = lk_pm.lookup_code
  AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
  AND rc.reason_code = rlk_cm.lookup_code(+)
  AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
  AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
  AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  END IF;
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);
  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_claim_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_requested_amt := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_REQUESTED_AMOUNT'
                     );

  l_requester := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_REQUESTER'
                 );

  l_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_APPROVER_DISPLAY_NAME'
                );

  l_pre_approver := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_PREV_APPROVER_DISP_NAME'
                );


 -- start of Bugfix 5686652
 -- If the approver is the first in line, then the requestor's comments must be shown
 -- If the approver is not the first, previous approver's comments must be shown
 /* Commented for bug fix 8656583
 -- start of Bugfix 7334602
     l_note := wf_engine.getitemattrtext(
		       itemtype => l_item_type
		      ,itemkey  => l_item_key
		      ,aname    => 'AMS_NOTES_FROM_REQUESTOR'
		    );
    -- end of Bugfix 7334602
    -- end of Bugfix 5686652
*/

--Start of Bug fix 8656583
   l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'AMS_PREV_APPROVER_NOTE'
            );
--End of Bug fix 8656583

  /*
  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'NOTE'
            );
  */

  l_approval_type := wf_engine.GetItemAttrText(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_APPROVAL_TYPE'
                     );

  OPEN c_claim_rec(l_claim_id);
  FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_remaining
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source;
  CLOSE c_claim_rec;

  IF l_approval_type = 'PERFORMANCE' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPR_SUBJ');
  ELSIF l_approval_type = 'EARNING' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPR_SUBJ');
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPROVAL_SUBJ');
     fnd_message.set_token('CURRENCY_CODE', l_currency, false);
     fnd_message.set_token('AMOUNT', l_requested_amt, false);
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  -- l_string := Substr(FND_MESSAGE.Get,1,2500);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'APP_SUBJECT'
    ,avalue   => l_subject
  );

  IF l_approval_type = 'PERFORMANCE' THEN
     get_offer_perf_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPR_INFO');
     fnd_message.set_token('OFFR_PERF_REQ', l_offer_req, false);
  ELSIF l_approval_type = 'EARNING' THEN
     get_offer_earn_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPR_INFO');
     fnd_message.set_token('OFFR_EARN_REQ', l_offer_req, false);
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPROVAL_INFO');
  END IF;
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('AMOUNT', l_requested_amt, false);
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  fnd_message.set_token('CLAIM_TYPE', l_claim_type, false);
  fnd_message.set_token('CLAIM_DATE', l_claim_date, false);
  fnd_message.set_token('DUE_DATE', l_due_date, false);
  fnd_message.set_token('CUSTOMER_NAME', l_account_name, false);
  fnd_message.set_token('CUST_ACCT_NUMBER', l_account_number, false);
  fnd_message.set_token('BILL_TO_SITE', l_billto_site, false);
  fnd_message.set_token('CM_REASON', l_cm_reason, false);
  fnd_message.set_token('ADJ_REASON', l_adj_reason, false);
  fnd_message.set_token('SETTLEMENT_METHOD', l_payment_method, false);

-- Lable for the token JUSTIFICATION_NOTES now reads as Comments

  fnd_message.set_token('JUSTIFICATION_NOTES', l_note, false);
  fnd_message.set_token('APPROVER_NAME', l_pre_approver, false);

-- fnd_message.set_token('DATE', TO_CHAR(SYSDATE, 'MM-DD-YYYY'), false);
-- fnd_message.set_token('TIME', TO_CHAR(SYSDATE, 'HH24:MI'), false);
-- l_string1 := Substr(FND_MESSAGE.Get,1,2500);

  l_body := fnd_message.get;

  /*
  -- l_note := wf_engine.getitemattrtext(
  --             itemtype => l_item_type
  --            ,itemkey => l_item_key
  --            ,aname => 'NOTE');
  --
  --
  -- l_forwarder :=
  --    wf_engine.getitemattrtext(
  --       itemtype => l_item_type
  --      ,itemkey => l_item_key
  --      ,aname => 'AMS_FORWARD_FROM_USERNAME');
  */

  -- IF (display_type = 'text/plain') THEN
  -- l_appreq_notification := l_subject || FND_GLOBAL.LOCAL_CHR(10) || l_body;

  l_appreq_notification := l_body;
  document := document || l_appreq_notification;
  document_type := 'text/plain';
  RETURN;

  --  END IF;

  /*
  -- IF (display_type = 'text/html') THEN
  --   l_appreq_notification := l_string ||
  --                            FND_GLOBAL.LOCAL_CHR(10) ||
  --                            l_string1 ||
  --                            FND_GLOBAL.LOCAL_CHR(10) ||
  --                            l_string2;
  --   document := document||l_appreq_notification;
  --   document_type := 'text/html';
  --   RETURN;
  -- END IF;
  */

EXCEPTION
  WHEN OTHERS THEN
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'NOTIFY_APPROVAL_REQUIRED'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_approval_required;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_appr_req_reminder
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella    CREATION
--   05/29/2001   Michelle Chang       MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_appr_req_reminder(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name               VARCHAR2(100)   := g_pkg_name || 'notify_appr_req_reminder';
l_hyphen_pos1            NUMBER;
l_apprem_notification    VARCHAR2(10000);
l_activity_type          VARCHAR2(30);
l_item_type              VARCHAR2(30);
l_item_key               VARCHAR2(30);
l_approval_type          VARCHAR2(30);
l_approver               VARCHAR2(200);
l_note                   VARCHAR2(3000);
l_approved_amt           NUMBER;
l_requested_amt          NUMBER;
l_forwarder              VARCHAR2(30);
l_subject                VARCHAR2(500);
l_body                   VARCHAR2(3000);
l_approver               VARCHAR2(200);
l_requester              VARCHAR2(30);

l_claim_id               NUMBER;
l_claim_number           VARCHAR2(30);
l_account_number         VARCHAR2(30);
l_account_name           VARCHAR2(360);
l_currency               VARCHAR2(80);
l_amount_settled         NUMBER;
l_claim_date             DATE;
l_due_date               DATE;
l_claim_type             VARCHAR2(30);
l_billto_site            VARCHAR2(40);
l_cm_reason              VARCHAR2(80);
l_adj_reason             VARCHAR2(80);
l_payment_method         VARCHAR2(80);
l_claim_source           VARCHAR2(30);
l_offer_req              VARCHAR2(2000);

CURSOR c_claim_rec(p_claim_id   IN   NUMBER) IS
  SELECT c.claim_number
  ,      a.account_number
  ,      hp.party_name
  ,      curr.name
  ,      c.amount_settled
  ,      c.claim_date
  ,      c.due_date
  ,      ct.name
  ,      hc.location
  ,      rlk_cm.meaning
  ,      rlk_adj.meaning
  ,      lk_pm.meaning
  ,      'resource_name'
  FROM ozf_claims_all c
  ,    hz_cust_accounts a
  ,    hz_parties hp
  ,    ozf_claim_types_all_vl ct
  ,    hz_cust_site_uses_all hc
  ,    ozf_reason_codes_all_b rc
  ,    ar_lookups rlk_cm
  ,    ar_lookups rlk_adj
  ,    ozf_lookups lk_pm
  ,    fnd_currencies_vl curr
  WHERE c.claim_id = p_claim_id
  AND c.cust_account_id = a.cust_account_id
  AND a.party_id = hp.party_id
  AND c.currency_code = curr.currency_code
  AND c.claim_type_id = ct.claim_type_id
  AND c.cust_billto_acct_site_id = hc.site_use_id(+)
  AND c.reason_code_id = rc.reason_code_id
  AND c.payment_method = lk_pm.lookup_code
  AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
  AND rc.reason_code = rlk_cm.lookup_code(+)
  AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
  AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
  AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  END IF;
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_claim_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_requested_amt := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_REQUESTED_AMOUNT'
                     );

  l_requester := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_REQUESTER'
                 );

  l_approval_type := wf_engine.GetItemAttrText(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_APPROVAL_TYPE'
                     );

  OPEN c_claim_rec(l_claim_id);
  FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_settled
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source;
  CLOSE c_claim_rec;

  IF l_approval_type = 'PERFORMANCE' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_REM_SUBJ');
  ELSIF l_approval_type = 'EARNING' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_REM_SUBJ');
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPR_REM_SUBJ');
     fnd_message.set_token('CURRENCY_CODE', l_currency, false);
     fnd_message.set_token('AMOUNT', l_requested_amt, false);
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  --  l_string := Substr(FND_MESSAGE.Get,1,2500);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'APP_SUBJECT'
    ,avalue   => l_subject
  );

  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'AMS_PREV_APPROVER_NOTE'
            );

  IF l_approval_type = 'PERFORMANCE' THEN
     get_offer_perf_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_REM_INFO');
     fnd_message.set_token('OFFR_PERF_REQ', l_offer_req, false);
  ELSIF l_approval_type = 'EARNING' THEN
     get_offer_earn_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_REM_INFO');
     fnd_message.set_token('OFFR_EARN_REQ', l_offer_req, false);
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPR_REM_INFO');
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  fnd_message.set_token('CLAIM_TYPE', l_claim_type, false);
  fnd_message.set_token('CLAIM_DATE', l_claim_date, false);
  fnd_message.set_token('DUE_DATE', l_due_date, false);
  fnd_message.set_token('CUSTOMER_NAME', l_account_name, false);
  fnd_message.set_token('CUST_ACCT_NUMBER', l_account_number, false);
  fnd_message.set_token('BILL_TO_SITE', l_billto_site, false);
  fnd_message.set_token('CM_REASON', l_cm_reason, false);
  fnd_message.set_token('ADJ_REASON', l_adj_reason, false);
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('AMOUNT', l_requested_amt, false);
  fnd_message.set_token('SETTLEMENT_METHOD', l_payment_method, false);
  fnd_message.set_token('JUSTIFICATION_NOTES', l_note, false);
  -- l_string1 := Substr(FND_MESSAGE.Get,1,2500);
  l_body := fnd_message.get;
  /*
  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey => l_item_key
              ,aname => 'NOTE');


  l_forwarder :=
     wf_engine.getitemattrtext(
        itemtype => l_item_type
       ,itemkey => l_item_key
       ,aname => 'OZF_FORWARD_FROM_USERNAME');
  */
  --  IF (display_type = 'text/plain') THEN
  -- l_apprem_notification := l_subject || FND_GLOBAL.LOCAL_CHR(10) || l_body;
  l_apprem_notification := l_body;
  document := document || l_apprem_notification;
  document_type := 'text/plain';
  RETURN;
  --  END IF;

  /*
  IF (display_type = 'text/html') THEN
    l_appreq_notification := l_string ||
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
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'NOTIFY_APPR_REQ_REMINDER'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_appr_req_reminder;


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of Approval
--
-- PURPOSE
--   Generate the Approval Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001   Prashanth Nerella   CREATION
--   05/30/2001   MICHELLE CHANG      MODIFIED
----------------------------------------------------------------------------
PROCEDURE notify_requestor_of_approval(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name             VARCHAR2(100)   := g_pkg_name || 'Notify_Requestor_of_approval';
l_hyphen_pos1          NUMBER;
l_appr_notification    VARCHAR2(10000);
l_activity_type        VARCHAR2(30);
l_item_type            VARCHAR2(30);
l_item_key             VARCHAR2(30);
l_approval_type        VARCHAR2(30);
l_approver             VARCHAR2(200);
l_note                 VARCHAR2(3000);
l_approved_amt         NUMBER;
l_subject              VARCHAR2(500);
l_body                 VARCHAR2(3000);
l_requester            VARCHAR2(30);
l_requested_amt        NUMBER;

l_claim_id            NUMBER;
l_claim_number        VARCHAR2(30);
l_account_number      VARCHAR2(30);
l_account_name        VARCHAR2(360);
l_currency            VARCHAR2(80);
l_amount_settled      NUMBER;
l_claim_date          DATE;
l_due_date            DATE;
l_claim_type          VARCHAR2(30);
l_billto_site         VARCHAR2(40);
l_cm_reason           VARCHAR2(80);
l_adj_reason          VARCHAR2(80);
l_payment_method      VARCHAR2(80);
l_claim_source        VARCHAR2(30);
l_offer_req           VARCHAR2(2000);

CURSOR c_claim_rec(p_claim_id IN NUMBER) IS
  SELECT c.claim_number
  ,      a.account_number
  ,      hp.party_name
  ,      curr.name
  ,      c.amount_settled
  ,      c.claim_date
  ,      c.due_date
  ,      ct.name
  ,      hc.location
  ,      rlk_cm.meaning
  ,      rlk_adj.meaning
  ,      lk_pm.meaning
  ,      'resource_name'
  FROM ozf_claims_all c
  ,    hz_cust_accounts a
  ,    hz_parties hp
  ,    ozf_claim_types_all_vl ct
  ,    hz_cust_site_uses_all hc
  ,    ozf_reason_codes_all_b rc
  ,    ar_lookups rlk_cm
  ,    ar_lookups rlk_adj
  ,    ozf_lookups lk_pm
  ,    fnd_currencies_vl curr
  WHERE c.claim_id = p_claim_id
  AND c.cust_account_id = a.cust_account_id
  ANd a.party_id = hp.party_id
  AND c.currency_code = curr.currency_code
  AND c.claim_type_id = ct.claim_type_id
  AND c.cust_billto_acct_site_id = hc.site_use_id(+)
  AND c.reason_code_id = rc.reason_code_id
  AND c.payment_method = lk_pm.lookup_code
  AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
  AND rc.reason_code = rlk_cm.lookup_code(+)
  AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
  AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
  AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  END IF;
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                         itemtype => l_item_type
                        ,itemkey  => l_item_key
                        ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_claim_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_approved_amt := wf_engine.getitemattrtext(
                       itemtype => l_item_type
                      ,itemkey  => l_item_key
                      ,aname    => 'AMS_REQUESTED_AMOUNT'
                    );

  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'APPROVAL_NOTE'
            );

  l_approver := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey  => l_item_key
                   ,aname    => 'AMS_APPROVER_DISPLAY_NAME'
                );

  l_approval_type := wf_engine.GetItemAttrText(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_APPROVAL_TYPE'
                     );

  OPEN c_claim_rec(l_claim_id);
  FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_settled
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source;
  CLOSE c_claim_rec;

  IF l_approval_type = 'PERFORMANCE' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPRD_SUBJ');
  ELSIF l_approval_type = 'EARNING' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPRD_SUBJ');
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPROVED_SUBJ');
     fnd_message.set_token('CURRENCY_CODE', l_currency, false);
     fnd_message.set_token('AMOUNT', l_approved_amt, false);
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  --fnd_message.set_token('APPROVER', l_approver, false);
  -- l_string := Substr(FND_MESSAGE.Get,1,2500);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
      itemtype => l_item_type
     ,itemkey  => l_item_key
     ,aname    => 'APRV_SUBJECT'
     ,avalue   => l_subject
  );

  IF l_approval_type = 'PERFORMANCE' THEN
     get_offer_perf_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPRD_INFO');
     fnd_message.set_token('OFFR_PERF_REQ', l_offer_req, false);
  ELSIF l_approval_type = 'EARNING' THEN
     get_offer_earn_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPRD_INFO');
     fnd_message.set_token('OFFR_EARN_REQ', l_offer_req, false);
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_APPROVED_INFO');
  END IF;
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('AMOUNT', l_approved_amt, false);
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('DATE', TO_CHAR(SYSDATE, 'MM-DD-YYYY'), false);
  fnd_message.set_token('TIME', TO_CHAR(SYSDATE, 'HH24:MI'), false);
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  fnd_message.set_token('CLAIM_TYPE', l_claim_type, false);
  fnd_message.set_token('CLAIM_DATE', l_claim_date, false);
  fnd_message.set_token('DUE_DATE', l_due_date, false);
  fnd_message.set_token('CUSTOMER_NAME', l_account_name, false);
  fnd_message.set_token('CUST_ACCT_NUMBER', l_account_number, false);
  fnd_message.set_token('BILL_TO_SITE', l_billto_site, false);
  fnd_message.set_token('CM_REASON', l_cm_reason, false);
  fnd_message.set_token('ADJ_REASON', l_adj_reason, false);
  fnd_message.set_token('SETTLEMENT_METHOD', l_payment_method, false);
  fnd_message.set_token('COMMENTS_NOTES', l_note, false);
  --               l_string1 := Substr(FND_MESSAGE.Get,1,2500);
  l_body := fnd_message.get;
  /*
  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey => l_item_key
              ,aname => 'NOTE');


  l_forwarder :=
     wf_engine.getitemattrtext(
        itemtype => l_item_type
       ,itemkey => l_item_key
       ,aname => 'OZF_FORWARD_FROM_USERNAME');
 */
  --  IF (display_type = 'text/plain') THEN
  -- l_appr_notification := l_subject || FND_GLOBAL.LOCAL_CHR(10) || l_body;
  l_appr_notification := l_body;
  document := document || l_appr_notification;
  document_type := 'text/plain';
  RETURN;
  --  END IF;

  /*
  IF (display_type = 'text/html') THEN
    l_appreq_notification := l_string ||
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
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'NOTIFY_REQUESTOR_OF_APPROVAL'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_of_approval;

--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of rejection
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either text or html
--
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--                     or 'text/html'
-- OUT
--
-- USED BY
--   Oracle MArketing Generic Apporval
--
-- HISTORY
--   04/25/2001    Prashanth Nerella      CREATION
--   05/30/2001    MICHELLE CHANG         MODIFIED
-------------------------------------------------------------------------------
PROCEDURE notify_requestor_of_rejection(
   document_id     IN       VARCHAR2
  ,display_type    IN       VARCHAR2
  ,document        IN OUT NOCOPY   VARCHAR2
  ,document_type   IN OUT NOCOPY   VARCHAR2
)
IS
l_api_name            VARCHAR2(100)   := g_pkg_name || 'Notify_Requestor_of_rejection';
l_hyphen_pos1         NUMBER;
l_rej_notification    VARCHAR2(10000);
l_activity_type       VARCHAR2(30);
l_item_type           VARCHAR2(30);
l_item_key            VARCHAR2(30);
l_approval_type       VARCHAR2(30);
l_approver            VARCHAR2(200);
l_note                VARCHAR2(3000);
l_approved_amt        NUMBER;
l_subject             VARCHAR2(500);
l_body                VARCHAR2(3000);
l_requester           VARCHAR2(30);
l_requested_amt       NUMBER;

l_claim_id            NUMBER;
l_claim_number        VARCHAR2(30);
l_account_number      VARCHAR2(30);
l_account_name        VARCHAR2(360);
l_currency            VARCHAR2(80);
l_amount_settled      NUMBER;
l_claim_date          DATE;
l_due_date            DATE;
l_claim_type          VARCHAR2(30);
l_billto_site         VARCHAR2(40);
l_cm_reason           VARCHAR2(80);
l_adj_reason          VARCHAR2(80);
l_payment_method      VARCHAR2(80);
l_claim_source        VARCHAR2(30);
l_offer_req           VARCHAR2(2000);

CURSOR c_claim_rec(p_claim_id IN NUMBER) IS
  SELECT c.claim_number
  ,      a.account_number
  ,      hp.party_name
  ,      curr.name
  ,      c.amount_settled
  ,      c.claim_date
  ,      c.due_date
  ,      ct.name
  ,      hc.location
  ,      rlk_cm.meaning
  ,      rlk_adj.meaning
  ,      lk_pm.meaning
  ,      'resource_name'
  FROM ozf_claims_all c
  ,    hz_cust_accounts a
  ,    hz_parties hp
  ,    ozf_claim_types_all_vl ct
  ,    hz_cust_site_uses_all hc
  ,    ozf_reason_codes_all_b rc
  ,    ar_lookups rlk_cm
  ,    ar_lookups rlk_adj
  ,    ozf_lookups lk_pm
  ,    fnd_currencies_vl curr
  WHERE c.claim_id = p_claim_id
  AND c.cust_account_id = a.cust_account_id
  AND a.party_id = hp.party_id
  AND c.currency_code = curr.currency_code
  AND c.claim_type_id = ct.claim_type_id
  AND c.cust_billto_acct_site_id = hc.site_use_id(+)
  AND c.reason_code_id = rc.reason_code_id
  AND c.payment_method = lk_pm.lookup_code
  AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
  AND rc.reason_code = rlk_cm.lookup_code(+)
  AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
  AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
  AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
  END IF;
  document_type := 'text/plain';
  -- parse document_id for the ':' dividing item type name from item key value
  -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
  -- release 2.5 version of this demo
  l_hyphen_pos1 := INSTR(document_id, ':');
  l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
  l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

  l_activity_type := wf_engine.getitemattrtext(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_ACTIVITY_TYPE'
                     );

  l_claim_id := wf_engine.getitemattrtext(
                   itemtype => l_item_type
                  ,itemkey  => l_item_key
                  ,aname    => 'AMS_ACTIVITY_ID'
                );

  l_approved_amt := wf_engine.getitemattrtext(
                       itemtype => l_item_type
                      ,itemkey  => l_item_key
                      ,aname    => 'AMS_AMOUNT'
                    );

  l_note := wf_engine.getitemattrtext(
               itemtype => l_item_type
              ,itemkey  => l_item_key
              ,aname    => 'APPROVAL_NOTE'
            );

  l_approver := wf_engine.getitemattrtext(
                    itemtype => l_item_type
                   ,itemkey => l_item_key
                   ,aname => 'AMS_APPROVER_DISPLAY_NAME'
                );

  l_approval_type := wf_engine.GetItemAttrText(
                        itemtype => l_item_type
                       ,itemkey  => l_item_key
                       ,aname    => 'AMS_APPROVAL_TYPE'
                     );

  OPEN c_claim_rec(l_claim_id);
  FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_settled
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source;
  CLOSE c_claim_rec;

  IF l_approval_type = 'PERFORMANCE' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_REJ_SUBJ');
  ELSIF l_approval_type = 'EARNING' THEN
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_REJ_SUBJ');
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_REJECTED_SUBJ');
     fnd_message.set_token('CURRENCY_CODE', l_currency, false);
     fnd_message.set_token('AMOUNT', l_amount_settled, false);
  END IF;
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  --fnd_message.set_token('APPROVER', l_approver, false);
  -- l_string := Substr(FND_MESSAGE.Get,1,2500);
  l_subject := fnd_message.get;

  wf_engine.setitemattrtext(
     itemtype => l_item_type
    ,itemkey  => l_item_key
    ,aname    => 'REJECT_SUBJECT'
    ,avalue   => l_subject
  );

  IF l_approval_type = 'PERFORMANCE' THEN
     get_offer_perf_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_PERF_REJ_INFO');
     fnd_message.set_token('OFFR_PERF_REQ', l_offer_req, false);
  ELSIF l_approval_type = 'EARNING' THEN
     get_offer_earn_req(l_claim_id, l_offer_req);
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_EARN_REJ_INFO');
     fnd_message.set_token('OFFR_EARN_REQ', l_offer_req, false);
  ELSE
     fnd_message.set_name('OZF', 'OZF_CLAIM_NTF_REJECTED_INFO');
  END IF;
  fnd_message.set_token('CURRENCY_CODE', l_currency, false);
  fnd_message.set_token('AMOUNT', l_amount_settled, false);
  fnd_message.set_token('APPROVER_NAME', l_approver, false);
  fnd_message.set_token('DATE', TO_CHAR(SYSDATE, 'MM-DD-YYYY'), false);
  fnd_message.set_token('TIME', TO_CHAR(SYSDATE, 'HH24:MI'), false);
  fnd_message.set_token('CLAIM_NUMBER', l_claim_number, false);
  fnd_message.set_token('CLAIM_TYPE', l_claim_type, false);
  fnd_message.set_token('CLAIM_DATE', l_claim_date, false);
  fnd_message.set_token('DUE_DATE', l_due_date, false);
  fnd_message.set_token('CUSTOMER_NAME', l_account_name, false);
  fnd_message.set_token('CUST_ACCT_NUMBER', l_account_number, false);
  fnd_message.set_token('BILL_TO_SITE', l_billto_site, false);
  fnd_message.set_token('CM_REASON', l_cm_reason, false);
  fnd_message.set_token('ADJ_REASON', l_adj_reason, false);
  fnd_message.set_token('SETTLEMENT_METHOD', l_payment_method, false);
  fnd_message.set_token('JUSTIFICATION_NOTES', '', false);
  fnd_message.set_token('COMMENTS_NOTES', l_note, false);
  --  l_string1 := Substr(FND_MESSAGE.Get,1,2500);
  l_body := fnd_message.get;
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
  -- l_rej_notification := l_subject || FND_GLOBAL.LOCAL_CHR(10) || l_body;
  l_rej_notification := l_body;
  document := document || l_rej_notification;
  document_type := 'text/plain';
  RETURN;
  --  END IF;

  /*
  IF (display_type = 'text/html') THEN
    l_appreq_notification := l_string ||
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
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'NOTIFY_REQUESTOR_OF_REJECTION'
                    , l_item_type
                    , l_item_key
                    );
     RAISE;
END notify_requestor_of_rejection;


---------------------------------------------------------------------
-- PROCEDURE
--   Set_claim_Activity_details
--
-- PURPOSE
--   This Procedure will set all the item attribute details
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   04/25/2001     Prashanth Nerella      CREATION
--   05/30/2001     MICHELLE CHANG         MODIFIED
-------------------------------------------------------------------------------
PROCEDURE set_claim_activity_details(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)
IS
  l_activity_id           NUMBER;
  l_activity_type         VARCHAR2(30)    := 'CLAM';
  l_approval_type         VARCHAR2(30)    := 'CLAIM';
  l_object_details        AMS_GEN_APPROVAL_PVT.objrectyp;
  l_approval_detail_id    NUMBER;
  l_approver_seq          NUMBER;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_error_msg             VARCHAR2(4000);
  l_orig_stat_id          NUMBER;
  x_resource_id           NUMBER;
  l_full_name             VARCHAR2(60);

  --l_approval_type       VARCHAR2(30);
  l_approver              VARCHAR2(200);
  l_note                  VARCHAR2(3000);
  l_subject               VARCHAR2(500);
  l_requester             VARCHAR2(30);
  l_requested_amt         NUMBER;
  l_approved_amt          NUMBER;

  l_claim_id              NUMBER;
  l_claim_number          VARCHAR2(30);
  l_account_number        VARCHAR2(30);
  l_account_name          VARCHAR2(360);
  l_currency              VARCHAR2(80);
  l_amount_settled        NUMBER;
  l_claim_date            DATE;
  l_due_date              DATE;
  l_claim_type            VARCHAR2(30);
  l_billto_site           VARCHAR2(40);
  l_cm_reason             VARCHAR2(80);
  l_adj_reason            VARCHAR2(80);
  l_payment_method        VARCHAR2(80);
  l_claim_source          VARCHAR2(30);
  l_comments              VARCHAR2(2000);
  l_object_meaning        VARCHAR2(240);
  l_requester_id          NUMBER;

  CURSOR c_claim_obj(p_act_id IN NUMBER) IS
    SELECT   claim_number
    ,        custom_setup_id
    ,        amount_settled
    ,        org_id
    ,        to_char(claim_type_id)   -- 'CLAM' changed by slkrishn
    ,        to_char(reason_code_id)  -- added by slkrishn for reason(priority)
    ,        claim_date
    ,        due_date
    ,        owner_id
    ,        currency_code
    FROM ozf_claims_all
    WHERE claim_id = p_act_id;

  CURSOR c_claim_rec(p_claim_id IN NUMBER) IS
    SELECT c.claim_number
    ,      a.account_number
    ,      hp.party_name
    ,      curr.name
    ,      c.amount_settled
    ,      c.claim_date
    ,      c.due_date
    ,      ct.name
    ,      hc.location
    ,      rlk_cm.meaning
    ,      rlk_adj.meaning
    ,      lk_pm.meaning
    ,      'resource_name'
    ,      c.comments
    FROM ozf_claims_all c
    ,    hz_cust_accounts a
    ,    hz_parties hp
    ,    ozf_claim_types_all_vl ct
    ,    hz_cust_site_uses_all hc
    ,    ozf_reason_codes_all_b rc
    ,    ar_lookups rlk_cm
    ,    ar_lookups rlk_adj
    ,    ozf_lookups lk_pm
    ,    fnd_currencies_vl curr
    WHERE c.claim_id = p_claim_id
    AND c.cust_account_id = a.cust_account_id
    AND a.party_id = hp.party_id
    AND c.currency_code = curr.currency_code
    AND c.claim_type_id = ct.claim_type_id
    AND c.cust_billto_acct_site_id = hc.site_use_id(+)
    AND c.reason_code_id = rc.reason_code_id
    AND c.payment_method = lk_pm.lookup_code
    /* [BEGIN OF FIXING BUG2474662 22-JUL-2002]: overpayment is not been selected. */
    --AND lk_pm.lookup_type = decode(c.claim_class, 'CLAIM', 'OZF_CLAIM_PAYMENT_METHOD', 'OZF_DEDUCTION_PAYMENT_METHOD');
    AND lk_pm.lookup_type = 'OZF_PAYMENT_METHOD'
    /* [END OF FIXING BUG2474662] */
    AND rc.reason_code = rlk_cm.lookup_code(+)
    AND rlk_cm.lookup_type(+) = 'CREDIT_MEMO_REASON'
    AND rc.adjustment_reason_code = rlk_adj.lookup_code(+)
    AND rlk_adj.lookup_type(+) = 'ADJUST_REASON';

BEGIN
  FND_MSG_PUB.initialize;

  l_activity_id := WF_ENGINE.getitemattrnumber(
                      itemtype => itemtype
                     ,itemkey  => itemkey
                     ,aname    => 'AMS_ACTIVITY_ID'
                   );

  l_approval_type := wf_engine.GetItemAttrText(
                            itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'AMS_APPROVAL_TYPE'
                        );

  l_requester_id := wf_engine.getitemattrnumber(
                            itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'AMS_REQUESTER_ID'
                        );




  OPEN c_claim_obj(l_activity_id);
  FETCH c_claim_obj INTO l_object_details.name
                       , l_object_details.setup_type_id
                       , l_object_details.total_header_amount
                       , l_object_details.org_id
                       , l_object_details.object_type
                       , l_object_details.priority
                       , l_object_details.start_date
                       , l_object_details.end_date
                       , l_object_details.owner_id
                       , l_object_details.currency;
  CLOSE c_claim_obj;

  IF (funcmode = 'RUN') THEN
      BEGIN
          UPDATE ozf_claims_all
          SET appr_wf_item_key = itemkey
          WHERE claim_id = l_activity_id;

	  IF ( l_approval_type = 'CLAIM' ) THEN
	     make_history_data (
               p_activity_id    => l_activity_id,
               p_requester_id   => l_requester_id,
               x_return_status      => l_return_status
	     );

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN
	      RAISE FND_API.g_exc_unexpected_error;
	   END IF;
	 END IF;

      EXCEPTION
          WHEN OTHERS THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_UPD_CLAM_ERR');
               FND_MSG_PUB.add;
            END IF;
            IF OZF_DEBUG_LOW_ON THEN
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',sqlerrm);
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
      END;

     AMS_GEN_APPROVAL_PVT.get_approval_details(
        p_activity_id        => l_activity_id
       ,p_activity_type      => l_activity_type
       ,p_approval_type      => l_approval_type
       ,p_object_details     => l_object_details
       ,x_approval_detail_id => l_approval_detail_id
       ,x_approver_seq       => l_approver_seq
       ,x_return_status      => l_return_status
     );

     IF l_return_status = fnd_api.g_ret_sts_success THEN
        WF_ENGINE.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_APPROVAL_DETAIL_ID'
          ,avalue   => l_approval_detail_id
        );
        WF_ENGINE.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_APPROVER_SEQ'
          ,avalue   => l_approver_seq
        );
        WF_ENGINE.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_REQUESTED_AMOUNT'
          ,avalue   => l_object_details.total_header_amount
        );

       -- [BEGIN OF FIX BUG2352621 07/03/2002]
       WF_ENGINE.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'AMS_APPROVAL_OBJECT_NAME'
         ,avalue   => l_object_details.name
       );

       l_object_meaning := OZF_UTILITY_PVT.get_lookup_meaning('AMS_SYS_ARC_QUALIFIER', 'CLAM');

       WF_ENGINE.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'AMS_APPROVAL_OBJECT_MEANING'
         ,avalue   => l_object_meaning
       );
       -- [END OF FIX BUG2352621 07/03/2002]

       -- set all subjects
       OPEN c_claim_rec(l_activity_id);
       FETCH c_claim_rec INTO l_claim_number
                       , l_account_number
                       , l_account_name
                       , l_currency
                       , l_amount_settled
                       , l_claim_date
                       , l_due_date
                       , l_claim_type
                       , l_billto_site
                       , l_cm_reason
                       , l_adj_reason
                       , l_payment_method
                       , l_claim_source
                       , l_comments;
       CLOSE c_claim_rec;

       WF_ENGINE.setitemattrtext(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'AMS_NOTES_FROM_REQUESTOR'
          ,avalue   => l_comments
       );

-- Start Bug fix for 8656583
         WF_ENGINE.setitemattrtext(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'APPROVAL_NOTE'
          ,avalue   => l_comments
       );
-- End Bug fix for 8656583

       IF l_approval_type = 'PERFORMANCE' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_PERF_FORD_SUBJ');
       ELSIF l_approval_type = 'EARNING' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_EARN_FORD_SUBJ');
       ELSE
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_FORWARD_SUBJ');
          FND_MESSAGE.set_token('CURRENCY_CODE', l_currency, false);
          FND_MESSAGE.set_token('AMOUNT', l_amount_settled, false);
       END IF;
       FND_MESSAGE.set_token('CLAIM_NUMBER', l_claim_number, false);
       --fnd_message.set_token('APPROVER', l_approver, false);
       l_subject := FND_MESSAGE.get;

       WF_ENGINE.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'FYI_SUBJECT'
         ,avalue   => l_subject
       );

       IF l_approval_type = 'PERFORMANCE' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPR_SUBJ');
       ELSIF l_approval_type = 'EARNING' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPR_SUBJ');
       ELSE
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_APPROVAL_SUBJ');
          FND_MESSAGE.set_token('CURRENCY_CODE', l_currency, false);
          FND_MESSAGE.set_token('AMOUNT', l_amount_settled, false);
       END IF;
       FND_MESSAGE.set_token('CLAIM_NUMBER', l_claim_number, false);
       -- l_string := Substr(FND_MESSAGE.Get,1,2500);
       l_subject := fnd_message.get;

       WF_ENGINE.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'APP_SUBJECT'
         ,avalue   => l_subject
       );

       IF l_approval_type = 'PERFORMANCE' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_PERF_APPRD_SUBJ');
       ELSIF l_approval_type = 'EARNING' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_EARN_APPRD_SUBJ');
       ELSE
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_APPROVED_SUBJ');
          FND_MESSAGE.set_token('CURRENCY_CODE', l_currency, false);
          FND_MESSAGE.set_token('AMOUNT', l_amount_settled, false);
       END IF;
       FND_MESSAGE.set_token('CLAIM_NUMBER', l_claim_number, false);
       --fnd_message.set_token('APPROVER', l_approver, false);
       -- l_string := Substr(FND_MESSAGE.Get,1,2500);
       l_subject := FND_MESSAGE.get;

       WF_ENGINE.setitemattrtext(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'APRV_SUBJECT'
          ,avalue   => l_subject
       );

       IF l_approval_type = 'PERFORMANCE' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_PERF_REJ_SUBJ');
       ELSIF l_approval_type = 'EARNING' THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_EARN_REJ_SUBJ');
       ELSE
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NTF_REJECTED_SUBJ');
          FND_MESSAGE.set_token('CURRENCY_CODE', l_currency, false);
          FND_MESSAGE.set_token('AMOUNT', l_amount_settled, false);
       END IF;
       FND_MESSAGE.set_token('CLAIM_NUMBER', l_claim_number, false);
       --fnd_message.set_token('APPROVER', l_approver, false);
       -- l_string := Substr(FND_MESSAGE.Get,1,2500);
       l_subject := FND_MESSAGE.get;

       WF_ENGINE.setitemattrtext(
          itemtype => itemtype
         ,itemkey  => itemkey
         ,aname    => 'REJECT_SUBJECT'
         ,avalue   => l_subject
       );

       resultout := 'COMPLETE:SUCCESS';
     ELSE
        FND_MSG_PUB.count_and_get(
           p_encoded   => fnd_api.g_false
          ,p_count     => l_msg_count
          ,p_data      => l_msg_data
        );

        AMS_GEN_APPROVAL_PVT.handle_err(
           p_itemtype  => itemtype
          ,p_itemkey   => itemkey
          ,p_msg_count => l_msg_count
          ,p_msg_data  => l_msg_data
          ,p_attr_name => 'AMS_ERROR_MSG'
          ,x_error_msg => l_error_msg
        );

        WF_CORE.context(
           'OZF_CLAIM_APPROVAL_PVT'
          ,'SET_CLAIM_ACTIVITY_DETAILS'
          ,itemtype
          ,itemkey
          ,actid
          ,l_error_msg
        );
        -- RAISE FND_API.G_EXC_ERROR;
        resultout := 'COMPLETE:ERROR';
     END IF;
     RETURN;
  END IF; -- end of RUN mode

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
     WF_CORE.context(
        'OZF_CLAIM_APPROVAL_PVT'
       ,'SET_CLAIM_ACTIVITY_DETAILS'
       ,itemtype
       ,itemkey
       ,actid
       ,funcmode
       ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;
     --RAISE;
  WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',sqlerrm);
     FND_MSG_PUB.Add;

     FND_MSG_PUB.count_and_get (
         p_encoded   => fnd_api.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     AMS_GEN_APPROVAL_PVT.handle_err(
         p_itemtype  => itemtype
        ,p_itemkey   => itemkey
        ,p_msg_count => l_msg_count
        ,p_msg_data  => l_msg_data
        ,p_attr_name => 'AMS_ERROR_MSG'
        ,x_error_msg => l_error_msg
     );
     WF_CORE.context(
         'AMS_GEN_APPROVAL_PVT'
        ,'SET_CLAIM_ACTIVITY_DETAILS'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;
     --RAISE;
  END set_claim_activity_details;



---------------------------------------------------------------------
-- PROCEDURE
--   Start_Approval_Process
--
-- PURPOSE
--   This Procedure will initiate ams gen apporval for earnings and performance.
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   NOV-24-2003   MCHANG     CREATION
-------------------------------------------------------------------------------
PROCEDURE Start_Approval_Process(
   p_claim_id           IN  NUMBER
  ,p_orig_status_id     IN  NUMBER
  ,p_new_status_id      IN  NUMBER
  ,p_reject_status_id   IN  NUMBER
  ,p_approval_type      IN  VARCHAR2
  ,x_return_status      OUT NOCOPY VARCHAR2
) IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Start_Approval_Process';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
---
l_object_version_number    NUMBER;
l_owner_id                 NUMBER;
l_comments                 VARCHAR2(2000);

CURSOR claim_rec_csr(l_claim_id in number) IS
 SELECT object_version_number
 --,      user_status_id
 ,      owner_id
 ,      comments
 FROM   ozf_claims_all --//Bugfix : 8442938 - Changed table name from ozf_claims to ozf_claims_all
 WHERE  claim_id = l_claim_id;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OPEN claim_rec_csr(p_claim_id);
   FETCH claim_rec_csr INTO l_object_version_number,
                            --l_new_status_id,
                            l_owner_id,
                            l_comments;
   CLOSE claim_rec_csr;

   l_object_version_number := l_object_version_number + 1;

BEGIN
          UPDATE ozf_claims_all
          SET OBJECT_VERSION_NUMBER = l_object_version_number
          WHERE claim_id = p_claim_id;
      EXCEPTION
          WHEN OTHERS THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_UPD_CLAM_ERR');
               FND_MSG_PUB.add;
            END IF;
            IF OZF_DEBUG_LOW_ON THEN
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',sqlerrm);
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
      END;

   ----------------------------
   -- Call Approval Workflow --
   ----------------------------
   -- the approval API would  start claim approval process
   AMS_GEN_APPROVAL_PVT.StartProcess(
      p_activity_type         => 'CLAM'
     ,p_activity_id           => p_claim_id
     ,p_approval_type         => p_approval_type
     ,p_object_version_number => l_object_version_number
     ,p_orig_stat_id          => p_orig_status_id
     ,p_new_stat_id           => p_new_status_id
     ,p_reject_stat_id        => p_reject_status_id
     ,p_requester_userid      => l_owner_id
     ,p_notes_from_requester  => l_comments
     ,p_workflowprocess       => 'AMSGAPP'
     ,p_item_type             => 'AMSGAPP'
   );

EXCEPTION
   WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||' - '||p_approval_type||' : Error');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Start_Approval_Process;


---------------------------------------------------------------------
-- PROCEDURE
--   update_claim_status
--
-- PURPOSE
--   This Procedure will update the status
--
-- IN
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
-- HISTORY
--   04/25/2001    Prashanth Nerella       CREATION
--   05/30/2001    MICHELLE CHANG          MODIFIED
-------------------------------------------------------------------------------
PROCEDURE update_claim_status(
   itemtype    IN       VARCHAR2
  ,itemkey     IN       VARCHAR2
  ,actid       IN       NUMBER
  ,funcmode    IN       VARCHAR2
  ,resultout   OUT NOCOPY      VARCHAR2
)
IS
l_api_version     CONSTANT NUMBER            := 1.0;
l_api_name        CONSTANT VARCHAR2(30)      := 'Update_Claim_Status';
l_full_name       CONSTANT VARCHAR2(60)      := g_pkg_name || '.' || l_api_name;
l_return_status            VARCHAR2(1)       := fnd_api.g_ret_sts_success;
l_msg_count                NUMBER;
l_msg_data                 VARCHAR2(4000);
l_error_msg                VARCHAR2(4000);

l_claim_rec                ozf_claim_pvt.claim_rec_type;
l_status_code              VARCHAR2(30);
l_next_status_id           NUMBER;
l_new_status_id            NUMBER;
l_orig_status_id           NUMBER;
l_reject_status_id         NUMBER;
l_approved_amount          NUMBER;
l_update_status            VARCHAR2(12);
l_object_version_number    NUMBER;
l_org_id                   NUMBER;
l_claim_id                 NUMBER;
l_approver_id              NUMBER;
l_claim_amount_settled     NUMBER;

l_user_id                  NUMBER;
l_resp_id                  NUMBER;
l_appl_id                  NUMBER;
l_security_group_id        NUMBER;
l_approver_role_name       VARCHAR2(30);
APPROVAL_RAISE_ERROR       EXCEPTION;
l_approval_type            VARCHAR2(30);
l_payment_method           VARCHAR2(30);
l_approval_require         VARCHAR2(1);

CURSOR csr_claim_obj_ver(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_get_claim_amount (cv_claim_id IN NUMBER) IS
  SELECT amount_settled
  , payment_method
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;


BEGIN
  -- [BEGIN OF BUG2631497 FIXING by mchang 23-OCT-2002]
  -- mchang: initialized PL/SQL security context since workflow mailer desn't establish those value.
  l_user_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'USER_ID'
                                          );

  l_resp_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'RESPONSIBILITY_ID'
                                          );

  l_appl_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                          , itemkey  => itemkey
                                          , aname    => 'APPLICATION_ID'
                                          );

  l_security_group_id := WF_ENGINE.getitemattrnumber( itemtype => itemtype
                                                    , itemkey  => itemkey
                                                    , aname    => 'SECURITY_GROUP_ID'
                                                    );

  -- [END OF BUG2631497 FIXING by mchang 23-OCT-2002]

  IF funcmode = 'RUN' THEN
     l_update_status := wf_engine.getitemattrtext(
                           itemtype => itemtype
                          ,itemkey  => itemkey
                          ,aname    => 'UPDATE_GEN_STATUS'
                        );

     IF l_update_status IN ('APPROVED', 'REJECTED') AND
        (l_user_id IS NULL OR l_resp_id IS NULL OR l_appl_id IS NULL) THEN
        l_update_status := NULL;
        WF_ENGINE.setitemattrnumber(
           itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'UPDATE_GEN_STATUS'
          ,avalue   => l_update_status
        );
        FND_MSG_PUB.count_and_get (
            p_encoded   => fnd_api.g_false
           ,p_count     => l_msg_count
           ,p_data      => l_msg_data
        );
        AMS_GEN_APPROVAL_PVT.handle_err(
            p_itemtype  => itemtype
           ,p_itemkey   => itemkey
           ,p_msg_count => l_msg_count
           ,p_msg_data  => l_msg_data
           ,p_attr_name => 'AMS_ERROR_MSG'
           ,x_error_msg => l_error_msg
        );
        WF_CORE.context(
            'OZF_CLAIM_APPROVAL_PVT'
           ,'UPDATE_CLAIM_STATUS'
           ,itemtype
           ,itemkey
           ,actid
           ,l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RETURN;
     ELSIF l_update_status IN ('APPROVED', 'REJECTED') THEN
        FND_GLOBAL.apps_initialize( user_id           => l_user_id
                                  , resp_id           => l_resp_id
                                  , resp_appl_id      => l_appl_id
                                  --, security_group_id => l_security_group_id
                                  );
     END IF;

     l_claim_id := wf_engine.getitemattrnumber(
                     itemtype => itemtype
                    ,itemkey  => itemkey
                    ,aname    => 'AMS_ACTIVITY_ID'
                   );

     l_approval_type := wf_engine.GetItemAttrText(
                            itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'AMS_APPROVAL_TYPE'
                        );

     l_new_status_id := wf_engine.getitemattrnumber(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'AMS_NEW_STAT_ID'
                         );

     l_orig_status_id := wf_engine.getitemattrnumber(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'AMS_ORIG_STAT_ID'
                         );

     l_reject_status_id := wf_engine.getitemattrnumber(
                               itemtype => itemtype
                              ,itemkey  => itemkey
                              ,aname    => 'AMS_REJECT_STAT_ID'
                         );

     IF l_update_status = 'APPROVED' AND
        l_approval_type = 'EARNING' THEN
        IF OZF_Claim_Accrual_PVT.Perform_Approval_Required(l_claim_id) = FND_API.g_true THEN
           -- Start Performance Approval
           Start_Approval_Process(
               p_claim_id           => l_claim_id
              ,p_orig_status_id     => l_orig_status_id
              ,p_new_status_id      => l_new_status_id
              ,p_reject_status_id   => l_reject_status_id
              ,p_approval_type      => 'PERFORMANCE'
              ,x_return_status      => l_return_status
           );
           IF l_return_status = FND_API.g_ret_sts_success THEN
              resultout := 'COMPLETE:SUCCESS';
	      RETURN;
           ELSE
              RAISE APPROVAL_RAISE_ERROR;
           END IF;
        ELSE
           OZF_CLAIM_SETTLEMENT_PVT.Claim_Approval_Required(p_claim_id => l_claim_id
                                  ,x_return_status => l_return_status
                                  ,x_msg_data      => l_msg_data
                                  ,x_msg_count     => l_msg_count
                                  ,x_approval_require => l_approval_require);

           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

           IF l_approval_require = 'Y' THEN
	       -- Start Performance Approval
               Start_Approval_Process(
                   p_claim_id      => l_claim_id
                  ,p_orig_status_id     => l_orig_status_id
                  ,p_new_status_id      => l_new_status_id
                  ,p_reject_status_id   => l_reject_status_id
                  ,p_approval_type => 'CLAIM'
                  ,x_return_status => l_return_status
               );


                IF l_return_status = FND_API.g_ret_sts_success THEN
                  resultout := 'COMPLETE:SUCCESS';
                  RETURN;
               ELSE
                  RAISE APPROVAL_RAISE_ERROR;
               END IF;
            END IF;
        END IF;
     ELSIF l_update_status = 'APPROVED' AND
           l_approval_type = 'PERFORMANCE' THEN
        -- Start Performance Approval
           OZF_CLAIM_SETTLEMENT_PVT.Claim_Approval_Required(p_claim_id => l_claim_id
                                  ,x_return_status => l_return_status
                                  ,x_msg_data      => l_msg_data
                                  ,x_msg_count     => l_msg_count
                                  ,x_approval_require => l_approval_require);

           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

	   IF l_approval_require = 'Y' THEN
	       -- Start Performance Approval
               Start_Approval_Process(
                   p_claim_id      => l_claim_id
                  ,p_orig_status_id     => l_orig_status_id
                  ,p_new_status_id      => l_new_status_id
                  ,p_reject_status_id   => l_reject_status_id
                  ,p_approval_type => 'CLAIM'
                  ,x_return_status => l_return_status
               );


                IF l_return_status = FND_API.g_ret_sts_success THEN
                  resultout := 'COMPLETE:SUCCESS';
                  RETURN;
               ELSE
                  RAISE APPROVAL_RAISE_ERROR;
               END IF;
            END IF;
     END IF;



     l_approved_amount := wf_engine.getitemattrnumber(
                            itemtype => itemtype
                           ,itemkey  => itemkey
                           ,aname    => 'AMS_AMOUNT'
                          );

     l_object_version_number := wf_engine.getitemattrnumber(
                                   itemtype => itemtype
                                  ,itemkey => itemkey
                                  ,aname => 'AMS_OBJECT_VERSION_NUMBER'
                                );


     -- get claims org_id
     l_org_id := find_org_id (l_claim_id);

     -- set org_context since workflow mailer does not set the context
     set_org_ctx (l_org_id);

     l_approver_id :=wf_engine.getitemattrnumber(
                       itemtype => itemtype
                      ,itemkey  => itemkey
                      ,aname    => 'AMS_APPROVER_ID'
                     );

     OPEN  csr_get_claim_amount (l_claim_id);
     FETCH csr_get_claim_amount INTO l_claim_amount_settled
                                   , l_payment_method;
     CLOSE csr_get_claim_amount;

     IF l_approved_amount <> l_claim_amount_settled AND
        l_payment_method <> 'MASS_SETTLEMENT' THEN
       IF l_update_status IN ('APPROVED', 'REJECTED') THEN
         --set message.
         FND_MESSAGE.Set_Name('AMS','AMS_WF_NTF_AMOUNT_CHANGE_FYI');
         FND_MESSAGE.set_token('APPROVED_AMOUNT',l_approved_amount, FALSE);
         FND_MESSAGE.set_token('CLAIM_AMOUNT',l_claim_amount_settled, FALSE);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.count_and_get (
            p_encoded   => fnd_api.g_false
           ,p_count     => l_msg_count
           ,p_data      => l_msg_data
           );
         AMS_GEN_APPROVAL_PVT.handle_err(
            p_itemtype  => itemtype
           ,p_itemkey   => itemkey
           ,p_msg_count => l_msg_count
           ,p_msg_data  => l_msg_data
           ,p_attr_name => 'AMS_ERROR_MSG'
           ,x_error_msg => l_error_msg
           );
         WF_CORE.context(
            'AMS_GEN_APPROVAL_PVT'
           ,'Set_Activity_Details'
           ,itemtype
           ,itemkey
           ,actid
           ,l_error_msg
           );
         resultout := 'COMPLETE:ERROR';
         --999
         --Set performer of the next notification to original claim approver.
         l_approver_role_name := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                          ,itemkey  => itemkey
                                                          ,aname    => 'AMS_APPROVER'
                                                          );

         WF_ENGINE.AssignActivity(itemtype  => itemtype
                                 ,itemkey   => itemkey
                                 ,activity  => 'AMSGAPP:AMS_NTF_ERROR_REQUEST'
                                 ,performer => l_approver_role_name
                                  );


         /*
         WF_ENGINE.AssignActivity(itemtype  => itemtype
                                 ,itemkey   => itemkey
                                 ,activity  => 'AMSGAPP:AMS_NTF_ERROR_REQUEST'
                                 ,performer => 'AMS_APPROVER'
                                  );
         */

       ELSE
         resultout := 'COMPLETE:';
       END IF;
       RETURN;
     END IF;

     IF l_update_status = 'APPROVED' THEN
        l_next_status_id := l_new_status_id;

        l_claim_rec.approved_by := l_approver_id;
        l_claim_rec.approved_date := SYSDATE;
        l_claim_rec.object_version_number := l_object_version_number ;

        IF OZF_DEBUG_HIGH_ON THEN
           ozf_utility_pvt.debug_message(l_full_name ||': update_status = ' || l_update_status);
        END IF;

     ELSIF l_update_status = 'REJECTED' THEN
        l_next_status_id := l_reject_status_id;

        l_claim_rec.object_version_number := l_object_version_number ;

     ELSE
        l_next_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                 'OZF_CLAIM_STATUS'
                                ,'OPEN'
                            );

        OPEN csr_claim_obj_ver(l_claim_id);
        FETCH csr_claim_obj_ver INTO l_claim_rec.object_version_number;
        CLOSE csr_claim_obj_ver;

     END IF;

     l_status_code := ozf_utility_pvt.get_system_status_code(l_next_status_id);
     l_claim_rec.claim_id := l_claim_id;
     l_claim_rec.user_status_id := l_next_status_id;

     IF OZF_DEBUG_HIGH_ON THEN
        ozf_utility_pvt.debug_message(l_full_name || l_status_code || l_approved_amount || l_update_status);
     END IF;

     IF l_payment_method = 'MASS_SETTLEMENT' THEN
        IF l_update_status = 'APPROVED' THEN

          OZF_MASS_SETTLEMENT_PVT.Start_Mass_Payment(
             p_group_claim_id    => l_claim_rec.claim_id,
             x_return_status     => l_return_status,
             x_msg_data          => l_msg_data,
             x_msg_count         => l_msg_count
          );

        ELSE

          OZF_MASS_SETTLEMENT_PVT.Reject_Mass_Payment(
             p_group_claim_id    => l_claim_rec.claim_id,
             x_return_status     => l_return_status,
             x_msg_data          => l_msg_data,
             x_msg_count         => l_msg_count
          );

        END IF;

     ELSE
         OZF_Claim_PVT.Update_Claim(
           p_api_version           => l_api_version
           ,p_init_msg_list         => FND_API.g_false
           ,p_commit                => FND_API.g_false
           ,p_validation_level      => FND_API.g_valid_level_full
           ,x_return_status         => l_return_status
           ,x_msg_data              => l_msg_data
           ,x_msg_count             => l_msg_count
           ,p_claim                 => l_claim_rec
           ,p_event                 => 'UPDATE'
           ,p_mode                  => 'AUTO'
           ,x_object_version_number => l_object_version_number
         );
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_success THEN
        resultout := 'COMPLETE:SUCCESS';
     ELSE
        FND_MSG_PUB.count_and_get (
            p_encoded   => fnd_api.g_false
           ,p_count     => l_msg_count
           ,p_data      => l_msg_data
        );
        AMS_GEN_APPROVAL_PVT.handle_err(
            p_itemtype  => itemtype
           ,p_itemkey   => itemkey
           ,p_msg_count => l_msg_count
           ,p_msg_data  => l_msg_data
           ,p_attr_name => 'AMS_ERROR_MSG'
           ,x_error_msg => l_error_msg
        );
        WF_CORE.context(
            'OZF_CLAIM_APPROVAL_PVT'
           ,'UPDATE_CLAIM_STATUS'
           ,itemtype
           ,itemkey
           ,actid
           ,l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
     END IF;
     RETURN;
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
    ,p_count   => l_msg_count
    ,p_data    => l_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message(l_full_name || ': l_return_status' || l_return_status);
  END IF;

EXCEPTION
  WHEN APPROVAL_RAISE_ERROR THEN
     wf_core.context( 'OZF_CLAIM_APPROVAL_PVT'
                    , 'Start_Approval_Process'
                    , itemtype
                    , itemkey
                    );
     RAISE;

  WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',sqlerrm);
     FND_MSG_PUB.Add;

     fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false
       ,p_count   => l_msg_count
       ,p_data    => l_msg_data
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;
END update_claim_status;



END OZF_Claim_Approval_PVT;

/
