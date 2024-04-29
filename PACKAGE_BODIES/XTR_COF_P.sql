--------------------------------------------------------
--  DDL for Package Body XTR_COF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_COF_P" as
/* $Header: xtrcostb.pls 120.12 2005/10/24 10:47:31 eaggarwa ship $ */
----------------------------------------------------------------------------------------------------------------
PROCEDURE SET_CURR_IG_DEAL_DETAILS(
 P_DEAL_NUMBER		IN XTR_INTERGROUP_TRANSFERS.DEAL_NUMBER%TYPE,
 P_TRANSACTION_NUMBER	IN XTR_INTERGROUP_TRANSFERS.TRANSACTION_NUMBER%TYPE,
 P_MATURITY_DATE	IN DATE) IS
BEGIN
  g_ig_curr_deal_number := p_deal_number;
  g_ig_curr_transaction_number := p_transaction_number;
  g_ig_curr_maturity_date := p_maturity_date;
END SET_CURR_IG_DEAL_DETAILS;

PROCEDURE GET_CURR_IG_DEAL_DETAILS(
 P_DEAL_NUMBER		IN XTR_INTERGROUP_TRANSFERS.DEAL_NUMBER%TYPE,
 P_TRANSACTION_NUMBER	IN XTR_INTERGROUP_TRANSFERS.TRANSACTION_NUMBER%TYPE,
 P_MATURITY_DATE	OUT NOCOPY DATE) IS
BEGIN
  if (p_deal_number = g_ig_curr_deal_number and
      p_transaction_number = g_ig_curr_transaction_number) then
    p_maturity_date := g_ig_curr_maturity_date;
    g_ig_curr_maturity_date := null;
    g_ig_curr_deal_number := null;
    g_ig_curr_transaction_number := null;
  end if;
END GET_CURR_IG_DEAL_DETAILS;

PROCEDURE MAINTAIN_POSITION_HISTORY(
 P_START_DATE                   IN DATE,
 P_MATURITY_DATE                IN DATE,
 P_OTHER_DATE                   IN DATE,
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
 P_MATURITY_AMOUNT              IN NUMBER,
 P_START_AMOUNT                 IN NUMBER,
 P_CALC_BASIS                   IN VARCHAR2,
 P_CALC_TYPE			IN VARCHAR2,
 P_ACTION                       IN VARCHAR2,
 P_DAY_COUNT_TYPE               IN VARCHAR2,
 P_FIRST_TRANS_FLAG             IN VARCHAR2
  ) as
---
 cursor HCE is
  select s.HCE_RATE,s.ROUNDING_FACTOR
   from XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY = P_CURRENCY;

 L_HCE_BASE_REF_AMOUNT	NUMBER;
 L_REF_DATE 		DATE;
 L_END_DATE	        DATE;
 L_SYS_DATE		DATE :=trunc(sysdate);
 L_AS_AT_DATE  		DATE;
 L_ROWID         	VARCHAR2(30);
 L_AMOUNT		NUMBER;
 L_HCE_RATE		NUMBER;
 L_FAC 			NUMBER;
 L_BASE_REF_AMOUNT 	NUMBER;
 L_YEAR_BASIS		NUMBER;
 L_NO_OF_DAYS		NUMBER;
 L_NO_OF_DAYS_IN	NUMBER;
 L_NO_OF_DAYS_OUT       NUMBER;
 L_YEAR_BASIS_IN 	NUMBER;
 L_YEAR_BASIS_OUT	NUMBER;
 L_YIELD_RATE           NUMBER;
 L_CALC_BASIS           XTR_DEALS.calc_basis%TYPE;
 L_CALC_TYPE		XTR_BOND_ISSUES.calc_type%TYPE;
 L_COUPON_RATE		NUMBER;
 L_MATURITY_AMT		NUMBER;
 L_CONSIDERATION   	NUMBER;
 L_CONVERT_RATE		NUMBER;
 L_CONVERT_TYPE         CONSTANT VARCHAR2(15) := 'ACTUAL365';
 L_TOTAL_INT		NUMBER;
 L_DAILY_INT		NUMBER;
 L_HCE_INT		NUMBER;
 L_NEXT_YEAR		DATE;

 L_DEAL_SUBTYPE		XTR_POSITION_HISTORY.deal_subtype%TYPE;
 L_TRANSACTION_RATE	NUMBER;
 T_AS_AT_DATE		DBMS_SQL.DATE_TABLE;
 T_AS_AT_DATE_INS	DBMS_SQL.DATE_TABLE;
 T_ROWID		DBMS_SQL.VARCHAR2_TABLE;
 N_COUNTER		NUMBER;
 N_AS_AT_DATE_CP	NUMBER;
 N_AS_AT_DATE_INS_CP	NUMBER;

/*********************************/
/* For DEAL_TYPE in('NI','ONC')  */
/*********************************/
 cursor CHK_LOCK_ROWS_ONC(V_START_DATE DATE,
                     V_END_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER,
                     V_TRANSACTION_NUMBER NUMBER,
                     V_COMPANY_CODE VARCHAR2) is
    select rowid, as_at_date
      from XTR_POSITION_HISTORY
       where AS_AT_DATE >= V_START_DATE
         and AS_AT_DATE < V_END_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER
         and TRANSACTION_NUMBER = V_TRANSACTION_NUMBER
       order by AS_AT_DATE
        for update of BASE_REF_AMOUNT NOWAIT;

/***********************************************/
/* For DEAL_TYPE in('TMM','RTMM', 'BOND', 'FX')*/
/***********************************************/
 cursor CHK_LOCK_ROWS_TMM(V_START_DATE DATE,
                     V_END_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER,
                     V_COMPANY_CODE VARCHAR2) is
    select rowid, as_at_date
      from XTR_POSITION_HISTORY
       where AS_AT_DATE >= V_START_DATE
         and AS_AT_DATE < V_END_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER
       order by AS_AT_DATE
        for update of BASE_REF_AMOUNT NOWAIT;

/*************************/
/* For deal Type CA      */
/*************************/
 cursor CHK_LOCK_ROWS_CA(V_START_DATE DATE,
                     V_END_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_COMPANY_CODE VARCHAR2,
                     V_ACCOUNT_NO VARCHAR2) is
    select rowid, as_at_date
      from XTR_POSITION_HISTORY
       where AS_AT_DATE >= V_START_DATE
         and AS_AT_DATE < V_END_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and COMPANY_CODE = V_COMPANY_CODE
         and ACCOUNT_NO = V_ACCOUNT_NO
       order by AS_AT_DATE
        for update of BASE_REF_AMOUNT NOWAIT;

/*************************/
/* For deal Type IG      */
/*************************/
 cursor CHK_LOCK_ROWS_IG(V_START_DATE 	DATE,
                     V_END_DATE 	DATE,
                     V_DEAL_TYPE  	VARCHAR2,
                     V_DEAL_NUMBER	NUMBER) is
    select rowid, as_at_date
      from XTR_POSITION_HISTORY
       where AS_AT_DATE >= V_START_DATE
         and AS_AT_DATE < V_END_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAl_NUMBER
       order by AS_AT_DATE
        for update of BASE_REF_AMOUNT NOWAIT;


/*********************************************/
/* For deal manager performance issue for IG */
/*********************************************/
/* This is a pure preformance hack for the IG deal manager
   The idea is that the correspondence between an IG deal in XTR_POSITION_HISTORY and XTR_COST_OF_FUNDS
   is one to one.  Therefore it is much more effecient to update XTR_COST_OF_FUNDS at the same time
   we update XTR_POSITION_HISTORY.  Block update.   However to do this it was necessicary to duplicate
   some of the logic from maintain_cof procedure.  This procedure is for IG deals and only IG deals.
   In order to use this hack, the developer must adhere to the following requirements and must not
   deviate or modify them.  Be careful when making modifications to any of the affected code areas so
   as not to violate these assumptions.

   First, INSERT and UPDATE for IG deals are executed ONLY by the maintain position history procedure.
   The maintain COF procedure will do no processing for IG deals for INSERT and UPDATE but will continue
   to be responsible for IG DELETEs.  Call MAINTAIN_COF_IG for IG deals and IG deals only.  Position
   History is now responsible for IG data in COF so it must not forget to call this function for INSERT
   and UPDATE.  For anyone writing SQL upgrade scripts, if data is inserted or updated in XTR_POSITION_HISTORY
   for IG deals then make sure the snapshot of COF is updated appropriately.
*/

  procedure maintain_cof_ig is

    l_fac number;
    l_weighted_avg_prin number;
    l_base_weighted_avg_prin number;

    N_COF_COUNTER NUMBER;
    N_COF_AS_AT_DATE_CP NUMBER;
    N_COF_AS_AT_DATE_INS_CP NUMBER;
    T_COF_AS_AT_DATE DBMS_SQL.DATE_TABLE;
    T_COF_AS_AT_DATE_INS DBMS_SQL.DATE_TABLE;
    T_COF_ROWID DBMS_SQL.VARCHAR2_TABLE;

    cursor get_rounding_factor(l_in_currency in varchar2) is
      select hce_rate,rounding_factor
      from XTR_MASTER_CURRENCIES_V
      where currency=l_in_currency;

    cursor CHK_LOCK_ROWS_COF_IG(V_START_DATE DATE,
                                V_END_DATE DATE,
                                V_COMPANY_CODE  VARCHAR2,
                                V_CPARTY_CODE  VARCHAR2,
                                V_DEAL_TYPE  VARCHAR2,
                                V_CURRENCY  VARCHAR2) is
        select ROWID,AS_AT_DATE
          from XTR_COST_OF_FUNDS
           where AS_AT_DATE >= V_START_DATE
             and AS_AT_DATE < V_END_DATE
             and DEAL_TYPE = V_DEAL_TYPE
             --and DEAL_SUBTYPE = V_DEAL_SUBTYPE /* IG DEAL HAS ONE AND ONLY ONE ENTRY. UPDATE RESPECTIVELY */
             and COMPANY_CODE = V_COMPANY_CODE
             and CURRENCY = V_CURRENCY
             --and nvl(CURRENCY_COMBINATION,'%')=nvl(V_CURRENCY_COMBINATION,'%') /* IG, NOT FX */
             --and nvl(PRODUCT_TYPE,'%') = nvl(V_PRODUCT_TYPE,'%') /* SAME AS DEAL_SUBTYPE */
             --and nvl(PORTFOLIO_CODE,'%') = nvl(V_PORTFOLIO_CODE,'%') /* SAME AS DEAL_SUBTYPE */
             and nvl(PARTY_CODE,'%') = nvl(V_CPARTY_CODE,'%')
            for update of GROSS_PRINCIPAL NOWAIT;

  begin

    open get_rounding_factor(p_currency);
    fetch get_rounding_factor into l_hce_rate,l_fac;
    close get_rounding_factor;
    l_fac :=nvl(l_fac,2);

    l_weighted_avg_prin := round(nvl(L_BASE_REF_AMOUNT,0)*nvl(L_CONVERT_RATE,0)/100,l_fac);
    l_base_weighted_avg_prin := round(nvl(L_BASE_REF_AMOUNT,0)*nvl(P_BASE_RATE,0)/100,l_fac);

    open CHK_LOCK_ROWS_COF_IG(L_REF_DATE,L_END_DATE,P_COMPANY_CODE,P_CPARTY_CODE,P_DEAL_TYPE,P_CURRENCY);
    fetch CHK_LOCK_ROWS_COF_IG bulk collect into T_COF_ROWID,T_COF_AS_AT_DATE;
    close chk_LOCK_ROWS_COF_IG;

       N_COF_COUNTER := T_COF_AS_AT_DATE.COUNT;
       N_COF_AS_AT_DATE_CP := 1;
       N_COF_AS_AT_DATE_INS_CP := 1;

       /* The following loop determines which dates are not already in the table */
       /* all dates not in the table are saved in T_AS_AT_DATE_INS to be inserted */
       FOR I IN 1..(L_END_DATE-L_REF_DATE) LOOP
         IF N_COF_AS_AT_DATE_CP <= N_COF_COUNTER AND T_COF_AS_AT_DATE(N_COF_AS_AT_DATE_CP)=L_REF_DATE+I-1 THEN
           N_COF_AS_AT_DATE_CP:=N_COF_AS_AT_DATE_CP+1;
         ELSE
           T_COF_AS_AT_DATE_INS(N_COF_AS_AT_DATE_INS_CP):=L_REF_DATE+I-1;
           N_COF_AS_AT_DATE_INS_CP:=N_COF_AS_AT_DATE_INS_CP+1;
         END IF;
       END LOOP;

       FORALL i in 1..T_COF_AS_AT_DATE.COUNT
            update XTR_COST_OF_FUNDS
            set GROSS_PRINCIPAL = L_BASE_REF_AMOUNT,
              HCE_GROSS_PRINCIPAL = L_HCE_BASE_REF_AMOUNT,
              WEIGHTED_AVG_PRINCIPAL = L_WEIGHTED_AVG_PRIN,
              AVG_INTEREST_RATE = L_CONVERT_RATE,
              BASE_WEIGHTED_AVG_PRINCIPAL = L_BASE_WEIGHTED_AVG_PRIN,
              AVG_BASE_RATE = P_BASE_RATE,
              INTEREST = L_DAILY_INT,
              HCE_INTEREST = L_HCE_INT,
              DEAL_SUBTYPE = L_DEAL_SUBTYPE,
              PRODUCT_TYPE = P_PRODUCT_TYPE,
              PORTFOLIO_CODE = P_PORTFOLIO_CODE
            where rowid=T_COF_ROWID(i);

       FORALL i in 1..T_COF_AS_AT_DATE_INS.COUNT
            insert into XTR_COST_OF_FUNDS
             (as_at_date,company_code,deal_type,
              deal_subtype,party_code,portfolio_code,product_type,
              currency,currency_combination,contra_ccy,
              account_no,created_on,
              gross_principal,hce_gross_principal,
              weighted_avg_principal,avg_interest_rate,interest,hce_interest,
              base_weighted_avg_principal,avg_base_rate, gross_base_amount,
              gross_contra_trans_amount, gross_contra_spot_amount)
            values(
               T_COF_AS_AT_DATE_INS(i),
               P_COMPANY_CODE,
               P_DEAL_TYPE,
               L_DEAL_SUBTYPE,
               P_CPARTY_CODE,
               P_PORTFOLIO_CODE,
               P_PRODUCT_TYPE,
               P_CURRENCY,
               NULL,
               P_CONTRA_CCY,
               P_ACCOUNT_NO,
               sysdate,
               L_BASE_REF_AMOUNT,
               L_HCE_BASE_REF_AMOUNT,
               L_WEIGHTED_AVG_PRIN,
               L_CONVERT_RATE, --avg_int_rate
               L_DAILY_INT,         -- interest
               L_HCE_INT,     -- hce_interest
               L_BASE_WEIGHTED_AVG_PRIN,
               P_BASE_RATE, -- avg_base_rate
               NULL,  -- gross_base_amount
               NULL, --gross_contra_trans
               NULL --gross_contra_spot
               );



  end;


begin
  open HCE;
  fetch HCE into L_HCE_RATE,L_FAC;
  close HCE;

/***********************/
/* Common Calculations */
/***********************/
       L_REF_DATE :=nvl(P_START_DATE,L_SYS_DATE);
       L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
       if p_deal_type = 'IG' then
         get_curr_ig_deal_details(P_DEAL_NUMBER,P_TRANSACTION_NUMBER,L_END_DATE);
         L_END_DATE := least(nvl(L_END_DATE,L_SYS_DATE),nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
       end if;


  L_HCE_BASE_REF_AMOUNT :=round(P_BASE_REF_AMOUNT/L_HCE_RATE,L_FAC);
  L_BASE_REF_AMOUNT :=P_BASE_REF_AMOUNT;

    /*====================================================*/
    /* Calculate the following columns' values:           */
    /* (1) Daily Interst                                  */
    /* (2) HCE_INTEREST                                   */
    /* (3) transaction rate in terms of Actual/365 basis  */
    /*====================================================*/
    If P_DEAL_TYPE = 'NI' then
       /** Need to convert to yield rate first if it's Discount basis  **/
       if P_CALC_BASIS = 'DISCOUNT' THEN
	  -- Added the parameters for Interest Override feature
	  XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                p_year_calc_type,
                                l_no_of_days,
				l_year_basis,
				NULL,
				p_day_count_type,
				p_first_trans_flag
				     );

          XTR_RATE_CONVERSION.Discount_To_Yield_Rate(P_TRANSACTION_RATE, L_NO_OF_DAYS,
                                 L_YEAR_BASIS, L_YIELD_RATE);
       else
             L_YIELD_RATE := P_TRANSACTION_RATE;
       end if;
    Else
       L_YIELD_RATE := P_TRANSACTION_RATE;
    End if;

