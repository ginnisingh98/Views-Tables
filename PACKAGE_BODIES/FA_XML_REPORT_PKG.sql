--------------------------------------------------------
--  DDL for Package Body FA_XML_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XML_REPORT_PKG" AS
/* $Header: FAXREXTB.pls 120.9.12010000.4 2010/05/11 11:29:45 gigupta noship $ */

   g_print_debug boolean := fa_cache_pkg.fa_print_debug;

   G_PKG_NAME          CONSTANT VARCHAR2(30) := 'FA_XML_REPORT_PKG';
   G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
   G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
   G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
   G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
   G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
   G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

   G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
   G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
   G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
   G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
   G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
   G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
   G_MODULE_NAME           CONSTANT VARCHAR2(80) := 'FA_XML_REPORT_PKG';



PROCEDURE clob_to_file
        (p_xml_clob           IN CLOB) IS

l_clob_size                NUMBER;
l_offset                   NUMBER;
l_chunk_size               INTEGER;
l_chunk                    VARCHAR2(32767);
l_log_module               VARCHAR2(240);

BEGIN


   l_clob_size := dbms_lob.getlength(p_xml_clob);

   IF (l_clob_size = 0) THEN
      RETURN;
   END IF;

   l_offset     := 1;
   l_chunk_size := 3000;

   WHILE (l_clob_size > 0) LOOP
      l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);
      fnd_file.put
         (which     => fnd_file.output
         ,buff      => l_chunk);

      l_clob_size := l_clob_size - l_chunk_size;
      l_offset := l_offset + l_chunk_size;
   END LOOP;

   fnd_file.new_line(fnd_file.output,1);

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;

END clob_to_file;


PROCEDURE put_encoding(code     IN VARCHAR2) IS
BEGIN

  if (code = 'UTF-8') then
    fnd_file.put_line(fnd_file.output, '<?xml version = ''1.0'' encoding = ''UTF-8''?>');
    fnd_file.new_line(fnd_file.output,1);
  end if;

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;


PROCEDURE put_starttag(tag_name         IN VARCHAR2) IS
BEGIN

  fnd_file.put_line(fnd_file.output, '<'||tag_name||'>');
  fnd_file.new_line(fnd_file.output,1);

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;

PROCEDURE put_endtag(tag_name   IN VARCHAR2) IS
BEGIN

  fnd_file.put_line(fnd_file.output, '</'||tag_name||'>');
  fnd_file.new_line(fnd_file.output,1);

EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;

PROCEDURE put_element(tag_name  IN VARCHAR2,
                      value     IN VARCHAR2) IS
BEGIN

  fnd_file.put(fnd_file.output, '<'||tag_name||'>');
  fnd_file.put(fnd_file.output, '<![CDATA[');
  fnd_file.put(fnd_file.output, value);
  fnd_file.put(fnd_file.output, ']]>');
  fnd_file.put_line(fnd_file.output, '</'||tag_name||'>');


EXCEPTION

    WHEN OTHERS then
      APP_EXCEPTION.RAISE_EXCEPTION;

END;


PROCEDURE asset_impairment_report(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_book_type_code   IN         VARCHAR2, -- req
                        p_set_of_books_id  IN         NUMBER,   -- req
                        p_period_counter   IN         NUMBER,   -- req
                        p_impairment_id    IN         NUMBER,   -- opt
                        p_cash_gen_unit_id IN         NUMBER,   -- opt
                        p_request_id       IN         NUMBER, -- opt, not displayed
                        p_status           IN         VARCHAR2 ) IS  -- opt, not displayed

l_qryCtx                DBMS_XMLGEN.ctxHandle;
l_result_clob           CLOB;
l_calling_fn            varchar2(200);
l_debug_info            varchar2(200);

l_report_name           varchar2(80) := 'Asset Impairment Report';
l_currency_code         varchar2(15);
l_sob_name              varchar2(30);
l_period_name           varchar2(30);
l_reporting_flag        varchar2(1);
l_reporting_suffix      varchar2(30);
l_orig_set_of_books_id  number(15);
l_orig_currency_context varchar2(15);

