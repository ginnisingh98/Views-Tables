--------------------------------------------------------
--  DDL for Package Body JG_RX_FAREG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_RX_FAREG" AS
/* $Header: jgrxfrb.pls 120.25.12010000.4 2008/08/04 13:53:38 vgadde ship $ */

  -- Structure to hold values of parameters
  -- These include parameters which are passed in the core

  TYPE param_t IS RECORD (
        p_book_type_code             VARCHAR2(15),
        p_period_from	             VARCHAR2(20),
        p_period_to                  VARCHAR2(20),
        p_major_category             VARCHAR2(150),
        p_minor_category             VARCHAR2(150),
        p_begin_period_from_date     DATE,             -- for where clause
        p_begin_period_to_date       DATE,             -- for where clause
        p_end_period_from_date       DATE,             -- for where clause
        p_end_period_to_date         DATE,             -- for where clause
        p_begin_period_counter       NUMBER(15),
        p_end_period_counter         NUMBER(15),
        p_fiscal_year_start_date     DATE,
        x_fiscal_year                NUMBER(4)
                        );
  parm param_t;
  X_Account_Segment                  VArchar2(50);    -- used to store the Account Segment Name
  X_major_segment                    VARCHAR2(20);     -- used to store major segment
  X_minor_segment                    VARCHAR2(20);     -- used to store minor segment
  X_minor_segment_sel                    VARCHAR2(20);     -- used to store minor segment
  X_where_clause_tmp                 VARCHAR2(1000);
  X_transaction_id_initial           NUMBER;           -- used to stored first transaction for asset
  X_transaction_id_final             NUMBER;           -- used to stored last transaction for asset
  X_fiscal_year                      NUMBER(4);
  X_fiscal_year1                     NUMBER(4);
  X_fiscal_year_start_date           DATE;
  X_fiscal_year_end_date             DATE;
  X_rate1                            NUMBER;
  X_method_id1                       NUMBER;
  X_first_row                        BOOLEAN;
  X_request_id                       NUMBER;
  X_last_update_date                 DATE;
  X_last_updated_by                  NUMBER;
  X_last_update_login                NUMBER;
  X_creation_date                    DATE;
  X_created_by                       NUMBER;
  X_deprn_calendar                   VARCHAR2(15);
  X_number_per_fiscal_year 	     NUMBER;
  X_prorate_calendar                 VARCHAR2(15);
  method_type                        NUMBER;
  success                            INTEGER;
/*===================================================================+
|                      fa_get_report                                 |
+====================================================================*/

  PROCEDURE fa_get_report(
        p_book_type_code       IN  VARCHAR2,
        p_period_from          IN  VARCHAR2,
        p_period_to            IN  VARCHAR2,
        p_dummy                IN  NUMBER,
        p_major_category       IN  VARCHAR2,
        p_minor_category       IN  VARCHAR2,
        p_type                 IN  VARCHAR2,  -- ASSET or RTRMNT
        request_id             IN  NUMBER,
        retcode                OUT NOCOPY NUMBER,
        errbuf                 OUT NOCOPY VARCHAR2
       )
  IS

  X_section_name               VARCHAR2(20);
  X_calling_proc               VARCHAR2(70);
  X_before_report              VARCHAR2(300);
  X_bind                       VARCHAR2(300) := NULL;
  X_after_fetch                VARCHAR2(300) := NULL;
  X_after_report               VARCHAR2(300) := NULL;


    BEGIN

      -- Inizialize Variables
      X_section_name   := 'Get_' || p_type || '_Details';
      X_calling_proc   := 'JG_RX_FAREG.fa_get_report';
      X_before_report  := 'JG_RX_FAREG.fa_' || p_type || '_before_report'|| ';';
      X_bind           := 'JG_RX_FAREG.fa_' || p_type || '_bind' || '(:CURSOR_SELECT);';
      X_after_fetch    := 'JG_RX_FAREG.fa_' || p_type || '_after_fetch'|| ';';
      X_after_report   := 'JG_RX_FAREG.fa_' || p_type || '_after_report'|| ';';

      FA_RX_UTIL_PKG.debug(X_calling_proc || '()+');
     FA_RX_UTIL_PKG.debug(X_calling_proc || '(amar)+');

      FA_RX_UTIL_PKG.init_request(X_calling_proc, request_id);

      -- Store the parameters in a variable which can be accesed globally accross all procedures
      PARM.p_book_type_code          := p_book_type_code;
      PARM.p_period_from             := p_period_from;
      PARM.p_period_to               := p_period_to;
      PARM.p_major_category          := p_major_category;
      PARM.p_minor_category          := p_minor_category;


      X_request_id := request_id;

      -- Who columns
      X_last_update_date   := SYSDATE;
      X_last_updated_by    := FND_GLOBAL.user_id;
      X_last_update_login  := FND_GLOBAL.login_id;
      X_creation_date      := SYSDATE;
      X_created_by         := FND_GLOBAL.user_id;


      -- Call the procedure to find date of parm_period
      Get_period_date(p_period_from, p_period_to);
      Get_fiscal_year_date;
      PARM.p_fiscal_year_start_date := X_fiscal_year_start_date ;

      -- Call the core report.This executes the core report and the SELECT statement of the core
      -- is built.
      -- No data is inserted into the interface table.

      FA_RX_UTIL_PKG.debug('FA_RX_UTIL_PKG.assign_report(' || X_section_name);
      FA_RX_UTIL_PKG.debug('                              TRUE');
      FA_RX_UTIL_PKG.debug('                             ' || X_before_report);
      FA_RX_UTIL_PKG.debug('                             ' || X_bind);
      FA_RX_UTIL_PKG.debug('                             ' || X_after_fetch);
      FA_RX_UTIL_PKG.debug('                             ' || X_after_report);
      FA_RX_UTIL_PKG.debug('                             )');

      FA_RX_UTIL_PKG.assign_report(X_section_name,
                                   TRUE,
                                   X_before_report,
                                   X_bind,
                                   X_after_fetch,
                                   X_after_report);

      FA_RX_UTIL_PKG.run_report(X_calling_proc, retcode, errbuf);

      FA_RX_UTIL_PKG.debug(X_calling_proc || '()-');

    END fa_get_report;


/*****************************************************************************************************

                             A S S E T

*****************************************************************************************************/

