--------------------------------------------------------
--  DDL for Package Body PN_OPEX_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_OPEX_TERMS_PKG" AS
  -- $Header: PNOTERMB.pls 120.2 2007/10/11 06:27:45 rthumma noship $

-------------------------------------------------------------------
-- PROCEDURE CREATE_OPEX_PAYMENT_TERMS
-------------------------------------------------------------------
PROCEDURE create_opex_payment_terms(
    p_est_payment_id        IN     NUMBER,
    p_term_template_id      IN     NUMBER DEFAULT NULL,
    p_lease_id              IN     NUMBER,
    x_payment_term_id       OUT    NOCOPY NUMBER,
    x_catch_up_term_id      OUT    NOCOPY NUMBER,
    x_return_status         IN OUT NOCOPY VARCHAR2
    ) IS
    l_lease_class_code         pn_leases.lease_class_code%TYPE;
    l_distribution_id          pn_distributions.distribution_id%TYPE;
    l_lease_change_id          pn_lease_details.lease_change_id%TYPE;
    l_rowid                    ROWID;
    l_distribution_count       NUMBER  := 0;
    l_inv_start_date           DATE;
    l_payment_start_date       DATE;
    l_payment_end_date         DATE;
    l_frequency                pn_payment_terms_all.frequency_code%type;
    l_schedule_day             pn_payment_terms_all.schedule_day%type;
    l_set_of_books_id          gl_sets_of_books.set_of_books_id%type;
    l_context                  varchar2(2000);
    l_area                     pn_payment_terms_all.area%TYPE;
    l_area_type_code           pn_payment_terms_all.area_type_code%TYPE;
    l_org_id                   NUMBER;
    l_schedule_day_char        VARCHAR2(8);
    l_payment_status_lookup_code  pn_payment_schedules_all.payment_status_lookup_code%type;
    i_cnt                      number;
    l_est_payment_term_id          pn_payment_terms_all.payment_term_id%TYPE;
    l_catch_up_payment_term_id          pn_payment_terms_all.payment_term_id%TYPE;
    l_currency_code  pn_payment_terms_all.currency_code%TYPE;


    CURSOR opex_est_pay_cur(est_pay_trm_id   IN  NUMBER)
    IS
        SELECT *
        FROM pn_opex_est_payments_all
        WHERE est_payment_id = est_pay_trm_id;

    CURSOR term_template_cur (term_temp_id   IN   NUMBER)
    IS
        SELECT *
        FROM pn_term_templates_all
        WHERE term_template_id = term_temp_id;

    CURSOR agreement_cur(agr_id   IN NUMBER)
    IS
    SELECT agr.* , loc.location_id
    FROM pn_opex_agreements_all agr,
       pn_locations_all loc,
       pn_tenancies_all ten
    WHERE agreement_id = agr_id
     AND  agr.tenancy_id = ten.tenancy_id
     AND ten.location_id = loc.location_id;

    CURSOR distributions_cur (term_temp_id   IN   NUMBER)
    IS
        SELECT *
        FROM pn_distributions_all
        WHERE term_template_id = term_temp_id;



-- Used to default the previous terms values and
-- could be used in case contraction is to be done.
    CURSOR prev_pay_term_cur (arg_id IN NUMBER)
    IS
      SELECT * FROM pn_payment_terms_all
      WHERE payment_term_id =
                (SELECT MAX(payment_term_id) FROM pn_payment_terms_all
                 WHERE opex_agr_id = arg_id
                 AND opex_type = 'ESTPMT');

    template_rec pn_term_templates_all%ROWTYPE;
    opex_est_pay_rec opex_est_pay_cur%ROWTYPE;
    agreement_rec agreement_cur%ROWTYPE;
    distributions_rec distributions_cur%ROWTYPE;
    pay_term_rec prev_pay_term_cur%ROWTYPE;


BEGIN
    x_return_status :=  'S';
    SAVEPOINT create_term;
       --dbms_output.put_line('Testing');

    pnp_debug_pkg.put_log_msg ('opex_create_payment_term');

        l_context := 'Validating input parameters';

    IF (p_est_payment_id IS NULL OR
         p_lease_id IS NULL ) THEN
          pnp_debug_pkg.put_log_msg ('Input Prameters missing');
    END IF;



        l_context := 'Getting lease class code and lease change id';
        BEGIN
            SELECT pl.lease_class_code,
                   pld.lease_change_id,
                   pl.org_id
            INTO   l_lease_class_code,
                   l_lease_change_id,
                   l_org_id
            FROM pn_leases_all pl,
                 pn_lease_details_all pld
            WHERE pl.lease_id = pld.lease_id
            AND pld.lease_id = p_lease_id;

            EXCEPTION
            WHEN TOO_MANY_ROWS THEN
                 pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - TOO_MANY_ROWS');
            WHEN NO_DATA_FOUND THEN
                 pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - NO_DATA_FOUND');
            WHEN OTHERS THEN
                pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - Unknown Error:'|| SQLERRM);
        END;

        l_context := 'Getting set of books id';
        --dbms_output.put_line('getting set of books');

        l_set_of_books_id := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID'
                                                                            ,l_org_id));

        pnp_debug_pkg.put_log_msg ('create_payment_terms  - Set of books id :'||l_set_of_books_id);

        IF p_term_template_id IS NOT NULL THEN

            l_context := 'opening cursor csr_template';
            OPEN term_template_cur(p_term_template_id);
            FETCH term_template_cur INTO template_rec;
            IF term_template_cur%NOTFOUND THEN
              pnp_debug_pkg.put_log_msg ('No template dat found');
              RAISE NO_DATA_FOUND;
            END IF;
            CLOSE term_template_cur;
        END IF;

        --dbms_output.put_line('template cur');

        l_context := 'opening est terms table';

        OPEN opex_est_pay_cur(p_est_payment_id);
        FETCH opex_est_pay_CUR INTO opex_est_pay_rec;
        IF opex_est_pay_cur%NOTFOUND THEN
          pnp_debug_pkg.put_log_msg ('No template dat found');
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE opex_est_pay_cur;

        --dbms_output.put_line('est Table cur');

        l_context := 'opening agreement_cur';

        OPEN agreement_cur(opex_est_pay_rec.agreement_id);
        FETCH agreement_cur INTO agreement_rec;
        IF agreement_cur%NOTFOUND THEN
          pnp_debug_pkg.put_log_msg ('No template dat found');
          RAISE NO_DATA_FOUND ;
        END IF;
        CLOSE agreement_cur;

        --dbms_output.put_line('agreement curr');

        OPEN prev_pay_term_cur(opex_est_pay_rec.agreement_id);
        FETCH prev_pay_term_cur INTO pay_term_rec;
        IF prev_pay_term_cur%NOTFOUND THEN
          pnp_debug_pkg.put_log_msg ('No template dat found');
          pay_term_rec := NULL;
        END IF;
        CLOSE prev_pay_term_cur;


       IF l_lease_class_code = 'DIRECT' THEN
        /* lease is of class: DIRECT */
         template_rec.customer_id := NULL;
         template_rec.customer_site_use_id := NULL;
         template_rec.cust_ship_site_id := NULL;
         template_rec.cust_trx_type_id := NULL;
         template_rec.inv_rule_id := NULL;
         template_rec.account_rule_id := NULL;
         template_rec.salesrep_id := NULL;
         template_rec.cust_po_number := NULL;
         template_rec.receipt_method_id := NULL;
      ELSE
        /* lease is 'sub-lease' or third-party */
         template_rec.project_id := NULL;
         template_rec.task_id := NULL;
         template_rec.organization_id := NULL;
         template_rec.expenditure_type := NULL;
         template_rec.expenditure_item_date := NULL;
         template_rec.vendor_id := NULL;
         template_rec.vendor_site_id := NULL;
         template_rec.tax_group_id := NULL;
         template_rec.distribution_set_id := NULL;
         template_rec.po_header_id := NULL;
      END IF;

      IF pn_r12_util_pkg.is_r12 THEN
         template_rec.tax_group_id := null;
         template_rec.tax_code_id := null;
      ELSE
         template_rec.tax_classification_code := null;
      END IF;

        --dbms_output.put_line('setting main values');


      -- put the start date and the end for the payment term from est_pay term

    l_payment_start_date := opex_est_pay_rec.start_date;
    l_payment_end_date := opex_est_pay_rec.end_date;

    l_context := 'Setting frequency and schedule day';


null;


      l_frequency        := agreement_rec.est_pay_freq_code;
      l_schedule_day     := to_char(l_payment_start_date,'dd');
      l_currency_code    := NVL(agreement_rec.est_pay_currency_code , template_rec.currency_code);
      --dbms_output.put_line('set freq and sch day');


    -- Need to check how to get the location.

      IF agreement_rec.location_id IS NOT NULL AND
         l_payment_start_date IS NOT NULL THEN

          l_area_type_code := 'LOCTN_RENTABLE';
          l_area := pnp_util_func.fetch_tenancy_area(
                       p_lease_id       => p_lease_id,
                       p_location_id    => agreement_rec.location_id,
                       p_as_of_date     => l_payment_start_date,
                       p_area_type_code => l_area_type_code);

      END IF;

