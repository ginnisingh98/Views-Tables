--------------------------------------------------------
--  DDL for Package Body IGI_IAC_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_COMMON_UTILS" AS
-- $Header: igiiacub.pls 120.23.12010000.3 2010/06/24 10:52:30 schakkin ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	  ;
g_proc_level  NUMBER	  ;
g_event_level NUMBER	  ;
g_excep_level NUMBER	  ;
g_error_level NUMBER	  ;
g_unexp_level NUMBER	  ;
g_path        VARCHAR2(100) ;

--===========================FND_LOG.END=====================================

    PROCEDURE do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
    END;

-- DMahajan Start

Function Get_Period_Info_for_Counter( P_book_type_Code IN VARCHAR2 ,
                                                        P_period_Counter IN NUMBER ,
                                                        P_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                        )
RETURN BOOLEAN AS
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'get_period_info_for_counter';
    BEGIN
        SELECT  dp.period_num, dp.period_name, dp.calendar_period_open_date ,
                dp.calendar_period_close_date , p_period_counter, dp.fiscal_year
        INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
        FROM    fa_deprn_periods dp
        WHERE   dp.book_type_code = P_book_type_code
        AND     dp.period_counter = P_period_counter ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT  cp.period_num, cp.period_name, cp.start_date ,
                    cp.end_Date  , p_period_counter, fy.fiscal_year
            INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                    p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
	    FROM   fa_fiscal_year fy ,
		   fa_calendar_types ct ,
		   fa_calendar_periods cp,
		   fa_book_controls    bc
	    WHERE  ct.fiscal_year_name = fy.fiscal_year_name
	    AND    bc.book_type_code = P_book_type_code
	    AND    ct.calendar_type = bc.deprn_Calendar
	    AND    fy.fiscal_year   = decode( mod ( P_period_counter , ct.number_per_fiscal_year ) , 0 ,
                                      trunc ( P_period_counter / ct.number_per_fiscal_year ) -1 ,
                                      trunc ( P_period_counter / ct.number_per_fiscal_year ) )
	    AND    cp.calendar_type = ct.calendar_type
	    AND    cp.start_Date >= fy.start_date
	    AND    cp.end_Date <= fy.end_Date
	    AND    cp.period_num = decode( mod ( P_period_counter , ct.number_per_fiscal_year ),0 ,ct.number_per_fiscal_year,
	                                   mod ( P_period_counter , ct.number_per_fiscal_year ));
            RETURN TRUE;
    END;

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;



 Function Get_Period_Info_for_Date( P_book_type_Code IN VARCHAR2 ,
                                                     P_date           IN DATE ,
                                                     p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                     )
RETURN BOOLEAN AS
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'get_period_info_for_date';
    BEGIN
        SELECT  dp.period_num, dp.period_name, dp.calendar_period_open_date ,
                dp.calendar_period_close_date , dp.period_counter, dp.fiscal_year
        INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
        FROM    fa_deprn_periods dp
        WHERE   dp.book_type_code = P_book_type_code
        AND     P_date between dp.calendar_period_open_Date and dp.calendar_period_close_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT  cp.period_num, cp.period_name, cp.start_date ,
                    cp.end_Date  ,
                    ((fy.fiscal_year*ct.number_per_fiscal_year)+cp.period_num) p_period_counter,
                    fy.fiscal_year
            INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                    p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
	    FROM   fa_fiscal_year fy ,
		   fa_calendar_types ct ,
		   fa_calendar_periods cp ,
		   fa_book_controls    bc
	    WHERE  ct.fiscal_year_name = fy.fiscal_year_name
	    AND    bc.book_type_code = P_book_type_code
	    AND    ct.calendar_type = bc.deprn_Calendar
	    AND    P_date between cp.start_date and cp.end_Date
	    AND    P_date between fy.start_date and fy.end_Date
	    AND    cp.calendar_type = ct.calendar_type
	    AND    cp.start_Date >= fy.start_date
	    AND    cp.end_Date <= fy.end_Date;
    END;

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;



 Function Get_Period_Info_for_Name( P_book_type_Code IN VARCHAR2 ,
                                                     P_Prd_Name       IN VARCHAR2 ,
                                                     p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                     )
RETURN BOOLEAN AS
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'get_period_info_for_name';
    BEGIN
        SELECT  dp.period_num, dp.period_name, dp.calendar_period_open_date ,
                dp.calendar_period_close_date , dp.period_counter, dp.fiscal_year
        INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
        FROM    fa_deprn_periods dp
        WHERE   dp.book_type_code = P_book_type_code
        AND     dp.period_name    = P_prd_name ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT  cp.period_num, cp.period_name, cp.start_date ,
                    cp.end_Date  ,
                    ((fy.fiscal_year*ct.number_per_fiscal_year)+cp.period_num) p_period_counter,
                    fy.fiscal_year
            INTO    p_prd_rec.period_num, p_prd_rec.period_name, p_prd_rec.period_start_date,
                    p_prd_rec.period_end_date, p_prd_rec.period_counter , p_prd_rec.fiscal_year
	    FROM   fa_fiscal_year fy ,
		   fa_calendar_types ct ,
		   fa_calendar_periods cp ,
		   fa_book_controls    bc
	    WHERE  ct.fiscal_year_name = fy.fiscal_year_name
	    AND    bc.book_type_code = P_book_type_code
	    AND    ct.calendar_type = bc.deprn_Calendar
	    AND    cp.calendar_type = ct.calendar_type
	    AND    cp.period_name = P_prd_name
	    AND    cp.start_Date >= fy.start_date
	    AND    cp.end_Date <= fy.end_Date;
    END;

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;



Function Get_Open_Period_Info ( P_book_type_Code IN VARCHAR2 ,
                                                  p_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                                  )
RETURN BOOLEAN AS
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'get_open_period_info';
    SELECT dp.Period_Name, dp.Period_Counter, dp.Period_Num,
           dp.Fiscal_Year, dp.calendar_Period_open_Date, dp.calendar_Period_close_Date
    INTO   p_prd_rec.Period_Name, p_prd_rec.Period_Counter, p_prd_rec.Period_Num,
           p_prd_rec.Fiscal_Year, p_prd_rec.Period_Start_Date, p_prd_rec.Period_End_Date
    FROM    fa_deprn_periods dp
    WHERE   dp.book_type_code = P_book_type_code
    AND     dp.period_close_date IS NULL ;

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;





Function Get_Retirement_Info ( P_Retirement_Id   IN NUMBER ,
                                                 P_Retire_Info    OUT NOCOPY fa_retirements%ROWTYPE
                                                 )
RETURN BOOLEAN AS

    l_index  NUMBER;
    l_path_name VARCHAR2(150);

    CURSOR c_ret IS
        SELECT *
        FROM   fa_retirements
        WHERE  retirement_id = P_Retirement_Id ;

BEGIN
    l_index  := 0 ;
    l_path_name := g_path||'get_retirement_info';

    OPEN c_ret ;
    LOOP
        l_index := l_index + 1 ;
        FETCH c_ret INTO  P_Retire_Info ;
        EXIT WHEN c_ret%NOTFOUND ;
    END LOOP ;
    CLOSE c_ret ;

    IF ( l_index ) <= 0 THEN
       RAISE NO_DATA_FOUND ;
    END IF;
    RETURN TRUE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END ;



 Function Get_Units_Info_for_Gain_Loss (P_asset_id  IN NUMBER ,
                                                         P_Book_type_code  IN VARCHAR2 ,
                                                         P_Retirement_Id   IN NUMBER ,
-- ssmales                                                         P_Calling_txn     IN NUMBER ,
                                                         P_Calling_txn     IN VARCHAR2,
                                                         P_Units_Before   OUT NOCOPY NUMBER ,
                                                         P_Units_After    OUT NOCOPY NUMBER
                                                         )
RETURN BOOLEAN AS
       l_Retire_Info    fa_retirements%ROWTYPE ;
       l_txn_id_before NUMBER ;
       l_path_name VARCHAR2(150);
BEGIN
       l_path_name := g_path||'get_units_info_for_gain_loss';
    IF ( NOT ( Get_Retirement_Info ( P_Retirement_Id  ,
                                     l_Retire_Info
                                     ) )) THEN
        RETURN FALSE ;
    END IF;

    IF( P_Calling_txn  = 'RETIREMENT' ) THEN
        l_txn_id_before := l_retire_info.transaction_header_id_in ;
    ELSE
        l_txn_id_before := l_retire_info.transaction_header_id_out ;
    END IF;

    SELECT h.units
    INTO   p_units_before
    FROM   fa_asset_history h
    WHERE  h.asset_id = P_asset_id
    AND    h.transaction_header_id_out =  l_txn_id_before ;

    SELECT h.units
    INTO   p_units_after
    FROM   fa_asset_history h
    WHERE  h.asset_id = P_asset_id
    AND    h.transaction_header_id_in =  l_txn_id_before ;

    RETURN TRUE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END ;





 Function  Get_Cost_Retirement_Factor ( P_Book_Type_code  IN VARCHAR2 ,
                                        P_Asset_id IN NUMBER ,
                                        P_Retirement_Id IN NUMBER ,
                                        P_Factor OUT NOCOPY NUMBER
                                        )
RETURN BOOLEAN AS
    l_cost_retired   NUMBER ;
    l_cost           NUMBER ;
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'get_cost_retirement_factor';

    SELECT b.cost, r.cost_retired
    INTO   l_cost, l_cost_retired
    FROM   fa_books b,  fa_retirements r
    WHERE  b.book_type_code            = P_book_type_Code
    AND    b.asset_id                  = P_asset_id
    AND    r.retirement_id             = P_retirement_id
    AND    r.retirement_id             = b.retirement_id ;

    P_Factor := l_cost_retired / l_cost ;

    RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;


