--------------------------------------------------------
--  DDL for Package Body FA_BALREP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_BALREP_PKG" AS
/*$Header: fabalrepb.pls 120.1.12010000.9 2009/10/28 11:33:08 spooyath noship $*/
PROCEDURE LOAD_WORKERS
           (book_type_code  in  varchar2
	   ,request_id in  number
	   --,batch_size in  number
	   ,errbuf     out NOCOPY varchar2
	   ,retcode    out NOCOPY number
	   ) IS
    l_batch_size       number;
    p_total_requests   number;

    type char_tbl_type is table of varchar2(120) index by binary_integer;
    type num_tbl_type  is table of number(15)    index by binary_integer;

    l_rowid_tbl          char_tbl_type;
    l_worker_num_tbl     num_tbl_type;

  CURSOR c_workers(request_id_in number) IS
    SELECT rowid
    FROM  fa_worker_jobs
    WHERE request_id = request_id_in;

BEGIN
  fnd_profile.get('FA_NUM_PARALLEL_REQUESTS', p_total_requests);
  fnd_profile.get('FA_BATCH_SIZE', l_batch_size);
  l_batch_size  := nvl(l_batch_size, 1000);
  p_total_requests :=  nvl(p_total_requests,1);

     INSERT INTO FA_WORKER_JOBS
          ( START_RANGE
	  , END_RANGE
	  , WORKER_NUM
	  , STATUS,REQUEST_ID
	  )
           SELECT MIN(ASSET_ID)
           ,MAX(ASSET_ID)
           ,0
           ,'UNASSIGNED'
           , request_id
     FROM ( SELECT /*+ parallel(BK) */ ASSET_ID,
            FLOOR(RANK() OVER (ORDER BY ASSET_ID)/l_batch_size ) UNIT_ID
            FROM FA_BOOKS BK
            WHERE BK.BOOK_TYPE_CODE = book_type_code
            AND BK.transaction_header_id_out is null
          )
     GROUP BY UNIT_ID;


    OPEN c_workers(request_id);
    LOOP
       FETCH c_workers bulk collect
       INTO  l_rowid_tbl;

        if l_rowid_tbl.count = 0 then
           exit;
        end if;

        FOR i in 1..l_rowid_tbl.count
        LOOP
           l_worker_num_tbl(i) := mod(i, p_total_requests) + 1;

        END LOOP;

       FORALL i in 1..l_rowid_tbl.count
          UPDATE fa_worker_jobs
             set worker_num = l_worker_num_tbl(i)
          WHERE  rowid      = l_rowid_tbl(i);
     END LOOP;

     COMMIT; --ANUJ

     retcode := 1;
     Commit;
EXCEPTION
  when others then
    retcode := SQLCODE;
    errbuf := SQLERRM;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END LOAD_WORKERS;


PROCEDURE LAUNCH_WORKERS
      (
        Book         IN VARCHAR2,
        Report_Type  IN VARCHAR2,
        report_style IN VARCHAR2,
        l_Request_id IN NUMBER,
        Period1_PC   IN NUMBER,
        Period1_POD  IN DATE,
        Period1_PCD  IN DATE,
        Period2_PC   IN NUMBER,
        Period2_PCD  IN DATE,
        Distribution_Source_Book  IN VARCHAR2,
        p_total_requests1 IN NUMBER,
        l_errbuf     out NOCOPY varchar2,
        l_retcode    out NOCOPY number
       )
       IS
Child_request_id number;
BEGIN

FOR i IN 1..nvl(p_total_requests1,1) LOOP

                      Child_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                              'OFA',
                                              'RXFAPOGT',
                                               Null,
                                               Sysdate,
                                               FALSE,
                                               book,
                                               Report_Type, --'COST'
                                               report_style,
                                               l_Request_id,
                                               i,  --worker number
                                               Period1_PC,
                                               Period1_POD,
                                               Period1_PCD,
                                               Period2_PC,
                                               Period2_PCD,
                                               Distribution_Source_Book
                                               );

            IF (Child_request_id = 0) THEN
              rollback;
              --raise G_NO_CHILD_PROCESS;
            END IF;
            COMMIT;
      END LOOP;
END LAUNCH_WORKERS;