-- For estimated term


    IF  NVL(opex_est_pay_rec.est_pmt_amount,0) <> 0 THEN

      --dbms_output.put_line('tttttt'||agreement_rec.est_pay_freq_code);

      --dbms_output.put_line('inserting row 1');
      --dbms_output.put_line('x_last_update_login' || NVL(fnd_profile.value('LOGIN_ID'),0));
      --dbms_output.put_line('x_last_updated_by '|| NVL (fnd_profile.VALUE ('USER_ID'), 0));
      --dbms_output.put_line('x_payment_purpose_code' || NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code) );
      --dbms_output.put_line('x_payment_term_type_code' || NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code));
      --dbms_output.put_line('x_frequency_code' || NVL(agreement_rec.est_pay_freq_code , l_frequency));
      --dbms_output.put_line('x_lease_id' || p_lease_id);
      --dbms_output.put_line('x_lease_change_id' || l_lease_change_id);
      --dbms_output.put_line('l_payment_start_date' || l_payment_start_date);
      --dbms_output.put_line('x_end_date' || l_payment_end_date);
      --dbms_output.put_line('x_currency_code' || l_currency_code);
      --dbms_output.put_line('x_set_of_books_id' || NVL(template_rec.set_of_books_id,l_set_of_books_id));

        pnp_debug_pkg.put_log_msg ('opex_create_payment_term');
        pnp_debug_pkg.put_log_msg('inserting row 1');
        pnp_debug_pkg.put_log_msg('x_last_update_login' || NVL(fnd_profile.value('LOGIN_ID'),0));
        pnp_debug_pkg.put_log_msg('x_last_updated_by '|| NVL (fnd_profile.VALUE ('USER_ID'), 0));
        pnp_debug_pkg.put_log_msg('x_payment_purpose_code' || NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code) );
        pnp_debug_pkg.put_log_msg('x_payment_term_type_code' || NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code));
        pnp_debug_pkg.put_log_msg('x_frequency_code' || NVL(agreement_rec.est_pay_freq_code , l_frequency));
        pnp_debug_pkg.put_log_msg('x_lease_id' || agreement_rec.lease_id);
        pnp_debug_pkg.put_log_msg('x_lease_change_id' || l_lease_change_id);
        pnp_debug_pkg.put_log_msg('l_payment_start_date' || l_payment_start_date);
        pnp_debug_pkg.put_log_msg('x_end_date' || l_payment_end_date);
        pnp_debug_pkg.put_log_msg('x_currency_code' || l_currency_code);
        pnp_debug_pkg.put_log_msg('x_set_of_books_id' || NVL(template_rec.set_of_books_id,l_set_of_books_id));

    -- We retain the previous term's changes made. hence
    -- if a previous term exists we store the values present
    -- in the previous term , else we store the values of the
    -- template.


      pnt_payment_terms_pkg.insert_row (
            x_rowid                       => l_rowid
           ,x_payment_term_id             => l_est_payment_term_id
           ,x_index_period_id             => null
           ,x_index_term_indicator        => null
           ,x_var_rent_inv_id             => null
           ,x_var_rent_type               => null
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code)
           ,x_payment_term_type_code      => NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code)
           ,x_frequency_code              => NVL(agreement_rec.est_pay_freq_code , l_frequency)
           ,x_lease_id                    => p_lease_id
           ,x_lease_change_id             => l_lease_change_id
           ,x_start_date                  => l_payment_start_date
           ,x_end_date                    => l_payment_end_date
           ,x_set_of_books_id             => NVL(template_rec.set_of_books_id,l_set_of_books_id)
           ,x_currency_code               => l_currency_code
           ,x_rate                        => 1   -- not used in application
           ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
           ,x_vendor_id                   => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_id ELSE  pay_term_rec.vendor_id END
           ,x_vendor_site_id              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_site_id ELSE pay_term_rec.vendor_site_id END
           ,x_target_date                 => NULL
           ,x_actual_amount               => opex_est_pay_rec.est_pmt_amount
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => NVL(opex_est_pay_rec.attribute_category , template_rec.attribute_category)
           ,x_attribute1                  => NVL(opex_est_pay_rec.attribute1 , template_rec.attribute1)
           ,x_attribute2                  => NVL(opex_est_pay_rec.attribute2 , template_rec.attribute2)
           ,x_attribute3                  => NVL(opex_est_pay_rec.attribute3 , template_rec.attribute3)
           ,x_attribute4                  => NVL(opex_est_pay_rec.attribute4 , template_rec.attribute4)
           ,x_attribute5                  => NVL(opex_est_pay_rec.attribute5 , template_rec.attribute5)
           ,x_attribute6                  => NVL(opex_est_pay_rec.attribute6 , template_rec.attribute6)
           ,x_attribute7                  => NVL(opex_est_pay_rec.attribute7 , template_rec.attribute7)
           ,x_attribute8                  => NVL(opex_est_pay_rec.attribute8 , template_rec.attribute8)
           ,x_attribute9                  => NVL(opex_est_pay_rec.attribute9 , template_rec.attribute9)
           ,x_attribute10                 => NVL(opex_est_pay_rec.attribute10 , template_rec.attribute10)
           ,x_attribute11                 => NVL(opex_est_pay_rec.attribute11 , template_rec.attribute11)
           ,x_attribute12                 => NVL(opex_est_pay_rec.attribute12 , template_rec.attribute12)
           ,x_attribute13                 => NVL(opex_est_pay_rec.attribute13 , template_rec.attribute13)
           ,x_attribute14                 => NVL(opex_est_pay_rec.attribute14 , template_rec.attribute14)
           ,x_attribute15                 => NVL(opex_est_pay_rec.attribute15 , template_rec.attribute15)
           ,x_project_attribute_category  => NULL
           ,x_project_attribute1          => NULL
           ,x_project_attribute2          => NULL
           ,x_project_attribute3          => NULL
           ,x_project_attribute4          => NULL
           ,x_project_attribute5          => NULL
           ,x_project_attribute6          => NULL
           ,x_project_attribute7          => NULL
           ,x_project_attribute8          => NULL
           ,x_project_attribute9          => NULL
           ,x_project_attribute10         => NULL
           ,x_project_attribute11         => NULL
           ,x_project_attribute12         => NULL
           ,x_project_attribute13         => NULL
           ,x_project_attribute14         => NULL
           ,x_project_attribute15         => NULL
           ,x_customer_id                 => template_rec.customer_id
           ,x_customer_site_use_id        => template_rec.customer_site_use_id
           ,x_normalize                   => 'N'
           ,x_location_id                 => agreement_rec.location_id
           ,x_schedule_day                => l_schedule_day
           ,x_cust_ship_site_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_ship_site_id ELSE  pay_term_rec.cust_ship_site_id END
           ,x_ap_ar_term_id               => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.ap_ar_term_id ELSE  pay_term_rec.ap_ar_term_id END
           ,x_cust_trx_type_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_trx_type_id ELSE  pay_term_rec.cust_trx_type_id END
           ,x_project_id                  => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.project_id ELSE  pay_term_rec.project_id END
           ,x_task_id                     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.task_id ELSE  pay_term_rec.task_id END
           ,x_organization_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.organization_id ELSE  pay_term_rec.organization_id END
           ,x_expenditure_type            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_type ELSE  pay_term_rec.expenditure_type END
           ,x_expenditure_item_date       => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_item_date ELSE  pay_term_rec.expenditure_item_date END
           ,x_tax_group_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_group_id ELSE  pay_term_rec.tax_group_id END
           ,x_tax_code_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_tax_classification_code     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_classification_code ELSE  pay_term_rec.tax_classification_code END
           ,x_tax_included                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_included ELSE  pay_term_rec.tax_included END
           ,x_distribution_set_id         => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.distribution_set_id ELSE  pay_term_rec.distribution_set_id END
           ,x_inv_rule_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.inv_rule_id ELSE  pay_term_rec.inv_rule_id END
           ,x_account_rule_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.account_rule_id ELSE  pay_term_rec.account_rule_id END
           ,x_salesrep_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.salesrep_id ELSE  pay_term_rec.salesrep_id END
           ,x_approved_by                 => NULL
           ,x_status                      => 'DRAFT'
           ,x_po_header_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_cust_po_number              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_receipt_method_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
--C           ,x_calling_form                => NULL
           ,x_org_id                      => l_org_id
           ,x_term_template_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.term_template_id ELSE  pay_term_rec.term_template_id END
           ,x_area                        => l_area
           ,x_area_type_code              => l_area_type_code
         );

         -- Updating the opex columns in the pn_payment_terms_all

            UPDATE pn_payment_terms_all
             SET opex_agr_id = agreement_rec.agreement_id,
                 opex_type   = 'ESTPMT'
             WHERE payment_term_id = l_est_payment_term_id;


    END IF;

      --dbms_output.put_line('inserted payment amt row ' || l_est_payment_term_id );

-- For catch up term

    IF  NVL(opex_est_pay_rec.catch_up_amount,0) <> 0 THEN

      pnt_payment_terms_pkg.insert_row (
            x_rowid                       => l_rowid
           ,x_payment_term_id             => l_catch_up_payment_term_id
           ,x_index_period_id             => null
           ,x_index_term_indicator        => null
           ,x_var_rent_inv_id             => null
           ,x_var_rent_type               => null
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code)
           ,x_payment_term_type_code      => NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code)
           ,x_frequency_code              => 'OT'
           ,x_lease_id                    => p_lease_id
           ,x_lease_change_id             => l_lease_change_id
           ,x_start_date                  => SYSDATE -- Defaulted to sysdate for catchup terms
           ,x_end_date                    => SYSDATE -- Defaulted to sysdate for catchup terms
           ,x_set_of_books_id             => NVL(template_rec.set_of_books_id,l_set_of_books_id)
           ,x_currency_code               => l_currency_code
           ,x_rate                        => 1 -- not used in application
           ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
           ,x_vendor_id                   => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_id ELSE  pay_term_rec.vendor_id END
           ,x_vendor_site_id              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_site_id ELSE pay_term_rec.vendor_site_id END
           ,x_target_date                 => NULL
           ,x_actual_amount               => opex_est_pay_rec.catch_up_amount
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => NVL(opex_est_pay_rec.attribute_category , template_rec.attribute_category)
           ,x_attribute1                  => NVL(opex_est_pay_rec.attribute1 , template_rec.attribute1)
           ,x_attribute2                  => NVL(opex_est_pay_rec.attribute2 , template_rec.attribute2)
           ,x_attribute3                  => NVL(opex_est_pay_rec.attribute3 , template_rec.attribute3)
           ,x_attribute4                  => NVL(opex_est_pay_rec.attribute4 , template_rec.attribute4)
           ,x_attribute5                  => NVL(opex_est_pay_rec.attribute5 , template_rec.attribute5)
           ,x_attribute6                  => NVL(opex_est_pay_rec.attribute6 , template_rec.attribute6)
           ,x_attribute7                  => NVL(opex_est_pay_rec.attribute7 , template_rec.attribute7)
           ,x_attribute8                  => NVL(opex_est_pay_rec.attribute8 , template_rec.attribute8)
           ,x_attribute9                  => NVL(opex_est_pay_rec.attribute9 , template_rec.attribute9)
           ,x_attribute10                 => NVL(opex_est_pay_rec.attribute10 , template_rec.attribute10)
           ,x_attribute11                 => NVL(opex_est_pay_rec.attribute11 , template_rec.attribute11)
           ,x_attribute12                 => NVL(opex_est_pay_rec.attribute12 , template_rec.attribute12)
           ,x_attribute13                 => NVL(opex_est_pay_rec.attribute13 , template_rec.attribute13)
           ,x_attribute14                 => NVL(opex_est_pay_rec.attribute14 , template_rec.attribute14)
           ,x_attribute15                 => NVL(opex_est_pay_rec.attribute15 , template_rec.attribute15)
           ,x_project_attribute_category  => NULL
           ,x_project_attribute1          => NULL
           ,x_project_attribute2          => NULL
           ,x_project_attribute3          => NULL
           ,x_project_attribute4          => NULL
           ,x_project_attribute5          => NULL
           ,x_project_attribute6          => NULL
           ,x_project_attribute7          => NULL
           ,x_project_attribute8          => NULL
           ,x_project_attribute9          => NULL
           ,x_project_attribute10         => NULL
           ,x_project_attribute11         => NULL
           ,x_project_attribute12         => NULL
           ,x_project_attribute13         => NULL
           ,x_project_attribute14         => NULL
           ,x_project_attribute15         => NULL
           ,x_customer_id                 => template_rec.customer_id
           ,x_customer_site_use_id        => template_rec.customer_site_use_id
           ,x_normalize                   => 'N'
           ,x_location_id                 => agreement_rec.location_id
           ,x_schedule_day                => l_schedule_day
           ,x_cust_ship_site_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_ship_site_id ELSE  pay_term_rec.cust_ship_site_id END
           ,x_ap_ar_term_id               => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.ap_ar_term_id ELSE  pay_term_rec.ap_ar_term_id END
           ,x_cust_trx_type_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_trx_type_id ELSE  pay_term_rec.cust_trx_type_id END
           ,x_project_id                  => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.project_id ELSE  pay_term_rec.project_id END
           ,x_task_id                     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.task_id ELSE  pay_term_rec.task_id END
           ,x_organization_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.organization_id ELSE  pay_term_rec.organization_id END
           ,x_expenditure_type            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_type ELSE  pay_term_rec.expenditure_type END
           ,x_expenditure_item_date       => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_item_date ELSE  pay_term_rec.expenditure_item_date END
           ,x_tax_group_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_group_id ELSE  pay_term_rec.tax_group_id END
           ,x_tax_code_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_tax_classification_code     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_classification_code ELSE  pay_term_rec.tax_classification_code END
           ,x_tax_included                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_included ELSE  pay_term_rec.tax_included END
           ,x_distribution_set_id         => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.distribution_set_id ELSE  pay_term_rec.distribution_set_id END
           ,x_inv_rule_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.inv_rule_id ELSE  pay_term_rec.inv_rule_id END
           ,x_account_rule_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.account_rule_id ELSE  pay_term_rec.account_rule_id END
           ,x_salesrep_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.salesrep_id ELSE  pay_term_rec.salesrep_id END
           ,x_approved_by                 => NULL
           ,x_status                      => 'DRAFT'
           ,x_po_header_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_cust_po_number              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_receipt_method_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
