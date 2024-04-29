--------------------------------------------------------
--  DDL for Package Body IGI_IAC_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_PROJ_PKG" AS
-- $Header: igiiacpb.pls 120.25 2007/08/01 10:47:04 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiacpb.IGI_IAC_PROJ_PKG.';

--===========================FND_LOG.END=====================================

-- ===================================================================
-- PROCEDURE Update_Status:
-- ===================================================================
   PROCEDURE Update_Status(x_projection_id  igi_iac_projections.projection_id%TYPE,
                           x_status         igi_iac_projections.status%TYPE
                          )
   IS


   BEGIN
      UPDATE igi_iac_projections
      SET status = x_status
      WHERE projection_id = x_projection_id;

   END Update_Status;

-- ===================================================================
-- FUNCTION Get_Period_Info_For_Counter : Gets period related
-- information for the period counter
-- ===================================================================
 FUNCTION Get_Period_Info_for_Counter( P_book_type_Code IN VARCHAR2 ,
                                       P_period_Counter IN NUMBER ,
                                       P_prd_rec       OUT NOCOPY igi_iac_types.prd_rec
                                      )
 RETURN BOOLEAN AS
	l_ret_flag		 BOOLEAN;
 BEGIN

   l_ret_flag := igi_iac_common_utils.get_Period_Info_for_Counter( P_book_type_Code,
                                                                   p_period_Counter,
                                                                   P_prd_rec );
   RETURN TRUE;

 EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(g_path||'Get_Period_Info_for_Counter');
     RETURN FALSE;
 END;


-- ===================================================================
-- FUNCTION Non_Depreciating_Asset: The function will check if the
-- asset is a non depreciating asset
-- ===================================================================
FUNCTION Non_Depreciating_Asset(x_asset_id    IN fa_books.asset_id%TYPE,
                                x_book_code   IN fa_books.book_type_code%TYPE)
RETURN BOOLEAN AS
  l_exists     NUMBER := 0;

BEGIN

   SELECT count(*)
   INTO l_exists
   FROM fa_books
   WHERE depreciate_flag = 'NO'
   AND transaction_header_id_out IS NULL
   AND book_type_code = x_book_code
   AND asset_id = x_asset_id;

   IF (l_exists = 0) THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Non_Depreciating_Asset' ,'Non Depr Asset'||sqlerrm);
     RETURN FALSE;

END Non_Depreciating_Asset;

-- ===================================================================
-- PROCEDURE Submit_Report_Request: Procedure to submit the
-- concurrent request for running the Projections report
-- ===================================================================
PROCEDURE submit_report_request(p_projection_id    IN igi_iac_projections.projection_id%type,
                                p_book_type_code   IN fa_books.book_type_code%type,
                                p_reval_period_num IN igi_iac_projections.revaluation_period%type,
                                p_concat_cat       IN varchar2,
                                p_start_period_name IN varchar2,
                                p_end_period_name  IN varchar2,
                                p_rx_attribute_set IN fa_rx_attrsets_b.attribute_set%TYPE,
                                p_rx_output_format IN fnd_lookups.lookup_code%TYPE) IS

    l_request_id			NUMBER;
    l_Err_Buf				VARCHAR2(1000);
    l_Ret_Code				NUMBER(3);
    l_message				varchar2(1000);

    l_report_id                         NUMBER;
    IGI_IAC_REQUEST_SUB_ERR 		Exception;
  BEGIN
     -- Get the report id
     SELECT report_id
     INTO l_report_id
     FROM fa_rx_reports r,
          fnd_concurrent_programs c,
          fnd_application a
     WHERE r.application_id = a.application_id
     AND r.application_id = c.application_id
     AND r.concurrent_program_id = c.concurrent_program_id
     AND a.application_short_name = 'IGI'
     AND c.concurrent_program_name = 'RXIGIIAP';


      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
      APPLICATION		 => 'IGI',
      PROGRAM			 => 'IGIIARXP', -- 'IGIIACPR',
      DESCRIPTION		 => 'Inflation Accounting : Projections Report',
      START_TIME		 => NULL,
      SUB_REQUEST		 => FALSE,
      ARGUMENT1		 	 => 'SUBMIT', -- p_projection_id,
      ARGUMENT2  	     	 => 'IGI',
      ARGUMENT3  		 => 'RXIGIIAP',
      ARGUMENT4                  => l_report_id,
      ARGUMENT5     		 => p_rx_attribute_set,
      ARGUMENT6             	 => p_rx_output_format,
      ARGUMENT7  	         => p_projection_id,
      ARGUMENT8           	 => p_book_type_code,
      ARGUMENT9           	 => p_reval_period_num,
      ARGUMENT10	         => p_concat_cat,
      ARGUMENT11   	         => p_start_period_name,
      ARGUMENT12   	         => p_end_period_name,
      ARGUMENT13   	         => p_rx_attribute_set,
      ARGUMENT14                 => p_rx_output_format,
      ARGUMENT15                 => chr(0),
      ARGUMENT16                 => NULL,
      ARGUMENT17                 => NULL,
      ARGUMENT18                 => NULL,
      ARGUMENT19                 => NULL,
      ARGUMENT20                 => NULL,
      ARGUMENT21                 => NULL,
      ARGUMENT22                 => NULL,
      ARGUMENT23                 => NULL,
      ARGUMENT24                 => NULL,
      ARGUMENT25                 => NULL,
      ARGUMENT26                 => NULL,
      ARGUMENT27                 => NULL,
      ARGUMENT28                 => NULL,
      ARGUMENT29                 => NULL,
      ARGUMENT30                 => NULL,
      ARGUMENT31                 => NULL,
      ARGUMENT32                 => NULL,
      ARGUMENT33                 => NULL,
      ARGUMENT34                 => NULL,
      ARGUMENT35                 => NULL,
      ARGUMENT36                 => NULL,
      ARGUMENT37                 => NULL,
      ARGUMENT38                 => NULL,
      ARGUMENT39                 => NULL,
      ARGUMENT40                 => NULL,
      ARGUMENT41                 => NULL,
      ARGUMENT42                 => NULL,
      ARGUMENT43                 => NULL,
      ARGUMENT44                 => NULL,
      ARGUMENT45                 => NULL,
      ARGUMENT46                 => NULL,
      ARGUMENT47                 => NULL,
      ARGUMENT48                 => NULL,
      ARGUMENT49                 => NULL,
      ARGUMENT50                 => NULL,
      ARGUMENT51                 => NULL,
      ARGUMENT52                 => NULL,
      ARGUMENT53                 => NULL,
      ARGUMENT54                 => NULL,
      ARGUMENT55                 => NULL,
      ARGUMENT56                 => NULL,
      ARGUMENT57                 => NULL,
      ARGUMENT58                 => NULL,
      ARGUMENT59                 => NULL,
      ARGUMENT60                 => NULL,
      ARGUMENT61                 => NULL,
      ARGUMENT62                 => NULL,
      ARGUMENT63                 => NULL,
      ARGUMENT64                 => NULL,
      ARGUMENT65                 => NULL,
      ARGUMENT66                 => NULL,
      ARGUMENT67                 => NULL,
      ARGUMENT68                 => NULL,
      ARGUMENT69                 => NULL,
      ARGUMENT70                 => NULL,
      ARGUMENT71                 => NULL,
      ARGUMENT72                 => NULL,
      ARGUMENT73                 => NULL,
      ARGUMENT74                 => NULL,
      ARGUMENT75                 => NULL,
      ARGUMENT76                 => NULL,
      ARGUMENT77                 => NULL,
      ARGUMENT78                 => NULL,
      ARGUMENT79                 => NULL,
      ARGUMENT80                 => NULL,
      ARGUMENT81                 => NULL,
      ARGUMENT82                 => NULL,
      ARGUMENT83                 => NULL,
      ARGUMENT84                 => NULL,
      ARGUMENT85                 => NULL,
      ARGUMENT86                 => NULL,
      ARGUMENT87                 => NULL,
      ARGUMENT88                 => NULL,
      ARGUMENT89                 => NULL,
      ARGUMENT90                 => NULL,
      ARGUMENT91                 => NULL,
      ARGUMENT92                 => NULL,
      ARGUMENT93                 => NULL,
      ARGUMENT94                 => NULL,
      ARGUMENT95                 => NULL,
      ARGUMENT96                 => NULL,
      ARGUMENT97                 => NULL,
      ARGUMENT98                 => NULL,
      ARGUMENT99                 => NULL,
      ARGUMENT100                => NULL
    );

    IF l_request_id = 0 THEN
      raise IGI_IAC_REQUEST_SUB_ERR;
    ELSE
	commit;
        FND_MESSAGE.SET_NAME('IGI','IGI_IAC_SUBMIT_REQUEST');
        FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id);
        l_message:= fnd_message.get;
	igi_iac_debug_pkg.debug_other_string(g_event_level,g_path||'submit_report_request','Submit Request'||l_message);

    END IF;
    EXCEPTION
    WHEN IGI_IAC_REQUEST_SUB_ERR then
      fnd_message.retrieve(l_message);
      igi_iac_debug_pkg.debug_other_string(g_event_level,g_path||'submit_report_request','Submit Request'||l_message);
   END submit_report_request;

