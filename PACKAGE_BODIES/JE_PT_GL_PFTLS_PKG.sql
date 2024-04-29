--------------------------------------------------------
--  DDL for Package Body JE_PT_GL_PFTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_PT_GL_PFTLS_PKG" AS
-- $Header: jeptglpb.pls 120.0.12000000.1 2007/10/24 09:50:11 sgudupat noship $

PROCEDURE parent_child(p_parent         IN     VARCHAR2
                      ,p_summary_flag   IN     VARCHAR2
					  ,x_lev            IN OUT NOCOPY NUMBER ) IS

 /* cursor to find direct children */
  CURSOR children_csr(p_parent_node VARCHAR2) IS
   SELECT  ffvnh.parent_flex_value parent_flex_value
          ,ffv.flex_value flex_value,ffv.summary_flag
     FROM  fnd_flex_value_norm_hierarchy ffvnh
          ,fnd_flex_values ffv
    WHERE ffvnh.flex_value_set_id=gn_flex_value_set_id
      AND ffv.flex_value_set_id=ffvnh.flex_value_set_id
      AND (ffv.flex_value BETWEEN ffvnh.child_flex_value_low
                              AND ffvnh.child_flex_value_high)
      AND ((ffvnh.range_attribute = 'P' AND ffv.summary_flag = 'Y') OR
          (ffvnh.range_attribute = 'C' AND ffv.summary_flag = 'N'))
      AND ffvnh.parent_flex_value = p_parent_node;


BEGIN
    parent_value_rec(gn_iteration) := p_parent;
    gn_iteration:=gn_iteration+1;
     FOR lcr_direct_children_rec IN children_csr(p_parent)
     LOOP
      x_lev:=x_lev+1;
       parent_child(lcr_direct_children_rec.flex_value,lcr_direct_children_rec.summary_flag,x_lev);

     END LOOP;

     FOR i IN parent_value_rec.first..parent_value_rec.last
	 LOOP
      IF (p_summary_flag = 'N' OR x_lev=1)
	  THEN
         INSERT INTO je_parent_child_gt(parent_value,child_value)
		      VALUES (parent_value_rec(i),p_parent);
      END IF;
     END LOOP;

     parent_value_rec.delete(parent_value_rec.last);
     gn_iteration:=gn_iteration-1;

EXCEPTION
   WHEN OTHERS THEN
      gc_debug_var :=gc_debug_var||', EXCEPTION IN FINDING DIRECT CHILDREN IN THE PROCEDURE parent_child
		              FOR THE PARENT'||p_parent;
   RAISE;
END;

   /*Procedure to get the parent and child nodes balances into the global temporary table  */

PROCEDURE update_amount(p_period_set_name  IN  VARCHAR2
		               ,p_period_type      IN  VARCHAR2
		               ,p_bal_seg_filter   IN  VARCHAR2) IS

    lc_stmt        VARCHAR2(2000);
    ln_cur_amt     NUMBER(20);
    ln_pre_amt     NUMBER(20);
    ln_amt         NUMBER(20);
    ln_pamt        NUMBER(20);
