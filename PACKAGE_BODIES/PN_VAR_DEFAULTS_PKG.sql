--------------------------------------------------------
--  DDL for Package Body PN_VAR_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_VAR_DEFAULTS_PKG" as
/* $Header: PNVRDFTB.pls 120.0 2007/10/03 14:28:49 rthumma noship $ */

/*********** Comment out code duplicate also found in PNCHCALS.pls

===========================================================================+
 | PROCEDURE COPY_LINE_BKDT_DEFAULTS
 |
 |
 | DESCRIPTION
 |    Create records in the PN_VAR_LINE_DEFAULTS and PN_VAR_BKDT_DEFAULTS tables
 |    when change calendar function executed.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |                    X_CHG_CAL_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-FEB-2003  Gary Olson  o Created
 +===========================================================================

procedure copy_line_bkdt_defaults (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_CAL_VAR_RENT_ID in NUMBER
    )  IS

   l_linerowid          VARCHAR2(18) := NULL;
   l_lineDefId          NUMBER       := NULL;
   l_lineNum            NUMBER       := 0;
   l_new_rentid         NUMBER       := NULL;
   l_old_rentid         NUMBER       := NULL;
   l_bkhdDefId          NUMBER       := 0;
   l_bkhdrowid          VARCHAR2(18) := NULL;
   l_bkhdNum            NUMBER       := 0;
   l_bkdtrowid          VARCHAR2(18) := NULL;
   l_bkdtDefId          NUMBER       := NULL;
   l_bkdtNum            NUMBER       := 0;

   cursor c_get_linedef is
       select * from pn_var_line_defaults_all
       where var_rent_id = l_old_rentid;

   cursor c_get_bkhddef (p_line_def_id NUMBER) is
       select * from pn_var_bkhd_defaults_all
       where line_default_id = p_line_def_id;

   cursor c_get_bkdtdef (p_bkhd_def_id NUMBER) is
       select * from pn_var_bkdt_defaults_all
       where bkhd_default_id = p_bkhd_def_id;

begin

   l_old_rentid := X_VAR_RENT_ID;
   l_new_rentid := X_CHG_CAL_VAR_RENT_ID;

    FOR c_lrec IN c_get_linedef LOOP

        SELECT pn_var_line_defaults_s.nextval
        INTO l_lineDefid
        FROM DUAL;

        l_bkhdNum := 0;
        l_lineNum := l_lineNum + 1;

                 insert into pn_var_line_defaults_all (
                          line_default_id,
                          line_num,
                          var_rent_id,
                          sales_type_code,
                          item_category_code,
                          line_template_id,
                          agreement_template_id,
                          line_start_date,
                          line_end_date,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          last_update_login,
                          org_id,
                          processed_flag
                     ) values (
                           l_lineDefid,
                           l_lineNum,
                           l_new_rentid,
                           c_lrec.SALES_TYPE_CODE,
                           c_lrec.ITEM_CATEGORY_CODE,
                           c_lrec.line_template_id,
                           c_lrec.AGREEMENT_TEMPLATE_ID,
                           c_lrec.LINE_START_DATE,
                           c_lrec.LINE_END_DATE,
                           sysdate,
                           NVL(fnd_profile.value('USER_ID'),0),
                           sysdate,
                           NVL(fnd_profile.value('USER_ID'),0),
                           NVL(fnd_profile.value('USER_ID'),0),
                           c_lrec.ORG_ID,
                           c_lrec.processed_flag
                           );


        FOR c_hdrec IN c_get_bkhddef (c_lrec.line_default_id) LOOP

           SELECT pn_var_bkhd_defaults_s.nextval
           INTO l_bkhdDefId
           FROM DUAL;

           l_bkdtNum := 0;
           l_bkhdNum := l_bkhdNum + 1;

                      insert into pn_var_bkhd_defaults_all (
                               bkhd_default_id,
                               bkhd_detail_num,
                               line_default_id,
                               bkhd_start_date,
                               bkhd_end_date,
                               break_type,
                               base_rent_type,
                               natural_break_rate,
                               base_rent,
                               breakpoint_type,
                               breakpoint_level,
                               bkpt_head_template_id,
                               agreement_template_id,
                               last_update_date,
                               last_updated_by,
                               creation_date,
                               created_by,
                               last_update_login,
                               org_id,
                               var_rent_id,
                               processed_flag
                          ) values (
                               l_bkhdDefId,
                               l_bkhdNum,
                               l_lineDefId,
                               c_hdrec.bkhd_start_date,
                               c_hdrec.bkhd_end_date,
                               c_hdrec.break_type,
                               c_hdrec.base_rent_type,
                               c_hdrec.natural_break_rate,
                               c_hdrec.base_rent,
                               c_hdrec.breakpoint_type,
                               c_hdrec.breakpoint_level,
                               c_hdrec.bkpt_head_template_id,
                               c_hdrec.agreement_template_id,
                               sysdate,
                               NVL(fnd_profile.value('USER_ID'),0),
                               sysdate,
                               NVL(fnd_profile.value('USER_ID'),0),
                               NVL(fnd_profile.value('USER_ID'),0),
                               c_hdrec.ORG_ID,
                               c_hdrec.var_rent_id,
                               c_hdrec.processed_flag
                               );

          FOR c_dtrec IN c_get_bkdtdef (c_hdrec.bkhd_default_id) LOOP

              SELECT pn_var_bkdt_defaults_s.nextval
              INTO l_bkdtDefId
              FROM DUAL;

              l_bkdtNum := l_bkdtNum+1;


                    INSERT into pn_var_bkdt_defaults_all (
                             bkdt_default_id,
                             bkdt_detail_num,
                             bkhd_default_id,
                             bkdt_start_date,
                             bkdt_end_date,
                             period_bkpt_vol_start,
                             period_bkpt_vol_end,
                             group_bkpt_vol_start,
                             group_bkpt_vol_end,
                             bkpt_rate,
                             last_update_date,
                             last_updated_by,
                             creation_date,
                             created_by,
                             last_update_login,
                             org_id,
                             var_rent_id,
                             processed_flag
                         ) values (
                              l_bkdtDefid,
                              l_bkdtNum,
                              l_bkhdDefid,
                              c_dtrec.BKDT_START_DATE,
                              c_dtrec.BKDT_END_DATE,
                              c_dtrec.PERIOD_BKPT_VOL_START,
                              c_dtrec.PERIOD_BKPT_VOL_END,
                              c_dtrec.GROUP_BKPT_VOL_START,
                              c_dtrec.GROUP_BKPT_VOL_END,
                              c_dtrec.BKPT_RATE,
                              sysdate,
                              NVL(fnd_profile.value('USER_ID'),0),
                              sysdate,
                              NVL(fnd_profile.value('USER_ID'),0),
                              NVL(fnd_profile.value('USER_ID'),0),
                              C_dtrec.ORG_ID,
                              C_dtrec.var_rent_id,
                              C_dtrec.processed_flag
                              );
           END LOOP;

        END LOOP;

    END LOOP;

    commit;

end copy_line_bkdt_defaults;

===========================================================================+
 | PROCEDURE COPY_CONSTR_DEFAULTS
 |
 |
 | DESCRIPTION
 |    Create records in the PN_VAR_CONSTR_DEFAULTS table when change calendar
      function executed.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_VAR_RENT_ID
 |                    X_CHG_CAL_VAR_RENT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-FEB-2003  Gary Olson  o Created
 +===========================================================================

procedure copy_constr_defaults (
    X_VAR_RENT_ID         in NUMBER,
    X_CHG_CAL_VAR_RENT_ID in NUMBER
    )   IS

   l_consrowid          VARCHAR2(18) := NULL;
   l_consDefId          NUMBER       := NULL;
   l_consNum            NUMBER       := 0;
   l_rowid              VARCHAR2(32767);

   l_new_rentid         NUMBER       := NULL;
   l_old_rentid         NUMBER       := NULL;

     cursor c_get_consdef is
       select * from pn_var_constr_defaults_all
       where var_rent_id = l_old_rentid;

BEGIN


    l_old_rentid := X_VAR_RENT_ID;
    l_new_rentid := X_CHG_CAL_VAR_RENT_ID;

    FOR c_crec IN c_get_consdef LOOP

           SELECT pn_var_constr_defaults_s.nextval
           INTO l_consDefId
           FROM DUAL;

           l_consNum := l_consNum+1;


           pn_var_constr_defaults_pkg.insert_row (
              X_ROWID                 => l_rowid,
              X_CONSTR_DEFAULT_ID     => l_consDefid,
              X_CONSTR_DEFAULT_NUM    => l_consNum,
              X_VAR_RENT_ID           => l_new_rentid,
              X_AGREEMENT_TEMPLATE_ID => c_crec.agreement_template_id,
              X_CONSTR_TEMPLATE_ID    => c_crec.constr_template_id ,
              X_CONSTR_START_DATE     => c_crec.constr_start_date,
              X_CONSTR_END_DATE       => c_crec.CONSTR_END_DATE,
              X_CONSTR_CAT_CODE       => c_crec.CONSTR_CAT_CODE,
              X_TYPE_CODE             => c_crec.type_code,
              X_AMOUNT                => c_crec.amount,
              X_CREATION_DATE         => sysdate,
              X_CREATED_BY            => NVL(fnd_profile.value('USER_ID'),0),
              X_LAST_UPDATE_DATE      => sysdate,
              X_LAST_UPDATED_BY       => NVL(fnd_profile.value('USER_ID'),0),
              X_LAST_UPDATE_LOGIN     => NVL(fnd_profile.value('LOGIN_ID'),0),
              X_ORG_ID                => c_crec.ORG_ID
                          );

   END LOOP;

   commit;

END copy_constr_defaults;
************* END DUPLICATE COMMENT ****************/

/*===========================================================================+
 | PROCEDURE CREATE_DEFAULT_CONSTRAINTS
 |
 |
 | DESCRIPTION
 |    Create records in the PN_VAR_CONSTRAINTS_ALL table from date range constraints
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 |   13-FEB-03  GOlson  o Created
 |   28-JUN-06  Pikhar  o Added desc flex and modified entering of start
 |                        and end date for constraints
 |   31-AUG-06  Pikhar  o Modified cursor c1 so as to take the intersection
 |                          of dates
 +===========================================================================*/

procedure create_default_constraints (
    X_VAR_RENT_ID         in NUMBER
    )   IS

   l_var_rent_id  NUMBER        := NULL;
   l_rowId        VARCHAR2(18)  := NULL;
   l_constrId     NUMBER        := NULL;
   l_constrNum    NUMBER        := 0;
   l_null         VARCHAR2(150) := NULL;
   L_filename     VARCHAR2(50)  := 'Create_def_cons'||to_char(sysdate,'MMDDYYHHMMSS');
   l_pathname     VARCHAR2(20)  := '/usr/tmp';
   l_start_date   DATE          := NULL;
   l_end_date     DATE          := NULL;

  cursor c1 (p_start DATE, p_end DATE, p_defid NUMBER) is
      select distinct period_id, start_date, end_date
      from pn_var_periods_all
      where var_rent_id = l_var_rent_id
      and start_date <= p_end
      and end_date >= p_start
      and period_id not in (select period_id
                            from pn_var_constraints_all
                            where constr_default_id = p_defid);

  cursor c2 is
      select *
      from pn_var_constr_defaults_all
      where var_rent_id = l_var_rent_id;

  cursor c_num (p_periodId NUMBER) is
      select NVL(max(CONSTRAINT_NUM),0)
      from pn_var_constraints_all
      where period_id = p_periodId;

