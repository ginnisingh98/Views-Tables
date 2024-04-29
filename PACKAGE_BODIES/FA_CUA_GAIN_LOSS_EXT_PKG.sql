--------------------------------------------------------
--  DDL for Package Body FA_CUA_GAIN_LOSS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_GAIN_LOSS_EXT_PKG" AS
/* $Header: FACPX11MB.pls 120.1.12010000.2 2009/07/19 12:23:55 glchen ship $ */

-- ------------------------------------------------------------
-- facuas1: needs to be called from calculate_gain_loss process
--          after updating the status of fa_retirements to DELETED
--
--          This procedure re-derives the hierarchy attributes of
--          the reinstated assets
-- -----------------------------------------------------------

   PROCEDURE facuas1( x_book_type_code in varchar2
                    , x_asset_id       in number
                    , x_retire_status  in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    v_err_code            varchar2(640) := '0';
    v_err_stage           varchar2(640);
    v_err_stack           varchar2(640);
    v_dummy_varchar       varchar2(30);
    v_batch_id            number;
    v_batch_number        varchar2(30);
    v_dummy_number        number;
    v_amortize_flag       VARCHAR2(3);
    v_amortization_date   date;
    v_old_life_in_months  number;

    l_app varchar2(50);
    l_name varchar2(30);
    l_trans_rec   FA_API_TYPES.trans_rec_type;

    Cursor C_amort_date is
      select greatest(calendar_period_open_date,least(sysdate, calendar_period_close_date))
      from     fa_deprn_periods
      where    book_type_code = x_book_type_code
      and      period_close_date is null;

    Cursor check_hr_asset is
     select 'Y'
     from ( select a.transaction_header_id_in
            from fa_books a
               , fa_asset_hierarchy b
            where a.book_type_code = x_book_type_code
              and a.asset_id = x_asset_id
              and a.asset_id = b.asset_id
              and a.date_ineffective IS NULL ) a1,
     fa_books c
    where c.transaction_header_id_out = a1.transaction_header_id_in
    and nvl(c.period_counter_fully_retired, 0) <> 0;

   CURSOR check_status is
     select 1 from dual
     where exists ( select 'X'
                    from fa_mass_update_batch_details
                    where batch_id = v_batch_id
                    and status_code IN ('P', 'R' ) );
  BEGIN
    if(x_retire_status = 'DELETED') then
       -- check if fully retired
       open check_hr_asset;
       fetch check_hr_asset into v_dummy_varchar;
       close check_hr_asset;

      if(v_dummy_varchar = 'Y') then
         -- get batch_id
         v_dummy_varchar:= NULL;
         select fa_mass_update_batch_hdrs_s.nextval
         into v_batch_id
         from dual;

         open  C_amort_date;
         fetch C_amort_date into v_amortization_date;
         close C_amort_date;


         v_amortize_flag:= 'YES';

         fa_cua_mass_update2_pkg.g_override_book_check:= 'YES';

         -- Fix for Bug #2709865.  Use different variable names.
         v_batch_number := to_char (v_batch_id);

         -- generate_batch_transactions
         fa_cua_asset_apis.generate_batch_transactions(
                             x_event_code           => 'HR_REINSTATEMENT'
                           , x_book_type_code       => x_book_type_code
                           , x_src_entity_name      => 'REINSTATED_ASSET'
                           , x_src_entity_value     => x_asset_id
                           , x_src_attribute_name   => v_dummy_varchar
                           , x_src_attr_value_from  => v_dummy_varchar
                           , x_src_attr_value_to    => v_dummy_varchar
                           , x_amortize_expense_flg => v_amortize_flag
                           , x_amortization_date    => v_amortization_date
                           , x_batch_num            => v_batch_number
                           , x_batch_id             => v_batch_id
                           , x_err_code             => v_err_code
                           , x_err_stage            => v_err_stage
                           , x_err_stack            => v_err_stack
                           , p_log_level_rec        => p_log_level_rec);

         if  v_err_code <> '0' then
           raise_application_error(-20000,v_err_code);
         end if;

         l_trans_rec.mass_reference_id          := fnd_global.conc_request_id;
         l_trans_rec.who_info.last_update_date  := sysdate;
         l_trans_rec.who_info.last_updated_by   := fnd_global.user_id;
         l_trans_rec.who_info.created_by        := l_trans_rec.who_info.last_updated_by;
         l_trans_rec.who_info.creation_date     := sysdate;
         l_trans_rec.who_info.last_update_login := fnd_global.login_id;
         l_trans_rec.amortization_start_date    := v_amortization_date;
         l_trans_rec.transaction_date_entered   := v_amortization_date;

         fa_cua_mass_update1_pkg.process_asset(
                                 px_trans_rec    => l_trans_rec,
                                 p_batch_id      => v_batch_id,
                                 p_asset_id      => x_asset_id,
                                 p_book          => x_book_type_code,
                                 p_amortize_flag => v_amortize_flag,
                                 x_err_code      => v_err_code,
                                 x_err_attr_name => v_dummy_varchar , p_log_level_rec => p_log_level_rec);

        if v_err_code <> '0' then
               delete from fa_mass_update_batch_headers
               where batch_id = v_batch_id;

               delete from fa_mass_update_batch_details
               where batch_id = v_batch_id;

               raise_application_error(-20000, v_err_code);
         else
              -- success
             delete from fa_mass_update_batch_headers
             where batch_id = v_batch_id;

             delete from fa_mass_update_batch_details
             where batch_id = v_batch_id;
         end if;

        end if;  -- v_dummy
      end if;  --status

EXCEPTION
  when others then
    raise;
END facuas1;

END fa_cua_gain_loss_ext_pkg;

/
