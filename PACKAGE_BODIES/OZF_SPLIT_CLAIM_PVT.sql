--------------------------------------------------------
--  DDL for Package Body OZF_SPLIT_CLAIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SPLIT_CLAIM_PVT" AS
/* $Header: ozfvspcb.pls 120.4.12010000.4 2009/01/27 08:04:29 ateotia ship $ */

----------- Define private data type -----------------------------
TYPE Simple_line_type IS RECORD (
     claim_line_id                   NUMBER,
     object_version_number           NUMBER
);

TYPE Simple_line_tbl_type IS TABLE of Simple_line_type
                 INDEX BY BINARY_INTEGER;

TYPE Child_Claim_int_type IS RECORD (
     claim_id                        NUMBER,
     object_version_number           NUMBER,
     claim_type_id                   NUMBER,
     amount                          NUMBER,
     line_amount_sum                 NUMBER,
     reason_code_id                  NUMBER,
     parent_claim_id                 NUMBER
);


----------- Define Private Constant -----------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_split_claim_PVT';
G_OPEN_STATUS   CONSTANT VARCHAR2(30) := 'OPEN';
G_CLOSE_STATUS   CONSTANT VARCHAR2(30) := 'CLOSED';
G_PENDING_CLOSE_STATUS   CONSTANT VARCHAR2(30) := 'PENDING_CLOSE';
G_CLAIM_STATUS  CONSTANT VARCHAR2(30) := 'OZF_CLAIM_STATUS';
G_NO_CHANGE_EVENT CONSTANT VARCHAR2(30) := 'NOCHANGE';
G_SPLIT_EVENT   CONSTANT VARCHAR2(30) := 'SPLIT';
G_UPDATE_EVENT  CONSTANT VARCHAR2(30) := 'UPDATE';
G_CLAIM_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'CLAM';

----------- Define session related variables --------------------
g_history_created boolean := false;

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
-- PROCEDURE
--    create_child_claim
--
-- PURPOSE
--    Split a child claim
--
-- PARAMETERS
--    p_claim    : the new claim to be created.
--    p_line_tbl : the table of lines associated with this new claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE create_child_claim (
    p_claim                  IN    child_claim_int_type
   ,p_line_tbl               IN    Simple_line_tbl_type
   ,x_return_status          OUT NOCOPY   VARCHAR2
)
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Create_Child_Claim';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;
l_claim_id             NUMBER;
l_child_claim          OZF_CLAIM_PVT.claim_rec_type;
l_claim_line           OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_line_obj_num         NUMBER;
l_open_status_id       NUMBER;
l_split_status_type    VARCHAR2(30);

CURSOR parent_claim_csr(p_id in number) IS
SELECT *
FROM   OZF_CLAIMS_ALL
WHERE  claim_id = p_id;
l_parent_claim    parent_claim_csr%ROWTYPE;

-- [BEGIN OF BUG 3473501 FIXING]
Type access_list_tbl_type IS TABLE OF AMS_ACCESS_PVT.ACCESS_REC_TYPE
INDEX BY BINARY_INTEGER;
l_access_list_tbl      access_list_tbl_type;
l_access_id            NUMBER;
i                      NUMBER := 1;

CURSOR parent_claim_act_access( pv_parent_claim_id IN NUMBER
                              , pv_child_claim_id IN NUMBER
                              ) IS
  SELECT user_or_role_id
  ,      arc_user_or_role_type
  ,      admin_flag
  ,      owner_flag
  FROM ams_act_access
  WHERE arc_act_access_to_object = 'CLAM'
  AND act_access_to_object_id = pv_parent_claim_id
  MINUS
  SELECT user_or_role_id
  ,      arc_user_or_role_type
  ,      admin_flag
  ,      owner_flag
  FROM ams_act_access
  WHERE arc_act_access_to_object = 'CLAM'
  AND act_access_to_object_id = pv_child_claim_id;
-- [END OF BUG 3473501 FIXING]

BEGIN
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start Creation.
    -- setup the data for claim and then call create_claim package.
    -- get the parent claim record

    OPEN parent_claim_csr(p_claim.parent_claim_id);
    FETCH parent_claim_csr INTO l_parent_claim;
    CLOSE parent_claim_csr;

    -- assign the value of the parent to the child claim.
    IF p_claim.claim_type_id is NULL THEN
       l_child_claim.claim_type_id       := l_parent_claim.claim_type_id;
    ELSE
       l_child_claim.claim_type_id       := p_claim.claim_type_id;
    END IF;
    l_child_claim.split_from_claim_id := p_claim.parent_claim_id;
    l_child_claim.duplicate_claim_id  := null;
    l_child_claim.split_date          := sysdate;
    l_child_claim.amount              := p_claim.amount;
    IF p_claim.reason_code_id is NULL THEN
        l_child_claim.reason_code_id  := l_parent_claim.reason_code_id;
    ELSE
       l_child_claim.reason_code_id   := p_claim.reason_code_id;
    END IF;

    --//Bugfix: 7584669
    l_split_status_type := NVL(FND_PROFILE.value('OZF_DEFAULT_CHILD_CLAIM_STATUS'),'PARENT');

    IF l_split_status_type = 'PARENT' THEN
       l_open_status_id := l_parent_claim.open_status_id;
    ELSE
       l_open_status_id := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                       P_STATUS_TYPE=> G_CLAIM_STATUS,
                                       P_STATUS_CODE=> G_OPEN_STATUS));
    END IF;
    --//End

    l_child_claim.user_status_id      := l_open_status_id;
    l_child_claim.open_status_id      := l_open_status_id;

    l_child_claim.batch_id            := l_parent_claim.batch_id;
    l_child_claim.claim_class         := l_parent_claim.claim_class;
    l_child_claim.claim_date          := l_parent_claim.claim_date;
    l_child_claim.due_date            := l_parent_claim.due_date;
    l_child_claim.owner_id            := l_parent_claim.owner_id;
    l_child_claim.root_claim_id       := l_parent_claim.root_claim_id;
--    l_child_claim.tax_amount          := l_parent_claim.tax_amount;
    l_child_claim.tax_code            := l_parent_claim.tax_code;
    l_child_claim.order_type_id       := l_parent_claim.order_type_id;  -- fixed for  4946978