BEGIN

   pnp_debug_pkg.debug(' create_default_constraints +');
   l_var_rent_id := X_VAR_RENT_ID;

        FOR c2_rec IN c2 LOOP
           FOR c1_rec IN c1 (c2_rec.constr_start_date,
                             c2_rec.constr_end_date,
                             c2_rec.constr_default_id) LOOP

               open c_num (c1_rec.period_id);
               fetch c_num into l_constrNum;
               close c_num;
               l_constrNum := l_constrNum + 1;

               IF c2_rec.constr_start_date < c1_rec.start_date THEN
                  l_start_date := c1_rec.start_date;
               ELSE
                  l_start_date := c2_rec.constr_start_date;
               END IF;

               IF c2_rec.constr_end_date > c1_rec.end_date THEN
                  l_end_date := c1_rec.end_date;
               ELSE
                  l_end_date := c2_rec.constr_end_date;
               END IF;


               PN_VAR_CONSTRAINTS_PKG.INSERT_ROW(
                  X_ROWID                 => l_rowid,
                  X_CONSTRAINT_ID         => l_constrId,
                  x_CONSTRAINT_NUM        => l_constrNum,
                  X_PERIOD_ID             => c1_rec.period_id,
                  X_CONSTR_CAT_CODE       => c2_rec.constr_cat_code,
                  X_TYPE_CODE             => c2_rec.type_code,
                  X_AMOUNT                => c2_rec.amount,
                  X_AGREEMENT_TEMPLATE_ID => c2_rec.agreement_template_id,
                  X_CONSTR_TEMPLATE_ID    => c2_rec.constr_template_id,
                  X_CONSTR_DEFAULT_ID     => c2_rec.constr_default_id,
                  X_COMMENTS              => NULL,
                  X_ATTRIBUTE_CATEGORY    => c2_rec.ATTRIBUTE_CATEGORY,
                  X_ATTRIBUTE1            => c2_rec.ATTRIBUTE1,
                  X_ATTRIBUTE2            => c2_rec.ATTRIBUTE2,
                  X_ATTRIBUTE3            => c2_rec.ATTRIBUTE3,
                  X_ATTRIBUTE4            => c2_rec.ATTRIBUTE4,
                  X_ATTRIBUTE5            => c2_rec.ATTRIBUTE5,
                  X_ATTRIBUTE6            => c2_rec.ATTRIBUTE6,
                  X_ATTRIBUTE7            => c2_rec.ATTRIBUTE7,
                  X_ATTRIBUTE8            => c2_rec.ATTRIBUTE8,
                  X_ATTRIBUTE9            => c2_rec.ATTRIBUTE9,
                  X_ATTRIBUTE10           => c2_rec.ATTRIBUTE10,
                  X_ATTRIBUTE11           => c2_rec.ATTRIBUTE11,
                  X_ATTRIBUTE12           => c2_rec.ATTRIBUTE12,
                  X_ATTRIBUTE13           => c2_rec.ATTRIBUTE13,
                  X_ATTRIBUTE14           => c2_rec.ATTRIBUTE14,
                  X_ATTRIBUTE15           => c2_rec.ATTRIBUTE15,
                  X_ORG_ID                => c2_rec.org_id,
                  X_CREATION_DATE         => sysdate,
                  X_CREATED_BY            => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATE_DATE      => sysdate,
                  X_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
                  X_LAST_UPDATE_LOGIN     => FND_GLOBAL.LOGIN_ID,
                  X_CONSTR_START_DATE     => l_start_date,
                  X_CONSTR_END_DATE       => l_end_date);

                 l_constrID := NULL;
                 l_rowid := NULL;

           END LOOP;

        END LOOP;

   PNp_debug_pkg.debug(' create_default_constraints +');

