--------------------------------------------------------
--  DDL for Package Body OKS_HZ_CUSTOMER_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_HZ_CUSTOMER_ACCOUNTS_PVT" AS
/* $Header: OKSSCOTB.pls 120.2 2006/04/13 05:39:04 npalepu noship $ */

 procedure init (p_account_rec     OUT NOCOPY hz_cust_account_v2pub.cust_account_rec_type,
                 p_cust_prof_rec  OUT NOCOPY hz_customer_profile_v2pub.customer_profile_rec_type)
 IS
   G_MISS_NUM      CONSTANT NUMBER   := 9.99E125;
   G_MISS_CHAR     CONSTANT VARCHAR2(1) := chr(0);
   G_MISS_DATE     CONSTANT DATE    := to_date('1','j');
 BEGIN
   p_account_rec.cust_account_id                 :=              G_MISS_NUM;
   p_account_rec.account_number                  :=              G_MISS_CHAR;
--   p_account_rec.wh_update_date                  :=              G_MISS_DATE;
   p_account_rec.attribute_category              :=              G_MISS_CHAR;
   p_account_rec.attribute1                      :=              G_MISS_CHAR;
   p_account_rec.attribute2                      :=              G_MISS_CHAR;
   p_account_rec.attribute3                      :=              G_MISS_CHAR;
   p_account_rec.attribute4                      :=              G_MISS_CHAR;
   p_account_rec.attribute5                      :=              G_MISS_CHAR;
   p_account_rec.attribute6                      :=              G_MISS_CHAR;
   p_account_rec.attribute7                      :=              G_MISS_CHAR;
   p_account_rec.attribute8                      :=              G_MISS_CHAR;
   p_account_rec.attribute9                      :=              G_MISS_CHAR;
   p_account_rec.attribute10                     :=              G_MISS_CHAR;
   p_account_rec.attribute11                     :=              G_MISS_CHAR;
   p_account_rec.attribute12                     :=              G_MISS_CHAR;
   p_account_rec.attribute13                     :=              G_MISS_CHAR;
   p_account_rec.attribute14                     :=              G_MISS_CHAR;
   p_account_rec.attribute15                     :=              G_MISS_CHAR;
   p_account_rec.attribute16                     :=              G_MISS_CHAR;
   p_account_rec.attribute17                     :=              G_MISS_CHAR;
   p_account_rec.attribute18                     :=              G_MISS_CHAR;
   p_account_rec.attribute19                     :=              G_MISS_CHAR;
   p_account_rec.attribute20                     :=              G_MISS_CHAR;
   p_account_rec.global_attribute_category       :=               G_MISS_CHAR;
   p_account_rec.global_attribute1               :=              G_MISS_CHAR;
   p_account_rec.global_attribute2               :=              G_MISS_CHAR;
   p_account_rec.global_attribute3               :=              G_MISS_CHAR;
   p_account_rec.global_attribute4               :=              G_MISS_CHAR;
   p_account_rec.global_attribute5               :=              G_MISS_CHAR;
   p_account_rec.global_attribute6               :=              G_MISS_CHAR;
   p_account_rec.global_attribute7               :=              G_MISS_CHAR;
   p_account_rec.global_attribute8               :=              G_MISS_CHAR;
   p_account_rec.global_attribute9               :=              G_MISS_CHAR;
   p_account_rec.global_attribute10              :=              G_MISS_CHAR;
   p_account_rec.global_attribute11              :=              G_MISS_CHAR;
   p_account_rec.global_attribute12              :=              G_MISS_CHAR;
   p_account_rec.global_attribute13              :=              G_MISS_CHAR;
   p_account_rec.global_attribute14              :=              G_MISS_CHAR;
   p_account_rec.global_attribute15              :=              G_MISS_CHAR;
   p_account_rec.global_attribute16              :=              G_MISS_CHAR;
   p_account_rec.global_attribute17              :=              G_MISS_CHAR;
   p_account_rec.global_attribute18              :=              G_MISS_CHAR;
   p_account_rec.global_attribute19              :=              G_MISS_CHAR;
   p_account_rec.global_attribute20              :=              G_MISS_CHAR;
   p_account_rec.orig_system_reference           :=              G_MISS_CHAR;
   p_account_rec.status                          :=              G_MISS_CHAR;
   p_account_rec.customer_type                   :=              G_MISS_CHAR;
   p_account_rec.customer_class_code             :=              G_MISS_CHAR;
   p_account_rec.primary_salesrep_id             :=              G_MISS_NUM;
   p_account_rec.sales_channel_code              :=              G_MISS_CHAR;
   p_account_rec.order_type_id                   :=              G_MISS_NUM;
   p_account_rec.price_list_id                   :=              G_MISS_NUM;
 --  p_account_rec.category_code                   :=              G_MISS_CHAR;
 --  p_account_rec.reference_use_flag              :=              G_MISS_CHAR;
 --  p_account_rec.subcategory_code                :=              G_MISS_CHAR;
   p_account_rec.tax_code                        :=              G_MISS_CHAR;
 --  p_account_rec.third_party_flag                :=              G_MISS_CHAR;
 --  p_account_rec.competitor_flag                 :=              G_MISS_CHAR;
   p_account_rec.fob_point                       :=              G_MISS_CHAR;
   p_account_rec.freight_term                    :=              G_MISS_CHAR;
   p_account_rec.ship_partial                    :=              G_MISS_CHAR;
   p_account_rec.ship_via                        :=              G_MISS_CHAR;
   p_account_rec.warehouse_id                    :=              G_MISS_NUM;
 --  p_account_rec.payment_term_id                 :=              G_MISS_NUM;
   p_account_rec.tax_header_level_flag           :=              G_MISS_CHAR;
   p_account_rec.tax_rounding_rule               :=              G_MISS_CHAR;
   p_account_rec.coterminate_day_month           :=              G_MISS_CHAR;
   p_account_rec.primary_specialist_id           :=              G_MISS_NUM;
   p_account_rec.secondary_specialist_id         :=              G_MISS_NUM;
   p_account_rec.account_liable_flag             :=              G_MISS_CHAR;
 --  p_account_rec.restriction_limit_amount        :=              G_MISS_NUM;
   p_account_rec.current_balance                 :=              G_MISS_NUM;
 --  p_account_rec.password_text                   :=              G_MISS_CHAR;
 --  p_account_rec.high_priority_indicator         :=              G_MISS_CHAR;
   p_account_rec.account_established_date        :=              G_MISS_DATE;
   p_account_rec.account_termination_date        :=              G_MISS_DATE;
   p_account_rec.account_activation_date         :=              G_MISS_DATE;
 --  p_account_rec.credit_classification_code      :=              G_MISS_CHAR;
   p_account_rec.department                      :=              G_MISS_CHAR;
 --  p_account_rec.major_account_number            :=              G_MISS_CHAR;
 --  p_account_rec.hotwatch_service_flag           :=              G_MISS_CHAR;
 --  p_account_rec.hotwatch_svc_bal_ind            :=              G_MISS_CHAR;
   p_account_rec.held_bill_expiration_date       :=              G_MISS_DATE;
   p_account_rec.hold_bill_flag                  :=              G_MISS_CHAR;
 --  p_account_rec.high_priority_remarks           :=              G_MISS_CHAR;
 --  p_account_rec.po_effective_date               :=              G_MISS_DATE;
 --  p_account_rec.po_expiration_date              :=              G_MISS_DATE;
   p_account_rec.realtime_rate_flag              :=              G_MISS_CHAR;
 --  p_account_rec.single_user_flag                :=              G_MISS_CHAR;
 --  p_account_rec.watch_account_flag              :=              G_MISS_CHAR;
 --  p_account_rec.watch_balance_indicator         :=              G_MISS_CHAR;
 --  p_account_rec.geo_code                        :=              G_MISS_CHAR;
   p_account_rec.acct_life_cycle_status          :=              G_MISS_CHAR;
   p_account_rec.account_name                    :=              G_MISS_CHAR;
   p_account_rec.deposit_refund_method           :=              G_MISS_CHAR;
   p_account_rec.dormant_account_flag            :=              G_MISS_CHAR;
   p_account_rec.npa_number                      :=              G_MISS_CHAR;
 --  p_account_rec.pin_number                      :=              G_MISS_NUM;
   p_account_rec.suspension_date                 :=              G_MISS_DATE;
 --  p_account_rec.write_off_adjustment_amount     :=              G_MISS_NUM;
 --  p_account_rec.write_off_payment_amount        :=              G_MISS_NUM;
 --  p_account_rec.write_off_amount                :=              G_MISS_NUM;
   p_account_rec.source_code                     :=              G_MISS_CHAR;
 --  p_account_rec.competitor_type                 :=              G_MISS_CHAR;
   p_account_rec.comments                        :=              G_MISS_CHAR;
   p_account_rec.dates_negative_tolerance        :=              G_MISS_NUM;
   p_account_rec.dates_positive_tolerance        :=              G_MISS_NUM;
   p_account_rec.date_type_preference            :=              G_MISS_CHAR;
   p_account_rec.over_shipment_tolerance         :=              G_MISS_NUM;
   p_account_rec.under_shipment_tolerance        :=              G_MISS_NUM;
   p_account_rec.over_return_tolerance           :=              G_MISS_NUM;
   p_account_rec.under_return_tolerance          :=              G_MISS_NUM;
   p_account_rec.item_cross_ref_pref             :=              G_MISS_CHAR;
   p_account_rec.ship_sets_include_lines_flag    :=              G_MISS_CHAR;
   p_account_rec.arrivalsets_include_lines_flag  :=              G_MISS_CHAR;
   p_account_rec.sched_date_push_flag            :=              G_MISS_CHAR;
   p_account_rec.invoice_quantity_rule           :=              G_MISS_CHAR;
   p_account_rec.pricing_event                   :=              G_MISS_CHAR;
 --  p_account_rec.account_replication_key         :=              G_MISS_NUM;
   p_account_rec.status_update_date              :=              G_MISS_DATE;
   p_account_rec.autopay_flag                    :=              G_MISS_CHAR;
   p_account_rec.notify_flag                     :=              G_MISS_CHAR;
   p_account_rec.last_batch_id                   :=              G_MISS_NUM;

  --
   p_cust_prof_rec.cust_account_profile_id      :=              G_MISS_NUM;
   p_cust_prof_rec.cust_account_id              :=              G_MISS_NUM;
   p_cust_prof_rec.status                       :=              G_MISS_CHAR;
   p_cust_prof_rec.collector_id                 :=              G_MISS_NUM;
   p_cust_prof_rec.credit_analyst_id            :=              G_MISS_NUM;
   p_cust_prof_rec.credit_checking              :=              G_MISS_CHAR;
   p_cust_prof_rec.next_credit_review_date      :=              G_MISS_DATE;
   p_cust_prof_rec.tolerance                    :=              G_MISS_NUM;
   p_cust_prof_rec.discount_terms               :=              G_MISS_CHAR;
   p_cust_prof_rec.dunning_letters              :=              G_MISS_CHAR;
   p_cust_prof_rec.interest_charges             :=              G_MISS_CHAR;
   p_cust_prof_rec.send_statements              :=              G_MISS_CHAR;
   p_cust_prof_rec.credit_balance_statements    :=              G_MISS_CHAR;
   p_cust_prof_rec.credit_hold                  :=              G_MISS_CHAR;
   p_cust_prof_rec.profile_class_id             :=              G_MISS_NUM;
   p_cust_prof_rec.site_use_id                  :=              G_MISS_NUM;
   p_cust_prof_rec.credit_rating                :=              G_MISS_CHAR;
   p_cust_prof_rec.risk_code                    :=              G_MISS_CHAR;
   p_cust_prof_rec.standard_terms               :=              G_MISS_NUM;
   p_cust_prof_rec.override_terms               :=              G_MISS_CHAR;
   p_cust_prof_rec.dunning_letter_set_id        :=              G_MISS_NUM;
   p_cust_prof_rec.interest_period_days         :=              G_MISS_NUM;
   p_cust_prof_rec.payment_grace_days           :=              G_MISS_NUM;
   p_cust_prof_rec.discount_grace_days          :=              G_MISS_NUM;
   p_cust_prof_rec.statement_cycle_id           :=              G_MISS_NUM;
   p_cust_prof_rec.account_status               :=              G_MISS_CHAR;
   p_cust_prof_rec.percent_collectable          :=              G_MISS_NUM;
   p_cust_prof_rec.autocash_hierarchy_id        :=              G_MISS_NUM;
   p_cust_prof_rec.attribute_category           :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute1                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute2                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute3                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute4                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute5                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute6                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute7                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute8                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute9                   :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute10                  :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute11                  :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute12                  :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute13                  :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute14                  :=              G_MISS_CHAR;
   p_cust_prof_rec.attribute15                  :=              G_MISS_CHAR;
 --  p_cust_prof_rec.wh_update_date               :=              G_MISS_DATE;
   p_cust_prof_rec.auto_rec_incl_disputed_flag  :=              G_MISS_CHAR;
   p_cust_prof_rec.tax_printing_option           :=              G_MISS_CHAR;
   p_cust_prof_rec.charge_on_finance_charge_flag :=              G_MISS_CHAR;
   p_cust_prof_rec.grouping_rule_id              :=              G_MISS_NUM;
   p_cust_prof_rec.clearing_days                  :=              G_MISS_NUM;
   p_cust_prof_rec.jgzz_attribute_category       :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute1               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute2               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute3               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute4               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute5               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute6               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute7               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute8               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute9               :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute10              :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute11              :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute12              :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute13              :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute14              :=              G_MISS_CHAR;
   p_cust_prof_rec.jgzz_attribute15              :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute1             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute2             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute3             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute4             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute5             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute6             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute7             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute8             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute9             :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute10            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute11            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute12            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute13            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute14            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute15            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute16            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute17            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute18            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute19            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute20            :=              G_MISS_CHAR;
   p_cust_prof_rec.global_attribute_category     :=              G_MISS_CHAR;
   p_cust_prof_rec.cons_inv_flag                 :=              G_MISS_CHAR;
   p_cust_prof_rec.cons_inv_type                 :=              G_MISS_CHAR;
   p_cust_prof_rec.autocash_hierarchy_id_for_adr :=              G_MISS_NUM;
   p_cust_prof_rec.lockbox_matching_option       :=              G_MISS_CHAR;
  end;


  procedure UPDATE_ROW (p_cust_account_id IN number,
                        p_coterm_day_month IN varchar2)
  is

   cursor cu_last_update(cp_cust_account_id  IN NUMBER)
   is
   --npalepu modified on 4/13/2006 for bug # 5139425
   /* SELECT last_update_date  */
   SELECT last_update_date,object_version_number
   --end npalepu
   FROM HZ_CUST_ACCOUNTS
   WHERE cust_account_id= cp_cust_account_id;

   cr_last_update      cu_last_update%ROWTYPE;

   l_account_rec   HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
   l_cust_rec      HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
   l_return_status VARCHAR2(100);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);
   l_main_id       NUMBER;
   l_nested1_id    NUMBER;
   l_nested2_id    NUMBER;
   l_validation_level NUMBER;
   --
   l_last_update_date1  DATE;
   l_last_update_date2  DATE;
   --
   -- New Parameter for Update_cust_account api
   l_object_version_number NUMBER;
   BEGIN

     --npalepu commented this call for bug # 5139425 on 4/13/2006
     /* init (l_account_rec,
          l_cust_rec); */
     --end npalepu


     l_account_rec.cust_account_id := p_cust_account_id;
     l_account_rec.coterminate_day_month := p_coterm_day_month ;
     --
     open cu_last_update(p_cust_account_id);
     fetch cu_last_update into cr_last_update;
     close cu_last_update;

     l_last_update_date1 := cr_last_update.last_update_date;
     --npalepu added for bug # 5139425 on 4/13/2006
     l_object_version_number := cr_last_update.object_version_number;
     --end npalepu

     HZ_CUST_ACCOUNT_V2PUB.update_cust_account
--     ( p_api_version => 1
     ( p_init_msg_list => 'T'
--     , p_commit => 'F'
     , p_cust_account_rec => l_account_rec
--     , p_cust_profile_rec => l_cust_rec
--     , p_acct_last_update_date => l_last_update_date1
--     , p_prof_last_update_date => l_last_update_date2
     , p_object_version_number   => l_object_version_number -- New parameter
     , x_return_status => l_return_status
     , x_msg_count => l_msg_count
     , x_msg_data => l_msg_data
--     , p_validation_level => l_validation_level
     );

     FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
        arp_util.debug(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ));
    END LOOP;
    --
   END;
 END OKS_HZ_CUSTOMER_ACCOUNTS_PVT ;

/