--    l_child_claim.tax_calculation_flag := l_parent_claim.tax_calculation_flag;
    l_child_claim.currency_code       := l_parent_claim.currency_code;
    l_child_claim.exchange_rate_type  := l_parent_claim.exchange_rate_type;
    l_child_claim.exchange_rate_date  := l_parent_claim.exchange_rate_date;
    l_child_claim.exchange_rate       := l_parent_claim.exchange_rate;
    l_child_claim.set_of_books_id     := l_parent_claim.set_of_books_id;
    l_child_claim.original_claim_date := l_parent_claim.claim_date;
    l_child_claim.source_object_id    := l_parent_claim.source_object_id;
    l_child_claim.source_object_class := l_parent_claim.source_object_class;
    l_child_claim.source_object_type_id := l_parent_claim.source_object_type_id;
    l_child_claim.source_object_number:= l_parent_claim.source_object_number;
    l_child_claim.cust_account_id     := l_parent_claim.cust_account_id;
    l_child_claim.cust_billto_acct_site_id := l_parent_claim.cust_billto_acct_site_id;
    l_child_claim.cust_shipto_acct_site_id := l_parent_claim.cust_shipto_acct_site_id;
    l_child_claim.location_id         := l_parent_claim.location_id;
    l_child_claim.pay_related_account_flag := l_parent_claim.pay_related_account_flag;
    l_child_claim.related_cust_account_id:= l_parent_claim.related_cust_account_id;
    l_child_claim.related_site_use_id := l_parent_claim.related_site_use_id;
    l_child_claim.relationship_type   := l_parent_claim.relationship_type;
    l_child_claim.vendor_id           := l_parent_claim.vendor_id;
    l_child_claim.vendor_site_id      := l_parent_claim.vendor_site_id;
    l_child_claim.reason_type         := l_parent_claim.reason_type;
    l_child_claim.sales_rep_id        := l_parent_claim.sales_rep_id;
    l_child_claim.collector_id        := l_parent_claim.collector_id;
    l_child_claim.contact_id          := l_parent_claim.contact_id;
    l_child_claim.broker_id           := l_parent_claim.broker_id;
    l_child_claim.territory_id        := l_parent_claim.territory_id;
    l_child_claim.customer_ref_date   := l_parent_claim.customer_ref_date;
    l_child_claim.customer_ref_number := l_parent_claim.customer_ref_number;
    l_child_claim.assigned_to         := l_parent_claim.assigned_to;
    l_child_claim.receipt_id          := l_parent_claim.receipt_id;
    l_child_claim.receipt_number      := l_parent_claim.receipt_number;
    l_child_claim.doc_sequence_id     := l_parent_claim.doc_sequence_id;
    l_child_claim.doc_sequence_value  := l_parent_claim.doc_sequence_value;
--    l_child_claim.gl_date             := l_parent_claim.gl_date;
    l_child_claim.payment_method      := l_parent_claim.payment_method;
    l_child_claim.voucher_id          := l_parent_claim.voucher_id;
    l_child_claim.voucher_number      := l_parent_claim.voucher_number;
    l_child_claim.payment_reference_id:= l_parent_claim.payment_reference_id;
    l_child_claim.payment_reference_number:= l_parent_claim.payment_reference_number;
    l_child_claim.payment_reference_date  := l_parent_claim.payment_reference_date;
--    l_child_claim.payment_status      := l_parent_claim.payment_status;
--    l_child_claim.approved_flag       := l_parent_claim.approved_flag;
--    l_child_claim.approved_date       := l_parent_claim.approved_date;
--    l_child_claim.approved_by         := l_parent_claim.approved_by;
--    l_child_claim.settled_date        := l_parent_claim.settled_date;
--    l_child_claim.settled_by          := l_parent_claim.settled_by;
    l_child_claim.effective_date      := l_parent_claim.effective_date;
    l_child_claim.custom_setup_id     := l_parent_claim.custom_setup_id;
    l_child_claim.task_id             := l_parent_claim.task_id;
    l_child_claim.country_id          := l_parent_claim.country_id;
    l_child_claim.comments            := l_parent_claim.comments;
    l_child_claim.attribute_category  := l_parent_claim.attribute_category;
    l_child_claim.attribute1          := l_parent_claim.attribute1;
    l_child_claim.attribute2          := l_parent_claim.attribute2;
    l_child_claim.attribute3          := l_parent_claim.attribute3;
    l_child_claim.attribute4          := l_parent_claim.attribute4;
    l_child_claim.attribute5          := l_parent_claim.attribute5;
    l_child_claim.attribute6          := l_parent_claim.attribute6;
    l_child_claim.attribute7          := l_parent_claim.attribute7;
    l_child_claim.attribute8          := l_parent_claim.attribute8;
    l_child_claim.attribute9          := l_parent_claim.attribute9;
    l_child_claim.attribute10         := l_parent_claim.attribute10;
    l_child_claim.attribute11         := l_parent_claim.attribute11;
    l_child_claim.attribute12         := l_parent_claim.attribute12;
    l_child_claim.attribute13         := l_parent_claim.attribute13;
    l_child_claim.attribute14         := l_parent_claim.attribute14;
    l_child_claim.attribute15         := l_parent_claim.attribute15;
    l_child_claim.deduction_attribute_category := l_parent_claim.deduction_attribute_category;
     l_child_claim.deduction_attribute1 := l_parent_claim.deduction_attribute1;
    l_child_claim.deduction_attribute2 := l_parent_claim.deduction_attribute2;
    l_child_claim.deduction_attribute3 := l_parent_claim.deduction_attribute3;
    l_child_claim.deduction_attribute4 := l_parent_claim.deduction_attribute4;
    l_child_claim.deduction_attribute5 := l_parent_claim.deduction_attribute5;
    l_child_claim.deduction_attribute6 := l_parent_claim.deduction_attribute6;
    l_child_claim.deduction_attribute7 := l_parent_claim.deduction_attribute7;
    l_child_claim.deduction_attribute8 := l_parent_claim.deduction_attribute8;
    l_child_claim.deduction_attribute9 := l_parent_claim.deduction_attribute9;
    l_child_claim.deduction_attribute10 := l_parent_claim.deduction_attribute10;
    l_child_claim.deduction_attribute11 := l_parent_claim.deduction_attribute11;
    l_child_claim.deduction_attribute12 := l_parent_claim.deduction_attribute12;
    l_child_claim.deduction_attribute13 := l_parent_claim.deduction_attribute13;
    l_child_claim.deduction_attribute14 := l_parent_claim.deduction_attribute14;
    l_child_claim.deduction_attribute15 := l_parent_claim.deduction_attribute15;
    l_child_claim.org_id              := l_parent_claim.org_id;


    OZF_claim_PVT.Create_Claim(
         P_Api_Version        => 1.0,
         P_Init_Msg_List      => FND_API.G_FALSE,
         P_Commit             => FND_API.G_FALSE,
         P_Validation_Level   => FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status      => l_return_status,
         X_Msg_Count          => l_msg_count,
         X_Msg_Data           => l_msg_data,
         P_claim              => l_child_claim,
         X_CLAIM_ID           => l_claim_id
      );

    IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
    END IF;

IF OZF_DEBUG_HIGH_ON THEN
   ozf_utility_PVT.debug_message('new claim id '|| l_claim_id);
