--------------------------------------------------------
--  DDL for Package Body JE_ES_WHTAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ES_WHTAX" AS
/* $Header: jeeswhtb.pls 120.15.12010000.12 2010/02/18 06:43:50 gkumares ship $ */
PROCEDURE plsqlmsg ( msg IN VARCHAR2) IS
BEGIN
  fnd_file.put_line(fnd_file.output, msg);
END plsqlmsg;
PROCEDURE dbmsmsg( msg IN VARCHAR2) IS
BEGIN
  fnd_file.put_line(fnd_file.log,msg);
END dbmsmsg;
/* Delete EXTERNAL transactions */
PROCEDURE del_trans_x ( --  p_org_name    IN VARCHAR2,-- Bug 5207771 org_id removed
                      p_legal_entity_name IN VARCHAR2,
                      p_fin_ind                  IN VARCHAR2) IS
  bad_parameters EXCEPTION;
  bad_legal_entity EXCEPTION;
  bad_org_name EXCEPTION;
  current_org_id number(15);
  current_legal_entity_id number(15);
BEGIN
  if p_fin_ind = 'S' then
     RAISE bad_parameters;
  end if;
  if p_legal_entity_name is NOT NULL then
        select  legal_entity_id
        into        current_legal_entity_id
        from         XLE_FIRSTPARTY_INFORMATION_V
        where          upper(name) = upper(p_legal_entity_name);
        If (SQL%NOTFOUND) then
                RAISE bad_legal_entity;
        else
                DELETE je_es_modelo_190_all
                        WHERE         legal_entity_id = current_legal_entity_id
                        and         fin_ind = p_fin_ind;
                COMMIT;
        end if;
   end if;
-- bug 5207771: Removed org_id condition
/*
   if p_org_name is NOT NULL then
        select         organization_id
        into        current_org_id
        from         hr_organization_units
        where         UPPER(name) = UPPER(p_org_name);
        If (SQL%NOTFOUND) then
                RAISE bad_org_name;
        else
             DELETE je_es_modelo_190_all
                        WHERE         org_id = current_org_id
                        and         fin_ind = p_fin_ind;
             COMMIT;
        end if;
   end if;
*/
EXCEPTION
  WHEN bad_parameters THEN
       dbmsmsg('Error: Please call this routine with a parameter for FIN_IND <> S');
  WHEN bad_legal_entity THEN
       dbmsmsg('Error: Legal Entity Name ' || p_legal_entity_name || ' is not a valid Legal Entity');
--  WHEN bad_org_name THEN
--       dbmsmsg('Error: Org Name ' || p_org_name || ' is not a valid Organization');
END del_trans_x;
/* Delete Oracle Payables Hard Copy transactions */
PROCEDURE del_trans_s ( p_conc_req_id IN NUMBER,
                        p_legal_entity_id IN NUMBER,
                        p_org_id IN NUMBER ) IS
BEGIN
  DELETE je_es_modelo_190_all
        WHERE fin_ind = 'S'
        and conc_req_id = p_conc_req_id
        and legal_entity_id = p_legal_entity_id;
-- bug 5207771: Removed org_id condition
--      and org_id = p_org_id;
  COMMIT;
END del_trans_s;
/* Delete Oracle Payables Magnetic transactions */
PROCEDURE del_trans_m  ( p_legal_entity_id IN NUMBER,
                        p_org_id IN NUMBER) IS
BEGIN
  DELETE je_es_modelo_190_all
        WHERE fin_ind = 'S'
        and conc_req_id is NULL
        and legal_entity_id = p_legal_entity_id;
        -- bug 5207771: Removed org_id condition
--      and org_id = p_org_id;
  COMMIT;
END del_trans_m;
/* Insert EXTERNAL PAID transactions */
PROCEDURE ins_trans (   p_legal_entity_name        IN VARCHAR2,
--                      p_org_name                IN VARCHAR2, -- Bug 5207771 org_id removed
                        p_fin_ind                IN VARCHAR2,
                        p_remun_type                 IN VARCHAR2,
                        p_vendor_nif                IN VARCHAR2,
                        p_vendor_name                IN VARCHAR2,
                        p_date_paid                        IN VARCHAR2,
                        p_net_amount                        IN NUMBER,
                        p_withholding_tax_amount        IN NUMBER,
                        p_zip_electronic                IN VARCHAR2,
                        p_num_children                        IN NUMBER,
                        p_sign                        IN VARCHAR2,
                        p_tax_rate                IN NUMBER,
                        p_year_due                IN NUMBER,
                        p_sub_remun_type         IN VARCHAR2,
                        p_withholdable_amt_in_kind   IN NUMBER,
                        p_withheld_amt_in_kind               IN NUMBER,
                        p_withheld_pymt_amt_in_kind          IN NUMBER,
                        p_earned_amounts                     IN NUMBER,
                        p_contract_type                      IN NUMBER,
                        p_birth_year                         IN NUMBER,
                        p_disabled              IN NUMBER,
                        p_family_situation      IN NUMBER,
                        p_partner_fiscal_code   IN VARCHAR2,
                        p_descendant_lt_3       IN NUMBER,
                        p_descendant_bt_3_16    IN NUMBER,
                        p_descendant_bt_16_25                IN NUMBER,
                        p_disable_desc_bt_33_65              IN NUMBER,
                        p_disable_desc_gt_65                 IN NUMBER,
                        p_descendant_total                   IN NUMBER,
                        p_deductions                         IN NUMBER,
                        p_expenses                   IN NUMBER,
                        p_spouse_maintenance_amt     IN NUMBER,
                        p_children_maintenance_amt   IN NUMBER
                        ) IS
  bad_num_children EXCEPTION;
  bad_parameters EXCEPTION;
  missing_parameters EXCEPTION;
  bad_legal_name EXCEPTION;
  bad_org_name EXCEPTION;
  current_org_id number(15);
  current_legal_entity_id number(15);
BEGIN
  if p_fin_ind = 'S' then
     RAISE bad_parameters;
  end if;
  if p_num_children is NOT NULL then
     if (p_num_children < 0) or (p_num_children > 99) then
        RAISE bad_num_children;
     end if;
  end if;
  if (p_legal_entity_name is NOT NULL) then
        select legal_entity_id
        into        current_legal_entity_id
        from         XLE_FIRSTPARTY_INFORMATION_V
        where          upper(name) = upper(p_legal_entity_name);
        If (SQL%NOTFOUND) then
                RAISE bad_legal_name;
        end if;
-- bug 5207771: Removed org_id condition
/*
        if (p_org_name is NOT NULL) then
                select         organization_id
                       into        current_org_id
                       from         hr_organization_units
                      where         UPPER(name) = UPPER(p_org_name);
                If (SQL%NOTFOUND) then
                        RAISE bad_org_name;
                end if;
        else
                current_org_id := NULL;
        end if;
*/
     INSERT INTO je_es_modelo_190_all(
                                legal_entity_id,
--                              org_id, -- Bug 5207771 org_id removed
                                fin_ind,
                                remun_type,
                                vendor_nif,
                                vendor_name,
                                date_paid,
                                net_amount,
                                withholding_tax_amount,
                                zip_electronic,
                                num_children,
                                sign,
                                tax_rate,
                                year_due,
                                sub_remun_type ,
                                withholdable_amt_in_kind   ,
                                withholdable_amt_in_kind_sign   ,
                                withheld_amt_in_kind       ,
                                withheld_pymt_amt_in_kind  ,
                                earned_amounts             ,
                                contract_type              ,
                                birth_year                 ,
                                disabled                   ,
                                family_situation           ,
                                partner_fiscal_code        ,
                                descendant_lt_3            ,
                                descendant_bt_3_16         ,
                                descendant_bt_16_25        ,
                                disable_desc_bt_33_65      ,
                                disable_desc_gt_65         ,
                                descendant_total           ,
                                deductions                 ,
                                expenses                   ,
                                spouse_maintenance_amt     ,
                                children_maintenance_amt
                                      )
     values(    current_legal_entity_id,
--              current_org_id, -- Bug 5207771 org_id removed
                p_fin_ind,
                p_remun_type,
                p_vendor_nif,
                substr(p_vendor_name,1,80) ,         -- AP UTF8 Changes 2398166
                p_date_paid,
                p_net_amount,
                p_withholding_tax_amount,
                p_zip_electronic,
                p_num_children,
                p_sign,
                p_tax_rate,
                p_year_due,
                p_sub_remun_type ,
                p_withholdable_amt_in_kind   ,
                decode(p_withholdable_amt_in_kind,NULL,NULL,
                        decode(sign(p_withholdable_amt_in_kind),-1,'N',' ')),
                p_withheld_amt_in_kind       ,
                p_withheld_pymt_amt_in_kind  ,
                p_earned_amounts             ,
                p_contract_type              ,
                p_birth_year                 ,
                p_disabled                   ,
                p_family_situation           ,
                p_partner_fiscal_code        ,
                p_descendant_lt_3            ,
                p_descendant_bt_3_16         ,
                p_descendant_bt_16_25        ,
                p_disable_desc_bt_33_65      ,
                p_disable_desc_gt_65         ,
                p_descendant_total           ,
                p_deductions                 ,
                p_expenses                   ,
                p_spouse_maintenance_amt     ,
                p_children_maintenance_amt
                );
 else
        RAISE missing_parameters;
 end if;
EXCEPTION
  WHEN bad_num_children THEN
     dbmsmsg('Error: Please enter a value between 0 and 99 for P_NUM_CHILDREN');
  WHEN bad_parameters THEN
     dbmsmsg('Error: Please use the correct parameters when inserting FIN_IND = S transactions');
  WHEN bad_legal_name THEN
        dbmsmsg('Error: Legal Entity Name ' || p_legal_entity_name || ' is not a valid Legal Entity');
--  WHEN bad_org_name THEN
--        dbmsmsg('Error: Org Name ' || p_org_name || ' is not a valid Organization');
  WHEN missing_parameters THEN
        dbmsmsg('Error: Legal Entity Name has to be given as a parameter');
END ins_trans;
/* Insert EXTERNAL APPROVED transactions */
PROCEDURE ins_trans (   p_legal_entity_name        IN VARCHAR2,
--                      p_org_name                IN VARCHAR2,-- Bug 5207771 org_id removed
                        p_fin_ind                IN VARCHAR2,
                        p_remun_type                 IN VARCHAR2,
                        p_vendor_nif                IN VARCHAR2,
                        p_vendor_name                IN VARCHAR2,
                        p_gl_date                        IN VARCHAR2,
                        p_net_amount                        IN NUMBER,
                        p_withholding_tax_amount        IN NUMBER,
                        p_zip_electronic                IN VARCHAR2,
                        p_num_children                        IN NUMBER,
                        p_sign                        IN VARCHAR2,
                        p_tax_rate                IN NUMBER,
                        p_year_due                IN NUMBER,
                        p_sub_remun_type         IN VARCHAR2,
                        p_withholdable_amt_in_kind   IN NUMBER,
                        p_withheld_amt_in_kind               IN NUMBER,
                        p_withheld_pymt_amt_in_kind          IN NUMBER,
                        p_earned_amounts                     IN NUMBER,
                        p_contract_type                      IN NUMBER,
                        p_birth_year                         IN NUMBER,
                        p_disabled                   IN NUMBER,
                        p_family_situation      IN NUMBER,
                        p_partner_fiscal_code   IN VARCHAR2,
                        p_descendant_lt_3       IN NUMBER,
                        p_descendant_bt_3_16    IN NUMBER,
                        p_descendant_bt_16_25                IN NUMBER,
                        p_disable_desc_bt_33_65              IN NUMBER,
                        p_disable_desc_gt_65                 IN NUMBER,
                        p_descendant_total                   IN NUMBER,
                        p_deductions                         IN NUMBER,
                        p_expenses                   IN NUMBER,
                        p_spouse_maintenance_amt     IN NUMBER,
                        p_children_maintenance_amt   IN NUMBER
                        ) IS
  bad_num_children EXCEPTION;
  bad_parameters EXCEPTION;
  missing_parameters EXCEPTION;
  bad_legal_name EXCEPTION;
  bad_org_name EXCEPTION;
  current_legal_entity_id number(15);
  current_org_id number(15);
