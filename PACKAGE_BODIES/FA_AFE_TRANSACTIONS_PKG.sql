--------------------------------------------------------
--  DDL for Package Body FA_AFE_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_AFE_TRANSACTIONS_PKG" as
  /* $Header: FAAFETRB.pls 120.2.12010000.2 2009/07/19 12:56:29 glchen ship $ */


  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations

  -- Function and procedure implementations
  -- Author  : SKCHAWLA
  -- Created : 7/26/2005 5:32:12 PM
  FUNCTION get_new_ccid(p_book_type_code   varchar2,
                        p_old_expense_ccid number,
                        p_overlay_seg_val  number,
                        x_new_expense_ccid out NOCOPY number,
                        p_log_level_rec    IN FA_API_TYPES.log_level_rec_type default null)
    return boolean IS

    h_mesg_name          VARCHAR2(30);
    h_new_deprn_exp_acct VARCHAR2(26);
    --  h_new_ccid     NUMBER(15) := 0;
    gen_ccid_err EXCEPTION;
    h_cost_acct_ccid NUMBER := 0;

    h_chart_of_accounts_id   GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
    h_flex_segment_delimiter varchar2(5);
    h_flex_segment_number    number;
    h_num_of_segments        NUMBER;
    h_concat_array_segments  FND_FLEX_EXT.SEGMENTARRAY;

    h_appl_short_name varchar2(30);
    h_message_name    varchar2(30);
    h_num             number := 0;
    h_errmsg          varchar2(512);
    h_concat_segs     varchar2(2000) := '';
    h_delimiter       varchar2(1);

    l_err_stage  varchar2(250);
    l_calling_fn varchar2(40) := 'FA_AFE_TRANSACTIONS_PKG.get_new_ccid';

  BEGIN

    l_err_stage := 'Get Chart of Accounts ID';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => p_log_level_rec);
    end if;
    Select sob.chart_of_accounts_id
      into h_chart_of_accounts_id
      From fa_book_controls bc, gl_sets_of_books sob
     Where sob.set_of_books_id = bc.set_of_books_id
       And bc.book_type_code = p_book_type_code;

    l_err_stage := 'Get Account Qualifier Segment Number';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => p_log_level_rec);
    end if;
    IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(101,
                                               'GL#',
                                               h_chart_of_accounts_id,
                                               'FA_COST_CTR',
                                               h_flex_segment_number)) THEN
      RAISE gen_ccid_err;
    END IF;

    l_err_stage := 'Retrieve distribution segments';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => p_log_level_rec);
    end if;
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
                                      'GL#',
                                      h_chart_of_accounts_id,
                                      p_old_expense_ccid, --old_ccid,
                                      h_num_of_segments,
                                      h_concat_array_segments)) THEN

      RAISE gen_ccid_err;
    END IF;

    -- Updating array with new account value
    h_concat_array_segments(h_flex_segment_number) := p_overlay_seg_val;

    l_err_stage := 'Retrieve new ccid with overlaid account';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => p_log_level_rec);
    end if;
    --  get_combination_id function generates new ccid if rules allows.
    --  h_message_name := 'FND_FLEX_EXT.GET_COMBINATION_ID';

    IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID('SQLGL',
                                            'GL#',
                                            h_chart_of_accounts_id,
                                            SYSDATE,
                                            h_num_of_segments,
                                            h_concat_array_segments,
                                            x_new_expense_ccid)) THEN

      -- -- dbms_output.put_line('FND_FLEX_APIS.get_segment_delimiter');
      -- build message
      h_delimiter := FND_FLEX_APIS.get_segment_delimiter(101,
                                                         'GL#',
                                                         h_chart_of_accounts_id);

      -- fill the string for messaging with concat segs...
      while (h_num < h_num_of_segments) loop
        h_num := h_num + 1;

        if (h_num > 1) then
          h_concat_segs := h_concat_segs || h_delimiter;
        end if;

        h_concat_segs := h_concat_segs || h_concat_array_segments(h_num);

      end loop;

      h_errmsg := null;
      h_errmsg := FND_FLEX_EXT.GET_ENCODED_MESSAGE;

      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN      => 'FAFLEX_PKG_WF.START_PROCESS',
                              NAME            => 'FA_FLEXBUILDER_FAIL_CCID',
                              TOKEN1          => 'ACCOUNT_TYPE',
                              VALUE1          => 'DEPRN_EXP',
                              TOKEN2          => 'BOOK_TYPE_CODE',
                              VALUE2          => p_book_type_code,
                              TOKEN3          => 'DIST_ID',
                              VALUE3          => 'NEW',
                              TOKEN4          => 'CONCAT_SEGS',
                              VALUE4          => h_concat_segs,
                              p_log_level_rec => p_log_level_rec);

      fnd_message.set_encoded(h_errmsg);
      fnd_msg_pub.add;

      RAISE gen_ccid_err;
    END IF;

    RETURN(TRUE);

  EXCEPTION
    WHEN gen_ccid_err THEN
      FA_SRVR_MSG.add_message(CALLING_FN      => l_calling_fn,
                              NAME            => h_mesg_name,
                              p_log_level_rec => p_log_level_rec);
      RETURN(FALSE);
    WHEN OTHERS THEN
      FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN      => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);

      RETURN(FALSE);

  END get_new_ccid;

  -- Purpose : To capitalize the assets
  function process_capitalize(p_trans_int_rec      FA_API_TYPES.trans_interface_rec_type,
                              p_asset_id           number,
                              p_new_asset_key_ccid number,
                              p_log_level_rec      IN FA_API_TYPES.log_level_rec_type)
    return boolean is
    Result           boolean;
    l_trans_rec      FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec  FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec  FA_API_TYPES.asset_fin_rec_type;
    l_asset_desc_rec FA_API_TYPES.asset_desc_rec_type;
    l_asset_cat_rec  FA_API_TYPES.asset_cat_rec_type;

    l_CALENDAR_PERIOD_OPEN_DATE date;
    l_return_status             VARCHAR2(1);
    l_mesg_count                number := 0;
    l_mesg_len                  number;
    l_mesg                      varchar2(4000);
    l_book_type_code            varchar2(30);
    cost_center_seg             varchar(50);
    cost_center_seg_index       number;
    l_group_asset_rec           FA_CREATE_GROUP_ASSET_PKG.group_asset_rec_type;
    l_ACCOUNTING_FLEX_STRUCTURE fa_book_controls.accounting_flex_structure%type;
    l_asset_dist_tbl            fa_api_types.asset_dist_tbl_type;
    l_gl_ccid_enabled_flag      varchar2(1);
    l_log_level_rec             FA_API_TYPES.log_level_rec_type := p_log_level_rec;
    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    l_segment    varchar30_tbl;
    l_err_stage  varchar2(250);
    l_calling_fn varchar2(40) := 'FA_AFE_TRANSACTIONS_PKG.process_capitalize';

    cursor get_distributions(c_book_type_code varchar2, c_asset_id number) is
      select *
        from fa_distribution_history
       where book_type_code = c_book_type_code
         and asset_id = c_asset_id
         and date_ineffective is null;

  begin
    l_err_stage := 'Begin FA_AFE_TRANSACTIONS_PKG.process_capitalize';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    l_book_type_code := p_trans_int_rec.book_type_code;
    select CALENDAR_PERIOD_OPEN_DATE
      into l_CALENDAR_PERIOD_OPEN_DATE
      from fa_deprn_periods
     where period_close_date is null
       and book_type_code = l_book_type_code;
    -- asset header info
    l_asset_hdr_rec.asset_id       := p_asset_id;
    l_asset_hdr_rec.book_type_code := l_book_type_code;

    l_asset_fin_rec.date_placed_in_service := l_CALENDAR_PERIOD_OPEN_DATE;
    l_asset_fin_rec.dry_hole_flag          := 'N';
    l_err_stage                            := 'Calling capitalization API';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    FA_CIP_PUB.do_capitalization(p_api_version      => 1.0,
                                 p_init_msg_list    => FND_API.G_FALSE,
                                 p_commit           => FND_API.G_FALSE,
                                 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status    => l_return_status,
                                 x_msg_count        => l_mesg_count,
                                 x_msg_data         => l_mesg,
                                 p_calling_fn       => null,
                                 px_trans_rec       => l_trans_rec,
                                 px_asset_hdr_rec   => l_asset_hdr_rec,
                                 px_asset_fin_rec   => l_asset_fin_rec);

    l_err_stage := 'Change ASset Key and Transfer Report Center';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    if (p_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE is not null) then

      l_asset_hdr_rec                := null;
      l_asset_hdr_rec.asset_id       := p_asset_id;
      l_asset_hdr_rec.book_type_code := l_book_type_code;

      l_asset_desc_rec.asset_key_ccid := p_new_asset_key_ccid;
      l_err_stage                     := 'Calling asset descriptive API';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         'before ' || l_err_stage,
                         p_log_level_rec => l_log_level_rec);
      end if;
      FA_ASSET_DESC_PUB.update_desc(p_api_version         => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status       => l_return_status,
                                    x_msg_count           => l_mesg_count,
                                    x_msg_data            => l_mesg,
                                    p_calling_fn          => 'process_capitalize',
                                    px_trans_rec          => l_trans_rec,
                                    px_asset_hdr_rec      => l_asset_hdr_rec,
                                    px_asset_desc_rec_new => l_asset_desc_rec,
                                    px_asset_cat_rec_new  => l_asset_cat_rec);

      --do transfer

      select ACCOUNTING_FLEX_STRUCTURE
        into l_ACCOUNTING_FLEX_STRUCTURE
        from fa_book_controls
       where book_type_code = l_book_type_code;

      if not
          (FND_FLEX_APIS.get_segment_column(x_application_id  => 101,
                                            x_id_flex_code    => 'GL#',
                                            x_id_flex_num     => l_ACCOUNTING_FLEX_STRUCTURE,
                                            x_seg_attr_type   => 'FA_COST_CTR',
                                            x_app_column_name => cost_center_seg)) then
        null;
      end if;

      cost_center_seg_index := to_number(substr(cost_center_seg, 8));
      l_err_stage           := 'Check all distributions';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         'before ' || l_err_stage,
                         p_log_level_rec => l_log_level_rec);
      end if;
      for dist_rec in get_distributions(l_book_type_code, p_asset_id) loop

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
         where code_combination_id = dist_rec.code_combination_id;
        l_err_stage := 'Check distribution for the transfer';
        if (l_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           '-',
                           'before ' || l_err_stage,
                           p_log_level_rec => l_log_level_rec);
        end if;
        if (l_segment(cost_center_seg_index) =
           p_trans_int_rec.ASSET_KEY_HIERARCHY_VALUE) then

          l_asset_dist_tbl.delete;
          l_asset_hdr_rec                := null;
          l_asset_hdr_rec.asset_id       := p_asset_id;
          l_asset_hdr_rec.book_type_code := l_book_type_code;

          l_asset_dist_tbl(1).transaction_units := dist_rec.units_assigned;

          l_asset_dist_tbl(1).distribution_id := dist_rec.distribution_id;

          l_asset_dist_tbl(2).transaction_units := dist_rec.units_assigned;
          l_asset_dist_tbl(2).assigned_to := dist_rec.assigned_to;
          l_asset_dist_tbl(2).location_ccid := dist_rec.location_id;
          l_err_stage := 'Get new expense account for transfer';
          if (l_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             '-',
                             'before ' || l_err_stage,
                             p_log_level_rec => l_log_level_rec);
          end if;
          if not get_new_ccid(l_book_type_code,
                              dist_rec.code_combination_id,
                              p_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE,
                              l_asset_dist_tbl(2).expense_ccid) then
            null;
          end if;
          l_err_stage := 'Perform the transfer calling transfer API';
          if (l_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             '-',
                             'before ' || l_err_stage,
                             p_log_level_rec => l_log_level_rec);
          end if;
          FA_TRANSFER_PUB.do_transfer(p_api_version      => 1.0,
                                      p_init_msg_list    => FND_API.G_FALSE,
                                      p_commit           => FND_API.G_FALSE,
                                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                      x_return_status    => l_return_status,
                                      x_msg_count        => l_mesg_count,
                                      x_msg_data         => l_mesg,
                                      p_calling_fn       => 'process_capitalize',
                                      px_trans_rec       => l_trans_rec,
                                      px_asset_hdr_rec   => l_asset_hdr_rec,
                                      px_asset_dist_tbl  => l_asset_dist_tbl);
          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            null; --raise mtfr_err;
          end if;

        end if;

      end loop;
    end if;

    l_group_asset_rec.asset_id       := p_asset_id;
    l_group_asset_rec.rec_mode       := 'ITERFACE';
    l_group_asset_rec.book_type_code := l_book_type_code;
    l_err_stage                      := 'Calling create_group_asset';
    if not (FA_CREATE_GROUP_ASSET_PKG.create_group_asset(l_group_asset_rec)) then
      l_err_stage := 'create_group_asset_failed';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         l_err_stage,
                         p_log_level_rec => l_log_level_rec);
        return false;
      end if;
    end if;

    if (l_return_status = 'Y') then
      return true;
    else
      return false;
    end if;

    return(Result);
  exception
    when others then
      return false;
  end process_capitalize;

  function process_dry_hole(p_trans_int_rec      FA_API_TYPES.trans_interface_rec_type,
                            p_asset_id           number,
                            p_new_asset_key_ccid number,
                            p_log_level_rec      IN FA_API_TYPES.log_level_rec_type)
    return boolean is
    Result           boolean;
    l_trans_rec      FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec  FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec  FA_API_TYPES.asset_fin_rec_type;
    l_asset_desc_rec FA_API_TYPES.asset_desc_rec_type;
    l_asset_cat_rec  FA_API_TYPES.asset_cat_rec_type;

    l_CALENDAR_PERIOD_OPEN_DATE date;
    l_return_status             VARCHAR2(1);
    l_mesg_count                number := 0;
    l_mesg_len                  number;
    l_mesg                      varchar2(4000);
    l_book_type_code            varchar2(30);
    cost_center_seg             varchar(50);
    cost_center_seg_index       number;
    l_group_asset_rec           FA_CREATE_GROUP_ASSET_PKG.group_asset_rec_type;
    l_ACCOUNTING_FLEX_STRUCTURE fa_book_controls.accounting_flex_structure%type;
    l_asset_dist_tbl            fa_api_types.asset_dist_tbl_type;
    l_gl_ccid_enabled_flag      varchar2(1);
    l_log_level_rec             FA_API_TYPES.log_level_rec_type := p_log_level_rec;
    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    l_segment    varchar30_tbl;
    l_err_stage  varchar2(250);
    l_calling_fn varchar2(40) := 'FA_AFE_TRANSACTIONS_PKG.process_dry_hole';
    cursor get_distributions(c_book_type_code varchar2, c_asset_id number) is
      select *
        from fa_distribution_history
       where book_type_code = c_book_type_code
         and asset_id = c_asset_id
         and date_ineffective is null;
  begin
    l_err_stage := 'Begin FA_AFE_TRANSACTIONS_PKG.process_capitalize';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    l_book_type_code := p_trans_int_rec.book_type_code;
    select CALENDAR_PERIOD_OPEN_DATE
      into l_CALENDAR_PERIOD_OPEN_DATE
      from fa_deprn_periods
     where period_close_date is null
       and book_type_code = l_book_type_code;
    -- asset header info
    l_asset_hdr_rec.asset_id       := p_asset_id;
    l_asset_hdr_rec.book_type_code := l_book_type_code;

    l_asset_fin_rec.date_placed_in_service := l_CALENDAR_PERIOD_OPEN_DATE;
    l_asset_fin_rec.dry_hole_flag          := 'Y';
    l_err_stage                            := 'Calling capitalization API';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    FA_CIP_PUB.do_capitalization(p_api_version      => 1.0,
                                 p_init_msg_list    => FND_API.G_FALSE,
                                 p_commit           => FND_API.G_FALSE,
                                 p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                 x_return_status    => l_return_status,
                                 x_msg_count        => l_mesg_count,
                                 x_msg_data         => l_mesg,
                                 p_calling_fn       => null,
                                 px_trans_rec       => l_trans_rec,
                                 px_asset_hdr_rec   => l_asset_hdr_rec,
                                 px_asset_fin_rec   => l_asset_fin_rec);

    l_err_stage := 'Change ASset Key and Transfer Report Center';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;
    if (p_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE is not null) then

      l_asset_hdr_rec                := null;
      l_asset_hdr_rec.asset_id       := p_asset_id;
      l_asset_hdr_rec.book_type_code := l_book_type_code;

      l_asset_desc_rec.asset_key_ccid := p_new_asset_key_ccid;
      l_err_stage                     := 'Calling asset descriptive API';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         'before ' || l_err_stage,
                         p_log_level_rec => l_log_level_rec);
      end if;
      FA_ASSET_DESC_PUB.update_desc(p_api_version         => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status       => l_return_status,
                                    x_msg_count           => l_mesg_count,
                                    x_msg_data            => l_mesg,
                                    p_calling_fn          => 'process_capitalize',
                                    px_trans_rec          => l_trans_rec,
                                    px_asset_hdr_rec      => l_asset_hdr_rec,
                                    px_asset_desc_rec_new => l_asset_desc_rec,
                                    px_asset_cat_rec_new  => l_asset_cat_rec);

      --do transfer

      select ACCOUNTING_FLEX_STRUCTURE
        into l_ACCOUNTING_FLEX_STRUCTURE
        from fa_book_controls
       where book_type_code = l_book_type_code;

      if not
          (FND_FLEX_APIS.get_segment_column(x_application_id  => 101,
                                            x_id_flex_code    => 'GL#',
                                            x_id_flex_num     => l_ACCOUNTING_FLEX_STRUCTURE,
                                            x_seg_attr_type   => 'FA_COST_CTR',
                                            x_app_column_name => cost_center_seg)) then
        null;
      end if;

      cost_center_seg_index := to_number(substr(cost_center_seg, 8));
      l_err_stage           := 'Check all distributions';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         'before ' || l_err_stage,
                         p_log_level_rec => l_log_level_rec);
      end if;
      for dist_rec in get_distributions(l_book_type_code, p_asset_id) loop

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
         where code_combination_id = dist_rec.code_combination_id;
        l_err_stage := 'Check distribution for the transfer';
        if (l_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           '-',
                           'before ' || l_err_stage,
                           p_log_level_rec => l_log_level_rec);
        end if;
        if (l_segment(cost_center_seg_index) =
           p_trans_int_rec.ASSET_KEY_HIERARCHY_VALUE) then

          l_asset_dist_tbl.delete;
          l_asset_hdr_rec                := null;
          l_asset_hdr_rec.asset_id       := p_asset_id;
          l_asset_hdr_rec.book_type_code := l_book_type_code;

          l_asset_dist_tbl(1).transaction_units := dist_rec.units_assigned;

          l_asset_dist_tbl(1).distribution_id := dist_rec.distribution_id;

          l_asset_dist_tbl(2).transaction_units := dist_rec.units_assigned;
          l_asset_dist_tbl(2).assigned_to := dist_rec.assigned_to;
          l_asset_dist_tbl(2).location_ccid := dist_rec.location_id;
          l_err_stage := 'Get new expense account for transfer';
          if (l_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             '-',
                             'before ' || l_err_stage,
                             p_log_level_rec => l_log_level_rec);
          end if;
          if not get_new_ccid(l_book_type_code,
                              dist_rec.code_combination_id,
                              p_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE,
                              l_asset_dist_tbl(2).expense_ccid) then
            null;
          end if;
          l_err_stage := 'Perform the transfer calling transfer API';
          if (l_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             '-',
                             'before ' || l_err_stage,
                             p_log_level_rec => l_log_level_rec);
          end if;
          FA_TRANSFER_PUB.do_transfer(p_api_version      => 1.0,
                                      p_init_msg_list    => FND_API.G_FALSE,
                                      p_commit           => FND_API.G_FALSE,
                                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                                      x_return_status    => l_return_status,
                                      x_msg_count        => l_mesg_count,
                                      x_msg_data         => l_mesg,
                                      p_calling_fn       => 'process_capitalize',
                                      px_trans_rec       => l_trans_rec,
                                      px_asset_hdr_rec   => l_asset_hdr_rec,
                                      px_asset_dist_tbl  => l_asset_dist_tbl);
          if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            null; --raise mtfr_err;
          end if;

        end if;

      end loop;
    end if;

    l_group_asset_rec.asset_id       := p_asset_id;
    l_group_asset_rec.rec_mode       := 'ITERFACE';
    l_group_asset_rec.book_type_code := l_book_type_code;
    l_err_stage                      := 'Calling create_group_asset';
    if not (FA_CREATE_GROUP_ASSET_PKG.create_group_asset(l_group_asset_rec)) then
      l_err_stage := 'create_group_asset_failed';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         l_err_stage,
                         p_log_level_rec => l_log_level_rec);
        return false;
      end if;
    end if;

    if (l_return_status = 'Y') then
      return true;
    else
      return false;
    end if;

    return(Result);
  exception
    when others then
      return false;
  end process_dry_hole;

  function process_expense(p_trans_int_rec FA_API_TYPES.trans_interface_rec_type,
                           p_asset_id      number,
                           p_log_level_rec IN FA_API_TYPES.log_level_rec_type)
    return boolean is
    Result             boolean;
    l_book_type_code   varchar2(30);
    l_trans_rec        FA_API_TYPES.trans_rec_type;
    l_dist_trans_rec   FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
    l_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
    l_asset_dist_tbl   FA_API_TYPES.asset_dist_tbl_type;
    l_subcomp_tbl      FA_API_TYPES.subcomp_tbl_type;
    l_inv_tbl          FA_API_TYPES.inv_tbl_type;

    l_api_version      number := 1;
    l_init_msg_list    varchar2(1) := FND_API.G_FALSE;
    l_commit           varchar2(1) := FND_API.G_FALSE;
    l_validation_level number := FND_API.G_VALID_LEVEL_FULL;

    l_return_status VARCHAR2(1);
    l_mesg_count    number := 0;
    l_mesg_len      number;
    l_mesg          varchar2(4000);

    l_log_level_rec FA_API_TYPES.log_level_rec_type := p_log_level_rec;

    l_err_stage  varchar2(250);
    l_calling_fn varchar2(40) := 'FA_AFE_TRANSACTIONS_PKG.process_expense';
  begin
    l_book_type_code := p_trans_int_rec.book_type_code;

    l_asset_hdr_rec.asset_id       := p_asset_id;
    l_asset_hdr_rec.book_type_code := l_book_type_code;
    select cost
      into l_asset_retire_rec.cost_retired
      from fa_books
     where book_type_code = l_book_type_code
       and asset_id = p_asset_id
       and transaction_header_id_out is null;

    FA_RETIREMENT_PUB.do_retirement(p_api_version       => l_api_version,
                                    p_init_msg_list     => l_init_msg_list,
                                    p_commit            => l_commit,
                                    p_validation_level  => l_validation_level,
                                    p_calling_fn        => l_calling_fn,
                                    x_return_status     => l_return_status,
                                    x_msg_count         => l_mesg_count,
                                    x_msg_data          => l_mesg,
                                    px_trans_rec        => l_trans_rec,
                                    px_dist_trans_rec   => l_dist_trans_rec,
                                    px_asset_hdr_rec    => l_asset_hdr_rec,
                                    px_asset_retire_rec => l_asset_retire_rec,
                                    p_asset_dist_tbl    => l_asset_dist_tbl,
                                    p_subcomp_tbl       => l_subcomp_tbl,
                                    p_inv_tbl           => l_inv_tbl);

    return(Result);
  exception
    when others then
      return false;
  end process_expense;

end FA_AFE_TRANSACTIONS_PKG;

/
