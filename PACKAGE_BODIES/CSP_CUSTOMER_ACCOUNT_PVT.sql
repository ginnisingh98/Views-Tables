--------------------------------------------------------
--  DDL for Package Body CSP_CUSTOMER_ACCOUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_CUSTOMER_ACCOUNT_PVT" AS
/* $Header: cspvcusb.pls 120.4.12010000.2 2010/02/12 02:17:53 hhaugeru ship $ */
/* This procedure is a copy of hzp_cprof_pkg.create_profile_from_class. */
PROCEDURE create_profile_from_class
                (       x_customer_profile_class_id     in number,
                        x_customer_profile_id           in out nocopy number,
                        x_customer_id                   in out nocopy number,
                        x_site_use_id                   in number,
                        x_collector_id                  out nocopy number,
                        x_collector_name                out nocopy varchar2,
                        x_credit_checking               out nocopy varchar2,
                        x_tolerance                     out nocopy number,
                        x_interest_charges              out nocopy varchar2,
                        x_charge_on_fin_charge_flag     out nocopy varchar2,
                        x_interest_period_days          out nocopy number,
                        x_discount_terms                out nocopy varchar2,
                        x_discount_grace_days           out nocopy number,
                        x_statements                    out nocopy varchar2,
                        x_statement_cycle_id            out nocopy number,
                        x_statement_cycle_name          out nocopy varchar2,
                        x_credit_balance_statements     out nocopy varchar2,
                        x_standard_terms                out nocopy number,
                        x_standard_terms_name           out nocopy varchar2,
                        x_override_terms                out nocopy varchar2,
                        x_payment_grace_days            out nocopy number,
                        x_dunning_letters               out nocopy varchar2,
                        x_dunning_letter_set_id         out nocopy number,
                        x_dunning_letter_set_name       out nocopy varchar2,
                        x_autocash_hierarchy_id         out nocopy number,
                        x_autocash_hierarchy_name       out nocopy varchar2,
                        x_auto_rec_incl_disputed_flag   out nocopy varchar2,
                        x_tax_printing_option           out nocopy varchar2,
                        x_grouping_rule_id              out nocopy number,
                        x_grouping_rule_name            out nocopy varchar2,
                        x_cons_inv_flag                 out nocopy varchar2,
                        x_cons_inv_type                 out nocopy varchar2,
                        x_attribute_category            out nocopy varchar2,
                        x_attribute1                    out nocopy varchar2,
                        x_attribute2                    out nocopy varchar2,
                        x_attribute3                    out nocopy varchar2,
                        x_attribute4                    out nocopy varchar2,
                        x_attribute5                    out nocopy varchar2,
                        x_attribute6                    out nocopy varchar2,
                        x_attribute7                    out nocopy varchar2,
                        x_attribute8                    out nocopy varchar2,
                        x_attribute9                    out nocopy varchar2,
                        x_attribute10                   out nocopy varchar2,
                        x_attribute11                   out nocopy varchar2,
                        x_attribute12                   out nocopy varchar2,
                        x_attribute13                   out nocopy varchar2,
                        x_attribute14                   out nocopy varchar2,
                        x_attribute15                   out nocopy varchar2,
                        x_jgzz_attribute_category       out nocopy varchar2,
                        x_jgzz_attribute1               out nocopy varchar2,
                        x_jgzz_attribute2               out nocopy varchar2,
                        x_jgzz_attribute3               out nocopy varchar2,
                        x_jgzz_attribute4               out nocopy varchar2,
                        x_jgzz_attribute5               out nocopy varchar2,
                        x_jgzz_attribute6               out nocopy varchar2,
                        x_jgzz_attribute7               out nocopy varchar2,
                        x_jgzz_attribute8               out nocopy varchar2,
                        x_jgzz_attribute9               out nocopy varchar2,
                        x_jgzz_attribute10              out nocopy varchar2,
                        x_jgzz_attribute11              out nocopy varchar2,
                        x_jgzz_attribute12              out nocopy varchar2,
                        x_jgzz_attribute13              out nocopy varchar2,
                        x_jgzz_attribute14              out nocopy varchar2,
                        x_jgzz_attribute15              out nocopy varchar2,
                        x_global_attribute_category     out nocopy varchar2,
                        x_global_attribute1             out nocopy varchar2,
                        x_global_attribute2             out nocopy varchar2,
                        x_global_attribute3             out nocopy varchar2,
                        x_global_attribute4             out nocopy varchar2,
                        x_global_attribute5             out nocopy varchar2,
                        x_global_attribute6             out nocopy varchar2,
                        x_global_attribute7             out nocopy varchar2,
                        x_global_attribute8             out nocopy varchar2,
                        x_global_attribute9             out nocopy varchar2,
                        x_global_attribute10            out nocopy varchar2,
                        x_global_attribute11            out nocopy varchar2,
                        x_global_attribute12            out nocopy varchar2,
                        x_global_attribute13            out nocopy varchar2,
                        x_global_attribute14            out nocopy varchar2,
                        x_global_attribute15            out nocopy varchar2,
                        x_global_attribute16            out nocopy varchar2,
                        x_global_attribute17            out nocopy varchar2,
                        x_global_attribute18            out nocopy varchar2,
                        x_global_attribute19            out nocopy varchar2,
                        x_global_attribute20            out nocopy varchar2,
                        x_lockbox_matching_option       out nocopy varchar2,
                        x_lockbox_matching_name         out nocopy varchar2,
                        x_autocash_hierarchy_id_adr     out nocopy number,
                        x_autocash_hierarchy_name_adr   out nocopy varchar2,
                        x_return_status                 out nocopy varchar2,
                        x_msg_count                     out nocopy number,
                        x_msg_data                      out nocopy varchar2
                        ) is

--
prof_amt_rec      HZ_CUSTOMER_PROFILE_V2PUB.cust_profile_amt_rec_type;
x_cust_acct_profile_amt_id   NUMBER;
tmp_var                VARCHAR2(2000);
i                      number;
tmp_var1                VARCHAR2(2000);

cursor c_prof_class is
		select	collector_id,
 			collector_name,
 			credit_checking,
 			tolerance,
 			interest_charges,
 			charge_on_finance_charge_flag,
 			interest_period_days,
 			discount_terms,
 			discount_grace_days,
 			statements,
 			statement_cycle_id,
 			statement_cycle_name,
 			credit_balance_statements,
 			standard_terms,
 			standard_terms_name,
 			override_terms,
 			payment_grace_days,
 			dunning_letters,
 			dunning_letter_set_id,
 			dunning_letter_set_name,
 			autocash_hierarchy_id,
 			autocash_hierarchy_name,
 			auto_rec_incl_disputed_flag,
 			tax_printing_option,
 			grouping_rule_id,
 			grouping_rule_name,
                        cons_inv_flag,
                        cons_inv_type,
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
 			jgzz_attribute_category,
 			jgzz_attribute1,
 			jgzz_attribute2,
 			jgzz_attribute3,
 			jgzz_attribute4,
 			jgzz_attribute5,
 			jgzz_attribute6,
 			jgzz_attribute7,
 			jgzz_attribute8,
 			jgzz_attribute9,
 			jgzz_attribute10,
 			jgzz_attribute11,
 			jgzz_attribute12,
 			jgzz_attribute13,
 			jgzz_attribute14,
			jgzz_attribute15,
 			global_attribute_category,
 			global_attribute1,
 			global_attribute2,
 			global_attribute3,
 			global_attribute4,
 			global_attribute5,
 			global_attribute6,
 			global_attribute7,
 			global_attribute8,
 			global_attribute9,
 			global_attribute10,
 			global_attribute11,
 			global_attribute12,
 			global_attribute13,
 			global_attribute14,
			global_attribute15,
 			global_attribute16,
 			global_attribute17,
 			global_attribute18,
 			global_attribute19,
 			global_attribute20,
                        lockbox_matching_option,
                        lockbox_matching_option_name,
                        autocash_hierarchy_id_for_adr,
                        autocash_hierarchy_name_adr
		from	AR_CUSTOMER_PROFILE_CLASSES_V
		-- from	AR_CUST_PROF_CLASSES_TEST_V
		where	customer_profile_class_id = x_customer_profile_class_id;