END IF;

    -- For each claim_line_id, update the claim_line
    FOR i in 1..p_line_tbl.COUNT LOOP
        -- build a record to update in claim lines table.
        OZF_CLAIM_LINE_PVT.Init_Claim_Line_Rec(x_claim_line_rec => l_claim_line);
        l_claim_line.claim_line_id         := p_line_tbl(i).claim_line_id;
        l_claim_line.object_version_number := p_line_tbl(i).object_version_number;
        l_claim_line.claim_id              := l_claim_id;

        OZF_CLAIM_LINE_PVT.Update_Claim_Line(
           p_api_version       => l_api_version
          ,p_init_msg_list     => FND_API.g_false
          ,p_commit            => FND_API.g_false
          ,p_validation_level  => FND_API.g_valid_level_full
          ,x_return_status     => l_return_status
          ,x_msg_count         => l_msg_count
          ,x_msg_data          => l_msg_data
          ,p_claim_line_rec    => l_claim_line
                         ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
          ,x_object_version    => l_line_obj_num
       );

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END LOOP;


    -- [BEGIN OF BUG 3473501 FIXING]
    OPEN parent_claim_act_access(p_claim.parent_claim_id, l_claim_id);
    LOOP
       FETCH parent_claim_act_access INTO  l_access_list_tbl(i).user_or_role_id
                                        ,  l_access_list_tbl(i).arc_user_or_role_type
                                        ,  l_access_list_tbl(i).admin_flag
                                        ,  l_access_list_tbl(i).owner_flag;
       EXIT WHEN parent_claim_act_access%NOTFOUND;
       l_access_list_tbl(i).arc_act_access_to_object := 'CLAM';
       l_access_list_tbl(i).act_access_to_object_id := l_claim_id;
       i := i + 1;
    END LOOP;
    CLOSE parent_claim_act_access;

    IF l_access_list_tbl.COUNT > 0 THEN
       FOR i IN 1..l_access_list_tbl.LAST LOOP
          AMS_ACCESS_PVT.Create_Access(
               p_api_version      => l_api_version
              ,p_init_msg_list    => FND_API.G_FALSE
              ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
              ,x_return_status    => l_return_status
              ,x_msg_count        => l_msg_count
              ,x_msg_data         => l_msg_data
              ,p_commit           => FND_API.G_FALSE
              ,p_access_rec       => l_access_list_tbl(i)
              ,x_access_id        => l_access_id
          );
          IF l_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
       END LOOP;
    END IF;
    -- [END OF BUG 3473501 FIXING]


    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END create_child_claim;

---------------------------------------------------------------------
-- PROCEDURE
--    update_child_claim
--
-- PURPOSE
--    Update a child claim
--
-- PARAMETERS
--    p_claim    : the claim to be update.
--    p_line_tbl : the table of lines associated with this claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE update_child_claim (
    p_claim                  IN    child_claim_int_type
   ,p_line_tbl               IN    Simple_line_tbl_type
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_new_claim_amount       OUT NOCOPY   NUMBER
)
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Update_Child_Claim';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;
l_child_claim          OZF_CLAIM_PVT.claim_rec_type;
l_claim_line           OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_line_obj_num         NUMBER;

l_object_version_number  NUMBER;

CURSOR version_csr (p_id in number) IS
SELECT object_version_number
FROM   ozf_claims_all
WHERE  claim_id = p_id;

CURSOR status_code_csr(p_id in number) IS
SELECT status_code
FROM   ozf_claims_all
WHERE  claim_id = p_id;
l_status_code   VARCHAR(30);

CURSOR line_amount_sum_csr(p_id in number) IS
/* BEGIN FIX BUG : split amount becomes null after updating split claim.*/
--SELECT SUM(claim_currency_amount)
SELECT NVL(SUM(claim_currency_amount), 0)
/* END FIX BUG : while calculating claim amount, line_sume_amount should set to 0 if it is null.*/
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;
l_line_amount_sum  number;
l_diff_amount      number;

BEGIN
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN version_csr(p_claim.claim_id);
    FETCH version_csr INTO l_object_version_number;
    CLOSE version_csr;

    IF p_claim.object_version_number = l_object_version_number THEN
       BEGIN
         -- We will do some checking before updating the claim
         OPEN status_code_csr(p_claim.claim_id);
         FETCH status_code_csr INTO l_status_code;
         CLOSE status_code_csr;

              IF l_status_code = G_OPEN_STATUS THEN
                 -- Get the line amount before update
                 OPEN line_amount_sum_csr(p_claim.claim_id);
                 FETCH line_amount_sum_csr into l_line_amount_sum;
                 CLOSE line_amount_sum_csr;

            -- To get the new amount, I first get the difference between claim_amount and sum( old line amount)
            -- Then, I add this difference to the sum(new line amount), which is obtained from the screen.
            -- Here p_claim.amount is the old amount, since we don't update it on screen.
            l_diff_amount := p_claim.amount - l_line_amount_sum;
            l_child_claim.claim_id              := p_claim.claim_id;
            l_child_claim.object_version_number := p_claim.object_version_number;
            IF p_claim.line_amount_sum is not null THEN
               l_child_claim.amount                := l_diff_amount + p_claim.line_amount_sum;
            ELSE
               l_child_claim.amount                 := l_diff_amount;
            END IF;

            OZF_claim_PVT.Update_Claim (
               p_api_version       => l_api_version
              ,p_init_msg_list     => FND_API.G_FALSE
              ,p_commit            => FND_API.G_FALSE
              ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
              ,x_return_status     => l_return_status
              ,x_msg_data          => l_msg_data
              ,x_msg_count         => l_msg_count
              ,p_claim             => l_child_claim
              ,p_event             => G_UPDATE_EVENT
                                  ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
              ,x_object_version_number  => l_object_version_number
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            x_new_claim_amount := l_child_claim.amount;

            -- Now update the lines.
            -- For each claim_line_id, update the claim_line
            FOR i in 1..p_line_tbl.COUNT LOOP
                -- build a record to update in claim lines table.
                OZF_CLAIM_LINE_PVT.Init_Claim_Line_Rec(x_claim_line_rec => l_claim_line);
                l_claim_line.claim_line_id         := p_line_tbl(i).claim_line_id;
                l_claim_line.object_version_number := p_line_tbl(i).object_version_number;
                l_claim_line.claim_id              := p_claim.claim_id;

               OZF_CLAIM_LINE_PVT.Update_Claim_Line(
                 p_api_version       => l_api_version
                ,p_init_msg_list     => FND_API.g_false
                ,p_commit            => FND_API.g_false
                ,p_validation_level  => FND_API.g_valid_level_full
                ,x_return_status     => l_return_status
                ,x_msg_count         => l_msg_count
                ,x_msg_data          => l_msg_data
                ,p_claim_line_rec    => l_claim_line
                ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
                ,x_object_version    => l_line_obj_num
              );

              IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
            END LOOP;
         ELSE
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_WRONG_SPLIT_STATUS');
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

       EXCEPTION
          WHEN OTHERS THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
          END;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_REC_VERSION_CHANGED');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END update_child_claim;

---------------------------------------------------------------------
-- PROCEDURE
--    update_parent_claim
--
-- PURPOSE
--    update parent claim
--
-- PARAMETERS
--    p_claim    : the parent claim to be updated.
--    p_mode     : mode of the opreation. It's to indicate whether the caller is from UI or API.
--    p_line_tbl : the table of lines associated with the parent claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE update_parent_claim (
    p_claim                  IN    parent_claim_type
   ,p_mode                   IN VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   )
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Update_Parent_Claim';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;

l_claim                OZF_CLAIM_PVT.claim_rec_type;
l_claim_line           OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_line_obj_num         NUMBER;

CURSOR claim_info_csr (p_id in number) IS
SELECT object_version_number, status_code, amount_adjusted, amount_remaining, currency_code, reason_code_id
FROM   ozf_claims_all
WHERE  claim_id = p_id;
l_object_version_number  NUMBER;
l_status_code varchar2(30);
l_amount_adjusted number;
l_amount_remaining number;
l_currency_code varchar2(15);
l_reason_code_id number;


BEGIN
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;
    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_pvt.debug_message('start update parent');
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN claim_info_csr(p_claim.claim_id);
    FETCH claim_info_csr INTO l_object_version_number, l_status_code
        , l_amount_adjusted, l_amount_remaining, l_currency_code, l_reason_code_id;
    CLOSE claim_info_csr;

    IF l_amount_adjusted is null THEN
       l_amount_adjusted := 0;
    END IF;

    IF p_claim.object_version_number = l_object_version_number THEN
        -- A claim has to be in the open status or close stasut with amount_remaining not zero to be split.
       IF ((l_status_code = G_OPEN_STATUS) OR
           (l_status_code = G_PENDING_CLOSE_STATUS AND
            ABS(l_amount_remaining) > 0 AND
            p_mode = OZF_claim_Utility_pvt.G_AUTO_MODE))THEN


         -- build the record to call update_claim
         l_claim.claim_id              := p_claim.claim_id;
         l_claim.object_version_number := p_claim.object_version_number;
         l_claim.reason_code_id        := l_reason_code_id;

         IF p_claim.amount_adjusted is not null THEN
            l_claim.amount_adjusted       := l_amount_adjusted + p_claim.amount_adjusted;
         ELSE
            l_claim.amount_adjusted       := l_amount_adjusted;
         END IF;

         IF ((l_amount_remaining > 0) and
            (l_amount_remaining -OZF_UTILITY_PVT.CurrRound(p_claim.amount_adjusted, l_currency_code)< 0)) THEN
           IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_SPLT_NG_NOPM');
              FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF ((l_amount_remaining < 0) and
            (l_amount_remaining - OZF_UTILITY_PVT.CurrRound(p_claim.amount_adjusted, l_currency_code) > 0)) THEN
            IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_SPLIT_PO_OPM');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         OZF_claim_PVT.Update_Claim (
           p_api_version       => l_api_version
          ,p_init_msg_list     => FND_API.G_FALSE
          ,p_commit            => FND_API.G_FALSE
          ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status     => l_return_status
          ,x_msg_data          => l_msg_data
          ,x_msg_count         => l_msg_count
          ,p_claim             => l_claim
          ,p_event             => G_NO_CHANGE_EVENT
          ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
          ,x_object_version_number  => l_object_version_number
         );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
       ELSE
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_WRONG_SPLIT_STATUS');
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
       END IF;
    ELSE
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_REC_VERSION_CHANGED');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END update_parent_claim;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Split_Condition
--
-- PURPOSE
--    Check_Split_Condition
--
-- PARAMETERS
--    p_claim_id : the parent claim to be updated.
--
-- NOTES
--   This procedure check whether the parent claim's amount condition still
--   holds after all the child claims are created.
----------------------------------------------------------------------
PROCEDURE Check_Split_Condition (
    p_claim_id               IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   )
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Check_Split_Condition';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;

