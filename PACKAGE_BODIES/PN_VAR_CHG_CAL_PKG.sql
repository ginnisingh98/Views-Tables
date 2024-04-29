--------------------------------------------------------
--  DDL for Package Body PN_VAR_CHG_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_CHG_CAL_PKG" as
-- $Header: PNCHCALB.pls 120.0 2007/10/03 14:24:39 rthumma noship $

/*===========================================================================+
 | PROCEDURE COPY_PARENT_CONSTRAINTS
 |
 |
 | DESCRIPTION
 |    Create records in the change calendar PN_VAR_CONSTRAINTS_ALL table from
 |    records in the parent variable rent agreement.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |                    X_CHG_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-FEB-2003  Gary Olson  o Created
 +===========================================================================*/
procedure copy_parent_constraints (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    )   IS

   l_var_rent_id          NUMBER       := NULL;
   l_chg_var_rent_id      NUMBER       := NULL;
   l_last_constr_cat_code VARCHAR2(30) := NULL;
   l_last_type_code       VARCHAR2(30) := NULL;
   l_last_amount          NUMBER       := 0;
   l_constr_Num           NUMBER       := 0;

  cursor c_new_periods is
      select period_id, start_date, end_date, org_id
      from pn_var_periods
      where var_rent_id = l_var_rent_id;

  cursor c_old_periods (p_chg_var_rent_id NUMBER, p_start DATE, p_end DATE) is
      select distinct period_id
      from pn_var_periods
      where var_rent_id  = p_chg_var_rent_id
      and (start_date between p_start and p_end
      or  end_date between p_start and p_end);


  cursor c_old_constraints (p_old_periodId NUMBER) is
      select *
      from pn_var_constraints
      where period_id  = p_old_periodId
      ORDER BY constr_cat_code, type_code, amount;

BEGIN

   l_var_rent_id     := X_VAR_RENT_ID;
   l_chg_var_rent_id := X_CHG_VAR_RENT_ID;

        FOR c1_rec IN c_new_periods LOOP

           l_last_constr_cat_code  := NULL;
           l_last_type_code        := NULL;
           l_last_amount           := 0;
           l_constr_num            := 0;

           FOR c2_rec IN c_old_periods(l_chg_var_rent_id, c1_rec.start_date, c1_rec.end_date) LOOP

              FOR c3_rec IN c_old_constraints(c2_rec.period_id) LOOP

                  IF c3_rec.constr_cat_code = l_last_constr_cat_code and
                     c3_rec.type_code = l_last_type_code and
                     c3_rec.amount = l_last_amount then
                       NULL;
                  ELSE
                       l_constr_num := l_constr_num + 1;

                       INSERT INTO pn_var_constraints_all (
                                       constraint_id,
                                       constraint_num,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       last_update_login,
                                       period_id,
                                       constr_cat_code,
                                       type_code,
                                       amount,
                                       comments,
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
                                       org_id,
                                       constr_template_id,
                                       agreement_template_id,
                                       constr_default_id
                                   ) values (
                                       pn_var_constraints_s.nextval,
                                       l_constr_num,
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       c1_rec.period_id,
                                       c3_rec.constr_cat_code,
                                       c3_rec.type_code,
                                       c3_rec.amount,
                                       c3_rec.comments,
                                       c3_rec.attribute_category,
                                       c3_rec.attribute1,
                                       c3_rec.attribute2,
                                       c3_rec.attribute3,
                                       c3_rec.attribute4,
                                       c3_rec.attribute5,
                                       c3_rec.attribute6,
                                       c3_rec.attribute7,
                                       c3_rec.attribute8,
                                       c3_rec.attribute9,
                                       c3_rec.attribute10,
                                       c3_rec.attribute11,
                                       c3_rec.attribute12,
                                       c3_rec.attribute13,
                                       c3_rec.attribute14,
                                       c3_rec.attribute15,
                                       c3_rec.org_id,
                                       c3_rec.constr_template_id,
                                       c3_rec.agreement_template_id,
                                       c3_rec.constr_default_id
                                   );

                     l_last_constr_cat_code := c3_rec.constr_cat_code;
                     l_last_type_code := c3_rec.type_code;
                     l_last_amount := c3_rec.amount;

                  END IF;

              END LOOP;

           END LOOP;

        END LOOP;


END copy_parent_constraints;

/*===========================================================================+
 | PROCEDURE COPY_PARENT_LINES
 |
 |
 | DESCRIPTION
 |    Create records in the change calendar PN_VAR_LINES_ALL table from
 |    records in the parent variable rent agreement.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |                    X_CHG_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     14-FEB-2003  Gary Olson  o Created
 +===========================================================================*/
procedure copy_parent_lines (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    )   IS

   l_var_rent_id          NUMBER       := NULL;
   l_chg_var_rent_id      NUMBER       := NULL;
   l_last_sales_type_code VARCHAR2(30) := NULL;
   l_last_item_cat_code   VARCHAR2(30) := NULL;
   l_line_Num             NUMBER       := 0;
   l_lineitemid           NUMBER       := 0;
   l_bkptheadid           NUMBER       := 0;
   l_bkdt_num             NUMBER       := 0;
   l_line_start_date      DATE;
   l_line_end_date        DATE;

  cursor c_new_periods is
      select period_id, start_date, end_date,
             org_id, proration_factor
      from pn_var_periods
      where var_rent_id = l_var_rent_id;

  cursor c_old_periods (p_chg_var_rent_id NUMBER, p_start DATE, p_end DATE) is
      select distinct period_id
      from pn_var_periods
      where var_rent_id  = p_chg_var_rent_id
      and (start_date between p_start and p_end
      or  end_date between p_start and p_end);

  cursor c_old_lines (p_old_periodId NUMBER) is
      select *
      from pn_var_lines
      where period_id  = p_old_periodId
      ORDER BY sales_type_code, item_category_code;

  cursor c_old_bkpt_head (p_old_periodId NUMBER) is
      select *
      from pn_var_bkpts_head
      where period_id  = p_old_periodId;

  cursor c_old_bkpt_det (p_bkptheadid NUMBER) IS
      select *
      from pn_var_bkpts_det
      where bkpt_header_id = p_bkptheadid;

BEGIN

   l_var_rent_id     := X_VAR_RENT_ID;
   l_chg_var_rent_id := X_CHG_VAR_RENT_ID;

        FOR c1_rec IN c_new_periods LOOP

           l_last_sales_type_code  := NULL;
           l_last_item_cat_code    := NULL;
           l_line_num              := 0;
           l_bkdt_num              := 0;

           FOR c2_rec IN c_old_periods(l_chg_var_rent_id, c1_rec.start_date, c1_rec.end_date) LOOP

              FOR c3_rec IN c_old_lines(c2_rec.period_id) LOOP

                  IF c3_rec.sales_type_code = l_last_sales_type_code and
                     c3_rec.item_category_code = l_last_item_cat_code then
                       NULL;
                  ELSE
                       l_line_num := l_line_num + 1;
                       SELECT pn_var_lines_s.nextval into l_lineitemid from dual;

                       INSERT INTO pn_var_lines_all (
                                       line_item_id,
                                       line_item_num,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       last_update_login,
                                       period_id,
                                       sales_type_code,
                                       item_category_code,
                                       comments,
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
                                       org_id,
                                       line_template_id,
                                       agreement_template_id,
                                       line_default_id
                                   ) values (
                                       l_lineitemid,
                                       l_line_num,
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       c1_rec.period_id,
                                       c3_rec.sales_type_code,
                                       c3_rec.item_category_code,
                                       c3_rec.comments,
                                       c3_rec.attribute_category,
                                       c3_rec.attribute1,
                                       c3_rec.attribute2,
                                       c3_rec.attribute3,
                                       c3_rec.attribute4,
                                       c3_rec.attribute5,
                                       c3_rec.attribute6,
                                       c3_rec.attribute7,
                                       c3_rec.attribute8,
                                       c3_rec.attribute9,
                                       c3_rec.attribute10,
                                       c3_rec.attribute11,
                                       c3_rec.attribute12,
                                       c3_rec.attribute13,
                                       c3_rec.attribute14,
                                       c3_rec.attribute15,
                                       c3_rec.org_id,
                                       c3_rec.line_template_id,
                                       c3_rec.agreement_template_id,
                                       c3_rec.line_default_id
                                   );

                     l_last_sales_type_code := c3_rec.sales_type_code;
                     l_last_item_cat_code   := c3_rec.item_category_code;


              FOR c4_rec IN c_old_bkpt_head(c2_rec.period_id) LOOP
                      SELECT pn_var_bkpts_head_s.nextval into l_bkptheadid from dual;

                      INSERT INTO pn_var_bkpts_head_all (
                                       bkpt_header_id,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       last_update_login,
                                       line_item_id,
                                       period_id,
                                       break_type,
                                       base_rent_type,
                                       natural_break_rate,
                                       base_rent,
                                       breakpoint_type,
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
                                       org_id
                                   ) values (
                                       l_bkptheadid,
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       l_lineitemid,
                                       c1_rec.period_id,
                                       c4_rec.break_type,
                                       c4_rec.base_rent_type,
                                       c4_rec.natural_break_rate,
                                       c4_rec.base_rent,
                                       c4_rec.breakpoint_type,
                                       c4_rec.attribute_category,
                                       c4_rec.attribute1,
                                       c4_rec.attribute2,
                                       c4_rec.attribute3,
                                       c4_rec.attribute4,
                                       c4_rec.attribute5,
                                       c4_rec.attribute6,
                                       c4_rec.attribute7,
                                       c4_rec.attribute8,
                                       c4_rec.attribute9,
                                       c4_rec.attribute10,
                                       c4_rec.attribute11,
                                       c4_rec.attribute12,
                                       c4_rec.attribute13,
                                       c4_rec.attribute14,
                                       c4_rec.attribute15,
                                       c4_rec.org_id
                                   );

                      l_bkdt_num := 0;

                      FOR c5_rec IN c_old_bkpt_det(c4_rec.bkpt_header_id) LOOP

                          l_bkdt_num := l_bkdt_num + 1;
                          IF c1_rec.start_date > NVL(c5_rec.bkpt_start_date, c1_rec.start_date - 1) THEN
                             l_line_start_date := c1_rec.start_date;
                          ELSE
                             l_line_start_date := c5_rec.bkpt_start_date;
                          END IF;

                          IF c1_rec.end_date < NVL(c5_rec.bkpt_end_date, c1_rec.end_date + 1) THEN
                             l_line_end_date := c1_rec.end_date;
                          ELSE
                             l_line_end_date := c5_rec.bkpt_end_date;
                          END IF;

-- need to build routine to calculate volumes based on period and group proration.
-- use period volumes as control amounts for calculations.

                          INSERT INTO pn_var_bkpts_det_all (
                                       bkpt_detail_id,
                                       bkpt_detail_num,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       last_update_login,
                                       bkpt_header_id,
                                       bkpt_start_date,
                                       bkpt_end_date,
                                       period_bkpt_vol_start,
                                       period_bkpt_vol_end,
                                       group_bkpt_vol_start,
                                       group_bkpt_vol_end,
                                       bkpt_rate,
                                       comments,
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
                                       org_id
                                   ) values (
                                       pn_var_bkpts_det_s.nextval,
                                       l_bkdt_num,
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       sysdate,
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       NVL(fnd_profile.value('USER_ID'),0),
                                       l_bkptheadid,
                                       l_line_start_date,
                                       l_line_end_date,
                                       c5_rec.period_bkpt_vol_start,
                                       c5_rec.period_bkpt_vol_end,
                                       c5_rec.group_bkpt_vol_start,
                                       c5_rec.group_bkpt_vol_end,
                                       c5_rec.bkpt_rate,
                                       c5_rec.comments,
                                       c5_rec.attribute_category,
                                       c5_rec.attribute1,
                                       c5_rec.attribute2,
                                       c5_rec.attribute3,
                                       c5_rec.attribute4,
                                       c5_rec.attribute5,
                                       c5_rec.attribute6,
                                       c5_rec.attribute7,
                                       c5_rec.attribute8,
                                       c5_rec.attribute9,
                                       c5_rec.attribute10,
                                       c5_rec.attribute11,
                                       c5_rec.attribute12,
                                       c5_rec.attribute13,
                                       c5_rec.attribute14,
                                       c5_rec.attribute15,
                                       c5_rec.org_id
                                   );

                         END LOOP;

                     END LOOP;

                  END IF;

              END LOOP;

           END LOOP;

        END LOOP;


end copy_parent_lines;

/*===========================================================================+
 | PROCEDURE COPY_PARENT_VOLHIST
 |
 |
 | DESCRIPTION
 |    Create records in the change calendar PN_VAR_VOL_HIST_ALL table from
 |    records in the parent variable rent agreement VOL HIST TABLE when group dates
 |    are the same for both the parent and the change calendar periods.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |                    X_CHG_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     18-FEB-2003  Gary Olson  o Created
 +===========================================================================*/
procedure copy_parent_volhist (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_VAR_RENT_ID     in NUMBER
    ) IS

   l_chg_var_rent_id       NUMBER := 0;
   l_var_rent_id           NUMBER := 0;
   l_comm_date             DATE;
   l_vol_num               NUMBER := 0;
   l_null                  VARCHAR2(10) := NULL;
   l_start_date            DATE;
   l_end_date              DATE;
   l_actual_amount         NUMBER := 0;

   cursor c_start is
       select commencement_date
       from pn_var_rents_all
       where var_rent_id = l_var_rent_id;

   cursor c_new_grplineperiod is
       select a.grp_date_id,
              b.line_item_id,
              c.period_id,
              c.start_date,
              c.end_date,
              a.group_date,
              a.invoice_date invoicing_date,
              a.reptg_due_date reporting_date
       from pn_var_grp_dates_all a,
            pn_var_lines_all b,
            pn_var_periods_all c
       where a.var_rent_id = l_var_rent_id
       and a.period_id     = b.period_id
       and b.period_id     = c.period_id;

   cursor c_old_grplineperiod (p_comm_date DATE, p_start_date DATE, p_end_date DATE) is
       select d.vol_hist_id          vol_hist_id,
              d.line_item_id         line_item_id,
              d.period_id            period_id,
              d.start_date           start_date,
              d.end_date             end_date,
              d.grp_date_id          grp_date_id,
              d.group_date           group_date,
              d.actual_gl_account_id actual_gl_account_id,
              d.actual_amount        actual_amount,
              d.daily_actual_amount  daily_actual_amount,
              d.vol_hist_status_code vol_hist_status_code,
              d.report_type_code     report_type_code,
              d.certified_by         certified_by,
              d.actual_exp_code      actual_exp_code,
              d.for_gl_account_id    for_gl_account_id,
              d.forecasted_amount    forecasted_amount,
              d.forecasted_exp_code  forecasted_exp_code,
              d.variance_exp_code    variance_exp_code,
              d.comments             comments,
              d.attribute_category   attribute_category,
              d.attribute1           attribute1,
              d.attribute2           attribute2,
              d.attribute3           attribute3,
              d.attribute4           attribute4,
              d.attribute5           attribute5,
              d.attribute6           attribute6,
              d.attribute7           attribute7,
              d.attribute8           attribute8,
              d.attribute9           attribute9,
              d.attribute10          attribute10,
              d.attribute11          attribute11,
              d.attribute12          attribute12,
              d.attribute13          attribute13,
              d.attribute14          attribute14,
              d.attribute15          attribute15,
              d.org_id               org_id
       from pn_var_grp_dates_all a,
            pn_var_lines_all b,
            pn_var_periods_all c,
            pn_var_vol_hist_all d
       where a.var_rent_id = l_chg_var_rent_id
       and a.period_id     = b.period_id
       and b.period_id     = c.period_id
       and d.period_id     = c.period_id
       and d.line_item_id  = b.line_item_id
       and d.grp_date_id   = a.grp_date_id
       and (d.start_date between p_start_date and p_end_date
       or d.end_date between p_start_date and p_end_date)
       and a.grp_start_date >= p_comm_date;

BEGIN

   l_chg_var_rent_id := X_CHG_VAR_RENT_ID;
   l_var_rent_id     := X_VAR_RENT_ID;

   open c_start;
   fetch c_start into l_comm_date;
   close c_start;

   FOR c1_rec IN c_new_grplineperiod LOOP
      l_vol_num := 0;
      FOR c2_rec IN c_old_grplineperiod (l_comm_date, c1_rec.start_date, c1_rec.end_date) LOOP
          l_vol_num := l_vol_num + 1;
          IF c1_rec.start_date > c2_rec.start_date THEN
             l_start_date := c1_rec.start_date;
          ELSE
             l_start_date := c2_rec.start_date;
          END IF;

          IF c1_rec.end_date < c2_rec.end_date THEN
             l_end_date := c1_rec.end_date;
          ELSE
             l_end_date := c2_rec.end_date;
          END IF;

            /**
          l_actual_amount := ROUND(c2_rec.daily_actual_amount *
                             to_number(to_char(l_end_date,'YYMMDD'))-
                             to_number(to_char(l_start_date,'YYMMDD')),2);
            **/

              INSERT into pn_var_vol_hist_all (
                                vol_hist_id,
                                vol_hist_num,
                                last_update_date,
                                last_updated_by,
                                creation_date,
                                created_by,
                                last_update_login,
                                line_item_id,
                                period_id,
                                start_date,
                                end_date,
                                grp_date_id,
                                group_date,
                                reporting_date,
                                due_date,
                                invoicing_date,
                                actual_gl_account_id,
                                actual_amount,
                                daily_actual_amount,
                                vol_hist_status_code,
                                report_type_code,
                                certified_by,
                                actual_exp_code,
                                for_gl_account_id,
                                forecasted_amount,
                                forecasted_exp_code,
                                variance_exp_code,
                                comments,
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
                                org_id
                           ) values (
                                pn_var_vol_hist_s.nextval,
                                l_vol_num,
                                sysdate,
                                NVL(fnd_profile.value('USER_ID'),0),
                                sysdate,
                                NVL(fnd_profile.value('USER_ID'),0),
                                NVL(fnd_profile.value('USER_ID'),0),
                                c1_rec.line_item_id,
                                c1_rec.period_id,
                                l_start_date,
                                l_end_date,
                                c1_rec.grp_date_id,
                                c1_rec.group_date,
                                c1_rec.reporting_date,
                                l_null,
                                c1_rec.invoicing_date,
                                l_null,
                                l_actual_amount,
                                c2_rec.daily_actual_amount,
                                c2_rec.vol_hist_status_code,
                                c2_rec.report_type_code,
                                l_null,
                                l_null,
                                l_null,
                                l_null,
                                l_null,
                                l_null,
                                c2_rec.comments,
                                c2_rec.attribute_category,
                                c2_rec.attribute1,
                                c2_rec.attribute2,
                                c2_rec.attribute3,
                                c2_rec.attribute4,
                                c2_rec.attribute5,
                                c2_rec.attribute6,
                                c2_rec.attribute7,
                                c2_rec.attribute8,
                                c2_rec.attribute9,
                                c2_rec.attribute10,
                                c2_rec.attribute11,
                                c2_rec.attribute12,
                                c2_rec.attribute13,
                                c2_rec.attribute14,
                                c2_rec.attribute15,
                                c2_rec.org_id
                               );

      END LOOP;

   END LOOP;


END copy_parent_volhist;

/*===========================================================================+
 | PROCEDURE POPULATE_TRANSACTIONS
 |
 |
 | DESCRIPTION
 |         Populate the variable rent transactions table when periods,
 |         group dates and breakpoint details have been created.
 |
 | SCOPE - PUBLIC
 |
  EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     10-MAR-2003  Gary Olson  o Created
 +===========================================================================*/
PROCEDURE populate_transactions (p_var_rent_id IN NUMBER,
                                 p_period_id IN NUMBER,
                                 p_line_item_id IN NUMBER)
IS

CURSOR csr_get_groups (ip_var_rent_id NUMBER, ip_period_id NUMBER) IS
    SELECT a.var_rent_id,
           a.period_id,
           a.grp_date_id,
           a.grp_start_date,
           a.grp_end_date,
           a.group_date,
           (a.grp_end_date - a.grp_start_date)+1 no_of_group_days,
           a.invoice_date
           ,a.proration_factor
           ,b.start_date
           ,b.end_date
           ,c.commencement_date
           ,c.proration_rule     --Chris.T. 10FEB2004
    FROM pn_var_grp_dates_all a
         ,pn_var_periods_all b
         ,pn_var_rents_all c
    WHERE c.var_rent_id = ip_var_rent_id
    AND   c.var_rent_id = a.var_rent_id
    AND   a.period_id = b.period_id
    AND   a.period_id = NVL(ip_period_id,a.period_id)
    ORDER by grp_start_date;

CURSOR csr_get_bkpts (ip_period_id NUMBER) IS
    SELECT bkpt.bkpt_detail_id          bkpt_detail_id,
           bkpt.bkpt_start_date         bkpt_start_date,
           bkpt.bkpt_end_date           bkpt_end_date,
           bkpt.group_bkpt_vol_start    group_bkpt_vol_start,
           bkpt.group_bkpt_vol_end      group_bkpt_vol_end,
           bkpt.period_bkpt_vol_start   period_bkpt_vol_start, --Chris.T. 10FEB2004
           bkpt.period_bkpt_vol_end     period_bkpt_vol_end, --Chris.T. 10FEB2004
           bkpt.bkpt_rate               bkpt_rate,
           bkpt.bkpt_header_id          bkpt_header_id,
           head.line_item_id            line_item_id
    FROM pn_var_bkpts_head_all head,
         pn_var_bkpts_det_all bkpt
    WHERE head.bkpt_header_id = bkpt.bkpt_header_id
    AND head.period_id = ip_period_id
    AND head.line_item_id = NVL(p_line_item_id,line_item_id)
    ORDER by head.line_item_id,bkpt.bkpt_start_date, bkpt.bkpt_rate, bkpt.group_bkpt_vol_start;