/*-----------------------------*/
/* NI, TMM, RTMM, ONC mature   */
/*-----------------------------*/
    -- Changed for Interest Override feature
    If P_DEAL_TYPE in ('NI', 'TMM', 'RTMM') or
       (P_DEAL_TYPE = 'ONC' and P_MATURITY_DATE is not null) then
       If ((p_maturity_date - p_start_date) <> 0)
	 -- Added for Interest Override
	 AND( p_day_count_type <> 'B'
         OR (p_day_count_type ='B' AND p_first_trans_flag <>'Y'))
	 --
       THEN
          L_DAILY_INT := P_INTEREST / (p_maturity_date - p_start_date);
          L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
	-- Added for Intreest Override
	ELSIF p_day_count_type ='B' AND p_first_trans_flag='Y' then
          L_DAILY_INT := P_INTEREST / (p_maturity_date - p_start_date +1);
          L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
	--
	ELSE
 	  L_DAILY_INT := 0;
	  L_HCE_INT := 0;
       END IF;

       -- Added paramters for Interest Override feature
       XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                p_year_calc_type,
                                l_no_of_days_in,
                                l_year_basis_in,
				NULL,
				p_day_count_type,
				p_first_trans_flag);

       XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                l_convert_type,
                                l_no_of_days_out,
                                l_year_basis_out,
				NULL,
				p_day_count_type,
				p_first_trans_flag);

       XTR_RATE_CONVERSION.day_count_basis_conv(l_no_of_days_in,
                                                l_no_of_days_out,
                                                l_year_basis_in,
                                                l_year_basis_out,
                                                l_yield_rate,
                                                L_CONVERT_RATE);
/*--------------------------*/
/* CA, IG, ONC not mature   */
/*--------------------------*/
    Elsif P_DEAL_TYPE in ('CA', 'IG') or
       (P_DEAL_TYPE = 'ONC' and P_MATURITY_DATE is null) then
       L_NEXT_YEAR := add_months(p_start_date, 12);

       XTR_CALC_P.calc_days_run(p_start_date,
				l_next_year,
                                p_year_calc_type,
                                l_no_of_days_in,
				l_year_basis_in,
				NULL,
				p_day_count_type,
				p_first_trans_flag
				  );

       XTR_RATE_CONVERSION.day_count_basis_conv(1,
                                                1,
                                                l_year_basis_in,
                                                365,
                                                l_yield_rate,
                                                L_CONVERT_RATE);
       L_DAILY_INT := P_TRANSACTION_RATE * P_BASE_REF_AMOUNT / (100 * l_year_basis_in);
       L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;

       -- Added for Interest Override
       IF P_DEAL_TYPE in ('CA', 'IG') AND P_INTEREST IS NOT NULL THEN
	  L_DAILY_INT := L_DAILY_INT + P_INTEREST;
	  L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
       END IF;
       --

/*--------*/
/* BOND   */
/*--------*/
     Elsif P_DEAL_TYPE = 'BOND' THEN
       -- Added paramters for Interest Override feature
       XTR_COF_P.Calculate_Bond_rate(P_DEAL_NUMBER,
				     P_MATURITY_AMOUNT,
                                     P_START_AMOUNT,
                                     P_TRANSACTION_RATE, -- jhung make sure it's coupon rate
                                     P_START_DATE,
                                     P_MATURITY_DATE,
				     P_CALC_TYPE,
                                     L_DAILY_INT,
                                     L_CONVERT_RATE,
				     P_DAY_COUNT_TYPE -- Added for Interest Overide
				     );
      L_HCE_INT := L_DAILY_INT / L_HCE_RATE;
    End if;


/**************/
/* INSERT     */
/**************/
  if P_ACTION='INSERT' and P_STATUS_CODE='CURRENT' then

       L_DEAL_SUBTYPE := P_DEAL_SUBTYPE;
       L_BASE_REF_AMOUNT := P_BASE_REF_AMOUNT;

       if (P_DEAL_TYPE in ('CA','IG')) then
         if (nvl(P_BASE_REF_AMOUNT,0)<0) then
           L_DEAL_SUBTYPE := 'FUND';
         else
           L_DEAL_SUBTYPE := 'INVEST';
         end if;
       elsif (P_DEAL_TYPE in ('FX')) then
         L_CONVERT_RATE := P_TRANSACTION_RATE;
         L_DAILY_INT := 0;
         L_HCE_INT := 0;
       end if;

       FOR i in 1..(L_END_DATE-L_REF_DATE) LOOP
           T_AS_AT_DATE(i) := L_REF_DATE+i-1;
       END LOOP;

       if (P_DEAL_TYPE = 'IG') then
         maintain_cof_ig;
       end if;

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
             L_CONVERT_RATE,
             P_BASE_RATE,
	     L_DAILY_INT,
 	     L_HCE_INT);



/*
       WHILE L_AS_AT_DATE < L_END_DATE LOOP
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
             decode(P_DEAL_TYPE,
                  'CA',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1,'FUND','INVEST'),
                  'IG',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1, 'FUND','INVEST'),
                                                        P_DEAL_SUBTYPE),  -- bug 2345708
             P_PRODUCT_TYPE,
             P_PORTFOLIO_CODE,
             P_CURRENCY,
             P_CONTRA_CCY,
             P_CURRENCY_COMBINATION,
             P_YEAR_CALC_TYPE,
             P_ACCOUNT_NO,
             P_BASE_REF_AMOUNT,
             L_HCE_BASE_REF_AMOUNT,
             decode(P_DEAL_TYPE, 'FX', P_TRANSACTION_RATE, L_CONVERT_RATE),
             P_BASE_RATE,
	     decode(P_DEAL_TYPE, 'FX', 0, L_DAILY_INT),
 	     decode(P_DEAL_TYPE, 'FX', 0, L_HCE_INT));
        L_AS_AT_DATE :=L_AS_AT_DATE +1;
     end loop;
*/


/**************/
/* DELETE     */
/**************/
  elsif P_ACTION = 'DELETE' then
       if P_DEAL_TYPE='CA' then
         delete from XTR_POSITION_HISTORY
            where DEAL_TYPE='CA'
               and AS_AT_DATE >= P_START_DATE
               and ACCOUNT_NO = P_ACCOUNT_NO
               and COMPANY_CODE = P_COMPANY_CODE;
       elsif P_DEAL_TYPE='IG' then
         delete from XTR_POSITION_HISTORY
            where DEAL_TYPE='IG'
               and AS_AT_DATE >= P_START_DATE
               and DEAL_NUMBER = P_DEAL_NUMBER;
       elsif P_DEAL_TYPE ='ONC' then
	  if  P_STATUS_CODE = 'CLOSED' THEN
           L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
           delete from XTR_POSITION_HISTORY
           where AS_AT_DATE >= L_END_DATE
             and DEAL_TYPE = P_DEAL_TYPE
             and DEAL_NUMBER = P_DEAL_NUMBER
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
	   -- Added for Interest Override
	   L_REF_DATE :=P_START_DATE;
	   L_AS_AT_DATE :=L_REF_DATE;

          open CHK_LOCK_ROWS_ONC(L_REF_DATE,L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_TRANSACTION_NUMBER,P_COMPANY_CODE);
          fetch CHK_LOCK_ROWS_ONC BULK COLLECT into T_ROWID, T_AS_AT_DATE;
          close CHK_LOCK_ROWS_ONC;

          FORALL I in 1..T_ROWID.COUNT
		 update XTR_POSITION_HISTORY
		   set COMPANY_CODE = P_COMPANY_CODE,
		   CPARTY_CODE  = P_CPARTY_CODE,
		   DEAL_SUBTYPE = p_deal_subtype,
		   PRODUCT_TYPE = P_PRODUCT_TYPE,
		   PORTFOLIO_CODE = P_PORTFOLIO_CODE,
		   CURRENCY = P_CURRENCY,
		   CURRENCY_COMBINATION = P_CURRENCY_COMBINATION,
		   YEAR_CALC_TYPE = P_YEAR_CALC_TYPE,
		   ACCOUNT_NO = P_ACCOUNT_NO,
		   BASE_REF_AMOUNT = p_base_ref_amount,
		   HCE_BASE_REF_AMOUNT = l_hce_base_ref_amount,
		   BASE_RATE = p_base_rate,
		   TRANSACTION_RATE =  l_convert_rate,
		   INTEREST = l_daily_int,
		   HCE_INTEREST = l_hce_int
		   where rowid=T_ROWID(I);
	   --
	 else
          delete from XTR_POSITION_HISTORY
           where DEAL_NUMBER = P_DEAL_NUMBER
             and DEAL_TYPE = P_DEAL_TYPE
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         end if;

       elsif P_DEAL_TYPE in('TMM','RTMM') then
          delete from XTR_POSITION_HISTORY
           where DEAL_NUMBER = P_DEAL_NUMBER
             and DEAL_TYPE = P_DEAL_TYPE
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;

       elsif P_DEAL_TYPE ='FX' then
         if  P_STATUS_CODE = 'CLOSED' then
           L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
           delete from XTR_POSITION_HISTORY
           where AS_AT_DATE >= L_END_DATE
             and DEAL_NUMBER = P_DEAL_NUMBER
             and DEAL_TYPE = P_DEAL_TYPE
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         else
            delete from XTR_POSITION_HISTORY
             where DEAL_NUMBER = P_DEAL_NUMBER
               and DEAL_TYPE = P_DEAL_TYPE
               and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         end if;
       elsif P_DEAL_TYPE ='NI' then
         if  P_STATUS_CODE = 'CLOSED' then
           L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
           delete from XTR_POSITION_HISTORY
           where AS_AT_DATE >= L_END_DATE
             and DEAL_NUMBER = P_DEAL_NUMBER
             and DEAL_TYPE = P_DEAL_TYPE
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         else
             delete from XTR_POSITION_HISTORY
             where DEAL_TYPE = P_DEAL_TYPE
               and DEAL_NUMBER = P_DEAL_NUMBER;
         end if;
       elsif P_DEAL_TYPE ='BOND' then
         if  P_STATUS_CODE = 'CLOSED' then
           L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
           delete from XTR_POSITION_HISTORY
           where AS_AT_DATE >= L_END_DATE
             and DEAL_TYPE = P_DEAL_TYPE
             and DEAL_NUMBER = P_DEAL_NUMBER
             and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         else
            delete from XTR_POSITION_HISTORY
             where DEAL_NUMBER = P_DEAL_NUMBER
               and DEAL_TYPE = P_DEAL_TYPE
               and TRANSACTION_NUMBER = P_TRANSACTION_NUMBER;
         end if;
       end if;

/**************/
/* UPDATE     */
/**************/
  elsif  P_ACTION='UPDATE' then

       if P_DEAL_TYPE NOT in('TMM','RTMM','CA','IG') then
          open CHK_LOCK_ROWS_ONC(L_REF_DATE,L_END_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_TRANSACTION_NUMBER,P_COMPANY_CODE);
          fetch CHK_LOCK_ROWS_ONC BULK COLLECT into T_ROWID, T_AS_AT_DATE;
          close CHK_LOCK_ROWS_ONC;

       elsif P_DEAL_TYPE  in('TMM','RTMM') then
          open CHK_LOCK_ROWS_TMM(L_REF_DATE,L_END_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_COMPANY_CODE);
           fetch CHK_LOCK_ROWS_TMM BULK COLLECT into T_ROWID, T_AS_AT_DATE;
           close CHK_LOCK_ROWS_TMM;
       elsif P_DEAL_TYPE = 'CA' then
          open CHK_LOCK_ROWS_CA(L_REF_DATE,L_END_DATE,P_DEAL_TYPE,
           P_COMPANY_CODE,P_ACCOUNT_NO);
          fetch CHK_LOCK_ROWS_CA BULK COLLECT into T_ROWID, T_AS_AT_DATE;
          close CHK_LOCK_ROWS_CA;
       elsif P_DEAL_TYPE = 'IG' then
          open CHK_LOCK_ROWS_IG(L_REF_DATE,L_END_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
          fetch CHK_LOCK_ROWS_IG BULK COLLECT into T_ROWID, T_AS_AT_DATE;
          close CHK_LOCK_ROWS_IG;
       end if;

       N_COUNTER := T_AS_AT_DATE.COUNT;
       N_AS_AT_DATE_CP := 1;
       N_AS_AT_DATE_INS_CP := 1;

       /* The following loop determines which dates are not already in the table */
       /* all dates not in the table are saved in T_AS_AT_DATE_INS to be inserted */
       FOR I IN 1..(L_END_DATE-L_REF_DATE) LOOP
         IF N_AS_AT_DATE_CP <= N_COUNTER AND T_AS_AT_DATE(N_AS_AT_DATE_CP)=L_REF_DATE+I-1 THEN
           N_AS_AT_DATE_CP:=N_AS_AT_DATE_CP+1;
         ELSE
           T_AS_AT_DATE_INS(N_AS_AT_DATE_INS_CP):=L_REF_DATE+I-1;
           N_AS_AT_DATE_INS_CP:=N_AS_AT_DATE_INS_CP+1;
         END IF;
       END LOOP;

       L_DEAL_SUBTYPE := P_DEAL_SUBTYPE;

       if P_DEAL_TYPE in('CA','IG') then
         if (nvl(P_BASE_REF_AMOUNT,0)<0) then
           L_DEAL_SUBTYPE := 'FUND';
         else
           L_DEAL_SUBTYPE := 'INVEST';
         end if;
         L_BASE_REF_AMOUNT :=abs(P_BASE_REF_AMOUNT);
         L_HCE_BASE_REF_AMOUNT :=abs(L_HCE_BASE_REF_AMOUNT);
         L_DAILY_INT :=abs(L_DAILY_INT);
         L_HCE_INT :=abs(L_HCE_INT);
       elsif p_DEAL_TYPE in('FX') then
         L_DAILY_INT :=0;
         L_HCE_INT :=0;
         L_CONVERT_RATE := P_TRANSACTION_RATE;
       end if;

       if (P_DEAL_TYPE = 'IG') then
         maintain_cof_ig;
       end if;

        FORALL I in 1..T_AS_AT_DATE.COUNT
            update XTR_POSITION_HISTORY
              set  -- COMPANY_CODE removed from update because it cannot change and it was causing an index to be recalculated
                CPARTY_CODE  = P_CPARTY_CODE,
                DEAL_SUBTYPE = L_DEAL_SUBTYPE,
                PRODUCT_TYPE = P_PRODUCT_TYPE,
                PORTFOLIO_CODE = P_PORTFOLIO_CODE,
                CURRENCY = P_CURRENCY,
                CURRENCY_COMBINATION = P_CURRENCY_COMBINATION,
                YEAR_CALC_TYPE = P_YEAR_CALC_TYPE,
                ACCOUNT_NO = P_ACCOUNT_NO,
                BASE_REF_AMOUNT = L_BASE_REF_AMOUNT,
                HCE_BASE_REF_AMOUNT = L_HCE_BASE_REF_AMOUNT,
                BASE_RATE = P_BASE_RATE,
                TRANSACTION_RATE = L_CONVERT_RATE,
		INTEREST = L_DAILY_INT,
		HCE_INTEREST = L_HCE_INT
             where rowid=T_ROWID(I);

       FORALL I in 1..T_AS_AT_DATE_INS.COUNT
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
             T_AS_AT_DATE_INS(I),
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
             L_CONVERT_RATE,
             P_BASE_RATE,
	     L_DAILY_INT,
	     L_HCE_INT);


  /*
       L_REF_DATE :=P_START_DATE;
       L_END_DATE :=least(nvl(P_MATURITY_DATE,L_SYS_DATE),L_SYS_DATE);
       L_AS_AT_DATE :=L_REF_DATE;

       WHILE L_AS_AT_DATE < L_END_DATE LOOP

       L_ROWID :=NULL;
       if P_DEAL_TYPE NOT in('TMM','RTMM','CA','IG') then
          open CHK_LOCK_ROWS_ONC(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_TRANSACTION_NUMBER,P_COMPANY_CODE);
          fetch CHK_LOCK_ROWS_ONC into L_ROWID;
          close CHK_LOCK_ROWS_ONC;

       elsif P_DEAL_TYPE  in('TMM','RTMM') then
          open CHK_LOCK_ROWS_TMM(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_COMPANY_CODE);
           fetch CHK_LOCK_ROWS_TMM into L_ROWID;
           close CHK_LOCK_ROWS_TMM;
       elsif P_DEAL_TYPE = 'CA' then
          open CHK_LOCK_ROWS_CA(L_AS_AT_DATE,P_DEAL_TYPE,
           P_COMPANY_CODE,P_ACCOUNT_NO);
          fetch CHK_LOCK_ROWS_CA into L_ROWID;
          close CHK_LOCK_ROWS_CA;
       elsif P_DEAL_TYPE = 'IG' then
          open CHK_LOCK_ROWS_IG(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
          fetch CHK_LOCK_ROWS_IG into L_ROWID;
          close CHK_LOCK_ROWS_IG;
       end if;

        if L_ROWID is not null then
            update XTR_POSITION_HISTORY
              set COMPANY_CODE = P_COMPANY_CODE,
                CPARTY_CODE  = P_CPARTY_CODE,
                DEAL_SUBTYPE = decode(DEAL_TYPE,
                  'CA',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1,'FUND','INVEST'),
                  'IG',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1, 'FUND','INVEST'),
                                                        P_DEAL_SUBTYPE),
                PRODUCT_TYPE = P_PRODUCT_TYPE,
                PORTFOLIO_CODE = P_PORTFOLIO_CODE,
                CURRENCY = P_CURRENCY,
                CURRENCY_COMBINATION = P_CURRENCY_COMBINATION,
                YEAR_CALC_TYPE = P_YEAR_CALC_TYPE,
                ACCOUNT_NO = P_ACCOUNT_NO,
                BASE_REF_AMOUNT = decode(DEAL_TYPE,'CA',abs(P_BASE_REF_AMOUNT),
                                                   'IG',abs(P_BASE_REF_AMOUNT),
                                                        P_BASE_REF_AMOUNT),
                HCE_BASE_REF_AMOUNT =decode(DEAL_TYPE,'CA',abs(L_HCE_BASE_REF_AMOUNT),
                                                      'IG',abs(L_HCE_BASE_REF_AMOUNT),
                                                           L_HCE_BASE_REF_AMOUNT),
                BASE_RATE = P_BASE_RATE,
                TRANSACTION_RATE = decode(P_DEAL_TYPE, 'FX', P_TRANSACTION_RATE, L_CONVERT_RATE),
		INTEREST = decode(DEAL_TYPE, 'CA', abs(L_DAILY_INT),
					     'IG', abs(L_DAILY_INT),
					     'FX', 0,
						L_DAILY_INT),
		HCE_INTEREST = decode(DEAL_TYPE, 'CA', abs(L_HCE_INT),
						 'IG', abs(L_HCE_INT),
					         'FX', 0,
						L_HCE_INT)
             where rowid=l_rowid;
         else
         -- insert new row
           if P_DEAL_TYPE in('CA','IG') then
             L_BASE_REF_AMOUNT :=abs(P_BASE_REF_AMOUNT);
             L_HCE_BASE_REF_AMOUNT :=abs(L_HCE_BASE_REF_AMOUNT);
           end if;
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
             decode(P_DEAL_TYPE,
                  'CA',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1,'FUND','INVEST'),
                  'IG',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1, 'FUND','INVEST'),
                                                        P_DEAL_SUBTYPE), --bug 2345708
             P_PRODUCT_TYPE,
             P_PORTFOLIO_CODE,
             P_CURRENCY,
             P_CONTRA_CCY,
             P_CURRENCY_COMBINATION,
             P_YEAR_CALC_TYPE,
	     P_ACCOUNT_NO,
             L_BASE_REF_AMOUNT,
             L_HCE_BASE_REF_AMOUNT,
             decode(P_DEAL_TYPE, 'FX', P_TRANSACTION_RATE, L_CONVERT_RATE),
             P_BASE_RATE,
	     decode(P_DEAL_TYPE, 'FX', 0, abs(L_DAILY_INT)),
	     decode(P_DEAL_TYPE, 'FX', 0, abs(L_HCE_INT)));
          end if;
        L_AS_AT_DATE :=L_AS_AT_DATE +1;
        END LOOP;
*/
 end if;

