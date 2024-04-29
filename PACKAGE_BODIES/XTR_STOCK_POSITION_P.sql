--------------------------------------------------------
--  DDL for Package Body XTR_STOCK_POSITION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_STOCK_POSITION_P" as
/* $Header: xtrsposb.pls 120.1 2005/11/23 12:26:15 eaggarwa noship $ */
/*  This files conatins three procedure to insert/update/delete rows from the
xtr_position_history table for the 'STOCK' deal.

1. Maintain_stk_position_history is called from the form when the
 'BUY' stock deal is created or the deal status is set to cancelled

2. Snapshot_cost_of_funds fetches all the 'BUY' stock deals with status code as
current and call the procedure snapshot_stk_position_history. This procedure is
called from the form when the sell deal is created or when the concurrent
program -update average rates is run.

When this program is called from the 'FORM' the deal number is passed for which
the resale is being created and when called through the CP the deal number is
null.

3.Snapshot_stk_position_history recalculates the values and then insert/update
or delete rows from the xtr_postion_history table. This procedure is called by
snapshot_stk_cost_of_funds

*/


PROCEDURE MAINTAIN_STK_POSITION_HISTORY(
 P_START_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_INTEREST                     IN NUMBER,
 P_ACTION                       IN VARCHAR2
  ) as



 L_REF_DATE 		DATE;
 L_END_DATE	        DATE;
 L_SYS_DATE		   DATE :=trunc(sysdate);
 L_HCE_RATE		NUMBER;
 L_FAC 			NUMBER;
 L_HCE_BASE_REF_AMOUNT	NUMBER;
 L_BASE_REF_AMOUNT 	NUMBER;
 L_DAILY_INT   NUMBER;
 L_HCE_INT    NUMBER;
 L_DEAL_SUBTYPE		XTR_POSITION_HISTORY.deal_subtype%TYPE;
 T_AS_AT_DATE		DBMS_SQL.DATE_TABLE;
 L_TRANSACTION_RATE	NUMBER;

  --
 cursor HCE is
  select s.HCE_RATE,s.ROUNDING_FACTOR
   from XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY = P_CURRENCY;


begin
  open HCE;
  fetch HCE into L_HCE_RATE,L_FAC;
  close HCE;

/***********************/
/* Common Calculations */
/***********************/
       L_REF_DATE :=nvl(P_START_DATE,L_SYS_DATE);
       L_END_DATE := L_SYS_DATE;
       L_HCE_BASE_REF_AMOUNT :=round(P_BASE_REF_AMOUNT/L_HCE_RATE,L_FAC);
       L_BASE_REF_AMOUNT :=P_BASE_REF_AMOUNT;
       L_TRANSACTION_RATE := P_TRANSACTION_RATE;
       L_DAILY_INT := 0;
	   L_HCE_INT := 0;


/**************/
/* INSERT     */
/**************/
  if P_ACTION='INSERT' and P_STATUS_CODE='CURRENT' then

       L_DEAL_SUBTYPE := P_DEAL_SUBTYPE;
       L_BASE_REF_AMOUNT := P_BASE_REF_AMOUNT;


       FOR i in 1..(L_END_DATE-L_REF_DATE) LOOP
           T_AS_AT_DATE(i) := L_REF_DATE+i-1;
       END LOOP;


       forall i in 1..T_AS_AT_DATE.COUNT
           insert into XTR_POSITION_HISTORY(
             AS_AT_DATE,
             DEAL_TYPE,
             DEAL_NUMBER,
             TRANSACTION_NUMBER,
             COMPANY_CODE,
             CPARTY_CODE,
             DEAL_SUBTYPE,
             PRODUCT_TYPE,
             PORTFOLIO_CODE,
             CURRENCY,
             CONTRA_CCY,
             CURRENCY_COMBINATION,
             YEAR_CALC_TYPE,
             ACCOUNT_NO,
             BASE_REF_AMOUNT,
             HCE_BASE_REF_AMOUNT,
             TRANSACTION_RATE,
             BASE_RATE,
	     INTEREST,
	     HCE_INTEREST)
          values(
             T_AS_AT_DATE(i),
             P_DEAL_TYPE,
             P_DEAL_NUMBER,
             P_TRANSACTION_NUMBER,
             P_COMPANY_CODE,
             P_CPARTY_CODE,
             L_DEAL_SUBTYPE,
             P_PRODUCT_TYPE,
             P_PORTFOLIO_CODE,
             P_CURRENCY,
             P_CONTRA_CCY,
             P_CURRENCY_COMBINATION,
             P_YEAR_CALC_TYPE,
             P_ACCOUNT_NO,
             L_BASE_REF_AMOUNT,
             L_HCE_BASE_REF_AMOUNT,
             L_TRANSACTION_RATE,
             P_BASE_RATE,
             L_DAILY_INT,
	     L_HCE_INT);