/*CURSOR csr_trans_exists (p_grp_date_id NUMBER,
                         p_bkpt_detail_id NUMBER) IS
    SELECT 1
    FROM pn_var_transactions_all
    WHERE grp_date_id = p_grp_date_id
    AND bkpt_detail_id = p_bkpt_detail_id;

CURSOR csr_find_resets (ip_var_rent_id NUMBER) IS
    SELECT distinct a.period_id
           ,a.group_date
           ,a.line_item_id
           ,a.bkpt_start_date
           ,b.item_category_code
           ,b.sales_type_code
    FROM   pn_var_transactions_all a
           ,pn_var_lines_all b
    WHERE  a.var_rent_id = ip_var_rent_id
    AND    a.line_item_id = NVL(p_line_item_id,b.line_item_id)
    AND    a.line_item_id = b.line_item_id --24SEP03 Chris.T.
    ORDER BY b.item_category_code ,b.sales_type_code ,a.group_date; -- 11DEC03 Chris.T.

CURSOR csr_reset_check( ip_var_rent_id NUMBER, p_start_date DATE) IS
     SELECT 1
     FROM pn_var_transactions_all a
     WHERE a.var_rent_id = p_var_rent_id
     AND a.bkpt_end_date = p_start_date - 1
     AND a.bkpt_rate not in (select b.bkpt_rate
     FROM pn_var_transactions_all b
         where b.var_rent_id = ip_var_rent_id
         and b.bkpt_start_date = p_start_date);

  CURSOR l_row_exists_cur (ip_var_rent_id NUMBER
                          ,ip_grp_date_id NUMBER
                          ,ip_line_item_id NUMBER
                          ,ip_bkpt_detail_id NUMBER
                          ,ip_bkpt_start_date DATE
                          ,ip_bkpt_end_date DATE) IS

  SELECT 'x'
  FROM   DUAL
  WHERE EXISTS( SELECT var_rent_id
                FROM   pn_var_transactions_all
                WHERE var_rent_id     = ip_var_rent_id
                AND   line_item_id    = ip_line_item_id
                AND   bkpt_detail_id  = ip_bkpt_detail_id
              AND   grp_date_id     = ip_grp_date_id);
                --AND   bkpt_start_date = ip_bkpt_start_date
                --AND   bkpt_End_date   = ip_bkpt_end_date);*/

   CURSOR pn_var_grp_dt (p_var_rent_id NUMBER) IS
   SELECT min(grp_start_date) fy_start_date
          , ADD_MONTHS(min(grp_start_date), 12) - 1 fy_end_date
          , ADD_MONTHS(max(grp_end_date), -12) + 1 ly_start_date
          , max(grp_end_date) ly_end_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id;
   /* Srini 14JUL2004
   SELECT min(grp_start_date)
          , min(grp_start_date)+364
          , max(grp_end_date) - 364
          , max(grp_end_date)
   */

  /*CURSOR update_365_days_bkpt(p_ly_365_end_dt DATE)
  IS
    SELECT *
    FROM pn_var_transactions_all
    WHERE var_rent_id = p_var_rent_id
    AND bkpt_end_date = p_ly_365_end_dt
    AND NVL(pr_grp_blended_vol_end,0) <> 0;

  CURSOR update_365_days_bkpt_strat(p_ly_365_end_dt DATE)
  IS
    SELECT *
    FROM pn_var_transactions_all
    WHERE var_rent_id = p_var_rent_id
    AND bkpt_end_date = p_ly_365_end_dt
    AND NVL(pr_grp_blended_vol_end,0) = 0;*/


  l_found                     NUMBER := 0;
  l_row_exists                VARCHAR2(1);
  l_reset_found               NUMBER := 0;
  l_calc_days                 NUMBER;
  l_proration_factor          NUMBER;
  l_prorate_start             NUMBER; --(12,2); Chris.T. 09MAR2004
  l_prorate_end               NUMBER; --(12,2); Chris.T. 09MAR2004
  l_pr_prorate_start          NUMBER; --(12,2); Chris.T. 09MAR2004
  l_pr_prorate_end            NUMBER; --(12,2); Chris.T. 09MAR2004
  l_resets_flag               VARCHAR2(1) := 'N';
  l_reset_flag                VARCHAR2(1) := 'N';
  l_reset_group_id            NUMBER := 0;
  l_reset_group_id_cnt        NUMBER := 0;
  l_pro_reset_group_id        NUMBER := NULL;
  l_pro_reset_group_id_cnt    NUMBER := 0;
  g_pro_reset_group_id_cnt    NUMBER := 0;
  l_proration_rule            VARCHAR2(30);
  l_period_start              DATE;
  l_period_end                DATE;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_commencement_date         DATE;
  l_filename                  VARCHAR2(50) := 'POPULATE-'||p_var_rent_id||'-'||to_char(sysdate,'MMDDYYHHMMSS');
  l_pathname                  VARCHAR2(60) := '/u04/app/crp4comn/admin/plsql';

  l_fy_start_date             DATE;
  l_fy_end_date               DATE;
  l_ly_start_date             DATE;
  l_ly_end_date               DATE;
  l_fy_factor                 NUMBER;
  l_ly_factor                 NUMBER;
  l_factor                    NUMBER;
  g_reset_complete            VARCHAR2(1) := NULL;
  l_last_complete_period_id   NUMBER;
  l_ly_365_start_date         DATE;
  l_fy_365_end_date           DATE;
  l_vr_term_dt          DATE;
  l_cumulative_vol        PN_VAR_RENTS_ALL.CUMULATIVE_VOL%TYPE;
  v_reset_grp_id        NUMBER;
  l_bkpt_days1          NUMBER;
  l_bkpt_days2          NUMBER;
  l_cnt                 NUMBER;
  v_bkpt_start_date       DATE;
  l_ly_365_end_dt       DATE;
  l_ly_365_start_dt       DATE;
  l_invg_freq         VARCHAR2(20);
  l_pr_start                  NUMBER;
  l_pr_end                    NUMBER;