-- ===================================================================
-- FUNCTION Get_Price_Index_Val: get the price index value for the book,
-- category and period
-- ===================================================================
  FUNCTION Get_Price_Index_Val(p_book_code fa_books.book_type_code%TYPE,
  	                           p_category_id fa_category_books.category_id%TYPE,
  	                           p_period_ctr fa_deprn_periods.period_counter%TYPE,
  	                           p_price_index_val OUT NOCOPY igi_iac_cal_idx_values.current_price_index_value%TYPE
                              )
  RETURN BOOLEAN
  IS

  -- To get deprn calendar
  CURSOR c_get_calendar(n_book_type_code fa_books.book_type_code%TYPE)
  IS
  SELECT deprn_calendar
  FROM fa_book_controls
  WHERE book_type_code = n_book_type_code;

  -- To get the price index value for a given period
  CURSOR c_get_price_index_value(n_book_code fa_books.book_type_code%TYPE,
 	                             n_category_id fa_category_books.category_id%TYPE,
 	                             n_start_date fa_calendar_periods.start_date%TYPE,
 	                             n_end_date fa_calendar_periods.end_date%TYPE,
 	                             n_calendar_type fa_calendar_periods.calendar_type%TYPE
                                )
  IS
  SELECT current_price_index_value
  FROM igi_iac_cal_idx_values
  WHERE date_from = n_start_date
  AND date_to = n_end_date
  AND cal_price_index_link_id = (SELECT cal_price_index_link_id
                                 FROM igi_iac_cal_price_indexes
		                         WHERE calendar_type= n_calendar_type
                                 AND price_index_id = (SELECT price_index_id
			                               FROM igi_iac_category_books
                                           WHERE book_type_code = n_book_code
			                               AND category_id= n_category_id));

   l_prd_rec 		igi_iac_types.prd_rec;
   l_ret_flag		BOOLEAN;
   l_calendar		fa_calendar_types.calendar_type%type;


  BEGIN
  	-- Get  Price index value
  	l_ret_flag := get_period_info_for_counter(p_book_code,
                                              p_period_ctr,
                                              l_prd_rec
                                             );
  	OPEN c_get_calendar(p_book_code);
  	FETCH c_get_calendar INTO l_calendar;
  	CLOSE c_get_calendar;

    OPEN  c_get_price_index_value(p_book_code,
                                  p_category_id,
                                  l_prd_rec.period_start_date,
                                  l_prd_rec.period_end_date,
                                  l_calendar
                                 );
    FETCH c_get_price_index_value INTO p_price_index_val;


    CLOSE c_get_price_index_value;

    RETURN TRUE;

  EXCEPTION
  WHEN OTHERS THEN
  	RETURN FALSE;
  END Get_Price_Index_Val;


-- ===================================================================
-- FUNCTION Get_Reval_Prd_Dpis_Ctr:
-- Bug no: 2514825 sowsubra start
--     Procedure  to get the period_counter of the revaluation period
--     before the start_period . If such a period does not exist - ie.
--     the book/asset was created afetr the revaluation period then
--     return the DPIS period_counter
--     the parameter l_reval_prd_ctr returns the either reval_prd or
--     dpis ctr
-- ===================================================================
  FUNCTION Get_Reval_Prd_Dpis_Ctr(p_book_code fa_books.book_type_code%TYPE,
  	                          p_asset_id  fa_books.asset_id%TYPE,
  	                          p_reval_prd_ctr OUT NOCOPY fa_deprn_summary.period_counter%TYPE
                                 )
  RETURN BOOLEAN
  IS

  -- get the revaluation period counter
  CURSOR c_get_reval_period(n_book_code  fa_books.book_type_code%TYPE,
                            n_asset_id   fa_books.asset_id%TYPE
                           )
  IS
  SELECT MAX(irr.period_counter) period_counter
  FROM igi_iac_revaluation_rates irr
  WHERE irr.book_type_code = n_book_code
  AND asset_id = n_asset_id
  AND irr.adjustment_id = (SELECT MAX(adjustment_id)
                           FROM igi_iac_transaction_headers
                           WHERE book_type_code = n_book_code
                           AND asset_id = n_asset_id
		           AND transaction_type_code = 'REVALUATION'
		           AND adjustment_status<>'PREVIEW');


  -- Cursor  to get the Date Placed in Service of the asset
  CURSOR c_get_dpis(n_book_code  fa_books.book_type_code%TYPE,
                    n_asset_id   fa_books.asset_id%TYPE
                   )
  IS
  SELECT date_placed_in_service
  FROM fa_books
  WHERE book_type_code = n_book_code
  AND asset_id = n_asset_id
  AND date_ineffective IS NULL;

  l_dpis                fa_books.date_placed_in_service%TYPE;
  l_ret_flag            BOOLEAN;
  l_get_reval_period    fa_deprn_summary.period_counter%TYPE;--c_get_reval_period%type;
  l_dpis_prd_rec        igi_iac_types.prd_rec;


 BEGIN

	-- Get the date placed in service
	OPEN c_get_dpis(p_book_code,
                    p_asset_id);
	FETCH c_get_dpis INTO l_dpis;
	CLOSE c_get_dpis;

	-- Get the period info for the dpis
	l_ret_flag := igi_iac_common_utils.Get_period_info_for_date(p_book_code,
                                                                    l_dpis,
                                                                    l_dpis_prd_rec
                                                                   );

	-- To get the the previous reval period counter
	OPEN c_get_reval_period(p_book_code,
                                p_asset_id);
	FETCH c_get_reval_period INTO l_get_reval_period;
        IF l_get_reval_period IS NOT NULL THEN    --(c_get_reval_period%FOUND) THEN
	    p_reval_prd_ctr:=l_get_reval_period;
        ELSE
            p_reval_prd_ctr := l_dpis_prd_rec.period_counter;
        END IF;
	CLOSE c_get_reval_period;

        RETURN TRUE;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Get_Reval_Prd_Dpis_Ctr' ,'Get Reval PC:'||'No Data found');
        RETURN FALSE;

  WHEN OTHERS THEN
	igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Get_Reval_Prd_Dpis_Ctr','exception Raised ');
	igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Get_Reval_Prd_Dpis_Ctr','Get Reval PC:'||sqlerrm);
        RETURN FALSE;

 END Get_Reval_Prd_Dpis_Ctr;