-- ssmales  Function Is_Part_Ret_Unit_or_Cost( P_book_type_Code IN VARCHAR2 ,
 Function Get_Retirement_Type     ( P_book_type_Code IN VARCHAR2 ,
                                                     P_Asset_id       IN NUMBER ,
-- ssmales                                                     P_Transaction_header_id IN NUMBER ,
                                                     P_Retirement_Id IN NUMBER ,
                                                     P_Type   OUT NOCOPY VARCHAR2
                                                     )
RETURN BOOLEAN AS
    l_units  NUMBER;
    l_transaction_type fa_transaction_headers.transaction_type_code%TYPE ;
    l_path_name VARCHAR2(150);
BEGIN
    l_units  := 0 ;
    l_path_name := g_path||'get_retirement_type';

    SELECT  t.transaction_type_code
    INTO    l_transaction_type
    FROM    fa_transaction_headers t, fa_retirements r
    WHERE   t.transaction_header_id = r.transaction_header_id_in
    AND     r.retirement_id  = P_retirement_id ;

    SELECT  r.units
    INTO    l_units
    FROM    fa_retirements r
--ssmales    WHERE   r.transaction_header_id_in = P_transaction_header_id
    WHERE   r.retirement_id = P_retirement_id
    AND     r.book_type_code = P_book_type_code
    AND     r.asset_id       = P_asset_id ;

    IF l_transaction_type = 'FULL RETIREMENT' THEN
        P_Type := 'FULL' ;

    ELSIF ( nvl(l_units,0) > 0 ) THEN
        P_Type := 'UNIT';
    ELSE
        P_Type := 'COST';
    END IF;
    RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;



Function Prorate_Amt_to_Active_Dists( P_book_type_Code IN VARCHAR2 ,
                                                     P_Asset_id       IN NUMBER ,
                                                     P_Amount         IN NUMBER ,
                                                     P_out_tab       OUT NOCOPY igi_iac_types.dist_amt_tab
                                                     )
RETURN BOOLEAN AS
    l_tot_units          NUMBER;
    l_dist_amount        NUMBER;
    l_remain_amount      NUMBER;
    l_units_processed    NUMBER;
    l_factor             NUMBER;
    l_index                NUMBER ;
    l_path_name VARCHAR2(150);

    CURSOR c_active_dists IS
         SELECT *
         FROM   fa_distribution_history
         WHERE  asset_id  = P_Asset_Id
         AND    book_type_code = P_book_type_code
    	 AND    date_ineffective IS NULL ;
BEGIN
    l_tot_units := 0 ;
    l_dist_amount := 0 ;
    l_remain_amount := p_amount ;
    l_units_processed := 0 ;
    l_factor := 1 ;
    l_path_name := g_path||'prorate_amt_to_active_dists';

    SELECT h.units
    INTO   l_tot_units
    FROM   fa_asset_history h
    WHERE  asset_id  = P_asset_id
    AND    date_ineffective IS NULL ;

    l_remain_amount := P_amount ;
    l_index := 0 ;

    FOR distrec IN c_active_dists LOOP
       l_index := l_index + 1 ;
       l_units_processed := l_units_processed + distrec.units_assigned ;
       IF (l_units_processed <> l_tot_units ) THEN
           l_factor := distrec.units_assigned / l_tot_units ;
           l_dist_amount   := P_Amount * l_factor ;
           do_round(l_dist_amount,P_book_type_Code);
           l_remain_amount := l_remain_amount - l_dist_amount ;
       ELSE
           l_factor := distrec.units_assigned / l_tot_units;
           l_dist_amount := l_remain_amount ;
       END IF;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'P_amount: ' || P_amount);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'l_factor: ' || l_factor);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'l_dist_amount: ' || l_dist_amount);
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'l_remain_amount: ' || l_remain_amount);
       P_out_tab(l_index).distribution_id := distrec.distribution_id ;
       P_out_tab(l_index).amount          := l_dist_amount ;
       P_out_tab(l_index).units		  := distrec.units_assigned;
       P_out_tab(l_index).prorate_factor := l_factor;
    END LOOP ;

    RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;



 Function Get_Active_Distributions ( P_book_type_Code IN VARCHAR2 ,
                                                      P_Asset_id       IN NUMBER ,
                                                      P_dh_tab        OUT NOCOPY igi_iac_types.dh_tab
                                                      )
RETURN BOOLEAN AS

    l_index    NUMBER;
    l_path_name VARCHAR2(150);

    CURSOR c_dh IS
        SELECT dh.*
        FROM   fa_distribution_history dh
        WHERE  dh.asset_id = P_Asset_Id
        AND    dh.book_type_code = P_book_type_Code
        AND    dh.date_ineffective IS NULL ;

BEGIN
    l_index    := 0 ;
    l_path_name := g_path||'get_active_distributions';

    OPEN c_dh ;
    LOOP
        l_index := l_index + 1 ;
        FETCH c_dh INTO  P_dh_tab(l_index);
        EXIT WHEN c_dh%NOTFOUND ;
    END LOOP ;
    CLOSE c_dh ;

    IF ( P_dh_tab.count ) <= 0 THEN
       RAISE NO_DATA_FOUND ;
    END IF;

    RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END ;





 Function Get_CY_PY_Factors( P_book_type_Code IN VARCHAR2 ,
                                              P_Asset_id       IN NUMBER ,
                                              P_Period_Name    IN VARCHAR2 ,
                                              P_PY_Ratio      OUT NOCOPY NUMBER ,
                                              P_CY_Ratio      OUT NOCOPY  NUMBER
                                              )
RETURN BOOLEAN AS
       l_curr_prd_tab       igi_iac_types.prd_rec ;
       l_dpis_prd_tab       igi_iac_types.prd_rec ;
       l_dpis               DATE ;
       l_path_name VARCHAR2(150);
BEGIN
       l_path_name := g_path||'get_cy_py_factors';

    SELECT b.date_placed_in_service
    INTO   l_dpis
    FROM   fa_books b
    WHERE  b.book_type_code = P_book_type_code
    AND    b.asset_id       = P_Asset_Id
    AND    b.date_ineffective IS NULL ;


    IF ( NOT ( Get_Period_Info_for_Date( P_book_type_Code ,
                                         l_dpis ,
                                         l_dpis_prd_tab
                                          ))) THEN
        RETURN FALSE ;
    END IF;

    IF ( NOT ( Get_Period_Info_for_Name( P_book_type_Code ,
                                         P_Period_Name ,
                                         l_curr_prd_tab
                                          ))) THEN
        RETURN FALSE ;
    END IF;

    P_CY_Ratio := (l_curr_prd_tab.Period_Num)/
                                (l_curr_prd_tab.period_counter-l_dpis_prd_tab.period_counter) ;
    P_PY_Ratio := 1 - P_CY_Ratio ;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'P_CY_Ratio: ' || P_CY_Ratio);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path_name,'P_PY_Ratio: ' || P_PY_Ratio);

    RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END ;




Function Is_Asset_Rvl_in_curr_Period( P_book_type_Code IN VARCHAR2 ,
                                                        P_Asset_id       IN NUMBER
                                                        )
RETURN BOOLEAN AS
    l_curr_prd_Counter  NUMBER ;
    l_prev_prd_Counter  NUMBER ;
    l_tot_records       NUMBER ;
    l_path_name VARCHAR2(150) ;
BEGIN
    l_path_name := g_path||'is_asset_rvl_in_curr_period';
    SELECT dp.period_counter
    INTO   l_curr_prd_Counter
    FROM   fa_deprn_periods dp
    WHERE  dp.book_type_Code   = P_book_type_code
    AND    dp.period_close_date IS NULL;

    l_prev_prd_counter :=  l_curr_prd_Counter - 1;

    SELECT count(*)
    INTO   l_tot_records
    FROM   igi_iac_transaction_headers it
    WHERE  it.book_type_Code        = P_book_type_code
    AND    it.asset_id              = P_asset_id
    AND    it.transaction_type_Code = 'REVALUATION'
    AND    it.period_counter        = l_prev_prd_counter
    AND    it.adjustment_status     = 'R' ;

    IF l_tot_records > 0 THEN
        RETURN TRUE ;
    END IF;

    RETURN FALSE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END ;



Function Any_Txns_In_Open_Period( P_book_type_Code IN VARCHAR2 ,
                                                    P_Asset_id       IN NUMBER
                                                    )
RETURN BOOLEAN AS
    l_tot_records  NUMBER;
    l_path_name VARCHAR2(150);
BEGIN
    l_tot_records  := 0 ;
    l_path_name := g_path||'any_txns_in_open_period';

    SELECT count(*)
    INTO   l_tot_records
    FROM   fa_transaction_headers ft ,
           fa_deprn_periods dp
    WHERE  ft.book_type_Code        = P_book_type_code
    AND    ft.asset_id              = P_asset_id
    AND    dp.book_type_Code        = P_book_type_code
    AND    dp.period_close_Date     IS NULL
    AND    ft.date_effective        >= dp.period_open_date ;


    IF l_tot_records > 0 THEN
        RETURN TRUE ;
    END IF;

    RETURN FALSE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;





Function Any_Adj_In_Book( P_book_type_Code IN VARCHAR2 ,
                                            P_Asset_id       IN NUMBER
                                            )
RETURN BOOLEAN AS
    l_tot_records  NUMBER;
    l_path_name VARCHAR2(150);
BEGIN
    l_tot_records  := 0 ;
    l_path_name  := g_path||'any_adj_in_book';

    SELECT count(*)
    INTO   l_tot_records
    FROM   fa_transaction_headers ft
    WHERE  ft.book_type_Code        = P_book_type_code
    AND    ft.asset_id              = P_asset_id
    AND    ft.transaction_type_Code = 'ADJUSTMENT';


    IF l_tot_records > 0 THEN
        RETURN TRUE ;
    END IF;

    RETURN FALSE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;




Function Any_Reval_in_Corp_Book( P_book_type_Code IN VARCHAR2 ,
                                                   P_Asset_id       IN NUMBER
                                                   )