CURSOR amount_csr(p_id in NUMBER) IS
SELECT amount_remaining
FROM   ozf_claims_all
WHERE  claim_id = p_id;
l_parent_amount_remaining      NUMBER:=0;

CURSOR line_amt_sum_csr( p_id in NUMBER) IS
SELECT NVL(SUM(claim_currency_amount), 0)
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;
l_parent_line_sum   NUMBER:=0;
l_child_line_sum    NUMBER:=0;
l_child_line_total  NUMBER:=0;

CURSOR amount_sum_csr(p_id in NUMBER) IS
SELECT NVL(SUM(amount), 0)
FROM   ozf_claims_all
WHERE  split_from_claim_id = p_id;
l_child_amount_sum      NUMBER:=0;

CURSOR child_claim_id_csr(p_id in NUMBER) IS
SELECT claim_id
FROM   ozf_claims_all
WHERE  split_from_claim_id = p_id;

TYPE  child_claim_id_Tbl_Type IS TABLE OF child_claim_id_csr%rowtype
                               INDEX BY BINARY_INTEGER;
l_claim_id_tbl child_claim_id_Tbl_Type;
i number := 1;
BEGIN

  -- Initialize API return status to sucess
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Debug Message
  IF OZF_DEBUG_LOW_ON THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
     FND_MSG_PUB.Add;
  END IF;


  OPEN amount_csr (p_claim_id);
  FETCH amount_csr INTO l_parent_amount_remaining;
  CLOSE amount_csr;

  OPEN line_amt_sum_csr(p_claim_id);
  FETCH line_amt_sum_csr INTO l_parent_line_sum;
  CLOSE line_amt_sum_csr;

  OPEN amount_sum_csr(p_claim_id);
  FETCH amount_sum_csr INTO l_child_amount_sum;
  CLOSE amount_sum_csr;

  OPEN child_claim_id_csr(p_claim_id);
  LOOP
    EXIT WHEN child_claim_id_csr%NOTFOUND;
    FETCH child_claim_id_csr into l_claim_id_tbl(i);
    i := i +1;
  END LOOP;
  CLOSE child_claim_id_csr;

  FOR i in 1..l_claim_id_tbl.COUNT LOOP
      OPEN line_amt_sum_csr(l_claim_id_tbl(i).claim_id);
      FETCH line_amt_sum_csr INTO l_child_line_sum;
      CLOSE line_amt_sum_csr;
      l_child_line_total := l_child_line_total + l_child_line_sum;
  END LOOP;

  -- We want l_child_amount_sum - l_child_line_total <=  l_parent_amount_remaining - l_parent_line_sum
  /* BEGIN FIX BUG -- by mchang 07/13/2001 */
  --IF (l_child_amount_sum - l_child_line_total) >=  (l_parent_amount_remaining - l_parent_line_sum) THEN
  IF (l_child_amount_sum - l_child_line_total) > (l_parent_amount_remaining - l_parent_line_sum) THEN
  /* END FIG BUG */
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_SPLIT_TOO_BIG');
        FND_MSG_PUB.ADD;
     END IF;
     RAISE FND_API.g_exc_error;
  END IF;

  -- Debug Message
  IF OZF_DEBUG_LOW_ON THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
     FND_MSG_PUB.Add;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Check_Split_Condition;

-----------------------------------------------------------------------------------------
-- PROCEDURE
--   get_line_table
--
-- PURPOSE
--   convert a comma dilimited string to a simple_line_tble
--   The string is pairs of xxx,xxx
--
-- PARAMETERS
--   p_line_string
--   x_line_table
--   x_return_status
--
-- NOTES
--
-- HISTORY
-- ateotia  09-Jan-2009  Bug# 7699177 fixed.
--                       This procedure now doesn't expect object_version_number in
--                       input paramter p_line_string.
-----------------------------------------------------------------------------------------
PROCEDURE get_line_table(p_line_string    in varchar2,
                         x_line_table     OUT NOCOPY simple_line_tbl_type,
                         x_return_status  OUT NOCOPY varchar2)
