--------------------------------------------------------
--  DDL for Package Body OZF_AR_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AR_SETTLEMENT_PVT" AS
/* $Header: ozfvcapb.pls 120.11.12010000.4 2010/03/22 04:56:38 kpatro ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_AR_SETTLEMENT_PVT';
G_ITEMTYPE CONSTANT varchar2(30) := 'OZF_CSTL';
ERROR      EXCEPTION;

--------------------------------------------------------------------------
PROCEDURE set_org_context(p_item_type   IN VARCHAR2,
                                      p_item_key    IN VARCHAR2,
                                      p_activity_id IN VARCHAR2,
                                      p_command     IN VARCHAR2,
                          p_resultout   IN OUT NOCOPY VARCHAR2)
IS

CURSOR csr_claim IS
  SELECT org_id
  FROM   ozf_claims_all
  WHERE  cstl_wf_item_key = p_item_key;

l_org_id           NUMBER;

BEGIN

   OPEN csr_claim;
   FETCH csr_claim INTO l_org_id;
   CLOSE csr_claim;

   IF p_command = 'SET_CTX' THEN
     mo_global.init('OZF');
     mo_global.set_policy_context( p_access_mode => 'S',   p_org_id => l_org_id);
     RETURN;
  END IF;

  IF p_command = 'TEST_CTX' THEN
    IF (NVL(mo_global.get_access_mode,'NULL') <> 'S') OR
       (NVL(mo_global.get_current_org_id,-99) <> l_org_id)
    THEN
      p_resultout := 'FALSE';
      RETURN;
    ELSE
      p_resultout := 'TRUE';
      RETURN;
    END IF;
 END IF;

EXCEPTION
WHEN OTHERS THEN
   WF_CORE.CONTEXT ('OZF_AR_SETTLEMENT_PVT',
                    'set_org_context',
                     p_item_type,
                     p_item_key,
                     p_activity_id,
                     p_command);
   RAISE;
END set_org_context;

---------------------------------------------------------------------------------
-- PROCEDURE
--   Get_User_Role
--
-- PURPOSE
--   This Procedure will be return the User role for the userid sent Called By
--
-- NOTES
--
---------------------------------------------------------------------------------
PROCEDURE Get_User_Role(
    p_user_id               IN      NUMBER,
    x_role_name             OUT NOCOPY     VARCHAR2,
    x_role_display_name     OUT NOCOPY     VARCHAR2
)
IS
-- Bug4904064: Replaced view jtf_rs_res_emp_vl with direct tables
-- Modified for Bugfix 5199354, to reduce shared memory usage further
CURSOR c_resource IS
  select  ppl.person_id employee_id
  from jtf_rs_resource_extns rsc , per_people_f ppl
  where rsc.category = 'EMPLOYEE' and ppl.person_id = rsc.source_id
  and trunc(sysdate) between ppl.effective_start_date and ppl.effective_end_date
  and rsc.resource_id = p_user_id;

l_person_id        NUMBER;

BEGIN
  OPEN c_resource ;
  FETCH c_resource INTO l_person_id ;
  IF c_resource%NOTFOUND THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT', sqlerrm );
    FND_MSG_PUB.Add;
  END IF;
  CLOSE c_resource ;
    -- Pass the Employee ID to get the Role
    WF_DIRECTORY.getrolename(
         p_orig_system       => 'PER',
         p_orig_system_id    => l_person_id ,
         p_name              => x_role_name,
         p_display_name      => x_role_display_name
    );
END Get_User_Role;


--------------------------------------------------------------------------------
-- PROCEDURE
--   Set_Reminder
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_SET_REMINDER
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--------------------------------------------------------------------------------
PROCEDURE Set_Reminder(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Set_Reminder',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Set_Reminder;


--------------------------------------------------------------------------------
-- PROCEDURE
--   Incomplete_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_INCOMPLETE_CLAIM
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--------------------------------------------------------------------------------
PROCEDURE Incomplete_Claim(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(400);
l_msg_count        NUMBER;

CURSOR csr_claim_version(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      status_code
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

l_claim_id         NUMBER;
l_object_version   NUMBER;
l_org_id           NUMBER;
l_status_code      VARCHAR2(30);
l_user_status_id   NUMBER;
l_claim_rec        OZF_CLAIM_PVT.claim_rec_type;
l_error_msg VARCHAR2(4000);

BEGIN
  SAVEPOINT Inccmplete_Claim;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    OPEN csr_claim_version(l_claim_id);
    FETCH csr_claim_version INTO l_object_version
                               , l_status_code
                               , l_org_id;
    CLOSE csr_claim_version;

    -- set org_context since workflow mailer does not set the context
    --Set_Org_Ctx (l_org_id);

    l_claim_rec.claim_id := l_claim_id;
    l_claim_rec.object_version_number := l_object_version;
    l_claim_rec.payment_status := 'INCOMPLETE';

    OZF_CLAIM_PVT.Update_Claim (
          p_api_version            => 1.0
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full

         ,x_return_status          => l_return_status
         ,x_msg_data               => l_msg_data
         ,x_msg_count              => l_msg_count
         ,p_claim                  => l_claim_rec
         ,p_event                  => 'UPDATE'
         ,p_mode                   => 'AUTO'
         ,x_object_version_number  => l_object_version
      );
    IF l_return_status <> FND_API.g_ret_sts_success THEN
       RAISE ERROR;
    END IF;

    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     ROLLBACK TO Inccmplete_Claim;
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'Incomplete_Creation'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'Incomplete_Creation'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     RAISE;
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Incomplete_Creation',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Incomplete_Claim;


--------------------------------------------------------------------------------
-- PROCEDURE
--   Prepare_Instructions
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>               <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_RECEIVABLE_INSTRUCTION
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--   10/30/2001  MCHNAG  Hand 'CANCELLED' and 'REJECTED' deduction :
--                       get OZF_NEXT_STATUS, if it's other then 'CLOSED', return 'N'.
--------------------------------------------------------------------------------
PROCEDURE Prepare_Instructions(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS

l_next_status            VARCHAR2(30);

l_return_status          VARCHAR2(1);
l_msg_data               VARCHAR2(4000);
l_msg_count              NUMBER;

l_claim_id               NUMBER;
l_root_claim_id          NUMBER;
l_payment_method         VARCHAR2(30);
l_inv_org_id             NUMBER;
l_vendor_id              NUMBER;
l_vendor_site_id         NUMBER;
l_vendor_name            VARCHAR2(80);
l_vendor_site            VARCHAR2(15);
l_vendor_info_str        VARCHAR2(200)   := NULL;

CURSOR csr_claim(cv_claim_id IN NUMBER) IS
  SELECT root_claim_id
  ,      payment_method
  ,      vendor_id
  ,      vendor_site_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

/* == Stuff used for Getting Split info ==== */

CURSOR csr_is_split( cv_claim_id IN NUMBER ) IS
  SELECT COUNT(claim_id)
  FROM ozf_claims
  WHERE root_claim_id = cv_claim_id ;

CURSOR csr_get_split_details (cv_claim_id IN NUMBER ) IS
  SELECT c.claim_number,
         lk.meaning,
         c.amount,
         c.amount_remaining,
         c.amount_settled
  FROM ozf_claims c
  ,    ozf_lookups lk
  WHERE root_claim_id = cv_claim_id
  AND c.status_code = lk.lookup_code
  AND lk.lookup_type = 'OZF_CLAIM_STATUS'
  ORDER BY claim_number;

TYPE l_split_rec is RECORD ( claim_number     VARCHAR2(30)
                           , status           VARCHAR2(30)
                           , amount           NUMBER
                           , amount_remaining NUMBER
                           , amount_settled   NUMBER
                           );

TYPE split_tbl_type IS TABLE OF l_split_rec;
l_split_tbl split_tbl_type;

l_split_count       NUMBER;
l_rec_count         NUMBER := 1;
l_split_msg         VARCHAR2(2000);
l_split_str         VARCHAR2(2000);

/* =========================================== */

/* ===== Getting Claim Line Detail info ====== */

CURSOR csr_claim_lines(cv_claim_id IN NUMBER) IS
  SELECT ln.claim_line_id
  ,      ln.line_number
  ,      ln.item_id
  ,      ln.quantity_uom
  ,      ln.quantity
  ,      ln.rate
  ,      ln.claim_currency_amount
  ,      ln.tax_code
  ,      ln.earnings_associated_flag
  ,      ln.org_id
  FROM ozf_claim_lines ln
  WHERE ln.claim_id = cv_claim_id;

TYPE line_detail_rec is RECORD ( claim_line_id   NUMBER
                               , line_number     NUMBER
                               , item_id         NUMBER
                               , product         VARCHAR2(40)
                               , uom_code        VARCHAR2(3)
                               , uom_name        VARCHAR2(25)
                               , quantity        NUMBER
                               , rate            NUMBER
                               , amount          NUMBER
                               , type            VARCHAR2(20)
                               , name            VARCHAR2(30)
                               , tax_code        VARCHAR2(50)
                               , tax_name        VARCHAR2(50)
                               , gl_code_id      VARCHAR2(30)
                               , gl_code         VARCHAR2(50)
                               , earnings_flag   VARCHAR2(1)
                               , org_id          NUMBER
                               );
TYPE line_detail_tbl_type IS TABLE OF line_detail_rec
  INDEX BY BINARY_INTEGER;
l_line_detail_tbl     line_detail_tbl_type;
l_line_counter        NUMBER := 1;
l_line_detail_str     VARCHAR2(2000);
l_line_detail_msg     VARCHAR2(2000);
l_cc_id_tbl           OZF_GL_INTERFACE_PVT.CC_ID_TBL;

CURSOR csr_gl_code(cv_gl_code_id IN NUMBER) IS
  SELECT padded_concatenated_segments
  FROM gl_code_combinations_kfv
  WHERE code_combination_id = cv_gl_code_id;

CURSOR csr_line_trx_info(cv_claim_line_id IN NUMBER) IS
  SELECT lk.meaning
  ,      trx.trx_number
  FROM ozf_claim_lines ln
  ,    ra_customer_trx trx
  ,    ozf_lookups lk
  WHERE ln.claim_line_id = cv_claim_line_id
  AND ln.source_object_class = lk.lookup_code
  AND lk.lookup_type = 'OZF_OBJECT_CLASS'
  AND ln.source_object_id = trx.customer_trx_id;

CURSOR csr_line_product_name(cv_item_id IN NUMBER, cv_org_id IN NUMBER) IS
  SELECT concatenated_segments
  FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_item_id
  AND organization_id = cv_org_id;