BEGIN

   --pnp_debug_pkg.enable_file_debug(l_pathname,l_filename);
   PNP_DEBUG_PKG.log('PN_VAR_CHG_CAL_PKG.populate_transactions  (+)');
   PNP_DEBUG_PKG.log('  Parameters :');
   pNP_DEBUG_PKG.log('  p_var_rent_id =  '|| p_var_rent_id);
   pNP_DEBUG_PKG.log('  p_period_id =  '|| p_period_id);
   pnp_debug_pkg.log('  Call pn_var_rent_pkg.get_proration_rule');
   PNP_DEBUG_PKG.DEBUG('PN_VAR_CHG_CAL_PKG.populate_transactions  (+)');
   PNP_DEBUG_PKG.DEBUG('Parameters :');
   pNP_DEBUG_PKG.DEBUG('p_var_rent_id =  '|| p_var_rent_id);
   pNP_DEBUG_PKG.DEBUG('p_period_id =  '|| p_period_id);
   pnp_debug_pkg.debug('Call pn_var_rent_pkg.get_proration_rule');

   l_proration_rule := pn_var_rent_pkg.get_proration_rule(p_var_rent_id =>p_var_rent_id);
   pnp_debug_pkg.log('  Proration Rule = '||l_proration_rule);
   pnp_debug_pkg.debug('Proration Rule = '||l_proration_rule);

   SELECT termination_date, cumulative_vol
   INTO l_vr_term_dt, l_cumulative_vol
   FROM pn_var_rents_all
   WHERE var_rent_id = p_var_rent_id;
   pnp_debug_pkg.log('  Variable Rent Termination Date:'||l_vr_term_dt||' Cumulative Volume:'||l_cumulative_vol);
   pnp_debug_pkg.debug(' Variable Rent Termination Date:'||l_vr_term_dt);

   IF l_proration_rule in ('FY','LY','FLY') THEN
      OPEN pn_var_grp_dt(p_var_rent_id);
      FETCH pn_var_grp_dt INTO
            l_fy_start_date
            ,l_fy_end_date
            ,l_ly_start_date
            ,l_ly_end_date;
      CLOSE pn_var_grp_dt;

      SELECT MAX(end_date), ADD_MONTHS(MAX(end_date), -12)+1
      INTO l_ly_365_end_dt, l_ly_365_start_dt
      FROM pn_var_periods_all
      WHERE var_rent_id = p_var_rent_id;

    --pnp_debug_pkg.log('  l_fy_start_date = '|| l_fy_start_date);
    --pnp_debug_pkg.log('  l_fy_end_date = '|| l_fy_end_date);
    --pnp_debug_pkg.log('  l_ly_start_date = '|| l_ly_start_date);
    --pnp_debug_pkg.log('  l_ly_end_date = '|| l_ly_end_date);
    pnp_debug_pkg.debug('l_fy_start_date = '|| l_fy_start_date);
    pnp_debug_pkg.debug('l_fy_end_date = '|| l_fy_end_date);
    pnp_debug_pkg.debug('l_ly_start_date = '|| l_ly_start_date);
    pnp_debug_pkg.debug('l_ly_end_date = '|| l_ly_end_date);
    /*DBMS_OUTPUT.PUT_LINE('  l_fy_start_date = '|| l_fy_start_date);
    DBMS_OUTPUT.PUT_LINE('  l_fy_end_date = '|| l_fy_end_date);
    DBMS_OUTPUT.PUT_LINE('  l_ly_start_date = '|| l_ly_start_date);
    DBMS_OUTPUT.PUT_LINE('  l_ly_end_date = '|| l_ly_end_date);*/
   END IF;
   /*dbms_output.put_line('Step - 1'); */
   FOR c_grp IN csr_get_groups (p_var_rent_id,p_period_id) LOOP
       l_commencement_date := c_grp.commencement_date;
       --PNP_DEBUG_PKG.log('  Calling csr_get_groups');
       pnp_debug_pkg.debug('Cursor csr_get_groups');
       l_period_start := c_grp.start_date;
       l_period_end := c_grp.end_date;
       --pnp_debug_pkg.log('  Period start = '|| l_period_start);
       --pnp_debug_pkg.log('  Period end = '|| l_period_end);
       pnp_debug_pkg.debug('Period start = '|| l_period_start);
       pnp_debug_pkg.debug('Period end = '|| l_period_end);

       PNP_DEBUG_PKG.DEBUG('Opening cursor csr_get_bkpts ');
       /* dbms_output.put_line('Step - 2'); */
       FOR c_bkpt IN csr_get_bkpts (c_grp.period_id) LOOP
           l_found := 0;

           --pnp_debug_pkg.log('  GRP Start Date '||to_char(c_grp.grp_start_date ,'DD-MON-YYYY'));
           --pnp_debug_pkg.log('  GRP End Date '||to_char(c_grp.grp_end_date ,'DD-MON-YYYY'));
           --pnp_debug_pkg.log('  BKPT Start Date '||to_char(c_bkpt.bkpt_start_date ,'DD-MON-YYYY'));
           --pnp_debug_pkg.log('  BKPT End Date '||to_char(c_bkpt.bkpt_end_date ,'DD-MON-YYYY'));
           pnp_debug_pkg.debug('GRP Start Date '||to_char(c_grp.grp_start_date ,'DD-MON-YYYY'));
           pnp_debug_pkg.debug('GRP End Date '||to_char(c_grp.grp_end_date ,'DD-MON-YYYY'));
           pnp_debug_pkg.debug('BKPT Start Date '||to_char(c_bkpt.bkpt_start_date ,'DD-MON-YYYY'));
           pnp_debug_pkg.debug('BKPT End Date '||to_char(c_bkpt.bkpt_end_date ,'DD-MON-YYYY'));
           PNP_DEBUG_PKG.DEBUG('Opening cursor csr_trans_exists ');
           l_resets_flag := 'N';

           pnp_debug_pkg.debug('l_found = ' || l_found);

         /* dbms_output.put_line('Step - 3'); */
         IF c_grp.grp_start_date between c_bkpt.bkpt_start_date and c_bkpt.bkpt_end_date
            OR c_grp.grp_end_date between c_bkpt.bkpt_start_date and c_bkpt.bkpt_end_date
            OR c_bkpt.bkpt_start_date between c_grp.grp_start_date and c_grp.grp_end_date
            OR c_bkpt.bkpt_end_date between c_grp.grp_start_date and c_grp.grp_end_date THEN

            --pnp_debug_pkg.log('  Group Start Date OR End Date Between BKPT Start date or End Date');
            pnp_debug_pkg.debug('Group Start Date OR End Date Between BKPT Start date or End Date');

            IF c_grp.grp_start_date >= c_bkpt.bkpt_start_date THEN
              l_start_date := c_grp.grp_start_date;
            ELSE
              l_start_date := c_bkpt.bkpt_start_date;
            END IF;
            IF c_grp.grp_end_date <= c_bkpt.bkpt_end_date THEN
              l_end_date := c_grp.grp_end_date;
            ELSE
              l_end_date := c_bkpt.bkpt_end_date;
            END IF;

            l_calc_days := (l_end_date - l_start_date)+1;

            IF l_proration_rule = 'NP' THEN
            --IF l_proration_rule IN ('NP', 'LY', 'FLY') THEN
              l_proration_factor := 1;
      ELSE
              l_proration_factor := l_calc_days/c_grp.no_of_group_days;
      END IF;
            /*DBMS_OUTPUT.PUT_LINE('  Calculate Days     = '||to_char(l_calc_days));
            DBMS_OUTPUT.PUT_LINE('  Proration Factor   = '||to_char(l_proration_factor));
            DBMS_OUTPUT.PUT_LINE('  GRP Start Date '||to_char(c_grp.grp_start_date ,'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('  GRP End Date '||to_char(c_grp.grp_end_date ,'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('  BKPT Start Date '||to_char(c_bkpt.bkpt_start_date ,'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('  BKPT End Date '||to_char(c_bkpt.bkpt_end_date ,'DD-MON-YYYY')); */

            IF l_proration_rule = 'NP' THEN
              l_prorate_start := c_bkpt.period_bkpt_vol_start;
            ELSE
              l_prorate_start := (c_bkpt.group_bkpt_vol_start*c_grp.proration_factor)*l_proration_factor;
            END IF;

            IF c_bkpt.group_bkpt_vol_end > 0 THEN
              IF l_proration_rule = 'NP' THEN
                l_prorate_end   := c_bkpt.period_bkpt_vol_end;
              ELSE
                l_prorate_end   := (c_bkpt.group_bkpt_vol_end*c_grp.proration_factor)*l_proration_factor;
              END IF;
            ELSE
              l_prorate_end := 0;
            END IF;
          /* DBMS_OUTPUT.PUT_LINE('  l_prorate_start = '||l_prorate_start);
          DBMS_OUTPUT.PUT_LINE('  l_prorate_end = '||l_prorate_end); */

            pnp_debug_pkg.debug('Prorated GRP Vol Start '||to_char(l_prorate_start));
            pnp_debug_pkg.debug('Prorated GRP Vol End '||to_char(l_prorate_end));
            PNP_DEBUG_PKG.DEBUG('l_start_date = '|| l_start_date);
            PNP_DEBUG_PKG.DEBUG('l_end_date = '|| l_end_date);
            PNP_DEBUG_PKG.DEBUG('Calculate Days = '||to_char(l_calc_days));
            PNP_DEBUG_PKG.DEBUG('no of_group_Days = '||to_char(c_grp.no_of_group_days));
            PNP_DEBUG_PKG.DEBUG('l_proration_factor = '||to_char(l_proration_factor));
            PNP_DEBUG_PKG.DEBUG('c_grp.proration_factor = '||to_char(c_grp.proration_factor));
            PNP_DEBUG_PKG.DEBUG('GRP BKPT 1 = '||to_char(c_bkpt.group_bkpt_vol_start));
            PNP_DEBUG_PKG.DEBUG('GRP BKPT 2 = '||(c_bkpt.group_bkpt_vol_start* c_grp.proration_Factor));
            PNP_DEBUG_PKG.DEBUG('GRP BKPT 3 = '||((c_bkpt.group_bkpt_vol_start* c_grp.proration_Factor)* l_proration_Factor));

            PNP_DEBUG_PKG.DEBUG('insert pn_var_Transactions');
            pnp_debug_pkg.debug('l_startdate = '|| l_start_date);
            pnp_debug_pkg.debug('l_enddae = '|| l_end_date);
            l_fy_factor := 1;
            l_ly_factor := 1;
            l_factor := l_proration_factor;
            l_pr_prorate_start := l_prorate_start ;
            l_pr_prorate_end := l_prorate_end ;
            pnp_debug_pkg.debug('l_proration_rule='|| l_proration_rule);
            IF l_proration_rule in ('FY','LY','FLY') THEN

                 IF l_fy_end_date BETWEEN  l_start_date and l_end_date THEN
        IF l_proration_rule = 'LY' AND l_fy_end_date > l_ly_start_date THEN
          l_fy_factor := 1;
        ELSE
                      l_fy_factor := ((l_fy_end_date - l_start_date)+1)/((l_end_Date-l_start_date)+1);
                      l_pr_prorate_start := l_pr_prorate_start * l_fy_factor;
                      l_pr_prorate_end := l_pr_prorate_end * l_fy_factor;
                      pnp_debug_pkg.debug('l_fy_factor='|| l_fy_factor);
                      l_factor := l_fy_factor;
                /*DBMS_OUTPUT.PUT_LINE('********* l_fy_factor ********* : '||l_fy_factor); */
        END IF;
                 END IF;

                 IF l_ly_start_date BETWEEN l_start_date and l_end_date THEN
        IF l_proration_rule = 'FY' AND l_ly_start_date < l_fy_end_date THEN
          l_ly_factor := 1;
        ELSE
                      l_ly_factor := ((l_end_date - l_ly_start_date)+1)/((l_end_date-l_start_date)+1);
                      l_pr_prorate_start := l_pr_prorate_start * l_ly_factor;
                      l_pr_prorate_end := l_pr_prorate_end * l_ly_factor;
                      pnp_debug_pkg.debug('l_ly_factor='|| l_ly_factor);
                      l_factor := l_ly_factor;
               /* DBMS_OUTPUT.PUT_LINE('********* l_ly_factor ********* : '||l_ly_factor); */
        END IF;
                 END IF;

            END IF;

            l_row_exists :=  NULL;
            /* dbms_output.put_line('Step - 4'); */
            /*OPEN l_row_exists_cur ( p_var_rent_id
                                     ,c_grp.grp_date_id
                                     ,c_bkpt.line_item_id
                                     ,c_bkpt.bkpt_detail_id
                                     ,l_start_date
                                     ,l_end_date);
            FETCH l_row_exists_cur into l_row_exists;
            CLOSE l_row_exists_cur;*/

            --PNP_DEBUG_PKG.log('  l_row_exists = '||l_row_exists);
            PNP_DEBUG_PKG.DEBUG('l_row_exists = '||l_row_exists);
            pnp_debug_pkg.debug('l_pr_prorate_start = ' || l_pr_prorate_start);
            pnp_debug_pkg.debug('l_pr_prorate_end = ' || l_pr_prorate_end);
      /* DBMS_OUTPUT.PUT_LINE('p_var_rent_id       = '||p_var_rent_id);
      DBMS_OUTPUT.PUT_LINE('c_grp.grp_date_id     = '||c_grp.grp_date_id);
      DBMS_OUTPUT.PUT_LINE('c_bkpt.line_item_id   = '||c_bkpt.line_item_id);
      DBMS_OUTPUT.PUT_LINE('c_bkpt.bkpt_detail_id = '||c_bkpt.bkpt_detail_id);
      DBMS_OUTPUT.PUT_LINE('l_start_date    = '||l_start_date);
      DBMS_OUTPUT.PUT_LINE('l_end_date      = '||l_end_date);
            DBMS_OUTPUT.PUT_LINE('l_row_exists = '||l_row_exists);
            DBMS_OUTPUT.PUT_LINE('l_proration_factor = '||l_proration_factor);
            DBMS_OUTPUT.PUT_LINE('l_proration_rule = '||l_proration_rule);*/
            IF l_row_exists IS NULL THEN
              /* dbms_output.put_line('Step - 5 - Insert'); */
              PNP_DEBUG_PKG.DEBUG('inserting into pn_var_Transactions');
              pnp_debug_pkg.debug('l_factor = ' || l_factor);
              /*INSERT INTO pn_var_transactions_all (
                           transaction_id
                           ,grp_date_id
                          ,bkpt_detail_id
                          ,var_rent_id
                          ,line_item_id
                          ,period_id
                          ,period_start_date
                          ,period_end_date
                          ,group_date
                          ,invoice_date
                          ,bkpt_start_date
                          ,bkpt_end_date
                          ,no_of_group_days
                          ,no_of_bkpt_days
                          ,prorated_grp_vol_start
                          ,prorated_grp_vol_end
                          ,pr_grp_blended_vol_start
                          ,pr_grp_blended_vol_end
                          ,bkpt_rate
                          ,reset_group_id
                          ,proration_reset_group_id
                          ,proration_rule_factor
                          ,last_update_date
                          ,last_updated_by
                          ,creation_date
                          ,created_by
                          ,last_update_login
                         ,org_id
                      )values(
                          pn_var_transactions_s.nextval
                           ,c_grp.grp_date_id
                          ,c_bkpt.bkpt_detail_id
                          ,p_VAR_RENT_ID
                          ,c_bkpt.line_item_id
                          ,c_grp.period_id
                          ,l_period_start
                          ,l_period_end
                          ,c_grp.group_date
                          ,c_grp.invoice_date
                          ,l_start_date
                          ,l_end_date
                          ,c_grp.no_of_group_days
                          ,l_calc_days
                          ,l_prorate_start
                          ,l_prorate_end
                          ,l_pr_prorate_start
                          ,l_pr_prorate_end
                          ,c_bkpt.bkpt_rate
                          ,l_reset_group_id
                          ,l_pro_reset_group_id
                          ,l_factor
                          ,sysdate
                          ,NVL(fnd_profile.value('USER_ID'),0)
                          ,sysdate
                          ,NVL(fnd_profile.value('USER_ID'),0)
                          ,NVL(fnd_profile.value('USER_ID'),0)
                          ,to_number(decode(substr(userenv('CLIENT_INFO'),1,1),' ',null,substr(userenv('CLIENT_INFO'),1,10)))
                          );*/
                        PNP_DEBUG_PKG.DEBUG('Rows Inserted='||to_char(sql%rowcount));

            ELSE
               /*dbms_output.put_line('Step - 5 - update'); */
               --PNP_DEBUG_PKG.log('  update pn_var_Transactions');
               --PNP_DEBUG_PKG.log('  l_factor ='|| l_factor);
               PNP_DEBUG_PKG.DEBUG('update pn_var_Transactions');
               PNP_DEBUG_PKG.DEBUG('l_factor ='|| l_factor);
               /*UPDATE pn_var_transactions_all
               SET    no_of_group_days =c_grp.no_of_group_days
                      ,no_of_bkpt_days =l_calc_days
                      ,prorated_grp_vol_start =l_prorate_start
                      ,prorated_grp_vol_end =l_prorate_end
                      ,pr_grp_blended_vol_start =l_pr_prorate_start
                      ,pr_grp_blended_vol_end =l_pr_prorate_end
                      ,proration_rule_factor = l_factor
                      ,bkpt_rate = c_bkpt.bkpt_rate
                      ,last_update_date =sysdate
                      ,last_updated_by = NVL(fnd_profile.value('USER_ID'),0)
                      ,last_update_login = NVL(fnd_profile.value('USER_ID'),0 )
               WHERE  var_rent_id = p_var_rent_id
               AND    grp_date_id = c_grp.grp_date_id
               AND    line_item_id = c_bkpt.line_item_id
               AND    bkpt_detail_id = c_bkpt.bkpt_detail_id
               AND    bkpt_start_date = l_start_date
               AND    bkpt_end_date = l_end_date;*/
               /*DBMS_OUTPUT.PUT_LINE('  Step1 l_pr_prorate_start='||l_pr_prorate_start);
               DBMS_OUTPUT.PUT_LINE('  Step1 Rows Updated='||to_char(sql%rowcount));*/
            END IF;

         END IF;
       END LOOP;

       END LOOP;

       -------------------------
       -- Get Proration Rule
       -------------------------
       pnp_debug_pkg.debug('Call pn_var_rent_pkg.get_proration_rule');
       l_proration_rule := pn_var_rent_pkg.get_proration_rule(
                           p_var_rent_id =>p_var_rent_id);
       pnp_debug_pkg.debug('Proration Rule = '||l_proration_rule);

       ------------------------
       -- Initialize - reset_grp_id_cnt and proration_reset_grp_id_cnt
       ------------------------
       -- 11-AUG-03 Chris.T. - Proration Rule Specific - End --
       pnp_debug_pkg.debug('Determine_resets');
       l_reset_group_id_cnt := 0; -- 24-JUL-03 Chris T --
       l_pro_reset_group_id_cnt := NULL; -- 11-AUG-03 Chris.T --

       ---------------------------------------
       --- IF pro-ration rule is LY or FLY, then get the
       --  last complete period id and the start of the 365 days
       --  We will then trip the proration_reset_group_id at that
       -- point so that the ytdsales and breakpoint will start
       -- from the 365 calendar start.
       --------------------------------------

       IF l_proration_rule IN ('FY','LY','FLY') THEN   --Chris.T Added FY 11DEC03

          l_last_complete_period_id := get_last_complete_period_id ( p_var_rent_id => p_var_rent_id) ;
          l_ly_365_start_date := get_ly_365_start_date ( p_var_rent_id => p_var_rent_id);
          l_fy_365_end_Date := get_fy_365_end_date ( p_var_rent_id => p_var_rent_id);

          --dbms_output.put_line('l_last_complete_period = '|| l_last_complete_period_id);
          --dbms_output.put_line('l_ly_365_start_date = '|| l_ly_365_start_date);

   --Srini 11AUG2004 if last year is not a complete year then the
   --                proration_reset_group_id is not set properly
   IF l_last_complete_period_id IS NULL THEN
     IF l_proration_rule IN ('LY', 'FLY') THEN
       BEGIN
         SELECT MAX(period_id)
         INTO l_last_complete_period_id
         FROM pn_var_periods_all
         WHERE var_rent_id = p_var_rent_id
         AND l_ly_365_start_date BETWEEN start_date AND end_date;
         EXCEPTION
     WHEN OTHERS THEN
       l_last_complete_period_id := NULL;
       END;
     END IF;
   END IF;

       END IF;

       /*FOR c_flag IN csr_find_resets (p_var_rent_id) LOOP

          --pnp_debug_pkg.log('  Calling determine reset flag for Start Date = '||to_char(c_flag.bkpt_start_date,'DD-MON-YY'));
          --pnp_debug_pkg.log('  Period ID ='||to_char(c_flag.period_id));
          --pnp_debug_pkg.log('  Line Item ID ='||to_char(c_flag.line_item_id));
          --pnp_debug_pkg.log('  Item Category Code ='||c_flag.item_category_code);
          --pnp_debug_pkg.log('  Sales Type Code ='||c_flag.sales_type_code);
          --pnp_debug_pkg.log('  Group Date ='||c_flag.group_date);
          pnp_debug_pkg.debug('Calling determine reset flag for Start Date = '||to_char(c_flag.bkpt_start_date,'DD-MON-YY'));
          pnp_debug_pkg.debug('Period ID ='||to_char(c_flag.period_id));
          pnp_debug_pkg.debug('Line Item ID ='||to_char(c_flag.line_item_id));
          pnp_debug_pkg.debug('Item Category Code ='||c_flag.item_category_code);
          pnp_debug_pkg.debug('Sales Type Code ='||c_flag.sales_type_code);
          pnp_debug_pkg.debug('Group Date ='||c_flag.group_date);
          determine_reset_flag (p_var_rent_id   => p_var_rent_id,
                                p_period_id     => c_flag.period_id,
                                p_item_category_code  => c_flag.item_category_code,
                                p_sales_type_code  => c_flag.sales_type_code,
                                p_start_date    => c_flag.bkpt_start_date,
                                x_reset_flag    => l_reset_flag);
          pnp_debug_pkg.debug('Update pn_var_Transactions with reset flag=  '||l_reset_flag);
          -- 24-JUL-03 Chris T - Start --
          IF l_reset_flag = 'Y' THEN
            l_reset_group_id_cnt := l_reset_group_id_cnt + 1;
            --pnp_debug_pkg.log('  Reset Group ID Count = '||to_char(l_reset_group_id_cnt));
            pnp_debug_pkg.debug('Reset Group ID Count = '||to_char(l_reset_group_id_cnt));
          END IF;

          /*UPDATE pn_var_transactions_all
          SET reset_group_id = l_reset_group_id_cnt --24-JUL-03 Chris T--
          WHERE var_rent_id = p_VAR_RENT_ID
          AND   period_id   = c_flag.period_id
          AND   line_item_id   = c_flag.line_item_id
          AND bkpt_start_date = c_flag.bkpt_start_date;
          -- 24-JUL-03 Chris T - End --

          -- 11-AUG-03 Chris.T. - Proration Rule Specific  - Start --
          IF l_proration_rule in ( 'CYNP','CYP','FY','LY','FLY') THEN

            determine_reset_flag (p_var_rent_id   => p_var_rent_id,
                                  p_period_id     => NULL,
                                  p_item_category_code  => c_flag.item_category_code,
                                  p_sales_type_code  => c_flag.sales_type_code,
                                  p_start_date    => c_flag.bkpt_start_date,
                                  x_reset_flag    => l_reset_flag);

            /* dbms_output.put_line('  l_proration_rule = ' || l_proration_rule);
            dbms_output.put_line('  c_flag.period_id = ' || c_flag.period_id);
            dbms_output.put_line('  l_last_complete_period_id= ' || l_last_complete_period_id);
            dbms_output.put_line('  c_flag.group_date = ' || c_flag.group_date );
            dbms_output.put_line('  l_ly_365_start_date= ' || l_ly_365_start_date);
            dbms_output.put_line('  g_reset_complete = '|| nvl(g_reset_complete,'x'));

            IF l_proration_rule in ('LY' , 'FLY') AND
               c_flag.period_id = l_last_complete_period_id  AND
               c_flag.group_date = l_ly_365_start_date  AND
               g_reset_complete is  NULL THEN
               g_reset_complete := 'Y'  ;
               l_pro_reset_group_id_cnt := nvl(l_pro_reset_group_id_cnt ,0)+ 1;
               g_pro_reset_group_id_cnt := l_pro_reset_group_id;
               --l_pro_reset_group_id_cnt := nvl(g_pro_reset_group_id_cnt ,0)+ 1;
               --g_pro_reset_group_id_cnt := l_pro_reset_group_id;
              --pnp_debug_pkg.log('  365 New Proration Reset Group ID Count = '||to_char(l_pro_reset_group_id_cnt));
              pnp_debug_pkg.debug('365 New Proration Reset Group ID Count = '||to_char(l_pro_reset_group_id_cnt));
              /* dbms_output.put_line('365 New Proration Reset Group ID Count = '||to_char(l_pro_reset_group_id_cnt));
              pnp_debug_pkg.debug('365 New G Proration Reset Group ID Count = '||to_char(g_pro_reset_group_id_cnt));
            END IF;
            --pnp_debug_pkg.log('  l_reset_flag='||l_reset_flag);
            --pnp_debug_pkg.log('  l_proration_rule = '||l_proration_rule);
            --pnp_debug_pkg.log('  Group Date = '||c_flag.group_date);
            --pnp_debug_pkg.log('  l_fy_365_end_date = '||l_fy_365_end_date);
            --pnp_debug_pkg.log('  l_ly_365_start_date = '||l_ly_365_start_date);
            pnp_debug_pkg.debug('l_reset_flag='||l_reset_flag);
            pnp_debug_pkg.debug('l_proration_rule = '||l_proration_rule);
            pnp_debug_pkg.debug('Group Date = '||c_flag.group_date);
            pnp_debug_pkg.debug('l_fy_365_end_date = '||l_fy_365_end_date);
            pnp_debug_pkg.debug('l_ly_365_start_date = '||l_ly_365_start_date);
            /* dbms_output.put_line('l_reset_flag='||l_reset_flag);
            dbms_output.put_line('l_proration_rule = '||l_proration_rule);
            dbms_output.put_line('Group Date = '||c_flag.group_date);
            dbms_output.put_line('l_fy_365_end_date = '||l_fy_365_end_date);
            dbms_output.put_line('l_ly_365_start_date = '||l_ly_365_start_date);
            IF l_reset_flag = 'Y' THEN
               IF l_proration_rule = 'FY' AND
                   c_flag.group_date > l_fy_365_end_date THEN
                  l_pro_reset_group_id := NULL;
                  pnp_debug_pkg.debug('FY');
               ELSIF l_proration_rule = 'LY' AND
                   c_flag.group_date < l_ly_365_start_date THEN
                  l_pro_reset_group_id := NULL;
                  /* dbms_output.put_line('aaa');
                  pnp_debug_pkg.debug('LY');
               ELSIF l_proration_rule  = 'FLY' and
                  (c_flag.group_Date > l_fy_365_end_date and
                   c_flag.group_Date < l_ly_365_start_date) THEN
                  l_pro_reset_group_id := NULL;
                  pnp_debug_pkg.debug('FLY');
                  /* dbms_output.put_line('Reset to NULL FLY');
               ELSE
                  l_pro_reset_group_id_cnt := nvl(l_pro_reset_group_id_cnt ,0)+ 1;
                  g_pro_reset_group_id_cnt := l_pro_reset_group_id;
                  pnp_debug_pkg.debug('New Proration Reset Group ID Count = '||to_char(l_pro_reset_group_id_cnt));
                  pnp_debug_pkg.debug('New G Proration Reset Group ID Count = '||to_char(g_pro_reset_group_id_cnt));
               END IF;
            ELSE
               IF l_proration_rule = 'FY' AND
                   c_flag.group_date > l_fy_365_end_date THEN
                  l_pro_reset_group_id := NULL;
               ELSIF l_proration_rule = 'LY' AND
                   c_flag.group_date < l_ly_365_start_date THEN
                  l_pro_reset_group_id := NULL;
                  /* dbms_output.put_line('aaa');
               ELSIF l_proration_rule  = 'FLY' THEN -- and
                 pnp_debug_pkg.debug('FLY');
                 --pnp_debug_pkg.log('  FLY');
                 IF c_flag.group_Date > l_fy_365_end_date and  --Chris.T. 17MAR2004
                    c_flag.group_Date < l_ly_365_start_date THEN
                    l_pro_reset_group_id := NULL;
                    /* dbms_output.put_line('Reset to NULL FLY');
                 ELSIF c_flag.group_Date >= l_ly_365_start_date THEN
                   NULL;
                   /* dbms_output.put_line('FLY - l_pro_reset_group_id_cnt = '||l_pro_reset_group_id_cnt);
                 END IF;
               END IF;
            END IF;

            /*UPDATE pn_var_transactions_all
            SET    proration_reset_group_id = l_pro_reset_group_id_cnt
            WHERE  var_rent_id = p_VAR_RENT_ID
            AND    period_id   = c_flag.period_id
            AND    line_item_id   = c_flag.line_item_id
            AND    bkpt_start_date = c_flag.bkpt_start_date;

          END IF; --IF l_proration_rule in ( 'CYNP','CYP','FY','LY','FLY') THEN

    pnp_debug_pkg.debug('------------------------------- ');
  END LOOP;*/
  NULL;

  --Start Srini 08SEP2004
  IF l_proration_rule IN ('LY', 'FLY') AND l_ly_365_start_dt < l_fy_end_date THEN
    BEGIN
      --Findout invoicing freq
      SELECT invg_freq_code
      INTO l_invg_freq
      FROM pn_var_rent_dates_all
      WHERE var_rent_id = p_var_rent_id;
      /* DBMS_OUTPUT.PUT_LINE('  l_invg_freq:'||l_invg_freq); */
      pnp_debug_pkg.log('  l_invg_freq:'||l_invg_freq);
      EXCEPTION
  WHEN OTHERS THEN
    l_invg_freq := 'MON';
    END;

    /*FOR i4 IN update_365_days_bkpt(l_ly_365_end_dt)
    LOOP

      FOR i2 IN csr_get_groups (p_var_rent_id,p_period_id)
      LOOP
        l_commencement_date := i2.commencement_date;
        l_period_start      := i2.start_date;
        l_period_end        := i2.end_date;

        FOR i3 IN csr_get_bkpts (i2.period_id)
        LOOP
          IF i2.grp_start_date between i3.bkpt_start_date and i3.bkpt_end_date
          OR i2.grp_end_date between i3.bkpt_start_date and i3.bkpt_end_date
          OR i3.bkpt_start_date between i2.grp_start_date and i2.grp_end_date
          OR i3.bkpt_end_date between i2.grp_start_date and i2.grp_end_date THEN
            IF i2.grp_start_date >= i3.bkpt_start_date THEN
              l_start_date := i2.grp_start_date;
            ELSE
              l_start_date := i3.bkpt_start_date;
            END IF;
            IF i2.grp_end_date <= i3.bkpt_end_date THEN
              l_end_date := i2.grp_end_date;
            ELSE
              l_end_date := i3.bkpt_end_date;
            END IF;

      IF l_end_date = l_ly_365_end_dt THEN
              l_calc_days := (l_end_date - l_start_date)+1;

              IF l_proration_rule = 'NP' THEN
              --IF l_proration_rule IN ('NP', 'LY', 'FLY') THEN
                l_proration_factor := 1;
        ELSE
                l_proration_factor := l_calc_days/i2.no_of_group_days;
        END IF;

              IF l_proration_rule = 'NP' THEN
                l_prorate_start := i3.period_bkpt_vol_start;
              ELSE
                l_prorate_start := (i3.group_bkpt_vol_start*i2.proration_factor)*l_proration_factor;
              END IF;

              IF i3.group_bkpt_vol_end > 0 THEN
                IF l_proration_rule = 'NP' THEN
                  l_prorate_end   := i3.period_bkpt_vol_end;
                ELSE
                  l_prorate_end   := (i3.group_bkpt_vol_end*i2.proration_factor)*l_proration_factor;
                END IF;
              ELSE
          l_prorate_end := 0;
              END IF;

        IF l_prorate_end <> 0 THEN
                /*DBMS_OUTPUT.PUT_LINE('  Step1 l_prorate_start = '||l_prorate_start);
                DBMS_OUTPUT.PUT_LINE('  Step1 l_prorate_end = '||l_prorate_end);
                DBMS_OUTPUT.PUT_LINE('  Step1 i4.reset_group_id = '||i4.reset_group_id);
                DBMS_OUTPUT.PUT_LINE('  Step1 i4.proration_reset_group_id = '||i4.proration_reset_group_id);

          BEGIN
      SELECT COUNT(*)
      INTO l_cnt
      FROM pn_var_transactions_all
      WHERE var_rent_id = p_var_rent_id
      AND bkpt_end_date = l_ly_365_end_dt
      AND NVL(pr_grp_blended_vol_end, 0) <> 0;
      EXCEPTION
        WHEN OTHERS THEN
          l_cnt := 1;
          END;
                /* DBMS_OUTPUT.PUT_LINE('  l_cnt:'||l_cnt);
                BEGIN
                  --Determine no of bkpt days
                  SELECT SUM(no_of_bkpt_days)/l_cnt
                  INTO l_bkpt_days1
                  FROM pn_var_transactions_all
                  WHERE var_rent_id = p_var_rent_id
                  AND NVL(proration_reset_group_id, 0) = NVL(i4.proration_reset_group_id, 0)
                  --AND NVL(reset_group_id, 0) = NVL(i4.reset_group_id, 0)
      AND NVL(pr_grp_blended_vol_end, 0) <> 0;
                  --AND prorated_group_sales IS NOT NULL;
                  pnp_debug_pkg.log('  l_bkpt_days1 = '||l_bkpt_days1);
                  /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days1:'||l_bkpt_days1);

                  --Determine no of days for which bkpt is missing
                  l_bkpt_days2 := (l_ly_365_end_dt - ADD_MONTHS(l_ly_365_end_dt, -12)) - l_bkpt_days1;
                  pnp_debug_pkg.log('  l_bkpt_days2 = '||l_bkpt_days2);
                  /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days2:'||l_bkpt_days2);

                  EXCEPTION
                    WHEN OTHERS THEN
                      l_bkpt_days2 := NULL;
                      /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days2:'||l_bkpt_days2);
                END;

                IF l_bkpt_days2 IS NOT NULL THEN
      IF l_bkpt_days2 <> 0 THEN
                    --Determine Actual bkpt start and bkpt end
        l_pr_start := l_prorate_start;
        l_pr_end   := l_prorate_end;
                    BEGIN
                      SELECT DECODE(l_invg_freq, 'MON', 0, l_prorate_start) + ((SUM(pr_grp_blended_vol_start) /
                                       SUM(no_of_bkpt_days)) * l_bkpt_days2),
                             DECODE(l_invg_freq, 'MON', 0, l_prorate_end) + ((SUM(pr_grp_blended_vol_end) /
                                     SUM(no_of_bkpt_days)) * l_bkpt_days2)
                      INTO l_prorate_start, l_prorate_end
                      FROM pn_var_transactions_all
                      WHERE var_rent_id = p_var_rent_id
                      AND NVL(proration_reset_group_id, 0) <> NVL(i4.proration_reset_group_id, 0)
                      --AND NVL(reset_group_id, 0) <> NVL(i4.reset_group_id, 0)
                      AND bkpt_end_date BETWEEN ADD_MONTHS(i4.bkpt_start_date, -11) AND i4.bkpt_start_date
          AND NVL(pr_grp_blended_vol_end, 0) <> 0;
                      --AND prorated_group_sales IS NOT NULL;
                      EXCEPTION
                        WHEN OTHERS THEN
        --Will not come here
                        l_prorate_start := l_pr_start;
                        l_prorate_end   := l_pr_end;
                    END;
      END IF;
      IF l_prorate_start IS NULL THEN
        l_prorate_start := l_pr_start;
        l_prorate_end   := l_pr_end;
      END IF;

                  pnp_debug_pkg.log('  l_prorate_start = '||l_prorate_start);
                  pnp_debug_pkg.log('  l_prorate_end = '||l_prorate_end);
                  /* DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_start = '||l_prorate_start);
                  DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_end = '||l_prorate_end);

                  UPDATE pn_var_transactions_all
                  SET prorated_grp_vol_start  = l_prorate_start
                     ,prorated_grp_vol_end  = l_prorate_end
                     ,pr_grp_blended_vol_start  = l_prorate_start
                     ,pr_grp_blended_vol_end  = l_prorate_end
                     ,last_update_date    = SYSDATE
                     ,last_updated_by     = NVL(FND_PROFILE.VALUE('USER_ID'),0)
                     ,last_update_login   = NVL(FND_PROFILE.VALUE('USER_ID'),0 )
                  WHERE transaction_id = i4.transaction_id;
                  /* DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_start='||l_prorate_start);
                  DBMS_OUTPUT.PUT_LINE('  Step2 Rows Updated='||TO_CHAR(SQL%ROWCOUNT));

                END IF; --l_bkpt_days2 IS NOT NULL
              END IF;   --l_bkpt_end <> 0
      END IF; --l_end_date = l_ly_365_end_dt
    END IF; --multiple condition
        END LOOP; --i3
      END LOOP;   --i2
    END LOOP;   --i4  */

    /*FOR i4 IN update_365_days_bkpt_strat(l_ly_365_end_dt)
    LOOP

      FOR i2 IN csr_get_groups (p_var_rent_id,p_period_id)
      LOOP
        l_commencement_date := i2.commencement_date;
        l_period_start      := i2.start_date;
        l_period_end        := i2.end_date;

        FOR i3 IN csr_get_bkpts (i2.period_id)
        LOOP
          IF i2.grp_start_date between i3.bkpt_start_date and i3.bkpt_end_date
          OR i2.grp_end_date between i3.bkpt_start_date and i3.bkpt_end_date
          OR i3.bkpt_start_date between i2.grp_start_date and i2.grp_end_date
          OR i3.bkpt_end_date between i2.grp_start_date and i2.grp_end_date THEN
            IF i2.grp_start_date >= i3.bkpt_start_date THEN
              l_start_date := i2.grp_start_date;
            ELSE
              l_start_date := i3.bkpt_start_date;
            END IF;
            IF i2.grp_end_date <= i3.bkpt_end_date THEN
              l_end_date := i2.grp_end_date;
            ELSE
              l_end_date := i3.bkpt_end_date;
            END IF;

      IF l_end_date = l_ly_365_end_dt THEN
              l_calc_days := (l_end_date - l_start_date)+1;

              IF l_proration_rule = 'NP' THEN
              --IF l_proration_rule IN ('NP', 'LY', 'FLY') THEN
                l_proration_factor := 1;
        ELSE
                l_proration_factor := l_calc_days/i2.no_of_group_days;
        END IF;

              IF l_proration_rule = 'NP' THEN
                l_prorate_start := i3.period_bkpt_vol_start;
              ELSE
                l_prorate_start := (i3.group_bkpt_vol_start*i2.proration_factor)*l_proration_factor;
              END IF;

              IF i3.group_bkpt_vol_end > 0 THEN
                IF l_proration_rule = 'NP' THEN
                  l_prorate_end   := i3.period_bkpt_vol_end;
                ELSE
                  l_prorate_end   := (i3.group_bkpt_vol_end*i2.proration_factor)*l_proration_factor;
                END IF;
              ELSE
          l_prorate_end := 0;
              END IF;

        IF l_prorate_end = 0 THEN
                /* DBMS_OUTPUT.PUT_LINE('  Step1 l_prorate_start = '||l_prorate_start);
                DBMS_OUTPUT.PUT_LINE('  Step1 l_prorate_end = '||l_prorate_end);
                DBMS_OUTPUT.PUT_LINE('  Step1 i4.reset_group_id = '||i4.reset_group_id);
                DBMS_OUTPUT.PUT_LINE('  Step1 i4.proration_reset_group_id = '||i4.proration_reset_group_id);

          BEGIN
      SELECT COUNT(*)
      INTO l_cnt
      FROM pn_var_transactions_all
      WHERE var_rent_id = p_var_rent_id
      AND bkpt_end_date = l_ly_365_end_dt
      AND NVL(pr_grp_blended_vol_end, 0) = 0;
      EXCEPTION
        WHEN OTHERS THEN
          l_cnt := 1;
          END;
                /* DBMS_OUTPUT.PUT_LINE('  l_cnt:'||l_cnt);
                BEGIN
                  --Determine no of bkpt days
                  SELECT SUM(no_of_bkpt_days)/l_cnt
                  INTO l_bkpt_days1
                  FROM pn_var_transactions_all
                  WHERE var_rent_id = p_var_rent_id
                  AND NVL(proration_reset_group_id, 0) = NVL(i4.proration_reset_group_id, 0)
                  --AND NVL(reset_group_id, 0) = NVL(i4.reset_group_id, 0)
      AND NVL(pr_grp_blended_vol_end, 0) = 0;
                  --AND prorated_group_sales IS NOT NULL;
                  pnp_debug_pkg.log('  l_bkpt_days1 = '||l_bkpt_days1);
                  /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days1:'||l_bkpt_days1);

                  --Determine no of days for which bkpt is missing
                  l_bkpt_days2 := (l_ly_365_end_dt - ADD_MONTHS(l_ly_365_end_dt, -12)) - l_bkpt_days1;
                  pnp_debug_pkg.log('  l_bkpt_days2 = '||l_bkpt_days2);
                  /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days2:'||l_bkpt_days2);

                  EXCEPTION
                    WHEN OTHERS THEN
                      l_bkpt_days2 := NULL;
                      /* DBMS_OUTPUT.PUT_LINE('  l_bkpt_days2:'||l_bkpt_days2);
                END;

                IF l_bkpt_days2 IS NOT NULL THEN
      IF l_bkpt_days2 <> 0 THEN
                    --Determine Actual bkpt start and bkpt end
        l_pr_start := l_prorate_start;
        l_pr_end   := l_prorate_end;
                    BEGIN
                      SELECT DECODE(l_invg_freq, 'MON', 0, l_prorate_start) + ((SUM(pr_grp_blended_vol_start) /
                                       SUM(no_of_bkpt_days)) * l_bkpt_days2),
                             DECODE(l_invg_freq, 'MON', 0, l_prorate_end) + ((SUM(pr_grp_blended_vol_end) /
                                     SUM(no_of_bkpt_days)) * l_bkpt_days2)
                      INTO l_prorate_start, l_prorate_end
                      FROM pn_var_transactions_all
                      WHERE var_rent_id = p_var_rent_id
                      AND NVL(proration_reset_group_id, 0) <> NVL(i4.proration_reset_group_id, 0)
                      --AND NVL(reset_group_id, 0) <> NVL(i4.reset_group_id, 0)
                      AND bkpt_end_date BETWEEN ADD_MONTHS(i4.bkpt_start_date, -11) AND i4.bkpt_start_date
          AND NVL(pr_grp_blended_vol_end, 0) = 0;
                      --AND prorated_group_sales IS NOT NULL;
                      EXCEPTION
                        WHEN OTHERS THEN
        --Will not come here
                        l_prorate_start := l_pr_start;
                        l_prorate_end   := l_pr_end;
                    END;
      END IF;
      IF l_prorate_start IS NULL THEN
        l_prorate_start := l_pr_start;
        l_prorate_end   := l_pr_end;
      END IF;

                  pnp_debug_pkg.log('  l_prorate_start = '||l_prorate_start);
                  pnp_debug_pkg.log('  l_prorate_end = '||l_prorate_end);
                  /* DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_start = '||l_prorate_start);
                  DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_end = '||l_prorate_end);

                  UPDATE pn_var_transactions_all
                  SET prorated_grp_vol_start  = l_prorate_start
                     ,prorated_grp_vol_end  = l_prorate_end
                     ,pr_grp_blended_vol_start  = l_prorate_start
                     ,pr_grp_blended_vol_end  = l_prorate_end
                     ,last_update_date    = SYSDATE
                     ,last_updated_by     = NVL(FND_PROFILE.VALUE('USER_ID'),0)
                     ,last_update_login   = NVL(FND_PROFILE.VALUE('USER_ID'),0 )
                  WHERE transaction_id = i4.transaction_id;
                  /* DBMS_OUTPUT.PUT_LINE('  Step2 l_prorate_start='||l_prorate_start);
                  DBMS_OUTPUT.PUT_LINE('  Step2 Rows Updated='||TO_CHAR(SQL%ROWCOUNT));

                END IF; --l_bkpt_days2 IS NOT NULL
              END IF;   --l_bkpt_end = 0
      END IF; --l_end_date = l_ly_365_end_dt
    END IF; --multiple condition
        END LOOP; --i3
      END LOOP;   --i2
    END LOOP;   --i4 */
  END IF;
  --End Srini 08SEP2004

  -- Call Procedure to update blended_period_vol_start and
  -- belnded_period_vol_end with the appropriate sum of the
  -- prorated_grp_vol_start and prorated_grp_vol_end, grouped
  -- by period_id, line_item_id, reset_group_id and bkpt_rate
  -- for the current var_rent_id
  -- 24-JUL-03 Chris.T.
  ---------------------------------------------------------
  pnp_debug_pkg.log('  Call to Update Blended Period Volume - Start and END');
  pnp_debug_pkg.debug('Call to Update Blended Period Volume - Start and END');


  IF l_proration_rule IN ('CYNP','CYP') THEN
      update_blended_period(p_var_rent_id => p_var_rent_id,
                            p_start_date => l_commencement_date,
                            p_proration_rule => l_proration_rule);
  ELSE
    --IF l_proration_rule <> 'NP' THEN --Chris.T. 10FEB2004
      update_blended_period(p_var_rent_id => p_var_rent_id);
    --END IF; --Chris.T. 10FEB2004
  END IF;

  pnp_debug_pkg.log('  Call update_ytd_bkpts');
  pnp_debug_pkg.debug('Call update_ytd_bkpts');
  update_ytd_bkpts ( p_var_rent_id => p_var_rent_id,
                     p_period_id   => p_period_id);

  COMMIT;

  pnp_debug_pkg.debug('End of Populate_Transactions');
  PNP_DEBUG_PKG.log('PN_VAR_CHG_CAL_PKG.populate_transactions  (-)');
  --pnp_debug_pkg.disable_file_debug;
  EXCEPTION
   When OTHERS THEN
     /* dbms_output.put_line(' Error While Running Populate Transactions:' || SQLERRM); */
     null;