-- Bug 8902344 : Changed UNION to UNION ALL in all the inserts
procedure Get_Adjustments
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Start_range      IN NUMBER,
    End_Range        IN NUMBER,
    h_request_id     IN NUMBER)
  is
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
 begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

    if (h_set_of_books_id = -1)   then
       h_set_of_books_id := null;
    end if;

  exception
    when others then
      h_set_of_books_id := null;
  end;


  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
   select set_of_books_id
     into h_set_of_books_id
     from fa_book_controls
    where book_type_code = book;

    h_reporting_flag := 'P';
  end if;

  -- Fix for Bug #1892406.  Run only if CRL not installed.
  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then


     if (h_reporting_flag = 'R') then
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,
		request_id)
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),
			h_request_id
	    FROM
		FA_LOOKUPS              RT,
		FA_DISTRIBUTION_HISTORY DH,
		FA_TRANSACTION_HEADERS  TH,
		FA_ASSET_HISTORY        AH,
		FA_ADJUSTMENTS_MRC_V    AJ,
		FA_DEPRN_PERIODS        DP
	    WHERE
		RT.Lookup_Type          = 'REPORT TYPE' AND
		RT.Lookup_Code          = Report_Type
	    AND	DH.Book_Type_Code       = Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID             = DH.Asset_ID           AND
		AJ.Book_Type_Code       = Book                  AND
		AJ.Distribution_ID      = DH.Distribution_ID    AND
		AJ.Adjustment_Type      in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is not null
	    AND
		TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID             = DH.Asset_ID           AND
		((AH.Asset_Type         <> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
	    GROUP BY
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		AJ.Source_Type_Code
	    UNION ALL
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		lines.code_combination_id, --AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS              RT,
		FA_DISTRIBUTION_HISTORY DH,
		FA_TRANSACTION_HEADERS  TH,
		FA_ASSET_HISTORY        AH,
		FA_ADJUSTMENTS_MRC_V    AJ,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links
	    WHERE
		RT.Lookup_Type          = 'REPORT TYPE' AND
		RT.Lookup_Code          = Report_Type
	    AND	DH.Book_Type_Code       = Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID             = DH.Asset_ID           AND
		AJ.Book_Type_Code       = Book                  AND
		AJ.Distribution_ID      = DH.Distribution_ID    AND
		AJ.Adjustment_Type      in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is null
	    AND
		TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID             = DH.Asset_ID           AND
		((AH.Asset_Type         <> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
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

     else
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,
		request_id)
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),
			h_request_id
	    FROM
		FA_LOOKUPS              RT,
		FA_DISTRIBUTION_HISTORY DH,
		FA_TRANSACTION_HEADERS  TH,
		FA_ASSET_HISTORY        AH,
		FA_ADJUSTMENTS          AJ,
		FA_DEPRN_PERIODS        DP
	    WHERE
		RT.Lookup_Type          = 'REPORT TYPE' AND
		RT.Lookup_Code          = Report_Type
	    AND	DH.Book_Type_Code       = Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID             = DH.Asset_ID           AND
		AJ.Book_Type_Code       = Book                  AND
		AJ.Distribution_ID      = DH.Distribution_ID    AND
		AJ.Adjustment_Type      in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is not null
	    AND AJ.code_combination_id is not null -- suju
	    AND
		TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID             = DH.Asset_ID           AND
		((AH.Asset_Type         <> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type  in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
            GROUP BY
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		AJ.Source_Type_Code
	    UNION ALL
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		lines.code_combination_id, --AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS              RT,
		FA_DISTRIBUTION_HISTORY DH,
		FA_TRANSACTION_HEADERS  TH,
		FA_ASSET_HISTORY        AH,
		FA_ADJUSTMENTS          AJ,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links

	    WHERE
		RT.Lookup_Type          = 'REPORT TYPE' AND
		RT.Lookup_Code          = Report_Type
	    AND	DH.Book_Type_Code       = Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID             = DH.Asset_ID           AND
		AJ.Book_Type_Code       = Book                  AND
		AJ.Distribution_ID      = DH.Distribution_ID    AND
		AJ.Adjustment_Type      in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND (DP.xla_conversion_status is null or
	         AJ.code_combination_id is null) -- suju
	    AND
		TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID             = DH.Asset_ID           AND
		((AH.Asset_Type         <> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type  in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
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
     end if;

  -- Fix for Bug #1892406.  Run only if CRL installed.
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then

   if (h_reporting_flag = 'R') then
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,
		request_id)
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_DISTRIBUTION_HISTORY	DH,
		FA_TRANSACTION_HEADERS	TH,
		FA_ASSET_HISTORY	AH,
		FA_ADJUSTMENTS_MRC_V	AJ,
		FA_DEPRN_PERIODS        DP

	    WHERE
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND	DH.Book_Type_Code	= Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID		= DH.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Distribution_ID	= DH.Distribution_ID	AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is not null
	    AND
		TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID		= DH.Asset_ID		AND
		((AH.Asset_Type		<> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
		 -- start of cua
		       and not exists ( select 'x' from fa_books_mrc_v bks
						where bks.book_type_code = Book
						and   bks.asset_id = aj.asset_id
						and   bks.group_asset_id is not null
						and   bks.date_ineffective is not null )
		 -- end of cua
	   GROUP BY
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		AJ.Source_Type_Code
	   UNION ALL
	   SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		lines.code_combination_id, --AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_DISTRIBUTION_HISTORY	DH,
		FA_TRANSACTION_HEADERS	TH,
		FA_ASSET_HISTORY	AH,
		FA_ADJUSTMENTS_MRC_V	AJ,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links

	    WHERE
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND	DH.Book_Type_Code	= Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID		= DH.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Distribution_ID	= DH.Distribution_ID	AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is null
	    AND
		TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID		= DH.Asset_ID		AND
		((AH.Asset_Type		<> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
		 -- start of cua
		       and not exists ( select 'x' from fa_books_mrc_v bks
						where bks.book_type_code = Book
						and   bks.asset_id = aj.asset_id
						and   bks.group_asset_id is not null
						and   bks.date_ineffective is not null )
		 -- end of cua
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
	    and lines.application_id               = 140    GROUP BY
		DH.Asset_ID,
		DH.Code_Combination_ID,
		lines.code_combination_id, --AJ.Code_Combination_ID,
		AJ.Source_Type_Code;

   else
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,request_id)
	    SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_DISTRIBUTION_HISTORY	DH,
		FA_TRANSACTION_HEADERS	TH,
		FA_ASSET_HISTORY	AH,
		FA_ADJUSTMENTS   	AJ,
		FA_DEPRN_PERIODS        DP

	    WHERE
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND	DH.Book_Type_Code	= Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID		= DH.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Distribution_ID	= DH.Distribution_ID	AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is not null
	    AND
		TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID		= DH.Asset_ID		AND
		((AH.Asset_Type		<> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
		 -- start of cua
		       and not exists ( select 'x' from fa_books bks
						where bks.book_type_code = Book
						and   bks.asset_id = aj.asset_id
						and   bks.group_asset_id is not null
						and   bks.date_ineffective is not null )
		 -- end of cua
	   GROUP BY
		DH.Asset_ID,
		DH.Code_Combination_ID,
		AJ.Code_Combination_ID,
		AJ.Source_Type_Code
	   UNION ALL
	   SELECT
		DH.Asset_ID,
		DH.Code_Combination_ID,
		lines.code_combination_id, --AJ.Code_Combination_ID,
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_DISTRIBUTION_HISTORY	DH,
		FA_TRANSACTION_HEADERS	TH,
		FA_ASSET_HISTORY	AH,
		FA_ADJUSTMENTS   	AJ,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links

	    WHERE RT.Lookup_Type		= 'REPORT TYPE'
	    AND	RT.Lookup_Code		= Report_Type
	    AND	DH.Book_Type_Code	= Distribution_Source_Book
	    AND DH.Asset_id BETWEEN start_range AND end_range --Anuj
	    AND	AJ.Asset_ID		= DH.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Distribution_ID	= DH.Distribution_ID	AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
	    AND DP.Book_type_code   = AJ.Book_type_code
	    AND DP.Period_counter   =AJ.Period_Counter_created
	    AND DP.xla_conversion_status is null
	    AND
		TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
	    AND
		AH.Asset_ID		= DH.Asset_ID		AND
		((AH.Asset_Type		<> 'EXPENSED' AND
			Report_Type IN ('COST', 'CIP COST')) OR
		 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
			Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
		TH.Transaction_Header_ID BETWEEN
			AH.Transaction_Header_ID_In AND
			NVL (AH.Transaction_Header_ID_Out - 1,
				TH.Transaction_Header_ID)
	    AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0
		 -- start of cua
		       and not exists ( select 'x' from fa_books bks
						where bks.book_type_code = Book
						and   bks.asset_id = aj.asset_id
						and   bks.group_asset_id is not null
						and   bks.date_ineffective is not null )
		 -- end of cua
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

   end if;

  end if;

    IF REPORT_TYPE = 'RESERVE' then
     if (h_reporting_flag = 'R') then
	insert into fa_balances_reports_itf
	(Asset_id,
	Distribution_CCID,
	Adjustment_CCID,
	Category_books_account,
	Source_type_code,
	amount,
	request_id)
	SELECT
	dh.asset_id,
	dh.code_combination_id,
	null,
	CB.Deprn_Reserve_Acct,
	'ADDITION',
	sum(DD.DEPRN_RESERVE),h_request_id
	FROM FA_DISTRIBUTION_HISTORY DH,
	     FA_CATEGORY_BOOKS CB,
	     FA_ASSET_HISTORY AH,
	     FA_DEPRN_DETAIL_MRC_V DD
	WHERE NOT EXISTS (SELECT ASSET_ID
                          FROM  fa_balances_reports_itf
                          WHERE ASSET_ID = DH.ASSET_ID
                          AND   DISTRIBUTION_CCID = DH.CODE_COMBINATION_ID
                          AND   SOURCE_TYPE_CODE = 'ADDITION'
                          AND   REQUEST_ID = h_request_id)
        AND   DD.BOOK_TYPE_CODE = BOOK
	AND   DD.Asset_id BETWEEN start_range AND end_range --Anuj
	AND   (DD.PERIOD_COUNTER+1) BETWEEN
		PERIOD1_PC AND PERIOD2_PC
	AND   DD.DEPRN_SOURCE_CODE = 'B'
	AND   DD.ASSET_ID = DH.ASSET_ID
	AND   DD.DEPRN_RESERVE <> 0
	AND   DD.DISTRIBUTION_ID = DH.DISTRIBUTION_ID
	AND   DD.ASSET_ID = AH.ASSET_ID
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
      else
	insert into fa_balances_reports_itf
	(Asset_id,
	Distribution_CCID,
	Adjustment_CCID,
	Category_books_account,
	Source_type_code,
	amount,
	request_id)
	SELECT
	dh.asset_id,
	dh.code_combination_id,
	null,
	CB.Deprn_Reserve_Acct,
	'ADDITION',
	sum(nvl(DD.DEPRN_RESERVE, 0)),h_request_id
	FROM FA_DISTRIBUTION_HISTORY DH,
	     FA_CATEGORY_BOOKS CB,
	     FA_ASSET_HISTORY AH,
             FA_BOOK_CONTROLS BC,
	     FA_DEPRN_DETAIL DD
	WHERE NOT EXISTS (SELECT ASSET_ID
                          FROM  fa_balances_reports_itf
                          WHERE ASSET_ID = DH.ASSET_ID
                          AND   DISTRIBUTION_CCID = DH.CODE_COMBINATION_ID
                          AND   SOURCE_TYPE_CODE = 'ADDITION'
                          AND   REQUEST_ID = h_request_id)
        AND   DD.BOOK_TYPE_CODE = BOOK
        AND   BC.BOOK_TYPE_CODE = BOOK
	AND   DD.Asset_id BETWEEN start_range AND end_range --Anuj
	AND   (DD.PERIOD_COUNTER+1) BETWEEN
		PERIOD1_PC AND PERIOD2_PC
	AND   DD.DEPRN_SOURCE_CODE = 'B'
	AND   DD.ASSET_ID = DH.ASSET_ID
        AND   BC.DISTRIBUTION_SOURCE_BOOK = DH.BOOK_TYPE_CODE
	AND   DD.DEPRN_RESERVE <> 0
	AND   DD.DISTRIBUTION_ID = DH.DISTRIBUTION_ID
	AND   DD.ASSET_ID = AH.ASSET_ID
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
      end if;

    end if;

  end Get_Adjustments;

-- Bug 8902344 : Changed UNION to UNION ALL in all the inserts
PROCEDURE get_adjustments_for_group
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Start_range              IN NUMBER,
    End_Range                IN NUMBER,
    h_request_id in number)
  is
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

    if (h_set_of_books_id = -1) then
       h_set_of_books_id := null;
    end if;

  exception
    when others then
      h_set_of_books_id := null;
  end;

  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
   select set_of_books_id
     into h_set_of_books_id
     from fa_book_controls
    where book_type_code = book;

    h_reporting_flag := 'P';
  end if;

  -- run only if CRL installed
  if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

   if (h_reporting_flag = 'R') then
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,request_id)
	    SELECT
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,AJ.Code_Combination_ID ),
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_ADJUSTMENTS_MRC_V	AJ,
		fa_books_mrc_v          bk,
		fa_group_asset_default  gad,
		FA_DEPRN_PERIODS        DP
	    WHERE
		bk.asset_id = aj.asset_id
		and bk.book_type_code = book
		and bk.group_asset_id = gad.group_asset_id
		and bk.book_type_code = gad.book_type_code
		and bk.date_ineffective is null
		and aj.asset_id in (select asset_id from fa_books_mrc_v
				 where group_asset_id is not null
				      and date_ineffective is null)
	     and
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND	AJ.Asset_ID		= BK.Asset_ID
	    AND aj.asset_id  BETWEEN start_range and End_range  --anuj
	    AND	AJ.Book_Type_Code	= Book
	    AND	AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC

		AND DP.Book_type_code   = AJ.Book_type_code
	        AND DP.Period_counter   = AJ.Period_Counter_created
	        AND DP.xla_conversion_status is not null
		AND (DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0

	    GROUP BY
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,AJ.Code_Combination_ID ),
		aJ.Source_Type_Code
	   UNION ALL
	   SELECT
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_ADJUSTMENTS_MRC_V	AJ,
		fa_books_mrc_v          bk,
		fa_group_asset_default  gad,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links
	    WHERE
		bk.asset_id = aj.asset_id
		and bk.book_type_code = book
		and bk.group_asset_id = gad.group_asset_id
		and bk.book_type_code = gad.book_type_code
		and bk.date_ineffective is null
		AND aj.asset_id  BETWEEN start_range and End_range  --anuj
		and aj.asset_id in (select asset_id from fa_books_mrc_v
				 where group_asset_id is not null
				      and date_ineffective is null)
	     and
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND
		AJ.Asset_ID		= BK.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC

		AND DP.Book_type_code   = AJ.Book_type_code
	        AND DP.Period_counter   = AJ.Period_Counter_created
	        AND DP.xla_conversion_status is null
		AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
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
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
		aJ.Source_Type_Code;
   else
            /* Bug 7498880: Added new query for upgraded periods */
	    INSERT INTO fa_balances_reports_itf
	       (Asset_ID,
		Distribution_CCID,
		Adjustment_CCID,
		Category_Books_Account,
		Source_Type_Code,
		Amount,request_id)
	    SELECT
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,AJ.Code_Combination_ID ),
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_ADJUSTMENTS		AJ,
		fa_books                bk,
		fa_group_asset_default  gad,
		FA_DEPRN_PERIODS        DP

	    WHERE
		bk.asset_id = aj.asset_id
		and bk.book_type_code = book
		AND aj.asset_id  BETWEEN start_range and End_range  --anuj
		and bk.group_asset_id = gad.group_asset_id
		and bk.book_type_code = gad.book_type_code
		and bk.date_ineffective is null
		and aj.asset_id in (select asset_id from fa_books
				 where group_asset_id is not null
				      and date_ineffective is null)
	     and
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND
		AJ.Asset_ID		= BK.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
		AND DP.Book_type_code   = AJ.Book_type_code
	        AND DP.Period_counter   = AJ.Period_Counter_created
	        AND DP.xla_conversion_status is not null
		AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
			AJ.Adjustment_Amount) <> 0

	    GROUP BY
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID, AJ.Code_Combination_ID ),
		aJ.Source_Type_Code
	    UNION ALL
	    SELECT
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
		null,
		AJ.Source_Type_Code,
		SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
			AJ.Adjustment_Amount),h_request_id
	    FROM
		FA_LOOKUPS		RT,
		FA_ADJUSTMENTS		AJ,
		fa_books                bk,
		fa_group_asset_default  gad,
		FA_DEPRN_PERIODS        DP

		/* SLA Changes */
		,xla_ae_headers headers
		,xla_ae_lines lines
		,xla_distribution_links links
	    WHERE
		bk.asset_id = aj.asset_id
		and bk.book_type_code = book
		AND aj.asset_id  BETWEEN start_range and End_range  --anuj
		and bk.group_asset_id = gad.group_asset_id
		and bk.book_type_code = gad.book_type_code
		and bk.date_ineffective is null
		and aj.asset_id in (select asset_id from fa_books
				 where group_asset_id is not null
				      and date_ineffective is null)
	     and
		RT.Lookup_Type		= 'REPORT TYPE' AND
		RT.Lookup_Code		= Report_Type
	    AND
		AJ.Asset_ID		= BK.Asset_ID		AND
		AJ.Book_Type_Code	= Book			AND
		AJ.Adjustment_Type	in
			(Report_Type, DECODE(Report_Type,
				'REVAL RESERVE', 'REVAL AMORT')) AND
		AJ.Period_Counter_Created BETWEEN
				Period1_PC AND Period2_PC
		AND DP.Book_type_code   = AJ.Book_type_code
	        AND DP.Period_counter   = AJ.Period_Counter_created
	        AND DP.xla_conversion_status is null
		AND
		(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
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
		AJ.Asset_ID,
		-- Changed for BMA1
		-- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
		GAD.DEPRN_EXPENSE_ACCT_CCID,
		decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id  /* AJ.Code_Combination_ID*/ ),
		aJ.Source_Type_Code;
    end if;


   end if;

  end Get_Adjustments_for_group;


procedure Get_Balance
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2,
    Start_Range      IN NUMBER,
    End_Range        IN NUMBER,
    h_request_id     IN NUMBER
    )
  is
     P_Date date := Period_Date;
     A_Date date := Additions_Date;
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

  exception
    when others then
      h_set_of_books_id := null;
  end;

  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
    h_reporting_flag := 'P';
  end if;


  -- Fix for Bug #1892406.  Run only if CRL not installed.
  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then

   if (h_reporting_flag = 'R') then

    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount,
	request_id)
    SELECT
        DH.Asset_ID,
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
        DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
		,h_request_id
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS_MRC_V          BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
    AND
        DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC
	AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	AND DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                    DECODE(Begin_or_End,
                                   'BEGIN', DD.Deprn_Source_Code, 'D')) =
                              DD.Deprn_Source_Code AND
/*        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND */
        -- End bug fix 5076193
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL_MRC_V SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DD.Asset_ID                   AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type in ('CAPITALIZED','CIP') AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
   else
-- split for 'COST','CIP COST' and 'RESERVE','REVAL RESERVE' for better performance.

      if report_type in ('COST', 'CIP COST') then
    	INSERT INTO fa_balances_reports_itf
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount,
	request_id)
    	SELECT
           DH.Asset_ID,
       	   DH.Code_Combination_ID,
       	   null,
           DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
           DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
           DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
           DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
		,h_request_id
    FROM
        FA_DEPRN_DETAIL         DD,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
    AND
        DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC
	AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	AND DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	       DECODE(Begin_or_End,
                      'BEGIN', DD.Deprn_Source_Code, 'D')) =
                     DD.Deprn_Source_Code AND