IS
l_return_status VARCHAR2(3);
l_index         NUMBER;
l_temp_index    NUMBER;
i               NUMBER:=1; -- line table index start from 1

--Bug# 7699177 fixed by ateotia(+)
l_line_string           VARCHAR2(32767):= p_line_string;
l_temp                  VARCHAR2(32767);
l_object_version_number NUMBER;

CURSOR getObjectVersionNumber(p_line_id IN NUMBER) IS
SELECT object_version_number
FROM ozf_claim_lines_all
WHERE claim_line_id = p_line_id;
--Bug# 7699177 fixed by ateotia(-)

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Bug# 7699177 fixed by ateotia(+)
   /*-- split (claim_line_id, object_version_number) pair
   l_index := INSTR(l_line_string, ',', 1, 2);
   WHILE (l_index >0)LOOP

     -- get the pair string
     l_temp := SUBSTR(l_line_string, 1, l_index-1);
     l_temp_index := INSTR(l_temp, ',',1,1);
     x_line_table(i).claim_line_id := TO_NUMBER(SUBSTR(l_temp,1, l_temp_index -1));
     x_line_table(i).object_version_number := TO_NUMBER(SUBSTR(l_temp, l_temp_index+1));

     -- get new string and change index
     l_line_string := SUBSTR(l_line_string, l_index +1);
     l_index := INSTR(l_line_string, ',', 1, 2);
     i:=i+1;
   END LOOP;

   -- Get the last pair
   l_temp_index := INSTR(l_line_string, ',',1,1);
   IF l_temp_index = 0 THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SPLT_LINE_STR_WRG');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   ELSE
      x_line_table(i).claim_line_id := TO_NUMBER(SUBSTR(l_line_string,1, l_temp_index -1));
      x_line_table(i).object_version_number := TO_NUMBER(SUBSTR(l_line_string, l_temp_index +1));
   END IF;*/

   l_index := INSTR(l_line_string, ',', 1, 1);
   WHILE (l_index >0)LOOP
     l_temp := SUBSTR(l_line_string, 1, l_index-1);
     x_line_table(i).claim_line_id := TO_NUMBER(l_temp);
     OPEN getObjectVersionNumber(x_line_table(i).claim_line_id);
     FETCH getObjectVersionNumber INTO l_object_version_number;
     CLOSE getObjectVersionNumber;
     x_line_table(i).object_version_number := l_object_version_number;
     l_line_string := SUBSTR(l_line_string, l_index +1);
     l_index := INSTR(l_line_string, ',', 1, 1);
     i:=i+1;
   END LOOP;
   x_line_table(i).claim_line_id := TO_NUMBER(l_line_string);
   OPEN getObjectVersionNumber(x_line_table(i).claim_line_id);
   FETCH getObjectVersionNumber INTO l_object_version_number;
   CLOSE getObjectVersionNumber;
   x_line_table(i).object_version_number := l_object_version_number;
   --Bug# 7699177 fixed by ateotia(-)

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SPLT_LINE_TBL_ERR');
        FND_MSG_PUB.add;
     END IF;
END get_line_table;

-----------------------------------------------------------------------------------------
-- PROCEDURE
--    autosplit_line
--
-- PURPOSE
--    split a claim line of a parent based the child claim information
--
-- PARAMETERS
--    p_child_claim_tbl
--    x_child_claim_tbl
--    x_return_status
--
-- NOTES
--
-- HISTORY
-- ateotia  27-Jan-2009  Bug# 7699177 fixed.
--                       Procedure get_line_table doesn't expect object_version_number in
--                       input parameter p_line_string.
-----------------------------------------------------------------------------------------
PROCEDURE autosplit_line(p_child_claim_tbl    in Child_Claim_tbl_type,
                         x_child_claim_tbl     OUT NOCOPY Child_Claim_tbl_type,
                         x_return_status  OUT NOCOPY varchar2)
IS
l_return_status varchar2(3);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;
l_child_claim_tbl      Child_Claim_tbl_type := p_child_claim_tbl;

CURSOR parent_amount_rem_csr(p_id in NUMBER) IS
SELECT amount_remaining
FROM   ozf_claims_all
WHERE  claim_id = p_id;
l_parent_amount_remaining      NUMBER:=0;

CURSOR line_amount_sum_csr(p_id in number) IS
SELECT NVL(SUM(claim_currency_amount), 0)
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;
l_current_sum number;

CURSOR line_count_csr(p_id in number) IS
SELECT Count(claim_line_id)
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;
l_line_count number:=0;

CURSOR line_associate_csr(p_id in number) IS
SELECT earnings_associated_flag
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;
l_earning_flag varchar2(1);

l_no_line_found boolean := true;

CURSOR line_info_csr(p_id in number) IS
SELECT *
FROM ozf_claim_lines_all
where claim_id = p_id;

l_claim_line line_info_csr%rowtype;
l_pvt_claim_line  OZF_CLAIM_LINE_PVT.claim_line_rec_type ;
l_parent_line     OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_claim_line_id number;