END populate_transactions;

/*===========================================================================+
 | PROCEDURE UPDATE_YTD_BKPTS
 |
 | DESCRIPTION
 |   This procedure will add the grup breakpoints to arrive at the YTD breakpoints
 |   the summation is reset whenever there is rate change between groups.
 |   In case of proration rule being combined sales with no proration or
 |   combined year sales with proration   we will add across the
 |   periods. i.e the summation does not reset when the period changes. In all
 |   other cases the ytd summation resets when the period changes.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    P_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     16-MAR-2003  graghuna o Created
 +===========================================================================*/
PROCEDURE update_ytd_bkpts(p_var_rent_id IN NUMBER,
                           p_period_id   IN NUMBER,
                           p_start_date  IN DATE ,
                           p_end_date    IN DATE)
IS

   /* Chris.T. 13-Aug-03 -- To accomodate Proration rules -- Start*/
   CURSOR get_periods_cur IS
   SELECT pvt.period_id,pvt.start_date,pvt.end_date,pvt.partial_period
         ,pvr.proration_rule
   FROM   pn_var_periods_all pvt
         ,pn_var_rents_all   pvr
   WHERE  pvt.var_Rent_id = p_var_rent_id
   AND    pvt.var_rent_id = pvr.var_rent_id
   ORDER  by pvt.start_date;
   /* Chris.T. 13-Aug-03 -- To accomodate Proration rules -- End*/

   /* Chris.T. 11-Aug-03 -- To accomodate Proration rules -- Start*/
   /*CURSOR pn_var_trx_cur  IS
   SELECT  pvt.*
          ,pvl.sales_type_code
          ,pvl.item_category_code
          ,pvr.proration_rule
          ,per.partial_period
          ,per.start_date
          ,per.end_date
   FROM    pn_var_transactions_all pvt
          ,pn_var_lines_all pvl
          ,pn_var_periods_all per
          ,pn_var_rents_all   pvr
   WHERE   pvt.var_rent_id = p_var_rent_id
   AND     per.period_id = NVL(p_period_id,per.period_id)
   AND     pvt.period_id = per.period_id
   AND     pvt.period_id = pvl.period_id
   AND     per.var_rent_id = pvr.var_rent_id
   AND     pvt.line_item_id = pvl.line_item_id
   AND     pvt.bkpt_start_date >= NVL(p_start_date,pvt.bkpt_start_date)
   AND     pvt.bkpt_end_date   <= NVL(p_end_date , pvt.bkpt_end_date)
   ORDER BY pvl.sales_type_code,pvl.item_category_code,pvt.period_id,
          pvt.reset_group_id,pvt.bkpt_rate,pvt.bkpt_start_date,pvt.pr_grp_blended_vol_start;

   CURSOR pn_var_trx_cur_pro  IS
   SELECT  pvt.*
          ,pvl.sales_type_code
          ,pvl.item_category_code
          ,pvr.proration_rule
          ,per.partial_period
          ,per.start_date
          ,per.end_date
   FROM    pn_var_transactions_all pvt
          ,pn_var_lines_all pvl
          ,pn_var_periods_all per
          ,pn_var_rents_all   pvr
   WHERE   pvt.var_rent_id = p_var_rent_id
   AND     per.period_id = NVL(p_period_id,per.period_id)
   AND     pvt.period_id = per.period_id
   AND     pvt.period_id = pvl.period_id
   AND     per.var_rent_id = pvr.var_rent_id
   AND     pvt.line_item_id = pvl.line_item_id
   AND     pvt.bkpt_start_date >= NVL(p_start_date,pvt.bkpt_start_date)
   AND     pvt.bkpt_end_date   <= NVL(p_end_date , pvt.bkpt_end_date)
   AND     pvr.proration_rule NOT IN ('STD','NP')
   ORDER BY pvl.sales_type_code,pvl.item_category_code,
           pvt.proration_reset_group_id,pvt.bkpt_rate,
           pvt.bkpt_start_date,pvt.pr_grp_blended_vol_start;*/

   CURSOR pn_var_grp_dt (p_var_rent_id NUMBER) IS
   SELECT max(group_date), min(group_date), min(grp_start_date)+364
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id;

   CURSOR get_max_per_grp_dt (p_var_rent_id NUMBER --Chris.T. 19-NOV-03
                             ,p_period_id NUMBER) IS
   SELECT max(group_date)
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    period_id = p_period_id;


   CURSOR get_invoice_grp_dt (p_var_rent_id NUMBER
                             ,p_period_id NUMBER
                             ,p_min_grp_dt_364 DATE) IS
   SELECT  group_date
   FROM    pn_var_grp_dates_all
   WHERE   var_rent_id = p_var_rent_id
   --AND     period_id = p_period_id
   AND     grp_start_date <= p_min_grp_dt_364
   AND     grp_end_date   >= p_min_grp_dt_364;
   /* Chris.T. 11-Aug-03 -- To accomodate Proration rules -- End*/

  Cursor is_last_year_partial IS
  SELECT period_id,partial_period
  FROM    pn_var_periods_all
  WHERE  period_id  = (SELECT max(period_id)
                       FROM pn_var_periods_all
                       WHERE var_rent_id = p_var_rent_id);

   l_summ_vol_start             NUMBER := 0;
   l_summ_vol_end               NUMBER := 0;
   l_pro_bkpt_vol_start         NUMBER := 0;
   l_pro_bkpt_vol_end           NUMBER := 0;
   l_old_period_id              NUMBER := 0;
   l_old_line_item_id           NUMBER := 0;
   l_old_bkpt_rate              NUMBER := 0;
   l_period_rownum              NUMBER := 0;
   l_proration_rule             VARCHAR2(30) := NULL;
   l_sales_type_code            VARCHAR2(30) := 'X'; /*11-AUG-03 Chris.T.*/
   l_item_category_code         VARCHAR2(30) := 'X'; /*11-AUG-03 Chris.T.*/
   l_first_partial_period       VARCHAR2(1):= 'X';
   l_last_partial_period        VARCHAR2(1):= 'X';
   l_last_partial_period_id     NUMBER;
   l_first_full_period          VARCHAR2(1):= 'X';
   l_old_reset_group_id         NUMBER := 99.99;
   l_old_pro_reset_group_id     NUMBER := 99.99;
   l_prv_partial_period         VARCHAR2(1) := 'X'; /*13-AUG-03 Chris.T.*/
   l_pro_invoice_flag           VARCHAR2(1) := 'X'; /*13-AUG-03 Chris.T.*/
   l_invoice_grp_dt             DATE; /*13-AUG-03 Chris.T.*/
   l_365_grp_dt                 DATE; /*13-AUG-03 Chris.T.*/
   l_max_grp_dt                 DATE; /*13-AUG-03 Chris.T.*/
   l_min_grp_dt                 DATE; /*13-AUG-03 Chris.T.*/
   l_min_grp_dt_364             DATE; /*13-AUG-03 Chris.T.*/
   l_first_partial_year         VARCHAR2(4); /*18-AUG-03 Chris.T.*/
   l_last_partial_year          VARCHAR2(4); /*18-AUG-03 Chris.T.*/
   l_curr_grp_date_year         VARCHAR2(4); /*18-AUG-03 Chris.T.*/
   l_old_partial_period         VARCHAR2(1);
   /*l_old_grp_date_id            pn_var_transactions_all.grp_date_id%TYPE;     --Chris.T 19-NOV-03
   l_old_bkpt_start_date        pn_var_transactions_all.bkpt_start_date%TYPE; --Chris.T 19-NOV-03
   l_old_bkpt_detail_id         pn_var_transactions_all.bkpt_detail_id%TYPE;  --Chris.T 19-NOV-03
   l_max_per_grp_dt             pn_var_grp_dates_all.group_date%TYPE;         --Chris.T 19-NOV-03
   l_old_group_date             pn_var_transactions_all.group_date%TYPE;      --Chris.T 19-NOV-03 */
   l_ly_365_start_date          DATE;
   l_fy_365_end_Date          DATE;