exception
 when app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_ROWS_ONC%ISOPEN then
     close CHK_LOCK_ROWS_ONC;
  end if;
  if CHK_LOCK_ROWS_TMM%ISOPEN then
     close CHK_LOCK_ROWS_TMM;
  end if;
  if CHK_LOCK_ROWS_CA%ISOPEN then
     close CHK_LOCK_ROWS_CA;
  end if;
  if CHK_LOCK_ROWS_IG%ISOPEN then
     close CHK_LOCK_ROWS_IG;
  end if;
 raise app_exceptions.RECORD_LOCK_EXCEPTION;

end MAINTAIN_POSITION_HISTORY;


PROCEDURE SNAPSHOT_POSITION_HISTORY(
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
 P_MATURITY_DATE		IN DATE,
 P_INTEREST                     IN NUMBER,
 P_MATURITY_AMOUNT              IN NUMBER,
 P_START_AMOUNT                 IN NUMBER,
 P_CALC_BASIS                   IN VARCHAR2,
 P_CALC_TYPE			IN VARCHAR2,
 -- Added the new parameters for Intrest Override feature
 P_DAY_COUNT_TYPE               IN VARCHAR2,
 P_FIRST_TRANS_FLAG             IN VARCHAR2
 --
) as

---
 cursor HCE is
  select s.HCE_RATE,s.ROUNDING_FACTOR
   from XTR_MASTER_CURRENCIES_V s
   where s.CURRENCY = P_CURRENCY;

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
 L_YEAR_BASIS           NUMBER;
 L_NO_OF_DAYS           NUMBER;
 L_NO_OF_DAYS_IN        NUMBER;
 L_NO_OF_DAYS_OUT       NUMBER;
 L_YEAR_BASIS_IN        NUMBER;
 L_YEAR_BASIS_OUT       NUMBER;
 L_YIELD_RATE           NUMBER;
 L_CALC_BASIS           XTR_DEALS.calc_basis%TYPE;
 L_CALC_TYPE            XTR_BOND_ISSUES.calc_type%TYPE;
 L_COUPON_RATE          NUMBER;
 L_MATURITY_AMT         NUMBER;
 L_CONSIDERATION        NUMBER;
 L_CONVERT_RATE         NUMBER;
 L_CONVERT_TYPE         CONSTANT VARCHAR2(15) := 'ACTUAL365';
 L_TOTAL_INT		NUMBER;
 L_DAILY_INT		NUMBER;
 L_HCE_INT              NUMBER;
 L_NEXT_YEAR            DATE;
 L_FACE_VALUE_SOLD      NUMBER := NULL;
 L_LAST_RESALE_DATE     DATE:= NULL;
 L_BASE_REF_AMOUNT      NUMBER;
 -- Added for Interest Override
 l_interest             NUMBER;
 l_original_amount      NUMBER;
 l_face_value          NUMBER;
 l_fully_resold        VARCHAR2(1);
 l_till_date           DATE;
 L_DAILY_INT_INIT 	NUMBER;
 L_HCE_INT_INIT        NUMBER;
 L_HCE_BASE_REF_AMOUNT_INIT NUMBER;
 l_maturity_date   DATE;


/*********************************/
/* For DEAL_TYPE in('NI','ONC')  */
/*********************************/
 cursor GET_PRV_ROWS_ONC(V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER,
                     V_TRANSACTION_NUMBER NUMBER) is
    select max(AS_AT_DATE + 1)
      from XTR_POSITION_HISTORY
       where DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER
         and TRANSACTION_NUMBER = V_TRANSACTION_NUMBER;


 cursor CHK_LOCK_ROWS_ONC(V_AS_AT_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER,
                     V_TRANSACTION_NUMBER NUMBER) is
    select rowid
      from XTR_POSITION_HISTORY
       where AS_AT_DATE = V_AS_AT_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER
         and TRANSACTION_NUMBER = V_TRANSACTION_NUMBER
        for update of BASE_REF_AMOUNT NOWAIT;

/*************************/
/* For DEAL_TYPE 'BOND'  */
/*************************/
 cursor GET_PRV_ROWS_BOND(V_DEAL_TYPE  VARCHAR2,
                          V_DEAL_NUMBER NUMBER) is
    select max(AS_AT_DATE + 1)
    from XTR_POSITION_HISTORY
    where DEAL_TYPE = V_DEAL_TYPE
    and DEAL_NUMBER = V_DEAL_NUMBER;

 cursor BOND_LAST_PROC_DATE(V_AS_AT_DATE DATE,
			    V_DEAL_NUMBER NUMBER)is
    select cross_ref_start_date, avg_rate_last_processed
    from xtr_bond_alloc_details
    where deal_no = V_DEAL_NUMBER
    and CROSS_REF_START_DATE <= V_AS_AT_DATE
    and avg_rate_last_processed is null
    order by cross_ref_start_date;   -- 4470022

 cursor CHK_LOCK_ROWS_BOND(V_AS_AT_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER) is
    select rowid
    from XTR_POSITION_HISTORY
    where AS_AT_DATE = V_AS_AT_DATE
      and DEAL_TYPE = V_DEAL_TYPE
      and DEAL_NUMBER = V_DEAL_NUMBER
     for update of BASE_REF_AMOUNT NOWAIT;


/***********************************************/
/* For DEAL_TYPE in('TMM','RTMM')*/
/***********************************************/
 cursor GET_PRV_ROWS_TMM(V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER) is
    select max(AS_AT_DATE + 1)
      from XTR_POSITION_HISTORY
       where DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER;

 cursor CHK_LOCK_ROWS_TMM(V_AS_AT_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_NUMBER NUMBER) is
    select rowid
      from XTR_POSITION_HISTORY
       where AS_AT_DATE = V_AS_AT_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAL_NUMBER
        for update of BASE_REF_AMOUNT NOWAIT;

/***********************/
/* For DEAL_TYPE 'CA'  */
/***********************/
 cursor GET_PRV_ROWS_CA(V_DEAL_TYPE VARCHAR2,
                     V_COMPANY_CODE VARCHAR2,
                     V_ACCOUNT_NO VARCHAR2) is
    select max(AS_AT_DATE + 1)
      from XTR_POSITION_HISTORY
       where DEAL_TYPE = V_DEAl_TYPE
         and COMPANY_CODE = V_COMPANY_CODE
         and ACCOUNT_NO = V_ACCOUNT_NO;

 cursor CHK_LOCK_ROWS_CA(V_AS_AT_DATE DATE,
                     V_DEAL_TYPE  VARCHAR2,
                     V_COMPANY_CODE VARCHAR2,
                     V_ACCOUNT_NO VARCHAR2) is
    select rowid
      from XTR_POSITION_HISTORY
       where AS_AT_DATE = V_AS_AT_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and COMPANY_CODE = V_COMPANY_CODE
         and ACCOUNT_NO = V_ACCOUNT_NO
        for update of BASE_REF_AMOUNT NOWAIT;

/***********************/
/* For DEAL_TYPE 'IG'  */
/***********************/
 cursor GET_PRV_ROWS_IG(V_DEAL_TYPE  	VARCHAR2,
                     V_DEAL_NUMBER	NUMBER) is
    select MAX(AS_AT_DATE + 1)
      from XTR_POSITION_HISTORY
       where DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAl_NUMBER;

 cursor CHK_LOCK_ROWS_IG(V_AS_AT_DATE 	DATE,
                     V_DEAL_TYPE  	VARCHAR2,
                     V_DEAL_NUMBER	NUMBER) is
    select rowid
      from XTR_POSITION_HISTORY
       where AS_AT_DATE = V_AS_AT_DATE
         and DEAL_TYPE = V_DEAL_TYPE
         and DEAL_NUMBER = V_DEAl_NUMBER
        for update of BASE_REF_AMOUNT NOWAIT;


 cursor get_bond_calc is
 select b.calc_type, d.coupon_rate, d.maturity_amount, d.start_amount
 from xtr_deals D, xtr_bond_issues B
 where d.bond_issue = b.bond_issue_code
 and d.deal_no = P_DEAL_NUMBER;

 cursor get_bond_resale is
 Select sum(face_value), max(cross_ref_start_date)
 From XTR_BOND_ALLOC_DETAILS
 Where deal_no = P_DEAL_NUMBER
  and cross_ref_start_date <= P_AS_AT_DATE;

-- bug 4539511

cursor get_bond_maturity_date is
 Select maturity_date
 from xtr_deals
 where deal_no = p_deal_number
 and deal_type = 'BOND'
 and maturity_date <= P_AS_AT_DATE;


BEGIN
  open HCE;
  fetch HCE into L_HCE_RATE,L_FAC;
  close HCE;

  L_HCE_BASE_REF_AMOUNT :=round(P_BASE_REF_AMOUNT/L_HCE_RATE,L_FAC);

    /*====================================================*/
    /* Calculate the following columns' values:           */
    /* (1) Daily Interst                                  */
    /* (2) HCE_INTEREST                                   */
    /* (3) transaction rate in terms of Actual/365 basis  */
    /*====================================================*/
    If P_DEAL_TYPE = 'NI' then
       if P_CALC_BASIS = 'DISCOUNT' then
       /** Need to convert to yield rate first if it's Discount basis  **/
	  -- Added the parameters for Interest Override feature
          XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                p_year_calc_type,
                                l_no_of_days,
				l_year_basis,
				p_day_count_type,
				p_first_trans_flag
				     );

          XTR_RATE_CONVERSION.Discount_To_Yield_Rate(P_TRANSACTION_RATE, L_NO_OF_DAYS,
                                 L_YEAR_BASIS, L_YIELD_RATE);
       else
             L_YIELD_RATE := P_TRANSACTION_RATE;
       end if;
    Else
       L_YIELD_RATE := P_TRANSACTION_RATE;
    End if;

/*-----------------------------*/
/* NI, TMM, RTMM, ONC mature   */
/*-----------------------------*/
    If P_DEAL_TYPE in ('NI', 'TMM', 'RTMM') or
      (P_DEAL_TYPE = 'ONC' and P_MATURITY_DATE is not null) THEN
       -- Changed for Interest Override feature
       IF p_day_count_type ='B' AND p_first_trans_flag='Y' THEN
	  L_DAILY_INT := P_INTEREST / (p_maturity_date - p_start_date +1);
	  L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
	ELSE
	  L_DAILY_INT := P_INTEREST / (p_maturity_date - p_start_date);
	  L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
       END IF;

       -- Added the new parameter for Interest Override feature
       XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                p_year_calc_type,
                                l_no_of_days_in,
				l_year_basis_in,
				NULL,
				p_day_count_type,
				p_first_trans_flag
				  );
       XTR_CALC_P.calc_days_run(p_start_date,
                                p_maturity_date,
                                l_convert_type,
                                l_no_of_days_out,
				l_year_basis_out,
				NULL,
				p_day_count_type,
				p_first_trans_flag
				  );

       XTR_RATE_CONVERSION.day_count_basis_conv(l_no_of_days_in,
                                                l_no_of_days_out,
                                                l_year_basis_in,
                                                l_year_basis_out,
                                                l_yield_rate,
                                                L_CONVERT_RATE);
/*--------------------------*/
/* CA, IG, ONC not mature   */
/*--------------------------*/
    Elsif P_DEAL_TYPE in ('CA', 'IG') or
       (P_DEAL_TYPE = 'ONC' and P_MATURITY_DATE is null) then
   --    L_DAILY_INT := P_TRANSACTION_RATE * P_BASE_REF_AMOUNT / (100 * 365);
   --    L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;

       -- Added for Interest Override
       IF P_DEAL_TYPE in ('CA', 'IG') AND P_INTEREST IS NOT NULL THEN
	  L_DAILY_INT := L_DAILY_INT + P_INTEREST;
	  L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;
       END IF;
       --

       L_NEXT_YEAR := add_months(p_start_date, 12);

       -- Added the new parameter for Interest Override feature
       XTR_CALC_P.calc_days_run(p_start_date,
                                l_next_year,
                                p_year_calc_type,
                                l_no_of_days_in,
                                l_year_basis_in,
				NULL,
				p_day_count_type,
				p_first_trans_flag
				);

       XTR_RATE_CONVERSION.day_count_basis_conv(1,
                                                1,
                                                l_year_basis_in,
                                                365,
                                                l_yield_rate,
                                                L_CONVERT_RATE);
       L_DAILY_INT := P_TRANSACTION_RATE * P_BASE_REF_AMOUNT / (100 * l_year_basis_in);
       L_HCE_INT   := L_DAILY_INT / L_HCE_RATE;