l_new_split_amount number :=0;
l_line_obj_num number;
BEGIN

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Under the following condition, I will create lines with the child amount for the parents.
   -- These line information will be stored in the line_table for the child claim.
   -- These new lines will be moved to the child claims in a later stage

   -- Get the sum of the line amount for the parent claim
   -- If the sum of the line amount = claim amount and
   -- there is only one line and
   -- there is no utlization and
   -- there is no line_table for any of the child claim
   -- for this line, we will create new claim line for the parent claim based on the child claim amount.
   OPEN parent_amount_rem_csr(l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id);
   FETCH parent_amount_rem_csr into l_parent_amount_remaining;
   CLOSE parent_amount_rem_csr;

   OPEN line_amount_sum_csr(l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id);
   FETCH line_amount_sum_csr into l_current_sum;
   CLOSE line_amount_sum_csr;

   OPEN line_count_csr(l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id);
   FETCH line_count_csr into l_line_count;
   CLOSE line_count_csr;

   OPEN line_associate_csr(l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id);
   FETCH line_associate_csr into l_earning_flag;
   CLOSE line_associate_csr;

   -- If there is no claim line moved between parent and child
   For i in 1..l_child_claim_tbl.count LOOP
      l_no_line_found :=l_child_claim_tbl(i).line_table is null;
      exit when not l_no_line_found;
   END LOOP;

   IF l_current_sum = l_parent_amount_remaining AND
      l_line_count = 1 AND
      (l_earning_flag = 'F' or l_earning_flag is null) AND
      l_no_line_found THEN

      -- get the amount to be split
      For i in 1..l_child_claim_tbl.count LOOP
         l_new_split_amount := l_new_split_amount + l_child_claim_tbl(i).amount;
      END LOOP;

      -- store the line information in a local variable
      OPEN line_info_csr(l_child_claim_tbl(1).parent_claim_id);
      FETCH line_info_csr into l_claim_line;
      CLOSE line_info_csr;

      IF l_new_split_amount = l_parent_amount_remaining THEN
         IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_PVT.debug_message('delete claim line amount ' || l_claim_line.claim_line_id);
         END IF;

         delete from ozf_claim_lines_all
         where claim_line_id = l_claim_line.claim_line_id;
      ELSE
         IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_PVT.debug_message('update parent claim amount ' ||l_claim_line.claim_line_id);
         END IF;

         OZF_CLAIM_LINE_PVT.Init_Claim_Line_Rec(x_claim_line_rec => l_parent_line);
         l_parent_line.claim_line_id         := l_claim_line.claim_line_id;
         l_parent_line.object_version_number := l_claim_line.object_version_number;
         l_parent_line.claim_id              := l_claim_line.claim_id;
         l_parent_line.claim_currency_amount := l_parent_amount_remaining - l_new_split_amount;

         --Bug Fix 3405910
         IF (l_claim_line.quantity is not null AND l_claim_line.quantity <> FND_API.G_MISS_NUM)
            AND (l_claim_line.rate is not null AND l_claim_line.rate <> FND_API.G_MISS_NUM) THEN
            IF mod(l_parent_line.claim_currency_amount , l_claim_line.rate) = 0 THEN
               l_parent_line.quantity := l_parent_line.claim_currency_amount/l_claim_line.rate;
            ELSE
               --If not a whole number, then clear the parent lines values.
               l_parent_line.quantity := fnd_api.g_miss_num;
               l_parent_line.rate     := fnd_api.g_miss_num;
               l_parent_line.quantity_uom  := fnd_api.g_miss_char;
            END IF;
         END IF;
         --End of Bug Fix 3405910

         OZF_CLAIM_LINE_PVT.Update_Claim_Line(
            p_api_version       => 1.0
           ,p_init_msg_list     => FND_API.g_false
           ,p_commit            => FND_API.g_false
           ,p_validation_level  => FND_API.g_valid_level_full
           ,x_return_status     => l_return_status
           ,x_msg_count         => l_msg_count
           ,x_msg_data          => l_msg_data
           ,p_claim_line_rec    => l_parent_line
           ,p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
           ,x_object_version    => l_line_obj_num
         );

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         /*
         update ozf_claim_lines_all
         set claim_currency_amount = l_parent_amount_remaining - l_new_split_amount,
         quantity = null
         where claim_line_id = l_claim_line.claim_line_id;
         */
      END IF;

      For i in 1..l_child_claim_tbl.count LOOP
         -- construct the new line record based on the old line record
         -- keep the rate info, but nullify the quantity
         -- assign claim_currency_amount := l_child_claim_tbl(i).amount;
         l_pvt_claim_line.claim_id                    := l_claim_line.claim_id;
         l_pvt_claim_line.split_from_claim_line_id    := l_claim_line.split_from_claim_line_id;

         -- assign claim_currency_amount := l_child_claim_tbl(i).amount;
         l_pvt_claim_line.claim_currency_amount       := l_child_claim_tbl(i).amount;
         /*
         l_pvt_claim_line.acctd_amount                := l_claim_line.acctd_amount;
         l_pvt_claim_line.currency_code               := l_claim_line.currency_code ;
         l_pvt_claim_line.exchange_rate_type          := l_claim_line.exchange_rate_type ;
         l_pvt_claim_line.exchange_rate_date          := l_claim_line.exchange_rate_date;
         l_pvt_claim_line.exchange_rate               := l_claim_line.exchange_rate;
         */
         l_pvt_claim_line.set_of_books_id             := l_claim_line.set_of_books_id;
         l_pvt_claim_line.valid_flag                  := l_claim_line.valid_flag;
         l_pvt_claim_line.source_object_id            := l_claim_line.source_object_id;
         l_pvt_claim_line.source_object_class         := l_claim_line.source_object_class;
         l_pvt_claim_line.source_object_type_id       := l_claim_line.source_object_type_id;
         l_pvt_claim_line.plan_id                     := l_claim_line.plan_id;
         l_pvt_claim_line.offer_id                    := l_claim_line.offer_id;
         l_pvt_claim_line.utilization_id              := l_claim_line.utilization_id;
         l_pvt_claim_line.payment_method              := l_claim_line.payment_method;
         l_pvt_claim_line.payment_reference_id        := l_claim_line.payment_reference_id;
         l_pvt_claim_line.payment_reference_number    := l_claim_line.payment_reference_number;
         l_pvt_claim_line.payment_reference_date      := l_claim_line.payment_reference_date;
         l_pvt_claim_line.voucher_id                  := l_claim_line.voucher_id;
         l_pvt_claim_line.voucher_number              := l_claim_line.voucher_number;
         l_pvt_claim_line.payment_status              := l_claim_line.payment_status;
         l_pvt_claim_line.approved_flag               := l_claim_line.approved_flag ;
         l_pvt_claim_line.approved_date               := l_claim_line.approved_date;
         l_pvt_claim_line.approved_by                 := l_claim_line.approved_by  ;
         l_pvt_claim_line.settled_date                := l_claim_line.settled_date;
         l_pvt_claim_line.settled_by                  := l_claim_line.settled_by;
         l_pvt_claim_line.performance_complete_flag   := l_claim_line.performance_complete_flag;
         l_pvt_claim_line.performance_attached_flag   := l_claim_line.performance_attached_flag;
         l_pvt_claim_line.item_id                     := l_claim_line.item_id;
         l_pvt_claim_line.item_description            := l_claim_line.item_description ;
         l_pvt_claim_line.quantity                    := null;
         l_pvt_claim_line.quantity_uom                := l_claim_line.quantity_uom;
         l_pvt_claim_line.rate                        := l_claim_line.rate;
         l_pvt_claim_line.activity_type               := l_claim_line.activity_type;
         l_pvt_claim_line.activity_id                 := l_claim_line.activity_id;
         l_pvt_claim_line.related_cust_account_id     := l_claim_line.related_cust_account_id;
         l_pvt_claim_line.relationship_type           := l_claim_line.relationship_type;
         l_pvt_claim_line.earnings_associated_flag    := l_claim_line.earnings_associated_flag;
         l_pvt_claim_line.comments                    := l_claim_line.comments;
         l_pvt_claim_line.tax_code                    := l_claim_line.tax_code;
         l_pvt_claim_line.attribute_category          := l_claim_line.attribute_category;
         l_pvt_claim_line.attribute1                  := l_claim_line.attribute1;
         l_pvt_claim_line.attribute2                  := l_claim_line.attribute2;
         l_pvt_claim_line.attribute3                  := l_claim_line.attribute3;
         l_pvt_claim_line.attribute4                  := l_claim_line.attribute4;
         l_pvt_claim_line.attribute5                  := l_claim_line.attribute5;
         l_pvt_claim_line.attribute6                  := l_claim_line.attribute6;
         l_pvt_claim_line.attribute7                  := l_claim_line.attribute7;
         l_pvt_claim_line.attribute8                  := l_claim_line.attribute8;
         l_pvt_claim_line.attribute9                  := l_claim_line.attribute9;
         l_pvt_claim_line.attribute10                 := l_claim_line.attribute10;
         l_pvt_claim_line.attribute11                 := l_claim_line.attribute11;
         l_pvt_claim_line.attribute12                 := l_claim_line.attribute12;
         l_pvt_claim_line.attribute13                 := l_claim_line.attribute13;
         l_pvt_claim_line.attribute14                 := l_claim_line.attribute14;
         l_pvt_claim_line.attribute15                 := l_claim_line.attribute15;
         l_pvt_claim_line.org_id                      := l_claim_line.org_id ;
         -- bugfix 4921610
         l_pvt_claim_line.item_type                   := l_claim_line.item_type;

         Ozf_Claim_Line_Pvt.Create_Claim_Line(
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => FND_API.G_VALID_LEVEL_FULL
               , x_return_status     => l_return_status
               , x_msg_data          => l_msg_data
               , x_msg_count         => l_msg_count
               , p_claim_line_rec    => l_pvt_claim_line
                                        , p_mode              => OZF_claim_Utility_pvt.G_AUTO_MODE
               , x_claim_line_id     => l_claim_line_id
         );
         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         --update the l_child_claim_tbl record
         --   line_amount_sum := amount
         --   line_table := l_claim_line_id || ',1';
         l_child_claim_tbl(i).line_amount_sum := l_child_claim_tbl(i).amount;

         --Bug# 7699177 fixed by ateotia(+)
         --Procedure get_line_table doesn't expect object_version_number in input parameter p_line_string.
         --l_child_claim_tbl(i).line_table  := l_claim_line_id || ',1';
         l_child_claim_tbl(i).line_table  := l_claim_line_id;
         --Bug# 7699177 fixed by ateotia(-)

      END LOOP;
   ELSE
      -- I will not construct the line information for these child claims
      null;
   END IF;

   x_child_claim_tbl := l_child_claim_tbl;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AUTSPLT_LINE_ERR');
        FND_MSG_PUB.add;
     END IF;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_AUTSPLT_LINE_ERR');
        FND_MSG_PUB.add;
     END IF;