--C           ,x_calling_form                => NULL
           ,x_org_id                      => l_org_id
           ,x_term_template_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.term_template_id ELSE  pay_term_rec.term_template_id END
           ,x_area                        => l_area
           ,x_area_type_code              => l_area_type_code
           );

         -- Updating the opex columns in the pn_payment_terms_all

            UPDATE pn_payment_terms_all
             SET opex_agr_id = agreement_rec.agreement_id,
                 opex_type   = 'CATCHUP'
             WHERE payment_term_id = l_catch_up_payment_term_id;


    END IF;
      --dbms_output.put_line('inserted payment amt row ' || l_catch_up_payment_term_id );

      l_distribution_count := 0;
      l_context :='opening cursor csr_distributions';

    IF l_est_payment_term_id IS NOT NULL THEN
      FOR rec_distributions in distributions_cur(p_term_template_id)
            LOOP
                    pnp_debug_pkg.put_log_msg(' account_id '||rec_distributions.account_id);
                    pnp_debug_pkg.put_log_msg(' account_class '||rec_distributions.account_id);
              l_context := 'Inserting into pn_distributions';
              pn_distributions_pkg.insert_row (
                 x_rowid                       => l_rowid
                ,x_distribution_id             => l_distribution_id
                ,x_account_id                  => rec_distributions.account_id
                ,x_payment_term_id             => l_est_payment_term_id
                ,x_term_template_id            => NULL
                ,x_account_class               => rec_distributions.account_class
                ,x_percentage                  => rec_distributions.percentage
                ,x_line_number                 => rec_distributions.line_number
                ,x_last_update_date            => SYSDATE
                ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_creation_date               => SYSDATE
                ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
                ,x_attribute_category          => rec_distributions.attribute_category
                ,x_attribute1                  => rec_distributions.attribute1
                ,x_attribute2                  => rec_distributions.attribute2
                ,x_attribute3                  => rec_distributions.attribute3
                ,x_attribute4                  => rec_distributions.attribute4
                ,x_attribute5                  => rec_distributions.attribute5
                ,x_attribute6                  => rec_distributions.attribute6
                ,x_attribute7                  => rec_distributions.attribute7
                ,x_attribute8                  => rec_distributions.attribute8
                ,x_attribute9                  => rec_distributions.attribute9
                ,x_attribute10                 => rec_distributions.attribute10
                ,x_attribute11                 => rec_distributions.attribute11
                ,x_attribute12                 => rec_distributions.attribute12
                ,x_attribute13                 => rec_distributions.attribute13
                ,x_attribute14                 => rec_distributions.attribute14
                ,x_attribute15                 => rec_distributions.attribute15
                ,x_org_id                      => l_org_id
              );
                    l_rowid := NULL;
                    l_distribution_id := NULL;
                    l_distribution_count :=   l_distribution_count + 1;
            END LOOP;
            l_context := 'exiting from loop';
    END IF;

    IF l_catch_up_payment_term_id IS NOT NULL THEN
      FOR rec_distributions in distributions_cur(p_term_template_id)
            LOOP
                    pnp_debug_pkg.put_log_msg(' account_id '||rec_distributions.account_id);
                    pnp_debug_pkg.put_log_msg(' account_class '||rec_distributions.account_id);
              l_context := 'Inserting into pn_distributions';
              pn_distributions_pkg.insert_row (
                 x_rowid                       => l_rowid
                ,x_distribution_id             => l_distribution_id
                ,x_account_id                  => rec_distributions.account_id
                ,x_payment_term_id             => l_catch_up_payment_term_id
                ,x_term_template_id            => NULL
                ,x_account_class               => rec_distributions.account_class
                ,x_percentage                  => rec_distributions.percentage
                ,x_line_number                 => rec_distributions.line_number
                ,x_last_update_date            => SYSDATE
                ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_creation_date               => SYSDATE
                ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
                ,x_attribute_category          => rec_distributions.attribute_category
                ,x_attribute1                  => rec_distributions.attribute1
                ,x_attribute2                  => rec_distributions.attribute2
                ,x_attribute3                  => rec_distributions.attribute3
                ,x_attribute4                  => rec_distributions.attribute4
                ,x_attribute5                  => rec_distributions.attribute5
                ,x_attribute6                  => rec_distributions.attribute6
                ,x_attribute7                  => rec_distributions.attribute7
                ,x_attribute8                  => rec_distributions.attribute8
                ,x_attribute9                  => rec_distributions.attribute9
                ,x_attribute10                 => rec_distributions.attribute10
                ,x_attribute11                 => rec_distributions.attribute11
                ,x_attribute12                 => rec_distributions.attribute12
                ,x_attribute13                 => rec_distributions.attribute13
                ,x_attribute14                 => rec_distributions.attribute14
                ,x_attribute15                 => rec_distributions.attribute15
                ,x_org_id                      => l_org_id
              );
                    l_rowid := NULL;
                    l_distribution_id := NULL;
                    l_distribution_count :=   l_distribution_count + 1;
            END LOOP;
            l_context := 'exiting from loop';

    END IF;
      --dbms_output.put_line('inserted dists ' );


            x_payment_term_id   :=  l_est_payment_term_id;
            x_catch_up_term_id  :=  l_catch_up_payment_term_id;


      --dbms_output.put_line('updaated est payments' );

EXCEPTION
     WHEN OTHERS THEN
      ROLLBACK TO create_term;
      pnp_debug_pkg.put_log_msg(substrb('pn_variable_term_pkg.Error in opex_create_payment_term - ' ||
                                             to_char(sqlcode)||' : '||sqlerrm || ' - '|| l_context,1,244));
      --dbms_output.put_line('Exception');
      x_return_status := 'E';
END create_opex_payment_terms;


PROCEDURE create_recon_pay_term(
    p_recon_id         IN            NUMBER DEFAULT NULL,
    p_agreement_id     IN            NUMBER,
    p_st_end_date      IN            DATE,
    p_amount           IN            NUMBER,
    x_payment_term_id  OUT    NOCOPY NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2
    ) IS

    l_lease_class_code         pn_leases.lease_class_code%TYPE;
    l_distribution_id          pn_distributions.distribution_id%TYPE;
    l_lease_change_id          pn_lease_details.lease_change_id%TYPE;
    l_rowid                    ROWID;
    l_distribution_count       NUMBER  := 0;
    l_inv_start_date           DATE;
    l_payment_start_date       DATE;
    l_payment_end_date         DATE;
    l_frequency                pn_payment_terms_all.frequency_code%type;
    l_schedule_day             pn_payment_terms_all.schedule_day%type;
    l_set_of_books_id          gl_sets_of_books.set_of_books_id%type;
    l_context                  varchar2(2000);
    l_area                     pn_payment_terms_all.area%TYPE;
    l_area_type_code           pn_payment_terms_all.area_type_code%TYPE;
    l_org_id                   NUMBER;
    l_schedule_day_char        VARCHAR2(8);
    l_payment_status_lookup_code  pn_payment_schedules_all.payment_status_lookup_code%type;
    i_cnt                      number;
    l_payment_term_id          pn_payment_terms_all.payment_term_id%TYPE;
    l_currency_code  pn_payment_terms_all.currency_code%TYPE;


    CURSOR opex_est_pay_cur(est_pay_trm_id   IN  NUMBER)
    IS
        SELECT *
        FROM pn_opex_est_payments_all
        WHERE est_payment_id = est_pay_trm_id;

    CURSOR term_template_cur (term_temp_id   IN   NUMBER)
    IS
        SELECT *
        FROM pn_term_templates_all
        WHERE term_template_id = term_temp_id;

    CURSOR agreement_cur(agr_id   IN NUMBER)
    IS
      SELECT agr.* , loc.location_id
      FROM pn_opex_agreements_all agr,
         pn_locations_all loc,
         pn_tenancies_all ten
      WHERE agreement_id = agr_id
      AND  agr.tenancy_id = ten.tenancy_id
      AND ten.location_id = loc.location_id;

    CURSOR distributions_cur (term_temp_id   IN   NUMBER)
    IS
        SELECT *
        FROM pn_distributions_all
        WHERE term_template_id = term_temp_id;


-- Using the last estimated payment term to default the values in case present.

    CURSOR prev_pay_term_cur (arg_id IN NUMBER)
    IS
      SELECT * FROM pn_payment_terms_all
      WHERE payment_term_id =
                (SELECT MAX(payment_term_id) FROM pn_payment_terms_all
                 WHERE opex_agr_id = arg_id
                 AND opex_type = 'ESTPMT');


    template_rec pn_term_templates_all%ROWTYPE;
    agreement_rec agreement_cur%ROWTYPE;
    distributions_rec distributions_cur%ROWTYPE;
    pay_term_rec prev_pay_term_cur%ROWTYPE;


BEGIN
    x_return_status :=  'S';
       --dbms_output.put_line('Testing');

    pnp_debug_pkg.put_log_msg ('opex_create_payment_term');

        l_context := 'Validating input parameters';

    IF (p_recon_id  IS NULL OR
        p_agreement_id is NULL) THEN
          pnp_debug_pkg.put_log_msg ('Input Prameters missing');
    END IF;


        l_context := 'opening agreement_cur';

        OPEN agreement_cur(p_agreement_id);
        FETCH agreement_cur INTO agreement_rec;
        IF agreement_cur%NOTFOUND THEN
          pnp_debug_pkg.put_log_msg ('No template dat found');
          RAISE NO_DATA_FOUND ;
        END IF;
        CLOSE agreement_cur;

        --dbms_output.put_line('agreement curr');


        l_context := 'Getting lease class code and lease change id';
        BEGIN
            SELECT pl.lease_class_code,
                   pld.lease_change_id,
                   pl.org_id
            INTO   l_lease_class_code,
                   l_lease_change_id,
                   l_org_id
            FROM pn_leases_all pl,
                 pn_lease_details_all pld
            WHERE pl.lease_id = pld.lease_id
            AND pld.lease_id = agreement_rec.lease_id;
            EXCEPTION
            WHEN TOO_MANY_ROWS THEN
                 pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - TOO_MANY_ROWS');
            WHEN NO_DATA_FOUND THEN
                 pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - NO_DATA_FOUND');
            WHEN OTHERS THEN
                pnp_debug_pkg.put_log_msg ('Cannot Get Main Lease Details - Unknown Error:'|| SQLERRM);
        END;

        l_context := 'Getting set of books id';
        --dbms_output.put_line('getting set of books');

        l_set_of_books_id := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID'
                                                                            ,l_org_id));

        pnp_debug_pkg.put_log_msg ('create_payment_terms  - Set of books id :'||l_set_of_books_id);

        IF agreement_rec.term_template_id IS NOT NULL THEN

            l_context := 'opening cursor csr_template';
            OPEN term_template_cur(agreement_rec.term_template_id);
            FETCH term_template_cur INTO template_rec;
            IF term_template_cur%NOTFOUND THEN
              pnp_debug_pkg.put_log_msg ('No template dat found');
              RAISE NO_DATA_FOUND;
            END IF;
            CLOSE term_template_cur;
        END IF;

        --dbms_output.put_line('template cur');

--N        l_context := 'opening est terms table';
--N
--N        OPEN opex_est_pay_cur(p_est_payment_id);
--N        FETCH opex_est_pay_CUR INTO opex_est_pay_rec;
--N        IF opex_est_pay_cur%NOTFOUND THEN
--N          pnp_debug_pkg.put_log_msg ('No template dat found');
--N          RAISE NO_DATA_FOUND;
--N        END IF;
--N        CLOSE opex_est_pay_cur;

        --dbms_output.put_line('est Table cur');

        OPEN prev_pay_term_cur(p_agreement_id);
        FETCH prev_pay_term_cur INTO pay_term_rec;
        IF prev_pay_term_cur%NOTFOUND THEN
          pnp_debug_pkg.put_log_msg ('No template dat found');
          pay_term_rec := NULL;
        END IF;
        CLOSE prev_pay_term_cur;


       IF l_lease_class_code = 'DIRECT' THEN
        /* lease is of class: DIRECT */
         template_rec.customer_id := NULL;
         template_rec.customer_site_use_id := NULL;
         template_rec.cust_ship_site_id := NULL;
         template_rec.cust_trx_type_id := NULL;
         template_rec.inv_rule_id := NULL;
         template_rec.account_rule_id := NULL;
         template_rec.salesrep_id := NULL;
         template_rec.cust_po_number := NULL;
         template_rec.receipt_method_id := NULL;
      ELSE
        /* lease is 'sub-lease' or third-party */
         template_rec.project_id := NULL;
         template_rec.task_id := NULL;
         template_rec.organization_id := NULL;
         template_rec.expenditure_type := NULL;
         template_rec.expenditure_item_date := NULL;
         template_rec.vendor_id := NULL;
         template_rec.vendor_site_id := NULL;
         template_rec.tax_group_id := NULL;
         template_rec.distribution_set_id := NULL;
         template_rec.po_header_id := NULL;
      END IF;

      IF pn_r12_util_pkg.is_r12 THEN
         template_rec.tax_group_id := null;
         template_rec.tax_code_id := null;
      ELSE
         template_rec.tax_classification_code := null;
      END IF;

        --dbms_output.put_line('setting main values');


      -- put the start date and the end for the payment term from est_pay term

    l_payment_start_date := p_st_end_date;
    l_payment_end_date :=   p_st_end_date;

    l_context := 'Setting frequency and schedule day';