BEGIN

   /*13-AUG-03 Chris.T. -Start*/
   pnp_debug_pkg.debug('UPDATE_YTD_BKPTS (+)');
   pnp_debug_pkg.debug('Parameter : p_var_rent_id = '|| p_var_rent_id);
   pnp_debug_pkg.debug('Parameter : p_period_id = '|| p_period_id);
   OPEN pn_var_grp_dt(p_var_rent_id);
   FETCH pn_var_grp_dt into l_max_grp_dt, l_min_grp_dt, l_min_grp_dt_364;
   l_first_partial_year := to_char(l_min_grp_dt,'YYYY');
   l_last_partial_year  := to_char(l_max_grp_dt,'YYYY');
   IF pn_var_grp_dt%NOTFOUND THEN
     CLOSE pn_var_grp_dt;
     pnp_debug_pkg.debug('Raising no data found');
     RAISE NO_DATA_FOUND;
   ELSE
     pnp_debug_pkg.debug('Max = '||to_char(l_max_grp_dt,'MM/DD/YY')||
                         'Min = '||to_char(l_min_grp_dt,'MM/DD/YY')||
                         'Min_364 = '||to_char(l_min_grp_dt_364,'MM/DD/YY'));
   END IF;
   CLOSE pn_var_grp_dt;
   /*13-AUG-03 Chris.T. -End*/

   pnp_debug_pkg.debug('opening periods cursor');

   /*FOR pn_var_trx_rec in pn_var_trx_cur LOOP

      IF l_old_reset_group_id <> pn_var_trx_rec.reset_group_id
        OR l_old_period_id <> pn_var_trx_rec.period_id
        OR l_old_line_item_id <> pn_var_trx_rec.line_item_id
        OR l_old_bkpt_rate <> pn_var_trx_rec.bkpt_rate  THEN
        l_summ_vol_start   := 0;
        l_summ_vol_end     := 0;
        pnp_debug_pkg.debug('Reset/Initialize YTD Group Vol Start/End');
      END IF;

      l_summ_vol_start := l_summ_vol_start + pn_var_trx_rec.prorated_grp_vol_start;
      l_summ_vol_end   := l_summ_vol_end + pn_var_trx_rec.prorated_grp_vol_end;

      UPDATE pn_var_transactions_all
      SET    ytd_group_vol_start = l_summ_vol_start,
             ytd_group_vol_end   = l_summ_vol_end
      WHERE  grp_date_id = pn_var_trx_rec.grp_date_id
      AND    bkpt_start_date = pn_var_trx_rec.bkpt_start_date
      AND    bkpt_rate = pn_var_trx_rec.bkpt_rate
      AND    line_item_id = pn_var_trx_rec.line_item_id
      AND    bkpt_detail_id = pn_var_trx_rec.bkpt_detail_id
      AND    reset_group_id = pn_var_trx_rec.reset_group_id;
      pnp_debug_pkg.debug('Rows Updated = '||to_char(sql%rowcount));

      l_sales_type_code        := pn_var_trx_rec.sales_type_code;
      l_item_category_code     := pn_var_trx_rec.item_category_code;
      /* 11-AUG-03 Chris.T. - Proration Rule Specific -- End

      l_old_period_id := pn_var_trx_rec.period_id;
      l_old_line_item_id := pn_var_trx_rec.line_item_id;
      l_old_reset_group_id := pn_var_trx_rec.reset_group_id;
      l_old_bkpt_rate := pn_var_trx_rec.bkpt_rate;

   END LOOP; */-- pn_var_trex_rec end loop;

   /*l_sales_type_code        := 'X';
   l_item_category_code     := 'X';
   l_old_period_id          := 0;
   l_old_line_item_id       := 0;
   l_old_reset_group_id     := 0;
   l_old_bkpt_rate          := 0;
   l_old_grp_date_id        := 0;    --Chris.T 19-NOV-03
   l_old_bkpt_start_date    := NULL; --Chris.T 19-NOV-03
   l_old_bkpt_detail_id     := 0;    --Chris.T 19-NOV-03
   l_old_pro_reset_group_id := 0;    --Chris.T 19-NOV-03


   FOR pn_var_trx_rec in pn_var_trx_cur_pro LOOP

      IF (l_old_period_id <> pn_var_trx_rec.period_id)THEN
          l_prv_partial_period := l_old_partial_period;  /*13-AUG-03 Chris.T.
          --Chris.T 19-NOV-03 Start
          pnp_debug_pkg.debug('Prev partial period = '||pn_var_trx_rec.partial_period);
          pnp_debug_pkg.debug('-----------------------------------------------');

      END IF;
      l_pro_invoice_flag := 'X'; /*Chris.T. 13-Aug-03
      l_curr_grp_date_year := to_char(pn_var_trx_rec.group_date,'YYYY'); /*Chris.T. 18-Aug-03

      --
      -- Proration Rule Based Processing
      --
      pnp_debug_pkg.debug('proration rule = '|| pn_var_trx_rec.proration_rule);
      IF pn_var_trx_rec.proration_rule IN ('FY','LY','FLY','CYNP','CYP') THEN /*Chris.T. 18-Aug-03

         IF l_ly_365_start_date IS NULL THEN
            l_ly_365_start_date := get_ly_365_start_date ( p_var_rent_id => p_var_rent_id);
          --dbms_output.put_line('l_ly_365_start_date = '|| l_ly_365_start_date);
            OPEN get_invoice_grp_dt (pn_var_trx_rec.var_rent_id
                                ,pn_var_trx_rec.period_id
                                ,l_ly_365_start_date);
            FETCH get_invoice_grp_dt INTO l_365_grp_dt;
            CLOSE get_invoice_grp_dt;
          --dbms_output.put_line('l_365_grp_dt = '|| l_365_grp_dt);

            FOR last_period_rec in is_last_year_partial LOOP
               l_last_partial_period_id := last_period_rec.period_id;
               l_last_partial_period := last_period_rec.partial_period;
               EXIT;
            END LOOP;
         END IF;

        /* 11-AUG-03 Chris.T. - Proration Rule Specific -- Start

        pnp_debug_pkg.debug(' group_date = ' || pn_var_trx_rec.group_date);
        pnp_debug_pkg.debug(' l_old_pro_reset_group_id = ' || l_old_pro_reset_group_id);
        pnp_debug_pkg.debug(' pn_var_trx_rec.proration_reset_group_id = ' || pn_var_trx_rec.proration_reset_group_id);
        pnp_debug_pkg.debug(' l_sales_type_code = ' || l_sales_type_code);
        pnp_debug_pkg.debug(' pn_var_trx_rec.sales_type_code = ' || pn_var_trx_rec.sales_type_code);
        pnp_debug_pkg.debug(' l_item_category_code = ' || l_item_category_code);
        pnp_debug_pkg.debug(' pn_var_trx_rec.item_category_code = ' || pn_var_trx_rec.item_category_code);
        pnp_debug_pkg.debug(' l_old_bkpt_rate = ' || l_old_bkpt_rate);
        pnp_debug_pkg.debug(' pn_var_trx_rec.bkpt_rate = ' || pn_var_trx_rec.bkpt_rate);
        pnp_debug_pkg.debug(' l_pro_bkpt_vol_start = ' || l_pro_bkpt_vol_start);
        pnp_debug_pkg.debug(' l_pro_bkpt_vol_end = ' || l_pro_bkpt_vol_end);

        /*dbms_output.put_line('Current group_date = ' || pn_var_trx_rec.group_date);
        --dbms_output.put_line(' l_old_pro_reset_group_id = ' || l_old_pro_reset_group_id);
        --dbms_output.put_line(' pn_var_trx_rec.proration_reset_group_id = ' || pn_var_trx_rec.proration_reset_group_id);
        --dbms_output.put_line(' l_sales_type_code = ' || l_sales_type_code);
        --dbms_output.put_line(' pn_var_trx_rec.sales_type_code = ' || pn_var_trx_rec.sales_type_code);
        --dbms_output.put_line(' l_item_category_code = ' || l_item_category_code);
        --dbms_output.put_line(' pn_var_trx_rec.item_category_code = ' || pn_var_trx_rec.item_category_code);
        --dbms_output.put_line(' l_old_bkpt_rate = ' || l_old_bkpt_rate);
        --dbms_output.put_line(' pn_var_trx_rec.bkpt_rate = ' || pn_var_trx_rec.bkpt_rate);
        --dbms_output.put_line(' l_pro_bkpt_vol_start = ' || l_pro_bkpt_vol_start);
        --dbms_output.put_line(' l_pro_bkpt_vol_end = ' || l_pro_bkpt_vol_end);
        dbms_output.put_line(' l_old_period_id = ' || l_old_period_id);
        dbms_output.put_line(' current period id = ' || pn_var_trx_rec.period_id);
        dbms_output.put_line(' Current Invoice Flag = ' || pn_var_trx_rec.invoice_flag);

        IF l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id
          OR l_sales_type_code <> pn_var_trx_rec.sales_type_code
          OR l_item_category_code <> pn_var_trx_rec.item_category_code
          OR l_old_bkpt_rate <> pn_var_trx_rec.bkpt_rate  THEN

          l_pro_bkpt_vol_start   := 0;
          l_pro_bkpt_vol_end     := 0;
          pnp_debug_pkg.debug('Reset/Initialize Pro Group Vol Start/End');

        END IF;

        IF pn_var_trx_rec.proration_rule IN ('CYP','CYNP') AND --Chris.T. 17MAR2004 Start
           l_old_period_id <> 0 AND
           l_old_period_id <> pn_var_trx_rec.period_id AND
           nvl(pn_var_trx_rec.invoice_flag,'X') <> 'P' THEN

           l_pro_bkpt_vol_start   := 0;
           l_pro_bkpt_vol_end     := 0;
           pnp_debug_pkg.debug(' CYNP - Reset/Initialize Pro Group Vol Start/End');
           /* dbms_output.put_line(' CYNP - Reset/Initialize Pro Group Vol Start/End');

        END IF; --Chris.T. 17MAR2004 End

        /* dbms_output.put_line(' STEP1 l_pro_bkpt_vol_start = ' || l_pro_bkpt_vol_start);
        dbms_output.put_line(' STEP1 pn_var_trx_rec.pr_grp_blended_vol_start = ' || pn_var_trx_rec.pr_grp_blended_vol_start);
        l_pro_bkpt_vol_start := l_pro_bkpt_vol_start + pn_var_trx_rec.pr_grp_blended_vol_start;
        l_pro_bkpt_vol_end   := l_pro_bkpt_vol_end + pn_var_trx_rec.pr_grp_blended_vol_end;

        /* dbms_output.put_line(' STEP2 l_pro_bkpt_vol_start = ' || l_pro_bkpt_vol_start);
        dbms_output.put_line(' l_pro_bkpt_vol_end = ' || l_pro_bkpt_vol_end);

        IF pn_var_trx_rec.proration_rule IN ('FY','LY','FLY') THEN
          UPDATE pn_var_transactions_all
          SET    pr_ytd_blended_vol_start = l_pro_bkpt_vol_start,
                 pr_ytd_blended_vol_end   = l_pro_bkpt_vol_end
          WHERE  grp_date_id     = pn_var_trx_rec.grp_date_id
          AND    bkpt_start_date = pn_var_trx_rec.bkpt_start_date
          AND    bkpt_rate       = pn_var_trx_rec.bkpt_rate
          AND    line_item_id    = pn_var_trx_rec.line_item_id
          AND    bkpt_detail_id  = pn_var_trx_rec.bkpt_detail_id
          AND    proration_reset_group_id  = pn_var_trx_rec.proration_reset_group_id;
          pnp_debug_pkg.debug('Rows Updated = '||to_char(sql%rowcount));

        ELSIF pn_var_trx_rec.proration_rule IN ('CYNP','CYP') THEN
          UPDATE pn_var_transactions_all
          SET    pr_ytd_blended_vol_start = l_pro_bkpt_vol_start,
                 pr_ytd_blended_vol_end   = l_pro_bkpt_vol_end,
                 ytd_group_vol_start = l_pro_bkpt_vol_start,
                 ytd_group_vol_end   = l_pro_bkpt_vol_end
          WHERE  grp_date_id     = pn_var_trx_rec.grp_date_id
          AND    bkpt_start_date = pn_var_trx_rec.bkpt_start_date
          AND    bkpt_rate       = pn_var_trx_rec.bkpt_rate
          AND    line_item_id    = pn_var_trx_rec.line_item_id
          AND    bkpt_detail_id  = pn_var_trx_rec.bkpt_detail_id
          AND    proration_reset_group_id  = pn_var_trx_rec.proration_reset_group_id;
          pnp_debug_pkg.debug('Rows Updated = '||to_char(sql%rowcount));

        END IF; --IF pn_var_trx_rec.proration_rule IN ('FY','LY','FLY','CYNP','CYP')

        IF pn_var_trx_rec.partial_period = 'Y' THEN -- Partial Year
           pnp_debug_pkg.debug('Partial Period');
           /* dbms_output.put_line('  Partial Period ');
           l_max_per_grp_dt := NULL;
           OPEN get_max_per_grp_dt (pn_var_trx_rec.var_rent_id
                                  ,pn_var_trx_rec.period_id);
           FETCH get_max_per_grp_dt INTO l_max_per_grp_dt;
              IF get_max_per_grp_dt%NOTFOUND THEN
                 CLOSE get_max_per_grp_dt;
                 RAISE NO_DATA_FOUND;
              END IF;
           CLOSE get_max_per_grp_dt;

           l_first_partial_year := to_char(l_max_per_grp_dt,'YYYY');
           /* dbms_output.put_line('  l_first_partial_year ='|| l_first_partial_year);
           dbms_output.put_line('  l_curr_grp_date_year ='|| l_curr_grp_date_year);
           dbms_output.put_line('  l_last_partial_period := '||l_last_partial_period);
           dbms_output.put_line('  l_last_partial_period_id := '||l_last_partial_period_id);
           dbms_output.put_line('  pn_var_trx_rec.proration_reset_group_id:= '||pn_var_trx_rec.proration_reset_group_id);
           dbms_output.put_line('  l_old_pro_reset_group_id := '||l_old_pro_reset_group_id); */

     /*
           IF (pn_var_trx_rec.proration_rule IN ('FLY','FY') AND
               l_curr_grp_date_year <= l_first_partial_year  AND
               l_last_partial_period_id <> pn_var_trx_rec.period_id)  THEN
             IF l_old_pro_reset_group_id <> 0 AND
                pn_var_trx_rec.proration_reset_group_id <> 1  AND
                l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id THEN
                --l_last_partial_period = 'Y' THEN
               l_pro_invoice_flag := 'F';
               dbms_output.put_line(' l_pro_invoice_flag := F');
             ELSE
               l_pro_invoice_flag := 'N';
               --dbms_output.put_line(' Step1 l_curr_grp_date_year ='|| l_curr_grp_date_year);
               --dbms_output.put_line(' Step1 l_first_partial_year ='|| l_first_partial_year);
               --dbms_output.put_line(' Step1 l_pro_invoice_flag := N');
             END IF;
           END IF;
     */

     /* commented above code as it will not take care of first year partial year
        followed with a another partial year Srini 09-AUG-2004
           IF pn_var_trx_rec.proration_rule IN ('FLY','FY') THEN
             IF (l_curr_grp_date_year <= l_first_partial_year  AND
                l_last_partial_period_id <> pn_var_trx_rec.period_id)  THEN
               IF l_old_pro_reset_group_id <> 0 AND
                 pn_var_trx_rec.proration_reset_group_id <> 1  AND
                 l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id THEN
                 --l_last_partial_period = 'Y' THEN
                 l_pro_invoice_flag := 'F';
                 /* dbms_output.put_line(' l_pro_invoice_flag := F');
               ELSE
                 l_pro_invoice_flag := 'N';
                 --dbms_output.put_line(' Step1 l_curr_grp_date_year ='|| l_curr_grp_date_year);
                 --dbms_output.put_line(' Step1 l_first_partial_year ='|| l_first_partial_year);
                 --dbms_output.put_line(' Step1 l_pro_invoice_flag := N');
               END IF;
       ELSIF (l_curr_grp_date_year = l_first_partial_year  AND
                l_last_partial_period_id = pn_var_trx_rec.period_id AND
                l_prv_partial_period = 'Y') THEN
               l_invoice_grp_dt := NULL;
               OPEN get_invoice_grp_dt (pn_var_trx_rec.var_rent_id
                                      ,pn_var_trx_rec.period_id
                                      ,l_min_grp_dt_364);
               FETCH get_invoice_grp_dt INTO l_invoice_grp_dt;
               IF get_invoice_grp_dt%NOTFOUND THEN
                   CLOSE get_invoice_grp_dt;
                   RAISE NO_DATA_FOUND;
               END IF;
               CLOSE get_invoice_grp_dt;
               IF pn_var_trx_rec.group_date = l_invoice_grp_dt THEN
                 l_pro_invoice_flag := 'I';
         END IF;
       END IF;
           END IF;

           /* dbms_output.put_line('  LY/FLY l_last_partial_period := '||l_last_partial_period);
           dbms_output.put_line('  LY/FLY l_last_partial_period_id := '||l_last_partial_period_id);
           dbms_output.put_line('  LY/FLY pn_var_trx_rec.group_date := '||pn_var_trx_rec.group_date);
           dbms_output.put_line('  LY/FLY l_old_pro_reset_group_id := '||l_old_pro_reset_group_id);
           dbms_output.put_line('  LY/FLY l_max_grp_dt := '||l_max_grp_dt);
           dbms_output.put_line('  Step1 LY/FLY l_curr_grp_date_year := '||l_curr_grp_date_year);
           dbms_output.put_line('  Step1 LY/FLY pn_var_trx_rec.period_id := '||pn_var_trx_rec.period_id);

           IF (pn_var_trx_rec.proration_rule IN ('FLY','LY') AND
               l_last_partial_period_id = pn_var_trx_rec.period_id AND
               l_last_partial_period = 'Y' )  THEN
             IF pn_var_trx_rec.group_date = l_max_grp_dt THEN
                 l_pro_invoice_flag := 'I';
             ELSIF l_old_pro_reset_group_id <> 0 AND
                pn_var_trx_rec.proration_reset_group_id <> 1  AND
                l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id THEN
               l_pro_invoice_flag := 'L';

         IF pn_var_trx_rec.proration_rule = 'FLY' THEN
       l_fy_365_end_date   := NULL;
       l_ly_365_start_date := NULL;
       l_fy_365_end_date   := get_fy_365_end_date(p_var_rent_id   => p_var_rent_id);
       l_ly_365_start_date := get_ly_365_start_date(p_var_rent_id => p_var_rent_id);
       IF l_ly_365_start_date < l_fy_365_end_date THEN
                   l_pro_invoice_flag := 'F';
     END IF;
         END IF;

             ELSE
               l_pro_invoice_flag := 'N';
               /*dbms_output.put_line(' Step2 l_pro_invoice_flag := N');
             END IF;--IF pn_var_trx_rec.group_date = l_max_grp_dt
           END IF;--IF pn_var_trx_rec.proration_rule IN ('FY','FLY')

           pnp_debug_pkg.debug('Invoice Flag = '||l_pro_invoice_flag);
           /* dbms_output.put_line(' Invoice Flag = '||l_pro_invoice_flag);

        ELSE -- Complete Year
          pnp_debug_pkg.debug('Complete Year');
          /* dbms_output.put_line('Complete Year '||pn_var_trx_rec.period_id );
          DBMS_OUTPUT.PUT_LINE('  Previous Partial Period :'||l_prv_partial_period);
          l_pro_invoice_flag := NULL;
          IF (pn_var_trx_rec.proration_rule IN ('FY','FLY')) AND
             l_prv_partial_period = 'Y' THEN
             l_invoice_grp_dt := NULL;
             OPEN get_invoice_grp_dt (pn_var_trx_rec.var_rent_id
                                    ,pn_var_trx_rec.period_id
                                    ,l_min_grp_dt_364);
             FETCH get_invoice_grp_dt INTO l_invoice_grp_dt;
             IF get_invoice_grp_dt%NOTFOUND THEN
                 CLOSE get_invoice_grp_dt;
                 RAISE NO_DATA_FOUND;
             END IF;
             CLOSE get_invoice_grp_dt;
             pnp_debug_pkg.debug('l_invoice_grp_date = ' || l_invoice_grp_dt);
             pnp_debug_pkg.debug('pn_var_trx_rec.group_date = ' || pn_var_trx_rec.group_date);
             /* dbms_output.put_line('l_invoice_grp_date = ' || l_invoice_grp_dt);
             dbms_output.put_line('pn_var_trx_rec.group_date = ' || pn_var_trx_rec.group_date);
             dbms_output.put_line('l_365_grp_dt = ' || l_365_grp_dt);

             IF pn_var_trx_rec.group_date = l_invoice_grp_dt THEN
               l_pro_invoice_flag := 'I';
             ELSIF l_old_pro_reset_group_id <> 0 AND
                pn_var_trx_rec.group_date < l_invoice_grp_dt AND
                l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id THEN
               l_pro_invoice_flag := 'F';
             END IF;--IF pn_var_trx_rec.group_date = l_invoice_grp_dt

          END IF;
          /* dbms_output.put_line(' l_pro_invoice_flag for FY or FLY = ' || l_pro_invoice_flag);

          IF (pn_var_trx_rec.proration_rule IN ('LY','FLY')) AND
             pn_var_trx_rec.group_date >= l_365_grp_dt THEN
             l_invoice_grp_dt := NULL;
             OPEN get_invoice_grp_dt (pn_var_trx_rec.var_rent_id
                                     ,pn_var_trx_rec.period_id
                                     ,l_min_grp_dt_364);
             FETCH get_invoice_grp_dt INTO l_invoice_grp_dt;
             IF get_invoice_grp_dt%NOTFOUND THEN
               CLOSE get_invoice_grp_dt;
               RAISE NO_DATA_FOUND;
             END IF;
             CLOSE get_invoice_grp_dt;
             pnp_debug_pkg.debug('l_invoice_grp_date = ' || l_invoice_grp_dt);
             pnp_debug_pkg.debug('pn_var_trx_rec.group_date = ' || pn_var_trx_rec.group_date);

       /* dbms_output.put_line('  Step1');
       dbms_output.put_line('  l_old_group_date:'|| l_old_group_date);
       dbms_output.put_line('  l_365_grp_dt:'|| l_365_grp_dt);
       dbms_output.put_line('  l_old_pro_reset_group_id:'|| l_old_pro_reset_group_id);
       dbms_output.put_line('  pn_var_trx_rec.proration_reset_group_id:'|| pn_var_trx_rec.proration_reset_group_id);

             IF l_old_group_date >= l_365_grp_dt AND
                l_old_pro_reset_group_id <> 0 AND
                l_old_pro_reset_group_id <> pn_var_trx_rec.proration_reset_group_id THEN
          /* dbms_output.put_line('  Step2');
                --l_pro_invoice_flag := 'L';
    IF pn_var_trx_rec.proration_rule = 'FLY' THEN
                  l_pro_invoice_flag := 'L';
    END IF;
             ELSE
          /* dbms_output.put_line('  Step3');
    IF l_pro_invoice_flag = 'N' THEN
                  l_pro_invoice_flag := NULL;
    END IF;
             END IF;--IF pn_var_trx_rec.group_date = l_invoice_grp_dt

          END IF;
          /* dbms_output.put_line(' l_pro_invoice_flag for LY or FLY = ' || l_pro_invoice_flag);
          pnp_debug_pkg.debug('Complete Year Invoice Flag = '||l_pro_invoice_flag);

        END IF; --IF pn_var_trx_rec.partial_period = 'Y'

        IF l_pro_invoice_flag IN ('N','I') THEN

          UPDATE pn_var_transactions_all
          SET    invoice_flag    = l_pro_invoice_flag
          WHERE    bkpt_start_date = pn_var_trx_rec.bkpt_start_date
          AND    line_item_id    = pn_var_trx_rec.line_item_id
          AND    NVL(proration_reset_group_id,0)  = NVL(pn_var_trx_rec.proration_reset_group_id, 0);
          --AND    proration_reset_group_id  = pn_var_trx_rec.proration_reset_group_id; Srini 11AUG2004

          pnp_debug_pkg.debug('Current Updated for N,I  = '||to_char(sql%rowcount));
          /* dbms_output.put_line(' UPDATE for N or I, SQL%ROWCOUNT := '||SQL%ROWCOUNT);
        ELSIF l_pro_invoice_flag IN ('F','L') THEN
          --IF pn_var_trx_rec.partial_period = 'Y' AND
          --   pn_var_trx_rec.proration_rule =  'FLY' THEN
          UPDATE pn_var_transactions_all
          SET    invoice_flag    = l_pro_invoice_flag
          WHERE   group_date = l_old_group_date
          AND    line_item_id    = l_old_line_item_id
          AND    NVL(proration_reset_group_id, 0)  = NVL(l_old_pro_reset_group_id, 0);
          --AND    proration_reset_group_id  = l_old_pro_reset_group_id; Srini 11AUG2004
          pnp_debug_pkg.debug('Previous Updated for F,L = '||to_char(sql%rowcount));
          /* dbms_output.put_line(' UPDATE for F or L, SQL%ROWCOUNT := '||SQL%ROWCOUNT);


    --Following should not happen
          IF pn_var_trx_rec.proration_rule = 'LY' THEN
            UPDATE pn_var_transactions_all
            SET    invoice_flag = NULL
            WHERE  var_rent_id  = p_var_rent_id
            AND    invoice_flag = 'L';
    END IF;

    --Following should not happen
          IF pn_var_trx_rec.proration_rule = 'FY' THEN
            UPDATE pn_var_transactions_all
            SET    invoice_flag = NULL
            WHERE  var_rent_id  = p_var_rent_id
            AND    invoice_flag = 'F';
    END IF;

          IF pn_var_trx_rec.partial_period = 'Y' AND
             pn_var_trx_rec.proration_rule IN ('FLY','LY','FY') THEN
            UPDATE pn_var_transactions_all
            SET    invoice_flag    = 'N'
            WHERE  bkpt_start_date = pn_var_trx_rec.bkpt_start_date
            AND    line_item_id    = pn_var_trx_rec.line_item_id
            AND    NVL(proration_reset_group_id, 0)  = NVL(pn_var_trx_rec.proration_reset_group_id, 0);
            --AND    proration_reset_group_id  = pn_var_trx_rec.proration_reset_group_id; Srini 11AUG2004

            /* dbms_output.put_line('  Current Updated for N,I  = '||to_char(sql%rowcount));
            pnp_debug_pkg.debug('Current Updated for N,I  = '||to_char(sql%rowcount));
          END IF;

        END IF;

  --Srini 31AUG2004
        --For FLY, invoice_flag is not set to I for a overlapping first and last partial year
  IF pn_var_trx_rec.proration_rule = 'FLY' THEN
    l_fy_365_end_date   := NULL;
    l_ly_365_start_date := NULL;
    l_fy_365_end_date   := get_fy_365_end_date(p_var_rent_id   => p_var_rent_id);
    l_ly_365_start_date := get_ly_365_start_date(p_var_rent_id => p_var_rent_id);

    IF pn_var_trx_rec.bkpt_start_date = l_fy_365_end_date AND
       l_ly_365_start_date < l_fy_365_end_date THEN
            UPDATE pn_var_transactions_all
            SET invoice_flag    = 'I'
            WHERE bkpt_start_date       = pn_var_trx_rec.bkpt_start_date
            AND line_item_id            = pn_var_trx_rec.line_item_id
            AND NVL(proration_reset_group_id, 0)  = NVL(pn_var_trx_rec.proration_reset_group_id, 0);
    END IF;

    /*
    --Srini 01SEP2004
    IF pn_var_trx_rec.bkpt_end_date = ADD_MONTHS(l_ly_365_start_date, 12) - 1 AND
       l_ly_365_start_date < l_fy_365_end_date THEN
            UPDATE pn_var_transactions_all
            SET invoice_flag    = 'C'
            WHERE bkpt_start_date       = pn_var_trx_rec.bkpt_start_date
            AND line_item_id            = pn_var_trx_rec.line_item_id
            AND NVL(proration_reset_group_id, 0)  = NVL(pn_var_trx_rec.proration_reset_group_id, 0);
    END IF;


  END IF;

      END IF; --IF pn_var_trx_rec.proration_rule IN ('FY','LY','FLY','CYP','CYNP')

      l_old_group_date         := pn_var_trx_rec.group_date;
      l_old_grp_date_id        := pn_var_trx_rec.grp_date_id;
      l_old_bkpt_start_date    := pn_var_trx_rec.bkpt_start_date;
      l_old_bkpt_detail_id     := pn_var_trx_rec.bkpt_detail_id;
      l_old_pro_reset_group_id := pn_var_trx_rec.proration_reset_group_id;
      l_sales_type_code        := pn_var_trx_rec.sales_type_code;
      l_item_category_code     := pn_var_trx_rec.item_category_code;
      l_old_period_id := pn_var_trx_rec.period_id;
      l_old_line_item_id := pn_var_trx_rec.line_item_id;
      l_old_reset_group_id := pn_var_trx_rec.reset_group_id;
      l_old_bkpt_rate := pn_var_trx_rec.bkpt_rate;
      l_old_partial_period := pn_var_trx_rec.partial_period;

   END LOOP; -- pn_var_trex_rec end loop; */
   NULL;
END update_ytd_bkpts;

/*===========================================================================+
 | PROCEDURE DETERMINE_RESET_FLAG
 |
 | DESCRIPTION
 |
 |   This procedure will set the reset flag for a particular row in pn_var_transactions_all
 |   table. This flag is then used to determine the summary for ytd breakpoints and
 |   the cumulative sales. The rule being followed is that if the rates between the
 |   current group and the previous group and different either in count or in number
 |   then the reset flag is set to Y for the current group. This will set the summary
 |   counter to 0 when we do ytd breakpoints and ytd sales.
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    P_VAR_RENT_ID
 |                    P_START_DATE
 |
 |              OUT:  X_RESET_FLAG
 |
 | MODIFICATION HISTORY
 |
 |     16-MAR-2003  graghuna o Created
 |     25-JUL-2003  cthangai o Added param period_id and line_item_id
 +===========================================================================*/