l_impairment_count      number;
l_asset_count           number;
l_temp_asset_count      number;


r_CASH_GENERATING_UNIT  varchar2(30);
r_IMPAIRMENT_DATE       date;
r_NET_SELLING_PRICE     number;
r_VALUE_IN_USE          number;
r_GOODWILL_AMOUNT       number;
r_ASSET_NUMBER          varchar2(15);
r_IMPAIRMENT_ID         number(15);
r_IMPAIRMENT_ID_text    varchar2(30);
l_imp_description varchar2(240);
l_imp_date date;
/*Bug# 9182681 */
r_CGU_id                  number;
r_CASH_GENERATING_UNIT_id number;
l_proc_flag               number := 0;

BEGIN

  l_calling_fn := 'FA_XML_REPORT_PKG.asset_impairment_report';

  FA_SRVR_MSG.Init_Server_Message;
  FA_DEBUG_PKG.Initialize;

  if g_print_debug then
     fa_debug_pkg.add(l_calling_fn, 'milestone', 'START....');
     fa_debug_pkg.add(l_calling_fn, 'substrb(userenv(''CLIENT_INFO''),45,10)', substrb(userenv('CLIENT_INFO'),45,10));
  end if;

  -- save the orignal set of books id
  l_orig_currency_context :=  substrb(userenv('CLIENT_INFO'),45,10);

  if g_print_debug then
     fa_debug_pkg.add(l_calling_fn, 'milestone', '1.1');
  end if;

  fnd_profile.get('GL_SET_OF_BKS_ID',l_orig_set_of_books_id);

  -- set the given set of books id for MRC_V
  fnd_client_info.set_currency_context (to_char(p_set_of_books_id));

  -- get the book type code P,R or N
  if not fa_cache_pkg.fazcsob
            (x_set_of_books_id   => p_set_of_books_id
            ,x_mrc_sob_type_code => l_reporting_flag)
            then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if l_reporting_flag = 'R' then
    l_reporting_suffix := 'FA_MC_ITF_IMPAIRMENTS';
  else
    l_reporting_suffix := 'FA_ITF_IMPAIRMENTS';
  end if;

  if g_print_debug then
     fa_debug_pkg.add(l_calling_fn, 'milestone', '1.5');
  end if;


  l_debug_info := 'Resolve input parameters...';

  declare

    cursor c_currency (c_sob_id number) is
      select sob.currency_code
            ,sob.name
      from gl_sets_of_books sob
      where sob.set_of_books_id = c_sob_id;

    cursor c_period (c_book varchar2, c_period_counter number) is
      select period_name
      from fa_deprn_periods
      where book_type_code = c_book
        and period_counter = c_period_counter;
-- Bug#6666666 SORP Cursor c_imp and related attributes added for SORP
        cursor c_imp(c_impairment_id number) is
          select description,
          impairment_date
          from FA_IMPAIRMENTS
          where impairment_id = c_impairment_id;

  begin

    open c_currency(p_set_of_books_id);
    fetch c_currency into l_currency_code, l_sob_name;
    close c_currency;

    open c_period(p_book_type_code, p_period_counter);
    fetch c_period into l_period_name;
    close c_period;

        open c_imp(p_impairment_id);
        fetch c_imp into l_imp_description,l_imp_date;
        close c_imp;

  exception
    when others then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end;


  l_debug_info := 'Select the main sql...';

  put_encoding('UTF-8');
  put_starttag('IMPAIRMENT_REPORT');
  put_starttag('IMPAIRMENT_SET');

  l_impairment_count := 0;
  l_asset_count := 0;

  if g_print_debug then
     fa_debug_pkg.add(l_calling_fn, 'milestone', '2');
  end if;


  declare

    cursor c_master is
                SELECT CGU.CASH_GENERATING_UNIT
                      ,CGU.CASH_GENERATING_UNIT_ID /*Bug# 9182681 */
                      ,IMP.IMPAIRMENT_DATE
                      ,IMP.NET_SELLING_PRICE
                      ,IMP.VALUE_IN_USE
                      ,IMP.GOODWILL_AMOUNT
                      ,AD.ASSET_NUMBER
                      ,IMP.IMPAIRMENT_ID
                FROM FA_IMPAIRMENTS     IMP
                    ,FA_CASH_GEN_UNITS  CGU
                    ,FA_ADDITIONS_B     AD
                WHERE IMP.CASH_GENERATING_UNIT_ID = CGU.CASH_GENERATING_UNIT_ID(+)
                  AND IMP.GOODWILL_ASSET_ID       = AD.ASSET_ID(+)
                  AND IMP.BOOK_TYPE_CODE          = p_book_type_code
                  AND IMP.PERIOD_COUNTER_IMPAIRED = p_period_counter
                  AND IMP.REQUEST_ID              = nvl(p_request_id, IMP.REQUEST_ID)
