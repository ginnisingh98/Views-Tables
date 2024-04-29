--------------------------------------------------------
--  DDL for Package Body FA_INVOICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_INVOICE_PVT" as
/* $Header: FAVINVB.pls 120.23.12010000.3 2009/07/19 11:35:26 glchen ship $   */

g_release                  number  := fa_cache_pkg.fazarel_release;

-- used for tracking the total payables cost cleared for all invoices
TYPE payables_cost_rec_type IS RECORD
     (set_of_books_id              number,
      payables_cost                number,
      payables_code_combination_id number,
      source_dest_code             varchar2(15),
      source_line_id               number,
      asset_invoice_id             number);

TYPE payables_cost_tbl_type IS TABLE OF payables_cost_rec_type index by binary_integer;

-- private prottypes

FUNCTION inv_calc_info
   (p_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec         IN     FA_API_TYPES.asset_type_rec_type,
    p_inv_trans_rec          IN     FA_API_TYPES.inv_trans_rec_type,
    px_inv_rec               IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
    px_asset_fin_rec_new     IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    px_asset_deprn_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION  process_invoice
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    px_inv_rec                 IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_inv_rate_rec             IN     FA_API_TYPES.inv_rate_rec_type,
    p_mrc_sob_type_code        IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION get_inv_rate
   (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION post_clearing
   (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    p_payables_cost_tbl        IN     payables_cost_tbl_type,
    p_payables_cost_mrc_tbl    IN     payables_cost_tbl_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

-- public function

FUNCTION invoice_engine
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_mrc_tbl_new       OUT NOCOPY FA_API_TYPES.asset_fin_tbl_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_mrc_tbl_new     OUT NOCOPY FA_API_TYPES.asset_deprn_tbl_type,
    p_calling_fn               IN            varchar2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_rowid                   varchar2(100);  -- placeholder for table handlers
   l_row_count               number := 0;
   l_deprn_count             number := 0;
   l_create_new_row          varchar2(3);
   l_current_fa_cost         number;
   l_current_pa_cost         number;
   l_current_source_line_id  number;
   l_inv_rec_fa_cost_primary number;

   -- local structs used for manipulation
   l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
   l_inv_rec                 FA_API_TYPES.inv_rec_type;
   l_inv_rate_rec            FA_API_TYPES.inv_rate_rec_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;

   l_count                   number;

   -- mrc checks
   l_sob_tbl                 FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_reporting_flag          varchar2(1);
   l_mrc_rate_found_count    number := 0;
   l_mrc_rate_index          number := 0;
   l_mrc_fin_book_rec        number := 0;
   l_mrc_deprn_rec           number := 0;

   l_mrc_date                date;

   l_payables_cost_tbl       payables_cost_tbl_type;
   l_payables_cost_mrc_tbl   payables_cost_tbl_type;
   l_payables_cost_count     number;
   l_payables_cost_mrc_count number;

   -- new variables for merging mrc trigger logic
   l_primary_sob_id          NUMBER;
   l_exchange_date           date;


   -- exceptions
   l_calling_fn              varchar2(35) := 'fa_inv_pvt.invoice_engine';
   error_found               exception;


BEGIN

    l_asset_hdr_rec              := px_asset_hdr_rec;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn,
                        'px_inv_tbl.count',
                        px_inv_tbl.count, p_log_level_rec => p_log_level_rec);
    end if;

    if (px_inv_tbl.count = 0) then
       fa_srvr_msg.add_message(
           calling_fn => l_calling_fn,
           name       => '***NO_INVOICES***',
           p_log_level_rec => p_log_level_rec);
       raise error_found;
    end if;


    --  store the current profile value and then use the definitive value
    --  for the book in question and check whether this is a reporting book.

    if (fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y') then

       -- call the sob cache to get the table of sob_ids
       if not FA_CACHE_PKG.fazcrsob
               (x_book_type_code => px_asset_hdr_rec.book_type_code,
                x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
          raise error_found;
       end if;

    end if;



    -- insert invoice transaction row(only for null values)
    -- when called for destination asset in a source line transfer it will be populated)


    if (px_inv_trans_rec.invoice_transaction_id is null) then

       FA_INVOICE_TRANSACTIONS_PKG.Insert_Row
         (X_Rowid                     => l_rowid,
          X_Invoice_Transaction_Id    => px_inv_trans_rec.invoice_transaction_id ,
          X_Book_Type_Code            => px_asset_hdr_rec.book_type_code,
          X_Transaction_Type          => px_inv_trans_rec.transaction_type,
          X_Date_Effective            => sysdate,
          X_Calling_Fn                => 'FA_INVOICE_API_PKG.invoice_engine'
         , p_log_level_rec => p_log_level_rec);

    end if;


    --  initialize the new fin struct to the incoming values
    --  in the case of the addition engine, this will be
    --  populated before hand for fields like DPIS, etc.
    --  for adjustments, it will be null anyway

    x_asset_fin_rec_new                           := p_asset_fin_rec_adj;
    x_asset_fin_rec_new.adjusted_cost             := 0;
    x_asset_fin_rec_new.original_cost             := 0;
    -- NOTE: do not set salvage here as it needs to be null
    -- when not populated do the default percent salvage is used
    -- within the cal engine
    -- x_asset_fin_rec_new.salvage_value             := 0;
    x_asset_fin_rec_new.recoverable_cost          := 0;
    x_asset_fin_rec_new.adjusted_recoverable_cost := 0;
    x_asset_fin_rec_new.reval_amortization_basis  := 0;
    x_asset_fin_rec_new.old_adjusted_cost         := 0;
    x_asset_fin_rec_new.cost                      := 0;

    x_asset_deprn_rec_new.deprn_amount             := 0;
    x_asset_deprn_rec_new.ytd_deprn                := 0;
    x_asset_deprn_rec_new.deprn_reserve            := 0;
    x_asset_deprn_rec_new.bonus_ytd_deprn          := 0;
    x_asset_deprn_rec_new.bonus_deprn_reserve      := 0;
    x_asset_deprn_rec_new.reval_amortization_basis := 0;
    x_asset_deprn_rec_new.reval_deprn_expense      := 0;
    x_asset_deprn_rec_new.reval_ytd_deprn          := 0;
    x_asset_deprn_rec_new.reval_deprn_reserve      := 0;


    -- init the mrc fin structs - the fin struct will NOT be populated yet for invoice trx's
    -- any trx or just adjs via invoice trx?


    l_count := 0;

    FOR l_sob_index in 1..l_sob_tbl.count LOOP

        l_count := l_count + 1;
        x_asset_fin_mrc_tbl_new(l_count)                     := x_asset_fin_rec_new;
        x_asset_fin_mrc_tbl_new(l_count).set_of_books_id     := l_sob_tbl(l_sob_index);
        x_asset_deprn_mrc_tbl_new(l_count)                   := x_asset_deprn_rec_new;
        x_asset_deprn_mrc_tbl_new(l_count).set_of_books_id   := l_sob_tbl(l_sob_index);

    end loop;


    l_asset_hdr_rec.set_of_books_id := px_asset_hdr_rec.set_of_books_id;

    l_row_count := 0;

    -- load the inv_rate table for existing source lines
    -- SLA - this will fetch all currencies at one time

    if not get_inv_rate
            (p_trans_rec       => px_trans_rec,
             p_asset_hdr_rec   => px_asset_hdr_rec,
             p_inv_trans_rec   => px_inv_trans_rec,
             px_inv_tbl        => px_inv_tbl,
             p_log_level_rec   => p_log_level_rec) then
         raise error_found;
    end if;

    while (l_row_count < px_inv_tbl.count) loop  -- loop for invoices array

       l_current_source_line_id := px_inv_tbl(l_row_count + 1).source_line_id;

       -- call for primary book first
       -- initialize the invoice structs to be passed
       -- to process_invoice to the current row in the table.
       -- The values in this struct will be added to those
       -- being incremented in the p_fin_new struct.


       -- load the non financial info into the struct using get utility
       if (px_inv_trans_rec.transaction_type <> 'MASS ADDITION' and
           px_inv_trans_rec.transaction_type <> 'INVOICE ADDITION' and
           px_inv_tbl(l_row_count + 1).source_line_id is not null) then

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn,
                              'in invoice loop, source_line_id',
                              px_inv_tbl(l_row_count + 1).source_line_id);
             fa_debug_pkg.add(l_calling_fn,
                              'in invoice loop, fa cost',
                              px_inv_tbl(l_row_count + 1).fixed_assets_cost);
             fa_debug_pkg.add(l_calling_fn,
                              'in invoice loop, ap cost',
                              px_inv_tbl(l_row_count + 1).payables_cost);
          end if;

          -- set the source_line and sob in the local struct
          l_inv_rec.source_line_Id := px_inv_tbl(l_row_count + 1).source_line_id;
          if not FA_UTIL_PVT.get_inv_rec
                   (px_inv_rec          => l_inv_rec,
                    p_mrc_sob_type_code => 'P',
                    p_set_of_books_id   => null,
                    p_inv_trans_rec     => px_inv_trans_rec, p_log_level_rec => p_log_level_rec) then
             raise error_found;
          end if;

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add(l_calling_fn,
                              'after get_inv_rec, deleted_flag',
                              l_inv_rec.deleted_flag, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn,
                              'after get_inv_rec, dep_in_grp_flag',
                              l_inv_rec.depreciate_in_group_flag, p_log_level_rec => p_log_level_rec);
          end if;

          -- set the current fa cost from the get_inv call
          l_current_fa_cost := l_inv_rec.fixed_assets_cost;
          l_current_pa_cost := l_inv_rec.payables_cost;

          -- reset any info that might change as a result of the invoice transaction
          -- remember that the fa cost is always the delta thus, it goes to 0 if there
          -- is no change.  for deletes and reinstates only the depreciate can flag
          -- however, we need the current cost in order to set the delta info in the
          -- fin rec struct. For deletes, we flip the sign and later on flip it back

          -- adding new flag for group requirements to allow for portions of
          -- a cip asset's cost to be included in the depreciable basis
          -- when set to Y, the cip_cost decreases!

          if (px_inv_trans_rec.transaction_type = 'INVOICE DELETE') then
             if (l_inv_rec.deleted_flag = 'YES') then
                fa_srvr_msg.add_message(
                    calling_fn => l_calling_fn,
                    name       => '***FA_INV_ALREADY_DEL***',
                    p_log_level_rec => p_log_level_rec);
                raise error_found;
             end if;

             l_inv_rec.deleted_flag      := 'YES';
             l_inv_rec.Fixed_Assets_Cost := -l_current_fa_cost;
             l_inv_rec.Payables_Cost     := -l_current_pa_cost;
             if (p_asset_type_rec.asset_type = 'CIP') then
                if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                   l_inv_rec.Cip_Cost          := -l_current_fa_cost;
                else
                   l_inv_rec.Cip_Cost          := 0;
                end if;
             end if;
          elsif (px_inv_trans_rec.transaction_type =  'INVOICE REINSTATE') then
             if (nvl(l_inv_rec.deleted_flag, 'NO') = 'NO') then
                fa_srvr_msg.add_message(
                    calling_fn => l_calling_fn,
                    name       => '***FA_INV_ALREADY_REINS***',
                    p_log_level_rec => p_log_level_rec);
                raise error_found;
             end if;

             l_inv_rec.deleted_flag      := 'NO';
             l_inv_rec.Fixed_Assets_Cost := l_current_fa_cost;
             l_inv_rec.Payables_Cost     := l_current_pa_cost;
             if (p_asset_type_rec.asset_type = 'CIP') then
                if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                   l_inv_rec.Cip_Cost          := l_current_fa_cost;
                else
                   l_inv_rec.Cip_Cost          := 0;
                end if;
             end if;
          elsif (px_inv_trans_rec.transaction_type = 'INVOICE DEP') then
             if (l_inv_rec.depreciate_in_group_flag = 'Y') then
                fa_srvr_msg.add_message(
                    calling_fn => l_calling_fn,
                    name       => '***FA_INV_ALREADY_DEP***',
                    p_log_level_rec => p_log_level_rec);
                raise error_found;
             end if;

             if (p_asset_type_rec.asset_type = 'CIP') then
                l_inv_rec.depreciate_in_group_flag := 'Y';
                l_inv_rec.Cip_Cost          := -l_current_fa_cost;
                l_inv_rec.Fixed_Assets_Cost := 0;
                l_inv_rec.Payables_Cost     := 0;
             else
                raise error_found;
             end if;
          elsif (px_inv_trans_rec.transaction_type = 'INVOICE NO DEP') then
             if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'N') then
                fa_srvr_msg.add_message(
                    calling_fn => l_calling_fn,
                    name       => '***FA_INV_ALREADY_NO_DEP***',
                    p_log_level_rec => p_log_level_rec);
                raise error_found;
             end if;

             if (p_asset_type_rec.asset_type = 'CIP') then
                l_inv_rec.depreciate_in_group_flag := 'N';
                l_inv_rec.Cip_Cost          := l_current_fa_cost;
                l_inv_rec.Fixed_Assets_Cost := 0;
                l_inv_rec.Payables_Cost     := 0;
             else
                raise error_found;
             end if;
          else
             l_inv_rec.Fixed_Assets_Cost              := nvl(px_inv_tbl(l_row_count + 1).Fixed_Assets_Cost, 0);

             -- do not allow delta cost to exceed the current fa cost
             -- in the case of an invoice transfer
             if (px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' and
                 px_inv_tbl(l_row_count + 1).source_line_id is not null) then

                -- can't transfer nothing on non-zero line
                if (l_inv_rec.Fixed_Assets_Cost = 0) then
                   if (l_current_fa_cost <> 0) then
                      fa_srvr_msg.add_message(
                          calling_fn  => l_calling_fn,
                          name        => 'FA_TFRINV_NONE_TFR_COST', p_log_level_rec => p_log_level_rec);
                      raise error_found;
                   end if;
                -- must transfer zero on a zero line
                elsif (l_current_fa_cost = 0) then
                   if (l_inv_rec.Fixed_Assets_Cost <> 0) then
                      fa_srvr_msg.add_message(
                          calling_fn  => l_calling_fn,
                          name        => 'FA_TFRINV_ZERO_TFR_COST', p_log_level_rec => p_log_level_rec);
                      raise error_found;
                   end if;
                -- may not increase the value (due to same sign)
                elsif (sign(l_inv_rec.Fixed_Assets_Cost) = sign(l_current_fa_cost)) then
                   fa_srvr_msg.add_message(
                       calling_fn  => l_calling_fn,
                       name        => 'FA_TFRINV_NOT_BTWN_TFR_COST', p_log_level_rec => p_log_level_rec);
                   raise error_found;
                -- may not transfer more than current value
                elsif ((sign(l_current_fa_cost) > 0 and
                        -l_inv_rec.Fixed_Assets_Cost > l_current_fa_cost) or
                       (sign(l_current_fa_cost) < 0 and
                        -l_inv_rec.Fixed_Assets_Cost < l_current_fa_cost)) then
                   fa_srvr_msg.add_message(
                       calling_fn  => l_calling_fn,
                       name        => 'FA_TFRINV_NOT_BTWN_TFR_COST', p_log_level_rec => p_log_level_rec);
                   raise error_found;
                end if;

             end if;  -- invoice transfer

             -- BUG# 2314466
             -- do not use nvl here as we want to insert null intentionally
             -- and the null value is needed to correctly derive original cost later
             l_inv_rec.Payables_Cost                  := px_inv_tbl(l_row_count + 1).Payables_Cost;

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add('fa_inv_pvt',
                                 'asset_type',
                                 p_asset_type_rec.asset_type, p_log_level_rec => p_log_level_rec);
             end if;

             -- group related stuff - insure we reflect changes to fa_cost in cip_cost
             l_inv_rec.depreciate_in_group_flag := l_inv_rec.depreciate_in_group_flag;

             if (p_asset_type_rec.asset_type = 'CIP') then
                if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                   l_inv_rec.Cip_Cost          := 0;
                else
                   l_inv_rec.Cip_Cost          := nvl(px_inv_tbl(l_row_count + 1).Fixed_Assets_Cost, 0);
                end if;
             end if;

          end if;

          if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('fa_inv_pvt',
                               'cip_cost',
                               l_inv_rec.Cip_Cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add('fa_inv_pvt',
                               'fa_cost',
                               l_inv_rec.fixed_assets_Cost, p_log_level_rec => p_log_level_rec);
          end if;


          l_inv_rec.Po_Vendor_Id                   := nvl(px_inv_tbl(l_row_count + 1).Po_Vendor_Id,
                                                             l_inv_rec.Po_Vendor_Id);
          l_inv_rec.Asset_Invoice_Id               := nvl(px_inv_tbl(l_row_count + 1).Asset_Invoice_Id,
                                                             l_inv_rec.Asset_Invoice_Id);
          l_inv_rec.Po_Number                      := nvl(px_inv_tbl(l_row_count + 1).Po_Number,
                                                             l_inv_rec.Po_Number);
          l_inv_rec.Invoice_Number                 := nvl(px_inv_tbl(l_row_count + 1).Invoice_Number,
                                                             l_inv_rec.Invoice_Number);
          l_inv_rec.Payables_Batch_Name            := nvl(px_inv_tbl(l_row_count + 1).Payables_Batch_Name,
                                                             l_inv_rec.Payables_Batch_Name);
          l_inv_rec.Payables_Code_Combination_Id   := nvl(px_inv_tbl(l_row_count + 1).Payables_Code_Combination_Id,
                                                             l_inv_rec.Payables_Code_Combination_Id);
          l_inv_rec.Feeder_System_Name             := nvl(px_inv_tbl(l_row_count + 1).Feeder_System_Name,
                                                             l_inv_rec.Feeder_System_Name);
          l_inv_rec.Create_Batch_Date              := nvl(px_inv_tbl(l_row_count + 1).Create_Batch_Date,
                                                             l_inv_rec.Create_Batch_Date);
          l_inv_rec.Create_Batch_Id                := nvl(px_inv_tbl(l_row_count + 1).Create_Batch_Id,
                                                             l_inv_rec.Create_Batch_Id);
          l_inv_rec.Invoice_Date                   := nvl(px_inv_tbl(l_row_count + 1).Invoice_Date,
                                                             l_inv_rec.Invoice_Date);
          l_inv_rec.Payables_Cost                  := nvl(px_inv_tbl(l_row_count + 1).Payables_Cost,
                                                             l_inv_rec.Payables_Cost);
          l_inv_rec.Post_Batch_Id                  := nvl(px_inv_tbl(l_row_count + 1).Post_Batch_Id,
                                                             l_inv_rec.Post_Batch_Id);
          l_inv_rec.Invoice_Id                     := nvl(px_inv_tbl(l_row_count + 1).Invoice_Id,
                                                             l_inv_rec.Invoice_Id);
          l_inv_rec.Ap_Distribution_Line_Number    := nvl(px_inv_tbl(l_row_count + 1).Ap_Distribution_Line_Number,
                                                             l_inv_rec.Ap_Distribution_Line_Number);
          l_inv_rec.Payables_Units                 := nvl(px_inv_tbl(l_row_count + 1).Payables_Units,
                                                             l_inv_rec.Payables_Units);
          l_inv_rec.Split_Merged_Code              := nvl(px_inv_tbl(l_row_count + 1).Split_Merged_Code,
                                                             l_inv_rec.Split_Merged_Code);
          l_inv_rec.Description                    := nvl(px_inv_tbl(l_row_count + 1).Description,
                                                             l_inv_rec.Description);
          l_inv_rec.Parent_Mass_Addition_Id        := nvl(px_inv_tbl(l_row_count + 1).Parent_Mass_Addition_Id,
                                                             l_inv_rec.Parent_Mass_Addition_Id);
          l_inv_rec.Attribute1                     := nvl(px_inv_tbl(l_row_count + 1).Attribute1,
                                                             l_inv_rec.Attribute1);
          l_inv_rec.Attribute2                     := nvl(px_inv_tbl(l_row_count + 1).Attribute2,
                                                             l_inv_rec.Attribute2);
          l_inv_rec.Attribute3                     := nvl(px_inv_tbl(l_row_count + 1).Attribute3,
                                                             l_inv_rec.Attribute3);
          l_inv_rec.Attribute4                     := nvl(px_inv_tbl(l_row_count + 1).Attribute4,
                                                             l_inv_rec.Attribute4);
          l_inv_rec.Attribute5                     := nvl(px_inv_tbl(l_row_count + 1).Attribute5,
                                                             l_inv_rec.Attribute5);
          l_inv_rec.Attribute6                     := nvl(px_inv_tbl(l_row_count + 1).Attribute6,
                                                             l_inv_rec.Attribute6);
          l_inv_rec.Attribute7                     := nvl(px_inv_tbl(l_row_count + 1).Attribute7,
                                                             l_inv_rec.Attribute7);
          l_inv_rec.Attribute8                     := nvl(px_inv_tbl(l_row_count + 1).Attribute8,
                                                             l_inv_rec.Attribute8);
          l_inv_rec.Attribute9                     := nvl(px_inv_tbl(l_row_count + 1).Attribute9,
                                                             l_inv_rec.Attribute9);
          l_inv_rec.Attribute10                    := nvl(px_inv_tbl(l_row_count + 1).Attribute10,
                                                             l_inv_rec.Attribute10);
          l_inv_rec.Attribute11                    := nvl(px_inv_tbl(l_row_count + 1).Attribute11,
                                                             l_inv_rec.Attribute11);
          l_inv_rec.Attribute12                    := nvl(px_inv_tbl(l_row_count + 1).Attribute12,
                                                             l_inv_rec.Attribute12);
          l_inv_rec.Attribute13                    := nvl(px_inv_tbl(l_row_count + 1).Attribute13,
                                                             l_inv_rec.Attribute13);
          l_inv_rec.Attribute14                    := nvl(px_inv_tbl(l_row_count + 1).Attribute14,
                                                             l_inv_rec.Attribute14);
          l_inv_rec.Attribute15                    := nvl(px_inv_tbl(l_row_count + 1).Attribute15,
                                                             l_inv_rec.Attribute15);
          l_inv_rec.Attribute_Category_Code        := nvl(px_inv_tbl(l_row_count + 1).Attribute_Category_Code,
                                                             l_inv_rec.Attribute_Category_Code);
          l_inv_rec.Unrevalued_Cost                := nvl(px_inv_tbl(l_row_count + 1).Unrevalued_Cost,
                                                             l_inv_rec.Unrevalued_Cost);
          l_inv_rec.Merged_Code                    := nvl(px_inv_tbl(l_row_count + 1).Merged_Code,
                                                             l_inv_rec.Merged_Code);
          l_inv_rec.Split_Code                     := nvl(px_inv_tbl(l_row_count + 1).Split_Code,
                                                             l_inv_rec.Split_Code);
          l_inv_rec.Merge_Parent_Mass_Additions_Id := nvl(px_inv_tbl(l_row_count + 1).Merge_Parent_Mass_Additions_Id,
                                                             l_inv_rec.Merge_Parent_Mass_Additions_Id);
          l_inv_rec.Split_Parent_Mass_Additions_Id := nvl(px_inv_tbl(l_row_count + 1).Split_Parent_Mass_Additions_Id,
                                                             l_inv_rec.Split_Parent_Mass_Additions_Id);
          l_inv_rec.Project_Asset_Line_Id          := nvl(px_inv_tbl(l_row_count + 1).Project_Asset_Line_Id,
                                                             l_inv_rec.Project_Asset_Line_Id);
          l_inv_rec.Project_Id                     := nvl(px_inv_tbl(l_row_count + 1).Project_Id,
                                                             l_inv_rec.Project_Id);
          l_inv_rec.Task_Id                        := nvl(px_inv_tbl(l_row_count + 1).Task_Id,
                                                             l_inv_rec.Task_Id);

          -- added for R12
          l_inv_rec.invoice_distribution_id        := nvl(px_inv_tbl(l_row_count + 1).invoice_distribution_id,
                                                             l_inv_rec.invoice_distribution_id);
          l_inv_rec.invoice_line_number            := nvl(px_inv_tbl(l_row_count + 1).invoice_line_number,
                                                             l_inv_rec.invoice_line_number);
          l_inv_rec.po_distribution_id             := nvl(px_inv_tbl(l_row_count + 1).po_distribution_id,
                                                             l_inv_rec.po_distribution_id);

          l_inv_rate_rec     := null;

       else

          l_current_fa_cost := 0;
          l_current_pa_cost := 0;

          l_inv_rec          := px_inv_tbl(l_row_count + 1);
          l_inv_rate_rec     := null;

          if (l_inv_rec.deleted_flag is null) then
             l_inv_rec.deleted_flag := 'NO';
          end if;

          if (p_asset_type_rec.asset_type = 'CIP') then
             if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                l_inv_rec.Cip_Cost          := 0;
             else
                l_inv_rec.Cip_Cost          := nvl(px_inv_tbl(l_row_count + 1).Fixed_Assets_Cost, 0);
             end if;
          end if;

          if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('fa_inv_pvt',
                               'cip_cost',
                               l_inv_rec.Cip_Cost, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add('fa_inv_pvt',
                               'fa_cost',
                               l_inv_rec.fixed_assets_Cost, p_log_level_rec => p_log_level_rec);
          end if;

       end if;

       -- call invoice calc

       if not inv_calc_info
               (p_asset_hdr_rec         => px_asset_hdr_rec,
                p_asset_type_rec        => p_asset_type_rec,
                p_inv_trans_rec         => px_inv_trans_rec,
                px_inv_rec              => l_inv_rec,
                px_asset_fin_rec_new    => x_asset_fin_rec_new,
                px_asset_deprn_rec_new  => x_asset_deprn_rec_new,
                p_log_level_rec         => p_log_level_rec
               ) then
           raise error_found;
       end if;

       -- In the case of a source line transfer on the source side,
       -- check the delta and original cost values for the primary book
       -- if they are equal and opposite (i.e. tranferring out all of the cost)
       -- we will only terminate the existing row, not create a new one.
       -- SRC line ret should have same behavior with inv transfer.
       -- Reisntate is not handle below since existing cost +
       -- cost to reinstate won't be zero.

       -- In case of  full source line retirement, new line with 0 amount
       -- still needs to be created.

       -- bug 2543777 (old 2557171)

       -- also adding a join to asset_id to insure the invoice line
       -- in question belongs to the asset on which transaction is being
       -- performed.  get_inv_rec doesn't have such a parameter so doing
       -- this to avoid dependancies.

       if (px_inv_trans_rec.transaction_type in ('INVOICE TRANSFER', 'REINSTATEMENT') and
           l_inv_rec.source_line_id is not null) then

          select decode(fixed_assets_cost + l_inv_rec.fixed_assets_cost,
                        0, 'NO',
                        'YES')
            into l_create_new_row
            from fa_asset_invoices
           where source_line_id = l_inv_rec.source_line_id
             and asset_id       = px_asset_hdr_rec.asset_Id;

       else
          if (l_inv_rec.source_line_id is not null) then
             select 'YES'
               into l_create_new_row
               from fa_asset_invoices
              where source_line_id = l_inv_rec.source_line_id
                and asset_id       = px_asset_hdr_rec.asset_id;
          else
             l_create_new_row := 'YES';
          end if;
       end if;

       -- for non-invoice-addition calls, terminate the existing rows for both
       -- primary and mrc based on the incoming source line id

       if (px_inv_trans_rec.transaction_type <> 'MASS ADDITION'  and
           px_inv_trans_rec.transaction_type <> 'INVOICE ADDITION') then

          update fa_asset_invoices
             set date_ineffective           = sysdate,
                 invoice_transaction_id_out = px_inv_trans_rec.invoice_transaction_id
           where source_line_id             = l_inv_rec.source_line_id;

          update fa_mc_asset_invoices
             set date_ineffective           = sysdate,
                 invoice_transaction_id_out = px_inv_trans_rec.invoice_transaction_id
           where source_line_id             = l_inv_rec.source_line_id;

       end if;


       -- BUG# 2622722
       -- do this for all lines for addition and transfer transactions,
       -- not just those from mass additions.   note that non-xfr adjustment
       -- will use the flexbuilt ccids for now. section has been moved up so
       -- tht the deltas are used, not the final amounts (alos done for mrc below)

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'prior to loading payables info, trx_type',
                           px_inv_trans_rec.transaction_type, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn,
                           'prior to loading payables info, payables_cost',
                           l_inv_rec.payables_cost, p_log_level_rec => p_log_level_rec);
       end if;

       -- SLA conditional handling for clearing for 11i and R12 below:
       if ((px_inv_trans_rec.transaction_type = 'MASS ADDITION' or
            px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' or
            px_inv_trans_rec.transaction_type = 'INVOICE ADDITION') and
           l_inv_rec.payables_cost <> 0 and
           (G_release <> 11 or
            l_inv_rec.payables_code_combination_id is not null)) then
           l_payables_cost_count := l_payables_cost_tbl.count + 1;
           l_payables_cost_tbl(l_payables_cost_count).payables_cost :=
              l_inv_rec.payables_cost;
           l_payables_cost_tbl(l_payables_cost_count).payables_code_combination_id :=
              l_inv_rec.payables_code_combination_id;
           l_payables_cost_tbl(l_payables_cost_count).source_dest_code :=
              l_inv_rec.source_dest_code;

           -- for new lines, the source line is is not known
           -- yet so we assign this after nexval fetch
           -- l_payables_cost_tbl(l_payables_cost_count).source_line_id :=
           --   l_inv_rec.source_line_id;

       end if;


       if (l_create_new_row = 'YES') OR
	  (px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' and
	   l_create_new_row = 'NO') then

          -- now for invoice transfers and adjustments, use the current values of the invoice
          -- that was just terminated and then add the delta.  This will be the resulting cost
          -- of the new line.  For invoice transfers, if full cost was transfered, we will
          -- be entering this logic for the source asset.  Delta is the net effect, neg or pos.
          -- SRC line ret should have same behavior with inv transfer.

          if (px_inv_trans_rec.transaction_type = 'INVOICE ADJUSTMENT' or
              (px_inv_trans_rec.transaction_type in ('INVOICE TRANSFER',
                                                     'RETIREMENT',
                                                     'REINSTATEMENT') and
               l_inv_rec.source_line_id is not null)) then

             l_inv_rec.fixed_assets_cost := nvl(l_current_fa_cost, 0) +
                                               nvl(l_inv_rec.fixed_assets_cost, 0);

             -- BUG# 2314466
             -- do not use nvl as form transactions should insert null
             -- and this is used for deriving original_cost later on too

             l_inv_rec.payables_cost     := l_current_pa_cost +
                                               l_inv_rec.payables_cost;


          -- for deletes, reset the sign on fa_cost
          -- no need for group depreciation change as delta = 0
          elsif (px_inv_trans_rec.transaction_type = 'INVOICE DELETE' or
                 px_inv_trans_rec.transaction_type = 'INVOICE DEP' or
                 px_inv_trans_rec.transaction_type = 'INVOICE NO DEP') then
             l_inv_rec.Fixed_Assets_Cost := l_current_fa_cost;
             l_inv_rec.Payables_Cost     := l_current_pa_cost;
          end if;

          -- original code here for setting up the payables cost rec/table has been moved above
          -- the previous section as this needs to be done, before resetting the cost amounts


          -- Need to get the asset_invoice_id and source_line_id values here
          -- first assign the old source_line_id to self join column
          -- for audit trail (BUG# 3033220).  On the source side, the
          -- source line id is populated, on the destination side, it
          -- is not, but the invoice transfer api will populate the
          -- the prior value for the dest

          if (l_inv_rec.source_line_id is not null) then
             l_inv_rec.prior_source_line_id := l_inv_rec.source_line_id;
          end if;

          select FA_ASSET_INVOICES_S.nextval
            into l_inv_rec.source_line_id
            from dual;


          -- R12: need to assign source lne id here
          if ((px_inv_trans_rec.transaction_type = 'MASS ADDITION' or
               px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' or
               px_inv_trans_rec.transaction_type = 'INVOICE ADDITION') and
              l_inv_rec.payables_cost <> 0) then

             l_payables_cost_tbl(l_payables_cost_count).source_line_id :=
                l_inv_rec.source_line_id;
          end if;


          if l_inv_rec.asset_invoice_id is null then
             select FA_MASS_ADDITIONS_S.nextval
               into l_inv_rec.asset_invoice_id
               from dual;
          end if;

	  if (l_create_new_row = 'YES') then
             if not process_invoice
                (px_trans_rec            => px_trans_rec,
                 px_asset_hdr_rec        => px_asset_hdr_rec,
                 p_inv_trans_rec         => px_inv_trans_rec,
                 px_inv_rec              => l_inv_rec,        -- current row primary,
                 p_inv_rate_rec          => l_inv_rate_rec,   -- null for primary
                 p_mrc_sob_type_code     => 'P',
                 p_log_level_rec         => p_log_level_rec
                ) then raise error_found;
              end if;
	  end if;

          l_inv_rec_fa_cost_primary := l_inv_rec.fixed_assets_cost;

          -- call process_invoice for reporting books by looping through each reporting book

          if (fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y') then

             if (px_inv_tbl(l_row_count + 1).inv_rate_tbl.count > 0 and
                 px_inv_tbl(l_row_count + 1).inv_rate_tbl.count <> l_sob_tbl.count) then
                fa_srvr_msg.add_message(
                    calling_fn => l_calling_fn,
                    name       => '***NOT_ENOUGH_INVRATES***');
                raise error_found;    -- not enough rates for each invoice
             end if;   -- end init mrc


             FOR l_sob_index in 1..l_sob_tbl.count LOOP
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,
                                    'in reporting loop, reporting_sob',
                                    l_sob_tbl(l_sob_index));
                end if;

                -- BUG# 2632955
                -- call the cache to set the sob_id used for rounding and other lower
                -- level code for each book.
                if NOT fa_cache_pkg.fazcbcs(X_book => px_asset_hdr_rec.book_type_code,
                                            X_set_of_books_id => l_sob_tbl(l_sob_index),
                                            p_log_level_rec => p_log_level_rec) then
                   raise error_found;
                end if;

                l_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
                l_mrc_rate_found_count := 0;
                l_mrc_rate_index       := 0;


                -- need to locate the matching invoice rate for the given invoice.
                -- can do this by this inv_indicator for new lines or theoretically
                -- via source_line_id for existing ones.  inv_indicator is simply a
                -- a temporary key so calling code doesn't have to access sequences, etc.

                for i in 1..px_inv_tbl(l_row_count + 1).inv_rate_tbl.count loop

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                                       'inside',
                                       'inv rate loop',
                                       p_log_level_rec);
                      fa_debug_pkg.add(l_calling_fn,
                                       'px_inv_tbl(l_row_count + 1).inv_rate_tbl(i).set_of_books_id',
                                       px_inv_tbl(l_row_count + 1).inv_rate_tbl(i).set_of_books_id,
                                       p_log_level_rec);
                      fa_debug_pkg.add(l_calling_fn,
                                       'sob_id',
                                       l_sob_tbl(l_sob_index),
                                       p_log_level_rec);

                   end if;

                   -- match only based on sob now, indicator is obsolete in SLA as we have nested the rate
                   if (px_inv_tbl(l_row_count + 1).inv_rate_tbl(i).set_of_books_id = l_sob_tbl(l_sob_index)) then
                         l_mrc_rate_found_count := l_mrc_rate_found_count + 1;
                         l_mrc_rate_index       := i;
                         l_inv_rate_rec         := px_inv_tbl(l_row_count + 1).inv_rate_tbl(i);
                   end if;

                end loop;

                -- BUG# 2613834
                -- exchange will no longer be derived at insertion
                -- via the trigger, but will be done here inside the engine
                -- thus if rate isn't populated, we'll find it for AP/PA/other lines

                if (l_mrc_rate_found_count > 1) then

                   fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => '***WRONG_NUM_INVRATES2***',
                      p_log_level_rec => p_log_level_rec);
                   raise error_found;
                elsif (l_mrc_rate_found_count = 0) then

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                                       'entering',
                                       'no rate found logic', p_log_level_rec => p_log_level_rec);
                   end if;

                   l_inv_rate_rec.set_of_books_id := l_sob_tbl(l_sob_index);

                   -- note: the following is only used for non-AP and non-PA lines
                   l_exchange_date                := p_asset_fin_rec_adj.date_placed_in_service; -- inv date?
                   l_exchange_date                := px_trans_rec.transaction_date_entered;

                   if not FA_MC_UTIL_PVT.get_invoice_rate
                           (p_inv_rec                    => l_inv_rec,
                            p_book_type_code             => px_asset_hdr_rec.book_type_code,
                            p_set_of_books_id            => l_sob_tbl(l_sob_index),
                            px_exchange_date             => l_exchange_date,
                            px_inv_rate_rec              => l_inv_rate_rec,
                            p_log_level_rec              => p_log_level_rec) then
                      raise error_found;
                   end if;

                end if; -- l_mrc_rate_found_count


                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,
                                    'after',
                                    'rate found logic', p_log_level_rec => p_log_level_rec);
                end if;

                -- use the rate located and multiply by the primary amounts
                -- in order to get the reporting value - taking precision into account.
                -- since the values in l_rec were already changed to the values to
                -- be inserted, we must revert to using the values in array
                --
                -- for invoice deletes and reinstates use the values already in
                -- record as they are the true deltas in terms of the adjustment
                -- for deletes, we need to flip the sign here

                -- R12 / SLA - we will no longer be using the rate, but the amount
                -- directly in the same structure.  logi will be to use that for
                -- fa cost and then compare the remaining values and either
                -- use that same amount or the exchange rate if different
                --
                -- however in case where amount is not provided, we will still
                -- use the old method

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,
                                    'checking',
                                    'l_inv_rate_rec.cost',
                                    p_log_level_rec);
                end if;

                -- the following code mirrors that for primary
                -- but we only need to worry about the amounts for alc
                -- validation has already been done and rest of inv_rec values
                -- can equal the primary values

                if (px_inv_trans_rec.transaction_type <> 'MASS ADDITION' and
                    px_inv_trans_rec.transaction_type <> 'INVOICE ADDITION' and
                    px_inv_tbl(l_row_count + 1).source_line_id is not null) then

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                                    'in lgoic for existing line',
                                    '',
                                    p_log_level_rec);
                   end if;


                   select fixed_assets_cost,
                          payables_cost
                     into l_current_fa_cost,
                          l_current_pa_cost
                     from fa_mc_asset_invoices
                    where source_line_id = l_current_source_line_id
                      and set_of_books_id = l_sob_tbl(l_sob_index);


                   if (px_inv_trans_rec.transaction_type = 'INVOICE DELETE') then
                      l_inv_rec.Fixed_Assets_Cost := -l_current_fa_cost;
                      l_inv_rec.Payables_Cost     := -l_current_pa_cost;
                      if (p_asset_type_rec.asset_type = 'CIP') then
                         if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                            l_inv_rec.Cip_Cost          := -l_current_fa_cost;
                         else
                            l_inv_rec.Cip_Cost          := 0;
                         end if;
                      end if;
                   elsif (px_inv_trans_rec.transaction_type =  'INVOICE REINSTATE') then
                      l_inv_rec.Fixed_Assets_Cost := l_current_fa_cost;
                      l_inv_rec.Payables_Cost     := l_current_pa_cost;
                      if (p_asset_type_rec.asset_type = 'CIP') then
                         if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y') then
                            l_inv_rec.Cip_Cost          := l_current_fa_cost;
                         else
                            l_inv_rec.Cip_Cost          := 0;
                         end if;
                      end if;
                   elsif (px_inv_trans_rec.transaction_type = 'INVOICE DEP') then
                      l_inv_rec.Cip_Cost          := -l_current_fa_cost;
                      l_inv_rec.Fixed_Assets_Cost := 0;
                      l_inv_rec.Payables_Cost     := 0;
                   elsif (px_inv_trans_rec.transaction_type = 'INVOICE NO DEP') then
                      l_inv_rec.Cip_Cost          := l_current_fa_cost;
                      l_inv_rec.Fixed_Assets_Cost := 0;
                      l_inv_rec.Payables_Cost     := 0;
                   else
                      -- on existing lines, we currently do not allow
                      -- a different exchange rate to be used that the original
                      -- thus we can ignore the amount and go directly to the rate logic

                      -- use the rate located and multiply by the primary amounts
                      -- in order to get the reporting value - taking precision into account.
                      -- since the values in l_rec were already changed to the values to
                      -- be inserted, we must revert to using the values in array
                      --
                      -- for invoice deletes and reinstates use the values already in
                      -- record as they are the true deltas in terms of the adjustment
                      -- for deletes, we need to flip the sign here

                      l_inv_rec.fixed_assets_cost := nvl(px_inv_tbl(l_row_count + 1).fixed_assets_cost, 0) *
                                                        l_inv_rate_rec.exchange_rate;

                      -- bug 2258936 we do not want to set these values to 0, but leave null
                      l_inv_rec.payables_cost     := px_inv_tbl(l_row_count + 1).payables_cost *
                                                        l_inv_rate_rec.exchange_rate;
                      l_inv_rec.unrevalued_cost   := px_inv_tbl(l_row_count + 1).unrevalued_cost *
                                                        l_inv_rate_rec.exchange_rate;

                      -- adding for new group requirements
                      l_inv_rec.cip_cost          := px_inv_tbl(l_row_count + 1).cip_cost *
                                                        l_inv_rate_rec.exchange_rate;

