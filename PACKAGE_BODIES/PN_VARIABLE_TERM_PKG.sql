--------------------------------------------------------
--  DDL for Package Body PN_VARIABLE_TERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VARIABLE_TERM_PKG" AS
-- $Header: PNVTERMB.pls 120.17.12010000.3 2009/12/24 07:09:51 jsundara ship $

-------------------------------------------------------------------------------
-- PROCEDURE : create_payment_term_batch
-- DESCRIPTION: This procedure is called by the payment term
--              creation concurrent program.
--
-- 15-AUG-02 dthota  o Changes for Mass Calculate Variable Rent.
--                     Added p_period_date parameter to
--                     create_payment_term_batch, CURSOR csr_for_inv,
--                     CURSOR csr_act_inv,CURSOR csr_var_inv.
-- 09-Jan-03 dthota  o Changed p_period_date to VARCHAR2 from DATE in
--                     create_payment_term_batch,CURSOR csr_for_inv,
--                     CURSOR csr_act_inv,CURSOR csr_var_inv and added
--                     fnd_date.canonical_to_date before p_period_date
--                     in the WHERE clauses of the cursors.
--                     Fix for bug # 2733870
-- 21-Oct-04 vmmehta o Bug# 3942264. Added code to reset term_status if term
--                     creation fails for actual/forecasted/variance terms.
-- 26-Oct-06 Shabda  o Changed cursor csr_var_inv to accomodate true_ups
-- 12-DEC-07 acprakas o Bug#6490896. Modified to create reversal terms for
--                   	invoices created for reversal.
-- 24-DEC-09 jsundara o BUg#9094493. If the profile option PN_VAR_VOL_INV_PRD is set,
--                      make a call to find_volume_continuous only if VR termination date is > invoice date

-------------------------------------------------------------------------------

PROCEDURE create_payment_term_batch(
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_lease_num_from      IN  VARCHAR2,
        p_lease_num_to        IN  VARCHAR2,
        p_location_code_from  IN  VARCHAR2,
        p_location_code_to    IN  VARCHAR2,
        p_vrent_num_from      IN  VARCHAR2,
        p_vrent_num_to        IN  VARCHAR2,
        p_period_num_from     IN  NUMBER,
        p_period_num_to       IN  NUMBER,
        p_responsible_user    IN  NUMBER,
        p_period_id           IN  NUMBER,
        p_org_id              IN  NUMBER,
        p_period_date         IN  VARCHAR2
) IS
CURSOR csr_get_vrent_wloc IS
SELECT  pvr.lease_id,
        pvr.var_rent_id,
        pvr.rent_num,
        pvr.invoice_on,
        pvr.location_id,
        pvr.currency_code,
        pvr.term_template_id,
        per.period_id,
        per.period_num,
        pl.lease_class_code,
        pl.org_id
FROM    pn_leases             pl,
        pn_lease_details_all  pld,
        pn_var_rents_all      pvr,
        pn_locations_all      ploc,
        pn_var_periods_all    per
