--------------------------------------------------------
--  DDL for Package Body AR_LL_RCV_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_LL_RCV_SUMMARY_PKG" AS
/*$Header: ARRWSLTB.pls 120.9.12010000.8 2010/04/30 06:48:57 nemani ship $ */


PROCEDURE Delete_Row (
    X_CUSTOMER_TRX_ID  				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
) IS
BEGIN

    DELETE AR_ACTIVITY_DETAILS
    WHERE  1 = 1
    AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
    AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- BUG 7241111
    AND CUSTOMER_TRX_LINE_ID in (select customer_trx_line_id
                                from ra_customer_trx_lines
                                where customer_trx_id = X_CUSTOMER_TRX_ID);
    IF ( SQL%NOTFOUND ) THEN
    -- 17 Jan 2006, don't need to raise error, when there are no rows
    /*RAISE NO_DATA_FOUND;
    */ null;
    END IF;
END Delete_Row;



PROCEDURE Lock_Row (
    X_CUSTOMER_TRX_ID				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    x_object_Version_number in number
) IS
BEGIN
  null;
END Lock_Row;


PROCEDURE Insert_Row (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_frt                 in        number,
    x_chg             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency /* Bug 5189370 */
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_attribute_category IN varchar2 DEFAULT NULL
    ,x_attribute1 IN varchar2 DEFAULT NULL
    ,x_attribute2 IN varchar2 DEFAULT NULL
    ,x_attribute3 IN varchar2 DEFAULT NULL
    ,x_attribute4 IN varchar2 DEFAULT NULL
    ,x_attribute5 IN varchar2 DEFAULT NULL
    ,x_attribute6 IN varchar2 DEFAULT NULL
    ,x_attribute7 IN varchar2 DEFAULT NULL
    ,x_attribute8 IN varchar2 DEFAULT NULL
    ,x_attribute9 IN varchar2 DEFAULT NULL
    ,x_attribute10 IN varchar2 DEFAULT NULL
    ,x_attribute11 IN varchar2 DEFAULT NULL
    ,x_attribute12 IN varchar2 DEFAULT NULL
    ,x_attribute13 IN varchar2 DEFAULT NULL
    ,x_attribute14 IN varchar2 DEFAULT NULL
    ,x_attribute15 IN varchar2 DEFAULT NULL
) IS
begin
/*Bug 7311231, Added parameter p_attribute_rec and passed it to procedures
  Insert_lintax_Rows, Insert_frt_Rows and Insert_chg_Rows */
  insert_lintax_rows ( x_cash_receipt_id, x_customer_Trx_id, x_lin, x_tax,
                        x_lin_dsc, x_tax_dsc, x_created_by_module
                        ,x_inv_curr_code
                        ,x_inv_to_rct_rate,x_rct_curr_code
			,p_attribute_category => x_attribute_category
			,p_attribute1 => x_attribute1
			,p_attribute2 => x_attribute2
			,p_attribute3 => x_attribute3
			,p_attribute4 => x_attribute4
			,p_attribute5 => x_attribute5
			,p_attribute6 => x_attribute6
			,p_attribute7 => x_attribute7
			,p_attribute8 => x_attribute8
			,p_attribute9 => x_attribute9
			,p_attribute10 => x_attribute10
			,p_attribute11 => x_attribute11
			,p_attribute12 => x_attribute12
			,p_attribute13 => x_attribute13
			,p_attribute14 => x_attribute14
			,p_attribute15 => x_attribute15
			);
  insert_frt_rows (x_cash_receipt_id, x_customer_Trx_id, x_frt, x_frt_dsc,
                   x_created_by_module
                   ,x_inv_curr_code
                   ,x_inv_to_rct_rate,x_rct_curr_code
		   ,p_attribute_category => x_attribute_category
		   ,p_attribute1 => x_attribute1
 		   ,p_attribute2 => x_attribute2
		   ,p_attribute3 => x_attribute3
		   ,p_attribute4 => x_attribute4
		   ,p_attribute5 => x_attribute5
		   ,p_attribute6 => x_attribute6
		   ,p_attribute7 => x_attribute7
		   ,p_attribute8 => x_attribute8
		   ,p_attribute9 => x_attribute9
		   ,p_attribute10 => x_attribute10
		   ,p_attribute11 => x_attribute11
		   ,p_attribute12 => x_attribute12
		   ,p_attribute13 => x_attribute13
		   ,p_attribute14 => x_attribute14
		   ,p_attribute15 => x_attribute15
		   );
  insert_chg_rows (x_cash_receipt_id, x_customer_Trx_id, x_chg,
                   x_created_by_module
                   ,x_inv_curr_code
                   ,x_inv_to_rct_rate,x_rct_curr_code
		   ,p_attribute_category => x_attribute_category
		   ,p_attribute1 => x_attribute1
		   ,p_attribute2 => x_attribute2
		   ,p_attribute3 => x_attribute3
		   ,p_attribute4 => x_attribute4
		   ,p_attribute5 => x_attribute5
		   ,p_attribute6 => x_attribute6
		   ,p_attribute7 => x_attribute7
		   ,p_attribute8 => x_attribute8
		   ,p_attribute9 => x_attribute9
		   ,p_attribute10 => x_attribute10
		   ,p_attribute11 => x_attribute11
		   ,p_attribute12 => x_attribute12
		   ,p_attribute13 => x_attribute13
		   ,p_attribute14 => x_attribute14
		   ,p_attribute15 => x_attribute15
	  	   );
