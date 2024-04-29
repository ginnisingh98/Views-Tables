--------------------------------------------------------
--  DDL for Package Body FA_RECLASS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RECLASS_PUB" as
/* $Header: FAPRECB.pls 120.5.12010000.2 2009/07/19 12:00:57 glchen ship $   */

--*********************** Global constants *******************************--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_RECLASS_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Reclass API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;


/* ---------------------------------------------------------------
 * Name            : Do_reclass
 * Type            : Procedure
 * Returns         : N/A
 * Purpose         : Perform reclass transaction for an asset
 * Calling Details : This procedure expects the following parameters with
 *                   valid data for it to perform the Reclass transaction
 *                   successfully
 *                   px_trans_rec.amortization_start_date
 *                   px_asset_hdr_rec.asset_id
 *                   px_asset_cat_rec_new.category_id
 * ---------------------------------------------------------------- */

 PROCEDURE do_reclass (
           -- std parameters
           p_api_version              IN      NUMBER,
           p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE,
           p_commit                   IN      VARCHAR2 := FND_API.G_FALSE,
           p_validation_level         IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
           p_calling_fn               IN      VARCHAR2,
           x_return_status               OUT NOCOPY  VARCHAR2,
           x_msg_count                   OUT NOCOPY  NUMBER,
           x_msg_data                    OUT NOCOPY  VARCHAR2,
           -- api parameters
           px_trans_rec               IN OUT NOCOPY  FA_API_TYPES.trans_rec_type,
           px_asset_hdr_rec           IN OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
           px_asset_cat_rec_new       IN OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
           p_recl_opt_rec             IN      FA_API_TYPES.reclass_options_rec_type ) IS

      l_api_version   CONSTANT NUMBER := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'RECLASS API';
      l_corp_book         VARCHAR2(30);
      l_status            BOOLEAN;
      l_sysdate           date;
      l_addition_rec      fa_additions%ROWTYPE;
      l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
      l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
      l_asset_cat_rec_old FA_API_TYPES.asset_cat_rec_type;
      l_period_rec        FA_API_TYPES.period_rec_type;
      l_num_dummy number:= 0;

      l_calling_fn varchar2(40) := 'FA_RECLASS_PUB.do_reclass';

    CURSOR C_corp_book( p_asset_id number ) IS
         SELECT bc.book_type_code
           FROM fa_books bks,
                fa_book_controls bc
          WHERE bks.book_type_code = bc.distribution_source_book
            AND bks.book_type_code = bc.book_type_code
            AND bks.asset_id       = p_asset_id
            AND bks.date_ineffective is null;

    CURSOR c_asset_parent is
     select parent_hierarchy_id
     from   fa_asset_hierarchy
     where  asset_id = px_asset_hdr_rec.asset_id;

    CURSOR C_txn_date is
      select  greatest(calendar_period_open_date,
                                  least(sysdate, calendar_period_close_date))
      from    fa_deprn_periods
      where   book_type_code = px_asset_hdr_rec.book_type_code
      and     period_close_date is null;

    l_err_stage varchar2(640);
    l_override_flag     varchar2(1);
    l_asset_hr_rec      FA_API_TYPES.asset_hierarchy_rec_type;
    l_asset_hr_opt_rec  FA_API_TYPES.asset_hr_options_rec_type;
    l_crl_enabled BOOLEAN := FALSE;
  BEGIN

    -- initialize date;
    l_sysdate := sysdate;

     -- Standard start of API savepoint.
    SAVEPOINT   Reclass_Asset_Begin;

    if (not g_log_level_rec.initialized) then
       if (NOT fa_util_pub.get_log_level_rec (
                 x_log_level_rec =>  g_log_level_rec
       )) then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    l_err_stage:= 'Standard call to check for call compatibility.';
    -- dbms_output.put_line(l_err_stage);
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME) then
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    l_err_stage:= 'Initialize message list if p_init_msg_list is set to TRUE.';
    -- dbms_output.put_line(l_err_stage);
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        -- Initialize error message stack.
        FA_SRVR_MSG.Init_Server_Message;
        -- Initialize debug message stack.
        FA_DEBUG_PKG.Initialize;
    END IF;

    -- bugfix 2158910 Override FA: PRINT_DEBUG profile option.
    -- IF FND_API.To_Boolean(p_debug_flag) THEN
    --      FA_DEBUG_PKG.Set_Debug_Flag;
    --  ELSE
         --    FA_DEBUG_PKG.Set_Debug_Flag('NO', p_log_level_rec => g_log_level_rec);
    --  END IF;

     l_err_stage := 'validate required parameters';
     -- -- dbms_output.put_line(l_err_stage);
     if ( px_asset_hdr_rec.asset_id is null or
          px_asset_cat_rec_new.category_id is null ) then
             fa_srvr_msg.add_message(
                         calling_fn => l_calling_fn,
                         name       => 'FA_SHARED_ITEM_NULL' , p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
     end if;


      l_err_stage:= 'check that asset is valid';
     -- -- dbms_output.put_line(l_err_stage);
      select count(book_type_code)
      into l_num_dummy
      from fa_books b
      where asset_id = px_asset_hdr_rec.asset_id
      and date_ineffective is null;
        if l_num_dummy = 0 then
           fa_srvr_msg.add_message(
                       calling_fn => l_calling_fn,
                       name       => 'FA_INVALID_ASSET' , p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
        end if;

     l_err_stage:= 'determine the corporate book';
     -- dbms_output.put_line(l_err_stage);
     open c_corp_book( px_asset_hdr_rec.asset_id );
     fetch c_corp_book into l_corp_book;
         if l_corp_book is null then
            close c_corp_book;
            FA_SRVR_MSG.Add_Message(
                     calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
         end if;
     close c_corp_book;

     px_asset_hdr_rec.book_type_code := l_corp_book;

     -- load the book controls cache
     if not fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     --Verify if impairment has happened in same period
     if not FA_ASSET_VAL_PVT.validate_impairment_exists
              (p_asset_id                   => px_asset_hdr_rec.asset_id,
              p_book             => px_asset_hdr_rec.book_type_code,
              p_mrc_sob_type_code => 'P',
              p_set_of_books_id => px_asset_hdr_rec.set_of_books_id,
              p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Book',  px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Asset_id',  px_asset_hdr_rec.asset_id, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Transaction_date_entered',  px_trans_rec.transaction_date_entered, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '-', 'calling FA_TRX_APPROVAL_PKG.faxcat', p_log_level_rec => g_log_level_rec);
      end if;

     -- call asset level transaction approval
     -- only if not called from mass process
     if nvl(p_recl_opt_rec.mass_request_id, -1) = -1 then
        l_err_stage:= 'FA_TRX_APPROVAL_PKG.faxcat';
        -- dbms_output.put_line(l_err_stage);
        if NOT FA_TRX_APPROVAL_PKG.faxcat(
                        X_book          =>px_asset_hdr_rec.book_type_code,
                        X_asset_id      =>px_asset_hdr_rec.asset_id,
                        X_trx_type      =>'RECLASS',
                        X_trx_date      =>px_trans_rec.transaction_date_entered,
                        X_init_message_flag=>'NO', p_log_level_rec => g_log_level_rec) then
           FA_SRVR_MSG.Add_Message(
                       Calling_FN => l_calling_fn, p_log_level_rec => g_log_level_rec);
           raise FND_API.G_EXC_ERROR;
        end if;
     end if;

     -- BUG# 3549470
     -- force the population of trx_date_entered here

     if not FA_UTIL_PVT.get_period_rec
                (p_book       => px_asset_hdr_rec.book_type_code,
                 x_period_rec => l_period_rec, p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     px_trans_rec.transaction_date_entered :=
        greatest(l_period_rec.calendar_period_open_date,
                 least(sysdate,l_period_rec.calendar_period_close_date));

     px_trans_rec.transaction_date_entered :=
        to_date(to_char(px_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');

     -- for redefault the user must specify whether to
     -- expense/amortize the adjustments. If not then
     -- consider it as expense.
     if ( p_recl_opt_rec.redefault_flag = 'YES' and
          ( nvl(px_trans_rec.transaction_subtype, 'XX') not in
                        ('EXPENSED', 'AMORTIZED'))   ) then
              px_trans_rec.transaction_subtype := 'EXPENSED';
     end if;

      -- dbms_output.put_line('transaction_subtype '|| px_trans_rec.transaction_subtype );

     l_err_stage:= 'fa_utils_pvt.get_asset_desc_rec';
      -- dbms_output.put_line(l_err_stage);
        if not fa_util_pvt.get_asset_desc_rec(
                           p_asset_hdr_rec   => px_asset_hdr_rec ,
                           px_asset_desc_rec => l_asset_desc_rec , p_log_level_rec => g_log_level_rec) then
             fa_srvr_msg.add_message(
                         calling_fn => l_calling_fn,
                         name       => 'FA_PROJ_GET_ASSET_INFO' , p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
       end if;

     l_err_stage:= 'fa_utils_pvt.get_asset_type_rec';
      -- dbms_output.put_line(l_err_stage);
     if not fa_util_pvt.get_asset_type_rec(
                       p_asset_hdr_rec  => px_asset_hdr_rec,
                       px_asset_type_rec => l_asset_type_rec,
                       p_date_effective  => null , p_log_level_rec => g_log_level_rec) then
              fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
          raise FND_API.G_EXC_ERROR;
     end if;

      -- get current category details
     l_err_stage:= 'fa_utils_pvt.get_asset_cat_rec';
      -- dbms_output.put_line(l_err_stage);
       if not fa_util_pvt.get_asset_cat_rec(
                          p_asset_hdr_rec  => px_asset_hdr_rec,
                          px_asset_cat_rec => l_asset_cat_rec_old,
                          p_date_effective => null , p_log_level_rec => g_log_level_rec) then
          fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
          raise FND_API.G_EXC_ERROR;
       end if;

      l_err_stage:= 'check if old and new categories are same';
      -- dbms_output.put_line(l_err_stage);
      if ( l_asset_cat_rec_old.category_id = px_asset_cat_rec_new.category_id ) then
         -- do nothing. Skip
         return ;
      end if;

     l_err_stage:= 'Check if CRL enabled';
     -- dbms_output.put_line(l_err_stage);
     if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        l_crl_enabled := TRUE;
     end if;

     if l_crl_enabled then
       -- dbms_output.put_line('CRL Is Enabled');

       l_err_stage:= 'Check_override_allowed';
       -- dbms_output.put_line(l_err_stage);
       if (not fa_cua_asset_APIS.check_override_allowed(
                      p_attribute_name => 'CATEGORY',
                      p_book_type_code => px_asset_hdr_rec.book_type_code,
                      p_asset_id => px_asset_hdr_rec.asset_id,
                      x_override_flag => l_override_flag,
                      p_log_level_rec => g_log_level_rec)) then
            fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
       end if;
       if l_override_flag = 'N' then
           fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name => 'FA_OVERRIDE_NOT_ALLOWED',
                      token1 => 'CATEGORY', p_log_level_rec => g_log_level_rec);
           raise FND_API.G_EXC_ERROR;
       end if;

       l_err_stage:= 'c_asset_parent';
       -- dbms_output.put_line(l_err_stage);
       open C_asset_parent;
       fetch C_asset_parent into l_asset_hr_rec.parent_hierarchy_id;
       close C_asset_parent;

       if l_asset_hr_rec.parent_hierarchy_id is not null then
           -- create/submit batch to derive asset hierarchy attributes

           l_asset_hr_opt_rec.event_code  := 'CHANGE_ASSET_CATEGORY';
           l_asset_hr_opt_rec.status_code := 'N';
           l_asset_hr_opt_rec.source_entity_name := 'ASSET';
           l_asset_hr_opt_rec.source_entity_value:= px_asset_hdr_rec.asset_id;
           l_asset_hr_opt_rec.source_attribute_name:= 'CATEGORY';
           l_asset_hr_opt_rec.source_attribute_old_id:= l_asset_cat_rec_old.category_id;
           l_asset_hr_opt_rec.source_attribute_new_id:= px_asset_cat_rec_new.category_id;
           l_asset_hr_opt_rec.description:= null;

           if px_trans_rec.transaction_subtype = 'AMORTIZED' then
              l_asset_hr_opt_rec.amortize_flag:= 'Y';
              if px_trans_rec.amortization_start_date is null then
                 l_err_stage:= 'C_txn_date';
                 -- dbms_output.put_line(l_err_stage);
                 Open C_txn_date;
                 Fetch C_txn_date into l_asset_hr_opt_rec.amortization_start_date;
                 Close C_txn_date;
              else
                l_asset_hr_opt_rec.amortization_start_date := px_trans_rec.amortization_start_date;
              end if;
           else
              l_asset_hr_opt_rec.amortize_flag:= 'N';
              l_asset_hr_opt_rec.amortization_start_date := null;
           end if;

           l_err_stage:= 'calling FA_ASSET_HIERARCHY_PVT.create_batch';
           -- dbms_output.put_line(l_err_stage );
           if not FA_ASSET_HIERARCHY_PVT.create_batch(
                  p_asset_hdr_rec     => px_asset_hdr_rec,
                  p_trans_rec         => px_trans_rec,
                  p_asset_hr_opt_rec  => l_asset_hr_opt_rec , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_ERROR;
           end if;
       end if;  -- parent_hierarchy not null
    end if; -- if l_crl_enabled

    if ( (not l_crl_enabled) OR
         l_asset_hr_rec.parent_hierarchy_id is null ) then
         -- dbms_output.put_line('CRL Not Enabled');
          px_trans_rec.transaction_type_code := 'RECLASS';

       if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Transaction_type_code',  px_trans_rec.transaction_type_code , p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '-', 'calling FA_RECLASS_PVT.do_reclass',  p_log_level_rec => g_log_level_rec);
       end if;


          l_err_stage:= 'calling FA_RECLASS_PVT.do_reclass';
          -- dbms_output.put_line(l_err_stage);
          if not FA_RECLASS_PVT.do_reclass(
                                px_trans_rec,
                                l_asset_desc_rec,
                                px_asset_hdr_rec,
                                l_asset_type_rec,
                                l_asset_cat_rec_old,
                                px_asset_cat_rec_new,
                                p_recl_opt_rec , p_log_level_rec => g_log_level_rec) then

                       raise FND_API.G_EXC_ERROR;
          end if;
     end if;     -- if not crl_enabled

     if FND_API.To_Boolean(p_commit) THEN
       commit;
     end if;

     FND_MSG_PUB.Count_And_Get(
                 p_count => x_msg_count,
                 p_data =>  x_msg_data );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
     when FND_API.G_EXC_ERROR then
          rollback to Reclass_Asset_Begin;
          FA_SRVR_MSG.Add_Message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.Count_And_Get(
                      p_count => x_msg_count,
                      p_data =>  x_msg_data );
          x_return_status := FND_API.G_RET_STS_ERROR;

      when others then
          rollback to Reclass_Asset_Begin;
          fa_srvr_msg.add_sql_error(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.Count_And_Get(
                      p_count => x_msg_count,
                      p_data =>  x_msg_data );
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END do_reclass;


END FA_RECLASS_PUB;

/
