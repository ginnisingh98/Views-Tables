--------------------------------------------------------
--  DDL for Package Body HZP_CPROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZP_CPROF_PKG" as
/* $Header: ARHCPRFB.pls 120.15 2005/06/16 21:09:29 jhuang ship $ */
--
--
FUNCTION INIT_SWITCH
( p_date   IN DATE,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN DATE
IS
 res_date date;
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_date IS NULL THEN
     res_date := FND_API.G_MISS_DATE;
   ELSE
     res_date := p_date;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_date = FND_API.G_MISS_DATE THEN
     res_date := NULL;
   ELSE
     res_date := p_date;
   END IF;
 ELSE
   res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
 END IF;
 RETURN res_date;
END;

FUNCTION INIT_SWITCH
( p_char   IN VARCHAR2,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN VARCHAR2
IS
 res_char varchar2(2000);
BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_char IS NULL THEN
     return FND_API.G_MISS_CHAR;
   ELSE
     return p_char;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_char = FND_API.G_MISS_CHAR THEN
     return NULL;
   ELSE
     return p_char;
   END IF;
 ELSE
   return ('INCORRECT_P_SWITCH');
 END IF;
END;

FUNCTION INIT_SWITCH
( p_num   IN NUMBER,
  p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
RETURN NUMBER
IS
 BEGIN
 IF    p_switch = 'NULL_GMISS' THEN
   IF p_num IS NULL THEN
     return FND_API.G_MISS_NUM;
   ELSE
     return p_num;
   END IF;
 ELSIF p_switch = 'GMISS_NULL' THEN
   IF p_num = FND_API.G_MISS_NUM THEN
     return NULL;
   ELSE
     return p_num;
   END IF;
 ELSE
   return ('9999999999');
 END IF;
END;

 PROCEDURE check_unique ( p_customer_id in number,
			  p_site_use_id in number
			)
 IS
 --
   l_profile_count number;
 --
 BEGIN
   --
   IF ( p_site_use_id is null ) THEN
	--
	select count(1)
	into   l_profile_count
 	from   hz_customer_profiles cp
 	where  cp.cust_account_id = p_customer_id
 	and    cp.site_use_id is null;
 	--
   ELSE
/* bug3578108 : Added condition to pickup only bill to,
   statement and dunning profile */
	select count(1)
	into   l_profile_count
 	from   hz_customer_profiles cp,
               hz_cust_site_uses su
 	where  cp.cust_account_id = p_customer_id
 	and    cp.site_use_id = p_site_use_id
        and    su.site_use_id = cp.site_use_id
        and    su.site_use_code in ('BILL_TO','DUN','STMTS') ;
	--
   END IF;
   IF ( l_profile_count >= 1 ) THEN
	fnd_message.set_name('AR','AR_CUST_ONE_PROFILE_ALLOWED');
	app_exception.raise_exception;
   END IF;
   --
   --
 END check_unique;
 --
 --

 PROCEDURE update_customer_alt_names(p_rowid in varchar2,
                                    p_standard_terms in number,
                                    p_customer_id in number,
                                    p_site_use_id in number
                                    )
 IS
    l_standard_terms number := null ;

    CURSOR c1 is
        select standard_terms
        from hz_customer_profiles
        where rowid = p_rowid;
 BEGIN
        --
        --
--        if ( nvl ( fnd_profile.value('AR_ALT_NAME_SEARCH') , 'N' ) = 'Y' ) then
        --
        OPEN c1;
          FETCH  c1 INTO l_standard_terms;
          IF c1%FOUND THEN
              --
              IF (
                        ( l_standard_terms IS NULL AND p_standard_terms IS NOT NULL )
                     OR ( l_standard_terms IS NOT NULL and p_standard_terms IS NULL )
                     OR ( l_standard_terms <> p_standard_terms )
                     )
              THEN
                 --
                    arp_cust_alt_match_pkg.update_pay_term_id ( p_customer_id,
                                p_site_use_id , p_standard_terms );
                    --
              END IF;
              --
          END IF;
        CLOSE c1;
        --
--        end if;
        --
        --
 EXCEPTION
        WHEN OTHERS THEN
              arp_standard.debug('EXCEPTION: hzp_cprof_pkg.update_customer_alt_names');
 END update_customer_alt_names;

 --
 --
 --
 PROCEDURE Insert_Row(
                       X_Customer_Profile_Id     IN OUT NOCOPY NUMBER,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Credit_Checking                VARCHAR2,
                       X_Credit_Hold                    VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Dunning_Letters                VARCHAR2,
                       X_Interest_Charges               VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Statements                     VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Account_Status                 VARCHAR2,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Credit_Rating                  VARCHAR2,
                       X_Customer_Profile_Class_Id      NUMBER,
                       X_Discount_Grace_Days            NUMBER,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Interest_Period_Days           NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Percent_Collectable            NUMBER,
                       X_Risk_Code                      VARCHAR2,
                       X_Site_Use_Id                    NUMBER,
                       X_Standard_Terms                 NUMBER,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Charge_On_Fin_Charge_Flag   	VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Clearing_Days                  NUMBER,
                       X_Jgzz_attribute_Category        VARCHAR2,
                       X_Jgzz_attribute1                VARCHAR2,
                       X_Jgzz_attribute2                VARCHAR2,
                       X_Jgzz_attribute3                VARCHAR2,
                       X_Jgzz_attribute4                VARCHAR2,
                       X_Jgzz_attribute5                VARCHAR2,
                       X_Jgzz_attribute6                VARCHAR2,
                       X_Jgzz_attribute7                VARCHAR2,
                       X_Jgzz_attribute8                VARCHAR2,
                       X_Jgzz_attribute9                VARCHAR2,
                       X_Jgzz_attribute10               VARCHAR2,
                       X_Jgzz_attribute11               VARCHAR2,
                       X_Jgzz_attribute12               VARCHAR2,
                       X_Jgzz_attribute13               VARCHAR2,
                       X_Jgzz_attribute14               VARCHAR2,
                       X_Jgzz_attribute15               VARCHAR2,
                       X_global_attribute_category        VARCHAR2,
                       X_global_attribute1                VARCHAR2,
                       X_global_attribute2                VARCHAR2,
                       X_global_attribute3                VARCHAR2,
                       X_global_attribute4                VARCHAR2,
                       X_global_attribute5                VARCHAR2,
                       X_global_attribute6                VARCHAR2,
                       X_global_attribute7                VARCHAR2,
                       X_global_attribute8                VARCHAR2,
                       X_global_attribute9                VARCHAR2,
                       X_global_attribute10               VARCHAR2,
                       X_global_attribute11               VARCHAR2,
                       X_global_attribute12               VARCHAR2,
                       X_global_attribute13               VARCHAR2,
                       X_global_attribute14               VARCHAR2,
                       X_global_attribute15               VARCHAR2,
                       X_global_attribute16               VARCHAR2,
                       X_global_attribute17               VARCHAR2,
                       X_global_attribute18               VARCHAR2,
                       X_global_attribute19               VARCHAR2,
                       X_global_attribute20               VARCHAR2,
                       X_lockbox_matching_option          VARCHAR2,
                       X_autocash_hierarchy_id_adr        NUMBER,
--{ BUG 2310474
                       X_Review_Cycle                     VARCHAR2 DEFAULT NULL,
                       X_Credit_Classification            VARCHAR2 DEFAULT NULL,
                       X_Next_Credit_Review_Date          DATE     DEFAULT NULL,
                       X_Last_Credit_Review_Date          DATE     DEFAULT NULL,
                       X_Credit_Analyst_id                NUMBER   DEFAULT NULL,
                       X_Party_id                         NUMBER   DEFAULT NULL,
--}
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2
  )
 IS
-- suse_rec        hz_customer_accounts_pub.acct_site_uses_rec_type;
-- prof_rec        hz_customer_accounts_pub.cust_profile_rec_type;
  suse_rec        hz_cust_account_site_v2pub.cust_site_use_rec_type;
  prof_rec        hz_customer_profile_v2pub.customer_profile_rec_type;

  i_site_use_id   NUMBER;
  tmp_var         VARCHAR2(2000);
  i               NUMBER;
  tmp_var1        VARCHAR2(2000);
  l_cust_account_profile_id NUMBER;
 BEGIN

      hzp_cprof_pkg.check_unique (
           p_customer_id => x_customer_id,
           p_site_use_id => x_site_use_id
      );

      --
      -- The form may have already allocated on value to customer_profile_id
      -- in order bt create profile ammounts from a prfile class
      --
      IF ( x_customer_profile_id is null ) THEN
      --
        SELECT  hz_customer_profiles_s.nextval
          INTO  x_customer_profile_id
          FROM  dual;
      --
      END IF;
      --
      --
      IF (X_Credit_Hold = 'Y') THEN
           arh_cprof1_pkg.check_credit_hold(
              p_customer_id => X_Customer_Id,
              p_site_use_id => X_Site_Use_Id,
              p_credit_hold => X_Credit_Hold);
      END IF;
      --
      --
      prof_rec.cust_account_profile_id       := X_Customer_Profile_Id;
      prof_rec.cust_account_id               := X_Customer_Id;
      prof_rec.status                        := x_status;
      prof_rec.collector_id                  := x_collector_id;
--{2310474
      prof_rec.credit_analyst_id             := X_credit_analyst_id;
      prof_rec.next_credit_review_date       := x_next_credit_review_date;
--}
      prof_rec.credit_checking               := x_credit_checking;
      prof_rec.tolerance                     := x_tolerance;
      prof_rec.discount_terms                := x_discount_terms;
      prof_rec.dunning_letters               := x_dunning_letters;
      prof_rec.interest_charges              := x_interest_charges;
      prof_rec.send_statements               := x_statements;
      prof_rec.credit_balance_statements     := x_credit_balance_statements;
      prof_rec.credit_hold                   := x_credit_hold;
      prof_rec.profile_class_id              := X_Customer_Profile_Class_Id;
      prof_rec.site_use_id                   := X_Site_Use_Id;
      prof_rec.credit_rating                 := x_credit_rating;
      prof_rec.risk_code                     := x_risk_code;
      prof_rec.standard_terms                := x_standard_terms;
      prof_rec.override_terms                := x_override_terms;
      prof_rec.dunning_letter_set_id         := x_dunning_letter_set_id;
      prof_rec.interest_period_days          := x_interest_period_days;
      prof_rec.payment_grace_days            := x_payment_grace_days;
      prof_rec.discount_grace_days           := x_discount_grace_days;
      prof_rec.statement_cycle_id            := x_statement_cycle_id;
      prof_rec.account_status                := x_account_status;
      prof_rec.percent_collectable           := x_percent_collectable;
      prof_rec.autocash_hierarchy_id         := x_autocash_hierarchy_id;
      prof_rec.attribute_category            := x_attribute_category;
      prof_rec.attribute1                    := x_attribute1;
      prof_rec.attribute2                    := x_attribute2;
      prof_rec.attribute3                    := x_attribute3;
      prof_rec.attribute4                    := x_attribute4;
      prof_rec.attribute5                    := x_attribute5;
      prof_rec.attribute6                    := x_attribute6;
      prof_rec.attribute7                    := x_attribute7;
      prof_rec.attribute8                    := x_attribute8;
      prof_rec.attribute9                    := x_attribute9;
      prof_rec.attribute10                   := x_attribute10;
      prof_rec.attribute11                   := x_attribute11;
      prof_rec.attribute12                   := x_attribute12;
      prof_rec.attribute13                   := x_attribute13;
      prof_rec.attribute14                   := x_attribute14;
      prof_rec.attribute15                   := x_attribute15;
      prof_rec.auto_rec_incl_disputed_flag   := x_auto_rec_incl_disputed_flag;
      prof_rec.tax_printing_option           := x_tax_printing_option;
      prof_rec.charge_on_finance_charge_flag := x_charge_on_fin_charge_flag;
      prof_rec.grouping_rule_id              := x_grouping_rule_id;
      prof_rec.clearing_days                 := x_clearing_days;
      prof_rec.jgzz_attribute_category       := x_jgzz_attribute_category;
      prof_rec.jgzz_attribute1               := x_jgzz_attribute1;
      prof_rec.jgzz_attribute2               := x_jgzz_attribute2;
      prof_rec.jgzz_attribute3               := x_jgzz_attribute3;
      prof_rec.jgzz_attribute4               := x_jgzz_attribute4;
      prof_rec.jgzz_attribute5               := x_jgzz_attribute5;
      prof_rec.jgzz_attribute6               := x_jgzz_attribute6;
      prof_rec.jgzz_attribute7               := x_jgzz_attribute7;
      prof_rec.jgzz_attribute8               := x_jgzz_attribute8;
      prof_rec.jgzz_attribute9               := x_jgzz_attribute9;
      prof_rec.jgzz_attribute10              := x_jgzz_attribute10;
      prof_rec.jgzz_attribute11              := x_jgzz_attribute11;
      prof_rec.jgzz_attribute12              := x_jgzz_attribute12;
      prof_rec.jgzz_attribute13              := x_jgzz_attribute13;
      prof_rec.jgzz_attribute14              := x_jgzz_attribute14;
      prof_rec.jgzz_attribute15              := x_jgzz_attribute15;
      prof_rec.global_attribute1             := x_global_attribute1;
      prof_rec.global_attribute2             := x_global_attribute2;
      prof_rec.global_attribute3             := x_global_attribute3;
      prof_rec.global_attribute4             := x_global_attribute4;
      prof_rec.global_attribute5             := x_global_attribute5;
      prof_rec.global_attribute6             := x_global_attribute6;
      prof_rec.global_attribute7             := x_global_attribute7;
      prof_rec.global_attribute8             := x_global_attribute8;
      prof_rec.global_attribute9             := x_global_attribute9;
      prof_rec.global_attribute10            := x_global_attribute10;
      prof_rec.global_attribute11            := x_global_attribute11;
      prof_rec.global_attribute12            := x_global_attribute12;
      prof_rec.global_attribute13            := x_global_attribute13;
      prof_rec.global_attribute14            := x_global_attribute14;
      prof_rec.global_attribute15            := x_global_attribute15;
      prof_rec.global_attribute16            := x_global_attribute16;
      prof_rec.global_attribute17            := x_global_attribute17;
      prof_rec.global_attribute18            := x_global_attribute18;
      prof_rec.global_attribute19            := x_global_attribute19;
      prof_rec.global_attribute20            := x_global_attribute20;
      prof_rec.global_attribute_category     := x_global_attribute_category;
      prof_rec.cons_inv_flag                 := x_cons_inv_flag;
      prof_rec.cons_inv_type                 := x_cons_inv_type;
      prof_rec.autocash_hierarchy_id_for_adr := X_autocash_hierarchy_id_adr;
      prof_rec.lockbox_matching_option       := x_lockbox_matching_option ;
--{2310474
      prof_rec.review_cycle                  := x_review_cycle;
      prof_rec.credit_classification         := x_credit_classification;
      prof_rec.last_credit_review_date       := x_last_credit_review_date;
      prof_rec.party_id                      := x_party_id;
--}

   /* Commented for Bug No : 2134837
        HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
            p_cust_site_use_rec                 => suse_rec,
            p_customer_profile_rec              => prof_rec,
            p_create_profile                    => fnd_api.g_true,
            p_create_profile_amt                => fnd_api.g_false,
            x_site_use_id                       => i_site_use_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data
        );
   */
     prof_rec.created_by_module                  := 'TCA_FORM_WRAPPER';
        HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
            p_customer_profile_rec              => prof_rec,
            p_create_profile_amt                => fnd_api.g_false,
            x_cust_account_profile_id           => l_cust_account_profile_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data
        );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

  END Insert_Row;


  PROCEDURE insert_row(x_customer_id                NUMBER,
                     x_site_use_id                NUMBER,
                     x_customer_profile_class_id  NUMBER,
                     x_party_id                   NUMBER DEFAULT NULL,
                     x_last_credit_review_date    DATE   DEFAULT NULL,
                     x_next_credit_review_date    DATE   DEFAULT NULL )
  IS
  --
  --
   l_customer_profile_id number;
   x_cust_prof_rec       HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
  --
   CURSOR cu_class IS
   SELECT *
     FROM hz_cust_profile_classes
    WHERE profile_class_id  = x_customer_profile_class_id;

   lrec  hz_cust_profile_classes%ROWTYPE;
   x_return_status  VARCHAR2(10);
   x_msg_count      NUMBER;
   x_msg_data       VARCHAR2(2000);
   tmp_var          VARCHAR2(2000);
   i                number;
   tmp_var1         VARCHAR2(2000);

  BEGIN
    --
    OPEN cu_class;
    FETCH cu_class INTO lrec;
    CLOSE cu_class;
    --
    SELECT hz_customer_profiles_s.NEXTVAL
      INTO l_customer_profile_id
      FROM DUAL;
    --
    x_cust_prof_rec.cust_account_profile_id := l_customer_profile_id;
    x_cust_prof_rec.cust_account_id         := x_customer_id;
    x_cust_prof_rec.site_use_id             := x_site_use_id;
    x_cust_prof_rec.collector_id            := lrec.collector_id;
    x_cust_prof_rec.credit_checking         := lrec.credit_checking;
    x_cust_prof_rec.tolerance               := lrec.tolerance;
    x_cust_prof_rec.tax_printing_option     := lrec.tax_printing_option;
    x_cust_prof_rec.discount_terms          := lrec.discount_terms;
    x_cust_prof_rec.dunning_letters         := lrec.dunning_letters;
    x_cust_prof_rec.interest_charges        := lrec.interest_charges;
    x_cust_prof_rec.send_statements         := lrec.statements;
    x_cust_prof_rec.credit_balance_statements:= lrec.credit_balance_statements;
    x_cust_prof_rec.credit_hold             := 'N';
    x_cust_prof_rec.profile_class_id        := lrec.profile_class_id;
    x_cust_prof_rec.standard_terms          := lrec.standard_terms;
    x_cust_prof_rec.override_terms          := lrec.override_terms;
    x_cust_prof_rec.dunning_letter_set_id   := lrec.dunning_letter_set_id;
    x_cust_prof_rec.interest_period_days    := lrec.interest_period_days;
    x_cust_prof_rec.payment_grace_days      := lrec.payment_grace_days;
    x_cust_prof_rec.discount_grace_days     := lrec.discount_grace_days;
    x_cust_prof_rec.statement_cycle_id      := lrec.statement_cycle_id;
    x_cust_prof_rec.attribute_category      := lrec.attribute_category;
    x_cust_prof_rec.attribute1              := lrec.attribute1;
    x_cust_prof_rec.attribute2              := lrec.attribute2;
    x_cust_prof_rec.attribute3              := lrec.attribute3;
    x_cust_prof_rec.attribute4              := lrec.attribute4;
    x_cust_prof_rec.attribute5              := lrec.attribute5;
    x_cust_prof_rec.attribute6              := lrec.attribute6;
    x_cust_prof_rec.attribute7              := lrec.attribute7;
    x_cust_prof_rec.attribute8              := lrec.attribute8;
    x_cust_prof_rec.attribute9              := lrec.attribute9;
    x_cust_prof_rec.attribute10             := lrec.attribute10;
    x_cust_prof_rec.attribute11             := lrec.attribute11;
    x_cust_prof_rec.attribute12             := lrec.attribute12;
    x_cust_prof_rec.attribute13             := lrec.attribute13;
    x_cust_prof_rec.attribute14             := lrec.attribute14;
    x_cust_prof_rec.attribute15             := lrec.attribute15;
    x_cust_prof_rec.jgzz_attribute_category := lrec.jgzz_attribute_category;
    x_cust_prof_rec.jgzz_attribute1         := lrec.jgzz_attribute1;
    x_cust_prof_rec.jgzz_attribute2         := lrec.jgzz_attribute2;
    x_cust_prof_rec.jgzz_attribute3         := lrec.jgzz_attribute3;
    x_cust_prof_rec.jgzz_attribute4         := lrec.jgzz_attribute4;
    x_cust_prof_rec.jgzz_attribute5         := lrec.jgzz_attribute5;
    x_cust_prof_rec.jgzz_attribute6         := lrec.jgzz_attribute6;
    x_cust_prof_rec.jgzz_attribute7         := lrec.jgzz_attribute7;
    x_cust_prof_rec.jgzz_attribute8         := lrec.jgzz_attribute8;
    x_cust_prof_rec.jgzz_attribute9         := lrec.jgzz_attribute9;
    x_cust_prof_rec.jgzz_attribute10        := lrec.jgzz_attribute10;
    x_cust_prof_rec.jgzz_attribute11        := lrec.jgzz_attribute11;
    x_cust_prof_rec.jgzz_attribute12        := lrec.jgzz_attribute12;
    x_cust_prof_rec.jgzz_attribute13        := lrec.jgzz_attribute13;
    x_cust_prof_rec.jgzz_attribute14        := lrec.jgzz_attribute14;
    x_cust_prof_rec.jgzz_attribute15        := lrec.jgzz_attribute15;
    x_cust_prof_rec.status                  := 'A';
    x_cust_prof_rec.auto_rec_incl_disputed_flag := lrec.auto_rec_incl_disputed_flag;
    x_cust_prof_rec.autocash_hierarchy_id   :=  lrec.autocash_hierarchy_id;
    x_cust_prof_rec.charge_on_finance_charge_flag := lrec.charge_on_finance_charge_flag;
    x_cust_prof_rec.grouping_rule_id        := lrec.grouping_rule_id;
    x_cust_prof_rec.cons_inv_flag           := lrec.cons_inv_flag;
    x_cust_prof_rec.cons_inv_type           := lrec.cons_inv_type;
    x_cust_prof_rec.lockbox_matching_option := lrec.lockbox_matching_option;
    x_cust_prof_rec.autocash_hierarchy_id_for_adr := lrec.autocash_hierarchy_id_for_adr;
    x_cust_prof_rec.created_by_module       := 'TCA_FORM_WRAPPER';
--{2310474
    x_cust_prof_rec.review_cycle            := lrec.review_cycle;
    x_cust_prof_rec.credit_classification   := lrec.credit_classification;
    x_cust_prof_rec.credit_analyst_id       := lrec.credit_analyst_id;
    x_cust_prof_rec.next_credit_review_date := x_next_credit_review_date;
    x_cust_prof_rec.last_credit_review_date := x_last_credit_review_date;
    x_cust_prof_rec.party_id                := x_party_id;
--}

    HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
       p_customer_profile_rec           => x_cust_prof_rec,
       x_cust_account_profile_id        => l_customer_profile_id,
       x_return_status                  => x_return_status,
       x_msg_count                      => x_msg_count,
       x_msg_data                       => x_msg_data );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
    END IF;

  END insert_row;
  --
  --
  --
  --
  --
  --
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Customer_Profile_Id            NUMBER,
                       X_Auto_Rec_Incl_Disputed_Flag    VARCHAR2,
                       X_Collector_Id                   NUMBER,
                       X_Credit_Balance_Statements      VARCHAR2,
                       X_Credit_Checking                VARCHAR2,
                       X_Credit_Hold                    VARCHAR2,
                       X_Customer_Id                    NUMBER,
                       X_Discount_Terms                 VARCHAR2,
                       X_Dunning_Letters                VARCHAR2,
                       X_Interest_Charges               VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Statements                     VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Tolerance                      NUMBER,
                       X_Tax_Printing_Option            VARCHAR2,
                       X_Account_Status                 VARCHAR2,
                       X_Autocash_Hierarchy_Id          NUMBER,
                       X_Credit_Rating                  VARCHAR2,
                       X_Customer_Profile_Class_Id      NUMBER,
                       X_Discount_Grace_Days            NUMBER,
                       X_Dunning_Letter_Set_Id          NUMBER,
                       X_Interest_Period_Days           NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Override_Terms                 VARCHAR2,
                       X_Payment_Grace_Days             NUMBER,
                       X_Percent_Collectable            NUMBER,
                       X_Risk_Code                      VARCHAR2,
                       X_Site_Use_Id                    NUMBER,
                       X_Standard_Terms                 NUMBER,
                       X_Statement_Cycle_Id             NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Charge_On_Fin_Charge_Flag  VARCHAR2,
                       X_Grouping_Rule_Id               NUMBER,
                       X_Cons_Inv_Flag                  VARCHAR2,
                       X_Cons_Inv_Type                  VARCHAR2,
                       X_Clearing_Days                  NUMBER,
                       X_Jgzz_attribute_Category             VARCHAR2,
                       X_Jgzz_attribute1                     VARCHAR2,
                       X_Jgzz_attribute2                     VARCHAR2,
                       X_Jgzz_attribute3                     VARCHAR2,
                       X_Jgzz_attribute4                     VARCHAR2,
                       X_Jgzz_attribute5                     VARCHAR2,
                       X_Jgzz_attribute6                     VARCHAR2,
                       X_Jgzz_attribute7                     VARCHAR2,
                       X_Jgzz_attribute8                     VARCHAR2,
                       X_Jgzz_attribute9                     VARCHAR2,
                       X_Jgzz_attribute10                    VARCHAR2,
                       X_Jgzz_attribute11                    VARCHAR2,
                       X_Jgzz_attribute12                    VARCHAR2,
                       X_Jgzz_attribute13                    VARCHAR2,
                       X_Jgzz_attribute14                    VARCHAR2,
                       X_Jgzz_attribute15                    VARCHAR2,
                       X_global_attribute_category        VARCHAR2,
                       X_global_attribute1                VARCHAR2,
                       X_global_attribute2                VARCHAR2,
                       X_global_attribute3                VARCHAR2,
                       X_global_attribute4                VARCHAR2,
                       X_global_attribute5                VARCHAR2,
                       X_global_attribute6                VARCHAR2,
                       X_global_attribute7                VARCHAR2,
                       X_global_attribute8                VARCHAR2,
                       X_global_attribute9                VARCHAR2,
                       X_global_attribute10               VARCHAR2,
                       X_global_attribute11               VARCHAR2,
                       X_global_attribute12               VARCHAR2,
                       X_global_attribute13               VARCHAR2,
                       X_global_attribute14               VARCHAR2,
                       X_global_attribute15               VARCHAR2,
                       X_global_attribute16               VARCHAR2,
                       X_global_attribute17               VARCHAR2,
                       X_global_attribute18               VARCHAR2,
                       X_global_attribute19               VARCHAR2,
                       X_global_attribute20               VARCHAR2,
                       X_lockbox_matching_option          VARCHAR2,
                       X_autocash_hierarchy_id_adr        NUMBER,
--{2310474
                       X_party_id                         NUMBER    DEFAULT NULL,
                       X_review_cycle                     VARCHAR2  DEFAULT NULL,
                       X_credit_classification            VARCHAR2  DEFAULT NULL,
                       X_credit_analyst_id                NUMBER    DEFAULT NULL,
                       X_last_credit_review_date          DATE      DEFAULT NULL,
                       X_next_credit_review_date          DATE      DEFAULT NULL,
--}
                       X_object_version                IN NUMBER DEFAULT -1
  ) IS
    l_object_version       NUMBER;
    l_rowid                ROWID;
    x_msg_count            NUMBER;
    x_msg_data             VARCHAR2(2000);
    x_return_status        VARCHAR2(10);
    tmp_var                VARCHAR2(2000);
    i                      number;
    tmp_var1               VARCHAR2(2000);
    l_cp_rec               HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    Exc_g                  EXCEPTION;
  BEGIN
    l_object_version := x_object_version;

    IF l_object_version = -1 THEN

     SELECT OBJECT_VERSION_NUMBER
        INTO l_object_version
        FROM HZ_CUSTOMER_PROFILES
       WHERE ROWID = X_rowid;

      IF (SQL%NOTFOUND) THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','HZ_CUSTOMER_PROFILES');
        FND_MESSAGE.SET_TOKEN('ID',X_Customer_Profile_Id);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
           p_encoded => FND_API.G_FALSE,
           p_count => x_msg_count,
           p_data  => x_msg_data );

        IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := SUBSTRB(tmp_var1,1,2000);
        END IF;

        Raise Exc_g;

      END IF;

    END IF;


    arh_cprof1_pkg.check_credit_hold (  p_customer_id => x_customer_id,
                                       p_site_use_id => x_site_use_id,
                                       p_credit_hold => x_credit_hold
                                    );
    --
    hzp_cprof_pkg.update_customer_alt_names( X_Rowid , X_Standard_Terms ,
                                          X_Customer_Id , X_Site_Use_Id ) ;
    --
       l_cp_rec.cust_account_profile_id         :=    INIT_SWITCH(X_Customer_Profile_Id);
       l_cp_rec.auto_rec_incl_disputed_flag     :=    INIT_SWITCH(X_Auto_Rec_Incl_Disputed_Flag);
       l_cp_rec.collector_id                    :=    INIT_SWITCH(X_Collector_Id);
       l_cp_rec.credit_balance_statements       :=    INIT_SWITCH( X_Credit_Balance_Statements);
       l_cp_rec.credit_checking                 :=    INIT_SWITCH( X_Credit_Checking);
       l_cp_rec.credit_hold                     :=    INIT_SWITCH( X_Credit_Hold);
       l_cp_rec.cust_account_id                 :=    INIT_SWITCH( X_Customer_Id);
       l_cp_rec.discount_terms                  :=    INIT_SWITCH( X_Discount_Terms);
       l_cp_rec.dunning_letters                 :=    INIT_SWITCH( X_Dunning_Letters);
       l_cp_rec.interest_charges                :=    INIT_SWITCH( X_Interest_Charges);
