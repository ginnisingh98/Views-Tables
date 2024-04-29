--------------------------------------------------------
--  DDL for Package Body FA_RETIREMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETIREMENT_PUB" as
/* $Header: FAPRETB.pls 120.78.12010000.27 2010/05/25 02:36:57 anujain ship $   */

-- API info
G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_RETIREMENT_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Retirement API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

g_release                  number  := fa_cache_pkg.fazarel_release;

-- l_calling_fn    VARCHAR2(100) := 'FA_RETIREMENT_PUB';

g_retirement         VARCHAR2(30) := 'RETIREMENT';
g_reinstatement      VARCHAR2(30) := 'REINSTATEMENT';
g_undo_retirement    VARCHAR2(30) := 'UNDO RETIREMENT';
g_undo_reinstatement VARCHAR2(30) := 'UNDO REINSTATEMENT';

-- global variables used to go back to original env.
g_orig_set_of_books_id   number;
g_orig_currency_context  varchar2(64);

g_primary_set_of_books_id number; /* BUG#2919562 */

-- error message
g_msg_name               varchar2(80) := null;
g_token1                 varchar2(80) := null;
g_token2                 varchar2(80) := null;
g_value1                 varchar2(80) := null;
g_value2                 varchar2(80) := null;

/*
 * Added for Group Asset uptake
 * g_inv_trans_rec to pass FA_API_TYPES.inv_trans_rec
 * when calling FA_GROUP_RETIREMENT_PVT.DO_RETIREMENT
 * This is necessary without passing this value from
 * Do_Retirement to do_sub_regular_retirement
 */
g_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
/*** End uptake ***/

FUNCTION do_all_books_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_sub_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_sub_regular_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION calculate_gain_loss
        (p_retirement_id              in     number
        ,p_mrc_sob_type_code          in     varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_all_books_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_sub_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_rate                       in     number
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_sub_regular_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION undo_all_books_retirement
        (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type -- bug 8630242
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION undo_sub_retirement
   (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
   ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_mrc_sob_type_code          in     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION undo_all_books_reinstatement
   (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
   ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type -- bug 8643362
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION undo_sub_reinstatement
   (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
   ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_mrc_sob_type_code          in     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION do_validation
        (p_validation_type            in     varchar2
        ,p_trans_rec                  in     FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,p_asset_retire_rec           in     FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_calling_fn                 in     varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

FUNCTION reinstate_src_line(
                  px_trans_rec             IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                  px_asset_hdr_rec         IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                  px_asset_fin_rec         IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
                  p_asset_desc_rec         IN     FA_API_TYPES.asset_desc_rec_type,
                  p_invoice_transaction_id IN     NUMBER,
                  p_inv_tbl                IN     FA_API_TYPES.inv_tbl_type,
                  p_rowid                  IN     ROWID,
                  p_calling_fn             IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

------------------------------------------------------------------------------
PROCEDURE do_retirement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
   ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
   ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type) IS

   -- local asset info
   l_trans_rec        FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec   FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec   FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec   FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec    FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl   FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl      FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl          FA_API_TYPES.inv_tbl_type;
   l_period_rec       FA_API_TYPES.period_rec_type;

   -- used for loop through tax books
   l_tax_book_tbl     FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index        number;

   -- used for tax books when doing cip-in-tax or autocopy
   lv_trans_rec      FA_API_TYPES.trans_rec_type;
   lv_dist_trans_rec FA_API_TYPES.trans_rec_type;
   lv_asset_hdr_rec  FA_API_TYPES.asset_hdr_rec_type;
   lv_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;

   -- local individual variables
   l_transaction_type           varchar2(30) := null;
   l_reporting_flag             varchar2(1);
   l_retirement_id              number(15);
   l_calculate_gain_loss_flag   varchar2(1);


   /**
   -- used for category defaulting
   l_ret_prorate_convention     FA_CATEGORY_BOOK_DEFAULTS.prorate_convention_code%TYPE;
   l_use_stl_retirements_flag   FA_CATEGORY_BOOK_DEFAULTS.use_stl_retirements_flag%TYPE;
   l_stl_method_code    FA_CATEGORY_BOOK_DEFAULTS.stl_method_code%TYPE;
   l_stl_life_in_months FA_CATEGORY_BOOK_DEFAULTS.stl_life_in_months%TYPE;
   **/

   /*
    * Added for Group Asset uptake
    */
   l_asset_cat_rec           FA_API_TYPES.asset_cat_rec_type;
   l_new_asset_fin_rec       FA_API_TYPES.asset_fin_rec_type;
   l_new_asset_fin_mrc_tbl   FA_API_TYPES.asset_fin_tbl_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
   /*** End of uptake ***/

   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

   l_ins_status                 boolean := FALSE;

   l_calling_fn    VARCHAR2(80) := 'FA_RETIREMENT_PUB.do_retirement';

   --Bug# 6998072  Start
   l_unit_assigned                 number;
   l_cost_retire_last_unit         number;
   l_total_cost_retire             number;
   l_ret_cost                      number :=0;
   dummy_char                      varchar2(100);
   dummy_bool                      boolean;
   dummy_num                       number;
   --Bug# 6998072 end

BEGIN

   SAVEPOINT do_retirement;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;

   -- ****************************************************
   -- **  API compatibility check and initialization
   -- ****************************************************
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => g_log_level_rec); end if;

   -- check version of the API
   -- standard call to check for API call compatibility.

   if not FND_API.compatible_api_call
          (G_API_VERSION
          ,p_api_version
          ,G_API_NAME
          ,G_PKG_NAME) then
                         raise  FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- initialize message list if p_init_msg_list is set to TRUE.
   if (FND_API.to_boolean(p_init_msg_list) ) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- override FA:PRINT_DEBUG profile option.
   -- if (p_debug_flag = 'YES') then
   --   fa_debug_pkg.set_debug_flag;
   -- end if;

   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_dist_trans_rec   := px_dist_trans_rec;
   l_asset_hdr_rec    := px_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;

   lv_asset_retire_rec := px_asset_retire_rec;

   -- ***************************
   -- **  Transaction approval
   -- ***************************
   -- common for all types
   -- bug 1230315... adding FA_TRX_APPROVAL_PKG for all retirement
   -- transactions

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'call trx approval pkg - faxcat', '', p_log_level_rec => g_log_level_rec); end if;
   l_ins_status := FA_TRX_APPROVAL_PKG.faxcat
                   (x_book              => l_asset_hdr_rec.book_type_code
                   ,x_asset_id          => l_asset_hdr_rec.asset_id
                   ,x_trx_type          => 'PARTIAL UNIT RETIREMENT'
                   ,x_trx_date          => l_asset_retire_rec.date_retired
                   ,x_init_message_flag => 'NO', p_log_level_rec => g_log_level_rec);
   if not l_ins_status then
        g_msg_name := 'error msg name-after trx_app';
        raise FND_API.G_EXC_ERROR;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'ret_id1 ', l_retirement_id, p_log_level_rec => g_log_level_rec); end if;
   -- ***********************************
   -- **  Call the cache for book
   -- **  and do initial MRC validation
   -- ***********************************

   if l_asset_hdr_rec.book_type_code is not null then

        -- call the cache for the primary transaction book
        if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- l_book_class               := fa_cache_pkg.fazcbc_record.book_class;
        -- l_set_of_books_id          := fa_cache_pkg.fazcbc_record.set_of_books_id;
        -- l_distribution_source_book := fa_cache_pkg.fazcbc_record.distribution_source_book;
        -- l_mc_source_flag           := fa_cache_pkg.fazcbc_record.mc_source_flag;

        l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

        -- get the book type code P,R or N
        if not fa_cache_pkg.fazcsob
               (x_set_of_books_id   => l_asset_hdr_rec.set_of_books_id
               ,x_mrc_sob_type_code => l_reporting_flag, p_log_level_rec => g_log_level_rec)
               then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- Error out if the program is submitted from the Reporting Responsibility
        -- No transaction permitted directly on reporting books.
        if l_reporting_flag = 'R' then
             FND_MESSAGE.set_name('GL','MRC_OSP_INVALID_BOOK_TYPE');
             FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        --Check if impairment has been posted in current period.
        if not FA_ASSET_VAL_PVT.validate_impairment_exists
             (p_asset_id           => l_asset_hdr_rec.asset_id,
              p_book               => l_asset_hdr_rec.book_type_code,
              p_mrc_sob_type_code  => 'P',
              p_set_of_books_id    => l_asset_hdr_rec.set_of_books_id,
              p_log_level_rec      => g_log_level_rec) then

           raise FND_API.G_EXC_ERROR;
        end if;
        /*phase5 This function will validate if current transaction is overlapping to any previously done impairment*/
        if not FA_ASSET_VAL_PVT.check_overlapping_impairment(
               p_trans_rec            => l_trans_rec,
               p_asset_hdr_rec        => l_asset_hdr_rec ,
               p_log_level_rec        => g_log_level_rec) then

               fa_srvr_msg.add_message
                    (name       => 'FA_OVERLAPPING_IMP_NOT_ALLOWED',
                     calling_fn => 'FA_ASSET_VAL_PVT.check_overlapping_impairment'
                    ,p_log_level_rec => g_log_level_rec);

           raise FND_API.G_EXC_ERROR;
        end if;
   end if; -- book_type_code

   -- *********************************
   -- **  Populate local record types
   -- *********************************
   -- populate rec_types that were not provided by users

   -- pop asset_desc_rec
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_desc_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_desc_rec    => l_asset_desc_rec
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop asset_type_rec
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_type_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_type_rec    => l_asset_type_rec
          ,p_date_effective     => NULL
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

/* Bug# 4663092: fyi: May not needed at this level  */
   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code  => 'P'
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop current period_rec info
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   -- get the current units of the asset from fa_asset_history table
   -- ? call the following get_current_units function
   -- to make sure that the current_units
   -- of asset_desc_rec is correct.
   -- => this call shouldn't be necessary
   --    if asset_desc_rec.current_units always reflects current units.
   if not FA_UTIL_PVT.get_current_units
          (p_calling_fn    => l_calling_fn
          ,p_asset_id      => l_asset_hdr_rec.asset_id
          ,x_current_units => l_asset_desc_rec.current_units
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- *********************************************
   -- **  Set default values unless provided
   -- *********************************************
   -- set default values unless provided
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'set default values unless provided', '', p_log_level_rec => g_log_level_rec); end if;

   -- default date_retired to the current period if it is null
   if l_asset_retire_rec.date_retired is null then

        -- default date_retired to the current period
        l_asset_retire_rec.date_retired
          := greatest(least(l_period_rec.calendar_period_close_date, sysdate)
                     ,l_period_rec.calendar_period_open_date
                     );
   end if;

   -- BUG# 3549470
   -- remove time stamps

   l_asset_retire_rec.date_retired :=
       to_date(to_char(l_asset_retire_rec.date_retired, 'DD/MM/YYYY'),'DD/MM/YYYY');

   -- set transaction_date_entered
   if l_asset_retire_rec.date_retired
      <> l_trans_rec.transaction_date_entered
      or l_trans_rec.transaction_date_entered is null then
        l_trans_rec.transaction_date_entered := l_asset_retire_rec.date_retired;
   end if;

   if (l_asset_fin_rec.group_asset_id is not null) then
      l_ins_status := FA_TRX_APPROVAL_PKG.faxcat
                   (x_book              => l_asset_hdr_rec.book_type_code
                   ,x_asset_id          => l_asset_fin_rec.group_asset_id
                   ,x_trx_type          => 'ADJUSTMENT'
                   ,x_trx_date          => l_asset_retire_rec.date_retired
                   ,x_init_message_flag => 'NO', p_log_level_rec => g_log_level_rec);
      if not l_ins_status then
        g_msg_name := 'error msg name-after trx_app group';
        raise FND_API.G_EXC_ERROR;
      end if;

   end if;

/****
 *** BUG#4663092: Move this book-specific validation to do_all_retirement level.

   -- default retirement prorate convention if not provided.

   if l_asset_retire_rec.retirement_prorate_convention is null then
     SELECT retirement_prorate_convention,
             use_stl_retirements_flag,
             stl_method_code,
             stl_life_in_months
     INTO
           l_ret_prorate_convention,
           l_use_stl_retirements_flag,
           l_stl_method_code,
           l_stl_life_in_months
     FROM       fa_category_book_defaults, fa_additions_b a
     WHERE      book_type_code = l_asset_hdr_rec.book_type_code
     and        category_id = a.asset_category_id
     and        a.asset_id  = l_asset_hdr_rec.asset_id
     and        l_asset_fin_rec.Date_Placed_In_Service between start_dpis and
                     nvl(end_dpis,l_asset_fin_rec.Date_Placed_In_Service);

     l_asset_retire_rec.retirement_prorate_convention := l_ret_prorate_convention;

     --
     if (l_Use_STL_Retirements_Flag = 'NO') then
        l_asset_retire_rec.detail_info.stl_method_code := NULL;
        l_asset_retire_rec.detail_info.stl_life_in_months := NULL;
     else
        if (l_asset_retire_rec.detail_info.stl_method_code is null) then
           l_asset_retire_rec.detail_info.stl_method_code :=
                                                l_stl_method_code;
        end if;
        if (l_asset_retire_rec.detail_info.stl_life_in_months is null) then
           l_asset_retire_rec.detail_info.stl_life_in_months :=
                                                l_stl_life_in_months;
        end if;
     end if;
   end if;
  ***
  */


   /*
    * Added for Group Asset uptake
    */

-- source line retirement now available for core FA too.
     /*
      * Call Invoice API to populate cost_retired in case of
      * source line retirement.
      */
     if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'l_inv_tbl.last: ', to_char(l_inv_tbl.last)); end if;

     if (nvl(l_inv_tbl.last, 0) > 0 ) then

       -- Populate asset_cat_rec
       if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_cat_rec', '', p_log_level_rec => g_log_level_rec); end if;
       if not FA_UTIL_PVT.get_asset_cat_rec (
                               p_asset_hdr_rec  => l_asset_hdr_rec,
                               px_asset_cat_rec => l_asset_cat_rec,
                               p_date_effective  => NULL, p_log_level_rec => g_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

       -- Initialize g_inv_trans_rec global variable
       g_inv_trans_rec.invoice_transaction_id := to_number(null);
       g_inv_trans_rec.transaction_type := 'RETIREMENT';

       if not FA_INVOICE_PVT.INVOICE_ENGINE (
                               px_trans_rec              => l_trans_rec,
                               px_asset_hdr_rec          => l_asset_hdr_rec,
                               p_asset_desc_rec          => l_asset_desc_rec,
                               p_asset_type_rec          => l_asset_type_rec,
                               p_asset_cat_rec           => l_asset_cat_rec,
                               p_asset_fin_rec_adj       => l_asset_fin_rec,
                               x_asset_fin_rec_new       => l_new_asset_fin_rec,
                               x_asset_fin_mrc_tbl_new   => l_new_asset_fin_mrc_tbl,
                               px_inv_trans_rec          => g_inv_trans_rec,
                               px_inv_tbl                => l_inv_tbl,
                               x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                               x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
                               p_calling_fn              => l_calling_fn,
                               p_log_level_rec => g_log_level_rec) then
         if g_log_level_rec.statement_level then
           fa_debug_pkg.add(l_calling_fn, 'Error Calling FA_INVOICE_PVT.INVOICE_ENGINE', '',  p_log_level_rec => g_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'SQLERRM: ', SQLERRM, p_log_level_rec => g_log_level_rec);
         end if;
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

          if (g_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (fname=>'FAPRETB.pls',
                element=>'cost_retired',
               value=> l_asset_retire_rec.cost_retired, p_log_level_rec => g_log_level_rec);
             FA_DEBUG_PKG.ADD (fname=>'do_all_book_retirement',
                element=>'cost',
               value=> l_asset_fin_rec.cost, p_log_level_rec => g_log_level_rec);
          end if;

-- fixed_assets_cost is obviously passed in as negative value for src line ret.
       l_asset_retire_rec.cost_retired := nvl(l_new_asset_fin_rec.cost, 0) * - 1;


     end if; -- (nvl(l_inv_tbl.last, 0) > 0 )

   /*** End of uptake ***/

 -- fix for bug 4705832
   l_asset_retire_rec.limit_proceeds_flag := l_asset_fin_rec.limit_proceeds_flag;
   -- for 4705832 adding next line to be safe. may not be necessary if being derived later
   l_asset_retire_rec.reduction_rate := l_asset_fin_rec.reduction_rate;

   -- *********************************************
   -- **  Do validation
   -- *********************************************
   -- validate that all user-entered input parameters are valid
   if not do_validation
          (p_validation_type   => g_retirement
          ,p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,p_asset_retire_rec  => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_calling_fn        => p_calling_fn
          ,p_log_level_rec       => g_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   -- **********************************************
   -- **  Do asset-level validation on transaction
   -- **********************************************
   -- begin asset-level validation on transaction

   -- check if trx is partial retirement on CIP asset
   if g_log_level_rec.statement_level then
       fa_debug_pkg.add(l_calling_fn, 'begin asset-level validation on transaction', '', p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'check if trx is partial retirement on CIP asset', '', p_log_level_rec => g_log_level_rec);
   end if;
   if l_asset_retire_rec.units_retired is not null then

        -- can only fully retire CIP assets unless source line retirement
        if l_asset_type_rec.asset_type = 'CIP' and p_inv_tbl.count = 0
           and l_asset_retire_rec.units_retired <> l_asset_desc_rec.current_units then
             g_msg_name := 'FA_RET_WHOLE_CIP_ASSET';
             raise FND_API.G_EXC_ERROR;
        end if;

      else -- if units_retired is null

        -- can only fully retire CIP assets unless source line retirement
        if l_asset_type_rec.asset_type = 'CIP' and p_inv_tbl.count = 0
           and l_asset_retire_rec.cost_retired <> l_asset_fin_rec.cost then
             g_msg_name := 'FA_RET_WHOLE_CIP_ASSET';
             raise FND_API.G_EXC_ERROR;
        end if;

   end if; -- partial retirement on CIP asset

   -- The following code was in the initialize part
   -- of retirement in FAXASSET(i.e. fa_retire_pkg.initialize).
   -- ? not sure of the following code - need more investigation
   if l_asset_desc_rec.unit_adjustment_flag = 'YES' then
        g_msg_name := 'FA_RET_CHANGE_UNITS_TFR_FORM';
        raise FND_API.G_EXC_ERROR;
   end if;

   -- FYI: We don't allow unit retirements for TAX book
   -- probably because TAX book does not have its own distributions
   -- in DH table.
   if fa_cache_pkg.fazcbc_record.book_class = 'TAX'
      and l_asset_retire_rec.units_retired is not null then
        g_msg_name := 'FA_RET_NO_PART_UNIT_IN_TAX';
         -- ? can not find this message name in msg table
        raise FND_API.G_EXC_ERROR;
   end if;


   /* IAC Specific Validation */
   if (FA_IGI_EXT_PKG.IAC_Enabled) then
       if not FA_IGI_EXT_PKG.Validate_Retire_Reinstate(
           p_book_type_code   => l_asset_hdr_rec.book_type_code,
           p_asset_id         => l_asset_hdr_rec.asset_id,
           p_calling_function => l_calling_fn
        ) then
            raise FND_API.G_EXC_ERROR;
       end if;
   end if;

   -- check if any adjustment is pending
   -- Users cannot retire the asset if an adjustment is pending
   -- FA_RET_PENDING_ADJUSTMENT
   -- ? Is this adj check really needed ? - No, not in do_retirement


   -- ***************************
   -- **  Do basic calculation
   -- ***************************
   -- begin retirement-specific calculation
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin calculation', '', p_log_level_rec => g_log_level_rec); end if;

   if l_asset_retire_rec.units_retired is not null then

        -- derive cost_retired from units_retired
        -- regardless of cost_retired once units_retired is proved
        -- just as faxasset form does so.
        -- formula: cost_retired <= units_retired/current_units * cost

         if ( l_asset_retire_rec.units_retired < l_asset_desc_rec.current_units ) then
           --Bug# 6998072 start
           l_ret_cost :=0;
           for ctr in 1..p_asset_dist_tbl.count
           Loop
               l_cost_retire_last_unit :=0;
               l_total_cost_retire :=0;
               l_unit_assigned :=0;

               Select  hist.units_assigned into l_unit_assigned
               from fa_distribution_history hist
               where hist.distribution_id = p_asset_dist_tbl(ctr).distribution_id;

               If ( l_unit_assigned + p_asset_dist_tbl(ctr).transaction_units = 0 ) then
                  fa_query_balances_pkg.query_balances(
                    X_asset_id       => l_asset_hdr_rec.asset_id,
                    X_book           => l_asset_hdr_rec.book_type_code,
                    X_period_ctr     => 0,
                    X_dist_id        => p_asset_dist_tbl(ctr).distribution_id,
                    X_run_mode       => 'STANDARD',
                    X_cost           => l_cost_retire_last_unit,
                    X_deprn_rsv      => dummy_num,
                    X_reval_rsv      => dummy_num,
                    X_ytd_deprn      => dummy_num,
                    X_ytd_reval_exp  => dummy_num,
                    X_reval_deprn_exp => dummy_num,
                    X_deprn_exp      => dummy_num,
                    X_reval_amo      => dummy_num,
                    X_prod           => dummy_num,
                    X_ytd_prod       => dummy_num,
                    X_ltd_prod       => dummy_num,
                    X_adj_cost       => dummy_num,
                    X_reval_amo_basis=> dummy_num,
                    X_bonus_rate     => dummy_num,
                    X_deprn_source_code     => dummy_char,
                    X_adjusted_flag         => dummy_bool,
                    X_transaction_header_id => -1,
                    X_bonus_deprn_rsv       => dummy_num,
                    X_bonus_ytd_deprn       => dummy_num,
                    X_bonus_deprn_amount    => dummy_num,
                    X_impairment_rsv        => dummy_num,
                    X_ytd_impairment        => dummy_num,
                    X_impairment_amount     => dummy_num,
                    X_capital_adjustment    => dummy_num,
                    X_general_fund          => dummy_num,
                    X_mrc_sob_type_code     => l_reporting_flag,
                    X_set_of_books_id       => l_asset_hdr_rec.set_of_books_id,
                    p_log_level_rec         => g_log_level_rec
                   );
               Else
                    l_total_cost_retire:=(((p_asset_dist_tbl(ctr).transaction_units*-1) / l_asset_desc_rec.current_units))
                        * l_asset_fin_rec.cost;
               End if;

                    l_ret_cost := nvl(l_total_cost_retire,0) +
                                  nvl(l_cost_retire_last_unit,0) +
                                  nvl(l_ret_cost,0);
                    l_asset_retire_rec.cost_retired := l_ret_cost;

           End Loop;
           --Bug# 6998072 end
        else
           l_asset_retire_rec.cost_retired
             := (l_asset_retire_rec.units_retired / l_asset_desc_rec.current_units)
                 * l_asset_fin_rec.cost;
        end if;

        if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_rec.cost_retired
                                  ,x_book   => l_asset_hdr_rec.book_type_code
                                  ,x_set_of_books_id => l_asset_hdr_rec.set_of_books_id
                                  ,p_log_level_rec => g_log_level_rec) then
                                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'derived cost_retired: ', l_asset_retire_rec.cost_retired, p_log_level_rec => g_log_level_rec); end if;

        if l_asset_retire_rec.units_retired = l_asset_desc_rec.current_units then
           l_transaction_type := 'FULL RETIREMENT';
        else
           l_transaction_type := 'PARTIAL UNIT RETIREMENT';
        end if;

      else -- if units_retired is null

        -- ? need to check the condition for the transaction type, full retirement.
        if l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost then
             l_transaction_type := 'FULL RETIREMENT';
        else
             l_transaction_type := 'PARTIAL COST RETIREMENT';
        end if;

   end if; -- units_retired/cost_retired

   -- Make sure that transaction type becomes FULL RETIREMENT
   -- when retiring an asset with zero cost
   if l_asset_fin_rec.cost = 0 then
        l_transaction_type := 'FULL RETIREMENT';
   end if;

   -- ? need to check again
   if l_transaction_type = 'FULL RETIREMENT'
         then
           l_trans_rec.transaction_type_code := 'FULL RETIREMENT';
   elsif l_transaction_type = 'PARTIAL UNIT RETIREMENT'
         or l_transaction_type = 'PARTIAL COST RETIREMENT'
         then
           l_trans_rec.transaction_type_code := 'PARTIAL RETIREMENT';
   end if;

   -- assign date_retired to trans_date_entered
   l_trans_rec.transaction_date_entered := l_asset_retire_rec.date_retired;

   l_asset_retire_rec.status := 'PENDING';

   -- end retirement-specific calculation
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'end calculation', '', p_log_level_rec => g_log_level_rec); end if;

   -- Fix for Bug #3187975.  Do Polish rule validations.
   -- Need to do this after transaction_type_code is derived.
   if not FA_ASSET_VAL_PVT.validate_polish (
      p_transaction_type_code => l_trans_rec.transaction_type_code,
      p_method_code           => l_asset_fin_rec.deprn_method_code,
      p_life_in_months        => l_asset_fin_rec.life_in_months,
      p_asset_type            => l_asset_type_rec.asset_type,
      p_bonus_rule            => l_asset_fin_rec.bonus_rule,
      p_ceiling_name          => l_asset_fin_rec.ceiling_name,
      p_deprn_limit_type      => l_asset_fin_rec.deprn_limit_type,
      p_group_asset_id        => l_asset_fin_rec.group_asset_id,
      p_calling_fn            => 'FA_RETIREMENT_PUB.do_retirement'
   , p_log_level_rec => g_log_level_rec) then
      g_msg_name := null;
      g_token1 := null;
      raise FND_API.G_EXC_ERROR;
   end if;

   -- ***************************
   -- **  Main
   -- ***************************
   if g_log_level_rec.statement_level then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Entering corporate book',
             value   => '', p_log_level_rec => g_log_level_rec);
   end if;

   if not do_all_books_retirement
          (px_trans_rec        => l_trans_rec
          ,px_dist_trans_rec   => l_dist_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_ERROR;
   end if;

   l_retirement_id    := l_asset_retire_rec.retirement_id;

   if g_log_level_rec.statement_level then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Finished corporate book',
             value   => '', p_log_level_rec => g_log_level_rec);
   end if;

   px_trans_rec := l_trans_rec;
   px_dist_trans_rec := l_dist_trans_rec;
   px_asset_retire_rec := l_asset_retire_rec;

   /* if book is a corporate book, process cip assets and autocopy */

   -- start processing tax books for cip-in-tax and autocopy
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      lv_trans_rec := l_trans_rec;
      lv_asset_hdr_rec := l_asset_hdr_rec;

      if (l_asset_type_rec.asset_type = 'CIP'
          or l_asset_type_rec.asset_type = 'CAPITALIZED') then

         if g_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Asset type',
               value   => l_asset_type_rec.asset_type, p_log_level_rec => g_log_level_rec);
         end if;

         if not fa_cache_pkg.fazctbk
                (x_corp_book    => l_asset_hdr_rec.book_type_code
                ,x_asset_type   => l_asset_type_rec.asset_type
                ,x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => g_log_level_rec) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         if g_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_tax_book_tbl.count',
               value   => l_tax_book_tbl.count, p_log_level_rec => g_log_level_rec);
         end if;


         for l_tax_index in 1..l_tax_book_tbl.count loop

           if g_log_level_rec.statement_level then
              fa_debug_pkg.add(l_calling_fn, 'entered loop for tax books', '', p_log_level_rec => g_log_level_rec);
              fa_debug_pkg.add(l_calling_fn, 'selected tax book: ', l_tax_book_tbl(l_tax_index));
           end if;

           if not FA_ASSET_VAL_PVT.validate_asset_book
                  (p_transaction_type_code      => px_trans_rec.transaction_type_code
                  ,p_book_type_code             => l_tax_book_tbl(l_tax_index)
                  ,p_asset_id                   => px_asset_hdr_rec.asset_id
                  ,p_calling_fn                 => l_calling_fn
                  ,p_log_level_rec              => g_log_level_rec) then

                     null; -- just to ignore the error

           else

             -- cache the book information for the tax book
             if not fa_cache_pkg.fazcbc(x_book => l_tax_book_tbl(l_tax_index),
                                        p_log_level_rec => g_log_level_rec) then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

             -- ? Excerpt from Brad's comment on this part - need more investigation:
             -- 'May need to set the transaction date, trx_type, subtype here as well
             --  based on the open period and settings for each tax book in the loop'

             lv_asset_hdr_rec.book_type_code           := l_tax_book_tbl(l_tax_index);
             lv_trans_rec.source_transaction_header_id := l_trans_rec.transaction_header_id;
             lv_trans_rec.transaction_header_id        := null;

             if g_log_level_rec.statement_level then
                fa_debug_pkg.add(l_calling_fn, 'calling do_all_books_retirement for tax book', '', p_log_level_rec => g_log_level_rec);
                fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'In Tax-Book Loop For',
                 value   => lv_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
             end if;


             if not do_all_books_retirement
                    (px_trans_rec        => lv_trans_rec      -- tax
                    ,px_dist_trans_rec   => lv_dist_trans_rec -- null
                    ,p_asset_hdr_rec     => lv_asset_hdr_rec  -- tax
                    ,p_asset_desc_rec    => l_asset_desc_rec
                    ,p_asset_type_rec    => l_asset_type_rec
                    ,p_asset_fin_rec     => l_asset_fin_rec
                    ,px_asset_retire_rec => lv_asset_retire_rec
                    ,p_asset_dist_tbl    => l_asset_dist_tbl
                    ,p_subcomp_tbl       => l_subcomp_tbl
                    ,p_inv_tbl           => l_inv_tbl
                    ,p_period_rec        => l_period_rec
                    ,p_log_level_rec     => g_log_level_rec
                    ) then
                        raise FND_API.G_EXC_ERROR;
             end if;

           end if;

         end loop;

      end if; -- asset_type

   end if; -- book_class

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.recognize_gain_loss',
                       l_asset_retire_rec.recognize_gain_loss, g_log_level_rec);
   end if;
   IF (l_asset_fin_rec.group_asset_id is not null
        and l_asset_retire_rec.recognize_gain_loss = 'YES') THEN
      l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;
   END IF;

   l_calculate_gain_loss_flag := l_asset_retire_rec.calculate_gain_loss;

   if g_log_level_rec.statement_level then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Check to see if calculate gain/loss has to be submitted',
             value   => '', p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'before calc gain/loss', '', p_log_level_rec => g_log_level_rec);
   end if;

   -- submit calculate_gain_loss programs if flag is set

   if l_calculate_gain_loss_flag = FND_API.G_TRUE then

        if g_log_level_rec.statement_level then
           fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Running calculate gain/loss...',
             value   => '', p_log_level_rec => g_log_level_rec);
        end if;

        if g_log_level_rec.statement_level then
           fa_debug_pkg.add(l_calling_fn, 'ret_id:', l_retirement_id, p_log_level_rec => g_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'submit calculate gain/loss program', '', p_log_level_rec => g_log_level_rec);
        end if;
        if not calculate_gain_loss
               (p_retirement_id     => l_retirement_id
               ,p_mrc_sob_type_code => 'P'
               ,p_log_level_rec     => g_log_level_rec
               ) then
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
        if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'right after calc gain/loss', '', p_log_level_rec => g_log_level_rec); end if;

   end if;

   -- call to workflow business event
   fa_business_events.raise(p_event_name => 'oracle.apps.fa.retirement.asset.retire',
                 p_event_key => l_retirement_id || to_char(sysdate,'RRDDDSSSSS'),
                 p_parameter_name1 => 'RETIREMENT_ID',
                 p_parameter_value1 => l_retirement_id,
                 p_parameter_name2 => 'ASSET_ID',
                 p_parameter_value2 => px_asset_hdr_rec.asset_id,
                 p_parameter_name3 => 'ASSET_NUMBER',
                 p_parameter_value3 => l_asset_desc_rec.asset_number,
                 p_parameter_name4 => 'BOOK_TYPE_CODE',
                 p_parameter_value4 => px_asset_hdr_rec.book_type_code,
                 p_log_level_rec       => g_log_level_rec);


   -- commit if p_commit is TRUE.
   if FND_API.to_boolean(p_commit) then
      COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

   -- return the status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then

          ROLLBACK TO do_retirement;

          x_return_status := FND_API.G_RET_STS_ERROR;

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => g_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => g_log_level_rec);
          end if;

          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when FND_API.G_EXC_UNEXPECTED_ERROR then

          ROLLBACK TO do_retirement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                 , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when others then

          ROLLBACK TO do_retirement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

