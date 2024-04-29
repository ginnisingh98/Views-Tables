--------------------------------------------------------
--  DDL for Package Body FA_CIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CIP_PUB" as
/* $Header: FAPCIPB.pls 120.18.12010000.2 2009/07/19 14:27:04 glchen ship $   */

--*********************** Global constants ******************************--

G_PKG_NAME      CONSTANT   varchar2(30) := 'FA_CIP_PUB';
G_API_NAME      CONSTANT   varchar2(30) := 'Capitalization/Reverse API';
G_API_VERSION   CONSTANT   number       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private functions ******************************--

FUNCTION do_cap_rev
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_cap_rev                  IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

-- private declaration for books (mrc) wrapper

FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    px_asset_type_rec          IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

--*********************** Public procedures ******************************--

PROCEDURE do_capitalization
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type) IS

   l_cap_rev                   VARCHAR2(10) := 'CAPITALIZE';
   l_calling_fn                VARCHAR2(30) := 'fa_cip_pub.do_capitalization';
   cap_err                     EXCEPTION;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise cap_err;
      end if;
   end if;

   px_trans_rec.transaction_type_code := 'CAPITALIZE';

   if not do_cap_rev (
      p_api_version           => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      p_commit                => p_commit,
      p_validation_level      => p_validation_level,
      p_calling_fn            => p_calling_fn,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      px_trans_rec            => px_trans_rec,
      px_asset_hdr_rec        => px_asset_hdr_rec,
      px_asset_fin_rec        => px_asset_fin_rec,
      p_cap_rev               => l_cap_rev,
      p_log_level_rec         => g_log_level_rec
   ) then
      raise cap_err;
   end if;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   return;

EXCEPTION

   WHEN CAP_ERR THEN

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from cip-in-taxapi allow calling program to dump them
--      if (nvl(p_calling_fn, 'N') <> 'fa_ciptax_api_pkg.cip_adj') then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
--      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return;

   WHEN OTHERS THEN

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from cip-in-taxapi allow calling program to dump them
--      if (nvl(p_calling_fn, 'N') <> 'fa_ciptax_api_pkg.cip_adj') then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
--      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return;

END do_capitalization;

PROCEDURE do_reverse
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type) IS

   l_cap_rev                   VARCHAR2(10) := 'REVERSE';
   l_calling_fn                VARCHAR2(30) := 'fa_cip_pub.do_reverse';
   rev_err                     EXCEPTION;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise rev_err;
      end if;
   end if;

   px_trans_rec.transaction_type_code := 'REVERSE';

   if not do_cap_rev (
      p_api_version           => p_api_version,
      p_init_msg_list         => p_init_msg_list,
      p_commit                => p_commit,
      p_validation_level      => p_validation_level,
      p_calling_fn            => p_calling_fn,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      px_trans_rec            => px_trans_rec,
      px_asset_hdr_rec        => px_asset_hdr_rec,
      px_asset_fin_rec        => px_asset_fin_rec,
      p_cap_rev               => l_cap_rev,
      p_log_level_rec         => g_log_level_rec
   ) then
      raise rev_err;
   end if;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   return;


EXCEPTION

   WHEN REV_ERR THEN

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from cip-in-taxapi allow calling program to dump them
--      if (nvl(p_calling_fn, 'N') <> 'fa_ciptax_api_pkg.cip_adj') then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
--      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return;

   WHEN OTHERS THEN

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      -- do not retrieve / clear messaging when this is being called
      -- from cip-in-taxapi allow calling program to dump them
--      if (nvl(p_calling_fn, 'X') <> 'fa_ciptax_api_pkg.cip_adj') then
         FA_DEBUG_PKG.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
         FND_MSG_PUB.count_and_get (
            p_count => x_msg_count,
            p_data  => x_msg_data
         );
--      end if;

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return;

END do_reverse;

--*********************** Private procedures ******************************--

