--------------------------------------------------------
--  DDL for Package Body FA_ASSET_TRACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_TRACE_PKG" AS
/* $Header: faxtrcb.pls 120.27.12010000.12 2010/04/26 17:12:36 hhafid ship $ */

FUNCTION fafsc (p_col VARCHAR2) RETURN VARCHAR2;
FUNCTION fparse_header(p_in_str VARCHAR2) RETURN VARCHAR2;
PROCEDURE load_tbls (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);
PROCEDURE load_setup_tbls (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);
PROCEDURE deprn_calc_info (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);
PROCEDURE load_xla_info (p_banner         IN          varchar2,
                         x_retcode        OUT NOCOPY  NUMBER,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);
PROCEDURE submit_subrequest(p_parent_request IN          NUMBER,
                            x_retcode        OUT NOCOPY  NUMBER,
                            x_errbuf         OUT NOCOPY  VARCHAR2);
FUNCTION enqueue_request RETURN BOOLEAN;
FUNCTION dequeue_request (p_request  IN         VARCHAR2,
                          x_desc     OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
PROCEDURE prt_opt_tbl (p_options_tbl  FA_ASSET_TRACE_PUB.t_options_tbl);
FUNCTION get_event_list RETURN VARCHAR2;
FUNCTION get_schema (p_app_short_name  VARCHAR2) RETURN VARCHAR2;
PROCEDURE log(p_calling_fn     IN  VARCHAR2,
              p_msg            IN  VARCHAR2 default null,
              p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null);

TYPE t_asset_tbl IS TABLE OF VARCHAR2(32767)
     INDEX BY BINARY_INTEGER;

TYPE c_stmt IS REF CURSOR;

Type t_cc_cols_rec IS RECORD (cTbl VARCHAR2(100), cCol VARCHAR2(100));
Type t_cc_cols IS TABLE OF t_cc_cols_rec INDEX BY BINARY_INTEGER;

TYPE t_num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_log_level_rec     fa_api_types.log_level_rec_type;
g_options_tbl       FA_ASSET_TRACE_PUB.t_options_tbl;
g_col_exclusions    FA_ASSET_TRACE_PUB.t_excl_tbl;
g_tmpc_tbl          t_col_tbl;
g_tbl_hldr          t_col_tbl;
g_anchor_tbl        t_col_tbl;
g_hdr_tbl           t_asset_tbl;
g_sel_tbl           FA_ASSET_TRACE_PVT.t_asset_tbl;
g_no_rec_tbl        t_asset_tbl;
g_tmp_tbl           t_asset_tbl;
g_output_tbl        t_asset_tbl;
g_asset_number      FA_ADDITIONS.ASSET_NUMBER%TYPE;
g_asset_id          FA_ADDITIONS.ASSET_ID%TYPE;
g_book              FA_BOOK_CONTROLS.BOOK_TYPE_CODE%TYPE;
g_book_class        FA_BOOK_CONTROLS.BOOK_CLASS%TYPE;
g_source_book       FA_BOOK_CONTROLS.DISTRIBUTION_SOURCE_BOOK%TYPE;
g_sob_id            FA_BOOK_CONTROLS.SET_OF_BOOKS_ID%TYPE;
g_fiscal_year       FA_BOOK_CONTROLS.CURRENT_FISCAL_YEAR%TYPE;
g_fiscal_year_name  FA_BOOK_CONTROLS.FISCAL_YEAR_NAME%TYPE;
g_deprn_calendar    FA_BOOK_CONTROLS.DEPRN_CALENDAR%TYPE;
g_prorate_calendar  FA_BOOK_CONTROLS.PRORATE_CALENDAR%TYPE;
g_mrc_enabled       VARCHAR2(1);
g_jx_enabled        VARCHAR2(1);
g_chk_cnt           BOOLEAN;
g_no_header         VARCHAR2(1):='N';
g_trc_tbl           VARCHAR2(100);
g_dyn_head          VARCHAR2(32767);
g_anchor            VARCHAR2(32767);
g_trc_idx           NUMBER :=1;

g_qname             varchar2(80) := 'GAT_REQ_Q';
g_qtable            varchar2(80) := 'GAT_REQ_QTBL';
g_payload           GAT_message_type;

g_submit_sub        boolean;
g_req_data          VARCHAR2(10);

g_print_debug       boolean; --  := fa_cache_pkg.fa_print_debug;

--
-- Entry point.
--
PROCEDURE do_trace (errbuf          OUT NOCOPY  VARCHAR2,
                    retcode         OUT NOCOPY  NUMBER,
                    p_book          IN          VARCHAR2,
                    p_asset_number  IN          VARCHAR2,
                    p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null) IS

   l_asset_id          NUMBER;
   l_book              VARCHAR2(15);
   l_tblcount          NUMBER;
   l_count             NUMBER;
   l_country_code      VARCHAR2(150); --financials_system_params_all.global_attribute1%type; --need 2597346 to get these columns.
   l_product_code      VARCHAR2(150); --financials_system_params_all.global_attribute2%type;
   l_app_id            number;
   l_app_version       fnd_product_groups.release_name%type;
   l_stmt              VARCHAR2(4000);
   l_temp_head         VARCHAR2(2000);
   l_desc              varchar2(200);
   l_req_count         number :=0;
   l_banner            VARCHAR2(32767);
   l_filename          VARCHAR2(80); --for utl_file

   l_parent_request    number;
   l_submit_sub        varchar2(1);

   l_qstarted          varchar2(3);

   l_calling_fn        varchar2(80)  := 'fa_asset_trace_pkg.do_trace';
   l_msg_count         number;
   l_msg_data          varchar2(512);

   error_found1        EXCEPTION;
   error_found2        EXCEPTION;

BEGIN
   dbms_lock.sleep(3); --sleeping for no reason, but leave it anyway :-)

   IF (fa_asset_trace_pkg.g_use_utl_file = 'Y') THEN
     if (nvl(fa_asset_trace_pkg.g_sla_only, 'N') = 'Y') then
       l_filename := 'GTUSLA_'||replace(ltrim(rtrim(p_book)),' ','_') || '_' || replace(p_asset_number,' ','_') ||'.log';
     else
       l_filename := 'GTU_'||replace(ltrim(rtrim(p_book)),' ','_') || '_' || replace(p_asset_number,' ','_') ||'.log';
       g_submit_sub := TRUE;
     end if;
     log(l_calling_fn, 'l_filename: '||l_filename);
     FA_ASSET_TRACE_PVT.g_use_utl_file := 'Y';
     FA_ASSET_TRACE_PVT.ocfile (FA_ASSET_TRACE_PVT.g_logfile, l_filename,'O');
   END IF;
   log(l_calling_fn, 'use utl file: '|| fa_asset_trace_pkg.g_use_utl_file);
   if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N') then
     l_parent_request := fnd_global.conc_request_id;
     log(l_calling_fn, 'l_parent_request: '|| l_parent_request);
     l_qstarted := FA_ASSET_TRACE_PUB.start_queue (p_qtable        => g_qtable,
                                                   p_qpayload_type => 'GAT_message_type',
                                                   p_qname         => g_qname);

     log(l_calling_fn, 'l_qstarted: '|| l_qstarted);

     if (l_qstarted <> 'F') then
       l_submit_sub := dequeue_request('S'||to_char(l_parent_request), l_desc);
       if (NVL(l_submit_sub, 'N') = 'S') then
         g_submit_sub := FALSE; --subrequest already submitted
       else
         g_submit_sub := TRUE;
       end if;
     end if;

     --Check number of requests in the queue + add to queue.
     --Doing this to force serial processing in case requests were submitted in
     --the same manner as bug 3184059.
     l_req_count := FA_ASSET_TRACE_PUB.g_req_tbl.count +1;
     FA_ASSET_TRACE_PUB.g_req_tbl(l_req_count) := l_parent_request;
     FA_ASSET_TRACE_PUB.wait_for_req;

   end if; --(nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N') ...

   g_print_debug := fa_cache_pkg.fa_print_debug;

   if (not g_log_level_rec.initialized) then
     if (NOT fa_util_pub.get_log_level_rec (x_log_level_rec => g_log_level_rec)) then
        raise FND_API.G_EXC_ERROR;
     else
       if (not g_print_debug) then
          g_print_debug := TRUE;
       end if;
     end if; -- (NOT fa_util_pub....
   end if;

   l_book := p_book;
   if not (fa_cache_pkg.fazcbc(X_book          => p_book,
                               p_log_level_rec => g_log_level_rec)) then
      raise error_found1;
   end if;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'setting', 'initial globals',
                       p_log_level_rec => p_log_level_rec);
   end if;

   g_book         := p_book;

   if (NVL(l_submit_sub, 'N') = 'S') then
     g_asset_id := to_number(p_asset_number);

     SELECT asset_number
     INTO g_asset_number
     FROM fa_additions_b
     where asset_id = g_asset_id;
   else
     g_asset_number := p_asset_number;
     BEGIN
        SELECT asset_id
          INTO l_asset_id
          FROM fa_additions_b
         WHERE asset_number = p_asset_number;

        g_asset_id := l_asset_id;

        SELECT count(*)
          INTO l_count
          FROM fa_books
         WHERE asset_id = g_asset_id
           AND book_type_code = g_book;

        if l_count = 0 then
           raise ERROR_FOUND2;
        end if;

     EXCEPTION
        WHEN ERROR_FOUND2 THEN
           -- 'FA_EXP_GET_ASSET_INFO';
           raise error_found1;
        WHEN OTHERS THEN
           -- 'FA_EXP_GET_ASSET_INFO';
           raise error_found1;
     END;
   end if; -- (NVL(l_submit_sub, 'N') = 'S')

   if (nvl(fa_asset_trace_pkg.g_sla_only, 'N') = 'Y') then
     l_desc := 'FATRACE - SLA Subrequest from backend: '||g_book||'-'||g_asset_id||'-'||to_char(sysdate);
   end if;

   --populate param tbl.
   l_count :=FA_ASSET_TRACE_PVT.g_param_tbl.count + 1;
   FA_ASSET_TRACE_PVT.g_param_tbl(l_count).param_column :='ASSET_ID';
   FA_ASSET_TRACE_PVT.g_param_tbl(l_count).nValue := g_asset_id;
   l_count := l_count +1;
   FA_ASSET_TRACE_PVT.g_param_tbl(l_count).param_column :='BOOK_TYPE_CODE';
   FA_ASSET_TRACE_PVT.g_param_tbl(l_count).cValue := g_book;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'setting', 'localizations info');
   end if;

   -- Doing this check for globalizations until a better way is found.
   FND_PROFILE.get('JGZZ_COUNTRY_CODE',l_country_code);

   -- Derive Product Code from Country
   -- Application Id: 7000-JA, 7002-JE, 7003-JG, 7004-JL
   -- Right now just getting the info to make sure we select the global_attributexx columns
   -- In future, we may want to select globalization data from the country-specific tables.

   IF l_country_code IS NOT NULL THEN

      IF l_country_code IN ('AU', 'CA', 'KR', 'SG', 'TH', 'TW') THEN
         l_product_code := 'JA';
         l_app_id       :=7000;
         g_jx_enabled   := 'Y';
      ELSIF l_country_code in ('AT', 'BE', 'CH', 'CZ', 'DE',
                               'DK', 'ES', 'FI', 'FR', 'GR',
                               'HU', 'IT', 'NL', 'NO', 'PL',
                               'PT', 'SE', 'TR') THEN
         l_product_code := 'JE';
         l_app_id       :=7002;
         g_jx_enabled   := 'Y';
      ELSIF l_country_code in ('AR', 'BR', 'CL', 'CO', 'MX') THEN
         l_product_code := 'JL';
         l_app_id       :=7004;
         g_jx_enabled   := 'Y';
      ELSE
         l_product_code := NULL;
         l_app_id       :=NULL;
         g_jx_enabled   := 'N';
      END IF;
   ELSE
      g_jx_enabled := 'N';
   END IF;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'setting', 'book control info',
                               p_log_level_rec => p_log_level_rec);
   end if;

   g_mrc_enabled := NVL(fa_cache_pkg.fazcbc_record.mc_source_flag,'N');
   g_book_class  := fa_cache_pkg.fazcbc_record.book_class;
   g_source_book := fa_cache_pkg.fazcbc_record.distribution_source_book;
   g_sob_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
   g_fiscal_year := fa_cache_pkg.fazcbc_record.current_fiscal_year;
   g_fiscal_year_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
   g_deprn_calendar := fa_cache_pkg.fazcbc_record.deprn_calendar;
   g_prorate_calendar:= fa_cache_pkg.fazcbc_record.prorate_calendar;

   log (l_calling_fn,'g_source_book: '||g_source_book);

   FA_ASSET_TRACE_PVT.g_jx_enabled  := g_jx_enabled;
   FA_ASSET_TRACE_PVT.g_mrc_enabled := g_mrc_enabled;

   select release_name
   into l_app_version
   from fnd_product_groups;

   DBMS_SESSION.SET_NLS('NLS_DATE_FORMAT','''DD-MON-YYYY HH24:MI:SS''');
   --set banner section
   l_temp_head :='<tr>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>Asset Number</b></font></td>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>Asset ID</b></font></td>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>Book Type</b></font></td>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>Book Class</b></font></td>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>App. Version</b></font></td>
    <td  bgcolor="#cfe0f1" align="center"><font color="#343434"><b>Run Date</b></font></td></tr>
    <tr><td  bgcolor="#f2f2f5" align="center">'||g_asset_number||'</td>
    <td  bgcolor="#f2f2f5" align="center">'||g_asset_id||'</td>
    <td  bgcolor="#f2f2f5" align="center">'||g_book||'</td>
    <td  bgcolor="#f2f2f5" align="center">'||g_book_class||'</td>
    <td  bgcolor="#f2f2f5" align="center">'||l_app_version||'</td>
    <td  bgcolor="#f2f2f5" align="center">'||sysdate||'</td></tr></table></center><br><hr width="93%" align="left" size="5"color="#343434"><br>';

   FA_ASSET_TRACE_PUB.set_temp_head (l_temp_head);
   --
   if (g_submit_sub) then

     l_stmt :=''''||'<TD bgcolor="#f2f2f5">'||''''||'||bk.BOOK_TYPE_CODE||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.DISTRIBUTION_SOURCE_BOOK||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.BOOK_CLASS||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.DATE_INEFFECTIVE||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.SET_OF_BOOKS_ID||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.LAST_DEPRN_RUN_DATE||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.DEPRN_STATUS||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.MASS_REQUEST_ID||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||bc.LAST_PERIOD_COUNTER||'||''''||'</TD>'||''''||'||''''||';
     l_stmt :=l_stmt||''''||'<TD bgcolor="#f2f2f5">'||''''||'||dp.PERIOD_COUNTER||'||''''||'</TD>'||'''';
     l_stmt :=l_stmt||' from fa_books bk, fa_book_controls bc, fa_deprn_periods dp
                          where bc.book_type_code = bk.book_type_code
                          and dp.book_type_code = bk.book_type_code
                          and dp.period_close_date is null
                          and bk.date_ineffective is null
                          and bk.asset_id = '|| l_asset_id;

     l_banner :='NH <TABLE BORDER=0 width="93%" cellpadding="5"><TR><TD BGCOLOR="#3a5a87"><font color=white><B>List of books to which this asset was added'
          ||'</B></TD></TR></TABLE><TABLE BORDER=0 width="93%" cellpadding="5" BORDERCOLOR="#c9cbd3"><TR>';
     l_banner := l_banner||fparse_header('BOOK_TYPE_CODE')||fparse_header('DISTRIBUTION_SOURCE_BOOK')
                 ||fparse_header('BOOK_CLASS')||fparse_header('DATE_INEFFECTIVE')
                 ||fparse_header('SET_OF_BOOKS_ID')||fparse_header('LAST_DEPRN_RUN_DATE')
                 ||fparse_header('DEPRN_STATUS')||fparse_header('MASS_REQUEST_ID')
                 ||fparse_header('LAST_PERIOD_COUNTER')||fparse_header('CURRENT_PERIOD_COUNTER')||'</TR>';

     load_tbls;
     FA_ASSET_TRACE_PUB.run_trace(p_opt_tbl       => g_options_tbl,
                                p_exc_tbl       => g_col_exclusions,
                                p_tdyn_head     => l_banner,
                                p_stmt          => l_stmt,
                                p_sys_opt_tbl   => 'FA_SYSTEM_CONTROLS',
                                p_use_utl_file  => fa_asset_trace_pkg.g_use_utl_file,
                                p_debug_flag    => g_print_debug,
                                p_calling_prog  => 'Asset Trace Utility',
                                p_retcode       => retcode,
                                p_log_level_rec => g_log_level_rec);

     if ((nvl(fa_asset_trace_pkg.g_sla_only, 'Y') = 'N') and
         (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N')) then
       submit_subrequest (l_parent_request, retcode, errbuf);
     end if;

     log(l_calling_fn,'Parent request, retcode is '||retcode);
     if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'N') = 'Y') then
       log(l_calling_fn, 'Trying to close log file');
       FA_ASSET_TRACE_PVT.ocfile (FA_ASSET_TRACE_PVT.g_logfile, null,'C');
     end if;
     g_submit_sub := FALSE;
   elsif ((NOT g_submit_sub) OR ((nvl(fa_asset_trace_pkg.g_sla_only, 'N') = 'Y'))) then

     log(l_calling_fn,'Calling load_xla_info.');
     load_xla_info(l_desc, retcode, g_log_level_rec);
     log(l_calling_fn,'sla subrequest retcode is '||retcode);

     if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'N') = 'Y') then
       FA_ASSET_TRACE_PVT.ocfile (FA_ASSET_TRACE_PVT.g_logfile, null,'C');
     end if;

   end if;

   if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N') then
     if g_print_debug then
       fa_debug_pkg.add(l_calling_fn, 'retcode', retcode, p_log_level_rec => p_log_level_rec);
     end if;
     if (g_print_debug) then
       fa_debug_pkg.Write_Debug_Log;
     end if;
     FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data  => l_msg_data);
     fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);
   end if;

EXCEPTION

   WHEN ERROR_FOUND1 THEN
        fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);
        if ((g_print_debug) and (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N')) then
           fa_debug_pkg.Write_Debug_Log;
        end if;
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                  p_data  => l_msg_data);
        if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N') then
          fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);
        else
          log (l_calling_fn,'Others: '||l_msg_count||' - '||l_msg_data);
        end if;
        retcode := 2;

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                                  p_log_level_rec => p_log_level_rec);
        if ((g_print_debug) and (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N')) then
           fa_debug_pkg.Write_Debug_Log;
        end if;
        FND_MSG_PUB.Count_And_Get(p_count => l_msg_count,
                                  p_data  => l_msg_data);
        if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'Y') = 'N') then
          fa_srvr_msg.Write_Msg_Log(l_msg_count, l_msg_data);
        else
          log (l_calling_fn,'Others: '||l_msg_count||' - '||l_msg_data);
        end if;
        retcode := 2;

END do_trace;
--
--Load tables to be processed
--
PROCEDURE load_tbls (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

  l_nmrc_count  NUMBER;
  l_check_reval NUMBER;
  l_idx         number := 0;
  l_options_tbl FA_ASSET_TRACE_PUB.t_options_tbl;

  l_calling_fn  varchar2(40)  := 'fa_asset_trace_pkg.load_tbls';

BEGIN
   select count(1)
   into l_check_reval
   from fa_transaction_headers
   where transaction_type_code = 'REVALUATION'
   and asset_id = g_asset_id
   and book_type_code = g_book;

   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_ADDITIONS_B';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_col_order     := 'ASSET_NUMBER,ASSET_TYPE,ASSET_CATEGORY_ID,CURRENT_UNITS';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_ADDITIONS_TL';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_TRANSACTION_HEADERS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'BOOK_TYPE_CODE,TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('BOOK_TYPE_CODE')||fafsc('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_order_by      := 'TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('BOOK_TYPE_CODE')||fparse_header('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_num_cols      := 2;
   l_options_tbl(l_idx).l_col_order     := 'TRANSACTION_TYPE_CODE,TRANSACTION_DATE_ENTERED,DATE_EFFECTIVE,AMORTIZATION_START_DATE'
     ||',CALLING_INTERFACE,MASS_REFERENCE_ID,TRANSACTION_NAME,TRANSACTION_SUBTYPE,TRANSACTION_KEY,SOURCE_TRANSACTION_HEADER_ID'
     ||',MASS_TRANSACTION_ID,INVOICE_TRANSACTION_ID';
   l_options_tbl(l_idx).l_add_clause    := ' FROM FA_TRANSACTION_HEADERS Where asset_id = '||g_asset_id
    ||' and book_type_code in ('||''''||g_source_book||''''||','||''''||g_book||''''||') ';
   l_options_tbl(l_idx).l_cnt_stmt      := 'SELECT count(1) FROM FA_TRANSACTION_HEADERS'
    ||' WHERE asset_id = '||g_asset_id||' and book_type_code in ('||''''||g_source_book||''''||','||''''||g_book||''''||')';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_ASSET_HISTORY';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_DISTRIBUTION_HISTORY';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_order_by      := 'DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_num_cols      := 1;
   l_options_tbl(l_idx).l_col_order     := 'TRANSACTION_HEADER_ID_IN,TRANSACTION_HEADER_ID_OUT'
    ||',CODE_COMBINATION_ID,LOCATION_ID,ASSIGNED_TO,RETIREMENT_ID,UNITS_ASSIGNED,TRANSACTION_UNITS';
   l_options_tbl(l_idx).l_add_clause    := ' FROM FA_DISTRIBUTION_HISTORY Where asset_id = '||g_asset_id
    ||' and book_type_code in ('||''''||g_source_book||''''||','||''''||g_book||''''||') ';
   l_options_tbl(l_idx).l_cnt_stmt      := 'SELECT count(1) FROM FA_DISTRIBUTION_HISTORY'
    ||' WHERE asset_id = '||g_asset_id||' and book_type_code = '||''''||g_source_book||'''';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_ADJUSTMENTS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_order_by      := 'TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_num_cols      := 1;
   l_options_tbl(l_idx).l_col_order     := 'SOURCE_TYPE_CODE,ADJUSTMENT_TYPE,DEBIT_CREDIT_FLAG,CODE_COMBINATION_ID,'
     ||'ADJUSTMENT_AMOUNT,DISTRIBUTION_ID,PERIOD_COUNTER_CREATED,PERIOD_COUNTER_ADJUSTED';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_MC_ADJUSTMENTS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'SET_OF_BOOKS_ID,TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('SET_OF_BOOKS_ID')||fafsc('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_order_by      := 'SET_OF_BOOKS_ID,TRANSACTION_HEADER_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('SET_OF_BOOKS_ID')||fparse_header('TRANSACTION_HEADER_ID');
   l_options_tbl(l_idx).l_num_cols      := 2;
   l_options_tbl(l_idx).l_col_order     := 'SOURCE_TYPE_CODE,ADJUSTMENT_TYPE'
     ||',DEBIT_CREDIT_FLAG,CODE_COMBINATION_ID,ADJUSTMENT_AMOUNT,DISTRIBUTION_ID'
     ||',PERIOD_COUNTER_CREATED,PERIOD_COUNTER_ADJUSTED';
   if (l_check_reval > 1) then
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'FA_MASS_REVALUATIONS';
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'MASS_REVAL_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('MASS_REVAL_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('MASS_REVAL_ID');
     l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MASS_REVALUATIONS where book_type_code = '||''''||g_book||''''
       ||' and mass_reval_id in (select mass_transaction_id from fa_transaction_headers where transaction_type_code = ''REVALUATION'''
	   ||' and asset_id = '||g_asset_id||' and book_type_code = '||'''' || g_book || ''''||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
	 l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'FA_MASS_REVALUATIONS_RULES';
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'MASS_REVAL_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('MASS_REVAL_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('MASS_REVAL_ID');
     l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MASS_REVALUATIONS_RULES where asset_id = '||g_asset_id
       ||' and mass_reval_id in (select mass_transaction_id from fa_transaction_headers where transaction_type_code = ''REVALUATION'''
	   ||' and asset_id = '||g_asset_id||' and book_type_code = '||'''' || g_book || ''''||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
   end if;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_BOOKS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'TRANSACTION_HEADER_ID_IN';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('TRANSACTION_HEADER_ID_IN');
   l_options_tbl(l_idx).l_order_by      := 'TRANSACTION_HEADER_ID_IN';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('TRANSACTION_HEADER_ID_IN');
   l_options_tbl(l_idx).l_num_cols      := 1;
   l_options_tbl(l_idx).l_col_order     := 'TRANSACTION_HEADER_ID_OUT,DATE_EFFECTIVE,DATE_INEFFECTIVE,DATE_PLACED_IN_SERVICE,'
     ||'ORIGINAL_COST,COST,ADJUSTED_COST,ADJUSTED_RECOVERABLE_COST,RECOVERABLE_COST,UNREVALUED_COST,SALVAGE_VALUE,'
	 ||'PRORATE_CONVENTION_CODE,PRORATE_DATE,DEPRN_START_DATE,DEPRN_METHOD_CODE,LIFE_IN_MONTHS,DEPRECIATE_FLAG,CAPITALIZE_FLAG'
     ||',RATE_ADJUSTMENT_FACTOR,ANNUAL_DEPRN_ROUNDING_FLAG,ANNUAL_ROUNDING_FLAG,ADJUSTMENT_REQUIRED_STATUS';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_MC_BOOKS_RATES';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_DEPRN_SUMMARY';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by      := 'PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols      := 1;
   l_options_tbl(l_idx).l_col_order     := 'DEPRN_SOURCE_CODE,DEPRN_RUN_DATE,DEPRN_AMOUNT,YTD_DEPRN,DEPRN_RESERVE,ADJUSTED_COST';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_DEPRN_SUMMARY_H';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by      := 'PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols      := 1;
   l_options_tbl(l_idx).l_col_order     := 'EVENT_ID,REVERSAL_EVENT_ID,REVERSAL_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_MC_DEPRN_SUMMARY';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SET_OF_BOOKS_ID,PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SET_OF_BOOKS_ID')||fafsc('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by     := 'SET_OF_BOOKS_ID,PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SET_OF_BOOKS_ID')||fparse_header('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_col_order    := 'DEPRN_SOURCE_CODE,DEPRN_RUN_DATE,DEPRN_AMOUNT,YTD_DEPRN,DEPRN_RESERVE,ADJUSTED_COST';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_MC_DEPRN_SUMMARY_H';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SET_OF_BOOKS_ID,PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SET_OF_BOOKS_ID')||fafsc('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by     := 'SET_OF_BOOKS_ID,PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SET_OF_BOOKS_ID')||fparse_header('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_col_order    := 'EVENT_ID,REVERSAL_EVENT_ID,REVERSAL_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_DEPRN_DETAIL';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('PERIOD_COUNTER')||fafsc('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_order_by      := 'PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('PERIOD_COUNTER')||fparse_header('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_num_cols      := 2;
   l_options_tbl(l_idx).l_col_order     := 'DEPRN_SOURCE_CODE,DEPRN_RUN_DATE,DEPRN_AMOUNT'
             ||',YTD_DEPRN,DEPRN_RESERVE,ADDITION_COST_TO_CLEAR,COST,DEPRN_ADJUSTMENT_AMOUNT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_DEPRN_DETAIL_H';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('PERIOD_COUNTER')||fafsc('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_order_by      := 'PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('PERIOD_COUNTER')||fparse_header('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_num_cols      := 2;
   l_options_tbl(l_idx).l_col_order     := 'EVENT_ID,REVERSAL_EVENT_ID,REVERSAL_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_MC_DEPRN_DETAIL';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'SET_OF_BOOKS_ID,PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('SET_OF_BOOKS_ID')||fafsc('PERIOD_COUNTER')||fafsc('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_order_by      := 'SET_OF_BOOKS_ID,PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('SET_OF_BOOKS_ID')||fparse_header('PERIOD_COUNTER')||fparse_header('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_num_cols      := 3;
   l_options_tbl(l_idx).l_col_order     := 'DEPRN_SOURCE_CODE,DEPRN_RUN_DATE,DEPRN_AMOUNT'
             ||',YTD_DEPRN,DEPRN_RESERVE,ADDITION_COST_TO_CLEAR,COST,DEPRN_ADJUSTMENT_AMOUNT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_MC_DEPRN_DETAIL_H';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'SET_OF_BOOKS_ID,PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('SET_OF_BOOKS_ID')||fafsc('PERIOD_COUNTER')||fafsc('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_order_by      := 'SET_OF_BOOKS_ID,PERIOD_COUNTER,DISTRIBUTION_ID';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('SET_OF_BOOKS_ID')||fparse_header('PERIOD_COUNTER')||fparse_header('DISTRIBUTION_ID');
   l_options_tbl(l_idx).l_num_cols      := 3;
   l_options_tbl(l_idx).l_col_order     := 'EVENT_ID,REVERSAL_EVENT_ID,REVERSAL_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_TRACK_MEMBERS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'TRACK_MEMBER_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('TRACK_MEMBER_ID');
   l_options_tbl(l_idx).l_order_by     := 'TRACK_MEMBER_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('TRACK_MEMBER_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'GROUP_ASSET_ID,PERIOD_COUNTER,FISCAL_YEAR';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_TRACK_MEMBERS where member_asset_id = '||g_asset_id||' or group_asset_id = '||g_asset_id;
   l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_DEFERRED_DEPRN';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'CORP_PERIOD_COUNTER,TAX_PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols := fafsc('CORP_PERIOD_COUNTER')||fafsc('TAX_PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by     := 'CORP_PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('CORP_PERIOD_COUNTER')||fparse_header('TAX_PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_DEPRN_OVERRIDE';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'DEPRN_OVERRIDE_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('DEPRN_OVERRIDE_ID');
   l_options_tbl(l_idx).l_order_by     := 'DEPRN_OVERRIDE_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('DEPRN_OVERRIDE_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'PERIOD_NAME';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_RETIREMENTS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'RETIREMENT_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('RETIREMENT_ID');
   l_options_tbl(l_idx).l_order_by     := 'RETIREMENT_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('RETIREMENT_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'TRANSACTION_HEADER_ID_IN,TRANSACTION_HEADER_ID_OUT'
                ||',DATE_RETIRED,STATUS,DATE_EFFECTIVE,COST_RETIRED,NBV_RETIRED,GAIN_LOSS_AMOUNT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_MC_RETIREMENTS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SET_OF_BOOKS_ID,RETIREMENT_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SET_OF_BOOKS_ID')||fafsc('RETIREMENT_ID');
   l_options_tbl(l_idx).l_order_by     := 'SET_OF_BOOKS_ID,RETIREMENT_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SET_OF_BOOKS_ID')||fparse_header('RETIREMENT_ID');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_col_order    := 'TRANSACTION_HEADER_ID_IN,TRANSACTION_HEADER_ID_OUT,DATE_RETIRED,STATUS'
               ||',DATE_EFFECTIVE,COST_RETIRED,NBV_RETIRED,GAIN_LOSS_AMOUNT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_ASSET_INVOICES';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SOURCE_LINE_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SOURCE_LINE_ID');
   l_options_tbl(l_idx).l_order_by     := 'SOURCE_LINE_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SOURCE_LINE_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'INVOICE_DATE,INVOICE_ID,INVOICE_NUMBER,INVOICE_TRANSACTION_ID_IN,INVOICE_TRANSACTION_ID_OUT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_MC_ASSET_INVOICES';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SOURCE_LINE_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SOURCE_LINE_ID');
   l_options_tbl(l_idx).l_order_by     := 'SET_OF_BOOKS_ID,SOURCE_LINE_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SOURCE_LINE_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'INVOICE_DATE,INVOICE_ID,INVOICE_NUMBER,INVOICE_TRANSACTION_ID_IN,INVOICE_TRANSACTION_ID_OUT';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_INVOICE_TRANSACTIONS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'INVOICE_TRANSACTION_ID,DATE_EFFECTIVE';
   l_options_tbl(l_idx).l_leading_cols := fafsc('INVOICE_TRANSACTION_ID')||fafsc('IT.DATE_EFFECTIVE');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('INVOICE_TRANSACTION_ID')||fparse_header('DATE_EFFECTIVE');
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_INVOICE_TRANSACTIONS it, fa_asset_invoices ai where ai.asset_id = ' || g_asset_id
     ||' and (ai.invoice_transaction_id_in = it.invoice_transaction_id or ai.invoice_transaction_id_out = it.invoice_transaction_id)'
	 ||' order by INVOICE_TRANSACTION_ID';
   l_options_tbl(l_idx).l_cnt_stmt     := 'SELECT count(it.invoice_transaction_id) FROM FA_INVOICE_TRANSACTIONS it, fa_asset_invoices ai'
     ||' where ai.asset_id = ' || g_asset_id ||' and (ai.invoice_transaction_id_in = it.invoice_transaction_id '
     ||' or ai.invoice_transaction_id_out = it.invoice_transaction_id)';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_TRX_REFERENCES';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'TRX_REFERENCE_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('TRX_REFERENCE_ID');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('TRX_REFERENCE_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_TRX_REFERENCES WHERE book_type_code = '||''''||g_book||''''
     ||' and (member_asset_id = '||g_asset_id||' or src_asset_id = '||g_asset_id||' or dest_asset_id = '||g_asset_id||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'SELECT count(1) FROM FA_TRX_REFERENCES WHERE book_type_code = '||''''||g_book||''''
     ||' and (member_asset_id = '||g_asset_id||' or src_asset_id = '||g_asset_id||' or dest_asset_id = '||g_asset_id||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_BOOKS_SUMMARY';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'FISCAL_YEAR,PERIOD_NUM,PERIOD_COUNTER';
   l_options_tbl(l_idx).l_leading_cols := fafsc('FISCAL_YEAR')||fafsc('PERIOD_NUM')||fafsc('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_order_by     := 'PERIOD_COUNTER';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('FISCAL_YEAR')||fparse_header('PERIOD_NUM')||fparse_header('PERIOD_COUNTER');
   l_options_tbl(l_idx).l_num_cols     := 3;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl           := 'FA_MC_BOOKS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_lcs           := 'SET_OF_BOOKS_ID,TRANSACTION_HEADER_ID_IN';
   l_options_tbl(l_idx).l_leading_cols  := fafsc('SET_OF_BOOKS_ID')||fafsc('TRANSACTION_HEADER_ID_IN');
   l_options_tbl(l_idx).l_order_by      := 'SET_OF_BOOKS_ID,TRANSACTION_HEADER_ID_IN';
   l_options_tbl(l_idx).l_lc_header     := fparse_header('SET_OF_BOOKS_ID')||fparse_header('TRANSACTION_HEADER_ID_IN');
   l_options_tbl(l_idx).l_num_cols      := 2;
   l_options_tbl(l_idx).l_col_order     := 'TRANSACTION_HEADER_ID_OUT,DATE_EFFECTIVE,DATE_INEFFECTIVE,DATE_PLACED_IN_SERVICE,'
     ||'ORIGINAL_COST,COST,ADJUSTED_COST,ADJUSTED_RECOVERABLE_COST,RECOVERABLE_COST,UNREVALUED_COST,SALVAGE_VALUE,'
	 ||'PRORATE_CONVENTION_CODE,PRORATE_DATE,DEPRN_START_DATE,DEPRN_METHOD_CODE,LIFE_IN_MONTHS,DEPRECIATE_FLAG,CAPITALIZE_FLAG'
     ||',RATE_ADJUSTMENT_FACTOR,ANNUAL_DEPRN_ROUNDING_FLAG,ANNUAL_ROUNDING_FLAG,ADJUSTMENT_REQUIRED_STATUS';

   --reset index for reuse
   l_idx:= 0;

   --do exclusions
   l_idx:= l_idx+ 1;   g_col_exclusions(l_idx).cValue  := 'ASSET_ID';
   l_idx:= l_idx+ 1;   g_col_exclusions(l_idx).cValue  := 'BOOK_TYPE_CODE';
   l_idx:= l_idx+ 1;   g_col_exclusions(l_idx).cValue  := 'APPLICATION_ID';
   l_idx:= l_idx+ 1;   g_col_exclusions(l_idx).cValue  := 'CREATED_BY';
   l_idx:= l_idx+ 1;   g_col_exclusions(l_idx).cValue  := 'CREATION_DATE';
   l_idx:= l_idx+ 1;
   g_col_exclusions(l_idx).cValue  := 'ATTRIBUTE%';        g_col_exclusions(l_idx).cType := 'P';
   l_idx:= l_idx+ 1;
   g_col_exclusions(l_idx).cValue  := 'SEGMENT%';          g_col_exclusions(l_idx).cType := 'P';
   l_idx:= l_idx+ 1;
   g_col_exclusions(l_idx).cValue  := 'TH_ATTRIBUTE%';     g_col_exclusions(l_idx).cType := 'P';
   l_idx:= l_idx+ 1;
   g_col_exclusions(l_idx).cValue  := 'TRX_ATTRIBUTE%';    g_col_exclusions(l_idx).cType := 'P';

   g_options_tbl :=l_options_tbl;

   --load non-primary
   load_setup_tbls;
   --load derpn calc info
   deprn_calc_info;
   get_dist_info;

   l_options_tbl := g_options_tbl;

   -- Doing this so as not to needlessly generate statements if MRC is not enabled.
   IF NVL(g_mrc_enabled,'N') <>'Y' THEN
     g_options_tbl.delete;
	 l_nmrc_count := g_options_tbl.count + 1;
     FOR i IN l_options_tbl.first .. l_options_tbl.last LOOP
       IF substr(l_options_tbl(i).l_tbl,instr(l_options_tbl(i).l_tbl,'_'),4) <> '_MC_' THEN
         g_options_tbl(l_nmrc_count) :=l_options_tbl(i);
         l_nmrc_count := l_nmrc_count + 1;
       END IF;
     END LOOP;
   ELSE
     g_options_tbl :=l_options_tbl;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                               p_log_level_rec => p_log_level_rec);
     raise;

END load_tbls;
--
-- Gets setup-related tbls.
--

PROCEDURE load_setup_tbls (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_counter     NUMBER;
   l_idx         number;
   l_options_tbl FA_ASSET_TRACE_PUB.t_options_tbl;

   l_calling_fn  varchar2(40)  := 'fa_asset_trace_pkg.load_setup_tbls';

BEGIN

   l_counter     := g_options_tbl.count +1;
   l_idx         := 0;

   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_DEPRN_PERIODS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'PERIOD_COUNTER,PERIOD_NAME';
   l_options_tbl(l_idx).l_leading_cols := fafsc('PERIOD_COUNTER')||fafsc('PERIOD_NAME');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('PERIOD_COUNTER')||fparse_header('PERIOD_NAME');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_col_order    := 'FISCAL_YEAR,PERIOD_NUM,PERIOD_OPEN_DATE,PERIOD_CLOSE_DATE,'
                   ||'CALENDAR_PERIOD_OPEN_DATE,CALENDAR_PERIOD_CLOSE_DATE';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_DEPRN_PERIODS WHERE book_type_code = '
     ||''''||g_book||'''' ||' ORDER BY period_counter';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_MC_DEPRN_PERIODS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SET_OF_BOOKS_ID,PERIOD_COUNTER,PERIOD_NAME';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SET_OF_BOOKS_ID')||fafsc('PERIOD_COUNTER')||fafsc('PERIOD_NAME');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SET_OF_BOOKS_ID')||fparse_header('PERIOD_COUNTER')||fparse_header('PERIOD_NAME');
   l_options_tbl(l_idx).l_num_cols     := 3;
   l_options_tbl(l_idx).l_col_order    := 'FISCAL_YEAR,PERIOD_NUM,PERIOD_OPEN_DATE,PERIOD_CLOSE_DATE,'
                   ||'CALENDAR_PERIOD_OPEN_DATE,CALENDAR_PERIOD_CLOSE_DATE';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MC_DEPRN_PERIODS WHERE book_type_code = '||''''||g_book||''''
         ||' ORDER BY SET_OF_BOOKS_ID, period_counter';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_MASS_ADDITIONS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'MASS_ADDITION_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_order_by     := 'MASS_ADDITION_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'ASSET_NUMBER,QUEUE_NAME,POSTING_STATUS,TAG_NUMBER,DESCRIPTION,ASSET_CATEGORY_ID';
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_mass_additions WHERE asset_number = '||''''||g_asset_number||''''
     ||' AND book_type_code = '||''''||g_book||''''||' OR add_to_asset_id = '||g_asset_id;
   l_options_tbl(l_idx).l_cnt_stmt     := 'SELECT count(*) FROM fa_mass_additions WHERE asset_number = '
     ||''''||g_asset_number||'''' ||' OR add_to_asset_id = '||g_asset_id;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_MASSADD_DISTRIBUTIONS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'MASS_ADDITION_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_order_by     := 'MASS_ADDITION_ID,MASSADD_DIST_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MASSADD_DISTRIBUTIONS WHERE mass_addition_id IN (SELECT mass_addition_id FROM '
     ||'fa_mass_additions WHERE asset_number =' ||''''||g_asset_number||''''||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'SELECT count(*) FROM fa_mass_additions WHERE asset_number = '
     ||''''||g_asset_number||'''' ||' OR add_to_asset_id = '||g_asset_id;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_MC_MASS_RATES';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'SET_OF_BOOKS_ID,MASS_ADDITION_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('SET_OF_BOOKS_ID')||fafsc('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_order_by     := 'SET_OF_BOOKS_ID,MASS_ADDITION_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('SET_OF_BOOKS_ID')||fparse_header('MASS_ADDITION_ID');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MC_MASS_RATES WHERE mass_addition_id IN (SELECT mass_addition_id FROM fa_mass_additions '
     ||'WHERE asset_number =' ||''''||g_asset_number||''''||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'SELECT count(*) FROM fa_mass_additions WHERE asset_number = '
     ||''''||g_asset_number||'''' ||' OR add_to_asset_id = '||g_asset_id;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_BOOK_CONTROLS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_BOOK_CONTROLS WHERE book_type_code = '||''''||g_book||'''';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_MC_BOOK_CONTROLS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_MC_BOOK_CONTROLS WHERE book_type_code = '||''''||g_book||'''';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'GL_MC_REPORTING_OPTIONS';
   l_options_tbl(l_idx).l_gen_select    := 'Y';
   l_options_tbl(l_idx).l_schema       := 'GL';
   l_options_tbl(l_idx).l_lcs          := 'REPORTING_SET_OF_BOOKS_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('REPORTING_SET_OF_BOOKS_ID');
   l_options_tbl(l_idx).l_order_by     := 'REPORTING_SET_OF_BOOKS_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('REPORTING_SET_OF_BOOKS_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM GL_MC_REPORTING_OPTIONS WHERE fa_book_type_code = '||''''||g_book||'''';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_BOOK_CONTROLS_HISTORY';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_BOOK_CONTROLS_HISTORY WHERE book_type_code = '||''''||g_book||''''||' ORDER BY date_active';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_CATEGORIES_B';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'CATEGORY_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('CATEGORY_ID');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('CATEGORY_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_CATEGORIES_B WHERE category_id IN (SELECT DISTINCT ah.category_id FROM fa_asset_history ah'
     ||' WHERE ah.asset_id = '||g_asset_id|| ') ORDER BY category_id';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_CATEGORIES_TL';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'CATEGORY_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('CATEGORY_ID');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('CATEGORY_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_CATEGORIES_TL WHERE category_id IN (SELECT DISTINCT ah.category_id FROM fa_asset_history ah'
     ||' WHERE ah.asset_id = '||g_asset_id|| ') ORDER BY category_id';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_CATEGORY_BOOKS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'CATEGORY_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('CATEGORY_ID');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('CATEGORY_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_category_books WHERE category_id IN (SELECT DISTINCT ah.category_id FROM fa_asset_history ah'
	 ||' WHERE ah.asset_id = '||g_asset_id|| ') AND book_type_code = '||''''||g_book||'''' ||' ORDER BY category_id';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'FA_CATEGORY_BOOK_DEFAULTS';
   l_options_tbl(l_idx).l_gen_select   := 'Y';
   l_options_tbl(l_idx).l_lcs          := 'CATEGORY_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('CATEGORY_ID');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('CATEGORY_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_category_book_defaults WHERE category_id IN (SELECT DISTINCT ah.category_id '
     ||'FROM fa_asset_history ah WHERE ah.asset_id = '||g_asset_id||') AND book_type_code = '||''''||g_book||''''
	 ||' ORDER BY category_id, start_dpis';

   --load global tbl.
   FOR i IN l_options_tbl.first .. l_options_tbl.last LOOP
      g_options_tbl(l_counter) :=l_options_tbl(i);
      l_counter := l_counter + 1;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                               p_log_level_rec => p_log_level_rec);
      raise;

END load_setup_tbls;

--
-- Gets account info for the active distribution(s).
-- Not happy with this solution, but works for now.
--

PROCEDURE get_dist_info (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_appid           fnd_profile_option_values.level_value_application_id%type;
   l_options_tbl FA_ASSET_TRACE_PUB.t_options_tbl;
   l_select_clause   varchar2(2000);
   l_stmt            varchar2(32767);
   l_tbl             varchar2(100);
   l_dist_tbl        t_col_tbl;
   l_tbl_cols        t_cc_cols;
   l_flex_num        number;
   l_idx             number;
   l_count           number :=0;
   l_cnt_stmt        number :=0;

   l_calling_fn      varchar2(40)  := 'fa_asset_trace_pkg.get_dist_info';

   CURSOR c_coa_segs IS
      SELECT APPLICATION_COLUMN_NAME, SEGMENT_NAME
      from fnd_id_flex_segments
      where application_id = 101
      and id_flex_code = 'GL#'
      AND ID_FLEX_NUM = l_flex_num;

BEGIN
   --
   l_appid := FND_GLOBAL.resp_appl_id;
   --
   l_idx:= 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'ASSET_COST_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'ASSET_CLEARING_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'WIP_COST_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'WIP_CLEARING_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'RESERVE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'REVAL_AMORT_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'REVAL_RESERVE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'BONUS_RESERVE_ACCT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'IMPAIR_EXPENSE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'IMPAIR_RESERVE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_CATEGORY_BOOKS';l_tbl_cols(l_idx).cCol := 'UNPLAN_EXPENSE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_ADJUSTMENTS';l_tbl_cols(l_idx).cCol := 'CODE_COMBINATION_ID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'XLA_AE_LINES';l_tbl_cols(l_idx).cCol := 'CODE_COMBINATION_ID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_DISTRIBUTION_HISTORY';l_tbl_cols(l_idx).cCol := 'CODE_COMBINATION_ID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl := 'FA_BOOK_CONTROLS';l_tbl_cols(l_idx).cCol := 'FLEXBUILDER_DEFAULTS_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';  l_tbl_cols(l_idx).cCol :='ASSET_COST_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='ASSET_CLEARING_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='DEPRN_EXPENSE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='DEPRN_RESERVE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='CIP_COST_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='CIP_CLEARING_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='NBV_RETIRED_GAIN_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='NBV_RETIRED_LOSS_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='PROCEEDS_SALE_GAIN_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='PROCEEDS_SALE_LOSS_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='COST_REMOVAL_GAIN_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='COST_REMOVAL_LOSS_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='PROCEEDS_SALE_CLEARING_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='COST_REMOVAL_CLEARING_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='REVAL_RSV_GAIN_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='REVAL_RSV_LOSS_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='DEFERRED_EXP_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='DEFERRED_RSV_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='DEPRN_ADJ_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='REVAL_AMORT_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='REVAL_RSV_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='BONUS_EXP_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='BONUS_RSV_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='IMPAIR_RESERVE_ACCOUNT_CCID';
   l_idx:= l_idx+ 1;
   l_tbl_cols(l_idx).cTbl :='FA_DISTRIBUTION_ACCOUNTS';l_tbl_cols(l_idx).cCol :='IMPAIR_EXPENSE_ACCOUNT_CCID';

   l_idx:= 0; --reset
   l_dist_tbl(1) := 'CODE_COMBINATION_ID';
   l_dist_tbl(2) := 'ACCOUNT_TYPE';
   l_dist_tbl(3) := 'ENABLED_FLAG';
   l_dist_tbl(4) := 'START_DATE_ACTIVE';
   l_dist_tbl(5) := 'END_DATE_ACTIVE';
   --l_dist_tbl(6) := 'ALTERNATE_CODE_COMBINATION_ID';

   l_flex_num :=  fa_cache_pkg.fazcbc_record.accounting_flex_structure;

   log(l_calling_fn, 'l_flex_num: '||l_flex_num);

   l_idx :=l_dist_tbl.count +1;
   FOR crec IN c_coa_segs LOOP
      l_dist_tbl(l_idx):=crec.application_column_name;
      l_idx:= l_idx+ 1;
   END LOOP;

   FOR i IN l_dist_tbl.first .. l_dist_tbl.last LOOP
      l_select_clause := l_select_clause||','||l_dist_tbl(i);
   END LOOP;

   l_select_clause := substr(l_select_clause,2,length(l_select_clause));
   if g_print_debug then
     fa_debug_pkg.add(l_calling_fn, 'getting', 'distribution info',
                               p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_select_clause', l_select_clause,
                               p_log_level_rec => p_log_level_rec);
   end if;

   l_idx:= 0;

   FOR i IN l_tbl_cols.first .. l_tbl_cols.last LOOP

     l_count := l_count +1;
     l_idx:= l_idx+ 1;
     if (l_count = 1) then
       l_options_tbl(l_idx).l_tbl := 'CODE_COMBINATIONS';
       l_options_tbl(l_idx).l_no_anchor := 'N';
     else
       l_options_tbl(l_idx).l_tbl := 'NH'||l_tbl_cols(i).cTbl||i;
       l_options_tbl(l_idx).l_no_anchor := 'Y';
       --l_options_tbl(l_idx).l_no_header := 'Y';
     end if;

     l_options_tbl(l_idx).l_gen_select   := 'N';
     l_options_tbl(l_idx).l_fullcol_list := 'Y';
     l_options_tbl(l_idx).l_col_order    := l_select_clause;
     l_options_tbl(l_idx).l_lc_header    := fparse_header('SOURCE_TABLE')||fparse_header('CCID_COLUMN');
     l_options_tbl(l_idx).l_leading_cols := fafsc(''''||l_tbl_cols(i).cTbl||'''')||fafsc(''''||l_tbl_cols(i).cCol||'''');

     IF l_tbl_cols(i).cTbl = 'FA_CATEGORY_BOOKS' THEN
       l_options_tbl(l_idx).l_add_clause := ' FROM GL_CODE_COMBINATIONS WHERE code_combination_id IN
             (SELECT '||l_tbl_cols(i).cCol||' from fa_category_books where book_type_code = '||''''||g_book||'''' ||
                ' and category_id in (SELECT DISTINCT ah.category_id FROM fa_asset_history ah
                WHERE ah.asset_id = '||g_asset_id||')) ORDER BY code_combination_id';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     ELSIF l_tbl_cols(i).cTbl ='FA_ADJUSTMENTS' THEN
       l_options_tbl(l_idx).l_add_clause := ' FROM GL_CODE_COMBINATIONS WHERE code_combination_id IN
             (SELECT distinct code_combination_id from fa_adjustments where book_type_code = '||''''||g_book||''''||
              ' and asset_id = '||g_asset_id||' and code_combination_id is not null) ORDER BY code_combination_id';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     ELSIF l_tbl_cols(i).cTbl ='XLA_AE_LINES' THEN
       l_options_tbl(l_idx).l_add_clause := ' FROM GL_CODE_COMBINATIONS WHERE code_combination_id IN
             (select distinct code_combination_id from XLA_AE_LINES where application_id in (140,'||l_appid||') and ae_header_id in
             (select ae_header_id from xla_ae_headers where application_id in (140,'||l_appid||') and event_id '||get_event_list
             ||')) ORDER BY code_combination_id';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     ELSIF l_tbl_cols(i).cTbl ='FA_DISTRIBUTION_HISTORY' THEN
       l_options_tbl(l_idx).l_add_clause := '  FROM GL_CODE_COMBINATIONS WHERE code_combination_id IN
             (SELECT code_combination_id FROM fa_distribution_history
              WHERE asset_id = '||g_asset_id||' AND transaction_header_id_out IS NULL) ORDER BY code_combination_id';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     ELSIF l_tbl_cols(i).cTbl = 'FA_BOOK_CONTROLS' THEN
       l_options_tbl(l_idx).l_add_clause := ' FROM GL_CODE_COMBINATIONS WHERE code_combination_id IN
             (SELECT FLEXBUILDER_DEFAULTS_CCID FROM fa_book_controls WHERE book_type_code = '||''''||g_book||''''||')';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     ELSIF l_tbl_cols(i).cTbl='FA_DISTRIBUTION_ACCOUNTS' THEN
       l_options_tbl(l_idx).l_lc_header    := l_options_tbl(l_idx).l_lc_header||fparse_header('DISTRIBUTION_ID');
       l_options_tbl(l_idx).l_leading_cols := l_options_tbl(l_idx).l_leading_cols||fafsc('DISTRIBUTION_ID');
       l_options_tbl(l_idx).l_add_clause := ' FROM GL_CODE_COMBINATIONS gcc, fa_distribution_accounts fda
             WHERE gcc.code_combination_id = fda.'||l_tbl_cols(i).cCol||' and fda.book_type_code = '||''''||g_book||''''||
             ' and fda.distribution_id IN (SELECT distribution_id FROM fa_distribution_history WHERE asset_id = '||g_asset_id||')
              ORDER BY code_combination_id';
       l_stmt := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
     END IF;

     EXECUTE IMMEDIATE l_stmt INTO l_cnt_stmt;
     if (l_cnt_stmt = 0) then
       l_options_tbl.delete(l_idx);
       l_idx:= l_idx - 1;
     end if;

   END LOOP;  -- FOR i IN l_tbl_cols.first...

   l_count :=0;
   l_dist_tbl.delete;

   if g_print_debug then
      fa_debug_pkg.add(l_calling_fn, 'getting', 'KEY FF info',
                               p_log_level_rec => p_log_level_rec);
   end if;

   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'KEY_FLEXFIELD_INFO';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   --l_options_tbl(l_idx).l_no_header    := 'N';
   l_options_tbl(l_idx).l_col_order    := 'SEG.SEGMENT_NUM,SEG.SEGMENT_NAME,SEG.APPLICATION_COLUMN_NAME,VAL.SEGMENT_ATTRIBUTE_TYPE,VAL.ATTRIBUTE_VALUE'
      ||',SEG.ENABLED_FLAG,SEG.REQUIRED_FLAG,SEG.DISPLAY_FLAG,SETS.FLEX_VALUE_SET_NAME,SEG.FLEX_VALUE_SET_ID,SEG.SECURITY_ENABLED_FLAG'
      ||',SETS.SECURITY_ENABLED_FLAG,STRU.FREEZE_FLEX_DEFINITION_FLAG,STRU.DYNAMIC_INSERTS_ALLOWED_FLAG,STRU.CROSS_SEGMENT_VALIDATION_FLAG';
   l_options_tbl(l_idx).l_lcs          := 'ID_FLEX_CODE';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('ID_FLEX_CODE');
   l_options_tbl(l_idx).l_leading_cols := fafsc('SEG.ID_FLEX_CODE');
   l_options_tbl(l_idx).l_num_cols     := 2;
   l_options_tbl(l_idx).l_add_clause := ' FROM FND_ID_FLEX_SEGMENTS_VL SEG, FND_FLEX_VALUE_SETS SETS, FND_SEGMENT_ATTRIBUTE_VALUES VAL,'
     ||' FA_BOOK_CONTROLS FABC, FND_ID_FLEX_STRUCTURES_VL STRU WHERE SEG.flex_value_set_id = SETS.flex_value_set_id(+)'
     ||' AND SEG.id_flex_code in (''LOC#'',''CAT#'',''KEY#'',''GL#'') AND SEG.id_flex_code = VAL.id_flex_code(+)'
	   ||' AND SEG.id_flex_num  = VAL.id_flex_num(+) AND SEG.application_column_name = VAL.application_column_name(+)'
     ||' AND VAL.attribute_value(+) = ''Y'' AND VAL.segment_attribute_type(+) <> ''GL_GLOBAL'' AND SEG.id_flex_num = FABC.accounting_flex_structure'
	   ||' AND FABC.book_type_code = '||'''' || g_book || ''''||' AND STRU.id_flex_code = SEG.id_flex_code AND STRU.id_flex_num = SEG.id_flex_num'
	   ||' AND STRU.application_id = SEG.application_id order by SEG.ID_FLEX_CODE,SEG.SEGMENT_NUM';

   l_count := g_options_tbl.count +1;

   --load global tbl.
   FOR i IN l_options_tbl.first .. l_options_tbl.last LOOP
      g_options_tbl(l_count) :=l_options_tbl(i);
      l_count := l_count + 1;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                               p_log_level_rec => p_log_level_rec);
      raise;

END get_dist_info;
--
PROCEDURE deprn_calc_info (p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_stmt                  varchar2(4000);
   l_cnt_stmt              varchar2(4000);
   l_select_clause         varchar2(4000);
   l_count                 number:=0;
   l_cols                  t_col_tbl;
   l_tbls                  t_col_tbl;
   l_var_tbls              t_col_tbl;
   l_tbl                   varchar2(100);
   l_method_cur            c_stmt;



   l_counter     NUMBER;
   l_idx         number;
   l_options_tbl FA_ASSET_TRACE_PUB.t_options_tbl;

   l_calling_fn  varchar2(80):= 'fa_asset_trace_pkg.deprn_calc_tbls';

BEGIN

   l_counter     := g_options_tbl.count +1;
   l_idx         := 0;

   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='CALENDAR';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_col_order    := 'CP.Period_Num,CP.Period_Name,cp.start_date,cp.end_date,'
     ||'ct.fiscal_year_name,ct.period_suffix_type,ct.number_per_fiscal_year,ct.description';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_calendar_types ct,fa_fiscal_year fy,fa_calendar_periods cp'||
     ' where CT.calendar_type = cp.calendar_type and cp.calendar_type = '||'''' ||g_deprn_calendar|| ''''||
     ' AND fy.fiscal_year_name = '||'''' ||g_fiscal_year_name|| ''''||
     ' and fy.fiscal_year BETWEEN '||(g_fiscal_year-1)||' AND '||g_fiscal_year||
     ' and fy.fiscal_year_name = ct.fiscal_year_name and cp.start_date >= fy.start_date '||
     ' and cp.end_date <= fy.end_date order by fy.fiscal_year, cp.period_num';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='CONVENTIONS';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_col_order    := 'CT.PRORATE_CONVENTION_CODE,CT.DESCRIPTION,CO.START_DATE,'
     ||'CO.END_DATE,CO.PRORATE_DATE,CT.DEPR_WHEN_ACQUIRED_FLAG';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_CONVENTIONS CO, FA_CONVENTION_TYPES CT, FA_FISCAL_YEAR FY '
     ||'WHERE FY.FISCAL_YEAR BETWEEN '||(g_fiscal_year-1)||' AND '||g_fiscal_year||
     ' AND FY.FISCAL_YEAR_NAME = '||'''' ||g_fiscal_year_name|| ''''||
     ' AND (CO.PRORATE_CONVENTION_CODE IN (select distinct PRORATE_CONVENTION_CODE from fa_books '||
     ' where asset_id = '||g_asset_id||' and book_type_code = '||'''' || g_book || ''''||') '||
     ' OR CO.PRORATE_CONVENTION_CODE in (select distinct RETIREMENT_PRORATE_CONVENTION from fa_retirements '||
     ' where asset_id = '||g_asset_id|| ' and book_type_code = '||'''' || g_book || ''''||')) '||
     ' AND CO.START_DATE BETWEEN FY.START_DATE AND FY.END_DATE '||
	 ' AND CO.PRORATE_CONVENTION_CODE = CT.PRORATE_CONVENTION_CODE ORDER BY CT.PRORATE_CONVENTION_CODE, CO.START_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          := 'BONUS_RULES';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_col_order    := 'br.Bonus_Rule,br.Start_Year,br.End_Year,br.Bonus_Rate * 100,brl.ONE_TIME_FLAG';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' from FA_BONUS_RATES br, FA_BONUS_RULES brl '||
     ' where BR.BONUS_RULE=BRL.BONUS_RULE and BR.BONUS_RULE IN (select distinct BONUS_RULE from fa_books '||
     ' where asset_id = '||g_asset_id||' and book_type_code = '||'''' || g_book || ''''||') '||
     ' order by BR.Bonus_Rule,BR.Start_Year';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_CEILINGS';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_col_order    := 'CT.CEILING_TYPE,CT.Currency_Code,CL.Ceiling_Name,CL.Start_Date,CL.End_Date,'
     ||'CL.Year_Of_Life,CL.Limit';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' FROM FA_CEILINGS CL, FA_CEILING_TYPES CT '
     ||' WHERE cl.ceiling_name = ct.ceiling_name AND (cl.ceiling_name in (select distinct Ceiling_Name '||
     ' from fa_books where asset_id = '||g_asset_id||' and book_type_code = '||'''' || g_book || ''''||') '
     ||' OR  cl.ceiling_name in (select Ceiling_Name from fa_category_book_defaults '||
     ' where category_id in (SELECT DISTINCT ah.category_id FROM fa_asset_history ah '||
     ' WHERE ah.asset_id = '||g_asset_id|| ') and book_type_code = '||'''' || g_book || ''''||'))';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='RATES';
   l_options_tbl(l_idx).l_gen_select   := 'N';
   l_options_tbl(l_idx).l_col_order    := 'mt.method_code,mt.name,mt.life_in_months,mt.stl_method_flag,'
     ||'mt.depreciate_lastyear_flag,rt.year,rt.period_placed_in_service,rt.rate';
   l_options_tbl(l_idx).l_fullcol_list := 'Y';
   l_options_tbl(l_idx).l_add_clause   := ' from fa_methods mt, fa_rates rt, fa_books bk, fa_calendar_periods cp'
     ||' where mt.method_id = rt.method_id and mt.method_code = bk.deprn_method_code and mt.life_in_months = bk.life_in_months'
     ||' and bk.asset_id = '||g_asset_id||' and bk.book_type_code = '||'''' || g_book || ''''||' and cp.calendar_type = '
	 ||'''' ||g_prorate_calendar|| ''''||' and bk.prorate_date between cp.start_date and cp.end_date'
     ||' and rt.PERIOD_PLACED_IN_SERVICE = cp.period_num order by mt.method_code, mt.life_in_months, rt.year';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_METHODS';
   l_options_tbl(l_idx).l_lcs          := 'METHOD_ID';
   l_options_tbl(l_idx).l_leading_cols := fafsc('METHOD_ID');
   l_options_tbl(l_idx).l_order_by     := 'METHOD_ID';
   l_options_tbl(l_idx).l_lc_header    := fparse_header('METHOD_ID');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'METHOD_CODE,NAME,LIFE_IN_MONTHS';
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_methods WHERE METHOD_CODE||to_char(nvl(LIFE_IN_MONTHS,99999))'
     ||' IN (select DEPRN_METHOD_CODE||to_char(nvl(LIFE_IN_MONTHS,99999)) from fa_books'
     ||' where book_type_code = '||'''' || g_book || ''''||' and asset_id = '||g_asset_id||')';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_DEPRN_BASIS_RULES';
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_deprn_basis_rules WHERE deprn_basis_rule_id IN (SELECT deprn_basis_rule_id'
     ||' FROM fa_methods WHERE METHOD_CODE||to_char(nvl(LIFE_IN_MONTHS,99999)) IN '
	 ||'(select DEPRN_METHOD_CODE||to_char(nvl(LIFE_IN_MONTHS,99999)) from fa_books where book_type_code = '
	 ||'''' || g_book || ''''||' and asset_id = '||g_asset_id||'))';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_FLAT_RATES';
   l_options_tbl(l_idx).l_add_clause   := ' From fa_flat_rates Where to_char(method_id) || to_char(basic_rate) in '
     ||'(SELECT to_char(mt.method_id) || to_char(basic_rate) FROM FA_METHODS mt, fa_books bk '
     ||'where mt.method_code = bk.deprn_method_code and nvl(mt.life_in_months,0) = nvl(bk.life_in_months,0) '
     ||'and bk.book_type_code = '||'''' || g_book || ''''||' and bk.asset_id = '||g_asset_id||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_FISCAL_YEAR';
   l_options_tbl(l_idx).l_lcs          := 'FISCAL_YEAR_NAME';
   l_options_tbl(l_idx).l_leading_cols := fafsc('FISCAL_YEAR_NAME');
   l_options_tbl(l_idx).l_lc_header    := fparse_header('FISCAL_YEAR_NAME');
   l_options_tbl(l_idx).l_num_cols     := 1;
   l_options_tbl(l_idx).l_col_order    := 'FISCAL_YEAR,START_DATE,END_DATE';
   l_options_tbl(l_idx).l_add_clause   := ' FROM fa_fiscal_year where fiscal_year_name = '||'''' ||g_fiscal_year_name|| ''''
     ||' and fiscal_year BETWEEN '||(g_fiscal_year-1)||' AND '||g_fiscal_year||' Order by FISCAL_YEAR, START_DATE';
   l_idx:= l_idx+ 1;
   l_options_tbl(l_idx).l_tbl          :='FA_FORMULAS';
   l_options_tbl(l_idx).l_add_clause   := ' From fa_formulas Where method_id in (SELECT mt.method_id '
     ||'FROM FA_METHODS mt, fa_books bk where mt.method_code = bk.deprn_method_code '
	 ||'and nvl(mt.life_in_months,0) = nvl(bk.life_in_months,0) and bk.book_type_code = '||'''' || g_book || ''''
	 ||' and bk.asset_id = '||g_asset_id||')';
   l_options_tbl(l_idx).l_cnt_stmt     := 'select count(1) '||l_options_tbl(l_idx).l_add_clause;

   --load global tbl.
   FOR i IN l_options_tbl.first .. l_options_tbl.last LOOP
      g_options_tbl(l_counter) :=l_options_tbl(i);
      l_counter := l_counter + 1;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn,
                               p_log_level_rec => p_log_level_rec);
      log(l_calling_fn, 'Exception, tbl: '||l_options_tbl(l_idx).l_tbl);
      raise;

