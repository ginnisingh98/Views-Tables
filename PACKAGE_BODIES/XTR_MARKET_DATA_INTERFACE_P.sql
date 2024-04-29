--------------------------------------------------------
--  DDL for Package Body XTR_MARKET_DATA_INTERFACE_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MARKET_DATA_INTERFACE_P" AS
/*  $Header: xtrmdtrb.pls 120.8.12010000.2 2010/01/28 11:26:47 nipant ship $	*/
--------------------------------------------------------------------------------------------------------------------

/* archive_rates
 This procedure updates the history table
parameters
p_called_from_trigger-is it called from the db trigger?
p_ask_price,p_bid_price- file quote of ask and bid, computed from what's in mdi
the rest - comes directly from mp
 */
PROCEDURE archive_rates(p_called_from_trigger	IN	BOOLEAN,
			p_ask_price		IN	NUMBER,
			p_bid_price		IN	NUMBER,
			p_currency_a		IN	VARCHAR2,
			p_currency_b		IN	VARCHAR2,
			p_nos_of_days		IN	NUMBER,
			p_ric_code		IN	VARCHAR2,
			p_term_length		IN	NUMBER,
			p_term_type		IN	VARCHAR2,
			p_term_year		IN	NUMBER,
--			p_last_download_time	IN	DATE) IS
			p_last_download_time	IN	DATE,
			p_day_count_basis	IN	VARCHAR2) IS
--
  v_hce               	NUMBER;
  v_old_base_hce_rate 	NUMBER;
  v_mid_usd_rate      	NUMBER;
  v_home_ccy          	VARCHAR2(15);
  v_basis             	VARCHAR2(1);
  v_rounding_factor   	NUMBER;
  v_usd_hce_rate      	NUMBER;
  v_row_exists		NUMBER;
--
  CURSOR home_ccy_cursor IS
    SELECT p.param_value, b.usd_quoted_spot, b.divide_or_multiply
    FROM xtr_pro_param p,
	xtr_master_currencies b
    WHERE p.param_name = 'SYSTEM_FUNCTIONAL_CCY'
    AND b.currency = p.param_value;
--
 CURSOR rnd_factor_cursor (p_currency VARCHAR2) IS
  SELECT rounding_factor
  FROM xtr_master_currencies_v
  WHERE currency = p_currency;
--
  CURSOR c_interest_date_stamp (p_currency VARCHAR2,
				p_ric_code VARCHAR2,
				p_rate_date DATE) IS
    SELECT 1
    FROM xtr_interest_period_rates
    WHERE currency = p_currency
    AND unique_period_id = p_ric_code
    AND rate_date = p_rate_date;
--
  CURSOR c_spot_date_stamp (p_currency VARCHAR2,
				p_rate_date DATE) IS
    SELECT 1
    FROM xtr_spot_rates
    WHERE currency = p_currency
    AND rate_date = p_rate_date;