END create_default_constraints;

 /*===========================================================================+
 | PROCEDURE CREATE_DEFAULT_LINES
 |
 |
 | DESCRIPTION
 |    Create records in the PN_VAR_LINES_ALL table from date range lines.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 |     13-FEB-2003  Gary Olson  o Created
 |     04-jun-03    graghuna    o Removed min/max amount and reverted back to
 |                                type code , amount and used table handlers.
 |     03-NOV-2003  cthangai    o CODEV: NBP -
 |     12-JAN-2004  Srini       o Support for not creating lines again for Natural Bkpt
 |     09-FEB-2004  Srini       o Support for 1 to Many for Line Defaults to Header Defaults
 +===========================================================================*/

 procedure create_default_lines (X_VAR_RENT_ID   IN NUMBER,
                                 X_CREATE_FLAG   IN VARCHAR2 DEFAULT 'N') IS
   l_var_rent_id            NUMBER        := NULL;
   l_rowId                  VARCHAR2(18)  := NULL;
   l_line_item_id           NUMBER        := NULL;
   l_line_item_num          NUMBER        := NULL;
   l_bkpt_header_id         NUMBER        := NULL;
   l_period_start           DATE          := NULL;
   l_period_end             DATE          := NULL;
   l_bkhd_start_date        DATE          := NULL;
   l_bkhd_end_date          DATE          := NULL;
   l_bkptsNum               NUMBER        := NULL;
   l_bkpt_detail_id         NUMBER        := 0;
   l_bkpt_detail_num        NUMBER        := 0;
   l_null                   VARCHAR2(150) := NULL;
   l_reporting_periods      NUMBER        := 0;
   l_period_bkpt_vol_start  NUMBER        := 0;
   l_period_bkpt_vol_end    NUMBER        := 0;
   l_group_bkpt_vol_start   NUMBER        := 0;
   l_group_bkpt_vol_end     NUMBER        := 0;
   l_filename               VARCHAR2(50) := 'CREATE_DEFAULT_LINES-'||x_var_rent_id || '-'||to_char(sysdate,'MMDDYYHHMMSS');
   l_pathname               VARCHAR2(20) := '/usr/tmp';
   l_dummy                  VARCHAR2(2)  := NULL;
   l_cnt                    NUMBER;
   l_sales_type_code        VARCHAR2(30);
   l_item_category_code     VARCHAR2(30);

   CURSOR c_periods
   IS
      select a.period_id,
             a.start_date,
             a.end_date,
             b.reptg_freq_code
      from pn_var_periods_all a,
           pn_var_rent_dates_all b
      where a.var_rent_id = l_var_rent_id
      and   a.var_rent_id = b.var_rent_id;

   CURSOR c_lines (p_start_date DATE, p_end_date DATE)
   IS
     SELECT *
            /*sales_type_code,
            item_category_code,
            line_template_id,
            agreement_template_id,
            line_start_date,
            line_end_date,
            line_default_id,
            created_by,
            org_id*/
     FROM pn_var_line_defaults_all
     WHERE var_rent_id = l_var_rent_id
     --AND NVL(processed_flag,0) <> 1
     AND (p_start_date BETWEEN line_start_date AND line_end_date
     OR p_end_date BETWEEN line_start_date AND line_end_date
     OR line_start_date BETWEEN p_start_date AND p_end_date
     OR line_end_date BETWEEN p_start_date AND p_end_date);

   CURSOR c_bkheads (p_line_default_id NUMBER)
   IS
     SELECT *
            /*bkhd_default_id,
            line_default_id,
            bkhd_start_date,
            bkhd_end_date,
            break_type,
            base_rent_type,
            natural_break_rate,
            base_rent,
            breakpoint_type,
            breakpoint_level,
            bkpt_head_template_id,
            agreement_template_id,
            last_update_login,
            org_id*/
     from pn_var_bkhd_defaults_all
     where line_default_id = p_line_default_id
     and NVL(processed_flag,0) <> 1;

   CURSOR c_bkdets (p_head_default_id NUMBER)
   IS
     SELECT *
            /*bkdt_default_id,
            bkdt_start_date,
            bkdt_end_date,
            period_bkpt_vol_start,
            period_bkpt_vol_end,
            group_bkpt_vol_start,
            group_bkpt_vol_end,
            bkpt_rate,
            org_id,
            annual_basis_amount --03-NOV-2003 */
     from pn_var_bkdt_defaults_all
     where bkhd_default_id = p_head_default_id
     and NVL(processed_flag,0) <> 1;

   CURSOR c_rep_periods(p_period_id NUMBER)
   IS
     select count(grp_start_date)
     from pn_var_grp_dates_all
     where period_id = p_period_id;

   CURSOR line_exists_cur ( ip_period_id NUMBER,ip_item_category_code  VARCHAR2,ip_sales_type_code VARCHAR2)
   IS
     SELECT 'x' line_exists
     FROM   dual
     WHERE  exists ( select line_item_id
                     from pn_var_lines_all
                     where period_id = ip_period_id
                     and   item_category_code = ip_item_category_code
                     and  sales_type_code = ip_sales_type_code);

   /* codev changes - line_exists_cur fails in its purpose if either item_category_code or  sales_type_code is null
      Hence we require two more cursors which fetch the lines incase any one of them is null*/
   CURSOR line_exists_sales_cur ( ip_period_id NUMBER,ip_sales_type_code VARCHAR2)
   IS
     SELECT 'x' line_exists
     FROM   dual
     WHERE  exists ( select line_item_id
                     from pn_var_lines_all
                     where period_id = ip_period_id
                     and   sales_type_code = ip_sales_type_code
                     and rownum <2);

   CURSOR line_exists_item_cur ( ip_period_id NUMBER,ip_item_category_code  VARCHAR2)
   IS
     SELECT 'x' line_exists
     FROM   dual
     WHERE  exists ( select line_item_id
                     from pn_var_lines_all
                     where period_id = ip_period_id
                     and   item_category_code = ip_item_category_code
                     and rownum <2);
   /* codev changes ends */

   CURSOR c_bkheads_natural(p_line_default_id NUMBER)
   IS
     SELECT *
            /*bkhd_default_id,
            line_default_id,
            bkhd_start_date,
            bkhd_end_date,
            break_type,
            base_rent_type,
            natural_break_rate,
            base_rent,
            breakpoint_type,
            breakpoint_level,
            bkpt_head_template_id,
            agreement_template_id,
            last_update_login,
            org_id */
     FROM pn_var_bkhd_defaults_all
     WHERE line_default_id = p_line_default_id
     AND break_type = 'NATURAL';

   CURSOR c_bkdets_natural (p_head_default_id NUMBER)
   IS
     SELECT *
            /*bkdt_default_id,
            bkdt_start_date,
            bkdt_end_date,
            period_bkpt_vol_start,
            period_bkpt_vol_end,
            group_bkpt_vol_start,
            group_bkpt_vol_end,
            bkpt_rate,
            org_id,
            annual_basis_amount --03-NOV-2003 */
     FROM pn_var_bkdt_defaults_all
     WHERE bkhd_default_id = p_head_default_id;

   CURSOR header_defaults_cur(p_var_rent_id NUMBER)
   IS
     SELECT bkhd_default_id
     FROM pn_var_bkhd_defaults_all
     WHERE var_rent_id = p_var_rent_id;
     --AND break_type    = 'NATURAL';

 BEGIN
   --pnp_debug_pkg.enable_file_debug(l_pathname,l_filename);
   PNP_DEBUG_PKG.log('PN_VAR_DEFAULTS_PKG.CREATE_DEFAULT_LINES (+)');
   l_var_rent_id := x_var_rent_id;
   PNP_DEBUG_PKG.log('Parameter : x_var_rent_id = '|| l_var_rent_id);
   FOR c_period_rec IN c_periods
   LOOP
     PNP_DEBUG_PKG.log('Processing Period => '|| c_period_rec.period_id || ' ' ||
                                       c_period_rec.start_date || ' '||
                                       c_period_rec.end_date  || ' ' ||
                                       c_period_rec.reptg_freq_code);
     l_reporting_periods := NVL(pn_var_rent_pkg.find_reporting_periods(
                                p_freq_code => c_period_rec.reptg_freq_code),1);

     PNP_DEBUG_PKG.log( 'l_reporting_periods = '|| l_reporting_periods);
     FOR c_line_rec IN c_lines (c_period_rec.start_date, c_period_rec.end_date)
     LOOP
       PNP_DEBUG_PKG.log('Processing line Default ID: ' || c_line_rec.line_default_id);
       l_rowid          := NULL;
       l_line_item_id   := NULL;
       l_line_item_num  := NULL;
       l_dummy          := NULL;
       l_sales_type_code        := c_line_rec.sales_type_code;
       l_item_category_code     := c_line_rec.item_category_code;

       IF l_item_category_code IS NOT NULL AND l_sales_type_code IS NOT NULL THEN
          FOR Line_exists_rec in  line_exists_cur (c_period_rec.period_id,
                                                   c_line_rec.item_category_code,
                                                   c_line_rec.sales_type_code)
          LOOP
            l_dummy := line_exists_rec.line_exists;
          END LOOP;
       ELSIF  c_line_rec.item_category_code IS NULL AND c_line_rec.sales_type_code IS NOT NULL THEN
          FOR Line_exists_rec in  line_exists_sales_cur (c_period_rec.period_id,
                                                         c_line_rec.sales_type_code)
          LOOP
            l_dummy := line_exists_rec.line_exists;
          END LOOP;
       ELSIF  c_line_rec.sales_type_code IS NULL AND c_line_rec.item_category_code IS NOT NULL THEN
          FOR Line_exists_rec in  line_exists_item_cur (c_period_rec.period_id,
                                                        c_line_rec.item_category_code)
          LOOP
            l_dummy := line_exists_rec.line_exists;
          END LOOP;
       END IF;


       IF l_dummy IS NULL THEN
         PN_VAR_LINES_PKG.INSERT_ROW(l_rowid,
                                     l_line_item_id,
                                     l_line_item_num,
                                     c_period_rec.period_id,
                                     c_line_rec.sales_type_code,
                                     c_line_rec.item_category_code,
                                     l_null,
                                     c_line_rec.ATTRIBUTE_CATEGORY,
                                     c_line_rec.ATTRIBUTE1,
                                     c_line_rec.ATTRIBUTE2,
                                     c_line_rec.ATTRIBUTE3,
                                     c_line_rec.ATTRIBUTE4,
                                     c_line_rec.ATTRIBUTE5,
                                     c_line_rec.ATTRIBUTE6,
                                     c_line_rec.ATTRIBUTE7,
                                     c_line_rec.ATTRIBUTE8,
                                     c_line_rec.ATTRIBUTE9,
                                     c_line_rec.ATTRIBUTE10,
                                     c_line_rec.ATTRIBUTE11,
                                     c_line_rec.ATTRIBUTE12,
                                     c_line_rec.ATTRIBUTE13,
                                     c_line_rec.ATTRIBUTE14,
                                     c_line_rec.ATTRIBUTE15,
                                     c_line_rec.org_id,
                                     sysdate,
                                     NVL(fnd_profile.value('USER_ID'),0),
                                     sysdate,
                                     NVL(fnd_profile.value('USER_ID'),0),
                                     NVL(fnd_profile.value('USER_ID'),0),
                                     c_line_rec.line_template_id,
                                     c_line_rec.agreement_template_id,
                                     c_line_rec.line_default_id,
                                     l_var_rent_id);

         /*
         UPDATE pn_var_line_defaults_all
         SET processed_flag  = 1
         WHERE var_rent_id   = l_var_rent_id
         AND line_default_id = c_line_rec.line_default_id
         AND line_start_date >= c_period_rec.start_date
         AND line_end_date   <= c_period_rec.end_date;
         */
       ELSE
         SELECT line_item_id
         INTO l_line_item_id
         FROM pn_var_lines_all
         WHERE line_default_id  = c_line_rec.line_default_id
         AND period_id          = c_period_rec.period_id
         AND var_rent_id        = l_var_rent_id
         AND ROWNUM             = 1;
       END IF;

       --PNP_DEBUG_PKG.log('X_CREATE_FLAG:'|| X_CREATE_FLAG);
       --PNP_DEBUG_PKG.log('Line Item ID:'|| l_line_item_id);
       IF X_CREATE_FLAG = 'N' THEN
         FOR c_head_rec IN c_bkheads (c_line_rec.line_default_id)
         LOOP
           PNP_DEBUG_PKG.log('Processing header for Line Default =' || c_line_rec.line_default_id);
           l_rowid              := NULL;
           l_bkpt_header_id     := NULL;
           l_bkhd_start_date    := NULL;
           l_bkhd_end_Date      := NULL;

           PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW(x_rowid                     => l_rowid,
                                            x_bkpt_header_id            => l_bkpt_header_id,
                                            x_line_item_id              => l_line_item_id,
                                            x_period_id                 => c_period_rec.period_id,
                                            x_break_type                => c_head_rec.break_type,
                                            x_base_rent_type            => c_head_rec.base_rent_type,
                                            x_natural_break_rate        => c_head_rec.natural_break_rate,
                                            x_base_rent                 => c_head_rec.base_rent,
                                            x_breakpoint_type           => c_head_rec.breakpoint_type,
                                            x_bkhd_default_id           => c_head_rec.bkhd_default_id,
                                            x_bkhd_start_date           => null,
                                            x_bkhd_end_date             => null,
                                            x_var_rent_id               => l_var_rent_id,
                                            x_attribute_category        => c_head_rec.ATTRIBUTE_CATEGORY,
                                            x_attribute1                => c_head_rec.ATTRIBUTE1,
                                            x_attribute2                => c_head_rec.ATTRIBUTE2,
                                            x_attribute3                => c_head_rec.ATTRIBUTE3,
                                            x_attribute4                => c_head_rec.ATTRIBUTE4,
                                            x_attribute5                => c_head_rec.ATTRIBUTE5,
                                            x_attribute6                => c_head_rec.ATTRIBUTE6,
                                            x_attribute7                => c_head_rec.ATTRIBUTE7,
                                            x_attribute8                => c_head_rec.ATTRIBUTE8,
                                            x_attribute9                => c_head_rec.ATTRIBUTE9,
                                            x_attribute10               => c_head_rec.ATTRIBUTE10,
                                            x_attribute11               => c_head_rec.ATTRIBUTE11,
                                            x_attribute12               => c_head_rec.ATTRIBUTE12,
                                            x_attribute13               => c_head_rec.ATTRIBUTE13,
                                            x_attribute14               => c_head_rec.ATTRIBUTE14,
                                            x_attribute15               => c_head_rec.ATTRIBUTE15,
                                            x_org_id                    => c_head_rec.org_id,
                                            x_creation_date             => sysdate,
                                            x_created_by                => NVL(fnd_profile.value('USER_ID'),0),
                                            x_last_update_date          => sysdate,
                                            x_last_updated_by           => NVL(fnd_profile.value('USER_ID'),0),
                                            x_last_update_login         => NVL(fnd_profile.value('LOGIN_ID'),0),
                                            x_bkpt_update_flag          => c_head_rec.bkpt_update_flag);

           FOR c_det_rec IN c_bkdets (c_head_rec.bkhd_default_id)
           LOOP
             PNP_DEBUG_PKG.log('Processing detail for Header Default = '|| c_head_rec.bkhd_default_id);

             IF c_det_rec.bkdt_start_date > c_period_rec.start_date THEN
               l_period_start := c_det_rec.bkdt_start_date;
             ELSE
               l_period_start := c_period_rec.start_date;
             END IF;

             IF c_det_rec.bkdt_end_date < c_period_rec.end_date THEN
               l_period_end := c_det_rec.bkdt_end_date;
             ELSE
               l_period_end := c_period_rec.end_date;
             END IF;

             IF nvl(c_head_rec.breakpoint_level,'PERIOD') = 'PERIOD' THEN
               l_period_bkpt_vol_start := NVL(c_det_rec.period_bkpt_vol_start,0);
               l_period_bkpt_vol_end   := NVL(c_det_rec.period_bkpt_vol_end,0);
               IF l_period_bkpt_vol_start <> 0 THEN
                 l_group_bkpt_vol_start := round((l_period_bkpt_vol_start/l_reporting_periods),2);
               ELSE
                 l_group_bkpt_vol_start := 0;
               END IF;
               IF l_period_bkpt_vol_end <> 0 THEN
                 l_group_bkpt_vol_end := round((l_period_bkpt_vol_end/l_reporting_periods),2);
               ELSE
                 l_group_bkpt_vol_end := 0;
               END IF;
             ELSE
               l_group_bkpt_vol_start := NVL(c_det_rec.group_bkpt_vol_start,0);
               l_group_bkpt_vol_end   := NVL(c_det_rec.group_bkpt_vol_end,0);
               IF l_group_bkpt_vol_start <> 0 THEN
                 l_period_bkpt_vol_start := round((l_group_bkpt_vol_start*l_reporting_periods),2);
               ELSE
                 l_period_bkpt_vol_start := 0;
               END IF;
               IF l_group_bkpt_vol_end <> 0 THEN
                 l_period_bkpt_vol_end := round((l_group_bkpt_vol_end*l_reporting_periods),2);
               ELSE
                 l_period_bkpt_vol_end := 0;
               END IF;

             END IF;
             IF l_period_end >= l_period_start THEN
               l_rowid                  := NULL;
               l_bkpt_detail_id         := NULL;
               l_bkpt_detail_num        := NULL;

               PN_VAR_BKPTS_DET_PKG.INSERT_ROW(
                                      l_rowid,
                                      l_bkpt_detail_id,
                                      l_bkpt_detail_num,
                                      l_bkpt_header_id,
                                      l_period_start,
                                      l_period_end,
                                      l_period_bkpt_vol_start,
                                      l_period_bkpt_vol_end,
                                      l_group_bkpt_vol_start,
                                      l_group_bkpt_vol_end,
                                      c_det_rec.bkpt_rate,
                                      c_det_rec.bkdt_default_id,
                                      l_var_rent_id,
                                      l_null,
                                      c_det_rec.ATTRIBUTE_CATEGORY,
                                      c_det_rec.ATTRIBUTE1,
                                      c_det_rec.ATTRIBUTE2,
                                      c_det_rec.ATTRIBUTE3,
                                      c_det_rec.ATTRIBUTE4,
                                      c_det_rec.ATTRIBUTE5,
                                      c_det_rec.ATTRIBUTE6,
                                      c_det_rec.ATTRIBUTE7,
                                      c_det_rec.ATTRIBUTE8,
                                      c_det_rec.ATTRIBUTE9,
                                      c_det_rec.ATTRIBUTE10,
                                      c_det_rec.ATTRIBUTE11,
                                      c_det_rec.ATTRIBUTE12,
                                      c_det_rec.ATTRIBUTE13,
                                      c_det_rec.ATTRIBUTE14,
                                      c_det_rec.ATTRIBUTE15,
                                      c_det_rec.org_id,
                                      sysdate,
                                      NVL(fnd_profile.value('USER_ID'),0),
                                      sysdate,
                                      NVL(fnd_profile.value('USER_ID'),0),
                                      NVL(fnd_profile.value('USER_ID'),0),
                                      c_det_rec.annual_basis_amount         --03-NOV-2003
                                     );

               IF l_bkhd_start_date is NULL OR
                 l_period_start < l_bkhd_start_date THEN
                 l_bkhd_start_date := l_period_start;
               END IF;

               IF l_bkhd_end_date is NULL OR
                 l_period_end > l_bkhd_end_date THEN
                 l_bkhd_end_date := l_period_end;
               END IF;

               IF c_head_rec.break_type = 'NATURAL' THEN
                 UPDATE pn_var_bkdt_defaults_all
                 SET processed_flag = 1
                 WHERE var_rent_id = l_var_rent_id
                 AND bkdt_default_id = c_det_rec.bkdt_default_id;
               END IF;
             END IF;

           END LOOP;

           UPDATE pn_var_bkpts_head_all
           SET bkhd_start_date  = l_bkhd_start_date,
               bkhd_end_date    = l_bkhd_end_date
           WHERE bkpt_header_id = l_bkpt_header_id;

         END LOOP;

       ELSE
         FOR c_head_rec IN c_bkheads_natural (c_line_rec.line_default_id)
         LOOP
           PNP_DEBUG_PKG.log('Processing Natural header for Line Default =' || c_line_rec.line_default_id);
           l_rowid              := NULL;
           l_bkpt_header_id     := NULL;
           l_bkhd_start_date    := NULL;
           l_bkhd_end_Date      := NULL;

           BEGIN
             PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW(x_rowid                     => l_rowid,
                                              x_bkpt_header_id            => l_bkpt_header_id,
                                              x_line_item_id              => l_line_item_id,
                                              x_period_id                 => c_period_rec.period_id,
                                              x_break_type                => c_head_rec.break_type,
                                              x_base_rent_type            => c_head_rec.base_rent_type,
                                              x_natural_break_rate        => c_head_rec.natural_break_rate,
                                              x_base_rent                 => c_head_rec.base_rent,
                                              x_breakpoint_type           => c_head_rec.breakpoint_type,
                                              x_bkhd_default_id           => c_head_rec.bkhd_default_id,
                                              x_bkhd_start_date           => null,
                                              x_bkhd_end_date             => null,
                                              x_var_rent_id               => l_var_rent_id,
                                              x_attribute_category        => c_head_rec.ATTRIBUTE_CATEGORY,
                                              x_attribute1                => c_head_rec.ATTRIBUTE1,
                                              x_attribute2                => c_head_rec.ATTRIBUTE2,
                                              x_attribute3                => c_head_rec.ATTRIBUTE3,
                                              x_attribute4                => c_head_rec.ATTRIBUTE4,
                                              x_attribute5                => c_head_rec.ATTRIBUTE5,
                                              x_attribute6                => c_head_rec.ATTRIBUTE6,
                                              x_attribute7                => c_head_rec.ATTRIBUTE7,
                                              x_attribute8                => c_head_rec.ATTRIBUTE8,
                                              x_attribute9                => c_head_rec.ATTRIBUTE9,
                                              x_attribute10               => c_head_rec.ATTRIBUTE10,
                                              x_attribute11               => c_head_rec.ATTRIBUTE11,
                                              x_attribute12               => c_head_rec.ATTRIBUTE12,
                                              x_attribute13               => c_head_rec.ATTRIBUTE13,
                                              x_attribute14               => c_head_rec.ATTRIBUTE14,
                                              x_attribute15               => c_head_rec.ATTRIBUTE15,
                                              x_org_id                    => c_head_rec.org_id,
                                              x_creation_date             => sysdate,
                                              x_created_by                => NVL(fnd_profile.value('USER_ID'),0),
                                              x_last_update_date          => sysdate,
                                              x_last_updated_by           => NVL(fnd_profile.value('USER_ID'),0),
                                              x_last_update_login         => NVL(fnd_profile.value('LOGIN_ID'),0),
                                              x_bkpt_update_flag          => c_head_rec.bkpt_update_flag);
             EXCEPTION
               WHEN OTHERS THEN
                 NULL;
           END;

           FOR c_det_rec IN c_bkdets_natural (c_head_rec.bkhd_default_id)
           LOOP
             PNP_DEBUG_PKG.log('Processing Natural detail for Header Default = '|| c_head_rec.bkhd_default_id);
             IF c_det_rec.bkdt_start_date > c_period_rec.start_date THEN
               l_period_start := c_det_rec.bkdt_start_date;
             ELSE
               l_period_start := c_period_rec.start_date;
             END IF;

             IF c_det_rec.bkdt_end_date < c_period_rec.end_date THEN
               l_period_end := c_det_rec.bkdt_end_date;
             ELSE
               l_period_end := c_period_rec.end_date;
             END IF;

             IF nvl(c_head_rec.breakpoint_level,'PERIOD') = 'PERIOD' THEN
               l_period_bkpt_vol_start := NVL(c_det_rec.period_bkpt_vol_start,0);
               l_period_bkpt_vol_end   := NVL(c_det_rec.period_bkpt_vol_end,0);
               IF l_period_bkpt_vol_start <> 0 THEN
                 l_group_bkpt_vol_start := round((l_period_bkpt_vol_start/l_reporting_periods),2);
               ELSE
                 l_group_bkpt_vol_start := 0;
               END IF;
               IF l_period_bkpt_vol_end <> 0 THEN
                 l_group_bkpt_vol_end := round((l_period_bkpt_vol_end/l_reporting_periods),2);
               ELSE
                 l_group_bkpt_vol_end := 0;
               END IF;
             ELSE
               l_group_bkpt_vol_start := NVL(c_det_rec.group_bkpt_vol_start,0);
               l_group_bkpt_vol_end   := NVL(c_det_rec.group_bkpt_vol_end,0);
               IF l_group_bkpt_vol_start <> 0 THEN
                 l_period_bkpt_vol_start := round((l_group_bkpt_vol_start*l_reporting_periods),2);
               ELSE
                 l_period_bkpt_vol_start := 0;
               END IF;
               IF l_group_bkpt_vol_end <> 0 THEN
                 l_period_bkpt_vol_end := round((l_group_bkpt_vol_end*l_reporting_periods),2);
               ELSE
                 l_period_bkpt_vol_end := 0;
               END IF;
             END IF;

             IF l_period_end >= l_period_start THEN
               l_rowid                  := NULL;
               l_bkpt_detail_id         := NULL;
               l_bkpt_detail_num        := NULL;

               BEGIN
                 PN_VAR_BKPTS_DET_PKG.INSERT_ROW(X_ROWID                 => l_rowid,
                                                 X_BKPT_DETAIL_ID        => l_bkpt_detail_id,
                                                 X_BKPT_DETAIL_NUM       => l_bkpt_detail_num,
                                                 X_BKPT_HEADER_ID        => l_bkpt_header_id,
                                                 X_BKPT_START_DATE       => l_period_start,
                                                 X_BKPT_END_DATE         => l_period_end,
                                                 X_PERIOD_BKPT_VOL_START => l_period_bkpt_vol_start,
                                                 X_PERIOD_BKPT_VOL_END   => l_period_bkpt_vol_end,
                                                 X_GROUP_BKPT_VOL_START  => l_group_bkpt_vol_start,
                                                 X_GROUP_BKPT_VOL_END    => l_group_bkpt_vol_end,
                                                 X_BKPT_RATE             => c_det_rec.bkpt_rate,
                                                 X_BKDT_DEFAULT_ID       => c_det_rec.bkdt_default_id,
                                                 X_VAR_RENT_ID           => l_var_rent_id,
                                                 X_COMMENTS              => l_null,
                                                 X_ATTRIBUTE_CATEGORY    => c_det_rec.ATTRIBUTE_CATEGORY,
                                                 X_ATTRIBUTE1            => c_det_rec.ATTRIBUTE1,
                                                 X_ATTRIBUTE2            => c_det_rec.ATTRIBUTE2,
                                                 X_ATTRIBUTE3            => c_det_rec.ATTRIBUTE3,
                                                 X_ATTRIBUTE4            => c_det_rec.ATTRIBUTE4,
                                                 X_ATTRIBUTE5            => c_det_rec.ATTRIBUTE5,
                                                 X_ATTRIBUTE6            => c_det_rec.ATTRIBUTE6,
                                                 X_ATTRIBUTE7            => c_det_rec.ATTRIBUTE7,
                                                 X_ATTRIBUTE8            => c_det_rec.ATTRIBUTE8,
                                                 X_ATTRIBUTE9            => c_det_rec.ATTRIBUTE9,
                                                 X_ATTRIBUTE10           => c_det_rec.ATTRIBUTE10,
                                                 X_ATTRIBUTE11           => c_det_rec.ATTRIBUTE11,
                                                 X_ATTRIBUTE12           => c_det_rec.ATTRIBUTE12,
                                                 X_ATTRIBUTE13           => c_det_rec.ATTRIBUTE13,
                                                 X_ATTRIBUTE14           => c_det_rec.ATTRIBUTE14,
                                                 X_ATTRIBUTE15           => c_det_rec.ATTRIBUTE15,
                                                 X_ORG_ID                => c_det_rec.org_id,
                                                 X_CREATION_DATE         => sysdate,
                                                 X_CREATED_BY            => NVL(fnd_profile.value('USER_ID'),0),
                                                 X_LAST_UPDATE_DATE      => sysdate,
                                                 X_LAST_UPDATED_BY       => NVL(fnd_profile.value('USER_ID'),0),
                                                 X_LAST_UPDATE_LOGIN     => NVL(fnd_profile.value('USER_ID'),0),
                                                 X_ANNUAL_BASIS_AMOUNT   => c_det_rec.annual_basis_amount
                                                );
                 EXCEPTION
                   WHEN OTHERS THEN
                     NULL;
               END;

               IF l_bkhd_start_date is NULL OR l_period_start < l_bkhd_start_date THEN
                 l_bkhd_start_date := l_period_start;
               END IF;

               IF l_bkhd_end_date is NULL OR l_period_end > l_bkhd_end_date THEN
                 l_bkhd_end_date := l_period_end;
               END IF;

               UPDATE pn_var_bkdt_defaults_all
               SET processed_flag  =  1
               WHERE var_rent_id   =  l_var_rent_id
               AND bkdt_default_id =  c_det_rec.bkdt_default_id;
             END IF;

           END LOOP;

           UPDATE pn_var_bkpts_head_all
           SET bkhd_start_date   = l_bkhd_start_date,
               bkhd_end_date     = l_bkhd_end_date
           WHERE  bkpt_header_id = l_bkpt_header_id;
         END LOOP;
       END IF;          --X_CREATE_FLAG

     END LOOP;
   END LOOP;

        UPDATE pn_var_bkhd_defaults_all
        SET bkpt_update_flag = 'N'
        WHERE var_rent_id = x_var_rent_id;

   --For Artificial, Update only the ones which made it to pn_var_bkpts_head_all
   /* DBMS_OUTPUT.PUT_LINE(' Step1'); */
   UPDATE pn_var_bkdt_defaults_all
   SET processed_flag  = 1
   WHERE var_rent_id   = l_var_rent_id
   AND bkhd_default_id IN (SELECT a.bkhd_default_id
                           FROM pn_var_bkhd_defaults_all a,
                                pn_var_bkpts_head_all b
                           WHERE a.var_rent_id     = b.var_rent_id
                           AND a.var_rent_id       = l_var_rent_id
                           AND a.bkhd_default_id   = b.bkhd_default_id
                           AND a.break_type        = b.break_type
                           AND a.break_type        <> 'NATURAL');

   /* DBMS_OUTPUT.PUT_LINE(' Step2');*/
   FOR i IN header_defaults_cur(l_var_rent_id)
   LOOP
     --Set the header flag to 1 if all detail records are processed
     l_cnt := 0;
     SELECT COUNT(*)
     INTO l_cnt
     FROM pn_var_bkdt_defaults_all
     WHERE bkhd_default_id     = i.bkhd_default_id
     AND NVL(processed_flag,0) <> 1;
     IF l_cnt = 0 THEN
       UPDATE pn_var_bkhd_defaults_all
       SET processed_flag  =  1
       WHERE var_rent_id   =  l_var_rent_id
       AND bkhd_default_id =  i.bkhd_default_id;
   /* DBMS_OUTPUT.PUT_LINE(' Step3'); */
     ELSE
       UPDATE pn_var_bkhd_defaults_all
       SET processed_flag  =  0
       WHERE var_rent_id   =  l_var_rent_id
       AND bkhd_default_id =  i.bkhd_default_id;
   /* DBMS_OUTPUT.PUT_LINE(' Step4'); */
     END IF;
   END LOOP;

   /* Need to be revisited */
   DELETE FROM pn_var_bkpts_head_all
   WHERE var_rent_id = l_var_rent_id
   AND bkhd_start_date IS NULL
   AND bkhd_end_date IS NULL;
   --PNP_DEBUG_PKG.disable_file_debug;
   PNP_DEBUG_PKG.log('PN_VAR_DEFAULTS_PKG.CREATE_DEFAULT_LINES (-)');

