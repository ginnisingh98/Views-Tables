--------------------------------------------------------
--  DDL for Package Body RA_LL_RCV_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RA_LL_RCV_GROUPS_PKG" AS
/*$Header: ARRWGLTB.pls 120.5.12000000.2 2008/08/25 19:04:53 mpsingh ship $ */

PROCEDURE Delete_Row (
    X_GROUP_ID  				 IN				 NUMBER,
    X_CUSTOMER_TRX_ID  				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER
) IS
BEGIN

    DELETE AR_ACTIVITY_DETAILS
    WHERE  1 = 1
    AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
    AND GROUP_ID = X_GROUP_ID
    AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- BUG 7241111
    AND CUSTOMER_TRX_LINE_ID = (select customer_trx_line_id
                                from ra_customer_trx
                                where customer_trx_id = X_CUSTOMER_TRX_ID);


    IF ( SQL%NOTFOUND ) THEN
    -- 18 Oct 2005, don't need to raise error, when there are no rows
    /*RAISE NO_DATA_FOUND;
    */ null;
    END IF;
END Delete_Row;

PROCEDURE Insert_lintax_Rows (
    X_GROUP_ID          IN NUMBER,
    X_CASH_RECEIPT_ID   IN NUMBER,
    X_CUSTOMER_TRX_ID   IN NUMBER,
    X_lin               in number,
    x_tax               in number                ,
    X_lin_dsc           in number,
    x_tax_dsc           in number                ,
    x_CREATED_BY_MODULE in varchar2
    -- Oct 04 added two param below
    ,x_inv_to_rct_rate  in number default 1
    ,x_rct_curr_code    in varchar2 default arpcurr.FunctionalCurrency
) IS