null;


      l_frequency        := 'OT';
      l_schedule_day     := to_char(l_payment_start_date,'dd');
      l_currency_code    := template_rec.currency_code;
      --dbms_output.put_line('set freq and sch day');


    -- Need to check how to get the location.

      IF agreement_rec.location_id IS NOT NULL AND
         l_payment_start_date IS NOT NULL THEN

          l_area_type_code := 'LOCTN_RENTABLE';
          l_area := pnp_util_func.fetch_tenancy_area(
                       p_lease_id       => agreement_rec.lease_id,
                       p_location_id    => agreement_rec.location_id,
                       p_as_of_date     => l_payment_start_date,
                       p_area_type_code => l_area_type_code);

      END IF;

-- For estimated term


      --dbms_output.put_line('tttttt'||agreement_rec.est_pay_freq_code);

      --dbms_output.put_line('inserting row 1');
      --dbms_output.put_line('x_last_update_login' || NVL(fnd_profile.value('LOGIN_ID'),0));
      --dbms_output.put_line('x_last_updated_by '|| NVL (fnd_profile.VALUE ('USER_ID'), 0));
      --dbms_output.put_line('x_payment_purpose_code' || NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code) );
      --dbms_output.put_line('x_payment_term_type_code' || NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code));
      --dbms_output.put_line('x_frequency_code' || NVL(agreement_rec.est_pay_freq_code , l_frequency));
      --dbms_output.put_line('x_lease_id' || agreement_rec.lease_id);
      --dbms_output.put_line('x_lease_change_id' || l_lease_change_id);
      --dbms_output.put_line('l_payment_start_date' || l_payment_start_date);
      --dbms_output.put_line('x_end_date' || l_payment_end_date);
      --dbms_output.put_line('x_currency_code' || l_currency_code);
      --dbms_output.put_line('x_set_of_books_id' || NVL(template_rec.set_of_books_id,l_set_of_books_id));

        pnp_debug_pkg.put_log_msg ('opex_create_payment_term');
        pnp_debug_pkg.put_log_msg('inserting row 1');
        pnp_debug_pkg.put_log_msg('x_last_update_login' || NVL(fnd_profile.value('LOGIN_ID'),0));
        pnp_debug_pkg.put_log_msg('x_last_updated_by '|| NVL (fnd_profile.VALUE ('USER_ID'), 0));
        pnp_debug_pkg.put_log_msg('x_payment_purpose_code' || NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code) );
        pnp_debug_pkg.put_log_msg('x_payment_term_type_code' || NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code));
        pnp_debug_pkg.put_log_msg('x_frequency_code' || NVL(agreement_rec.est_pay_freq_code , l_frequency));
        pnp_debug_pkg.put_log_msg('x_lease_id' || agreement_rec.lease_id);
        pnp_debug_pkg.put_log_msg('x_lease_change_id' || l_lease_change_id);
        pnp_debug_pkg.put_log_msg('l_payment_start_date' || l_payment_start_date);
        pnp_debug_pkg.put_log_msg('x_end_date' || l_payment_end_date);
        pnp_debug_pkg.put_log_msg('x_currency_code' || l_currency_code);
        pnp_debug_pkg.put_log_msg('x_set_of_books_id' || NVL(template_rec.set_of_books_id,l_set_of_books_id));



      pnt_payment_terms_pkg.insert_row (
            x_rowid                       => l_rowid
           ,x_payment_term_id             => l_payment_term_id
           ,x_index_period_id             => null
           ,x_index_term_indicator        => null
           ,x_var_rent_inv_id             => null
           ,x_var_rent_type               => null
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => NVL(agreement_rec.payment_purpose_code ,template_rec.payment_purpose_code)
           ,x_payment_term_type_code      => NVL(agreement_rec.payment_type_code , template_rec.payment_term_type_code)
           ,x_frequency_code              => l_frequency
           ,x_lease_id                    => agreement_rec.lease_id
           ,x_lease_change_id             => l_lease_change_id
           ,x_start_date                  => l_payment_start_date
           ,x_end_date                    => l_payment_end_date
           ,x_set_of_books_id             => NVL(template_rec.set_of_books_id,l_set_of_books_id)
           ,x_currency_code               => l_currency_code
           ,x_rate                        => 1 -- not used in application
           ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
           ,x_vendor_id                   => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_id ELSE  pay_term_rec.vendor_id END
           ,x_vendor_site_id              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.vendor_site_id ELSE pay_term_rec.vendor_site_id END
           ,x_target_date                 => NULL
           ,x_actual_amount               => p_amount
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => template_rec.attribute_category
           ,x_attribute1                  => template_rec.attribute1
           ,x_attribute2                  => template_rec.attribute2
           ,x_attribute3                  => template_rec.attribute3
           ,x_attribute4                  => template_rec.attribute4
           ,x_attribute5                  => template_rec.attribute5
           ,x_attribute6                  => template_rec.attribute6
           ,x_attribute7                  => template_rec.attribute7
           ,x_attribute8                  => template_rec.attribute8
           ,x_attribute9                  => template_rec.attribute9
           ,x_attribute10                 => template_rec.attribute10
           ,x_attribute11                 => template_rec.attribute11
           ,x_attribute12                 => template_rec.attribute12
           ,x_attribute13                 => template_rec.attribute13
           ,x_attribute14                 => template_rec.attribute14
           ,x_attribute15                 => template_rec.attribute15
           ,x_project_attribute_category  => NULL
           ,x_project_attribute1          => NULL
           ,x_project_attribute2          => NULL
           ,x_project_attribute3          => NULL
           ,x_project_attribute4          => NULL
           ,x_project_attribute5          => NULL
           ,x_project_attribute6          => NULL
           ,x_project_attribute7          => NULL
           ,x_project_attribute8          => NULL
           ,x_project_attribute9          => NULL
           ,x_project_attribute10         => NULL
           ,x_project_attribute11         => NULL
           ,x_project_attribute12         => NULL
           ,x_project_attribute13         => NULL
           ,x_project_attribute14         => NULL
           ,x_project_attribute15         => NULL
           ,x_customer_id                 => template_rec.customer_id
           ,x_customer_site_use_id        => template_rec.customer_site_use_id
           ,x_normalize                   => 'N'
           ,x_location_id                 => agreement_rec.location_id
           ,x_schedule_day                => l_schedule_day
           ,x_cust_ship_site_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_ship_site_id ELSE  pay_term_rec.cust_ship_site_id END
           ,x_ap_ar_term_id               => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.ap_ar_term_id ELSE  pay_term_rec.ap_ar_term_id END
           ,x_cust_trx_type_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.cust_trx_type_id ELSE  pay_term_rec.cust_trx_type_id END
           ,x_project_id                  => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.project_id ELSE  pay_term_rec.project_id END
           ,x_task_id                     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.task_id ELSE  pay_term_rec.task_id END
           ,x_organization_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.organization_id ELSE  pay_term_rec.organization_id END
           ,x_expenditure_type            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_type ELSE  pay_term_rec.expenditure_type END
           ,x_expenditure_item_date       => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.expenditure_item_date ELSE  pay_term_rec.expenditure_item_date END
           ,x_tax_group_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_group_id ELSE  pay_term_rec.tax_group_id END
           ,x_tax_code_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_tax_classification_code     => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_classification_code ELSE  pay_term_rec.tax_classification_code END
           ,x_tax_included                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_included ELSE  pay_term_rec.tax_included END
           ,x_distribution_set_id         => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.distribution_set_id ELSE  pay_term_rec.distribution_set_id END
           ,x_inv_rule_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.inv_rule_id ELSE  pay_term_rec.inv_rule_id END
           ,x_account_rule_id             => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.account_rule_id ELSE  pay_term_rec.account_rule_id END
           ,x_salesrep_id                 => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.salesrep_id ELSE  pay_term_rec.salesrep_id END
           ,x_approved_by                 => NULL
           ,x_status                      => 'DRAFT'
           ,x_po_header_id                => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_cust_po_number              => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
           ,x_receipt_method_id           => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.tax_code_id ELSE  pay_term_rec.tax_code_id END
--C           ,x_calling_form                => NULL
           ,x_org_id                      => l_org_id
           ,x_term_template_id            => CASE WHEN pay_term_rec.payment_term_id IS NULL THEN template_rec.term_template_id ELSE  pay_term_rec.term_template_id END
           ,x_area                        => l_area
           ,x_area_type_code              => l_area_type_code
           );
            -- Updating the opex columns in the pn_payment_terms_all

            UPDATE pn_payment_terms_all
             SET opex_recon_id = p_recon_id,
                 opex_agr_id = p_agreement_id,
                 opex_type = 'RECON'
            WHERE payment_term_id = l_payment_term_id;

      --dbms_output.put_line('inserted payment amt row ' || l_payment_term_id );


      l_distribution_count := 0;
      l_context :='opening cursor csr_distributions';

    IF l_payment_term_id IS NOT NULL THEN
      FOR rec_distributions in distributions_cur(agreement_rec.term_template_id)
            LOOP
                    pnp_debug_pkg.put_log_msg(' account_id '||rec_distributions.account_id);
                    pnp_debug_pkg.put_log_msg(' account_class '||rec_distributions.account_id);
              l_context := 'Inserting into pn_distributions';
              pn_distributions_pkg.insert_row (
                 x_rowid                       => l_rowid
                ,x_distribution_id             => l_distribution_id
                ,x_account_id                  => rec_distributions.account_id
                ,x_payment_term_id             => l_payment_term_id
                ,x_term_template_id            => NULL
                ,x_account_class               => rec_distributions.account_class
                ,x_percentage                  => rec_distributions.percentage
                ,x_line_number                 => rec_distributions.line_number
                ,x_last_update_date            => SYSDATE
                ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_creation_date               => SYSDATE
                ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
                ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
                ,x_attribute_category          => rec_distributions.attribute_category
                ,x_attribute1                  => rec_distributions.attribute1
                ,x_attribute2                  => rec_distributions.attribute2
                ,x_attribute3                  => rec_distributions.attribute3
                ,x_attribute4                  => rec_distributions.attribute4
                ,x_attribute5                  => rec_distributions.attribute5
                ,x_attribute6                  => rec_distributions.attribute6
                ,x_attribute7                  => rec_distributions.attribute7
                ,x_attribute8                  => rec_distributions.attribute8
                ,x_attribute9                  => rec_distributions.attribute9
                ,x_attribute10                 => rec_distributions.attribute10
                ,x_attribute11                 => rec_distributions.attribute11
                ,x_attribute12                 => rec_distributions.attribute12
                ,x_attribute13                 => rec_distributions.attribute13
                ,x_attribute14                 => rec_distributions.attribute14
                ,x_attribute15                 => rec_distributions.attribute15
                ,x_org_id                      => l_org_id
              );
                    l_rowid := NULL;
                    l_distribution_id := NULL;
                    l_distribution_count :=   l_distribution_count + 1;
            END LOOP;
            l_context := 'exiting from loop';
    END IF;

            x_payment_term_id := l_payment_term_id;