BEGIN
  if p_fin_ind = 'S' then
     RAISE bad_parameters;
  end if;
  if p_num_children is NOT NULL then
     if (p_num_children < 0) or (p_num_children > 99) then
        RAISE bad_num_children;
     end if;
  end if;
  if (p_legal_entity_name is NOT NULL) then
        select legal_entity_id
        into        current_legal_entity_id
        from         XLE_FIRSTPARTY_INFORMATION_V
        where          upper(name) = upper(p_legal_entity_name);
        If (SQL%NOTFOUND) then
                RAISE bad_legal_name;
        end if;
-- bug 5207771: Removed org_id condition
/*
    if (p_org_name is NOT NULL) then
                select         organization_id
                       into        current_org_id
                       from         hr_organization_units
                      where         UPPER(name) = UPPER(p_org_name);
                If (SQL%NOTFOUND) then
                        RAISE bad_org_name;
                end if;
        else
                current_org_id := NULL;
        end if;
*/
        INSERT INTO je_es_modelo_190_all(
                        legal_entity_id,
--                      org_id, -- Bug 5207771 org_id removed
                        fin_ind,
                        remun_type,
                        vendor_nif,
                        vendor_name,
                        gl_date,
                        net_amount,
                        withholding_tax_amount,
                        zip_electronic,
                        num_children,
                        sign,
                        tax_rate,
                        year_due,
                        sub_remun_type ,
                        withholdable_amt_in_kind   ,
                        withholdable_amt_in_kind_sign   ,
                        withheld_amt_in_kind       ,
                        withheld_pymt_amt_in_kind  ,
                        earned_amounts             ,
                        contract_type              ,
                        birth_year                 ,
                        disabled                   ,
                        family_situation           ,
                        partner_fiscal_code        ,
                        descendant_lt_3            ,
                        descendant_bt_3_16         ,
                        descendant_bt_16_25        ,
                        disable_desc_bt_33_65      ,
                        disable_desc_gt_65         ,
                        descendant_total           ,
                        deductions                 ,
                        expenses                   ,
                        spouse_maintenance_amt     ,
                        children_maintenance_amt
                        )
     values(    current_legal_entity_id,
--              current_org_id, -- Bug 5207771 org_id removed
                p_fin_ind,
                p_remun_type,
                p_vendor_nif,
                substr(p_vendor_name,1,80),        -- AP UTF8 Changes 2398166
                p_gl_date,
                p_net_amount,
                p_withholding_tax_amount,
                p_zip_electronic,
                p_num_children,
                p_sign,
                p_tax_rate,
                p_year_due,
                p_sub_remun_type ,
                p_withholdable_amt_in_kind   ,
                decode(p_withholdable_amt_in_kind,NULL,NULL,
                decode(sign(p_withholdable_amt_in_kind),-1,'N',' ')),
                p_withheld_amt_in_kind       ,
                p_withheld_pymt_amt_in_kind  ,
                p_earned_amounts             ,
                p_contract_type              ,
                p_birth_year                 ,
                p_disabled                   ,
                p_family_situation           ,
                p_partner_fiscal_code        ,
                p_descendant_lt_3            ,
                p_descendant_bt_3_16         ,
                p_descendant_bt_16_25        ,
                p_disable_desc_bt_33_65      ,
                p_disable_desc_gt_65         ,
                p_descendant_total           ,
                p_deductions                 ,
                p_expenses                   ,
                p_spouse_maintenance_amt     ,
                p_children_maintenance_amt
                );
  else
        RAISE missing_parameters;
  end if;
EXCEPTION
  WHEN bad_parameters THEN
    dbmsmsg('Error: Please use the correct parameters when inserting FIN_IND = S transactions');
  WHEN bad_num_children THEN
    dbmsmsg('Error: Please enter a value between 0 and 99 for P_NUM_CHILDREN');
  WHEN bad_legal_name THEN
        dbmsmsg('Error: Legal Entity Name ' || p_legal_entity_name || ' is not a valid Legal Entity');
--  WHEN bad_org_name THEN
--        dbmsmsg('Error: Org Name ' || p_org_name || ' is not a valid Organization');
  WHEN missing_parameters THEN
        dbmsmsg('Error: Legal Entity Name has to be given as a parameter');
END ins_trans;
/* Insert Oracle Payables transactions */
PROCEDURE ins_trans (   legal_entity_id                NUMBER,
                        org_id                        NUMBER,
                        conc_req_id                NUMBER,
                        remun_type                 VARCHAR2,
                        sub_remun_type                 VARCHAR2,
                        vendor_nif                 VARCHAR2,
                        vendor_name                 VARCHAR2,
                        invoice_id                        NUMBER,
                        invoice_num                        VARCHAR2,
                        inv_doc_seq_num                        VARCHAR2,
                        invoice_date                        VARCHAR2,
                        gl_date                         VARCHAR2,
                        invoice_payment_id        NUMBER,
                        date_paid                 VARCHAR2,
                        net_amount                 NUMBER,
                        withholding_tax_amount         NUMBER,
                        zip_electronic                 VARCHAR2,
                        zip_legal                        VARCHAR2,
                        city_legal                        VARCHAR2,
                        num_children                         NUMBER,
                        sign                                 VARCHAR2,
                        tax_rate                         NUMBER,
                        tax_name                 VARCHAR2,
                        year_due                 NUMBER
                        ) IS
BEGIN
  INSERT INTO je_es_modelo_190_all( legal_entity_id,
                                org_id,
                                conc_req_id,
                                fin_ind,
                                remun_type,
                                vendor_nif,
                                vendor_name,
                                invoice_id,
                                invoice_num,
                                inv_doc_seq_num,
                                invoice_date,
                                gl_date,
                                invoice_payment_id,
                                date_paid,
                                net_amount,
                                withholding_tax_amount,
                                zip_electronic,
                                zip_legal,
                                city_legal,
                                num_children,
                                sign,
                                tax_rate,
                                tax_name,
                                year_due,
                                sub_remun_type
                                )
  values(       legal_entity_id,
                org_id,
                conc_req_id,
                'S',
                remun_type,
                vendor_nif,
                substr(vendor_name,1,80) ,        -- AP UTF8 Changes 2398166
                invoice_id,
                invoice_num,
                inv_doc_seq_num,
                invoice_date,
                gl_date,
                invoice_payment_id,
                date_paid,
                net_amount,
                withholding_tax_amount,
                zip_electronic,
                zip_legal,
                city_legal,
                num_children,
                sign,
                tax_rate,
                tax_name,
                year_due,
                sub_remun_type
                );
END ins_trans;
-----------------------------------------------------------------------
-- Function get_amount_withheld returns the AWT withheld amount on
-- an invoice.
--
FUNCTION get_amount_withheld(   l_invoice_id IN NUMBER,
                                l_org_id IN NUMBER,
                                l_legal_entity_id IN NUMBER)
  RETURN NUMBER IS
  amount_withheld           NUMBER := 0;
BEGIN
  select (0 - sum(nvl(dist.base_amount,nvl(dist.amount,0))))
    into amount_withheld
    from ap_invoice_distributions_all dist,
         ap_invoice_lines_all line,
         ap_invoices_all inv
   where dist.invoice_id = l_invoice_id
   and   inv.legal_entity_id = nvl(l_legal_entity_id, inv.legal_entity_id)
-- Bug 5207771 : Org_id is removed
--   and   inv.org_id = nvl(l_org_id, inv.org_id)
   and   inv.invoice_id = line.invoice_id
   and   dist.invoice_id = line.invoice_id
--   and   dist.distribution_line_number = line.line_number commented and added below logic for bug 7300332
   and   dist.invoice_line_number = line.line_number
   and   dist.line_type_lookup_code = 'AWT';
  return(amount_withheld);
END get_amount_withheld;
-----------------------------------------------------------------------
-- Function get_prepaid_amount returns the prepayment amount on
-- an invoice.
--
FUNCTION get_prepaid_amount(    l_invoice_id IN NUMBER,
                                l_org_id IN NUMBER,
                                    l_legal_entity_id IN NUMBER)
  RETURN NUMBER IS
  prepaid_amount           NUMBER := 0;
BEGIN
  select (0 - sum(nvl(dist.base_amount,nvl(dist.amount,0))))
    into prepaid_amount
    from ap_invoice_distributions_all dist,
         ap_invoice_lines_all line,
         ap_invoices_all inv
   where dist.invoice_id = l_invoice_id
   and   inv.legal_entity_id = nvl(l_legal_entity_id, inv.legal_entity_id)
-- Bug 5207771 : Org_id is removed
--   and   inv.org_id = nvl(l_org_id, inv.org_id)
   and   inv.invoice_id = line.invoice_id
   and   dist.invoice_id = line.invoice_id
--   and   dist.distribution_line_number = line.line_number Commented and added below logic for Bug 7300332
   and   dist.invoice_line_number = line.line_number
   and   dist.line_type_lookup_code = 'PREPAY';
  return(prepaid_amount);
END get_prepaid_amount;
----------------------------------------------------------------------
-- Function get_awt_net_total returns the total distribution
-- amount for the invoice associated with withholding group.
-- BUG 3930123 : The net amount should be calculated only for the requested accounting period
-- spanugan 17/12/2004
FUNCTION get_awt_net_total(l_invoice_id IN NUMBER,
                           l_legal_entity_id IN NUMBER,
                           l_org_id IN NUMBER,
                           l_accounting_date IN DATE)
  RETURN NUMBER IS
  l_awt_net_total       NUMBER := 0;
BEGIN
  SELECT NVL(SUM(nvl(dist.base_amount,NVL(dist.amount,0))),0)
  INTO  l_awt_net_total
  FROM  ap_invoice_distributions_all dist,
        ap_invoice_lines_all line,
        ap_invoices_all inv
  WHERE dist.invoice_id = l_invoice_id
  and   inv.legal_entity_id = nvl(l_legal_entity_id, inv.legal_entity_id)
-- Bug 5207771 : Org_id is removed
--   and   inv.org_id = nvl(l_org_id, inv.org_id)
  and   inv.invoice_id = line.invoice_id
  and   dist.invoice_id = line.invoice_id
--  and   dist.distribution_line_number = line.line_number Commented and added below for bug 7300332
  and   dist.invoice_line_number = line.line_number
  and   dist.awt_group_id IS NOT NULL
  and   dist.line_type_lookup_code NOT IN ('AWT')
  and   dist.accounting_date = l_accounting_date;        -- Bug 3930123
  RETURN(l_awt_net_total);
END get_awt_net_total;
----------------------------------------------------------------------
-- Function get_payments_count returns the total number of
-- accounted payments for the invoice.
--
FUNCTION get_payments_count(    l_invoice_id IN NUMBER,
                                   l_legal_entity_id IN NUMBER,
                                l_org_id IN NUMBER)
  RETURN NUMBER IS
  l_payments_count      NUMBER := 0;
BEGIN
  SELECT COUNT(aip.invoice_payment_id)
    INTO l_payments_count
    FROM ap_invoice_payments_all aip,
         ap_checks_all ac
   WHERE aip.invoice_id = l_invoice_id
     AND ac.legal_entity_id = nvl(l_legal_entity_id, ac.legal_entity_id)
    -- bug 5207771: Removed org_id condition
    --and       ac.org_id = nvl(l_org_id,ac.org_id)
     AND aip.check_id = ac.check_id
     AND ac.void_date is null;
  RETURN(l_payments_count);