/*        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND  */
        -- End bug fix 5076193
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DD.Asset_ID                   AND
        AH.Asset_Type         <> 'EXPENSED'
    AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      else -- report_type in ('RESERVE','REVAL RESERVE')

        /* Bug 6998035 */
    	INSERT INTO fa_balances_reports_itf
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount,
	request_id)
    	SELECT
           DH.Asset_ID,
       	   DH.Code_Combination_ID,
       	   null,
           DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
           DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
           DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
           DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve),
		h_request_id
    FROM
        FA_DEPRN_DETAIL         DD,
        FA_DISTRIBUTION_HISTORY DH,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
        AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
        AND DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC            AND
        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DD.Asset_ID                   AND
        AH.Asset_Type        in ( 'CAPITALIZED' ,'CIP') 	 AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;

      end if;

   end if;

  -- Fix for Bug #1892406.  Run only if CRL installed.
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then

   if (h_reporting_flag = 'R') then
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (Report_Type,
		'COST', CB.Asset_Cost_Acct,
		'CIP COST', CB.CIP_Cost_Acct,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
		'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),
		h_request_id
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS_MRC_V          BK
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                  DECODE(Begin_or_End,
		                  'BEGIN', DD.Deprn_Source_Code, 'D')) =
			        DD.Deprn_Source_Code AND