CURSOR csr_line_uom_name(cv_uom_code IN VARCHAR2) IS
  SELECT unit_of_measure
  FROM mtl_units_of_measure
  WHERE uom_code = cv_uom_code;


/* =========================================== */
CURSOR csr_vendor_name(cv_vendor_id IN NUMBER) IS
  SELECT vendor_name
  FROM po_vendors
  WHERE vendor_id = cv_vendor_id;

CURSOR csr_vendor_site(cv_vendor_site_id IN NUMBER) IS
  SELECT vendor_site_code
  FROM po_vendor_sites
  WHERE vendor_site_id = cv_vendor_site_id;



-- [BEGIN OF BUG 3768539 FIXING]
l_rec_role_name                 VARCHAR2(320);
l_next_status_meaning           VARCHAR2(60);
l_csetl_err_msg                 VARCHAR2(2000);
-- [END OF BUG 3768539 FIXING]

l_error_msg   VARCHAR2(4000);
BEGIN

   l_next_status := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'OZF_NEXT_STATUS'
                                             );

   l_claim_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                            );


   -- [BEGIN OF BUG 3768539 FIXING]
   l_rec_role_name := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'OZF_RECEIVABLE_ROLE'
                                                 );

  -- Bug4042671: Read role from profile to allow role to be org specific.
  IF l_rec_role_name IS NULL THEN
     l_rec_role_name := FND_PROFILE.value('OZF_CLAIM_CSTL_WF_ROLE');
     IF l_rec_role_name IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                   itemkey   => itemkey,
                                   aname     => 'OZF_RECEIVABLE_ROLE',
                                   avalue    => l_rec_role_name
                                 );
     END IF;
   END IF;

   IF l_rec_role_name IS NULL THEN
      l_next_status := 'OPEN';
      l_next_status_meaning := OZF_UTILITY_PVT.get_lookup_meaning (
                                    p_lookup_type      => 'OZF_CLAIM_STATUS',
                                    p_lookup_code      => 'OPEN'
                               );


      WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'OZF_NEXT_STATUS_MEANING',
                                 avalue    => l_next_status_meaning
                               );

      FND_MESSAGE.set_name('OZF', 'OZF_SETL_WF_REC_ROLE_ERR');
      l_csetl_err_msg := FND_MESSAGE.get;

      WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'OZF_CSETL_ERR_MSG',
                                 avalue    => l_csetl_err_msg
                               );
   END IF;
   -- [END OF BUG 3768539 FIXING]


  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    IF l_next_status = 'CLOSED' THEN
         OPEN csr_claim(l_claim_id);
         FETCH csr_claim INTO l_root_claim_id
                            , l_payment_method
                            , l_vendor_id
                            , l_vendor_site_id;
         CLOSE csr_claim;


         /* === Fetch Claim Split Information ======= */

           OPEN  csr_is_split(l_root_claim_id);
           FETCH csr_is_split into l_split_count ;
           CLOSE csr_is_split;

           l_split_tbl := split_tbl_type();

           IF l_split_count > 1 then

              FOR i IN csr_get_split_details(l_root_claim_id)
              LOOP
                 l_split_tbl.EXTEND;
                 l_split_tbl(l_rec_count).claim_number     := i.claim_number;
                 l_split_tbl(l_rec_count).status           := i.meaning;
                 l_split_tbl(l_rec_count).amount           := i.amount;
                 l_split_tbl(l_rec_count).amount_remaining := i.amount_remaining;
                 l_split_tbl(l_rec_count).amount_settled   := i.amount_settled;

                 l_rec_count := l_rec_count+1;
              END LOOP;

              FOR i IN 1..l_split_tbl.COUNT
              LOOP
                /*
                l_split_str :=  l_split_str || ', ('
                                            || RPAD(l_split_tbl(i).claim_number,30,' ') || ' , '
                                            || TO_CHAR(l_split_tbl(i).amount_remaining)
                                            || ')' ;

         --                                   || fnd_global.local_chr(10) ;
                */
                l_split_msg := SUBSTR(l_split_msg||'('
                                     || RPAD(l_split_tbl(i).claim_number,30,' ') || ' , '
                                     || RPAD(l_split_tbl(i).status,30,' ') || ' , '
                                     || TO_CHAR(l_split_tbl(i).amount) || ' , '
                                     || TO_CHAR(l_split_tbl(i).amount_remaining) || ' , '
                                     || TO_CHAR(l_split_tbl(i).amount_settled)
                                     || ')'
                                     ||  FND_GLOBAL.local_chr(10), 1, 2000);
              END LOOP;
           END IF;

           FND_MESSAGE.set_name('OZF', 'OZF_SETL_WF_SPLT_DETLS');
           FND_MESSAGE.set_token('OZF_SETL_WF_SPLT_DETLS', l_split_msg, false);
           l_split_str := FND_MESSAGE.get;

         /* ========================================= */

         /* == Set Vendor Information in case of Contra Charge settlement == */
           IF l_payment_method = 'CONTRA_CHARGE' THEN
              OPEN csr_vendor_name(l_vendor_id);
              FETCH csr_vendor_name INTO l_vendor_name;
              CLOSE csr_vendor_name;

              OPEN csr_vendor_site(l_vendor_site_id);
              FETCH csr_vendor_site INTO l_vendor_site;
              CLOSE csr_vendor_site;

              FND_MESSAGE.set_name('OZF', 'OZF_SETL_WF_VENDOR_INFO');
              FND_MESSAGE.set_token('VENDOR_NAME', l_vendor_name, false);
              FND_MESSAGE.set_token('VENDOR_SITE', l_vendor_site, false);
              l_vendor_info_str := FND_MESSAGE.get;
           END IF;

         /* ========================================= */

         /* === Fetch Claim Lines Detail Information ======= */
           OPEN  csr_claim_lines(l_claim_id);
           LOOP
             FETCH csr_claim_lines into l_line_detail_tbl(l_line_counter).claim_line_id
                                      , l_line_detail_tbl(l_line_counter).line_number
                                      , l_line_detail_tbl(l_line_counter).item_id
                                      , l_line_detail_tbl(l_line_counter).uom_code
                                      , l_line_detail_tbl(l_line_counter).quantity
                                      , l_line_detail_tbl(l_line_counter).rate
                                      , l_line_detail_tbl(l_line_counter).amount
                                      , l_line_detail_tbl(l_line_counter).tax_code
                                      , l_line_detail_tbl(l_line_counter).earnings_flag
                                      , l_line_detail_tbl(l_line_counter).org_id;
             EXIT WHEN csr_claim_lines%NOTFOUND;
             l_line_counter := l_line_counter + 1;
           END LOOP;
           CLOSE csr_claim_lines;


           IF l_line_counter > 1 THEN
              FOR i IN 1..l_line_detail_tbl.count LOOP
                IF l_line_detail_tbl(i).earnings_flag = 'T' THEN
                  OZF_GL_INTERFACE_PVT.Get_GL_Account(
                        p_api_version       => 1.0
                       ,p_init_msg_list     => FND_API.g_false
                       ,p_commit            => FND_API.g_false
                       ,p_validation_level  => FND_API.g_valid_level_full
                       ,x_return_status     => l_return_status
                       ,x_msg_data          => l_msg_data
                       ,x_msg_count         => l_msg_count
                       ,p_source_id         => l_line_detail_tbl(i).claim_line_id
                       ,p_source_table      => 'OZF_CLAIM_LINES_ALL'
                       ,p_account_type      => 'REC_CLEARING'
                       ,x_cc_id_tbl         => l_cc_id_tbl
                  );
                  IF l_return_status <> FND_API.g_ret_sts_success THEN
                    RAISE ERROR;
                  END IF;

                  IF l_cc_id_tbl.EXISTS(1) THEN
                    OPEN csr_gl_code(l_cc_id_tbl(1).code_combination_id);
                    FETCH csr_gl_code INTO l_line_detail_tbl(i).gl_code;
                    CLOSE csr_gl_code;
                  END IF;
                END IF;

                IF l_line_detail_tbl(i).item_id IS NOT NULL THEN
                   l_inv_org_id := FND_PROFILE.value('OZF_ITEM_ORGANIZATION_ID');
                   OPEN csr_line_product_name(l_line_detail_tbl(i).item_id, l_inv_org_id);
                   FETCH csr_line_product_name INTO l_line_detail_tbl(i).product;
                   CLOSE csr_line_product_name;
                ENd IF;

                IF l_line_detail_tbl(i).uom_code IS NOT NULL THEN
                   OPEN csr_line_uom_name(l_line_detail_tbl(i).uom_code);
                   FETCH csr_line_uom_name INTO l_line_detail_tbl(i).uom_name;
                   CLOSE csr_line_uom_name;
                END IF;


                OPEN csr_line_trx_info(l_line_detail_tbl(i).claim_line_id);
                FETCH csr_line_trx_info INTO l_line_detail_tbl(i).type
                                           , l_line_detail_tbl(i).name;
                CLOSE csr_line_trx_info;

                l_line_detail_msg := SUBSTR(l_line_detail_msg||'('||
                                           TO_CHAR(l_line_detail_tbl(i).line_number)||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).type, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).name, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).product, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).uom_name, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(TO_CHAR(l_line_detail_tbl(i).quantity), ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(TO_CHAR(l_line_detail_tbl(i).rate), ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(TO_CHAR(l_line_detail_tbl(i).amount), ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).tax_code, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).gl_code, ' ')||FND_GLOBAL.local_chr(9)||' , '||
                                           NVL(l_line_detail_tbl(i).earnings_flag, ' ')||FND_GLOBAL.local_chr(9)||')'||
                                           FND_GLOBAL.local_chr(10), 1, 2000);
                       END LOOP;
           END IF;

           FND_MESSAGE.set_name('OZF', 'OZF_SETL_WF_LINE_DETLS');
           FND_MESSAGE.set_token('OZF_SETL_WF_LINE_DETLS', l_line_detail_msg, false);
           l_line_detail_str := FND_MESSAGE.get;
         /* ========================================= */

           WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname     => 'OZF_SPLIT_DETAILS',
                                      avalue    => l_split_str
                                    );
           --

           WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname     => 'OZF_LINE_DETAILS',
                                      avalue    => l_line_detail_str
                                    );

           WF_ENGINE.SetItemAttrDocument(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'OZF_LINE_DETAILS',
                                         documentid => l_line_detail_str
                                        );

           WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                                      itemkey   => itemkey,
                                      aname     => 'OZF_VENDOR_INFO',
                                      avalue    => l_vendor_info_str
                                    );
      resultout := 'COMPLETE:Y';
      RETURN;
    ELSE
      resultout := 'COMPLETE:N';
      RETURN;
    END IF;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'PREPARE_INSTRUCTIONS'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'Prepare_Instructions'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     RAISE;
  WHEN OTHERS THEN
    IF (csr_claim_lines%ISOPEN) THEN
       CLOSE csr_claim_lines;
    END IF;
    IF (csr_gl_code%ISOPEN) THEN
       CLOSE csr_gl_code;
    END IF;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Prepare_Instructions',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Prepare_Instructions;