RETURN BOOLEAN AS
    l_tot_records  NUMBER;
    l_path_name VARCHAR2(150);
BEGIN
    l_tot_records  := 0 ;
    l_path_name := g_path||'any_reval_in_corp_book';

    SELECT count(*)
    INTO   l_tot_records
    FROM   fa_transaction_headers ft
    WHERE  ft.book_type_Code        = P_book_type_code
    AND    ft.asset_id              = P_asset_id
    AND    ft.transaction_type_Code = 'REVALUATION';


    IF l_tot_records > 0 THEN
        RETURN TRUE ;
    END IF;

    RETURN FALSE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;





Function Any_Ret_In_Curr_Yr    ( P_book_type_Code IN  VARCHAR2 ,
                                                   P_Asset_id       IN  NUMBER ,
                                                   P_retirements    OUT NOCOPY VARCHAR2
                                                   )
RETURN BOOLEAN AS
       l_prd_tab          igi_iac_types.prd_rec ;
       l_calendar         VARCHAR2(30);
       l_fiscal_year_name VARCHAR2(30);
       l_fy_start_date    DATE ;
       l_tot_retirements  NUMBER ;
       l_path_name VARCHAR2(150);
BEGIN
       l_path_name := g_path||'any_ret_in_curr_yr';

    IF ( NOT ( Get_Open_Period_Info ( P_book_type_Code ,
                                      l_prd_tab
                                      ))) THEN
         RETURN FALSE ;
    END IF;

    SELECT ct.calendar_type , ct.fiscal_year_name
    INTO   l_calendar , l_fiscal_year_name
    FROM   fa_Calendar_types ct , fa_book_controls bc
    WHERE  ct.calendar_type  = bc.deprn_calendar
    AND    bc.book_type_Code = P_book_type_Code ;

    SELECT fy.start_Date
    INTO   l_fy_start_date
    FROM   fa_fiscal_year fy
    WHERE  fy.fiscal_year_name = l_fiscal_year_name
    AND    fy.fiscal_year      = l_prd_tab.fiscal_year ;

    -- bug 2452521, start (1)

/*    SELECT count(*)
    INTO   l_tot_retirements
    FROM   fa_retirements r
    WHERE  r.book_type_code    = P_book_type_Code
    AND    r.asset_id          = P_asset_id
    AND    r.status           IN ('PROCESSED' , 'PENDING', 'PARTIAL' , 'REINSTATE' )
    AND    r.date_retired     >= l_fy_start_date ;
*/

    SELECT count(*)
    INTO   l_tot_retirements
    FROM   fa_retirements r
    WHERE  r.book_type_code    = P_book_type_Code
    AND    r.transaction_header_id_out IS NULL
    AND    r.asset_id          = P_asset_id
    AND    r.status           IN ('PROCESSED' , 'PENDING', 'PARTIAL' , 'REINSTATE' )
    AND    r.date_retired     >= l_fy_start_date
    AND    EXISTS ( SELECT  'x'
                    FROM    fa_transaction_headers t
                    WHERE   t.transaction_header_id = r.transaction_header_id_in
                    AND     t.transaction_type_code = 'FULL RETIREMENT' );

    -- bug 2452521, end (1)

    IF ( l_tot_Retirements > 0 ) THEN
         P_retirements    := 'Y' ;
    ELSE
         P_retirements    := 'N' ;
    END IF;


    RETURN TRUE ;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE;
END;

-- DMahajan End


-- Niyer Start

FUNCTION Is_Asset_Proc (
        X_book_type_code   IN  VARCHAR2,
        X_asset_id         IN  VARCHAR2 )    RETURN BOOLEAN IS

      Cursor C1 is select asset_id
      	from igi_iac_asset_balances
      	where asset_id = X_asset_id
      	and book_type_code = X_book_type_code
      	and  rownum = 1 ;

     l_dummy   NUMBER;
     l_path_name VARCHAR2(150);

BEGIN
     l_path_name := g_path||'is_asset_proc';

   OPEN C1;
   FETCH C1 INTO l_dummy;
   IF C1%FOUND THEN
	CLOSE C1;
	RETURN TRUE;
   ELSE
	CLOSE C1;
	RETURN  FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE ;
END;

FUNCTION Get_Dpis_Period_Counter (
        X_book_type_code IN Varchar2,
        X_asset_id       IN Varchar2,
        X_Period_Counter OUT NOCOPY Varchar2 )    RETURN BOOLEAN IS

        Cursor C1 is select date_placed_in_service
        from fa_books fb ,
             igi_iac_book_controls ibc
        Where fb.book_type_code = ibc.book_type_code
        AND   fb.book_type_code = X_book_type_code
        AND   fb.asset_id = X_asset_id
        AND   fb.date_ineffective is null;

 l_prd_rec igi_iac_types.prd_rec;
 l_dpis   DATE;
 l_path_name VARCHAR2(150);

Begin
    l_path_name := g_path||'get_dpis_period_counter';

   OPEN C1;
   FETCH C1 INTO l_dpis;
   IF C1%FOUND THEN
      Begin
        SELECT  dp.period_num, dp.period_name, dp.calendar_period_open_date ,
                dp.calendar_period_close_date , dp.period_counter, dp.fiscal_year
        INTO    l_prd_rec.period_num, l_prd_rec.period_name, l_prd_rec.period_start_date,
                l_prd_rec.period_end_date, l_prd_rec.period_counter , l_prd_rec.fiscal_year
        FROM    fa_deprn_periods dp
        WHERE   dp.book_type_code = X_book_type_code
        AND     l_dpis between dp.calendar_period_open_Date and dp.calendar_period_close_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT  cp.period_num, cp.period_name, cp.start_date ,
                    cp.end_Date  ,
                    ((fy.fiscal_year*ct.number_per_fiscal_year)+cp.period_num) p_period_counter,
                    fy.fiscal_year
            INTO    l_prd_rec.period_num, l_prd_rec.period_name, l_prd_rec.period_start_date,
                    l_prd_rec.period_end_date, l_prd_rec.period_counter , l_prd_rec.fiscal_year
	    FROM   fa_fiscal_year fy ,
		   fa_calendar_types ct ,
		   fa_calendar_periods cp ,
		   fa_book_controls    bc
	    WHERE  ct.fiscal_year_name = fy.fiscal_year_name
	    AND    bc.book_type_code = X_book_type_code
	    AND    ct.calendar_type = bc.deprn_Calendar
	    AND    l_dpis between cp.start_date and cp.end_Date
	    AND    l_dpis between fy.start_date and fy.end_Date
	    AND    cp.calendar_type = ct.calendar_type
	    AND    cp.start_Date >= fy.start_date
	    AND    cp.end_Date <= fy.end_Date;
     END;
     X_Period_Counter := l_prd_rec.period_counter;
	CLOSE C1;

	RETURN TRUE;
   ELSE
	CLOSE C1;
	RETURN  FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE ;
END;



FUNCTION Get_Price_Index (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN Varchar2,
        X_Price_Index_Id OUT NOCOPY NUMBER,
        X_Price_Index_Name OUT NOCOPY VARCHAR2 )      RETURN BOOLEAN IS

        Cursor cat is
        select asset_category_id
        from fa_additions
        where asset_id = X_asset_id;

        Cursor prc_idx(p_cat number) is
        select price_index_id
        from igi_iac_category_books
        where book_type_code = X_book_type_code
        and   category_id = p_cat;

        Cursor idx_nam(p_prc_idx number) is
        select price_index_name , price_index_id
        from igi_iac_price_indexes
        where price_index_id = p_prc_idx;

        l_path_name VARCHAR2(150);

   Begin
        l_path_name := g_path||'get_price_index';

     for l_cat in cat LOOP
         for l_prc_idx in prc_idx(l_cat.asset_category_id) LOOP
             for l_idx_nam in idx_nam(l_prc_idx.price_index_id) LOOP
                 X_Price_Index_Name := l_idx_nam.price_index_name;
                 X_Price_Index_Id := l_idx_nam.price_index_id;
             end loop;
         end loop;
      end loop;

      RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE ;

End;



   FUNCTION Get_Price_Index_Value (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN Varchar2,
        X_Period_Name	IN VARCHAR2,
        X_Price_Index_Value OUT NOCOPY NUMBER )      RETURN BOOLEAN IS

        Cursor cat is
        select asset_category_id
        from fa_additions
        where asset_id = X_asset_id;

        Cursor cal_price_idx_id(p_cat number ) is
        select cal_price_index_link_id
        from igi_iac_category_books
        where category_id = p_cat
        and   book_type_code = X_book_type_code;

        p_dep_cal varchar2(15);
        p_cal_prc_idx_id number;
        p_start_date date;
        p_end_date   date;
        p_cur_prc_idx_val number;
        l_path_name VARCHAR2(150) ;

        Cursor dep_cal is
        select deprn_calendar
        from fa_book_controls
        where book_type_code = X_book_type_code;

        Cursor start_end_dat(cp_dep_cal varchar2)  is
        select start_date , end_date
        from fa_calendar_periods
        where period_name = X_Period_Name
        and   calendar_type = cp_dep_cal;

        Cursor c_price_index_value(cp_cal_prc_idx_id number,cp_start_date date,cp_end_date date) IS
           select current_price_index_value
           from igi_iac_cal_idx_values
           where cal_price_index_link_id = cp_cal_prc_idx_id
           and	 date_from = cp_start_date
           and   date_to   = cp_end_date;


        Begin
        l_path_name := g_path||'get_price_index_value';
             Begin

              open dep_cal;
                    fetch dep_cal into p_dep_cal;
                    IF dep_cal%FOUND THEN

                       close dep_cal;
                    else
                       close dep_cal;
                    End If;
                 Exception
                    WHEN OTHERS THEN
  		       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
                       Raise_application_Error (-20000, SQLERRM);
               End;

          for l_cat in cat LOOP
             for l_cal_prc_idx_id in cal_price_idx_id(l_cat.asset_category_id) LOOP
                 p_cal_prc_idx_id := l_cal_prc_idx_id.cal_price_index_link_id;
             End Loop;
           End Loop;

           for l_start_end_dat in start_end_dat(p_dep_cal) LOOP
               p_start_date := l_start_end_dat.start_date;
               p_end_date   := l_start_end_dat.end_date;
           End Loop;

           open c_price_index_value(p_cal_prc_idx_id,p_start_date,p_end_date);
           fetch c_price_index_value into p_cur_prc_idx_val;
           close c_price_index_value;


       X_Price_Index_Value := p_cur_prc_idx_val;
     RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       RETURN FALSE ;

