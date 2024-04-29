--------------------------------------------------------
--  DDL for Package Body PNRX_RENT_INCREASE_DETAILACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNRX_RENT_INCREASE_DETAILACC" AS
/* $Header: PNRXADRB.pls 120.0 2007/10/03 14:25:27 rthumma noship $ */
   PROCEDURE rent_increase_detailacc (
      p_lease_number_low       IN              VARCHAR2 DEFAULT NULL,
      p_lease_number_high      IN              VARCHAR2 DEFAULT NULL,
      p_ri_number_low          IN              VARCHAR2 DEFAULT NULL,
      p_ri_number_high         IN              VARCHAR2 DEFAULT NULL,
      p_assess_date_from       IN              DATE,
      p_assess_date_to         IN              DATE,
      p_lease_class            IN              VARCHAR2 DEFAULT NULL,
      p_property_id            IN              NUMBER DEFAULT NULL,
      p_building_id            IN              NUMBER DEFAULT NULL,
      p_location_id            IN              NUMBER DEFAULT NULL,
      p_include_draft          IN              VARCHAR2 DEFAULT NULL,
      p_rent_type              IN              VARCHAR2 DEFAULT NULL,
      p_account_class          IN              VARCHAR2 DEFAULT NULL,
      p_set_of_books_id        IN              NUMBER DEFAULT NULL,
      p_chart_of_accounts_id   IN              NUMBER DEFAULT NULL,
      l_request_id             IN              NUMBER,
      l_user_id                IN              NUMBER,
      retcode                  OUT NOCOPY      VARCHAR2,
      errbuf                   OUT NOCOPY      VARCHAR2
   )
   IS
      l_login_id                   NUMBER;
      l_org_id                     NUMBER;
      l_lease_num                  VARCHAR2 (30);
      l_assess_date                VARCHAR2 (10);
      l_precision                  NUMBER;  -- slk
      l_ext_precision              NUMBER;  -- slk
      l_min_acct_unit              NUMBER;  -- slk
      l_vendor_rec                 pnrx_rent_increase_detail.vendor_rec;
      l_customer_rec               pnrx_rent_increase_detail.customer_rec;
      l_lease_detail               pnrx_rent_increase_detail.lease_detail;
      l_lease_detail_null          pnrx_rent_increase_detail.lease_detail;
      v_status                    VARCHAR2 (30) :='APPROVED';

      TYPE cur_typ IS REF CURSOR;

      c_lease_pn                   cur_typ;
      -- term_Rec      c_lease_pn%ROWTYPE;
      term_rec                     pn_rent_increase_detailacc_itf%ROWTYPE;
      term_rec_null                pn_rent_increase_detailacc_itf%ROWTYPE;
      query_str                    VARCHAR2 (20000);
      --declare the 'where clauses here........'
      lease_number_where_clause    VARCHAR2 (4000) := NULL;
      ri_number_where_clause       VARCHAR2 (4000) := NULL;
      lease_date_where_clause      VARCHAR2 (4000) := NULL;
      location_code_where          VARCHAR2 (4000) := NULL;
      lease_class_where            VARCHAR2 (4000) := NULL;
      account_class_where          VARCHAR2 (4000) := NULL;
      account_id_where             VARCHAR2 (4000) := NULL;
      rent_type_where              VARCHAR2 (4000) := NULL;
      property_name_where          VARCHAR2 (4000) := NULL;
      building_name_where          VARCHAR2 (4000) := NULL;
      location_code_from           VARCHAR2 (4000) := NULL;
      property_name_from           VARCHAR2 (4000) := NULL;
      building_name_from           VARCHAR2 (4000) := NULL;
      location_code_field          VARCHAR2 (4000) := NULL;
      include_draft_where          VARCHAR2 (4000) := NULL;
      l_get_gl_segments            BOOLEAN;
      l_gl_concatenated_segments   VARCHAR2 (240);
   --declare all columns as variables here

   -- declare cursors.....
        CURSOR cur_carry_forward
                   (p_index_lease_id IN pn_index_lease_periods_all.index_lease_id%TYPE,
                    p_l_precision IN  NUMBER) IS
         SELECT ROUND(carry_forward_amount, p_l_precision) carry_forward_amount,
                carry_forward_percent,
                ROUND (constraint_rent_due, p_l_precision) old_rent
           FROM pn_index_lease_periods_all
          WHERE index_lease_id = p_index_lease_id
            AND assessment_date =
                                   ADD_MONTHS (
                                               term_rec.ilp_assessment_date,
                                               -12 * term_rec.assessment_interval
                                               );


   BEGIN
      pnp_debug_pkg.put_log_msg ('pn_rentincdeta_where_cond_set(+)');

--Initialise status parameters...
      retcode := 0;
      errbuf := '';
      fnd_profile.get ('LOGIN_ID', l_login_id);

