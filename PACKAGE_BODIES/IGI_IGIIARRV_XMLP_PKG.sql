--------------------------------------------------------
--  DDL for Package Body IGI_IGIIARRV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGIIARRV_XMLP_PKG" AS
/* $Header: IGIIARRVB.pls 120.0.12010000.1 2008/07/29 08:58:47 appldev ship $ */
FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DO_INSERT:=DO_INSERTFORMULA();
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    ROLLBACK;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;


procedure Debug_print(p_char varchar2) IS
l_log varchar2(30);
l_out varchar2(30);
begin
	--fnd_file.get_names(l_log,l_out);
	fnd_file.put_line(1,p_char);
	--srw.message(1000,p_char);
	null;
end;


procedure FDRCSID(idstring in varchar2) is
  BEGIN
    IF (idstring is NULL) THEN
      NULL;
    END IF;
        --        FDRCSID('$Header: IGIIARRVB.pls 120.0.12010000.1 2008/07/29 08:58:47 appldev ship $');
  END;


PROCEDURE Get_Adjustments  (
	p_book               varchar2,
        p_distribution_source_book   varchar2,
	p_period1_pc         number,
        p_period2_pc         number,
        p_report_type        varchar2,
        p_balance_type       varchar2)
    IS
        l_account_type      varchar2(25);
	l_balance_type	    varchar2(3);
    l_data_source       varchar2(30);
    l_display_order     number(5);
    h_set_of_books_id number;
  BEGIN

        BEGIN
            select set_of_books_id
             into h_set_of_books_id
             from fa_book_controls
             where book_type_code = p_book;
        EXCEPTION
            WHEN OTHERS THEN
                h_set_of_books_id := NULL;
                Debug_Print('Error in fetching set_of_books_id :'||sqlerrm);
        END;

        debug_print('Parameters to Get_Adjustments');
        debug_print('Book :'|| p_book);
        debug_print('Distribution Source Book :'|| p_distribution_source_book);
        debug_print('p_period1_pc :'||p_period1_pc);
        debug_print('p_period2_pc :'||p_period2_pc);
        debug_print('p_report_type :'||p_report_type);
        debug_print('p_balance_type :'||p_balance_type);

        IF (p_report_type = 'COST' OR p_report_type = 'RESERVE') THEN

            INSERT INTO IGI_IAC_BALANCES_REPORT
               (Asset_ID,
                Distribution_CCID,
                Adjustment_CCID,
                Category_Books_Account,
                Source_Type_Code,
                Amount,
                Data_Source,
                Display_order)
            SELECT
                DH.Asset_ID,
                DH.Code_Combination_ID,
                lines.code_combination_id, --AJ.Code_Combination_ID,
                null,
                AJ.Source_Type_Code,
                SUM (DECODE (AJ.Debit_Credit_Flag, p_Balance_Type, 1, -1) *
                    AJ.Adjustment_Amount),
        	'FA',
        	 1
            FROM
                FA_DISTRIBUTION_HISTORY DH,
                FA_TRANSACTION_HEADERS  TH,
                FA_ASSET_HISTORY        AH,
                FA_ADJUSTMENTS          AJ

                /* SLA Changes */
                ,xla_ae_headers headers
                ,xla_ae_lines lines
                ,xla_distribution_links links
            WHERE
                DH.Book_Type_Code       = p_Distribution_Source_Book        AND
                AJ.Asset_ID             = DH.Asset_ID           AND
                AJ.Book_Type_Code       = p_Book                  AND
                AJ.Distribution_ID      = DH.Distribution_ID    AND
                AJ.Adjustment_Type      in
                    (p_Report_Type, DECODE(p_Report_Type,
                            'REVAL RESERVE', 'REVAL AMORT')) AND
                AJ.Period_Counter_Created BETWEEN
                            p_Period1_PC AND p_Period2_PC    AND
                TH.Transaction_Header_ID        = AJ.Transaction_Header_ID    AND
                AH.Asset_ID             = DH.Asset_ID           AND
                ((AH.Asset_Type         <> 'EXPENSED' AND
                    p_Report_Type IN ('COST', 'OP EXPENSE')) OR
                 (AH.Asset_Type         = 'CAPITALIZED' AND
                    p_Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
                TH.Transaction_Header_ID BETWEEN
                    AH.Transaction_Header_ID_In AND
                    NVL (AH.Transaction_Header_ID_Out - 1,
                            TH.Transaction_Header_ID)    AND
                (DECODE (p_report_type, AJ.Adjustment_Type, 1, 0) *
                    AJ.Adjustment_Amount) <> 0

                /* SLA Changes */
                and links.Source_distribution_id_num_1 = aj.transaction_header_id
                and links.Source_distribution_id_num_2 = aj.adjustment_line_id
                and links.application_id               = 140
                and links.source_distribution_type     = 'TRX'
                and headers.application_id             = 140
                and headers.ae_header_id               = links.ae_header_id
                and headers.ledger_id                  = h_set_of_books_id
                and lines.ae_header_id                 = links.ae_header_id
                and lines.ae_line_num                  = links.ae_line_num
                and lines.application_id               = 140

            GROUP BY
                DH.Asset_ID,
                DH.Code_Combination_ID,
                lines.code_combination_id, --AJ.Code_Combination_ID,
                AJ.Source_Type_Code;

        END IF;

        IF (p_report_type = 'COST') THEN

            INSERT INTO IGI_IAC_BALANCES_REPORT
                (Asset_ID,
                Distribution_CCID,
                Adjustment_CCID,
                Category_Books_Account,
                Source_Type_Code,
                Amount,
                Data_Source,
                Display_order)
            SELECT
                DH.Asset_ID,
                DH.Code_Combination_ID,
                AJ.Code_Combination_ID,
                null,
                DECODE(TH.Transaction_Type_Code,
                        'FULL RETIREMENT','RETIREMENT',
						'PARTIAL RETIRE','RETIREMENT',
						'REINSTATEMENT','RETIREMENT',
                        'REVALUATION',DECODE(TH.Transaction_sub_Type,
                                                'IMPLEMENTATION','ADDITION',
                                                TH.Transaction_Type_Code),
			 TH.Transaction_Type_Code),
                SUM (DECODE (AJ.Dr_Cr_Flag, p_Balance_Type, 1, -1) *
                    AJ.Amount),
		'IAC',
		2
            FROM
                FA_DISTRIBUTION_HISTORY     DH,
                IGI_IAC_TRANSACTION_HEADERS TH,
                IGI_IAC_ADJUSTMENTS         AJ
            WHERE
                DH.Book_Type_Code       = p_Distribution_Source_Book    AND
                AJ.Asset_ID             = DH.Asset_ID           AND
                AJ.Book_Type_Code       = p_Book                  AND
                AJ.Distribution_ID      = DH.Distribution_ID    AND
                AJ.Adjustment_Type      = p_Report_Type AND
                AJ.Period_Counter BETWEEN
                            p_Period1_PC AND p_Period2_PC    AND
                AJ.transfer_to_gl_flag  <> 'N'              AND
                TH.adjustment_ID        = AJ.adjustment_ID
            GROUP BY
                DH.Asset_ID,
                DH.Code_Combination_ID,
                AJ.Code_Combination_ID,
                TH.Transaction_Type_Code,
                TH.Transaction_sub_Type;

        END IF;

        IF (p_report_type = 'BL RESERVE' OR p_report_type = 'RESERVE') THEN

            INSERT INTO IGI_IAC_BALANCES_REPORT
                (Asset_ID,
                Distribution_CCID,
                Adjustment_CCID,
                Category_Books_Account,
                Source_Type_Code,
                Amount,
                Data_Source,
                Display_order)
            SELECT
                DH.Asset_ID,
                DH.Code_Combination_ID,
                AJ.Code_Combination_ID,
                null,
                DECODE(TH.Transaction_Type_Code,
                        'FULL RETIREMENT','RETIREMENT',
						'PARTIAL RETIRE','RETIREMENT',
						'REINSTATEMENT','RETIREMENT',
                        'REVALUATION',DECODE(TH.Transaction_sub_Type,
                                            'IMPLEMENTATION','DEPRECIATION',
                                            TH.Transaction_Type_Code),
			TH.Transaction_Type_Code),
                SUM (DECODE (AJ.Dr_Cr_Flag, p_Balance_Type, 1, -1) *
                    AJ.Amount),
		'IAC',
		2
            FROM
                FA_DISTRIBUTION_HISTORY     DH,
                IGI_IAC_TRANSACTION_HEADERS TH,
                IGI_IAC_ADJUSTMENTS         AJ
            WHERE
                DH.Book_Type_Code       = p_Distribution_Source_Book    AND
                AJ.Asset_ID             = DH.Asset_ID           AND
                AJ.Book_Type_Code       = p_Book                  AND
                AJ.Distribution_ID      = DH.Distribution_ID    AND
                AJ.Adjustment_Type      = p_Report_Type AND
                AJ.Period_Counter BETWEEN
                            p_Period1_PC AND p_Period2_PC    AND
                AJ.transfer_to_gl_flag  <> 'N'              AND
                TH.adjustment_ID        = AJ.adjustment_ID
            GROUP BY
                DH.Asset_ID,
                DH.Code_Combination_ID,
                AJ.Code_Combination_ID,
                TH.Transaction_Type_Code,
                TH.Transaction_sub_type;

        END IF;

        IF (p_report_type = 'REVAL RESERVE' OR p_report_type = 'OP EXPENSE') THEN

	    debug_print('INSIDE COST for reval reserve');

            FOR counter IN 1..4 LOOP

                IF counter = 1 THEN
		    IF p_report_type = 'REVAL RESERVE' THEN
	                    l_account_type := 'COST';
			    l_balance_type := 'DR';
                l_data_source := 'Cost';
                l_display_order := 1;
		    ELSIF p_report_type = 'OP EXPENSE' THEN
		   	   l_account_type := 'COST' ;
			   l_balance_type := 'CR' ;
               l_data_source := 'Cost';
               l_display_order := 1;
		    END IF ;
                ELSIF counter = 2 THEN
                    l_account_type := 'BL RESERVE';
		    l_balance_type := p_balance_type;
            l_data_source := 'Backlog';
            IF p_report_type = 'REVAL RESERVE' THEN
                l_display_order := 3;
            ELSIF p_report_type = 'OP EXPENSE' THEN
                l_display_order := 2;
            END IF;
                ELSIF counter = 3 THEN
                    l_account_type := 'GENERAL FUND';
		    l_balance_type := p_balance_type;
            l_data_source := 'General Fund';
            l_display_order := 2;
                ELSE
                    l_account_type := p_report_type;
		    l_balance_type := p_balance_type;
            l_data_source := 'Net';
            IF p_report_type = 'REVAL RESERVE' THEN
                l_display_order := 4;
            ELSIF p_report_type = 'OP EXPENSE' THEN
                l_display_order := 3;
            END IF;

                END IF;


            IF (l_account_type IN ('COST','GENERAL FUND','BL RESERVE') AND
                NOT(p_report_type = 'OP EXPENSE' AND l_account_type = 'GENERAL FUND')) THEN

                    INSERT INTO IGI_IAC_BALANCES_REPORT
	                    (Asset_ID,
	                    Distribution_CCID,
	                    Adjustment_CCID,
	                    Category_Books_Account,
	                    Source_Type_Code,
	                    Amount,
	                    Data_Source,
	                    Display_order)
	                SELECT
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    AJ.Report_ccid,
	                    null,
                        TH.Transaction_Type_Code,
                	    SUM (DECODE (AJ.Dr_Cr_Flag, l_Balance_Type, 1, -1) * AJ.Amount),
	                    l_data_source,
	                    l_display_order
	                FROM
	                    FA_DISTRIBUTION_HISTORY     DH,
	                    IGI_IAC_TRANSACTION_HEADERS TH,
	                    IGI_IAC_ADJUSTMENTS         AJ
	                WHERE
	                    DH.Book_Type_Code       = p_Distribution_Source_Book    AND
	                    AJ.Asset_ID             = DH.Asset_ID           AND
	                    AJ.Book_Type_Code       = p_Book                  AND
	                    AJ.Distribution_ID      = DH.Distribution_ID    AND
	                    AJ.Adjustment_Type      = l_account_type AND
	                    AJ.Period_Counter BETWEEN
	                                p_Period1_PC AND p_Period2_PC    AND
	                    AJ.transfer_to_gl_flag  <> 'N'              AND
	                    TH.adjustment_ID        = AJ.adjustment_ID    AND
                            TH.Transaction_type_code NOT IN ('PARTIAL RETIRE', 'FULL RETIREMENT', 'REINSTATEMENT') AND
 	                    AJ.adjustment_offset_type  = p_report_type
	                GROUP BY
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    AJ.report_ccid,
	                    TH.Transaction_Type_Code;

            END IF;

/*            IF l_account_type = 'BL RESERVE' THEN

	                INSERT INTO IGI_IAC_BALANCES_REPORT
	                    (Asset_ID,
	                    Distribution_CCID,
	                    Adjustment_CCID,
	                    Category_Books_Account,
	                    Source_Type_Code,
	                    Amount,
	                    Data_Source,
	                    Display_order)
	                SELECT
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    SUB_AJ.Code_Combination_ID,
	                    null,
                	    TH.Transaction_Type_Code,
	                    SUM (DECODE (AJ.Dr_Cr_Flag, l_Balance_Type, 1, -1) * AJ.Amount),
	                    l_data_source,
	                    l_display_order
	                FROM
	                    FA_DISTRIBUTION_HISTORY     DH,
	                    IGI_IAC_TRANSACTION_HEADERS TH,
	                    IGI_IAC_ADJUSTMENTS         AJ,
	                    IGI_IAC_ADJUSTMENTS         SUB_AJ
	                WHERE
	                    DH.Book_Type_Code       = p_Distribution_Source_Book    AND
	                    AJ.Asset_ID             = DH.Asset_ID           AND
	                    AJ.Book_Type_Code       = p_Book                  AND
	                    AJ.Distribution_ID      = DH.Distribution_ID    AND
	                    AJ.Adjustment_Type      = l_account_type AND
	                    AJ.Period_Counter BETWEEN
	                                p_Period1_PC AND p_Period2_PC    AND
	                    AJ.transfer_to_gl_flag  <> 'N'              AND
	                    TH.adjustment_ID        = AJ.adjustment_ID    AND
                        TH.Transaction_type_code NOT IN ('PARTIAL RETIRE', 'FULL RETIREMENT', 'REINSTATEMENT') AND
	                    AJ.adjustment_id        = SUB_AJ.adjustment_id AND
			    AJ.distribution_id	    = SUB_AJ.distribution_id AND
	                    SUB_AJ.adjustment_type  = p_report_type AND
	                    SUB_AJ.rowid            = (select min(x_aj.rowid)
	                                        FROM igi_iac_adjustments x_aj
	                                        WHERE x_aj.Book_Type_Code  = p_book
	                                        AND x_aj.adjustment_id = sub_aj.adjustment_id
						AND x_aj.distribution_id = sub_aj.distribution_id
	                                        AND x_aj.asset_id = sub_AJ.Asset_ID
	                                        AND x_aj.adjustment_type = p_report_type
                                            AND x_aj.amount = AJ.amount
                                            AND x_aj.adjustment_type <> AJ.adjustment_type)
	                GROUP BY
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    SUB_AJ.Code_Combination_ID,
	                    TH.Transaction_Type_Code;
		END IF;*/

                IF l_account_type = p_report_type THEN

	                INSERT INTO IGI_IAC_BALANCES_REPORT
	                    (Asset_ID,
	                    Distribution_CCID,
	                    Adjustment_CCID,
	                    Category_Books_Account,
	                    Source_Type_Code,
	                    Amount,
	                    Data_Source,
	                    Display_order)
	                SELECT
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    AJ.Code_Combination_ID,
	                    null,
                	    DECODE(TH.Transaction_Type_Code,'FULL RETIREMENT','RETIREMENT',
							    'PARTIAL RETIRE','RETIREMENT',
                                'REINSTATEMENT','RETIREMENT',
						 	    TH.Transaction_Type_Code),
	                    SUM (DECODE (AJ.Dr_Cr_Flag, l_Balance_Type, 1, -1) * AJ.Amount),
	                    l_data_source,
	                    l_display_order
	                FROM
	                    FA_DISTRIBUTION_HISTORY     DH,
	                    IGI_IAC_TRANSACTION_HEADERS TH,
	                    IGI_IAC_ADJUSTMENTS         AJ
	                WHERE
	                    DH.Book_Type_Code       = p_Distribution_Source_Book    AND
	                    AJ.Asset_ID             = DH.Asset_ID           AND
	                    AJ.Book_Type_Code       = p_Book                  AND
	                    AJ.Distribution_ID      = DH.Distribution_ID    AND
	                    AJ.Adjustment_Type      = l_account_type AND
	                    AJ.Period_Counter BETWEEN
	                                p_Period1_PC AND p_Period2_PC    AND
	                    AJ.transfer_to_gl_flag  <> 'N'              AND
	                    TH.adjustment_ID        = AJ.adjustment_ID
	                GROUP BY
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    AJ.Code_Combination_ID,
	                    TH.Transaction_Type_Code;
		END IF;
            END LOOP;

            -- 02-Jun-2003, mh start, update source type to retirement for all non general fund
            -- reinstatement trxs

            /* UPDATE igi_iac_balances_report
            SET source_type_code = 'RETIREMENT'
            WHERE source_type_code = 'REINSTATEMENT'
            AND data_source <> 'General Fund'; */

             -- mh end



/*            UPDATE igi_iac_balances_report BR
            SET adjustment_ccid = (SELECT adjustment_ccid
                                    FROM igi_iac_balances_report SUB_BR
                                    WHERE SUB_BR.asset_id = BR.asset_id AND
                                          SUB_BR.distribution_ccid = BR.distribution_ccid AND
                                          SUB_BR.display_order = DECODE(p_report_type,
                                                                        'REVAL RESERVE',4,
                                                                        'OP EXPENSE',3) AND
                                          SUB_BR.source_type_code NOT IN ('BEGIN','END'))
            WHERE BR.data_source IN ('Cost','Backlog','General Fund');
*/

        END IF;

        IF (p_report_type = 'RESERVE') THEN

            INSERT INTO IGI_IAC_BALANCES_REPORT
            	(Asset_id,
            	Distribution_CCID,
        	Adjustment_CCID,
            	Category_books_account,
            	Source_type_code,
            	Amount,
                Data_source,
                Display_order)
            SELECT
            	dh.asset_id,
            	dh.code_combination_id,
            	null,
            	CB.Deprn_Reserve_Acct,
            	'ADDITION',
            	sum(DD.DEPRN_RESERVE),
            	'FA',
            	1
            FROM
		FA_DISTRIBUTION_HISTORY DH,
        	FA_CATEGORY_BOOKS CB,
           	FA_ASSET_HISTORY AH,
        	FA_DEPRN_DETAIL DD
	    WHERE
		NOT EXISTS (SELECT ASSET_ID
                              FROM  IGI_IAC_BALANCES_REPORT
                              WHERE ASSET_ID = DH.ASSET_ID
                              AND   DISTRIBUTION_CCID = DH.CODE_COMBINATION_ID
                              AND   SOURCE_TYPE_CODE = 'ADDITION'
                              AND   DATA_SOURCE = 'FA')
                AND   DD.BOOK_TYPE_CODE = p_book
            	AND   (DD.PERIOD_COUNTER+1) BETWEEN
            		p_period1_pc AND p_period2_pc
            	AND   DD.DEPRN_SOURCE_CODE = 'B'
            	AND   DD.ASSET_ID = DH.ASSET_ID
            	AND   DD.DEPRN_RESERVE <> 0
            	AND   DD.DISTRIBUTION_ID = DH.DISTRIBUTION_ID
            	AND   DH.ASSET_ID = AH.ASSET_ID
            	AND   AH.DATE_EFFECTIVE <
        			NVL(DH.DATE_INEFFECTIVE, SYSDATE)
            	AND   NVL(DH.DATE_INEFFECTIVE,SYSDATE) <=
        			NVL(AH.DATE_INEFFECTIVE,SYSDATE)
            	AND   DD.BOOK_TYPE_CODE = CB.BOOK_TYPE_CODE
               	AND   AH.CATEGORY_ID = CB.CATEGORY_ID
           GROUP BY
            	Dh.ASSET_ID,
            	DH.CODE_COMBINATION_ID,
            	CB.DEPRN_RESERVE_ACCT;
        END IF;

   EXCEPTION
      WHEN others THEN
        debug_print('Error in Get_Adjustments :'||sqlerrm);
          NULL ;
   END;


PROCEDURE Get_Balance ( p_book               varchar2,
       p_distribution_source_book   varchar2,
       p_period_pc          number,
       p_earliest_pc        number,
       p_period_date        date,
       p_additions_date     date,
       p_earliest_date	    date,
       p_report_type        varchar2,
       p_balance_type       varchar2,
       p_begin_or_end       varchar2)
    IS
        l_account_type      varchar2(15);
   BEGIN
        debug_print('Parameters to Get_Balance');
        debug_print('Book :'|| p_book);
        debug_print('Distribution Source Book :'|| p_distribution_source_book);
        debug_print('p_period_pc :'||p_period_pc);
        debug_print('p_earliest_pc :'||p_earliest_pc);
        debug_print('p_period_date :'||p_period_date);
        debug_print('p_additions_date :'||p_additions_date);
	debug_print('p_earliest_date :'||p_earliest_date);
        debug_print('p_report_type :'||p_report_type);
        debug_print('p_balance_type :'||p_balance_type);
        debug_print('p_begin_or_end :'||p_begin_or_end);

        IF (p_report_type = 'COST' OR p_report_type = 'RESERVE') THEN
            INSERT INTO IGI_IAC_BALANCES_REPORT
               (Asset_ID,
                Distribution_CCID,
                Adjustment_CCID,
                Category_Books_Account,
                Source_Type_Code,
                Amount,
                Data_source,
                Display_order)
            SELECT  /*+ index(dd FA_DEPRN_DETAIL_U1) */
                DH.Asset_ID,
                DH.Code_Combination_ID,
                null,
                DECODE (p_Report_Type,
                        'COST', CB.Asset_Cost_Acct,
                        'RESERVE', CB.Deprn_Reserve_Acct,
                        'REVAL RESERVE', CB.Reval_Reserve_Acct),
                DECODE(p_Report_Type,
                        'RESERVE', DECODE(DD.Deprn_Source_Code,
                                        'D', p_Begin_or_End, 'ADDITION'),
                        'REVAL RESERVE',
                                    DECODE(DD.Deprn_Source_Code,
                                        'D', p_Begin_or_End, 'ADDITION'),
                        p_Begin_or_End),
                DECODE (p_Report_Type,
                    'COST', DD.Cost,
                    'OP EXPENSE', 0,
                    'RESERVE', DD.Deprn_Reserve,
                    'REVAL RESERVE', DD.Reval_Reserve),
    	        'FA',
    	        1
            FROM
                FA_DISTRIBUTION_HISTORY DH,
                FA_DEPRN_DETAIL         DD,
                FA_ASSET_HISTORY        AH,
                FA_CATEGORY_BOOKS       CB,
                FA_BOOKS                BK
            WHERE
                DH.Book_Type_Code       = p_Distribution_Source_Book AND
                DECODE(DD.Deprn_Source_Code, 'D', P_Period_Date,
                            p_Additions_Date) BETWEEN
                                 DH.Date_Effective AND
                                NVL(DH.Date_Ineffective, SYSDATE)    AND
                DD.Asset_ID             = DH.Asset_ID           AND
                DD.Book_Type_Code       = p_Book                  AND
                DD.Distribution_ID      = DH.Distribution_ID    AND
                DD.Period_Counter       <= p_Period_PC            AND
                DECODE(p_Begin_or_End,
                        'BEGIN', DD.Deprn_Source_Code, 'D') =
                            DD.Deprn_Source_Code AND
                DD.Period_Counter       =
                       (SELECT  MAX (SUB_DD.Period_Counter)
                        FROM    FA_DEPRN_DETAIL SUB_DD
                        WHERE   SUB_DD.Book_Type_Code   = p_Book                  AND
                                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                                DH.Distribution_ID      =  DD.Distribution_ID   AND
                                SUB_DD.Period_Counter   <= p_Period_PC) AND
                AH.Asset_ID             = DH.Asset_ID                   AND
                ((AH.Asset_Type         <> 'EXPENSED' AND
                        p_Report_Type IN ('COST', 'CIP COST')) OR
                     (AH.Asset_Type         = 'CAPITALIZED' AND
                        p_Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
                DECODE(DD.Deprn_Source_Code, 'D', P_Period_Date,
                            p_Additions_Date) BETWEEN
                            AH.Date_Effective AND
                            NVL(AH.Date_Ineffective, SYSDATE)    AND
                CB.Category_ID          = AH.Category_ID        AND
                CB.Book_Type_Code       = DD.book_type_code      AND
                BK.Book_Type_Code       = CB.book_type_code     AND
                BK.Asset_ID             = DD.Asset_ID   AND
                DECODE(DD.Deprn_Source_Code, 'D', P_period_Date,
                            p_Additions_Date) BETWEEN
                            BK.Date_Effective AND
                            NVL(BK.Date_Ineffective, SYSDATE) AND
                NVL(BK.Period_Counter_Fully_Retired, p_Period_PC+1)
                            > p_Earliest_PC    AND
                DECODE (p_Report_Type,
                    'COST', DECODE (AH.Asset_Type,
                                    'CAPITALIZED', CB.Asset_Cost_Acct,
                                    null),
                    'CIP COST',
                            DECODE (AH.Asset_Type,
                                    'CIP', CB.CIP_Cost_Acct,
                                    null),
                    'RESERVE', CB.Deprn_Reserve_Acct,
                    'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
        END IF;

        IF (p_report_type = 'COST' OR p_report_type = 'RESERVE' OR p_report_type = 'BL RESERVE') THEN

            INSERT INTO IGI_IAC_BALANCES_REPORT
               (Asset_ID,
                Distribution_CCID,
                Adjustment_CCID,
                Category_Books_Account,
                Source_Type_Code,
                Amount,
                Data_source,
                Display_order)
            SELECT
                DH.Asset_ID,
                DH.Code_Combination_ID,
                null,
                DECODE (p_Report_Type,
                        'COST', CB.Asset_Cost_Acct,
                        'RESERVE', CB.Deprn_Reserve_Acct,
			'BL RESERVE', ICB.Backlog_Deprn_Rsv_ccid,
                        'REVAL RESERVE', ICB.Reval_Rsv_ccid,
                        'OP EXPENSE',ICB.Operating_Expense_ccid),
                p_Begin_or_End,
                DECODE (p_Report_Type,
                        'COST', DD.adjustment_Cost,
                        'OP EXPENSE', DD.Operating_Acct_Net,
                        'RESERVE', DD.Deprn_Reserve,
			'BL RESERVE', DD.Deprn_Reserve_Backlog,
                        'REVAL RESERVE', DD.Reval_Reserve_Net),
           	   'IAC',
        	    2
            FROM
                FA_DISTRIBUTION_HISTORY DH,
                IGI_IAC_DET_BALANCES    DD,
                FA_ASSET_HISTORY        AH,
                FA_CATEGORY_BOOKS       CB,
        	IGI_IAC_CATEGORY_BOOKS  ICB,
                FA_BOOKS                BK,
                IGI_IAC_TRANSACTION_HEADERS ITH
            WHERE
                DH.Book_Type_Code       = p_Distribution_Source_Book AND
                DD.Asset_ID             = DH.Asset_ID               AND
                DD.Book_Type_Code       = p_Book                    AND
                DD.Distribution_ID      = DH.Distribution_ID        AND
                DD.Period_Counter       <= p_Period_PC              AND
                DD.adjustment_id        =
                                        (SELECT  MAX (SUB_TH.adjustment_id)
                                        FROM    IGI_IAC_TRANSACTION_HEADERS SUB_TH
                                        WHERE   SUB_TH.Book_Type_Code   = p_Book  AND
                                                SUB_TH.Asset_ID  = DH.Asset_ID    AND
                                                SUB_TH.Period_Counter   <= p_Period_PC AND
                                                SUB_TH.adjustment_status NOT IN ('PREVIEW','OBSOLETE'))     AND
                ITH.adjustment_id       = DD.adjustment_id      AND
                ITH.asset_id            = DD.asset_id           AND
                ITH.book_type_code      = DD.book_type_code     AND
                ITH.category_id         = AH.category_id        AND
                nvl(DD.Active_Flag,'Y') <> 'N'                  AND
                AH.Asset_ID             = DH.Asset_ID               AND
                ((AH.Asset_Type         <> 'EXPENSED' AND
                        p_Report_Type IN ('COST', 'OP EXPENSE')) OR
                 (AH.Asset_Type         = 'CAPITALIZED' AND
                        p_Report_Type IN ('RESERVE', 'REVAL RESERVE', 'BL RESERVE')))   AND
                CB.Category_ID          = AH.Category_ID            AND
                ICB.Category_ID	        = AH.Category_ID            AND
                p_period_date BETWEEN
                            AH.Date_Effective AND
                            NVL(AH.Date_Ineffective, SYSDATE) AND
                CB.Book_Type_Code       = DD.book_type_code         AND
                ICB.Book_Type_Code      = DD.book_type_code         AND
                BK.Book_Type_Code       = CB.book_type_code         AND
                BK.Asset_ID             = DD.Asset_ID               AND
                p_period_Date BETWEEN
                            BK.Date_Effective AND
                            NVL(BK.Date_Ineffective, SYSDATE) AND
                NVL(BK.Period_Counter_Fully_Retired, p_Period_PC+1)
                        > p_Earliest_PC                               AND
                DECODE (p_Report_Type,
                        'COST', DECODE (AH.Asset_Type,
                                        'CAPITALIZED', CB.Asset_Cost_Acct,
                                        null),
                        'RESERVE', CB.Deprn_Reserve_Acct,
			'BL RESERVE', ICB.Backlog_deprn_Rsv_ccid,
                        'REVAL RESERVE', ICB.Reval_Rsv_ccid,
                        'OP EXPENSE', ICB.Operating_Expense_ccid) is not null;
        END IF;

        IF (p_report_type = 'REVAL RESERVE') THEN

-- mh, 16/06/2003, OR p_report_type = 'OP EXPENSE') THEN - coomented because BEGIN and END balances are
-- no longer required for Op Expense reports

            FOR counter IN 1..4 LOOP
                IF (counter = 1) THEN
                    l_account_type := 'COST';
                ELSIF counter = 2 THEN
                    l_account_type := 'BACKLOG';
                ELSIF counter = 3 THEN
                    l_account_type := 'GENERAL FUND';
                ELSE
                    l_account_type := 'NET';
                END IF;

--   mh,16/06/2003   IF NOT (p_report_type = 'OP EXPENSE' AND l_account_type = 'GENERAL FUND') THEN

-- mh, 21/01/2004 bug 3377806    IF NOT l_account_type = 'GENERAL FUND' THEN

	                INSERT INTO IGI_IAC_BALANCES_REPORT
       		           (Asset_ID,
       	        	    Distribution_CCID,
	                    Adjustment_CCID,
	                    Category_Books_Account,
	                    Source_Type_Code,
	                    Amount,
	                    Data_source,
	                    Display_order)
	                SELECT
	                    DH.Asset_ID,
	                    DH.Code_Combination_ID,
	                    null,
	                    DECODE (p_Report_Type,
	                        'REVAL RESERVE', ICB.Reval_Rsv_ccid, /* Here ccid should be replaced by account */
	                        'OP EXPENSE',ICB.Operating_Expense_ccid), /* Here ccid should be replaced by account */
	                    p_Begin_or_End,
	                    DECODE (p_Report_Type,
	                        'OP EXPENSE',DECODE(l_account_type,
	                                                'COST',DD.Operating_Acct_Cost,
	                                                'BACKLOG',DD.Operating_Acct_Backlog,
	                                                'NET',DD.Operating_Acct_Net) ,
	                        'REVAL RESERVE', DECODE(l_account_type,
	                                                'COST',DD.Reval_Reserve_Cost,
	                                                'BACKLOG',DD.Reval_Reserve_Backlog,
	                                                'GENERAL FUND',DD.Reval_Reserve_Gen_Fund,
	                                                'NET',DD.Reval_Reserve_Net) ),
	                    DECODE (p_Report_Type,
	                        'OP EXPENSE',DECODE(l_account_type,
	                                                'COST','Cost',
	                                                'BACKLOG','Backlog',
	                                                'NET','Net') ,
	                        'REVAL RESERVE', DECODE(l_account_type,
	                                                'COST','Cost',
	                                                'BACKLOG','Backlog',
	                                                'GENERAL FUND','General Fund',
	                                                'NET','Net') ),
	                    DECODE (p_Report_Type,
	                        'OP EXPENSE',DECODE(l_account_type,
	                                                'COST',1,
	                                                'BACKLOG',2,
	                                                'NET',3) ,
	                        'REVAL RESERVE', DECODE(l_account_type,
	                                                'COST',1,
	                                                'BACKLOG',3,
	                                                'GENERAL FUND',2,
	                                                'NET',4) )
	                FROM
	                    FA_DISTRIBUTION_HISTORY DH,
	                    IGI_IAC_DET_BALANCES    DD,
	                    FA_ASSET_HISTORY        AH,
	                    FA_CATEGORY_BOOKS       CB,
	            	    IGI_IAC_CATEGORY_BOOKS  ICB,
	                    FA_BOOKS                BK,
	                    IGI_IAC_TRANSACTION_HEADERS ITH
	                WHERE
	                    DH.Book_Type_Code       = p_Distribution_Source_Book AND
	                    DD.Asset_ID             = DH.Asset_ID               AND
	                    DD.Book_Type_Code       = p_Book                    AND
	                    DD.Distribution_ID      = DH.Distribution_ID        AND
	                    DD.Period_Counter       <= p_Period_PC              AND
	                    DD.adjustment_id        =
	                                            (SELECT  MAX (SUB_TH.adjustment_id)
	                                            FROM    IGI_IAC_TRANSACTION_HEADERS SUB_TH
	                                            WHERE   SUB_TH.Book_Type_Code   = p_Book  AND
	                                                    SUB_TH.Asset_ID  = DH.Asset_ID    AND
	                                                    SUB_TH.Period_Counter   <= p_Period_PC AND
	                                                    SUB_TH.adjustment_status NOT IN ('PREVIEW','OBSOLETE'))     AND
	                    ITH.adjustment_id       = DD.adjustment_id      AND
	                    ITH.asset_id            = DD.asset_id           AND
	                    ITH.book_type_code      = DD.book_type_code     AND
	                    ITH.category_id         = AH.category_id        AND
	                    nvl(DD.Active_Flag,'Y') <> 'N'                  AND
	                    AH.Asset_ID             = DH.Asset_ID               AND
	                    ((AH.Asset_Type         <> 'EXPENSED' AND
	                            p_Report_Type IN ('COST', 'OP EXPENSE')) OR
	                     (AH.Asset_Type         = 'CAPITALIZED' AND
	                            p_Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
	                    CB.Category_ID          = AH.Category_ID            AND
	                    ICB.Category_ID	        = AH.Category_ID            AND
	                    p_Period_date BETWEEN
	                                AH.Date_Effective AND
	                                NVL(AH.Date_Ineffective, SYSDATE) AND
	                    CB.Book_Type_Code       = DD.book_type_code         AND
	                    ICB.Book_Type_Code      = DD.book_type_code         AND
	                    BK.Book_Type_Code       = CB.book_type_code         AND
	                    BK.Asset_ID             = DD.Asset_ID               AND
	                    p_Period_Date BETWEEN
	                                BK.Date_Effective AND
	                                NVL(BK.Date_Ineffective, SYSDATE) AND
	                    NVL(BK.Period_Counter_Fully_Retired, p_Period_PC+1)
	                            > p_Earliest_PC                               AND
	                    DECODE (p_Report_Type,
	                            'REVAL RESERVE', ICB.Reval_Rsv_ccid,
	                            'OP EXPENSE', ICB.Operating_Expense_ccid) is not null;

	/* mh, 16/06/2003	    IF (p_report_type = 'OP EXPENSE') THEN
		    -- This is required for getting the ending balance of inactive distributions
	            	INSERT INTO IGI_IAC_BALANCES_REPORT
       		           (Asset_ID,
       	        	    Distribution_CCID,
	                    Adjustment_CCID,
	                    Category_Books_Account,
	                    Source_Type_Code,
	                    Amount,
	                    Data_source,
	                    Display_order)
                    	SELECT
			    db.asset_id,
                            dh.code_combination_id,
                            NULL,
                            icb.operating_expense_ccid,
                            p_Begin_or_End,
                            DECODE(l_account_type,
            	                'COST',DB.Operating_Acct_Cost,
                   	            'BACKLOG',DB.Operating_Acct_Backlog,
            	                'NET',DB.Operating_Acct_Net) ,
                            DECODE(l_account_type,
	                            'COST','Cost',
            	                'BACKLOG','Backlog',
            	                'NET','Net'),
                            DECODE(l_account_type,
            	                'COST',1,
            	                'BACKLOG',2,
            	                'NET',3)
                    	FROM
			    igi_iac_det_balances db,
                            fa_distribution_history dh,
                            fa_asset_history ah,
                            igi_iac_category_books icb
                    	WHERE
			    dh.book_type_code = p_book AND
                            nvl(dh.date_ineffective, p_earliest_date-1) > p_earliest_date AND
                            dh.asset_id = ah.asset_id AND
                            nvl(dh.date_ineffective, SYSDATE) > ah.date_effective AND
                            nvl(dh.date_ineffective, SYSDATE) <= nvl(ah.date_ineffective, SYSDATE) AND
                            icb.book_type_code = p_book AND
                            icb.category_id = ah.category_id AND
                            db.distribution_id = dh.distribution_id AND
                            db.adjustment_id = (SELECT max(idb.adjustment_id)
                                            FROM igi_iac_det_balances idb
                                            WHERE idb.book_type_code = p_book AND
                                                  idb.asset_id = dh.asset_id AND
                                                  idb.distribution_id = db.distribution_id AND
                                                  idb.period_counter <= p_period_pc);
               	    END IF;   */

       --        END IF;

            END LOOP;
        END IF;

   EXCEPTION
      WHEN others THEN
        debug_print('Error in Get_Balance :'||sqlerrm);
          NULL ;
   END;


PROCEDURE Get_Deprn_Effects (
	p_book               varchar2,
        p_distribution_source_book   varchar2,
        p_period1_pc         number,
        p_period2_pc         number,
        p_report_type        varchar2,
        p_balance_type       varchar2)
    IS
  BEGIN

        INSERT INTO IGI_IAC_BALANCES_REPORT
		(Asset_ID,
        	Distribution_CCID,
        	Adjustment_CCID,
        	Category_Books_Account,
        	Source_Type_Code,
        	Amount,
            	Data_Source,
            	Display_Order)
        SELECT
        	DH.Asset_ID,
        	DH.Code_Combination_ID,
        	null,
        	DECODE (p_report_type,
        		'RESERVE', CB.Deprn_Reserve_Acct,
        		'REVAL RESERVE', CB.Reval_Reserve_Acct),
        	DECODE(DD.Deprn_Source_Code,
        		'D', 'DEPRECIATION', 'ADDITION'),
        	SUM (DECODE (p_report_type,
        		'RESERVE', DD.Deprn_Amount,
        		'REVAL RESERVE', -DD.Reval_Amortization)),
            	'FA',
            	1
        FROM
        	FA_CATEGORY_BOOKS	CB,
        	FA_DISTRIBUTION_HISTORY	DH,
        	FA_ASSET_HISTORY	AH,
        	FA_DEPRN_DETAIL		DD,
        	FA_DEPRN_PERIODS	DP
        WHERE
        	DH.Book_Type_Code	= p_Distribution_Source_Book   AND
        	AH.Asset_ID		= DH.Asset_ID		    AND
        	AH.Asset_Type		= 'CAPITALIZED'		AND
        	AH.Date_Effective <
        		nvl(DH.date_ineffective, sysdate)	AND
        	nvl(DH.date_ineffective, sysdate) <=
        		NVL(AH.Date_Ineffective, SYSDATE)   AND
        	CB.Category_ID		= AH.Category_ID	AND
        	CB.Book_Type_Code	= p_Book            AND
        	((DD.Deprn_Source_Code 	= 'B'
        		AND (DD.Period_Counter+1) < p_Period2_PC)	OR
            	 (DD.Deprn_Source_Code 	= 'D'))		AND
        	DD.Book_Type_Code||''	= p_Book		AND
        	DD.Asset_ID		= DH.Asset_ID		    AND
        	DD.Distribution_ID	= DH.Distribution_ID	AND
        	DD.Period_Counter between
        		p_Period1_PC and p_Period2_PC           AND
        	DP.Book_Type_Code	= DD.Book_Type_Code	AND
        	DP.Period_Counter	= DD.Period_Counter AND
        	DECODE (p_report_type,
        		'RESERVE', CB.Deprn_Reserve_Acct,
        		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null AND
        	DECODE (p_report_type,
        		'RESERVE', DD.Deprn_Amount,
        		'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0
        GROUP BY
        	DH.Asset_ID,
        	DH.Code_Combination_ID,
        	DECODE (p_report_type,
        		'RESERVE', CB.Deprn_Reserve_Acct,
        		'REVAL RESERVE', CB.Reval_Reserve_Acct),
        	DD.Deprn_Source_Code;

   EXCEPTION
      WHEN others THEN
        debug_print('Error in Get_Deprn_Effects :'||sqlerrm);
          NULL ;
   END;


PROCEDURE GET_GENERAL_FUND(
	p_book               varchar2,
        p_period1_pc         number,
        p_period2_pc         number,
        p_report_type        varchar2,
        p_balance_type       varchar2)
IS
    l_prev_adjustment_id    	igi_iac_transaction_headers.adjustment_id%TYPE;
    l_distribution_ccid 	fa_distribution_history.code_combination_id%TYPE;

    /* Cursor for fetching all retirement, reinstatement transactions */
    CURSOR c_get_transactions(cp_book fa_books.book_type_code%TYPE) IS
    SELECT  *
    FROM igi_iac_transaction_headers
    WHERE book_type_code = cp_book
    AND period_counter BETWEEN p_period1_pc AND p_period2_pc
    AND transaction_type_code IN ('PARTIAL RETIRE', 'FULL RETIREMENT', 'REINSTATEMENT');

    /* Cursor for fetching the transaction previous to retirement or reinstatement */
    CURSOR c_get_Prev_transaction(cp_book fa_books.book_type_code%TYPE,
                                    cp_asset_id igi_iac_transaction_headers.asset_id%TYPE,
                                    cp_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE) IS
    SELECT max(adjustment_id)
    FROM igi_iac_transaction_headers
    WHERE book_type_code = cp_book
    AND asset_id = cp_asset_id
    AND adjustment_id < cp_adjustment_id
    AND adjustment_status NOT IN ('PREVIEW','OBSOLETE');

    /* Cursor to fetch the general fund movement from previous transaction
       to current transaction for the distributions which exist in both
       transactions */
    CURSOR c_get_dists(cp_book fa_books.book_type_code%TYPE,
                        cp_asset_id igi_iac_transaction_headers.asset_id%TYPE,
                        cp_curr_adj_id igi_iac_transaction_headers.adjustment_id%TYPE,
                        cp_prev_adj_id igi_iac_transaction_headers.adjustment_id%TYPE) IS
    SELECT  curr_adj.distribution_id distribution_id,
            (curr_adj.reval_reserve_cost - prev_adj.reval_reserve_cost) reval_reserve_cost,
            (curr_adj.reval_reserve_backlog - prev_adj.reval_reserve_backlog) reval_reserve_backlog,
            (curr_adj.general_fund_acc - prev_adj.general_fund_acc) general_fund,
            (curr_adj.Operating_acct_cost - prev_adj.Operating_acct_cost) operating_acct_cost,
            (curr_adj.Operating_acct_backlog - prev_adj.Operating_acct_backlog) operating_acct_backlog
    FROM igi_iac_det_balances curr_adj,
         igi_iac_det_balances prev_adj
    WHERE curr_adj.book_type_code = cp_book
    AND curr_adj.asset_id = cp_asset_id
    AND prev_adj.book_type_code = cp_book
    AND prev_adj.asset_id = cp_asset_id
    AND curr_adj.adjustment_id = cp_curr_adj_id
    AND prev_adj.adjustment_id = cp_prev_adj_id
    AND curr_adj.distribution_id = prev_adj.distribution_id;

    /* Cursor to fetch the general fund movement from previous transaction
       to current transaction for the distributions which exist only in the
       latest transaction */
    CURSOR c_get_new_dists(cp_book fa_books.book_type_code%TYPE,
                        cp_asset_id igi_iac_transaction_headers.asset_id%TYPE,
                        cp_curr_adj_id igi_iac_transaction_headers.adjustment_id%TYPE,
                        cp_prev_adj_id igi_iac_transaction_headers.adjustment_id%TYPE) IS
    SELECT adj.distribution_id,
           adj.reval_reserve_cost reval_reserve_cost,
           adj.reval_reserve_backlog reval_reserve_backlog,
           adj.general_fund_acc general_fund,
           adj.operating_acct_cost operating_acct_cost,
           adj.operating_acct_backlog operating_acct_backlog
    FROM igi_iac_det_balances adj
    WHERE book_type_code = cp_book
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_curr_adj_id
    AND NOT EXISTS (SELECT 'X'
                    FROM igi_iac_det_balances sub_adj
                    WHERE sub_adj.book_type_code = cp_book
                    AND sub_adj.asset_id = cp_asset_id
                    AND sub_adj.adjustment_id = cp_prev_adj_id
                    AND sub_adj.distribution_id = adj.distribution_id);

    /* Cursor to fetch the general fund movement from previous transaction
       to current transaction for the distributions which exist only in the
       previous transaction */
    CURSOR c_get_old_dists(cp_book fa_books.book_type_code%TYPE,
                        cp_asset_id igi_iac_transaction_headers.asset_id%TYPE,
                        cp_curr_adj_id igi_iac_transaction_headers.adjustment_id%TYPE,
                        cp_prev_adj_id igi_iac_transaction_headers.adjustment_id%TYPE) IS
    SELECT adj.distribution_id,
           (adj.reval_reserve_cost * -1) reval_reserve_cost,
           (adj.reval_reserve_backlog * -1) reval_reserve_backlog,
           (adj.general_fund_acc * -1) general_fund,
           (adj.operating_acct_cost * -1) operating_acct_cost,
           (adj.operating_acct_backlog * -1) operating_acct_backlog
    FROM igi_iac_det_balances adj
    WHERE book_type_code = cp_book
    AND asset_id = cp_asset_id
    AND adjustment_id = cp_prev_adj_id
    AND NOT EXISTS (SELECT 'X'
                    FROM igi_iac_det_balances sub_adj
                    WHERE sub_adj.book_type_code = cp_book
                    AND sub_adj.asset_id = cp_asset_id
                    AND sub_adj.adjustment_id = cp_curr_adj_id
                    AND sub_adj.distribution_id = adj.distribution_id);

    /* Cursor to fetch the category for the asset */
    CURSOR c_get_category(cp_book fa_books.book_type_code%TYPE,
                            cp_asset_id fa_additions.asset_id%TYPE,
                            cp_transaction_id igi_iac_transaction_headers.transaction_header_id%TYPE) IS
    SELECT ah.category_id
    FROM    fa_asset_history ah,
            fa_transaction_headers th
    WHERE   ah.asset_id = cp_asset_id
    AND     th.transaction_header_id = cp_transaction_id
    AND     th.book_type_code = cp_book
    AND     th.asset_id = cp_asset_id
    AND     th.transaction_header_id BETWEEN
                    ah.transaction_header_id_in AND
                    NVL (ah.transaction_header_id_out - 1,
                            th.transaction_header_id);

    /* Cursor to fetch the revaluation reserve account for the book
       and the category */
    CURSOR c_get_account(cp_book fa_books.book_type_code%TYPE,
                         cp_category_id igi_iac_category_books.category_id%TYPE,
                         cp_report_type varchar2) IS
    SELECT DECODE(cp_report_type,'REVAL RESERVE', reval_rsv_ccid,
                                 'OP EXPENSE', operating_expense_ccid) adjustment_ccid
    FROM igi_iac_category_books
    WHERE   book_type_code = cp_book
    AND     category_id = cp_category_id;

    /* Cursor to fetch the distribution ccid for a distribution */
    CURSOR c_get_dist_ccid( cp_book fa_distribution_history.book_type_code%TYPE,
                            cp_asset_id fa_distribution_history.asset_id%TYPE,
                            cp_distribution_id fa_distribution_history.distribution_id%TYPE) IS
    SELECT code_combination_id
    FROM fa_distribution_history
    WHERE book_type_code = cp_book
    AND asset_id = cp_asset_id
    AND distribution_id = cp_distribution_id;

BEGIN
    Debug_Print('Starting of processing for retirements');
    FOR l_transaction IN c_get_transactions(p_book) LOOP
        Debug_print('Adjustment id :'||l_transaction.adjustment_id);
        OPEN c_get_prev_transaction(l_transaction.book_type_code,
                                    l_transaction.asset_id,
                                    l_transaction.adjustment_id);
        FETCH c_get_prev_transaction INTO l_prev_adjustment_id;
        CLOSE c_get_prev_transaction;
        Debug_Print('Previous Adjustment_id :'||l_prev_adjustment_id);
        /* Processing distributions existing in both transactions */
        Debug_Print('Before start of distributions in both transactions');
        FOR l_dist IN c_get_dists(l_transaction.book_type_code,
                         l_transaction.asset_id,
                         l_transaction.adjustment_id,
                         l_prev_adjustment_id) LOOP
            Debug_Print('Distribution_id :'||l_dist.distribution_id);
            Debug_Print('Reval Reserve Cost :'||l_dist.reval_reserve_cost);
            Debug_Print('Reval Reserve General Fund :'||l_dist.general_fund);
            Debug_Print('Reval Reserve Backlog :'||l_dist.reval_reserve_backlog);
            Debug_Print('Operating Acct Cost :'||l_dist.operating_acct_cost);
            Debug_Print('Operating Acct Backlog :'||l_dist.operating_acct_backlog);
            FOR l_category IN c_get_category(l_transaction.book_type_code,
                                l_transaction.asset_id,
                                l_transaction.transaction_header_id) LOOP
                Debug_Print('Category_id :'||l_category.category_id);
                FOR l_account IN c_get_account(l_transaction.book_type_code,
                                                l_category.category_id,
                                                p_report_type) LOOP
                    Debug_Print('Account CCID: '|| l_account.adjustment_ccid);
                    OPEN c_get_dist_ccid(l_transaction.book_type_code,
                                         l_transaction.asset_id,
                                         l_dist.distribution_id);
                    FETCH c_get_dist_ccid INTO l_distribution_ccid;
                    CLOSE c_get_dist_ccid;


                    IF (p_report_type = 'REVAL RESERVE') THEN
                        Debug_Print('Inserting Reval Reserve records');
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.general_fund,
                            'General Fund',
                            2);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_backlog,
                            'Backlog',
                            3);
                    END IF;

                    IF (p_report_type = 'OP EXPENSE') THEN
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_backlog,
                            'Backlog',
                            2);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;

        /* Processing the distributions existing only in latest transaction */
        debug_Print('Before start of distributions only in new transaction');
        FOR l_dist IN c_get_new_dists(l_transaction.book_type_code,
                         l_transaction.asset_id,
                         l_transaction.adjustment_id,
                         l_prev_adjustment_id) LOOP
            Debug_Print('Distribution_id :'||l_dist.distribution_id);
            Debug_Print('Reval Reserve Cost :'||l_dist.reval_reserve_cost);
            Debug_Print('Reval Reserve General Fund :'||l_dist.general_fund);
            Debug_Print('Reval Reserve Backlog :'||l_dist.reval_reserve_backlog);
            Debug_Print('Operating Acct Cost :'||l_dist.operating_acct_cost);
            Debug_Print('Operating Acct Backlog :'||l_dist.operating_acct_backlog);

            FOR l_category IN c_get_category(l_transaction.book_type_code,
                                l_transaction.asset_id,
                                l_transaction.transaction_header_id) LOOP

                FOR l_account IN c_get_account(l_transaction.book_type_code,
                                                l_category.category_id,
                                                p_report_type) LOOP
                    OPEN c_get_dist_ccid(l_transaction.book_type_code,
                                         l_transaction.asset_id,
                                         l_dist.distribution_id);
                    FETCH c_get_dist_ccid INTO l_distribution_ccid;
                    CLOSE c_get_dist_ccid;

                    IF (p_report_type = 'REVAL RESERVE') THEN
                        Debug_Print('Inserting Reval Reserve records');
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.general_fund,
                            'General Fund',
                            2);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_backlog,
                            'Backlog',
                            3);
                    END IF;

                    IF (p_report_type = 'OP EXPENSE') THEN
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_backlog,
                            'Backlog',
                            2);
                    END IF;

                END LOOP;
            END LOOP;
        END LOOP;

        Debug_Print('Before start of distributions only in previous transaction');
        /* Processing the distributions existing only in previous transaction */
        FOR l_dist IN c_get_old_dists(l_transaction.book_type_code,
                         l_transaction.asset_id,
                         l_transaction.adjustment_id,
                         l_prev_adjustment_id) LOOP
            Debug_Print('Distribution_id :'||l_dist.distribution_id);
            Debug_Print('Reval Reserve Cost :'||l_dist.reval_reserve_cost);
            Debug_Print('Reval Reserve General Fund :'||l_dist.general_fund);
            Debug_Print('Reval Reserve Backlog :'||l_dist.reval_reserve_backlog);
            Debug_Print('Operating Acct Cost :'||l_dist.operating_acct_cost);
            Debug_Print('Operating Acct Backlog :'||l_dist.operating_acct_backlog);

            FOR l_category IN c_get_category(l_transaction.book_type_code,
                                l_transaction.asset_id,
                                l_transaction.transaction_header_id) LOOP

                FOR l_account IN c_get_account(l_transaction.book_type_code,
                                                l_category.category_id,
                                                p_report_type) LOOP
                    OPEN c_get_dist_ccid(l_transaction.book_type_code,
                                         l_transaction.asset_id,
                                         l_dist.distribution_id);
                    FETCH c_get_dist_ccid INTO l_distribution_ccid;
                    CLOSE c_get_dist_ccid;

                    IF (p_report_type = 'REVAL RESERVE') THEN
                        Debug_Print('Inserting Reval Reserve records');
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.general_fund,
                            'General Fund',
                            2);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.reval_reserve_backlog,
                            'Backlog',
                            3);
                    END IF;

                    IF (p_report_type = 'OP EXPENSE') THEN
                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_cost,
                            'Cost',
                            1);

                        INSERT INTO IGI_IAC_BALANCES_REPORT
                            (Asset_ID,
                            Distribution_CCID,
                            Adjustment_CCID,
                            Category_Books_Account,
                            Source_Type_Code,
                            Amount,
                            Data_Source,
                            Display_order)
                        VALUES
                            (l_transaction.asset_id,
                            l_distribution_ccid,
                            l_account.adjustment_ccid,
                            NULL,
                            'RETIREMENT',
                            l_dist.operating_acct_backlog,
                            'Backlog',
                            2);
                    END IF;

                END LOOP;
            END LOOP;
        END LOOP;

    END LOOP;