/**************/
/* UPDATE     */
/**************/
  elsif  P_ACTION='UPDATE' and P_STATUS_CODE= 'CANCELLED' then

          delete from XTR_POSITION_HISTORY
          where AS_AT_DATE >= L_REF_DATE
          and DEAL_TYPE = P_DEAL_TYPE
          and DEAL_NUMBER = P_DEAL_NUMBER;



/**************/
/* DELETE     */
/**************/
/* this function is not available for the stock deals */


end if;

end MAINTAIN_STK_POSITION_HISTORY;


PROCEDURE SNAPSHOT_STK_POSITION_HISTORY(
 P_AS_AT_DATE                   IN DATE,
 P_DEAL_NUMBER                  IN NUMBER,
 P_TRANSACTION_NUMBER           IN NUMBER,
 P_COMPANY_CODE                 IN VARCHAR2,
 P_CURRENCY                     IN VARCHAR2,
 P_DEAL_TYPE                    IN VARCHAR2,
 P_DEAL_SUBTYPE                 IN VARCHAR2,
 P_PRODUCT_TYPE                 IN VARCHAR2,
 P_PORTFOLIO_CODE               IN VARCHAR2,
 P_CPARTY_CODE                  IN VARCHAR2,
 P_CONTRA_CCY                   IN VARCHAR2,
 P_CURRENCY_COMBINATION         IN VARCHAR2,
 P_ACCOUNT_NO                   IN VARCHAR2,
 P_TRANSACTION_RATE             IN NUMBER,
 P_YEAR_CALC_TYPE               IN VARCHAR2,
 P_BASE_REF_AMOUNT              IN NUMBER,
 P_BASE_RATE                    IN NUMBER,
 P_STATUS_CODE                  IN VARCHAR2,
 P_START_DATE			IN DATE,
 P_INTEREST                     IN NUMBER,
 P_START_AMOUNT         IN NUMBER

) as

--
 L_HCE_BASE_REF_AMOUNT	NUMBER;
 L_REF_DATE 		DATE;
 L_END_DATE	        DATE;
 L_AS_AT_DATE  		DATE;
 L_PROC_DATE		DATE;
 L_RESALE_DATE		DATE;
 L_LAST_PROC_DATE       DATE;
 L_EARLY_START_DATE     DATE;
 L_ROWID         	VARCHAR2(30);
 L_AMOUNT		NUMBER;
 L_HCE_RATE		NUMBER;
 L_FAC 			NUMBER;
 L_LAST_RESALE_DATE     DATE:= NULL;
 L_BASE_REF_AMOUNT      NUMBER;
 L_TILL_DATE  DATE;
 l_complete_resale varchar2(1);
 l_remaining_quantity number;
 l_transaction_rate number;
 l_price_per_share number;
 l_cross_ref_start_date Date;
/*************************/
/* For DEAL_TYPE 'STOCK'  */
/*************************/

 cursor HCE is
  select s.HCE_RATE,s.ROUNDING_FACTOR
  from XTR_MASTER_CURRENCIES_V s
  where s.CURRENCY = P_CURRENCY;



 cursor GET_PRV_ROWS_STOCK(V_DEAL_TYPE  VARCHAR2,
                          V_DEAL_NUMBER NUMBER) is
    select max(AS_AT_DATE + 1)
    from XTR_POSITION_HISTORY
    where DEAL_TYPE = V_DEAL_TYPE
    and DEAL_NUMBER = V_DEAL_NUMBER;

 cursor STOCK_LAST_PROC_DATE(V_AS_AT_DATE DATE,
			    V_DEAL_NUMBER NUMBER)is
    select cross_ref_start_date
    from xtr_stock_alloc_details
    where deal_no = V_DEAL_NUMBER
    and CROSS_REF_START_DATE <= V_AS_AT_DATE
    and avg_rate_last_processed is null
    order by cross_ref_start_date;


 cursor get_stock_resale ( V_AS_AT_DATE DATE) is
     Select min(remaining_quantity), max(cross_ref_start_date)
     From XTR_STOCK_ALLOC_DETAILS
     Where deal_no = P_DEAL_NUMBER
     and cross_ref_start_date <= V_AS_AT_DATE;


 cursor CHK_LOCK_ROWS_STOCK(V_AS_AT_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER) is
    select rowid
    from XTR_POSITION_HISTORY
    where AS_AT_DATE = V_AS_AT_DATE
    and DEAL_TYPE = V_DEAL_TYPE
    and DEAL_NUMBER = V_DEAL_NUMBER
    for update of BASE_REF_AMOUNT NOWAIT;