--       l_cp_rec.last_updated_by                 :=    INIT_SWITCH( X_Last_Updated_By);
--       l_cp_rec.last_update_date                :=    INIT_SWITCH( X_Last_Update_Date);
       l_cp_rec.send_statements                 :=    INIT_SWITCH( X_Statements);
       l_cp_rec.status                          :=    INIT_SWITCH( X_Status);
       l_cp_rec.tolerance                       :=    INIT_SWITCH( X_Tolerance);
       l_cp_rec.tax_printing_option             :=    INIT_SWITCH( X_Tax_Printing_Option);
       l_cp_rec.account_status                  :=    INIT_SWITCH( X_Account_Status);
       l_cp_rec.autocash_hierarchy_id           :=    INIT_SWITCH( X_Autocash_Hierarchy_Id);
       l_cp_rec.credit_rating                   :=    INIT_SWITCH( X_Credit_Rating);
       l_cp_rec.profile_class_id                :=    INIT_SWITCH( X_Customer_Profile_Class_Id);
       l_cp_rec.discount_grace_days             :=    INIT_SWITCH( X_Discount_Grace_Days);
       l_cp_rec.dunning_letter_set_id           :=    INIT_SWITCH( X_Dunning_Letter_Set_Id);
       l_cp_rec.interest_period_days            :=    INIT_SWITCH( X_Interest_Period_Days);