/*	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND  */
        -- end bug fix 5076193
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
                DH.Distribution_ID      = DD.Distribution_ID   AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DD.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
	BK.Asset_ID		= DD.Asset_ID	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		BK.Date_Effective AND
			NVL(BK.Date_Ineffective, SYSDATE) AND
	NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
		> Earliest_PC
    AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
        -- start of CUA - This is to exclude the Group Asset Members
                and bk.GROUP_ASSET_ID IS NULL;
   else
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (Report_Type,
		'COST', CB.Asset_Cost_Acct,
		'CIP COST', CB.CIP_Cost_Acct,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
		'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),
		h_request_id
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
       AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
       AND DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                   DECODE(Begin_or_End,
		                  'BEGIN', DD.Deprn_Source_Code, 'D')) =
			         DD.Deprn_Source_Code AND
/*	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND  */
-- End bug fix 5076193
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
                DH.Distribution_ID      = DD.Distribution_ID   AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DD.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
	BK.Asset_ID		= DD.Asset_ID	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		BK.Date_Effective AND
			NVL(BK.Date_Ineffective, SYSDATE) AND
	NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
		> Earliest_PC
    AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
        -- start of CUA - This is to exclude the Group Asset Members
                and bk.GROUP_ASSET_ID IS NULL;
   end if;
        -- end of cua

  commit;
  end if;
  end Get_Balance;