end create_default_lines;

/*===========================================================================+
 | PROCEDURE DELETE_DEFAULT_LINES
 |
 |
 | DESCRIPTION
 |    Delete records from the PN_VAR_LINE_DEFAULTS_ALL tables.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 |     13-MAR-2003  Gary Olson          o Created
 |     16-FEB-2004  Srini Vijayareddy   o Support for multiple default header
 |
 +===========================================================================*/

procedure delete_default_lines (X_VAR_RENT_ID           IN      NUMBER,
                                x_bkhd_default_id       IN      NUMBER DEFAULT NULL,
                                x_bkpt_header_id        IN      NUMBER DEFAULT NULL)   IS
begin

  IF x_bkhd_default_id IS NULL AND x_bkpt_header_id IS NULL THEN
    DELETE FROM pn_var_bkpts_det_all
    WHERE var_rent_id = X_VAR_RENT_ID;

    DELETE FROM pn_var_bkpts_head_all
    WHERE var_rent_id = X_VAR_RENT_ID;

    /*DELETE FROM pn_var_vol_hist_all
    WHERE line_item_id IN (SELECT line_item_id
                           FROM pn_var_lines_all
                           WHERE var_rent_id = X_VAR_RENT_ID);

    DELETE FROM pn_var_lines_all
    WHERE var_rent_id = X_VAR_RENT_ID;

    DELETE FROM pn_var_transactions_all
    WHERE var_rent_id = X_VAR_RENT_ID;*/

    --COMMIT;

    UPDATE pn_var_line_defaults_all
    SET processed_flag = 0
    WHERE var_rent_id = X_VAR_RENT_ID;

    UPDATE pn_var_bkhd_defaults_all
    SET processed_flag = 0
    WHERE var_rent_id = X_VAR_RENT_ID;

    UPDATE pn_var_bkdt_defaults_all
    SET processed_flag = 0
    WHERE var_rent_id = X_VAR_RENT_ID;

    --COMMIT;
  ELSE
    IF x_bkhd_default_id IS NOT NULL THEN
      /*DELETE FROM pn_var_transactions_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_detail_id IN (SELECT det.bkpt_detail_id
                             FROM pn_var_bkpts_det_all det,
                                  pn_var_bkpts_head_all head
                             WHERE det.var_rent_id = X_VAR_RENT_ID
                             AND det.var_rent_id = head.var_rent_id
                             AND det.bkpt_header_id = head.bkpt_header_id
                             AND head.bkhd_default_id = x_bkhd_default_id);*/