--
BEGIN
  -- Check if No Spot Rates exist for this currency
  -- if not found ensure at least one row is inserted before the Archive Freq
  -- takes effect
  OPEN home_ccy_cursor;
  FETCH home_ccy_cursor INTO v_home_ccy,v_old_base_hce_rate,v_basis;
  CLOSE home_ccy_cursor;
  IF v_home_ccy ='USD' then
    v_old_base_hce_rate :=1;
  END IF;

    /* ======================= */
    /* 2. not in ('S','W','F') */
    /* ======================= */
    IF Nvl(p_term_type,'S') <>'S' then
       --
      OPEN c_interest_date_stamp(p_currency_a, p_ric_code,
						p_last_download_time);
      FETCH c_interest_date_stamp INTO v_row_exists;
      CLOSE c_interest_date_stamp;
      -- If date stamp already exists in table (v_row_exists = 1),
      --   do not insert, just update
      IF Nvl(v_row_exists,0)<>1 THEN
       INSERT INTO xtr_interest_period_rates
                (currency,contra_option_ccy,unique_period_id,period_code,rate_date,
                 bid_rate,spread,offer_rate,term_type,day_count_basis)
       VALUES
                (p_currency_a,p_currency_b,p_ric_code,p_nos_of_days,
		 p_last_download_time,p_bid_price,p_ask_price - p_bid_price,
		 p_ask_price,p_term_type,p_day_count_basis);
      ELSE
	UPDATE xtr_interest_period_rates
	SET contra_option_ccy = p_currency_b,
		period_code = p_nos_of_days,
                bid_rate = p_bid_price,
		spread = p_ask_price - p_bid_price,
		offer_rate = p_ask_price,
		term_type = p_term_type,
		day_count_basis = p_day_count_basis
	WHERE currency = p_currency_a
	AND unique_period_id = p_ric_code
	AND rate_date = p_last_download_time;
      END IF;
       --
       /* -- table not currently used
       UPDATE xtr_yield_curve_details
       SET    bid_price = p_bid_price,
              ask_price = p_ask_price,
              movement_indicator = p_movement_indicator,
              rate_date = p_last_download_time
       WHERE  currency = p_currency_a
       AND    term_type = p_term_type
       AND    term_length = p_term_length
       AND    Nvl(term_year,1111) = Nvl(p_term_year,1111);
       */
       --
    ELSIF Nvl(p_term_type,'^') = 'S'  then
       /* ==================== */
       /* 3. Update Spot Rates */
       /* ==================== */
       IF Nvl(p_currency_a,'$#$')='USD' OR Nvl(p_currency_b,'$#$')='USD' then
          IF Nvl(p_currency_a,'$#$') <>'USD' then
             -- Put the Rate in USD terms by first inversing
             v_mid_usd_rate := (1 / ((p_bid_price + p_ask_price) / 2)); /* bug#2366624, rravunny */
          ELSE
             -- The Rate is in USD terms
             v_mid_usd_rate := ((p_bid_price + p_ask_price) / 2); /* bug#2366624, rravunny */
          END IF;
          --
          IF Nvl(p_currency_a,'$#$') <> 'USD'  then
             -- Currency A <> 'USD' ie AUD/USD, GBP/USD
             IF (v_home_ccy <> p_currency_a AND v_home_ccy <> p_currency_b) OR v_home_ccy='USD'  then  --- add OR
               --
               IF p_called_from_trigger THEN
                OPEN rnd_factor_cursor(p_currency_a);
                FETCH rnd_factor_cursor INTO v_rounding_factor;
                CLOSE rnd_factor_cursor;
                UPDATE xtr_master_currencies
                SET    current_spot_rate = (p_bid_price + p_ask_price) / 2,
                       hce_rate = (v_mid_usd_rate / v_old_base_hce_rate),
                       usd_quoted_spot = Decode(currency,'USD',1,(v_mid_usd_rate)), /* bug#2366624, rravunny */
                       spot_date = p_last_download_time,
                       rate_date = p_last_download_time
                WHERE  currency = p_currency_a;
               END IF;
               --
               v_hce :=  (v_mid_usd_rate / v_old_base_hce_rate); /* bug#2366624, rravunny */
             ELSE
               v_hce := 1;
             END IF;
             --
	     OPEN c_spot_date_stamp(p_currency_a, p_last_download_time);
	     FETCH c_spot_date_stamp INTO v_row_exists;
	     CLOSE c_spot_date_stamp;
             -- If date stamp already exists in table (v_row_exists = 1),
             --   do not insert, just update
             IF Nvl(v_row_exists,0)<>1 THEN
               INSERT INTO xtr_spot_rates
                   (currency,rate_date,bid_rate_against_usd,
                    spread_against_usd,offer_rate_against_usd,
                    usd_base_curr_bid_rate,usd_base_curr_offer_rate,
                    hce_rate,unique_period_id)
               VALUES
                   (p_currency_a,p_last_download_time,p_bid_price,
                    p_ask_price-p_bid_price,p_ask_price,
                    1/p_ask_price,1/p_bid_price,
                    v_hce,p_ric_code);
             ELSE
	       UPDATE xtr_spot_rates
		 SET bid_rate_against_usd = p_bid_price,
                    spread_against_usd = p_ask_price-p_bid_price,
		    offer_rate_against_usd = p_ask_price,
                    usd_base_curr_bid_rate = 1/p_ask_price,
		    usd_base_curr_offer_rate = 1/p_bid_price,
                    hce_rate = v_hce,
		    unique_period_id = p_ric_code
	       WHERE currency = p_currency_a
	       AND rate_date = p_last_download_time;
	     END IF;
	     --
          ELSE
             -- Currency A = 'USD' eg USD/DEM, USD/JPY etc
             IF (v_home_ccy <> p_currency_a AND v_home_ccy <> p_currency_b) OR v_home_ccy='USD' then
               --
               IF p_called_from_trigger THEN
                OPEN rnd_factor_cursor(p_currency_b);
                FETCH rnd_factor_cursor INTO v_rounding_factor;
                CLOSE rnd_factor_cursor;
                UPDATE xtr_master_currencies
                SET    current_spot_rate = (p_bid_price + p_ask_price) / 2,
                       hce_rate = (v_mid_usd_rate / v_old_base_hce_rate),
                       usd_quoted_spot = Decode(currency,'USD',1,(v_mid_usd_rate)), /* bug#2366624, rravunny */
                       spot_date = p_last_download_time,
                       rate_date = p_last_download_time
                WHERE currency = p_currency_b;
               END IF;
               --
               v_hce :=  (v_mid_usd_rate / v_old_base_hce_rate); /* bug#2366624, rravunny */
             ELSE
               v_hce := 1;
             END IF;
             --
	     OPEN c_spot_date_stamp(p_currency_b, p_last_download_time);
	     FETCH c_spot_date_stamp INTO v_row_exists;
	     CLOSE c_spot_date_stamp;
             -- If date stamp already exists in table (v_row_exists = 1),
             --   do not insert, just update
             IF Nvl(v_row_exists,0)<>1 THEN
	       INSERT INTO xtr_spot_rates
                    (currency,rate_date,bid_rate_against_usd,
                     spread_against_usd,offer_rate_against_usd,
                     usd_base_curr_bid_rate,usd_base_curr_offer_rate,
                     hce_rate,unique_period_id)
               VALUES
                   (p_currency_b,p_last_download_time,p_bid_price,
                    p_ask_price - p_bid_price,
                    p_ask_price,p_bid_price,p_ask_price,
                    v_hce,p_ric_code);
             ELSE
	       UPDATE xtr_spot_rates
		 SET bid_rate_against_usd = p_bid_price,
                    spread_against_usd = p_ask_price - p_bid_price,
		    offer_rate_against_usd = p_ask_price,
                    usd_base_curr_bid_rate = p_bid_price,
		    usd_base_curr_offer_rate = p_ask_price,
                    hce_rate = v_hce,
		    unique_period_id = p_ric_code
	       WHERE currency = p_currency_b
	       AND rate_date = p_last_download_time;
	     END IF;
	     --
          END IF;
          /* =================================================== */
          /* 4. Compare home_ccy with currency_A and currrency_B */
          /* =================================================== */
          IF v_home_ccy = p_currency_a OR v_home_ccy = p_currency_b  then
             -- ie updating home currency where currency = 'USD'
             -- note the following if statement (using basis for home ccy) is to ensure
             -- that the hce for usd is quoted in the home ccy basis.
             IF v_basis = '*' then
                v_usd_hce_rate := ((p_bid_price + p_ask_price) / 2); /* bug#2366624, rravunny */
             ELSE
                -- need to put hce rate back in home ccy terms for the usd
                v_usd_hce_rate := (1 / ((p_bid_price + p_ask_price)/2)); /* bug#2366624, rravunny */
             END IF;
             --
             IF p_called_from_trigger THEN
              UPDATE xtr_master_currencies
              SET    current_spot_rate = 1,
                    hce_rate = Decode(v_home_ccy,'USD',1,v_usd_hce_rate),
                    usd_quoted_spot = 1,
                    spot_date = p_last_download_time,
                    rate_date = p_last_download_time
              WHERE  currency = 'USD';
             END IF;
             --
             /* ====== */
             /* 5. Add */
             /* ====== */
             IF v_home_ccy <>'USD' then
               --
               IF p_called_from_trigger THEN
                UPDATE xtr_master_currencies
                SET    current_spot_rate = ((p_bid_price + p_ask_price) / 2), /* bug#2366624, rravunny */
                       usd_quoted_spot = (v_mid_usd_rate), /* bug#2366624, rravunny */
                       hce_rate = 1,
                       spot_date = p_last_download_time,
                       rate_date = p_last_download_time
                WHERE  currency = v_home_ccy;
                -- ie updating home currency therefore ALL hce rates need updating for each currency
                UPDATE xtr_master_currencies_v a
                SET    hce_rate = (usd_quoted_spot / v_mid_usd_rate),
                        spot_date = p_last_download_time,
                        rate_date = p_last_download_time
                WHERE   currency <> v_home_ccy
                AND     currency <> 'USD'
                AND     usd_quoted_spot IS NOT NULL;
               END IF;
               --
                -- Insert USD 'DUMMY' Row ie this is used by USD deals to enable them to pick
                -- the HCE RATE.
	       OPEN c_spot_date_stamp('USD', p_last_download_time);
	       FETCH c_spot_date_stamp INTO v_row_exists;
	       CLOSE c_spot_date_stamp;
               -- If date stamp already exists in table (v_row_exists = 1),
               --   do not insert, just update
               IF Nvl(v_row_exists,0)<>1 THEN
                 INSERT INTO xtr_spot_rates
                  (currency,rate_date,bid_rate_against_usd,spread_against_usd,
                   offer_rate_against_usd,usd_base_curr_bid_rate,
		   usd_base_curr_offer_rate,hce_rate,unique_period_id)
                 VALUES
                  ('USD',p_last_download_time,1,0,1,1,1,
			v_usd_hce_rate,'USD REF ROW');
               ELSE
	         UPDATE xtr_spot_rates
		 SET bid_rate_against_usd = 1,
                    spread_against_usd = 0,
		    offer_rate_against_usd = 1,
                    usd_base_curr_bid_rate = 1,
		    usd_base_curr_offer_rate = 1,
                    hce_rate = v_usd_hce_rate,
		    unique_period_id = 'USD REF ROW'
	         WHERE currency = 'USD'
	         AND rate_date = p_last_download_time;
	       END IF;
	       --
             END IF; /* 5 */
          END IF;    /* 4 */
       END IF;       /* 3 */
    END IF;          /* 2 */