procedure get_balance_group_begin
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2,
    Start_Range              IN NUMBER,
    End_range                IN NUMBER,
    h_request_id             number
    )
  is
    P_Date date := Period_Date;
    A_Date date := Additions_Date;
    h_set_of_books_id  number;
    h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

  exception
    when others then
      h_set_of_books_id := null;
  end;

  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
    h_reporting_flag := 'P';
  end if;


      -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

    if ( report_type not in ('RESERVE') ) THEN
     if (h_reporting_flag = 'R') then
      INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
      SELECT
	DH.Asset_ID,
      --DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
	-- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
        null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
-- Commented by Prabakar
		'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
-- 	        'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),
		h_request_id
    FROM
	FA_BOOKS_MRC_V		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V	DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
    WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
     and
-- This is to include only the Group Asset Members
        bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DD.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups_mrc_v bg, fa_books_mrc_v fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
     else
      INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
      SELECT
	DH.Asset_ID,
      --DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
	-- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
        null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
-- Commented by Prabakar
		'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
-- 	        'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),
		h_request_id
    FROM
	FA_BOOKS		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
    WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
     and
-- This is to include only the Group Asset Members
        bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DD.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups bg, fa_books fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      end if;
ELSE

-- Get the Depreciation reserve begin balance

   if (h_reporting_flag = 'R') then
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
    SELECT
        GAR.GROUP_ASSET_ID						ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
        */
        'BEGIN',
        DD.DEPRN_RESERVE,
	h_request_id
    FROM
        FA_DEPRN_SUMMARY_MRC_V  DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
