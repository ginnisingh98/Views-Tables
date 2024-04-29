--------------------------------------------------------
--  DDL for Package Body IGI_IAC_CREATE_ASSETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_CREATE_ASSETS" AS
-- $Header: igiiacab.pls 120.17.12010000.2 2010/06/24 10:46:39 schakkin ship $


--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiacab.IGI_IAC_CREATE_ASSETS.';

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

/* to be deleted from spec and body */
PROCEDURE log(p_mesg IN VARCHAR2)IS

BEGIN
  IF FND_PROFILE.VALUE('IGI_DEBUG_OPTION') = 'Y'  THEN
    fnd_file.put_line(fnd_file.log, p_mesg);
  END IF;
END;


PROCEDURE get_adjusted_cost(p_asset_id IN NUMBER,
                           p_period_counter IN NUMBER,
                           p_book   IN VARCHAR2,
                           l_adjusted_cost OUT NOCOPY NUMBER)
 IS

  /*  bug 3451539 start 1
    -- no longer required
  CURSOR c_fully_reserved(p_book IN VARCHAR2,
                          p_asset_id IN NUMBER)
  IS

  SELECT 'X'
  FROM fa_books
  WHERE book_type_code = p_book
  AND   asset_id       = p_asset_id
  AND   period_counter_fully_reserved IS NOT NULL;

  l_dummy VARCHAR2(1);

  bug 3451539 end 1*/

  BEGIN

  /*  bug 3451539 start 2, no longer required
  OPEN c_fully_reserved(p_book,
                       p_asset_id);
  FETCH c_fully_reserved
  INTO  l_dummy;

  IF  c_fully_reserved%FOUND THEN

   SELECT adjusted_cost
   INTO   l_adjusted_cost
   FROM igi_iac_asset_balances
   WHERE book_type_code = p_book
   AND   asset_id       = p_asset_id
   AND period_counter   = (SELECT MAX(period_counter)
                          FROM igi_iac_asset_balances
                          WHERE book_type_code = p_book
                          AND   asset_id       = p_asset_id);

  CLOSE c_fully_reserved;

  ELSE

  SELECT adjusted_cost
  INTO   l_adjusted_cost
  FROM   igi_iac_asset_balances
  WHERE  book_type_code = p_book
  AND    asset_id = p_asset_id
  AND    period_counter = p_period_counter;


  CLOSE c_fully_reserved;

  END IF;
  bug 3451539 end 2 */

  -- bug 3451539, start 3
  -- This will bring the latest iac cost for any type
  -- of asset - depreciating, non depreciating or fully
  -- reserved

   SELECT adjusted_cost
   INTO   l_adjusted_cost
   FROM igi_iac_asset_balances
   WHERE book_type_code = p_book
   AND   asset_id       = p_asset_id
   AND period_counter   = (SELECT MAX(period_counter)
                          FROM igi_iac_asset_balances
                          WHERE book_type_code = p_book
                          AND   asset_id       = p_asset_id);

  -- bug 3451539, end 3

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     l_adjusted_cost :=0;

  WHEN OTHERS

   THEN null;
