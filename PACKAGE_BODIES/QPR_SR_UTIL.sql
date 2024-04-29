--------------------------------------------------------
--  DDL for Package Body QPR_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_SR_UTIL" AS
/* $Header: QPRUTILB.pls 120.6 2008/03/12 12:57:35 amjha ship $ */

  g_ref_uom VARCHAR2(10);
  g_ref_item_id NUMBER;
  g_ref_uom_conv_rate NUMBER;
  g_ods_from_uom varchar2(30);
  g_ods_to_uom varchar2(30);
  g_ods_ref_uom_crate number;
  g_ods_uom_inst_id number;
  g_uom_conv_in_ods varchar2(1);
  g_curr_conv_in_ods varchar2(10);
  g_ods_curr_inst_id number;
  g_from_currency_code varchar2(30);
  g_ods_rate_type varchar2(40);
  g_to_currency_code varchar2(30);
  g_ods_curr_date date;
  g_ods_curr_rate number;
  g_ods_ref_item_id number;
  g_ref_curr varchar2(30);
  g_ref_curr_date date;
  g_ref_global_curr_code varchar2(30);
  g_curr_conv_rate number;
  g_global_currency_code varchar2(40);
  g_global_rate_type varchar2(40);
  g_ref_cust_attr varchar2(30);
  g_base_item number;
  g_uom_instance number;
  g_ref_base_uom varchar2(10);
  g_master_uom varchar2(10);
  g_load_curr_no_conv varchar2(1);
  g_load_uom_no_conv varchar2(1) ;
  g_master_org number;
  g_b_cust_attr_read number := 0;

/* Public Constants */
NULL_VALUE_CONST constant varchar2(10) := 'Other';
NULL_VALUE_PK_CONST constant number := -777;
ALL_CHANNELS_CONST constant varchar(20) := 'All Channels';
ALL_CHANNELS_PK_CONST constant number := -5 ;
ALL_GEOGRAPHY_CONST constant varchar(20) := 'All Geography';
ALL_GEOGRAPHY_PK_CONST constant number := -3 ;
ALL_ORGANIZATIONS_CONST constant varchar(20) := 'All Organizations';
ALL_ORGANIZATIONS_PK_CONST constant number := -2 ;
ALL_PRODUCTS_CONST constant varchar(20) := 'All Products';
ALL_PRODUCTS_PK_CONST constant number := -1 ;
ALL_SALESREP_CONST constant varchar(20) := 'All Sales Rep';
ALL_SALESREP_PK_CONST constant number := -4 ;

ALL_ORDER_CONST constant varchar(20) := 'All Orders ';
ALL_ORDER_PK_CONST constant number := -6 ;
ALL_ADJUSTMENT_CONST constant varchar(20) := 'All Adjustments ';
ALL_ADJUSTMENT_PK_CONST constant number := -7 ;
ALL_CUSTOMER_CONST constant varchar(20) := 'All Customers ';
ALL_CUSTOMER_PK_CONST constant number := -8 ;

ALL_VOL_BAND_CONST constant varchar(20) := 'All Volume Bands ';
ALL_VOL_BAND_PK_CONST constant number := -11 ;
ALL_DSC_BAND_CONST constant varchar(20) := 'All Discount Bands ';
ALL_DSC_BAND_PK_CONST constant number := -12 ;
ALL_MRG_BAND_CONST constant varchar(20) := 'All Margin Bands ';
ALL_MRG_BAND_PK_CONST constant number := -13 ;

ALL_OFFADJ_CONST constant varchar(30) := 'All Off Invoice Adjustments';
ALL_OFFADJ_PK_CONST constant number := -14 ;
ALL_COST_CONST constant varchar(20) := 'All Costs';
ALL_COST_PK_CONST constant number := -15 ;

ALL_PSG_CONST constant varchar(30) := 'All Pricing Segments';
ALL_PSG_PK_CONST constant number := -17 ;

ALL_YEAR_CONST constant varchar2(30) := 'All Years';
ALL_YEAR_PK_CONST constant number := -18;

OAD_OM_GROUP_CONST constant varchar2(30) := 'SERVICES';
OAD_AR_GROUP_CONST constant varchar2(30) := 'PROMOTIONS';
OAD_OM_TYPE_CONST constant varchar2(30) := 'SHIPPING';
OAD_AR_CM_TYPE_CONST constant varchar2(30) := 'REBATE';
OAD_AR_CD_TYPE_CONST constant varchar2(30) := 'PAYMENT';

C_YES constant number := 1;
C_NO  constant number := 2;