END do_retirement;

FUNCTION do_all_books_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
-- will return retirement_id of asset_retire_rec
IS

   -- Returns the reporting GL set_of_books_ids
   -- associated with the set_of_books_id of given primary book_type_code
   CURSOR sob_cursor(p_book_type_code in varchar2
                    ,p_sob_id         in number) is
   SELECT set_of_books_id AS sob_id
     FROM fa_mc_book_controls
    WHERE book_type_code          = p_book_type_code
      AND primary_set_of_books_id = p_sob_id
      AND enabled_flag            = 'Y';

   -- used for main transaction book
   l_book_class                 varchar2(15);
   l_set_of_books_id            number;
   l_distribution_source_book   varchar2(30);
   l_mc_source_flag             varchar2(1);

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   l_sob_tbl           FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   lv_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;

   -- local individual variables
   l_latest_trans_date date;
   l_ret_prorate_date  date;
   l_prorate_calendar  varchar2(15);
   l_fiscal_year_name  varchar2(30);


   -- used for category defaulting
   l_ret_prorate_convention     FA_CATEGORY_BOOK_DEFAULTS.prorate_convention_code%TYPE;
   l_use_stl_retirements_flag   FA_CATEGORY_BOOK_DEFAULTS.use_stl_retirements_flag%TYPE;
   l_stl_method_code    FA_CATEGORY_BOOK_DEFAULTS.stl_method_code%TYPE;
   l_stl_life_in_months FA_CATEGORY_BOOK_DEFAULTS.stl_life_in_months%TYPE;


   -- added for bug 3684222
   l_latest_reval_date date;

   -- msg
   g_msg_name                   varchar2(30);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_all_books_retirement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_dist_trans_rec   := px_dist_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_desc_rec   := p_asset_desc_rec;
   l_asset_type_rec   := p_asset_type_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;

   -- *********************************
   -- **  Populate local record types
   -- *********************************
   -- populate rec_types that were not provided by users

   -- call the cache for the primary transaction book
   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code     => 'P'
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   fa_debug_pkg.add(l_calling_fn,'l_asset_fin_rec.recognize_gain_loss',l_asset_fin_rec.recognize_gain_loss,p_log_level_rec);

        /*Bug 8647381 - Defaulting Recognize_Gain_Loss if it is null. */
        if l_asset_retire_rec.recognize_gain_loss is null then
           l_asset_retire_rec.recognize_gain_loss := l_asset_fin_rec.recognize_gain_loss;
        end if;


   -- pop current period_rec info
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************************************
   -- **  Do asset/book-level validation on transaction
   -- ***************************************************
   -- begin asset/book-level validation on transaction

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin asset/book-level validation on transaction', '', p_log_level_rec => p_log_level_rec); end if;

   -- check if the asset is in period of addition
   -- used CAPITALIZED as mode since the current FAXASSET form uses this logic
   -- We allow users to retire CIP assets. But we don't allow retirements
   -- in period of capitalization.
   -- The following mode 'CAPITALIZED' makes sure that the asset
   -- is neither in the period of addition nor in the period of capitalization.
   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'check if the asset is in period of addition', '', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'asset_id: ',  l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'book: ',  l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
   end if;

   -- BUG# 4053626
   -- the above was incorrect interpretation - need to use absolute

   if FA_ASSET_VAL_PVT.validate_period_of_addition
      (p_asset_id            => l_asset_hdr_rec.asset_id
      ,p_book                => l_asset_hdr_rec.book_type_code
      ,p_mode                => 'ABSOLUTE'
      ,px_period_of_addition => l_asset_hdr_rec.period_of_addition
      , p_log_level_rec => p_log_level_rec) then
          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'perid_of_addition_flag: ',  l_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec); end if;
          if (l_asset_hdr_rec.period_of_addition = 'Y'  and
              G_release = 11) then
               -- error out since retirement is not allowed in period of addition
               g_msg_name := 'FA_RET_CANT_RET_NONDEPRN';
               raise FND_API.G_EXC_ERROR;
          end if;
   else
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'perid_of_addition_flag: ',  l_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec); end if;

   -- check if there is an add-to-asset transaction pending
   -- Users must post their mass additions before they can retire the asset
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if there is an add-to-asset transaction pending', '', p_log_level_rec => p_log_level_rec); end if;
   if FA_ASSET_VAL_PVT.validate_add_to_asset_pending
      (p_asset_id   => l_asset_hdr_rec.asset_id
      ,p_book       => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => p_log_level_rec) then
          -- Users must post their mass additions before they can retire the asset
          g_msg_name := 'FA_RET_CANT_RET_INCOMPLETE_ASS';
          raise FND_API.G_EXC_ERROR;
   end if;

   -- check if another retirement/reinstatement already pending
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if another retirement/reinstatement already pending', '', p_log_level_rec => p_log_level_rec); end if;
   if FA_ASSET_VAL_PVT.validate_ret_rst_pending
      (p_asset_id   => l_asset_hdr_rec.asset_id
      ,p_book       => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => p_log_level_rec) then
          g_msg_name := 'FA_RET_PENDING_RETIREMENTS';
          raise FND_API.G_EXC_ERROR;
   end if;

   -- check if the asset has already been fully retired
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if the asset is already fully retired', '', p_log_level_rec => p_log_level_rec); end if;
   if FA_ASSET_VAL_PVT.validate_fully_retired
      (p_asset_id  => l_asset_hdr_rec.asset_id
      ,p_book      => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => p_log_level_rec) then
          g_msg_name := 'FA_REC_RETIRED';
          raise FND_API.G_EXC_ERROR;
   end if;

   -- check if date_retired is valid in terms of trx date
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if date_retired is valid in terms of trx date', '', p_log_level_rec => p_log_level_rec); end if;
   if l_asset_retire_rec.date_retired is not null then

        -- no transactions except Retirements and Reinstatements may be
        -- dated after the latest trx date
        if not FA_UTIL_PVT.get_latest_trans_date
               (p_calling_fn        => l_calling_fn
               ,p_asset_id          => l_asset_hdr_rec.asset_id
               ,p_book              => l_asset_hdr_rec.book_type_code
               ,x_latest_trans_date => l_latest_trans_date
               , p_log_level_rec => p_log_level_rec) then
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        if l_asset_retire_rec.date_retired < l_latest_trans_date then
             g_msg_name := 'FA_SHARED_OTHER_TRX_FOLLOW';
             raise FND_API.G_EXC_ERROR;
        end if;

        -- BUG# 3575340
        -- need to prevent the backdate of a retirement not only
        -- on the retire date but also the prorate date

        l_prorate_calendar     := fa_cache_pkg.fazcbc_record.prorate_calendar;
        l_fiscal_year_name     := fa_cache_pkg.fazcbc_record.fiscal_year_name;

        if p_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'fa_cache_pkg.fazcbc_record.prorate_calendar',
               value   => fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_asset_retire_rec.retirement_prorate_convention',
               value   => l_asset_retire_rec.retirement_prorate_convention, p_log_level_rec => p_log_level_rec);
        end if;

        /* Bug#4663092: Moved Book-specific validation/calculation to do_all_books_retirement function. */
        if l_asset_retire_rec.retirement_prorate_convention is null then

          SELECT retirement_prorate_convention,
             use_stl_retirements_flag,
             stl_method_code,
             stl_life_in_months
          INTO
            l_ret_prorate_convention,
            l_use_stl_retirements_flag,
            l_stl_method_code,
            l_stl_life_in_months
          FROM   fa_category_book_defaults, fa_additions_b a
          WHERE  book_type_code = l_asset_hdr_rec.book_type_code
            and  category_id = a.asset_category_id
            and  a.asset_id  = l_asset_hdr_rec.asset_id
            and  l_asset_fin_rec.Date_Placed_In_Service between start_dpis and
                   nvl(end_dpis,l_asset_fin_rec.Date_Placed_In_Service);

          l_asset_retire_rec.retirement_prorate_convention := l_ret_prorate_convention;
          --

          if (l_Use_STL_Retirements_Flag = 'NO') then
            l_asset_retire_rec.detail_info.stl_method_code := NULL;
            l_asset_retire_rec.detail_info.stl_life_in_months := NULL;
          else
            if (l_asset_retire_rec.detail_info.stl_method_code is null) then
              l_asset_retire_rec.detail_info.stl_method_code :=
                                                l_stl_method_code;
            end if;
            if (l_asset_retire_rec.detail_info.stl_life_in_months is null) then
               l_asset_retire_rec.detail_info.stl_life_in_months :=
                                                l_stl_life_in_months;
            end if;
          end if;

        end if;


        if not fa_cache_pkg.fazccvt
               (x_prorate_convention_code => l_asset_retire_rec.retirement_prorate_convention,
                x_fiscal_year_name        => l_fiscal_year_name, p_log_level_rec => p_log_level_rec) then
           raise FND_API.G_EXC_ERROR;
        end if;

        if not fa_cache_pkg.fazcdp
                 (x_book_type_code => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
           raise FND_API.G_EXC_ERROR;
        end if;

        select prorate_date
          into l_ret_prorate_date
          from fa_calendar_periods cp,
               fa_conventions conv
         where conv.prorate_convention_code   = l_asset_retire_rec.retirement_prorate_convention
           and conv.start_date               <= l_asset_retire_rec.date_retired
           and conv.end_date                 >= l_asset_retire_rec.date_retired
           and cp.calendar_type               = l_prorate_calendar
           and conv.prorate_date             >= cp.start_date
           and conv.prorate_date             <= cp.end_date;

        -- added this for bug 3684222
        select MAX(transaction_date_entered)
        into l_latest_reval_date
        from fa_transaction_headers
        where asset_id       = l_asset_hdr_rec.asset_id
        and book_type_code = l_asset_hdr_rec.book_type_code
        and transaction_type_code in ('REVALUATION');

        -- added this for bug 3684222
        if (l_ret_prorate_date < l_latest_reval_date and
             l_ret_prorate_date < fa_cache_pkg.fazcdp_record.calendar_period_open_date) then
             g_msg_name := 'FA_SHARED_OTHER_TRX_FOLLOW';
             raise FND_API.G_EXC_ERROR;
        end if;


   end if; -- date_retired

   if (not fa_cache_pkg.fazccmt(l_asset_fin_rec.deprn_method_code,
                                l_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec)) then
      if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
      end if;

      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /* Bug 8584206 */
   IF not FA_ASSET_VAL_PVT.validate_energy_transactions (
               p_trans_rec            => l_trans_rec,
               p_asset_type_rec       => p_asset_type_rec,
               p_asset_fin_rec_old    => p_asset_fin_rec,
               p_asset_hdr_rec        => p_asset_hdr_rec ,
               p_log_level_rec        => p_log_level_rec) then

           raise FND_API.G_EXC_ERROR;
        END IF;


   --
   -- Bug3254818: Lift this ristriction for FLAT method type
   --
   -- check if date_retired is valid
   if (l_asset_retire_rec.date_retired is not null) and
      (fa_cache_pkg.fazccmt_record.rate_source_rule <> fa_std_types.FAD_RSR_FLAT) then

        if l_asset_retire_rec.date_retired < l_period_rec.calendar_period_open_date
           and nvl(l_asset_fin_rec.period_counter_fully_reserved,99)
               <> nvl(l_asset_fin_rec.period_counter_life_complete,99)
           then

             g_msg_name := 'FA_NO_TRX_WHEN_LIFE_COMPLETE';
             raise FND_API.G_EXC_ERROR;

        end if;

   end if; -- date_retired

   -- check if cost_retired is valid when units_retired is null
   if l_asset_retire_rec.units_retired is null then

        -- check if absolute value of retired_cost is greater than that of current_cost


        if abs(l_asset_retire_rec.cost_retired) > abs(l_asset_fin_rec.cost)
           or sign(l_asset_retire_rec.cost_retired) <> sign(l_asset_fin_rec.cost) then

          if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (fname=>'do_all_book_retirement',
                element=>'In error: cost_retired',
               value=> l_asset_retire_rec.cost_retired, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (fname=>'do_all_book_retirement',
                element=>'In error: cost',
               value=> l_asset_fin_rec.cost, p_log_level_rec => p_log_level_rec);
          end if;

             g_msg_name := 'FA_RET_COST_TOO_BIG';
             raise FND_API.G_EXC_ERROR;
        end if;

   end if; -- units_retired

   if (fa_cache_pkg.fazcbc_record.book_class = 'TAX'
       and l_asset_retire_rec.units_retired is not null) then

        -- In tax book, treat unit retirement as cost retirement
        l_asset_retire_rec.cost_retired
          := l_asset_fin_rec.cost
             * l_asset_retire_rec.units_retired
               / l_asset_desc_rec.current_units;

        l_asset_retire_rec.units_retired := NULL;

        -- round the converted amounts
        if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_rec.cost_retired
                                  ,x_book   => l_asset_hdr_rec.book_type_code
                                  ,x_set_of_books_id => l_asset_hdr_rec.set_of_books_id
                                  , p_log_level_rec => p_log_level_rec) then
                                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

   end if;

   if l_asset_retire_rec.cost_retired is null then
      l_asset_retire_rec.cost_retired := 0;
   end if;

   if l_asset_retire_rec.proceeds_of_sale is null then
      l_asset_retire_rec.proceeds_of_sale := 0;
   end if;

   if l_asset_retire_rec.cost_of_removal is null then
      l_asset_retire_rec.cost_of_removal := 0;
   end if;

   /*Bug#8289173 - to fetch transaction_header_id and retirement_id for the RETIREMENT row
                   to not rely on table handler (for consistency)*/
   select fa_transaction_headers_s.nextval
   into   l_trans_rec.transaction_header_id
   from   dual;

   select fa_retirements_s.nextval
   into l_asset_retire_rec.retirement_id
   from dual;
   /*Bug#8289173 - end*/

   -- SLA UPTAKE
   -- assign an event for the transaction
   -- at this point key info asset/book/trx info is known from above code

   if not fa_xla_events_pvt.create_transaction_event
        (p_asset_hdr_rec => l_asset_hdr_rec,
         p_asset_type_rec=> l_asset_type_rec,
         px_trans_rec    => l_trans_rec,
         p_event_status  => FA_XLA_EVENTS_PVT.C_EVENT_INCOMPLETE,
         p_calling_fn    => 'FA_RETIREMENT_PUB.do_all_books_retirement'
         ,p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************
   -- **  Main
   -- ***************************

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling do_sub_retirement for each book/sob', '', p_log_level_rec => p_log_level_rec); end if;

   if not do_sub_retirement
          (px_trans_rec        => l_trans_rec
          ,px_dist_trans_rec   => l_dist_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_mrc_sob_type_code => 'P'
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'do_all_books_retirement: retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'do_all_books_retirement: transaction_header_id: ', l_trans_rec.transaction_header_id, p_log_level_rec => p_log_level_rec);
   end if;

   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;

   -- MRC LOOP
   -- if this is a primary book, process reporting books(sobs)
   if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

       g_primary_set_of_books_id := l_asset_hdr_rec.set_of_books_id;

       -- call the sob cache to get the table of sob_ids
       if not FA_CACHE_PKG.fazcrsob
              (x_book_type_code => l_asset_hdr_rec.book_type_code,
               x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

       -- loop through each book starting with the primary and
       -- call sub routine for each
       for l_sob_index in 1..l_sob_tbl.count loop

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in sob_id loop', '', p_log_level_rec => p_log_level_rec); end if;

         if not fa_cache_pkg.fazcbcs(x_book => l_asset_hdr_rec.book_type_code,
                                     x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                     p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return FALSE;
         end if;

         -- set up the local asset_header and sob_id
         lv_asset_hdr_rec    := l_asset_hdr_rec;
         lv_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);

         if not do_sub_retirement
                (px_trans_rec        => l_trans_rec
                ,px_dist_trans_rec   => l_dist_trans_rec
                ,p_asset_hdr_rec     => lv_asset_hdr_rec
                ,p_asset_desc_rec    => l_asset_desc_rec
                ,p_asset_type_rec    => l_asset_type_rec
                ,p_asset_fin_rec     => l_asset_fin_rec
                ,px_asset_retire_rec => l_asset_retire_rec
                ,p_asset_dist_tbl    => l_asset_dist_tbl
                ,p_subcomp_tbl       => l_subcomp_tbl
                ,p_inv_tbl           => l_inv_tbl
                ,p_period_rec        => l_period_rec
                ,p_mrc_sob_type_code => 'R'
                ,p_log_level_rec     => p_log_level_rec
                ) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

       end loop;

   end if;

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do_all_books_retirement: retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec); end if;
   -- px_asset_retire_rec := l_asset_retire_rec;
   px_asset_retire_rec.retirement_id := l_asset_retire_rec.retirement_id;
   px_trans_rec := l_trans_rec;
   px_dist_trans_rec := l_dist_trans_rec;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_all_books_retirement;


FUNCTION do_sub_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,px_dist_trans_rec            in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
-- will return retirement_id of px_asset_retire_rec
IS

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec    FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_rec FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_retire_mrc_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   l_asset_cat_rec     FA_API_TYPES.asset_cat_rec_type;

   l_rate                      number;

   l_fraction_remaining        number;
   l_deprn_rounding_flag       varchar2(30);
   l_period_counter_fully_ret  number;


   /* BUG#2919562 */
   l_trx_rate                  number;

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_sub_retirement';

BEGIN


   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;
   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec         := px_trans_rec;
   l_dist_trans_rec    := px_dist_trans_rec;
   l_asset_hdr_rec     := p_asset_hdr_rec;
   l_asset_desc_rec    := p_asset_desc_rec;
   l_asset_type_rec    := p_asset_type_rec;
   l_asset_fin_rec     := p_asset_fin_rec;
   l_asset_retire_rec  := px_asset_retire_rec;
   l_asset_retire_mrc_rec := px_asset_retire_rec;
   l_asset_dist_tbl    := p_asset_dist_tbl;
   l_subcomp_tbl       := p_subcomp_tbl;
   l_inv_tbl           := p_inv_tbl;
   l_period_rec        := p_period_rec;

   -- ***************************
   -- **  Pop local rec types
   -- ***************************

   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_mrc_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code     => p_mrc_sob_type_code
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop asset_cat_rec
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_cat_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_cat_rec     => l_asset_cat_rec
          ,p_date_effective     => NULL
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************
   -- **  Do basic calculation
   -- ***************************

   if p_mrc_sob_type_code = 'R' then

      if l_asset_fin_rec.cost <> 0 then

         -- rate is calculated as reporting cost divided by primary cost
         l_rate := l_asset_fin_mrc_rec.cost / l_asset_fin_rec.cost;

      else

       /********* BUG#2919562
        -- get average rate from the latest transaction record
        -- when cost is zero
        select br1.avg_exchange_rate
        into l_rate
        from fa_mc_books_rates br1
        where br1.asset_id              = l_asset_hdr_rec.asset_id
          and br1.book_type_code        = l_asset_hdr_rec.book_type_code
          and br1.set_of_books_id       = l_asset_hdr_rec.set_of_books_id
          and br1.transaction_header_id =
             (select max(br2.transaction_header_id)
              from fa_mc_books_rates br2
              where br2.asset_id        = l_asset_hdr_rec.asset_id
                and br2.book_type_code  = l_asset_hdr_rec.book_type_code
                and br2.set_of_books_id = l_asset_hdr_rec.set_of_books_id);
       *****/

          l_rate := 1;


      end if;

       /* BUG#2919562 */
      if not FA_MC_UTIL_PVT.get_trx_rate
              (p_prim_set_of_books_id      => g_primary_set_of_books_id,
               p_reporting_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
               px_exchange_date            => l_asset_retire_rec.date_retired,
               p_book_type_code            => l_asset_hdr_rec.book_type_code,
               px_rate                     => l_trx_rate
              , p_log_level_rec => p_log_level_rec) then return false;

      end if;

   else

      l_rate := 1;
      l_trx_rate := 1;

   end if;

   -- convert the financial amounts using the retrieved rate
   -- cost_retired is calculated as primary cost_retired multiplied by l_rate
   l_asset_retire_mrc_rec.cost_retired     := l_asset_retire_rec.cost_retired
                                              * l_rate;
   l_asset_retire_mrc_rec.reserve_retired := l_asset_retire_rec.reserve_retired * l_trx_rate; --Bug 9103418
   l_asset_retire_mrc_rec.proceeds_of_sale := l_asset_retire_rec.proceeds_of_sale
                                              * l_trx_rate;
   l_asset_retire_mrc_rec.cost_of_removal  := l_asset_retire_rec.cost_of_removal
                                              * l_trx_rate;

   -- round the converted amounts
   if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_mrc_rec.cost_retired
                             ,x_book   => l_asset_hdr_rec.book_type_code
                             ,x_set_of_books_id => l_asset_hdr_rec.set_of_books_id
                             , p_log_level_rec => p_log_level_rec) then
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_mrc_rec.proceeds_of_sale
                             ,x_book   => l_asset_hdr_rec.book_type_code
                             ,x_set_of_books_id => l_asset_hdr_rec.set_of_books_id
                             , p_log_level_rec => p_log_level_rec) then
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_mrc_rec.cost_of_removal
                             ,x_book   => l_asset_hdr_rec.book_type_code
                             ,x_set_of_books_id => l_asset_hdr_rec.set_of_books_id
                             , p_log_level_rec => p_log_level_rec) then
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- if transaction is full retirement
   -- then set cost_retired to full cost
   -- so that there is no rounding issue.

   -- Bug 5752331: Added condition l_asset_fin_rec.cost <> 0
   if l_asset_fin_rec.cost = l_asset_retire_rec.cost_retired and
      l_asset_fin_rec.cost <> 0 then

      l_asset_retire_mrc_rec.cost_retired := l_asset_fin_mrc_rec.cost;
      --bug 5453230
      l_asset_retire_rec.units_retired := l_asset_desc_rec.current_units;
      l_asset_retire_mrc_rec.units_retired := l_asset_desc_rec.current_units;

   end if;

  /* Bug#4663092 */
  if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (fname=>'do_sub_retirement',
                element=>'BEGIN: l_asset_retire_mrc_rec.retirement_id',
               value=> l_asset_retire_mrc_rec.retirement_id, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (fname=>'do_sub_retirement',
                element=>'BEGIN: l_asset_retire_mrc_rec.status',
               value=> l_asset_retire_mrc_rec.status, p_log_level_rec => p_log_level_rec);
   end if;

   -- ***************************
   -- **  Main
   -- ***************************

   if not do_sub_regular_retirement
          (px_trans_rec        => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_fin_rec     => l_asset_fin_mrc_rec
          ,px_asset_retire_rec => l_asset_retire_mrc_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_mrc_sob_type_code => p_mrc_sob_type_code
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_asset_retire_rec.units_retired = l_asset_desc_rec.current_units
      or l_asset_retire_rec.units_retired is null then
      -- if full unit retirement or cost (both full and partial) retirement

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'treat this trx as regular', '', p_log_level_rec => p_log_level_rec); end if;
        null;

   elsif l_asset_retire_rec.units_retired
         < l_asset_desc_rec.current_units then -- if partial unit retirement

        -- Due to 3188851, need to insert CR row for members before calling dist api.
        if (l_asset_fin_rec.group_asset_id is not null) and
           (l_asset_retire_rec.recognize_gain_loss = 'NO') then

            --Need this for selection_thid
            SELECT fa_transaction_headers_s.nextval
            into l_dist_trans_rec.transaction_header_id /* 3513319 */
            FROM dual;
            /*
            -- due to 3513319.  Passing the thid straight to the dist api and keeping
            -- the value that came in in l_trans_rec.
            */
            if not FA_RETIREMENT_PVT.DO_RETIREMENT(
                       p_trans_rec         => l_trans_rec,
                       p_asset_retire_rec  => l_asset_retire_mrc_rec,
                       p_asset_hdr_rec     => l_asset_hdr_rec,
                       p_asset_type_rec    => l_asset_type_rec,
                       p_asset_cat_rec     => l_asset_cat_rec,
                       p_asset_fin_rec     => l_asset_fin_mrc_rec,
                       p_asset_desc_rec    => l_asset_desc_rec,
                       p_period_rec        => l_period_rec,
                       p_mrc_sob_type_code => p_mrc_sob_type_code,
                       p_calling_fn        => 'DO_RETIREMENT.CGLFR_CR_ONLY', p_log_level_rec => p_log_level_rec) then

                raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
        elsif (G_release = 11) then
            l_dist_trans_rec.transaction_header_id := NULL;
        end if; --group_asset_id <> null

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'treat this trx as partial unit retirement', '', p_log_level_rec => p_log_level_rec); end if;

        -- make a local copy of trans_rec and change trx_type_code
        -- this local copy of trans_rec will be used
        -- for distribution api and fautfr
        l_dist_trans_rec.transaction_date_entered :=
            l_trans_rec.transaction_date_entered;
        l_dist_trans_rec.source_transaction_header_id :=
            l_trans_rec.source_transaction_header_id;
        l_dist_trans_rec.mass_reference_id := l_trans_rec.mass_reference_id;
        l_dist_trans_rec.transaction_subtype := l_trans_rec.transaction_subtype;
        l_dist_trans_rec.transaction_key := l_trans_rec.transaction_key;
        l_dist_trans_rec.amortization_start_date :=
            l_trans_rec.amortization_start_date;
        l_dist_trans_rec.calling_interface := l_trans_rec.calling_interface;
        l_dist_trans_rec.who_info := l_trans_rec.who_info;
        l_dist_trans_rec.transaction_type_code := 'TRANSFER OUT';

        -- FYI: current_units is used as parameter of units_retired in Distribution API
        /* --Commenting this out for bug 3440308.  Don't c a use for it below, but if
           --some use was intended, then this logic is incorrect.
        l_asset_desc_rec.current_units := l_asset_retire_rec.units_retired;
           -- end 3440308 */

        -- FYI: call distribution api
        -- only when set of books is a primary GL book
        -- and FA book is a corporate book
        -- and transaction is a partial unit retirement.
        -- Assumption: fautfr in distribution API
        --             is handling all MRC part of adjustments table
        if (l_asset_dist_tbl.count > 0 )
           and
           (l_asset_hdr_rec.set_of_books_id
             = fa_cache_pkg.fazcbc_record.set_of_books_id)
           and
           (fa_cache_pkg.fazcbc_record.book_class='CORPORATE') then

             -- Call distribution API to process partial-unit retirement.
             -- do_distribution will handle TH, DH, AD and AH tables for TRANSFER OUT transaction
             -- and call 'fautfr' function in it.

             -- assuming that fautfr is inserting adjustment rows for TAX books.
             -- and calculate gain/loss is taking care of those for CORPORATE book.

             -- Required parameters for TRANSFER OUT transaction
             --   trans_rec: transaction_date_entered
             --   asset_hdr_rec: asset_id, book_type_code(only CORPORATE)
             --   asset_dist_tbl: distribution_id, trx_units

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add(l_calling_fn, 'trx_type_code:', l_dist_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'trx_date_entered:', l_dist_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'asset_id:', l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'book_type_code:', l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
             end if;

             SELECT fa_transaction_headers_s.nextval
             into l_dist_trans_rec.transaction_header_id
             FROM dual;

             /************* routine for debug
             for i in 1..l_asset_dist_tbl.count loop

                 if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'dist_id:', l_asset_dist_tbl(1).distribution_id); end if;
                 if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'trx_units:', l_asset_dist_tbl(1).transaction_units); end if;

             end loop;
             *************/

             if not FA_DISTRIBUTION_PVT.do_distribution
                    (px_trans_rec            => l_dist_trans_rec
                    ,px_asset_hdr_rec        => l_asset_hdr_rec
                    ,px_asset_cat_rec_new    => l_asset_cat_rec
                    ,px_asset_dist_tbl       => l_asset_dist_tbl
                    , p_log_level_rec => p_log_level_rec) then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

        end if;

   end if; -- main

   -- fix for Bug 4966209
   -- call book cache to reset with right book

   -- call the cache for the book
   if not fa_cache_pkg.fazcbc(X_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   --
   -- If this is member asset and Recognize Gain Loss is set
   -- to "NO", create adjustment entries right away and
   -- make sure gain loss won't process this retirement later.
   --
   if (l_asset_fin_rec.group_asset_id is not null) and
      (nvl(l_asset_retire_rec.recognize_gain_loss, 'NO') = 'NO') then

-- ENERGY: Decide to fetch recognize gain loss using group asset id
-- ENERGY: or not.

      if not FA_RETIREMENT_PVT.DO_RETIREMENT(
                       p_trans_rec         => l_trans_rec,
                       p_asset_retire_rec  => l_asset_retire_mrc_rec,
                       p_asset_hdr_rec     => l_asset_hdr_rec,
                       p_asset_type_rec    => l_asset_type_rec,
                       p_asset_cat_rec     => l_asset_cat_rec,
                       p_asset_fin_rec     => l_asset_fin_mrc_rec,
                       p_asset_desc_rec    => l_asset_desc_rec,
                       p_period_rec        => l_period_rec,
                       p_mrc_sob_type_code => p_mrc_sob_type_code,
                       p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then

         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if;


   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do_sub_retirement: retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec); end if;

  /* Bug#4663092 */
  if (p_log_level_rec.statement_level) then
             FA_DEBUG_PKG.ADD (fname=>'do_sub_retirement',
                element=>'l_asset_retire_mrc_rec.retirement_id',
               value=> l_asset_retire_mrc_rec.retirement_id, p_log_level_rec => p_log_level_rec);
             FA_DEBUG_PKG.ADD (fname=>'do_sub_retirement',
                element=>'l_asset_retire_mrc_rec.status',
               value=> l_asset_retire_mrc_rec.status, p_log_level_rec => p_log_level_rec);
   end if;

   -- Bug 4942017  Changed the order of statements
   -- Retirement_id was getting populated as NULL
   -- for reporting books

   px_asset_retire_rec := l_asset_retire_rec;
   px_asset_retire_rec.retirement_id := l_asset_retire_mrc_rec.retirement_id;

   px_trans_rec := l_trans_rec;
   px_dist_trans_rec := l_dist_trans_rec;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_sub_retirement;

FUNCTION do_sub_regular_retirement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in            FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in            FA_API_TYPES.asset_desc_rec_type
        ,p_asset_fin_rec              in            FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in            FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in            FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in            FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in            FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in            VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   p_sob_id                    number;
   p_book_type_code            varchar2(30);
   p_asset_id                  number;
   p_dpis                      date;


   -- changed fa_lookups to fa_lookups_b for high-cost sql fix
   CURSOR bk_cursor IS
     select bk.transaction_header_id_in
           ,bk.Allowed_Deprn_Limit_Amount
           ,bk.date_effective
           ,itc.basis_reduction_rate
           ,ce.limit
           ,lk.lookup_type
     from   fa_books     bk
           ,fa_itc_rates itc
           ,fa_ceilings  ce
           ,fa_lookups_b   lk
     where  bk.asset_id = p_asset_id
     and    bk.book_type_code = p_book_type_code
     and    bk.date_ineffective is null
     and    bk.itc_amount_id = itc.itc_amount_id(+)
     and    bk.ceiling_name  = ce.ceiling_name(+)
     and    bk.date_placed_in_service between
               nvl(ce.start_date, bk.date_placed_in_service)
               and nvl(ce.end_date, bk.date_placed_in_service)
     and    bk.ceiling_name = lk.lookup_code(+)
     and    p_mrc_sob_type_code = 'P'
     UNION
     select /*+ INDEX (bk fa_mc_books_n1)*/
            bk.transaction_header_id_in
           ,bk.Allowed_Deprn_Limit_Amount
           ,bk.date_effective
           ,itc.basis_reduction_rate
           ,ce.limit
           ,lk.lookup_type
     from   fa_mc_books     bk
           ,fa_itc_rates itc
           ,fa_ceilings  ce
           ,fa_lookups_b   lk
     where  bk.asset_id = p_asset_id
     and    bk.book_type_code = p_book_type_code
     and    bk.date_ineffective is null
     and    bk.itc_amount_id = itc.itc_amount_id(+)
     and    bk.ceiling_name  = ce.ceiling_name(+)
     and    bk.date_placed_in_service between
               nvl(ce.start_date, bk.date_placed_in_service)
               and nvl(ce.end_date, bk.date_placed_in_service)
     and    bk.ceiling_name = lk.lookup_code(+)
     and    p_mrc_sob_type_code <> 'P'
     and    bk.set_of_books_id = p_sob_id;

   bk_rec   bk_cursor%ROWTYPE;


   CURSOR salvage_percent_deprn_limits IS
      select  cbd.percent_salvage_value
             ,cbd.use_deprn_limits_flag
             ,cbd.allowed_deprn_limit
             ,cbd.special_deprn_limit_amount
      from fa_additions_b            fad
          ,fa_category_book_defaults cbd
      where fad.asset_id = p_asset_id
      and   cbd.category_id = fad.asset_category_id
      and   cbd.book_type_code = p_book_type_code
      and   p_dpis
            between cbd.start_dpis
                and nvl(cbd.end_dpis,to_date('31-12-4712','DD-MM-YYYY'));

   limit_rec   salvage_percent_deprn_limits%ROWTYPE;

   CURSOR dh_cursor (p_asset_id       in number
                    ,p_book_type_code in varchar2) IS
        select  distribution_id,
                book_type_code,
                asset_id,
                units_assigned,
                date_effective,
                code_combination_id,
                location_id,
                transaction_header_id_in,
                last_update_date,
                last_updated_by,
                date_ineffective,
                assigned_to,
                transaction_header_id_out,
                transaction_units,
                retirement_id,
                last_update_login
        from fa_distribution_history
        where asset_id = p_asset_id
        and book_type_code = p_book_type_code
        and date_ineffective is null;

   CURSOR c_get_reserve is                                -- ENERGY
      select deprn_reserve                                -- ENERGY
      from   fa_books_summary                             -- ENERGY
      where  asset_id = p_asset_id                        -- ENERGY
      and    book_type_code = p_book_type_code            -- ENERGY
      and    period_counter = p_period_rec.period_counter -- ENERGY
      and    transaction_header_id_out is null;           -- ENERGY

   CURSOR c_get_group_method_info is                  -- ENERGY
      select db.rule_name                             -- ENERGY
      from   fa_deprn_basis_rules db                  -- ENERGY
           , fa_methods mt                            -- ENERGY
           , fa_books bk                              -- ENERGY
      where  bk.asset_id = p_asset_fin_rec.group_asset_id           -- ENERGY
      and    bk.book_type_code = p_asset_hdr_rec.book_type_code   -- ENERGY
      and    bk.transaction_header_id_out is null                      -- ENERGY
      and    bk.deprn_method_code = mt.method_code                     -- ENERGY
      and    nvl(bk.life_in_months, -99) = nvl(mt.life_in_months, -99) -- ENERGY
      and    mt.deprn_basis_rule_id = db.deprn_basis_rule_id;          -- ENERGY


   -- local asset info
   l_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec   FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec   FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec    FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl   FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl      FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl          FA_API_TYPES.inv_tbl_type;
   l_period_rec       FA_API_TYPES.period_rec_type;
   l_asset_deprn_rec  FA_API_TYPES.asset_deprn_rec_type;

   l_asset_cat_rec             FA_API_TYPES.asset_cat_rec_type;

   l_rowid                     ROWID;
   l_Fraction_Remaining        number;
   l_deprn_rounding_flag       varchar2(30);
   l_period_counter_fully_ret  number := null;

   l_percent_salvage_value     number := 0;

   l_adjusted_cost_new         number := 0;
   l_cost_new                  number := 0;
   l_salvage_value_new         number := 0;
   l_unrevalued_cost_new       number := 0;
   l_recoverable_cost_new      number := 0;
   l_recoverable               number := 0;
   l_adjusted_rec_cost         number := 0;
   l_eofy_reserve_new          number := 0;
   l_reval_amort_basis_new     number := 0;

   l_reserve_retired           number;                         -- ENERGY
   l_group_db_rule_name        varchar2(80);                   -- ENERGY

   l_status                    boolean := TRUE;

   l_th_rowid                  rowid;
   l_bk_rowid                  rowid;

   l_retirement_pending_flag   varchar2(3);

   l_rate_in_use               number;   -- Bug:5930979:Japan Tax Reform Project

   l_calling_fn  varchar2(80) := 'FA_RETIREMENT_PUB.do_sub_regular_retirement';

BEGIN

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;

   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_desc_rec   := p_asset_desc_rec;
   l_asset_fin_rec    := p_asset_fin_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;
   l_period_rec       := p_period_rec;

   -- ***************************
   -- **  Main
   -- ***************************
   -- determine deprn_rounding_flag and transaction_type_code
   -- between full retirement and partial retirement
   -- after evaluating units_retired vs. current_units
   -- and cost_retired vs. current_cost

   -- cost retirements on 0 cost assets are in fact
   -- treated as full retirements. (bug1565792)

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'set_of_books_id: ', l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec); end if;

   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec,
           px_asset_fin_rec        => l_asset_fin_rec,
           p_transaction_header_id => NULL,
           p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec,
           px_asset_type_rec    => l_asset_type_rec, p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if (p_mrc_sob_type_code <> 'R') then

       if ((l_asset_retire_rec.units_retired = l_asset_desc_rec.current_units
           )
           or (l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost
              and l_asset_retire_rec.cost_retired <> 0
              )
           or (l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost
              and l_asset_retire_rec.cost_retired = 0
              and l_asset_retire_rec.units_retired is NULL
              )
          ) then

          l_trans_rec.transaction_type_code := 'FULL RETIREMENT';
          l_period_counter_fully_ret := l_period_rec.period_counter;
          l_deprn_rounding_flag := 'RET';

          -- In case of TAX book, units_retired must always be NULL
          -- so that Calculate Gain/Loss program will not lead to
          -- distribution logic.
          if fa_cache_pkg.fazcbc_record.book_class='TAX' then
             l_asset_retire_rec.units_retired := NULL;
          else
             l_asset_retire_rec.units_retired := l_asset_desc_rec.current_units;
          end if;

       else
          l_trans_rec.transaction_type_code := 'PARTIAL RETIREMENT';
          l_period_counter_fully_ret := NULL;
          l_deprn_rounding_flag := 'RET';

       end if;

       l_trans_rec.who_info.creation_date := sysdate;
       l_trans_rec.who_info.last_update_date := sysdate;

       -- Fix for Bug #3187975.  Do Polish rule validations.
       -- Need to do this after transaction_type_code is derived.
       if not FA_ASSET_VAL_PVT.validate_polish (
          p_transaction_type_code => l_trans_rec.transaction_type_code,
          p_method_code           => l_asset_fin_rec.deprn_method_code,
          p_life_in_months        => l_asset_fin_rec.life_in_months,
          p_asset_type            => l_asset_type_rec.asset_type,
          p_bonus_rule            => l_asset_fin_rec.bonus_rule,
          p_ceiling_name          => l_asset_fin_rec.ceiling_name,
          p_deprn_limit_type      => l_asset_fin_rec.deprn_limit_type,
          p_group_asset_id        => l_asset_fin_rec.group_asset_id,
          p_calling_fn            =>
                               'FA_RETIREMENT_PUB.do_sub_regular_retirement'
       , p_log_level_rec => p_log_level_rec) then
          g_msg_name := null;
          g_token1 := null;
          raise FND_API.G_EXC_ERROR;
       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do fa_transaction_headers_pkg.insert_row', '', p_log_level_rec => p_log_level_rec); end if;
       fa_transaction_headers_pkg.insert_row
             (x_rowid                          => l_th_rowid,
              x_transaction_header_id          => l_trans_rec.transaction_header_id,
              x_book_type_code                 => l_asset_hdr_rec.book_type_code,
              x_asset_id                       => l_asset_hdr_rec.asset_id,
              x_transaction_type_code          => l_trans_rec.transaction_type_code,
              x_transaction_date_entered       => l_trans_rec.transaction_date_entered,
              x_date_effective                 => l_trans_rec.who_info.creation_date,
              x_last_update_date               => l_trans_rec.who_info.last_update_date,
              x_last_updated_by                => l_trans_rec.who_info.last_updated_by,
              x_transaction_name               => l_trans_rec.transaction_name,
              x_invoice_transaction_id         => g_inv_trans_rec.invoice_transaction_id,
              x_source_transaction_Header_id   => l_trans_rec.source_transaction_header_id,
              x_mass_reference_id              => l_trans_rec.mass_reference_id,
              x_last_Update_login              => l_trans_rec.who_info.last_update_login,
              x_transaction_subtype            => null, -- l_trans_rec.transaction_subtype
              x_Attribute1                     => l_trans_rec.desc_flex.attribute1,
              x_Attribute2                     => l_trans_rec.desc_flex.attribute2,
              x_Attribute3                     => l_trans_rec.desc_flex.attribute3,
              x_Attribute4                     => l_trans_rec.desc_flex.attribute4,
              x_Attribute5                     => l_trans_rec.desc_flex.attribute5,
              x_Attribute6                     => l_trans_rec.desc_flex.attribute6,
              x_Attribute7                     => l_trans_rec.desc_flex.attribute7,
              x_Attribute8                     => l_trans_rec.desc_flex.attribute8,
              x_Attribute9                     => l_trans_rec.desc_flex.attribute9,
              x_Attribute10                    => l_trans_rec.desc_flex.attribute10,
              x_Attribute11                    => l_trans_rec.desc_flex.attribute11,
              x_Attribute12                    => l_trans_rec.desc_flex.attribute12,
              x_Attribute13                    => l_trans_rec.desc_flex.attribute13,
              x_Attribute14                    => l_trans_rec.desc_flex.attribute14,
              x_Attribute15                    => l_trans_rec.desc_flex.attribute15,
              x_attribute_category_code        => l_trans_rec.desc_flex.attribute_category_code,
              x_transaction_key                => 'R', -- l_trans_rec.transaction_key
              x_mass_transaction_id            => l_trans_rec.mass_transaction_id,
              x_event_id                       => l_trans_rec.event_id,

              x_calling_interface               => l_trans_rec.calling_interface,
              x_return_status                  => l_status,
              x_calling_fn                     => l_calling_fn, p_log_level_rec => p_log_level_rec);

      -- returning trans_rec to reuse for mrc tables
      px_trans_rec := l_trans_rec;

   end if; -- reporting_flag

   if (l_asset_fin_rec.cost = 0) then
     l_fraction_remaining := 0;
   else
     l_fraction_remaining
               := 1 - l_asset_retire_rec.cost_retired/l_asset_fin_rec.cost;
   end if;

   l_cost_new := l_asset_fin_rec.cost - l_asset_retire_rec.cost_retired;
   l_unrevalued_cost_new := l_asset_fin_rec.unrevalued_cost * l_fraction_remaining;
   l_eofy_reserve_new := l_asset_fin_rec.eofy_reserve * l_fraction_remaining;

   if (fa_cache_pkg.fazcbc_record.retire_reval_reserve_flag='YES') and
      (l_asset_fin_rec.Reval_Amortization_Basis is not null) then
       l_reval_amort_basis_new := l_asset_fin_rec.Reval_Amortization_Basis * l_fraction_remaining;
   else
       l_reval_amort_basis_new := l_asset_fin_rec.Reval_Amortization_Basis;
   end if;

   -- BUG# 3933689
   -- correcting logic for salvage to account for type
   -- note that cost is already rounded coming in
   -- so we just need to floor or round the salvage
   -- prior to rec_cost derivation

   if (l_asset_fin_rec.salvage_type = 'PCT') then
       l_salvage_value_new :=
          l_cost_new * nvl(l_asset_fin_rec.percent_salvage_value, 0);

       fa_round_pkg.fa_ceil(l_salvage_value_new,
                            l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);

   else
      l_salvage_value_new := l_asset_fin_rec.salvage_value * l_fraction_remaining;
      if not FA_UTILS_PKG.faxrnd(x_amount => l_salvage_value_new,
                                 x_book   => l_asset_hdr_rec.book_type_code,
                                 x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                 p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if;

   p_sob_id         := l_asset_hdr_rec.set_of_books_id;
   p_asset_id       := l_asset_hdr_rec.asset_id;
   p_book_type_code := l_asset_hdr_rec.book_type_code;

   OPEN bk_cursor;
   FETCH bk_cursor INTO bk_rec;
   CLOSE bk_cursor;

   l_recoverable := l_cost_new -
                    l_salvage_value_new -
                    nvl(l_asset_fin_rec.itc_basis, 0) *
                    nvl(bk_rec.basis_reduction_rate, 0);

   if (l_asset_fin_rec.cost = l_asset_retire_rec.cost_retired) then
     l_recoverable_cost_new := 0;
   else
     -- set deprn_rounding_flag for partial cost retirement
     l_deprn_rounding_flag := 'RET';

     if (bk_rec.lookup_type = 'RECOVERABLE COST CEILING') then
       l_recoverable_cost_new := least(l_recoverable, bk_rec.limit);
     else
       l_recoverable_cost_new := l_recoverable;
     end if;
   end if;

   p_dpis           := p_asset_fin_rec.date_placed_in_service;


--   OPEN salvage_percent_deprn_limits;
--   FETCH salvage_percent_deprn_limits INTO limit_rec;
--   CLOSE salvage_percent_deprn_limits;

   -- now set Japan deprn_limits
   -- don't touch salvage value

   if (l_trans_rec.transaction_type_code = 'PARTIAL RETIREMENT') then

      if (l_asset_fin_rec.deprn_limit_type = 'PCT') then
         l_asset_fin_rec.allowed_deprn_limit_amount := l_cost_new -
                              l_cost_new * nvl(l_asset_fin_rec.allowed_deprn_limit, 0);

         if (l_asset_fin_rec.allowed_deprn_limit_amount <> 0) then
            fa_round_pkg.fa_ceil(l_asset_fin_rec.allowed_deprn_limit_amount,
                                 l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
         end if;

         l_asset_fin_rec.adjusted_recoverable_cost :=
                                l_cost_new - l_asset_fin_rec.allowed_deprn_limit_amount;

      elsif (l_asset_fin_rec.deprn_limit_type = 'AMT') then

         l_asset_fin_rec.adjusted_recoverable_cost :=
                                l_cost_new - l_asset_fin_rec.allowed_deprn_limit_amount;
      else
         l_asset_fin_rec.adjusted_recoverable_cost := l_recoverable_cost_new;
      end if;

      fa_round_pkg.fa_floor(l_asset_fin_rec.adjusted_recoverable_cost,
                            l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
      -- BUG# 4942017
      -- Period_Counter_Fully_Retired was not populated for
      -- reporting books
      l_period_counter_fully_ret := NULL;

   else -- Trx_Type_code = 'FULL RETIREMENT'

     -- BUG# 3371210
     -- leave the percent unchanged
     --   l_asset_fin_rec.percent_salvage_value := 0;
     l_asset_fin_rec.adjusted_recoverable_cost := 0;

     -- BUG# 4942017
     -- Period_Counter_Fully_Retired was not populated for
     -- reporting books
     l_period_counter_fully_ret := l_period_rec.period_counter;

   end if;

--bug fix 3982941 starts
   if(l_asset_fin_rec.Adjusted_Cost = l_asset_fin_rec.Recoverable_Cost)
    then
          l_adjusted_cost_new := l_Recoverable_Cost_New;
    end if;
--bug fix 3982941 ends

   -- rounding values
   if not FA_UTILS_PKG.faxrnd(x_amount => l_recoverable_cost_new,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Bug4343087: Moved function call of FA_UTILS_PKG.faxrnd for
   -- l_adjusted_cost_new to after deprn basis function call.

   if not FA_UTILS_PKG.faxrnd(x_amount => l_unrevalued_cost_new,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not FA_UTILS_PKG.faxrnd(x_amount => l_asset_retire_rec.eofy_reserve,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not FA_UTILS_PKG.faxrnd(x_amount => l_eofy_reserve_new,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not FA_UTILS_PKG.faxrnd(x_amount => l_reval_amort_basis_new,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   --
   -- Processing member asset if Recognize Gain Loss is NO.
   -- If it is YES, it will be processed at the time of Gain Loss.
   -- Below condition validating group asset id but it is not
   -- absolutely necessary since recognize gain loss should be null for
   -- stand alone assets.
   --

   -- Get asset_deprn_rec for Depreciable Basis Rule
        if (not FA_UTIL_PVT.get_asset_deprn_rec (
                  p_asset_hdr_rec     => l_asset_hdr_rec,
                  px_asset_deprn_rec  => l_asset_deprn_rec,
                  p_period_counter    => l_period_rec.period_counter,
                  p_mrc_sob_type_code => p_mrc_sob_type_code
                  ,p_log_level_rec => p_log_level_rec))
        then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn
                   ,p_log_level_rec => p_log_level_rec);
            RETURN FALSE;
        end if;

   if (l_asset_fin_rec.group_asset_id is not null) and
      (nvl(l_asset_retire_rec.recognize_gain_loss, 'NO') = 'NO') then

     l_retirement_pending_flag := 'NO';
     l_asset_retire_rec.detail_info.nbv_retired := 0;

     if (l_asset_retire_rec.limit_proceeds_flag = 'Y') and
        ((l_asset_fin_rec.recoverable_cost - l_recoverable_cost_new) <
         (l_asset_retire_rec.proceeds_of_sale - l_asset_retire_rec.cost_of_removal)) then

        l_asset_retire_rec.detail_info.gain_loss_amount := l_asset_retire_rec.proceeds_of_sale -
                                                           l_asset_retire_rec.cost_of_removal -
                                                           (l_asset_fin_rec.recoverable_cost -
                                                            l_recoverable_cost_new);
        l_asset_retire_rec.reserve_retired := 0;
        l_asset_retire_rec.detail_info.nbv_retired := l_asset_retire_rec.cost_retired;

     else

        l_asset_retire_rec.detail_info.gain_loss_amount := 0;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.deprn_reserve',
                           l_asset_deprn_rec.deprn_reserve, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.tracking_method',
                           l_asset_fin_rec.tracking_method, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcdrd_record.rule_name',
                           fa_cache_pkg.fazcdrd_record.rule_name, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.group_asset_id',
                           l_asset_fin_rec.group_asset_id, p_log_level_rec => p_log_level_rec);
       end if;

        OPEN c_get_group_method_info;
        FETCH c_get_group_method_info INTO l_group_db_rule_name;
        CLOSE c_get_group_method_info;

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, 'l_group_db_rule_name',
                            l_group_db_rule_name, p_log_level_rec => p_log_level_rec);
        end if;

        -- BUG# 6899255
        -- handle all allocate cases the same way rathern than just energy:
        -- (l_group_db_rule_name = 'ENERGY PERIOD END BALANCE')
        -- ENERGY
        if (nvl(l_asset_fin_rec.tracking_method, 'NO TRACK') = 'ALLOCATE') then
           --bug 9431199
           if (l_asset_fin_rec.cost = 0) then
              l_reserve_retired:=0;
           else
              l_reserve_retired :=
                 l_asset_deprn_rec.deprn_reserve * l_asset_retire_rec.cost_retired/l_asset_fin_rec.cost;
           end if;
                                                                                              -- ENERGY
           if not FA_UTILS_PKG.faxrnd(x_amount => l_reserve_retired,                          -- ENERGY
                                      x_book   => l_asset_hdr_rec.book_type_code,
                                      x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                      p_log_level_rec => p_log_level_rec) then        -- ENERGY
              raise FND_API.G_EXC_UNEXPECTED_ERROR;                                           -- ENERGY
           end if;                                                                            -- ENERGY
                                                                                              -- ENERGY
           l_asset_retire_rec.reserve_retired := l_reserve_retired;                           -- ENERGY

           if (p_log_level_rec.statement_level) then                                                            -- ENERGY
              fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.reserve_retired',            -- ENERGY
                               l_asset_retire_rec.reserve_retired, p_log_level_rec => p_log_level_rec);                           -- ENERGY
           end if;                                                                            -- ENERGY

        else                                                                                  -- ENERGY
           l_asset_retire_rec.reserve_retired := nvl(l_asset_retire_rec.cost_retired, 0) -
                                                 nvl(l_asset_retire_rec.proceeds_of_sale, 0) +
                                                 nvl(l_asset_retire_rec.cost_of_removal, 0);
        end if;

        l_asset_retire_rec.detail_info.nbv_retired := l_asset_retire_rec.cost_retired -
                                                      l_asset_retire_rec.reserve_retired;
     end if; -- (l_asset_retire_rec.limit_proceeds_flag = 'Y') and

     px_asset_retire_rec.reserve_retired := l_asset_retire_rec.reserve_retired;

   else -- Gain Loss will be processed by concurrent program
     l_retirement_pending_flag := 'YES';

     if (l_asset_fin_rec.group_asset_id is null) then
        l_asset_retire_rec.reserve_retired := to_number(null);
     end if;
   end if;

   -- Subtract Prior Year Reserve Retired from eofy_reserve
   if p_log_level_rec.statement_level then
       fa_debug_pkg.add(l_calling_fn, 'l_eofy_reserve_new', l_eofy_reserve_new, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_asset_fin_rec.eofy_reserve',  l_asset_fin_rec.eofy_reserve, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.eofy_reserve', l_asset_retire_rec.eofy_reserve, p_log_level_rec => p_log_level_rec);
   end if;

   if (l_asset_retire_rec.eofy_reserve is null) then
      l_asset_fin_rec.eofy_reserve := l_eofy_reserve_new;
   else
      l_asset_fin_rec.eofy_reserve := nvl(l_asset_fin_rec.eofy_reserve,0) -
                                      nvl(l_asset_retire_rec.eofy_reserve, 0);
   end if;

   if (l_asset_fin_rec.group_asset_id is not null) and
      (l_group_db_rule_name = 'ENERGY PERIOD END BALANCE') then
      l_asset_deprn_rec.deprn_reserve := l_asset_deprn_rec.deprn_reserve - l_asset_retire_rec.reserve_retired; -- ENERGY
   end if;

   -----------------------------------
   -- Call Depreciable Basis Rule
   -----------------------------------
   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                    (p_event_type             => 'RETIREMENT',
                     p_asset_fin_rec_new      => l_asset_fin_rec,
                     p_asset_fin_rec_old      => l_asset_fin_rec,
                     p_asset_hdr_rec          => l_asset_hdr_rec,
                     p_asset_type_rec         => l_asset_type_rec,
                     p_trans_rec              => l_trans_rec,
                     p_period_rec             => l_period_rec,
                     p_asset_retire_rec       => l_asset_retire_rec,
                     p_asset_deprn_rec        => l_asset_deprn_rec,
                     p_recoverable_cost       => l_recoverable_cost_new,
                     p_salvage_value          => l_salvage_value_new,
                     p_mrc_sob_type_code      => p_mrc_sob_type_code,
                     px_new_adjusted_cost     => l_adjusted_cost_new,
                     px_new_raf               => l_asset_fin_rec.rate_adjustment_factor,
       px_new_formula_factor    => l_asset_fin_rec.formula_factor, p_log_level_rec => p_log_level_rec)) then
       fa_srvr_msg.add_message(calling_fn =>
                            'FA_RETIREMENT_PUB.do_sub_regular_retirement', p_log_level_rec => p_log_level_rec);
       RETURN FALSE;
   end if;

   -- Bug4343087
   if not FA_UTILS_PKG.faxrnd(x_amount => l_adjusted_cost_new,
                              x_book   => l_asset_hdr_rec.book_type_code,
                              x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                              p_log_level_rec => p_log_level_rec) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_log_level_rec.statement_level then
       fa_debug_pkg.add(l_calling_fn, 'l_adjusted_cost_new', l_adjusted_cost_new, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, '++ l_asset_retire_rec.status', l_asset_retire_rec.status, p_log_level_rec => p_log_level_rec);
   end if;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'do fa_retirements_pkg.insert_row', '', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'asset_id: ', l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'book: ', l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'cost_retired: ', l_asset_retire_rec.cost_retired, p_log_level_rec => p_log_level_rec);
   end if;

   fa_retirements_pkg.insert_row
         (x_rowid                     => l_asset_retire_rec.detail_info.row_id,
          X_Retirement_Id             => l_asset_retire_rec.retirement_id,
          X_Book_Type_Code            => l_asset_hdr_rec.book_type_code,
          X_Asset_Id                  => l_asset_hdr_rec.asset_id,
          X_Transaction_Header_Id_In  => l_trans_rec.transaction_header_id,
          X_Date_Retired              => l_asset_retire_rec.date_retired,
          X_Date_Effective            => l_trans_rec.who_info.creation_date,
          X_Cost_Retired              => l_asset_retire_rec.cost_retired,
          X_Status                    => l_asset_retire_rec.status,-- ? need to check
          X_Last_Update_Date          => l_trans_rec.who_info.last_update_date,
          X_Last_Updated_By           => l_trans_rec.who_info.last_updated_by,
          X_Ret_Prorate_Convention    => l_asset_retire_rec.retirement_prorate_convention,
          X_Transaction_Header_Id_Out => NULL,
          X_Units                     => l_asset_retire_rec.units_retired,
          X_Cost_Of_Removal           => l_asset_retire_rec.cost_of_removal,
          X_Nbv_Retired               => l_asset_retire_rec.detail_info.nbv_retired,
          X_Gain_Loss_Amount          => l_asset_retire_rec.detail_info.gain_loss_amount,
          X_Proceeds_Of_Sale          => l_asset_retire_rec.proceeds_of_sale,
          X_Gain_Loss_Type_Code       => l_asset_retire_rec.detail_info.gain_loss_type_code,
          X_Retirement_Type_Code      => l_asset_retire_rec.retirement_type_code,
          X_Itc_Recaptured            => l_asset_retire_rec.detail_info.itc_recaptured,
          X_Itc_Recapture_Id          => l_asset_retire_rec.detail_info.itc_recapture_id,
          X_Reference_Num             => l_asset_retire_rec.reference_num,
          X_Sold_To                   => l_asset_retire_rec.sold_to,
          X_Trade_In_Asset_Id         => l_asset_retire_rec.trade_in_asset_id,
          X_Stl_Method_Code           => l_asset_retire_rec.detail_info.stl_method_code,
          X_Stl_Life_In_Months        => l_asset_retire_rec.detail_info.stl_life_in_months,
          X_Stl_Deprn_Amount          => l_asset_retire_rec.detail_info.stl_deprn_amount,
          X_Created_By                => l_trans_rec.who_info.created_by,
          X_Creation_Date             => l_trans_rec.who_info.creation_date,
          X_Last_Update_Login         => l_trans_rec.who_info.last_update_login,
          X_Attribute1                => l_asset_retire_rec.desc_flex.attribute1,
          X_Attribute2                => l_asset_retire_rec.desc_flex.attribute2,
          X_Attribute3                => l_asset_retire_rec.desc_flex.attribute3,
          X_Attribute4                => l_asset_retire_rec.desc_flex.attribute4,
          X_Attribute5                => l_asset_retire_rec.desc_flex.attribute5,
          X_Attribute6                => l_asset_retire_rec.desc_flex.attribute6,
          X_Attribute7                => l_asset_retire_rec.desc_flex.attribute7,
          X_Attribute8                => l_asset_retire_rec.desc_flex.attribute8,
          X_Attribute9                => l_asset_retire_rec.desc_flex.attribute9,
          X_Attribute10               => l_asset_retire_rec.desc_flex.attribute10,
          X_Attribute11               => l_asset_retire_rec.desc_flex.attribute11,
          X_Attribute12               => l_asset_retire_rec.desc_flex.attribute12,
          X_Attribute13               => l_asset_retire_rec.desc_flex.attribute13,
          X_Attribute14               => l_asset_retire_rec.desc_flex.attribute14,
          X_Attribute15               => l_asset_retire_rec.desc_flex.attribute15,
          X_Attribute_Category_Code   => l_asset_retire_rec.desc_flex.attribute_category_code,
          X_Reval_Reserve_Retired     => l_asset_retire_rec.detail_info.reval_reserve_retired,
          X_Unrevalued_Cost_Retired   => l_asset_retire_rec.detail_info.unrevalued_cost_retired,
          X_Recognize_Gain_Loss       => l_asset_retire_rec.recognize_gain_loss,
          X_Recapture_Reserve_Flag    => l_asset_retire_rec.recapture_reserve_flag,
          X_Limit_Proceeds_Flag       => l_asset_retire_rec.limit_proceeds_flag,
          X_Terminal_Gain_Loss        => l_asset_retire_rec.terminal_gain_loss,
          X_Reserve_Retired           => l_asset_retire_rec.reserve_retired,
          X_Eofy_Reserve              => l_asset_retire_rec.eofy_reserve,
          X_Reduction_Rate            => l_asset_retire_rec.reduction_rate,
          X_Recapture_Amount          => l_asset_retire_rec.detail_info.recapture_amount,
          X_mrc_sob_type_code         => p_mrc_sob_type_code,
          X_set_of_books_id           => l_asset_hdr_rec.set_of_books_id,
          x_calling_fn                => l_calling_fn,
          p_log_level_rec             => p_log_level_rec);

   -- return retirement_id if book is primary
   -- The retirement_ids of all reporting books will be same.
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec); end if;
   px_asset_retire_rec := l_asset_retire_rec;

   -- Bug:5930979:Japan Tax Reform Project (Start)
   if nvl(fa_cache_pkg.fazccmt_record.GUARANTEE_RATE_METHOD_FLAG,'NO') = 'YES' then

      SELECT nvl(rate_in_use,0)
      INTO l_rate_in_use
      FROM fa_books
      WHERE asset_id = l_asset_hdr_rec.asset_id
      AND book_type_code = l_asset_hdr_rec.Book_Type_Code
      AND transaction_header_id_out is null;

      if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Fetching rate_in_use ', l_rate_in_use, p_log_level_rec => p_log_level_rec); end if;

   end if;

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'l_rate_in_use: ', l_rate_in_use, p_log_level_rec => p_log_level_rec); end if;
   -- Bug:5930979:Japan Tax Reform Project (End)

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do fa_books_pkg.update_row', '', p_log_level_rec => p_log_level_rec); end if;
   -- terminate current fa_books row
   fa_books_pkg.update_row (
          X_Rowid                        => NULL,
          X_Book_Type_Code               => l_asset_hdr_rec.Book_Type_Code,
          X_Asset_Id                     => l_asset_hdr_rec.Asset_Id,
          X_Date_Placed_In_Service       => l_asset_fin_rec.Date_Placed_In_Service,
          X_Date_Effective               => bk_rec.Date_Effective,
          X_Deprn_Start_Date             => l_asset_fin_rec.Deprn_Start_Date,
          X_Deprn_Method_Code            => l_asset_fin_rec.Deprn_Method_Code,
          X_Life_In_Months               => l_asset_fin_rec.Life_In_Months,
          X_Rate_Adjustment_Factor       => l_asset_fin_rec.Rate_Adjustment_Factor,
          X_Adjusted_Cost                => l_asset_fin_rec.Adjusted_Cost,
          X_Cost                         => l_asset_fin_rec.Cost,
          X_Original_Cost                => l_asset_fin_rec.Original_Cost,
          X_Salvage_Value                => l_asset_fin_rec.Salvage_Value,
          X_Prorate_Convention_Code      => l_asset_fin_rec.Prorate_Convention_Code,
          X_Prorate_Date                 => l_asset_fin_rec.Prorate_Date,
          X_Cost_Change_Flag             => l_asset_fin_rec.Cost_Change_Flag,
          X_Adjustment_Required_Status   => l_asset_fin_rec.Adjustment_Required_Status,
          X_Capitalize_Flag              => l_asset_fin_rec.Capitalize_Flag,
          X_Retirement_Pending_Flag      => l_retirement_pending_flag,
          X_Depreciate_Flag              => l_asset_fin_rec.Depreciate_Flag,
          X_Disabled_Flag                => l_asset_fin_rec.Disabled_Flag, --HH
          X_Last_Update_Date             => l_trans_rec.who_info.Last_Update_Date,
          X_Last_Updated_By              => l_trans_rec.who_info.Last_Updated_By,
          X_Date_Ineffective             => l_trans_rec.who_info.creation_date,
          X_Transaction_Header_Id_In     => bk_rec.Transaction_Header_Id_In,
          X_Transaction_Header_Id_Out    => l_trans_rec.Transaction_Header_Id,
          X_Itc_Amount_Id                => l_asset_fin_rec.Itc_Amount_Id,
          X_Itc_Amount                   => l_asset_fin_rec.Itc_Amount,
          X_Retirement_Id                => l_asset_retire_rec.Retirement_Id,
          X_Tax_Request_Id               => l_asset_fin_rec.Tax_Request_Id,
          X_Itc_Basis                    => l_asset_fin_rec.Itc_Basis,
          X_Basic_Rate                   => l_asset_fin_rec.Basic_Rate,
          X_Adjusted_Rate                => l_asset_fin_rec.Adjusted_Rate,
          X_Bonus_Rule                   => l_asset_fin_rec.Bonus_Rule,
          X_Ceiling_Name                 => l_asset_fin_rec.Ceiling_Name,
          X_Recoverable_Cost             => l_asset_fin_rec.Recoverable_Cost,
          X_Last_Update_Login            => l_trans_rec.who_info.Last_Update_Login,
          X_Adjusted_Capacity            => l_asset_fin_rec.Adjusted_Capacity,
          X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.Fully_Rsvd_Revals_Counter,
          X_Idled_Flag                   => l_asset_fin_rec.Idled_Flag,
          X_Period_Counter_Capitalized   => l_asset_fin_rec.Period_Counter_Capitalized,
          X_PC_Fully_Reserved            => l_asset_fin_rec.Period_Counter_Fully_Reserved,
          X_Period_Counter_Fully_Retired => l_Period_Counter_Fully_Ret,
          X_Production_Capacity          => l_asset_fin_rec.Production_Capacity,
          X_Reval_Amortization_Basis     => l_asset_fin_rec.Reval_Amortization_Basis,
          X_Reval_Ceiling                => l_asset_fin_rec.Reval_Ceiling,
          X_Unit_Of_Measure              => l_asset_fin_rec.Unit_Of_Measure,
          X_Unrevalued_Cost              => l_asset_fin_rec.Unrevalued_Cost,
          X_Annual_Deprn_Rounding_Flag   => 'RET',
--          X_Percent_Salvage_Value        => l_asset_fin_rec.Percent_Salvage_Value,
--          X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
--          X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => l_asset_fin_rec.Period_Counter_Life_Complete,
--          X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.Adjusted_Recoverable_Cost,
          X_Group_Asset_Id               => l_asset_fin_rec.Group_Asset_ID,
          X_salvage_type                 => l_asset_fin_rec.salvage_type,
          X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
          X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
          X_super_group_id               => l_asset_fin_rec.super_group_id,
          X_reduction_rate               => l_asset_retire_rec.reduction_rate,
          X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
          X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
          X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
          X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
          X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
          X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
          X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
          X_tracking_method              => l_asset_fin_rec.tracking_method,
          X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
          X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
          X_depreciation_option          => l_asset_fin_rec.depreciation_option,
          X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => l_asset_hdr_rec.set_of_books_id,
          X_Calling_Fn                   => l_calling_fn,
        X_nbv_at_switch                  => l_asset_fin_rec.nbv_at_switch               ,      -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
        X_prior_deprn_limit_type         => l_asset_fin_rec.prior_deprn_limit_type       ,
        X_prior_deprn_limit_amount       => l_asset_fin_rec.prior_deprn_limit_amount      ,
        X_prior_deprn_limit              => l_asset_fin_rec.prior_deprn_limit              ,
        X_period_counter_fully_rsrved    => l_asset_fin_rec.period_counter_fully_reserved     ,
        X_extended_depreciation_period   => l_asset_fin_rec.extended_depreciation_period     ,
        X_prior_deprn_method             => l_asset_fin_rec.prior_deprn_method                ,
        X_prior_life_in_months           => l_asset_fin_rec.prior_life_in_months               ,
        X_prior_basic_rate               => l_asset_fin_rec.prior_basic_rate                    ,
        X_prior_adjusted_rate            => l_asset_fin_rec.prior_adjusted_rate                   -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
          , p_log_level_rec => p_log_level_rec);

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do fa_books_pkg.insert_row', '', p_log_level_rec => p_log_level_rec); end if;
   -- insert into fa books
   fa_books_pkg.insert_row
         (X_Rowid                        => l_bk_rowid,
          X_Book_Type_Code               => l_asset_hdr_rec.book_type_code,
          X_Asset_Id                     => l_asset_hdr_rec.asset_id,
          X_Date_Placed_In_Service       => l_asset_fin_rec.date_placed_in_service,
          X_Date_Effective               => l_trans_rec.who_info.last_update_date,
          X_Deprn_Start_Date             => l_asset_fin_rec.deprn_start_date,
          X_Deprn_Method_Code            => l_asset_fin_rec.deprn_method_code,
          X_Life_In_Months               => l_asset_fin_rec.life_in_months,
          X_Rate_Adjustment_Factor       => l_asset_fin_rec.rate_adjustment_factor,
          X_Adjusted_Cost                => l_adjusted_cost_new,
          X_Cost                         => l_cost_new,
          X_Original_Cost                => l_asset_fin_rec.original_cost,
          X_Salvage_Value                => l_salvage_value_new,
          X_Prorate_Convention_Code      => l_asset_fin_rec.prorate_convention_code,
          X_Prorate_Date                 => l_asset_fin_rec.prorate_date,
          X_Cost_Change_Flag             => l_asset_fin_rec.cost_change_flag,
          X_Adjustment_Required_Status   => l_asset_fin_rec.adjustment_required_status,
          X_Capitalize_Flag              => l_asset_fin_rec.capitalize_flag,
          X_Retirement_Pending_Flag      => l_retirement_pending_flag,
          X_Depreciate_Flag              => l_asset_fin_rec.depreciate_flag,
          X_Disabled_Flag                => l_asset_fin_rec.Disabled_Flag, --HH
          X_Last_Update_Date             => l_trans_rec.who_info.last_update_date,
          X_Last_Updated_By              => l_trans_rec.who_info.last_updated_by,
          X_Date_Ineffective             => NULL,
          X_Transaction_Header_Id_In     => l_trans_rec.transaction_header_id,
          X_Transaction_Header_Id_Out    => NULL,
          X_Itc_Amount_Id                => l_asset_fin_rec.itc_amount_id,
          X_Itc_Amount                   => l_asset_fin_rec.itc_amount,
          X_Retirement_Id                => NULL,
          X_Tax_Request_Id               => l_asset_fin_rec.tax_request_id,
          X_Itc_Basis                    => l_asset_fin_rec.itc_basis,
          X_Basic_Rate                   => l_asset_fin_rec.basic_rate,
          X_Adjusted_Rate                => l_asset_fin_rec.adjusted_rate,
          X_Bonus_Rule                   => l_asset_fin_rec.bonus_rule,
          X_Ceiling_Name                 => l_asset_fin_rec.ceiling_name,
          X_Recoverable_Cost             => l_recoverable_cost_new,
          X_Last_Update_Login            => l_trans_rec.who_info.last_update_login,
          X_Adjusted_Capacity            => l_asset_fin_rec.adjusted_capacity,
          X_Fully_Rsvd_Revals_Counter    => l_asset_fin_rec.fully_rsvd_revals_counter,
          X_Idled_Flag                   => l_asset_fin_rec.idled_flag,
          X_Period_Counter_Capitalized   => l_asset_fin_rec.period_counter_capitalized,
          X_PC_Fully_Reserved            => l_asset_fin_rec.period_counter_fully_reserved,
          X_Period_Counter_Fully_Retired => l_period_counter_fully_ret,
          X_Production_Capacity          => l_asset_fin_rec.production_capacity,
          X_Reval_Amortization_Basis     => l_reval_amort_basis_new,
          X_Reval_Ceiling                => l_asset_fin_rec.reval_ceiling,
          X_Unit_Of_Measure              => l_asset_fin_rec.unit_of_measure,
          X_Unrevalued_Cost              => l_unrevalued_cost_new,
          --X_Annual_Deprn_Rounding_Flag   => l_deprn_rounding_flag,
          X_Annual_Deprn_Rounding_Flag   => 'RET',
          X_Percent_Salvage_Value        => l_asset_fin_rec.percent_salvage_value,
          X_Allowed_Deprn_Limit          => l_asset_fin_rec.allowed_deprn_limit,
          X_Allowed_Deprn_Limit_Amount   => l_asset_fin_rec.allowed_deprn_limit_amount,
          X_Period_Counter_Life_Complete => l_asset_fin_rec.period_counter_life_complete,
          X_Adjusted_Recoverable_Cost    => l_asset_fin_rec.adjusted_recoverable_cost,
          X_Short_Fiscal_Year_Flag       => l_asset_fin_rec.short_fiscal_year_flag,
          X_Conversion_Date              => l_asset_fin_rec.conversion_date,
          X_Orig_Deprn_Start_Date        => l_asset_fin_rec.orig_deprn_start_date,
          X_Remaining_Life1              => l_asset_fin_rec.remaining_life1,
          X_Remaining_Life2              => l_asset_fin_rec.remaining_life2,
          X_Old_Adj_Cost                 => l_asset_fin_rec.old_adjusted_cost,
          X_Formula_Factor               => l_asset_fin_rec.formula_factor,
          X_gf_Attribute1                => l_asset_fin_rec.global_attribute1,
          X_gf_Attribute2                => l_asset_fin_rec.global_attribute2,
          X_gf_Attribute3                => l_asset_fin_rec.global_attribute3,
          X_gf_Attribute4                => l_asset_fin_rec.global_attribute4,
          X_gf_Attribute5                => l_asset_fin_rec.global_attribute5,
          X_gf_Attribute6                => l_asset_fin_rec.global_attribute6,
          X_gf_Attribute7                => l_asset_fin_rec.global_attribute7,
          X_gf_Attribute8                => l_asset_fin_rec.global_attribute8,
          X_gf_Attribute9                => l_asset_fin_rec.global_attribute9,
          X_gf_Attribute10               => l_asset_fin_rec.global_attribute10,
          X_gf_Attribute11               => l_asset_fin_rec.global_attribute11,
          X_gf_Attribute12               => l_asset_fin_rec.global_attribute12,
          X_gf_Attribute13               => l_asset_fin_rec.global_attribute13,
          X_gf_Attribute14               => l_asset_fin_rec.global_attribute14,
          X_gf_Attribute15               => l_asset_fin_rec.global_attribute15,
          X_gf_Attribute16               => l_asset_fin_rec.global_attribute16,
          X_gf_Attribute17               => l_asset_fin_rec.global_attribute17,
          X_gf_Attribute18               => l_asset_fin_rec.global_attribute18,
          X_gf_Attribute19               => l_asset_fin_rec.global_attribute19,
          X_gf_Attribute20               => l_asset_fin_rec.global_attribute20,
          X_global_attribute_category    => l_asset_fin_rec.global_attribute_category,
          X_group_asset_id               => l_asset_fin_rec.group_asset_id,
          X_salvage_type                 => l_asset_fin_rec.salvage_type,
          X_deprn_limit_type             => l_asset_fin_rec.deprn_limit_type,
          X_over_depreciate_option       => l_asset_fin_rec.over_depreciate_option,
          X_super_group_id               => l_asset_fin_rec.super_group_id,
          X_reduction_rate               => l_asset_fin_rec.reduction_rate,
          X_reduce_addition_flag         => l_asset_fin_rec.reduce_addition_flag,
          X_reduce_adjustment_flag       => l_asset_fin_rec.reduce_adjustment_flag,
          X_reduce_retirement_flag       => l_asset_fin_rec.reduce_retirement_flag,
          X_recognize_gain_loss          => l_asset_fin_rec.recognize_gain_loss,
          X_recapture_reserve_flag       => l_asset_fin_rec.recapture_reserve_flag,
          X_limit_proceeds_flag          => l_asset_fin_rec.limit_proceeds_flag,
          X_terminal_gain_loss           => l_asset_fin_rec.terminal_gain_loss,
          X_exclude_proceeds_from_basis  => l_asset_fin_rec.exclude_proceeds_from_basis,
          X_retirement_deprn_option      => l_asset_fin_rec.retirement_deprn_option,
          X_tracking_method              => l_asset_fin_rec.tracking_method,
          X_allocate_to_fully_rsv_flag   => l_asset_fin_rec.allocate_to_fully_rsv_flag,
          X_allocate_to_fully_ret_flag   => l_asset_fin_rec.allocate_to_fully_ret_flag,
          X_exclude_fully_rsv_flag       => l_asset_fin_rec.exclude_fully_rsv_flag,
          X_excess_allocation_option     => l_asset_fin_rec.excess_allocation_option,
          X_depreciation_option          => l_asset_fin_rec.depreciation_option,
          X_member_rollup_flag           => l_asset_fin_rec.member_rollup_flag,
          X_ytd_proceeds                 => nvl(l_asset_fin_rec.ytd_proceeds, 0) +
                                            nvl(l_asset_retire_rec.proceeds_of_sale, 0),
          X_ltd_proceeds                 => nvl(l_asset_fin_rec.ltd_proceeds, 0) +
                                            nvl(l_asset_retire_rec.proceeds_of_sale, 0),
          X_eofy_reserve                 => l_asset_fin_rec.eofy_reserve,
          X_terminal_gain_loss_amount    => l_asset_fin_rec.terminal_gain_loss_amount,
          X_ltd_cost_of_removal          => nvl(l_asset_fin_rec.ltd_cost_of_removal, 0) +
                                            nvl(l_asset_retire_rec.cost_of_removal, 0),
          X_cash_generating_unit_id      =>
                                      l_asset_fin_rec.cash_generating_unit_id,
          X_extended_deprn_flag          => l_asset_fin_rec.extended_deprn_flag,          -- Japan Tax phase3
          X_extended_depreciation_period => l_asset_fin_rec.extended_depreciation_period, -- Japan Tax phase3
          X_mrc_sob_type_code            => p_mrc_sob_type_code,
          X_set_of_books_id              => l_asset_hdr_rec.set_of_books_id,
          X_Return_Status                => l_status,
          X_Calling_Fn                   => l_calling_fn,
        X_nbv_at_switch                  => l_asset_fin_rec.nbv_at_switch               ,      -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
        X_prior_deprn_limit_type         => l_asset_fin_rec.prior_deprn_limit_type       ,
        X_prior_deprn_limit_amount       => l_asset_fin_rec.prior_deprn_limit_amount      ,
        X_prior_deprn_limit              => l_asset_fin_rec.prior_deprn_limit              ,
        X_period_counter_fully_rsrved    => l_asset_fin_rec.period_counter_fully_reserved     ,
        X_prior_deprn_method             => l_asset_fin_rec.prior_deprn_method                ,
        X_prior_life_in_months           => l_asset_fin_rec.prior_life_in_months               ,
        X_prior_basic_rate               => l_asset_fin_rec.prior_basic_rate                    ,
        X_prior_adjusted_rate            => l_asset_fin_rec.prior_adjusted_rate         ,             -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
        X_period_counter_fully_extend    => l_asset_fin_rec.period_counter_fully_extended             -- Bug 7576755
        , p_log_level_rec       => p_log_level_rec
          );

    -- Bug:5930979:Japan Tax Reform Project (Start)
    if nvl(fa_cache_pkg.fazccmt_record.GUARANTEE_RATE_METHOD_FLAG,'NO') = 'YES' then

       UPDATE fa_books
       SET rate_in_use = l_rate_in_use
       WHERE asset_id = l_asset_hdr_rec.asset_id
       AND book_type_code = l_asset_hdr_rec.Book_Type_Code
       AND transaction_header_id_out is null;

    end if;
    -- Bug:5930979:Japan Tax Reform Project (End)

   -- Full retirement does not update DH table at all
   -- since DH table only has distribtuions only for corporate book
   if fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE' and
      l_trans_rec.transaction_type_code = 'FULL RETIREMENT' then

      -- full retirement
      for dh_rec in dh_cursor(l_asset_hdr_rec.asset_id,
                              l_asset_hdr_rec.book_type_code) loop

         dh_rec.transaction_units := -1 * dh_rec.units_assigned;

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do fa_distribution_history_pkg.update_row', '', p_log_level_rec => p_log_level_rec); end if;

         fa_distribution_history_pkg.update_row
                       (null,
                        dh_rec.distribution_id,
                        dh_rec.book_type_code,
                        dh_rec.asset_id,
                        dh_rec.units_assigned,
                        dh_rec.date_effective,
                        dh_rec.code_combination_id,
                        dh_rec.location_id,
                        dh_rec.transaction_header_id_in,
                        l_trans_rec.who_info.last_update_date,
                        l_trans_rec.who_info.last_updated_by,
                        dh_rec.date_ineffective,
                        dh_rec.assigned_to,
                        dh_rec.transaction_header_id_out,
                        dh_rec.transaction_units,
                        l_asset_retire_rec.retirement_id,
                        l_trans_rec.who_info.last_update_login,
                        l_calling_fn, p_log_level_rec => p_log_level_rec);
      end loop;

   end if;

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'end ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;

   return TRUE;

EXCEPTION
   /*
    * Added for Group Asset uptake
    */
   when FND_API.G_EXC_UNEXPECTED_ERROR then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;
   /*** End of uptake ***/
   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_sub_regular_retirement;

FUNCTION calculate_gain_loss
        (p_retirement_id              in     number
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   l_return_status                   number := 0;

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.calculate_gain_loss';

BEGIN


   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'p_retirement_id ', p_retirement_id, p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'P') then
       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling Do_Calc_GainLoss_Asset... ', '', p_log_level_rec => p_log_level_rec); end if;
       FA_GAINLOSS_PKG.Do_Calc_GainLoss_Asset
                      (p_retirement_id => p_retirement_id
                      ,x_return_status => l_return_status, p_log_level_rec => p_log_level_rec);
   end if;

   if l_return_status > 0 then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   return TRUE;

EXCEPTION

   when FND_API.G_EXC_UNEXPECTED_ERROR then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

          return FALSE;

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          return FALSE;
END calculate_gain_loss;
-----------------------------------------------------------------------------

PROCEDURE undo_retirement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type)
IS
   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   lv_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   lv_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   lv_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   -- used to loop through tax books
   l_tax_book_tbl      FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index         number;  -- index for tax loop

   l_reporting_flag             varchar2(1);

   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_retirement';