EXCEPTION
     WHEN OTHERS THEN
      pnp_debug_pkg.put_log_msg(substrb('pn_variable_term_pkg.Error in opex_create_payment_term - ' ||
                                             to_char(sqlcode)||' : '||sqlerrm || ' - '|| l_context,1,244));
      --dbms_output.put_line('Exception');
      x_return_status := 'E';
END create_recon_pay_term;


-------------------------------------------------------------------------------
-- PROCEDURE contract_prev_est_term
--
-- History
--
--  05-JUL-07  Pikhar   o IF frequency is MONTHLY, last schedule day is last
--                        day of month, else the day one day prior to payment
--                        term start.
-------------------------------------------------------------------------------

PROCEDURE contract_prev_est_term(
    p_lease_id          IN    NUMBER,
    p_est_payment_id    IN    NUMBER,
    x_return_status     IN OUT  NOCOPY VARCHAR2)
IS

    CURSOR opex_est_pay_cur(est_pay_trm_id   IN  NUMBER)
    IS
        SELECT *
        FROM pn_opex_est_payments_all
        WHERE est_payment_id = est_pay_trm_id;

    CURSOR pay_sch_cur(p1_lease_id  IN NUMBER , pl_contract_sch_date  IN DATE) IS
          SELECT payment_schedule_id
          FROM pn_payment_schedules_all
        WHERE lease_id = p1_lease_id
        and  payment_status_lookup_code = 'DRAFT'
        AND schedule_date >=  pl_contract_sch_date;


    prev_pay_term_id    NUMBER;
    opex_est_pay_rec  opex_est_pay_cur%ROWTYPE;
    last_sch_date  DATE;
    prev_trm_end_date  DATE;
    l_sch_id NUMBER;


    CURSOR last_sch_day_cur( c_lease_id IN NUMBER , c_pay_term_id IN NUMBER)  IS
        SELECT
        pmt.lease_id,
        ADD_MONTHS(TO_DATE((TO_CHAR(MAX(pmt.start_date),'dd') || '-' || to_char(max(sch.schedule_date) , 'mm-yyyy')),'dd-mm-yyyy'),
                   DECODE(max(pmt.frequency_code),'MON', 0, 'QTR', 2, 'SA', 5 , 'YR', 11)) as last_sch_date
        FROM   pn_payment_terms_all pmt,
               pn_payment_schedules_all sch
        WHERE  sch.payment_status_lookup_code = 'APPROVED'
        AND pmt.payment_term_id = c_pay_term_id
        AND    sch.lease_id = c_lease_id
        AND    pmt.lease_id = c_lease_id
        GROUP BY pmt.lease_id;


    /*CURSOR last_sch_day_cur( c_lease_id IN NUMBER , c_pay_term_id IN NUMBER)  IS
        SELECT
        pmt.lease_id,
        (TO_DATE((TO_CHAR(MAX(pmt.start_date),'dd') || '-' || to_char(max(sch.schedule_date) , 'mm-yyyy')),'dd-mm-yyyy'))  as last_sch_date
        FROM   pn_payment_terms_all pmt,
               pn_payment_schedules_all sch
        WHERE  sch.payment_status_lookup_code = 'APPROVED'
        AND pmt.payment_term_id = c_pay_term_id
        AND    sch.lease_id = c_lease_id
        AND    pmt.lease_id = c_lease_id
        GROUP BY pmt.lease_id;*/


    CURSOR payment_cur(pay_term_id IN NUMBER) IS
       SELECT * FROM
        pn_payment_terms_all
        WHERE payment_term_id = pay_term_id;

       last_sch_day_rec last_sch_day_cur%ROWTYPE;
       payment_rec payment_cur%ROWTYPE;

  BEGIN
    x_return_status := 'S';
    OPEN opex_est_pay_cur(p_est_payment_id);
    FETCH opex_est_pay_cur INTO opex_est_pay_rec;
    IF opex_est_pay_cur%NOTFOUND THEN
      pnp_debug_pkg.put_log_msg('No Est Term Err'  );
      RAISE NO_DATA_FOUND;
    END IF;


--  Getting the payment term that has to be contracted.
    BEGIN
        SELECT payment_term_id INTO prev_pay_term_id
         FROM pn_opex_est_payments_all
         WHERE est_payment_id <> p_est_payment_id
         AND  AGREEMENT_ID = opex_est_pay_rec.agreement_id
         AND END_DATE = (
              SELECT MAX(END_DATE) FROM pn_opex_est_payments_all
               WHERE AGREEMENT_ID = opex_est_pay_rec.agreement_id
               AND est_payment_id <> p_est_payment_id)
               AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      pnp_debug_pkg.put_log_msg('No Prev Term to be contracted'  );
        RETURN;   -- No term to be contracted;
    END;

      pnp_debug_pkg.put_log_msg('Payment term to be contracted ' || prev_pay_term_id);

      FOR payment_rec1 IN payment_cur(prev_pay_term_id) LOOP
        payment_rec  := payment_rec1 ;
      END LOOP;

      pnp_debug_pkg.put_log_msg('Prev Payment term to be contracted 1' || payment_rec.payment_term_id);
      pnp_debug_pkg.put_log_msg('Prev Payment term end date' || payment_rec.end_date);
      pnp_debug_pkg.put_log_msg('New payment_term start date ' || opex_est_pay_rec.start_date);

    IF payment_rec.end_date >=  opex_est_pay_rec.start_date THEN
    --do all this only if the parev end date is greater than the start date
      pnp_debug_pkg.put_log_msg('Into if for contraction');

    --    Getting the last approved schedule date
          pnp_debug_pkg.put_log_msg('Getting the last approved schedule date');

    /*         pn_opex_terms_pkg.last_schedule_day(p_lease_id =>  p_lease_id,
                                   p_payment_term_id =>  prev_pay_term_id,
                                   x_end_date        =>  last_sch_date);
          pnp_debug_pkg.put_log_msg('last approved schedule date ' || last_sch_date);  */

            FOR last_sch_day_rec in last_sch_day_cur(p_lease_id ,prev_pay_term_id) LOOP
                IF payment_rec.frequency_code = 'MON' THEN
                   last_sch_date := last_day(last_sch_day_rec.last_sch_date);
                ELSE
                   last_sch_date := last_sch_day_rec.last_sch_date - 1;
                END IF;
            END LOOP;
          pnp_debug_pkg.put_log_msg('last approved schedule date ' || last_sch_date);



         -- Contract previous estpmt Id to last approved schedule date.
         -- Logic..
         -- If last schedule date is not  null set prev term end date to  last schedule date
         -- else
         --  set end date to start date - 1
         -- else est end date to the start date

            IF last_sch_date IS NOT NULL THEN
               prev_trm_end_date := last_sch_date;
            ELSE
              IF  opex_est_pay_rec.start_date <=  payment_rec.end_date THEN
                -- if they prev end date is less than the start date set prev term end date to prev term start date.
                IF opex_est_pay_rec.start_date >  payment_rec.start_date  THEN
                    prev_trm_end_date := opex_est_pay_rec.start_date - 1;
                ELSE
                    prev_trm_end_date := opex_est_pay_rec.start_date;
                END IF;
              END IF;
            END IF;




        --  Delete all schedules from pn_payment_schedules_all and payment_schedule id is not there in payment_items_all and schedule is in draft status

            l_sch_id := NULL;
            FOR sch_rec in pay_sch_cur(p_lease_id , prev_trm_end_date ) LOOP

              l_sch_id := sch_rec.payment_schedule_id;

              pnp_debug_pkg.put_log_msg('Deleting Schedule_id  ' || l_sch_id);

              DELETE FROM pn_payment_items_all
                WHERE payment_term_id = prev_pay_term_id
                AND payment_schedule_id = l_sch_id
                AND payment_item_type_lookup_code = 'CASH';

              DELETE FROM pn_payment_schedules_all
                WHERE NOT EXISTS (SELECT NULL
                                  FROM pn_payment_items_all
                                  WHERE payment_schedule_id = l_sch_id)
                AND payment_schedule_id = l_sch_id;

           END LOOP; /*sch cursor */



          pnp_debug_pkg.put_log_msg('Updating pn_opex_est_payments_all and pn_payment_terms_all with date ' || prev_trm_end_date );

          IF (prev_trm_end_date IS NOT NULL) THEN

            UPDATE pn_opex_est_payments_all
                SET END_DATE = prev_trm_end_date
            Where payment_term_id = prev_pay_term_id;

            UPDATE pn_payment_terms_all
                SET END_DATE = prev_trm_end_date
            Where payment_term_id = prev_pay_term_id;
          END IF;

    ELSE
        pnp_debug_pkg.put_log_msg('Terms are independent and need not be contracted.');
    END IF; --payment_rec.end_date >=  opex_est_pay_rec.start_date

EXCEPTION
     WHEN OTHERS THEN
      pnp_debug_pkg.put_log_msg('contract_prev_est_term Errored' );
      --dbms_output.put_line('Exception');
      x_return_status := 'E';

  END contract_prev_est_term;



/*===========================================================================+
 | PROCEDURE
 |    LAST_SCHEDULE_DAY
 |
 | DESCRIPTION
 |    Find last date till which schedules are approved
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   p_lease_id
 |                   p_payment_term_id
 |
 |              OUT:
 |                   x_end_date
 |
 | RETURNS    : None
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |   02-JAN-2007  pikhar    o Created
 +===========================================================================*/
PROCEDURE LAST_SCHEDULE_DAY( p_lease_id        IN           NUMBER,
                             p_payment_term_id IN           NUMBER,
                             x_end_date        OUT  NOCOPY  VARCHAR2) IS

   schedule_date   DATE;
   end_date        DATE;
   frequency       NUMBER;
   l_pay_term_id   NUMBER;
   last_sch_date   DATE;


   CURSOR schedule_end_date_cur IS
      SELECT (to_date((substr(to_char(max(pmt.start_date),'dd-mm-yyyy'),1,2) || substr(to_char(max(sch.schedule_date),'dd-mm-yyyy'),3)), 'dd-mm-yyyy')) schedule_date
      FROM   pn_payment_terms_all pmt,
             pn_payment_schedules_all sch,
             pn_opex_est_payments_all est
      WHERE  pmt.payment_term_id = est.payment_term_id
      AND    est.est_payment_id = p_payment_term_id
      AND    sch.payment_status_lookup_code = 'APPROVED'
      AND    sch.lease_id = p_lease_id;

   CURSOR frequency_cur(p_pay_trm_id   IN  NUMBER) IS
      SELECT DECODE(pmt.FREQUENCY_CODE, 'MON', 1, 'QTR', 3, 'SA', 6 , 'YR', 12) frequency
      FROM   pn_payment_terms_all pmt
      WHERE  pmt.payment_term_id = p_pay_trm_id;


   CURSOR opex_est_pay_cur(est_pay_trm_id   IN  NUMBER)
    IS
        SELECT payment_term_id
        FROM pn_opex_est_payments_all
        WHERE est_payment_id = est_pay_trm_id;

   CURSOR last_sch_day_cur( c_lease_id IN NUMBER , c_pay_term_id IN NUMBER)  IS
        SELECT
        pmt.lease_id,
        ADD_MONTHS(TO_DATE((TO_CHAR(MAX(pmt.start_date),'dd') || '-' || to_char(max(sch.schedule_date) , 'mm-yyyy')),'dd-mm-yyyy'),
                   DECODE(max(pmt.frequency_code),'MON', 0, 'QTR', 2, 'SA', 5 , 'YR', 11)) as last_sch_date
        FROM   pn_payment_terms_all pmt,
               pn_payment_schedules_all sch
        WHERE  sch.payment_status_lookup_code = 'APPROVED'
        AND pmt.payment_term_id = c_pay_term_id
        AND    sch.lease_id = c_lease_id
        AND    pmt.lease_id = c_lease_id
        GROUP BY pmt.lease_id;