--                AND CGU.CASH_GENERATING_UNIT_ID = nvl(p_cash_gen_unit_id, CGU.CASH_GENERATING_UNIT_ID)          -- bug# 5893164
                  AND IMP.STATUS                  = nvl(p_status, 'POSTED')
                  AND IMP.IMPAIRMENT_ID           = nvl(p_impairment_id,IMP.IMPAIRMENT_ID); --Bug#8539194

    cursor c_master_mrc is
                SELECT CGU.CASH_GENERATING_UNIT
                      ,CGU.CASH_GENERATING_UNIT_ID
                      ,IMP.IMPAIRMENT_DATE
                      ,IMP.NET_SELLING_PRICE
                      ,IMP.VALUE_IN_USE
                      ,IMP.GOODWILL_AMOUNT
                      ,AD.ASSET_NUMBER
                      ,IMP.IMPAIRMENT_ID
                FROM FA_MC_IMPAIRMENTS IMP
                    ,FA_CASH_GEN_UNITS    CGU
                    ,FA_ADDITIONS_B       AD
                WHERE IMP.CASH_GENERATING_UNIT_ID = CGU.CASH_GENERATING_UNIT_ID(+)
                  AND IMP.GOODWILL_ASSET_ID       = AD.ASSET_ID(+)
                  AND IMP.BOOK_TYPE_CODE          = p_book_type_code
                  AND IMP.PERIOD_COUNTER_IMPAIRED = p_period_counter
                  AND IMP.REQUEST_ID              = nvl(p_request_id, IMP.REQUEST_ID)
