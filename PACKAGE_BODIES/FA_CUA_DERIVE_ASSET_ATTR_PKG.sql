--------------------------------------------------------
--  DDL for Package Body FA_CUA_DERIVE_ASSET_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_DERIVE_ASSET_ATTR_PKG" AS
 /* $Header: FACDAAMB.pls 120.1.12010000.3 2009/08/20 14:17:04 bridgway ship $ */

  PROCEDURE insert_mass_update_batch_hdrs(
             x_event_code                 IN     VARCHAR2
           , x_book_type_code             IN     VARCHAR2
           , x_status_code                IN     VARCHAR2 DEFAULT NULL
           , x_source_entity_name         IN     VARCHAR2
           , x_source_entity_key_value    IN     VARCHAR2
           , x_source_attribute_name      IN     VARCHAR2
           , x_source_attribute_old_id    IN     VARCHAR2
           , x_source_attribute_new_id    IN     VARCHAR2
           , x_description                IN     VARCHAR2 DEFAULT NULL
           , x_amortize_flag              IN     VARCHAR2
           , x_amortization_date          IN     DATE
           , x_rejection_reason_code      IN     VARCHAR2 DEFAULT NULL
           , x_concurrent_request_id      IN     NUMBER   DEFAULT NULL
           , x_created_by                 IN     NUMBER   DEFAULT NULL
           , x_creation_date              IN     DATE     DEFAULT NULL
           , x_last_updated_by            IN     NUMBER   DEFAULT NULL
           , x_last_update_date           IN     DATE     DEFAULT NULL
           , x_last_update_login          IN     NUMBER   DEFAULT NULL
           , x_batch_number               IN OUT NOCOPY VARCHAR2
           , x_batch_id                   IN OUT NOCOPY NUMBER
           , x_transaction_name           IN     VARCHAR2 DEFAULT NULL
           , x_attribute_category         IN     VARCHAR2 DEFAULT NULL
           , x_attribute1                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute2                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute3                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute4                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute5                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute6                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute7                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute8                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute9                 IN     VARCHAR2 DEFAULT NULL
           , x_attribute10                IN     VARCHAR2 DEFAULT NULL
           , x_attribute11                IN     VARCHAR2 DEFAULT NULL
           , x_attribute12                IN     VARCHAR2 DEFAULT NULL
           , x_attribute13                IN     VARCHAR2 DEFAULT NULL
           , x_attribute14                IN     VARCHAR2 DEFAULT NULL
           , x_attribute15                IN     VARCHAR2 DEFAULT NULL
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS

  cursor C1 is
    select 1
    from dual
    where  exists ( select 'X'
                      from fa_book_controls
                      where book_type_code = x_book_type_code
                      and book_class = 'CORPORATE' );

  v_old_err_stack VARCHAR2(630);
  v_dummy NUMBER := 0;
  v_created_by NUMBER;
  v_last_update_login NUMBER;
  v_sysdate DATE;

  BEGIN
    x_err_code:= '0';
    v_old_err_stack := substr(x_err_stack, 1, 600 );
    x_err_stack:= substr(x_err_stack, 1, 600)||'insert_mass_update_batch_hdrs';

    x_err_stage:= 'Assigning fa_cua_asset_apis.G_multi_books_flg';
    if nvl(fa_cua_asset_apis.G_multi_books_flg, 'N') = 'Y' then
      -- insert header info only for the corporate book
      OPEN C1;
      FETCH C1 into v_dummy;
      CLOSE C1;

      if v_dummy = 0 then
        return;
      end if;
    end if;

    x_err_stage:= 'fa_mass_update_batch_hdrs_s.nextval';

    select fa_mass_update_batch_hdrs_s.nextval
    into x_batch_id
    from dual;

    x_batch_number:= to_char(x_batch_id);
    v_sysdate:= sysdate;

    x_err_stage:= 'getting value for user_id';

    if x_created_by is null or x_last_updated_by is null then
      v_created_by:= nvl(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
    else
      v_created_by := x_created_by;
    end if;

    x_err_stage:= 'getting value for login_id';

    if x_last_update_login is null then
       v_last_update_login:= nvl(TO_NUMBER(fnd_profile.value('LOGIN_ID')),-1);
    else
       v_last_update_login := x_last_update_login;
    end if;

    x_err_stage:= 'Inserting fa_mass_update_batch_headers';

    INSERT INTO fa_mass_update_batch_headers(
             event_code
           , book_type_code
           , status_code
           , source_entity_name
           , source_entity_key_value
           , source_attribute_name
           , source_attribute_old_id
           , source_attribute_new_id
           , description
           , amortize_flag
           , amortization_date
           , rejection_reason_code
           , concurrent_request_id
           , created_by
           , creation_date
           , last_updated_by
           , last_update_date
           , last_update_login
           , batch_number
           , batch_id
           , transaction_name
           , attribute_category
           , attribute1
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15 )
    VALUES (
             x_event_code
           , x_book_type_code
           , x_status_code
           , x_source_entity_name
           , x_source_entity_key_value
           , x_source_attribute_name
           , x_source_attribute_old_id
           , x_source_attribute_new_id
           , x_description
           , x_amortize_flag
           , x_amortization_date
           , x_rejection_reason_code
           , x_concurrent_request_id
           , v_created_by         -- x_created_by
           , v_sysdate            -- x_creation_date
           , v_created_by         -- x_last_updated_by
           , v_sysdate            -- x_last_update_date
           , v_last_update_login  -- x_last_update_login
           , x_batch_number
           , x_batch_id
           , x_transaction_name
           , x_attribute_category
           , x_attribute1
           , x_attribute2
           , x_attribute3
           , x_attribute4
           , x_attribute5
           , x_attribute6
           , x_attribute7
           , x_attribute8
           , x_attribute9
           , x_attribute10
           , x_attribute11
           , x_attribute12
           , x_attribute13
           , x_attribute14
           , x_attribute15 );

      x_err_stack:= v_old_err_stack;
    EXCEPTION
      WHEN OTHERS THEN
      x_err_code:= substr(sqlerrm, 1, 600);
      return;
    END insert_mass_update_batch_hdrs;


   PROCEDURE insert_mass_update_batch_dtls (
             x_batch_id                   IN     NUMBER
           , x_book_type_code             IN     VARCHAR2
           , x_attribute_name             IN     VARCHAR2
           , x_asset_id                   IN     NUMBER
           , x_attribute_old_value        IN     VARCHAR2
           , x_attribute_new_value        IN     VARCHAR2
           , x_derived_from_entity        IN     VARCHAR2
           , x_derived_from_entity_id     IN     NUMBER
           , x_parent_hierarchy_id        IN     NUMBER
           , x_status_code                IN     VARCHAR2
           , x_rejection_reason           IN     VARCHAR2
           , x_apply_flag                 IN     VARCHAR2
           , x_effective_date             IN     DATE
           , x_fa_period_name             IN     VARCHAR2
           , x_concurrent_request_id      IN     NUMBER
           , x_created_by                 IN     NUMBER
           , x_creation_date              IN     DATE
           , x_last_updated_by            IN     NUMBER
           , x_last_update_date           IN     DATE
           , x_last_update_login          IN     NUMBER
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS

     v_old_err_stack VARCHAR2(630);
     BEGIN
     x_err_code:= '0';
     v_old_err_stack := x_err_stack;
     x_err_stack:= x_err_stack||'Inserting fa_mass_update_batch_details';
     insert into fa_mass_update_batch_details (
       batch_id
     , book_type_code
     , attribute_name
     , asset_id
     , attribute_old_id
     , attribute_new_id
     , derived_from_entity
     , derived_from_entity_id
     , parent_hierarchy_id
     , status_code
     , rejection_reason
     , apply_flag
     , effective_date
     , fa_period_name
     , concurrent_request_id
     , created_by
     , creation_date
     , last_updated_by
     , last_update_date
     , last_update_login )
     values (
        x_batch_id
      , x_book_type_code
      , x_attribute_name
      , x_asset_id
      , x_attribute_old_value
      , x_attribute_new_value
      , x_derived_from_entity
      , x_derived_from_entity_id
      , x_parent_hierarchy_id
      , x_status_code
      , x_rejection_reason
      , x_apply_flag
      , x_effective_date
      , x_fa_period_name
      , x_concurrent_request_id
      , x_created_by
      , x_creation_date
      , x_last_updated_by
      , x_last_update_date
      , x_last_update_login );

     x_err_stack := v_old_err_stack;
   EXCEPTION
     WHEN OTHERS THEN
      x_err_code:= substr(sqlerrm, 1, 600);
      -- x_err_code := sqlerrm;
     return;
   END insert_mass_update_batch_dtls;


   PROCEDURE select_assets( x_event_code       IN VARCHAR2
                          , x_book_type_code   IN VARCHAR2
                          , x_book_class       IN VARCHAR2
                          , x_src_entity_value IN VARCHAR2
                          , x_parent_id_new    IN NUMBER
                          , x_asset_array      OUT NOCOPY asset_tabtype
                          , x_err_code         IN OUT NOCOPY VARCHAR2
                          , x_err_stage        IN OUT NOCOPY VARCHAR2
                          , x_err_stack        IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null)IS
    v_node_id       number;
    i                binary_integer :=0;
    i2               binary_integer :=0;
    v_old_err_stack varchar2(630);

    CURSOR C_node_assets IS
      select asset_id
           , asset_hierarchy_id
           , asset_hierarchy_purpose_id
           , hierarchy_rule_set_id
           , parent_hierarchy_id
           , depreciation_start_date
      from fa_asset_hierarchy
      where asset_id is not null
      and   level_number = 0
      start with asset_hierarchy_id = to_number(x_src_entity_value)
      connect by prior asset_hierarchy_id = parent_hierarchy_id;

   CURSOR C_asset_attr( p_asset_id IN NUMBER) IS
     select fa.asset_id
          , fa.asset_number
          , fa.asset_key_ccid
          , fa.asset_category_id
          , fa.serial_number
          , fa.lease_id
          , fb.life_in_months
          , fb.book_type_code
          , iah.parent_hierarchy_id
          , iah.hierarchy_rule_Set_id
     from fa_additions fa
        , fa_books fb
        , fa_asset_hierarchy iah
     where fa.asset_id = p_asset_id
     and   fa.asset_id = fb.asset_id
     and   fb.book_type_code = x_book_type_code
     and   fb.date_ineffective is null
     and   nvl(fb.period_counter_fully_retired,0) = 0
     and   fb.asset_id = iah.asset_id
     and   iah.level_number = 0;

    CURSOR C_ctgry_assets IS
      select iah.asset_id
           , iah.asset_hierarchy_id
           , iah.asset_hierarchy_purpose_id
           , iah.hierarchy_rule_set_id
           , iah.depreciation_start_date
           , iah.parent_hierarchy_id
           , fa.asset_number
           , fa.asset_key_ccid
           , fa.asset_category_id
           , fa.serial_number
           , fa.lease_id
           , fb.life_in_months
           , fb.book_type_code
     from fa_additions fa
        , fa_books fb
        , fa_asset_hierarchy iah
     where fa.asset_category_id = to_number(x_src_entity_value)
     and   fa.asset_id = fb.asset_id
     and   fb.book_type_code = x_book_type_code
     and   fb.date_ineffective is null
     and   nvl(fb.period_counter_fully_retired,0) = 0
     and   fb.asset_id = iah.asset_id
     and   iah.level_number = 0;

    CURSOR C_lease_assets IS
      select iah.asset_id
           , iah.asset_hierarchy_id
           , iah.asset_hierarchy_purpose_id
           , iah.hierarchy_rule_set_id
           , iah.depreciation_start_date
           , iah.parent_hierarchy_id
           , fa.asset_number
           , fa.asset_key_ccid
           , fa.asset_category_id
           , fa.serial_number
           , fa.lease_id
           , fb.life_in_months
           , fb.book_type_code
      from fa_additions fa
         , fa_books  fb
         , fa_asset_hierarchy iah
     where fa.lease_id = to_number(x_src_entity_value)
     and   fa.asset_id = fb.asset_id
     and   fb.date_ineffective is null
     and   fb.book_type_code = x_book_type_code
     and   nvl(fb.period_counter_fully_retired,0) = 0
     and   fb.asset_id = iah.asset_id
     and   iah.level_number = 0;

CURSOR C_get_attr IS
     select fa.asset_id
          , fa.asset_number
          , fa.asset_key_ccid
          , fa.asset_category_id
          , fa.serial_number
          , fa.lease_id
          , fb.life_in_months
          , fb.book_type_code
          , iah.parent_hierarchy_id
          , iah.hierarchy_rule_Set_id
     from fa_additions fa
        , fa_books  fb
        , fa_asset_hierarchy iah
     where fa.asset_id = to_number(x_src_entity_value)
     and   fa.asset_id = fb.asset_id
     and   fb.date_ineffective is null
     and   fb.book_type_code = x_book_type_code
     and   nvl(fb.period_counter_fully_retired,0) = 0
     and   fb.asset_id = iah.asset_id
     and   iah.level_number = 0;

  BEGIN
     x_err_code := 0;
     v_old_err_stack:= x_err_stack;
     x_err_stack := x_err_stack||'select_assets';

     if (x_event_code = 'CHANGE_NODE_PARENT' OR
           x_event_code = 'CHANGE_NODE_ATTRIBUTE' OR
             x_event_code = 'CHANGE_NODE_RULE_SET' ) then
       x_err_stage:= x_event_code;
       -- find all assets below the node passed as x_src_entity_value
       for assets_rec in C_node_assets LOOP
         -- for each identified asset get the attribute values
         -- and store as a record in the passed in asset_array table
         -- should fetch only one record for each asset
         for assets_attr_rec in C_asset_attr( assets_rec.asset_id) LOOP
           i:= i+1;
           x_asset_array(i).parent_hierarchy_id:= assets_rec.parent_hierarchy_id;
           x_asset_array(i).rule_set_id := assets_rec.hierarchy_rule_set_id;
           x_asset_array(i).asset_id := assets_attr_rec.asset_id;
           x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
           x_asset_array(i).lease_id := assets_attr_rec.lease_id;
           x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
           x_asset_array(i).serial_number := assets_attr_rec.serial_number;
           x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
         end loop;
       end loop;
     elsif (x_event_code = 'CHANGE_CATEGORY_RULE_SET' OR
              x_event_code = 'CHANGE_CATEGORY_LIFE' OR
                x_event_code = 'CHANGE_CATEGORY_LIFE_END_DATE' ) then
       x_err_stage:= x_event_code;
       -- fetch all the assets and their attributes, which are tied
       -- to the passed-in asset category and store it in asset_array table
       for assets_attr_rec in C_ctgry_assets LOOP
         i := i+1;
         x_asset_array(i).parent_hierarchy_id:= assets_attr_rec.parent_hierarchy_id;
         x_asset_array(i).rule_set_id := assets_attr_rec.hierarchy_rule_set_id;
         x_asset_array(i).asset_id := assets_attr_rec.asset_id;
         x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
         x_asset_array(i).lease_id := assets_attr_rec.lease_id;
         x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
         x_asset_array(i).serial_number := assets_attr_rec.serial_number;
         x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
       end loop;
     elsif (x_event_code = 'CHANGE_LEASE_LIFE_END_DATE') then
       x_err_stage := x_event_code;
       -- fetch all the assets and their attributes, which are tied
       -- to the passed-in lease_id and store it in asset_array table
       for assets_attr_rec in c_lease_assets LOOP
         i := i+1;
         x_asset_array(i).parent_hierarchy_id:= assets_attr_rec.parent_hierarchy_id;
         x_asset_array(i).rule_set_id := assets_attr_rec.hierarchy_rule_set_id;
         x_asset_array(i).asset_id := assets_attr_rec.asset_id;
         x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
         x_asset_array(i).lease_id := assets_attr_rec.lease_id;
         x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
         x_asset_array(i).serial_number := assets_attr_rec.serial_number;
         x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
       end loop;
     elsif (x_event_code = 'CHANGE_ASSET_PARENT' OR
             x_event_code = 'CHANGE_ASSET_LEASE' OR
              x_event_code = 'CHANGE_ASSET_CATEGORY' ) then
       for assets_attr_rec in c_asset_attr( to_number(x_src_entity_value) ) LOOP
           i := i+1;
           x_asset_array(i).parent_hierarchy_id:= assets_attr_rec.parent_hierarchy_id;
           x_asset_array(i).rule_set_id := assets_attr_rec.hierarchy_rule_Set_id;
           x_asset_array(i).asset_id := assets_attr_rec.asset_id;
           x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
           x_asset_array(i).lease_id := assets_attr_rec.lease_id;
           x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
           x_asset_array(i).serial_number := assets_attr_rec.serial_number;
           x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
         end loop;
     elsif (x_event_code = 'HR_MASS_TRANSFER' ) then
       x_err_stage:= x_event_code;
       if x_book_class = 'CORPORATE' then
       i:= 0;
         for assets_rec in c_node_assets LOOP
           -- store the old_parent_id
           -- for each identified asset get the attribute values
           -- and store as a record in the passed in asset_array table
           -- should fetch only one record for each asset
           for assets_attr_rec in C_asset_attr( assets_rec.asset_id) LOOP
             i:= i+1;
             x_asset_array(i).parent_hierarchy_id:= x_parent_id_new;
             x_asset_array(i).parent_hierarchy_id_old:= assets_rec.parent_hierarchy_id;
             x_asset_array(i).rule_set_id := assets_rec.hierarchy_rule_set_id;
             x_asset_array(i).asset_id := assets_attr_rec.asset_id;
             x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
             x_asset_array(i).lease_id := assets_attr_rec.lease_id;
             x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
             x_asset_array(i).serial_number := assets_attr_rec.serial_number;
             x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
            -- save assets to be used by tax books, if any
             fa_cua_asset_apis.g_asset_array(i).asset_id:= assets_attr_rec.asset_id;
             fa_cua_asset_apis.g_asset_array(i).rule_set_id:= assets_attr_rec.asset_id;
             fa_cua_asset_apis.g_asset_array(i).parent_hierarchy_id_old:= assets_rec.parent_hierarchy_id;
           end loop;
           -- update the asset_parent with the new parent_id
           update fa_asset_hierarchy
           set parent_hierarchy_id = x_parent_id_new
           where asset_id = assets_rec.asset_id;
         end loop;
       elsif x_book_class = 'TAX' then
       i:=0;
         for j in 1..fa_cua_asset_apis.g_asset_array.count LOOP
            for assets_attr_rec in C_asset_attr( fa_cua_asset_apis.g_asset_array(j).asset_id) LOOP
              i:=i+1;
             x_asset_array(i).parent_hierarchy_id:= x_parent_id_new;
             x_asset_array(i).parent_hierarchy_id_old:= fa_cua_asset_apis.g_asset_array(j).parent_hierarchy_id;
             x_asset_array(i).rule_set_id := fa_cua_asset_apis.g_asset_array(j).rule_set_id;
             x_asset_array(i).asset_id := assets_attr_rec.asset_id;
             x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
             x_asset_array(i).lease_id := assets_attr_rec.lease_id;
             x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
             x_asset_array(i).serial_number := assets_attr_rec.serial_number;
             x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
           end loop;
         end loop;
       end if; -- book_class
       elsif (x_event_code = 'HR_REINSTATEMENT') then
         -- for reinstatement derive only if fully retired
       for assets_attr_rec in c_get_attr LOOP
           i := i+1;
           x_asset_array(i).parent_hierarchy_id:= assets_attr_rec.parent_hierarchy_id;
           x_asset_array(i).rule_set_id := assets_attr_rec.hierarchy_rule_Set_id;
           x_asset_array(i).asset_id := assets_attr_rec.asset_id;
           x_asset_array(i).asset_category_id := assets_attr_rec.asset_category_id;
           x_asset_array(i).lease_id := assets_attr_rec.lease_id;
           x_asset_array(i).asset_key_ccid := assets_attr_rec.asset_key_ccid;
           x_asset_array(i).serial_number := assets_attr_rec.serial_number;
           x_asset_array(i).life_in_months := assets_attr_rec.life_in_months;
       end loop;
     end if;   -- x_event_code
     x_err_stack:= v_old_err_stack;
   EXCEPTION
     WHEN others THEN
       x_err_code:= substr(sqlerrm, 1, 600);
      -- x_err_code := sqlerrm ;
       return;
   END;

END FA_CUA_DERIVE_ASSET_ATTR_PKG;

/