/*===================================================================+
|                 fa_ASSET_before_report                             |
+====================================================================*/
  -- This is the before report trigger for the main Report. The code which is written in the " BEFORE
  -- REPORT " triggers has been incorporated over here. The code is the common code accross all the
  -- reports.

  PROCEDURE fa_ASSET_before_report
  IS


   BEGIN
       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_before_report()+');


       -- It takes the segment condition, Company name, currency code and store in placeholder variable
       Startup;

    -- This gets the segment name of the account flexfield qualifier which corresponds to this chart of accounts
       X_Account_Segment := Get_Account_segment;

       -- Assign SELECT list
       -- the Select statement is build over here

       -- FA_RX_UTIL_PKG.assign_column(#, select, insert, place, type, len);
        fa_rx_util_pkg.debug(' checking if value is available'||to_char(X_fiscal_year_start_date));

       -->>SELECT_START<<--

       FA_RX_UTIL_PKG.assign_column('1', NULL, 'organization_name','JG_RX_FAREG.var.organization_name','VARCHAR2',60);
       FA_RX_UTIL_PKG.assign_column('2', NULL, 'functional_currency_code','JG_RX_FAREG.var.functional_currency_code', 'VARCHAR2',15);

       FA_RX_UTIL_PKG.assign_column('3', 'CA.' || X_major_segment, 'major_category','JG_RX_FAREG.var.major_category','VARCHAR2', 30);
       FA_RX_UTIL_PKG.assign_column('4', X_minor_segment_sel, 'minor_category','JG_RX_FAREG.var.minor_category','VARCHAR2', 30);

       FA_RX_UTIL_PKG.assign_column('5', NULL, 'deprn_rate','JG_RX_FAREG.var.deprn_rate','NUMBER');

       FA_RX_UTIL_PKG.assign_column('6', NULL,'starting_deprn_year','JG_RX_FAREG.var.starting_deprn_year','VARCHAR2', 4);

/* FA_RX_UTIL_PKG.assign_column('7', 'TO_CHAR(BO.date_placed_in_service,"YYYY")','starting_deprn_year','JG_RX_FAREG.var.starting_deprn_year','VARCHAR2', 4);
*/
 FA_RX_UTIL_PKG.assign_column('7', 'BO.date_placed_in_service','date_placed_in_service','JG_RX_FAREG.var.date_placed_in_service','DATE');

       FA_RX_UTIL_PKG.assign_column('8', 'BO.asset_id', NULL,'JG_RX_FAREG.var.asset_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('9', 'AD.asset_number', 'asset_number','JG_RX_FAREG.var.asset_number','VARCHAR2', 25);
       FA_RX_UTIL_PKG.assign_column('10', 'AD.description', 'description','JG_RX_FAREG.var.description','VARCHAR2', 80);

       FA_RX_UTIL_PKG.assign_column('11', 'AD.parent_asset_id', NULL,'JG_RX_FAREG.var.parent_asset_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('12', NULL, 'parent_asset_number','JG_RX_FAREG.var.parent_asset_number','VARCHAR2', 15);

       FA_RX_UTIL_PKG.assign_column('13', 'BO.original_cost', 'asset_cost_orig','JG_RX_FAREG.var.asset_cost_orig','NUMBER');

       FA_RX_UTIL_PKG.assign_column('14', NULL, 'bonus_rate','JG_RX_FAREG.var.bonus_rate','NUMBER');

       FA_RX_UTIL_PKG.assign_column('15', NULL, 'invoice_number','JG_RX_FAREG.var.invoice_number','VARCHAR2', 50);
       FA_RX_UTIL_PKG.assign_column('16', NULL, 'supplier_name','JG_RX_FAREG.var.supplier_name','VARCHAR2', 360);

       FA_RX_UTIL_PKG.assign_column('17', 'CB.asset_cost_acct', 'cost_account','JG_RX_FAREG.var.cost_account','VARCHAR2', 25);

       FA_RX_UTIL_PKG.assign_column('18', NULL, 'expense_account','JG_RX_FAREG.var.expense_account','VARCHAR2', 25);
       FA_RX_UTIL_PKG.assign_column('19', 'CB.deprn_reserve_acct', 'reserve_account','JG_RX_FAREG.var.reserve_account','VARCHAR2', 25);

       FA_RX_UTIL_PKG.assign_column('20', 'CB.bonus_deprn_expense_acct', 'bonus_deprn_account','JG_RX_FAREG.var.bonus_deprn_account','VARCHAR2', 25);
       FA_RX_UTIL_PKG.assign_column('21', 'CB.bonus_deprn_reserve_acct', 'bonus_reserve_account','JG_RX_FAREG.var.bonus_reserve_account','VARCHAR2', 25);

       FA_RX_UTIL_PKG.assign_column('22', NULL, 'asset_cost_initial','JG_RX_FAREG.var.asset_cost_initial', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('23', NULL, 'asset_cost_increase','JG_RX_FAREG.var.asset_cost_increase', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('24', NULL, 'asset_cost_decrease','JG_RX_FAREG.var.asset_cost_decrease', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('25', NULL, 'asset_cost_final','JG_RX_FAREG.var.asset_cost_final', 'NUMBER');

       FA_RX_UTIL_PKG.assign_column('26', NULL, 'revaluation_initial','JG_RX_FAREG.var.revaluation_initial', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('27', NULL, 'revaluation_increase','JG_RX_FAREG.var.revaluation_increase', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('28', NULL, 'revaluation_decrease','JG_RX_FAREG.var.revaluation_decrease', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('29', NULL, 'revaluation_final','JG_RX_FAREG.var.revaluation_final', 'NUMBER');

       FA_RX_UTIL_PKG.assign_column('30', NULL, 'deprn_reserve_initial','JG_RX_FAREG.var.deprn_reserve_initial', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('31', NULL, 'deprn_reserve_increase','JG_RX_FAREG.var.deprn_reserve_increase', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('32', NULL, 'deprn_reserve_decrease','JG_RX_FAREG.var.deprn_reserve_decrease', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('33', NULL, 'deprn_reserve_final','JG_RX_FAREG.var.deprn_reserve_final', 'NUMBER');

       FA_RX_UTIL_PKG.assign_column('34', NULL, 'bonus_reserve_initial','JG_RX_FAREG.var.bonus_reserve_initial', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('35', NULL, 'bonus_reserve_increase','JG_RX_FAREG.var.bonus_reserve_increase', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('36', NULL, 'bonus_reserve_decrease','JG_RX_FAREG.var.bonus_reserve_decrease', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('37', NULL, 'bonus_reserve_final','JG_RX_FAREG.var.bonus_reserve_final', 'NUMBER');

       FA_RX_UTIL_PKG.assign_column('38', NULL, 'net_book_value_initial','JG_RX_FAREG.var.net_book_value_initial', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('39', NULL, 'net_book_value_increase','JG_RX_FAREG.var.net_book_value_increase', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('40', NULL, 'net_book_value_decrease','JG_RX_FAREG.var.net_book_value_decrease', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('41', NULL, 'net_book_value_final','JG_RX_FAREG.var.net_book_value_final', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('42', NULL, 'transaction_date','JG_RX_FAREG.var.transaction_date', 'DATE');
       FA_RX_UTIL_PKG.assign_column('43', NULL, 'transaction_number','JG_RX_FAREG.var.transaction_number', 'NUMBER');
       FA_RX_UTIL_PKG.assign_column('44', NULL, 'transaction_code','JG_RX_FAREG.var.transaction_code', 'VARCHAR2', 20);
       FA_RX_UTIL_PKG.assign_column('45', NULL, 'transaction_amount','JG_RX_FAREG.var.transaction_amount', 'NUMBER');
--       FA_RX_UTIL_PKG.assign_column('46', 'BO.date_placed_in_service', NULL,'JG_RX_FAREG.var.date_placed_in_service','DATE');
       FA_RX_UTIL_PKG.assign_column('47', 'BO.prorate_date', NULL,'JG_RX_FAREG.var.prorate_date','DATE');
       FA_RX_UTIL_PKG.assign_column('48', 'METH.method_id', NULL,'JG_RX_FAREG.var.method_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('49', 'METH.rate_source_rule', NULL,'JG_RX_FAREG.var.rate_source_rule','VARCHAR2', 10);
       FA_RX_UTIL_PKG.assign_column('50', 'BO.adjusted_rate', NULL,'JG_RX_FAREG.var.adjusted_rate','NUMBER');
--Modified for ECE Project
       FA_RX_UTIL_PKG.assign_column('51', 'BO.life_in_months', 'life_in_months','JG_RX_FAREG.var.life_in_months','NUMBER');
--
       FA_RX_UTIL_PKG.assign_column('52', 'BO.bonus_rule', NULL,'JG_RX_FAREG.var.bonus_rule','VARCHAR2', 30);
       FA_RX_UTIL_PKG.assign_column('53', NULL,'asset_heading','JG_RX_FAREG.var.asset_heading','VARCHAR2', 15);
       FA_RX_UTIL_PKG.assign_column('54', NULL,'initial_heading','JG_RX_FAREG.var.initial_heading','VARCHAR2', 15);         -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('55', '''Variation''','variation_heading','JG_RX_FAREG.var.variation_heading','VARCHAR2', 15);   -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('56', '''------------------------------------------------------------------------------------------------------------------------------------''','final_heading',
              'JG_RX_FAREG.var.final_heading','VARCHAR2', 132);               -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('57', NULL, 'asset_variation','JG_RX_FAREG.var.asset_variation', 'NUMBER');  -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('58', NULL, 'reval_variation','JG_RX_FAREG.var.reval_variation', 'NUMBER');  -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('59', NULL, 'deprn_variation','JG_RX_FAREG.var.deprn_variation', 'NUMBER');  -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('60', NULL, 'bonus_variation','JG_RX_FAREG.var.bonus_variation', 'NUMBER');  -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('61', NULL, 'netbo_variation','JG_RX_FAREG.var.netbo_variation', 'NUMBER');  -- 09/08/00 AFERRARA
       FA_RX_UTIL_PKG.assign_column('62', NULL, 'revaluation_total','JG_RX_FAREG.var.revaluation_total', 'NUMBER');  -- 09/08/00 AFERRARA
--- Added for ECE Project
FA_RX_UTIL_PKG.assign_column('63', 'METH.method_code', 'depreciation_method','JG_RX_FAREG.var.depriciation_method', 'VARCHAR2', 12);
FA_RX_UTIL_PKG.assign_column('64', 'BO.prorate_convention_code','prorate_convention','JG_RX_FAREG.var.prorate_convention', 'VARCHAR2',10);
FA_RX_UTIL_PKG.assign_column('65', 'AD.tag_number', 'tag_number','JG_RX_FAREG.var.tag_number', 'VARCHAR2',15);
FA_RX_UTIL_PKG.assign_column('66', 'AD.serial_number', 'serial_number','JG_RX_FAREG.var.serial_number', 'VARCHAR2',35);
FA_RX_UTIL_PKG.assign_column('67', 'AD.asset_key_ccid', NULL,'JG_RX_FAREG.var.asset_key_ccid', 'NUMBER');
FA_RX_UTIL_PKG.assign_column('68', NULL, 'asset_key_flexfield','JG_RX_FAREG.var.asset_key_flexfield', 'VARCHAR2',320); -- bug 4969343
FA_RX_UTIL_PKG.assign_column('69', NULL, 'life_in_years','JG_RX_FAREG.var.life_in_years','NUMBER');
---
--Added the following column as part of the fix for bug 3240485
 FA_RX_UTIL_PKG.assign_column('70', NULL, 'ytd_deprn','JG_RX_FAREG.var.ytd_deprn', 'NUMBER');
FA_RX_UTIL_PKG.assign_column('69', NULL, 'life_in_years','JG_RX_FAREG.var.life_in_months','NUMBER');
--Added the above part to fix bug 3240485

/*       FA_RX_UTIL_PKG.assign_column('7', 'BO.date_placed_in_service','date_placed_in_service','JG_RX_FAREG.var.date_placed_in_service','DATE');
        FA_RX_UTIL_PKG.assign_column('63','BO.flag' , 'short_fiscal_year_flag','JG_RX_FAREG.short_fiscal_year_flag', 'VARCHAR2', 3); --07/11/03 APRABHUN
*/
       -->>SELECT_END<<--


       --
       -- Assign From Clause
       --
       FA_RX_UTIL_PKG.From_Clause :=
         'fa_books BO,
         fa_additions      AD,
         fa_categories     CA,
         fa_category_books CB,
         fa_methods        METH';


       --
       -- Assign Where Clause
       --

       FA_RX_UTIL_PKG.Where_clause:=
             '     AD.asset_id = BO.asset_id' ||
             ' AND AD.in_use_flag = ''YES''' ||
             ' AND AD.asset_category_id = CA.category_id' ||
             ' AND (BO.date_effective,transaction_header_id_in) = (SELECT MAX(date_effective),'||
             '                                     max(transaction_header_id_in)' ||
             '                             FROM fa_books' ||
             '                               WHERE date_placed_in_service <= :b_period_to_date' ||
--    '      WHERE date_effective < :b_period_to_date' ||  // Date_effective -> Date_placed_in_service
             '                             AND book_type_code = bo.book_type_code' ||
             '                             AND asset_id       = BO.asset_id)' ||
             ' AND AD.asset_type = ''CAPITALIZED''' ||
             ' AND ((BO.period_counter_fully_retired IS NULL)'||
             '       OR ((BO.period_counter_fully_retired IS NOT NULL)'||
             '            AND BO.TRANSACTION_HEADER_ID_IN ='||
             '                  ( SELECT RE.TRANSACTION_HEADER_ID_IN'||
             '                     FROM FA_RETIREMENTS RE'||
             '                     WHERE BO.ASSET_ID = RE.ASSET_ID'||
             '                     AND BO.TRANSACTION_HEADER_ID_IN = RE.TRANSACTION_HEADER_ID_IN'||
             '                     AND RE.DATE_RETIRED >=:b_fiscal_year_start_date)))'||
             ' AND CB.category_id = CA.category_id' ||
             ' AND CB.book_type_code = BO.book_type_code' ||
             ' AND BO.deprn_method_code = METH.method_code' ||
             ' AND NVL(BO.life_in_months,-99) = NVL(METH.life_in_months,-99)';



       -- It takes the segment condition
       IF X_where_clause_tmp IS NOT NULL THEN
          FA_RX_UTIL_PKG.Where_Clause := FA_RX_UTIL_PKG.Where_clause || X_where_clause_tmp;
       END IF;

       IF PARM.p_book_type_code IS NOT NULL THEN
          FA_RX_UTIL_PKG.Where_clause := FA_RX_UTIL_PKG.Where_clause ||
                                       ' AND BO.book_type_code  = :b_book_type_code ';
       END IF;

       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_before_report()-');

   END fa_ASSET_before_report;



/*===================================================================+
|                        fa_ASSET_bind                              |
+====================================================================*/
      -- This is the bind trigger for the  Assets
      PROCEDURE fa_ASSET_bind (c IN INTEGER)
      IS
        b_major_category    VARCHAR2(20);
        b_minor_category    VARCHAR2(20);
        b_period_from_date  VARCHAR2(20);
        b_period_to_date    VARCHAR2(20);
        b_book_type_code    VARCHAR2(15);
        b_fiscal_year_start_date DATE;

      BEGIN
        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_bind()+');

        IF PARM.p_end_period_to_date IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_period_to_date');
          DBMS_SQL.bind_variable(c, 'b_period_to_date', PARM.p_end_period_to_date);
        END IF;

        IF PARM.p_major_category IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding major_category');
          DBMS_SQL.bind_variable(c, 'b_major_category', PARM.p_major_category);
        END IF;

        IF PARM.p_minor_category IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_minor_category');
          DBMS_SQL.bind_variable(c, 'b_minor_category', PARM.p_minor_category);
        END IF;

        IF PARM.p_book_type_code IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_book_type_code '|| PARM.p_book_type_code);
          DBMS_SQL.bind_variable(c, 'b_book_type_code', PARM.p_book_type_code);
        END IF;

        IF PARM.p_fiscal_year_start_date IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_fiscal_year_start_date'|| to_char( PARM.p_fiscal_year_start_date ,'DD/MM/YY'));
          DBMS_SQL.bind_variable(c, 'b_fiscal_year_start_date', PARM.p_fiscal_year_start_date);
        END IF;


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_bind()-');

     END fa_ASSET_bind;


/*===================================================================+
|                      fa_ASSET_after_fetch                         |
+====================================================================*/
      -- The after fetch trigger fires after the Select statement has executed
      PROCEDURE fa_ASSET_after_fetch IS
      X_msg       VARCHAR2(100);
      BEGIN
         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_after_fetch()+');

         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_id =' || TO_CHAR(JG_RX_FAREG.var.asset_id));

	-- Added for ECE Project
	-- This code is added to get the Asset Flexfield
        -- concatenated segment value

     BEGIN
		SELECT number_per_fiscal_year
        	INTO X_number_per_fiscal_year
        	FROM fa_calendar_types
       	 	WHERE calendar_type = X_deprn_calendar;
       	JG_RX_FAREG.var.life_in_years :=
                 JG_RX_FAREG.var.life_in_months / X_number_per_fiscal_year;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.fa_ASSET_after_fetch: NO_DATA_FOUND';
	     x_msg := x_msg || ' -  Error in getting number_per_fiscal_year';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.fa_ASSET_after_fetch: TOO_MANY_ROWS';
             x_msg := x_msg || ' -  Error in getting number_per_fiscal_year';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);
     END;

     BEGIN
        IF JG_RX_FAREG.var.asset_key_ccid IS NOT NULL THEN
		SELECT trim(padded_concatenated_segments)
		INTO JG_RX_FAREG.var.asset_key_flexfield
		FROM FA_ASSET_KEYWORDS_KFV
		WHERE CODE_COMBINATION_ID=JG_RX_FAREG.var.asset_key_ccid;
        ELSE
		JG_RX_FAREG.var.asset_key_flexfield := NULL;
        END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.fa_ASSET_after_fetch: NO_DATA_FOUND';
	     x_msg := x_msg || ' -  Error in getting Asset Flexfield Value ';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.fa_ASSET_after_fetch: TOO_MANY_ROWS';
	     x_msg := x_msg || ' -  Error in getting Asset Flexfield Value ';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);


    END;
	--   End for ECE Project

        --Clear the Parent Asset Number
          JG_RX_FAREG.var.parent_asset_number := NULL;
         -- It takes the parent asset number
         IF JG_RX_FAREG.var.parent_asset_id IS NOT NULL THEN
            JG_RX_FAREG.var.parent_asset_number := Get_parent_asset_number;
         END IF;
         JG_RX_FAREG.var.asset_heading := 'ASSET NUMBER ';
         JG_RX_FAREG.var.starting_deprn_year := to_char(JG_RX_FAREG.var.date_placed_in_service,'YYYY');
         FA_RX_UTIL_PKG.debug('date_placed_in_service'||to_char(JG_RX_FAREG.var.date_placed_in_service));
          FA_RX_UTIL_PKG.debug('Starting deprn Year' || JG_RX_FAREG.var.starting_deprn_year);
         -- It takes the cost values


        FA_RX_UTIL_PKG.debug('PARM.p_period_from'||PARM.p_period_from);
        FA_RX_UTIL_PKG.debug('PARM.p_period_to'||PARM.p_period_to);

         JG_RX_FAREG.var.expense_account := null;
        if X_Account_segment <> 'NONE'then
            Get_Deprn_Accounts;
       end if;

        Get_cost_value;

         -- It takes the revaluation values
         Get_revaluation;

         -- It takes the cost values
         Get_deprn_reserve_value;

         -- It takes the cost values
         Get_bonus_reserve_value;

         -- It takes the fiscal year start and end date
         Get_fiscal_year_date;

         -- It takes the bonus rate
         Get_bonus_rate;

         -- It takes the depreciation rate
         Get_depreciation_rate;

        -- It gets the invoice_number  and the supplier name
         Get_invoice_number;


         -- It takes the net book value
         Get_Net_Book_Value;

         -- It takes the transactions
         X_first_row := FALSE; -- It must be FALSE the first time
         JG_RX_FAREG.var.transaction_date   := NULL;
         JG_RX_FAREG.var.transaction_number := NULL;
         JG_RX_FAREG.var.transaction_code   := NULL;
         JG_RX_FAREG.var.transaction_amount := NULL;
         Get_Transactions;

         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_after_fetch()-');
      END fa_ASSET_after_fetch;


/*===================================================================+
|                      fa_ASSET_after_report                        |
+====================================================================*/
      PROCEDURE fa_ASSET_after_report IS
      BEGIN
         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_after_report()+');

         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_ASSET_after_report()-');
      END fa_ASSET_after_report;


/*****************************************************************************************************

                             R E T I R E M E N T

*****************************************************************************************************/

/*===================================================================+
|                 fa_RTRMNT_before_report                            |
+====================================================================*/
  -- This is the before report trigger for the main Report. The code which is written in the " BEFORE
  -- REPORT " triggers has been incorporated over here. The code is the common code accross all the
  -- reports.

  PROCEDURE fa_RTRMNT_before_report
  IS


   BEGIN
       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_before_report()+');


       -- It takes the segment condition, Company name, currency code and store in placeholder variable
       Startup;

       --Assign SELECT list
       -- the Select statement is build over here

       -- FA_RX_UTIL_PKG.assign_column(#, select, insert, place, type, len);


       -->>SELECT_START<<--

       FA_RX_UTIL_PKG.assign_column('1', NULL, 'organization_name','JG_RX_FAREG.var.organization_name','VARCHAR2',60);
       FA_RX_UTIL_PKG.assign_column('2', NULL, 'functional_currency_code','JG_RX_FAREG.var.functional_currency_code', 'VARCHAR2',15);

       FA_RX_UTIL_PKG.assign_column('3', 'CA.' || X_major_segment, 'major_category','JG_RX_FAREG.var.major_category','VARCHAR2', 30);
       FA_RX_UTIL_PKG.assign_column('4', X_minor_segment_sel, 'minor_category','JG_RX_FAREG.var.minor_category','VARCHAR2', 30);

       FA_RX_UTIL_PKG.assign_column('5', 'AD.asset_number', 'asset_number','JG_RX_FAREG.var.asset_number','VARCHAR2', 15);
       FA_RX_UTIL_PKG.assign_column('6', 'AD.description', 'description','JG_RX_FAREG.var.description','VARCHAR2', 80);

       FA_RX_UTIL_PKG.assign_column('7', 'AD.parent_asset_id', NULL,'JG_RX_FAREG.var.parent_asset_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('8', NULL, 'parent_asset_number','JG_RX_FAREG.var.parent_asset_number','VARCHAR2', 15);

       FA_RX_UTIL_PKG.assign_column('9', 'BO.original_cost', 'asset_cost_orig','JG_RX_FAREG.var.asset_cost_orig','NUMBER');
       FA_RX_UTIL_PKG.assign_column('10', 'RE.proceeds_of_sale', 'sales_amount','JG_RX_FAREG.var.sales_amount','NUMBER');
       FA_RX_UTIL_PKG.assign_column('11', 'RE.cost_retired', 'cost_retired','JG_RX_FAREG.var.cost_retired','NUMBER');
       FA_RX_UTIL_PKG.assign_column('12',  NULL, 'deprn_reserve','JG_RX_FAREG.var.deprn_reserve','NUMBER');
       FA_RX_UTIL_PKG.assign_column('13',  NULL, 'bonus_reserve','JG_RX_FAREG.var.bonus_reserve','NUMBER');
       FA_RX_UTIL_PKG.assign_column('14', 'RE.nbv_retired', 'net_book_value','JG_RX_FAREG.var.net_book_value','NUMBER');
       FA_RX_UTIL_PKG.assign_column('15', 'RE.gain_loss_amount', 'gain_loss','JG_RX_FAREG.var.gain_loss','NUMBER');
       FA_RX_UTIL_PKG.assign_column('16', 'RE.reference_num', 'invoice_number','JG_RX_FAREG.var.invoice_number','VARCHAR2', 50);
       FA_RX_UTIL_PKG.assign_column('17', 'RE.asset_id', NULL,'JG_RX_FAREG.var.asset_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('18', 'RE.date_retired', 'date_retired','JG_RX_FAREG.var.date_retired','DATE');
       FA_RX_UTIL_PKG.assign_column('19', 'RE.transaction_header_id_in', NULL,'JG_RX_FAREG.var.transaction_header_id','NUMBER');
       FA_RX_UTIL_PKG.assign_column('20', NULL,'asset_heading','JG_RX_FAREG.var.asset_heading','VARCHAR2', 15);

       --- Added for ECE Project
	FA_RX_UTIL_PKG.assign_column('21', 'BO.prorate_convention_code','prorate_convention','JG_RX_FAREG.var.prorate_convention', 'VARCHAR2',10);
	FA_RX_UTIL_PKG.assign_column('22', 'AD.tag_number', 'tag_number','JG_RX_FAREG.var.tag_number', 'VARCHAR2',15);
	FA_RX_UTIL_PKG.assign_column('23', 'AD.serial_number', 'serial_number','JG_RX_FAREG.var.serial_number', 'VARCHAR2',35);
	FA_RX_UTIL_PKG.assign_column('24', 'AD.asset_key_ccid', NULL,'JG_RX_FAREG.var.asset_key_ccid', 'NUMBER');
	FA_RX_UTIL_PKG.assign_column('25', NULL, 'asset_key_flexfield','JG_RX_FAREG.var.asset_key_flexfield', 'VARCHAR2',320); -- Bug 4969343
	FA_RX_UTIL_PKG.assign_column('26', 'BO.life_in_months', 'life_in_months','JG_RX_FAREG.var.life_in_months','NUMBER');
	FA_RX_UTIL_PKG.assign_column('27', 'METH.method_code', 'depreciation_method','JG_RX_FAREG.var.depriciation_method', 'VARCHAR2', 12);
	FA_RX_UTIL_PKG.assign_column('28', NULL, 'life_in_years','JG_RX_FAREG.var.life_in_years','NUMBER');
	---
       -->>SELECT_END<<--


       --
       -- Assign From Clause
       --
       FA_RX_UTIL_PKG.From_Clause :=
         'fa_retirements      re,
         fa_additions        ad,
         fa_categories       ca,
         fa_books            bo,
         fa_methods        METH';


       --
       -- Assign Where Clause
       --
 -- ECE Project Added a where condition to add table fa_methods        METH

       FA_RX_UTIL_PKG.Where_clause:=
             '     AD.asset_id = RE.ASSET_ID' ||
             ' AND RE.STATUS   = ''PROCESSED'''||
             ' AND AD.asset_category_id = CA.category_id' ||
             ' AND BO.deprn_method_code = METH.method_code' ||
             ' AND NVL(BO.life_in_months,-99) = NVL(METH.life_in_months,-99)'||
             ' AND AD.asset_id = BO.asset_id' ||
             ' AND BO.date_effective = (SELECT MAX(date_effective)' ||
             '                            FROM fa_books' ||
             '                           WHERE TO_CHAR(date_effective,''DD-MON-YYYY HH:MI:SS'') < ' ||
             '                                 TO_CHAR(:b_period_to_date,''DD-MON-YYYY HH:MI:SS'')' ||
             '                             AND book_type_code = BO.book_type_code' ||
             '                             AND asset_id       = BO.asset_id) '||
             ' AND RE.date_effective = (SELECT MAX(date_effective)' ||
             '                            FROM fa_retirements' ||
             '                           WHERE TO_CHAR(date_effective,''DD-MON-YYYY HH:MI:SS'') < ' ||
             '                                 TO_CHAR(:b_period_to_date,''DD-MON-YYYY HH:MI:SS'')' ||
             '                             AND book_type_code = BO.book_type_code' ||
             '                             AND asset_id       = BO.asset_id)';

       -- It takes the segment condition
       IF X_where_clause_tmp IS NOT NULL THEN
          FA_RX_UTIL_PKG.Where_Clause := FA_RX_UTIL_PKG.Where_clause || X_where_clause_tmp;
       END IF;

       IF PARM.p_book_type_code IS NOT NULL THEN
          FA_RX_UTIL_PKG.Where_clause := FA_RX_UTIL_PKG.Where_clause ||
                                     ' AND BO.book_type_code  = :b_book_type_code ';
       END IF;
       -- Both parameters are not null...anyway
       IF PARM.p_begin_period_from_date IS NOT NULL AND PARM.p_end_period_to_date IS NOT NULL THEN
         FA_RX_UTIL_PKG.Where_clause := FA_RX_UTIL_PKG.Where_clause || ' AND RE.date_retired ' ||
                                            'BETWEEN :b_period_from_date AND :b_period_to_date ';
       END IF;

       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_before_report()-');

   END fa_RTRMNT_before_report;



/*===================================================================+
|                        fa_RTRMNT_bind                              |
+====================================================================*/
      -- This is the bind trigger for the
      PROCEDURE fa_RTRMNT_bind (c IN INTEGER)
      IS
        b_major_category    VARCHAR2(20);
        b_minor_category    VARCHAR2(20);
        b_period_from_date  VARCHAR2(20);
        b_period_to_date    VARCHAR2(20);
        b_book_type_code    VARCHAR2(15);

      BEGIN
        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_bind()+');

        IF PARM.p_begin_period_from_date IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_period_from_date');
          DBMS_SQL.bind_variable(c, 'b_period_from_date', PARM.p_begin_period_from_date);
        END IF;

        IF PARM.p_end_period_to_date IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_period_to_date');
          DBMS_SQL.bind_variable(c, 'b_period_to_date', PARM.p_end_period_to_date);
        END IF;

        IF PARM.p_major_category IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding major_category');
          DBMS_SQL.bind_variable(c, 'b_major_category', PARM.p_major_category);
        END IF;

        IF PARM.p_minor_category IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_minor_category');
          DBMS_SQL.bind_variable(c, 'b_minor_category', PARM.p_minor_category);
        END IF;

        IF PARM.p_book_type_code IS NOT NULL THEN
          FA_RX_UTIL_PKG.debug('Binding b_book_type_code');
          DBMS_SQL.bind_variable(c, 'b_book_type_code', PARM.p_book_type_code);
        END IF;

        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_bind()-');

     END fa_RTRMNT_bind;


/*===================================================================+
|                      fa_RTRMNT_after_fetch                         |
+====================================================================*/
      -- The after fetch trigger fires after the Select statement has executed
      PROCEDURE fa_RTRMNT_after_fetch IS

      X_msg       VARCHAR2(100);
      BEGIN
         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_after_fetch()+');

           	-- Added for ECE Project
	-- This code is added to get the Asset Flexfield
        -- concatenated segment value
     BEGIN
		SELECT number_per_fiscal_year
	        INTO X_number_per_fiscal_year
        	FROM fa_calendar_types
	        WHERE calendar_type = X_deprn_calendar;

       	JG_RX_FAREG.var.life_in_years :=
                      JG_RX_FAREG.var.life_in_months / X_number_per_fiscal_year;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.fa_RTRMNT_after_fetch: NO_DATA_FOUND';
             x_msg := x_msg || ' -  Error in getting number_per_fiscal_year';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.fa_RTRMNT_after_fetch: TOO_MANY_ROWS';
             x_msg := x_msg || ' -  Error in getting number_per_fiscal_year';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);
     END;

     BEGIN
          IF JG_RX_FAREG.var.asset_key_ccid IS NOT NULL THEN
		SELECT trim(padded_concatenated_segments)
		INTO JG_RX_FAREG.var.asset_key_flexfield
		FROM FA_ASSET_KEYWORDS_KFV
		WHERE CODE_COMBINATION_ID=JG_RX_FAREG.var.asset_key_ccid;
          ELSE
		JG_RX_FAREG.var.asset_key_flexfield := NULL;
          END IF;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.fa_RTRMNT_after_fetch: NO_DATA_FOUND';
	     x_msg := x_msg || ' -  Error in getting Asset Flexfield Value ';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.fa_RTRMNT_after_fetch: TOO_MANY_ROWS';
	     x_msg := x_msg || ' -  Error in getting Asset Flexfield Value ';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

     END;

	--   End for ECE Project


         -- It takes the parent asset number

            JG_RX_FAREG.var.parent_asset_number := null;
         IF JG_RX_FAREG.var.parent_asset_id IS NOT NULL THEN
            JG_RX_FAREG.var.parent_asset_number := Get_parent_asset_number;
         END IF;

         JG_RX_FAREG.var.asset_heading := 'ASSET NUMBER ';

         -- It takes the reserve values
         Get_RTRMNT_reserve;

         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_after_fetch()-');

      END fa_RTRMNT_after_fetch;


/*===================================================================+
|                      fa_RTRMNT_after_report                        |
+====================================================================*/
      PROCEDURE fa_RTRMNT_after_report IS
      BEGIN
         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_after_report()+');


         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.fa_RTRMNT_after_report()-');
      END fa_RTRMNT_after_report;


/*===================================================================+
|                  Get_Account_Segment                               |
+====================================================================*/
FUNCTION Get_Account_Segment RETURN VARCHAR2 IS

   X_Account_Segment  Varchar2(50);
   X_ret BOOLEAN := TRUE;
   X_id_flex_num Number(15);
Begin
   FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_Account_segment()+');

   select sob.chart_of_accounts_id
   into X_id_flex_num
   from gl_sets_of_books sob,
        fa_book_controls bkc
   where bkc.book_type_code = PARM.p_Book_type_code and
         bkc.set_of_books_id = sob.set_of_books_id;

   X_ret := FND_FLEX_APIS.get_segment_column(
                                               101,                -- x_application_id
                                               'GL#',             -- x_id_flex_code in
                                               X_id_flex_Num,                -- x_id_flex_num in
                                               'GL_ACCOUNT',   -- x_seg_attr_type
                                               X_Account_segment);   -- x_app_column_name
  If X_ret = TRUE then
      FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Account_segment'||X_account_segment);
      return (X_Account_Segment);
  else
      FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Account_segment'||'NONE');
      return ('NONE');
  end if;
 FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_Account_segment()-');

end Get_Account_Segment;

/*===================================================================+
|                      Get_category_segment                          |
+====================================================================*/
  FUNCTION Get_category_segment RETURN VARCHAR2
  IS

    X_where_clause     VARCHAR2(2000);
    X_ret              BOOLEAN := TRUE;
    X_msg              VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_category_segment()+');

     -- Takes major segment
     X_ret := FND_FLEX_APIS.get_segment_column(
                                               140,                -- x_application_id
                                               'CAT#',             -- x_id_flex_code in
                                               101,                -- x_id_flex_num in
                                               'BASED_CATEGORY',   -- x_seg_attr_type
                                               X_major_segment);   -- x_app_column_name

     IF X_ret = FALSE THEN
        X_msg := 'JG_RX_FAREG.Get_category_segment: error retrieving MAJOR SEGMENT';
        FA_RX_UTIL_PKG.debug(X_msg);
        RAISE_APPLICATION_ERROR(-20010,X_msg);
     ELSIF PARM.p_major_category IS NOT NULL THEN
        -- Building major segment condition
         FA_RX_UTIL_PKG.debug('Major Category');
        X_where_clause := ' AND CA.' || X_major_segment || ' = :b_major_category ';
     END IF;

     -- Takes minor segment
     X_ret := FND_FLEX_APIS.get_segment_column(
                                               140,                -- x_application_id
                                               'CAT#',             -- x_id_flex_code in
                                               101,                -- x_id_flex_num in
                                               'MINOR_CATEGORY',   -- x_seg_attr_type
                                               X_minor_segment);   -- x_app_column_name

     IF X_ret = FALSE THEN
        X_msg := 'JG_RX_FAREG.Get_category_segment: error retrieving MINOR SEGMENT';
        FA_RX_UTIL_PKG.debug(X_msg);
        X_minor_segment_sel := 'NULL';
      --  RAISE_APPLICATION_ERROR(-20010,X_msg);
     ELSIF PARM.p_minor_category IS NOT NULL THEN
        -- Building minor segment condition
          X_minor_segment_sel := 'CA.'||X_minor_segment;
         X_where_clause := X_where_clause || ' AND CA.' || X_minor_segment ||
                           ' = :b_minor_category ';
     END IF;
     IF X_ret <> FALSE and  PARM.p_minor_category IS NULL THEN
            X_minor_segment_sel := 'CA.'||X_minor_segment;
     END IF;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_category_segment()-');

     RETURN X_where_clause;

  END Get_category_segment;



/*===================================================================+
|                      Get_period_date                               |
+====================================================================*/
  PROCEDURE Get_period_date (
        p_period_from          IN  VARCHAR2,
        p_period_to            IN  VARCHAR2)
  IS

  X_msg  VARCHAR2(100);
  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_period_date()+');

      PARM.p_period_from             := p_period_from;
      PARM.p_period_to               := p_period_to;

     -- Both period are required by anyway...
     IF PARM.p_period_from IS NOT NULL THEN
        FA_RX_UTIL_PKG.debug('Get period date from');

        SELECT calendar_period_open_date,
               calendar_period_close_date,
               period_counter,
               fiscal_year                      -- fiscal year for periods
          INTO PARM.p_begin_period_from_date,
               PARM.p_begin_period_to_date,
               PARM.p_begin_period_counter,
               X_fiscal_year
          FROM fa_deprn_periods
         WHERE book_type_code = PARM.p_book_type_code
           AND period_counter > (SELECT MIN(DP2.period_counter)
                                   FROM fa_deprn_periods DP2
                                  WHERE DP2.book_type_code = PARM.p_book_type_code)
           AND period_name = PARM.p_period_from;
     END IF;

     IF PARM.p_period_to IS NOT NULL THEN
        FA_RX_UTIL_PKG.debug('Get period date to');

        SELECT calendar_period_open_date,
               calendar_period_close_date,
               period_counter
          INTO PARM.p_end_period_from_date,
               PARM.p_end_period_to_date,
               PARM.p_end_period_counter
          FROM fa_deprn_periods
         WHERE book_type_code = PARM.p_book_type_code
           AND period_counter > (SELECT MIN(DP2.period_counter)
                                   FROM fa_deprn_periods DP2
                                  WHERE DP2.book_type_code = PARM.p_book_type_code)
           AND period_name = PARM.p_period_to;
     END IF;


     FA_RX_UTIL_PKG.debug('PARM.p_begin_period_from_date ' || to_char(PARM.p_begin_period_from_date));
     FA_RX_UTIL_PKG.debug('PARM.p_begin_period_to_date ' || to_char(PARM.p_begin_period_to_date));
     FA_RX_UTIL_PKG.debug('PARM.p_end_period_from_date ' || to_char(PARM.p_end_period_from_date));
     FA_RX_UTIL_PKG.debug('PARM.p_end_period_to_date ' || to_char(PARM.p_end_period_to_date));
     FA_RX_UTIL_PKG.debug('PARM.p_begin_period_counter ' || to_char(PARM.p_begin_period_counter));
     FA_RX_UTIL_PKG.debug('PARM.p_end_period_counter'|| to_char(PARM.p_end_period_counter));

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_period_date()-');

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.Get_period_date: NO_DATA_FOUND';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.Get_period_date: TOO_MANY_ROWS';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_period_date;

/*===================================================================+
|                      Get_RTRMNT_reserve                                   |
+====================================================================*/
  PROCEDURE Get_RTRMNT_reserve
  IS
  BEGIN
        SELECT SUM((DECODE(adjustment_type,'RESERVE',adjustment_amount,0)) -
               (DECODE(adjustment_type,'BONUS RESERVE',adjustment_amount,0)))
          INTO JG_RX_FAREG.var.deprn_reserve
          FROM fa_adjustments            AD
         WHERE AD.source_type_code      in ('RETIREMENT')
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.debit_credit_flag      = 'DR'
           AND transaction_header_id = JG_RX_FAREG.var.transaction_header_id;

        SELECT SUM(DECODE(adjustment_type,'BONUS RESERVE',adjustment_amount,0))
          INTO JG_RX_FAREG.var.bonus_reserve
          FROM fa_adjustments            AD
         WHERE AD.source_type_code      in ('RETIREMENT')
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.debit_credit_flag      = 'DR'
           AND transaction_header_id = JG_RX_FAREG.var.transaction_header_id;

END Get_RTRMNT_reserve   ;


/*===================================================================+
|                  Get_starting_depreciation_year                    |
+====================================================================*/
  FUNCTION Get_starting_depreciation_year RETURN NUMBER
  IS

    X_ret    NUMBER(4);
    X_msg       VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_starting_depreciation_year()+');

     SELECT FY.fiscal_year
       INTO X_ret
       FROM fa_fiscal_year      FY,
            fa_convention_types CT,
            fa_books            BO
      WHERE CT.prorate_convention_code = BO.prorate_convention_code
        AND FY.fiscal_year_name        = CT.fiscal_year_name
        AND BO.date_ineffective IS NULL
        AND BO.date_placed_in_service BETWEEN FY.start_date
                                          AND FY.end_date
        AND BO.asset_id                = JG_RX_FAREG.var.asset_id
        AND BO.book_type_code          = PARM.p_book_type_code;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_starting_depreciation_year()-');

     RETURN X_ret;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 X_msg := 'JG_RX_FAREG.Get_starting_depreciation_year: NO_DATA_FOUND';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 RAISE_APPLICATION_ERROR(-20010,X_msg);

            WHEN TOO_MANY_ROWS THEN
                 X_msg := 'JG_RX_FAREG.Get_starting_depreciation_year: TOO_MANY_ROWS';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_starting_depreciation_year;

/*===================================================================+
|                  Get_depreciation_rate                             |
+====================================================================*/
  PROCEDURE Get_depreciation_rate
  IS

    X_msg                      VARCHAR2(100);
    X_life_in_years            NUMBER;
    X_number_per_fiscal_year   NUMBER;
    X_life_of_asset            NUMBER;
    X_year_of_life             NUMBER;
    X_current_fiscal_year      NUMBER;
    X_prorate_fiscal_year      NUMBER;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_depreciation_rate()+');

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.rate_source_rule = ' || JG_RX_FAREG.var.rate_source_rule);

     -- FLAT
     IF JG_RX_FAREG.var.rate_source_rule = 'FLAT' THEN
        JG_RX_FAREG.var.deprn_rate := JG_RX_FAREG.var.adjusted_rate;
     END IF;


     -- CALCULATED
     IF JG_RX_FAREG.var.rate_source_rule IN ('CALCULATED','TABLE','FORMULA') THEN
        SELECT number_per_fiscal_year
          INTO X_number_per_fiscal_year
          FROM fa_calendar_types
         WHERE calendar_type = X_deprn_calendar;  -- X_deprn_calendar is retrieved in Get_fiscal_year_date()
         IF JG_RX_FAREG.var.rate_source_rule = 'CALCULATED' THEN
                 X_life_in_years := JG_RX_FAREG.var.life_in_months / 12;                      -- Bug 4066022
                  FA_RX_UTIL_PKG.debug('Life in years ='||to_char(X_life_in_years));
                  JG_RX_FAREG.var.deprn_rate := round(1 / (X_life_in_years * X_number_per_fiscal_year),4);-- Bug 4066022 ,5081410
                  FA_RX_UTIL_PKG.debug('Method Type Calculate..'||JG_RX_FAREG.var.rate_source_rule);
                  FA_RX_UTIL_PKG.debug('deprn rate'||to_char(JG_RX_FAREG.var.deprn_rate));
         END IF;
--Added this part for Formula Column  for bug 2906455
    IF JG_RX_FAREG.var.rate_source_rule = 'FORMULA' THEN
                 X_life_in_years := JG_RX_FAREG.var.life_in_months / X_number_per_fiscal_year;
                  FA_RX_UTIL_PKG.debug('Life in years ='||to_char(X_life_in_years));
                 JG_RX_FAREG.var.deprn_rate := 1 / X_life_in_years;
                  FA_RX_UTIL_PKG.debug('Method Type Formula is....'||JG_RX_FAREG.var.rate_source_rule);
                  FA_RX_UTIL_PKG.debug('deprn rate'||to_char(JG_RX_FAREG.var.deprn_rate));
         END IF;
--Changes finished for bug 2906455
     END IF;


--Added this following code to calculate the depriciation rate for FORMULA methods

   /* IF JG_RX_FAREG.var.rate_source_rule ='FORMULA' then

    select method_id
    into X_METHOD_ID1
    from   fa_methods
    where method_code = JG_RX_FAREG.var.deprn_method_code
    and    nvl (life_in_months, -999) = nvl (JG_RX_FAREG.var.Life_In_Months, -999);

      FA_RX_UTIL_PKG.debug('Asset Id '||to_char(JG_RX_FAREG.var.asset_id));
      FA_RX_UTIL_PKG.debug('life in months'||to_char(JG_RX_FAREG.var.life_in_months));
      FA_RX_UTIL_PKG.debug('Fiscal  Year '||to_char(JG_RX_FAREG.var.x_fiscal_year1));
     FA_RX_UTIL_PKG.debug('Short Fiscal Year'||JG_RX_FAREG.var.short_fiscal_year_flag);
     FA_RX_UTIL_PKG.debug('Method Code'||JG_RX_FAREG.var.deprn_method_code);
     FA_RX_UTIL_PKG.debug('Current Period '||to_char(JG_RX_FAREG.var.begin_period_counter1));
      FA_RX_UTIL_PKG.debug('Prorate DAte is..'||to_char(JG_RX_FAREG.var.prorate_Date, 'DD/MM/YYYY'));
       FA_RX_UTIL_PKG.debug('Conversion  DAte is..'||to_char(JG_RX_FAREG.var.conversion_date, 'DD/MM/YYYY'));
       FA_RX_UTIL_PKG.debug('Orginal Deprn DAte is..'||to_char(JG_RX_FAREG.var.original_deprn_start_date, 'DD/MM/YYYY'));
    FA_RX_UTIL_PKG.debug('deprn rate for Formula before is ..'||to_char(JG_RX_FAREG.var.deprn_rate));

            FA_CDE_PKG.faxgfr(X_Book_Type_Code   =>  PARM.p_book_type_code,
                        X_Asset_Id               => JG_RX_FAREG.var.asset_id,
                        X_Short_Fiscal_Year_Flag => JG_RX_FAREG.var.short_fiscal_year_flag,
                        X_Conversion_Date        => JG_RX_FAREG.var.conversion_date,
                        X_Prorate_Date           => JG_RX_FAREG.var.prorate_date,
                        X_Orig_Deprn_Start_Date  => JG_RX_FAREG.var.original_deprn_start_date,
                        C_Prorate_Date           => NULL,
                        C_Conversion_Date        => NULL,
                        C_Orig_Deprn_Start_Date  => NULL,
                        X_Method_Code            => JG_RX_FAREG.var.deprn_method_code,
                        X_Life_In_Months         => JG_RX_FAREG.var.life_in_months,
                        X_Fiscal_Year            => JG_RX_FAREG.var.x_fiscal_year1,
                        X_Current_Period         => JG_RX_FAREG.var.begin_period_counter1,
                        X_Rate                   => X_rate1,
                        X_Method_Type            => method_type,
                        X_Success                => success
                        );

                  FA_CDE_PKG.faxgfr(X_Book_Type_Code   =>  PARM.p_book_type_code,
                        X_Asset_Id               => JG_RX_FAREG.var.asset_id,
                        X_Life_In_Months         => JG_RX_FAREG.var.life_in_months,
                        X_Short_Fiscal_Year_Flag => JG_RX_FAREG.var.short_fiscal_year_flag,
                        X_Conversion_Date        => JG_RX_FAREG.var.conversion_date,
                        X_Prorate_Date           => JG_RX_FAREG.var.prorate_date,
                        X_Orig_Deprn_Start_Date  => JG_RX_FAREG.var.original_deprn_start_date,
                        C_Prorate_Date           => NULL,
                        C_Conversion_Date        => NULL,
                        C_Orig_Deprn_Start_Date  => NULL,
                        X_Method_Id              => X_METHOD_ID1,
                        X_Fiscal_Year            => JG_RX_FAREG.var.x_fiscal_year1,
                       -- X_Current_Period         => JG_RX_FAREG.var.begin_period_counter1,
                        X_Rate                   => X_rate1,
                        X_Method_Type            => method_type,
                        X_Success                => success
                        );

                           JG_RX_FAREG.var.deprn_rate := X_rate1;
                FA_RX_UTIL_PKG.debug('deprn rate for Formula is ..'||to_char(JG_RX_FAREG.var.deprn_rate));
                FA_RX_UTIL_PKG.debug('Success Code for  Formula is ..'||to_char(success));

   END IF;*/
-- Amar added above part to fix bug 2906455.
     -- TABLE
     IF JG_RX_FAREG.var.rate_source_rule = 'TABLE' THEN
--        SELECT (ROUND(MONTHS_BETWEEN(PARM.p_end_period_to_date,JG_RX_FAREG.var.date_placed_in_service)/
--	  SELECT (ROUND(JG_RX_FAREG.var.life_in_months/  -- bug 4665510
--               X_number_per_fiscal_year))   -- +1    -- bug 5364830

	  SELECT ROUND(JG_RX_FAREG.var.life_in_months/12)
          INTO X_life_of_asset
          FROM dual;

          FA_RX_UTIL_PKG.debug('Life of the asset= ' || to_char(x_life_of_asset));
          FA_RX_UTIL_PKG.debug('deprn calendar = ' || x_deprn_calendar);
          FA_RX_UTIL_PKG.debug('start date = ' || JG_RX_FAREG.var.prorate_date);
          FA_RX_UTIL_PKG.debug(' date placed in service = ' || JG_RX_FAREG.var.date_placed_in_service);
          FA_RX_UTIL_PKG.debug('number per fiscal year= ' || to_char(x_number_per_fiscal_year));
          FA_RX_UTIL_PKG.debug('METHOD ID= ' || to_char(JG_RX_FAREG.var.method_id));

        -- Fix for Bug #5384045.  To find the correct rate, we need to use
        -- the current year of the asset's life rather than the entire life
        -- of the asset (X_life_of_asset) when joining to fa_rates.
        SELECT fiscal_year
          INTO X_current_fiscal_year
          FROM fa_deprn_periods
         WHERE book_type_code = PARM.p_book_type_code
           AND period_name = PARM.p_period_from;

         SELECT fy.fiscal_year
           INTO X_prorate_fiscal_year
           FROM fa_calendar_periods cp,
                fa_fiscal_year fy,
                fa_book_controls bc
          WHERE fy.fiscal_year_name = bc.fiscal_year_name
            AND cp.calendar_type    = bc.prorate_calendar
            AND bc.book_type_code = PARM.p_book_type_code
            AND JG_RX_FAREG.var.prorate_date between
                fy.start_date and fy.end_date
            AND cp.start_date       between fy.start_date and fy.end_date
            AND cp.end_date         between fy.start_date and fy.end_date
            AND JG_RX_FAREG.var.prorate_date between
                cp.start_date and cp.end_date;

        X_year_of_life := X_current_fiscal_year - X_prorate_fiscal_year + 1;

        SELECT rate
          INTO JG_RX_FAREG.var.deprn_rate
          FROM fa_rates
         WHERE method_id = JG_RX_FAREG.var.method_id
           AND year      = X_year_of_life
           AND period_placed_in_service = (SELECT period_num
                                             FROM fa_calendar_periods
                                            WHERE calendar_type  = X_deprn_calendar  -- X_deprn_calendar is retrieved in Get_fiscal_year_date()
                                              AND JG_RX_FAREG.var.prorate_date BETWEEN start_date  -- X_prorate_date   is retrieved in Get_fiscal_year_date()
                                                                                  AND end_date);

     END IF;
     IF JG_RX_FAREG.var.rate_source_rule IN ('CALCULATED','FLAT','TABLE', 'FORMULA') THEN

        JG_RX_FAREG.var.deprn_rate := JG_RX_FAREG.var.deprn_rate *100;
    END IF;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_rate =' || TO_CHAR(JG_RX_FAREG.var.deprn_rate));

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_depreciation_rate()-');

     EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 X_msg := 'JG_RX_FAREG.Get_depreciation_rate: NO_DATA_FOUND';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 RAISE_APPLICATION_ERROR(-20010,X_msg);

            WHEN TOO_MANY_ROWS THEN
                 X_msg := 'JG_RX_FAREG.Get_depreciation_rate: TOO_MANY_ROWS';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_depreciation_rate;


/*===================================================================+
|                          Get_Deprn_Accounts                        |
+====================================================================*/

  PROCEDURE Get_Deprn_Accounts
  IS
    X_msg                    VARCHAR2(100);
    V_CURSORiD iNTEGER;
    v_Selectstmnt varchar2(20000);
    v_Selectstmnt1 varchar2(10000);
    v_selectstmnt2 varchar2(10000);
    v_selectstmnt3 varchar2(10000);
    V_expense_account varchar2(100);
    v_dummy integer ;
 BEGIN
    FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_Deprn_Account()+');
    JG_RX_FAREG.var.expense_account := NULL;
    v_cursorId  := DBMS_SQL.OPEN_CURSOR;
    v_Selectstmnt1 :=
         'select distinct  '||X_account_segment||' from '||
                 ' fa_distribution_history dih,'||
                 ' gl_code_combinations gcc'||
                 ' where dih.asset_id ='||JG_RX_FAREG.var.asset_id || 'and '||
                 ' dih.book_type_code = '||''''||PARM.p_book_type_code ||''''||' and'||
                  ' gcc.code_combination_id = dih.code_combination_id'||
                  ' and dih.transaction_header_id_in =';
   v_selectstmnt2 := '(select to_char(MAX(transaction_heaDer_id))'||
                               ' from fa_transaction_headers trh,'||
                               ' fa_distribution_history dih1'||
                               ' where dih1.asset_id= dih.asset_id and'||
                               ' dih1.book_type_code =dih.book_type_code and'||
                               ' dih1.transaction_header_id_in = trh.transaction_header_id and';
   v_selectstmnt3 := ' transaction_date_entered <= '||''''||PARM.p_end_period_to_date||''''||')';

    DBMS_SQL.PARSE(V_cursorId,v_selectstmnt1||v_selectstmnt2||v_selectstmnt3,DBMS_SQL.V7);
    DBMS_SQL.DEFINE_COLUMN(V_cursorId,1,V_expense_account,100);
    V_DUMMY := DBMS_SQL.EXECUTE(V_cursorId);
   LOOP
      IF DBMS_SQL.FETCH_ROWS(V_cursorId) = 0 THEN
        EXIT;
      END IF;
      DBMS_SQL.COLUMN_VALUE(V_cursorId,1,V_expense_account);
      JG_RX_FAREG.var.expense_account:= JG_RX_FAREG.var.expense_account||V_expense_account;
  END LOOP;
  dbms_sql.close_cursor(v_cursorId);
       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.expense_account = ' || JG_RX_FAREG.var.expense_account);
       FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_depr_account()-');
 END Get_deprn_accounts;




/*===================================================================+
|                          Get_Invoice Number and  Supplier Name        |
+====================================================================*/

  PROCEDURE Get_invoice_number
	IS
	X_msg                    VARCHAR2(100);

   BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_inv_number()+');
        select distinct invoice_number,
               vendor_name
	    into JG_RX_FAREG.var.invoice_number,
             JG_RX_FAREG.var.supplier_name
        from fa_asset_invoices ai,po_vendors ve,fa_invoice_transactions  IT,
        fa_book_controls fabc
        where ai.po_vendor_id= ve.vendor_id and
              ai.asset_id = JG_RX_FAREG.var.asset_id and
              ai.invoice_transaction_id_in = IT.invoice_transaction_id and
               -- IT.book_type_code = PARM.p_book_type_code;
              IT.book_type_code = fabc.DISTRIBUTION_SOURCE_BOOK and
              fabc.book_type_code = PARM.p_book_type_code;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.invoice_number = ' || JG_RX_FAREG.var.invoice_number);
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.supplier_name  = ' || JG_RX_FAREG.var.supplier_name);
	 FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_inv_number() - ');
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              X_msg := 'JG_RX_FAREG.Get_inv_number: NO_DATA_FOUND';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 JG_RX_FAREG.var.invoice_number := null;
                 JG_RX_FAREG.var.supplier_name := null;
  END Get_invoice_number;




/*===================================================================+
|                      Get_parent_asset_number                       |
+====================================================================*/
  FUNCTION Get_parent_asset_number RETURN VARCHAR2
  IS

    X_msg                    VARCHAR2(100);
    X_parent_asset_number    VARCHAR2(15);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_parent_asset_number()+');

     SELECT asset_number
       INTO X_parent_asset_number
       FROM fa_additions
      WHERE asset_id = JG_RX_FAREG.var.parent_asset_id;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_parent_asset_number()-');

     RETURN X_parent_asset_number;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 X_msg := 'JG_RX_FAREG.Get_parent_asset_number: NO_DATA_FOUND';
                 FA_RX_UTIL_PKG.debug(X_msg);
                 RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_parent_asset_number;


/*===================================================================+
|                          Startup                                   |
+====================================================================*/
  PROCEDURE Startup
  IS

    X_msg                    VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Startup()+');

     -- It takes the segment condition
     X_where_clause_tmp := Get_category_segment;

     FA_RX_UTIL_PKG.debug('Get Company name');
     -- Get Company name and store in placeholder variable
     SELECT company_name
       INTO JG_RX_FAREG.var.organization_name
       FROM fa_system_controls;


     FA_RX_UTIL_PKG.debug('Get currency code');
     -- Get currency code and store in placeholder variable
     SELECT currency_code
       INTO JG_RX_FAREG.var.functional_currency_code
       FROM gl_sets_of_books
      WHERE set_of_books_id = FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Startup()-');

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              X_msg := 'JG_RX_FAREG.Startup: NO_DATA_FOUND';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);

         WHEN TOO_MANY_ROWS THEN
              X_msg := 'JG_RX_FAREG.Startup: TOO_MANY_ROWS';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Startup;


/*===================================================================+
|                          Get_cost_value                            |
+====================================================================*/
  PROCEDURE Get_cost_value
  IS

    X_msg                    VARCHAR2(100);
    X_capitalized            NUMBER(10);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_value()+');

     BEGIN
        FA_RX_UTIL_PKG.debug('Get cost initial value');
        -- Get initial value
        SELECT count(*)
          INTO X_capitalized
          FROM fa_books                  BO
         WHERE BO.book_type_code         = PARM.p_book_type_code
           AND BO.asset_id               = JG_RX_FAREG.var.asset_id
           AND BO.period_counter_capitalized BETWEEN PARM.p_begin_period_counter AND
                                                     PARM.p_end_period_counter;
        IF X_capitalized > 0 THEN

            JG_RX_FAREG.var.asset_cost_initial := 0;
        ELSE
           SELECT cost,
                  transaction_header_id_in
           INTO JG_RX_FAREG.var.asset_cost_initial,
                X_transaction_id_initial
           FROM fa_books                  BO
           WHERE BO.book_type_code         = PARM.p_book_type_code
           AND BO.asset_id               = JG_RX_FAREG.var.asset_id
           AND (TO_CHAR(BO.date_effective, 'DD-MON-YYYY HH:MI:SS'),transaction_header_id_in) =
                    (SELECT TO_CHAR(MAX(BO1.date_effective), 'DD-MON-YYYY HH:MI:SS'),
                            max(transaction_header_id_in)
                     FROM fa_books                  BO1, fa_transaction_headers TRH
                     WHERE BO1.book_type_code = BO.book_type_code
                     AND BO1.asset_id       = BO.asset_id
                     AND TRH.transaction_header_id= BO1.transaction_header_id_in
                     AND TRH.transaction_date_entered < PARM.p_begin_period_from_date);
         END IF;
               FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_cost_initial =' || TO_CHAR(JG_RX_FAREG.var.asset_cost_initial));

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.asset_cost_initial := 0;
     END;

     FA_RX_UTIL_PKG.debug('Get cost final value');
     -- Get final value
     BEGIN
         SELECT cost,
                transaction_header_id_in
         INTO JG_RX_FAREG.var.asset_cost_final,
               X_transaction_id_final
         FROM fa_books                  BO
         WHERE BO.book_type_code         = PARM.p_book_type_code
                AND BO.asset_id               = JG_RX_FAREG.var.asset_id
                AND (TO_CHAR(BO.date_effective, 'DD-MON-YYYY HH:MI:SS'),transaction_header_id_in) =
                         (SELECT TO_CHAR(MAX(BO1.date_effective), 'DD-MON-YYYY HH:MI:SS'),
                           max(transaction_header_id_in)
                          FROM fa_books                  BO1,FA_TRANSACTION_HEADERS TRH
                          WHERE BO1.book_type_code = BO.book_type_code
                          AND BO1.asset_id       = BO.asset_id
                          AND TRH.transaction_header_id= BO1.transaction_header_id_in
                          AND TRH.transaction_date_entered <= PARM.p_end_period_to_date);
         FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_cost_final =' || TO_CHAR(JG_RX_FAREG.var.asset_cost_final));
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.asset_cost_final := 0;
                FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_cost_final =' ||'no data found');

         END;

     -- It takes the asset cost increase
     Get_cost_increase;

     -- It takes the asset cost increase
     Get_cost_decrease;
     -- 09/08/00 AFERRARA
     JG_RX_FAREG.var.asset_variation := JG_RX_FAREG.var.asset_cost_increase -
                                   JG_RX_FAREG.var.asset_cost_decrease;
FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.revaluation_total(before) =' || JG_RX_FAREG.var.revaluation_total);
     JG_RX_FAREG.var.revaluation_total := JG_RX_FAREG.var.revaluation_final;
          -- JG_RX_FAREG.var.asset_cost_final -
          --                           JG_RX_FAREG.var.asset_cost_orig;
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_variation =' || JG_RX_FAREG.var.asset_variation);
      --  09/08/00 AFERRARA

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_value()-');

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              X_msg := 'JG_RX_FAREG.Get_cost_value: NO_DATA_FOUND';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);

         WHEN TOO_MANY_ROWS THEN
              X_msg := 'JG_RX_FAREG.Get_cost_value: TOO_MANY_ROWS';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_cost_value;


/*===================================================================+
|                          Get_cost_increase                         |
+====================================================================*/
  PROCEDURE Get_cost_increase
  IS

    X_partial_addition       NUMBER := 0;
    X_manual_adjustment_plus NUMBER := 0;
    X_revaluation_plus       NUMBER := 0;
    X_reinstatements         NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_increase()+');

     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get partial addition ');
     fa_rx_util_pkg.debug('transaction id'||X_transaction_id_initial);
     fa_rx_util_pkg.debug('PARM.p_begin_period_to_date'||to_char(PARM.p_begin_period_to_date));
     fa_rx_util_pkg.debug('PARM.p_end_period_from_date'||to_char(PARM.p_end_period_from_date));

        SELECT SUM(AD.adjustment_amount)
          INTO X_partial_addition
          FROM fa_books                  BO,
               fa_transaction_headers    TH,
               fa_adjustments            AD
         WHERE BO.book_type_code            = PARM.p_book_type_code
           AND BO.asset_id                  = JG_RX_FAREG.var.asset_id
           AND BO.transaction_header_id_in  <> NVL(X_transaction_id_initial, 0)
           AND BO.book_type_code            = TH.book_type_code
           AND BO.asset_id                  = TH.asset_id
           AND BO.transaction_header_id_in  = TH.transaction_header_id
           AND TH.transaction_type_code     = 'ADDITION'
           AND AD.transaction_header_id     = TH.transaction_header_id
           AND AD.source_type_code          = TH.TRANSACTION_TYPE_CODE
           AND AD.book_type_code            = TH.book_type_code
           AND AD.asset_id                  = TH.asset_id
           AND AD.adjustment_type           = 'COST'
           AND AD.debit_credit_flag         = 'DR'
           AND AD.adjustment_amount         > 0
           AND TH.transaction_date_entered BETWEEN (PARM.p_begin_period_from_date)
                                     AND (PARM.p_end_period_to_date);
         -- changed bo.date_effective to TH.transaction_date_entered

     FA_RX_UTIL_PKG.debug('partial addition =' || TO_CHAR(X_partial_addition));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get manual adjustment upwards');

        SELECT SUM(AD.adjustment_amount)
          INTO X_manual_adjustment_plus
          FROM fa_transaction_headers TH,
               fa_adjustments         AD
         WHERE AD.transaction_header_id = TH.transaction_header_id
           AND AD.book_type_code        = TH.book_type_code
           AND AD.asset_id              = TH.asset_id
           AND TH.transaction_type_code = 'ADJUSTMENT'
           AND TH.book_type_code        = PARM.p_book_type_code
           AND TH.asset_id              = JG_RX_FAREG.var.asset_id
           AND AD.adjustment_type       = 'COST'
           AND AD.debit_credit_flag     = 'DR'
           AND TH.transaction_date_entered BETWEEN PARM.p_begin_period_from_date
                                               AND PARM.p_end_period_to_date;

     FA_RX_UTIL_PKG.debug('Get manual adjustment upwards =' || TO_CHAR(X_manual_adjustment_plus));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get revaluations upward ');

        SELECT SUM(AD.adjustment_amount)
          INTO X_revaluation_plus
          FROM fa_transaction_headers TH,
               fa_adjustments         AD
         WHERE AD.transaction_header_id = TH.transaction_header_id
           AND AD.book_type_code        = TH.book_type_code
           AND AD.asset_id              = TH.asset_id
           AND TH.transaction_type_code = 'REVALUATION'
           AND TH.book_type_code        = PARM.p_book_type_code
           AND TH.asset_id              = JG_RX_FAREG.var.asset_id
           AND AD.adjustment_type       = 'COST'
           AND AD.debit_credit_flag     = 'DR'
           AND AD.adjustment_amount     > 0
           AND TH.transaction_date_entered BETWEEN PARM.p_begin_period_from_date
                                               AND PARM.p_end_period_to_date;

     FA_RX_UTIL_PKG.debug('Revaluations Upward =' || TO_CHAR(X_revaluation_plus));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get reinstatements ');

        SELECT SUM(RE.cost_retired)
          INTO X_reinstatements
          FROM fa_transaction_headers TH,
               fa_retirements         RE
         WHERE RE.transaction_header_id_out = TH.transaction_header_id
           AND RE.book_type_code            = TH.book_type_code
           AND RE.asset_id                  = TH.asset_id
           AND TH.transaction_type_code     = 'REINSTATEMENT'
           AND TH.book_type_code            = PARM.p_book_type_code
           AND TH.asset_id                  = JG_RX_FAREG.var.asset_id
           AND TH.transaction_date_entered  BETWEEN PARM.p_begin_period_from_date
                                     AND PARM.p_end_period_to_date;
-- jmary changing date_retired to transaction_date
     FA_RX_UTIL_PKG.debug('Reinstatements =' || TO_CHAR(X_reinstatements));



     JG_RX_FAREG.var.asset_cost_increase := NVL(X_partial_addition,0)  +
                                           NVL(X_manual_adjustment_plus,0) +
                                           NVL(X_revaluation_plus,0)  +
                                           NVL(X_reinstatements,0);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_cost_increase =' || JG_RX_FAREG.var.asset_cost_increase);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_increase()-');


  END Get_cost_increase;



/*===================================================================+
|                          Get_cost_decrease                              |
+====================================================================*/
  PROCEDURE Get_cost_decrease
  IS

    X_credit_memos                  NUMBER := 0;
    X_manual_adjustment_minus       NUMBER := 0;
    X_revaluation_minus             NUMBER := 0;
    X_retirements                   NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_decrease()+');


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get credit memos ');

        SELECT SUM(AD.adjustment_amount)
          INTO X_credit_memos
          FROM fa_books                  BO,
               fa_transaction_headers    TH,
               fa_adjustments            AD
         WHERE BO.book_type_code            = PARM.p_book_type_code
           AND BO.asset_id                  = JG_RX_FAREG.var.asset_id
           AND BO.transaction_header_id_in  <> NVL(X_transaction_id_initial, 0)
           AND BO.book_type_code            = TH.book_type_code
           AND BO.asset_id                  = TH.asset_id
           AND BO.transaction_header_id_in  = TH.transaction_header_id
           AND TH.TRANSACTION_TYPE_CODE     = 'ADDITION'
           AND AD.transaction_header_id     = TH.transaction_header_id
           AND AD.source_type_code          = TH.TRANSACTION_TYPE_CODE
           AND AD.book_type_code            = TH.book_type_code
           AND AD.asset_id                  = TH.asset_id
           AND AD.adjustment_type           = 'COST'
           AND AD.debit_credit_flag         = 'CR'
           AND AD.adjustment_amount         < 0
           AND TH.transaction_date_entered  BETWEEN PARM.p_begin_period_from_date
                                     AND PARM.p_end_period_to_date;
           -- changed date_effective to transaction_date_entered

     FA_RX_UTIL_PKG.debug('credit memos =' || TO_CHAR(X_credit_memos));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get manual adjustment downwards');

        SELECT SUM(AD.adjustment_amount)
          INTO X_manual_adjustment_minus
          FROM fa_transaction_headers TH,
               fa_adjustments         AD
         WHERE AD.transaction_header_id = TH.transaction_header_id
           AND AD.book_type_code        = TH.book_type_code
           AND AD.asset_id              = TH.asset_id
           AND TH.transaction_type_code = 'ADJUSTMENT'
           AND TH.book_type_code        = PARM.p_book_type_code
           AND TH.asset_id              = JG_RX_FAREG.var.asset_id
           AND AD.adjustment_type       = 'COST'
           AND AD.debit_credit_flag     = 'CR'
           AND TH.transaction_date_entered BETWEEN PARM.p_begin_period_from_date
                                               AND PARM.p_end_period_to_date;

     FA_RX_UTIL_PKG.debug('Get manual adjustment downwards =' || TO_CHAR(X_manual_adjustment_minus));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get revaluations downward ');

        SELECT SUM(AD.adjustment_amount)
          INTO X_revaluation_minus
          FROM fa_transaction_headers TH,
               fa_adjustments         AD
         WHERE AD.transaction_header_id = TH.transaction_header_id
           AND AD.book_type_code        = TH.book_type_code
           AND AD.asset_id              = TH.asset_id
           AND TH.transaction_type_code = 'REVALUATION'
           AND TH.book_type_code        = PARM.p_book_type_code
           AND TH.asset_id              = JG_RX_FAREG.var.asset_id
           AND AD.adjustment_type       = 'COST'
           AND AD.debit_credit_flag     = 'CR'
           AND TH.transaction_date_entered BETWEEN PARM.p_begin_period_from_date
                                               AND PARM.p_end_period_to_date;

     FA_RX_UTIL_PKG.debug('Revaluations downward =' || TO_CHAR(X_revaluation_minus));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get retirements ');

        SELECT SUM(RE.cost_retired)
          INTO X_retirements
          FROM fa_transaction_headers TH,
               fa_retirements         RE
         WHERE RE.transaction_header_id_in = TH.transaction_header_id
           AND RE.book_type_code           = TH.book_type_code
           AND RE.asset_id                 = TH.asset_id
           AND (TH.TRANSACTION_TYPE_CODE   = 'PARTIAL RETIREMENT' OR
                TH.TRANSACTION_TYPE_CODE   = 'FULL RETIREMENT' )
           AND TH.book_type_code           = PARM.p_book_type_code
           AND TH.asset_id                 = JG_RX_FAREG.var.asset_id
           AND RE.date_retired BETWEEN PARM.p_begin_period_from_date  /* changed Transaction Date to Retirement Date */
                                     AND PARM.p_end_period_to_date;

     FA_RX_UTIL_PKG.debug('Retirements =' || TO_CHAR(X_retirements));



     JG_RX_FAREG.var.asset_cost_decrease := NVL(X_credit_memos,0)  +
                                           NVL(X_manual_adjustment_minus,0) +
                                           NVL(X_revaluation_minus,0)  +
                                           NVL(X_retirements,0);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.asset_cost_decrease =' || JG_RX_FAREG.var.asset_cost_decrease);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_cost_decrease()-');


  END Get_cost_decrease;


/*===================================================================+
|                          Get_revaluation                           |
+====================================================================*/
  PROCEDURE Get_revaluation
  IS

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation()+');

     BEGIN
        FA_RX_UTIL_PKG.debug('Get_revaluation initial value');
        -- Get initial value
        SELECT SUM(DECODE(debit_credit_flag, 'DR', adjustment_amount, 0)) -
               SUM(DECODE(debit_credit_flag, 'CR', adjustment_amount, 0))
          INTO JG_RX_FAREG.var.revaluation_initial
          FROM fa_adjustments
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND source_type_code       = 'REVALUATION'
           AND adjustment_type        = 'COST'
           AND period_counter_adjusted <= (PARM.p_begin_period_counter -1);

        IF JG_RX_FAREG.var.revaluation_initial IS NULL THEN
           JG_RX_FAREG.var.revaluation_initial := 0;
        END IF;

        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.revaluation_initial =' || TO_CHAR(JG_RX_FAREG.var.revaluation_initial));
     END;


     BEGIN
        FA_RX_UTIL_PKG.debug('Get_revaluation final value');
        -- Get final value
        SELECT SUM(DECODE(debit_credit_flag, 'DR', adjustment_amount, 0)) -
               SUM(DECODE(debit_credit_flag, 'CR', adjustment_amount, 0))
          INTO JG_RX_FAREG.var.revaluation_final
          FROM fa_adjustments
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND source_type_code       = 'REVALUATION'
           AND adjustment_type        = 'COST'
           AND period_counter_adjusted <= PARM.p_end_period_counter;

        IF JG_RX_FAREG.var.revaluation_final IS NULL THEN
           JG_RX_FAREG.var.revaluation_final := 0;
        END IF;


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.revaluation_final =' || TO_CHAR(JG_RX_FAREG.var.revaluation_final));
     END;

     -- It takes the asset revaluation increase
     Get_revaluation_change;

     -- 09/08/00 AFERRARA
     JG_RX_FAREG.var.reval_variation := JG_RX_FAREG.var.revaluation_increase -
                                   JG_RX_FAREG.var.revaluation_decrease;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.reval_variation =' || JG_RX_FAREG.var.reval_variation);
      --  09/08/00 AFERRARA

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation()-');

  END Get_revaluation;

/*===================================================================+
|                          Get_revaluation_change              |
+====================================================================*/
  PROCEDURE Get_revaluation_change
  IS

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation_change()+');

     SELECT SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',AD.adjustment_amount,0)),
            SUM(DECODE(DEBIT_CREDIT_FLAG,'CR',AD.adjustment_amount,0))
       INTO JG_RX_FAREG.var.revaluation_increase,JG_RX_FAREG.var.revaluation_decrease
       FROM fa_adjustments            AD
      WHERE AD.book_type_code            = PARM.p_book_type_code
        AND AD.asset_id                  = JG_RX_FAREG.var.asset_id
        AND AD.source_type_code          = 'REVALUATION'
        AND AD.adjustment_type           = 'COST'
        AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter ;
     IF JG_RX_FAREG.var.revaluation_increase IS NULL THEN
        JG_RX_FAREG.var.revaluation_increase := 0;
     END IF;
     IF JG_RX_FAREG.var.revaluation_decrease IS NULL THEN
        JG_RX_FAREG.var.revaluation_decrease := 0;
     END IF;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.revaluation_increase =' || JG_RX_FAREG.var.revaluation_increase);
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.revaluation_decrease =' || JG_RX_FAREG.var.revaluation_decrease);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation_change()-');


  END Get_revaluation_change;

/*===================================================================+
|                       Get_depr_reserve_value                       |
+====================================================================*/
  PROCEDURE Get_deprn_reserve_value
  IS

   X_msg                    VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_value()+');

     -------------------------------------------------------------------------------
     BEGIN
        FA_RX_UTIL_PKG.debug('Get deprn reserve initial value');
        -- Get initial value

          SELECT (NVL(deprn_reserve,0) - NVL(bonus_deprn_reserve,0))
          INTO JG_RX_FAREG.var.deprn_reserve_initial
          FROM fa_deprn_summary
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND period_counter         = (select max(period_counter)
                       from fa_deprn_summary
                       where period_counter <= (PARM.p_begin_period_counter-1)
                       and asset_id= JG_RX_FAREG.var.asset_id
                       and book_type_code = PARM.p_book_type_code );


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_reserve_initial =' || TO_CHAR(JG_RX_FAREG.var.deprn_reserve_initial));
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.deprn_reserve_initial := 0;
     END;


     -------------------------------------------------------------------------------
     BEGIN
        FA_RX_UTIL_PKG.debug('Get deprn reserve final value');
        -- Get final value
        SELECT (NVL(deprn_reserve,0) - NVL(bonus_deprn_reserve,0)),
               ytd_deprn
          INTO JG_RX_FAREG.var.deprn_reserve_final
               , JG_RX_FAREG.var.ytd_deprn
          FROM fa_deprn_summary
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND period_counter         =
                        (select max(period_counter)
                         from fa_deprn_summary
                         where period_counter <= PARM.p_end_period_counter
                         and asset_id= JG_RX_FAREG.var.asset_id
                         and book_type_code = PARM.p_book_type_code );


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_reserve_final =' || TO_CHAR(JG_RX_FAREG.var.deprn_reserve_final));
--Added this part to fix bug 3240485
        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.ytd_deprn='      || TO_CHAR(JG_RX_FAREG.var.ytd_deprn));
--Added the above part to fix bug 3240485
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.deprn_reserve_final := 0;
     END;


     -- It takes the deprn reserve increase
     Get_deprn_reserve_increase;

     -- It takes the deprn reserve decrease
     Get_deprn_reserve_decrease;

     -- 09/08/00 AFERRARA
     JG_RX_FAREG.var.deprn_variation := JG_RX_FAREG.var.deprn_reserve_increase -
                                  JG_RX_FAREG.var.deprn_reserve_decrease;

      FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_variation =' || JG_RX_FAREG.var.deprn_variation);
      -- 09/08/00 AFERRARA


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_value()-');

      EXCEPTION
         WHEN TOO_MANY_ROWS THEN
              X_msg := 'JG_RX_FAREG.Get_deprn_reserve_value: TOO_MANY_ROWS';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);


  END Get_deprn_reserve_value;



/*===================================================================+
|                      Get_deprn_reserve_increase                    |
+====================================================================*/
  PROCEDURE Get_deprn_reserve_increase
  IS

    X_ord_deprn                NUMBER := 0;
    X_reinstatements           NUMBER := 0;
    X_tax_re_adjustment_plus   NUMBER := 0;
    X_revaluation_cr	       NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_increase()+');

     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get ordinary depreciation ');

        SELECT SUM((NVL(deprn_amount,0) - NVL(bonus_deprn_amount,0)))
          INTO X_ord_deprn
          FROM fa_deprn_summary
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND period_counter         BETWEEN PARM.p_begin_period_counter
                                          AND PARM.p_end_period_counter;

     FA_RX_UTIL_PKG.debug('Ordinary depreciation =' || TO_CHAR(X_ord_deprn));


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get increase due to reinstatements and Revaluations ');

        SELECT nvl(abs(SUM(DECODE(adjustment_type,'RESERVE',adjustment_amount,0)) -
               SUM(DECODE(adjustment_type,'BONUS RESERVE',adjustment_amount,0))),0)
          INTO X_revaluation_cr
          FROM fa_adjustments            AD
         WHERE AD.source_type_code       = 'REVALUATION'     -- bug 5208066 removed reinstatement
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.debit_credit_flag      = 'CR'
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                          AND PARM.p_end_period_counter;

 --query added for bug 5208066 to separate revaluation and reinstatement

   SELECT nvl(abs(SUM(DECODE(adjustment_type,'RESERVE', DECODE(debit_credit_flag , 'CR' ,adjustment_amount, 'DR', (-1*adjustment_amount),0),0)) -
               SUM(DECODE(adjustment_type,'BONUS RESERVE',DECODE(debit_credit_flag , 'CR' ,adjustment_amount, 'DR', (-1*adjustment_amount),0),0))),0)

          INTO X_reinstatements
          FROM fa_adjustments            AD, fa_transaction_headers ft
         WHERE AD.source_type_code       = 'RETIREMENT'
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           and ft.asset_id               = ad.asset_id
           and ft.book_type_code         = ad.book_type_code
           and ft.transaction_header_id  = ad.transaction_header_id
           and ft.transaction_type_code in ('REINSTATEMENT')
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;

        X_reinstatements := X_reinstatements+X_revaluation_cr;


     FA_RX_UTIL_PKG.debug('Reinstatements =' || TO_CHAR(X_reinstatements));

     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get positive tax reserve adjustment ');

        SELECT SUM(adjustment_amount)
          INTO X_tax_re_adjustment_plus
          FROM fa_adjustments AD
         WHERE AD.source_type_code  = 'TAX'
           AND AD.adjustment_type   = 'RESERVE'
           AND AD.debit_credit_flag = 'CR'
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.period_counter_created BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;
-- changed period_counter_adjusted to period_counter_created
     FA_RX_UTIL_PKG.debug('Positive tax reserve adjustment =' || TO_CHAR(X_tax_re_adjustment_plus));


     JG_RX_FAREG.var.deprn_reserve_increase := NVL(X_ord_deprn,0)  +
                                              NVL(X_reinstatements,0) +
                                              NVL(X_tax_re_adjustment_plus,0);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_reserve_increase =' || JG_RX_FAREG.var.deprn_reserve_increase);


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_increase()-');


  END Get_deprn_reserve_increase;


/*===================================================================+
|                      Get_deprn_reserve_decrease                    |
+====================================================================*/
  PROCEDURE Get_deprn_reserve_decrease
  IS

    X_retirements               NUMBER := 0;
    X_financ_adjustment_minus   NUMBER := 0;
    X_tax_re_adjustment_minus   NUMBER := 0;
    X_revaluation_dr     	NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_decrease()+');


     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get deprn reserve decrease due to retirements and revaluations');

        SELECT nvl(abs(SUM(DECODE(adjustment_type,'RESERVE',adjustment_amount,0)) -
               SUM(DECODE(adjustment_type,'BONUS RESERVE',adjustment_amount,0))),0)
          INTO X_revaluation_dr
          FROM fa_adjustments            AD
         WHERE AD.source_type_code       = 'REVALUATION'  --bug 5208066 removed retirement
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.debit_credit_flag      = 'DR'
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;

 --query added for bug 5208066 to separate revaluation and retirement
SELECT nvl(abs(SUM(DECODE(adjustment_type,'RESERVE', DECODE(debit_credit_flag , 'DR' ,adjustment_amount, 'CR', (-1*adjustment_amount),0),0)) -
               SUM(DECODE(adjustment_type,'BONUS RESERVE',DECODE(debit_credit_flag , 'DR' ,adjustment_amount, 'CR', (-1*adjustment_amount),0),0))),0)

        INTO X_retirements
          FROM fa_adjustments            AD, fa_transaction_headers ft
         WHERE AD.source_type_code       = 'RETIREMENT'
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           and ft.asset_id               = ad.asset_id
           and ft.book_type_code         = ad.book_type_code
           and ft.transaction_header_id  = ad.transaction_header_id
           and ft.transaction_type_code in  ('PARTIAL RETIREMENT','FULL RETIREMENT')
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;

      X_retirements := X_retirements+X_revaluation_dr;

     FA_RX_UTIL_PKG.debug('Retirements =' || TO_CHAR(X_retirements));



     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get negative financial adjustment ');

        SELECT abs(SUM(DECODE(adjustment_type,'EXPENSE',adjustment_amount,0)) -
               SUM(DECODE(adjustment_type,'BONUS EXPENSE',adjustment_amount,0)))
          INTO X_financ_adjustment_minus
          FROM fa_adjustments AD
         WHERE AD.source_type_code  = 'DEPRECIATION'
           AND AD.adjustment_amount < 0
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;

     FA_RX_UTIL_PKG.debug('Negative financial adjustment =' || TO_CHAR(X_financ_adjustment_minus));

      JG_RX_FAREG.var.deprn_reserve_increase  := JG_RX_FAREG.var.deprn_reserve_increase +nvl(X_financ_adjustment_minus,0);

/*  to show the increase and then minus it */

     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get negative tax reserve adjustment ');

        SELECT SUM(adjustment_amount)
          INTO X_tax_re_adjustment_minus
          FROM fa_adjustments   AD
         WHERE AD.source_type_code  = 'TAX'
           AND AD.adjustment_type   = 'RESERVE'
           AND AD.debit_credit_flag = 'DR'
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.period_counter_created BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;
-- jmary changed period_counter_adjusted to period_counter_created
     FA_RX_UTIL_PKG.debug('Negative tax reserve adjustment =' || TO_CHAR(X_tax_re_adjustment_minus));


     JG_RX_FAREG.var.deprn_reserve_decrease := NVL(X_retirements,0) +
                                              NVL(X_financ_adjustment_minus,0)  +
                                              NVL(X_tax_re_adjustment_minus,0);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.deprn_reserve_decrease =' || JG_RX_FAREG.var.deprn_reserve_decrease);


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_deprn_reserve_decrease()-');


  END Get_deprn_reserve_decrease;



/*===================================================================+
|                       Get_bonus_reserve_value                      |
+====================================================================*/
  PROCEDURE Get_bonus_reserve_value
  IS

    X_msg                    VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_value()+');

     -------------------------------------------------------------------------------
     BEGIN
        FA_RX_UTIL_PKG.debug('Get bonus reserve initial value');
        -- Get initial value

           SELECT NVL(bonus_deprn_reserve,0)
           INTO JG_RX_FAREG.var.bonus_reserve_initial
           FROM fa_deprn_summary
           WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND period_counter         =
                      (SELECT max(period_counter)
                       FROM fa_deprn_summary
                       WHERE  period_counter <= (PARM.p_begin_period_counter-1)
                              AND  asset_id= JG_RX_FAREG.var.asset_id
                              AND book_type_code = PARM.p_book_type_code );


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.bonus_reserve_initial =' || TO_CHAR(JG_RX_FAREG.var.bonus_reserve_initial));
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.bonus_reserve_initial := 0;
     END;


     -------------------------------------------------------------------------------
     BEGIN
        FA_RX_UTIL_PKG.debug('Get bonus reserve final value');
        -- Get final value
        SELECT NVL(bonus_deprn_reserve,0)
          INTO JG_RX_FAREG.var.bonus_reserve_final
          FROM fa_deprn_summary
          WHERE book_type_code         = PARM.p_book_type_code
                AND asset_id               = JG_RX_FAREG.var.asset_id
                AND period_counter         =
                     (SELECT  max(period_counter)
                       FROM fa_deprn_summary
                       WHERE period_counter <= PARM.p_end_period_counter
                       AND asset_id= JG_RX_FAREG.var.asset_id
                       AND  book_type_code = PARM.p_book_type_code );


        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.bonus_reserve_final =' || TO_CHAR(JG_RX_FAREG.var.bonus_reserve_final));
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                JG_RX_FAREG.var.bonus_reserve_final := 0;
     END;


     -- It takes the bonus reserve increase
     Get_bonus_reserve_increase;

     -- It takes the deprn reserve decrease
     Get_bonus_reserve_decrease;
      -- 09/08/00 AFERRARA
      JG_RX_FAREG.var.bonus_variation := JG_RX_FAREG.var.bonus_reserve_increase -
                                   JG_RX_FAREG.var.bonus_reserve_decrease;

      FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.bonus_variation =' || JG_RX_FAREG.var.bonus_variation);
      -- 09/08/00 AFERRARA



     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_value()-');

     EXCEPTION
         WHEN TOO_MANY_ROWS THEN
              X_msg := 'JG_RX_FAREG.Get_bonus_reserve_value: TOO_MANY_ROWS';
              FA_RX_UTIL_PKG.debug(X_msg);
              RAISE_APPLICATION_ERROR(-20010,X_msg);


  END Get_bonus_reserve_value;



/*===================================================================+
|                      Get_bonus_reserve_increase                    |
+====================================================================*/
  PROCEDURE Get_bonus_reserve_increase
  IS

    X_bonus_deprn              NUMBER := 0;
    X_reinstatements           NUMBER := 0;
    X_financ_adjustment_plus   NUMBER := 0;
    X_tax_re_adjustment_plus   NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_increase()+');

     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get bonus depreciation ');

        SELECT sum(bonus_deprn_amount)
          INTO X_bonus_deprn
          FROM fa_deprn_summary
         WHERE book_type_code         = PARM.p_book_type_code
           AND asset_id               = JG_RX_FAREG.var.asset_id
           AND period_counter         BETWEEN PARM.p_begin_period_counter
                                          AND PARM.p_end_period_counter;

     FA_RX_UTIL_PKG.debug('Bonus depreciation =' || TO_CHAR(X_bonus_deprn));


    -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get reinstatements ');

        SELECT SUM(adjustment_amount)
          INTO X_reinstatements
          FROM fa_adjustments            AD
         WHERE AD.source_type_code       in ('RETIREMENT','REVALUATION')
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.adjustment_type        = 'BONUS RESERVE'
           AND AD.debit_credit_flag      = 'CR'
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                          AND PARM.p_end_period_counter;
     FA_RX_UTIL_PKG.debug('Reinstatements =' || TO_CHAR(X_reinstatements));


     JG_RX_FAREG.var.bonus_reserve_increase := NVL(X_bonus_deprn,0)  +
                                              NVL(X_reinstatements,0) ;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.bonus_reserve_increase =' || JG_RX_FAREG.var.bonus_reserve_increase);


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_increase()-');


  END Get_bonus_reserve_increase;


/*===================================================================+
|                      Get_bonus_reserve_decrease                    |
+====================================================================*/
  PROCEDURE Get_bonus_reserve_decrease
  IS

    X_retirements               NUMBER := 0;
    X_financ_adjustment_minus   NUMBER := 0;

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_decrease()+');


    -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get retirements and revaluations ');
         SELECT ABS(SUM(adjustment_amount))
		  INTO X_retirements
          FROM fa_adjustments AD
         WHERE AD.source_type_code  in ('RETIREMENT','REVALUATION')
		   AND AD.adjustment_type   = 'BONUS RESERVE'
           AND AD.debit_credit_flag      = 'DR'
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;


     FA_RX_UTIL_PKG.debug('Retirements =' || TO_CHAR(X_retirements));



     -------------------------------------------------------------------------------
     FA_RX_UTIL_PKG.debug('Get Negative financial adjustment ');
         SELECT ABS(SUM(adjustment_amount))
		  INTO X_financ_adjustment_minus
          FROM fa_adjustments AD
         WHERE AD.source_type_code  = 'DEPRECIATION'
		   AND AD.adjustment_type   = 'BONUS EXPENSE'
		   AND AD.adjustment_amount < 0
           AND AD.book_type_code         = PARM.p_book_type_code
           AND AD.asset_id               = JG_RX_FAREG.var.asset_id
           AND AD.period_counter_adjusted BETWEEN PARM.p_begin_period_counter
                                           AND PARM.p_end_period_counter;
      JG_RX_FAREG.var.bonus_reserve_increase  := JG_RX_FAREG.var.bonus_reserve_increase +nvl(X_financ_adjustment_minus,0);

     FA_RX_UTIL_PKG.debug('Negative financial adjustment =' || TO_CHAR(X_financ_adjustment_minus));


     JG_RX_FAREG.var.bonus_reserve_decrease := NVL(X_retirements,0) +
                                              NVL(X_financ_adjustment_minus,0);

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.bonus_reserve_decrease =' || JG_RX_FAREG.var.bonus_reserve_decrease);


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_reserve_decrease()-');


  END Get_bonus_reserve_decrease;


/*===================================================================+
|                      Get_fiscal_year_date                          |
+====================================================================*/
  PROCEDURE Get_fiscal_year_date
  IS

  X_msg               VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_fiscal_year_date()+');

     SELECT start_date,
            end_date,
            deprn_calendar,
            prorate_calendar
       INTO X_fiscal_year_start_date,
            X_fiscal_year_end_date,
            X_deprn_calendar,
            X_prorate_calendar
       FROM fa_fiscal_year    FY,
            fa_book_controls  BC
      WHERE FY.fiscal_year      = X_fiscal_year
        AND FY.fiscal_year_name = BC.fiscal_year_name
        AND BC.book_type_code   = PARM.p_book_type_code;


     FA_RX_UTIL_PKG.debug('X_fiscal_year_start_date =' || TO_CHAR(X_fiscal_year_start_date));
     FA_RX_UTIL_PKG.debug('X_fiscal_year_end_date =' || TO_CHAR(X_fiscal_year_end_date));


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_fiscal_year_date()-');

 -- Added for ECE Project
 BEGIN
	SELECT number_per_fiscal_year
        INTO X_number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = X_deprn_calendar;

       	JG_RX_FAREG.var.life_in_years := JG_RX_FAREG.var.life_in_months / X_number_per_fiscal_year;

 END;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_msg := 'JG_RX_FAREG.Get_fiscal_year_date: NO_DATA_FOUND';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

        WHEN TOO_MANY_ROWS THEN
             X_msg := 'JG_RX_FAREG.Get_fiscal_year_date: TOO_MANY_ROWS';
             FA_RX_UTIL_PKG.debug(X_msg);
             RAISE_APPLICATION_ERROR(-20010,X_msg);

  END Get_fiscal_year_date;


/*===================================================================+
|                      Get_bonus_rate                                |
+====================================================================*/
  PROCEDURE Get_bonus_rate
  IS

  X_year                         NUMBER;
  X_starting_depreciation_year   NUMBER(4);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_rate()+');

     JG_RX_FAREG.var.bonus_rate := 0; -- To print 0 instead of NULL

     IF JG_RX_FAREG.var.bonus_rule IS NOT NULL THEN
        FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_bonus_rate: JG_RX_FAREG.var.bonus_rule IS NOT NULL');

        X_starting_depreciation_year := Get_starting_depreciation_year;

        X_year := TO_NUMBER(X_fiscal_year) - X_starting_depreciation_year + 1;

        SELECT (bonus_rate*100)
          INTO JG_RX_FAREG.var.bonus_rate
          FROM fa_bonus_rates
         WHERE bonus_rule = JG_RX_FAREG.var.bonus_rule
           AND X_year BETWEEN start_year
                          AND end_year;

     END IF;

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             JG_RX_FAREG.var.bonus_rate := 0;

  END Get_bonus_rate;


/*===================================================================+
|                         Get_transactions                           |
+====================================================================*/
  PROCEDURE Get_transactions
  IS

  X_msg               VARCHAR2(100);

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_transactions()+');

     Get_addition_transactions;

     Get_adjustment_transactions;

     Get_retirement_transactions;

     Get_revaluation_transactions;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_transactions()-');

  END Get_transactions;


/*===================================================================+
|                    Get_addition_transactions                       |
+====================================================================*/
  PROCEDURE Get_addition_transactions
  IS

   CURSOR c_additon_trans IS
          SELECT TH.transaction_type_code,
                 TH.transaction_header_id,
                 BO.date_placed_in_service,
                 BO.cost
            FROM fa_transaction_headers TH,
                 fa_books				 BO
           WHERE BO.transaction_header_id_in = TH.transaction_header_id
             AND BO.book_type_code           = TH.book_type_code
             AND BO.asset_id                 = TH.asset_id
             AND TH.transaction_type_code    = 'ADDITION'
             AND TH.book_type_code           = PARM.p_book_type_code
             AND TH.asset_id                 = JG_RX_FAREG.var.asset_id
             AND TH.transaction_date_entered BETWEEN X_fiscal_year_start_date
                                       AND PARM.p_end_period_to_date;
-- changing X_fiscal_year_end_date to PARM.p_end_period_to_date
  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_addition_transactions()+');
     FOR c_addition IN c_additon_trans LOOP
        IF (X_first_row = FALSE and c_additon_trans%ROWCOUNT=0) then
            exit ;
         end if;
         IF X_first_row = FALSE THEN  -- It is the first time...
            JG_RX_FAREG.var.transaction_date   := c_addition.date_placed_in_service;
            JG_RX_FAREG.var.transaction_number := c_addition.transaction_header_id;
            JG_RX_FAREG.var.transaction_code   := c_addition.transaction_type_code;
            JG_RX_FAREG.var.transaction_amount := c_addition.cost;
            X_first_row := TRUE;
         ELSE  -- The current row is alredy used
            Insert_transaction(p_transaction_date   => c_addition.date_placed_in_service,
                               p_transaction_number => c_addition.transaction_header_id,
                               p_transaction_code   => c_addition.transaction_type_code,
                               p_transaction_amount => c_addition.cost);
         END IF;

     END LOOP;
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_addition_transactions()-');

  END Get_addition_transactions;


/*===================================================================+
|                    Get_adjustment_transactions                     |
+====================================================================*/
  PROCEDURE Get_adjustment_transactions
  IS

   CURSOR c_adjustment_trans IS
          SELECT TH.transaction_type_code,
                 TH.transaction_header_id,
                 TH.transaction_date_entered,
                 decode(debit_credit_flag,'CR',(-1*AD.ADJUSTMENT_AMOUNT),AD.ADJUSTMENT_AMOUNT) ADJUSTMENT_AMOUNT
            FROM fa_transaction_headers TH,
                 fa_ADJUSTMENTS               AD
           WHERE AD.transaction_header_id = TH.transaction_header_id
             AND AD.book_type_code           = TH.book_type_code
             AND AD.asset_id                 = TH.asset_id
             AND TH.transaction_type_code    = 'ADJUSTMENT'
             AND AD.source_type_code         = TH.transaction_type_code
             AND AD.adjustment_type          = 'COST'
             AND TH.book_type_code           = PARM.p_book_type_code
             AND TH.asset_id                 = JG_RX_FAREG.var.asset_id
             AND TH.transaction_date_entered BETWEEN X_fiscal_year_start_date
                                             AND PARM.p_end_period_to_date;

-- changing X_fiscal_year_end_date to PARM.p_end_period_to_date

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_adjustment_transactions()+');
     FOR c_adjustment IN c_adjustment_trans LOOP
         IF (X_first_row = FALSE and c_adjustment_trans%ROWCOUNT=0) then
            exit ;
         end if;
         IF X_first_row = FALSE THEN  -- It is the first time...
            JG_RX_FAREG.var.transaction_date   := c_adjustment.transaction_date_entered;
            JG_RX_FAREG.var.transaction_number := c_adjustment.transaction_header_id;
            JG_RX_FAREG.var.transaction_code   := c_adjustment.transaction_type_code;
            JG_RX_FAREG.var.transaction_amount := c_adjustment.adjustment_amount;
            X_first_row := TRUE;
         ELSE  -- The current row is alredy used
            Insert_transaction(p_transaction_date   => c_adjustment.transaction_date_entered,
                               p_transaction_number => c_adjustment.transaction_header_id,
                               p_transaction_code   => c_adjustment.transaction_type_code,
                               p_transaction_amount => c_adjustment.adjustment_amount);
         END IF;

     END LOOP;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_adjustment_transactions()-');

  END Get_adjustment_transactions;



/*===================================================================+
|                    Get_retirement_transactions                       |
+====================================================================*/
  PROCEDURE Get_retirement_transactions
  IS

   CURSOR c_retirement_trans IS
          SELECT TH.transaction_type_code,
                 TH.transaction_header_id,
                 th.transaction_date_entered,
                 RE.cost_retired
            FROM fa_transaction_headers TH,
                 fa_retirements         RE
           WHERE (RE.transaction_header_id_in = TH.transaction_header_id
                  OR RE.transaction_header_id_out = TH.transaction_header_id)
             AND RE.book_type_code           = TH.book_type_code
             AND RE.asset_id                 = TH.asset_id
            AND TH.TRANSACTION_TYPE_CODE IN ('PARTIAL RETIREMENT','FULL RETIREMENT','REINSTATEMENT')          --   AND RE.STATUS                 = 'PROCESSED'
             AND TH.book_type_code           = PARM.p_book_type_code
             AND TH.asset_id                 = JG_RX_FAREG.var.asset_id
             AND th.transaction_date_entered BETWEEN X_fiscal_year_start_date
                                             AND PARM.p_end_period_to_date;

-- changing X_fiscal_year_end_date to PARM.p_end_period_to_date

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_retirement_transactions()+');

     FOR c_retirement IN c_retirement_trans LOOP
         IF (X_first_row = FALSE and c_retirement_trans%ROWCOUNT=0) then
            exit ;
         end if;
         IF X_first_row = FALSE THEN  -- It is the first time...
            JG_RX_FAREG.var.transaction_date   := c_retirement.transaction_date_entered;
            JG_RX_FAREG.var.transaction_number := c_retirement.transaction_header_id;
            JG_RX_FAREG.var.transaction_code   := c_retirement.transaction_type_code;
            JG_RX_FAREG.var.transaction_amount := c_retirement.cost_retired;
            X_first_row := TRUE;
         ELSE  -- The current row is alredy used
            Insert_transaction(p_transaction_date   => c_retirement.transaction_date_entered,
                               p_transaction_number => c_retirement.transaction_header_id,
                               p_transaction_code   => c_retirement.transaction_type_code,
                               p_transaction_amount => c_retirement.cost_retired);
         END IF;

     END LOOP;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_retirement_transactions()-');

  END Get_retirement_transactions;

/*===================================================================+
|                    Get_revaluation_transactions                    |
+====================================================================*/
  PROCEDURE Get_revaluation_transactions
  IS

   CURSOR c_revaluation_trans IS
          SELECT TH.transaction_type_code,
                 TH.transaction_header_id,
                 TH.transaction_date_entered,
    decode(debit_credit_flag,'CR',(-1*sum(AD.ADJUSTMENT_AMOUNT)),sum(AD.ADJUSTMENT_AMOUNT)) ADJUSTMENT_AMOUNT
     --            SUM(AD.adjustment_amount) adjustment_amount
            FROM fa_transaction_headers TH,
                 fa_adjustments         AD
           WHERE AD.transaction_header_id    = TH.transaction_header_id
             AND AD.book_type_code           = TH.book_type_code
             AND AD.asset_id                 = TH.asset_id
             AND AD.adjustment_type          = 'COST'
             AND TH.TRANSACTION_TYPE_CODE    = 'REVALUATION'
             AND TH.book_type_code           = PARM.p_book_type_code
             AND TH.asset_id                 = JG_RX_FAREG.var.asset_id
             AND TH.transaction_date_entered BETWEEN X_fiscal_year_start_date
                                       AND PARM.p_end_period_to_date
            GROUP BY TH.transaction_type_code,
                     TH.transaction_header_id,
                     TH.transaction_date_entered,debit_credit_flag;

-- changing X_fiscal_year_end_date to PARM.p_end_period_to_date

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation_transactions()+');
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation_transactions()+');
     FOR c_revaluation IN c_revaluation_trans LOOP
        IF X_first_row = FALSE THEN  -- It is the first time...
            JG_RX_FAREG.var.transaction_date   := c_revaluation.transaction_date_entered;
            JG_RX_FAREG.var.transaction_number := c_revaluation.transaction_header_id;
            JG_RX_FAREG.var.transaction_code   := c_revaluation.transaction_type_code;
            JG_RX_FAREG.var.transaction_amount := c_revaluation.adjustment_amount;
            X_first_row := TRUE;
         ELSE  -- The current row is alredy used
              FA_RX_UTIL_PKG.debug('JG_RX_FAREG.rowcount'||to_char(c_revaluation_trans%ROWCOUNT));
            Insert_transaction(p_transaction_date   => c_revaluation.transaction_date_entered,
                               p_transaction_number => c_revaluation.transaction_header_id,
                               p_transaction_code   => c_revaluation.transaction_type_code,
                               p_transaction_amount => c_revaluation.adjustment_amount);
         END IF;

     END LOOP;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_revaluation_transactions()-');

  END Get_revaluation_transactions;


/*===================================================================+
|                     Insert_transaction                             |
+====================================================================*/
  PROCEDURE Insert_transaction( p_transaction_date     DATE,
                                p_transaction_number   NUMBER,
                                p_transaction_code     VARCHAR2,
                                p_transaction_amount   NUMBER)
  IS

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Insert_transaction()+');

     INSERT INTO jg_zz_fa_reg_itf(
                 request_id,
                 organization_name,
                 functional_currency_code,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 creation_date,
                 created_by,
                 major_category,
                 minor_category,
                 deprn_rate,
                 starting_deprn_year,
                 date_placed_in_service,
                 asset_heading,
                 asset_number,
                 description,
                 parent_asset_id,
                 parent_asset_number,
                 asset_cost_orig,
                 bonus_rate,
                 invoice_number,
                 supplier_name,
                 cost_account,
                 expense_account,
                 reserve_account,
                 bonus_deprn_account,
                 bonus_reserve_account,
                 asset_cost_initial,
                 asset_cost_increase,
                 asset_cost_decrease,
                 asset_cost_final,
                 revaluation_initial,
                 revaluation_increase,
                 revaluation_decrease,
                 revaluation_final,
                 deprn_reserve_initial,
                 deprn_reserve_increase,
                 deprn_reserve_decrease,
                 deprn_reserve_final,
                 bonus_reserve_initial,
                 bonus_reserve_increase,
                 bonus_reserve_decrease,
                 bonus_reserve_final,
                 net_book_value_initial,
                 net_book_value_increase,
                 net_book_value_decrease,
                 net_book_value_final,
                 transaction_date,
                 transaction_number,
                 transaction_code,
                 transaction_amount,
                 sales_amount,
                 cost_retired,
                 deprn_reserve,
                 bonus_reserve,
                 net_book_value,
                 gain_loss,
                 date_retired,
                 initial_heading,          -- 09/08/00 AFERRARA
                 variation_heading,        -- 09/08/00 AFERRARA
                 final_heading,            -- 09/08/00 AFERRARA
                 asset_variation,          -- 09/08/00 AFERRARA
                 reval_variation,          -- 09/08/00 AFERRARA
                 deprn_variation,          -- 09/08/00 AFERRARA
                 bonus_variation,          -- 09/08/00 AFERRARA
                 netbo_variation,          -- 09/08/00 AFERRARA
                 revaluation_total         -- 09/08/00 AFERRARA
                 --- Added for ECE Project
		,depreciation_method
		,life_in_months
		,life_in_years
		,prorate_convention
		,tag_number
		,serial_number
		,asset_key_flexfield
              -- Added to fix bug 3240485
                ,ytd_deprn
              -- Added above to fix bug 3240485
                )
         VALUES(
                 X_request_id,
                 JG_RX_FAREG.var.organization_name,
                 JG_RX_FAREG.var.functional_currency_code,
                 X_last_update_date,
                 X_last_updated_by,
                 X_last_update_login,
                 X_creation_date,
                 X_created_by,
                 JG_RX_FAREG.var.major_category,
                 JG_RX_FAREG.var.minor_category,
                 JG_RX_FAREG.var.deprn_rate,
                 JG_RX_FAREG.var.starting_deprn_year,
                 JG_RX_FAREG.var.date_placed_in_service,
                 JG_RX_FAREG.var.asset_heading,
                 JG_RX_FAREG.var.asset_number,
                 JG_RX_FAREG.var.description,
                 JG_RX_FAREG.var.parent_asset_id,
                 JG_RX_FAREG.var.parent_asset_number,
                 JG_RX_FAREG.var.asset_cost_orig,
                 JG_RX_FAREG.var.bonus_rate,
                 JG_RX_FAREG.var.invoice_number,
                 JG_RX_FAREG.var.supplier_name,
                 JG_RX_FAREG.var.cost_account,
                 JG_RX_FAREG.var.expense_account,
                 JG_RX_FAREG.var.reserve_account,
                 JG_RX_FAREG.var.bonus_deprn_account,
                 JG_RX_FAREG.var.bonus_reserve_account,
                 JG_RX_FAREG.var.asset_cost_initial,
                 JG_RX_FAREG.var.asset_cost_increase,
                 JG_RX_FAREG.var.asset_cost_decrease,
                 JG_RX_FAREG.var.asset_cost_final,
                 JG_RX_FAREG.var.revaluation_initial,
                 JG_RX_FAREG.var.revaluation_increase,
                 JG_RX_FAREG.var.revaluation_decrease,
                 JG_RX_FAREG.var.revaluation_final,
                 JG_RX_FAREG.var.deprn_reserve_initial,
                 JG_RX_FAREG.var.deprn_reserve_increase,
                 JG_RX_FAREG.var.deprn_reserve_decrease,
                 JG_RX_FAREG.var.deprn_reserve_final,
                 JG_RX_FAREG.var.bonus_reserve_initial,
                 JG_RX_FAREG.var.bonus_reserve_increase,
                 JG_RX_FAREG.var.bonus_reserve_decrease,
                 JG_RX_FAREG.var.bonus_reserve_final,
                 JG_RX_FAREG.var.net_book_value_initial,
                 JG_RX_FAREG.var.net_book_value_increase,
                 JG_RX_FAREG.var.net_book_value_decrease,
                 JG_RX_FAREG.var.net_book_value_final,
                 p_transaction_date,
                 p_transaction_number,
                 p_transaction_code,
                 p_transaction_amount,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 JG_RX_FAREG.var.initial_heading,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.variation_heading,        -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.final_heading,            -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.asset_variation,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.reval_variation,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.deprn_variation,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.bonus_variation,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.netbo_variation,          -- 09/08/00 AFERRARA
                 JG_RX_FAREG.var.revaluation_total         -- 09/08/00 AFERRARA
                  -- Added for ECE Project
		,JG_RX_FAREG.var.depriciation_method
		,JG_RX_FAREG.var.life_in_months
		,JG_RX_FAREG.var.life_in_years
		,JG_RX_FAREG.var.prorate_convention
		,JG_RX_FAREG.var.tag_number
		,JG_RX_FAREG.var.serial_number
		,JG_RX_FAREG.var.asset_key_flexfield
              --Added to fix bug 3240485
                ,JG_RX_FAREG.var.ytd_deprn
              -- Added above to fix bug 3240485
                );


     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Insert_transaction()-');

  END Insert_transaction;


/*===================================================================+
|                    Get_Net_Book_Value                              |
+====================================================================*/
  PROCEDURE Get_Net_Book_Value
  IS

  BEGIN
     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_Net_Book_Value()+');

     JG_RX_FAREG.var.net_book_value_initial := NVL(JG_RX_FAREG.var.asset_cost_initial,0)    -
                                              NVL(JG_RX_FAREG.var.deprn_reserve_initial,0) -
                                              NVL(JG_RX_FAREG.var.bonus_reserve_initial,0) ;

     JG_RX_FAREG.var.net_book_value_increase := NVL(JG_RX_FAREG.var.asset_cost_increase,0)    +
                                               NVL(JG_RX_FAREG.var.deprn_reserve_decrease,0) +
                                               NVL(JG_RX_FAREG.var.bonus_reserve_decrease,0) ;



     JG_RX_FAREG.var.net_book_value_decrease := NVL(JG_RX_FAREG.var.asset_cost_decrease,0)    +
                                               NVL(JG_RX_FAREG.var.deprn_reserve_increase,0) +
                                               NVL(JG_RX_FAREG.var.bonus_reserve_increase,0) ;

     -- + 09/08/00 AFERRARA
     JG_RX_FAREG.var.netbo_variation := JG_RX_FAREG.var.net_book_value_increase -
                                   JG_RX_FAREG.var.net_book_value_decrease;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.var.netbo_variation =' || JG_RX_FAREG.var.netbo_variation);
     -- - 09/08/00 AFERRARA

     JG_RX_FAREG.var.net_book_value_final := NVL(JG_RX_FAREG.var.asset_cost_final,0)    -
                                            NVL(JG_RX_FAREG.var.deprn_reserve_final,0) -
                                            NVL(JG_RX_FAREG.var.bonus_reserve_final,0) ;

     FA_RX_UTIL_PKG.debug('JG_RX_FAREG.Get_Net_Book_Value()-');

  END Get_Net_Book_Value;


END JG_RX_FAREG;

/
