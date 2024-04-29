--------------------------------------------------------
--  DDL for Package Body FA_CUA_ASSET_WB_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_ASSET_WB_APIS_PKG" AS
/* $Header: FACHRAWMB.pls 120.3.12010000.2 2009/07/19 12:31:10 glchen ship $*/

FUNCTION Is_CRLFA_Enabled RETURN  Boolean
IS
BEGIN
   if fnd_profile.value('CRL-FA ENABLED') = 'Y' then
      return true;
   else
      return false;
   end if;

END Is_CRLFA_Enabled;

FUNCTION Get_book_type_code RETURN  VARCHAR2
IS
BEGIN

        RETURN ( g_book_type_code );
END Get_book_type_code;

Procedure put_book_type_code (v_book_type_code in VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
IS
BEGIN

	g_book_type_code := v_book_type_code;
END put_book_type_code;

Procedure put_asset_id (v_asset_id in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
IS
BEGIN

	g_life_asset_id := v_asset_id;
END put_asset_id;


FUNCTION Get_asset_id RETURN NUMBER
IS
BEGIN

	RETURN ( g_life_asset_id );
END Get_asset_id;

Procedure put_transaction_id (v_transaction_id in NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
IS
BEGIN

	g_transaction_id := v_transaction_id;
END put_transaction_id;


FUNCTION Get_transaction_id RETURN NUMBER
IS
BEGIN

	RETURN ( g_transaction_id );
END Get_transaction_id;

PROCEDURE create_node( x_asset_hierarchy_purpose_id in out nocopy number
	                   , x_asset_hierarchy_id       in out nocopy number
	                   , x_name                     in varchar2
	                   , x_hierarchy_rule_set_id    in out nocopy number
                       , x_parent_hierarchy_id      in out nocopy number
                       , x_asset_id                 in out nocopy number
                       , x_err_code                  in out nocopy varchar2
		               , x_err_stage                 in out nocopy varchar2
                       , x_err_stack                 in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)IS


   BEGIN
     fa_cua_hierarchy_pkg.create_node(x_asset_hierarchy_purpose_id=>x_asset_hierarchy_purpose_id,
                                   x_asset_hierarchy_id => x_asset_hierarchy_id,
                                   x_name => x_name,
                                   x_level_number => 0,
                                   x_hierarchy_rule_set_id=>x_hierarchy_rule_set_id,
                                   x_parent_hierarchy_id => x_parent_hierarchy_id,
                                   x_asset_id => x_asset_id,
                                   x_err_code => x_err_code,
                                   x_err_stage => x_err_stage,
                                   x_err_stack => x_err_stack, p_log_level_rec => p_log_level_rec);
  End create_node;


Procedure get_asset_parent (x_asset_id in number,
                            x_parent_hierarchy_id in out nocopy number,
                            x_parent_hierarchy_name in out nocopy varchar2,
                            x_asset_purpose_id in out nocopy number,
                            x_asset_purpose_name in out nocopy varchar2,
                            x_purpose_book_type_code in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is


v_corp_book varchar2(30);

Cursor c_1 is
  select bc.book_type_code
  from fa_books bk, fa_book_controls bc
  where bc.book_class = 'CORPORATE'
  and bk.asset_id = X_Asset_Id
  and bk.book_type_code = bc.book_type_code
  and bk.date_ineffective is null;

Cursor c_2 is
  select asset_hierarchy_purpose_id
         ,name
  from   fa_asset_hierarchy_purpose
  where  book_type_code = v_corp_book
  and    purpose_type = 'INHERITANCE';

Cursor c_3 is
  select parent_hierarchy_id
  from   fa_asset_hierarchy
  where  asset_id = x_asset_id
  and    asset_hierarchy_purpose_id = x_asset_purpose_id;

Cursor c_4 is
  select name
  from fa_asset_hierarchy
  where asset_hierarchy_id = x_parent_hierarchy_id;


 Begin

   open c_1;
   fetch c_1 into x_purpose_book_type_code;
   close c_1;

   v_corp_book:= x_purpose_book_type_code;
   open c_2;
   fetch c_2    into   x_asset_purpose_id, x_asset_purpose_name;
   close c_2;

   open c_3;
   fetch c_3 into x_parent_hierarchy_id;
   close c_3;

   open c_4;
   fetch c_4 into x_parent_hierarchy_name;
   close c_4;


End get_asset_parent;

Function get_category_id (x_concatenated_segments in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return number is
  cursor c is
  select category_id
  from fa_categories_b_kfv
  where concatenated_segments = x_concatenated_segments;

  v_category_id number;
begin
  open c;
  fetch c into v_category_id ;
  close c;
  return v_category_id;
end get_category_id;

Function get_category_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
  cursor c is
  select concatenated_segments
  from fa_categories_b_kfv
  where category_id = x_id;

  v_concatenated_segments fa_categories_b_kfv.concatenated_segments%type;
begin
  open c;
  fetch c into v_concatenated_segments;
  close c;
  return v_concatenated_segments;
end get_category_name;


Function get_asset_key_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  select concatenated_segments
  from fa_asset_keywords_kfv
  where code_combination_id = x_id;

  v_concatenated_segments fa_asset_keywords_kfv.concatenated_segments%type;
begin
  open c;
  fetch c into v_concatenated_segments;
  close c;
  return v_concatenated_segments;
end get_asset_key_name;

Function get_location_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  select concatenated_segments
  from fa_locations_kfv
  where location_id = x_id;

  v_concatenated_segments fa_locations_kfv.concatenated_segments%type;
begin
  open c;
  fetch c into v_concatenated_segments;
  close c;
  return v_concatenated_segments;
end get_location_name;

Function get_account_code_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  select concatenated_segments
  from gl_code_combinations_kfv
  where code_combination_id = x_id;

  v_concatenated_segments gl_code_combinations_kfv.concatenated_segments%type;
begin
  open c;
  fetch c into v_concatenated_segments;
  close c;
  return v_concatenated_segments;
end get_account_code_name;


Function get_employee_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  select name
  from fa_employees
  where employee_id = x_id;

  v_name fa_employees.name%type;

 begin
  open c;
  fetch c into v_name;
  close c;
  return v_name;
end get_employee_name;

Function get_employee_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  select employee_number
  from fa_employees
  where employee_id = x_id;

  v_employee_number fa_employees.employee_number%type;

 begin
  open c;
  fetch c into v_employee_number;
  close c;
  return v_employee_number;
end get_employee_number;

Function get_lease_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is

 v_lease_number fa_leases.lease_number%type;
 cursor c is
  select lease_number
  from fa_leases
  where lease_id = x_id;
Begin
  open c;
  fetch c into v_lease_number;
  close c;

  return v_lease_number;
End get_lease_number;

Function get_lease_id (x_lease_number in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return number is

 v_lease_id number ;
 cursor c is
  select lease_id
  from fa_leases
  where lease_number = x_lease_number;
Begin
  open c;
  fetch c into v_lease_id;
  close c;

  return v_lease_id;
End get_lease_id;

Function derive_override_flag(x_rule_set_id in number,
                              x_attribute_name in varchar2,
                              x_book_type_code in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2 is
cursor c is
  SELECT override_allowed_flag
  FROM FA_HIERARCHY_RULE_DETAILS
  WHERE hierarchy_rule_set_id = x_rule_set_id
  AND   attribute_name = x_attribute_name
  AND   book_type_code = x_book_type_code;
  v_dummy            FA_HIERARCHY_RULE_DETAILS.override_allowed_flag%type  ;
Begin
  open c;
  fetch c into v_dummy;
  close c;
  return nvl(v_dummy,'Y');
End derive_override_flag;

Function check_distribution_match(x_Asset_id in number,
                                  x_book_type_code in varchar2,
                                  x_mode in varchar2 default 'SHOWERR', p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean is


  h_dist_count number;
  h_dist_count2 number;
  h_dist_count3 number;
  v_hierarchy_node_id number;
  v_hierarchy_node varchar2(100);
  v_hierarchy_purpose_id number;
  v_hierarchy_purpose varchar2(100);
  x_dist_set_id number;
  v_book_type_code varchar2(30);
Begin

  v_book_type_code := x_book_type_code;
  fa_cua_asset_wb_apis_pkg.get_asset_parent(x_asset_id,
                                         v_hierarchy_node_id,
                                         v_hierarchy_node,
                                         v_hierarchy_purpose_id,
                                         v_hierarchy_purpose,
                                         v_book_type_code, p_log_level_rec => p_log_level_rec);
    if(nvl(v_hierarchy_node_id,0) = 0 ) then -- Asset Not Linked to Hierarchy
        return true;
    end if;

      FA_CUA_ASSET_APIS.g_book_type_code := v_book_type_code;
      FA_CUA_ASSET_APIS.g_parent_node_id := v_hierarchy_node_id;
      FA_CUA_ASSET_APIS.g_asset_id:= x_asset_id;
      FA_CUA_ASSET_APIS.g_derivation_type := 'DISTRIBUTION';
      FA_CUA_ASSET_APIS.g_err_code := '0';

      FA_CUA_ASSET_APIS.wrapper_derive_asset_attribute;

      x_dist_set_id := FA_CUA_ASSET_APIS.g_distribution_set_id_out;
     if (x_mode = 'SHOWMSG') and (FA_CUA_ASSET_APIS.g_distribution_overide_allowed = 'N') then
       return false;
     end if;

     if (FA_CUA_ASSET_APIS.g_distribution_overide_allowed = 'N') and ( x_mode = 'SHOWERR') then

      select count(*) into h_dist_count
      from fa_distribution_history
      where asset_id = x_Asset_id
      and book_type_code = v_book_type_code
      and  date_ineffective is null;

      select count(*) into h_dist_count2
      from fa_hierarchy_distributions
      where dist_set_id = x_dist_set_id;

      if h_dist_count <> 0 then

 	  select count(*)
	  into h_dist_count3
	  from fa_distribution_history fdh ,fa_hierarchy_distributions ihd,fa_additions fa
	  where  fa.asset_id = x_Asset_id
	  and    fdh.asset_id = x_Asset_id
	  and   fdh.date_ineffective is null
          and   fdh.book_type_code = v_book_type_code
	  and   ihd.dist_set_id = x_dist_set_id
	  and   ihd.code_combination_id||ihd.location_id||ihd.assigned_to||ihd.distribution_line_percentage
	       = fdh.code_combination_id||fdh.location_id||fdh.assigned_to||round(fdh.units_assigned/fa.current_units,2)*100;
       if h_dist_count3 <> h_dist_count2 then
	     return false;
       else
	     return true;
       end if;

       elsif h_dist_count = 0 then
         return true;
       end if;

    else
     return true;
    end if;
end check_distribution_match;

Function get_node_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2
is
v_node_name fa_asset_hierarchy.name%type;
 cursor c is
  select name
  from fa_asset_hierarchy
  where asset_hierarchy_id = x_id;
Begin
  open c;
  fetch c into v_node_name;
  close c;

  return v_node_name;
End get_node_name;

Function get_node_level (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2
is
v_node_level fa_asset_hierarchy.level_number%type;
 cursor c is
  select level_number
  from fa_asset_hierarchy
  where asset_hierarchy_id = x_id;
Begin
  open c;
  fetch c into v_node_level;
  close c;

  return to_char(v_node_level);
End get_node_level;

Function get_rule_set_name (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2
is
v_rule_set_name fa_hierarchy_rule_set.name%type;
 cursor c is
  select name
  from fa_hierarchy_rule_set
  where hierarchy_rule_set_id = x_id;
Begin
  open c;
  fetch c into v_rule_set_name;
  close c;

  return v_rule_set_name;
End get_rule_set_name;

Function get_asset_number (x_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return varchar2
is
v_asset_number fa_additions.asset_number%TYPE;
 cursor C is
 select asset_number
 from fa_additions
 where asset_id = x_id;
Begin
 open C;
 fetch C into v_asset_number;
 close C;

 return v_asset_number;
End get_asset_number;

Function check_batch_details_exists(x_batch_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
return boolean
is
dummy	number;
Begin
  select 1 into dummy
  from dual
  where exists(select 'X' from fa_mass_update_batch_details
               where batch_id = x_batch_id);
  return TRUE;
Exception
  when no_data_found then
    return FALSE;
End check_batch_details_exists;

Function check_deprn_method(x_cat_id in varchar2, x_book_type_code in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return boolean
is
v_dummy varchar2(20);
 cursor c is
  select rate_source_rule
  from fa_methods a, fa_category_book_defaults b
  where b.category_id = x_cat_id
  and book_type_code = x_book_type_code
  and a.method_code = b.deprn_method
  and ( trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate) ) );
Begin
  open c;
  fetch c into v_dummy;
  close c;

  if v_dummy <> 'CALCULATED' then
    return false;
  else
    return true;
  end if;
End check_deprn_method;

FUNCTION GET_PERIOD_END_DATE(X_book_type_code  VARCHAR2,
		             x_date             DATE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) return date IS
CURSOR C IS
select (cp.end_date)
from fa_calendar_periods cp,
    fa_calendar_types ct,
    fa_book_controls bc
where bc.book_type_code = X_book_type_code and
     bc.date_ineffective is null and
     ct.calendar_type = bc.prorate_calendar  and
     cp.calendar_type = ct.calendar_type and
     x_date between cp.start_date and cp.end_date;

v_end_date date;
Begin
  open c;
  fetch c into v_end_date;
  close c;

  return nvl(v_end_date,x_date);
End GET_PERIOD_END_DATE;

Procedure get_prorate_date ( x_category_id in number,
                             x_book        in varchar2,
                             x_deprn_start_date in date,
                             x_prorate_date out nocopy date
			    ,x_err_code    in out nocopy varchar2
                            ,x_err_stage   in out nocopy varchar2
                            ,x_err_stack   in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
is
   CURSOR C is
        select prorate_convention_code
        from fa_category_book_defaults
        where category_id = x_category_id
        and book_type_code = x_book
        and ( trunc(sysdate) between start_dpis and nvl(end_dpis, trunc(sysdate)) );
   l_prorate_convention   varchar2(10);
   l_old_err_stack        varchar2(240);
   CURSOR C1(x_prorate_conv in varchar2) IS
           select  conv.prorate_date
           from    fa_conventions conv
           where   conv.prorate_convention_code = x_prorate_conv
           and     x_deprn_start_date
           between conv.start_date and conv.end_date;
   l_prorate_date  date;
Begin
  l_old_err_stack := x_err_stack;
  x_err_code := '0';
  x_err_stack := x_err_stack || 'GET_PRORATE_DATE';
  x_err_stage := 'Getting Prorate Convention';
  open C;
  fetch C into l_prorate_convention;
  close C;
  x_err_stage := 'Getting Prorate Date';
  open C1(l_prorate_convention);
  fetch C1 into l_prorate_date;
  close C1;
  x_prorate_date := l_prorate_date;
  x_err_stack := l_old_err_stack;
Exception
  when others then
    x_err_code := sqlerrm;
End get_prorate_date;


Procedure get_life_derivation_info(x_asset_id in number,
                                   x_book_type_code varchar2,
                                   x_transaction_id number,
                                   x_derived_from_entity in out nocopy varchar2 ,
                                   x_derived_from_entity_name in out nocopy varchar2,
                                   x_level_number in out nocopy varchar2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
x_derived_from_entity_id number;
cursor c is
 Select fl.meaning, decode(derived_from_entity,
                           'NODE', FA_CUA_ASSET_WB_APIS_PKG.get_node_name(derived_from_entity_id),
                           'NODE-P', FA_CUA_ASSET_WB_APIS_PKG.get_node_name(derived_from_entity_id),
			   'CATEGORY-LED', FA_CUA_ASSET_WB_APIS_PKG.get_category_name(derived_from_entity_id),
			   'CATEGORY-LIFE', FA_CUA_ASSET_WB_APIS_PKG.get_category_name(derived_from_entity_id),
		            'LEASE', FA_CUA_ASSET_WB_APIS_PKG.get_lease_number(derived_from_entity_id),
			   'ASSET', FA_CUA_ASSET_WB_APIS_PKG.get_asset_number(derived_from_entity_id),
			                null  ), derived_from_entity_id
   from   fa_life_derivation_info, fa_lookups fl
   where asset_id =x_asset_id
   and book_type_code = x_book_type_code
   and transaction_header_id = (select max(transaction_header_id)
                           from fa_life_derivation_info
                           where asset_id =x_asset_id
                           and book_type_code = x_book_type_code
                           and transaction_header_id = nvl(x_transaction_id,
                                                           transaction_header_id))
   and     (derived_from_entity = fl.lookup_code
                 AND fl.lookup_type  = 'IFA_HR_SRC_ENTITY_NAME');

Begin
   open c;
   fetch c into x_derived_from_entity,  x_derived_from_entity_name,x_derived_from_entity_id;
   close c;

   if  upper(x_derived_from_entity) like '%NODE%' then
     select level_number
     into x_level_number
     from fa_asset_hierarchy
     where asset_hierarchy_id = x_derived_from_entity_id;
   end if;

 End get_life_derivation_info;

Procedure remove_adjustments (x_asset_id in number,
                              x_book_type_code in varchar2,
                              x_thid in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS
BEGIN

  /* To be called when processing an asset reclassification (category change):
     For group member assets, the source and destination assets reserve
     balances should not be adjusted.  For assets added in the current period,
     the calling procedure has been modifed to simply not call the user exit
     which creates those adjustments.  For assets added in a prior period however
     we still need to make cost adjustments, which must be spread acoross the
     distributions for the asset.  To avoid re-writing the code that creates those
     cost adjustments, we allow the user exit to run, which creates the necessary
     cost adjustments, but also creates reserve adjustments.  The purpose of this
     procedure is to clear out those adjustments which are not required for group assets.
  */

  delete from FA_ADJUSTMENTS
  where ASSET_ID              = x_asset_id
  and   BOOK_TYPE_CODE        = x_book_type_code
  and   TRANSACTION_HEADER_ID = x_thid
  and   ADJUSTMENT_TYPE       not in ('COST', 'COST CLEARING');

END remove_adjustments;

END FA_CUA_ASSET_WB_APIS_PKG;

/