END deprn_calc_info;
--
FUNCTION get_event_list RETURN VARCHAR2 IS

  l_appid          fnd_profile_option_values.level_value_application_id%type;
  l_event_list     VARCHAR2(32767) := ' in (';

  l_calling_fn  varchar2(80) := 'fa_asset_trace_pkg.get_event_list';

  Cursor get_events IS
  /* trx */
    select ev.event_id, en.entity_code
    from fa_transaction_headers th, xla_transaction_entities en, xla_events ev
    where th.book_type_code = g_book
    and th.asset_id         = g_asset_id
    and en.application_id  in (l_appid,140)
    and en.ledger_id        = g_sob_id
    and en.entity_code in ('MANUAL', 'TRANSACTIONS')
    and nvl(en.source_id_int_1, (-99)) = th.transaction_header_id
    and en.valuation_method            = g_book
    and ev.application_id              in (l_appid,140)
    and ev.entity_id                   = en.entity_id
    union /* dist-related */
    select ev.event_id, en.entity_code
    from fa_transaction_headers th, xla_transaction_entities en, xla_events ev
    where th.book_type_code = g_source_book
    and th.asset_id         = g_asset_id
    and th.transaction_type_code in ('UNIT ADJUSTMENT','TRANSFER OUT','TRANSFER','RECLASS')
    and en.application_id   in (l_appid,140)
    and en.ledger_id        = g_sob_id
    and en.entity_code in ('MANUAL', 'TRANSACTIONS')
    and nvl(en.source_id_int_1, (-99)) = th.transaction_header_id
    and en.valuation_method            = g_book
    and ev.application_id              in (l_appid,140)
    and ev.entity_id                   = en.entity_id
    union /* inter-asset */
    select ev.event_id, en.entity_code
    from fa_transaction_headers th, xla_transaction_entities en, xla_events ev
    where th.book_type_code   = g_book
    and th.asset_id           = g_asset_id
    and en.application_id     in (l_appid,140)
    and en.ledger_id          = g_sob_id
    and en.entity_code in ('MANUAL', 'INTER_ASSET_TRANSACTIONS')
    and nvl(en.source_id_int_1, (-99)) = th.trx_reference_id
    and ev.application_id              in (l_appid,140)
    and ev.entity_id                   = en.entity_id
    union  /* deprn */
    select ev.event_id, en.entity_code
    from xla_transaction_entities en, xla_events ev, fa_book_controls bc
    where bc.book_type_code   = g_book
    and en.application_id     in (l_appid,140)
    and en.ledger_id          = g_sob_id
    and en.entity_code in ('MANUAL', 'DEPRECIATION','DEFERRED_DEPRECIATION')
    and nvl(en.source_id_int_1, (-99)) = g_asset_id
    and nvl(en.source_id_char_1, '')   = bc.book_type_code
    and ev.application_id              in (l_appid,140)
    and ev.entity_id                   = en.entity_id;