/* commented by parag
      DELETE FROM pn_var_vol_hist_all
      --WHERE vol_hist_status_code <> 'APPROVED'
      WHERE actual_exp_code = 'N'
      AND line_item_id IN (SELECT line_item_id
                           FROM pn_var_bkpts_head_all
                           WHERE var_rent_id = X_VAR_RENT_ID
                           AND bkhd_default_id = x_bkhd_default_id)
      AND line_item_id NOT IN (SELECT line_item_id
                               FROM pn_var_bkpts_head_all
                               WHERE var_rent_id = X_VAR_RENT_ID
                               AND bkhd_default_id <> x_bkhd_default_id); */

/* commented by parag
      DELETE FROM pn_var_lines_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND line_item_id IN (SELECT line_item_id
                           FROM pn_var_bkpts_head_all
                           WHERE bkhd_default_id = x_bkhd_default_id)
      AND line_item_id NOT IN (SELECT line_item_id
                               FROM pn_var_bkpts_head_all
                               WHERE var_rent_id = X_VAR_RENT_ID
                               AND bkhd_default_id <> x_bkhd_default_id); */

      DELETE FROM pn_var_bkpts_det_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_header_id IN (SELECT bkpt_header_id
                             FROM pn_var_bkpts_head_all
                             WHERE bkhd_default_id = x_bkhd_default_id);

      DELETE FROM pn_var_bkpts_head_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkhd_default_id = x_bkhd_default_id;
     -- COMMIT;

      UPDATE pn_var_line_defaults_all
      SET processed_flag = 0
      WHERE var_rent_id = X_VAR_RENT_ID;

      UPDATE pn_var_bkhd_defaults_all
      SET processed_flag = 0
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkhd_default_id = x_bkhd_default_id;

      UPDATE pn_var_bkdt_defaults_all
      SET processed_flag = 0
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkhd_default_id = x_bkhd_default_id;
      --COMMIT;
    ELSE
      /*DELETE FROM pn_var_transactions_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_detail_id IN (SELECT bkpt_detail_id
                             FROM pn_var_bkpts_det_all
                             WHERE var_rent_id = X_VAR_RENT_ID
                             AND bkpt_header_id = x_bkpt_header_id);*/

     /* DELETE FROM pn_var_vol_hist_all
      --WHERE vol_hist_status_code <> 'APPROVED'
      WHERE actual_exp_code = 'N'
      AND line_item_id IN (SELECT line_item_id
                           FROM pn_var_bkpts_head_all
                           WHERE var_rent_id = X_VAR_RENT_ID
                           AND bkpt_header_id = x_bkpt_header_id)
      AND line_item_id NOT IN (SELECT line_item_id
                               FROM pn_var_bkpts_head_all
                               WHERE var_rent_id = X_VAR_RENT_ID
                               AND bkpt_header_id <> x_bkpt_header_id);

      DELETE FROM pn_var_lines_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND line_item_id IN (SELECT line_item_id
                           FROM pn_var_bkpts_head_all
                           WHERE bkpt_header_id = x_bkpt_header_id)
      AND line_item_id NOT IN (SELECT line_item_id
                               FROM pn_var_bkpts_head_all
                               WHERE var_rent_id = X_VAR_RENT_ID
                               AND bkpt_header_id <> x_bkpt_header_id);*/

      DELETE FROM pn_var_bkpts_det_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_header_id = x_bkpt_header_id;


      DELETE FROM pn_var_bkpts_head_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_header_id = x_bkpt_header_id;

      --COMMIT;
    END IF;
  END IF;

end delete_default_lines;

/*===========================================================================+
 | PROCEDURE RESET_DEFAULT_LINES
 |
 |
 | DESCRIPTION
 |    Delete records from the PN_VAR_LINE_DEFAULTS_ALL tables.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    X_LINE_DEFAULT_ID
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-MAR-2003  Gary Olson  o Created
 |
 +===========================================================================*/

procedure reset_default_lines (
    X_BKHD_DEFAULT_ID      in NUMBER
    )   IS

begin

   delete from pn_var_bkdt_defaults_all
      where bkhd_default_id = X_BKHD_DEFAULT_ID;

   --commit;

end reset_default_lines;

/*===========================================================================+
 | PROCEDURE DELETE_TRANSACTIONS
 |
 |
 | DESCRIPTION
 |    Delete records from the PN_VAR_TRANSACTIONS_ALL tables.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
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
 |     13-MAR-2003  Gary Olson          o Created
 |     16-FEB-2004  Srini Vijayareddy   o Support for multiple default header
 |
 +===========================================================================*/

procedure delete_transactions ( X_VAR_RENT_ID           in      NUMBER,
                                x_bkhd_default_id       IN      NUMBER DEFAULT NULL,
                                x_bkpt_header_id        IN      NUMBER DEFAULT NULL)   IS
begin

  /*IF x_bkhd_default_id IS NULL AND x_bkpt_header_id IS NULL THEN
    delete from pn_var_transactions_all
    where var_rent_id = X_VAR_RENT_ID;
  ELSE
    IF x_bkhd_default_id IS NOT NULL THEN
      DELETE FROM pn_var_transactions_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_detail_id IN (SELECT det.bkpt_detail_id
                             FROM pn_var_bkpts_det_all det,
                                  pn_var_bkpts_head_all head
                             WHERE det.var_rent_id = X_VAR_RENT_ID
                             AND det.var_rent_id = head.var_rent_id
                             AND det.bkpt_header_id = head.bkpt_header_id
                             AND head.bkhd_default_id = x_bkhd_default_id);
    ELSE
      DELETE FROM pn_var_transactions_all
      WHERE var_rent_id = X_VAR_RENT_ID
      AND bkpt_detail_id IN (SELECT bkpt_detail_id
                             FROM pn_var_bkpts_det_all
                             WHERE var_rent_id = X_VAR_RENT_ID
                             AND bkpt_header_id = x_bkpt_header_id);
    END IF;
  END IF;*/
  --COMMIT;
  NULL;

end delete_transactions;

/*===========================================================================+
 | FUNCTION
 |    CALCULATE_PARTIAL_FIRST_YEAR
 |
 | DESCRIPTION
 |    Calculates the partial first year rent due
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-MAR-2003  Gary Olson  o Created
 |
 +===========================================================================*/

FUNCTION calculate_partial_first_year (X_VAR_RENT_ID IN NUMBER)

      RETURN NUMBER IS

   cursor csr_check_no_days (p_var_rent_id NUMBER) IS
      select commencement_date,
             TO_DATE('31-12-'||TO_CHAR(commencement_date,'YYYY'),'DD-MM-YYYY') year,
             TO_DATE(TO_CHAR(commencement_date,'DD-MM-')||
             TO_CHAR(TO_NUMBER(TO_CHAR(commencement_date,'YYYY'))+1), 'DD-MM-YYYY')-1 end_date
      from pn_var_rents_all
      where var_rent_id = p_var_rent_id;

   /*cursor csr_group_sales (p_var_rent_id NUMBER, p_date DATE) IS
      select grp_date_id,bkpt_start_date, bkpt_end_date,
             no_of_group_days, prorated_group_sales
      from pn_var_transactions_all
      where var_rent_id = p_var_rent_id
      and prorated_group_sales is not null
      and grp_date_id in (select grp_date_id
          from pn_var_grp_dates_all
          where grp_start_date <= p_date );*/

  cursor csr_get_gd (p_grp_date_id NUMBER) IS
     select grp_start_date, grp_end_date
     from pn_var_grp_dates_all
     where grp_date_id = p_grp_date_id;

   l_start_date        DATE;
   l_end_date          DATE;
   l_grp_start_date    DATE;
   l_grp_end_date      DATE;
   l_reporting_date    DATE;
   l_proration_factor  NUMBER;
   l_sum_sales         NUMBER := 0;
   l_check_days        NUMBER := 0;
   l_proration_days    NUMBER := 0;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.calculate_partial_first_year (+)');

   /*open csr_check_no_days (X_VAR_RENT_ID);
   fetch csr_check_no_days into l_start_date, l_end_date, l_reporting_date;
   close csr_check_no_days;

   l_proration_factor := ((l_end_date - l_start_date) + 1)/365;
   l_sum_sales        := 0;

   FOR c_amt IN csr_group_sales(X_VAR_RENT_ID, l_reporting_date) LOOP
       IF l_reporting_date >= c_amt.bkpt_end_date THEN
          l_sum_sales := l_sum_sales + c_amt.prorated_group_sales;
       ELSE
          open csr_get_gd(c_amt.grp_date_id);
          fetch csr_get_gd into l_grp_start_date, l_grp_end_date;
          close csr_get_gd;
          IF c_amt.bkpt_start_date > l_grp_start_date THEN
             l_start_date := c_amt.bkpt_start_date;
          ELSE
             l_start_date := l_grp_start_date;
          END IF;
          l_check_days := (c_amt.bkpt_end_date - l_start_date)+1;
          l_proration_days := l_check_days/c_amt.no_of_group_days;
          l_sum_sales := l_sum_sales + c_amt.prorated_group_sales*l_proration_days;
       END IF;
   END LOOP;

   l_sum_sales := l_sum_sales/l_proration_factor;*/
   NULL;

   RETURN l_sum_sales;

   PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.calculate_partial_first_year (-)');