/* BOM ITEM TYPE */
C_MODEL           constant number := 1;
C_OPTION_CLASS    constant number := 2;
C_PLANNING        constant number := 3;
C_STANDARD        constant number := 4;
C_PRODUCT_FAMILY  constant number := 5;


-- Public Functions

function get_null_pk return number IS
BEGIN
 return NULL_VALUE_PK_CONST;
END;

function get_null_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('QPR_DIM_ALL_DESC','OTH');
END;

function get_all_scs_pk return number IS
BEGIN
 return ALL_CHANNELS_PK_CONST ;
END;

function get_all_scs_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','CHN');
END;

function get_all_cus_pk return number IS
BEGIN
 return ALL_CUSTOMER_PK_CONST ;
END;

function get_all_cus_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('QPR_DIM_ALL_DESC','CUS');
END;

function get_all_geo_pk return number IS
BEGIN
 return ALL_GEOGRAPHY_PK_CONST ;
END;

function get_all_geo_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('QPR_DIM_ALL_DESC','GEO');
END;

function get_all_org_pk return number IS
BEGIN
 return ALL_ORGANIZATIONS_PK_CONST ;
END;

function get_all_org_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('QPR_DIM_ALL_DESC','ORG');
END;

function get_all_prd_pk return number IS
BEGIN
 return ALL_PRODUCTS_PK_CONST ;
END;

function get_all_prd_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','PRD');
END;

function get_all_rep_pk return number IS
BEGIN
 return ALL_SALESREP_PK_CONST ;
END;

function get_all_rep_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','REP');
END;

function get_all_ord_pk return number IS
BEGIN
 return ALL_ORDER_PK_CONST ;
END;

function get_all_ord_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','ORD');
END;

function get_all_adj_pk return number IS
BEGIN
 return ALL_ADJUSTMENT_PK_CONST ;
END;

function get_all_adj_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','ADJ');
END;

function get_all_dsb_pk return number IS
BEGIN
 return ALL_DSC_BAND_PK_CONST ;
END;

function get_all_vlb_pk return number IS
BEGIN
 return ALL_VOL_BAND_PK_CONST ;
END;

function get_all_oad_pk return number IS
BEGIN
 return ALL_OFFADJ_PK_CONST ;
END;

function get_all_cos_pk return number IS
BEGIN
 return ALL_COST_PK_CONST ;
END;

function get_all_mgb_pk return number IS
BEGIN
 return ALL_MRG_BAND_PK_CONST ;
END;

function get_all_psg_pk return number IS
BEGIN
 return ALL_PSG_PK_CONST ;
END;

function get_all_year_pk return number IS
BEGIN
 return ALL_YEAR_PK_CONST ;
END;

function get_all_dsb_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','DSB');
END;

function get_all_vlb_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','VLB');
END;

function get_all_mgb_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','MGB');
END;

function get_all_oad_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','OAD');
END;

function get_all_cos_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','COS');
END;

function get_all_psg_desc return VARCHAR2 IS
BEGIN
  return get_dimension_desc('QPR_DIM_ALL_DESC','PSG');
END;

function get_all_year_desc return VARCHAR2 IS
BEGIN
 return get_dimension_desc('QPR_DIM_ALL_DESC','TIM');
END;

function get_cost_type_desc return varchar2 IS
msg varchar2(2000);
BEGIN
  FND_MESSAGE.SET_NAME('QPR', 'DEFAULT_COST_TYPE');
  msg := FND_MESSAGE.GET;
  return(msg);
END;

function get_oad_om_group_pk return varchar2 is
begin
  return OAD_OM_GROUP_CONST;
end;

function get_oad_om_group_desc return varchar2 is
begin
  return get_oad_group_desc(OAD_OM_GROUP_CONST);
end;

function get_oad_ar_group_pk return varchar2 is
begin
  return OAD_AR_GROUP_CONST;
end;

function get_oad_ar_group_desc return varchar2 is
begin
  return get_oad_group_desc(OAD_AR_GROUP_CONST);
end;

function get_oad_om_type_pk return varchar2 is
begin
  return OAD_OM_TYPE_CONST;
end;

function get_oad_om_type_desc return varchar2 is
begin
  return get_oad_type_desc(OAD_OM_TYPE_CONST);
end;

function get_oad_ar_cm_type_pk return varchar2 is
begin
  return OAD_AR_CM_TYPE_CONST;
end;

function get_oad_ar_cm_type_desc return varchar2 is
begin
  return get_oad_type_desc(OAD_AR_CM_TYPE_CONST);