--       l_cp_rec.last_update_login               :=    INIT_SWITCH( X_Last_Update_Login);
       l_cp_rec.override_terms                  :=    INIT_SWITCH( X_Override_Terms);
       l_cp_rec.payment_grace_days              :=    INIT_SWITCH( X_Payment_Grace_Days);
       l_cp_rec.percent_collectable             :=    INIT_SWITCH( X_Percent_Collectable);
       l_cp_rec.risk_code                       :=    INIT_SWITCH( X_Risk_Code);
       l_cp_rec.site_use_id                     :=    INIT_SWITCH( X_Site_Use_Id);
       l_cp_rec.standard_terms                  :=    INIT_SWITCH( X_Standard_Terms);
       l_cp_rec.statement_cycle_id              :=    INIT_SWITCH( X_Statement_Cycle_Id);
       l_cp_rec.attribute_category              :=    INIT_SWITCH( X_Attribute_Category);
       l_cp_rec.attribute1                      :=    INIT_SWITCH( X_Attribute1);
       l_cp_rec.attribute2                      :=    INIT_SWITCH( X_Attribute2);
       l_cp_rec.attribute3                      :=    INIT_SWITCH( X_Attribute3);
       l_cp_rec.attribute4                      :=    INIT_SWITCH( X_Attribute4);
       l_cp_rec.attribute5                      :=    INIT_SWITCH( X_Attribute5);
       l_cp_rec.attribute6                      :=    INIT_SWITCH( X_Attribute6);
       l_cp_rec.attribute7                      :=    INIT_SWITCH( X_Attribute7);
       l_cp_rec.attribute8                      :=    INIT_SWITCH( X_Attribute8);
       l_cp_rec.attribute9                      :=    INIT_SWITCH( X_Attribute9);
       l_cp_rec.attribute10                     :=    INIT_SWITCH( X_Attribute10);
       l_cp_rec.attribute11                     :=    INIT_SWITCH( X_Attribute11);
       l_cp_rec.attribute12                     :=    INIT_SWITCH( X_Attribute12);
       l_cp_rec.attribute13                     :=    INIT_SWITCH( X_Attribute13);
       l_cp_rec.attribute14                     :=    INIT_SWITCH( X_Attribute14);
       l_cp_rec.attribute15                     :=    INIT_SWITCH( X_Attribute15);
       l_cp_rec.charge_on_finance_charge_flag   :=    INIT_SWITCH( X_Charge_On_Fin_Charge_Flag);
       l_cp_rec.grouping_rule_id                :=    INIT_SWITCH( X_Grouping_Rule_Id);
       l_cp_rec.cons_inv_flag                   :=    INIT_SWITCH( X_Cons_Inv_Flag);
       l_cp_rec.cons_inv_type                   :=    INIT_SWITCH( X_Cons_Inv_Type);
       l_cp_rec.clearing_days                   :=    INIT_SWITCH( X_Clearing_Days);
       l_cp_rec.jgzz_attribute_category         :=    INIT_SWITCH( X_Jgzz_attribute_Category);
       l_cp_rec.jgzz_attribute1                 :=    INIT_SWITCH( X_Jgzz_attribute1);
       l_cp_rec.jgzz_attribute2                 :=    INIT_SWITCH( X_Jgzz_attribute2);
       l_cp_rec.jgzz_attribute3                 :=    INIT_SWITCH( X_Jgzz_attribute3);
       l_cp_rec.jgzz_attribute4                 :=    INIT_SWITCH( X_Jgzz_attribute4);
       l_cp_rec.jgzz_attribute5                 :=    INIT_SWITCH( X_Jgzz_attribute5);
       l_cp_rec.jgzz_attribute6                 :=    INIT_SWITCH( X_Jgzz_attribute6);
       l_cp_rec.jgzz_attribute7                 :=    INIT_SWITCH( X_Jgzz_attribute7);
       l_cp_rec.jgzz_attribute8                 :=    INIT_SWITCH( X_Jgzz_attribute8);
       l_cp_rec.jgzz_attribute9                 :=    INIT_SWITCH( X_Jgzz_attribute9);
       l_cp_rec.jgzz_attribute10                :=    INIT_SWITCH( X_Jgzz_attribute10);
       l_cp_rec.jgzz_attribute11                :=    INIT_SWITCH( X_Jgzz_attribute11);
       l_cp_rec.jgzz_attribute12                :=    INIT_SWITCH( X_Jgzz_attribute12);
       l_cp_rec.jgzz_attribute13                :=    INIT_SWITCH( X_Jgzz_attribute13);
       l_cp_rec.jgzz_attribute14                :=    INIT_SWITCH( X_Jgzz_attribute14);
       l_cp_rec.jgzz_attribute15                :=    INIT_SWITCH( X_Jgzz_attribute15);
       l_cp_rec.global_attribute_category       :=    INIT_SWITCH( X_global_attribute_category);
       l_cp_rec.global_attribute1               :=    INIT_SWITCH( X_global_attribute1);
       l_cp_rec.global_attribute2               :=    INIT_SWITCH( X_global_attribute2);
       l_cp_rec.global_attribute3               :=    INIT_SWITCH( X_global_attribute3);
       l_cp_rec.global_attribute4               :=    INIT_SWITCH( X_global_attribute4);
       l_cp_rec.global_attribute5               :=    INIT_SWITCH( X_global_attribute5);
       l_cp_rec.global_attribute6               :=    INIT_SWITCH( X_global_attribute6);
       l_cp_rec.global_attribute7               :=    INIT_SWITCH( X_global_attribute7);
       l_cp_rec.global_attribute8               :=    INIT_SWITCH( X_global_attribute8);
       l_cp_rec.global_attribute9               :=    INIT_SWITCH( X_global_attribute9);
       l_cp_rec.global_attribute10              :=    INIT_SWITCH( X_global_attribute10);
       l_cp_rec.global_attribute11              :=    INIT_SWITCH( X_global_attribute11);
       l_cp_rec.global_attribute12              :=    INIT_SWITCH( X_global_attribute12);
       l_cp_rec.global_attribute13              :=    INIT_SWITCH( X_global_attribute13);
       l_cp_rec.global_attribute14              :=    INIT_SWITCH( X_global_attribute14);
       l_cp_rec.global_attribute15              :=    INIT_SWITCH( X_global_attribute15);
       l_cp_rec.global_attribute16              :=    INIT_SWITCH( X_global_attribute16);
       l_cp_rec.global_attribute17              :=    INIT_SWITCH( X_global_attribute17);
       l_cp_rec.global_attribute18              :=    INIT_SWITCH( X_global_attribute18);
       l_cp_rec.global_attribute19              :=    INIT_SWITCH( X_global_attribute19);
       l_cp_rec.global_attribute20              :=    INIT_SWITCH( X_global_attribute20);
       l_cp_rec.lockbox_matching_option         :=    INIT_SWITCH( X_lockbox_matching_option);
       l_cp_rec.autocash_hierarchy_id_for_adr   :=    INIT_SWITCH( X_autocash_hierarchy_id_adr);
       l_cp_rec.created_by_module               :=    'TCA_FORM_WRAPPER';