END calculate_partial_first_year;

/*===========================================================================+
 | FUNCTION
 |    CALCULATE_DEFAULT_BASE_RENT
 |
 | DESCRIPTION
 |    Calculates the base rent for a var_rent_id
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |                    p_base_rent_type
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 | NOTES      : Calculates the base rent for a given var_rent_id and base_rent_type
 |
 | MODIFICATION HISTORY
 |
 |     26-FEB-2003  Gary Olson  o Created
 |
 +===========================================================================*/

FUNCTION CALCULATE_DEFAULT_BASE_RENT (p_var_rent_id    NUMBER,
                                      p_base_rent_type VARCHAR2)
      RETURN NUMBER IS

      l_base_rent   NUMBER;

   BEGIN

        PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.CALCULATE_DEFAULT_BASE_RENT (+)');

      IF (p_base_rent_type = 'ROLLING') THEN

         SELECT sum(item.ACTUAL_AMOUNT)
         INTO   l_base_rent
         FROM   pn_payment_items_ALL item,
                pn_payment_terms_ALL term,
                pn_var_rents_ALL     var,
                pn_payment_schedules sched
         WHERE  item.PAYMENT_TERM_ID               = term.PAYMENT_TERM_ID
         AND    sched.PAYMENT_SCHEDULE_ID          = item.PAYMENT_SCHEDULE_ID
         AND    term.lease_id                      = var.lease_id
         AND    var.var_rent_id                    = p_var_rent_id
         AND    sched.SCHEDULE_DATE                between term.start_date and term.end_date
         AND    term.PAYMENT_PURPOSE_CODE          = 'RENT'
         AND    term.PAYMENT_TERM_TYPE_CODE        = 'BASER'
         AND    term.start_date                    >= var.commencement_date
         AND    term.end_date                      <= var.termination_date
         AND    item.PAYMENT_ITEM_TYPE_LOOKUP_CODE = 'CASH'
         AND    term.currency_code =  var.currency_code     --BUG#2452909
         ;
      ELSIF (p_base_rent_type = 'FIXED') THEN

         SELECT sum(item.ACTUAL_AMOUNT)
         INTO   l_base_rent
         FROM   pn_payment_items_ALL item,
                pn_payment_terms_ALL term,
                pn_var_rents_ALL     var,
                pn_payment_schedules sched
         WHERE  item.PAYMENT_TERM_ID               = term.PAYMENT_TERM_ID
         AND    sched.PAYMENT_SCHEDULE_ID          = item.PAYMENT_SCHEDULE_ID
         AND    term.lease_id                      = var.lease_id
         AND    var.var_rent_id                    = p_var_rent_id
         AND    sched.SCHEDULE_DATE                between term.start_date and term.end_date
         AND    term.PAYMENT_PURPOSE_CODE          = 'RENT'
         AND    term.PAYMENT_TERM_TYPE_CODE        = 'BASER'
         AND    term.start_date                    >= var.commencement_date
         AND    term.end_date                      <= var.termination_date
         AND    item.PAYMENT_ITEM_TYPE_LOOKUP_CODE = 'CASH'
         AND    term.currency_code =  var.currency_code
         ;
      END IF;
      RETURN l_base_rent;

   EXCEPTION

      WHEN OTHERS
      THEN
         RETURN NULL;

        PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.CALCULATE_DEFAULT_BASE_RENT (-)');

END CALCULATE_DEFAULT_BASE_RENT;

/*===========================================================================+
 | FUNCTION
 |    CALCULATE_PARTIAL_LAST_YEAR
 |
 | DESCRIPTION
 |    Calculates the partial last year rent due
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_var_rent_id
 |
 |              OUT:
 |
 | RETURNS    : None
 |
 |
 | MODIFICATION HISTORY
 |
 |     13-MAR-2003  Gary Olson  o Created
 |
 +===========================================================================*/

FUNCTION calculate_partial_last_year (X_VAR_RENT_ID IN NUMBER)

      RETURN NUMBER IS

   cursor csr_check_no_days (p_var_rent_id NUMBER) IS
      select TO_DATE(TO_CHAR(termination_date,'DD-MM-')||
             TO_CHAR(TO_NUMBER(TO_CHAR(termination_date,'YYYY'))-1), 'DD-MM-YYYY')+1 start_date,
             TO_DATE('1-1-'||TO_CHAR(termination_date,'YYYY'),'DD-MM-YYYY') year,
             termination_date
      from pn_var_rents_all
      where var_rent_id = p_var_rent_id;

   /*cursor csr_group_sales (p_var_rent_id NUMBER, p_date DATE) IS
      select grp_date_id,bkpt_start_date, bkpt_end_date,
             no_of_group_days, prorated_group_sales
      from pn_var_transactions_all
      where var_rent_id = p_var_rent_id
      and prorated_group_sales is not null
      and grp_date_id in (select grp_date_id
          from pn_var_grp_dates_all
          where grp_end_date >= p_date)
      order by bkpt_start_date desc;*/

  cursor csr_get_gd (p_grp_date_id NUMBER) IS
     select grp_start_date, grp_end_date
     from pn_var_grp_dates_all
     where grp_date_id = p_grp_date_id;

   l_start_date        DATE;
   l_end_date          DATE;
   l_grp_start_date    DATE;
   l_grp_end_date      DATE;
   l_reporting_date    DATE;
   l_proration_factor  NUMBER;
   l_sum_sales         NUMBER := 0;
   l_check_days        NUMBER := 0;
   l_proration_days    NUMBER := 0;

BEGIN

   PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.calculate_partial_last_year (+)');

   /*open csr_check_no_days (X_VAR_RENT_ID);
   fetch csr_check_no_days into l_reporting_date, l_start_date, l_end_date;
   close csr_check_no_days;

   l_proration_factor := ((l_end_date - l_start_date) + 1)/365;
   l_sum_sales        := 0;

   FOR c_amt IN csr_group_sales(X_VAR_RENT_ID, l_reporting_date) LOOP
       IF l_reporting_date <= c_amt.bkpt_start_date THEN
          l_sum_sales := l_sum_sales + c_amt.prorated_group_sales;
       ELSE
          open csr_get_gd(c_amt.grp_date_id);
          fetch csr_get_gd into l_grp_start_date, l_grp_end_date;
          close csr_get_gd;
          IF c_amt.bkpt_start_date > l_grp_start_date THEN
             l_start_date := c_amt.bkpt_start_date;
          ELSE
             l_start_date := l_grp_start_date;
          END IF;
          l_check_days := (c_amt.bkpt_end_date - l_start_date)+1;
          l_proration_days := l_check_days/c_amt.no_of_group_days;
          l_sum_sales := l_sum_sales + c_amt.prorated_group_sales*l_proration_days;
       END IF;
   END LOOP;

   l_sum_sales := l_sum_sales/l_proration_factor;*/
   NULL;

   RETURN l_sum_sales;

   PNP_DEBUG_PKG.debug ('PN_VAR_DEFAULTS_PKG.calcuLate_partial_last_year (-)');

END calculate_partial_last_year;

FUNCTION find_if_line_defaults_exist (p_var_rent_id NUMBER)
    RETURN NUMBER IS

l_line_found NUMBER  := 0;

BEGIN

   SELECT 1
   INTO l_line_found
   FROM pn_var_line_defaults_all
   WHERE var_rent_id = p_var_rent_id
   AND rownum < 2;

   RETURN l_line_found;

EXCEPTION

WHEN OTHERS THEN
     RETURN 0;

END find_if_line_defaults_exist;

FUNCTION find_if_constr_defaults_exist (p_var_rent_id NUMBER)
    RETURN NUMBER IS

l_constr_found NUMBER  := 0;

BEGIN

   SELECT 1
   INTO l_constr_found
   FROM pn_var_constr_defaults_all
   WHERE var_rent_id = p_var_rent_id;

   RETURN l_constr_found;

EXCEPTION

WHEN OTHERS THEN
     RETURN 0;

END find_if_constr_defaults_exist;

PROCEDURE populate_agreement (
      X_VAR_RENT_ID            in NUMBER,
      X_LINE_ID                in NUMBER,
      X_PERIOD_ID              in NUMBER,
      X_AGREEMENT_TEMPLATE_ID  in NUMBER,
      X_LINE_TEMPLATE_ID       in NUMBER,
      X_CURRENT_BLOCK          in VARCHAR2
      ) IS

  /*cursor c_bkhds IS
     select *
     from pn_var_bkpts_head_template_all
     where agreement_template_id = X_AGREEMENT_TEMPLATE_ID
     and line_template_id = X_LINE_TEMPLATE_ID;

  cursor c_bkdts (p_bkpt_head_template_id NUMBER) IS
    select *
    from pn_var_bkpts_det_template_all
    where bkpt_head_template_id = p_bkpt_head_template_id;*/

  l_rowid    VARCHAR2(18)   := NULL;
  l_itemId   NUMBER         := NULL;
  l_itemNum  NUMBER         := NULL;
  l_null     VARCHAR2(4000) := NULL;
  l_nullid   NUMBER         := NULL;
  l_nulldate DATE           := NULL;
  l_bkpt_header_id NUMBER   := NULL;