cursor c_prof_class_amts is
       select
                hz_cust_profile_amts_s.nextval,
                x_customer_profile_id,
                currency_code,
                trx_credit_limit,
                overall_credit_limit,
                min_dunning_amount,
                min_dunning_invoice_amount,
                max_interest_charge,
                min_statement_amount,
                auto_rec_min_receipt_amount,
                interest_rate,
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
                min_fc_balance_amount,
                min_fc_invoice_amount,
                x_customer_id,
                x_site_use_id,
                jgzz_attribute_category,
                jgzz_attribute1,
                jgzz_attribute2,
                jgzz_attribute3,
                jgzz_attribute4,
                jgzz_attribute5,
                jgzz_attribute6,
                jgzz_attribute7,
                jgzz_attribute8,
                jgzz_attribute9,
                jgzz_attribute10,
                jgzz_attribute11,
                jgzz_attribute12,
                jgzz_attribute13,
                jgzz_attribute14,
                jgzz_attribute15,
                'CSPSHIPAD',
                GLOBAL_ATTRIBUTE1,
                GLOBAL_ATTRIBUTE2,
                GLOBAL_ATTRIBUTE3,
                GLOBAL_ATTRIBUTE4,
                GLOBAL_ATTRIBUTE5,
                GLOBAL_ATTRIBUTE6,
                GLOBAL_ATTRIBUTE7,
                GLOBAL_ATTRIBUTE8,
                GLOBAL_ATTRIBUTE9,
                GLOBAL_ATTRIBUTE10,
                GLOBAL_ATTRIBUTE11,
                GLOBAL_ATTRIBUTE12,
                GLOBAL_ATTRIBUTE13,
                GLOBAL_ATTRIBUTE14,
                GLOBAL_ATTRIBUTE15,
                GLOBAL_ATTRIBUTE16,
                GLOBAL_ATTRIBUTE17,
                GLOBAL_ATTRIBUTE18,
                GLOBAL_ATTRIBUTE19,
                GLOBAL_ATTRIBUTE20,
                GLOBAL_ATTRIBUTE_CATEGORY,
                EXCHANGE_RATE_TYPE,
                MIN_FC_INVOICE_OVERDUE_TYPE,
                MIN_FC_INVOICE_PERCENT,
                MIN_FC_BALANCE_OVERDUE_TYPE,
                MIN_FC_BALANCE_PERCENT,
                INTEREST_TYPE,
                INTEREST_FIXED_AMOUNT,
                INTEREST_SCHEDULE_ID,
                PENALTY_TYPE,
                PENALTY_RATE,
                MIN_INTEREST_CHARGE,
                PENALTY_FIXED_AMOUNT,
                PENALTY_SCHEDULE_ID
        from    hz_cust_prof_class_amts
        where   profile_class_id = x_customer_profile_class_id;