End;

-- Niyer End


-- Shekar Start

FUNCTION Is_IAC_Book ( X_book_type_code   IN  VARCHAR2 )
    RETURN BOOLEAN IS
    CURSOR IAC_book IS
    SELECT 'X'
    FROM   igi_iac_book_Controls ibc ,
           fa_book_controls bc
    WHERE  bc.book_type_code = ibc.book_type_code
    AND    bc.date_ineffective IS NULL
    AND    bc.book_type_code = X_book_type_code;

    l_found   BOOLEAN;
    l_dummy   VARCHAR2(1);
    l_path_name VARCHAR2(150);
BEGIN
    l_found   :=  FALSE ;
    l_path_name := g_path||'is_iac_book';
   OPEN iac_book;
   FETCH iac_book INTO l_dummy;
   IF iac_book%FOUND THEN
	CLOSE iac_book;
	RETURN TRUE;
   ELSE
	CLOSE iac_book;
	RETURN  FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     RETURN FALSE ;
END; -- is_iac_book


/*
The Get_lastest transaction function retrives the latest non-preview transaction
x_adjustment_id returns latest transaction id
	(This transaction should be closed by new transaction)
x_prev_adjustment_id returns latest non preview transaction
	(This det_balances for this transaction should be considered for calculations).
*/

FUNCTION Get_Latest_Transaction (
		X_book_type_code IN Varchar2
		 , X_asset_id		IN	Number
		 , X_Transaction_Type_Code	IN OUT NOCOPY	Varchar2
		, X_Transaction_Id		IN OUT NOCOPY	Number
		 , X_Mass_Reference_ID	IN OUT NOCOPY	Number
		 , X_Adjustment_Id		OUT NOCOPY	Number
		 , X_Prev_Adjustment_Id	OUT NOCOPY	Number
		 , X_Adjustment_Status	OUT NOCOPY	Varchar2
                               )
RETURN BOOLEAN IS
	CURSOR get_adj IS
	SELECT adjustment_id,
		transaction_type_code,
		transaction_header_id,
		nvl(mass_reference_id,0),
		adjustment_status
	FROM igi_iac_transaction_headers
	WHERE asset_id = x_asset_id
	AND book_type_code = x_book_type_code
	AND adjustment_id_out is null;

	CURSOR get_prev_adj(c_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE) IS
	SELECT adjustment_id,
		transaction_type_code,
		transaction_header_id,
		nvl(mass_reference_id,0),
		adjustment_status
	FROM igi_iac_transaction_headers
	WHERE asset_id = x_asset_id
	AND book_type_code = x_book_type_code
	AND adjustment_id_out = c_adjustment_id;

	CURSOR get_adj_Trans_Type IS
	SELECT max(adjustment_id)
	FROM igi_iac_transaction_headers
	WHERE asset_id = x_asset_id
	AND book_type_code = x_book_type_code
	AND transaction_type_code = X_TRANSACTION_TYPE_CODE;

	CURSOR get_trans (p_adjustment_id Number) IS
	SELECT transaction_header_id, nvl(mass_reference_id,0), adjustment_status
	FROM igi_iac_transaction_headers
	WHERE asset_id = x_asset_id
	AND book_type_code = x_book_type_code
	AND adjustment_id = p_adjustment_id;

	l_non_preview_trans BOOLEAN;
	l_adjustment_id     igi_iac_transaction_headers.adjustment_id%TYPE;
	l_path_name VARCHAR2(150);
BEGIN
	l_non_preview_trans := FALSE;
	l_path_name := g_path||'get_latest_transaction';

	IF X_transaction_type_code IS NULL THEN
		OPEN get_adj;
		FETCH get_adj Into x_adjustment_id,
			x_transaction_type_code,
			x_transaction_id,
			x_mass_reference_id,
			x_adjustment_status;
		IF get_adj%FOUND THEN
			CLOSE  get_adj;
			IF NOT(x_transaction_type_code = 'REVALUATION' AND x_adjustment_status IN ('PREVIEW','OBSOLETE')) THEN
				l_non_preview_trans := TRUE;
				x_prev_adjustment_id := x_adjustment_id;
				return TRUE;
			ELSE
				l_adjustment_id := x_adjustment_id;

				WHILE NOT l_non_preview_trans LOOP
					OPEN get_prev_adj(l_adjustment_id);
					FETCH get_prev_adj INTO x_prev_adjustment_id,
							x_transaction_type_code,
							x_transaction_id,
							x_mass_reference_id,
							x_adjustment_status;
					IF get_prev_adj%NOTFOUND THEN
						CLOSE get_prev_adj;
						return FALSE;
					ELSE
						CLOSE get_prev_adj;
					END IF;

					IF NOT(x_transaction_type_code = 'REVALUATION' AND x_adjustment_status IN ('PREVIEW','OBSOLETE')) THEN
						l_non_preview_trans := TRUE;
					ELSE
						l_adjustment_id := x_prev_adjustment_id;
					END IF;
				END LOOP;
				return TRUE;
			END IF;
		ELSE
			CLOSE  get_adj;
			return FALSE;
		END IF;
	ELSE    -- X_transaction_type_code is not null
		OPEN get_adj_trans_type;
		FETCH get_adj_trans_type INTO x_adjustment_id;
		IF get_adj_trans_type%FOUND THEN
			OPEN get_trans(x_adjustment_id);
			FETCH get_trans into x_transaction_id,x_mass_reference_id, x_adjustment_status;
			IF get_trans%FOUND THEN
				x_prev_adjustment_id := x_adjustment_id;
				CLOSE get_trans;
				CLOSE  get_adj_trans_type;
				return TRUE;
			ELSE
				CLOSE get_trans;
				CLOSE  get_adj_trans_type;
				return FALSE;
			END IF;
		END IF;
	END IF;
   	return FALSE;
EXCEPTION
	WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
		return FALSE;
END Get_Latest_Transaction;


/*
Get_Book_GL_Info gets the general ledger info for the book type
*/

FUNCTION Get_Book_GL_Info ( X_book_type_code IN VARCHAR2
                               ,Set_Of_Books_Id IN OUT NOCOPY NUMBER
                               ,Chart_Of_Accounts_Id IN OUT NOCOPY NUMBER
                               ,Currency IN OUT NOCOPY VARCHAR2
                               ,Precision IN OUT NOCOPY NUMBER
                               )
RETURN BOOLEAN IS
	Cursor get_gl_info(p_book_type_code Varchar2) is
	SELECT  bc.accounting_flex_structure, bc.set_of_books_id
    FROM    fa_book_controls bc
	WHERE  bc.book_type_code = p_book_type_code
        	AND bc.date_ineffective IS NULL ;
    Cursor get_curr (p_set_of_books_id Number) is
	SELECT currency_code
	FROM   gl_sets_of_books
	WHERE set_of_books_id = p_set_of_books_id;
	Cursor get_precision ( p_currency_code varchar2) is
	SELECT Precision
	FROM fnd_currencies
	WHERE currency_code = p_currency_code;
	l_book_type_code varchar2(255);
	l_chart_of_accounts_id Number;
	l_set_of_books_id Number;
	l_currency_code VARCHAR2(10);
	l_precision Number;
        l_path_name VARCHAR2(150);
BEGIN
        l_path_name := g_path||'get_book_gl_info';
		Open get_gl_info (X_book_type_code);
		Fetch get_gl_info into l_chart_of_accounts_id,
							   l_set_of_books_id;
		IF get_gl_info%FOUND THEN
			 Chart_of_accounts_id := l_chart_of_accounts_id;
		     set_of_books_id := l_set_of_books_id;
		  	 Open get_curr(l_set_of_books_id);
			 Fetch get_curr into l_currency_code;
			 IF get_curr%FOUND THEN
			 	Currency := l_currency_code;
			 	open get_precision (l_currency_code);
				Fetch get_precision into l_precision;
				IF get_precision%FOUND THEN
					Precision := l_precision;
					Close get_precision;
					Close get_curr;
					Close get_gl_info;
					Return TRUE;
				ELSE
					Precision :=Null;
					Close get_precision;
					Close get_curr;
					Close get_gl_info;
					RETURN FALSE;
				END IF;
			ELSE
			 	Currency := Null;
				Close get_curr;
				Close get_gl_info;
				RETURN FALSE;
			END IF;
		ELSE
			 Chart_of_accounts_id := Null;
		     set_of_books_id := Null;
			 close get_gl_info;
			 RETURN FALSE;
		End if;
	EXCEPTION
		WHEN OTHERS THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
		RETURN FALSE;
END;-- Get_Book_GL_Info;

/*
This functions RETURNs the value contained in the GL_ACCOUNT segment of a code combination account
Parameters possible segment types are 'GL_ACCOUNT', 'GL_BALANCING', 'FA_COST_CTR'
*/

FUNCTION Get_Account_Segment_Value (
       X_sob_id                IN gl_sets_of_books.set_of_books_id%TYPE,
       X_code_combination_id   IN fa_distribution_history.code_combination_id%TYPE,
       X_segment_type          IN VARCHAR2 ,
       X_segment_value         IN OUT NOCOPY VARCHAR2 )
       RETURN BOOLEAN IS
   l_account_value 	VARCHAR2(30);
   l_segment       	VARCHAR2(30);
   l_cursor_hANDle   	NUMBER;
   l_sel_stmt           VARCHAR2(1024) ;
   l_sel_cursor       	NUMBER;
   l_sel_column		VARCHAR2(30);
   l_sel_rows		NUMBER;
   l_sel_execute	VARCHAR2(1024);
   l_path_name VARCHAR2(150);