PROCEDURE determine_reset_flag ( p_var_rent_id   IN NUMBER,
                                 p_period_id     IN NUMBER,
                                 p_item_category_code IN VARCHAR2,
                                 p_sales_type_code  IN VARCHAR2,
                                 p_start_date    IN DATE ,
                                 x_reset_flag    OUT NOCOPY VARCHAR2)
IS

   Type rate_rec is RECORD (
   rate NUMBER );

   TYPE rate_tbl is table of rate_rec index by binary_integer;

   v_rate_tbl_1                  rate_tbl;
   v_rate_tbl_2                  rate_tbl;
   l_start_date                  DATE := NULL;
   l_end_date                    DATE := NULL;
   I                             INTEGER := 0;
   l_reset_flag                  VARCHAR2(1) := 'N';
   l_x                  VARCHAR2(2000) := 'N';
 /*cursor get_distinct_rates_cur( p_var_Rent_id NUMBER,
                                  p_start_date  DATE,
                                  p_end_date    DATE) IS
   SELECT a.bkpt_rate
   FROM   pn_var_transactions_all  a
          ,pn_var_lines_all b
   WHERE  a.var_rent_id = p_var_rent_id
   AND    a.period_id = NVL(p_period_id,a.period_id)
   AND    a.line_item_id = b.line_item_id
   AND    b.item_category_code = p_item_category_code
   AND    b.sales_type_code = p_sales_type_code
   AND    a.bkpt_start_date = NVL( p_start_date,a.bkpt_start_date)
   AND    a.bkpt_end_date   = NVL( p_end_date , a.bkpt_end_date)
   ORDER BY a.period_id,a.bkpt_start_date, a.prorated_grp_vol_start;  /*25-JUL-03 Chris T*/

BEGIN

   /*l_start_date := p_start_date;
   i := 0;
   FOR distinct_rates_rec in get_distinct_rates_cur (
                                p_var_rent_id,
                                l_start_date,
                                l_end_date) LOOP
      i := i+1;
      v_rate_tbl_1(i).rate := distinct_rates_rec.bkpt_rate;
   END LOOP;

   i:=0;
   l_start_date:= NULL;
   l_end_date := p_start_date-1;
   FOR distinct_rates_rec in get_distinct_rates_cur (
                                p_var_rent_id,
                                l_start_date,
                                l_end_date) LOOP
      i := i+1;
      v_rate_tbl_2(i).rate := distinct_rates_rec.bkpt_rate;
   END LOOP;

   l_x :=   'v_rate_tbl_1.count = ' || v_rate_tbl_1.count;
   pnp_debug_pkg.debug(l_x);
   l_x :=  'v_rate_tbl_2.count = ' || v_rate_tbl_2.count;
   pnp_debug_pkg.debug(l_x);

   IF v_rate_tbl_1.count <> v_rate_tbl_2.count THEN
      x_reset_flag := 'Y';
   ELSE
      FOR i in v_rate_tbl_1.first .. v_rate_tbl_1.last LOOP

         l_x :=  'i= '|| i;
         pnp_debug_pkg.debug(l_x);
         l_x := 'v_rate_tbl_1= '|| v_rate_tbl_1(i).rate;
         pnp_debug_pkg.debug(l_x);
         l_x := 'v_rate_tbl_2= '|| v_rate_tbl_2(i).rate;
         pnp_debug_pkg.debug(l_x);
         IF v_rate_tbl_1(i).rate <> v_rate_tbl_2(i).rate THEN
            x_reset_flag := 'Y';
         END IF;

      END LOOP;
   END IF;*/ NULL;
END determine_reset_flag;

/*===========================================================================+
 | PROCEDURE update_blended_period
 |
 | DESCRIPTION
 |
 | SCOPE : PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    P_VAR_RENT_ID
 |
 |              OUT:
 |
 | MODIFICATION HISTORY
 |
 |     24-JUL-2003  CTHANGAI o Created
 +===========================================================================*/
PROCEDURE update_blended_period ( p_var_rent_id IN NUMBER)
IS

   /*CURSOR get_prorated_grp_vol_cur IS
   SELECT period_id
         ,line_item_id
         ,reset_group_id
         ,bkpt_rate
         ,ROUND(SUM(prorated_grp_vol_start),2) blend_period_start
         ,ROUND(SUM(prorated_grp_vol_end),2)   blend_period_end
   FROM   pn_var_transactions_all
   WHERE  var_rent_id = p_var_rent_id
   GROUP BY period_id
         ,line_item_id
         ,reset_group_id
         ,bkpt_rate;

   CURSOR get_prorated_grp_vol_np_cur IS   --Chris.T. 11FEB2004
   SELECT period_id
         ,line_item_id
         ,reset_group_id
         ,bkpt_rate
         ,prorated_grp_vol_start blend_period_start
         ,prorated_grp_vol_end   blend_period_end
   FROM   pn_var_transactions_all
   WHERE  var_rent_id = p_var_rent_id;*/

   l_proration_rule VARCHAR2(10) := NULL; --Chris.T. 11FEB2004

BEGIN

   --Get Proration Rule for VR
  /* l_proration_rule := pn_var_rent_pkg.get_proration_rule(p_var_rent_id => p_var_rent_id);
   pnp_debug_pkg.log('  Proration Rule = '||l_proration_rule);

   IF l_proration_rule = 'NP' THEN  --Chris.T. 11FEB2004
     FOR get_prorated_grp_vol_rec IN get_prorated_grp_vol_np_cur
     LOOP

       UPDATE pn_var_transactions_all
       SET    blended_period_vol_start = get_prorated_grp_vol_rec.blend_period_start
             ,blended_period_vol_end = get_prorated_grp_vol_rec.blend_period_end
       WHERE  var_rent_id = p_var_rent_id
       AND    period_id   = get_prorated_grp_vol_rec.period_id
       AND    line_item_id = get_prorated_grp_vol_rec.line_item_id
       AND    reset_group_id = get_prorated_grp_vol_rec.reset_group_id
       AND    bkpt_rate =  get_prorated_grp_vol_rec.bkpt_rate;

       pnp_debug_pkg.debug('Period_id/line_item_id/reset_grp_id/bkpt_rate = '
                          ||to_char(get_prorated_grp_vol_rec.period_id)||'/'
                          ||to_char(get_prorated_grp_vol_rec.line_item_id)||'/'
                          ||to_char(get_prorated_grp_vol_rec.reset_group_id)||'/'
                          ||to_char(get_prorated_grp_vol_rec.bkpt_rate));
       pnp_debug_pkg.debug('Blended Period Vol Start = '||to_char(get_prorated_grp_vol_rec.blend_period_start));
       pnp_debug_pkg.debug('Blended Period Vol End  = '||to_char(get_prorated_grp_vol_rec.blend_period_end));

     END LOOP;

   ELSE

     FOR get_prorated_grp_vol_rec IN get_prorated_grp_vol_cur
     LOOP

       UPDATE pn_var_transactions_all
       SET    blended_period_vol_start = get_prorated_grp_vol_rec.blend_period_start
             ,blended_period_vol_end = get_prorated_grp_vol_rec.blend_period_end
       WHERE  var_rent_id = p_var_rent_id
       AND    period_id   = get_prorated_grp_vol_rec.period_id
       AND    line_item_id = get_prorated_grp_vol_rec.line_item_id
       AND    reset_group_id = get_prorated_grp_vol_rec.reset_group_id
       AND    bkpt_rate =  get_prorated_grp_vol_rec.bkpt_rate;

       pnp_debug_pkg.debug('Period_id/line_item_id/reset_grp_id/bkpt_rate = '
                           ||to_char(get_prorated_grp_vol_rec.period_id)||'/'
                           ||to_char(get_prorated_grp_vol_rec.line_item_id)||'/'
                           ||to_char(get_prorated_grp_vol_rec.reset_group_id)||'/'
                           ||to_char(get_prorated_grp_vol_rec.bkpt_rate));
       pnp_debug_pkg.debug('Blended Period Vol Start = '||to_char(get_prorated_grp_vol_rec.blend_period_start));
       pnp_debug_pkg.debug('Blended Period Vol End  = '||to_char(get_prorated_grp_vol_rec.blend_period_end));

     END LOOP;

   END IF;  --IF l_proration_rule = 'NP' THEN  --Chris.T. 11FEB2004*/
   NULL;

END update_blended_period;

PROCEDURE update_blended_period (p_var_rent_id IN NUMBER,
                                 p_start_date  IN DATE,
                                 p_proration_rule IN VARCHAR2)
IS

 l_partial_period_id NUMBER;
 l_partial_period_start_date DATE;
 l_partial_period_end_date DATE;
 l_p_parital_period_flag VARCHAR2(1);
 l_complete_period_id NUMBER;
 l_complete_period_start_date DATE;
 l_complete_period_end_date DATE;
 l_c_parital_period_flag VARCHAR2(1);
 l_date DATE;

 l_months_in_group NUMBER(12,2);
 l_months_in_complete_period NUMBER(12,2);
 l_months_in_partial_period NUMBER(12,2);
 l_total_months NUMBER(12,2);
 l_period_proration_factor NUMBER;
 l_group_proration_factor NUMBER;
 l_period_from NUMBER(12,2);
 l_period_to NUMBER(12,2);
 l_group_from NUMBER(12,2);
 l_group_to NUMBER(12,2);
 l_rate_count NUMBER;
 l_invg_freq_code NUMBER;

 CURSOR first_partial_period_cur IS
 SELECT period_id,start_date,end_date,partial_period
 FROM   pn_var_periods_all
 WHERE  var_rent_id = p_var_rent_id
 AND    start_Date = p_start_date ; -- p_start date = VR_agreement_start_date

 CURSOR first_complete_period_cur (p_date DATE) IS
 SELECT period_id,Start_date,end_date,partial_period
 FROM  pn_var_periods_all
 WHERE  var_rent_id = p_var_rent_id
 AND    start_Date = p_date ; -- p_date =  partial_period_end_date +1;

 /*CURSOR annual_blended_bkpts_cur (p_end_date DATE) IS
 SELECT proration_reset_group_id
        ,a.bkpt_rate
        ,b.item_category_code
        ,b.sales_type_code
        ,min(a.group_date) min_group_date
        ,max(a.group_date) max_group_date
        ,sum(a.prorated_grp_vol_start) sum_grp_vol_start
        ,sum(a.prorated_grp_vol_end) sum_grp_vol_end
 FROM   pn_var_transactions_all a
        ,pn_var_lines_all b
 WHERE  a.var_rent_id = p_var_rent_id
 AND    a.group_date  <= p_end_date -- end date of the complete period
 AND    a.line_item_id = b.line_item_id
 GROUP BY a.proration_reset_group_id,
          a.bkpt_rate
        ,b.item_category_code
        ,b.sales_type_code;

 --Chris.T. 15MAR2004 --Cursor To fetch other than first partial and first complete period
 CURSOR get_prorated_grp_vol_cur (ip_end_date DATE) IS
 SELECT period_id
       ,line_item_id
       ,reset_group_id
       ,bkpt_rate
       --,min(group_date) min_group_date
       --,max(group_date) max_group_date
       ,min(bkpt_start_date) min_group_date
       ,max(bkpt_end_date) max_group_date
       ,ROUND(SUM(prorated_grp_vol_start),2) blend_period_start
       ,ROUND(SUM(prorated_grp_vol_end),2)   blend_period_end
 FROM   pn_var_transactions_all
 WHERE  var_rent_id = p_var_rent_id
 AND    group_date  > ip_end_date -- end date of the complete period
 GROUP BY period_id
       ,line_item_id
       ,reset_group_id
       ,bkpt_rate;

/*Chris.T. 16MAR2004 - Commented as Cursor not used
 CURSOR get_dates_for_reset_grp ( p_reset_group_id NUMBER) IS
 SELECT min(group_date)
        ,max(group_date)
 FROM   pn_var_transactions_all
 WHERE  var_rent_id = p_var_rent_id
 AND    proration_reset_group_id = p_reset_group_id;
*/
  --Srini Start 10-Jun-2004

  l_vr_term_dt  DATE;
  l_grp_end_dt  DATE;
  v_grp_st_dt DATE;
  v_grp_end_dt  DATE;

  /*CURSOR process_grp_dates_cur(p_min_grp_dt   DATE,
             p_max_grp_dt   DATE,
             p_pr_re_grp_id   NUMBER,
             p_bkpt_rate  NUMBER,
             p_vr_term_dt DATE)
  IS SELECT *
     FROM pn_var_transactions_all trx
     WHERE  trx.var_rent_id = p_var_rent_id
     AND trx.group_date >= p_min_grp_dt
     AND trx.group_date <= p_max_grp_dt
     AND trx.proration_reset_group_id = p_pr_re_grp_id
     AND trx.bkpt_rate = p_bkpt_rate
     AND EXISTS (SELECT 'Partial Month'
     FROM pn_var_grp_dates_all grp
     WHERE grp.grp_date_id = trx.grp_date_id
     AND grp.grp_end_date  > p_vr_term_dt);

  CURSOR process_first_cynp_cur(p_var_rent_id   NUMBER,
        p_bkpt_st_dt  DATE,
        p_period_from NUMBER,
        p_period_to NUMBER)
  IS SELECT *
     FROM pn_var_transactions_all trx
     WHERE  trx.var_rent_id           = p_var_rent_id
     AND trx.bkpt_start_date          = p_bkpt_st_dt
     AND trx.blended_period_vol_start = p_period_from
     AND trx.blended_period_vol_end   = p_period_to;

  CURSOR process_last_cynp_cur(p_var_rent_id  NUMBER,
             p_bkpt_end_dt  DATE,
             p_period_from  NUMBER,
             p_period_to  NUMBER)
  IS SELECT *
     FROM pn_var_transactions_all trx
     WHERE trx.var_rent_id        = p_var_rent_id
     AND trx.bkpt_end_date          = p_bkpt_end_dt
     AND trx.blended_period_vol_start = p_period_from
     AND trx.blended_period_vol_end   = p_period_to;*/

  l_counter       NUMBER(12,6);
  l_counter1      NUMBER(12,6);
  l_counter2      NUMBER(12,6);
  l_date1     DATE;
  l_st_dt1    DATE;
  l_end_dt1     DATE;
  l_cynp_days   NUMBER;
  l_tot_days    NUMBER;
  l_mth_cynp_days NUMBER;
  l_mth_tot_days  NUMBER;
  l_cnt     NUMBER;
  l_mths_bet      NUMBER(12,6);
  l_bkpt_days   NUMBER;
  l_bkpt_tot_days NUMBER;
  l_new_period_from   NUMBER(12,2);
  l_new_period_to   NUMBER(12,2);

  --Srini End 10-Jun-2004

