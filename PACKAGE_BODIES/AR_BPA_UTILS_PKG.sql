--------------------------------------------------------
--  DDL for Package Body AR_BPA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_UTILS_PKG" as
/* $Header: ARBPAUTB.pls 120.8 2006/06/20 21:41:15 lishao noship $*/

PROCEDURE debug (
    p_message                   IN      VARCHAR2,
    p_log_level                 IN      NUMBER default FND_LOG.LEVEL_STATEMENT,
    p_module_name               IN      VARCHAR2 default 'ar.plsql.ar_bpa_utils_pkg') IS

BEGIN
  if ( (pg_debug = 'Y') and  ( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )) then
    FND_LOG.string(p_log_level,p_module_name, p_message);
  end if;
END;


FUNCTION fn_get_header_level_so ( p_customer_trx_id IN number ) return varchar2 AS
cursor c_linesSO is
	select  distinct ctl.sales_order
	from    ra_customer_trx_lines ctl
	where   ctl.customer_trx_id = p_customer_trx_id
	and	ctl.line_type = 'LINE';

l_count_sales_orders number := 0;
l_so_number varchar2(30) := null;
BEGIN

	FOR crec in c_linesSO
	LOOP
		l_count_sales_orders := l_count_sales_orders + 1;
		if (l_count_sales_orders > 1) then
			l_so_number := '-1';			-- multiple value
			exit; -- break
		else
	        	l_so_number := crec.sales_order;
		end if;
	END LOOP;

	return l_so_number;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_header_level_so;

FUNCTION fn_get_header_level_co ( p_customer_trx_id IN number ) return varchar2 AS
cursor c_linesCO is
	select  distinct ctl.interface_line_attribute1
	from    ra_customer_trx_lines ctl
	where   ctl.customer_trx_id = p_customer_trx_id
	and	ctl.line_type = 'LINE';

l_count_contract_numbers number := 0;
l_co_number varchar2(30) := null;
BEGIN

	FOR crec in c_linesCO
	LOOP
		l_count_contract_numbers := l_count_contract_numbers + 1;
		if (l_count_contract_numbers > 1) then
			l_co_number := '-1';		-- multiple value
			exit; -- break
		else
	        	l_co_number := crec.interface_line_attribute1;
		end if;
	END LOOP;

	return l_co_number;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_header_level_co;

FUNCTION fn_get_billing_line_level ( p_customer_trx_id IN number ) return varchar2 AS
cursor c_headerlevel is
		select  1
		from    ra_customer_trx ctl
		where   ctl.customer_trx_id = p_customer_trx_id
		and ctl.interface_header_context = 'OKS CONTRACTS';
cursor c_linelevel is
		select  ctl.INVOICED_LINE_ACCTG_LEVEL
		from    ra_customer_trx_lines ctl
		where   ctl.customer_trx_id = p_customer_trx_id
		and	ctl.line_type = 'LINE'
		and ctl.interface_line_context = 'OKS CONTRACTS'
		and ctl.interface_line_attribute9 = 'Service';
l_line_level  varchar2(30) := null;
BEGIN
	FOR crec in c_headerlevel
	LOOP
		-- if we are here, it means it is an OKS contract invoice.
		l_line_level := 'D';
		exit; -- break
	END LOOP;

	if (l_line_level = 'D') then
		FOR crec1 in c_linelevel
		LOOP
	      	l_line_level := crec1.INVOICED_LINE_ACCTG_LEVEL;
	      	exit; -- break
		END LOOP;
	end if;
	return l_line_level;
EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_billing_line_level;

FUNCTION fn_get_profile_class_name ( p_customer_trx_id IN number ) return varchar2 AS
cursor c_profileclass1 is
	select hzc.name
	from ra_customer_trx trx,
	    hz_customer_profiles hzp,
	    hz_cust_profile_classes hzc
	where trx.customer_trx_id = p_customer_trx_id
	and  trx.bill_to_customer_id = hzp.cust_account_id
	and  trx.bill_to_site_use_id = hzp.site_use_id
	and  hzp.profile_class_id = hzc.profile_class_id;

cursor c_profileclass2 is
	select hzc.name
	from ra_customer_trx trx,
	    hz_customer_profiles hzp,
	    hz_cust_profile_classes hzc
	where trx.customer_trx_id = p_customer_trx_id
	and  trx.bill_to_customer_id = hzp.cust_account_id
	and  hzp.site_use_id is null
	and  hzp.profile_class_id = hzc.profile_class_id;