BEGIN
   l_path_name := g_path||'get_account_segment_value';
    SELECT application_column_name
    INTO   l_segment
    FROM   fnd_segment_attribute_values ,
           gl_sets_of_books sob
    WHERE  id_flex_code                    = 'GL#'
    AND    attribute_value                 = 'Y'
    AND    segment_attribute_type          = X_segment_type
    AND    application_id                  = 101
    AND    sob.chart_of_accounts_id        = id_flex_num
    AND    sob.set_of_books_id             = X_sob_id;

    EXECUTE IMMEDIATE ' SELECT '||l_segment ||
                  ' FROM gl_code_combinations '||
                  ' WHERE code_combination_id = :X_ccid '
     INTO l_sel_column USING IN X_code_combination_id;

    X_segment_value := l_sel_column;
    RETURN TRUE ;
EXCEPTION
  WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       RETURN FALSE ;
END Get_Account_Segment_Value;

FUNCTION Get_Distribution_Ccid (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_Id IN NUMBER,
        Dist_CCID IN OUT NOCOPY NUMBER )
RETURN BOOLEAN IS
	Cursor get_dist_ccid (p_book_type_code Varchar2,
						  P_asset_id Number,
						  p_distribution_id Number) IS
	SELECT code_combination_id
	FROM fa_distribution_history
	WHERE Book_type_code = p_book_type_code
	AND	  asset_id = p_asset_id
	AND	  distribution_id = p_distribution_id;

        l_path_name VARCHAR2(150);
BEGIN
        l_path_name := g_path||'get_distribution_ccid';

	Open get_dist_ccid ( X_book_type_code,
						 X_asset_id,
						 X_distribution_id);
	Fetch get_dist_ccid into dist_CCID;
	IF get_dist_ccid%FOUND THEN
		Close get_dist_ccid;
		RETURN TRUE;
	END IF;
	IF get_dist_ccid%ISOPEN THEN
		Close get_dist_ccid;
	END IF;
	RETURN FALSE;
EXCEPTION
  WHEN OTHERS THEN
       igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
       RETURN FALSE ;
END;-- Get_Distribution_Ccid;

FUNCTION Get_Default_Account (
        X_book_type_code IN VARCHAR2,
        Default_Account IN OUT NOCOPY NUMBER )
RETURN BOOLEAN IS
	Cursor get_default (p_book_type_code Varchar2) IS
	SELECT flexbuilder_defaults_ccid
	FROM fa_book_controls
	WHERE book_type_code = p_book_type_code;
        l_path_name VARCHAR2(150);
BEGIN
        l_path_name := g_path||'get_default_account';
	open get_default ( x_book_type_code);
	Fetch get_default into default_account;
	IF  get_default%FOUND THEN
		close get_default;
		RETURN TRUE;
	END IF;
	IF get_default%ISOPEN THEN
		close get_default;
	END IF;
	RETURN FALSE;
EXCEPTION
	WHEN OTHERS THEN
  	   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
           RETURN FALSE ;
END;-- Get_Default_Account;

-- For FND logging, this function is aliased as get_account_ccid1 since this is an overloaded
-- function
FUNCTION Get_Account_CCID (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_ID IN NUMBER,
        X_Account_Type    IN VARCHAR2,
        Account_CCID IN OUT NOCOPY NUMBER )
RETURN BOOLEAN IS
      CURSOR get_accounts IS
       SELECT  nvl(ASSET_COST_ACCOUNT_CCID, -1),
               nvl(ASSET_CLEARING_ACCOUNT_CCID, -1),
               nvl(DEPRN_EXPENSE_ACCOUNT_CCID, -1),
               nvl(DEPRN_RESERVE_ACCOUNT_CCID, -1),
               nvl(CIP_COST_ACCOUNT_CCID, -1),
               nvl(CIP_CLEARING_ACCOUNT_CCID, -1),
               nvl(NBV_RETIRED_GAIN_CCID,-1),
               nvl(NBV_RETIRED_LOSS_CCID,-1),
               nvl(PROCEEDS_SALE_GAIN_CCID,-1),
               nvl(PROCEEDS_SALE_LOSS_CCID,-1),
               nvl(COST_REMOVAL_GAIN_CCID,-1),
               nvl(COST_REMOVAL_LOSS_CCID,-1),
               nvl(COST_REMOVAL_CLEARING_CCID,-1),
               nvl(PROCEEDS_SALE_CLEARING_CCID,-1),
               --nvl(REVAL_RSV_ACCOUNT_CCID,-1),
               --nvl(REVAL_RSV_GAIN_ACCOUNT_CCID,-1),
              -- nvl(REVAL_RSV_LOSS_ACCOUNT_CCID,-1),
               bc.accounting_flex_structure
       FROM    FA_DISTRIBUTION_ACCOUNTS da,
                    FA_BOOK_CONTROLS bc
       WHERE   bc.book_type_code = X_book_type_code
       AND     da.book_type_code = bc.book_type_code
       AND     da.distribution_id = X_distribution_id;

       CURSOR validate_ccid IS
        SELECT  'VALID'
        FROM    gl_code_combinations glcc
        WHERE   glcc.code_combination_id = Account_ccid
        AND     glcc.enabled_flag = 'Y'
        AND     nvl(glcc.end_date_active, sysdate) >= sysdate;

 	CURSOR get_category_id IS
	SELECT asset_category_id
	FROM fa_additions
	WHERE asset_id = X_asset_id;

    Cursor get_iac_category_id is
    SELECT category_id
    FROM igi_iac_transaction_headers
    Where asset_id = X_asset_id
    and book_type_code = X_book_type_code
    and adjustment_id_out is null;


	CURSOR get_category_accounts (p_asset_category_Id Number) IS
	SELECT  nvl(BACKLOG_DEPRN_RSV_CCID,-1),
		nvl(GENERAL_FUND_CCID,-1),
		nvl(OPERATING_EXPENSE_CCID,-1),
        nvl(REVAL_RSV_CCID,-1),
        nvl(REVAL_RSV_RET_CCID,-1)
	FROM igi_iac_category_books
	WHERE book_type_code = X_book_type_code
	AND	  category_id = p_asset_category_id;

	CURSOR get_reval_rsv_ccid (p_asset_category_id number) is
        SELECT nvl(REVAL_RESERVE_ACCOUNT_CCID,-1)
        FROM fa_category_books
        WHERE book_type_Code = X_book_type_code
        AND category_id = p_asset_category_id;

     CURSOR c_get_intercompany is
        SELECT AP_INTERCOMPANY_ACCT,AR_INTERCOMPANY_ACCT
        FROM FA_BOOK_CONTROLS
        WHERE book_type_code = X_book_TYPE_Code;

     CURSOR get_accounts_from_FA is
          SELECT deprn_reserve_acct, asset_cost_acct
          FROM FA_CATEGORY_BOOKS
          WHERE book_type_code = X_book_type_code
          AND category_id IN
                 (SELECT asset_category_id
                  FROM fa_additions
                  WHERE asset_id = X_asset_id);

     CURSOR c_get_nbv_accounts is
        SELECT nbv_retired_gain_acct,nbv_retired_loss_acct
        FROM FA_BOOK_CONTROLS
        WHERE book_type_code = X_book_type_code;

l_cost_ccid             number ;
l_clearing_ccid         number ;
l_expense_ccid          number ;
l_reserve_ccid          number ;
l_cip_cost_ccid         number ;
l_cip_clearing_ccid     number ;
l_nbv_retired_gain_ccid number ;
l_nbv_retired_loss_ccid number ;
l_pos_gain_ccid         number ;
l_pos_loss_ccid         number ;
l_cost_removal_gain_ccid number ;
l_cost_removal_loss_ccid number ;
l_cor_clearing_ccid      number ;
l_pos_clearing_ccid      number ;
l_reval_reserve_ccid	 number ;
l_reval_rsv_retired_gain_ccid number ;
l_reval_rsv_retired_loss_ccid number ;
l_reval_reserve_retired_ccid number ;
l_flex_num               number ;
l_ccid_valid             varchar2(10) ;
n_segs                   number;
all_segments             fnd_flex_ext.SegmentArray;
delim                    varchar2(1);
get_segs_success         boolean;
l_ret_value              boolean ;
l_distribution_ccid 			Number ;
l_default_ccid 			Number ;
l_set_of_books_id		Number ;
l_chart_of_accounts_id  Number ;
l_currency				Varchar2(5);
l_precision 			Number;
l_back_deprn_rsv_ccid   Number ;
l_general_fund_ccid     Number ;
l_operation_expense_ccid Number ;
l_account_value         Varchar2(250);
l_deprn_reserve_acct    Varchar2(250);
l_asset_cost_acct       Varchar2(250);
l_nbv_retired_gain_acct Varchar2(250);
l_nbv_retired_loss_acct Varchar2(250);
l_asset_category_id Number;
l_account_ccid Number ;
l_path_name VARCHAR2(150) ;
l_interco_ap_acct number ;
l_interco_ar_acct number ;
x_concat_segs                VARCHAR2(780);
x_return_value               NUMBER;