BEGIN

   pnp_debug_pkg.debug ('PN_OPEX_TERMS_PKG.LAST_SCHEDULE_DAY (+)');


   FOR rec IN opex_est_pay_cur(p_payment_term_id) LOOP
     l_pay_term_id := rec.payment_term_id;
   END LOOP;

   IF l_pay_term_id IS NOT NULL THEN
      FOR rec IN frequency_cur(l_pay_term_id) LOOP
         frequency := rec.frequency;
      END LOOP;


      FOR last_sch_day_rec in last_sch_day_cur(p_lease_id ,l_pay_term_id) LOOP
          IF frequency = 1 THEN
             last_sch_date := last_day(last_sch_day_rec.last_sch_date) + 1;
          ELSE
             last_sch_date := last_sch_day_rec.last_sch_date;
          END IF;
      END LOOP;

      x_end_date :=  to_char(last_sch_date);

   ELSE
      x_end_date :=  to_char(sysdate);
   END IF;



   /*FOR rec  IN schedule_end_date_cur LOOP
      schedule_date := to_date(rec.schedule_date , 'DD-MM-YYYY');
   END LOOP;


   FOR rec IN frequency_cur LOOP
      frequency := rec.frequency;
   END LOOP;

   end_date := add_months(schedule_date, frequency);
   end_date := end_date - 1;

   --dbms_output.put_line('schedule_date = '||schedule_date);
   --dbms_output.put_line('frequency  = '||frequency);
   --dbms_output.put_line('end date = '||end_date);

   x_end_date :=  to_char(end_date);*/

   pnp_debug_pkg.debug ('PN_OPEX_TERMS_PKG.LAST_SCHEDULE_DAY (-)');

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END LAST_SCHEDULE_DAY;




PROCEDURE ALAST_SCHEDULE_DAY( p_lease_id        IN           NUMBER,
                             p_payment_term_id IN           NUMBER,
                             x_end_date        OUT  NOCOPY  VARCHAR2) IS

   schedule_date   DATE;
   end_date        DATE;
   frequency       NUMBER;


   CURSOR schedule_end_date_cur IS
      SELECT (to_date((substr(to_char(max(pmt.start_date),'dd-mm-yyyy'),1,2) || substr(to_char(max(sch.schedule_date),'dd-mm-yyyy'),3)), 'dd-mm-yyyy')) schedule_date
      FROM   pn_payment_terms_all pmt,
             pn_payment_schedules_all sch
      WHERE  pmt.payment_term_id = p_payment_term_id
      AND    sch.payment_status_lookup_code = 'APPROVED'
      AND    sch.lease_id = p_lease_id;

   CURSOR frequency_cur IS
      SELECT DECODE(pmt.FREQUENCY_CODE, 'MON', 1, 'QTR', 3, 'SA', 6 , 'YR', 12) frequency
      FROM   pn_payment_terms_all pmt
      WHERE  pmt.payment_term_id = p_payment_term_id;



BEGIN

   pnp_debug_pkg.debug ('PN_OPEX_TERMS_PKG.LAST_SCHEDULE_DAY (+)');

   FOR rec  IN schedule_end_date_cur LOOP
      --dbms_output.put_line('schedule_date = L1');
      schedule_date := rec.schedule_date ;
   END LOOP;


   FOR rec IN frequency_cur LOOP
      --dbms_output.put_line('freq');
      frequency := rec.frequency;
   END LOOP;
      --dbms_output.put_line('out');
   end_date := add_months(schedule_date, frequency);
   end_date := end_date - 1;

   --dbms_output.put_line('schedule_date = '||schedule_date);
   --dbms_output.put_line('frequency  = '||frequency);
   --dbms_output.put_line('end date = '||end_date);

   x_end_date :=  to_char(end_date);

   pnp_debug_pkg.debug ('PN_OPEX_TERMS_PKG.LAST_SCHEDULE_DAY (-)');

EXCEPTION
   WHEN OTHERS THEN
      RAISE;

END ALAST_SCHEDULE_DAY;


  FUNCTION get_curr_est_pay_term_amt(agr_id IN NUMBER)
  RETURN NUMBER
  IS
  amount NUMBER ;
  BEGIN
    IF agr_id IS NULL THEN
       RETURN NULL;

    ELSE
      BEGIN
       SELECT EST_PMT_AMOUNT INTO amount
       FROM pn_opex_est_payments_all
       WHERE agreement_id = agr_id
       AND END_DATE IN
                (SELECT  MAX(END_DATE) FROM
                 pn_opex_est_payments_all
                 WHERE agreement_id = agr_id)
                 AND ROWNUM = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END;
    END IF;
      RETURN amount;

  END get_curr_est_pay_term_amt;

/*===========================================================================+
 | FUNCTION
 |    GET_CURR_EST_PAY_TERM
 |
 | DESCRIPTION
 |    Finds the latest estimated payment term
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :agr_id IN NUMBER
 |
 | RETURNS    : NUMBER
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |   20-JUN-07  sdmahesh      o Bug 6132914 - Modified to get latest estimated
 |                              pay term in case of multiple terms with same
 |                              maximum end date
 +===========================================================================*/

  FUNCTION get_curr_est_pay_term(agr_id IN NUMBER)
  RETURN NUMBER
  IS
  max_id              NUMBER := -1;
  CURSOR csr_max_dt_est_term(p_agr_id NUMBER) IS
    SELECT est_payment_id
    FROM pn_opex_est_payments_all
    WHERE agreement_id = p_agr_id
    AND END_DATE IN
             (SELECT  MAX(END_DATE) FROM
              pn_opex_est_payments_all
              WHERE agreement_id = p_agr_id);


  BEGIN
    IF agr_id IS NULL THEN
       RETURN NULL;
    ELSE
       FOR rec IN csr_max_dt_est_term(agr_id) LOOP
         IF rec.est_payment_id > max_id THEN
            max_id := rec.est_payment_id;
         END IF;
       END LOOP;
    END IF;
    RETURN max_id;
  END get_curr_est_pay_term;


  FUNCTION get_latest_recon(agr_id IN NUMBER)
  RETURN NUMBER
  IS
  x_recon_id NUMBER ;
  BEGIN
    IF agr_id IS NULL THEN
       RETURN NULL;
    ELSE
      BEGIN
      SELECT * INTO x_recon_id
      FROM (SELECT recon_id FROM pn_opex_recon_all
                      WHERE agreement_id = agr_id
                      ORDER BY period_end_dt DESC , revision_number DESC)
      WHERE ROWNUM = 1 ;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN NULL;
      END;
    END IF;
      RETURN x_recon_id;
  END get_latest_recon;

/*===========================================================================+
 | FUNCTION
 |    GET_PROP_ID
 |
 | DESCRIPTION
 |    Finds the property associated with a location
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :p_location_id IN NUMBER
 |
 | RETURNS    : NUMBER
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |   23-MAY-2007  sdmahesh    o Bug 6069029
 |                              Created
 +===========================================================================*/

FUNCTION get_prop_id(p_location_id IN NUMBER)
RETURN NUMBER
IS

CURSOR csr_prop_id(loc_id IN NUMBER) IS
   SELECT loc.property_id prop_id
   FROM pn_locations_all loc
   WHERE loc.parent_location_id IS NULL
   START WITH loc.location_id = loc_id
   CONNECT BY PRIOR loc.parent_location_id=loc.location_id;

rec csr_prop_id%ROWTYPE;

BEGIN
   OPEN csr_prop_id(p_location_id);
   FETCH csr_prop_id INTO rec;
    IF csr_prop_id%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE csr_prop_id;
    RETURN rec.prop_id;

EXCEPTION
   WHEN NO_DATA_FOUND  THEN
     RETURN NULL;
   WHEN OTHERS THEN
     RAISE;
END get_prop_id;



/*===========================================================================+
 | FUNCTION
 |    GET_STMT_DUE_DATE
 |
 | DESCRIPTION
 |    Finds the Statement due date for a reconciliation period
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                   agr_id
 |
 |
 |
 | RETURNS    : DATE
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |   02-MAY-2007  sdmahesh    o Bug 5940429
 |                              Ensured that all cases are taken care of in
 |                              DECODE for finding WORKING_DATE
 +===========================================================================*/

  FUNCTION get_stmt_due_date(agr_id IN NUMBER)
  RETURN DATE
  IS
  x_stmt_due_date DATE;
  latest_recon_id NUMBER;

  working_date  DATE;
  CURSOR st_due_cur(agr_id  IN NUMBER)
  IS
    SELECT * FROM
    pn_opex_critical_dates_all
    WHERE agreement_id = agr_id
    AND critical_date_type_code = 'RSDFL';


  CURSOR recon_cur(p_recon_id  IN NUMBER)
  IS
    SELECT * FROM
    pn_opex_recon_all
    WHERE recon_id = p_recon_id;

    st_due_rec st_due_cur%ROWTYPE;
    recon_rec recon_cur%ROWTYPE;


  BEGIN

    latest_recon_id := get_latest_recon(agr_id);
    IF latest_recon_id IS NULL THEN
      RETURN NULL;
    END IF;

    OPEN st_due_cur(agr_id);
    FETCH st_due_cur INTO st_due_rec;
    IF st_due_cur%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE st_due_cur;

    OPEN recon_cur(latest_recon_id);
    FETCH recon_cur INTO recon_rec;
    IF recon_cur%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
    END IF;

    CLOSE recon_cur;

-- Processing to get the date.

    BEGIN
    SELECT DECODE (st_due_rec.event_code ,
                   'RS' , recon_rec.period_start_dt ,
                   'RE' , recon_rec.period_end_dt ,
                   'CS' , TO_DATE('01-01-'||TO_CHAR(recon_rec.period_end_dt,'YYYY'),'DD-MM-YYYY'),
                   'ST' , recon_rec.st_recv_dt ,
                   null) INTO working_date FROM DUAL;
    IF working_date IS NULL THEN
      RETURN NULL ;
    END IF;

    SELECT DECODE (st_due_rec.when_code , 'A',DECODE (st_due_rec.time_unit_code,
                                         'M' , ADD_MONTHS(working_date , NVL(st_due_rec.time_unit,0)),
                                         'D' , working_date + NVL(st_due_rec.time_unit,0),
                                         'Y' , ADD_MONTHS(working_date , NVL(st_due_rec.time_unit,0) * 12),
                                         'W' , working_date + NVL(st_due_rec.time_unit,0)*7 ,
                                               null),--default
                                   'B' ,DECODE (st_due_rec.time_unit_code,
                                         'M' , ADD_MONTHS(working_date , -NVL(st_due_rec.time_unit,0)),
                                         'D' , working_date + -NVL(st_due_rec.time_unit,0),
                                         'Y' , ADD_MONTHS(working_date , -NVL(st_due_rec.time_unit,0) * 12),
                                         'W' , working_date + -NVL(st_due_rec.time_unit,0)*7,
                                              null) -- default
                                          , null) INTO working_date from dual;

    EXCEPTION
      WHEN NO_DATA_FOUND  THEN
        RETURN NULL;
    END;

    IF working_date IS NULL THEN
      RETURN NULL;
    ELSE
      x_stmt_due_date := working_date;
      RETURN working_date;
    END IF;

 EXCEPTION
      WHEN NO_DATA_FOUND THEN

      IF st_due_cur%ISOPEN THEN
        CLOSE st_due_cur;
      END IF;

      IF recon_cur%ISOPEN THEN
        CLOSE recon_cur;
      END IF;
      RETURN NULL;

      WHEN OTHERS THEN
        RAISE;
  END get_stmt_due_date;


PROCEDURE delete_agreement (p_agreement_id  IN  NUMBER
                           ,x_return_status  IN OUT NOCOPY VARCHAR2)
IS
  l_deletion_allowed VARCHAR2(1) := 'N';