--------------------------------------------------------------------------------
-- PROCEDURE
--   Update_Docs
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_UPDATE_DOCS
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--   03/04/2002  MCHANG  Updated to populate Wriet_off number.(see BUG#2226663)
--   15-Jul-05   Sahana  R12: AP-AR Netting Changes
--------------------------------------------------------------------------------
PROCEDURE Update_Docs(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_return_status        VARCHAR2(1)   := FND_API.g_ret_sts_success;
l_msg_data             VARCHAR2(400);
l_msg_count            NUMBER;

-- Cursor to get claim payment_method
CURSOR csr_get_settle_method(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;


TYPE trx_number_type IS VARRAY(5) OF VARCHAR2(30);
l_trx_number           trx_number_type;

CURSOR csr_cm_trx_data(cv_trx_number IN VARCHAR2) IS
  SELECT distinct customer_trx_id
  FROM   ar_payment_schedules
  WHERE  trx_number = cv_trx_number
  AND    class = 'CM';

CURSOR csr_dm_trx_data(cv_trx_number IN VARCHAR2) IS
  SELECT distinct customer_trx_id
  FROM   ar_payment_schedules
  WHERE  trx_number = cv_trx_number
  AND    class in ( 'DM', 'CB', 'INV');

CURSOR csr_cb_trx_data(cv_trx_number IN VARCHAR2) IS
  SELECT distinct customer_trx_id
  FROM   ar_payment_schedules
  WHERE  trx_number = cv_trx_number;

-- Cursor to verify Write_Off number
CURSOR csr_write_off_trx(cv_trx_number IN VARCHAR2) IS
  SELECT adjustment_id
  FROM ar_adjustments
  WHERE adjustment_number = cv_trx_number;

l_trx_id               NUMBER        := NULL;
l_trx_number_name      VARCHAR2(30);
l_err_trx_number_name  VARCHAR2(30);
l_trx_number_invalid   VARCHAR2(1)   := 'N';
l_trx_number_all_null  VARCHAR2(1)   := 'Y';
l_trx_number_error     VARCHAR2(1)   := FND_API.g_false;

l_claim_id             NUMBER;
l_org_id               NUMBER;
l_settlement_method    VARCHAR(15);
l_invoice_id           NUMBER        := NULL;
l_receipt_id           NUMBER        := NULL;
l_settle_amount        NUMBER;
l_settlement_doc_id    NUMBER;
l_settlement_doc_rec   OZF_Settlement_Doc_PVT.settlement_doc_rec_type;
l_settlement_doc_tbl   OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_err_msg              VARCHAR2(2000);
l_do_fetch             VARCHAR2(1)   := 'N';
l_is_overpayment       BOOLEAN       := FALSE;
l_trx_attribute_name   VARCHAR2(30);

--modified for Bugfix 5199354
CURSOR csr_ar_settlement(cv_trx_id IN NUMBER) IS
 select pay.customer_trx_id                      --"settlement_id"
  , pay.cust_trx_type_id                          --"settlement_type_id"
  , pay.trx_number                                --"settlement_number"
  , pay.trx_date                                  --"settlement_date"
  , sum(pay.amount_due_original)                  --"settlement_amount"
  , pay.status
 from  ar_payment_schedules pay
 where pay.customer_trx_id = cv_trx_id
 group by pay.customer_trx_id, pay.cust_trx_type_id,pay.trx_number,
  pay.trx_date , pay.status;

CURSOR csr_ar_settle_ded_writeoff(cv_trx_id IN NUMBER) IS
  SELECT adj.adjustment_id        --"settlement_id"
  , adj.receivables_trx_id        --"settlement_type_id"
  , adj.adjustment_number         --"settlement_number"
  , adj.apply_date                --"settlement_date"
  , adj.amount                    --"settlement_amount"
  , pay.status                    --"status_code"
  FROM ar_adjustments adj
  , ar_payment_schedules pay
  WHERE adj.payment_schedule_id = pay.payment_schedule_id
  AND adj.adjustment_id = cv_trx_id;

CURSOR csr_ar_settle_rec_writeoff(cv_cash_receipt_id IN NUMBER) IS
  SELECT rec.receivable_application_id    --"settlement_id"
  , pay.payment_schedule_id               --"settlement_type_id"
  , NULL                                  --"settlement_number"
  , rec.apply_date                        --"settlement_date"
  , rec.amount_applied                    --"settlement_amount"
  , pay.status                            --"status_code"
  FROM ar_receivable_applications rec
  , ar_payment_schedules pay
  WHERE rec.cash_receipt_id = cv_cash_receipt_id
  AND rec.applied_payment_schedule_id = -3
  AND rec.applied_payment_schedule_id = pay.payment_schedule_id;

CURSOR csr_del_settle_doc(cv_claim_id IN NUMBER) IS
  SELECT settlement_doc_id
  ,      object_version_number
  FROM ozf_settlement_docs
  WHERE claim_id = cv_claim_id;

BEGIN
  SAVEPOINT Update_Docs;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    l_claim_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'OZF_CLAIM_ID'
                                             );
    l_settle_amount := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'OZF_AMOUNT_SETTLED'
                                                   );

    l_receipt_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_RECEIPT_ID'
                                               );
    l_invoice_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_INVOICE_ID'
                                               );
    OPEN csr_get_settle_method(l_claim_id);
    FETCH csr_get_settle_method INTO l_settlement_method
                                   , l_org_id;
    CLOSE csr_get_settle_method;

    -- set org_context since workflow mailer does not set the context
    --Set_Org_Ctx (l_org_id);


    IF l_settle_amount < 0 THEN
      l_is_overpayment := TRUE;
    END IF;

    l_trx_number := trx_number_type();


   /*------------------------*
    | Get Transaction Number
    | Reset Error Transaction Number Array
    *------------------------*/

    IF l_settlement_method = 'WRITE_OFF' AND
          (l_invoice_id IS NULL OR l_is_overpayment) THEN
          -- If it's a overpayment-receipt write_off,
          -- workflow don't expect a transaction number entered by user.
          l_trx_number.extend;
          l_trx_number(1) := 'Receipt Write-off';
          l_trx_number.extend;
          l_trx_number(2) := NULL;
          l_trx_number.extend;
          l_trx_number(3) := NULL;
          l_trx_number.extend;
          l_trx_number(4) := NULL;
          l_trx_number.extend;
          l_trx_number(5) := NULL;
          l_trx_number_all_null := 'N';
    ELSE
         -- get OZF_TRX_NUMBER_i
         FOR i IN 1..5 LOOP
            l_trx_number_name := 'OZF_TRX_NUMBER_'||i;
            l_trx_number.extend;
            l_trx_number(i) := WF_ENGINE.GetItemAttrText( itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_number_name
                                                        );

            l_trx_number(i) := LTRIM(RTRIM(l_trx_number(i)));

                FOR j IN 1..i LOOP
                  IF i <> 1 AND l_trx_number(i) = l_trx_number(j) THEN
                    l_trx_number(i) := NULL;
                    WF_ENGINE.SetItemAttrText( itemtype  => itemtype
                                             , itemkey   => itemkey
                                             , aname     => l_trx_number_name
                                             , avalue    => NULL
                                               );
                  END IF;
                END LOOP;

            IF l_trx_number(i) IS NOT NULL THEN
               l_trx_number_all_null := 'N';
               WF_ENGINE.SetItemAttrText( itemtype  => itemtype
                                        , itemkey   => itemkey
                                        , aname     => l_trx_number_name
                                        , avalue    => l_trx_number(i)
                                        );
            END IF;

            l_err_trx_number_name := 'OZF_ERROR_TRX_NUMBER_'||i;
            WF_ENGINE.SetItemAttrText( itemtype  => itemtype
                                     , itemkey   => itemkey
                                     , aname     => l_err_trx_number_name
                                     , avalue    => NULL
                                     );
         END LOOP;

         IF l_trx_number_all_null = 'Y' THEN
           resultout := 'COMPLETE:ERROR';
           RETURN;
         END IF;
    END IF;

    /*---------------------------*
    | Verify Transaction Number
    *---------------------------*/

     FOR i IN 1..5 LOOP
       IF l_trx_number(i) IS NOT NULL THEN
           l_do_fetch := 'N';
           l_trx_number_invalid := 'N';

           IF l_settlement_method = 'CONTRA_CHARGE' THEN -- R12
              l_do_fetch := 'Y';
           ELSIF l_settlement_method = 'WRITE_OFF' THEN

              IF l_invoice_id IS NULL OR  l_is_overpayment THEN
                -- Overpayment - Receipt Write-Off: payment_schedule_id for Receipt Write-off is -3
                l_do_fetch := 'Y';
              ELSE
                -- Deduction Write-Off: AR will issue a write_off number.
                OPEN csr_write_off_trx(l_trx_number(i));
                FETCH csr_write_off_trx INTO l_trx_id;
                IF csr_write_off_trx%NOTFOUND THEN
                   l_do_fetch := 'N';
                ELSE
                   l_do_fetch := 'Y';
                END IF;
                CLOSE csr_write_off_trx;
              END IF;
           ELSE
              -- Other settlement methods
                  IF  l_settlement_method ='CHARGEBACK' THEN
                  OPEN csr_cb_trx_data(l_trx_number(i));
                      FETCH csr_cb_trx_data INTO l_trx_id;
                          IF csr_cb_trx_data%NOTFOUND THEN
                             l_do_fetch := 'N';
                      ELSE
                          l_do_fetch := 'Y';
                  END IF;
                      CLOSE csr_cb_trx_data;

              ELSIF l_is_overpayment THEN
                  OPEN csr_dm_trx_data(l_trx_number(i));
                  FETCH csr_dm_trx_data INTO l_trx_id;
                          IF csr_dm_trx_data%NOTFOUND THEN
                             l_do_fetch := 'N';
                      ELSE
                             l_do_fetch := 'Y';
                  END IF;
                      CLOSE csr_dm_trx_data;
                  ELSE
                  OPEN csr_cm_trx_data(l_trx_number(i));
                      FETCH csr_cm_trx_data INTO l_trx_id;
                          IF csr_cm_trx_data%NOTFOUND THEN
                             l_do_fetch := 'N';
                      ELSE
                             l_do_fetch := 'Y';
                  END IF;
                          CLOSE csr_cm_trx_data;
                  END IF;
          END IF;

          IF l_do_fetch = 'Y' THEN
              /*---------------------------*
             | Populate Settlement Docs
             *---------------------------*/
                 IF l_settlement_method = 'CONTRA_CHARGE' THEN
               l_settlement_doc_rec.settlement_number := l_trx_number(i);
             ELSIF l_settlement_method = 'WRITE_OFF' THEN
               IF l_invoice_id IS NULL AND
                  l_is_overpayment THEN
                  -- Overpayment: Receipt Write-Off
                  OPEN csr_ar_settle_rec_writeoff(l_receipt_id);
                  FETCH csr_ar_settle_rec_writeoff INTO
                             l_settlement_doc_rec.settlement_id
                           , l_settlement_doc_rec.settlement_type_id
                           , l_settlement_doc_rec.settlement_number
                           , l_settlement_doc_rec.settlement_date
                           , l_settlement_doc_rec.settlement_amount
                           , l_settlement_doc_rec.status_code;
                  CLOSE csr_ar_settle_rec_writeoff;
               ELSE
                  -- Deduction Write-Off
                  OPEN csr_ar_settle_ded_writeoff(l_trx_id);
                  FETCH csr_ar_settle_ded_writeoff INTO
                             l_settlement_doc_rec.settlement_id
                           , l_settlement_doc_rec.settlement_type_id
                           , l_settlement_doc_rec.settlement_number
                           , l_settlement_doc_rec.settlement_date
                           , l_settlement_doc_rec.settlement_amount
                           , l_settlement_doc_rec.status_code;
                  CLOSE csr_ar_settle_ded_writeoff;
               END IF;
             ELSE
               -- Other settlement method
               OPEN csr_ar_settlement(l_trx_id);
               FETCH csr_ar_settlement INTO
                        l_settlement_doc_rec.settlement_id
                      , l_settlement_doc_rec.settlement_type_id
                      , l_settlement_doc_rec.settlement_number
                      , l_settlement_doc_rec.settlement_date
                      , l_settlement_doc_rec.settlement_amount
                      , l_settlement_doc_rec.status_code;
               CLOSE csr_ar_settlement;
             END IF;

             l_settlement_doc_rec.payment_method := l_settlement_method;
             l_settlement_doc_rec.claim_id := l_claim_id;

             -- create ozf_setttlement_docs_all
             BEGIN
               OZF_Settlement_Doc_PVT.Create_Settlement_Doc(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.g_false,
                   p_commit             => FND_API.g_false,
                   p_validation_level   => FND_API.g_valid_level_full,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_settlement_doc_rec => l_settlement_doc_rec,
                   x_settlement_doc_id  => l_settlement_doc_id
               );

               IF l_return_status <> FND_API.g_ret_sts_success THEN
                 l_trx_number_invalid := 'Y';
                 l_err_msg := l_msg_count||' '||l_msg_data;
               END IF;
             EXCEPTION
               WHEN OTHERS THEN
                 WF_CORE.context( 'OZF_AR_SETTLEMENT_PVT',
                                  'Update_Docs'||'-'||'Update_Settlement_Docs',
                                  itemtype,
                                  itemkey,
                                  to_char(actid),
                                  funcmode
                                );
                 l_err_msg := SQLERRM;
                 RAISE;
             END; -- begin-exception-end
           END IF; -- end-if l_do_fetch

           IF l_trx_number_invalid = 'Y' OR l_do_fetch = 'N' THEN
             l_trx_number_error := FND_API.g_true;
             l_err_trx_number_name := 'OZF_ERROR_TRX_NUMBER_'||i;
             WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => l_err_trx_number_name,
                                        avalue   => l_trx_number(i)
                                      );
             WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'OZF_RECEIVABLE_NOTES',
                                        avalue   => l_err_msg
                                      );
           END IF;

         END IF; -- end-if l_trx_num not null
       END LOOP; -- end-if 1..5 loop

       IF l_trx_number_error = FND_API.g_true THEN
          resultout := 'COMPLETE:ERROR';
       ELSE
          resultout := 'COMPLETE:SUCCESS';
       END IF;

       RETURN;

  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    OPEN csr_del_settle_doc(l_claim_id);
    FETCH csr_del_settle_doc INTO l_settlement_doc_rec.settlement_doc_id
                                , l_settlement_doc_rec.object_version_number;
    CLOSE csr_del_settle_doc;

    BEGIN
       OZF_Settlement_Doc_PVT.Delete_Settlement_Doc(
             p_api_version_number      => 1.0,
             p_init_msg_list           => FND_API.g_false,
             p_commit                  => FND_API.g_false,
             p_validation_level        => FND_API.g_valid_level_full,
             x_return_status           => l_return_status,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data,
             p_settlement_doc_id       => l_settlement_doc_rec.settlement_doc_id,
             p_object_version_number   => l_settlement_doc_rec.object_version_number
       );
       IF l_return_status <> FND_API.g_ret_sts_success THEN
           resultout := 'COMPLETE:ERROR';
           RETURN;
       END IF;
    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.context( 'OZF_AR_SETTLEMENT_PVT',
                         'Update_Docs'||'-'||'Update_Claim',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode
                       );
        RAISE;
    END;

    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Update_Docs;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Update_Docs',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Update_Docs;