END autosplit_line;

---------------------------------------------------------------------
-- PROCEDURE
--    create_child_claim_tbl
--
-- PURPOSE
--    Split a child claim
--
-- PARAMETERS
--    p_claim    : the new claim to be created.
--    p_line_tbl : the table of lines associated with this new claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE create_child_claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_child_claim_tbl        IN    Child_Claim_tbl_type
        ,p_mode                   IN    VARCHAR2
   )
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Create_Child_Claim_tbl';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;
l_child_claim_tbl      Child_Claim_tbl_type := p_child_claim_tbl;
l_x_child_claim_tbl    Child_Claim_tbl_type;
l_child_claim          child_claim_int_type;
l_parent_claim         Parent_Claim_Type;
l_line_tbl             Simple_line_tbl_type;
l_amount_adjusted      number := 0;
l_new_split_amount     number := 0;

l_temp_claim_rec       ozf_claim_pvt.claim_rec_type;
l_temp_need_to_create  VARCHAR2(20);
l_temp_clm_history_id  NUMBER;
l_access varchar2(1) := 'N';
l_claim_class       varchar2(30);


CURSOR claim_class_csr(p_claim_id in number) IS
SELECT claim_class
FROM ozf_claims_all
WHERE claim_id = p_claim_id;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT Create_Child_Tbl_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
   THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
       FND_MSG_PUB.Add;
   END IF;
   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;


   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF p_mode = 'MANU' THEN
       OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
          P_Api_Version_Number => 1.0,
          P_Init_Msg_List      => FND_API.G_FALSE,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          P_Commit             => FND_API.G_FALSE,
          P_object_id          => l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id,
          P_object_type        => G_CLAIM_OBJECT_TYPE,
          P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1)),
          X_Return_Status      => l_return_status,
          X_Msg_Count          => l_msg_count,
          X_Msg_Data           => l_msg_data,
          X_access             => l_access);

            IF l_access = 'N' THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_NO_ACCESS');
             FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;


   --Get the parent claim class.
   OPEN claim_class_csr(l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id);
   FETCH claim_class_csr INTO l_claim_class;
   CLOSE claim_class_csr;
   --End of Claim amount check.

   FOR i IN 1..l_child_claim_tbl.count LOOP
    --Check for the claim amount, if it is invalid amount throw an exception.
         IF l_claim_class = 'CLAIM'
         OR l_claim_class = 'DEDUCTION'
         THEN
            IF l_child_claim_tbl(i).amount <= 0
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SPLIT_POS_AMT_ERR');
                  FND_MSG_PUB.add;
                  END IF;
            RAISE FND_API.g_exc_error;
            END IF;
         ELSIF l_claim_class = 'CHARGE'
         OR l_claim_class = 'OVERPAYMENT'
         THEN
            IF l_child_claim_tbl(i).amount >= 0
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SPLIT_NEG_AMT_ERR');
               FND_MSG_PUB.add;
               END IF;
            RAISE FND_API.g_exc_error;
            END IF;
        END IF;
        --End of claim amount check.
   END LOOP;


  -- automatically split a claim line for the parent, if needed, based on the child information
   autosplit_line(p_child_claim_tbl => l_child_claim_tbl,
                  x_child_claim_tbl => l_x_child_claim_tbl,
                  x_return_status   => l_return_status);
   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   l_child_claim_tbl := l_x_child_claim_tbl;

   l_new_split_amount := 0;
   For i in 1..l_child_claim_tbl.count LOOP
      l_child_claim.claim_id              := l_child_claim_tbl(i).claim_id;
      l_child_claim.object_version_number := l_child_claim_tbl(i).object_version_number;
      l_child_claim.claim_type_id         := l_child_claim_tbl(i).claim_type_id;
      l_child_claim.amount                := l_child_claim_tbl(i).amount;
      l_child_claim.line_amount_sum       := l_child_claim_tbl(i).line_amount_sum;
      l_child_claim.reason_code_id        := l_child_claim_tbl(i).reason_code_id;
      l_child_claim.parent_claim_id       := l_child_claim_tbl(i).parent_claim_id;

      IF l_child_claim_tbl(i).line_table is not null AND
         l_child_claim_tbl(i).line_table <> FND_API.G_MISS_CHAR THEN
         get_line_table (p_line_string => l_child_claim_tbl(i).line_table,
                         x_line_table  => l_line_tbl,
                         x_return_status => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

      create_child_claim (
         p_claim                  => l_child_claim
        ,p_line_tbl               => l_line_tbl
        ,x_return_status          => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- create_child_claim sucessful.
      -- Reinitialize line table is needed.
      IF l_line_tbl.count >0 THEN
         l_line_tbl.delete;
      END IF;
      l_new_split_amount := l_new_split_amount + l_child_claim_tbl(i).amount;
   END LOOP;

   l_parent_claim.claim_id := l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id;
   l_parent_claim.object_version_number := l_child_claim_tbl(l_child_claim_tbl.count).parent_object_ver_num;

   -- When creating child claims, amount_adjusted = claim amount of all new claims.
   -- The l_old_split_amount is the amount that has been split. It should be 0 during child creation.
   -- change this line: l_parent_claim.amount_adjusted := l_new_split_amount - l_old_split_amount;
   l_parent_claim.amount_adjusted := l_new_split_amount;



   update_parent_claim (
      p_claim   => l_parent_claim
     ,p_mode    => p_mode
     ,x_return_status  => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   END IF;


   --bug 335704
   -- create claim history if needed
   IF (not g_history_created ) THEN
      l_temp_claim_rec.claim_id := l_child_claim_tbl(l_child_claim_tbl.count).parent_claim_id;
      l_temp_claim_rec.object_version_number := l_child_claim_tbl(l_child_claim_tbl.count).parent_object_ver_num;

      OZF_CLAIM_PVT.Create_Claim_History (
        p_api_version       => l_api_version
       ,p_init_msg_list     => FND_API.G_FALSE
       ,p_commit            => FND_API.G_FALSE
       ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
       ,x_return_status     => l_return_status
       ,x_msg_data          => l_msg_data
       ,x_msg_count         => l_msg_count
       ,p_claim             => l_temp_claim_rec
       ,p_event             => G_SPLIT_EVENT
       ,x_need_to_create    => l_temp_need_to_create
       ,x_claim_history_id  => l_temp_clm_history_id
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
        ELSE
      g_history_created := false;
   END IF;
   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
       FND_MSG_PUB.Add;
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Create_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Create_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Create_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END create_child_claim_tbl;

---------------------------------------------------------------------
-- PROCEDURE
--    update_child_claim_tbl
--
-- PURPOSE
--    Update a child claim
--
-- PARAMETERS
--    p_claim    : the new claim to be created.
--    p_line_tbl : the table of lines associated with this new claim if any.
--
-- NOTES
----------------------------------------------------------------------
PROCEDURE update_child_claim_tbl (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_child_claim_tbl        IN    Child_Claim_tbl_type
        ,p_mode                   IN    VARCHAR2
   )
IS
l_api_name               CONSTANT VARCHAR2(30) := 'Update_Child_Claim_tbl';
l_api_version            CONSTANT NUMBER := 1.0;
l_full_name              CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status        VARCHAR2(30);
l_msg_data             VARCHAR2(2000);
l_msg_count            NUMBER;
l_child_claim          child_claim_int_type;
l_parent_claim         parent_Claim_type;
l_line_tbl             Simple_line_tbl_type;
l_amount_adjusted      number := 0;
l_new_split_amount     number := 0;
l_old_split_amount     number := 0;
l_new_child_claim_amount number := 0;

l_temp_claim_rec       ozf_claim_pvt.claim_rec_type;
l_temp_need_to_create  VARCHAR2(20);
l_temp_clm_history_id  NUMBER;
l_access varchar2(1) := 'N';
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Update_Child_Tbl_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
   THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
       FND_MSG_PUB.Add;
   END IF;
   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_mode = 'MANU' THEN
       OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
          P_Api_Version_Number => 1.0,
          P_Init_Msg_List      => FND_API.G_FALSE,
          p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
          P_Commit             => FND_API.G_FALSE,
          P_object_id          => p_child_claim_tbl(p_child_claim_tbl.count).parent_claim_id,
          P_object_type        => G_CLAIM_OBJECT_TYPE,
          P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1)),
          X_Return_Status      => l_return_status,
          X_Msg_Count          => l_msg_count,
          X_Msg_Data           => l_msg_data,
          X_access             => l_access);

            IF l_access = 'N' THEN
               IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_NO_ACCESS');
             FND_MSG_PUB.Add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
    END IF;


   For i in 1..p_child_claim_tbl.count LOOP
        l_child_claim.claim_id              := p_child_claim_tbl(i).claim_id;
        l_child_claim.object_version_number := p_child_claim_tbl(i).object_version_number;
        l_child_claim.claim_type_id         := p_child_claim_tbl(i).claim_type_id;
        l_child_claim.amount                := p_child_claim_tbl(i).amount;
        l_child_claim.line_amount_sum       := p_child_claim_tbl(i).line_amount_sum;
        l_child_claim.reason_code_id        := p_child_claim_tbl(i).reason_code_id;
        l_child_claim.parent_claim_id       := p_child_claim_tbl(i).parent_claim_id;

        IF p_child_claim_tbl(i).line_table is not null AND
           p_child_claim_tbl(i).line_table <> FND_API.G_MISS_CHAR THEN
           get_line_table (p_line_string => p_child_claim_tbl(i).line_table,
                           x_line_table  => l_line_tbl,
                           x_return_status => l_return_status
           );
           IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
        END IF;
        update_child_claim (
             p_claim                  => l_child_claim
            ,p_line_tbl               => l_line_tbl
            ,x_return_status          => l_return_status
            ,x_new_claim_amount       => l_new_child_claim_amount
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         -- create_child_claim sucessful.

         -- Reinitialize line table is needed.
         IF l_line_tbl.count >0 THEN
            l_line_tbl.delete;
         END IF;

         l_old_split_amount := l_old_split_amount + p_child_claim_tbl(i).amount;
         l_new_split_amount := l_new_split_amount + l_new_child_claim_amount;
   END LOOP;

   l_parent_claim.claim_id := p_child_claim_tbl(p_child_claim_tbl.count).parent_claim_id;
   l_parent_claim.object_version_number := p_child_claim_tbl(p_child_claim_tbl.count).parent_object_ver_num;

   -- When creating child claims, amount_adjusted = sum(new child claim amount) - sum(old child claim amount)
   l_parent_claim.amount_adjusted := l_new_split_amount - l_old_split_amount;
   update_parent_claim (
       p_claim   => l_parent_claim
      ,p_mode    => p_mode
      ,x_return_status  => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --bug 3357204
   -- create claim history if needed
   if (g_history_created = false) THEN
      l_temp_claim_rec.claim_id := p_child_claim_tbl(p_child_claim_tbl.count).parent_claim_id;
      l_temp_claim_rec.object_version_number := p_child_claim_tbl(p_child_claim_tbl.count).parent_object_ver_num;

      OZF_CLAIM_PVT.Create_Claim_History (
        p_api_version       => l_api_version
       ,p_init_msg_list     => FND_API.G_FALSE
       ,p_commit            => FND_API.G_FALSE
       ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
       ,x_return_status     => l_return_status
       ,x_msg_data          => l_msg_data
       ,x_msg_count         => l_msg_count
       ,p_claim             => l_temp_claim_rec
       ,p_event             => G_SPLIT_EVENT
       ,x_need_to_create    => l_temp_need_to_create
       ,x_claim_history_id  => l_temp_clm_history_id
      );
      g_history_created := true;
        END IF;

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
       FND_MSG_PUB.Add;
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Update_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Update_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Update_Child_Tbl_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END update_child_claim_tbl;

END;

/