/*--------*/
/* BOND   */
/*--------*/
    Elsif P_DEAL_TYPE = 'BOND' THEN
       -- Added the new parameter for Interest Override feature
       XTR_COF_P.Calculate_Bond_rate(P_DEAL_NUMBER,
			             P_MATURITY_AMOUNT,
                                     P_START_AMOUNT,
                                     P_TRANSACTION_RATE, -- jhung make sure it's coupon rate
                                     P_START_DATE,
                                     P_MATURITY_DATE,
				     P_CALC_TYPE,
                                     L_DAILY_INT,
                                     L_CONVERT_RATE,
				     P_DAY_COUNT_TYPE   -- Added for Interest Override
				     );
      L_HCE_INT := L_DAILY_INT / L_HCE_RATE;

      Open get_bond_resale;
      Fetch get_bond_resale into l_face_value_sold, l_last_resale_date;
      If get_bond_resale%FOUND then
	 If nvl(l_face_value_sold, 0) = P_MATURITY_AMOUNT then  -- totally resale
            Delete from XTR_POSITION_HISTORY
            Where deal_number = P_DEAL_NUMBER
            And as_at_date >= l_last_resale_date;

            close get_bond_resale;
            l_fully_resold := 'Y';


             --  Shifted  the else in while loop for bug 4470022
          end if;

        Else
             close get_bond_resale;
        End if;

   End if;

    if P_DEAL_TYPE NOT in('BOND','TMM','RTMM','CA','IG') then
          open GET_PRV_ROWS_ONC(P_DEAL_TYPE,P_DEAL_NUMBER,
           P_TRANSACTION_NUMBER);
          fetch GET_PRV_ROWS_ONC into L_AS_AT_DATE;
          close GET_PRV_ROWS_ONC;
    elsif P_DEAL_TYPE = 'BOND' then
	  open GET_PRV_ROWS_BOND(P_DEAL_TYPE,P_DEAL_NUMBER);
	  fetch GET_PRV_ROWS_BOND into L_AS_AT_DATE;
	  if GET_PRV_ROWS_BOND%FOUND then  -- deal no has some data in PH
	     open BOND_LAST_PROC_DATE(L_AS_AT_DATE,P_DEAL_NUMBER);
             fetch BOND_LAST_PROC_DATE into L_RESALE_DATE, L_LAST_PROC_DATE;
             if BOND_LAST_PROC_DATE%FOUND then
                L_EARLY_START_DATE := nvl(L_LAST_PROC_DATE, L_RESALE_DATE);
                if L_EARLY_START_DATE < nvl(L_AS_AT_DATE, sysdate) then
                   L_AS_AT_DATE := L_EARLY_START_DATE;
                end if;
	        close BOND_LAST_PROC_DATE;
	     else
                close BOND_LAST_PROC_DATE;
	     end if;
	     close GET_PRV_ROWS_BOND;
	  else
	     close GET_PRV_ROWS_BOND;
	  end if;

    elsif P_DEAL_TYPE  in('TMM','RTMM') then
          open GET_PRV_ROWS_TMM(P_DEAL_TYPE,P_DEAL_NUMBER);
           fetch GET_PRV_ROWS_TMM into L_AS_AT_DATE;
           close GET_PRV_ROWS_TMM;
    elsif P_DEAL_TYPE = 'CA' then
          open GET_PRV_ROWS_CA(P_DEAL_TYPE,
           P_COMPANY_CODE,P_ACCOUNT_NO);
          fetch GET_PRV_ROWS_CA into L_AS_AT_DATE;
          close GET_PRV_ROWS_CA;
    elsif P_DEAL_TYPE = 'IG' then
          open GET_PRV_ROWS_IG(P_DEAL_TYPE,P_DEAL_NUMBER);
          fetch GET_PRV_ROWS_IG into L_AS_AT_DATE;
          close GET_PRV_ROWS_IG;
    end if;

    L_AS_AT_DATE :=nvl(L_AS_AT_DATE,P_AS_AT_DATE);


    -- bug 4470022  Added the following lines

    IF p_deal_type = 'BOND' THEN

       L_DAILY_INT_INIT:= L_DAILY_INT;
       L_HCE_INT_INIT := L_HCE_INT;
       L_HCE_BASE_REF_AMOUNT_INIT := l_hce_base_ref_amount ;

       -- bug 4539511
       open get_bond_maturity_date;
       fetch get_bond_maturity_date into l_maturity_date;
       close get_bond_maturity_date;

       l_till_date := nvl(l_maturity_date -1 , p_as_at_date);



       if l_fully_resold = 'Y' then

            l_till_date := l_last_resale_date -1 ;

       end if;

    ELSE

            l_till_date := p_as_at_date;
    end if;


    -- Bug 4470022 ended


    WHILE L_AS_AT_DATE <= L_TILL_DATE LOOP
       L_ROWID :=NULL;
       if P_DEAL_TYPE NOT in('BOND', 'TMM','RTMM','CA','IG') then
          open CHK_LOCK_ROWS_ONC(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER,
           P_TRANSACTION_NUMBER);
          fetch CHK_LOCK_ROWS_ONC into L_ROWID;
          close CHK_LOCK_ROWS_ONC;
       elsif P_DEAL_TYPE = 'BOND' then
          open CHK_LOCK_ROWS_BOND(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
          fetch CHK_LOCK_ROWS_BOND into L_ROWID;
          close CHK_LOCK_ROWS_BOND;

           --  bug 4470022  Added the following lines
          Select sum(face_value)
          into l_face_value
          From XTR_BOND_ALLOC_DETAILS
          Where deal_no = P_DEAL_NUMBER
          and cross_ref_start_date <= L_AS_AT_DATE;

           IF l_face_value <> 0 then

              -- Added and changed for Interest Override
                    SELECT SUM(interest), SUM(original_amount)
                    INTO l_interest,l_original_amount
                     FROM xtr_rollover_transactions
                     WHERE deal_number = P_DEAL_NUMBER;


                    IF l_interest = l_original_amount THEN

                        L_DAILY_INT := L_DAILY_INT_INIT* (P_MATURITY_AMOUNT - l_face_value)/P_MATURITY_AMOUNT;
	                L_HCE_INT := L_HCE_INT_INIT* (P_MATURITY_AMOUNT -l_face_value)/P_MATURITY_AMOUNT;
               	        L_BASE_REF_AMOUNT := p_base_ref_amount * (P_MATURITY_AMOUNT -l_face_value)/P_MATURITY_AMOUNT;
	                L_HCE_BASE_REF_AMOUNT := l_hce_base_ref_amount_init *
                                (P_MATURITY_AMOUNT -l_face_value)/P_MATURITY_AMOUNT;
                        L_CONVERT_RATE := L_DAILY_INT * 365 * 100 / L_BASE_REF_AMOUNT;

                   END If;
            END if;
            -- bug 4470022 ended

       elsif P_DEAL_TYPE  in('TMM','RTMM') then
          open CHK_LOCK_ROWS_TMM(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
           fetch CHK_LOCK_ROWS_TMM into L_ROWID;
           close CHK_LOCK_ROWS_TMM;
       elsif P_DEAL_TYPE = 'CA' then
          open CHK_LOCK_ROWS_CA(L_AS_AT_DATE,P_DEAL_TYPE,
           P_COMPANY_CODE,P_ACCOUNT_NO);
          fetch CHK_LOCK_ROWS_CA into L_ROWID;
          close CHK_LOCK_ROWS_CA;
       elsif P_DEAL_TYPE = 'IG' then
          open CHK_LOCK_ROWS_IG(L_AS_AT_DATE,P_DEAL_TYPE,P_DEAL_NUMBER);
          fetch CHK_LOCK_ROWS_IG into L_ROWID;
          close CHK_LOCK_ROWS_IG;
       end if;

      /*========================================*/
      /* Insert or Update postion history table */
      /*========================================*/
       if L_ROWID is not null then
            update XTR_POSITION_HISTORY
              set COMPANY_CODE = P_COMPANY_CODE,
                CPARTY_CODE  = P_CPARTY_CODE,
          /*      DEAL_SUBTYPE = decode(DEAL_TYPE,
                  'CA',decode(sign(nvl(BASE_REF_AMOUNT,0)
                        +nvl(P_BASE_REF_AMOUNT,0)),-1,'FUND','INVEST'),
                  'IG',decode(sign(nvl(BASE_REF_AMOUNT,0)
                        +nvl(P_BASE_REF_AMOUNT,0)),-1, 'FUND','INVEST'),
                                                        P_DEAL_SUBTYPE),   */
                DEAL_SUBTYPE = decode(DEAL_TYPE,
                  'CA',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1,'FUND','INVEST'),
                  'IG',decode(sign(nvl(P_BASE_REF_AMOUNT,0)),-1, 'FUND','INVEST'),
                                                        P_DEAL_SUBTYPE),   -- bug 2345708
                PRODUCT_TYPE = P_PRODUCT_TYPE,
                PORTFOLIO_CODE = P_PORTFOLIO_CODE,
                CURRENCY = P_CURRENCY,
                CONTRA_CCY = P_CONTRA_CCY,
                CURRENCY_COMBINATION = P_CURRENCY_COMBINATION,
                YEAR_CALC_TYPE = P_YEAR_CALC_TYPE,
                ACCOUNT_NO = P_ACCOUNT_NO,
                BASE_REF_AMOUNT = decode(DEAL_TYPE,'CA',abs(P_BASE_REF_AMOUNT),
                                                   'IG',abs(P_BASE_REF_AMOUNT),
						   'BOND', abs(nvl(L_BASE_REF_AMOUNT,P_BASE_REF_AMOUNT)),
                                                        P_BASE_REF_AMOUNT),
                HCE_BASE_REF_AMOUNT =decode(DEAL_TYPE,'CA',abs(L_HCE_BASE_REF_AMOUNT),
                                                      'IG',abs(L_HCE_BASE_REF_AMOUNT),
                                                           L_HCE_BASE_REF_AMOUNT),  -- bug2345708
                BASE_RATE = P_BASE_RATE,
                TRANSACTION_RATE = decode(P_DEAL_TYPE, 'FX', P_TRANSACTION_RATE, L_CONVERT_RATE),
                INTEREST = decode(DEAL_TYPE, 'CA', abs(L_DAILY_INT),
                                             'IG', abs(L_DAILY_INT),
					     'FX', 0,
                                                L_DAILY_INT),
                HCE_INTEREST = decode(DEAL_TYPE, 'CA', abs(L_HCE_INT),
                                                 'IG', abs(L_HCE_INT),
                                                 'FX', 0,
                                                L_HCE_INT)
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
             decode(P_DEAL_TYPE, 'FX', P_TRANSACTION_RATE, L_CONVERT_RATE),
             P_BASE_RATE,
	     decode(P_DEAL_TYPE, 'FX', 0, abs(L_DAILY_INT)),
	     decode(P_DEAL_TYPE, 'FX', 0, abs(L_HCE_INT)));
          end if;

	  if P_DEAL_TYPE = 'BOND' and l_face_value_sold is not null then
	     Update XTR_BOND_ALLOC_DETAILS
	     set avg_rate_last_processed = greatest(nvl(avg_rate_last_processed, L_AS_AT_DATE),
					   L_AS_AT_DATE)
	     where deal_no = P_DEAL_NUMBER;
	  end if;
        L_AS_AT_DATE :=L_AS_AT_DATE +1;
        END LOOP;

exception
 when app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_ROWS_ONC%ISOPEN then
     close CHK_LOCK_ROWS_ONC;
  end if;
  if CHK_LOCK_ROWS_TMM%ISOPEN then
     close CHK_LOCK_ROWS_TMM;
  end if;
  if CHK_LOCK_ROWS_CA%ISOPEN then
     close CHK_LOCK_ROWS_CA;
  end if;
  if CHK_LOCK_ROWS_IG%ISOPEN then
     close CHK_LOCK_ROWS_IG;
  end if;
 raise app_exceptions.RECORD_LOCK_EXCEPTION;

end SNAPSHOT_POSITION_HISTORY;


PROCEDURE MAINTAIN_COST_OF_FUND(
 OLD_AS_AT_DATE			IN date,
 OLD_COMPANY_CODE		IN VARCHAR2,
 OLD_CURRENCY			IN VARCHAR2,
 OLD_DEAL_TYPE			IN VARCHAR2,
 OLD_DEAL_SUBTYPE		IN VARCHAR2,
 OLD_PRODUCT_TYPE		IN VARCHAR2,
 OLD_PORTFOLIO_CODE  		IN VARCHAR2,
 OLD_CPARTY_CODE		IN VARCHAR2,
 OLD_CONTRA_CCY			IN VARCHAR2,
 OLD_CURRENCY_COMBINATION	IN VARCHAR2,
 OLD_ACCOUNT_NO			IN VARCHAR2,
 OLD_TRANSACTION_RATE		IN NUMBER,
 OLD_YEAR_CALC_TYPE		IN VARCHAR2,
 OLD_BASE_REF_AMOUNT		IN NUMBER,
 OLD_HCE_BASE_REF_AMOUNT	IN NUMBER,
 OLD_BASE_RATE			IN NUMBER,
 OLD_INTEREST			IN NUMBER,
 OLD_HCE_INTEREST		IN NUMBER,
 NEW_AS_AT_DATE			IN date,
 NEW_COMPANY_CODE               IN VARCHAR2,
 NEW_CURRENCY                   IN VARCHAR2,
 NEW_DEAL_TYPE                  IN VARCHAR2,
 NEW_DEAL_SUBTYPE               IN VARCHAR2,
 NEW_PRODUCT_TYPE               IN VARCHAR2,
 NEW_PORTFOLIO_CODE             IN VARCHAR2,
 NEW_CPARTY_CODE                IN VARCHAR2,
 NEW_CONTRA_CCY                 IN VARCHAR2,
 NEW_CURRENCY_COMBINATION       IN VARCHAR2,
 NEW_ACCOUNT_NO                 IN VARCHAR2,
 NEW_TRANSACTION_RATE           IN NUMBER,
 NEW_YEAR_CALC_TYPE             IN VARCHAR2,
 NEW_BASE_REF_AMOUNT            IN NUMBER,
 NEW_HCE_BASE_REF_AMOUNT	IN NUMBER,
 NEW_BASE_RATE			IN NUMBER,
 NEW_INTEREST			IN NUMBER,
 NEW_HCE_INTEREST		IN NUMBER,
 P_ACTION 			IN VARCHAR2) as

---

L_ROWID         VARCHAR2(30);

cursor CHK_LOCK_ROWS(V_AS_AT_DATE DATE,
                     V_COMPANY_CODE  VARCHAR2,
                     V_CPARTY_CODE  VARCHAR2,
                     V_DEAL_TYPE  VARCHAR2,
                     V_DEAL_SUBTYPE  VARCHAR2,
                     V_PRODUCT_TYPE  VARCHAR2,
                     V_PORTFOLIO_CODE  VARCHAR2,
                     V_CURRENCY  VARCHAR2,
                     V_CONTRA_CCY VARCHAR2,
                     V_CURRENCY_COMBINATION VARCHAR2,
                     V_ACCOUNT_NO  VARCHAR2) is
    select ROWID,GROSS_PRINCIPAL
      from XTR_COST_OF_FUNDS
       where AS_AT_DATE = V_AS_AT_DATE
         and DEAL_TYPE = V_DEAL_TYPE
	 and DEAL_SUBTYPE = V_DEAL_SUBTYPE
         and COMPANY_CODE = V_COMPANY_CODE
         and CURRENCY = V_CURRENCY
         and nvl(CURRENCY_COMBINATION,'%')=nvl(V_CURRENCY_COMBINATION,'%')
         and nvl(PRODUCT_TYPE,'%') = nvl(V_PRODUCT_TYPE,'%')
         and nvl(PORTFOLIO_CODE,'%') = nvl(V_PORTFOLIO_CODE,'%')
         and nvl(PARTY_CODE,'%') = nvl(V_CPARTY_CODE,'%')
        for update of GROSS_PRINCIPAL NOWAIT;

l_gross         NUMBER;
l_currency	VARCHAR2(15);
l_hce_rate	NUMBER;
l_fac	 	NUMBER;
v_100		NUMBER;
l_interest	NUMBER;
l_interest_hce  NUMBER;

cursor get_rounding_factor is
 select hce_rate,rounding_factor
 from XTR_MASTER_CURRENCIES_V
  where currency=l_currency;

