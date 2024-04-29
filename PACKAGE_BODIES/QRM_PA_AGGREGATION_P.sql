--------------------------------------------------------
--  DDL for Package Body QRM_PA_AGGREGATION_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QRM_PA_AGGREGATION_P" AS
/* $Header: qrmpaggb.pls 120.13 2005/09/20 11:49:16 csutaria ship $ */


/***************************************************************
This procedure determines the underlying currency of the report:
IF v_amount EXIST
  IF already 1 underlying Ccy
    IF Deals Ccy
      Use Deals Ccy
    IF SOB Ccy
      Use SOB Ccy
    IF Reporting Ccy
      Use Rerportin Ccy
  ELSIF Ccy is one of the aggregate attributes
    IF Deals Ccy
      Use Deals Ccy
    IF SOB Ccy
      Use SOB Ccy
    IF Reporting Ccy
      Use Rerportin Ccy
    --make sure the aggregate level above the Ccy agg.
    --cannot be Totaled
  ELSE
    Use Reporting Ccy

It finds the ccy aggregate lowest level and the underlying ccy.
It also determines the suffix '_USD' or '_SOB' to be appended
onto the columns names.
In addition, it calculates the currency multiplier in the case
of Reporting Ccy other than USD is used.
***************************************************************/
PROCEDURE get_underlying_currency(p_name VARCHAR2,
                        p_ref_date DATE,
                        p_style VARCHAR2,
                        p_md_set_code VARCHAR2,
                        p_currency_source VARCHAR2,
                        p_curr_reporting VARCHAR2,
                        p_amount SYSTEM.QRM_VARCHAR_TABLE,
                        p_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                        p_ccy_aggregate IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_type IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_order IN OUT NOCOPY XTR_MD_NUM_TABLE,
                        p_ccy_suffix OUT NOCOPY VARCHAR2,
                        p_ccy_multiplier OUT NOCOPY NUMBER,
                        p_ccy_agg_flag OUT NOCOPY NUMBER,
                        p_underlying_ccy OUT NOCOPY VARCHAR2,
                        p_ccy_case_flag OUT NOCOPY NUMBER,
                        p_measure VARCHAR2,
                        p_ccy_agg_level OUT NOCOPY NUMBER,
                        --only necessary for style='T'
                        p_table_col_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_agg_col_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_sensitivity SYSTEM.QRM_VARCHAR_TABLE)
	 IS

  v_amount_type BOOLEAN;
  v_uniform_ccy BOOLEAN := TRUE;
  v_count NUMBER;
  v_meas_temp VARCHAR2(240);
  v_temp VARCHAR2(30);
  v_deal_currency_col VARCHAR2(30);
  i NUMBER(5) := 0;
  j NUMBER(5);
  v_count_sens NUMBER;
  v_underlying_ccy_sens VARCHAR2(30);

  CURSOR check_deal_ccy IS
     SELECT DISTINCT dc.deal_ccy
                        --or reval_ccy for FX??
                        --Felicia will copy reval_ccy to currency for FX
                        --02/05/2002
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id;
  CURSOR check_sob_ccy IS
     SELECT DISTINCT dc.sob_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id;
  CURSOR check_base_ccy IS
     SELECT DISTINCT v.base_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
			qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
			AND v.deal_no=dc.deal_no
			AND v.transaction_no=dc.transaction_no;
  CURSOR check_contra_ccy IS
     SELECT DISTINCT v.contra_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
			qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
			AND v.deal_no=dc.deal_no
			AND v.transaction_no=dc.transaction_no;
  CURSOR check_buy_ccy IS
     SELECT DISTINCT v.buy_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
                        qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
                        AND dc.deal_no=v.deal_no
                        AND dc.transaction_no=v.transaction_no;
  CURSOR check_sell_ccy IS
     SELECT DISTINCT v.sell_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
                        qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
                        AND dc.deal_no=v.deal_no
                        AND dc.transaction_no=v.transaction_no;
  CURSOR check_foreign_ccy IS
     SELECT DISTINCT v.foreign_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
                        qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
                        AND dc.deal_no=v.deal_no
                        AND dc.transaction_no=v.transaction_no;
  CURSOR check_domestic_ccy IS
     SELECT DISTINCT v.domestic_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
                        qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
                        AND dc.deal_no=v.deal_no
                        AND dc.transaction_no=v.transaction_no;
  CURSOR check_sensitivity_ccy IS
     SELECT DISTINCT v.sensitivity_ccy
                        FROM qrm_deal_calculations dc, qrm_deals_analyses da,
                        qrm_current_deals_v v
                        WHERE da.analysis_name=p_name
                        AND da.deal_calc_id=dc.deal_calc_id
                        AND dc.deal_no=v.deal_no
                        AND dc.transaction_no=v.transaction_no;
  CURSOR get_deal_currency_col IS
     SELECT deal_currency_col FROM qrm_ana_atts_lookups
                        WHERE attribute_name=v_meas_temp;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.GET_UNDERLYING_CCY');
  END IF;
------------------CURRENCY LOGIC-----------------------
  --for sensitivity can only be averaged/summed if the underlying
  --sensitivity_ccy is uniform
  --check only if Currency Source is not Deal Currency, coz. for
  --Deal Currency the checking is done in the loop below.
  IF p_style='T' AND p_currency_source<>'D' THEN
     OPEN check_sensitivity_ccy;
     LOOP
        FETCH check_sensitivity_ccy INTO v_underlying_ccy_sens;
        EXIT WHEN check_sensitivity_ccy%ROWCOUNT>2 OR check_sensitivity_ccy%NOTFOUND;
     END LOOP;
     v_count_sens :=  check_sensitivity_ccy%ROWCOUNT;
     CLOSE check_sensitivity_ccy;
  END IF;

  --Assumption: AMOUNT type is the only measure that
  --can only be converted to different area
  --get the underlying currency
  IF p_currency_source='D' THEN --Deal ccy
     IF p_style IN('X','C') THEN
        j := 1;
     ELSE --style='A','T'
        j := p_agg.COUNT;
     END IF;
     FOR i IN 1..j LOOP
        IF p_style='A' THEN
           IF p_amount(i)='Y' THEN
              v_amount_type := TRUE;
              v_meas_temp := p_agg(i);
           ELSE
              v_amount_type := FALSE;
           END IF;
        ELSIF p_style='T' THEN
           v_amount_type := TRUE;
           v_meas_temp := p_agg(i);
        ELSE --style C,X, the check was done earlier
           v_amount_type := TRUE;
           v_meas_temp := p_measure;
        END IF;
        IF v_amount_type THEN
           --get the deal_currency_col from qrm_ana_atts_lookups
           OPEN get_deal_currency_col;
           FETCH get_deal_currency_col INTO v_deal_currency_col;
           CLOSE get_deal_currency_col;
           IF v_deal_currency_col='BASE_CCY' THEN
              --check for uniform deal ccy
              OPEN check_base_ccy;
              LOOP
                 FETCH check_base_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_base_ccy%ROWCOUNT>2 OR check_base_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_base_ccy%ROWCOUNT;
              CLOSE check_base_ccy;
           ELSIF v_deal_currency_col='CONTRA_CCY' THEN
              --check for uniform deal ccy
              OPEN check_contra_ccy;
              LOOP
                 FETCH check_contra_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_contra_ccy%ROWCOUNT>2 OR check_contra_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_contra_ccy%ROWCOUNT;
              CLOSE check_contra_ccy;
           ELSIF v_deal_currency_col='BUY_CCY' THEN
              --check for uniform deal ccy
              OPEN check_buy_ccy;
              LOOP
                 FETCH check_buy_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_buy_ccy%ROWCOUNT>2 OR check_buy_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_buy_ccy%ROWCOUNT;
              CLOSE check_buy_ccy;
           ELSIF v_deal_currency_col='SELL_CCY' THEN
              --check for uniform deal ccy
              OPEN check_sell_ccy;
              LOOP
                 FETCH check_sell_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_sell_ccy%ROWCOUNT>2 OR check_sell_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_sell_ccy%ROWCOUNT;
              CLOSE check_sell_ccy;
           ELSIF v_deal_currency_col='FOREIGN_CCY' THEN
              --check for uniform deal ccy
              OPEN check_foreign_ccy;
              LOOP
                 FETCH check_foreign_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_foreign_ccy%ROWCOUNT>2 OR check_foreign_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_foreign_ccy%ROWCOUNT;
              CLOSE check_foreign_ccy;
           ELSIF v_deal_currency_col='DOMESTIC_CCY' THEN
              --check for uniform deal ccy
              OPEN check_domestic_ccy;
              LOOP
                 FETCH check_domestic_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_domestic_ccy%ROWCOUNT>2 OR check_domestic_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_domestic_ccy%ROWCOUNT;
              CLOSE check_domestic_ccy;
           ELSIF v_deal_currency_col='SENSITIVITY_CCY' THEN
              --check for uniform sensitivity ccy
              OPEN check_sensitivity_ccy;
              LOOP
                 FETCH check_sensitivity_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_sensitivity_ccy%ROWCOUNT>2 OR check_sensitivity_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_sensitivity_ccy%ROWCOUNT;
              CLOSE check_sensitivity_ccy;
           ELSE
              --check for uniform deal ccy
              OPEN check_deal_ccy;
              LOOP
                 FETCH check_deal_ccy INTO p_underlying_ccy;
                 EXIT WHEN check_deal_ccy%ROWCOUNT>2 OR check_deal_ccy%NOTFOUND;
              END LOOP;
              v_count :=  check_deal_ccy%ROWCOUNT;
              CLOSE check_deal_ccy;
           END IF;
        END IF;
        IF p_style='A' THEN
           --check whether 1 ccy/column
           IF v_count>1 THEN
              p_ccy_case_flag := 0;
              p_underlying_ccy := NULL;
              EXIT;
           ELSE --put the underlying currency into the array
              p_agg_col_curr.EXTEND;
	      p_agg_col_curr(i) := p_underlying_ccy;
           END IF;
           --check whether 1 underlying ccy
           IF i>1 THEN
              IF v_temp<>p_underlying_ccy THEN
                 v_uniform_ccy := FALSE;
              END IF;
           END IF;
           v_temp := p_underlying_ccy;
        --For Table style try to either fill in the v_table_col_curr
        --or append the suffix to p_agg.
        --Unlike style='A', Table style determine currency per column basis
        ELSIF p_style='T' THEN
           --check whether 1 ccy for the particular column
           IF v_count>1 THEN
              IF p_sensitivity(i)='N' THEN
       		 --revert to Reporting Currency
                 p_agg(i) := p_agg(i)||'_USD';
                 --leave p_table_col_curr NULL,necessary for Spot Rate
		 --validations
              ELSE
                 --NULL for sensitivity
                 p_agg(i) := NULL;
              END IF;
           ELSE --use the currency
              p_table_col_curr(i) := p_underlying_ccy;
           END IF;
        END IF;
     END LOOP;
     --determine v_ccy_case_flag
     IF p_style='A' THEN
        IF p_ccy_case_flag IS NULL THEN
           IF v_uniform_ccy THEN
              p_ccy_case_flag := 1;--1 ccy
           ELSE
              p_ccy_case_flag := 2;--1 ccy/col
              p_underlying_ccy := NULL;
           END IF;
        END IF;
     ELSIF p_style IN ('C','X') THEN
        IF v_count=1 THEN
           p_ccy_case_flag := 1;--1 ccy
        ELSE
           p_ccy_case_flag := 0;-->1 ccy
           p_underlying_ccy := NULL;
        END IF;
     END IF;
  ELSIF p_currency_source='B' THEN
     --check for uniform deal ccy
     OPEN check_sob_ccy;
     LOOP
        FETCH check_sob_ccy INTO p_underlying_ccy;
        EXIT WHEN check_sob_ccy%ROWCOUNT>2 OR check_sob_ccy%NOTFOUND;
     END LOOP;
     v_count :=  check_sob_ccy%ROWCOUNT;
     CLOSE check_sob_ccy;
     --For Table style try to either fill in the v_table_col_curr
     --or append the suffix to p_agg.
     --Unlike style='A', Table style determine currency per column basis
     IF p_style='T' THEN
        IF v_count=1 THEN --use SOB
           p_ccy_suffix := '_SOB';
        ELSE --use Reporting Currency
           p_ccy_suffix := '_USD';
           p_underlying_ccy := NULL;
        END IF;
        FOR i IN 1..p_agg.COUNT LOOP
           IF p_sensitivity(i)='N' THEN
              p_agg(i) := p_agg(i)||p_ccy_suffix;
              p_table_col_curr(i) := p_underlying_ccy;
           ELSE --sensitivity
              IF v_count_sens>1 THEN --NULL's the p_agg(i)
                 p_agg(i) := NULL;
              ELSE --use the currency
                 p_table_col_curr(i) := v_underlying_ccy_sens;
              END IF;
           END IF;
        END LOOP;
     ELSE --style='A','C','X'
        IF v_count=1 THEN
           p_ccy_case_flag := 1;
        ELSE
           p_ccy_case_flag := 0;
           p_underlying_ccy := NULL;
        END IF;
     END IF;
  ELSIF p_style='T' THEN --p_currency_source='R'
     --Append Reporting Currency suffix to the p_agg
     FOR i IN 1..p_agg.COUNT LOOP
        IF p_sensitivity(i) = 'N' THEN
           p_agg(i) := p_agg(i)||'_USD';
        ELSE --sensitivity
           IF v_count_sens>1 THEN --NULL's the p_agg(i)
              p_agg(i) := NULL;
           ELSE --use the currency
              p_table_col_curr(i) := v_underlying_ccy_sens;
           END IF;
        END IF;
     END LOOP;
  END IF;

  --determine p_ccy_agg_flag only necessary when >1 ccy and style<>'T'
  --and ccy pref<>'R'
  IF p_style<>'T' THEN
     IF (p_ccy_case_flag<>1 AND p_currency_source<>'R') THEN
        FOR i IN REVERSE 1..p_agg.COUNT LOOP
           IF p_currency_source='D' THEN
              --1 ccy/col will have p_ccy_agg_flag=0
              --make sure only the underlying ccy is considered
	      --i.e. BUY_AMOUNT only consider BUY_CCY
              IF p_ccy_case_flag<>2 AND p_ccy_aggregate(i)='Y'
	      AND p_agg(i)=v_deal_currency_col THEN
                 p_ccy_agg_level := p_order(i);
                 IF p_type(i)='R' THEN
                    p_ccy_agg_flag := 1;
                    p_ccy_agg_level := i;
                    EXIT;
                 ELSE --p_type(i)='C'
                    p_ccy_agg_flag := 2;
                    p_ccy_agg_level := i;
                    EXIT;
                 END IF;
              ELSE
                 IF i=1 THEN --last interation
                    p_ccy_agg_flag := 0;
                    p_ccy_agg_level := 0;
                 END IF;
              END IF;
           ELSE --p_currency_source='B'
              IF p_agg(i)='COMPANY_CODE' THEN
                 p_ccy_agg_level := p_order(i);
                 IF p_type(i)='R' THEN
                    p_ccy_agg_flag := 1;
                    p_ccy_agg_level := i;
                    EXIT;
                 ELSE --p_type(i)='C'
                    p_ccy_agg_flag := 2;
                    p_ccy_agg_level := i;
                    EXIT;
                 END IF;
              ELSE
                 IF i=1 THEN --last iteration
                    p_ccy_agg_flag := 0;
                    p_ccy_agg_level := 0;
                 END IF;
              END IF;
           END IF;
        END LOOP;
     END IF;

     --determine p_ccy_suffix=ccy pref used
     --not necessary for Table style
     IF (p_ccy_case_flag=0 AND p_ccy_agg_flag=0) OR p_currency_source='R' THEN
     --revert to reporting ccy
        p_ccy_suffix := '_USD';
        p_underlying_ccy := p_curr_reporting;
     ELSE --no need to revert to reporting ccy
        IF p_currency_source='B' THEN --ccy pref=SOB
           p_ccy_suffix := '_SOB';
        END IF;
     END IF;
  END IF; --p_style<>'T'

  --Find multiplier
  IF p_curr_reporting<>'USD' THEN
    p_ccy_multiplier := get_fx_rate(p_md_set_code,
			p_ref_date,
			'USD',
			p_curr_reporting,
			'M');
  END IF;
------------------END OF CURRENCY LOGIC----------------
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.GET_UNDERLYING_CCY');
  END IF;
END get_underlying_currency;



/***************************************************************
This procedure appends suffix '_USD' or '_SOB' to the actual
column name to be used in the dynamic SQL.
***************************************************************/
PROCEDURE get_actual_column_name(p_name VARCHAR2,
                p_amount SYSTEM.QRM_VARCHAR_TABLE,
                p_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_actual_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_nom_fl IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_denom_fl IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_actual_agg_usd IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_nom_fl_usd IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_denom_fl_usd IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_ccy_suffix VARCHAR2,
                p_ccy_multiplier NUMBER,
                p_need_usd_arr BOOLEAN,
                p_origin IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                p_origin_usd IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_num_denom_origin IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_num_denom_origin_usd IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_type IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_sensitivity SYSTEM.QRM_VARCHAR_TABLE)
		IS

  i NUMBER(5);
  v_col_name VARCHAR2(200);

  CURSOR get_nom_denom IS
      SELECT numerator,denominator,num_denom_origin
      FROM qrm_ana_atts_lookups
      WHERE attribute_name=v_col_name;
  CURSOR get_origin IS
      SELECT origin FROM qrm_ana_atts_lookups
      WHERE attribute_name=v_col_name;
  v_deal_type_arr SYSTEM.QRM_VARCHAR_table;
  v_market_type_arr SYSTEM.QRM_VARCHAR_table;
  v_count NUMBER;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.GET_ACT_COL_NAME');
  END IF;

   p_actual_agg.EXTEND(p_agg.COUNT);
----------This is for the Total ccy conversion purpose
   --check whether we need USD ccy on backup
   IF p_need_usd_arr THEN
      p_actual_agg_usd.EXTEND(p_agg.COUNT);
      p_nom_fl_usd.EXTEND(p_agg.COUNT);
      p_denom_fl_usd.EXTEND(p_agg.COUNT);
      p_origin_usd.EXTEND(p_agg.COUNT);
      p_num_denom_origin_usd.EXTEND(p_agg.COUNT);
   END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('get_actual_column_name: ' || 'p_nom_fl_usd.COUNT',p_nom_fl_usd.COUNT);
