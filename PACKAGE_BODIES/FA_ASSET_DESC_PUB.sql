--------------------------------------------------------
--  DDL for Package Body FA_ASSET_DESC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_DESC_PUB" AS
/* $Header: FAPADSCB.pls 120.18.12010000.2 2009/07/19 14:26:06 glchen ship $   */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'FA_ASSET_DESC_PUB';
G_API_NAME      CONSTANT VARCHAR2(30) := 'Update Asset Description API';
G_API_VERSION   CONSTANT NUMBER       := 1.0;

g_log_level_rec fa_api_types.log_level_rec_type;

--*********************** Private functions ******************************--

FUNCTION update_row(
          p_trans_rec           IN fa_api_types.trans_rec_type,
          p_asset_hdr_rec       IN fa_api_types.asset_hdr_rec_type,
          p_asset_desc_rec_new  IN fa_api_types.asset_desc_rec_type,
          p_asset_cat_rec_new   IN fa_api_types.asset_cat_rec_type,
          p_old_warranty_id     IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION initialize_category_df (
         px_asset_cat_rec        IN OUT NOCOPY   FA_API_TYPES.asset_cat_rec_type
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


--*********************** Public procedures ******************************--
PROCEDURE update_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_asset_desc_rec_new   IN OUT NOCOPY fa_api_types.asset_desc_rec_type,
          px_asset_cat_rec_new    IN OUT NOCOPY fa_api_types.asset_cat_rec_type)
IS

   l_asset_desc_rec   FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec    FA_API_TYPES.asset_cat_rec_type;
   l_asset_fin_rec    FA_API_TYPES.asset_fin_rec_type;
   l_calling_fn       varchar2(50) := 'FA_ASSET_DESC_PUB.update_desc';
   pub_error          exception;

   l_err_stage        varchar2(640);
   l_crl_enabled      boolean := FALSE;
   l_override_flag    varchar2(1) := null;
   l_old_warranty_id  number(15);

BEGIN

   SAVEPOINT do_desc_update;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise pub_error;
      end if;
   end if;

   l_err_stage:= 'Compatible_API_Call';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;

   if (NOT FND_API.Compatible_API_Call(
        G_API_VERSION,
        p_api_version,
        G_API_NAME, G_PKG_NAME
   )) then
      raise pub_error;
   end if;


   l_err_stage:= 'Init_Server_Message';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (FND_API.To_Boolean(p_init_msg_list)) then
       -- Initialize error message stack.
       FA_SRVR_MSG.Init_Server_Message;

       -- Initialize debug message stack.
       FA_DEBUG_PKG.Initialize;
   end if;


   l_err_stage:= 'validate mandatory input params';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;

   if (px_asset_hdr_rec.asset_id is NULL) then
       fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_ASSET_MAINT_WRONG_PARAM', p_log_level_rec => g_log_level_rec);
       raise pub_error;
    end if;

   l_err_stage:= 'We need a calling book if it was not provided';
   if (px_asset_hdr_rec.book_type_code is null) then
      select bc.book_type_code
      into   px_asset_hdr_rec.book_type_code
      from   fa_book_controls bc
      where  bc.book_class = 'CORPORATE'
      and exists
      (
       select 'X'
       from   fa_books bks
       where  bks.asset_id = px_asset_hdr_rec.asset_id
       and    bks.book_type_code = bc.book_type_code
      );
   end if;


   l_err_stage:= 'fa_cache_pkg.fazcbc';
   if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
      end if;

   if (NOT fa_cache_pkg.fazcbc (
      X_book => px_asset_hdr_rec.book_type_code
   , p_log_level_rec => g_log_level_rec)) then
      raise pub_error;
   end if;


   l_err_stage:= 'FA_UTIL_PVT.get_asset_desc_rec';
   if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
      end if;

    if not FA_UTIL_PVT.get_asset_desc_rec(
                     p_asset_hdr_rec   => px_asset_hdr_rec,
                     px_asset_desc_rec => l_asset_desc_rec , p_log_level_rec => g_log_level_rec) then
          raise pub_error;
    end if;

    -- check if CRL enabled
    if (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

        -- If called from Asset Hierarchy batch ignore CRL validations
        if px_trans_rec.calling_interface <> 'ASSET_HIERARCHY' then
           l_crl_enabled := TRUE;
        end if;
    end if;


    -- Asset Number
    l_err_stage:= 'Asset NUmber';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


    if (px_asset_desc_rec_new.asset_number is NOT NULL) then
       if (px_asset_desc_rec_new.asset_number <>
           nvl(l_asset_desc_rec.asset_number, '-999')) then

         if (px_asset_desc_rec_new.asset_number is null) then
            -- retain the old asset_number
            null;
         else
            -- Check if user intentionally nulls out item.
            if (px_asset_desc_rec_new.asset_number = FND_API.G_MISS_CHAR) then
               -- use asset_id for asset_number
               px_asset_desc_rec_new.asset_number :=
                  to_char(px_asset_hdr_rec.asset_id);
            end if;

            -- Validate asset_number
            if (NOT FA_ASSET_VAL_PVT.validate_asset_number(
                  p_transaction_type_code => 'ADDITION',
                                           --px_trans_rec.transaction_type_code,
                  p_asset_number          => px_asset_desc_rec_new.asset_number,
                  p_calling_fn            => l_calling_fn
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         end if;
       end if;
       l_asset_desc_rec.asset_number:= px_asset_desc_rec_new.asset_number;
    end if;   /* asset_number */

    -- Asset Description
    l_err_stage:= 'Asset Description';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


    if (px_asset_desc_rec_new.description is NOT NULL) then
       if (px_asset_desc_rec_new.description <>
           nvl(l_asset_desc_rec.description, '-999')) then

          if (px_asset_desc_rec_new.description is null) then
             -- retain the old description
             null;

          -- Check if user intentionally nulls out item.
          elsif (px_asset_desc_rec_new.description = FND_API.G_MISS_CHAR) then
             --l_asset_desc_rec.description := NULL;
             null;
          end if;

          l_asset_desc_rec.description:= px_asset_desc_rec_new.description;
       end if;
    end if;  /* asset description */

    -- Tag Number
    l_err_stage:= 'Tag Number';
     if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;

    if (px_asset_desc_rec_new.tag_number is NOT NULL) then
      if (nvl(l_asset_desc_rec.tag_number, '-999') <>
          px_asset_desc_rec_new.tag_number) then

         if (px_asset_desc_rec_new.tag_number = FND_API.G_MISS_CHAR) then
            --l_asset_desc_rec.tag_number := NULL;
            null;
         else

            if (NOT FA_ASSET_VAL_PVT.validate_tag_number (
                 p_tag_number        => px_asset_desc_rec_new.tag_number,
                 p_mass_addition_id  => null,
                 p_calling_fn        => l_calling_fn
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         end if;
         l_asset_desc_rec.tag_number:= px_asset_desc_rec_new.tag_number;
      end if;
    end if;

    l_err_stage:= 'Get_asset_cat';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


    if not FA_UTIL_PVT.get_asset_cat_rec(
                     p_asset_hdr_rec   => px_asset_hdr_rec,
                     px_asset_cat_rec =>  l_asset_cat_rec , p_log_level_rec => g_log_level_rec) then
          raise pub_error;
    end if;

    l_asset_cat_rec.desc_flex := px_asset_cat_rec_new.desc_flex;

    l_err_stage:= 'initialize_category_df';
    if not initialize_category_df ( l_asset_cat_rec , g_log_level_rec) then
           raise pub_error;
    end if;

/*

    if not FA_ASSET_VAL_PVT.validate_category_df (
           p_transaction_type_code => px_trans_rec.transaction_type_code,
           p_cat_desc_flex         => l_asset_cat_rec.desc_flex,
           p_calling_fn            => p_calling_fn , p_log_level_rec => g_log_level_rec) then
           raise pub_error;
    end if;

*/

    -- Serial Number
    l_err_stage:= 'Serial Number';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


    if (px_asset_desc_rec_new.serial_number is NOT NULL) then
       if (nvl(l_asset_desc_rec.serial_number, '-999') <>
           px_asset_desc_rec_new.serial_number) then

          if (px_asset_desc_rec_new.serial_number = FND_API.G_MISS_CHAR) then
             --px_asset_desc_rec_new.serial_number := NULL;
             null;
          else
             -- check whether update is allowed for Hierarchy Attached asset
             if (l_crl_enabled ) then
                if (NOT fa_cua_asset_apis.check_override_allowed (
                      p_attribute_name => 'SERIAL_NUMBER',
                      p_book_type_code => px_asset_hdr_rec.book_type_code,
                      p_asset_id       => px_asset_hdr_rec.asset_id,
                      x_override_flag  => l_override_flag,
                      p_log_level_rec  => g_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
                   raise pub_error;
                end if;

                if (l_override_flag = 'N') then
                   fa_srvr_msg.add_message(
                       calling_fn => l_calling_fn,
                       name       => 'FA_OVERRIDE_NOT_ALLOWED',
                       token1     => 'SERIAL NUMBER', p_log_level_rec => g_log_level_rec);
                   raise pub_error;
                end if;
             end if;

             if (NOT FA_ASSET_VAL_PVT.validate_serial_number (
                 p_transaction_type_code => px_trans_rec.transaction_type_code,
                 p_serial_number         => px_asset_desc_rec_new.serial_number,
                 p_calling_fn            => l_calling_fn
             , p_log_level_rec => g_log_level_rec)) then
                raise pub_error;
             end if;
          end if;
          l_asset_desc_rec.serial_number:= px_asset_desc_rec_new.serial_number;
       end if;
    end if;

    -- Asset Key
    l_err_stage:= 'Asset Key';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


    if (px_asset_desc_rec_new.asset_key_ccid is NOT NULL) then
      if (nvl(l_asset_desc_rec.asset_key_ccid, -999) <>
          px_asset_desc_rec_new.asset_key_ccid) then

          if (px_asset_desc_rec_new.asset_key_ccid = FND_API.G_MISS_NUM) then
             --px_asset_desc_rec_new.asset_key_ccid := NULL;

             if (NOT FA_ASSET_VAL_PVT.validate_asset_key (
                p_transaction_type_code => px_trans_rec.transaction_type_code,
                p_asset_key_ccid        => NULL,
                p_calling_fn            => l_calling_fn
             , p_log_level_rec => g_log_level_rec)) then
                raise pub_error;
             end if;
          else
             if (l_crl_enabled) then
                if (NOT fa_cua_asset_APIS.check_override_allowed(
                      p_attribute_name => 'ASSET_KEY',
                      p_book_type_code => px_asset_hdr_rec.book_type_code,
                      p_asset_id       => px_asset_hdr_rec.asset_id,
                      x_override_flag  => l_override_flag,
                      p_log_level_rec  => g_log_level_rec
                )) then

                   fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
                   raise pub_error;
                end if;

                if (l_override_flag = 'N') then
                     fa_srvr_msg.add_message(
                         calling_fn => l_calling_fn,
                         name       => 'FA_OVERRIDE_NOT_ALLOWED',
                         token1     => 'ASSET KEY', p_log_level_rec => g_log_level_rec);
                     raise pub_error;
                end if;
             end if;
         end if;

         if (NOT FA_ASSET_VAL_PVT.validate_asset_key (
             p_transaction_type_code => px_trans_rec.transaction_type_code,
             p_asset_key_ccid        => px_asset_desc_rec_new.asset_key_ccid,
             p_calling_fn            => l_calling_fn
         , p_log_level_rec => g_log_level_rec)) then
             raise pub_error;
         end if;

         l_asset_desc_rec.asset_key_ccid:= px_asset_desc_rec_new.asset_key_ccid;
      end if;
    end if;

   -- Parent asset
   l_err_stage:= 'Parent Asset';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
   end if;


   if (px_asset_desc_rec_new.parent_asset_id is NOT NULL) then
      if (nvl(l_asset_desc_rec.parent_asset_id, -999) <>
          px_asset_desc_rec_new.parent_asset_id) then

          if (px_asset_desc_rec_new.parent_asset_id = FND_API.G_MISS_NUM) then
             --px_asset_desc_rec_new.parent_asset_id := NULL;
             null;
          else
             if (NOT FA_ASSET_VAL_PVT.validate_parent_asset(
                  p_parent_asset_id  => px_asset_desc_rec_new.parent_asset_id,
                  p_asset_id         => px_asset_hdr_rec.asset_id
             , p_log_level_rec => g_log_level_rec)) then
                raise pub_error;
             end if;
          end if;
          l_asset_desc_rec.parent_asset_id :=
             px_asset_desc_rec_new.parent_asset_id;
      end if;
   end if;

   -- Manufacturer
   l_err_stage:= 'Manufacturer';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
   end if;


   if (px_asset_desc_rec_new.manufacturer_name is NOT NULL) then
       if (nvl(l_asset_desc_rec.manufacturer_name, '-999') <>
           px_asset_desc_rec_new.manufacturer_name) then

           if (px_asset_desc_rec_new.manufacturer_name = FND_API.G_MISS_CHAR)
              then null; --px_asset_desc_rec_new.manufacturer_name := NULL;
           end if;

           l_asset_desc_rec.manufacturer_name :=
              px_asset_desc_rec_new.manufacturer_name;
       end if;
   end if;

   /*
   if (nvl(l_asset_desc_rec.manufacturer_name, '-999') <>
       px_asset_desc_rec_new.manufacturer_name) then

      if (NOT FA_ASSET_VAL_PVT.validate_supplier_name (
                 p_transaction_type_code => p_trans_rec.transaction_type_code,
                 p_calling_fn            => l_calling_fn
      , p_log_level_rec => g_log_level_rec)) then
         raise pub_error;
      end if;
   end if;

   if (NOT FA_ASSET_VAL_PVT.validate_supplier_number (
             p_transaction_type_code => p_trans_rec.transaction_type_code,
             p_calling_fn            => p_calling_fn
   , p_log_level_rec => g_log_level_rec)) then return FALSE;
   end if;
   */

   -- Model Number
   l_err_stage:= 'Model Number';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.model_number is NOT NULL) then
      if (nvl(l_asset_desc_rec.model_number, '-999') <>
          px_asset_desc_rec_new.model_number)
      then
         if (px_asset_desc_rec_new.model_number = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.model_number := NULL;
            null;
         end if;

         l_asset_desc_rec.model_number := px_asset_desc_rec_new.model_number;
      end if;
   end if;

   -- Warranty Number
   l_err_stage:= 'Warranty Number';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.warranty_id is NOT NULL) then
      if (nvl(l_asset_desc_rec.warranty_id, -999) <>
          px_asset_desc_rec_new.warranty_id)
      then
         if (px_asset_desc_rec_new.warranty_id = FND_API.G_MISS_NUM) then
            --px_asset_desc_rec_new.warranty_id := NULL;
            null;
         else
            -- We will need dpis to validate warranty.  Same in primary/rep
            if not FA_UTIL_PVT.get_asset_fin_rec(
                     p_asset_hdr_rec     => px_asset_hdr_rec,
                     px_asset_fin_rec    => l_asset_fin_rec,
                     p_mrc_sob_type_code => 'P' , p_log_level_rec => g_log_level_rec) then
               raise pub_error;
            end if;

            if (NOT FA_ASSET_VAL_PVT.validate_warranty(
                p_warranty_id            => px_asset_desc_rec_new.warranty_id,
                p_date_placed_in_service =>
                   l_asset_fin_rec.date_placed_in_service,
                p_book_type_code         => px_asset_hdr_rec.book_type_code
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         end if;
      end if;
      l_old_warranty_id := l_asset_desc_rec.warranty_id;
      l_asset_desc_rec.warranty_id := px_asset_desc_rec_new.warranty_id;
   end if;

   -- Lease
   l_err_stage:= 'Lease';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
   end if;

   if (px_asset_desc_rec_new.lease_id is NOT NULL) then
      if (nvl(l_asset_desc_rec.lease_id, -999) <>
          px_asset_desc_rec_new.lease_id) then

         if (px_asset_desc_rec_new.lease_id = FND_API.G_MISS_NUM) then

            null;

            -- px_asset_desc_rec_new.lease_id := NULL;

/*
            -- null out the lease dffs
            l_asset_desc_rec.lease_desc_flex.attribute_category_code := null;
            l_asset_desc_rec.lease_desc_flex.context    := null;
            l_asset_desc_rec.lease_desc_flex.attribute1 := null;
            l_asset_desc_rec.lease_desc_flex.attribute2 := null;
            l_asset_desc_rec.lease_desc_flex.attribute3 := null;
            l_asset_desc_rec.lease_desc_flex.attribute4 := null;
            l_asset_desc_rec.lease_desc_flex.attribute5 := null;
            l_asset_desc_rec.lease_desc_flex.attribute6 := null;
            l_asset_desc_rec.lease_desc_flex.attribute7 := null;
            l_asset_desc_rec.lease_desc_flex.attribute8 := null;
            l_asset_desc_rec.lease_desc_flex.attribute9 := null;
            l_asset_desc_rec.lease_desc_flex.attribute10 := null;
            l_asset_desc_rec.lease_desc_flex.attribute11 := null;
            l_asset_desc_rec.lease_desc_flex.attribute12 := null;
            l_asset_desc_rec.lease_desc_flex.attribute13 := null;
            l_asset_desc_rec.lease_desc_flex.attribute14 := null;
            l_asset_desc_rec.lease_desc_flex.attribute15 := null;
*/
         else

            if (l_crl_enabled) then
               if (NOT fa_cua_asset_apis.check_override_allowed(
                      p_attribute_name => 'LEASE_NUMBER',
                      p_book_type_code => px_asset_hdr_rec.book_type_code,
                      p_asset_id       => px_asset_hdr_rec.asset_id,
                      x_override_flag  => l_override_flag,
                      p_log_level_rec  => g_log_level_rec
               )) then
                  fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
                  raise pub_error;
               end if;

               if (l_override_flag = 'N') then
                  fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_OVERRIDE_NOT_ALLOWED',
                      token1     => 'LEASE NUMBER', p_log_level_rec => g_log_level_rec);
                  raise pub_error;
               end if;
            end if;

            if (NOT FA_ASSET_VAL_PVT.validate_lease(
               p_asset_id  => px_asset_hdr_rec.asset_id,
               p_lease_id  => px_asset_desc_rec_new.lease_id
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;

         end if;
         l_asset_desc_rec.lease_id := px_asset_desc_rec_new.lease_id;
      end if;

      -- Update Lease DFF
      if (px_asset_desc_rec_new.lease_desc_flex.attribute1 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute1, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute1) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute1 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute1 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute1;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute2 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute2, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute2) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute2 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute2 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute2;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute3 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute3, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute3) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute3 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute3 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute3;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute4 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute4, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute4) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute4 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute4 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute4;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute5 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute5, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute5) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute5 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute5 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute5;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute6 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute6, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute6) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute6 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute6 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute6;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute7 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute7, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute7) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute7 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute7 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute7;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute8 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute8, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute8) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute8 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute8 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute8;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute9 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute9, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute9) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute9 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute9 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute9;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute10 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute10, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute10) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute10 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute10 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute10;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute11 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute11, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute11) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute11 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute11 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute11;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute12 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute12, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute12) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute12 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute12 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute12;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute13 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute13, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute13) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute13 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute13 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute13;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute14 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute14, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute14) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute14 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute14 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute14;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute15 is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute15, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute15) then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute15 =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute15 :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute15;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.attribute_category_code
          is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.attribute_category_code,
                 '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.attribute_category_code)
          then

              if (px_asset_desc_rec_new.lease_desc_flex.attribute_category_code
                  = FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.attribute_category_code :=
                 px_asset_desc_rec_new.lease_desc_flex.attribute_category_code;

          end if;
      end if;

      if (px_asset_desc_rec_new.lease_desc_flex.context is NOT NULL) then
          if (nvl(l_asset_desc_rec.lease_desc_flex.context, '-999') <>
              px_asset_desc_rec_new.lease_desc_flex.context) then

              if (px_asset_desc_rec_new.lease_desc_flex.context =
                  FND_API.G_MISS_CHAR)
              then null;
              end if;

              l_asset_desc_rec.lease_desc_flex.context :=
                 px_asset_desc_rec_new.lease_desc_flex.context;

          end if;
      end if;
   end if;

   -- in_use_flag
   l_err_stage:= 'in_use_flag';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.in_use_flag is NOT NULL) then
      if (nvl(l_asset_desc_rec.in_use_flag, '-999') <>
          px_asset_desc_rec_new.in_use_flag)
      then

         if (px_asset_desc_rec_new.in_use_flag = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.in_use_flag := NULL;
            null;
         end if;

         l_asset_desc_rec.in_use_flag := px_asset_desc_rec_new.in_use_flag;
      end if;
   end if;

   -- inventorial
   l_err_stage:= 'inventorial';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.inventorial is NOT NULL) then
      if (nvl(l_asset_desc_rec.inventorial, '-999') <> px_asset_desc_rec_new.inventorial)
      then

         if (px_asset_desc_rec_new.inventorial = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.inventorial := NULL;
            null;
         end if;

         l_asset_desc_rec.inventorial:= px_asset_desc_rec_new.inventorial;
      end if;
   end if;

  -- commitment
   l_err_stage:= 'commitment';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage
                              ,p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.commitment is NOT NULL) then

         l_asset_desc_rec.commitment:= px_asset_desc_rec_new.commitment;

   end if;

   -- investment_law
   l_err_stage:= 'investment_law';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage
                              ,p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.investment_law is NOT NULL) then

         l_asset_desc_rec.investment_law:= px_asset_desc_rec_new.investment_law;

   end if;

   -- property_type_code
   l_err_stage:= 'property_type_code';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.property_type_code is NOT NULL) then
      if (nvl(l_asset_desc_rec.property_type_code, '-999') <>
          px_asset_desc_rec_new.property_type_code) then

         if (px_asset_desc_rec_new.property_type_code = FND_API.G_MISS_CHAR)
            then --px_asset_desc_rec_new.property_type_code := NULL;

            if (NOT FA_ASSET_VAL_PVT.validate_property_type(
               p_property_type_code => NULL
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         else
            if (NOT FA_ASSET_VAL_PVT.validate_property_type(
               p_property_type_code => px_asset_desc_rec_new.property_type_code
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         end if;
         l_asset_desc_rec.property_type_code :=
            px_asset_desc_rec_new.property_type_code ;
      end if;
   end if;

   -- property_1245_1250_code
   l_err_stage:= 'property_1245_1250_code';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.property_1245_1250_code is NOT NULL) then
      if (nvl(l_asset_desc_rec.property_1245_1250_code, '-999') <>
          px_asset_desc_rec_new.property_1245_1250_code) then

         if (px_asset_desc_rec_new.property_1245_1250_code =
             FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.property_1245_1250_code := NULL;

            if (NOT FA_ASSET_VAL_PVT.validate_1245_1250_code(
               p_1245_1250_code => NULL
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         else
            if (NOT FA_ASSET_VAL_PVT.validate_1245_1250_code(
               p_1245_1250_code => px_asset_desc_rec_new.property_1245_1250_code
            , p_log_level_rec => g_log_level_rec)) then
               raise pub_error;
            end if;
         end if;

         l_asset_desc_rec.property_1245_1250_code :=
            px_asset_desc_rec_new.property_1245_1250_code;
      end if;
   end if;

   -- owned_leased
   l_err_stage:= 'owned_leased';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.owned_leased is NOT NULL) then
      if (nvl(l_asset_desc_rec.owned_leased, '-999') <>
          px_asset_desc_rec_new.owned_leased) then
         if (px_asset_desc_rec_new.owned_leased = FND_API.G_MISS_CHAR) then
            null;
            --px_asset_desc_rec_new.owned_leased := NULL;
         end if;

         l_asset_desc_rec.owned_leased := px_asset_desc_rec_new.owned_leased;
      end if;
   end if;

   -- new_used
   l_err_stage:= 'new_used';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.new_used is NOT NULL) then
      if (nvl(l_asset_desc_rec.new_used, '-999') <>
          px_asset_desc_rec_new.new_used) then
         if (px_asset_desc_rec_new.new_used = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.new_used := NULL;
            null;
         end if;

         l_asset_desc_rec.new_used := px_asset_desc_rec_new.new_used;
      end if;
   end if;

   -- add_cost_je_flag
   l_err_stage:= 'add_cost_je_flag';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.add_cost_je_flag is NOT NULL) then
      if (nvl(l_asset_desc_rec.add_cost_je_flag, '-999') <>
          px_asset_desc_rec_new.add_cost_je_flag) then

         if (px_asset_desc_rec_new.add_cost_je_flag = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.add_cost_je_flag := NULL;
            null;
         end if;

         l_asset_desc_rec.add_cost_je_flag :=
            px_asset_desc_rec_new.add_cost_je_flag;
      end if;
   end if;

   -- status
   l_err_stage:= 'status';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;


   if (px_asset_desc_rec_new.status is NOT NULL) then
      if (nvl(l_asset_desc_rec.status, '-999') <>
          px_asset_desc_rec_new.status) then

         if (px_asset_desc_rec_new.status = FND_API.G_MISS_CHAR) then
            --px_asset_desc_rec_new.status := NULL;
            null;
         end if;

         l_asset_desc_rec.status :=
            px_asset_desc_rec_new.status;
      end if;
   end if;

   -- Update Global Attributes
    l_err_stage:= 'Global_desc_flex';
    if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;

    l_asset_desc_rec.global_desc_flex := px_asset_desc_rec_new.global_desc_flex;


   l_err_stage:= 'Update Row';
   if (g_log_level_rec.statement_level) then
               fa_debug_pkg.add('Update_desc', 'before', l_err_stage, p_log_level_rec => g_log_level_rec);
     end if;

   if (NOT update_row(
          p_trans_rec          => px_trans_rec,
          p_asset_hdr_rec      => px_asset_hdr_rec,
          p_asset_desc_rec_new => l_asset_desc_rec,
          p_asset_cat_rec_new  => l_asset_cat_rec,
          p_old_warranty_id    => l_old_warranty_id,
          p_log_level_rec      => g_log_level_rec
   )) then
      raise pub_error;
   end if;

   if (FND_API.To_Boolean(p_commit)) then
      commit;
   end if;

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when pub_error then

      ROLLBACK TO do_desc_update;

      fa_srvr_msg.add_message
           (calling_fn => 'fa_asset_desc_pub.update_desc', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

   when others then

      ROLLBACK TO do_desc_update;

      fa_srvr_msg.add_sql_error
           (calling_fn => 'fa_asset_desc_pub.update_desc', p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status :=  FND_API.G_RET_STS_ERROR;

END update_desc;


FUNCTION update_row(
          p_trans_rec           IN fa_api_types.trans_rec_type,
          p_asset_hdr_rec       IN fa_api_types.asset_hdr_rec_type,
          p_asset_desc_rec_new  IN fa_api_types.asset_desc_rec_type,
          p_asset_cat_rec_new   IN fa_api_types.asset_cat_rec_type,
          p_old_warranty_id     IN number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   l_return_status boolean:= FALSE;
   l_calling_fn varchar2(30);
   update_error EXCEPTION;
   l_rowid            varchar2(10):= null;
BEGIN

   l_calling_fn := 'FA_ASSET_DESC_PUB.update_row';

   -- update fa_additions.
   -- for bug no. 3643781. made the serial number case sensitive.
   fa_additions_pkg.update_row (
         X_Rowid                => l_rowid,
         X_Asset_Id             => p_asset_hdr_rec.asset_id,
         X_Asset_Number         => upper(p_asset_desc_rec_new.asset_number),
         X_Asset_Key_Ccid       => p_asset_desc_rec_new.asset_key_ccid,
         X_Current_Units        => p_asset_desc_rec_new.current_units,
         X_Tag_Number           => upper(p_asset_desc_rec_new.tag_number),
         X_Description          => p_asset_desc_rec_new.description,
         X_Asset_Category_Id    => p_asset_cat_rec_new.category_id,
         X_Parent_Asset_Id      => p_asset_desc_rec_new.parent_asset_id,
         X_Manufacturer_Name    => p_asset_desc_rec_new.manufacturer_name,
         X_Serial_Number        => p_asset_desc_rec_new.serial_number,
         X_Model_Number         => p_asset_desc_rec_new.model_number,
         X_Property_Type_Code   => upper(p_asset_desc_rec_new.property_type_code),
         X_Property_1245_1250_Code =>
              p_asset_desc_rec_new.property_1245_1250_code,
         X_In_Use_Flag          => upper(p_asset_desc_rec_new.in_use_flag),
         X_Owned_Leased         => upper(p_asset_desc_rec_new.owned_leased),
         X_New_Used             => upper(p_asset_desc_rec_new.new_used),
         X_Unit_Adjustment_Flag => upper(p_asset_desc_rec_new.unit_adjustment_flag),
         X_Add_Cost_Je_Flag     => upper(p_asset_desc_rec_new.add_cost_je_flag),
         X_Attribute1           => p_asset_cat_rec_new.desc_flex.attribute1,
         X_Attribute2           => p_asset_cat_rec_new.desc_flex.attribute2,
         X_Attribute3           => p_asset_cat_rec_new.desc_flex.attribute3,
         X_Attribute4           => p_asset_cat_rec_new.desc_flex.attribute4,
         X_Attribute5           => p_asset_cat_rec_new.desc_flex.attribute5,
         X_Attribute6           => p_asset_cat_rec_new.desc_flex.attribute6,
         X_Attribute7           => p_asset_cat_rec_new.desc_flex.attribute7,
         X_Attribute8           => p_asset_cat_rec_new.desc_flex.attribute8,
         X_Attribute9           => p_asset_cat_rec_new.desc_flex.attribute9,
         X_Attribute10          => p_asset_cat_rec_new.desc_flex.attribute10,
         X_Attribute11          => p_asset_cat_rec_new.desc_flex.attribute11,
         X_Attribute12          => p_asset_cat_rec_new.desc_flex.attribute12,
         X_Attribute13          => p_asset_cat_rec_new.desc_flex.attribute13,
         X_Attribute14          => p_asset_cat_rec_new.desc_flex.attribute14,
         X_Attribute15          => p_asset_cat_rec_new.desc_flex.attribute15,
         X_Attribute16          => p_asset_cat_rec_new.desc_flex.attribute16,
         X_Attribute17          => p_asset_cat_rec_new.desc_flex.attribute17,
         X_Attribute18          => p_asset_cat_rec_new.desc_flex.attribute18,
         X_Attribute19          => p_asset_cat_rec_new.desc_flex.attribute19,
         X_Attribute20          => p_asset_cat_rec_new.desc_flex.attribute20,
         X_Attribute21          => p_asset_cat_rec_new.desc_flex.attribute21,
         X_Attribute22          => p_asset_cat_rec_new.desc_flex.attribute22,
         X_Attribute23          => p_asset_cat_rec_new.desc_flex.attribute23,
         X_Attribute24          => p_asset_cat_rec_new.desc_flex.attribute24,
         X_Attribute25          => p_asset_cat_rec_new.desc_flex.attribute25,
         X_Attribute26          => p_asset_cat_rec_new.desc_flex.attribute26,
         X_Attribute27          => p_asset_cat_rec_new.desc_flex.attribute27,
         X_Attribute28          => p_asset_cat_rec_new.desc_flex.attribute28,
         X_Attribute29          => p_asset_cat_rec_new.desc_flex.attribute29,
         X_Attribute30          => p_asset_cat_rec_new.desc_flex.attribute30,
         X_Attribute_Category_Code =>
              p_asset_cat_rec_new.desc_flex.attribute_category_code,
         X_gf_Attribute1        =>
              p_asset_desc_rec_new.global_desc_flex.attribute1,
         X_gf_Attribute2        =>
              p_asset_desc_rec_new.global_desc_flex.attribute2,
         X_gf_Attribute3        =>
              p_asset_desc_rec_new.global_desc_flex.attribute3,
         X_gf_Attribute4        =>
              p_asset_desc_rec_new.global_desc_flex.attribute4,
         X_gf_Attribute5        =>
              p_asset_desc_rec_new.global_desc_flex.attribute5,
         X_gf_Attribute6        =>
              p_asset_desc_rec_new.global_desc_flex.attribute6,
         X_gf_Attribute7        =>
              p_asset_desc_rec_new.global_desc_flex.attribute7,
         X_gf_Attribute8        =>
              p_asset_desc_rec_new.global_desc_flex.attribute8,
         X_gf_Attribute9        =>
              p_asset_desc_rec_new.global_desc_flex.attribute9,
         X_gf_Attribute10       =>
              p_asset_desc_rec_new.global_desc_flex.attribute10,
         X_gf_Attribute11       =>
              p_asset_desc_rec_new.global_desc_flex.attribute11,
         X_gf_Attribute12       =>
              p_asset_desc_rec_new.global_desc_flex.attribute12,
         X_gf_Attribute13       =>
              p_asset_desc_rec_new.global_desc_flex.attribute13,
         X_gf_Attribute14       =>
              p_asset_desc_rec_new.global_desc_flex.attribute14,
         X_gf_Attribute15       =>
              p_asset_desc_rec_new.global_desc_flex.attribute15,
         X_gf_Attribute16       =>
              p_asset_desc_rec_new.global_desc_flex.attribute16,
         X_gf_Attribute17       =>
              p_asset_desc_rec_new.global_desc_flex.attribute17,
         X_gf_Attribute18       =>
              p_asset_desc_rec_new.global_desc_flex.attribute18,
         X_gf_Attribute19       =>
              p_asset_desc_rec_new.global_desc_flex.attribute19,
         X_gf_Attribute20       =>
              p_asset_desc_rec_new.global_desc_flex.attribute20,
         X_gf_Attribute_Category_Code =>
              p_asset_desc_rec_new.global_desc_flex.attribute_category_code,
         X_Context              => p_asset_cat_rec_new.desc_flex.context,
         X_Lease_Id             => p_asset_desc_rec_new.lease_id,
         X_Inventorial          => upper(p_asset_desc_rec_new.inventorial),
	 X_Commitment		=> p_asset_desc_rec_new.commitment,
	 X_Investment_Law	=> p_asset_desc_rec_new.investment_law,
         X_Status               => upper(p_asset_desc_rec_new.status),
         X_Last_Update_Date     => p_trans_rec.who_info.last_update_date,
         X_Last_Updated_By      => p_trans_rec.who_info.last_updated_by,
         X_Last_Update_Login    => p_trans_rec.who_info.last_update_login,
         x_return_status        => l_return_status,
         X_Calling_Fn           => l_calling_fn,
         p_log_level_rec        => g_log_level_rec);

   if not l_return_status then
      raise update_error;
   end if;


   if ( p_asset_desc_rec_new.lease_id is not null and
        p_asset_desc_rec_new.lease_id <> FND_API.G_MISS_NUM ) then

        FA_DET_ADD_PKG.UPDATE_LEASE_DF
               (X_Lease_Id          => p_asset_desc_rec_new.Lease_Id,
                X_Last_Update_Date  => p_trans_rec.who_info.Last_Update_Date,
                X_Last_Updated_By   => p_trans_rec.who_info.Last_Updated_By,
                X_Last_Update_Login => p_trans_rec.who_info.Last_Update_Login,
                X_Attribute1        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute1,
                X_Attribute2        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute2,
                X_Attribute3        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute3,
                X_Attribute4        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute4,
                X_Attribute5        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute5,
                X_Attribute6        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute6,
                X_Attribute7        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute7,
                X_Attribute8        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute8,
                X_Attribute9        =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute9,
                X_Attribute10       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute10,
                X_Attribute11       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute11,
                X_Attribute12       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute12,
                X_Attribute13       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute13,
                X_Attribute14       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute14,
                X_Attribute15       =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute15,
                X_Attribute_Category_Code
                                    =>
                   p_asset_desc_rec_new.lease_desc_flex.Attribute_Category_Code,
                X_Return_Status     => l_return_status,
                X_Calling_Fn        => l_calling_fn, p_log_level_rec => p_log_level_rec);

      if not l_return_status then
         raise update_error;
      end if;
   end if;

   -- Update warranty info
   if (p_asset_desc_rec_new.warranty_id is NOT NULL) then
      if ((p_asset_desc_rec_new.warranty_id = FND_API.G_MISS_NUM) and
          (p_old_warranty_id is NOT NULL)) then
          -- Remove an existing warranty from an asset
          FA_ADD_WARRANTY_PKG.Update_table(
             WR_warranty_id       => NULL,
             WR_old_warranty_id   => p_old_warranty_id,
             WR_asset_id          => p_asset_hdr_rec.asset_id,
             WR_date_effective    => NULL,
             WR_date_ineffective  => p_trans_rec.who_info.last_update_date,
             WR_last_update_date  => p_trans_rec.who_info.last_update_date,
             WR_last_updated_by   => p_trans_rec.who_info.last_updated_by,
             WR_created_by        => NULL,
             WR_creation_date     => NULL,
             WR_last_update_login => p_trans_rec.who_info.last_update_login,
             WR_Update_Row        => 'YES',
             WR_Insert_Row        => 'NO',
             WR_calling_fn        => 'fa_asset_desc_pub.update_row'
         , p_log_level_rec => p_log_level_rec);
      elsif (p_old_warranty_id is NULL) then
         -- Add a warranty to an asset that doesn't have one
         FA_ADD_WARRANTY_PKG.Update_table(
             WR_warranty_id       => p_asset_desc_rec_new.warranty_id,
             WR_old_warranty_id   => NULL,
             WR_asset_id          => p_asset_hdr_rec.asset_id,
             WR_date_effective    => p_trans_rec.who_info.last_update_date,
             WR_date_ineffective  => NULL,
             WR_last_update_date  => p_trans_rec.who_info.last_update_date,
             WR_last_updated_by   => p_trans_rec.who_info.last_updated_by,
             WR_created_by        => p_trans_rec.who_info.last_updated_by,
             WR_creation_date     => p_trans_rec.who_info.last_update_date,
             WR_last_update_login => p_trans_rec.who_info.last_update_login,
             WR_Update_Row        => 'NO',
             WR_Insert_Row        => 'YES',
             WR_calling_fn        => 'fa_asset_desc_pub.update_row'
         , p_log_level_rec => p_log_level_rec);
      elsif (p_asset_desc_rec_new.warranty_id <> p_old_warranty_id) then
         -- Change an asset's existing warranty
         FA_ADD_WARRANTY_PKG.Update_table(
             WR_warranty_id       => p_asset_desc_rec_new.warranty_id,
             WR_old_warranty_id   => p_old_warranty_id,
             WR_asset_id          => p_asset_hdr_rec.asset_id,
             WR_date_effective    => p_trans_rec.who_info.last_update_date,
             WR_date_ineffective  => p_trans_rec.who_info.last_update_date,
             WR_last_update_date  => p_trans_rec.who_info.last_update_date,
             WR_last_updated_by   => p_trans_rec.who_info.last_updated_by,
             WR_created_by        => p_trans_rec.who_info.last_updated_by,
             WR_creation_date     => p_trans_rec.who_info.last_update_date,
             WR_last_update_login => p_trans_rec.who_info.last_update_login,
             WR_Update_Row        => 'YES',
             WR_Insert_Row        => 'YES',
             WR_calling_fn        => 'fa_asset_desc_pub.update_row'
         , p_log_level_rec => p_log_level_rec);
      end if;
   end if;

   return TRUE;

EXCEPTION
   when update_error then
	FA_SRVR_MSG.Add_Message(
	           Calling_Fn	       => l_calling_fn , p_log_level_rec => p_log_level_rec);

	return FALSE;
   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;

END update_row;


PROCEDURE update_invoice_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_inv_tbl_new          IN OUT NOCOPY fa_api_types.inv_tbl_type) IS

   inv_err         exception;

   l_rowid                        ROWID;
   l_period_rec                   fa_api_types.period_rec_type;
   l_inv_rec                      fa_api_types.inv_rec_type;

   l_calling_fn varchar2(40) := 'FA_ASSET_DESC_PUB.update_invoice_desc';

   -- Bug 8252607/5475276 Cursor to get the book_type_code
    CURSOR c_corp_book( p_asset_id number ) IS
    SELECT bc.book_type_code
      FROM fa_books bks,
           fa_book_controls bc
     WHERE bks.book_type_code = bc.distribution_source_book
       AND bks.book_type_code = bc.book_type_code
       AND bks.asset_id       = p_asset_id
       AND bks.transaction_header_id_out is null;


   -- For primary and reporting books
   l_reporting_flag               varchar2(1) := 'P';
   l_rsob_tbl                     fa_cache_pkg.fazcrsob_sob_tbl_type;
   l_mrc_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;

BEGIN

   SAVEPOINT do_invoice_desc_update;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise inv_err;
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
   if (NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
   )) then
      raise inv_err;
   end if;

   -- Bug 8252607/5475276 Get the book_type_code if it is not supplied.
   if (px_asset_hdr_rec.book_type_code is null) then
      open c_corp_book( px_asset_hdr_rec.asset_id );
      fetch c_corp_book into px_asset_hdr_rec.book_type_code;
      close c_corp_book;

      if px_asset_hdr_rec.book_type_code is null then
         fa_srvr_msg.add_message
	    (calling_fn => l_calling_fn,
	     name       => 'FA_EXP_GET_ASSET_INFO', p_log_level_rec => g_log_level_rec);
	 raise inv_err;
      end if;
   end if;

   -- Call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => px_asset_hdr_rec.book_type_code
   , p_log_level_rec => g_log_level_rec)) then
      raise inv_err;
   end if;

   px_asset_hdr_rec.set_of_books_id :=
      fa_cache_pkg.fazcbc_record.set_of_books_id;

   if (NOT FA_UTIL_PVT.get_period_rec (
      p_book           => px_asset_hdr_rec.book_type_code,
      p_effective_date => NULL,
      x_period_rec     => l_period_rec
   , p_log_level_rec => g_log_level_rec)) then
      raise inv_err;
   end if;

   -- Call cache to verify whether this is a primary or reporting book
   if (NOT fa_cache_pkg.fazcsob (
      X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
      X_mrc_sob_type_code => l_reporting_flag
   , p_log_level_rec => g_log_level_rec)) then
      raise inv_err;
   end if;

   -- Call the reporting books cache to get rep books.
   if (l_reporting_flag <> 'R') then
      if (NOT fa_cache_pkg.fazcrsob (
         x_book_type_code => px_asset_hdr_rec.book_type_code,
         x_sob_tbl        => l_rsob_tbl
      , p_log_level_rec => g_log_level_rec)) then
         raise inv_err;
      end if;
   end if;

   for mrc_index in 0..l_rsob_tbl.COUNT loop

      l_mrc_asset_hdr_rec := px_asset_hdr_rec;

      -- if the counter mrc_index  is at 0, then process incoming
      -- book else iterate through reporting books
      if (mrc_index  = 0) then
         l_mrc_asset_hdr_rec.set_of_books_id :=
            px_asset_hdr_rec.set_of_books_id;
      else
         l_mrc_asset_hdr_rec.set_of_books_id :=
            l_rsob_tbl(mrc_index);
         l_reporting_flag := 'R';
      end if;

      -- Need to always call fazcbcs
      if (NOT fa_cache_pkg.fazcbcs (
         X_book => l_mrc_asset_hdr_rec.book_type_code,
         X_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id
      , p_log_level_rec => g_log_level_rec)) then
         raise inv_err;
      end if;
/*
      -- call transaction approval for primary books only
      -- Will probably need to break this into an MRC wrapper thing
      if (l_reporting_flag <> 'R') then
         if (NOT fa_trx_approval_pkg.faxcat (
               X_book              => l_mrc_asset_hdr_rec.book_type_code,
               X_asset_id          => l_mrc_asset_hdr_rec.asset_id,
               X_trx_type          => px_trans_rec.transaction_type_code,
               X_trx_date          => px_trans_rec.transaction_date_entered,
               X_init_message_flag => 'NO'
         , p_log_level_rec => g_log_level_rec)) then
            raise inv_err;
         end if;
      end if;
*/
      for i in 1 .. px_inv_tbl_new.COUNT loop

         -- Retrieve old invoice record
         l_inv_rec.source_line_id := px_inv_tbl_new(i).source_line_id;

         if (NOT FA_UTIL_PVT.get_inv_rec (
            px_inv_rec          => l_inv_rec,
            p_mrc_sob_type_code => l_reporting_flag,
            p_set_of_books_id   => l_mrc_asset_hdr_rec.set_of_books_id,
            p_log_level_rec => g_log_level_rec)) then
            raise inv_err;
         end if;

         -- Invoice_Number
         if (px_inv_tbl_new(i).invoice_number is NOT NULL) then
            if (nvl(l_inv_rec.invoice_number, '-999') <>
                px_inv_tbl_new(i).invoice_number)
            then
               if (px_inv_tbl_new(i).invoice_number = FND_API.G_MISS_CHAR) then
                  --px_inv_tbl_new(i).invoice_number := NULL;
                  null;
               end if;

               l_inv_rec.invoice_number := px_inv_tbl_new(i).invoice_number;
            end if;
         end if;

         -- Ap_Distribution_Line_Number
         if (px_inv_tbl_new(i).ap_distribution_line_number is NOT NULL) then
            if (nvl(l_inv_rec.ap_distribution_line_number, -999) <>
                px_inv_tbl_new(i).ap_distribution_line_number) then
               if (px_inv_tbl_new(i).ap_distribution_line_number =
                   FND_API.G_MISS_NUM) then
                   --px_inv_tbl_new(i).ap_distribution_line_number := NULL;
                   null;
               end if;

               l_inv_rec.ap_distribution_line_number :=
                  px_inv_tbl_new(i).ap_distribution_line_number;
            end if;
         end if;

         -- Invoice_Line_Number
         if (px_inv_tbl_new(i).invoice_line_number is NOT NULL) then
            if (nvl(l_inv_rec.invoice_line_number, '-999') <>
                px_inv_tbl_new(i).invoice_line_number)
            then
               if (px_inv_tbl_new(i).invoice_line_number = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).invoice_line_number := NULL;
                  null;
               end if;

               l_inv_rec.invoice_line_number := px_inv_tbl_new(i).invoice_line_number;
            end if;
         end if;

         -- Invoice_Distribution_id
         if (px_inv_tbl_new(i).invoice_distribution_id is NOT NULL) then
            if (nvl(l_inv_rec.invoice_distribution_id, '-999') <>
                px_inv_tbl_new(i).invoice_distribution_id)
            then
               if (px_inv_tbl_new(i).invoice_distribution_id = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).invoice_distribution_id := NULL;
                  null;
               end if;

               l_inv_rec.invoice_distribution_id := px_inv_tbl_new(i).invoice_distribution_id;
            end if;
         end if;

         -- Po_Distribution_id
         if (px_inv_tbl_new(i).po_distribution_id is NOT NULL) then
            if (nvl(l_inv_rec.po_distribution_id, '-999') <>
                px_inv_tbl_new(i).po_distribution_id)
            then
               if (px_inv_tbl_new(i).po_distribution_id = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).po_distribution_id := NULL;
                  null;
               end if;

               l_inv_rec.po_distribution_id := px_inv_tbl_new(i).po_distribution_id;
            end if;
         end if;

         -- Description
         if (px_inv_tbl_new(i).description is NOT NULL) then
            if (nvl(l_inv_rec.description, '-999') <>
                px_inv_tbl_new(i).description) then
               if (px_inv_tbl_new(i).description = FND_API.G_MISS_CHAR) then
                  --px_inv_tbl_new(i).description := NULL;
                  null;
               end if;

               l_inv_rec.description := px_inv_tbl_new(i).description;
            end if;
         end if;

         -- Deleted_Flag
         if (px_inv_tbl_new(i).deleted_flag is NOT NULL) then
            if (nvl(l_inv_rec.deleted_flag, '-999') <>
                px_inv_tbl_new(i).deleted_flag) then
               if (px_inv_tbl_new(i).deleted_flag = FND_API.G_MISS_CHAR) then
                  --px_inv_tbl_new(i).deleted_flag := NULL;
                  null;
               end if;

               l_inv_rec.deleted_flag := px_inv_tbl_new(i).deleted_flag;

            end if;
         end if;

         -- PO_Vendor_Id
         if (px_inv_tbl_new(i).po_vendor_id is NOT NULL) then
            if (nvl(l_inv_rec.po_vendor_id, -999) <>
                px_inv_tbl_new(i).po_vendor_id) then
               if (px_inv_tbl_new(i).po_vendor_id = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).po_vendor_id := NULL;
                  null;
               end if;

               l_inv_rec.po_vendor_id := px_inv_tbl_new(i).po_vendor_id;
            end if;
         end if;

         -- PO_Number
         if (px_inv_tbl_new(i).po_number is NOT NULL) then
            if (nvl(l_inv_rec.po_number, '-999') <>
                px_inv_tbl_new(i).po_number) then
               if (px_inv_tbl_new(i).po_number = FND_API.G_MISS_CHAR) then
                  --px_inv_tbl_new(i).po_number := NULL;
                  null;
               end if;

               l_inv_rec.po_number := px_inv_tbl_new(i).po_number;
            end if;
         end if;

         -- Payables_Batch_Name
         if (px_inv_tbl_new(i).payables_batch_name is NOT NULL) then
            if (nvl(l_inv_rec.payables_batch_name, '-999') <>
                px_inv_tbl_new(i).payables_batch_name) then
               if (px_inv_tbl_new(i).payables_batch_name = FND_API.G_MISS_CHAR)
                  then null; --px_inv_tbl_new(i).payables_batch_name := NULL;
               end if;

               l_inv_rec.payables_batch_name :=
                  px_inv_tbl_new(i).payables_batch_name;
            end if;
         end if;

         -- Project_Asset_Line_Id
         if (px_inv_tbl_new(i).project_asset_line_id is NOT NULL) then
            if (nvl(l_inv_rec.project_asset_line_id, -999) <>
                px_inv_tbl_new(i).project_asset_line_id) then
               if (px_inv_tbl_new(i).project_asset_line_id =
                   FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).project_asset_line_id := NULL;
                  null;
               end if;

               l_inv_rec.project_asset_line_id :=
                  px_inv_tbl_new(i).project_asset_line_id;
            end if;
         end if;

         -- Project_Id
         if (px_inv_tbl_new(i).project_id is NOT NULL) then
            if (nvl(l_inv_rec.project_id, -999) <>
                px_inv_tbl_new(i).project_id) then
               if (px_inv_tbl_new(i).project_id = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).project_id := NULL;
                  null;
               end if;

               l_inv_rec.project_id := px_inv_tbl_new(i).project_id;
            end if;
         end if;

         -- Task_Id
         if (px_inv_tbl_new(i).task_id is NOT NULL) then
            if (nvl(l_inv_rec.task_id, -999) <> px_inv_tbl_new(i).task_id) then
               if (px_inv_tbl_new(i).task_id = FND_API.G_MISS_NUM) then
                  --px_inv_tbl_new(i).task_id := NULL;
                  null;
               end if;

               l_inv_rec.task_id := px_inv_tbl_new(i).task_id;
            end if;
         end if;

         -- Material Indicator
         if (px_inv_tbl_new(i).material_indicator_flag is NOT NULL) then
            if (nvl(l_inv_rec.material_indicator_flag, '-999') <>
                px_inv_tbl_new(i).material_indicator_flag) then
               if (px_inv_tbl_new(i).material_indicator_flag =
                   FND_API.G_MISS_CHAR) then
                  --px_inv_tbl_new(i).material_indicator_flag := NULL;
                  null;
               end if;

               l_inv_rec.material_indicator_flag :=
                  px_inv_tbl_new(i).material_indicator_flag;
            end if;
         end if;

         -- Flex Columns
         if (px_inv_tbl_new(i).attribute1 is NOT NULL) then
            if (nvl(l_inv_rec.attribute1, '-999') <>
                px_inv_tbl_new(i).attribute1) then

               l_inv_rec.attribute1 := px_inv_tbl_new(i).attribute1;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute2 is NOT NULL) then
            if (nvl(l_inv_rec.attribute2, '-999') <>
                px_inv_tbl_new(i).attribute2) then

               l_inv_rec.attribute2 := px_inv_tbl_new(i).attribute2;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute3 is NOT NULL) then
            if (nvl(l_inv_rec.attribute3, '-999') <>
                px_inv_tbl_new(i).attribute3) then

               l_inv_rec.attribute3 := px_inv_tbl_new(i).attribute3;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute4 is NOT NULL) then
            if (nvl(l_inv_rec.attribute4, '-999') <>
                px_inv_tbl_new(i).attribute4) then

               l_inv_rec.attribute4 := px_inv_tbl_new(i).attribute4;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute5 is NOT NULL) then
            if (nvl(l_inv_rec.attribute5, '-999') <>
                px_inv_tbl_new(i).attribute5) then

               l_inv_rec.attribute5 := px_inv_tbl_new(i).attribute5;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute6 is NOT NULL) then
            if (nvl(l_inv_rec.attribute6, '-999') <>
                px_inv_tbl_new(i).attribute6) then

               l_inv_rec.attribute6 := px_inv_tbl_new(i).attribute6;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute7 is NOT NULL) then
            if (nvl(l_inv_rec.attribute7, '-999') <>
                px_inv_tbl_new(i).attribute7) then

               l_inv_rec.attribute7 := px_inv_tbl_new(i).attribute7;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute8 is NOT NULL) then
            if (nvl(l_inv_rec.attribute8, '-999') <>
                px_inv_tbl_new(i).attribute8) then

               l_inv_rec.attribute8 := px_inv_tbl_new(i).attribute8;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute9 is NOT NULL) then
            if (nvl(l_inv_rec.attribute9, '-999') <>
                px_inv_tbl_new(i).attribute9) then

               l_inv_rec.attribute9 := px_inv_tbl_new(i).attribute9;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute10 is NOT NULL) then
            if (nvl(l_inv_rec.attribute10, '-999') <>
                px_inv_tbl_new(i).attribute10) then

               l_inv_rec.attribute10 := px_inv_tbl_new(i).attribute10;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute11 is NOT NULL) then
            if (nvl(l_inv_rec.attribute11, '-999') <>
                px_inv_tbl_new(i).attribute11) then

               l_inv_rec.attribute11 := px_inv_tbl_new(i).attribute11;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute12 is NOT NULL) then
            if (nvl(l_inv_rec.attribute12, '-999') <>
                px_inv_tbl_new(i).attribute12) then

               l_inv_rec.attribute12 := px_inv_tbl_new(i).attribute12;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute13 is NOT NULL) then
            if (nvl(l_inv_rec.attribute13, '-999') <>
                px_inv_tbl_new(i).attribute13) then

               l_inv_rec.attribute13 := px_inv_tbl_new(i).attribute13;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute14 is NOT NULL) then
            if (nvl(l_inv_rec.attribute14, '-999') <>
                px_inv_tbl_new(i).attribute14) then

               l_inv_rec.attribute14 := px_inv_tbl_new(i).attribute14;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute15 is NOT NULL) then
            if (nvl(l_inv_rec.attribute15, '-999') <>
                px_inv_tbl_new(i).attribute15) then

               l_inv_rec.attribute15 := px_inv_tbl_new(i).attribute15;
            end if;
         end if;

         if (px_inv_tbl_new(i).attribute_category_code is NOT NULL) then
            if (nvl(l_inv_rec.attribute_category_code, '-999') <>
                px_inv_tbl_new(i).attribute_category_code) then

               l_inv_rec.attribute_category_code :=
                  px_inv_tbl_new(i).attribute_category_code;
            end if;
         end if;

         l_rowid := NULL;

         FA_ASSET_INVOICES_PKG.Update_Row (
            X_Rowid                      => l_rowid,
            X_Source_Line_id             => l_inv_rec.Source_Line_Id,
            X_Asset_Id                   => l_mrc_asset_hdr_rec.asset_id,
            X_Po_Vendor_Id               => l_inv_rec.Po_Vendor_Id,
            X_Asset_Invoice_Id           => l_inv_rec.Asset_Invoice_Id,
            X_Fixed_Assets_Cost          => l_inv_rec.Fixed_Assets_Cost,
            X_Deleted_Flag               => l_inv_rec.Deleted_Flag,
            X_Po_Number                  => l_inv_rec.Po_Number,
            X_Invoice_Number             => l_inv_rec.Invoice_Number,
            X_Payables_Batch_Name        => l_inv_rec.Payables_Batch_Name,
            X_Payables_Code_Combination_Id
                                         =>
               l_inv_rec.Payables_Code_Combination_Id,
            X_Feeder_System_Name         =>
               l_inv_rec.Feeder_System_Name,
            X_Create_Batch_Date          => l_inv_rec.Create_Batch_Date,
            X_Create_Batch_Id            => l_inv_rec.Create_Batch_Id,
            X_Invoice_Date               => l_inv_rec.Invoice_Date,
            X_Payables_Cost              => l_inv_rec.Payables_Cost,
            X_Post_Batch_Id              => l_inv_rec.Post_Batch_Id,
            X_Invoice_Id                 => l_inv_rec.Invoice_Id,
            X_Ap_Distribution_Line_Number
                                         =>
               l_inv_rec.Ap_Distribution_Line_Number,
            X_Payables_Units             => l_inv_rec.Payables_Units,
            X_Split_Merged_Code          => l_inv_rec.Split_Merged_Code,
            X_Description                => l_inv_rec.Description,
            X_Parent_Mass_Addition_Id    => l_inv_rec.Parent_Mass_Addition_Id,
            X_Last_Update_Date           =>
               px_trans_rec.who_info.Last_Update_Date,
            X_Last_Updated_By            =>
               px_trans_rec.who_info.Last_Updated_By,
            X_Last_Update_Login          =>
               px_trans_rec.who_info.Last_Update_Login,
            X_Attribute1                 => l_inv_rec.Attribute1,
            X_Attribute2                 => l_inv_rec.Attribute2,
            X_Attribute3                 => l_inv_rec.Attribute3,
            X_Attribute4                 => l_inv_rec.Attribute4,
            X_Attribute5                 => l_inv_rec.Attribute5,
            X_Attribute6                 => l_inv_rec.Attribute6,
            X_Attribute7                 => l_inv_rec.Attribute7,
            X_Attribute8                 => l_inv_rec.Attribute8,
            X_Attribute9                 => l_inv_rec.Attribute9,
            X_Attribute10                => l_inv_rec.Attribute10,
            X_Attribute11                => l_inv_rec.Attribute11,
            X_Attribute12                => l_inv_rec.Attribute12,
            X_Attribute13                => l_inv_rec.Attribute13,
            X_Attribute14                => l_inv_rec.Attribute14,
            X_Attribute15                => l_inv_rec.Attribute15,
            X_Attribute_Category_Code    =>
               l_inv_rec.Attribute_Category_Code,
            X_Unrevalued_Cost            => l_inv_rec.Unrevalued_Cost,
            X_Merged_Code                => l_inv_rec.Merged_Code,
            X_Split_Code                 => l_inv_rec.Split_Code,
            X_Merge_Parent_Mass_Add_Id   =>
               l_inv_rec.Merge_Parent_Mass_Additions_Id,
            X_Split_Parent_Mass_Add_Id   =>
               l_inv_rec.Split_Parent_Mass_Additions_Id,
            X_Project_Asset_Line_Id      =>
               l_inv_rec.Project_Asset_Line_Id,
            X_Project_Id                 => l_inv_rec.Project_Id,
            X_Task_Id                    => l_inv_rec.Task_Id,
            X_Material_Indicator_Flag    => l_inv_rec.Material_Indicator_Flag,
            X_invoice_distribution_id    => l_inv_rec.Invoice_distribution_id,
            X_invoice_line_number        => l_inv_rec.Invoice_line_number,
            X_po_distribution_id         => l_inv_rec.Po_distribution_id,
            X_mrc_sob_type_code          => l_reporting_flag,
            X_set_of_books_id            => l_mrc_asset_hdr_rec.set_of_books_id,
            X_Calling_Fn                 => p_calling_fn
         , p_log_level_rec => g_log_level_rec);
      end loop;
   end loop;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   fnd_msg_pub.count_and_get (
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN inv_err THEN

      ROLLBACK TO do_invoice_desc_update;

      fa_srvr_msg.add_message
           (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

      ROLLBACK TO do_invoice_desc_update;

      fa_srvr_msg.add_sql_error
           (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

END update_invoice_desc;

PROCEDURE update_retirement_desc(
          -- Standard Parameters --
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status            OUT NOCOPY VARCHAR2,
          x_msg_count                OUT NOCOPY NUMBER,
          x_msg_data                 OUT NOCOPY VARCHAR2,
          p_calling_fn            IN     VARCHAR2,
          -- Transaction Object --
          px_trans_rec            IN OUT NOCOPY fa_api_types.trans_rec_type,
          -- Asset Object --
          px_asset_hdr_rec        IN OUT NOCOPY fa_api_types.asset_hdr_rec_type,
          px_asset_retire_rec_new IN OUT NOCOPY fa_api_types.asset_retire_rec_type) IS

   ret_err         exception;

   l_rowid                        ROWID;
   l_period_rec                   fa_api_types.period_rec_type;
   l_asset_retire_rec             fa_api_types.asset_retire_rec_type;

   l_calling_fn varchar2(40) := 'FA_ASSET_DESC_PUB.update_retirement_desc';

   -- For primary and reporting books
   l_reporting_flag               varchar2(1) := 'P';
   l_rsob_tbl                     fa_cache_pkg.fazcrsob_sob_tbl_type;
   l_mrc_asset_hdr_rec            fa_api_types.asset_hdr_rec_type;

   l_old_primary_proceeds_of_sale number;
   l_old_primary_cost_of_removal  number;
   l_old_rep_proceeds_of_sale     number;
   l_old_rep_cost_of_removal      number;
   l_rate                         number;

BEGIN

   SAVEPOINT do_retirement_desc_update;
   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise ret_err;
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
   if (NOT fnd_api.compatible_api_call (
          G_API_VERSION,
          p_api_version,
          G_API_NAME,
          G_PKG_NAME
   )) then
      raise ret_err;
   end if;

    -- Bug 8252607/5475276 Populate the values of book_type_code
    -- and asset_id if they are not supplied.
    if (px_asset_hdr_rec.book_type_code is null or
        px_asset_hdr_rec.asset_id is null) then
	  l_asset_retire_rec.retirement_id := px_asset_retire_rec_new.retirement_id;
	  if not FA_UTIL_PVT.get_asset_retire_rec
	         (px_asset_retire_rec => l_asset_retire_rec,
		  p_mrc_sob_type_code => 'P',
                  p_set_of_books_id => null,
                  p_log_level_rec => g_log_level_rec) then
		    raise ret_err;
          end if;

	  px_asset_hdr_rec.book_type_code := l_asset_retire_rec.detail_info.book_type_code;
	  px_asset_hdr_rec.asset_id := l_asset_retire_rec.detail_info.asset_id;
    end if;

   -- Call the cache for the primary transaction book
   if (NOT fa_cache_pkg.fazcbc (
      X_book => px_asset_hdr_rec.book_type_code
   , p_log_level_rec => g_log_level_rec)) then
      raise ret_err;
   end if;

   px_asset_hdr_rec.set_of_books_id :=
      fa_cache_pkg.fazcbc_record.set_of_books_id;

   if (NOT FA_UTIL_PVT.get_period_rec (
      p_book           => px_asset_hdr_rec.book_type_code,
      p_effective_date => NULL,
      x_period_rec     => l_period_rec
   , p_log_level_rec => g_log_level_rec)) then
      raise ret_err;
   end if;

   -- Call cache to verify whether this is a primary or reporting book
   if (NOT fa_cache_pkg.fazcsob (
      X_set_of_books_id   => px_asset_hdr_rec.set_of_books_id,
      X_mrc_sob_type_code => l_reporting_flag
   , p_log_level_rec => g_log_level_rec)) then
      raise ret_err;
   end if;

   -- Call the reporting books cache to get rep books.
   if (l_reporting_flag <> 'R') then
      if (NOT fa_cache_pkg.fazcrsob (
         x_book_type_code => px_asset_hdr_rec.book_type_code,
         x_sob_tbl        => l_rsob_tbl
      , p_log_level_rec => g_log_level_rec)) then
         raise ret_err;
      end if;
   end if;

   for mrc_index in 0..l_rsob_tbl.COUNT loop

      l_mrc_asset_hdr_rec := px_asset_hdr_rec;

      -- if the counter mrc_index  is at 0, then process incoming
      -- book else iterate through reporting books
      if (mrc_index  = 0) then
         l_mrc_asset_hdr_rec.set_of_books_id :=
            px_asset_hdr_rec.set_of_books_id;
      else
         l_mrc_asset_hdr_rec.set_of_books_id :=
            l_rsob_tbl(mrc_index);
         l_reporting_flag := 'R';
      end if;

      -- Need to always call fazcbcs
      if (NOT fa_cache_pkg.fazcbcs (
         X_book => l_mrc_asset_hdr_rec.book_type_code,
         X_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id
      , p_log_level_rec => g_log_level_rec)) then
         raise ret_err;
      end if;
/*
      -- call transaction approval for primary books only
      -- Will probably need to break this into an MRC wrapper thing
      if (l_reporting_flag <> 'R') then
         if (NOT fa_trx_approval_pkg.faxcat (
               X_book              => l_mrc_asset_hdr_rec.book_type_code,
               X_asset_id          => l_mrc_asset_hdr_rec.asset_id,
               X_trx_type          => px_trans_rec.transaction_type_code,
               X_trx_date          => px_trans_rec.transaction_date_entered,
               X_init_message_flag => 'NO'
         , p_log_level_rec => g_log_level_rec)) then
            raise ret_err;
         end if;
      end if;
*/
      l_asset_retire_rec := px_asset_retire_rec_new;

      if (g_log_level_rec.statement_level) then
         fa_debug_pkg.add('Set Of Books Id',
            'l_mrc_asset_hdr_rec.set_of_books_id',
            to_char(l_mrc_asset_hdr_rec.set_of_books_id));
         fa_debug_pkg.add('Reporting Flag','l_reporting_flag',
            l_reporting_flag, p_log_level_rec => g_log_level_rec);
         fa_debug_pkg.add('Retirement ID','l_asset_retire_rec.retirement_id',
            to_char(l_asset_retire_rec.retirement_id), g_log_level_rec);
      end if;

      if (NOT FA_UTIL_PVT.get_asset_retire_rec (
         px_asset_retire_rec => l_asset_retire_rec,
         p_mrc_sob_type_code => l_reporting_flag,
         p_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id
      , p_log_level_rec => g_log_level_rec)) then
         raise ret_err;
      end if;

      -- Date Retired
      if (px_asset_retire_rec_new.date_retired is NOT NULL) then
         if (l_asset_retire_rec.date_retired <>
             px_asset_retire_rec_new.date_retired) then

            l_asset_retire_rec.date_retired :=
               px_asset_retire_rec_new.date_retired;
         end if;
      end if;

      -- Status
      if (px_asset_retire_rec_new.status is NOT NULL) then
         if (l_asset_retire_rec.status <> px_asset_retire_rec_new.status) then
            if (px_asset_retire_rec_new.status = FND_API.G_MISS_CHAR) then
               --px_asset_retire_rec_new.status := NULL;
               null;
            end if;

            l_asset_retire_rec.status := px_asset_retire_rec_new.status;
         end if;
      end if;

      -- Retirement Type Code
      if (px_asset_retire_rec_new.retirement_type_code is NOT NULL) then
         if (nvl(l_asset_retire_rec.retirement_type_code, '-999') <>
             px_asset_retire_rec_new.retirement_type_code) then
            if (px_asset_retire_rec_new.retirement_type_code =
                FND_API.G_MISS_CHAR) then
                --px_asset_retire_rec_new.retirement_type_code := NULL;
                null;
            end if;

            l_asset_retire_rec.retirement_type_code :=
               px_asset_retire_rec_new.retirement_type_code;
         end if;
      end if;

      -- Retirement Convention
      if (px_asset_retire_rec_new.retirement_prorate_convention is NOT NULL)
      then
         if (l_asset_retire_rec.retirement_prorate_convention <>
             px_asset_retire_rec_new.retirement_prorate_convention) then
            if (px_asset_retire_rec_new.retirement_prorate_convention =
                FND_API.G_MISS_CHAR) then
               --px_asset_retire_rec_new.retirement_prorate_convention := NULL;
               null;
            end if;

            l_asset_retire_rec.retirement_prorate_convention :=
               px_asset_retire_rec_new.retirement_prorate_convention;
         end if;
      end if;

      -- Proceeds of Sale
      if (px_asset_retire_rec_new.proceeds_of_sale is NOT NULL) then
         if (nvl(l_asset_retire_rec.proceeds_of_sale, -999) <>
             px_asset_retire_rec_new.proceeds_of_sale) then
            if (px_asset_retire_rec_new.proceeds_of_sale = FND_API.G_MISS_NUM)
               then null; --px_asset_retire_rec_new.proceeds_of_sale := NULL;
            end if;

            -- Fix for Bug #2368292.  Need to account for reporting books
            if (l_reporting_flag <> 'R') then

               -- Save old primary proceeds for rate calculation
               l_old_primary_proceeds_of_sale :=
                  l_asset_retire_rec.proceeds_of_sale;

               -- Set new proceeds
               l_asset_retire_rec.proceeds_of_sale :=
                  px_asset_retire_rec_new.proceeds_of_sale;
            else

               -- Save old reporting proceeds for rate calculation
               l_old_rep_proceeds_of_sale :=
                  l_asset_retire_rec.proceeds_of_sale;

         /* BUG4128113
               -- Calculate exchange rate.
               if (nvl(l_old_primary_proceeds_of_sale, 0) <> 0) then
                  l_rate := l_old_rep_proceeds_of_sale /
                            l_old_primary_proceeds_of_sale;

               else
                  -- get average rate from the latest transaction record
                  select br1.avg_exchange_rate
                  into   l_rate
                  from   fa_mc_books_rates br1
                  where  br1.asset_id = l_mrc_asset_hdr_rec.asset_id
                  and    br1.book_type_code = l_mrc_asset_hdr_rec.book_type_code
                  and    br1.set_of_books_id =
                            l_mrc_asset_hdr_rec.set_of_books_id
                  and    br1.transaction_header_id =
                  (
                   select max(br2.transaction_header_id)
                   from   fa_mc_books_rates br2
                   where  br2.asset_id = l_mrc_asset_hdr_rec.asset_id
                   and    br2.book_type_code  =
                             l_mrc_asset_hdr_rec.book_type_code
                   and    br2.set_of_books_id =
                             l_mrc_asset_hdr_rec.set_of_books_id
                  );
               end if;
         */

               /* BUG#4128113 */
               if not FA_MC_UTIL_PVT.get_trx_rate
                     (p_prim_set_of_books_id      => px_asset_hdr_rec.set_of_books_id,
                      p_reporting_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id,
                      px_exchange_date            => l_asset_retire_rec.date_retired,
                      p_book_type_code            => l_mrc_asset_hdr_rec.book_type_code,
                      px_rate                     => l_rate
                     , p_log_level_rec => g_log_level_rec) then raise ret_err;

               end if;

               -- Calculate the new proceeds of sale
               l_asset_retire_rec.proceeds_of_sale :=
                  px_asset_retire_rec_new.proceeds_of_sale * l_rate;

               -- Round the converted amount
               if (NOT fa_utils_pkg.faxrnd (
                  x_amount => l_asset_retire_rec.proceeds_of_sale,
                  x_book   => l_mrc_asset_hdr_rec.book_type_code,
                  x_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id,
                  p_log_level_rec => g_log_level_rec)) then
                  raise ret_err;
               end if;
            end if;
         end if;
      end if;

      -- Cost of Removal
      if (px_asset_retire_rec_new.cost_of_removal is NOT NULL) then
         if (nvl(l_asset_retire_rec.cost_of_removal, -999) <>
             px_asset_retire_rec_new.cost_of_removal) then
            if (px_asset_retire_rec_new.cost_of_removal = FND_API.G_MISS_NUM)
               then null; --px_asset_retire_rec_new.cost_of_removal := NULL;
            end if;

            -- Fix for Bug #2368292.  Need to account for reporting books
            if (l_reporting_flag <> 'R') then

               -- Save old primary cost of removal for rate calculation
               l_old_primary_cost_of_removal :=
                  l_asset_retire_rec.cost_of_removal;

               -- Set new cost of removal
               l_asset_retire_rec.cost_of_removal :=
                  px_asset_retire_rec_new.cost_of_removal;
            else

               -- Save old reporting cost of removal for rate calculation
               l_old_rep_cost_of_removal :=
                  l_asset_retire_rec.cost_of_removal;

               -- Calculate exchange rate.
               if (l_rate is not null) then
                  -- If we already have a rate from proceeds, use that
                  null;

               elsif (nvl(l_old_primary_cost_of_removal, 0) <> 0) then
                  l_rate := l_old_rep_cost_of_removal /
                            l_old_primary_cost_of_removal;

               else
                  -- get average rate from the latest transaction record
                  select br1.avg_exchange_rate
                  into   l_rate
                  from   fa_mc_books_rates br1
                  where  br1.asset_id = l_mrc_asset_hdr_rec.asset_id
                  and    br1.book_type_code = l_mrc_asset_hdr_rec.book_type_code
                  and    br1.set_of_books_id =
                            l_mrc_asset_hdr_rec.set_of_books_id
                  and    br1.transaction_header_id =
                  (
                   select max(br2.transaction_header_id)
                   from   fa_mc_books_rates br2
                   where  br2.asset_id = l_mrc_asset_hdr_rec.asset_id
                   and    br2.book_type_code  =
                             l_mrc_asset_hdr_rec.book_type_code
                   and    br2.set_of_books_id =
                             l_mrc_asset_hdr_rec.set_of_books_id
                  );
               end if;

               -- Calculate the new cost of removal
               l_asset_retire_rec.cost_of_removal :=
                  px_asset_retire_rec_new.cost_of_removal * l_rate;

               -- Round the converted amount
               if (NOT fa_utils_pkg.faxrnd (
                  x_amount => l_asset_retire_rec.cost_of_removal,
                  x_book   => l_mrc_asset_hdr_rec.book_type_code,
                  x_set_of_books_id => l_mrc_asset_hdr_rec.set_of_books_id,
                  p_log_level_rec => g_log_level_rec)) then
                  raise ret_err;
               end if;
            end if;
         end if;
      end if;

      -- STL Method Code
      if (px_asset_retire_rec_new.detail_info.stl_method_code is NOT NULL) then
         if (nvl(l_asset_retire_rec.detail_info.stl_method_code, '-999') <>
             px_asset_retire_rec_new.detail_info.stl_method_code) then
            if (px_asset_retire_rec_new.detail_info.stl_method_code =
                FND_API.G_MISS_CHAR) then
               null;
               --px_asset_retire_rec_new.detail_info.stl_method_code := NULL;
            end if;

            l_asset_retire_rec.detail_info.stl_method_code :=
               px_asset_retire_rec_new.detail_info.stl_method_code;
         end if;
      end if;

      -- STL Life in Months
      if (px_asset_retire_rec_new.detail_info.stl_life_in_months is NOT NULL)
      then
         if (nvl(l_asset_retire_rec.detail_info.stl_life_in_months, -999) <>
             px_asset_retire_rec_new.detail_info.stl_life_in_months) then
            if (px_asset_retire_rec_new.detail_info.stl_life_in_months =
                FND_API.G_MISS_NUM) then
               --px_asset_retire_rec_new.detail_info.stl_life_in_months := NULL;
               null;
            end if;

            l_asset_retire_rec.detail_info.stl_life_in_months :=
               px_asset_retire_rec_new.detail_info.stl_life_in_months;
         end if;
      end if;

      -- Reference Num
      if (px_asset_retire_rec_new.reference_num is NOT NULL) then
         if (nvl(l_asset_retire_rec.reference_num, '-999') <>
             px_asset_retire_rec_new.reference_num) then
            if (px_asset_retire_rec_new.reference_num = FND_API.G_MISS_CHAR)
               then null; --px_asset_retire_rec_new.reference_num := NULL;
            end if;

            l_asset_retire_rec.reference_num :=
               px_asset_retire_rec_new.reference_num;
         end if;
      end if;

      -- Sold To
      if (px_asset_retire_rec_new.sold_to is NOT NULL) then
         if (nvl(l_asset_retire_rec.sold_to, '-999') <>
             px_asset_retire_rec_new.sold_to)
         then
            if (px_asset_retire_rec_new.sold_to = FND_API.G_MISS_CHAR) then
               null;
               --px_asset_retire_rec_new.sold_to := NULL;
            end if;

            l_asset_retire_rec.sold_to := px_asset_retire_rec_new.sold_to;
         end if;
      end if;

      -- Trade In Asset Id
      if (px_asset_retire_rec_new.trade_in_asset_id is NOT NULL) then
         if (nvl(l_asset_retire_rec.trade_in_asset_id, -999) <>
             px_asset_retire_rec_new.trade_in_asset_id) then
            if (px_asset_retire_rec_new.trade_in_asset_id = FND_API.G_MISS_NUM)
               then null; --px_asset_retire_rec_new.trade_in_asset_id := NULL;
            end if;

            l_asset_retire_rec.trade_in_asset_id :=
               px_asset_retire_rec_new.trade_in_asset_id;
         end if;
      end if;

      -- Flex Columns
      if (px_asset_retire_rec_new.desc_flex.attribute1 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute1, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute1) then

            l_asset_retire_rec.desc_flex.attribute1 :=
               px_asset_retire_rec_new.desc_flex.attribute1;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute2 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute2, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute2) then

            l_asset_retire_rec.desc_flex.attribute2 :=
               px_asset_retire_rec_new.desc_flex.attribute2;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute3 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute3, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute3) then

            l_asset_retire_rec.desc_flex.attribute3 :=
               px_asset_retire_rec_new.desc_flex.attribute3;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute4 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute4, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute4) then

            l_asset_retire_rec.desc_flex.attribute4 :=
               px_asset_retire_rec_new.desc_flex.attribute4;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute5 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute5, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute5) then

            l_asset_retire_rec.desc_flex.attribute5 :=
               px_asset_retire_rec_new.desc_flex.attribute5;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute6 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute6, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute6) then

            l_asset_retire_rec.desc_flex.attribute6 :=
               px_asset_retire_rec_new.desc_flex.attribute6;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute7 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute7, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute7) then

            l_asset_retire_rec.desc_flex.attribute7 :=
               px_asset_retire_rec_new.desc_flex.attribute7;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute8 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute8, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute8) then

            l_asset_retire_rec.desc_flex.attribute8 :=
               px_asset_retire_rec_new.desc_flex.attribute8;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute9 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute9, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute9) then

            l_asset_retire_rec.desc_flex.attribute9 :=
               px_asset_retire_rec_new.desc_flex.attribute9;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute10 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute10, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute10) then

            l_asset_retire_rec.desc_flex.attribute10 :=
               px_asset_retire_rec_new.desc_flex.attribute10;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute11 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute11, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute11) then

            l_asset_retire_rec.desc_flex.attribute11 :=
               px_asset_retire_rec_new.desc_flex.attribute11;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute12 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute12, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute12) then

            l_asset_retire_rec.desc_flex.attribute12 :=
               px_asset_retire_rec_new.desc_flex.attribute12;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute13 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute13, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute13) then

            l_asset_retire_rec.desc_flex.attribute13 :=
               px_asset_retire_rec_new.desc_flex.attribute13;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute14 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute14, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute14) then

            l_asset_retire_rec.desc_flex.attribute14 :=
               px_asset_retire_rec_new.desc_flex.attribute14;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute15 is NOT NULL) then
         if (nvl(l_asset_retire_rec.desc_flex.attribute15, '-999') <>
             px_asset_retire_rec_new.desc_flex.attribute15) then

            l_asset_retire_rec.desc_flex.attribute15 :=
               px_asset_retire_rec_new.desc_flex.attribute15;
         end if;
      end if;

      if (px_asset_retire_rec_new.desc_flex.attribute_category_code is NOT NULL)
      then
         if (nvl(l_asset_retire_rec.desc_flex.attribute_category_code, '999') <>
             px_asset_retire_rec_new.desc_flex.attribute_category_code) then

            l_asset_retire_rec.desc_flex.attribute_category_code :=
               px_asset_retire_rec_new.desc_flex.attribute_category_code;
         end if;
      end if;

      l_rowid := NULL;

      FA_RETIREMENTS_PKG.Update_Row(
           X_Rowid                => l_rowid,
           X_Retirement_Id        => l_asset_retire_rec.retirement_id,
           X_Book_Type_Code       =>
              l_asset_retire_rec.detail_info.book_type_code,
           X_Asset_Id             => l_asset_retire_rec.detail_info.asset_id,
           X_Date_Retired         => l_asset_retire_rec.date_retired,
           X_Cost_Retired         => l_asset_retire_rec.cost_retired,
           X_Status               => l_asset_retire_rec.status,
           X_Last_Update_Date     => px_trans_rec.who_info.last_update_date,
           X_Last_Updated_By      => px_trans_rec.who_info.last_updated_by,
           X_Ret_Prorate_Convention
                                  =>
              l_asset_retire_rec.retirement_prorate_convention,
           X_Units                => l_asset_retire_rec.units_retired,
           X_Cost_Of_Removal      => l_asset_retire_rec.cost_of_removal,
           X_Nbv_Retired          => l_asset_retire_rec.detail_info.nbv_retired,
           X_Gain_Loss_Amount     =>
              l_asset_retire_rec.detail_info.gain_loss_amount,
           X_Proceeds_Of_Sale     => l_asset_retire_rec.proceeds_of_sale,
           X_Gain_Loss_Type_Code  =>
              l_asset_retire_rec.detail_info.gain_loss_type_code,
           X_Retirement_Type_Code => l_asset_retire_rec.retirement_type_code,
           X_Itc_Recaptured       =>
              l_asset_retire_rec.detail_info.itc_recaptured,
           X_Itc_Recapture_Id     =>
              l_asset_retire_rec.detail_info.itc_recapture_id,
           X_Reference_Num        => l_asset_retire_rec.reference_num,
           X_Sold_To              => l_asset_retire_rec.sold_to,
           X_Trade_In_Asset_Id    => l_asset_retire_rec.trade_in_asset_id,
           X_Stl_Method_Code      =>
              l_asset_retire_rec.detail_info.stl_method_code,
           X_Stl_Life_In_Months   =>
              l_asset_retire_rec.detail_info.stl_life_in_months,
           X_Last_Update_Login    => px_trans_rec.who_info.last_update_login,
           X_Attribute1           => l_asset_retire_rec.desc_flex.attribute1,
           X_Attribute2           => l_asset_retire_rec.desc_flex.attribute2,
           X_Attribute3           => l_asset_retire_rec.desc_flex.attribute3,
           X_Attribute4           => l_asset_retire_rec.desc_flex.attribute4,
           X_Attribute5           => l_asset_retire_rec.desc_flex.attribute5,
           X_Attribute6           => l_asset_retire_rec.desc_flex.attribute6,
           X_Attribute7           => l_asset_retire_rec.desc_flex.attribute7,
           X_Attribute8           => l_asset_retire_rec.desc_flex.attribute8,
           X_Attribute9           => l_asset_retire_rec.desc_flex.attribute9,
           X_Attribute10          => l_asset_retire_rec.desc_flex.attribute10,
           X_Attribute11          => l_asset_retire_rec.desc_flex.attribute11,
           X_Attribute12          => l_asset_retire_rec.desc_flex.attribute12,
           X_Attribute13          => l_asset_retire_rec.desc_flex.attribute13,
           X_Attribute14          => l_asset_retire_rec.desc_flex.attribute14,
           X_Attribute15          => l_asset_retire_rec.desc_flex.attribute15,
           X_Attribute_Category_Code
                                  =>
              l_asset_retire_rec.desc_flex.attribute_category_code,
           X_mrc_sob_type_code    => l_reporting_flag,
           X_set_of_books_id      => l_mrc_asset_hdr_rec.set_of_books_id,
           X_Calling_Fn           => p_calling_fn
      , p_log_level_rec => g_log_level_rec);

   end loop;

   -- commit if p_commit is TRUE.
   if (fnd_api.to_boolean (p_commit)) then
        COMMIT WORK;
   end if;

   -- Standard call to get message count and if count is 1 get message info.
   fnd_msg_pub.count_and_get (
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN ret_err THEN

      ROLLBACK TO do_retirement_desc_update;

      fa_srvr_msg.add_message
           (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN

      ROLLBACK TO do_retirement_desc_update;

      fa_srvr_msg.add_sql_error
           (calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);

      FND_MSG_PUB.count_and_get (
         p_count => x_msg_count,
         p_data  => x_msg_data
      );

      x_return_status := FND_API.G_RET_STS_ERROR;

END update_retirement_desc;


--
FUNCTION initialize_category_df (
         px_asset_cat_rec        IN OUT NOCOPY   FA_API_TYPES.asset_cat_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

l_return_status                BOOLEAN;
l_category_chart_id            number;
l_num_segs                     number;
l_delimiter                    varchar2(1);
l_segment_array                FND_FLEX_EXT.SEGMENTARRAY;
l_concat_string                varchar2(210);

BEGIN

   -- Get defaults from the category.
/*
      if not fa_cache_pkg.fazcat(
         X_cat_id => px_asset_cat_rec.category_id
      , p_log_level_rec => p_log_level_rec) then
         fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_desc_pub.initialize_category_df', p_log_level_rec => p_log_level_rec);
             return FALSE;
      end if;
*/
     if not fa_cache_pkg.fazsys(g_log_level_rec) then
        fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_desc_pub.initialize_category_df',  p_log_level_rec => p_log_level_rec);
             return FALSE;
     end if;

     l_category_chart_id :=
               fa_cache_pkg.fazsys_record.category_flex_structure;

     if not fa_flex_pvt.get_concat_segs (
            p_ccid                   => px_asset_cat_rec.category_id,
            p_application_short_name => 'OFA',
            p_flex_code              => 'CAT#',
            p_flex_num               => l_category_chart_id,
            p_num_segs               => l_num_segs,
            p_delimiter              => l_delimiter,
            p_segment_array          => l_segment_array,
            p_concat_string          => l_concat_string
         , p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message(
             calling_fn => 'fa_asset_desc_pub.initialize_category_df', p_log_level_rec => p_log_level_rec);
             return FALSE;
     end if;

     px_asset_cat_rec.desc_flex.attribute_category_code := l_concat_string;

     -- commenting this for bug 2700227
     --px_asset_cat_rec.desc_flex.context                 := l_concat_string;
/*
     if (px_asset_cat_rec.desc_flex.attribute1 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute1 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute2 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute2 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute3 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute3 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute4 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute4 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute5 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute5 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute6 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute6 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute7 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute7 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute8 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute8 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute9 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute9 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute10 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute10 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute11 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute11 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute12 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute12 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute13 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute13 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute14 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute14 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute15 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute15 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute16 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute16 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute17 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute17 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute18 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute18 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute19 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute19 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute20 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute20 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute21 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute21 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute22 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute22 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute23 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute23 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute24 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute24 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute25 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute25 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute26 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute26 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute27 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute27 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute28 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute28 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute29 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute29 := null;
     end if;
     if (px_asset_cat_rec.desc_flex.attribute30 = FND_API.G_MISS_CHAR) then
        px_asset_cat_rec.desc_flex.attribute30 := null;
     end if;
*/
     return (TRUE);
EXCEPTION

   WHEN OTHERS THEN
        fa_srvr_msg.add_sql_error(calling_fn => 'fa_asset_desc_pub.initialize_category_df', p_log_level_rec => p_log_level_rec);
        return FALSE;

END;

END FA_ASSET_DESC_PUB;

/