BEGIN
/**************/
/* INSERT     */
/**************/
 if P_ACTION='INSERT' then
  if (NEW_DEAL_TYPE<>'IG') then /* IG handled by maintain_position_history, see comments for maintain_cof_ig */
   l_currency :=NEW_CURRENCY;
   open get_rounding_factor;
   fetch get_rounding_factor into l_hce_rate,l_fac;
   close get_rounding_factor;
   l_fac :=nvl(l_fac,2);

   L_INTEREST :=NULL;
   L_INTEREST_HCE :=NULL;

   if NEW_DEAL_TYPE = 'FX' then
     v_100 :=1;
     l_fac :=4;
   else
     v_100 :=100;
   end if;

   open CHK_LOCK_ROWS(
		     NEW_AS_AT_DATE ,
                     NEW_COMPANY_CODE,
                     NEW_CPARTY_CODE,
                     NEW_DEAL_TYPE,
                     NEW_DEAL_SUBTYPE,
                     NEW_PRODUCT_TYPE,
                     NEW_PORTFOLIO_CODE,
                     NEW_CURRENCY,
                     NEW_CONTRA_CCY,
                     NEW_CURRENCY_COMBINATION,
                     NEW_ACCOUNT_NO);
        fetch CHK_LOCK_ROWS into l_rowid,l_gross;
        if CHK_LOCK_ROWS%FOUND then
          close CHK_LOCK_ROWS;
	  If NEW_DEAL_TYPE = 'FX' then
	     -- For FX, adding 3 new columns to calculate avg_interest_rate and avg_base_rate
             update XTR_COST_OF_FUNDS
             set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)+nvl(NEW_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                         nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
		GROSS_BASE_AMOUNT = nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),
	        GROSS_CONTRA_TRANS_AMOUNT = nvl(GROSS_CONTRA_TRANS_AMOUNT,0)+
					    abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_TRANSACTION_RATE,0),
                GROSS_CONTRA_SPOT_AMOUNT = nvl(GROSS_CONTRA_SPOT_AMOUNT,0)+
                                            abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_BASE_RATE,0),
                AVG_INTEREST_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),0,NULL,
				    round((nvl(GROSS_CONTRA_TRANS_AMOUNT,0)+
                                     abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_TRANSACTION_RATE,0))/
				    (nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0))),l_fac)),
                AVG_BASE_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_SPOT_AMOUNT,0)+
                                     abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_BASE_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0))),l_fac)),
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),
                INTEREST = 0,
	        HCE_INTEREST = 0
                where rowid=l_rowid;
	    else  -- For other deal types (TMM, RTMM, CA, IG, ONC, NI, BOND)
                update XTR_COST_OF_FUNDS
                set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)+nvl(NEW_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                         nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
                AVG_INTEREST_RATE = decode((nvl(GROSS_PRINCIPAL,0) - nvl(NEW_BASE_REF_AMOUNT,0)),0,null,
                 	            abs((nvl(INTEREST,0) - nvl(NEW_INTEREST,0))/
                                    (nvl(GROSS_PRINCIPAL,0) - nvl(NEW_BASE_REF_AMOUNT,0)))) * 36500,
					-- bug 2345708
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),
                AVG_BASE_RATE = abs(decode(nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),0,null,
                                    decode(nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                    +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                     nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
                                     0,null,
                                     round(v_100*(nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                     +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac))/
                                     (nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0)),l_fac)))),
                INTEREST = nvl(INTEREST,0) + nvl(NEW_INTEREST,0),
                HCE_INTEREST = nvl(HCE_INTEREST,0) + nvl(NEW_HCE_INTEREST,0)
                where rowid=l_rowid;
	     end if;
         else
          close CHK_LOCK_ROWS;
         -- insert new row
          insert into XTR_COST_OF_FUNDS
           (as_at_date,company_code,deal_type,
            deal_subtype,party_code,portfolio_code,product_type,
            currency,currency_combination,contra_ccy,
            account_no,created_on,
            gross_principal,hce_gross_principal,
            weighted_avg_principal,avg_interest_rate,interest,hce_interest,
            base_weighted_avg_principal,avg_base_rate,gross_base_amount,
	    gross_contra_trans_amount, gross_contra_spot_amount)
          values(
             NEW_AS_AT_DATE,
             NEW_COMPANY_CODE,
             NEW_DEAL_TYPE,
             NEW_DEAL_SUBTYPE,
             NEW_CPARTY_CODE,
             NEW_PORTFOLIO_CODE,
             NEW_PRODUCT_TYPE,
             NEW_CURRENCY,
             NEW_CURRENCY_COMBINATION,
             NEW_CONTRA_CCY,
             NEW_ACCOUNT_NO,
             sysdate,   -- created_on
             NEW_BASE_REF_AMOUNT,  -- gross_principal
             NEW_HCE_BASE_REF_AMOUNT,  -- hce_gross_principal
             round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac), -- weightedavgprin
             NEW_TRANSACTION_RATE,    -- avg_interest_rate
             decode(NEW_DEAL_TYPE, 'FX', 0, NEW_INTEREST),         -- interest
	     decode(NEW_DEAL_TYPE, 'FX', 0, NEW_HCE_INTEREST),     -- hce_interest
             round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),  -- base_w_avg_prin
             NEW_BASE_RATE, -- avg_base_rate
	     decode(NEW_DEAL_TYPE, 'FX', abs(NEW_BASE_REF_AMOUNT), NULL),  -- gross_base_amount
	     decode(NEW_DEAL_TYPE, 'FX', round(abs(nvl(NEW_BASE_REF_AMOUNT,0)
					 *nvl(NEW_TRANSACTION_RATE,0)),l_fac), NULL), --gross_contra_trans
             decode(NEW_DEAL_TYPE, 'FX', round(abs(nvl(NEW_BASE_REF_AMOUNT,0)
                                         *nvl(NEW_BASE_RATE,0)),l_fac), NULL) --gross_contra_spot
             );
       end if;
  end if; /* Not IG deal_type */
/**************/
/* DELETE     */
/**************/
 elsif P_ACTION = 'DELETE' then
   l_currency :=OLD_CURRENCY;
   open get_rounding_factor;
   fetch get_rounding_factor into l_hce_rate,l_fac;
   close get_rounding_factor;

   if OLD_DEAL_TYPE = 'FX' then
     v_100 :=1;
     l_fac :=4;
   else
     v_100 :=100;
   end if;

   Open CHK_LOCK_ROWS(
                     OLD_AS_AT_DATE ,
                     OLD_COMPANY_CODE,
                     OLD_CPARTY_CODE,
                     OLD_DEAL_TYPE,
                     OLD_DEAL_SUBTYPE,
                     OLD_PRODUCT_TYPE,
                     OLD_PORTFOLIO_CODE,
                     OLD_CURRENCY,
                     OLD_CONTRA_CCY,
                     OLD_CURRENCY_COMBINATION,
                     OLD_ACCOUNT_NO
                     );
   fetch CHK_LOCK_ROWS into l_rowid,l_gross;
   if CHK_LOCK_ROWS%FOUND then
       close CHK_LOCK_ROWS;
       if OLD_DEAL_TYPE <> 'FX' and nvl(l_gross,0) = nvl(OLD_BASE_REF_AMOUNT,0) then
             delete from XTR_COST_OF_FUNDS
              where  rowid=l_rowid;
       else
	    if OLD_DEAL_TYPE = 'FX' then
                update XTR_COST_OF_FUNDS
                set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)-nvl(OLD_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                         nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
                GROSS_BASE_AMOUNT = nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),
                GROSS_CONTRA_TRANS_AMOUNT = nvl(GROSS_CONTRA_TRANS_AMOUNT,0)-
                                            abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_TRANSACTION_RATE,0),
                GROSS_CONTRA_SPOT_AMOUNT = nvl(GROSS_CONTRA_SPOT_AMOUNT,0)-
                                            abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_BASE_RATE,0),
                AVG_INTEREST_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_TRANS_AMOUNT,0)-
                                     abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_TRANSACTION_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0))),l_fac)),
                AVG_BASE_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_SPOT_AMOUNT,0)-
                                     abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_BASE_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0))),l_fac)),
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
                INTEREST = 0,
                HCE_INTEREST = 0
                where rowid=l_rowid;
	     else  -- deal type TMM, RTMM, NI, BOND, CA, IG
                update XTR_COST_OF_FUNDS
                set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)-nvl(OLD_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                         nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
                AVG_INTEREST_RATE = decode((nvl(INTEREST,0) - nvl(NEW_INTEREST,0)), 0, null,
			            abs((nvl(INTEREST,0) - nvl(NEW_INTEREST,0))/
				    (nvl(GROSS_PRINCIPAL,0) - nvl(NEW_BASE_REF_AMOUNT,0)))),
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
                AVG_BASE_RATE = abs(decode(nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),0,null,
                                    decode(nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                     -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                      nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),0,null,
                                     round(v_100*(nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                     -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                       nvl(OLD_BASE_RATE,0)/v_100,l_fac))/
                                      (nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)),l_fac)))),
                INTEREST = nvl(INTEREST,0) - nvl(OLD_INTEREST,0),
		HCE_INTEREST = nvl(HCE_INTEREST,0) - nvl(OLD_HCE_INTEREST,0)
                where rowid=l_rowid;
              end if;
          end if;
      else
          close CHK_LOCK_ROWS;
         -- insert new row
          insert into XTR_COST_OF_FUNDS
           (as_at_date,company_code,deal_type,
            deal_subtype,party_code,portfolio_code,product_type,
            currency,currency_combination,contra_ccy,
            account_no,created_on,
            gross_principal,hce_gross_principal,
            weighted_avg_principal,avg_interest_rate,interest,hce_interest,
            base_weighted_avg_principal,avg_base_rate,gross_base_amount,
	    gross_contra_trans_amount, gross_contra_spot_amount)
          values(
             OLD_AS_AT_DATE,
             OLD_COMPANY_CODE,
             OLD_DEAL_TYPE,
             OLD_DEAL_SUBTYPE,
             OLD_CPARTY_CODE,
             OLD_PORTFOLIO_CODE,
             OLD_PRODUCT_TYPE,
             OLD_CURRENCY,
             OLD_CURRENCY_COMBINATION,
             OLD_CONTRA_CCY,
             OLD_ACCOUNT_NO,
             sysdate,
             OLD_BASE_REF_AMOUNT,
             OLD_HCE_BASE_REF_AMOUNT,
             0-round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
             OLD_TRANSACTION_RATE,
	     decode(OLD_DEAL_TYPE, 'FX', 0, OLD_INTEREST),
	     decode(OLD_DEAL_TYPE, 'FX', 0, OLD_HCE_INTEREST),
             0-round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
             OLD_BASE_RATE,
             decode(OLD_DEAL_TYPE, 'FX', abs(OLD_BASE_REF_AMOUNT), NULL),  -- gross_base_amount
             decode(OLD_DEAL_TYPE, 'FX', round(abs(nvl(OLD_BASE_REF_AMOUNT,0)
                                         *nvl(OLD_TRANSACTION_RATE,0)),l_fac), NULL), --gross_contra_trans
             decode(OLD_DEAL_TYPE, 'FX', round(abs(nvl(OLD_BASE_REF_AMOUNT,0)
                                         *nvl(OLD_BASE_RATE,0)),l_fac), NULL) --gross_contra_spot
	     );
       end if;

/**************/
/* UPDATE     */
/**************/
 elsif  P_ACTION='UPDATE' then
  if (NEW_DEAL_TYPE<>'IG') then /* IG handled by maintain_position_history, see comments for maintain_cof_ig */

   l_currency :=NEW_CURRENCY;
   open get_rounding_factor;
   fetch get_rounding_factor into l_hce_rate,l_fac;
   close get_rounding_factor;

   if NEW_DEAL_TYPE = 'FX' then
     v_100 :=1;
     l_fac :=4;
   else
     v_100 :=100;
   end if;

   L_INTEREST :=NULL;
   L_INTEREST_HCE :=NULL;

   Open CHK_LOCK_ROWS(
                     NEW_AS_AT_DATE ,
                     NEW_COMPANY_CODE,
                     NEW_CPARTY_CODE,
                     NEW_DEAL_TYPE,
                     NEW_DEAL_SUBTYPE,
                     NEW_PRODUCT_TYPE,
                     NEW_PORTFOLIO_CODE,
                     NEW_CURRENCY,
                     NEW_CONTRA_CCY,
                     NEW_CURRENCY_COMBINATION,
                     NEW_ACCOUNT_NO
                     );
   fetch CHK_LOCK_ROWS into l_rowid,l_gross;
   if CHK_LOCK_ROWS%FOUND then
       close CHK_LOCK_ROWS;
       if NEW_DEAL_TYPE = 'FX' then
             update XTR_COST_OF_FUNDS
             set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)+nvl(NEW_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                         nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
                GROSS_BASE_AMOUNT = nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),
                GROSS_CONTRA_TRANS_AMOUNT = nvl(GROSS_CONTRA_TRANS_AMOUNT,0)+
                                            abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_TRANSACTION_RATE,0),
                GROSS_CONTRA_SPOT_AMOUNT = nvl(GROSS_CONTRA_SPOT_AMOUNT,0)+
                                            abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_BASE_RATE,0),
                AVG_INTEREST_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_TRANS_AMOUNT,0)+
                                     abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_TRANSACTION_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0))),l_fac)),
                AVG_BASE_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_SPOT_AMOUNT,0)+
                                     abs(nvl(NEW_BASE_REF_AMOUNT,0))*nvl(NEW_BASE_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)+abs(nvl(NEW_BASE_REF_AMOUNT,0))),l_fac)),
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),
                INTEREST = 0,
                HCE_INTEREST = 0
                where rowid=l_rowid;
        else   -- deal type TMM, RTMM, NI, BOND, ONC, CA, IG
             update XTR_COST_OF_FUNDS
             set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)+nvl(NEW_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                         nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
       	        AVG_INTEREST_RATE = decode((nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)
				    +nvl(NEW_BASE_REF_AMOUNT,0)), 0,null,
				   abs((nvl(INTEREST,0)-nvl(OLD_INTEREST,0)+nvl(NEW_INTEREST,0))/
			           (nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)+nvl(NEW_BASE_REF_AMOUNT,0))
					)) * 36500, -- bug 2345708
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),
                AVG_BASE_RATE = abs(decode(nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0),0,null,
                                    decode(nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                      +round(nvl(NEW_BASE_REF_AMOUNT,0)*
                                       nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),0,null,
                                       round(v_100*(nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                       +round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac))/
                                       (nvl(GROSS_PRINCIPAL,0)+nvl(NEW_BASE_REF_AMOUNT,0)),l_fac)))),
	        INTEREST = nvl(INTEREST,0) + nvl(NEW_INTEREST,0),
	        HCE_INTEREST = nvl(HCE_INTEREST,0) + nvl(NEW_HCE_INTEREST,0)
                where rowid=l_rowid;
         end if;
    else
         close CHK_LOCK_ROWS;
         -- insert new row
          insert into XTR_COST_OF_FUNDS
           (as_at_date,company_code,deal_type,
            deal_subtype,party_code,portfolio_code,product_type,
            currency,currency_combination,contra_ccy,
            account_no,created_on,
            gross_principal,hce_gross_principal,
            weighted_avg_principal,avg_interest_rate,interest,hce_interest,
            base_weighted_avg_principal,avg_base_rate, gross_base_amount,
	    gross_contra_trans_amount, gross_contra_spot_amount)
          values(
             NEW_AS_AT_DATE,
             NEW_COMPANY_CODE,
             NEW_DEAL_TYPE,
             NEW_DEAL_SUBTYPE,
             NEW_CPARTY_CODE,
             NEW_PORTFOLIO_CODE,
             NEW_PRODUCT_TYPE,
             NEW_CURRENCY,
             NEW_CURRENCY_COMBINATION,
             NEW_CONTRA_CCY,
             NEW_ACCOUNT_NO,
             sysdate,
             NEW_BASE_REF_AMOUNT,
             NEW_HCE_BASE_REF_AMOUNT,
             round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_TRANSACTION_RATE,0)/v_100,l_fac),
             NEW_TRANSACTION_RATE,
             decode(NEW_DEAL_TYPE, 'FX', 0, NEW_INTEREST),         -- interest
             decode(NEW_DEAL_TYPE, 'FX', 0, NEW_HCE_INTEREST),     -- hce_interest
             round(nvl(NEW_BASE_REF_AMOUNT,0)*nvl(NEW_BASE_RATE,0)/v_100,l_fac),
             NEW_BASE_RATE,
             decode(NEW_DEAL_TYPE, 'FX', abs(NEW_BASE_REF_AMOUNT), NULL),  -- gross_base_amount
             decode(NEW_DEAL_TYPE, 'FX', round(abs(nvl(NEW_BASE_REF_AMOUNT,0)
                                         *nvl(NEW_TRANSACTION_RATE,0)),l_fac), NULL), --gross_contra_trans
             decode(NEW_DEAL_TYPE, 'FX', round(abs(nvl(NEW_BASE_REF_AMOUNT,0)
                                         *nvl(NEW_BASE_RATE,0)),l_fac), NULL) --gross_contra_spot
             );
   end if;

   l_currency :=OLD_CURRENCY;
   open get_rounding_factor;
   fetch get_rounding_factor into l_hce_rate,l_fac;
   close get_rounding_factor;

   if NEW_DEAL_TYPE = 'FX' then
     v_100 :=1;
     l_fac :=4;
   else
     v_100 :=100;
   end if;

   open CHK_LOCK_ROWS(
                     OLD_AS_AT_DATE ,
                     OLD_COMPANY_CODE,
                     OLD_CPARTY_CODE,
                     OLD_DEAL_TYPE,
                     OLD_DEAL_SUBTYPE,
                     OLD_PRODUCT_TYPE,
                     OLD_PORTFOLIO_CODE,
                     OLD_CURRENCY,
                     OLD_CONTRA_CCY,
                     OLD_CURRENCY_COMBINATION,
                     OLD_ACCOUNT_NO
                     );
   fetch CHK_LOCK_ROWS into l_rowid,l_gross;
   if CHK_LOCK_ROWS%FOUND then
          close CHK_LOCK_ROWS;

          if OLD_DEAL_TYPE <> 'FX' and nvl(l_gross,0) = nvl(OLD_BASE_REF_AMOUNT,0) then
             delete from XTR_COST_OF_FUNDS
              where  rowid=l_rowid;
          else
             If NEW_DEAL_TYPE = 'FX' then
             -- For FX, we add 3 columns to calculate correct avg_interest_rate and avg_base_rate
                update XTR_COST_OF_FUNDS
                set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)-nvl(OLD_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                       -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                        nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
                GROSS_BASE_AMOUNT = nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),
                GROSS_CONTRA_TRANS_AMOUNT = nvl(GROSS_CONTRA_TRANS_AMOUNT,0)-
                                            abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_TRANSACTION_RATE,0),
                GROSS_CONTRA_SPOT_AMOUNT = nvl(GROSS_CONTRA_SPOT_AMOUNT,0)-
                                            abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_BASE_RATE,0),
                AVG_INTEREST_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_TRANS_AMOUNT,0)-
                                     abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_TRANSACTION_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0))),l_fac)),
                AVG_BASE_RATE = decode(nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0)),0,NULL,
                                    round((nvl(GROSS_CONTRA_SPOT_AMOUNT,0)-
                                     abs(nvl(OLD_BASE_REF_AMOUNT,0))*nvl(OLD_BASE_RATE,0))/
                                    (nvl(GROSS_BASE_AMOUNT,0)-abs(nvl(OLD_BASE_REF_AMOUNT,0))),l_fac)),
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
                INTEREST = 0,
                HCE_INTEREST = 0
                where rowid=l_rowid;
	    else  -- deal type TMM, RTMM, CA, IG, ONC, BOND, NI
                update XTR_COST_OF_FUNDS
                set GROSS_PRINCIPAL = nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),
                HCE_GROSS_PRINCIPAL =nvl(HCE_GROSS_PRINCIPAL,0)-nvl(OLD_HCE_BASE_REF_AMOUNT,0),
                WEIGHTED_AVG_PRINCIPAL = nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                       -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                        nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
                AVG_INTEREST_RATE =decode((nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)),0,null,
				   abs((nvl(INTEREST,0)-nvl(OLD_INTEREST,0))/
				       (nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)))) * 36500