--                AND CGU.CASH_GENERATING_UNIT_ID = nvl(p_cash_gen_unit_id, CGU.CASH_GENERATING_UNIT_ID)            -- bug# 5893164
                  AND IMP.STATUS                  = nvl(p_status, 'POSTED')
                  AND IMP.IMPAIRMENT_ID           = nvl(p_impairment_id,IMP.IMPAIRMENT_ID);


  begin

    if l_reporting_flag = 'R' then
      OPEN c_master_mrc;
    else
      OPEN c_master;
    end if;


    LOOP
      <<skip_loop>> /*Bug# 9182681 */
      if g_print_debug then
         fa_debug_pkg.add(l_calling_fn, 'milestone', '3.1');
      end if;

      if l_reporting_flag = 'R' then
        FETCH c_master_mrc into
                 r_CASH_GENERATING_UNIT
                ,r_CASH_GENERATING_UNIT_id /*Bug# 9182681 */
                ,r_IMPAIRMENT_DATE
                ,r_NET_SELLING_PRICE
                ,r_VALUE_IN_USE
                ,r_GOODWILL_AMOUNT
                ,r_ASSET_NUMBER
                ,r_IMPAIRMENT_ID;

        EXIT when c_master_mrc%NOTFOUND;

      else

        if g_print_debug then
           fa_debug_pkg.add(l_calling_fn, 'milestone', '3.2');
        end if;

        FETCH c_master into
                 r_CASH_GENERATING_UNIT
                ,r_CASH_GENERATING_UNIT_id
                ,r_IMPAIRMENT_DATE
                ,r_NET_SELLING_PRICE
                ,r_VALUE_IN_USE
                ,r_GOODWILL_AMOUNT
                ,r_ASSET_NUMBER
                ,r_IMPAIRMENT_ID;

        EXIT when c_master%NOTFOUND;

        if g_print_debug then
           fa_debug_pkg.add(l_calling_fn, 'milestone', '3.3');
        end if;

      end if;
      /*Bug# 9182681 */
      if l_proc_flag = 0 and r_CASH_GENERATING_UNIT is null then
         l_proc_flag := 1;
      elsif r_CASH_GENERATING_UNIT is null then
         goto skip_loop;
      end if;
      l_impairment_count := l_impairment_count + 1;

      put_starttag('IMPAIRMENT_RECORD');

      put_element('CASH_GENERATING_UNIT',r_CASH_GENERATING_UNIT);
      put_element('IMPAIRMENT_DATE',r_IMPAIRMENT_DATE);
      put_element('H_NET_SELLING_PRICE',r_NET_SELLING_PRICE);
      put_element('H_VALUE_IN_USE',r_VALUE_IN_USE);
      put_element('GOODWILL_AMOUNT',r_GOODWILL_AMOUNT);
      put_element('ASSET_NUMBER',r_ASSET_NUMBER);
      put_element('IMPAIRMENT_ID',r_IMPAIRMENT_ID);

      if r_IMPAIRMENT_ID is null then
        r_IMPAIRMENT_ID_text := 'ITF.IMPAIRMENT_ID';
      else
        r_IMPAIRMENT_ID_text := r_IMPAIRMENT_ID;
      end if;
      /*Bug# 9182681 */
      if r_CASH_GENERATING_UNIT is null then
        r_CGU_id := -99;
      else
        r_CGU_id := r_CASH_GENERATING_UNIT_id;
      end if;
     -- Bug#6666666 SORP Start
     /*Bug# 9182681 - Modified query to group by CGU*/
      l_qryCtx := DBMS_XMLGEN.newContext(
             'SELECT AD.ASSET_NUMBER
                    ,ITF.COST
                    ,(ITF.COST - ITF.DEPRN_RESERVE - ITF.impairment_reserve) NEW_NBV
                    ,(ITF.COST - ITF.DEPRN_RESERVE - ITF.impairment_reserve + ITF.IMPAIRMENT_AMOUNT + NVL(reval_reserve_adj_amount,0) ) OLD_NBV
                    ,(ITF.COST - ITF.DEPRN_RESERVE - ITF.impairment_reserve + ITF.IMPAIRMENT_AMOUNT ) NET_BOOK_VALUE
                    ,ITF.IMPAIRMENT_AMOUNT
                    ,ITF.impair_class,
                     ITF.reason,
                     ITF.REVAL_RESERVE_ADJ_AMOUNT,
                     ITF.impair_loss_acct,
                     ITF.split_impair_flag,
                     ITF.split1_impair_class,
                     ITF.split1_reason,
                     ITF.SPLIT1_REVAL_RESERVE,
                     ITF.split1_loss_acct,
                     ITF.split1_loss_amount,
                     ITF.split2_impair_class,
                     ITF.split2_reason,
                     ITF.SPLIT2_REVAL_RESERVE,
                     ITF.split2_loss_acct,
                     ITF.split2_loss_amount,
                     ITF.split3_impair_class,
                     ITF.split3_reason,
                     ITF.SPLIT3_REVAL_RESERVE,
                     ITF.split3_loss_acct,
                     ITF.split3_loss_amount
		    ,ITF.NET_SELLING_PRICE NET_SELLING_PRICE
                    ,ITF.VALUE_IN_USE VALUE_IN_USE
              FROM   '||l_reporting_suffix||' ITF
                    ,FA_ADDITIONS_B AD
              WHERE ITF.ASSET_ID = AD.ASSET_ID
                AND ITF.BOOK_TYPE_CODE = '''||p_book_type_code||'''
                AND NVL(ITF.cash_generating_unit_id,-99) = '''||r_CGU_id||'''
                AND ITF.REQUEST_ID = nvl( '''||p_request_id||''', ITF.REQUEST_ID)
                AND EXISTS
                    (SELECT 1 FROM FA_IMPAIRMENTS IMP
                     WHERE  IMP.IMPAIRMENT_ID = ITF.IMPAIRMENT_ID
                     AND    IMP.PERIOD_COUNTER_IMPAIRED = '''||p_period_counter||'''
                     AND    IMP.STATUS = nvl( '''||p_status||''', ''POSTED''))
              ORDER BY AD.ASSET_NUMBER'
                );
      -- Bug#6666666 SORP END
      DBMS_XMLGEN.setRowSetTag(l_qryCtx,'ASSET_SET');
      DBMS_XMLGEN.setRowTag(l_qryCtx, 'ASSET_RECORD');