BEGIN

            /*IF X_CURRENT_BLOCK = ('LINE_ITEMS_BLK') THEN

               FOR c_hd IN c_bkhds LOOP
                  PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW (
                         X_ROWID                => l_rowid,
                         X_BKPT_HEADER_ID       => l_bkpt_header_id,
                         X_LINE_ITEM_ID         => X_LINE_ID,
                         X_PERIOD_ID            => X_PERIOD_ID,
                         X_BREAK_TYPE           => c_hd.break_type,
                         X_BASE_RENT_TYPE       => c_hd.base_rent_type,
                         X_NATURAL_BREAK_RATE   => c_hd.natural_break_rate,
                         X_BASE_RENT            => c_hd.base_rent,
                         X_BREAKPOINT_TYPE      => c_hd.breakpoint_type,
                         X_BKHD_DEFAULT_ID      => l_nullid,
                         X_BKHD_START_DATE      => NULL,
                         X_BKHD_END_DATE        => NULL,
                         X_VAR_RENT_ID          => X_VAR_RENT_ID,
                         X_ATTRIBUTE_CATEGORY   => l_null,
                         X_ATTRIBUTE1           => l_null,
                         X_ATTRIBUTE2           => l_null,
                         X_ATTRIBUTE3           => l_null,
                         X_ATTRIBUTE4           => l_null,
                         X_ATTRIBUTE5           => l_null,
                         X_ATTRIBUTE6           => l_null,
                         X_ATTRIBUTE7           => l_null,
                         X_ATTRIBUTE8           => l_null,
                         X_ATTRIBUTE9           => l_null,
                         X_ATTRIBUTE10          => l_null,
                         X_ATTRIBUTE11          => l_null,
                         X_ATTRIBUTE12          => l_null,
                         X_ATTRIBUTE13          => l_null,
                         X_ATTRIBUTE14          => l_null,
                         X_ATTRIBUTE15          => l_null,
                         X_ORG_ID               => c_hd.org_id,
                         X_CREATION_DATE        => sysdate,
                         X_CREATED_BY           => NVL(fnd_profile.value('USER_ID'),0),
                         X_LAST_UPDATE_DATE     => sysdate,
                         X_LAST_UPDATED_BY      => NVL(fnd_profile.value('USER_ID'),0),
                         X_LAST_UPDATE_LOGIN    => NVL(fnd_profile.value('USER_ID'),0)
                         );

                    COMMIT;

                  FOR c_det IN c_bkdts (c_hd.bkpt_head_template_id) LOOP

                     l_rowid     := NULL;
                     l_itemId    := NULL;
                     l_itemNum   := NULL;

                     PN_VAR_BKPTS_DET_PKG.INSERT_ROW(
                         l_rowid,
                         l_nullid,
                         l_itemNum,
                         l_bkpt_header_id,
                         l_nulldate,
                         l_nulldate,
                         c_det.period_bkpt_vol_start,
                         c_det.period_bkpt_vol_end,
                         c_det.group_bkpt_vol_start,
                         c_det.group_bkpt_vol_end,
                         c_det.bkpt_rate,
                         l_nullid,
                         X_VAR_RENT_ID,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         c_hd.org_id,
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         NVL(fnd_profile.value('USER_ID'),0),
                         NULL                                   --03-NOV-2003
                         );
                    COMMIT;

                  END LOOP;

               END LOOP;

            ELSIF X_CURRENT_BLOCK = ('LINE_DEFAULTS_BLK') THEN
               FOR c_hd IN c_bkhds LOOP
                  PN_VAR_BKHD_DEFAULTS_PKG.INSERT_ROW (
                         l_rowid,
                         l_bkpt_header_id,
                         l_itemNum,
                         X_LINE_ID,
                         l_nullid,
                         X_AGREEMENT_TEMPLATE_ID,
                         l_nulldate,
                         l_nulldate,
                         c_hd.break_type,
                         c_hd.base_rent_type,
                         c_hd.natural_break_rate,
                         c_hd.base_rent,
                         c_hd.breakpoint_type,
                         l_null,
                         l_null,
                         X_VAR_RENT_ID,
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         NVL(fnd_profile.value('USER_ID'),0),
                         c_hd.org_id,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null
                         );
                    COMMIT;

                  FOR c_det IN c_bkdts(c_hd.bkpt_head_template_id) LOOP

                     l_rowid     := NULL;
                     l_itemId    := NULL;
                     l_itemNum   := NULL;

                     PN_VAR_BKDT_DEFAULTS_PKG.INSERT_ROW(
                         l_rowid,
                         l_itemId,
                         l_itemNum,
                         l_bkpt_header_id,
                         l_nulldate,
                         l_nulldate,
                         c_det.period_bkpt_vol_start,
                         c_det.period_bkpt_vol_end,
                         c_det.group_bkpt_vol_start,
                         c_det.group_bkpt_vol_end,
                         c_det.bkpt_rate,
                         l_null,
                         X_VAR_RENT_ID,
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         sysdate,
                         NVL(fnd_profile.value('USER_ID'),0),
                         NVL(fnd_profile.value('USER_ID'),0),
                         c_hd.org_id,
                         NULL,                                --03-NOV-2003
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null,
                         l_null);
                    COMMIT;

                  END LOOP;

               END LOOP;

            END IF;

            commit;*/
            NULL;

END populate_agreement;

PROCEDURE populate_default_dates (
         X_VAR_RENT_ID     in   NUMBER,
         X_BKHD_DEFAULT_ID in   NUMBER,
         X_LINE_DEFAULT_ID in   NUMBER
        )
    IS

begin

    UPDATE pn_var_bkhd_defaults_all
    SET bkhd_start_date = (select min(bkdt_start_date)
        from pn_var_bkdt_defaults_all
        where var_rent_id = X_VAR_RENT_ID
        and bkhd_default_id = X_BKHD_DEFAULT_ID),
        bkhd_end_date = (select max(bkdt_end_date)
        from pn_var_bkdt_defaults_all
        where var_rent_id = X_VAR_RENT_ID
        and bkhd_default_id = X_BKHD_DEFAULT_ID)
    WHERE var_rent_id  = X_VAR_RENT_ID
    AND bkhd_default_id = X_BKHD_DEFAULT_ID;

    UPDATE pn_var_line_defaults_all
    SET line_start_date = (select min(bkhd_start_date)
        from pn_var_bkhd_defaults_all
        where var_rent_id = X_VAR_RENT_ID
        and line_default_id = X_LINE_DEFAULT_ID),
        line_end_date = (select max(bkhd_end_date)
        from pn_var_bkhd_defaults_all
        where var_rent_id = X_VAR_RENT_ID
        and line_default_id = X_LINE_DEFAULT_ID)
    WHERE var_rent_id  = X_VAR_RENT_ID
    AND line_default_id = X_LINE_DEFAULT_ID;

    commit;

end populate_default_dates;

/*=============================================================================+
| PROCEDURE CREATE_SETUP_DATA
|
|
| DESCRIPTION
|    Creates records in the PN_VAR_LINES_ALL, PN_VAR_BPKT_HEAD_ALL and
|    PN_VAR_BKPT_DET_ALL tables from DEFAULTS tables
|
| SCOPE - PUBLIC
|
| EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
|
| ARGUMENTS  : IN:   X_VAR_RENT_ID
|
|              OUT:
|
| RETURNS    : None
|
|
| MODIFICATION HISTORY
|
|    07-JUL-06    PIkhar     o Created
|    28-FEB-07    PIkhar     o Bug 5904246. Added
|                              pn_var_defaults_pkg.delete_default_lines
|
+=============================================================================*/
PROCEDURE CREATE_SETUP_DATA (X_VAR_RENT_ID IN NUMBER) IS


   l_var_rent_id            NUMBER           := NULL;
   l_rowId                  VARCHAR2(18)     := NULL;
   l_line_item_id           NUMBER           := NULL;
   l_line_item_num          NUMBER           := NULL;
   l_dummy                  VARCHAR2(2)      := NULL;
   l_bkpt_header_id         NUMBER           := NULL;
   l_bkhd_start_date        DATE             := NULL;
   l_bkhd_end_Date          DATE             := NULL;
   l_bkpt_detail_id         NUMBER           := NULL;
   l_bkpt_detail_num        NUMBER           := NULL;
   l_bkdt_start_date        DATE             := NULL;
   l_bkdt_end_date          DATE             := NULL;
   l_flag                   VARCHAR2(1)      := 'N';

   /* Cursor to fetch all the periods */

   CURSOR cur_periods
   IS
      SELECT a.period_id,
             a.start_date,
             a.end_date
      FROM   pn_var_periods_all a
      WHERE  a.var_rent_id = l_var_rent_id
      AND    a.status IS NULL;


   /* Cursor to fetch all line defaults */

   CURSOR cur_line_def (p_start_date DATE
                       ,p_end_date DATE)
   IS
      SELECT *
      FROM   pn_var_line_defaults_all
      WHERE  var_rent_id = l_var_rent_id;


   /* Cursor to fetch all breakpoint header defaults
      overlaping with period */

   CURSOR cur_bkhd_def (p_line_default_id NUMBER
                       ,p_start_date DATE
                       ,p_end_date DATE)
   IS
      SELECT *
      FROM   pn_var_bkhd_defaults_all
      WHERE  line_default_id = p_line_default_id
      AND    bkhd_start_date <= p_end_date
      AND    bkhd_end_date >= p_start_date;


   /* Cursor to fetch all breakpoint detail defaults
      overlaping with period */

   CURSOR cur_bkdt_def (p_head_default_id NUMBER
                       ,p_start_date DATE
                       ,p_end_date DATE)
   IS
      SELECT *
      FROM   pn_var_bkdt_defaults_all
      WHERE  bkhd_default_id = p_head_default_id
      AND    bkdt_start_date <= p_end_date
      AND    bkdt_end_date >= p_start_date;


   /* Cursor to check if a line exist for a given line default */

   CURSOR line_exists_cur (p_line_def_id NUMBER
                          ,p_period_id NUMBER)
   IS
      SELECT line_item_id
      FROM   pn_var_lines_all
      WHERE  line_default_id = p_line_def_id
      AND    period_id = p_period_id;


  /* Cursor to check if a breakpoint header default exists for
     a line default */

   CURSOR find_if_bkhd_exists_cur (p_line_def_id NUMBER)
   IS
      SELECT bkhd_default_id
      FROM pn_var_bkhd_defaults_all
      WHERE line_default_id = p_line_def_id;

   /* Cursor to check if a breakpoint detail default exists for
      a breakpoint Header default */

   CURSOR find_if_bkdt_exists_cur (p_bkhd_def_id NUMBER)
   IS
      SELECT 'x' bkdt_exists
      FROM DUAL
      WHERE EXISTS (SELECT null
                    from pn_var_bkdt_defaults_all
                    where bkhd_default_id = p_bkhd_def_id);

