--------------------------------------------------------
--  DDL for Package Body FA_UNIT_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UNIT_ADJ_PUB" AS
/* $Header: FAPUADJB.pls 120.9.12010000.3 2009/07/19 12:06:54 glchen ship $   */

--*********************** Global constants *******************************--
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_UNIT_ADJ_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Unit Adjustment API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private procedures *****************************--


FUNCTION valid_input(px_trans_rec     IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                     p_asset_hdr_rec  IN     FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                RETURN BOOLEAN;

--*********************** Public procedures ******************************--

PROCEDURE do_unit_adjustment(p_api_version         IN     NUMBER,
     		      p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
    		      p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
     		      p_validation_level     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                      p_calling_fn           IN     VARCHAR2,
                      x_return_status        OUT NOCOPY    VARCHAR2,
                      x_msg_count            OUT NOCOPY    NUMBER,
                      x_msg_data             OUT NOCOPY    VARCHAR2,
		      px_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                      px_asset_hdr_rec       IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
		      px_asset_dist_tbl      IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type)

IS

   l_api_version   CONSTANT NUMBER := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'UNIT ADJUSTMENT API';
   l_period_addition varchar2(1);

    -- Bug 8252607/5475276 Cursor to get the book_type_code
    CURSOR c_corp_book( p_asset_id number ) IS
    SELECT bc.book_type_code
      FROM fa_books bks,
           fa_book_controls bc
     WHERE bks.book_type_code = bc.distribution_source_book
       AND bks.book_type_code = bc.book_type_code
       AND bks.asset_id       = p_asset_id
       AND bks.transaction_header_id_out is null;

   l_asset_cat_rec FA_API_TYPES.asset_cat_rec_type;
   l_period_rec    FA_API_TYPES.period_rec_type;

BEGIN

     SAVEPOINT unit_adj_pub;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

     IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME) then
                RAISE   FND_API.G_EXC_ERROR;
     END IF;

     if (p_init_msg_list = FND_API.G_TRUE) then
         fa_srvr_msg.Init_Server_Message;
         fa_debug_pkg.Initialize;
     end if;

     if (px_asset_hdr_rec.asset_id is null) then
            fa_srvr_msg.add_message(
                        calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
                        name       => 'FA_SHARED_ITEM_NULL',
                        token1     => 'ITEM',
                        value1     => 'Asset Id', p_log_level_rec => g_log_level_rec);
	RAISE FND_API.G_EXC_ERROR;
     end if;

     -- Bug 8252607/5475276 Get the book_type_code if it is not supplied.
     if (px_asset_hdr_rec.book_type_code is null) then
         open c_corp_book( px_asset_hdr_rec.asset_id );
	 fetch c_corp_book into px_asset_hdr_rec.book_type_code;
	 close c_corp_book;

	 if px_asset_hdr_rec.book_type_code is null then
	    fa_srvr_msg.add_message
	       (calling_fn => 'FA_UNIT_ADJ_PUB.do_unit_adjustment',
	        name       => 'FA_EXP_GET_ASSET_INFO', p_log_level_rec => g_log_level_rec);
	    raise FND_API.G_EXC_ERROR;
	 end if;
     end if;

     -- call the cache for the primary transaction book
     if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
         RAISE FND_API.G_EXC_ERROR;
     end if;

     -- validate book if corporate, validate asset

     if not fa_asset_val_pvt.validate_asset_book
            (p_transaction_type_code  => 'UNIT ADJUSTMENT',
             p_book_type_code         => px_asset_hdr_rec.book_type_code,
             p_asset_id               => px_asset_hdr_rec.asset_id,
             p_calling_fn             => 'FA_UNIT_ADJ_PUB.valid_input', p_log_level_rec => g_log_level_rec) then
	raise FND_API.G_EXC_ERROR;
     end if;

     px_trans_rec.transaction_type_code := 'UNIT ADJUSTMENT';
     IF NOT FA_TRX_APPROVAL_PKG.faxcat(
                        X_book          =>px_asset_hdr_rec.book_type_code,
                        X_asset_id      =>px_asset_hdr_rec.asset_id,
                        X_trx_type      =>'TRANSFER',
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
                        px_asset_dist_tbl     => px_asset_dist_tbl, p_log_level_rec => g_log_level_rec) then
        raise FND_API.G_EXC_ERROR;
     end if;

     /*
      * Code hook for IAC
      */
     if (FA_IGI_EXT_PKG.IAC_Enabled) then
        if not FA_IGI_EXT_PKG.Do_Unit_Adjustment(
                 p_trans_rec             => px_trans_rec,
                 p_asset_hdr_rec         => px_asset_hdr_rec,
                 p_asset_cat_rec         => l_asset_cat_rec,
                 p_calling_function      => 'FA_UNIT_ADJ_PUB.DO_UNIT_ADJUSTMENT') then raise FND_API.G_EXC_ERROR;
        end if;
     end if; -- (FA_IGI_EXT_PKG.IAC_Enabled)

     if cse_fa_integration_grp.is_oat_enabled then
        if not cse_fa_integration_grp.unit_adjustment(
                             p_trans_rec      =>  px_trans_rec,
                             p_asset_hdr_rec  =>  px_asset_hdr_rec,
                             p_asset_dist_tbl =>  px_asset_dist_tbl) then
           raise FND_API.G_EXC_ERROR;
        end if;
     end if;

     if (p_commit = FND_API.G_TRUE) then
          COMMIT WORK;
     end if;

     FND_MSG_PUB.Count_And_Get(
                       p_count => x_msg_count,
                       p_data => x_msg_data
                       );

        -- Return the status.
     x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        FA_SRVR_MSG.Add_Message(
		calling_fn => 'FA_UNIT_ADJ_PUB.do_unit_adjustment', p_log_level_rec => g_log_level_rec);

        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data => x_msg_data
                );
        ROLLBACK TO unit_adj_pub;
        x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
        FA_SRVR_MSG.Add_Sql_Error(
                calling_fn => 'FA_UNIT_ADJ_PUB.do_unit_adjustment', p_log_level_rec => g_log_level_rec);

        FND_MSG_PUB.Count_And_Get(
                p_count => x_msg_count,
                p_data => x_msg_data
                );
        ROLLBACK TO unit_adj_pub;
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
     -- be override to proceed with normal unit adjustment
     if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        if (not fa_cua_asset_APIS.check_override_allowed(
                      p_attribute_name => 'DISTRIBUTION',
                      p_book_type_code => p_asset_hdr_rec.book_type_code,
                      p_asset_id => p_asset_hdr_rec.asset_id,
                      x_override_flag => l_override_flag,
                      p_log_level_rec => p_log_level_rec)) then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_UNIT_ADJ_PUB.valid_input', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
        -- if override flag is set to No, do not allow the unit adjustment
        if (l_override_flag = 'N') then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
                      name => 'CUA_NO_DIST_CHANGE_ALLOWED', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
     end if;


     -- check if asset is fully retired
     if FA_ASSET_VAL_PVT.validate_fully_retired(p_asset_hdr_rec.asset_id,
                                                p_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(
             calling_fn      => 'FA_UNIT_ADJ_PUB.valid_input',
             Name            => 'FA_REC_RETIRED', p_log_level_rec => p_log_level_rec);
             return FALSE;
     end if;

    /* Added for bug 8584206 */
    IF not FA_ASSET_VAL_PVT.validate_energy_transactions (
 	         p_trans_rec            => px_trans_rec,
 	         p_asset_hdr_rec        => p_asset_hdr_rec ,
 	         p_log_level_rec        => p_log_level_rec) then

 	    return FALSE;
 	 END IF;


     if not FA_UTIL_PVT.get_period_rec
               (p_book       => p_asset_hdr_rec.book_type_code,
                x_period_rec => l_period_rec, p_log_level_rec => p_log_level_rec) then
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
           fa_srvr_msg.add_message( calling_fn => 'FA_UNIT_ADJ_PUB.valid_input', p_log_level_rec => p_log_level_rec);
           return false;
        else
           l_fiscal_year_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
           l_fiscal_year      := fa_cache_pkg.fazcbc_record.current_fiscal_year;
        end if;

        select start_date, end_date
        into l_fy_start_Date, l_fy_end_date
        from fa_fiscal_year
        where fiscal_year = l_fiscal_year
        and fiscal_year_name = l_fiscal_year_name;

        if not FA_UTIL_PVT.get_latest_trans_date('FA_UNIT_ADJ_PUB.valid_input',
                                                  p_asset_hdr_rec.asset_id,
                                                  p_asset_hdr_rec.book_type_code,
                                                  l_max_transaction_date, p_log_level_rec => p_log_level_rec) then
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered < l_fy_start_date or
            px_trans_rec.transaction_date_entered > l_fy_end_date) then
            fa_srvr_msg.add_message(
			calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
			name       => 'FA_RET_DATE_MUSTBE_IN_CUR_FY', p_log_level_rec => p_log_level_rec);
            return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered > l_period_rec.calendar_period_close_date) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
                        name       => 'FA_SHARED_CANNOT_FUTURE', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered < l_max_transaction_date) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
                        name       => 'FA_SHARED_OTHER_TRX_FOLLOW', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;

        if (px_trans_rec.transaction_date_entered <to_date('1000/01/01', 'YYYY/MM/DD')) then
           fa_srvr_msg.add_message(
                        calling_fn => 'FA_UNIT_ADJ_PUB.valid_input',
                        name       => 'FA_YEAR_GREATER_THAN', p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;
     end if;

     return TRUE;

EXCEPTION
    when others then
	fa_srvr_msg.add_sql_error(
                    calling_fn => 'FA_UNIT_ADJ_PUB.valid_input', p_log_level_rec => p_log_level_rec);
        return FALSE;

END;

END FA_UNIT_ADJ_PUB;

/