WHERE  pl.lease_id = pvr.lease_id
AND    pld.lease_id = pvr.lease_id
AND    ploc.location_id = pvr.location_id
AND    pvr.var_rent_id = per.var_rent_id
AND    pl.lease_num >= nvl(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= nvl(p_lease_num_to, pl.lease_num)
AND    ploc.location_code >= nvl(p_location_code_from, ploc.location_code)
AND    ploc.location_code <= nvl(p_location_code_to, ploc.location_code)
AND    pvr.rent_num >= nvl(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= nvl(p_vrent_num_to,pvr.rent_num)
AND    per.period_num >= nvl(p_period_num_from,per.period_num)
AND    per.period_num <= nvl(p_period_num_to,period_num)
AND    pld.responsible_user = nvl(p_responsible_user, pld.responsible_user)
AND   (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id, pvr.var_rent_id,per.period_num;

CURSOR csr_get_vrent_woloc IS
SELECT pvr.lease_id,
       pvr.var_rent_id,
       pvr.rent_num,
       pvr.invoice_on,
       pvr.location_id,
       pvr.currency_code,
       pvr.term_template_id,
       per.period_id,
       per.period_num,
       pl.lease_class_code,
       pl.org_id
FROM   pn_var_rents_all      pvr,
       pn_leases             pl,
       pn_lease_details_all  pld,
       pn_var_periods_all    per
WHERE  pl.lease_id = pvr.lease_id
AND    pld.lease_id = pvr.lease_id
AND    pvr.var_rent_id = per.var_rent_id
AND    pl.lease_num >= nvl(p_lease_num_from, pl.lease_num)
AND    pl.lease_num <= nvl(p_lease_num_to, pl.lease_num)
AND    pvr.rent_num >= nvl(p_vrent_num_from,pvr.rent_num)
AND    pvr.rent_num <= nvl(p_vrent_num_to,pvr.rent_num)
AND    per.period_num >= nvl(p_period_num_from,per.period_num)
AND    per.period_num <= nvl(p_period_num_to,period_num)
AND    pld.responsible_user = nvl(p_responsible_user, pld.responsible_user)
AND    per.period_id = nvl(p_period_id,per.period_id)
AND   (pl.org_id = p_org_id or p_org_id is null)
ORDER BY pl.lease_id,pvr.var_rent_id,per.period_num;

/* Get the forecasted amounts */

CURSOR csr_for_inv(ip_period_id NUMBER)
IS
SELECT var_rent_id,
       var_rent_inv_id,
       invoice_date,
       for_per_rent,
       period_id
FROM pn_var_rent_inv_all
WHERE period_id = ip_period_id
AND adjust_num = 0
AND nvl(for_per_rent,0) <> 0
AND forecasted_exp_code = 'N'
AND forecasted_term_status = decode(p_period_id,null,'N','Y')
AND pn_variable_amount_pkg.find_if_term_exists(var_rent_inv_id,'FORECASTED') ='N'
AND invoice_date <= nvl(fnd_date.canonical_to_date(p_period_date),to_date('12/31/4712','mm/dd/yyyy'))
ORDER BY invoice_date;

/* Get the actual rent amounts */

CURSOR csr_act_inv(ip_period_id NUMBER)
IS
SELECT var_rent_id,
       var_rent_inv_id,
       invoice_date,
       adjust_num,
       actual_invoiced_amount,
       period_id,
       credit_flag
FROM pn_var_rent_inv_all
WHERE period_id = ip_period_id
AND actual_exp_code = 'N'
AND nvl(actual_invoiced_amount,0) <> 0
AND actual_term_status = decode(p_period_id,null,'N','Y')
AND pn_variable_amount_pkg.find_if_term_exists(var_rent_inv_id,'ACTUAL') ='N'
AND invoice_date <= nvl(fnd_date.canonical_to_date(p_period_date),to_date('12/31/4712','mm/dd/yyyy'))
ORDER BY invoice_date;

/* get the actual-forecasted rent amounts */

CURSOR csr_var_inv(ip_period_id NUMBER)
IS
SELECT inv.var_rent_id,
       inv.var_rent_inv_id,
       inv.adjust_num,
       inv.invoice_date,
       inv.period_id,
       decode(inv.adjust_num,0,(inv.actual_invoiced_amount-NVL(inv.for_per_rent,0)),
                                inv.actual_invoiced_amount) act_for_amt
FROM pn_var_rent_inv_all inv
WHERE inv.period_id = ip_period_id
AND inv.variance_exp_code = 'N'
AND nvl(decode(inv.adjust_num,0,(inv.actual_invoiced_amount-NVL(inv.for_per_rent,0)),
                                 inv.actual_invoiced_amount),0) <> 0
AND inv.variance_term_status = decode(p_period_id,null,'N','Y')
AND not exists (SELECT null
                FROM pn_var_grp_dates_all gd
                WHERE gd.invoice_date = inv.invoice_date
                AND gd.period_id = inv.period_id
                AND gd.var_rent_id = inv.var_rent_id
                AND nvl(gd.forecasted_exp_code,'N') = 'N')
AND pn_variable_amount_pkg.find_if_term_exists(inv.var_rent_inv_id,'VARIANCE') = 'N'
AND invoice_date <= nvl(fnd_date.canonical_to_date(p_period_date),to_date('12/31/4712','mm/dd/yyyy'))
ORDER BY inv.invoice_date;

  CURSOR payment_cur(p_invoice_date DATE,p_var_rent_id NUMBER) IS
      SELECT payment_term_id
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id IN (SELECT var_rent_inv_id
                                FROM pn_var_rent_inv_all
                                WHERE invoice_date = p_invoice_date
                                AND var_rent_id = p_var_rent_id);


l_rent_num        pn_var_rents.rent_num%type;
l_invoice_on      pn_var_rents.invoice_on%type;
l_period_id       pn_var_periods.period_id%type;
l_period_num      pn_var_periods.period_num%type;
l_lease_id        pn_var_rents.lease_id%type;
l_location_id     pn_var_rents.location_id%type;
l_var_rent_id     pn_var_rents.var_rent_id%type;
l_pre_var_rent_id pn_var_rents.var_rent_id%type;
l_context         VARCHAR2(2000);
l_errmsg          VARCHAR2(2000);
l_org_id          pn_leases.org_id%type;
l_term_temp_id    pn_payment_terms.term_template_id%TYPE;
l_lease_cls_code  pn_leases.lease_class_code%TYPE;
l_err_flag        VARCHAR2(1);
l_inv_sch_date    DATE;
l_inv_start_date  DATE;
term_count NUMBER;
err_flag   BOOLEAN := FALSE;
l_trmn_dt DATE;  /* 9094493 */

BEGIN
        pn_variable_amount_pkg.put_log('pn_variable_term_pkg.create_payment_term_batch (+)' );

        fnd_message.set_name ('PN','PN_VTERM_INP');
        fnd_message.set_token ('TO_NUM',p_lease_num_to);
        fnd_message.set_token ('FROM_NUM',p_lease_num_from);
        fnd_message.set_token ('FROM_CODE',p_location_code_from);
        fnd_message.set_token ('TO_CODE',p_location_code_to);
        fnd_message.set_token ('VRN_FROM',p_vrent_num_from);
        fnd_message.set_token ('VRN_TO',p_vrent_num_to);
        fnd_message.set_token ('PRD_FROM',p_period_num_from);
        fnd_message.set_token ('PRD_TO',p_period_num_to);
        fnd_message.set_token ('USR',p_responsible_user);
        pnp_debug_pkg.put_log_msg(fnd_message.get);


        /* Retrieve operating unit attributes and stores them in the cache */
        l_context := 'Retreiving operating unit attributes';

        --pn_mo_global_cache.populate;


        /* Checking Location Code From, Location Code To to open appropriate cursor */

        IF p_location_code_from IS NOT NULL or p_location_code_to IS NOT NULL THEN
           OPEN csr_get_vrent_wloc;
        ELSE
           OPEN csr_get_vrent_woloc;
        END IF;

        l_pre_var_rent_id := NULL;
        LOOP

           IF csr_get_vrent_wloc%ISOPEN THEN
              FETCH csr_get_vrent_wloc INTO l_lease_id, l_var_rent_id, l_rent_num,
                                        l_invoice_on, l_location_id,
                                        g_currency_code, l_term_temp_id,
                                        l_period_id, l_period_num,
                                        l_lease_cls_code, l_org_id;
              EXIT WHEN csr_get_vrent_wloc%NOTFOUND;
           ELSIF csr_get_vrent_woloc%ISOPEN THEN
              FETCH csr_get_vrent_woloc INTO l_lease_id, l_var_rent_id, l_rent_num,
                                        l_invoice_on, l_location_id,
                                        g_currency_code, l_term_temp_id,
                                        l_period_id, l_period_num,
                                        l_lease_cls_code, l_org_id;
              EXIT WHEN csr_get_vrent_woloc%NOTFOUND;
           END IF;


       IF l_var_rent_id <> NVL(l_pre_var_rent_id,-9999) THEN
          l_err_flag := 'N';
          l_pre_var_rent_id := l_var_rent_id;

          IF NOT pnp_util_func.validate_term_template(p_term_temp_id   => l_term_temp_id,
                                                      p_lease_cls_code => l_lease_cls_code) THEN

             l_err_flag := 'Y';
             fnd_message.set_name ('PN', 'PN_MISS_TERM_TEMP_DATA');
             l_errmsg := fnd_message.get;
             pn_variable_amount_pkg.put_output(l_errmsg);

             fnd_message.set_name ('PN','PN_SOI_VRN');
             fnd_message.set_token ('NUM',l_rent_num);
             pnp_debug_pkg.put_log_msg(fnd_message.get);

          END IF;
       END IF;

       IF l_err_flag = 'N' THEN

          pn_variable_amount_pkg.put_output ('+---------------------------------------------------------------+');
          fnd_message.set_name ('PN','PN_RICAL_PROC');
          pnp_debug_pkg.put_log_msg(fnd_message.get||' ...');

          fnd_message.set_name ('PN','PN_SOI_VRN');
          fnd_message.set_token ('NUM',l_rent_num);
          pnp_debug_pkg.put_log_msg(fnd_message.get);

          fnd_message.set_name ('PN','PN_VTERM_PRD_NUM');
          fnd_message.set_token ('NUM',l_period_num);
          pnp_debug_pkg.put_log_msg(fnd_message.get);

          IF l_invoice_on = 'FORECASTED' THEN

             l_context := 'opening csr_for_inv';

             FOR rec_for_inv in csr_for_inv(l_period_id) LOOP

                 fnd_message.set_name ('PN','PN_VTERM_FORC_TRM');
                 pnp_debug_pkg.put_log_msg(fnd_message.get||' ...');

                 err_flag := FALSE;

                 /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date
                                 (inv_start_date => rec_for_inv.invoice_date
                                            ,vr_id => l_var_rent_id
                                            ,approved_status => 'N');  */

                 l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date(rec_for_inv.invoice_date,l_var_rent_id,l_period_id);
                 fnd_message.set_name ('PN','PN_SOI_INV_DT');
                 fnd_message.set_token ('DATE',l_inv_sch_date);
                 pnp_debug_pkg.put_log_msg(fnd_message.get);

                 fnd_message.set_name ('PN','PN_VTERM_FORC_RENT');
                 fnd_message.set_token ('RENT',round(rec_for_inv.for_per_rent,2));
                 pnp_debug_pkg.put_log_msg(fnd_message.get);


                 l_context := 'Checking if volume exists for all group dates and line items';

                 IF pn_variable_amount_pkg.find_volume_exists(rec_for_inv.period_id,
                                                              rec_for_inv.invoice_date,
                                                              'FORECASTED')='N' THEN

                    fnd_message.set_name('PN','PN_VAR_VOL_HIST');
                    l_errmsg := fnd_message.get;
                    pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                    pn_variable_amount_pkg.put_output(l_errmsg);
                    pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');
                    errbuf := l_errmsg;


                 ELSE

                  IF NVL(fnd_profile.value('PN_VAR_VOL_INV_PRD'),'N')='Y'  THEN
                    IF pn_variable_term_pkg.find_volume_continuous_for(rec_for_inv.var_rent_id,
                                                                   rec_for_inv.period_id,
                                                                   rec_for_inv.invoice_date,
                                                                   'FORECASTED'
                                                                   ) = 'N' THEN
                        fnd_message.set_name('PN','PN_VOL_INV_PRD');
                        l_errmsg := fnd_message.get;
                        pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                        pn_variable_amount_pkg.put_output(l_errmsg);
                        pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');
                        errbuf := l_errmsg;

                        err_flag := TRUE;

                    END IF;
                   END IF;

                    IF (NOT err_flag) THEN
                    l_context:='Creating Forecasted Payment term';

                    savepoint create_terms;
                    create_payment_terms(p_lease_id           => l_lease_id
                                        ,p_period_id          => rec_for_inv.period_id
                                        ,p_payment_amount     => rec_for_inv.for_per_rent
                                        ,p_invoice_date       => rec_for_inv.invoice_date
                                        ,p_var_rent_id        => rec_for_inv.var_rent_id
                                        ,p_var_rent_inv_id    => rec_for_inv.var_rent_inv_id
                                        ,p_location_id        => l_location_id
                                        ,p_var_rent_type      => 'FORECASTED'
                                        ,p_org_id             => l_org_id );

                    -- Check if term exists and set forecasted_term_status accordingly.

                    term_count := 0;

                    SELECT count(*) INTO term_count
                    FROM pn_payment_terms_all
                    WHERE var_rent_inv_id = rec_for_inv.var_rent_inv_id
                    AND var_rent_type = 'FORECASTED';

                    IF term_count > 0 THEN
                       UPDATE pn_var_rent_inv_all
                       SET    forecasted_term_status='Y',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_for_inv.var_rent_inv_id;
                    ELSE
                       pn_variable_amount_pkg.put_log('term not found ...');
                       UPDATE pn_var_rent_inv_all
                       SET    forecasted_term_status='N',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_for_inv.var_rent_inv_id;
                    END IF;

                    END IF;

                 END IF;
             END LOOP;

             l_context :='opening csr_var_inv';

             FOR rec_var_inv in csr_var_inv(l_period_id) LOOP
                 fnd_message.set_name ('PN','PN_VTERM_FORC_TRM');
                 pnp_debug_pkg.put_log_msg(fnd_message.get||' ...');

                 err_flag := FALSE;
                 /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date
                                 (inv_start_date => rec_var_inv.invoice_date
                                            ,vr_id => l_var_rent_id
                                            ,approved_status => 'N');  */

                 l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date(rec_var_inv.invoice_date,l_var_rent_id,l_period_id);
                 fnd_message.set_name ('PN','PN_SOI_INV_DT');
                 fnd_message.set_token ('DATE',l_inv_sch_date);
                 pnp_debug_pkg.put_log_msg(fnd_message.get);

                 l_context := 'Checking if volume exists for all group dates and line items';

                 IF pn_variable_amount_pkg.find_volume_exists(rec_var_inv.period_id,
                                                              rec_var_inv.invoice_date,
                                                              'ACTUAL')='N' THEN

                    fnd_message.set_name('PN','PN_VAR_VOL_HIST');
                    l_errmsg := fnd_message.get;
                    pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                    pn_variable_amount_pkg.put_output(l_errmsg);
                    pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');
                    errbuf := l_errmsg;

                 ELSE

                  IF NVL(fnd_profile.value('PN_VAR_VOL_INV_PRD'),'N')='Y' THEN
                   IF pn_variable_term_pkg.find_volume_continuous_for(rec_var_inv.var_rent_id,
                                                                  rec_var_inv.period_id,
                                                                  rec_var_inv.invoice_date,
                                                                  'ACTUAL'
                                                                  ) = 'N' THEN
                        fnd_message.set_name('PN','PN_VOL_INV_PRD');
                        l_errmsg := fnd_message.get;
                        pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                        pn_variable_amount_pkg.put_output(l_errmsg);
                        pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');
                        errbuf := l_errmsg;

                        err_flag := TRUE;

                    END IF;
                   END IF;

                    IF (NOT err_flag) THEN

                    pn_variable_amount_pkg.put_output('Actual-Forecasted Amount   :'||round(rec_var_inv.act_for_amt,2));
                    l_context :='Creating Variance Payment term';

                    savepoint create_terms;

                    create_payment_terms(p_lease_id           => l_lease_id
                                        ,p_period_id          => rec_var_inv.period_id
                                        ,p_payment_amount     => rec_var_inv.act_for_amt
                                        ,p_invoice_date       => rec_var_inv.invoice_date
                                        ,p_var_rent_id        => rec_var_inv.var_rent_id
                                        ,p_var_rent_inv_id    => rec_var_inv.var_rent_inv_id
                                        ,p_location_id        => l_location_id
                                        ,p_var_rent_type      => 'VARIANCE'
                                        ,p_org_id             => l_org_id );

                    -- Check if term exists and set variance_term_status accordingly.

                    term_count := 0;

                    SELECT count(*) INTO term_count
                    FROM pn_payment_terms_all
                    WHERE var_rent_inv_id = rec_var_inv.var_rent_inv_id
                    AND var_rent_type = 'VARIANCE';

                    IF term_count > 0 THEN
                       UPDATE pn_var_rent_inv_all
                       SET    variance_term_status='Y',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_var_inv.var_rent_inv_id;

                       UPDATE pn_var_rent_inv_all
                       SET    true_up_status = 'Y'
                       WHERE var_rent_inv_id = rec_var_inv.var_rent_inv_id
                       AND   true_up_status IS NOT NULL;

                    ELSE
                       pn_variable_amount_pkg.put_log('term not found ...');
                       UPDATE pn_var_rent_inv_all
                       SET    variance_term_status='N',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_var_inv.var_rent_inv_id;

                       UPDATE pn_var_rent_inv_all
                       SET    true_up_status = 'N'
                       WHERE var_rent_inv_id = rec_var_inv.var_rent_inv_id
                       AND   true_up_status IS NOT NULL;

                    END IF;

                    END IF;

                 END IF;
             END LOOP;
          END IF;  -- IF l_invoice_on = 'FORECASTED'

          IF l_invoice_on = 'ACTUAL' THEN

             l_context :='opening csr_act_inv';
             FOR rec_act_inv in csr_act_inv(l_period_id) LOOP

                 fnd_message.set_name ('PN','PN_VTERM_AFORC_TRM');
                 pnp_debug_pkg.put_log_msg(fnd_message.get);

                 err_flag := FALSE;

                 l_inv_sch_date := pn_var_rent_calc_pkg.inv_sch_date(rec_act_inv.invoice_date,l_var_rent_id,l_period_id);
                 fnd_message.set_name ('PN','PN_SOI_INV_DT');
                 fnd_message.set_token ('DATE',l_inv_sch_date);
                 pnp_debug_pkg.put_log_msg(fnd_message.get);

                 l_context := 'Checking if volume exists for all group dates and line items';

                 IF pn_variable_amount_pkg.find_volume_exists(rec_act_inv.period_id,
                                                              rec_act_inv.invoice_date,
                                                              'ACTUAL')='N'         THEN
                    fnd_message.set_name('PN','PN_VAR_VOL_HIST');
                    l_errmsg := fnd_message.get;
                    pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                    pn_variable_amount_pkg.put_output(l_errmsg);
                    pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');


                 ELSE

                   IF NVL(fnd_profile.value('PN_VAR_VOL_INV_PRD'),'N')='Y' and (l_trmn_dt >= rec_act_inv.invoice_date) THEN  /* 9094493 */
                    IF pn_variable_term_pkg.find_volume_continuous(rec_act_inv.var_rent_id,
                                                                   rec_act_inv.period_id,
                                                                   rec_act_inv.invoice_date
                                                                   ) = 'N' THEN
                        fnd_message.set_name('PN','PN_VOL_INV_PRD');
                        l_errmsg := fnd_message.get;
                        pn_variable_amount_pkg.put_output('+-----------------------------------------------------------+');
                        pn_variable_amount_pkg.put_output(l_errmsg);
                        pn_variable_amount_pkg.put_output('+------------------------------------------------------------+');
                        errbuf := l_errmsg;

                        err_flag := TRUE;

                    END IF;
                   END IF;

                    IF (NOT err_flag) THEN

                    pn_variable_amount_pkg.put_output('Actual Amount          :'|| round(rec_act_inv.actual_invoiced_amount,2));
                    l_context :='Creating Actual Payment term';

                    savepoint create_terms;

		 IF NVL(rec_act_inv.credit_flag,'N') = 'N' THEN

                    create_payment_terms(p_lease_id           => l_lease_id
                                        ,p_period_id          => rec_act_inv.period_id
                                        ,p_payment_amount     => rec_act_inv.actual_invoiced_amount
                                        ,p_invoice_date       => rec_act_inv.invoice_date
                                        ,p_var_rent_id        => rec_act_inv.var_rent_id
                                        ,p_var_rent_inv_id    => rec_act_inv.var_rent_inv_id
                                        ,p_location_id        => l_location_id
                                        ,p_var_rent_type      => 'ACTUAL'
                                        ,p_org_id             => l_org_id );

                    -- Check if term exists and set actual_term_status accordingly.

                    term_count := 0;

                    SELECT count(*) INTO term_count
                    FROM pn_payment_terms_all
                    WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id
                    AND var_rent_type = 'ACTUAL';

                    IF term_count > 0 THEN
                       UPDATE pn_var_rent_inv_all
                       SET    actual_term_status='Y',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id;

                       UPDATE pn_var_rent_inv_all
                       SET    true_up_status = 'Y'
                       WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id
                       AND   true_up_status IS NOT NULL;

                    ELSE
                       pn_variable_amount_pkg.put_log('term not found ...');
                       UPDATE pn_var_rent_inv_all
                       SET    actual_term_status='N',
                              last_update_date = SYSDATE,
                              last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                              last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                       WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id;

                       UPDATE pn_var_rent_inv_all
                       SET    true_up_status = 'N'
                       WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id
                       AND   true_up_status IS NOT NULL;
                    END IF;
	 ELSE

	     FOR payment_rec IN payment_cur(rec_act_inv.invoice_date,rec_act_inv.var_rent_id) LOOP
               pn_variable_term_pkg.create_reversal_terms(p_payment_term_id => payment_rec.payment_term_id
                                                         ,p_var_rent_inv_id => rec_act_inv.var_rent_inv_id
                                                         ,p_var_rent_type   => 'ADJUSTMENT');
              UPDATE pn_var_rent_inv_all
              SET    actual_term_status='Y',
                     last_update_date = SYSDATE,
                     last_update_login = NVL(fnd_profile.value('LOGIN_ID'),0),
                     last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
              WHERE var_rent_inv_id = rec_act_inv.var_rent_inv_id
	      AND actual_term_status='N' ;

	     END LOOP;

	 END IF;  --NVL(rec_act_inv.credit_flag,'N') = 'N'
                    END IF;
                 END IF;
             END LOOP;
          END IF; -- If l_invoice_on is ACTUAL
       END IF; -- If l_err_flag = 'N'
    END LOOP;

pn_variable_amount_pkg.put_log('pn_variable_term_pkg.create_payment_term_batch (-) : ');

EXCEPTION

When OTHERS Then
pn_variable_amount_pkg.put_log(substrb('Error in create_payment_term_batch - ' || to_char(sqlcode)
                                       ||' : ' ||sqlerrm|| ' - '|| l_context,1,244));
Errbuf  := SQLERRM;
Retcode := 2;
rollback;
raise;

END create_payment_term_batch;


-------------------------------------------------------------------------------
-- PROCEDURE : create_payment_terms
-- Procedure for creation of variable rent payment terms.
--
-- 31-Jan-02           o Fix for bug# 2208196. Pass value for normalized flag
--                       as 'Y'to procedure pnt_payment_terms_pkg.insert_row.
-- 22-Feb-02           o Added parameter x_calling_form in the call to
--                       pnt_payment_terms_cpg.
-- 28-Jun-02           o Added parameter p_org_id for shared serv.
--                       Enhancement.
-- 18-SEP-02  ftanudja o changed call from fnd_profile.value('PN_SET_OF..')
--                       to pn_mo_cache_utils.get_profile_value('PN_SET_OF..')
-- 14-JUN-04  abanerje o Modified call to pnt_payment_terms_pkg.insert_row
--                       to populate the term_template_id also. Bug#3657130.
-- 15-SEP-04  atuppad  o In the call pnt_payment_terms_pkg.insert_row,
--                       corrected the code to copy the payment DFF into
--                       payment DFF of new VR term and not in AR Projects DFF
--                       Bug # 3841542
-- 21-APR-05  ftanudja o Added area_type_code, area defaulting. #4324777
-- 15-JUL-05  ftanudja o R12 changes: add logic for tax_clsfctn_code. #4495054
-- 21-JUN-05  hareesha o Bug 4284035 - Replaced pn_var_rents, pn_distributions,
--                       pn_term_templates, pn_leases with _ALL table.
-- 23-NOV-05  pikhar   o Passed org_id in pn_mo_cache_utils.get_profile_value
-- 13-DEC-05  rdonthul o Changed the l_payment_term_date for bug 5700403
-- 15-MAR-07  pikhar   o Bug 5930387. Added include_in_var_rent
-------------------------------------------------------------------------------

PROCEDURE create_payment_terms(
      p_lease_id               IN       NUMBER
     ,p_period_id              IN       NUMBER
     ,p_payment_amount         IN       NUMBER
     ,p_invoice_date           IN       DATE
     ,p_var_rent_id            IN       NUMBER
     ,p_var_rent_inv_id        IN       NUMBER
     ,p_location_id            IN       NUMBER
     ,p_var_rent_type          IN       VARCHAR2
     ,p_org_id                 IN       NUMBER
   ) IS

l_lease_class_code         pn_leases.lease_class_code%TYPE;
l_distribution_id          pn_distributions.distribution_id%TYPE;
l_payment_term_id          pn_payment_terms.payment_term_id%TYPE;
l_lease_change_id          pn_lease_details.lease_change_id%TYPE;
l_rowid                    ROWID;
l_distribution_count       NUMBER  := 0;
l_inv_start_date           DATE;
l_payment_start_date       DATE;
l_payment_end_date         DATE;
l_frequency                pn_payment_terms.frequency_code%type;
l_schedule_day             pn_payment_terms.schedule_day%type;
l_set_of_books_id          gl_sets_of_books.set_of_books_id%type;
l_context                  varchar2(2000);
l_area                     pn_payment_terms.area%TYPE;
l_area_type_code           pn_payment_terms.area_type_code%TYPE;
l_org_id                   NUMBER;
l_schedule_day_char        VARCHAR2(8);
l_payment_status_lookup_code  pn_payment_schedules_all.payment_status_lookup_code%type;
i_cnt                      number;

CURSOR csr_distributions (p_var_rent_id   IN   NUMBER)
IS
SELECT *
FROM pn_distributions_all
WHERE term_template_id = (SELECT term_template_id
                          FROM pn_var_rents_all
                          WHERE var_rent_id = p_var_rent_id);

CURSOR csr_template (p_var_rent_id   IN   NUMBER)
IS
SELECT *
FROM pn_term_templates_all
WHERE term_template_id = (SELECT term_template_id
                          FROM pn_var_rents_all
                          WHERE var_rent_id = p_var_rent_id);

CURSOR currency_code_cur IS
  SELECT currency_code
  FROM pn_var_rents_all
  WHERE var_rent_id = p_var_rent_id;

rec_template pn_term_templates_all%ROWTYPE;
term_count NUMBER := 0;
l_currency_code  pn_var_rents_all.currency_code%TYPE;
--l_global_rec pn_mo_cache_utils.GlobalsRecord;

-- Get the details of
/*CURSOR invoice_date_c IS
  SELECT DISTINCT inv_start_date
    FROM pn_var_grp_dates_all
   WHERE var_rent_id = p_var_rent_id
     AND invoice_date = p_invoice_date;*/


BEGIN

pn_variable_amount_pkg.put_log ('pn_variable_term_pkg.create_payment_terms  :   (+)');

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
             pn_variable_amount_pkg.put_log ('Cannot Get Main Lease Details - TOO_MANY_ROWS');
        WHEN NO_DATA_FOUND THEN
             pn_variable_amount_pkg.put_log ('Cannot Get Main Lease Details - NO_DATA_FOUND');
        WHEN OTHERS THEN
             pn_variable_amount_pkg.put_log ('Cannot Get Main Lease Details - Unknown Error:'|| SQLERRM);
        END;


        --pn_variable_amount_pkg.put_log ('create_payment_terms  - multi_org_flag  :'||
                                         --mo_utils.get_multi_org_flag);
        pn_variable_amount_pkg.put_log ('create_payment_terms  - Org id          :'||p_org_id);


        l_context := 'Getting set of books id';

        --IF mo_utils.get_multi_org_flag = 'Y'  THEN
           --l_global_rec   := pn_mo_global_cache.get_org_attributes(p_org_id);
        --ELSE
           --l_global_rec   := pn_mo_global_cache.get_org_attributes(-3115);
        --END IF;


        --l_set_of_books_id := l_global_rec.set_of_books_id;
        l_set_of_books_id := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID'
                                                                            ,l_org_id));


        pn_variable_amount_pkg.put_log ('create_payment_terms  - Currency Code   :'||g_currency_code);
        pn_variable_amount_pkg.put_log ('create_payment_terms  - Set of books id :'||l_set_of_books_id);


        l_context := 'opening cursor csr_template';

        OPEN csr_template(p_var_rent_id);
        FETCH csr_template INTO rec_template;
        CLOSE csr_template;


       IF l_lease_class_code = 'DIRECT' THEN

        /* lease is of class: DIRECT */

         rec_template.customer_id := NULL;
         rec_template.customer_site_use_id := NULL;
         rec_template.cust_ship_site_id := NULL;
         rec_template.cust_trx_type_id := NULL;
         rec_template.inv_rule_id := NULL;
         rec_template.account_rule_id := NULL;
         rec_template.salesrep_id := NULL;
         rec_template.cust_po_number := NULL;
         rec_template.receipt_method_id := NULL;
      ELSE

        /* lease is 'sub-lease' or third-party */

         rec_template.project_id := NULL;
         rec_template.task_id := NULL;
         rec_template.organization_id := NULL;
         rec_template.expenditure_type := NULL;
         rec_template.expenditure_item_date := NULL;
         rec_template.vendor_id := NULL;
         rec_template.vendor_site_id := NULL;
         rec_template.tax_group_id := NULL;
         rec_template.distribution_set_id := NULL;
         rec_template.po_header_id := NULL;
      END IF;

      IF pn_r12_util_pkg.is_r12 THEN
         rec_template.tax_group_id := null;
         rec_template.tax_code_id := null;
      ELSE
         rec_template.tax_classification_code := null;
      END IF;

     /* Derive the payment start date */

      l_context := 'Getting payment term start date';

      BEGIN

      /*SELECT distinct inv_schedule_date
      INTO  l_payment_start_date
      FROM pn_var_grp_dates_all
      WHERE period_id = p_period_id
      AND invoice_date = p_invoice_date;*/
      --
   --   FOR rec IN invoice_date_c LOOP
         /*l_inv_start_date := pn_var_rent_calc_pkg.inv_start_date(inv_start_date => p_invoice_date
                                                                  ,vr_id => p_var_rent_id
                                                                  ,approved_status => 'N');  */

         l_payment_start_date := pn_var_rent_calc_pkg.inv_sch_date(inv_start_date => p_invoice_date
                                                                  ,vr_id => p_var_rent_id
                                                                  ,p_period_id => p_period_id);
     -- END LOOP;

      EXCEPTION
      WHEN TOO_MANY_ROWS THEN
             pn_variable_amount_pkg.put_log('Cannot Get Payment term start date- TOO_MANY_ROWS');
      WHEN NO_DATA_FOUND THEN
             pn_variable_amount_pkg.put_log('Cannot Get Payment term start date- NO_DATA_FOUND');
      WHEN OTHERS THEN
             pn_variable_amount_pkg.put_log('Cannot Get Payment term start date- Unknown Error:'|| SQLERRM);
      END;



   /* Derive the payment end date,schedule_day and frequency*/

      l_context := 'Setting payment end date,frequency and schedule day';

      l_payment_end_date := l_payment_start_date;
      l_frequency        := 'OT';
      l_schedule_day     := to_char(l_payment_start_date,'dd');

      IF p_location_id IS NOT NULL AND
         l_payment_start_date IS NOT NULL THEN

          l_area_type_code := pn_mo_cache_utils.get_profile_value('PN_AREA_TYPE',l_org_id);
          l_area := pnp_util_func.fetch_tenancy_area(
                       p_lease_id       => p_lease_id,
                       p_location_id    => p_location_id,
                       p_as_of_date     => l_payment_start_date,
                       p_area_type_code => l_area_type_code);

      END IF;

      l_context := 'Inserting into pn_payment_terms';

      FOR rec IN currency_code_cur LOOP
        l_currency_code := rec.currency_code;
      END LOOP;

      pnt_payment_terms_pkg.insert_row (
            x_rowid                       => l_rowid
           ,x_payment_term_id             => l_payment_term_id
           ,x_index_period_id             => null
           ,x_index_term_indicator        => null
           ,x_var_rent_inv_id             => p_var_rent_inv_id
           ,x_var_rent_type               => p_var_rent_type
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => rec_template.payment_purpose_code
           ,x_payment_term_type_code      => rec_template.payment_term_type_code
           ,x_frequency_code              => l_frequency
           ,x_lease_id                    => p_lease_id
           ,x_lease_change_id             => l_lease_change_id
           ,x_start_date                  => l_payment_start_date
           ,x_end_date                    => l_payment_end_date
           ,x_set_of_books_id             => NVL(rec_template.set_of_books_id,l_set_of_books_id)
           --,x_currency_code             => NVL(rec_template.currency_code, l_currency_code)
           ,x_currency_code               => NVl(g_currency_code, l_currency_code)
           ,x_rate                        => 1 -- not used in application
           ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
           ,x_vendor_id                   => rec_template.vendor_id
           ,x_vendor_site_id              => rec_template.vendor_site_id
           ,x_target_date                 => NULL
           ,x_actual_amount               => p_payment_amount
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => rec_template.attribute_category
           ,x_attribute1                  => rec_template.attribute1
           ,x_attribute2                  => rec_template.attribute2
           ,x_attribute3                  => rec_template.attribute3
           ,x_attribute4                  => rec_template.attribute4
           ,x_attribute5                  => rec_template.attribute5
           ,x_attribute6                  => rec_template.attribute6
           ,x_attribute7                  => rec_template.attribute7
           ,x_attribute8                  => rec_template.attribute8
           ,x_attribute9                  => rec_template.attribute9
           ,x_attribute10                 => rec_template.attribute10
           ,x_attribute11                 => rec_template.attribute11
           ,x_attribute12                 => rec_template.attribute12
           ,x_attribute13                 => rec_template.attribute13
           ,x_attribute14                 => rec_template.attribute14
           ,x_attribute15                 => rec_template.attribute15
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
           ,x_customer_id                 => rec_template.customer_id
           ,x_customer_site_use_id        => rec_template.customer_site_use_id
           ,x_normalize                   => 'N'
           ,x_location_id                 => p_location_id
           ,x_schedule_day                => l_schedule_day
           ,x_cust_ship_site_id           => rec_template.cust_ship_site_id
           ,x_ap_ar_term_id               => rec_template.ap_ar_term_id
           ,x_cust_trx_type_id            => rec_template.cust_trx_type_id
           ,x_project_id                  => rec_template.project_id
           ,x_task_id                     => rec_template.task_id
           ,x_organization_id             => rec_template.organization_id
           ,x_expenditure_type            => rec_template.expenditure_type
           ,x_expenditure_item_date       => rec_template.expenditure_item_date
           ,x_tax_group_id                => rec_template.tax_group_id
           ,x_tax_code_id                 => rec_template.tax_code_id
           ,x_tax_classification_code     => rec_template.tax_classification_code
           ,x_tax_included                => rec_template.tax_included
           ,x_distribution_set_id         => rec_template.distribution_set_id
           ,x_inv_rule_id                 => rec_template.inv_rule_id
           ,x_account_rule_id             => rec_template.account_rule_id
           ,x_salesrep_id                 => rec_template.salesrep_id
           ,x_approved_by                 => NULL
           ,x_status                      => 'DRAFT'
           ,x_po_header_id                => rec_template.po_header_id
           ,x_cust_po_number              => rec_template.cust_po_number
           ,x_receipt_method_id           => rec_template.receipt_method_id
           ,x_calling_form                => 'PNXVAREN'
           ,x_org_id                      => l_org_id
           ,x_term_template_id            => rec_template.term_template_id
           ,x_area                        => l_area
           ,x_area_type_code              => l_area_type_code
           ,x_include_in_var_rent         => NULL
         );



   /* Create a record in pn_distributions */

      l_distribution_count := 0;

      l_context :='opening cursor csr_distributions';

      FOR rec_distributions in csr_distributions(p_var_rent_id)

            LOOP
                    pn_variable_amount_pkg.put_log(' account_id '||rec_distributions.account_id);
                    pn_variable_amount_pkg.put_log(' account_class '||rec_distributions.account_id);


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

            -- Check if term exists and set actual_term_status accordingly.

            IF p_var_rent_type <> 'ADJUSTMENT' THEN
               SELECT count(*)
               INTO term_count
               FROM pn_payment_terms_all
               WHERE var_rent_inv_id = p_var_rent_inv_id
               AND var_rent_type = 'ACTUAL';

               IF term_count > 0 THEN
                  pnp_debug_pkg.debug('setting actual term status ...');
                  UPDATE pn_var_rent_inv_all
                  SET    actual_term_status='Y'
                  WHERE var_rent_inv_id = p_var_rent_inv_id;

                  UPDATE pn_var_rent_inv_all
                  SET    true_up_status = 'Y'
                  WHERE var_rent_inv_id = p_var_rent_inv_id
                  AND   true_up_status IS NOT NULL;

               ELSE
                  UPDATE pn_var_rent_inv_all
                  SET    actual_term_status='N'
                  WHERE var_rent_inv_id = p_var_rent_inv_id;

                  UPDATE pn_var_rent_inv_all
                  SET    true_up_status = 'N'
                  WHERE var_rent_inv_id = p_var_rent_inv_id
                  AND   true_up_status IS NOT NULL;

               END IF;
            END IF;

pn_variable_amount_pkg.put_log('pn_variable_term_pkg.create_payment_terms  (-) ');

EXCEPTION

     when others then
     pn_variable_amount_pkg.put_log(substrb('pn_variable_term_pkg.Error in create_payment_terms - ' ||
                                             to_char(sqlcode)||' : '||sqlerrm || ' - '|| l_context,1,244));
     rollback to create_terms;

      -- Check if term exists and set actual_term_status accordingly.

      IF p_var_rent_type <> 'ADJUSTMENT' THEN
         SELECT count(*)
         INTO term_count
         FROM pn_payment_terms_all
         WHERE var_rent_inv_id = p_var_rent_inv_id
         AND var_rent_type = 'ACTUAL';

         IF term_count > 0 THEN
            pnp_debug_pkg.debug('setting actual term status ...');
            UPDATE pn_var_rent_inv_all
            SET    actual_term_status='Y'
            WHERE var_rent_inv_id = p_var_rent_inv_id;
         ELSE
            UPDATE pn_var_rent_inv_all
            SET    actual_term_status='N'
            WHERE var_rent_inv_id = p_var_rent_inv_id;
         END IF;
      END IF;

END create_payment_terms;


PROCEDURE  get_schedule_status ( p_lease_id IN NUMBER,
                                 p_schedule_date IN DATE,
                                 x_payment_status_lookup_code OUT NOCOPY VARCHAR2) IS

   CURSOR get_schedule_cur IS
   SELECT payment_status_lookup_code
   FROM   pn_payment_schedules_all
   WHERE  lease_id = p_lease_id
   AND    schedule_date = p_schedule_date;

BEGIN


   FOR get_schedule_rec in  get_schedule_cur LOOP
      x_payment_status_lookup_code := get_schedule_rec.payment_status_lookup_code;
   END LOOP;

   IF x_payment_status_lookup_code is NULL THEN
     x_payment_status_lookup_code := 'DRAFT';
   END IF;

END;
-------------------------------------------------------------------------------
--  NAME         : FIND_VOLUME_CONTINUOUS()
--  PURPOSE      : Checks that no gaps exist in volumes for a invoice period
--  DESCRIPTION  : Checks taht volumes exist for each and every day of the
--                 invoice period
--  SCOPE        : PUBLIC
--
--  ARGUMENTS    : p_var_rent_id : variable rent ID (mandatory)
--                 p_period_id   : Id of a particular period (optional)
--                 p_invoice_date: Invoice date
--
--  RETURNS      :
--  HISTORY      :
--
--  03-APR-07    Lbala  o Created.
--
-------------------------------------------------------------------------------
FUNCTION find_volume_continuous (p_var_rent_id IN NUMBER,
                                 p_period_id IN NUMBER,
                                 p_invoice_date IN DATE
                                 ) RETURN VARCHAR2
IS
TYPE vol_hist_rec IS RECORD(
      start_date           pn_var_vol_hist_all.start_date%TYPE,
      end_date             pn_var_vol_hist_all.end_date%TYPE,
      line_item_id         pn_var_lines_all.line_item_id%TYPE
                            );

TYPE vol_hist_type IS
      TABLE OF vol_hist_rec
      INDEX BY BINARY_INTEGER;

vol_hist_tab  vol_hist_type;

--Get all line items for a period
CURSOR line_items_c(p_prd_id IN NUMBER) IS
SELECT line_item_id
FROM   pn_var_lines_all
WHERE  period_id = p_prd_id
ORDER BY line_item_id;

--Get all volume history records for a inv_dt,period_id,line_item_id combination
CURSOR vol_hist_dates(p_prd_id IN NUMBER, p_inv_dt IN DATE, p_line_id IN NUMBER)
IS
SELECT start_date, end_date, line_item_id
FROM pn_var_vol_hist_all vol,
     (SELECT gd.period_id,
             gd.grp_date_id
      FROM pn_var_grp_dates_all gd
      WHERE gd.period_id= p_prd_id
      AND gd.invoice_date = p_inv_dt OR p_inv_dt IS NULL
     )itemp
WHERE  vol.grp_date_id  = itemp.grp_date_id
AND vol.line_item_id = p_line_id
AND vol.period_id = itemp.period_id
AND vol_hist_status_code = 'APPROVED'
AND actual_amount IS NOT NULL
ORDER BY start_date,end_date;

--Get all volume history records for a inv_dt,period_id,line_item_id combination
--for firstyr
CURSOR vol_hist_dates_fy(p_prd_id IN NUMBER, p_inv_dt IN DATE, p_line_id IN NUMBER,p_end_dt IN DATE)
IS
SELECT start_date, end_date, line_item_id
FROM pn_var_vol_hist_all vol,
     (SELECT gd.period_id,
             gd.grp_date_id
      FROM pn_var_grp_dates_all gd
      WHERE gd.period_id= p_prd_id
      AND gd.invoice_date <= p_inv_dt
     )itemp
WHERE  vol.grp_date_id  = itemp.grp_date_id
AND vol.line_item_id = p_line_id
AND vol.period_id = itemp.period_id
AND vol_hist_status_code = 'APPROVED'
AND actual_amount IS NOT NULL
AND start_date <= p_end_dt
ORDER BY start_date,end_date;

--Get all volume history records for a inv_dt,period_id,line_item_id combination
--for lastyr
CURSOR vol_hist_dates_ly(p_prd_id IN NUMBER, p_inv_dt IN DATE, p_line_id IN NUMBER,p_st_dt IN DATE)
IS
SELECT start_date, end_date, line_item_id
FROM pn_var_vol_hist_all vol,
     (SELECT gd.period_id,
             gd.grp_date_id
      FROM pn_var_grp_dates_all gd
      WHERE gd.period_id= p_prd_id
      AND gd.invoice_date >= p_inv_dt
     )itemp
WHERE  vol.grp_date_id  = itemp.grp_date_id
AND vol.line_item_id = p_line_id
AND vol.period_id = itemp.period_id
AND vol_hist_status_code = 'APPROVED'
AND actual_amount IS NOT NULL
AND end_date >= p_st_dt
ORDER BY start_date,end_date;


-- Get the VR details
CURSOR vrent_cur(p_vr_id IN NUMBER) IS
  SELECT proration_rule, commencement_date, termination_date
    FROM pn_var_rents_all
   WHERE var_rent_id = p_vr_id;

-- Get partial period information
CURSOR partial_prd(p_vr_id IN NUMBER) IS
  SELECT period_id, period_num, start_date, end_date
    FROM pn_var_periods_all
   WHERE partial_period='Y'
     AND var_rent_id = p_vr_id;

-- Get invoice period dates
CURSOR inv_prd_cur(p_prd_id IN NUMBER,p_inv_dt IN DATE) IS
  SELECT inv_start_date ,inv_end_date
    FROM pn_var_grp_dates_all
   WHERE period_id = p_prd_id
     AND invoice_date = p_inv_dt;

l_prorul  VARCHAR2(5):=NULL;
l_line_id      NUMBER:= NULL;
l_invoice_date  DATE := NULL;
l_prev_end_dt   DATE ;
l_comm_dt       DATE := NULL;
l_term_dt       DATE := NULL;
l_st_dt         DATE := NULL;
l_end_dt        DATE := NULL;
inv_st_dt       DATE := NULL;
inv_end_dt      DATE := NULL;
min_st_dt       DATE := to_date('01/01/2247','dd/mm/rrrr');
max_end_dt      DATE := NULL;
l_fy_flag      NUMBER:=0;
l_ly_flag      NUMBER:=0;
l_next_prd_id  NUMBER:= NULL;
l_prev_prd_id  NUMBER:= NULL;
l_prev_line    NUMBER:= NULL;
l_next_line    NUMBER:= NULL;
l_prev_inv_dt  DATE;
k              NUMBER:= NULL;

BEGIN
    pnp_debug_pkg.log('pn_variable_term_pkg.find_volume_continuous (+) : ');

    l_invoice_date := p_invoice_date;

    FOR inv_prd_rec IN inv_prd_cur(p_period_id, p_invoice_date)  LOOP
      inv_st_dt  := inv_prd_rec.inv_start_date;
      inv_end_dt := inv_prd_rec.inv_end_date;
    END LOOP;

    l_st_dt := pn_var_rent_calc_pkg.inv_start_date(inv_start_date  => l_invoice_date
                                                   ,vr_id          => p_var_rent_id
                                                   ,p_period_id    => p_period_id
                                                   );

    l_end_dt := pn_var_rent_calc_pkg.inv_end_date(inv_start_date  => l_invoice_date
                                                  ,vr_id          => p_var_rent_id
                                                  ,p_period_id    => p_period_id
                                                  );

    FOR var_rent_rec IN vrent_cur(p_var_rent_id) LOOP
      l_prorul := var_rent_rec.proration_rule;
      l_comm_dt := var_rent_rec.commencement_date;
      l_term_dt := var_rent_rec.termination_date;
    END LOOP;

    IF l_prorul IN ('FY','FLY') THEN

      FOR prd_rec IN partial_prd(p_var_rent_id) LOOP

        IF prd_rec.period_id = p_period_id AND prd_rec.period_num=1
        THEN l_st_dt := prd_rec.start_date;
             l_end_dt := ADD_MONTHS(prd_rec.start_date,12)-1;

             IF (l_end_dt > l_term_dt AND l_st_dt <= l_term_dt ) THEN
                l_end_dt := l_term_dt;
             END IF;

             l_next_prd_id := get_period(p_var_rent_id, l_end_dt);
             l_fy_flag:=1;

        END IF;

      END LOOP;
    END IF;

    IF l_prorul IN ('LY','FLY') THEN

      FOR prd_rec IN partial_prd(p_var_rent_id) LOOP

        IF prd_rec.period_id = p_period_id AND prd_rec.end_date=l_term_dt
        THEN l_st_dt := ADD_MONTHS(prd_rec.end_date,-12)+1;
             l_end_dt := prd_rec.end_date;

             IF (l_comm_dt > l_st_dt) THEN
                l_st_dt := l_comm_dt;
             END IF;

             l_prev_prd_id := get_period(p_var_rent_id, l_st_dt);
             l_ly_flag:=1;

        END IF;
      END LOOP;

    END IF;

    IF (l_fy_flag = 0 AND l_ly_flag = 0) THEN /* Normal invoice */

      FOR line_rec IN line_items_c(p_period_id) LOOP

        l_line_id := line_rec.line_item_id;
        vol_hist_tab.DELETE;
        l_prev_end_dt := NULL;
        min_st_dt     := to_date('01/01/2247','dd/mm/rrrr');
        max_end_dt    := to_date('01/01/1976','dd/mm/rrrr');


        OPEN vol_hist_dates(p_period_id,l_invoice_date,l_line_id);
        FETCH vol_hist_dates BULK COLLECT INTO vol_hist_tab;
        CLOSE vol_hist_dates;

        IF(vol_hist_tab.COUNT > 0) THEN
         min_st_dt  := vol_hist_tab(1).start_date;
         max_end_dt := vol_hist_tab(1).end_date;
        END IF;

        FOR i IN 2..vol_hist_tab.COUNT LOOP

          IF vol_hist_tab(i).start_date BETWEEN min_st_dt AND max_end_dt + 1 THEN

             IF vol_hist_tab(i).end_date > max_end_dt THEN
                max_end_dt := vol_hist_tab(i).end_date;
             END IF;

          ELSE
             RETURN 'N';
          END IF;

        END LOOP;

        IF ( min_st_dt > l_st_dt OR
             max_end_dt < l_end_dt ) THEN

           RETURN 'N';
        END IF;


      END LOOP;
      RETURN 'Y';

    -- For first partial period invoice
    -- We need to get all volume records for the 365/366 day period say 1-JUL-05 to 30-JUN-06
    -- So we break it up into 2 parts -- 1st volumes for partial period i.e 1-JUL-05 to 31-DEC-05
    -- and 2nd volumes for 1-JAN-06 to 30-JUN-06
    -- We then check that volumes exist for this entire period

    ELSIF l_fy_flag =1 THEN /*FY invoice */

      FOR line_rec IN line_items_c(p_period_id) LOOP

        l_line_id   := line_rec.line_item_id;
        l_next_line := get_line(l_next_prd_id,l_line_id);
        l_prev_end_dt := NULL;
        min_st_dt     := to_date('01/01/2247','dd/mm/rrrr');
        max_end_dt    := to_date('01/01/1976','dd/mm/rrrr');
        vol_hist_tab.DELETE;

        OPEN vol_hist_dates(p_period_id,NULL,l_line_id);
        FETCH vol_hist_dates BULK COLLECT INTO vol_hist_tab;
        CLOSE vol_hist_dates;

        k := vol_hist_tab.COUNT + 1;

        FOR rec IN vol_hist_dates_fy(l_next_prd_id ,l_invoice_date ,l_next_line,l_end_dt ) LOOP
          vol_hist_tab(k).start_date   := rec.start_date;
          vol_hist_tab(k).end_date     := rec.end_date;
          vol_hist_tab(k).line_item_id := rec.line_item_id;
          k := k+1;
        END LOOP;

        IF(vol_hist_tab.COUNT > 0) THEN
         min_st_dt  := vol_hist_tab(1).start_date;
         max_end_dt := vol_hist_tab(1).end_date;
        END IF;

        FOR i IN 2..vol_hist_tab.COUNT LOOP

          IF vol_hist_tab(i).start_date BETWEEN min_st_dt AND max_end_dt + 1 THEN

             IF vol_hist_tab(i).end_date > max_end_dt THEN
                max_end_dt := vol_hist_tab(i).end_date;
             END IF;

          ELSE
             RETURN 'N';
          END IF;

        END LOOP;

        IF ( min_st_dt > l_st_dt OR
             max_end_dt < l_end_dt ) THEN

          RETURN 'N';
        END IF;

      END LOOP;
      RETURN 'Y';

    -- For last partial period invoice
    ELSIF l_ly_flag = 1 THEN  /* LY invoice */

      FOR line_rec IN line_items_c(p_period_id) LOOP

        l_line_id   := line_rec.line_item_id;
        l_prev_line := get_line(l_prev_prd_id,l_line_id);
        l_prev_inv_dt := get_inv_date(l_prev_prd_id, l_st_dt);
        min_st_dt     := to_date('01/01/2247','dd/mm/rrrr');
        max_end_dt    := to_date('01/01/1976','dd/mm/rrrr');
        l_prev_end_dt := NULL;
        vol_hist_tab.DELETE;


        OPEN vol_hist_dates_ly(l_prev_prd_id,l_prev_inv_dt,l_prev_line,l_st_dt);
        FETCH vol_hist_dates_ly BULK COLLECT INTO vol_hist_tab;
        CLOSE vol_hist_dates_ly;

        k := vol_hist_tab.COUNT + 1;

        FOR rec IN vol_hist_dates(p_period_id,NULL,l_line_id) LOOP
          vol_hist_tab(k).start_date   := rec.start_date;
          vol_hist_tab(k).end_date     := rec.end_date;
          vol_hist_tab(k).line_item_id := rec.line_item_id;
          k := k+1;
        END LOOP;

        IF(vol_hist_tab.COUNT > 0) THEN
         min_st_dt  := vol_hist_tab(1).start_date;
         max_end_dt := vol_hist_tab(1).end_date;
        END IF;

        FOR i IN 2..vol_hist_tab.COUNT LOOP

          IF vol_hist_tab(i).start_date BETWEEN min_st_dt AND max_end_dt + 1 THEN

             IF vol_hist_tab(i).end_date > max_end_dt THEN
                max_end_dt := vol_hist_tab(i).end_date;
             END IF;

          ELSE
             RETURN 'N';
          END IF;

        END LOOP;

        IF ( min_st_dt > l_st_dt OR
             max_end_dt < l_end_dt ) THEN

          RETURN 'N';
        END IF;

      END LOOP;
      RETURN 'Y';

    END IF;

EXCEPTION
WHEN OTHERS THEN
   pnp_debug_pkg.log('pn_variable_term_pkg.find_volume_continuous (-) : ');
   RAISE;

END find_volume_continuous;

--------------------------------------------------------------------------------
--  NAME         : get_period
--  DESCRIPTION  : Gets the period id for a var_rent_id and date combination
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  8.Mar.07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION get_period(p_vr_id IN NUMBER,
                    p_date  IN DATE
                   )
RETURN NUMBER IS

-- Get the period_id
CURSOR period_cur IS
  SELECT period_id
    FROM pn_var_periods_all
   WHERE var_rent_id = p_vr_id
     AND p_date BETWEEN start_date AND end_date;

l_prd_id NUMBER:=NULL;

BEGIN

FOR rec IN period_cur LOOP
  l_prd_id := rec.period_id;
END LOOP;

RETURN l_prd_id;

EXCEPTION
  WHEN others THEN
    RAISE;
END get_period;
--------------------------------------------------------------------------------
--  NAME         : get_line
--  DESCRIPTION  : Gets the line item for a particular corresponding to a line
--                 item id passed
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  8.Mar.07  lbala    o Created
--------------------------------------------------------------------------------
FUNCTION get_line(p_prd_id IN NUMBER,
                  p_line_id IN NUMBER
                 )
RETURN NUMBER IS

-- Get the details of
CURSOR get_line_item
IS
  SELECT line_item_id
    FROM pn_var_lines_all
   WHERE line_default_id IN ( SELECT line_default_id
                              FROM pn_var_lines_all
                              WHERE line_item_id=p_line_id
                             )
     AND period_id = p_prd_id;

l_line_id NUMBER := NULL;

BEGIN

 FOR rec IN get_line_item LOOP
   l_line_id := rec.line_item_id;
 END LOOP;

 RETURN l_line_id;

EXCEPTION
  WHEN others THEN
    RAISE;
END get_line;
--------------------------------------------------------------------------------
--  NAME         : get_inv_date
--  DESCRIPTION  : Gets invoice date for a particular period and date combination
--  PURPOSE      :
--  INVOKED FROM :
--  ARGUMENTS    :
--  REFERENCE    :
--  HISTORY      :
--
--  8.Mar.07  lbala    o Created
--------------------------------------------------------------------------------

FUNCTION get_inv_date(p_prd_id IN NUMBER,
                      p_date IN DATE
                     )
RETURN DATE IS

-- Get the details of
CURSOR inv_dt_cur
IS
SELECT invoice_date
  FROM pn_var_grp_dates_all
 WHERE period_id = p_prd_id
   AND p_date BETWEEN inv_start_date AND inv_end_date ;

l_inv_date DATE;

BEGIN

FOR rec IN inv_dt_cur LOOP
 l_inv_date := rec.invoice_date;
END LOOP;

RETURN l_inv_date;
EXCEPTION
  WHEN others THEN
    RAISE;
END get_inv_date;

-------------------------------------------------------------------------------
--  NAME         : FIND_VOLUME_CONTINUOUS_FOR()
--  PURPOSE      : Checks that no gaps exist in volumes for a invoice period
--  DESCRIPTION  : Checks that volumes exist for each and every day of the
--                 invoice period ,created only for forecasted or variance terms
--  SCOPE        : PUBLIC
--
--  ARGUMENTS    : p_var_rent_id : variable rent ID (mandatory)
--                 p_period_id   : Id of a particular period (optional)
--                 p_invoice_date: Invoice date
--                 p_rent_type   : Forecasted or Variance
--  RETURNS      :
--  HISTORY      :
--
--  03-APR-07    Lbala  o Created.
--
-------------------------------------------------------------------------------
FUNCTION find_volume_continuous_for (p_var_rent_id IN NUMBER,
                                     p_period_id IN NUMBER,
                                     p_invoice_date IN DATE,
                                     p_rent_type IN VARCHAR2
                                    ) RETURN VARCHAR2
IS
TYPE vol_hist_rec IS RECORD(
      start_date           pn_var_vol_hist_all.start_date%TYPE,
      end_date             pn_var_vol_hist_all.end_date%TYPE,
      line_item_id         pn_var_lines_all.line_item_id%TYPE
                            );

TYPE vol_hist_type IS
      TABLE OF vol_hist_rec
      INDEX BY BINARY_INTEGER;

vol_hist_tab  vol_hist_type;

--Get all line items for a period
CURSOR line_items_c(p_prd_id IN NUMBER) IS
SELECT line_item_id
FROM   pn_var_lines_all
WHERE  period_id = p_prd_id
ORDER BY line_item_id;

--Get all volume history records for a inv_dt,period_id,line_item_id combination
--for forecasted terms
CURSOR vol_hist_dates_for(p_prd_id IN NUMBER, p_inv_dt IN DATE, p_line_id IN NUMBER)
IS
SELECT start_date, end_date, line_item_id
FROM pn_var_vol_hist_all vol,
     (SELECT gd.period_id,
             gd.grp_date_id
      FROM pn_var_grp_dates_all gd
      WHERE gd.period_id= p_prd_id
      AND gd.invoice_date = p_inv_dt OR p_inv_dt IS NULL
     )itemp
WHERE  vol.grp_date_id  = itemp.grp_date_id
AND vol.line_item_id = p_line_id
AND vol.period_id = itemp.period_id
AND vol_hist_status_code = 'APPROVED'
AND forecasted_amount IS NOT NULL
ORDER BY start_date,end_date;

--Get all volume history records for a inv_dt,period_id,line_item_id combination
--for variance terms
CURSOR vol_hist_dates_var(p_prd_id IN NUMBER, p_inv_dt IN DATE, p_line_id IN NUMBER)
IS
SELECT start_date, end_date, line_item_id
FROM pn_var_vol_hist_all vol,
     (SELECT gd.period_id,
             gd.grp_date_id
      FROM pn_var_grp_dates_all gd
      WHERE gd.period_id= p_prd_id
      AND gd.invoice_date = p_inv_dt OR p_inv_dt IS NULL
     )itemp
WHERE  vol.grp_date_id  = itemp.grp_date_id
AND vol.line_item_id = p_line_id
AND vol.period_id = itemp.period_id
AND vol_hist_status_code = 'APPROVED'
AND actual_amount IS NOT NULL
ORDER BY start_date,end_date;

-- Get partial period information
CURSOR partial_prd(p_vr_id IN NUMBER) IS
  SELECT period_id, period_num, start_date, end_date
    FROM pn_var_periods_all
   WHERE partial_period='Y'
     AND var_rent_id = p_vr_id;

-- Get invoice period dates
CURSOR inv_prd_cur(p_prd_id IN NUMBER,p_inv_dt IN DATE) IS
  SELECT inv_start_date ,inv_end_date
    FROM pn_var_grp_dates_all
   WHERE period_id = p_prd_id
     AND invoice_date = p_inv_dt;

l_line_id      NUMBER:= NULL;
l_invoice_date  DATE := NULL;
l_prev_end_dt   DATE ;
l_st_dt         DATE := NULL;
l_end_dt        DATE := NULL;
min_st_dt       DATE := to_date('01/01/2247','dd/mm/rrrr');
max_end_dt      DATE := NULL;
inv_st_dt       DATE := NULL;
inv_end_dt      DATE := NULL;

BEGIN
    pnp_debug_pkg.log('pn_variable_term_pkg.find_volume_continuous_for (+) : ');

    l_invoice_date := p_invoice_date;

    FOR inv_prd_rec IN inv_prd_cur(p_period_id, p_invoice_date)  LOOP
      inv_st_dt  := inv_prd_rec.inv_start_date;
      inv_end_dt := inv_prd_rec.inv_end_date;
    END LOOP;

    l_st_dt := pn_var_rent_calc_pkg.inv_start_date(inv_start_date  => l_invoice_date
                                                   ,vr_id          => p_var_rent_id
                                                   ,p_period_id    => p_period_id
                                                    );

    l_end_dt := pn_var_rent_calc_pkg.inv_end_date(inv_start_date  => l_invoice_date
                                                  ,vr_id          => p_var_rent_id
                                                  ,p_period_id    => p_period_id
                                                   );

    FOR line_rec IN line_items_c(p_period_id) LOOP

      l_line_id := line_rec.line_item_id;
      vol_hist_tab.DELETE;
      l_prev_end_dt := NULL;
      min_st_dt     := to_date('01/01/2247','dd/mm/rrrr');
      max_end_dt    := to_date('01/01/1976','dd/mm/rrrr');

      IF(p_rent_type = 'FORECASTED') THEN

       /* For forecasted terms*/
       OPEN vol_hist_dates_for(p_period_id,l_invoice_date,l_line_id);
       FETCH vol_hist_dates_for BULK COLLECT INTO vol_hist_tab;
       CLOSE vol_hist_dates_for;

      ELSE

       /* For Variance*/
       OPEN vol_hist_dates_var(p_period_id,l_invoice_date,l_line_id);
       FETCH vol_hist_dates_var BULK COLLECT INTO vol_hist_tab;
       CLOSE vol_hist_dates_var;

      END IF;

      IF(vol_hist_tab.COUNT > 0) THEN
         min_st_dt  := vol_hist_tab(1).start_date;
         max_end_dt := vol_hist_tab(1).end_date;
      END IF;

      FOR i IN 2..vol_hist_tab.COUNT LOOP

          IF vol_hist_tab(i).start_date BETWEEN min_st_dt AND max_end_dt + 1 THEN

             IF vol_hist_tab(i).end_date > max_end_dt THEN
                max_end_dt := vol_hist_tab(i).end_date;
             END IF;

          ELSE
             RETURN 'N';
          END IF;

      END LOOP;

      IF ( min_st_dt > l_st_dt OR
           max_end_dt < l_end_dt ) THEN

        RETURN 'N';
      END IF;

    END LOOP;

    RETURN 'Y';

EXCEPTION
  WHEN others THEN
  pnp_debug_pkg.log('pn_variable_term_pkg.find_volume_continuous_for (-) : ');
  RAISE;
END find_volume_continuous_for;


-------------------------------------------------------------------------------
-- PROCEDURE : create_reversal_terms
-- Procedure for creation of reversal variable rent payment terms.
--
-- 17-apr-07 piagrawa  o Created
-------------------------------------------------------------------------------

PROCEDURE create_reversal_terms(
      p_payment_term_id        IN       NUMBER
     ,p_var_rent_inv_id        IN       NUMBER
     ,p_var_rent_type          IN       VARCHAR2
   ) IS


l_distribution_id          pn_distributions.distribution_id%TYPE;
l_payment_term_id          pn_payment_terms.payment_term_id%TYPE;
l_rowid                    ROWID;
l_distribution_count       NUMBER  := 0;
l_context                  varchar2(2000);

CURSOR csr_distributions
IS
SELECT *
FROM pn_distributions_all
WHERE payment_term_id = p_payment_term_id;

CURSOR payment_term_cur
IS
SELECT *
FROM pn_payment_terms_all
WHERE payment_term_id = p_payment_term_id;

term_count NUMBER := 0;

BEGIN

   pn_variable_amount_pkg.put_log ('pn_variable_term_pkg.create_reversal_terms  :   (+)');

   FOR payment_term_rec IN payment_term_cur LOOP

         pnt_payment_terms_pkg.insert_row (
            x_rowid                       => l_rowid
           ,x_payment_term_id             => l_payment_term_id
           ,x_index_period_id             => payment_term_rec.index_period_id
           ,x_index_term_indicator        => payment_term_rec.index_term_indicator
           ,x_var_rent_inv_id             => p_var_rent_inv_id
           ,x_var_rent_type               => p_var_rent_type
           ,x_last_update_date            => SYSDATE
           ,x_last_updated_by             => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_creation_date               => SYSDATE
           ,x_created_by                  => NVL (fnd_profile.VALUE ('USER_ID'), 0)
           ,x_payment_purpose_code        => payment_term_rec.payment_purpose_code
           ,x_payment_term_type_code      => payment_term_rec.payment_term_type_code
           ,x_frequency_code              => payment_term_rec.frequency_code
           ,x_lease_id                    => payment_term_rec.lease_id
           ,x_lease_change_id             => payment_term_rec.lease_change_id
           ,x_start_date                  => payment_term_rec.start_date
           ,x_end_date                    => payment_term_rec.end_date
           ,x_set_of_books_id             => payment_term_rec.set_of_books_id
           ,x_currency_code               => payment_term_rec.currency_code
           ,x_rate                        => payment_term_rec.rate
           ,x_last_update_login           => NVL(fnd_profile.value('LOGIN_ID'),0)
           ,x_vendor_id                   => payment_term_rec.vendor_id
           ,x_vendor_site_id              => payment_term_rec.vendor_site_id
           ,x_target_date                 => NULL
           ,x_actual_amount               => -(payment_term_rec.actual_amount)
           ,x_estimated_amount            => NULL
           ,x_attribute_category          => payment_term_rec.attribute_category
           ,x_attribute1                  => payment_term_rec.attribute1
           ,x_attribute2                  => payment_term_rec.attribute2
           ,x_attribute3                  => payment_term_rec.attribute3
           ,x_attribute4                  => payment_term_rec.attribute4
           ,x_attribute5                  => payment_term_rec.attribute5
           ,x_attribute6                  => payment_term_rec.attribute6
           ,x_attribute7                  => payment_term_rec.attribute7
           ,x_attribute8                  => payment_term_rec.attribute8
           ,x_attribute9                  => payment_term_rec.attribute9
           ,x_attribute10                 => payment_term_rec.attribute10
           ,x_attribute11                 => payment_term_rec.attribute11
           ,x_attribute12                 => payment_term_rec.attribute12
           ,x_attribute13                 => payment_term_rec.attribute13
           ,x_attribute14                 => payment_term_rec.attribute14
           ,x_attribute15                 => payment_term_rec.attribute15
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
           ,x_customer_id                 => payment_term_rec.customer_id
           ,x_customer_site_use_id        => payment_term_rec.customer_site_use_id
           ,x_normalize                   => 'N'
           ,x_location_id                 => payment_term_rec.location_id
           ,x_schedule_day                => payment_term_rec.schedule_day
           ,x_cust_ship_site_id           => payment_term_rec.cust_ship_site_id
           ,x_ap_ar_term_id               => payment_term_rec.ap_ar_term_id
           ,x_cust_trx_type_id            => payment_term_rec.cust_trx_type_id
           ,x_project_id                  => payment_term_rec.project_id
           ,x_task_id                     => payment_term_rec.task_id
           ,x_organization_id             => payment_term_rec.organization_id
           ,x_expenditure_type            => payment_term_rec.expenditure_type
           ,x_expenditure_item_date       => payment_term_rec.expenditure_item_date
           ,x_tax_group_id                => payment_term_rec.tax_group_id
           ,x_tax_code_id                 => payment_term_rec.tax_code_id
           ,x_tax_classification_code     => payment_term_rec.tax_classification_code
           ,x_tax_included                => payment_term_rec.tax_included
           ,x_distribution_set_id         => payment_term_rec.distribution_set_id
           ,x_inv_rule_id                 => payment_term_rec.inv_rule_id
           ,x_account_rule_id             => payment_term_rec.account_rule_id
           ,x_salesrep_id                 => payment_term_rec.salesrep_id
           ,x_approved_by                 => NULL
           ,x_status                      => 'DRAFT'
           ,x_po_header_id                => payment_term_rec.po_header_id
           ,x_cust_po_number              => payment_term_rec.cust_po_number
           ,x_receipt_method_id           => payment_term_rec.receipt_method_id
           ,x_calling_form                => 'PNXVAREN'
           ,x_org_id                      => payment_term_rec.org_id
           ,x_term_template_id            => payment_term_rec.term_template_id
           ,x_area                        => payment_term_rec.area
           ,x_area_type_code              => payment_term_rec.area_type_code
           ,x_include_in_var_rent         => NULL
         );

   END LOOP;

   /* Create a record in pn_distributions */

   l_distribution_count := 0;

   FOR rec_distributions IN  csr_distributions LOOP

      pn_variable_amount_pkg.put_log(' account_id '||rec_distributions.account_id);
      pn_variable_amount_pkg.put_log(' account_class '||rec_distributions.account_id);


      l_context := 'Inserting into pn_distributions';
      pn_distributions_pkg.insert_row (
            x_rowid                        => l_rowid
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
            ,x_org_id                      => rec_distributions.org_id
      );

      l_rowid := NULL;
      l_distribution_id := NULL;
      l_distribution_count :=   l_distribution_count + 1;

   END LOOP;


   l_context := 'exiting from loop';

   -- Check if term exists and set actual_term_status accordingly.

   IF p_var_rent_type <> 'ADJUSTMENT' THEN
      SELECT count(*)
      INTO term_count
      FROM pn_payment_terms_all
      WHERE var_rent_inv_id = p_var_rent_inv_id
      AND var_rent_type = 'ACTUAL';

      IF term_count > 0 THEN
         pnp_debug_pkg.debug('setting actual term status ...');
         UPDATE pn_var_rent_inv_all
         SET    actual_term_status='Y'
         WHERE var_rent_inv_id = p_var_rent_inv_id;

         UPDATE pn_var_rent_inv_all
         SET    true_up_status = 'Y'
         WHERE var_rent_inv_id = p_var_rent_inv_id
         AND   true_up_status IS NOT NULL;

      ELSE
         UPDATE pn_var_rent_inv_all
         SET    actual_term_status='N'
         WHERE var_rent_inv_id = p_var_rent_inv_id;

         UPDATE pn_var_rent_inv_all
         SET    true_up_status = 'N'
         WHERE var_rent_inv_id = p_var_rent_inv_id
         AND   true_up_status IS NOT NULL;

      END IF;

   END IF;

pn_variable_amount_pkg.put_log('pn_variable_term_pkg.create_reversal_terms  (-) ');

EXCEPTION

     when others then
     pn_variable_amount_pkg.put_log(substrb('pn_variable_term_pkg.Error in create_reversal_terms - ' ||
                                             to_char(sqlcode)||' : '||sqlerrm || ' - '|| l_context,1,244));
     rollback to create_terms;

      -- Check if term exists and set actual_term_status accordingly.

      IF p_var_rent_type <> 'ADJUSTMENT' THEN
         SELECT count(*)
         INTO term_count
         FROM pn_payment_terms_all
         WHERE var_rent_inv_id = p_var_rent_inv_id
         AND var_rent_type = 'ACTUAL';

         IF term_count > 0 THEN
            pnp_debug_pkg.debug('setting actual term status ...');
            UPDATE pn_var_rent_inv_all
            SET    actual_term_status='Y'
            WHERE var_rent_inv_id = p_var_rent_inv_id;
         ELSE
            UPDATE pn_var_rent_inv_all
            SET    actual_term_status='N'
            WHERE var_rent_inv_id = p_var_rent_inv_id;
         END IF;
      END IF;

END create_reversal_terms;

END pn_variable_term_pkg;


/
