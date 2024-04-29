--------------------------------------------------------
--  DDL for Package Body OZF_SUPP_TRD_PRFLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SUPP_TRD_PRFLS_PKG" as
/* $Header: ozftstpb.pls 120.0.12010000.5 2009/09/23 09:48:49 nepanda ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_supp_trd_prfls_PKG
-- Purpose
--
-- History
-- 16-SEP-2008 kdass  ER 7377460 - added DFFs for DPP section
-- 09-OCT-2008 kdass  ER 7475578 - Supplier Trade Profile changes for Price Protection price increase enhancement
-- 03-AUG-2009 kdass  ER 8755134 - STP: PRICE PROTECTION OPTIONS FOR SKIP APPROVAL AND SKIP ADJUSTMENT
-- 23-SEP-2009 nepanda ER 8932673 - er: credit memo scenario not handled in current price protection product
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_supp_trd_prfls_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftstpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
                px_supp_trade_profile_id   IN OUT NOCOPY NUMBER,
                px_object_version_number   IN OUT NOCOPY NUMBER,
                p_last_update_date    DATE,
                p_last_updated_by    NUMBER,
                p_creation_date    DATE,
                p_created_by    NUMBER,
                p_last_update_login    NUMBER,
                p_request_id    NUMBER,
                p_program_application_id    NUMBER,
                p_program_update_date    DATE,
                p_program_id    NUMBER,
                p_created_from    VARCHAR2,
                p_party_id    NUMBER,
                p_site_use_id    NUMBER,
                p_cust_account_id    NUMBER,
                p_cust_acct_site_id    NUMBER,
                p_supplier_id    NUMBER,
                p_supplier_site_id    NUMBER,
                p_attribute_category    VARCHAR2,
                p_attribute1    VARCHAR2,
                p_attribute2    VARCHAR2,
                p_attribute3    VARCHAR2,
                p_attribute4    VARCHAR2,
                p_attribute5    VARCHAR2,
                p_attribute6    VARCHAR2,
                p_attribute7    VARCHAR2,
                p_attribute8    VARCHAR2,
                p_attribute9    VARCHAR2,
                p_attribute10    VARCHAR2,
                p_attribute11    VARCHAR2,
                p_attribute12    VARCHAR2,
                p_attribute13    VARCHAR2,
                p_attribute14    VARCHAR2,
                p_attribute15    VARCHAR2,
        p_attribute16    VARCHAR2,
        p_attribute17   VARCHAR2,
        p_attribute18   VARCHAR2,
        p_attribute19   VARCHAR2,
        p_attribute20   VARCHAR2,
        p_attribute21    VARCHAR2,
        p_attribute22   VARCHAR2,
        p_attribute23   VARCHAR2,
        p_attribute24   VARCHAR2,
        p_attribute25    VARCHAR2,
        p_attribute26    VARCHAR2,
        p_attribute27    VARCHAR2,
        p_attribute28    VARCHAR2,
        p_attribute29    VARCHAR2,
        p_attribute30    VARCHAR2,
        p_dpp_attribute_category    VARCHAR2,
        p_dpp_attribute1    VARCHAR2,
        p_dpp_attribute2    VARCHAR2,
        p_dpp_attribute3    VARCHAR2,
        p_dpp_attribute4    VARCHAR2,
        p_dpp_attribute5    VARCHAR2,
        p_dpp_attribute6    VARCHAR2,
        p_dpp_attribute7    VARCHAR2,
        p_dpp_attribute8    VARCHAR2,
        p_dpp_attribute9    VARCHAR2,
        p_dpp_attribute10    VARCHAR2,
        p_dpp_attribute11    VARCHAR2,
        p_dpp_attribute12    VARCHAR2,
        p_dpp_attribute13    VARCHAR2,
        p_dpp_attribute14    VARCHAR2,
        p_dpp_attribute15    VARCHAR2,
        p_dpp_attribute16    VARCHAR2,
        p_dpp_attribute17   VARCHAR2,
        p_dpp_attribute18   VARCHAR2,
        p_dpp_attribute19   VARCHAR2,
        p_dpp_attribute20   VARCHAR2,
        p_dpp_attribute21    VARCHAR2,
        p_dpp_attribute22   VARCHAR2,
        p_dpp_attribute23   VARCHAR2,
        p_dpp_attribute24   VARCHAR2,
        p_dpp_attribute25    VARCHAR2,
        p_dpp_attribute26    VARCHAR2,
        p_dpp_attribute27    VARCHAR2,
        p_dpp_attribute28    VARCHAR2,
        p_dpp_attribute29    VARCHAR2,
        p_dpp_attribute30    VARCHAR2,

                px_org_id   IN OUT NOCOPY NUMBER ,
                p_pre_approval_flag             VARCHAR2,
                p_approval_communication        VARCHAR2,
                p_gl_contra_liability_acct      NUMBER,
                p_gl_cost_adjustment_acct       NUMBER,
                p_default_days_covered          NUMBER,
                p_create_claim_price_increase   VARCHAR2,
                p_skip_approval_flag            VARCHAR2,
                p_skip_adjustment_flag          VARCHAR2,
		--nepanda : ER 8932673 : start
                p_settlement_method_supp_inc  VARCHAR2,
                p_settlement_method_supp_dec  VARCHAR2,
                p_settlement_method_customer  VARCHAR2,
		--nepanda : ER 8932673 : end
                p_authorization_period          NUMBER,
                p_grace_days                    NUMBER,
                p_allow_qty_increase            VARCHAR2,
                p_qty_increase_tolerance        NUMBER,
                p_request_communication         VARCHAR2,
                p_claim_communication           VARCHAR2,
                p_claim_frequency               NUMBER,
                p_claim_frequency_unit          VARCHAR2,
                p_claim_computation_basis       NUMBER,
                p_claim_currency_code           VARCHAR2,
                p_min_claim_amt                 NUMBER,
                p_min_claim_amt_line_lvl        NUMBER,
                p_auto_debit                    VARCHAR2,
                p_days_before_claiming_debit    NUMBER


          )

 IS
   x_rowid    VARCHAR2(30);


BEGIN
       IF g_debug THEN
          OZF_UTILITY_PVT.debug_message( 'Into begin 1');
       END IF;

 -- R12 Enhancements
   IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       px_org_id := MO_GLOBAL.get_current_org_id();
   END IF;

   px_object_version_number := 1;
   IF g_debug THEN
           OZF_UTILITY_PVT.debug_message( 'before insert 2');
       OZF_UTILITY_PVT.debug_message( 'Party id is'||p_party_id );
       OZF_UTILITY_PVT.debug_message( 'supplier id is'||p_supplier_id );
       OZF_UTILITY_PVT.debug_message( 'supplier site id is'||p_supplier_site_id );
    END IF;

   INSERT INTO ozf_supp_trd_prfls_all(
        supp_trade_profile_id,
        object_version_number,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_update_date,
        program_id,
        created_from,
        party_id,
        site_use_id,
        cust_account_id,
        cust_acct_site_id,
        supplier_id,
        supplier_site_id,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    attribute21,
    attribute22,
    attribute23,
    attribute24,
    attribute25,
    attribute26,
    attribute27,
    attribute28,
    attribute29,
    attribute30,
        dpp_attribute_category,
        dpp_attribute1,
        dpp_attribute2,
        dpp_attribute3,
        dpp_attribute4,
        dpp_attribute5,
        dpp_attribute6,
        dpp_attribute7,
        dpp_attribute8,
        dpp_attribute9,
        dpp_attribute10,
        dpp_attribute11,
        dpp_attribute12,
        dpp_attribute13,
        dpp_attribute14,
        dpp_attribute15,
        dpp_attribute16,
        dpp_attribute17,
        dpp_attribute18,
        dpp_attribute19,
        dpp_attribute20,
        dpp_attribute21,
        dpp_attribute22,
        dpp_attribute23,
        dpp_attribute24,
        dpp_attribute25,
        dpp_attribute26,
        dpp_attribute27,
        dpp_attribute28,
        dpp_attribute29,
        dpp_attribute30,
        org_id ,
        pre_approval_flag          ,
        approval_communication    ,
        gl_contra_liability_acct  ,
        gl_cost_adjustment_acct   ,
        default_days_covered      ,
        create_claim_price_increase  ,
        skip_approval_flag  ,
        skip_adjustment_flag  ,
	--nepanda : ER 8932673 : start
        settlement_method_supplier_inc,
        settlement_method_supplier_dec,
        settlement_method_customer,
	--nepanda : ER 8932673 : end
        authorization_period      ,
        grace_days                ,
        allow_qty_increase        ,
        qty_increase_tolerance   ,
        request_communication     ,
        claim_communication       ,
        claim_frequency          ,
        claim_frequency_unit      ,
        claim_computation_basis ,
        claim_currency_code      ,
        min_claim_amt           ,
        min_claim_amt_line_lvl  ,
        auto_debit              ,
        days_before_claiming_debit



   ) VALUES (
        px_supp_trade_profile_id,
        px_object_version_number,
        p_last_update_date,
        p_last_updated_by,
        p_creation_date,
        p_created_by,
        p_last_update_login,
        p_request_id,
        p_program_application_id,
        p_program_update_date,
        p_program_id,
        p_created_from,
        p_party_id,
        p_site_use_id,
        p_cust_account_id,
        p_cust_acct_site_id,
        p_supplier_id,
        p_supplier_site_id,
        p_attribute_category,
        p_attribute1,
        p_attribute2,
        p_attribute3,
        p_attribute4,
        p_attribute5,
        p_attribute6,
        p_attribute7,
        p_attribute8,
        p_attribute9,
        p_attribute10,
        p_attribute11,
        p_attribute12,
        p_attribute13,
        p_attribute14,
        p_attribute15,
        p_attribute16,
    p_attribute17,
    p_attribute18 ,
    p_attribute19 ,
    p_attribute20 ,
    p_attribute21 ,
    p_attribute22 ,
    p_attribute23 ,
    p_attribute24 ,
    p_attribute25 ,
    p_attribute26 ,
    p_attribute27 ,
    p_attribute28 ,
    p_attribute29 ,
    p_attribute30 ,
        p_dpp_attribute_category,
        p_dpp_attribute1,
        p_dpp_attribute2,
        p_dpp_attribute3,
        p_dpp_attribute4,
        p_dpp_attribute5,
        p_dpp_attribute6,
        p_dpp_attribute7,
        p_dpp_attribute8,
        p_dpp_attribute9,
        p_dpp_attribute10,
        p_dpp_attribute11,
        p_dpp_attribute12,
        p_dpp_attribute13,
        p_dpp_attribute14,
        p_dpp_attribute15,
        p_dpp_attribute16,
        p_dpp_attribute17,
        p_dpp_attribute18,
        p_dpp_attribute19,
        p_dpp_attribute20,
        p_dpp_attribute21,
        p_dpp_attribute22,
        p_dpp_attribute23,
        p_dpp_attribute24,
        p_dpp_attribute25,
        p_dpp_attribute26,
        p_dpp_attribute27,
        p_dpp_attribute28,
        p_dpp_attribute29,
        p_dpp_attribute30,
        px_org_id  ,
        p_pre_approval_flag          ,
        p_approval_communication    ,
        p_gl_contra_liability_acct  ,
        p_gl_cost_adjustment_acct   ,
        p_default_days_covered      ,
        p_create_claim_price_increase ,
        p_skip_approval_flag ,
        p_skip_adjustment_flag ,
	--nepanda : ER 8932673 : start
        p_settlement_method_supp_inc,
        p_settlement_method_supp_dec,
        p_settlement_method_customer,
	--nepanda : ER 8932673 : end
        p_authorization_period      ,
        p_grace_days                ,
        p_allow_qty_increase        ,
        p_qty_increase_tolerance   ,
        p_request_communication     ,
        p_claim_communication       ,
        p_claim_frequency          ,
        p_claim_frequency_unit      ,
        p_claim_computation_basis ,
        p_claim_currency_code    ,
        p_min_claim_amt         ,
        p_min_claim_amt_line_lvl ,
        p_auto_debit            ,
        p_days_before_claiming_debit



          );
       IF g_debug THEN
          OZF_UTILITY_PVT.debug_message( 'after insert 2');
       END IF;

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
        p_supp_trade_profile_id    NUMBER,
        p_object_version_number    NUMBER,
        p_last_update_date    DATE,
        p_last_updated_by    NUMBER,
        p_last_update_login    NUMBER,
        p_request_id    NUMBER,
        p_program_application_id    NUMBER,
        p_program_update_date    DATE,
        p_program_id    NUMBER,
        p_created_from    VARCHAR2,
        p_party_id    NUMBER,
        p_site_use_id    NUMBER,
        p_cust_account_id    NUMBER,
        p_cust_acct_site_id    NUMBER,
        p_supplier_id    NUMBER,
        p_supplier_site_id    NUMBER,
        p_attribute_category    VARCHAR2,
        p_attribute1    VARCHAR2,
        p_attribute2    VARCHAR2,
        p_attribute3    VARCHAR2,
        p_attribute4    VARCHAR2,
        p_attribute5    VARCHAR2,
        p_attribute6    VARCHAR2,
        p_attribute7    VARCHAR2,
        p_attribute8    VARCHAR2,
        p_attribute9    VARCHAR2,
        p_attribute10    VARCHAR2,
        p_attribute11    VARCHAR2,
        p_attribute12    VARCHAR2,
        p_attribute13    VARCHAR2,
        p_attribute14    VARCHAR2,
        p_attribute15    VARCHAR2,
        p_attribute16    VARCHAR2,
        p_attribute17   VARCHAR2,
        p_attribute18   VARCHAR2,
        p_attribute19   VARCHAR2,
        p_attribute20   VARCHAR2,
        p_attribute21    VARCHAR2,
        p_attribute22   VARCHAR2,
        p_attribute23   VARCHAR2,
        p_attribute24   VARCHAR2,
        p_attribute25    VARCHAR2,
        p_attribute26    VARCHAR2,
        p_attribute27    VARCHAR2,
        p_attribute28    VARCHAR2,
        p_attribute29    VARCHAR2,
        p_attribute30    VARCHAR2,
        p_dpp_attribute_category    VARCHAR2,
        p_dpp_attribute1     VARCHAR2,
        p_dpp_attribute2     VARCHAR2,
        p_dpp_attribute3     VARCHAR2,
        p_dpp_attribute4     VARCHAR2,
        p_dpp_attribute5     VARCHAR2,
        p_dpp_attribute6     VARCHAR2,
        p_dpp_attribute7     VARCHAR2,
        p_dpp_attribute8     VARCHAR2,
        p_dpp_attribute9     VARCHAR2,
        p_dpp_attribute10    VARCHAR2,
        p_dpp_attribute11    VARCHAR2,
        p_dpp_attribute12    VARCHAR2,
        p_dpp_attribute13    VARCHAR2,
        p_dpp_attribute14    VARCHAR2,
        p_dpp_attribute15    VARCHAR2,
        p_dpp_attribute16    VARCHAR2,
        p_dpp_attribute17    VARCHAR2,
        p_dpp_attribute18    VARCHAR2,
        p_dpp_attribute19    VARCHAR2,
        p_dpp_attribute20    VARCHAR2,
        p_dpp_attribute21    VARCHAR2,
        p_dpp_attribute22    VARCHAR2,
        p_dpp_attribute23    VARCHAR2,
        p_dpp_attribute24    VARCHAR2,
        p_dpp_attribute25    VARCHAR2,
        p_dpp_attribute26    VARCHAR2,
        p_dpp_attribute27    VARCHAR2,
        p_dpp_attribute28    VARCHAR2,
        p_dpp_attribute29    VARCHAR2,
        p_dpp_attribute30    VARCHAR2,
        p_org_id         NUMBER ,
        p_pre_approval_flag         VARCHAR2,
        p_approval_communication    VARCHAR2,
        p_gl_contra_liability_acct  NUMBER,
        p_gl_cost_adjustment_acct   NUMBER,
        p_default_days_covered      NUMBER,
        p_create_claim_price_increase   VARCHAR2,
        p_skip_approval_flag        VARCHAR2,
        p_skip_adjustment_flag      VARCHAR2,
	--nepanda : ER 8932673 : start
        p_settlement_method_supp_inc  VARCHAR2,
        p_settlement_method_supp_dec  VARCHAR2,
        p_settlement_method_customer  VARCHAR2,
	--nepanda : ER 8932673 : end
        p_authorization_period      NUMBER,
        p_grace_days                NUMBER,
        p_allow_qty_increase        VARCHAR2,
        p_qty_increase_tolerance    NUMBER,
        p_request_communication     VARCHAR2,
        p_claim_communication       VARCHAR2,
        p_claim_frequency           NUMBER,
        p_claim_frequency_unit      VARCHAR2,
        p_claim_computation_basis   NUMBER ,
        p_claim_currency_code       VARCHAR2,
        p_min_claim_amt             NUMBER,
        p_min_claim_amt_line_lvl    NUMBER,
        p_auto_debit                VARCHAR2,
        p_days_before_claiming_debit  NUMBER
          )
IS
BEGIN

   IF g_debug THEN
      OZF_UTILITY_PVT.debug_message( 'Inside update table ');
      OZF_UTILITY_PVT.debug_message( 'Inside update table 2' || p_supp_trade_profile_id);
      OZF_UTILITY_PVT.debug_message( 'Inside update table3'|| p_object_version_number);
   END IF;

   Update ozf_supp_trd_prfls_all
   SET
        supp_trade_profile_id = p_supp_trade_profile_id,
        object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number + 1),
        last_update_date = p_last_update_date,
        last_updated_by = p_last_updated_by,
        last_update_login = p_last_update_login,
        request_id = p_request_id,
        program_application_id = p_program_application_id,
        program_update_date = p_program_update_date,
        program_id = p_program_id,
        created_from = p_created_from,
        party_id = p_party_id,
        site_use_id = p_site_use_id,
        cust_account_id = p_cust_account_id,
        cust_acct_site_id = p_cust_acct_site_id,
        supplier_id = p_supplier_id,
        supplier_site_id = p_supplier_site_id,
        attribute_category = p_attribute_category,
        attribute1 = p_attribute1,
        attribute2 = p_attribute2,
        attribute3 = p_attribute3,
        attribute4 = p_attribute4,
        attribute5 = p_attribute5,
        attribute6 = p_attribute6,
        attribute7 = p_attribute7,
        attribute8 = p_attribute8,
        attribute9 = p_attribute9,
        attribute10 = p_attribute10,
        attribute11 = p_attribute11,
        attribute12 = p_attribute12,
        attribute13 = p_attribute13,
        attribute14 = p_attribute14,
        attribute15 = p_attribute15,
        attribute16     =       p_attribute16 ,
    attribute17 =       p_attribute17 ,
    attribute18 =       p_attribute18 ,
    attribute19 =       p_attribute19 ,
    attribute20 =       p_attribute20 ,
    attribute21 =       p_attribute21 ,
    attribute22 =       p_attribute22 ,
    attribute23 =       p_attribute23 ,
    attribute24 =       p_attribute24 ,
    attribute25 =       p_attribute25 ,
    attribute26 =       p_attribute26 ,
    attribute27 =       p_attribute27 ,
    attribute28 =       p_attribute28 ,
    attribute29 =       p_attribute29 ,
    attribute30 =       p_attribute30 ,
        dpp_attribute_category = p_dpp_attribute_category,
        dpp_attribute1 = p_dpp_attribute1,
        dpp_attribute2 = p_dpp_attribute2,
        dpp_attribute3 = p_dpp_attribute3,
        dpp_attribute4 = p_dpp_attribute4,
        dpp_attribute5 = p_dpp_attribute5,
        dpp_attribute6 = p_dpp_attribute6,
        dpp_attribute7 = p_dpp_attribute7,
        dpp_attribute8 = p_dpp_attribute8,
        dpp_attribute9 = p_dpp_attribute9,
        dpp_attribute10 = p_dpp_attribute10,
        dpp_attribute11 = p_dpp_attribute11,
        dpp_attribute12 = p_dpp_attribute12,
        dpp_attribute13 = p_dpp_attribute13,
        dpp_attribute14 = p_dpp_attribute14,
        dpp_attribute15 = p_dpp_attribute15,
        dpp_attribute16 = p_dpp_attribute16,
        dpp_attribute17 = p_dpp_attribute17,
        dpp_attribute18 = p_dpp_attribute18,
        dpp_attribute19 = p_dpp_attribute19,
        dpp_attribute20 = p_dpp_attribute20,
        dpp_attribute21 = p_dpp_attribute21,
        dpp_attribute22 = p_dpp_attribute22,
        dpp_attribute23 = p_dpp_attribute23,
        dpp_attribute24 = p_dpp_attribute24,
        dpp_attribute25 = p_dpp_attribute25,
        dpp_attribute26 = p_dpp_attribute26,
        dpp_attribute27 = p_dpp_attribute27,
        dpp_attribute28 = p_dpp_attribute28,
        dpp_attribute29 = p_dpp_attribute29,
        dpp_attribute30 = p_dpp_attribute30,

        org_id = p_org_id ,
        pre_approval_flag               =       p_pre_approval_flag          ,
        approval_communication          =       p_approval_communication    ,
        gl_contra_liability_acct        =       p_gl_contra_liability_acct  ,
        gl_cost_adjustment_acct         =       p_gl_cost_adjustment_acct   ,
        default_days_covered            =       p_default_days_covered      ,
        create_claim_price_increase     =       p_create_claim_price_increase ,
        skip_approval_flag              =       p_skip_approval_flag ,
        skip_adjustment_flag            =       p_skip_adjustment_flag ,
	--nepanda : ER 8932673 : start
        settlement_method_supplier_inc  =       p_settlement_method_supp_inc,
        settlement_method_supplier_dec  =       p_settlement_method_supp_dec,
        settlement_method_customer      =       p_settlement_method_customer,
	--nepanda : ER 8932673 : end
        authorization_period            =       p_authorization_period      ,
        grace_days                      =       p_grace_days                ,
        allow_qty_increase              =       p_allow_qty_increase        ,
        qty_increase_tolerance          =       p_qty_increase_tolerance   ,
        request_communication           =       p_request_communication     ,
        claim_communication             =       p_claim_communication       ,
        claim_frequency                 =       p_claim_frequency          ,
        claim_frequency_unit            =       p_claim_frequency_unit      ,
        claim_computation_basis         =       p_claim_computation_basis ,
        claim_currency_code             =       p_claim_currency_code   ,
        min_claim_amt                   =       p_min_claim_amt         ,
        min_claim_amt_line_lvl          =       p_min_claim_amt_line_lvl ,
        auto_debit                      =       p_auto_debit            ,
        days_before_claiming_debit      =        p_days_before_claiming_debit

   WHERE supp_trade_profile_id = p_supp_trade_profile_id;
   IF (SQL%NOTFOUND) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_supp_trade_profile_id  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_supp_trd_prfls_all
    WHERE supp_trade_profile_id = p_supp_trade_profile_id;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
        p_supp_trade_profile_id         NUMBER,
        p_object_version_number         NUMBER,
        p_last_update_date              DATE,
        p_last_updated_by               NUMBER,
        p_creation_date                 DATE,
        p_created_by                    NUMBER,
        p_last_update_login              NUMBER,
        p_request_id                    NUMBER,
        p_program_application_id        NUMBER,
        p_program_update_date            DATE,
        p_program_id                    NUMBER,
        p_created_from                  VARCHAR2,
        p_party_id                      NUMBER,
        p_site_use_id                   NUMBER,
        p_cust_account_id               NUMBER,
        p_cust_acct_site_id             NUMBER,
        p_supplier_id                   NUMBER,
        p_supplier_site_id              NUMBER,
        p_attribute_category            VARCHAR2,
        p_attribute1                    VARCHAR2,
        p_attribute2                    VARCHAR2,
        p_attribute3                    VARCHAR2,
        p_attribute4                    VARCHAR2,
        p_attribute5                    VARCHAR2,
        p_attribute6                    VARCHAR2,
        p_attribute7                    VARCHAR2,
        p_attribute8                    VARCHAR2,
        p_attribute9                    VARCHAR2,
        p_attribute10                    VARCHAR2,
        p_attribute11                    VARCHAR2,
        p_attribute12                    VARCHAR2,
        p_attribute13                    VARCHAR2,
        p_attribute14                    VARCHAR2,
        p_attribute15                    VARCHAR2,
        p_attribute16           VARCHAR2,
        p_attribute17           VARCHAR2,
        p_attribute18       VARCHAR2,
        p_attribute19       VARCHAR2,
        p_attribute20       VARCHAR2,
        p_attribute21       VARCHAR2,
        p_attribute22      VARCHAR2,
        p_attribute23      VARCHAR2,
        p_attribute24      VARCHAR2,
        p_attribute25       VARCHAR2,
        p_attribute26       VARCHAR2,
        p_attribute27       VARCHAR2,
        p_attribute28       VARCHAR2,
        p_attribute29        VARCHAR2,
        p_attribute30      VARCHAR2,
        p_dpp_attribute_category    VARCHAR2,
        p_dpp_attribute1    VARCHAR2,
        p_dpp_attribute2    VARCHAR2,
        p_dpp_attribute3    VARCHAR2,
        p_dpp_attribute4    VARCHAR2,
        p_dpp_attribute5    VARCHAR2,
        p_dpp_attribute6    VARCHAR2,
        p_dpp_attribute7    VARCHAR2,
        p_dpp_attribute8    VARCHAR2,
        p_dpp_attribute9    VARCHAR2,
        p_dpp_attribute10    VARCHAR2,
        p_dpp_attribute11    VARCHAR2,
        p_dpp_attribute12    VARCHAR2,
        p_dpp_attribute13    VARCHAR2,
        p_dpp_attribute14    VARCHAR2,
        p_dpp_attribute15    VARCHAR2,
        p_dpp_attribute16    VARCHAR2,
        p_dpp_attribute17    VARCHAR2,
        p_dpp_attribute18    VARCHAR2,
        p_dpp_attribute19    VARCHAR2,
        p_dpp_attribute20    VARCHAR2,
        p_dpp_attribute21    VARCHAR2,
        p_dpp_attribute22    VARCHAR2,
        p_dpp_attribute23    VARCHAR2,
        p_dpp_attribute24    VARCHAR2,
        p_dpp_attribute25    VARCHAR2,
        p_dpp_attribute26    VARCHAR2,
        p_dpp_attribute27    VARCHAR2,
        p_dpp_attribute28    VARCHAR2,
        p_dpp_attribute29    VARCHAR2,
        p_dpp_attribute30    VARCHAR2,

        p_org_id                          NUMBER ,
        p_pre_approval_flag              VARCHAR2,
        p_approval_communication         VARCHAR2,
        p_gl_contra_liability_acct       NUMBER,
        p_gl_cost_adjustment_acct        NUMBER,
        p_default_days_covered           NUMBER,
        p_create_claim_price_increase    VARCHAR2,
        p_skip_approval_flag             VARCHAR2,
        p_skip_adjustment_flag           VARCHAR2,
	--nepanda : ER 8932673 : start
        p_settlement_method_supp_inc  VARCHAR2,
        p_settlement_method_supp_dec  VARCHAR2,
        p_settlement_method_customer  VARCHAR2,
	--nepanda : ER 8932673 : end
        p_authorization_period           NUMBER,
        p_grace_days                     NUMBER,
        p_allow_qty_increase             VARCHAR2,
        p_qty_increase_tolerance         NUMBER,
        p_request_communication          VARCHAR2,
        p_claim_communication            VARCHAR2,
        p_claim_frequency                NUMBER,
        p_claim_frequency_unit           VARCHAR2,
        p_claim_computation_basis        NUMBER,
        p_claim_currency_code            VARCHAR2,
        p_min_claim_amt                  NUMBER,
        p_min_claim_amt_line_lvl         NUMBER,
        p_auto_debit                     VARCHAR2,
        p_days_before_claiming_debit     NUMBER
        )

IS
   CURSOR C IS
      SELECT *
      FROM ozf_supp_trd_prfls_all
      WHERE supp_trade_profile_id =  p_supp_trade_profile_id
      FOR UPDATE of supp_trade_profile_id NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
   OPEN c;
   FETCH c INTO Recinfo;
   If (c%NOTFOUND) then
   CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
   CLOSE C;
   IF(
           (      Recinfo.supp_trade_profile_id = p_supp_trade_profile_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.party_id = p_party_id)
            OR (    ( Recinfo.party_id IS NULL )
                AND (  p_party_id IS NULL )))
       AND (    ( Recinfo.site_use_id = p_site_use_id)
            OR (    ( Recinfo.site_use_id IS NULL )
                AND (  p_site_use_id IS NULL )))
       AND (    ( Recinfo.pre_approval_flag = p_pre_approval_flag)
            OR (    ( Recinfo.pre_approval_flag IS NULL )
                AND (  p_pre_approval_flag IS NULL )))
       AND (    ( Recinfo.approval_communication = p_approval_communication)
            OR (    ( Recinfo.approval_communication IS NULL )
                AND (  p_approval_communication IS NULL )))
       AND (    ( Recinfo.gl_contra_liability_acct = p_gl_contra_liability_acct)
            OR (    ( Recinfo.gl_contra_liability_acct IS NULL )
                AND (  p_gl_contra_liability_acct IS NULL )))
       AND (    ( Recinfo.gl_cost_adjustment_acct = p_gl_cost_adjustment_acct)
            OR (    ( Recinfo.gl_cost_adjustment_acct IS NULL )
                AND (  p_gl_cost_adjustment_acct IS NULL )))

       AND (    ( Recinfo.default_days_covered = p_default_days_covered)
            OR (    ( Recinfo.default_days_covered IS NULL )
                AND (  p_default_days_covered IS NULL )))

       AND (    ( Recinfo.create_claim_price_increase = p_create_claim_price_increase)
            OR (    ( Recinfo.create_claim_price_increase IS NULL )
                AND (  p_create_claim_price_increase IS NULL )))

       AND (    ( Recinfo.skip_approval_flag = p_skip_approval_flag)
            OR (    ( Recinfo.skip_approval_flag IS NULL )
                AND (  p_skip_approval_flag IS NULL )))

       AND (    ( Recinfo.skip_adjustment_flag = p_skip_adjustment_flag)
            OR (    ( Recinfo.skip_adjustment_flag IS NULL )
                AND (  p_skip_adjustment_flag IS NULL )))

	--nepanda : ER 8932673 : start
      AND (    ( Recinfo.settlement_method_supplier_inc = p_settlement_method_supp_inc)
            OR (    ( Recinfo.settlement_method_supplier_inc IS NULL )
                AND (  p_settlement_method_supp_inc IS NULL )))

      AND (    ( Recinfo.settlement_method_supplier_dec = p_settlement_method_supp_dec)
            OR (    ( Recinfo.settlement_method_supplier_dec IS NULL )
                AND (  p_settlement_method_supp_dec IS NULL )))

      AND (    ( Recinfo.settlement_method_customer = p_settlement_method_customer)
            OR (    ( Recinfo.settlement_method_customer IS NULL )
                AND (  p_settlement_method_customer IS NULL )))
	--nepanda : ER 8932673 : end

       AND (    ( Recinfo.authorization_period= p_authorization_period)
            OR (    ( Recinfo.authorization_period IS NULL )
                AND (  p_authorization_period IS NULL )))


       AND (    ( Recinfo.grace_days = p_grace_days)
            OR (    ( Recinfo.grace_days IS NULL )
                AND (  p_grace_days IS NULL )))

       AND (    ( Recinfo.allow_qty_increase = p_allow_qty_increase)
            OR (    ( Recinfo.allow_qty_increase IS NULL )
                AND (  p_allow_qty_increase IS NULL )))

       AND (    ( Recinfo.qty_increase_tolerance = p_qty_increase_tolerance)
            OR (    ( Recinfo.qty_increase_tolerance IS NULL )
                AND (  p_qty_increase_tolerance IS NULL )))


       AND (    ( Recinfo.request_communication = p_request_communication)
            OR (    ( Recinfo.request_communication IS NULL )
                AND (  p_request_communication IS NULL )))

       AND (    ( Recinfo.claim_communication = p_claim_communication)
            OR (    ( Recinfo.claim_communication IS NULL )
                AND (  p_claim_communication IS NULL )))

       AND (    ( Recinfo.claim_frequency = p_claim_frequency)
            OR (    ( Recinfo.claim_frequency IS NULL )
                AND (  p_claim_frequency IS NULL )))


       AND (    ( Recinfo.claim_frequency_unit = p_claim_frequency_unit)
            OR (    ( Recinfo.claim_frequency_unit IS NULL )
                AND (  p_claim_frequency_unit IS NULL )))

       AND (    ( Recinfo.claim_computation_basis = p_claim_computation_basis)
            OR (    ( Recinfo.claim_computation_basis IS NULL )
                AND (  p_claim_computation_basis IS NULL )))

       AND (    ( Recinfo.claim_currency_code = p_claim_currency_code)
            OR (    ( Recinfo.claim_currency_code IS NULL )
                AND (  p_claim_currency_code IS NULL )))

       AND (    ( Recinfo.min_claim_amt = p_min_claim_amt)
            OR (    ( Recinfo.min_claim_amt IS NULL )
                AND (  p_min_claim_amt IS NULL )))

       AND (    ( Recinfo.min_claim_amt_line_lvl = p_min_claim_amt_line_lvl)
            OR (    ( Recinfo.min_claim_amt_line_lvl IS NULL )
                AND (  p_min_claim_amt_line_lvl IS NULL )))


       AND (    ( Recinfo.auto_debit = p_auto_debit)
            OR (    ( Recinfo.auto_debit IS NULL )
                AND (  p_auto_debit IS NULL )))

       AND (    ( Recinfo.days_before_claiming_debit = p_days_before_claiming_debit)
            OR (    ( Recinfo.days_before_claiming_debit IS NULL )
                AND (  p_days_before_claiming_debit IS NULL )))

       AND (    ( Recinfo.cust_account_id = p_cust_account_id)
            OR (    ( Recinfo.cust_account_id IS NULL )
                AND (  p_cust_account_id IS NULL )))
       AND (    ( Recinfo.cust_acct_site_id = p_cust_acct_site_id)
            OR (    ( Recinfo.cust_acct_site_id IS NULL )
                AND (  p_cust_acct_site_id IS NULL )))
       AND (    ( Recinfo.supplier_id = p_supplier_id)
            OR (    ( Recinfo.supplier_id IS NULL )
                AND (  p_supplier_id IS NULL )))
       AND (    ( Recinfo.supplier_site_id = p_supplier_site_id)
            OR (    ( Recinfo.supplier_site_id IS NULL )
                AND (  p_supplier_site_id IS NULL )))

       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.attribute16 = p_attribute16)
            OR (    ( Recinfo.attribute16 IS NULL )
                AND (  p_attribute16 IS NULL )))
       AND (    ( Recinfo.attribute17 = p_attribute17)
            OR (    ( Recinfo.attribute17 IS NULL )
                AND (  p_attribute17 IS NULL )))
       AND (    ( Recinfo.attribute18 = p_attribute18)
            OR (    ( Recinfo.attribute18 IS NULL )
                AND (  p_attribute18 IS NULL )))
       AND (    ( Recinfo.attribute19 = p_attribute19)
            OR (    ( Recinfo.attribute19 IS NULL )
                AND (  p_attribute19 IS NULL )))
       AND (    ( Recinfo.attribute20 = p_attribute20)
            OR (    ( Recinfo.attribute20 IS NULL )
                AND (  p_attribute20 IS NULL )))
       AND (    ( Recinfo.attribute21 = p_attribute21)
            OR (    ( Recinfo.attribute21 IS NULL )
                AND (  p_attribute21 IS NULL )))
       AND (    ( Recinfo.attribute22 = p_attribute22)
            OR (    ( Recinfo.attribute22 IS NULL )
                AND (  p_attribute22 IS NULL )))
       AND (    ( Recinfo.attribute23 = p_attribute23)
            OR (    ( Recinfo.attribute23 IS NULL )
                AND (  p_attribute23 IS NULL )))
       AND (    ( Recinfo.attribute24 = p_attribute24)
            OR (    ( Recinfo.attribute24 IS NULL )
                AND (  p_attribute24 IS NULL )))
       AND (    ( Recinfo.attribute25 = p_attribute25)
            OR (    ( Recinfo.attribute25 IS NULL )
                AND (  p_attribute25 IS NULL )))
       AND (    ( Recinfo.attribute26 = p_attribute26)
            OR (    ( Recinfo.attribute26 IS NULL )
                AND (  p_attribute26 IS NULL )))
       AND (    ( Recinfo.attribute27 = p_attribute27)
            OR (    ( Recinfo.attribute27 IS NULL )
                AND (  p_attribute27 IS NULL )))
       AND (    ( Recinfo.attribute28 = p_attribute28)
            OR (    ( Recinfo.attribute28 IS NULL )
                AND (  p_attribute28 IS NULL )))
       AND (    ( Recinfo.attribute29 = p_attribute29)
            OR (    ( Recinfo.attribute29 IS NULL )
                AND (  p_attribute19 IS NULL )))
       AND (    ( Recinfo.attribute30 = p_attribute30)
            OR (    ( Recinfo.attribute30 IS NULL )
                AND (  p_attribute30 IS NULL )))
AND (    ( Recinfo.dpp_attribute_category = p_dpp_attribute_category)
            OR (    ( Recinfo.dpp_attribute_category IS NULL )
                AND (  p_dpp_attribute_category IS NULL )))
       AND (    ( Recinfo.dpp_attribute1 = p_dpp_attribute1)
            OR (    ( Recinfo.dpp_attribute1 IS NULL )
                AND (  p_dpp_attribute1 IS NULL )))
       AND (    ( Recinfo.dpp_attribute2 = p_dpp_attribute2)
            OR (    ( Recinfo.dpp_attribute2 IS NULL )
                AND (  p_dpp_attribute2 IS NULL )))
       AND (    ( Recinfo.dpp_attribute3 = p_dpp_attribute3)
            OR (    ( Recinfo.dpp_attribute3 IS NULL )
                AND (  p_dpp_attribute3 IS NULL )))
       AND (    ( Recinfo.dpp_attribute4 = p_dpp_attribute4)
            OR (    ( Recinfo.dpp_attribute4 IS NULL )
                AND (  p_dpp_attribute4 IS NULL )))
       AND (    ( Recinfo.dpp_attribute5 = p_dpp_attribute5)
            OR (    ( Recinfo.dpp_attribute5 IS NULL )
                AND (  p_dpp_attribute5 IS NULL )))
       AND (    ( Recinfo.dpp_attribute6 = p_dpp_attribute6)
            OR (    ( Recinfo.dpp_attribute6 IS NULL )
                AND (  p_dpp_attribute6 IS NULL )))
       AND (    ( Recinfo.dpp_attribute7 = p_dpp_attribute7)
            OR (    ( Recinfo.dpp_attribute7 IS NULL )
                AND (  p_dpp_attribute7 IS NULL )))
       AND (    ( Recinfo.dpp_attribute8 = p_dpp_attribute8)
            OR (    ( Recinfo.dpp_attribute8 IS NULL )
                AND (  p_dpp_attribute8 IS NULL )))
       AND (    ( Recinfo.dpp_attribute9 = p_dpp_attribute9)
            OR (    ( Recinfo.dpp_attribute9 IS NULL )
                AND (  p_dpp_attribute9 IS NULL )))
       AND (    ( Recinfo.dpp_attribute10 = p_dpp_attribute10)
            OR (    ( Recinfo.dpp_attribute10 IS NULL )
                AND (  p_dpp_attribute10 IS NULL )))
       AND (    ( Recinfo.dpp_attribute11 = p_dpp_attribute11)
            OR (    ( Recinfo.dpp_attribute11 IS NULL )
                AND (  p_dpp_attribute11 IS NULL )))
       AND (    ( Recinfo.dpp_attribute12 = p_dpp_attribute12)
            OR (    ( Recinfo.dpp_attribute12 IS NULL )
                AND (  p_dpp_attribute12 IS NULL )))
       AND (    ( Recinfo.dpp_attribute13 = p_dpp_attribute13)
            OR (    ( Recinfo.dpp_attribute13 IS NULL )
                AND (  p_dpp_attribute13 IS NULL )))
       AND (    ( Recinfo.dpp_attribute14 = p_dpp_attribute14)
            OR (    ( Recinfo.dpp_attribute14 IS NULL )
                AND (  p_dpp_attribute14 IS NULL )))
       AND (    ( Recinfo.dpp_attribute15 = p_dpp_attribute15)
            OR (    ( Recinfo.dpp_attribute15 IS NULL )
                AND (  p_dpp_attribute15 IS NULL )))
       AND (    ( Recinfo.dpp_attribute16 = p_dpp_attribute16)
            OR (    ( Recinfo.dpp_attribute16 IS NULL )
                AND (  p_dpp_attribute16 IS NULL )))
       AND (    ( Recinfo.dpp_attribute17 = p_dpp_attribute17)
            OR (    ( Recinfo.dpp_attribute17 IS NULL )
                AND (  p_dpp_attribute17 IS NULL )))
       AND (    ( Recinfo.dpp_attribute18 = p_dpp_attribute18)
            OR (    ( Recinfo.dpp_attribute18 IS NULL )
                AND (  p_dpp_attribute18 IS NULL )))
       AND (    ( Recinfo.dpp_attribute19 = p_dpp_attribute19)
            OR (    ( Recinfo.dpp_attribute19 IS NULL )
                AND (  p_dpp_attribute19 IS NULL )))
       AND (    ( Recinfo.dpp_attribute20 = p_dpp_attribute20)
            OR (    ( Recinfo.dpp_attribute20 IS NULL )
                AND (  p_dpp_attribute20 IS NULL )))
       AND (    ( Recinfo.dpp_attribute21 = p_dpp_attribute21)
            OR (    ( Recinfo.dpp_attribute21 IS NULL )
                AND (  p_dpp_attribute21 IS NULL )))
       AND (    ( Recinfo.dpp_attribute22 = p_dpp_attribute22)
            OR (    ( Recinfo.dpp_attribute22 IS NULL )
                AND (  p_dpp_attribute22 IS NULL )))
       AND (    ( Recinfo.dpp_attribute23 = p_dpp_attribute23)
            OR (    ( Recinfo.dpp_attribute23 IS NULL )
                AND (  p_dpp_attribute23 IS NULL )))
       AND (    ( Recinfo.dpp_attribute24 = p_dpp_attribute24)
            OR (    ( Recinfo.dpp_attribute24 IS NULL )
                AND (  p_dpp_attribute24 IS NULL )))
       AND (    ( Recinfo.dpp_attribute25 = p_dpp_attribute25)
            OR (    ( Recinfo.dpp_attribute25 IS NULL )
                AND (  p_dpp_attribute25 IS NULL )))
       AND (    ( Recinfo.dpp_attribute26 = p_dpp_attribute26)
            OR (    ( Recinfo.dpp_attribute26 IS NULL )
                AND (  p_dpp_attribute26 IS NULL )))
       AND (    ( Recinfo.dpp_attribute27 = p_dpp_attribute27)
            OR (    ( Recinfo.dpp_attribute27 IS NULL )
                AND (  p_dpp_attribute27 IS NULL )))
       AND (    ( Recinfo.dpp_attribute28 = p_dpp_attribute28)
            OR (    ( Recinfo.dpp_attribute28 IS NULL )
                AND (  p_dpp_attribute28 IS NULL )))
       AND (    ( Recinfo.dpp_attribute29 = p_dpp_attribute29)
            OR (    ( Recinfo.dpp_attribute29 IS NULL )
                AND (  p_dpp_attribute19 IS NULL )))
       AND (    ( Recinfo.dpp_attribute30 = p_dpp_attribute30)
            OR (    ( Recinfo.dpp_attribute30 IS NULL )
                AND (  p_dpp_attribute30 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))

       ) THEN
       RETURN;
   ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_supp_trd_prfls_PKG;



/