--
begin
	--
	--
	open c_prof_class;
	fetch c_prof_class
		into	x_collector_id,
 			x_collector_name,
 			x_credit_checking,
 			x_tolerance,
 			x_interest_charges,
 			x_charge_on_fin_charge_flag,
 			x_interest_period_days,
 			x_discount_terms,
 			x_discount_grace_days,
 			x_statements,
 			x_statement_cycle_id,
 			x_statement_cycle_name,
 			x_credit_balance_statements,
 			x_standard_terms,
 			x_standard_terms_name,
 			x_override_terms,
 			x_payment_grace_days,
 			x_dunning_letters,
 			x_dunning_letter_set_id,
 			x_dunning_letter_set_name,
 			x_autocash_hierarchy_id,
 			x_autocash_hierarchy_name,
 			x_auto_rec_incl_disputed_flag,
 			x_tax_printing_option,
 			x_grouping_rule_id,
 			x_grouping_rule_name,
                        x_cons_inv_flag,
                        x_cons_inv_type,
 			x_attribute_category,
 			x_attribute1,
 			x_attribute2,
 			x_attribute3,
 			x_attribute4,
 			x_attribute5,
 			x_attribute6,
 			x_attribute7,
 			x_attribute8,
 			x_attribute9,
 			x_attribute10,
 			x_attribute11,
 			x_attribute12,
 			x_attribute13,
 			x_attribute14,
			x_attribute15,
 			x_jgzz_attribute_category,
 			x_jgzz_attribute1,
 			x_jgzz_attribute2,
 			x_jgzz_attribute3,
 			x_jgzz_attribute4,
 			x_jgzz_attribute5,
 			x_jgzz_attribute6,
 			x_jgzz_attribute7,
 			x_jgzz_attribute8,
 			x_jgzz_attribute9,
 			x_jgzz_attribute10,
 			x_jgzz_attribute11,
 			x_jgzz_attribute12,
 			x_jgzz_attribute13,
 			x_jgzz_attribute14,
			x_jgzz_attribute15,
 			x_global_attribute_category,
 			x_global_attribute1,
 			x_global_attribute2,
 			x_global_attribute3,
 			x_global_attribute4,
 			x_global_attribute5,
 			x_global_attribute6,
 			x_global_attribute7,
 			x_global_attribute8,
 			x_global_attribute9,
 			x_global_attribute10,
 			x_global_attribute11,
 			x_global_attribute12,
 			x_global_attribute13,
 			x_global_attribute14,
			x_global_attribute15,
 			x_global_attribute16,
 			x_global_attribute17,
 			x_global_attribute18,
 			x_global_attribute19,
 			x_global_attribute20,
                        x_lockbox_matching_option,
                        x_lockbox_matching_name,
                        x_autocash_hierarchy_id_adr,
                        x_autocash_hierarchy_name_adr;

	--
	if (c_prof_class%NOTFOUND) then
		close c_prof_class;
		raise NO_DATA_FOUND;
	end if;
	--
	close c_prof_class;
	--
	-- If the customer_profile_id/customers_id is null we need to generate one so we
	-- can insert rows into ar_customer_profile_amounts.
	-- Customer_id wil be null when inserting a profile .
	-- and not null if they are updating an existing profile.
	--
	--
	if ( x_customer_id is null ) then
		select hz_cust_accounts_s.nextval into x_customer_id from dual;
      --  x_customer_id := FND_API.G_MISS_NUM;
	end if;
	--
	--
	If (x_customer_profile_id is null ) then
		select hz_customer_profiles_s.nextval into x_customer_profile_id from dual;
        --x_customer_profile_id := FND_API.G_MISS_NUM;
	end if;
	--
	--
	--
	--
	--  Delete only the profile_amounts that match the currency that is
        --  present in the profile_amounts of the new customer profile class.
	--
	delete  from hz_cust_profile_amts
      	where   cust_account_profile_id = x_customer_profile_id
      	and     currency_code in ( select  currency_code
              	        	   from    hz_cust_prof_class_amts
                      		   where   profile_class_id =  x_customer_profile_class_id
				 );
	--
	-- copy profile amount records from class to customer profile
	--
       open c_prof_class_amts;
       LOOP
       Fetch c_prof_class_amts into
                prof_amt_rec.cust_acct_profile_amt_id,
                prof_amt_rec.cust_account_profile_id,
                prof_amt_rec.currency_code,
                prof_amt_rec.trx_credit_limit,
                prof_amt_rec.overall_credit_limit,
                prof_amt_rec.min_dunning_amount,
                prof_amt_rec.min_dunning_invoice_amount,
                prof_amt_rec.max_interest_charge,
                prof_amt_rec.min_statement_amount,
                prof_amt_rec.auto_rec_min_receipt_amount,
                prof_amt_rec.interest_rate,
                prof_amt_rec.attribute_category,
                prof_amt_rec.attribute1,
                prof_amt_rec.attribute2,
                prof_amt_rec.attribute3,
                prof_amt_rec.attribute4,
                prof_amt_rec.attribute5,
                prof_amt_rec.attribute6,
                prof_amt_rec.attribute7,
                prof_amt_rec.attribute8,
                prof_amt_rec.attribute9,
                prof_amt_rec.attribute10,
                prof_amt_rec.attribute11,
                prof_amt_rec.attribute12,
                prof_amt_rec.attribute13,
                prof_amt_rec.attribute14,
                prof_amt_rec.attribute15,
                prof_amt_rec.min_fc_balance_amount,
                prof_amt_rec.min_fc_invoice_amount,
                prof_amt_rec.cust_account_id,
                prof_amt_rec.site_use_id,
                prof_amt_rec.jgzz_attribute_category,
                prof_amt_rec.jgzz_attribute1,
                prof_amt_rec.jgzz_attribute2,
                prof_amt_rec.jgzz_attribute3,
                prof_amt_rec.jgzz_attribute4,
                prof_amt_rec.jgzz_attribute5,
                prof_amt_rec.jgzz_attribute6,
                prof_amt_rec.jgzz_attribute7,
                prof_amt_rec.jgzz_attribute8,
                prof_amt_rec.jgzz_attribute9,
                prof_amt_rec.jgzz_attribute10,
                prof_amt_rec.jgzz_attribute11,
                prof_amt_rec.jgzz_attribute12,
                prof_amt_rec.jgzz_attribute13,
                prof_amt_rec.jgzz_attribute14,
                prof_amt_rec.jgzz_attribute15,
                prof_amt_rec.created_by_module,
                prof_amt_rec.GLOBAL_ATTRIBUTE1,
                prof_amt_rec.GLOBAL_ATTRIBUTE2,
                prof_amt_rec.GLOBAL_ATTRIBUTE3,
                prof_amt_rec.GLOBAL_ATTRIBUTE4,
                prof_amt_rec.GLOBAL_ATTRIBUTE5,
                prof_amt_rec.GLOBAL_ATTRIBUTE6,
                prof_amt_rec.GLOBAL_ATTRIBUTE7,
                prof_amt_rec.GLOBAL_ATTRIBUTE8,
                prof_amt_rec.GLOBAL_ATTRIBUTE9,
                prof_amt_rec.GLOBAL_ATTRIBUTE10,
                prof_amt_rec.GLOBAL_ATTRIBUTE11,
                prof_amt_rec.GLOBAL_ATTRIBUTE12,
                prof_amt_rec.GLOBAL_ATTRIBUTE13,
                prof_amt_rec.GLOBAL_ATTRIBUTE14,
                prof_amt_rec.GLOBAL_ATTRIBUTE15,
                prof_amt_rec.GLOBAL_ATTRIBUTE16,
                prof_amt_rec.GLOBAL_ATTRIBUTE17,
                prof_amt_rec.GLOBAL_ATTRIBUTE18,
                prof_amt_rec.GLOBAL_ATTRIBUTE19,
                prof_amt_rec.GLOBAL_ATTRIBUTE20,
                prof_amt_rec.GLOBAL_ATTRIBUTE_CATEGORY,
                prof_amt_rec.EXCHANGE_RATE_TYPE,
                prof_amt_rec.MIN_FC_INVOICE_OVERDUE_TYPE,
                prof_amt_rec.MIN_FC_INVOICE_PERCENT,
                prof_amt_rec.MIN_FC_BALANCE_OVERDUE_TYPE,
                prof_amt_rec.MIN_FC_BALANCE_PERCENT,
                prof_amt_rec.INTEREST_TYPE,
                prof_amt_rec.INTEREST_FIXED_AMOUNT,
                prof_amt_rec.INTEREST_SCHEDULE_ID,
                prof_amt_rec.PENALTY_TYPE,
                prof_amt_rec.PENALTY_RATE,
                prof_amt_rec.MIN_INTEREST_CHARGE,
                prof_amt_rec.PENALTY_FIXED_AMOUNT,
                prof_amt_rec.PENALTY_SCHEDULE_ID;

                exit when c_prof_class_amts%notfound;

   if prof_amt_rec.site_use_id is null then
     prof_amt_rec.site_use_id := -1;
   end if;

   HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
    p_init_msg_list             => FND_API.G_FALSE,
    p_check_foreign_key        =>  FND_API.G_FALSE,
    p_cust_profile_amt_rec     => prof_amt_rec,
    x_cust_acct_profile_amt_id => x_cust_acct_profile_amt_id,
    x_return_status           => x_return_status,
    x_msg_count              => x_msg_count,
    x_msg_data              => x_msg_data);

    update hz_cust_profile_amts
    set    site_use_id = null
    where  cust_acct_profile_amt_id = x_cust_acct_profile_amt_id
    and    site_use_id = -1;

      End loop;
-- insert into tk7 values (x_return_status, x_msg_count, 'profile from class >>>'||x_msg_data);
 if x_msg_count > 1 then
   FOR i IN 1..x_msg_count  LOOP
  tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
  -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
  tmp_var1 := tmp_var1 || ' '|| tmp_var;
  END LOOP;
  x_msg_data := tmp_var1;
  -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
END IF;


      close c_prof_class_amts;


	--
	--