/*                    l_inv_rec.salvage_value     := nvl(px_inv_tbl(l_row_count
 *                    + 1).salvage_value, 0)     *
 *                                                                            l_inv_rate_rec.exchange_rate;
 *                                                                            */


                   end if;  -- invoice transaction type

/*   may not be needed
 *              elsif () then
 *                 -- special ALC for treatment for destinat8ion side of invoice transfers
 *                 -- still need to insure we use the correct exchange rate here
 *
 */

                else -- new line scenario (add/massadd)

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add(l_calling_fn,
                                    'in logic for new line',
                                    '',
                                    p_log_level_rec);
                   end if;


                   if (l_mrc_rate_found_count = 1 and
                       px_inv_tbl(l_row_count + 1).inv_rate_tbl(l_mrc_rate_index).cost is not null) then

                      -- now set the rate for subsequent use
                      -- accounting for possibility that primary is 0/null

                      if (px_inv_tbl(l_row_count + 1).fixed_assets_cost is not null and
                          px_inv_tbl(l_row_count + 1).fixed_assets_cost <> 0) then
                         l_inv_rate_rec.exchange_rate := l_inv_rate_rec.cost /
                                                            px_inv_tbl(l_row_count + 1).fixed_assets_cost;
                         l_inv_rec.fixed_assets_cost := px_inv_tbl(l_row_count + 1).inv_rate_tbl(l_mrc_rate_index).cost;
                      else
                         l_inv_rate_rec.exchange_rate := nvl(l_inv_rate_rec.exchange_rate, 0);
                      end if;

                   else  -- old rate based method

                      if (p_log_level_rec.statement_level) then
                         fa_debug_pkg.add(l_calling_fn,
                                          'entering',
                                          'null ALC amount logic for cost',
                                          p_log_level_rec);
                      end if;

                      l_inv_rec.fixed_assets_cost := nvl(px_inv_tbl(l_row_count + 1).fixed_assets_cost, 0) *
                                                        l_inv_rate_rec.exchange_rate;
                   end if;

                   -- BUG# 2314466
                   -- do not use nvl here as we want to insert null intentionally
                   -- and the null value is needed to correctly derive original cost later
                   if (px_inv_tbl(l_row_count + 1).payables_cost = px_inv_tbl(l_row_count + 1).fixed_assets_cost) then
                      l_inv_rec.payables_cost     := l_inv_rec.fixed_assets_cost;
                   else
                      -- bug 2258936 we do not want to set these values to 0, but leave null
                      l_inv_rec.payables_cost     := px_inv_tbl(l_row_count + 1).payables_cost *
                                                        l_inv_rate_rec.exchange_rate;
                   end if;

                   if (px_inv_tbl(l_row_count + 1).unrevalued_cost = px_inv_tbl(l_row_count + 1).fixed_assets_cost) then
                      l_inv_rec.unrevalued_cost   := l_inv_rec.fixed_assets_cost;
                   else
                      l_inv_rec.unrevalued_cost   := px_inv_tbl(l_row_count + 1).unrevalued_cost *
                                                     l_inv_rate_rec.exchange_rate;
                   end if;