end;

PROCEDURE Insert_lintax_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,p_attribute_category IN varchar2 DEFAULT NULL
    ,p_attribute1 IN varchar2 DEFAULT NULL
    ,p_attribute2 IN varchar2 DEFAULT NULL
    ,p_attribute3 IN varchar2 DEFAULT NULL
    ,p_attribute4 IN varchar2 DEFAULT NULL
    ,p_attribute5 IN varchar2 DEFAULT NULL
    ,p_attribute6 IN varchar2 DEFAULT NULL
    ,p_attribute7 IN varchar2 DEFAULT NULL
    ,p_attribute8 IN varchar2 DEFAULT NULL
    ,p_attribute9 IN varchar2 DEFAULT NULL
    ,p_attribute10 IN varchar2 DEFAULT NULL
    ,p_attribute11 IN varchar2 DEFAULT NULL
    ,p_attribute12 IN varchar2 DEFAULT NULL
    ,p_attribute13 IN varchar2 DEFAULT NULL
    ,p_attribute14 IN varchar2 DEFAULT NULL
    ,p_attribute15 IN varchar2 DEFAULT NULL
) IS

cursor c_lintax
is
  select
    line.line_number apply_to,
    line.customer_trx_line_id LINE_ID,
    -- No nvl needed in the foll amounts since arp_process_det_pkg.initialization
    -- would have updated the values to not-nulls
    line.amount_due_remaining line_rem,
    line.amount_due_original line_orig,
    tax.amount_due_remaining tax_rem,
    tax.amount_due_original tax_orig,
    line.source_data_key4 group_id
  from ra_customer_trx_lines line,
  (select link_to_cust_trx_line_id,
          line_type,
          sum(nvl(amount_due_original,0)) amount_due_original,
          sum(nvl(amount_due_remaining,0)) amount_due_remaining
   from ra_customer_trx_lines
   where nvl(line_type,'TAX') =  'TAX'
   and  customer_trx_id = x_customer_trx_id
   group by link_to_cust_trx_line_id,
          line_type
  ) tax
  where line.line_type = 'LINE'
    and   line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
    and line.customer_trx_id = x_customer_trx_id;

  lintax_row c_lintax%rowtype;

  line_count    number;
  iterator     number := 1;

  all_linrem_tot number;
  all_linorig_tot number;
  line_run_tot number := 0;
  line_2b_applied  number;

  all_taxrem_tot number;
  all_taxorig_tot number;
  tax_run_tot number := 0;
  tax_2b_applied  number;

  -- Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
  lindsc_run_tot number := 0;
  lindsc_2b_applied  number;

  taxdsc_run_tot number := 0;
  taxdsc_2b_applied  number;
  -- End of additions for bug 4775656

  --Used in proration (cumulation logic - bug 7307197)
  x_run_line_amt        number := 0;
  x_run_tax_amt         number := 0;
  x_run_line_disc_amt   number := 0;
  x_run_tax_disc_amt    number := 0;

  --no need for the total for all lines, for amt_app_from
  --since we are not pro-rating amt_app_from. To get amt_app_from
  --we are just multiplying the inv_to_rct_rate into prorated amt
  /*all_amt_app_from number;
  amt_app_from_run_tot number := 0;*/
  cross_currency_2b_applied number;

  l_line_id   NUMBER;

