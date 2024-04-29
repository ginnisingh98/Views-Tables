--------------------------------------------------------
--  DDL for Package Body FV_BE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_BE_UTIL_PKG" AS
--  $Header: FVBEUTLB.pls 120.7.12010000.2 2009/06/17 16:37:59 sharoy ship $    |
    g_module_name VARCHAR2(100) := 'fv.plsql.fv_be_util_pkg.';
    G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
    G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;

    g_errbuf  varchar2(1000);
    g_retcode number ;
    g_sob_id gl_sets_of_books.set_of_books_id%TYPE;
    g_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
    g_gl_seg_num  NUMBER(4);
    g_n_segments  NUMBER(4);
    g_gl_seg_name fnd_id_flex_segments.application_column_name%TYPE;
    g_gl_bal_seg_name fnd_id_flex_segments.application_column_name%TYPE;
    g_gl_sec_initialized BOOLEAN := FALSE;


FUNCTION has_segments_access(   p_bud_segments IN varchar2
                                ,p_ccid IN NUMBER
                                ,p_coa_id IN NUMBER
                                ,p_sob_id IN NUMBER) RETURN varchar2 IS
    l_ccid          NUMBER;
    l_valid_flag    BOOLEAN;
    l_delim         VARCHAR2(10);
    l_num           NUMBER;
    l_module_name   VARCHAR2(1000);
    l_segarray      fnd_flex_ext.segmentarray;
    i               NUMBER;
  BEGIN
    l_module_name := 'FV_BE_UTIL_PKG.has_segments_access';
    l_valid_flag := FALSE;

    -- if p_ccid is null then fetch the ccid using
    -- fnd_flex_ext.get_combination_id()
    IF p_ccid IS NULL THEN
        FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'ccid is NULL');
        l_delim := fnd_flex_ext.get_delimiter(
                            'SQLGL'
                            ,'GL#'
                            ,p_coa_id);
        FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'Delimiter ' || l_delim);

        l_num :=  fnd_flex_ext.breakup_segments(
                        p_bud_segments
                        ,l_delim
                        ,l_segarray);
        IF l_num IS NULL THEN
            FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'fnd_flex_ext.breakup_segments() returned null');
        END IF;

        FOR i IN l_segarray.FIRST .. l_segarray.LAST
        LOOP
            FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name,'l_segarray('||i||') - '||l_segarray(i));
        END LOOP;

        FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'p_coa_id is ' || p_coa_id);
        l_valid_flag := fnd_flex_ext.get_combination_id
                                (application_short_name => 'SQLGL'
                                 ,key_flex_code => 'GL#'
                                 ,structure_number => p_coa_id
                                 ,validation_date => SYSDATE
                                 ,n_segments => l_num
                                 ,segments => l_segarray
                                 ,combination_id => l_ccid
                                 ,data_set => -1
                                 );
         IF l_valid_flag = FALSE THEN
             FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT, l_module_name,
               'fnd_flex_ext.get_combination_id() ended with an error');
             RETURN 'FALSE';
          ELSE
             FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name,
                    'The API call fnd_flex_ext.get_combination_id() completed');
             FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'ccid is ' || l_ccid);
         END IF;

    -- else we can directly call the API fnd_flex_ext.get_combination_id()
    ELSE
        FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'ccid is not NULL');
        l_ccid := p_ccid;
        FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT,l_module_name, 'ccid: '||l_ccid);
    END IF;

    IF NOT g_gl_sec_initialized THEN
       fv_utility.log_mesg('Initializing gl security package');
       gl_security_pkg.init();
       g_gl_sec_initialized := TRUE;
    END IF;

    --IF l_valid_flag THEN
       -- gl_security_pkg.init();
        IF gl_security_pkg.validate_access(p_sob_id, l_ccid)='TRUE' THEN
            RETURN 'TRUE';
        ELSE
            RETURN 'FALSE';
        END IF;
    --ELSE
        --fnd_message.debug('fnd_flex_ext.get_combination_id() ended with an error');
        --FV_UTILITY.DEBUG_MESG(G_LEVEL_STATEMENT, l_module_name,'fnd_flex_ext.get_combination_id() ended with an error');
        --RETURN 'FALSE';
    --END IF;

  EXCEPTION when others then
    RAISE;
  END has_segments_access;

-- BCPSA-BE Enhancements
-- Removed p_transaction_code parameter
-- Added p_transaction_type_id and p_sub_type parameters

procedure check_cross_validation ( errbuf        OUT NOCOPY varchar2,
         retcode       OUT NOCOPY number,
	 p_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE,
	 p_header_segments fnd_flex_ext.SegmentArray,
	 p_detail_segments fnd_flex_ext.SegmentArray,
	 p_budget_level_id fv_be_trx_hdrs.budget_level_id%TYPE,
	 p_transaction_type_id fv_be_trx_dtls.transaction_type_id%TYPE,
	 p_sub_type fv_be_trx_dtls.sub_type%TYPE,
	 p_source           fv_be_trx_hdrs.source%TYPE,
	 p_increase_decrease_flag fv_be_trx_dtls.increase_decrease_flag%TYPE)
is

 l_module_name VARCHAR2(200) := g_module_name || 'check_cross_validation';
 l_user_id      NUMBER(15);
 l_resp_id      NUMBER(15);
 l_errcode      BOOLEAN;
 l_valid_flag   BOOLEAN;
 l_dr_ccid      NUMBER(15);
 l_cr_ccid      NUMBER(15);

 l_gl_dr_segments  fnd_flex_ext.SegmentArray;
 l_gl_cr_segments  fnd_flex_ext.SegmentArray;

 l_dr_account gl_ussgl_account_pairs.dr_account_segment_value%TYPE;
 l_cr_account gl_ussgl_account_pairs.cr_account_segment_value%TYPE;


