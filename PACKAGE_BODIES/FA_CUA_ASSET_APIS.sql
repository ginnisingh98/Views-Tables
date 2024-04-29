--------------------------------------------------------
--  DDL for Package Body FA_CUA_ASSET_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_ASSET_APIS" AS
/* $Header: FACXAPIMB.pls 120.1.12010000.3 2009/08/20 14:20:04 bridgway ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

-- -------------------------------------------------------

PROCEDURE derive_rule( x_book_type_code IN     VARCHAR2
                     , x_parent_node_id IN     NUMBER
                     , x_asset_id       IN     NUMBER
                     , x_cat_id_in      IN     NUMBER
                     , x_rule_set_id       OUT NOCOPY NUMBER
                     , x_err_code       IN OUT NOCOPY VARCHAR2
                     , x_err_stage      IN OUT NOCOPY VARCHAR2
                     , x_err_stack      IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

-- should fetch one row of purpose_id
CURSOR C_purpose IS
  select a.default_rule_set_id
       , a.rule_set_level
  from fa_asset_hierarchy_purpose a
     , fa_asset_hierarchy b
  where a.asset_hierarchy_purpose_id = b.asset_hierarchy_purpose_id
  and   b.asset_hierarchy_id = x_parent_node_id
  and   a.book_type_code = x_book_type_code ;

CURSOR C_get_rule( p_rule_set_level VARCHAR2 ) IS
  select cua_rule_set_id
  from fa_category_book_defaults
  where category_id = x_cat_id_in
  and   book_type_code = x_book_type_code
  and p_rule_set_level = 'ASSET_CATEGORY'
  UNION
  select a.hierarchy_rule_set_id
  from fa_asset_hierarchy a
     , fa_asset_hierarchy_purpose b
  where a.asset_hierarchy_purpose_id = b.asset_hierarchy_purpose_id
  and   a.asset_hierarchy_id = x_parent_node_id
  and   b.book_type_code = x_book_type_code
  and p_rule_set_level = 'TOP_NODE'
  UNION
  select a.hierarchy_rule_set_id
  from  ( select hierarchy_rule_set_id, asset_hierarchy_purpose_id
          from fa_asset_hierarchy
          where parent_hierarchy_id IS NULL
          start with asset_hierarchy_id = x_parent_node_id
          connect by prior asset_hierarchy_id = parent_hierarchy_id ) a
      , fa_asset_hierarchy_purpose b
  where a.asset_hierarchy_purpose_id = b.asset_hierarchy_purpose_id
  and   b.book_type_code = x_book_type_code
  and p_rule_set_level = 'LOWEST_NODE';

  v_old_err_stack   VARCHAR2(630);
  v_purpose_rec     c_purpose%ROWTYPE;
BEGIN
  -- initialize variables
  x_err_code := '0';
  v_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'derive_rule';
  x_rule_set_id := null;

  -- get the purpose_id to determine the rule_set
  x_err_stage:= ' c_purpose';
  open c_purpose;
  fetch c_purpose into v_purpose_rec;
  close c_purpose;

  x_err_stage := 'C_get_rule';
  open C_get_rule(v_purpose_rec.rule_set_level);
  fetch C_get_rule into x_rule_set_id;
  close C_get_rule;

  -- if no rule is found at any of the above three levels
  -- use the default rule
  if(x_rule_set_id IS NULL) then
     x_rule_set_id := v_purpose_rec.default_rule_set_id;
  end if;

  x_err_stack:= v_old_err_stack;
EXCEPTION
  when others then
  -- x_err_code := sqlerrm;
  x_err_code := substr(sqlerrm, 1, 240);
  return;
END derive_rule;


-- ----------------------------------------------------------------
--
-- ----------------------------------------------------------------
PROCEDURE derive_LED_for_ALL( x_book_type_code    IN VARCHAR2
                            , x_asset_id          IN NUMBER
                            , x_parent_node_id    IN NUMBER
                            , x_top_node_id       IN NUMBER
                            , x_asset_cat_id      IN NUMBER
                            , x_node_category_id  IN NUMBER
                            , x_asset_lease_id    IN NUMBER
                            , x_node_lease_id     IN NUMBER
                            , x_prorate_date      IN DATE
                            , x_convention_code   IN VARCHAR2
                            , x_deprn_method_code IN VARCHAR2
                            , x_rule_det_rec      IN fa_hierarchy_rule_details%ROWTYPE
                            , x_life_out        OUT NOCOPY NUMBER
                            , x_err_code     IN OUT NOCOPY VARCHAR2
                            , x_err_stage    IN OUT NOCOPY VARCHAR2
                            , x_err_stack    IN OUT NOCOPY VARCHAR2
,p_log_level_rec       IN     fa_api_types.log_level_rec_type default null) IS

v_led NUMBER;
v_led_min NUMBER:= 5373484;
v_led_max NUMBER:= 1;
v_count NUMBER :=0;
i BINARY_INTEGER:=0;
v_old_err_stack varchar2(630);
v_deprn_date DATE;
v_prorated_depr_date DATE;
v_dummy    varchar2(1);
v_life_end_date date;

Cursor check_tax_record_exists (c_asset_hierarchy_id number) is
select life_end_date
from fa_asset_hierarchy_values
where book_type_code = x_book_type_code
and asset_hierarchy_id = c_asset_hierarchy_id ;

CURSOR C_get_lifes IS
select a.asset_hierarchy_id src_id
    , 'NODE' src_type
    , b.level_number hierarchy_level
    , a.book_type_code book_type_code
    , a.life_end_date life_end_date
    , 0 life_in_months
    , bc.book_class book_class
from fa_asset_hierarchy_values a,
     fa_asset_hierarchy b,
     fa_book_controls bc
where a.asset_hierarchy_id = b.asset_hierarchy_id
and   bc.book_type_code = a.book_type_code
and   a.book_type_code in (x_book_type_code,g_corporate_book)
and   b.asset_hierarchy_id in (select x_top_node_id
                               from dual
                               where nvl(x_rule_det_rec.include_level, 'ALL') = 'TOP'
                                     union
                               select x_parent_node_id
                               from dual
                               where nvl(x_rule_det_rec.include_level, 'ALL') = 'LOWEST'
                                     union
                               select d.asset_hierarchy_id
                               from fa_asset_hierarchy d
                               where nvl(x_rule_det_rec.include_level, 'ALL') = 'ALL'
                               start with d.asset_hierarchy_id = x_parent_node_id
                               connect by d.asset_hierarchy_id =  prior d.parent_hierarchy_id
                              )
and not exists (select 'X'
                  from   fa_exclude_hierarchy_levels c
                  where c.attribute_name = 'LIFE_END_DATE'
                  and   c.book_type_code= x_book_type_code
                  and   c.hierarchy_rule_set_id = x_rule_det_rec.hierarchy_rule_set_id
                  and   b.level_number = c.level_number
                 )
and nvl(x_rule_det_rec.include_hierarchy_flag,'N') = 'Y'
	 UNION ALL
--
 select asset_id src_id
    , 'ASSET' src_type
    , 0 hierarchy_level
    , book_type_code
    , add_months(prorate_date, life_in_months) life_end_date
    , life_in_months
    , 'CORPORATE' book_class
  from fa_books
  where asset_id = x_asset_id
  and date_ineffective IS NULL
  and nvl(x_rule_det_rec.include_asset_end_date_flag, 'N') = 'Y'
  and book_type_code = x_book_type_code
	  UNION ALL
--
  select lease_id src_id
       , 'LEASE' src_type
       , 0 hierarchy_level
       , null book_type_code
       , max(flp.end_date)  life_end_date
       , 0 life_in_months
       , 'CORPORATE' book_class
  from fa_lease_payments flp,fa_leases fl
  where fl.lease_id = decode(x_rule_det_rec.target_flag, 'Y', x_node_lease_id, x_asset_lease_id  )
  and nvl(x_rule_det_rec.include_lease_end_date_flag, 'N') = 'Y'
  and fl.payment_schedule_id = flp.payment_schedule_id
  group by lease_id
    , 'LEASE'
    , 0
    , null
    , 0
    , 'CORPORATE'
	  UNION ALL
--
  select category_id src_id
  , 'CATEGORY-LIFE' src_type
    , 0 hierarchy_level
    , book_type_code
    , decode( x_rule_det_rec.target_flag, 'Y',
       add_months( nvl(v_prorated_depr_date, x_prorate_date), life_in_months),
       add_months(x_prorate_date, life_in_months) ) life_end_date
    , life_in_months
    , 'CORPORATE' book_class
  from fa_category_book_defaults
  where category_id = decode(x_rule_det_rec.target_flag, 'Y', x_node_category_id, x_asset_cat_id )
  and  (trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate) ) )
  and nvl(x_rule_det_rec.include_asset_catg_life_flag, 'N') = 'Y'
  and  book_type_code = x_book_type_code
	  UNION ALL
--
  select  category_id src_id
  , 'CATEGORY-LED' src_type
    , 0 hierarchy_level
    , book_type_code
    , cua_life_end_date life_end_date
    , life_in_months
    , 'CORPORATE' book_class
  from fa_category_book_defaults
  where category_id = decode(x_rule_det_rec.target_flag, 'Y', x_node_category_id, x_asset_cat_id  )
  and  (trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate) ) )
  and nvl(x_rule_det_rec.include_catg_end_date_flag, 'N') = 'Y'
  and  book_type_code = x_book_type_code
  order by 7 desc;

CURSOR C_get_depr_date IS
  select depreciation_start_date
  from fa_asset_hierarchy
  where asset_hierarchy_id = x_parent_node_id;

BEGIN
  x_err_code:= '0';
  v_old_err_stack := x_err_stack;
  x_err_stack:= x_err_stack||'Derive_LED_for_ALL';

  g_derived_from_entity_rec.lim_type:= NULL;
  g_derived_from_entity_rec.life_in_months:= NULL;
  g_derive_from_entity := NULL;
  g_derive_from_entity_value:= NULL;

  if ( nvl(x_rule_det_rec.target_flag, 'N') = 'Y' AND
       nvl(x_rule_det_rec.include_asset_catg_life_flag, 'N') = 'Y') then
    OPEN C_get_depr_date;
    FETCH C_get_depr_date INTO v_deprn_date;
    CLOSE C_get_depr_date;

    if(v_deprn_date IS NOT NULL) then
      x_err_stage:= 'get_prorate_date';
      fa_cua_asset_wb_apis_pkg.get_prorate_date ( x_node_category_id
                                             , x_book_type_code
                                             , v_deprn_date -- in
                                             , v_prorated_depr_date  -- out
                                             , x_err_code
                                             , x_err_stage
                                             , x_err_stack , p_log_level_rec => p_log_level_rec);
               if(x_err_code <> '0') then
                return;
               end if;
    end if;
  end if;

  for life_rec in C_get_lifes LOOP

     -- The Book Type passed is not Corporate Book
     -- And the record selected is a Corporate Book then check if the Tax record exists
     -- If Tax record exists then use it instead of Corp Book

     if (x_book_type_code <> g_corporate_book) and (life_rec.src_type = 'NODE')
        and (life_rec.book_type_code =g_corporate_book) then
        open check_tax_record_exists(life_rec.src_id) ;
        fetch check_tax_record_exists into v_life_end_date;
        if check_tax_record_exists%found then
          close check_tax_record_exists;
          life_rec.life_end_date := nvl(v_life_end_date,life_rec.life_end_date);
        else
          close check_tax_record_exists;
        end if;
      end if;


              BEGIN
                if(life_rec.life_end_date IS NOT NULL ) then
                  if ( x_rule_det_rec.basis_code = 'MAX') then
                     v_led:= to_number(to_char(life_rec.life_end_date, 'J') );
                     v_led_max:= GREATEST( v_led, v_led_max );
                        if(v_led_max = v_led ) then
                           g_derived_from_entity_rec.lim_type:=life_rec.src_type;
                           g_derived_from_entity_rec.life_in_months:= life_rec.src_id;
                           g_derive_from_entity := life_rec.src_type;
                           g_derive_from_entity_value :=  life_rec.src_id;
                        end if;
                        v_led:= v_led_max;
                  elsif ( x_rule_det_rec.basis_code = 'MIN') then
                    v_led:= to_number(to_char(life_rec.life_end_date, 'J') );
                    v_led_min:= LEAST( v_led, v_led_min );
                        if(v_led_min = v_led ) then
                           g_derived_from_entity_rec.lim_type:=life_rec.src_type;
                           g_derived_from_entity_rec.life_in_months:= life_rec.src_id;
                           g_derive_from_entity := life_rec.src_type;
                           g_derive_from_entity_value :=  life_rec.src_id;
                         end if;
                      v_led:= v_led_min;
                  elsif ( x_rule_det_rec.basis_code = 'AVG') then
                    v_led_max:= GREATEST( to_number(to_char(life_rec.life_end_date, 'J') ), v_led_max );
                    v_led_min:= LEAST( to_number(to_char(life_rec.life_end_date, 'J') ), v_led_min );
                    v_led:= ROUND( (v_led_max + v_led_min)/2 ) ;

                    if(v_led = to_number(to_char(life_rec.life_end_date, 'J') ) ) then
                       g_derived_from_entity_rec.lim_type:=life_rec.src_type;
                       g_derived_from_entity_rec.life_in_months:= life_rec.src_id;
                       g_derive_from_entity := life_rec.src_type;
                       g_derive_from_entity_value :=  life_rec.src_id;
                    else
                       g_derived_from_entity_rec.lim_type:=NULL;
                       g_derived_from_entity_rec.life_in_months:= NULL;
                       g_derive_from_entity := NULL;
                       g_derive_from_entity_value := NULL;
                    end if;
                 end if;
               end if; -- NOT NULL

              END;

  END LOOP;

 -- convert to life in months
  if (v_led <> 0 )then
    -- get the life_in_months for the LED
    x_err_stage:= 'calc_life';
    x_life_out:= 0;
    fa_cua_mass_update1_pkg.calc_life ( x_book_type_code
                                   , x_prorate_date
                                   , to_date( v_led, 'J')
                                   , x_deprn_method_code
                                   , x_life_out
                                   , x_err_code
                                   , x_err_stage
                                   , x_err_stack
                                   , p_log_level_rec);
    if(x_err_code <> '0') then
       return;
    end if;

  end if;

x_err_stack := v_old_err_stack;
EXCEPTION
  WHEN OTHERS THEN
  -- x_err_code := sqlerrm;
  x_err_code := substr(sqlerrm,1,240);
  return;
END derive_LED_for_ALL;


-- ----------------------------------------------------------------
-- -----------------------------------------------------------------
PROCEDURE derive_asset_attribute(
          x_book_type_code               IN     VARCHAR2
        , x_parent_node_id               IN     NUMBER
        , x_asset_number                 IN     VARCHAR2  DEFAULT NULL
        , x_asset_id                     IN     NUMBER    DEFAULT NULL
        , x_prorate_date                 IN     DATE
        , x_cat_id_in                    IN     NUMBER
        , x_cat_id_out                      OUT NOCOPY NUMBER
        , x_cat_overide_allowed             OUT NOCOPY VARCHAR2
        , x_cat_rejection_flag              OUT NOCOPY VARCHAR2
        , x_lease_id_in                  IN     NUMBER    DEFAULT NULL
        , x_lease_id_out                    OUT NOCOPY NUMBER
        , x_lease_overide_allowed           OUT NOCOPY VARCHAR2
        , x_lease_rejection_flag            OUT NOCOPY VARCHAR2
        , x_distribution_set_id_in       IN     NUMBER    DEFAULT NULL
        , x_distribution_set_id_out         OUT NOCOPY NUMBER
        , x_distribution_overide_allowed    OUT NOCOPY VARCHAR2
        , x_distribution_rejection_flag     OUT NOCOPY VARCHAR2
        , x_serial_number_in             IN     VARCHAR2  DEFAULT NULL
        , x_serial_number_out               OUT NOCOPY VARCHAR2
        , x_serial_num_overide_allowed      OUT NOCOPY VARCHAR2
        , x_serial_num_rejection_flag       OUT NOCOPY VARCHAR2
        , x_asset_key_ccid_in            IN     NUMBER    DEFAULT NULL
        , x_asset_key_ccid_out              OUT NOCOPY NUMBER
        , x_asset_key_overide_allowed       OUT NOCOPY VARCHAR2
        , x_asset_key_rejection_flag        OUT NOCOPY VARCHAR2
        , x_life_in_months_in            IN     NUMBER    DEFAULT NULL
        , x_life_in_months_out              OUT NOCOPY NUMBER
        , x_life_end_dte_overide_allowed    OUT NOCOPY VARCHAR2
        , x_life_rejection_flag             OUT NOCOPY VARCHAR2
        , x_err_code                     IN OUT NOCOPY VARCHAR2
        , x_err_stage                    IN OUT NOCOPY VARCHAR2
        , x_err_stack                    IN OUT NOCOPY VARCHAR2
        , x_derivation_type              IN     VARCHAR2  DEFAULT 'ALL', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) IS

CURSOR C_get_rule_details( p_rule_set_id IN NUMBER
                         , p_book_type_code IN VARCHAR2
                         , p_attribute_name IN VARCHAR2 ) IS
  SELECT *
  FROM FA_HIERARCHY_RULE_DETAILS a
  WHERE hierarchy_rule_set_id = p_rule_set_id
  AND   attribute_name = p_attribute_name
  AND   book_type_code = p_book_type_code;


CURSOR C_get_top_node IS
  select asset_hierarchy_id
  from fa_asset_hierarchy
  where parent_hierarchy_id IS NULL
  start with asset_hierarchy_id = x_parent_node_id
  connect by asset_hierarchy_id = prior parent_hierarchy_id;

CURSOR C_check_lowest_node IS
  select 1
  from dual
  where not exists ( select asset_hierarchy_id
                     from fa_asset_hierarchy
                     where ( parent_hierarchy_id = x_parent_node_id
                             and asset_id IS NULL)
                     OR ( asset_hierarchy_id = x_parent_node_id
                             and asset_id IS NOT NULL ) );

CURSOR C_get_attr_values ( p_node_id IN NUMBER ) IS
  select '1' dummy, asset_hierarchy_id
       , asset_category_id
       , lease_id
       , dist_set_id
       , asset_key_ccid
       , serial_number
       , life_end_date
  from fa_asset_hierarchy_values
  where asset_hierarchy_id = p_node_id
  and   book_type_code = x_book_type_code
  UNION
  select '2' dummy, asset_hierarchy_id
       , asset_category_id
       , lease_id
       , dist_set_id
       , asset_key_ccid
       , serial_number
       , life_end_date
  from fa_asset_hierarchy_values
  where asset_hierarchy_id = p_node_id
  and   book_type_code = g_corporate_book
  order by 1;

CURSOR C_get_depr_info  IS
  select '1' dummy
       , nvl(x_prorate_date,prorate_date) -- Use Asset Pro Rate date if nothing passed
      , deprn_method_code
      , prorate_convention_code
      , life_in_months
  from fa_books
  where asset_id = x_asset_id
  and book_type_code = x_book_type_code
  and date_ineffective IS NULL;

CURSOR C_get_default_depr_info( p_cat_id IN NUMBER ) IS
  select '1' dummy,
         deprn_method
       , prorate_convention_code
       , life_in_months
  from fa_category_book_defaults
  where category_id = p_cat_id
  and book_type_code = x_book_type_code
  and ( trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate)) )
  UNION
  select '2' dummy
       , deprn_method
       , prorate_convention_code
       , life_in_months
  from fa_category_book_defaults
  where category_id = p_cat_id
  and book_type_code = g_corporate_book
  and ( trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate)) )
  ORDER BY 1;

CURSOR C_get_cat_id IS
  select asset_category_id
  from fa_additions
  where asset_id = x_asset_id;

CURSOR C_get_lease_id IS
  select lease_id
  from fa_additions
  where asset_id = x_asset_id;

CURSOR C_book_class IS
  select book_class
  from fa_book_controls
  where book_type_code = x_book_type_code;

CURSOR c_corp_book IS
  select distribution_source_book
  from fa_book_controls
  where book_type_code = x_book_type_code;

v_top_attr_val_rec    C_get_attr_values%ROWTYPE:= NULL;
v_lowest_attr_val_rec C_get_attr_values%ROWTYPE:= NULL;
v_attr_val_rec        C_get_attr_values%ROWTYPE:= NULL;
v_top_node_id         NUMBER;
v_dummy               NUMBER;
v_node_id             NUMBER;
v_old_err_stack       VARCHAR2(630);
v_rule_set_id         NUMBER;
v_rule_det_rec        fa_hierarchy_rule_details%ROWTYPE:= NULL;
i                     binary_integer:=0;
v_derivation_type VARCHAR2(30);
v_prorate_date DATE;
v_life_in_months NUMBER;
v_deprn_method_code VARCHAR2(30);
v_prorate_convention_code VARCHAr2(30);
v_LED DATE;
v_cat_id NUMBER;
v_lease_id NUMBER;
v_notfound VARCHAR2(1):= 'N';
BEGIN
  x_err_code := '0';
  v_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'derive_asset_attributes';

   -- determine the book_class
   x_err_stage:= 'c_book_class';
   OPEN c_book_class;
   FETCH c_book_class INTO G_book_class;
   CLOSE c_book_class;
     if G_book_class = 'TAX' then
        --first determine its corporate book
        x_err_stage:= 'c_corp_book';
        open c_corp_book;
        fetch c_corp_book INTO G_corporate_book;
        close c_corp_book;
    elsif G_book_class = 'CORPORATE' then
        G_corporate_book:= NULL;    --x_book_type_code;
     end if;

  x_err_stage:= 'c_check_lowest_node';
  open C_check_lowest_node;
  fetch C_check_lowest_node into v_dummy;
  close C_check_lowest_node;
    if v_dummy <>1 then
      x_err_code:= 'CUA_PARENT_NODE_NOT_LOWEST';
      return;
    end if;

  -- get TOP node of the tree and store it for future use
  x_err_stage:= 'C_get_top_node';
  open C_get_top_node;
  fetch C_get_top_node into v_top_node_id;
  close C_get_top_node;

  x_err_stage:= 'C_get_attr_values: Top Node';
  open C_get_attr_values( v_top_node_id );
  fetch C_get_attr_values into v_top_attr_val_rec;
  close C_get_attr_values;

  x_err_stage:= 'C_get_attr_values: Parent Node';
  open C_get_attr_values( x_parent_node_id );
  fetch C_get_attr_values into v_lowest_attr_val_rec;
  close C_get_attr_values;

  x_err_stage:= 'derive_rule';
  -- always derive for corporate_book only
  derive_rule( nvl(g_corporate_book, x_book_type_code)
              , x_parent_node_id
              , x_asset_id
              , x_cat_id_in
              , v_rule_set_id
              , x_err_code
              , x_err_stage
              , x_err_stack
              ,p_log_level_rec);
    if(x_err_code <> '0') then
       return;
    end if;

  -- now that the rule is identified, determine what the rule says
  if( x_derivation_type = 'ALL') then
      x_err_stage:= 'Getting Rule Details for Category';
       -- initialize before use
       v_rule_det_rec:=NULL;
       open C_get_rule_details( v_rule_set_id
                              , x_book_type_code
                              , 'CATEGORY');
      fetch C_get_rule_details into v_rule_det_rec;
      if(C_get_rule_details%NOTFOUND) then
        x_cat_id_out:= x_cat_id_in;
        x_cat_rejection_flag:= 'N';
        x_cat_overide_allowed:= 'Y';
      else
        if ( v_rule_det_rec.include_hierarchy_flag = 'Y') then
          -- then check the level
          if (v_rule_det_rec.include_level = 'TOP') then
            x_cat_id_out := v_top_attr_val_rec.asset_category_id;
            g_derived_from_entity_rec.category:= v_top_node_id;
          elsif (v_rule_det_rec.include_level = 'LOWEST') then
            x_cat_id_out := v_lowest_attr_val_rec.asset_category_id;
            g_derived_from_entity_rec.category:= x_parent_node_id;
          end if;
          x_cat_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
          x_cat_rejection_flag:= 'N';
          if( nvl(v_rule_det_rec.override_allowed_flag,'Y') = 'N' AND
              (nvl(x_cat_id_in,0) <> 0) AND
              x_cat_id_in <> nvl(x_cat_id_out,0)  ) then
              x_cat_rejection_flag:= 'Y';
          end if;

          -- check if the category has changed
          -- if so then the rule associated with the new ctgry might change
          -- derive new rule upto one iteration only and derive rest of attributes
          -- based on the new rule
          if ( (nvl(x_cat_id_out,0) <> 0 ) and (nvl(x_cat_id_in,0) <> nvl(x_cat_id_out,0) ) ) then
            x_err_stage:= 'Deriving Rule for the new category';
            derive_rule( x_book_type_code
                        , x_parent_node_id
                        , x_asset_id
                        , x_cat_id_out --new category
                        , v_rule_set_id
                        , x_err_code
                        , x_err_stage
                        , x_err_stack
                        , p_log_level_rec );

             if(x_err_code <> '0') then
               close C_get_rule_details;
               return;
             end if;
          end if;
        else
           x_cat_id_out := x_cat_id_in;
        end if;  --include_hierarchy_flag
      end if;
    close C_get_rule_details;
  end if; --derivation_type


  if( x_derivation_type IN ( 'ALL', 'LEASE_NUMBER' )) then
      x_err_stage:= 'Getting Rule Details for Lease';
       -- initialize before use
       v_rule_det_rec:=NULL;
      open C_get_rule_details( v_rule_set_id
                         , x_book_type_code
                         , 'LEASE_NUMBER');
      fetch C_get_rule_details into v_rule_det_rec;
      if(C_get_rule_details%NOTFOUND) then
        x_lease_id_out:= x_lease_id_in;
        x_lease_rejection_flag:= 'N';
        x_lease_overide_allowed:= 'Y';
      else
        if ( v_rule_det_rec.include_hierarchy_flag = 'Y') then
          if (v_rule_det_rec.include_level = 'TOP') then
            x_lease_id_out := v_top_attr_val_rec.lease_id;
            g_derived_from_entity_rec.lease:= v_top_node_id;
          elsif (v_rule_det_rec.include_level = 'LOWEST') then
            x_lease_id_out := v_lowest_attr_val_rec.lease_id;
            g_derived_from_entity_rec.lease:= x_parent_node_id;
          end if;
          x_lease_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
          x_lease_rejection_flag:= 'N';
          if( nvl(x_lease_overide_allowed,'Y') = 'N' AND
              (nvl(x_lease_id_in,0) <> 0)   AND
              x_lease_id_in <> nvl(x_lease_id_out,0)  ) then
            x_lease_rejection_flag:= 'Y';
          end if;
        else
          x_lease_id_out:= x_lease_id_in;
        end if;  -- include_hierarchy
      end if;
    close C_get_rule_details;
  end if; --derivation_type


  if( x_derivation_type IN ( 'ALL', 'DISTRIBUTION' )) then
      x_err_stage:= 'Getting Rule Details for Distribution Set';
       -- initialize before use
       v_rule_det_rec:=NULL;
      open C_get_rule_details( v_rule_set_id
                             , x_book_type_code
                             , 'DISTRIBUTION');
      fetch C_get_rule_details into v_rule_det_rec;
      if(C_get_rule_details%NOTFOUND) then
        x_distribution_set_id_out:= x_distribution_set_id_in;
        x_distribution_rejection_flag:= 'N';
        x_distribution_overide_allowed:= 'Y';
      else
         if( v_rule_det_rec.include_hierarchy_flag = 'Y') then
          if (v_rule_det_rec.include_level = 'TOP') then
              x_distribution_set_id_out := v_top_attr_val_rec.dist_set_id;
              g_derived_from_entity_rec.distribution:= v_top_node_id;
          elsif (v_rule_det_rec.include_level = 'LOWEST') then
              x_distribution_set_id_out := v_lowest_attr_val_rec.dist_set_id;
              g_derived_from_entity_rec.distribution:= x_parent_node_id;
          end if;
          x_distribution_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
          x_distribution_rejection_flag:= 'N';

          if( nvl(x_distribution_overide_allowed, 'Y') = 'N') then
            if( nvl(x_distribution_set_id_in,0)<>0
              AND x_distribution_set_id_in <> nvl(x_distribution_set_id_out,0)) then
              x_distribution_rejection_flag:= 'Y';
            end if;
          end if;
        else
         x_distribution_set_id_out:=  x_distribution_set_id_in;
        end if;
      end if;
    close C_get_rule_details;
  end if; --derivation_type

  if( x_derivation_type IN ( 'ALL', 'SERIAL_NUMBER' )) then
      x_err_stage:= 'Getting Rule Details for Serial Number';
       -- initialize before use
       v_rule_det_rec:=NULL;
      open C_get_rule_details( v_rule_set_id
                             , x_book_type_code
                             , 'SERIAL_NUMBER');
      fetch C_get_rule_details into v_rule_det_rec;
      if( C_get_rule_details%NOTFOUND) then
        x_serial_number_out:= x_serial_number_in;
        x_serial_num_rejection_flag:= 'N';
        x_serial_num_overide_allowed:= 'Y';
      else


      if( v_rule_det_rec.include_hierarchy_flag = 'Y') then
        if (v_rule_det_rec.include_level = 'TOP') then
          x_serial_number_out := v_top_attr_val_rec.serial_number;
          g_derived_from_entity_rec.serial_number:= v_top_node_id;
        elsif (v_rule_det_rec.include_level = 'LOWEST') then
          x_serial_number_out := v_lowest_attr_val_rec.serial_number;
          g_derived_from_entity_rec.serial_number:= x_parent_node_id;
        end if;
        x_serial_num_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
        x_serial_num_rejection_flag:= 'N';
        if( nvl( x_serial_num_overide_allowed,'Y') = 'N' AND
          (nvl(x_serial_number_in,'0') <> '0') AND
          x_serial_number_in <> nvl(x_serial_number_out ,'0') ) then
          x_serial_num_rejection_flag:= 'Y';
        end if;
      else
         x_serial_number_out:= x_serial_number_in;
      end if;  -- asset_hierarchy
    end if;
   close C_get_rule_details;
  end if; --derivation_type


  if( x_derivation_type IN ( 'ALL', 'ASSET_KEY' )) then
      x_err_stage:= 'Getting Rule Details for Asset Key';
      open C_get_rule_details( v_rule_set_id
                             , x_book_type_code
                             , 'ASSET_KEY');
       -- initialize before use
       v_rule_det_rec:=NULL;
      fetch C_get_rule_details into v_rule_det_rec;
      if(C_get_rule_details%NOTFOUND) then
        x_asset_key_ccid_out:= x_asset_key_ccid_in;
        x_asset_key_rejection_flag:= 'N';
        x_asset_key_overide_allowed := 'Y';
      else
        if( v_rule_det_rec.include_hierarchy_flag = 'Y') then
          if (v_rule_det_rec.include_level = 'TOP') then
            g_derived_from_entity_rec.asset_key:= v_top_node_id;
            x_asset_key_ccid_out := v_top_attr_val_rec.asset_key_ccid;
          elsif (v_rule_det_rec.include_level = 'LOWEST') then
            g_derived_from_entity_rec.asset_key:= x_parent_node_id;
            x_asset_key_ccid_out := v_lowest_attr_val_rec.asset_key_ccid;
          end if;
          x_asset_key_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
          x_asset_key_rejection_flag:= 'N';
          if( nvl(x_asset_key_overide_allowed, 'Y') = 'N' AND
            (nvl(x_asset_key_ccid_in,0) <> 0) AND
            x_asset_key_ccid_in <> nvl(x_asset_key_ccid_out ,0) ) then
              x_asset_key_rejection_flag:= 'Y';
          end if;
        else
          x_asset_key_ccid_out:= x_asset_key_ccid_in;
        end if; -- include_asset_hierarchy
      end if;
    close C_get_rule_details;
  end if; --derivation_type


  if( x_derivation_type IN ('ALL' ,'LIFE_END_DATE', 'LEASE_NUMBER') AND
      ( ( x_asset_id IS NULL AND x_prorate_date IS NOT NULL ) OR x_asset_id IS NOT NULL) ) then
      x_err_stage:= 'Getting Rule Details for Life End Date';
       -- initialize before use
       v_rule_det_rec:=NULL;
      x_err_stage:= 'Life End Date: C_get_rule_details1';
      open C_get_rule_details( v_rule_set_id
                             , x_book_type_code
                             , 'LIFE_END_DATE');
      fetch C_get_rule_details into v_rule_det_rec;
      if(C_get_rule_details%NOTFOUND) then
          if G_book_class = 'TAX' then
            -- close opened cursor
            close C_get_rule_details;

            -- get the rule details from the corporate book
            x_err_stage:= 'Life End Date: C_get_rule_details2';
            open C_get_rule_details( v_rule_set_id
                                   , g_corporate_book
                                   , 'LIFE_END_DATE');
            fetch C_get_rule_details into v_rule_det_rec;
              if(C_get_rule_details%NOTFOUND) then
                v_notfound := 'Y';
              end if;
            close c_get_rule_details;
         else
            -- if it is corporate book then notfound logic still applies
            v_notfound := 'Y';
         end if;
      end if; -- C_get_rule_details not found
      if C_get_rule_details%ISOPEN then
        close C_get_rule_details;
      end if;

      if v_notfound = 'Y' then
         v_notfound:= 'N';
          -- determine the life to be passed out
          if(x_asset_id IS NOT NULL) then
            --get life from asset;
            x_err_stage:= 'Life End Date: C_get_depr_info1';
            open C_get_depr_info;
            fetch C_get_depr_info into v_dummy
                                   , v_prorate_date
                                   , v_deprn_method_code
                                   , v_prorate_convention_code
                                   , v_life_in_months;
            close C_get_depr_info;
            x_err_stage:= 'After Life End Date: C_get_depr_info1';

            -- bugfix 2233323 if  C_get_depr_info%notfound then
            if  v_life_in_months is null then
                x_err_stage:= 'Life End Date: C_get_depr_info2';
                open C_get_default_depr_info( x_cat_id_in );
                fetch C_get_default_depr_info into v_dummy, v_deprn_method_code
                                               , v_prorate_convention_code
                                               , v_life_in_months;
                close C_get_default_depr_info;
                v_prorate_date := x_prorate_date;
            end if;

            g_derived_from_entity_rec.life_in_months:= x_asset_id;
            g_derived_from_entity_rec.lim_type:= 'ASSET';
            g_derive_from_entity_value:= x_asset_id;
	         g_derive_from_entity:= 'ASSET';
          else
            -- get life from category
            -- determine the category_id to be passed to derive the dates from
            if (x_cat_id_out IS NOT NULL) then
               -- then use the new category_id
               v_cat_id := x_cat_id_out;
            else  -- if_cat_out IS NULL
               -- then try to use the passed-in category_id
               if(nvl(x_cat_id_in,0) <> 0 ) then
                   v_cat_id := x_cat_id_in;
               else
                 -- cannot determine the cat_id
                 v_cat_id :=NULL;
               end if;
            end if;

            x_err_stage:= 'Life End Date: C_get_default_depr_info';
            open C_get_default_depr_info( v_cat_id);
            fetch C_get_default_depr_info into v_dummy, v_deprn_method_code
                                           , v_prorate_convention_code
                                           , v_life_in_months;
            close C_get_default_depr_info;
           if v_cat_id IS NOT NULL then
             g_derived_from_entity_rec.life_in_months:= v_cat_id;
             g_derived_from_entity_rec.lim_type:= 'CATEGORY';
             g_derive_from_entity_value:= v_cat_id;
	         g_derive_from_entity:= 'CATEGORY';
           end if;
          end if;  --asset_id NOT NULL
          x_life_in_months_out:= v_life_in_months;
          x_life_rejection_flag:= 'N';
          x_life_end_dte_overide_allowed := 'Y';
      else

--         if( v_rule_det_rec.include_hierarchy_flag = 'Y') then
            -- get depr info and store for future use
            x_err_stage:= 'Getting Depreciation Info';
            if(x_asset_id IS NULL) then
              -- get depr info from Category_Book_Defaults
              open C_get_default_depr_info( x_cat_id_in );
              fetch C_get_default_depr_info into v_dummy, v_deprn_method_code
                                               , v_prorate_convention_code
                                               , v_life_in_months;
              close C_get_default_depr_info;

              v_prorate_date := x_prorate_date;

            else
              open C_get_depr_info;
              fetch C_get_depr_info into v_dummy, v_prorate_date
                                   , v_deprn_method_code
                                   , v_prorate_convention_code
                                   , v_life_in_months;
              if  C_get_depr_info%notfound then
                open C_get_default_depr_info( x_cat_id_in );
                fetch C_get_default_depr_info into v_dummy, v_deprn_method_code
                                               , v_prorate_convention_code
                                               , v_life_in_months;
                close C_get_default_depr_info;
                v_prorate_date := x_prorate_date;
              end if;

              close C_get_depr_info;


           end if;

           if(v_rule_det_rec.precedence_level IS NOT NULL ) then
             if( v_rule_det_rec.precedence_level = 'TOP') then
               x_err_stage:= 'Calling calc_life';
               fa_cua_mass_update1_pkg.calc_life ( x_book_type_code
                                              , v_prorate_date
                                              , v_top_attr_val_rec.life_end_date
                                              , v_deprn_method_code
                                              , x_life_in_months_out
                                              , x_err_code
                                              , x_err_stage
                                              , x_err_stack , p_log_level_rec => p_log_level_rec);
                 if(x_err_code <> '0') then
                   return;
                 end if;
              g_derived_from_entity_rec.life_in_months:= v_top_node_id;
              g_derived_from_entity_rec.lim_type:= 'NODE-P';
	          g_derive_from_entity_value:= v_top_node_id;
	          g_derive_from_entity:= 'NODE-P';
          elsif( v_rule_det_rec.precedence_level = 'LOWEST') then
              x_err_stage:= 'Calling calc_life';
              fa_cua_mass_update1_pkg.calc_life ( x_book_type_code
                                             , v_prorate_date
                                             , v_lowest_attr_val_rec.life_end_date
                                             , v_deprn_method_code
                                             , x_life_in_months_out
                                             , x_err_code
                                             , x_err_stage
                                             , x_err_stack , p_log_level_rec => p_log_level_rec);
              if(x_err_code <> '0') then
                return;
              end if;
              g_derived_from_entity_rec.life_in_months:= x_parent_node_id;
              g_derived_from_entity_rec.lim_type:= 'NODE-P';
	          g_derive_from_entity_value := x_parent_node_id;
	          g_derive_from_entity:= 'NODE-P';
          end if; --precedence_level
        end if;  -- precedence level not null

        if( v_rule_det_rec.precedence_level IS NULL OR
          nvl(x_life_in_months_out, 0) = 0 ) then
            -- get all the possible LEDs and store
            if(x_asset_id IS NULL) then
              -- determine the category_id to be passed to derive the dates from
              if (x_cat_id_out IS NOT NULL) then
                 -- then use the new category_id
                  v_cat_id := x_cat_id_out;
              else  -- if_cat_out IS NULL
                 -- then try to use the passed-in category_id
                 if( nvl(x_cat_id_in,0) <> 0 ) then
                   v_cat_id := x_cat_id_in;
                 else
                   -- cannot determine the cat_id
                   v_cat_id :=NULL;
                 end if;
              end if;

              -- determine the lease to be used to derive the dates from
              if (x_lease_id_out IS NOT NULL) then
                 -- then use the new lease_id
                  v_lease_id := x_lease_id_out;
              else  -- if_cat_lease IS NULL
                 -- then try to use the passed-in category_id
                 if( nvl(x_lease_id_in,0) <> 0 ) then
                   v_lease_id := x_lease_id_in;
                 else
                   -- cannot determine the lease_id
                   v_lease_id :=NULL;
                 end if;
              end if;
            else --if x_asset_id IS NOT NULL
              -- determine the category_id to be passed to derive dates from
              if(x_cat_id_out IS NOT NULL) then
                -- use the new category_id
                v_cat_id := x_cat_id_out;
              else
                -- use the cat_in value
                if(nvl(x_cat_id_in,0) <> 0) then
                 v_cat_id := x_cat_id_in;
                else -- if cat_id_in is null
                  -- determine from fa_additions for that asset
                  open C_get_cat_id;
                  fetch C_get_cat_id into v_cat_id;
                  close c_get_cat_id;

                end if;
              end if;

              -- determine the lease to be used to derive the date
              if(x_lease_id_out IS NOT NULL) then
                -- use the new lease_id
                v_lease_id := x_lease_id_out;
              else
                -- use the lease_id_in value
                if( nvl(x_lease_id_in, 0) <> 0) then
                  v_lease_id := x_lease_id_in;
                else
                  -- determine the lease_id for that asset
                  open C_get_lease_id;
                  fetch C_get_lease_id into v_lease_id;
                  close C_get_lease_id;
                end if;
              end if;
            end if;

            -- derive all LEDs and determine based on basis_code
            x_err_stage:= 'derive_LED_for_ALL';

               derive_LED_for_ALL( x_book_type_code
                                 , x_asset_id
                                 , x_parent_node_id
                                 , v_top_node_id
                                 , v_cat_id
                                 , nvl(v_lowest_attr_val_rec.asset_category_id, v_cat_id)
                                 , v_lease_id
                                 , nvl(v_lowest_attr_val_rec.lease_id, v_lease_id)
                                 , v_prorate_date
                                 , v_prorate_convention_code
                                 , v_deprn_method_code
                                 , v_rule_det_rec
                                 , x_life_in_months_out   --v_LED
                                 , x_err_code
                                 , x_err_stage
                                 , x_err_stack ) ;

              if(x_err_code <> '0') then
                -- close C_get_rule_details;
                return;
              end if;

            end if;  -- precedence_level
            x_life_end_dte_overide_allowed := nvl(v_rule_det_rec.override_allowed_flag, 'Y');
            x_life_rejection_flag:= 'N';
            if(    (nvl(x_life_end_dte_overide_allowed, 'Y') = 'N')
               AND (nvl(x_life_in_months_in, 0) <> 0)
               AND x_life_in_months_in <> nvl(x_life_in_months_out, 0) ) then
              x_life_rejection_flag:= 'Y';
            end if;
--         else
--           x_life_in_months_out:= x_life_in_months_in;
--         end if;
     end if;  -- v_notfound
    -- close C_get_rule_details;
  end if; --derivation_type

  g_derived_from_entity_rec.lim_type:= rtrim(g_derived_from_entity_rec.lim_type,' ');
  g_derived_from_entity_rec.life_in_months:= rtrim(g_derived_from_entity_rec.life_in_months,' ');
  g_derive_from_entity :=rtrim(g_derive_from_entity,' ');
  g_derive_from_entity_value:= rtrim(g_derive_from_entity_value,' ');
  x_err_stage := 'End of derive_asset_attribute';
  x_err_stack := v_old_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    -- x_err_code := sqlerrm;
    x_err_code := substr(sqlerrm, 1,240);
    return;
END derive_asset_attribute;

PROCEDURE process_conc_batch ( ERRBUF  OUT NOCOPY VARCHAR2,
                               RETCODE OUT NOCOPY VARCHAR2,
                               x_batch_number IN VARCHAR2 ) IS
  CURSOR C_bhdrs IS
    SELECT *
    FROM fa_mass_update_batch_headers
    where batch_number = x_batch_number
    and status_code IN ( 'N', 'IP')
    for UPDATE NOWAIT;
    v_err_stack varchar2(640);
    v_err_code varchar2(640);
    v_err_stage varchar2(640);
    v_message_name  varchar2(240);

    request_failed EXCEPTION;
BEGIN

    RETCODE := '0';
    -- v_Request_ID := FND_GLOBAL.Conc_Request_ID;
    -- set the flag so as to not allow insert into batch_headers

    g_conc_process:= 'Y';

    For hdr_rec IN C_bhdrs LOOP

    if fa_cua_hr_retirements_pkg.check_pending_batch( x_calling_function  => 'CONCURRENT'
                                                  , x_event_code       => hdr_rec.event_code
                                                  , x_book_type_code   => hdr_rec.book_type_code
                                                  , x_asset_id         => null
                                                  , x_node_id          => null
                                                  , x_category_id      => null
                                                  , x_attribute        => null
                                                  , x_conc_request_id  => hdr_rec.concurrent_request_id
                                                  , x_status           => RETCODE
                                                  , p_log_level_rec => g_log_level_rec) then
           raise request_failed;
    else
      generate_batch_transactions(
          x_event_code           => hdr_rec.event_code
        , x_book_type_code       => hdr_rec.book_type_code
        , x_src_entity_name      => hdr_rec.source_entity_name
        , x_src_entity_value     => hdr_rec.source_entity_key_value
        , x_src_attribute_name   => hdr_rec.source_attribute_name
        , x_src_attr_value_from  => hdr_rec.source_attribute_old_id
        , x_src_attr_value_to    => hdr_rec.source_attribute_new_id
        , x_amortize_expense_flg => hdr_rec.amortize_flag
        , x_amortization_date    => hdr_rec.amortization_date
        , x_batch_num            => hdr_rec.batch_number
        , x_batch_id             => hdr_rec.batch_id
        , x_transaction_name     => hdr_rec.transaction_name
        , x_attribute_category   => hdr_rec.attribute_category
        , x_attribute1           => hdr_rec.attribute1
        , x_attribute2           => hdr_rec.attribute2
        , x_attribute3           => hdr_rec.attribute3
        , x_attribute4           => hdr_rec.attribute4
        , x_attribute5           => hdr_rec.attribute5
        , x_attribute6           => hdr_rec.attribute6
        , x_attribute7           => hdr_rec.attribute7
        , x_attribute8           => hdr_rec.attribute8
        , x_attribute9           => hdr_rec.attribute9
        , x_attribute10          => hdr_rec.attribute10
        , x_attribute11          => hdr_rec.attribute11
        , x_attribute12          => hdr_rec.attribute12
        , x_attribute13          => hdr_rec.attribute13
        , x_attribute14          => hdr_rec.attribute14
        , x_attribute15          => hdr_rec.attribute15
        , x_err_code             => RETCODE
        , x_err_stage            => ERRBUF
        , x_err_stack            => v_err_stack
        , p_log_level_rec        => g_log_level_rec);
     end if;

      if RETCODE = '0' then
       if fa_cua_asset_wb_apis_pkg.check_batch_details_exists(hdr_rec.batch_id, p_log_level_rec => g_log_level_rec) then

          -- bugfix  1507759
           update fa_mass_update_batch_headers
           set status_code = 'P',
           rejection_reason_code = null
           where batch_id = hdr_rec.batch_id;
        else
           update fa_mass_update_batch_headers
           set status_code = 'CP',
           rejection_reason_code = null
           where batch_id = hdr_rec.batch_id;
        end if;
      else
        raise request_failed;
      end if;

  END LOOP;
      commit;

EXCEPTION
    when request_failed then

       fnd_message.set_name('CUA', RETCODE);
       v_message_name:= substrb(fnd_message.get, 1, 240);

       update fa_mass_update_batch_headers
       set status_code = 'R',
       rejection_reason_code = v_message_name
       where batch_number = x_batch_number ;

        commit;
       raise_application_error(-20010,v_message_name );

   when others then
       v_message_name := substrb(sqlerrm(sqlcode), 1, 240);

       update fa_mass_update_batch_headers
       set status_code = 'R',
       rejection_reason_code = v_message_name
       where batch_number = x_batch_number ;

       commit;
       raise;
END process_conc_batch;

-- -----------------------------------------------------------------
PROCEDURE generate_batch_transactions1(
          x_event_code           IN     VARCHAR2
        , x_book_type_code       IN     VARCHAR2
        , x_src_entity_name      IN     VARCHAR2
        , x_src_entity_value     IN     VARCHAR2
        , x_src_attribute_name   IN     VARCHAR2
        , x_src_attr_value_from  IN     VARCHAR2
        , x_src_attr_value_to    IN     VARCHAR2
        , x_amortize_expense_flg IN     VARCHAR2
        , x_amortization_date    IN     DATE
        , x_batch_num            IN OUT NOCOPY VARCHAR2
        , x_batch_id             IN OUT NOCOPY NUMBER
        , x_transaction_name     IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category   IN     VARCHAR2 DEFAULT NULL
        , x_attribute1           IN     VARCHAR2 DEFAULT NULL
        , x_attribute2           IN     VARCHAR2 DEFAULT NULL
        , x_attribute3           IN     VARCHAR2 DEFAULT NULL
        , x_attribute4           IN     VARCHAR2 DEFAULT NULL
        , x_attribute5           IN     VARCHAR2 DEFAULT NULL
        , x_attribute6           IN     VARCHAR2 DEFAULT NULL
        , x_attribute7           IN     VARCHAR2 DEFAULT NULL
        , x_attribute8           IN     VARCHAR2 DEFAULT NULL
        , x_attribute9           IN     VARCHAR2 DEFAULT NULL
        , x_attribute10          IN     VARCHAR2 DEFAULT NULL
        , x_attribute11          IN     VARCHAR2 DEFAULT NULL
        , x_attribute12          IN     VARCHAR2 DEFAULT NULL
        , x_attribute13          IN     VARCHAR2 DEFAULT NULL
        , x_attribute14          IN     VARCHAR2 DEFAULT NULL
        , x_attribute15          IN     VARCHAR2 DEFAULT NULL
        , x_err_code             IN OUT NOCOPY VARCHAR2
        , x_err_stage            IN OUT NOCOPY VARCHAR2
        , x_err_stack            IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) IS

v_dummy NUMBER;
v_old_err_stack varchar2(630);
v_sysdate DATE;
v_created_by NUMBER;
v_last_update_login NUMBER;
v_last_updated_by NUMBER;
v_conc_request_id NUMBER;
v_asset_attr_tab FA_CUA_DERIVE_ASSET_ATTR_PKG.asset_tabtype;
--v_distribution_array_out distribution_tabtype;
i binary_integer:=0;
j binary_integer:= 0;
v_cat_id_out             NUMBER;
v_cat_overide_allowed    VARCHAR2(1);
v_cat_rejection_flag     VARCHAR2(1);
v_lease_id_out           NUMBER;
v_lease_overide_allowed  VARCHAR2(1);
v_lease_rejection_flag   VARCHAR2(1);
v_depr_ccid_out          NUMBER;
v_assigned_to_out        NUMBER;
v_location_id_out        NUMBER;
v_dist_overide_allowed VARCHAR2(1);
v_dist_rejection_flag  VARCHAR2(1);
v_serial_number_out            VARCHAR2(30);
v_serial_num_overide_allowed   VARCHAR2(1);
v_serial_num_rejection_flag    VARCHAR2(1);
v_asset_key_ccid_out           NUMBER;
v_asset_key_overide_allowed    VARCHAR2(1);
v_asset_key_rejection_flag     VARCHAR2(1);
v_life_in_months_out           NUMBER;
v_life_end_dte_overide_allowed VARCHAR2(1);
v_life_rejection_flag          VARCHAR2(1);
v_rejection_reason_code        VARCHAR2(150);
v_status_code                  VARCHAR2(3):= 'P';
v_rejected_rows                NUMBER:=0;
v_derivation_type              VARCHAR2(30);
v_distribution_set_id_out      NUMBER:= NULL;
v_location_id_old              NUMBER:= NULL;
v_location_id_new              NUMBER:= NULL;
v_depr_ccid_old                NUMBER:= NULL;
v_depr_ccid_new                NUMBER:= NULL;
v_assigned_to_old              NUMBER:= NULL;
v_assigned_to_new              NUMBER:= NULL;
v_src_attribute_name           VARCHAR2(30):= NULL;
v_src_attr_value_from          VARCHAR2(30):= NULL;
v_src_attr_value_to            VARCHAR2(30):= NULL;
v_dist_count                   NUMBER;
v_dist_count2                  NUMBER;
v_parent_id                    NUMBER:= NULL;
v_insert_flag                  VARCHAR2(1):= 'N';
v_book_class                   VARCHAR2(15);

CURSOR c_book IS
  select book_class
  from fa_book_controls
  where book_type_code = x_book_type_code;

BEGIN
  x_err_code := '0';
  v_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'generate_batch_transactions1';

  x_err_stage:= 'Initializing Parameters';
  v_sysdate:= sysdate;
  v_conc_request_id := fnd_global.conc_request_id;
  v_created_by:= nvl(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
  v_last_updated_by:= v_created_by;
  v_last_update_login:= nvl(TO_NUMBER(fnd_profile.value('LOGIN_ID')),-1);

  -- copy input values to internal variables
  -- for future assignments
  v_src_attribute_name:= x_src_attribute_name;
  v_src_attr_value_from:= x_src_attr_value_from;
  v_src_attr_value_to:= x_src_attr_value_to;
  v_derivation_type := v_src_attribute_name;

  if x_event_code IN( 'CHANGE_NODE_PARENT'
                    , 'CHANGE_NODE_RULE_SET'
                    , 'CHANGE_ASSET_PARENT'
                    , 'CHANGE_ASSET_CATEGORY'
                    , 'CHANGE_CATEGORY_RULE_SET'
                    , 'HR_MASS_TRANSFER'
                    , 'HR_REINSTATEMENT') then
      v_derivation_type := 'ALL';
      if x_event_code = 'HR_MASS_TRANSFER' then
        v_parent_id:= x_src_attr_value_to;
      end if;
  elsif ( x_event_code = 'CHANGE_NODE_ATTRIBUTE' ) then
      if (v_src_attribute_name = 'CATEGORY') then
        v_derivation_type := 'ALL';
      elsif (v_src_attribute_name = 'DISTRIBUTION' ) then
        v_derivation_type:= 'DISTRIBUTION';
      elsif (v_src_attribute_name = 'DATE_PLACED_IN_SERVICE') then
        v_derivation_type:= 'LIFE_END_DATE';
      end if;
  elsif x_event_code IN ( 'CHANGE_ASSET_LEASE',
                          'CHANGE_LEASE_LIFE_END_DATE',
                          'CHANGE_CATEGORY_LIFE',
                          'CHANGE_CATEGORY_LIFE_END_DATE') then
    v_derivation_type := 'LIFE_END_DATE';
  end if;

  -- for TAX books derive only Life changes
   OPEN c_book;
   FETCH c_book into v_book_class;
   CLOSE c_book;
   if( v_book_class = 'TAX') then
     v_derivation_type := 'LIFE_END_DATE';
   end if;

-- insert into batch_headers if not called from conc_process
if G_conc_process <> 'Y' then
  x_err_stage:= 'Calling insert_mass_update_batch_headers';
  FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_hdrs (
             x_event_code
           , x_book_type_code
           , 'P'
           , x_src_entity_name
           , x_src_entity_value
           , v_src_attribute_name
           , v_src_attr_value_from
           , v_src_attr_value_to
           , NULL  -- x_description
           , x_amortize_expense_flg
           , x_amortization_date
           , v_rejection_reason_code
           , v_conc_request_id
           , v_created_by
           , v_sysdate -- creation_date
           , v_last_updated_by
           , v_sysdate  -- last_update_date
           , v_last_update_login
           , x_batch_num
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
           , x_attribute15
           , x_err_code
           , x_err_stage
           , x_err_stack , p_log_level_rec => p_log_level_rec);

     if (x_err_code <> '0') then
       return;
      end if;
  end if;

  x_err_stage:= 'Calling select_assets';
  -- dbms_output.put_line(x_err_stage);
  FA_CUA_DERIVE_ASSET_ATTR_PKG.select_assets( x_event_code
               , x_book_type_code
               , v_book_class
               , x_src_entity_value
               , v_parent_id  -- new parent id in case of HR_MASS_TRANSFER
               , v_asset_attr_tab
               , x_err_code
               , x_err_stage
               , x_err_stack , p_log_level_rec => p_log_level_rec);
   if (x_err_code <> '0') then
     update fa_mass_update_batch_headers
     set status_code = 'R',
        rejection_reason_code = x_err_code
     where batch_id = x_batch_id;
     return;
  end if;

  if(x_event_code = 'HR_MASS_TRANSFER' and v_book_class = 'CORPORATE') then
    G_asset_array:= v_asset_attr_tab;
  end if;

--    for each asset in the select_assets_array loop
  for i in 1..v_asset_attr_tab.count LOOP
    if( fa_cua_hr_retirements_pkg.check_pending_batch('HIERARCHY',
                                                x_event_code,
                                                x_book_type_code,
                                                v_asset_attr_tab(i).asset_id,
                                                null, null, null, null, x_err_code,
                                                p_log_level_rec )) then
      x_err_code := 'CUA_ASSET_IN_USE';
      rollback;
      return;
    end if;
  x_err_stage:= 'Calling derive_asset_attributes';
    derive_asset_attribute(
      x_book_type_code
    , v_asset_attr_tab(i).parent_hierarchy_id
    , NULL -- asset_number
    , v_asset_attr_tab(i).asset_id
    , NULL
    , v_asset_attr_tab (i).asset_category_id
    , v_cat_id_out
    , v_cat_overide_allowed
    , v_cat_rejection_flag
    , v_asset_attr_tab(i).lease_id
    , v_lease_id_out
    , v_lease_overide_allowed
    , v_lease_rejection_flag
    , NULL --v_distribution_set_id_old
    , v_distribution_set_id_out
    , v_dist_overide_allowed
    , v_dist_rejection_flag
    , v_asset_attr_tab(i).serial_number
    , v_serial_number_out
    , v_serial_num_overide_allowed
    , v_serial_num_rejection_flag
    , v_asset_attr_tab(i).asset_key_ccid
    , v_asset_key_ccid_out
    , v_asset_key_overide_allowed
    , v_asset_key_rejection_flag
    , v_asset_attr_tab(i).life_in_months
    , v_life_in_months_out
    , v_life_end_dte_overide_allowed
    , v_life_rejection_flag
    , x_err_code
    , x_err_stage
    , x_err_stack
    , v_derivation_type
    , p_log_level_rec);

    if(x_err_code <> '0') then
       return;
    end if;

   if ( v_derivation_type = 'ALL' AND
        nvl(v_asset_attr_tab(i).asset_category_id,0) <> nvl(v_cat_id_out,0)) then
     x_err_stage:= 'Insert_mass_update_batch_details: asset_category';
     FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
              x_batch_id
            , x_book_type_code
            , 'CATEGORY'
            , v_asset_attr_tab(i).asset_id
            , to_char(v_asset_attr_tab(i).asset_category_id)
            , to_char(v_cat_id_out)
            , 'NODE' --x_derived_from_entity_type
            , g_derived_from_entity_rec.category -- x_derived_from_entity_id
            , v_asset_attr_tab(i).parent_hierarchy_id_old
            , v_status_code
            , NULL --v_rejection_reason_code
            , 'Y'  --x_apply_flag
            , NULL --x_effective_date
            , NULL --x_fa_period_name
            , v_conc_request_id
            , v_created_by
            , v_sysdate
            , v_last_updated_by
            , v_sysdate
            , v_last_update_login
            , x_err_code
            , x_err_stage
            , x_err_stack
            , p_log_level_rec);
   end if;
   if(x_err_code <> '0') then
      return;
    end if;

   if( v_derivation_type IN ('ALL', 'LEASE_NUMBER') AND
       nvl(v_asset_attr_tab(i).lease_id,0) <> nvl(v_lease_id_out,0) ) then
      x_err_stage:= 'Insert_mass_update_batch_details: lease_number';
     FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
             x_batch_id
           , x_book_type_code
           , 'LEASE_NUMBER'
           , v_asset_attr_tab(i).asset_id
           , to_char(v_asset_attr_tab(i).lease_id)
           , to_char(v_lease_id_out)
           , 'NODE' --x_derived_from_entity_type
           , g_derived_from_entity_rec.lease
           , v_asset_attr_tab(i).parent_hierarchy_id_old
           , v_status_code
           , NULL --x_rejection_reason_code
           , 'Y' --x_apply_flag
           , NULL --x_effective_date
           , NULL --x_fa_period_name
           , v_conc_request_id
           , v_created_by
           , v_sysdate
           , v_last_updated_by
           , v_sysdate
           , v_last_update_login
           , x_err_code
           , x_err_stage
           , x_err_stack
           , p_log_level_rec);
   end if;
   if(x_err_code <> '0') then
      return;
    end if;

   if( v_derivation_type IN ('ALL', 'DISTRIBUTION') AND nvl(v_distribution_set_id_out,0) <>0 )then
          -- check the dist already exists
          select count(*) into v_dist_count
          from fa_hierarchy_distributions
          where dist_set_id = v_distribution_set_id_out;

           if( v_dist_count <> 0 ) then
              -- first get each dist-combination
              -- for each cokbination run query below
              -- check whether the distribution exists for the asset
              select count(*)
              into v_dist_count2
              from fa_distribution_history fmd
                 , fa_hierarchy_distributions ihd
                 , fa_additions a
              where fmd.asset_id = v_asset_attr_tab(i).asset_id
              and fmd.asset_id = a.asset_id
              and   fmd.date_ineffective is null
              and   ihd.dist_set_id = v_distribution_set_id_out
              and   ROUND(ihd.distribution_line_percentage, 2)
                          ||ihd.code_combination_id||ihd.location_id||ihd.assigned_to
                  = ROUND((fmd.units_assigned * 100/a.current_units), 2)
                          ||fmd.code_combination_id||fmd.location_id||fmd.assigned_to;
           end if;

           if ( (v_dist_count2 <> v_dist_count) AND (v_dist_count<> 0) ) then
           --CREATE NEW DISTRIBUTION;
           x_err_stage:= 'Insert_mass_update_batch_details: distribution_set';
           FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
              x_batch_id
            , x_book_type_code
            , 'DISTRIBUTION'
            , v_asset_attr_tab(i).asset_id
            , NULL -- x_attribute_old_id; old dist_set_id is passed as null
            , v_distribution_set_id_out
            , 'NODE' --x_derived_from_entity_type
            , g_derived_from_entity_rec.distribution
            , v_asset_attr_tab(i).parent_hierarchy_id_old
            , v_status_code
            , v_rejection_reason_code
            , 'Y' --x_apply_flag
            , NULL --x_effective_date
            , NULL --x_fa_period_name
            , v_conc_request_id
            , v_created_by
            , v_sysdate
            , v_last_updated_by
            , v_sysdate
            , v_last_update_login
            , x_err_code
            , x_err_stage
            , x_err_stack
            , p_log_level_rec);

          end if;
    end if;
    if(x_err_code <> '0') then
      return;
    end if;

  if ( v_derivation_type IN ('ALL', 'SERIAL_NUMBER') AND
       nvl(v_asset_attr_tab(i).serial_number,'0') <> nvl(v_serial_number_out,'0')) then
    x_err_stage:= 'Insert_mass_update_batch_details: serial_number';
    FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
             x_batch_id
           , x_book_type_code
           , 'SERIAL_NUMBER'
           , v_asset_attr_tab(i).asset_id
           , v_asset_attr_tab(i).serial_number
           , v_serial_number_out
           , 'NODE' --x_derived_from_entity_type
           , g_derived_from_entity_rec.serial_number
           , v_asset_attr_tab(i).parent_hierarchy_id_old
           , v_status_code
           , v_rejection_reason_code
           , 'Y' --x_apply_flag
           , NULL --x_effective_date
           , NULL --x_fa_period_name
           , v_conc_request_id
           , v_created_by
           , v_sysdate
           , v_last_updated_by
           , v_sysdate
           , v_last_update_login
           , x_err_code
           , x_err_stage
           , x_err_stack
           , p_log_level_rec);
   end if;
   if(x_err_code <> '0') then
      return;
    end if;

   if ( v_derivation_type IN ('ALL', 'ASSET_KEY') AND
        nvl(v_asset_attr_tab(i).asset_key_ccid,0)<> nvl(v_asset_key_ccid_out,0)) then
    x_err_stage:= 'Insert_mass_update_batch_details: asset_key';
    FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
             x_batch_id
           , x_book_type_code
           , 'ASSET_KEY'
           , nvl(v_asset_attr_tab(i).asset_id, 0)
           , to_char(nvl(v_asset_attr_tab(i).asset_key_ccid, 0))
           , to_char(nvl(v_asset_key_ccid_out, 0))
           , 'NODE' --x_derived_from_entity_type
           , g_derived_from_entity_rec.asset_key
           , v_asset_attr_tab(i).parent_hierarchy_id_old
           , v_status_code
           , v_rejection_reason_code
           , 'Y' --x_apply_flag
           , NULL --x_effective_date
           , NULL --x_fa_period_name
           , v_conc_request_id
           , v_created_by
           , v_sysdate
           , v_last_updated_by
           , v_sysdate
           , v_last_update_login
           , x_err_code
           , x_err_stage
           , x_err_stack
           , p_log_level_rec );
   end if;
   if(x_err_code <> '0') then
      return;
    end if;

  if ( v_derivation_type IN ('ALL', 'LEASE_NUMBER', 'LIFE_END_DATE') AND
       nvl(v_asset_attr_tab(i).life_in_months,0) <> nvl(v_life_in_months_out,0) ) then
    x_err_stage:= 'Insert_mass_update_batch_details: life_end_date';
    FA_CUA_DERIVE_ASSET_ATTR_PKG.insert_mass_update_batch_dtls(
             x_batch_id
           , x_book_type_code
           , 'LIFE_END_DATE'
           , nvl(v_asset_attr_tab(i).asset_id, 0)
           , to_char(nvl(v_asset_attr_tab(i).life_in_months, 0))
           , to_char(nvl(v_life_in_months_out, 0))
           , g_derived_from_entity_rec.lim_type --x_derived_from_entity_type
           , g_derived_from_entity_rec.life_in_months
           , v_asset_attr_tab(i).parent_hierarchy_id_old
           , v_status_code
           , v_rejection_reason_code
           , 'Y' --x_apply_flag
           , NULL --x_effective_date
           , NULL --x_fa_period_name
           , v_conc_request_id
           , v_created_by
           , v_sysdate
           , v_last_updated_by
           , v_sysdate
           , v_last_update_login
           , x_err_code
           , x_err_stage
           , x_err_stack
           , p_log_level_rec);

    end if;
    if(x_err_code <> '0') then
      return;
    end if;

  end loop;
  x_err_stack := v_old_err_stack;
EXCEPTION
  WHEN OTHERS THEN
   -- x_err_code:= sqlerrm;
   x_err_code:= substr(sqlerrm, 1, 240);
   return;
END generate_batch_transactions1;

-- ------------------------------------------------------
-- generate_batch_transactions: This is the wrapper to call
-- the original generate_batch_transactions, inorder to handle
-- tax books. The calling modules will always pass COPORATE
-- book.
-- ------------------------------------------------------
PROCEDURE generate_batch_transactions(
          x_event_code           IN     VARCHAR2
        , x_book_type_code       IN     VARCHAR2
        , x_src_entity_name      IN     VARCHAR2
        , x_src_entity_value     IN     VARCHAR2
        , x_src_attribute_name   IN     VARCHAR2
        , x_src_attr_value_from  IN     VARCHAR2
        , x_src_attr_value_to    IN     VARCHAR2
        , x_amortize_expense_flg IN     VARCHAR2
        , x_amortization_date    IN     DATE
        , x_batch_num            IN OUT NOCOPY VARCHAR2
        , x_batch_id             IN OUT NOCOPY NUMBER
        , x_transaction_name     IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category   IN     VARCHAR2 DEFAULT NULL
        , x_attribute1           IN     VARCHAR2 DEFAULT NULL
        , x_attribute2           IN     VARCHAR2 DEFAULT NULL
        , x_attribute3           IN     VARCHAR2 DEFAULT NULL
        , x_attribute4           IN     VARCHAR2 DEFAULT NULL
        , x_attribute5           IN     VARCHAR2 DEFAULT NULL
        , x_attribute6           IN     VARCHAR2 DEFAULT NULL
        , x_attribute7           IN     VARCHAR2 DEFAULT NULL
        , x_attribute8           IN     VARCHAR2 DEFAULT NULL
        , x_attribute9           IN     VARCHAR2 DEFAULT NULL
        , x_attribute10          IN     VARCHAR2 DEFAULT NULL
        , x_attribute11          IN     VARCHAR2 DEFAULT NULL
        , x_attribute12          IN     VARCHAR2 DEFAULT NULL
        , x_attribute13          IN     VARCHAR2 DEFAULT NULL
        , x_attribute14          IN     VARCHAR2 DEFAULT NULL
        , x_attribute15          IN     VARCHAR2 DEFAULT NULL
        , x_err_code             IN OUT NOCOPY VARCHAR2
        , x_err_stage            IN OUT NOCOPY VARCHAR2
        , x_err_stack            IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) IS

 CURSOR c_books IS
   select book_type_code
   from fa_book_controls
   where ( (book_type_code = x_book_type_code)
   OR (distribution_source_book = x_book_type_code) )
   and book_class IN ( 'CORPORATE', 'TAX')
   order by book_class;

   v_call_flag VARCHAR2(1);

BEGIN

 if x_event_code IN( 'CHANGE_NODE_PARENT'
                    , 'CHANGE_NODE_RULE_SET'
                    , 'CHANGE_ASSET_PARENT'
                    , 'CHANGE_ASSET_CATEGORY'
                    , 'CHANGE_CATEGORY_RULE_SET'
                    , 'HR_MASS_TRANSFER'
                    ,  'CHANGE_ASSET_LEASE'
                    , 'CHANGE_LEASE_LIFE_END_DATE' ) then
        G_multi_books_flg := 'Y';
  elsif ( x_event_code = 'CHANGE_NODE_ATTRIBUTE' ) then
      if x_src_attribute_name IN ( 'CATEGORY', 'DATE_PLACED_IN_SERVICE' ) then
        G_multi_books_flg := 'Y';
      end if;
  end if;

  if ( G_multi_books_flg = 'Y' ) then
     -- generate transaction for each book under the
     -- passed in corporate_book
     for book_rec IN c_books LOOP
       generate_batch_transactions1( x_event_code
                                  , book_rec.book_type_code
                                  , x_src_entity_name
                                  , x_src_entity_value
                                  , x_src_attribute_name
                                  , x_src_attr_value_from
                                  , x_src_attr_value_to
                                  , x_amortize_expense_flg
                                  , x_amortization_date
                                  , x_batch_num
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
                                  , x_attribute15
                                  , x_err_code
                                  , x_err_stage
                                  , x_err_stack
                                  , p_log_level_rec);
      end LOOP;
    else
      generate_batch_transactions1( x_event_code
                                  , x_book_type_code
                                  , x_src_entity_name
                                  , x_src_entity_value
                                  , x_src_attribute_name
                                  , x_src_attr_value_from
                                  , x_src_attr_value_to
                                  , x_amortize_expense_flg
                                  , x_amortization_date
                                  , x_batch_num
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
                                  , x_attribute15
                                  , x_err_code
                                  , x_err_stage
                                  , x_err_stack
                                  , p_log_level_rec);
    end if;

-- do this if not called from conc_process
-- otherwise do it in process_conc_request procedure
if G_conc_process <> 'Y' then
    if fa_cua_asset_wb_apis_pkg.check_batch_details_exists(x_batch_id, p_log_level_rec => p_log_level_rec) then
       null;
    else
       update fa_mass_update_batch_headers
       set status_code = 'CP'
       where batch_id = x_batch_id;
    end if;
end if;

 END generate_batch_transactions;


-- ------------------------------------
PROCEDURE wrapper_derive_asset_attribute
(p_log_level_rec       IN     fa_api_types.log_level_rec_type default null) IS
Begin
  derive_asset_attribute(
  FA_CUA_ASSET_APIS.g_book_type_code
, FA_CUA_ASSET_APIS.g_parent_node_id
, FA_CUA_ASSET_APIS.g_asset_number
, FA_CUA_ASSET_APIS.g_asset_id
, FA_CUA_ASSET_APIS.g_prorate_date
, FA_CUA_ASSET_APIS.g_cat_id_in
, FA_CUA_ASSET_APIS.g_cat_id_out
, FA_CUA_ASSET_APIS.g_cat_overide_allowed
, FA_CUA_ASSET_APIS.g_cat_rejection_flag
, FA_CUA_ASSET_APIS.g_lease_id_in
, FA_CUA_ASSET_APIS.g_lease_id_out
, FA_CUA_ASSET_APIS.g_lease_overide_allowed
, FA_CUA_ASSET_APIS.g_lease_rejection_flag
, NULL   -- distribution_set_id_in
, FA_CUA_ASSET_APIS.g_distribution_set_id_out
, FA_CUA_ASSET_APIS.g_distribution_overide_allowed
, FA_CUA_ASSET_APIS.g_distribution_rejection_flag
, FA_CUA_ASSET_APIS.g_serial_number_in
, FA_CUA_ASSET_APIS.g_serial_number_out
, FA_CUA_ASSET_APIS.g_serial_num_overide_allowed
, FA_CUA_ASSET_APIS.g_serial_num_rejection_flag
, FA_CUA_ASSET_APIS.g_asset_key_ccid_in
, FA_CUA_ASSET_APIS.g_asset_key_ccid_out
, FA_CUA_ASSET_APIS.g_asset_key_overide_allowed
, FA_CUA_ASSET_APIS.g_asset_key_rejection_flag
, FA_CUA_ASSET_APIS.g_life_in_months_in
, FA_CUA_ASSET_APIS.g_life_in_months_out
, FA_CUA_ASSET_APIS.g_life_end_dte_overide_allowed
, FA_CUA_ASSET_APIS.g_life_rejection_flag
, FA_CUA_ASSET_APIS.g_err_code
, FA_CUA_ASSET_APIS.g_err_stage
, FA_CUA_ASSET_APIS.g_err_stack
, FA_CUA_ASSET_APIS.g_derivation_type
, p_log_level_rec );
End;

PROCEDURE initialize_Gvariables
(p_log_level_rec       IN     fa_api_types.log_level_rec_type default null) IS
Begin
  FA_CUA_ASSET_APIS.g_book_type_code := NULL;
  FA_CUA_ASSET_APIS.g_parent_node_id := NULL;
  FA_CUA_ASSET_APIS.g_asset_number := NULL;
  FA_CUA_ASSET_APIS.g_asset_id := NULL;
  FA_CUA_ASSET_APIS.g_prorate_date := NULL;
  FA_CUA_ASSET_APIS.g_cat_id_in := NULL;
  FA_CUA_ASSET_APIS.g_cat_id_out := NULL;
  FA_CUA_ASSET_APIS.g_cat_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_cat_rejection_flag := NULL;
  FA_CUA_ASSET_APIS.g_lease_id_in := NULL;
  FA_CUA_ASSET_APIS.g_lease_id_out := NULL;
  FA_CUA_ASSET_APIS.g_lease_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_lease_rejection_flag := NULL;
  --FA_CUA_ASSET_APIS.g_distribution_set_id_in := NULL;
  FA_CUA_ASSET_APIS.g_distribution_set_id_out := NULL;
  FA_CUA_ASSET_APIS.g_distribution_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_distribution_rejection_flag := NULL;
  FA_CUA_ASSET_APIS.g_serial_number_in := NULL;
  FA_CUA_ASSET_APIS.g_serial_number_out := NULL;
  FA_CUA_ASSET_APIS.g_serial_num_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_serial_num_rejection_flag := NULL;
  FA_CUA_ASSET_APIS.g_asset_key_ccid_in := NULL;
  FA_CUA_ASSET_APIS.g_asset_key_ccid_out := NULL;
  FA_CUA_ASSET_APIS.g_asset_key_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_asset_key_rejection_flag := NULL;
  FA_CUA_ASSET_APIS.g_life_in_months_in := NULL;
  FA_CUA_ASSET_APIS.g_life_in_months_out := NULL;
  FA_CUA_ASSET_APIS.g_life_end_dte_overide_allowed := NULL;
  FA_CUA_ASSET_APIS.g_life_rejection_flag := NULL;
  FA_CUA_ASSET_APIS.g_err_code := NULL;
  FA_CUA_ASSET_APIS.g_err_stage := NULL;
  FA_CUA_ASSET_APIS.g_err_stack := NULL;
  FA_CUA_ASSET_APIS.g_derivation_type := NULL;
End initialize_Gvariables;

PROCEDURE Purge(errbuf              OUT NOCOPY  VARCHAR2,
                retcode             OUT NOCOPY  VARCHAR2,
                x_book_type_code    IN VARCHAR2,
                x_batch_id          IN NUMBER ) IS
    Cursor C1 is
    select batch_id
    from fa_mass_update_batch_headers
    where book_type_code = x_book_type_code
    and   batch_id = nvl(x_batch_id, batch_id)
    and status_code = 'C'
    for update NOWAIT;

  BEGIN

      For C1_rec in C1 loop

          Delete from fa_mass_update_batch_details
          where batch_id = C1_rec.batch_id;

          Delete from fa_mass_update_batch_headers
          where batch_id = C1_rec.batch_id;

       End Loop;
       commit;

  EXCEPTION
    When NO_DATA_FOUND Then
      Return;

  WHEN OTHERS THEN
      errbuf  :=  SQLERRM(SQLCODE);
      retcode := SQLCODE;
      return;
END PURGE;


/* -----------------------------------------------------
   This function returns TRUE if override is allowed
   for the attribute, else returns FALSE.
   Valid Attribute Names are: CATEGORY, DISTRIBUTION,
                              SERIAL_NUMBER, ASSET_KEY,
                              LIFE_END_DATE,LEASE_NUMBER
   --------------------------------------------------- */