--------------------------------------------------------------------------------
-- PROCEDURE
--   Create_Settle_Doc
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:SUCCESS'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CREATE_SETTLE_DOC
--
-- HISTORY
--------------------------------------------------------------------------------
PROCEDURE Create_Settle_Doc(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_return_status        VARCHAR2(1)   := FND_API.g_ret_sts_success;
l_msg_data             VARCHAR2(400);
l_msg_count            NUMBER;

l_trx_id               NUMBER        := NULL;
l_trx_number_name      VARCHAR2(30);
l_err_trx_number_name  VARCHAR2(30);
l_trx_number_invalid   VARCHAR2(1)   := 'N';
l_trx_number_all_null  VARCHAR2(1)   := 'Y';
l_trx_number_error     VARCHAR2(1)   := FND_API.g_false;

l_claim_id             NUMBER;
l_org_id               NUMBER;
l_settle_amount        NUMBER;
l_settlement_doc_id    NUMBER;
l_settlement_method    VARCHAR(15);
l_settlement_doc_rec   OZF_Settlement_Doc_PVT.settlement_doc_rec_type;
l_settlement_doc_tbl   OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_err_msg              VARCHAR2(2000);
l_do_fetch             VARCHAR2(1)   := 'N';
l_is_overpayment       BOOLEAN       := FALSE;
l_trx_attribute_name   VARCHAR2(30);

CURSOR csr_get_org(cv_claim_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_del_settle_doc(cv_claim_id IN NUMBER) IS
  SELECT settlement_doc_id
  ,      object_version_number
  FROM ozf_settlement_docs
  WHERE claim_id = cv_claim_id;


BEGIN
  SAVEPOINT Create_Settle_Doc;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN

    l_claim_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'OZF_CLAIM_ID'
                                             );
    l_settlement_method := WF_ENGINE.GetItemAttrText(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'OZF_PAYMENT_METHOD_CODE'
                           );
    l_settle_amount := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'OZF_AMOUNT_SETTLED'
                                                   );
    OPEN csr_get_org(l_claim_id);
    FETCH csr_get_org INTO l_org_id;
    CLOSE csr_get_org;

    -- set org_context since workflow mailer does not set the context
    --Set_Org_Ctx (l_org_id);

       FOR i IN 1..1 LOOP
          l_trx_attribute_name := 'OZF_TRX_ID_'||i;
          l_settlement_doc_tbl(i).settlement_id := WF_ENGINE.GetItemAttrNumber(
                                                          itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                    );

          l_trx_attribute_name := 'OZF_TRX_TYPE_'||i;
          l_settlement_doc_tbl(i).settlement_type := WF_ENGINE.GetItemAttrText(
                                                          itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                     );
          l_settlement_doc_tbl(i).settlement_type := LTRIM(RTRIM(l_settlement_doc_tbl(i).settlement_type));

          l_trx_attribute_name := 'OZF_TRX_NUMBER_'||i;
          l_settlement_doc_tbl(i).settlement_number := WF_ENGINE.GetItemAttrText(
                                                          itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                       );
          l_settlement_doc_tbl(i).settlement_number := LTRIM(RTRIM(l_settlement_doc_tbl(i).settlement_number));

          IF l_settlement_doc_tbl(i).settlement_number IS NOT NULL THEN
             l_trx_number_all_null := 'N';
          END IF;

          l_trx_attribute_name := 'OZF_TRX_DATE_'||i;
          l_settlement_doc_tbl(i).settlement_DATE := WF_ENGINE.GetItemAttrDate(
                                                         itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                     );

          l_trx_attribute_name := 'OZF_TRX_AMOUNT_'||i;
          l_settlement_doc_tbl(i).settlement_amount := WF_ENGINE.GetItemAttrNumber(
                                                          itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                       );

          l_trx_attribute_name := 'OZF_TRX_STATUS_'||i;
          l_settlement_doc_tbl(i).status_code := WF_ENGINE.GetItemAttrText(
                                                          itemtype => itemtype
                                                        , itemkey  => itemkey
                                                        , aname    => l_trx_attribute_name
                                                 );
          l_settlement_doc_tbl(i).status_code := LTRIM(RTRIM(l_settlement_doc_tbl(i).status_code));

       END LOOP;

       IF l_trx_number_all_null = 'Y' THEN
          resultout := 'COMPLETE:ERROR';
          RETURN;
       END IF;

       FOR i IN 1..1 LOOP
          IF l_settlement_doc_tbl(i).settlement_number IS NOT NULL THEN
             l_settlement_doc_tbl(i).payment_method := l_settlement_method;
             l_settlement_doc_tbl(i).claim_id := l_claim_id;

             -- create ozf_setttlement_docs_all
             BEGIN
               OZF_Settlement_Doc_PVT.Create_Settlement_Doc(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.g_false,
                   p_commit             => FND_API.g_false,
                   p_validation_level   => FND_API.g_valid_level_full,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_settlement_doc_rec => l_settlement_doc_tbl(i),
                   x_settlement_doc_id  => l_settlement_doc_id
               );
               IF l_return_status <> FND_API.g_ret_sts_success THEN
                  resultout := 'COMPLETE:ERROR';
                  RETURN;
               END IF;
             EXCEPTION
               WHEN OTHERS THEN
                 WF_CORE.context( 'OZF_AR_SETTLEMENT_PVT',
                                  'Create_Settle_Doc'||'-'||'Create_Settlement_Doc',
                                  itemtype,
                                  itemkey,
                                  to_char(actid),
                                  funcmode
                                );
                 l_err_msg := SQLERRM;
                 RAISE;
             END;
          END IF;
       END LOOP;
       resultout := 'COMPLETE:SUCCESS';
       RETURN;
  END IF;

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    OPEN csr_del_settle_doc(l_claim_id);
    FETCH csr_del_settle_doc INTO l_settlement_doc_rec.settlement_doc_id
                                , l_settlement_doc_rec.object_version_number;
    CLOSE csr_del_settle_doc;

    BEGIN
       OZF_Settlement_Doc_PVT.Delete_Settlement_Doc(
             p_api_version_number      => 1.0,
             p_init_msg_list           => FND_API.g_false,
             p_commit                  => FND_API.g_false,
             p_validation_level        => FND_API.g_valid_level_full,
             x_return_status           => l_return_status,
             x_msg_count               => l_msg_count,
             x_msg_data                => l_msg_data,
             p_settlement_doc_id       => l_settlement_doc_rec.settlement_doc_id,
             p_object_version_number   => l_settlement_doc_rec.object_version_number
       );
    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.context( 'OZF_AR_SETTLEMENT_PVT',
                         'Create_Settle_Doc'||'-'||'Delete_Settlement_Doc',
                         itemtype,
                         itemkey,
                         to_char(actid),
                         funcmode
                       );
        RAISE;
    END;

    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Create_Settle_Doc;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Create_Settle_Doc',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Create_Settle_Doc;