BEGIN
  begin
    select count(*) ,
    sum(nvl(line.amount_due_remaining,0)),
    sum(nvl(tax.amount_due_remaining,0)),
    sum(nvl(line.amount_due_original,0)),
    sum(nvl(tax.amount_due_original,0))
    into line_count,
         all_linrem_tot, all_taxrem_tot,
         all_linorig_tot, all_taxorig_tot
    from ra_customer_trx_lines line,
    (select link_to_cust_trx_line_id,
          line_type,
          sum(nvl(amount_due_original,0)) amount_due_original,
          sum(nvl(amount_due_remaining,0)) amount_due_remaining
     from ra_customer_trx_lines
     where  nvl(line_type,'TAX') =  'TAX'
            and customer_trx_id  =  x_customer_trx_id
     group by link_to_cust_trx_line_id,
          line_type
    ) tax
    where line.customer_trx_id = x_customer_trx_id
    and line.line_type = 'LINE'
    and   line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
    ;
  exception
    when others then
      arp_standard.debug ('Error in calcuating the total of all rows', 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);
      raise ;
  end;
  for lintax_row in c_lintax loop

    -- Prorate the Line Amount
    if iterator = line_count then
      arp_standard.debug ('i='||to_char(iterator)||'.'|| 'THIS IS THE LAST. line_run_tot=' || line_run_tot);
      line_2b_applied := nvl(x_lin,0) - line_run_tot;
      tax_2b_applied := nvl(x_tax,0) - tax_run_tot;

      -- Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
      lindsc_2b_applied := nvl(x_lin_dsc,0) - lindsc_run_tot;
      taxdsc_2b_applied := nvl(x_tax_dsc,0) - taxdsc_run_tot;
      -- End of additions for bug 4775656
    else -- If the adr on the invoice is zero, then
      if all_linrem_tot > 0 then
        arp_standard.debug ('i='||to_char(iterator)||'.'||
                            'NOT LAST, all_linrem_tot<>0. line_run_tot=' || line_run_tot
                            || '. all_linorig_tot=' || all_linorig_tot);
        --line_2b_applied := arpcurr.currRound(lintax_row.line_rem * nvl(x_lin,0) / all_linrem_tot);
        x_run_line_amt := x_run_line_amt + lintax_row.line_rem;
        line_2b_applied := arpcurr.currRound(x_run_line_amt * nvl(x_lin,0) / all_linrem_tot) - line_run_tot;
      else -- Overappl (all_linrem_tot < 0) should be done at the UI level,
           -- so this means all_linrem_tot = 0
        arp_standard.debug ('i='||to_char(iterator)||'.'||
                            'NOT LAST, all_linrem_tot=0. line_run_tot=' || line_run_tot
                            || '. all_linorig_tot=' || all_linorig_tot);
        if all_linorig_tot <> 0 then
          --line_2b_applied := arpcurr.currRound(lintax_row.line_orig * nvl(x_lin,0) / all_linorig_tot);
          x_run_line_amt := x_run_line_amt + lintax_row.line_orig;
          line_2b_applied := arpcurr.currRound(x_run_line_amt * nvl(x_lin,0) / all_linorig_tot) - line_run_tot;
        else
          line_2b_applied := 0;
        end if;
      end if;

     --Prorate the Tax Amount

     if all_taxrem_tot > 0 then
       --tax_2b_applied := arpcurr.currRound(lintax_row.tax_rem * nvl(x_tax,0) / all_taxrem_tot);
       x_run_tax_amt := x_run_tax_amt + lintax_row.tax_rem;
       tax_2b_applied := arpcurr.currRound(x_run_tax_amt * nvl(x_tax,0) / all_taxrem_tot) - tax_run_tot;
     else-- Overappl (all_taxrem_tot < 0) should be done at the UI level,
           -- so this means all_taxrem_tot = 0
      if all_taxorig_tot <> 0 then
         --tax_2b_applied := arpcurr.currRound(lintax_row.tax_orig * nvl(x_tax,0) / all_taxorig_tot);
         x_run_tax_amt := x_run_tax_amt + lintax_row.tax_orig;
         tax_2b_applied := arpcurr.currRound(x_run_tax_amt * nvl(x_tax,0) / all_taxorig_tot) - tax_run_tot;
       else
         tax_2b_applied := 0;
       end if;
     end if ;

      -- Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
      -- Proate in the same ratio as that of the lin2bapplied / all_lin2bapplied_tot
        if nvl(x_lin,0) <> 0 then
          --lindsc_2b_applied := arpcurr.currRound(x_lin_dsc * nvl(line_2b_applied,0) /  nvl(x_lin,0) );
	  lindsc_2b_applied := arpcurr.currRound(x_lin_dsc * nvl(line_run_tot,0) /  nvl(x_lin,0) ) - lindsc_run_tot;
        else
          lindsc_2b_applied := 0;
        end if;
      -- Proate in the same ratio as that of the tax2bapplied / all_tax2bapplied_tot
        if nvl(x_tax,0) <> 0 then
          --taxdsc_2b_applied := arpcurr.currRound(x_tax_dsc * nvl(tax_2b_applied,0) / nvl(x_tax,0) );
	  taxdsc_2b_applied := arpcurr.currRound(x_tax_dsc * nvl(tax_run_tot,0) / nvl(x_tax,0) )- taxdsc_run_tot;
        else
          taxdsc_2b_applied := 0;
        end if;
      -- End of additions for bug 4775656
    end if;

    -- Calculate the Allocated Receipt Amount for the line
    cross_currency_2b_applied := arp_util.currRound((line_2b_applied+tax_2b_applied) * nvl(x_inv_to_rct_rate,1), x_rct_curr_code);
    arp_standard.debug ('i='||to_char(iterator)||'.'||
                              'line_amount='||to_char(line_2b_applied)||'.'||
                               'tax_amount='||to_char(tax_2b_applied)||'.'||
                               'alloc_rct_amt='||to_char(cross_currency_2b_applied)||'.'
                             , 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);

    Select ar_Activity_details_s.nextval
     INTO l_line_id
     FROM DUAL;

