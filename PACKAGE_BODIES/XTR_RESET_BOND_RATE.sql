--------------------------------------------------------
--  DDL for Package Body XTR_RESET_BOND_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_RESET_BOND_RATE" AS
/* $Header: xtrrfbrb.pls 120.1 2005/11/17 10:52:01 badiredd noship $*/



   PROCEDURE RESET_BOND_BENCHMARK_RATE (errbuf       	OUT NOCOPY VARCHAR2,
                      	       retcode      	OUT NOCOPY NUMBER,
			                   p_rateset_from   IN VARCHAR2,
                               p_rateset_to     IN VARCHAR2,
                               p_rateset_adj    IN NUMBER,
                               p_bond_issue_code IN VARCHAR2,
                               p_currency       IN VARCHAR2,
                               p_bench_mark       IN VARCHAR2,
                               p_overwrite_type IN VARCHAR2 DEFAULT 'N')
    AS
     l_buf VARCHAR2(300);
   l_rowid         ROWID;
   l_company       XTR_DEALS.COMPANY_CODE%TYPE;
   l_deal_no       NUMBER;
   l_tran_no       NUMBER;
   l_deal_type     XTR_DEALS.DEAL_TYPE%TYPE;
   l_start_date     DATE;
   l_coupon_date    DATE;
   l_ratefix_date  DATE;
   l_bond_issue_code XTR_BOND_COUPON_DATES.bond_issue_code%TYPE;
   l_bench_mark      XTR_BOND_ISSUES.BENCHMARK_RATE%TYPE;
   l_margin        NUMBER;
   l_new_rate      NUMBER;
   l_rate          NUMBER;
   l_valid_ok      BOOLEAN;
   l_error         NUMBER;
   l_count         NUMBER:= 0;
   l_count1        NUMBER:= 0;
   l_hold          VARCHAR2(1);
   l_retcode       NUMBER := 0;


   /*-------------------------------------------------*/
   /*  Selection criteria for transactions :          */
   /*  - only BOND deals with Benchmark Rate          */
   /*  - Benchmark Rate  is not null                  */
   /*  - RATE_FIXING_DATE is not null on transaction  */
   /*  - RATE_FIXING_DATE within parameter date range */
   /*-------------------------------------------------*/

   CURSOR C_GET_ALL_BOND_ISSUES IS
   select b.bond_issue_code,
		  b.rate_fixing_date,
          b.coupon_date,
          c.benchmark_rate,
		  nvl(c.float_margin,0)
		FROM
		  XTR_BOND_COUPON_DATES b,
		  XTR_BOND_ISSUES c
	   WHERE  b.bond_issue_code = c.bond_issue_code
          AND b.bond_issue_code = NVL(p_bond_issue_code,b.bond_issue_code)
		  and b.rate_fixing_date between fnd_date.canonical_to_date(p_rateset_from)
                             and     fnd_date.canonical_to_date(p_rateset_to)
		  and c.benchmark_rate is not null
		  and c.benchmark_rate   = nvl(p_bench_mark, c.benchmark_rate)
          and c.calc_type in ('FL IRREGULAR','FL REGULAR')
		ORDER BY b.bond_issue_code,b.rate_fixing_date,b.coupon_date;




   cursor C_ONE_ROW_BOND is
        select 'Y'
        from XTR_BOND_COUPON_DATES a
        where a.bond_issue_code = l_bond_issue_code
        and a.rate_fixing_date = l_ratefix_date
        and a.rate_fixing_date < (
            select max (b.rate_fixing_date)
		        FROM
		        XTR_BOND_COUPON_DATES b
		        WHERE  b.bond_issue_code = l_bond_issue_code
		        and b.rate_fixing_date between fnd_date.canonical_to_date(p_rateset_from)
                             and     fnd_date.canonical_to_date(p_rateset_to) );

    cursor C_SUBSEQ_BOND_DETAILS IS
        select a.rate_fixing_date,
              a.coupon_date
            from XTR_BOND_COUPON_DATES a
            where a.bond_issue_code = l_bond_issue_code
            and a.rate_fixing_date >= l_ratefix_date
            Order by a.rate_fixing_date;

    bond_info C_SUBSEQ_BOND_DETAILS%ROWTYPE;

   BEGIN

    retcode := 0;

    if fnd_date.canonical_to_date(p_rateset_from) > sysdate then
        retcode := 2;
        FND_MESSAGE.SET_NAME('XTR', 'XTR_RESET_DATE_FROM');
        l_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_buf);
    end if;

    if fnd_date.canonical_to_date(p_rateset_to) > sysdate then
        retcode := 2;
        FND_MESSAGE.SET_NAME('XTR', 'XTR_RESET_DATE_TO');
        l_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_buf);
    end if;

    If(retcode = 0)then
        OPEN C_GET_ALL_BOND_ISSUES;
        LOOP
            FETCH C_GET_ALL_BOND_ISSUES into  l_bond_issue_code, l_ratefix_date,
                            l_coupon_date, l_bench_mark, l_margin;
            EXIT when C_GET_ALL_BOND_ISSUES%notfound;

            l_count := l_count +1;
            l_valid_ok := TRUE;
            l_error := 0;
            VALIDATE_TRANSACTION (l_bond_issue_code,
                                     l_coupon_date,
                                     l_ratefix_date,
                                      p_overwrite_type,
		                              l_valid_ok,
			                          l_retcode);
            retcode := greatest(retcode,nvl(l_retcode,0));

            if l_valid_ok then

                XTR_FPS2_P.GET_BENCHMARK_RATE(l_bench_mark,
		                                    l_ratefix_date,
                                            nvl(p_rateset_adj,0),
			                                l_new_rate);

                if l_new_rate is not null then

                    l_new_rate := l_new_rate + (l_margin/100);
                    open C_ONE_ROW_BOND;
    	            fetch C_ONE_ROW_BOND into l_hold;
                    if C_ONE_ROW_BOND%FOUND then   -- update only one row. This is not the latest transaction of this deal number
                        close C_ONE_ROW_BOND;
                        l_count1 := 0;
                        UPDATE_BOND_DETAILS(l_bond_issue_code,l_coupon_date,
                                                l_ratefix_date,l_new_rate,l_count1);
                    else    --update current record as well as subsequent transactions
                        close C_ONE_ROW_BOND;

                        OPEN C_SUBSEQ_BOND_DETAILS;
                        LOOP
                            FETCH C_SUBSEQ_BOND_DETAILS into  bond_info;
                            EXIT when C_SUBSEQ_BOND_DETAILS%notfound;
                            l_valid_ok := TRUE;
                            l_error := 0;
                            l_count1 := 0;
                            VALIDATE_TRANSACTION (l_bond_issue_code,
                                                    bond_info.coupon_date,
                                                    bond_info.rate_fixing_date,
                                                    p_overwrite_type,
		                                            l_valid_ok,
			                                        l_retcode);
                            retcode := greatest(retcode,nvl(l_retcode,0));

                            if l_valid_ok then
                                UPDATE_BOND_DETAILS(l_bond_issue_code,bond_info.coupon_date,
                                                bond_info.rate_fixing_date,l_new_rate,l_count1);
                            end if;

                        END LOOP;
                        CLOSE C_SUBSEQ_BOND_DETAILS;
                    end if;
                    if l_count1 = 0 then
                        retcode := 1;
                        -- No deals/transactions for the bond issue code were found using the specified search criteria.
                        FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_ELIGI_BENCH_BOND');
                        FND_MESSAGE.SET_TOKEN('ISSUE_CODE', l_bond_issue_code);
                        FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
                        l_buf := FND_MESSAGE.GET;
                        fnd_file.put_line(fnd_file.log, l_buf);
                    end if;
                else
	                retcode := 1;
                    FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_BOND_BENCH_RATE');
                    FND_MESSAGE.SET_TOKEN('ISSUE_CODE', l_bond_issue_code);
                    FND_MESSAGE.SET_TOKEN('RATE_DATE', l_ratefix_date);
                    FND_MESSAGE.SET_TOKEN('COUPON_DATE', l_coupon_date);
                    l_buf := FND_MESSAGE.GET;
                    fnd_file.put_line(fnd_file.log, l_buf);
                end if;
            End if; -- valid OK

        END LOOP;
        CLOSE C_GET_ALL_BOND_ISSUES;

        if l_count = 0 then
        retcode := 1;
        -- No deals/transactions were found using the specified search criteria.
        FND_MESSAGE.SET_NAME('XTR', 'XTR_NO_ELIGI_BENCH_ISSUE');
        l_buf := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_buf);
        end if;
    end if;
   EXCEPTION
      WHEN OTHERS THEN
          APP_EXCEPTION.raise_exception;
   END RESET_BOND_BENCHMARK_RATE;

 PROCEDURE VALIDATE_TRANSACTION(p_bond_issue_code        IN VARCHAR2,
                               p_coupon_date     IN DATE,
                               p_ratefix_date   IN DATE,
                               p_overwrite_type IN VARCHAR2,
                               p_valid_ok       OUT NOCOPY BOOLEAN,
			       	p_retcode	OUT NOCOPY NUMBER) AS


 v_out_rec xtr_fps3_p.validation_out_rec;
      v_in_rec xtr_fps3_p.validation_in_rec;
      v_settled BOOLEAN := FALSE;
      v_journaled BOOLEAN := FALSE;
      v_reconciled BOOLEAN := FALSE;
      v_accrued BOOLEAN := FALSE;
       v_count NUMBER := 0;
       l_buf2 VARCHAR2(300);
       l_error NUMBER;

       cursor check_overridden_cpn_amt(p_bond_issue_code VARCHAR2,
				p_coupon_date DATE) is
      select count(*)
      from xtr_deals d, xtr_rollover_transactions rt
      where d.deal_no=rt.deal_number
      and d.bond_issue=p_bond_issue_code
      and rt.maturity_date=p_coupon_date
      and rt.interest<>rt.original_amount
      and rt.interest>0;




 BEGIN

            p_valid_ok := TRUE;
            v_in_rec.deal_type:='BOND';
            v_in_rec.bond_issue_code:=p_bond_issue_code;
            v_in_rec.bond_coupon_date:=p_COUPON_DATE;

            If p_overwrite_type = 'N' then
                open check_overridden_cpn_amt(p_bond_issue_code,p_coupon_date);
                fetch check_overridden_cpn_amt into v_count;
                close check_overridden_cpn_amt;
                if v_count>0 then
                    l_error := 4;
                    p_valid_ok := FALSE;
                End if;
            End if;

            If p_valid_ok then
                xtr_fps3_p.settled_validation(v_in_rec,v_out_rec);
                v_settled:=v_out_rec.yes;
                v_out_rec.yes:=NULL;
                if v_settled then
                    l_error := 1;
                    p_valid_ok := FALSE;
                end if;
            end if;

            If p_valid_ok then
                xtr_fps3_p.journaled_validation(v_in_rec,v_out_rec);
                v_journaled:=v_out_rec.yes;
                v_out_rec.yes:=NULL;
                if v_journaled then
                    l_error := 3;
                    p_valid_ok := FALSE;
                end if;
            end if;

            If p_valid_ok then
                xtr_fps3_p.accrued_validation(v_in_rec,v_out_rec);
                v_accrued:=v_out_rec.yes;
                v_out_rec.yes:=NULL;
                if v_accrued then
                    l_error := 2;
                    p_valid_ok := FALSE;
                end if;
            end if;

    If Not p_valid_ok then

        p_retcode := 1;
	 if l_error = 1 then  -- deal been settled
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_BOND_SETTLE');
            FND_MESSAGE.SET_TOKEN('ISSUE_CODE', p_bond_issue_code);
            FND_MESSAGE.SET_TOKEN('COUPON_DATE', p_coupon_date);
            FND_MESSAGE.SET_TOKEN('RATEFIX_DATE', p_ratefix_date);
            l_buf2 := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf2);
	 elsif l_error = 2 then   -- Accrual has been generated
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_BOND_ACCRUAL');
            FND_MESSAGE.SET_TOKEN('ISSUE_CODE', p_bond_issue_code);
            FND_MESSAGE.SET_TOKEN('COUPON_DATE', p_coupon_date);
            FND_MESSAGE.SET_TOKEN('RATEFIX_DATE', p_ratefix_date);
            l_buf2 := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf2);
      elsif l_error = 3 then   -- journal has been generated
            FND_MESSAGE.SET_NAME('XTR', 'XTR_BENCH_BOND_JOURNAL');
            FND_MESSAGE.SET_TOKEN('ISSUE_CODE', p_bond_issue_code);
            FND_MESSAGE.SET_TOKEN('COUPON_DATE', p_coupon_date);
            FND_MESSAGE.SET_TOKEN('RATEFIX_DATE', p_ratefix_date);
            l_buf2 := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf2);
      elsif l_error = 4 then   -- Coupon amount has been overwritten manually
            FND_MESSAGE.SET_NAME('XTR', 'XTR_COUPON_AMOUNT_OVERWRITTEN');
            FND_MESSAGE.SET_TOKEN('ISSUE_CODE', p_bond_issue_code);
            FND_MESSAGE.SET_TOKEN('COUPON_DATE', p_coupon_date);
            FND_MESSAGE.SET_TOKEN('RATEFIX_DATE', p_ratefix_date);
            l_buf2 := FND_MESSAGE.GET;
            fnd_file.put_line(fnd_file.log, l_buf2);

     End if;

   End if;




 END VALIDATE_TRANSACTION;

 PROCEDURE UPDATE_COUPON_DETAILS(p_bond_issue_code IN VARCHAR2,
                                 p_coupon_date IN DATE,
                                 p_new_rate IN NUMBER,
                                 p_deal_number IN NUMBER,
                                 p_transaction_number IN NUMBER,
                                 p_update_type IN VARCHAR2) AS

   CURSOR C_GET_SEQ_TRANSACTIONS IS
   SELECT maturity_date,transaction_number
   FROM XTR_ROLLOVER_TRANSACTIONS
   WHERE deal_number = p_deal_number
   AND transaction_number >= p_transaction_number
   ORDER BY transaction_number;

   l_coupon_date DATE;
   l_trans_no NUMBER;




 BEGIN
 IF p_update_type = 'SINGLE' THEN
    UPDATE XTR_ROLLOVER_TRANSACTIONS
         SET INTEREST_RATE=P_NEW_RATE,
                UPDATED_ON = SYSDATE,
                UPDATED_BY = fnd_global.user_id
         WHERE STATUS_CODE = 'CURRENT'
         AND MATURITY_DATE = P_COUPON_DATE
         AND DEAL_NUMBER = P_DEAL_NUMBER;

     UPDATE_COUPON_AMOUNT(p_bond_issue_code,p_deal_number,p_transaction_number);


 ELSE
    OPEN C_GET_SEQ_TRANSACTIONS;
   LOOP
      FETCH C_GET_SEQ_TRANSACTIONS into  l_coupon_date,l_trans_no;
      EXIT when C_GET_SEQ_TRANSACTIONS%notfound;

      UPDATE XTR_ROLLOVER_TRANSACTIONS
         SET INTEREST_RATE=P_NEW_RATE,
                UPDATED_ON = SYSDATE,
                UPDATED_BY = fnd_global.user_id
         WHERE STATUS_CODE = 'CURRENT'
         AND MATURITY_DATE = l_COUPON_DATE
         AND DEAL_NUMBER = P_DEAL_NUMBER;

         UPDATE_COUPON_AMOUNT(p_bond_issue_code,p_deal_number,l_trans_no);

   END LOOP;
   CLOSE C_GET_SEQ_TRANSACTIONS;
  END IF;
 END UPDATE_COUPON_DETAILS;

 PROCEDURE UPDATE_COUPON_AMOUNT(p_bond_issue_code IN VARCHAR2,
                                 p_deal_number IN NUMBER,
                                 p_transaction_number IN NUMBER
                                 ) AS

      v_new_cpn_amt NUMBER;
      v_tax_amt NUMBER;
      v_hce_amt NUMBER;
      v_tax_diff NUMBER;
      v_new_cpn_amt_dda NUMBER;
      v_out_rec xtr_mm_covers.CalcBondCpnAmt_out_rec;
      v_in_rec xtr_mm_covers.CalcBondCpnAmt_in_rec;
      v_prncpl_ctype  xtr_tax_brokerage_setup.calc_type%TYPE;
      v_prncpl_method  xtr_tax_brokerage_setup.tax_settle_method%TYPE;
      v_income_ctype   xtr_tax_brokerage_setup.calc_type%TYPE;
      v_income_method  xtr_tax_brokerage_setup.tax_settle_method%TYPE;

      CURSOR C_GET_CURR_RELATED_TRANS(p_deal_number NUMBER,
				p_transaction_number NUMBER) is
         select rt.deal_number,rt.transaction_number,rt.tax_settled_reference,
         rt.currency,rt.deal_subtype,rt.tax_code,rt.tax_amount
         from xtr_rollover_transactions rt
         where rt.status_code='CURRENT'
	     and rt.deal_number = p_deal_number
         and rt.transaction_number = p_transaction_number
         and rt.deal_subtype in ('ISSUE','SHORT','BUY')
         order by rt.deal_number,rt.transaction_number;

      curr_trans_info c_get_curr_related_trans%ROWTYPE;

      cursor GET_HCE(p_amt NUMBER, p_ccy VARCHAR2) is
         select nvl(round(p_amt/round(hce_rate,5),
         rounding_factor),0)
         from XTR_MASTER_CURRENCIES_V
         where CURRENCY = p_ccy;




 BEGIN

 open c_get_curr_related_trans(p_deal_number,p_transaction_number);
      LOOP
         FETCH c_get_curr_related_trans into curr_trans_info;
         EXIT when c_get_curr_related_trans%NOTFOUND or
		c_get_curr_related_trans%NOTFOUND is null;

         v_in_rec.deal_no := curr_trans_info.deal_number;
         v_in_rec.transaction_no := curr_trans_info.transaction_number;
         xtr_mm_covers.calc_bond_coupon_amt(v_in_rec,v_out_rec);
         v_new_cpn_amt:=v_out_rec.coupon_amt;
         v_tax_amt:=v_out_rec.coupon_tax_amt;
         --calc interest_hce
         OPEN GET_HCE(v_new_cpn_amt,curr_trans_info.currency);
        FETCH GET_HCE INTO V_HCE_AMT;
        CLOSE GET_HCE;
         --find out tax settlement method
         if curr_trans_info.tax_code is not null then
            xtr_fps2_p.GET_SETTLE_METHOD (null,
                             v_prncpl_ctype,
                             v_prncpl_method,
                             curr_trans_info.tax_code,
                             v_income_ctype,
                             v_income_method);
         end if;
         --update XTR_ROLLOVER_TRANSACTIONS
         UPDATE xtr_rollover_transactions
            set interest=v_new_cpn_amt,interest_hce=v_hce_amt,
		tax_amount=v_tax_amt,original_amount=v_new_cpn_amt,
                UPDATED_ON = sysdate,
                UPDATED_BY = fnd_global.user_id
            where deal_number=curr_trans_info.deal_number
            and transaction_number=curr_trans_info.transaction_number;
         --update XTR_DEAL_DATE_AMOUNTS
         if nvl(v_income_method,'NUL')='NIA' then
            v_new_cpn_amt_dda:=v_new_cpn_amt-v_tax_amt;
         else
            v_new_cpn_amt_dda:=v_new_cpn_amt;
         end if;
         UPDATE xtr_deal_date_amounts
            set amount=nvl(v_new_cpn_amt_dda,0),
            cashflow_amount=decode(curr_trans_info.deal_subtype,'BUY',1,-1)*nvl(v_new_cpn_amt_dda,0),
                UPDATED_ON = sysdate,
                UPDATED_BY = fnd_global.user_id
            where deal_type='BOND'
            and deal_number=curr_trans_info.deal_number
            and transaction_number=curr_trans_info.transaction_number
            and amount_type='COUPON' and date_type='COUPON';
         --update the TAX DDA
         if curr_trans_info.tax_code is not null then
            if nvl(v_income_method,'NUL')='NIA' then
               UPDATE xtr_deal_date_amounts
                  set amount=v_tax_amt,
                      UPDATED_ON = sysdate,
                      UPDATED_BY = fnd_global.user_id
                  where deal_type='BOND'
                  and deal_number=curr_trans_info.deal_number
                  and transaction_number=curr_trans_info.transaction_number
                  and amount_type='TAX' and date_type='INCUR';
            else
               if curr_trans_info.tax_settled_reference is not null then
                  v_tax_diff:=curr_trans_info.tax_amount-v_tax_amt;
                  --Only pass the differences to UPDATE_TAX_DDA/EXP function
                  --since tax can be consolidated.
                  xtr_fps2_p.UPDATE_TAX_EXP (curr_trans_info.tax_settled_reference,
			v_tax_diff);
                  xtr_fps2_p.UPDATE_TAX_DDA (curr_trans_info.tax_settled_reference,
			v_tax_diff);
               end if;
            end if;
         end if;
  end loop;
      close c_get_curr_related_trans;

 END UPDATE_COUPON_AMOUNT;


 PROCEDURE UPDATE_BOND_DETAILS(p_bond_issue_code IN VARCHAR2,
                                 p_coupon_date IN DATE,
                                 p_ratefix_date DATE,
                                 p_new_rate IN NUMBER,
                                 p_count OUT NOCOPY NUMBER) AS

  CURSOR C_GET_RELATED_TRANS(p_bond_issue_code VARCHAR2,
				p_coupon_date DATE) is
         select rt.deal_number,rt.transaction_number
         from xtr_rollover_transactions rt, xtr_deals d
         where rt.status_code='CURRENT'
	 and d.deal_no=rt.deal_number
         and rt.deal_subtype in ('ISSUE','SHORT','BUY')
         and d.bond_issue=p_bond_issue_code
         and rt.maturity_date=p_coupon_date
         order by rt.deal_number,rt.transaction_number;

      trans_info c_get_related_trans%ROWTYPE;
      l_buf1 VARCHAR2(300);
      -- Start Fix not to show transactions with zero amount
      CURSOR C_GET_BALANCE_AMOUNT (p_deal NUMBER) IS
        SELECT maturity_balance_amount
        FROM XTR_DEALS
        WHERE DEAL_NO = p_deal;

        l_balance_amount NUMBER;

     CURSOR C_GET_MAX_RESALE_DATE(p_deal_no NUMBER) IS
        SELECT max(cross_ref_start_date)
        FROM XTR_BOND_ALLOC_DETAILS
        WHERE DEAL_NO = p_deal_no;

        l_max_resale_date DATE;
        l_show_message NUMBER := 1;