BEGIN

   PNP_DEBUG_PKG.log('PN_VAR_DEFAULTS_PKG.CREATE_SETUP_DATA (+)');
   /* dbms_output.put_line('PN_VAR_DEFAULTS_PKG.CREATE_SETUP_DATA (+)'); */

   l_var_rent_id := x_var_rent_id;

   pn_var_defaults_pkg.delete_default_lines (l_var_rent_id);

   FOR per_rec IN cur_periods
   LOOP

      FOR line_def_rec IN  cur_line_def (p_start_date => per_rec.start_date
                                        ,p_end_date   => per_rec.start_date)
      LOOP

         l_flag := 'N';

         FOR bkhd_exists_rec IN find_if_bkhd_exists_cur (p_line_def_id => line_def_rec.line_default_id)
         LOOP
            FOR bkdt_exists_rec IN find_if_bkdt_exists_cur(p_bkhd_def_id => bkhd_exists_rec.bkhd_default_id)
            LOOP
               l_flag := 'Y';
            END LOOP;
         END LOOP;

         IF l_flag = 'Y' THEN
            l_line_item_id := NULL;
            OPEN  line_exists_cur (p_line_def_id => line_def_rec.line_default_id
                                  ,p_period_id   => per_rec.period_id);
            FETCH line_exists_cur INTO l_line_item_id;
            CLOSE line_exists_cur;

            /*dbms_output.put_line('p_start_date '|| per_rec.start_date);
            dbms_output.put_line('l_line_item_id '||l_line_item_id);*/

            IF l_line_item_id IS NULL THEN

               /* Inserting line defaults data into PN_VAR_LINES_ALL */

               l_rowid          := NULL;
               l_line_item_num  := NULL;

               PN_VAR_LINES_PKG.INSERT_ROW(
                  X_ROWID                 => l_rowid,
                  X_LINE_ITEM_ID          => l_line_item_id,
                  X_LINE_ITEM_NUM         => l_line_item_num,
                  X_PERIOD_ID             => per_rec.period_id,
                  X_SALES_TYPE_CODE       => line_def_rec.sales_type_code,
                  X_ITEM_CATEGORY_CODE    => line_def_rec.item_category_code,
                  X_COMMENTS              => null,
                  X_ATTRIBUTE_CATEGORY    => line_def_rec.attribute_category,
                  X_ATTRIBUTE1            => line_def_rec.attribute1,
                  X_ATTRIBUTE2            => line_def_rec.attribute2,
                  X_ATTRIBUTE3            => line_def_rec.attribute3,
                  X_ATTRIBUTE4            => line_def_rec.attribute4,
                  X_ATTRIBUTE5            => line_def_rec.attribute5,
                  X_ATTRIBUTE6            => line_def_rec.attribute6,
                  X_ATTRIBUTE7            => line_def_rec.attribute7,
                  X_ATTRIBUTE8            => line_def_rec.attribute8,
                  X_ATTRIBUTE9            => line_def_rec.attribute9,
                  X_ATTRIBUTE10           => line_def_rec.attribute10,
                  X_ATTRIBUTE11           => line_def_rec.attribute11,
                  X_ATTRIBUTE12           => line_def_rec.attribute12,
                  X_ATTRIBUTE13           => line_def_rec.attribute13,
                  X_ATTRIBUTE14           => line_def_rec.attribute14,
                  X_ATTRIBUTE15           => line_def_rec.attribute15,
                  X_ORG_ID                => line_def_rec.org_id,
                  X_CREATION_DATE         => sysdate,
                  X_CREATED_BY            => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_DATE      => sysdate,
                  X_LAST_UPDATED_BY       => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_LOGIN     => NVL(fnd_profile.value('USER_ID'),0),
                  X_LINE_TEMPLATE_ID      => line_def_rec.line_template_id,
                  X_AGREEMENT_TEMPLATE_ID => line_def_rec.agreement_template_id,
                  X_LINE_DEFAULT_ID       => line_def_rec.line_default_id,
                  X_VAR_RENT_ID           => l_var_rent_id);


            ELSE

               /* UPDATE PN_VAR_LINES_ALL, using data from PN_VAR_LINE_DEFAULTS_ALL */

               /*dbms_output.put_line('at update');
               dbms_output.put_line('l_line_item_id '||l_line_item_id);*/

               UPDATE PN_VAR_LINES_ALL SET
                  PERIOD_ID             = per_rec.period_id,
                  SALES_TYPE_CODE       = line_def_rec.sales_type_code,
                  ITEM_CATEGORY_CODE    = line_def_rec.item_category_code,
                  ATTRIBUTE_CATEGORY    = line_def_rec.attribute_category,
                  ATTRIBUTE1            = line_def_rec.attribute1,
                  ATTRIBUTE2            = line_def_rec.attribute2,
                  ATTRIBUTE3            = line_def_rec.attribute3,
                  ATTRIBUTE4            = line_def_rec.attribute4,
                  ATTRIBUTE5            = line_def_rec.attribute5,
                  ATTRIBUTE6            = line_def_rec.attribute6,
                  ATTRIBUTE7            = line_def_rec.attribute7,
                  ATTRIBUTE8            = line_def_rec.attribute8,
                  ATTRIBUTE9            = line_def_rec.attribute9,
                  ATTRIBUTE10           = line_def_rec.attribute10,
                  ATTRIBUTE11           = line_def_rec.attribute11,
                  ATTRIBUTE12           = line_def_rec.attribute12,
                  ATTRIBUTE13           = line_def_rec.attribute13,
                  ATTRIBUTE14           = line_def_rec.attribute14,
                  ATTRIBUTE15           = line_def_rec.attribute15,
                  LAST_UPDATE_DATE      = sysdate,
                  LAST_UPDATED_BY       = NVL(fnd_profile.value('USER_ID'),0),
                  LAST_UPDATE_LOGIN     = NVL(fnd_profile.value('USER_ID'),0),
                  LINE_TEMPLATE_ID      = line_def_rec.line_template_id ,
                  AGREEMENT_TEMPLATE_ID = line_def_rec.agreement_template_id,
                  LINE_DEFAULT_ID       = line_def_rec.line_default_id,
                  VAR_RENT_ID           = l_var_rent_id
               WHERE  LINE_ITEM_ID      = l_line_item_id;

            END IF;

            FOR bkhd_def_rec IN cur_bkhd_def (p_line_default_id => line_def_rec.line_default_id
                                             ,p_start_date      => per_rec.start_date
                                             ,p_end_date        => per_rec.end_date)
            LOOP

               l_rowid              := NULL;
               l_bkpt_header_id     := NULL;
               l_bkhd_start_date    := GREATEST(bkhd_def_rec.bkhd_start_date,per_rec.start_date);
               l_bkhd_end_Date      := LEAST(bkhd_def_rec.bkhd_end_date,per_rec.end_date);

               PN_VAR_BKPTS_HEAD_PKG.INSERT_ROW(
                  X_ROWID                     => l_rowid,
                  X_BKPT_HEADER_ID            => l_bkpt_header_id,
                  X_LINE_ITEM_ID              => l_line_item_id,
                  X_PERIOD_ID                 => per_rec.period_id,
                  X_BREAK_TYPE                => bkhd_def_rec.break_type,
                  X_BASE_RENT_TYPE            => bkhd_def_rec.base_rent_type,
                  X_NATURAL_BREAK_RATE        => bkhd_def_rec.natural_break_rate,
                  X_BASE_RENT                 => bkhd_def_rec.base_rent,
                  X_BREAKPOINT_TYPE           => bkhd_def_rec.breakpoint_type,
                  X_BKHD_DEFAULT_ID           => bkhd_def_rec.bkhd_default_id,
                  X_BKHD_START_DATE           => l_bkhd_start_date,
                  X_BKHD_END_DATE             => l_bkhd_end_Date,
                  X_VAR_RENT_ID               => l_var_rent_id,
                  X_ATTRIBUTE_CATEGORY        => bkhd_def_rec.attribute_category,
                  X_ATTRIBUTE1                => bkhd_def_rec.attribute1,
                  X_ATTRIBUTE2                => bkhd_def_rec.attribute2,
                  X_ATTRIBUTE3                => bkhd_def_rec.attribute3,
                  X_ATTRIBUTE4                => bkhd_def_rec.attribute4,
                  X_ATTRIBUTE5                => bkhd_def_rec.attribute5,
                  X_ATTRIBUTE6                => bkhd_def_rec.attribute6,
                  X_ATTRIBUTE7                => bkhd_def_rec.attribute7,
                  X_ATTRIBUTE8                => bkhd_def_rec.attribute8,
                  X_ATTRIBUTE9                => bkhd_def_rec.attribute9,
                  X_ATTRIBUTE10               => bkhd_def_rec.attribute10,
                  X_ATTRIBUTE11               => bkhd_def_rec.attribute11,
                  X_ATTRIBUTE12               => bkhd_def_rec.attribute12,
                  X_ATTRIBUTE13               => bkhd_def_rec.attribute13,
                  X_ATTRIBUTE14               => bkhd_def_rec.attribute14,
                  X_ATTRIBUTE15               => bkhd_def_rec.attribute15,
                  X_ORG_ID                    => bkhd_def_rec.org_id,
                  X_CREATION_DATE             => sysdate,
                  X_CREATED_BY                => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_DATE          => sysdate,
                  X_LAST_UPDATED_BY           => NVL(fnd_profile.value('USER_ID'),0),
                  X_LAST_UPDATE_LOGIN         => NVL(fnd_profile.value('LOGIN_ID'),0),
                  X_BKPT_UPDATE_FLAG          => bkhd_def_rec.bkpt_update_flag);


                  /*dbms_output.put_line('l_bkpt_header_id ' || l_bkpt_header_id);
                  dbms_output.put_line('l_line_item_id '||l_line_item_id); */

               FOR bkdt_def_rec IN cur_bkdt_def (p_head_default_id => bkhd_def_rec.bkhd_default_id
                                                ,p_start_date      => per_rec.start_date
                                                ,p_end_date        => per_rec.end_date)
               LOOP

                  l_rowid                    := NULL;
                  l_bkpt_detail_id           := NULL;
                  l_bkpt_detail_num          := NULL;
                  l_bkdt_start_date          := GREATEST(bkdt_def_rec.bkdt_start_date,per_rec.start_date);
                  l_bkdt_end_date            := LEAST(bkdt_def_rec.bkdt_end_date,per_rec.end_date);

                  PN_VAR_BKPTS_DET_PKG.INSERT_ROW (
                     X_ROWID                 => l_rowid,
                     X_BKPT_DETAIL_ID        => l_bkpt_detail_id,
                     X_BKPT_DETAIL_NUM       => l_bkpt_detail_num,
                     X_BKPT_HEADER_ID        => l_bkpt_header_id,
                     X_BKPT_START_DATE       => l_bkdt_start_date,
                     X_BKPT_END_DATE         => l_bkdt_end_date,
                     X_PERIOD_BKPT_VOL_START => bkdt_def_rec.period_bkpt_vol_start,
                     X_PERIOD_BKPT_VOL_END   => bkdt_def_rec.period_bkpt_vol_end,
                     X_GROUP_BKPT_VOL_START  => bkdt_def_rec.group_bkpt_vol_start,
                     X_GROUP_BKPT_VOL_END    => bkdt_def_rec.group_bkpt_vol_end,
                     X_BKPT_RATE             => bkdt_def_rec.bkpt_rate,
                     X_BKDT_DEFAULT_ID       => bkdt_def_rec.bkdt_default_id,
                     X_VAR_RENT_ID           => l_var_rent_id,
                     X_COMMENTS              => NULL,
                     X_ATTRIBUTE_CATEGORY    => bkdt_def_rec.attribute_category,
                     X_ATTRIBUTE1            => bkdt_def_rec.attribute1,
                     X_ATTRIBUTE2            => bkdt_def_rec.attribute2,
                     X_ATTRIBUTE3            => bkdt_def_rec.attribute3,
                     X_ATTRIBUTE4            => bkdt_def_rec.attribute4,
                     X_ATTRIBUTE5            => bkdt_def_rec.attribute5,
                     X_ATTRIBUTE6            => bkdt_def_rec.attribute6,
                     X_ATTRIBUTE7            => bkdt_def_rec.attribute7,
                     X_ATTRIBUTE8            => bkdt_def_rec.attribute8,
                     X_ATTRIBUTE9            => bkdt_def_rec.attribute9,
                     X_ATTRIBUTE10           => bkdt_def_rec.attribute10,
                     X_ATTRIBUTE11           => bkdt_def_rec.attribute11,
                     X_ATTRIBUTE12           => bkdt_def_rec.attribute12,
                     X_ATTRIBUTE13           => bkdt_def_rec.attribute13,
                     X_ATTRIBUTE14           => bkdt_def_rec.attribute14,
                     X_ATTRIBUTE15           => bkdt_def_rec.attribute15,
                     X_ORG_ID                => bkdt_def_rec.org_id,
                     X_CREATION_DATE         => sysdate,
                     X_CREATED_BY            => NVL(fnd_profile.value('USER_ID'),0),
                     X_LAST_UPDATE_DATE      => sysdate,
                     X_LAST_UPDATED_BY       => NVL(fnd_profile.value('USER_ID'),0),
                     X_LAST_UPDATE_LOGIN     => NVL(fnd_profile.value('USER_ID'),0),
                     X_ANNUAL_BASIS_AMOUNT   => bkdt_def_rec.annual_basis_amount);

                     /* dbms_output.put_line('l_bkpt_detail_id ' || l_bkpt_detail_id);
                     dbms_output.put_line('l_line_item_id '||l_line_item_id); */

                  END LOOP; /* bkdt_def_rec */

               END LOOP; /* bkhd_def_rec */
            END IF;

         END LOOP; /* line_def_rec */

      END LOOP; /* per_rec */

      UPDATE pn_var_bkhd_defaults_all
      SET bkpt_update_flag = 'N'
      WHERE var_rent_id = l_var_rent_id;

      UPDATE pn_var_lines_all
      SET bkpt_update_flag = 'Y'
      WHERE var_rent_id = l_var_rent_id;

   PNP_DEBUG_PKG.log('PN_VAR_DEFAULTS_PKG.CREATE_SETUP_DATA (-)');

END CREATE_SETUP_DATA;


PROCEDURE put_log(p_str VARCHAR2) IS

BEGIN
   pnp_debug_pkg.debug(p_str);
END put_log;

END PN_VAR_DEFAULTS_PKG;


/
