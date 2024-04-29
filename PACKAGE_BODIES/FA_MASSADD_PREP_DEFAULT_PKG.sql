--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_PREP_DEFAULT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_PREP_DEFAULT_PKG" as
  /* $Header: FAMAPREPDB.pls 120.5.12010000.3 2009/07/19 09:45:43 glchen ship $ */

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations
  -- Function and procedure implementations
  function prepare_asset_category_id(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                                     p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_gl_ccid_rec  GL_CODE_COMBINATIONS%ROWTYPE;
    l_mass_add_rec FA_MASSADD_PREPARE_PKG.mass_add_rec;
    l_debug_str    varchar2(500);
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
    h_chart_of_accounts_id      GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
    l_account_segment varchar2(30);
    l_calling_fn      varchar2(40) := 'prepare_asset_category_id';
    h_flex_segment_number       number;
    l_asset_clearing_acct       varchar2(25);
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
      select ACCOUNTING_FLEX_STRUCTURE
        into l_ACCOUNTING_FLEX_STRUCTURE
        from fa_book_controls
       where book_type_code = px_mass_add_rec.BOOK_TYPE_CODE;

      IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                          101,
                          'GL#',
                           h_chart_of_accounts_id,
                          'GL_ACCOUNT',
                           h_flex_segment_number)) THEN
        null;
      end if;

      l_seg_num(h_flex_segment_number) := 1;

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
        and CHART_OF_ACCOUNTS_ID = h_chart_of_accounts_id;

      for i in 1 .. 30 loop
        IF (l_seg_num(i) < 0) THEN
          l_segment(i) := null;
        END IF;
      end loop;

      for i in 1 .. 30 loop
        IF (i = h_flex_segment_number) THEN
          l_asset_clearing_acct := l_segment(i);
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
         where ASSET_CLEARING_ACCT = l_asset_clearing_acct
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
        select category_id
          into px_mass_add_rec.ASSET_CATEGORY_ID
          from fa_category_books
         where CIP_CLEARING_ACCT = l_asset_clearing_acct
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
    l_calling_fn                varchar2(40) := 'prepare_expense_ccid';
    h_chart_of_accounts_id      GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
    h_flex_segment_delimiter    varchar2(5);
    h_flex_segment_number       number;
    h_num_of_segments           NUMBER;
    h_concat_array_segments     FND_FLEX_EXT.SEGMENTARRAY;
    h_new_deprn_exp_acct        VARCHAR2(26);
    h_cost_acct_ccid            NUMBER := 0;
    h_cost_clearing_acct_ccid            NUMBER := 0;
    l_API_VERSION               NUMBER := 1.0;
    l_SOURCE_DISTRIB_ID_NUM_1   NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_2   NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_3   NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_4   NUMBER;
    l_SOURCE_DISTRIB_ID_NUM_5   NUMBER;
    l_ACCOUNT_TYPE_CODE         VARCHAR2(30) := 'FA_EXPENSE_ACCT';
    l_DEPRN_EXPENSE_ACCT_CCID   NUMBER;
    l_PAYABLES_CCID             NUMBER;
    l_default_ccid              number;

    l_ACCOUNT_DEFINITION_TYPE_CODE VARCHAR2(30) := 'S';
    l_ACCOUNT_DEFINITION_CODE      VARCHAR2(30) := 'FA_EXPENSE_ACCT2';
    l_TRANSACTION_COA_ID           NUMBER := 101;
    l_MODE                         VARCHAR2(30) := 'ONLINE';
    l_RETURN_STATUS                VARCHAR2(1);
    l_MSG_COUNT                    NUMBER;
    l_MSG_DATA                     VARCHAR2(255);

    l_TARGET_CCID           NUMBER;
    l_CONCATENATED_SEGMENTS VARCHAR2(4000);
    l_plsql_block           varchar2(1000);

    h_num              number := 0;
    h_string           varchar2(100);
    h_errmsg           varchar2(512);
    h_concat_segs      varchar2(2000) := '';
    h_delimiter        varchar2(1);
    l_debug_str        varchar2(500);
    prepare_expense_ccid_error EXCEPTION;
  begin