end;

function get_oad_ar_cd_type_pk return varchar2 is
begin
  return OAD_AR_CD_TYPE_CONST;
end;

function get_oad_ar_cd_type_desc return varchar2 is
begin
  return get_oad_type_desc(OAD_AR_CD_TYPE_CONST);
end;

function get_oad_group_desc (p_code varchar2) return varchar2 is
l_group_desc varchar2(240) := null;
begin
	select meaning into l_group_desc
	from qpr_lookups
	where lookup_type = 'QPR_OAD_GROUPS'
	and lookup_code = p_code;

	return l_group_desc;
end get_oad_group_desc;

function get_oad_type_desc (p_code varchar2) return varchar2 is
l_type_desc varchar2(240) := null;
begin
	select meaning into l_type_desc
	from qpr_lookups
	where lookup_type = 'QPR_TERM_TYPE'
	and lookup_code = p_code;

	return l_type_desc;
end get_oad_type_desc;


FUNCTION get_dimension_desc(p_type varchar2,
                            p_code varchar2) return VARCHAR2 IS


CURSOR c_dim_desc(l_type varchar2, l_code varchar2) IS
select meaning from fnd_lookup_values
where lookup_type = l_type
and language = userenv('LANG')
and lookup_code = l_code;

l_dim_desc   varchar2(240) := NULL;

BEGIN

   OPEN  c_dim_desc(p_type, p_code);
   FETCH c_dim_desc INTO l_dim_desc;
   CLOSE c_dim_desc;

   IF l_dim_desc is NULL THEN
      RETURN p_code;
   ELSE
      RETURN l_dim_desc;
   END IF;

END get_dimension_desc;


function set_customer_attr(	p_profile_name IN VARCHAR2,
				p_profile_value IN VARCHAR2,
				p_profile_Level IN VARCHAR2) return number is
x_ret_value boolean;
begin
x_ret_value := fnd_profile.save(p_profile_name,p_profile_value,p_profile_Level);
if x_ret_value then
 return 0;
else
 return 2;
end if;
end;

FUNCTION get_customer_id( p_party_id IN NUMBER) return NUMBER is

x_customer_id number ;


cursor c_customer_id is
select  decode( decode(nvl(lower(fnd_profile.value('QPR_CUSTOMER_ATTRIBUTE')), '1'), '1', '1',
                           'attribute1', cust.attribute1,
                           'attribute2', cust.attribute2,
                           'attribute3', cust.attribute3,
                           'attribute4', cust.attribute4,
                           'attribute5', cust.attribute5,
                           'attribute6', cust.attribute6,
                           'attribute7', cust.attribute7,
                           'attribute8', cust.attribute8,
                           'attribute9', cust.attribute9,
                           'attribute10', cust.attribute10,
                           'attribute11', cust.attribute11,
                           'attribute12', cust.attribute12,
                           'attribute13',cust.attribute13,
                           'attribute14', cust.attribute14,
                           'attribute15', cust.attribute15, '2')
                         ,  '1',  nvl(cust.cust_account_id,
				qpr_sr_util.get_null_pk),
				qpr_sr_util.get_null_pk)
from
hz_cust_accounts cust
where cust.party_id = p_party_id
order by cust.cust_account_id ASC;


BEGIN

    open c_customer_id ;
    fetch c_customer_id into x_customer_id ;
    close c_customer_id ;

    if( x_customer_id  is not null) then
       return x_customer_id ;
    else
       return NULL_VALUE_PK_CONST ;
    end if ;

EXCEPTION
   when others then return NULL_VALUE_PK_CONST ;
end get_customer_id ;

function get_internal_customers_desc return VARCHAR2 is
BEGIN
	return get_dimension_desc('QPR_DIM_ALL_DESC','ICUS');
END;

function read_parameter(p_para_name in varchar2) return varchar2 as
begin
  return(fnd_profile.value(p_para_name));
end read_parameter;

function get_base_uom(p_item_id in number,
                      p_instance_id in number default null) return varchar2 as
  s_master_uom VARCHAR2(3);
  l_master_org number;
  l_sql varchar2(1000);
  s_tbl_name varchar2(200);