END archive_rates;



/* transfer_mp
 This procedure does the actual transfer from mdi to mp
parameters
p_ref- the reference number from xtr_data_feed_codes based on the source and external ref code of mdi
p_ask,p_bid- file quote of ask and bid, computed from what's in mdi
p_rowid- the rowid of the mdi record we are dealing with currently
 */

PROCEDURE transfer_mp(p_ref IN NUMBER,p_ask IN NUMBER, p_bid IN NUMBER,
                      p_rowid IN ROWID ) IS
--
v_now DATE;
--
BEGIN
  SELECT NVL(datetime,SYSDATE)INTO v_now FROM xtr_market_data_interface where
    rowid=p_rowid;
  IF v_now > sysdate THEN
    v_now := sysdate;
  END IF;
  UPDATE XTR_MARKET_PRICES
    SET ASK_PRICE= p_ask, BID_PRICE= p_bid,LAST_DOWNLOAD_TIME=v_now
            WHERE XTR_MARKET_PRICES.REF_NUMBER = p_ref;
  UPDATE XTR_MARKET_DATA_INTERFACE
    SET LAST_UPDATED_BY = FND_GLOBAL.user_id, LAST_UPDATED_DATE= sysdate
          WHERE XTR_MARKET_DATA_INTERFACE.ROWID = p_rowid;
END transfer_mp;



/* calc_ask_bid
 This procedure calculates the correct ask and bid values based on ask, bid, mid, and spread that are alredy stored in mdi
parameters
p_ref- the reference number from xtr_data_feed_codes based on the source and external ref code of mdi
p_ask,p_bid,p_mid,p_spread- file quote of ask, bid,mid, and spread that's in mdi
p_code- code scheme that lets you know which values are missing based on its code
 */
PROCEDURE calc_ask_bid(p_ref IN NUMBER, p_ask IN OUT NOCOPY NUMBER,
                       p_bid IN OUT NOCOPY NUMBER,p_mid IN NUMBER, p_spread IN NUMBER,                       p_code IN NUMBER) IS
--
v_pspread NUMBER;
--
BEGIN
/* v_code scheme
   1 is added to v_code if ask is missing
   2 is added to v_code if bid is missing
   4 is added to v_code if mid is missing
   8 is added to v_code if spread is missing
   the combinations of those codes will enable to programmer to uniquely identify which items are missing */
  IF (p_code <> 0) AND (p_code<> 4) AND (p_code<> 8) AND  (p_code<> 12) THEN
-- if ask or bid are missing
    IF (p_code = 1) THEN -- just ask missing
      p_ask:=2*p_mid-p_bid;
    ELSIF (p_code = 2) THEN -- just bid missing
      p_bid:= 2*p_mid-p_ask;
    ELSIF (p_code = 3) THEN -- ask and bid missing
      p_ask:= (2*p_mid+p_spread)/2;
      p_bid:= (2*p_mid-p_spread)/2;
    ELSIF (p_code = 5) THEN -- mid and ask missing
      p_ask:=p_bid+p_spread;
    ELSIF (p_code = 6) THEN--bid and mid missing
      p_bid:= p_ask-p_spread;
    ELSIF (p_code = 9) THEN -- ask and spread missing
      p_ask:=2*p_mid-p_bid;
    ELSIF (p_code = 10) THEN -- bid and spread missing
      p_bid:= 2*p_mid-p_ask;
    ELSIF (p_code = 11) THEN -- ask, bid, and spread missing
      SELECT NVL(ASK_PRICE-BID_PRICE,0) INTO v_pspread
      FROM XTR_MARKET_PRICES WHERE REF_NUMBER= p_ref;
      p_ask:= (2*p_mid+v_pspread)/2;
      p_bid:= (2*p_mid-v_pspread)/2;
    ELSIF (p_code = 13) THEN-- ask, mid, and spread missing
      SELECT NVL(ASK_PRICE-BID_PRICE,0) INTO v_pspread
      FROM XTR_MARKET_PRICES WHERE REF_NUMBER= p_ref;
      p_ask:= p_bid+v_pspread;
    ELSIF (p_code = 14) THEN-- bid, mid, and spread missing
      SELECT NVL(ASK_PRICE-BID_PRICE,0) INTO v_pspread
      FROM XTR_MARKET_PRICES WHERE REF_NUMBER= p_ref;
      p_bid:=p_ask-v_pspread;
    END IF;
  END IF;
END calc_ask_bid;