BEGIN

   savepoint undo_retirement;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;

   -- initialize message list if p_init_msg_list is set to TRUE.
   if (FND_API.to_boolean(p_init_msg_list) ) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- override FA:PRINT_DEBUG profile option.
   -- if (p_debug_flag = 'YES') then
   --      fa_debug_pkg.set_debug_flag;
   -- end if;


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := px_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_desc_rec   := null;
   l_asset_type_rec   := null;
   l_period_rec       := null;

   -- ***********************************
   -- **  Call the cache for book
   -- **  and do initial MRC validation
   -- ***********************************

   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_type_rec    => l_asset_type_rec
          ,p_date_effective     => NULL
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_asset_hdr_rec.book_type_code is not null then

        -- call the cache for the primary transaction book
        if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
        lv_asset_hdr_rec := l_asset_hdr_rec;

        -- get the book type code P,R or N
        if not fa_cache_pkg.fazcsob
               (x_set_of_books_id   => l_asset_hdr_rec.set_of_books_id
               ,x_mrc_sob_type_code => l_reporting_flag, p_log_level_rec => g_log_level_rec)
               then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- Error out if the program is submitted from the Reporting Responsibility
        -- No transaction permitted directly on reporting books.
        if l_reporting_flag = 'R' then
             FND_MESSAGE.set_name('GL','MRC_OSP_INVALID_BOOK_TYPE');
             FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;


   end if; -- book_type_code

   -- *********************************************
   -- **  Do basic validation on input parameters
   -- *********************************************

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'before do_validation', '', p_log_level_rec => g_log_level_rec); end if;

   -- validate that all user-entered input parameters are valid
   if not do_validation
          (p_validation_type   => g_undo_retirement
          ,p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,p_asset_retire_rec  => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_calling_fn        => p_calling_fn
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   /* IAC Specific Validation */
   if (FA_IGI_EXT_PKG.IAC_Enabled) then
       if not FA_IGI_EXT_PKG.Validate_Retire_Reinstate(
           p_book_type_code   => l_asset_hdr_rec.book_type_code,
           p_asset_id         => l_asset_hdr_rec.asset_id,
           p_calling_function => l_calling_fn
        ) then
            raise FND_API.G_EXC_ERROR;
       end if;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'after do_validation', '', p_log_level_rec => g_log_level_rec); end if;

   l_trans_rec.transaction_type_code := null;


   -- ***************************
   -- **  Main
   -- ***************************

   if not undo_all_books_retirement
          (p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_type_rec    => l_asset_type_rec   -- bug 8630242
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_ERROR;
   end if;

   /* if book is a corporate book, process cip assets and autocopy */

   -- start processing tax books for cip-in-tax and autocopy
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      lv_trans_rec := l_trans_rec;

      if (l_asset_type_rec.asset_type = 'CIP'
          or l_asset_type_rec.asset_type = 'CAPITALIZED') then

         if not fa_cache_pkg.fazctbk
                (x_corp_book    => l_asset_hdr_rec.book_type_code
                ,x_asset_type   => l_asset_type_rec.asset_type
                ,x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => g_log_level_rec) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         for l_tax_index in 1..l_tax_book_tbl.count loop

           if not FA_ASSET_VAL_PVT.validate_asset_book
                  (p_transaction_type_code      => l_trans_rec.transaction_type_code
                  ,p_book_type_code             => l_tax_book_tbl(l_tax_index)
                  ,p_asset_id                   => l_asset_hdr_rec.asset_id
                  ,p_calling_fn                 => l_calling_fn
                  ,p_log_level_rec              => g_log_level_rec) then

                     null; -- just to ignore the error

           else

             -- cache the book information for the tax book
             if not fa_cache_pkg.fazcbc(x_book => l_tax_book_tbl(l_tax_index),
                                        p_log_level_rec => g_log_level_rec) then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

             lv_trans_rec.transaction_header_id   := null;
             lv_asset_retire_rec                  := null;

             -- to get the new retirement_id for the retrieved tax book
             select retirement_id
             into lv_asset_retire_rec.retirement_id
             from fa_retirements
             where asset_id=lv_asset_hdr_rec.asset_id
               and book_type_code=l_tax_book_tbl(l_tax_index)
               and status = 'PENDING';

             if not undo_all_books_retirement
                    (p_trans_rec         => lv_trans_rec     -- tax
                    ,p_asset_hdr_rec     => lv_asset_hdr_rec -- tax
                    ,p_asset_type_rec    => l_asset_type_rec   -- bug 8630242
                    ,px_asset_retire_rec => lv_asset_retire_rec -- tax
                    ,p_log_level_rec     => g_log_level_rec
                    ) then
                        raise FND_API.G_EXC_ERROR;
             end if;

           end if;

         end loop;


      end if; -- asset_type

   end if; -- book_class


   -- commit if p_commit is TRUE.
   if FND_API.to_boolean(p_commit) then
      COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

   -- return the status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then

          ROLLBACK TO undo_retirement;

          x_return_status := FND_API.G_RET_STS_ERROR;

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => g_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => g_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when FND_API.G_EXC_UNEXPECTED_ERROR then

          ROLLBACK TO undo_retirement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                 , p_log_level_rec => g_log_level_rec);
          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when others then

          ROLLBACK TO undo_retirement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