/*                 l_inv_rec.salvage_value     := nvl(px_inv_tbl(l_row_count +
 *                 1).salvage_value, 0)     *
 *                                                                      l_inv_rate_rec.exchange_rate;
 */


                   if (p_asset_type_rec.asset_type = 'CIP') then
                      if (nvl(l_inv_rec.depreciate_in_group_flag, 'N') = 'Y')
then
                         l_inv_rec.Cip_Cost       := 0;
                      else
                         l_inv_rec.Cip_Cost       := l_inv_rec.fixed_assets_cost;
                      end if;
                   end if;

                   if (px_asset_hdr_rec.period_of_addition = 'Y' and
                       px_inv_trans_rec.transaction_type in ('MASS ADDITION',
'INVOICE ADDITION') and
                       p_asset_type_rec.asset_type = 'CAPITALIZED') then

                      l_inv_rec.ytd_deprn                := nvl(px_inv_tbl(l_row_count + 1).ytd_deprn, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.deprn_reserve            := nvl(px_inv_tbl(l_row_count + 1).deprn_reserve, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.bonus_ytd_deprn          := nvl(px_inv_tbl(l_row_count + 1).bonus_ytd_deprn, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.bonus_deprn_reserve      := nvl(px_inv_tbl(l_row_count + 1).bonus_deprn_reserve, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.reval_ytd_deprn          := nvl(px_inv_tbl(l_row_count + 1).reval_ytd_deprn, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.reval_deprn_reserve      := nvl(px_inv_tbl(l_row_count + 1).reval_deprn_reserve, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                      l_inv_rec.reval_amortization_basis := nvl(px_inv_tbl(l_row_count + 1).reval_amortization_basis, 0) *
                                                               l_inv_rate_rec.exchange_rate;
                   end if;

                end if; -- end existing / new line logic

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,
                                    'calculated delta ALC cost',
                                    l_inv_rec.fixed_assets_cost,
                                    p_log_level_rec);
                end if;



                -- retrieve the mrc fin struct row from the table of structs
                -- note that the order should match the sob_id cursor since
                -- that was used to populate the above.  This will also be
                -- used for deprn table

                l_mrc_fin_book_rec := 0;
                for i in 1..x_asset_fin_mrc_tbl_new.count loop

                   if ((x_asset_fin_mrc_tbl_new(i).set_of_books_id = l_sob_tbl(l_sob_index))) then
                          l_mrc_fin_book_rec := i;
                   end if;

                end loop;

                if (l_mrc_fin_book_rec = 0) then
                    fa_srvr_msg.add_message(
                       calling_fn => l_calling_fn,
                       name       => '***FAILED LOOKUP FININFO***',
                       p_log_level_rec => p_log_level_rec);
                    raise error_found;
                end if;

                --  call calc_inv for amounts
                if not inv_calc_info
                        (p_asset_hdr_rec         => px_asset_hdr_rec,
                         p_asset_type_rec        => p_asset_type_rec,
                         p_inv_trans_rec         => px_inv_trans_rec,
                         px_inv_rec              => l_inv_rec,
                         px_asset_fin_rec_new    => x_asset_fin_mrc_tbl_new(l_mrc_fin_book_rec),
                         px_asset_deprn_rec_new  => x_asset_deprn_mrc_tbl_new(l_mrc_fin_book_rec),
                         p_log_level_rec         => p_log_level_rec
                        ) then
                   raise error_found;
                end if;

                -- BUG# 2622722
                -- do this for all lines for addition and transfer transactions,
                -- not just those from mass additions. note that non-xfr adjustment
                -- will use the flexbuilt ccids for now. section has been moved up so
                -- tht the deltas are used, not the final amounts

                if ((px_inv_trans_rec.transaction_type = 'MASS ADDITION' or
                     px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' or
                     px_inv_trans_rec.transaction_type = 'INVOICE ADDITION') and
                    l_inv_rec.payables_cost <> 0 and
                    (G_release <> 11 or
                     l_inv_rec.payables_code_combination_id is not null)) then
                   l_payables_cost_mrc_count := l_payables_cost_mrc_tbl.count + 1;
                   l_payables_cost_mrc_tbl(l_payables_cost_mrc_count).set_of_books_id :=
                        l_sob_tbl(l_sob_index);
                   l_payables_cost_mrc_tbl(l_payables_cost_mrc_count).payables_cost :=
                        l_inv_rec.payables_cost;
                   l_payables_cost_mrc_tbl(l_payables_cost_mrc_count).payables_code_combination_id :=
                        l_inv_rec.payables_code_combination_id;
                   l_payables_cost_mrc_tbl(l_payables_cost_mrc_count).source_dest_code :=
                        l_inv_rec.source_dest_code;
                   l_payables_cost_mrc_tbl(l_payables_cost_mrc_count).source_line_id :=
                        l_inv_rec.source_line_id;

                end if;


                -- now for invoice transfers and adjustments, get the current values of the invoice
                -- that was just terminated and then add the delta.  This will be the resulting cost
                -- of the new line.  For invoice transfers, if full cost was transfered, we will
                -- be entering this logic for the source asset.  Delta is the net effect, neg or pos.
                -- SRC line ret should have same behavior with inv transfer.
                --
                -- for source line deletes and reinstatements, no need to rederive this
                -- as the value set above using the rate is fine however we do need to
                -- flip the sign back for deletes

                if (px_inv_trans_rec.transaction_type = 'INVOICE ADJUSTMENT' or
                    (px_inv_trans_rec.transaction_type in ('INVOICE TRANSFER',
                                                           'RETIREMENT',
                                                           'REINSTATEMENT') and
                     l_current_source_line_id is not null)) then

                   -- special case - for invoice transfer (source)
                   -- load the delta amount back into the rate array
                   -- which will be used by the destination asset
                   if (px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER') then
                       px_inv_tbl(l_row_count + 1).inv_rate_tbl(l_mrc_rate_index).cost := -l_inv_rec.fixed_assets_cost;
                   end if;

                   l_inv_rec.fixed_assets_cost := l_current_fa_cost + l_inv_rec.fixed_assets_cost;
                   l_inv_rec.payables_cost     := l_current_pa_cost + l_inv_rec.payables_cost;

                end if;


                if (l_create_new_row = 'YES') then

                   if not process_invoice
                      (px_trans_rec            => px_trans_rec,
                       px_asset_hdr_rec        => l_asset_hdr_rec,
                       p_inv_trans_rec         => px_inv_trans_rec,
                       px_inv_rec              => l_inv_rec,       -- current row reporting
                       p_inv_rate_rec          => l_inv_rate_rec,
                       p_mrc_sob_type_code     => 'R',
                       p_log_level_rec         => p_log_level_rec
                      ) then raise error_found;
                   end if;
                end if;


                -- store the total payables cost cleared per book


             end loop; -- end mrc sob loop

             -- call the cache to reset the sob_id for the primary book
             if NOT fa_cache_pkg.fazcbcs(X_book => px_asset_hdr_rec.book_type_code,
                                         X_set_of_books_id => px_asset_hdr_rec.set_of_books_id,
                                         p_log_level_rec => p_log_level_rec) then
                raise error_found;
             end if;

          end if; -- end mrc enabled book

       end if;  -- end create new row is yes

       l_row_count := l_row_count + 1;

   end loop; -- end invoice loop

   -- call the post clearing code to clear all payables cost
   -- R12 conditional handling
   if ((px_inv_trans_rec.transaction_type = 'MASS ADDITION' or
        px_inv_trans_rec.transaction_type = 'INVOICE TRANSFER' or
        px_inv_trans_rec.transaction_type = 'INVOICE ADDITION') and
       ((G_release <> 11 and
         p_calling_fn <> 'fa_addition_pub.do_addition') or
        px_asset_hdr_rec.period_of_addition <> 'Y')) then
      if not post_clearing
             (p_trans_rec                => px_trans_rec,
              p_asset_hdr_rec            => px_asset_hdr_rec,
              p_asset_desc_rec           => p_asset_desc_rec,
              p_asset_type_rec           => p_asset_type_rec,
              p_asset_cat_rec            => p_asset_cat_rec,
              p_inv_trans_rec            => px_inv_trans_rec,
              p_payables_cost_tbl        => l_payables_cost_tbl,
              p_payables_cost_mrc_tbl    => l_payables_cost_mrc_tbl,
              p_log_level_rec            => p_log_level_rec
            ) then raise error_found;
      end if;
   end if;

   -- BUG# 2632955
   -- call the cache to reset the sob_id for the primary book
   if NOT fa_cache_pkg.fazcbcs(X_book => px_asset_hdr_rec.book_type_code,
                               X_set_of_books_id => px_asset_hdr_rec.set_of_books_id,
                               p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   return true;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_invoice_pvt.inv_engine',  p_log_level_rec => p_log_level_rec);

      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.inv_engine',  p_log_level_rec => p_log_level_rec);

      return false;

END invoice_engine;

------------------------------------------------------------------------------------------

FUNCTION inv_calc_info
               (p_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
                p_asset_type_rec         IN     FA_API_TYPES.asset_type_rec_type,
                p_inv_trans_rec          IN     FA_API_TYPES.inv_trans_rec_type,
                px_inv_rec               IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
                px_asset_fin_rec_new     IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
                px_asset_deprn_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type
               , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   error_found   exception;

BEGIN

   -- Bug:5907174
   if not FA_UTILS_PKG.faxrnd(px_inv_rec.fixed_assets_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;

   -- populate / increment the fin_rec using the delta

   px_asset_fin_rec_new.cost            := nvl(px_asset_fin_rec_new.cost, 0) +
                                                 nvl(px_inv_rec.fixed_assets_cost, 0);
   px_asset_fin_rec_new.unrevalued_cost := nvl(px_asset_fin_rec_new.unrevalued_cost, 0) +
                                                 nvl(px_inv_rec.unrevalued_cost,
                                                     nvl(px_inv_rec.fixed_assets_cost, 0));
   px_asset_fin_rec_new.cip_cost        := nvl(px_asset_fin_rec_new.cip_cost, 0) +
                                                 nvl(px_inv_rec.cip_cost,0);


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add('fa_inv_pvt.inv_calc_info',
                       'px_asset_fin_rec_new.cost',
                       px_asset_fin_rec_new.cost,  p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add('fa_inv_pvt.inv_calc_info',
                       'px_asset_fin_rec_new.cip_cost',
                       px_asset_fin_rec_new.cip_cost,  p_log_level_rec => p_log_level_rec);
   end if;


/*     px_asset_fin_rec_new.salvage_value   := nvl(px_asset_fin_rec_new.salvage_value, 0) +
                                                     nvl(px_inv_rec.salvage_value, 0);
*/

   if (p_asset_hdr_rec.period_of_addition = 'Y') then
       -- Bug:5907174
       if not FA_UTILS_PKG.faxrnd(px_inv_rec.payables_cost,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       px_asset_fin_rec_new.original_cost   := nvl(px_asset_fin_rec_new.original_cost,0) +
                                                     nvl(px_inv_rec.payables_cost,
                                                         nvl(px_inv_rec.fixed_assets_cost, 0));
   end if;


   if not FA_UTILS_PKG.faxrnd(px_inv_rec.fixed_assets_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_inv_rec.payables_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;

   if not FA_UTILS_PKG.faxrnd(px_inv_rec.cip_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;

/*
   if not FA_UTILS_PKG.faxrnd(px_inv_rec.payables_cost,
                              p_asset_hdr_rec.book_type_code,
                              p_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
          raise error_found;
   end if;
*/

   if (p_asset_hdr_rec.period_of_addition = 'Y' and
       p_inv_trans_rec.transaction_type in ('MASS ADDITION', 'INVOICE ADDITION') and
       p_asset_type_rec.asset_type = 'CAPITALIZED') then

       px_asset_deprn_rec_new.ytd_deprn            := nvl(px_asset_deprn_rec_new.ytd_deprn, 0) +
                                                        nvl(px_inv_rec.ytd_deprn, 0);
       px_asset_deprn_rec_new.deprn_reserve        := nvl(px_asset_deprn_rec_new.deprn_reserve, 0) +
                                                        nvl(px_inv_rec.deprn_reserve, 0);
       px_asset_deprn_rec_new.bonus_ytd_deprn      := nvl(px_asset_deprn_rec_new.bonus_ytd_deprn, 0) +
                                                        nvl(px_inv_rec.bonus_ytd_deprn, 0);
       px_asset_deprn_rec_new.bonus_deprn_reserve  := nvl(px_asset_deprn_rec_new.bonus_deprn_reserve, 0) +
                                                        nvl(px_inv_rec.bonus_deprn_reserve, 0);
       px_asset_deprn_rec_new.reval_ytd_deprn      := nvl(px_asset_deprn_rec_new.reval_ytd_deprn, 0) +
                                                        nvl(px_inv_rec.reval_ytd_deprn, 0);
       px_asset_deprn_rec_new.reval_deprn_reserve  := nvl(px_asset_deprn_rec_new.reval_deprn_reserve, 0) +
                                                        nvl(px_inv_rec.reval_deprn_reserve, 0);
       px_asset_deprn_rec_new.reval_amortization_basis := nvl(px_asset_deprn_rec_new.reval_amortization_basis, 0) +
                                                            nvl(px_inv_rec.reval_amortization_basis, 0);

       -- Bug 4243541 : Load to fin_rec and round the reval_amort_bais .
       px_asset_fin_rec_new.reval_amortization_basis :=  px_asset_deprn_rec_new.reval_amortization_basis;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.ytd_deprn,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.deprn_reserve       ,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.bonus_ytd_deprn     ,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.bonus_deprn_reserve ,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.reval_ytd_deprn     ,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.reval_deprn_reserve ,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

       if not FA_UTILS_PKG.faxrnd(px_inv_rec.reval_amortization_basis,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

   -- MVK
       if not FA_UTILS_PKG.faxrnd(px_asset_fin_rec_new.reval_amortization_basis,
                                  p_asset_hdr_rec.book_type_code,
                                  p_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
              raise error_found;
       end if;

   end if;

   return true;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.inv_calc_info',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.inv_calc_info',  p_log_level_rec => p_log_level_rec);
      return false;

END inv_calc_info;

------------------------------------------------------------------------------------------

FUNCTION  process_invoice
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    px_inv_rec                 IN OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_inv_rate_rec             IN     FA_API_TYPES.inv_rate_rec_type,
    p_mrc_sob_type_code        IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

 l_rowid                       varchar2(30);
 l_reporting_flag              varchar2(1);
 error_found                   EXCEPTION;
 /*
  * Following two variables are created for creating 0 cost source line
  * which may happned in source line retirement
  */
 l_date_ineffective            date   := null;
 l_invoice_transaction_id_out  number := null;

BEGIN

   /*
    * In case of  full source line retirement, new line with 0 amount
    * still needs to be created, but it needs to have DATE_INEFFECTIVE and
    * INVOICE_TRANSACTION_ID_OUT populated to not to display on source line window.
    */
   if (p_inv_trans_rec.transaction_type = 'RETIREMENT' and
       px_inv_rec.fixed_assets_cost = 0) then

      l_date_ineffective             := px_trans_rec.who_info.last_update_date;
      l_invoice_transaction_id_out := p_inv_trans_rec.invoice_transaction_id;

   end if;

   FA_ASSET_INVOICES_PKG.Insert_Row
                      (X_Rowid                          => l_rowid,
                       X_Asset_Id                       => px_asset_hdr_rec.asset_id,
                       X_Po_Vendor_Id                   => px_inv_rec.po_vendor_id,
                       X_Asset_Invoice_Id               => px_inv_rec.asset_invoice_id,    -- mass_add_id
                       X_Fixed_Assets_Cost              => px_inv_rec.fixed_assets_cost,
                       X_Date_Effective                 => px_trans_rec.who_info.last_update_date,
                       X_Date_Ineffective               => l_date_ineffective,
                       X_Invoice_Transaction_Id_In      => p_inv_trans_rec.invoice_transaction_id,
                       X_Invoice_Transaction_Id_Out     => l_invoice_transaction_id_out,
                       X_Deleted_Flag                   => px_inv_rec.deleted_flag,
                       X_Po_Number                      => px_inv_rec.po_number,
                       X_Invoice_Number                 => px_inv_rec.invoice_number,
                       X_Payables_Batch_Name            => px_inv_rec.payables_batch_name,
                       X_Payables_Code_Combination_Id   => px_inv_rec.payables_code_combination_id,
                       X_Feeder_System_Name             => px_inv_rec.feeder_system_name,
                       X_Create_Batch_Date              => px_inv_rec.create_batch_date,
                       X_Create_Batch_Id                => px_inv_rec.create_batch_id,
                       X_Invoice_Date                   => px_inv_rec.invoice_date,
                       X_Payables_Cost                  => px_inv_rec.payables_cost,
                       X_Post_Batch_Id                  => px_inv_rec.post_batch_id,
                       X_Invoice_Id                     => px_inv_rec.invoice_id,
                       X_Ap_Distribution_Line_Number    => px_inv_rec.ap_distribution_line_number,
                       X_Payables_Units                 => px_inv_rec.payables_units,
                       X_Split_Merged_Code              => px_inv_rec.split_merged_code,
                       X_Description                    => px_inv_rec.description,
                       X_Parent_Mass_Addition_Id        => px_inv_rec.parent_mass_addition_id,
                       X_Last_Update_Date               => px_trans_rec.who_info.last_update_date,
                       X_Last_Updated_By                => px_trans_rec.who_info.last_updated_by,
                       X_Created_By                     => px_trans_rec.who_info.created_by,
                       X_Creation_Date                  => px_trans_rec.who_info.creation_date,
                       X_Last_Update_Login              => px_trans_rec.who_info.last_update_login,
                       X_Attribute1                     => px_inv_rec.ATTRIBUTE1,
                       X_Attribute2                     => px_inv_rec.ATTRIBUTE2,
                       X_Attribute3                     => px_inv_rec.ATTRIBUTE3,
                       X_Attribute4                     => px_inv_rec.ATTRIBUTE4,
                       X_Attribute5                     => px_inv_rec.ATTRIBUTE5,
                       X_Attribute6                     => px_inv_rec.ATTRIBUTE6,
                       X_Attribute7                     => px_inv_rec.ATTRIBUTE7,
                       X_Attribute8                     => px_inv_rec.ATTRIBUTE8,
                       X_Attribute9                     => px_inv_rec.ATTRIBUTE9,
                       X_Attribute10                    => px_inv_rec.ATTRIBUTE10,
                       X_Attribute11                    => px_inv_rec.ATTRIBUTE11,
                       X_Attribute12                    => px_inv_rec.ATTRIBUTE12,
                       X_Attribute13                    => px_inv_rec.ATTRIBUTE13,
                       X_Attribute14                    => px_inv_rec.ATTRIBUTE14,
                       X_Attribute15                    => px_inv_rec.ATTRIBUTE15,
                       X_Attribute_Category_Code        => px_inv_rec.ATTRIBUTE_CATEGORY_CODE,
                       X_Unrevalued_Cost                => px_inv_rec.unrevalued_cost,
                       X_Merged_Code                    => px_inv_rec.merged_code,
                       X_Split_Code                     => px_inv_rec.split_code,
                       X_Merge_Parent_Mass_Add_Id       => px_inv_rec.merge_parent_mass_additions_id,
                       X_Split_Parent_Mass_Add_Id       => px_inv_rec.split_parent_mass_additions_id,
                       X_Project_Asset_Line_Id          => px_inv_rec.project_asset_line_id,
                       X_Project_Id                     => px_inv_rec.project_id,
                       X_Task_Id                        => px_inv_rec.task_id,
                       X_Material_Indicator_Flag        => px_inv_rec.material_indicator_flag,
                       X_source_line_id                 => px_inv_rec.source_line_id,
                       X_prior_source_line_id           => px_inv_rec.prior_source_line_id,
                       X_depreciate_in_group_flag       => px_inv_rec.depreciate_in_group_flag,
                       -- added for R12
                       X_invoice_distribution_id        => px_inv_rec.invoice_distribution_id,
                       X_invoice_line_number            => px_inv_rec.invoice_line_number,
                       X_po_distribution_id             => px_inv_rec.po_distribution_id,
                       X_exchange_rate                  => p_inv_rate_rec.exchange_rate,
                       X_mrc_sob_type_code              => p_mrc_sob_type_code,
                       X_set_of_books_id                => px_asset_hdr_rec.set_of_books_id,
                       X_Calling_Fn                     => 'fa_invoice_api_pkg.process_invoice'
                      , p_log_level_rec => p_log_level_rec);

   return true;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_invoice_pvt.process_invoice',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.process_invoice',  p_log_level_rec => p_log_level_rec);
      return false;

END process_invoice;

--------------------------------------------------------------------------------

FUNCTION  get_inv_rate
   (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   i               number := 0;
   l_inv_rate_ctr  number := 0;

   cursor c_mc_invoices (p_source_line_id in number) is
   select mcai.set_of_books_id,
          mcai.exchange_rate,
          mcai.fixed_assets_cost
     from fa_mc_asset_invoices mcai,
          fa_mc_book_controls  mcbk
    where mcai.source_line_id  = p_source_line_id
      and mcai.set_of_books_id = mcbk.set_of_books_id
      and mcbk.book_type_code  = p_asset_hdr_rec.book_type_code
      and mcbk.enabled_flag    = 'Y';

   l_calling_fn              varchar2(35) := 'fa_inv_pvt.get_inv_rate';

   error_found     EXCEPTION;

BEGIN

   for i in 1..px_inv_tbl.count loop

      -- reset the starting value to one in each invoice
      l_inv_rate_ctr := 0;

      -- only populate for existing source lines

      if (px_inv_tbl(i).source_line_id is not null) then

          if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add('fa_inv_pvt.get_inv_rate',
                               'source_line_id',
                               px_inv_tbl(i).source_line_id);
          end if;

          for c_rec in c_mc_invoices(px_inv_tbl(i).source_line_id) loop

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add('fa_inv_pvt.get_inv_rate',
                                 'set_of_books_id',
                                 c_rec.set_of_books_id,  p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('fa_inv_pvt.get_inv_rate',
                                 'exchange_rate',
                                 c_rec.exchange_rate,  p_log_level_rec => p_log_level_rec);
             end if;

             l_inv_rate_ctr := l_inv_rate_ctr  + 1;
             px_inv_tbl(i).inv_rate_tbl(l_inv_rate_ctr).set_of_books_id  := c_rec.set_of_books_id;
             px_inv_tbl(i).inv_rate_tbl(l_inv_rate_ctr).exchange_rate    := c_rec.exchange_rate;
             px_inv_tbl(i).inv_rate_tbl(l_inv_rate_ctr).cost             := c_rec.fixed_assets_cost;


          end loop;
      end if;
   end loop;
   return true;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_invoice_pvt.get_inv_rate',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.get_inv_rate',  p_log_level_rec => p_log_level_rec);
      return false;

END get_inv_rate;

--------------------------------------------------------------------------------

FUNCTION post_clearing
   (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_inv_trans_rec            IN     FA_API_TYPES.inv_trans_rec_type,
    p_payables_cost_tbl        IN     payables_cost_tbl_type,
    p_payables_cost_mrc_tbl    IN     payables_cost_tbl_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   i                  number;
   l_adj              fa_adjust_type_pkg.fa_adj_row_struct;
   sob_processed_tbl  num_tbl;
   l_sob_tbl          FA_CACHE_PKG.fazcrsob_sob_tbl_type;
   l_sob_index        number;

   l_calling_fn              varchar2(35) := 'fa_inv_pvt.post_clearing';

   error_found        exception;

BEGIN

   l_adj.transaction_header_id    := p_trans_rec.transaction_header_id;
   l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
   l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created   := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.period_counter_adjusted  := fa_cache_pkg.fazcbc_record.last_period_counter + 1;
   l_adj.current_units            := p_asset_desc_rec.current_units ;
   l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_thid           := 0;
   l_adj.selection_retid          := 0;
   l_adj.leveling_flag            := TRUE;
   l_adj.last_update_date         := p_trans_rec.who_info.last_update_date;

   l_adj.flush_adj_flag           := FALSE;
   l_adj.gen_ccid_flag            := FALSE;
   l_adj.annualized_adjustment    := 0;
   l_adj.distribution_id          := 0;

   l_adj.adjustment_type          := 'COST CLEARING';
   l_adj.source_type_code         := p_trans_rec.transaction_type_code;

   if l_adj.source_type_code = 'CIP ADJUSTMENT' then
      l_adj.account_type     := 'CIP_CLEARING_ACCT';
   else
      l_adj.account_type     := 'ASSET_CLEARING_ACCT';
   end if;

   -- post the primary rows
   for i in 1..p_payables_cost_tbl.count loop

      -- SLA changes
      l_adj.asset_invoice_id    := p_payables_cost_tbl(i).asset_invoice_id;
      l_adj.source_line_id      := p_payables_cost_tbl(i).source_line_id;
      l_adj.source_dest_code    := p_payables_cost_tbl(i).source_dest_code;

      -- the nvl was added for R12 handling...
      l_adj.code_combination_id := nvl(p_payables_cost_tbl(i).payables_code_combination_id, 0);
      -- l_adj.asset_invoice_id    := 0;  -- could pass this in tbl

      if p_payables_cost_tbl(i).payables_cost > 0 then
         l_adj.debit_credit_flag   := 'CR';
         l_adj.adjustment_amount   := p_payables_cost_tbl(i).payables_cost ;
      else
         l_adj.debit_credit_flag   := 'DR';
         l_adj.adjustment_amount   := -p_payables_cost_tbl(i).payables_cost ;
      end if;

      l_adj.mrc_sob_type_code := 'P';
      l_adj.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

      if not FA_INS_ADJUST_PKG.faxinaj
               (l_adj,
                p_trans_rec.who_info.last_update_date,
                p_trans_rec.who_info.last_updated_by,
                p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;
   end loop;

   -- flush them
   l_adj.transaction_header_id := 0;
   l_adj.flush_adj_flag        := TRUE;
   l_adj.leveling_flag         := TRUE;

   if not FA_INS_ADJUST_PKG.faxinaj
            (l_adj,
             p_trans_rec.who_info.last_update_date,
             p_trans_rec.who_info.last_updated_by,
             p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   -- need to reset this after each flush
   l_adj.transaction_header_id  := p_trans_rec.transaction_header_id;


   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
            (x_book_type_code => p_asset_hdr_rec.book_type_code,
             x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise error_found;
   end if;

   -- post reporting rows one reporting book at a time
   FOR l_sob_index in 1..l_sob_tbl.count LOOP

      for i in 1..p_payables_cost_mrc_tbl.count loop

         if (p_payables_cost_mrc_tbl(i).set_of_books_id = l_sob_tbl(l_sob_index)) then

            -- SLA changes
            l_adj.asset_invoice_id    := p_payables_cost_mrc_tbl(i).asset_invoice_id;
            l_adj.source_line_id      := p_payables_cost_mrc_tbl(i).source_line_id;
            l_adj.source_dest_code    := p_payables_cost_mrc_tbl(i).source_dest_code;

            -- nvl added for R12
            l_adj.code_combination_id := nvl(p_payables_cost_mrc_tbl(i).payables_code_combination_id, 0);

            -- l_adj.asset_invoice_id    := 0;  -- could pass this in tbl

            if p_payables_cost_mrc_tbl(i).payables_cost > 0 then
               l_adj.debit_credit_flag   := 'CR';
               l_adj.adjustment_amount   := p_payables_cost_mrc_tbl(i).payables_cost ;
            else
               l_adj.debit_credit_flag   := 'DR';
               l_adj.adjustment_amount   := -p_payables_cost_mrc_tbl(i).payables_cost ;
            end if;

            l_adj.mrc_sob_type_code := 'R';
            l_adj.set_of_books_id   := l_sob_tbl(l_sob_index);

            if not FA_INS_ADJUST_PKG.faxinaj
                     (l_adj,
                      p_trans_rec.who_info.last_update_date,
                      p_trans_rec.who_info.last_updated_by,
                      p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
               raise error_found;
            end if;

         end if;

      end loop; -- invoices

      -- flush them
      l_adj.transaction_header_id := 0;
      l_adj.flush_adj_flag        := TRUE;
      l_adj.leveling_flag         := TRUE;

      if not FA_INS_ADJUST_PKG.faxinaj
               (l_adj,
                p_trans_rec.who_info.last_update_date,
                p_trans_rec.who_info.last_updated_by,
                p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
         raise error_found;
      end if;

      -- need to reset this after each flush
      l_adj.transaction_header_id    := p_trans_rec.transaction_header_id;

   end loop; -- mrc

   return true;

EXCEPTION
   when error_found then
      fa_srvr_msg.add_message(calling_fn => 'fa_invoice_pvt.post_clearing',  p_log_level_rec => p_log_level_rec);
      return false;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_invoice_pvt.post_clearing',  p_log_level_rec => p_log_level_rec);
      return false;

END;


END FA_INVOICE_PVT;

/