/* q_quote_compare
 This function compares file quote computed from mdi and system quote that's
already in mp. It returns true if they are not equal and returns true if they
are equal. It was created so that sql statements could be used inside of if
structure. It first computes file quote based on data in mdi
parameters
p_source,p_external_ref_code- souce and ext_ref_code of what's in mdi. These combined enables you to find unique row in data feed codes
p_ask,p_bid,p_mid,p_spread- file quote of ask,bid,mid, and spread that's in mdi
p_code-used to call calc_ask_bid proc
 */
FUNCTION q_quote_compare(p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2,p_ask IN OUT NOCOPY NUMBER,
  p_bid IN OUT NOCOPY NUMBER,p_mid IN NUMBER, p_spread IN NUMBER, p_code IN NUMBER)
  RETURN BOOLEAN IS
--
  v_fask NUMBER;
  v_fbid NUMBER;-- temporary storage for ask and bid
  v_fref NUMBER;
--
BEGIN
  SELECT REF_NUMBER INTO v_fref FROM XTR_DATA_FEED_CODES
  WHERE SOURCE = p_source AND EXTERNAL_REF_CODE = p_external_ref_code;
  SELECT ASK_PRICE INTO v_fask FROM XTR_MARKET_PRICES
  WHERE REF_NUMBER = v_fref;
  SELECT BID_PRICE INTO v_fbid FROM XTR_MARKET_PRICES
  WHERE REF_NUMBER = v_fref;
  calc_ask_bid(v_fref,p_ask,p_bid,p_mid,p_spread,p_code);
  IF (v_fask<>  p_ask) OR (v_fbid<> p_bid) OR (v_fask IS NULL) OR
  (v_fbid IS NULL)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END q_quote_compare;



/* q_code_check
 This function checks if mdi.source and mdi.external_ref_code not found in data feed codes or corresponding ric code not found in mp
returns true if not found. returns false if found
parameters
p_source, p_external_ref_code-source and ext ref code in mdi
 */
FUNCTION q_code_check(p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2) RETURN BOOLEAN IS
--
 CURSOR c1_cursor IS
  SELECT REF_NUMBER  FROM XTR_DATA_FEED_CODES
  WHERE SOURCE = p_source AND EXTERNAL_REF_CODE = p_external_ref_code;
 CURSOR c2_cursor IS
    SELECT RIC_CODE  FROM XTR_MARKET_PRICES
    WHERE REF_NUMBER = ( SELECT REF_NUMBER  FROM XTR_DATA_FEED_CODES
  WHERE SOURCE = p_source AND EXTERNAL_REF_CODE = p_external_ref_code);
  v_fref NUMBER;
  v_fric VARCHAR2(20);
--
BEGIN
    OPEN c1_cursor;
    FETCH c1_cursor INTO v_fref;
  IF c1_cursor%NOTFOUND THEN
    CLOSE c1_cursor;
    RETURN TRUE;
  ELSE
    OPEN c2_cursor;
    FETCH c2_cursor INTO v_fric;
    IF c2_cursor%NOTFOUND THEN
      CLOSE c1_cursor;
      CLOSE c2_cursor;
      RETURN TRUE;
    ELSE
      CLOSE c1_cursor;
      CLOSE c2_cursor;
      RETURN FALSE;
    END IF;
  END IF;
END q_code_check;



/* q_date_check
 This function checks if mdi.datetime<mp.last_download_time
returns true if that is the case. returns false otherwise
parameters
p_date-datetime in mdi
 p_source, p_external_ref_code-source and ext ref code in mdi
 */
FUNCTION q_date_check(p_date IN DATE, p_source IN VARCHAR2,
  p_external_ref_code IN VARCHAR2) RETURN BOOLEAN IS
--
  v_fref NUMBER;
  v_date DATE;
--
BEGIN
  SELECT REF_NUMBER INTO v_fref FROM XTR_DATA_FEED_CODES
  WHERE SOURCE = p_source AND EXTERNAL_REF_CODE = p_external_ref_code;
  SELECT LAST_DOWNLOAD_TIME INTO v_date FROM XTR_MARKET_PRICES
  WHERE REF_NUMBER= v_fref;
  IF (p_date< v_date) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END q_date_check;



/*put_header
 This procedure puts the header(titles) for the log messages. It is invoked only if there are errors
 */
PROCEDURE put_header IS
--
  v_source_h VARCHAR2(100);
  v_ext_ref_h VARCHAR2(100);
  v_bid_h VARCHAR2(100);
  v_ask_h VARCHAR2(100);
  v_mid_h VARCHAR2(100);
  v_spread_h VARCHAR2(100);
  v_date_h VARCHAR2(100);
  v_trans_stat_h VARCHAR2(100);
--
BEGIN
  SELECT text INTO v_source_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_SOURCE';
  SELECT text INTO v_ext_ref_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME =
      'P_EXTERNAL_REF_CODE';
  SELECT text INTO v_bid_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_BID';
  SELECT text INTO v_ask_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_ASK';
  SELECT text INTO v_mid_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_MID';
  SELECT text INTO v_spread_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_SPREAD';
  SELECT text INTO v_date_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME = 'P_DATE';
  SELECT text INTO v_trans_stat_h FROM xtr_sys_languages_vl WHERE
    module_name='XTRMDTRP' AND canvas_type='TEXT' AND ITEM_NAME =
      'P_TRANSFER_STATUS';
  FND_FILE.PUT_LINE(FND_FILE.LOG,v_source_h ||', '||v_ext_ref_h||', '
    ||v_bid_h||', '||v_ask_h||', '||v_mid_h||', '||v_spread_h||', '
    ||v_date_h||', '||v_trans_stat_h);
END put_header;



/*market_data_transfer_cp
 This is a dummy procedure that simply calls market_data_transfer. It is called by the concurrent program
 */
PROCEDURE market_data_transfer_cp(
errbuf                  OUT NOCOPY    VARCHAR2,
retcode                 OUT NOCOPY    VARCHAR2,
p_upd_date_missing  IN VARCHAR2,
p_upd_history  IN VARCHAR2)
 IS
--
--
BEGIN
 market_data_transfer(p_upd_date_missing,p_upd_history);
END market_data_transfer_cp;