END get_payments_count;
----------------------------------------------------------------------
-- Main Procedure Called by concurrent program.
--
PROCEDURE get_data (    ERRBUF                OUT NOCOPY VARCHAR2,
                        RETCODE                OUT NOCOPY NUMBER,
                        p_pay_inv_sel                IN VARCHAR2,
                        p_summary                IN VARCHAR2,
                        p_date_from                IN VARCHAR2,
                        p_date_to                IN VARCHAR2,
                        p_vendor_id                IN NUMBER ,
                        p_conc_req_id                IN NUMBER ,
                        p_hard_copy                IN VARCHAR2 ,
                        p_wht_tax_type                 IN VARCHAR2,
                        p_legal_entity_id        IN NUMBER,
                        p_org_id                IN NUMBER,
                        p_rep_site_ou           IN NUMBER
                        ) IS
  bad_parameters EXCEPTION;
  bad_awt_lines  EXCEPTION;     -- Bug 1271489
  countrecs      NUMBER;
  first_record   NUMBER := 0;
  conc_req_id1    JE_ES_MODELO_190_ALL.conc_req_id%TYPE;
  fin_ind1        JE_ES_MODELO_190_ALL.fin_ind%TYPE;
  remun_type1     JE_ES_MODELO_190_ALL.remun_type%TYPE;
  sub_remun_type1 JE_ES_MODELO_190_ALL.sub_remun_type%TYPE;
  vendor_nif1     JE_ES_MODELO_190_ALL.vendor_nif%TYPE;
  vendor_name1          JE_ES_MODELO_190_ALL.vendor_name%TYPE;
  invoice_id1           JE_ES_MODELO_190_ALL.invoice_id%TYPE;
  invoice_num1          JE_ES_MODELO_190_ALL.invoice_num%TYPE;
  inv_doc_seq_num1      JE_ES_MODELO_190_ALL.inv_doc_seq_num%TYPE;
  invoice_date1         JE_ES_MODELO_190_ALL.invoice_date%TYPE;
  gl_date1                      JE_ES_MODELO_190_ALL.gl_date%TYPE;
  invoice_payment_id1           JE_ES_MODELO_190_ALL.invoice_payment_id%TYPE;
  awt_invoice_payment_id        JE_ES_MODELO_190_ALL.invoice_payment_id%TYPE;
  date_paid1                    JE_ES_MODELO_190_ALL.date_paid%TYPE;
  invoice_amount                JE_ES_MODELO_190_ALL.net_amount%TYPE;
  inv_payment_status_flag  ap_invoices.payment_status_flag%TYPE;
  wht_mode                 ap_invoices.payment_status_flag%TYPE;
  inv_awt_flag             ap_invoices.awt_flag%TYPE;
  dist_awt_flag            ap_invoice_distributions_all.awt_flag%type; -- bug 8709676
  paid_amount              JE_ES_MODELO_190_ALL.net_amount%TYPE;
  invoice_prepaid_amount   JE_ES_MODELO_190_ALL.net_amount%TYPE;
  invoice_withheld_amount       JE_ES_MODELO_190_ALL.net_amount%TYPE;
  inv_dist_net_amount           JE_ES_MODELO_190_ALL.net_amount%TYPE;
  discount_amount               JE_ES_MODELO_190_ALL.net_amount%TYPE;
  net_amount1                   JE_ES_MODELO_190_ALL.net_amount%TYPE;
  wht_net_amount1               JE_ES_MODELO_190_ALL.net_amount%TYPE;
  inv_net_amount1          JE_ES_MODELO_190_ALL.net_amount%TYPE;
  withholding_tax_amount1  JE_ES_MODELO_190_ALL.withholding_tax_amount%TYPE;
  inv_wht_amount1          JE_ES_MODELO_190_ALL.withholding_tax_amount%TYPE;
  zip_electronic1          JE_ES_MODELO_190_ALL.zip_electronic%TYPE;
  zip_legal1               JE_ES_MODELO_190_ALL.zip_legal%TYPE;
  city_legal1                   JE_ES_MODELO_190_ALL.city_legal%TYPE;
  num_children1                 JE_ES_MODELO_190_ALL.num_children%TYPE;
  sign1                         JE_ES_MODELO_190_ALL.sign%TYPE;
  tax_rate1                     JE_ES_MODELO_190_ALL.tax_rate%TYPE;
  tax_name1                     JE_ES_MODELO_190_ALL.tax_name%TYPE;
  year_due1                JE_ES_MODELO_190_ALL.year_due%TYPE;
  invoice_payments_count   number := 0;
  func_curr             fnd_currencies_vl.currency_code%TYPE;
  func_curr_precision   fnd_currencies_vl.precision%TYPE;
  old_remun_type        JE_ES_MODELO_190_ALL.remun_type%TYPE;
  old_sub_remun_type    JE_ES_MODELO_190_ALL.sub_remun_type%TYPE;
  old_vendor_nif        JE_ES_MODELO_190_ALL.vendor_nif%TYPE;
  old_vendor_name       JE_ES_MODELO_190_ALL.vendor_name%TYPE;
  old_city_legal        JE_ES_MODELO_190_ALL.city_legal%TYPE;
  old_zip_electronic            JE_ES_MODELO_190_ALL.zip_electronic%TYPE;
  old_zip_legal                 JE_ES_MODELO_190_ALL.zip_legal%TYPE;
  old_tax_rate                  JE_ES_MODELO_190_ALL.tax_rate%TYPE;
  old_tax_name                  JE_ES_MODELO_190_ALL.tax_name%TYPE;
           l_le_id_count         NUMBER;
           l_le_id_message       VARCHAR2(500);
	   l_ledger_id number;
--
-- Summary APPROVED transactions Magnetic Report
-- Tax Code and Tax Rate are not used in Magnetic Format(Bug 998053).
--
CURSOR sum_approve_mag IS
SELECT  decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,        -- AP UTF8 Changes 2398166
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        sum(decode(dist.awt_group_id,NULL,0,
                decode(dist.line_type_lookup_code,'AWT',0,
                nvl(dist.base_amount,dist.amount)))) net_amount,
        sum(decode(dist.line_type_lookup_code,'AWT',
                nvl(dist.base_amount,dist.amount),0)) withholding_tax_amount
FROM    po_vendors v,
        po_vendor_sites_all vs,
	fnd_lookups fl,
	ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
       (SELECT distinct person_id
       ,national_identifier
       FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE    v.vendor_id = vs.vendor_id
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
AND      vs.country = fl.lookup_code(+)
AND     fl.lookup_type = 'JEES_EURO_COUNTRY_CODES'
AND    (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND     inv.vendor_id = v.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-----and     inv.cancelled_date is null      -- Bug 2228008        )
AND     dist.parent_reversal_id is null
-- bug 	8496890
/*AND     not exists ( select 1
                       from ap_invoice_distributions dist1, gl_period_statuses gl
		      where gl.application_id = 101
		        and dist1.invoice_id = inv.invoice_id
			and dist1.parent_reversal_id = dist.invoice_distribution_id
			and gl.ledger_id = dist1.set_of_books_id
			and dist.accounting_date between gl.start_date and gl.end_date
			   and dist1.accounting_date <= gl.end_date  )
*/
AND     not exists ( select 1
                     from ap_invoice_distributions dist1
                     where dist1.invoice_id = inv.invoice_id
                     and dist1.parent_reversal_id = dist.invoice_distribution_id
                     and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                    	and fnd_date.canonical_to_date(P_Date_To)
		            )
-- bug 	8496890
AND     trunc(dist.accounting_date,'DD')
                between fnd_date.canonical_to_date(P_Date_From)
                AND fnd_date.canonical_to_date(P_Date_To)
AND     ((dist.line_type_lookup_code = 'AWT')
         OR
         (dist.awt_group_id is not NULL))
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                dist.ACCRUAL_POSTED_FLAG,
                dist.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
                -- bug 5207771 Added legal_entity id as 4th parameter, above line
AND    dist.withholding_tax_code_id = atc.tax_id (+)        -- bug 5102299
AND    atc.name     = awt.tax_name(+)
AND    awt.vendor_id is null /* Ignore any Vendor Lines */
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
          OR (dist.awt_tax_rate_id is NULL) )
-- Ignore any invoices which do not have 'AWT' distribution lines
AND    EXISTS ( select dist2.invoice_id
                from   ap_invoice_distributions_all dist2
                where  inv.invoice_id = dist2.invoice_id
                and    dist2.line_type_lookup_code = 'AWT'
                and    dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id from ap_tax_codes_all
                        where vat_transaction_type = p_wht_tax_type))
GROUP BY        decode(nvl(v.employee_id,-1),-1,'G','A'),
                decode(nvl(v.employee_id,-1),-1,'01','00'),
                nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
                substr(v.vendor_name,1,80) ,
                decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3))
HAVING  sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0
-- BUG 3930123 : Adding one more select clause with certain modifications, to fetch
--               the invoices that are cancelled in different accounting period.
-- spanugan 17/12/2004
UNION
SELECT  decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,        -- AP UTF8 Changes 2398166
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        sum(decode(dist.awt_group_id,NULL,0,
                decode(dist.line_type_lookup_code,'AWT',0,
                nvl(dist.base_amount,dist.amount)))) net_amount,
        sum(decode(dist.line_type_lookup_code,'AWT',
                nvl(dist.base_amount,dist.amount),0)) withholding_tax_amount
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
        (SELECT distinct person_id
         ,national_identifier
         FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE    v.vendor_id = vs.vendor_id
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
AND      vs.country = fl.lookup_code(+)
AND     fl.lookup_type = 'JEES_EURO_COUNTRY_CODES'
AND    (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND     inv.vendor_id = v.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-- BUG 3930123 : spanugan
/*AND     inv.cancelled_date is not null
AND     (
        (dist.cancellation_flag is null
AND     dist.accounting_date < (select distinct gl.start_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag = 'Y' )))
        OR
        (dist.cancellation_flag = 'Y'
AND     dist.accounting_date > (select distinct gl.end_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag is null )))
        )
-- END
--  Bug 3930123 JCHALL . Changed the subquery above from
--  a single row returned to accept mutiple rows.
--
*/
AND     dist.parent_reversal_id is not null
-- bug 	8496890
/*
AND     dist.accounting_date > (select distinct gl.end_date
                                  from ap_invoice_distributions dist1, gl_period_statuses gl
				 where gl.application_id = 101
				   and dist1.invoice_id = inv.invoice_id
				   and dist.parent_reversal_id = dist1.invoice_distribution_id
				   and gl.ledger_id = dist1.set_of_books_id
				   and dist1.accounting_date between gl.start_date and gl.end_date)
  */
 AND      not exists (select 1 from ap_invoice_distributions dist1
				where dist1.invoice_id = inv.invoice_id
				and dist.parent_reversal_id = dist1.invoice_distribution_id
				and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                and fnd_date.canonical_to_date(P_Date_To))
 -- bug 	8496890
AND     trunc(dist.accounting_date,'DD')
        between fnd_date.canonical_to_date(P_Date_From)
        AND fnd_date.canonical_to_date(P_Date_To)
AND     ((dist.line_type_lookup_code = 'AWT')
         OR
         (dist.awt_group_id is not NULL))
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                dist.ACCRUAL_POSTED_FLAG,
                dist.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
         -- bug 5207771 Added legal_entity id as 4th parameter, above line
AND    dist.withholding_tax_code_id = atc.tax_id(+)
AND    atc.name     = awt.tax_name(+)
AND    awt.vendor_id is null /* Ignore any Vendor Lines */
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
          OR (dist.awt_tax_rate_id is NULL) )
-- Ignore any invoices which do not have 'AWT' distribution lines
AND    EXISTS ( select dist2.invoice_id
                from   ap_invoice_distributions_all dist2
                where  inv.invoice_id = dist2.invoice_id
                and    dist2.line_type_lookup_code = 'AWT'
                and    dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id from ap_tax_codes_all
                        where vat_transaction_type = p_wht_tax_type))