END undo_retirement;
-----------------------------------------------------------------------------

FUNCTION undo_all_books_retirement
        (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type -- bug 8630242
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   -- Returns the reporting GL set_of_books_ids
   -- associated with the set_of_books_id of given primary book_type_code
   CURSOR sob_cursor(p_book_type_code in varchar2
                    ,p_sob_id         in number) is
   SELECT set_of_books_id AS sob_id
     FROM fa_mc_book_controls
    WHERE book_type_code          = p_book_type_code
      AND primary_set_of_books_id = p_sob_id
      AND enabled_flag            = 'Y';

   -- used for main transaction book
   l_book_class                 varchar2(15);
   l_set_of_books_id            number;
   l_distribution_source_book   varchar2(30);
   l_mc_source_flag             varchar2(1);

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_period_rec        FA_API_TYPES.period_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type; -- bug 8630242

   l_ins_status                 boolean := FALSE;

   l_retirement_id              number(15);

   -- local conversion rate
   l_exchange_date              date;
   l_rate                       number;

   -- msg
   g_msg_name                   varchar2(30);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_all_books_retirement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := p_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_type_rec   := p_asset_type_rec;  -- bug 8630242

   -- *********************************
   -- **  Populate local record types
   -- *********************************
   -- populate rec_types that were not provided by users

   -- pop asset_retire_rec to get the rowid of retirement
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   -- call the cache for the primary transaction book
   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;


   -- pop current period_rec info
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************************************
   -- **  Do asset/book-level validation on transaction
   -- ***************************************************
   -- begin asset/book-level validation on transaction

   -- nothing to do here
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin asset/book-level validation on transaction', '', p_log_level_rec => p_log_level_rec); end if;

   -- ***************************
   -- **  Transaction approval
   -- ***************************

   -- SLA: delete the event
   if not fa_xla_events_pvt.delete_transaction_event
           (p_ledger_id              => l_asset_hdr_rec.set_of_books_id,
            p_transaction_header_id  => l_asset_retire_rec.detail_info.transaction_header_id_in,
            p_book_type_code         => l_asset_hdr_rec.book_type_code,
            p_asset_type             => l_asset_type_rec.asset_type , -- bug 8630242
            p_calling_fn             => 'fa_retirement_pub.undo_all_books_retirement'
            ,p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   -- ***************************
   -- **  Main
   -- ***************************

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling do_sub_retirement for each book/sob', '', p_log_level_rec => p_log_level_rec); end if;

   l_rate := 1;
   if not undo_sub_retirement
          (p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_mrc_sob_type_code => 'P'
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;

   -- MRC LOOP
   -- if this is a primary book, process reporting books(sobs)
   if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

       -- loop thourgh reporting set of books
       for sob_rec in sob_cursor(l_asset_hdr_rec.book_type_code
                                ,l_asset_hdr_rec.set_of_books_id) loop

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in sob_id loop', '', p_log_level_rec => p_log_level_rec); end if;

         l_asset_hdr_rec.set_of_books_id := sob_rec.sob_id;

         if not fa_cache_pkg.fazcbcs(x_book => l_asset_hdr_rec.book_type_code,
                                     x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                     p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return FALSE;
         end if;

         if not undo_sub_retirement
                (p_trans_rec         => l_trans_rec
                ,p_asset_hdr_rec     => l_asset_hdr_rec
                ,px_asset_retire_rec => l_asset_retire_rec
                ,p_mrc_sob_type_code => 'R'
                ,p_log_level_rec     => p_log_level_rec
                ) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;


       end loop;

   end if;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END undo_all_books_retirement;
------------------------------------------------------------------------------

FUNCTION undo_sub_retirement
   (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
   ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_mrc_sob_type_code          in     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   transfer_id          number(15);
   l_trans_units        number;
   l_units_assigned     number;

   l_partial_unit_ret_flag varchar2(1) := 'N';

   l_old_cost           number;
   l_old_units          number;
   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;

   cursor get_transfer_id is
      select transaction_header_id_out
            ,transaction_units
            ,units_assigned
      from fa_distribution_history
      where retirement_id = l_asset_retire_rec.retirement_id;

   cursor adj_def is
      select rowid
      from fa_adjustments
      where asset_id = p_asset_hdr_rec.asset_id
      and transaction_header_id = transfer_id
      and source_type_code = 'TRANSFER'
      and adjustment_type in ('COST', 'RESERVE', 'REVAL RESERVE');

   l_adj_rowid    rowid;

   /*
    * Check to see previous retirement was source line retirement or not
    */
   cursor c_inv_trx_id (c_thid number)is
      select invoice_transaction_id
      from   fa_transaction_headers
      where  transaction_header_id = c_thid;

   cursor get_cost_before_ret(c_asset_id number, c_book varchar2, c_ret_id number, c_reporting_flag varchar2) is
      select cost
      from fa_books
      where asset_id = c_asset_id
        and book_type_code = c_book
        and retirement_id = c_ret_id
        and c_reporting_flag <> 'R'
      union
      select cost
      from fa_mc_books
      where asset_id = c_asset_id
        and book_type_code = c_book
        and retirement_id = c_ret_id
        and c_reporting_flag = 'R';

   l_invoice_transaction_id    number;  -- Local variable to store return value of c_inv_trx_id

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_sub_retirement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := p_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;

   -- pop asset_retire_rec to get the rowid of retirement
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => p_mrc_sob_type_code,
           p_set_of_books_id => p_asset_hdr_rec.set_of_books_id
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   -- pop asset_desc_rec
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_desc_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_desc_rec    => l_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code     => p_mrc_sob_type_code
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'after pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'asset_hdr: set_of_books_id: ', l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);
   end if;

   /*
    * Take care source line
    */
   OPEN  c_inv_trx_id(l_asset_retire_rec.detail_info.transaction_header_id_in);
   FETCH c_inv_trx_id into l_invoice_transaction_id;
   CLOSE c_inv_trx_id;

   if (l_invoice_transaction_id is not null) then
      if (p_mrc_sob_type_code = 'R') then

         DELETE FROM FA_MC_ASSET_INVOICES
         WHERE       ASSET_ID = l_asset_hdr_rec.asset_id
         AND         INVOICE_TRANSACTION_ID_IN = l_invoice_transaction_id;

         UPDATE FA_MC_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = '',
                DATE_INEFFECTIVE = ''
         WHERE  ASSET_ID = l_asset_hdr_rec.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id;

      else

         DELETE FROM FA_ASSET_INVOICES
         WHERE       ASSET_ID = l_asset_hdr_rec.asset_id
         AND         INVOICE_TRANSACTION_ID_IN = l_invoice_transaction_id;

         UPDATE FA_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = '',
                DATE_INEFFECTIVE = ''
         WHERE  ASSET_ID = l_asset_hdr_rec.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id;

         /*
          * This needs to happen only once so do this for primary book.
          */
         DELETE FROM FA_INVOICE_TRANSACTIONS
         WHERE       INVOICE_TRANSACTION_ID = l_invoice_transaction_id;

      end if; --(p_mrc_sob_type_code = 'R')


   end if; -- (l_invoice_transaction_id is not null)

   /*
    * Added for Group Asset uptake
    */
   if (l_asset_fin_rec.group_asset_id is not null) then
      if (l_asset_retire_rec.recognize_gain_loss = 'NO') then
         if not FA_RETIREMENT_PVT.UNDO_RETIREMENT_REINSTATEMENT(
                    p_transaction_header_id =>l_asset_retire_rec.detail_info.transaction_header_id_in,
                    p_asset_hdr_rec         => l_asset_hdr_rec,
                    p_group_asset_id        => l_asset_fin_rec.group_asset_id,
                    p_set_of_books_id       => l_asset_hdr_rec.set_of_books_id,
                    p_mrc_sob_type_code     => p_mrc_sob_type_code,
                    p_calling_fn            => l_calling_fn, p_log_level_rec => p_log_level_rec) then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      elsif (p_mrc_sob_type_code <> 'R') then
         update fa_books
            set adjustment_required_status = 'NONE'
          where asset_id = l_asset_fin_rec.group_asset_id
            and book_type_code = l_asset_hdr_rec.book_type_code
            and transaction_header_id_out is null;
      end if;
   end if;
           /*** End of uptake ***/

   -- l_trans_rec.transaction_header_id should be trx_header_id
   -- of PARTIAL RETIREMENT or FULL RETIREMENT row in TH table

   OPEN  get_cost_before_ret(l_asset_hdr_rec.asset_id,
                             l_asset_hdr_rec.book_type_code,
                             l_asset_retire_rec.retirement_id,
                             p_mrc_sob_type_code);
   FETCH get_cost_before_ret into l_old_cost;
   CLOSE get_cost_before_ret;

   -- Added for bug 7125732
   if l_asset_retire_rec.units_retired is not null then
      BEGIN
        SELECT prev.units
        INTO   l_old_units
        FROM   fa_asset_history prev,
               fa_retirements ret
        WHERE prev.asset_id = l_asset_hdr_rec.asset_id
        AND   prev.transaction_header_id_out = ret.transaction_header_id_in
        AND   ret.retirement_id = l_asset_retire_rec.retirement_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_old_units := l_asset_retire_rec.units_retired;
      END;
    else
 -- added for Bug# 5098320 get the current units of the asset from fa_asset_history table
           if not FA_UTIL_PVT.get_current_units
                  (p_calling_fn    => l_calling_fn
                  ,p_asset_id      => l_asset_hdr_rec.asset_id
                  ,x_current_units => l_old_units
                  , p_log_level_rec => p_log_level_rec) then
                      g_msg_name := null;
                      g_token1 := null;
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
    end if;
   -- End of bug 7125732

   if p_log_level_rec.statement_level then
     fa_debug_pkg.add(l_calling_fn, 'Asset_Id:', l_asset_hdr_rec.Asset_Id, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_old_units', l_old_units, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code:', p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'Cost before ret:', l_old_cost, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.cost_retired:', l_asset_retire_rec.cost_retired, p_log_level_rec => p_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.units_retired:', l_asset_retire_rec.units_retired, p_log_level_rec => p_log_level_rec);
   end if;
   -- Bug#2306068: Fixed wrong check of partial unit retirement
   -- 0 cost condition added to allow for partial unit retirements/reinstatements
   -- on assets with 0 cost.
   /* Bug# 5098320: undo retirement for zero cost asset was failing.
      changed the if condition to prevent that.
   if (
        (l_asset_retire_rec.units_retired is not null)
        and ( (l_asset_retire_rec.cost_retired <> l_old_cost) or
                (l_asset_retire_rec.cost_retired = 0 and l_old_cost = 0))
      ) then*/
   if (
        (l_asset_retire_rec.units_retired <> l_old_units)
        and ((l_asset_retire_rec.cost_retired <> l_old_cost) or
                (l_asset_retire_rec.cost_retired = 0 and l_old_cost = 0))
      ) then
      -- partial unit retirement

        -- l_trans_rec.transaction_header_id should be trx_header_id
        -- of PARTIAL RETIREMENT row in TH table

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add(l_calling_fn, 'deleting a partial unit retirement', '', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'FA_BOOKS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'trx_id: ', l_asset_retire_rec.detail_info.transaction_header_id_in, p_log_level_rec => p_log_level_rec);
        end if;
        FA_BOOKS_PKG.DELETE_ROW
                        (X_Transaction_Header_Id_In =>
                                        l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(l_calling_fn, 'FA_BOOKS_PKG.REACTIVATE_ROW', '', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'trx_id: ', l_asset_retire_rec.detail_info.transaction_header_id_in, p_log_level_rec => p_log_level_rec);
        end if;
        FA_BOOKS_PKG.REACTIVATE_ROW
                        (X_Transaction_Header_Id_Out =>
                                        l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_BOOKS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'ROW: ', l_asset_retire_rec.detail_info.row_id, p_log_level_rec => p_log_level_rec); end if;
        FA_RETIREMENTS_PKG.DELETE_ROW
                        (X_Rowid => l_asset_retire_rec.detail_info.row_id,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add(l_calling_fn, 'Asset_Id:', l_asset_hdr_rec.Asset_Id, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'Book_Type_Code:', l_asset_hdr_rec.Book_Type_Code, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'p_mrc_sob_type_code:', p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'book class:', fa_cache_pkg.fazcbc_record.book_class, p_log_level_rec => p_log_level_rec);
        end if;

        if (p_mrc_sob_type_code <> 'R') then

           if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'before get_transfer_id', '', p_log_level_rec => p_log_level_rec); end if;

              l_partial_unit_ret_flag := 'N';

              open get_transfer_id;

              loop

                fetch get_transfer_id
                into transfer_id
                     ,l_trans_units
                     ,l_units_assigned;

                EXIT when get_transfer_id%NOTFOUND;

                /* Fix for bug#3246439: Partial unit transfer issue
                                        with multi-distributed asset */
              if (l_trans_units <> l_units_assigned * -1) then
                   l_partial_unit_ret_flag := 'Y';
                end if;

              end loop;

              close get_transfer_id;


              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'after get_transfer_id', '', p_log_level_rec => p_log_level_rec); end if;

            if (l_partial_unit_ret_flag='Y') then

                  --delete a row only if a distribution is partially retired
                  if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_DISTRIBUTION_HISTORY_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
                  FA_DISTRIBUTION_HISTORY_PKG.DELETE_ROW
                        (X_Asset_Id     => l_asset_hdr_rec.Asset_Id,
                        X_Book_Type_Code=> l_asset_hdr_rec.Book_Type_Code,
                        X_Transaction_Header_Id => transfer_id,
                        X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

              end if;

              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_DISTRIBUTION_HISTORY_PKG.REACTIVATE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
              FA_DISTRIBUTION_HISTORY_PKG.REACTIVATE_ROW
                        (X_Transaction_Header_Id_Out =>
                                        transfer_id,
                        X_Asset_Id      => l_asset_hdr_rec.Asset_Id,
                        X_Book_Type_Code=> l_asset_hdr_rec.Book_Type_Code,
                        X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_ASSET_HISTORY_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
              FA_ASSET_HISTORY_PKG.DELETE_ROW
                        (X_Transaction_Header_Id_In =>
                                l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_Asset_Id   => l_asset_hdr_rec.Asset_Id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_ASSET_HISTORY_PKG.REACTIVATE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
              FA_ASSET_HISTORY_PKG.REACTIVATE_ROW
                        (X_Transaction_Header_Id_Out =>
                                l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_Asset_Id   => l_asset_hdr_rec.Asset_Id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_ADDITIONS_PKG.UPDATE_UNITS', '', p_log_level_rec => p_log_level_rec); end if;
              FA_ADDITIONS_PKG.UPDATE_UNITS
                        (X_Asset_Id => l_asset_hdr_rec.Asset_Id,

                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_TRANSFER_DETAILS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
              FA_TRANSFER_DETAILS_PKG.DELETE_ROW
                        (X_Transfer_Header_Id => transfer_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

           end if; -- if corporate

           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_TRANSACTION_HEADERS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
           FA_TRANSACTION_HEADERS_PKG.DELETE_ROW -- delete PARTIAL RETIREMENT row
                        (X_Transaction_Header_Id =>
                                l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_TRANSACTION_HEADERS_PKG.DELETE_ROW -- delete TRANSFER OUT row', '', p_log_level_rec => p_log_level_rec); end if;
           FA_TRANSACTION_HEADERS_PKG.DELETE_ROW -- delete TRANSFER OUT row
                        (X_Transaction_Header_Id =>
                                transfer_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        end if; -- if reporting_flag <> 'R'

        -- Remove any cost and reserve adjustment rows
        -- if UNDOing PARTIAL UNIT RETIREMENT

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin - deleting fa_adjustments', '', p_log_level_rec => p_log_level_rec); end if;

        open adj_def;

        begin

          loop
               fetch adj_def into l_adj_rowid;

               exit when adj_def%NOTFOUND;

               if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_ADJUSTMENTS_PKG.delete_row', '', p_log_level_rec => p_log_level_rec); end if;
               FA_ADJUSTMENTS_PKG.delete_row(
                          X_Rowid       => l_adj_rowid,
                          X_Asset_Id    => l_asset_hdr_rec.asset_id,
                          X_Calling_Fn  => l_calling_fn,
                          X_mrc_sob_type_code => p_mrc_sob_type_code,
                          X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                          p_log_level_rec => p_log_level_rec);

          end loop;

        exception
          when others then null;
        end;

        close adj_def;

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'done - deleting fa_adjustments', '', p_log_level_rec => p_log_level_rec); end if;


   else -- if not partial unit retirement

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'not a partial unit retirement', '', p_log_level_rec => p_log_level_rec); end if;

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_BOOKS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
        FA_BOOKS_PKG.DELETE_ROW
                                (X_Transaction_Header_Id_In =>
                                l_asset_retire_rec.detail_info.transaction_header_id_in,
                                X_mrc_sob_type_code => p_mrc_sob_type_code,
                                X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                                X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_BOOKS_PKG.REACTIVATE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
        FA_BOOKS_PKG.REACTIVATE_ROW
                        (X_Transaction_Header_Id_Out =>
                                        l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add(l_calling_fn, 'FA_RETIREMENTS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'ROW: ', l_asset_retire_rec.detail_info.row_id, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, 'retirement_id: ', l_asset_retire_rec.retirement_id, p_log_level_rec => p_log_level_rec);
        end if;
        FA_RETIREMENTS_PKG.DELETE_ROW
                        (X_Rowid      => l_asset_retire_rec.detail_info.row_id,
                         X_mrc_sob_type_code => p_mrc_sob_type_code,
                         X_set_of_books_id   => l_asset_hdr_rec.set_of_books_id,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        if (p_mrc_sob_type_code <> 'R') then

           if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
                if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_DISTRIBUTION_HISTORY_PKG.REACTIVATE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
                FA_DISTRIBUTION_HISTORY_PKG.REACTIVATE_ROW
                        (X_Asset_Id     => l_asset_hdr_rec.asset_id,
                         X_Book_Type_Code=> l_asset_hdr_rec.book_type_code,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           end if; -- if corporate

           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'FA_TRANSACTION_HEADERS_PKG.DELETE_ROW', '', p_log_level_rec => p_log_level_rec); end if;
           FA_TRANSACTION_HEADERS_PKG.DELETE_ROW
                        (X_Transaction_Header_Id =>
                                l_asset_retire_rec.detail_info.transaction_header_id_in,
                         X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

        end if; -- reporting_flag

   end if;

   return TRUE;

EXCEPTION
   /*
    * Added for Group Asset uptake
    */
    when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Make sure to close curosr opened for source line retirement
        if c_inv_trx_id%ISOPEN then
          CLOSE c_inv_trx_id;
        end if;

        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
        return FALSE;
   /*** End of uptake ***/
    when others then

        close adj_def;

        -- Make sure to close curosr opened for source line retirement
        if c_inv_trx_id%ISOPEN then
          CLOSE c_inv_trx_id;
        end if;

        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
        return FALSE;

END undo_sub_retirement;
-----------------------------------------------------------------------------

-- In addition to the existing functionalities,
-- Do_reinstatement will handle asset_dist_tbl for distributions

-- Table access
-- 1. insert into TH
-- 2. update RET

-- AAA
-- Users are allowed to do reinstatement on an asset whose retirement status
-- is set to 'PROCESSED', which indicates
-- 'Retirement and Calculate Gain/Loss are processed'.

-- undo_retirement, do_resinsatement and undo_reinstatement allow
-- users to give them either asset_id/book or retirement_id
-- as a target for the transactions while do_retirement allows only
-- asset_id/book parameter.

PROCEDURE do_reinstatement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
   ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
   ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type)
IS
   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   lv_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   lv_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   lv_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   -- used for loop through tax books
   l_tax_book_tbl     FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index        number;

   cursor tde_cursor is
   select max(th.transaction_date_entered)
   from fa_deprn_periods       dp
       ,fa_transaction_headers th
       ,fa_books               bk
   where dp.book_type_code = l_asset_hdr_rec.book_type_code
     and dp.period_close_date is null
     and bk.book_type_code = dp.book_type_code
     and bk.asset_id       = l_asset_hdr_rec.asset_id
     and th.date_effective
         between bk.date_effective
             and nvl(bk.date_ineffective,sysdate)
     and th.date_effective
         between dp.period_open_date
             and nvl(dp.period_close_date,sysdate)
     and th.book_type_code = dp.book_type_code
     and th.asset_id = bk.asset_id
     and th.transaction_type_code like '%RETIREMENT';

   l_transaction_date_entered   date;
   l_reporting_flag             varchar2(1);

   l_retirement_id              number(15);
   l_calculate_gain_loss_flag   varchar2(1);

   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

   l_ins_status                 boolean := FALSE;

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_reinstatement';

BEGIN

   savepoint do_reinstatement;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;


   -- initialize message list if p_init_msg_list is set to TRUE.
   if (FND_API.to_boolean(p_init_msg_list) ) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := px_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;

   l_retirement_id    := l_asset_retire_rec.retirement_id;

   -- *********************************
   -- **  Populate local record types
   -- *********************************

   -- pop asset_retire_rec to get the rowid of retirement
      if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_retire_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   if g_log_level_rec.statement_level then
     fa_debug_pkg.add(l_calling_fn, 'asset_id:', l_asset_hdr_rec.asset_id, p_log_level_rec => g_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'book_type_code:', l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'fa_ret retirement_id:', l_asset_retire_rec.retirement_id, p_log_level_rec => g_log_level_rec);
   end if;

   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /*Bug# 8527619 */
   if not FA_UTIL_PVT.get_asset_fin_rec
                    (p_asset_hdr_rec         => l_asset_hdr_rec, /* 8808629*/
                     px_asset_fin_rec        => l_asset_fin_rec,
                     p_transaction_header_id => NULL,
                     p_mrc_sob_type_code     => 'P',
                     p_log_level_rec           => g_log_level_rec) then
      raise FND_API.G_EXC_ERROR;
   end if;

   -- ***************************
   -- **  Transaction approval
   -- ***************************
   -- common for all types
   -- bug 1230315... adding FA_TRX_APPROVAL_PKG for all retirement
   -- transactions

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'call trx approval pkg - faxcat', '', p_log_level_rec => g_log_level_rec); end if;
   l_ins_status := FA_TRX_APPROVAL_PKG.faxcat
                   (x_book              => l_asset_hdr_rec.book_type_code
                   ,x_asset_id          => l_asset_hdr_rec.asset_id
                   ,x_trx_type          => 'REINSTATEMENT'
                   ,x_trx_date          => l_asset_retire_rec.date_retired
                   ,x_init_message_flag => 'NO', p_log_level_rec => g_log_level_rec);
   if not l_ins_status then
        g_msg_name := 'error msg name-after trx_app';
        raise FND_API.G_EXC_ERROR;
   end if;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'l_asset_retire_rec.recognize_gain_loss',
                  l_asset_retire_rec.recognize_gain_loss, g_log_level_rec);
   end if;
   IF (l_asset_fin_rec.group_asset_id is not null
      and l_asset_retire_rec.recognize_gain_loss = 'YES') THEN
      l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;
   END IF;

   l_calculate_gain_loss_flag := l_asset_retire_rec.calculate_gain_loss;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code  => 'P'
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if (l_asset_fin_rec.group_asset_id is not null) then
      l_ins_status := FA_TRX_APPROVAL_PKG.faxcat
                   (x_book              => l_asset_hdr_rec.book_type_code
                   ,x_asset_id          => l_asset_fin_rec.group_asset_id
                   ,x_trx_type          => 'ADJUSTMENT'
                   ,x_trx_date          => l_asset_retire_rec.date_retired
                   ,x_init_message_flag => 'NO', p_log_level_rec => g_log_level_rec);
      if not l_ins_status then
        g_msg_name := 'error msg name-after trx_app group';
        raise FND_API.G_EXC_ERROR;
      end if;

   end if;

   -- ***********************************
   -- **  Call the cache for book
   -- **  and do initial MRC validation
   -- ***********************************

   if l_asset_hdr_rec.book_type_code is not null then

        -- call the cache for the primary transaction book
        if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- l_book_class               := fa_cache_pkg.fazcbc_record.book_class;
        -- l_set_of_books_id          := fa_cache_pkg.fazcbc_record.set_of_books_id;
        -- l_distribution_source_book := fa_cache_pkg.fazcbc_record.distribution_source_book;
        -- l_mc_source_flag           := fa_cache_pkg.fazcbc_record.mc_source_flag;

        l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

        -- get the book type code P,R or N
        if not fa_cache_pkg.fazcsob
               (x_set_of_books_id   => l_asset_hdr_rec.set_of_books_id
               ,x_mrc_sob_type_code => l_reporting_flag, p_log_level_rec => g_log_level_rec)
               then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- Error out if the program is submitted from the Reporting Responsibility
        -- No transaction permitted directly on reporting books.
        if l_reporting_flag = 'R' then
             FND_MESSAGE.set_name('GL','MRC_OSP_INVALID_BOOK_TYPE');
             FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        --Check if impairment has been posted in current period.
        if not FA_ASSET_VAL_PVT.validate_impairment_exists
             (p_asset_id           => l_asset_hdr_rec.asset_id,
              p_book               => l_asset_hdr_rec.book_type_code,
              p_mrc_sob_type_code  => 'P',
              p_set_of_books_id    => l_asset_hdr_rec.set_of_books_id,
              p_log_level_rec      => g_log_level_rec) then

           raise FND_API.G_EXC_ERROR;
        end if;

   end if; -- book_type_code

   -- pop current period_rec info
   if g_log_level_rec.statement_level then
     fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => g_log_level_rec);
     fa_debug_pkg.add(l_calling_fn, 'book:',  l_asset_retire_rec.detail_info.book_type_code, p_log_level_rec => g_log_level_rec);
   end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'passed pop period_rec', '', p_log_level_rec => g_log_level_rec); end if;

   -- pop asset_type_rec
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_type_rec', '', p_log_level_rec => g_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_type_rec    => l_asset_type_rec
          ,p_date_effective     => NULL
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- **********************************************
   -- **  Do asset-level validation on transaction
   -- **********************************************
   -- check that the status of the retirement to reinstate is PROCESSED

   -- get the latest transaction_date_entered from TH table
   open tde_cursor;
   fetch tde_cursor
         into l_trans_rec.transaction_date_entered;
   close tde_cursor;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'passed tde_cursor', '', p_log_level_rec => g_log_level_rec); end if;

   -- default transaction_date_entered to the current period if it is null
   if l_trans_rec.transaction_date_entered is null then

        -- default date_retired to the current period
        l_trans_rec.transaction_date_entered
          := greatest(least(l_period_rec.calendar_period_close_date, sysdate)
                     ,l_period_rec.calendar_period_open_date
                     );
   end if;

   if g_log_level_rec.statement_level then
       fa_debug_pkg.add(l_calling_fn, 'passed transaction_date_entered', '', p_log_level_rec => g_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, 'Transaction Date: ', l_trans_rec.transaction_date_entered , p_log_level_rec => g_log_level_rec);
   end if;

   -- *********************************************
   -- **  Do validation
   -- *********************************************
   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'before validation', '', p_log_level_rec => g_log_level_rec); end if;
   -- validate that all user-entered input parameters are valid
   if not do_validation
          (p_validation_type   => g_reinstatement
          ,p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,p_asset_retire_rec  => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_calling_fn        => p_calling_fn
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /* IAC Specific Validation */
   if (FA_IGI_EXT_PKG.IAC_Enabled) then
       if not FA_IGI_EXT_PKG.Validate_Retire_Reinstate(
           p_book_type_code   => l_asset_hdr_rec.book_type_code,
           p_asset_id         => l_asset_hdr_rec.asset_id,
           p_calling_function => l_calling_fn
        ) then
            raise FND_API.G_EXC_ERROR;
       end if;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'after validation', '', p_log_level_rec => g_log_level_rec); end if;

   -- ***************************
   -- **  Main
   -- ***************************

   if not do_all_books_reinstatement
          (px_trans_rec        => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_ERROR;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'after do_all_books_reinstatement', '', p_log_level_rec => g_log_level_rec); end if;


   /* if book is a corporate book, process cip assets and autocopy */

   -- start processing tax books for cip-in-tax and autocopy
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      lv_trans_rec := l_trans_rec;
      lv_asset_hdr_rec := l_asset_hdr_rec;
      lv_asset_retire_rec := l_asset_retire_rec;

      if (l_asset_type_rec.asset_type = 'CIP'
          or l_asset_type_rec.asset_type = 'CAPITALIZED') then

         if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Asset type: ', l_asset_type_rec.asset_type, p_log_level_rec => g_log_level_rec); end if;

         if not fa_cache_pkg.fazctbk
                (x_corp_book    => l_asset_hdr_rec.book_type_code
                ,x_asset_type   => l_asset_type_rec.asset_type
                ,x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => g_log_level_rec) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         for l_tax_index in 1..l_tax_book_tbl.count loop

           if g_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'entered loop for tax books', '', p_log_level_rec => g_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'selected tax book: ', l_tax_book_tbl(l_tax_index));
           end if;

           if not FA_ASSET_VAL_PVT.validate_asset_book
                  (p_transaction_type_code      => l_trans_rec.transaction_type_code
                  ,p_book_type_code             => l_tax_book_tbl(l_tax_index)
                  ,p_asset_id                   => l_asset_hdr_rec.asset_id
                  ,p_calling_fn                 => l_calling_fn
                  ,p_log_level_rec              => g_log_level_rec) then

                     null; -- just to ignore the error
                if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'failed in validate_asset_book ', '', p_log_level_rec => g_log_level_rec); end if;

           else

             -- cache the book information for the tax book
             if not fa_cache_pkg.fazcbc(x_book => l_tax_book_tbl(l_tax_index),
                                        p_log_level_rec => g_log_level_rec) then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

             -- ? Excerpt from Brad's comment on this part - need more investigation:
             -- 'May need to set the transaction date, trx_type, subtype here as well
             --  based on the open period and settings for each tax book in the loop'

             lv_asset_hdr_rec.book_type_code           := l_tax_book_tbl(l_tax_index);
             lv_trans_rec.source_transaction_header_id := l_trans_rec.transaction_header_id;
             lv_trans_rec.transaction_header_id        := null;

             select max(retirement_id)
             into lv_asset_retire_rec.retirement_id
             from fa_retirements
             where asset_id=l_asset_hdr_rec.asset_id
               and book_type_code=lv_asset_hdr_rec.book_type_code;

             if g_log_level_rec.statement_level then
               fa_debug_pkg.add(l_calling_fn, 'calling do_all_books_reinstatement for tax book', '', p_log_level_rec => g_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'retirement_id for TAX:', lv_asset_retire_rec.retirement_id, p_log_level_rec => g_log_level_rec);
             end if;

             if not do_all_books_reinstatement
                    (px_trans_rec        => lv_trans_rec     -- tax
                    ,p_asset_hdr_rec     => lv_asset_hdr_rec -- tax
                    ,p_asset_desc_rec    => l_asset_desc_rec
                    ,p_asset_type_rec    => l_asset_type_rec
                    ,p_asset_fin_rec     => l_asset_fin_rec
                    ,px_asset_retire_rec => lv_asset_retire_rec
                    ,p_asset_dist_tbl    => l_asset_dist_tbl
                    ,p_subcomp_tbl       => l_subcomp_tbl
                    ,p_inv_tbl           => l_inv_tbl
                    ,p_period_rec        => l_period_rec
                    ,p_log_level_rec     => g_log_level_rec
                    ) then
                        raise FND_API.G_EXC_ERROR;
             end if;


             if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'passed do_all_books_reinstatement for tax book', '', p_log_level_rec => g_log_level_rec); end if;
           end if;

         end loop;


      end if; -- asset_type

   end if; -- book_class

   -- submit calculate_gain_loss programs if flag is set

   if l_calculate_gain_loss_flag = FND_API.G_TRUE then

        if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'submit calculate gain/loss program', '', p_log_level_rec => g_log_level_rec); end if;
        if not calculate_gain_loss
               (p_retirement_id     => l_retirement_id
               ,p_mrc_sob_type_code => 'P'
               ,p_log_level_rec     => g_log_level_rec
               ) then
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

   end if;

   -- commit if p_commit is TRUE.
   if FND_API.to_boolean(p_commit) then
      COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

   -- return the status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then

          ROLLBACK TO do_reinstatement;

          x_return_status := FND_API.G_RET_STS_ERROR;

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => g_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => g_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when FND_API.G_EXC_UNEXPECTED_ERROR then

          ROLLBACK TO do_reinstatement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                 , p_log_level_rec => g_log_level_rec);
          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when others then

          ROLLBACK TO do_reinstatement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

END do_reinstatement;
-----------------------------------------------------------------------------

FUNCTION do_all_books_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
-- will return retirement_id of asset_retire_rec
IS

   -- Returns the reporting GL set_of_books_ids
   -- associated with the set_of_books_id of given primary book_type_code
   CURSOR sob_cursor(p_book_type_code in varchar2
                    ,p_sob_id         in number) is
   SELECT set_of_books_id AS sob_id
     FROM fa_mc_book_controls
    WHERE book_type_code          = p_book_type_code
      AND primary_set_of_books_id = p_sob_id
      AND enabled_flag            = 'Y';

   -- used for main transaction book
   l_book_class                 varchar2(15);
   l_set_of_books_id            number;
   l_distribution_source_book   varchar2(30);
   l_mc_source_flag             varchar2(1);

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   -- local individual variables
   l_latest_trans_date          date;

   -- local conversion rate
   l_exchange_date              date;
   l_rate                       number;

   -- msg
   g_msg_name                   varchar2(30);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_all_books_reinstatement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_desc_rec   := p_asset_desc_rec;
   l_asset_type_rec   := p_asset_type_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;

   -- *********************************
   -- **  Populate local record types
   -- *********************************
   -- populate rec_types that were not provided by users

   -- call the cache for the primary transaction book
   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- pop current period_rec info
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************************************
   -- **  Do asset/book-level validation on transaction
   -- ***************************************************
   -- begin asset/book-level validation on transaction

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin asset/book-level validation on transaction', '', p_log_level_rec => p_log_level_rec); end if;

   -- check if there is an add-to-asset transaction pending
   -- Users must post their mass additions before they can retire the asset
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if there is an add-to-asset transaction pending', '', p_log_level_rec => p_log_level_rec); end if;
   if FA_ASSET_VAL_PVT.validate_add_to_asset_pending
      (p_asset_id   => l_asset_hdr_rec.asset_id
      ,p_book       => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => p_log_level_rec) then
          -- Users must post their mass additions before they can retire the asset
          g_msg_name := 'FA_RET_CANT_RET_INCOMPLETE_ASS';
          raise FND_API.G_EXC_ERROR;
   end if;

   -- check if another retirement/reinstatement already pending
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if another retirement/reinstatement already pending', '', p_log_level_rec => p_log_level_rec); end if;
   if FA_ASSET_VAL_PVT.validate_ret_rst_pending
      (p_asset_id   => l_asset_hdr_rec.asset_id
      ,p_book       => l_asset_hdr_rec.book_type_code
      , p_log_level_rec => p_log_level_rec) then
          g_msg_name := 'FA_SHARED_PENDING_RETIREMENT';
          raise FND_API.G_EXC_ERROR;
   end if;

   -- check if date_retired is valid in terms of trx date
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if date_retired is valid in terms of trx date', '', p_log_level_rec => p_log_level_rec); end if;
   if l_asset_retire_rec.date_retired is not null then

        -- no transactions except Retirements and Reinstatements may be
        -- dated after the latest trx date
        if not FA_UTIL_PVT.get_latest_trans_date
               (p_calling_fn        => l_calling_fn
               ,p_asset_id          => l_asset_hdr_rec.asset_id
               ,p_book              => l_asset_hdr_rec.book_type_code
               ,x_latest_trans_date => l_latest_trans_date
               , p_log_level_rec => p_log_level_rec) then
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- Bug3130595
        --  Removing following check since we need to allow reinstatement
        --  of retirement even there are another trx in between ret and reinstatement
        --
        --if l_asset_retire_rec.date_retired < l_latest_trans_date then
        --     g_msg_name := 'FA_SHARED_OTHER_TRX_FOLLOW';
        --     raise FND_API.G_EXC_ERROR;
        --end if;

   end if; -- date_retired

   -- Pop the transaction_header_id for the REINSTATEMENT row
   select fa_transaction_headers_s.nextval
   into   l_trans_rec.transaction_header_id
   from   dual;

   -- SLA UPTAKE
   -- moving original event creation into do_sub_regular_reinstatement

   -- ***************************
   -- **  Main
   -- ***************************

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling do_sub_retirement for each book/sob', '', p_log_level_rec => p_log_level_rec); end if;

   l_rate := 1;
   if not do_sub_reinstatement
          (px_trans_rec        => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_rate              => l_rate
          ,p_mrc_sob_type_code => 'P'
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;

   -- MRC LOOP
   -- if this is a primary book, process reporting books(sobs)
   if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

       -- loop thourgh reporting set of books
       for sob_rec in sob_cursor(l_asset_hdr_rec.book_type_code
                                ,l_asset_hdr_rec.set_of_books_id) loop

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in sob_id loop', '', p_log_level_rec => p_log_level_rec); end if;

         l_asset_hdr_rec.set_of_books_id := sob_rec.sob_id;

         if not fa_cache_pkg.fazcbcs(x_book => l_asset_hdr_rec.book_type_code,
                                     x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                     p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;
         end if;

         -- ? code for conversion rate when invoice trx is involved will be
         -- discussed later
         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'get currency conversion rates', '', p_log_level_rec => p_log_level_rec); end if;
         -- if l_inv_trans_rec.transaction_type is null then

         /******* routine to get existing rates when invoice trx is involved
         -- if (l_inv_rec.source_transaction_header_id is not null)
             and (fa_cache_pkg.fazcbc_record.book_class = 'TAX') then

               if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling get_existing_rate', '', p_log_level_rec => p_log_level_rec); end if;

               -- get the exchange rate from the corporate transaction
               if not FA_MC_UTIL_PVT.get_existing_rate
                  (p_set_of_books_id        => sob_rec.sob_id,
                   p_transaction_header_id  => l_trans_rec.source_transaction_header_id,
                   px_rate                  => l_rate
                  , p_log_level_rec => p_log_level_rec) then return false;
               end if;

         *******/

         if TRUE then

               l_exchange_date    := l_trans_rec.transaction_date_entered;

               if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling get_trx_rate', '', p_log_level_rec => p_log_level_rec); end if;

               if not FA_MC_UTIL_PVT.get_trx_rate
                  (p_prim_set_of_books_id       => fa_cache_pkg.fazcbc_record.set_of_books_id,
                   p_reporting_set_of_books_id  => sob_rec.sob_id,
                   px_exchange_date             => l_exchange_date,
                   p_book_type_code             => l_asset_hdr_rec.book_type_code,
                   px_rate                      => l_rate
                  , p_log_level_rec => p_log_level_rec)then return false;
               end if;

         end if;

         -- else
            -- ? code for conversion rate when invoice trx is involved will be
            -- discussed later
         -- end if; -- if invoice trx is not involved


         if not do_sub_reinstatement
                (px_trans_rec        => l_trans_rec
                ,p_asset_hdr_rec     => l_asset_hdr_rec
                ,p_asset_desc_rec    => l_asset_desc_rec
                ,p_asset_type_rec    => l_asset_type_rec
                ,p_asset_fin_rec     => l_asset_fin_rec
                ,px_asset_retire_rec => l_asset_retire_rec
                ,p_asset_dist_tbl    => l_asset_dist_tbl
                ,p_subcomp_tbl       => l_subcomp_tbl
                ,p_inv_tbl           => l_inv_tbl
                ,p_period_rec        => l_period_rec
                ,p_rate              => l_rate
                ,p_mrc_sob_type_code => 'R'
                ,p_log_level_rec     => p_log_level_rec
                ) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         -- ? may need to call MC_FA_UTILITIES_PKG.insert_books_rates procedure
         -- to process invoice trx

       end loop;

   end if;

   px_trans_rec := l_trans_rec;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_all_books_reinstatement;


FUNCTION do_sub_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_rate                       in     number
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
-- will return retirement_id of px_asset_retire_rec
IS

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   lv_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   l_asset_cat_rec     FA_API_TYPES.asset_cat_rec_type;

   l_rate              number;

   l_fraction_remaining        number;
   l_deprn_rounding_flag       varchar2(30);
   l_period_counter_fully_ret  number;

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_sub_reinstatement';

BEGIN


   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;
   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_desc_rec   := p_asset_desc_rec;
   l_asset_type_rec   := p_asset_type_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;

   l_rate             := p_rate;

   -- ***************************
   -- **  Pop local rec types
   -- ***************************

   -- pop asset_fin_rec
   -- get fa_books row where transaction_header_id_out is null
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_fin_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_fin_rec
          (p_asset_hdr_rec         => l_asset_hdr_rec
          ,px_asset_fin_rec        => l_asset_fin_rec
          ,p_transaction_header_id => NULL
          ,p_mrc_sob_type_code     => p_mrc_sob_type_code
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop asset_retire_rec
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_retire_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code     => p_mrc_sob_type_code,
           p_set_of_books_id => p_asset_hdr_rec.set_of_books_id
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- pop asset_cat_rec
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop asset_cat_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec     => l_asset_hdr_rec
          ,px_asset_cat_rec    => l_asset_cat_rec
          ,p_date_effective    => NULL
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************
   -- **  Do basic calculation
   -- ***************************
   -- nothing to add here now

   -- ***************************
   -- **  Main
   -- ***************************

   if not do_sub_regular_reinstatement
          (px_trans_rec        => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_mrc_sob_type_code => p_mrc_sob_type_code
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /*************************************************************
   * Partial unit reinstatement will be handled
   * once remaining part of the process handled in gain/loss
   * is verified...
   *-------------------------------------------------------------
        -- make a local copy of trans_rec and change trx_type_code
        -- this local copy of trans_rec will be used
        -- for distribution api and fautfr
        lv_trans_rec := l_trans_rec;
        lv_trans_rec.transaction_type_code := 'TRANSFER OUT';
        lv_trans_rec.transaction_header_id := null;

        -- FYI: current_units is used as parameter of units_retired in Distribution API
        l_asset_desc_rec.current_units := l_asset_retire_rec.units_retired;

        -- FYI: call distribution api
        -- only when set of books is a primary GL book
        -- and FA book is a corporate book
        -- and transaction is a partial unit retirement.
        -- Assumption: fautfr in distribution API
        --             is handling all MRC part of adjustments table
        if (l_asset_dist_tbl.count > 0 )
           and
           (l_asset_hdr_rec.set_of_books_id
             = fa_cache_pkg.fazcbc_record.set_of_books_id)
           and
           (fa_cache_pkg.fazcbc_record.book_class='CORPORATE') then

             -- Call distribution API to process partial-unit reinstatement.
             -- do_distribution will handle TH, DH, AD and AH tables for TRANSFER OUT transaction
             -- and call 'fautfr' function in it.

             -- assuming that fautfr is inserting adjustment rows for TAX books.
             -- and calculate gain/loss is taking care of those for CORPORATE book.

             -- Required parameters for TRANSFER OUT transaction
             --   trans_rec: transaction_date_entered
             --   asset_hdr_rec: asset_id, book_type_code(only CORPORATE)
             --   asset_dist_tbl: distribution_id, trx_units

             if p_log_level_rec.statement_level then
               fa_debug_pkg.add(l_calling_fn, 'trx_type_code:', lv_trans_rec.transaction_type_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'trx_date_entered:', lv_trans_rec.transaction_date_entered, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'asset_id:', l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'book_type_code:', l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
             end if;

             --for i in 1..l_asset_dist_tbl.count loop

                 if p_log_level_rec.statement_level then
                    fa_debug_pkg.add(l_calling_fn, 'dist_id:', l_asset_dist_tbl(1).distribution_id);
                    fa_debug_pkg.add(l_calling_fn, 'trx_units:', l_asset_dist_tbl(1).transaction_units);
                 end if;

             --end loop;

             if not FA_DISTRIBUTION_PVT.do_distribution
                    (px_trans_rec            => lv_trans_rec
                    ,px_asset_hdr_rec        => l_asset_hdr_rec
                    ,px_asset_cat_rec_new    => l_asset_cat_rec
                    ,px_asset_dist_tbl       => l_asset_dist_tbl
                    , p_log_level_rec => p_log_level_rec) then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

        end if;
        ********************************/

   --
   -- If this is member asset and Recognize Gain Loss is set
   -- to "NO", create adjustment entries right away and
   -- make sure gain loss won't process this reinstatement later.
   --
   if (l_asset_fin_rec.group_asset_id is not null) and
      (l_asset_retire_rec.recognize_gain_loss = 'NO') then

      if not FA_RETIREMENT_PVT.DO_REINSTATEMENT(
                      p_trans_rec         => l_trans_rec,
                      p_asset_retire_rec  => l_asset_retire_rec,
                      p_asset_hdr_rec     => l_asset_hdr_rec,
                      p_asset_type_rec    => l_asset_type_rec,
                      p_asset_cat_rec     => l_asset_cat_rec,
                      p_asset_fin_rec     => l_asset_fin_rec,
                      p_asset_desc_rec    => l_asset_desc_rec,
                      p_period_rec        => l_period_rec,
                      p_mrc_sob_type_code => p_mrc_sob_type_code,
                      p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if;

   px_trans_rec := l_trans_rec;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;


END do_sub_reinstatement;
----------------------------------------------------------------

FUNCTION do_sub_regular_reinstatement
        (px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_mrc_sob_type_code          in     VARCHAR2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   -- local asset info
   l_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec   FA_API_TYPES.asset_desc_rec_type;
   l_asset_fin_rec    FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl   FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl      FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl          FA_API_TYPES.inv_tbl_type;
   l_period_rec       FA_API_TYPES.period_rec_type;

   l_asset_cat_rec             FA_API_TYPES.asset_cat_rec_type;

   l_rowid                     ROWID;
   l_Fraction_Remaining        number;
   l_deprn_rounding_flag       varchar2(30);
   l_period_counter_fully_ret  number := null;

   l_percent_salvage_value     number := 0;

   l_adjusted_cost_new         number := 0;
   l_cost_new                  number := 0;
   l_salvage_value_new         number := 0;
   l_unrevalued_cost_new       number := 0;
   l_recoverable_cost_new      number := 0;
   l_recoverable               number := 0;
   l_adjusted_rec_cost         number := 0;

   l_status                    boolean := TRUE;

   /*
    * Getting FA_TRANSACTION_HEADERS.INVOICE_TRANSACTION_ID
    */
   cursor c_inv_trx_id (c_thid number) is
   select invoice_transaction_id
   from   fa_transaction_headers
   where  transaction_header_id = c_thid;

   l_invoice_transaction_id    number;  -- Local variable to store return value of c_inv_trx_id;

   l_event_status              varchar2(1);  -- SLA status

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_sub_regular_reinstatement';

BEGIN


   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;

   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;
   l_asset_fin_rec    := p_asset_fin_rec;

   -- ***************************
   -- **  Main
   -- ***************************

   -- SLA Uptake - moving this to top so we know before event creation

   -- If the asset is member asset and Recognize Gain Loss is
   -- 'NO', set the status to 'DELETED' since all other process
   -- will be taken care in FA_RETIREMENT_PVT.DO_REINSTATEMENT
   -- and this asset should not be picked up by FARET
   --
   if (p_asset_fin_rec.group_asset_id is not null) and
      (l_asset_retire_rec.recognize_gain_loss = 'NO') then
     l_asset_retire_rec.status := 'DELETED';
   else
     l_asset_retire_rec.status := 'REINSTATE';
   end if;

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'set_of_books_id: ', l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec); end if;

   if (p_mrc_sob_type_code <> 'R') then

      if ((l_asset_retire_rec.units_retired = l_asset_desc_rec.current_units
          )
          or (l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost
             and l_asset_retire_rec.cost_retired <> 0
             )
          or (l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost
             and l_asset_retire_rec.cost_retired = 0
             and l_asset_retire_rec.units_retired is NULL
             )
         ) then

             l_trans_rec.transaction_type_code := 'REINSTATEMENT';
             l_period_counter_fully_ret := l_period_rec.period_counter;
             --l_deprn_rounding_flag := 'RET';

      else
             l_trans_rec.transaction_type_code := 'REINSTATEMENT';
             l_period_counter_fully_ret := NULL;
             --l_deprn_rounding_flag := 'RET';

      end if;

      l_trans_rec.who_info.creation_date := sysdate;
      l_trans_rec.who_info.last_update_date := sysdate;

      -- SLA UPTAKE
      -- moving original event creation into do_sub_regular_reinstatement
      -- assign an event for the transaction
      -- at this point key info asset/book/trx info is known from above code

      if (l_asset_retire_rec.status = 'REINSTATE') then
         l_event_status := FA_XLA_EVENTS_PVT.C_EVENT_INCOMPLETE;
      else
         l_event_status := FA_XLA_EVENTS_PVT.C_EVENT_UNPROCESSED;
      end if;

      if not fa_xla_events_pvt.create_transaction_event
           (p_asset_hdr_rec => l_asset_hdr_rec,
            p_asset_type_rec=> p_asset_type_rec,
            px_trans_rec    => l_trans_rec,
            p_event_status  => l_event_status,
            p_calling_fn    => 'FA_RETIREMENT_PUB.do_sub_regular_reinstatement',
            p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;


      if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'do fa_transaction_headers_pkg.insert_row', '', p_log_level_rec => p_log_level_rec); end if;

      fa_transaction_headers_pkg.insert_row
                      (x_rowid                          => l_rowid,
                       x_transaction_header_id          => l_trans_rec.transaction_header_id,
                       x_book_type_code                 => l_asset_hdr_rec.book_type_code,
                       x_asset_id                       => l_asset_hdr_rec.asset_id,
                       x_transaction_type_code          => l_trans_rec.transaction_type_code,
                       x_transaction_date_entered       => l_trans_rec.transaction_date_entered,
                       x_date_effective                 => l_trans_rec.who_info.creation_date,
                       x_last_update_date               => l_trans_rec.who_info.last_update_date,
                       x_last_updated_by                => l_trans_rec.who_info.last_updated_by,
                       x_transaction_name               => null, --l_trans_rec.transaction_name,
                       x_invoice_transaction_id         => null,
                       x_source_transaction_Header_id   => l_trans_rec.source_transaction_header_id,
                       x_mass_reference_id              => l_trans_rec.mass_reference_id,
                       x_last_Update_login              => l_trans_rec.who_info.last_update_login,
                       x_transaction_subtype            => null, --l_trans_rec.transaction_subtype
                       x_Attribute1                     => l_trans_rec.desc_flex.attribute1,
                       x_Attribute2                     => l_trans_rec.desc_flex.attribute2,
                       x_Attribute3                     => l_trans_rec.desc_flex.attribute3,
                       x_Attribute4                     => l_trans_rec.desc_flex.attribute4,
                       x_Attribute5                     => l_trans_rec.desc_flex.attribute5,
                       x_Attribute6                     => l_trans_rec.desc_flex.attribute6,
                       x_Attribute7                     => l_trans_rec.desc_flex.attribute7,
                       x_Attribute8                     => l_trans_rec.desc_flex.attribute8,
                       x_Attribute9                     => l_trans_rec.desc_flex.attribute9,
                       x_Attribute10                    => l_trans_rec.desc_flex.attribute10,
                       x_Attribute11                    => l_trans_rec.desc_flex.attribute11,
                       x_Attribute12                    => l_trans_rec.desc_flex.attribute12,
                       x_Attribute13                    => l_trans_rec.desc_flex.attribute13,
                       x_Attribute14                    => l_trans_rec.desc_flex.attribute14,
                       x_Attribute15                    => l_trans_rec.desc_flex.attribute15,
                       x_attribute_category_code        => l_trans_rec.desc_flex.attribute_category_code,
                       x_transaction_key                => 'R', -- l_trans_rec.transaction_key
                       x_mass_transaction_id            => l_trans_rec.mass_transaction_id,
                       x_event_id                       => l_trans_rec.event_id,

                       x_calling_interface              => l_trans_rec.calling_interface,
                       x_return_status                  => l_status,
                       x_calling_fn                     => l_calling_fn
                      , p_log_level_rec => p_log_level_rec);

      -- returning trans_rec to reuse for MRC tables
      px_trans_rec := l_trans_rec;

   end if; -- reporting_flag

   if p_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'do fa_retirements_pkg.update_row', '', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'retirement_id: ', l_asset_retire_rec.Retirement_Id, p_log_level_rec => p_log_level_rec);
   end if;

   -- ? just for now
   -- l_asset_retire_rec.detail_info := null;


   FA_RETIREMENTS_PKG.UPDATE_ROW (
              X_Rowid                     => l_asset_retire_rec.detail_info.row_id,
              X_Retirement_Id             => l_asset_retire_rec.Retirement_Id,
              X_Book_Type_Code            => l_asset_hdr_rec.Book_Type_Code,
              X_Asset_Id                  => l_asset_hdr_rec.Asset_Id,
              X_Transaction_Header_Id_In  => l_asset_retire_rec.detail_info.Transaction_Header_Id_in,
              X_Date_Retired              => l_asset_retire_rec.Date_Retired,
              X_Date_Effective            => null,
              X_Cost_Retired              => l_asset_retire_rec.Cost_Retired,
              X_Status                    => l_asset_retire_rec.status,
              X_Last_Update_Date          => l_trans_rec.who_info.last_update_date,
              X_Last_Updated_By           => l_trans_rec.who_info.last_updated_by,
              X_Ret_Prorate_Convention    => l_asset_retire_rec.retirement_prorate_convention,
              X_Transaction_Header_Id_Out => l_trans_rec.transaction_header_id,
              X_Units                     => l_asset_retire_rec.units_retired,
              X_Cost_Of_Removal           => l_asset_retire_rec.cost_of_removal,
              X_Nbv_Retired               => l_asset_retire_rec.detail_info.nbv_retired,
              X_Gain_Loss_Amount          => l_asset_retire_rec.detail_info.gain_loss_amount,
              X_Proceeds_Of_Sale          => l_asset_retire_rec.proceeds_of_sale,
              X_Gain_Loss_Type_Code       => l_asset_retire_rec.detail_info.gain_loss_type_code,
              X_Retirement_Type_Code      => l_asset_retire_rec.retirement_type_code,
              X_Itc_Recaptured            => l_asset_retire_rec.detail_info.itc_recaptured,
              X_Itc_Recapture_Id          => l_asset_retire_rec.detail_info.itc_recapture_id,
              X_Reference_Num             => l_asset_retire_rec.reference_num,
              X_Sold_To                   => l_asset_retire_rec.sold_to,
              X_Trade_In_Asset_Id         => l_asset_retire_rec.trade_in_asset_id,
              X_Stl_Method_Code           => l_asset_retire_rec.detail_info.stl_method_code,
              X_Stl_Life_In_Months        => l_asset_retire_rec.detail_info.stl_life_in_months,
              X_Stl_Deprn_Amount          => l_asset_retire_rec.detail_info.stl_deprn_amount,
              X_Last_Update_Login         => l_trans_rec.who_info.last_update_login,
              X_Attribute1                => l_asset_retire_rec.desc_flex.attribute1,
              X_Attribute2                => l_asset_retire_rec.desc_flex.attribute2,
              X_Attribute3                => l_asset_retire_rec.desc_flex.attribute3,
              X_Attribute4                => l_asset_retire_rec.desc_flex.attribute4,
              X_Attribute5                => l_asset_retire_rec.desc_flex.attribute5,
              X_Attribute6                => l_asset_retire_rec.desc_flex.attribute6,
              X_Attribute7                => l_asset_retire_rec.desc_flex.attribute7,
              X_Attribute8                => l_asset_retire_rec.desc_flex.attribute8,
              X_Attribute9                => l_asset_retire_rec.desc_flex.attribute9,
              X_Attribute10               => l_asset_retire_rec.desc_flex.attribute10,
              X_Attribute11               => l_asset_retire_rec.desc_flex.attribute11,
              X_Attribute12               => l_asset_retire_rec.desc_flex.attribute12,
              X_Attribute13               => l_asset_retire_rec.desc_flex.attribute13,
              X_Attribute14               => l_asset_retire_rec.desc_flex.attribute14,
              X_Attribute15               => l_asset_retire_rec.desc_flex.attribute15,
              X_Attribute_Category_Code   => l_asset_retire_rec.desc_flex.attribute_category_code,
              X_Reval_Reserve_Retired     => l_asset_retire_rec.detail_info.reval_reserve_retired,
              X_Unrevalued_Cost_Retired   => l_asset_retire_rec.detail_info.unrevalued_cost_retired,
              X_Recognize_Gain_Loss       => l_asset_retire_rec.recognize_gain_loss,
              X_Recapture_Reserve_Flag    => l_asset_retire_rec.recapture_reserve_flag,
              X_Limit_Proceeds_Flag       => l_asset_retire_rec.limit_proceeds_flag,
              X_Terminal_Gain_Loss        => l_asset_retire_rec.terminal_gain_loss,
              X_Reserve_Retired           => l_asset_retire_rec.reserve_retired,
              X_Eofy_Reserve              => l_asset_retire_rec.eofy_reserve,
              X_Reduction_Rate            => l_asset_retire_rec.reduction_rate,
              X_Recapture_Amount          => l_asset_retire_rec.detail_info.recapture_amount,
              X_mrc_sob_type_code         => p_mrc_sob_type_code,
              X_set_of_books_id           => l_asset_hdr_rec.set_of_books_id,
              X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

   /*
    * Check to see previous retirement involved source lines or not.
    */
   OPEN c_inv_trx_id (l_asset_retire_rec.detail_info.Transaction_Header_Id_in);
   FETCH c_inv_trx_id into l_invoice_transaction_id;
   CLOSE c_inv_trx_id;

   /*
    * If previous retirement involved source lines, call
    * REINSTATE_SRC_LINE to reinstate source lines.
    * REINSTATE_SRC_LINE needs to be called only once since
    * Invoice API which is called from REINSTATE_SRC_LINE takes
    * care mrc records when it is called for primary book.
    */
   if (l_invoice_transaction_id is not null) and
      (p_mrc_sob_type_code = 'P') then
      if not REINSTATE_SRC_LINE( px_trans_rec              => l_trans_rec,
                                 px_asset_hdr_rec          => l_asset_hdr_rec,
                                 px_asset_fin_rec          => l_asset_fin_rec,
                                 p_asset_desc_rec          => p_asset_desc_rec,
                                 p_invoice_transaction_id  => l_invoice_transaction_id,
                                 p_inv_tbl                 => l_inv_tbl,
                                 p_rowid                   => l_rowid,
                                 p_calling_fn              => l_calling_fn,
                                 p_log_level_rec           => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if; -- (l_invoice_transaction_id is not null)

   return TRUE;

EXCEPTION
   /*
    * Added for Group Asset uptake
    */
    when FND_API.G_EXC_UNEXPECTED_ERROR then
           -- Make sure to close curosr opened for source line retirement
          if c_inv_trx_id%ISOPEN then
             CLOSE c_inv_trx_id;
          end if;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;
   /*** End of uptake ***/
   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

           -- Make sure to close curosr opened for source line retirement
          if c_inv_trx_id%ISOPEN then
             CLOSE c_inv_trx_id;
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_sub_regular_reinstatement;
------------------------------------------------------------------------

-- Table access
-- 1. delete into TH
-- 2. update RET
PROCEDURE undo_reinstatement
   (p_api_version                in     NUMBER
   ,p_init_msg_list              in     VARCHAR2 := FND_API.G_FALSE
   ,p_commit                     in     VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level           in     NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_calling_fn                 in     VARCHAR2
   ,x_return_status              out    NOCOPY VARCHAR2
   ,x_msg_count                  out    NOCOPY NUMBER
   ,x_msg_data                   out    NOCOPY VARCHAR2

   ,px_trans_rec                 in out NOCOPY FA_API_TYPES.trans_rec_type
   ,px_asset_hdr_rec             in out NOCOPY FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type)

IS

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   lv_trans_rec        FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   lv_asset_hdr_rec    FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   lv_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   -- used to loop through tax books
   l_tax_book_tbl      FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index         number;  -- index for tax loop

   l_reporting_flag             varchar2(1);

   -- used to store original sob info upon entry into api
   l_orig_set_of_books_id    number;
   l_orig_currency_context   varchar2(64);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_reinstatement';

BEGIN

   savepoint undo_reinstatement;


   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   g_release := fa_cache_pkg.fazarel_release;

   -- initialize message list if p_init_msg_list is set to TRUE.
   if (FND_API.to_boolean(p_init_msg_list) ) then
        -- initialize error message stack.
        fa_srvr_msg.init_server_message;

        -- initialize debug message stack.
        fa_debug_pkg.initialize;
   end if;

   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := px_trans_rec;
   l_asset_hdr_rec    := px_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;

   -- ***********************************
   -- **  Call the cache for book
   -- **  and do initial MRC validation
   -- ***********************************

   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec      => l_asset_hdr_rec
          ,px_asset_type_rec    => l_asset_type_rec
          ,p_date_effective     => NULL
          , p_log_level_rec => g_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if l_asset_hdr_rec.book_type_code is not null then

        -- call the cache for the primary transaction book
        if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => g_log_level_rec) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
        lv_asset_hdr_rec := l_asset_hdr_rec;

        -- get the book type code P,R or N
        if not fa_cache_pkg.fazcsob
               (x_set_of_books_id   => l_asset_hdr_rec.set_of_books_id
               ,x_mrc_sob_type_code => l_reporting_flag, p_log_level_rec => g_log_level_rec)
               then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- Error out if the program is submitted from the Reporting Responsibility
        -- No transaction permitted directly on reporting books.
        if l_reporting_flag = 'R' then
             FND_MESSAGE.set_name('GL','MRC_OSP_INVALID_BOOK_TYPE');
             FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get);
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;


   end if; -- book_type_code

   -- *********************************************
   -- **  Do basic validation on input parameters
   -- *********************************************

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin do_validation', '', p_log_level_rec => g_log_level_rec); end if;
   -- validate that all user-entered input parameters are valid
   if not do_validation
          (p_validation_type   => g_undo_reinstatement
          ,p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,p_asset_desc_rec    => l_asset_desc_rec
          ,p_asset_type_rec    => l_asset_type_rec
          ,p_asset_fin_rec     => l_asset_fin_rec
          ,p_asset_retire_rec  => l_asset_retire_rec
          ,p_asset_dist_tbl    => l_asset_dist_tbl
          ,p_subcomp_tbl       => l_subcomp_tbl
          ,p_inv_tbl           => l_inv_tbl
          ,p_period_rec        => l_period_rec
          ,p_calling_fn        => p_calling_fn
          ,p_log_level_rec     => g_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /* IAC Specific Validation */
   if (FA_IGI_EXT_PKG.IAC_Enabled) then
       if not FA_IGI_EXT_PKG.Validate_Retire_Reinstate(
           p_book_type_code   => l_asset_hdr_rec.book_type_code,
           p_asset_id         => l_asset_hdr_rec.asset_id,
           p_calling_function => l_calling_fn
        ) then
            raise FND_API.G_EXC_ERROR;
       end if;
   end if;

   if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'end do_validation', '', p_log_level_rec => g_log_level_rec); end if;

   if not undo_all_books_reinstatement
      (p_trans_rec         => l_trans_rec
      ,p_asset_hdr_rec     => l_asset_hdr_rec
      ,px_asset_retire_rec => l_asset_retire_rec
      ,p_asset_type_rec    => l_asset_type_rec  --bug 8643362
      ,p_log_level_rec     => g_log_level_rec
      ) then
          raise  FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   /* if book is a corporate book, process cip assets and autocopy */

   -- start processing tax books for cip-in-tax and autocopy
   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      lv_trans_rec := l_trans_rec;

      if (l_asset_type_rec.asset_type = 'CIP'
          or l_asset_type_rec.asset_type = 'CAPITALIZED') then

         if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Asset type: ', l_asset_type_rec.asset_type, p_log_level_rec => g_log_level_rec); end if;

         if not fa_cache_pkg.fazctbk
                (x_corp_book    => l_asset_hdr_rec.book_type_code
                ,x_asset_type   => l_asset_type_rec.asset_type
                ,x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => g_log_level_rec) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         for l_tax_index in 1..l_tax_book_tbl.count loop

           if g_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'entered loop for tax books', '', p_log_level_rec => g_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, 'selected tax book: ', l_tax_book_tbl(l_tax_index));
           end if;

           if not FA_ASSET_VAL_PVT.validate_asset_book
                  (p_transaction_type_code      => l_trans_rec.transaction_type_code
                  ,p_book_type_code             => l_tax_book_tbl(l_tax_index)
                  ,p_asset_id                   => l_asset_hdr_rec.asset_id
                  ,p_calling_fn                 => l_calling_fn
                  ,p_log_level_rec              => g_log_level_rec) then

                     null; -- just to ignore the error

           else

             -- cache the book information for the tax book
             if not fa_cache_pkg.fazcbc(x_book => l_tax_book_tbl(l_tax_index),
                                        p_log_level_rec => g_log_level_rec) then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;

             lv_trans_rec.transaction_header_id   := null;
             lv_asset_retire_rec                  := null;

             -- to get the new retirement_id for the retrieved tax book
             select retirement_id
             into lv_asset_retire_rec.retirement_id
             from fa_retirements
             where asset_id=lv_asset_hdr_rec.asset_id
               and book_type_code=l_tax_book_tbl(l_tax_index)
               and status = 'REINSTATE';

             if g_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling undo_sub_retirement for tax book', '', p_log_level_rec => g_log_level_rec); end if;

             if not undo_all_books_reinstatement
                    (p_trans_rec         => lv_trans_rec     -- tax
                    ,p_asset_hdr_rec     => lv_asset_hdr_rec -- tax
                    ,px_asset_retire_rec => lv_asset_retire_rec -- tax
                    ,p_asset_type_rec    => l_asset_type_rec --bug 8643362
                    ,p_log_level_rec     => g_log_level_rec
                    ) then
                        raise FND_API.G_EXC_ERROR;
             end if;

           end if;

         end loop;


      end if; -- asset_type

   end if; -- book_class


   -- commit if p_commit is TRUE.
   if FND_API.to_boolean(p_commit) then
      COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   FND_MSG_PUB.count_and_get(p_count   => x_msg_count
                            ,p_data    => x_msg_data
                            );

   -- return the status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then

          ROLLBACK TO undo_reinstatement;

          x_return_status := FND_API.G_RET_STS_ERROR;

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => g_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => g_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when FND_API.G_EXC_UNEXPECTED_ERROR then

          ROLLBACK TO undo_reinstatement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                 , p_log_level_rec => g_log_level_rec);
          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

   when others then

          ROLLBACK TO undo_reinstatement;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => g_log_level_rec);
          FND_MSG_PUB.count_and_get(p_count => x_msg_count
                                   ,p_data  => x_msg_data
                                   );

END undo_reinstatement;
----------------------------------------------------

FUNCTION undo_all_books_reinstatement
        (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type -- bug 8643362
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   -- Returns the reporting GL set_of_books_ids
   -- associated with the set_of_books_id of given primary book_type_code
   CURSOR sob_cursor(p_book_type_code in varchar2
                    ,p_sob_id         in number) is
   SELECT set_of_books_id AS sob_id
     FROM fa_mc_book_controls
    WHERE book_type_code          = p_book_type_code
      AND primary_set_of_books_id = p_sob_id
      AND enabled_flag            = 'Y';

   -- used for main transaction book
   l_book_class                 varchar2(15);
   l_set_of_books_id            number;
   l_distribution_source_book   varchar2(30);
   l_mc_source_flag             varchar2(1);

   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_period_rec        FA_API_TYPES.period_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type; -- bug 8630242

   l_ins_status                 boolean := FALSE;

   -- local conversion rate
   l_exchange_date              date;
   l_rate                       number;

   -- msg
   g_msg_name                   varchar2(30);

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_all_books_reinstatement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := p_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;
   l_asset_type_rec   := p_asset_type_rec;  -- bug 8630242

   -- *********************************
   -- **  Populate local record types
   -- *********************************
   -- populate rec_types that were not provided by users

   -- pop asset_retire_rec to get the rowid of retirement
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => 'P',
           p_set_of_books_id => null
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.asset_id       := l_asset_retire_rec.detail_info.asset_id;
   l_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;

   -- call the cache for the primary transaction book
   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

   -- pop current period_rec info
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop period_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if not FA_UTIL_PVT.get_period_rec
          (p_book           => l_asset_hdr_rec.book_type_code
          ,p_effective_date => NULL
          ,x_period_rec     => l_period_rec
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************************************
   -- **  Do asset/book-level validation on transaction
   -- ***************************************************
   -- begin asset/book-level validation on transaction

   -- nothing to do here
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin asset/book-level validation on transaction', '', p_log_level_rec => p_log_level_rec); end if;

   -- ***************************
   -- **  Transaction approval
   -- ***************************

   -- delete the event
   if not fa_xla_events_pvt.delete_transaction_event
           (p_ledger_id              => l_asset_hdr_rec.set_of_books_id,
            p_transaction_header_id  => l_asset_retire_rec.detail_info.transaction_header_id_out,
            p_book_type_code         => l_asset_hdr_rec.book_type_code,
            p_asset_type             => l_asset_type_rec.asset_type, --bug 8643362
            p_calling_fn             => 'fa_retirement_pub.undo_all_books_reinstatement'
            ,p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- ***************************
   -- **  Main
   -- ***************************

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling do_sub_retirement for each book/sob', '', p_log_level_rec => p_log_level_rec); end if;

   l_rate := 1;
   if not undo_sub_reinstatement
          (p_trans_rec         => l_trans_rec
          ,p_asset_hdr_rec     => l_asset_hdr_rec
          ,px_asset_retire_rec => l_asset_retire_rec
          ,p_mrc_sob_type_code => 'P'
          ,p_log_level_rec     => p_log_level_rec
          ) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;
   end if;

   -- MRC LOOP
   -- if this is a primary book, process reporting books(sobs)
   if fa_cache_pkg.fazcbc_record.mc_source_flag = 'Y' then

       -- loop thourgh reporting set of books
       for sob_rec in sob_cursor(l_asset_hdr_rec.book_type_code
                                ,l_asset_hdr_rec.set_of_books_id) loop

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in sob_id loop', '', p_log_level_rec => p_log_level_rec); end if;

         l_asset_hdr_rec.set_of_books_id := sob_rec.sob_id;
         if not fa_cache_pkg.fazcbcs(x_book => l_asset_hdr_rec.book_type_code,
                                     x_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                     p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return FALSE;
         end if;

         if not undo_sub_reinstatement
                (p_trans_rec         => l_trans_rec
                ,p_asset_hdr_rec     => l_asset_hdr_rec
                ,px_asset_retire_rec => l_asset_retire_rec
                ,p_mrc_sob_type_code => 'R'
                ,p_log_level_rec     => p_log_level_rec
                ) then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

       end loop;

   end if;

   return TRUE;

EXCEPTION

   when others then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END undo_all_books_reinstatement;
------------------------------------------------------------------------------
-- p_trans_rec should have trx_id for the previous REINSTATEMENT transaction
FUNCTION undo_sub_reinstatement
   (p_trans_rec                  in     FA_API_TYPES.trans_rec_type
   ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
   ,px_asset_retire_rec          in out NOCOPY FA_API_TYPES.asset_retire_rec_type
   ,p_mrc_sob_type_code          in     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS
   -- local asset info
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;

   /*
    * Check to see previous retirement was source line retirement or not
    */
   cursor c_inv_trx_id (c_thid number)is
      select invoice_transaction_id
      from   fa_transaction_headers
      where  transaction_header_id = c_thid;

   l_invoice_transaction_id    number;  -- Local variable to store return value of c_inv_trx_id

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.undo_sub_reinstatement';

BEGIN


   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_trans_rec        := p_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_retire_rec := px_asset_retire_rec;

   -- pop local asset_retire_rec for retirement
   if not FA_UTIL_PVT.get_asset_retire_rec
          (px_asset_retire_rec => l_asset_retire_rec,
           p_mrc_sob_type_code => p_mrc_sob_type_code,
           p_set_of_books_id => p_asset_hdr_rec.set_of_books_id
          , p_log_level_rec => p_log_level_rec) then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_asset_retire_rec.status := 'PROCESSED';

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'set_of_books_id: ', l_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec); end if;

   /*
    * Check to see previous retirement involved source lines or not.
    */
   OPEN c_inv_trx_id (l_asset_retire_rec.detail_info.transaction_header_id_out);
   FETCH c_inv_trx_id into l_invoice_transaction_id;
   CLOSE c_inv_trx_id;

   if (l_invoice_transaction_id is not null) then
      if (p_mrc_sob_type_code = 'R') then
         DELETE FROM FA_MC_ASSET_INVOICES
         WHERE       ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND         INVOICE_TRANSACTION_ID_IN = l_invoice_transaction_id
         AND         INVOICE_TRANSACTION_ID_OUT is null
         AND         SET_OF_BOOKS_ID = l_asset_hdr_rec.set_of_books_id;

         /*
          * This reactivate record with FIXED_ASSETS_COST <> 0
          * since 0 cost row should not be appeared on source line window.
          */
         UPDATE FA_MC_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = '',
                DATE_INEFFECTIVE = ''
         WHERE  ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id
         AND    FIXED_ASSETS_COST <> 0
         AND    SET_OF_BOOKS_ID = l_asset_hdr_rec.set_of_books_id;

         /*
          * This set record as after retirement.
          * After retirement, if cost is 0, INVOICE_TRANSACTION_ID_OUT
          * and DATE_INEFFECTIVE is populated with the same value as
          * INVOICE_TRANSACTION_ID_IN and DATE_EFFECTIVE.
          */
         UPDATE FA_MC_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = INVOICE_TRANSACTION_ID_IN,
                DATE_INEFFECTIVE = DATE_EFFECTIVE
         WHERE  ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id
         AND    FIXED_ASSETS_COST = 0
         AND    SET_OF_BOOKS_ID = l_asset_hdr_rec.set_of_books_id;

      else -- This is primary book

         DELETE FROM FA_ASSET_INVOICES
         WHERE       ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND         INVOICE_TRANSACTION_ID_IN = l_invoice_transaction_id
         AND         INVOICE_TRANSACTION_ID_OUT is null;

         /*
          * This reactivate record with FIXED_ASSETS_COST <> 0
          * since 0 cost row should not be appeared on source line window.
          */
         UPDATE FA_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = '',
                DATE_INEFFECTIVE = ''
         WHERE  ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id
         AND    FIXED_ASSETS_COST <> 0;

         /*
          * This set record as after retirement.
          * After retirement, if cost is 0, INVOICE_TRANSACTION_ID_OUT
          * and DATE_INEFFECTIVE is populated with the same value as
          * INVOICE_TRANSACTION_ID_IN and DATE_EFFECTIVE.
          */
         UPDATE FA_ASSET_INVOICES
         SET    INVOICE_TRANSACTION_ID_OUT = INVOICE_TRANSACTION_ID_IN,
                DATE_INEFFECTIVE = DATE_EFFECTIVE
         WHERE  ASSET_ID = l_asset_retire_rec.detail_info.asset_id
         AND    INVOICE_TRANSACTION_ID_OUT = l_invoice_transaction_id
         AND    FIXED_ASSETS_COST = 0;

         DELETE FROM FA_INVOICE_TRANSACTIONS
         WHERE       INVOICE_TRANSACTION_ID = l_invoice_transaction_id;

      end if; -- (p_mrc_sob_type_code = 'R')
   end if; -- (l_invoice_transaction_id is not null)

   if (p_mrc_sob_type_code <> 'R') then
      -- ? check this parameter again
      -- delete transaction_headers row only for primary book
      FA_TRANSACTION_HEADERS_PKG.DELETE_ROW
                (X_Transaction_Header_Id => l_asset_retire_rec.detail_info.transaction_header_id_out,
                 X_Calling_Fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

   end if; -- reporting_flag

   FA_RETIREMENTS_PKG.UPDATE_ROW(
              X_Rowid                     => l_asset_retire_rec.detail_info.row_id,
              X_Retirement_Id             => l_asset_retire_rec.Retirement_Id,
              X_Book_Type_Code            => l_asset_retire_rec.detail_info.Book_Type_Code,
              X_Asset_Id                  => l_asset_retire_rec.detail_info.Asset_Id,
              X_Transaction_Header_Id_In  => l_asset_retire_rec.detail_info.Transaction_Header_Id_in,
              X_Date_Retired              => l_asset_retire_rec.Date_Retired,
              X_Date_Effective            => l_trans_rec.who_info.creation_date,
              X_Cost_Retired              => l_asset_retire_rec.Cost_Retired,
              X_Status                    => l_asset_retire_rec.status,
              X_Last_Update_Date          => l_trans_rec.who_info.last_update_date,
              X_Last_Updated_By           => l_trans_rec.who_info.last_updated_by,
              X_Ret_Prorate_Convention    => l_asset_retire_rec.retirement_prorate_convention,
              X_Transaction_Header_Id_Out => FND_API.G_MISS_NUM,--bug fix 4088953
              X_Units                     => l_asset_retire_rec.units_retired,
              X_Cost_Of_Removal           => l_asset_retire_rec.cost_of_removal,
              X_Nbv_Retired               => l_asset_retire_rec.detail_info.nbv_retired,
              X_Gain_Loss_Amount          => l_asset_retire_rec.detail_info.gain_loss_amount,
              X_Proceeds_Of_Sale          => l_asset_retire_rec.proceeds_of_sale,
              X_Gain_Loss_Type_Code       => l_asset_retire_rec.detail_info.gain_loss_type_code,
              X_Retirement_Type_Code      => l_asset_retire_rec.retirement_type_code,
              X_Itc_Recaptured            => l_asset_retire_rec.detail_info.itc_recaptured,
              X_Itc_Recapture_Id          => l_asset_retire_rec.detail_info.itc_recapture_id,
              X_Reference_Num             => l_asset_retire_rec.reference_num,
              X_Sold_To                   => l_asset_retire_rec.sold_to,
              X_Trade_In_Asset_Id         => l_asset_retire_rec.trade_in_asset_id,
              X_Stl_Method_Code           => l_asset_retire_rec.detail_info.stl_method_code,
              X_Stl_Life_In_Months        => l_asset_retire_rec.detail_info.stl_life_in_months,
              X_Stl_Deprn_Amount          => l_asset_retire_rec.detail_info.stl_deprn_amount,
              X_Last_Update_Login         => l_trans_rec.who_info.last_update_login,
              X_Attribute1                => l_asset_retire_rec.desc_flex.attribute1,
              X_Attribute2                => l_asset_retire_rec.desc_flex.attribute2,
              X_Attribute3                => l_asset_retire_rec.desc_flex.attribute3,
              X_Attribute4                => l_asset_retire_rec.desc_flex.attribute4,
              X_Attribute5                => l_asset_retire_rec.desc_flex.attribute5,
              X_Attribute6                => l_asset_retire_rec.desc_flex.attribute6,
              X_Attribute7                => l_asset_retire_rec.desc_flex.attribute7,
              X_Attribute8                => l_asset_retire_rec.desc_flex.attribute8,
              X_Attribute9                => l_asset_retire_rec.desc_flex.attribute9,
              X_Attribute10               => l_asset_retire_rec.desc_flex.attribute10,
              X_Attribute11               => l_asset_retire_rec.desc_flex.attribute11,
              X_Attribute12               => l_asset_retire_rec.desc_flex.attribute12,
              X_Attribute13               => l_asset_retire_rec.desc_flex.attribute13,
              X_Attribute14               => l_asset_retire_rec.desc_flex.attribute14,
              X_Attribute15               => l_asset_retire_rec.desc_flex.attribute15,
              X_Attribute_Category_Code   => l_asset_retire_rec.desc_flex.attribute_category_code,
              X_Reval_Reserve_Retired     => l_asset_retire_rec.detail_info.reval_reserve_retired,
              X_Unrevalued_Cost_Retired   => l_asset_retire_rec.detail_info.unrevalued_cost_retired,
              X_Recognize_Gain_Loss       => l_asset_retire_rec.recognize_gain_loss,
              X_Recapture_Reserve_Flag    => l_asset_retire_rec.recapture_reserve_flag,
              X_Limit_Proceeds_Flag       => l_asset_retire_rec.limit_proceeds_flag,
              X_Terminal_Gain_Loss        => l_asset_retire_rec.terminal_gain_loss,
              X_Reserve_Retired           => l_asset_retire_rec.reserve_retired,
              X_Eofy_Reserve              => l_asset_retire_rec.eofy_reserve,
              X_Reduction_Rate            => l_asset_retire_rec.reduction_rate,
              X_Recapture_Amount          => l_asset_retire_rec.detail_info.recapture_amount,
              X_mrc_sob_type_code         => p_mrc_sob_type_code,
              X_set_of_books_id           => l_asset_hdr_rec.set_of_books_id,
              X_Calling_Fn                => l_calling_fn, p_log_level_rec => p_log_level_rec);

   return TRUE;

EXCEPTION
   /*
    * Added for Group Asset uptake
    */
    when FND_API.G_EXC_UNEXPECTED_ERROR then
          -- Make sure to close curosr opened for source line retirement
          if c_inv_trx_id%ISOPEN then
             CLOSE c_inv_trx_id;
          end if;

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;
   /*** End of uptake ***/
    when others then

          -- Make sure to close curosr opened for source line retirement
          if c_inv_trx_id%ISOPEN then
             CLOSE c_inv_trx_id;
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;
END undo_sub_reinstatement;


-- This routine mainly validates input parameters and whether the trx is runnable
FUNCTION do_validation
        (p_validation_type            in     varchar2
        ,p_trans_rec                  in     FA_API_TYPES.trans_rec_type
        ,p_asset_hdr_rec              in     FA_API_TYPES.asset_hdr_rec_type
        ,p_asset_desc_rec             in     FA_API_TYPES.asset_desc_rec_type
        ,p_asset_type_rec             in     FA_API_TYPES.asset_type_rec_type
        ,p_asset_fin_rec              in     FA_API_TYPES.asset_fin_rec_type
        ,p_asset_retire_rec           in     FA_API_TYPES.asset_retire_rec_type
        ,p_asset_dist_tbl             in     FA_API_TYPES.asset_dist_tbl_type
        ,p_subcomp_tbl                in     FA_API_TYPES.subcomp_tbl_type
        ,p_inv_tbl                    in     FA_API_TYPES.inv_tbl_type
        ,p_period_rec                 in     FA_API_TYPES.period_rec_type
        ,p_calling_fn                 in     varchar2
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN
IS

   -- local asset info
   l_validation_type   varchar2(30);
   l_trans_rec         FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec    FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
   l_asset_fin_rec     FA_API_TYPES.asset_fin_rec_type;
   l_asset_retire_rec  FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl    FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl       FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl           FA_API_TYPES.inv_tbl_type;
   l_period_rec        FA_API_TYPES.period_rec_type;

   lv_asset_retire_rec FA_API_TYPES.asset_retire_rec_type;

   l_sum_units         number := 0;
   l_override_flag     varchar2(1);

   l_latest_ret_thid   number := -1;

   --Bug7565002
   l_trans_flag VARCHAR2(1) := 'N';
   l_chk_ext_deprn varchar2(1)  := 'N'; -- bug#8941124

   CURSOR c_last_grp_reclass IS
     select th.transaction_date_entered
     from   fa_transaction_headers th
          , fa_trx_references tr
     where  th.asset_id = p_asset_hdr_rec.asset_id
     and    th.book_type_code = p_asset_hdr_rec.book_type_code
     and    th.transaction_header_id = tr.member_transaction_header_id
     and    th.trx_reference_id = tr.trx_reference_id
     and    tr.member_asset_id = p_asset_hdr_rec.asset_id
     and    tr.book_type_code = p_asset_hdr_rec.book_type_code
     and    tr.transaction_type = 'GROUP CHANGE'
     and    nvl(th.amortization_start_date, th.transaction_date_entered) > l_asset_retire_rec.date_retired;

   -- bug#8941124: Cursor to check the period of extended depreciation.
   CURSOR c_check_extended_deprn IS
      select distinct 'Y'
      from fa_transaction_headers trx,fa_Deprn_periods prd
      where  trx.book_type_code = p_asset_hdr_rec.book_type_code
      and trx.asset_id = p_asset_hdr_rec.asset_id
      and trx.date_effective > prd.period_open_date
      and prd.book_type_code = trx.book_type_code
      and prd.period_close_date is null
      and trx.transaction_key = 'ES'
      and p_period_rec.calendar_period_open_date > l_asset_retire_rec.date_retired;

   l_trx_date  date;  -- Store return value of cursor c_check_other_trx

   l_calling_fn varchar2(80) := 'FA_RETIREMENT_PUB.do_validation';

BEGIN

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'begin ', l_calling_fn, p_log_level_rec => p_log_level_rec); end if;
   -- ****************************************************
   -- **  Assign input parameters to local rec/tbl types
   -- ****************************************************
   l_validation_type  := p_validation_type;
   l_trans_rec        := p_trans_rec;
   l_asset_hdr_rec    := p_asset_hdr_rec;
   l_asset_desc_rec   := p_asset_desc_rec;
   l_asset_type_rec   := p_asset_type_rec;
   l_asset_fin_rec    := p_asset_fin_rec;
   l_asset_retire_rec := p_asset_retire_rec;
   l_asset_dist_tbl   := p_asset_dist_tbl;
   l_subcomp_tbl      := p_subcomp_tbl;
   l_inv_tbl          := p_inv_tbl;
   l_period_rec       := p_period_rec;

   lv_asset_retire_rec := null;

   -- *********************************************
   -- **  Do basic validation on input parameters
   -- *********************************************
   -- do fundamental validation on input parameters
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check fundamental validation on input parameters', '', p_log_level_rec => p_log_level_rec); end if;

   -- check list for validation on input parameters:
   -- validation of asset_id, book_type_code - done
   -- validation of transaction date(retired_date)
   --  : within FY, future date, default if null - done
   -- validation of cost_retired and units_retired - done
   -- cross validation of cost_retired and units_retired - done
   -- validation of retirement_type - done
   -- validation of retirement_convention_code - done
   -- validation of trade_in_asset_id - done
   -- validate that asset_dist_tbl has all valid distributions and their units -done
   -- validation of units_retired to see if it is a whole number - done
   -- we do not allow retirement of CIP on TAX directly. Only through CORP book. -done

   -- check if asset_id and book are provided
   if l_validation_type=g_retirement then
      if l_asset_hdr_rec.asset_id is null
         or l_asset_hdr_rec.book_type_code is null then
           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Both asset_id and book_type_code should be provided.', '', p_log_level_rec => p_log_level_rec); end if;
           -- msg_name: FA_API_SHARED_INVALID_NOTNULL
           -- msg_text: Invalid value for <>. <> is a required field.
           g_msg_name := 'FA_API_SHARED_INVALID_NOTNULL';
           g_token1 := 'XMLTAG';
           g_value1 := 'ASSET_ID and BOOK_TYPE_CODE';
           raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- check if asset is attached to hierarchy and see if it can
   -- be override to proceed with normal partial unit retirement
   if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
       if (not fa_cua_asset_APIS.check_override_allowed(
                     p_attribute_name => 'DISTRIBUTION',
                     p_book_type_code => l_asset_hdr_rec.book_type_code,
                     p_asset_id => l_asset_hdr_rec.asset_id,
                     x_override_flag => l_override_flag,
                     p_log_level_rec => p_log_level_rec)) then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_RETIREMENT_PUB.valid_input', p_log_level_rec => p_log_level_rec);
           return FALSE;
       end if;
       -- if override flag is set to No, do not allow the transfer
       if (l_override_flag = 'N') then
           fa_srvr_msg.add_message(
                      calling_fn => 'FA_RETIREMENT_PUB.valid_input',
                      name => 'CUA_NO_DIST_CHANGE_ALLOWED', p_log_level_rec => p_log_level_rec);
           return FALSE;
       end if;
   end if;

   if l_validation_type in (g_reinstatement
                           ,g_undo_retirement
                           ,g_undo_reinstatement) then
      if not ((l_asset_hdr_rec.asset_id is not null
               and l_asset_hdr_rec.book_type_code is not null
               )
              or
              (l_asset_retire_rec.retirement_id is not null
              )
             ) then
           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Either asset_id/book or retirement_id should be provided.', '', p_log_level_rec => p_log_level_rec); end if;
           -- msg_name: FA_API_SHARED_INVALID_NOTNULL
           -- msg_text: Invalid value for <>. <> is a required field.
           g_msg_name := 'FA_API_SHARED_INVALID_NOTNULL';
           g_token1 := 'XMLTAG';
           g_value1 := 'ASSET_ID/BOOK_TYPE_CODE or RETIREMENT_ID';
           raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   -- check if retirement type exists in fa_lookups if it is provided
   if l_validation_type=g_retirement then
      if l_asset_retire_rec.retirement_type_code is not null then
         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if retirement type exists in fa_lookups', '', p_log_level_rec => p_log_level_rec); end if;
         if not FA_ASSET_VAL_PVT.validate_fa_lookup_code
                (p_lookup_type => 'RETIREMENT'
                ,p_lookup_code => l_asset_retire_rec.retirement_type_code
                , p_log_level_rec => p_log_level_rec) then
                    g_msg_name := null;
                    g_token1 := null;
                    if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: Retirement type is invalid', '', p_log_level_rec => p_log_level_rec); end if;
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
      end if;
   end if;

   /*Bug 8287630 - Group Asset cannot be retired */
   if l_validation_type=g_retirement then
      if l_asset_type_rec.asset_type = 'GROUP' then
           g_msg_name := 'FA_RET_GROUP_NOT_ALLOWED';
           raise FND_API.G_EXC_ERROR;
      end if;
   end if;
   /*Bug 8287630 - Group Asset cannot be retired */

   -- check if trade_in_asset_id is valid if it is not null
   if l_validation_type=g_retirement then
      if l_asset_retire_rec.trade_in_asset_id is not NULL then

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if trade in asset number is the asset you are retiring', '', p_log_level_rec => p_log_level_rec); end if;
          if l_asset_hdr_rec.asset_id=l_asset_retire_rec.trade_in_asset_id then
               g_msg_name := 'FA_RET_INVALID_TRADE_IN';
               g_token1 := null;
               raise FND_API.G_EXC_ERROR;
          end if;

          -- check if the trade-in asset exists in Oracle Assets
          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if trade_in_asset_id exists in Oracle Assets', '', p_log_level_rec => p_log_level_rec); end if;
          if not FA_ASSET_VAL_PVT.validate_asset_id_exist
                 (p_asset_id   => l_asset_hdr_rec.asset_id
                 , p_log_level_rec => p_log_level_rec) then
                     g_msg_name := 'FA_RET_TRADE_IN_NONEXISTENT';
                     g_token1 := null;
                     raise FND_API.G_EXC_ERROR;
          end if;

      end if; -- trade-in asset
   end if; -- g_retirement

   -- check if either units_retired or cost_retired is provided
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if either units_retired or cost_retired is provided', '', p_log_level_rec => p_log_level_rec); end if;
   if l_validation_type=g_retirement then
      if l_asset_retire_rec.units_retired is null
         and l_asset_retire_rec.cost_retired is null then
           if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Either units_retired or cost_retired should be provided.', '', p_log_level_rec => p_log_level_rec); end if;
           g_msg_name := 'FA_API_SHARED_INVALID_NOTNULL';
           g_token1 := 'XMLTAG';
           g_value1 := 'UNITS_RETIRED or COST_RETIRED';
           raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check units', '', p_log_level_rec => p_log_level_rec); end if;
   if l_validation_type=g_retirement then
      if l_asset_retire_rec.units_retired is not null then

           -- check to make sure that units_retired is positive
           if l_asset_retire_rec.units_retired < 0 then
                g_msg_name := 'FA_SHARED_GREATER_THAN_ZERO';
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
           end if;

           -- get the current units of the asset from fa_asset_history table
           if not FA_UTIL_PVT.get_current_units
                  (p_calling_fn    => l_calling_fn
                  ,p_asset_id      => l_asset_hdr_rec.asset_id
                  ,x_current_units => l_asset_desc_rec.current_units
                  , p_log_level_rec => p_log_level_rec) then
                      g_msg_name := null;
                      g_token1 := null;
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

           -- check if units_retired exceeds current units
           if l_asset_retire_rec.units_retired > l_asset_desc_rec.current_units then
                g_msg_name := 'FA_RET_UNITS_TOO_BIG';
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
           end if;

      end if;
   end if;

   -- Basically we need to populate asset_retire_rec at this point
   -- so that the following validation against units_retired
   -- ,which users will not probably provide, can be done.

   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'pop local asset_retire_rec', '', p_log_level_rec => p_log_level_rec); end if;
   if l_validation_type in (g_reinstatement
                           ,g_undo_retirement
                           ,g_undo_reinstatement) then
      -- pop local asset_retire_rec for retirement
      lv_asset_retire_rec.retirement_id := l_asset_retire_rec.retirement_id;
      if not FA_UTIL_PVT.get_asset_retire_rec
             (px_asset_retire_rec => lv_asset_retire_rec,
              p_mrc_sob_type_code => 'P',
              p_set_of_books_id => null
             , p_log_level_rec => p_log_level_rec) then
                 g_msg_name := null;
                 g_token1 := null;
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
      -- At this point, lv_asset_retire_rec has the previous retirement info.
   end if;

   /* Bug #2117746:
      Bypass the following validation temporarily
      when p_calling_fn is 'fa_ciptax_api_pkg.cip_retirement'.
      This validation against p_calling_fn will be removed later.
   */
   if p_calling_fn <> 'fa_ciptax_api_pkg.cip_retirement' then

     -- check to make sure that the transaction is not for CIP on TAX book
     -- since we do not allow retirement of CIP directly in TAX book.
     -- Instead retirement of CIP on TAX book can be copied through CORP book only.
     if l_validation_type = g_retirement then

        -- call the cache for the transaction book
        if not fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check to make sure that the transaction is not for CIP on TAX book', '', p_log_level_rec => p_log_level_rec); end if;
        if fa_cache_pkg.fazcbc_record.book_class = 'TAX'
           and l_asset_type_rec.asset_type = 'CIP' then

             -- we do not support this transaction
             if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform this transaction on CIP asset.', '', p_log_level_rec => p_log_level_rec); end if;
             g_msg_name := null;
             g_token1 := null;
             raise FND_API.G_EXC_ERROR;

        end if;

     elsif l_validation_type in (g_reinstatement
                           ,g_undo_retirement
                           ,g_undo_reinstatement) then

        -- call the cache for the transaction book
        if not fa_cache_pkg.fazcbc(x_book => lv_asset_retire_rec.detail_info.book_type_code, p_log_level_rec => p_log_level_rec) then
             g_msg_name := null;
             g_token1 := null;
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        if fa_cache_pkg.fazcbc_record.book_class = 'TAX'
           and l_asset_type_rec.asset_type = 'CIP' then

             -- we do not support this transaction
             if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform this transaction on CIP asset.', '', p_log_level_rec => p_log_level_rec); end if;
             g_msg_name := null;
             g_token1 := null;
             raise FND_API.G_EXC_ERROR;

        end if;

     end if; -- check CIP on TAX

   end if; -- check p_calling_fn


   if l_validation_type = g_reinstatement then
   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check to make sure that units_retired is valid', '', p_log_level_rec => p_log_level_rec); end if;

      if l_asset_retire_rec.units_retired is not null then

           -- default units_to_reinsate to total units retired before
           l_asset_retire_rec.units_retired := -1 * l_asset_retire_rec.units_retired;

           -- check to make sure that units_retired is negative
           if l_asset_retire_rec.units_retired > 0 then
                g_msg_name := 'FA_SHARED_LESS_THAN_ZERO'; -- ? may need to add to msg table
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
           end if;

           -- check to make sure that units_retired for reinstatement
           -- does not exceed the units_retired in retirement row.
           if (-1 * l_asset_retire_rec.units_retired)
              > lv_asset_retire_rec.units_retired then
                g_msg_name := 'FA_RET_UNITS_TOO_BIG'; -- Is this correct message even for reinstatement ?
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
           end if;

      end if;

   end if;

   -- check if distributions have valid info if trx is PARTIAL unit retirement
   -- or PARTIAL unit reinstatement.
   -- check if asset_dist_tbl has all valid units in distributions
   -- check if distribution lines are out of balance
   -- msg name: FA_RET_UNIS_OUT_OF_BALANCE
   -- msg text: Distribution lines are out of balance
   --           Cause: The sum of the distributed units is not equal to the total units of ....

   if l_validation_type in (g_retirement, g_reinstatement) then
      if l_asset_retire_rec.units_retired is not null
         and l_asset_dist_tbl.count > 0 then

           -- check if units_retired is a whole number
           -- make sure that units_retired is a whole number
           if trunc(l_asset_retire_rec.units_retired)
              <> l_asset_retire_rec.units_retired then

                -- g_msg_name := 'VALUE_MUST_BE_POSITIVE_INT'; -- this must be generic enough to be also good for reinstatement since units_retired for reinstatement should be negative.
      /* Bug 6817771 - Starts
         commented following line and added next lines to have meaning ful error message and debug messages*/
                --g_msg_name := null;
                fa_debug_pkg.add(l_calling_fn, 'Error!', 'cant retire partial units.Please provide whole number.');
                fa_debug_pkg.add(l_calling_fn,'Asset ID', l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn,'Ret. Units',l_asset_retire_rec.units_retired, p_log_level_rec => p_log_level_rec);
                g_msg_name := 'FA_RET_NO_FRAC_UNITS';
     /* Bug 6817771 - Ends */
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
           end if;

           -- check if distributions are valid
           if l_asset_dist_tbl.count >= 1 then

                -- check if the sum of units in all distributions is equal
                -- to the total units_retired

                l_sum_units := 0;

                for i in 1..l_asset_dist_tbl.count loop

                      l_sum_units := l_sum_units
                                     + l_asset_dist_tbl(i).transaction_units;

                      -- check if provided dist_id is valid
                      if l_asset_dist_tbl(i).distribution_id is not null then

                           if not FA_ASSET_VAL_PVT.validate_dist_id
                                  (p_asset_id  => l_asset_hdr_rec.asset_id
                                  ,p_dist_id   => l_asset_dist_tbl(i).distribution_id
                                  ,p_log_level_rec  => p_log_level_rec
                                  ) then
                                      -- Error: Unable to get distribution information
                                      g_msg_name := 'FA_EXP_FETCH_DH';
                                      g_token1 := null;
                                      raise FND_API.G_EXC_ERROR;
                           end if;

                      else -- if dist is null
                           -- error out since dist_id can not be null
                           g_msg_name := 'FA_API_SHARED_INVALID_NOTNULL';
                           g_token1 := 'XMLTAG';
                           g_value1 := 'DISTRIBUTION_ID';
                           raise FND_API.G_EXC_ERROR;
                      end if;

                end loop;

                -- error out when the two values are not equal
                if (l_sum_units*-1) <> l_asset_retire_rec.units_retired then
                     g_msg_name := 'FA_RET_UNIS_OUT_OF_BALANCE';
                     g_token1 := null;
                     raise FND_API.G_EXC_ERROR;
                end if;

           else
                -- error out: need at least one row in asset_dist_tbl type
                --            if this is partial unit retirement
                g_msg_name := 'FA_API_SHARED_INVALID_NOTNULL';
                g_token1 := 'XMLTAG';
                g_value1 := 'ASSET_DIST_TBL_REC';
                raise FND_API.G_EXC_ERROR;
           end if;

      end if; -- units_retired
   end if; -- if g_ret or g_reinst

   -- check that the retired date of retirement is within the current
   -- fiscal year
   if l_validation_type=g_retirement
      and l_asset_retire_rec.date_retired is not null then

        -- ? this validation will be replaced properly later
        -- fa_date.validate('LOW_RANGE', l_asset_retire_rec.date_retired);

        -- check if transaction date(date_retired) is in the current fiscal year
        -- date must be in current fiscal year
        if l_asset_retire_rec.date_retired < l_period_rec.fy_start_date
           or l_asset_retire_rec.date_retired > l_period_rec.fy_end_date then
              g_msg_name := 'FA_RET_DATE_MUSTBE_IN_CUR_FY';
              g_token1 := null;
              raise FND_API.G_EXC_ERROR;
        end if;

        -- check if date_retired is a future date
        -- date_retired must not be in a future period
        if l_asset_retire_rec.date_retired
           > l_period_rec.calendar_period_close_date then
                g_msg_name := 'FA_SHARED_CANNOT_FUTURE';
                g_token1 := null;
                raise FND_API.G_EXC_ERROR;
        end if;

        --Bug7589916: check that date_retired is not prior to dpis.
        if (l_asset_retire_rec.date_retired < l_asset_fin_rec.Date_Placed_In_Service) then
                g_msg_name := 'FA_INVALID_RETIRE_DATE';
                g_token1 := null;
               raise FND_API.G_EXC_ERROR;
        end if;

   end if;

   -- check that the retired date of the retirement to reinstate is within the current
   -- fiscal year
   if l_validation_type=g_reinstatement
      and lv_asset_retire_rec.date_retired is not null then

        -- check if transaction date(date_retired) is in the current fiscal year
        -- date must be in current fiscal year
        if lv_asset_retire_rec.date_retired < l_period_rec.fy_start_date
           or lv_asset_retire_rec.date_retired > l_period_rec.fy_end_date then
              if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not reinstate assets that were retired in previous fiscal year', '', p_log_level_rec => p_log_level_rec); end if;
              g_msg_name := 'FA_RET_DATE_MUSTBE_IN_CUR_FY';
              g_token1 := null;
              raise FND_API.G_EXC_ERROR;
        end if;

   end if;

   -- check if date_retired/retirement_convention is valid
   if l_validation_type = g_retirement
      and l_asset_retire_rec.date_retired is not null then

        -- validate retirement_prorate_convention if it is not null
        if l_asset_retire_rec.retirement_prorate_convention is not null then
             if not fa_cache_pkg.fazccvt
                      (x_prorate_convention_code => l_asset_retire_rec.retirement_prorate_convention,
                       x_fiscal_year_name        => fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec) then
                g_msg_name := 'FA_RET_CANT_GET_RET_PRO_DATE';
                g_token1   := null;

                raise FND_API.G_EXC_ERROR;
             end if;
        end if;

   end if; -- date_retired/retirement_convention

   --
   -- Validating date retired for member asset
   -- No prior period nor overlapping retirement trx
   -- with other trxs are allowed.
   --
   if l_validation_type = g_retirement and
      l_asset_retire_rec.date_retired is not null and
      l_asset_fin_rec.group_asset_id is not null then
      l_trx_date := null;
      OPEN c_last_grp_reclass;
      FETCH c_last_grp_reclass INTO l_trx_date;
      CLOSE c_last_grp_reclass;

      if l_trx_date is not null then
         g_msg_name := 'FA_SHARED_OTHER_TRX_FOLLOW';
         raise FND_API.G_EXC_ERROR;
      end if;

      if p_period_rec.calendar_period_open_date
             > l_asset_retire_rec.date_retired then
         g_msg_name := 'FA_NO_PRIOR_RET';
         raise FND_API.G_EXC_ERROR;
      end if;

   end if;



   -- check to make sure that the transaction is doable
   if l_validation_type = g_retirement then

         -- check if the asset has already been fully retired
         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if the asset is already fully retired', '', p_log_level_rec => p_log_level_rec); end if;
         if FA_ASSET_VAL_PVT.validate_fully_retired
           (p_asset_id  => l_asset_hdr_rec.asset_id
           ,p_book      => l_asset_hdr_rec.book_type_code
           , p_log_level_rec => p_log_level_rec) then
               g_msg_name := 'FA_REC_RETIRED';
               g_token1 := null;
               raise FND_API.G_EXC_ERROR;
         end if;

         if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'check if the asset in extended life', '', p_log_level_rec => p_log_level_rec); end if;
         --Bug#8941124
         --Added the check to restrict prior period retirement if in the same period of extended depreciation.
         open c_check_extended_deprn;
         fetch c_check_extended_deprn into l_chk_ext_deprn;
         close c_check_extended_deprn;

         if l_chk_ext_deprn = 'Y' then
            if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform prior period retirement in extended deprn period.', '', p_log_level_rec => p_log_level_rec); end if;
            g_msg_name := 'FA_JP_PRIOR_PD_RET_NOT_ALLOWED ';
            g_token1 := null;
            raise FND_API.G_EXC_ERROR;
         end if;

         --Bug7565002
         --Added the check to restrict full retirement if it overlaps any other transaction.
         --Bug 8602209 ..should allow full retirement if retirement prorate date falls in same
         --period in which adjustment is done
         --Bug 8627512 need to check for AMORTIZED adjustments only.
           if  l_asset_retire_rec.units_retired = l_asset_desc_rec.current_units  or
               l_asset_retire_rec.cost_retired = l_asset_fin_rec.cost or
               l_asset_fin_rec.cost = 0 then
             begin
                select distinct 'Y'
                into l_trans_flag
                from
                fa_transaction_headers th,
                fa_calendar_periods cp,
                fa_book_controls bc,
                fa_conventions con
                where th.book_type_code = l_asset_hdr_rec.book_type_code
                and th.asset_id = l_asset_hdr_rec.asset_id
                and con.prorate_convention_code = l_asset_retire_rec.retirement_prorate_convention
                and l_asset_retire_rec.date_retired between con.start_date and con.end_date
                and bc.book_type_code = th.book_type_code
                and cp.calendar_type = bc.deprn_calendar
                and con.prorate_date between cp.start_date and cp.end_date
                and th.transaction_date_entered > cp.end_date
                and th.transaction_type_code NOT IN ('ADDITION','TRANSFER IN')
                and th.TRANSACTION_SUBTYPE = 'AMORTIZED';
             exception
                When NO_DATA_FOUND then
                        l_trans_flag := 'N';
             end;
             if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'l_trans_flag'
                                  , l_trans_flag, p_log_level_rec => p_log_level_rec);
             end if;
             if l_trans_flag = 'Y' then
                   if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn,
                            'Error: You can not perform this transaction.', '', p_log_level_rec => p_log_level_rec);
                   end if;
                   g_msg_name := 'FA_OVERLAP_FUL_RET';
                   raise FND_API.G_EXC_ERROR;
             end if;
           end if;

         /*Bug# 8527619 */
         if (l_asset_fin_rec.group_asset_id is not null)    and
            (l_asset_retire_rec.recognize_gain_loss = 'NO') and
            (l_asset_fin_rec.over_depreciate_option = fa_std_types.FA_OVER_DEPR_NO) then
            if not FA_ASSET_VAL_PVT.validate_over_depreciation
               (p_asset_hdr_rec      => l_asset_hdr_rec,
                p_asset_fin_rec      => l_asset_fin_rec,
                p_validation_type    => g_retirement,
                p_cost_adj           => l_asset_retire_rec.cost_retired,
                p_rsv_adj            => l_asset_retire_rec.cost_retired,
                p_log_level_rec => g_log_level_rec) then
               g_msg_name := null;
               g_token1 := null;
               raise FND_API.G_EXC_ERROR;
            end if;
         end if;


   elsif l_validation_type = g_reinstatement then

      if lv_asset_retire_rec.status <> 'PROCESSED' then
            if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform this transaction.', '', p_log_level_rec => p_log_level_rec); end if;
            g_msg_name := null;
            g_token1 := null;
            raise FND_API.G_EXC_ERROR;
      end if;

      SELECT nvl(max(transaction_header_id),0)
      INTO   l_latest_ret_thid
      FROM   fa_transaction_headers
      WHERE  asset_id = l_asset_hdr_rec.asset_id
        AND  book_type_code = l_asset_hdr_rec.book_type_code
        AND  transaction_key = 'R'
        AND  transaction_type_code||'' like '%RETIREMENT';

     if l_latest_ret_thid
        <> lv_asset_retire_rec.detail_info.transaction_header_id_in then
            g_msg_name := 'FA_CREATE_NOT_ALLOWED';
            g_token1 := null;
            raise FND_API.G_EXC_ERROR;
     end if;

     /*Bug# 8527619 */
     if l_asset_fin_rec.group_asset_id is not null then
        if not FA_ASSET_VAL_PVT.validate_over_depreciation
            (p_asset_hdr_rec => l_asset_hdr_rec,
             p_asset_fin_rec => l_asset_fin_rec,
             p_asset_retire_rec     =>l_asset_retire_rec,
             p_validation_type    => g_reinstatement,
             p_cost_adj           => 0,
             p_rsv_adj            => 0,
           p_log_level_rec => g_log_level_rec) then
           g_msg_name := null;
           g_token1 := null;
           raise FND_API.G_EXC_ERROR;
         end if;
      end if;
      /* Bug 8633654 */
      if (not fa_cache_pkg.fazccmt(l_asset_fin_rec.deprn_method_code,
                                   l_asset_fin_rec.life_in_months
                                   ,p_log_level_rec => p_log_level_rec)) then
         if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt'
                           ,p_log_level_rec => p_log_level_rec);
         end if;

         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      if ( nvl(fa_cache_pkg.fazcdrd_record.rule_name,'ZZ') = 'ENERGY PERIOD END BALANCE' and
          nvl(l_asset_fin_rec.tracking_method, 'NO TRACK') = 'ALLOCATE') then
         if not FA_ASSET_VAL_PVT.validate_mbr_reins_possible
               (p_asset_retire_rec  =>l_asset_retire_rec,
               p_asset_fin_rec      => l_asset_fin_rec,
               p_log_level_rec => g_log_level_rec
               ) then
            raise FND_API.G_EXC_ERROR;
         end if;
      end if;
      /* Bug 8633654 ends */

   elsif l_validation_type = g_undo_retirement then

      -- ? Is PARTIAL required ?  when is it used ?
      if lv_asset_retire_rec.status not in ('PENDING','PARTIAL') then
            if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform this transaction.', '', p_log_level_rec => p_log_level_rec); end if;
            g_msg_name := null;
            g_token1 := null;
            raise FND_API.G_EXC_ERROR;
      end if;

      /*---------------------------------------------------------------+
      | Bug 1577955.                                                   |
      | We need to check if there are any partial Unit Retirements in  |
      | the Corporate book. Then we check if there were any cost       |
      | adjustments or if depreciation was run on  any of the          |
      | associated Tax books before running Gain/Loss in the Corporate |
      | book. If that is the case, we will not allow                   |
      | the use of the 'Undo Retirement' function.                     |
      | Instead, Gain/Loss must be run on the Corp book first          |
      | and then you may reinstate the asset.                          |
      +---------------------------------------------------------------+*/

      if FA_ASSET_VAL_PVT.validate_corp_pending_ret
         (p_asset_id                  => l_asset_hdr_rec.asset_id
         ,p_book                      => l_asset_hdr_rec.book_type_code
         ,p_transaction_header_id_in  => lv_asset_retire_rec.detail_info.transaction_header_id_in
         , p_log_level_rec => p_log_level_rec) then
             g_msg_name := 'FA_RET_CORP_PENDING_RETIREMENT';
             g_token1 := null;
             raise FND_API.G_EXC_ERROR;
      end if;

   elsif l_validation_type = g_undo_reinstatement then

      if lv_asset_retire_rec.status not in ('REINSTATE') then
            if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'Error: You can not perform this transaction.', '', p_log_level_rec => p_log_level_rec); end if;
             g_msg_name := null;
             g_token1 := null;
            raise FND_API.G_EXC_ERROR;
      end if;

   end if;



/***** ? Need to investigate the difference between PARTIAL and PENDING in forms code

   elsif (:retire.status = 'PARTIAL') then
     fa_retirements_val.toggle_retire_button('UNDO RETIRE');
     set_retire_fields('OFF');
     --
   elsif (:retire.status = 'PENDING') then
     fa_retirements_val.toggle_retire_button('UNDO RETIRE');
     set_retire_fields('ON');
     --
   elsif (:retire.status = 'REINSTATE') then
     fa_retirements_val.toggle_retire_button('UNDO REINSTATE');
     set_retire_fields('OFF');

***/

   return TRUE;

EXCEPTION

   when FND_API.G_EXC_ERROR then

          if g_token1 is null then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      , p_log_level_rec => p_log_level_rec);
          else
               fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                      ,name       => g_msg_name
                                      ,token1     => g_token1
                                      ,value1     => g_value1
                                      , p_log_level_rec => p_log_level_rec);
          end if;

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

   when FND_API.G_EXC_UNEXPECTED_ERROR then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn
                                 , p_log_level_rec => p_log_level_rec);
          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

   when others then

          fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
          return FALSE;

END do_validation;

/*====================================================================+
 | Function                                                           |
 |   REINSTATE_SRC_LINE                                               |
 |                                                                    |
 | Description                                                        |
 |   This is similar to FA_CUA_REINSTATE_APIS_PKG.REINSTATE_SRC_LINE. |
 |   The function has been modified to handle mrc as well by calling  |
 |   Invoice API instead of making direct DML call.                   |
 |                                                                    |
 +====================================================================*/
FUNCTION REINSTATE_SRC_LINE(
                  px_trans_rec             IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                  px_asset_hdr_rec         IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                  px_asset_fin_rec         IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
                  p_asset_desc_rec         IN     FA_API_TYPES.asset_desc_rec_type,
                  p_invoice_transaction_id IN     NUMBER,
                  p_inv_tbl                IN     FA_API_TYPES.inv_tbl_type,
                  p_rowid                  IN     ROWID,
                  p_calling_fn             IN     VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN Is

  l_calling_fn             VARCHAR2(80) := 'fa_retirement_pub.reinstate_src_line';

  CURSOR  New_Asset_Invoices_C (c_asset_invoice_id NUMBER) is
  SELECT  SOURCE_LINE_ID
        , FIXED_ASSETS_COST
  FROM    FA_ASSET_INVOICES
  WHERE   INVOICE_TRANSACTION_ID_IN = p_invoice_transaction_id
  AND     ASSET_INVOICE_ID = c_asset_invoice_id;

  -- added a condition asset_id = c_asset_id for high-cost sql fix
  CURSOR  Old_Asset_Invoices_C (c_asset_id NUMBER) is
  SELECT  ASSET_INVOICE_ID
        , FIXED_ASSETS_COST
        , SOURCE_LINE_ID
  FROM    FA_ASSET_INVOICES
  WHERE   INVOICE_TRANSACTION_ID_OUT = p_invoice_transaction_id
  AND     ASSET_ID = c_asset_id;

  /*
   * For calling invoice api
   */
  l_trans_rec               FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
  l_asset_cat_rec           FA_API_TYPES.asset_cat_rec_type;
  l_asset_type_rec          FA_API_TYPES.asset_type_rec_type;
  l_new_asset_fin_rec       FA_API_TYPES.asset_fin_rec_type;
  l_new_asset_fin_mrc_tbl   FA_API_TYPES.asset_fin_tbl_type;
  l_inv_tbl                 FA_API_TYPES.inv_tbl_type;
  l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
  l_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;

  l_ind                     BINARY_INTEGER;

  l_temp_src_line_id        NUMBER;
  l_fixed_assets_cost       NUMBER;

BEGIN

  if (nvl(p_inv_tbl.last, 0) = 0) then
    l_inv_tbl.delete;

    OPEN Old_Asset_Invoices_C(px_asset_hdr_rec.asset_id);

    l_ind := 0;

    /*
     * Populate old source line fixed_assets_cost for reinstatement
     */
    LOOP

      l_ind := l_ind + 1;
      l_temp_src_line_id := to_number(null);
      l_fixed_assets_cost := to_number(null);

      FETCH Old_Asset_Invoices_C INTO l_inv_tbl(l_ind).asset_invoice_id,
                                      l_inv_tbl(l_ind).fixed_assets_cost,
                                      l_temp_src_line_id;
      EXIT when Old_Asset_Invoices_C%NOTFOUND;

      OPEN New_Asset_Invoices_C (l_inv_tbl(l_ind).asset_invoice_id);
      FETCH New_Asset_Invoices_C INTO l_inv_tbl(l_ind).source_line_id,
                                      l_fixed_assets_cost;
      CLOSE New_Asset_Invoices_C;

      /*
       * Invoice API now does NOT default this flag to 'NO'
       */
      if (l_inv_tbl(l_ind).source_line_id is null) then
        l_inv_tbl(l_ind).source_line_id := l_temp_src_line_id;
        l_inv_tbl(l_ind).fixed_assets_cost := 0;
      else
        l_inv_tbl(l_ind).fixed_assets_cost := l_inv_tbl(l_ind).fixed_assets_cost -
                                              l_fixed_assets_cost;
      end if;

    End Loop;

    CLOSE Old_Asset_Invoices_C;

  else
    l_inv_tbl := p_inv_tbl;
  end if;

  if (nvl(l_inv_tbl.last, 0) > 0) then
    -- Populate asset_cat_rec
    -- Populating p_asset_cat_rec which may not be necessary since
    -- Invoice API seems not using it  as of Feb 2002
    if not FA_UTIL_PVT.get_asset_cat_rec (
                               p_asset_hdr_rec  => px_asset_hdr_rec,
                               px_asset_cat_rec => l_asset_cat_rec,
                               p_date_effective  => NULL, p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    if not FA_UTIL_PVT.get_asset_type_rec (
                               p_asset_hdr_rec      => px_asset_hdr_rec,
                               px_asset_type_rec    => l_asset_type_rec,
                               p_date_effective     => NULL, p_log_level_rec => p_log_level_rec) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    l_trans_rec     := px_trans_rec;
    l_asset_hdr_rec := px_asset_hdr_rec;

    l_inv_trans_rec.invoice_transaction_id := to_number(null);
    l_inv_trans_rec.transaction_type := 'REINSTATEMENT';

    if not FA_INVOICE_PVT.INVOICE_ENGINE (
                               px_trans_rec              => l_trans_rec,
                               px_asset_hdr_rec          => l_asset_hdr_rec,
                               p_asset_desc_rec          => p_asset_desc_rec,
                               p_asset_type_rec          => l_asset_type_rec,
                               p_asset_cat_rec           => l_asset_cat_rec,
                               p_asset_fin_rec_adj       => px_asset_fin_rec,
                               x_asset_fin_rec_new       => l_new_asset_fin_rec,
                               x_asset_fin_mrc_tbl_new   => l_new_asset_fin_mrc_tbl,
                               px_inv_trans_rec          => l_inv_trans_rec,
                               px_inv_tbl                => l_inv_tbl,
                               x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                               x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
                               p_calling_fn              => l_calling_fn,
                               p_log_level_rec => p_log_level_rec) then
      if p_log_level_rec.statement_level then
        fa_debug_pkg.add(l_calling_fn, 'Error Calling FA_INVOICE_PVT.INVOICE_ENGINE', '',  p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn, 'SQLERRM: ', SQLERRM, p_log_level_rec => p_log_level_rec);
      end if;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    FA_TRANSACTION_HEADERS_PKG.UPDATE_ROW(
               X_Rowid                  => p_rowid,
               X_Invoice_Transaction_Id => l_inv_trans_rec.invoice_transaction_id,
               X_Calling_Fn             => l_calling_fn, p_log_level_rec => p_log_level_rec);

  end if; -- (nvl(l_inv_tbl.last, 0) > 0)

  return TRUE;

EXCEPTION
  when OTHERS then

    if New_Asset_Invoices_C%ISOPEN then
      CLOSE New_Asset_Invoices_C;
    end if;

    if Old_Asset_Invoices_C%ISOPEN then
      CLOSE Old_Asset_Invoices_C;
    end if;

    fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn
                                   , p_log_level_rec => p_log_level_rec);
    return FALSE;

END REINSTATE_SRC_LINE;
---------------------------------------
END FA_RETIREMENT_PUB;

/