end create_profile_from_class;
PROCEDURE insert_person_row(
                       c_cust_account_id                IN OUT NOCOPY NUMBER ,
                       c_party_id                       IN OUT NOCOPY NUMBER,
                       c_account_number                  IN OUT NOCOPY VARCHAR2,
                       c_Attribute_Category              IN VARCHAR2,
                       c_Attribute1                      IN VARCHAR2,
                       c_Attribute2                      IN VARCHAR2,
                       c_Attribute3                      IN VARCHAR2,
                       c_Attribute4                      IN VARCHAR2,
                       c_Attribute5                      IN VARCHAR2,
                       c_Attribute6                      IN VARCHAR2,
                       c_Attribute7                      IN VARCHAR2,
                       c_Attribute8                      IN VARCHAR2,
                       c_Attribute9                      IN VARCHAR2,
                       c_Attribute10                     IN VARCHAR2,
                       c_Attribute11                     IN VARCHAR2,
                       c_Attribute12                     IN VARCHAR2,
                       c_Attribute13                     IN VARCHAR2,
                       c_Attribute14                     IN VARCHAR2,
                       c_Attribute15                     IN VARCHAR2,
                       c_Attribute16                     IN VARCHAR2,
                       c_Attribute17                     IN VARCHAR2,
                       c_Attribute18                     IN VARCHAR2,
                       c_Attribute19                     IN VARCHAR2,
                       c_Attribute20                     IN VARCHAR2,
                       c_global_attribute_category         IN VARCHAR2,
                       c_global_attribute1                 IN VARCHAR2,
                       c_global_attribute2                 IN VARCHAR2,
                       c_global_attribute3                 IN VARCHAR2,
                       c_global_attribute4                 IN VARCHAR2,
                       c_global_attribute5                 IN VARCHAR2,
                       c_global_attribute6                 IN VARCHAR2,
                       c_global_attribute7                 IN VARCHAR2,
                       c_global_attribute8                 IN VARCHAR2,
                       c_global_attribute9                 IN VARCHAR2,
                       c_global_attribute10                IN VARCHAR2,
                       c_global_attribute11                IN VARCHAR2,
                       c_global_attribute12                IN VARCHAR2,
                       c_global_attribute13                IN VARCHAR2,
                       c_global_attribute14                IN VARCHAR2,
                       c_global_attribute15                IN VARCHAR2,
                       c_global_attribute16                IN VARCHAR2,
                       c_global_attribute17                IN VARCHAR2,
                       c_global_attribute18                IN VARCHAR2,
                       c_global_attribute19                IN VARCHAR2,
                       c_global_attribute20                IN VARCHAR2,
                       c_orig_system_reference                   IN VARCHAR2,
                       c_status                                  IN VARCHAR2,
                       c_customer_type                           IN VARCHAR2,
                       c_customer_class_code                     IN VARCHAR2,
                       c_primary_salesrep_id                    IN NUMBER ,
                       c_sales_channel_code                      IN VARCHAR2,
                       c_order_type_id                          IN NUMBER,
                       c_price_list_id                          IN NUMBER ,
                       c_category_code                           IN VARCHAR2,
                       c_reference_use_flag                      IN VARCHAR2,
                       c_tax_code                                IN VARCHAR2,
                       c_third_party_flag                        IN VARCHAR2,
                       c_competitor_flag                         IN VARCHAR2,
                       c_fob_point                               IN VARCHAR2,
                       c_tax_header_level_flag                   IN VARCHAR2,
                       c_tax_rounding_rule                       IN VARCHAR2,
                       c_account_name                            IN VARCHAR2,
                       c_freight_term                            IN VARCHAR2,
                       c_ship_partial                            IN VARCHAR2,
                       c_ship_via                                IN VARCHAR2,
                       c_warehouse_id                           IN NUMBER,
                       c_payment_term_id                        IN NUMBER ,
                       c_DATES_NEGATIVE_TOLERANCE               IN NUMBER,
                       c_DATES_POSITIVE_TOLERANCE               IN NUMBER,
                       c_DATE_TYPE_PREFERENCE                   IN VARCHAR2,
                       c_OVER_SHIPMENT_TOLERANCE                IN NUMBER,
                       c_UNDER_SHIPMENT_TOLERANCE               IN NUMBER,
                       c_ITEM_CROSS_REF_PREF                    IN VARCHAR2,
                       c_OVER_RETURN_TOLERANCE                  IN NUMBER,
                       c_UNDER_RETURN_TOLERANCE                 IN NUMBER,
                       c_SHIP_SETS_INCLUDE_LINES_FLAG           IN VARCHAR2,
                       c_ARRIVALSETS_INCL_LINES_FLAG            IN VARCHAR2,
                       c_SCHED_DATE_PUSH_FLAG                   IN VARCHAR2,
                       c_INVOICE_QUANTITY_RULE                  IN VARCHAR2,
                       t_party_id                        IN NUMBER ,
                       t_party_number                     IN OUT NOCOPY VARCHAR2,
                       t_customer_key                     IN VARCHAR2,
                       t_Attribute_Category              IN VARCHAR2,
                       t_Attribute1                      IN VARCHAR2,
                       t_Attribute2                      IN VARCHAR2,
                       t_Attribute3                      IN VARCHAR2,
                       t_Attribute4                      IN VARCHAR2,
                       t_Attribute5                      IN VARCHAR2,
                       t_Attribute6                      IN VARCHAR2,
                       t_Attribute7                      IN VARCHAR2,
                       t_Attribute8                      IN VARCHAR2,
                       t_Attribute9                      IN VARCHAR2,
                       t_Attribute10                     IN VARCHAR2,
                       t_Attribute11                     IN VARCHAR2,
                       t_Attribute12                     IN VARCHAR2,
                       t_Attribute13                     IN VARCHAR2,
                       t_Attribute14                     IN VARCHAR2,
                       t_Attribute15                     IN VARCHAR2,
                       t_Attribute16                     IN VARCHAR2,
                       t_Attribute17                     IN VARCHAR2,
                       t_Attribute18                     IN VARCHAR2,
                       t_Attribute19                     IN VARCHAR2,
                       t_Attribute20                     IN VARCHAR2,
                       t_global_attribute_category         IN VARCHAR2,
                       t_global_attribute1                 IN VARCHAR2,
                       t_global_attribute2                 IN VARCHAR2,
                       t_global_attribute3                 IN VARCHAR2,
                       t_global_attribute4                 IN VARCHAR2,
                       t_global_attribute5                 IN VARCHAR2,
                       t_global_attribute6                 IN VARCHAR2,
                       t_global_attribute7                 IN VARCHAR2,
                       t_global_attribute8                 IN VARCHAR2,
                       t_global_attribute9                 IN VARCHAR2,
                       t_global_attribute10                IN VARCHAR2,
                       t_global_attribute11                IN VARCHAR2,
                       t_global_attribute12                IN VARCHAR2,
                       t_global_attribute13                IN VARCHAR2,
                       t_global_attribute14                IN VARCHAR2,
                       t_global_attribute15                IN VARCHAR2,
                       t_global_attribute16                IN VARCHAR2,
                       t_global_attribute17                IN VARCHAR2,
                       t_global_attribute18                IN VARCHAR2,
                       t_global_attribute19                IN VARCHAR2,
                       t_global_attribute20                IN VARCHAR2,
                       o_pre_name_adjunct                  IN VARCHAR2,
                       o_first_name                        IN VARCHAR2,
                       o_middle_name                       IN VARCHAR2,
                       o_last_name                         IN VARCHAR2,
                       o_name_suffix                       IN VARCHAR2,
                       o_tax_reference                     IN VARCHAR2,
                       o_taxpayer_id                       IN VARCHAR2,
                       o_party_name_phonetic               IN VARCHAR2,
                       p_cust_account_profile_id           IN NUMBER ,
                       p_cust_account_id                   IN NUMBER ,
                       p_status                            IN VARCHAR2,
                       p_collector_id                      IN NUMBER ,
                       p_credit_analyst_id                        IN NUMBER ,
                       p_credit_checking                           IN VARCHAR2,
                       p_next_credit_review_date                  DATE ,
                       p_tolerance                                IN NUMBER,
                       p_discount_terms                            IN VARCHAR2,
                       p_dunning_letters                           IN VARCHAR2,
                       p_interest_charges                          IN VARCHAR2,
                       p_send_statements                           IN VARCHAR2,
                       p_credit_balance_statements                 IN VARCHAR2,
                       p_credit_hold                               IN VARCHAR2,
                       p_profile_class_id                         IN NUMBER ,
                       p_site_use_id                              IN NUMBER ,
                       p_credit_rating                             IN VARCHAR2,
                       p_risk_code                                 IN VARCHAR2,
                       p_standard_terms                           IN NUMBER ,
                       p_override_terms                            IN VARCHAR2,
                       p_dunning_letter_set_id                    IN NUMBER,
                       p_interest_period_days                     IN NUMBER,
                       p_payment_grace_days                       IN NUMBER,
                       p_discount_grace_days                      IN NUMBER,
                       p_statement_cycle_id                       IN NUMBER ,
                       p_account_status                            IN VARCHAR2,
                       p_percent_collectable                      IN NUMBER ,
                       p_autocash_hierarchy_id                    IN NUMBER,
                       p_Attribute_Category              IN VARCHAR2,
                       p_Attribute1                      IN VARCHAR2,
                       p_Attribute2                      IN VARCHAR2,
                       p_Attribute3                      IN VARCHAR2,
                       p_Attribute4                      IN VARCHAR2,
                       p_Attribute5                      IN VARCHAR2,
                       p_Attribute6                      IN VARCHAR2,
                       p_Attribute7                      IN VARCHAR2,
                       p_Attribute8                      IN VARCHAR2,
                       p_Attribute9                      IN VARCHAR2,
                       p_Attribute10                     IN VARCHAR2,
                       p_Attribute11                     IN VARCHAR2,
                       p_Attribute12                     IN VARCHAR2,
                       p_Attribute13                     IN VARCHAR2,
                       p_Attribute14                     IN VARCHAR2,
                       p_Attribute15                     IN VARCHAR2,
                       p_auto_rec_incl_disputed_flag               IN VARCHAR2,
                       p_tax_printing_option                       IN VARCHAR2,
                       p_charge_on_fin_charge_flag             IN VARCHAR2,
                       p_grouping_rule_id                         IN NUMBER ,
                       p_clearing_days                            IN NUMBER,
                       p_jgzz_attribute_category                   IN VARCHAR2,
                       p_jgzz_attribute1                           IN VARCHAR2,
                       p_jgzz_attribute2                           IN VARCHAR2,
                       p_jgzz_attribute3                           IN VARCHAR2,
                       p_jgzz_attribute4                           IN VARCHAR2,
                       p_jgzz_attribute5                           IN VARCHAR2,
                       p_jgzz_attribute6                           IN VARCHAR2,
                       p_jgzz_attribute7                           IN VARCHAR2,
                       p_jgzz_attribute8                           IN VARCHAR2,
                       p_jgzz_attribute9                           IN VARCHAR2,
                       p_jgzz_attribute10                          IN VARCHAR2,
                       p_jgzz_attribute11                          IN VARCHAR2,
                       p_jgzz_attribute12                          IN VARCHAR2,
                       p_jgzz_attribute13                          IN VARCHAR2,
                       p_jgzz_attribute14                          IN VARCHAR2,
                       p_jgzz_attribute15                          IN VARCHAR2,
                       p_global_attribute_category         IN VARCHAR2,
                       p_global_attribute1                 IN VARCHAR2,
                       p_global_attribute2                 IN VARCHAR2,
                       p_global_attribute3                 IN VARCHAR2,
                       p_global_attribute4                 IN VARCHAR2,
                       p_global_attribute5                 IN VARCHAR2,
                       p_global_attribute6                 IN VARCHAR2,
                       p_global_attribute7                 IN VARCHAR2,
                       p_global_attribute8                 IN VARCHAR2,
                       p_global_attribute9                 IN VARCHAR2,
                       p_global_attribute10                IN VARCHAR2,
                       p_global_attribute11                IN VARCHAR2,
                       p_global_attribute12                IN VARCHAR2,
                       p_global_attribute13                IN VARCHAR2,
                       p_global_attribute14                IN VARCHAR2,
                       p_global_attribute15                IN VARCHAR2,
                       p_global_attribute16                IN VARCHAR2,
                       p_global_attribute17                IN VARCHAR2,
                       p_global_attribute18                IN VARCHAR2,
                       p_global_attribute19                IN VARCHAR2,
                       p_global_attribute20                IN VARCHAR2,
                       p_cons_inv_flag                     IN VARCHAR2,
                       p_cons_inv_type                     IN VARCHAR2,
                       p_autocash_hier_id_for_adr          IN NUMBER ,
                       p_lockbox_matching_option           IN VARCHAR2,
                       o_person_profile_id                 in OUT NOCOPY number,
                       x_msg_count                         OUT NOCOPY NUMBER,
                       x_msg_data                          OUT NOCOPY varchar2,
                       x_return_status                     OUT NOCOPY VARCHAR2) is