/*Bug 7311231,Modified the code to insert Flexfield info in AR_ACTIVITY_DETAILS.*/
    INSERT INTO AR_ACTIVITY_DETAILS (
        LINE_ID,
        APPLY_TO,
        customer_trx_line_id,
        CASH_RECEIPT_ID,
        GROUP_ID,
        AMOUNT,
        allocated_receipt_amount,
        TAX,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        SOURCE_TABLE,
        line_discount,
        tax_discount,
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
	CURRENT_ACTIVITY_FLAG
    )

    VALUES (
        l_line_id,
        lintax_row.apply_to,
        lintax_row.line_id,
        DECODE(X_CASH_RECEIPT_ID, FND_API.G_MISS_NUM, NULL , X_CASH_RECEIPT_ID),
        lintax_row.group_id,
        arpcurr.currRound(nvl(line_2b_applied ,0),x_inv_curr_code),
        arp_util.currRound(nvl(cross_currency_2b_applied,0), x_rct_curr_code),
        arpcurr.currRound(nvl(tax_2b_applied ,0),x_inv_curr_code),
        NVL(FND_GLOBAL.user_id,-1),
        SYSDATE,
        decode(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,
               FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
        SYSDATE,
        NVL(FND_GLOBAL.user_id,-1),
        0, -- Object Version Number is zero when the insert is at the group/summary level,
        x_created_by_module,
        'RA',
        lindsc_2b_applied,
        taxdsc_2b_applied,
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
	'Y'
        );

    line_run_tot := line_run_tot + line_2b_applied;
    tax_run_tot := tax_run_tot + tax_2b_applied;
    -- Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
    lindsc_run_tot := lindsc_run_tot + lindsc_2b_applied;
    taxdsc_run_tot := taxdsc_run_tot + taxdsc_2b_applied;
    -- End of additions for bug 4775656
    iterator := iterator + 1;
  end loop;
END Insert_lintax_Rows;



PROCEDURE Insert_frt_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_frt                 in        number,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    -- Oct 04 added two param below
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_comments      in varchar2 default null /* Bug 5453663 */
    ,p_attribute_category IN varchar2 DEFAULT NULL
    ,p_attribute1 IN varchar2 DEFAULT NULL
    ,p_attribute2 IN varchar2 DEFAULT NULL
    ,p_attribute3 IN varchar2 DEFAULT NULL
    ,p_attribute4 IN varchar2 DEFAULT NULL
    ,p_attribute5 IN varchar2 DEFAULT NULL
    ,p_attribute6 IN varchar2 DEFAULT NULL
    ,p_attribute7 IN varchar2 DEFAULT NULL
    ,p_attribute8 IN varchar2 DEFAULT NULL
    ,p_attribute9 IN varchar2 DEFAULT NULL
    ,p_attribute10 IN varchar2 DEFAULT NULL
    ,p_attribute11 IN varchar2 DEFAULT NULL
    ,p_attribute12 IN varchar2 DEFAULT NULL
    ,p_attribute13 IN varchar2 DEFAULT NULL
    ,p_attribute14 IN varchar2 DEFAULT NULL
    ,p_attribute15 IN varchar2 DEFAULT NULL
) IS