END IF;
----------End This is for the Total ccy conversion purpose
   --update col. name based on the currency conversion
   FOR i IN 1..p_agg.COUNT LOOP
      --Only Measure can be appended with _USD and _SOB for curr. consistency
      --but cannot be sensitivity
      IF p_type(i)='M' AND p_sensitivity(i)='N' THEN
         IF p_ccy_suffix IS NOT NULL THEN
            --need to modify p_nom_fl and p_denom_fl
            v_col_name := p_agg(i)||p_ccy_suffix;
            OPEN get_nom_denom;
            FETCH get_nom_denom INTO p_nom_fl(i),p_denom_fl(i),p_num_denom_origin(i);
            CLOSE get_nom_denom;
            --p_nom_fl and p_denom_fl are already updated above
            --modify the origin, bec. origin may not be the same
            OPEN get_origin;
            FETCH get_origin INTO p_origin(i);
            CLOSE get_origin;
            --need to modify the actual column name
	    --can only add ccy multiplier for amount type
            IF p_ccy_suffix='_USD' AND p_ccy_multiplier IS NOT NULL
	    AND p_amount(i)='Y' THEN
               --append ccy suffix and multiplier to the act. col. names

               --WDK: The following code breaks NLS
               --p_actual_agg(i) := p_agg(i)||p_ccy_suffix||'*'||TO_CHAR(p_ccy_multiplier);
               --p_nom_fl(i) := p_nom_fl(i)||'*'||TO_CHAR(p_ccy_multiplier);

               --WDK: NLS fix
               p_actual_agg(i) := p_agg(i)||p_ccy_suffix||'*TO_NUMBER('''||TO_CHAR(p_ccy_multiplier)||''')';
               p_nom_fl(i) := p_nom_fl(i)||'*TO_NUMBER('''||TO_CHAR(p_ccy_multiplier)||''')';
            ELSE
               p_actual_agg(i) := p_agg(i)||p_ccy_suffix;
            END IF;
         ELSE
            p_actual_agg(i) := p_agg(i);
         END IF;
----------This is for the Total ccy conversion purpose
         --check whether we need USD ccy on backup
         IF p_need_usd_arr THEN
            v_col_name := p_agg(i)||'_USD';
            OPEN get_nom_denom;
            FETCH get_nom_denom INTO p_nom_fl_usd(i),p_denom_fl_usd(i),p_num_denom_origin_usd(i);
            CLOSE get_nom_denom;
            --p_nom_fl and p_denom_fl are already updated above
            --modify the origin, bec. origin may not be the same
            OPEN get_origin;
            FETCH get_origin INTO p_origin_usd(i);
            CLOSE get_origin;
            --need to modify the usd column name
	    --can only add ccy multiplier for amount type
            IF p_ccy_multiplier IS NOT NULL AND p_amount(i)='Y' THEN
               --append ccy suffix and multiplier to the act. col. names
               --WDK: The following code breaks NLS
               --p_actual_agg_usd(i) := p_agg(i)||'_USD*'||TO_CHAR(p_ccy_multiplier);
               --p_nom_fl_usd(i) := p_nom_fl(i)||'*'||TO_CHAR(p_ccy_multiplier);
               --WDK: NLS fix
               p_actual_agg_usd(i) := p_agg(i)||'_USD*TO_NUMBER('''||TO_CHAR(p_ccy_multiplier)||''')';
               p_nom_fl_usd(i) := p_nom_fl(i)||'*TO_NUMBER('''||TO_CHAR(p_ccy_multiplier)||''')';
               --p_ccy_multiplier is not necessary for denom
               p_denom_fl_usd(i) := p_denom_fl(i);
            ELSE
               p_actual_agg_usd(i) := p_agg(i)||'_USD';
               --p_nom_fl and p_denom_fl are already updated above
            END IF;
         END IF;
----------End This is for the Total ccy conversion purpose
      ELSE
         p_actual_agg(i) := p_agg(i);
      END IF;
   END LOOP;

-----------Testing
FOR i IN 1..p_actual_agg.COUNT LOOP
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('get_actual_column_name: ' || 'p_actual_agg(i)',i||':'||p_actual_agg(i));
END IF;
IF p_need_usd_arr THEN
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dlog('get_actual_column_name: ' || 'p_nom_fl_usd(i)',i||':'||p_nom_fl_usd(i));
   END IF;
END IF;
END LOOP;
-----------End Testing
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.GET_ACT_COL_NAME');
  END IF;
END get_actual_column_name;



/***************************************************************
This procedure calculate the currency multipliers if there are
> 1 underlying currencies across the column aggregates.
The currency multipliers will then saved into an array that is
identical to the array used when inserting measures into
QRM_SAVED_ANALYSES_ROW.
Please refer to Bug 2566711.
***************************************************************/
PROCEDURE get_col_ccy_multp(p_col_ccy_multp IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_a1 IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
			p_default_ccy VARCHAR2,
			p_row_agg_no NUMBER,
			p_max_col_no NUMBER,
			p_md_set_code VARCHAR2,
			p_ref_date DATE)
	IS

   v_prev_ccy gl_sets_of_books.currency_code%TYPE;
   v_ccy gl_sets_of_books.currency_code%TYPE;
   v_fx_rate NUMBER;

   CURSOR get_sob_ccy (p_company_code VARCHAR2) IS
      SELECT  sob.currency_code
      FROM gl_sets_of_books sob, xtr_party_info pinfo
      WHERE pinfo.party_code = p_company_code AND
	 pinfo.set_of_books_id = sob.set_of_books_id;

BEGIN
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.GET_COL_CCY_MULTP');
      xtr_risk_debug_pkg.dlog('get_col_ccy_multp: ' || 'p_currency_source',p_default_ccy);
   END IF;

   p_col_ccy_multp.EXTEND(p_max_col_no);

   FOR i IN p_row_agg_no+1..p_a1.COUNT-1 LOOP
      IF p_default_ccy='D' THEN --Deal ccy
         --do some checks for optimization
         IF p_a1(i) IS NOT NULL THEN
            --Additional check for optimization
            IF i>1 and p_a1(i)=p_a1(i-1) THEN
               p_col_ccy_multp(i-p_row_agg_no) := v_fx_rate;
            ELSE
               v_fx_rate := get_fx_rate(p_md_set_code,
					p_ref_date,
					p_a1(i),
					'USD',
					'M');
               p_col_ccy_multp(i-p_row_agg_no) := v_fx_rate;
            END IF;
         END IF;
      ELSIF p_default_ccy='B' THEN --SOB ccy
         --do some checks for optimization
         IF p_a1(i) IS NOT NULL THEN
            --Additional check for optimization
            IF i>1 and p_a1(i)=p_a1(i-1) THEN
               p_col_ccy_multp(i-p_row_agg_no) := v_fx_rate;
            ELSE
               OPEN get_sob_ccy(p_a1(i));
	       FETCH get_sob_ccy INTO v_ccy;
	       CLOSE get_sob_ccy;
	       --Additional check for optimization
               IF v_ccy=v_prev_ccy THEN
                  p_col_ccy_multp(i-p_row_agg_no) := v_fx_rate;
	       ELSE
                  v_fx_rate := get_fx_rate(p_md_set_code,
					p_ref_date,
					p_a1(i),
					'USD',
					'M');
                  p_col_ccy_multp(i-p_row_agg_no) := v_fx_rate;
		  v_prev_ccy := v_ccy;
	       END IF;
            END IF;
         END IF;
      END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('get_col_ccy_multp: ' || 'i:p_a1',i||':'||p_a1(i));
   xtr_risk_debug_pkg.dlog('get_col_ccy_multp: ' || 'v_fx_rate',v_fx_rate);
   xtr_risk_debug_pkg.dlog('i:p_col_ccy_multp',i||':'||p_col_ccy_multp(i-p_row_agg_no));
END IF;
   END LOOP;

   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.GET_COL_CCY_MULTP');
   END IF;
END get_col_ccy_multp;



/***************************************************************
This function updates the columns' totals in the case of Crosstab
style with different underlying currencies for different columns.
Please refer to Bug 2566711.
***************************************************************/
FUNCTION calc_col_total(p_col_ccy_multp IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_measure IN OUT NOCOPY XTR_MD_NUM_TABLE,
			p_max_col_no NUMBER,
			p_ccy_case_flag NUMBER,
			p_ccy_agg_flag NUMBER,
			p_max_col_agg_level NUMBER)
	RETURN NUMBER IS

   v_total NUMBER := 0;
   v_temp_meas XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   v_null BOOLEAN := TRUE;

BEGIN

   v_temp_meas.EXTEND(p_measure.COUNT);

   --do simple stuffs for 1 level column aggregate
   IF p_max_col_agg_level=1 THEN
      --only need to do extra if columns has different currencies
      IF p_ccy_case_flag=0 and p_ccy_agg_flag=2 and p_max_col_no-1>1 THEN
         FOR i IN 1..p_measure.COUNT-1 LOOP
            IF p_measure(i) IS NOT NULL and p_col_ccy_multp(i) is not null
	    THEN
	       v_total := v_total + p_measure(i)*p_col_ccy_multp(i);
               v_null := FALSE;
            END IF;
	 END LOOP;
      END IF;
   ELSE
      NULL;
      --put in similar totaling logic to the one for
      --QRM_SAVED_ANALYSES_ROW
   END IF;

   IF v_null THEN
      v_total := NULL;
   END IF;

   RETURN v_total;

END calc_col_total;



/***************************************************************
This procedure insert 1 row at a time to qrm_saved_analyses_row
called when looping through the main cursor. Cannot do bulk insert
without initializing 100 arrays, thus, static insert per row basis
is the next viable option.
***************************************************************/
FUNCTION insert_row(sh IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                    sm IN OUT NOCOPY XTR_MD_NUM_TABLE,
                    p_row_agg_no NUMBER,
                    p_max_col_no NUMBER,
                    p_name VARCHAR2,
                    p_row NUMBER,
                    p_type NUMBER,
                    p_hidden VARCHAR2,
                    p_tot_currency VARCHAR2,
                    p_style VARCHAR2,
                    p_ref_date DATE,
		    p_ccy_case_flag NUMBER,
		    p_ccy_agg_flag NUMBER,
		    p_col_ccy_multp IN OUT NOCOPY XTR_MD_NUM_TABLE)
        RETURN BOOLEAN IS

  v_tot_currency VARCHAR2(20);
  v_tot_currency_label VARCHAR2(25);
  v_null BOOLEAN := TRUE;
-----Testing purposes
  v_test VARCHAR2(4096);  --WDK: this limit increased
-----End

BEGIN

   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.INSERT_ROW');
   END IF;

---------Should be removed if multiple level columns is implemented
--If multiple col level is implemented, replace this with
--a function that transfer the value of the 'sm' array to a new array
--while inserting and calculating Total whenever necessary.
--Equivalent to the process for the row.
  --calculate end column total
  sm(p_max_col_no) := 0;
  IF p_style<>'A' THEN

----Start Bug 2566711
     IF p_style='C' and p_ccy_case_flag=0 and p_ccy_agg_flag=2
     and p_max_col_no-1>1 THEN
        sm(p_max_col_no) := calc_col_total(p_col_ccy_multp,
			sm,
			p_max_col_no,
			p_ccy_case_flag,
			p_ccy_agg_flag,
			1);
        IF sm(p_max_col_no) IS NULL THEN
	   v_null := TRUE;
        ELSE
	   v_null := FALSE;
        END IF;
----End Bug 2566711

     ELSE
        FOR i IN 1..p_max_col_no-1 LOOP
           IF sm(i) IS NOT NULL THEN
              sm(p_max_col_no):=sm(p_max_col_no)+sm(i);
              v_null := FALSE;
           END IF;
        END LOOP;
     END IF;
  ELSE -- style=A cannot TOTAL at the end
     sm(p_max_col_no) := NULL;
  END IF;
  --if all columns are null then make TOTAL null
  IF v_null THEN
     sm(p_max_col_no) := NULL;
  END IF;
-------------------------------------------------------------------

------------------Testing purpose
  FOR j IN 1..p_row_agg_no+p_max_col_no LOOP
     --WDK: v_test is only 4096 characters big.  if bigger than that then do not want
     --to error out, so dump contents and continue
     IF (length(v_test)>4000) THEN
       IF (g_proc_level>=g_debug_level) THEN
          xtr_risk_debug_pkg.dlog('insert_row: ' || '',p_row||':'||v_test);
       END IF;
       v_test:='';
     END IF;
     IF j <= p_row_agg_no THEN
        v_test := v_test||':'||sh(j);
     ELSE
        v_test := v_test||':'||sm(j-p_row_agg_no);
     END IF;
  END LOOP;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('insert_row: ' || '',p_row||':'||v_test);
  END IF;
------------------End Testing purpose

  --format the tot, ccy to be append-ready (for now formatting is done in SQL)
  IF p_tot_currency IS NOT NULL THEN
     v_tot_currency_label := ' ('||p_tot_currency||')';
     v_tot_currency := p_tot_currency;
  END IF;

  IF p_row_agg_no<=5 AND p_max_col_no<=20 THEN
     IF sh.COUNT<5 THEN
        sh.EXTEND(5-p_row_agg_no);
     END IF;
     IF sm.COUNT<20 THEN
        sm.EXTEND(20-p_max_col_no);
     END IF;
     INSERT INTO qrm_saved_analyses_row(analysis_name,seq_no,type,hidden,
tot_currency,tot_currency_label,a1,a2,a3,a4,a5,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,
m16,m17,m18,m19,m20,created_by,creation_date,last_updated_by,last_update_date,
last_update_login)
VALUES(p_name,p_row,p_type,p_hidden,v_tot_currency,v_tot_currency_label,
sh(1),sh(2),sh(3),sh(4),
sh(5),sm(1),sm(2),sm(3),sm(4),sm(5),sm(6),sm(7),sm(8),sm(9),sm(10),sm(11),
sm(12),sm(13),sm(14),sm(15),sm(16),sm(17),sm(18),sm(19),sm(20),
FND_GLOBAL.user_id,p_ref_date,FND_GLOBAL.user_id,p_ref_date,
FND_GLOBAL.login_id);

  ELSIF p_row_agg_no<=10 AND p_max_col_no<=50 THEN
     IF sh.COUNT<10 THEN
        sh.EXTEND(10-p_row_agg_no);
     END IF;
     IF sm.COUNT<50 THEN
        sm.EXTEND(50-p_max_col_no);
     END IF;
     INSERT INTO qrm_saved_analyses_row(analysis_name,seq_no,type,hidden,
tot_currency,tot_currency_label,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,m1,m2,m3,m4,
m5,m6,m7,m8,m9,m10,m11,
m12,m13,m14,m15,m16,m17,m18,m19,m20,m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,
m31,m32,m33,m34,m35,m36,m37,m38,m39,m40,m41,m42,m43,m44,m45,m46,m47,m48,m49,
m50,created_by,creation_date,last_updated_by,last_update_date,
last_update_login)
VALUES(p_name,p_row,p_type,p_hidden,v_tot_currency,v_tot_currency_label,
sh(1),sh(2),sh(3),sh(4),
sh(5),sh(6),sh(7),sh(8),sh(9),sh(10),sm(1),sm(2),sm(3),sm(4),sm(5),sm(6),sm(7),
sm(8),sm(9),sm(10),sm(11),sm(12),sm(13),sm(14),sm(15),sm(16),sm(17),sm(18),
sm(19),sm(20),sm(21),sm(22),sm(23),sm(24),sm(25),sm(26),sm(27),sm(28),sm(29),
sm(30),sm(31),sm(32),sm(33),sm(34),sm(35),sm(36),sm(37),sm(38),sm(39),sm(40),
sm(41),sm(42),sm(43),sm(44),sm(45),sm(46),sm(47),sm(48),sm(49),sm(50),
FND_GLOBAL.user_id,p_ref_date,FND_GLOBAL.user_id,p_ref_date,
FND_GLOBAL.login_id);

  ELSE --p_row_agg_no<=16 AND p_max_col_no<=100
     IF sh.COUNT<16 THEN
        sh.EXTEND(16-p_row_agg_no);
     END IF;
     IF sm.COUNT<100 THEN
        sm.EXTEND(100-p_max_col_no);
     END IF;
     INSERT INTO qrm_saved_analyses_row(analysis_name,seq_no,type,hidden,
tot_currency,tot_currency_label,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,
a14,a15,a16,m1,m2,m3,
m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19,m20,m21,m22,m23,m24,
m25,m26,m27,m28,m29,m30,m31,m32,m33,m34,m35,m36,m37,m38,m39,m40,m41,m42,m43,
m44,m45,m46,m47,m48,m49,m50,m51,m52,m53,m54,m55,m56,m57,m58,m59,m60,m61,m62,
m63,m64,m65,m66,m67,m68,m69,m70,m71,m72,m73,m74,m75,m76,m77,m78,m79,m80,m81,
m82,m83,m84,m85,m86,m87,m88,m89,m90,m91,m92,m93,m94,m95,m96,m97,m98,m99,m100,
created_by,creation_date,last_updated_by,last_update_date,last_update_login)
VALUES(p_name,p_row,p_type,p_hidden,v_tot_currency,v_tot_currency_label,
sh(1),sh(2),sh(3),sh(4),
sh(5),sh(6),sh(7),sh(8),sh(9),sh(10),sh(11),sh(12),sh(13),sh(14),sh(15),sh(16),
sm(1),sm(2),sm(3),sm(4),sm(5),sm(6),sm(7),sm(8),sm(9),sm(10),sm(11),sm(12),
sm(13),sm(14),sm(15),sm(16),sm(17),sm(18),sm(19),sm(20),sm(21),sm(22),sm(23),
sm(24),sm(25),sm(26),sm(27),sm(28),sm(29),sm(30),sm(31),sm(32),sm(33),sm(34),
sm(35),sm(36),sm(37),sm(38),sm(39),sm(40),sm(41),sm(42),sm(43),sm(44),sm(45),
sm(46),sm(47),sm(48),sm(49),sm(50),sm(51),sm(52),sm(53),sm(54),sm(55),sm(56),
sm(57),sm(58),sm(59),sm(60),sm(61),sm(62),sm(63),sm(64),sm(65),sm(66),sm(67),
sm(68),sm(69),sm(70),sm(71),sm(72),sm(73),sm(74),sm(75),sm(76),sm(77),sm(78),
sm(79),sm(80),sm(81),sm(82),sm(83),sm(84),sm(85),sm(86),sm(87),sm(88),sm(89),
sm(90),sm(91),sm(92),sm(93),sm(94),sm(95),sm(96),sm(97),sm(98),sm(99),sm(100),
FND_GLOBAL.user_id,p_ref_date,FND_GLOBAL.user_id,p_ref_date,
FND_GLOBAL.login_id);
  END IF;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dlog('DML','Inserted into QRM_SAVED_ANALYSES_ROW',
        'QRM_PA_AGGREGATION_P.INSERT_ROW',g_event_level);
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.INSERT_ROW');
  END IF;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     IF (g_ERROR_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','UNEXPECTED',
	   'QRM_PA_AGGREGATION_P.INSERT_ROW',G_ERROR_LEVEL);
     END IF;
     RETURN FALSE;
END insert_row;



/***************************************************************
This procedure constructs dynamic SQL statement that does the
aggregation.
***************************************************************/
PROCEDURE create_cursor (p_name VARCHAR2,
                p_style VARCHAR2,
                p_analysis_type VARCHAR2,
                p_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_type IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                p_nom IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_denom IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                p_tot_avg SYSTEM.QRM_VARCHAR_TABLE,
                p_sql OUT NOCOPY VARCHAR2,
                p_sql_col OUT NOCOPY VARCHAR2,
                p_row_agg_no OUT NOCOPY NUMBER,
                p_measure_no IN OUT NOCOPY NUMBER,
                p_origin IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                p_tb_calc_used IN OUT NOCOPY BOOLEAN,
                p_tb_calc_used_col IN OUT NOCOPY BOOLEAN,
                p_need_usd_arr BOOLEAN,
                p_ccy_suffix VARCHAR2,
                p_ccy_multiplier NUMBER,
                p_amount SYSTEM.QRM_VARCHAR_TABLE,
                p_table_col_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_num_denom_origin IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
		p_curr_reporting VARCHAR2,
		p_sensitivity SYSTEM.QRM_VARCHAR_TABLE) IS

  --IMPORTANT: v_act_agg include multiplier
  v_act_agg SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_agg_usd SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_origin_usd SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_nom_fl_usd SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_denom_fl_usd SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_num_denom_origin_usd SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_from VARCHAR2(100):=' FROM qrm_deal_calculations dc,qrm_deals_analyses da,qrm_current_deals_v v';
  v_where VARCHAR2(255):=' WHERE da.deal_calc_id=dc.deal_calc_id AND da.analysis_name=:analysis_name AND dc.deal_no=v.deal_no AND dc.transaction_no=v.transaction_no';
  i NUMBER(5);
  j NUMBER(5);
  v_aggregate_level NUMBER(5);
  --whether qrm_saved_analyses_col is used or not
  v_col_used BOOLEAN := FALSE;
  --whether qrm_deal_calculations is used or not for p_sql_col
  v_table_used_col BOOLEAN := FALSE;
  v_origin VARCHAR2(1);
  v_col_name VARCHAR2(200);
  --Special indicators to treat DEAL_SUBTYPE
  v_deal_subtype BOOLEAN := FALSE;
  v_deal_subtype_col BOOLEAN := FALSE;
  v_where_col VARCHAR2(255);

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.CREATE_CURSOR');
  END IF;

  --call get_actual_column_name proc
  IF p_style<>'T' THEN
     get_actual_column_name(p_name,p_amount,p_agg,v_act_agg,
                        p_nom,p_denom,v_agg_usd,
                        v_nom_fl_usd,v_denom_fl_usd,p_ccy_suffix,
                        p_ccy_multiplier,p_need_usd_arr,p_origin,v_origin_usd,
			p_num_denom_origin,v_num_denom_origin_usd,
			p_type, p_sensitivity);
  ELSE
     --for style='T', the p_agg already contains the actual att. name
     --hence just need to append ccy multiplier and copy them to v_act_agg
     v_act_agg.EXTEND(p_agg.COUNT);
     FOR i IN 1..p_agg.COUNT LOOP
        --NULL in p_table_col_curr means that it 's converted to
        --Reporting Currency.
        --Those are the one that we need to attach multiplier on.
        v_act_agg(i) := p_agg(i);
        IF p_table_col_curr(i) IS NULL THEN
           --NULL means value is converted to reporting currency
           p_table_col_curr(i) := p_curr_reporting;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('create_cursor: ' || 'p_ccy_multiplier',p_ccy_multiplier);
END IF;
           --ccy multiplier only applicable to amount type
           IF p_ccy_multiplier IS NOT NULL AND p_amount(i)='Y' THEN
              v_act_agg(i) := v_act_agg(i)||'*TO_NUMBER('''||p_ccy_multiplier||''')';
              p_nom(i) := p_nom(i)||'*TO_NUMBER('''||p_ccy_multiplier||''')';
           END IF;
        END IF;
     END LOOP;
  END IF;
-----------Testing
FOR i IN 1..v_act_agg.COUNT LOOP
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dlog('create_cursor: ' || 'v_act_agg(i)',i||':'||v_act_agg(i));
   END IF;
END LOOP;
-----------End Testing

  --see whether we need join with qrm_save_analyses_col or not
  --style Crosstab Timebuckets and Crosstab need to join
  IF p_style IN ('C','X') THEN
     v_col_used := TRUE;
  END IF;
  --need to construct p_sql_col for style='C'
  IF p_style='C' THEN
     p_sql_col := 'SELECT DISTINCT ';
  END IF;
  p_sql := 'SELECT ';

  FOR j IN 1..v_act_agg.COUNT LOOP
     --for cross-tab and aggregated-table
     --IF (p_style='C') OR (p_style='A') THEN
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('create_cursor: ' || 'j:v_act_agg(j)',j||':'||v_act_agg(j));
   xtr_risk_debug_pkg.dlog('create_cursor: ' || 'j:p_type(j)',j||':'||p_type(j));
END IF;
     IF p_type(j)='R' THEN
        --check whether att. is from table or view
        IF p_origin(j)='T' THEN
           p_sql := p_sql||'dc.'||v_act_agg(j);
        ELSIF p_origin(j)='V' THEN
           --check for deal_subtype
           --SELECT dst.user_deal_subtype deal_subtype
           IF v_act_agg(j)='DEAL_SUBTYPE' THEN
              p_sql := p_sql||'dst.user_deal_subtype '||v_act_agg(j);
              v_deal_subtype := TRUE;
           ELSE
              p_sql := p_sql||'v.'||v_act_agg(j);
           END IF;
        ELSE --IF p_origin(j)='B'
           p_sql := p_sql||'tb.'||v_act_agg(j);
           p_tb_calc_used := TRUE;
        END IF;

        --find the aggregate level, if the next aggregate is of type M
        IF p_type(j+1)<>'R' THEN
           p_row_agg_no := j;
           IF p_style='A' THEN
              v_aggregate_level := j;
           END IF;
        END IF;
--xtr_risk_debug_pkg.dlog('p_row_agg_no',p_row_agg_no);
        --if style = X and the next one is Measure then v_aggregate_level=j
        IF p_style='X' AND p_type(j+1)='M' THEN
           p_sql := p_sql||',c.seq_no';
           v_aggregate_level := j;
        END IF;

     ELSIF p_type(j)='C' THEN --only style=C has type=C
        p_sql := p_sql||'c.seq_no';
        --dynamic sql for column header
        --check whether att. is from table or view
        IF p_origin(j)='T' THEN
           p_sql_col := p_sql_col||'dc.'||v_act_agg(j);
           v_table_used_col := TRUE;
           --exclude the null value
           v_where_col := v_where_col||' AND dc.'||v_act_agg(j)||' IS NOT NULL';
        ELSIF p_origin(j)='V' THEN
           --check for deal_subtype
           --SELECT dst.user_deal_subtype deal_subtype
           IF v_act_agg(j)='DEAL_SUBTYPE' THEN
              p_sql_col := p_sql_col||'dst.user_deal_subtype '||v_act_agg(j);
              v_deal_subtype := TRUE;
              v_deal_subtype_col := TRUE;
           ELSE
              p_sql_col := p_sql_col||'v.'||v_act_agg(j);
           END IF;
           --exclude the null value
           v_where_col := v_where_col||' AND v.'||v_act_agg(j)||' IS NOT NULL';
        ELSE --IF p_origin(j)='B'
--xtr_risk_debug_pkg.dlog('C->B: v_act_agg(j)',v_act_agg(j));
           p_sql_col := p_sql_col||'tb.'||v_act_agg(j);
           p_tb_calc_used := TRUE;
           p_tb_calc_used_col := TRUE;
           --exclude the null value
           v_where_col := v_where_col||' AND tb.'||v_act_agg(j)||' IS NOT NULL';
        END IF;

        --find the aggregate level, if the next aggregate is of type M
        --if so then we found the no. of aggregate level
        IF p_type(j+1)='M' THEN
           v_aggregate_level := j;
        END IF;

     --p_type(j)='M' AND
     ELSIF v_act_agg(j) IN ('NUMBER_DEALS','NUMBER_DEALS_USD','NUMBER_DEALS_SOB') THEN
        --this attribute calculate the number of deals aggregated/displayed
        IF p_style='T' THEN --just put 1 bec. 1 row represent 1 deal
           p_sql := p_sql||'1,NULL';
        ELSE
           p_sql := p_sql||'COUNT(*),NULL';
        END IF;
        p_measure_no := p_measure_no+2;
        IF p_need_usd_arr THEN
           p_sql := p_sql||',NULL,NULL';
           p_measure_no := p_measure_no+2;
        END IF;

     --p_type(j)='M' AND
--xtr_risk_debug_pkg.dlog('M->T: j:v_act_agg,p_origin,p_tot_avg=',j||':'||v_act_agg(j)||','||p_origin(j)||','||p_tot_avg(j));
     ELSIF v_act_agg(j) IS NOT NULL AND p_tot_avg(j)='T' THEN
        IF p_origin(j)='T' THEN
           p_sql := p_sql||'SUM(dc.'||v_act_agg(j)||'),NULL';
        ELSIF p_origin(j)='V' THEN
           p_sql := p_sql||'SUM(v.'||v_act_agg(j)||'),NULL';
        ELSE --IF p_origin(j)='B'
           p_sql := p_sql||'SUM(tb.'||v_act_agg(j)||'),NULL';
           p_tb_calc_used := TRUE;
        END IF;
        p_measure_no := p_measure_no+2;
        --if style = X then v_aggregate_level=j-1
        IF p_need_usd_arr THEN
           --first find the origin bec. col+'_usd' may be different from
           --the original
           v_col_name := v_act_agg(j)||'_USD';
--xtr_risk_debug_pkg.dlog('M->T: v_col_name=',v_col_name);
--xtr_risk_debug_pkg.dlog('M->T: v_origin=',v_origin);
--xtr_risk_debug_pkg.dlog('M->T: v_origin_usd(j)=',v_origin_usd(j));
--xtr_risk_debug_pkg.dlog('M->T: v_agg_usd(j)=',v_agg_usd(j));
           IF v_origin_usd(j)='T' THEN
              p_sql := p_sql||',SUM(dc.'||v_agg_usd(j)||'),NULL';
           ELSIF v_origin_usd(j)='V' THEN
              p_sql := p_sql||',SUM(v.'||v_agg_usd(j)||'),NULL';
           ELSE --IF v_origin_usd(j)='B'
              p_sql := p_sql||',SUM(tb.'||v_agg_usd(j)||'),NULL';
              p_tb_calc_used := TRUE;
           END IF;
           p_measure_no := p_measure_no+2;
        END IF;
--xtr_risk_debug_pkg.dlog('p_measure_no',p_measure_no);
     --p_type(j)='M' AND
     ELSIF v_act_agg(j) IS NOT NULL AND p_tot_avg(j)='A' THEN
--xtr_risk_debug_pkg.dlog('M->A: v_act_agg',v_act_agg(j));
        IF p_nom(j) IS NULL THEN
           p_nom(j) := 'NULL';
        END IF;
        IF p_denom(j) IS NULL THEN
           p_denom(j) := 'NULL';
        END IF;
        p_sql := p_sql||p_nom(j)||','||p_denom(j);
        IF p_num_denom_origin(j) IN ('2','3') THEN
           p_tb_calc_used := TRUE;
        END IF;
        p_measure_no := p_measure_no+2;
        --if style = X then v_aggregate_level=j-1
--xtr_risk_debug_pkg.dlog('j,v_nom_fl_usd.COUNT',j||','||v_nom_fl_usd.COUNT);
        IF p_need_usd_arr THEN
--xtr_risk_debug_pkg.dlog('M->T: v_nom_fl_usd(j)=',v_nom_fl_usd(j));
           IF v_nom_fl_usd(j) IS NULL THEN
              v_nom_fl_usd(j) := 'NULL';
           END IF;
--xtr_risk_debug_pkg.dlog('M->T: v_denom_fl_usd(j)=',v_denom_fl_usd(j));
           IF v_denom_fl_usd(j) IS NULL THEN
              v_denom_fl_usd(j) := 'NULL';
           END IF;
           p_sql := p_sql||','||v_nom_fl_usd(j)||','||v_denom_fl_usd(j);
           IF v_num_denom_origin_usd(j) IN ('2','3') THEN
              p_tb_calc_used := TRUE;
           END IF;
           p_measure_no := p_measure_no+2;
        END IF;
     ELSE
        p_sql := p_sql||'NULL,NULL';
        p_measure_no := p_measure_no+2;
     END IF;
     --add comma unless the end of SELECT clause
     IF j < v_act_agg.COUNT THEN
        p_sql := p_sql||',';
     END IF;
  END LOOP; --v_act_agg LOOP

  --Construct p_sql_col
  IF p_style='C' THEN
     --add BULK COLLECT clause for p_sql_col
     j := 0;
     p_sql_col := p_sql_col||' BULK COLLECT INTO ';
     FOR i IN 1..v_aggregate_level LOOP
        IF p_type(i)='C' THEN
           j := j+1;
           IF j>1 THEN
              p_sql_col := p_sql_col||',';
           END IF;
           p_sql_col := p_sql_col||':'||TO_CHAR(j);
        END IF;
     END LOOP;

     --add FROM clause for p_sql_col
     p_sql_col := p_sql_col||v_from;
     IF p_tb_calc_used_col THEN
        p_sql_col := p_sql_col||',qrm_tb_calculations tb';
     END IF;
     --FROM ...,xtr_deal_subtypes dst
     IF v_deal_subtype_col THEN
        p_sql_col := p_sql_col||',xtr_deal_subtypes dst';
     END IF;

     --add WHERE clause for p_sql_col
     p_sql_col := p_sql_col||v_where||v_where_col;
     IF p_tb_calc_used_col THEN
        --p_sql_col := p_sql_col||' AND dc.deal_no=tb.deal_no AND dc.transaction_no=tb.transaction_no'; --bug 2550158
        p_sql_col := p_sql_col||' AND dc.deal_no=tb.deal_no AND dc.transaction_no=tb.transaction_no AND dc.market_data_set = tb.market_data_set'; --bug 2550158
        IF p_analysis_type='P' THEN
	   --Bug 2318165 no.7
           p_sql_col := p_sql_col||' AND (tb.pos_start_date IS NULL OR :end_date>=tb.pos_start_date) AND (tb.pos_end_date IS NULL OR :end_date<tb.pos_end_date)'; --bug 3085258
        ELSIF p_analysis_type='G' THEN
           p_sql_col := p_sql_col||' AND (tb.start_date IS NULL OR NVL(dc.gap_date,:ref_date+1)>=tb.start_date) AND NVL(dc.gap_date,:ref_date+1)<=tb.end_date';--bug 2638277
           --p_sql_col := p_sql_col||' AND (tb.start_date IS NULL OR NVL(dc.gap_date,:ref_date+1)>=tb.start_date) AND NVL(dc.gap_date,:ref_date+1)<tb.end_date';--bug 2638277
        ELSE --p_analysis_type='M' THEN
           --p_sql_col := p_sql_col||' AND (tb.start_date IS NULL OR NVL(v.end_date,:ref_date+1)>=tb.start_date) AND NVL(v.end_date,:ref_date+1)<tb.end_date';
           --bug 2637950
           p_sql_col := p_sql_col||' AND ((v.start_date>=(:ref_date+1) AND NVL(v.end_date,v.start_date+1)>=tb.start_date AND NVL(v.end_date,v.start_date+1)<=tb.end_date)'||
                                     ' OR (v.start_date< (:ref_date+1) AND NVL(v.end_date,:ref_date+1)>=tb.start_date AND NVL(v.end_date,:ref_date+1)<=tb.end_date))';
        END IF;
     END IF;
     --WHERE ... AND dst.deal_subtype=v.deal_subtype
     IF v_deal_subtype_col THEN
        p_sql_col := p_sql_col||' AND dst.deal_subtype=v.deal_subtype';
     END IF;

     --add ORDER BY clause for p_sql_col
     j := 0;
     p_sql_col := p_sql_col||' ORDER BY ';
     FOR i IN 1..v_aggregate_level LOOP
        IF p_type(i)='C' THEN
           j := j+1;
           IF j>1 THEN
              p_sql_col := p_sql_col||',';
           END IF;
           p_sql_col := p_sql_col||TO_CHAR(j);
        END IF;
     END LOOP;
     p_sql_col := p_sql_col||';';
  END IF;

  --add FROM clause
  p_sql := p_sql||v_from;
  IF v_col_used THEN
     p_sql := p_sql||','||'qrm_saved_analyses_col c';
  END IF;
  IF p_tb_calc_used THEN
     p_sql := p_sql||','||'qrm_tb_calculations tb';
  END IF;
  --FROM ...,xtr_deal_subtypes dst
  IF v_deal_subtype THEN
     p_sql := p_sql||',xtr_deal_subtypes dst';
  END IF;

  --add WHERE clause
  p_sql := p_sql||v_where;
  IF v_col_used THEN
     p_sql := p_sql||' AND c.analysis_name=da.analysis_name';
     --
     IF p_style='C' THEN
        p_sql := p_sql||' AND c.seq_no_key=';
        FOR j IN 1..v_aggregate_level LOOP
           IF p_type(j)='C' THEN
              --check whether att. is from table or view
              IF p_origin(j)='T' THEN
                 p_sql := p_sql||'dc.'||v_act_agg(j);
              ELSIF p_origin(j)='V' THEN
                 IF v_deal_subtype_col THEN
                    p_sql := p_sql||'dst.user_deal_subtype';
                 ELSE
                    p_sql := p_sql||'v.'||v_act_agg(j);
                 END IF;
              ELSE --p_origin(j)='B' THEN
                 p_sql := p_sql||'tb.'||v_act_agg(j);
              END IF;
           END IF;
        END LOOP;
     END IF;
  END IF;
  IF p_style='X' AND p_analysis_type='P' THEN
     p_sql := p_sql||' AND v.deal_date<=c.end_date AND (v.end_date IS NULL OR c.end_date<=v.end_date)';
  ELSIF p_style='X' AND p_analysis_type='G' THEN
     p_sql := p_sql||' AND NVL(dc.gap_date,:ref_date+1)>=c.start_date AND NVL(dc.gap_date,:ref_date+1)<=c.end_date';--bug 2638277
     --p_sql := p_sql||' AND NVL(dc.gap_date,:ref_date+1)>=c.start_date AND NVL(dc.gap_date,:ref_date+1)<c.end_date';--bug 2638277
  ELSIF p_style='X' AND p_analysis_type='M' THEN
     --p_sql := p_sql||' AND c.start_date<=NVL(v.end_date,:ref_date+1) AND NVL(v.end_date,:ref_date+1)<c.end_date';
     --bug 2637950
     p_sql := p_sql||' AND ((v.start_date>=(:ref_date+1) AND NVL(v.end_date,v.start_date+1)>=c.start_date AND NVL(v.end_date,v.start_date+1)<=c.end_date)'||
                       ' OR (v.start_date< (:ref_date+1) AND NVL(v.end_date,:ref_date+1)>=c.start_date AND NVL(v.end_date,:ref_date+1)<=c.end_date))';
  END IF;
  IF p_tb_calc_used THEN
     --p_sql := p_sql||' AND dc.deal_no=tb.deal_no AND dc.transaction_no=tb.transaction_no'; --bug 2550158
     p_sql := p_sql||' AND dc.deal_no=tb.deal_no AND dc.transaction_no=tb.transaction_no AND dc.market_data_set = tb.market_data_set'; --bug 2550158
     IF p_style='X' THEN
        IF p_analysis_type='P' THEN
           p_sql := p_sql||' AND (c.end_date>=tb.pos_start_date OR tb.pos_start_date IS NULL) AND (tb.pos_end_date IS NULL OR c.end_date<tb.pos_end_date)';
        ELSE
           --p_sql := p_sql||' AND (c.end_date>=tb.start_date OR tb.start_date IS NULL) AND c.end_date<=tb.end_date'; --bug 2638277
           p_sql := p_sql||' AND (c.start_date<=tb.end_date OR tb.start_date IS NULL) AND c.end_date>=tb.end_date'||
                           ' AND (NVL(v.end_date,:ref_date+1)>=tb.start_date OR tb.start_date IS NULL) AND NVL(v.end_date,:ref_date+1)<=tb.end_date'; --bug 2638277
        END IF;
     ELSE --single period
        IF p_analysis_type='P' THEN
        --Bug 2318165 no.7
           p_sql := p_sql||' AND (tb.pos_start_date IS NULL OR :end_date>=tb.pos_start_date) AND (tb.pos_end_date IS NULL OR :end_date<tb.pos_end_date)'; --bug 3085258
        ELSIF p_analysis_type='G' THEN
           p_sql := p_sql||' AND (tb.start_date IS NULL OR NVL(dc.gap_date,:ref_date+1)>=tb.start_date) AND NVL(dc.gap_date,:ref_date+1)<=tb.end_date'; --bug 2638277
           --p_sql := p_sql||' AND (tb.start_date IS NULL OR NVL(dc.gap_date,:ref_date+1)>=tb.start_date) AND NVL(dc.gap_date,:ref_date+1)<tb.end_date'; --bug 2638277
        ELSE --p_analysis_type='M' THEN
           --p_sql := p_sql||' AND (tb.start_date IS NULL OR NVL(v.end_date,:ref_date+1)>=tb.start_date) AND NVL(v.end_date,:ref_date+1)<tb.end_date';
           --bug 2637950
           p_sql := p_sql||' AND ((v.start_date>=(:ref_date+1) AND NVL(v.end_date,v.start_date+1)>=tb.start_date AND NVL(v.end_date,v.start_date+1)<=tb.end_date)'||
                             ' OR (v.start_date< (:ref_date+1) AND NVL(v.end_date,:ref_date+1)>=tb.start_date AND NVL(v.end_date,:ref_date+1)<=tb.end_date))';
        END IF;
     END IF;
  END IF;
  --WHERE ... AND dst.deal_subtype=v.deal_subtype
  IF v_deal_subtype THEN
     p_sql := p_sql||' AND dst.deal_subtype=v.deal_subtype AND dst.deal_type=v.deal_type';
  END IF;

  IF p_style<>'T' THEN
     --add GROUP BY clause
     p_sql := p_sql||' GROUP BY ';
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('create_cursor: ' || 'v_aggregate_level',v_aggregate_level);
END IF;
     FOR j IN 1..v_aggregate_level LOOP
--xtr_risk_debug_pkg.dlog('v_act_agg(j)',j||':'||v_act_agg(j));
        --check whether att. is from table or view
        IF p_type(j)<>'C' THEN
           IF p_origin(j)='T' THEN
              p_sql := p_sql||'dc.'||v_act_agg(j);
           ELSIF p_origin(j)='V' THEN
              IF v_act_agg(j)='DEAL_SUBTYPE' THEN
                p_sql := p_sql||'dst.user_deal_subtype';
              ELSE
                p_sql := p_sql||'v.'||v_act_agg(j);
              END IF;
           ELSE --IF p_origin(j)='B'
              p_sql := p_sql||'tb.'||v_act_agg(j);
           END IF;
        ELSE --group by seq_no
           p_sql := p_sql||'c.seq_no';
        END IF;
        --special case where style=X
        IF p_style='X' AND p_type(j)='R' AND p_type(j+1)='M' THEN
           p_sql := p_sql||',c.seq_no';
        END IF;
        --put coma if not the end of Group By clause
        IF j<v_aggregate_level THEN
           p_sql := p_sql||',';
        END IF;
     END LOOP;

     --add ORDER BY clause
     p_sql := p_sql||' ORDER BY ';
     FOR j IN 1..v_aggregate_level LOOP
        p_sql := p_sql||TO_CHAR(j);
        IF j<v_aggregate_level THEN
           p_sql := p_sql||',';
        END IF;
     END LOOP;
  END IF; --p_style<>'T'

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PORTFOLIO_ANALYSIS.CREATE_CURSOR');
  END IF;
END create_cursor;



/***************************************************************
This function is the main function that does aggregation,
transformation of the data and saving them into the
qrm_saved_analyses_row and qrm_saved_analyses_col tables.
***************************************************************/
FUNCTION transform_and_save (p_name VARCHAR2,
                                p_ref_date DATE,
				p_caller_flag VARCHAR2)
				--'OA' if called from OA
				--'CONC' if called from Concurrent Program
        RETURN VARCHAR2 IS --'T' if success or 'F' for unsuccessful

  v_start_date SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
  v_end_date SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
  v_col SYSTEM.QRM_VARCHAR_table;
  v_col_seq_no xtr_md_num_table := xtr_md_num_table();
  v_col_name_map SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_percent_col_name_map SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_a1 SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_col_hidden SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_col_type xtr_md_num_table := xtr_md_num_table();
  v_col_seq_no_key SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_col_order xtr_md_num_table;
  v_col_ccy_multp xtr_md_num_table := xtr_md_num_table();--Bug 2566711

  v_header SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_measure xtr_md_num_table := xtr_md_num_table();
  v_save_header SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_save_measure xtr_md_num_table := xtr_md_num_table();
  v_nom xtr_md_num_table := xtr_md_num_table();
  v_denom xtr_md_num_table := xtr_md_num_table();
  v_nom_usd xtr_md_num_table := xtr_md_num_table();
  v_denom_usd xtr_md_num_table := xtr_md_num_table();
  v_origin SYSTEM.QRM_VARCHAR_table;
  v_tb_label_arr SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_num_denom_origin SYSTEM.QRM_VARCHAR_TABLE;

  v_sql VARCHAR2(4000);
  v_sql_col VARCHAR2(4000);
  v_max_col_no NUMBER(5):=0; --actual column span length excluding rowheader
  v_row_agg_no NUMBER(5); --no of levels of row agg.
  --for C style means no of levels of col agg.
  --for A style means no of aggregated col.
  v_col_agg_no NUMBER(5) := 1;
  v_measure_no NUMBER(5) := 0; --no of measure columns in the SQL statement
  --no of measure columns+other number type columns in the SQL statement
  v_all_meas_no NUMBER(5);

  v_date_type VARCHAR2(1);
  v_as_of_date DATE;--=v_start_date_fix
  v_start_date_ref VARCHAR2(2);
  v_start_date_offset NUMBER;
  v_start_offset_type VARCHAR2(1);
  v_end_date_fix DATE;
  v_end_date_ref VARCHAR2(2);
  v_end_date_offset NUMBER;
  v_end_offset_type VARCHAR2(1);
  v_tb_name VARCHAR2(20);
  v_tb_label VARCHAR2(1);
  v_style VARCHAR2(1);
  v_analysis_type VARCHAR2(1);
  v_calendar_id NUMBER(15);
  v_business_week VARCHAR2(1);
  v_currency_source VARCHAR2(1);
  v_curr_reporting VARCHAR2(15);
  v_md_set_code VARCHAR2(20);
  v_sens_exist BOOLEAN := FALSE; --whether the meas. contains sens.meas.
  v_sens_flag NUMBER(1);
  v_tb_calc_used BOOLEAN := FALSE;
  v_tb_calc_used_col BOOLEAN := FALSE;
----------CCY Variables------------
  v_ccy_suffix VARCHAR2(20); --suffix to be appended to att.(i.e. '_USD')
  v_ccy_multiplier NUMBER; --the FX rate between USD and other CCY
  --Flag for v_ccy_case_flag:
  --NULL = never tested
  --1 = 1 ccy for the whole analysis
  --0 = >1 ccy for the whole analysis(>1 ccy in each col. for style=A)
  --2 = >1 ccy for the whole analysis but 1 ccy in each col (style=A)
  v_ccy_case_flag NUMBER(1);
  --whether ccy/company is part of the agg.,depending on ccy pref(DEAL/SOB)
  --Flag for v_ccy_agg_flag:
  --NULL = never tested
  --1 = CCY (or COMPANY_CODE) is part of the aggregates
  --0 = CCY (or COMPANY_CODE) is not part of the aggregates
  --2 = CCY (or COMPANY_CODE) is part of row agg
  --3 = CCY (or COMPANY_CODE) is part of col agg
  v_ccy_agg_flag NUMBER(1);
  v_ccy_agg_level NUMBER(5);
  v_underlying_ccy VARCHAR2(15);--the ccy in the case of 1 underlying ccy used
  v_need_usd_arr BOOLEAN;
  v_current_ccy VARCHAR2(15);--the current ccy when CCY is aggregate
  v_row_ccy VARCHAR2(15);--the ccy of the last row with v_header(ccy_agg_level)
  --dummy variable used for style='T' required for get_underlying_currency
  v_table_col_curr SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_agg_col_curr SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
----------End CCY Variables--------
  CURSOR analysis_data IS
     SELECT analysis_type, style, tb_label, tb_name, date_type, start_date,
        start_date_ref, start_date_offset, start_offset_type, end_date,
        end_date_ref, end_date_offset, end_offset_type, business_week,
        gl_calendar_id,currency_source,curr_reporting,md_set_code
     FROM qrm_analysis_settings
     WHERE analysis_name=p_name AND history_flag='S';

  CURSOR attribute_data IS
     SELECT DECODE(a.type,'R',1,'C',2,'M',3,4) seq, a.att_order,
        a.attribute_name, a.type, a.total_average, a.percentage, l.numerator,
        l.denominator, l.origin, l.amount, l.ccy_aggregate, l.sensitivity,
	l.num_denom_origin
     FROM qrm_analysis_atts a, qrm_ana_atts_lookups l
     WHERE a.attribute_name=l.attribute_name AND a.analysis_name=p_name
     AND history_flag='S'
     ORDER BY 1,2;

  CURSOR count_max_col_no IS
     SELECT COUNT(*) FROM qrm_saved_analyses_col
        WHERE analysis_name=p_name
        AND type>-2;

  v_agg SYSTEM.QRM_VARCHAR240_TABLE;
  --array of the actual column names including currency conversion
  --to be inserted into the DYNAMIC SQL
  v_att_type SYSTEM.QRM_VARCHAR_table;
  v_nom_fl SYSTEM.QRM_VARCHAR240_TABLE;
  v_denom_fl SYSTEM.QRM_VARCHAR240_TABLE;
  v_tot_avg SYSTEM.QRM_VARCHAR_table;
  v_percent SYSTEM.QRM_VARCHAR_table;
  v_dummy1 xtr_md_num_table;
  v_amount SYSTEM.QRM_VARCHAR_table;
  v_ccy_aggregate SYSTEM.QRM_VARCHAR_table;
  v_sensitivity SYSTEM.QRM_VARCHAR_table;

  i NUMBER(5);
  j NUMBER(5);
  k NUMBER(5);
  m NUMBER(5);
  n NUMBER(5);
  v_row NUMBER(5) := 0;
  v_new_row BOOLEAN;
  v_type NUMBER(5);
  v_hidden VARCHAR(1);
  v_divisor NUMBER := 0.000001;

  --the row agg level which is totaled up to the previous level
  v_total_level NUMBER(5);
  v_cursor INT;
  v_rows_processed NUMBER;
  v_success BOOLEAN := TRUE;
  v_skip_row BOOLEAN;
-----------
--For col seq no 1
--CO.A NI USD
--L1   L2 L3 --=v_total_level
-----------

-------Testing parameters
dummy NUMBER;
v_test VARCHAR2(255);
-------End Testing parameters

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE');
  END IF;

  --initialize fnd_msg_pub if it has not been intialized
  IF p_caller_flag='OA' AND fnd_msg_pub.count_msg>0 THEN
     fnd_msg_pub.Initialize;
  END IF;

  --query analysis data
  OPEN analysis_data;
  FETCH analysis_data INTO v_analysis_type, v_style, v_tb_label, v_tb_name,
        v_date_type, v_as_of_date, v_start_date_ref, v_start_date_offset,
        v_start_offset_type, v_end_date_fix, v_end_date_ref, v_end_date_offset,
        v_end_offset_type, v_business_week, v_calendar_id, v_currency_source,
        v_curr_reporting, v_md_set_code;
  CLOSE analysis_data;

  --check whether analysis settings still there by looking whether the required
  --column value return IS NULL or not
  IF v_style IS NULL THEN
     FND_MESSAGE.SET_NAME('QRM','QRM_ANA_NO_SETTING');
     FND_MESSAGE.SET_TOKEN('ANALYSIS_NAME',p_name);
     RAISE e_pagg_no_setting_found;
  END IF;

  --DELETE existing saved data
  DELETE qrm_saved_analyses_row WHERE analysis_name=p_name;
  IF NOT (v_style='X' AND p_caller_flag='OA') THEN
     DELETE qrm_saved_analyses_col WHERE analysis_name=p_name;
  END IF;
  COMMIT;
--xtr_risk_debug_pkg.dlog('v_analysis_type',v_analysis_type);
--xtr_risk_debug_pkg.dlog('v_style',v_style);
--xtr_risk_debug_pkg.dlog('v_tb_label',v_tb_label);
--xtr_risk_debug_pkg.dlog('v_tb_name',v_tb_name);
--xtr_risk_debug_pkg.dlog('v_date_type',v_date_type);
--xtr_risk_debug_pkg.dlog('v_as_of_date',v_as_of_date);
--xtr_risk_debug_pkg.dlog('v_start_date_ref',v_start_date_ref);
--xtr_risk_debug_pkg.dlog('v_start_date_offset',v_start_date_offset);
--xtr_risk_debug_pkg.dlog('v_start_offset_type',v_start_offset_type);
--xtr_risk_debug_pkg.dlog('v_business_week',v_business_week);
--xtr_risk_debug_pkg.dlog('v_calendar_id',v_calendar_id);
  --query attributes data to from SQL statement
  OPEN attribute_data;
  FETCH attribute_data BULK COLLECT INTO v_dummy1,v_col_order,v_agg,v_att_type,
        v_tot_avg,v_percent,v_nom_fl,v_denom_fl,v_origin,v_amount,
        v_ccy_aggregate,v_sensitivity,v_num_denom_origin;
  CLOSE attribute_data;
--xtr_risk_debug_pkg.dlog('v_agg.COUNT',v_agg.COUNT);
  --use some logic to determine what the report underlying currency is
  --First, find if there is any AMOUNT type
  --bec. amount typemeas. are the only one that can be converted to diff ccy
  FOR i IN 1..v_amount.LAST LOOP
     IF v_amount(i)='Y' THEN
        get_underlying_currency(p_name,p_ref_date,v_style,v_md_set_code,
                        v_currency_source,v_curr_reporting,
                        v_amount,v_agg,v_ccy_aggregate,v_att_type,
                        v_col_order,v_ccy_suffix,
                        v_ccy_multiplier,v_ccy_agg_flag,v_underlying_ccy,
                        v_ccy_case_flag,v_agg(i),v_ccy_agg_level,
                        v_table_col_curr,v_agg_col_curr,
			NULL);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_ccy_suffix',v_ccy_suffix);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_ccy_multiplier',v_ccy_multiplier);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_ccy_case_flag',v_ccy_case_flag);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_ccy_agg_flag',v_ccy_agg_flag);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_ccy_agg_level',v_ccy_agg_level);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'After get_underlying_ccy: v_underlying_ccy',v_underlying_ccy);
END IF;
        --see whether need USD array container if Total CCY is diff.
        --from CCY used
        IF (v_ccy_case_flag=0 AND v_ccy_agg_flag>0) THEN
           v_need_usd_arr := TRUE;
        ELSE
           v_need_usd_arr := FALSE;
        END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_need_usd_arr',v_need_usd_arr);
END IF;
        EXIT;
     END IF;
  END LOOP;

  --Make sure that v_ccy_multiplier is not NULL when needed, otherwise,
  --throws exception
  IF v_ccy_multiplier IS NULL AND v_curr_reporting<>'USD' AND
    ((v_ccy_case_flag=0 AND v_ccy_agg_flag=0) OR v_currency_source='R' OR
     (v_ccy_case_flag=0 AND v_ccy_agg_flag IN (1,2) AND v_ccy_agg_level>1))
    THEN
     FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
     FND_MESSAGE.SET_TOKEN('CCY',v_curr_reporting);
     raise e_pagg_no_fxrate_found;
  END IF;
  --Update currency_used in qrm_analysis_settings
  IF v_ccy_case_flag=0 AND v_ccy_agg_flag=0 THEN --use curr_reporting
     UPDATE qrm_analysis_settings
        SET currency_used='R', last_updated_by=FND_GLOBAL.user_id,
	last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name AND history_flag='S';
  ELSE --use whatever in currency_source
     UPDATE qrm_analysis_settings
        SET currency_used=currency_source, last_updated_by=FND_GLOBAL.user_id,
	last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name AND history_flag='S';
  END IF;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_ANALYSIS_SETTINGS.CURRENCY_USED',
        'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_event_level);
  END IF;

  --Fix end date to be used later, alrady calculated and saved by FHU engine

  --construct the DYNAMIC SQL for the aggregate
  create_cursor(p_name,v_style,v_analysis_type,
                v_agg,v_att_type,v_nom_fl,v_denom_fl,v_tot_avg,
                v_sql,v_sql_col,v_row_agg_no,v_measure_no,v_origin,
                v_tb_calc_used,v_tb_calc_used_col,v_need_usd_arr,
                v_ccy_suffix,
                v_ccy_multiplier,v_amount,v_table_col_curr,v_num_denom_origin,
		v_curr_reporting,v_sensitivity);

IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'LENGTH(v_sql)',LENGTH(v_sql));
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_sql',v_sql);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_sql_col',v_sql_col);
END IF;

  IF v_style='X' AND p_caller_flag='OA' THEN
     OPEN count_max_col_no;
     FETCH count_max_col_no INTO v_max_col_no;
     CLOSE count_max_col_no;
     --there is no agg for column in qrm_analysis_atts for style=X
     v_col_agg_no := 0;
  ELSE
     --loop over the col. header cursor and populate qrm_saved_analyses_table
     v_col_seq_no.EXTEND(v_row_agg_no);
     v_col_seq_no_key.EXTEND(v_row_agg_no);
     v_col_name_map.EXTEND(v_row_agg_no);
     v_percent_col_name_map.EXTEND(v_row_agg_no);
    v_a1.EXTEND(v_row_agg_no);
     v_col_type.EXTEND(v_row_agg_no);
     v_col_hidden.EXTEND(v_row_agg_no);

     FOR j IN 1..v_agg.LAST LOOP
        --row aggreagate info on the column header
        IF v_att_type(j)='R' THEN
           v_col_seq_no(j) := j;
--Need to create a LOOP in case of multiple col. level
           v_col_seq_no_key(j) := v_agg(j);
           v_col_name_map(j) := 'A'||TO_CHAR(j);
           v_a1(j) := v_agg(j);
           v_col_type(j) := -2; --header type
           v_col_hidden(j) := 'N';
        --column
        ELSIF v_att_type(j)='C' THEN
           --include col. agg. values  in the column header
           --only v_style='C' has att_type='C'
           --bulk fetch into PL/SQL temp array
           v_sql_col := 'BEGIN '||v_sql_col||' END;';
           IF v_tb_calc_used_col THEN
              IF v_analysis_type='P' THEN
	 	 EXECUTE IMMEDIATE v_sql_col USING OUT v_col,p_name,v_end_date_fix;
              ELSE
		 EXECUTE IMMEDIATE v_sql_col USING OUT v_col,p_name,TRUNC(p_ref_date);
              END IF;
           ELSE
              EXECUTE IMMEDIATE v_sql_col USING OUT v_col,p_name;
           END IF;

           v_max_col_no := v_col.COUNT;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_max_col_no',v_max_col_no);
END IF;
           --construct v_seq_no, v_col_name_map, v_hidden, v_type
           v_col_seq_no.EXTEND(v_max_col_no);
           v_col_seq_no_key.EXTEND(v_max_col_no);
           v_col_name_map.EXTEND(v_max_col_no);
           v_percent_col_name_map.EXTEND(v_max_col_no);
           v_a1.EXTEND(v_max_col_no);
           v_col_type.EXTEND(v_max_col_no);
           v_col_hidden.EXTEND(v_max_col_no);
           FOR i IN v_row_agg_no+1..(v_row_agg_no+v_max_col_no) LOOP
              v_col_seq_no(i) := i;
              v_col_seq_no_key(i) := v_col(i-v_row_agg_no);
              v_col_name_map(i) := 'M'||TO_CHAR(i-v_row_agg_no);
              v_percent_col_name_map(i) := 'P'||TO_CHAR(i-v_row_agg_no);
              v_a1(i) := v_col(i-v_row_agg_no);
              v_col_type(i) := -1; --measure type
              v_col_hidden(i) := 'N';
           END LOOP;
           --add total column at the end

        --measure, becomes a column header only in the case of Aggregated Table
        ELSE
           --must be att. type = 'M' (measure)
           IF v_style='X' THEN
              --hardcoded date_type=(F)ixed, because qrmpaca*.pls will have
	      --saved the fixed date by the time this function is called.
              update_timebuckets(p_name,p_ref_date,
                   v_tb_name,v_tb_label,v_as_of_date,
                   v_start_date_ref,v_start_date_offset,v_start_offset_type,
                   v_row_agg_no,v_max_col_no,'F',v_calendar_id,
                   v_business_week,v_col_seq_no,v_col_seq_no_key,
                   v_col_name_map,v_percent_col_name_map,v_a1,
                   v_col_type,v_col_hidden,v_start_date,v_end_date,
		   v_tb_label_arr);
              --there is no agg for column in qrm_analysis_atts for style=X
              v_col_agg_no := 0;
           ELSIF v_style='A' THEN
              --if need usd arr then v_measure will include additional '_usd'
              --amount columns
              IF v_need_usd_arr THEN
                 v_max_col_no := v_measure_no/4;
              ELSE
                 v_max_col_no := v_measure_no/2;
              END IF;

              v_col_agg_no := 0;
              v_col_seq_no.EXTEND(v_max_col_no);
              v_col_seq_no_key.EXTEND(v_max_col_no);
              v_col_name_map.EXTEND(v_max_col_no);
              v_percent_col_name_map.EXTEND(v_max_col_no);
              v_a1.EXTEND(v_max_col_no);
              v_col_type.EXTEND(v_max_col_no);
              v_col_hidden.EXTEND(v_max_col_no);
              v_col_seq_no(j) := j;
              v_col_seq_no_key(j) := v_agg(j);
              v_col_name_map(j) := 'M'||TO_CHAR(j-v_row_agg_no);
              v_percent_col_name_map(j) := 'P'||TO_CHAR(j-v_row_agg_no);
              v_a1(j) := v_agg(j);
              v_col_type(j) := -1;
              v_col_hidden(j) := 'N';
           ELSE
              --exit path for style C and X
              EXIT;
           END IF;
        END IF;
     END LOOP;

------------Should be removed and done in a separate function
------------if multiple cil level is implemented
     --add total column at the end
     v_max_col_no := v_max_col_no+1;
     v_col_seq_no.EXTEND;
     v_col_seq_no_key.EXTEND;
     v_col_type.EXTEND;
     v_col_hidden.EXTEND;
     v_col_name_map.EXTEND;
     v_percent_col_name_map.EXTEND;
     v_a1.EXTEND;
     IF v_style='X' THEN
        v_start_date.EXTEND;
        v_end_date.EXTEND;
        v_tb_label_arr.EXTEND;
     END IF;
     j := v_max_col_no+v_row_agg_no;
     v_col_seq_no(j) := j;
     v_col_seq_no_key(j) := 'TOTAL';
     v_col_name_map(j) := 'M'||TO_CHAR(v_max_col_no);
     v_percent_col_name_map(j) := 'P'||TO_CHAR(v_max_col_no);
     --need to append ccy to total do the ccy logic
     v_a1(j) := 'TOTAL';
     v_col_type(j) := 1; --total level 1, grand total
     v_col_hidden(j) := 'N';
------------End Should be removed and done in a separate function

-------------Testing purposes
FOR i IN 1..v_row_agg_no+v_max_col_no LOOP
   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'i:seq_no:seq_no_key:a1',i||':'||v_col_seq_no(i)||':'||v_col_seq_no_key(i)||':'||v_a1(i));
   END IF;
--   xtr_risk_debug_pkg.dlog('i:type:hidden:col_name_map:percent_col_name_map',i||':'||v_col_type(i)||':'||v_col_hidden(i)||':'||v_col_name_map(i)||':'||v_percent_col_name_map(i)||':');
   IF v_style='X' THEN
      IF (g_proc_level>=g_debug_level) THEN
         xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'i:start:end',i||':'||v_start_date(i)||':'||v_end_date(i));
      END IF;
   END IF;
END LOOP;
-------------End Testing purposes

     --bulk insert
     IF v_style='X' THEN
        FORALL i IN 1..v_max_col_no+v_row_agg_no
           INSERT INTO qrm_saved_analyses_col(analysis_name,seq_no,seq_no_key,
              type,hidden,col_name_map,a1,percent_col_name_map,start_date,
              end_date,tb_label,created_by,creation_date,last_updated_by,
	      last_update_date,
              last_update_login) VALUES(p_name,v_col_seq_no(i),
              v_col_seq_no_key(i),v_col_type(i),v_col_hidden(i),
	      v_col_name_map(i),
              v_a1(i),v_percent_col_name_map(i),v_start_date(i),v_end_date(i),
	      v_tb_label_arr(i),
              FND_GLOBAL.user_id,p_ref_date,FND_GLOBAL.user_id,p_ref_date,
              FND_GLOBAL.login_id);
     ELSE
        FORALL i IN 1..v_max_col_no+v_row_agg_no
           INSERT INTO qrm_saved_analyses_col(analysis_name,seq_no,seq_no_key,
              type,hidden,col_name_map,a1,percent_col_name_map,created_by,
              creation_date,last_updated_by,last_update_date,
	      last_update_login)
              VALUES(p_name,v_col_seq_no(i),v_col_seq_no_key(i),v_col_type(i),
              v_col_hidden(i),v_col_name_map(i),v_a1(i),
	      v_percent_col_name_map(i),
              FND_GLOBAL.user_id,p_ref_date,FND_GLOBAL.user_id,p_ref_date,
              FND_GLOBAL.login_id);
     END IF;
     COMMIT;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dlog('DML','Inserted into QRM_SAVED_ANALYSES_COL',
        'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_event_level);
     END IF;

----Start Bug 2566711
     --update the tot_currency and tot_currency_label columns
     IF v_style IN ('C','X') THEN
        IF v_ccy_case_flag=0 AND v_ccy_agg_flag=2 THEN
           UPDATE qrm_saved_analyses_col
              SET tot_currency=v_curr_reporting,
	      tot_currency_label=' ('||v_curr_reporting||')',
	      last_updated_by=FND_GLOBAL.user_id,
	      last_update_date=p_ref_date,
	      last_update_login=FND_GLOBAL.login_id
              WHERE type=1;
        ELSIF v_ccy_case_flag=1 THEN
           UPDATE qrm_saved_analyses_col
              SET tot_currency=v_underlying_ccy,
	      tot_currency_label=' ('||v_underlying_ccy||')',
	      last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date,
	      last_update_login=FND_GLOBAL.login_id
              WHERE type=1;
	ELSE
           UPDATE qrm_saved_analyses_col
              SET tot_currency=NULL,
	      tot_currency_label=NULL,
	      last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date,
	      last_update_login=FND_GLOBAL.login_id
              WHERE type=1;
        END IF;
     END IF;
----End Bug 2566711
     COMMIT;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_COL.TOT_CURRENCY',
           'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_event_level);
     END IF;

  END IF;--for p_caller_flag='OA' and v_style='X'

  --prepare the columns currencies multiplier in case each column has
  --different currencies. This is necessary to TOTAL columnwise.
  IF v_style IN ('C','X') and v_ccy_case_flag=0 and v_ccy_agg_flag=2 THEN
     get_col_ccy_multp(v_col_ccy_multp,
			v_a1,
			v_currency_source,
			v_row_agg_no,
			v_max_col_no,
			v_md_set_code,
			p_ref_date);
  END IF;

  --find no of measure columns+other number type columns in the SQL statement
  IF v_style='A' THEN
     v_all_meas_no := v_measure_no;
  ELSE
     --add 1 for the col span seq no
     v_all_meas_no := v_measure_no+1;
  END IF;

  --open dynamic cursor
  v_cursor := dbms_sql.open_cursor;
  --Parse the results (row: qrm_saved_analyses_row)
  dbms_sql.parse(v_cursor,v_sql,dbms_sql.native);
  dbms_sql.bind_variable(v_cursor,'analysis_name',p_name);
  --remember to add end_date as binding variable
  --for special cases
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_tb_calc_used',v_tb_calc_used);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_end_date_fix',v_end_date_fix);
END IF;
  IF v_style='X' THEN
     IF v_analysis_type<>'P' THEN
        dbms_sql.bind_variable(v_cursor,'ref_date',TRUNC(p_ref_date));
     END IF;
  ELSE
     IF v_tb_calc_used THEN
        IF v_analysis_type='P' THEN
           dbms_sql.bind_variable(v_cursor,'end_date',v_end_date_fix);
        ELSE
           dbms_sql.bind_variable(v_cursor,'ref_date',TRUNC(p_ref_date));
        END IF;
     END IF;
  END IF;

  --define columns for row agg
  v_header.EXTEND(2*v_row_agg_no); -- the extra storage to be used later
  v_measure.EXTEND(v_all_meas_no);
  FOR i IN 1..v_row_agg_no LOOP
     dbms_sql.define_column(v_cursor,i,v_header(i),20);
  END LOOP;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_measure_no',v_measure_no);
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_all_meas_no',v_all_meas_no||':'||v_measure.COUNT);
END IF;
  FOR i IN 1..v_all_meas_no LOOP
     dbms_sql.define_column(v_cursor,i+v_row_agg_no,v_measure(i));
  END LOOP;

  --execute
  v_rows_processed := dbms_sql.execute(v_cursor);
--xtr_risk_debug_pkg.dlog('v_cursor = ',v_cursor);
--xtr_risk_debug_pkg.dlog('v_rows_processed = ',v_rows_processed);

  --calculate multiplier to be used in the total array for style=A
  IF v_need_usd_arr THEN -- need to consider USD array then
     m := 4;
     n := m-2;
  ELSE
     m := 2;
     n := m-2;
  END IF;

  --creating/preparing the temporary storage
  v_save_header.EXTEND(v_row_agg_no);

  v_save_measure.EXTEND(v_max_col_no);
  v_nom.EXTEND(v_row_agg_no*v_max_col_no);
  v_denom.EXTEND(v_row_agg_no*v_max_col_no);
  IF v_need_usd_arr THEN
     v_nom_usd.EXTEND(v_row_agg_no*v_max_col_no);
     v_denom_usd.EXTEND(v_row_agg_no*v_max_col_no);
  END IF;


  --loop through the fetched rows
  LOOP
     --fetch a row
     IF dbms_sql.fetch_rows(v_cursor)>0 THEN
        --fetch header/VARCHAR type
        FOR i IN 1..v_row_agg_no LOOP
           dbms_sql.column_value(v_cursor,i,v_header(i));
--xtr_risk_debug_pkg.dlog('v_header(i)',i||':'||v_header(i));
        END LOOP;

        --first reset the indicator
        v_skip_row := FALSE;
        --skip the row if the at least one of the header aggregate att IS NULL
        FOR i IN 1..v_row_agg_no LOOP
           IF v_header(i) IS NULL THEN
              v_skip_row := TRUE;
           END IF;
        END LOOP;

        IF NOT v_skip_row THEN
           --fetch measure and other NUMBER type
           FOR i IN 1..v_all_meas_no LOOP
              dbms_sql.column_value(v_cursor,i+v_row_agg_no,v_measure(i));
           END LOOP;

           --different treatment for Cross Tab and Aggregated Table
           IF v_style='A' THEN --no need for pivoting for style=A
              --check whether need to insert total
              v_total_level := 0;
              IF v_row<>0 THEN
                 FOR i IN 1..v_row_agg_no-1 LOOP
                    IF v_save_header(i)<>v_header(i) THEN
                       v_total_level := i+1;
                       EXIT;
                    END IF;
                 END LOOP;
                 --INSERT the old values: v_save_header and v_save_measure
                 v_type := -1;
                 v_hidden := 'N';
                 v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,NULL,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);

                 --delete the previous array content in case the new column
		 --is null
                 FOR i IN 1..v_row_agg_no LOOP
                    v_save_header(i) := NULL;
                 END LOOP;
                 FOR i IN 1..v_max_col_no LOOP
                    v_save_measure(i) := NULL;
                 END LOOP;
              END IF;

              --if v_total_level>0 then calc total and insert
------------------Calculating the Total Row------------------------
              --see if we need to insert total in between

              IF v_total_level>0 THEN
                 FOR i IN REVERSE v_total_level..v_row_agg_no LOOP
                    v_row := v_row+1;
                    v_save_header(i) := 'TOTAL';
                    -- loop through the measures total
                    FOR j IN 1..v_max_col_no LOOP
                       k := (i-1)*v_max_col_no+j;
                       --determine whether to fetch USD arr or reg. arr
                       IF v_need_usd_arr AND i<=v_ccy_agg_level THEN
		          IF v_denom_usd(k)=0 THEN
                             v_save_measure(j):=v_nom_usd(k)/v_divisor;
                          ELSE
                             v_save_measure(j):=v_nom_usd(k)/v_denom_usd(k);
                          END IF;
                       ELSE
                          IF v_denom(k)=0 THEN
		       	     v_save_measure(j):=v_nom(k)/v_divisor;
		          ELSE
                             v_save_measure(j):=v_nom(k)/v_denom(k);
                          END IF;
                       END IF;
                       v_nom(k) := NULL;
                       v_denom(k) := NULL;
                       IF v_need_usd_arr THEN
                          v_nom_usd(k) := NULL;
                          v_denom_usd(k) := NULL;
                       END IF;
                    END LOOP;
                    --INSERT the old values: v_save_header and v_save_measure
                    v_type := i;
                    v_hidden := 'Y';
                    --determine the CCY to be appended after TOTAL
                    --does not need to worry for the CCY agg logic
		    --(tot. level),
                    --bec. it's captured in v_current_ccy
           	    --Make sure that ccy is appended to Total that has
                    --uniform currency across the columns
                    IF v_need_usd_arr THEN
                       IF v_ccy_agg_flag=2 THEN
                          v_current_ccy := NULL;--cannot display CCY
		       ELSE --check whether before/after the ccy_agg_level
			  IF i>=v_ccy_agg_level THEN
			     v_current_ccy := v_row_ccy;
			  ELSE --v_current_ccy=v_header(ccy_agg_level)
			     v_current_ccy := v_curr_reporting;
			  END IF;
		       --ELSE keep the v_current_ccy
                       END IF;
                    ELSIF v_ccy_case_flag=2 THEN
                       v_current_ccy := NULL;--cannot display CCY
                    ELSE
                       v_current_ccy := v_underlying_ccy;
                    END IF;
                    v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,
                                        v_current_ccy,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);
                    v_current_ccy := NULL; --reset v_current_ccy
                    --delete the previous array content
                    FOR i IN 1..v_row_agg_no LOOP
                       v_save_header(i) := NULL;
                    END LOOP;
                    FOR i IN 1..v_max_col_no LOOP
                       v_save_measure(i) := NULL;
                    END LOOP;
                 END LOOP;
              END IF;
------------------End Calculating the Total Row--------------------

              v_row := v_row+1;
              --copy to v_save_measure and v_save_header assign to nom and
	      --denom
              FOR i IN 1..v_row_agg_no LOOP
                 v_save_header(i):=v_header(i);
                 --determine the current row ccy
                 IF v_ccy_agg_level=i AND v_need_usd_arr THEN
                    v_row_ccy := v_header(i);
                 END IF;
              END LOOP;
              --for style=A v_measure_no=2*(v_max_col_no-1)
              --1 is for the total at the column end
              --'-1' in 'v_max_col_no-1' is to compensate for the End Col TOTAL
              FOR k IN 1..v_max_col_no-1 LOOP
                 IF v_tot_avg(v_row_agg_no+k)='T' THEN
                    v_save_measure(k):=v_measure(k*m-n-1);
                    FOR i IN 1..v_row_agg_no LOOP
                       --determining the storage location for a specific
		       --level total
                       j := (i-1)*v_max_col_no+k;
                       IF v_nom(j) IS NOT NULL THEN
                          IF v_measure(k*m-n-1) IS NOT NULL THEN
                             v_nom(j):=v_nom(j)+v_measure(k*m-n-1);
                          END IF;
                       ELSE
                          v_nom(j):=v_measure(k*m-n-1);
                       END IF;
                       v_denom(j):=1;
                       --determining the storage location for a USD specific
                       --level total
                       IF v_need_usd_arr THEN
                          IF v_nom_usd(j) IS NOT NULL THEN
                             IF v_measure(k*m-1) IS NOT NULL THEN
                                v_nom_usd(j):=v_nom_usd(j)+v_measure(k*m-1);
                             END IF;
                          ELSE
                             v_nom_usd(j):=v_measure(k*m-1);
                          END IF;
                          v_denom_usd(j):=1;
                       END IF;
                    END LOOP;
                 --Weighted Average operation
                 ELSE --insert to side array to be totaled later
                    IF v_measure(k*m-n)=0 THEN
                       v_save_measure(k):=v_measure(k*m-n-1)/v_divisor;
                    ELSE
                       v_save_measure(k):=v_measure(k*m-n-1)/v_measure(k*m-n);
                    END IF;
                    FOR i IN 1..v_row_agg_no LOOP
                       --determining the storage location for a specific
		       --level total
                       j := (i-1)*v_max_col_no+k;
                       IF v_nom(j) IS NOT NULL THEN
                          IF v_measure(k*m-n-1) IS NOT NULL THEN
                             v_nom(j):=v_nom(j)+v_measure(k*m-n-1);
                             v_denom(j) := v_denom(j)+v_measure(k*m-n);
                          END IF;
                       ELSE
                          v_nom(j):=v_measure(k*m-n-1);
                          v_denom(j) := v_measure(k*m-n);
                       END IF;
                       --determining the storage location for a USD specific
                       --level total
                       IF v_need_usd_arr THEN
                          IF v_nom(j) IS NOT NULL THEN
                             IF v_measure(k*m-1) IS NOT NULL THEN
                                v_nom_usd(j):=v_nom_usd(j)+v_measure(k*m-1);
                                v_denom_usd(j) := v_denom_usd(j)+v_measure(k*m);
                             END IF;
                          ELSE
                             v_nom_usd(j):=v_measure(k*m-1);
                             v_denom_usd(j) := v_measure(k*m);
                          END IF;
                       END IF;
                    END LOOP;
                 END IF;
              END LOOP;

           ELSE --pivoting for style='C','X'
              --save the previous row header info in v_header(2*v_row+i)
              --insert to temp array all the output
              --nontotal case
              v_new_row := FALSE;
              v_total_level := 0;
              --check whether it's a new row
              FOR i IN 1..v_row_agg_no LOOP
                 IF v_row=0 OR v_save_header(i)<>v_header(i) THEN
                    v_new_row := TRUE;
                    --exclude condition of the first row fetched
                    IF v_row<>0 AND i<>v_row_agg_no THEN
                       v_total_level := i+1;
                    END IF;
                    EXIT;
                 END IF;
              END LOOP;
              --new row,therefore insert row header
              IF v_new_row THEN
                 IF v_row<>0 THEN
                    --INSERT the old values: v_save_header and v_save_measure
                    v_type := -1;
                    v_hidden := 'N';
                    v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,NULL,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);
                    --delete the previous array content
                    FOR i IN 1..v_row_agg_no LOOP
                       v_save_header(i) := NULL;
                    END LOOP;
                    FOR i IN 1..v_max_col_no LOOP
                       v_save_measure(i) := NULL;
                    END LOOP;
                 END IF;

------------------Calculating the Total Row------------------------
                 --see if we need to insert total in between
                 IF v_total_level>0 THEN
                    FOR i IN REVERSE v_total_level..v_row_agg_no LOOP
                       v_row := v_row+1;
                       v_save_header(i) := 'TOTAL';
                       -- loop through the measures total
                       FOR j IN 1..v_max_col_no LOOP
                          --determine whether to fetch USD arr or reg. arr
                          IF v_need_usd_arr AND i<=v_ccy_agg_level
		 	  AND v_ccy_agg_flag<>2 THEN --bug 2566711
 			     IF v_denom_usd((i-1)*v_max_col_no+j)=0 THEN
			        v_save_measure(j):=v_nom_usd((i-1)*v_max_col_no+j)/v_divisor;
			     ELSE
                                v_save_measure(j):=v_nom_usd((i-1)*v_max_col_no+j)/v_denom_usd((i-1)*v_max_col_no+j);
 			     END IF;
                          ELSE
			     IF v_denom((i-1)*v_max_col_no+j)=0 THEN
                                v_save_measure(j):=v_nom((i-1)*v_max_col_no+j)/v_divisor;
			     ELSE
                                v_save_measure(j):=v_nom((i-1)*v_max_col_no+j)/v_denom((i-1)*v_max_col_no+j);
 			     END IF;
                          END IF;
                          v_nom((i-1)*v_max_col_no+j) := NULL;
                          v_denom((i-1)*v_max_col_no+j) := NULL;
                          IF v_need_usd_arr THEN
                             v_nom_usd((i-1)*v_max_col_no+j) := NULL;
                             v_denom_usd((i-1)*v_max_col_no+j) := NULL;
                          END IF;
                       END LOOP;

                       --INSERT the old values: v_save_header and
		       --v_save_measure
                       v_type := i;
                       v_hidden := 'Y';
                       --determine the CCY to be appended after TOTAL
                       --does not need to worry for the CCY agg logic
		       --(tot. level),
                       --bec. it's captured in v_current_ccy
 		       --Make sure that ccy is appended to Total that has
                       --uniform currency across the columns
                       IF v_need_usd_arr THEN
                          IF v_ccy_agg_flag=2 THEN
                             v_current_ccy := NULL;--cannot display CCY
		          ELSE --check whether before/after the ccy_agg_level
			     IF i> v_ccy_agg_level THEN -- Bug 4533431
			        v_current_ccy := v_row_ccy;
			     ELSE --v_current_ccy=v_header(ccy_agg_level)
				v_current_ccy := v_curr_reporting;
			     END IF;
                          END IF;
                       ELSIF v_ccy_case_flag=2 THEN
                          v_current_ccy := NULL;--cannot display CCY
                       ELSE
                          v_current_ccy := v_underlying_ccy;
                       END IF;
                       v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,
                                        v_current_ccy,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);
                       v_current_ccy := NULL; --reset
                       --delete the previous array content
                       FOR i IN 1..v_row_agg_no LOOP
                          v_save_header(i) := NULL;
                       END LOOP;
                       FOR i IN 1..v_max_col_no LOOP
                          v_save_measure(i) := NULL;
                       END LOOP;
                    END LOOP;
                 END IF;
------------------End Calculating the Total Row--------------------

                 --insert header increase row count
                 v_row := v_row+1;
                 --do not include the column aggregate in the row header
                 FOR i IN 1..v_row_agg_no LOOP
                    v_save_header(i):=v_header(i);
                    --determine the current row ccy
                    IF v_ccy_agg_level=i AND v_need_usd_arr THEN
                       v_row_ccy := v_header(i);
                    END IF;
                 END LOOP;
              END IF;
              --insert measure
              --v_measure(1) has the Y Axis coordinate
              --Total operation
              IF v_tot_avg(v_row_agg_no+v_col_agg_no+1)='T' THEN
                 v_save_measure(v_measure(1)-v_row_agg_no):=v_measure(2);
                 FOR i IN 1..v_row_agg_no LOOP
                    --determining the storage location for a specific level
		    --total
                    j:=(i-1)*v_max_col_no+(v_measure(1)-v_row_agg_no);
                    IF v_nom(j) IS NOT NULL THEN
                       IF v_measure(2) IS NOT NULL THEN
                          v_nom(j):=v_nom(j)+v_measure(2);
                       END IF;
                    ELSE
                       v_nom(j):=v_measure(2);
                    END IF;
                    v_denom(j):=1;
                    --determining the storage location for USD specific level
		    --total
                    IF v_need_usd_arr THEN
                       IF v_nom_usd(j) IS NOT NULL THEN
                          IF v_measure(4) IS NOT NULL THEN
                             v_nom_usd(j):=v_nom_usd(j)+v_measure(4);
                          END IF;
                       ELSE
                          v_nom_usd(j):=v_measure(4);
                       END IF;
                       v_denom_usd(j):=1;
                    END IF;
                 END LOOP;
              --Weighted Average operation
              ELSE --insert to side array to be totaled later
                 IF v_measure(3)=0 THEN
                    v_save_measure(v_measure(1)-v_row_agg_no):=v_measure(2)/v_divisor;
                 ELSE
                    v_save_measure(v_measure(1)-v_row_agg_no):=v_measure(2)/v_measure(3);
                 END IF;
                 FOR i IN 1..v_row_agg_no LOOP
                    --determining the storage location for a specific level
		    --total
                    j:=(i-1)*v_max_col_no+(v_measure(1)-v_row_agg_no);
                    IF v_nom(j) IS NOT NULL THEN
                       IF v_measure(2) IS NOT NULL THEN
                          v_nom(j) := v_nom(j)+v_measure(2);
                          v_denom(j) := v_denom(j)+v_measure(3);
                       END IF;
                    ELSE
                       v_nom(j) := v_measure(2);
                       v_denom(j) := v_measure(3);
                    END IF;
                    --determining the storage location for USD specific level
		    --total
                    IF v_need_usd_arr THEN
                       IF v_nom_usd(j) IS NOT NULL THEN
                          IF v_measure(4) IS NOT NULL THEN
                             v_nom_usd(j) := v_nom_usd(j)+v_measure(4);
                             v_denom_usd(j) := v_denom_usd(j)+v_measure(5);
                          END IF;
                       ELSE
                          v_nom_usd(j) := v_measure(4);
                          v_denom_usd(j) := v_measure(5);
                       END IF;
                    END IF;
                 END LOOP;
              END IF;
           END IF; --style
        END IF; --v_skip_row

     ELSE
       --before exit:insert last row and do grand total at the bottom
        IF v_row<>0 THEN
           --INSERT the old values: v_save_header and v_save_measure
           v_type := -1;
           v_hidden := 'N';
           v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,NULL,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);

           --start from 1,the grand total
           v_total_level := 1;
           FOR i IN REVERSE v_total_level..v_row_agg_no LOOP
              --delete the previous array content
              FOR i IN 1..v_row_agg_no LOOP
                 v_save_header(i) := NULL;
              END LOOP;
              FOR i IN 1..v_max_col_no LOOP
                 v_save_measure(i) := NULL;
              END LOOP;
              v_row := v_row+1;
              v_save_header(i) := 'TOTAL';
              -- loop through the measures total
              FOR j IN 1..v_max_col_no LOOP
                 --determine whether to fetch USD arr or reg. arr
                 IF v_need_usd_arr AND i<=v_ccy_agg_level
		 AND v_ccy_agg_flag<>2 THEN --bug 2566711
 		    IF v_denom_usd((i-1)*v_max_col_no+j)=0 THEN
		       v_save_measure(j):=v_nom_usd((i-1)*v_max_col_no+j)/v_divisor;
		    ELSE
                       v_save_measure(j):=v_nom_usd((i-1)*v_max_col_no+j)/v_denom_usd((i-1)*v_max_col_no+j);
 		    END IF;
                 ELSE
		    IF v_denom((i-1)*v_max_col_no+j)=0 THEN
                       v_save_measure(j):=v_nom((i-1)*v_max_col_no+j)/v_divisor;
		    ELSE
                       v_save_measure(j):=v_nom((i-1)*v_max_col_no+j)/v_denom((i-1)*v_max_col_no+j);
   	            END IF;
                 END IF;
                 v_nom((i-1)*v_max_col_no+j) := NULL;
                 v_denom((i-1)*v_max_col_no+j) := NULL;
                 IF v_need_usd_arr THEN
                    v_nom_usd((i-1)*v_max_col_no+j) := NULL;
                    v_denom_usd((i-1)*v_max_col_no+j) := NULL;
                 END IF;
              END LOOP;
              --INSERT total
              v_type := i;
              v_hidden := 'Y';
              --determine the CCY to be appended after TOTAL
              --does not need to worry for the CCY agg logic (tot. level),
              --bec. it's captured in v_current_ccy
              IF v_need_usd_arr THEN
                 IF v_ccy_agg_flag=2 THEN
                    v_current_ccy := NULL;--cannot display CCY
		 ELSE --check whether before/after the ccy_agg_level
		    IF i > v_ccy_agg_level THEN --Bug 4533431
		       v_current_ccy := v_row_ccy;
		    ELSE --v_current_ccy=v_header(ccy_agg_level)
		       v_current_ccy := v_curr_reporting;
		    END IF;
		 END IF;
              ELSIF v_ccy_case_flag=2 THEN
                 v_current_ccy := NULL;--cannot display CCY
              ELSE
                 v_current_ccy := v_underlying_ccy;
              END IF;
              v_success := insert_row(v_save_header,v_save_measure,
                                        v_row_agg_no,v_max_col_no,
                                        p_name,v_row,v_type,v_hidden,
                                        v_current_ccy,
                                        v_style,p_ref_date,v_ccy_case_flag,
					v_ccy_agg_flag,v_col_ccy_multp);
           END LOOP;
        END IF;
        EXIT;
     END IF;
  END LOOP;

  COMMIT;
  dbms_sql.close_cursor(v_cursor);

  --update total
  v_success := update_total(p_name,p_ref_date);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_successT',v_success);
END IF;
  IF NOT v_success THEN
     RAISE e_pagg_update_total_fail;
  END IF;
  --find out NOCOPY currency for each saved cells in the table
  v_success := update_aggregate_curr(p_name,p_ref_date,v_ccy_case_flag,
	v_ccy_agg_flag,v_ccy_agg_level,v_row_agg_no,v_max_col_no,
        v_underlying_ccy,v_currency_source,v_curr_reporting,v_agg_col_curr);

IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_successCurr',v_success);
END IF;
  IF NOT v_success THEN
     RAISE e_pagg_update_agg_curr_fail;
  END IF;
  --update percent
  v_success := update_percent (p_name,v_style,v_row_agg_no,v_max_col_no,
				p_ref_date,v_md_set_code);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_success%',v_success);
END IF;
  IF NOT v_success THEN
     RAISE e_pagg_update_percent_fail;
  END IF;
  IF v_style='C' THEN
     v_success := update_label(p_name,v_agg,v_col_order,v_att_type,p_ref_date);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_successL',v_success);
END IF;
     IF NOT v_success THEN
        RAISE e_pagg_update_label_fail;
     END IF;
  END IF;
  --update timebuckets label
  IF v_style='X' AND p_caller_flag='OA' THEN
     v_success := update_timebuckets_label(p_name);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('transform_and_save: ' || 'v_successTBLabel',v_success);
END IF;
     IF NOT v_success THEN
        RAISE e_pagg_update_tb_label_fail;
     END IF;
  END IF;

  --update dirty column if called from 'OA'
  IF p_caller_flag='OA' THEN
     UPDATE qrm_analysis_settings SET dirty='N' WHERE analysis_name=p_name;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_ANALYSIS_SETTINGS.DIRTY=N',
           'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_event_level);
     END IF;

  END IF;

  COMMIT;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE');
  END IF;
  RETURN 'T';

EXCEPTION
  WHEN e_pagg_no_fxrate_found THEN
     IF p_caller_flag='CONC' THEN
        RAISE e_pagg_no_fxrate_found;
     ELSE
        fnd_msg_pub.add;
     END IF;
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','e_pagg_no_fxrate_found','QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_error_level);--bug 3236479
        --xtr_risk_debug_pkg.dpop('transform_and_save: ' || 'QRM_PA_AGGREGATION_P.T_AND_S');
     END IF;
     RETURN 'F';
  WHEN e_pagg_no_timebuckets_found THEN
     IF p_caller_flag='CONC' THEN
        RAISE e_pagg_no_timebuckets_found;
     ELSE
        fnd_msg_pub.add;
     END IF;
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','e_pagg_no_timebuckets_found','QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_error_level);--bug 3236479
        --xtr_risk_debug_pkg.dpop('transform_and_save: ' || 'QRM_PA_AGGREGATION_P.T_AND_S');
     END IF;
     RETURN 'F';
  WHEN e_pagg_no_setting_found THEN
     IF p_caller_flag='CONC' THEN
        RAISE e_pagg_no_setting_found;
     ELSE
        fnd_msg_pub.add;
     END IF;
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','e_pagg_no_setting_found','QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_error_level);--bug 3236479
        --xtr_risk_debug_pkg.dpop('transform_and_save: ' || 'QRM_PA_AGGREGATION_P.T_AND_S');
     END IF;
     RETURN 'F';
  WHEN OTHERS THEN
     IF p_caller_flag='OA' THEN
        FND_MESSAGE.SET_NAME('QRM','QRM_ANA_UNEXPECTED_ERROR');
        fnd_msg_pub.add;
     END IF;
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','others','QRM_PA_AGGREGATION_P.TRANSFORM_AND_SAVE',g_error_level);--bug 3236479
        --xtr_risk_debug_pkg.dpop('transform_and_save: ' || 'QRM_PA_AGGREGATION_P.T_AND_S');
     END IF;
     RETURN 'F';
END transform_and_save;



/***************************************************************
This function check whether a particular date is a holiday or not
in GL Calendar and if so, find the next/previous business day.

If anything goes wrong during the operation, the function will
return the date passed in as the argument.
***************************************************************/
-- from GL Calendar
FUNCTION find_gl_business_days(p_indicator VARCHAR2,
                --'F'=forward next bus.days,'B'=backward next bus.days
                        p_date_in DATE,
                        p_calendar_id NUMBER)
        RETURN DATE IS
  v_date_out DATE;
  v_move VARCHAR2(1); --'B' for backward,'F' for forward
  v_day VARCHAR2(3);
  v_week SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_day_no NUMBER;
  i NUMBER(1);
  j NUMBER(1);
  v_found BOOLEAN := FALSE;
BEGIN

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.FIND_GL_BUSINESS_DAY');
  END IF;

  IF p_calendar_id IS NULL THEN
    v_date_out := p_date_in;
  ELSE
    IF p_indicator='F' THEN --find the next bus. day forward
       SELECT MIN(transaction_date)
          INTO v_date_out
          FROM gl_transaction_dates
          WHERE transaction_calendar_id = p_calendar_id
          AND TRUNC(transaction_date) >= TRUNC(p_date_in)
          AND business_day_flag = 'Y';
    ELSIF p_indicator='B' THEN --find the next bus. day backward
       SELECT MAX(transaction_date)
          INTO v_date_out
          FROM gl_transaction_dates
          WHERE transaction_calendar_id = p_calendar_id
          AND TRUNC(transaction_date) <= TRUNC(p_date_in)
          AND business_day_flag = 'Y';
    ELSE
       RAISE_APPLICATION_ERROR
             (-20001,'Invalid Interval Type of Time-Buckets');
    END IF;
  END IF;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.FIND_GL_BUSINESS_DAY');
  END IF;

  RETURN v_date_out;
EXCEPTION
  WHEN OTHERS THEN

     IF (g_error_level>=g_debug_level) THEN --bug 3236479
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.FIND_GL_BUSINESS_DAY',g_error_level);
     END IF;

     RETURN p_date_in;
END find_gl_business_days;



/********************************************************************
 get_beg_end_of_week
    Procedure that provides the beginning and end of the week given a
    reference date, based on a GL Transaction Calendar.  In the case
    where there are either no or all business days, it defines the
    first of the week by following NLS_TERRITORY settings.

    This procedure attempts to determine the beginning of the week by
    looking for the first business day following a "block" of
    non-business days.

    In the case where there are multiple "blocks" of non-business days
    it will be based on the "block" that ends closest to (but on or
    after) Friday.

  p_gl_trans_calendar_id - GL Transacation Calendar ID
  p_ref_date - Reference date
  p_beg_date - Beginning of the week
  p_end_date - End of the week
********************************************************************/
PROCEDURE get_beg_end_of_week(p_gl_trans_calendar_id IN NUMBER,
	p_ref_date IN DATE,
	p_beg_date OUT NOCOPY DATE,
	p_end_date OUT NOCOPY DATE) IS
--
  -- Be very careful when modifying this.  The code runs on the
  --   the assumption that Friday comes first.
  CURSOR days_of_week_cursor IS
    SELECT
        fri_business_day_flag,
        sat_business_day_flag,
        sun_business_day_flag,
        mon_business_day_flag,
        tue_business_day_flag,
        wed_business_day_flag,
        thu_business_day_flag
    FROM gl_transaction_calendar
    WHERE transaction_calendar_id = p_gl_trans_calendar_id;
--
  v_day_table SYSTEM.QRM_VARCHAR_TABLE;
  v_fri GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_sat GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_sun GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_mon GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_tue GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_wed GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
  v_thu GL_TRANSACTION_CALENDAR.SAT_BUSINESS_DAY_FLAG%TYPE;
--
  v_last_nonbus_day NUMBER := 0;
  v_nonbus_count NUMBER := 0;
  v_ref_day NUMBER;
  v_days_before NUMBER;
  v_offset NUMBER;
--
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.get_beg_end_of_week');
  END IF;

  OPEN days_of_week_cursor;
  FETCH days_of_week_cursor INTO v_fri,v_sat,v_sun,v_mon,v_tue,v_wed,v_thu;
  CLOSE days_of_week_cursor;

  -- Put the days of the week in an array for code cleanliness.
  v_day_table := SYSTEM.QRM_VARCHAR_table(Nvl(v_fri, 'Y'), Nvl(v_sat, 'Y'),
                        Nvl(v_sun, 'Y'), Nvl(v_mon, 'Y'), Nvl(v_tue, 'Y'),
                        Nvl(v_wed, 'Y'), Nvl(v_thu, 'Y'));

  -- First go from top to bottom (Friday to Thursday)
  FOR i IN 1..v_day_table.count LOOP
    -- If non-business day, then we want to add to the count of the
    -- number of days this "block" of non-business days consists of
    IF v_day_table(i) = 'N' THEN
      v_nonbus_count := v_nonbus_count + 1;
      v_last_nonbus_day := i;
    ELSE
    -- If we hit a business day, and we've already encounted a non-business
    -- day "block" (count>0), we're done.
      IF v_nonbus_count > 0 THEN
        EXIT;
      END IF;
    END IF;
  END LOOP;

  -- Now we just have to make sure this "block" of non-business days
  -- is not any bigger than it seems.  It is bigger if it starts on
  -- the first day and the last day turns out NOCOPY to be a non-business
  -- day as well.  If this is the case, we need to increase the "block"
  -- size, by running backwards.
  IF v_day_table(1) = 'N' AND v_day_table(7)= 'N' THEN
    FOR i IN REVERSE 1..v_day_table.count LOOP
      -- If non-business day, we continue add to the "block" size.
      IF v_day_table(i) = 'N' THEN
        v_nonbus_count := v_nonbus_count + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('get_beg_end_of_week: ' || 'v_last_nonbus_day',v_last_nonbus_day);
     xtr_risk_debug_pkg.dlog('get_beg_end_of_week: ' || 'v_nonbus_count',v_nonbus_count);
  END IF;

  IF v_nonbus_count <= 0  OR v_nonbus_count >= 7 THEN
    p_beg_date := trunc(p_ref_date,'D');
    p_end_date := trunc(p_ref_date,'D')+6;
  ELSE
    -- TO_CHAR with 'D' format returns 1-7 for SUN-SAT (dependent on
    --   NLS_TERRITORY settings).
    -- Since this changes depending on the customer settings,
    --   we need a fixed reference point (Fri 5/31/2002).
    -- Now that we know NLS number system, we will apply that "offset"
    --   to our ref_date so that it is back in our system (where Friday
    --   is 1).  If Friday is no longer 1, we would need to pick a date
    --   that falls on that new reference day.
    v_offset := to_number(to_char(to_date('05/31/2002','MM/DD/YYYY'),'D'))-1;
    v_ref_day := to_number(to_char(p_ref_date,'D')) - v_offset;
    -- If negative, need to wrap so represent the correct day
    IF v_ref_day < 0 THEN
      v_ref_day := v_ref_day + 7;
    END IF;
    -- If negative, need to wrap so represent the correct day
    v_days_before := v_ref_day - (v_last_nonbus_day + 1);
    IF v_days_before < 0 THEN
      v_days_before := v_days_before + 7;
    END IF;
    p_beg_date := trunc(p_ref_date) - v_days_before;
    p_end_date := trunc(p_ref_date) + (7 - (v_days_before + v_nonbus_count) - 1);

    IF (g_proc_level>=g_debug_level) THEN
       xtr_risk_debug_pkg.dlog('get_beg_end_of_week: ' || 'v_ref_day',v_ref_day);
       xtr_risk_debug_pkg.dlog('get_beg_end_of_week: ' || 'v_days_before',v_days_before);
    END IF;
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGRREGATION_P.get_beg_end_of_week');
  END IF;
END get_beg_end_of_week;



/***************************************************************
This function calculates the actual date givent the relative date
,fixed date, and the date type.
***************************************************************/
FUNCTION calculate_relative_date(p_ref_date DATE,
                                p_date_type VARCHAR2,
                                p_as_of_date DATE,
                                p_start_date_ref VARCHAR2,
                                p_start_date_offset NUMBER,
                                p_start_offset_type VARCHAR2,
                                p_calendar_id NUMBER,
				p_business_week VARCHAR2)
        RETURN DATE IS
  v_date DATE;
  v_dummy DATE;
BEGIN

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGRREGATION_P.CALCULATE_RELATIVE_DATE');
  END IF;

  --see whether the as of date is fixed or relative
  IF p_date_type='F' THEN
     v_date := TRUNC(p_as_of_date);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('calculate_relative_date: ' || 'v_date',v_date);
END IF;
  ELSE
     --reference
     IF p_start_date_ref='BW' THEN --Beginning of Week
        get_beg_end_of_week(p_calendar_id,TRUNC(p_ref_date),v_date,v_dummy);
     ELSIF p_start_date_ref='BM' THEN --Beginning of Month
        v_date := TRUNC(p_ref_date,'MONTH');
     ELSIF p_start_date_ref='BY' THEN --Beginning of Year
        v_date := TRUNC(p_ref_date,'YEAR');
     ELSIF p_start_date_ref='S' THEN --p_ref_date
        v_date := TRUNC(p_ref_date);
     ELSIF p_start_date_ref='EW' THEN --End of Week
        get_beg_end_of_week(p_calendar_id,TRUNC(p_ref_date),v_dummy,v_date);
     ELSIF p_start_date_ref='EM' THEN --End of Month
        v_date := ADD_MONTHS(TRUNC(p_ref_date,'MONTH'),1)-1;
     ELSIF p_start_date_ref='EY' THEN --End of Year
        v_date := ADD_MONTHS(TRUNC(p_ref_date,'YEAR'),12)-1;
     ELSE
        RAISE_APPLICATION_ERROR
           (-20001,'Invalid start_date_ref.');
     END IF;
     --offset
     IF p_start_date_offset IS NOT NULL THEN
        IF p_start_offset_type='D' THEN
           v_date := v_date+p_start_date_offset;
        ELSIF p_start_offset_type='W' THEN
           v_date := v_date+7*p_start_date_offset;
        ELSIF p_start_offset_type='M' THEN
           v_date := ADD_MONTHS(v_date,p_start_date_offset);
        ELSIF p_start_offset_type='Y' THEN
           v_date := ADD_MONTHS(v_date,12*p_start_date_offset);
        ELSE
           RAISE_APPLICATION_ERROR
              (-20001,'Invalid start_offset_type.');
        END IF;
     END IF;
  END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('calculate_relative_date: ' || 'v_date',v_date);
   xtr_risk_debug_pkg.dlog('calculate_relative_date: ' || 'p_calendar_id',p_calendar_id);
END IF;
  --Only check holiday if p_business_week='C' otherwise
  --assume 7-days-week
  IF p_business_week='C' THEN
    v_date := find_gl_business_days('F',
                        v_date, p_calendar_id);
  END IF;

  IF (g_proc_level>=g_debug_level) THEN --bug 3236479
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGRREGATION_P.CALCULATE_RELATIVE_DATE');
  END IF;

  RETURN v_date;
END calculate_relative_date;



/***************************************************************
This procedure calculates the time-buckets interval actual
dates and saved them intot qrm_saved_analyses_col
***************************************************************/
PROCEDURE update_timebuckets (p_name VARCHAR2,
                        p_ref_date DATE,
                        p_tb_name VARCHAR2,
                        p_tb_label VARCHAR2,
                        p_as_of_date DATE,
                        p_start_date_ref VARCHAR2,
                        p_start_date_offset NUMBER,
                        p_start_offset_type VARCHAR2,
                        p_row_agg_no NUMBER,
                        p_max_col_no OUT NOCOPY NUMBER,
                        p_date_type VARCHAR2,
                        p_calendar_id NUMBER,
                        p_business_week VARCHAR2,
                        p_col_seq_no IN OUT NOCOPY XTR_MD_NUM_TABLE,
                        p_col_seq_no_key IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_col_name_map IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_percent_col_name_map IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_a1 IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_col_type IN OUT NOCOPY XTR_MD_NUM_TABLE,
                        p_col_hidden IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_start_date IN OUT NOCOPY SYSTEM.QRM_DATE_TABLE,
                        p_end_date IN OUT NOCOPY SYSTEM.QRM_DATE_TABLE,
			p_tb_label_arr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE) IS

  CURSOR v_tb_cursor IS
     SELECT interval_length, interval_type, label
        FROM qrm_time_intervals
        WHERE tb_name = p_tb_name AND sequence_number<>0
        ORDER BY sequence_number;
  CURSOR v_find_tb IS
     SELECT COUNT(*) FROM qrm_time_buckets
        WHERE tb_name = p_tb_name;
  v_int_length xtr_md_num_table;
  v_int_type SYSTEM.QRM_VARCHAR_table;
  v_label SYSTEM.QRM_VARCHAR_table;
  v_date DATE;
  v_prev_end_date DATE;
  v_dummy NUMBER;
  i NUMBER(5);
  j NUMBER(5);
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_P.UPDATE_TIMEBUCKETS'); --bug3236479
  END IF;

  --check whether time buckets exist
  OPEN v_find_tb;
  FETCH v_find_tb INTO v_dummy;
  CLOSE v_find_tb;
  IF v_dummy=0 THEN
     FND_MESSAGE.SET_NAME('QRM','QRM_ANA_NO_TIMEBUCKETS');
     FND_MESSAGE.SET_TOKEN('TB_NAME',p_tb_name);
     RAISE e_pagg_no_timebuckets_found;
  END IF;

  OPEN v_tb_cursor;
  FETCH v_tb_cursor BULK COLLECT INTO v_int_length,v_int_type,v_label;
  p_max_col_no := v_int_length.LAST;
  CLOSE v_tb_cursor;

  --construct p_seq_no, p_a1, p_hidden, p_type
  p_col_name_map.EXTEND(p_max_col_no);
  p_percent_col_name_map.EXTEND(p_max_col_no);
  p_a1.EXTEND(p_max_col_no);
  p_col_seq_no.EXTEND(p_max_col_no);
  p_col_type.EXTEND(p_max_col_no);
  p_col_hidden.EXTEND(p_max_col_no);
  p_col_seq_no_key.EXTEND(p_max_col_no);
  --start and end date has not been initilized earlier, thus, lacking
  --p_row_agg_no rows
  p_start_date.EXTEND(p_max_col_no+p_row_agg_no);
  p_end_date.EXTEND(p_max_col_no+p_row_agg_no);
  p_tb_label_arr.EXTEND(p_max_col_no+p_row_agg_no);

  --for the rest of the timebuckets
  FOR i IN p_row_agg_no+1..(p_row_agg_no+p_max_col_no) LOOP
     --find start date = previous end date + 1
     IF i=p_row_agg_no+1 THEN --for the first case/timebucket
        p_start_date(i) := calculate_relative_date(p_ref_date,
                                p_date_type,
                                p_as_of_date,
                                p_start_date_ref,
                                p_start_date_offset,
                                p_start_offset_type,
                                p_calendar_id,
				p_business_week);
        v_prev_end_date := p_start_date(i);
     ELSE
        IF p_business_week='C' THEN
           p_start_date(i) := find_gl_business_days('F',
                        p_end_date(i-1)+1,p_calendar_id);
        ELSE
           p_start_date(i) := p_end_date(i-1)+1;
        END IF;
        --need the -1 since timebucket start and end date cannot overlap.
        v_prev_end_date := p_start_date(i);
     END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('p_start_date(i)',i||':'||p_start_date(i));
END IF;
xtr_risk_debug_pkg.dlog('v_int_type(i),v_int_length(i)',i||':'||v_int_type(i-p_row_agg_no)||','||v_int_length(i-p_row_agg_no));
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_prev_end_date',v_prev_end_date);
END IF;
     --find temp end date
     IF v_int_type(i-p_row_agg_no)='D' THEN
        v_date := v_prev_end_date+v_int_length(i-p_row_agg_no);
     ELSIF v_int_type(i-p_row_agg_no)='W' THEN
        v_date := v_prev_end_date+7*v_int_length(i-p_row_agg_no);
     ELSIF v_int_type(i-p_row_agg_no)='M' THEN
        v_date := add_months(v_prev_end_date,v_int_length(i-p_row_agg_no));
     ELSIF v_int_type(i-p_row_agg_no)='Y' THEN
        v_date := add_months(v_prev_end_date,12*v_int_length(i-p_row_agg_no));
     ELSE
        RAISE_APPLICATION_ERROR
             (-20001,'Invalid Interval Type of Time-Buckets');
     END IF;
     --find actual end date
     IF p_business_week='C' THEN
        p_end_date(i) := find_gl_business_days('B',v_date-1,p_calendar_id);
     ELSE
        p_end_date(i) := v_date-1;
     END IF;
--xtr_risk_debug_pkg.dlog('p_end_date(i)',i||':'||p_end_date(i));
     p_col_seq_no(i) := i;
     p_col_seq_no_key(i) := TO_CHAR(i);
     p_col_name_map(i) := 'M'||TO_CHAR(i-p_row_agg_no);
     p_percent_col_name_map(i) := 'P'||TO_CHAR(i-p_row_agg_no);
     p_tb_label_arr(i) := v_label(i-p_row_agg_no);
     --logic whether to look for TB Label or display the end date
     IF p_tb_label='L' THEN
        p_a1(i) := p_tb_label_arr(i);
     ELSE--p_tb_label='D'
        p_a1(i) := TO_CHAR(TRUNC(p_end_date(i)));
     END IF;
     p_col_type(i) := -1; --measure type
     p_col_hidden(i) := 'N';
  END LOOP;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_P.UPDATE_TIMEBUCKETS');--bug 3236479
  END IF;
END update_timebuckets;



/***************************************************************
This procedure calculates the time-buckets start date and end date
and used by qrmpacab.pls

IMPORTANT:
For Timebuckets style, there is a discrepancy between the start
and end date in the DB and in the display.
END_DATE in DB for style=X means the first
START_DATE in the Timebuckets display.
That's why this procedure passes in DB's END_DATE in what should've
been the Timebuckets START_DATE only when analysis type='P'.
(Bug 2355584 no.2)
***************************************************************/
PROCEDURE calc_tb_start_end_dates (p_name VARCHAR2,
                        p_ref_date DATE,
                        p_tb_name VARCHAR2,
                        p_tb_label VARCHAR2,
                        p_end_date IN OUT NOCOPY DATE,
                        p_end_date_ref IN OUT NOCOPY VARCHAR2,
                        p_end_date_offset IN OUT NOCOPY NUMBER,
                        p_end_offset_type IN OUT NOCOPY VARCHAR2,
                        p_date_type VARCHAR2,
                        p_calendar_id NUMBER,
                        p_business_week VARCHAR2,
			p_start_date IN OUT NOCOPY DATE,
                        p_start_date_ref IN OUT NOCOPY VARCHAR2,
                        p_start_date_offset IN OUT NOCOPY NUMBER,
                        p_start_offset_type IN OUT NOCOPY VARCHAR2,
			p_analysis_type VARCHAR2) IS

  v_col_seq_no XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
  v_col_seq_no_key SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_col_name_map SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_percent_col_name_map SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_a1 SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_col_type XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
  v_col_hidden SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_start_date SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
  v_end_date SYSTEM.QRM_DATE_TABLE := SYSTEM.QRM_DATE_TABLE();
  v_tb_label_arr SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
  v_row_agg_no NUMBER := 0;
  v_max_col_no NUMBER;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_P.CALC_TB_START_END_DATE');--bug 3236479
  END IF;
  --need to swap because the END_DATE is the start date for the
  --timebuckets
  update_timebuckets(p_name, p_ref_date, p_tb_name, p_tb_label, p_end_date,
                        p_end_date_ref, p_end_date_offset,
			p_end_offset_type, v_row_agg_no, v_max_col_no,
                        p_date_type, p_calendar_id, p_business_week,
                        v_col_seq_no, v_col_seq_no_key, v_col_name_map,
                        v_percent_col_name_map, v_a1, v_col_type,
                        v_col_hidden, v_start_date, v_end_date,
			v_tb_label_arr);
  p_start_date := v_start_date(1);
  p_start_date_ref := p_end_date_ref;
  p_start_date_offset := p_end_date_offset;
  p_start_offset_type := p_end_offset_type;
  p_end_date := v_end_date(v_end_date.LAST);

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_P.CALC_TB_START_END_DATE');--bug 3236479
  END IF;
END calc_tb_start_end_dates;



/***************************************************************
This function should be used
everytime the Total page is modified.
***************************************************************/
FUNCTION update_total(p_name VARCHAR2, p_ref_date DATE) RETURN BOOLEAN IS
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_TOTAL');--bug 3236479
  END IF;
  --update qrm_saved_analyses_row first
  --set all the total rows to be hidden
  UPDATE qrm_saved_analyses_row
     SET hidden='Y', last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
     WHERE type>0 AND analysis_name=p_name;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_ROW.HIDDEN=Y',
        'QRM_PA_AGGREGATION_P.UPDATE_TOTAL',g_event_level);
  END IF;

  --set selected total rows to be displayed
  UPDATE qrm_saved_analyses_row
     SET hidden='N', last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
     WHERE analysis_name=p_name
     AND type IN (SELECT att_order FROM qrm_analysis_atts
                  WHERE analysis_name=p_name
                  AND total_ind<>'N'
                  AND type='R'
                  AND history_flag='S');

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_ROW.HIDDEN=N for those that need to be displayed',
        'QRM_PA_AGGREGATION_P.UPDATE_TOTAL',g_event_level);
  END IF;

  --update qrm_saved_analyses_col
  --set all the total rows to be hidden
  UPDATE qrm_saved_analyses_col
     SET hidden='Y', last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
     WHERE type>0 AND analysis_name=p_name;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_COL.HIDDEN=Y',
        'QRM_PA_AGGREGATION_P.UPDATE_TOTAL',g_event_level);
  END IF;

  --set selected total rows to be displayed
  UPDATE qrm_saved_analyses_col
     SET hidden='N', last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
     WHERE analysis_name=p_name
     AND type IN (SELECT att_order FROM qrm_analysis_atts
                  WHERE analysis_name=p_name
                  AND total_ind<>'N'
                  AND type='C'
                  AND history_flag='S');

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
      XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_COL.HIDDEN=N for those that need to be displayed',
        'QRM_PA_AGGREGATION_P.UPDATE_TOTAL',g_event_level);
  END IF;

  COMMIT;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_TOTAL');--bug 3236479
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     IF (g_error_level>=g_debug_level) THEN
        --xtr_risk_debug_pkg.dpop('QRM_PA_AGGREGATION_P.UPDATE_TOTAL');
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.UPDATE_TOTAL',g_error_level);--bug 3236479
     END IF;
     RETURN FALSE;
END update_total;



/***************************************************************
This function updates the percent columns (P1..P100) given
the analysis name and seq_no, one row at the time.
***************************************************************/
FUNCTION update_percent_cols(p_name VARCHAR2,
			p_row NUMBER,
			p_ref_date DATE,
			p_meas XTR_MD_NUM_TABLE)
        RETURN BOOLEAN IS
BEGIN

   IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT_COLS');--bug 3236479
   END IF;

   UPDATE qrm_saved_analyses_row
              SET p1=p_meas(1),p2=p_meas(2),p3=p_meas(3),
              p4=p_meas(4),p5=p_meas(5),p6=p_meas(6),
              p7=p_meas(7),p8=p_meas(8),p9=p_meas(9),
              p10=p_meas(10),p11=p_meas(11),
                p12=p_meas(12),
              p13=p_meas(13),p14=p_meas(14),
                p15=p_meas(15),
              p16=p_meas(16),p17=p_meas(17),
                p18=p_meas(18),
              p19=p_meas(19),p20=p_meas(20),
              p21=p_meas(21),p22=p_meas(22),
                p23=p_meas(23),
              p24=p_meas(24),p25=p_meas(25),
                p26=p_meas(26),
              p27=p_meas(27),p28=p_meas(28),
                p29=p_meas(29),
              p30=p_meas(30),p31=p_meas(31),
                p32=p_meas(32),
              p33=p_meas(33),p34=p_meas(34),
                p35=p_meas(35),
              p36=p_meas(36),p37=p_meas(37),
                p38=p_meas(38),
              p39=p_meas(39),p40=p_meas(40),
              p41=p_meas(41),p42=p_meas(42),
                p43=p_meas(43),
              p44=p_meas(44),p45=p_meas(45),
                p46=p_meas(46),
              p47=p_meas(47),p48=p_meas(48),
                p49=p_meas(49),p50=p_meas(50),
              p51=p_meas(51),p52=p_meas(52),
                p53=p_meas(53),
              p54=p_meas(54),p55=p_meas(55),
                p56=p_meas(56),
              p57=p_meas(57),p58=p_meas(58),
                p59=p_meas(59),
              p60=p_meas(60),p61=p_meas(61),
                p62=p_meas(62),
              p63=p_meas(63),p64=p_meas(64),
                p65=p_meas(65),
              p66=p_meas(66),p67=p_meas(67),
                p68=p_meas(68),
              p69=p_meas(69),p70=p_meas(70),
              p71=p_meas(71),p72=p_meas(72),
                p73=p_meas(73),
              p74=p_meas(74),p75=p_meas(75),
                p76=p_meas(76),
              p77=p_meas(77),p78=p_meas(78),
                p79=p_meas(79),
              p80=p_meas(80),p81=p_meas(81),
                p82=p_meas(82),
              p83=p_meas(83),p84=p_meas(84),
                p85=p_meas(85),
              p86=p_meas(86),p87=p_meas(87),
                p88=p_meas(88),
              p89=p_meas(89),p90=p_meas(90),
              p91=p_meas(91),p92=p_meas(92),
                p93=p_meas(93),
              p94=p_meas(94),p95=p_meas(95),
                p96=p_meas(96),
              p97=p_meas(97),p98=p_meas(98),
                p99=p_meas(99),p100=p_meas(100),
                last_updated_by=FND_GLOBAL.user_id,
                last_update_date=p_ref_date,
                last_update_login=FND_GLOBAL.login_id
              WHERE analysis_name=p_name
                AND seq_no=p_row;

   IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT_COLS');--bug 3236479
   END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      IF (g_proc_level>=g_debug_level) THEN
         --xtr_risk_debug_pkg.dpop('QRM_PA_AGGREGATION_P.UPDATE_PERCENT_COLS');
         xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.UPDATE_PERCENT_COLS');--bug 3236479
      END IF;
      RETURN FALSE;
END update_percent_cols;



/***************************************************************
This function converts values from M1..M100 and translate them
into USD and then updates the P1..P100 before calculating the
percent. This is necessary to get values based on 1 currency so
that they can be percentaged correctly.
Please refer to bug 2393589 for more details.
***************************************************************/
FUNCTION translate_to_usd (p_name VARCHAR2,
			p_ref_date DATE,
			p_md_set_code VARCHAR2,
			p_tot_level NUMBER)
        RETURN BOOLEAN IS

   v_level NUMBER;
   v_row NUMBER;
   v_meas XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
   v_ccy SYSTEM.QRM_VARCHAR_TABLE := SYSTEM.QRM_VARCHAR_TABLE();
   v_fx_rate NUMBER;
   v_success BOOLEAN;

   CURSOR get_all_measures IS
      SELECT seq_no,type,
	m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,
        m18,m19,m20,m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,m31,m32,m33,m34,
        m35,m36,m37,m38,m39,m40,m41,m42,m43,m44,m45,m46,m47,m48,m49,m50,m51,
        m52,m53,m54,m55,m56,m57,m58,m59,m60,m61,m62,m63,m64,m65,m66,m67,m68,
        m69,m70,m71,m72,m73,m74,m75,m76,m77,m78,m79,m80,m81,m82,m83,m84,m85,
        m86,m87,m88,m89,m90,m91,m92,m93,m94,m95,m96,m97,m98,m99,m100,
        curr1,curr2,curr3,curr4,curr5,curr6,curr7,curr8,curr9,
        curr10,curr11,curr12,curr13,curr14,curr15,curr16,curr17,
        curr18,curr19,curr20,curr21,curr22,curr23,curr24,curr25,curr26,
        curr27,curr28,curr29,curr30,curr31,curr32,curr33,curr34,
        curr35,curr36,curr37,curr38,curr39,curr40,curr41,curr42,curr43,
        curr44,curr45,curr46,curr47,curr48,curr49,curr50,curr51,
        curr52,curr53,curr54,curr55,curr56,curr57,curr58,curr59,curr60,
        curr61,curr62,curr63,curr64,curr65,curr66,curr67,curr68,
        curr69,curr70,curr71,curr72,curr73,curr74,curr75,curr76,curr77,
        curr78,curr79,curr80,curr81,curr82,curr83,curr84,curr85,
        curr86,curr87,curr88,curr89,curr90,curr91,curr92,curr93,curr94,
        curr95,curr96,curr97,curr98,curr99,curr100
        FROM qrm_saved_analyses_row
        WHERE analysis_name=p_name
	ORDER BY seq_no;

BEGIN

   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.TRANSLATE_TO_USD');
   END IF;

   OPEN get_all_measures;
   v_meas.EXTEND(100);
   v_ccy.EXTEND(100);
--xtr_risk_debug_pkg.dlog('p_name',p_name);
   LOOP
      FETCH get_all_measures INTO
              v_row,v_level,v_meas(1),v_meas(2),v_meas(3),v_meas(4),v_meas(5),
              v_meas(6),v_meas(7),v_meas(8),v_meas(9),v_meas(10),v_meas(11),
              v_meas(12),v_meas(13),v_meas(14),v_meas(15),v_meas(16),
		v_meas(17),
              v_meas(18),v_meas(19),v_meas(20),
              v_meas(21),v_meas(22),v_meas(23),v_meas(24),v_meas(25),
              v_meas(26),v_meas(27),v_meas(28),v_meas(29),v_meas(30),
		v_meas(31),
              v_meas(32),v_meas(33),v_meas(34),v_meas(35),v_meas(36),
		v_meas(37),
              v_meas(38),v_meas(39),v_meas(40),
              v_meas(41),v_meas(42),v_meas(43),v_meas(44),v_meas(45),
              v_meas(46),v_meas(47),v_meas(48),v_meas(49),v_meas(50),
              v_meas(51),v_meas(52),v_meas(53),v_meas(54),v_meas(55),
              v_meas(56),v_meas(57),v_meas(58),v_meas(59),v_meas(60),
		v_meas(61),
              v_meas(62),v_meas(63),v_meas(64),v_meas(65),v_meas(66),
		v_meas(67),
              v_meas(68),v_meas(69),v_meas(70),
              v_meas(71),v_meas(72),v_meas(73),v_meas(74),v_meas(75),
              v_meas(76),v_meas(77),v_meas(78),v_meas(79),v_meas(80),
		v_meas(81),
              v_meas(82),v_meas(83),v_meas(84),v_meas(85),v_meas(86),
		v_meas(87),
              v_meas(88),v_meas(89),v_meas(90),
              v_meas(91),v_meas(92),v_meas(93),v_meas(94),v_meas(95),
              v_meas(96),v_meas(97),v_meas(98),v_meas(99),v_meas(100),
              v_ccy(1),v_ccy(2),v_ccy(3),v_ccy(4),v_ccy(5),
              v_ccy(6),v_ccy(7),v_ccy(8),v_ccy(9),v_ccy(10),v_ccy(11),
              v_ccy(12),v_ccy(13),v_ccy(14),v_ccy(15),v_ccy(16),
		v_ccy(17),
              v_ccy(18),v_ccy(19),v_ccy(20),
              v_ccy(21),v_ccy(22),v_ccy(23),v_ccy(24),v_ccy(25),
              v_ccy(26),v_ccy(27),v_ccy(28),v_ccy(29),v_ccy(30),
		v_ccy(31),
              v_ccy(32),v_ccy(33),v_ccy(34),v_ccy(35),v_ccy(36),
		v_ccy(37),
              v_ccy(38),v_ccy(39),v_ccy(40),
              v_ccy(41),v_ccy(42),v_ccy(43),v_ccy(44),v_ccy(45),
              v_ccy(46),v_ccy(47),v_ccy(48),v_ccy(49),v_ccy(50),
              v_ccy(51),v_ccy(52),v_ccy(53),v_ccy(54),v_ccy(55),
              v_ccy(56),v_ccy(57),v_ccy(58),v_ccy(59),v_ccy(60),
		v_ccy(61),
              v_ccy(62),v_ccy(63),v_ccy(64),v_ccy(65),v_ccy(66),
		v_ccy(67),
              v_ccy(68),v_ccy(69),v_ccy(70),
              v_ccy(71),v_ccy(72),v_ccy(73),v_ccy(74),v_ccy(75),
              v_ccy(76),v_ccy(77),v_ccy(78),v_ccy(79),v_ccy(80),
		v_ccy(81),
              v_ccy(82),v_ccy(83),v_ccy(84),v_ccy(85),v_ccy(86),
		v_ccy(87),
              v_ccy(88),v_ccy(89),v_ccy(90),
              v_ccy(91),v_ccy(92),v_ccy(93),v_ccy(94),v_ccy(95),
              v_ccy(96),v_ccy(97),v_ccy(98),v_ccy(99),v_ccy(100);
      EXIT WHEN get_all_measures%NOTFOUND OR get_all_measures%NOTFOUND IS NULL;
      --
      FOR i IN 1..v_ccy.COUNT LOOP
         --if TYPE > total level then insert NULL
         IF v_level>0 AND v_level<p_tot_level THEN
            v_meas(i) := NULL;
	 ELSE
            --do some checks for optimization
            IF v_ccy(i) IS NOT NULL and v_meas(i) IS NOT NULL and
            v_meas(i)<>0 THEN
               --Additional check for optimization
               IF i>1 and v_ccy(i)=v_ccy(i-1) THEN
                  v_meas(i) := v_meas(i)*v_fx_rate;
               ELSE
                  v_fx_rate := get_fx_rate(p_md_set_code,
					p_ref_date,
					v_ccy(i),
					'USD',
					'M');
                  v_meas(i) := v_meas(i)*v_fx_rate;
               END IF;
            END IF;
         END IF;
      END LOOP;
      --
      v_success := update_percent_cols(p_name,v_row,p_ref_date,v_meas);
      --
   END LOOP;
   CLOSE get_all_measures;

   IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.TRANSLATE_TO_USD'); --bug 3236479
   END IF;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
      IF (g_error_level>=g_debug_level) THEN
         xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.TRANSLATE_TO_USD',g_error_level);--bug 3236479
      END IF;
      RETURN FALSE;
END translate_to_usd;



/***************************************************************
This update_percent function should be used by external call
everytime the Total page is modified.
Internal call (transform_and_save) will use the other signature.
***************************************************************/
FUNCTION update_percent (p_name VARCHAR2,p_ref_date DATE)
        RETURN BOOLEAN IS

  CURSOR count_column IS
     SELECT COUNT(*) FROM qrm_saved_analyses_col
        WHERE analysis_name=p_name
        AND type>-2;
  CURSOR count_row_header IS
     SELECT COUNT(*) FROM qrm_saved_analyses_col
        WHERE analysis_name=p_name
        AND type=-2;
  CURSOR get_style IS
     SELECT style,md_set_code FROM qrm_analysis_settings
        WHERE analysis_name=p_name AND history_flag='S';
  v_max_col_no NUMBER(5);
  v_row_agg_no NUMBER(5);
  v_style VARCHAR2(1);
  v_success BOOLEAN;
  v_md_set_code qrm_analysis_settings.md_set_code%TYPE;

BEGIN

  IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT'); --bug 3236479
  END IF;

  OPEN count_column;
  FETCH count_column INTO v_max_col_no;
  CLOSE count_column;
  OPEN count_row_header;
  FETCH count_row_header INTO v_row_agg_no;
  CLOSE count_row_header;
  OPEN get_style;
  FETCH get_style INTO v_style,v_md_set_code;
  CLOSE get_style;
  v_success:=update_percent(p_name,v_style,v_row_agg_no,v_max_col_no,
			p_ref_date,v_md_set_code);

  IF (g_proc_level>=g_debug_level) THEN
      xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT'); --bug 3236479
  END IF;

  RETURN v_success;
END update_percent;



/***************************************************************
This update_percent function should be used by internal call
from transform_and_save procedure.
External call should use the other signature.
***************************************************************/
FUNCTION update_percent (p_name VARCHAR2,
                         p_style VARCHAR2,
                         p_row_agg_no NUMBER,
                         p_max_col_no NUMBER,
                         p_ref_date DATE,
			 p_md_set_code VARCHAR2)
        RETURN BOOLEAN IS

  v_tot XTR_MD_NUM_TABLE := XTR_MD_NUM_TABLE();
  v_type VARCHAR2(1);
  v_level VARCHAR2(1); --the order
  v_row NUMBER;
  v_previous_count NUMBER := 1;
  i NUMBER(5);
  v_sql VARCHAR2(4000);
  v_tot_segment NUMBER;
  v_divisor NUMBER := 0.000001; --bug 2393972
  v_success BOOLEAN;

  CURSOR percent_info IS
     SELECT type,att_order FROM qrm_analysis_atts
        WHERE analysis_name=p_name AND percentage='Y' AND history_flag='S';
  CURSOR get_col_tot_seq_no IS
     SELECT seq_no FROM qrm_saved_analyses_col
        WHERE analysis_name=p_name AND type=v_level;
  CURSOR col_100 IS
     SELECT seq_no,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,
        m18,m19,m20,m21,m22,m23,m24,m25,m26,m27,m28,m29,m30,m31,m32,m33,m34,
        m35,m36,m37,m38,m39,m40,m41,m42,m43,m44,m45,m46,m47,m48,m49,m50,m51,
        m52,m53,m54,m55,m56,m57,m58,m59,m60,m61,m62,m63,m64,m65,m66,m67,m68,
        m69,m70,m71,m72,m73,m74,m75,m76,m77,m78,m79,m80,m81,m82,m83,m84,m85,
        m86,m87,m88,m89,m90,m91,m92,m93,m94,m95,m96,m97,m98,m99,m100
        FROM qrm_saved_analyses_row
        WHERE analysis_name=p_name AND type=v_level ORDER BY seq_no;
BEGIN

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT');
  END IF;

  OPEN percent_info;
  FETCH percent_info INTO v_type,v_level;
  CLOSE percent_info;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_type:v_level',v_type||':'||v_level);
END IF;

  v_success :=  translate_to_usd (p_name,
			p_ref_date,
			p_md_set_code,
			v_level);

  --percentage is based on the row aggregates
  IF v_type='R' THEN

     --prep cursor that contains total at the specified level
     v_tot.EXTEND(100);

     --bug 2393972
     FOR i in 1..100 LOOP
        IF (v_tot(i)=0) THEN
           v_tot(i):=v_divisor;
        END IF;
     END LOOP;

     OPEN col_100;
     LOOP
        --fetch the specified level total row
        FETCH col_100 INTO
              v_row,v_tot(1),v_tot(2),v_tot(3),v_tot(4),v_tot(5),
              v_tot(6),v_tot(7),v_tot(8),v_tot(9),v_tot(10),v_tot(11),
              v_tot(12),v_tot(13),v_tot(14),v_tot(15),v_tot(16),v_tot(17),
              v_tot(18),v_tot(19),v_tot(20),
              v_tot(21),v_tot(22),v_tot(23),v_tot(24),v_tot(25),
              v_tot(26),v_tot(27),v_tot(28),v_tot(29),v_tot(30),v_tot(31),
              v_tot(32),v_tot(33),v_tot(34),v_tot(35),v_tot(36),v_tot(37),
              v_tot(38),v_tot(39),v_tot(40),
              v_tot(41),v_tot(42),v_tot(43),v_tot(44),v_tot(45),
              v_tot(46),v_tot(47),v_tot(48),v_tot(49),v_tot(50),
              v_tot(51),v_tot(52),v_tot(53),v_tot(54),v_tot(55),
              v_tot(56),v_tot(57),v_tot(58),v_tot(59),v_tot(60),v_tot(61),
              v_tot(62),v_tot(63),v_tot(64),v_tot(65),v_tot(66),v_tot(67),
              v_tot(68),v_tot(69),v_tot(70),
              v_tot(71),v_tot(72),v_tot(73),v_tot(74),v_tot(75),
              v_tot(76),v_tot(77),v_tot(78),v_tot(79),v_tot(80),v_tot(81),
              v_tot(82),v_tot(83),v_tot(84),v_tot(85),v_tot(86),v_tot(87),
              v_tot(88),v_tot(89),v_tot(90),
              v_tot(91),v_tot(92),v_tot(93),v_tot(94),v_tot(95),
              v_tot(96),v_tot(97),v_tot(98),v_tot(99),v_tot(100);
        --calculating the % while updating the rows in between
        UPDATE qrm_saved_analyses_row
              SET p1=100*p1/v_tot(1),p2=100*p2/v_tot(2),p3=100*p3/v_tot(3),
              p4=100*p4/v_tot(4),p5=100*p5/v_tot(5),p6=100*p6/v_tot(6),
              p7=100*p7/v_tot(7),p8=100*p8/v_tot(8),p9=100*p9/v_tot(9),
              p10=100*p10/v_tot(10),p11=100*p11/v_tot(11),
                p12=100*p12/v_tot(12),
              p13=100*p13/v_tot(13),p14=100*p14/v_tot(14),
                p15=100*p15/v_tot(15),
              p16=100*p16/v_tot(16),p17=100*p17/v_tot(17),
                p18=100*p18/v_tot(18),
              p19=100*p19/v_tot(19),p20=100*p20/v_tot(20),
              p21=100*p21/v_tot(21),p22=100*p22/v_tot(22),
                p23=100*p23/v_tot(23),
              p24=100*p24/v_tot(24),p25=100*p25/v_tot(25),
                p26=100*p26/v_tot(26),
              p27=100*p27/v_tot(27),p28=100*p28/v_tot(28),
                p29=100*p29/v_tot(29),
              p30=100*p30/v_tot(30),p31=100*p31/v_tot(31),
                p32=100*p32/v_tot(32),
              p33=100*p33/v_tot(33),p34=100*p34/v_tot(34),
                p35=100*p35/v_tot(35),
              p36=100*p36/v_tot(36),p37=100*p37/v_tot(37),
                p38=100*p38/v_tot(38),
              p39=100*p39/v_tot(39),p40=100*p40/v_tot(40),
              p41=100*p41/v_tot(41),p42=100*p42/v_tot(42),
                p43=100*p43/v_tot(43),
              p44=100*p44/v_tot(44),p45=100*p45/v_tot(45),
                p46=100*p46/v_tot(46),
              p47=100*p47/v_tot(47),p48=100*p48/v_tot(48),
                p49=100*p49/v_tot(49),p50=100*p50/v_tot(50),
              p51=100*p51/v_tot(51),p52=100*p52/v_tot(52),
                p53=100*p53/v_tot(53),
              p54=100*p54/v_tot(54),p55=100*p55/v_tot(55),
                p56=100*p56/v_tot(56),
              p57=100*p57/v_tot(57),p58=100*p58/v_tot(58),
                p59=100*p59/v_tot(59),
              p60=100*p60/v_tot(60),p61=100*p61/v_tot(61),
                p62=100*p62/v_tot(62),
              p63=100*p63/v_tot(63),p64=100*p64/v_tot(64),
                p65=100*p65/v_tot(65),
              p66=100*p66/v_tot(66),p67=100*p67/v_tot(67),
                p68=100*p68/v_tot(68),
              p69=100*p69/v_tot(69),p70=100*p70/v_tot(70),
              p71=100*p71/v_tot(71),p72=100*p72/v_tot(72),
                p73=100*p73/v_tot(73),
              p74=100*p74/v_tot(74),p75=100*p75/v_tot(75),
                p76=100*p76/v_tot(76),
              p77=100*p77/v_tot(77),p78=100*p78/v_tot(78),
                p79=100*p79/v_tot(79),
              p80=100*p80/v_tot(80),p81=100*p81/v_tot(81),
                p82=100*p82/v_tot(82),
              p83=100*p83/v_tot(83),p84=100*p84/v_tot(84),
                p85=100*p85/v_tot(85),
              p86=100*p86/v_tot(86),p87=100*p87/v_tot(87),
                p88=100*p88/v_tot(88),
              p89=100*p89/v_tot(89),p90=100*p90/v_tot(90),
              p91=100*p91/v_tot(91),p92=100*p92/v_tot(92),
                p93=100*p93/v_tot(93),
              p94=100*p94/v_tot(94),p95=100*p95/v_tot(95),
                p96=100*p96/v_tot(96),
              p97=100*p97/v_tot(97),p98=100*p98/v_tot(98),
                p99=100*p99/v_tot(99),p100=100*p100/v_tot(100),
                last_updated_by=FND_GLOBAL.user_id,
                last_update_date=p_ref_date,
                last_update_login=FND_GLOBAL.login_id
              WHERE analysis_name=p_name AND seq_no>=v_previous_count
                AND seq_no<=v_row
                AND (type=-1 OR type>=v_level);

        IF (g_event_level>=g_debug_level) THEN --bug 3236479
           XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_ROW.P1..P100 Row Level Agg',
              'QRM_PA_AGGREGATION_P.UPDATE_PERCENT',g_event_level);
        END IF;

        v_previous_count := v_row+1;
        EXIT WHEN col_100%NOTFOUND;
     END LOOP;
     CLOSE col_100;

     --update the column info, first null all the COL_PERCENT_LEVEL
     UPDATE qrm_saved_analyses_col
        SET col_percent_level=NULL, last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name;
     --left null total columns,so it won't be displayed
     UPDATE qrm_saved_analyses_col
        SET col_percent_level=v_level, last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name AND type=-1;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_COL.COL_PERCENT_LEVEL to null then '||v_level,
              'QRM_PA_AGGREGATION_P.UPDATE_PERCENT',g_event_level);
     END IF;

  --percentage is based on the col aggregates
  ELSIF v_type='C' THEN
     --get all the specified total column index
     v_tot := NULL;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('Before FETCH v_tot');
END IF;
     OPEN get_col_tot_seq_no;
     FETCH get_col_tot_seq_no BULK COLLECT INTO v_tot;
     CLOSE get_col_tot_seq_no;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('After FETCH v_tot');
END IF;
     v_previous_count := p_row_agg_no;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_tot.COUNT',v_tot.COUNT);
   xtr_risk_debug_pkg.dlog('v_tot.LAST',v_tot.LAST);
   xtr_risk_debug_pkg.dlog('v_previous_count',v_previous_count);
END IF;
     FOR i IN 1..v_tot.COUNT LOOP
--
--Have to do dynamic sql bec. we have to divide per block of col
--Trying to get all column between the total index
--
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_tot(i)',i||':'||v_tot(i));
END IF;
        v_tot_segment := v_tot(i)-v_previous_count;
        FOR j IN 1..v_tot_segment LOOP
           --IF j<v_tot(i)-v_previous_count THEN
           --   v_sql := v_sql||'p'||j||'=100*m'||j||'/m'||v_tot_segment||',';
           --ELSE
           --   v_sql := v_sql||'p'||j||'=100*m'||j||'/m'||v_tot_segment;
           --END IF;

           --bug 2393972
           IF j<v_tot(i)-v_previous_count THEN
              v_sql := v_sql||'p'||j||'=100*p'||j||'/DECODE(p'||v_tot_segment||',0,TO_NUMBER('''||v_divisor||'''),p'||v_tot_segment||'),';
           ELSE
              v_sql := v_sql||'p'||j||'=100*p'||j||'/DECODE(p'||v_tot_segment||',0,TO_NUMBER('''||v_divisor||'''),p'||v_tot_segment||')';
           END IF;

        END LOOP;
        v_sql:='UPDATE qrm_saved_analyses_row SET '||v_sql||' , last_updated_by=FND_GLOBAL.user_id, last_update_date=:p_ref_date, last_update_login=FND_GLOBAL.login_id WHERE analysis_name=:p_name';

IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_sql',v_sql);
END IF;
        EXECUTE IMMEDIATE v_sql USING p_ref_date,p_name;
        v_previous_count := v_tot(i)+1;
     END LOOP;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('After EXECUTE IMMEDIATE');
END IF;
     --update the column info, first null all the COL_PERCENT_LEVEL
     UPDATE qrm_saved_analyses_col
        SET col_percent_level=NULL, last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name;
     --left null total columns,so it won't be displayed
     UPDATE qrm_saved_analyses_col
        SET col_percent_level=-v_level, last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
        WHERE analysis_name=p_name AND (type=-1 OR type>=v_level);

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_COL.COL_PERCENT_LEVEL to null then '||v_level,
              'QRM_PA_AGGREGATION_P.UPDATE_PERCENT',g_event_level);
     END IF;

  ELSE
     --no percentage calculation is necessary
     IF (g_proc_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT');--bug 3236479
     END IF;
     RETURN TRUE;
  END IF;

  COMMIT;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_PERCENT');-- bug 3236479
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN

     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS',
		'QRM_PA_AGGREGATION_P.UPDATE_PERCENT',g_error_level);--bug 3236479
     END IF;

     RETURN FALSE;
END update_percent;



/***************************************************************
This function updates the label of the DEAL_TYPE and
DEAL_SUBTYPE aggregate attributes with the user defined ones
from table qrm_saved_analyses_col.
The label of table qrm_saved_analyses_row will be updated at run
time in OA.

DEAL_TYPE -> xtr_deal_types.user_deal_type

DEAL_SUBTYPE -> xtr_deal_subtypes.user_deal_subtype
is taken care in the dynamic cursor when aggregation is done.
***************************************************************/
FUNCTION update_label(p_name VARCHAR2,
                        p_agg IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,
                        p_col_order IN OUT NOCOPY XTR_MD_NUM_TABLE,
                        p_att_type IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,
                        p_ref_date DATE)
                RETURN BOOLEAN IS
  v_col_name VARCHAR2(50);
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_LABEL');
  END IF;

  --loop through all the aggregate to see whether DEAL_TYPE is there.
  FOR i IN 1..p_agg.COUNT LOOP
     IF p_agg(i)='DEAL_TYPE' AND p_att_type(i)='C' THEN
        --update the column header to reflect user defined DEAL_TYPE
        UPDATE qrm_saved_analyses_col
           SET a1=(SELECT DISTINCT user_deal_type FROM xtr_deal_types WHERE deal_type=a1), last_updated_by=FND_GLOBAL.user_id, last_update_date=p_ref_date, last_update_login=FND_GLOBAL.login_id
           WHERE analysis_name=p_name AND type=-1;
        COMMIT;

        IF (g_event_level>=g_debug_level) THEN --bug 3236479
           XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SET_ANALYSES_COL.A1 to user_deal_type',
              'QRM_PA_AGGREGATION_P.UPDATE_LABEL',g_event_level);
        END IF;

	EXIT;
     END IF;
  END LOOP;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_LABEL');
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.UPDATE_LABEL',g_error_level);-- bug 3236479
     END IF;
     RETURN FALSE;
END update_label;



/***************************************************************
This procedure calculate the Totals for Table style using the
currency conversion logic. Moreover, the underlying currency
of the Totals will be returned together with the calculated totals.
Also calculate the currency multipler (FX Rate) for reporting
currency as needed.
IMPORTANT:
If an attribute cannot be averaged/totaled (sensitivity with
> 1 underlying curr) then the p_att_name(i) will be NULLED.
***************************************************************/
PROCEDURE calc_table_total_and_fxrate(p_name VARCHAR2,--1
                           p_calc_total_ind VARCHAR2,--2: 'Y'es or 'N'o
                           p_curr_reporting VARCHAR2,--3
                           p_currency_source VARCHAR2,--4
                           p_last_run_date DATE,--5
                           p_md_set_code VARCHAR2,--6
                           p_dirty VARCHAR2,--7
                           p_end_date_fix DATE,--8
                           p_tot_avg SYSTEM.QRM_VARCHAR_TABLE,--9
                           p_ccy_multiplier OUT NOCOPY NUMBER,--10
                           p_att_name IN OUT NOCOPY SYSTEM.QRM_VARCHAR240_TABLE,--11
                           p_total OUT NOCOPY XTR_MD_NUM_TABLE,--12
                           p_table_col_curr OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE,--13
			   p_sensitivity SYSTEM.QRM_VARCHAR_TABLE, --14
			   p_analysis_type VARCHAR2, --15
			   p_business_week VARCHAR2,--16
			   p_amount SYSTEM.QRM_VARCHAR_TABLE)--17
		IS

  v_ccy_suffix VARCHAR2(20);
  v_underlying_ccy VARCHAR2(20);
  v_origin SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_att_type SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_nom SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_denom SYSTEM.QRM_VARCHAR240_TABLE := SYSTEM.QRM_VARCHAR240_TABLE();
  v_num_denom_origin SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_sql VARCHAR2(4000);
  i NUMBER(5);
  v_cursor INTEGER;
  v_rows_processed INTEGER;
  v_tb_calc_used BOOLEAN;
  v_temp VARCHAR2(240);
  v_total_temp xtr_md_num_table := xtr_md_num_table();

  --dummy variables required only for other styles
  v_tb_calc_used_col BOOLEAN;
  v_ccy_aggregate SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_type SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();
  v_order xtr_md_num_table := xtr_md_num_table();
  v_ccy_agg_flag NUMBER;
  v_ccy_case_flag NUMBER;
  v_ccy_agg_level NUMBER;
  v_measure_no NUMBER(5);
  v_row_agg_no NUMBER(5);
  v_dummy VARCHAR2(1);
  v_sql_col VARCHAR2(1);
  v_agg_col_curr SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();

  CURSOR get_lookup_prop IS
     SELECT origin,attribute_type,numerator,denominator,num_denom_origin
        FROM qrm_ana_atts_lookups
        WHERE attribute_name=v_temp;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.CALC_TABLE_TOTAL');--bug 3236479
  END IF;

  --initialize fnd_msg_pub if it has not been intialized
  IF fnd_msg_pub.count_msg>0 THEN
     fnd_msg_pub.Initialize;
  END IF;

  --FHU will convert the relative date and saved them into the fix date col

  --see whether we need to do total or just to get multiplier
  IF p_calc_total_ind='Y' THEN
     --first extend v_table_col_curr
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('p_att_name.COUNT,p_att_name.LAST',p_att_name.COUNT||','||p_att_name.LAST);
END IF;
     p_table_col_curr := SYSTEM.QRM_VARCHAR_table();
     p_table_col_curr.EXTEND(p_att_name.COUNT);
     v_origin.EXTEND(p_att_name.COUNT);
     v_att_type.EXTEND(p_att_name.COUNT);
     v_nom.EXTEND(p_att_name.COUNT);
     v_denom.EXTEND(p_att_name.COUNT);
     v_num_denom_origin.EXTEND(p_att_name.COUNT);
     p_total := xtr_md_num_table();
     p_total.EXTEND(p_att_name.COUNT);

--xtr_risk_debug_pkg.dlog('p_table_col_curr.COUNT',p_table_col_curr.COUNT);
     --get the underlying currency for each column and modify the the
     --attribute name with '_USD' and '_SOB'
     get_underlying_currency(p_name,p_last_run_date,'T',p_md_set_code,
                        p_currency_source,p_curr_reporting,p_amount,
                        p_att_name,v_ccy_aggregate,v_type,v_order,
                        v_ccy_suffix,p_ccy_multiplier,v_ccy_agg_flag,
                        v_underlying_ccy,v_ccy_case_flag,NULL,
                        v_ccy_agg_level,p_table_col_curr,v_agg_col_curr,
			p_sensitivity);
--xtr_risk_debug_pkg.dlog('p_table_col_curr.COUNT',p_table_col_curr.COUNT);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('p_ccy_multiplier',p_ccy_multiplier);
END IF;
     --make sure p_ccy_multiplier is not null when necessary otherwise throws error
     FOR i IN 1..p_table_col_curr.COUNT LOOP
--xtr_risk_debug_pkg.dlog('p_table_col_curr(i)',i||':'||p_table_col_curr(i));
        IF p_table_col_curr(i) IS NULL THEN
           IF p_curr_reporting<>'USD' AND p_ccy_multiplier IS NULL THEN
              FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
              FND_MESSAGE.SET_TOKEN('CCY',p_curr_reporting);
              RAISE e_pagg_no_fxrate_found;
           END IF;
        END IF;
     END LOOP;

     --get the property of the new name attributes
     FOR i IN 1..p_att_name.COUNT LOOP
        IF p_att_name(i) IS NOT NULL THEN
           v_temp := p_att_name(i);
--xtr_risk_debug_pkg.dlog('v_temp',v_temp);
           OPEN get_lookup_prop;
           FETCH get_lookup_prop INTO v_origin(i),v_att_type(i),v_nom(i),
                v_denom(i),v_num_denom_origin(i);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_origin,v_att_type,v_nom,v_denom',i||':'||v_origin(i)||','||v_att_type(i)||','||v_nom(i)||','||v_denom(i));
END IF;
           CLOSE get_lookup_prop;
        END IF;
     END LOOP;

     --create dynamic sql, first get the origin and alias
     create_cursor (p_name,'T',p_analysis_type,p_att_name,v_att_type,
                        v_nom,v_denom,p_tot_avg,v_sql,v_sql_col,
                        v_row_agg_no,v_measure_no,v_origin,v_tb_calc_used,
                        v_tb_calc_used_col,
                        FALSE,v_ccy_suffix,p_ccy_multiplier,
                        p_amount,p_table_col_curr,v_num_denom_origin,
			p_curr_reporting,p_sensitivity);

IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('v_sql',v_sql);
END IF;
     --open dynamic cursor
     v_cursor := dbms_sql.open_cursor;
     --Parse the results
     dbms_sql.parse(v_cursor,v_sql,dbms_sql.native);
     dbms_sql.bind_variable(v_cursor,'analysis_name',p_name);
     --remember to add end_date as binding variable
     --for special cases: v_tb_calc_used=TRUE
     IF v_tb_calc_used THEN
        IF p_analysis_type='P' THEN
           dbms_sql.bind_variable(v_cursor,'end_date',p_end_date_fix);
        ELSE
           dbms_sql.bind_variable(v_cursor,'ref_date',TRUNC(p_last_run_date));
        END IF;
     END IF;
--xtr_risk_debug_pkg.dlog('v_measure_no',v_measure_no);
     --the number of columns is twice as many in the SQL bec. of nom and denom
     v_total_temp.EXTEND(p_att_name.COUNT*2);
     FOR i IN 1..v_total_temp.COUNT LOOP
        dbms_sql.define_column(v_cursor,i,v_total_temp(i));
     END LOOP;
     --execute
     v_rows_processed := dbms_sql.execute(v_cursor);
     --get the value
     LOOP
        IF dbms_sql.fetch_rows(v_cursor)>0 THEN
           FOR i IN 1..v_total_temp.COUNT LOOP
              dbms_sql.column_value(v_cursor,i,v_total_temp(i));
           END LOOP;
        ELSE
           EXIT;
        END IF;
     END LOOP;
     --transfer the value from v_total_temp to p_total
     FOR i IN 1..p_total.COUNT LOOP
        IF p_att_name(i) IS NOT NULL THEN
           IF p_tot_avg(i)='T' THEN --do SUM operation
              p_total(i) := v_total_temp(i*2-1);
           ELSE --do AVERAGE operation
              p_total(i) := v_total_temp(i*2-1)/v_total_temp(i*2);
           END IF;
        END IF;
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('p_total(i)',i||':'||p_att_name(i)||','||p_total(i)||','||p_table_col_curr(i));
END IF;
     END LOOP;
     --close dynamic cursor
     dbms_sql.close_cursor(v_cursor);

  ELSE --just need to call MD API to get the FX Rate/Ccy multiplier
     --Find multiplier
     p_ccy_multiplier := get_fx_rate(p_md_set_code,
			p_last_run_date,
			'USD',
			p_curr_reporting,
			'M');

     --check whether p_ccy_multiplier is not null when needed
     IF p_ccy_multiplier IS NULL THEN
        FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
        FND_MESSAGE.SET_TOKEN('CCY',p_curr_reporting);
        RAISE e_pagg_no_fxrate_found;
     END IF;
  END IF;

  --update dirty flag if semi-dirty
  IF p_dirty IN ('C','S') THEN
     UPDATE qrm_analysis_settings SET dirty='N' WHERE analysis_name=p_name;
  END IF;

  IF (g_event_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dlog('DML','UPDATE QRM_ANALYSIS_SETTINGS.DIRTY=N',
     	'QRM_PA_AGGREGATION_P.CALC_TABLE_TOTAL',g_event_level);--bug 3236479
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.CALC_TABLE_TOTAL');--bug 3236479
  END IF;

EXCEPTION
  WHEN e_pagg_no_fxrate_found THEN
     fnd_msg_pub.add;
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','e_pagg_no_fxrate_found','QRM_PA_AGGREGATION_P.CALC_TABLE_TOTAL',g_error_level);--bug 3236479
     END IF;
  WHEN OTHERS THEN
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.CALC_TABLE_TOTAL',g_error_level);--bug 3236479
     END IF;
END calc_table_total_and_fxrate;



/***************************************************************
This procedure calculate the Totals for Table style using the
currency conversion logic. Moreover, the underlying currency
of the Totals will be returned together with the calculated totals.
Also calculate the currency multipler (FX Rate) for reporting
currency as needed.
***************************************************************/
FUNCTION update_currency_columns(p_indicator NUMBER,
		p_name VARCHAR2,
		p_ref_date DATE,
		v_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE)
        RETURN BOOLEAN IS
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush('QRM_PA_AGGREGATION_P.UPDATE_CURR_COL');
  END IF;
  IF p_indicator=1 THEN
    UPDATE qrm_saved_analyses_row
  	SET curr1=v_curr(1),curr2=v_curr(2),curr3=v_curr(3),
              curr4=v_curr(4),curr5=v_curr(5),curr6=v_curr(6),
              curr7=v_curr(7),curr8=v_curr(8),curr9=v_curr(9),
              curr10=v_curr(10),curr11=v_curr(11),curr12=v_curr(12),
              curr13=v_curr(13),curr14=v_curr(14),curr15=v_curr(15),
              curr16=v_curr(16),curr17=v_curr(17),curr18=v_curr(18),
              curr19=v_curr(19),curr20=v_curr(20),
              curr21=v_curr(21),curr22=v_curr(22),curr23=v_curr(23),
              curr24=v_curr(24),curr25=v_curr(25),curr26=v_curr(26),
              curr27=v_curr(27),curr28=v_curr(28),curr29=v_curr(29),
              curr30=v_curr(30),curr31=v_curr(31),curr32=v_curr(32),
              curr33=v_curr(33),curr34=v_curr(34),curr35=v_curr(35),
              curr36=v_curr(36),curr37=v_curr(37),curr38=v_curr(38),
              curr39=v_curr(39),curr40=v_curr(40),
              curr41=v_curr(41),curr42=v_curr(42),curr43=v_curr(43),
              curr44=v_curr(44),curr45=v_curr(45),curr46=v_curr(46),
              curr47=v_curr(47),curr48=v_curr(48),
                curr49=v_curr(49),curr50=v_curr(50),
              curr51=v_curr(51),curr52=v_curr(52),curr53=v_curr(53),
              curr54=v_curr(54),curr55=v_curr(55),curr56=v_curr(56),
              curr57=v_curr(57),curr58=v_curr(58),curr59=v_curr(59),
              curr60=v_curr(60),curr61=v_curr(61),curr62=v_curr(62),
              curr63=v_curr(63),curr64=v_curr(64),curr65=v_curr(65),
              curr66=v_curr(66),curr67=v_curr(67),curr68=v_curr(68),
              curr69=v_curr(69),curr70=v_curr(70),
              curr71=v_curr(71),curr72=v_curr(72),curr73=v_curr(73),
              curr74=v_curr(74),curr75=v_curr(75),curr76=v_curr(76),
              curr77=v_curr(77),curr78=v_curr(78),curr79=v_curr(79),
              curr80=v_curr(80),curr81=v_curr(81),curr82=v_curr(82),
              curr83=v_curr(83),curr84=v_curr(84),curr85=v_curr(85),
              curr86=v_curr(86),curr87=v_curr(87),curr88=v_curr(88),
              curr89=v_curr(89),curr90=v_curr(90),
              curr91=v_curr(91),curr92=v_curr(92),curr93=v_curr(93),
              curr94=v_curr(94),curr95=v_curr(95),curr96=v_curr(96),
              curr97=v_curr(97),curr98=v_curr(98),
                curr99=v_curr(99),curr100=v_curr(100),
                last_updated_by=FND_GLOBAL.user_id,
                last_update_date=p_ref_date,
                last_update_login=FND_GLOBAL.login_id
  	WHERE analysis_name=p_name;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_ROW.CURR1..100 with p_indicator=1',
           'QRM_PA_AGGREGATION_P.UPDATE_CURRENCY_COLUMNS',g_event_level);
     END IF;

  ELSE --p_indicator=2 where curr1 has the CCY for the row
     UPDATE qrm_saved_analyses_row
  	SET curr2=curr1,curr3=curr1,
              curr4=curr1,curr5=curr1,curr6=curr1,
              curr7=curr1,curr8=curr1,curr9=curr1,
              curr10=curr1,curr11=curr1,curr12=curr1,
              curr13=curr1,curr14=curr1,curr15=curr1,
              curr16=curr1,curr17=curr1,curr18=curr1,
              curr19=curr1,curr20=curr1,
              curr21=curr1,curr22=curr1,curr23=curr1,
              curr24=curr1,curr25=curr1,curr26=curr1,
              curr27=curr1,curr28=curr1,curr29=curr1,
              curr30=curr1,curr31=curr1,curr32=curr1,
              curr33=curr1,curr34=curr1,curr35=curr1,
              curr36=curr1,curr37=curr1,curr38=curr1,
              curr39=curr1,curr40=curr1,
              curr41=curr1,curr42=curr1,curr43=curr1,
              curr44=curr1,curr45=curr1,curr46=curr1,
              curr47=curr1,curr48=curr1,
                curr49=curr1,curr50=curr1,
              curr51=curr1,curr52=curr1,curr53=curr1,
              curr54=curr1,curr55=curr1,curr56=curr1,
              curr57=curr1,curr58=curr1,curr59=curr1,
              curr60=curr1,curr61=curr1,curr62=curr1,
              curr63=curr1,curr64=curr1,curr65=curr1,
              curr66=curr1,curr67=curr1,curr68=curr1,
              curr69=curr1,curr70=curr1,
              curr71=curr1,curr72=curr1,curr73=curr1,
              curr74=curr1,curr75=curr1,curr76=curr1,
              curr77=curr1,curr78=curr1,curr79=curr1,
              curr80=curr1,curr81=curr1,curr82=curr1,
              curr83=curr1,curr84=curr1,curr85=curr1,
              curr86=curr1,curr87=curr1,curr88=curr1,
              curr89=curr1,curr90=curr1,
              curr91=curr1,curr92=curr1,curr93=curr1,
              curr94=curr1,curr95=curr1,curr96=curr1,
              curr97=curr1,curr98=curr1,
                curr99=curr1,curr100=curr1,
                last_updated_by=FND_GLOBAL.user_id,
                last_update_date=p_ref_date,
                last_update_login=FND_GLOBAL.login_id
  	WHERE analysis_name=p_name;

     IF (g_event_level>=g_debug_level) THEN --bug 3236479
        XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_ROW.CURR1..100 with p_indicator='||p_indicator,
           'QRM_PA_AGGREGATION_P.UPDATE_CURRENCY_COLUMNS',g_event_level);
     END IF;

  END IF;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_CURR_COL');
  END IF;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS','QRM_PA_AGGREGATION_P.UPDATE_CURR_COL',g_error_level);--bug 3236479
     END IF;
     RETURN FALSE;
END update_currency_columns;



/***************************************************************
This procedure calculate the Totals for Table style using the
currency conversion logic. Moreover, the underlying currency
of the Totals will be returned together with the calculated totals.
Also calculate the currency multipler (FX Rate) for reporting
currency as needed.
***************************************************************/
FUNCTION update_aggregate_curr(p_name VARCHAR2,
			p_ref_date DATE,
                        p_ccy_case_flag NUMBER,
                        p_ccy_agg_flag NUMBER,
                        p_ccy_agg_level NUMBER,
                        p_row_agg_no NUMBER,
                        p_max_col_no NUMBER,
                        p_underlying_ccy VARCHAR2,
                        p_currency_source VARCHAR2,
                        p_curr_reporting VARCHAR2,
                        p_agg_col_curr IN OUT NOCOPY SYSTEM.QRM_VARCHAR_TABLE)
        RETURN BOOLEAN IS

  v_curr SYSTEM.QRM_VARCHAR_table;
  i NUMBER(3);
  v_success BOOLEAN;
  v_sql VARCHAR2(255);
  v_curr_col_name_map SYSTEM.QRM_VARCHAR_table := SYSTEM.QRM_VARCHAR_table();

  CURSOR get_column_header IS
     SELECT DECODE(type,-2,a1,-1,a1,tot_currency) FROM qrm_saved_analyses_col
        WHERE analysis_name=p_name AND seq_no>p_row_agg_no
        ORDER BY 1;

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_AGG_CURR');--bug 3236479
  END IF;

     IF p_ccy_case_flag=1 THEN
        v_curr := SYSTEM.QRM_VARCHAR_table();
        v_curr.EXTEND(100);
        FOR i IN 1..v_curr.COUNT LOOP
           v_curr(i) := p_underlying_ccy;
        END LOOP;
        v_success := update_currency_columns(1,p_name,p_ref_date,v_curr);
     ELSIF p_ccy_case_flag=2 THEN
        v_curr := SYSTEM.QRM_VARCHAR_table();
        v_curr.EXTEND(100);
        --need to make it into array of size 100 bec. of the
        --update SQL
        FOR i IN 1..p_agg_col_curr.COUNT LOOP
           v_curr(i) := p_agg_col_curr(i);
        END LOOP;
        v_success := update_currency_columns(1,p_name,p_ref_date,v_curr);
     ELSIF p_ccy_case_flag=0 THEN
        IF p_ccy_agg_flag=1 THEN
           v_sql := 'UPDATE qrm_saved_analyses_row SET curr1=DECODE(type,-1,a'||p_ccy_agg_level||',tot_currency) WHERE analysis_name=:analysis_name';
           IF (g_proc_level>=g_debug_level) THEN
              xtr_risk_debug_pkg.dlog('v_sql',v_sql);
           END IF;
           EXECUTE IMMEDIATE v_sql USING p_name;

           IF (g_event_level>=g_debug_level) THEN --bug 3236479
              XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_ROW.CURR1',
                 'QRM_PA_AGGREGATION_P.UPDATE_AGGREGATE_CURR',g_event_level);
           END IF;

           v_success := update_currency_columns(2,p_name,p_ref_date,v_curr);
        ELSIF p_ccy_agg_flag=2 THEN
           OPEN get_column_header;
           FETCH get_column_header BULK COLLECT INTO v_curr;
           CLOSE get_column_header;
           --need to make it into array of size 100 bec. of the
           --update SQL
           v_curr.EXTEND(100-p_max_col_no);
           v_success := update_currency_columns(1,p_name,p_ref_date,v_curr);
        ELSE --p_ccy_agg_flag=0
           v_curr := SYSTEM.QRM_VARCHAR_table();
           v_curr.EXTEND(100);
           FOR i IN 1..v_curr.COUNT LOOP
              v_curr(i) := p_curr_reporting;
           END LOOP;
           v_success := update_currency_columns(1,p_name,p_ref_date,v_curr);
        END IF;
     END IF;

  --insert the currency col name (CURR1, CURR2, ...)
  v_curr_col_name_map.EXTEND(p_max_col_no+p_row_agg_no);
  FOR i IN p_row_agg_no+1..p_row_agg_no+p_max_col_no LOOP
     v_curr_col_name_map(i) := 'CURR'||i;
     UPDATE qrm_saved_analyses_col
	SET curr_col_name_map=v_curr_col_name_map(i)
        WHERE analysis_name=p_name AND seq_no=i;
  END LOOP;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_COL.CURR_COL_NAME',
           'QRM_PA_AGGREGATION_P.UPDATE_AGGREGATE_CURR',g_event_level);
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_AGG_CURR');-- bug 3236479
  END IF;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS',
		'QRM_PA_AGGREGATION_P.UPDATE_AGG_CURR',g_error_level);--bug 3236479
     END IF;
     RETURN FALSE;
END update_aggregate_curr;



/***************************************************************
This function should be called if TB Label in the Setup changed.
i.e. The user prefer to show the user-defined labels in the
cross-tab from showing the End Date.
***************************************************************/
FUNCTION update_timebuckets_label(p_name VARCHAR2)
	RETURN BOOLEAN IS

  v_tb_label VARCHAR2(1);
  i NUMBER(5);
  v_row_agg_no NUMBER(5);
  v_dummy NUMBER;
  CURSOR get_tb_label IS
     SELECT tb_label FROM qrm_analysis_settings
	WHERE analysis_name=p_name AND history_flag='S';
  CURSOR get_row_agg_no IS
     SELECT COUNT(*) FROM qrm_saved_analyses_col
	WHERE analysis_name=p_name AND type=-2;
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_TB_LABEL');
  END IF;

  OPEN get_tb_label;
  FETCH get_tb_label INTO v_tb_label;
  CLOSE get_tb_label;
  IF v_tb_label IS NULL THEN
     FND_MESSAGE.SET_NAME('QRM','QRM_ANA_NO_SETTING');
     FND_MESSAGE.SET_TOKEN('ANALYSIS_NAME',p_name);
     RAISE e_pagg_no_setting_found;
  END IF;
  OPEN get_row_agg_no;
  FETCH get_row_agg_no INTO v_row_agg_no;
  CLOSE get_row_agg_no;

  IF v_tb_label='L' THEN
     --update the qrm_saved_analyses_col by using the tb label
     UPDATE qrm_saved_analyses_col SET a1=tb_label
        WHERE analysis_name=p_name AND seq_no>v_row_agg_no
	AND type<0;
  ELSE --v_tb_label='D'
     --update the qrm_saved_analyses_col by using the end date
     UPDATE qrm_saved_analyses_col SET a1=TO_CHAR(end_date)
        WHERE analysis_name=p_name AND seq_no>v_row_agg_no
	AND type<0;
  END IF;
  COMMIT;

  IF (g_event_level>=g_debug_level) THEN --bug 3236479
     XTR_RISK_DEBUG_PKG.dlog('DML','Updated QRM_SAVED_ANALYSES_COL.A1 with v_tb_label='||v_tb_label,
           'QRM_PA_AGGREGATION_P.UPDATE_TIMEBUCKETS_LABELS',g_event_level);
  END IF;

  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_TB_LABEL');
  END IF;
  RETURN TRUE;

EXCEPTION
  WHEN e_pagg_no_setting_found THEN
     RAISE e_pagg_no_setting_found;

     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','e_pagg_no_setting_found',
		'QRM_PA_AGGREGATION_P.UPDATE_TB_LABEL',g_error_level);--bug 3236479
     END IF;

  WHEN OTHERS THEN

     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS',
		'QRM_PA_AGGREGATION_P.UPDATE_TB_LABEL',g_error_level);--bug 3236479
     END IF;

     RETURN FALSE;
END update_timebuckets_label;



/***************************************************************
This function should be called from OA if the DIRTY indicator
is semi-dirty that does not involved currency updates (S).
***************************************************************/
FUNCTION update_semidirty(p_name VARCHAR2, p_ref_date DATE)
	RETURN VARCHAR2 IS

  v_style VARCHAR2(1);
  v_success BOOLEAN := TRUE;
  CURSOR get_style IS
     SELECT style FROM qrm_analysis_settings
	WHERE analysis_name=p_name AND history_flag='S';
BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.UPDATE_SEMIDIRTY');
  END IF;
  --initialize fnd_msg_pub if it has not been intialized
  IF fnd_msg_pub.count_msg>0 THEN
     fnd_msg_pub.Initialize;
  END IF;
  --check whether analysis settings still there by looking whether the required
  --column value return IS NULL or not
  OPEN get_style;
  FETCH get_style INTO v_style;
  CLOSE get_style;
  IF v_style IS NULL THEN
     FND_MESSAGE.SET_NAME('QRM','QRM_ANA_NO_SETTING');
     FND_MESSAGE.SET_TOKEN('ANALYSIS_NAME',p_name);
     RAISE e_pagg_no_setting_found;
  END IF;

  --update total
  v_success := update_total(p_name,p_ref_date);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('update_semidirty: ' || 'v_successT',v_success);
END IF;
  IF NOT v_success THEN
     RAISE e_pagg_update_total_fail;
  END IF;
  --update percent
  v_success := update_percent (p_name,p_ref_date);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('update_semidirty: ' || 'v_success%',v_success);
END IF;
  IF NOT v_success THEN
     RAISE e_pagg_update_percent_fail;
  END IF;
  --update timebuckets label
  IF v_style='X' THEN
     v_success := update_timebuckets_label(p_name);
IF (g_proc_level>=g_debug_level) THEN
   xtr_risk_debug_pkg.dlog('update_semidirty: ' || 'v_successTBLabel',v_success);
END IF;
     IF NOT v_success THEN
        RAISE e_pagg_update_tb_label_fail;
     END IF;
  END IF;

  --update dirty flag
  UPDATE qrm_analysis_settings SET dirty='N' WHERE analysis_name=p_name;
  COMMIT;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.UPDATE_SEMIDIRTY');
  END IF;
  RETURN 'T';
EXCEPTION
  WHEN e_pagg_no_setting_found THEN
     fnd_msg_pub.add;
     --bug 3236479
	   IF (g_proc_level>=g_ERROR_level) THEN
	      XTR_RISK_DEBUG_PKG.dlog('EXCEPTION','QRM_PA_AGGREGATION_P.E_PAGG_NO_SETTING_FOUND',
	         'QRM_PA_AGGREGATION_P.UPDATE_SEMIDIRTY',
		 g_error_level);
	   END IF;
     RETURN 'F';
  WHEN OTHERS THEN

     IF (g_error_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','OTHERS',
		'QRM_PA_AGGREGATION_P.UPDATE_SEMIDIRTY',g_error_level);--bug 3236479
     END IF;

     RETURN 'F';
END update_semidirty;



/***************************************************************
This function find the FX Spot Rate. If there is MD_SET_CODE defined
this will call xtr_market_data_p.get_md_from_set otherwise
this will call qrm_calculators_p.get_rates_from_base
***************************************************************/
FUNCTION get_fx_rate(p_md_set_code VARCHAR2,
			p_spot_date DATE,
			p_base_ccy VARCHAR2,
			p_contra_ccy VARCHAR2,
			p_side VARCHAR2)
	RETURN NUMBER IS

  v_md_in xtr_market_data_p.md_from_set_in_rec_type;
  v_md_out xtr_market_data_p.md_from_set_out_rec_type;
  v_ccy_multiplier NUMBER;
  v_bid_rate_comm NUMBER;
  v_ask_rate_comm NUMBER;
  v_bid_rate_base NUMBER;
  v_ask_rate_base NUMBER;
  v_ccy VARCHAR2(15);

  --use the same cursor as in XTR_MARKET_DATA_P.GET_MD_FROM_SET
  CURSOR get_fx_spot_rates IS
     SELECT usd_base_curr_bid_rate bid_rate,
	usd_base_curr_offer_rate ask_rate,
	1/usd_base_curr_offer_rate bid_rate_base,
	1/usd_base_curr_bid_rate ask_rate_base,
	currency
  	FROM xtr_spot_rates
	WHERE (rate_date, currency) IN (SELECT MAX(rate_date), currency
		FROM xtr_spot_rates
		WHERE currency IN (p_base_ccy, p_contra_ccy)
		AND currency <> 'USD'
		AND trunc(rate_date) <= trunc(p_spot_date)
		GROUP BY currency);

BEGIN
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpush(null,'QRM_PA_AGGREGATION_P.GET_FX_RATE');
  END IF;

  IF p_base_ccy=p_contra_ccy THEN
     v_ccy_multiplier := 1;
  ELSE
     IF p_md_set_code IS NOT NULL THEN
        v_md_in.p_md_set_code := p_md_set_code;
        v_md_in.p_source := 'C';
        v_md_in.p_indicator := 'S';
        v_md_in.p_spot_date := p_spot_date;
        v_md_in.p_ccy := p_base_ccy;
        v_md_in.p_contra_ccy := p_contra_ccy;
        v_md_in.p_side := p_side;
        xtr_market_data_p.get_md_from_set(v_md_in,v_md_out);
        --Round the FX Spot
        v_ccy_multiplier := v_md_out.p_md_out;
     ELSE
        OPEN get_fx_spot_rates;
        FETCH get_fx_spot_rates INTO v_bid_rate_comm, v_ask_rate_comm,
					     v_bid_rate_base, v_ask_rate_base,
					     v_ccy;
        CLOSE get_fx_spot_rates;
        IF v_bid_rate_comm IS NULL THEN
           FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
           FND_MESSAGE.SET_TOKEN('CCY',p_contra_ccy);
           RAISE e_pagg_no_fxrate_found;
        ELSE
           IF p_side IN ('A','ASK') THEN
              IF p_base_ccy='USD' THEN --use Commodity Quote Basis
                 v_ccy_multiplier := v_ask_rate_comm;
              ELSE
                 v_ccy_multiplier := v_ask_rate_base;
              END IF;
 	   ELSIF p_side IN ('B','BID') THEN
              IF p_base_ccy='USD' THEN --use Commodity Quote Basis
                 v_ccy_multiplier := v_bid_rate_comm;
              ELSE
                 v_ccy_multiplier := v_bid_rate_base;
              END IF;
           ELSE --'MID'
              IF p_base_ccy='USD' THEN --use Commodity Quote Basis
                 v_ccy_multiplier := (v_ask_rate_comm+v_bid_rate_comm)/2;
              ELSE
                 v_ccy_multiplier := (v_ask_rate_base+v_bid_rate_base)/2;
              END IF;
           END IF;
        END IF;
     END IF;

  END IF;
  IF (g_proc_level>=g_debug_level) THEN
     xtr_risk_debug_pkg.dpop(null,'QRM_PA_AGGREGATION_P.GET_FX_RATE');
  END IF;
  RETURN v_ccy_multiplier;

EXCEPTION
  WHEN xtr_market_data_p.e_mdcs_no_data_found THEN

     IF (G_ERROR_level>=g_debug_level) THEN
        xtr_risk_debug_pkg.dlog('EXCEPTION','xtr_market_data.e_mdcs_no_data_found',
		'QRM_PA_AGGREGATION_P.GET_FX_RATE',g_eRROR_level);--bug 3236479
     END IF;

     FND_MESSAGE.SET_NAME('QRM','QRM_CALC_NO_DEFAULT_SPOT_ERR');
     FND_MESSAGE.SET_TOKEN('CCY',p_contra_ccy);
     RAISE e_pagg_no_fxrate_found;
END get_fx_rate;




END QRM_PA_AGGREGATION_P;

/
