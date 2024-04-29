--------------------------------------------------------
--  DDL for Package Body FA_TRANS_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TRANS_API_PVT" AS
/* $Header: FAVTAPIB.pls 120.8.12010000.2 2009/07/19 11:20:22 glchen ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

FUNCTION set_asset_fin_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec         IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new        OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN IS

    l_asset_fin_rec_old            fa_api_types.asset_fin_rec_type;

    fin_err                        exception;

BEGIN

   if (NOT fa_util_pvt.get_asset_fin_rec (
           p_asset_hdr_rec      => p_asset_hdr_rec,
           px_asset_fin_rec     => l_asset_fin_rec_old,
           p_mrc_sob_type_code  => p_mrc_sob_type_code,
           p_log_level_rec      => g_log_level_rec
   )) then
      raise fin_err;
   end if;

   x_asset_fin_rec_new := p_asset_fin_rec;

   if ((p_asset_fin_rec.reval_ceiling is NULL) and
       (l_asset_fin_rec_old.reval_ceiling is NOT NULL)) then
      x_asset_fin_rec_new.reval_ceiling := FND_API.G_MISS_NUM;
   else
      x_asset_fin_rec_new.reval_ceiling := p_asset_fin_rec.reval_ceiling;
   end if;

   if ((p_asset_fin_rec.salvage_value is NULL) and
       (l_asset_fin_rec_old.salvage_value is NOT NULL)) then
      x_asset_fin_rec_new.salvage_value := FND_API.G_MISS_NUM;
   else
      x_asset_fin_rec_new.salvage_value := p_asset_fin_rec.salvage_value;
   end if;

   if ((p_asset_fin_rec.itc_amount_id is NULL) and
       (l_asset_fin_rec_old.itc_amount_id is NOT NULL)) then
      x_asset_fin_rec_new.itc_amount_id := FND_API.G_MISS_NUM;
   else
      x_asset_fin_rec_new.itc_amount_id := p_asset_fin_rec.itc_amount_id;
   end if;

   if ((p_asset_fin_rec.ceiling_name is NULL) and
       (l_asset_fin_rec_old.ceiling_name is NOT NULL)) then
      x_asset_fin_rec_new.ceiling_name := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.ceiling_name := p_asset_fin_rec.ceiling_name;
   end if;

/*
   if ((p_asset_fin_rec.conversion_date is NULL) and
       (l_asset_fin_rec_old.conversion_date is NOT NULL)) then
      x_asset_fin_rec_new.conversion_date := FND_API.G_MISS_DATE;
   else
      x_asset_fin_rec_new.conversion_date := p_asset_fin_rec.conversion_date;
   end if;

   if ((p_asset_fin_rec.orig_deprn_start_date is NULL) and
       (l_asset_fin_rec_old.orig_deprn_start_date is NOT NULL)) then
      x_asset_fin_rec_new.orig_deprn_start_date := FND_API.G_MISS_DATE;
   else
      x_asset_fin_rec_new.orig_deprn_start_date :=
         p_asset_fin_rec.orig_deprn_start_date;
   end if;
*/
   if ((p_asset_fin_rec.group_asset_id is NULL) and
       (l_asset_fin_rec_old.group_asset_id is NOT NULL)) then
      x_asset_fin_rec_new.group_asset_id := FND_API.G_MISS_NUM;
   else
      x_asset_fin_rec_new.group_asset_id := p_asset_fin_rec.group_asset_id;
   end if;

   if ((p_asset_fin_rec.global_attribute1 is NULL) and
       (l_asset_fin_rec_old.global_attribute1 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute1 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute1 :=
         p_asset_fin_rec.global_attribute1;
   end if;

   if ((p_asset_fin_rec.global_attribute2 is NULL) and
       (l_asset_fin_rec_old.global_attribute2 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute2 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute2 :=
         p_asset_fin_rec.global_attribute2;
   end if;

   if ((p_asset_fin_rec.global_attribute3 is NULL) and
       (l_asset_fin_rec_old.global_attribute3 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute3 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute3 :=
         p_asset_fin_rec.global_attribute3;
   end if;

   if ((p_asset_fin_rec.global_attribute4 is NULL) and
       (l_asset_fin_rec_old.global_attribute4 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute4 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute4 :=
         p_asset_fin_rec.global_attribute4;
   end if;

   if ((p_asset_fin_rec.global_attribute5 is NULL) and
       (l_asset_fin_rec_old.global_attribute5 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute5 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute5 :=
         p_asset_fin_rec.global_attribute5;
   end if;

   if ((p_asset_fin_rec.global_attribute6 is NULL) and
       (l_asset_fin_rec_old.global_attribute6 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute6 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute6 :=
         p_asset_fin_rec.global_attribute6;
   end if;

   if ((p_asset_fin_rec.global_attribute7 is NULL) and
       (l_asset_fin_rec_old.global_attribute7 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute7 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute7 :=
         p_asset_fin_rec.global_attribute7;
   end if;

   if ((p_asset_fin_rec.global_attribute8 is NULL) and
       (l_asset_fin_rec_old.global_attribute8 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute8 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute8 :=
         p_asset_fin_rec.global_attribute8;
   end if;

   if ((p_asset_fin_rec.global_attribute9 is NULL) and
       (l_asset_fin_rec_old.global_attribute9 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute9 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute9 :=
         p_asset_fin_rec.global_attribute9;
   end if;

   if ((p_asset_fin_rec.global_attribute10 is NULL) and
       (l_asset_fin_rec_old.global_attribute10 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute10 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute10 :=
         p_asset_fin_rec.global_attribute10;
   end if;

   if ((p_asset_fin_rec.global_attribute11 is NULL) and
       (l_asset_fin_rec_old.global_attribute11 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute11 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute11 :=
         p_asset_fin_rec.global_attribute11;
   end if;

   if ((p_asset_fin_rec.global_attribute12 is NULL) and
       (l_asset_fin_rec_old.global_attribute12 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute12 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute12 :=
         p_asset_fin_rec.global_attribute12;
   end if;

   if ((p_asset_fin_rec.global_attribute13 is NULL) and
       (l_asset_fin_rec_old.global_attribute13 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute13 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute13 :=
         p_asset_fin_rec.global_attribute13;
   end if;

   if ((p_asset_fin_rec.global_attribute14 is NULL) and
       (l_asset_fin_rec_old.global_attribute14 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute14 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute14 :=
         p_asset_fin_rec.global_attribute14;
   end if;

   if ((p_asset_fin_rec.global_attribute15 is NULL) and
       (l_asset_fin_rec_old.global_attribute15 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute15 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute15 :=
         p_asset_fin_rec.global_attribute15;
   end if;

   if ((p_asset_fin_rec.global_attribute16 is NULL) and
       (l_asset_fin_rec_old.global_attribute16 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute16 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute16 :=
         p_asset_fin_rec.global_attribute16;
   end if;

   if ((p_asset_fin_rec.global_attribute17 is NULL) and
       (l_asset_fin_rec_old.global_attribute17 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute17 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute17 :=
         p_asset_fin_rec.global_attribute17;
   end if;

   if ((p_asset_fin_rec.global_attribute18 is NULL) and
       (l_asset_fin_rec_old.global_attribute18 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute18 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute18 :=
         p_asset_fin_rec.global_attribute18;
   end if;

   if ((p_asset_fin_rec.global_attribute19 is NULL) and
       (l_asset_fin_rec_old.global_attribute19 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute19 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute19 :=
         p_asset_fin_rec.global_attribute19;
   end if;

   if ((p_asset_fin_rec.global_attribute20 is NULL) and
       (l_asset_fin_rec_old.global_attribute20 is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute20 := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute20 :=
         p_asset_fin_rec.global_attribute20;
   end if;

   if ((p_asset_fin_rec.global_attribute_category is NULL) and
       (l_asset_fin_rec_old.global_attribute_category is NOT NULL)) then
      x_asset_fin_rec_new.global_attribute_category := FND_API.G_MISS_CHAR;
   else
      x_asset_fin_rec_new.global_attribute_category :=
         p_asset_fin_rec.global_attribute_category;
   end if;

   return TRUE;

EXCEPTION
   when fin_err then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_fin_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_fin_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_asset_fin_rec;

FUNCTION set_asset_deprn_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_deprn_rec       IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new      OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN IS

    l_asset_deprn_rec_old          fa_api_types.asset_deprn_rec_type;

    deprn_err                      exception;

BEGIN

   -- Need to call the cache for book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => p_asset_hdr_rec.book_type_code,
      p_log_level_rec => g_log_level_rec
   )) then
      raise deprn_err;
   end if;

   if (NOT fa_util_pvt.get_asset_deprn_rec (
           p_asset_hdr_rec      => p_asset_hdr_rec,
           px_asset_deprn_rec   => l_asset_deprn_rec_old,
           p_mrc_sob_type_code  => p_mrc_sob_type_code,
           p_log_level_rec      => g_log_level_rec
   )) then
      raise deprn_err;
   end if;

   x_asset_deprn_rec_new := p_asset_deprn_rec;

   if ((p_asset_deprn_rec.deprn_reserve is NULL) and
       (l_asset_deprn_rec_old.deprn_reserve is NOT NULL)) then
      x_asset_deprn_rec_new.deprn_reserve := FND_API.G_MISS_NUM;
   else
      x_asset_deprn_rec_new.deprn_reserve := p_asset_deprn_rec.deprn_reserve;
   end if;

   if ((p_asset_deprn_rec.ytd_deprn is NULL) and
       (l_asset_deprn_rec_old.ytd_deprn is NOT NULL)) then
      x_asset_deprn_rec_new.ytd_deprn := FND_API.G_MISS_NUM;
   else
      x_asset_deprn_rec_new.ytd_deprn := p_asset_deprn_rec.ytd_deprn;
   end if;

   if ((p_asset_deprn_rec.reval_deprn_reserve is NULL) and
       (l_asset_deprn_rec_old.reval_deprn_reserve is NOT NULL)) then
      x_asset_deprn_rec_new.reval_deprn_reserve := FND_API.G_MISS_NUM;
   else
      x_asset_deprn_rec_new.reval_deprn_reserve :=
         p_asset_deprn_rec.reval_deprn_reserve;
   end if;

   return TRUE;

EXCEPTION
   when deprn_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pvt.set_deprn_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_deprn_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_asset_deprn_rec;

FUNCTION set_asset_desc_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
    x_asset_desc_rec_new       OUT NOCOPY FA_API_TYPES.asset_desc_rec_type
) RETURN BOOLEAN IS

    l_asset_desc_rec_old           fa_api_types.asset_desc_rec_type;

    desc_err                       exception;

BEGIN

   if (NOT fa_util_pvt.get_asset_desc_rec (
           p_asset_hdr_rec      => p_asset_hdr_rec,
           px_asset_desc_rec    => l_asset_desc_rec_old,
           p_log_level_rec      => g_log_level_rec

   )) then
      raise desc_err;
   end if;

   x_asset_desc_rec_new := p_asset_desc_rec;

   if ((p_asset_desc_rec.asset_number is NULL) and
       (l_asset_desc_rec_old.asset_number is NOT NULL)) then
      x_asset_desc_rec_new.asset_number := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.asset_number := p_asset_desc_rec.asset_number;
   end if;

   if ((p_asset_desc_rec.description is NULL) and
       (l_asset_desc_rec_old.description is NOT NULL)) then
      x_asset_desc_rec_new.description := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.description := p_asset_desc_rec.description;
   end if;

   if ((p_asset_desc_rec.tag_number is NULL) and
       (l_asset_desc_rec_old.tag_number is NOT NULL)) then
      x_asset_desc_rec_new.tag_number := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.tag_number := p_asset_desc_rec.tag_number;
   end if;

   if ((p_asset_desc_rec.serial_number is NULL) and
       (l_asset_desc_rec_old.serial_number is NOT NULL)) then
      x_asset_desc_rec_new.serial_number := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.serial_number := p_asset_desc_rec.serial_number;
   end if;

   if ((p_asset_desc_rec.asset_key_ccid is NULL) and
       (l_asset_desc_rec_old.asset_key_ccid is NOT NULL)) then
      x_asset_desc_rec_new.asset_key_ccid := FND_API.G_MISS_NUM;
   else
      x_asset_desc_rec_new.asset_key_ccid := p_asset_desc_rec.asset_key_ccid;
   end if;

   if ((p_asset_desc_rec.parent_asset_id is NULL) and
       (l_asset_desc_rec_old.parent_asset_id is NOT NULL)) then
      x_asset_desc_rec_new.parent_asset_id := FND_API.G_MISS_NUM;
   else
      x_asset_desc_rec_new.parent_asset_id := p_asset_desc_rec.parent_asset_id;
   end if;

   if ((p_asset_desc_rec.manufacturer_name is NULL) and
       (l_asset_desc_rec_old.manufacturer_name is NOT NULL)) then
      x_asset_desc_rec_new.manufacturer_name := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.manufacturer_name :=
         p_asset_desc_rec.manufacturer_name;
   end if;

   if ((p_asset_desc_rec.model_number is NULL) and
       (l_asset_desc_rec_old.model_number is NOT NULL)) then
      x_asset_desc_rec_new.model_number := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.model_number := p_asset_desc_rec.model_number;
   end if;

   if ((p_asset_desc_rec.warranty_id is NULL) and
       (l_asset_desc_rec_old.warranty_id is NOT NULL)) then
      x_asset_desc_rec_new.warranty_id := FND_API.G_MISS_NUM;
   else
      x_asset_desc_rec_new.warranty_id := p_asset_desc_rec.warranty_id;
   end if;

   if ((p_asset_desc_rec.lease_id is NULL) and
       (l_asset_desc_rec_old.lease_id is NOT NULL)) then
      x_asset_desc_rec_new.lease_id := FND_API.G_MISS_NUM;
   else
      x_asset_desc_rec_new.lease_id := p_asset_desc_rec.lease_id;
   end if;

   if ((p_asset_desc_rec.in_use_flag is NULL) and
       (l_asset_desc_rec_old.in_use_flag is NOT NULL)) then
      x_asset_desc_rec_new.in_use_flag := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.in_use_flag := p_asset_desc_rec.in_use_flag;
   end if;

   if ((p_asset_desc_rec.inventorial is NULL) and
       (l_asset_desc_rec_old.inventorial is NOT NULL)) then
      x_asset_desc_rec_new.inventorial := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.inventorial := p_asset_desc_rec.inventorial;
   end if;

   if ((p_asset_desc_rec.property_type_code is NULL) and
       (l_asset_desc_rec_old.property_type_code is NOT NULL)) then
      x_asset_desc_rec_new.property_type_code := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.property_type_code :=
         p_asset_desc_rec.property_type_code;
   end if;

   if ((p_asset_desc_rec.property_1245_1250_code is NULL) and
       (l_asset_desc_rec_old.property_1245_1250_code is NOT NULL)) then
      x_asset_desc_rec_new.property_1245_1250_code := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.property_1245_1250_code :=
         p_asset_desc_rec.property_1245_1250_code;
   end if;

   if ((p_asset_desc_rec.owned_leased is NULL) and
       (l_asset_desc_rec_old.owned_leased is NOT NULL)) then
      x_asset_desc_rec_new.owned_leased := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.owned_leased := p_asset_desc_rec.owned_leased;
   end if;

   if ((p_asset_desc_rec.new_used is NULL) and
       (l_asset_desc_rec_old.new_used is NOT NULL)) then
      x_asset_desc_rec_new.new_used := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.new_used := p_asset_desc_rec.new_used;
   end if;

   if ((p_asset_desc_rec.current_units is NULL) and
       (l_asset_desc_rec_old.current_units is NOT NULL)) then
      x_asset_desc_rec_new.current_units := FND_API.G_MISS_NUM;
   else
      x_asset_desc_rec_new.current_units := p_asset_desc_rec.current_units;
   end if;

   if ((p_asset_desc_rec.status is NULL) and
       (l_asset_desc_rec_old.status is NOT NULL)) then
      x_asset_desc_rec_new.status := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.status := p_asset_desc_rec.status;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute1 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute1 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute1 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute1 :=
         p_asset_desc_rec.lease_desc_flex.attribute1;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute2 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute2 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute2 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute2 :=
         p_asset_desc_rec.lease_desc_flex.attribute2;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute3 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute3 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute3 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute3 :=
         p_asset_desc_rec.lease_desc_flex.attribute3;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute4 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute4 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute4 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute4 :=
         p_asset_desc_rec.lease_desc_flex.attribute4;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute5 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute5 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute5 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute5 :=
         p_asset_desc_rec.lease_desc_flex.attribute5;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute6 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute6 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute6 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute6 :=
         p_asset_desc_rec.lease_desc_flex.attribute6;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute7 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute7 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute7 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute7 :=
         p_asset_desc_rec.lease_desc_flex.attribute7;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute8 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute8 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute8 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute8 :=
         p_asset_desc_rec.lease_desc_flex.attribute8;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute9 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute9 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute9 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute9 :=
         p_asset_desc_rec.lease_desc_flex.attribute9;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute10 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute10 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute10 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute10 :=
         p_asset_desc_rec.lease_desc_flex.attribute10;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute11 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute11 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute11 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute11 :=
         p_asset_desc_rec.lease_desc_flex.attribute11;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute12 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute12 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute12 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute12 :=
         p_asset_desc_rec.lease_desc_flex.attribute12;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute13 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute13 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute13 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute13 :=
         p_asset_desc_rec.lease_desc_flex.attribute13;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute14 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute14 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute14 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute14 :=
         p_asset_desc_rec.lease_desc_flex.attribute14;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute15 is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute15 is NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute15 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute15 :=
         p_asset_desc_rec.lease_desc_flex.attribute15;
   end if;

   if ((p_asset_desc_rec.lease_desc_flex.attribute_category_code is NULL) and
       (l_asset_desc_rec_old.lease_desc_flex.attribute_category_code is
        NOT NULL)) then
      x_asset_desc_rec_new.lease_desc_flex.attribute_category_code :=
         FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.lease_desc_flex.attribute_category_code :=
         p_asset_desc_rec.lease_desc_flex.attribute_category_code;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute1 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute1 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute1 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute1 :=
         p_asset_desc_rec.global_desc_flex.attribute1;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute2 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute2 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute2 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute2 :=
         p_asset_desc_rec.global_desc_flex.attribute2;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute3 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute3 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute3 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute3 :=
         p_asset_desc_rec.global_desc_flex.attribute3;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute4 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute4 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute4 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute4 :=
         p_asset_desc_rec.global_desc_flex.attribute4;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute5 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute5 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute5 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute5 :=
         p_asset_desc_rec.global_desc_flex.attribute5;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute6 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute6 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute6 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute6 :=
         p_asset_desc_rec.global_desc_flex.attribute6;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute7 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute7 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute7 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute7 :=
         p_asset_desc_rec.global_desc_flex.attribute7;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute8 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute8 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute8 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute8 :=
         p_asset_desc_rec.global_desc_flex.attribute8;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute9 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute9 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute9 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute9 :=
         p_asset_desc_rec.global_desc_flex.attribute9;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute10 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute10 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute10 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute10 :=
         p_asset_desc_rec.global_desc_flex.attribute10;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute11 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute11 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute11 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute11 :=
         p_asset_desc_rec.global_desc_flex.attribute11;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute12 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute12 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute12 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute12 :=
         p_asset_desc_rec.global_desc_flex.attribute12;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute13 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute13 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute13 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute13 :=
         p_asset_desc_rec.global_desc_flex.attribute13;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute14 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute14 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute14 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute14 :=
         p_asset_desc_rec.global_desc_flex.attribute14;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute15 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute15 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute15 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute15 :=
         p_asset_desc_rec.global_desc_flex.attribute15;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute16 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute16 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute16 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute16 :=
         p_asset_desc_rec.global_desc_flex.attribute16;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute17 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute17 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute17 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute17 :=
         p_asset_desc_rec.global_desc_flex.attribute17;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute18 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute18 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute18 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute18 :=
         p_asset_desc_rec.global_desc_flex.attribute18;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute19 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute19 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute19 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute19 :=
         p_asset_desc_rec.global_desc_flex.attribute19;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute20 is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute20 is NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute20 := FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute20 :=
         p_asset_desc_rec.global_desc_flex.attribute20;
   end if;

   if ((p_asset_desc_rec.global_desc_flex.attribute_category_code is NULL) and
       (l_asset_desc_rec_old.global_desc_flex.attribute_category_code is
        NOT NULL)) then
      x_asset_desc_rec_new.global_desc_flex.attribute_category_code :=
         FND_API.G_MISS_CHAR;
   else
      x_asset_desc_rec_new.global_desc_flex.attribute_category_code :=
         p_asset_desc_rec.global_desc_flex.attribute_category_code;
   end if;

   return TRUE;

EXCEPTION
   when desc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pvt.set_desc_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_desc_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_asset_desc_rec;

FUNCTION set_asset_cat_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
    x_asset_cat_rec_new        OUT NOCOPY FA_API_TYPES.asset_cat_rec_type
) RETURN BOOLEAN IS

    l_asset_cat_rec_old         fa_api_types.asset_cat_rec_type;

    cat_err                     exception;

BEGIN

   l_asset_cat_rec_old.category_id := p_asset_cat_rec.category_id;

   if (NOT fa_util_pvt.get_asset_cat_rec (
           p_asset_hdr_rec     => p_asset_hdr_rec,
           px_asset_cat_rec    => l_asset_cat_rec_old,
           p_log_level_rec      => g_log_level_rec
   )) then
      raise cat_err;
   end if;

   x_asset_cat_rec_new := p_asset_cat_rec;

   if ((p_asset_cat_rec.desc_flex.attribute1 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute1 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute1 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute2 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute2 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute2 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute3 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute3 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute3 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute4 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute4 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute4 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute5 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute5 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute5 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute6 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute6 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute6 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute7 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute7 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute7 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute8 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute8 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute8 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute9 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute9 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute9 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute10 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute10 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute10 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute11 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute11 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute11 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute12 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute12 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute12 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute13 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute13 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute13 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute14 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute14 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute14 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute15 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute15 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute15 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute16 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute16 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute16 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute17 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute17 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute17 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute18 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute18 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute18 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute19 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute19 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute19 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute20 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute20 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute20 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute21 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute21 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute21 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute22 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute22 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute22 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute23 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute23 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute23 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute24 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute24 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute24 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute25 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute25 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute25 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute26 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute26 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute26 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute27 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute27 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute27 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute28 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute28 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute28 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute29 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute29 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute29 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute30 is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute30 is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute30 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.attribute_category_code is NULL) and
       (l_asset_cat_rec_old.desc_flex.attribute_category_code is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.attribute_category_code :=
         FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_cat_rec.desc_flex.context is NULL) and
       (l_asset_cat_rec_old.desc_flex.context is NOT NULL)) then
      x_asset_cat_rec_new.desc_flex.context := FND_API.G_MISS_CHAR;
   end if;

   return TRUE;

EXCEPTION
   when cat_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pvt.set_cat_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_cat_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_asset_cat_rec;

FUNCTION set_asset_retire_rec (
    p_asset_retire_rec      IN     FA_API_TYPES.asset_retire_rec_type,
    x_asset_retire_rec_new     OUT NOCOPY FA_API_TYPES.asset_retire_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN IS

    l_asset_retire_rec_old         fa_api_types.asset_retire_rec_type;

    retire_err                     exception;

BEGIN

   l_asset_retire_rec_old.retirement_id := p_asset_retire_rec.retirement_id;

   if (NOT fa_util_pvt.get_asset_retire_rec (
           px_asset_retire_rec  => l_asset_retire_rec_old,
           p_mrc_sob_type_code  => p_mrc_sob_type_code,
           p_set_of_books_id    => null,
           p_log_level_rec      => g_log_level_rec
   )) then
      raise retire_err;
   end if;

   x_asset_retire_rec_new := p_asset_retire_rec;

   if ((p_asset_retire_rec.units_retired is NULL) and
       (l_asset_retire_rec_old.units_retired is NOT NULL)) then
      x_asset_retire_rec_new.units_retired := FND_API.G_MISS_NUM;
   end if;

   if ((p_asset_retire_rec.cost_retired is NULL) and
       (l_asset_retire_rec_old.cost_retired is NOT NULL)) then
      x_asset_retire_rec_new.cost_retired := FND_API.G_MISS_NUM;
   end if;

   if ((p_asset_retire_rec.proceeds_of_sale is NULL) and
       (l_asset_retire_rec_old.proceeds_of_sale is NOT NULL)) then
      x_asset_retire_rec_new.proceeds_of_sale := FND_API.G_MISS_NUM;
   end if;

   if ((p_asset_retire_rec.cost_of_removal is NULL) and
       (l_asset_retire_rec_old.cost_of_removal is NOT NULL)) then
      x_asset_retire_rec_new.cost_of_removal := FND_API.G_MISS_NUM;
   end if;

   if ((p_asset_retire_rec.retirement_type_code is NULL) and
       (l_asset_retire_rec_old.retirement_type_code is NOT NULL)) then
      x_asset_retire_rec_new.retirement_type_code := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.retirement_prorate_convention is NULL) and
       (l_asset_retire_rec_old.retirement_prorate_convention is NOT NULL)) then
      x_asset_retire_rec_new.retirement_prorate_convention := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.sold_to is NULL) and
       (l_asset_retire_rec_old.sold_to is NOT NULL)) then
      x_asset_retire_rec_new.sold_to := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.trade_in_asset_id is NULL) and
       (l_asset_retire_rec_old.trade_in_asset_id is NOT NULL)) then
      x_asset_retire_rec_new.trade_in_asset_id := FND_API.G_MISS_NUM;
   end if;

   if ((p_asset_retire_rec.status is NULL) and
       (l_asset_retire_rec_old.status is NOT NULL)) then
      x_asset_retire_rec_new.status := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.reference_num is NULL) and
       (l_asset_retire_rec_old.reference_num is NOT NULL)) then
      x_asset_retire_rec_new.reference_num := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute1 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute1 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute1 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute2 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute2 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute2 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute3 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute3 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute3 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute4 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute4 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute4 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute5 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute5 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute5 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute6 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute6 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute6 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute7 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute7 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute7 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute8 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute8 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute8 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute9 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute9 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute9 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute10 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute10 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute10 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute11 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute11 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute11 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute12 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute12 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute12 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute13 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute13 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute13 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute14 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute14 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute14 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute15 is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute15 is NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute15 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_asset_retire_rec.desc_flex.attribute_category_code is NULL) and
       (l_asset_retire_rec_old.desc_flex.attribute_category_code is
        NOT NULL)) then
      x_asset_retire_rec_new.desc_flex.attribute_category_code :=
         FND_API.G_MISS_CHAR;
   end if;

   return TRUE;

EXCEPTION
   when retire_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pvt.set_ret_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_ret_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_asset_retire_rec;

FUNCTION set_inv_rec (
    p_inv_rec               IN     FA_API_TYPES.inv_rec_type,
    x_inv_rec_new              OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN IS

    l_inv_rec_old                  fa_api_types.inv_rec_type;

    inv_err                        exception;

BEGIN

   l_inv_rec_old.source_line_id := p_inv_rec.source_line_id;

   if (NOT fa_util_pvt.get_inv_rec (
           px_inv_rec           => l_inv_rec_old,
           p_mrc_sob_type_code  => p_mrc_sob_type_code,
           p_set_of_books_id    => null,
           p_log_level_rec      => g_log_level_rec
   )) then
      raise inv_err;
   end if;

   x_inv_rec_new := p_inv_rec;

   if ((p_inv_rec.invoice_number is NULL) and
       (l_inv_rec_old.invoice_number is NOT NULL)) then
      x_inv_rec_new.invoice_number := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.ap_distribution_line_number is NULL) and
       (l_inv_rec_old.ap_distribution_line_number is NOT NULL)) then
      x_inv_rec_new.ap_distribution_line_number := FND_API.G_MISS_NUM;
   end if;

   if ((p_inv_rec.description is NULL) and
       (l_inv_rec_old.description is NOT NULL)) then
      x_inv_rec_new.description := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.deleted_flag is NULL) and
       (l_inv_rec_old.deleted_flag is NOT NULL)) then
      x_inv_rec_new.deleted_flag := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.po_vendor_id is NULL) and
       (l_inv_rec_old.po_vendor_id is NOT NULL)) then
      x_inv_rec_new.po_vendor_id := FND_API.G_MISS_NUM;
   end if;

   if ((p_inv_rec.po_number is NULL) and
       (l_inv_rec_old.po_number is NOT NULL)) then
      x_inv_rec_new.po_number := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.payables_batch_name is NULL) and
       (l_inv_rec_old.payables_batch_name is NOT NULL)) then
      x_inv_rec_new.payables_batch_name := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.project_asset_line_id is NULL) and
       (l_inv_rec_old.project_asset_line_id is NOT NULL)) then
      x_inv_rec_new.project_asset_line_id := FND_API.G_MISS_NUM;
   end if;

   if ((p_inv_rec.project_id is NULL) and
       (l_inv_rec_old.project_id is NOT NULL)) then
      x_inv_rec_new.project_id := FND_API.G_MISS_NUM;
   end if;

   if ((p_inv_rec.task_id is NULL) and
       (l_inv_rec_old.task_id is NOT NULL)) then
      x_inv_rec_new.task_id := FND_API.G_MISS_NUM;
   end if;

   if ((p_inv_rec.material_indicator_flag is NULL) and
       (l_inv_rec_old.material_indicator_flag is NOT NULL)) then
      x_inv_rec_new.material_indicator_flag := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute1 is NULL) and
       (l_inv_rec_old.attribute1 is NOT NULL)) then
      x_inv_rec_new.attribute1 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute2 is NULL) and
       (l_inv_rec_old.attribute2 is NOT NULL)) then
      x_inv_rec_new.attribute2 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute3 is NULL) and
       (l_inv_rec_old.attribute3 is NOT NULL)) then
      x_inv_rec_new.attribute3 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute4 is NULL) and
       (l_inv_rec_old.attribute4 is NOT NULL)) then
      x_inv_rec_new.attribute4 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute5 is NULL) and
       (l_inv_rec_old.attribute5 is NOT NULL)) then
      x_inv_rec_new.attribute5 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute6 is NULL) and
       (l_inv_rec_old.attribute6 is NOT NULL)) then
      x_inv_rec_new.attribute6 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute7 is NULL) and
       (l_inv_rec_old.attribute7 is NOT NULL)) then
      x_inv_rec_new.attribute7 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute8 is NULL) and
       (l_inv_rec_old.attribute8 is NOT NULL)) then
      x_inv_rec_new.attribute8 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute9 is NULL) and
       (l_inv_rec_old.attribute9 is NOT NULL)) then
      x_inv_rec_new.attribute9 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute10 is NULL) and
       (l_inv_rec_old.attribute10 is NOT NULL)) then
      x_inv_rec_new.attribute10 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute11 is NULL) and
       (l_inv_rec_old.attribute11 is NOT NULL)) then
      x_inv_rec_new.attribute11 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute12 is NULL) and
       (l_inv_rec_old.attribute12 is NOT NULL)) then
      x_inv_rec_new.attribute12 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute13 is NULL) and
       (l_inv_rec_old.attribute13 is NOT NULL)) then
      x_inv_rec_new.attribute13 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute14 is NULL) and
       (l_inv_rec_old.attribute14 is NOT NULL)) then
      x_inv_rec_new.attribute14 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute15 is NULL) and
       (l_inv_rec_old.attribute15 is NOT NULL)) then
      x_inv_rec_new.attribute15 := FND_API.G_MISS_CHAR;
   end if;

   if ((p_inv_rec.attribute_category_code is NULL) and
       (l_inv_rec_old.attribute_category_code is NOT NULL)) then
      x_inv_rec_new.attribute_category_code := FND_API.G_MISS_CHAR;
   end if;

   return TRUE;

EXCEPTION
   when inv_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_trans_api_pvt.set_inv_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

   when others then
      fa_srvr_msg.add_sql_error(calling_fn => 'fa_trans_api_pvt.set_inv_rec',
                   p_log_level_rec => g_log_level_rec);
      return FALSE;

END set_inv_rec;

END FA_TRANS_API_PVT;

/
