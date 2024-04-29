--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_PREP_ENERGY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_PREP_ENERGY_PKG" as
  /* $Header: FAMAPREPEB.pls 120.11.12010000.3 2010/03/04 23:38:41 glchen ship $ */

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations
  -- Function and procedure implementations

  function create_new_asset(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                            p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_total_cost number;
    l_debug_str  varchar2(1000);
    l_calling_fn varchar2(40) := 'create_new_asset';
  begin
    if (px_mass_add_rec.EXPENSE_CODE_COMBINATION_ID is not null) and
       (px_mass_add_rec.location_id is not null) and
       (px_mass_add_rec.asset_category_id is not null) and
       (px_mass_add_rec.asset_key_ccid is not null) then
      l_debug_str := 'Check the cost';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      select nvl(sum(fixed_assets_cost), 0)
        into l_total_cost
        from fa_mass_additions
       where split_merged_code = 'MC'
         and parent_mass_addition_id = px_mass_add_rec.mass_addition_id
          or mass_addition_id = px_mass_add_rec.mass_addition_id;
      if (l_total_cost >= 0) then
        l_debug_str := 'Cost is positive';
        update fa_mass_additions
           set EXPENSE_CODE_COMBINATION_ID = px_mass_add_rec.EXPENSE_CODE_COMBINATION_ID,
               location_id                 = px_mass_add_rec.location_id,
               asset_category_id           = px_mass_add_rec.asset_category_id,
               asset_key_ccid              = px_mass_add_rec.asset_key_ccid,
               posting_status              = 'POST',
               queue_name                  = 'POST',
               last_update_date            = sysdate,
               last_updated_by             = FND_GLOBAL.user_id
        where mass_addition_id = px_mass_add_rec.mass_addition_id;
      else
        l_debug_str := 'Cost is negative';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        update fa_mass_additions
           set EXPENSE_CODE_COMBINATION_ID = px_mass_add_rec.EXPENSE_CODE_COMBINATION_ID,
               location_id                 = px_mass_add_rec.location_id,
               asset_category_id           = px_mass_add_rec.asset_category_id,
               asset_key_ccid              = px_mass_add_rec.asset_key_ccid,
               posting_status              = 'ON HOLD',
               queue_name                  = 'ON HOLD',
               last_update_date            = sysdate,
               last_updated_by             = FND_GLOBAL.user_id
        where mass_addition_id = px_mass_add_rec.mass_addition_id;

      end if;
    else
      l_debug_str := 'Expense Account not generated';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      update fa_mass_additions
         set EXPENSE_CODE_COMBINATION_ID = nvl(px_mass_add_rec.EXPENSE_CODE_COMBINATION_ID,
                                               EXPENSE_CODE_COMBINATION_ID),
             location_id                 = nvl(px_mass_add_rec.location_id,
                                               location_id),
             asset_category_id           = nvl(px_mass_add_rec.asset_category_id,
                                               asset_category_id),
             asset_key_ccid              = nvl(px_mass_add_rec.asset_key_ccid,
                                               asset_key_ccid),
             posting_status              = 'ON HOLD',
             queue_name                  = 'ON HOLD',
             last_update_date            = sysdate,
             last_updated_by             = FND_GLOBAL.user_id
        where mass_addition_id = px_mass_add_rec.mass_addition_id;

    end if;
    commit;
    return true;
  EXCEPTION
    WHEN no_data_found THEN
      return false;
    WHEN OTHERS THEN
      ROLLBACK;
      return false;
  END;

  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function cost_adjustment(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                           p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_total_cost number;
    l_debug_str  varchar2(1000);
    l_calling_fn varchar2(40) := 'cost_asjustment';
  begin
    if (px_mass_add_rec.add_to_asset_id is not null) then
      l_debug_str := 'Check the cost validity';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      select nvl(sum(fixed_assets_cost), 0)
        into l_total_cost
        from fa_mass_additions
       where split_merged_code = 'MC'
         and parent_mass_addition_id = px_mass_add_rec.mass_addition_id
         and merged_code = 'MC'
         and posting_status = 'MERGED';

      select l_total_cost + nvl(cost, 0)
        into l_total_cost
        from fa_books
       where book_type_code = px_mass_add_rec.book_type_code
         and asset_id = px_mass_add_rec.add_to_asset_id
         and transaction_header_id_out is null;
      if (l_total_cost > 0) then
        l_debug_str := 'Cost is positive';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        update fa_mass_additions
           set add_to_asset_id  = px_mass_add_rec.add_to_asset_id,
               posting_status   = 'POST',
               queue_name       = 'POST',
               last_update_date = sysdate,
               last_updated_by  = FND_GLOBAL.user_id
        where mass_addition_id = px_mass_add_rec.mass_addition_id;

      else
        l_debug_str := 'Cost is negative';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        update fa_mass_additions
           set posting_status   = 'POST',
               queue_name       = 'POST',
               last_update_date = sysdate,
               last_updated_by  = FND_GLOBAL.user_id
        where mass_addition_id = px_mass_add_rec.mass_addition_id;

      end if;
    end if;

    return true;
  EXCEPTION
    WHEN no_data_found THEN

      return false;
    WHEN OTHERS THEN

      ROLLBACK;
      return false;
  END;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function check_addition_or_adj(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                 x_status        OUT NOCOPY varchar2,
                                 p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_asset_id number := 0;
  begin
    select ad.asset_id
      into l_asset_id
      from fa_additions ad, fa_books bk
     where asset_key_ccid = px_mass_add_rec.asset_category_id
       and asset_key_ccid = px_mass_add_rec.ASSET_KEY_CCID
       and ad.asset_id = bk.asset_id
       and bk.book_type_code = px_mass_add_rec.book_type_code
       and bk.transaction_header_id_out is null
       and rownum < 2;
    px_mass_add_rec.add_to_asset_id := l_asset_id;
    x_status                        := 'ADJUSTMENT';
    return true;
  exception
    when no_data_found then
      px_mass_add_rec.add_to_asset_id := null;
      x_status                        := 'ADDITION';
      return true;
    when others then
      x_status := 'FAILED';
      return false;
  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function prepare_asset_key(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                             p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is

    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    l_akey_segment varchar30_tbl;
    l_akey_ccid    number;
    akey_ccid_seq  number;
    l_select       varchar2(2000);
    l_from         varchar2(2000);
    l_where        varchar2(2000);
    l_query        varchar2(6000);
    l_coa          NUMBER;
    l_sob_id       NUMBER;
    l_dyanmic_cur  number;

    l_segment    varchar30_tbl;
    l_category   FA_Categories.Category_ID%TYPE;
    l_key_ccid   FA_Asset_Keywords.Code_Combination_ID%TYPE;
    l_asset_type FA_Mass_Additions.Asset_Type%TYPE;

    l_mass_addition_id    FA_Mass_Additions.Mass_Addition_ID%TYPE;
    l_invoice_number      FA_Mass_Additions.Invoice_Number%TYPE;
    l_feeder_sys_name     FA_Mass_Additions.Feeder_System_Name%TYPE;
    l_fixed_assets_cost   FA_Mass_Additions.Fixed_Assets_Cost%TYPE;
    l_description         FA_Mass_Additions.Description%TYPE;
    l_queue_name          FA_Mass_Additions.Queue_Name%TYPE;
    l_asset_Key_segment1  FA_Mass_Additions.Asset_Key_segment1%TYPE;
    l_asset_Key_segment2  FA_Mass_Additions.Asset_Key_segment2%TYPE;
    l_asset_Key_segment3  FA_Mass_Additions.Asset_Key_segment3%TYPE;
    l_asset_Key_segment4  FA_Mass_Additions.Asset_Key_segment4%TYPE;
    l_asset_Key_segment5  FA_Mass_Additions.Asset_Key_segment5%TYPE;
    l_asset_Key_segment6  FA_Mass_Additions.Asset_Key_segment6%TYPE;
    l_asset_Key_segment7  FA_Mass_Additions.Asset_Key_segment7%TYPE;
    l_asset_Key_segment8  FA_Mass_Additions.Asset_Key_segment8%TYPE;
    l_asset_Key_segment9  FA_Mass_Additions.Asset_Key_segment9%TYPE;
    l_asset_Key_segment10 FA_Mass_Additions.Asset_Key_segment10%TYPE;
    l_payables_ccid       FA_Mass_Additions.Payables_Code_Combination_ID%TYPE;
    l_dist_ccid           NUMBER;
    l_dist_line_num       NUMBER;
    l_mass_add_rec        Fa_Mass_Additions%ROWTYPE;

    l_cur_status  number;
    l_debug_str   varchar2(1000);
    l_plsql_block VARCHAR2(500);
    l_table       varchar(30);
    l_product     varchar2(10);
    TYPE AssetKeyCurType IS REF CURSOR;
    l_AssetKeyCur AssetKeyCurType;
    l_calling_fn  varchar2(40) := 'prepare_asset_key';
  begin
    l_query := null;
    if (px_mass_add_rec.ASSET_KEY_CCID is null) then
      l_debug_str := 'Getting SOB id and COA';
      --code to get asset key using fedder system
      SELECT Gl_sob.Set_Of_Books_id, Chart_Of_Accounts_ID
        INTO l_sob_id, l_coa
        FROM GL_Sets_Of_Books GL_sob, FA_Book_Controls FA_BC
       WHERE GL_sob.Set_Of_Books_ID = FA_BC.Set_Of_Books_ID
         AND Book_Type_Code = px_mass_add_rec.book_type_code;

      if (upper(px_mass_add_rec.FEEDER_SYSTEM_NAME) = 'ORACLE PAYABLES') then
        l_debug_str   := 'Feeder System Oracle Payables';
        l_table       := 'AP_INVOICE_DISTRIBUTIONS_ALL';
        l_product     := 'AP';
        l_plsql_block := 'BEGIN EJINMAP.get_asset_key_map(:l_table,:l_product,:l_sob_id,:l_select,:l_from,:l_where); END;';
        EXECUTE IMMEDIATE l_plsql_block
          USING l_table, l_product, l_sob_id, l_select, l_from, l_where;

        /*        EJINMAP.get_asset_key_map('AP_INVOICE_DISTRIBUTIONS_ALL',
        'AP',
        l_sob_id,
        l_select,
        l_from,
        l_where);*/
        l_query := 'select ' || l_select || ',Payables_Code_Combination_ID
                   from ' || l_from ||
                   ',FA_Mass_Additions FA  where ' || l_where ||
                   ' AND TRANS.Invoice_ID= FA.Invoice_ID
                    AND TRANS.Distribution_Line_Number=FA.AP_Distribution_Line_Number
                    AND Posting_Status IN (''NEW'',''ON HOLD'')
                    AND book_type_code=:px_mass_add_rec.book_type_code
                    AND Feeder_System_Name=''ORACLE PAYABLES''';

      elsif (upper(px_mass_add_rec.FEEDER_SYSTEM_NAME) =
            'ORACLE GENERAL LEDGER') then
        l_debug_str := 'Feeder System Oracle General Ledger';
        l_debug_str := 'Feeder System Oracle Payables';
        l_table     := 'GL_JE_LINES';
        l_product   := 'GL';

        l_plsql_block := 'BEGIN EJINMAP.get_asset_key_map(:l_table,:l_product,:l_sob_id,:l_select,:l_from,:l_where); END;';
        EXECUTE IMMEDIATE l_plsql_block
          USING l_table, l_product, l_sob_id, OUT l_select, OUT l_from, OUT l_where;

        l_query := 'SELECT AFF.Code_Combination_ID ,Mass_Addition_ID
                   ,Invoice_Number ,FA.AP_Distribution_Line_Number
                   ,Feeder_System_Name ,Fixed_Assets_Cost
                   ,FA.Description Description ,Queue_Name ' ||
                   l_select || ',Payables_Code_Combination_ID
                   from ' || l_from ||
                   ',FA_Mass_Additions FA  where ' || l_where ||
                   'AND TRANS.Je_Header_ID = FA.Je_Header_ID
                    AND TRANS.Je_Line_Num = FA.Je_Line_Num
                    AND book_type_code = :px_mass_add_rec.book_type_code
                    AND Posting_Status IN (''NEW'',''ON HOLD'')
                    AND Feeder_System_Name = ''GL''';
      else
        l_debug_str := 'Feeder System Other';
        --if (upper(px_mass_add_rec.FEEDER_SYSTEM_NAME) = 'OTHERS') then
        SELECT asset_key_segment1,
               asset_key_segment2,
               asset_key_segment3,
               asset_key_segment4,
               asset_key_segment5,
               asset_key_segment6,
               asset_key_segment7,
               asset_key_segment8,
               asset_key_segment9,
               asset_key_segment10
          INTO l_akey_segment(1),
               l_akey_segment(2),
               l_akey_segment(3),
               l_akey_segment(4),
               l_akey_segment(5),
               l_akey_segment(6),
               l_akey_segment(7),
               l_akey_segment(8),
               l_akey_segment(9),
               l_akey_segment(10)
          FROM fa_mass_additions
         WHERE mass_addition_id = px_mass_add_rec.mass_addition_id;

        BEGIN
          l_debug_str := 'Get the Asset Key';
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             l_debug_str,
                             '',
                             p_log_level_rec => p_log_level_rec);
          end if;
          SELECT code_combination_id
            INTO l_akey_ccid
            FROM fa_asset_keywords
           WHERE nvl(segment1, '-1') = nvl(l_akey_segment(1), '-1')
             and nvl(segment2, '-1') = nvl(l_akey_segment(2), '-1')
             and nvl(segment3, '-1') = nvl(l_akey_segment(3), '-1')
             and nvl(segment4, '-1') = nvl(l_akey_segment(4), '-1')
             and nvl(segment5, '-1') = nvl(l_akey_segment(5), '-1')
             and nvl(segment6, '-1') = nvl(l_akey_segment(6), '-1')
             and nvl(segment7, '-1') = nvl(l_akey_segment(7), '-1')
             and nvl(segment8, '-1') = nvl(l_akey_segment(8), '-1')
             and nvl(segment9, '-1') = nvl(l_akey_segment(9), '-1')
             and nvl(segment10, '-1') = nvl(l_akey_segment(10), '-1');
          px_mass_add_rec.asset_key_ccid := l_akey_ccid;
        EXCEPTION
          WHEN no_data_found THEN
            SELECT FA_Asset_keywords_S.Nextval
              INTO akey_ccid_seq
              FROM DUAL;
            l_debug_str := 'Insert the asset key';
            if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn,
                               l_debug_str,
                               '',
                               p_log_level_rec => p_log_level_rec);
            end if;
            INSERT INTO fa_asset_keywords
              (CODE_COMBINATION_ID,
               SEGMENT1,
               SEGMENT2,
               SEGMENT3,
               SEGMENT4,
               SEGMENT5,
               SEGMENT6,
               SEGMENT7,
               SEGMENT8,
               SEGMENT9,
               SEGMENT10,
               SUMMARY_FLAG,
               ENABLED_FLAG,
               START_DATE_ACTIVE,
               END_DATE_ACTIVE,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN)
            VALUES
              (akey_ccid_seq,
               l_akey_segment(1),
               l_akey_segment(2),
               l_akey_segment(3),
               l_akey_segment(4),
               l_akey_segment(5),
               l_akey_segment(6),
               l_akey_segment(7),
               l_akey_segment(8),
               l_akey_segment(9),
               l_akey_segment(10),
               'Y',
               'Y',
               NULL,
               NULL,
               sysdate,
               FND_GLOBAL.USER_ID,
               -1);

            px_mass_add_rec.asset_key_ccid := akey_ccid_seq;
          WHEN OTHERS THEN
            ROLLBACK;
        END;
      end if;

      if (length(l_query) is not null) then
        l_debug_str := 'Preparing the query, Define the Columns';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        OPEN l_AssetKeyCur FOR l_query
          using px_mass_add_rec.book_type_code;

        loop

          FETCH l_AssetKeyCur
            INTO l_dist_ccid, l_mass_addition_ID, l_invoice_number, l_Dist_Line_Num, l_feeder_sys_name,
                 l_fixed_assets_cost, l_description, l_queue_name, l_asset_Key_segment1, l_asset_Key_segment2,
                 l_asset_Key_segment3, l_asset_Key_segment4, l_asset_Key_segment5, l_asset_Key_segment6,
                 l_asset_Key_segment7, l_asset_Key_segment8, l_asset_Key_segment9, l_asset_Key_segment10,
                 l_payables_ccid;

          EXIT WHEN l_AssetKeyCur%NOTFOUND;

          BEGIN
            SELECT code_combination_id
              INTO px_mass_add_rec.asset_key_ccid
              FROM fa_asset_keywords
             WHERE nvl(segment1, '-1') = nvl(l_asset_key_segment1, '-1')
               and nvl(segment2, '-1') = nvl(l_asset_key_segment2, '-1')
               and nvl(segment3, '-1') = nvl(l_asset_key_segment3, '-1')
               and nvl(segment4, '-1') = nvl(l_asset_key_segment4, '-1')
               and nvl(segment5, '-1') = nvl(l_asset_key_segment5, '-1')
               and nvl(segment6, '-1') = nvl(l_asset_key_segment6, '-1')
               and nvl(segment7, '-1') = nvl(l_asset_key_segment7, '-1')
               and nvl(segment8, '-1') = nvl(l_asset_key_segment8, '-1')
               and nvl(segment9, '-1') = nvl(l_asset_key_segment9, '-1')
               and nvl(segment10, '-1') = nvl(l_asset_key_segment10, '-1');

          exception
            when no_data_found then
              SELECT FA_Asset_keywords_S.Nextval
                INTO akey_ccid_seq
                FROM DUAL;
              INSERT INTO fa_asset_keywords
                (CODE_COMBINATION_ID,
                 SEGMENT1,
                 SEGMENT2,
                 SEGMENT3,
                 SEGMENT4,
                 SEGMENT5,
                 SEGMENT6,
                 SEGMENT7,
                 SEGMENT8,
                 SEGMENT9,
                 SEGMENT10,
                 SUMMARY_FLAG,
                 ENABLED_FLAG,
                 START_DATE_ACTIVE,
                 END_DATE_ACTIVE,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_LOGIN)
              VALUES
                (akey_ccid_seq,
                 l_akey_segment(1),
                 l_akey_segment(2),
                 l_akey_segment(3),
                 l_akey_segment(4),
                 l_akey_segment(5),
                 l_akey_segment(6),
                 l_akey_segment(7),
                 l_akey_segment(8),
                 l_akey_segment(9),
                 l_akey_segment(10),
                 'Y',
                 'Y',
                 NULL,
                 NULL,
                 sysdate,
                 -1,
                 -1);

              px_mass_add_rec.asset_key_ccid := akey_ccid_seq;
          end;
        end loop;

        close l_AssetKeyCur;
      end if;
    end if;
    return true;
  exception
    when others then
      return false;
  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function prepare_category(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                            p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_gl_ccid_rec  GL_CODE_COMBINATIONS%ROWTYPE;
    l_mass_add_rec FA_MASSADD_PREPARE_PKG.mass_add_rec;
    l_err_mesg     varchar2(500);
    l_calling_fn   varchar2(40) := 'prepare_category';
    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    TYPE num_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;
    l_seg_num                   num_tbl;
    l_segment                   varchar30_tbl;
    l_major_category            varchar2(50);
    l_minor_category            varchar2(50);
    l_major_index               number;
    l_minor_index               number;
    l_major_ccid                number;
    l_minor_ccid                number;
    l_clearing_acct_ccid        number;
    l_category_id               number;
    l_gl_ccid_enabled_flag      varchar2(1);
    l_ACCOUNTING_FLEX_STRUCTURE fa_book_controls.accounting_flex_structure%type;
    l_bal_seg_num               NUMBER;
    l_lookup_code               varchar2(30);
    l_debug_str                 varchar2(1000);
    h_chart_of_accounts_id    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;

    CURSOR lookup_cur(c_lookup_type varchar2) IS
      select lookup_code
        from fa_lookups
       where lookup_type = c_lookup_type
         and enabled_flag = 'Y';

  begin
    Select sob.chart_of_accounts_id
      into h_chart_of_accounts_id
      From fa_book_controls bc, gl_sets_of_books sob
     Where sob.set_of_books_id = bc.set_of_books_id
       And bc.book_type_code = px_mass_add_rec.book_type_code;

    if (px_mass_add_rec.PAYABLES_CODE_COMBINATION_ID is not null) then
      l_debug_str := 'Get the Accounting Flex Field';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      for i in 1 .. 30 loop
        l_segment(i) := null;
        l_seg_num(i) := -1;
      end loop;
      l_debug_str := 'Get the Category Mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('CATEGORY MAPPING FOR COA') LOOP
        l_seg_num(to_number(substr(rec.lookup_code, 8))) := 1;
      END LOOP;

      select Segment1,
             Segment2,
             Segment3,
             Segment4,
             Segment5,
             Segment6,
             Segment7,
             Segment8,
             Segment9,
             Segment10,
             Segment11,
             Segment12,
             Segment13,
             Segment14,
             Segment15,
             Segment16,
             Segment17,
             Segment18,
             Segment19,
             Segment20,
             Segment21,
             Segment22,
             Segment23,
             Segment24,
             Segment25,
             Segment26,
             Segment27,
             Segment28,
             Segment29,
             Segment30,
             enabled_flag
        into l_segment(1),
             l_segment(2),
             l_segment(3),
             l_segment(4),
             l_segment(5),
             l_segment(6),
             l_segment(7),
             l_segment(8),
             l_segment(9),
             l_segment(10),
             l_segment(11),
             l_segment(12),
             l_segment(13),
             l_segment(14),
             l_segment(15),
             l_segment(16),
             l_segment(17),
             l_segment(18),
             l_segment(19),
             l_segment(20),
             l_segment(21),
             l_segment(22),
             l_segment(23),
             l_segment(24),
             l_segment(25),
             l_segment(26),
             l_segment(27),
             l_segment(28),
             l_segment(29),
             l_segment(30),
             l_gl_ccid_enabled_flag
        from gl_code_combinations
        where code_combination_id =
             px_mass_add_rec.payables_code_combination_id
	and chart_of_accounts_id = h_chart_of_accounts_id;

      for i in 1 .. 30 loop
        IF (l_seg_num(i) < 0) THEN
          l_segment(i) := null;
        END IF;
      end loop;
      if (px_mass_add_rec.asset_type = 'CAPITALIZED') then
        l_debug_str := 'Get the Clearing Account for Capitalized Assets';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        select max(code_combination_id)
          into l_clearing_acct_ccid
          from gl_code_combinations gl_ccid
         where decode(l_segment(1), null, '-1', gl_ccid.Segment1) =
               nvl(l_segment(1), '-1')
           and decode(l_segment(2), null, '-1', gl_ccid.Segment2) =
               nvl(l_segment(2), '-1')
           and decode(l_segment(3), null, '-1', gl_ccid.Segment3) =
               nvl(l_segment(3), '-1')
           and decode(l_segment(4), null, '-1', gl_ccid.Segment4) =
               nvl(l_segment(4), '-1')
           and decode(l_segment(5), null, '-1', gl_ccid.Segment5) =
               nvl(l_segment(5), '-1')
           and decode(l_segment(6), null, '-1', gl_ccid.Segment6) =
               nvl(l_segment(6), '-1')
           and decode(l_segment(7), null, '-1', gl_ccid.Segment7) =
               nvl(l_segment(7), '-1')
           and decode(l_segment(8), null, '-1', gl_ccid.Segment8) =
               nvl(l_segment(8), '-1')
           and decode(l_segment(9), null, '-1', gl_ccid.Segment9) =
               nvl(l_segment(9), '-1')
           and decode(l_segment(10), null, '-1', gl_ccid.Segment10) =
               nvl(l_segment(10), '-1')
           and decode(l_segment(11), null, '-1', gl_ccid.Segment11) =
               nvl(l_segment(11), '-1')
           and decode(l_segment(12), null, '-1', gl_ccid.Segment12) =
               nvl(l_segment(12), '-1')
           and decode(l_segment(13), null, '-1', gl_ccid.Segment13) =
               nvl(l_segment(13), '-1')
           and decode(l_segment(14), null, '-1', gl_ccid.Segment14) =
               nvl(l_segment(14), '-1')
           and decode(l_segment(15), null, '-1', gl_ccid.Segment15) =
               nvl(l_segment(15), '-1')
           and decode(l_segment(16), null, '-1', gl_ccid.Segment16) =
               nvl(l_segment(16), '-1')
           and decode(l_segment(17), null, '-1', gl_ccid.Segment17) =
               nvl(l_segment(17), '-1')
           and decode(l_segment(18), null, '-1', gl_ccid.Segment18) =
               nvl(l_segment(18), '-1')
           and decode(l_segment(19), null, '-1', gl_ccid.Segment19) =
               nvl(l_segment(19), '-1')
           and decode(l_segment(20), null, '-1', gl_ccid.Segment20) =
               nvl(l_segment(20), '-1')
           and decode(l_segment(21), null, '-1', gl_ccid.Segment21) =
               nvl(l_segment(21), '-1')
           and decode(l_segment(22), null, '-1', gl_ccid.Segment22) =
               nvl(l_segment(22), '-1')
           and decode(l_segment(23), null, '-1', gl_ccid.Segment23) =
               nvl(l_segment(23), '-1')
           and decode(l_segment(24), null, '-1', gl_ccid.Segment24) =
               nvl(l_segment(24), '-1')
           and decode(l_segment(25), null, '-1', gl_ccid.Segment25) =
               nvl(l_segment(25), '-1')
           and decode(l_segment(26), null, '-1', gl_ccid.Segment26) =
               nvl(l_segment(26), '-1')
           and decode(l_segment(27), null, '-1', gl_ccid.Segment27) =
               nvl(l_segment(27), '-1')
           and decode(l_segment(28), null, '-1', gl_ccid.Segment28) =
               nvl(l_segment(28), '-1')
           and decode(l_segment(29), null, '-1', gl_ccid.Segment29) =
               nvl(l_segment(29), '-1')
           and decode(l_segment(30), null, '-1', gl_ccid.Segment30) =
               nvl(l_segment(30), '-1')
           and chart_of_accounts_id = h_chart_of_accounts_id
           and exists
         (select 1
                  from fa_category_books cat
                 where cat.ASSET_CLEARING_ACCOUNT_CCID =
                       gl_ccid.code_combination_id
                   and cat.book_type_code = px_mass_add_rec.book_type_code);
        l_debug_str := 'Get the Category for Capitalized Assets';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        select category_id
          into px_mass_add_rec.ASSET_CATEGORY_ID
          from fa_category_books
         where ASSET_CLEARING_ACCOUNT_CCID = l_clearing_acct_ccid
           and book_type_code = px_mass_add_rec.book_type_code
           and rownum = 1;
      elsif (px_mass_add_rec.asset_type = 'CIP') then
        l_debug_str := 'Get the Clearing Account for CIP Assets';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        select max(code_combination_id)
          into l_clearing_acct_ccid
          from gl_code_combinations gl_ccid
         where decode(l_segment(1), null, '-1', gl_ccid.Segment1) =
               nvl(l_segment(1), '-1')
           and decode(l_segment(2), null, '-1', gl_ccid.Segment2) =
               nvl(l_segment(2), '-1')
           and decode(l_segment(3), null, '-1', gl_ccid.Segment3) =
               nvl(l_segment(3), '-1')
           and decode(l_segment(4), null, '-1', gl_ccid.Segment4) =
               nvl(l_segment(4), '-1')
           and decode(l_segment(5), null, '-1', gl_ccid.Segment5) =
               nvl(l_segment(5), '-1')
           and decode(l_segment(6), null, '-1', gl_ccid.Segment6) =
               nvl(l_segment(6), '-1')
           and decode(l_segment(7), null, '-1', gl_ccid.Segment7) =
               nvl(l_segment(7), '-1')
           and decode(l_segment(8), null, '-1', gl_ccid.Segment8) =
               nvl(l_segment(8), '-1')
           and decode(l_segment(9), null, '-1', gl_ccid.Segment9) =
               nvl(l_segment(9), '-1')
           and decode(l_segment(10), null, '-1', gl_ccid.Segment10) =
               nvl(l_segment(10), '-1')
           and decode(l_segment(11), null, '-1', gl_ccid.Segment11) =
               nvl(l_segment(11), '-1')
           and decode(l_segment(12), null, '-1', gl_ccid.Segment12) =
               nvl(l_segment(12), '-1')
           and decode(l_segment(13), null, '-1', gl_ccid.Segment13) =
               nvl(l_segment(13), '-1')
           and decode(l_segment(14), null, '-1', gl_ccid.Segment14) =
               nvl(l_segment(14), '-1')
           and decode(l_segment(15), null, '-1', gl_ccid.Segment15) =
               nvl(l_segment(15), '-1')
           and decode(l_segment(16), null, '-1', gl_ccid.Segment16) =
               nvl(l_segment(16), '-1')
           and decode(l_segment(17), null, '-1', gl_ccid.Segment17) =
               nvl(l_segment(17), '-1')
           and decode(l_segment(18), null, '-1', gl_ccid.Segment18) =
               nvl(l_segment(18), '-1')
           and decode(l_segment(19), null, '-1', gl_ccid.Segment19) =
               nvl(l_segment(19), '-1')
           and decode(l_segment(20), null, '-1', gl_ccid.Segment20) =
               nvl(l_segment(20), '-1')
           and decode(l_segment(21), null, '-1', gl_ccid.Segment21) =
               nvl(l_segment(21), '-1')
           and decode(l_segment(22), null, '-1', gl_ccid.Segment22) =
               nvl(l_segment(22), '-1')
           and decode(l_segment(23), null, '-1', gl_ccid.Segment23) =
               nvl(l_segment(23), '-1')
           and decode(l_segment(24), null, '-1', gl_ccid.Segment24) =
               nvl(l_segment(24), '-1')
           and decode(l_segment(25), null, '-1', gl_ccid.Segment25) =
               nvl(l_segment(25), '-1')
           and decode(l_segment(26), null, '-1', gl_ccid.Segment26) =
               nvl(l_segment(26), '-1')
           and decode(l_segment(27), null, '-1', gl_ccid.Segment27) =
               nvl(l_segment(27), '-1')
           and decode(l_segment(28), null, '-1', gl_ccid.Segment28) =
               nvl(l_segment(28), '-1')
           and decode(l_segment(29), null, '-1', gl_ccid.Segment29) =
               nvl(l_segment(29), '-1')
           and decode(l_segment(30), null, '-1', gl_ccid.Segment30) =
               nvl(l_segment(30), '-1')
           and chart_of_accounts_id = h_chart_of_accounts_id
           and exists
         (select 1
                  from fa_category_books cat
                 where cat.WIP_CLEARING_ACCOUNT_CCID =
                       gl_ccid.code_combination_id
                   and cat.book_type_code = px_mass_add_rec.book_type_code);
        l_debug_str := 'Get the Clearing Account for CIP Assets';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        select category_id
          into px_mass_add_rec.ASSET_CATEGORY_ID
          from fa_category_books
         where WIP_CLEARING_ACCOUNT_CCID = l_clearing_acct_ccid
           and book_type_code = px_mass_add_rec.book_type_code
           and rownum = 1;
      END IF;

    end if;
    return true;
  exception
    when too_many_rows then
      return false;
    when no_data_found then
      return false;
    when others then
      return false;
  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  -- Author  : SKCHAWLA
  -- Created : 5/16/2005 2:30:36 PM
  -- Purpose : To Prepare asset key and category id for common customers

  function prep_asset_key_category(p_book_type_code varchar2,
                                   p_log_level_rec  IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_mass_add_rec FA_MASSADD_PREPARE_PKG.mass_add_rec;
    l_batch_size   number := 500;
    l_count        number;
    Result         boolean;
    l_status       number;
    l_debug_str    varchar2(1000);

    l_mass_add_rec_tbl FA_MASSADD_PREPARE_PKG.mass_add_rec_tbl;

    --l_mass_add_dist_tbl mass_add_dist_tbl;
    l_calling_fn        varchar2(40) := 'prepare_aset_key_category';
    --Cursor to get all mass_addition lines
    --check about the book_type_code
    cursor GET_MASS_ADD(l_book varchar2) is
      Select MASS_ADDITION_ID,
             ASSET_NUMBER,
             TAG_NUMBER,
             DESCRIPTION,
             ASSET_CATEGORY_ID,
             MANUFACTURER_NAME,
             SERIAL_NUMBER,
             MODEL_NUMBER,
             BOOK_TYPE_CODE,
             DATE_PLACED_IN_SERVICE,
             FIXED_ASSETS_COST,
             PAYABLES_UNITS,
             FIXED_ASSETS_UNITS,
             PAYABLES_CODE_COMBINATION_ID,
             EXPENSE_CODE_COMBINATION_ID,
             LOCATION_ID,
             ASSIGNED_TO,
             FEEDER_SYSTEM_NAME,
             CREATE_BATCH_DATE,
             CREATE_BATCH_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             REVIEWER_COMMENTS,
             INVOICE_NUMBER,
             INVOICE_LINE_NUMBER,
             INVOICE_DISTRIBUTION_ID,
             VENDOR_NUMBER,
             PO_VENDOR_ID,
             PO_NUMBER,
             POSTING_STATUS,
             QUEUE_NAME,
             INVOICE_DATE,
             INVOICE_CREATED_BY,
             INVOICE_UPDATED_BY,
             PAYABLES_COST,
             INVOICE_ID,
             PAYABLES_BATCH_NAME,
             DEPRECIATE_FLAG,
             PARENT_MASS_ADDITION_ID,
             PARENT_ASSET_ID,
             SPLIT_MERGED_CODE,
             AP_DISTRIBUTION_LINE_NUMBER,
             POST_BATCH_ID,
             ADD_TO_ASSET_ID,
             AMORTIZE_FLAG,
             NEW_MASTER_FLAG,
             ASSET_KEY_CCID,
             ASSET_TYPE,
             DEPRN_RESERVE,
             YTD_DEPRN,
             BEGINNING_NBV,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             SALVAGE_VALUE,
             ACCOUNTING_DATE,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             ATTRIBUTE_CATEGORY_CODE,
             FULLY_RSVD_REVALS_COUNTER,
             MERGE_INVOICE_NUMBER,
             MERGE_VENDOR_NUMBER,
             PRODUCTION_CAPACITY,
             REVAL_AMORTIZATION_BASIS,
             REVAL_RESERVE,
             UNIT_OF_MEASURE,
             UNREVALUED_COST,
             YTD_REVAL_DEPRN_EXPENSE,
             ATTRIBUTE16,
             ATTRIBUTE17,
             ATTRIBUTE18,
             ATTRIBUTE19,
             ATTRIBUTE20,
             ATTRIBUTE21,
             ATTRIBUTE22,
             ATTRIBUTE23,
             ATTRIBUTE24,
             ATTRIBUTE25,
             ATTRIBUTE26,
             ATTRIBUTE27,
             ATTRIBUTE28,
             ATTRIBUTE29,
             ATTRIBUTE30,
             MERGED_CODE,
             SPLIT_CODE,
             MERGE_PARENT_MASS_ADDITIONS_ID,
             SPLIT_PARENT_MASS_ADDITIONS_ID,
             PROJECT_ASSET_LINE_ID,
             PROJECT_ID,
             TASK_ID,
             SUM_UNITS,
             DIST_NAME,
             GLOBAL_ATTRIBUTE1,
             GLOBAL_ATTRIBUTE2,
             GLOBAL_ATTRIBUTE3,
             GLOBAL_ATTRIBUTE4,
             GLOBAL_ATTRIBUTE5,
             GLOBAL_ATTRIBUTE6,
             GLOBAL_ATTRIBUTE7,
             GLOBAL_ATTRIBUTE8,
             GLOBAL_ATTRIBUTE9,
             GLOBAL_ATTRIBUTE10,
             GLOBAL_ATTRIBUTE11,
             GLOBAL_ATTRIBUTE12,
             GLOBAL_ATTRIBUTE13,
             GLOBAL_ATTRIBUTE14,
             GLOBAL_ATTRIBUTE15,
             GLOBAL_ATTRIBUTE16,
             GLOBAL_ATTRIBUTE17,
             GLOBAL_ATTRIBUTE18,
             GLOBAL_ATTRIBUTE19,
             GLOBAL_ATTRIBUTE20,
             GLOBAL_ATTRIBUTE_CATEGORY,
             CONTEXT,
             INVENTORIAL,
             SHORT_FISCAL_YEAR_FLAG,
             CONVERSION_DATE,
             ORIGINAL_DEPRN_START_DATE,
             GROUP_ASSET_ID,
             CUA_PARENT_HIERARCHY_ID,
             UNITS_TO_ADJUST,
             BONUS_YTD_DEPRN,
             BONUS_DEPRN_RESERVE,
             AMORTIZE_NBV_FLAG,
             AMORTIZATION_START_DATE,
             TRANSACTION_TYPE_CODE,
             TRANSACTION_DATE,
             WARRANTY_ID,
             LEASE_ID,
             LESSOR_ID,
             PROPERTY_TYPE_CODE,
             PROPERTY_1245_1250_CODE,
             IN_USE_FLAG,
             OWNED_LEASED,
             NEW_USED,
             ASSET_ID,
             MATERIAL_INDICATOR_FLAG,
             cast(multiset (select MASSADD_DIST_ID dist_id,
                          MASS_ADDITION_ID mass_add_id,
                          UNITS,
                          DEPRN_EXPENSE_CCID,
                          LOCATION_ID,
                          EMPLOYEE_ID
                     from FA_MASSADD_DISTRIBUTIONS mass_dist
                    where mass_dist.mass_addition_id =
                          mass_add.mass_addition_id) as
                  fa_mass_add_dist_tbl) dists
        FROM fa_mass_additions mass_add
       where posting_status in ('NEW', 'ON-HOLD', 'POST')
         and book_type_code = l_book
         and nvl(merged_code, '1') not in ('MC')
         and (asset_key_ccid is null or asset_category_id is null);

  begin
    --Open the cursor for the mass additions
    open GET_MASS_ADD(p_book_type_code);

    -- Process all the records
    while true loop
      l_debug_str := 'In Loop';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      --fetch the records as per batch size
      fetch GET_MASS_ADD BULK COLLECT
        INTO l_mass_add_rec_tbl limit l_batch_size;

      --exit from the loop if no more records
      if (GET_MASS_ADD%NOTFOUND) and (l_mass_add_rec_tbl.count < 1) then
        exit;
      end if;

      --Loop to get process each mass addition line
      for l_count in 1 .. l_mass_add_rec_tbl.count loop
        l_debug_str := 'Calling prepare_asset_key';
        if not prepare_asset_key(l_mass_add_rec_tbl(l_count)) then
          l_debug_str := 'prepare_asset_key returned failure';
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             l_debug_str,
                             '',
                             p_log_level_rec => p_log_level_rec);
          end if;
        end if;
        l_debug_str := 'Calling prepare_category';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        if not prepare_category(l_mass_add_rec_tbl(l_count)) then
          l_debug_str := 'prepare_category returned failuer';
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             l_debug_str,
                             '',
                             p_log_level_rec => p_log_level_rec);
          end if;
        end if;
      end loop;
      l_debug_str := 'Calling update_mass_additions';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      if not
          FA_MASSADD_PREPARE_PKG.update_mass_additions(l_mass_add_rec_tbl,
                                                       p_log_level_rec => p_log_level_rec) then
        l_debug_str := 'update_mass_additions returned failure';
      end if;
      commit;
    end loop;
    close GET_MASS_ADD;
    Result := True;
    return(Result);
  exception
    when others then
      return false;
  end prep_asset_key_category;
  /**********************Funtion to merge the mass addition lines****************************/
  function merge_lines(p_book_type_code varchar2,
                       p_log_level_rec  IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is

    cursor parent_mass_add(l_book_type_code varchar2) is
      SELECT Mass_Addition_ID,
             Asset_Key_CCID,
             Asset_Category_ID,
             book_type_code
        FROM FA_Mass_Additions
       WHERE Posting_Status IN ('NEW', 'ON HOLD', 'POST')
         AND Asset_Category_ID IS NOT NULL
         AND Asset_Key_CCID IS NOT NULL
         and book_type_code = l_book_type_code
       order by asset_category_id,
                asset_key_ccid,
                decode(merged_code, 'MP', 1, NULL, 2), -->Use an existing parent if any
                fixed_assets_cost desc,
                decode(posting_status, 'POST', 1, 'NEW', 2, 'ON HOLD', 3);

    cursor child_mass_add(l_mass_add_id number, l_asset_key_ccid number, l_asset_category_id number, l_book_type_code varchar2) is
      select mass_addition_id, asset_category_id, asset_key_ccid
        from fa_mass_additions
       where posting_status in ('NEW', 'ON HOLD', 'POSTED')
         and mass_addition_id <> l_mass_add_id
         and asset_category_id = l_asset_category_id
         and asset_key_ccid = l_asset_key_ccid
         and merged_code is null
         and book_type_code = l_book_type_code;

    merged_parent number;
    Result        boolean;
  begin
    for parent_rec in parent_mass_add(p_book_type_code) loop
      merged_parent := -1;
      for child_rec in child_mass_add(parent_rec.mass_addition_id,
                                      parent_rec.asset_key_ccid,
                                      parent_rec.asset_category_id,
                                      parent_rec.book_type_code) loop
        update fa_mass_additions
           set posting_status                 = 'MERGED',
               MERGE_PARENT_MASS_ADDITIONS_ID = parent_rec.mass_addition_id,
               merged_code                    = 'MC',
               last_update_date               = sysdate,
               last_updated_by                = -1,
               last_update_login              = -1
         where mass_addition_id = child_rec.mass_addition_id;
        merged_parent := 1;
      end loop;
      if (merged_parent = 1) then
        update fa_mass_additions
           set merged_code       = 'MP',
               last_update_date  = sysdate,
               last_updated_by   = -1,
               last_update_login = -1
         where mass_addition_id = parent_rec.mass_addition_id;
      end if;
    end loop;
    commit;
    Result := True;
    return(Result);
  exception
    when no_data_found then
      return false;
    when others then
      return false;

  end merge_lines;

  /*********************Prepare Expense Account******************************************/
  function prepare_expense_ccid(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_exp_acct_col_name fnd_id_flex_segments.application_column_name%TYPE;
    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    l_segment                   varchar30_tbl;
    l_exp_acct_index            number;
    l_exp_acct_ccid             number;
    l_gl_ccid_enabled_flag      varchar2(1);
    l_ACCOUNTING_FLEX_STRUCTURE fa_book_controls.accounting_flex_structure%type;

    h_chart_of_accounts_id    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
    h_flex_segment_delimiter  varchar2(5);
    h_flex_segment_number     number;
    h_num_of_segments         NUMBER;
    h_concat_array_segments   FND_FLEX_EXT.SEGMENTARRAY;
    h_new_deprn_exp_acct      VARCHAR2(26);
    h_cost_acct_ccid          NUMBER := 0;
    l_API_VERSION             NUMBER := 1.0;
    l_SOURCE_DISTRIB_ID_NUM_1 NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_2 NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_3 NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_4 NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_5 NUMBER;
    l_ACCOUNT_TYPE_CODE       VARCHAR2(30) := 'FA_EXPENSE_ACCOUNT';
    l_DEPRN_EXPENSE_ACCT_CCID NUMBER;
    l_PAYABLES_CCID           NUMBER;
    l_default_ccid            number;

    l_ACCOUNT_DEFINITION_TYPE_CODE VARCHAR2(30) := 'S';
    l_ACCOUNT_DEFINITION_CODE      VARCHAR2(30) := 'FA_EXPENSE_ACCOUNT';
    l_TRANSACTION_COA_ID           NUMBER := 101;
    l_MODE                         VARCHAR2(30) := 'ONLINE';
    l_RETURN_STATUS                VARCHAR2(1);
    l_MSG_COUNT                    NUMBER;
    l_MSG_DATA                     VARCHAR2(255);

    l_TARGET_CCID           NUMBER;
    l_CONCATENATED_SEGMENTS VARCHAR2(4000);
    l_plsql_block           varchar2(5000);
    l_calling_fn            varchar2(40) := 'prepare_expense_ccid';
  begin

    select FLEXBUILDER_DEFAULTS_CCID
    into l_default_ccid
    from fa_book_controls
    where book_type_code = px_mass_add_rec.book_type_code;

    SELECT deprn_expense_account_ccid, asset_cost_account_ccid
      INTO l_DEPRN_EXPENSE_ACCT_CCID, h_cost_acct_ccid
      FROM fa_category_books
     WHERE book_type_code = px_mass_add_rec.book_type_code
       AND category_id = px_mass_add_rec.asset_category_id;

    Select sob.chart_of_accounts_id
      into h_chart_of_accounts_id
      From fa_book_controls bc, gl_sets_of_books sob
     Where sob.set_of_books_id = bc.set_of_books_id
       And bc.book_type_code = px_mass_add_rec.book_type_code;
    l_TRANSACTION_COA_ID := h_chart_of_accounts_id;

    l_PAYABLES_CCID           := px_mass_add_rec.payables_code_combination_id;

    l_plsql_block := 'begin
                      fa_xla_tab_pkg.WRITE_ONLINE_TAB(
                      P_API_VERSION                  => :l_API_VERSION,
                      P_SOURCE_DISTRIB_ID_NUM_1      => :l_SOURCE_DISTRIB_ID_NUM_1,
                      P_SOURCE_DISTRIB_ID_NUM_2      => :l_SOURCE_DISTRIB_ID_NUM_2,
                      P_SOURCE_DISTRIB_ID_NUM_3      => :l_SOURCE_DISTRIB_ID_NUM_3,
                      P_SOURCE_DISTRIB_ID_NUM_4      => :l_SOURCE_DISTRIB_ID_NUM_4,
                      P_SOURCE_DISTRIB_ID_NUM_5      => :l_SOURCE_DISTRIB_ID_NUM_5,
                      P_ACCOUNT_TYPE_CODE            => :l_ACCOUNT_TYPE_CODE,
                      DEFAULT_CCID                   => :l_default_ccid,
                      DEPRN_EXPENSE_ACCOUNT_CCID     => :l_DEPRN_EXPENSE_ACCT_CCID,
                      PAYABLES_CCID                  => :l_PAYABLES_CCID,
                      X_RETURN_STATUS                => :l_RETURN_STATUS,
                      X_MSG_COUNT                    => :l_MSG_COUNT ,
                      X_MSG_DATA                     => :l_MSG_DATA);
                      end;';

    EXECUTE IMMEDIATE l_plsql_block
      USING l_API_VERSION, l_SOURCE_DISTRIB_ID_NUM_1, l_SOURCE_DISTRIB_ID_NUM_2, l_SOURCE_DISTRIB_ID_NUM_3,
      l_SOURCE_DISTRIB_ID_NUM_4, l_SOURCE_DISTRIB_ID_NUM_5, l_ACCOUNT_TYPE_CODE,l_default_ccid,
       l_DEPRN_EXPENSE_ACCT_CCID, l_PAYABLES_CCID, out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;

    l_plsql_block := 'begin
                      FA_XLA_TAB_PKG.run(
                      P_API_VERSION                  => :l_API_VERSION,
                      P_ACCOUNT_DEFINITION_TYPE_CODE => :l_ACCOUNT_DEFINITION_TYPE_CODE,
                      P_ACCOUNT_DEFINITION_CODE      => :l_ACCOUNT_DEFINITION_CODE,
                      P_TRANSACTION_COA_ID           => :l_TRANSACTION_COA_ID ,
                      P_MODE                         => :l_MODE,
                      X_RETURN_STATUS                => :l_RETURN_STATUS,
                      X_MSG_COUNT                    => :l_MSG_COUNT,
                      X_MSG_DATA                     => :l_MSG_DATA);
                      end;';

    EXECUTE IMMEDIATE l_plsql_block
      USING l_API_VERSION, l_ACCOUNT_DEFINITION_TYPE_CODE, l_ACCOUNT_DEFINITION_CODE, l_TRANSACTION_COA_ID, l_MODE,
      out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;

    l_plsql_block := 'begin
    fa_xla_tab_pkg.READ_ONLINE_TAB(
     P_API_VERSION                  => :l_API_VERSION,
     P_SOURCE_DISTRIB_ID_NUM_1      => :l_SOURCE_DISTRIB_ID_NUM_1,
     P_SOURCE_DISTRIB_ID_NUM_2      => :l_SOURCE_DISTRIB_ID_NUM_2,
     P_SOURCE_DISTRIB_ID_NUM_3      => :l_SOURCE_DISTRIB_ID_NUM_3,
     P_SOURCE_DISTRIB_ID_NUM_4      => :l_SOURCE_DISTRIB_ID_NUM_4,
     P_SOURCE_DISTRIB_ID_NUM_5      => :l_SOURCE_DISTRIB_ID_NUM_5,
     P_ACCOUNT_TYPE_CODE            => :l_ACCOUNT_TYPE_CODE,
     X_TARGET_CCID                  => :l_TARGET_CCID,
     X_CONCATENATED_SEGMENTS        => :l_CONCATENATED_SEGMENTS,
     X_RETURN_STATUS                => :l_RETURN_STATUS,
     X_MSG_COUNT                    => :l_MSG_COUNT ,
     X_MSG_DATA                     => :l_MSG_DATA);
     end;';

    EXECUTE IMMEDIATE l_plsql_block
      USING l_API_VERSION, l_SOURCE_DISTRIB_ID_NUM_1, l_SOURCE_DISTRIB_ID_NUM_2, l_SOURCE_DISTRIB_ID_NUM_3,
      l_SOURCE_DISTRIB_ID_NUM_4, l_SOURCE_DISTRIB_ID_NUM_5, l_ACCOUNT_TYPE_CODE, out l_TARGET_CCID,
      out l_CONCATENATED_SEGMENTS, out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;

    px_mass_add_rec.expense_code_combination_id := l_target_ccid;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return false;
    when others then
      return false;

  end;

  /********************************Prepare Location*******************/
  function prepare_location_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                               p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_location_col_name fnd_id_flex_segments.application_column_name%TYPE;
    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    TYPE num_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;
    l_segment                   varchar30_tbl;
    l_seg_num                   num_tbl;
    l_location_index            number;
    l_location_seg              number;
    l_gl_ccid_enabled_flag      varchar2(1);
    l_ACCOUNTING_FLEX_STRUCTURE fa_book_controls.accounting_flex_structure%type;
    l_location_id               number;
    l_debug_str                 varchar2(1000);
    l_loc_seg_name              varchar2(30) := null;
    l_calling_fn                varchar2(40) := 'prepare_location_id';
    loc_seg_clr_acct_map        varchar30_tbl;
    loc_seg_clr_acct_map_index  num_tbl;
    l_loc_query                 varchar2(1000);
    TYPE LocationCurType IS REF CURSOR;
    l_LocationCur LocationCurType;

    CURSOR lookup_cur(c_lookup_type varchar2) IS
      select lookup_code
        from fa_lookups
       where lookup_type = c_lookup_type
         and enabled_flag = 'Y';
  begin
    for i in 1 .. 30 loop
      l_segment(i) := null;
      l_seg_num(i) := -1;
    end loop;
    select location_id
      into l_location_id
      from fa_locations
     where rownum = 1;
    l_debug_str := 'Getting Mapping for Location';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       l_debug_str,
                       '',
                       p_log_level_rec => p_log_level_rec);
    end if;
    FOR rec IN lookup_cur('LOCATION MAPPING CLEAR ACCT') LOOP
      l_loc_seg_name := rec.lookup_code;
      l_seg_num(to_number(substr(l_loc_seg_name, 8))) := 1;
    END LOOP;
    if (l_loc_seg_name is not null) then
      l_debug_str := 'Get values from payables_ccid';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      select Segment1,
             Segment2,
             Segment3,
             Segment4,
             Segment5,
             Segment6,
             Segment7,
             Segment8,
             Segment9,
             Segment10,
             Segment11,
             Segment12,
             Segment13,
             Segment14,
             Segment15,
             Segment16,
             Segment17,
             Segment18,
             Segment19,
             Segment20,
             Segment21,
             Segment22,
             Segment23,
             Segment24,
             Segment25,
             Segment26,
             Segment27,
             Segment28,
             Segment29,
             Segment30,
             enabled_flag
        into l_segment(1),
             l_segment(2),
             l_segment(3),
             l_segment(4),
             l_segment(5),
             l_segment(6),
             l_segment(7),
             l_segment(8),
             l_segment(9),
             l_segment(10),
             l_segment(11),
             l_segment(12),
             l_segment(13),
             l_segment(14),
             l_segment(15),
             l_segment(16),
             l_segment(17),
             l_segment(18),
             l_segment(19),
             l_segment(20),
             l_segment(21),
             l_segment(22),
             l_segment(23),
             l_segment(24),
             l_segment(25),
             l_segment(26),
             l_segment(27),
             l_segment(28),
             l_segment(29),
             l_segment(30),
             l_gl_ccid_enabled_flag
        from gl_code_combinations
       where code_combination_id =
             px_mass_add_rec.payables_code_combination_id;

      for i in 1 .. 30 loop
        IF (l_seg_num(i) < 0) THEN
          l_segment(i) := null;
        END IF;
      end loop;
      l_debug_str := 'Get the Loaction';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      /* Location lookups mapping */

      FOR rec IN lookup_cur('LOCATION SEGMENT1 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(1) := rec.lookup_code;

      END LOOP;

      FOR rec IN lookup_cur('LOCATION SEGMENT2 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(2) := rec.lookup_code;

      END LOOP;
      FOR rec IN lookup_cur('LOCATION SEGMENT3 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(3) := rec.lookup_code;

      END LOOP;
      FOR rec IN lookup_cur('LOCATION SEGMENT4 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(4) := rec.lookup_code;

      END LOOP;
      FOR rec IN lookup_cur('LOCATION SEGMENT5 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(5) := rec.lookup_code;

      END LOOP;
      FOR rec IN lookup_cur('LOCATION SEGMENT6 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(6) := rec.lookup_code;

      END LOOP;
      FOR rec IN lookup_cur('LOCATION SEGMENT7 CLEAR ACCT') LOOP
        loc_seg_clr_acct_map(7) := rec.lookup_code;

      END LOOP;
      l_loc_query := 'select max(location_id) from fa_locations fa_loc where fa_loc.' ||
                     l_loc_seg_name || '= ' ||
                     l_segment(to_number(substr(l_loc_seg_name, 8))) || '
                     and location_id in (select location_id
			                 from fa_locations fa_loc2, gl_code_combinations gl_code
					 where fa_loc.segment1 = gl_code.' ||
                     loc_seg_clr_acct_map(1) ||
                     ' and fa_loc.segment2 = gl_code.' ||
                     loc_seg_clr_acct_map(2) ||
                     ' and fa_loc.segment3 = gl_code.' ||
                     loc_seg_clr_acct_map(3) ||
                     ' and fa_loc.segment4 = gl_code.' ||
                     loc_seg_clr_acct_map(4) ||
                     ' and fa_loc.segment5 = gl_code.' ||
                     loc_seg_clr_acct_map(5) ||
                     ' and fa_loc.segment6 = gl_code.' ||
                     loc_seg_clr_acct_map(6) ||
                     ' and fa_loc.segment7 = gl_code.' ||
                     loc_seg_clr_acct_map(7);
      OPEN l_LocationCur FOR l_loc_query;
      FETCH l_LocationCur
        INTO px_mass_add_rec.LOCATION_ID;
      close l_LocationCur;
    else

      px_mass_add_rec.LOCATION_ID := l_location_id;
    END IF;
    if (px_mass_add_rec.LOCATION_ID is null) then
      px_mass_add_rec.LOCATION_ID := l_location_id;
    end if;
    return true;
  exception
    when no_data_found then
      px_mass_add_rec.LOCATION_ID := l_location_id;
      return true;
    when too_many_rows then
      px_mass_add_rec.LOCATION_ID := l_location_id;
      return true;
    when others then
      px_mass_add_rec.LOCATION_ID := l_location_id;
      return false;
  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function prepare_group_asset_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                  p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_debug_str       varchar2(1000);
    l_status          number;
    l_group_asset_rec FA_CREATE_GROUP_ASSET_PKG.group_asset_rec_type;
    l_calling_fn      varchar2(40) := 'prepare_group_asset';
  begin
    l_group_asset_rec.asset_id         := null;
    l_group_asset_rec.mass_addition_id := px_mass_add_rec.mass_addition_id;
    l_group_asset_rec.rec_mode         := 'PREPARE';

    l_debug_str := 'energy calling create_group_asset';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       l_debug_str,
                       '',
                       p_log_level_rec => p_log_level_rec);
    end if;
    if not
        FA_CREATE_GROUP_ASSET_PKG.create_group_asset(l_group_asset_rec,
                                                     p_log_level_rec => p_log_level_rec) then
      l_debug_str := 'energy create_group_asset returned failure';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
    end if;
    px_mass_add_rec.group_asset_id := l_group_asset_rec.group_asset_id;
    return true;
  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function prepare_attributes(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                              p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_status         varchar2(10);
    l_debug_str      varchar2(1000);
    old_expense_ccid number := -1;
    new_expense_ccid number := -1;
    l_calling_fn     varchar2(40) := 'prepare_attributes';
  begin
    if (px_mass_add_rec.location_id is null) then
      if not prepare_location_id(px_mass_add_rec,
                                 p_log_level_rec => p_log_level_rec) then
        l_debug_str := ' energy prepare_location_id returned failure';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;
    if (px_mass_add_rec.expense_code_combination_id is null) then
      if not prepare_expense_ccid(px_mass_add_rec,
                                  p_log_level_rec => p_log_level_rec) then
        l_debug_str := 'energy prepare_expense_ccid returned failure';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;

    update fa_mass_additions
    set location_id = px_mass_add_rec.location_id,
        expense_code_combination_id = px_mass_add_rec.expensE_code_combination_id
    where mass_addition_id = px_mass_add_rec.mass_addition_id;
    commit;

    if (px_mass_add_rec.group_asset_id is null) then
      if not prepare_group_asset_id(px_mass_add_rec,
                                    p_log_level_rec => p_log_level_rec) then
        l_debug_str := 'energy prepare group_asset_id returned failure';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;
    l_debug_str := 'Calling check_addition_or_adj';
    if not (check_addition_or_adj(px_mass_add_rec,
                                  l_status,
                                  p_log_level_rec => p_log_level_rec)) then
      l_debug_str := 'check_addition_or_adj';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
    end if;

    if (l_status = 'ADDITION') then
      l_debug_str := 'Calling create_new_asset';
      if not (create_new_asset(px_mass_add_rec,
                               p_log_level_rec => p_log_level_rec)) then
        l_debug_str := 'create_new_asset';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;

    if (l_status = 'ADUSTMENT') then
      l_debug_str := 'Calling cost_adjustment';
      if not (cost_adjustment(px_mass_add_rec,
                              p_log_level_rec => p_log_level_rec)) then
        l_debug_str := 'cost_adjustment';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;
    l_debug_str := 'Validating expense account for distributions';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       l_debug_str,
                       '',
                       p_log_level_rec => p_log_level_rec);
    end if;
    if (px_mass_add_rec.distributions_table.count > 0) then
      old_expense_ccid := px_mass_add_rec.distributions_table(1)
                         .deprn_expense_ccid;
      for dist_count in 2 .. px_mass_add_rec.distributions_table.count loop

        new_expense_ccid := px_mass_add_rec.distributions_table(dist_count)
                           .deprn_expense_ccid;
        if (old_expense_ccid <> new_expense_ccid) then
          l_debug_str                    := 'Distributions has different expense account';
          px_mass_add_rec.POSTING_STATUS := 'ON HOLD';
          px_mass_add_rec.queue_name     := 'ON HOLD';
        end if;
        old_expense_ccid := new_expense_ccid;
      end loop;
    end if;

    return true;
  exception
    when others then
      return false;
  end;

end FA_MASSADD_PREP_ENERGY_PKG;

/