acct_rec        hz_cust_account_v2pub.cust_account_rec_type;
party_rec       hz_party_v2pub.party_rec_type;
person_rec      hz_party_v2pub.person_rec_type;
prel_rec        HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
prof_rec        hz_customer_profile_v2pub .customer_profile_rec_type;


tmp_var                VARCHAR2(2000);
i                      number;
tmp_var1                VARCHAR2(2000);
x_customer_id      number;
x_cust_account_number VARCHAR2(100);
 x_party_id         number;
x_party_number     VARCHAR2(100);
i_internal_party_id number;
i_pr_party_relationship_id NUMBER;
i_pr_party_id              NUMBER;
i_pr_party_number          VARCHAR2(100);
-- create_internal_party      VARCHAR2(1) := 'Y';
x_party_rel_id              NUMBER;
l_object_version_number     NUMBER;
l_party_object_version_number NUMBER;

   cursor C_REFERENCE_FOR is select relationship_id from
   hz_relationships where subject_id = c_party_id
   and relationship_code = 'REFERENCE_FOR'
   and subject_table_name = 'HZ_PARTIES'
   AND object_table_name = 'HZ_PARTIES'
   AND directional_flag = 'F';
x_party_last_update_date     date;
X_PARTY_REL_LAST_UPDATE_DATE date;

   cursor C_PARTNER_OF is select relationship_id from
   hz_relationships where subject_id = c_party_id
   and relationship_code = 'PARTNER_OF'
   and subject_table_name = 'HZ_PARTIES'
   and object_table_name = 'HZ_PARTIES'
   and directional_flag = 'F';

   cursor C_COMPETITOR_OF is select relationship_id from
   hz_relationships where subject_id = c_party_id
   and relationship_code = 'COMPETITOR_OF'
   and subject_table_name = 'HZ_PARTIES'
   and object_table_name = 'HZ_PARTIES'
   and directional_flag = 'F';

begin
/*
if C_Party_Id is not null then
    create_internal_party := 'N';
end if;
*/
 acct_rec.cust_account_id        := C_Cust_account_Id;
--  acct_rec.party_id               := C_Party_Id;
 acct_rec.account_number         := C_account_Number;
 acct_rec.attribute_category     := C_Attribute_Category;
 acct_rec.attribute1             := C_Attribute1;
 acct_rec.attribute2             := C_Attribute2;
 acct_rec.attribute3             := C_Attribute3;
 acct_rec.attribute4             := C_Attribute4;
 acct_rec.attribute5             := C_Attribute5;
 acct_rec.attribute6             := C_Attribute6;
 acct_rec.attribute7             := C_Attribute7;
 acct_rec.attribute8             := C_Attribute8;
 acct_rec.attribute9             := C_Attribute9;
 acct_rec.attribute10            := C_Attribute10;
 acct_rec.attribute11            := C_Attribute11;
 acct_rec.attribute12            := C_Attribute12;
 acct_rec.attribute13            := C_Attribute13;
 acct_rec.attribute14            := C_Attribute14;
 acct_rec.attribute15            := C_Attribute15;
 acct_rec.attribute16            := C_Attribute16;
 acct_rec.attribute17            := C_Attribute17;
 acct_rec.attribute18            := C_Attribute18;
 acct_rec.attribute19            := C_Attribute19;
 acct_rec.attribute20            := C_Attribute20;
 acct_rec.global_attribute_category := C_Global_Attribute_Category;
 acct_rec.global_attribute1      := C_Global_Attribute1;
 acct_rec.global_attribute2      := C_Global_Attribute2;
 acct_rec.global_attribute3      := C_Global_Attribute3;
 acct_rec.global_attribute4      := C_Global_Attribute4;
 acct_rec.global_attribute5      := C_Global_Attribute5;
 acct_rec.global_attribute6      := C_Global_Attribute6;
 acct_rec.global_attribute7      := C_Global_Attribute7;
 acct_rec.global_attribute8      := C_Global_Attribute8;
 acct_rec.global_attribute9      := C_Global_Attribute9;
 acct_rec.global_attribute10     := C_Global_Attribute10;
 acct_rec.global_attribute11     := C_Global_Attribute11;
 acct_rec.global_attribute12     := C_Global_Attribute12;
 acct_rec.global_attribute13     := C_Global_Attribute13;
 acct_rec.global_attribute14     := C_Global_Attribute14;
 acct_rec.global_attribute15     := C_Global_Attribute15;
 acct_rec.global_attribute16     := C_Global_Attribute16;
 acct_rec.global_attribute17     := C_Global_Attribute17;
 acct_rec.global_attribute18     := C_Global_Attribute18;
 acct_rec.global_attribute19     := C_Global_Attribute19;
 acct_rec.global_attribute20     := C_Global_Attribute20;
 acct_rec.orig_system_reference  := C_Orig_System_Reference;
 acct_rec.status                 := C_Status;
 acct_rec.customer_type          := c_customer_type;
 acct_rec.customer_class_code    := C_Customer_Class_Code;
 acct_rec.primary_salesrep_id    := C_Primary_Salesrep_Id;
 acct_rec.sales_channel_code     := C_Sales_Channel_Code;
 acct_rec.order_type_id          := C_Order_Type_Id;
 acct_rec.price_list_id          := C_Price_List_Id;
 -- acct_rec.category_code          := C_Category_Code;
 -- acct_rec.reference_use_flag     := C_Reference_Use_Flag;
 acct_rec.tax_code               := C_Tax_Code;
 -- acct_rec.third_party_flag       := C_Third_Party_Flag;
 -- acct_rec.competitor_flag        := c_competitor_flag;
 acct_rec.fob_point              := C_Fob_Point;
 acct_rec.freight_term            := C_Freight_Term;
 acct_rec.ship_partial            := C_Ship_Partial;
 acct_rec.ship_via                := C_Ship_Via;
 acct_rec.warehouse_id            := C_Warehouse_Id;
 acct_rec.tax_header_level_flag  := C_Tax_Header_Level_Flag;
 acct_rec.tax_rounding_rule      := C_Tax_Rounding_Rule;
 acct_rec.coterminate_day_month  := NULL; --new
 acct_rec.primary_specialist_id  := NULL;
 acct_rec.secondary_specialist_id := NULL;
 --acct_rec.geo_code                := NULL;
 --acct_rec.payment_term_id         := NULL;
 acct_rec.account_liable_flag     := null;