BEGIN

   open HCE;
   fetch HCE into L_HCE_RATE,L_FAC;
   close HCE;

   L_BASE_REF_AMOUNT := P_BASE_REF_AMOUNT;
   L_HCE_BASE_REF_AMOUNT :=round(P_BASE_REF_AMOUNT/L_HCE_RATE,L_FAC);
   l_transaction_rate := P_TRANSACTION_RATE;



   l_complete_resale := 'N';

   Open get_stock_resale(p_as_at_date);
   Fetch get_stock_resale into l_remaining_quantity,l_last_resale_date;
      If get_stock_resale%FOUND then

           If nvl(l_remaining_quantity, -1) = 0  then  -- total resale
               Delete from XTR_POSITION_HISTORY
               Where deal_number = P_DEAL_NUMBER
               And as_at_date >= l_last_resale_date;
               l_complete_resale := 'Y';
          end if;

          close get_stock_resale;

      Else
         close get_stock_resale;

      End if;

   open GET_PRV_ROWS_STOCK(P_DEAL_TYPE,P_DEAL_NUMBER);
   fetch GET_PRV_ROWS_STOCK into L_AS_AT_DATE;

    if GET_PRV_ROWS_STOCK%FOUND then  -- deal no has some data in PH

          open STOCK_LAST_PROC_DATE(L_AS_AT_DATE,P_DEAL_NUMBER);
          fetch STOCK_LAST_PROC_DATE into L_RESALE_DATE;
              if STOCK_LAST_PROC_DATE%FOUND then
                    if  L_RESALE_DATE < nvl(L_AS_AT_DATE, sysdate) then
                        L_AS_AT_DATE := L_RESALE_DATE;
                    end if;
	                close STOCK_LAST_PROC_DATE;
              else
                    close STOCK_LAST_PROC_DATE;
                    l_as_at_date := p_start_date;  -- incase no rows exist in position history
              end if;

              close GET_PRV_ROWS_STOCK;
    else
	      close GET_PRV_ROWS_STOCK;

    end if;


      L_AS_AT_DATE :=nvl(L_AS_AT_DATE,P_AS_AT_DATE);

      if l_complete_resale = 'Y' then
           l_till_date := l_last_resale_date -1 ;
      ELSE
           l_till_date := p_as_at_date;
      end if;


     WHILE L_AS_AT_DATE <= L_TILL_DATE LOOP



        L_ROWID := NULL;

        open CHK_LOCK_ROWS_STOCK(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
        fetch CHK_LOCK_ROWS_STOCK into L_ROWID;
        close CHK_LOCK_ROWS_STOCK;


        Open get_stock_resale(l_as_at_date);
        Fetch get_stock_resale into l_remaining_quantity,l_cross_ref_start_date;


        if get_stock_resale%found and l_cross_ref_start_date is not null then

              select price_per_share into
              l_price_per_share
              FROM xtr_stock_alloc_details a
              WHERE deal_no = P_DEAL_NUMBER
              and cross_ref_start_date = l_cross_ref_start_date
              and cross_ref_no = ( select max(cross_ref_no)   --  multiple sales on the same date
                                   FROM xtr_stock_alloc_details
                                   WHERE deal_no = a.deal_no
                                   and cross_ref_start_date = l_cross_ref_start_date);

               l_transaction_rate := l_price_per_share;
               L_BASE_REF_AMOUNT := l_remaining_quantity * l_price_per_share;
	       L_HCE_BASE_REF_AMOUNT := round(L_BASE_REF_AMOUNT/L_HCE_RATE,L_FAC);
               close get_stock_resale;
         else
             close get_stock_resale;
         end if;




      /*========================================*/
      /* Insert or Update position history table */
      /*========================================*/
       if L_ROWID is not null then
            update XTR_POSITION_HISTORY
              set COMPANY_CODE = P_COMPANY_CODE,
                CPARTY_CODE  = P_CPARTY_CODE,
                DEAL_SUBTYPE = P_DEAL_SUBTYPE,
                PRODUCT_TYPE = P_PRODUCT_TYPE,
                PORTFOLIO_CODE = P_PORTFOLIO_CODE,
                CURRENCY = P_CURRENCY,
                CONTRA_CCY = P_CONTRA_CCY,
                CURRENCY_COMBINATION = P_CURRENCY_COMBINATION,
                YEAR_CALC_TYPE = P_YEAR_CALC_TYPE,
                ACCOUNT_NO = P_ACCOUNT_NO,
                BASE_REF_AMOUNT = l_BASE_REF_AMOUNT,
                HCE_BASE_REF_AMOUNT = L_HCE_BASE_REF_AMOUNT,
                BASE_RATE = P_BASE_RATE,
                TRANSACTION_RATE = l_TRANSACTION_RATE
                where rowid=l_rowid;
       else

         -- insert new row
           insert into XTR_POSITION_HISTORY(
             AS_AT_DATE,
             DEAL_TYPE,
             DEAL_NUMBER,
             TRANSACTION_NUMBER,
             COMPANY_CODE,
             CPARTY_CODE,
             DEAL_SUBTYPE,
             PRODUCT_TYPE,
             PORTFOLIO_CODE,
             CURRENCY,
             CONTRA_CCY,
             CURRENCY_COMBINATION,
             YEAR_CALC_TYPE,
             ACCOUNT_NO,
             BASE_REF_AMOUNT,
             HCE_BASE_REF_AMOUNT,
             TRANSACTION_RATE,
             BASE_RATE,
	         INTEREST,
	         HCE_INTEREST)
         values(
             L_AS_AT_DATE,
             P_DEAL_TYPE,
             P_DEAL_NUMBER,
             P_TRANSACTION_NUMBER,
             P_COMPANY_CODE,
             P_CPARTY_CODE,
             P_DEAL_SUBTYPE,
             P_PRODUCT_TYPE,
             P_PORTFOLIO_CODE,
             P_CURRENCY,
             P_CONTRA_CCY,
             P_CURRENCY_COMBINATION,
             P_YEAR_CALC_TYPE,
     	     P_ACCOUNT_NO,
             abs(nvl(L_BASE_REF_AMOUNT, P_BASE_REF_AMOUNT)),
             abs(L_HCE_BASE_REF_AMOUNT),
             L_TRANSACTION_RATE,
             P_BASE_RATE,
	         0,
	         0);

         end if;

  if P_DEAL_TYPE = 'STOCK' and l_remaining_quantity is not null then
	     Update XTR_STOCK_ALLOC_DETAILS
	     set avg_rate_last_processed = greatest(nvl(avg_rate_last_processed,
L_AS_AT_DATE),
					   L_AS_AT_DATE)
	     where deal_no = P_DEAL_NUMBER;
  end if;

  L_AS_AT_DATE :=L_AS_AT_DATE +1;
  END LOOP;



exception
 when app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_ROWS_STOCK%ISOPEN then
     close CHK_LOCK_ROWS_STOCK;
  end if;
 raise app_exceptions.RECORD_LOCK_EXCEPTION;


end SNAPSHOT_STK_POSITION_HISTORY;




PROCEDURE SNAPSHOT_STK_COST_OF_FUNDS(
                             errbuf	OUT NOCOPY VARCHAR2,
                	         retcode OUT NOCOPY NUMBER,
                             p_deal_number IN NUMBER default NULL) as

 l_run_date date := sysdate;
 l_date     date;
--
  L_COMPANY_CODE		VARCHAR2(7);
  L_CURRENCY			VARCHAR2(15);
  L_DEAL_SUBTYPE		VARCHAR2(7);
  L_PRODUCT_TYPE		VARCHAR2(10);
  L_PORTFOLIO_CODE		VARCHAR2(10);
  L_CPARTY_CODE			VARCHAR2(7);
  L_AMOUNT			NUMBER;
  L_CONTRA_CCY			VARCHAR2(15);
  L_CURRENCY_COMBINATION 	VARCHAR2(31);
  L_TRANSACTION_RATE		NUMBER;
  L_YEAR_CALC_TYPE 		VARCHAR2(15);
  L_ACCOUNT_NO			VARCHAR2(50);
  L_CALC_BASIS 			VARCHAR2(15);
  L_YEAR_BASIS			NUMBER;
  L_DEAL_NUMBER			NUMBER;
  L_TRANSACTION_NUMBER          NUMBER;
  L_CALC_TYPE			VARCHAR2(15);
  L_TOTAL_RESALE		NUMBER := NULL;
  L_START_DATE                  DATE;
  L_cross_ref_start_date        DATE;
  L_remaining_quantity  NUMBER;


 cursor get_stock_deals is
 select a.deal_no deal_number,
        1 transaction_number,
        a.status_code status_code,
        a.company_code,
        a.cparty_code,
        a.deal_type,
        a.deal_subtype,
        a.currency,
        a.currency_buy,
        a.currency_sell,
        a.product_type,
        a.portfolio_code,
        a.year_calc_type,
        a.year_basis,
        a.interest_rate interest_rate,
        a.capital_price transaction_rate,
        a.base_rate base_rate,
        a.calc_basis,
        a.start_date,
        a.value_date,
        a.option_commencement,
        a.expiry_date,
        a.maturity_date,
        a.maturity_account_no account_no,
        a.start_amount base_amount,
        a.settle_amount second_amount,
	    a.maturity_amount,
        a.start_amount,
        a.day_count_type
 from XTR_DEALS a
 where a.deal_type ='STOCK'
 and a.deal_subtype in ('BUY')
 and a.status_code ='CURRENT'
 and a.start_date <=l_date
 and a.deal_no = nvl(p_deal_number, a.deal_no);


 D get_stock_deals%rowtype;

 cursor get_stock_total_resale is
     Select min(remaining_quantity), max(cross_ref_start_date)
     From XTR_STOCK_ALLOC_DETAILS
     Where deal_no = D.DEAL_Number
     and cross_ref_start_date <= L_DATE;

BEGIN


   l_date :=trunc(sysdate)-1;

   open get_stock_deals;
   LOOP
   fetch get_stock_deals into D;
   exit WHEN get_stock_deals%NOTFOUND;



   OPEN get_stock_total_resale;
   FETCH get_stock_total_resale into
l_remaining_quantity,l_cross_ref_start_date;
     if nvl(l_remaining_quantity,0)= 0  then
    	Update XTR_STOCK_ALLOC_DETAILS
        Set avg_rate_last_processed = L_DATE
        where deal_no = d.deal_number
        and cross_ref_start_date = l_cross_ref_start_date;
	    close get_stock_total_resale;
     else
        CLOSE get_stock_total_resale;
     end if;

   if d.deal_type  = 'STOCK' then
     XTR_STOCK_POSITION_P.SNAPSHOT_STK_POSITION_HISTORY(
        P_AS_AT_DATE                  => L_DATE,
        P_DEAL_NUMBER                 => D.DEAL_NUMBER,
        P_TRANSACTION_NUMBER          => D.TRANSACTION_NUMBER,
        P_COMPANY_CODE                => D.COMPANY_CODE,
        P_CURRENCY                    => D.CURRENCY,
        P_DEAL_TYPE                   => D.DEAl_TYPE,
        P_DEAL_SUBTYPE                => D.DEAL_SUBTYPE,
        P_PRODUCT_TYPE                => D.PRODUCT_TYPE,
        P_PORTFOLIO_CODE              => D.PORTFOLIO_CODE,
        P_CPARTY_CODE                 => D.CPARTY_CODE,
        P_CONTRA_CCY                  => null,
        P_CURRENCY_COMBINATION        => null,
        P_ACCOUNT_NO                  => D.ACCOUNT_NO,
        P_TRANSACTION_RATE            => D.TRANSACTION_RATE,
        P_YEAR_CALC_TYPE              => D.YEAR_CALC_TYPE,
        P_BASE_REF_AMOUNT             => D.BASE_AMOUNT,
        P_BASE_RATE                   => D.BASE_RATE,
        P_STATUS_CODE		      => D.STATUS_CODE,
	    P_START_DATE		      => D.START_DATE,
	    P_INTEREST                    => NULL,
        P_START_AMOUNT                => D.START_AMOUNT
	   );
    end if;
  END LOOP;


 end SNAPSHOT_STK_COST_OF_FUNDS;


end XTR_STOCK_POSITION_P;


/