-- BCPSA-BE Enhancements
-- Removed transcation_code_c cursor
-- Added accounts_cur cursor

CURSOR accounts_cur IS
SELECT cr_account_segment_value,
       dr_account_segment_value
FROM fv_be_account_pairs
WHERE be_tt_id = p_transaction_type_id
AND nvl(sub_type, 'X') = nvl(p_sub_type, 'X')
AND chart_of_accounts_id = g_chart_of_accounts_id;

begin

  g_chart_of_accounts_id := p_chart_of_accounts_id;

  retcode := 0;
  g_retcode := 0;

  l_user_id := fnd_global.user_id;
  l_resp_id := fnd_global.resp_id;

/*
  fv_utility.Get_Context(l_user_id, l_resp_id, 'ACCT_SEGMENT',
			g_gl_seg_name, l_errcode, errbuf);
*/
   fv_utility.Get_Segment_Col_Names(g_chart_of_accounts_id, g_gl_seg_name,
                                    g_gl_bal_seg_name, l_errcode, errbuf);
  if (l_errcode) then
	retcode := 2;
	return;
  end if;

    if (p_budget_level_id = 1) then

 	--Initialize both dr and cr arrays with values from document header

	initialize_gl_segments(p_header_segments, l_gl_dr_segments);
	initialize_gl_segments(p_header_segments, l_gl_cr_segments);

    else
	if (p_source = 'RPR') then

	  --Initialize both dr and cr arrays with values from document details
	  initialize_gl_segments(p_detail_segments, l_gl_dr_segments);
	  initialize_gl_segments(p_detail_segments, l_gl_cr_segments);

	else
	  if (p_increase_decrease_flag = 'I') then

	    --Initialize dr arrays with values from document header
	    --Initialize cr arrays with values from document detail
	    initialize_gl_segments(p_header_segments, l_gl_dr_segments);
	    initialize_gl_segments(p_detail_segments, l_gl_cr_segments);

	  else

	    --Initialize cr arrays with values from document header
	    --Initialize dr arrays with values from document detail
	    initialize_gl_segments(p_header_segments, l_gl_cr_segments);
	    initialize_gl_segments(p_detail_segments, l_gl_dr_segments);

	  end if;--increase_decrease_flag

	end if; --source 'RPR'

    end if; --budget_level_id 1

    if (g_retcode = 0) then

-- BCPSA-BE Enhancements
-- Removed transcation_code_c cursor
-- Added accounts_cur cursor

	open accounts_cur;
	    loop
		fetch accounts_cur
		into  l_cr_account, l_dr_account;

 	       exit when accounts_cur%NOTFOUND or accounts_cur%NOTFOUND is NULL;

		if (p_increase_decrease_flag = 'I') then
		  l_gl_cr_segments(g_gl_seg_num) := l_cr_account;
		  l_gl_dr_segments(g_gl_seg_num) := l_dr_account;
		else
		  l_gl_cr_segments(g_gl_seg_num) := l_dr_account;
		  l_gl_dr_segments(g_gl_seg_num) := l_cr_account;
		end if;

		l_valid_flag := fnd_flex_ext.get_combination_id('SQLGL', 'GL#',
		g_chart_of_accounts_id, SYSDATE, g_n_segments, l_gl_cr_segments,l_cr_ccid);
 	       if (not l_valid_flag) then
	 	 retcode := 2;
		  errbuf := fnd_flex_ext.get_message;
		  return;
		end if;
		l_valid_flag := fnd_flex_ext.get_combination_id('SQLGL', 'GL#',
		g_chart_of_accounts_id, SYSDATE, g_n_segments, l_gl_dr_segments,l_dr_ccid);
	        if (not l_valid_flag) then
		  retcode := 2;
		  errbuf := fnd_flex_ext.get_message;
		  return;
		end if;
	    end loop;
	close accounts_cur;

  end if; --g_retcode = 0

  retcode := g_retcode;
  errbuf := g_errbuf;

  exception when others then
    retcode := 2;
    errbuf:= 'Error in check_cross_validation procedure. SQL Error is '||sqlerrm;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

end; --check_cross_validation


procedure initialize_gl_segments(p_from_segments IN fnd_flex_ext.SegmentArray,
				 p_to_segments   OUT NOCOPY fnd_flex_ext.SegmentArray) is

  l_module_name VARCHAR2(200) := g_module_name || 'initialize_gl_segments';

  cursor flex_fields is
  select application_column_name
  from   fnd_id_flex_segments
  where  id_flex_code = 'GL#'
  and    id_flex_num = g_chart_of_accounts_id
  order by segment_num;

  l_n_segments NUMBER(4);
  l_column_name fnd_id_flex_segments.application_column_name%TYPE;
  l_from_seg_num NUMBER(4);

begin

  l_n_segments := 0;
  for flex_fields_rec in flex_fields
  loop
    l_n_segments := l_n_segments + 1;
    l_column_name := flex_fields_rec.application_column_name;
    l_from_seg_num := substr(rtrim(l_column_name),8);

    --Get the natural account segment column position in array

    if (l_column_name = g_gl_seg_name) then
	g_gl_seg_num := l_n_segments;
    end if;

    p_to_segments(l_n_segments) := p_from_segments(l_from_seg_num);
  end loop;
  g_n_segments := l_n_segments;

  exception when others then
    g_retcode := 2;
    g_errbuf:= 'Error in initialize_gl_segments procedure. SQL Error is '||sqlerrm;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',g_errbuf);

end; --initialize_gl_segments

end fv_be_util_pkg; -- Package body

/