/*commented for bug 4928682
    select FLEXBUILDER_DEFAULTS_CCID
    into l_default_ccid
    from fa_book_controls
    where book_type_code = px_mass_add_rec.book_type_code;
*/
    SELECT deprn_expense_acct,
           asset_cost_account_ccid,
           ASSET_CLEARING_ACCOUNT_CCID
    INTO   h_new_deprn_exp_acct,
           h_cost_acct_ccid,
           h_cost_clearing_acct_ccid
    FROM
           fa_category_books
    WHERE  book_type_code = px_mass_add_rec.book_type_code
    AND    category_id = px_mass_add_rec.asset_category_id;

 --  Get Chart of Accounts ID
    Select  sob.chart_of_accounts_id
    into    h_chart_of_accounts_id
    From    fa_book_controls bc,
            gl_sets_of_books sob
    Where   sob.set_of_books_id = bc.set_of_books_id
    And     bc.book_type_code  = px_mass_add_rec.book_type_code;

/* Use the clearing ccid and then overlay the account segment with deprn exp acct from
  the category which will be returned when there is 1 to 1 setup in terms of category and
  clearing account in Asset Clearing acount.*/

    l_TRANSACTION_COA_ID := h_chart_of_accounts_id;

    l_PAYABLES_CCID           := px_mass_add_rec.payables_code_combination_id;

  --  Get Account Qualifier Segment Number
    IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                          101,
                          'GL#',
                           h_chart_of_accounts_id,
                          'GL_ACCOUNT',
                           h_flex_segment_number)) THEN
                RAISE prepare_expense_ccid_error;
    END IF;
-- Retreive segments
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
                         'GL#',
                         h_chart_of_accounts_id,
--bug 8596581                         h_cost_clearing_acct_ccid,
                         l_PAYABLES_CCID,
                         h_num_of_segments,
                         h_concat_array_segments)) THEN

                RAISE prepare_expense_ccid_error;
    END IF;
-- Updating array with new account value
    h_concat_array_segments(h_flex_segment_number) := h_new_deprn_exp_acct;

-- Retrieve new ccid with overlaid account
--  get_combination_id function generates new ccid if rules allows.
    IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID(
                         'SQLGL',
                         'GL#',
                         h_chart_of_accounts_id,
                         SYSDATE,
                         h_num_of_segments,
                         h_concat_array_segments,
                         l_target_ccid)) THEN

        h_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                       101,
                       'GL#',
                       h_chart_of_accounts_id);

        -- fill the string for messaging with concat segs...

        while (h_num < h_num_of_segments) loop

           h_num := h_num + 1;

           if (h_num > 1) then
              h_concat_segs := h_concat_segs ||
                               h_delimiter;
           end if;

           h_concat_segs := h_concat_segs ||
                            h_concat_array_segments(h_num);

        end loop;

        h_errmsg := FND_FLEX_EXT.GET_ENCODED_MESSAGE;


        FA_SRVR_MSG.ADD_MESSAGE
               (CALLING_FN=>'FAFLEX_PKG_WF.START_PROCESS',
                NAME=>'FA_FLEXBUILDER_FAIL_CCID',
                TOKEN1 => 'ACCOUNT_TYPE',
                VALUE1 => 'DEPRN_EXP',
                TOKEN2 => 'BOOK_TYPE_CODE',
                VALUE2 => px_mass_add_rec.book_type_code,
                TOKEN3 => 'DIST_ID',
                VALUE3 => 'NEW',
                TOKEN4 => 'CONCAT_SEGS',
                VALUE4 => h_concat_segs
                );

        fnd_message.set_encoded(h_errmsg);
        fnd_msg_pub.add;



        RAISE prepare_expense_ccid_error;
   END IF;
 l_debug_str := 'Generated Expense CCID '|| to_char(l_target_ccid);
 if (p_log_level_rec.statement_level) then
   fa_debug_pkg.add(l_calling_fn,
                   l_debug_str,
                   '',
                   p_log_level_rec => p_log_level_rec);
 end if;

