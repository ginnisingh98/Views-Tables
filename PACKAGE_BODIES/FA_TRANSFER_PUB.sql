--------------------------------------------------------
--  DDL for Package Body FA_TRANSFER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANSFER_PUB" AS
/* $Header: FAPTFRB.pls 120.9.12010000.5 2010/03/04 13:58:41 deemitta ship $   */

--*********************** Global constants *******************************--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_TRANSFER_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Transfer API';
G_API_VERSION   CONSTANT   number       := 1.0;
g_release                  number  := fa_cache_pkg.fazarel_release; --Bug 8477066

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private procedures *****************************--

FUNCTION valid_input(px_trans_rec     IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                     p_asset_hdr_rec  IN     FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                RETURN BOOLEAN;

--*********************** Public procedures ******************************--

PROCEDURE do_transfer(p_api_version         IN     NUMBER,
                      p_init_msg_list       IN     VARCHAR2 := FND_API.G_FALSE,
                      p_commit              IN     VARCHAR2 := FND_API.G_FALSE,
                      p_validation_level    IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn          IN     VARCHAR2,
                      x_return_status       OUT NOCOPY    VARCHAR2,
                      x_msg_count           OUT NOCOPY    NUMBER,
                      x_msg_data            OUT NOCOPY    VARCHAR2,
                      px_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                      px_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                      px_asset_dist_tbl     IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type)

IS

   -- Bug 8252607/5475276 Cursor to get the book_type_code
   CURSOR c_corp_book( p_asset_id number ) IS
   SELECT bc.book_type_code
     FROM fa_books bks,
          fa_book_controls bc
    WHERE bks.book_type_code = bc.distribution_source_book
      AND bks.book_type_code = bc.book_type_code
      AND bks.asset_id       = p_asset_id
      AND bks.transaction_header_id_out is null;

   l_period_addition varchar2(1);
   l_asset_cat_rec FA_API_TYPES.asset_cat_rec_type;

BEGIN

     SAVEPOINT transfer_pub;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

     IF NOT FND_API.Compatible_API_Call(g_api_version, p_api_version,
                                        g_api_name, G_PKG_NAME) then
                RAISE   FND_API.G_EXC_ERROR;
     END IF;

     if (p_init_msg_list = FND_API.G_TRUE) then
         fa_srvr_msg.Init_Server_Message;
         fa_debug_pkg.Initialize;
     end if;

     if (px_asset_hdr_rec.asset_id is null) then
            fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.do_transfer',
                        name       => 'FA_SHARED_ITEM_NULL',
                        token1     => 'ITEM',
                        value1     => 'Asset Id', p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
     end if;

     -- Bug 8252607/5475276 Get the book_type_code if it is not supplied.
     if (px_asset_hdr_rec.book_type_code is null) then
         open c_corp_book( px_asset_hdr_rec.asset_id );
         fetch c_corp_book into px_asset_hdr_rec.book_type_code;
         close c_corp_book;

         if px_asset_hdr_rec.book_type_code is null then
            fa_srvr_msg.add_message
               (calling_fn => 'FA_TRANSFER_PUB.do_transfer',
                name       => 'FA_EXP_GET_ASSET_INFO', p_log_level_rec => g_log_level_rec);
            raise FND_API.G_EXC_ERROR;
         end if;
     end if;

     -- call the cache for the primary transaction book
     if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
         RAISE FND_API.G_EXC_ERROR;
     end if;

     -- validate book is corporate and enabled and asset exists in book
     if not fa_asset_val_pvt.validate_asset_book
            (p_transaction_type_code  => 'TRANSFER',
             p_book_type_code         => px_asset_hdr_rec.book_type_code,
             p_asset_id               => px_asset_hdr_rec.asset_id,
             p_calling_fn             => 'FA_TRANSFER_PUB.do_transfer', p_log_level_rec => g_log_level_rec) then
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
     /*phase5 This function will validate if current transaction is overlapping to any previously done impairment*/
     if not FA_ASSET_VAL_PVT.check_overlapping_impairment(
               p_trans_rec            => px_trans_rec,
               p_asset_hdr_rec        => px_asset_hdr_rec ,
               p_log_level_rec        => g_log_level_rec) then

	       fa_srvr_msg.add_message
                    (name       => 'FA_OVERLAPPING_IMP_NOT_ALLOWED',
                     calling_fn => 'FA_ASSET_VAL_PVT.check_overlapping_impairment'
                    ,p_log_level_rec => g_log_level_rec);

           raise FND_API.G_EXC_ERROR;
     end if;
     px_trans_rec.transaction_type_code := 'TRANSFER';
     IF NOT FA_TRX_APPROVAL_PKG.faxcat(
                        X_book          =>px_asset_hdr_rec.book_type_code,
                        X_asset_id      =>px_asset_hdr_rec.asset_id,
                        X_trx_type      =>px_trans_rec.transaction_type_code,
                        X_trx_date      =>px_trans_rec.transaction_date_entered,
                        X_init_message_flag=> 'NO', p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     if not fa_asset_val_pvt.validate_period_of_addition
                                (px_asset_hdr_rec.asset_id,
                                 px_asset_hdr_rec.book_type_code,
                                 'ABSOLUTE',
                                 l_period_addition, p_log_level_rec => g_log_level_rec) then
         RAISE   FND_API.G_EXC_ERROR;
     end if;
     px_asset_hdr_rec.period_of_addition := l_period_addition;

     -- validate input
     if not valid_input(px_trans_rec,
                        px_asset_hdr_rec,
                        g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     -- BUG# 3325400
     -- forcing selection of the thid here rather
     -- then relying on table handler
     select fa_transaction_headers_s.nextval
       into px_trans_rec.transaction_header_id
       from dual;

     if not FA_DISTRIBUTION_PVT.do_distribution(
                        px_trans_rec          => px_trans_rec,
                        px_asset_hdr_rec      => px_asset_hdr_rec,
                        px_asset_cat_rec_new  => l_asset_cat_rec,
                        px_asset_dist_tbl     => px_asset_dist_tbl,
                        p_validation_level    => p_validation_level, p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     /*
      * Code hook for IAC
      */
     if (FA_IGI_EXT_PKG.IAC_Enabled) then
        if not FA_IGI_EXT_PKG.Do_Transfer(
                        p_trans_rec         => px_trans_rec,
                        p_asset_hdr_rec     => px_asset_hdr_rec,
                        p_asset_cat_rec     => l_asset_cat_rec,
                        p_calling_function  =>'FA_TRANSFER_PUB.Do_Transfer') then
           raise FND_API.G_EXC_ERROR;
        end if;
     end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

     -- call to workflow business event

     fa_business_events.raise(
                 p_event_name => 'oracle.apps.fa.transfer.asset.transfer',
                 p_event_key => px_asset_hdr_rec.asset_id || to_char(sysdate,'RRDDDSSSSS'),
                 p_parameter_name1 => 'ASSET_ID',
                 p_parameter_value1 => px_asset_hdr_rec.asset_id,
                 p_parameter_name2 => 'BOOK_TYPE_CODE',
                 p_parameter_value2 => px_asset_hdr_rec.book_type_code,
                 p_log_level_rec => g_log_level_rec);

     if cse_fa_integration_grp.is_oat_enabled then
        if not cse_fa_integration_grp.transfer(
                             p_trans_rec      =>  px_trans_rec,
                             p_asset_hdr_rec  =>  px_asset_hdr_rec,
                             p_asset_dist_tbl =>  px_asset_dist_tbl) then
           raise FND_API.G_EXC_ERROR;
        end if;
     end if;



     if (p_commit = FND_API.G_TRUE) then
          COMMIT WORK;
     end if;
/*
        -- Return the status.
     FA_SRVR_MSG.Add_Message(
             calling_fn => 'FA_TRANSFER_PUB.do_transfer',
             name       => 'FA_SHARED_END_SUCCESS',
             token1     => 'PROGRAM',
             value1     => 'FA_TRANSFER_PUB.do_transfer', p_log_level_rec => g_log_level_rec); */

     FND_MSG_PUB.Count_And_Get(
                       p_count => x_msg_count,
                       p_data => x_msg_data
                       );

     x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        FA_SRVR_MSG.Add_Message(
                calling_fn => 'FA_TRANSFER_PUB.do_transfer', p_log_level_rec => g_log_level_rec);

        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data => x_msg_data
                );
        ROLLBACK TO transfer_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
        FA_SRVR_MSG.add_sql_error(
                calling_fn => 'FA_TRANSFER_PUB.do_transfer', p_log_level_rec => g_log_level_rec);

        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data => x_msg_data
                );
        ROLLBACK TO transfer_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;

END;

FUNCTION valid_input(px_trans_rec     IN OUT NOCOPY fa_api_types.trans_rec_type,
                     p_asset_hdr_rec  IN     fa_api_types.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN IS

   l_fiscal_year_name varchar2(30);
   l_fiscal_year     number;
   l_fy_start_date   date;
   l_fy_end_date     date;
   l_count           number;
   l_max_transaction_date   date;
   l_period_rec      FA_API_TYPES.period_rec_type;
   l_override_flag   varchar2(1);
   l_transaction_date date;

BEGIN

     -- check if asset is attached to hierarchy and see if it can
     -- be override to proceed with normal transfer
     if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        if (not fa_cua_asset_APIS.check_override_allowed(
                      p_attribute_name => 'DISTRIBUTION',
                      p_book_type_code => p_asset_hdr_rec.book_type_code,
                      p_asset_id => p_asset_hdr_rec.asset_id,
                      x_override_flag => l_override_flag,
                      p_log_level_rec => p_log_level_rec)) then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_TRANSFER_PUB.valid_input', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
        -- if override flag is set to No, do not allow the transfer
        if (l_override_flag = 'N') then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_TRANSFER_PUB.valid_input',
                      name => 'CUA_NO_DIST_CHANGE_ALLOWED', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
     end if;

     -- check if asset is fully retired
     if FA_ASSET_VAL_PVT.validate_fully_retired(p_asset_hdr_rec.asset_id,
                               p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(
             calling_fn      => 'FA_TRANSFER_PUB.valid_input',
             Name            => 'FA_REC_RETIRED', p_log_level_rec => p_log_level_rec);
             return FALSE;
     end if;

     if not FA_UTIL_PVT.get_period_rec
              (p_book       => p_asset_hdr_rec.book_type_code,
               x_period_rec => l_period_rec, p_log_level_rec => p_log_level_rec) then
        return FALSE;
     end if;

     /*Bug 8601485 - Verify if transfer date of the asset is before DPIS*/
     if not fa_asset_val_pvt.validate_asset_transfer_date
	    (p_asset_hdr_rec   => p_asset_hdr_rec,
	     p_trans_rec         => px_trans_rec,
	     p_calling_fn         => 'FA_TRANSFER_PUB.do_transfer',
	     p_log_level_rec    => NULL) then
        fa_srvr_msg.add_message( calling_fn => 'FA_TRANSFER_PUB.valid_input',
                                             name       => 'FA_MASSTFR_VALID_TFR_DPIS', p_log_level_rec => p_log_level_rec);
	return FALSE;
     end if;

     if (px_trans_rec.transaction_date_entered is null or
         p_asset_hdr_rec.period_of_addition = 'Y') then
         l_transaction_date :=
                          greatest(l_period_rec.calendar_period_open_date,
                          least(sysdate,l_period_rec.calendar_period_close_date));
         px_trans_rec.transaction_date_entered :=
               to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');
     else
        if not fa_cache_pkg.fazcbc (X_book => p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message( calling_fn => 'FA_TRANSFER_PUB.valid_input', p_log_level_rec => p_log_level_rec);
           return FALSE;
        else
           l_fiscal_year_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
           l_fiscal_year      := fa_cache_pkg.fazcbc_record.current_fiscal_year;
        end if;

        select start_date, end_date
        into l_fy_start_Date, l_fy_end_date
        from fa_fiscal_year
        where fiscal_year = l_fiscal_year
        and fiscal_year_name = l_fiscal_year_name;

        if not FA_UTIL_PVT.get_latest_trans_date('FA_TRANSFER_PUB.valid_input',
                                                  p_asset_hdr_rec.asset_id,
                                                  p_asset_hdr_rec.book_type_code,
                                                  l_max_transaction_date, p_log_level_rec => p_log_level_rec) then
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered <l_fy_start_date or
            px_trans_rec.transaction_date_entered > l_fy_end_date) then
            fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_RET_DATE_MUSTBE_IN_CUR_FY', p_log_level_rec => p_log_level_rec);
            return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered > l_period_rec.calendar_period_close_date) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_SHARED_CANNOT_FUTURE', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered < l_max_transaction_date) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered <to_date('1000/01/01', 'YYYY/MM/DD')) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_YEAR_GREATER_THAN', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

     -- check that only one prior period transfer is allowed in the same period

        SELECT count(1)
        INTO   l_count
        FROM   FA_TRANSACTION_HEADERS th,
               FA_DEPRN_PERIODS dp
        WHERE  th.asset_id = nvl(p_asset_hdr_rec.asset_id, -1)
        AND    th.book_type_code = nvl(p_asset_hdr_rec.book_type_code,'XX')
        AND    th.transaction_type_code||'' = 'TRANSFER'
        AND    th.transaction_date_entered < dp.calendar_period_open_date
        AND    th.date_effective > dp.period_open_date
        AND    px_trans_rec.transaction_date_entered <
                                dp.calendar_period_open_date
        AND    dp.book_type_code = nvl(p_asset_hdr_rec.book_type_code, 'XX')
        AND    dp.period_close_date IS NULL;

        IF (l_count > 0) THEN
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_SHARED_ONE_PRIOR_PERIOD_TRX', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        -- prior period tfr is not allowed after assets' normal life complete

        SELECT count(1)
        INTO   l_count
        FROM   FA_BOOKS bk, FA_DEPRN_PERIODS dp
        WHERE  bk.asset_id = p_asset_hdr_rec.asset_id
        AND    bk.book_type_code = p_asset_hdr_rec.book_type_code
        AND    nvl(period_counter_fully_reserved, 99) <>
                          nvl(period_counter_life_complete, 99)
        AND    bk.date_ineffective IS NULL
        AND    dp.book_type_code = bk.book_type_code
        AND    px_trans_rec.transaction_date_entered <
                                   dp.calendar_period_open_date
        AND    dp.period_close_date IS NULL;

        if (l_count > 0) THEN
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_TRANSFER_PUB.valid_input',
                        name       => 'FA_NO_TRX_WHEN_LIFE_COMPLETE', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        /*Bug 8477066. If there is any pending backdated transfer already in any tax book,
                       we should not allow this backdated transfer in Corp Book. */
        if (g_release = 11) then --Brahma
           SELECT   count(1)
             INTO   l_count
             FROM   FA_TRANSACTION_HEADERS th,
                    FA_DEPRN_PERIODS dp,
                    FA_BOOK_CONTROLS bc
             WHERE  th.asset_id = nvl(p_asset_hdr_rec.asset_id, -1)
               AND  th.book_type_code = nvl(p_asset_hdr_rec.book_type_code,'XX')
               AND  th.transaction_type_code||'' = 'TRANSFER'
               AND  th.transaction_date_entered < dp.calendar_period_open_date
               AND  th.date_effective > dp.period_open_date
               AND  px_trans_rec.transaction_date_entered < dp.calendar_period_open_date
               AND  dp.book_type_code = bc.book_type_code
               AND  dp.period_close_date IS NULL
               AND  bc.DISTRIBUTION_SOURCE_BOOK =  nvl(p_asset_hdr_rec.book_type_code,'XX')  ;

           if (l_count > 0) THEN
              fa_srvr_msg.add_message(
                           calling_fn => 'FA_TRANSFER_PUB.valid_input',
                           name => 'FA_TAX_PRIOR_PER_TFR', p_log_level_rec => p_log_level_rec);
              return FALSE;
           end if;
        end if;
     end if;

     return TRUE;

EXCEPTION
    when others then
        fa_srvr_msg.add_sql_error(
                    calling_fn => 'FA_TRANSFER_PUB.valid_input', p_log_level_rec => p_log_level_rec);
        return FALSE;

END;



END FA_TRANSFER_PUB;

/