GROUP BY        decode(nvl(v.employee_id,-1),-1,'G','A'),
                decode(nvl(v.employee_id,-1),-1,'01','00'),
                nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
                substr(v.vendor_name,1,80) ,
                decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3))
HAVING  sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0;
--
-- Detailed PAID transactions cursor.
-- This is used for Detail, Summary, Summary Magnetic format Transactions
-- extract purpose. It handles automatic witholding, manual witholding
--
CURSOR detail_paid IS
SELECT  'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,        -- AP UTF8 Changes 2398166
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total(inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total(inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'|| substr(fl.description,1,3)),
        vs.city,
        0,
        sum(nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
        (SELECT distinct person_id
         ,national_identifier
         FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
---AND     v.vendor_id = nvl(p_vendor_id,v.vendor_id)
AND (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     vs.vendor_site_id = inv.vendor_site_id
AND     nvl(inv.awt_flag,'N') = 'Y'
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
---and     inv.cancelled_date is null      -- Bug 2228008
AND     dist.parent_reversal_id is null
-- bug 	8496890
/*
AND     not exists ( select 1
                       from ap_invoice_distributions dist1, gl_period_statuses gl
		      where gl.application_id = 101
		        and dist1.invoice_id = inv.invoice_id
			and dist1.parent_reversal_id = dist.invoice_distribution_id
			and gl.ledger_id = dist1.set_of_books_id
			and dist.accounting_date between gl.start_date and gl.end_date
			and dist1.accounting_date <= gl.end_date  )
*/
AND     not exists ( select 1
                     from ap_invoice_distributions dist1
                     where dist1.invoice_id = inv.invoice_id
                     and dist1.parent_reversal_id = dist.invoice_distribution_id
                     and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                    	and fnd_date.canonical_to_date(P_Date_To)
		            )
-- bug 	8496890

AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null /* Ignore any Vendor Lines */
AND     invpay.accounting_date
        between nvl(awt.start_date,invpay.accounting_date)
        and nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
-- Ignore any invoices which do not have 'AWT' distribution lines
AND     EXISTS (select dist2.invoice_id
                from   ap_invoice_distributions_all dist2
                where  inv.invoice_id = dist2.invoice_id
                and    dist2.line_type_lookup_code = 'AWT'
                and    dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     NOT EXISTS ( select dist2.invoice_id
                       from ap_invoice_distributions_all dist2
                      where inv.invoice_id = dist2.invoice_id
                        and dist2.line_type_lookup_code = 'AWT'
                        and dist2.awt_flag <> 'A')
GROUP BY 'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) ,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0),
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0),
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0),
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) ,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
        substr(fl.description,1,3)),
        vs.city,
        0,
        dist.awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
HAVING  ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0))
-- Bug 1212074
-- BUG 3930123 : Adding one more select clause with certain modifications, to fetch
--               the invoices that are cancelled in different accounting period.
-- spanugan 17/12/2004
UNION
SELECT  'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,        -- AP UTF8 Changes 2398166
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        0,
        sum(nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
        (SELECT distinct person_id
         ,national_identifier
         FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
---AND     v.vendor_id = nvl(p_vendor_id,v.vendor_id)
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     vs.vendor_site_id = inv.vendor_site_id
AND     nvl(inv.awt_flag,'N') = 'Y'
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-- BUG 3930123 : spanugan
/*AND     inv.cancelled_date is not null
AND     (
        (dist.cancellation_flag is null
AND     dist.accounting_date < (select distinct gl.start_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag = 'Y' )))
        OR
        (dist.cancellation_flag = 'Y'
AND     dist.accounting_date > (select distinct gl.end_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag is null )))
        )
-- END
*/
AND     dist.parent_reversal_id is not null
-- bug 	8496890
/*
AND     dist.accounting_date > (select distinct gl.end_date
                                  from ap_invoice_distributions dist1, gl_period_statuses gl
				 where gl.application_id = 101
				   and dist1.invoice_id = inv.invoice_id
				   and dist.parent_reversal_id = dist1.invoice_distribution_id
				   and gl.ledger_id = dist1.set_of_books_id
				   and dist1.accounting_date between gl.start_date and gl.end_date)
*/
AND      not exists (select 1 from ap_invoice_distributions dist1
				where dist1.invoice_id = inv.invoice_id
				and dist.parent_reversal_id = dist1.invoice_distribution_id
				and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                and fnd_date.canonical_to_date(P_Date_To))
-- bug 	8496890
AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null /* Ignore any Vendor Lines */
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND     invpay.accounting_date
        between nvl(awt.start_date,invpay.accounting_date)
        and nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
-- Ignore any invoices which do not have 'AWT' distribution lines
AND     EXISTS (select dist2.invoice_id
                from   ap_invoice_distributions_all dist2
                where  inv.invoice_id = dist2.invoice_id
                and    dist2.line_type_lookup_code = 'AWT'
                and    dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     NOT EXISTS ( select dist2.invoice_id
                       from ap_invoice_distributions_all dist2
                      where inv.invoice_id = dist2.invoice_id
                        and dist2.line_type_lookup_code = 'AWT'
                        and dist2.awt_flag <> 'A')
GROUP BY 'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80) ,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) ,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0),
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0),
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0),
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) ,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
        substr(fl.description,1,3)),
        vs.city,
        0,
        dist.awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
HAVING  ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0))
-- Bug 1212074
UNION
SELECT  'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' || to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'|| substr(fl.description,1,3)),
        vs.city,
        (nvl(dist.awt_gross_amount,0)) wht_net_amount,
        (nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, -- bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
AND     nvl(inv.awt_flag,'N') = 'N'
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
---and     inv.cancelled_date is null      -- Bug 2228008
AND     dist.parent_reversal_id is null
-- bug 	8496890
/*
AND     not exists ( select 1
                       from ap_invoice_distributions dist1, gl_period_statuses gl
		      where gl.application_id = 101
		        and dist1.invoice_id = inv.invoice_id
			and dist1.parent_reversal_id = dist.invoice_distribution_id
			and gl.ledger_id = dist1.set_of_books_id
			and dist.accounting_date between gl.start_date and gl.end_date
			and dist1.accounting_date <= gl.end_date  )
*/
AND     not exists ( select 1
                     from ap_invoice_distributions dist1
                     where dist1.invoice_id = inv.invoice_id
                     and dist1.parent_reversal_id = dist.invoice_distribution_id
                     and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                    	and fnd_date.canonical_to_date(P_Date_To)
		            )
-- bug 	8496890
AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     dist.awt_invoice_payment_id = invpay.invoice_payment_id
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null
AND     invpay.accounting_date between nvl(awt.start_date, invpay.accounting_date)
AND     nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND     EXISTS (select  dist2.invoice_id
                from         ap_invoice_distributions_all dist2
                where         inv.invoice_id = dist2.invoice_id
                and        dist2.line_type_lookup_code = 'AWT'
                and         dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     NOT EXISTS ( select dist2.invoice_id
                       from ap_invoice_distributions_all dist2
                      where inv.invoice_id = dist2.invoice_id
                        and dist2.line_type_lookup_code = 'AWT'
                        and dist2.awt_flag <> 'A')
-- BUG 3930123 : Adding one more select clause with certain modifications, to fetch
--               the invoices that are cancelled in different accounting period.
-- spanugan 17/12/2004
UNION
SELECT  'A',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total(inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total(inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        dist.awt_invoice_payment_id,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        (nvl(dist.awt_gross_amount,0)) wht_net_amount,
        (nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, -- bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
AND     nvl(inv.awt_flag,'N') = 'N'
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-- BUG 3930123 : spanugan
/*AND     inv.cancelled_date is not null
AND
        (
        (dist.cancellation_flag is null
AND     dist.accounting_date < (select distinct gl.start_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag = 'Y' )))
        OR
        (dist.cancellation_flag = 'Y'
AND     dist.accounting_date > (select distinct gl.end_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag is null )))
        )
-- END
*/
AND     dist.parent_reversal_id is not null
-- bug 	8496890
/*
AND     dist.accounting_date > (select distinct gl.end_date
               		          from ap_invoice_distributions dist1, gl_period_statuses gl
                                 where gl.application_id = 101
				   and dist1.invoice_id = inv.invoice_id
				   and dist.parent_reversal_id = dist1.invoice_distribution_id
				   and gl.ledger_id = dist1.set_of_books_id
				   and dist1.accounting_date between gl.start_date and gl.end_date)
*/
AND      not exists (select 1 from ap_invoice_distributions dist1
				where dist1.invoice_id = inv.invoice_id
				and dist.parent_reversal_id = dist1.invoice_distribution_id
				and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                and fnd_date.canonical_to_date(P_Date_To))
-- bug 	8496890
AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     dist.awt_invoice_payment_id = invpay.invoice_payment_id
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND     invpay.accounting_date between nvl(awt.start_date, invpay.accounting_date)
AND     nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
AND     EXISTS (select  dist2.invoice_id
                from         ap_invoice_distributions_all dist2
                where         inv.invoice_id = dist2.invoice_id
                and        dist2.line_type_lookup_code = 'AWT'
                and         dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     NOT EXISTS ( select dist2.invoice_id
                       from ap_invoice_distributions_all dist2
                      where inv.invoice_id = dist2.invoice_id
                        and dist2.line_type_lookup_code = 'AWT'
                        and dist2.awt_flag <> 'A')
UNION
SELECT  'M',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        0,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        0,
        sum(nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
---and     inv.cancelled_date is null      -- Bug 2228008
AND     dist.parent_reversal_id is null
-- bug 	8496890
/*
AND     not exists ( select 1
                       from ap_invoice_distributions dist1, gl_period_statuses gl
		      where gl.application_id = 101
		        and dist1.invoice_id = inv.invoice_id
			and dist1.parent_reversal_id = dist.invoice_distribution_id
			and gl.ledger_id = dist1.set_of_books_id
			and dist.accounting_date between gl.start_date and gl.end_date
			and dist1.accounting_date <= gl.end_date  )
*/
AND     not exists ( select 1
                     from ap_invoice_distributions dist1
                     where dist1.invoice_id = inv.invoice_id
                     and dist1.parent_reversal_id = dist.invoice_distribution_id
                     and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                    	and fnd_date.canonical_to_date(P_Date_To)
		            )
-- bug 	8496890
AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND     invpay.accounting_date between nvl(awt.start_date, invpay.accounting_date)
AND     nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
AND     EXISTS (select         dist2.invoice_id
                from         ap_invoice_distributions_all dist2
                where         inv.invoice_id = dist2.invoice_id
                and        dist2.line_type_lookup_code = 'AWT'
                and         dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     EXISTS ( select dist2.invoice_id
                   from ap_invoice_distributions_all dist2
                  where inv.invoice_id = dist2.invoice_id
                    and dist2.line_type_lookup_code = 'AWT'
                    and dist2.awt_flag <> 'A')
GROUP BY 'M',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount),
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) ,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) ,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0),
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        0,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        0,
        dist.awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
HAVING ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0))
-- Bug 1212074
-- BUG 3930123 : Adding one more select clause with certain modifications, to fetch
--               the invoices that are cancelled in different accounting period.
-- spanugan 17/12/2004
UNION
SELECT  'M',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount) invoice_amount,
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) prepaid_amount,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) invoice_withheld_amount,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0) payments_count,
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        0,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        0,
        sum(nvl(dist.base_amount,dist.amount)),
        dist.awt_flag dist_awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_invoice_payments_all invpay,
        ap_checks_all checks,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-- BUG 3930123 : spanugan