cursor c_frt
is
  select
    'FREIGHT' apply_to,
    line.customer_trx_line_id LINE_ID,
    -- No nvl needed in the foll amounts since arp_process_det_pkg.initialization
    -- would have updated the values to not-nulls
    decode(line_type, 'FREIGHT', line.amount_due_remaining,
                      'LINE', frt_adj_remaining, 0) frt_rem,
    decode(line_type, 'FREIGHT', line.amount_due_original,
                      'LINE', frt_adj_remaining, 0) frt_orig,
    NULL group_id
  from ra_customer_trx_lines line
  where (line.line_type = 'FREIGHT' OR
          (line.line_type = 'LINE'
           and nvl(line.frt_adj_remaining,0) <> 0))
    and line.customer_trx_id = x_customer_trx_id;

  frt_row c_frt%rowtype;

  line_count    number;
  iterator     number := 1;

  all_frtrem_tot number;
  all_frtorig_tot number;
  frt_run_tot number := 0;
  frt_2b_applied  number;

  -- 2 lines Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
  frtdsc_run_tot number := 0;
  frtdsc_2b_applied  number;

  cross_currency_2b_applied number;
  l_line_id   NUMBER;
BEGIN
  begin
    select count(*) row_count,
    sum(decode(line_type, 'FREIGHT', line.amount_due_remaining,
                          'LINE', frt_adj_remaining, 0)) all_frtrem_tot,
    sum(decode(line_type, 'FREIGHT', line.amount_due_original,
                          'LINE', frt_adj_remaining, 0)) all_frtorig_tot
    into line_count, all_frtrem_tot, all_frtorig_tot
    from ra_customer_trx_lines line
    where line.customer_trx_id = x_customer_trx_id
    and (line.line_type = 'FREIGHT' OR
          (line.line_type = 'LINE'
           and nvl(line.frt_adj_remaining,0) <> 0))
    ;
  exception
    when others then
      arp_standard.debug ('Error in calcuating the total of all rows', 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);
      raise ;
  end;
  for frt_row in c_frt loop
    if iterator = line_count then
      frt_2b_applied := x_frt - frt_run_tot;
    else
      if all_frtrem_tot > 0 then
        frt_2b_applied := arpcurr.currRound(frt_row.frt_rem * x_frt / all_frtrem_tot);
      else -- Overappl (all_frtrem_tot < 0) should be done at the UI level,
           -- so this means all_frtrem_tot = 0
       if all_frtorig_tot <> 0 then
          frt_2b_applied := arpcurr.currRound(frt_row.frt_orig * x_frt / all_frtorig_tot);
        else
          frt_2b_applied := 0;
        end if;
      end if;

    end if;
      -- Proate in the same ratio as that of the lin2bapplied / all_lin2bapplied_tot
        if  nvl(x_frt,0) <> 0 then
          frtdsc_2b_applied := arpcurr.currRound(x_frt_dsc * nvl(frt_2b_applied,0) /  nvl(x_frt,0) );
        else
          frtdsc_2b_applied := 0;
        end if;
          arp_standard.debug ('i='||to_char(iterator)||'.'||
                              'frt_amount='||to_char(frt_2b_applied)||'.'||
                               'frt_discount='||to_char(frtdsc_2b_applied)||'.'
                             , 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);

     Select ar_Activity_details_s.nextval
     INTO l_line_id
     FROM DUAL;

    -- Calculate the Allocated Receipt Amount for the line
    cross_currency_2b_applied := arp_util.currRound((frt_2b_applied) * nvl(x_inv_to_rct_rate,1), x_rct_curr_code);
    arp_standard.debug ('i='||to_char(iterator)||'.'||
                              'frt_amount='||to_char(frt_2b_applied)||'.'||
                               'alloc_rct_amt='||to_char(cross_currency_2b_applied)||'.'
                             , 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);