END;

  PROCEDURE insert_exceptions(p_revaluation_id IN igi_iac_revaluations.revaluation_id%TYPE,
                              p_asset_id       IN igi_iac_reval_asset_rules.asset_id%TYPE,
                              p_category_id    IN igi_iac_reval_categories.category_id%TYPE,
                              p_book_type_code IN igi_iac_revaluations.book_type_code%TYPE,
                              p_exception_type IN VARCHAR2
                             )

  IS
    l_user_id NUMBER;
   /*changed the hardcoded message to seeded*/
   /*for bug no 2647561 by shsaxena*/
    l_str     VARCHAR(2000);
  BEGIN
    -- enable the exception handler to log negative assets as well
    IF (p_exception_type = 'PERIOD_INDEX') THEN
        l_user_id := fnd_global.user_id;
        fnd_message.set_name('IGI','IGI_IAC_INVALID_PRICE_INDEX');
	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'insert_exceptions',FALSE);
        l_str:=fnd_message.get;
	fnd_file.put_line(FND_FILE.LOG,l_str);
    ELSIF (p_exception_type = 'NEGATIVE_ASSET') THEN
        l_user_id := fnd_global.user_id;
         fnd_message.set_name('IGI','IGI_IAC_NEGATIVE_ASSETS');
	 igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'insert_exceptions',FALSE);
         l_str:=fnd_message.get;
	fnd_file.put_line(FND_FILE.LOG,l_str);
    END IF;

    INSERT INTO igi_iac_exceptions (revaluation_id,
                                    asset_id,
                                    category_id,
                                    book_type_code,
                                    exception_message,
                                    created_by,
                                    creation_date,
                                    last_Update_date,
                                    last_updated_by)
                             SELECT p_revaluation_id,
                                    p_asset_id,
                                    p_category_id,
                                    p_book_type_code,
                                    l_str,
                                    l_user_id,
                                    sysdate,
                                    sysdate,
                                    l_user_id
                             FROM sys.dual
    WHERE  NOT EXISTS(SELECT 'X'
                     FROM igi_iac_exceptions
                     WHERE revaluation_id = p_revaluation_id
                     AND   book_type_code = p_book_type_code
                     AND   category_id    = p_category_id
                     AND   asset_id       = p_asset_id);

  EXCEPTION
    WHEN OTHERS THEN
     NULL;
  END;