/* market_data_transfer
 *
 * transfers market data from the XTR_MARKET_DATA_INTERFACE table
 * to the current (or historic) rates table within Treasury.
 * For each record in the XTR_MARKET_DATA_INTERFACE table, this procedure
 * attempts to make the transfer and writes a return code back
 * on the interface table corresponding to the status of the transfer.
 * For successful transfers, the corresponding Reference Code is also
 * recorded on the interface table.
 *
 * The Return Code and Description are stored in FND_LOOKUPS where the
 * lookup_type = 'XTR_MDTSF_RTN_CODES'
 */
PROCEDURE market_data_transfer (p_upd_date_missing  IN VARCHAR2,
                               p_upd_history  IN VARCHAR2) IS
--
  CURSOR each_row_cursor IS
    SELECT rowid, source,external_ref_code,ask,bid,datetime,mid,spread,
    return_code,ref_code,created_by,creation_date,last_updated_by,
    last_updated_date,last_updated_login
    FROM XTR_MARKET_DATA_INTERFACE
      WHERE RETURN_CODE IS NULL;
  v_counter NUMBER DEFAULT 0;
  e_inv EXCEPTION;
-- invalid parameter exception
  v_ask NUMBER;
  v_bid NUMBER;
  v_ref NUMBER;
  v_ric VARCHAR2(20);
  v_currency_a VARCHAR2(15);
  v_currency_b VARCHAR2(15);
  v_nos_of_days NUMBER;
  v_term_length	NUMBER;
  v_term_type VARCHAR2(1);
  v_term_year NUMBER;
  v_code NUMBER ;
  v_day_count_basis XTR_INTEREST_PERIOD_RATES.DAY_COUNT_BASIS%TYPE;
/* v_code scheme
   1 is added to v_code if ask is missing
   2 is added to v_code if bid is missing
   4 is added to v_code if mid is missing
   8 is added to v_code if spread is missing
   the combinations of those codes will enable to programmer to uniquely identify which items are missing */
  v_trans_stat VARCHAR2(240);
  v_e_count NUMBER; --number of rows with errors

  --bug 2588763
  type currency_list_type is table of xtr_market_prices.currency_a%type index by binary_integer;
  v_currency_a_list currency_list_type;
  v_currency_b_list currency_list_type;

--
BEGIN
  IF NOT(((p_upd_date_missing = 'A') OR (p_upd_date_missing = 'N') OR
  (p_upd_date_missing = 'C')) AND ((p_upd_history = 'Y') OR
  (p_upd_history = 'N'))) THEN
    RAISE e_inv;
  END IF;
-- check parameter integrity
  LOCK TABLE XTR_MARKET_DATA_INTERFACE,XTR_MARKET_PRICES IN EXCLUSIVE MODE
  NOWAIT;