/*AND     inv.cancelled_date is not null
AND
        (
        (dist.cancellation_flag is null
AND     dist.accounting_date < (select distinct gl.start_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag = 'Y' )))
        OR
        (dist.cancellation_flag = 'Y'
AND     dist.accounting_date > (select distinct gl.end_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag is null )))
        )
-- END
*/
AND     dist.parent_reversal_id is not null
-- bug 	8496890
/*
AND     dist.accounting_date > (select distinct gl.end_date
               		          from ap_invoice_distributions dist1, gl_period_statuses gl
                                 where gl.application_id = 101
				   and dist1.invoice_id = inv.invoice_id
				   and dist.parent_reversal_id = dist1.invoice_distribution_id
				   and gl.ledger_id = dist1.set_of_books_id
				   and dist1.accounting_date between gl.start_date and gl.end_date)
*/
AND      not exists (select 1 from ap_invoice_distributions dist1
				where dist1.invoice_id = inv.invoice_id
				and dist.parent_reversal_id = dist1.invoice_distribution_id
				and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                and fnd_date.canonical_to_date(P_Date_To))
-- bug 	8496890
AND     inv.invoice_id = invpay.invoice_id
AND     ( invpay.posted_flag in ('Y','P')
        or invpay.cash_posted_flag in ('Y','P')
        or invpay.accrual_posted_flag in ('Y','P'))
AND     invpay.check_id = checks.check_id
AND     checks.void_date is null
AND     trunc(invpay.accounting_date,'DD')
        between
        nvl(fnd_date.canonical_to_date(P_Date_From),invpay.accounting_date)
        and nvl(fnd_date.canonical_to_date(P_Date_To),invpay.accounting_date)
AND     (dist.line_type_lookup_code = 'AWT')
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND     dist.withholding_tax_code_id = atc.tax_id(+)
AND     atc.name     = awt.tax_name(+)
AND     awt.vendor_id is null
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND     invpay.accounting_date between nvl(awt.start_date, invpay.accounting_date)
AND     nvl(awt.end_date, invpay.accounting_date)
AND     inv.doc_sequence_id = seq.doc_sequence_id(+)
AND     EXISTS (select         dist2.invoice_id
                from         ap_invoice_distributions_all dist2
                where         inv.invoice_id = dist2.invoice_id
                and        dist2.line_type_lookup_code = 'AWT'
                and         dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id
                           from ap_tax_codes_all
                          where vat_transaction_type = p_wht_tax_type))
AND     EXISTS ( select dist2.invoice_id
                   from ap_invoice_distributions_all dist2
                  where inv.invoice_id = dist2.invoice_id
                    and dist2.line_type_lookup_code = 'AWT'
                    and dist2.awt_flag <> 'A')
GROUP BY 'M',
        decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        v.vendor_name,
        inv.awt_flag,
        inv.payment_status_flag,
        inv.invoice_id,
        inv.invoice_num,
        nvl(inv.base_amount,inv.invoice_amount),
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0),
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0),
        nvl(je_es_whtax.GET_PREPAID_AMOUNT( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        nvl(je_es_whtax.GET_AMOUNT_WITHHELD( inv.INVOICE_ID,inv.org_id,inv.legal_entity_id),0) ,
        decode(seq.name || '-' ||
                to_char(inv.doc_sequence_value),'-',null,seq.name || '-' ||
                to_char(inv.doc_sequence_value)),
        trunc(inv.invoice_date,'DD'),
        invpay.invoice_payment_id,
        nvl(je_es_whtax.get_payments_count(inv.INVOICE_ID,inv.legal_entity_id,inv.org_id),0),
        nvl(invpay.payment_base_amount,invpay.amount),
        nvl(invpay.discount_taken,0),
        trunc(invpay.accounting_date,'DD'),
        0,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||
                substr(fl.description,1,3)),
        vs.city,
        0,
        dist.awt_flag, --bug 8709676
        awt.tax_rate,
        awt.tax_name
HAVING ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0));
-- Bug 1212074
--
-- Detailed APPROVED transactions. This is used for Detail and Summary
-- transactions extract Hard Copy Report.
--
CURSOR detail_approve IS
SELECT  decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80),        -- AP UTF8 Changes 2398166
        nvl(inv.base_amount,inv.invoice_amount),
        decode(seq.name || '-' || to_char(inv.doc_sequence_value),'-',null,
                seq.name || '-' || to_char(inv.doc_sequence_value)),
        inv.invoice_id,
        inv.invoice_num,
        trunc(inv.invoice_date,'DD'),
        trunc(dist.accounting_date,'DD'),
        dist.awt_flag, -- bug 8709676
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        sum(nvl(dist.base_amount,dist.amount)) withholding_tax_amount,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        vs.city,
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
---and     inv.cancelled_date is null      -- Bug 2228008
AND     dist.parent_reversal_id is null
-- bug 	8496890
/*
AND     not exists ( select 1
                       from ap_invoice_distributions dist1, gl_period_statuses gl
		      where gl.application_id = 101
		        and dist1.invoice_id = inv.invoice_id
			and dist1.parent_reversal_id = dist.invoice_distribution_id
			and gl.ledger_id = dist1.set_of_books_id
			and dist.accounting_date between gl.start_date and gl.end_date
			and dist1.accounting_date <= gl.end_date  )
*/
AND     not exists ( select 1
                     from ap_invoice_distributions dist1
                     where dist1.invoice_id = inv.invoice_id
                     and dist1.parent_reversal_id = dist.invoice_distribution_id
                     and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                    	and fnd_date.canonical_to_date(P_Date_To)
		            )
-- bug 	8496890
AND     trunc(dist.accounting_date,'DD')
        between fnd_date.canonical_to_date(P_Date_From)
        and fnd_date.canonical_to_date(P_Date_To)
AND     dist.line_type_lookup_code = 'AWT'
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND    dist.withholding_tax_code_id = atc.tax_id(+)
AND    atc.name     = awt.tax_name(+)
AND    dist.accounting_date
        between nvl(awt.start_date, dist.accounting_date)
        and     nvl(awt.end_date, dist.accounting_date)
AND    awt.vendor_id is null /* Ignore any Vendor Lines */
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND    inv.doc_sequence_id = seq.doc_sequence_id(+)
-- Ignore any invoices which do not have 'AWT' distribution lines
AND     EXISTS ( select dist2.invoice_id
                   from ap_invoice_distributions_all dist2
                  where inv.invoice_id = dist2.invoice_id
                    and        dist2.line_type_lookup_code = 'AWT'
                    and dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id from ap_tax_codes_all
                        where vat_transaction_type = p_wht_tax_type))
GROUP BY decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80),
        nvl(inv.base_amount,inv.invoice_amount),
        decode(seq.name || '-' || to_char(inv.doc_sequence_value),'-', null,
                seq.name || '-' || to_char(inv.doc_sequence_value)),
        inv.invoice_id,
        inv.invoice_num,
        trunc(inv.invoice_date,'DD'),
        trunc(dist.accounting_date,'DD'),
        dist.awt_flag, -- bug 8709676
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) ,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) ,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        vs.city,
        awt.tax_rate,
        awt.tax_name
HAVING ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0))
-- Bug 1212074
-- BUG 3930123 : Adding one more select clause with certain modifications, to fetch
--               the invoices that are cancelled in different accounting period.
-- spanugan 17/12/2004
UNION
SELECT  decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80),        -- AP UTF8 Changes 2398166
        nvl(inv.base_amount,inv.invoice_amount),
        decode(seq.name || '-' || to_char(inv.doc_sequence_value),'-',null,
                seq.name || '-' || to_char(inv.doc_sequence_value)),
        inv.invoice_id,
        inv.invoice_num,
        trunc(inv.invoice_date,'DD'),
        trunc(dist.accounting_date,'DD'),
        dist.awt_flag, -- bug 8709676
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) net_amount,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) net_amount,
        sum(nvl(dist.base_amount,dist.amount)) withholding_tax_amount,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        vs.city,
        awt.tax_rate,
        awt.tax_name
FROM    fnd_lookups fl,
        po_vendors v,
        po_vendor_sites_all vs,
        ap_tax_codes_all atc,
        ap_awt_tax_rates_all awt,
        fnd_document_sequences seq,
        ap_invoices_all inv,
        ap_invoice_lines_all line,
        ap_invoice_distributions_all dist,
       (SELECT distinct person_id
        ,national_identifier
        FROM PER_ALL_PEOPLE_F WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
WHERE   vs.country = fl.lookup_code(+)
AND     'JEES_EURO_COUNTRY_CODES' = fl.lookup_type
AND     (( p_vendor_id is null and v.vendor_id = v.vendor_id) or (v.vendor_id = p_vendor_id))
AND      nvl(v.employee_id,-99)  = papf.person_id (+)
AND     inv.vendor_id = v.vendor_id
AND     v.vendor_id = vs.vendor_id
and     vs.vendor_site_id = inv.vendor_site_id
-- bug 8551359 - start
--AND      vs.tax_reporting_site_flag = 'Y'
AND    exists (select 'x'
            from po_vendor_sites_all
            where vendor_id = v.vendor_id
            and tax_reporting_site_flag = 'Y'
            and org_id = p_rep_site_ou)
-- bug 8551359 - end
and     inv.legal_entity_id = nvl(p_legal_entity_id,inv.legal_entity_id)
-- bug 5207771: Removed org_id condition
--and   inv.org_id = nvl(p_org_id,inv.org_id)
and     inv.invoice_id = line.invoice_id
and     dist.invoice_id = line.invoice_id
and     dist.invoice_line_number = line.line_number
-- BUG 3930123 : spanugan
/*AND     inv.cancelled_date is not null
AND
        (
        (dist.cancellation_flag is null
AND     dist.accounting_date < (select distinct gl.start_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag = 'Y' )))
        OR
        (dist.cancellation_flag = 'Y'
AND     dist.accounting_date > (select distinct gl.end_date
        from gl_period_statuses gl
        where gl.period_name IN (select distinct to_char(dist1.accounting_date,'MM-YY')
        from ap_invoice_distributions_all dist1
        where dist1.invoice_id = inv.invoice_id
        and dist1.cancellation_flag is null )))
        )
-- END
*/
AND     dist.parent_reversal_id is not null
-- bug 	8496890
/*
AND     dist.accounting_date > (select distinct gl.end_date
               		          from ap_invoice_distributions dist1, gl_period_statuses gl
                                 where gl.application_id = 101
				   and dist1.invoice_id = inv.invoice_id
				   and dist.parent_reversal_id = dist1.invoice_distribution_id
				   and gl.ledger_id = dist1.set_of_books_id
				   and dist1.accounting_date between gl.start_date and gl.end_date)
*/
AND      not exists (select 1 from ap_invoice_distributions dist1
				where dist1.invoice_id = inv.invoice_id
				and dist.parent_reversal_id = dist1.invoice_distribution_id
				and dist1.accounting_date between fnd_date.canonical_to_date(P_Date_From)
                and fnd_date.canonical_to_date(P_Date_To))
-- bug 	8496890
AND     trunc(dist.accounting_date,'DD')
        between fnd_date.canonical_to_date(P_Date_From)
        and fnd_date.canonical_to_date(P_Date_To)
AND     dist.line_type_lookup_code = 'AWT'
AND     AP_INVOICE_DISTRIBUTIONS_PKG.GET_POSTED_STATUS(
                DIST.ACCRUAL_POSTED_FLAG,
                DIST.CASH_POSTED_FLAG,
                dist.POSTED_FLAG, inv.org_id) in ('Y','P')
AND    dist.withholding_tax_code_id = atc.tax_id(+)
AND    atc.name     = awt.tax_name(+)
AND    dist.accounting_date
        between nvl(awt.start_date, dist.accounting_date)
        and     nvl(awt.end_date, dist.accounting_date)
AND    awt.vendor_id is null /* Ignore any Vendor Lines */
-- Bug 5207771 : Added to remove the duplicates WH lines
AND( (dist.awt_tax_rate_id = awt.tax_rate_id)
        OR (dist.awt_tax_rate_id is NULL) )
AND    inv.doc_sequence_id = seq.doc_sequence_id(+)
-- Ignore any invoices which do not have 'AWT' distribution lines
AND     EXISTS ( select dist2.invoice_id
                   from ap_invoice_distributions_all dist2
                  where inv.invoice_id = dist2.invoice_id
                    and        dist2.line_type_lookup_code = 'AWT'
                    and dist2.withholding_tax_code_id in
                        -- Bug 2019586: Column name should be tax_id.
                        -- (select tax_code_id from ap_tax_codes
                        (select tax_id from ap_tax_codes_all
                        where vat_transaction_type = p_wht_tax_type))
GROUP BY decode(nvl(v.employee_id,-1),-1,'G','A'),
        decode(nvl(v.employee_id,-1),-1,'01','00'),
        nvl(substr(nvl(papf.national_identifier,nvl(v.individual_1099,v.num_1099)),1,9),' '),
        substr(v.vendor_name,1,80),
        nvl(inv.base_amount,inv.invoice_amount),
        decode(seq.name || '-' || to_char(inv.doc_sequence_value),'-', null,
        seq.name || '-' || to_char(inv.doc_sequence_value)),
        inv.invoice_id,
        inv.invoice_num,
        trunc(inv.invoice_date,'DD'),
        trunc(dist.accounting_date,'DD'),
        dist.awt_flag, -- bug 8709676
--      nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID),0) ,
        nvl(je_es_whtax.get_awt_net_total( inv.INVOICE_ID,inv.legal_entity_id,inv.org_id,dist.accounting_date),0) ,
        decode(vs.country,'ES',substr(vs.zip,1,2)||'000','98'||substr(fl.description,1,3)),
        vs.city,
        awt.tax_rate,
        awt.tax_name