FUNCTION do_cap_rev
   (p_api_version              IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_calling_fn               IN     VARCHAR2,
    x_return_status               OUT NOCOPY VARCHAR2,
    x_msg_count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT NOCOPY VARCHAR2,

    px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_cap_rev                  IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_reporting_flag            VARCHAR2(1);
   l_count                     NUMBER := 0;

   l_asset_desc_rec            FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec            FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec             FA_API_TYPES.asset_cat_rec_type;

   -- Bug 8252607/5475276 Cursor to get the book_type_code
   CURSOR c_corp_book( p_asset_id number ) IS
   SELECT bc.book_type_code
     FROM fa_books bks,
          fa_book_controls bc
    WHERE bks.book_type_code = bc.distribution_source_book
      AND bks.book_type_code = bc.book_type_code
      AND bks.asset_id       = p_asset_id
      AND bks.transaction_header_id_out is null;

   -- used for tax books when doing cip-in-tax or autocopy
   l_trans_rec                 FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec             FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec             FA_API_TYPES.asset_fin_rec_type;
   l_tax_book_tbl              FA_CACHE_PKG.fazctbk_tbl_type;
   l_tax_index                 NUMBER;  -- index for tax loop

   l_calling_fn                VARCHAR2(30) := 'fa_cip_pub.do_cap_rev';
   cap_rev_err                 EXCEPTION;

   --Added following variables for bugfix# 5155488
   l_period_of_addition_flag   varchar2(1);
   l_dist_trans_rec            FA_API_TYPES.trans_rec_type;
   l_asset_hierarchy_rec       FA_API_TYPES.asset_hierarchy_rec_type;
   l_asset_deprn_rec           FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_rec            FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl            FA_API_TYPES.asset_dist_tbl_type;
   l_inv_tbl                   FA_API_TYPES.inv_tbl_type;
   l_return_status             VARCHAR2(1);
   l_mesg_count                number := 0;
   l_mesg_len                  number;
   l_mesg                      varchar2(4000);
   l_corp_thid		       number;


BEGIN

   savepoint  do_cap_rev;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise cap_rev_err;
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
      raise cap_rev_err;
   end if;

    -- Bug 8252607/5475276 Get the book_type_code if it is not supplied.
    if (px_asset_hdr_rec.book_type_code is null) then
        open c_corp_book( px_asset_hdr_rec.asset_id );
	fetch c_corp_book into px_asset_hdr_rec.book_type_code;
	close c_corp_book;

	if px_asset_hdr_rec.book_type_code is null then
	   fa_srvr_msg.add_message
	      (calling_fn => l_calling_fn,
	       name       => 'FA_EXP_GET_ASSET_INFO', p_log_level_rec => p_log_level_rec);
           raise cap_rev_err;
 	end if;
    end if;

   -- call the cache for the primary transaction book
   if NOT fa_cache_pkg.fazcbc(X_book => px_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- commenting this out until after complete uptake of apis
   -- (in this case from cap form and massadd) at which point
   -- the interim fa_ciptax_api_pkg will be obsolete and this
   -- package will and must only be called for corporate book
   -- (the if condition for book class for the cip-tax loop
   --  will also become obsolete)
   --
   -- if (fa_cache_pkg.fazcbc_record.book_class <> 'CORPORATE') then
   --          fa_srvr_msg.add_message
   --               (calling_fn => l_calling_fn,
   --                name       => '**FA_NO_DIR_CAP_TAX***');
   --    raise cap_rev_err;
   -- end if;

   px_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
   -- verify the asset exist in the book already
   if not FA_ASSET_VAL_PVT.validate_asset_book
              (p_transaction_type_code      => 'CAPITALIZATION',
               p_book_type_code             => px_asset_hdr_rec.book_type_code,
               p_asset_id                   => px_asset_hdr_rec.asset_id,
               p_calling_fn                 => 'fa_adjustment_pub.do_adjustment'
              , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;


   -- get the current info for the primary book

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                      'in main, sobid', px_asset_hdr_rec.set_of_books_id, p_log_level_rec => p_log_level_rec);
   end if;

   -- Account for transaction submitted from a responsibility
   -- that is not tied to a SOB_ID by getting the value from
   -- the book struct

   -- Get the book type code P,R or N
   if not fa_cache_pkg.fazcsob
      (X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
       X_mrc_sob_type_code => l_reporting_flag
      , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   --  Error out if the program is submitted from the Reporting Responsibility
   --  No transaction permitted directly on reporting books.

   IF l_reporting_flag = 'R' THEN
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => 'MRC_OSP_INVALID_BOOK_TYPE', p_log_level_rec => p_log_level_rec);
      raise cap_rev_err;
   END IF;

   -- end initial MRC validation


   -- set trx type
   if p_cap_rev = 'CAPITALIZE' then
      px_trans_rec.transaction_type_code := 'ADDITION';

   elsif p_cap_rev = 'REVERSE' then
      px_trans_rec.transaction_type_code := 'CIP REVERSE';
   else
      fa_srvr_msg.add_message
          (calling_fn => l_calling_fn,
           name       => '***INVALID_TRX_TYPE***',
                   p_log_level_rec => p_log_level_rec);
      raise cap_rev_err;
   end if;


   -- load the needed structs
   if not FA_UTIL_PVT.get_asset_desc_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_desc_rec       => l_asset_desc_rec
          , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   if not FA_UTIL_PVT.get_asset_cat_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_cat_rec        => l_asset_cat_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec
          (p_asset_hdr_rec         => px_asset_hdr_rec,
           px_asset_type_rec       => l_asset_type_rec,
           p_date_effective        => null
          , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- remove after api update
   -- verify the transaction / asset type combi is valid for corp books

   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      if (((l_asset_type_rec.asset_type = 'CIP') and
           (px_trans_rec.transaction_type_code = 'CIP REVERSE')) or
          ((l_asset_type_rec.asset_type = 'CAPITALIZED') and
           (px_trans_rec.transaction_type_code = 'ADDITION')) or
          (l_asset_type_rec.asset_type  = 'EXPENSED')) then

         fa_srvr_msg.add_message
             (calling_fn => l_calling_fn,
              name       => '***INVALID_COMBO***',
                   p_log_level_rec => p_log_level_rec);
         raise cap_rev_err;

      end if;

   end if;

   if not do_all_books
      (px_trans_rec               => px_trans_rec,
       px_asset_hdr_rec           => px_asset_hdr_rec ,
       p_asset_desc_rec           => l_asset_desc_rec ,
       px_asset_type_rec          => l_asset_type_rec,
       p_asset_cat_rec            => l_asset_cat_rec ,
       px_asset_fin_rec           => px_asset_fin_rec ,
       p_log_level_rec            => p_log_level_rec
      )then
      raise cap_rev_err;
   end if;


   -- remove the if condition after api update as this will always be corp book
   -- If book is a corporate book, process cip assets and autocopy

   if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then

      -- null out the deprn_adj table as we do not want to autocopy
      -- any deprn info to tax books
      -- still need to DO THIS!!!

      l_trans_rec                       := px_trans_rec;
      l_asset_hdr_rec                   := px_asset_hdr_rec;


      -- ideally we may want to revisit this and get the CAP version
      -- of the cache when in period of addition and changing to
      -- capitalization, calling the additions api or for reversals
      -- deleting the asset from tax books in period of addition
      -- if allow cip assets is not enabled.

      if not fa_cache_pkg.fazctbk
                (x_corp_book    => px_asset_hdr_rec.book_type_code,
                 x_asset_type   => 'CIP',
                 x_tax_book_tbl => l_tax_book_tbl, p_log_level_rec => p_log_level_rec) then
         raise cap_rev_err;
      end if;

      for l_tax_index in 1..l_tax_book_tbl.count loop

          l_asset_fin_rec := null;

	  if (p_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn,
                               'in do_cap_rev processing tax book', l_tax_book_tbl(l_tax_index));
          end if;

          -- verify that the asset exists in the tax book
          -- if not just bypass it without failing

	  if not (FA_ASSET_VAL_PVT.validate_asset_book
                    (p_transaction_type_code      => 'CAPITALIZATION',
                     p_book_type_code             => l_tax_book_tbl(l_tax_index),
                     p_asset_id                   => px_asset_hdr_rec.asset_id,
                     p_calling_fn                 => 'fa_adjustment_pub.do_adjustment',
                     p_log_level_rec              => p_log_level_rec)) then
             --null;
	     -- bugfix# 5155488
	     if not (FA_ASSET_VAL_PVT.validate_period_of_addition
		    (p_asset_id			  => px_asset_hdr_rec.asset_id,
		     p_book			  => px_asset_hdr_rec.book_type_code,
		     px_period_of_addition	  => l_period_of_addition_flag, p_log_level_rec => p_log_level_rec)) then
		raise cap_rev_err;
	     end if;

	     if(nvl(l_period_of_addition_flag,'N') = 'Y') then

		select transaction_header_id
		into l_corp_thid
		from fa_transaction_headers
		where asset_id=px_asset_hdr_rec.asset_id
		and book_type_code=px_asset_hdr_rec.book_type_code
		and transaction_type_code='CIP ADDITION';

		l_asset_hdr_rec.asset_id		 := px_asset_hdr_rec.asset_id;
		l_asset_hdr_rec.book_type_code		 := l_tax_book_tbl(l_tax_index);
		l_trans_rec.source_transaction_header_id := l_corp_thid;
		l_trans_rec.calling_interface            := 'FAXASSET';
		l_trans_rec.mass_reference_id            := px_trans_rec.mass_reference_id;
                l_trans_rec.transaction_header_id        := null;

		select  cost,
			date_placed_in_service,
			group_asset_id,
			salvage_type,
			percent_salvage_value,
			salvage_value
		into    l_asset_fin_rec.cost,
			l_asset_fin_rec.date_placed_in_service,
			l_asset_fin_rec.group_asset_id,
			l_asset_fin_rec.salvage_type,
			l_asset_fin_rec.percent_salvage_value,
			l_asset_fin_rec.salvage_value
		from fa_books
		where asset_id = px_asset_hdr_rec.asset_id
		and book_type_code = fa_cache_pkg.fazcbc_record.distribution_source_book
		and transaction_header_id_in = l_corp_thid;

		if (nvl(fa_cache_pkg.fazcbc_record.copy_group_assignment_flag, 'N') = 'N') then
		    l_asset_fin_rec.group_asset_id := null;
		end if;

	        if (nvl(fa_cache_pkg.fazcbc_record.copy_salvage_value_flag, 'NO') = 'NO') then
		    l_asset_fin_rec.salvage_type          := null;
	            l_asset_fin_rec.percent_salvage_value := null;
		    l_asset_fin_rec.salvage_value         := null;
	        end if;

		FA_ADDITION_PUB.do_addition
			( p_api_version             => 1.0,
		          p_init_msg_list           => FND_API.G_FALSE,
		          p_commit                  => FND_API.G_FALSE,
		          p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
		          x_return_status           => l_return_status,
		          x_msg_count               => l_mesg_count,
		          x_msg_data                => l_mesg,
		          p_calling_fn              => null,
		          px_trans_rec              => l_trans_rec,
		          px_dist_trans_rec         => l_dist_trans_rec,
		          px_asset_hdr_rec          => l_asset_hdr_rec,
		          px_asset_desc_rec         => l_asset_desc_rec,
		          px_asset_type_rec         => l_asset_type_rec,
		          px_asset_cat_rec          => l_asset_cat_rec,
		          px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
		          px_asset_fin_rec          => l_asset_fin_rec,
		          px_asset_deprn_rec        => l_asset_deprn_rec,
		          px_asset_dist_tbl         => l_asset_dist_tbl,
		          px_inv_tbl                => l_inv_tbl
		         );

		if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
		    raise cap_rev_err;
		end if;

	     end if;
	     -- end bugfix# 5155488
          else

             -- cache the book information for the tax book
             if (NOT fa_cache_pkg.fazcbc(X_book => l_tax_book_tbl(l_tax_index),
                                         p_log_level_rec => p_log_level_rec)) then
                raise cap_rev_err;
             end if;

             -- NOTE!!!!
             -- May need to set the transaction date, trx_type, subtype here as well
             -- based on the open period and settings for each tax book in the loop

             l_asset_hdr_rec.book_type_code           := l_tax_book_tbl(l_tax_index);
             l_asset_hdr_rec.set_of_books_id          := fa_cache_pkg.fazcbc_record.set_of_books_id;

             l_trans_rec.source_transaction_header_id := px_trans_rec.transaction_header_id;
             l_trans_rec.mass_reference_id            := px_trans_rec.mass_reference_id;
             l_trans_rec.transaction_header_id        := null;

             -- BUG# 2623092
             -- need to reset trx_type here in order to process tax book
             -- in period of addition

             if p_cap_rev = 'CAPITALIZE' then
                l_trans_rec.transaction_type_code := 'ADDITION';
             elsif p_cap_rev = 'REVERSE' then
                l_trans_rec.transaction_type_code := 'CIP REVERSE';
             end if;
             l_asset_fin_rec.date_placed_in_service   := px_asset_fin_rec.date_placed_in_service;

             -- set the gl sob info for the primary tax book

             if not do_all_books
                (px_trans_rec               => l_trans_rec,              -- tax
                 px_asset_hdr_rec           => l_asset_hdr_rec,         -- tax
                 p_asset_desc_rec           => l_asset_desc_rec,
                 px_asset_type_rec          => l_asset_type_rec,
                 p_asset_cat_rec            => l_asset_cat_rec,
                 px_asset_fin_rec           => l_asset_fin_rec,
                 p_log_level_rec            => p_log_level_rec
               ) then
                raise cap_rev_err;
             end if;

         end if; -- exists in tax book

      end loop; -- tax books

   end if; -- corporate book

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   return TRUE;

EXCEPTION

   when cap_rev_err then
      ROLLBACK TO do_cap_rev;

      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return FALSE;

   when others then
      ROLLBACK TO do_cap_rev;

      fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

      x_return_status :=  FND_API.G_RET_STS_ERROR;

      return FALSE;

END do_cap_rev;

-------------------------------------------------------------------------------

FUNCTION do_all_books
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    px_asset_type_rec          IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   -- used for calling private api for reporting books
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_old        FA_API_TYPES.asset_fin_rec_type;

   -- used for retrieving "new" structs from private api calls
   l_reporting_flag           varchar2(1);
   l_period_rec               FA_API_TYPES.period_rec_type;
   l_sob_tbl                  FA_CACHE_PKG.fazcrsob_sob_tbl_type;

   -- used for get_rate
   l_exchange_date            date;
   l_rate                     number;
   l_result_code              varchar2(15);
   l_exchange_rate            number;
   l_avg_rate                 number;

   l_complete                 varchar2(1);
   l_result_code1             varchar2(15);

   l_transaction_date         date;
   l_date_placed_in_service   date;

   -- used for new group code
   l_group_trans_rec              fa_api_types.trans_rec_type;
   l_group_asset_hdr_rec          fa_api_types.asset_hdr_rec_type;
   l_group_asset_desc_rec         fa_api_types.asset_desc_rec_type;
   l_group_asset_type_rec         fa_api_types.asset_type_rec_type;
   l_group_asset_cat_rec          fa_api_types.asset_cat_rec_type;
   l_group_asset_fin_rec_old      fa_api_types.asset_fin_rec_type;
   l_group_asset_fin_rec_adj      fa_api_types.asset_fin_rec_type;
   l_group_asset_fin_rec_new      fa_api_types.asset_fin_rec_type;
   l_group_asset_deprn_rec_old    fa_api_types.asset_deprn_rec_type;
   l_group_asset_deprn_rec_adj    fa_api_types.asset_deprn_rec_type;
   l_group_asset_deprn_rec_new    fa_api_types.asset_deprn_rec_type;
   l_inv_trans_rec                fa_api_types.inv_trans_rec_type;
   l_group_reclass_options_rec    fa_api_types.group_reclass_options_rec_type;

   l_calling_fn               varchar2(30) := 'fa_cip_pub.do_all_books';
   cap_rev_err                EXCEPTION;

BEGIN

   -- call the category cache used for faxinajc calls
   if not fa_cache_pkg.fazccb
           (X_book        => px_asset_hdr_rec.book_type_code,
            X_cat_id      => p_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- call transaction approval
   if not FA_TRX_APPROVAL_PKG.faxcat
          (X_book              => px_asset_hdr_rec.book_type_code,
           X_asset_id          => px_asset_hdr_rec.asset_id,
           X_trx_type          => px_trans_rec.transaction_type_code,
           X_trx_date          => px_trans_rec.transaction_date_entered,
           X_init_message_flag => 'NO'
          , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- load the period struct for current period info
   if not FA_UTIL_PVT.get_period_rec
           (p_book           => px_asset_hdr_rec.book_type_code,
            p_effective_date => NULL,
            x_period_rec     => l_period_rec
           , p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- check if this is the period of addition - use absolute mode for adjustments
   if not FA_ASSET_VAL_PVT.validate_period_of_addition
             (p_asset_id            => px_asset_hdr_rec.asset_id,
              p_book                => px_asset_hdr_rec.book_type_code,
              p_mode                => 'ABSOLUTE',
              px_period_of_addition => px_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

  -- Bugfix #4730248
  if(px_asset_fin_rec.date_placed_in_service is null) then
	if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
		l_date_placed_in_service := greatest(l_period_rec.calendar_period_open_date,
						     least(sysdate,l_period_rec.calendar_period_close_date));

		px_asset_fin_rec.date_placed_in_service :=
		   to_date(to_char(l_date_placed_in_service,'DD/MM/YYYY'),'DD/MM/YYYY');
	end if;
  end if;
  -- End Bugfix

  -- Default transaction_date_entered
   if ((px_trans_rec.transaction_date_entered is null) and
       (px_asset_fin_rec.date_placed_in_service is null)) then

      if (fa_cache_pkg.fazcbc_record.book_class = 'CORPORATE') then
         -- Default to last day of the period
         l_transaction_date := greatest(l_period_rec.calendar_period_open_date,
                                        least(sysdate,l_period_rec.calendar_period_close_date));
         px_trans_rec.transaction_date_entered :=
            to_date(to_char(l_transaction_date,'DD/MM/YYYY'),'DD/MM/YYYY');
      end if;

   elsif ((px_trans_rec.transaction_date_entered is null) and
          (px_asset_fin_rec.date_placed_in_service is not null)) then
      px_trans_rec.transaction_date_entered :=
         px_asset_fin_rec.date_placed_in_service;
   end if;


   -- remove any time stamps from both dates:
   px_trans_rec.transaction_date_entered :=
      to_date(to_char(px_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');

   px_asset_fin_rec.date_placed_in_service :=
      to_date(to_char(px_asset_fin_rec.date_placed_in_service,'DD/MM/YYYY'),'DD/MM/YYYY');


   -- defaulting within calc engine has been removed for group
   -- explicitly overirde the related fields here
   -- NOTE: not overiding salvage /limit info here
   --


   if not fa_cache_pkg.fazccbd (X_book   => px_asset_hdr_rec.book_type_code,
                                X_cat_id => p_asset_cat_rec.category_id,
                                X_jdpis  => to_number(to_char(px_asset_fin_rec.date_placed_in_service, 'J')),
                                p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;


   px_asset_fin_rec.deprn_method_code       := fa_cache_pkg.fazccbd_record.deprn_method;
   px_asset_fin_rec.life_in_months          := fa_cache_pkg.fazccbd_record.life_in_months;
   px_asset_fin_rec.basic_rate              := fa_cache_pkg.fazccbd_record.basic_rate;
   px_asset_fin_rec.adjusted_rate           := fa_cache_pkg.fazccbd_record.adjusted_rate;
   px_asset_fin_rec.prorate_convention_code := fa_cache_pkg.fazccbd_record.prorate_convention_code;
   px_asset_fin_rec.depreciate_flag         := fa_cache_pkg.fazccbd_record.depreciate_flag;
   px_asset_fin_rec.bonus_rule              := fa_cache_pkg.fazccbd_record.bonus_rule;
   px_asset_fin_rec.ceiling_name            := fa_cache_pkg.fazccbd_record.ceiling_name;
   px_asset_fin_rec.production_capacity     := fa_cache_pkg.fazccbd_record.production_capacity;
   px_asset_fin_rec.unit_of_measure         := fa_cache_pkg.fazccbd_record.unit_of_measure;

   -- call the sob cache to get the table of sob_ids
   if not FA_CACHE_PKG.fazcrsob
          (x_book_type_code => px_asset_hdr_rec.book_type_code,
           x_sob_tbl        => l_sob_tbl, p_log_level_rec => p_log_level_rec) then
      raise cap_rev_err;
   end if;

   -- set up the local asset_header and sob_id
   l_asset_hdr_rec := px_asset_hdr_rec;


   -- loop through each book starting with the primary and
   -- call the private API for each

   FOR l_sob_index in 0..l_sob_tbl.count LOOP

      --clear out the fin rec
      l_asset_fin_rec                        := NULL;
      l_asset_fin_rec.date_placed_in_service := px_asset_fin_rec.date_placed_in_service;
-- BUG 4553782
      l_asset_fin_rec.deprn_method_code       := px_asset_fin_rec.deprn_method_code;
      l_asset_fin_rec.life_in_months          := px_asset_fin_rec.life_in_months;
      l_asset_fin_rec.basic_rate              := px_asset_fin_rec.basic_rate;
      l_asset_fin_rec.adjusted_rate           := px_asset_fin_rec.adjusted_rate;
      l_asset_fin_rec.prorate_convention_code := px_asset_fin_rec.prorate_convention_code;
      l_asset_fin_rec.depreciate_flag         := px_asset_fin_rec.depreciate_flag;
      l_asset_fin_rec.bonus_rule              := px_asset_fin_rec.bonus_rule;
      l_asset_fin_rec.ceiling_name            := px_asset_fin_rec.ceiling_name;
      l_asset_fin_rec.production_capacity     := px_asset_fin_rec.production_capacity;
      l_asset_fin_rec.unit_of_measure         := px_asset_fin_rec.unit_of_measure;
-- END BUG
      if (l_sob_index = 0) then
         l_reporting_flag := 'P';
         px_trans_rec.transaction_date_entered  := px_asset_fin_rec.date_placed_in_service;
      else
         l_reporting_flag := 'R';
         l_asset_hdr_rec.set_of_books_id := l_sob_tbl(l_sob_index);
      end if;


      -- call the cache to set the sob_id used for rounding and other lower
      -- level code for each book.
      if NOT fa_cache_pkg.fazcbcs(X_book => px_asset_hdr_rec.book_type_code,
                                  X_set_of_books_id => l_asset_hdr_rec.set_of_books_id,
                                  p_log_level_rec => p_log_level_rec) then
         raise cap_rev_err;
      end if;

      -- load the old structs
      if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec            => l_asset_hdr_rec,
               px_asset_fin_rec           => l_asset_fin_rec_old,
               p_transaction_header_id    => NULL,
               p_mrc_sob_type_code        => l_reporting_flag
               , p_log_level_rec => p_log_level_rec) then
         raise cap_rev_err;
      end if;

      --HH Validate disabled_flag
      if not FA_ASSET_VAL_PVT.validate_disabled_flag
              (p_group_asset_id => px_asset_hdr_rec.asset_id,
               p_book_type_code => px_asset_hdr_rec.book_type_code,
               p_old_flag       => l_asset_fin_rec_old.disabled_flag,
               p_new_flag       => l_asset_fin_rec_old.disabled_flag
               , p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
      end if; --End HH

      -- main private api
      if not fa_cip_pvt.do_cap_rev
              (px_trans_rec              => px_trans_rec,
               p_asset_hdr_rec           => l_asset_hdr_rec,
               p_asset_desc_rec          => p_asset_desc_rec,
               p_asset_cat_rec           => p_asset_cat_rec,
               px_asset_type_rec         => px_asset_type_rec,
               p_asset_fin_rec_old       => l_asset_fin_rec_old,
               px_asset_fin_rec          => l_asset_fin_rec,
               p_period_rec              => l_period_rec,
               p_mrc_sob_type_code       => l_reporting_flag
              , p_log_level_rec => p_log_level_rec) then
         raise cap_rev_err;
      end if;

      if (l_sob_index <> 0) then

         if px_asset_hdr_rec.period_of_addition = 'N' then
            if (px_asset_fin_rec.cost <> 0) then
               l_avg_rate      := l_asset_fin_rec_old.cost /
                                  px_asset_fin_rec.cost;
            else
               select br1.avg_exchange_rate
                 into l_avg_rate
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
            end if;

            l_exchange_rate := l_avg_rate;

            -- insert the books_rates record

            MC_FA_UTILITIES_PKG.insert_books_rates
              (p_set_of_books_id              => l_asset_hdr_rec.set_of_books_id,
               p_asset_id                     => l_asset_hdr_rec.asset_id,
               p_book_type_code               => l_asset_hdr_rec.book_type_code,
               p_transaction_header_id        => px_trans_rec.transaction_header_id,
               p_invoice_transaction_id       => null,
               p_exchange_date                => px_trans_rec.transaction_date_entered,  -- ??? dpis
               p_cost                         => 0,
               p_exchange_rate                => l_exchange_rate,
               p_avg_exchange_rate            => l_avg_rate,
               p_last_updated_by              => px_trans_rec.who_info.last_updated_by,
               p_last_update_date             => px_trans_rec.who_info.last_update_date,
               p_last_update_login            => px_trans_rec.who_info.last_update_login,
               p_complete                     => 'Y',
               p_trigger                      => 'l_calling_fn',
               p_currency_code                => l_asset_hdr_rec.set_of_books_id,
               p_log_level_rec                => p_log_level_rec);

         end if;  -- period of addition

      end if; -- reporting book


      -- GROUP API CALL
      -- this will be called once passing both primary and reporting info
      -- to adjust primary and reporting books for the group

      if (l_asset_fin_rec_old.group_asset_id is not null) then

         -- set up the group recs
         l_group_asset_hdr_rec          := l_asset_hdr_rec;
         l_group_asset_hdr_rec.asset_id := l_asset_fin_rec_old.group_asset_id;
         l_group_trans_rec              := px_trans_rec;   -- will set the amort start date

         if (l_reporting_flag <> 'R') then

            if not FA_UTIL_PVT.get_asset_desc_rec
                    (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                     px_asset_desc_rec       => l_group_asset_desc_rec
                    , p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            if not FA_UTIL_PVT.get_asset_cat_rec
                    (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                     px_asset_cat_rec        => l_group_asset_cat_rec,
                     p_date_effective        => null
                    , p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            if not FA_UTIL_PVT.get_asset_type_rec
                    (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                     px_asset_type_rec       => l_group_asset_type_rec,
                     p_date_effective        => null
                    , p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            if not FA_ASSET_VAL_PVT.validate_period_of_addition
                    (p_asset_id            => l_group_asset_hdr_rec.asset_id,
                     p_book                => l_group_asset_hdr_rec.book_type_code,
                     p_mode                => 'ABSOLUTE',
                     px_period_of_addition => l_group_asset_hdr_rec.period_of_addition, p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
            end if;

            l_group_trans_rec.transaction_type_code := 'GROUP ADJUSTMENT';
            l_group_trans_rec.member_transaction_header_id := px_trans_rec.transaction_header_id;

            if (NOT fa_trx_approval_pkg.faxcat
                     (X_book              => l_group_asset_hdr_rec.book_type_code,
                      X_asset_id          => l_group_asset_hdr_rec.asset_id,
                      X_trx_type          => l_group_trans_rec.transaction_type_code,
                      X_trx_date          => l_group_trans_rec.transaction_date_entered,
                      X_init_message_flag => 'NO', p_log_level_rec => p_log_level_rec)) then
               raise cap_rev_err;
            end if;

            -- use dpis as amort start
            l_group_trans_rec.transaction_subtype     := 'AMORTIZED';
            l_group_trans_rec.amortization_start_date := l_asset_fin_rec.date_placed_in_service;

            select fa_transaction_headers_s.nextval
              into l_group_trans_rec.transaction_header_id
              from dual;

         end if;

         -- load the old structs
         if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_group_asset_hdr_rec,
                  px_asset_fin_rec        => l_group_asset_fin_rec_old,
                  p_transaction_header_id => NULL,
                  p_mrc_sob_type_code     => l_reporting_flag
                , p_log_level_rec => p_log_level_rec) then raise cap_rev_err;
         end if;

         --HH Validate disabled_flag
         --No trx on a disabled group.
         if not FA_ASSET_VAL_PVT.validate_disabled_flag
                  (p_group_asset_id => l_group_asset_hdr_rec.asset_id,
                   p_book_type_code => l_group_asset_hdr_rec.book_type_code,
                   p_old_flag       => l_group_asset_fin_rec_old.disabled_flag,
                   p_new_flag       => l_group_asset_fin_rec_old.disabled_flag
                  , p_log_level_rec => p_log_level_rec) then
               raise cap_rev_err;
         end if; --End HH

         if not FA_UTIL_PVT.get_asset_deprn_rec
                 (p_asset_hdr_rec         => l_group_asset_hdr_rec ,
                  px_asset_deprn_rec      => l_group_asset_deprn_rec_old,
                  p_period_counter        => NULL,
                  p_mrc_sob_type_code     => l_reporting_flag
                 , p_log_level_rec => p_log_level_rec) then raise cap_rev_err;
         end if;

         -- need to account for portion of cip_cost that may already have been
         -- in group's basis:

         if (px_asset_type_rec.asset_type = 'CAPITALIZED') then -- originally cip
            l_group_asset_fin_rec_adj.cip_cost := -l_asset_fin_rec_old.cip_cost;
            l_group_asset_fin_rec_adj.cost     := l_asset_fin_rec_old.cip_cost;
            l_group_trans_rec.transaction_key  := 'MC';
	    l_group_asset_fin_rec_adj.salvage_value := nvl(l_asset_fin_rec_old.salvage_value,0);--bug# 4129999
         else
            l_group_asset_fin_rec_adj.cip_cost := l_asset_fin_rec_old.cip_cost;
            l_group_asset_fin_rec_adj.cost     := l_asset_fin_rec_old.cip_cost;
            l_group_trans_rec.transaction_key  := 'MV';
         end if;

         if not FA_ADJUSTMENT_PVT.do_adjustment
                     (px_trans_rec              => l_group_trans_rec,
                      px_asset_hdr_rec          => l_group_asset_hdr_rec,
                      p_asset_desc_rec          => l_group_asset_desc_rec,
                      p_asset_type_rec          => l_group_asset_type_rec,
                      p_asset_cat_rec           => l_group_asset_cat_rec,
                      p_asset_fin_rec_old       => l_group_asset_fin_rec_old,
                      p_asset_fin_rec_adj       => l_group_asset_fin_rec_adj,
                      x_asset_fin_rec_new       => l_group_asset_fin_rec_new,
                      p_inv_trans_rec           => l_inv_trans_rec,
                      p_asset_deprn_rec_old     => l_group_asset_deprn_rec_old,
                      p_asset_deprn_rec_adj     => l_group_asset_deprn_rec_adj,
                      x_asset_deprn_rec_new     => l_group_asset_deprn_rec_new,
                      p_period_rec              => l_period_rec,
                      p_mrc_sob_type_code       => l_reporting_flag,
		      p_group_reclass_options_rec =>l_group_reclass_options_rec,
                      p_calling_fn              => 'fa_addition_pub.do_addition'
                     , p_log_level_rec => p_log_level_rec)then
            raise cap_rev_err;
         end if; -- do_adjustment
      end if;  -- group asset id not null

   end loop;

   return true;

EXCEPTION

   WHEN CAP_REV_ERR THEN
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

   WHEN OTHERS THEN
      fa_srvr_msg.add_sql_error(CALLING_FN => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return FALSE;

END do_all_books;

-----------------------------------------------------------------------------

END FA_CIP_PUB;

/