-- setBindValue doesn't work for 11i
--
      l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
      l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
      l_temp_asset_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
      l_asset_count := l_asset_count + l_temp_asset_count;
      DBMS_XMLGEN.closeContext(l_qryCtx);
      clob_to_file(l_result_clob);

      put_endtag('IMPAIRMENT_RECORD');

    END LOOP;

    if l_reporting_flag = 'R' then
      CLOSE c_master_mrc;
    else
      CLOSE c_master;
    end if;

  end;

  put_endtag('IMPAIRMENT_SET');

  put_starttag('SETUP');
  put_element('REPORT_NAME',l_report_name);
  put_element('BOOK_TYPE_CODE',p_book_type_code);
  put_element('SET_OF_BOOKS_ID',p_set_of_books_id);
  put_element('SET_OF_BOOKS_NAME',l_sob_name);
  put_element('CURRENCY_CODE',l_currency_code);
  put_element('PERIOD_COUNTER',p_period_counter);
  put_element('PERIOD_NAME',l_period_name);
  put_element('IMPAIRMENT_ID',p_impairment_id);
  put_element('CASH_GENERATING_UNIT_ID',p_cash_gen_unit_id);
  put_element('REQUEST_ID',p_request_id);
  put_element('IMPAIRMENT_DESCRIPTION',l_imp_description);
  put_element('IMPAIRMENT_DATE',r_IMPAIRMENT_DATE); /*Bug#9000114 */

  put_element('IMPAIRMENT_COUNT',to_char(l_impairment_count));
  put_element('ASSET_COUNT',to_char(l_asset_count));
  put_endtag('SETUP');

  put_endtag('IMPAIRMENT_REPORT');

  -- set back to original environment when the procedure is finished
  fnd_client_info.set_currency_context (l_orig_currency_context);
  fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);

EXCEPTION

    WHEN OTHERS then

      if (g_print_debug) then
        fa_debug_pkg.add(l_calling_fn,
           'l_debug_info',
            l_debug_info);
        fa_debug_pkg.add(l_calling_fn,
           'SQLERRM',
            substr(SQLERRM, 1, 200));
      end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn || ':' || l_debug_info);

      fa_srvr_msg.add_sql_error
          (calling_fn => l_calling_fn);

      -- set back to original environment when the procedure is finished
      fnd_client_info.set_currency_context (l_orig_currency_context);
      fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);

      APP_EXCEPTION.RAISE_EXCEPTION;

END asset_impairment_report;

----

PROCEDURE list_assets_by_cash_gen(
                        errbuf             OUT NOCOPY VARCHAR2,
                        retcode            OUT NOCOPY NUMBER,
                        p_book_type_code   IN         VARCHAR2,
                        p_set_of_books_id  IN         NUMBER,
                        p_cash_gen_unit_id IN         NUMBER,
                        p_asset_id         IN         NUMBER ) IS

l_qryCtx                DBMS_XMLGEN.ctxHandle;
l_result_clob           CLOB;
l_calling_fn            varchar2(200);
l_debug_info            varchar2(200);

l_report_name           varchar2(80) := 'List Assets by Cash Generating Unit Report';
l_currency_code         varchar2(15);
l_sob_name              varchar2(30);
--l_period_counter      number(15);
l_reporting_flag        varchar2(1);
l_reporting_suffix      varchar2(10);
l_fa_books_tb_name      varchar2(30);
l_fa_dpr_sum_tb_name    varchar2(30);
l_orig_set_of_books_id  number(15);
l_orig_currency_context varchar2(15);

l_unit_count            number;
l_asset_count           number;
l_temp_asset_count      number;