END get_general_fund;


PROCEDURE Insert_info (
	p_book               varchar2,
        p_start_period_name  varchar2,
        p_end_period_name    varchar2,
        p_report_type        varchar2)    IS

	l_Period1_PC		number(15);
	l_Period1_POD		date;
	l_Period1_PCD		date;
	l_Period2_PC		number(15);
	l_Period2_PCD		date;
	l_Distribution_Source_Book  varchar2(15);
	l_balance_type		varchar2(3);
	l_rowid			rowid;
	l_chart_of_accounts_id  number;
	l_company 		varchar2(30);
	l_cost_ctr 		varchar2(30);
	l_account 		varchar2(30);
	l_appl_id		number;
	l_company_segment	number;
	l_account_segment	number;
	l_cc_segment		number;

        CURSOR c_get_balances IS
        SELECT rowid,ibr.*
	FROM igi_iac_balances_report ibr;

	PROCEDURE Get_Company_CostCtr(
				appl_short_name          IN  VARCHAR2,
                                key_flex_code            IN  VARCHAR2,
                                structure_number         IN  NUMBER,
                                combination_id           IN  NUMBER,
                                company_segment		 IN  NUMBER,
				cc_segment		 IN  NUMBER,
				company_value		 OUT NOCOPY VARCHAR2,
				cc_value		 OUT NOCOPY VARCHAR2) IS

	segment_count   NUMBER;
	segments        FND_FLEX_EXT.SegmentArray;
	segment_value   VARCHAR2(30);

  	BEGIN

		IF FND_FLEX_EXT.get_segments(appl_short_name, key_flex_code,
	              structure_number, combination_id, segment_count, segments)
	    	then
	        	company_value := segments(company_segment);
	        	cc_value := segments(cc_segment);
	    	END IF;


	    	EXCEPTION
	        	when NO_DATA_FOUND then
	        		--Debug_Print('Application short name not found.');
		        	company_value := NULL;
				cc_value := NULL;

		        when OTHERS then
		        	--Debug_Print('Error in procedure get_qulaified_segment');
		        	company_value := NULL;
				cc_value := NULL;

	END get_company_costctr;


	FUNCTION Get_account(
				appl_short_name          IN  VARCHAR2,
                                key_flex_code            IN  VARCHAR2,
                                structure_number         IN  NUMBER,
                                combination_id           IN  NUMBER,
                                account_segment		 IN  NUMBER)
	RETURN VARCHAR2 IS

	segment_count   NUMBER;
	segments        FND_FLEX_EXT.SegmentArray;
	segment_value   VARCHAR2(30);

  	BEGIN

		IF FND_FLEX_EXT.get_segments(appl_short_name, key_flex_code,
	              structure_number, combination_id, segment_count, segments)
	    	then
	        	segment_value := segments(account_segment);
	        	return(segment_value);
	    	END IF;
	    	return null;

	    	EXCEPTION
	        	when NO_DATA_FOUND then
	        		--Debug_Print('Application short name not found.');
		        	return NULL;

		        when OTHERS then
		        	--Debug_Print('Error in procedure get_qulaified_segment');
		        	return NULL;

	   END get_account;


   BEGIN
        Debug_Print('Inside Insert_Info');
    	SELECT
		    P1.Period_Counter,
		    P1.Period_Open_Date,
		    NVL(P1.Period_Close_Date, SYSDATE),
		    P2.Period_Counter,
		    NVL(P2.Period_Close_Date, SYSDATE),
		    BC.Distribution_Source_Book
    	INTO
		    l_Period1_PC,
		    l_Period1_POD,
		    l_Period1_PCD,
		    l_Period2_PC,
		    l_Period2_PCD,
		    l_Distribution_Source_Book
        FROM
		    FA_DEPRN_PERIODS P1,
		    FA_DEPRN_PERIODS P2,
		    FA_BOOK_CONTROLS BC
    	WHERE
		    BC.Book_Type_Code	= p_Book    AND
		    P1.Book_Type_Code	= p_Book    AND
		    P1.Period_Name	= p_Start_Period_Name    AND
		    P2.Book_Type_Code	= p_Book	AND
		    P2.Period_Name	= p_End_Period_Name;

        Debug_Print('Before assigning balance type');
         -- 02-Jun-2003, mh, add "OR p_report_type = 'OP EXPENSE'" to the statement below as part of
         -- reporting enhancement project

        IF (p_report_type = 'COST' OR p_report_type = 'OP EXPENSE') THEN
            l_balance_type  := 'DR';
        ELSE
            l_balance_type  := 'CR';
        END IF;

        Debug_Print('Before processing for Delete');
        DELETE FROM igi_iac_balances_report;

	Debug_Print('Before processing for beginning balances');
        Get_Balance(
            p_book              => p_book,
            p_distribution_source_book  => l_distribution_source_book,
            p_period_pc         => l_period1_pc - 1,
            p_earliest_pc       => l_period1_pc - 1,
            p_period_date       => l_period1_POD,
            p_additions_date    => l_period1_PCD,
	    p_earliest_date	=> l_period1_POD,
            p_report_type       => p_report_type,
            p_balance_type      => l_balance_type,
            p_begin_or_end      => 'BEGIN');

	Debug_Print('Before processing for ending balances');
        Get_Balance(
            p_book              => p_book,
            p_distribution_source_book  => l_distribution_source_book,
            p_period_pc         => l_period2_pc,
            p_earliest_pc       => l_period1_pc - 1,
            p_period_date       => l_period2_PCD,
            p_additions_date    => l_period2_PCD,
	    p_earliest_date	=> l_period1_POD,
            p_report_type       => p_report_type,
            p_balance_type      => l_balance_type,
            p_begin_or_end      => 'END');

	Debug_Print('Before processing for adjustments balances');
        Get_Adjustments(
            p_book              => p_book,
            p_distribution_source_book  => l_distribution_source_book,
            p_period1_pc        => l_period1_pc,
            p_period2_pc        => l_period2_pc,
            p_report_type       => p_report_type,
            p_balance_type      => l_balance_type);

	Debug_Print('Before processing for retirements');
    IF (p_report_type = 'REVAL RESERVE' OR p_report_type = 'OP EXPENSE') THEN
	    Get_General_Fund(
		p_book		=> p_book,
        	p_period1_pc	=> l_period1_pc,
        	p_period2_pc	=> l_period2_pc,
        	p_report_type 	=> p_report_type,
        	p_balance_type 	=> l_balance_type);
	END IF;

        IF (p_report_type = 'RESERVE') THEN

	    Debug_Print('Before processing for depreciation balances');
            Get_Deprn_Effects(
	            p_book              => p_book,
	            p_distribution_source_book  => l_distribution_source_book,
	            p_period1_pc        => l_period1_pc,
	            p_period2_pc        => l_period2_pc,
	            p_report_type       => p_report_type,
	            p_balance_type      => l_balance_type);

        END IF;

	DELETE FROM igi_iac_balances_report
	WHERE amount = 0;

        SELECT  SOB.Chart_of_Accounts_ID
        INTO    l_chart_of_accounts_id
        FROM    fa_book_controls        BC,
                gl_sets_of_books        SOB
        WHERE   BC.Book_Type_Code = p_book AND
		SOB.Set_Of_Books_ID = BC.Set_Of_Books_ID;

	SELECT application_id
	INTO l_appl_id FROM fnd_application
	WHERE application_short_name = 'SQLGL';

	IF (FND_FLEX_APIS.get_qualifier_segnum(l_appl_id, 'GL#',
	              l_chart_of_accounts_id, 'GL_BALANCING', l_company_segment))
	AND (FND_FLEX_APIS.get_qualifier_segnum(l_appl_id, 'GL#',
	              l_chart_of_accounts_id, 'GL_ACCOUNT', l_account_segment))
	AND (FND_FLEX_APIS.get_qualifier_segnum(l_appl_id, 'GL#',
	              l_chart_of_accounts_id, 'FA_COST_CTR', l_cc_segment)) THEN
		NULL;
	END IF;

        FOR l_balance IN c_get_balances LOOP

 		get_company_costctr(
                                            'SQLGL',
                                            'GL#',
                                            l_chart_of_accounts_id,
                                            l_balance.distribution_ccid,
                                            l_company_segment,
					    l_cc_segment,
					    l_company,
					    l_cost_ctr);

	    	IF p_report_type in ('COST','RESERVE') THEN

			if l_balance.category_books_account is not null then
		    		l_account := l_balance.category_books_account;
			else
		    		l_account :=  get_account(
                                                        	'SQLGL',
                                                        	'GL#',
                                                        	l_chart_of_accounts_id,
                                                        	l_balance.adjustment_ccid,
                                                        	l_account_segment);
			end if;

		END IF;

	      	IF p_report_type in ('REVAL RESERVE', 'OP EXPENSE', 'BL RESERVE') THEN

		  	l_account := get_account(
                                                        'SQLGL',
                                                        'GL#',
                                                        l_chart_of_accounts_id,
                                                        nvl(l_balance.adjustment_ccid,l_balance.category_books_account),
                                                        l_account_segment);

           	END IF;

		UPDATE igi_iac_balances_report
            	SET     company     = l_company,
                    	cost_center = l_cost_ctr,
                    	account     = l_account
            	WHERE rowid     = l_balance.rowid;

        END LOOP;

   EXCEPTION
      WHEN others THEN
          Debug_Print('Error in Insert Info :'||sqlerrm);
          NULL ;
   END Insert_Info;

  FUNCTION DO_INSERTFORMULA RETURN NUMBER IS
  BEGIN
    IF (P_REPORT_TYPE = 'REVAL RESERVE') THEN
      INSERT_INFO(P_BOOK
                 ,P_PERIOD1
                 ,P_PERIOD2
                 ,P_REPORT_TYPE);
      RETURN (1);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END DO_INSERTFORMULA;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2
                             ,CURRENCY_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID
        AND CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = 8400;
	l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
      RP_REPORT_NAME := L_REPORT_NAME || ' (' || CURRENCY_CODE || ')';
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        RP_REPORT_NAME := 'Inflation Accounting : Revaluation Reserve Summary Report';
        RETURN (RP_REPORT_NAME);
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION COST_BEGINNINGFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,BEGINNING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := BEGINNING;
    END IF;
    RETURN (L_NUM);
  END COST_BEGINNINGFORMULA;

  FUNCTION COST_ADDITIONFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,ADDITION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := ADDITION;
    END IF;
    RETURN (L_NUM);
  END COST_ADDITIONFORMULA;

  FUNCTION COST_DEPRECIATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                   ,DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  END COST_DEPRECIATIONFORMULA;

  FUNCTION COST_ADJUSTMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,ADJUSTMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := ADJUSTMENT;
    END IF;
    RETURN (L_NUM);
  END COST_ADJUSTMENTFORMULA;

  FUNCTION COST_RETIREMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,RETIREMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := RETIREMENT;
    END IF;
    RETURN (L_NUM);
  END COST_RETIREMENTFORMULA;

  FUNCTION COST_REVALUATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,REVALUATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := REVALUATION;
    END IF;
    RETURN (L_NUM);
  END COST_REVALUATIONFORMULA;

  FUNCTION COST_RECLASSFORMULA(BALANCE_TYPE IN VARCHAR2
                              ,RECLASS IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := RECLASS;
    END IF;
    RETURN (L_NUM);
  END COST_RECLASSFORMULA;

  FUNCTION COST_TRANSFERFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,TRANSFER IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := TRANSFER;
    END IF;
    RETURN (L_NUM);
  END COST_TRANSFERFORMULA;

  FUNCTION COST_ENDINGFORMULA(BALANCE_TYPE IN VARCHAR2
                             ,ENDING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Cost') THEN
      L_NUM := ENDING;
    END IF;
    RETURN (L_NUM);
  END COST_ENDINGFORMULA;

  FUNCTION GFUND_BEGINNINGFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,BEGINNING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := BEGINNING;
    END IF;
    RETURN (L_NUM);
  END GFUND_BEGINNINGFORMULA;

  FUNCTION GFUND_ADDITIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,ADDITION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := ADDITION;
    END IF;
    RETURN (L_NUM);
  END GFUND_ADDITIONFORMULA;

  FUNCTION GFUND_DEPRECIATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                    ,DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  END GFUND_DEPRECIATIONFORMULA;

  FUNCTION GFUND_ADJUSTMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,ADJUSTMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := ADJUSTMENT;
    END IF;
    RETURN (L_NUM);
  END GFUND_ADJUSTMENTFORMULA;

  FUNCTION GFUND_RETIREMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,RETIREMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := RETIREMENT;
    END IF;
    RETURN (L_NUM);
  END GFUND_RETIREMENTFORMULA;

  FUNCTION GFUND_REVALUATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                   ,REVALUATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := REVALUATION;
    END IF;
    RETURN (L_NUM);
  END GFUND_REVALUATIONFORMULA;

  FUNCTION GFUND_RECLASSFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,RECLASS IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := RECLASS;
    END IF;
    RETURN (L_NUM);
  END GFUND_RECLASSFORMULA;

  FUNCTION GFUND_TRANSFERFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,TRANSFER IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := TRANSFER;
    END IF;
    RETURN (L_NUM);
  END GFUND_TRANSFERFORMULA;

  FUNCTION GFUND_ENDINGFORMULA(BALANCE_TYPE IN VARCHAR2
                              ,ENDING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'General Fund') THEN
      L_NUM := ENDING;
    END IF;
    RETURN (L_NUM);
  END GFUND_ENDINGFORMULA;

  FUNCTION BLOG_BEGINNINGFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,BEGINNING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := BEGINNING;
    END IF;
    RETURN (L_NUM);
  END BLOG_BEGINNINGFORMULA;

  FUNCTION BLOG_ADDITIONFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,ADDITION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := ADDITION;
    END IF;
    RETURN (L_NUM);
  END BLOG_ADDITIONFORMULA;

  FUNCTION BLOG_DEPRECIATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                   ,DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  END BLOG_DEPRECIATIONFORMULA;

  FUNCTION BLOG_ADJUSTMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,ADJUSTMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := ADJUSTMENT;
    END IF;
    RETURN (L_NUM);
  END BLOG_ADJUSTMENTFORMULA;

  FUNCTION BLOG_RETIREMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,RETIREMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := RETIREMENT;
    END IF;
    RETURN (L_NUM);
  END BLOG_RETIREMENTFORMULA;

  FUNCTION BLOG_REVALUATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,REVALUATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := REVALUATION;
    END IF;
    RETURN (L_NUM);
  END BLOG_REVALUATIONFORMULA;

  FUNCTION BLOG_RECLASSFORMULA(BALANCE_TYPE IN VARCHAR2
                              ,RECLASS IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := RECLASS;
    END IF;
    RETURN (L_NUM);
  END BLOG_RECLASSFORMULA;

  FUNCTION BLOG_TRANSFERFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,TRANSFER IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := TRANSFER;
    END IF;
    RETURN (L_NUM);
  END BLOG_TRANSFERFORMULA;

  FUNCTION BLOG_ENDINGFORMULA(BALANCE_TYPE IN VARCHAR2
                             ,ENDING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Backlog') THEN
      L_NUM := ENDING;
    END IF;
    RETURN (L_NUM);
  END BLOG_ENDINGFORMULA;

  FUNCTION NET_BEGINNINGFORMULA(BALANCE_TYPE IN VARCHAR2
                               ,BEGINNING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := BEGINNING;
    END IF;
    RETURN (L_NUM);
  END NET_BEGINNINGFORMULA;

  FUNCTION NET_ADDITIONFORMULA(BALANCE_TYPE IN VARCHAR2
                              ,ADDITION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := ADDITION;
    END IF;
    RETURN (L_NUM);
  END NET_ADDITIONFORMULA;

  FUNCTION NET_DEPRECIATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                  ,DEPRECIATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := DEPRECIATION;
    END IF;
    RETURN (L_NUM);
  END NET_DEPRECIATIONFORMULA;

  FUNCTION NET_ADJUSTMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,ADJUSTMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := ADJUSTMENT;
    END IF;
    RETURN (L_NUM);
  END NET_ADJUSTMENTFORMULA;

  FUNCTION NET_RETIREMENTFORMULA(BALANCE_TYPE IN VARCHAR2
                                ,RETIREMENT IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := RETIREMENT;
    END IF;
    RETURN (L_NUM);
  END NET_RETIREMENTFORMULA;

  FUNCTION NET_REVALUATIONFORMULA(BALANCE_TYPE IN VARCHAR2
                                 ,REVALUATION IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := REVALUATION;
    END IF;
    RETURN (L_NUM);
  END NET_REVALUATIONFORMULA;

  FUNCTION NET_RECLASSFORMULA(BALANCE_TYPE IN VARCHAR2
                             ,RECLASS IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := RECLASS;
    END IF;
    RETURN (L_NUM);
  END NET_RECLASSFORMULA;

  FUNCTION NET_TRANSFERFORMULA(BALANCE_TYPE IN VARCHAR2
                              ,TRANSFER IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := TRANSFER;
    END IF;
    RETURN (L_NUM);
  END NET_TRANSFERFORMULA;

  FUNCTION NET_ENDINGFORMULA(BALANCE_TYPE IN VARCHAR2
                            ,ENDING IN NUMBER) RETURN NUMBER IS
    L_NUM NUMBER := 0;
  BEGIN
    IF (BALANCE_TYPE = 'Net') THEN
      L_NUM := ENDING;
    END IF;
    RETURN (L_NUM);
  END NET_ENDINGFORMULA;



  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_BAL_APROMPT;
  END ACCT_BAL_APROMPT_P;

  FUNCTION ACCT_CC_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_CC_APROMPT;
  END ACCT_CC_APROMPT_P;

  FUNCTION RP_BAL_LPROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_BAL_LPROMPT;
  END RP_BAL_LPROMPT_P;

  FUNCTION RP_CC_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CC_APROMPT;
  END RP_CC_APROMPT_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_CC_LPROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CC_LPROMPT;
  END RP_CC_LPROMPT_P;

END IGI_IGIIARRV_XMLP_PKG;

/
