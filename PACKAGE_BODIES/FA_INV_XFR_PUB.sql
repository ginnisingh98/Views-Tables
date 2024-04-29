--------------------------------------------------------
--  DDL for Package Body FA_INV_XFR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INV_XFR_PUB" as
/* $Header: FAPIXFRB.pls 120.25.12010000.4 2010/02/01 14:37:20 bmaddine ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_UNPLANNED_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Unplanned API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;
g_release       number  := fa_cache_pkg.fazarel_release;

--*********************** Private procedures ******************************--

FUNCTION do_all_books
           (p_src_trans_rec          IN FA_API_TYPES.trans_rec_type,
            p_src_asset_hdr_rec      IN FA_API_TYPES.asset_hdr_rec_type,
            p_dest_trans_rec         IN FA_API_TYPES.trans_rec_type,
            p_dest_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
            p_period_counter         IN NUMBER,
            p_ccid                   IN NUMBER,
            p_src_asset_type         IN VARCHAR2,
            p_dest_asset_type        IN VARCHAR2,
            p_src_current_units      IN NUMBER,
            p_dest_current_units     IN NUMBER,
            p_calling_fn             IN varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

--*********************** Public procedures ******************************--

PROCEDURE do_transfer
   (p_api_version             IN     NUMBER,
    p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn              IN     VARCHAR2 := NULL,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    px_src_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_src_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_dest_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_asset_hdr_rec     IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_inv_tbl                 IN     FA_API_TYPES.inv_tbl_type) IS

   -- used for sob cache
   l_mrc_sob_type_code              varchar2(1);

   -- shared
   l_inv_trans_rec                  FA_API_TYPES.inv_trans_rec_type;
   l_return_status                  VARCHAR2(1);
   l_return_status_bool             boolean;
   l_group_reclass_options_rec      FA_API_TYPES.group_reclass_options_rec_type;

   -- source
   l_src_asset_fin_rec_adj          FA_API_TYPES.asset_fin_rec_type;
   l_src_asset_fin_rec_new          FA_API_TYPES.asset_fin_rec_type;
   l_src_asset_fin_mrc_tbl_new      FA_API_TYPES.asset_fin_tbl_type;
   l_src_inv_tbl                    FA_API_TYPES.inv_tbl_type;
   l_src_asset_deprn_rec_adj        FA_API_TYPES.asset_deprn_rec_type;
   l_src_asset_deprn_rec_new        FA_API_TYPES.asset_deprn_rec_type;
   l_src_asset_deprn_mrc_tbl_new    FA_API_TYPES.asset_deprn_tbl_type;

   -- destination
   l_dest_asset_fin_rec_adj         FA_API_TYPES.asset_fin_rec_type;
   l_dest_asset_fin_rec_new         FA_API_TYPES.asset_fin_rec_type;
   l_dest_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;
   l_dest_inv_tbl                   FA_API_TYPES.inv_tbl_type;
   l_dest_asset_deprn_rec_adj       FA_API_TYPES.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new       FA_API_TYPES.asset_deprn_rec_type;
   l_dest_asset_deprn_mrc_tbl_new   FA_API_TYPES.asset_deprn_tbl_type;

   l_src_asset_type_rec             FA_API_TYPES.asset_type_rec_type;
   l_dest_asset_type_rec            FA_API_TYPES.asset_type_rec_type;

   l_from_asset_type     varchar2(15);
   l_to_asset_type       varchar2(15);
   l_from_current_units  number;
   l_to_current_units    number;

   l_period_rec          FA_API_TYPES.period_rec_type;
   l_transaction_date    date;

   l_clearing_ccid    number;
   l_interco_impact   boolean;

   l_rowid               varchar2(40);

   l_current_period_counter         NUMBER;
   l_calling_fn                     VARCHAR2(35) := 'fa_inv_xfr_pub.do_transfer';
   inv_xfr_err                      EXCEPTION;

   -- Bug 8862296 Changes start here
   l_source_group_asset_id       NUMBER;
   l_dest_group_asset_id         NUMBER;

   CURSOR C_GET_SOURCE_GROUP IS
   SELECT BK.GROUP_ASSET_ID
     FROM FA_BOOKS BK,FA_DEPRN_PERIODS DP
    WHERE BK.ASSET_ID = PX_SRC_ASSET_HDR_REC.ASSET_ID
      AND BK.BOOK_TYPE_CODE = PX_SRC_ASSET_HDR_REC.BOOK_TYPE_CODE
      AND BK.DATE_INEFFECTIVE IS NULL
      AND BK.GROUP_ASSET_ID IS NOT NULL
      AND DP.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
      AND DP.PERIOD_CLOSE_DATE IS NULL
      AND DP.CALENDAR_PERIOD_OPEN_DATE > PX_SRC_TRANS_REC.AMORTIZATION_START_DATE;

   CURSOR C_GET_DEST_GROUP IS
   SELECT BK.GROUP_ASSET_ID
     FROM FA_BOOKS BK,FA_DEPRN_PERIODS DP
    WHERE BK.ASSET_ID = PX_DEST_ASSET_HDR_REC.ASSET_ID
      AND BK.BOOK_TYPE_CODE = PX_DEST_ASSET_HDR_REC.BOOK_TYPE_CODE
      AND BK.DATE_INEFFECTIVE IS NULL
      AND BK.GROUP_ASSET_ID IS NOT NULL
      AND DP.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
      AND DP.PERIOD_CLOSE_DATE IS NULL
      AND DP.CALENDAR_PERIOD_OPEN_DATE > PX_DEST_TRANS_REC.AMORTIZATION_START_DATE;
   -- Bug 8862296 Changes end here

BEGIN

   SAVEPOINT do_transfer;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise inv_xfr_err;
      end if;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if (fnd_api.to_boolean(p_init_msg_list)) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- Check version of the API
   -- Standard call to check for API call compatibility.
   if NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
         ) then
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise inv_xfr_err;
   end if;

   -- get /validate the corporate books for each asset error on mismatch
   -- do not allow transfer between books

   -- set up sob/mrc info
   -- call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc(X_book => px_src_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec)) then
      raise inv_xfr_err;
   end if;

   px_src_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
   px_src_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- reset the global here in case cache was not initialized at
   -- time this package was instantiated
   g_release := fa_cache_pkg.fazarel_release;

   --  Account for transaction submitted from a responsibility
   --  that is not tied to a SOB_ID by getting the value from
   --  the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
           (X_set_of_books_id   => px_src_asset_hdr_rec.set_of_books_id,
            X_mrc_sob_type_code => l_mrc_sob_type_code, p_log_level_rec => g_log_level_rec) then
      raise inv_xfr_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_mrc_sob_type_code = 'R' THEN
      fa_srvr_msg.add_message
          (NAME       => 'MRC_OSP_INVALID_BOOK_TYPE',
           CALLING_FN => l_calling_fn, p_log_level_rec => g_log_level_rec);
      raise inv_xfr_err;
   END IF;

   -- end initial MRC validation


   -- additional validation migrated from the external transfers program
   -- do not allow transfers between books
   if (px_src_asset_hdr_rec.book_type_code <>
       px_dest_asset_hdr_rec.book_type_code) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name        => 'FA_TFRINV_NOT_BTWN_BOOKS',
         token1      => 'BOOK',
         value1      => px_dest_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
      raise inv_xfr_err;
   end if;

   -- From and To Asset Ids Identical
   if (px_src_asset_hdr_rec.asset_id = px_dest_asset_hdr_rec.asset_id) then
      fa_srvr_msg.add_message(
         calling_fn  => l_calling_fn,
         name        => 'FA_TFRINV_NOT_SAME_ASSET', p_log_level_rec => g_log_level_rec);
      raise inv_xfr_err;
   end if;

   l_inv_trans_rec.transaction_type := 'INVOICE TRANSFER';


   FA_INVOICE_TRANSACTIONS_PKG.Insert_Row
     (X_Rowid                     => l_rowid,
      X_Invoice_Transaction_Id    => l_inv_trans_rec.invoice_transaction_id ,
      X_Book_Type_Code            => px_src_asset_hdr_rec.book_type_code,
      X_Transaction_Type          => l_inv_trans_rec.transaction_type,
      X_Date_Effective            => sysdate,
      X_Calling_Fn                => l_calling_fn
     ,p_log_level_rec => g_log_level_rec);

   -- if we wish to validate any info such as same subtype
   -- on both assets we should do it here.   Currently,
   -- all trx/amort info will default from the adjustment api
   -- for each asset and we will allow transfer between
   -- different asset types as well as expensing one side
   -- while amortizing the other


   -- set up the invoice tables for the source and destination assets
   -- initially src i sset the parameter, then we load the inv_indicator
   -- for each row.  Then we set the destination table to the same values
   -- and subsequently null out source line id and flip the sign of fa cost
   -- and repopulate the indicator which gets nulls our for some reason

   l_src_inv_tbl              := p_inv_tbl;

   for l_inv_index in 1..l_src_inv_tbl.count loop

      if not FA_UTIL_PVT.get_inv_rec
         (px_inv_rec          => l_src_inv_tbl(l_inv_index),
          p_mrc_sob_type_code => 'P',
          p_set_of_books_id   => null,
          p_log_level_rec => g_log_level_rec) then raise inv_xfr_err;
      end if;

      -- BUG#
      -- handle payables cost here...
      if (p_inv_tbl(l_inv_index).payables_cost is null) then
         if (l_src_inv_tbl(l_inv_index).fixed_assets_cost <> 0) then
            l_src_inv_tbl(l_inv_index).payables_cost := l_src_inv_tbl(l_inv_index).payables_cost *
                                                         (p_inv_tbl(l_inv_index).fixed_assets_cost/
                                                          l_src_inv_tbl(l_inv_index).fixed_assets_cost);
         else
            l_src_inv_tbl(l_inv_index).payables_cost := 0;
         end if;
      else
         l_dest_inv_tbl(l_inv_index).payables_cost := p_inv_tbl(l_inv_index).payables_cost;
      end if;

      if (p_inv_tbl(l_inv_index).fixed_assets_cost is null) then
         fa_srvr_msg.add_message(
            calling_fn  => l_calling_fn,
            name        => 'FA_TFRINV_NONE_TFR_COST', p_log_level_rec => g_log_level_rec);
      end if;

      l_src_inv_tbl(l_inv_index).fixed_assets_cost := p_inv_tbl(l_inv_index).fixed_assets_cost;

      -- added for SLA
      l_src_inv_tbl(l_inv_index).source_dest_code     := 'SOURCE';

   end loop;

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,
                        'l_src_inv_tbl.count',
                         l_src_inv_tbl.count, p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,
                        'inv_tbl(1).payables_cost',
                         p_inv_tbl(1).payables_cost);
   end if;


   l_dest_inv_tbl             := l_src_inv_tbl;

   for l_inv_index in 1..l_dest_inv_tbl.count loop

      -- BUG#
      -- handle the payables cost here too...
      -- in previous releases, full transfers resulted in all payables cost
      -- moving to the destination asset where as partial transfers resulted
      -- in all payables cost remaining in the source.  To get around the
      -- discrepancies created by the large differences in the amounts going
      -- to the different (flexbuil) accounts for this, a subsequent update
      -- was done to insure accounts matched.  However, now that we're allowing
      -- this to occur between assets which are depreciated and those which aren't
      -- this isn't sufficient.
      --
      -- new behavior will transfer an equal proportion of the payables cost
      -- any descrepancies between the two will be spread based on the
      -- fixed assets cost with the differences having same ratios
      --

      if (p_inv_tbl(l_inv_index).payables_cost is null) then
         if (l_dest_inv_tbl(l_inv_index).fixed_assets_cost <> 0) then
            l_dest_inv_tbl(l_inv_index).payables_cost := -l_src_inv_tbl(l_inv_index).payables_cost *
                                                         (l_src_inv_tbl(l_inv_index).fixed_assets_cost/
                                                          l_dest_inv_tbl(l_inv_index).fixed_assets_cost);
         else
            l_dest_inv_tbl(l_inv_index).payables_cost := 0;
         end if;
      else
         l_dest_inv_tbl(l_inv_index).payables_cost := -p_inv_tbl(l_inv_index).payables_cost ;
      end if;


      l_dest_inv_tbl(l_inv_index).fixed_assets_cost := -l_src_inv_tbl(l_inv_index).fixed_assets_cost;
      l_dest_inv_tbl(l_inv_index).prior_source_line_id :=  l_dest_inv_tbl(l_inv_index).source_line_id;
      l_dest_inv_tbl(l_inv_index).source_line_id    := null;


      if (g_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'l_src_inv_tbl(' || to_char(l_inv_index) || ').source_line_id',
                            l_src_inv_tbl(l_inv_index).source_line_id);
          fa_debug_pkg.add(l_calling_fn,
                           'l_src_inv_tbl(' || to_char(l_inv_index) || ').inv_indicator',
                            l_src_inv_tbl(l_inv_index).inv_indicator);
          fa_debug_pkg.add(l_calling_fn,
                           'l_src_inv_tbl(' || to_char(l_inv_index) || ').fixed_assets_cost',
                            l_src_inv_tbl(l_inv_index).fixed_assets_cost);

          fa_debug_pkg.add(l_calling_fn,
                           'l_dest_inv_tbl(' || to_char(l_inv_index) || ').source_line_id',
                           l_dest_inv_tbl(l_inv_index).source_line_id);
          fa_debug_pkg.add(l_calling_fn,
                           'l_dest_inv_tbl(' || to_char(l_inv_index) || ').inv_indicator',
                            l_dest_inv_tbl(l_inv_index).inv_indicator);
          fa_debug_pkg.add(l_calling_fn,
                           'l_dest_inv_tbl(' || to_char(l_inv_index) || ').fixed_assets_cost',
                            l_dest_inv_tbl(l_inv_index).fixed_assets_cost);
      end if;


   end loop;


   -- SLA: for inter asset transfers of the same asset type,
   --      we need to create the event here - since the THIDs are the unique
   --      identifiers, we need to derive them first
   --
   -- CORRECTION: we will now roll non-like type transfer into cap event

   select asset_type,
          current_units
     into l_from_asset_type,
          l_from_current_units
     from fa_additions_b
    where asset_id = px_src_asset_hdr_rec.asset_id;

   select asset_type,
          current_units
     into l_to_asset_type,
          l_to_current_units
     from fa_additions_b
    where asset_id = px_dest_asset_hdr_rec.asset_id;


   l_src_asset_type_rec.asset_type := l_from_asset_type;
   l_dest_asset_type_rec.asset_type := l_to_asset_type;

   select fa_transaction_headers_s.nextval
     into px_src_trans_rec.transaction_header_id
     from dual;

   select fa_transaction_headers_s.nextval
     into px_dest_trans_rec.transaction_header_id
     from dual;

   -- Also need to load the date here to make it available to the event api
   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => px_src_asset_hdr_rec.book_type_code,
           p_effective_date => NULL,
           x_period_rec     => l_period_rec,
           p_log_level_rec => g_log_level_rec) then
      raise inv_xfr_err;
   end if;


   l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                  least(sysdate,l_period_rec.calendar_period_close_date));

   if (px_src_trans_rec.transaction_subtype = 'AMORTIZED') then
      px_src_trans_rec.transaction_date_entered :=
         nvl(px_src_trans_rec.amortization_start_date, l_transaction_date);
   else
      px_src_trans_rec.transaction_date_entered := l_transaction_date;
   end if;

   if (px_dest_trans_rec.transaction_subtype = 'AMORTIZED') then
      px_dest_trans_rec.transaction_date_entered :=
         nvl(px_dest_trans_rec.amortization_start_date, l_transaction_date);
   else
      px_dest_trans_rec.transaction_date_entered := l_transaction_date;
   end if;

   px_src_trans_rec.transaction_date_entered :=
      to_date(to_char(px_src_trans_rec.transaction_date_entered, 'DD/MM/YYYY'),'DD/MM/YYYY');

   px_dest_trans_rec.transaction_date_entered :=
      to_date(to_char(px_dest_trans_rec.transaction_date_entered, 'DD/MM/YYYY'),'DD/MM/YYYY');

   -- fetch value for the trx_reference_id from sequence
   -- insure we load the trx_ref_idinto dest th row too!!!

   select fa_trx_references_s.nextval
     into px_src_trans_rec.trx_reference_id
     from dual;

   px_dest_trans_rec.trx_reference_id :=
      px_src_trans_rec.trx_reference_id;

   px_src_trans_rec.transaction_key  := 'IT';
   px_dest_trans_rec.transaction_key := 'IT';


   if not FA_XLA_EVENTS_PVT.create_dual_transaction_event
              (p_asset_hdr_rec_src      => px_src_asset_hdr_rec,
               p_asset_hdr_rec_dest     => px_dest_asset_hdr_rec,
               p_asset_type_rec_src     => l_src_asset_type_rec,
               p_asset_type_rec_dest    => l_dest_asset_type_rec,
               px_trans_rec_src         => px_src_trans_rec,
               px_trans_rec_dest        => px_dest_trans_rec,
               p_event_status           => NULL,
               p_calling_fn             => l_calling_fn,
               p_log_level_rec => g_log_level_rec) then
      raise inv_xfr_err;
   end if;

   -- insert the transaction link record
   --   (sequence will be used in table handler)
   -- note that not all values are 100% here as the adjustment
   -- API could reset the subtype, etc

   fa_trx_references_pkg.insert_row
      (X_Rowid                          => l_rowid,
       X_Trx_Reference_Id               => px_src_trans_rec.trx_reference_id,
       X_Book_Type_Code                 => px_src_asset_hdr_rec.book_type_code,
       X_Src_Asset_Id                   => px_src_asset_hdr_rec.asset_id,
       X_Src_Transaction_Header_Id      => px_src_trans_rec.transaction_header_id,
       X_Dest_Asset_Id                  => px_dest_asset_hdr_rec.asset_id,
       X_Dest_Transaction_Header_Id     => px_dest_trans_rec.transaction_header_id,
       X_Member_Asset_Id                => null,
       X_Member_Transaction_Header_Id   => null,
       X_Transaction_Type               => 'INVOICE TRANSFER',
       X_Src_Transaction_Subtype        => px_src_trans_rec.transaction_subtype,
       X_Dest_Transaction_Subtype       => px_dest_trans_rec.transaction_subtype,
       X_Src_Amortization_Start_Date    => px_src_trans_rec.amortization_start_date,
       X_Dest_Amortization_Start_Date   => px_dest_trans_rec.amortization_start_date,
       X_Reserve_Transfer_Amount        => null,
       X_Src_Expense_Amount             => null,
       X_Dest_Expense_Amount            => null,
       X_Src_Eofy_Reserve               => null,
       X_Dest_Eofy_Reserve              => null,
       X_event_id                    => px_src_trans_rec.event_id,
       X_Invoice_Transaction_Id      => l_inv_trans_rec.invoice_transaction_id,
       X_Creation_Date                  => px_src_trans_rec.who_info.creation_date,
       X_Created_By                     => px_src_trans_rec.who_info.created_by,
       X_Last_Update_Date               => px_src_trans_rec.who_info.last_update_date,
       X_Last_Updated_By                => px_src_trans_rec.who_info.last_updated_by,
       X_Last_Update_Login              => px_src_trans_rec.who_info.last_update_login,
       X_Return_Status                  => l_return_status_bool,
       X_Calling_Fn                     => l_calling_fn,
       p_log_level_rec => g_log_level_rec);

   -- Bug 8862296 Changes start here.
   OPEN C_GET_SOURCE_GROUP;
   FETCH C_GET_SOURCE_GROUP into l_source_group_asset_id;
   CLOSE C_GET_SOURCE_GROUP;

   OPEN C_GET_DEST_GROUP;
   FETCH C_GET_DEST_GROUP into l_dest_group_asset_id;
   CLOSE C_GET_DEST_GROUP;
   -- Bug 8862296 Changes end here

   -- call the adjustment api's first for src
   -- then for destination if successful
   -- if either fails we rollback everything

   FA_ADJUSTMENT_PUB.do_adjustment
            (p_api_version             => 1.0,
             p_init_msg_list           => FND_API.G_FALSE,
             p_commit                  => FND_API.G_FALSE,
             p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
             x_return_status           => l_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data,
             p_calling_fn              => l_calling_fn,
             px_trans_rec              => px_src_trans_rec,
             px_asset_hdr_rec          => px_src_asset_hdr_rec,
             p_asset_fin_rec_adj       => l_src_asset_fin_rec_adj,
             x_asset_fin_rec_new       => l_src_asset_fin_rec_new,
             x_asset_fin_mrc_tbl_new   => l_src_asset_fin_mrc_tbl_new,
             px_inv_trans_rec          => l_inv_trans_rec,
             px_inv_tbl                => l_src_inv_tbl,
             p_asset_deprn_rec_adj     => l_src_asset_deprn_rec_adj,
             x_asset_deprn_rec_new     => l_src_asset_deprn_rec_new,
             x_asset_deprn_mrc_tbl_new => l_src_asset_deprn_mrc_tbl_new,
             p_group_reclass_options_rec => l_group_reclass_options_rec
            );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise inv_xfr_err;
   end if;

   /* Bug 8862296: The following IF condition is to make sure that do_inv_sub_transfer
      will be called from Process Group Adjustment if Source Group and Destination Group
      are same, and calling interface is FAXASSET. Thus we are differing destination asset
      adjustment till Process Group Adjustment for source is completed. If this is current
      period amortization then cursors to fetch group assets will return null value and
      following condition fails and we will process destination here itself.*/
   if (l_source_group_asset_id = l_dest_group_asset_id and px_dest_trans_rec.calling_interface = 'FAXASSET') then
      null;
   else
      -- copy in the invoice thid and copy the exchange rate info
      -- was already populated from the invoice engine for src

      -- R12: table is now nested so copy it in the rec
      --  also note the outcoming values for cost in this array
      --  will be for the delta amounts (new amounts for new line)

      for i in 1..l_dest_inv_tbl.count loop
          l_dest_inv_tbl(i).inv_rate_tbl :=  l_src_inv_tbl(i).inv_rate_tbl;
      end loop;

      if not do_inv_sub_transfer(p_src_trans_rec      => px_src_trans_rec,
                                 p_src_asset_hdr_rec  => px_src_asset_hdr_rec,
                                 p_dest_trans_rec     => px_dest_trans_rec,
                                 p_dest_asset_hdr_rec => px_dest_asset_hdr_rec,
                                 p_inv_tbl            => l_dest_inv_tbl,
                                 p_inv_trans_rec      => l_inv_trans_rec,
                                 p_log_level_rec      => g_log_level_rec) then
         raise inv_xfr_err;
      end if;
   end if;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   -- no need to call dump_debug_messages since they are already
   -- loaded from adjustment api
   when No_Data_Found then

      ROLLBACK to do_transfer;

      fa_srvr_msg.add_message(
		CALLING_FN  => l_calling_fn,
            NAME       => 'FA_TFRINV_NO_COST_CLR', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   when inv_xfr_err then
      ROLLBACK to do_transfer;

      fa_srvr_msg.add_message(
               calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   when others then
      ROLLBACK to do_transfer;

      fa_srvr_msg.add_sql_error(
               calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

END do_transfer;

---------------------------------------------------------------------------

FUNCTION do_all_books
           (p_src_trans_rec          IN FA_API_TYPES.trans_rec_type,
            p_src_asset_hdr_rec      IN FA_API_TYPES.asset_hdr_rec_type,
            p_dest_trans_rec         IN FA_API_TYPES.trans_rec_type,
            p_dest_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
            p_period_counter         IN NUMBER,
            p_ccid                   IN NUMBER,
            p_src_asset_type         IN VARCHAR2,
            p_dest_asset_type        IN VARCHAR2,
            p_src_current_units      IN NUMBER,
            p_dest_current_units     IN NUMBER,
            p_calling_fn             IN varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

   l_src_interco_amount  number;
   l_src_cost_amount     number;

   l_interco_amount      number;
   l_cost_amount         number;
   l_delta_amount        number;

   l_reporting_flag      varchar2(1);
   l_sob_index           number;
   l_sob_tbl             FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   l_adj                 fa_adjust_type_pkg.fa_adj_row_struct;
   l_set_of_books_id     number;

   cursor c_total_amount
         (p_asset_id       number,
          p_book_type_code varchar2,
          p_period_counter number,
          p_thid           number,
          p_adj_type       varchar2) is
      select sum(decode(adjustment_type,
                        'INTERCO AR', decode(debit_credit_flag,
                                             'DR', adjustment_amount,
                                                   -adjustment_amount),
                        'INTERCO AP', decode(debit_credit_flag,
                                             'CR', adjustment_amount,
                                                   -adjustment_amount),
                        decode(debit_credit_flag,
                               'CR', adjustment_amount,
                                     -adjustment_amount)))
        from fa_adjustments
       where asset_id               = p_asset_id
         and book_type_code         = p_book_type_code
         and period_counter_created = p_period_counter
         and transaction_header_id  = p_thid
         and adjustment_type        like p_adj_type;

  cursor c_total_amount_mrc
         (p_asset_id       number,
          p_book_type_code varchar2,
          p_period_counter number,
          p_thid           number,
          p_adj_type       varchar2) is
      select sum(decode(adjustment_type,
                        'INTERCO AR', decode(debit_credit_flag,
                                             'DR', adjustment_amount,
                                                   -adjustment_amount),
                        'INTERCO AP', decode(debit_credit_flag,
                                             'CR', adjustment_amount,
                                                   -adjustment_amount),
                        decode(debit_credit_flag,
                               'CR', adjustment_amount,
                                     -adjustment_amount)))
        from fa_mc_adjustments
       where asset_id               = p_asset_id
         and book_type_code         = p_book_type_code
         and period_counter_created = p_period_counter
         and transaction_header_id  = p_thid
         and adjustment_type        like p_adj_type
         and set_of_books_id        = l_set_of_books_id;

   l_calling_fn                     VARCHAR2(35) := 'fa_inv_xfr_pub.do_all_books';
   inv_xfr_err                      EXCEPTION;


begin

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'calling',
                       'fazcrsob', p_log_level_rec => p_log_level_rec);
   end if;


   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => p_src_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise inv_xfr_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       'looping through',
                       'set of books', p_log_level_rec => p_log_level_rec);
   end if;

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      if (l_sob_index = 0) then
         l_reporting_flag := 'P';
         l_set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
      else
         l_reporting_flag := 'R';
         l_set_of_books_id := l_sob_tbl(l_sob_index);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'processing',
                          'cursor to get sum of amounts', p_log_level_rec => p_log_level_rec);
      end if;

      -- get the interco and cost totals
      if (l_sob_index = 0) then
         open c_total_amount
                (p_asset_id       => p_src_asset_hdr_rec.asset_id,
                 p_book_type_code => p_src_asset_hdr_rec.book_type_code,
                 p_period_counter => p_period_counter,
                 p_thid           => p_src_trans_rec.transaction_header_id,
                 p_adj_type       => '%INTERCO%');
         fetch c_total_amount into l_interco_amount;
         close c_total_amount;

         open c_total_amount
                (p_asset_id       => p_src_asset_hdr_rec.asset_id,
                 p_book_type_code => p_src_asset_hdr_rec.book_type_code,
                 p_period_counter => p_period_counter,
                 p_thid           => p_src_trans_rec.transaction_header_id,
                 p_adj_type       => '%COST%');
         fetch c_total_amount into l_cost_amount;
         close c_total_amount;
      else
         open c_total_amount_mrc
                (p_asset_id       => p_src_asset_hdr_rec.asset_id,
                 p_book_type_code => p_src_asset_hdr_rec.book_type_code,
                 p_period_counter => p_period_counter,
                 p_thid           => p_src_trans_rec.transaction_header_id,
                 p_adj_type       => '%INTERCO%');
         fetch c_total_amount_mrc into l_interco_amount;
         close c_total_amount_mrc;

         open c_total_amount_mrc
                (p_asset_id       => p_src_asset_hdr_rec.asset_id,
                 p_book_type_code => p_src_asset_hdr_rec.book_type_code,
                 p_period_counter => p_period_counter,
                 p_thid           => p_src_trans_rec.transaction_header_id,
                 p_adj_type       => '%COST%');
         fetch c_total_amount_mrc into l_cost_amount;
         close c_total_amount_mrc;
      end if;

      l_delta_amount := l_cost_amount - l_interco_amount;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,
                          'src cost amount',
                           l_cost_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,
                          'src interco amount',
                           l_interco_amount, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,
                          'l_delta_amount',
                           l_delta_amount, p_log_level_rec => p_log_level_rec);
      end if;

      if (l_delta_amount <> 0) then

         -- insert the difference as clearing to the ccid found above
         -- first the source

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'setting up',
                             'adj struct for src', p_log_level_rec => p_log_level_rec);
         end if;


         l_adj.transaction_header_id    := p_src_trans_rec.transaction_header_id;
         l_adj.asset_id                 := p_src_asset_hdr_rec.asset_id;
         l_adj.book_type_code           := p_src_asset_hdr_rec.book_type_code;
         l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.current_units            := p_src_current_units;
         l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.selection_thid           := 0;
         l_adj.selection_retid          := 0;
         l_adj.leveling_flag            := TRUE;
         l_adj.last_update_date         := p_src_trans_rec.who_info.last_update_date;

         l_adj.flush_adj_flag           := FALSE;
         l_adj.gen_ccid_flag            := FALSE;
         l_adj.annualized_adjustment    := 0;
         l_adj.asset_invoice_id         := 0;
         l_adj.code_combination_id      := p_ccid;
         l_adj.distribution_id          := 0;

         l_adj.deprn_override_flag      := '';

         if (p_src_asset_type = 'CIP') then
            l_adj.source_type_code      := 'CIP ADJUSTMENT';
         else
            l_adj.source_type_code      := 'ADJUSTMENT';
         end if;

         l_adj.adjustment_type          := 'COST CLEARING';

         if l_delta_amount > 0 then
            l_adj.debit_credit_flag     := 'DR';
            l_adj.adjustment_amount     := l_delta_amount;
         else
            l_adj.debit_credit_flag     := 'CR';
            l_adj.adjustment_amount     := -l_delta_amount;
         end if;

         l_adj.mrc_sob_type_code        := l_reporting_flag ;
         l_adj.set_of_books_id          := l_set_of_books_id;

         if not FA_INS_ADJUST_PKG.faxinaj
                   (l_adj,
                    p_src_trans_rec.who_info.last_update_date,
                    p_src_trans_rec.who_info.last_updated_by,
                    p_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise inv_xfr_err;
         end if;

         -- then the destination
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,
                             'setting up',
                             'adj struct for dest', p_log_level_rec => p_log_level_rec);
         end if;

         l_adj.transaction_header_id    := p_dest_trans_rec.transaction_header_id;
         l_adj.asset_id                 := p_dest_asset_hdr_rec.asset_id;
         l_adj.book_type_code           := p_dest_asset_hdr_rec.book_type_code;
         l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
         l_adj.current_units            := p_dest_current_units;
         l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
         l_adj.selection_thid           := 0;
         l_adj.selection_retid          := 0;
         l_adj.leveling_flag            := TRUE;
         l_adj.last_update_date         := p_dest_trans_rec.who_info.last_update_date;

         l_adj.flush_adj_flag           := TRUE;
         l_adj.gen_ccid_flag            := FALSE;
         l_adj.annualized_adjustment    := 0;
         l_adj.asset_invoice_id         := 0;
         l_adj.code_combination_id      := p_ccid;
         l_adj.distribution_id          := 0;

         l_adj.deprn_override_flag      := '';

         if (p_dest_asset_type = 'CIP') then
            l_adj.source_type_code      := 'CIP ADJUSTMENT';
         else
            l_adj.source_type_code      := 'ADJUSTMENT';
         end if;

         l_adj.adjustment_type          := 'COST CLEARING';

         if l_delta_amount > 0 then
            l_adj.debit_credit_flag     := 'CR';
            l_adj.adjustment_amount     := l_delta_amount;
         else
            l_adj.debit_credit_flag     := 'DR';
            l_adj.adjustment_amount     := -l_delta_amount;
         end if;

         l_adj.mrc_sob_type_code        := l_reporting_flag ;
         l_adj.set_of_books_id          := l_set_of_books_id;

         if not FA_INS_ADJUST_PKG.faxinaj
                   (l_adj,
                    p_src_trans_rec.who_info.last_update_date,
                    p_src_trans_rec.who_info.last_updated_by,
                    p_src_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
            raise inv_xfr_err;
         end if;


      end if;

   END LOOP;

   return true;

exception
   when inv_xfr_err then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;

end do_all_books;

-- Bug 8862296 Changes start here.
FUNCTION do_inv_sub_transfer
           (p_src_trans_rec          IN FA_API_TYPES.trans_rec_type,
            p_src_asset_hdr_rec      IN FA_API_TYPES.asset_hdr_rec_type,
            p_dest_trans_rec         IN FA_API_TYPES.trans_rec_type,
            p_dest_asset_hdr_rec     IN FA_API_TYPES.asset_hdr_rec_type,
            p_inv_tbl                IN FA_API_TYPES.inv_tbl_type,
            p_inv_trans_rec          IN FA_API_TYPES.inv_trans_rec_type,
            p_log_level_rec          IN FA_API_TYPES.log_level_rec_type) return boolean IS

   x_msg_count                      NUMBER;
   x_msg_data                       VARCHAR2(1000);
   l_calling_fn                     VARCHAR2(35) := 'fa_inv_xfr_pub.do_inv_sub_transfer';

   l_src_trans_rec                  FA_API_TYPES.trans_rec_type := p_src_trans_rec;
   l_src_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type := p_src_asset_hdr_rec;
   l_dest_trans_rec                 FA_API_TYPES.trans_rec_type := p_dest_trans_rec;
   l_dest_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type := p_dest_asset_hdr_rec;
   l_inv_tbl                        FA_API_TYPES.inv_tbl_type := p_inv_tbl;
   l_inv_trans_rec                  FA_API_TYPES.inv_trans_rec_type := p_inv_trans_rec;

   l_dest_asset_fin_rec_adj         FA_API_TYPES.asset_fin_rec_type;
   l_dest_asset_fin_rec_new         FA_API_TYPES.asset_fin_rec_type;
   l_dest_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;
   l_dest_asset_deprn_rec_adj       FA_API_TYPES.asset_deprn_rec_type;
   l_dest_asset_deprn_rec_new       FA_API_TYPES.asset_deprn_rec_type;
   l_dest_asset_deprn_mrc_tbl_new   FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec      FA_API_TYPES.group_reclass_options_rec_type;

   l_from_asset_type     varchar2(15);
   l_to_asset_type       varchar2(15);
   l_from_current_units  number;
   l_to_current_units    number;

   l_clearing_ccid       number;
   l_interco_impact      boolean;

   l_current_period_counter         NUMBER;
   l_return_status                  VARCHAR2(1);

   inv_xfr_err                      EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'Before Calling Do_Adjustment for','DESTINATION', p_log_level_rec => p_log_level_rec);
   end if;

   -- call do_adjustment for dest asset
   FA_ADJUSTMENT_PUB.do_adjustment
            (p_api_version             => 1.0,
             p_init_msg_list           => FND_API.G_FALSE,
             p_commit                  => FND_API.G_FALSE,
             p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
             x_return_status           => l_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data,
             p_calling_fn              => l_calling_fn,
             px_trans_rec              => l_dest_trans_rec,
             px_asset_hdr_rec          => l_dest_asset_hdr_rec,
             p_asset_fin_rec_adj       => l_dest_asset_fin_rec_adj,
             x_asset_fin_rec_new       => l_dest_asset_fin_rec_new,
             x_asset_fin_mrc_tbl_new   => l_dest_asset_fin_mrc_tbl_new,
             px_inv_trans_rec          => l_inv_trans_rec,
             px_inv_tbl                => l_inv_tbl,
             p_asset_deprn_rec_adj     => l_dest_asset_deprn_rec_adj,
             x_asset_deprn_rec_new     => l_dest_asset_deprn_rec_new,
             x_asset_deprn_mrc_tbl_new => l_dest_asset_deprn_mrc_tbl_new,
             p_group_reclass_options_rec => l_group_reclass_options_rec
            );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      raise inv_xfr_err;
   end if;

   if not FA_ASSET_VAL_PVT.validate_period_of_addition
                           (p_asset_id            => l_src_asset_hdr_rec.asset_id,
                            p_book                => l_src_asset_hdr_rec.book_type_code,
                            p_mode                => 'ABSOLUTE',
                            px_period_of_addition => l_src_asset_hdr_rec.period_of_addition,
                            p_log_level_rec       => p_log_level_rec) then
      raise inv_xfr_err;
   end if;
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
                           (p_asset_id            => l_dest_asset_hdr_rec.asset_id,
                            p_book                => l_dest_asset_hdr_rec.book_type_code,
                            p_mode                => 'ABSOLUTE',
                            px_period_of_addition => l_dest_asset_hdr_rec.period_of_addition,
                            p_log_level_rec       => p_log_level_rec) then
      raise inv_xfr_err;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,'src.period_of_addition',l_src_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'dest.period_of_addition',l_dest_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'src.thid',l_src_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn,'dest.thid',l_dest_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
   end if;

   -- only fire the intercompany logic for 11i
   if (g_release = 11 ) then
      if not FA_INTERCO_PVT.validate_inv_interco
          (p_src_asset_hdr_rec    => l_src_asset_hdr_rec,
           p_src_trans_rec        => l_src_trans_rec,
           p_dest_asset_hdr_rec   => l_dest_asset_hdr_rec,
           p_dest_trans_rec       => l_dest_trans_rec,
           p_calling_fn           => l_calling_fn,
           x_interco_impact       => l_interco_impact, p_log_level_rec => p_log_level_rec) then
         raise inv_xfr_err;
      end if;
   end if;

   if (p_log_level_rec.statement_level) then
      if (l_interco_impact) then
         fa_debug_pkg.add(l_calling_fn,'intercompany impact','TRUE', p_log_level_rec => p_log_level_rec);
      else
         fa_debug_pkg.add(l_calling_fn,'intercompany impact','FALSE', p_log_level_rec => p_log_level_rec);
      end if;
   end if;

   select asset_type,current_units
     into l_from_asset_type,l_from_current_units
     from fa_additions_b
    where asset_id = l_src_asset_hdr_rec.asset_id;

   select asset_type,current_units
     into l_to_asset_type,l_to_current_units
     from fa_additions_b
    where asset_id = l_dest_asset_hdr_rec.asset_id;

   if ((l_dest_asset_hdr_rec.period_of_addition = 'N' and
        l_src_asset_hdr_rec.period_of_addition  = 'N' and
        l_from_asset_type = l_to_asset_type)
        or g_release <> 11) then

      if not fa_cache_pkg.fazcbc(X_book => l_src_asset_hdr_rec.book_type_code,
                                 p_log_level_rec => p_log_level_rec) then
         raise inv_xfr_err;
      end if;

      l_current_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter + 1;

      delete from fa_adjustments
       where asset_id              in (l_src_asset_hdr_rec.asset_id,l_dest_asset_hdr_rec.asset_id)
         and book_type_code         = l_src_asset_hdr_rec.book_type_code
         and period_counter_created = l_current_period_counter
         and transaction_header_id in (l_dest_trans_rec.transaction_header_id,l_src_trans_rec.transaction_header_id)
         and adjustment_type        = 'COST CLEARING';

      delete from fa_mc_adjustments
       where asset_id              in (l_src_asset_hdr_rec.asset_id,l_dest_asset_hdr_rec.asset_id)
         and book_type_code         = l_src_asset_hdr_rec.book_type_code
         and period_counter_created = l_current_period_counter
         and transaction_header_id in (l_dest_trans_rec.transaction_header_id,l_src_trans_rec.transaction_header_id)
         and adjustment_type        = 'COST CLEARING';

      -- only fire the intercompany logic for pre-R12
      if (l_interco_impact and g_release = 11) then
         if not fa_interco_pvt.do_all_books(p_src_trans_rec      => l_src_trans_rec,
                                            p_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                                            p_dest_trans_rec     => l_dest_trans_rec,
                                            p_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                                            p_calling_fn         => l_calling_fn,
                                            p_log_level_rec      => p_log_level_rec) then
            raise inv_xfr_err;
         end if;
      end if;

   elsif (l_dest_asset_hdr_rec.period_of_addition = 'N' and l_src_asset_hdr_rec.period_of_addition  = 'N') then

      SELECT CODE_COMBINATION_ID
        INTO l_clearing_ccid
        FROM FA_ADJUSTMENTS
       WHERE ASSET_ID              = l_src_asset_hdr_rec.asset_id
         AND BOOK_TYPE_CODE        = l_src_asset_hdr_rec.book_type_code
         AND TRANSACTION_HEADER_ID = l_src_trans_rec.transaction_header_id
         AND ADJUSTMENT_TYPE       = 'COST CLEARING'
         AND ROWNUM                < 2;

      if (l_interco_impact) then

         l_current_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter + 1;

         delete from fa_adjustments
          where asset_id              in (l_src_asset_hdr_rec.asset_id,l_dest_asset_hdr_rec.asset_id)
            and book_type_code         = l_src_asset_hdr_rec.book_type_code
            and period_counter_created = l_current_period_counter
            and transaction_header_id in (l_dest_trans_rec.transaction_header_id,l_src_trans_rec.transaction_header_id)
            and adjustment_type        = 'COST CLEARING';

         delete from fa_mc_adjustments
          where asset_id              in (l_src_asset_hdr_rec.asset_id,l_dest_asset_hdr_rec.asset_id)
            and book_type_code         = l_src_asset_hdr_rec.book_type_code
            and period_counter_created = l_current_period_counter
            and transaction_header_id in (l_dest_trans_rec.transaction_header_id,l_src_trans_rec.transaction_header_id)
            and adjustment_type        = 'COST CLEARING';

         if not fa_interco_pvt.do_all_books(p_src_trans_rec      => l_src_trans_rec,
                                            p_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                                            p_dest_trans_rec     => l_dest_trans_rec,
                                            p_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                                            p_calling_fn         => l_calling_fn,
                                            p_log_level_rec      => p_log_level_rec) then
            raise inv_xfr_err;
         end if;

         if not do_all_books(p_src_trans_rec      => l_src_trans_rec,
                             p_src_asset_hdr_rec  => l_src_asset_hdr_rec,
                             p_dest_trans_rec     => l_dest_trans_rec,
                             p_dest_asset_hdr_rec => l_dest_asset_hdr_rec,
                             p_period_counter     => l_current_period_counter,
                             p_ccid               => l_clearing_ccid,
                             p_src_asset_type     => l_from_asset_type,
                             p_dest_asset_type    => l_to_asset_type,
                             p_src_current_units  => l_from_current_units,
                             p_dest_current_units => l_to_current_units,
                             p_calling_fn         => l_calling_fn,
                             p_log_level_rec      => p_log_level_rec) then
            raise inv_xfr_err;
         end if;

      else

         UPDATE FA_ADJUSTMENTS
            SET CODE_COMBINATION_ID   = l_clearing_ccid,
                DEBIT_CREDIT_FLAG     = DECODE(DEBIT_CREDIT_FLAG, 'CR','DR','CR'),
                ADJUSTMENT_AMOUNT     = -1 * ADJUSTMENT_AMOUNT
          WHERE ASSET_ID              = l_src_asset_hdr_rec.asset_id
            AND BOOK_TYPE_CODE        = l_src_asset_hdr_rec.book_type_code
            AND TRANSACTION_HEADER_ID = l_src_trans_rec.transaction_header_id
            AND ADJUSTMENT_TYPE       = 'COST CLEARING';

         UPDATE FA_MC_ADJUSTMENTS
            SET CODE_COMBINATION_ID   = l_clearing_ccid,
                DEBIT_CREDIT_FLAG     = DECODE(DEBIT_CREDIT_FLAG, 'CR','DR','CR'),
                ADJUSTMENT_AMOUNT     = -1 * ADJUSTMENT_AMOUNT
         WHERE ASSET_ID               = l_src_asset_hdr_rec.asset_id
            AND BOOK_TYPE_CODE        = l_src_asset_hdr_rec.book_type_code
            AND TRANSACTION_HEADER_ID = l_src_trans_rec.transaction_header_id
            AND ADJUSTMENT_TYPE       = 'COST CLEARING';

         UPDATE FA_ADJUSTMENTS
            SET CODE_COMBINATION_ID   = l_clearing_ccid,
                DEBIT_CREDIT_FLAG     = DECODE(DEBIT_CREDIT_FLAG, 'CR','DR','CR'),
                ADJUSTMENT_AMOUNT     = -1 * ADJUSTMENT_AMOUNT
          WHERE ASSET_ID              = l_dest_asset_hdr_rec.asset_id
            AND BOOK_TYPE_CODE        = l_dest_asset_hdr_rec.book_type_code
            AND TRANSACTION_HEADER_ID = l_dest_trans_rec.transaction_header_id
            AND ADJUSTMENT_TYPE       = 'COST CLEARING';

         UPDATE FA_MC_ADJUSTMENTS
            SET CODE_COMBINATION_ID   = l_clearing_ccid,
                DEBIT_CREDIT_FLAG     = DECODE(DEBIT_CREDIT_FLAG, 'CR','DR','CR'),
                ADJUSTMENT_AMOUNT     = -1 * ADJUSTMENT_AMOUNT
          WHERE ASSET_ID              = l_dest_asset_hdr_rec.asset_id
            AND BOOK_TYPE_CODE        = l_dest_asset_hdr_rec.book_type_code
            AND TRANSACTION_HEADER_ID = l_dest_trans_rec.transaction_header_id
            AND ADJUSTMENT_TYPE       = 'COST CLEARING';

      end if; -- interco impact
   end if; -- asset type and period of addition

   -- SLA: update the source_dest_code accordingly
   -- ideally would do this for cost in FAVIATB.pls but no good way to do so
   update fa_adjustments
      set source_dest_code = decode(transaction_header_Id,l_src_trans_rec.transaction_header_id, 'SOURCE','DEST')
   where transaction_header_id in (l_src_trans_rec.transaction_header_id,l_dest_trans_rec.transaction_header_id);

   update fa_mc_adjustments
      set source_dest_code =decode(transaction_header_Id,l_src_trans_rec.transaction_header_id, 'SOURCE','DEST')
   where transaction_header_id in (l_src_trans_rec.transaction_header_id,l_dest_trans_rec.transaction_header_id);

   -- Cannot Transfer Lines between expensed and Non Expensed Assets */
   if ((l_from_asset_type =  'EXPENSED' and l_to_asset_type <> 'EXPENSED') OR
       (l_from_asset_type <> 'EXPENSED' and l_to_asset_type  = 'EXPENSED')) THEN
      fa_srvr_msg.add_message(calling_fn      => l_calling_fn,
                              name            => 'FA_TFRINV_NO_EXP_NONEXP',
                              p_log_level_rec => p_log_level_rec);
      raise inv_xfr_err;
   end if;

   return true;

exception
   when inv_xfr_err then

      fa_srvr_msg.add_sql_error(calling_fn      => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);

      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);

      return false;

   when others then

      fa_srvr_msg.add_sql_error(calling_fn      => l_calling_fn,
                                p_log_level_rec => p_log_level_rec);

      FND_MSG_PUB.count_and_get (p_count => x_msg_count,
                                 p_data  => x_msg_data);

      return false;

END do_inv_sub_transfer;
-- Bug 8862296 Changes end here.

END FA_INV_XFR_PUB;

/