/* acct_rec.current_balance         := null ; --new
 acct_rec.account_established_date := null ; --new
 acct_rec.account_termination_date := null ; --new
 acct_rec.account_activation_date  := null ; --new
 acct_rec.department               := null; --new
 acct_rec.held_bill_expiration_date := null ; --new
 acct_rec.hold_bill_flag            := null ; --new
 acct_rec.realtime_rate_flag        := null ; --new
 acct_rec.acct_life_cycle_status    := null ; --new */
 acct_rec.account_name            := c_account_name;

 acct_rec.DATES_NEGATIVE_TOLERANCE   := c_DATES_NEGATIVE_TOLERANCE;
 acct_rec.DATES_POSITIVE_TOLERANCE   := c_DATES_POSITIVE_TOLERANCE;
 acct_rec.DATE_TYPE_PREFERENCE       := c_DATE_TYPE_PREFERENCE;
 acct_rec.OVER_SHIPMENT_TOLERANCE    := c_OVER_SHIPMENT_TOLERANCE;
 acct_rec.UNDER_SHIPMENT_TOLERANCE   := c_UNDER_SHIPMENT_TOLERANCE;
 acct_rec.OVER_RETURN_TOLERANCE       := c_OVER_RETURN_TOLERANCE;
 acct_rec.UNDER_RETURN_TOLERANCE      := c_UNDER_RETURN_TOLERANCE;
 acct_rec.ITEM_CROSS_REF_PREF        := c_ITEM_CROSS_REF_PREF;
 acct_rec.SHIP_SETS_INCLUDE_LINES_FLAG := c_SHIP_SETS_INCLUDE_LINES_FLAG;
 acct_rec.ARRIVALSETS_INCLUDE_LINES_FLAG := c_ARRIVALSETS_INCL_LINES_FLAG;
 acct_rec.SCHED_DATE_PUSH_FLAG        := c_SCHED_DATE_PUSH_FLAG;
 acct_rec.INVOICE_QUANTITY_RULE       := c_INVOICE_QUANTITY_RULE;
 /*acct_rec.status_update_date          := null ; --new
 acct_rec.autopay_flag                := null; --new
 acct_rec.notify_flag                 := null; --new
 acct_rec.last_batch_id               := null; --new
 acct_rec.selling_party_id            := null; --new*/
 acct_rec.created_by_module           := 'CSPSHIPAD'; --new
 acct_rec.application_id              := 523 ; --new


 person_rec.party_rec.party_id     := c_party_id;
 person_rec.person_pre_name_adjunct := o_pre_name_adjunct;
 person_rec.person_first_name       := o_first_name;
 person_rec.person_middle_name      := o_middle_name;
 person_rec.person_last_name        := o_last_name;
 person_rec.person_name_suffix      := o_name_suffix;
 person_rec.jgzz_fiscal_code := o_taxpayer_id;
 person_rec.person_name_phonetic     := o_party_name_phonetic;
-- person_rec.tax_reference    := o_tax_reference;
 person_rec.party_rec.party_id               := t_party_id;
 person_rec.party_rec.party_number           := t_party_number;
 person_rec.party_rec.validated_flag         := NULL;
 person_rec.party_rec.orig_system_reference  := c_orig_system_reference;
 --person_rec.party_rec.customer_key           := t_customer_key;
 person_rec.party_rec.attribute_category     := t_Attribute_Category;
 person_rec.party_rec.attribute1             := t_Attribute1;
 person_rec.party_rec.attribute2             := t_Attribute2;
 person_rec.party_rec.attribute3             := t_Attribute3;
 person_rec.party_rec.attribute4             := t_Attribute4;
 person_rec.party_rec.attribute5             := t_Attribute5;
 person_rec.party_rec.attribute6             := t_Attribute6;
 person_rec.party_rec.attribute7             := t_Attribute7;
 person_rec.party_rec.attribute8             := t_attribute8;
 person_rec.party_rec.attribute9             := t_Attribute9;
 person_rec.party_rec.attribute10            := t_Attribute10;
 person_rec.party_rec.attribute11            := t_Attribute11;
 person_rec.party_rec.attribute12            := t_Attribute12;
 person_rec.party_rec.attribute13            := t_Attribute13;
 person_rec.party_rec.attribute14            := t_Attribute14;
 person_rec.party_rec.attribute15            := t_Attribute15;
 person_rec.party_rec.attribute16            := t_Attribute16;
 person_rec.party_rec.attribute17            := t_Attribute17;
 person_rec.party_rec.attribute18            := t_Attribute18;
 person_rec.party_rec.attribute19            := t_Attribute19;
 person_rec.party_rec.attribute20            := t_Attribute20;
 /*person_rec.party_rec.global_attribute_category  := t_Global_Attribute_Category;
 person_rec.party_rec.global_attribute1      := t_Global_Attribute1;
 person_rec.party_rec.global_attribute2      := t_Global_Attribute2;
 person_rec.party_rec.global_attribute3      := t_Global_Attribute3;
 person_rec.party_rec.global_attribute4      := t_Global_Attribute4;
 person_rec.party_rec.global_attribute5      := t_Global_Attribute5;
 person_rec.party_rec.global_attribute6      := t_Global_Attribute6;
 person_rec.party_rec.global_attribute7      := t_Global_Attribute7;
 person_rec.party_rec.global_attribute8      := t_Global_Attribute8;
 person_rec.party_rec.global_attribute9      := t_Global_Attribute9;
 person_rec.party_rec.global_attribute10     := t_Global_Attribute10;
 person_rec.party_rec.global_attribute11     := t_Global_Attribute11;
 person_rec.party_rec.global_attribute12     := t_Global_Attribute12;
 person_rec.party_rec.global_attribute13     := t_Global_Attribute13;
 person_rec.party_rec.global_attribute14     := t_Global_Attribute14;
 person_rec.party_rec.global_attribute15     := t_Global_Attribute15;
 person_rec.party_rec.global_attribute16     := t_Global_Attribute16;
 person_rec.party_rec.global_attribute17     := t_Global_Attribute17;
 person_rec.party_rec.global_attribute18     := t_Global_Attribute18;
 person_rec.party_rec.global_attribute19     := t_Global_Attribute19;
 person_rec.party_rec.global_attribute20     := t_Global_Attribute20;*/
 person_rec.party_rec.status                 := null;
 person_rec.party_rec.category_code          := C_Category_Code;
 -- person_rec.party_rec.reference_use_flag     := C_Reference_Use_Flag;
 -- person_rec.party_rec.third_party_flag       := C_Third_Party_Flag;
 -- person_rec.party_rec.competitor_flag        := c_competitor_flag;