-- End Added not to show the Transactions with 0 amount

    BEGIN
      p_count := 0;
      UPDATE XTR_BOND_COUPON_DATES
        SET RATE = p_new_rate
        WHERE BOND_ISSUE_CODE = p_bond_issue_code
        AND COUPON_DATE = p_coupon_date;

        OPEN C_GET_RELATED_TRANS(p_bond_issue_code,p_coupon_date);
        LOOP
         FETCH C_GET_RELATED_TRANS into trans_info;
         EXIT when C_GET_RELATED_TRANS%NOTFOUND or
		C_GET_RELATED_TRANS%NOTFOUND is null;
         p_count := p_count +1;

         UPDATE_COUPON_DETAILS(p_bond_issue_code,
                                p_coupon_date,
                                p_new_rate,
                                trans_info.deal_number,
                                trans_info.transaction_number,
                                'SINGLE');
-- Below fix added not to show the update of transactions with zero coupon amount
        l_show_message := 1;
         OPEN C_GET_BALANCE_AMOUNT(trans_info.deal_number);
         FETCH C_GET_BALANCE_AMOUNT INTO l_balance_amount;
         CLOSE C_GET_BALANCE_AMOUNT;



         IF nvl(l_balance_amount,0) = 0 THEN
            OPEN C_GET_MAX_RESALE_DATE(trans_info.deal_number);
            FETCH C_GET_MAX_RESALE_DATE into l_max_resale_date;
            CLOSE C_GET_MAX_RESALE_DATE;
            If p_coupon_date > l_max_resale_date then

                            l_show_message := 0;

            End If;
         END IF;

If l_show_message = 1 then

	        FND_MESSAGE.SET_NAME('XTR', 'XTR_UPDATE_BENCH_RATE_BOND');
	        FND_MESSAGE.SET_TOKEN('BENCH_RATE', p_new_rate);
	        FND_MESSAGE.SET_TOKEN('ISSUE_CODE', p_bond_issue_code);
	        FND_MESSAGE.SET_TOKEN('DEAL_NO', trans_info.deal_number);
	        FND_MESSAGE.SET_TOKEN('TRANS_NO', trans_info.transaction_number);
	        FND_MESSAGE.SET_TOKEN('RATE_DATE', p_ratefix_date);
                l_buf1 := FND_MESSAGE.GET;
   	        fnd_file.put_line(fnd_file.log, l_buf1);
End If;

    end loop;
      close C_GET_RELATED_TRANS;


    END UPDATE_BOND_DETAILS;



END;

/