r_cash_gen_unit         varchar2(30);
r_cash_gen_unit_id      number(15);
r_cash_gen_unit_id_text varchar2(30);
r_asset_id_text         varchar2(30);


BEGIN


  l_calling_fn := 'FA_XML_REPORT_PKG.list_assets_by_cash_gen';

  FA_SRVR_MSG.Init_Server_Message;
  FA_DEBUG_PKG.Initialize;

  -- save the orignal set of books id
  l_orig_currency_context :=  substrb(userenv('CLIENT_INFO'),45,10);
  fnd_profile.get('GL_SET_OF_BKS_ID',l_orig_set_of_books_id);

  -- set the given set of books id for MRC_V
  fnd_client_info.set_currency_context (to_char(p_set_of_books_id));

  -- get the book type code P,R or N
  if not fa_cache_pkg.fazcsob
            (x_set_of_books_id   => p_set_of_books_id
            ,x_mrc_sob_type_code => l_reporting_flag)
            then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if l_reporting_flag = 'R' then
    l_fa_books_tb_name := 'fa_mc_books';
    l_fa_dpr_sum_tb_name := 'fa_mc_deprn_summary';
  else
    l_fa_books_tb_name := 'fa_books';
    l_fa_dpr_sum_tb_name := 'fa_deprn_summary';
  end if;


  l_debug_info := 'Resolve input parameters...';

  declare

    cursor c_currency (c_sob_id number) is
      select sob.currency_code
            ,sob.name
      from gl_sets_of_books sob
      where sob.set_of_books_id = c_sob_id;

  begin

    open c_currency(p_set_of_books_id);
    fetch c_currency into l_currency_code, l_sob_name;
    close c_currency;

  exception
    when others then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end;


  l_debug_info := 'Select the main sql...';

  put_encoding('UTF-8');
  put_starttag('LIST_ASSETS_REPORT');
  put_starttag('CASH_GEN_UNIT_SET');

  l_unit_count := 0;
  l_asset_count := 0;

  declare

    cursor c_master is
       select cash_generating_unit
             ,cgu.cash_generating_unit_id
       from   fa_cash_gen_units cgu
       where  cgu.book_type_code = p_book_type_code
         and  cgu.cash_generating_unit_id = nvl(p_cash_gen_unit_id, cgu.cash_generating_unit_id)
         and  cgu.cash_generating_unit_id
              in (select bk.cash_generating_unit_id
                  from fa_books bk
                  where bk.book_type_code = p_book_type_code
                    and bk.transaction_header_id_out is null
                    and bk.asset_id = nvl(p_asset_id, bk.asset_id)
                 );

    cursor c_master_mrc is
       select cash_generating_unit
             ,cgu.cash_generating_unit_id
       from   fa_cash_gen_units cgu
       where  cgu.book_type_code = p_book_type_code
         and  cgu.cash_generating_unit_id = nvl(p_cash_gen_unit_id, cgu.cash_generating_unit_id)
         and  cgu.cash_generating_unit_id
              in (select bk.cash_generating_unit_id
                  from fa_mc_books bk
                  where bk.book_type_code = p_book_type_code
                    and bk.transaction_header_id_out is null
                    and bk.asset_id = nvl(p_asset_id, bk.asset_id)
                 );


  begin

    if l_reporting_flag = 'R' then
      OPEN c_master_mrc;
    else
      OPEN c_master;
    end if;


    LOOP

      if l_reporting_flag = 'R' then
        FETCH c_master_mrc into
                 r_cash_gen_unit
                ,r_cash_gen_unit_id;

        EXIT when c_master_mrc%NOTFOUND;

      else
        FETCH c_master into
                 r_cash_gen_unit
                ,r_cash_gen_unit_id;

        EXIT when c_master%NOTFOUND;

      end if;

      l_unit_count := l_unit_count + 1;

      put_starttag('CASH_GEN_UNIT_RECORD');

      put_element('CASH_GENERATING_UNIT',r_cash_gen_unit);
      put_element('CASH_GENERATING_UNIT_ID',r_cash_gen_unit_id);

      if r_cash_gen_unit_id is null then
        r_cash_gen_unit_id_text := 'bk.cash_generating_unit_id';
      else
        r_cash_gen_unit_id_text := to_char(r_cash_gen_unit_id);
      end if;

      if p_asset_id is null then
        r_asset_id_text := 'bk.asset_id';
      else
        r_asset_id_text := to_char(p_asset_id);
      end if;

      l_qryCtx := DBMS_XMLGEN.newContext(
        'select ad.asset_number as asset_number
                ,bk.cost as cost
                ,bk.cost - ds.deprn_reserve - ds.impairment_reserve as net_book_value
                ,ds.impairment_reserve as accumulated_impairment
                ,ds.ytd_impairment as ytd_impairment
        from fa_additions_b ad
            ,'||l_fa_books_tb_name||' bk
            ,'||l_fa_dpr_sum_tb_name||' ds
        where bk.book_type_code = '''||p_book_type_code||'''
          and ds.book_type_code = bk.book_type_code
          and bk.asset_id = ad.asset_id
          and bk.asset_id = ds.asset_id
          and bk.cash_generating_unit_id = '||r_cash_gen_unit_id_text||'
          and bk.asset_id = '||r_asset_id_text||'
          and bk.transaction_header_id_out is null
          and ds.period_counter =
                 (select max(period_counter)
                  from '||l_fa_dpr_sum_tb_name||' ds2
                  where ds2.book_type_code = '''||p_book_type_code||'''
                    and ds2.asset_id = bk.asset_id
                 )
        order by ad.asset_number'
          );

      DBMS_XMLGEN.setRowSetTag(l_qryCtx,'ASSET_SET');
      DBMS_XMLGEN.setRowTag(l_qryCtx, 'ASSET_RECORD');