,  -- bug 2345708
                BASE_WEIGHTED_AVG_PRINCIPAL = nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                        -round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
                AVG_BASE_RATE = abs(decode(nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0),0,null,
                                    decode(nvl(WEIGHTED_AVG_PRINCIPAL,0)
                                     -round(nvl(OLD_BASE_REF_AMOUNT,0)*
                                     nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),0,null,
                                     round(v_100*(nvl(BASE_WEIGHTED_AVG_PRINCIPAL,0)
                                     -round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac))/
                                     (nvl(GROSS_PRINCIPAL,0)-nvl(OLD_BASE_REF_AMOUNT,0)),l_fac)))),
                INTEREST = nvl(INTEREST,0) - nvl(OLD_INTEREST,0),
                HCE_INTEREST = nvl(HCE_INTEREST,0) - nvl(OLD_HCE_INTEREST,0)
                where rowid=l_rowid;
	     end if;
          end if;
   else
          close CHK_LOCK_ROWS;
         -- insert new row
          insert into XTR_COST_OF_FUNDS
           (as_at_date,company_code,deal_type,
            deal_subtype,party_code,portfolio_code,product_type,
            currency,currency_combination,contra_ccy,
            account_no,created_on,
            gross_principal,hce_gross_principal,
            weighted_avg_principal,avg_interest_rate,interest,hce_interest,
            base_weighted_avg_principal,avg_base_rate, gross_base_amount,
	    gross_contra_trans_amount, gross_contra_spot_amount)
          values(
             OLD_AS_AT_DATE,
             OLD_COMPANY_CODE,
             OLD_DEAL_TYPE,
             OLD_DEAL_SUBTYPE,
             OLD_CPARTY_CODE,
             OLD_PORTFOLIO_CODE,
             OLD_PRODUCT_TYPE,
             OLD_CURRENCY,
             OLD_CURRENCY_COMBINATION,
             OLD_CONTRA_CCY,
             OLD_ACCOUNT_NO,
             sysdate,
             OLD_BASE_REF_AMOUNT,
             OLD_HCE_BASE_REF_AMOUNT,
             0-round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_TRANSACTION_RATE,0)/v_100,l_fac),
             OLD_TRANSACTION_RATE,
	     decode(OLD_DEAL_TYPE, 'FX', 0, 0-OLD_INTEREST),  -- interest
	     decode(OLD_DEAL_TYPE, 'FX', 0, 0-OLD_HCE_INTEREST), --hce_interest
             0-round(nvl(OLD_BASE_REF_AMOUNT,0)*nvl(OLD_BASE_RATE,0)/v_100,l_fac),
             OLD_BASE_RATE,
             decode(OLD_DEAL_TYPE, 'FX', abs(OLD_BASE_REF_AMOUNT), NULL),  -- gross_base_amount
             decode(OLD_DEAL_TYPE, 'FX', round(abs(nvl(OLD_BASE_REF_AMOUNT,0)
                                         *nvl(OLD_TRANSACTION_RATE,0)),l_fac), NULL), --gross_contra_trans
             decode(OLD_DEAL_TYPE, 'FX', round(abs(nvl(OLD_BASE_REF_AMOUNT,0)
                                         *nvl(OLD_BASE_RATE,0)),l_fac), NULL) --gross_contra_spot
             );
    end if;
  end if; /* Not IG deal type */
 end if;

exception
 when app_exceptions.RECORD_LOCK_EXCEPTION then
  if CHK_LOCK_ROWS%ISOPEN then
     close CHK_LOCK_ROWS;
  end if;
 raise app_exceptions.RECORD_LOCK_EXCEPTION;
end MAINTAIN_COST_OF_FUND;


PROCEDURE SNAPSHOT_COST_OF_FUNDS(errbuf	OUT NOCOPY VARCHAR2,
                	         retcode OUT NOCOPY NUMBER) as
--
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
  -- Added the variable for Interest Override feature
  L_FIRST_TRANS_FLAG            VARCHAR2(1):= NULL;
  L_DAY_COUNT_TYPE              VARCHAR2(1):= NULL;
  L_cross_ref_start_date        DATE;
  L_ERRBUF     VARCHAR2(50);
  L_RETCODE    NUMBER;
  --

  /*************************************/
  /* Find FX, BOND deal information    */
  /*************************************/
cursor get_deals is
/*******/
/* FX  */
/*******/
 select a.deal_no deal_number,
        1 transaction_number,
        a.status_code status_code,
        a.company_code company_code,
        a.cparty_code cparty_code,
        a.deal_type deal_type,
        a.deal_subtype deal_subtype,
        a.currency currency,
        a.currency_buy currency_buy,
        a.currency_sell currency_sell,
        a.product_type,
        a.portfolio_code,
        'ACTUAL/ACTUAL'  year_calc_type,
        a.year_basis,
        a.interest_rate interest_rate,
        a.transaction_rate,
        a.base_rate base_rate,
        a.calc_basis,
        a.start_date,
        a.value_date,
        a.option_commencement,
        a.expiry_date,
        a.maturity_date,
        a.maturity_account_no account_no,
        a.buy_amount base_amount,
        a.sell_amount second_amount,
	a.maturity_amount,
        a.start_amount,
   -- Added for Interest Override feature
   -- But FX is always populate null value to day_count_type
        a.day_count_type
 from XTR_DEALS a
 where a.deal_type ='FX'
 and a.status_code <> 'CANCELLED'
 and a.deal_date <= l_date
 and nvl(a.start_date,l_date+1) > l_date
 and value_date >l_date
Union all
/*********/
/* BOND  */
/*********/
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
        a.transaction_rate,
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
        -- Added for Interest Override feature
        a.day_count_type
 from XTR_DEALS a
 where a.deal_type ='BOND'
 and a.deal_subtype in ('BUY', 'ISSUE')
 and a.status_code ='CURRENT'
 and a.start_date <=l_date
 and a.maturity_date > l_date
Union All
/****************/
/* Bond resale  */
/****************/
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
        a.transaction_rate,
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
        -- Added for the Interest Override feature
        a.day_count_type
 from XTR_DEALS a
 where a.deal_type ='BOND'
 and a.deal_subtype in ('BUY', 'ISSUE')    -- Bond Repurchase Project - 2879858.
 and a.status_code ='CURRENT'
 and a.deal_no in (select distinct d.deal_no
		   from XTR_DEALS d,
		        XTR_BOND_ALLOC_DETAILS R
		   where d.deal_no = r.deal_no
		   and d.maturity_date <= l_date
		   and nvl(r.avg_rate_last_processed, r.cross_ref_start_date)
		       < d.maturity_date);

  /*************************************/
  /* Find CA deal information          */
  /*************************************/
cursor get_ca is
 select a.party_code,
        a.currency,
        a.account_number,
        a.bank_code,
        a.portfolio_code,
        a.year_calc_type
 from xtr_bank_accounts a,
      xtr_party_info b
 where a.party_code=b.party_code
   and b.party_type='C'
   and nvl(a.setoff_account_yn,'N') ='N'
   and nvl(a.opening_balance,0) <> 0 ;

cursor get_ca_row is
 select nvl(balance_adjustment,0)+nvl(statement_balance,0) base_amount,
       interest_rate, balance_date, day_count_type -- Added day_count_type for Interest Override
 from xtr_bank_balances
  where company_code = L_COMPANY_CODE
    and account_number = L_ACCOUNT_NO
    and balance_date <= l_date
  order by balance_date desc;


  /*************************************/
  /* Find IG deal information          */
  /*************************************/
cursor get_ig is
 select a.deal_number,  -- bug 2345708
        a.amount_date,
	a.company_code,
        a.currency,
        a.account_no,
        a.limit_party,
        a.portfolio_code,
        a.product_type
 from xtr_mirror_dda_limit_row a
 where a.deal_type = 'IG';

cursor get_ig_row is
 select nvl(balance_out,0) base_amount,
        interest_rate,
        day_count_type  -- Added for Interest Override feature
 from xtr_intergroup_transfers
  where company_code = L_COMPANY_CODE
    and party_code= L_CPARTY_CODE
    and currency = L_CURRENCY
    and deal_number = L_DEAL_NUMBER
    and transfer_date <= l_date
  order by transfer_date desc,transaction_number desc;


  /**********************************************/
  /* Find TMM, RTMM, ONC, NI deal information   */
  /**********************************************/
cursor get_rt is
 select a.deal_number,
        a.transaction_number,
        a.status_code,
        a.company_code,
        a.cparty_code,
        a.deal_type,
        a.deal_subtype,
        a.currency,
        a.product_type,
        a.portfolio_code,
        a.year_calc_type,
        a.interest_rate,
        a.start_date,
        a.maturity_date,
        a.balance_out_bf base_amount,
        decode(nvl(a.principal_action,'DECRSE'),'INCRSE',
        nvl(a.PRINCIPAL_ADJUST,0),0-nvl(a.PRINCIPAL_ADJUST,0))  second_amount,
        a.interest,
        -- Added for Interest Override feature
        a.first_transaction_flag,
        d.day_count_type
 from XTR_ROLLOVER_TRANSACTIONS  a,
      -- Added for Interest Override feature
      XTR_DEALS d
 where a.deal_type in('TMM','RTMM')
   and a.start_date <=l_date
   and a.maturity_date >l_date
   and a.status_code='CURRENT'
   -- Added for Interest Override feature
   and d.deal_no = a.deal_number
Union all
 select a.deal_number,
        a.transaction_number,
        a.status_code,
        a.company_code,
        a.cparty_code,
        a.deal_type,
        a.deal_subtype,
        a.currency,
        a.product_type,
        a.portfolio_code,
        a.year_calc_type,
        a.interest_rate,
        a.start_date,
        a.maturity_date,
        a.balance_out base_amount,
        0  second_amount,
	a.interest,
        -- Added for Interest Override feature
        a.first_transaction_flag,
        d.day_count_type
 from XTR_ROLLOVER_TRANSACTIONS  a,
      -- Added for Interest Override feature
      XTR_DEALS d
 where a.deal_type ='ONC'
   and a.start_date <=l_date
   and nvl(a.maturity_date,l_date+1) >l_date
   and a.interest_rate is not null
   and a.status_code='CURRENT'
   -- Added for Interest Override feature
   and d.deal_no = a.deal_number
Union all
 select a.deal_number,
        a.transaction_number,
        a.status_code,
        a.company_code,
        a.cparty_code,
        a.deal_type,
        a.deal_subtype,
        a.currency,
        a.product_type,
        a.portfolio_code,
        a.year_calc_type,
        a.interest_rate,
        a.start_date,
        nvl(a.ni_reneg_date,a.maturity_date) maturity_date,
        nvl(a.balance_out,0)-nvl(a.interest,0) base_amount,
        0  second_amount,
	a.interest,
        -- Added for Interest Override feature
        a.first_transaction_flag,
        d.day_count_type
 from XTR_ROLLOVER_TRANSACTIONS  a,
      -- Added for Interest Override feature
      XTR_DEALS d
 where a.deal_type ='NI'
   and a.deal_subtype in ('BUY', 'ISSUE')
   and a.start_date <=l_date
   and nvl(a.ni_reneg_date,a.maturity_date) >l_date
   -- Added for Interest Override feature
   and d.deal_no = a.deal_number;

 D get_deals%rowtype;
 C get_ca%rowtype;
 G get_ig%rowtype;
 R get_rt%rowtype;

cursor GET_COM(P_CURRENCY_BUY varchar2,P_CURRENCY_SELL varchar2) is
 select CURRENCY_FIRST||'/'||CURRENCY_SECOND
  from XTR_BUY_SELL_COMBINATIONS
  where (CURRENCY_BUY = P_CURRENCY_BUY and CURRENCY_SELL = P_CURRENCY_SELL)
  or (CURRENCY_BUY = P_CURRENCY_SELL and CURRENCY_SELL = P_CURRENCY_BUY);
--
cursor get_ig_year_calc is
 select ig_year_basis
 from XTR_MASTER_CURRENCIES
   where currency = L_CURRENCY;
--
 cursor get_calc_basis is
  select calc_basis
   from xtr_deals
   where deal_no=L_DEAL_NUMBER;

 cursor get_bond_type is
 select b.year_calc_type, b.calc_type
 from XTR_DEALS A, XTR_BOND_ISSUES B
 where a.bond_issue = b.bond_issue_code
 and a.deal_no = D.DEAL_NUMBER;

 cursor chk_date_exits is
  select 1
    from XTR_COST_OF_FUNDS
     where as_at_date = l_date;

 cursor bond_total_resale is
 select sum(face_value), max(cross_ref_start_date)
 from xtr_bond_alloc_details
 where deal_no = D.DEAL_NUMBER
 and CROSS_REF_START_DATE <= l_date;


BEGIN
-- check time
--if to_number(to_char(l_run_date,'HH24')) <6 then
 l_date :=trunc(sysdate)-1;
--else
-- l_date :=trunc(sysdate);
--end if;

/**************/
/* FX, BOND   */
/**************/
open get_deals;
 LOOP
  fetch get_deals into D;
  exit WHEN get_deals%NOTFOUND;
     L_CURRENCY :=D.CURRENCY;
     L_AMOUNT :=D.BASE_AMOUNT;
     L_CONTRA_CCY :=NULL;
     L_CURRENCY_COMBINATION :=NULL;
     L_TRANSACTION_RATE :=D.INTEREST_RATE;
     L_ACCOUNT_NO :=NULL;
     L_YEAR_CALC_TYPE :=nvl(D.YEAR_CALC_TYPE,'ACTUAL/ACTUAL');

  If D.DEAL_TYPE = 'FX' then
     L_TRANSACTION_RATE :=D.TRANSACTION_RATE;

     open GET_COM(D.CURRENCY_BUY,D.CURRENCY_SELL);
     fetch GET_COM into L_CURRENCY_COMBINATION;
     close GET_COM;

     if D.CURRENCY_BUY =substr(L_CURRENCY_COMBINATION,1,3) then
       L_AMOUNT :=D.BASE_AMOUNT;
       L_CURRENCY :=D.CURRENCY_BUY;
       L_CONTRA_CCY :=D.CURRENCY_SELL;
     else
       L_AMOUNT :=0-D.SECOND_AMOUNT;
       L_CURRENCY :=D.CURRENCY_SELL;
       L_CONTRA_CCY :=D.CURRENCY_BUY;
     end if;
  elsif D.DEAL_TYPE ='BOND' then
     OPEN get_bond_type;
     FETCH get_bond_type into l_year_calc_type, l_calc_type;
     CLOSE get_bond_type;

     OPEN bond_total_resale;
     FETCH bond_total_resale into l_total_resale,l_cross_ref_start_date;
     if l_total_resale = D.MATURITY_AMOUNT then
    	Update XTR_BOND_ALLOC_DETAILS
        Set avg_rate_last_processed = L_DATE
        where deal_no = d.deal_number                      -- bug 4470022 Added where clause
        and cross_ref_start_date = l_cross_ref_start_date;
	close bond_total_resale;
     else
        CLOSE bond_total_resale;
     end if;

     -- Added for Interest Override feature
     IF D.DAY_COUNT_TYPE ='B' THEN
	l_first_trans_flag :='Y';
     END IF;
     --

  end if;
   if nvl(L_AMOUNT,0) <> 0 or (nvl(l_total_resale,0) <> D.MATURITY_AMOUNT) then
     XTR_COF_P.SNAPSHOT_POSITION_HISTORY(
        P_AS_AT_DATE                  => L_DATE,
        P_DEAL_NUMBER                 => D.DEAL_NUMBER,
        P_TRANSACTION_NUMBER          => D.TRANSACTION_NUMBER,
        P_COMPANY_CODE                => D.COMPANY_CODE,
        P_CURRENCY                    => L_CURRENCY,
        P_DEAL_TYPE                   => D.DEAl_TYPE,
        P_DEAL_SUBTYPE                => D.DEAL_SUBTYPE,
        P_PRODUCT_TYPE                => D.PRODUCT_TYPE,
        P_PORTFOLIO_CODE              => D.PORTFOLIO_CODE,
        P_CPARTY_CODE                 => D.CPARTY_CODE,
        P_CONTRA_CCY                  => L_CONTRA_CCY,
        P_CURRENCY_COMBINATION        => L_CURRENCY_COMBINATION,
        P_ACCOUNT_NO                  => L_ACCOUNT_NO,
        P_TRANSACTION_RATE            => L_TRANSACTION_RATE,
        P_YEAR_CALC_TYPE              => L_YEAR_CALC_TYPE,
        P_BASE_REF_AMOUNT             => L_AMOUNT,
        P_BASE_RATE                   => D.BASE_RATE,
        P_STATUS_CODE		      => D.STATUS_CODE,
	P_START_DATE		      => D.START_DATE,
	P_MATURITY_DATE		      => D.MATURITY_DATE,
        P_INTEREST                    => NULL,
        P_MATURITY_AMOUNT             => D.MATURITY_AMOUNT,
        P_START_AMOUNT                => D.START_AMOUNT,
	P_CALC_TYPE		      => L_CALC_TYPE,
        P_CALC_BASIS                  => NULL,
        P_DAY_COUNT_TYPE              => D.DAY_COUNT_TYPE,  -- Added for Interest Override
        P_FIRST_TRANS_FLAG            => L_FIRST_TRANS_FLAG -- Added for Interest Override
       );
    end if;
 END LOOP;
 close get_deals;