--- Start of Create Assets Procedure

 PROCEDURE get_assets( errbuf            OUT NOCOPY VARCHAR2
                      , retcode           OUT NOCOPY NUMBER
                      , p_revaluation_id    IN NUMBER
                      , p_book_type_code    IN VARCHAR2
                      , p_revaluation_date  IN DATE
                      )
 IS

  l_reval_period_counter       NUMBER;
  l_reval_factor               igi_iac_reval_asset_rules.revaluation_factor%TYPE:= 1;
  l_user_id                    NUMBER ;
  l_login_id                   NUMBER := fnd_global.login_id;
  l_reval_period_name          VARCHAR(100);
  l_lastest_closed_per_name    VARCHAR2(300);
  l_reval_price_inxed_value    NUMBER;
  l_last_closed_index_value    NUMBER;
  l_quiet                      BOOLEAN;
  l_period_counter             NUMBER;
  l_get_open_period            igi_iac_types.prd_rec;
  l_get_reval_period           igi_iac_types.prd_rec;
  l_book                       igi_iac_revaluations.book_type_code%TYPE;
  l_get_record_from_date       igi_iac_types.prd_rec;
  l_get_counter_from_date      NUMBER;
  l_date_placed_in_service     DATE;
  l_get_closed_period          igi_iac_types.prd_rec;
  l_line varchar2(300);
  l_new_cost                   igi_iac_reval_asset_rules.new_cost%TYPE;
  l_current_cost               igi_iac_reval_asset_rules.new_cost%TYPE;
  l_cost                       BOOLEAN;
  l_adjusted_cost              NUMBER;

  TYPE asset_id_tbl_type IS TABLE OF FA_ADDITIONS.ASSET_ID%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE cost_tbl_type IS TABLE OF FA_BOOKS.COST%TYPE
    INDEX BY BINARY_INTEGER;

  l_asset_id			asset_id_tbl_type;
  l_cost_tbl			cost_tbl_type;
  l_loop_count			number;
  l_commit_cnt			number := 0;

  CURSOR c_get_categories IS
  SELECT rc.category_id,
         DECODE(cb.allow_indexed_reval_flag,'Y','O',
         DECODE(cb.allow_prof_reval_flag,'Y','P')) reval_type,
         NVL(cb.allow_indexed_reval_flag, 'N')allow_indexed_reval_flag,
         NVL(cb.allow_prof_reval_flag, 'N')allow_prof_reval_flag,
         rc.revaluation_id
  FROM igi_iac_reval_categories rc, igi_iac_category_books cb
  WHERE rc.category_id = cb.category_id
  AND   rc.book_type_code = cb.book_type_code
  AND   rc.book_type_code = p_book_type_code
  AND   rc.revaluation_id = p_revaluation_id
  AND   rc.select_category ='Y'
  AND  ( NVL(cb.allow_indexed_reval_flag,'N') = 'Y'
  OR    NVL(cb.allow_prof_reval_flag, 'N')='Y');

  CURSOR c_get_assets(p_cat_id         IN fa_additions.asset_category_id%TYPE,
                      p_period_counter IN NUMBER,
                      p_revaluation_id IN igi_iac_revaluations.revaluation_id%TYPE,
                      p_allow_indexed  IN igi_iac_category_books.allow_indexed_reval_flag%TYPE,
                      p_allow_prof     IN igi_iac_category_books.allow_prof_reval_flag%TYPE
                      ) IS
  SELECT a.asset_id,
         b.cost
  FROM fa_additions a,
       fa_books b
  WHERE a.asset_id = b.asset_id
  AND   b.book_type_code = p_book_type_code
  AND   a.asset_category_id = p_cat_id
  AND   a.asset_type <> 'CIP' -- bug 3416315
  AND   b.transaction_header_id_out IS NULL
  AND   b.date_placed_in_service <= p_revaluation_date
  AND   NOT EXISTS(SELECT 'X'
                   FROM igi_iac_revaluation_rates rr,
                        igi_iac_revaluations r
                   WHERE r.revaluation_id = rr.revaluation_id
                   AND   rr.asset_id      = a.asset_id
                   AND   r.book_type_code  = rr.book_type_code
                   AND   r.book_type_code = p_book_type_code
                   AND   r.status IN ('PREVIEWED','COMPLETED','UPDATED','FAILED_RUN')
                   AND   rr.period_counter = p_period_counter
                   AND   rr.reval_type = 'O'
                   AND   p_allow_indexed = 'Y'
                   AND   p_allow_prof = 'N')
  AND   NOT EXISTS(SELECT 'X'
                   FROM  igi_iac_reval_asset_rules ar
                   WHERE a.asset_id = ar.asset_id
                   AND   ar. revaluation_id = p_revaluation_id)
  AND  NOT EXISTS(SELECT 'X'
                  FROM   fa_transaction_headers t,
                         fa_retirements r
                  WHERE  t.book_type_code = b.book_type_code
                  AND    t.asset_id = a.asset_id
                  AND    t.transaction_header_id = r.transaction_header_id_in
                  AND    r.transaction_header_id_out IS NULL
                  AND    t.transaction_type_code =  'FULL RETIREMENT'
                  );

  CURSOR c_get_last_reval_period_count(p_asset_id IN igi_iac_revaluation_rates.asset_id%TYPE) IS
  SELECT period_counter
  FROM   igi_iac_revaluation_rates
  WHERE  asset_id = p_asset_id
  AND    latest_record = 'Y'
  AND    book_type_code = p_book_type_code;

  CURSOR c_get_date_place_in_service(p_asset_id IN fa_books.asset_id%TYPE) IS
  SELECT date_placed_in_service
  FROM   fa_books
  WHERE  asset_id = p_asset_id
  AND    book_type_code = p_book_type_code
  AND    date_ineffective IS NULL;

  BEGIN

  l_user_id := fnd_global.user_id;

    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','starting get assets');
  -- get the period counter from the :books.revaluation_date
  IF igi_iac_common_utils.get_period_info_for_date(p_book_type_code,
                                                   p_revaluation_date,
                                                   l_get_record_from_date) THEN

     l_get_counter_from_date:=l_get_record_from_date.period_counter;

     igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','got period counter');
  END IF;

    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','got period counter');
    FOR r_get_categories IN c_get_categories
    LOOP
        OPEN c_get_assets(r_get_categories.category_id,
                          l_get_counter_from_date,
                          r_get_categories.revaluation_id,
                          r_get_categories.allow_indexed_reval_flag,
                          r_get_categories.allow_prof_reval_flag);
        FETCH c_get_assets BULK COLLECT INTO
              l_asset_id, l_cost_tbl;

        CLOSE c_get_assets;

        FOR l_loop_count IN 1..l_asset_id.count
        LOOP
            -- check if the asset is a negative asset, if it is then
            -- log it into the exceptions table and do not process it
           IF (l_cost_tbl(l_loop_count) < 0) THEN
                  insert_exceptions(p_revaluation_id,
                                    l_asset_id(l_loop_count),
                                    r_get_categories.category_id,
                                    p_book_type_code,
                                    'NEGATIVE_ASSET'
                                    );
		igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','insert_exceptions called');
           ELSE
               -- if revaluation type = 'O' (Indexed) then calculate the reval_rate
               IF r_get_categories.reval_type = 'O' THEN
		 igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','reval type is O');
                   -- first get the period counter for the last revaluation on this asset
                   OPEN   c_get_last_reval_period_count(l_asset_id(l_loop_count));
                   FETCH  c_get_last_reval_period_count
                   INTO   l_reval_period_counter;
                   IF     c_get_last_reval_period_count%FOUND THEN
                       CLOSE  c_get_last_reval_period_count;
                       -- then get the period_name using get_period_for_counter
                       IF IGI_IAC_COMMON_UTILS.Get_Period_Info_For_Counter(p_book_type_code,
                                                                           l_reval_period_counter,
                                                                           l_get_reval_period) THEN
				igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets',
					'asset getting price index for last reval period');
                          l_reval_period_name := l_get_reval_period.period_name;
                          -- then get the price index using get_price_index_value
                          IF IGI_IAC_COMMON_UTILS.Get_Price_Index_Value(p_book_type_code,
                                                                        l_asset_id(l_loop_count),
                                                                        l_reval_period_name,
                                                                        l_reval_price_inxed_value)
                             THEN null;
                          END IF;
                       END IF;
                   ELSE  -- no revaluation on this asset, so get the date placed in service
		       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','no revaluation,
		       		so get date placed in service');
                       CLOSE  c_get_last_reval_period_count;
                       OPEN   c_get_date_place_in_service(l_asset_id(l_loop_count));
                       FETCH  c_get_date_place_in_service
                       INTO   l_date_placed_in_service;
                       IF     c_get_date_place_in_service%FOUND THEN
                           CLOSE  c_get_date_place_in_service;
                           -- get the period_name using get_period_for_date
                           IF IGI_IAC_COMMON_UTILS.Get_Period_Info_For_Date(p_book_type_code,
                                                                            l_date_placed_in_service,
                                                                            l_get_reval_period) THEN
                              l_reval_period_name := l_get_reval_period.period_name;
                              -- then get the price index using get_price_index_value
				igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','get index for date placed
					in service');
                              IF IGI_IAC_COMMON_UTILS.Get_Price_Index_Value(p_book_type_code,
                                                                            l_asset_id(l_loop_count),
                                                                            l_reval_period_name,
                                                                            l_reval_price_inxed_value)
                                  THEN null;
                              END IF;
                           END IF;
                       ELSE
                           CLOSE  c_get_date_place_in_service;
                       END IF; --fetch c_get_date_placed_in_service
                    END IF; -- fetch c_get_laset_reval_period_count
                    -- now get the latest closed period number
                    -- first get the open period
		      igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','get last closed period');
                    IF IGI_IAC_COMMON_UTILS.Get_Open_Period_Info(p_book_type_code,
                                                                 l_get_open_period)THEN
                        null;
                    END IF;
                    -- Then get the period_name for the closed period
                    IF IGI_IAC_COMMON_UTILS.Get_Period_Info_For_Counter(p_book_type_code,
                                                                        l_get_open_period.period_counter-1,
                                                                        l_get_closed_period) THEN
                        l_lastest_closed_per_name:=l_get_closed_period.period_name;
                    END IF;
		    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','get price index for last closed period');
                    -- then get the proce index for the latest closed period using coomon utils
                    IF IGI_IAC_COMMON_UTILS.Get_Price_Index_Value(p_book_type_code,
                                                                  l_asset_id(l_loop_count),
                                                                  l_lastest_closed_per_name,
                                                                  l_last_closed_index_value) THEN
                       -- calculate the reval_rate by dividing the last_closed_index_value
                       -- by the l_reval_price_inxed_value
                       l_reval_factor := (l_last_closed_index_value/l_reval_price_inxed_value);
                    END IF;
                    -- Now get the adjusted cost
                    get_adjusted_cost(l_asset_id(l_loop_count),
                                      l_get_counter_from_date,
                                      p_book_type_code,
                                      l_adjusted_cost);
                    -- Now calculate the current cost
                    l_current_cost:=l_cost_tbl(l_loop_count)+l_adjusted_cost;
                    -- Now calculate the new cost
		    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','calculate new cost');
                    l_new_cost:=((l_cost_tbl(l_loop_count)+l_adjusted_cost)*l_reval_factor);
		    do_round(l_new_cost,p_book_type_code);
                    -- Now round hte new cost
                    l_cost := igi_iac_common_utils.iac_round(l_new_cost,p_book_type_code) ;
               ELSE -- reval_type = 'P'
		   igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','getting adjusted cost for P asset');
                  get_adjusted_cost(l_asset_id(l_loop_count),
                                    l_get_counter_from_date,
                                    p_book_type_code,
                                    l_adjusted_cost);
                  -- Now calculate the current cost
                  l_current_cost:=l_cost_tbl(l_loop_count)+l_adjusted_cost;
		  igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','professional allowed only');
                  l_new_cost:=(l_cost_tbl(l_loop_count)+l_adjusted_cost);
               END IF;  --is r_get_categories.reval_type = 'O'
	       igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','checking if l_last_closed_index_value = 9999.99');
               IF l_last_closed_index_value = 9999.99 AND
                   r_get_categories.reval_type = 'O' THEN
		   igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','l_last_closed_index_value = 9999.99');
                   insert_exceptions(p_revaluation_id,
                                     l_asset_id(l_loop_count),
                                     r_get_categories.category_id,
                                     p_book_type_code,
                                     'PERIOD_INDEX'
                                    );
				    igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','insert_exceptions called');
               ELSE -- l_last_closed_index_value not equal to 9999.99
                   -- insert into igi_iac_reval_asset_rules
		   igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','inserting into igi_iac_reval_asset_rules');
                   IF (r_get_categories.reval_type = 'P' )                   OR
                        (r_get_categories.allow_prof_reval_flag = 'N'       AND
                         r_get_categories.allow_indexed_reval_flag = 'Y'    AND
                         l_reval_factor<>1)                                 OR
                      (r_get_categories.allow_prof_reval_flag = 'Y'         AND
                       r_get_categories.allow_indexed_reval_flag = 'Y')THEN

                       INSERT INTO igi_iac_reval_asset_rules
                                         (REVALUATION_ID,
                                          BOOK_TYPE_CODE,
                                          CATEGORY_ID,
                                          ASSET_ID,
                                          REVALUATION_FACTOR,
                                          REVALUATION_TYPE,
                                          NEW_COST,
                                          CURRENT_COST,
                                          SELECTED_FOR_REVAL_FLAG,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY)
                                   VALUES(p_revaluation_id,
                                          p_book_type_code,
                                          r_get_categories.category_id,
                                          l_asset_id(l_loop_count),
                                          l_reval_factor,
                                          r_get_categories.reval_type,
                                          l_new_cost,
                                          l_current_cost,
                                          'Y',
                                          l_user_id,
                                          sysdate,
                                          sysdate,
                                          l_user_id);

		      igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'get_assets','end of insert for this asset');
                    END IF;  -- insert asset
               END IF; -- last closed index 9999.99
               l_commit_cnt := l_commit_cnt + 1;
               IF l_commit_cnt=1000 THEN
                  commit;
                  l_commit_cnt := 0;
               END IF;
           END IF; -- negative assets
        END LOOP;
      END LOOP;

   errbuf := 'Normal completion';
   retcode := 0;

  commit;
EXCEPTION WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := 2;
      igi_iac_debug_pkg.debug_unexpected_msg(g_path||'get_assets');
END  get_assets;
END; -- package

/