HAVING ((sum(decode(dist.line_type_lookup_code,'AWT',nvl(dist.base_amount,dist.amount),0)) <> 0) or (min(awt.tax_rate) = 0));

-- Bug 1212074
-- Bug 1271489: Fetch correct awt rate and name for a given invoice.
PROCEDURE fetch_awt_line(   p_fetch_pi_flag     IN varchar2,
                            p_fetch_invoice_id  IN number,
                            p_fetch_wht_amount  IN number,
                            date_paid1          IN  DATE,   -- Bug 3930123 : Spanugan 23/12/2004
                            p_fetch_tax_rate    IN OUT NOCOPY number,
                            p_fetch_tax_name    IN OUT NOCOPY varchar2,
                            p_legal_entity_id   IN number,
                            p_org_id                IN number) is
  l_tax_code_id       ap_tax_codes.tax_id%TYPE;
  l_invoice_num       ap_invoices.invoice_num%TYPE;
  l_tax_name          JE_ES_MODELO_190_ALL.tax_name%TYPE;
  l_tax_rate          JE_ES_MODELO_190_ALL.tax_rate%TYPE;
  l_accounting_date   ap_invoice_distributions_all.accounting_date%TYPE;
begin
  begin
    if p_fetch_pi_flag = 'P' then
       select    min(dist.withholding_tax_code_id), max(invpay.accounting_date)
       into      l_tax_code_id, l_accounting_date
       from      ap_invoice_payments_all invpay,
                 ap_invoice_distributions_all dist
       where     dist.invoice_id = p_fetch_invoice_id
       and       invpay.invoice_id = dist.invoice_id
       and       dist.line_type_lookup_code = 'AWT'
       -- Bug 5207771
--       and       dist.accounting_date = date_paid1         -- Bug 3930217 : Spanugan 23/12/2004
       group by  withholding_tax_code_id
       having    /*((mod(count(dist.withholding_tax_code_id),2) = 1) and*/ --Bug 3930217
              (sum(decode(dist.line_type_lookup_code,'AWT',
              nvl(dist.base_amount,dist.amount),0)) = p_fetch_wht_amount);
    else  -- p_fetch_pi_flag <> 'P
       select    min(withholding_tax_code_id), max(accounting_date)
       into      l_tax_code_id,    l_accounting_date
       from      ap_invoice_distributions_all
       where     invoice_id = p_fetch_invoice_id
       and       line_type_lookup_code = 'AWT'
       -- Bug 5207771
--       and       accounting_date = date_paid1               -- Bug 3930217 : Spanugan 23/12/2004
       group by  withholding_tax_code_id
       having    /*((mod(count(withholding_tax_code_id),2) = 1) and*/ --Bug 3930217
                 (sum(decode(line_type_lookup_code,'AWT',
                 nvl(base_amount,amount),0)) = p_fetch_wht_amount)
                 ;
    end if;
  exception
    when OTHERS then
         select        invoice_num into l_invoice_num
         from         ap_invoices_all
         where  invoice_id = p_fetch_invoice_id
         and    legal_entity_id = nvl(p_legal_entity_id, legal_entity_id);
        -- bug 5207771: Removed org_id condition
    --and       inv.org_id = nvl(p_org_id,inv.org_id);
         dbmsmsg('Wrong number of withholding tax lines in invoice '||l_invoice_num||'.');
         raise bad_awt_lines;
  end;
  begin


    select  awt.tax_rate, awt.tax_name
    into    l_tax_rate,   l_tax_name
    from    ap_tax_codes_all atc, ap_awt_tax_rates_all awt
    where   atc.name     = awt.tax_name(+)
    and     atc.tax_id  = l_tax_code_id
    and     l_accounting_date between nvl(awt.start_date,l_accounting_date)
            and nvl(awt.end_date,l_accounting_date)
    and     atc.org_id = awt.org_id;  -- bug 8401560

  exception
    when OTHERS then
         select invoice_num into l_invoice_num
         from         ap_invoices_all
         where         invoice_id = p_fetch_invoice_id
         and         legal_entity_id = nvl(p_legal_entity_id,legal_entity_id);
        -- bug 5207771: Removed org_id condition
    --and       inv.org_id = nvl(p_org_id,inv.org_id);
         dbmsmsg('The tax name for withholding tax line of invoice '||l_invoice_num|| ' is an incorrect one.');
         raise bad_awt_lines;
  end;
  p_fetch_tax_rate := nvl(l_tax_rate,p_fetch_tax_rate);
  p_fetch_tax_name := nvl(l_tax_name,p_fetch_tax_name);
end;
BEGIN
  fnd_file.put_line( fnd_file.log,'Parameters :');
  fnd_file.put_line( fnd_file.log,'Selection Criteria : ' || p_pay_inv_sel );
  fnd_file.put_line( fnd_file.log,'Summary Report     : ' || p_summary );
  fnd_file.put_line( fnd_file.log,'Date From          : ' || p_date_from );
  fnd_file.put_line( fnd_file.log,'Date To            : ' || p_date_to );
  fnd_file.put_line( fnd_file.log,'Tax Type           : ' || p_wht_tax_type );
  fnd_file.put_line( fnd_file.log,'Legal Entity id    : ' || p_legal_entity_id );
  fnd_file.put_line( fnd_file.log,'Organization id    : ' || p_org_id );
  fnd_file.put_line( fnd_file.log,' ');
   -- Added for bug 5277700.
   SELECT COUNT(*)
   INTO   l_le_id_count
   FROM   je_es_modelo_190_all
   WHERE  legal_entity_id IS NULL;
   IF l_le_id_count > 0 THEN
je_es_mod_le_update.update_main;
/* fnd_message.set_name('JE', 'JE_WHT_LEGAL_ENTITY_ID_UPG');
       fnd_message.set_token('TABLE', 'JE_ES_MODELO_190_ALL');
       l_le_id_message := fnd_message.get;
       errbuf := l_le_id_message;
       retcode := -1;
       RETURN;
*/
END IF;
  /* Get the functional currency and precision */