BEGIN

 /* Statement to update the Global temporary table amounts with parent and child accouns period to date balances */

    lc_stmt := 'UPDATE je_parent_child_gt jpcg
            SET amount = (SELECT sum(nvl(gb.period_net_dr,0)-nvl(gb.period_net_cr,0))
	                        FROM gl_balances gb
			                    ,gl_code_combinations gcc
		                    WHERE gcc.code_combination_id=gb.code_combination_id
		                     AND  gcc.summary_flag=''N''
							 '||p_bal_seg_filter||'
							 AND  gb.template_id is null
							 AND '||gc_access_where||'
		                     AND  gb.actual_flag=''A''
		                     AND  gb.ledger_id= :p_ledger_id
		                     AND  gb.translated_flag is null
		                     AND  gb.period_name in
		                           (SELECT gp.period_name
				                      FROM gl_periods gp
				                     WHERE gp.period_set_name=:p_period_set_name
				                       AND gp.period_type=:p_period_type
				                       AND gp.start_date between :gd_start_date
							           AND :gd_end_date)
		                     AND jpcg.child_value='||gc_natural_account||'
		                     GROUP BY '||gc_natural_account||')';

	EXECUTE IMMEDIATE lc_stmt USING p_ledger_id,p_period_set_name,p_period_type,gd_start_date,gd_end_date;

	lc_stmt := 'UPDATE je_parent_child_gt jpcg
           SET prior_amount = (SELECT sum(nvl(gb.period_net_dr,0)-nvl(gb.period_net_cr,0))
	                             FROM gl_balances gb
			                         ,gl_code_combinations gcc
		                        WHERE gcc.code_combination_id=gb.code_combination_id
		                         AND  gcc.summary_flag=''N''
								 '||p_bal_seg_filter||'
		                         AND  gb.template_id is null
								 AND '||gc_access_where||'
		                         AND  gb.actual_flag=''A''
		                         AND  gb.ledger_id=:p_ledger_id
		                         AND  gb.translated_flag is null
		                         AND  gb.period_name in
		                                (SELECT gp.period_name
				                           FROM gl_periods gp
				                          WHERE gp.period_set_name=:p_period_set_name
				                            AND gp.period_type=:p_period_type
				                            AND gp.start_date between :gd_prior_start_date
											AND :gd_prior_end_date)
		                         AND jpcg.child_value='||gc_natural_account||'
		                         GROUP BY '||gc_natural_account||')';

	EXECUTE IMMEDIATE lc_stmt USING p_ledger_id,p_period_set_name,p_period_type,gd_prior_start_date,gd_prior_end_date;

    INSERT INTO je_profit_loss_rpt_gt( parent_value
                          		      ,amount
								      ,prior_amount)
			                   SELECT  parent_value
                          	          ,ABS(SUM(amount))
								      ,ABS(SUM(prior_amount))
		                          FROM je_parent_child_gt
							      GROUP BY parent_value
	                              ORDER BY parent_value;

   /* Amount for the item:Increase in stocks of finished goods and in work in progress    */

	SELECT NVL(SUM(jplrg.amount),0)
          ,NVL(SUM(jplrg.prior_amount),0)
      INTO ln_cur_amt
	      ,ln_pre_amt
      FROM je_profit_loss_rpt_gt jplrg
     WHERE jplrg.parent_value IN (SELECT ffv.flex_value
                                    FROM fnd_flex_value_sets ffvs,
								         fnd_flex_values ffv
                                   WHERE ffvs.flex_value_set_name = 'JE_PT_PL_INCSTK_FGWP'
								     AND ffvs.flex_value_set_id=ffv.flex_value_set_id );

  /* Amount for the item:Increase in stocks of finished goods and in work in progress    */
 	BEGIN
	 SELECT NVL(SUM(jpcg.amount),0)
           ,NVL(SUM(jpcg.prior_amount),0)
	   INTO ln_amt
	       ,ln_pamt
       FROM je_parent_child_gt jpcg
      WHERE jpcg.parent_value IN (SELECT ffv.flex_value
                                    FROM fnd_flex_value_sets ffvs,
								         fnd_flex_values ffv
                                   WHERE ffvs.flex_value_set_name = 'JE_PT_PL_INCSTCK_FGWP'
								     AND ffvs.flex_value_set_id=ffv.flex_value_set_id)
	  GROUP BY jpcg.parent_value;
	EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    ln_amt  := NVL(ln_amt,0);
		ln_pamt := NVL(ln_pamt,0);
	  WHEN OTHERS THEN
        gc_debug_var :=gc_debug_var||', EXCEPTION IN GETTING BALANCE AMOUNTS FOR THE ITEM: Increase in stocks of finished goods and in work in progress';
		RAISE;
    END;
	    gn_cur_amt := ln_cur_amt+ln_amt;
		gn_pre_amt := ln_pre_amt+ln_pamt;
   /* Amount for the item:Income Tax   */
    BEGIN
      SELECT (CASE WHEN p_irc_tax IS NULL THEN
	             (CASE WHEN NVL(jplrg.amount,0)<=0 THEN 0 ELSE jplrg.amount END) ELSE p_irc_tax END)
	        ,(CASE WHEN NVL(jplrg.prior_amount,0)<=0 THEN 0 ELSE jplrg.prior_amount END)
        INTO gn_cur_tax_amt
	        ,gn_pre_tax_amt
        FROM je_profit_loss_rpt_gt	jplrg
       WHERE jplrg.parent_value IN (SELECT ffv.flex_value
                                      FROM fnd_flex_value_sets ffvs,
									       fnd_flex_values ffv
                                     WHERE ffvs.flex_value_set_name = 'JE_PT_PL_INCM_TAX'
									   AND ffvs.flex_value_set_id=ffv.flex_value_set_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	    gn_cur_tax_amt := 0;
	    gn_pre_tax_amt := 0;
	  WHEN OTHERS THEN
        gc_debug_var :=gc_debug_var||', EXCEPTION IN GETTING BALANCE AMOUNTS FOR THE ITEM: INCOME TAX';
		RAISE;
    END;

EXCEPTION
   WHEN OTHERS THEN
      gc_debug_var :=gc_debug_var||', EXCEPTION IN GETTING BALANCE AMOUNTS IN THE PROCEDURE update_amount';
      RAISE;
END update_amount;

--public function

FUNCTION beforeReport RETURN BOOLEAN IS
 lc_period_set_name     VARCHAR2(15);
 lc_period_type         VARCHAR2(15);
 ln_lev                 NUMBER :=1;
     /*Cursor to find the parent accounts */
 CURSOR top_parent_csr(p_flex_value_set_id NUMBER) IS
 SELECT ffvnh.parent_flex_value parent_flex_value
   FROM fnd_flex_value_norm_hierarchy ffvnh
  WHERE ffvnh.flex_value_set_id=p_flex_value_set_id
    AND NOT EXISTS
	               (SELECT 1
                      FROM fnd_flex_value_norm_hierarchy f1
                     WHERE f1.flex_value_set_id=p_flex_value_set_id
                       AND ffvnh.parent_flex_value BETWEEN f1.child_flex_value_low
                       AND f1.child_flex_value_high)
 UNION
  SELECT ffv.flex_value parent_flex_value
    FROM fnd_flex_values ffv
   WHERE flex_value_set_id=p_flex_value_set_id
    AND  NOT EXISTS
	                (SELECT 1
	                   FROM fnd_flex_value_norm_hierarchy f1
                      WHERE flex_value_set_id=p_flex_value_set_id
                        AND ffv.flex_value BETWEEN f1.child_flex_value_low
                        AND f1.child_flex_value_high);

BEGIN
   gc_debug_var :=NULL;

   BEGIN
	SELECT  gps.period_set_name
           ,gps.start_date
           ,gpe.end_date
           ,gps.period_year
	       ,gpps.start_date
           ,gppe.end_date
		   ,gpps.period_year
		   ,gps.period_type
      INTO
	        lc_period_set_name
           ,gd_start_date
		   ,gd_end_date
		   ,gn_curr_year
		   ,gd_prior_start_date
		   ,gd_prior_end_date
		   ,gn_prev_year
		   ,lc_period_type
      FROM
            gl_ledgers gll
		   ,gl_periods gps
           ,gl_periods gpe
           ,gl_periods gpps
           ,gl_periods gppe
     WHERE
	        gll.ledger_id=p_ledger_id
        AND gps.period_name=p_start_period
        AND gps.period_set_name=gll.period_set_name
        AND gpe.period_name=p_end_period
        AND gpe.period_set_name=gll.period_set_name
        AND gpps.period_year=gps.period_year-1
        AND gpps.period_type=gps.period_type
        AND gpps.period_set_name=gps.period_set_name
        AND gpps.period_num=gps.period_num
        AND gppe.period_year=gps.period_year-1
        AND gppe.period_type=gpe.period_type
        AND gppe.period_set_name=gpe.period_set_name
        AND gppe.period_num=gpe.period_num;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 gc_debug_var :=gc_debug_var||', NO DATA FOUND EXCEPTION in beforeReport for the given parameters';
	 RAISE;
	WHEN OTHERS THEN
     gc_debug_var :=gc_debug_var||', EXCEPTION IN beforeReport for the given parameters';
	 RAISE;
   END;

     /* Check for parameters */
    IF p_bal_seg_value = 'T'
	THEN
      gc_bal_seg_filter:='AND 1=1';
	ELSE
	  gc_bal_seg_filter:='AND gcc.'||p_balance_segment||'='||''''||p_bal_seg_value||'''';
	END IF;
      gc_natural_account:='gcc.'||p_natural_account;
	  gc_access_where:= GL_ACCESS_SET_SECURITY_PKG.get_security_clause
                      (p_access_set_id,
                      'R',
                      'LEDGER_COLUMN',
                      'LEDGER_ID',
                      'gb',
                      'SEG_COLUMN',
                       NULL,
                      'gcc',
                       NULL);
    IF gc_access_where IS NULL
	THEN
      gc_access_where:= '1 = 1';
    END IF;

     /* get the value set id for account segment */
    SELECT fifs.flex_value_set_id
      INTO gn_flex_value_set_id
      FROM fnd_id_flex_segments fifs
     WHERE fifs.application_column_name=p_natural_account
	   AND fifs.application_id=101
	   AND fifs.id_flex_num=p_coa_id
	   AND fifs.id_flex_code='GL#';

    FOR j IN top_parent_csr(gn_flex_value_set_id)
    LOOP
     parent_child(p_parent       => j.parent_flex_value
	             ,p_summary_flag => 'Y'
				 ,x_lev          => ln_lev);
     ln_lev :=1;
    END LOOP;

   /* update the amounts for each parent */

   update_amount(p_period_set_name  =>lc_period_set_name
				,p_period_type      =>lc_period_type
                ,p_bal_seg_filter   =>gc_bal_seg_filter);

 COMMIT;
     RETURN TRUE;
 EXCEPTION
    WHEN OTHERS THEN
      gc_debug_var :=gc_debug_var||', EXCEPTION IN THE PROCEDURE beforeReport';
      fnd_file.put_line(FND_FILE.LOG,gc_debug_var);
	  RAISE;
END beforeReport;


END JE_PT_GL_PFTLS_PKG;

/