-- ===================================================================
-- PROCEDURE Get_Next_Period_Ctr: Procedure will retrieve the next
-- period counter
-- ===================================================================
  PROCEDURE Get_Next_Period_Ctr(p_period_rec IN igi_iac_types.prd_rec,
  	                            p_book_code IN fa_books.book_type_code%TYPE,
  	                            p_next_period_ctr OUT NOCOPY fa_deprn_periods.period_counter%TYPE)
  IS

  -- get the number of periods per fiscal year
  CURSOR c_get_num_per_period(n_calendar fa_calendar_types.calendar_type%TYPE)
  IS
  SELECT number_per_fiscal_year
  FROM fa_calendar_types
  WHERE calendar_type = n_calendar;

  -- Get deprn calendar
  CURSOR c_get_calendar(n_book_code fa_books.book_type_code%TYPE)
  IS
  SELECT deprn_calendar
  FROM fa_book_controls
  WHERE book_type_code = n_book_code;

  l_num_per_period      fa_calendar_types.number_per_fiscal_year%TYPE;
  l_mod_value		NUMBER;
  l_fiscal_yr 		fa_fiscal_year.fiscal_year%TYPE;
  l_next_period_num	fa_calendar_periods.period_num%TYPE;
  l_calendar		fa_calendar_types.calendar_type%TYPE;


  BEGIN

	OPEN c_get_calendar(p_book_code);
  	FETCH  c_get_calendar INTO l_calendar;
  	CLOSE  c_get_calendar;

  	OPEN c_get_num_per_period(l_calendar);
  	FETCH  c_get_num_per_period INTO l_num_per_period;
  	CLOSE  c_get_num_per_period;

  	l_mod_value := MOD(p_period_rec.period_num,l_num_per_period);

  	IF l_mod_value = 0 THEN
		l_fiscal_yr:=p_period_rec.fiscal_year+1;
	ELSE
		l_fiscal_yr:=p_period_rec.fiscal_year;
	END IF;

  	l_next_period_num:=l_mod_value+1;

  	p_next_period_ctr:= (l_fiscal_yr*l_num_per_period)+l_next_period_num;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
        igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Get_Next_Period_Ctr','Get Next PC: No Data Found');
  WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Get_Next_Period_Ctr','Exception raised: '||sqlerrm);
  END Get_Next_Period_Ctr;

-- ===================================================================
-- FUNCTION Chk_Asset_Life: Find if the life of asset is completed in
-- the given period
-- ===================================================================
  FUNCTION  Chk_Asset_Life( p_book_code fa_books.book_type_code%TYPE,
  			    p_period_counter fa_deprn_periods.period_counter%TYPE,
  			    p_asset_id fa_books.asset_id%TYPE,
                            l_last_period_counter OUT NOCOPY fa_deprn_periods.period_counter%TYPE
                          )
  RETURN BOOLEAN
  IS

  CURSOR c_get_asset_det(n_book_code   fa_books.book_type_code%TYPE,
                         n_asset_id    fa_books.asset_id%TYPE
                        )
  IS
  SELECT date_placed_in_service,
         life_in_months
  FROM fa_books
  WHERE book_type_code = n_book_code
  AND date_ineffective is NULL  -- Bug 5850597
  AND asset_id = n_asset_id;

  CURSOR c_get_periods_in_year(n_book_code fa_books.book_type_code%TYPE)
  IS
  SELECT number_per_fiscal_year
  FROM fa_calendar_types
  WHERE calendar_type = (SELECT deprn_calendar
                         FROM fa_book_controls
                         WHERE book_type_code = n_book_code);


  l_prd_rec_frm_ctr 		igi_iac_types.prd_rec;
  l_prd_rec_frm_date		igi_iac_types.prd_rec;
  l_end_date            	DATE;
  l_asset_rec			c_get_asset_det%ROWTYPE;
  l_ret_flag			BOOLEAN;
  l_mess			varchar2(255);

  l_periods_in_year             fa_calendar_types.number_per_fiscal_year%TYPE;
  l_dpis_prd_rec                igi_iac_types.prd_rec;
  l_total_periods               NUMBER;

  -- l_last_period_counter         NUMBER;

  BEGIN

       OPEN  c_get_asset_det(p_book_code,
                             p_asset_id
                            );
       FETCH c_get_asset_det INTO l_asset_rec;
       CLOSE c_get_asset_det;

       OPEN c_get_periods_in_year(p_book_code);
       FETCH c_get_periods_in_year INTO l_periods_in_year;
       CLOSE c_get_periods_in_year;

	-- Get the period info for the dpis
	l_ret_flag := igi_iac_common_utils.Get_period_info_for_date(p_book_code,
                                                                    l_asset_rec.date_placed_in_service,
                                                                    l_dpis_prd_rec
                                                                   );
       l_total_periods := ceil((l_asset_rec.life_in_months*l_periods_in_year)/12);
       l_last_period_counter := (l_dpis_prd_rec.period_counter + l_total_periods - 1);

--  Bug 3139173, last period in asset life is being missed out
--       IF (l_last_period_counter = p_period_counter) THEN
       IF (l_last_period_counter < p_period_counter) THEN
		RETURN FALSE; /* The life of asset is over */
       ELSE
		RETURN TRUE;  /* Life not over at this period */
       END IF;

  EXCEPTION
  WHEN OTHERS THEN
  	igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Chk_Asset_Life','Check Asset Life'||sqlerrm);
   raise_Application_error(-20001,SQLERRM);
	rollback;
  END Chk_Asset_Life;


-- ===================================================================
-- PROCEDURE Do_Proj_CAlc: Main procedure to calculate the projections
-- for the projection id
-- ===================================================================
  -- This procedure has been rewritten for the Projections enhancement project
  PROCEDURE Do_Proj_Calc(
                         errbuf     OUT NOCOPY VARCHAR2,
                         retcode    OUT NOCOPY VARCHAR2,
                         p_projection_id   IN   igi_iac_projections.projection_id%TYPE,
                         p_rx_attribute_set IN fa_rx_attrsets_b.attribute_set%TYPE,
                         p_rx_output_format IN fnd_lookups.lookup_code%TYPE
                        ) IS

    -- cursors
    -- Get all the projection details
    CURSOR c_get_proj(n_projection_id   NUMBER)
    IS
    SELECT book_type_code,
           start_period_counter,
           end_period,
           category_id,
       	   revaluation_period,
           status
    FROM igi_iac_projections
    WHERE projection_id = n_projection_id;


   --  Get all the assets that should be considered for projection
   -- this query should include non depreciating assets as well
   -- and excludes all fully retired assets for a category
   CURSOR c_get_assets_one_cat(n_book_code fa_books.book_type_code%TYPE,
                               n_category_id igi_iac_projections.category_id%TYPE DEFAULT NULL,
                               n_period_counter fa_deprn_summary.period_counter%TYPE)
   IS
   SELECT DISTINCT fh.asset_id asset_id
   FROM fa_books fb,
        fa_additions fh,
        igi_iac_category_books fcb
   WHERE fb.book_type_code = n_book_code
   AND fb.book_type_code = fcb.book_type_code
   AND fcb.category_id = fh.asset_category_id
   AND fh.asset_category_id = n_category_id
   AND fb.asset_id=fh.asset_id
   AND fb.period_counter_fully_retired IS NULL
   AND fh.asset_type <> 'CIP'