/*
 person_rec.party_rec.party_id     := c_party_id;
 person_rec.pre_name_adjunct := o_pre_name_adjunct;
 person_rec.first_name       := o_first_name;
 person_rec.middle_name      := o_middle_name;
 person_rec.last_name        := o_last_name;
 person_rec.name_suffix      := o_name_suffix;
 person_rec.jgzz_fiscal_code := o_taxpayer_id;
 person_rec.person_name_phonetic     := o_party_name_phonetic;
*/
 prof_rec.cust_account_profile_id       := p_cust_account_profile_id;
 prof_rec.cust_account_id               := p_cust_account_id;
 prof_rec.status                        := p_status;
 prof_rec.collector_id                  := p_collector_id;
 prof_rec.credit_analyst_id             := null;
 prof_rec.credit_checking               := p_credit_checking;
 prof_rec.next_credit_review_date       := null;
 prof_rec.tolerance                     := p_tolerance;
 prof_rec.discount_terms                := p_discount_terms;
 prof_rec.dunning_letters               := p_dunning_letters;
 prof_rec.interest_charges              := p_interest_charges;
 prof_rec.send_statements               := p_send_statements;
 prof_rec.credit_balance_statements     := p_credit_balance_statements;
 prof_rec.credit_hold                   := p_credit_hold;
 prof_rec.profile_class_id              := p_profile_class_id;
 prof_rec.site_use_id                   := NULL;
 prof_rec.credit_rating                 := p_credit_rating;
 prof_rec.risk_code                     := p_risk_code;
 prof_rec.standard_terms                := p_standard_terms;
 prof_rec.override_terms                := p_override_terms;
 prof_rec.dunning_letter_set_id         := p_dunning_letter_set_id;
 prof_rec.interest_period_days          := p_interest_period_days;
 prof_rec.payment_grace_days            := p_payment_grace_days;
 prof_rec.discount_grace_days           := p_discount_grace_days;
 prof_rec.statement_cycle_id            := p_statement_cycle_id;
 prof_rec.account_status                := p_account_status;
 prof_rec.percent_collectable           := p_percent_collectable;
 prof_rec.autocash_hierarchy_id         := p_autocash_hierarchy_id;
 prof_rec.attribute_category            := p_attribute_category;
 prof_rec.attribute1                    := p_attribute1;
 prof_rec.attribute2                    := p_attribute2;
 prof_rec.attribute3                    := p_attribute3;
 prof_rec.attribute4                    := p_attribute4;
 prof_rec.attribute5                    := p_attribute5;
 prof_rec.attribute6                    := p_attribute6;
 prof_rec.attribute7                    := p_attribute7;
 prof_rec.attribute8                    := p_attribute8;
 prof_rec.attribute9                    := p_attribute9;
 prof_rec.attribute10                   := p_attribute10;
 prof_rec.attribute11                   := p_attribute11;
 prof_rec.attribute12                   := p_attribute12;
 prof_rec.attribute13                   := p_attribute13;
 prof_rec.attribute14                   := p_attribute14;
 prof_rec.attribute15                   := p_attribute15;
 prof_rec.auto_rec_incl_disputed_flag   := p_auto_rec_incl_disputed_flag;
 prof_rec.tax_printing_option           := p_tax_printing_option;
 prof_rec.charge_on_finance_charge_flag := p_charge_on_fin_charge_flag;
 prof_rec.grouping_rule_id              := p_grouping_rule_id;
 prof_rec.clearing_days                 := p_clearing_days;
 prof_rec.jgzz_attribute_category       := p_jgzz_attribute_category;
 prof_rec.jgzz_attribute1               := p_jgzz_attribute1;
 prof_rec.jgzz_attribute2               := p_jgzz_attribute2;
 prof_rec.jgzz_attribute3               := p_jgzz_attribute3;
 prof_rec.jgzz_attribute4               := p_jgzz_attribute4;
 prof_rec.jgzz_attribute5               := p_jgzz_attribute5;
 prof_rec.jgzz_attribute6               := p_jgzz_attribute6;
 prof_rec.jgzz_attribute7               := p_jgzz_attribute7;
 prof_rec.jgzz_attribute8               := p_jgzz_attribute8;
 prof_rec.jgzz_attribute9               := p_jgzz_attribute9;
 prof_rec.jgzz_attribute10              := p_jgzz_attribute10;
 prof_rec.jgzz_attribute11              := p_jgzz_attribute11;
 prof_rec.jgzz_attribute12              := p_jgzz_attribute12;
 prof_rec.jgzz_attribute13              := p_jgzz_attribute13;
 prof_rec.jgzz_attribute14              := p_jgzz_attribute14;
 prof_rec.jgzz_attribute15              := p_jgzz_attribute15;
 prof_rec.global_attribute1             := p_global_attribute1;
 prof_rec.global_attribute2             := p_global_attribute2;
 prof_rec.global_attribute3             := p_global_attribute3;
 prof_rec.global_attribute4             := p_global_attribute4;
 prof_rec.global_attribute5             := p_global_attribute5;
 prof_rec.global_attribute6             := p_global_attribute6;
 prof_rec.global_attribute7             := p_global_attribute7;
 prof_rec.global_attribute8             := p_global_attribute8;
 prof_rec.global_attribute9             := p_global_attribute9;
 prof_rec.global_attribute10            := p_global_attribute10;
 prof_rec.global_attribute11            := p_global_attribute11;
 prof_rec.global_attribute12            := p_global_attribute12;
 prof_rec.global_attribute13            := p_global_attribute13;
 prof_rec.global_attribute14            := p_global_attribute14;
 prof_rec.global_attribute15            := p_global_attribute15;
 prof_rec.global_attribute16            := p_global_attribute16;
 prof_rec.global_attribute17            := p_global_attribute17;
 prof_rec.global_attribute18            := p_global_attribute18;
 prof_rec.global_attribute19            := p_global_attribute19;
 prof_rec.global_attribute20            := p_global_attribute20;
 prof_rec.global_attribute_category     := p_global_attribute_category;
 prof_rec.cons_inv_flag                 := p_cons_inv_flag;
 prof_rec.cons_inv_type                 := p_cons_inv_type;
 prof_rec.autocash_hierarchy_id_for_adr := p_autocash_hier_id_for_adr;
 prof_rec.lockbox_matching_option       := p_lockbox_matching_option ;


hz_cust_account_v2pub.create_cust_account(
FND_API.g_false,
acct_rec,
person_rec,
prof_rec,
FND_API.G_FALSE,
x_customer_id,
x_cust_account_number,
x_party_id,
x_party_number,
o_person_profile_id,
x_return_status,
x_msg_count,
x_msg_data
);
c_cust_account_id := x_customer_id;
c_party_id := x_party_id;
t_party_number := x_party_number;
c_account_number  := x_cust_account_number;

-- insert into tk7 values (x_return_status, x_msg_count, 'create per >>>'||x_msg_data);
 if x_msg_count > 1 then
   FOR i IN 1..x_msg_count  LOOP
  tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
--  insert into tk7 values (x_return_status, x_msg_count, tmp_var);
  tmp_var1 := tmp_var1 || ' '|| tmp_var;
  END LOOP;
  x_msg_data := tmp_var1;
--  insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
END IF;


if x_return_status <> 'S' then
   return;
end if;

i_internal_party_id := fnd_profile.value('HZ_INTERNAL_PARTY');
if i_internal_party_id is not null then
-- insert into testqq values (prel_rec.subject_id,prel_rec.object_id);
-- commit;
    if C_Reference_Use_Flag is not null then
      open  C_REFERENCE_FOR;
      fetch C_REFERENCE_FOR into x_party_rel_id;
      close C_REFERENCE_FOR;
      if x_party_rel_id is null then
        if C_Reference_Use_Flag = 'Y' then
           prel_rec.subject_id        := x_party_id;
           prel_rec.object_id         := i_internal_party_id;
           prel_rec.start_date         := sysdate;
           prel_rec.end_date := null;
           prel_rec.relationship_type := 'REFERENCE_FOR';
           prel_rec.start_date := sysdate;
           prel_rec.created_by_module := 'CSPSHIPAD';
           /*HZ_PARTY_PUB.create_party_relationship (
           1,
           null,
           null,
           prel_rec,
           'N',
           x_return_status,
           x_msg_count,
           x_msg_data,
           i_pr_party_relationship_id,
           i_pr_party_id,
           i_pr_party_number);*/
           HZ_RELATIONSHIP_V2PUB.create_relationship (
                p_init_msg_list              => FND_API.G_FALSE,
                p_relationship_rec           =>  prel_rec,
                x_relationship_id            => i_pr_party_relationship_id,
                x_party_id                   => i_pr_party_id,
                x_party_number               => i_pr_party_number,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data);
           if x_msg_count > 1 then
              FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
              -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
           END IF;
        end if;
       end if;