--SELECT Fnd_Profile.value('ORG_ID') INTO l_org_id
--FROM dual;

      l_org_id := TO_NUMBER (fnd_profile.VALUE ('ORG_ID'));

--lease number conditions.....
--lease_number_where_clause := 'AND l.lease_num = '||'''NE213142''';

      IF  p_lease_number_low IS NOT NULL
          AND p_lease_number_high IS NOT NULL
      THEN
         lease_number_where_clause :=    ' AND l.lease_num  BETWEEN '
                                      || ''''
                                      || p_lease_number_low
                                      || ''''
                                      || ' AND '
                                      || ''''
                                      || p_lease_number_high
                                      || '''';
      ELSIF  p_lease_number_low IS NULL
             AND p_lease_number_high IS NOT NULL
      THEN
         lease_number_where_clause :=
                     ' AND l.lease_num = ' || '''' || p_lease_number_high || '''';
      ELSIF  p_lease_number_low IS NOT NULL
             AND p_lease_number_high IS NULL
      THEN
         lease_number_where_clause :=
                      ' AND l.lease_num = ' || '''' || p_lease_number_low || '''';
      ELSE
         lease_number_where_clause := ' AND 4=4 ';
      END IF;

      IF  p_ri_number_low IS NOT NULL
          AND p_ri_number_high IS NOT NULL
      THEN
         ri_number_where_clause :=    ' AND il.index_lease_number  BETWEEN '
                                   || ''''
                                   || p_ri_number_low
                                   || ''''
                                   || ' AND '
                                   || ''''
                                   || p_ri_number_high
                                   || '''';
      ELSIF  p_ri_number_low IS NULL
             AND p_ri_number_high IS NOT NULL
      THEN
         ri_number_where_clause :=
              ' AND il.index_lease_number = ' || '''' || p_ri_number_high || '''';
      ELSIF  p_ri_number_low IS NOT NULL
             AND p_ri_number_high IS NULL
      THEN
         ri_number_where_clause :=
               ' AND il.index_lease_number = ' || '''' || p_ri_number_low || '''';
      ELSE
         ri_number_where_clause := ' AND 4=4 ';
      END IF;

      IF p_assess_date_from IS NOT NULL
      THEN
      	lease_date_where_clause :=    ' AND ilp.ASSESSMENT_DATE  BETWEEN '
                                   || ''''
                                   || p_assess_date_from
                                   || ''''
                                   || ' AND '
                                   || ''''
                                   || p_assess_date_to
                                   || '''';
      END IF;

     IF p_include_draft='N' OR p_include_draft IS NULL
      THEN
          include_draft_where  :=
                              ' AND it.status='
			      || ''''
			      || v_status
			      || '''';
      END IF;

      IF p_lease_class IS NOT NULL
      THEN
         lease_class_where :=
                    ' AND l.lease_class_code = ' || '''' || p_lease_class || '''';
      END IF;

      IF p_rent_type IS NOT NULL
      THEN
         rent_type_where :=
               ' AND it.PAYMENT_TERM_TYPE_CODE = ' || '''' || p_rent_type || '''';
      END IF;

      IF p_account_class IS NOT NULL
      THEN
         account_class_where :=
                  ' AND dist.ACCOUNT_CLASS = ' || '''' || p_account_class || '''';
      END IF;

      IF p_location_id IS NOT NULL
      THEN
         location_code_from :=
                              ', PN_TENANCIES_ALL ten , PN_LOCATIONS_ALL loc';
         location_code_where :=
                  ' AND l.lease_id = ten.lease_id
                           AND ten.location_id = loc.location_id
                     AND loc.rowid = (select max(loc1.rowid) from pn_locations_all loc1
                                   where loc.location_id = loc1.location_id)
                     AND ten.location_id = '
               || ''''
               || p_location_id
               || '''';
      END IF;

      IF p_property_id IS NOT NULL
      THEN
         property_name_from :=
                  ', PN_TENANCIES_ALL ten, (select bld.location_id, bld.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                             pn_properties_all    prop,
                                       pn_locations_all         bld
                                       WHERE
                                       bld.location_type_lookup_code IN ('
               || ''''
               || 'BUILDING'
               || ''''
               || ','
               || ''''
               || 'LAND'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)
                                       UNION
                                       select flr.location_id, flr.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                       pn_properties_all    prop,
                                       pn_locations_all         bld,
                                       pn_locations_all         flr
                                       WHERE  flr.location_type_lookup_code IN ('
               || ''''
               || 'FLOOR'
               || ''''
               || ','
               || ''''
               || 'PARCEL'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)     AND
                                       bld.location_id = flr.parent_location_id     AND
                                       ((flr.active_start_date BETWEEN bld.active_start_date AND
                                       bld.active_end_date)            OR (flr.active_end_date BETWEEN bld.active_start_date AND
                                       bld.active_end_date))
                                       UNION
                                       select off.location_id, off.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                       pn_properties_all    prop,
                                       pn_locations_all         bld,
                                       pn_locations_all         flr,
                                       pn_locations_all         off
                                       WHERE  off.location_type_lookup_code IN ('
               || ''''
               || 'OFFICE'
               || ''''
               || ','
               || ''''
               || 'SECTION'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)     AND
                                       flr.location_id = off.parent_location_id     AND
                                       bld.location_id = flr.parent_location_id     AND
                                       ((off.active_start_date BETWEEN flr.active_start_date AND
                                       flr.active_end_date)            OR (off.active_end_date BETWEEN flr.active_start_date AND
                                       flr.active_end_date)) ) loc';
         property_name_where :=
                  ' AND l.lease_id = ten.lease_id
                           AND ten.location_id = loc.location_id
                     AND loc.property_id = '
               || ''''
               || p_property_id
               || '''';
      END IF;

      IF p_building_id IS NOT NULL
      THEN
         building_name_from :=
                  ', PN_TENANCIES_ALL ten, (select bld.location_id, bld.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                             pn_properties_all    prop,
                                       pn_locations_all         bld
                                       WHERE
                                       bld.location_type_lookup_code IN ('
               || ''''
               || 'BUILDING'
               || ''''
               || ','
               || ''''
               || 'LAND'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)
                                       UNION
                                       select flr.location_id, flr.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                       pn_properties_all    prop,
                                       pn_locations_all         bld,
                                       pn_locations_all         flr
                                       WHERE  flr.location_type_lookup_code IN ('
               || ''''
               || 'FLOOR'
               || ''''
               || ','
               || ''''
               || 'PARCEL'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)     AND
                                       bld.location_id = flr.parent_location_id     AND
                                       ((flr.active_start_date BETWEEN bld.active_start_date AND
                                       bld.active_end_date)            OR (flr.active_end_date BETWEEN bld.active_start_date AND
                                       bld.active_end_date))
                                       UNION
                                       select off.location_id, off.location_type_lookup_code , bld.location_id building_id, prop.property_id FROM
                                       pn_properties_all    prop,
                                       pn_locations_all         bld,
                                       pn_locations_all         flr,
                                       pn_locations_all         off
                                       WHERE  off.location_type_lookup_code IN ('
               || ''''
               || 'OFFICE'
               || ''''
               || ','
               || ''''
               || 'SECTION'
               || ''''
               || ')     AND
                                       bld.property_id  = prop.property_id (+)     AND
                                       flr.location_id = off.parent_location_id     AND
                                       bld.location_id = flr.parent_location_id     AND
                                       ((off.active_start_date BETWEEN flr.active_start_date AND
                                       flr.active_end_date)            OR (off.active_end_date BETWEEN flr.active_start_date AND
                                       flr.active_end_date)) ) loc';
         building_name_where :=
                  ' AND l.lease_id = ten.lease_id
                           AND ten.location_id = loc.location_id
                     AND loc.building_id = '
               || ''''
               || p_building_id
               || '''';
      END IF;

      IF p_location_id IS NOT NULL
         OR p_property_id IS NOT NULL
         OR p_building_id IS NOT NULL
      THEN
         location_code_field :=
                         ',ten.location_id , loc.location_type_lookup_code  ';
      ELSE
         location_code_from :=
                              ', PN_TENANCIES_ALL ten , PN_LOCATIONS_ALL loc';
         location_code_where :=
               ' AND l.lease_id = ten.lease_id
                           AND ten.location_id = loc.location_id
                     AND loc.rowid = (select max(loc1.rowid) from pn_locations_all loc1
                                   where loc.location_id = loc1.location_id) ';
         location_code_field :=
                         ',ten.location_id , loc.location_type_lookup_code  ';
      END IF;

      IF p_location_id IS NOT NULL
      THEN
         building_name_from := NULL;
         building_name_where := NULL;
         property_name_from := NULL;
         property_name_where := NULL;
      ELSIF p_building_id IS NOT NULL
      THEN
         property_name_from := NULL;
         property_name_where := NULL;
      END IF;

      pnp_debug_pkg.put_log_msg ('pn_rentincdeta_where_cond_set(-)');

--lease cursor.....
      OPEN c_lease_pn FOR    'SELECT
   l.name         --2
  ,l.lease_num       --3
  ,l.payment_term_proration_rule --5
  ,l.abstracted_by_user           --6
  ,l.lease_class_code   --9
  ,ld.lease_commencement_date  --12
  ,ld.lease_termination_date     --13
  ,ld.lease_execution_date       --14
  ,ld.lease_extension_end_date
  ,it.payment_purpose_code        --16
  ,it.payment_term_type_code    --17
  ,it.frequency_code             --18
  ,it.start_date                 --19
  ,it. end_date                   --20
  ,it.vendor_id               --21
  ,it.vendor_site_id            --22
  ,it.target_date                --23
  ,it.actual_amount           --24
  ,it.estimated_amount          --25
  ,it.currency_code               --27
  ,it.rate                       --28
  ,it.customer_id               --29
  ,it.customer_site_use_id          --30
  ,it.normalize'
                          || location_code_field
                          || ',it.schedule_day
  ,it.cust_ship_site_id          --34
  ,it.ap_ar_term_id           --35
  ,it.cust_trx_type_id       --36
  ,it.project_id              --37
  ,it.task_id                     --38
  ,it.organization_id           --39
  ,it.expenditure_type      --40
  ,it.expenditure_item_date   --41
  ,it.inv_rule_id           --42
  ,it.account_rule_id           --43
  ,it.salesrep_id               --44
  ,it.status payterm_status       --45
  ,it.index_term_indicator       --47
  ,il.index_lease_id       --53
  ,il.index_id              --54
  ,il.commencement_date il_commencement_date --55
  ,il.termination_date il_termination_date      --56
  ,il.index_lease_number      --57
  ,il.assessment_date il_assessment_date  --58
  ,il.assessment_interval    --59
  ,il.spread_frequency       --60
  ,il.basis_percent_default --62
  ,il.initial_basis          --63
  ,il.base_index             --64
  ,il.index_finder_method     --66
  ,il.index_finder_months    --67
  ,il.negative_rent_type     --68
  ,il.increase_on            --69
  ,il.basis_type             --70
  ,il.reference_period      --71
  ,il.base_year              --72
  ,il.index_multiplier  -- slk
  ,il.proration_rule  -- slk
  ,ilp.assessment_date ilp_assessment_date --73
  ,ilp.basis_start_date         --74
  ,ilp.basis_end_date            --75
  ,ilp.index_finder_date         --76
  ,ilp.current_basis              --77
  ,ilp.relationship              --78
  ,ilp.index_percent_change      --79
  ,ilp.basis_percent_change       --80
  ,ilp.unconstraint_rent_due     --81
  ,ilp.constraint_rent_due       --82
  ,ilp.carry_forward_amount
  ,ilp.carry_forward_percent
  ,ilp.constraint_applied_amount
  ,ilp.constraint_applied_percent
  ,ilp.current_index_line_value
  ,ilp.previous_index_line_value
  ,dist.account_id
  ,dist.account_class
  ,dist.percentage
  ,it.approved_by
  ,it.po_header_id
  ,it.receipt_method_id
  ,it.tax_code_id
  ,it.tax_group_id
  ,it.tax_included
  ,it.include_in_var_rent  -- slk
FROM
pn_payment_terms_all it,
pn_leases_all        l,
pn_lease_details_all ld,
pn_index_leases  il ,
pn_distributions_all dist,
pn_index_lease_periods_all ilp'
                          || location_code_from
                          || property_name_from
                          || building_name_from
                          || ' WHERE it.lease_id = l.lease_id
AND l.lease_id = ld.lease_id
AND it.lease_id = il.lease_id
AND l.lease_id = il.lease_id
AND dist.payment_term_id = it.payment_term_id
AND it.index_period_id IS NOT NULL
AND ilp.index_lease_id = il.index_lease_id
AND ilp.index_period_id = it.index_period_id '
                          || lease_number_where_clause
                          || ri_number_where_clause
                          || lease_date_where_clause
                          || lease_class_where
                          || location_code_where
                          || property_name_where
                          || building_name_where
                          || account_class_where
                          || account_id_where
                          || rent_type_where
			  || include_draft_where;
      pnp_debug_pkg.put_log_msg ('pn_rentincdet_open_cursor(+)');

      LOOP --start lease loop....
         term_rec := term_rec_null;
         l_lease_detail := l_lease_detail_null;
         term_rec.creation_date := SYSDATE;
         term_rec.created_by := l_user_id;
         term_rec.last_update_date := SYSDATE;
         term_rec.last_updated_by := l_user_id;
         term_rec.last_update_login := l_user_id;
         term_rec.request_id := l_request_id;

         FETCH c_lease_pn INTO term_rec.name, --2
                               term_rec.lease_num, --3
                               term_rec.payment_term_proration_rule, --5
                               l_lease_detail.abstracted_by_user, --6
                               l_lease_detail.lease_class_code, --9
                               term_rec.lease_commencement_date, --12
                               term_rec.lease_termination_date, --13
                               term_rec.lease_execution_date, --14
			       term_rec.lease_extension_end_date,
                               l_lease_detail.payment_purpose_code, --16
                               l_lease_detail.payment_term_type_code, --17
                               l_lease_detail.frequency_code, --18
                               term_rec.start_date, --19
                               term_rec.end_date, --20
                               l_lease_detail.vendor_id, --21
                               l_lease_detail.vendor_site_id, --22
                               term_rec.target_date, --23
                               term_rec.actual_amount, --24
                               term_rec.estimated_amount, --25
                               term_rec.currency_code, --27
                               term_rec.rate, --28
                               l_lease_detail.customer_id, --29
                               l_lease_detail.customer_site_use_id, --30
                               term_rec.normalize, --31
                               l_lease_detail.location_id, --32
                               term_rec.location_type_lookup_code,
                               term_rec.schedule_day, --33
                               l_lease_detail.cust_ship_site_id, --34
                               l_lease_detail.ap_ar_term_id, --35
                               l_lease_detail.cust_trx_type_id, --36
                               l_lease_detail.project_id, --37
                               l_lease_detail.task_id, --38
                               l_lease_detail.organization_id, --39
                               term_rec.expenditure_type, --40
                               term_rec.expenditure_item_date, --41
                               l_lease_detail.inv_rule_id, --42
                               l_lease_detail.account_rule_id, --43
                               l_lease_detail.salesrep_id, --44
                               term_rec.payterm_status, --45
                               term_rec.index_term_indicator, --47
                               l_lease_detail.index_lease_id, --53
                               l_lease_detail.index_id,--54
                               term_rec.il_commencement_date,--55
                               term_rec.il_termination_date, --56
                               term_rec.index_lease_number, --57
                               term_rec.il_assessment_date, --58
                               term_rec.assessment_interval, --59
                               l_lease_detail.spread_frequency, --60
                               term_rec.basis_percent_default, --62
                               term_rec.initial_basis, --63
                               term_rec.base_index, --64
                               l_lease_detail.index_finder_method, --66
                               term_rec.index_finder_months, --67
                               l_lease_detail.negative_rent_type, --68
                               l_lease_detail.increase_on, --69
                               l_lease_detail.basis_type, --70
                               l_lease_detail.reference_period, --71
                               term_rec.base_year, --72
                               term_rec.index_multiplier,  -- slk
                               l_lease_detail.proration_rule,  -- slk
                               term_rec.ilp_assessment_date, --73
                               term_rec.basis_start_date, --74
                               term_rec.basis_end_date, --75
                               term_rec.index_finder_date, --76
                               term_rec.current_basis, --77
                               l_lease_detail.relationship, --78
                               term_rec.index_percent_change, --79
                               term_rec.basis_percent_change, --80
                               term_rec.unconstraint_rent_due, --81
                               term_rec.constraint_rent_due, --82
                               term_rec.carry_forward_amount,
                               term_rec.carry_forward_percent,
                               term_rec.constraint_applied_amount,
                               term_rec.constraint_applied_percent,
                               term_rec.current_index_line_value,
                               term_rec.previous_index_line_value,
                               l_lease_detail.account_id,
                               l_lease_detail.account_class,
                               term_rec.distribution_percentage,
                               l_lease_detail.approved_by,
                               l_lease_detail.po_header_id,
                               l_lease_detail.receipt_method_id,
                               l_lease_detail.tax_code_id,
                               l_lease_detail.tax_group_id,
                               term_rec.tax_included,
                               term_rec.include_in_var_rent;  -- slk

         EXIT WHEN c_lease_pn%NOTFOUND;

         pnp_debug_pkg.put_log_msg ('pn_rentincdet_get_details(+)');
         term_rec.abstracted_by_user_name :=
               pn_index_lease_common_pkg.get_approver (
                  l_lease_detail.abstracted_by_user
               );
         l_vendor_rec :=
              pnrx_rent_increase_detail.get_vendor (l_lease_detail.vendor_id);
         term_rec.vendor_name := l_vendor_rec.vendor_name;
         term_rec.supplier_number := l_vendor_rec.vendor_number;
         term_rec.vendor_site_code :=
               pnrx_rent_increase_detail.get_vendor_site (
                  l_lease_detail.vendor_site_id
               );
         l_customer_rec :=
               pnrx_rent_increase_detail.get_customer (
                  l_lease_detail.customer_id
               );
         term_rec.customer_name := l_customer_rec.customer_name;
         term_rec.customer_number := l_customer_rec.customer_number;
         term_rec.customer_bill_site :=
               pnrx_rent_increase_detail.get_customer_bill_site (
                  l_lease_detail.customer_site_use_id
               );
         term_rec.customer_ship_site :=
               pnrx_rent_increase_detail.get_customer_ship_site (
                  l_lease_detail.cust_ship_site_id
               );
         term_rec.account_rule_name :=
               pn_index_lease_common_pkg.get_accounting_rule (
                  l_lease_detail.account_rule_id
               );
         term_rec.index_name :=
               pnrx_rent_increase_detail.get_index_name (
                  l_lease_detail.index_id
               );
         term_rec.location_code :=
               pnrx_rent_increase_detail.get_location_code (
                  l_lease_detail.location_id
               );
         term_rec.project_number :=
               pnrx_rent_increase_detail.get_project_number (
                  l_lease_detail.project_id
               );
         term_rec.task_number :=
               pnrx_rent_increase_detail.get_task_number (
                  l_lease_detail.task_id
               );
         term_rec.organization_name :=
               pnp_util_func.get_ap_organization_name (
                  l_lease_detail.organization_id
               );

         IF l_lease_detail.vendor_id > 0
         THEN
            term_rec.ap_ar_term_name :=
                  pnp_util_func.get_ap_payment_term (
                     l_lease_detail.ap_ar_term_id
                  );
            term_rec.tax_code :=
                  pn_r12_util_pkg.get_ap_tax_code_name (
                     l_lease_detail.tax_code_id
                  );
            term_rec.account_class_meaning :=
                  pnrx_rent_increase_detail.get_lookup_meaning (
                     l_lease_detail.account_class,
                     'PN_PAY_ACCOUNT_TYPE'
                  );
         END IF;

         IF l_lease_detail.customer_id > 0
         THEN
            term_rec.ap_ar_term_name :=
                  pnp_util_func.get_ar_payment_term (
                     l_lease_detail.ap_ar_term_id
                  );
            term_rec.tax_code :=
                  pn_r12_util_pkg.get_ar_tax_code_name (
                     l_lease_detail.tax_code_id
                  );
            term_rec.account_class_meaning :=
                  pnrx_rent_increase_detail.get_lookup_meaning (
                     l_lease_detail.account_class,
                     'PN_REC_ACCOUNT_TYPE'
                  );
         END IF;

         term_rec.salesrep_name :=
                  pnp_util_func.get_salesrep_name (l_lease_detail.salesrep_id,l_org_id);
         term_rec.lease_class_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.lease_class_code,
                  'PN_LEASE_CLASS'
               );
         term_rec.increase_on_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.increase_on,
                  'PN_PAYMENT_TERM_TYPE'
               );
         term_rec.reference_period_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.reference_period,
                  'PN_INDEX_REF_PERIOD'
               );
         term_rec.negative_rent_type_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.negative_rent_type,
                  'PN_INDEX_NEGATIVE_RENT'
               );
         term_rec.relationship_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.relationship,
                  'PN_INDEX_RELATION'
               );
         term_rec.frequency_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.frequency_code,
                  'PN_PAYMENT_FREQUENCY_TYPE'
               );

	  term_rec.spread_frequency_meaning  :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.spread_frequency,
                  'PN_PAYMENT_FREQUENCY_TYPE'
               );

         term_rec.payment_purpose_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.payment_purpose_code,
                  'PN_PAYMENT_PURPOSE_TYPE'
               );
         term_rec.payment_term_type_meaning :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.payment_term_type_code,
                  'PN_PAYMENT_TERM_TYPE'
               );
         term_rec.area :=
               pnp_util_func.get_rentable_area (
                  term_rec.location_type_lookup_code,
                  l_lease_detail.location_id,
                  term_rec.ilp_assessment_date
               );
         term_rec.approved_by_name :=
               pn_index_lease_common_pkg.get_approver (
                  l_lease_detail.approved_by
               );
         term_rec.tax_group :=
               pn_r12_util_pkg.get_tax_group (
                  l_lease_detail.tax_group_id
               );
         term_rec.po_number :=
               pn_index_lease_common_pkg.get_po_number (
                  l_lease_detail.po_header_id
               );
         term_rec.payment_method :=
               pn_index_lease_common_pkg.get_receipt_method (
                  l_lease_detail.receipt_method_id
               );
         term_rec.cust_trx_type_name :=
               pn_index_lease_common_pkg.get_ar_trx_type (
                  l_lease_detail.cust_trx_type_id
               );
         term_rec.inv_rule_name :=
               pn_index_lease_common_pkg.get_invoicing_rule (
                  l_lease_detail.inv_rule_id
               );
         term_rec.gl_concatenated_segments :=
               fnd_flex_ext.get_segs (
                  'SQLGL',
                  'GL#',
                  p_chart_of_accounts_id,
                  l_lease_detail.account_id
               );
	  term_rec.constraint_proration :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                   l_lease_detail.proration_rule,
                  'PN_CONSTRAINT_PRORATION'
               );
	   term_rec.index_finder_method :=
               pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.index_finder_method,
                  'PN_INDEX_FINDER_METHOD'
               );
	    term_rec.basis_type :=
		pnrx_rent_increase_detail.get_lookup_meaning (
                  l_lease_detail.basis_type,
                  'PN_INDEX_BASIS_TYPE'
               );
	     term_rec.include_in_var_rent :=
	         pnrx_rent_increase_detail.get_lookup_meaning (
                  term_rec.include_in_var_rent,
                  'PN_PAYMENT_BKPT_BASIS_TYPE'
               );
         pnp_debug_pkg.put_log_msg ('pn_rentincdet_get_details(-)');

-- slk start
         fnd_currency.get_info (term_rec.currency_code,
                                l_precision,
                                l_ext_precision,
                                l_min_acct_unit);
-- slk end


      FOR rec_cur_carry_forward
         IN cur_carry_forward(l_lease_detail.index_lease_id,
                                                      l_precision)
          LOOP
            term_rec.open_carry_forward_amount := rec_cur_carry_forward.carry_forward_amount;
	    term_rec.open_carry_forward_percent := rec_cur_carry_forward.carry_forward_percent;
	    term_rec.old_rent := rec_cur_carry_forward.old_rent;
          END LOOP;


        BEGIN
	     SELECT    DECODE (
                               term_rec.frequency_meaning,
                               'Monthly', 12,
                               'Quarterly', 4,
                               'Semiannually', 2,
                               'Annually', 1,
                                1
                               ) * ROUND(NVL(term_rec.actual_amount,0), l_precision)
	       INTO    term_rec.annual
	       FROM    DUAL;
	  EXCEPTION
	    WHEN OTHERS THEN
	      NULL;
	  END;

         INSERT INTO pn_rent_increase_detailacc_itf
                     (name,
                      lease_num,
                      payment_term_proration_rule,
                      abstracted_by_user_name,
                      lease_class_meaning,
                      lease_commencement_date,
                      lease_termination_date,
                      lease_execution_date,
		      lease_extension_end_date,
                      payment_purpose_meaning,
                      payment_term_type_meaning,
                      frequency_meaning,
                      start_date,
                      end_date,
                      vendor_name,
                      supplier_number,
                      vendor_site_code,
                      target_date,
                      actual_amount,
                      estimated_amount,
                      currency_code,
                      rate,
                      customer_name,
                      customer_number,
                      customer_bill_site,
                      normalize,
                      location_code,
                      location_type_lookup_code,
                      schedule_day,
                      customer_ship_site,
                      ap_ar_term_name,
                      cust_trx_type_name,
                      project_number,
                      task_number,
                      organization_name,
                      expenditure_type,
                      expenditure_item_date,
                      inv_rule_name,
                      account_rule_name,
                      salesrep_name,
                      payterm_status,
                      index_term_indicator,
                      index_name,
                      il_commencement_date,
                      il_termination_date,
                      index_lease_number,
                      il_assessment_date,
                      assessment_interval,
		      spread_frequency_meaning,
                      basis_percent_default,
                      initial_basis,
                      base_index,
                      index_finder_method,
                      index_finder_months,
                      negative_rent_type_meaning,
                      increase_on_meaning,
                      basis_type,
                      reference_period_meaning,
                      base_year,
                      ilp_assessment_date,
                      basis_start_date,
                      basis_end_date,
                      index_finder_date,
                      current_basis,
                      relationship_meaning,
                      index_percent_change,
                      basis_percent_change,
                      unconstraint_rent_due,
                      constraint_rent_due,
                      carry_forward_amount,
                      carry_forward_percent,
                      constraint_applied_amount,
                      constraint_applied_percent,
		      open_carry_forward_amount,
		      open_carry_forward_percent,
		      app_carry_forward_amount,
		      app_carry_forward_percent,
		      old_rent,
		      new_rent,
		      change_rent,
                      current_index_line_value,
                      previous_index_line_value,
                      account_class_meaning,
                      distribution_percentage,
		      distribution_amount,
                      gl_concatenated_segments,
                      approved_by_name,
                      po_number,
                      payment_method,
                      tax_code,
                      tax_group,
                      tax_included,
		      annual,
                      area,
		      annual_area,
                      constraint_proration,  -- slk
                      index_multiplier,  -- slk
                      unadjusted_index_change,  -- slk
		      adjusted_index_change_percent,
                      include_in_var_rent,  -- slk
                      last_update_date,
                      last_updated_by,
                      creation_date,
                      created_by,
                      last_update_login,
                      request_id
                     )
              VALUES (term_rec.name,
                      term_rec.lease_num,
                      term_rec.payment_term_proration_rule,
                      term_rec.abstracted_by_user_name,
                      term_rec.lease_class_meaning,
                      term_rec.lease_commencement_date,
                      term_rec.lease_termination_date,
                      term_rec.lease_execution_date,
		      term_rec.lease_extension_end_date,
                      term_rec.payment_purpose_meaning,
                      term_rec.payment_term_type_meaning,
                      term_rec.frequency_meaning,
                      term_rec.start_date,
                      term_rec.end_date,
                      term_rec.vendor_name,
                      term_rec.supplier_number,
                      term_rec.vendor_site_code,
                      term_rec.target_date,
                      ROUND (term_rec.actual_amount, l_precision),  -- slk
                      ROUND (term_rec.estimated_amount, l_precision),  -- slk
                      term_rec.currency_code,
                      term_rec.rate,
                      term_rec.customer_name,
                      term_rec.customer_number,
                      term_rec.customer_bill_site,
                      term_rec.normalize,
                      term_rec.location_code,
                      term_rec.location_type_lookup_code,
                      term_rec.schedule_day,
                      term_rec.customer_ship_site,
                      term_rec.ap_ar_term_name,
                      term_rec.cust_trx_type_name,
                      term_rec.project_number,
                      term_rec.task_number,
                      term_rec.organization_name,
                      term_rec.expenditure_type,
                      term_rec.expenditure_item_date,
                      term_rec.inv_rule_name,
                      term_rec.account_rule_name,
                      term_rec.salesrep_name,
                      term_rec.payterm_status,
                      term_rec.index_term_indicator,
                      term_rec.index_name,
                      term_rec.il_commencement_date,
                      term_rec.il_termination_date,
                      term_rec.index_lease_number,
                      term_rec.il_assessment_date,
                      term_rec.assessment_interval,
		      term_rec.spread_frequency_meaning,
                      term_rec.basis_percent_default,
                      ROUND (term_rec.initial_basis, l_precision),  -- slk
                      term_rec.base_index,
                      term_rec.index_finder_method,
                      term_rec.index_finder_months,
                      term_rec.negative_rent_type_meaning,
                      term_rec.increase_on_meaning,
                      term_rec.basis_type,
                      term_rec.reference_period_meaning,
                      term_rec.base_year,
                      term_rec.ilp_assessment_date,
                      term_rec.basis_start_date,
                      term_rec.basis_end_date,
                      term_rec.index_finder_date,
                      ROUND (term_rec.current_basis, l_precision),  -- slk
                      term_rec.relationship_meaning,
                      term_rec.index_percent_change,
                      term_rec.basis_percent_change,
                      ROUND (term_rec.unconstraint_rent_due, l_precision),  -- slk
                      ROUND (term_rec.constraint_rent_due, l_precision),  -- slk
                      ROUND (term_rec.carry_forward_amount, l_precision),  -- slk
                      term_rec.carry_forward_percent,
                      ROUND (term_rec.constraint_applied_amount, l_precision),  -- slk
                      term_rec.constraint_applied_percent,
		      term_rec.open_carry_forward_amount,
		      term_rec.open_carry_forward_percent,
		      NVL (term_rec.open_carry_forward_amount, 0) - NVL (term_rec.carry_forward_amount, 0),
		      NVL (term_rec.open_carry_forward_percent, 0) - NVL (term_rec.carry_forward_percent, 0),
		      term_rec.old_rent,
		      ROUND (term_rec.constraint_rent_due, l_precision),
		      NVL (term_rec.constraint_rent_due, 0) - NVL (term_rec.old_rent, 0),
                      term_rec.current_index_line_value,
                      term_rec.previous_index_line_value,
                      term_rec.account_class_meaning,
                      term_rec.distribution_percentage,
		      ((ROUND (term_rec.actual_amount, l_precision) * term_rec.distribution_percentage) / 100),
                      term_rec.gl_concatenated_segments,
                      term_rec.approved_by_name,
                      term_rec.po_number,
                      term_rec.payment_method,
                      term_rec.tax_code,
                      term_rec.tax_group,
                      term_rec.tax_included,
		      term_rec.annual,
                      term_rec.area,
		      DECODE (NVL (term_rec.area, 0), 0, 0, ROUND ((term_rec.annual / term_rec.area), 10)),
                      term_rec.constraint_proration,  -- slk
                      term_rec.index_multiplier,  -- slk
		      term_rec.index_percent_change,
                      term_rec.index_percent_change * NVL (term_rec.index_multiplier, 1),  -- slk
                      term_rec.include_in_var_rent,  -- slk
                      term_rec.last_update_date,
                      term_rec.last_updated_by,
                      term_rec.creation_date,
                      term_rec.created_by,
                      term_rec.last_update_login,
                      term_rec.request_id
                     );

         pnp_debug_pkg.put_log_msg ('pn_rentincdet_insert(-)');

      END LOOP; --end lease loop...

      pnp_debug_pkg.put_log_msg ('pn_rentincdet_open_cursor(-)');

   EXCEPTION
      WHEN OTHERS
      THEN
         retcode := 2;
         errbuf := SUBSTR (SQLERRM, 1, 235);
         RAISE;
         COMMIT;
   END rent_increase_detailacc;
END pnrx_rent_increase_detailacc;

/