cursor c_lintax
is
    select to_char(line.line_number) apply_to,
    line.customer_trx_line_id LINE_ID,
    -- No nvl needed in the foll amounts since arp_process_det_pkg.initialization
    -- would have updated the values to not-nulls
    line.source_data_key4 GROUP_ID ,
    line.amount_due_remaining line_rem,
    line.amount_due_original line_orig,
    tax.amount_due_remaining tax_rem,
    tax.amount_due_original tax_orig
  from ra_customer_trx_lines line,
  (select link_to_cust_trx_line_id,
          line_type,
          sum(nvl(amount_due_original,0)) amount_due_original,
          sum(nvl(amount_due_remaining,0)) amount_due_remaining
   from ra_customer_trx_lines
   where   nvl(line_type,'TAX') =  'TAX'
   group by link_to_cust_trx_line_id,
          line_type
  ) tax
  where line.line_type = 'LINE'
    and line.source_data_key4 = x_group_id
    and   line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
    and line.customer_trx_id = x_customer_trx_id;

  lintax_row c_lintax%rowtype;

  line_count    number;
  --iterator     number := 0;
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
     where nvl(line_type,'TAX') =  'TAX'
     group by link_to_cust_trx_line_id,
          line_type
    ) tax
    where line.customer_trx_id = x_customer_trx_id
    and line.line_type = 'LINE'
    and line.source_data_key4 = x_group_id
    and   line.customer_trx_line_id = tax.link_to_cust_trx_line_id (+)
    ;
  exception
    when others then
      arp_standard.debug ('Error in calcuating the total of all rows', 'plsql',
                          'RA_LL_RCV_GROUPS_PKG.INSERT_ROW', 1);
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
        line_2b_applied := arpcurr.currRound(lintax_row.line_rem * nvl(x_lin,0) / all_linrem_tot);

      else -- Overappl (all_linrem_tot < 0) should be done at the UI level,
           -- so this means all_linrem_tot = 0
        arp_standard.debug ('i='||to_char(iterator)||'.'||
                            'NOT LAST, all_linrem_tot=0. line_run_tot=' || line_run_tot
                            || '. all_linorig_tot=' || all_linorig_tot);
        if all_linorig_tot <> 0 then
          line_2b_applied := arpcurr.currRound(lintax_row.line_orig * nvl(x_lin,0) / all_linorig_tot);
        else
          line_2b_applied := 0;
        end if;
      end if;

     --Prorate the Tax Amount

     if all_taxrem_tot > 0 then
       tax_2b_applied := arpcurr.currRound(lintax_row.tax_rem * nvl(x_tax,0) / all_taxrem_tot);
     else-- Overappl (all_taxrem_tot < 0) should be done at the UI level,
           -- so this means all_taxrem_tot = 0
      if all_taxorig_tot <> 0 then
         tax_2b_applied := arpcurr.currRound(lintax_row.tax_orig * nvl(x_tax,0) / all_taxorig_tot);
       else
         tax_2b_applied := 0;
       end if;
     end if ;

      -- Added Dec 7, 2005 - Bug 4775656. Discounts are not getting saved from Summary
      -- Proate in the same ratio as that of the lin2bapplied / all_lin2bapplied_tot
        if nvl(x_lin,0) <> 0 then
          lindsc_2b_applied := arpcurr.currRound(x_lin_dsc * nvl(line_2b_applied,0) /  nvl(x_lin,0) );
        else
          lindsc_2b_applied := 0;
        end if;
      -- Proate in the same ratio as that of the tax2bapplied / all_tax2bapplied_tot
        if nvl(x_tax,0) <> 0 then
          taxdsc_2b_applied := arpcurr.currRound(x_tax_dsc * nvl(tax_2b_applied,0) / nvl(x_tax,0) );
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
                          'RA_LL_RCV_GROUPS_PKG.INSERT_ROW', 1);

    Select ar_Activity_details_s.nextval
     INTO l_line_id
     FROM DUAL;

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
	CURRENT_ACTIVITY_FLAG
    )

    VALUES (
        l_line_id,
        lintax_row.apply_to,
        lintax_row.line_id,
        DECODE(X_CASH_RECEIPT_ID, FND_API.G_MISS_NUM, NULL , X_CASH_RECEIPT_ID),
        DECODE(X_GROUP_ID, FND_API.G_MISS_NUM, NULL , X_GROUP_ID),
        arpcurr.currRound(nvl(line_2b_applied ,0)),
        arp_util.currRound(nvl(cross_currency_2b_applied,0), x_rct_curr_code ),
        arpcurr.currRound(nvl(tax_2b_applied ,0)),
        NVL(FND_GLOBAL.user_id,-1),
        SYSDATE,
        decode(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,
               FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
        SYSDATE,
        NVL(FND_GLOBAL.user_id,-1),
        0, -- Object Version Number is zero when the insert is at the group level
        x_created_by_module,
        'RA',
        lindsc_2b_applied,
        taxdsc_2b_applied,
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


PROCEDURE Lock_Row (
    X_CUSTOMER_TRX_ID				 IN				 NUMBER,
    X_CASH_RECEIPT_ID				 IN				 NUMBER,
    x_object_Version_number in number
) IS
BEGIN
  null;
END Lock_Row;


PROCEDURE Insert_Row (
    X_ROWID			 IN OUT NOCOPY ROWID,
    X_CASH_RECEIPT_ID		 IN NUMBER,
    X_GROUP_ID     		 IN NUMBER,
    X_CUSTOMER_TRX_ID            IN NUMBER,
    X_line_only                  IN NUMBER,
    x_tax_only                   IN NUMBER,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE          IN VARCHAR2
    -- Oct 04 added two param below
    ,x_inv_to_rct_rate in number default 1
    ,x_rct_curr_code in varchar2 default arpcurr.FunctionalCurrency
) IS
begin
        --insert_lintax_rows ( x_cash_receipt_id, x_customer_Trx_id, x_line_only, x_tax_only,
        --                x_lin_dsc, x_tax_dsc, x_created_by_module
        --                ,x_inv_to_rct_rate,x_rct_curr_code);

         Insert_lintax_Rows (
            X_CASH_RECEIPT_ID => X_CASH_RECEIPT_ID,
            X_GROUP_ID     	=> X_GROUP_ID,
            X_CUSTOMER_TRX_ID  =>    X_CUSTOMER_TRX_ID,
            x_lin               => x_line_only,
            x_tax                => x_tax_only,
            x_lin_dsc           => x_lin_dsc,
            x_tax_dsc           => x_tax_dsc,
            x_Created_By_Module => 'AR'
            -- Oct 04, 2005 Two params added below
            ,x_inv_to_rct_rate => x_inv_to_rct_rate
            ,x_rct_curr_code       => x_rct_curr_code);
end;



PROCEDURE Update_Row (
    X_ROWID	         IN OUT NOCOPY  ROWID,
    X_CASH_RECEIPT_ID   IN NUMBER,
    X_GROUP_ID          IN NUMBER,
    X_CUSTOMER_TRX_ID   IN NUMBER,
    X_line_only         in number,
    x_tax_only          in number                ,
    X_lin_dsc                in        number,
    x_tax_dsc             in number                ,
    x_CREATED_BY_MODULE in varchar2
    -- Oct 04 added two param below
    ,x_inv_to_rct_rate  in number default 1
    ,x_rct_curr_code    in varchar2 := arpcurr.FunctionalCurrency
) IS
  p_rowid rowid;
BEGIN
  delete_Row (x_group_id => x_group_id,
            x_customer_trx_id => x_customer_trx_id,
            x_cash_receipt_id => x_cash_receipt_id);
  insert_Row (
    x_rowid => p_ROWID				   				 ,
    X_CASH_RECEIPT_ID => X_CASH_RECEIPT_ID			 				 ,
    X_GROUP_ID => X_GROUP_ID     				 				 ,
    X_CUSTOMER_TRX_ID => X_CUSTOMER_TRX_ID,
    X_line_only => X_line_only,
    x_tax_only => x_tax_only,
    X_lin_dsc => X_lin_dsc,
    x_tax_dsc => x_tax_dsc,
    x_created_by_module => x_created_by_module
            -- Oct 04, 2005 Two params added below
            ,x_inv_to_rct_rate =>x_inv_to_rct_rate
            ,x_rct_curr_code       =>x_rct_curr_code
);

END Update_Row;



PROCEDURE Select_Row (
    X_APPLY_TO     				 IN OUT NOCOPY				 VARCHAR2,
    X_TAX_BALANCE  				 IN OUT NOCOPY				 NUMBER,
    X_CUSTOMER_TRX_LINE_ID				 IN OUT NOCOPY				 NUMBER,
    X_COMMENTS     				 IN OUT NOCOPY				 VARCHAR2,
    X_TAX          				 IN OUT NOCOPY				 NUMBER,
    X_CASH_RECEIPT_ID				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE_CATEGORY				 IN OUT NOCOPY				 VARCHAR2,
    X_ALLOCATED_RECEIPT_AMOUNT				 IN OUT NOCOPY				 NUMBER,
    X_GROUP_ID     				 IN OUT NOCOPY				 NUMBER,
    X_TAX_DISCOUNT 				 IN OUT NOCOPY				 NUMBER,
    X_AMOUNT       				 IN OUT NOCOPY				 NUMBER,
    X_LINE_DISCOUNT				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE9   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE8   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE7   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE6   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE5   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE4   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE3   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE2   				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE1   				 IN OUT NOCOPY				 VARCHAR2,
    X_LINE_BALANCE 				 IN OUT NOCOPY				 NUMBER,
    X_ATTRIBUTE15  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE14  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE13  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE12  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE11  				 IN OUT NOCOPY				 VARCHAR2,
    X_ATTRIBUTE10  				 IN OUT NOCOPY				 VARCHAR2
) IS


BEGIN

    SELECT
        NVL( APPLY_TO,FND_API.G_MISS_CHAR ),
        NVL( TAX_BALANCE,FND_API.G_MISS_NUM ),
        NVL( CUSTOMER_TRX_LINE_ID,FND_API.G_MISS_NUM ),
        NVL( COMMENTS,FND_API.G_MISS_CHAR ),
        NVL( TAX,FND_API.G_MISS_NUM ),
        NVL( CASH_RECEIPT_ID,FND_API.G_MISS_NUM ),
        NVL( ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR ),
        NVL( ALLOCATED_RECEIPT_AMOUNT,FND_API.G_MISS_NUM ),
        NVL( GROUP_ID,FND_API.G_MISS_NUM ),
        NVL( TAX_DISCOUNT,FND_API.G_MISS_NUM ),
        NVL( AMOUNT,FND_API.G_MISS_NUM ),
        NVL( LINE_DISCOUNT,FND_API.G_MISS_NUM ),
        NVL( ATTRIBUTE9,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE8,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE7,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE6,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE5,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE4,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE3,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE2,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE1,FND_API.G_MISS_CHAR ),
        NVL( LINE_BALANCE,FND_API.G_MISS_NUM ),
        NVL( ATTRIBUTE15,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE14,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE13,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE12,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE11,FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE10,FND_API.G_MISS_CHAR )
        INTO
        X_APPLY_TO,
        X_TAX_BALANCE,
        X_CUSTOMER_TRX_LINE_ID,
        X_COMMENTS,
        X_TAX,
        X_CASH_RECEIPT_ID,
        X_ATTRIBUTE_CATEGORY,
        X_ALLOCATED_RECEIPT_AMOUNT,
        X_GROUP_ID,
        X_TAX_DISCOUNT,
        X_AMOUNT,
        X_LINE_DISCOUNT,
        X_ATTRIBUTE9,
        X_ATTRIBUTE8,
        X_ATTRIBUTE7,
        X_ATTRIBUTE6,
        X_ATTRIBUTE5,
        X_ATTRIBUTE4,
        X_ATTRIBUTE3,
        X_ATTRIBUTE2,
        X_ATTRIBUTE1,
        X_LINE_BALANCE,
        X_ATTRIBUTE15,
        X_ATTRIBUTE14,
        X_ATTRIBUTE13,
        X_ATTRIBUTE12,
        X_ATTRIBUTE11,
        X_ATTRIBUTE10
        FROM AR_ACTIVITY_DETAILS
    WHERE  1 = 1  AND CASH_RECEIPT_ID = X_CASH_RECEIPT_ID
         AND NVL(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y' -- BUG 7241111
 AND CUSTOMER_TRX_LINE_ID = X_CUSTOMER_TRX_LINE_ID
;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'p_AR_ACTIVITY_DETAILS_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', '' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END Select_Row;





END;

/