--{2310474
       l_cp_rec.party_id                        :=    X_party_id;
       l_cp_rec.review_cycle                    :=    INIT_SWITCH( X_review_cycle);
       l_cp_rec.credit_classification           :=    INIT_SWITCH( X_credit_classification);
       l_cp_rec.credit_analyst_id               :=    INIT_SWITCH( X_credit_analyst_id);
       l_cp_rec.next_credit_review_date         :=    INIT_SWITCH( X_next_credit_review_date);
       l_cp_rec.last_credit_review_date         :=    INIT_SWITCH( X_last_credit_review_date);
--}

    HZ_CUSTOMER_PROFILE_V2PUB.update_customer_profile (
      p_customer_profile_rec                  => l_cp_rec,
      p_object_version_number                 => l_object_version,
      x_return_status                         => x_return_status,
      x_msg_count                             => x_msg_count,
      x_msg_data                              => x_msg_data );

    IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE Exc_g;
    END IF;

  EXCEPTION
   WHEN Exc_g THEN
     RAISE_APPLICATION_ERROR(-20000,x_msg_data);
  END Update_Row;
--
--
--
--
-- PROCEDURE
--     create_profile_from_class
--
-- DESCRIPTION
--	This procedure creates a customer profile from the customr_profile_class
--	It is designed to be called from the cust_prof|addr_prof blocks of the
--	enter customer form.
--
--	It returns all the profiles attributes to the form ans sliently
--      creates the rows in ar_customer_profile_amounts;
--
--	It is assume that the calling forms has no uncomitted rows for the
-- 	table hz_customer_profile_amounts.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:
--
--              OUT:
--                    None
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--  Marijo Erickson   7/25/01  Bug 1591948: Remove the unnecessary fetching of
--                                          the "global attribute" fields to
--                                          accommodate globalization logic.
--  Marijo Erickson   1/29/02  Bug 2046191: revised to delete all prior currency
--                                          amounts to accurately reflect the
--                                          current profile class currencies
--                                          and their respective amounts.
--  Herve Yu         13/08/03  Bug 3046535: profile_amount can be either kept
--                                          or replaced
 PROCEDURE create_profile_from_class
                (       x_customer_profile_class_id     in number,
                        x_customer_profile_id           in out NOCOPY number,
                        x_customer_id                   in out NOCOPY number,
                        x_site_use_id                   in number,
                        x_collector_id                  out NOCOPY number,
                        x_collector_name                out NOCOPY varchar2,
                        x_credit_checking               out NOCOPY varchar2,
                        x_tolerance                     out NOCOPY number,
                        x_interest_charges              out NOCOPY varchar2,
                        x_charge_on_fin_charge_flag     out NOCOPY varchar2,
                        x_interest_period_days          out NOCOPY number,
                        x_discount_terms                out NOCOPY varchar2,
                        x_discount_grace_days           out NOCOPY number,
                        x_statements                    out NOCOPY varchar2,
                        x_statement_cycle_id            out NOCOPY number,
                        x_statement_cycle_name          out NOCOPY varchar2,
                        x_credit_balance_statements     out NOCOPY varchar2,
                        x_standard_terms                out NOCOPY number,
                        x_standard_terms_name           out NOCOPY varchar2,
                        x_override_terms                out NOCOPY varchar2,
                        x_payment_grace_days            out NOCOPY number,
                        x_dunning_letters               out NOCOPY varchar2,
                        x_dunning_letter_set_id         out NOCOPY number,
                        x_dunning_letter_set_name       out NOCOPY varchar2,
                        x_autocash_hierarchy_id         out NOCOPY number,
                        x_autocash_hierarchy_name       out NOCOPY varchar2,
                        x_auto_rec_incl_disputed_flag   out NOCOPY varchar2,
                        x_tax_printing_option           out NOCOPY varchar2,
                        x_grouping_rule_id              out NOCOPY number,
                        x_grouping_rule_name            out NOCOPY varchar2,
                        x_cons_inv_flag                 out NOCOPY varchar2,
                        x_cons_inv_type                 out NOCOPY varchar2,
                        x_attribute_category            out NOCOPY varchar2,
                        x_attribute1                    out NOCOPY varchar2,
                        x_attribute2                    out NOCOPY varchar2,
                        x_attribute3                    out NOCOPY varchar2,
                        x_attribute4                    out NOCOPY varchar2,
                        x_attribute5                    out NOCOPY varchar2,
                        x_attribute6                    out NOCOPY varchar2,
                        x_attribute7                    out NOCOPY varchar2,
                        x_attribute8                    out NOCOPY varchar2,
                        x_attribute9                    out NOCOPY varchar2,
                        x_attribute10                   out NOCOPY varchar2,
                        x_attribute11                   out NOCOPY varchar2,
                        x_attribute12                   out NOCOPY varchar2,
                        x_attribute13                   out NOCOPY varchar2,
                        x_attribute14                   out NOCOPY varchar2,
                        x_attribute15                   out NOCOPY varchar2,
                        x_jgzz_attribute_category       out NOCOPY varchar2,
                        x_jgzz_attribute1               out NOCOPY varchar2,
                        x_jgzz_attribute2               out NOCOPY varchar2,
                        x_jgzz_attribute3               out NOCOPY varchar2,
                        x_jgzz_attribute4               out NOCOPY varchar2,
                        x_jgzz_attribute5               out NOCOPY varchar2,
                        x_jgzz_attribute6               out NOCOPY varchar2,
                        x_jgzz_attribute7               out NOCOPY varchar2,
                        x_jgzz_attribute8               out NOCOPY varchar2,
                        x_jgzz_attribute9               out NOCOPY varchar2,
                        x_jgzz_attribute10              out NOCOPY varchar2,
                        x_jgzz_attribute11              out NOCOPY varchar2,
                        x_jgzz_attribute12              out NOCOPY varchar2,
                        x_jgzz_attribute13              out NOCOPY varchar2,
                        x_jgzz_attribute14              out NOCOPY varchar2,
                        x_jgzz_attribute15              out NOCOPY varchar2,
                        x_lockbox_matching_option       out NOCOPY varchar2,
                        x_lockbox_matching_name         out NOCOPY varchar2,
                        x_autocash_hierarchy_id_adr     out NOCOPY number,
                        x_autocash_hierarchy_name_adr   out NOCOPY varchar2,
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2,
                        --{BUG#3046535
                        p_keep_replace                  IN  VARCHAR2 DEFAULT 'KEEP'
                        --}
                        ) is