--------------------------------------------------------------------------------
-- PROCEDURE
--   Close_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:ERROR'
--             - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CLOSE_CLAIM
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--   11/15/2001  MCHANG  Call OZF_SETTLEMENT_DOC_PVT.Update_Claim_From_Settlement()
--                       to update claim status to CLOSED.
--------------------------------------------------------------------------------
PROCEDURE Close_Claim (
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(400);
l_msg_count        NUMBER;

CURSOR csr_claim_version(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  system_status_code = cv_status_code;

l_user_status_id   NUMBER;
l_status_code      VARCHAR2(30);
l_claim_rec        OZF_CLAIM_PVT.claim_rec_type;
l_claim_id         NUMBER;
l_settle_amount    NUMBER;

l_error_msg        VARCHAR2(4000);

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );
    -- get claim next status to update
    l_status_code := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_NEXT_STATUS'
                                              );

    l_settle_amount := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'OZF_AMOUNT_SETTLED'
                                                   );

    OZF_AR_PAYMENT_PVT.Query_Claim(
           p_claim_id           => l_claim_id
              ,x_claim_rec          => l_claim_rec
          ,x_return_status      => l_return_status
    );
    IF l_return_status <> FND_API.g_ret_sts_success THEN
           RAISE ERROR;
    END IF;

    -- set org_context since workflow mailer does not set the context
    --Set_Org_Ctx (l_claim_rec.org_id);
    OZF_Settlement_Doc_PVT.Update_Claim_From_Settlement(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => FND_API.g_false
           ,p_commit                 => FND_API.g_false
           ,p_validation_level       => FND_API.g_valid_level_full

           ,x_return_status          => l_return_status
           ,x_msg_count              => l_msg_count
           ,x_msg_data               => l_msg_data

           ,p_claim_id               => l_claim_rec.claim_id
           ,p_object_version_number  => l_claim_rec.object_version_number
           ,p_status_code            => l_status_code
           ,p_payment_status         => 'PAID'
    );
    IF l_return_status <> FND_API.g_ret_sts_success THEN
         RAISE ERROR;
    END IF;

    IF l_claim_rec.claim_class = 'DEDUCTION' AND
          l_claim_rec.source_object_id IS NOT NULL THEN
          OZF_AR_PAYMENT_PVT.update_dispute_amount(
                        p_claim_rec          => l_claim_rec
               ,p_dispute_amount     => l_settle_amount
                       ,x_return_status      => l_return_status
               ,x_msg_data           => l_msg_data
                       ,x_msg_count          => l_msg_count
                    );
           IF l_return_status <> FND_API.g_ret_sts_success THEN
              RAISE ERROR;
           END IF;
    END IF;

    IF l_claim_rec.claim_class IN ( 'DEDUCTION' , 'OVERPAYMENT') THEN
          OZF_AR_PAYMENT_PVT.Unapply_Claim_Investigation(
                        p_claim_rec          => l_claim_rec
               ,p_reapply_amount     => 0
                       ,x_return_status      => l_return_status
               ,x_msg_data           => l_msg_data
                       ,x_msg_count          => l_msg_count
                    );
           IF l_return_status <> FND_API.g_ret_sts_success THEN
              RAISE ERROR;
               END IF;
    END IF;

    resultout := 'COMPLETE:SUCCESS';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'CLOSE_CLAIM'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'CLOSE_CLAIM'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RAISE;

  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Close_Claim',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Close_Claim;