/**************/
/* CA         */
/**************/
 L_CONTRA_CCY :=NULL;
 L_CURRENCY_COMBINATION :=NULL;
 L_PRODUCT_TYPE :=NULL;
 open get_ca;
 LOOP
  fetch get_ca into C;
  exit WHEN get_ca%NOTFOUND;
     L_COMPANY_CODE :=C.PARTY_CODE;
     L_CURRENCY :=C.CURRENCY;
     L_YEAR_CALC_TYPE :=nvl(C.YEAR_CALC_TYPE,'ACTUAL/ACTUAL');
     L_CPARTY_CODE :=C.BANK_CODE;
     L_PORTFOLIO_CODE :=C.PORTFOLIO_CODE;
     L_ACCOUNT_NO :=C.ACCOUNT_NUMBER;

     L_AMOUNT :=0;
     L_TRANSACTION_RATE :=0;
     L_FIRST_TRANS_FLAG := NULL; -- Added for Intrest Override

     open get_ca_row;
     fetch get_ca_row into L_AMOUNT,L_TRANSACTION_RATE, L_START_DATE,
                           L_DAY_COUNT_TYPE; -- Added for Interest Override
     close get_ca_row;

     if L_AMOUNT >0 then
       L_DEAL_SUBTYPE :='INVEST';
     else
       L_DEAL_SUBTYPE :='FUND';
     end if;

   if nvl(L_AMOUNT,0) <> 0 then
   XTR_COF_P.SNAPSHOT_POSITION_HISTORY(
        P_AS_AT_DATE                  => L_DATE,
        P_DEAL_NUMBER                 => NULL,
        P_TRANSACTION_NUMBER          => NULL,
        P_COMPANY_CODE                => L_COMPANY_CODE,
        P_CURRENCY                    => L_CURRENCY,
        p_DEAL_TYPE                   => 'CA',
        P_DEAL_SUBTYPE                => L_DEAL_SUBTYPE,
        P_PRODUCT_TYPE                => L_PRODUCT_TYPE,
        P_PORTFOLIO_CODE              => L_PORTFOLIO_CODE,
        P_CPARTY_CODE                 => L_CPARTY_CODE,
        P_CONTRA_CCY                  => L_CONTRA_CCY,
        P_CURRENCY_COMBINATION        => L_CURRENCY_COMBINATION,
        P_ACCOUNT_NO                  => L_ACCOUNT_NO,
        P_TRANSACTION_RATE            => L_TRANSACTION_RATE,
        P_YEAR_CALC_TYPE              => L_YEAR_CALC_TYPE,
        P_BASE_REF_AMOUNT             => L_AMOUNT,
        P_BASE_RATE                   => NULL,
        P_STATUS_CODE		      => 'CURRENT',
	P_START_DATE		      => L_START_DATE,
	P_MATURITY_DATE		      => NULL,
        P_INTEREST                    => NULL,
        P_MATURITY_AMOUNT             => NULL,
        P_START_AMOUNT                => NULL,
        P_CALC_BASIS                  => NULL,
        P_CALC_TYPE		      => NULL,
        P_DAY_COUNT_TYPE              => L_DAY_COUNT_TYPE,  -- Added for Interest Override
        P_FIRST_TRANS_FLAG            => L_FIRST_TRANS_FLAG -- Added for Interest Override
);
   end if;
 END LOOP;
 close get_ca;

/**************/
/* IG         */
/**************/
 L_CONTRA_CCY :=NULL;
 L_CURRENCY_COMBINATION :=NULL;
 open get_ig;
 LOOP
  fetch get_ig into G;
  exit WHEN get_ig%NOTFOUND;
     L_DEAL_NUMBER := G.DEAL_NUMBER;
     L_START_DATE := G.AMOUNT_DATE;
     L_COMPANY_CODE :=G.COMPANY_CODE;
     L_CURRENCY :=G.CURRENCY;
     L_CPARTY_CODE :=G.LIMIT_PARTY;
     L_PORTFOLIO_CODE :=G.PORTFOLIO_CODE;
     L_PRODUCT_TYPE :=G.PRODUCT_TYPE;
     L_ACCOUNT_NO :=G.ACCOUNT_NO;

    open get_ig_year_calc;
    fetch get_ig_year_calc into L_YEAR_CALC_TYPE;
    close get_ig_year_calc;

     L_AMOUNT :=0;
     L_TRANSACTION_RATE :=0;

     open get_ig_row;
     fetch get_ig_row into L_AMOUNT,L_TRANSACTION_RATE, L_DAY_COUNT_TYPE;
     close get_ig_row;

     if L_AMOUNT >0 then
       L_DEAL_SUBTYPE :='INVEST';
     else
       L_DEAL_SUBTYPE :='FUND';
     end if;

   if L_AMOUNT <>0 then
   XTR_COF_P.SNAPSHOT_POSITION_HISTORY(
        P_AS_AT_DATE                  => L_DATE,
        P_DEAL_NUMBER                 => L_DEAL_NUMBER,
        P_TRANSACTION_NUMBER          => 1,
        P_COMPANY_CODE                => L_COMPANY_CODE,
        P_CURRENCY                    => L_CURRENCY,
        p_DEAL_TYPE                   => 'IG',
        P_DEAL_SUBTYPE                => L_DEAL_SUBTYPE,
        P_PRODUCT_TYPE                => L_PRODUCT_TYPE,
        P_PORTFOLIO_CODE              => L_PORTFOLIO_CODE,
        P_CPARTY_CODE                 => L_CPARTY_CODE,
        P_CONTRA_CCY                  => L_CONTRA_CCY,
        P_CURRENCY_COMBINATION        => L_CURRENCY_COMBINATION,
        P_ACCOUNT_NO                  => L_ACCOUNT_NO,
        P_TRANSACTION_RATE            => L_TRANSACTION_RATE,
        P_YEAR_CALC_TYPE              => L_YEAR_CALC_TYPE,
        P_BASE_REF_AMOUNT             => L_AMOUNT,
        P_BASE_RATE                   => NULL,
        P_STATUS_CODE		      => 'CURRENT',
        P_START_DATE                  => L_START_DATE,
        P_MATURITY_DATE               => NULL,
        P_INTEREST                    => NULL,
        P_MATURITY_AMOUNT             => NULL,
        P_START_AMOUNT                => NULL,
        P_CALC_BASIS                  => NULL,
        P_CALC_TYPE		      => NULL,
        P_DAY_COUNT_TYPE              => L_DAY_COUNT_TYPE,  -- Added for Interest Override
        P_FIRST_TRANS_FLAG            => L_FIRST_TRANS_FLAG -- Added for Interest Override
        );
   end if;
 END LOOP;
 close get_ig;

/***********************/
/* TMM, RTMM, NI, ONC  */
/***********************/
 open get_rt;
 LOOP
  fetch get_rt into R;
  exit WHEN get_rt%NOTFOUND;
     L_CURRENCY :=R.CURRENCY;
     L_AMOUNT :=nvl(R.BASE_AMOUNT,0)+nvl(R.SECOND_AMOUNT,0);
     L_CONTRA_CCY :=NULL;
     L_CURRENCY_COMBINATION :=NULL;
     L_TRANSACTION_RATE :=R.INTEREST_RATE;
     L_ACCOUNT_NO :=NULL;

     -- Added for the Interest Override feature
     -- Set FIRST_TRANS_FLAG
     IF R.DEAL_TYPE IN ('TMM','RTMM') THEN
	IF r.day_count_type ='B' AND r.first_transaction_flag=1 THEN
	      L_FIRST_TRANS_FLAG :='Y';
	 ELSE
	      L_FIRST_TRANS_FLAG := NULL;
	END IF;
     ELSIF R.DEAL_TYPE ='NI' THEN
	L_FIRST_TRANS_FLAG := 'Y';
     ELSIF R.DEAL_TYPE ='ONC' THEN
	L_FIRST_TRANS_FLAG := R.FIRST_TRANSACTION_FLAG;
     ELSE
	L_FIRST_TRANS_FLAG := NULL;
     END IF;
      --

     OPEN get_calc_basis;
     FETCH get_calc_basis into L_CALC_BASIS;
     CLOSE get_calc_basis;

  if nvl(L_AMOUNT,0) <> 0 then
     XTR_COF_P.SNAPSHOT_POSITION_HISTORY(
        P_AS_AT_DATE                  => L_DATE,
        P_DEAL_NUMBER                 => R.DEAL_NUMBER,
        P_TRANSACTION_NUMBER          => R.TRANSACTION_NUMBER,
        P_COMPANY_CODE                => R.COMPANY_CODE,
        P_CURRENCY                    => L_CURRENCY,
        P_DEAL_TYPE                   => R.DEAl_TYPE,
        P_DEAL_SUBTYPE                => R.DEAL_SUBTYPE,
        P_PRODUCT_TYPE                => R.PRODUCT_TYPE,
        P_PORTFOLIO_CODE              => R.PORTFOLIO_CODE,
        P_CPARTY_CODE                 => R.CPARTY_CODE,
        P_CONTRA_CCY                  => L_CONTRA_CCY,
        P_CURRENCY_COMBINATION        => L_CURRENCY_COMBINATION,
        P_ACCOUNT_NO                  => L_ACCOUNT_NO,
        P_TRANSACTION_RATE            => L_TRANSACTION_RATE,
        P_YEAR_CALC_TYPE              => L_YEAR_CALC_TYPE,
        P_BASE_REF_AMOUNT             => L_AMOUNT,
        P_BASE_RATE                   => NULL,
        P_STATUS_CODE		      => R.STATUS_CODE,
	P_START_DATE		      => R.START_DATE,
	P_MATURITY_DATE		      => R.MATURITY_DATE,
        P_INTEREST                    => R.INTEREST,
        P_MATURITY_AMOUNT             => NULL,
        P_START_AMOUNT                => NULL,
        P_CALC_BASIS                  => L_CALC_BASIS,
        P_CALC_TYPE		      => NULL,
        P_DAY_COUNT_TYPE              => R.DAY_COUNT_TYPE,  -- Added for Interest Override
        P_FIRST_TRANS_FLAG            => L_FIRST_TRANS_FLAG -- Added for Interest Override
       );
  end if;
 END LOOP;
 close get_rt;

  xtr_stock_position_p.snapshot_stk_cost_of_funds(l_errbuf, l_retcode);  -- bug 4466775 nyse enh


 end SNAPSHOT_COST_OF_FUNDS;

--
/*******************************************************************************/
/* This procedure is to calculate BOND yield rate based on ACTUAL/365. It is   */
/* called by XTR_COF_P.SNAPSHOT_COST_OF_FUND and trigger XTR_AI_DEALS_T        */
/* and XTR_AU_DEALS_T. It inputs the following information:                    */
/* p_deal_no      : XTR_DEALS.deal_no                                          */
/* p_maturity_amt : XTR_DEALS.maturity_amount                                  */
/* p_consideration: XTR_DEALS.start_amount                                     */
/* p_coupon_rate  : XTR_DEALS.coupon_rate                                      */
/* p_start_date   : XTR_DEALS.start_date                                       */
/* p_maturity_date: XTR_DEALS.maturity_date                                    */
/* p_year_basis   : year basis (365 or 360)                                    */
/* p_disc_prem	  : discount or premium                                        */
/* p_yield_rate   : output rate as simple, annualized rate                     */
/*******************************************************************************/
PROCEDURE CALCULATE_BOND_RATE(
        p_deal_no		IN NUMBER,
        p_maturity_amt          IN NUMBER,
        p_consideration         IN NUMBER,
        p_coupon_rate           IN NUMBER,
        p_start_date            IN DATE,
        p_maturity_date         IN DATE,
        p_calc_type             IN VARCHAR2,
	p_daily_int		OUT NOCOPY NUMBER,
	p_yield_rate            OUT NOCOPY NUMBER,
	p_day_count_type        IN VARCHAR2   -- Added for Interest Override
			      )IS

l_year_basis_in NUMBER;
l_year_basis_out NUMBER;
l_no_of_days_in NUMBER;
l_no_of_days_out NUMBER;
l_coupon	NUMBER;
l_rate1		NUMBER;
-- Added for Interest Override feature
l_num_of_days   NUMBER;
l_interest      NUMBER;
l_original_amount NUMBER;
l_orig_coupon   NUMBER;
l_resale_count  NUMBER;

BEGIN
  /*------------------------------------------------*/
  /* Step 1: Calculate total coupon interest amount */
  /*------------------------------------------------*/
   -- Changed for Interest Override
--   Select SUM(orig_coupon_amount)
--    Into l_coupon
--    From xtr_rollover_transactions
--    Where deal_number = p_deal_no;
   Select SUM(orig_coupon_amount),SUM(interest),SUM(original_amount)
    Into l_orig_coupon,l_interest,l_original_amount
    From xtr_rollover_transactions
     Where deal_number = p_deal_no;

   SELECT COUNT(deal_no)
     INTO l_resale_count
     FROM xtr_bond_alloc_details
     WHERE deal_no=p_deal_no;

   IF l_resale_count>0 AND l_interest <> l_original_amount THEN
      l_coupon := l_interest;
    ELSE
      l_coupon := l_orig_coupon;
   END IF;
   --
   /*----------------------------------*/
  /* Step 2: Calculate Daily Interest */
  /*----------------------------------*/

    -- Added for the Interest Override feature
    IF p_day_count_type ='B' THEN
       l_num_of_days := p_maturity_date - p_start_date +1;
     ELSE
       l_num_of_days := p_maturity_date - p_start_date;
    END IF;

    if p_calc_type = 'ZERO COUPON' then
       -- Changed to l_num_of_days for Interest Override feature
	p_daily_int := (p_maturity_amt - p_consideration) /l_num_of_days;
    else
        p_daily_int := (l_coupon + p_maturity_amt - p_consideration)
         	       / l_num_of_days;
    end if;

  /*-------------------------------------------------------------*/
  /* Step 3: Calculate a simple, annual rate based on ACTUAL/365 */
  /*-------------------------------------------------------------*/
    p_yield_rate := (p_daily_int * 365) * 100 / p_consideration;

END CALCULATE_BOND_RATE;

/******************************************************************************/
/* Upload_Avg_Rates_Results can be called from a form via Find Window or
 * from a report with the necessary parameters to query the Cost of Funds table
 * and insert that summary information in the "temporary" XTR_AVG_RATES_RESULTS
 * table.  This table is actually always in the database but data that is
 * inserted is never committed so the results can be seen during a session
 * and erased once the session is over.  This way no maintenance is necessary
 * for this table.
 * This procedure takes an unique batch id so the caller can distinguish one
 * result set from another.  Currently, the XTR_EXPOSURE_TRANS_S sequence is
 * used to generate the id so it is advisable to use it to keep the uniqueness.
 */
PROCEDURE UPLOAD_AVG_RATES_RESULTS(
	p_batch_id		IN NUMBER,
	p_group_type		IN VARCHAR2,
	p_date_from		IN DATE,
	p_date_to		IN DATE,
	p_company_code		IN VARCHAR2,
	p_deal_type		IN VARCHAR2,
	p_currency		IN VARCHAR2,
	p_contra_ccy		IN VARCHAR2,
	p_cparty_code		IN VARCHAR2,
	p_product_type		IN VARCHAR2,
	p_portfolio_code	IN VARCHAR2,
	p_group_by_month 	IN VARCHAR2,
	p_group_by_year		IN VARCHAR2,
	p_group_by_company 	IN VARCHAR2,
	p_group_by_deal		IN VARCHAR2,
	p_group_by_currency	IN VARCHAR2,
	p_group_by_cparty	IN VARCHAR2,
	p_group_by_product	IN VARCHAR2,
	p_group_by_portfolio	IN VARCHAR2) IS