if x_return_status <> 'S' then
   return;
end if;
      if x_party_rel_id is not null then
          /* Update of party relationship table */
          prel_rec.party_rec.party_id := c_party_id;

        /* select last_update_date into x_party_rel_last_update_date
          from hz_party_relationships where party_relationship_id = x_party_rel_id;

          select last_update_date into x_party_last_update_date
          from hz_parties where party_id = c_party_id;*/

          select object_version_number into l_object_version_number
          from hz_relationships where relationship_id = x_party_rel_id;

          select object_version_number  into l_party_object_version_number
          from hz_parties where party_id = c_party_id;

          prel_rec.relationship_id := x_party_rel_id;
          if C_Reference_Use_Flag = 'N' then
             prel_rec.end_date := sysdate;
           else
             prel_rec.end_date := null;
          end if;

            HZ_RELATIONSHIP_V2PUB.update_relationship (
    p_init_msg_list                 =>  FND_API.G_FALSE,
    p_relationship_rec              =>  prel_rec ,
    p_object_version_number         => l_object_version_number,
    p_party_object_version_number   => l_party_object_version_number,
    x_return_status                 => x_return_status,
    x_msg_count                     =>x_msg_count  ,
    x_msg_data                      => x_msg_data);

          -- insert into tk7 values (x_return_status, x_msg_count, 'up ofg prf pty >>>'||x_msg_data);
          if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
            -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
         END IF;
      end if;
     end if ; -- C_Reference_Use_Flag is not null


if x_return_status <> 'S' then
   return;
end if;

    if C_Third_Party_Flag is not null then
      open  C_PARTNER_OF;
      fetch C_PARTNER_OF into x_party_rel_id;
      close C_PARTNER_OF;
      if x_party_rel_id is null then
        if C_Third_Party_Flag = 'Y' then
           prel_rec.subject_id        := x_party_id;
           prel_rec.object_id         := i_internal_party_id;
           prel_rec.start_date         := sysdate;
           prel_rec.end_date := null;
           prel_rec.relationship_type := 'PARTNER_OF';
           prel_rec.created_by_module := 'CSPSHIPAD';
       HZ_RELATIONSHIP_V2PUB.create_relationship (
                p_init_msg_list              => FND_API.G_FALSE,
                p_relationship_rec           =>  prel_rec,
                x_relationship_id            => i_pr_party_relationship_id,
                x_party_id                   => i_pr_party_id,
                x_party_number               => i_pr_party_number,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data);
           if x_msg_count > 1 then
              FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
              -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
           END IF;
        end if;
       end if;
if x_return_status <> 'S' then
   return;
end if;
      if x_party_rel_id is not null then
          /* Update of party relationship table */
          prel_rec.party_rec.party_id := c_party_id;

         /* select last_update_date into x_party_rel_last_update_date
          from hz_party_relationships where party_relationship_id = x_party_rel_id;

          select last_update_date into x_party_last_update_date
          from hz_parties where party_id = c_party_id;*/

          select object_version_number into l_object_version_number
          from hz_relationships where relationship_id = x_party_rel_id;

          select object_version_number  into l_party_object_version_number
          from hz_parties where party_id = c_party_id;

          prel_rec.relationship_id := x_party_rel_id;
          if C_Third_Party_Flag = 'N' then
             prel_rec.end_date := sysdate;
           else
             prel_rec.end_date := null;
          end if;
           HZ_RELATIONSHIP_V2PUB.update_relationship (
    p_init_msg_list                 =>  FND_API.G_FALSE,
    p_relationship_rec              =>  prel_rec ,
    p_object_version_number         => l_object_version_number,
    p_party_object_version_number   => l_party_object_version_number,
    x_return_status                 => x_return_status,
    x_msg_count                     =>x_msg_count  ,
    x_msg_data                      => x_msg_data);

          -- insert into tk7 values (x_return_status, x_msg_count, 'up ofg prf pty >>>'||x_msg_data);
          if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
            -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
         END IF;
      end if;
     end if ; -- C_Third_Party_Flag is not null



if x_return_status <> 'S' then
   return;
end if;


    if c_competitor_flag is not null then
      open  C_COMPETITOR_OF;
      fetch C_COMPETITOR_OF into x_party_rel_id;
      close C_COMPETITOR_OF;
      if x_party_rel_id is null then
        if c_competitor_flag = 'Y' then
           prel_rec.subject_id        := x_party_id;
           prel_rec.object_id         := i_internal_party_id;
           prel_rec.start_date         := sysdate;
           prel_rec.end_date := null;
           prel_rec.relationship_type := 'COMPETITOR_OF';
           prel_rec.start_date := sysdate;
           prel_rec.created_by_module := 'CSPSHIPAD';
          HZ_RELATIONSHIP_V2PUB.create_relationship (
                p_init_msg_list              => FND_API.G_FALSE,
                p_relationship_rec           =>  prel_rec,
                x_relationship_id            => i_pr_party_relationship_id,
                x_party_id                   => i_pr_party_id,
                x_party_number               => i_pr_party_number,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data);
           if x_msg_count > 1 then
              FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
              -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
           END IF;
        end if;
       end if;
if x_return_status <> 'S' then
   return;
end if;
      if x_party_rel_id is not null then
          /* Update of party relationship table */
          prel_rec.party_rec.party_id := c_party_id;

          /*select last_update_date,object_version_number into x_party_rel_last_update_date,l_object_version_number
          from hz_party_relationships where party_relationship_id = x_party_rel_id;

          select last_update_date into x_party_last_update_date
          from hz_parties where party_id = c_party_id;*/

          select object_version_number into l_object_version_number
          from hz_relationships where relationship_id = x_party_rel_id;

          select object_version_number  into l_party_object_version_number
          from hz_parties where party_id = c_party_id;

          prel_rec.relationship_id := x_party_rel_id;
          if c_competitor_flag = 'N' then
             prel_rec.end_date := sysdate;
           else
             prel_rec.end_date := null;
          end if;
          /*HZ_PARTY_PUB.update_party_relationship (
          1,
          null,
          null,
          prel_rec,
          x_party_rel_last_update_date,
          x_party_last_update_date,
          x_return_status,
          x_msg_count,
          x_msg_data);*/
          HZ_RELATIONSHIP_V2PUB.update_relationship (
    p_init_msg_list                 =>  FND_API.G_FALSE,
    p_relationship_rec              =>  prel_rec ,
    p_object_version_number         => l_object_version_number,
    p_party_object_version_number   => l_party_object_version_number,
    x_return_status                 => x_return_status,
    x_msg_count                     =>x_msg_count  ,
    x_msg_data                      => x_msg_data);

          -- insert into tk7 values (x_return_status, x_msg_count, 'up ofg prf pty >>>'||x_msg_data);
          if x_msg_count > 1 then
            FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             -- insert into tk7 values (x_return_status, x_msg_count, tmp_var);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
            -- insert into tk7 values (x_return_status, x_msg_count, tmp_var1);
         END IF;
      end if;
     end if ; -- c_competitor_flag is not null

end if;
-- end if; -- for internal party

end insert_person_row;
END CSP_CUSTOMER_ACCOUNT_PVT;

/