------------------------------------------------------------------------------
-- PROCEDURE
--   Reset_Status
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_RESET_STATUS
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--------------------------------------------------------------------------------
PROCEDURE Reset_Status(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(400);
l_msg_count        NUMBER;

CURSOR csr_claim_version(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  system_status_code = cv_status_code;

l_claim_id         NUMBER;
l_object_version   NUMBER;
l_org_id           NUMBER;
l_user_status_id   NUMBER;
l_result_status    VARCHAR2(15)      := 'OPEN';
l_claim_rec        OZF_CLAIM_PVT.claim_rec_type;

l_error_msg        VARCHAR2(4000);

BEGIN
  SAVEPOINT Reset_Status;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    OPEN csr_claim_version(l_claim_id);
    FETCH csr_claim_version INTO l_object_version
                               , l_org_id;
    CLOSE csr_claim_version;

    -- set org_context since workflow mailer does not set the context
    --Set_Org_Ctx (l_org_id);

    OPEN csr_user_status_id(l_result_status);
    FETCH csr_user_status_id INTO l_user_status_id;
    CLOSE csr_user_status_id;

    l_claim_rec.claim_id := l_claim_id;
    l_claim_rec.object_version_number := l_object_version;
    --l_claim_rec.payment_status := 'PENDING';
    l_claim_rec.payment_status := NULL;
    l_claim_rec.user_status_id := l_user_status_id;
    l_claim_rec.status_code := l_result_status;

    OZF_CLAIM_PVT.Update_Claim (
          p_api_version            => 1.0
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full

         ,x_return_status          => l_return_status
         ,x_msg_data               => l_msg_data
         ,x_msg_count              => l_msg_count
         ,p_claim                  => l_claim_rec
         ,p_event                  => 'UPDATE'
         ,p_mode                   => 'AUTO'
         ,x_object_version_number  => l_object_version
     );
    IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE ERROR;
    END IF;

    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     ROLLBACK TO Reset_Status;
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'RESET_STATUS'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'Reset_Status'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     RAISE;
  WHEN OTHERS THEN
    ROLLBACK TO Reset_Status;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Reset_Status',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Reset_Status;


------------------------------------------------------------------------------
-- PROCEDURE
--   Start_Settlement
--
-- IN
--   p_claim_id      - claim_id
--   p_prev_status   - previous_status
--   p_curr_status   - current_status
--   p_next_status   - next_status
--
-- OUT
--
-- HISTORY
--   04/05/2001  MCHANG  CREATION.
--------------------------------------------------------------------------------
PROCEDURE Start_Settlement(
    p_claim_id              IN  NUMBER,
    p_prev_status           IN  VARCHAR2,
    p_curr_status           IN  VARCHAR2,
    p_next_status           IN  VARCHAR2,
    p_promotional_claim     IN  VARCHAR2 := 'N',
    p_process               IN  VARCHAR2 := 'OZF_CLAIM_GENERIC_SETTLEMENT'
)
IS
l_api_name      CONSTANT VARCHAR2(30)    := 'Start_Settlement';

l_itemtype               VARCHAR2(30)    := G_ITEMTYPE;
l_itemkey                VARCHAR2(80);
l_itemuserkey            VARCHAR2(80);
l_process                VARCHAR2(80)    := p_process;
l_return_status          VARCHAR2(1);
l_msg_data               VARCHAR2(1000);
l_msg_count              NUMBER;

CURSOR csr_claim_rec(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      claim_number
  ,      claim_class
  ,      amount_settled
  ,      currency_code
  ,      receipt_id
  ,      receipt_number
  ,      source_object_id
  ,      source_object_number
  ,      payment_method
  ,      gl_date
  ,      effective_date
  ,      cust_account_id
  ,      cust_billto_acct_site_id
  ,      cust_shipto_acct_site_id
  ,      owner_id
  ,      org_id
  ,      claim_type_id
  ,      claim_date
  ,      due_date
  ,      reason_code_id
  ,      comments
  ,      root_claim_id
  ,      sales_rep_id
  ,      vendor_id
  ,      vendor_site_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_owner(cv_owner_id IN NUMBER) IS
  SELECT fnd.user_name
  FROM fnd_user fnd
  ,    ams_jtf_rs_emp_v rs
  WHERE rs.user_id = fnd.user_id
  AND rs.resource_id = cv_owner_id;

CURSOR csr_site(cv_site_id IN NUMBER) IS
  SELECT location
  FROM hz_cust_site_uses
  WHERE site_use_id = cv_site_id;

CURSOR csr_cust_name(cv_cust_account_id IN NUMBER) IS
  SELECT p.party_name,
         a.account_number
  FROM   hz_cust_accounts a
  ,      hz_parties p
  WHERE  a.party_id = p.party_id
  AND    a.cust_account_id = cv_cust_account_id;

CURSOR csr_org_name(cv_org_id IN NUMBER) IS
  SELECT name
  FROM   hr_all_organization_units
  WHERE organization_id = cv_org_id ;

CURSOR csr_claim_type (cv_claim_type_id IN NUMBER) IS
  SELECT name
  , cm_trx_type_id
  , dm_trx_type_id
  , cb_trx_type_id
  FROM   ozf_claim_types_vl
  WHERE claim_type_id = cv_claim_type_id;

CURSOR csr_trx_type(cv_trx_type_id IN NUMBER) IS
  SELECT name
  FROM ra_cust_trx_types
  WHERE cust_trx_type_id = cv_trx_type_id;

--  AND    transaction_type = typ.cust_trx_type_id (+) ;
/*
CURSOR csr_reason (cv_reason_code_id IN NUMBER ) IS
  SELECT name
  FROM   ozf_reason_codes_all_vl
  WHERE  reason_code_id = cv_reason_code_id ;
*/
CURSOR csr_pmt_method (cv_payment_method IN VARCHAR2) IS
  SELECT meaning
  FROM   ozf_lookups
  WHERE  lookup_type = 'OZF_PAYMENT_METHOD'
  AND    lookup_code = cv_payment_method ;

CURSOR csr_salesrep_name(cv_salesrep_id IN NUMBER, cv_org_id IN NUMBER) IS
  SELECT nvl(s.name, r.source_name)
  FROM   jtf_rs_salesreps s
  ,      jtf_rs_resource_extns r
  WHERE s.resource_id = r.resource_id
  AND s.salesrep_id = cv_salesrep_id
  AND s.org_id = cv_org_id;

CURSOR csr_status_meaning(cv_status_code IN VARCHAR2) IS
  SELECT meaning
  FROM ozf_lookups
  WHERE lookup_type = 'OZF_CLAIM_STATUS'
  AND lookup_code = cv_status_code;

CURSOR csr_ar_cm_reason_code(cv_reason_code_id IN NUMBER) IS
  SELECT ar.meaning
  FROM ar_lookups ar
  ,    ozf_reason_codes_vl rs
  WHERE rs.reason_code_id = cv_reason_code_id
  AND ar.lookup_type = 'CREDIT_MEMO_REASON'
  AND rs.reason_code = ar.lookup_code;

CURSOR csr_ar_adj_reason_code(cv_reason_code_id IN NUMBER) IS
  SELECT ar.meaning
  FROM ar_lookups ar
  ,    ozf_reason_codes_vl rs
  WHERE rs.reason_code_id = cv_reason_code_id
  AND ar.lookup_type = 'ADJUST_REASON'
  AND rs.adjustment_reason_code = ar.lookup_code;

CURSOR csr_setl_doc(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  ,      settlement_amount
  FROM ozf_settlement_docs
  WHERE claim_id = cv_claim_id
  AND payment_status = 'PENDING_PAID';

l_claim_rec              csr_claim_rec%ROWTYPE;
l_owner                  VARCHAR2(100);
l_owner_name             VARCHAR2(100);
l_billto_site            VARCHAR2(40);
l_shipto_site            VARCHAR2(40);
l_cust_name              VARCHAR2(240);
l_salesrep_name          VARCHAR2(240);

l_org_name               VARCHAR2(240);
l_claim_type             VARCHAR2(30);
l_trx_type               VARCHAR2(20);
--l_reason                 VARCHAR2(80);
l_account_number         VARCHAR2(30);
l_payment_method         VARCHAR2(80);
l_payment_method_code    VARCHAR2(30);
l_next_status_meaning    VARCHAR2(80);
l_ar_reason_code         VARCHAR2(80);
l_cm_trx_type_id         NUMBER;
l_dm_trx_type_id         NUMBER;
l_cb_trx_type_id         NUMBER;
l_amount_settled         NUMBER;

BEGIN

  OPEN csr_claim_rec(p_claim_id);
  FETCH csr_claim_rec INTO l_claim_rec;
  IF csr_claim_rec%NOTFOUND THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    CLOSE csr_claim_rec;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE csr_claim_rec;

  -- set org_context since workflow mailer does not set the context
  --Set_Org_Ctx (l_claim_rec.org_id);

  OPEN csr_site(l_claim_rec.cust_billto_acct_site_id);
  FETCH csr_site INTO l_billto_site;
  CLOSE csr_site;

  OPEN csr_site(l_claim_rec.cust_shipto_acct_site_id);
  FETCH csr_site INTO l_shipto_site;
  CLOSE csr_site;

  OPEN csr_cust_name(l_claim_rec.cust_account_id);
  FETCH csr_cust_name INTO l_cust_name, l_account_number;
  CLOSE csr_cust_name;

  OPEN csr_org_name(l_claim_rec.org_id);
  FETCH csr_org_name INTO l_org_name ;
  CLOSE csr_org_name;

  /*
  -- Transaction type should not be passed for Regular Credit Memos and should be
  -- passed only for On Account Credit Memos in the settlement notification.
  IF l_claim_rec.payment_method <> 'CREDIT_MEMO' THEN
    l_trx_type := NULL;
  END IF;
  */
  OPEN csr_claim_type(l_claim_rec.claim_type_id) ;
  FETCH csr_claim_type INTO l_claim_type
                          , l_cm_trx_type_id
                          , l_dm_trx_type_id
                          , l_cb_trx_type_id;
  CLOSE csr_claim_type;

  IF l_claim_rec.payment_method IN ('REG_CREDIT_MEMO', 'CREDIT_MEMO') THEN
     OPEN csr_trx_type(l_cm_trx_type_id);
     FETCH csr_trx_type INTO l_trx_type;
     CLOSE csr_trx_type;
  ELSIF l_claim_rec.payment_method = 'DEBIT_MEMO' THEN
     OPEN csr_trx_type(l_dm_trx_type_id);
     FETCH csr_trx_type INTO l_trx_type;
     CLOSE csr_trx_type;
  ELSIF l_claim_rec.payment_method = 'CHARGEBACK' THEN
     OPEN csr_trx_type(l_cb_trx_type_id);
     FETCH csr_trx_type INTO l_trx_type;
     CLOSE csr_trx_type;
  END IF;

  /*
  OPEN csr_reason(l_claim_rec.reason_code_id);
  FETCH csr_reason INTO l_reason ;
  CLOSE csr_reason ;
  */

  OPEN csr_pmt_method(l_claim_rec.payment_method);
  FETCH csr_pmt_method INTO l_payment_method;
  CLOSE csr_pmt_method;

  OPEN csr_salesrep_name(l_claim_rec.sales_rep_id, l_claim_rec.org_id);
  FETCH csr_salesrep_name INTO l_salesrep_name;
  CLOSE csr_salesrep_name;

  OPEN csr_owner(l_claim_rec.owner_id);
  FETCH csr_owner INTO l_owner_name;
  CLOSE csr_owner;

  OPEN csr_status_meaning(p_next_status);
  FETCH csr_status_meaning INTO l_next_status_meaning;
  CLOSE csr_status_meaning;

  IF l_claim_rec.payment_method IN ('CREDIT_MEMO', 'REG_CREDIT_MEMO') THEN
     OPEN csr_ar_cm_reason_code(l_claim_rec.reason_code_id);
     FETCH csr_ar_cm_reason_code INTO l_ar_reason_code;
     CLOSE csr_ar_cm_reason_code;
  ELSIF l_claim_rec.payment_method IN ('WRITE_OFF', 'CHARGEBACK') THEN
     OPEN csr_ar_adj_reason_code(l_claim_rec.reason_code_id);
     FETCH csr_ar_adj_reason_code INTO l_ar_reason_code;
     CLOSE csr_ar_adj_reason_code;
  END IF;


  -- set the itemkey and itemuserkey
  l_itemkey := p_claim_id||'_'||l_claim_rec.object_version_number;
  l_itemuserkey := l_claim_rec.claim_number||'_'||
                   l_claim_rec.receipt_number||'_'||
                   l_claim_rec.object_version_number;

  -- creaye a new process
  WF_ENGINE.CreateProcess( itemType   => l_itemtype,
                           itemKey    => l_itemkey,
                           process    => l_process
                         );
  --
  -- set the user key for process
  WF_ENGINE.SetItemUserKey( itemType   => l_itemtype,
                            itemKey    => l_itemkey,
                            userKey    => l_itemuserkey
                          );
  --

  Get_User_Role(
      p_user_id               => l_claim_rec.owner_id
     ,x_role_name             => l_owner
     ,x_role_display_name     => l_owner_name
  );
  -- set the process owner (l_claim_owner)
  WF_ENGINE.SetItemOwner( itemtype  => l_itemtype,
                          itemkey   => l_itemkey,
                          owner     => l_owner
                        );
  --

  ----------------- Set Attributes ---------------------------
  WF_ENGINE.SetItemAttrNumber( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'OZF_CLAIM_ID',
                               avalue   => p_claim_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'OZF_CLAIM_NUMBER',
                             avalue   => l_claim_rec.claim_number
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'OZF_CLAIM_CLASS',
                             avalue   => l_claim_rec.claim_class
                           );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'OZF_AMOUNT_SETTLED',
                               avalue   => l_claim_rec.amount_settled
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'OZF_CURRENCY_CODE',
                             avalue   => l_claim_rec.currency_code
                           );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_RECEIPT_ID',
                               avalue    => l_claim_rec.receipt_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_RECEIPT_NUMBER',
                             avalue    => l_claim_rec.receipt_number
                           );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_INVOICE_ID',
                               avalue    => l_claim_rec.source_object_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_INVOICE_NUMBER',
                             avalue    => l_claim_rec.source_object_number
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_PAYMENT_METHOD',
                             avalue    => l_payment_method
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_PAYMENT_METHOD_CODE',
                             avalue    => l_claim_rec.payment_method
                           );
  --
  WF_ENGINE.SetItemAttrDate( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_GL_DATE',
                             avalue    => l_claim_rec.gl_date
                           );
  --
  WF_ENGINE.SetItemAttrDate( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_EFFECTIVE_DATE',
                             avalue    => l_claim_rec.effective_date
                           );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_CUST_ACCOUNT_ID',
                               avalue    => l_claim_rec.cust_account_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_ACCOUNT_NAME',
                             avalue    => l_cust_name
                             );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_BILLTO_ACCT_SITE_ID',
                               avalue    => l_claim_rec.cust_billto_acct_site_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_BILLTO_SITE',
                             avalue    => l_billto_site
                             );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_SHIPTO_ACCT_SITE_ID',
                               avalue    => l_claim_rec.cust_shipto_acct_site_id
                             );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_SHIPTO_SITE',
                             avalue    => l_shipto_site
                           );
  --
  WF_ENGINE.SetItemAttrNumber( itemtype  => l_itemtype,
                               itemkey   => l_itemkey,
                               aname     => 'OZF_CLAIM_OWNER_ID',
                               avalue    => l_claim_rec.owner_id
                             );
  --
  WF_ENGINE.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'OZF_CLAIM_OWNER',
                            avalue    => l_owner
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_PREVIOUS_STATUS',
                             avalue    => p_prev_status
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_CURRENT_STATUS',
                             avalue    => p_curr_status
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_NEXT_STATUS',
                             avalue    => p_next_status
                           );

  -- New attr added 12-Aug

  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_ORG_NAME',
                             avalue    => l_org_name
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_CLAIM_TYPE',
                             avalue    => l_claim_type
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_CLAIM_DATE',
                             avalue    => l_claim_rec.claim_date
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_DUE_DATE',
                             avalue    => l_claim_rec.due_date
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_ACCOUNT_NUMBER',
                             avalue    => l_account_number
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_REASON',
                             avalue    => l_ar_reason_code
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_TRX_TYPE',
                             avalue    => l_trx_type
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_COMMENTS',
                             avalue    => l_claim_rec.comments
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_SALESREP_ID',
                             avalue    => l_claim_rec.sales_rep_id
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_SALESREP_NAME',
                             avalue    => l_salesrep_name
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_CLAIM_OWNER_NAME',
                             avalue    => l_owner_name
                           );
  --
  WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                             itemkey   => l_itemkey,
                             aname     => 'OZF_NEXT_STATUS_MEANING',
                             avalue    => l_next_status_meaning
                           );
  --
  IF p_promotional_claim = 'Y' THEN
        WF_ENGINE.SetItemAttrText( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'OZF_PROMO_CLAIM_FLAG',
                                   avalue   => 'Y'
                                  );
  END IF;

  --
  IF l_claim_rec.payment_method = 'MASS_SETTLEMENT' THEN
     OPEN csr_setl_doc(p_claim_id);
     FETCH csr_setl_doc INTO l_payment_method_code
                           , l_amount_settled;
     CLOSE csr_setl_doc;
     l_amount_settled := l_amount_settled * -1;

     OPEN csr_pmt_method(l_payment_method_code);
     FETCH csr_pmt_method INTO l_payment_method;
     CLOSE csr_pmt_method;

     --
     WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                                itemkey   => l_itemkey,
                                aname     => 'OZF_PAYMENT_METHOD',
                                avalue    => l_payment_method
                              );
     --
     WF_ENGINE.SetItemAttrText( itemtype  => l_itemtype,
                                itemkey   => l_itemkey,
                                aname     => 'OZF_PAYMENT_METHOD_CODE',
                                avalue    => l_payment_method_code
                              );
     --
     WF_ENGINE.SetItemAttrNumber( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'OZF_AMOUNT_SETTLED',
                                  avalue   => l_amount_settled
                                );
  END IF;


  --
  -- set AR Role
  -- Get more details for the current activity
  /*
  BEGIN
    Get_AR_Role(
        p_activity_id          => ,
        x_return_status        => l_return_status
    );
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT', sqlerrm || l_budget_type);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   RAISE FND_API.G_EXC_ERROR;
  END IF;
  */
  /*
  WF_ENGINE.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'OZF_RECEIVABLE_DEPT',
                            avalue    =>
                           );
  */

  --kdass - Bug 9137090 - commented since this debug message introduced junk character in the out param l_msg_data
  --OZF_Utility_PVT.debug_message('Start == Item Type:'||l_itemtype||'-- Item key:'||l_itemkey);
   BEGIN
               UPDATE ozf_claims_all
               SET cstl_wf_item_key = l_itemkey
               WHERE claim_id = p_claim_id;
         EXCEPTION
               WHEN OTHERS THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                    FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_UPD_CLAM_ERR');
                    FND_MSG_PUB.add;
                    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                    FND_MESSAGE.Set_Token('TEXT',sqlerrm);
                    FND_MSG_PUB.Add;
                 END IF;
   END;
  -------------- start the process  ---------------------
  WF_ENGINE.StartProcess( itemtype => l_itemtype,
                          itemkey  => l_itemkey
                        );
  --

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
            FND_MSG_PUB.Add;
      END IF;
      RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
            FND_MSG_PUB.Add;
      END IF;
      RAISE;
    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      RAISE;