l_profile_class_name varchar2(30) := null;
BEGIN

	FOR crec in c_profileclass1
	LOOP
      	l_profile_class_name := crec.name;
	END LOOP;

	if (l_profile_class_name is null) then
		FOR crec1 in c_profileclass2
		LOOP
	      	l_profile_class_name := crec1.name;
		END LOOP;

	end if;
	return l_profile_class_name;


EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_profile_class_name;

FUNCTION fn_get_tax_printing_option ( p_bill_to_site_use_id IN number, p_bill_to_customer_id in number ) return varchar2 AS
cursor c_tax_printing_option1 is
      select cp_site.tax_printing_option
      from   hz_customer_profiles cp_site
      where  cp_site.site_use_id    = p_bill_to_site_use_id
      and    cp_site.cust_account_id    = p_bill_to_customer_id;

cursor c_tax_printing_option2 is
      select cp_cust.tax_printing_option
      from   hz_customer_profiles cp_cust
      where  cp_cust.cust_account_id = p_bill_to_customer_id
      and    cp_cust.site_use_id is null;

cursor c_tax_printing_option3 is
      SELECT tax_invoice_print from AR_SYSTEM_PARAMETERS;

l_tax_printing_option hz_customer_profiles.tax_printing_option%TYPE := null;
BEGIN
	FOR crec in c_tax_printing_option1
	LOOP
      	l_tax_printing_option := crec.tax_printing_option;
	END LOOP;

	if (l_tax_printing_option is null) then
		FOR crec1 in c_tax_printing_option2
		LOOP
	      	l_tax_printing_option := crec1.tax_printing_option;
		END LOOP;
    end if;

	if (l_tax_printing_option is null) then
		FOR crec2 in c_tax_printing_option3
		LOOP
	      	l_tax_printing_option := crec2.tax_invoice_print;
		END LOOP;
    end if;

   return l_tax_printing_option;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_tax_printing_option;

-- it only works for OKS so far, need extend it to support dynamic data source
-- and future integration with other source products.
FUNCTION fn_trx_has_groups ( p_customer_trx_id IN number ) return varchar2 AS
CURSOR 	c_trx_has_groups IS
SELECT 	1
FROM  	ra_customer_trx_lines
WHERE 	customer_trx_id = p_customer_trx_id
AND   	line_type = 'LINE'
and   	(source_data_key1 is not null
	 or source_data_key2 is not null
	 or source_data_key3 is not null
	 or source_data_key4 is not null
	 or source_data_key5 is not null
	);
l_trx_has_groups varchar2(10) := 'N';

BEGIN
	l_trx_has_groups := 'N';
	FOR crec in c_trx_has_groups
	LOOP
		-- if we are here, it means at least one line has a grouping key.
		l_trx_has_groups := 'Y';
		exit; -- break
	END LOOP;
	return l_trx_has_groups;
EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_trx_has_groups;

FUNCTION fn_get_line_taxrate( p_customer_trx_line_id IN number ) return varchar2 AS
cursor c_linetax is
	SELECT  to_char(round(ctl.tax_rate,4)) line_tax_rate
	from    ra_customer_trx_lines ctl
	where
	ctl.link_to_cust_trx_line_id = p_customer_trx_line_id
	and	ctl.line_type = 'TAX'
	and rownum = 1;

l_taxrate varchar2(30) := null;
BEGIN

	FOR crec in c_linetax
	LOOP
		l_taxrate := crec.line_tax_rate;
	END LOOP;

	return l_taxrate;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_line_taxrate;

FUNCTION fn_get_line_taxname( p_customer_trx_line_id IN number ) return varchar2 AS
cursor c_linetax is
	SELECT  v.tax_rate_name as printed_tax_name
	from    ra_customer_trx_lines ctl,
			zx_rates_vl v
	where
	ctl.link_to_cust_trx_line_id = p_customer_trx_line_id
	and	ctl.line_type = 'TAX'
	and	ctl.vat_tax_id =  v.tax_rate_id(+)
	and rownum = 1;

l_taxname varchar2(80) := null;
BEGIN

	FOR crec in c_linetax
	LOOP
		l_taxname := crec.printed_tax_name;
	END LOOP;

	return l_taxname;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_line_taxname;

FUNCTION fn_get_line_taxcode( p_customer_trx_line_id IN number ) return varchar2 AS
cursor c_linetax is
	SELECT  v.tax_rate_code as tax_code
	from    ra_customer_trx_lines ctl,
			zx_rates_vl v
	where
	ctl.link_to_cust_trx_line_id = p_customer_trx_line_id
	and	ctl.line_type = 'TAX'
	and	ctl.vat_tax_id =  v.tax_rate_id(+)
	and rownum = 1;

