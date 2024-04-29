--------------------------------------------------------
--  DDL for Package Body PER_RU_CURRENCY_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RU_CURRENCY_CONVERSION" as
/* $Header: perucurr.pkb 120.2.12010000.1 2008/10/01 07:14:26 parusia noship $ */
--
  PROCEDURE currency_rur_to_rub
             (errbuf               OUT NOCOPY VARCHAR2
             ,retcode              OUT NOCOPY NUMBER
             ,p_business_group_id  IN  NUMBER
             ,p_conv_curr_code     IN  VARCHAR2
             ) IS

  CURSOR get_all_bgs( cp_old_currency VARCHAR2, cp_new_currency VARCHAR2 ) IS
    SELECT hoi.organization_id, hou.name
      FROM hr_organization_units hou,
           hr_organization_information hoi,
           hr_organization_information hoi1
     WHERE hoi.org_information_context  = 'Business Group Information'
       AND hoi.org_information9         = 'RU'
       AND hoi.org_information10        in (cp_old_currency, cp_new_currency)
       AND hou.organization_id          = hoi.organization_id
       AND hou.organization_id          = hoi1.organization_id
       AND hoi1.org_information_context = 'CLASS'
       AND hoi1.org_information1        = 'HR_BG'
       AND hoi1.org_information2        = 'Y'
       AND NOT EXISTS ( SELECT 1
                          FROM pay_patch_status pps
                         WHERE pps.patch_number = to_char(hoi.organization_id)
                           AND pps.patch_name = 'Currency_Conversion_for_Russia'
                           AND pps.legislation_code = 'RU'
                           AND pps.status = 'C' );

  CURSOR c_pay_gl_interface ( cp_business_group_id NUMBER ) IS
    SELECT pgi.assignment_action_id
      FROM pay_gl_interface pgi
          ,pay_payroll_actions ppa
     WHERE ppa.business_group_id     = cp_business_group_id
       AND pgi.run_payroll_action_id = ppa.payroll_action_id;

  CURSOR c_legi_ele_tmplt IS
    SELECT template_id
      FROM pay_element_templates
     WHERE legislation_code = 'RU';

  CURSOR c_bg_ele_tmplt( cp_business_group_id NUMBER ) IS
    SELECT template_id
      FROM pay_element_templates
     WHERE business_group_id = cp_business_group_id;

  CURSOR c_ben_chc_popl( cp_business_group_id NUMBER ) IS
    SELECT rowid
      FROM ben_pil_elctbl_chc_popl
     WHERE business_group_id = cp_business_group_id;

  CURSOR c_ben_elig_per( cp_business_group_id NUMBER ) IS
    SELECT rowid
      FROM ben_elig_per_f
     WHERE business_group_id = cp_business_group_id;

    ln_business_group_id       NUMBER;
    lv_business_group_name     VARCHAR2(400);

    ln_legislation_done        NUMBER;
    ln_commit_cnt              NUMBER;
    lv_old_currency            VARCHAR2(10);
    lv_new_currency            VARCHAR2(10);
    ln_ota_act_ver_count       NUMBER;

  BEGIN

    ln_legislation_done := 0;
    lv_old_currency     := 'RUR';
    lv_new_currency     := 'RUB';

    OPEN  get_all_bgs( lv_old_currency, lv_new_currency );
    LOOP
      FETCH get_all_bgs INTO ln_business_group_id
                            ,lv_business_group_name;
      EXIT WHEN get_all_bgs%NOTFOUND;

      IF ln_legislation_done = 0 THEN

         UPDATE pay_balance_types
            SET currency_code    = lv_new_currency
          WHERE legislation_code = 'RU'
            AND currency_code    = lv_old_currency;

         UPDATE pay_element_types_f
            SET input_currency_code    = decode(input_currency_code,
                                                lv_old_currency,
                                                lv_new_currency,
                                                input_currency_code )
               ,output_currency_code   = decode(output_currency_code,
                                                lv_old_currency,
                                                lv_new_currency,
                                                output_currency_code )
          WHERE legislation_code       = 'RU'
            AND ( input_currency_code  = lv_old_currency OR
                  output_currency_code = lv_old_currency );

         UPDATE pay_legislation_rules
            SET rule_mode        = lv_new_currency
          WHERE legislation_code = 'RU'
            AND rule_type        = 'DC'
            AND rule_mode        = lv_old_currency;

         UPDATE pay_leg_setup_defaults
            SET currency_code    = lv_new_currency
          WHERE legislation_code = 'RU'
            AND currency_code    = lv_old_currency;

         UPDATE pay_monetary_units
            SET currency_code    = lv_new_currency
          WHERE legislation_code = 'RU'
            AND currency_code    = lv_old_currency;

         UPDATE pay_payment_types
            SET currency_code  = lv_new_currency
          WHERE territory_code = 'RU'
            AND currency_code  = lv_old_currency;

         UPDATE pay_pss_transaction_steps
            SET currency_code  = lv_new_currency
          WHERE territory_code = 'RU'
            AND currency_code  = lv_old_currency;

         UPDATE pqp_exception_reports
            SET currency_code    = lv_new_currency
          WHERE legislation_code = 'RU'
            AND currency_code    = lv_old_currency;

         FOR tmplt IN c_legi_ele_tmplt
         LOOP

           UPDATE pay_shadow_balance_types
              SET currency_code = lv_new_currency
            WHERE template_id   = tmplt.template_id
              AND currency_code = lv_old_currency;

           UPDATE pay_shadow_element_types
              SET input_currency_code    = decode(input_currency_code,
                                                  lv_old_currency,
                                                  lv_new_currency,
                                                  input_currency_code )
                 ,output_currency_code   = decode(output_currency_code,
                                                  lv_old_currency,
                                                  lv_new_currency,
                                                  output_currency_code )
            WHERE template_id   = tmplt.template_id
              AND ( input_currency_code  = lv_old_currency OR
                    output_currency_code = lv_old_currency );

         END LOOP;

         ln_legislation_done := 1;

      END IF;

      /* PAY_BALANCE_TYPES */

      UPDATE pay_balance_types
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PAY_ELEMENT_TYPES_F */

      UPDATE pay_element_types_f
         SET input_currency_code    = decode(input_currency_code,
                                             lv_old_currency,
                                             lv_new_currency,
                                             input_currency_code )
            ,output_currency_code   = decode(output_currency_code,
                                             lv_old_currency,
                                             lv_new_currency,
                                             output_currency_code )
       WHERE business_group_id      = ln_business_group_id
         AND ( input_currency_code  = lv_old_currency OR
               output_currency_code = lv_old_currency );

      /* PAY_MONETARY_UNITS  */

      UPDATE pay_monetary_units
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PAY_ORG_PAYMENT_METHODS_F */

      UPDATE pay_org_payment_methods_f
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PER_QUALIFICATIONS  */

      UPDATE per_qualifications
         SET fee_currency      = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND fee_currency      = lv_old_currency;

      /* PER_RECRUITMENT_ACTIVITIES */

      UPDATE per_recruitment_activities
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PER_WORK_INCIDENTS */

      UPDATE per_work_incidents pwi
         SET compensation_currency = lv_new_currency
       WHERE compensation_currency = lv_old_currency
         AND EXISTS ( SELECT 1
                        FROM per_all_people_f ppf
                       WHERE ppf.person_id = pwi.person_id
                         AND ppf.business_group_id = ln_business_group_id );

      /* PER_SALARY_SURVEY_LINES */

      UPDATE per_salary_survey_lines
         SET currency_code     = lv_new_currency
       WHERE currency_code     = lv_old_currency;

      /* PQH_ACCOMMODATIONS_F */

      UPDATE pqh_accommodations_f
         SET rental_value_currency = lv_new_currency
       WHERE business_group_id     = ln_business_group_id
         AND rental_value_currency = lv_old_currency;

      /* PQH_ASSIGN_ACCOMMODATIONS_F */

      UPDATE pqh_assign_accommodations_f
         SET indemnity_currency = lv_new_currency
       WHERE business_group_id  = ln_business_group_id
         AND indemnity_currency = lv_old_currency;

      /* PQH_FR_VALIDATIONS */

      UPDATE pqh_fr_validations
         SET deduction_currency_code = decode( deduction_currency_code,
                                               lv_old_currency,
                                               lv_new_currency,
                                               deduction_currency_code )
            ,employee_currency_code  = decode( employee_currency_code,
                                               lv_old_currency,
                                               lv_new_currency,
                                               employee_currency_code )
            ,employer_currency_code  = decode( employer_currency_code,
                                               lv_old_currency,
                                               lv_new_currency,
                                               employer_currency_code )
       WHERE business_group_id = ln_business_group_id
         AND (  deduction_currency_code = lv_old_currency OR
                employee_currency_code  = lv_old_currency OR
                employer_currency_code  = lv_old_currency );

      /* PQH_BUDGETS */

      UPDATE pqh_budgets
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PQP_EXCEPTION_REPORTS */

      UPDATE pqp_exception_reports
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PQP_VEHICLE_REPOSITORY_F */

      UPDATE pqp_vehicle_repository_f
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PQP_VEHICLE_DETAILS */

      UPDATE pqp_vehicle_details
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PSP_ADJUSTMENT_CONTROL_TABLE */

      UPDATE psp_adjustment_control_table
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PSP_DISTRIBUTION_INTERFACE */

      UPDATE psp_distribution_interface
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PSP_PAYROLL_CONTROLS */

      UPDATE psp_payroll_controls
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PSP_PAYROLL_INTERFACE */

      UPDATE psp_payroll_interface
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* BEN_ACTL_PREM_F */

      UPDATE ben_actl_prem_f
         SET uom         = decode( uom, lv_old_currency, lv_new_currency, uom )
            ,cr_lkbk_uom = decode( cr_lkbk_uom, lv_old_currency,
                                                lv_new_currency, cr_lkbk_uom )
       WHERE business_group_id = ln_business_group_id
         AND ( uom = lv_old_currency OR cr_lkbk_uom = lv_old_currency );

      /* BEN_BNFTS_BAL_F */

      UPDATE ben_bnfts_bal_f
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_CNTNG_PRTN_ELIG_PRFL_F */

      UPDATE ben_cntng_prtn_elig_prfl_f
         SET pymt_must_be_rcvd_uom = lv_new_currency
       WHERE business_group_id     = ln_business_group_id
         AND pymt_must_be_rcvd_uom = lv_old_currency;

      /* BEN_CNTNG_PRTN_PRFL_RT_F */

      UPDATE ben_cntng_prtn_prfl_rt_f
         SET pymt_must_be_rcvd_uom = lv_new_currency
       WHERE business_group_id     = ln_business_group_id
         AND pymt_must_be_rcvd_uom = lv_old_currency;

      /* BEN_DRVBL_FCTR_UOM */

      UPDATE ben_drvbl_fctr_uom
         SET uom_cd            = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom_cd            = lv_old_currency;

      /* BEN_ENRT_PREM_RBV */

      UPDATE ben_enrt_prem_rbv
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_PGM_F */

      UPDATE ben_pgm_f
         SET pgm_uom           = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND pgm_uom           = lv_old_currency;

      /* BEN_PIL_EPE_POPL_RBV */

      UPDATE ben_pil_epe_popl_rbv
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_PL_FRFS_VAL_F */

      UPDATE ben_pl_frfs_val_f
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_PRTT_ENRT_RSLT_F_RBV */

      UPDATE ben_prtt_enrt_rslt_f_rbv
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_PRTT_PREM_F */

      UPDATE ben_prtt_prem_f
         SET std_prem_uom      = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND std_prem_uom      = lv_old_currency;

      /* BEN_PRTT_REIMBMT_RQST_F */

      UPDATE ben_prtt_reimbmt_rqst_f
         SET rqst_amt_uom      = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND rqst_amt_uom      = lv_old_currency;

      /* BEN_PRTT_PREM_BY_MO_F */

      UPDATE ben_prtt_prem_by_mo_f
         SET antcpd_prtt_cntr_uom = lv_new_currency
       WHERE business_group_id    = ln_business_group_id
         AND antcpd_prtt_cntr_uom = lv_old_currency;

      /* BEN_COMP_LVL_FCTR */

      UPDATE ben_comp_lvl_fctr
         SET comp_lvl_uom      = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND comp_lvl_uom      = lv_old_currency;

      /* BEN_PL_R_OIPL_PREM_BY_MO_F */

      UPDATE ben_pl_r_oipl_prem_by_mo_f
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_PL_F */

      UPDATE BEN_PL_F
         SET nip_pl_uom        = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND nip_pl_uom        = lv_old_currency;

      /* BEN_PL_BNF_F */

      UPDATE ben_pl_bnf_f
         SET amt_dsgd_uom      = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND amt_dsgd_uom      = lv_old_currency;

      /* BEN_PL_R_OIPL_ASSET_F */

      UPDATE ben_pl_r_oipl_asset_f
         SET mkt_val_uom       = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND mkt_val_uom       = lv_old_currency;

      /* BEN_CRT_ORDR */

      UPDATE ben_crt_ordr
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* BEN_ENRT_PREM */

      UPDATE ben_enrt_prem
         SET uom               = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND uom               = lv_old_currency;

      /* IRC_ALL_RECRUITING_SITES */

      UPDATE irc_all_recruiting_sites
         SET posting_cost_currency = lv_new_currency
       WHERE posting_cost_currency = lv_old_currency;

      /* IRC_SEARCH_CRITERIA */

      UPDATE irc_search_criteria
         SET salary_currency = lv_new_currency
       WHERE salary_currency = lv_old_currency;

      /* OTA_ACTIVITY_VERSIONS */

      SELECT count(*)
        INTO ln_ota_act_ver_count
        FROM ota_activity_versions
       WHERE budget_currency_code = lv_old_currency;
      IF ln_ota_act_ver_count > 0
      THEN
         UPDATE ota_activity_versions
            SET budget_currency_code = lv_new_currency
          WHERE budget_currency_code = lv_old_currency;
      END IF;

      /* OTA_EVENTS */

      UPDATE ota_events
         SET budget_currency_code = decode( budget_currency_code,
                                            lv_old_currency,
                                            lv_new_currency,
                                            budget_currency_code)
            ,currency_code        = decode( currency_code,
                                            lv_old_currency,
                                            lv_new_currency,
                                            currency_code)
       WHERE business_group_id    = ln_business_group_id
         AND ( budget_currency_code = lv_old_currency OR
               currency_code        = lv_old_currency );

      /* OTA_PRICE_LISTS */

      UPDATE ota_price_lists
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* OTA_SUPPLIABLE_RESOURCES */

      UPDATE ota_suppliable_resources
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* OTA_TRAINING_PLANS */

      UPDATE ota_training_plans
         SET budget_currency   = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND budget_currency   = lv_old_currency;

      /* OTA_TRAINING_PLAN_COSTS */

      UPDATE ota_training_plan_costs
         SET currency_code     = lv_new_currency
       WHERE business_group_id = ln_business_group_id
         AND currency_code     = lv_old_currency;

      /* PAY_GL_INTERFACE */

      ln_commit_cnt := 0;

      FOR paygl IN c_pay_gl_interface( ln_business_group_id )
      LOOP

        UPDATE pay_gl_interface
           SET currency_code        = lv_new_currency
         WHERE assignment_action_id = paygl.assignment_action_id
           AND currency_code        = lv_old_currency;

        ln_commit_cnt := ln_commit_cnt + 1;

        IF ln_commit_cnt >= 100 THEN
           commit;
           ln_commit_cnt := 0;
        END IF;

      END LOOP;

      /* PAY SHADOW SCHEMA */

      FOR ele_tmplt IN c_bg_ele_tmplt( ln_business_group_id )
      LOOP

        UPDATE pay_shadow_balance_types
           SET currency_code = lv_new_currency
         WHERE template_id   = ele_tmplt.template_id
           AND currency_code = lv_old_currency;

        UPDATE pay_shadow_element_types
           SET input_currency_code    = decode(input_currency_code,
                                               lv_old_currency,
                                               lv_new_currency,
                                               input_currency_code )
              ,output_currency_code   = decode(output_currency_code,
                                               lv_old_currency,
                                               lv_new_currency,
                                               output_currency_code )
         WHERE template_id   = ele_tmplt.template_id
           AND ( input_currency_code  = lv_old_currency OR
                 output_currency_code = lv_old_currency );

      END LOOP;

      /* BEN_PIL_ELCTBL_CHC_POPL */

      ln_commit_cnt := 0;

      FOR chc IN c_ben_chc_popl( ln_business_group_id )
      LOOP

        UPDATE ben_pil_elctbl_chc_popl
           SET uom   = lv_new_currency
         WHERE rowid = chc.rowid
           AND uom   = lv_old_currency;

        ln_commit_cnt := ln_commit_cnt + 1;

        IF ln_commit_cnt >= 100 THEN
           commit;
           ln_commit_cnt := 0;
        END IF;

      END LOOP;

      /* BEN_ELIG_PER_F */

      ln_commit_cnt := 0;

      FOR elig IN c_ben_elig_per( ln_business_group_id )
      LOOP

        UPDATE ben_elig_per_f
           SET rt_comp_ref_uom = lv_new_currency
         WHERE rowid           = elig.rowid
           AND rt_comp_ref_uom = lv_old_currency;

        ln_commit_cnt := ln_commit_cnt + 1;

        IF ln_commit_cnt >= 100 THEN
           commit;
           ln_commit_cnt := 0;
        END IF;

      END LOOP;

      /* HR_ORGANIZATION_INFORMATION */

      UPDATE hr_organization_information
         SET org_information10       = lv_new_currency
       WHERE organization_id         = ln_business_group_id
         AND org_information_context = 'Business Group Information'
         AND org_information10       = lv_old_currency;

      INSERT INTO pay_patch_status
                  (id, patch_number, patch_name, applied_date, status,
                   description, update_date, legislation_code)
      VALUES      (pay_patch_status_s.nextval, to_char(ln_business_group_id),
                   'Currency_Conversion_for_Russia', sysdate, 'C',
                   lv_business_group_name,  sysdate, 'RU');

    END LOOP;

    CLOSE get_all_bgs;

    --COMMIT;

    EXCEPTION
    WHEN others THEN
         raise;

  END currency_rur_to_rub;


  FUNCTION get_converted_curr_code ( p_business_group_id NUMBER )
    RETURN VARCHAR2 IS

    ln_conv_curr_cnt  NUMBER;
    lv_conv_curr_code VARCHAR2(80);

  BEGIN

    SELECT count(*)
      INTO ln_conv_curr_cnt
      FROM hr_organization_units hou,
           hr_organization_information hoi,
           hr_organization_information hoi1
     WHERE hoi.org_information_context  = 'Business Group Information'
       AND hoi.org_information9         = 'RU'
       AND hoi.org_information10        = 'RUR'
       AND hou.organization_id          = hoi.organization_id
       AND hou.organization_id          = hoi1.organization_id
       AND hoi1.org_information_context = 'CLASS'
       AND hoi1.org_information1        = 'HR_BG'
       AND hoi1.org_information2        = 'Y';

    IF ln_conv_curr_cnt = 0 THEN

       lv_conv_curr_code := 'CONVERTED';

    ELSE

       lv_conv_curr_code := 'CONVERTING';

    END IF;

    RETURN lv_conv_curr_code;

  END get_converted_curr_code;

END PER_RU_CURRENCY_CONVERSION ;

/