-- fyi: setBindValue doesn't work for 11i
      l_result_clob :=DBMS_XMLGEN.GETXML(l_qryCtx);
      l_result_clob := substr(l_result_clob,instr(l_result_clob,'>')+1);
      l_temp_asset_count := DBMS_XMLGEN.getNumRowsProcessed(l_qryCtx);
      l_asset_count := l_asset_count + l_temp_asset_count;
      DBMS_XMLGEN.closeContext(l_qryCtx);
      clob_to_file(l_result_clob);

      put_endtag('CASH_GEN_UNIT_RECORD');

    END LOOP;

    if l_reporting_flag = 'R' then
      CLOSE c_master_mrc;
    else
      CLOSE c_master;
    end if;

  end;

  put_endtag('CASH_GEN_UNIT_SET');

  put_starttag('SETUP');
  put_element('REPORT_NAME',l_report_name);
  put_element('BOOK_TYPE_CODE',p_book_type_code);
  put_element('SET_OF_BOOKS_ID',p_set_of_books_id);
  put_element('SET_OF_BOOKS_NAME',l_sob_name);
  put_element('CURRENCY_CODE',l_currency_code);
  put_element('CASH_GENERATING_UNIT_ID',p_cash_gen_unit_id);
  put_element('ASSET_ID',p_asset_id);

  put_element('CASH_GEN_UNIT_COUNT',to_char(l_unit_count));
  put_element('ASSET_COUNT',to_char(l_asset_count));
  put_endtag('SETUP');

  put_endtag('LIST_ASSETS_REPORT');

  -- set back to original environment when the procedure is finished
  fnd_client_info.set_currency_context (l_orig_currency_context);
  fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);

EXCEPTION

    WHEN OTHERS then

      if (g_print_debug) then
        fa_debug_pkg.add(l_calling_fn,
           'l_debug_info',
            l_debug_info);
        fa_debug_pkg.add(l_calling_fn,
           'SQLERRM',
            substr(SQLERRM, 1, 200));
      end if;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn || ':' || l_debug_info);

      fa_srvr_msg.add_sql_error
          (calling_fn => l_calling_fn);

      -- set back to original environment when the procedure is finished
      fnd_client_info.set_currency_context (l_orig_currency_context);
      fnd_profile.put('GL_SET_OF_BKS_ID', l_orig_set_of_books_id);

      APP_EXCEPTION.RAISE_EXCEPTION;

END list_assets_by_cash_gen;


END FA_XML_REPORT_PKG;

/
