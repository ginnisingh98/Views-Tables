--------------------------------------------------------
--  DDL for Package Body FA_ASSET_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_HIERARCHY_PVT" as
/* $Header: FAVAHRB.pls 120.2.12010000.2 2009/07/19 11:51:32 glchen ship $   */


FUNCTION validate_parent ( p_parent_hierarchy_id in number,
                           p_book_type_code      in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

l_purpose_book varchar2(30);
l_parent_id number;

Cursor C1 IS
       select book_type_code
       from fa_asset_hierarchy_purpose
       where asset_hierarchy_purpose_id =
            ( select asset_hierarchy_purpose_id
              from fa_asset_hierarchy
              where asset_hierarchy_id = p_parent_hierarchy_id
              and level_number = 1);
BEGIN

   open C1;
   fetch C1 into l_purpose_book;
   close C1;

   if l_purpose_book is null then
     fa_srvr_msg.add_message(
                         calling_fn => 'FA_ASSET_HIERARCHY_PVT.validate_parent',
                         name       => 'CUA_INVALID_PARENT' ,  p_log_level_rec => p_log_level_rec);
     return FALSE;
   end if;

   if l_purpose_book <> p_book_type_code then
     fa_srvr_msg.add_message(
                         calling_fn => 'FA_ASSET_HIERARCHY_PVT.validate_parent',
                         name       => 'CUA_INVALID_PARENT_BOOK_TYPE' ,  p_log_level_rec => p_log_level_rec);
     return FALSE;
   end if;

   return TRUE;

END validate_parent;

-----
-----
FUNCTION add_asset(
         -- api parameters
         p_asset_hdr_rec         IN   FA_API_TYPES.asset_hdr_rec_type,
         p_asset_hierarchy_rec   IN   FA_API_TYPES.asset_hierarchy_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

   cursor C_purpose is
     select asset_hierarchy_purpose_id
     from   fa_asset_hierarchy_purpose
     where  book_type_code = p_asset_hdr_rec.book_type_code
     and    purpose_type = 'INHERITANCE';

   l_err_stage varchar2(640);
   l_err_code  varchar2(640);
   l_err_stack varchar2(640);

   l_purpose_id number;
   l_asset_hierarchy_id number;
   l_asset_number 	fa_additions.asset_number%TYPE;
BEGIN

    -- validate the required_parameters
    if ( p_asset_hdr_rec.asset_id is null OR
         p_asset_hierarchy_rec.parent_hierarchy_id is null ) then
         fa_srvr_msg.add_message(
                     calling_fn => 'fa_asset_hierarchy_pvt.add_asset',
                     name       => 'FA_SHARED_ITEM_NULL' ,  p_log_level_rec => p_log_level_rec);
        return FALSE;
    end if;

/*
    -- check the parent is a valid
    if not FA_ASSET_HIERARCHY_PVT.validate_parent(
                                  p_asset_hierarchy_rec.parent_hierarchy_id,
                                  p_asset_hdr_rec.book_type_code , p_log_level_rec => p_log_level_rec) then
       return FALSE;
    end if;
*/
    -- get purpose
    open C_purpose;
    fetch C_purpose into l_purpose_id;
    close c_purpose;

    select asset_number
    into l_asset_number
    from fa_additions
    where asset_id = p_asset_hdr_rec.asset_id;

    -- create node
    fa_cua_hierarchy_pkg.create_node(
                         x_asset_hierarchy_purpose_id=> l_purpose_id,
                         x_asset_hierarchy_id => l_asset_hierarchy_id,
                         x_level_number => 0,
			 x_name => l_asset_number,
                         x_parent_hierarchy_id => p_asset_hierarchy_rec.parent_hierarchy_id,
                         x_asset_id => p_asset_hdr_rec.asset_id,
                         x_err_code => l_err_code,
                         x_err_stage => l_err_stage,
                         x_err_stack => l_err_stack, p_log_level_rec => p_log_level_rec);
      if l_err_code <> '0' then
         fa_srvr_msg.add_message(
                     calling_fn => 'fa_asset_hierarchy_pvt.add_asset',
                     name       => l_err_code ,  p_log_level_rec => p_log_level_rec);
         return FALSE;
      end if;

     return TRUE;
EXCEPTION
  when others then
       rollback;
       fa_srvr_msg.add_sql_error(
                   calling_fn => 'fa_asset_hierarchy_pvt.add_asset',  p_log_level_rec => p_log_level_rec);
       return FALSE;
END;

-----------------------------------

FUNCTION load_distributions(
              p_hr_dist_set_id     IN     number,
              p_asset_units        IN     number,
              px_asset_dist_tbl    IN OUT NOCOPY fa_api_types.asset_dist_tbl_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

i binary_integer := 0;
l_distribution_set_id number;
CURSOR distset_cur is
       select distribution_line_percentage unit_percentage,
       code_combination_id deprn_expense_ccid,
       location_id,
       assigned_to
       from fa_hierarchy_distributions
       where dist_set_id = p_hr_dist_set_id;

  v_assigned_to_number number;
  v_assigned_to_name   varchar2(2000);

BEGIN
    if ( nvl(p_hr_dist_set_id, 0) = 0 ) then
       return TRUE;
    end if;

    px_asset_dist_tbl.delete;

    for dist_rec in distset_cur LOOP
      i:= i+1;
      px_asset_dist_tbl(i).units_assigned := ( p_asset_units * dist_rec.unit_percentage/100 );
      px_asset_dist_tbl(i).assigned_to    := dist_rec.assigned_to;
      px_asset_dist_tbl(i).expense_ccid   := dist_rec.deprn_expense_ccid;
      px_asset_dist_tbl(i).location_ccid  := dist_rec.location_id;

    END LOOP;

    return TRUE;
EXCEPTION
    when others then
       fa_srvr_msg.add_sql_error(
                   calling_fn => 'fa_asset_hierarchy_pvt.load_distributions',  p_log_level_rec => p_log_level_rec);
       return FALSE;


END load_distributions;

-----------------------------------

FUNCTION derive_asset_attribute(
                px_asset_hdr_rec            IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type,
                px_asset_desc_rec           IN OUT NOCOPY  fa_api_types.asset_desc_rec_type,
                px_asset_cat_rec            IN OUT NOCOPY  fa_api_types.asset_cat_rec_type,
                px_asset_hierarchy_rec      IN OUT NOCOPY  fa_api_types.asset_hierarchy_rec_type,
                px_asset_fin_rec            IN OUT NOCOPY  fa_api_types.asset_fin_rec_type,
                px_asset_dist_tbl           IN OUT NOCOPY  fa_api_types.asset_dist_tbl_type,
                p_derivation_type           IN       varchar2  DEFAULT 'ALL',
                p_calling_function          IN       varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  return boolean IS


l_asset_hdr_rec        fa_api_types.asset_hdr_rec_type;
l_asset_desc_rec       fa_api_types.asset_desc_rec_type;
l_asset_cat_rec        fa_api_types.asset_cat_rec_type;
l_asset_hierarchy_rec  fa_api_types.asset_hierarchy_rec_type;
l_asset_fin_rec        fa_api_types.asset_fin_rec_type;
l_asset_dist_tbl       fa_api_types.asset_dist_tbl_type;

l_category_id_out number;
l_cat_OA     varchar2(1);
l_cat_RF     varchar2(1);
l_lease_id_out number;
l_lease_OA     varchar2(1);
l_lease_RF     varchar2(1);
l_dist_set_id_out number;
l_dist_OA     varchar2(1);
l_dist_RF     varchar2(1);
l_serial_num_out   varchar2(30);
l_serial_num_OA     varchar2(1);
l_serial_num_RF     varchar2(1);
l_asset_key_out    number;
l_asset_key_OA     varchar2(1);
l_asset_key_RF     varchar2(1);
l_life_out    number;
l_life_OA     varchar2(1);
l_life_RF     varchar2(1);
l_err_code     varchar2(640);
l_err_stage     varchar2(640);
l_err_stack     varchar2(640);
l_inherit_flag  varchar2(5):= null;
l_parent_deprn_start_date  date;

daa_error EXCEPTION;
rej_error EXCEPTION;
inherit_error EXCEPTION;

BEGIN

/**
    if x_calling_function = 'MASS_ADDITIONS' then
      -- validate the prorate_date passed in
      SELECT cua_inheritance_flag
      INTO l_inherit_flag
      FROM fa_system_controls;


      select depreciation_start_date
      into l_parent_deprn_start_date
      from fa_asset_hierarchy
      where asset_hierarchy_id = p_asset_hr_rec.parent_hierarchy_id;

      if l_inherit_flag <> 'Y' AND
         to_date(p_asset_hr_attr_rec_in.prorate_date,'DD/MM/YYYY') >
                     nvl(parent_deprn_start_date,
                         to_date(p_asset_hr_attr_rec_in.prorate_date,'DD/MM/YYYY') - 1) then

         raise inherit_error;
      end if;
    end if;
**/

    -- check if the parent is valid
    if not validate_parent(
                    px_asset_hierarchy_rec.parent_hierarchy_id,
                    px_asset_hdr_rec.book_type_code,
                    p_log_level_rec ) then
       return FALSE;
    end if;

    -- derive the new attributes for the asset
    FA_CUA_ASSET_APIS.derive_asset_attribute(
       x_book_type_code               => px_asset_hdr_rec.book_type_code
     , x_parent_node_id               => px_asset_hierarchy_rec.parent_hierarchy_id
     , x_asset_number                 => NULL
     , x_asset_id                     => px_asset_hdr_rec.asset_id
     , x_prorate_date                 => null --p_asset_hr_attr_rec_in.prorate_date
     , x_cat_id_in                    => px_asset_cat_rec.category_id
     , x_cat_id_out                   => l_category_id_out
     , x_cat_overide_allowed          => l_cat_OA
     , x_cat_rejection_flag           => l_cat_RF
     , x_lease_id_in                  => l_asset_desc_rec.lease_id
     , x_lease_id_out                 => l_lease_id_out
     , x_lease_overide_allowed        => l_lease_OA
     , x_lease_rejection_flag         => l_lease_RF
     , x_distribution_set_id_in       => NULL
     , x_distribution_set_id_out      => l_dist_set_id_out
     , x_distribution_overide_allowed => l_dist_OA
     , x_distribution_rejection_flag  => l_dist_RF
     , x_serial_number_in             => px_asset_desc_rec.serial_number
     , x_serial_number_out            => l_serial_num_out
     , x_serial_num_overide_allowed   => l_serial_num_OA
     , x_serial_num_rejection_flag    => l_serial_num_RF
     , x_asset_key_ccid_in            => px_asset_desc_rec.asset_key_ccid
     , x_asset_key_ccid_out           => l_asset_key_out
     , x_asset_key_overide_allowed    => l_asset_key_OA
     , x_asset_key_rejection_flag     => l_asset_key_RF
     , x_life_in_months_in            => px_asset_fin_rec.life_in_months
     , x_life_in_months_out           => l_life_out
     , x_life_end_dte_overide_allowed => l_life_OA
     , x_life_rejection_flag          => l_life_RF
     , x_err_code                     => l_err_code
     , x_err_stage                    => l_err_stage
     , x_err_stack                    => l_err_stack
     , x_derivation_type              => p_derivation_type
     , p_log_level_rec                => p_log_level_rec );

     if l_err_code <> '0' then
        raise daa_error;
     end if;

     if ( l_cat_RF = 'Y'        OR
          l_lease_RF = 'Y'      OR
          l_dist_RF = 'Y'       OR
          l_serial_num_RF = 'Y' OR
          l_asset_key_RF = 'Y'  OR
          l_life_RF = 'Y' ) then

        raise rej_error;
     end if;

     -- for addition simply derive the new dist details
     if l_dist_set_id_out is not null then
       if not load_distributions(
                 p_hr_dist_set_id     => l_dist_set_id_out,
                 p_asset_units        => px_asset_desc_rec.current_units,
                 px_asset_dist_tbl    => px_asset_dist_tbl,
                 p_log_level_rec      => p_log_level_rec ) then
          return FALSE;
       end if;
     end if;


     return TRUE;

EXCEPTION
    when inherit_error then
       fa_srvr_msg.add_message(
                      calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                      name       => 'CUA_MAP_DATES',  p_log_level_rec => p_log_level_rec);
            return FALSE;

    when daa_error then
      fa_srvr_msg.add_message(
                      calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                      name       => l_err_code ,  p_log_level_rec => p_log_level_rec);
            return FALSE;

    when rej_error then
        if l_cat_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_CAT_ID' ,  p_log_level_rec => p_log_level_rec);
        end if;

        if l_lease_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_LEASE_ID' ,  p_log_level_rec => p_log_level_rec);
        end if;

        if l_serial_num_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_SERIAL_NUMBER' ,  p_log_level_rec => p_log_level_rec);
        end if;

        if l_asset_key_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_ASSET_KEY_CCID' ,  p_log_level_rec => p_log_level_rec);
        end if;

        if l_dist_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_DISTRIBUTION' ,  p_log_level_rec => p_log_level_rec);
        end if;

        if l_life_RF = 'Y' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.derive_asset_attribute',
                       name       => 'CUA_MAP_LIFE_IN_MONTHS' ,  p_log_level_rec => p_log_level_rec);
        end if;


        return FALSE;

    when others then
      FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => 'fa_asset_hierarchy_pvt.derive_asset_attribute' ,  p_log_level_rec => p_log_level_rec);
      RETURN (FALSE);

END derive_asset_attribute;


FUNCTION create_batch(
         p_asset_hdr_rec         IN   FA_API_TYPES.asset_hdr_rec_type,
         p_trans_rec             IN   FA_API_TYPES.trans_rec_type,
         p_asset_hr_opt_rec      IN   FA_API_TYPES.asset_hr_options_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

l_err_code varchar2(600):= '0';
l_err_stack varchar2(600);
l_err_stage varchar2(600);
l_batch_num varchar2(15);
l_batch_id  number;
l_request_num  number;

BEGIN

        fa_cua_derive_asset_attr_pkg.insert_mass_update_batch_hdrs(
          x_event_code               => p_asset_hr_opt_rec.event_code
        , x_book_type_code           => p_asset_hdr_rec.book_type_code
        , x_status_code              => p_asset_hr_opt_rec.status_code
        , x_source_entity_name       => p_asset_hr_opt_rec.source_entity_name
        , x_source_entity_key_value  => p_asset_hr_opt_rec.source_entity_value
        , x_source_attribute_name    => p_asset_hr_opt_rec.source_attribute_name
        , x_source_attribute_old_id  => p_asset_hr_opt_rec.source_attribute_old_id
        , x_source_attribute_new_id  => p_asset_hr_opt_rec.source_attribute_new_id
        , x_description              => p_asset_hr_opt_rec.description
        , x_amortize_flag            => p_asset_hr_opt_rec.amortize_flag
        , x_amortization_date        => p_asset_hr_opt_rec.amortization_start_date
        , x_rejection_reason_code    => p_asset_hr_opt_rec.rejection_reason_code
        , x_concurrent_request_id    => p_asset_hr_opt_rec.concurrent_request_id
        , x_created_by               => p_trans_rec.who_info.created_by
        , x_creation_date            => p_trans_rec.who_info.creation_date
        , x_last_updated_by          => p_trans_rec.who_info.last_updated_by
        , x_last_update_date         => p_trans_rec.who_info.last_update_date
        , x_last_update_login        => p_trans_rec.who_info.last_update_login
        , x_batch_number             => l_batch_num
        , x_batch_id                 => l_batch_id
        , x_transaction_name         => p_trans_rec.transaction_name
        , x_attribute_category       => p_trans_rec.desc_flex.attribute_category_code
        , x_attribute1               => p_trans_rec.desc_flex.attribute1
        , x_attribute2               => p_trans_rec.desc_flex.attribute2
        , x_attribute3               => p_trans_rec.desc_flex.attribute3
        , x_attribute4               => p_trans_rec.desc_flex.attribute4
        , x_attribute5               => p_trans_rec.desc_flex.attribute5
        , x_attribute6               => p_trans_rec.desc_flex.attribute6
        , x_attribute7               => p_trans_rec.desc_flex.attribute7
        , x_attribute8               => p_trans_rec.desc_flex.attribute8
        , x_attribute9               => p_trans_rec.desc_flex.attribute9
        , x_attribute10              => p_trans_rec.desc_flex.attribute10
        , x_attribute11              => p_trans_rec.desc_flex.attribute11
        , x_attribute12              => p_trans_rec.desc_flex.attribute12
        , x_attribute13              => p_trans_rec.desc_flex.attribute13
        , x_attribute14              => p_trans_rec.desc_flex.attribute14
        , x_attribute15              => p_trans_rec.desc_flex.attribute15
        , x_err_code                 => l_err_code
        , x_err_stage                => l_err_stage
        , x_err_stack                => l_err_stack , p_log_level_rec => p_log_level_rec);


        if l_err_code <> '0' then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.create_batch',
                       name       => 'CUA_BATCH_ERRORED',  p_log_level_rec => p_log_level_rec);
           return FALSE;
        end if;


        l_request_num := FND_REQUEST.SUBMIT_REQUEST('CUA','FACCBTXN',null,null,FALSE,
                                     to_char(l_batch_id),chr(0),'','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','',
                                     '','','','','','','','','','');

        if(l_request_num = 0) then
           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.create_batch.submit_request',  p_log_level_rec => p_log_level_rec);
           return FALSE;
        else
           Update fa_mass_update_batch_headers
           set    status_code = 'IP'
                , concurrent_request_id = l_request_num
           where batch_id = l_batch_id;

           fa_srvr_msg.add_message(
                       calling_fn => 'fa_asset_hierarchy_pvt.create_batch',
                       name       => 'CUA_BATCH_SUBMITTED',
                       token1     => 'Request_id',
                       value1     => to_char(l_request_num),
                       token2     =>  'Batch_no',
                       value2     => to_char(l_batch_id) ,
                   p_log_level_rec => p_log_level_rec);

        end if;

        return TRUE;


END create_batch;


END FA_ASSET_HIERARCHY_PVT;

/