BEGIN
/*
   SELECT termination_date
   INTO l_vr_term_dt
   FROM pn_var_rents_all
   WHERE var_rent_id = p_var_rent_id;
   pnp_debug_pkg.log('  Variable Rent Termination Date:'||l_vr_term_dt);
   pnp_debug_pkg.debug(' Variable Rent Termination Date:'||l_vr_term_dt);

   OPEN first_partial_period_cur;
   FETCH first_partial_period_cur INTO
      l_partial_period_id ,
      l_partial_period_start_date ,
      l_partial_period_end_date ,
      l_p_parital_period_flag ;
   CLOSE first_partial_period_cur;

   l_date := l_partial_period_end_date + 1;
   OPEN first_complete_period_cur(l_date);
   FETCH first_complete_period_cur INTO
     l_complete_period_id ,
     l_complete_period_start_date ,
     l_complete_period_end_date ,
     l_c_parital_period_flag ;
   CLOSE first_complete_period_cur;

   l_months_in_complete_period :=round(MONTHS_BETWEEN(l_complete_period_end_date + 1,
                                                l_complete_period_start_date));
   l_months_in_partial_period :=round(MONTHS_BETWEEN(l_partial_period_end_date + 1,
                                               l_partial_period_start_date));

   IF p_proration_rule = 'CYP' THEN  --Chris.T. 09JUN2004
     l_total_months := l_months_in_complete_period + l_months_in_partial_period;
   ELSE
     --Start Srini 10SEP2004
     --Based on discussions with Sean, SSpar,Liam and Kathleen,
     --constant 12 months will be replaced with actual months in period after first partial period
     --l_total_months := 12; --Complete period treated as a 12 month
     l_total_months := l_months_in_complete_period;
     BEGIN
       --Findout invoicing freq
       SELECT DECODE(invg_freq_code, 'MON', 1,
             'QTR', 3,
             'SA', 6,
             'YR', 12,
             NULL)
       INTO l_invg_freq_code
       FROM pn_var_rent_dates_all
       WHERE var_rent_id = p_var_rent_id;
       /*DBMS_OUTPUT.PUT_LINE('  l_invg_freq_code:'||l_invg_freq_code);
       EXCEPTION
   WHEN OTHERS THEN
     l_invg_freq_code := 1;
     END;
     --End Srini 10SEP2004
   END IF;

   --pnp_debug_pkg.log('Proration Rule = '|| p_proration_rule);
   --pnp_debug_pkg.log('Months in complete period = '|| l_months_in_complete_period);
   --pnp_debug_pkg.log('Months in partial period = '|| l_months_in_partial_period);
   --pnp_debug_pkg.log('Total period/Months = '|| l_total_months);
   --pnp_debug_pkg.log('l_complete_period_end_date = '|| l_complete_period_end_date);


   FOR annual_blended_bkpts_rec IN
       annual_blended_bkpts_cur (l_complete_period_end_date)
   LOOP

     --Srini Start 10-Jun-2004

     BEGIN
       SELECT grp_end_date
       INTO l_grp_end_dt
       FROM pn_var_grp_dates_all
       WHERE var_rent_id = p_var_rent_id
       AND group_date    = annual_blended_bkpts_rec.max_group_date;
       EXCEPTION
  WHEN OTHERS THEN
    l_grp_end_dt := annual_blended_bkpts_rec.max_group_date;
     END;

     IF l_vr_term_dt < l_grp_end_dt THEN
       l_months_in_group := ROUND(MONTHS_BETWEEN(l_vr_term_dt + 1,
                                         annual_blended_bkpts_rec.min_group_date), 2);
     ELSE
       l_months_in_group := ROUND(MONTHS_BETWEEN(l_grp_end_dt + 1,
                                         annual_blended_bkpts_rec.min_group_date), 2);

     END IF;
     --Srini End 10-Jun-2004
     /* DBMS_OUTPUT.PUT_LINE('  min group date = '||annual_blended_bkpts_rec.min_group_date);
     DBMS_OUTPUT.PUT_LINE('  max group date = '||annual_blended_bkpts_rec.max_group_date);
     DBMS_OUTPUT.PUT_LINE('  l_vr_term_dt = '||l_vr_term_dt);
     DBMS_OUTPUT.PUT_LINE('  l_months_in_group = '||l_months_in_group);

     --Start Srini 14SEP2004
     IF p_proration_rule = 'CYNP' THEN
       l_counter  := 0;
       l_counter1 := 0;
       l_counter2 := 0;
       l_date1    := l_partial_period_start_date;
       l_cynp_days  := (l_complete_period_end_date - l_complete_period_start_date) + 1;
       l_tot_days := (TO_DATE('31-12-'||TO_CHAR(l_complete_period_start_date, 'YYYY'), 'DD-MM-YYYY')
          - l_complete_period_start_date) + 1;

       l_cnt    := ROUND(MONTHS_BETWEEN(LAST_DAY(l_complete_period_end_date),
         TO_DATE('01-'||TO_CHAR(l_partial_period_start_date, 'MM-YYYY'), 'DD-MM-YYYY')));

       FOR l_counter IN 0 .. l_cnt - 1
       LOOP
         l_st_dt1 := l_date1;
         l_end_dt1    := LAST_DAY(l_date1);

         IF l_end_dt1 > l_complete_period_end_date THEN
           l_end_dt1  := l_complete_period_end_date;
         END IF;

         l_mth_cynp_days:= (l_end_dt1 - l_st_dt1) + 1;
         l_mth_tot_days := (LAST_DAY(l_end_dt1) - TO_DATE('01-'||TO_CHAR(l_st_dt1,'MM-YYYY'), 'DD-MM-YYYY')) + 1;

         l_counter1   := l_counter1 + (l_mth_cynp_days/l_mth_tot_days);

         IF l_date1 >= l_complete_period_start_date THEN
           l_counter2   := l_counter2 + (l_mth_cynp_days/l_mth_tot_days);
         END IF;

         l_date1  := l_end_dt1 + 1;
         /*DBMS_OUTPUT.PUT_LINE('  l_mth_cynp_days:'||l_mth_cynp_days);
         DBMS_OUTPUT.PUT_LINE('  l_mth_tot_days:'||l_mth_tot_days);
         DBMS_OUTPUT.PUT_LINE('  l_counter:'||l_counter);
         DBMS_OUTPUT.PUT_LINE('  l_counter1:'||l_counter1);
         DBMS_OUTPUT.PUT_LINE('  l_counter2:'||l_counter2);
         DBMS_OUTPUT.PUT_LINE('  l_date1:'||l_date1);

       END LOOP;

       /* DBMS_OUTPUT.PUT_LINE('  l_counter1:'||l_counter1);
       DBMS_OUTPUT.PUT_LINE('  l_counter2:'||l_counter2);
       DBMS_OUTPUT.PUT_LINE('  l_tot_days:'||l_tot_days);
       DBMS_OUTPUT.PUT_LINE('  l_cynp_days:'||l_cynp_days);

       --IF p_proration_rule = 'CYNP' THEN
       l_period_from := ((annual_blended_bkpts_rec.sum_grp_vol_start/ l_counter1) * 12) * (l_cynp_days/l_tot_days);
       l_period_to   := ((annual_blended_bkpts_rec.sum_grp_vol_end/ l_counter1) * 12) * (l_cynp_days/l_tot_days);
       l_group_from :=  (l_period_from/l_counter1)*l_invg_freq_code;
       l_group_to   :=  (l_period_to/l_counter1)*l_invg_freq_code;
     ELSIF p_proration_rule = 'CYP' THEN
       l_period_from := annual_blended_bkpts_rec.sum_grp_vol_start;
       l_period_to := annual_blended_bkpts_rec.sum_grp_vol_end;
     END IF;
     --End Srini 14SEP2004

     IF p_proration_rule = 'CYNP' THEN
       /* DBMS_OUTPUT.PUT_LINE('  l_period_from = '||l_period_from);
       DBMS_OUTPUT.PUT_LINE('  l_period_to = '||l_period_to);
       --pnp_debug_pkg.log('updating for CYNP');

       UPDATE pn_var_transactions_all trx
       SET trx.pr_grp_blended_vol_start = l_group_from
          ,trx.pr_grp_blended_vol_end   = l_group_to
          ,trx.blended_period_vol_start = l_period_from
          ,trx.blended_period_vol_end   = l_period_to
          ,trx.invoice_flag             = 'P'
       WHERE  var_rent_id = p_var_rent_id
       AND group_date >= annual_blended_bkpts_rec.min_group_date
       AND group_date <= annual_blended_bkpts_rec.max_group_date
       AND proration_reset_group_id = annual_blended_bkpts_rec.proration_reset_group_id
       AND bkpt_rate = annual_blended_bkpts_rec.bkpt_rate
       AND bkpt_end_date <= l_complete_period_end_date;

       /* DBMS_OUTPUT.PUT_LINE('Number Of Records Updated: '||SQL%ROWCOUNT);

       --Process ,if any, partial months in first partial and complete year
       FOR i IN process_first_cynp_cur(p_var_rent_id,
               l_partial_period_start_date,
               l_period_from,
               l_period_to)
       LOOP
     l_bkpt_days     := (i.bkpt_end_date - i.bkpt_start_date) + 1;
     l_bkpt_tot_days := (((ADD_MONTHS(i.bkpt_start_date, l_invg_freq_code) - 1) - i.bkpt_start_date) + 1);
   l_mths_bet      := l_bkpt_days/l_bkpt_tot_days;

         l_group_from := (l_period_from/l_counter1) * l_invg_freq_code * l_mths_bet;
         l_group_to   := (l_period_to/l_counter1) * l_invg_freq_code * l_mths_bet;

         /* DBMS_OUTPUT.PUT_LINE('Partial l_bkpt_days = '||l_bkpt_days);
         DBMS_OUTPUT.PUT_LINE('Partial l_bkpt_tot_days = '||l_bkpt_tot_days);
         DBMS_OUTPUT.PUT_LINE('Partial l_mths_bet = '||l_mths_bet);
         DBMS_OUTPUT.PUT_LINE('Partial l_group_from = '||l_group_from);
         DBMS_OUTPUT.PUT_LINE('Partial l_group_to = '||l_group_to);
         DBMS_OUTPUT.PUT_LINE('Partial i.transaction_id = '||i.transaction_id);

         UPDATE pn_var_transactions_all trx
         SET trx.PR_GRP_BLENDED_VOL_START = l_group_from
            ,trx.PR_GRP_BLENDED_VOL_END   = l_group_to
            ,trx.BLENDED_PERIOD_VOL_START = l_period_from
            ,trx.BLENDED_PERIOD_VOL_END   = l_period_to
            ,trx.invoice_flag             = 'P'
         WHERE  transaction_id = i.transaction_id;
         /* DBMS_OUTPUT.PUT_LINE('Number Of First Partial Records Updated: '||SQL%ROWCOUNT);

       END LOOP;

       FOR i IN process_last_cynp_cur(p_var_rent_id,
              l_complete_period_end_date,
              l_period_from,
              l_period_to)
       LOOP
     l_bkpt_days     := (i.bkpt_end_date - i.bkpt_start_date) + 1;
     l_bkpt_tot_days := (((ADD_MONTHS(i.bkpt_start_date, l_invg_freq_code) - 1) - i.bkpt_start_date) + 1);
   l_mths_bet      := l_bkpt_days/l_bkpt_tot_days;

         l_group_from := (l_period_from/l_counter1) * l_invg_freq_code * l_mths_bet;
         l_group_to   := (l_period_to/l_counter1) * l_invg_freq_code * l_mths_bet;
         /* DBMS_OUTPUT.PUT_LINE('Partial l_bkpt_days = '||l_bkpt_days);
         DBMS_OUTPUT.PUT_LINE('Partial l_bkpt_tot_days = '||l_bkpt_tot_days);
         DBMS_OUTPUT.PUT_LINE('Partial l_mths_bet = '||l_mths_bet);
         DBMS_OUTPUT.PUT_LINE('Partial l_group_from = '||l_group_from);
         DBMS_OUTPUT.PUT_LINE('Partial l_group_to = '||l_group_to);
         DBMS_OUTPUT.PUT_LINE('Partial i.transaction_id = '||i.transaction_id);

         UPDATE pn_var_transactions_all trx
         SET trx.PR_GRP_BLENDED_VOL_START = l_group_from
            ,trx.PR_GRP_BLENDED_VOL_END   = l_group_to
            ,trx.BLENDED_PERIOD_VOL_START = l_period_from
            ,trx.BLENDED_PERIOD_VOL_END   = l_period_to
            ,trx.invoice_flag             = 'P'
         WHERE  transaction_id = i.transaction_id;
         /* DBMS_OUTPUT.PUT_LINE('Number Of Last Partial Records Updated: '||SQL%ROWCOUNT);

       END LOOP;

       BEGIN
   SELECT SUM(pr_grp_blended_vol_start), SUM(pr_grp_blended_vol_end)
   INTO l_new_period_from, l_new_period_to
   FROM pn_var_transactions_all
   WHERE var_rent_id      = p_var_rent_id
         AND group_date            >= annual_blended_bkpts_rec.min_group_date
         AND group_date            <= annual_blended_bkpts_rec.max_group_date
         AND proration_reset_group_id     = annual_blended_bkpts_rec.proration_reset_group_id
         AND bkpt_rate                    = annual_blended_bkpts_rec.bkpt_rate
         AND bkpt_end_date           <= l_complete_period_end_date
         AND blended_period_vol_start     = l_period_from
         AND blended_period_vol_end       = l_period_to;

         /* DBMS_OUTPUT.PUT_LINE('  l_new_period_from = '||l_new_period_from);
         DBMS_OUTPUT.PUT_LINE('  l_new_period_to = '||l_new_period_to);

         UPDATE pn_var_transactions_all trx
         SET trx.blended_period_vol_start = l_new_period_from
            ,trx.blended_period_vol_end   = l_new_period_to
            ,trx.invoice_flag             = 'P'
         WHERE trx.var_rent_id      = p_var_rent_id
         AND trx.group_date      >= annual_blended_bkpts_rec.min_group_date
         AND trx.group_date      <= annual_blended_bkpts_rec.max_group_date
         AND trx.proration_reset_group_id = annual_blended_bkpts_rec.proration_reset_group_id
         AND trx.bkpt_rate      = annual_blended_bkpts_rec.bkpt_rate
         AND trx.bkpt_end_date     <= l_complete_period_end_date
         AND trx.blended_period_vol_start = l_period_from
         AND trx.blended_period_vol_end   = l_period_to;
         /* DBMS_OUTPUT.PUT_LINE('Number Of CYNP Records Updated: '||SQL%ROWCOUNT);
   EXCEPTION
     WHEN OTHERS THEN
             /* DBMS_OUTPUT.PUT_LINE('  Exception - l_new_period_from = '||l_new_period_from);
             DBMS_OUTPUT.PUT_LINE('  Exception - l_new_period_to = '||l_new_period_to);
             null;
       END;

     ELSIF p_proration_rule = 'CYP' THEN
       --pnp_debug_pkg.log('updating for CYP');
       UPDATE pn_var_transactions_all
       SET blended_period_vol_start = l_period_from
          ,blended_period_vol_end   = l_period_to
          ,invoice_flag             = 'P'  --denote first partial or complete period
       WHERE  var_rent_id = p_var_rent_id
       AND group_date >= annual_blended_bkpts_rec.min_group_date
       AND group_date <= annual_blended_bkpts_rec.max_group_date
       AND proration_reset_group_id = annual_blended_bkpts_rec.proration_reset_group_id
       AND bkpt_rate = annual_blended_bkpts_rec.bkpt_rate;
       /* DBMS_OUTPUT.PUT_LINE('  Number Of Records Updated For CYP: '||SQL%ROWCOUNT);
       DBMS_OUTPUT.PUT_LINE('  l_group_from: '||l_group_from);
       DBMS_OUTPUT.PUT_LINE('  l_group_to: '||l_group_to);
       DBMS_OUTPUT.PUT_LINE('  l_period_from: '||l_period_from);
       DBMS_OUTPUT.PUT_LINE('  l_period_to: '||l_period_to);
     END IF;

   END LOOP;

   --To handle other than first partial and first complete period
   FOR get_prorated_grp_vol_rec IN get_prorated_grp_vol_cur (l_complete_period_end_date)
   LOOP

     l_months_in_group := NULL;
     l_period_from     := NULL;
     l_period_to       := NULL;
     l_group_from      := NULL;
     l_group_to        := NULL;

     l_months_in_group := ROUND(MONTHS_BETWEEN(get_prorated_grp_vol_rec.max_group_date + 1,
                                               get_prorated_grp_vol_rec.min_group_date), 1);

     IF p_proration_rule = 'CYNP' THEN
       pnp_debug_pkg.debug('updating CYNP');
       --pnp_debug_pkg.log('updating for CYNP');

       l_period_from := get_prorated_grp_vol_rec.blend_period_start;
       l_period_to   := get_prorated_grp_vol_rec.blend_period_end;
       l_group_from  := (l_period_from/l_months_in_group)*l_invg_freq_code;
       l_group_to    := (l_period_to/l_months_in_group)*l_invg_freq_code;

       /* DBMS_OUTPUT.PUT_LINE('  l_months_in_group: '||l_months_in_group);
       DBMS_OUTPUT.PUT_LINE('  l_group_from: '||l_group_from);
       DBMS_OUTPUT.PUT_LINE('  l_group_to: '||l_group_to);
       DBMS_OUTPUT.PUT_LINE('  l_period_from: '||l_period_from);
       DBMS_OUTPUT.PUT_LINE('  l_period_to: '||l_period_to);

       UPDATE pn_var_transactions_all
       SET blended_period_vol_start = l_period_from
          ,blended_period_vol_end = l_period_to
          ,PR_GRP_BLENDED_VOL_START =  l_group_from
          ,PR_GRP_BLENDED_VOL_END = l_group_to
       WHERE  var_rent_id = p_var_rent_id
       AND period_id   = get_prorated_grp_vol_rec.period_id
       AND line_item_id = get_prorated_grp_vol_rec.line_item_id
       AND reset_group_id = get_prorated_grp_vol_rec.reset_group_id
       AND bkpt_rate = get_prorated_grp_vol_rec.bkpt_rate;

       --Process ,if any, partial months after first complete year
       FOR i IN process_last_cynp_cur(p_var_rent_id,
              l_vr_term_dt,
              l_period_from,
              l_period_to)
       LOOP
     l_bkpt_days     := (i.bkpt_end_date - i.bkpt_start_date) + 1;
     l_bkpt_tot_days := (((ADD_MONTHS(i.bkpt_start_date, l_invg_freq_code) - 1) - i.bkpt_start_date) + 1);
   l_mths_bet      := l_bkpt_days/l_bkpt_tot_days;

         l_group_from := (l_period_from/l_months_in_group) * l_invg_freq_code * l_mths_bet;
         l_group_to   := (l_period_to/l_months_in_group) * l_invg_freq_code * l_mths_bet;
         /* DBMS_OUTPUT.PUT_LINE('  Partial l_group_from = '||l_group_from);
         DBMS_OUTPUT.PUT_LINE('  Partial l_group_to = '||l_group_to);
         DBMS_OUTPUT.PUT_LINE('  Partial i.transaction_id = '||i.transaction_id);

         UPDATE pn_var_transactions_all trx
         SET trx.PR_GRP_BLENDED_VOL_START = l_group_from
            ,trx.PR_GRP_BLENDED_VOL_END   = l_group_to
            ,trx.BLENDED_PERIOD_VOL_START = l_period_from
            ,trx.BLENDED_PERIOD_VOL_END   = l_period_to
         WHERE transaction_id = i.transaction_id;
         /* DBMS_OUTPUT.PUT_LINE('  Number Of Partial Records Updated: '||SQL%ROWCOUNT);

       END LOOP;

     ELSIF p_proration_rule = 'CYP' THEN
       pnp_debug_pkg.debug('updating CYP');
       --pnp_debug_pkg.log('updating for CYP');

       UPDATE pn_var_transactions_all
       SET    blended_period_vol_start = get_prorated_grp_vol_rec.blend_period_start
             ,blended_period_vol_end = get_prorated_grp_vol_rec.blend_period_end
       WHERE  var_rent_id = p_var_rent_id
       AND    period_id   = get_prorated_grp_vol_rec.period_id
       AND    line_item_id = get_prorated_grp_vol_rec.line_item_id
       AND    reset_group_id = get_prorated_grp_vol_rec.reset_group_id
       AND    bkpt_rate = get_prorated_grp_vol_rec.bkpt_rate;

     END IF;

     pnp_debug_pkg.debug('Period_id/line_item_id/reset_grp_id/bkpt_rate = '
           ||to_char(get_prorated_grp_vol_rec.period_id)
                       ||'/'||to_char(get_prorated_grp_vol_rec.line_item_id)
                       ||'/'||to_char(get_prorated_grp_vol_rec.reset_group_id)
                       ||'/'||to_char(get_prorated_grp_vol_rec.bkpt_rate));
     pnp_debug_pkg.debug('Blended Period Vol Start = '||to_char(get_prorated_grp_vol_rec.blend_period_start));
     pnp_debug_pkg.debug('Blended Period Vol End  = '||to_char(get_prorated_grp_vol_rec.blend_period_end));
     pnp_debug_pkg.debug('Pr Grp Blended Period Vol Start = '||l_group_from);
     pnp_debug_pkg.debug('Pr Grp Blended Period Vol End  = '||l_group_to);
     --pnp_debug_pkg.log('Period_id/line_item_id/reset_grp_id/bkpt_rate = '
           --||to_char(get_prorated_grp_vol_rec.period_id)
                       --||'/'||to_char(get_prorated_grp_vol_rec.line_item_id)
                       --||'/'||to_char(get_prorated_grp_vol_rec.reset_group_id)
                       --||'/'||to_char(get_prorated_grp_vol_rec.bkpt_rate));
     --pnp_debug_pkg.log('Blended Period Vol Start = '||to_char(get_prorated_grp_vol_rec.blend_period_start));
     --pnp_debug_pkg.log('Blended Period Vol End  = '||to_char(get_prorated_grp_vol_rec.blend_period_end));
     --pnp_debug_pkg.log('Pr Grp Blended Period Vol Start = '||l_group_from);
     --pnp_debug_pkg.log('Pr Grp Blended Period Vol End  = '||l_group_to);

   END LOOP;*/
   NULL;

END update_blended_period;

/*===========================================================================+
 | PROCEDURE copy_var_rent_agreement
 |
 | DESCRIPTION
 |
 | SCOPE : PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 | MODIFICATION HISTORY
 |
 |     06-SEP-2003  graghuna o Created
 +===========================================================================*/
procedure copy_var_rent_agreement (
   p_old_var_rent_id IN NUMBER,
   p_start_date      IN DATE DEFAULT NULL,
   p_end_date        IN DATE DEFAULT NULL,
   p_proration_rule  IN VARCHAR2 DEFAULT 'STD',
   p_create_periods  IN VARCHAR2 DEFAULT 'N',
   x_var_rent_id     OUT NOCOPY NUMBER,
   x_var_rent_num    OUT NOCOPY VARCHAR2) IS

  CURSOR var_rent_cur IS
  SELECT *
  FROM   pn_var_rents_all
  WHERE  var_rent_id = p_old_var_rent_id;

  CURSOR var_rent_dates_cur IS
  SELECT *
  FROM pn_var_rent_dates_all
  WHERE  var_rent_id = p_old_var_rent_id;

  l_length NUMBER;
  l_instr  NUMBER;
  l_return_status VARCHAR2(32767);
  l_return_msg VARCHAR2(32767);
  l_old_var_rent_id NUMBER;
  l_effective_date DATE;
BEGIN


   FOR var_rent_rec in var_rent_cur LOOP

      var_rent_rec.commencement_date := NVL(p_start_date,var_rent_Rec.commencement_date);
      var_rent_rec.termination_Date := NVL(p_end_date,var_rent_Rec.termination_date);
      var_rent_rec.proration_rule := NVL(p_proration_rule,var_rent_Rec.proration_rule);
      var_rent_rec.chg_cal_var_rent_id := NULL;
      l_length := LENGTH(var_rent_rec.rent_num);
      l_instr := INSTR(var_rent_rec.rent_num,'-');
      IF l_instr = 0 THEN
         var_rent_rec.rent_num := var_rent_rec.rent_num||'-1';
      ELSE
         var_rent_rec.rent_num := SUBSTR(var_rent_rec.rent_num,1,l_instr)||
                                   '-'||to_number(SUBSTR(var_rent_rec.rent_num,l_instr+1,10))+1;
   end if;



      FOR var_rent_dates_rec in var_rent_dates_cur LOOP
         var_rent_dates_rec.effective_date := NULL;
         var_rent_dates_rec.use_gl_calendar := NULL;
         var_rent_dates_rec.gl_period_set_name := NULL;
         var_rent_dates_rec.period_type := NULL;
         var_rent_dates_rec.year_start_date := NULL;
      pn_var_rents_pkg.create_var_rent_agreement (
         p_pn_var_rents_rec => var_rent_rec,
         p_var_rent_dates_rec => var_rent_dates_rec,
         p_create_periods => p_create_periods,
         x_var_rent_id => x_var_rent_id,
         x_var_rent_num => x_var_rent_num);
      l_old_var_rent_id := var_rent_rec.var_rent_id;
      l_effective_date := var_rent_dates_rec.effective_date;
       EXIT;
      END LOOP;
      EXIT;
   END LOOP;


END copy_var_rent_agreement;

Procedure process_calendar_change (
   p_var_rent_id     IN NUMBER ,
   p_old_var_rent_id IN NUMBER ,
   p_effective_date  IN DATE,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_return_message  OUT NOCOPY VARCHAR2
  )

IS

   CURSOR  period_exists_cur IS
   SELECT 'x' period_exists
   FROM   dual
   WHERE EXISTS ( SELECT period_id
                  FROM   pn_var_periods_all
                  WHERE  var_rent_id = p_var_rent_id);

  CURSOR old_var_rent_cur IS
  SELECT chg_cal_var_rent_id
  FROM   pn_var_rents_all
  WHERE  var_rent_id = p_var_rent_id;

  l_period_exists BOOLEAN := FALSE;
  l_defaults_exists BOOLEAN := FALSE;
  l_old_var_rent_id NUMBER;
  l_line_exists NUMBER  :=0 ;
  l_constr_exists NUMBER :=0 ;

  user_exception exception;

BEGIN


  -- Check if periods have been genereated for the new
  -- variable rent agreement. IF there are no periods
  -- generated then raise an error. When called from a form periods will always
  -- be generated before this process is called.

  FOR periods_exists_rec in period_exists_cur LOOP
     l_period_exists := TRUE;
     EXIT;
  END LOOP;

  IF  NOT(l_period_exists) THEN
     x_return_message := 'PN_PERIODS_NOT_FOUND';
     Raise user_exception;
  END IF;

  -- Check if there are defaults. IF defaults are present then
  -- copy them over and call create_default_lines and populate_transactions
  -- This will take care of generating period level data.

  l_old_var_rent_id := p_old_var_rent_id;

  l_line_exists := pn_var_defaults_pkg.find_if_line_defaults_exist (
                      p_var_rent_id => l_old_var_rent_Id) ;

  /* dbms_output.put_line('l_line_exists = '|| l_line_exists);
  dbms_output.put_line('l_old_var_rent_id = '|| l_old_var_rent_id); */
  IF l_line_exists > 0 THEN
  /* dbms_output.put_line('copy_line_defaults'); */

     pn_var_chg_cal_pkg.copy_line_defaults (
        p_old_var_rent_id=> l_old_var_rent_id,
        p_new_var_rent_id => p_var_rent_id,
        p_effective_date => p_effective_date);

     pn_var_defaults_pkg.create_default_lines (
        x_var_rent_id => p_var_rent_id);
  ELSE
     pn_var_chg_cal_pkg.copy_parent_lines (
       x_var_rent_id => p_var_rent_id,
       x_chg_var_rent_id => l_old_var_rent_id);



  END IF;

  l_constr_exists := pn_var_defaults_pkg.find_if_constr_defaults_exist (
                      p_var_rent_id => l_old_var_rent_Id) ;
  IF l_constr_exists > 0 THEN
     pn_var_chg_cal_pkg.copy_constr_defaults (
        p_old_var_rent_id => p_var_rent_id ,
        p_new_var_rent_id  => l_old_var_rent_id,
        p_effective_date => p_effective_date);

     pn_var_defaults_pkg.create_default_constraints (
        x_var_rent_id => p_var_rent_id);
  END IF;

  pn_var_chg_cal_pkg.copy_parent_volhist (
    x_var_rent_id => p_var_rent_id ,
    x_chg_var_rent_id  => l_old_var_rent_id);

     pn_var_chg_cal_pkg.populate_transactions (
        p_var_rent_id =>  p_var_rent_id);


   create_credit_invoice ( p_var_rent_id => p_var_rent_id,
                                   p_effective_date  => p_effective_date);

EXCEPTION

   When user_exception THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
   When OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

END process_calendar_change ;

Function get_last_complete_period_id ( p_var_rent_id IN NUMBER)
RETURN NUMBER
IS

   CURSOR last_period_cur IS
   SELECT max(period_id) period_id
   FROM   pn_var_periods_all
   WHERE  var_rent_id = p_var_rent_id
   AND    partial_period = 'N';

  l_last_complete_period_id NUMBER;
BEGIN

   FOR last_period_rec in  last_period_cur LOOP
      l_last_complete_period_id := last_period_rec.period_id;
      EXIT;
   END LOOP;

   RETURN l_last_complete_period_id;

END ;

Function get_fy_365_end_date ( p_var_rent_id IN NUMBER)
RETURN DATE
IS

   CURSOR get_group_date(ip_grp_date DATE)  IS
   SELECT group_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    ip_grp_date between grp_start_date and grp_end_date;


   CURSOR get_365_end_cur IS
   SELECT min(grp_start_date) + 364 enddate
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id ;


  l_fy_365_end_date DATE;
  l_date DATE;
BEGIN

   FOR get_365_end_rec in  get_365_end_cur LOOP
      l_fy_365_end_date := get_365_end_rec.enddate;
      EXIT;
   END LOOP;

   FOR get_group_date_rec in get_group_date(l_fy_365_end_date) LOOP
      l_date := get_group_date_rec.group_date;
      EXIT;
   END LOOP;
   RETURN l_date;

END ;