begin

    if g_base_item = p_item_id and
		nvl(g_uom_instance, 0) = nvl(p_instance_id, 0) then
			return(g_ref_base_uom);
    end if;

    if g_master_org is null then
      l_master_org := to_number(nvl(read_parameter('QPR_MASTER_ORG'), '0'));
      g_master_org := l_master_org;
    else
      l_master_org := g_master_org;
    end if;

    if p_instance_id is null then
      SELECT nvl(primary_uom_code,   'Ea')
      INTO s_master_uom
      FROM mtl_system_items
      WHERE inventory_item_id = p_item_id
      AND organization_id = l_master_org;
    else
      s_tbl_name := 'mtl_system_items' || get_dblink(p_instance_id);
      l_sql := 'SELECT nvl(primary_uom_code,  ''Ea'') from ' || s_tbl_name;
      l_sql := l_sql || ' WHERE inventory_item_id = ' || p_item_id;
      l_sql := l_sql || ' AND organization_id = ' || l_master_org;
      execute immediate l_sql into s_master_uom;
    end if;

    g_base_item := p_item_id;
    g_uom_instance := p_instance_id;
    g_ref_base_uom := s_master_uom;

    return(s_master_uom);
exception
  when OTHERS then
    return null;
end get_base_uom;


FUNCTION uom_conv(p_uom_code in VARCHAR2,   p_item_id in NUMBER,
		   p_master_uom varchar2
			) RETURN NUMBER AS
  l_conv_rate NUMBER := 1;
  s_master_uom VARCHAR2(3);
BEGIN
    --** Conversion between between two UOMS.
    --**
    --** 1. The conversion always starts from the conversion defined, if exists,
    --**    for an specified item.
    --** 2. If the conversion id not defined for that specific item, then the
    --**    standard conversion, which is defined for all items, is used.

    IF g_ref_uom = p_uom_code AND g_ref_item_id = p_item_id
    AND nvl(g_master_uom,'*') = nvl(p_master_uom,'*')
    THEN
      RETURN(g_ref_uom_conv_rate);
    END IF;

    if g_load_uom_no_conv is null then
      g_load_uom_no_conv := nvl(read_parameter('QPR_LOAD_NO_UOM_CON'), 'N');
    end if;

    if p_master_uom is null then
	 s_master_uom :=  get_base_uom(p_item_id);
    else
	 s_master_uom:= p_master_uom;
    end if;

    l_conv_rate := inv_convert.inv_um_convert(p_item_id,   NULL,   NULL,
                                  p_uom_code,   s_master_uom,   NULL,   NULL);

    IF(l_conv_rate = -99999 and g_load_uom_no_conv = 'Y') THEN
      l_conv_rate := 1;
    END IF;

    g_ref_uom := p_uom_code;
    g_ref_item_id := p_item_id;
    g_master_uom := p_master_uom;
    g_ref_uom_conv_rate := l_conv_rate;

    RETURN l_conv_rate;

EXCEPTION
  WHEN others THEN
    RETURN 1;
END uom_conv;

function convert_global_amt(p_curr_code in varchar2,
			    p_date in date,
			  from_ind_flag in varchar2 default 'Y',
                          p_global_curr_code in varchar2 default null)
                          return number is
  l_ret number;

begin
  if g_ref_curr = p_curr_code and g_ref_curr_date = p_date
  and nvl(g_ref_global_curr_code, '*') = nvl(p_global_curr_code,'*')
  then
    return(g_curr_conv_rate);
  end if;

  if g_load_curr_no_conv is null then
    g_load_curr_no_conv := nvl(read_parameter('QPR_LOAD_NO_CURR_CON'), 'N');
  end if;

  if p_global_curr_code is not null then
    g_global_currency_code := p_global_curr_code;
  end if;

  if g_global_currency_code is null then
    g_global_currency_code := read_parameter('QPR_CURRENCY_CODE');
  end if;

  if g_global_rate_type is null then
     g_global_rate_type := read_parameter('QPR_CONVERSION_TYPE');
  end if;

  if (p_curr_code = g_global_currency_code) then
    l_ret := 1;
  elsif p_curr_code is null or g_global_currency_code is null then
    l_ret := 1;
  else
    if from_ind_flag = 'Y' then
      l_ret := GL_CURRENCY_API.convert_amount_sql(p_curr_code,
                                                g_global_currency_code,
                                                p_date,
                                                g_global_rate_type, 1);
    else
      l_ret := GL_CURRENCY_API.convert_amount_sql(g_global_currency_code,
                                                  p_curr_code,
                                                  p_date,
                                                  g_global_rate_type, 1);

    end if;
  end if;
  if  l_ret < 0  and g_load_curr_no_conv = 'Y' then
  -- api returns -1(rate not found) and -2 (currency not found)
     l_ret := 1;
  end if;
  g_ref_curr := p_curr_code;
  g_ref_curr_date := p_date;
  g_ref_global_curr_code := p_global_curr_code;
  g_curr_conv_rate := l_ret;

  return l_ret;