BEGIN
    l_cost_ccid              :=0;
    l_clearing_ccid          :=0;
    l_expense_ccid           :=0;
    l_reserve_ccid           :=0;
    l_cip_cost_ccid          :=0;
    l_cip_clearing_ccid      :=0;
    l_nbv_retired_gain_ccid  :=0;
    l_nbv_retired_loss_ccid  :=0;
    l_pos_gain_ccid          :=0;
    l_pos_loss_ccid          :=0;
    l_cost_removal_gain_ccid  :=0;
    l_cost_removal_loss_ccid  :=0;
    l_cor_clearing_ccid       :=0;
    l_pos_clearing_ccid       :=0;
    l_reval_reserve_ccid	  :=0;
    l_reval_rsv_retired_gain_ccid  :=0;
    l_reval_rsv_retired_loss_ccid  :=0;
    l_reval_reserve_retired_ccid  :=0;
    l_flex_num                := null;
    l_ccid_valid              := NULL;
    l_ret_value               := FALSE;
    l_distribution_ccid       := 0;
    l_default_ccid 			 :=0;
    l_set_of_books_id		 :=0;
    l_chart_of_accounts_id   :=0;
    l_precision 			:=0;
    l_back_deprn_rsv_ccid    := 0;
    l_general_fund_ccid      :=0;
    l_operation_expense_ccid  :=0;
    l_asset_category_id :=0;
    l_account_ccid  :=0;
    l_path_name  := g_path||'get_account_ccid1';
    l_interco_ap_acct  :=0;
    l_interco_ar_acct  :=0;

   	 /* IAC Category account then call IAC work flow to generate the work flow */
		/* get and set all parameters required for start proces of workflow */
    	/* get the distribution ccid */
        --log('+ get ccid call');

		IF get_distribution_ccid(X_book_type_code,
							 X_asset_id,
							 X_distribution_id,
							 l_distribution_ccid) THEN
			Null;
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get distribution sucessfull ..'|| l_distribution_ccid);
		ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get distribution failed ..'|| l_distribution_ccid);
            		Account_ccid := -1;
			RETURN FALSE;
		END IF;
        --log('+ get ccid call get_distribution_ccid'||to_char(l_distribution_ccid));
		/* get the deault ccid from fa book controls */
		IF get_default_account ( X_book_type_code,
								l_default_ccid)THEN

  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get default account sucessfull ..'|| l_default_ccid);
            		Null;
		ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get default account failed..'|| l_default_ccid);
			Account_ccid := -1;
			RETURN FALSE;
		END IF;
       -- log('+ get ccid call get_default_account'||to_char(l_default_ccid));
		/* get the chart of accounts id */
		IF get_book_gl_info (X_book_type_code,
						l_set_of_books_id,
						l_chart_of_accounts_id,
    					l_currency,
						l_precision ) THEN
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get gl info sucessfull ..'|| l_chart_of_accounts_id);
            Null;
		ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => 'get gl info failed ..'|| l_chart_of_accounts_id);
            		Account_ccid := -1;
			RETURN FALSE;
		END IF;
        --log('+ get ccid call get_gl_info'||to_char(l_chart_of_accounts_id));


       	 IF X_ACCOUNT_TYPE IN ('BACKLOG_DEPRN_RSV_ACCT',
                        	'OPERATING_EXPENSE_ACCT',
	                       	'GENERAL_FUND_ACCT',
        	                'REVAL_RESERVE_ACCT',
                            'REVAL_RESERVE_RETIRED_ACCT') THEN

         		/*get the account ccid 	and segment value */
                 OPEN get_iac_category_id;
                 FETCH get_iac_category_id into l_asset_category_id;
                IF NOT get_iac_category_id%FOUND THEN
                    		OPEN get_category_id;
            		FETCH get_category_id into l_asset_category_id;
    	    		IF NOT get_category_id%FOUND THEN
  			            	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			    p_full_path => l_path_name,
        		     			p_string => 'get asset id failed ..'||l_asset_category_id);
		            		Close get_category_id;
				            Account_ccid := -1;
        				RETURN FALSE;
	            	 END IF;
  			            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        		     		p_full_path => l_path_name,
		             		p_string => 'get asset id success..'||l_asset_category_id);
            			CLOSE get_category_id;
                  END IF;
                 Close get_iac_category_id;

                OPEN get_category_accounts(l_asset_category_id);
	      		FETCH get_category_accounts INTO l_back_deprn_rsv_ccid,
							 l_general_fund_ccid,
							 l_operation_expense_ccid,
                             l_reval_reserve_ccid,
                             l_reval_reserve_retired_ccid;
		        IF NOT get_category_accounts%FOUND THEN
              			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
		     		        p_string => 'get account ccid form iac books failed  ..'||l_account_ccid);
        	    		CLOSE get_category_accounts;
	            		Account_ccid := -1;
		    	        RETURN FALSE;
       	 		END IF;

          			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+ get ccid call account type'||x_account_type);

          			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		         		p_full_path => l_path_name,
		         		p_string => '+ get ccid call account type'||x_account_type);
              			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		         		p_full_path => l_path_name,
		     	    	p_string => '+ get ccid call get_category_accounts back log '||to_char(l_back_deprn_rsv_ccid));
              			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
    		     		p_string => '+get ccid call get_category_accounts general fund '||to_char(l_general_fund_ccid));
  	            		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	        	p_full_path => l_path_name,
        		     		p_string => '+ get ccid call get_category_accounts oper exp'||to_char(l_operation_expense_ccid));

    		    IF 	X_account_Type = 'BACKLOG_DEPRN_RSV_ACCT' THEN
        				l_account_ccid := l_back_deprn_rsv_ccid;
  		        ELSIF X_account_Type = 	'OPERATING_EXPENSE_ACCT' THEN
			        	l_account_ccid := l_operation_expense_ccid;
    	         ELSIF X_account_Type = 	'GENERAL_FUND_ACCT' THEN
	            	         l_account_ccid := l_general_fund_ccid;
                 ELSIF X_account_Type = 	'REVAL_RESERVE_ACCT' THEN
	           	         l_account_ccid := l_reval_reserve_ccid;
                 ELSIF X_account_Type = 	'REVAL_RESERVE_RETIRED_ACCT' THEN
	          	         l_account_ccid :=  l_reval_reserve_retired_ccid;
   		        END IF;

    	    	/* get the segment value for the account ccid */
	    	    IF NOT Get_account_segment_value (l_set_of_books_id,
				            					  l_account_ccid,
							            		  'GL_ACCOUNT',
            									  l_account_value) THEN
      			        	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		    	p_full_path => l_path_name,
		     			    p_string => '+ get gl-account failed '|| l_account_value);
	        		    	Account_ccid := -1;
			        	    RETURN FALSE;
        		END IF;
  		            igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        		     p_full_path => l_path_name,
		             p_string => '+ get gl-account success '|| l_account_value);

		 IF NOT IGI_IAC_WF_PKG.Start_process (
		                   X_flex_account_type     => X_account_type,
		                   X_book_type_code        => X_book_type_code,
		                   X_chart_of_accounts_id  => l_chart_of_accounts_id,
		                   X_dist_ccid             => l_distribution_ccid,
		                   X_acct_segval          => l_account_value,
		                   X_default_ccid          => l_default_ccid,
		                   X_account_ccid          => l_account_ccid,
		                   X_distribution_id       => X_distribution_id,
		                   X_workflowprocess      => 'IGIIACWF',
      			           X_RETURN_ccid           => account_ccid   ) THEN

  				igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     			p_full_path => l_path_name,
		     			p_string => '+ get ccid call wf failed '||to_char(account_ccid));

				Account_ccid := -1;
				RETURN FALSE;
		ELSE
  			igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     		p_full_path => l_path_name,
		     		p_string => '+ get ccid call wf sucess '||to_char(account_ccid));
			RETURN TRUE;
		END IF;