-- bug 2588763 - get list of all currencies that will be updated
  select distinct mp.currency_a
	bulk collect into v_currency_a_list
	from xtr_market_prices mp,
	     xtr_data_feed_codes dfc,
	     xtr_market_data_interface mdi
	where mp.ric_code=dfc.ric_code
	and   dfc.source = mdi.source
	and   dfc.external_ref_code = mdi.external_ref_code
	and   mp.term_type = 'S'
	and   mp.currency_a is not null
	and   mp.currency_a <> 'USD'
	and   nvl(mp.currency_b,'USD')='USD'
	and   mdi.return_code is null;

  select distinct mp.currency_b
	bulk collect into v_currency_b_list
	from xtr_market_prices mp,
	     xtr_data_feed_codes dfc,
	     xtr_market_data_interface mdi
	where mp.ric_code=dfc.ric_code
	and   dfc.source = mdi.source
	and   dfc.external_ref_code = mdi.external_ref_code
	and   mp.currency_b is not null
	and   mp.currency_b <> 'USD'
	and   nvl(mp.currency_a,'USD')='USD'
	and   not exists
	      (select i_mp.currency_b
	       from   xtr_market_prices i_mp,
	              xtr_data_feed_codes i_dfc,
	              xtr_market_data_interface i_mdi
	       where  i_mp.ric_code = i_dfc.ric_code
	       and    i_dfc.source = i_mdi.source
	       and    i_dfc.external_ref_code = i_mdi.external_ref_code
	       and    i_mp.term_type = 'S'
	       and    i_mp.currency_a = mp.currency_b
	       and    i_mdi.return_code is null)
	and   mdi.return_code is null;

 -- lock the tables
  v_counter := 0;
  v_e_count:= 0;
  FOR v_mdi_rec IN each_row_cursor LOOP
    v_code:=0;
    v_counter:=v_counter+1;
    IF (v_mdi_rec.ASK IS NOT NULL) THEN
      v_ask:=v_mdi_rec.ASK ;
    ELSE
      v_code:=v_code+1;
    END IF;
    IF (v_mdi_rec.BID IS NOT NULL) THEN
      v_bid:=v_mdi_rec.BID ;
    ELSE
      v_code:=v_code+2;
    END IF;
    IF (v_mdi_rec.MID IS NULL) THEN
      v_code:=v_code+4;
    END IF;
    IF (v_mdi_rec.SPREAD IS NULL) THEN
      v_code:=v_code+8;
    END IF;

    IF (v_mdi_rec.SOURCE IS NULL) OR (v_mdi_rec.EXTERNAL_REF_CODE IS NULL) OR
	    ((v_mdi_rec.ASK IS NULL) AND (v_mdi_rec.BID IS NULL) AND
	    (v_mdi_rec.MID IS NULL)) THEN
        --XTRMDT special logic fails
        UPDATE XTR_MARKET_DATA_INTERFACE
          SET RETURN_CODE = 90,LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATED_DATE= SYSDATE WHERE rowid =v_mdi_rec.rowid;

        --Print error to concurrent log
        v_e_count := v_e_count + 1;
        IF v_e_count = 1 THEN
          put_header;
        END IF;

        SELECT description INTO v_trans_stat FROM fnd_lookups WHERE
          lookup_type= 'XTR_MDTSF_RTN_CODES'AND lookup_code= '90';
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_mdi_rec.source||', '||
       v_mdi_rec.external_ref_code||', '||v_mdi_rec.bid||', '||v_mdi_rec.ask
       ||', '||v_mdi_rec.mid||', '||v_mdi_rec.spread||', '
        ||v_mdi_rec.datetime||', '||v_trans_stat||' [90]');

    ELSIF q_code_check(v_mdi_rec.source,v_mdi_rec.external_ref_code) THEN
       UPDATE XTR_MARKET_DATA_INTERFACE
          SET RETURN_CODE = 50 ,LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATED_DATE= SYSDATE WHERE ROWID = v_mdi_rec.rowid;
    --Print error to concurrent log
       v_e_count := v_e_count + 1;
       IF v_e_count = 1 THEN
         put_header;
       END IF;
       SELECT description INTO v_trans_stat FROM fnd_lookups WHERE
          lookup_type= 'XTR_MDTSF_RTN_CODES'AND lookup_code= '50';
       FND_FILE.PUT_LINE(FND_FILE.LOG,v_mdi_rec.source||', '||
       v_mdi_rec.external_ref_code||', '||v_mdi_rec.bid||', '||v_mdi_rec.ask
       ||', '||v_mdi_rec.mid||', '||v_mdi_rec.spread||', '
        ||v_mdi_rec.datetime||', '||v_trans_stat||' [50]');

    ELSIF v_mdi_rec.DATETIME IS NULL THEN
      IF (p_upd_date_missing = 'N') THEN
        -- UPD_DATE_MISSING = Never
        UPDATE XTR_MARKET_DATA_INTERFACE
          SET RETURN_CODE = 60,LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATED_DATE= SYSDATE WHERE ROWID = v_mdi_rec.rowid;
        --Print error to concurrent log
        v_e_count := v_e_count + 1;
        IF v_e_count = 1 THEN
          put_header;
        END IF;
        SELECT description INTO v_trans_stat FROM fnd_lookups WHERE
          lookup_type= 'XTR_MDTSF_RTN_CODES'AND lookup_code= '60';
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_mdi_rec.source||', '||
       v_mdi_rec.external_ref_code||', '||v_mdi_rec.bid||', '||v_mdi_rec.ask
       ||', '||v_mdi_rec.mid||', '||v_mdi_rec.spread||', '
        ||v_mdi_rec.datetime||', '||v_trans_stat||' [60]');

     ELSIF (p_upd_date_missing = 'A') OR (q_quote_compare(v_mdi_rec.source,
       v_mdi_rec.external_ref_code,v_ask,v_bid,v_mdi_rec.mid,v_mdi_rec.spread,
       v_code)) THEN
         --UPD_DATE_MISSING = Always OR File Quote <> System Quote
         SELECT REF_NUMBER INTO v_ref FROM XTR_DATA_FEED_CODES
         WHERE SOURCE = v_mdi_rec.source
         AND EXTERNAL_REF_CODE = v_mdi_rec.external_ref_code;
         SELECT RIC_CODE INTO v_ric FROM XTR_MARKET_PRICES
         WHERE REF_NUMBER = v_ref;
         calc_ask_bid(v_ref,v_ask,v_bid,v_mdi_rec.mid,v_mdi_rec.spread,v_code);

         --transfer to mp
         transfer_mp(v_ref, v_ask,  v_bid, v_mdi_rec.rowid);
         UPDATE XTR_MARKET_DATA_INTERFACE
           SET REF_CODE = v_ric, RETURN_CODE = 20,
           LAST_UPDATED_BY = FND_GLOBAL.user_id, LAST_UPDATED_DATE= SYSDATE
             WHERE ROWID = v_mdi_rec.rowid;
      ELSE
        UPDATE XTR_MARKET_DATA_INTERFACE
          SET RETURN_CODE = 70,LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATED_DATE= SYSDATE WHERE ROWID = v_mdi_rec.rowid;
    --Print error to concurrent log
        v_e_count := v_e_count + 1;
        IF v_e_count = 1 THEN
          put_header;
        END IF;
        SELECT description INTO v_trans_stat FROM fnd_lookups WHERE
          lookup_type= 'XTR_MDTSF_RTN_CODES'AND lookup_code= '70';
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_mdi_rec.source||', '||
       v_mdi_rec.external_ref_code||', '||v_mdi_rec.bid||', '||v_mdi_rec.ask
       ||', '||v_mdi_rec.mid||', '||v_mdi_rec.spread||', '
        ||v_mdi_rec.datetime||', '||v_trans_stat||' [70]');
      END IF;
    ELSIF(q_date_check(v_mdi_rec.DATETIME,v_mdi_rec.source,
				v_mdi_rec.external_ref_code)) THEN
      --IF (UPD_HISTORY = N)
      IF (p_upd_history = 'N') THEN
        UPDATE XTR_MARKET_DATA_INTERFACE
          SET RETURN_CODE = 80 ,LAST_UPDATED_BY = FND_GLOBAL.user_id,
           LAST_UPDATED_DATE= SYSDATE WHERE ROWID = v_mdi_rec.rowid;
    --Print error to concurrent log
        v_e_count := v_e_count + 1;
        IF v_e_count = 1 THEN
          put_header;
        END IF;
        SELECT description INTO v_trans_stat FROM fnd_lookups WHERE
          lookup_type= 'XTR_MDTSF_RTN_CODES'AND lookup_code= '80';
        FND_FILE.PUT_LINE(FND_FILE.LOG,v_mdi_rec.source||', '||
       v_mdi_rec.external_ref_code||', '||v_mdi_rec.bid||', '||v_mdi_rec.ask
       ||', '||v_mdi_rec.mid||', '||v_mdi_rec.spread||', '
        ||v_mdi_rec.datetime||', '||v_trans_stat||' [80]');
      ELSE
        SELECT REF_NUMBER INTO v_ref FROM XTR_DATA_FEED_CODES
          WHERE SOURCE = v_mdi_rec.source
          AND EXTERNAL_REF_CODE = v_mdi_rec.external_ref_code;
        SELECT RIC_CODE INTO v_ric FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        calc_ask_bid(v_ref,v_ask,v_bid,v_mdi_rec.mid,v_mdi_rec.spread,v_code);