WHERE
        DD.BOOK_TYPE_CODE               = book
  AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
  AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
  AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
  AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
  AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
  AND      DD.PERIOD_COUNTER               =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
        AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
  else
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,request_id)
    SELECT
        GAR.GROUP_ASSET_ID						ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
        */
        'BEGIN',
        DD.DEPRN_RESERVE,h_request_id
    FROM
        FA_DEPRN_SUMMARY         DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
WHERE
        DD.BOOK_TYPE_CODE               = book
   AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
   AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
   AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
   AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
   AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
   AND      DD.PERIOD_COUNTER               =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
        AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
  end if;
--NULL;
END IF;

  end if;  --end of CRL check
  end get_balance_group_begin;


procedure get_balance_group_end
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2,
    Start_Range              IN NUMBER,
    End_range                IN NUMBER,
    h_request_id         in NUMBER)
  is
    P_Date date := Period_Date;
    A_Date date := Additions_Date;
    h_set_of_books_id  number;
    h_reporting_flag   varchar2(1);
 begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

  exception
    when others then
      h_set_of_books_id := null;
  end;

  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
    h_reporting_flag := 'P';
  end if;

   -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

    IF REPORT_TYPE NOT IN ('RESERVE') THEN
     if (h_reporting_flag = 'R') then
      INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
      SELECT
	DH.Asset_ID,
	-- DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
        -- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
	null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
                'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),h_request_id
      FROM
	FA_BOOKS_MRC_V		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V   DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
      WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
    -- This is to include only the Group Asset Members
    and   bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID	AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC
	AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
	AND DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
        AND
	AH.Asset_ID		= DD.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups_mrc_v bg, fa_books_mrc_v fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc  + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
     else
      INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,request_id)
      SELECT
	DH.Asset_ID,
	-- DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
        -- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
	null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
                'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve),h_request_id
      FROM
	FA_BOOKS		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
      WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
    -- This is to include only the Group Asset Members
    and   bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND
	DD.Asset_ID		= DH.Asset_ID	AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
        AND
	AH.Asset_ID		= DD.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups bg, fa_books fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc  + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      end if;