--
-- prof_amt_rec      hz_customer_accounts_pub.cust_prof_amt_rec_type;
   prof_amt_rec                 hz_customer_profile_v2pub.cust_profile_amt_rec_type;
   x_cust_acct_profile_amt_id   NUMBER;
   old_customer_profile_id	NUMBER;			--Bug Fix#1: 3107081
   tmp_var                      VARCHAR2(2000);
   i                            NUMBER;
   tmp_var1                     VARCHAR2(2000);
   CURSOR c_prof_class IS
		SELECT  collector_id,
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
                        lockbox_matching_option,
                        lockbox_matching_option_name,
                        autocash_hierarchy_id_for_adr,
                        autocash_hierarchy_name_adr
                  FROM AR_CUSTOMER_PROFILE_CLASSES_V
		-- from	AR_CUST_PROF_CLASSES_TEST_V
                 WHERE customer_profile_class_id = x_customer_profile_class_id;


   CURSOR c_prof_class_amts IS
       SELECT
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
                jgzz_attribute15
        FROM    hz_cust_prof_class_amts
        WHERE   profile_class_id = x_customer_profile_class_id;

--

   CURSOR c_get_profile_amt_id(l_profile_class_id NUMBER, l_currency_code VARCHAR2) IS
        SELECT profile_class_amount_id
          FROM hz_cust_prof_class_amts
         WHERE profile_class_id = l_profile_class_id
           AND currency_code = l_currency_code;

   l_profile_class_amount_id NUMBER;
   l_msg_count               NUMBER;
   l_msg_data                VARCHAR2(1000);


   --{bug#4084126
   CURSOR c_prof_class_id(p_customer_profile_id  IN NUMBER)
   IS
    SELECT profile_class_id
      FROM hz_customer_profiles
     WHERE cust_account_profile_id = p_customer_profile_id;

   l_curr_profile_class_id   NUMBER;
   --}



  BEGIN
	--
	--
	OPEN c_prof_class;
	FETCH c_prof_class
              INTO      x_collector_id,
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
                        x_lockbox_matching_option,
                        x_lockbox_matching_name,
                        x_autocash_hierarchy_id_adr,
                        x_autocash_hierarchy_name_adr;

	   --
	   IF (c_prof_class%NOTFOUND) THEN
		CLOSE c_prof_class;
		RAISE NO_DATA_FOUND;
	   END IF;
           --
	CLOSE c_prof_class;
	--
	-- If the customer_profile_id/customers_id is null we need to
        -- generate one so we
	-- can insert rows into hz_cust_profile_amts.
	-- Customer_id wil be null when inserting a profile .
	-- and not null if they are updating an existing profile.
	--
	--
	IF ( x_customer_id IS NULL ) THEN
		SELECT hz_cust_accounts_s.NEXTVAL INTO x_customer_id FROM DUAL;
	END IF;
	--
	--
	IF (x_customer_profile_id is null ) THEN
		SELECT hz_customer_profiles_s.NEXTVAL INTO  x_customer_profile_id FROM DUAL;
	END IF;
	--
	--
	--
	--
	--  Delete only the profile_amounts that match the currency that is
        --  present in the profile_amounts of the new customer profile class.
	--
        -- Bug 2046191: revised to delete all prior currency amounts to
        --              accurately reflect the current profile class currencies
        --              and their respective amounts.
        --
        --{BUG#3046535
/**********  Bug Fix Begin#2 : 3107081 ***********************/
/****   Get the Site Level Customer Profile Id if a profile already exists ****/

	BEGIN
	IF x_site_use_id IS NOT NULL THEN
		SELECT DISTINCT cust_account_profile_id
		INTO   old_customer_profile_id
		FROM   HZ_CUST_PROFILE_AMTS
		WHERE  cust_account_id = x_customer_id
		AND    site_use_id = x_site_use_id;
	END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    NULL;
	END;


/****    In the WHERE Clause of the DELETE Statements present in the IF and ELSE parts,
        * Use old_customer_profile_id for Site Level Profile
        * Use x_customer_profile_id   for Account Level Profile     ****/

		IF p_keep_replace = 'REPLACE' THEN
	           DELETE  FROM hz_cust_profile_amts
		   WHERE   cust_account_profile_id =
			   NVL(old_customer_profile_id,x_customer_profile_id);
	        ELSE
		   DELETE  FROM hz_cust_profile_amts
	            WHERE  cust_account_profile_id =
			   NVL(old_customer_profile_id,x_customer_profile_id)
		      AND  currency_code in ( select  currency_code
			                         from  hz_cust_prof_class_amts
				                where  profile_class_id =  x_customer_profile_class_id
					        );
	        END IF;


    --{bug#4084126
    IF x_customer_profile_id IS NOT NULL AND x_customer_profile_class_id IS NOT NULL THEN
      OPEN c_prof_class_id(x_customer_profile_id);
      FETCH c_prof_class_id INTO l_curr_profile_class_id;
      IF c_prof_class_id%FOUND THEN
         IF    l_curr_profile_class_id <>  x_customer_profile_class_id THEN
           UPDATE hz_customer_profiles
              SET profile_class_id = x_customer_profile_class_id
            WHERE cust_account_profile_id = x_customer_profile_id;
          END IF;
      END IF;
    END IF;
    --}




/**********  Bug Fix End#2 : 3107081 *************************/

/**********  Commented out the following piece of code  *******/
/**********  Bug Fix Begin#3 : 3107081 *************************
		IF p_keep_replace = 'REPLACE' THEN
	           DELETE  FROM hz_cust_profile_amts
		   WHERE   cust_account_profile_id = x_customer_profile_id;

	        ELSE
		   DELETE  FROM hz_cust_profile_amts
	            WHERE  cust_account_profile_id = x_customer_profile_id
		      AND  currency_code in ( select  currency_code
			                        from  hz_cust_prof_class_amts
				               where  profile_class_id =  x_customer_profile_class_id
					        );
	        END IF;
**********  Bug Fix End#3 : 3107081 *************************/
        --}
	--
	-- copy profile amount records from class to customer profile
	--
        OPEN c_prof_class_amts;
        LOOP
        FETCH c_prof_class_amts INTO
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
                 prof_amt_rec.jgzz_attribute15;
                 EXIT WHEN c_prof_class_amts%NOTFOUND;

                 prof_amt_rec.created_by_module := 'TCA_FORM_WRAPPER';
                 HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
                  p_check_foreign_key                 => FND_API.G_FALSE,
                  p_cust_profile_amt_rec              => prof_amt_rec,
                  x_cust_acct_profile_amt_id          => x_cust_acct_profile_amt_id,
                  x_return_status                     => x_return_status,
                  x_msg_count                         => x_msg_count,
                  x_msg_data                          => x_msg_data
                 );