BEGIN
  l_appid := FND_GLOBAL.resp_appl_id;
  if (l_appid = -1) then
     --must have been called from backend.  Assuming 140.
     l_appid := 140;
  end if;

  FOR e IN get_events LOOP
    l_event_list := l_event_list||e.event_id||',';
  END LOOP;
  --
  if length(l_event_list) > 5 then -- cursor returned something
    l_event_list := substr(l_event_list, 1, length(l_event_list) -1)||')';
  else --return some bogus unlikely value
    l_event_list := l_event_list || '-6741301)';
  end if;

  RETURN l_event_list;

EXCEPTION
    WHEN OTHERS THEN
      log(l_calling_fn,'l_event_list: '||l_event_list);
      raise;
END get_event_list;
--
PROCEDURE load_xla_info (p_banner         IN          varchar2,
                         x_retcode        OUT NOCOPY  NUMBER,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

  l_event_list     VARCHAR2(32767);
  l_tblcount       number;
  l_retcode        number;

  l_counter        NUMBER;
  l_idx            number;
  l_options_tbl    FA_ASSET_TRACE_PUB.t_options_tbl;
  l_col_exclusions FA_ASSET_TRACE_PUB.t_excl_tbl;
  l_appid          fnd_profile_option_values.level_value_application_id%type;

  l_calling_fn  varchar2(80) := 'fa_asset_trace_pkg.load_xla_info';

BEGIN

   l_counter     := g_options_tbl.count +1;
   l_idx         := 0;
   l_appid := FND_GLOBAL.resp_appl_id;
   if (l_appid = -1) then
     --must have been called from backend.  Assuming 140.
     l_appid := 140;
   end if;

   l_event_list := get_event_list;

   if (l_event_list <> ' in (-6741301)') then

     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_EVENTS';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'EVENT_ID,ENTITY_ID';
     l_options_tbl(l_idx).l_col_order    := 'EVENT_TYPE_CODE,EVENT_STATUS_CODE,PROCESS_STATUS_CODE,EVENT_DATE';
     l_options_tbl(l_idx).l_leading_cols := fafsc('EVENT_ID')||fafsc('ENTITY_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('EVENT_ID')||fparse_header('ENTITY_ID');
     l_options_tbl(l_idx).l_num_cols     := 2;
     l_options_tbl(l_idx).l_add_clause   := ' from XLA_EVENTS where application_id in (140,'||l_appid||') and event_id '||l_event_list;
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_TRANSACTION_ENTITIES';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_col_order    := 'ENTITY_CODE,VALUATION_METHOD';
     l_options_tbl(l_idx).l_lcs          := 'ENTITY_ID,LEDGER_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('ENTITY_ID')||fafsc('LEDGER_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('ENTITY_ID')||fparse_header('LEDGER_ID');
     l_options_tbl(l_idx).l_num_cols     := 2;
     l_options_tbl(l_idx).l_add_clause   := ' from XLA_TRANSACTION_ENTITIES where application_id in (140,'||l_appid||')'
           ||' and entity_id in (select entity_id from xla_events where event_id '||l_event_list||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_AE_HEADERS';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'AE_HEADER_ID,EVENT_ID,LEDGER_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('AE_HEADER_ID')||fafsc('EVENT_ID')||fafsc('LEDGER_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('AE_HEADER_ID')||fparse_header('EVENT_ID')||fparse_header('LEDGER_ID');
     l_options_tbl(l_idx).l_col_order    := 'EVENT_TYPE_CODE,ACCOUNTING_DATE,GL_TRANSFER_STATUS_CODE,GL_TRANSFER_DATE,'
           ||'JE_CATEGORY_NAME,ACCOUNTING_ENTRY_STATUS_CODE,ACCOUNTING_ENTRY_TYPE_CODE';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_options_tbl(l_idx).l_num_cols     := 3;
     l_options_tbl(l_idx).l_add_clause   := ' from XLA_AE_HEADERS where application_id in (140,'||l_appid||') and event_id '||l_event_list;
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_AE_LINES';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'AE_HEADER_ID,AE_LINE_NUM,LEDGER_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('AE_HEADER_ID')||fafsc('AE_LINE_NUM')||fafsc('LEDGER_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('AE_HEADER_ID')||fparse_header('AE_LINE_NUM')||fparse_header('LEDGER_ID');
     l_options_tbl(l_idx).l_col_order    := 'CODE_COMBINATION_ID,ENTERED_DR,ENTERED_CR,ACCOUNTED_DR,ACCOUNTED_CR,GL_TRANSFER_MODE_CODE,ACCOUNTING_CLASS_CODE';
     l_options_tbl(l_idx).l_num_cols     := 3;
     l_options_tbl(l_idx).l_add_clause   := ' from XLA_AE_LINES where application_id in (140,'||l_appid||')'
           ||' and ae_header_id in (select ae_header_id from xla_ae_headers where application_id in (140,'||l_appid||') and event_id '||l_event_list||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_DISTRIBUTION_LINKS';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'EVENT_ID,AE_HEADER_ID,AE_LINE_NUM';
     l_options_tbl(l_idx).l_leading_cols := fafsc('EVENT_ID')||fafsc('AE_HEADER_ID')||fafsc('AE_LINE_NUM');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('EVENT_ID')||fparse_header('AE_HEADER_ID')||fparse_header('AE_LINE_NUM');
     l_options_tbl(l_idx).l_num_cols     := 3;
     l_options_tbl(l_idx).l_add_clause   := ' from XLA_DISTRIBUTION_LINKS where application_id in (140,'||l_appid||') AND ae_header_id IN '
           ||'(SELECT ae_header_id FROM xla_ae_headers WHERE application_id in (140,'||l_appid||') AND event_id '||l_event_list||' )';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_ACCTG_METHOD_RULES_FVL';
     l_options_tbl(l_idx).l_schema       := 'APPS';
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'ACCTG_METHOD_RULE_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('ACCTG_METHOD_RULE_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('ACCTG_METHOD_RULE_ID');
     l_options_tbl(l_idx).l_num_cols     := 1;
     l_options_tbl(l_idx).l_add_clause   := ' FROM xla_acctg_method_rules_fvl where application_id in (140,'||l_appid||') and ACCOUNTING_METHOD_CODE in ' ||
        '(select SLA_ACCOUNTING_METHOD_CODE from gl_ledgers where ledger_id = '||g_sob_id||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_PRODUCT_RULES_FVL';
     l_options_tbl(l_idx).l_schema       := 'APPS';
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'PRODUCT_RULE_CODE';
     l_options_tbl(l_idx).l_leading_cols := fafsc('PRODUCT_RULE_CODE');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('PRODUCT_RULE_CODE');
     l_options_tbl(l_idx).l_num_cols     := 1;
     l_options_tbl(l_idx).l_add_clause   := ' from xla_product_rules_fvl where application_id in (140,'||l_appid||') and product_rule_code in '||
        '(select distinct product_rule_code from xla_ae_headers where application_id in (140,'||l_appid||') and event_id '||l_event_list||')';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'XLA_LEDGER_OPTIONS';
     l_options_tbl(l_idx).l_schema       := get_schema('XLA');
     l_options_tbl(l_idx).l_gen_select   := 'Y';
     l_options_tbl(l_idx).l_lcs          := 'APPLICATION_ID';
     l_options_tbl(l_idx).l_leading_cols := fafsc('APPLICATION_ID');
     l_options_tbl(l_idx).l_lc_header    := fparse_header('APPLICATION_ID');
     l_options_tbl(l_idx).l_num_cols     := 1;
     l_options_tbl(l_idx).l_add_clause   := ' from xla_ledger_options where (ledger_id = '||g_sob_id||' or ledger_id in (select target_ledger_id '||
        ' FROM gl_ledger_relationships WHERE primary_ledger_id = '||g_sob_id||' AND relationship_type_code <> ''NONE'' '||
        ' AND application_id IN (101,140) AND relationship_enabled_flag = ''Y'')) and application_id IN (101,140) order by APPLICATION_ID, LEDGER_ID';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;
     l_idx:= l_idx+ 1;
     l_options_tbl(l_idx).l_tbl          := 'GL_LEDGERS';
     l_options_tbl(l_idx).l_schema       := get_schema('SQLGL');
     l_options_tbl(l_idx).l_gen_select   := 'N';
     l_options_tbl(l_idx).l_fullcol_list := 'Y';
     l_options_tbl(l_idx).l_lc_header    := fparse_header('LEDGER_ID');
     l_options_tbl(l_idx).l_leading_cols := fafsc('LEDGER_ID');
     l_options_tbl(l_idx).l_col_order    := 'NAME,ACCOUNTED_PERIOD_TYPE,ALC_LEDGER_TYPE_CODE,ALLOW_INTERCOMPANY_POST_FLAG,CHART_OF_ACCOUNTS_ID,'||
        ' COMPLETE_FLAG,CONFIGURATION_ID,CURRENCY_CODE,IMPLICIT_ACCESS_SET_ID,LE_LEDGER_TYPE_CODE,LEDGER_CATEGORY_CODE,SLA_ACCOUNTING_METHOD_CODE,'||
        ' SLA_ACCOUNTING_METHOD_TYPE,SLA_ENTERED_CUR_BAL_SUS_CCID,SLA_SEQUENCING_FLAG,SLA_BAL_BY_LEDGER_CURR_FLAG,SLA_LEDGER_CUR_BAL_SUS_CCID';
     l_options_tbl(l_idx).l_add_clause   := ' from gl_ledgers where ledger_id = '||g_sob_id||' or ledger_id in (select target_ledger_id '||
        ' FROM gl_ledger_relationships WHERE primary_ledger_id = '||g_sob_id||' AND relationship_type_code <> ''NONE'' '||
        ' AND application_id IN (101,140) AND relationship_enabled_flag = ''Y'') order by ledger_id';
     l_options_tbl(l_idx).l_cnt_stmt     := 'Select count(1) '||l_options_tbl(l_idx).l_add_clause;

     --do exclusions
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'LAST_UPDATE_LOGIN';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'SOURCE_APPLICATION_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'APPLICATION_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'BUDGET_VERSION_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'ENCUMBRANCE_TYPE_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'USSGL_TRANSACTION_CODE';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'ACCOUNT_OVERLAY_SOURCE_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'ANALYTICAL_BALANCE_FLAG';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'BUSINESS_CLASS_CODE';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'CONTROL_BALANCE_FLAG';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'PACKET_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'PROGRAM_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'PROGRAM_APPLICATION_ID';
     l_idx:= l_idx+ 1;   l_col_exclusions(l_idx).cValue  := 'ROW_ID';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'SECURITY_ID%';        l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'SOURCE_ID_CHAR%';          l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'ATTRIBUTE%';     l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'CLOSE_ACCT%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'REFERENCE%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'COMPLETION_ACCT%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'DOC%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'UPG_TAX%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'UNROUNDED%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'APPLIED_TO%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'ALLOC_TO%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := 'TAX%';    l_col_exclusions(l_idx).cType := 'P';
     l_idx:= l_idx+ 1;
     l_col_exclusions(l_idx).cValue  := '%PARTY%';    l_col_exclusions(l_idx).cType := 'P';
     --
     FA_ASSET_TRACE_PUB.run_trace (p_opt_tbl       => l_options_tbl,
                                   p_exc_tbl       => l_col_exclusions,
                                   p_tdyn_head     => null,
                                   p_stmt          => null,
                                   p_sys_opt_tbl   => NULL,
                                   p_use_utl_file  => fa_asset_trace_pkg.g_use_utl_file,
                                   p_debug_flag    => g_print_debug,
                                   p_calling_prog  => p_banner,
                                   p_retcode       => x_retcode,
                                   p_log_level_rec => g_log_level_rec);

     log(l_calling_fn,'back in load_xla, p_retcode is '||x_retcode);
   else
     log(l_calling_fn,'No events found in SLA for this asset and book combination.');
     x_retcode := 1;
   end if; --length(l_event_list)

EXCEPTION
    WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                ,p_log_level_rec => p_log_level_rec);
       raise;

END load_xla_info;
--
PROCEDURE submit_subrequest(p_parent_request IN          NUMBER,
                            x_retcode        OUT NOCOPY  NUMBER,
                            x_errbuf         OUT NOCOPY  VARCHAR2) IS

  l_desc        VARCHAR2(100);
  l_sub_rule    varchar2(200);
  l_xla_reqID   number;
  l_Result      boolean;

  l_calling_fn  varchar2(80) := 'fa_asset_trace_pkg.submit_subrequest';

BEGIN

   l_desc := 'FATRACE - SLA Subrequest of '||p_parent_request;
   log(l_calling_fn, 'submit_request: '||l_desc);

   if (nvl(fa_asset_trace_pkg.g_use_utl_file, 'N') = 'N') then
     --do not use this method when calling from backend.
     l_xla_reqID := FND_REQUEST.SUBMIT_REQUEST(APPLICATION => 'OFA',
                                           PROGRAM     => 'FATRACE',
                                           DESCRIPTION => l_desc,
                                           ARGUMENT1   => g_book,
                                           ARGUMENT2   => to_char(g_asset_id));
     log(l_calling_fn, 'after fnd submit_request, l_xla_reqID: '||l_xla_reqID);
   end if;

   if (nvl(l_xla_reqID,99) <= 0)  then
     log(l_calling_fn, 'Failed to submit xla request.');
     x_errbuf  := fnd_message.get;
     x_retcode := 2;
   else
     l_sub_rule := 'tab.user_data.req_id = '||l_xla_reqID||' AND tab.user_data.req_type = ''S''';

     log(l_calling_fn,'Adding subscriber S'||to_char(l_xla_reqID));
     log(l_calling_fn,'l_sub_rule '||l_sub_rule);

     IF (NOT FA_ASSET_TRACE_PUB.add_subscriber (p_qname      => g_qname,
                                                p_subscriber => 'S'||to_char(l_xla_reqID),
                                                p_sub_rule   => l_sub_rule)) THEN
       log(l_calling_fn,'Failed to add subscriber.');
     END IF;
     g_payload := GAT_message_type(l_xla_reqID, 'S', g_book, g_asset_id, l_desc);
     IF (NOT enqueue_request) THEN
       log(l_calling_fn,'Failed to save message to the queue.');
     END IF;
     log(l_calling_fn, 'Successfully submitted xla request '||l_xla_reqID);
   end if;

EXCEPTION
    WHEN OTHERS THEN
       fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                ,p_log_level_rec => g_log_level_rec);
       x_retcode := 2;
       raise;

END submit_subrequest;
--
FUNCTION fafsc (p_col VARCHAR2) RETURN VARCHAR2 IS
BEGIN
   RETURN FA_ASSET_TRACE_PVT.fafsc(p_col);
END fafsc;
--
FUNCTION fparse_header(p_in_str VARCHAR2) RETURN VARCHAR2 IS
BEGIN
   RETURN FA_ASSET_TRACE_PVT.fparse_header(p_in_str);
END fparse_header;
--
FUNCTION enqueue_request RETURN BOOLEAN IS

  enqueue_options     DBMS_AQ.enqueue_options_t;
  message_properties  DBMS_AQ.message_properties_t;
  message_handle      RAW(16);

BEGIN
  DBMS_AQ.ENQUEUE(queue_name         => g_qname,
           	  enqueue_options    => enqueue_options,
           	  message_properties => message_properties,
           	  payload            => g_payload,
           	  msgid              => message_handle);
  COMMIT;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END enqueue_request;
--
FUNCTION dequeue_request (p_request  IN  VARCHAR2,
                          x_desc     OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

  dequeue_options     DBMS_AQ.dequeue_options_t;
  message_properties  DBMS_AQ.message_properties_t;
  message_handle      RAW(16);
  l_agent             sys.aq$_agent;
  l_req_type          VARCHAR2(1) :='P';

  no_messages         exception;
  pragma              exception_init(no_messages, -25228);
  no_agent            exception;
  pragma              exception_init(no_agent, -24047);
  no_subscriber       exception;
  pragma              exception_init(no_agent, -24035);

  l_calling_fn  varchar2(80) := 'fa_asset_trace_pkg.dequeue_request';

BEGIN
  dequeue_options.wait := DBMS_AQ.NO_WAIT;
  dequeue_options.consumer_name := p_request;
  dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE;

  begin
    LOOP
      DBMS_AQ.DEQUEUE(queue_name         => g_qname,
                      dequeue_options    => dequeue_options,
                      message_properties => message_properties,
                      payload            => g_payload,
                      msgid              => message_handle);
      l_req_type := g_payload.req_type;
      x_desc     := g_payload.l_desc;
      dequeue_options.navigation := DBMS_AQ.NEXT_MESSAGE;
    END LOOP;
    --remove subscriber.
    l_agent := sys.aq$_agent(p_request,null,null);
    dbms_aqadm.remove_subscriber(queue_name => g_qname, subscriber => l_agent);
    COMMIT;
  exception
    WHEN no_messages THEN
      log(l_calling_fn,'Queue is empty.');
      COMMIT;
    WHEN no_agent THEN
      log(l_calling_fn,'no agent '||p_request);
      COMMIT;
    WHEN no_subscriber THEN
      log(l_calling_fn,'No such subscriber as '||p_request);
      COMMIT;
  end;

  -- Just in case something happened to the initialized value...
  if (l_req_type is null) then
    l_req_type :='P';
  end if;

  log(l_calling_fn,'returning l_req_type is '||l_req_type);
  log(l_calling_fn,'returning p_desc is '||x_desc);

  RETURN l_req_type;

EXCEPTION
  WHEN others THEN
      log(l_calling_fn,'Unexpected error in dequeue.');
      COMMIT;

END dequeue_request;
--
--Used for debugging.
--
PROCEDURE prt_opt_tbl (p_options_tbl  FA_ASSET_TRACE_PUB.t_options_tbl) IS

BEGIN

  for i in p_options_tbl.first .. p_options_tbl.last loop
    log('prt_opt_tbl',p_options_tbl(i).l_tbl);
    log('prt_opt_tbl',p_options_tbl(i).l_schema);
    log('prt_opt_tbl',p_options_tbl(i).l_lcs);
    log('prt_opt_tbl',p_options_tbl(i).l_leading_cols);
    log('prt_opt_tbl',p_options_tbl(i).l_order_by);
    log('prt_opt_tbl',p_options_tbl(i).l_lc_header);
    log('prt_opt_tbl',p_options_tbl(i).l_num_cols);
    log('prt_opt_tbl',p_options_tbl(i).l_col_order);
    log('prt_opt_tbl',p_options_tbl(i).l_fullcol_list);
    log('prt_opt_tbl',p_options_tbl(i).l_gen_select);
    log('prt_opt_tbl',p_options_tbl(i).l_no_header);
    log('prt_opt_tbl',p_options_tbl(i).l_no_anchor);
    log('prt_opt_tbl',p_options_tbl(i).l_add_clause);
    log('prt_opt_tbl',p_options_tbl(i).l_cnt_stmt);
  end loop;

END prt_opt_tbl;
--
FUNCTION get_schema (p_app_short_name  VARCHAR2) RETURN VARCHAR2 IS

 l_schema          varchar2(50);
 l_status          varchar2(100);
 l_industry        varchar2(100);
 schema_err        exception;

 l_calling_fn  varchar2(80) := 'fa_asset_trace_pkg.get_schema';

BEGIN

  -- Get schema
  if not (fnd_installation.get_app_info (
                 application_short_name => p_app_short_name,
                 status                 => l_status,
                 industry               => l_industry,
                 oracle_schema          => l_schema)) then
     raise schema_err;
  end if;

  RETURN l_schema;

EXCEPTION
   WHEN schema_err THEN
      log(l_calling_fn, 'Error getting schema for '||p_app_short_name);
      raise;
   WHEN OTHERS THEN
      log(l_calling_fn, 'Unexpected Error');
      raise;

END get_schema;
--
PROCEDURE log(p_calling_fn     IN  VARCHAR2,
              p_msg            IN  VARCHAR2 default null,
              p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

BEGIN

  FA_ASSET_TRACE_PVT.LOG(p_calling_fn,p_msg,g_log_level_rec);

END log;
--
END FA_ASSET_TRACE_PKG;

/