/*commented for bug 4928682
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
            l_SOURCE_DISTRIB_ID_NUM_4, l_SOURCE_DISTRIB_ID_NUM_5, l_ACCOUNT_TYPE_CODE,
            l_default_ccid,l_DEPRN_EXPENSE_ACCT_CCID,
            l_PAYABLES_CCID, out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;

    l_plsql_block := 'begin
                      FA_XLA_TAB_PKG.run(
                      P_API_VERSION                  => :l_API_VERSION,
                      P_ACCOUNT_DEFINITION_TYPE_CODE => :l_ACCOUNT_DEFINITION_TYPE_CODE,
                      P_ACCOUNT_DEFINITION_CODE      => :l_ACCOUNT_DEFINITION_CODE,
                      P_TRANSACTION_COA_ID           => :l_TRANSACTION_COA_ID ,
                      P_MODE                         => :l_MODE,
                      X_RETURN_STATUS                => :l_RETURN_STATUS,
                      X_MSG_COUNT                    => :l_MSG_COUNT,
                      X_MSG_DATA                     => :l_MSG_DATA)
                      end;';

    EXECUTE IMMEDIATE l_plsql_block
      USING l_API_VERSION, l_ACCOUNT_DEFINITION_TYPE_CODE, l_ACCOUNT_DEFINITION_CODE, l_TRANSACTION_COA_ID,
            l_MODE, out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;

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
                        X_MSG_DATA                     => :l_MSG_DATA)
                       end;';

    EXECUTE IMMEDIATE l_plsql_block
      USING l_API_VERSION, l_SOURCE_DISTRIB_ID_NUM_1, l_SOURCE_DISTRIB_ID_NUM_2, l_SOURCE_DISTRIB_ID_NUM_3,
            l_SOURCE_DISTRIB_ID_NUM_4, l_SOURCE_DISTRIB_ID_NUM_5, l_ACCOUNT_TYPE_CODE, out l_TARGET_CCID,
            out l_CONCATENATED_SEGMENTS, out l_RETURN_STATUS, out l_MSG_COUNT, out l_MSG_DATA;
*/

    px_mass_add_rec.expense_code_combination_id := l_target_ccid;

    return true;
  exception
    when prepare_expense_ccid_error then
        l_debug_str := 'Unable to generate the Expense Account';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;

        return false;
    when no_data_found then
      return false;
    when too_many_rows then
      return false;
    when others then
      return false;

  end;

  function prepare_attributes(px_mass_add_rec IN out NOCOPY FA_MASSADD_PREPARE_PKG.mass_add_rec,
                              p_log_level_rec IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is

    Result       boolean;
    l_status     number;
    l_debug_str  varchar2(1000);
    l_calling_fn varchar2(40) := 'prepare_attributes';
  begin

    if (px_mass_add_rec.asset_category_id is null) then
      l_debug_str := 'calling prepare_asset_category_id';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      if not
          prepare_asset_category_id(px_mass_add_rec,
                                    p_log_level_rec => p_log_level_rec) then
        null;
      end if;
    end if;

    if (px_mass_add_rec.expense_code_combination_id is null) then
      l_debug_str := 'Calling prepare_expense_ccid';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      if not prepare_expense_ccid(px_mass_add_rec,
                                  p_log_level_rec => p_log_level_rec) then
        l_debug_str := 'Default prepare_expense_ccid returned failure';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
      end if;
    end if;
    Result := True;
    return(Result);
  exception
    when others then
      return false;
  end prepare_attributes;

end FA_MASSADD_PREP_DEFAULT_PKG;

/