EXCEPTION
  when OTHERS then
    return NULL;
END convert_global_amt;

function get_customer_attribute return varchar2 is
  s_cust_attr varchar2(30);
begin

  if g_ref_cust_attr is null and g_b_cust_attr_read = 0 then
    s_cust_attr := lower(read_parameter('QPR_CUSTOMER_ATTRIBUTE'));
    g_ref_cust_attr := s_cust_attr;
    g_b_cust_attr_read := 1;
  else
    s_cust_attr := g_ref_cust_attr;
  end if;

  return (s_cust_attr);
exception
  when OTHERS then
    return NULL;
end get_customer_attribute;

function get_dblink(p_instance_id in number) return varchar2 is
    db_link varchar2(150) := '';
begin
    select decode(DBLINK,null, '','@'||DBLINK) into db_link
    from QPR_INSTANCES
    where instance_id= p_instance_id;
    return(db_link);
exception
    when NO_DATA_FOUND then
      fnd_file.put_line(fnd_file.log, 'ERROR READING INSTANCE DATA...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end get_dblink;

FUNCTION ods_uom_conv(p_item_id in NUMBER, p_from_uom_code in VARCHAR2,
                      p_to_uom_code in varchar2,
                      p_instance_id in number default null,
                      p_precision in number default null
                      ) RETURN NUMBER AS
  l_conv_rate NUMBER := 1;

  STD_INV_PRECISION number := 5;

BEGIN
    --** Conversion between between two UOMS.
    --**
    --** 1. The conversion always starts from the conversion defined, if exists,
    --**    for an specified item.
    --** 2. If the conversion id not defined for that specific item, then the
    --**    standard conversion, which is defined for all items, is used.

    IF g_ods_from_uom = p_from_uom_code AND g_ods_ref_item_id = p_item_id
    and g_ods_to_uom = p_to_uom_code and g_ods_uom_inst_id = p_instance_id
    THEN
      RETURN(g_ods_ref_uom_crate);
    END IF;

    if g_load_uom_no_conv is null then
      g_load_uom_no_conv := nvl(read_parameter('QPR_LOAD_NO_UOM_CON'), 'N');
    end if;

    if g_uom_conv_in_ods is null then
        g_uom_conv_in_ods := nvl(read_parameter('QPR_PULL_UOM_CONV_TO_ODS'), 'N');
    end if;

    if p_from_uom_code = p_to_uom_code then
      l_conv_rate := 1;
    elsif g_uom_conv_in_ods = 'Y' then
      begin
        select conv_rate into l_conv_rate
        from (
        select 1/(nvl(conversion_rate, 1) ) conv_rate
        from qpr_uom_conversions
        where from_uom_code = p_from_uom_code
        and to_uom_code = p_to_uom_code
        and instance_id = p_instance_id
        and item_key in (to_char(p_item_id), '0')
        order by item_key desc)
        where rownum < 2;
      exception
        when no_data_found then
          begin
          select conv_rate into l_conv_rate
          from(
          select (nvl(conversion_rate, 1) ) conv_rate
          from qpr_uom_conversions
          where from_uom_code = p_to_uom_code
          and to_uom_code = p_from_uom_code
          and instance_id = p_instance_id
          and item_key in (to_char(p_item_id), '0')
          order by item_key desc)
          where rownum < 2;
          exception
            when no_data_found then
              l_conv_rate:= -99999;
          end;
      end;
      l_conv_rate := round(l_conv_rate, nvl(p_precision, STD_INV_PRECISION));
    else
      l_conv_rate := inv_convert.inv_um_convert(p_item_id, p_precision, NULL,
                                   p_from_uom_code, p_to_uom_code, NULL, NULL);
    end if;

    IF(l_conv_rate = -99999) and g_load_uom_no_conv='Y' THEN
      l_conv_rate := 1;
    END IF;

    g_ods_from_uom := p_from_uom_code;
    g_ods_to_uom := p_to_uom_code;
    g_ods_ref_item_id := p_item_id;
    g_ods_ref_uom_crate := l_conv_rate;
    g_ods_uom_inst_id := p_instance_id;

    return(l_conv_rate);

EXCEPTION
  WHEN others THEN
    RETURN -1;
END ods_uom_conv;


function ods_curr_conversion(p_from_curr_code in varchar2 default null,
                               p_to_curr_code in varchar2,
                               p_conv_type in varchar2 default null,
                               p_date in date,
                               p_instance_id in number)
                               return number is
  l_ret number;
begin
  if p_from_curr_code = p_to_curr_code then
     return(1);
  end if;
  if g_from_currency_code = nvl(p_from_curr_code, g_from_currency_code) and
     g_ods_curr_inst_id = p_instance_id and
     g_to_currency_code = p_to_curr_code and
     g_ods_rate_type = nvl(p_conv_type, g_ods_rate_type) and
     g_ods_curr_date = p_date then
     return(g_ods_curr_rate);
  end if;

  if g_load_curr_no_conv is null then
    g_load_curr_no_conv := nvl(read_parameter('QPR_LOAD_NO_CURR_CON'), 'N');
  end if;

  if g_curr_conv_in_ods  is null then
    g_curr_conv_in_ods := nvl(read_parameter('QPR_PULL_CURR_CONV_TO_ODS'), 'N');
  end if;

  if p_from_curr_code is null then
    if g_from_currency_code is null then
      g_from_currency_code := read_parameter('QPR_CURRENCY_CODE');
    end if;
  else
    g_from_currency_code := p_from_curr_code;
  end if;

  if p_conv_type is null then
    if g_ods_rate_type is null then
       g_ods_rate_type := read_parameter('QPR_CONVERSION_TYPE');
    end if;
  else
    g_ods_rate_type := p_conv_type;
  end if;

  if g_from_currency_code is null or p_to_curr_code is null then
    l_ret := -1;
  elsif g_curr_conv_in_ods = 'Y' then
    l_ret := qpr_convert_amount(p_instance_id,
                                g_from_currency_code,
                                p_to_curr_code,
                                p_date,
                                null, 1);
  else
    l_ret := GL_CURRENCY_API.convert_amount_sql(g_from_currency_code,
                                                  p_to_curr_code,
                                                  p_date,
                                                  g_ods_rate_type, 1);
  end if;

  if l_ret < 0 and g_load_curr_no_conv = 'Y' then
    l_ret := 1;
  end if;

  g_ods_curr_inst_id := p_instance_id;
  g_to_currency_code := p_to_curr_code;
  g_ods_curr_date := p_date;
  g_ods_curr_rate := l_ret;

  return(l_ret);

exception
  when OTHERS then
    return(-1);
end ods_curr_conversion;


function qpr_convert_amount(p_instance_id in number,
                            p_from_currency in varchar2,
                            p_to_currency in varchar2,
                            p_conversion_date in date,
                            p_conversion_type in varchar2 default null,
                            p_amount in number) return number as
  s_to_type varchar2(8);
  s_from_type varchar2(8);
  s_euro_code varchar2(20);
  l_to_rate number;
  l_from_rate number;
  l_from_mau number;
  l_to_mau number;
  l_converted_amount number;
  l_other_rate number;

  INVALID_CURRENCY exception;

procedure get_info(
                    p_currency in varchar2,
                    p_eff_date in date,
                    p_conversion_rate in out nocopy number,
                    p_mau in out nocopy number,
                    p_currency_type in out nocopy varchar2 ) is
begin
     -- Get currency information from FND_CURRENCIES table
  select decode( derive_type,
                'EURO', 'EURO',
                'EMU', decode( sign(trunc(p_eff_date) - trunc(derive_effective)),
                              -1, 'OTHER','EMU'),
                'OTHER'),
         decode( derive_type,
                  'EURO', 1,
		  'EMU', derive_factor,
		  'OTHER', -1 ),
         nvl( minimum_accountable_unit, power( 10, (-1 * precision)))
  into   p_currency_type, p_conversion_rate,  p_mau
  from   FND_CURRENCIES
  where  currency_code = p_currency;
exception
  when NO_DATA_FOUND then
    raise INVALID_CURRENCY;
end get_info;

function get_euro_code return varchar2 is
  s_euro_code varchar2(20);
begin
-- Get currency code of the EURO currency
  select currency_code into s_euro_code
  from FND_CURRENCIES
  where derive_type = 'EURO';

  return( s_euro_code );
exception
  when NO_DATA_FOUND then
    raise INVALID_CURRENCY;
end get_euro_code;

function get_fixed_conv_rate(p_instance_id in number,
                              p_from_currency in out nocopy varchar2,
                              p_to_currency in out nocopy varchar2,
                              p_conversion_date date) return number is
  l_fixed_conv_rate number;
  l_direct_from_fix_rate number := 1;
  l_inverse_to_fix_rate number := 1;

  cursor c_is_there_fixed_rate is
       select from_currency,
              to_currency,
              conversion_rate
       from qpr_currency_rates
       where from_currency in (p_from_currency, p_to_currency)
       and  conversion_date <= p_conversion_date
       and conversion_class = 'FIXED'
       and instance_id = p_instance_id;
begin
  if (p_from_currency = p_to_currency) then
    l_fixed_conv_rate := 1;
  end if;

   /* ********************************************************************+
   |  This routine should check whether there is a fixed rate relationship|
   |  exist between the from currency and the to_currency  in the         |
   |  GL_FIXED_CONV_RATES table.                                          |
   |  Some EUROPEAN countries are getting rid of ending zero's            |
   |  from their currency. In this case those countries define            |
   |  a fixed rate relationship between the old currency and the new      |
   |  replacement currency starting from an effective date.               |
   |  A few possible different scenarios                                  |
   |  The rate may be calculated between two currencies as follows        |
   |                                                                      |
   |  1) Old Currency to French Franks                                    |
   |  Old Currency -> New Currency from the GL_FIXED_CONV_RATES table     |
   |  New Currency -> EURO from the GL_DAILY_RATES                        |
   |  EURO -> FRENCH FRANK  fixed rate from the FND_CURRENCIES            |
   |                                                                      |
   |  2) USD to New Currency                                              |
   |     USD -> New CURRENCY from the GL Daily Rates Table.               |
   |                                                                      |
   |  3) USD to Old Currency                                              |
   |     USD -> New CURRENCY from the GL Daily Rates Table.               |
   |     New curency -> Old Currency fixed rate                           |
   |                         from GL Fixed Conv Rates                     |
   |                                                                      |
   |   4) Old Currency to CAD                                             |
   |      Old Currency -> New Currency from                               |
   |                          the GL_FIXED_CONV_RATES table               |
   |      New Currency -> CAD from the GL_DAILY_RATES                     |
   |                                                                      |
   |***********************************************************************/

  -- max. of 2 records will be fetched in this cursor if both the from and
  -- to currencies have fixed rates defined.
  for r_fix_rate in c_is_there_fixed_rate loop
    if (p_from_currency = r_fix_rate.from_currency) then
      l_direct_from_fix_rate:= r_fix_rate.conversion_rate;
      p_from_currency := r_fix_rate.to_currency;
    end if;

    if (p_to_currency = r_fix_rate.from_currency) then
      l_inverse_to_fix_rate := 1/r_fix_rate.conversion_rate;
      p_to_currency := r_fix_rate.to_currency;
    end if;
  end loop;

  l_fixed_conv_rate := l_direct_from_fix_rate* l_inverse_to_fix_rate;

  return(l_fixed_conv_rate);
exception
  when OTHERS then
    return(-1);
end get_fixed_conv_rate;

function get_other_rate (p_instance_id in number,
                          p_from_currency in varchar2,
                          p_to_currency in varchar2,
                          p_conversion_date in date,
                          p_conversion_type in varchar2 default null)
                          return number is
s_from_currency    VARCHAR2(15);
s_to_currency      VARCHAR2(15);
l_fix_rate         NUMBER;
l_rate NUMBER;
begin
  s_from_currency := p_from_currency;
  s_to_currency   := p_to_currency;
-- NOTE:UNCOMMENT THE FOLLOWING CODE WHEN FIXED CONV. RATE IS SUPPORTED
-- Get the Fixed conversion rate if there exists one.
  -- the from and to currencies can be replaced with new currencies in this call
/*  l_fix_rate := get_fixed_conv_rate(p_instance_id,
                                    s_from_currency,
                                    s_to_currency,
                                    p_conversion_date);
 */
  l_fix_rate := 1;
  if (s_from_currency = s_to_currency) then
    l_rate := 1;
  else
    -- Get conversion rate between the two currencies from GL_DAILY_RATES
    select conversion_rate into l_rate
    from  qpr_currency_rates
    where instance_id = p_instance_id
    and conversion_class = 'DAILY'
    and from_currency = s_from_currency
    and to_currency = s_to_currency
    and conversion_date = p_conversion_date
    and rownum < 2;
  end if;

  return(l_fix_rate * l_rate );
exception
  when NO_DATA_FOUND then
    return(-1);
end get_other_rate;

begin
  if p_from_currency = p_to_currency then
    return(p_amount);
  end if;

  -- Get currency information from the from_currency
  get_info ( p_from_currency, p_conversion_date, l_from_rate, l_from_mau,
                              s_from_type );

  -- Get currency information from the to_currency
  get_info ( p_to_currency, p_conversion_date, l_to_rate, l_to_mau, s_to_type );

  if (s_from_type = 'EMU') then
    if (s_to_type = 'EMU') then
      l_converted_amount := ( p_amount / l_from_rate ) * l_to_rate;

    elsif (s_to_type = 'EURO') then
      l_converted_amount := p_amount / l_from_rate;

    elsif (s_to_type = 'OTHER') then
      -- Find out conversion rate from EURO to x_to_currency
      -- Get conversion amt by converting EMU -> EURO -> OTHER
      s_euro_code := get_euro_code;
      l_other_rate := get_other_rate( p_instance_id, s_euro_code, p_to_currency,
                                      p_conversion_date,
                                      p_conversion_type);
      l_converted_amount := ( p_amount / l_from_rate ) * l_other_rate;
    end if;
  elsif (s_from_type = 'EURO') then
    -- if to currency is also EURO the amount is returned
    if (s_to_type = 'EMU') then
      l_converted_amount := p_amount * l_to_rate;
    elsif (s_to_type = 'OTHER' ) then
      l_other_rate := get_other_rate( p_instance_id,
                                      p_from_currency, p_to_currency,
                                      p_conversion_date,
                                      p_conversion_type );
      l_converted_amount := p_amount * l_other_rate;
    end if;

  elsif (s_from_type = 'OTHER' ) then
    if (s_to_type = 'EMU' ) then
      -- Get conversion amt by converting OTHER -> EURO -> EMU
      s_euro_code := get_euro_code;
      l_other_rate := get_other_rate( p_instance_id, p_from_currency,
                                      s_euro_code,
                                      p_conversion_date,
                                      p_conversion_type );
      l_converted_amount := ( p_amount * l_other_rate ) * l_to_rate;
    elsif ( s_to_type = 'EURO' ) then
      l_other_rate := get_other_rate( p_instance_id, p_from_currency,
                                      p_to_currency,
                                      p_conversion_date,
                                      p_conversion_type );
      l_converted_amount := p_amount * l_other_rate;
    elsif ( s_to_type = 'OTHER' ) then
      l_other_rate := get_other_rate( p_instance_id, p_from_currency,
                                      p_to_currency,
                                      p_conversion_date,
                                      p_conversion_type );
      l_converted_amount := p_amount * l_other_rate;
    end if;
  end if;

  -- Rounding to the correct precision and minumum accountable units
  return( round( l_converted_amount / l_to_mau ) * l_to_mau );
exception
  when OTHERS then
    return(-1);
end qpr_convert_amount;

function dm_parameters_ok return boolean
is
l_count number;
begin
	if (fnd_profile.value('QPR_CURRENCY_CODE') is null or
		fnd_profile.value('QPR_CATEGORY_SET_NAME') is null or
		fnd_profile.value('QPR_MASTER_ORG') is null) then
		return false;
	else
		return true;
	end if;
exception
	when others then return(false);
end;

function get_max_date(p_date1 in date, p_date2 in date) return date is
s_max_date date;
begin
  if p_date1 is null then
    return(p_date2);
  elsif p_date2 is null then
    return(p_date1);
  else
    if sign(p_date1-p_date2) = -1 then
      return(p_date2);
    else
      return(p_date1);
    end if;
  end if;
exception
  when others then return(null);
end;

procedure purge_base_tables_data (p_price_plan_id in number)
is
begin
	delete from QPR_MEASURE_GROUPS where price_plan_id = p_price_plan_id;
	delete from QPR_LVL_ATTRIBUTES where price_plan_id = p_price_plan_id;
	delete from QPR_HIER_LEVELS where price_plan_id = p_price_plan_id;
	delete from QPR_HIERARCHIES where price_plan_id = p_price_plan_id;
	delete from QPR_DIM_ATTRIBUTES where price_plan_id = p_price_plan_id;
	delete from QPR_SET_LEVELS where price_plan_id = p_price_plan_id;
	delete from QPR_MEAS_AGGRS where price_plan_id = p_price_plan_id;
	delete from QPR_MEASURES where price_plan_id = p_price_plan_id;
	delete from QPR_CUBE_DIMS where price_plan_id = p_price_plan_id;
	delete from QPR_CUBES where price_plan_id = p_price_plan_id;
	delete from QPR_DIMENSIONS where price_plan_id = p_price_plan_id;
	delete from QPR_PRICE_PLANS_TL where price_plan_id = p_price_plan_id;
	delete from QPR_PRICE_PLANS_B where price_plan_id = p_price_plan_id;
end;

END QPR_SR_UTIL;

/
