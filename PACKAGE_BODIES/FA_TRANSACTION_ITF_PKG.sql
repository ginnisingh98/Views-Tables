--------------------------------------------------------
--  DDL for Package Body FA_TRANSACTION_ITF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSACTION_ITF_PKG" as
  /* $Header: FATRXITFB.pls 120.1.12010000.2 2009/07/19 12:58:55 glchen ship $ */


  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations
  g_log_level_rec fa_api_types.log_level_rec_type;

  -- Private Function and Procedures declarations
  -- Function and procedure implementations
  function check_asset_book(p_book_type_code varchar2, p_asset_id number)
    return boolean is
    l_check number;
  begin
    begin
      select 1
        into l_check
        from fa_books
       where book_type_code = p_book_type_code
         and asset_id = p_asset_id
         and transaction_header_id_out is null
         and rownum < 2;
      return true;
    exception
      when no_data_found then
        return false;
      when others then
        return false;
    end;
  end;
  -- Author  : SKCHAWLA
  -- Created : 7/18/2005 1:58:52 PM
  -- Purpose : To process the assets for AFE Reclassification
  procedure process_transaction_interface(p_book_type_code in varchar2,
                           x_request_id     OUT NOCOPY number,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2,
                           x_return_status  OUT NOCOPY number) is

    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    TYPE trans_int_rec_tbl IS TABLE OF FA_API_TYPES.trans_interface_rec_type INDEX BY BINARY_INTEGER;
    l_akey_segment       varchar30_tbl;
    l_akey_ccid          number;
    l_trans_int_rec      FA_API_TYPES.trans_interface_rec_type;
    l_trans_int_rec_tbl  trans_int_rec_tbl;
    l_batch_size         number := 100;
    l_akey_grp_seg       varchar2(30);
    l_akey_grp_seg_index number;
    l_here_key_seg       varchar2(30);

    l_here_key_seg_index number;

    l_asset_id           number;
    l_new_asset_key_ccid number;
    l_err_stage          varchar2(640);
    l_log_level_rec      FA_API_TYPES.log_level_rec_type;
    afe_err EXCEPTION;
    l_calling_fn varchar2(250) := 'FA_AFE_RECLASS_PKG.process_transaction_interface';
    cursor get_interface_assets(c_book_type_code varchar2) is
      Select TRANSACTION_INTERFACE_ID,
             TRANSACTION_DATE,
             TRANSACTION_TYPE_CODE,
             POSTING_STATUS,
             BOOK_TYPE_CODE,
             ASSET_KEY_PROJECT_VALUE,
             ASSET_KEY_HIERARCHY_VALUE,
             ASSET_KEY_NEW_HIERARCHY_VALUE,
             REFERENCE_NUMBER,
             COMMENTS,
             CONCURRENT_REQUEST_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        from fa_transaction_interface
       where book_type_code = c_book_type_Code;

    CURSOR lookup_cur(c_lookup_type varchar2) IS
      select lookup_code
        from fa_lookups
       where lookup_type = c_lookup_type
         and enabled_flag = 'Y'
         and nvl(end_date_active, sysdate) >= sysdate
         and rownum = 1;

    cursor get_asset_key_ccid(c_akey_seg varchar30_tbl) is
      SELECT code_combination_id
        INTO l_akey_ccid
        FROM fa_asset_keywords
       WHERE nvl(segment1, '-1') = nvl(c_akey_seg(1), '-1')
         and nvl(segment2, '-1') = nvl(c_akey_seg(2), '-1')
         and nvl(segment3, '-1') = nvl(c_akey_seg(3), '-1')
         and nvl(segment4, '-1') = nvl(c_akey_seg(4), '-1')
         and nvl(segment5, '-1') = nvl(c_akey_seg(5), '-1')
         and nvl(segment6, '-1') = nvl(c_akey_seg(6), '-1')
         and nvl(segment7, '-1') = nvl(c_akey_seg(7), '-1')
         and nvl(segment8, '-1') = nvl(c_akey_seg(8), '-1')
         and nvl(segment9, '-1') = nvl(c_akey_seg(9), '-1')
         and nvl(segment10, '-1') = nvl(c_akey_seg(10), '-1');

    cursor get_cip_assets(c_akey_seg varchar30_tbl) is
      select asset_id
        from fa_additions
       where asset_type = 'CIP'
         and asset_key_ccid in
             (SELECT code_combination_id
                FROM fa_asset_keywords
               WHERE nvl(segment1, '-1') =
                     nvl(c_akey_seg(1), nvl(segment1, '-1'))
                 and nvl(segment2, '-1') =
                     nvl(c_akey_seg(2), nvl(segment2, '-1'))
                 and nvl(segment3, '-1') =
                     nvl(c_akey_seg(3), nvl(segment1, '-1'))
                 and nvl(segment4, '-1') =
                     nvl(c_akey_seg(4), nvl(segment4, '-1'))
                 and nvl(segment5, '-1') =
                     nvl(c_akey_seg(5), nvl(segment5, '-1'))
                 and nvl(segment6, '-1') =
                     nvl(c_akey_seg(6), nvl(segment6, '-1'))
                 and nvl(segment7, '-1') =
                     nvl(c_akey_seg(7), nvl(segment7, '-1'))
                 and nvl(segment8, '-1') =
                     nvl(c_akey_seg(8), nvl(segment8, '-1'))
                 and nvl(segment9, '-1') =
                     nvl(c_akey_seg(9), nvl(segment9, '-1'))
                 and nvl(segment10, '-1') =
                     nvl(c_akey_seg(10), nvl(segment10, '-1')));

  begin

    SAVEPOINT AFE_Reclass_Asset_Begin;
    l_err_stage := 'Begin FA_AFE_RECLASS_PKG.process_transaction_interface';
    if (not g_log_level_rec.initialized) then
      if (NOT
          fa_util_pub.get_log_level_rec(x_log_level_rec => g_log_level_rec)) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
    end if;

    l_err_stage := 'Get Lookup values';
    if (l_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       '-',
                       'before ' || l_err_stage,
                       p_log_level_rec => l_log_level_rec);
    end if;

    /* get the asset key mapping */
    FOR rec IN lookup_cur('ASSET KEY PROJECT MAPPING') LOOP
      l_akey_grp_seg       := rec.lookup_code;
      l_akey_grp_seg_index := to_number(substr(l_akey_grp_seg, 8));
    END LOOP;

    FOR rec IN lookup_cur('ASSET KEY HIERARCHY MAPPING') LOOP
      l_here_key_seg       := rec.lookup_code;
      l_here_key_seg_index := to_number(substr(l_here_key_seg, 8));
    END LOOP;
    l_err_stage := 'Fetching all records from the interface table ';
    /* get all the records from interface table */
    open get_interface_assets(p_book_type_code);
    while true loop

      fetch get_interface_assets BULK COLLECT
        INTO l_trans_int_rec_tbl limit l_batch_size;

      if (get_interface_assets%NOTFOUND) and
         (l_trans_int_rec_tbl.count < 1) then
        exit;
      end if;
      l_err_stage := 'Looping through all records of interface table';
      if (l_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         '-',
                         'before ' || l_err_stage,
                         p_log_level_rec => l_log_level_rec);
      end if;

      for l_count in 1 .. l_trans_int_rec_tbl.count loop
        l_trans_int_rec := l_trans_int_rec_tbl(l_count);

        if (l_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE is not null) then
          l_err_stage := 'Find the new asset key for new report center';
          for i in 1 .. 30 loop
            if (i = l_here_key_seg_index) then
              l_akey_segment(i) := l_trans_int_rec.ASSET_KEY_NEW_HIERARCHY_VALUE;
            elsif (i = l_akey_grp_seg_index) then
              l_akey_segment(i) := l_trans_int_rec.ASSET_KEY_PROJECT_VALUE;
            else
              l_akey_segment(i) := null;
            end if;
          end loop;

          begin
            open get_asset_key_ccid(l_akey_segment);
            fetch get_asset_key_ccid
              into l_new_asset_key_ccid;
            close get_asset_key_ccid;
          exception
            when no_data_found then
              null;
          end;
        end if;

        for i in 1 .. 30 loop
          if (i = l_here_key_seg_index) then
            l_akey_segment(i) := l_trans_int_rec.ASSET_KEY_HIERARCHY_VALUE;
          elsif (i = l_akey_grp_seg_index) then
            l_akey_segment(i) := l_trans_int_rec.ASSET_KEY_PROJECT_VALUE;
          else
            l_akey_segment(i) := null;
          end if;
        end loop;
        l_err_stage := '*get all assets matching AFE Number and HIERARCHY value';
        if (l_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           '-',
                           'before ' || l_err_stage,
                           p_log_level_rec => l_log_level_rec);
        end if;

        /*get all assets matching AFE Number and HIERARCHY value*/
        open get_cip_assets(l_akey_segment);
        while true loop
          /*fetch the cipa sset from fa_Additions */
          fetch get_cip_assets
            into l_asset_id;

          if (get_cip_assets%NOTFOUND) then
            exit;
          end if;
          l_err_stage := 'check whether asset belongs to selected book';
          if (l_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             '-',
                             'before ' || l_err_stage,
                             p_log_level_rec => l_log_level_rec);
          end if;

          /* check whether asset belongs to selected book or not */
          if (check_asset_book(p_book_type_code, l_asset_id)) then

            if (l_trans_int_rec.transaction_type_code = 'CAPITALIZE') then

              l_err_stage := 'Calling FA_AFE_TRANSACTIONS_PKG.process_capitalize';
              if (l_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 '-',
                                 'before ' || l_err_stage,
                                 p_log_level_rec => l_log_level_rec);
              end if;

              if not
                  (FA_AFE_TRANSACTIONS_PKG.process_capitalize(l_trans_int_rec,
                                                              l_asset_id,
                                                              l_new_asset_key_ccid,
                                                              l_log_level_rec)) then
                l_err_stage := 'FA_AFE_TRANSACTIONS_PKG.process_capitalize failed';
                if (l_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                                   '-',
                                   l_err_stage || 'For ' ||
                                   l_trans_int_rec.transaction_interface_id,
                                   p_log_level_rec => l_log_level_rec);
                end if;

              end if;
            elsif (l_trans_int_rec.transaction_type_code = 'DRY HOLE') then
              l_err_stage := 'Calling FA_AFE_TRANSACTIONS_PKG.process_dry_hole';
              if (l_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 '-',
                                 'before ' || l_err_stage,
                                 p_log_level_rec => l_log_level_rec);
              end if;

              if not
                  (FA_AFE_TRANSACTIONS_PKG.process_dry_hole(l_trans_int_rec,
                                                            l_asset_id,
                                                            l_new_asset_key_ccid,
                                                            l_log_level_rec)) then

                l_err_stage := 'FA_AFE_TRANSACTIONS_PKG.process_dry_hole failed';
                if (l_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                                   '-',
                                   l_err_stage || 'For ' ||
                                   l_trans_int_rec.transaction_interface_id,
                                   p_log_level_rec => l_log_level_rec);
                end if;
              end if;
            elsif (l_trans_int_rec.transaction_type_code = 'EXPENSE') then

              l_err_stage := 'Calling FA_AFE_TRANSACTIONS_PKG.process_expense';
              if (l_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 '-',
                                 'before ' || l_err_stage,
                                 p_log_level_rec => l_log_level_rec);
              end if;

              if not
                  (FA_AFE_TRANSACTIONS_PKG.process_expense(l_trans_int_rec,
                                                           l_asset_id,
                                                           l_log_level_rec)) then
                l_err_stage := 'FA_AFE_TRANSACTIONS_PKG.process_expense failed';
                if (l_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,
                                   '-',
                                   l_err_stage || 'For ' ||
                                   l_trans_int_rec.transaction_interface_id,
                                   p_log_level_rec => l_log_level_rec);
                end if;

              end if;
            else
              null; --do nothing....
            end if;
          end if;
        end loop; /* end of get_cip_assets loop*/
        close get_cip_assets;
      end loop;
      commit;
    end loop;
    close get_interface_assets;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FA_SRVR_MSG.Add_Message(calling_fn      => 'FA_TRANSFER_PUB.do_transfer',
                              p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      ROLLBACK TO AFE_Reclass_Asset_Begin;
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      FA_SRVR_MSG.add_sql_error(calling_fn      => 'FA_TRANSFER_PUB.do_transfer',
                                p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      ROLLBACK TO AFE_Reclass_Asset_Begin;
      x_return_status := FND_API.G_RET_STS_ERROR;
  end process_transaction_interface;

end FA_TRANSACTION_ITF_PKG;

/