-- added as per bug 2219199 CASCADE PROFILE CLASS AMOUNTS WITH THE CREDIT USAGES - MULTI CURRENCY SETUP
                if (x_return_status = 'S') then
                     open c_get_profile_amt_id(x_customer_profile_class_id, prof_amt_rec.currency_code);
                     fetch c_get_profile_amt_id into l_profile_class_amount_id;
                     close c_get_profile_amt_id;
                     if (l_profile_class_amount_id is not null) then
                          HZ_CREDIT_USAGES_CASCADE_PKG.cascade_credit_usage_rules (
                              x_cust_acct_profile_amt_id,
                              prof_amt_rec.cust_account_profile_id,
                              l_profile_class_amount_id,
                              x_customer_profile_class_id,
                              x_return_status,
                              l_msg_count,
                              l_msg_data );
                     end if;
                end if;


      END LOOP;

      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      CLOSE c_prof_class_amts;
      --
      --
   END create_profile_from_class;
   --
   --
   --

   -- Bug 2310474 Overload method
  PROCEDURE create_profile_from_class
		( 	x_customer_profile_class_id	in number,
			x_customer_profile_id		in out NOCOPY number,
			x_customer_id			in out NOCOPY number,
			x_site_use_id			in number,
			x_collector_id 			out NOCOPY number,
 			x_collector_name 		out NOCOPY varchar2,
 			x_credit_checking		out NOCOPY varchar2,
 			x_tolerance			out NOCOPY number,
 			x_interest_charges		out NOCOPY varchar2,
 			x_charge_on_fin_charge_flag	out NOCOPY varchar2,
 			x_interest_period_days		out NOCOPY number,
 			x_discount_terms 		out NOCOPY varchar2,
 			x_discount_grace_days		out NOCOPY number,
 			x_statements			out NOCOPY varchar2,
 			x_statement_cycle_id		out NOCOPY number,
 			x_statement_cycle_name		out NOCOPY varchar2,
 			x_credit_balance_statements	out NOCOPY varchar2,
 			x_standard_terms 		out NOCOPY number,
 			x_standard_terms_name		out NOCOPY varchar2,
 			x_override_terms 		out NOCOPY varchar2,
 			x_payment_grace_days		out NOCOPY number,
 			x_dunning_letters		out NOCOPY varchar2,
 			x_dunning_letter_set_id		out NOCOPY number,
 			x_dunning_letter_set_name	out NOCOPY varchar2,
 			x_autocash_hierarchy_id		out NOCOPY number,
 			x_autocash_hierarchy_name	out NOCOPY varchar2,
 			x_auto_rec_incl_disputed_flag	out NOCOPY varchar2,
 			x_tax_printing_option		out NOCOPY varchar2,
 			x_grouping_rule_id		out NOCOPY number,
 			x_grouping_rule_name		out NOCOPY varchar2,
                        x_cons_inv_flag                 out NOCOPY varchar2,
                        x_cons_inv_type                 out NOCOPY varchar2,
 			x_attribute_category		out NOCOPY varchar2,
 			x_attribute1			out NOCOPY varchar2,
 			x_attribute2			out NOCOPY varchar2,
 			x_attribute3			out NOCOPY varchar2,
 			x_attribute4			out NOCOPY varchar2,
 			x_attribute5			out NOCOPY varchar2,
 			x_attribute6			out NOCOPY varchar2,
 			x_attribute7			out NOCOPY varchar2,
 			x_attribute8			out NOCOPY varchar2,
 			x_attribute9			out NOCOPY varchar2,
 			x_attribute10			out NOCOPY varchar2,
 			x_attribute11			out NOCOPY varchar2,
 			x_attribute12			out NOCOPY varchar2,
 			x_attribute13			out NOCOPY varchar2,
 			x_attribute14			out NOCOPY varchar2,
 			x_attribute15			out NOCOPY varchar2,
 			x_jgzz_attribute_category	out NOCOPY varchar2,
 			x_jgzz_attribute1		out NOCOPY varchar2,
 			x_jgzz_attribute2		out NOCOPY varchar2,
 			x_jgzz_attribute3		out NOCOPY varchar2,
 			x_jgzz_attribute4		out NOCOPY varchar2,
 			x_jgzz_attribute5		out NOCOPY varchar2,
 			x_jgzz_attribute6		out NOCOPY varchar2,
 			x_jgzz_attribute7		out NOCOPY varchar2,
 			x_jgzz_attribute8		out NOCOPY varchar2,
 			x_jgzz_attribute9		out NOCOPY varchar2,
 			x_jgzz_attribute10		out NOCOPY varchar2,
 			x_jgzz_attribute11		out NOCOPY varchar2,
 			x_jgzz_attribute12		out NOCOPY varchar2,
 			x_jgzz_attribute13		out NOCOPY varchar2,
 			x_jgzz_attribute14		out NOCOPY varchar2,
 			x_jgzz_attribute15		out NOCOPY varchar2,
                        x_lockbox_matching_option       out NOCOPY varchar2,
                        x_lockbox_matching_name         out NOCOPY varchar2,
                        x_autocash_hierarchy_id_adr     out NOCOPY number,
                        x_autocash_hierarchy_name_adr   out NOCOPY varchar2,
--{2310474
                        x_review_cycle                  out NOCOPY varchar2,
                        x_credit_classification         out NOCOPY varchar2,
                        x_credit_classification_m       out NOCOPY varchar2,
                        x_review_cycle_name             out NOCOPY varchar2,
                        x_credit_analyst_id             out NOCOPY number,
                        x_credit_analyst_name           out NOCOPY varchar2,
--}
                        x_return_status                 out NOCOPY varchar2,
                        x_msg_count                     out NOCOPY number,
                        x_msg_data                      out NOCOPY varchar2,
--{Bug#3046535
                        p_keep_replace                  IN  VARCHAR2 DEFAULT 'KEEP'
--}
			)
   IS
     prof_amt_rec                 hz_customer_profile_v2pub.cust_profile_amt_rec_type;
     x_cust_acct_profile_amt_id   NUMBER;
     old_customer_profile_id	  NUMBER;			--Bug Fix#4: 3107081
     tmp_var                      VARCHAR2(2000);
     i                            NUMBER;
     tmp_var1                     VARCHAR2(2000);

     CURSOR c_prof_class IS
		SELECT  collector_id,
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
                        lockbox_matching_option,
                        lockbox_matching_option_name,
                        autocash_hierarchy_id_for_adr,
                        autocash_hierarchy_name_adr,
--{2310474
                        review_cycle,
                        credit_classification,
                        credit_classification_meaning,
                        review_cycle_name,
                        credit_analyst_id,
                        credit_analyst_name
--}
                  FROM AR_CUSTOMER_PROFILE_CLASSES_V
                 WHERE customer_profile_class_id = x_customer_profile_class_id;


     CURSOR c_prof_class_amts IS
         SELECT
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
                jgzz_attribute15
        FROM    hz_cust_prof_class_amts
        WHERE   profile_class_id = x_customer_profile_class_id;

     CURSOR c_get_profile_amt_id(l_profile_class_id NUMBER, l_currency_code VARCHAR2) IS
        SELECT profile_class_amount_id
          FROM hz_cust_prof_class_amts
         WHERE profile_class_id = l_profile_class_id
           AND currency_code = l_currency_code;
    l_profile_class_amount_id NUMBER;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(1000);

   --{bug#4084126
   CURSOR c_prof_class_id(p_customer_profile_id  IN NUMBER)
   IS
    SELECT profile_class_id
      FROM hz_customer_profiles
     WHERE cust_account_profile_id = p_customer_profile_id;

   l_curr_profile_class_id   NUMBER;
   --}




   BEGIN
	OPEN c_prof_class;
	FETCH c_prof_class
              INTO      x_collector_id,
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
                        x_lockbox_matching_option,
                        x_lockbox_matching_name,
                        x_autocash_hierarchy_id_adr,
                        x_autocash_hierarchy_name_adr,
--{2310474
                        x_review_cycle,
                        x_credit_classification,
                        x_credit_classification_m,
                        x_review_cycle_name,
                        x_credit_analyst_id,
                        x_credit_analyst_name;
--}

	   --
	   IF (c_prof_class%NOTFOUND) THEN
		CLOSE c_prof_class;
		RAISE NO_DATA_FOUND;
	   END IF;
           --
	CLOSE c_prof_class;
	--
	-- If the customer_profile_id/customers_id is null we need to
        -- generate one so we
	-- can insert rows into hz_cust_profile_amts.
	-- Customer_id wil be null when inserting a profile .
	-- and not null if they are updating an existing profile.
	--
	--
	IF ( x_customer_id IS NULL ) THEN
		SELECT hz_cust_accounts_s.NEXTVAL INTO x_customer_id FROM DUAL;
	END IF;
	--
	--
	IF (x_customer_profile_id is null ) THEN
		SELECT hz_customer_profiles_s.NEXTVAL INTO  x_customer_profile_id FROM DUAL;
	END IF;
	--
	--
	--
	--
	--  Delete only the profile_amounts that match the currency that is
        --  present in the profile_amounts of the new customer profile class.
	--
        -- Bug 2046191: revised to delete all prior currency amounts to
        --              accurately reflect the current profile class currencies
        --              and their respective amounts.
        --

        --{BUG#3046535

/**********  Bug Fix Begin#5 : 3107081 *************************/
/****   Get the Site Level Customer Profile Id if a profile already exists ****/

	BEGIN
	IF x_site_use_id IS NOT NULL THEN
		SELECT DISTINCT cust_account_profile_id
		INTO   old_customer_profile_id
		FROM   HZ_CUST_PROFILE_AMTS
		WHERE  cust_account_id = x_customer_id
		AND    site_use_id = x_site_use_id;
	END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    NULL;
	END;

/****    In the WHERE Clause of the DELETE Statements present in the IF and ELSE parts,
        * Use old_customer_profile_id for Site Level Profile
        * Use x_customer_profile_id   for Account Level Profile     ****/

		IF p_keep_replace = 'REPLACE' THEN
	           DELETE  FROM hz_cust_profile_amts
		   WHERE   cust_account_profile_id =
			   NVL(old_customer_profile_id,x_customer_profile_id);
	        ELSE
		   DELETE  FROM hz_cust_profile_amts
	            WHERE  cust_account_profile_id =
			   NVL(old_customer_profile_id,x_customer_profile_id)
		      AND  currency_code in ( select  currency_code
			                         from  hz_cust_prof_class_amts
				                where  profile_class_id =  x_customer_profile_class_id
					        );
	        END IF;

    --{bug#4084126
    IF x_customer_profile_id IS NOT NULL AND x_customer_profile_class_id IS NOT NULL THEN
      OPEN c_prof_class_id(x_customer_profile_id);
      FETCH c_prof_class_id INTO l_curr_profile_class_id;
      IF c_prof_class_id%FOUND THEN
         IF    l_curr_profile_class_id <>  x_customer_profile_class_id THEN
           UPDATE hz_customer_profiles
              SET profile_class_id = x_customer_profile_class_id
            WHERE cust_account_profile_id = x_customer_profile_id;
          END IF;
      END IF;
    END IF;
    --}



/**********  Bug Fix End#5 : 3107081 *************************/

/**********  Commented out the following piece of code  *******/
/**********  Bug Fix Begin#6 : 3107081 *************************
		IF p_keep_replace = 'REPLACE' THEN
	           DELETE  FROM hz_cust_profile_amts
		   WHERE   cust_account_profile_id = x_customer_profile_id;

	        ELSE
		   DELETE  FROM hz_cust_profile_amts
	            WHERE  cust_account_profile_id = x_customer_profile_id
		      AND  currency_code in ( select  currency_code
			                        from  hz_cust_prof_class_amts
			                       where  profile_class_id =  x_customer_profile_class_id
					        );
	        END IF;
**********  Bug Fix End#6 : 3107081 *************************/
        --}

	--
	-- copy profile amount records from class to customer profile
	--
        OPEN c_prof_class_amts;
        LOOP
        FETCH c_prof_class_amts INTO
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
                 prof_amt_rec.jgzz_attribute15;
                 EXIT WHEN c_prof_class_amts%NOTFOUND;

                 prof_amt_rec.created_by_module := 'TCA_FORM_WRAPPER';
                 HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
                  p_check_foreign_key                 => FND_API.G_FALSE,
                  p_cust_profile_amt_rec              => prof_amt_rec,
                  x_cust_acct_profile_amt_id          => x_cust_acct_profile_amt_id,
                  x_return_status                     => x_return_status,
                  x_msg_count                         => x_msg_count,
                  x_msg_data                          => x_msg_data
                 );

-- added as per bug 2219199 CASCADE PROFILE CLASS AMOUNTS WITH THE CREDIT USAGES - MULTI CURRENCY SETUP
                if (x_return_status = 'S') then
                     open c_get_profile_amt_id(x_customer_profile_class_id, prof_amt_rec.currency_code);
                     fetch c_get_profile_amt_id into l_profile_class_amount_id;
                     close c_get_profile_amt_id;
                     if (l_profile_class_amount_id is not null) then
                          HZ_CREDIT_USAGES_CASCADE_PKG.cascade_credit_usage_rules (
                              x_cust_acct_profile_amt_id,
                              prof_amt_rec.cust_account_profile_id,
                              l_profile_class_amount_id,
                              x_customer_profile_class_id,
                              x_return_status,
                              l_msg_count,
                              l_msg_data );
                     end if;
                end if;


      END LOOP;





      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      CLOSE c_prof_class_amts;
      --
      --
   END create_profile_from_class;