l_taxcode varchar2(30) := null;
BEGIN

	FOR crec in c_linetax
	LOOP
		l_taxcode := crec.tax_code;
	END LOOP;

	return l_taxcode;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_line_taxcode;

FUNCTION fn_get_group_taxrate (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2 AS
cursor c_lines is
	SELECT  lines.customer_trx_line_id
	from    ra_customer_trx_lines lines
	where
	lines.customer_trx_id = p_customer_trx_id
	and	lines.line_type = 'LINE'
	and source_data_key1 = id
	and source_data_key2 = bcl_id
	and rownum = 1;

cursor c_linetax (id number) is
	SELECT  to_char(round(ctl.tax_rate,4)) line_tax_rate
	from    ra_customer_trx_lines ctl
	where
	ctl.link_to_cust_trx_line_id = id
	and	ctl.line_type = 'TAX'
	and rownum = 1;

l_line_id number := 0;
l_taxrate varchar2(30) := null;
BEGIN

	FOR crec in c_lines
	LOOP
		l_line_id := crec.customer_trx_line_id;
	END LOOP;

	if (l_line_id <> 0) then
	BEGIN
		FOR crec1 in c_linetax(l_line_id)
		LOOP
			l_taxrate := crec1.line_tax_rate;
		END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				return NULL;
	END;
	end if;
	return l_taxrate;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_group_taxrate;

FUNCTION fn_get_group_taxname (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2 AS
cursor c_lines is
	SELECT  lines.customer_trx_line_id
	from    ra_customer_trx_lines lines
	where
	lines.customer_trx_id = p_customer_trx_id
	and	lines.line_type = 'LINE'
	and source_data_key1 = id
	and source_data_key2 = bcl_id
	and rownum = 1;

cursor c_linetax (id number) is
	SELECT  v.tax_rate_name as printed_tax_name
	from    ra_customer_trx_lines ctl,
			zx_rates_vl v
	where
	ctl.link_to_cust_trx_line_id = id
	and	ctl.line_type = 'TAX'
	and	ctl.vat_tax_id =  v.tax_rate_id(+)
	and rownum = 1;

l_line_id number := 0;
l_taxname varchar2(30) := null;
BEGIN

	FOR crec in c_lines
	LOOP
		l_line_id := crec.customer_trx_line_id;
	END LOOP;

	if (l_line_id <> 0) then
	BEGIN
		FOR crec1 in c_linetax(l_line_id)
		LOOP
			l_taxname := crec1.printed_tax_name;
		END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				return NULL;
	END;
	end if;
	return l_taxname;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_group_taxname;

FUNCTION fn_get_group_taxcode (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2 AS
cursor c_lines is
	SELECT  lines.customer_trx_line_id
	from    ra_customer_trx_lines lines
	where
	lines.customer_trx_id = p_customer_trx_id
	and	lines.line_type = 'LINE'
	and source_data_key1 = id
	and source_data_key2 = bcl_id
	and rownum = 1;

cursor c_linetax (id number) is
	SELECT  v.tax_rate_code as tax_code
	from    ra_customer_trx_lines ctl,
			zx_rates_vl v
	where
	ctl.link_to_cust_trx_line_id = id
	and	ctl.line_type = 'TAX'
	and	ctl.vat_tax_id =  v.tax_rate_id(+)
	and rownum = 1;

l_line_id number := 0;
l_taxcode varchar2(30) := null;
BEGIN

	FOR crec in c_lines
	LOOP
		l_line_id := crec.customer_trx_line_id;
	END LOOP;

	if (l_line_id <> 0) then
	BEGIN
		FOR crec1 in c_linetax(l_line_id)
		LOOP
			l_taxcode := crec1.tax_code;
		END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				return NULL;
	END;
	end if;
	return l_taxcode;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_group_taxcode;

FUNCTION fn_get_group_taxyn (p_customer_trx_id IN number, id in number, bcl_id in number) return varchar2 AS
cursor c_lines is
	SELECT  lines.customer_trx_line_id
	from    ra_customer_trx_lines lines
	where
	lines.customer_trx_id = p_customer_trx_id
	and	lines.line_type = 'LINE'
	and source_data_key1 = id
	and source_data_key2 = bcl_id
	and rownum = 1;

l_line_id number := 0;
BEGIN

	FOR crec in c_lines
	LOOP
		l_line_id := crec.customer_trx_line_id;
	END LOOP;

	return AR_INVOICE_SQL_FUNC_PUB.get_taxyn (l_line_id);

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_group_taxyn;

FUNCTION fn_get_line_description ( p_customer_trx_line_id IN number) return varchar2 AS
cursor c_linetax is
	SELECT
		ctl.line_type,
		nvl(ctl.translated_description,ctl.description) line_description,
		ctl.tax_rate,
	    ctl.vat_tax_id,
	    ctl.tax_exemption_id,
	    ctl.sales_tax_id,
	    ctl.tax_precedence
	from    ra_customer_trx_lines ctl
	where   ctl.customer_trx_line_id = p_customer_trx_line_id;

description varchar2(2000) := null;
line_type 			ra_customer_trx_lines.LINE_TYPE%TYPE;
line_description 	ra_customer_trx_lines.DESCRIPTION%TYPE;
tax_rate			ra_customer_trx_lines.TAX_RATE%TYPE;
vat_tax_id			ra_customer_trx_lines.VAT_TAX_ID%TYPE;
tax_exemption_id	ra_customer_trx_lines.TAX_EXEMPTION_ID%TYPE;
location_rate_id	ra_customer_trx_lines.SALES_TAX_ID%TYPE;
tax_precedence		ra_customer_trx_lines.TAX_PRECEDENCE%TYPE;

BEGIN
      open c_linetax;
	  fetch c_linetax into line_type, line_description, tax_rate, vat_tax_id, tax_exemption_id, location_rate_id, tax_precedence;
      CLOSE c_linetax;

   if ( line_type = 'TAX' ) then
      return get_tax_description(tax_rate, vat_tax_id, tax_exemption_id,location_rate_id, tax_precedence, '');
   else
      return line_description;
   end if;

   return  description;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END fn_get_line_description;

/* Return contact name */
FUNCTION fn_get_contact_name (p_contact_id IN NUMBER) return varchar2 IS
CURSOR c_cont_name( id in number ) IS
SELECT  party.person_first_name ||' '|| party.person_last_name attn
FROM	hz_cust_account_roles       acct_role,
        hz_relationships            rel,
        hz_parties                  party
WHERE acct_role.cust_account_role_id = id
AND   acct_role.ROLE_TYPE            = 'CONTACT'
AND   acct_role.party_id             = rel.party_id
AND   rel.subject_id                 = party.party_id
AND   rel.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
AND   rel.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
AND   rel.DIRECTIONAL_FLAG           = 'F';

l_contact_name varchar2(240) := null;
BEGIN
	  FOR crec IN c_cont_name(p_contact_id)
	  LOOP
		   l_contact_name := crec.attn;
		   exit; -- break
	  END LOOP;
	return l_contact_name;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END;

/* Return contact phone */
FUNCTION fn_get_phone (p_contact_id IN NUMBER) return varchar2 IS
CURSOR c_cont_phone( id in number ) IS
   select min(decode(cont_point.contact_point_type,'TLX',
         cont_point.telex_number, cont_point.phone_number)) contact_phone
   from  hz_contact_points cont_point,
         hz_cust_account_roles acct_role
   where acct_role.cust_account_role_id = id
     and acct_role.party_id = cont_point.owner_table_id
     and cont_point.owner_table_name = 'HZ_PARTIES'
     and nvl(cont_point.phone_line_type, cont_point.contact_point_type) = 'GEN';
l_phone varchar2(240) := null;
BEGIN
	FOR crec IN c_cont_phone(p_contact_id)
	LOOP
		l_phone := crec.contact_phone;
		exit; -- break
	END LOOP;

	return l_phone;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END;

/* Return contact fax */
FUNCTION fn_get_fax (p_contact_id IN NUMBER) return varchar2 IS
CURSOR c_cont_fax( id in number ) IS
   select min(decode(cont_point.contact_point_type,'TLX',
         cont_point.telex_number, cont_point.phone_number)) contact_fax
   from  hz_contact_points cont_point,
         hz_cust_account_roles acct_role
   where acct_role.cust_account_role_id = id
     and acct_role.party_id = cont_point.owner_table_id
     and cont_point.owner_table_name = 'HZ_PARTIES'
     and nvl(cont_point.phone_line_type, cont_point.contact_point_type) = 'FAX';
l_fax varchar2(240) := null;
BEGIN
	FOR crec IN c_cont_fax(p_contact_id)
	LOOP
		l_fax := crec.contact_fax;
		exit; -- break
	END LOOP;

	return l_fax;

EXCEPTION
	WHEN OTHERS THEN
		return null;
END;

function get_tax_description(
    tax_rate in number,
    vat_tax_id in number,
    tax_exemption_id in number,
    location_rate_id in number,
    tax_precedence in number,
    D_euro_taxable_amount in varchar2  ) return varchar2 is

 d  varchar2(240);
 e  varchar2(240);

 cursor tax_type_c( id in number ) is
    select t.tax_type_code,t.compounding_precedence
    from zx_taxes_vl t,zx_rates_vl r
    where t.tax_regime_code = r.tax_regime_code
    and t.tax = r.tax
    and r.tax_rate_id = id;

 cursor vat_tax_c( id in number ) is
    select tax_rate_code as tax_code, tax_rate_name as printed_tax_name from zx_rates_vl where tax_rate_id = id;

 cursor exem_c( id in number ) is
    select
        decode(nvl(product_id,-999),-999,'CUSTOMER','ITEM') as exemption_type,
        rate_modifier as percent_exempt
    from zx_exemptions
    where tax_exemption_id = id;

 cursor tax_type_name_c(code in varchar2) is
    select meaning
    from fnd_lookups
    where lookup_type = 'ZX_TAX_TYPE_CATEGORY'
    and lookup_code = code;


 vcode varchar2(60);
 vname varchar2(200);
 vcode_name varchar2(60);
 vtype_code varchar2(60);
 vprecedence number;
 vtaxtypename varchar(100);

 etype varchar2( 30 );
 pexempt number;

begin
   d := null;
   vtype_code := null;

   if vat_tax_id is not null
   then
      open tax_type_c(vat_tax_id);
      fetch tax_type_c into vtype_code, vprecedence;

      if tax_type_c%NOTFOUND
      then
        open tax_type_name_c(vtype_code);
        fetch tax_type_name_c into vtaxtypename;
          d := vtaxtypename||' @ '||ltrim(to_char(tax_rate, '990D99'));
        close tax_type_name_c;
      else
          if (vtype_code = 'SALES')
          then
              d := d || ' ' || arp_standard.fnd_message( 'AR_REPORTS_SALES_TAX', 'TAX_RATE', ltrim(to_char(tax_rate, '9990D00')));
          ELSE
            if ( vtype_code = 'VAT' or (vtype_code is null)) then
              open vat_tax_c(vat_tax_id);
              fetch vat_tax_c into vcode, vname;

        	  vcode_name := vcode;	-- Print Tax Code
              d := arp_standard.fnd_message( 'AR_REPORTS_VAT_TAX', 'TAX_CODE', rpad(VCODE_NAME,10), 'EURO_TAXABLE_AMOUNT', '', 'TAX_RATE', ltrim(to_char(tax_rate, '990D99')));

              close vat_tax_c;
            end if;
          END IF;
       end if;

       close tax_type_c;
   end if;

   if tax_exemption_id is not null and ( vat_tax_id is null )
   then
      open exem_c( tax_exemption_id );
      fetch exem_c into etype, pexempt;
      if exem_c%NOTFOUND
      then
         d := d || ' ' ||  arp_standard.fnd_message('AR_IP_NO_TAX_EXEM_ID',
 'TAX_EXEMPTION_ID', ltrim(to_char( tax_exemption_id )));
      else
         d := d || ' ' ||  arp_standard.fnd_message( 'AR_IP_TAX_EXEMPTION',                'EXEMPTION_TYPE', initcap(etype),
                'PERCENT_EXEMPT', ltrim(to_char(pexempt, '990D99')));
      end if;
      close exem_c;

  end if;

  if vprecedence is not null
  then
      d := d || ' ' || arp_standard.fnd_message( 'AR_REPORTS_PRECEDENCE') || ' ' ||
           ltrim(to_char( vprecedence,'9990') );
  end if;

  -- If you know what tax it is but no message generated so far, we create a general message.
  if vtype_code is not null and d is null then
      open tax_type_name_c(vtype_code);
      fetch tax_type_name_c into vtaxtypename;
        d := vtaxtypename||' @ '||ltrim(to_char(tax_rate, '990D99'));
      close tax_type_name_c;

  end if;

  return( ltrim(d, ' '));

EXCEPTION
	WHEN OTHERS THEN
		return null;

end ;

/* Create duplicate content areas and area_items_map while duplicating a template.
   Template row is already duplicated in the framework and will get committed
   along with these inserts.
   */
procedure create_dup_areas(
  p_orig_template_id IN NUMBER,
  p_dup_template_id IN NUMBER
) IS


cursor c_org_ca_b IS
  select
    CA.ITEM_LABEL_STYLE,
    CA.ITEM_VALUE_STYLE,
    CA.CONTENT_DISP_PROMPT_STYLE,
    CA.INVOICE_LINE_TYPE,
    CA.AREA_CODE,
    CA.PARENT_AREA_CODE,
    CA.LINE_REGION_FLAG,
    CA.CONTENT_COUNT,
    CA.CONTENT_AREA_RIGHT_SPACE,
    CA.CONTENT_AREA_TOP_SPACE,
    CA.CONTENT_AREA_BOTTOM_SPACE,
    CA.DISPLAY_LEVEL,
    CA.CONTENT_TYPE,
    CA.CONTENT_ORIENTATION,
    CA.CONTENT_STYLE_ID,
    CA.ITEM_ID,
    CA.URL_ID,
    CA.DISPLAY_SEQUENCE,
    CA.CONTENT_AREA_WIDTH,
    CA.CONTENT_AREA_LEFT_SPACE,
    CA.ITEM_COLUMN_WIDTH,
    CA.CONTENT_AREA_ID
   from ar_bpa_content_areas_b CA
where CA.template_id = p_orig_template_id
order by CA.content_area_id;

l_new_ca_id number := 0;
l_user_id number := -1;
BEGIN

/*
  1. insert into ca_b, ca_tl
  2. insert into area_items
  */
  FOR cabrec in c_org_ca_b
  LOOP
		    select ar_bpa_content_areas_s.nextval
		    into l_new_ca_id
		    from dual;

			  insert into AR_BPA_CONTENT_AREAS_B (
			    ITEM_LABEL_STYLE,
			    ITEM_VALUE_STYLE,
			    CONTENT_DISP_PROMPT_STYLE,
			    INVOICE_LINE_TYPE,
			    AREA_CODE,
			    PARENT_AREA_CODE,
			    LINE_REGION_FLAG,
			    CONTENT_COUNT,
			    CONTENT_AREA_RIGHT_SPACE,
			    CONTENT_AREA_TOP_SPACE,
			    CONTENT_AREA_BOTTOM_SPACE,
			    CONTENT_AREA_ID,
			    DISPLAY_LEVEL,
			    CONTENT_TYPE,
			    CONTENT_ORIENTATION,
			    TEMPLATE_ID,
			    CONTENT_STYLE_ID,
			    ITEM_ID,
			    URL_ID,
			    DISPLAY_SEQUENCE,
			    CONTENT_AREA_WIDTH,
			    CONTENT_AREA_LEFT_SPACE,
			    CREATION_DATE,
			    CREATED_BY,
			    LAST_UPDATE_DATE,
			    LAST_UPDATED_BY,
			    LAST_UPDATE_LOGIN,
                      ITEM_COLUMN_WIDTH
			  ) values (
			    cabrec.ITEM_LABEL_STYLE,
			    cabrec.ITEM_VALUE_STYLE,
			    cabrec.CONTENT_DISP_PROMPT_STYLE,
			    cabrec.INVOICE_LINE_TYPE,
			    cabrec.AREA_CODE,
			    cabrec.PARENT_AREA_CODE,
			    cabrec.LINE_REGION_FLAG,
			    cabrec.CONTENT_COUNT,
			    cabrec.CONTENT_AREA_RIGHT_SPACE,
			   	cabrec.CONTENT_AREA_TOP_SPACE,
			    cabrec.CONTENT_AREA_BOTTOM_SPACE,
			    l_new_ca_id,
			    cabrec.DISPLAY_LEVEL,
			    cabrec.CONTENT_TYPE,
			    cabrec.CONTENT_ORIENTATION,
			    p_dup_template_id,
			    cabrec.CONTENT_STYLE_ID,
			    cabrec.ITEM_ID,
			    cabrec.URL_ID,
			    cabrec.DISPLAY_SEQUENCE,
			    cabrec.CONTENT_AREA_WIDTH,
			    cabrec.CONTENT_AREA_LEFT_SPACE,
			    sysdate,
			    l_user_id,
			    sysdate,
			    l_user_id,
			    l_user_id,
                      cabrec.ITEM_COLUMN_WIDTH
			 );

		  insert into AR_BPA_CONTENT_AREAS_TL (
		    CONTENT_AREA_ID,
		    CONTENT_AREA_NAME,
		    CONTENT_DISPLAY_PROMPT,
		    CREATED_BY,
		    CREATION_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    LANGUAGE,
		    SOURCE_LANG
		  ) select
		    l_new_ca_id,
		    CONTENT_AREA_NAME,
		    CONTENT_DISPLAY_PROMPT,
		    l_user_id,
		    sysdate,
		    l_user_id,
		    sysdate,
		    l_user_id,
		    LANGUAGE,
		    SOURCE_LANG
		  from AR_BPA_CONTENT_AREAS_TL
		  where CONTENT_AREA_ID = cabrec.CONTENT_AREA_ID;
		END LOOP;

		/* insert item_id of original template into ar_bpa_area_items_map table  */
		insert into ar_bpa_area_items
		( area_item_id,
		  template_id,
			parent_area_code,
			display_level,
			secondary_app_id,
			item_id,
			display_sequence,
		    data_source_id,
		    flexfield_item_flag,
		  created_by,
		  creation_date,
		  last_updated_by,
		  last_update_date,
		  last_update_login)
		select ar_bpa_area_items_s.nextval,
			  p_dup_template_id,
		    ca.parent_area_code,
		    ca.display_level,
		    decode(item.seeded_application_id,222,-1, item.seeded_application_id),
		    ca.item_id,
		    ca.display_sequence,
		    item.data_source_id,
		    item.flexfield_item_flag,
		    l_user_id,
		    sysdate,
		    l_user_id,
		    sysdate,
		    l_user_id
		from ar_bpa_content_areas_b ca , ar_bpa_items_vl item
		where ca.template_id = p_orig_template_id
		and ca.item_id is not null
		and ca.item_id = item.item_id
		;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END create_dup_areas;

procedure DELETE_FLEXFIELD_ITEMS (
  P_DATASRC_APP_ID in NUMBER
) is
begin
  delete from AR_BPA_ITEMS_TL
  where item_id in (select item_id from ar_bpa_items_b
                               where SEEDED_APPLICATION_ID = P_DATASRC_APP_ID);

  delete from AR_BPA_ITEMS_B
  where SEEDED_APPLICATION_ID = P_DATASRC_APP_ID;

end DELETE_FLEXFIELD_ITEMS;

procedure UPDATE_VIEW_ITEM (
  P_ITEM_ID in NUMBER default null,
  P_ITEM_CODE in VARCHAR2,
  P_DISPLAY_LEVEL in VARCHAR2,
  P_DATA_SOURCE_ID in NUMBER,
  P_DISPLAY_ENABLED_FLAG in VARCHAR2,
  P_SEEDED_APPLICATION_ID in NUMBER,
  P_DATA_TYPE in VARCHAR2,
  P_COLUMN_NAME in VARCHAR2,
  P_ITEM_NAME in VARCHAR2,
  P_DISPLAY_PROMPT in VARCHAR2,
  P_ITEM_DESCRIPTION in VARCHAR2,
  P_FLEXFIELD_ITEM_FLAG in VARCHAR2,
  P_AMOUNT_ITEM_FLAG IN VARCHAR2,
  P_ASSIGNMENT_ENABLED_FLAG IN VARCHAR2,
  P_DISPLAYED_MULTI_LEVEL_FLAG  IN VARCHAR2,
  P_TAX_ITEM_FLAG in VARCHAR2,
  P_TOTALS_ENABLED_FLAG in VARCHAR2,
  P_LINK_ENABLED_FLAG in VARCHAR2,
  P_ITEM_TYPE in VARCHAR2
) is
      row_id             varchar2(64);
      item_id 			 number := -1;
      l_data_source_id  number;
begin
	  l_data_source_id := p_data_source_id;
	  if (p_data_source_id = -1)
	  then
		l_data_source_id := null;
	  end if;

    AR_BPA_ITEMS_PKG.UPDATE_ROW (
		X_AMOUNT_ITEM_FLAG         => P_AMOUNT_ITEM_FLAG,
		X_ASSIGNMENT_ENABLED_FLAG  => P_ASSIGNMENT_ENABLED_FLAG,
		X_DATA_SOURCE_ID           => l_DATA_SOURCE_ID,
		X_DISPLAY_ENABLED_FLAG     => P_DISPLAY_ENABLED_FLAG,
		X_DISPLAY_LEVEL            => P_DISPLAY_LEVEL,
		X_DISPLAY_PROMPT           => P_DISPLAY_PROMPT,
		X_ITEM_CODE                => P_ITEM_CODE,
		X_ITEM_DESCRIPTION         => P_ITEM_DESCRIPTION,
		X_ITEM_ID                  => P_ITEM_ID,
		X_ITEM_IMAGE_FILENAME      => null,
		X_ITEM_MESSAGE_NAME        => null,
		X_ITEM_NAME                => P_ITEM_NAME,
		X_ITEM_SOURCE              => 'P',
		X_ITEM_TEXT_VALUE          => null,
		X_ITEM_TYPE                => P_ITEM_TYPE,
		X_URL_ID                   => null,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => 0,
        X_LAST_UPDATE_LOGIN => 0,
		X_DISPLAYED_MULTI_LEVEL_FLAG => P_DISPLAYED_MULTI_LEVEL_FLAG,
		X_SEEDED_APPLICATION_ID => P_SEEDED_APPLICATION_ID,
		X_TAX_ITEM_FLAG			   => P_TAX_ITEM_FLAG,
		X_TOTALS_ENABLED_FLAG	   => P_TOTALS_ENABLED_FLAG,
		X_LINK_ENABLED_FLAG		   => P_LINK_ENABLED_FLAG,
		X_DATA_TYPE 			   => P_DATA_TYPE,
		X_COLUMN_NAME 			   => P_COLUMN_NAME,
		X_URLCFG_ENABLED_FLAG	   => null,
		X_FLEXFIELD_ITEM_FLAG	   => P_FLEXFIELD_ITEM_FLAG);
    exception
       when NO_DATA_FOUND then
       	   select ar_bpa_items_s.nextval
       	   INTO item_id
       	   from dual;
           AR_BPA_ITEMS_PKG.INSERT_ROW (
                 X_ROWID => row_id,
				X_AMOUNT_ITEM_FLAG         => P_AMOUNT_ITEM_FLAG,
				X_ASSIGNMENT_ENABLED_FLAG  => P_ASSIGNMENT_ENABLED_FLAG,
				X_DATA_SOURCE_ID           => l_DATA_SOURCE_ID,
				X_DISPLAY_ENABLED_FLAG     => P_DISPLAY_ENABLED_FLAG,
				X_DISPLAY_LEVEL            => P_DISPLAY_LEVEL,
				X_DISPLAY_PROMPT           => P_DISPLAY_PROMPT,
				X_ITEM_CODE                => P_ITEM_CODE,
				X_ITEM_DESCRIPTION         => P_ITEM_DESCRIPTION,
				X_ITEM_ID                  => item_id,
				X_ITEM_IMAGE_FILENAME      => null,
				X_ITEM_MESSAGE_NAME        => null,
				X_ITEM_NAME                => P_ITEM_NAME,
				X_ITEM_SOURCE              => 'P',
				X_ITEM_TEXT_VALUE          => null,
				X_ITEM_TYPE                => P_ITEM_TYPE,
				X_URL_ID                   => null,
                X_CREATION_DATE => sysdate,
                X_CREATED_BY => 0,
                X_LAST_UPDATE_DATE => sysdate,
                X_LAST_UPDATED_BY => 0,
                X_LAST_UPDATE_LOGIN => 0,
				X_DISPLAYED_MULTI_LEVEL_FLAG => P_DISPLAYED_MULTI_LEVEL_FLAG,
				X_SEEDED_APPLICATION_ID => P_SEEDED_APPLICATION_ID,
				X_TAX_ITEM_FLAG			   => P_TAX_ITEM_FLAG,
				X_TOTALS_ENABLED_FLAG	   => P_TOTALS_ENABLED_FLAG,
				X_LINK_ENABLED_FLAG		   => P_LINK_ENABLED_FLAG,
				X_DATA_TYPE 			   => P_DATA_TYPE,
				X_COLUMN_NAME 			   => P_COLUMN_NAME,
				X_URLCFG_ENABLED_FLAG	   => null,
				X_FLEXFIELD_ITEM_FLAG	   => P_FLEXFIELD_ITEM_FLAG);
end UPDATE_VIEW_ITEM;

procedure DELETE_VIEW_ITEM (
  P_ITEM_ID in NUMBER
) is
begin
	 AR_BPA_ITEMS_PKG.DELETE_ROW(
	  	X_ITEM_ID => P_ITEM_ID );
end DELETE_VIEW_ITEM;

begin

--arp_global.init_global;
--arp_standard.init_standard;
pg_debug  := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

end AR_BPA_UTILS_PKG;

/