BEGIN
    x_return_status :=  'S';
    BEGIN
      SELECT 'N' INTO l_deletion_allowed
      FROM DUAL WHERE EXISTS
                      (SELECT payment_term_id
                       FROM pn_payment_terms_all
                       WHERE opex_agr_id =  p_agreement_id
                       AND status = 'APPROVED');

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_deletion_allowed := 'Y';
    END;
    IF l_deletion_allowed = 'Y' THEN
        pnp_debug_pkg.debug ('Deleting.agreement');
    -- Deleting agreement tables

      DELETE FROM PN_OPEX_NOTES_ALL
      WHERE agreement_id = p_agreement_id;

      DELETE FROM PN_OPEX_CRITICAL_DATES_ALL
      WHERE agreement_id = p_agreement_id;


      DELETE FROM PN_OPEX_EXP_GRPS_ALL
      WHERE agreement_id = p_agreement_id;

      DELETE FROM PN_OPEX_PRORAT_BASIS_DTLS_ALL
      WHERE agreement_id = p_agreement_id;

      DELETE FROM PN_OPEX_EST_PAYMENTS_ALL
      WHERE agreement_id = p_agreement_id;

    -- Deleting reconciliation tables

      FOR i IN (SELECT recon_id FROM
                pn_opex_recon_all WHERE agreement_id = p_agreement_id) LOOP
          DELETE FROM PN_OPEX_RECON_CRDT_ALL
          WHERE recon_id = i.recon_id;

          DELETE FROM PN_OPEX_RECON_PRTBS_ALL
          WHERE recon_id = i.recon_id;

          DELETE FROM PN_OPEX_RECON_EXP_GRP_ALL
          WHERE recon_id = i.recon_id;

          DELETE FROM PN_OPEX_RECON_DETAILS_ALL
          WHERE recon_id = i.recon_id;

          DELETE FROM PN_OPEX_NOTES_ALL
          WHERE recon_id = i.recon_id;
      END LOOP;

        DELETE FROM PN_PAYMENT_TERMS_ALL
        WHERE opex_agr_id  = p_agreement_id;

        DELETE FROM PN_OPEX_AGREEMENTS_ALL
        WHERE agreement_id = p_agreement_id;

        DELETE FROM PN_OPEX_RECON_ALL
        WHERE agreement_id = p_agreement_id;

        DELETE FROM PN_OPEX_EST_PAYMENTS_ALL
        WHERE agreement_id = p_agreement_id;

    ELSE
        pnp_debug_pkg.debug ('Agreemnt cannot be deleted');
        x_return_status :=  'E';
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status :=  'U';
END delete_agreement;


FUNCTION recon_pct_change(p_agr_id IN NUMBER , p_recon_id IN NUMBER , p_period_start_dt DATE , p_ten_tot_charge NUMBER)
RETURN NUMBER
IS

rec_id NUMBER;
ten_tot_crg NUMBER;
pct_change NUMBER;
begin
  begin
    select recon_id , ten_tot_charge INTO rec_id,ten_tot_crg FROM pn_opex_recon_all WHERE
    agreement_id = p_agr_id
    AND period_end_dt + 1 = p_period_start_dt
    AND current_flag  = 'Y';
  EXCEPTION
   WHEN no_data_found THEN
      RETURN NULL;
  END;

  IF p_ten_tot_charge IS NULL OR ten_tot_crg IS NULL THEN
    RETURN NULL;
  ELSE
     IF ten_tot_crg = 0 THEN
      RETURN null;
     END if;
    pct_change := (p_ten_tot_charge - ten_tot_crg) / ten_tot_crg *100 ;
   END IF;
   RETURN round(pct_change,2);

EXCEPTION
WHEN others THEN
  raise;
END;

------------------------------------------------------------------------
-- PROCEDURE : put_log
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
-- 22-Feb-2007  Prabhakar   o Created.
------------------------------------------------------------------------

   PROCEDURE put_log ( p_string   IN   VARCHAR2 ) IS
   BEGIN
      pnp_debug_pkg.log(p_string);
   END put_log;


------------------------------------------------------------------------
-- PROCEDURE : put_output
-- DESCRIPTION: This procedure will display the text in the log file
--              of a concurrent program
--
-- 22-Feb-2007  Prabhakar   o Created.
------------------------------------------------------------------------

   PROCEDURE put_output ( p_string   IN   VARCHAR2 ) IS
   BEGIN
      pnp_debug_pkg.put_log_msg(p_string);
   END put_output;


------------------------------------------------------------------------
-- PROCEDURE : display_error_messages
-- DESCRIPTION: This procedure will parse a string of error message codes
--              delimited of with a comma.  It will lookup each code using
--              fnd_messages routine.
--
-- 22-Feb-2007  Prabhakar   o Created.
------------------------------------------------------------------------

   PROCEDURE display_error_messages (
      ip_message_string   IN   VARCHAR2
   ) IS
      message_string   VARCHAR2 (4000);
      msg_len          NUMBER;
      ind_message      VARCHAR2 (40);
      comma_loc        NUMBER;
   BEGIN
      message_string := ip_message_string;

      IF message_string IS NOT NULL THEN
         -- append a comma to the end of the string.
         message_string :=    message_string
                           || ',';
         -- get location of the first comma
         comma_loc := INSTR (message_string, ',', 1, 1);
         -- get length of message
         msg_len := LENGTH (message_string);
      ELSE
         comma_loc := 0;
      END IF;

      fnd_message.clear;

      --
      -- loop will cycle thru each occurrence of delimted text
      -- and display message with its code..
      --
      WHILE comma_loc <> 0
      LOOP
         --
         -- get error message to process
         --
         ind_message := SUBSTR (message_string, 1,   comma_loc
                                                   - 1);

         --
         -- check the length of error message code
         --
         --
         IF LENGTH (ind_message) > 30 THEN
            put_log (   '**** MESSAGE CODE '
                     || ind_message
                     || ' TOO LONG');
         ELSE
            --put_log (   'Message Code='
            --         || ind_message);

            --
            -- Convert error message code to its 'user-friendly' message;
            --
            fnd_message.set_name ('PN', ind_message);
            --
            -- Display message to the output log
            --
            put_output (   '-->'
                        || fnd_message.get
                        || ' ('
                        || ind_message
                        || ')');
            --
            -- delete the current message from string of messges
            -- e.g.
            --  before: message_string = "message1, message2, message3,"
            --  after:  message_string = "message2, message3,"
            --
            message_string := SUBSTR (
                                 message_string
                                ,  comma_loc
                                 + 1
                                ,  LENGTH (message_string)
                                 - comma_loc
                              );
            --
            -- locate the first occurrence of a comma
            --
            comma_loc := INSTR (message_string, ',', 1, 1);
         END IF; --LENGTH (ind_message) > 30
      END LOOP;
   END display_error_messages;




 ------------------------------------------------------------------------