END Start_Settlement;

------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Promo_Claim
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:YES'
--             - 'COMPLETE:NO'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CHECK_PROMO_CLAIM
---------------------------------------------------------------------------------
PROCEDURE Check_Promo_Claim(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_promo_flag    VARCHAR2(3);

-- Bug4308173
CURSOR claim_gl_posting_csr(p_id in number) IS
SELECT osp.post_to_gl
FROM   ozf_sys_parameters_all osp
,      ozf_claims_all oc
WHERE  osp.org_id = oc.org_id
AND    oc.claim_id = p_id;
l_post_to_gl VARCHAR2(1);
l_claim_id   NUMBER;

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_promo_flag := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_PROMO_CLAIM_FLAG'
                                           );

    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    OPEN claim_gl_posting_csr(l_claim_id);
    FETCH claim_gl_posting_csr INTO l_post_to_gl;
    CLOSE claim_gl_posting_csr;

    IF l_promo_flag = 'Y' AND NVL(l_post_to_gl,'F') = 'T' THEN
       resultout := 'COMPLETE:Y';
    ELSE
       resultout := 'COMPLETE:N';
    END IF;

    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Check_Promo_Claim',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Check_Promo_Claim;


------------------------------------------------------------------------------
-- PROCEDURE
--   Create_GL_Entries
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CREATE_GL_ENTRIES
---------------------------------------------------------------------------------
PROCEDURE Create_GL_Entries(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(400);
l_msg_count        NUMBER;
l_api_version  CONSTANT NUMBER         := 1.0;
l_event_id              NUMBER;
l_ccid                    NUMBER;

l_claim_id         NUMBER;
l_claim_class    VARCHAR2(30);
l_payment_method  VARCHAR2(30);

l_error_msg        VARCHAR2(4000);

BEGIN

  SAVEPOINT  Create_GL_Entries;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    l_payment_method := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'OZF_PAYMENT_METHOD_CODE'
                                           );

    l_claim_class   :=  WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'OZF_CLAIM_CLASS'
                           );
    -- ER#9382547 ChRM-SLA Uptake: Removed the Event_ID, x_clear_code_combination_id
    -- Out Parameter and claim_class as IN Parameter
    OZF_GL_INTERFACE_PVT.Post_Claim_To_GL(
               p_api_version    =>  1.0,
               x_return_status  =>  l_return_status,
               x_msg_data       =>  l_msg_data,
               x_msg_count      =>  l_msg_count,
               p_claim_id       =>  l_claim_id,
               p_settlement_method   => l_payment_method
               );
    IF l_return_status <> FND_API.g_ret_sts_success  THEN
      RAISE ERROR;
    ELSE
      resultout := 'COMPLETE:SUCCESS';
    END IF;
    RETURN;
  END IF;

  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     ROLLBACK TO Create_GL_Entries;
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'Create_GL_Entrie'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'Create_GL_Entries'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;

  WHEN OTHERS THEN
    ROLLBACK TO Create_GL_Entries;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Create_GL_Entries',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Create_GL_Entries;


------------------------------------------------------------------------------
-- PROCEDURE
--   Revert_GL_Entries
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
---------------------------------------------------------------------------------
PROCEDURE Revert_GL_Entries(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(400);
l_msg_count        NUMBER;
l_api_version  CONSTANT NUMBER         := 1.0;
l_event_id              NUMBER;
l_ccid                    NUMBER;

l_claim_id         NUMBER;
l_error_msg        VARCHAR2(4000);

BEGIN
  SAVEPOINT Revert_GL_Entries;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );


    /*OZF_GL_INTERFACE_PVT.Revert_GL_Entry (
                   p_api_version    =>  1.0,
           x_return_status  =>  l_return_status,
           x_msg_data       =>  l_msg_data,
           x_msg_count      =>  l_msg_count,
           p_claim_id       =>  l_claim_id
           );
           */

    --ER#9382547    ChRM-SLA Uptake
    -- For Reverting the GL entry,need to pass the
    -- reversal event type for the corresponding claim_id
    OZF_GL_INTERFACE_PVT.Post_Claim_To_GL (
    p_api_version         => 1.0
   ,p_init_msg_list       =>FND_API.G_FALSE
   ,p_commit              => FND_API.G_FALSE
   ,p_validation_level    =>FND_API.G_VALID_LEVEL_FULL
   ,x_return_status       =>l_return_status
   ,x_msg_data            =>l_msg_data
   ,x_msg_count           =>l_msg_count
   ,p_claim_id           => l_claim_id
   ,p_settlement_method  => 'CLAIM_SETTLEMENT_REVERSAL'
    );

    IF l_return_status <> FND_API.g_ret_sts_success  THEN
      RAISE ERROR;
    END IF;
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     ROLLBACK TO Revert_GL_Entries;
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'Revert_GL_Entries'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'Revert_GL_Entries'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     RAISE;

  WHEN OTHERS THEN
    ROLLBACK TO Revert_GL_Entries;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Revert_GL_Entries',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Revert_GL_Entries;