--
 v_date_format  VARCHAR2(15);
 v_from_date	DATE;
 v_to_date	DATE;
 v_p_i		VARCHAR2(1);
 v_period	VARCHAR2(15);
 v_company	VARCHAR2(7);
 v_user_deal	VARCHAR2(7);
 v_deal		VARCHAR2(7);
 v_product	VARCHAR2(10);
 v_portfolio	VARCHAR2(7);
 v_cparty	VARCHAR2(7);
 v_currency	VARCHAR2(15);
 v_currency_combination	VARCHAR2(31);
 v_principal	NUMBER;
 v_interest	NUMBER;
 v_avg_contract_rate NUMBER;
 v_avg_spot_rate NUMBER;
 v_min_rate	NUMBER;
 v_max_rate	NUMBER;
 v_num_deals	NUMBER;
-- Obtain COF summary for group type of INVEST and company is specified
 CURSOR c_get_invest_comp IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	Decode(p_group_by_currency, 'Y', currency, Null), -- currency,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
	Sum(Decode(p_currency, Null, hce_gross_principal, gross_principal))/(p_date_to - p_date_from + 1) principal,
  --  Sum(interest) interest,  RV Bug# 1291156 06-APR-2001
      Sum(Decode(p_currency,Null,hce_interest,interest)) interest,
      decode(Sum(gross_principal),0,0,
        (sum(interest) * 36500 /(sum(gross_principal)/(p_date_to-p_date_from+1))
        /(p_date_to - p_date_from +1))) avg_rate,
  	Sum(no_of_deals) num_deals
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code = p_company_code
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND (   (deal_type = 'NI' AND deal_subtype = 'BUY')
        OR (deal_type = 'BOND' AND deal_subtype = 'BUY')
	OR (deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM') AND deal_subtype = p_group_type)  )
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	Decode(p_group_by_currency, 'Y', currency, Null),
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);


----
-- Obtain COF summary for group type of INVEST and company is NOT specified
 CURSOR c_get_invest_all IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	Decode(p_group_by_currency, 'Y', currency, Null), -- currency,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
	Sum(Decode(p_currency, Null, hce_gross_principal, gross_principal))/(p_date_to - p_date_from + 1) principal,
  --  Sum(interest) interest,  RV Bug# 1291156 06-APR-2001
      Sum(Decode(p_currency,Null,hce_interest,interest)) interest,
      decode(Sum(gross_principal),0,0,
        (sum(interest) * 36500 /(sum(gross_principal)/(p_date_to-p_date_from+1))
        /(p_date_to - p_date_from +1))) avg_rate,
  	Sum(no_of_deals) num_deals
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code IN (SELECT p.party_code
			FROM xtr_parties_v p
			WHERE p.party_type = 'C')
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND (   (deal_type = 'NI' AND deal_subtype = 'BUY')
        OR (deal_type = 'BOND' AND deal_subtype = 'BUY')
	OR (deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM') AND deal_subtype = p_group_type)  )
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	Decode(p_group_by_currency, 'Y', currency, Null),
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);

----
-- Obtain COF summary for group type of FUND and company is specified
 CURSOR c_get_fund_comp IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	Decode(p_group_by_currency, 'Y', currency, Null), -- currency,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
	Sum(Decode(p_currency, Null, hce_gross_principal, gross_principal))/(p_date_to - p_date_from + 1) principal,
  --  Sum(interest) interest,  RV Bug# 1291156 06-APR-2001
      Sum(Decode(p_currency,Null,hce_interest,interest)) interest,
      decode(Sum(gross_principal),0,0,
        (sum(interest) * 36500 /(sum(gross_principal)/(p_date_to-p_date_from+1))
        /(p_date_to - p_date_from +1))) avg_rate,
  	Sum(no_of_deals) num_deals
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code = p_company_code
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND (   (deal_type = 'NI' AND deal_subtype = 'ISSUE')
        OR (deal_type = 'BOND' AND deal_subtype = 'ISSUE')
	OR (deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM') AND deal_subtype = p_group_type)  )
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	Decode(p_group_by_currency, 'Y', currency, Null),
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);

----
-- Obtain COF summary for group type of FUND and company is NOT specified
 CURSOR c_get_fund_all IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	Decode(p_group_by_currency, 'Y', currency, Null), -- currency,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
	Sum(Decode(p_currency, Null, hce_gross_principal, gross_principal))/(p_date_to - p_date_from + 1) principal,
  --  Sum(interest) interest,  RV Bug# 1291156 06-APR-2001
      Sum(Decode(p_currency,Null,hce_interest,interest)) interest,
      decode(Sum(gross_principal),0,0,
        (sum(interest) * 36500 /(sum(gross_principal)/(p_date_to-p_date_from+1))
        /(p_date_to - p_date_from +1))) avg_rate,
  	Sum(no_of_deals) num_deals
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code IN (SELECT p.party_code
			FROM xtr_parties_v p
			WHERE p.party_type = 'C')
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND (   (deal_type = 'NI' AND deal_subtype = 'ISSUE')
        OR (deal_type = 'BOND' AND deal_subtype = 'ISSUE')
	OR (deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM') AND deal_subtype = p_group_type)  )
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	Decode(p_group_by_currency, 'Y', currency, Null),
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);

----
-- Obtain COF summary for group type of FX and company is specified
 CURSOR c_get_fx_comp IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	currency_combination,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
        Sum(gross_principal)/((p_date_to-p_date_from)+1) principal,
        Sum(interest) interest,
	Decode(sum(gross_base_amount),0,0, Sum(gross_contra_trans_amount)/Sum(gross_base_amount)) avg_rate,
  	Sum(no_of_deals) num_deals,
	Decode(Sum(gross_base_amount),0,0, Sum(gross_contra_spot_amount)/Sum(gross_base_amount)) avg_spot_rate
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code = p_company_code
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND deal_type = 'FX'
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(contra_ccy,'%') LIKE Nvl(p_contra_ccy,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	currency_combination,
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);

----
-- Obtain COF summary for group type of FX and company is NOT specified
 CURSOR c_get_fx_all IS
  SELECT 'P', -- p_i,
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)), -- as_at_date,
        Decode(p_group_by_company, 'Y', company_code, Null), -- company_code,
	Decode(p_group_by_deal, 'Y', deal_type, Null), -- deal_type,
	currency_combination,
        Decode(p_group_by_product, 'Y', product_type, Null), -- product_type,
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null), -- portfolio_code,
	Decode(p_group_by_cparty, 'Y', party_code, Null), -- party_code,
        Sum(gross_principal)/((p_date_to-p_date_from)+1) principal,
        Sum(interest) interest,
        Decode(sum(gross_base_amount),0,0, Sum(gross_contra_trans_amount)/Sum(gross_base_amount)) avg_rate,
        Sum(no_of_deals) num_deals,
        Decode(Sum(gross_base_amount),0,0, Sum(gross_contra_spot_amount)/Sum(gross_base_amount)) avg_spot_rate
  FROM xtr_cost_of_funds_v
  WHERE as_at_date BETWEEN p_date_from AND p_date_to
   AND company_code IN (SELECT p.party_code
			FROM xtr_parties_v p
			WHERE p.party_type = 'C')
   AND deal_type LIKE Nvl(p_deal_type,'%')
   AND deal_type = 'FX'
   AND currency LIKE Nvl(p_currency,'%')
   AND Nvl(contra_ccy,'%') LIKE Nvl(p_contra_ccy,'%')
   AND Nvl(party_code,'%') LIKE Nvl(p_cparty_code,'%')
   AND Nvl(portfolio_code,'%') LIKE Nvl(p_portfolio_code,'%')
   AND Nvl(product_type,'%') LIKE Nvl(p_product_type,'%')
  GROUP BY 'P',
	Decode(v_date_format, 'MM/DD/YYYY', Null, to_char(as_at_date, v_date_format)),
        Decode(p_group_by_company, 'Y', company_code, Null),
	Decode(p_group_by_deal, 'Y', deal_type, Null),
	currency_combination,
        Decode(p_group_by_product, 'Y', product_type, Null),
	Decode(p_group_by_portfolio, 'Y', portfolio_code, Null),
	Decode(p_group_by_cparty, 'Y', party_code, Null);

----
-- Find min and max trans rates for INVEST deals queried with the given criteria
 CURSOR c_get_minmax_rate_invest (p_from_date VARCHAR2, p_to_date VARCHAR2, p_p_i VARCHAR2) IS
  SELECT Min(transaction_rate), Max(transaction_rate)
  FROM xtr_position_history
  WHERE as_at_date BETWEEN p_from_date and p_to_date
    AND ((v_company IS NOT NULL AND company_code = v_company)
      OR (v_company IS NULL AND
	  company_code IN (SELECT p.party_code
				FROM xtr_parties_v p
				WHERE p.party_type = 'C')))
    AND deal_type LIKE Nvl(v_deal, '%')
    AND (product_type LIKE Nvl(v_product, '%') or product_type is null)
    AND (portfolio_code LIKE Nvl(v_portfolio, '%') or portfolio_code is null)
    AND (cparty_code LIKE Nvl(v_cparty, '%') or cparty_code is null)
    AND ((p_p_i = 'P') AND ((deal_type = 'NI' AND deal_subtype = 'BUY')
                          OR (deal_type = 'BOND' AND deal_subtype = 'BUY')
			  OR ((deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM')) AND (deal_subtype = p_group_type))));

--
-- Find min and max trans rates for FUND deals queried with the given criteria
 CURSOR c_get_minmax_rate_fund (p_from_date VARCHAR2, p_to_date VARCHAR2, p_p_i VARCHAR2) IS
  SELECT Min(transaction_rate), Max(transaction_rate)
  FROM xtr_position_history
  WHERE as_at_date BETWEEN p_from_date and p_to_date
    AND ((v_company IS NOT NULL AND company_code = v_company)
      OR (v_company IS NULL AND
	  company_code IN (SELECT p.party_code
				FROM xtr_parties_v p
				WHERE p.party_type = 'C')))
    AND deal_type LIKE Nvl(v_deal, '%')
    AND (product_type LIKE Nvl(v_product, '%') or product_type is null)
    AND (portfolio_code LIKE Nvl(v_portfolio, '%') or portfolio_code is null)
    AND (cparty_code LIKE Nvl(v_cparty, '%') or cparty_code is null)
    AND ((p_p_i = 'P') AND ((deal_type = 'NI' AND deal_subtype = 'ISSUE')
                          OR (deal_type = 'BOND' AND deal_subtype = 'ISSUE')
			  OR ((deal_type IN ('ONC', 'CA', 'IG', 'TMM', 'RTMM')) AND (deal_subtype = p_group_type))));
--
-- Find min and max trans rates for FX deals queried with the given criteria
 CURSOR c_get_minmax_rate_fx (p_from_date VARCHAR2, p_to_date VARCHAR2, p_p_i VARCHAR2) IS
  SELECT Min(transaction_rate), Max(transaction_rate)
  FROM xtr_position_history
  WHERE as_at_date BETWEEN p_from_date and p_to_date
    AND ((v_company IS NOT NULL AND company_code = v_company)
      OR (v_company IS NULL AND
	  company_code IN (SELECT p.party_code
				FROM xtr_parties_v p
				WHERE p.party_type = 'C')))
    AND deal_type LIKE Nvl(v_deal, '%')
    AND (product_type LIKE Nvl(v_product, '%') or product_type is null)
    AND (portfolio_code LIKE Nvl(v_portfolio, '%') or portfolio_code is null)
    AND (cparty_code LIKE Nvl(v_cparty, '%') or cparty_code is null)
    AND (currency_combination LIKE Nvl(v_currency_combination, '%') or
         currency_combination is null)
    AND ((p_p_i = 'P') AND (deal_type = 'FX'));
--
BEGIN
 IF Nvl(p_group_by_month,'N') = 'Y' THEN
   v_date_format := 'MM/YYYY';
 ELSIF Nvl(p_group_by_year,'N') = 'Y' THEN
   v_date_format := 'YYYY';
 ELSE
   v_date_format := 'MM/DD/YYYY';
 END IF;
 -- Figure out which cursor to open
 IF p_company_code IS NULL THEN
   IF p_group_type = 'INVEST' THEN
     OPEN c_get_invest_all;
   ELSIF p_group_type = 'FUND' THEN
     OPEN c_get_fund_all;
   ELSE
     OPEN c_get_fx_all;
   END IF;
 ELSE
   IF p_group_type = 'INVEST' THEN
     OPEN c_get_invest_comp;
   ELSIF p_group_type = 'FUND' THEN
     OPEN c_get_fund_comp;
   ELSE
     OPEN c_get_fx_comp;
   END IF;
 END IF;
 LOOP
   IF p_company_code IS NULL THEN
     IF p_group_type = 'INVEST' THEN
       FETCH c_get_invest_all INTO v_p_i, v_period, v_company,
	v_deal, v_currency,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals;
       EXIT WHEN c_get_invest_all%NOTFOUND;
     ELSIF p_group_type = 'FUND' THEN
       FETCH c_get_fund_all INTO v_p_i, v_period, v_company,
	v_deal, v_currency,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals;
       EXIT WHEN c_get_fund_all%NOTFOUND;
     ELSE
       FETCH c_get_fx_all INTO v_p_i, v_period, v_company,
	v_deal, v_currency_combination,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals, v_avg_spot_rate;
       EXIT WHEN c_get_fx_all%NOTFOUND;
     END IF;
   ELSE
     IF p_group_type = 'INVEST' THEN
       FETCH c_get_invest_comp INTO v_p_i, v_period, v_company,
	v_deal, v_currency,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals;
       EXIT WHEN c_get_invest_comp%NOTFOUND;
     ELSIF p_group_type = 'FUND' THEN
       FETCH c_get_fund_comp INTO v_p_i, v_period, v_company,
	v_deal, v_currency,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals;
       EXIT WHEN c_get_fund_comp%NOTFOUND;
     ELSE
       FETCH c_get_fx_comp INTO v_p_i, v_period, v_company,
	v_deal, v_currency_combination,
	v_product, v_portfolio, v_cparty, v_principal,
	v_interest, v_avg_contract_rate, v_num_deals, v_avg_spot_rate;
       EXIT WHEN c_get_fx_comp%NOTFOUND;
     END IF;
   END IF;
   -- Find the date range
   -- Assume By Month is 'MM/YYYY'
   --        By Year is 'YYYY'
   IF v_period IS NOT NULL THEN
     IF v_period = To_Char(p_date_from, v_date_format) THEN
       v_from_date := p_date_from;
     ELSE
       IF Nvl(p_group_by_month, 'N') = 'Y' THEN
         v_from_date := to_date('01/'||v_period, 'DD/MM/YYYY');
       ELSE
         v_from_date := to_date('01/01'||v_period, 'DD/MM/YYYY');
       END IF;
     END IF;
     IF v_period = To_Char(p_date_to, v_date_format) THEN
       v_to_date := p_date_to;
     ELSE
       IF Nvl(p_group_by_month, 'N') = 'Y' THEN
         v_to_date := last_day(to_date(v_period, v_date_format));
       ELSE
         v_to_date := to_date('31/12'||v_period, 'DD/MM/YYYY');
       END IF;
     END IF;
   ELSE
     v_from_date := p_date_from;
     v_to_date := p_date_to;
   END IF;

   -- get min/max transaction rate per row
   IF p_group_type = 'INVEST' THEN
     OPEN c_get_minmax_rate_invest(v_from_date, v_to_date, v_p_i);
     FETCH c_get_minmax_rate_invest INTO v_min_rate, v_max_rate;
     CLOSE c_get_minmax_rate_invest;
   ELSIF p_group_type = 'FUND' THEN
     OPEN c_get_minmax_rate_fund(v_from_date, v_to_date, v_p_i);
     FETCH c_get_minmax_rate_fund INTO v_min_rate, v_max_rate;
     CLOSE c_get_minmax_rate_fund;
   ELSE
     OPEN c_get_minmax_rate_fx(v_from_date, v_to_date, v_p_i);
     FETCH c_get_minmax_rate_fx INTO v_min_rate, v_max_rate;
     CLOSE c_get_minmax_rate_fx;
   END IF;

   INSERT INTO xtr_avg_rates_results(unique_id, p_i, period, date_from, date_to, company_code, deal_type,
       product_type, portfolio_code, cparty_code, currency, currency_combination, principal,
       interest, average_contract_rate, average_spot_rate, minimum_rate, maximum_rate, num_deals)
       VALUES(
	p_batch_id, v_p_i, v_period,
	v_from_date, v_to_date, v_company,
	v_deal, v_product, v_portfolio, v_cparty,
	v_currency, v_currency_combination, v_principal,
	v_interest, v_avg_contract_rate, v_avg_spot_rate,
	v_min_rate, v_max_rate, v_num_deals);
 END LOOP;

 -- Figure out which cursor to close
 IF p_company_code IS NULL THEN
   IF p_group_type = 'INVEST' THEN
     CLOSE c_get_invest_all;
   ELSIF p_group_type = 'FUND' THEN
     CLOSE c_get_fund_all;
   ELSE
     CLOSE c_get_fx_all;
   END IF;
 ELSE
   IF p_group_type = 'INVEST' THEN
     CLOSE c_get_invest_comp;
   ELSIF p_group_type = 'FUND' THEN
     CLOSE c_get_fund_comp;
   ELSE
     CLOSE c_get_fx_comp;
   END IF;
 END IF;

END UPLOAD_AVG_RATES_RESULTS;

end XTR_COF_P;

/