-- FUNCTION : format
-- DESCRIPTION: This function is used the print_basis_periods procedure
--              to format any amount to This is only used to display
--              date to the output or log files.
--
-- 22-Feb-2007  Prabhakar   o Created.
--
------------------------------------------------------------------------


    FUNCTION format (
      p_number          IN   NUMBER
     ,p_precision       IN   NUMBER DEFAULT NULL
     ,p_currency_code   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2 IS
      v_currency_code      gl_sets_of_books.currency_code%TYPE;
      v_formatted_number   VARCHAR2 (100);
      v_format_mask        VARCHAR2 (100);
      v_field_length       NUMBER  := 20;
      v_min_acct_unit      NUMBER;
   BEGIN

      /* if p_number is not blank, apply format
         if it is blank, just print a blank space */

      IF p_number IS NOT NULL THEN

         /* deriving a format mask if precision is specified. */

         IF p_precision IS NOT NULL THEN
            fnd_currency.safe_build_format_mask (
               format_mask                   => v_format_mask
              ,field_length                  => v_field_length
              ,precision                     => p_precision
              ,min_acct_unit                 => v_min_acct_unit
            );
         ELSE


            /*  getting format make for currency code defined */

            v_format_mask := fnd_currency.get_format_mask (
                                currency_code                 => p_currency_code
                               ,field_length                  => v_field_length
                             );
         END IF;

         v_formatted_number := TO_CHAR (p_number, v_format_mask);
      ELSE

         /* set formatted number to a space if no number is passed */

         v_formatted_number := ' ';
      END IF;

      RETURN v_formatted_number;

   END format;

-------------------------------------------------------------------------------
-- PROCEDURE : approve_opex_pay_term
-- DESCRIPTION: This procedure is called by the mass opex payment
--              batch for single term approval.
--
--
-- 22-Feb-2007  Prabhakar   o Created.
-------------------------------------------------------------------------------

   PROCEDURE approve_opex_pay_term (ip_lease_id            IN          NUMBER
                                   ,ip_opex_pay_term_id   IN          NUMBER
                                   ,op_msg                 OUT NOCOPY  VARCHAR2
                                   ) IS

   v_msg                  VARCHAR2(1000);
   err_msg                VARCHAR2(2000);
   err_code               VARCHAR2(2000);
   l_include_in_var_rent  VARCHAR2(30);

   BEGIN
      put_log('pn_opex_terms_pkg.approve_index_pay_term (+) : ');

      pn_index_lease_common_pkg.chk_for_payment_reqd_fields (
         p_payment_term_id             => ip_opex_pay_term_id
        ,p_msg                         => v_msg
      );

      IF v_msg IS NULL THEN
         v_msg := 'PN_INDEX_APPROVE_SUCCESS';
         --
         -- call api to create schedules and items
         --

         pn_schedules_items.schedules_items (
            errbuf                        => err_msg
           ,retcode                       => err_code
           ,p_lease_id                    => ip_lease_id
           ,p_lease_context               => 'ADD'
           ,p_called_from                 => 'VAR'
           ,p_term_id                     => ip_opex_pay_term_id
           ,p_term_end_dt                 => NULL
         );

         --
         -- update status of payment term record
         --

         UPDATE pn_payment_terms_all
            SET status = 'APPROVED'
               ,last_update_date = SYSDATE
               ,last_updated_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
               ,approved_by = NVL (fnd_profile.VALUE ('USER_ID'), 0)
          WHERE payment_term_id = ip_opex_pay_term_id;

      END IF;

      op_msg := v_msg;

      put_log('pn_opex_terms_pkg.approve_index_pay_term (-) : ');

   END approve_opex_pay_term;



-------------------------------------------------------------------------------
-- PROCEDURE : approve_opex_pay_term_batch
-- DESCRIPTION: This procedure is called by the mass opex payment term
--              approval concurrent program.
--
--
-- 22-Feb-2007  Prabhakar   o Created.
-- 22-Mar-2007  Prabhakar   o Modified the property_id where condition
--                            not to cause both side NULL equalization.
-- 15-MAY-2007  sdmahesh    o Bug # 6039220
--                            Changed the order of concurrent program
--                            parameters
--                            Modifed CURSOR opex_recs w.r.t. join with
--                            PN_PROPERTIES_ALL
-- 23-MAY-07    sdmahesh    o Bug 6069029
--                            Modifed CURSOR OPEX_RECS w.r.t. join with
--                            PN_PROPERTIES_ALL.Used PN_OPEX_TERMS_PKG.GET_PROP_ID
-------------------------------------------------------------------------------

   PROCEDURE approve_opex_pay_term_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_agreement_number_lower     IN       VARCHAR2
     ,ip_agreement_number_upper     IN       VARCHAR2
     ,ip_main_lease_number_lower    IN       VARCHAR2
     ,ip_main_lease_number_upper    IN       VARCHAR2
     ,ip_location_code_lower        IN       VARCHAR2
     ,ip_location_code_upper        IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_payment_start_date_lower   IN       VARCHAR2
     ,ip_payment_start_date_upper   IN       VARCHAR2
     ,ip_payment_function           IN       VARCHAR2
     ,ip_property_code_ret_by_id    IN       VARCHAR2
     ,ip_payment_status             IN       VARCHAR2
   ) IS
      CURSOR opex_recs (
         p_agreement_number_lower     IN   VARCHAR2
        ,p_agreement_number_upper     IN   VARCHAR2
        ,p_main_lease_number_lower    IN   VARCHAR2
        ,p_main_lease_number_upper    IN   VARCHAR2
        ,p_location_code_lower        IN   VARCHAR2
   ,p_location_code_upper        IN   VARCHAR2
        ,p_user_responsible           IN   VARCHAR2
        ,p_payment_start_date_lower   IN   VARCHAR2
        ,p_payment_start_date_upper   IN   VARCHAR2
        ,p_property_code_ret_by_id    IN   VARCHAR2
        ,p_payment_function           IN   VARCHAR2
   ,p_payment_status             IN   VARCHAR2
      ) IS
      SELECT popex.lease_id,
        popex.agreement_id,
        ppt.payment_term_id,
        pl.lease_num,
        popex.agr_num,
        ppt.start_date,
        ppt.actual_amount,
        ppt.frequency_code,
        ppt.end_date,
        ppt.status,
        ppt.schedule_day,
        ppt.currency_code,
        DECODE(ppt.normalize,   'Y',   'NORMALIZE') "NORMALIZE",
        prop.property_id,
        loc.location_code,
        popex.created_by
      FROM pn_leases_all pl,
        pn_opex_agreements_all popex,
        pn_payment_terms_all ppt,
        pn_properties_all prop,
        pn_locations_all loc,
        pn_tenancies_all ten
      WHERE pl.lease_id         = popex.lease_id
       AND popex.agreement_id   = ppt.opex_agr_id
       AND popex.tenancy_id     = ten.tenancy_id
       AND ten.location_id      = loc.location_id
       AND  prop.property_id(+) = pn_opex_terms_pkg.get_prop_id(ppt.location_id)
       AND(popex.agr_num     BETWEEN nvl(p_agreement_number_lower,   popex.agr_num) AND nvl(p_agreement_number_upper,   popex.agr_num))
       AND(pl.lease_num      BETWEEN nvl(p_main_lease_number_lower,   pl.lease_num) AND nvl(p_main_lease_number_upper,   pl.lease_num))
       AND(loc.location_code BETWEEN nvl(p_location_code_lower,   loc.location_code)AND nvl(p_location_code_upper,   loc.location_code))
       AND(ppt.start_date    BETWEEN nvl(fnd_date.canonical_to_date(p_payment_start_date_lower),   ppt.start_date) AND nvl(fnd_date.canonical_to_date(p_payment_start_date_upper),   ppt.start_date))
       AND popex.created_by = nvl(p_user_responsible,   popex.created_by)
       AND ppt.status = p_payment_status
       AND(p_payment_function IS NULL OR
      (p_payment_function = 'RECON' AND ppt.opex_type = 'RECON' AND ppt.opex_agr_id IS NOT NULL AND ppt.opex_recon_id IS NOT NULL) OR
      (p_payment_function = 'CATCHUP' AND ppt.opex_type = 'CATCHUP' AND ppt.opex_agr_id IS NOT NULL AND ppt.opex_recon_id IS NULL) OR
      (p_payment_function = 'ESTPMT' AND ppt.opex_type = 'ESTPMT' AND ppt.opex_agr_id IS NOT NULL AND ppt.opex_recon_id IS NULL) OR
      (p_payment_function = 'ESTPMT_AND_CATCHUP' AND ppt.opex_type IN('ESTPMT',   'CATCHUP') AND ppt.opex_agr_id IS NOT NULL AND ppt.opex_recon_id IS NULL) OR
      (p_payment_function = 'ALL' AND ppt.opex_type IN('ESTPMT',   'CATCHUP',   'RECON') AND ppt.opex_agr_id IS NOT NULL))
       AND(p_property_code_ret_by_id IS NULL OR p_property_code_ret_by_id = prop.property_id)
       AND nvl(pl.status,   'D') = 'F';

      v_msg           VARCHAR2 (1000);
      v_counter       NUMBER          := 0;
      l_errmsg        VARCHAR2(2000);
      l_errmsg1       VARCHAR2(2000);
      l_return_status VARCHAR2 (2) := NULL;
      l_nxt_schdate   DATE;
      l_day           pn_payment_terms_all.schedule_day%TYPE;
      l_info          VARCHAR2(1000);
      l_message       VARCHAR2(2000) := NULL;
      l_appr_count    NUMBER := 0;
      l_batch_size    NUMBER := 1000;

   BEGIN
      put_log('pn_opex_terms_pkg.approve_index_pay_term_batch (+) : ');

      put_log ('ip_agreement_number_lower    '|| ip_agreement_number_lower);
      put_log ('ip_agreement_number_upper    '|| ip_agreement_number_upper);
      put_log ('ip_main_lease_number_lower   '|| ip_main_lease_number_lower);
      put_log ('ip_main_lease_number_upper   '|| ip_main_lease_number_upper);
      put_log ('ip_location_code_lower       '|| ip_location_code_lower);
      put_log ('ip_location_code_upper       '|| ip_location_code_upper);
      put_log ('ip_user_responsible          '|| ip_user_responsible);
      put_log ('ip_payment_start_date_lower  '|| ip_payment_start_date_lower);
      put_log ('ip_payment_start_date_upper  '|| ip_payment_start_date_upper);
      put_log ('ip_property_code_ret_by_id   '|| ip_property_code_ret_by_id);
      put_log ('ip_payment_function          '|| ip_payment_function);
      put_log ('ip_payment_status            '|| ip_payment_status);
      put_log ('Processing the Following Lease Periods:');

      /* get all opex payment terms to process */

      FOR opex_rec IN opex_recs (
                       ip_agreement_number_lower
                      ,ip_agreement_number_upper
                      ,ip_main_lease_number_lower
                      ,ip_main_lease_number_upper
                      ,ip_location_code_lower
                      ,ip_location_code_upper
                      ,ip_user_responsible
                      ,ip_payment_start_date_lower
                      ,ip_payment_start_date_upper
                      ,ip_property_code_ret_by_id
                      ,ip_payment_function
                      ,ip_payment_status
                            )
      LOOP
         v_counter :=   v_counter  +  1;

         put_output ('****************************************');
         fnd_message.set_name ('PN','PN_RICAL_PROC');
         put_output(fnd_message.get||'......');
         fnd_message.set_name ('PN','PN_OPEX_CAL_AGR_NO');
         fnd_message.set_token ('NUM', opex_rec.agr_num);
         put_output(fnd_message.get);
         put_output ('****************************************');

               l_info := ' approving payment term ID: '||opex_rec.payment_term_id||' ';
               approve_opex_pay_term (
                   ip_lease_id                   => opex_rec.lease_id
                  ,ip_opex_pay_term_id          => opex_rec.payment_term_id
                  ,op_msg                        => v_msg);

         l_message := NULL;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
         l_message := '         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_START');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_END');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT');
         l_message := l_message||'                     '||fnd_message.get;
         put_output(l_message);

         l_message := NULL;

         fnd_message.set_name ('PN','PN_RICAL_FREQ');
         l_message := '         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'    '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_DATE');
         l_message := l_message||'         '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_AMT');
         l_message := l_message||'        '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_STATUS');
         l_message := l_message||'      '||fnd_message.get;
         fnd_message.set_name ('PN','PN_RICAL_PAYMENT_TYPE');
         l_message := l_message||'        '||fnd_message.get;
    fnd_message.set_name ('PN','PN_RICAL_NORZ');
         l_message := l_message||'      '||fnd_message.get;
         put_output(l_message);

         put_output (
         '         ---------  -----------  -----------  ----------  -----------  ------------------  ----------'
                    );

         put_output ('.         ');
         put_output (
               LPAD (opex_rec.frequency_code, 18, ' ')
            || LPAD (opex_rec.start_date, 13, ' ')
            || LPAD (opex_rec.end_date, 13, ' ')
            || LPAD (format (opex_rec.actual_amount, 2, opex_rec.currency_code), 12, ' ')
            || LPAD (opex_rec.status, 13, ' ')
            || LPAD (opex_rec.NORMALIZE, 11, ' ')
               );
         put_output ('.         ');
         display_error_messages (ip_message_string => v_msg);

      END LOOP;

      IF v_counter = 0 THEN
         fnd_message.set_name ('PN','PN_RICAL_MSG');
         put_output (fnd_message.get||' :');
         display_error_messages (ip_message_string => 'PN_INDEX_NO_PAYT_TO_APPROVE');
      END IF;

      put_log('pn_opex_terms_pkg.approve_index_pay_term_batch (-) : ');

   END approve_opex_pay_term_batch;


/*===========================================================================+
 | FUNCTION
 |    GET_UNPAID_AMT
 |
 | DESCRIPTION
 |    Finds the unpaid amount for a reconciliation period
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: p_recon_id
 |
 | RETURNS    : NUMBER
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 |
 |   26-JUN-2007  sdmahesh    o Bug 6146157
 |                              Modified the unpaid amount calculation logic.
 |                              Added CSR_RECON_EXP_GRP
 +===========================================================================*/
FUNCTION get_unpaid_amt(p_recon_id  IN NUMBER) RETURN NUMBER
  IS

  CURSOR amt_cur(c_recon_id IN NUMBER) IS

    SELECT SUM(item.actual_amount)  act_amt
     FROM pn_payment_items_all item,
     pn_payment_terms_all term,
     pn_opex_recon_all recon
     WHERE item.payment_item_type_lookup_code = 'CASH'
     AND item.payment_term_id = term.payment_term_id
     AND term.opex_recon_id  = recon.recon_id
     AND recon.recon_id = c_recon_id ;

  CURSOR recon_cur(c_recon_id IN NUMBER) IS
    SELECT * FROM
    pn_opex_recon_all WHERE recon_id = c_recon_id;

  CURSOR recon_det_cur(c_recon_id IN NUMBER) IS
    SELECT NVL(expected_ovr , expected) AS amt FROM
    pn_opex_recon_details_all
    WHERE recon_id = c_recon_id
    AND  TYPE = '1PRP';

  CURSOR csr_recon_exp_grp(c_recon_id IN NUMBER) IS
    SELECT amount_st,
           recoverable_st
     FROM pn_opex_recon_exp_grp_all
     WHERE recon_id = c_recon_id;

    amt_rec amt_cur%ROWTYPE;
    recon_rec recon_cur%ROWTYPE;
    recon_det_rec recon_det_cur%ROWTYPE;

  unpaid_amount NUMBER;
  exp_grp_exst BOOLEAN := FALSE;


  BEGIN
    IF p_recon_id IS NULL THEN
       RETURN NULL;
    END IF;
    OPEN recon_cur(p_recon_id);
    FETCH recon_cur INTO recon_rec;

    OPEN amt_cur(p_recon_id);
    FETCH amt_cur INTO amt_rec;

    OPEN recon_det_cur(p_recon_id);
    FETCH recon_det_cur INTO recon_det_rec;

    FOR rec IN csr_recon_exp_grp(p_recon_id) LOOP
      IF rec.amount_st IS NOT NULL OR
         rec.recoverable_st IS NOT NULL THEN
         exp_grp_exst := TRUE;
         EXIT;
      END IF;
    END LOOP;

    IF recon_cur%ISOPEN THEN
      CLOSE recon_cur;
    END IF;
    IF amt_cur%ISOPEN THEN
      CLOSE amt_cur;
    END IF;
    IF recon_det_cur%ISOPEN THEN
      CLOSE recon_det_cur;
    END IF;
    IF csr_recon_exp_grp%ISOPEN THEN
      CLOSE csr_recon_exp_grp;
    END IF;

    IF recon_rec.amt_due_st IS NOT NULL AND exp_grp_exst THEN
      unpaid_amount := recon_rec.amt_due_st - NVL(amt_rec.act_amt,0);
      RETURN unpaid_amount;
    ELSIF recon_rec.st_amt_due IS NOT NULL THEN
      unpaid_amount := recon_rec.st_amt_due - NVL(amt_rec.act_amt,0) - NVL(recon_det_rec.amt,0);
      RETURN unpaid_amount;
    ELSE
     RETURN NULL;
    END IF;

    EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;

  END get_unpaid_amt;
END PN_OPEX_TERMS_PKG;

/