Function get_ly_365_start_date ( p_var_rent_id IN NUMBER)
RETURN DATE
IS

   CURSOR get_group_date(ip_grp_date DATE)  IS
   SELECT group_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    ip_grp_date between grp_start_date and grp_end_date;


   CURSOR get_365_start_cur IS
   SELECT max(grp_end_date) - 364 startdate
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id ;


  L_ly_365_start_date DATE;
  l_date DATE;
BEGIN

   FOR get_365_start_rec in  get_365_start_cur LOOP
      l_ly_365_start_date := get_365_start_rec.startdate;
      EXIT;
   END LOOP;

   FOR get_group_date_rec in get_group_date(l_ly_365_start_date) LOOP
      l_date := get_group_date_rec.group_date;
      EXIT;
   END LOOP;
   RETURN l_date;

END ;


PROCEDURE copy_line_defaults(p_old_var_rent_id NUMBER
,p_new_var_rent_id NUMBER
,p_effective_date DATE )

IS

   CURSOR source_cur IS
   SELECT *
   FROM   pn_var_line_defaults_all
   WHERE  var_rent_id = p_old_var_rent_id
   AND    line_end_date > p_effective_date;

   CURSOR bkhd_source_cur (ip_line_default_id NUMBER) IS
   SELECT *
   FROM   pn_var_bkhd_defaults_all
   WHERE  line_default_id = ip_line_default_id
   AND    var_rent_id = p_old_var_rent_id
   AND    bkhd_end_date > p_effective_date;

   CURSOR bkdt_source_cur (ip_bkhd_default_id NUMBER) IS
   SELECT *
   FROM   pn_var_bkdt_defaults_all
   WHERE  var_rent_id = p_old_var_rent_id
   AND    bkhd_default_id = ip_bkhd_default_id
   AND    bkdt_end_date > p_effective_date;


   l_rowid VARCHAR2(32767);
   l_start_date DATE;
   l_line_default_id NUMBER ;
   l_line_num NUMBER;
   l_bkhd_default_id NUMBER ;
   l_bkhd_detail_num NUMBER;
   l_bkdt_default_id NUMBER ;
   l_bkdt_detail_num NUMBER;
BEGIN

   FOR source_rec in source_cur LOOP
      /* dbms_output.put_line('line defaults'); */
      l_rowid  := NULL;
      l_start_date :=NULL;
      l_line_default_id := NULL;
      l_line_num := NULL;
      IF source_Rec.line_start_date < p_effective_date THEN
         l_start_date := p_effective_date ;
      ELSE
         l_start_date := source_rec.line_start_date;
      END IF;
      PN_VAR_LINE_DEFAULTS_PKG.INSERT_ROW (
         X_ROWID                 => l_rowid,
         X_LINE_DEFAULT_ID       => l_line_default_id,
         X_LINE_NUM              => l_line_num,
         X_VAR_RENT_ID           => p_new_var_rent_id,
         X_SALES_TYPE_CODE       => source_rec.sales_type_code,
         X_ITEM_CATEGORY_CODE    => source_rec.item_category_code ,
         X_LINE_TEMPLATE_ID      => source_rec.line_template_id,
         X_AGREEMENT_TEMPLATE_ID => source_rec.agreement_template_id,
         X_LINE_START_DATE       => l_start_date,
         X_LINE_END_DATE         => source_rec.line_end_date,
         X_PROCESSED_FLAG        => NULL,
         X_CREATION_DATE         => sysdate,
         X_CREATED_BY            => NVL(FND_PROFILE.VALUE('USER_ID'),1),
         X_LAST_UPDATE_DATE      => sysdate,
         X_LAST_UPDATED_BY       => NVL(FND_PROFILE.VALUE('USER_ID'),1),
         X_LAST_UPDATE_LOGIN     => NVL(FND_PROFILE.VALUE('LOGIN_ID'),1),
         X_ORG_ID                => source_rec.org_id,
         X_ATTRIBUTE_CATEGORY    => source_rec.ATTRIBUTE_CATEGORY,
         X_ATTRIBUTE1            => source_rec.ATTRIBUTE1,
         X_ATTRIBUTE2            => source_rec.ATTRIBUTE2,
         X_ATTRIBUTE3            => source_rec.ATTRIBUTE3,
         X_ATTRIBUTE4            => source_rec.ATTRIBUTE4,
         X_ATTRIBUTE5            => source_rec.ATTRIBUTE5,
         X_ATTRIBUTE6            => source_rec.ATTRIBUTE6,
         X_ATTRIBUTE7            => source_rec.ATTRIBUTE7,
         X_ATTRIBUTE8            => source_rec.ATTRIBUTE8,
         X_ATTRIBUTE9            => source_rec.ATTRIBUTE9,
         X_ATTRIBUTE10           => source_rec.ATTRIBUTE10,
         X_ATTRIBUTE11           => source_rec.ATTRIBUTE11,
         X_ATTRIBUTE12           => source_rec.ATTRIBUTE12,
         X_ATTRIBUTE13           => source_rec.ATTRIBUTE13,
         X_ATTRIBUTE14           => source_rec.ATTRIBUTE14,
         X_ATTRIBUTE15           => source_rec.ATTRIBUTE15);

         FOR bkhd_source_rec in bkhd_source_cur(source_rec.line_default_id)
         LOOP
            /* dbms_output.put_line('bkhd_defaults defaults'); */
            l_rowid := NULL;
            l_bkhd_default_id := NULL;
            l_bkhd_detail_num := NULL;
            IF bkhd_Source_rec.bkhd_start_date < p_effective_date THEN
               l_start_date := p_effective_date;
            ELSE
               l_start_date := bkhd_source_rec.bkhd_start_date;
            END IF;
            PN_VAR_BKHD_DEFAULTS_PKG.INSERT_ROW (
              X_ROWID                 => l_rowid,
              X_BKHD_DEFAULT_ID       => l_bkhd_default_id,
              X_BKHD_DETAIL_NUM       => l_bkhd_detail_num,
              X_LINE_DEFAULT_ID       => l_line_default_id,
              X_BKPT_HEAD_TEMPLATE_ID => bkhd_source_rec.bkpt_head_template_id,
              X_AGREEMENT_TEMPLATE_ID => bkhd_source_rec.agreement_template_id,
              X_BKHD_START_DATE       => l_start_date,
              X_BKHD_END_DATE         => bkhd_source_rec.bkhd_end_date,
              X_BREAK_TYPE            => bkhd_source_rec.break_type,
              X_BASE_RENT_TYPE        => bkhd_source_rec.base_rent_type,
              X_NATURAL_BREAK_RATE    => bkhd_source_rec.natural_break_rate,
              X_BASE_RENT             => bkhd_source_rec.base_rent,
              X_BREAKPOINT_TYPE       => bkhd_source_rec.breakpoint_type,
              X_BREAKPOINT_LEVEL      => bkhd_source_rec.breakpoint_level,
              X_PROCESSED_FLAG        => NULL,
              X_VAR_RENT_ID           => p_new_var_rent_id,
              X_CREATION_DATE         => sysdate,
              X_CREATED_BY            => NVL(FND_PROFILE.VALUE('USER_ID'),1),
              X_LAST_UPDATE_DATE      => sysdate,
              X_LAST_UPDATED_BY       => NVL(FND_PROFILE.VALUE('USER_ID'),1),
              X_LAST_UPDATE_LOGIN     => NVL(FND_PROFILE.VALUE('LOGIN_ID'),1),
              X_ORG_ID                => source_rec.org_id,
              X_ATTRIBUTE_CATEGORY    => bkhd_source_rec.ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1            => bkhd_source_rec.ATTRIBUTE1,
              X_ATTRIBUTE2            => bkhd_source_rec.ATTRIBUTE2,
              X_ATTRIBUTE3            => bkhd_source_rec.ATTRIBUTE3,
              X_ATTRIBUTE4            => bkhd_source_rec.ATTRIBUTE4,
              X_ATTRIBUTE5            => bkhd_source_rec.ATTRIBUTE5,
              X_ATTRIBUTE6            => bkhd_source_rec.ATTRIBUTE6,
              X_ATTRIBUTE7            => bkhd_source_rec.ATTRIBUTE7,
              X_ATTRIBUTE8            => bkhd_source_rec.ATTRIBUTE8,
              X_ATTRIBUTE9            => bkhd_source_rec.ATTRIBUTE9,
              X_ATTRIBUTE10           => bkhd_source_rec.ATTRIBUTE10,
              X_ATTRIBUTE11           => bkhd_source_rec.ATTRIBUTE11,
              X_ATTRIBUTE12           => bkhd_source_rec.ATTRIBUTE12,
              X_ATTRIBUTE13           => bkhd_source_rec.ATTRIBUTE13,
              X_ATTRIBUTE14           => bkhd_source_rec.ATTRIBUTE14,
              X_ATTRIBUTE15           => bkhd_source_rec.ATTRIBUTE15);

            FOR bkdt_source_rec in bkdt_source_cur(bkhd_source_rec.bkhd_default_id)
            LOOP

               /* dbms_output.put_line('bkdt defaults'); */
               l_bkdt_default_id := NULL;
               l_bkhd_detail_num := NULL;
               l_rowid := NULL;
               IF bkdt_source_rec.bkdt_start_date < p_effective_date THEN
                  l_start_date := p_effective_date;
               ELSE
                  l_start_date := bkdt_source_rec.bkdt_start_date;
               END IF;
               PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW (
                   X_ROWID                    => l_rowid,
                   X_BKDT_DEFAULT_ID          => l_bkhd_default_id,
                   X_BKDT_DETAIL_NUM          => l_bkdt_detail_num,
                   X_BKHD_DEFAULT_ID          => l_bkhd_default_id,
                   X_BKDT_START_DATE          => l_start_date,
                   X_BKDT_END_DATE            => bkdt_source_rec.bkdt_end_date,
                   X_PERIOD_BKPT_VOL_START    => bkdt_source_rec.period_bkpt_vol_start,
                   X_PERIOD_BKPT_VOL_END      => bkdt_source_rec.period_bkpt_vol_end,
                   X_GROUP_BKPT_VOL_START     => bkdt_source_rec.group_bkpt_vol_start,
                   X_GROUP_BKPT_VOL_END       => bkdt_source_rec.group_bkpt_vol_end,
                   X_BKPT_RATE                => bkdt_source_rec.bkpt_rate,
                   X_PROCESSED_FLAG           => NULL,
                   X_VAR_RENT_ID              => p_new_var_rent_id,
                   X_CREATION_DATE            => sysdate,
                   X_CREATED_BY               => NVL(FND_PROFILE.VALUE('USER_ID'),1),
                   X_LAST_UPDATE_DATE         => sysdate,
                   X_LAST_UPDATED_BY          => NVL(FND_PROFILE.VALUE('USER_ID'),1),
                   X_LAST_UPDATE_LOGIN        => NVL(FND_PROFILE.VALUE('LOGIN_ID'),1),
                   X_ORG_ID                   => source_rec.org_id,
                   X_ANNUAL_BASIS_AMOUNT      => bkdt_source_rec.annual_basis_amount,
                   X_ATTRIBUTE_CATEGORY       => bkdt_source_rec.ATTRIBUTE_CATEGORY,
                   X_ATTRIBUTE1               => bkdt_source_rec.ATTRIBUTE1,
                   X_ATTRIBUTE2               => bkdt_source_rec.ATTRIBUTE2,
                   X_ATTRIBUTE3               => bkdt_source_rec.ATTRIBUTE3,
                   X_ATTRIBUTE4               => bkdt_source_rec.ATTRIBUTE4,
                   X_ATTRIBUTE5               => bkdt_source_rec.ATTRIBUTE5,
                   X_ATTRIBUTE6               => bkdt_source_rec.ATTRIBUTE6,
                   X_ATTRIBUTE7               => bkdt_source_rec.ATTRIBUTE7,
                   X_ATTRIBUTE8               => bkdt_source_rec.ATTRIBUTE8,
                   X_ATTRIBUTE9               => bkdt_source_rec.ATTRIBUTE9,
                   X_ATTRIBUTE10              => bkdt_source_rec.ATTRIBUTE10,
                   X_ATTRIBUTE11              => bkdt_source_rec.ATTRIBUTE11,
                   X_ATTRIBUTE12              => bkdt_source_rec.ATTRIBUTE12,
                   X_ATTRIBUTE13              => bkdt_source_rec.ATTRIBUTE13,
                   X_ATTRIBUTE14              => bkdt_source_rec.ATTRIBUTE14,
                   X_ATTRIBUTE15              => bkdt_source_rec.ATTRIBUTE15
  );
            END LOOP;
         END LOOP;

     END LOOP;
END copy_line_defaults;

procedure copy_constr_defaults (
    p_old_var_rent_id in NUMBER,
    p_new_var_rent_id in NUMBER,
    p_effective_date  in DATE
    )   IS

   l_consrowid          VARCHAR2(18) := NULL;
   l_consDefId          NUMBER       := NULL;
   l_consNum            NUMBER       := 0;
   l_rowid              VARCHAR2(32767);
   l_start_date         DATE ;

     cursor c_get_consdef is
       select * from pn_var_constr_defaults_all
       where var_rent_id = p_old_var_rent_id
       AND constr_end_date > p_effective_date;

BEGIN

    FOR c_crec IN c_get_consdef LOOP

       IF c_crec.constr_start_date < p_effective_date THEN
          l_start_date := p_effective_date;
       ELSE
          l_start_date := c_crec.constr_start_date;
       END IF;

       l_rowid := NULL;
       l_consdefid := NULL;
       l_consnum := NULL;
           pn_var_constr_defaults_pkg.insert_row (
              X_ROWID                 => l_rowid,
              X_CONSTR_DEFAULT_ID     => l_consDefid,
              X_CONSTR_DEFAULT_NUM    => l_consNum,
              X_VAR_RENT_ID           => p_new_var_rent_id,
              X_AGREEMENT_TEMPLATE_ID => c_crec.agreement_template_id,
              X_CONSTR_TEMPLATE_ID    => c_crec.constr_template_id ,
              X_CONSTR_START_DATE     => l_start_date,
              X_CONSTR_END_DATE       => c_crec.CONSTR_END_DATE,
              X_CONSTR_CAT_CODE       => c_crec.CONSTR_CAT_CODE,
              X_TYPE_CODE             => c_crec.type_code,
              X_AMOUNT                => c_crec.amount,
              X_CREATION_DATE         => sysdate,
              X_CREATED_BY            => NVL(fnd_profile.value('USER_ID'),0),
              X_LAST_UPDATE_DATE      => sysdate,
              X_LAST_UPDATED_BY       => NVL(fnd_profile.value('USER_ID'),0),
              X_LAST_UPDATE_LOGIN     => NVL(fnd_profile.value('LOGIN_ID'),0),
              X_ORG_ID                => c_crec.ORG_ID,
              X_ATTRIBUTE_CATEGORY    => c_crec.ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1            => c_crec.ATTRIBUTE1,
              X_ATTRIBUTE2            => c_crec.ATTRIBUTE2,
              X_ATTRIBUTE3            => c_crec.ATTRIBUTE3,
              X_ATTRIBUTE4            => c_crec.ATTRIBUTE4,
              X_ATTRIBUTE5            => c_crec.ATTRIBUTE5,
              X_ATTRIBUTE6            => c_crec.ATTRIBUTE6,
              X_ATTRIBUTE7            => c_crec.ATTRIBUTE7,
              X_ATTRIBUTE8            => c_crec.ATTRIBUTE8,
              X_ATTRIBUTE9            => c_crec.ATTRIBUTE9,
              X_ATTRIBUTE10           => c_crec.ATTRIBUTE10,
              X_ATTRIBUTE11           => c_crec.ATTRIBUTE11,
              X_ATTRIBUTE12           => c_crec.ATTRIBUTE12,
              X_ATTRIBUTE13           => c_crec.ATTRIBUTE13,
              X_ATTRIBUTE14           => c_crec.ATTRIBUTE14,
              X_ATTRIBUTE15           => c_crec.ATTRIBUTE15
                          );

   END LOOP;

END copy_constr_defaults;

PROCEDURE  create_credit_invoice ( p_var_rent_id NUMBER,
                                   p_effective_date  DATE)
IS

   CURSOR inv_grp_dates_cur (ip_date DATE) IS
   SELECT invoice_date,
          inv_start_date
          ,inv_end_date
          ,inv_schedule_date
   FROM   pn_var_grp_dates_all
   WHERE  var_rent_id = p_var_rent_id
   AND    ip_date between inv_start_date and inv_end_date;

  CURSOR  invoices_cur (ip_invoice_date DATE) IS
  SELECT   decode(actual_Exp_code ,'Y',NVL(actual_invoiced_amount,0),0)  invoiced_amt
         ,invoice_date
  FROM   pn_var_rent_inv_all
  WHERE  var_rent_id = p_var_rent_id
  AND    invoice_date >= ip_invoice_date;

  CURSOR max_invoice_date_cur Is
  SELECT max(invoice_date) invoice_date
  FROM   pn_var_grp_dates_all
  WHERE  var_rent_id = p_var_rent_id;

  CURSOR get_periods_cur(ip_date DATE)  Is

  SELECT period_id
  FROM   pn_var_periods_all
  WHERE  var_rent_id = p_var_rent_id
  AND    ip_date between start_date and end_date ;

   CURSOR get_adjust_num ( ip_period_id NUMBER , ip_invoice_date DATE) IS
   SELECT max(adjust_num) adjust_num
   FROM   pn_var_rent_inv_all
   WHERE  period_id = ip_period_id
   AND    invoice_date = ip_invoice_date;

  l_proration_factor NUMBER;
  l_invoice_date  DATE;
  l_invoice_create_date  DATE;
  l_period_id   NUMBER;
  l_rent_inv_id NUMBER;
  l_credit_amount NUMBER;
  l_rowid VARCHAR2(32767);
  l_adjust_num              NUMBER;

  CURSOR get_invoice_date_cur  IS
  SELECT invoice_date
  from  pn_var_grp_dates_all
  where var_rent_id = p_var_rent_id
  and   p_effective_date between inv_start_date and inv_end_date ;

BEGIN

   -- If the effective date lies between the invoice start_date and
   -- invoice end date, prorate the $$ for that invoice period. Otherwise
   -- include the entire $$ amount.

   FOR inv_grp_date_rec in inv_grp_dates_cur(p_effective_date) LOOP

      l_proration_factor := (p_effective_date - inv_grp_date_rec.inv_start_date)/
                            (inv_grp_date_rec.inv_end_date - inv_grp_date_rec.inv_start_date);

      l_invoice_date := inv_grp_date_rec.invoice_date;
      EXIT;
   END LOOP;

   FOR invoices_rec in invoices_cur(l_invoice_date)  LOOP
      IF invoices_rec.invoice_date = l_invoice_date  THEN
         l_credit_amount := NVL(l_credit_amount,0) + (nvl(invoices_rec.invoiced_amt,0) *l_proration_factor );
      ELSE
         l_credit_amount := NVL(l_credit_amount,0) + nvl(invoices_rec.invoiced_amt ,0) ;
      END IF;
   END LOOP;


   FOR inv_grp_date_rec in inv_grp_dates_cur(sysdate) LOOP
      l_invoice_create_date := inv_grp_date_rec.invoice_date;
      EXIT;
   END LOOP;

   IF l_invoice_create_date IS NULL THEN
     FOR max_invoice_date_rec in  max_invoice_date_cur LOOP
        l_invoice_create_date := max_invoice_date_rec.invoice_date;
        EXIT;
     END LOOP;
   END IF;

   IF l_invoice_create_date IS NOT NULL AND
      NVL(l_credit_amount,0) <> 0 THEN
     FOR periods_rec in get_periods_cur(l_invoice_create_date) LOOP
       l_period_id := periods_rec.period_id;
       EXIT;
     END LOOP;

     FOR get_adjust_rec IN get_adjust_num ( l_period_id  , l_invoice_create_date) LOOP
        l_adjust_num := get_adjust_rec.adjust_num;
     END LOOP;
     l_adjust_num := nvl(l_adjust_num,0) + 1;
     l_rent_inv_id := null;
     l_rowid   := null;
     PN_VAR_RENT_INV_PKG.INSERT_ROW (
      X_ROWID                   => l_rowid,
      X_VAR_RENT_INV_ID         => l_rent_inv_id,
      X_ADJUST_NUM              => l_adjust_num,
      X_INVOICE_DATE            => l_invoice_create_date,
      X_FOR_PER_RENT            => NULL,
                  X_TOT_ACT_VOL             => NULL,
      X_ACT_PER_RENT            => NULL,
      X_CONSTR_ACTUAL_RENT      => NULL,
      X_ABATEMENT_APPL          => NULL,
                  X_REC_ABATEMENT           => NULL,
                  X_REC_ABATEMENT_OVERRIDE  => NULL,
      X_NEGATIVE_RENT           => NULL,
      X_ACTUAL_INVOICED_AMOUNT  => round(l_credit_amount,2),
      X_PERIOD_ID               => l_period_id,
      X_VAR_RENT_ID             => p_var_rent_id,
      X_FORECASTED_TERM_STATUS  => 'N',
      X_VARIANCE_TERM_STATUS    => 'N',
      X_ACTUAL_TERM_STATUS      => 'N',
                  X_FORECASTED_EXP_CODE     => 'N',
                  X_VARIANCE_EXP_CODE       => 'N',
                  X_ACTUAL_EXP_CODE         => 'N',
                  X_COMMENTS                => null,
      X_ATTRIBUTE_CATEGORY      => null,
      X_ATTRIBUTE1              => null,
      X_ATTRIBUTE2              => null,
      X_ATTRIBUTE3              => null,
      X_ATTRIBUTE4              => null,
      X_ATTRIBUTE5              => null,
      X_ATTRIBUTE6              => null,
      X_ATTRIBUTE7              => null,
      X_ATTRIBUTE8              => null,
      X_ATTRIBUTE9              => null,
      X_ATTRIBUTE10             => null,
      X_ATTRIBUTE11             => null,
      X_ATTRIBUTE12             => null,
      X_ATTRIBUTE13             => null,
      X_ATTRIBUTE14             => null,
      X_ATTRIBUTE15             => null,
      X_CREATION_DATE           => sysdate,
      X_CREATED_BY              => NVL(fnd_profile.value('USER_ID'),0),
      X_LAST_UPDATE_DATE        => sysdate,
      X_LAST_UPDATED_BY         => NVL(fnd_profile.value('USER_ID'),0),
      X_LAST_UPDATE_LOGIN       => NVL(fnd_profile.value('LOGIN_ID'),0),
                  X_ORG_ID                  => NVL(fnd_profile.value('org_id') ,239)
                 );

   END IF;
END;



end PN_VAR_CHG_CAL_PKG;

/