--        account_ccid := l_default_ccid;
      --  return true;
	ELSIF X_ACCOUNT_TYPE in ('INTERCO_AP_ACCT','INTERCO_AR_ACCT') THEN

            -- get the inter company account segements from  fa_book

             open c_get_intercompany;
             Fetch c_get_intercompany into l_interco_ap_acct,l_interco_ar_acct;
             If   c_get_intercompany%Notfound THEN
                   close c_get_intercompany;
    				Account_ccid := -1;
		    		RETURN FALSE;
             Else
                 If x_account_type = 'INTERCO_AP_ACCT' THEN
                    l_account_value := l_interco_ap_acct;
                 elsif x_account_type = 'INTERCO_AR_ACCT' THEN
                    l_account_value := l_interco_ar_acct;
                 end if  ;

                 IF NOT IGI_IAC_WF_PKG.Start_process (
		                   X_flex_account_type     => X_account_type,
		                   X_book_type_code        => X_book_type_code,
		                   X_chart_of_accounts_id  => l_chart_of_accounts_id,
		                   X_dist_ccid             => l_distribution_ccid,
		                   X_acct_segval          =>  l_account_value,
		                   X_default_ccid          => l_default_ccid,
		                   X_account_ccid          => l_default_ccid,
		                   X_distribution_id       => X_distribution_id,
		                   X_workflowprocess      => 'IGIIACWF',
      			           X_RETURN_ccid           => account_ccid   ) THEN

          				igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		         			p_full_path => l_path_name,
		         			p_string => '+ get ccid call wf failed '||to_char(account_ccid));

    				Account_ccid := -1;
	    			RETURN FALSE;
        		ELSE
  	    	        	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		             		p_full_path => l_path_name,
		     	    	p_string => '+ get ccid call wf sucess '||to_char(account_ccid));
        			RETURN TRUE;
		        END IF;
             END IF;
      ELSE    /* FA Account type get the ccid form the FA Distribution */
       OPEN get_accounts;
       FETCH get_accounts into
                l_cost_ccid,
                l_clearing_ccid,
                l_expense_ccid,
                l_reserve_ccid,
                l_cip_cost_ccid,
                l_cip_clearing_ccid,
                l_nbv_retired_gain_ccid,
                l_nbv_retired_loss_ccid,
                l_pos_gain_ccid,
                l_pos_loss_ccid,
                l_cost_removal_gain_ccid,
                l_cost_removal_loss_ccid,
                l_cor_clearing_ccid,
                l_pos_clearing_ccid,
		--l_reval_reserve_ccid,
		--l_reval_rsv_retired_gain_ccid,
		--l_reval_rsv_retired_loss_ccid,
                l_flex_num;

 	  if (get_accounts%FOUND) then
 	     if (X_account_type = 'ASSET_COST_ACCT') then
 	           account_ccid := l_cost_ccid;
 	     elsif (X_account_type = 'ASSET_CLEARING_ACCT') then
 	           account_ccid := l_clearing_ccid;
 	     elsif (X_account_type = 'DEPRN_RESERVE_ACCT') then
 	           account_ccid := l_reserve_ccid;
 	     elsif (X_account_type = 'DEPRN_EXPENSE_ACCT') then
 	           account_ccid := l_expense_ccid;
 	     elsif (X_account_type = 'CIP_COST_ACCT') then
 	           account_ccid := l_cip_cost_ccid;
 	     elsif (X_account_type = 'CIP_CLEARING_ACCT') then
 	           account_ccid := l_cip_clearing_ccid;
 	     elsif (X_account_type = 'NBV_RETIRED_GAIN_ACCT') then
 	           account_ccid := l_nbv_retired_gain_ccid;
 	     elsif (X_account_type = 'NBV_RETIRED_LOSS_ACCT') then
 	           account_ccid := l_nbv_retired_loss_ccid;
 	     elsif (X_account_type = 'PROCEEDS_OF_SALE_GAIN_ACCT') then
 	           account_ccid := l_pos_gain_ccid;
 	     elsif (X_account_type = 'PROCEEDS_OF_SALE_LOSS_ACCT') then
 	           account_ccid := l_pos_loss_ccid;
 	     elsif (X_account_type = 'COST_OF_REMOVAL_GAIN_ACCT') then
 	           account_ccid := l_cost_removal_gain_ccid;
 	     elsif (X_account_type = 'COST_OF_REMOVAL_LOSS_ACCT') then
 	           account_ccid := l_cost_removal_gain_ccid;
 	     elsif (X_account_type = 'COST_OF_REMOVAL_CLEARING_ACCT') then
 	           account_ccid := l_cor_clearing_ccid;
 	     elsif (X_account_type = 'PROCEEDS_OF_SALE_CLEARING_ACCT') then
 	           account_ccid := l_pos_clearing_ccid;
 	      --elsif (X_account_type = 'REVAL_RESERVE_ACCT') then
 	      ----   account_ccid := l_reval_reserve_ccid;
 	      --elsif (X_account_type = 'REVAL_RSV_RETIRED_GAIN_ACCT') then
 	       ---    account_ccid := l_reval_rsv_retired_gain_ccid;
 	     --- elsif (X_account_type = 'REVAL_RSV_RETIRED_LOSS_ACCT') then
 	       ---    account_ccid := l_reval_rsv_retired_loss_ccid;

 	   end if;
                if account_ccid > 0 then
                    l_ret_value := TRUE;
                end if;

 	else
         account_ccid := -1;
 	end if;

 	if(account_ccid = -1) then
   	-- Call FA package to get the Valid CCID.


   	   IF X_account_type in ('DEPRN_RESERVE_ACCT','ASSET_COST_ACCT') THEN
   	     OPEN get_accounts_from_FA;
   	     FETCH get_accounts_from_FA INTO
   	             l_deprn_reserve_acct,
   	             l_asset_cost_acct;

   	       IF (get_accounts_from_FA%FOUND) THEN
   	               IF (X_account_type = 'DEPRN_RESERVE_ACCT') THEN
   	                    l_account_value := l_deprn_reserve_acct;
   	               ELSIF (X_account_type = 'ASSET_COST_ACCT') THEN
   	                    l_account_value := l_asset_cost_acct;
   	               END IF;
   	       END IF;
   	     CLOSE get_accounts_from_FA;
   	   ELSIF X_account_type in ('NBV_RETIRED_GAIN_ACCT','NBV_RETIRED_LOSS_ACCT') THEN
   	     OPEN c_get_nbv_accounts;
   	     FETCH c_get_nbv_accounts INTO l_nbv_retired_gain_acct,l_nbv_retired_loss_acct;

   	       IF   c_get_nbv_accounts%FOUND THEN
   	               IF (X_account_type = 'NBV_RETIRED_GAIN_ACCT') THEN
   	                    l_account_value := l_nbv_retired_gain_acct;
   	               ELSIF (X_account_type = 'NBV_RETIRED_LOSS_ACCT') THEN
   	                    l_account_value := l_nbv_retired_loss_acct;
   	               END IF;
   	       END IF;
   	     CLOSE c_get_nbv_accounts;
   	   END IF;

   	   IF (X_account_type = 'DEPRN_EXPENSE_ACCT') THEN
   	      l_account_value := null;
   	      l_account_ccid  := l_distribution_ccid;
   	   ELSE
   	      l_account_ccid  := null;
   	   END IF;

   	   FA_GCCID_PKG.fafbgcc_proc
		      (X_book_type_code => X_book_type_code,
   	            X_fn_trx_code => X_account_type,
   	            X_dist_ccid => l_distribution_ccid,
   	            X_acct_segval => l_account_value,
   	            X_account_ccid => l_account_ccid,
   	            X_distribution_id => X_distribution_id,
   	            X_rtn_ccid => account_ccid,
		       X_concat_segs => x_concat_segs,
 		       X_return_value => x_return_value);

   	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			         			p_full_path => l_path_name,
			         			p_string => '+ get ccid call FA wf success = >'||to_char(account_ccid));
   	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
			         			p_full_path => l_path_name,
			         			p_string => '+ get ccid call FA wf return value = >'||to_char(x_return_value));

   	    IF (x_return_value = 0) then
   	        account_ccid := -1;
   	    END IF;
   	end if;
   	CLOSE get_accounts;

      if (account_ccid > 0) then

          open validate_ccid;
          fetch validate_ccid into l_ccid_valid;
          if (validate_ccid%NOTFOUND) then
             get_segs_success := FND_FLEX_EXT.get_segments(
                        application_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number => l_flex_num,
                        combination_id => account_ccid,
                        n_segments => n_segs,
                        segments => all_segments);
             delim := FND_FLEX_EXT.get_delimiter(
                        application_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number => l_flex_num);
             FA_GCCID_PKG.global_concat_segs :=
                FND_FLEX_EXT.concatenate_segments(
                        n_segments => n_segs,
                        segments   => all_segments,
                        delimiter  => delim);
             l_ret_value := FALSE;
          else
             l_ret_value := TRUE;
          end if;
          close validate_ccid;
      else
         l_ret_value := FALSE;
      end if;

    RETURN (l_ret_value);
   END IF;
RETURN FALSE;


END;-- Get_Account_CCID;


-- For FND logging, this function is alised as get_account_ccid2 since this is an overloaded
-- function
FUNCTION Get_Account_CCID (
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER,
        X_Distribution_ID IN NUMBER,
        X_Account_Type    IN VARCHAR2,
        X_Transaction_Header_ID IN NUMBER,
        X_Calling_function IN VARCHAR2,
        Account_CCID IN OUT NOCOPY NUMBER )
    RETURN BOOLEAN IS

    CURSOR get_ccid_adjustment(c_adjustment_type Varchar2) is
    SELECT nvl(code_combination_id,-1)
    FROM   fa_adjustments
    WHERE  book_type_code = X_book_type_code
    AND    asset_id = X_asset_id
    AND    distribution_id = X_distribution_id
    AND    Transaction_header_id = X_TRANSACTION_HEADER_ID
    AND    Source_type_code = X_calling_function
    AND    Adjustment_type = c_adjustment_type;


    l_return_ccid Number;
    l_default_ccid Number;
    l_adjustment_type fa_adjustments.adjustment_type%type;
    l_path_name VARCHAR2(150) ;

 BEGIN
    l_path_name := g_path||'get_account_ccid2';