------------------------------------------------------------------------------
-- PROCEDURE
--   Create_Payment
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:SUCCESS'
--             - 'COMPLETE:ERROR'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CREATE_PAYMENT
---------------------------------------------------------------------------------
PROCEDURE Create_Payment(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_return_status    VARCHAR2(1);
l_msg_data         VARCHAR2(4000);
l_msg_count        NUMBER;

l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Payment_for_Settlement';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_claim_id         NUMBER;
l_object_version   NUMBER;
l_org_id           NUMBER;
l_error_msg        VARCHAR2(4000);
l_payment_method   VARCHAR2(30);

CURSOR csr_claim_version(cv_claim_id IN NUMBER) IS
  SELECT object_version_number
  ,      org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;

CURSOR csr_claim_settle(cv_claim_id IN NUMBER) IS
  SELECT claim_number
  ,      settled_date
  ,      vendor_id
  ,      vendor_site_id
  ,      amount_settled
  ,      currency_code
  ,      exchange_rate
  ,      exchange_rate_type
  ,      exchange_rate_date
  ,      payment_method
  ,      set_of_books_id
  ,      gl_date
  ,      claim_class
  ,      payment_reference_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;


l_claim_settle        csr_claim_settle%ROWTYPE;
l_payment_term        NUMBER;
l_settlement_doc_rec  OZF_SETTLEMENT_DOC_PVT.settlement_doc_rec_type;
l_automate_settlement VARCHAR2(1);
BEGIN
  SAVEPOINT create_payment;
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_id := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_ID'
                                           );

    l_payment_method := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'OZF_PAYMENT_METHOD_CODE'
                                           );

    OPEN csr_claim_version(l_claim_id);
    FETCH csr_claim_version INTO l_object_version
                               , l_org_id;
    CLOSE csr_claim_version;


    OPEN csr_claim_settle(l_claim_id);
    FETCH csr_claim_settle INTO l_claim_settle;
    CLOSE csr_claim_settle;


    --------------------------- CHECK -----------------------------
    IF l_claim_settle.payment_method in ( 'CHECK','EFT','WIRE', 'AP_DEBIT','AP_DEFAULT') THEN
      -- create AP invoice
      OZF_AP_INTERFACE_PVT.Create_AP_Invoice (
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => l_msg_data
         ,x_msg_count              => l_msg_count
         ,p_claim_id               => l_claim_id
      );
      IF l_return_status <> FND_API.g_ret_sts_success  THEN
        RAISE ERROR;
      ELSE
        resultout := 'COMPLETE:SUCCESS';
      END IF;

    ----------------------- CREDIT_MEMO -----------------------------
    ELSIF l_claim_settle.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO') THEN
      OZF_AR_PAYMENT_PVT.Create_AR_Payment(
                      p_api_version            => l_api_version
                     ,p_init_msg_list          => FND_API.g_false
                     ,p_commit                 => FND_API.g_false
                     ,p_validation_level       => FND_API.g_valid_level_full
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => l_msg_data
                     ,x_msg_count              => l_msg_count
                     ,p_claim_id               => l_claim_id
       );
       IF l_return_status <> FND_API.g_ret_sts_success THEN
           RAISE ERROR;
       ELSE
           resultout := 'COMPLETE:SUCCESS';
       END IF;
    ELSE
          resultout := 'COMPLETE:ERROR';
    END IF;
    RETURN;
  END IF;
  -- end RUN mode



  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN ERROR THEN
     ROLLBACK TO create_payment;
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     Handle_Error(
         p_itemtype     => itemtype
        ,p_itemkey      => itemkey
        ,p_msg_count    => l_msg_count
        ,p_msg_data     => l_msg_data
        ,p_process_name => 'CREATE_PAYMENT'
        ,x_error_msg    => l_error_msg
     );
     WF_CORE.context(
         'OZF_AR_SETTLEMENT_PVT'
        ,'CREATE_PAYMENT'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:ERROR';
     RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO create_payment;
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Create_Payment',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Create_Payment;


------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Claim_Class
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:MANUAL'
--             - 'COMPLETE:AUTO'
--             - 'COMPLETE:END'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    CHECK_CLAIM_CLASS
---------------------------------------------------------------------------------
PROCEDURE Check_Claim_Class(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_claim_class     VARCHAR2(30);

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_claim_class := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'OZF_CLAIM_CLASS'
                                           );
    IF l_claim_class = 'CLAIM' THEN
       resultout := 'COMPLETE:CLAIM';
    ELSE
       resultout := 'COMPLETE:DEDUCTION';
    END IF;
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Check_Claim_Class',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Check_Claim_Class;



PROCEDURE Handle_Error(
    p_itemtype                 IN  VARCHAR2,
    p_itemkey                  IN  VARCHAR2,
    p_msg_count                IN  NUMBER,
    p_msg_data                 IN  VARCHAR2,
    p_process_name             IN  VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
)
IS
l_msg_count            NUMBER ;
l_msg_data             VARCHAR2(2000);
l_final_msg            VARCHAR2(4000);
l_msg_index            NUMBER ;
l_err_subj             VARCHAR2(240);
l_claim_number         VARCHAR2(30);


BEGIN
   l_claim_number := WF_ENGINE.GetItemAttrText(
                           itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname    => 'OZF_CLAIM_NUMBER'
                     );

   FND_MESSAGE.set_name ('OZF', 'OZF_SETL_WF_NTF_ERR');
   FND_MESSAGE.set_token ('CLAIM', l_claim_number, FALSE);

   l_err_subj := SUBSTR(FND_MESSAGE.get, 1, 240);

   Wf_Engine.SetItemAttrText(
       itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => 'OZF_CSETL_ERR_SUBJ',
       avalue     => l_err_subj );

   FOR i IN 1..p_msg_count LOOP
      FND_MSG_PUB.get(
         p_msg_index       => i,
         p_encoded         => FND_API.g_false,
         p_data            => l_msg_data,
         p_msg_index_out   => l_msg_index
      );
      l_final_msg := l_final_msg ||
                     l_msg_index ||
                     ': ' ||
                     l_msg_data ||
                     fnd_global.local_chr(10);
   END LOOP ;

   x_error_msg   := l_final_msg;

   WF_ENGINE.SetItemAttrText(
       itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => 'OZF_CSETL_ERR_MSG',
       avalue     => l_final_msg
   );
END Handle_Error;


PROCEDURE Check_Payment_Method(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout   OUT NOCOPY VARCHAR2
)
IS
l_payment_method       VARCHAR2(15);

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- get claim_id
    l_payment_method := WF_ENGINE.GetItemAttrText(
                             itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'OZF_PAYMENT_METHOD_CODE'
                        );

    IF l_payment_method IN ( 'CHECK'
                           , 'CONTRA_CHARGE'
                           , 'CREDIT_MEMO'
                           , 'REG_CREDIT_MEMO'
                           , 'CHARGEBACK'
                           , 'WRITE_OFF'
                           , 'DEBIT_MEMO'
                           , 'ON_ACCT_CREDIT'
                           , 'RMA'
                           , 'EFT'
                           , 'WIRE'
                           , 'AP_DEBIT'
                           , 'AP_DEFAULT'
                           ) THEN
       WF_ENGINE.SetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'OZF_CSETL_TYPE',
            avalue    => 'SEEDED'
       );
       resultout := 'COMPLETE:Y';
    ELSE
       WF_ENGINE.SetItemAttrText(
            itemtype  => itemtype,
            itemkey   => itemkey,
            aname     => 'OZF_CSETL_TYPE',
            avalue    => 'ADHOC'
       );
       resultout := 'COMPLETE:N';
    END IF;
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    --resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        --resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'CHECK_PAYMENT_METHOD',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Check_Payment_Method;


PROCEDURE Prepare_Docs(
    itemtype       IN  VARCHAR2,
    itemkey        IN  VARCHAR2,
    actid          IN  NUMBER,
    funcmode       IN  VARCHAR2,
    resultout      OUT NOCOPY VARCHAR2
)
IS
l_next_status          VARCHAR2(30);

BEGIN

  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    -- Transaction Identifier
    WF_ENGINE.SetItemAttrNumber( itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'OZF_TRX_ID_1',
                                 avalue    => 1001
                               );
    -- Transaction Type
    WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'OZF_TRX_TYPE_1',
                               avalue    => 'CM'
                             );
    -- Transaction Number
    WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'OZF_TRX_NUMBER_1',
                               avalue    => 'TST-1001'
                             );
    -- Transaction Date
    WF_ENGINE.SetItemAttrDate( itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'OZF_TRX_DATE_1',
                               avalue    => SYSDATE
                             );
    -- Transaction Amount
    WF_ENGINE.SetItemAttrNumber( itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'OZF_TRX_AMOUNT_1',
                                 avalue    => 123456
                               );
    -- Transaction Status
    WF_ENGINE.SetItemAttrText( itemtype  => itemtype,
                               itemkey   => itemkey,
                               aname     => 'OZF_TRX_STATUS_1',
                               avalue    => 'PAID'
                             );

    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Prepare_Docs',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Prepare_Docs;


------------------------------------------------------------------------------
-- PROCEDURE
--   Check_Auto_Setl_Process
--
--   Workflow cover:
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:YES'
--             - 'COMPLETE:NO'
--
-- USED BY ACTIVITIES
--   <ITEM_TYPE>              <ACTIVITY>
--   OZF_AR_SETTLEMENT_PVT    OZF_CHECK_PROMO_CLAIM
---------------------------------------------------------------------------------
PROCEDURE Check_Auto_Setl_Process(
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2
)
IS
l_automate_settlement VARCHAR2(1);
l_claim_class         VARCHAR2(30);
l_payment_method      VARCHAR2(30);

BEGIN
  ---- RUN mode ----
  IF (funcmode = 'RUN') THEN
    l_claim_class := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_CLAIM_CLASS'
                                              );

    l_payment_method := WF_ENGINE.GetItemAttrText( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'OZF_PAYMENT_METHOD_CODE'
                                                 );


   -- Modified for Bug4241187: Support for additional methods.
   IF l_payment_method = 'CONTRA_CHARGE' THEN
         resultout := 'COMPLETE:N';
   ELSIF l_payment_method in ( 'RMA', 'REG_CREDIT_MEMO') THEN
         resultout := 'COMPLETE:N';
         -- Bug4308173: This check always evaluates to N
         -- For RMA, WF is launched only when automate settlement is N
         -- For REG_CREDIT_MEMO, WF is launched when automate settlement is N or
         --    when settlement should be done by receivable role.
   ELSIF l_payment_method in ( 'CHECK','EFT','WIRE','AP_DEBIT','AP_DEFAULT') THEN
         resultout := 'COMPLETE:Y';
   ELSIF l_payment_method in ('CREDIT_MEMO','DEBIT_MEMO' ) THEN
         l_automate_settlement := NVL(FND_PROFILE.value('OZF_CLAIM_USE_AR_AUTOMATION'), 'Y');
         IF l_automate_settlement = 'Y' THEN
             resultout := 'COMPLETE:Y';
         ELSE
             resultout := 'COMPLETE:N';
         END IF;
   ELSE
         resultout := 'COMPLETE:N';
   END IF;

   RETURN;
  END IF;  -- end RUN mode

  ---- CANCEL mode -----
  IF (funcmode = 'CANCEL') THEN
    resultout := 'COMPLETE:';
    RETURN;
  END IF;
  --
  ---- TIMEOUT mode ----
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context(
        'OZF_AR_SETTLEMENT_PVT',
        'Check_Auto_Setl_Process',
        itemtype,
        itemkey,
        to_char(actid),
        funcmode
    );
    RAISE;
END Check_Auto_Setl_Process;

END OZF_AR_SETTLEMENT_PVT;

/