/*
        SELECT CURRENCY_A INTO v_currency_a FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        SELECT CURRENCY_B INTO v_currency_b FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        SELECT NOS_OF_DAYS INTO v_nos_of_days FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        SELECT TERM_LENGTH INTO v_term_length FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        SELECT TERM_TYPE INTO v_term_type FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
        SELECT TERM_YEAR INTO v_term_year FROM XTR_MARKET_PRICES
          WHERE REF_NUMBER = v_ref;
*/
        SELECT currency_a, currency_b, nos_of_days, term_length, term_type,
               term_type, term_year, day_count_basis
          INTO v_currency_a, v_currency_b, v_nos_of_days, v_term_length,
               v_term_type, v_term_type, v_term_year, v_day_count_basis
          FROM xtr_market_prices
          WHERE ref_number = v_ref;

        --transfer to history table
        archive_rates(FALSE,v_ask,v_bid,v_currency_a,v_currency_b,
		v_nos_of_days,v_ric,v_term_length,v_term_type,v_term_year,
		v_mdi_rec.datetime,v_day_count_basis);
        UPDATE XTR_MARKET_DATA_INTERFACE
          SET REF_CODE = v_ric, RETURN_CODE= 40 ,
          LAST_UPDATED_BY = FND_GLOBAL.user_id, LAST_UPDATED_DATE= SYSDATE
          WHERE ROWID = v_mdi_rec.rowid;
      END IF;
    ELSE
      SELECT REF_NUMBER INTO v_ref FROM XTR_DATA_FEED_CODES
        WHERE SOURCE = v_mdi_rec.source
          AND EXTERNAL_REF_CODE = v_mdi_rec.external_ref_code;
      SELECT RIC_CODE INTO v_ric FROM XTR_MARKET_PRICES
        WHERE REF_NUMBER = v_ref;
      calc_ask_bid(v_ref,v_ask,v_bid,v_mdi_rec.mid,v_mdi_rec.spread,v_code);
     --transfer to mp
      transfer_mp( v_ref,v_ask,  v_bid,v_mdi_rec.rowid);
      UPDATE XTR_MARKET_DATA_INTERFACE
        SET REF_CODE = v_ric, RETURN_CODE = 10,
          LAST_UPDATED_BY = FND_GLOBAL.user_id, LAST_UPDATED_DATE= SYSDATE
          WHERE ROWID = v_mdi_rec.rowid;
    END IF;

    IF v_counter = 50 THEN
      COMMIT;
      v_counter:= 0;
      -- lock the tables again because it was released by commit statement
      LOCK TABLE XTR_MARKET_DATA_INTERFACE,XTR_MARKET_PRICES
	IN EXCLUSIVE MODE NOWAIT;
    END IF;
  END LOOP;

  COMMIT;

  -- bug 2588763, update cross rates
  for i in 1..v_currency_a_list.count loop
    XTR_fps2_P.calc_cross_rate(v_currency_a_list(i),null);
  end loop;
  for i in 1..v_currency_b_list.count loop
    XTR_fps2_P.calc_cross_rate(v_currency_b_list(i),null);
  END LOOP;

EXCEPTION
  WHEN e_inv THEN
    FND_FILE.put_line(FND_FILE.LOG,'invalid parameter error. You must enter A,N, or C for the first parameter and Y or N for the second');

END market_data_transfer;


PROCEDURE upload_rates_to_gl_cp(errbuf		OUT NOCOPY	VARCHAR2,
				retcode		OUT NOCOPY	VARCHAR2,
				p_rel_abs	IN		VARCHAR2,
				p_abs_start_date	IN	VARCHAR2,
				p_abs_end_date	IN		VARCHAR2,
				p_rel_end_date	IN		NUMBER,
				p_rel_start_date	IN	NUMBER,
				p_rate_calc	IN		VARCHAR2,
				p_bid_mid_ask	IN		VARCHAR2,
				p_conv_type	IN		VARCHAR2,
				p_overwrite	IN		VARCHAR2) IS

t_currencies	dbms_sql.varchar2_table;
t_bids		dbms_sql.number_table;
t_offers	dbms_sql.number_table;
t_mul_or_div	dbms_sql.varchar2_table;
v_start_date	DATE;
v_end_date	DATE;
v_errbuf	VARCHAR2(80);
v_retcode	VARCHAR2(80);
p_batch_number_v VARCHAR2(40) DEFAULT NULL; --Bug 9300833

CURSOR get_from_usd_quote_avg(p_ref_date DATE) is
  SELECT outer.currency quote_currency,
         AVG(outer.bid_rate_against_usd) bid_rate_against_usd,
         AVG(outer.offer_rate_against_usd) offer_rate_against_usd,
         mc.divide_or_multiply
  FROM   xtr_spot_rates outer,
         xtr_master_currencies mc
  WHERE  outer.currency <> 'USD'
  AND    outer.rate_date >= p_ref_date
  AND    outer.rate_date <= (p_ref_date+1)
  AND    outer.currency = mc.currency
  GROUP BY outer.currency,mc.divide_or_multiply
  UNION ALL
  SELECT outer.currency quote_currency,
         outer.bid_rate_against_usd,
         outer.offer_rate_against_usd,
         mc.divide_or_multiply
  FROM   xtr_spot_rates outer,
         xtr_master_currencies mc
  WHERE  outer.currency <> 'USD'
  AND    outer.currency = mc.currency
  AND NOT EXISTS (SELECT 1
                  FROM   xtr_spot_rates inner
                  WHERE  outer.currency = inner.currency
                  AND    rate_date >= p_ref_date
                  AND    rate_date <= (p_ref_date+1))
  AND    outer.rate_date = (SELECT max(rate_date)
                            FROM   xtr_spot_rates inner
                            WHERE  outer.currency = inner.currency
                            AND    rate_date < p_ref_date)
  ORDER BY quote_currency;

CURSOR get_from_usd_quote_eod(p_ref_date DATE) is
  SELECT outer.currency,
         outer.bid_rate_against_usd,
         outer.offer_rate_against_usd,
         mc.divide_or_multiply
  FROM   xtr_spot_rates outer,
         xtr_master_currencies mc
  WHERE  outer.currency <> 'USD'
  AND    outer.currency = mc.currency
  AND    outer.rate_date = (SELECT max(rate_date)
                            FROM   xtr_spot_rates inner
                            WHERE  outer.currency = inner.currency
                            AND    rate_date <= (p_ref_date+1))
  ORDER BY outer.currency;