-- calling the function get_account_ccid
   IF X_ACCOUNT_TYPE NOT IN ( 'INTERCO_AP_ACCT','INTERCO_AR_ACCT') THEN -- not inter company acct


          l_return_ccid := -1;
          IF (X_account_type = 'NBV_RETIRED_GAIN_ACCT') THEN

              l_adjustment_type := 'NBV RETIRED';
              Open get_ccid_adjustment(l_adjustment_type);
              fetch get_ccid_adjustment into l_return_ccid;
              IF get_ccid_adjustment%FOUND THEN
                Account_CCID := l_return_ccid;
                 IF Account_CCID > 0 THEN
                       return true;
                 END IF;
              ELSE
                l_return_ccid := -1;
             END IF;
            close get_ccid_adjustment;
          END IF;

          IF l_return_ccid = -1 THEN

	          IF NOT GET_ACCOUNT_CCID(X_book_type_code => X_book_type_code,
                            X_asset_id=>X_asset_id ,
                            X_Distribution_ID=>X_Distribution_ID,
                            X_Account_Type=>X_Account_Type,
                            Account_CCID => l_return_ccid) THEN
               Return False;
          END IF;

    		/* get the deault ccid from fa book controls */
        IF get_default_account ( X_book_type_code,
								l_default_ccid)THEN

          	        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
        	         p_full_path => l_path_name,
	                p_string => 'get default account sucessfull ..'|| l_default_ccid);
                Null;
            ELSE
              	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
            	     p_full_path => l_path_name,
        	     p_string => 'get default account failed..'|| l_default_ccid);
            	Account_ccid := -1;
            	RETURN FALSE;
            END IF;



            IF l_default_ccid = l_return_ccid Then

                /* get the mapping of adjustment type with the account types */

                  if (X_account_type = 'ASSET_COST_ACCT') then
                            l_adjustment_type := 'COST';
                   elsif (X_account_type = 'ASSET_CLEARING_ACCT') then
                    l_adjustment_type:= 'COST CLEARING';
                  elsif (X_account_type = 'DEPRN_RESERVE_ACCT') then
                        l_adjustment_type := 'RESERVE';
                  elsif (X_account_type = 'DEPRN_EXPENSE_ACCT') then
                        l_adjustment_type := 'EXPENSE';
                  elsif (X_account_type = 'REVAL_RSV_RETIRED_GAIN_ACCT') then
                        l_adjustment_type := 'REVAL RSV RET';
                  elsif (X_account_type = 'REVAL_RSV_RETIRED_LOSS_ACCT') then
                       l_adjustment_type := 'REVAL RSV RET';
                  elsif (X_account_type = 'NBV_RETIRED_GAIN_ACCT') then
                        l_adjustment_type := 'NBV RETIRED';
                  elsif (X_account_type = 'NBV_RETIRED_LOSS_ACCT') then
                        l_adjustment_type := 'NBV RETIRED';
                   /* elsif (X_account_type = 'NBV_RETIRED_GAIN_ACCT') then
                        l_adjustment_type := l_nbv_retired_gain_ccid;
                      elsif (X_account_type = 'NBV_RETIRED_LOSS_ACCT') then
                        l_adjustment_type := l_nbv_retired_loss_ccid;
                      elsif (X_account_type = 'PROCEEDS_OF_SALE_GAIN_ACCT') then
                        l_adjustment_type := l_pos_gain_ccid;
                      elsif (X_account_type = 'PROCEEDS_OF_SALE_LOSS_ACCT') then
                       l_adjustment_type := l_pos_loss_ccid;
                      elsif (X_account_type = 'COST_OF_REMOVAL_GAIN_ACCT') then
                        l_adjustment_type := l_cost_removal_gain_ccid;
                      elsif (X_account_type = 'COST_OF_REMOVAL_LOSS_ACCT') then
                        l_adjustment_type := l_cost_removal_gain_ccid;
                      elsif (X_account_type = 'COST_OF_REMOVAL_CLEARING_ACCT') then
                        l_adjustment_type := l_cor_clearing_ccid;
                      elsif (X_account_type = 'PROCEEDS_OF_SALE_CLEARING_ACCT') then
                        l_adjustment_type := l_pos_clearing_ccid;
                      elsif (X_account_type = 'REVAL_RSV_RETIRED_GAIN_ACCT') then
                    l_adjustment_type := l_reval_rsv_retired_gain_ccid;
                      elsif (X_account_type = 'REVAL_RSV_RETIRED_LOSS_ACCT') then
                        l_adjustment_type := l_reval_rsv_retired_loss_ccid;*/
              end if;

              Open get_ccid_adjustment(l_adjustment_type);
              fetch get_ccid_adjustment into l_return_ccid;
              If get_ccid_adjustment%NotFOUND THEN
                 l_return_ccid := l_default_ccid;
               end if;
                  close get_ccid_adjustment;
                  Account_CCID := l_return_ccid;
                  IF Account_CCID > 0 THEN
		         return true;
                  END IF;
           else
                 Account_CCID := l_return_ccid;
                 IF Account_CCID > 0 THEN
                        return true;
                 END IF;
           end if;
	END IF;
    ELSE -- inter company accts


             if (X_account_type = 'INTERCO_AP_ACCT') then
                         l_adjustment_type := 'INTERCO AP';
              elsif (X_account_type = 'INTERCO_AR_ACCT') then
                    l_adjustment_type:= 'INTERCO AR';
              end if;

              Open get_ccid_adjustment(l_adjustment_type);
              fetch get_ccid_adjustment into l_return_ccid;
              If get_ccid_adjustment%FOUND THEN
                 Account_CCID := l_return_ccid;
                 return true;
               ELSE
               -- call workflow to generate the intercompany acct
                   IF NOT GET_ACCOUNT_CCID(X_book_type_code => X_book_type_code,
                            X_asset_id=>X_asset_id ,
                            X_Distribution_ID=>X_Distribution_ID,
                            X_Account_Type=>X_Account_Type,
                            Account_CCID => l_return_ccid) THEN
                          Return False;
                  END IF;
                  IF Nvl(l_return_ccid,-1)= -1  Then
                       Account_CCID := -1;
                       return false;
                    else
                        Account_CCID:=l_return_ccid;
                        IF Account_CCID > 0 THEN
		               return true;
                 	END IF;
                  end if;
               END IF;

    END IF;

    IF Account_CCID = -1 THEN
    	IF NOT GET_ACCOUNT_CCID(X_book_type_code => X_book_type_code,
	                            X_asset_id=>X_asset_id ,
	                            X_Distribution_ID=>X_Distribution_ID,
	                            X_Account_Type=>X_Account_Type,
	                            Account_CCID => l_return_ccid) THEN
	                          Return False;
        ELSE
                                  Return true;
        END IF;
    ELSE
       Return true;
    END IF;

 END; -- get account ccid

-- FND log changes, stubbed out the following procedures since they shouldnt be used any more
-- Procedures have not been removed since they might have an impact on other files.

PROCEDURE debug_on is
Begin
	NULL;
End;

PROCEDURE debug_off is
Begin
	NULL;
End;

PROCEDURE debug_write(stmt varchar2) is
begin
        Null;
end;

-- FND log changes stubbing of procedures .. End

-- Shekar End

-- M Hazarika, 07-05-2002 start

-- This will function will round the currency amount
-- based on the asset book information
FUNCTION Iac_Round(
         X_Amount  IN OUT NOCOPY NUMBER,
         X_Book    IN     VARCHAR2)
RETURN BOOLEAN
IS
    l_path_name VARCHAR2(150);
BEGIN
    l_path_name := g_path||'iac_round';
   /*RETURN FA_UTILS_PKG.faxrnd(X_Amount,
                              X_Book);*/
	FA_ROUND_PKG.fa_round(X_Amount,
                                X_Book);
   	return TRUE;
    EXCEPTION
	WHEN OTHERS THEN
  	igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
        return FALSE ;
END Iac_Round;

-- M Hazarika, 07-05-2002 end

    FUNCTION Populate_iac_fa_deprn_data(
                X_book_type_code    VARCHAR2,
                X_calling_mode      VARCHAR2 )
    RETURN BOOLEAN IS

    CURSOR c_get_iac_fa_data IS
    SELECT 'X'
    FROM igi_iac_fa_deprn
    WHERE book_type_code LIKE x_book_type_code
    AND rownum = 1;

    l_dummy_char    VARCHAR2(1);
    l_errbuf        VARCHAR2(2000);
    l_retcode       NUMBER;
    l_path_name VARCHAR2(150);

    BEGIN
    l_path_name := g_path||'populate_iac_fa_deprn_data';
        OPEN c_get_iac_fa_data;
        FETCH c_get_iac_fa_data INTO l_dummy_char;
        IF c_get_iac_fa_data%FOUND THEN
            CLOSE c_get_iac_fa_data;
            RETURN TRUE;
        ELSE
            CLOSE c_get_iac_fa_data;
            igi_iac_ytd_pre_process_pkg.populate_iac_fa_deprn_data(l_errbuf
                          		, l_retcode
                          		, x_book_type_code
                          		, x_calling_mode);
            IF (l_retcode = 0) THEN
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        END IF;

    EXCEPTION WHEN OTHERS THEN
  	igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
        RETURN FALSE;
    END populate_iac_fa_deprn_data;


    /* Added for Bug 5846861 by Venkataramanan S on 02-Feb-2007
    FUNCTION NAME: Is_Asset_Adjustment_Done
    PARAMETERS: Book Type Code and Asset Id
    RETURN TYPE: BOOLEAN
    DESCRIPTION: This function checks whether adjustments have been made in the
    open period for the given Asset and Book combination. A "BOOLEAN TRUE" is
    returned if adjustments have been done. A "BOOLEAN FALSE" is returned otherwise
    */
    FUNCTION Is_Asset_Adjustment_Done(
        X_book_type_code IN VARCHAR2,
        X_asset_id       IN NUMBER)
    RETURN BOOLEAN IS
    CURSOR c_get_asset_adj (p_book_type_code   fa_transaction_headers.book_type_code%TYPE,
                                p_asset_id  fa_transaction_headers.asset_id%TYPE,
                                p_period_counter number) is
        SELECT 1
        FROM dual
        WHERE EXISTS
          (SELECT 1
           FROM igi_iac_adjustments_history
           WHERE book_type_code = p_book_type_code
           AND period_counter = p_period_counter
           AND asset_id = p_asset_id
           AND nvl(current_period_amortization,'N') <> 'Y'
           AND nvl(active_flag,    'N') = 'N')
        ;

        l_get_asset_adj   c_get_asset_adj%rowtype;
        l_prd_rec 		  IGI_IAC_TYPES.prd_rec;
        l_path_name       VARCHAR2(250);

    BEGIN
        l_path_name := g_path||'Is_Asset_Adjustment_Done';

        --Fetch the current open period
        IF igi_iac_common_utils.get_open_period_info(X_book_type_code,l_prd_rec) THEN
              igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => '     + Current Open Period counter'
                    ||l_prd_rec.period_counter );
        ELSE
              igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
                    p_full_path => l_path_name,
                    p_string => '     + Error while fetching open period information
                    + Current Open Period counter' ||l_prd_rec.period_counter );
        END IF;

        OPEN c_get_asset_adj( X_book_type_code,
                                      X_asset_id ,
                                      l_prd_rec.period_counter);
        FETCH c_get_asset_adj INTO l_get_asset_adj;

        --If Record exists then this implies adjustment have been done in the
        --current open period; return TRUE
        --otherwise return FALSE
        IF    c_get_asset_adj%FOUND THEN
            CLOSE    c_get_asset_adj;
            RETURN TRUE;
        ELSE
             CLOSE    c_get_asset_adj;
             RETURN FALSE;
        END IF;
    END Is_Asset_Adjustment_Done;


 BEGIN
 --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiacub.igi_iac_common_utils.';

--===========================FND_LOG.END=====================================


END; --package body

/