--  l_ledger_id :=FND_PROFILE.value('gl_set_of_bks_id');

   SELECT p.currency_code,
          c.precision
   INTO  func_curr,
         func_curr_precision
   FROM  gl_ledgers p,
         fnd_currencies_vl c
   WHERE  p.currency_code  = c.currency_code
   AND    p.ledger_id = (select distinct primary_ledger_id
                         from gl_ledger_le_v
                         where legal_entity_id = p_legal_entity_id);

   if p_hard_copy = 'N' then
     /* Deal with ELECTRONIC transactions */
     plsqlmsg('WITHHOLDING TAX MAGNETIC REPORT - Transfer Data');
     del_trans_m(p_legal_entity_id => p_legal_entity_id,
                p_org_id => p_org_id);
     plsqlmsg('Deleted Existing Rows');
     if p_summary = 'Y' then
        /* Deal with SUMMARY transactions */
        if p_pay_inv_sel = 'P' then
           /* Deal with PAID transactions */
           countrecs := 0;
           plsqlmsg('Opened CURSOR detail_paid for summary paid electronic');
           OPEN detail_paid;
           LOOP
           FETCH         detail_paid
           INTO         wht_mode,
                        remun_type1,
                        sub_remun_type1,
                        vendor_nif1,
                        vendor_name1,
                        inv_awt_flag,
                        inv_payment_status_flag,
                        invoice_id1,
                        invoice_num1,
                        invoice_amount,
                        net_amount1,
                        invoice_prepaid_amount,
                        invoice_withheld_amount,
                        inv_doc_seq_num1,
                        invoice_date1,
                        invoice_payment_id1,
                        invoice_payments_count,
                        paid_amount,
                        discount_amount,
                        date_paid1,
                        awt_invoice_payment_id,
                        zip_legal1,
                        city_legal1,
                        wht_net_amount1,
                        withholding_tax_amount1,
                        dist_awt_flag, --bug 8709676
                        tax_rate1,
                        tax_name1;
           EXIT WHEN detail_paid%NOTFOUND;
           first_record := first_record + 1;
           -- fnd_file.put_line(fnd_file.log,'In Magnetic');
           -- Retain Old data
           if ( first_record = 1 ) then
                old_remun_type := remun_type1;
                old_sub_remun_type := sub_remun_type1;
                     old_vendor_nif := vendor_nif1;
                old_vendor_name := vendor_name1;
                old_zip_electronic := zip_electronic1;
                old_zip_legal := zip_legal1 ;
           end if;
           -- Automatic Withholding
           -- Withholding calculated at invoice payment time.
           if ( wht_mode = 'A' ) then
              if(nvl(inv_awt_flag,'N') = 'N') then
                  net_amount1 := round(wht_net_amount1,func_curr_precision);
                  withholding_tax_amount1 := round(withholding_tax_amount1,
                                                        func_curr_precision);
              else  -- if (nvl(inv_awt_flag,'N') = 'Y')
                     if (nvl(inv_payment_status_flag,'N') = 'Y') then
                     if (invoice_payments_count = 1 ) then
                         net_amount1 := round(net_amount1,func_curr_precision);
                         withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                     elsif ( invoice_payments_count > 1 ) then
                         net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                         withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1), func_curr_precision);
                     end if;
                  else        -- if nvl(inv_payment_status_flag,'N') = 'N'
                     net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                      withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1), func_curr_precision);
                  end if;
              end if;
             end if;
           -- Manuali+Automatic Withholding
           -- Withholding calculated at invoice payment time.
           -- Withholding calculated at approval time.
           if ( wht_mode = 'M' ) then
              if (nvl(inv_payment_status_flag,'N') = 'Y') then
                 if (invoice_payments_count = 1 ) then
                       net_amount1 := round(net_amount1,func_curr_precision);
                       withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                 elsif ( invoice_payments_count > 1 ) then
                       net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                       withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                 end if;  -- if invoice_payments_count =1 or >1
              else  -- if nvl(inv_payment_status_flag,'N') = 'N'
                 net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                 withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
              end if;  -- if nvl(inv_payment_status_flag,'N') = 'Y' or 'N'
           end if;  -- if wht_mode = 'M'
           if ( (nvl(remun_type1,'X') = nvl(old_remun_type,'X')) AND
                (nvl(sub_remun_type1,'X') = nvl(old_sub_remun_type,'X')) AND
                (nvl(vendor_nif1,'X') = nvl(old_vendor_nif,'X')) AND
                (nvl(vendor_name1,'X') = nvl(old_vendor_name,'X')) AND
                (nvl(zip_electronic1,'X') = nvl(old_zip_electronic,'X')) AND
                (nvl(zip_legal1,'X') = nvl(old_zip_legal,'X')) ) then
                inv_net_amount1 := nvl(inv_net_amount1,0) + net_amount1;
                inv_wht_amount1 := nvl(inv_wht_amount1,0) +  withholding_tax_amount1;
           else
                old_remun_type := remun_type1;
                old_sub_remun_type := sub_remun_type1;
                old_vendor_nif := vendor_nif1;
                old_vendor_name := vendor_name1;
                old_zip_electronic := zip_electronic1;
                old_zip_legal := zip_legal1 ;
              if sign(inv_net_amount1) = -1 then
                 sign1 := 'N';
              else
                 sign1:= '';
              end if;
              inv_wht_amount1 := abs(inv_wht_amount1);
              inv_net_amount1 := abs(inv_net_amount1);
              if ( inv_wht_amount1 <>0 ) then
                 -- Bug 1212074: Magnetic form does not care about 0 awt.
                 countrecs := countrecs + 1;
                 ins_trans(
                        legal_entity_id => p_legal_entity_id,
                        org_id => p_org_id,
                        conc_req_id => p_conc_req_id,
                        remun_type => remun_type1,
                        sub_remun_type => sub_remun_type1,
                        vendor_nif => vendor_nif1,
                        vendor_name => vendor_name1,
                        invoice_id => NULL,
                        invoice_num => NULL,
                        inv_doc_seq_num => NULL,
                        invoice_date => NULL,
                        gl_date => NULL,
                        invoice_payment_id => NULL,
                        date_paid => NULL,
                        net_amount => inv_net_amount1,
                        withholding_tax_amount => inv_wht_amount1,
                        zip_electronic => zip_electronic1,
                        zip_legal => zip_legal1,
                        city_legal => NULL,
                        num_children => NULL,
                        sign => sign1,
                        tax_rate => NULL,
                        tax_name => NULL,
                        year_due => NULL);
             end if;
             inv_net_amount1 := net_amount1;
             inv_wht_amount1 := withholding_tax_amount1;
          end if;
          END LOOP;
          if ( inv_wht_amount1 <>0 AND inv_net_amount1 <> 0 ) then
             -- Bug 1212074: Magnetic form does not care about 0 awt.
             countrecs := countrecs + 1;
             ins_trans(        legal_entity_id => p_legal_entity_id,
                        org_id => p_org_id,
                        conc_req_id => p_conc_req_id,
                        remun_type => remun_type1,
                        sub_remun_type => sub_remun_type1,
                        vendor_nif => vendor_nif1,
                        vendor_name => vendor_name1,
                        invoice_id => NULL,
                        invoice_num => NULL,
                        inv_doc_seq_num => NULL,
                        invoice_date => NULL,
                        gl_date => NULL,
                        invoice_payment_id => NULL,
                        date_paid => NULL,
                        net_amount => inv_net_amount1,
                        withholding_tax_amount => inv_wht_amount1,
                        zip_electronic => zip_electronic1,
                        zip_legal => zip_legal1,
                        city_legal => NULL,
                        num_children => NULL,
                        sign => sign1,
                        tax_rate => NULL,
                        tax_name => NULL,
                        year_due => NULL);
           end if;
           plsqlmsg('Data inserted into table JE_ES_MODELO_190_ALL');
           CLOSE detail_paid;
           plsqlmsg('CURSOR Closed');
           plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
         ELSE  -- p_pay_inv_sel <> 'P'
            /* Deal with APPROVED transactions */
            countrecs := 0;
            OPEN sum_approve_mag;
            plsqlmsg('Opened CURSOR sum_approve_mag');
            LOOP
            FETCH         sum_approve_mag
            INTO         remun_type1,
                        sub_remun_type1,
                        vendor_nif1,
                        vendor_name1,
                        zip_electronic1,
                        net_amount1,
                        withholding_tax_amount1;
            EXIT WHEN sum_approve_mag%NOTFOUND;
            net_amount1 := round(net_amount1,func_curr_precision);
            withholding_tax_amount1 := round(withholding_tax_amount1,func_curr_precision);
            if sign(net_amount1) = -1 then
                sign1 := 'N';
            else
                sign1:= '';
            end if;
            withholding_tax_amount1 := abs(withholding_tax_amount1);
            net_amount1 := abs(net_amount1);
            if ( withholding_tax_amount1 <>0 ) then
                -- Bug 1212074: Magnetic form does not care about 0 awt.
                countrecs := countrecs + 1;
                ins_trans(        legal_entity_id => p_legal_entity_id,
                                org_id => p_org_id,
                                conc_req_id => NULL,
                                remun_type => remun_type1,
                                sub_remun_type => sub_remun_type1,
                                vendor_nif => vendor_nif1,
                                vendor_name => vendor_name1,
                                invoice_id => invoice_id1,
                                invoice_num => invoice_num1,
                                inv_doc_seq_num => inv_doc_seq_num1,
                                invoice_date => invoice_date1,
                                gl_date => gl_date1,
                                invoice_payment_id => invoice_payment_id1,
                                date_paid => date_paid1,
                                net_amount => net_amount1,
                                withholding_tax_amount => withholding_tax_amount1,
                                zip_electronic => zip_electronic1,
                                zip_legal => zip_legal1,
                                city_legal => city_legal1,
                                num_children => num_children1,
                                sign => sign1,
                                tax_rate => tax_rate1,
                                tax_name => tax_name1,
                                year_due => year_due1);
            end if;
            END LOOP;
            plsqlmsg('Data inserted into table JE_ES_MODELO_190_ALL');
            CLOSE sum_approve_mag;
            plsqlmsg('CURSOR Closed');
            plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
         end if;  -- p_pay_inv_sel = 'P' or <> 'P'
     else  -- p_summary <> 'Y'
       /* We should NEVER have any DETAIL transactions */
       RAISE bad_parameters;
     end if;  -- if p_summary = 'Y' or <> 'Y'
  else  -- p_hard_copy = 'Y'
     /* Deal with HARD COPY transactions */
     plsqlmsg('WITHHOLDING TAX REPORT - Transfer Data for Hard Copy Summary');
     del_trans_s(p_conc_req_id => p_conc_req_id,
                p_legal_entity_id => p_legal_entity_id,
                p_org_id => p_org_id);
     plsqlmsg('Deleted Existing Rows');
     if p_summary = 'Y' then
        /* Deal with SUMMARY transactions */
        if p_pay_inv_sel = 'P' then
           /* Deal with PAID transactions */
           countrecs := 0;
           OPEN detail_paid;
           plsqlmsg('Opened CURSOR detail_paid');
           LOOP
           FETCH         detail_paid
           INTO wht_mode,
                remun_type1,
                sub_remun_type1,
                vendor_nif1,
                vendor_name1,
                inv_awt_flag,
                inv_payment_status_flag,
                invoice_id1,
                invoice_num1,
                invoice_amount,
                net_amount1,
                invoice_prepaid_amount,
                invoice_withheld_amount,
                inv_doc_seq_num1,
                invoice_date1,
                invoice_payment_id1,
                invoice_payments_count,
                paid_amount,
                discount_amount,
                date_paid1,
                awt_invoice_payment_id,
                zip_legal1,
                city_legal1,
                wht_net_amount1,
                withholding_tax_amount1,
                dist_awt_flag, --bug 8709676
                tax_rate1,
                tax_name1;
           EXIT WHEN detail_paid%NOTFOUND;
           -- Automatic Withholding
           -- Withholding calculated at invoice payment time.
           if ( wht_mode = 'A' ) then
              if (nvl(inv_awt_flag,'N') = 'N') then
                 net_amount1 := round(wht_net_amount1,func_curr_precision);
                 withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
              else  -- if (nvl(inv_awt_flag,'N') = 'Y')
                 if (nvl(inv_payment_status_flag,'N') = 'Y') then
                          if (invoice_payments_count = 1 ) then
                       net_amount1 := round(net_amount1,func_curr_precision);
                       withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                    elsif ( invoice_payments_count > 1 ) then
                       net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                       withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                    end if;  -- if invoice_payments_count = 1 or > 1
                else  -- if nvl(inv_payment_status_flag,'N') = 'N'
                    net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                    withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                end if;  -- if nvl(inv_payment_status_flag,'N') = 'Y' or 'N'
              end if;  -- if (nvl(inv_awt_flag,'N') = 'N' or 'Y'
           end if; -- if wht_mode = 'A'
           -- Manuali+Automatic Withholding
           -- Withholding calculated at invoice payment time.
           -- Withholding calculated at approval time.
           if ( wht_mode = 'M' ) then
              if (nvl(inv_payment_status_flag,'N') = 'Y') then
                 if (invoice_payments_count = 1 ) then
                    net_amount1 := round(net_amount1,func_curr_precision);
                    withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                 elsif ( invoice_payments_count > 1 ) then
                    net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                    withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                 end if;  -- if invoice_payments_count = 1 or > 1
              else  -- if nvl(inv_payment_status_flag,'N') <> 'Y'
                 net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                 withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
              end if;  -- if nvl(inv_payment_status_flag,'N') ='Y' or <> 'Y'
            end if;  -- if wht_mode = 'M'
            -- fnd_file.put_line(fnd_file.log,'Net Amount: '||to_char(net_amount1));
            -- fnd_file.put_line(fnd_file.log,'WHT Amount: '||to_char(withholding_tax_amount1));
            if ( withholding_tax_amount1 <>0 )
                or (tax_rate1 = 0) then            -- Bug 1212074
                countrecs := countrecs + 1;
                ins_trans(      legal_entity_id => p_legal_entity_id,
                                org_id => p_org_id,
                                conc_req_id => p_conc_req_id,
                                remun_type => remun_type1,
                                sub_remun_type => sub_remun_type1,
                                vendor_nif => vendor_nif1,
                                vendor_name => vendor_name1,
                                invoice_id => invoice_id1,
                                invoice_num => invoice_num1,
                                inv_doc_seq_num => inv_doc_seq_num1,
                                invoice_date => invoice_date1,
                                gl_date => gl_date1,
                                invoice_payment_id => invoice_payment_id1,
                                date_paid => date_paid1,
                                net_amount => net_amount1,
                                withholding_tax_amount => withholding_tax_amount1,
                                zip_electronic => zip_electronic1,
                                zip_legal => zip_legal1,
                                city_legal => city_legal1,
                                num_children => num_children1,
                                sign => sign1,
                                tax_rate => tax_rate1,
                                tax_name => tax_name1,
                                year_due => year_due1);
           end if;
           END LOOP;
           plsqlmsg('Data inserted into table JE_ES_MODELO_190_ALL');
           CLOSE detail_paid;
           plsqlmsg('CURSOR Closed');
           plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
        else  -- p_pay_inv_sel <> 'P'
           /* Deal with APPROVED transactions */
           countrecs := 0;
           OPEN detail_approve;
           plsqlmsg('Opened CURSOR detail_approve');
           LOOP
           FETCH         detail_approve
           INTO         remun_type1,
                        sub_remun_type1,
                        vendor_nif1,
                        vendor_name1,
                        invoice_amount,
                        inv_doc_seq_num1,
                        invoice_id1,
                        invoice_num1,
                        invoice_date1,
                        gl_date1,
                        dist_awt_flag, -- bug 8709676
                        net_amount1,
                        withholding_tax_amount1,
                        zip_legal1,
                        city_legal1,
                        tax_rate1,
                        tax_name1;
           EXIT WHEN detail_approve%NOTFOUND;
           net_amount1 := round(net_amount1,func_curr_precision);
           withholding_tax_amount1 := round(withholding_tax_amount1,func_curr_precision);
           if ( withholding_tax_amount1 <>0 )
                or (tax_rate1 = 0) then                 -- Bug 1212074
                countrecs := countrecs + 1;
                ins_trans(        legal_entity_id => p_legal_entity_id,
                                org_id => p_org_id,
                                conc_req_id => p_conc_req_id,
                                remun_type => remun_type1,
                                sub_remun_type => sub_remun_type1,
                                vendor_nif => vendor_nif1,
                                vendor_name => vendor_name1,
                                invoice_id => invoice_id1,
                                invoice_num => invoice_num1,
                                inv_doc_seq_num => inv_doc_seq_num1,
                                invoice_date => invoice_date1,
                                gl_date => gl_date1,
                                invoice_payment_id => NULL,
                                date_paid => NULL,
                                net_amount => net_amount1,
                                withholding_tax_amount => withholding_tax_amount1,
                                zip_electronic => NULL,
                                zip_legal => zip_legal1,
                                city_legal => city_legal1,
                                num_children => NULL,
                                sign => NULL,
                                tax_rate => tax_rate1,
                                tax_name => tax_name1,
                                year_due => NULL);
            end if;
            END LOOP;
            plsqlmsg('Data inserted into table JE_ES_MODELO_190_ALL');
            CLOSE detail_approve;
            plsqlmsg('CURSOR Closed');
            plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
        end if;  -- p_pay_inv_sel = 'P' or <> 'P'
     else  --  p_summary <> 'Y'
        /* Deal with DETAIL transactions */
        if p_pay_inv_sel = 'P' then
           /* Deal with PAID transactions */
           countrecs := 0;
           OPEN detail_paid;
           plsqlmsg('Opened CURSOR detail_paid for Hard Copy');
           LOOP
           FETCH         detail_paid
           INTO         wht_mode,
                        remun_type1,
                        sub_remun_type1,
                        vendor_nif1,
                        vendor_name1,
                        inv_awt_flag,
                        inv_payment_status_flag,
                        invoice_id1,
                        invoice_num1,
                        invoice_amount,
                        net_amount1,
                        invoice_prepaid_amount,
                        invoice_withheld_amount,
                        inv_doc_seq_num1,
                        invoice_date1,
                        invoice_payment_id1,
                        invoice_payments_count,
                        paid_amount,
                        discount_amount,
                        date_paid1,
                        awt_invoice_payment_id,
                        zip_legal1,
                        city_legal1,
                        wht_net_amount1,
                        withholding_tax_amount1,
                        dist_awt_flag, --bug 8709676
                        tax_rate1,
                        tax_name1;
            EXIT WHEN detail_paid%NOTFOUND;

           -- Bug 1271489: Get the correct tax name and tax rate.
          if dist_awt_flag <> 'M' then  --bug 8709676
           fetch_awt_line(      p_pay_inv_sel,
                                invoice_id1,
                                withholding_tax_amount1,
                                date_paid1,                -- Bug 3930123 : Spanugan 23/12/2004
                                tax_rate1,
                                tax_name1,
                                p_legal_entity_id,
                                p_org_id);
          end if;
            -- fnd_file.put_line(fnd_file.log,'Before No data');
            -- Automatic Withholding
            -- Withholding calculated at invoice payment time.
            if ( wht_mode = 'A' ) then
               if (nvl(inv_awt_flag,'N') = 'N') then
                  net_amount1 := round(wht_net_amount1,func_curr_precision);
                  withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
               elsif (nvl(inv_awt_flag,'N') = 'Y') then
                  if (nvl(inv_payment_status_flag,'N') = 'Y') then
                     if (invoice_payments_count = 1 ) then
                        net_amount1 := round(net_amount1,func_curr_precision);
                        withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                     elsif ( invoice_payments_count > 1 ) then
                        net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                        withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                     end if;  -- if invoice_payments_count = 1 or > 1
                  else  -- if nvl(inv_payment_status_flag,'N') = 'N'
                     net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                     withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                  end if;  -- if nvl(inv_payment_status_flag,'N') = 'N' or 'Y'
               end if; -- if nvl(inv_awt_flag,'N') = 'N' or 'Y'
             end if;  -- if wht_mode = 'A'
             -- Manuali+Automatic Withholding
             -- Withholding calculated at invoice payment time.
             -- Withholding calculated at approval time.
             if ( wht_mode = 'M' ) then
                if (nvl(inv_payment_status_flag,'N') = 'Y') then
                   if (invoice_payments_count = 1 ) then
                      net_amount1 := round(net_amount1,func_curr_precision);
                      withholding_tax_amount1 := round(withholding_tax_amount1, func_curr_precision);
                   elsif ( invoice_payments_count > 1 ) then
                      net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                      withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                   end if;  -- if invoice_payments_count = 1 or > 1
                else  -- if nvl(inv_payment_status_flag,'N') = 'N'
                   net_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* net_amount1),func_curr_precision);
                   withholding_tax_amount1 := round((((paid_amount + nvl(discount_amount,0))/ (invoice_amount - invoice_prepaid_amount - invoice_withheld_amount))* invoice_withheld_amount * -1),func_curr_precision);
                end if;  -- if nvl(inv_payment_status_flag,'N') = 'Y' or 'N'
             end if;  -- if wht_mode = 'M'
             -- fnd_file.put_line(fnd_file.log,'Net Amount:' ||to_char(net_amount1));
             -- fnd_file.put_line(fnd_file.log,'WHT Amount:' ||to_char(withholding_tax_amount1));
             if ( withholding_tax_amount1 <>0 )
                or (tax_rate1 = 0) then                 -- Bug 1212074
                countrecs := countrecs + 1;
                ins_trans(      legal_entity_id => p_legal_entity_id,
                                org_id => p_org_id,
                                conc_req_id => p_conc_req_id,
                                remun_type => remun_type1,
                                sub_remun_type => sub_remun_type1,
                                vendor_nif => vendor_nif1,
                                vendor_name => vendor_name1,
                                invoice_id => invoice_id1,
                                invoice_num => invoice_num1,
                                inv_doc_seq_num => inv_doc_seq_num1,
                                invoice_date => invoice_date1,
                                gl_date => gl_date1,
                                invoice_payment_id => invoice_payment_id1,
                                date_paid => date_paid1,
                                net_amount => net_amount1,
                                withholding_tax_amount => withholding_tax_amount1,
                                zip_electronic => zip_electronic1,
                                zip_legal => zip_legal1,
                                city_legal => city_legal1,
                                num_children => num_children1,
                                sign => sign1,
                                tax_rate => tax_rate1,
                                tax_name => tax_name1,
                                year_due => year_due1);
               end if;
               END LOOP;
               plsqlmsg('Data inserted into table JE_ES_MODELO_190_ALL');
               CLOSE detail_paid;
               plsqlmsg('CURSOR Closed');
               plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
        else  -- p_pay_inv_sel <> 'P'
        /* Deal with APPOVED transactions */
        countrecs := 0;
        OPEN detail_approve;
        plsqlmsg('Opened CURSOR detail_approve');
        LOOP
        FETCH         detail_approve
        INTO         remun_type1,
                sub_remun_type1,
                vendor_nif1,
                vendor_name1,
                invoice_amount,
                inv_doc_seq_num1,
                invoice_id1,
                invoice_num1,
                invoice_date1,
                gl_date1,
                dist_awt_flag, -- bug 8709676
                net_amount1,
                withholding_tax_amount1,
                zip_legal1,
                city_legal1,
                tax_rate1,
                tax_name1;
        EXIT WHEN detail_approve%NOTFOUND;
        -- Bug 1271489: Get the correct tax name and tax rate.

      if dist_awt_flag <> 'M' then    --bug 8709676
        fetch_awt_line( p_pay_inv_sel,
                        invoice_id1,
                        withholding_tax_amount1,
                        gl_date1,                        -- Bug 3930123 : Spanugan 23/12/2004
                        tax_rate1,
                        tax_name1,
                        p_legal_entity_id,
                        p_org_id);

      end if; -- bug 8709676

        net_amount1 := round(net_amount1,func_curr_precision);
        withholding_tax_amount1 := round(withholding_tax_amount1,func_curr_precision);
        if ( withholding_tax_amount1 <>0 )
           or (tax_rate1 = 0) then                         -- Bug 1212074
           countrecs := countrecs + 1;
           ins_trans(   legal_entity_id => p_legal_entity_id,
                        org_id => p_org_id,
                        conc_req_id => p_conc_req_id,
                        remun_type => remun_type1,
                        sub_remun_type => sub_remun_type1,
                        vendor_nif => vendor_nif1,
                        vendor_name => vendor_name1,
                        invoice_id => invoice_id1,
                        invoice_num => invoice_num1,
                        inv_doc_seq_num => inv_doc_seq_num1,
                        invoice_date => invoice_date1,
                        gl_date => gl_date1,
                        invoice_payment_id => invoice_payment_id1,
                        date_paid => date_paid1,
                        net_amount => net_amount1,
                        withholding_tax_amount => withholding_tax_amount1,
                        zip_electronic => zip_electronic1,
                        zip_legal => zip_legal1,
                        city_legal => city_legal1,
                        num_children => num_children1,
                        sign => sign1,
                        tax_rate => tax_rate1,
                        tax_name => tax_name1,
                        year_due => year_due1);
        end if;
        END LOOP;
        plsqlmsg('Data inserted into table JE_ES_MODELO_190_all');
        CLOSE detail_approve;
        plsqlmsg('CURSOR Closed');
        plsqlmsg('Routine Successfully completed - ' || to_char(countrecs) || ' rows inserted');
        RETCODE := 0;
        end if;  -- p_pay_inv_sel = 'P' or <> 'P'
     end if;  -- p_summary = 'Y' or <> 'Y'
  end if;  -- p_hard_copy = 'N' or <> 'N'
EXCEPTION
WHEN bad_parameters THEN
   dbmsmsg('Error: Magnetic Report does not require DETAILED transactions');
   dbmsmsg('Error: Please Request SUMMARY transactions');
        RETCODE := 2;
-- Bug 1271489: exception handling of wrong number of awt lines.
WHEN bad_awt_lines THEN
        RETCODE := 2;
WHEN others THEN
   dbmsmsg('Error: '|| substr(SQLERRM(SQLCODE),1,255));
        RETCODE := 2;
        ERRBUF := 'Error: '|| substr(SQLERRM(SQLCODE),1,255);
end get_data;
END je_es_whtax;

/