/*Bug 7311231,Modified the code to insert Flexfield info in AR_ACTIVITY_DETAILS.*/
    INSERT INTO AR_ACTIVITY_DETAILS (
        LINE_ID,
        APPLY_TO,
        customer_trx_line_id,
        CASH_RECEIPT_ID,
        GROUP_ID,
        AMOUNT,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        SOURCE_TABLE
        -- 1 line added below Oct 26
        , allocated_receipt_amount
        -- 2 lines added below Dec 12
        , freight
        , freight_discount,
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
	CURRENT_ACTIVITY_FLAG
    )

    VALUES (
        l_line_id,
        frt_row.apply_to,
        frt_row.line_id,
        DECODE(X_CASH_RECEIPT_ID, FND_API.G_MISS_NUM, NULL , X_CASH_RECEIPT_ID),
        frt_row.GROUP_ID,
        0, -- Bug 5189370 arpcurr.currRound(nvl(Frt_2b_applied ,0)),
        X_COMMENTS,
        NVL(FND_GLOBAL.user_id,-1),
        SYSDATE,
        decode(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,
               FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
        SYSDATE,
        NVL(FND_GLOBAL.user_id,-1),
        0, -- Object Version Number is zero when the insert is at the group/summary level,
        x_created_by_module,
        'RA'
        -- 1 line added below added Oct 26
        , cross_currency_2b_applied
        -- 2 lines added below Dec 12
        , arpcurr.currRound(nvl(Frt_2b_applied ,0),x_inv_curr_code)
        , arpcurr.currRound(nvl(FrtDsc_2b_applied ,0),x_inv_curr_Code),
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
	'Y'
       );

    frt_run_tot := frt_run_tot + frt_2b_applied;
    -- 1 line Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
    frtdsc_run_tot := frtdsc_run_tot + frtdsc_2b_applied;
    iterator := iterator + 1;
  end loop;
END Insert_frt_Rows;


PROCEDURE Insert_chg_Rows (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_chg                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,p_attribute_category IN varchar2 DEFAULT NULL
    ,p_attribute1 IN varchar2 DEFAULT NULL
    ,p_attribute2 IN varchar2 DEFAULT NULL
    ,p_attribute3 IN varchar2 DEFAULT NULL
    ,p_attribute4 IN varchar2 DEFAULT NULL
    ,p_attribute5 IN varchar2 DEFAULT NULL
    ,p_attribute6 IN varchar2 DEFAULT NULL
    ,p_attribute7 IN varchar2 DEFAULT NULL
    ,p_attribute8 IN varchar2 DEFAULT NULL
    ,p_attribute9 IN varchar2 DEFAULT NULL
    ,p_attribute10 IN varchar2 DEFAULT NULL
    ,p_attribute11 IN varchar2 DEFAULT NULL
    ,p_attribute12 IN varchar2 DEFAULT NULL
    ,p_attribute13 IN varchar2 DEFAULT NULL
    ,p_attribute14 IN varchar2 DEFAULT NULL
    ,p_attribute15 IN varchar2 DEFAULT NULL
) IS

cursor c_chg
is
  select
    'CHARGES' apply_to,
    line.customer_trx_line_id LINE_ID,
    -- No nvl needed in the foll amounts since arp_process_det_pkg.initialization
    -- would have updated the values to not-nulls
    decode(line_type, 'CHARGES', line.amount_due_remaining,
                      'LINE', line.chrg_amount_remaining, 0) chg_rem,
    decode(line_type, 'CHARGES', line.amount_due_original,
                      'LINE', line.chrg_amount_remaining, 0) chg_orig,
    NULL group_id
  from ra_customer_trx_lines line
  where (line.line_type = 'CHARGES' OR
          (line.line_type = 'LINE'
           and nvl(line.chrg_amount_remaining,0) <> 0))
    and line.customer_trx_id = x_customer_trx_id;

  chg_row c_chg%rowtype;

  line_count    number;
  iterator     number := 1;

  all_chgrem_tot number;
  all_chgorig_tot number;
  chg_run_tot number := 0;
  chg_2b_applied  number;

  cross_currency_2b_applied number;
  l_line_id   NUMBER;
BEGIN
  begin
    select count(*) row_count,
    sum(nvl(decode(line_type, 'CHARGES', line.amount_due_remaining,
                              'LINE', chrg_amount_remaining, 0), 0)),
    sum(nvl(decode(line_type, 'CHARGES', line.amount_due_original,
                              'LINE', chrg_amount_remaining, 0), 0))
    into line_count, all_chgrem_tot,
         all_chgorig_tot
    from ra_customer_trx_lines line
    where line.customer_trx_id = x_customer_trx_id
    and (line.line_type = 'CHARGES' OR
          (line.line_type = 'LINE'
           and nvl(line.chrg_amount_remaining,0) <> 0))
    ;
  exception
    when others then
      arp_standard.debug ('Error in calcuating the total of all rows', 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);
      raise ;
  end;
  for chg_row in c_chg loop
    if iterator = line_count then
      chg_2b_applied := x_chg - chg_run_tot;
    else
      if all_chgrem_tot > 0 then
        chg_2b_applied := arpcurr.currRound(chg_row.chg_rem * x_chg / all_chgrem_tot);
      else -- Overappl (all_chgrem_tot < 0) should be done at the UI level,
           -- so this means all_chgrem_tot = 0
       if all_chgorig_tot <> 0 then
          chg_2b_applied := arpcurr.currRound(chg_row.chg_orig * x_chg / all_chgorig_tot);
        else
          chg_2b_applied := 0;
        end if;
      end if;
    end if;
          arp_standard.debug ('i='||to_char(iterator)||'.'||
                              'chg_amount='||to_char(chg_2b_applied)||'.'
                             , 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);

     Select ar_Activity_details_s.nextval
     INTO l_line_id
     FROM DUAL;


    -- Calculate the Allocated Receipt Amount for the line
    cross_currency_2b_applied := arp_util.currRound((chg_2b_applied) *
                                   nvl(x_inv_to_rct_rate,1), x_rct_curr_code);
    arp_standard.debug ('i='||to_char(iterator)||'.'||
                              'chg_amount='||to_char(chg_2b_applied)||'.'||
                               'alloc_rct_amt='||to_char(cross_currency_2b_applied)||'.'
                             , 'plsql',
                          'AR_LL_RCV_SUMMARY_PKG.INSERT_ROW', 1);

/*Bug 7311231,Modified the code to insert Flexfield info in AR_ACTIVITY_DETAILS.*/
    INSERT INTO AR_ACTIVITY_DETAILS (
        LINE_ID,
        APPLY_TO,
        customer_trx_line_id,
        CASH_RECEIPT_ID,
        GROUP_ID,
        AMOUNT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        OBJECT_VERSION_NUMBER,
        CREATED_BY_MODULE,
        SOURCE_TABLE
        -- 1 line added below Oct 26
        , allocated_receipt_amount
        -- 1 line added below Dec 12
        , charges,
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
	CURRENT_ACTIVITY_FLAG
    )

    VALUES (
        l_line_id,
        chg_row.apply_to,
        chg_row.line_id,
        DECODE(X_CASH_RECEIPT_ID, FND_API.G_MISS_NUM, NULL , X_CASH_RECEIPT_ID),
        chg_row.GROUP_ID,
        0, -- Bug 5189370  arpcurr.currRound(nvl(chg_2b_applied ,0)),
        NVL(FND_GLOBAL.user_id,-1),
        SYSDATE,
        decode(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,
               FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
        SYSDATE,
        NVL(FND_GLOBAL.user_id,-1),
        0, -- Object Version Number is zero when the insert is at the group/summary level,
        x_created_by_module,
        'RA'
        -- 1 line added below Oct 26
        , cross_currency_2b_applied
        -- 1 line added below Dec 12
        , arpcurr.currRound(nvl(chg_2b_applied ,0),x_inv_curr_code),
	p_attribute_category,
	p_attribute1,
	p_attribute2,
	p_attribute3,
	p_attribute4,
	p_attribute5,
	p_attribute6,
	p_attribute7,
	p_attribute8,
	p_attribute9,
	p_attribute10,
	p_attribute11,
	p_attribute12,
	p_attribute13,
	p_attribute14,
	p_attribute15,
	'Y'
        );

    chg_run_tot := chg_run_tot + chg_2b_applied;
    iterator := iterator + 1;
  end loop;
END insert_chg_rows;


-- Bug 7241111
PROCEDURE offset_row (
 X_CUSTOMER_TRX_ID      IN NUMBER,
 X_CASH_RECEIPT_ID      IN NUMBER
)
IS
BEGIN

  INSERT INTO AR_ACTIVITY_DETAILS(
                                CASH_RECEIPT_ID,
                                CUSTOMER_TRX_LINE_ID,
                                ALLOCATED_RECEIPT_AMOUNT,
                                AMOUNT,
                                TAX,
                                FREIGHT,
                                CHARGES,
                                LAST_UPDATE_DATE,
                                LAST_UPDATED_BY,
                                LINE_DISCOUNT,
                                TAX_DISCOUNT,
                                FREIGHT_DISCOUNT,
                                LINE_BALANCE,
                                TAX_BALANCE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_LOGIN,
                                COMMENTS,
                                APPLY_TO,
                                ATTRIBUTE1,
                                ATTRIBUTE2,
                                ATTRIBUTE3,
                                ATTRIBUTE4,
                                ATTRIBUTE5,
                                ATTRIBUTE6,
                                ATTRIBUTE7,
                                ATTRIBUTE8,
                                ATTRIBUTE9,
                                ATTRIBUTE10,
                                ATTRIBUTE11,
                                ATTRIBUTE12,
                                ATTRIBUTE13,
                                ATTRIBUTE14,
                                ATTRIBUTE15,
                                ATTRIBUTE_CATEGORY,
                                GROUP_ID,
                                REFERENCE1,
                                REFERENCE2,
                                REFERENCE3,
                                REFERENCE4,
                                REFERENCE5,
                                OBJECT_VERSION_NUMBER,
                                CREATED_BY_MODULE,
                                SOURCE_ID,
                                SOURCE_TABLE,
                                LINE_ID,
			        CURRENT_ACTIVITY_FLAG)
                        SELECT
                                LLD.CASH_RECEIPT_ID,
                                LLD.CUSTOMER_TRX_LINE_ID,
                                LLD.ALLOCATED_RECEIPT_AMOUNT*-1,
                                LLD.AMOUNT*-1,
                                LLD.TAX*-1,
                                LLD.FREIGHT*-1,
                                LLD.CHARGES*-1,
                                LLD.LAST_UPDATE_DATE,
                                LLD.LAST_UPDATED_BY,
                                LLD.LINE_DISCOUNT,
                                LLD.TAX_DISCOUNT,
                                LLD.FREIGHT_DISCOUNT,
                                LLD.LINE_BALANCE,
                                LLD.TAX_BALANCE,
                                LLD.CREATION_DATE,
                                LLD.CREATED_BY,
                                LLD.LAST_UPDATE_LOGIN,
                                LLD.COMMENTS,
                                LLD.APPLY_TO,
                                LLD.ATTRIBUTE1,
                                LLD.ATTRIBUTE2,
                                LLD.ATTRIBUTE3,
                                LLD.ATTRIBUTE4,
                                LLD.ATTRIBUTE5,
                                LLD.ATTRIBUTE6,
                                LLD.ATTRIBUTE7,
                                LLD.ATTRIBUTE8,
                                LLD.ATTRIBUTE9,
                                LLD.ATTRIBUTE10,
                                LLD.ATTRIBUTE11,
                                LLD.ATTRIBUTE12,
                                LLD.ATTRIBUTE13,
                                LLD.ATTRIBUTE14,
                                LLD.ATTRIBUTE15,
                                LLD.ATTRIBUTE_CATEGORY,
                                LLD.GROUP_ID,
                                LLD.REFERENCE1,
                                LLD.REFERENCE2,
                                LLD.REFERENCE3,
                                LLD.REFERENCE4,
                                LLD.REFERENCE5,
                                LLD.OBJECT_VERSION_NUMBER,
                                LLD.CREATED_BY_MODULE,
                                LLD.SOURCE_ID,
                                LLD.SOURCE_TABLE,
                                ar_activity_details_s.nextval,
                                'R'
                        FROM ar_Activity_details LLD,
			     ra_customer_trx_lines rctl
		         WHERE rctl.CUSTOMER_TRX_ID = X_CUSTOMER_TRX_ID
			 AND LLD.CUSTOMER_TRX_LINE_ID = rctl.CUSTOMER_TRX_LINE_ID
			 AND LLD.CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y';


         UPDATE ar_Activity_details
		     set CURRENT_ACTIVITY_FLAG = 'N'
		         WHERE CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
			 AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y'
			 AND CUSTOMER_TRX_LINE_ID IN
			 ( select CUSTOMER_TRX_LINE_ID
			   from ra_customer_trx_lines
			   where CUSTOMER_TRX_ID = X_CUSTOMER_TRX_ID
			 );


END;


PROCEDURE Update_Row (
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID      IN        NUMBER,
    X_lin                 in        number,
    x_tax             in number                ,
    X_frt                 in        number,
    x_chg             in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    X_frt_dsc                 in        number,
    x_CREATED_BY_MODULE in varchar2
    ,x_inv_curr_code in varchar2 default arpcurr.FunctionalCurrency
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
) IS

BEGIN
  -- Bug 7241111 instead of deleting now inserting offset rows

offset_row(X_CUSTOMER_TRX_ID,
           X_CASH_RECEIPT_ID
);

  insert_row(    X_CASH_RECEIPT_ID=>X_CASH_RECEIPT_ID,
    X_CUSTOMER_TRX_ID=>X_CUSTOMER_TRX_ID,
    X_lin=>X_lin,
    x_tax=>X_tax,
    X_frt=>X_frt,
    x_chg=>x_chg,
    X_lin_dsc=>X_lin_dsc,
    x_tax_dsc=>x_tax_dsc,
    X_frt_dsc=>X_frt_dsc,
    x_CREATED_BY_MODULE=>x_CREATED_BY_MODULE
            ,x_inv_curr_code       =>x_inv_curr_code
            ,x_inv_to_rct_rate =>x_inv_to_rct_rate
            ,x_rct_curr_code       =>x_rct_curr_code
);

END Update_Row;

END AR_LL_RCV_SUMMARY_PKG;

/