ELSE

 if (h_reporting_flag = 'R') then
  INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,request_id)
    SELECT
        GAR.GROUP_ASSET_ID	ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),*/
        'END',
        DD.DEPRN_RESERVE,h_request_id
    FROM
        FA_DEPRN_SUMMARY_MRC_V  DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
    WHERE
        DD.BOOK_TYPE_CODE               = book
     AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
     AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
     AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
     AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
     AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
     AND      DD.PERIOD_COUNTER               =
                  (SELECT  max (DD_SUB.PERIOD_COUNTER)
                   FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
                   WHERE   DD_SUB.BOOK_TYPE_CODE   = book
                   AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
                   AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
 else
  INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,request_id)
    SELECT
        GAR.GROUP_ASSET_ID	ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),*/
        'END',
        DD.DEPRN_RESERVE,h_request_id
    FROM
        FA_DEPRN_SUMMARY         DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
    WHERE
        DD.BOOK_TYPE_CODE               = book
     AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
     AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
     AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
     AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
     AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
     AND      DD.PERIOD_COUNTER               =
                  (SELECT  max (DD_SUB.PERIOD_COUNTER)
                   FROM    FA_DEPRN_DETAIL DD_SUB
                   WHERE   DD_SUB.BOOK_TYPE_CODE   = book
                   AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
                   AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
   end if;
  END IF;

  end if;  -- end of CRL check
  end get_balance_group_end;


procedure Get_Deprn_Effects
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Start_Range              IN NUMBER,
    End_Range                IN NUMBER,
    h_request_id   in number)
  is
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

  exception
    when others then
      h_set_of_books_id := null;
  end;

  if (h_set_of_books_id is not null) then
    if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => h_set_of_books_id,
            X_mrc_sob_type_code => h_reporting_flag) then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
  else
    h_reporting_flag := 'P';
  end if;

   if (h_reporting_flag = 'R') then
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,
	request_id)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(DD.Deprn_Source_Code,
		'D', 'DEPRECIATION', 'ADDITION'),
	SUM (DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount - decode(ADJ.debit_credit_flag,'DR',1,-1)
                                              * nvl(ADJ.adjustment_amount,0),
		'REVAL RESERVE', -DD.Reval_Amortization)),h_request_id
    FROM
	FA_LOOKUPS_B		RT,
	FA_CATEGORY_BOOKS	CB,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V	DD,
	FA_DEPRN_PERIODS_MRC_V	DP,
        FA_ADJUSTMENTS_MRC_V    ADJ
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AH.Asset_ID		= DD.Asset_ID		AND
	AH.Asset_Type	 in ( 'CAPITALIZED' ,'CIP')		AND
	AH.Date_Effective <
		nvl(DH.date_ineffective, sysdate)	AND
	nvl(DH.date_ineffective, sysdate) <=
		NVL(AH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
	((DD.Deprn_Source_Code 	= 'B'
		AND (DD.Period_Counter+1) < Period2_PC)	OR
	 (DD.Deprn_Source_Code 	= 'D'))			AND
	DD.Book_Type_Code||''	= Book			AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter between
		Period1_PC and Period2_PC
    AND
	DP.Book_Type_Code	= DD.Book_Type_Code	AND
	DP.Period_Counter	= DD.Period_Counter
    AND
	RT.Lookup_Type 		= 'REPORT TYPE'	AND
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
    AND
	(DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount,
		'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0 OR
         DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount - nvl(DD.deprn_adjustment_amount,0),
                'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0)
    AND ADJ.asset_id(+) = DD.asset_id AND
        ADJ.book_type_code(+) = DD.book_type_code AND
        ADJ.period_counter_created(+) = DD.period_counter AND
        ADJ.distribution_id(+) = DD.distribution_id AND
        ADJ.source_type_code(+) = 'REVALUATION' AND
        ADJ.adjustment_type(+) = 'EXPENSE' AND
        ADJ.adjustment_amount(+) <> 0
    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DD.Deprn_Source_Code;
   else
    INSERT INTO fa_balances_reports_itf
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount,request_id)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(DD.Deprn_Source_Code,
		'D', 'DEPRECIATION', 'ADDITION'),
	SUM (DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount - decode(ADJ.debit_credit_flag,'DR',1,-1)
                                              * nvl(ADJ.adjustment_amount,0),
		'REVAL RESERVE', -DD.Reval_Amortization)),h_request_id
    FROM
	FA_LOOKUPS_B		RT,
	FA_CATEGORY_BOOKS	CB,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DEPRN_PERIODS	DP,
        FA_ADJUSTMENTS          ADJ
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AH.Asset_ID		= DD.Asset_ID		AND
	AH.Asset_Type	 in ( 'CAPITALIZED','CIP')		AND
	AH.Date_Effective <
		nvl(DH.date_ineffective, sysdate)	AND
	nvl(DH.date_ineffective, sysdate) <=
		NVL(AH.Date_Ineffective, SYSDATE)
    AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
	((DD.Deprn_Source_Code 	= 'B'
		AND (DD.Period_Counter+1) < Period2_PC)	OR
	 (DD.Deprn_Source_Code 	= 'D'))			AND
	DD.Book_Type_Code||''	= Book			AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter between
		Period1_PC and Period2_PC
    AND
	DP.Book_Type_Code	= DD.Book_Type_Code	AND
	DP.Period_Counter	= DD.Period_Counter
    AND
	RT.Lookup_Type 		= 'REPORT TYPE'	AND
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
    AND
	(DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount,
		'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0 OR
        DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount - nvl(DD.deprn_adjustment_amount,0),
                'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0)
    AND ADJ.asset_id(+) = DD.asset_id AND
        ADJ.book_type_code(+) = DD.book_type_code AND
        ADJ.period_counter_created(+) = DD.period_counter AND
        ADJ.distribution_id(+) = DD.distribution_id AND
        ADJ.source_type_code(+) = 'REVALUATION' AND
        ADJ.adjustment_type(+) = 'EXPENSE' AND
        ADJ.adjustment_amount(+) <> 0
    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DD.Deprn_Source_Code;
   end if;

    -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

       -- Get the Group Depreciation Effects

      if (h_reporting_flag = 'R') then
        INSERT INTO fa_balances_reports_itf
           (Asset_ID,
	   Distribution_CCID,
	   Adjustment_CCID,
	   Category_Books_Account,
	   Source_Type_Code,
	   Amount,request_id)
        SELECT
	   DD.Asset_ID,
	   GAD.DEPRN_EXPENSE_ACCT_CCID ,
	   GAD.DEPRN_RESERVE_ACCT_CCID,
	   null,
	   'DEPRECIATION',
	   SUM ( DD.Deprn_Amount),h_request_id
        FROM
           FA_DEPRN_SUMMARY_MRC_V  DD,
           fa_GROUP_ASSET_RULES    GAR,
           fa_GROUP_ASSET_DEFAULT  GAD
        WHERE
             DD.BOOK_TYPE_CODE               = book
        AND  DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
        AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
        AND  GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
        AND  GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
        AND  GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
        AND  DD.PERIOD_COUNTER             between
		Period1_PC and Period2_PC
        GROUP BY
          DD.Asset_ID,
	  GAD.DEPRN_EXPENSE_ACCT_CCID ,
	  GAD.DEPRN_RESERVE_ACCT_CCID ,
	  null,
	  'DEPRECIATION' ;
       else
        INSERT INTO fa_balances_reports_itf
           (Asset_ID,
	   Distribution_CCID,
	   Adjustment_CCID,
	   Category_Books_Account,
	   Source_Type_Code,
	   Amount,request_id)
        SELECT
	   DD.Asset_ID,
	   GAD.DEPRN_EXPENSE_ACCT_CCID ,
	   GAD.DEPRN_RESERVE_ACCT_CCID,
	   null,
	   'DEPRECIATION',
	   SUM ( DD.Deprn_Amount),h_request_id
        FROM
           FA_DEPRN_SUMMARY         DD,
           fa_GROUP_ASSET_RULES    GAR,
           fa_GROUP_ASSET_DEFAULT  GAD
        WHERE
             DD.BOOK_TYPE_CODE               = book
        AND  DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
        AND DD.Asset_id            BETWEEN Start_range  AND     End_range  --Anuj
        AND  GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
        AND  GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
        AND  GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
        AND  DD.PERIOD_COUNTER             between
		Period1_PC and Period2_PC
        GROUP BY
          DD.Asset_ID,
	  GAD.DEPRN_EXPENSE_ACCT_CCID ,
	  GAD.DEPRN_RESERVE_ACCT_CCID ,
	  null,
	  'DEPRECIATION' ;
       end if;
    end if;  -- end of CRL check

  end Get_Deprn_Effects;

  Procedure populate_gt_table
  (
      errbuf              IN OUT NOCOPY VARCHAR2
     ,retcode             IN OUT NOCOPY VARCHAR2
     ,Book		  in varchar2
     ,Report_Type	  in	varchar2
     ,Report_Style        in    varchar2
     ,Request_id  	  in	number
     ,Worker_number  	  in	number
     ,Period1_PC          in    number
     ,Period1_POD         in    date
     ,Period1_PCD         in    date
     ,Period2_PC          in    number
     ,Period2_PCD         in    date
     ,Distribution_Source_Book in varchar2
 ) IS

--Define worker cursor here ..

    Cursor c_range( request_id_in number ,worker_number_in number) is
    SELECT start_range
         , end_range
    FROM FA_WORKER_JOBS
    WHERE request_id = request_id_in
    AND   worker_num = worker_number_in
    AND   status     = 'UNASSIGNED';

    Start_Asset_id  NUMBER;
    End_Asset_id    NUMBER;
    Balance_Type    VARCHAR2(10);

    beg_period_open_date date;
    beg_period_close_date date;
    end_period_open_date date;
    end_period_close_date date;
    l_request_id    number;  -- Bug# 8936484

Begin

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
	Balance_Type := 'CR';
    else
	Balance_Type := 'DR';
    end if;

   l_request_id := request_id;
   OPEN c_range(l_request_id,Worker_number);
   Loop
     fetch c_range into    Start_Asset_id , End_Asset_id;
	    if c_range%notfound then
	      close c_range;
	      exit;
	    end if;

    select period_open_date, nvl(period_close_date, sysdate)
    into   beg_period_open_date, beg_period_close_date
    from   fa_deprn_periods
    where  book_type_code = Book
    and    period_counter = Period1_PC;

    Get_Balance (Book, Distribution_Source_Book,
                 Period1_PC-1, Period1_PC-1,
                 beg_period_open_date, beg_period_close_date,
                 Report_Type, Balance_Type,
                 'BEGIN', Start_Asset_id , End_Asset_id, l_request_id);

                  -- run only if CRL installed

     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
       Get_Balance_group_begin (Book, Distribution_Source_Book,
                 Period1_PC-1, Period1_PC-1,
                 beg_period_open_date, beg_period_close_date,
                 Report_Type, Balance_Type,
                 'BEGIN' , Start_Asset_id , End_Asset_id
                 ,l_request_id
                 );
     end if;

    select period_open_date, nvl(period_close_date, sysdate)
    into   end_period_open_date, end_period_close_date
    from   fa_deprn_periods
    where  book_type_code = Book
    and    period_counter = Period2_PC;

    -- Get Ending Balance
    Get_Balance (Book, Distribution_Source_Book,
                 Period2_PC, Period1_PC-1,
                 end_period_close_date, end_period_close_date,
                 Report_Type, Balance_Type,
                 'END', Start_Asset_id , End_Asset_id,l_request_id);

     -- run only if CRL installed
     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        Get_Balance_group_end (Book, Distribution_Source_Book,
                 Period2_PC, Period1_PC-1,
                 end_period_close_date, end_period_close_date,
                 Report_Type, Balance_Type,
                 'END', Start_Asset_id , End_Asset_id,l_request_id);
     end if;

    Get_Adjustments (Book, Distribution_Source_Book,
		     Period1_PC, Period2_PC,
		     Report_Type, Balance_Type, Start_Asset_id ,End_Asset_id,l_request_id);

     -- run only if CRL installed
     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        Get_Adjustments_for_group (Book, Distribution_Source_Book,
		     Period1_PC, Period2_PC,
		     Report_Type, Balance_Type, Start_Asset_id , End_Asset_id,l_request_id);
     end if;

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
	Get_Deprn_Effects (Book, Distribution_Source_Book,
			   Period1_PC, Period2_PC,
			   Report_Type, Start_Asset_id , End_Asset_id,l_request_id);
    end if;


    --=================================
    -- Update the child status as completed
    -- after the end of loop
    --=================================

         UPDATE FA_WORKER_JOBS
              SET    status = 'COMPLETED'
         WHERE  status = 'UNASSIGNED'
         AND request_id = l_request_id
         AND start_range= start_asset_id
         AND end_range= end_asset_id;
Commit;
End Loop;

End populate_gt_table;

END FA_BALREP_PKG;

/