FUNCTION check_override_allowed(
               p_attribute_name in varchar2,
               p_book_type_code in varchar2,
               p_asset_id       in number,
               x_override_flag  out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) return boolean IS

CURSOR c_get_parent_id IS
 select parent_hierarchy_id
 from fa_asset_hierarchy
 where asset_id = p_asset_id;

v_parent_id number;
v_asset_cat_id number;
l_err_stage varchar2(600);
BEGIN

  if p_attribute_name NOT IN ( 'CATEGORY', 'DISTRIBUTION',
                               'SERIAL_NUMBER', 'ASSET_KEY',
                               'LIFE_END_DATE', 'LEASE_NUMBER' ) then
     return FALSE;
  end if;

  l_err_stage:= 'c_get_parent_id';
  --dbms_output.put_line(l_err_stage);

  Open c_get_parent_id;
  Fetch c_get_parent_id into v_parent_id;
  Close c_get_parent_id;

  if(nvl(v_parent_id,0) = 0 ) then -- Asset Not Linked to Hierarchy
     return TRUE;
  end if;

  l_err_stage:= 'get asset_category_id';
  --dbms_output.put_line(l_err_stage);
  select asset_category_id
  into v_asset_cat_id
  from fa_additions
  where asset_id = p_asset_id;

  initialize_Gvariables;
  if p_attribute_name = 'CATEGORY' then
    FA_CUA_ASSET_APIS.g_derivation_type := 'ALL';
  else
    FA_CUA_ASSET_APIS.g_derivation_type := p_attribute_name;
  end if;

  FA_CUA_ASSET_APIS.g_book_type_code := p_book_type_code;
  FA_CUA_ASSET_APIS.g_parent_node_id := v_parent_id;
  FA_CUA_ASSET_APIS.g_cat_id_in:= v_asset_cat_id;
  FA_CUA_ASSET_APIS.g_asset_id:= p_asset_id;
  FA_CUA_ASSET_APIS.g_err_code := '0';

  l_err_stage:= 'wrapper_derive_asset_attribute';
  --dbms_output.put_line(l_err_stage);
  FA_CUA_ASSET_APIS.wrapper_derive_asset_attribute;

  --dbms_output.put_line(FA_CUA_ASSET_APIS.g_err_code);
  --dbms_output.put_line(FA_CUA_ASSET_APIS.g_err_stack);
  --dbms_output.put_line(FA_CUA_ASSET_APIS.g_err_stage);

  if ( FA_CUA_ASSET_APIS.g_err_code <> '0') then
     FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_CUA_ASSET_APIS.check_override_allowed',
                NAME => FA_CUA_ASSET_APIS.g_err_code , p_log_level_rec => p_log_level_rec);
     return FALSE;
  end if;

  if p_attribute_name = 'CATEGORY' then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_cat_overide_allowed,'Y');

  elsif p_attribute_name = 'LEASE_NUMBER'then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_lease_overide_allowed, 'Y');

  elsif p_attribute_name = 'DISTRIBUTION' then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_distribution_overide_allowed, 'Y');

  elsif p_attribute_name = 'SERIAL_NUMBER' then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_serial_num_overide_allowed, 'Y');

  elsif p_attribute_name = 'ASSET_KEY' then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_asset_key_overide_allowed,'Y');

  elsif p_attribute_name = 'LIFE_END_DATE' then
      x_override_flag := nvl(FA_CUA_ASSET_APIS.g_life_end_dte_overide_allowed, 'Y');
  end if;

  return TRUE;
EXCEPTION
  when others then
    FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_CUA_ASSET_APIS.check_override_allowed', p_log_level_rec => p_log_level_rec);
    return FALSE;

END check_override_allowed;


END FA_CUA_ASSET_APIS;

/