--   AND fb.asset_id IN (SELECT asset_id
--                       FROM fa_deprn_summary
--                       WHERE book_type_code = n_book_code
--                       AND period_counter = n_period_counter - 1
 --                      AND deprn_source_code <> 'BOOKS')
   ORDER BY fh.asset_id;

   --  Get all the assets that should be considered for projection
   -- this query should include non depreciating assets as well
   -- and excludes all fully retired assets for all categries
   CURSOR c_get_assets_all_cat(n_book_code fa_books.book_type_code%TYPE,
                               n_period_counter fa_deprn_summary.period_counter%TYPE)
   IS
   SELECT DISTINCT fh.asset_id asset_id
   FROM fa_books fb,
        fa_additions fh,
        igi_iac_category_books fcb
   WHERE fb.book_type_code = n_book_code
   AND fb.book_type_code = fcb.book_type_code
   AND fcb.category_id = fh.asset_category_id
   AND fb.asset_id=fh.asset_id
   AND fb.period_counter_fully_retired IS NULL
   AND fh.asset_type <> 'CIP'
 --  AND fb.asset_id IN (SELECT asset_id
 --                      FROM fa_deprn_summary
 --                      WHERE book_type_code = n_book_code
 --                      AND period_counter = n_period_counter - 1
 --                      AND deprn_source_code <> 'BOOKS')
   ORDER BY fh.asset_id;

   -- Get all the latest records  for the given  asset of the given book for which the  deprn had
   -- been run
   -- get the information from the distribution level
   CURSOR c_get_asset_all(n_book_type_code fa_books.book_type_code%TYPE,
                          n_asset_id fa_books.asset_id%TYPE )
   IS
   SELECT  ad.asset_id,
           dh.code_combination_id,
           ah.category_id,
           dd.period_counter,
           sum(nvl(id.adjustment_cost,0) + nvl(dd.cost,0)) adjusted_cost,
           sum(nvl(id.Deprn_Period+dd.deprn_amount-dd.deprn_adjustment_amount, 0)) deprn_period,
           sum(nvl(id.Deprn_YTD+ifd.deprn_ytd, 0)) deprn_ytd,
           'IAC' source_type
  FROM     fa_additions ad ,
           fa_Books bk ,
           fa_distribution_history dh,
           fa_deprn_Detail dd ,
           igi_iac_det_balances id ,
           igi_iac_fa_deprn ifd,
           gl_code_combinations cc,
           fa_categories cf,
           fa_asset_history ah
  WHERE ad.asset_id = dh.asset_id
  AND   cf.category_id = ah.category_id
  AND   bk.book_Type_code = n_book_type_code
  AND   ad.asset_id = n_asset_id
  AND   dh.book_type_Code = bk.book_type_code
  AND   dh.book_type_code = dd.book_type_code
  AND   dh.asset_id  = dd.asset_id
  AND   dh.distribution_id = dd.distribution_id
  AND   dh.asset_id = ah.asset_id
  AND   bk.depreciate_flag <> 'NO'
  AND   nvl(dh.date_ineffective,sysdate+1) > ah.date_effective
  AND   nvl(dh.date_ineffective,sysdate+1)  <= nvl(ah.date_ineffective,sysdate+1)
  AND   dd.period_counter = (SELECT  period_counter - 1
                             FROM fa_deprn_periods
                             WHERE book_type_code = n_book_type_code
                             AND period_close_date IS NULL)
  AND     bk.date_ineffective IS NULL
  AND     dh.distribution_id = id.distribution_id
  AND     dh.code_Combination_id = cc.code_combination_id
  AND     id.adjustment_id = ifd.adjustment_id
  AND     id.distribution_id = ifd.distribution_id
  AND     id.period_counter = ifd.period_counter
  AND     id.adjustment_id =       ( SELECT max(adjustment_id)
                                     FROM  igi_iac_transaction_headers it
                                     WHERE it.asset_id = bk.asset_id
                                     AND   it.book_type_code = bk.book_type_code
                                     AND   it.period_counter = dd.period_counter
                                     AND it.adjustment_status not in( 'PREVIEW', 'OBSOLETE'))
  GROUP BY ad.asset_id,
           dh.code_combination_id,
           ah.category_id,
           dd.period_counter
  UNION
  SELECT ad.asset_id,
       dh.code_combination_id,
       ah.category_id,
       dd.period_counter,
       sum(nvl(dd.cost,0))  adjusted_cost,
       sum(nvl(dd.deprn_amount,0)-nvl(dd.deprn_adjustment_amount,0))  deprn_period,
       sum(nvl(dd.ytd_deprn,0)) deprn_ytd,
       'FA'  source_type
  FROM fa_additions ad,
       fa_Books bk,
       fa_distribution_history dh,
       fa_deprn_Detail dd,
       gl_code_combinations cc,
       fa_categories cf,
       fa_asset_history ah
  WHERE ad.asset_id = bk.asset_id
  AND ad.asset_type <> 'CIP'
  AND cf.category_id = ah.category_id
  AND bk.transaction_header_id_out is NULL
  AND bk.book_type_code = n_book_type_code
  AND dd.asset_id = n_asset_id
  AND dd.asset_id = bk.asset_id
  AND dd.book_type_code = bk.book_type_code
  AND dh.distribution_id = dd.distribution_id
  AND dh.transaction_header_id_out is NULL
  AND dh.code_combination_id = cc.code_combination_id
  AND dh.asset_id = ah.asset_id
  AND nvl(dh.date_ineffective,sysdate+1) > ah.date_effective
  AND nvl(dh.date_ineffective,sysdate+1) <= nvl(ah.date_ineffective,sysdate+1)
  AND dd.period_counter = (SELECT  period_counter -1
                           FROM fa_deprn_periods
                           WHERE book_type_code = n_book_type_code
                           AND period_close_date IS NULL)
  AND bk.asset_id NOT IN
            (SELECT asset_id
            FROM igi_iac_asset_balances
            WHERE book_type_code = bk.book_type_code
            AND asset_id = bk.asset_id)
  AND  bk.depreciate_flag <> 'NO'
  GROUP BY ad.asset_id,
           dh.code_combination_id,
           ah.category_id,
           dd.period_counter
  UNION
  SELECT ad.asset_id,
       dh.code_combination_id,
       ah.category_id,
       dd.period_counter,
       sum(nvl(dd.cost,0))  adjusted_cost,
       0  deprn_period,
       0  deprn_ytd,
       'NONDEPFA'  source_type
  FROM fa_additions ad,
       fa_Books bk,
       fa_distribution_history dh,
       fa_deprn_Detail dd,
       gl_code_combinations cc,
       fa_categories cf,
       fa_asset_history ah
  WHERE ad.asset_id = bk.asset_id
  AND cf.category_id = ah.category_id
  AND ad.asset_type <> 'CIP'
  AND bk.transaction_header_id_out is NULL
  AND bk.book_type_code = n_book_type_code
  AND dd.asset_id = n_asset_id
  AND dd.asset_id = bk.asset_id
  AND dd.book_type_code = bk.book_type_code
  AND dh.distribution_id = dd.distribution_id
  AND dh.transaction_header_id_out is NULL
  AND dh.code_combination_id = cc.code_combination_id
  AND dh.asset_id = ah.asset_id
  AND nvl(dh.date_ineffective,sysdate+1) > ah.date_effective
  AND nvl(dh.date_ineffective,sysdate+1) <= nvl(ah.date_ineffective,sysdate+1)
  AND dd.period_counter = (SELECT  max(period_counter)
                           FROM fa_deprn_detail
                           WHERE book_type_code = n_book_type_code
                           AND   asset_id = n_asset_id)
  AND  bk.depreciate_flag = 'NO'
  GROUP BY ad.asset_id,
           dh.code_combination_id,
           ah.category_id,
           dd.period_counter
  UNION
  SELECT ad.asset_id,
       dh.code_combination_id,
       ah.category_id,
       dd.period_counter,
       sum(nvl(dd.cost,0))  adjusted_cost,
       sum(nvl(dd.deprn_amount,0)-nvl(dd.deprn_adjustment_amount,0))  deprn_period,
       sum(nvl(dd.ytd_deprn,0)) deprn_ytd,
       'FULLRSVDFA'  source_type
  FROM fa_additions ad,
       fa_Books bk,
       fa_distribution_history dh,
       fa_deprn_Detail dd,
       gl_code_combinations cc,
       fa_categories cf,
       fa_asset_history ah
  WHERE ad.asset_id = bk.asset_id
  AND ad.asset_type <> 'CIP'
  AND cf.category_id = ah.category_id
  AND bk.transaction_header_id_out is NULL
  AND bk.book_type_code = n_book_type_code
  AND dd.asset_id = n_asset_id
  AND dd.asset_id = bk.asset_id
  AND dd.book_type_code = bk.book_type_code
  AND dh.distribution_id = dd.distribution_id
  AND dh.transaction_header_id_out is NULL
  AND dh.code_combination_id = cc.code_combination_id
  AND dh.asset_id = ah.asset_id
  AND nvl(dh.date_ineffective,sysdate+1) > ah.date_effective
  AND nvl(dh.date_ineffective,sysdate+1) <= nvl(ah.date_ineffective,sysdate+1)
  AND dd.period_counter = (SELECT  period_counter_fully_reserved
                           FROM fa_books
                           WHERE book_type_code = n_book_type_code
                           AND asset_id = n_asset_id
                           AND date_ineffective IS NULL
                           AND transaction_header_id_out IS NULL)
  GROUP BY ad.asset_id,
           dh.code_combination_id,
           ah.category_id,
           dd.period_counter;

   -- cursor to get non depreciating IAC data
   CURSOR c_iac_non_deprn(n_asset_id    fa_books.asset_id%TYPE,
                          n_book_code   fa_books.book_type_code%TYPE)
   IS
   SELECT NVL(SUM(NVL(dd.adjustment_cost,0)),0)
   FROM igi_iac_det_balances dd,
        fa_books   fb
   WHERE dd.book_type_code = fb.book_type_code
   AND   dd.asset_id = fb.asset_id
   AND   dd.book_type_code = n_book_code
   AND   dd.asset_id = n_asset_id
   AND   fb.transaction_header_id_out IS NULL
   AND   fb.depreciate_flag = 'NO'
   AND   dd.adjustment_id = (SELECT max(ith.adjustment_id)
                             FROM   igi_iac_transaction_headers ith
                             WHERE  ith.book_type_code = n_book_code
                             AND    ith.asset_id = n_Asset_id
                             AND    ith.adjustment_status NOT IN( 'PREVIEW', 'OBSOLETE'));

   -- cursor to get fully reserved IAC data
 /*  CURSOR c_iac_full_rsvd(n_asset_id    fa_books.asset_id%TYPE,
                          n_book_code   fa_books.book_type_code%TYPE)
   IS
   SELECT NVL(SUM(NVL(dd.adjustment_cost,0)),0) adjustment_cost,
          NVL(sum(nvl(dd.Deprn_Period, 0)),0) deprn_period,
          NVL(sum(nvl(dd.Deprn_YTD+ifd.deprn_ytd, 0)),0) deprn_ytd
   FROM igi_iac_det_balances dd,
        igi_iac_fa_deprn ifd,
        fa_books   fb
   WHERE dd.book_type_code = fb.book_type_code
   AND   dd.asset_id = fb.asset_id
   AND   dd.distribution_id = ifd.distribution_id
   AND   dd.adjustment_id = ifd.adjustment_id
   AND   dd.asset_id = ifd.asset_id
   AND   dd.book_type_code = n_book_code
   AND   dd.asset_id = n_asset_id
   AND   fb.transaction_header_id_out IS NULL
   AND   fb.period_counter_fully_reserved IS NOT NULL
   AND   dd.adjustment_id = (SELECT max(ith.adjustment_id)
                             FROM   igi_iac_transaction_headers ith
                             WHERE  ith.book_type_code = n_book_code
                             AND    ith.asset_id = n_Asset_id
                             AND    ith.adjustment_status NOT IN( 'PREVIEW', 'OBSOLETE'));
*/
   -- check to see if the asset is fully reserved
   CURSOR c_chk_fully_rsvd (n_asset_id fa_books.asset_id%TYPE,
                            n_book_code fa_books.book_type_code%TYPE)
   IS
   SELECT period_counter_fully_reserved
   FROM fa_books where book_type_code =  n_book_code
   AND asset_id = n_asset_id;

    -- cursor to retrieve the DPIS date for an asset
    CURSOR c_get_asset_dpis(n_asset_id fa_books.asset_id%TYPE,
                            n_book_type_code fa_books.book_type_code%TYPE)
    IS
    SELECT date_placed_in_service
    FROM fa_books
    WHERE asset_id = n_asset_id
    AND book_type_code = n_book_type_code
    AND date_ineffective IS NULL;

    -- variables
     -- variables for projection detail records
    TYPE asset_id_type IS TABLE OF fa_books.asset_id%TYPE INDEX BY BINARY_INTEGER;

    TYPE asset_id_type1 IS TABLE OF igi_iac_proj_details.asset_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE proj_id_type IS TABLE OF igi_iac_proj_details.projection_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE period_counter_type IS TABLE OF igi_iac_proj_details.projection_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE category_id_type IS TABLE OF igi_iac_proj_details.category_id%TYPE INDEX BY BINARY_INTEGER;
    TYPE fiscal_year_type IS TABLE OF igi_iac_proj_details.fiscal_year%TYPE INDEX BY BINARY_INTEGER;
    TYPE company_type IS TABLE OF igi_iac_proj_details.company%TYPE INDEX BY BINARY_INTEGER;
    TYPE cost_center_type IS TABLE OF igi_iac_proj_details.cost_center%TYPE INDEX BY BINARY_INTEGER;
    TYPE reval_cost_type IS TABLE OF igi_iac_proj_details.latest_reval_cost%TYPE INDEX BY BINARY_INTEGER;
    TYPE deprn_period_type IS TABLE OF igi_iac_proj_details.deprn_period%TYPE INDEX BY BINARY_INTEGER;
    TYPE deprn_ytd_type IS TABLE OF igi_iac_proj_details.deprn_ytd%TYPE INDEX BY BINARY_INTEGER;
    TYPE asset_exception_type IS TABLE OF igi_iac_proj_details.asset_exception%TYPE INDEX BY BINARY_INTEGER;
    TYPE reccount_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE proj_details IS RECORD (
      record_counter     reccount_type,
      projection_id      proj_id_type,
      period_counter     period_counter_type,
      category_id        category_id_type,
      fiscal_year        fiscal_year_type,
      company            company_type,
      cost_center        cost_center_type,
      asset_id           asset_id_type1,
      latest_reval_cost  reval_cost_type,
      deprn_period       deprn_period_type,
      deprn_ytd          deprn_ytd_type,
      asset_exception    asset_exception_type);


    l_proj_rec           proj_details;
    l_assets_list        asset_id_type;
    l_asset_count        NUMBER;
    l_asset_id           fa_books.asset_id%TYPE;

    l_book_type_code         igi_iac_projections.book_type_code%TYPE;
    l_start_period_counter   igi_iac_projections.start_period_counter%TYPE;
    l_reval_period_ctr       igi_iac_projections.start_period_counter%TYPE;

    l_end_period_counter     igi_iac_projections.end_period%TYPE;
    l_category_id            igi_iac_projections.category_id%TYPE;
    l_reval_period_num       igi_iac_projections.revaluation_period%TYPE;
    l_status                 igi_iac_projections.status%TYPE;

    l_sob_id                 fa_book_controls.set_of_books_id%TYPE;
    l_get_asset_bal_rec      c_get_asset_all%ROWTYPE;
    l_asset_dpis_date        fa_books.date_placed_in_service%TYPE;

    l_next_period_ctr        igi_iac_projections.start_period_counter%TYPE := 0;
    l_period_info_rec        igi_iac_types.prd_rec;
    l_dpis_info_rec          igi_iac_types.prd_rec;
    l_ret_flag               BOOLEAN;
    l_fully_rsvd             fa_books.period_counter_fully_reserved%TYPE;
    l_company_seg            VARCHAR2(30);
    l_cc_seg                 VARCHAR2(30);

    l_hist_cost              fa_books.cost%TYPE;
    l_iac_cost               igi_iac_asset_balances.adjusted_cost%TYPE;
    l_hist_deprn_period      igi_iac_proj_details.deprn_period%TYPE;
    l_iac_deprn_period       igi_iac_proj_details.deprn_period%TYPE;
    l_hist_deprn_ytd         igi_iac_proj_details.deprn_ytd%TYPE;
    l_iac_deprn_ytd          igi_iac_proj_details.deprn_ytd%TYPE;

    l_curr_cost              fa_books.cost%TYPE;
    l_prev_cost              fa_books.cost%TYPE;
    l_curr_deprn_period      igi_iac_proj_details.deprn_period%TYPE;
    l_prev_deprn_period      igi_iac_proj_details.deprn_period%TYPE;
    l_curr_deprn_period_catchup       igi_iac_proj_details.deprn_period%TYPE;
    l_curr_deprn_ytd         igi_iac_proj_details.deprn_ytd%TYPE;
    l_prev_deprn_ytd         igi_iac_proj_details.deprn_ytd%TYPE;
    l_prior_prd_deprn_ytd         igi_iac_proj_details.deprn_ytd%TYPE;


    l_prior_prd_index_val    igi_iac_cal_idx_values.current_price_index_value%TYPE;
    l_curr_price_index_val   igi_iac_cal_idx_values.current_price_index_value%TYPE;
    l_prior_cumul_rate	     igi_iac_asset_balances.cumulative_reval_factor%TYPE;
    l_curr_reval_rate 	     igi_iac_asset_balances.current_reval_factor%TYPE;
    l_curr_reval_rate 	     igi_iac_asset_balances.current_reval_factor%TYPE;
    l_cumul_rate 	     igi_iac_asset_balances.cumulative_reval_factor%TYPE;

    l_count                  NUMBER := 1;
    l_login_id               NUMBER := fnd_profile.value('LOGIN_ID');
    l_user_id                NUMBER := fnd_profile.value('USER_ID');

    l_prd_rec                igi_iac_types.prd_rec;
    l_start_period_name      VARCHAR2(30);
    l_end_period_name        VARCHAR2(30);
    l_concat_cat             VARCHAR2(500);
    l_cat_segs               fa_rx_shared_pkg.Seg_Array;
    l_cat_struct             fa_system_controls.category_flex_structure%TYPE;


    l_last_prd_counter       fa_deprn_periods.period_counter%TYPE;
    l_rec_count              NUMBER;

    -- exceptions
    NO_ASSETS_FOUND                 EXCEPTION;
    NO_INDEX_FOUND                  EXCEPTION;
    NO_PROJ_MAIN_DATA               EXCEPTION;
    NO_ASSETS_TO_PROJECT            EXCEPTION;

  BEGIN

    -- Get all the projection details
    OPEN c_get_proj(p_projection_id);
    FETCH c_get_proj INTO
      l_book_type_code,
      l_start_period_counter,
      l_end_period_counter,
      l_category_id,
      l_reval_period_num,
      l_status;

    IF c_get_proj%NOTFOUND THEN
       RAISE NO_PROJ_MAIN_DATA;
    END IF;
    CLOSE c_get_proj;

    -- get period name for start period counter
    l_ret_flag := igi_iac_common_utils.get_period_info_for_counter( l_book_type_code,
                                                                    l_start_period_counter,
                                                                    l_prd_rec );
    l_start_period_name := l_prd_rec.period_name;

    -- get period name for end period counter
    l_ret_flag := igi_iac_common_utils.get_period_info_for_counter( l_book_type_code,
                                                                    l_end_period_counter,
                                                                    l_prd_rec );

    l_end_period_name := l_prd_rec.period_name;

    -- get the category and asset key flex structures
    SELECT category_flex_structure
    INTO   l_cat_struct
    FROM   fa_system_controls;

    -- get category
    IF (l_category_id IS NOT NULL) THEN
      -- get the concatenated category name
      fa_rx_shared_pkg.concat_category (
                                       struct_id       => l_cat_struct,
                                       ccid            => l_category_id,
                                       concat_string   => l_concat_cat,
                                       segarray        => l_cat_segs);
    ELSE

      l_concat_cat := 'All';
    END IF;

    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc','Book type code:   '||l_book_type_code);
    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc','CAtegory Id:    '||l_category_id);
    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc','Start period name:  '||l_start_period_name);
    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc','End Period name:   '||l_end_period_name);
    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc','Revaluation Period number:   '||l_reval_period_num);

    -- get the set of books id for the book
    SELECT  set_of_books_id
    INTO l_sob_id
    FROM fa_book_controls
    WHERE book_type_code =l_book_type_code;

    -- Retrieve all the assets that qualify for the projection run
    IF (l_category_id IS NOT NULL) THEN
       -- if it is for a category
        OPEN c_get_assets_one_cat(l_book_type_code, l_category_id, l_start_period_counter);
        FETCH c_get_assets_one_cat BULK COLLECT INTO l_assets_list;
        CLOSE c_get_assets_one_cat;
    ELSE
       -- if it is for all cats
	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Getting assets for all IAC categories');
        OPEN c_get_assets_all_cat(l_book_type_code, l_start_period_counter);
        FETCH c_get_assets_all_cat BULK COLLECT INTO l_assets_list;
        CLOSE c_get_assets_all_cat;
    END IF;

    l_rec_count := l_assets_list.COUNT;

    -- calculate projections for each of the assets queried
    FOR i IN 1 .. l_assets_list.COUNT
    LOOP
       -- get the asset position for the latest closed or depreciated period
       l_asset_id := l_assets_list(i);

       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Processing asset id:  '||l_asset_id);

       -- get the dpis for the asset
       OPEN c_get_asset_dpis(l_asset_id,
                             l_book_type_code);
       FETCH c_get_asset_dpis INTO l_asset_dpis_date;
       IF c_get_asset_dpis%NOTFOUND THEN
          CLOSE c_get_asset_dpis;
       END IF;
       CLOSE c_get_asset_dpis;

       -- get the period counter associated with the dpis
       l_ret_flag := igi_iac_common_utils.get_period_info_for_date(l_book_type_code,
                                                                   l_asset_dpis_date,
                                                                   l_dpis_info_rec);

       -- check if the asset is fully reserved
       OPEN c_chk_fully_rsvd (l_asset_id,
                              l_book_type_code);
       FETCH c_chk_fully_rsvd INTO l_fully_rsvd;
       IF c_chk_fully_rsvd%NOTFOUND THEN
          CLOSE c_chk_fully_rsvd;
       END IF;
       CLOSE c_chk_fully_rsvd;

       -- bug 3188025, start 1
       <<L_asset_loop>>
       -- bug 3188025, end 1
       -- For each asset distribution ccid record loop
       FOR l_get_asset_bal_rec IN c_get_asset_all(l_book_type_code,l_asset_id)
       LOOP

          -- bug 3188025, start 2
          -- only inactive dists will have cost and deprn period 0 at the same time
          -- so filter these out now
          IF (l_get_asset_bal_rec.adjusted_cost = 0 AND l_get_asset_bal_rec.deprn_period = 0) THEN
            igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Exiting loop L_asset_loop');

             EXIT L_asset_loop;
          END IF;

          -- bug 3188025, end 2
          -- To get company name in company
          l_ret_flag := igi_iac_common_utils.get_account_segment_value(l_sob_id,
                                                                       l_get_asset_bal_rec.code_combination_id,
                                                                       'GL_BALANCING',
                                                                       l_company_seg);

          -- To get  cost center in l_cost_center
          l_ret_flag := igi_iac_common_utils.get_account_segment_value(l_sob_id,
                                                                       l_get_asset_bal_rec.code_combination_id,
                                                                       'FA_COST_CTR',
                                                                       l_cc_seg);


	      igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Company: '||l_company_seg||' Cost Center: '||l_cc_seg);

 --        IF (l_fully_rsvd IS NOT NULL) THEN
          IF (l_get_asset_bal_rec.source_type = 'FULLRSVDFA') THEN
             -- asset is fully reserved
             igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Asset is fully reserved');
             l_count := l_count + 1;

             -- set the asset details for the projection record
             l_proj_rec.record_counter(l_count) := l_count;
             l_proj_rec.asset_id(l_count) := l_asset_id;
             l_proj_rec.projection_id(l_count) := p_projection_id;
             l_proj_rec.company(l_count) := l_company_seg;
             l_proj_rec.cost_center(l_count) := l_cc_seg;
             l_proj_rec.category_id(l_count) := l_get_asset_bal_rec.category_id;

             -- get the period information for the start period counter
             l_ret_flag := get_period_info_for_counter(l_book_type_code,
                                                       l_start_period_counter,
                                                       l_period_info_rec);

             -- set period related information for the projection record
             l_proj_rec.fiscal_year(l_count) := l_period_info_rec.fiscal_year;
             l_proj_rec.period_counter(l_count) := l_start_period_counter;

             -- set the exception comment and the projection amounts to NULL
             l_proj_rec.asset_exception(l_count) := 'FULL_RSVD';
             l_proj_rec.latest_reval_cost(l_count) := NULL;
             l_proj_rec.deprn_period(l_count) := NULL;
             l_proj_rec.deprn_ytd(l_count) := NULL;

         ELSE
            -- asset is not fully reserved
            -- do the projections calculations

	    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Asset is not a fully reserved asset, calculating projections');
            -- initialise the period counter
            l_next_period_ctr := l_start_period_counter;

            l_prev_cost := l_get_asset_bal_rec.adjusted_cost;
            l_prev_deprn_period := l_get_asset_bal_rec.deprn_period;
            l_prev_deprn_ytd := l_get_asset_bal_rec.deprn_ytd;

            -- Get the previous revaluation period or the DPIS period if it does not exist
	        --  Get the price index details for this period  into l_prior_prd_index_val
            l_ret_flag := get_reval_prd_dpis_ctr(l_book_type_code,
                                                 l_asset_id,
                                                 l_reval_period_ctr);

	    l_ret_flag:= get_price_index_val(l_book_type_code,
                                             l_get_asset_bal_rec.category_id,
                                             l_reval_period_ctr,
                                             l_prior_prd_index_val);

	    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'The previous reval period is:   '  || l_reval_period_ctr);

            -- calculate projections for the projection period while asset still has life
            -- and is not fully reserved

            WHILE ((l_next_period_ctr <= l_end_period_counter) AND
                      chk_asset_life(l_book_type_code, l_next_period_ctr,l_asset_id, l_last_prd_counter))
                          --  AND l_prev_cost >= 0)
            LOOP
	       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Next period counter:  '||l_next_period_ctr);

               -- increase the counter
               l_count := l_count + 1;

               -- set the asset details for the projection record
               l_proj_rec.record_counter(l_count) := l_count;
               l_proj_rec.asset_id(l_count) := l_asset_id;
               l_proj_rec.projection_id(l_count) := p_projection_id;
               l_proj_rec.company(l_count) := l_company_seg;
               l_proj_rec.cost_center(l_count) := l_cc_seg;
               l_proj_rec.category_id(l_count) := l_get_asset_bal_rec.category_id;
               -- get the period information for the next period counter
               l_ret_flag := get_period_info_for_counter(l_book_type_code,
                                                         l_next_period_ctr,
                                                         l_period_info_rec);

               -- set period related information for the projection record
               l_proj_rec.fiscal_year(l_count) := l_period_info_rec.fiscal_year;
               l_proj_rec.period_counter(l_count) := l_next_period_ctr;

               -- get the price_index_value  for the current period l_next_period_ctr
               l_ret_flag	:= get_price_index_val(l_book_type_code,
                                                   l_get_asset_bal_rec.category_id,
                                                   l_next_period_ctr,
                                                   l_curr_price_index_val);
	       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Price Index Value:  '||l_curr_price_index_val);

               -- Bug 3139146, if PI is 9999.99 then do not calculate projections
               -- instead trap with exceptions code INVALID_PI
               IF (l_curr_price_index_val = 9999.99 OR l_prior_prd_index_val = 9999.99) THEN
                  -- set cost, deprn_period and ytd_deprn to 0
                  -- set exception to INVALID_PI
		  igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Invalid Price Index');
                  l_proj_rec.latest_reval_cost(l_count) := 0;
                  l_proj_rec.deprn_period(l_count) := 0;
                  l_proj_rec.deprn_ytd(l_count) := 0;
                  l_proj_rec.asset_exception(l_count) := 'INVALID_PI';
                  EXIT;
               ELSE
                  -- valid PI
                  -- check if this is a non depreciating asset
                  -- if it has delta IAC amount then add it to the  FA cost for the first run
                  IF (l_get_Asset_bal_rec.source_type = 'NONDEPFA' AND
                                                l_next_period_ctr = l_start_period_counter) THEN
                     OPEN c_iac_non_deprn(l_asset_id, l_book_type_code);
                     FETCH c_iac_non_deprn INTO l_iac_cost;
                     CLOSE c_iac_non_deprn;
                     igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Non Depreciating IAC cost:  '||l_iac_cost);
                     l_prev_cost := l_prev_cost + l_iac_cost;
                  END IF;

                  -- check if the period is a revaluation period or just a normal period
                  -- to calculate the cost or the periodic depreciation amount
                  IF (l_period_info_rec.period_num = l_reval_period_num) THEN
		     igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'This is revaluation period number: '||l_reval_period_num);
                     -- this is the revaluation catchup period
                     -- calculate the current cost

                     l_curr_cost := l_prev_cost*(l_curr_price_index_val/l_prior_prd_index_val);

                     -- calculate the current depreciation period if it a depreciating asset
     --              IF NOT Non_Depreciating_Asset(l_asset_id, l_book_type_code) THEN
                     IF (l_get_asset_bal_rec.source_type <> 'NONDEPFA') THEN
                        l_curr_deprn_period := l_prev_deprn_period*(l_curr_price_index_val/l_prior_prd_index_val);
                        /* 01-Aug-2003, commenting out as catchup should be calculated for all instances
                        IF (l_get_asset_bal_rec.source_type = 'IAC') THEN
                           l_curr_deprn_period_catchup :=
                               l_prev_deprn_ytd*((l_curr_price_index_val/l_prior_prd_index_val) - 1);
                        ELSE
                           l_curr_deprn_period_catchup := 0;
                        END IF; */

                        -- calculate the catchup amount
                        l_curr_deprn_period_catchup :=
                            l_prev_deprn_ytd*((l_curr_price_index_val/l_prior_prd_index_val) - 1);

                        -- calculate the YTD depreciation amount
                        IF (l_period_info_rec.period_num = 1) THEN
                            l_curr_deprn_ytd := l_curr_deprn_period + l_curr_deprn_period_catchup;
                        ELSE
                            l_curr_deprn_ytd := l_prev_deprn_ytd + l_curr_deprn_period + l_curr_deprn_period_catchup;
                        END IF;
                     ELSE
                        -- is a non deprecaiting asset
                        l_curr_deprn_period := 0;
                        l_curr_deprn_period_catchup := 0;
                        l_curr_deprn_ytd := 0;
                     END IF;
                  ELSE
                     l_curr_cost := l_prev_cost;
                     l_curr_deprn_period := l_prev_deprn_period;
                     -- calculate the YTD depreciation amount
                     IF (l_period_info_rec.period_num = 1) THEN
                         l_curr_deprn_ytd := l_curr_deprn_period;
                     ELSE
                         l_curr_deprn_ytd := l_prev_deprn_ytd + l_curr_deprn_period;
                     END IF;
                  END IF;

                  -- set the rest of the details
                  -- bug 3139173, handling exception or comments

                  l_proj_rec.asset_exception(l_count) := NULL;
                  --IF (l_curr_cost = 0) THEN
                  IF (l_next_period_ctr = l_last_prd_counter) THEN
                     -- asset is fully reserved
                     l_proj_rec.asset_exception(l_count) := 'FULL_RSVD2';
                  END IF;

                  l_proj_rec.latest_reval_cost(l_count) := l_curr_cost;

                  IF (l_period_info_rec.period_num = l_reval_period_num) THEN
                      l_proj_rec.deprn_period(l_count) := l_curr_deprn_period_catchup + l_curr_deprn_period;
                      l_proj_rec.asset_exception(l_count) := 'REVAL_PRD';
                  ELSE
                      l_proj_rec.deprn_period(l_count) := l_curr_deprn_period;
               --       l_proj_rec.asset_exception(l_count) := NULL;
                  END IF;
                  l_proj_rec.deprn_ytd(l_count) := l_curr_deprn_ytd;

                  -- set the exception flag for non depreciating assets for the first rwo only
                  IF (l_next_period_ctr = l_start_period_counter AND l_get_asset_bal_rec.source_type = 'NONDEPFA') THEN
                      l_proj_rec.asset_exception(l_count) := 'NON_DEPR_ASSET';
                  END IF;

                  -- round the calculated amounts
                  l_ret_flag := igi_iac_common_utils.iac_round(l_proj_rec.latest_reval_cost(l_count),l_book_type_code);
                  l_ret_flag := igi_iac_common_utils.iac_round(l_proj_rec.deprn_period(l_count),l_book_type_code);
                  l_ret_flag := igi_iac_common_utils.iac_round(l_proj_rec.deprn_ytd(l_count),l_book_type_code);

                  -- Get the next period ctr  and store it in l_next_period_ctr
    	          get_next_period_ctr(l_period_info_rec,l_book_type_code,l_next_period_ctr);

                  -- set the previous values
                  l_prev_cost := l_curr_cost;
                  l_prev_deprn_period := l_curr_deprn_period;
                  l_prev_deprn_ytd := l_curr_deprn_ytd;
               END IF; -- check for valide PI
            END LOOP; -- end projection period counter loop (while)

         END IF; -- fully reserved asset check
      END LOOP; -- end for c_get_asset_all loop
    END LOOP;  -- end for l_asset_id loop

    IF (l_rec_count > 0) THEN
       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Before insertion into igi_iac_proj_details');
       -- insert the projections into igi_iac_proj_details
       FORALL l_count IN l_proj_rec.record_counter.FIRST..l_proj_rec.record_counter.LAST
        INSERT INTO igi_iac_proj_details(
                    projection_id,
                    period_counter,
                    category_id,
                    fiscal_year,
                    company,
                    cost_center,
                    asset_id,
                    latest_reval_cost,
                    deprn_period,
                    deprn_ytd,
                    asset_exception,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login
                    ) VALUES (
                    l_proj_rec.projection_id(l_count),
                    l_proj_rec.period_counter(l_count),
                    l_proj_rec.category_id(l_count),
                    l_proj_rec.fiscal_year(l_count),
                    l_proj_rec.company(l_count),
                    l_proj_rec.cost_center(l_count),
                    l_proj_rec.asset_id(l_count),
                    l_proj_rec.latest_reval_cost(l_count),
                    l_proj_rec.deprn_period(l_count),
                    l_proj_rec.deprn_ytd(l_count),
                    l_proj_rec.asset_exception(l_count),
                    l_user_id,
                    sysdate,
                    l_user_id,
                    sysdate,
                    l_login_id);
       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'Do_Proj_Calc' ,'Insert complete');

       -- submit the report
       igi_iac_debug_pkg.debug_other_string(g_event_level,g_path||'Do_Proj_Calc' ,'Submitted the RX Projections report');
       submit_report_request(p_projection_id,
                          l_book_type_code,
                          l_reval_period_num,
                          l_concat_cat,
                          l_start_period_name,
                          l_end_period_name,
                          p_rx_attribute_set,
                          p_rx_output_format
                         );
    ELSE
       RAISE NO_ASSETS_TO_PROJECT;
    END IF;
	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Projections completed successfully');

	igi_iac_debug_pkg.debug_other_msg(g_event_level,g_path||'Do_Proj_Calc',TRUE);
    errbuf := fnd_message.get;
    retcode := 0;
    -- ROLLBACK;
  EXCEPTION
  WHEN NO_PROJ_MAIN_DATA then
        Update_Status(p_projection_id, 'ERROR');
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Do_Proj_Calc' ,'Projection submission information could not be found ');
        FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Projection submission information could not be found ');

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
	retcode := 2;
  WHEN NO_DATA_FOUND  then
    Update_Status(p_projection_id, 'ERROR');
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Do_Proj_Calc' ,'No data found '||sqlerrm);
	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','No data found '||sqlerrm);

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
        retcode := 2;
  WHEN NO_ASSETS_FOUND then
    Update_Status(p_projection_id, 'ERROR');
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Do_Proj_Calc' ,'No assets are present for this book and category . Hence projections is not run ');
	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','No assets are present for this book and category . Hence projections is not run ');

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
        retcode := 2;
  WHEN NO_INDEX_FOUND then
    Update_Status(p_projection_id, 'ERROR');
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Do_Proj_Calc' ,'No Price index value found for this calendar and price index ');
	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','No Price index value found for this calendar and price index ');

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
        retcode := 2;
  WHEN NO_ASSETS_TO_PROJECT then
	igi_iac_debug_pkg.debug_other_string(g_error_level,g_path||'Do_Proj_Calc' ,'No assets have been selected for Projections. Hence, report not submitted');
	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','No assets have been selected for Projections. Hence, report not submitted');

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
        retcode := 0;
  WHEN OTHERS THEN
    Update_Status(p_projection_id, 'ERROR');
	igi_iac_debug_pkg.debug_other_string(g_unexp_level,g_path||'Do_Proj_Calc' ,sqlerrm);
        FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_proj_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE',sqlerrm);

	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'Do_Proj_Calc',FALSE);
        errbuf := fnd_message.get;
        retcode := 2;
  END Do_Proj_Calc;

   -- 15-May-2003, add new procedure to delete projections for a range of projection ids
  PROCEDURE Delete_Projections(
                                p_from_projection IN igi_iac_projections.projection_id%TYPE,
                                p_to_projection   IN igi_iac_projections.projection_id%TYPE
                              ) IS

  BEGIN

    DELETE FROM igi_iac_proj_details
    WHERE projection_id BETWEEN p_from_projection AND p_to_projection;

    DELETE FROM igi_iac_projections
    WHERE projection_id BETWEEN p_from_projection AND p_to_projection;

    DELETE FROM igi_iac_proj_rep_itf
    WHERE projection_id BETWEEN p_from_projection AND p_to_projection;

  END Delete_Projections;


END igi_iac_proj_pkg; -- Package body


/