/*---------------------------------------------------------------+
 | PROCEDURE :  CREATE_PROFILE_AMOUNT                            |
 |                                                               |
 | PARAMETERS :                                                  |
 |   Arguments in the record type                                |
 |   Hz_Customer_Profile_V2pub.Cust_Profile_Amt_Rec_Type         |
 |                                                               |
 | DESCRIPTION :                                                 |
 |  From the arguments entered contruct the recors type and call |
 |  Hz_Customer_Profile_V2pub.create_cust_profile_amt            |
 |                                                               |
 | HISTORY :                                                     |
 |  12-DEC-2002   H. Yu   Created                                |
 +---------------------------------------------------------------*/
 PROCEDURE create_profile_amount
  ( p_cust_account_profile_id         IN    NUMBER,
    p_currency_code                   IN    VARCHAR2,
    p_trx_credit_limit                IN    NUMBER,
    p_overall_credit_limit            IN    NUMBER,
    p_min_dunning_amount              IN    NUMBER,
    p_min_dunning_invoice_amount      IN    NUMBER,
    p_max_interest_charge             IN    NUMBER,
    p_min_statement_amount            IN    NUMBER,
    p_auto_rec_min_receipt_amount     IN    NUMBER,
    p_interest_rate                   IN    NUMBER,
    p_attribute_category              IN    VARCHAR2 DEFAULT NULL,
    p_attribute1                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute2                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute3                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute4                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute5                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute6                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute7                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute8                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute9                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute10                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute11                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute12                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute13                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute14                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute15                     IN    VARCHAR2 DEFAULT NULL,
    p_min_fc_balance_amount           IN    NUMBER,
    p_min_fc_invoice_amount           IN    NUMBER,
    p_cust_account_id                 IN    NUMBER,
    p_site_use_id                     IN    NUMBER,
    p_expiration_date                 IN    DATE,
    p_jgzz_attribute_category         IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute1                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute2                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute3                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute4                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute5                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute6                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute7                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute8                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute9                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute10                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute11                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute12                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute13                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute14                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute15                IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute1               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute2               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute3               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute4               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute5               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute6               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute7               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute8               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute9               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute10              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute11              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute12              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute13              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute14              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute15              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute16              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute17              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute18              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute19              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute20              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute_category       IN    VARCHAR2 DEFAULT NULL,
    p_created_by_module               IN    VARCHAR2 DEFAULT 'TCA_FORM_WRAPPER',
    p_application_id                  IN    NUMBER   DEFAULT NULL,
    x_cust_acct_profile_amt_id        OUT   NOCOPY NUMBER,
    x_return_status                   OUT   NOCOPY VARCHAR2,
    x_msg_count                       OUT   NOCOPY NUMBER,
    x_msg_data                        OUT   NOCOPY VARCHAR2 )
  IS
    l_rec                        Hz_Customer_Profile_V2pub.Cust_Profile_Amt_Rec_Type;
    l_cust_acct_profile_amt_id   NUMBER;
    tmp_var                      VARCHAR2(2000);
    i                            NUMBER;
    tmp_var1                     VARCHAR2(2000);
  BEGIN
    arp_standard.debug('create_profile_amount (+)');
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    l_rec.cust_acct_profile_amt_id     :=  x_cust_acct_profile_amt_id;
    l_rec.cust_account_profile_id      :=  p_cust_account_profile_id;
    l_rec.currency_code                :=  p_currency_code;
    l_rec.trx_credit_limit             :=  p_trx_credit_limit;
    l_rec.overall_credit_limit         :=  p_overall_credit_limit;
    l_rec.min_dunning_amount           :=  p_min_dunning_amount;
    l_rec.min_dunning_invoice_amount   :=  p_min_dunning_invoice_amount;
    l_rec.max_interest_charge          :=  p_max_interest_charge;
    l_rec.min_statement_amount         :=  p_min_statement_amount;
    l_rec.auto_rec_min_receipt_amount  :=  p_auto_rec_min_receipt_amount;
    l_rec.interest_rate                :=  p_interest_rate;
    l_rec.attribute_category           :=  p_attribute_category;
    l_rec.attribute1                   :=  p_attribute1;
    l_rec.attribute2                   :=  p_attribute2;
    l_rec.attribute3                   :=  p_attribute3;
    l_rec.attribute4                   :=  p_attribute4;
    l_rec.attribute5                   :=  p_attribute5;
    l_rec.attribute6                   :=  p_attribute6;
    l_rec.attribute7                   :=  p_attribute7;
    l_rec.attribute8                   :=  p_attribute8;
    l_rec.attribute9                   :=  p_attribute9;
    l_rec.attribute10                  :=  p_attribute10;
    l_rec.attribute11                  :=  p_attribute11;
    l_rec.attribute12                  :=  p_attribute12;
    l_rec.attribute13                  :=  p_attribute13;
    l_rec.attribute14                  :=  p_attribute14;
    l_rec.attribute15                  :=  p_attribute15;
    l_rec.min_fc_balance_amount        :=  p_min_fc_balance_amount;
    l_rec.min_fc_invoice_amount        :=  p_min_fc_invoice_amount;
    l_rec.cust_account_id              :=  p_cust_account_id;
    l_rec.site_use_id                  :=  p_site_use_id;
    l_rec.expiration_date              :=  p_expiration_date;
    l_rec.jgzz_attribute_category      :=  p_jgzz_attribute_category;
    l_rec.jgzz_attribute1              :=  p_jgzz_attribute1;
    l_rec.jgzz_attribute2              :=  p_jgzz_attribute2;
    l_rec.jgzz_attribute3              :=  p_jgzz_attribute3;
    l_rec.jgzz_attribute4              :=  p_jgzz_attribute4;
    l_rec.jgzz_attribute5              :=  p_jgzz_attribute5;
    l_rec.jgzz_attribute6              :=  p_jgzz_attribute6;
    l_rec.jgzz_attribute7              :=  p_jgzz_attribute7;
    l_rec.jgzz_attribute8              :=  p_jgzz_attribute8;
    l_rec.jgzz_attribute9              :=  p_jgzz_attribute9;
    l_rec.jgzz_attribute10             :=  p_jgzz_attribute10;
    l_rec.jgzz_attribute11             :=  p_jgzz_attribute11;
    l_rec.jgzz_attribute12             :=  p_jgzz_attribute12;
    l_rec.jgzz_attribute13             :=  p_jgzz_attribute13;
    l_rec.jgzz_attribute14             :=  p_jgzz_attribute14;
    l_rec.jgzz_attribute15             :=  p_jgzz_attribute15;
    l_rec.global_attribute1            :=  p_global_attribute1;
    l_rec.global_attribute2            :=  p_global_attribute2;
    l_rec.global_attribute3            :=  p_global_attribute3;
    l_rec.global_attribute4            :=  p_global_attribute4;
    l_rec.global_attribute5            :=  p_global_attribute5;
    l_rec.global_attribute6            :=  p_global_attribute6;
    l_rec.global_attribute7            :=  p_global_attribute7;
    l_rec.global_attribute8            :=  p_global_attribute8;
    l_rec.global_attribute9            :=  p_global_attribute9;
    l_rec.global_attribute10           :=  p_global_attribute10;
    l_rec.global_attribute11           :=  p_global_attribute11;
    l_rec.global_attribute12           :=  p_global_attribute12;
    l_rec.global_attribute13           :=  p_global_attribute13;
    l_rec.global_attribute14           :=  p_global_attribute14;
    l_rec.global_attribute15           :=  p_global_attribute15;
    l_rec.global_attribute16           :=  p_global_attribute16;
    l_rec.global_attribute17           :=  p_global_attribute17;
    l_rec.global_attribute18           :=  p_global_attribute18;
    l_rec.global_attribute19           :=  p_global_attribute19;
    l_rec.global_attribute20           :=  p_global_attribute20;
    l_rec.global_attribute_category    :=  p_global_attribute_category;
    l_rec.created_by_module            :=  p_created_by_module;
    l_rec.application_id               :=  p_application_id;

    HZ_CUSTOMER_PROFILE_V2PUB.create_cust_profile_amt (
       p_cust_profile_amt_rec        => l_rec,
       x_cust_acct_profile_amt_id    => x_cust_acct_profile_amt_id,
       x_return_status               => x_return_status,
       x_msg_count                   => x_msg_count,
       x_msg_data                    => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug(x_msg_data);
    END IF;

    arp_standard.debug('create_profile_amount(-)');
  EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     arp_standard.debug('EXCEPTION: hzp_cprof_pkg.delete_profile_amout'||x_msg_data);
  END;

/*---------------------------------------------------------------+
 | PROCEDURE :  UPDATE_PROFILE_AMOUNT                            |
 |                                                               |
 | PARAMETERS :                                                  |
 |   Arguments in the record type                                |
 |   Hz_Customer_Profile_V2pub.Cust_Profile_Amt_Rec_Type         |
 |                                                               |
 | DESCRIPTION :                                                 |
 |  From the arguments entered contruct the recors type and call |
 |  Hz_Customer_Profile_V2pub.update_cust_profile_amt            |
 |                                                               |
 | HISTORY :                                                     |
 |  12-DEC-2002   H. Yu   Created                                |
 +---------------------------------------------------------------*/
 PROCEDURE update_profile_amount
  ( p_cust_acct_profile_amt_id        IN    NUMBER,
    p_cust_account_profile_id         IN    NUMBER,
    p_currency_code                   IN    VARCHAR2,
    p_trx_credit_limit                IN    NUMBER,
    p_overall_credit_limit            IN    NUMBER,
    p_min_dunning_amount              IN    NUMBER,
    p_min_dunning_invoice_amount      IN    NUMBER,
    p_max_interest_charge             IN    NUMBER,
    p_min_statement_amount            IN    NUMBER,
    p_auto_rec_min_receipt_amount     IN    NUMBER,
    p_interest_rate                   IN    NUMBER,
    p_attribute_category              IN    VARCHAR2 DEFAULT NULL,
    p_attribute1                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute2                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute3                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute4                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute5                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute6                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute7                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute8                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute9                      IN    VARCHAR2 DEFAULT NULL,
    p_attribute10                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute11                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute12                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute13                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute14                     IN    VARCHAR2 DEFAULT NULL,
    p_attribute15                     IN    VARCHAR2 DEFAULT NULL,
    p_min_fc_balance_amount           IN    NUMBER,
    p_min_fc_invoice_amount           IN    NUMBER,
    p_cust_account_id                 IN    NUMBER,
    p_site_use_id                     IN    NUMBER,
    p_expiration_date                 IN    DATE,
    p_jgzz_attribute_category         IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute1                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute2                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute3                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute4                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute5                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute6                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute7                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute8                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute9                 IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute10                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute11                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute12                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute13                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute14                IN    VARCHAR2 DEFAULT NULL,
    p_jgzz_attribute15                IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute1               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute2               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute3               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute4               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute5               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute6               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute7               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute8               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute9               IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute10              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute11              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute12              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute13              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute14              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute15              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute16              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute17              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute18              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute19              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute20              IN    VARCHAR2 DEFAULT NULL,
    p_global_attribute_category       IN    VARCHAR2 DEFAULT NULL,
    x_return_status                   OUT   NOCOPY VARCHAR2,
    x_msg_count                       OUT   NOCOPY NUMBER,
    x_msg_data                        OUT   NOCOPY VARCHAR2,
    p_object_version                  IN    NUMBER DEFAULT -1,
    X_Last_Update_Date                IN    DATE)
  IS
    CURSOR cu_version_prof_amt IS
    SELECT ROWID,
           OBJECT_VERSION_NUMBER,
           LAST_UPDATE_DATE
      FROM hz_cust_profile_amts
     WHERE cust_acct_profile_amt_id  = p_cust_acct_profile_amt_id;

    l_rec                        Hz_Customer_Profile_V2pub.Cust_Profile_Amt_Rec_Type;
    l_cust_acct_profile_amt_id   NUMBER;
    tmp_var                      VARCHAR2(2000);
    i                            NUMBER;
    tmp_var1                     VARCHAR2(2000);
    l_object_version             NUMBER;
    l_rowid                      ROWID;
    l_last_update_date           DATE;
    l_exception                  EXCEPTION;
    tca_exception                EXCEPTION;
  BEGIN
    arp_standard.debug('update_profile_amount (+)');
    arp_standard.debug('Object_version_number:'||p_object_version);
    arp_standard.debug('last_update_date:'||X_Last_Update_Date );

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_rec.cust_acct_profile_amt_id     :=  INIT_SWITCH(p_cust_acct_profile_amt_id);
    l_rec.cust_account_profile_id      :=  INIT_SWITCH(p_cust_account_profile_id);
    l_rec.currency_code                :=  INIT_SWITCH(p_currency_code);
    l_rec.trx_credit_limit             :=  INIT_SWITCH(p_trx_credit_limit);
    l_rec.overall_credit_limit         :=  INIT_SWITCH(p_overall_credit_limit);
    l_rec.min_dunning_amount           :=  INIT_SWITCH(p_min_dunning_amount);
    l_rec.min_dunning_invoice_amount   :=  INIT_SWITCH(p_min_dunning_invoice_amount);
    l_rec.max_interest_charge          :=  INIT_SWITCH(p_max_interest_charge);
    l_rec.min_statement_amount         :=  INIT_SWITCH(p_min_statement_amount);
    l_rec.auto_rec_min_receipt_amount  :=  INIT_SWITCH(p_auto_rec_min_receipt_amount);
    l_rec.interest_rate                :=  INIT_SWITCH(p_interest_rate);
    l_rec.attribute_category           :=  INIT_SWITCH(p_attribute_category);
    l_rec.attribute1                   :=  INIT_SWITCH(p_attribute1);
    l_rec.attribute2                   :=  INIT_SWITCH(p_attribute2);
    l_rec.attribute3                   :=  INIT_SWITCH(p_attribute3);
    l_rec.attribute4                   :=  INIT_SWITCH(p_attribute4);
    l_rec.attribute5                   :=  INIT_SWITCH(p_attribute5);
    l_rec.attribute6                   :=  INIT_SWITCH(p_attribute6);
    l_rec.attribute7                   :=  INIT_SWITCH(p_attribute7);
    l_rec.attribute8                   :=  INIT_SWITCH(p_attribute8);
    l_rec.attribute9                   :=  INIT_SWITCH(p_attribute9);
    l_rec.attribute10                  :=  INIT_SWITCH(p_attribute10);
    l_rec.attribute11                  :=  INIT_SWITCH(p_attribute11);
    l_rec.attribute12                  :=  INIT_SWITCH(p_attribute12);
    l_rec.attribute13                  :=  INIT_SWITCH(p_attribute13);
    l_rec.attribute14                  :=  INIT_SWITCH(p_attribute14);
    l_rec.attribute15                  :=  INIT_SWITCH(p_attribute15);
    l_rec.min_fc_balance_amount        :=  INIT_SWITCH(p_min_fc_balance_amount);
    l_rec.min_fc_invoice_amount        :=  INIT_SWITCH(p_min_fc_invoice_amount);
    l_rec.cust_account_id              :=  INIT_SWITCH(p_cust_account_id);
    l_rec.site_use_id                  :=  INIT_SWITCH(p_site_use_id);
    l_rec.expiration_date              :=  INIT_SWITCH(p_expiration_date);
    l_rec.jgzz_attribute_category      :=  INIT_SWITCH(p_jgzz_attribute_category);
    l_rec.jgzz_attribute1              :=  INIT_SWITCH(p_jgzz_attribute1);
    l_rec.jgzz_attribute2              :=  INIT_SWITCH(p_jgzz_attribute2);
    l_rec.jgzz_attribute3              :=  INIT_SWITCH(p_jgzz_attribute3);
    l_rec.jgzz_attribute4              :=  INIT_SWITCH(p_jgzz_attribute4);
    l_rec.jgzz_attribute5              :=  INIT_SWITCH(p_jgzz_attribute5);
    l_rec.jgzz_attribute6              :=  INIT_SWITCH(p_jgzz_attribute6);
    l_rec.jgzz_attribute7              :=  INIT_SWITCH(p_jgzz_attribute7);
    l_rec.jgzz_attribute8              :=  INIT_SWITCH(p_jgzz_attribute8);
    l_rec.jgzz_attribute9              :=  INIT_SWITCH(p_jgzz_attribute9);
    l_rec.jgzz_attribute10             :=  INIT_SWITCH(p_jgzz_attribute10);
    l_rec.jgzz_attribute11             :=  INIT_SWITCH(p_jgzz_attribute11);
    l_rec.jgzz_attribute12             :=  INIT_SWITCH(p_jgzz_attribute12);
    l_rec.jgzz_attribute13             :=  INIT_SWITCH(p_jgzz_attribute13);
    l_rec.jgzz_attribute14             :=  INIT_SWITCH(p_jgzz_attribute14);
    l_rec.jgzz_attribute15             :=  INIT_SWITCH(p_jgzz_attribute15);
    l_rec.global_attribute1            :=  INIT_SWITCH(p_global_attribute1);
    l_rec.global_attribute2            :=  INIT_SWITCH(p_global_attribute2);
    l_rec.global_attribute3            :=  INIT_SWITCH(p_global_attribute3);
    l_rec.global_attribute4            :=  INIT_SWITCH(p_global_attribute4);
    l_rec.global_attribute5            :=  INIT_SWITCH(p_global_attribute5);
    l_rec.global_attribute6            :=  INIT_SWITCH(p_global_attribute6);
    l_rec.global_attribute7            :=  INIT_SWITCH(p_global_attribute7);
    l_rec.global_attribute8            :=  INIT_SWITCH(p_global_attribute8);
    l_rec.global_attribute9            :=  INIT_SWITCH(p_global_attribute9);
    l_rec.global_attribute10           :=  INIT_SWITCH(p_global_attribute10);
    l_rec.global_attribute11           :=  INIT_SWITCH(p_global_attribute11);
    l_rec.global_attribute12           :=  INIT_SWITCH(p_global_attribute12);
    l_rec.global_attribute13           :=  INIT_SWITCH(p_global_attribute13);
    l_rec.global_attribute14           :=  INIT_SWITCH(p_global_attribute14);
    l_rec.global_attribute15           :=  INIT_SWITCH(p_global_attribute15);
    l_rec.global_attribute16           :=  INIT_SWITCH(p_global_attribute16);
    l_rec.global_attribute17           :=  INIT_SWITCH(p_global_attribute17);
    l_rec.global_attribute18           :=  INIT_SWITCH(p_global_attribute18);
    l_rec.global_attribute19           :=  INIT_SWITCH(p_global_attribute19);
    l_rec.global_attribute20           :=  INIT_SWITCH(p_global_attribute20);
    l_rec.global_attribute_category    :=  INIT_SWITCH(p_global_attribute_category);

    l_object_version := p_object_version;

    IF (l_object_version   = -1 OR l_object_version IS NULL) THEN

        OPEN cu_version_prof_amt;
        FETCH  cu_version_prof_amt INTO l_rowid,
                                      l_object_version,
                                      l_last_update_date;
        arp_standard.debug('Last_update_date:'||to_char(l_last_update_date));

        IF cu_version_prof_amt%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD','HZ_CUST_PROFILE_AMTS');
          FND_MESSAGE.SET_TOKEN('ID',p_cust_acct_profile_amt_id);
          FND_MSG_PUB.ADD;
          RAISE l_exception;
        END IF;

        CLOSE cu_version_prof_amt;

   END IF;

   arp_standard.debug('x_return_status :'||x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

        HZ_CUSTOMER_PROFILE_V2PUB.update_cust_profile_amt
        ( p_cust_profile_amt_rec   => l_rec,
          p_object_version_number  => l_object_version,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE tca_exception;
    END IF;

    arp_standard.debug('update_profile_amount (-)');
  EXCEPTION
    WHEN l_exception THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(
          p_encoded => fnd_api.g_false,
          p_count => x_msg_count,
          p_data  => x_msg_data);
       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug('Exception hzp_cprof_pkg.update_profile_amount:'||x_msg_data);

    WHEN tca_Exception THEN
      IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       arp_standard.debug('Exception hzp_cprof_pkg.update_profile_amount:'||x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     arp_standard.debug('EXCEPTION OTHERS: hzp_cprof_pkg.update_profile_amout'||x_msg_data);
  END;


/*---------------------------------------------------------------+
 | PROCEDURE :  DELETE_PROFILE_AMOUNT                            |
 |                                                               |
 | PARAMETERS :                                                  |
 |   NUMBER Customer_profile_amt_id                              |
 |                                                               |
 | DESCRIPTION :                                                 |
 |  Delete a record from Hz_Cust_Profile_Amts                    |
 |                                                               |
 | HISTORY :                                                     |
 |  12-DEC-2002   H. Yu   Created                                |
 +---------------------------------------------------------------*/
 PROCEDURE delete_profile_amount
 (p_cust_acct_profile_amt_id        IN    NUMBER,
  x_return_status                   OUT   NOCOPY VARCHAR2,
  x_msg_count                       OUT   NOCOPY NUMBER,
  x_msg_data                        OUT   NOCOPY VARCHAR2)
 IS
 BEGIN
   arp_standard.debug('delete_profile_amount(+)');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   DELETE FROM hz_cust_profile_amts
   WHERE cust_acct_profile_amt_id  = p_cust_acct_profile_amt_id;

   IF (SQL%NOTFOUND) THEN
     Raise NO_DATA_FOUND;
   END IF;

   arp_standard.debug('delete_profile_amount(-)');

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     arp_standard.debug('EXCEPTION NO_DATA_FOUND: hzp_cprof_pkg.delete_profile_amout');

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
     FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
     arp_standard.debug('EXCEPTION OTHERS: hzp_cprof_pkg.delete_profile_amout'||x_msg_data);
 END;

END hzp_cprof_pkg;

/