cursor get_failed_imports(p_start_date DATE,p_end_date DATE) is
  SELECT DECODE(FROM_CURRENCY,'USD',TO_CURRENCY,FROM_CURRENCY) CURRENCY,NVL(ERROR_CODE,'VALIDATION_FAILURE') ERROR_CODE
  FROM   gl_daily_rates_interface
  WHERE  MODE_FLAG in ('X','F')
  AND    FROM_CONVERSION_DATE=p_start_date
  AND    TO_CONVERSION_DATE=p_end_date
  AND    USER_ID=fnd_global.user_id
  ORDER BY MODE_FLAG,TO_CURRENCY;


  Procedure	Put_Log(Avr_Buff In Varchar2) is
  Begin
	Fnd_File.Put_Line(Fnd_file.LOG,Avr_Buff);
  End;
  PROCEDURE populate_rate(p_currency		VARCHAR2,
                          p_date		DATE,
                          p_bid_rate		NUMBER,
                          p_offer_rate		NUMBER,
                          p_mul_or_div		VARCHAR2) IS

    p_insert_into_gl 	BOOLEAN:=TRUE;
    p_rate		NUMBER;
    p_dummy 		NUMBER;
    p_mode_flag 	VARCHAR2(1);
    p_from_currency	VARCHAR2(15);
    p_to_currency	VARCHAR2(15);
    CURSOR get_is_no_upload IS
      SELECT 1
      FROM   xtr_master_currencies
      WHERE  currency = p_currency
      AND    gl_no_upload='Y'
      AND    ROWNUM=1;
  BEGIN
    OPEN get_is_no_upload;
    FETCH get_is_no_upload INTO p_dummy;
    IF get_is_no_upload%FOUND THEN
      p_insert_into_gl:=FALSE;
    END IF;
    CLOSE get_is_no_upload;
    if (p_overwrite='N') then
      p_mode_flag:='N';
    else
      p_mode_flag:='T';
    end if;

    IF (p_insert_into_gl) THEN
      if (p_bid_mid_ask='ASK') then
        p_rate:=p_offer_rate;
      elsif (p_bid_mid_ask='BID') then
        p_rate:=p_bid_rate;
      else
        p_rate:=(p_offer_rate+p_bid_rate)/2;
      end if;
      if p_mul_or_div='*' then
        p_from_currency := p_currency;
        p_to_currency := 'USD';
      else
        p_from_currency := 'USD';
        p_to_currency := p_currency;
      end if;

      put_log(rpad(p_currency,15)||rpad(p_rate,15)||rpad(1/p_rate,15));

      insert into gl_daily_rates_interface(
        FROM_CURRENCY,
        TO_CURRENCY,
        FROM_CONVERSION_DATE,
        TO_CONVERSION_DATE,
        USER_CONVERSION_TYPE,
        CONVERSION_RATE,
        MODE_FLAG,
        INVERSE_CONVERSION_RATE,
        USER_ID)
      values(
         p_from_currency,
         p_to_currency,
         p_date,
         p_date,
         p_conv_type,
         p_rate,
         p_mode_flag,
         null,
         fnd_global.user_id);

    END IF;
  END populate_rate;

BEGIN
  retcode:='0';
  IF (p_rel_abs='R') THEN
    v_end_date := TRUNC(SYSDATE)-p_rel_end_date;
    v_start_date := TRUNC(SYSDATE)-p_rel_start_date;
  ELSIF (p_rel_abs='A') THEN
    v_end_date := fnd_date.canonical_to_date(p_abs_end_date);
    v_start_date := fnd_date.canonical_to_date(p_abs_start_date);
  END IF;

  IF (   v_start_date is null
      or v_end_date is null
      or p_bid_mid_ask is null
      or p_bid_mid_ask not in ('BID','MID','ASK')
      or v_start_date > v_end_date
     ) THEN
     put_log(fnd_message.get_string('XTR','XTR_1328'));
     retcode:='2';
  END IF;

  if (retcode<>'2') then

    for i in 0..(v_end_date-v_start_date) loop

      fnd_message.set_name('XTR','XTR_GL_UPLOAD_RATES');
      fnd_message.set_token('RATE_TYPE',p_conv_type);
      fnd_message.set_token('RATE_DATE',v_start_date+i);
      put_log(fnd_message.get);
      put_log(rpad(' ',15)||rpad(fnd_message.get_string('XTR','XTR_RATE_QUOTE'),30,'-'));
      put_log(rpad(fnd_message.get_string('XTR','XTR_CURRENCY_PROMPT'),15)||rpad(fnd_message.get_string('XTR','XTR_BASE_UNIT'),15)||rpad(fnd_message.get_string('XTR','XTR_CONTRA_UNIT'),15));

      IF (p_rate_calc='DAY_AVG') THEN
        OPEN get_from_usd_quote_avg(v_start_date+i);
        FETCH get_from_usd_quote_avg BULK COLLECT INTO t_currencies,t_bids,t_offers,t_mul_or_div;
        CLOSE get_from_usd_quote_avg;
      ELSE
        OPEN get_from_usd_quote_eod(v_start_date+i);
        FETCH get_from_usd_quote_eod BULK COLLECT INTO t_currencies,t_bids,t_offers,t_mul_or_div;
        CLOSE get_from_usd_quote_eod;
      END IF;

      FOR j IN 1..t_currencies.COUNT LOOP
        populate_rate(t_currencies(j),v_start_date+i,t_bids(j),t_offers(j),t_mul_or_div(j));
      END LOOP;
      put_log(' ');

    end loop;

    --GL_CRM_UTILITIES_PKG.daily_rates_import(v_errbuf,v_retcode);
    GL_CRM_UTILITIES_PKG.daily_rates_import(v_errbuf,v_retcode, p_batch_number_v); --BUG 9300833

    for c_error in get_failed_imports(v_start_date,v_end_date) loop
      if (retcode='0') then
        retcode:='1';
        put_log(' ');
        put_log(fnd_message.get_string('XTR','XTR_GL_UPLOAD_RATES_FAIL'));
        put_log(rpad(fnd_message.get_string('XTR','XTR_CURRENCY_PROMPT'),15)||rpad(fnd_message.get_string('XTR','XTR_ERROR'),30));
        put_log(rpad('-',45,'-'));
      end if;
      put_log(rpad(c_error.currency,15)||rpad(c_error.error_code,30));
    end loop;

    delete from gl_daily_rates_interface
    where  MODE_FLAG in ('X','F')
    and    USER_ID=fnd_global.user_id
    and    FROM_CONVERSION_DATE=TO_CONVERSION_DATE
    and    FROM_CONVERSION_DATE>=v_start_date
    and    FROM_CONVERSION_DATE<=v_end_date;

  END IF;
END upload_rates_to_gl_cp;

--------------------------------------------------------------------------------------------------------------------
END xtr_market_data_interface_p;

/
