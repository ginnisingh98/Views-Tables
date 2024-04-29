--------------------------------------------------------
--  DDL for Package Body POA_DBI_SUTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_SUTIL_PKG" AS
/* $Header: poadbisutilb.pls 120.22 2006/08/27 19:15:11 sriswami noship $ */

 PROCEDURE populate_mv_bmap(p_mv_bmap_tbl out NOCOPY poa_dbi_mv_bmap_tbl, p_mv_set in varchar2) ;
 PROCEDURE add_dimension(p_dim IN VARCHAR2,
			p_func_area IN VARCHAR2,
			p_version IN VARCHAR2,
			p_role IN VARCHAR2,
			p_mv_set IN VARCHAR2,
			p_generate_where_clause IN VARCHAR2,
			p_dim_map IN OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map);

 FUNCTION get_bmap(p_dim IN VARCHAR2) RETURN NUMBER;

 PROCEDURE get_binds(
			 p_trend	IN VARCHAR2,
			 p_mv_set	IN VARCHAR2,
			 p_xtd IN VARCHAR2,
			 p_comparison_type IN VARCHAR2,
                         x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                         p_context_code IN VARCHAR2,
                         p_param IN BIS_PMV_PAGE_PARAMETER_TBL
                          ) ;
  function get_msg (p_current in varchar2)return varchar2;

PROCEDURE bind_reqfact_date(
  p_custom_output IN OUT NOCOPY bis_query_attributes_tbl)
is
   l_last_refresh_date date;
   l_custom_rec BIS_QUERY_ATTRIBUTES;
 begin

   IF p_custom_output is null THEN
     p_custom_output := bis_query_attributes_tbl();
   END IF;

  l_last_refresh_date := fnd_date.displaydt_to_date(
		bis_collection_utilities.get_last_refresh_period('POAREQLN'));

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  l_custom_rec.attribute_name := '&REQ_FACT_UPDATE_DATE';
  l_custom_rec.attribute_value := to_char(l_last_refresh_date,'DD/MM/YYYY HH24:MI:SS');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

END bind_reqfact_date;

FUNCTION get_filter_where(p_cols in  POA_DBI_FILTER_TBL)
	return VARCHAR2 IS
	l_where VARCHAR2(1000);

BEGIN
  l_where := 'coalesce(';
  for i in 1..p_cols.COUNT LOOP
     if(i <> 1) then
	l_where := l_where || ',';
     end if;
     l_where := l_where || '
	decode(' || p_cols(i) || ',0,null,' || p_cols(i) || ')';
  END LOOP;

  l_where := l_where || ' ) is not null ';

  return l_where;
END;

PROCEDURE process_parameters(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                               p_view_by out NOCOPY VARCHAR2,
 			       p_view_by_col_name OUT NOCOPY VARCHAR2,
 			       p_view_by_value OUT NOCOPY VARCHAR2,
                               p_comparison_type out NOCOPY VARCHAR2,
                               p_xtd out NOCOPY VARCHAR2,
                               p_as_of_date out NOCOPY DATE,
                               p_prev_as_of_date out NOCOPY DATE,
                               p_cur_suffix out NOCOPY VARCHAR2,
                               p_nested_pattern out NOCOPY NUMBER,
			       p_where_clause out NOCOPY VARCHAR2,
			       p_mv out NOCOPY VARCHAR2,
			       p_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl,
			       p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
			       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
       			       p_trend in VARCHAR2,
			       p_func_area IN VARCHAR2,
			       p_version IN VARCHAR2,
			       p_role IN VARCHAR2,
			       p_mv_set IN VARCHAR2)
  IS
  l_dim_map poa_dbi_util_pkg.poa_dbi_dim_map;
  l_dim_bmap NUMBER;
  l_commodity_value varchar2(10) := null;
  l_region_code varchar2(30) := null;
  l_company_value varchar2(30) := 'All';
  l_cost_center_value varchar2(30) := 'All';
  l_aggregation_level NUMBER;
  l_context_code VARCHAR2(10) := 'OU/COM';

  l_and_agg_col VARCHAR2(50);
  BEGIN
	l_dim_bmap :=0;
        l_context_code := get_sec_context(p_param);
	init_dim_map(l_dim_map, p_func_area, p_version, p_role, p_mv_set);

  	poa_dbi_util_pkg.get_parameter_values(p_param, l_dim_map,p_view_by, p_comparison_type, p_xtd, p_as_of_date, p_prev_as_of_date, p_cur_suffix, p_nested_pattern,l_dim_bmap );


       --- Begin Spend Analysis Trend change
        IF(p_mv_set='FIIIV' OR p_mv_set='FIIPA')
        THEN
           IF(p_cur_suffix = 'g')
           THEN p_cur_suffix := 'prim_g' ;
           ELSIF(p_cur_suffix = 'sg')
           THEN p_cur_suffix := 'sec_g';
           END IF ;
        END IF ; --p_mv_set
       ---ENd Spend Analysis Trend change

/* add in the security dimensions that must always be present in bmap */
        IF(l_context_code = 'SUPPLIER') THEN
	  l_dim_bmap := poa_dbi_util_pkg.bitor(l_dim_bmap,SUPPLIER_BMAP);
        ELSIF(l_context_code = 'COMP') THEN
	  l_dim_bmap := poa_dbi_util_pkg.bitor(l_dim_bmap,COMPANY_BMAP);
	  l_dim_bmap := poa_dbi_util_pkg.bitor(l_dim_bmap,COSTCTR_BMAP);
        ELSIF(l_context_code = 'OU/COM' OR l_context_code = 'OU' OR l_context_code = 'NEG' OR l_context_code = 'OUX' ) THEN
	  l_dim_bmap := poa_dbi_util_pkg.bitor(l_dim_bmap, OPER_UNIT_BMAP);
          /* if the role is commodity manager then commodity should be added to bmap*/
        if (((p_role = 'COM') AND (l_context_code = 'OU/COM'))
	     OR (l_context_code = 'NEG')) then
	        l_dim_bmap := poa_dbi_util_pkg.bitor(l_dim_bmap, COMMODITY_BMAP);
	      end if;
         END IF;

         if(p_mv_set='POD' or p_mv_set='PODCUT') then
           p_mv := 'POA_POD_BS_MV';
         elsif(p_mv_set='PODA' or p_mv_set='PODCUTA') then /*pod aggregated mv*/
           p_mv := 'POA_POD_002_MV';
         elsif(p_mv_set='PODB' or p_mv_set='PODCUTB') then /*pod base mv*/
           p_mv := 'POA_POD_001_MV';
         elsif(p_mv_set='API') then
           p_mv := 'POA_API_BS_MV';
         elsif(p_mv_set='APIA') then /*api aggregated mv*/
           p_mv := 'POA_API_002_MV';
         elsif(p_mv_set='APIB') then /*api base mv*/
           p_mv := 'POA_API_001_MV';
         elsif(p_mv_set='PQC') then
           p_mv := 'POA_PQC_BS_MV';
         elsif(p_mv_set='PQCA') then /*pqc aggregated mv*/
           p_mv := 'POA_PQC_002_MV';
         elsif(p_mv_set='PQCB') then /*pqc base mv*/
           p_mv := 'POA_PQC_001_MV';
         elsif(p_mv_set = 'RTX') then
           p_mv := 'POA_RTX_BS_MV';
         elsif(p_mv_set = 'IDL') then
           p_mv := 'POA_IDL_BS_MV';
         elsif(p_mv_set='IDLA') then /*idl aggregated mv*/
           p_mv := 'POA_IDL_002_MV';
         elsif(p_mv_set='IDLB') then /*idl base mv*/
           p_mv := 'POA_IDL_001_MV';
         elsif(p_mv_set = 'MID') then
           p_mv := 'POA_MID_BS_MV';
	 elsif(p_mv_set = 'REQMP') then
	   p_mv := 'POA_REQ_001_MV';
	 elsif(p_mv_set = 'REQMF') then
	   p_mv := 'POA_REQ_002_MV';
	 elsif(p_mv_set = 'REQS') then
	   p_mv := 'POA_REQ_000_MV';
       --- Begin Spend Analysis Trend change
         elsif(p_mv_set='FIIIV')
         then p_mv := 'FII_AP_IVATY_XB_MV';
         elsif(p_mv_set='FIIPA')
         then p_mv := 'FII_AP_PAID_XB_MV';
       --- End  Spend Analysis Trend change
       --- Begin Sourcing Management Change
         elsif(p_mv_set = 'NEG') then
	    p_mv := 'POA_NEG_001_MV';
       --- End Sourcing Management Change
	 end if;

         l_aggregation_level := get_agg_level(l_dim_bmap, p_mv_set);

	if(l_dim_map.exists(p_view_by)) then
		p_view_by_col_name := l_dim_map(p_view_by).col_name;
		p_view_by_value := l_dim_map(p_view_by).value;
	end if;

	if(p_mv_set = 'REQS') then
	  p_where_clause := '2=2';
	else
	  p_where_clause := '';
        end if;

       --- Begin Spend Analysis Trend change
        IF p_mv_set = 'FIIIV' OR p_mv_set = 'FIIPA'
        THEN
           l_and_agg_col := ' and fact.gid=' ;
        ELSE
           l_and_agg_col := ' and fact.aggregation_level=' ;
        END IF ;
       --- End Spend Analysis Trend change

	p_where_clause := p_where_clause
		|| l_and_agg_col
		|| l_aggregation_level || ' '
		||  poa_dbi_util_pkg.get_where_clauses(l_dim_map, p_trend)
		|| get_in_security_where_clauses(
  			  l_dim_map
			, l_context_code
			, p_func_area
			, p_version
			, p_role
			, p_trend);

	get_join_info(p_view_by, l_dim_map,p_join_tbl, p_func_area, p_version);

	populate_in_join_tbl(p_in_join_tbl, p_param, l_dim_map, l_context_code, p_version, p_mv_set, p_where_clause);

	get_binds(p_trend,p_mv_set,p_xtd,p_comparison_type,x_custom_output, l_context_code, p_param);

  END process_parameters;

PROCEDURE drill_process_parameters(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                             p_cur_suffix out NOCOPY VARCHAR2,
                             p_where_clause out NOCOPY VARCHAR2,
                             p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl,
                             p_func_area IN VaRCHAR2,
                             p_version IN VARCHAR2,
                             p_role IN VARCHAR2,
                             p_mv_set IN VARCHAR2)
  IS
  l_dim_map poa_dbi_util_pkg.poa_dbi_dim_map;
  l_context_code VARCHAR2(10) := 'OU/COM';
  l_where_clause_unused varchar2(500);
BEGIN

        l_context_code := get_sec_context(p_param);

	init_dim_map(l_dim_map, p_func_area, p_version, p_role, p_mv_set);

        poa_dbi_util_pkg.get_drill_param_values(p_param, l_dim_map, p_cur_suffix);

        p_where_clause :=poa_dbi_util_pkg.get_where_clauses(l_dim_map, 'N')
                || get_in_security_where_clauses(l_dim_map, l_context_code , p_func_area, p_version, p_role, 'N');

        /* note that we are passing a dummy to the p_where_clause parameter. The drill report is
         * expected to provide its own security filters*/
        populate_in_join_tbl(p_in_join_tbl, p_param, l_dim_map, l_context_code, p_version, p_mv_set, l_where_clause_unused);

END;

/* OBSOLETE-- No new code should call this. Use
  get_in_security_where_clauses instead */
FUNCTION get_security_where_clauses(p_dim_map poa_dbi_util_pkg.poa_dbi_dim_map,
	p_func_area in VARCHAR2,
	p_version in VARCHAR2,
	p_role in VARCHAR2,
	p_trend in VARCHAR2 := 'N') return VARCHAR2 IS
l_sec_where_clause VARCHAR2(1000):='';
l_commod_where VARCHAR2(1000);
l_ou_where VARCHAR2(1000);
BEGIN

	l_ou_where := poa_dbi_util_pkg.get_ou_sec_where(
		p_dim_map('ORGANIZATION+FII_OPERATING_UNITS').value,
		p_dim_map('ORGANIZATION+FII_OPERATING_UNITS').col_name,
		p_trend);
	if(l_ou_where is not null) then
		l_sec_where_clause := l_sec_where_clause || ' and ' || l_ou_where;
	end if;

  if(p_version = '6.0') then
	l_commod_where := poa_dbi_util_pkg.get_commodity_sec_where(
		p_dim_map('ITEM+POA_COMMODITIES').value,
		p_trend);
	if(l_commod_where is not null ) then
		l_sec_where_clause := l_sec_where_clause || ' and ' || l_commod_where;
	end if;
  end if;

	return l_sec_where_clause;
END;

FUNCTION get_in_security_where_clauses(p_dim_map poa_dbi_util_pkg.poa_dbi_dim_map,
        p_context_code in VARCHAR2,
        p_func_area in VARCHAR2,
        p_version in VARCHAR2,
        p_role in VARCHAR2,
        p_trend in VARCHAR2 := 'N') return VARCHAR2 IS
l_in_sec_where_clause VARCHAR2(1000) :='';
l_commod_where VARCHAR2(1000) := '';
l_sup_where VARCHAR2(1000) := '';
l_ou_where VARCHAR2(1000) := '';
BEGIN
  IF(p_context_code = 'OU/COM' or p_context_code ='OU' or p_context_code = 'NEG'
     OR p_context_code = 'OUX' ) THEN
        l_ou_where := poa_dbi_util_pkg.get_in_ou_sec_where(
                p_dim_map('ORGANIZATION+FII_OPERATING_UNITS').value,
                p_dim_map('ORGANIZATION+FII_OPERATING_UNITS').col_name,
                p_use_bind => 'N');
        if(l_ou_where is not null) then
                l_in_sec_where_clause := l_ou_where;
        end if;
    IF(p_context_code = 'OU/COM' or p_context_code = 'NEG') THEN
     if(p_version = '6.0' or p_version = '7.0' or p_version = '8.0') then
        l_commod_where := poa_dbi_util_pkg.get_in_commodity_sec_where(
                p_dim_map('ITEM+POA_COMMODITIES').value,
                p_trend);
        if(l_commod_where is not null ) then
                l_in_sec_where_clause := l_in_sec_where_clause || l_commod_where;
        end if;
     end if;
   END IF;
 ELSIF(p_context_code='SUPPLIER') THEN
        l_sup_where := poa_dbi_util_pkg.get_in_supplier_sec_where(p_dim_map('SUPPLIER+POA_SUPPLIERS').value);
	IF(l_sup_where IS NOT NULL) THEN
	  l_in_sec_where_clause := l_in_sec_where_clause || l_sup_where;
        END IF;
 END IF;
  return l_in_sec_where_clause;
END;


PROCEDURE add_dimension(p_dim IN VARCHAR2,
			p_func_area IN VARCHAR2,
			p_version IN VARCHAR2,
			p_role IN VARCHAR2,
			p_mv_set IN VARCHAR2,
			p_generate_where_clause IN VARCHAR2,
			p_dim_map IN OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map) IS

l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

BEGIN
	l_dim_rec.col_name := get_col_name(p_dim,p_func_area, p_version, p_mv_set);
	l_dim_rec.view_by_table := get_table(p_dim, p_func_area, p_version);
	l_dim_rec.generate_where_clause := p_generate_where_clause;
	l_dim_rec.bmap := get_bmap(p_dim);
	p_dim_map(p_dim) := l_dim_rec;
END;


PROCEDURE init_dim_map(p_dim_map out NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map,
	p_func_area IN VARCHAR2,
	p_version IN VARCHAR2,
	p_role IN VARCHAR2,
	p_mv_set IN VARCHAR2) IS

l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

BEGIN

add_dimension('HRI_PERSON+HRI_PER',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('SUPPLIER+POA_SUPPLIERS',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('SUPPLIER+POA_SUPPLIER_SITES',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('ORGANIZATION+FII_OPERATING_UNITS',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
 add_dimension('LOOKUP+RETURN_REASON',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('ITEM+POA_COMMODITIES',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('LOOKUP+CONTRACT_DOCTYPE',
			p_func_area,
			p_version,
			p_role,
                      	p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('ITEM+ENI_ITEM_PO_CAT',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('ITEM+POA_ITEMS',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('POA_PERSON+REQUESTER',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('FII_COMPANIES+FII_COMPANIES',
                        p_func_area,
                        p_version,
                        p_role,
                        p_mv_set,
                        p_generate_where_clause => 'N',
                        p_dim_map => p_dim_map);
add_dimension('ORGANIZATION+HRI_CL_ORGCC',
                        p_func_area,
                        p_version,
                        p_role,
                        p_mv_set,
                        p_generate_where_clause => 'N',
                        p_dim_map => p_dim_map);
add_dimension('POA_PERSON+NEG_CREATOR',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('LOOKUP+NEG_DOCTYPES',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
add_dimension('POA_PERSON+INV_CREATOR',
			p_func_area,
			p_version,
			p_role,
			p_mv_set,
			p_generate_where_clause => 'Y',
			p_dim_map => p_dim_map);
END;

FUNCTION get_col_name(dim_name VARCHAR2, p_func_area in VARCHAR2, p_version in VARCHAR2, p_mv_set in VARCHAR2) return VARCHAR2
is
  l_col_name varchar2(100);

  begin
  if(dim_name = 'ORGANIZATION+FII_OPERATING_UNITS') then
	l_col_name := 'org_id';
   elsif(dim_name = 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION') THEN
     IF (p_mv_set in ('PQC','API','REQS','REQMP','REQMF')) THEN
	l_col_name := 'ship_to_org_id';
      ELSE
	l_col_name := 'receiving_org_id';
     END IF;
  elsif(dim_name = 'ITEM+ENI_ITEM_PO_CAT') then
	l_col_name := 'category_id';
  elsif(dim_name ='ITEM+POA_ITEMS') then
	l_col_name := 'po_item_id';
  elsif(dim_name ='HRI_PERSON+HRI_PER' ) then
	if(p_mv_set = 'IDL' or p_mv_set = 'MID' or
           p_mv_set = 'IDLA' or p_mv_set = 'IDLB') then
		l_col_name := 'inv_d_created_by';
	else
		l_col_name := 'buyer_id';
	end if;
  elsif(dim_name = 'POA_PERSON+INV_CREATOR') then
        l_col_name := 'inv_d_created_by';
  elsif(dim_name = 'POA_PERSON+REQUESTER') then
	l_col_name := 'requester_id';
  elsif(dim_name = 'SUPPLIER+POA_SUPPLIERS') then
	l_col_name := 'supplier_id';
  elsif(dim_name ='SUPPLIER+POA_SUPPLIER_SITES') then
	l_col_name := 'supplier_site_id';
  elsif(dim_name = 'ITEM+POA_COMMODITIES') then
	l_col_name := 'commodity_id';
  elsif(dim_name = 'LOOKUP+RETURN_REASON') then
	l_col_name := 'reason_id';
  elsif(dim_name = 'LOOKUP+CONTRACT_DOCTYPE') then
        l_col_name := 'contract_type';
  elsif(dim_name = 'FII_COMPANIES+FII_COMPANIES') then
        l_col_name := 'company_id';
  elsif(dim_name = 'ORGANIZATION+HRI_CL_ORGCC') then
        l_col_name := 'cost_center_id';
  elsif(dim_name = 'POA_PERSON+NEG_CREATOR') then
        l_col_name := 'negotiation_creator_id';
  elsif(dim_name = 'LOOKUP+NEG_DOCTYPES') then
        l_col_name := 'doctype_id';
  end if;

  return l_col_name;
END;

 FUNCTION get_bmap(p_dim IN VARCHAR2) RETURN NUMBER IS
	l_bmap NUMBER;
 BEGIN
	l_bmap := (case p_dim
 WHEN 'ORGANIZATION+FII_OPERATING_UNITS' THEN OPER_UNIT_BMAP
  WHEN 'ITEM+ENI_ITEM_PO_CAT' THEN CATEGORY_BMAP
  WHEN 'ITEM+POA_ITEMS' THEN  ITEM_BMAP
  WHEN 'HRI_PERSON+HRI_PER' THEN  BUYER_BMAP
  WHEN 'POA_PERSON+INV_CREATOR' THEN CLERK_BMAP
  WHEN 'SUPPLIER+POA_SUPPLIERS' THEN  SUPPLIER_BMAP
  WHEN 'SUPPLIER+POA_SUPPLIER_SITES' THEN  SUPPLIER_SITE_BMAP
  WHEN 'ITEM+POA_COMMODITIES' THEN  COMMODITY_BMAP
  WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN  REC_ORG_BMAP
  WHEN 'LOOKUP+RETURN_REASON' THEN REASON_BMAP
  WHEN 'LOOKUP+CONTRACT_DOCTYPE' THEN DOCTYPE_BMAP
  WHEN 'POA_PERSON+REQUESTER' THEN REQUESTER_BMAP
  WHEN 'FII_COMPANIES+FII_COMPANIES' THEN COMPANY_BMAP
  WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN COSTCTR_BMAP
  WHEN 'POA_PERSON+NEG_CREATOR' THEN BUYER_BMAP
  WHEN 'LOOKUP+NEG_DOCTYPES' THEN DOCTYPE_BMAP
  ELSE ''
  END);
	return l_bmap;
end;

FUNCTION get_table(dim_name VARCHAR2, p_func_area in VARCHAR2, p_version in VARCHAR2) return VARCHAR2
is
l_table varchar2(4000);

begin

  l_table :=  (CASE dim_name
  WHEN 'ORGANIZATION+FII_OPERATING_UNITS' THEN '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG''))'
  WHEN 'ITEM+ENI_ITEM_PO_CAT' THEN 'eni_item_po_cat_v'
  WHEN 'ITEM+POA_ITEMS' THEN 'poa_items_v '
  WHEN 'HRI_PERSON+HRI_PER' THEN '(select person_id id, substrb(first_name,1,1) || ''. ''|| last_name value from per_all_people_f where sysdate between effective_start_date and effective_end_date)'
  WHEN 'POA_PERSON+INV_CREATOR' THEN '(select person_id id, substrb(first_name,1,1) || ''. ''|| last_name value from per_all_people_f where sysdate between effective_start_date and effective_end_date)'
  WHEN 'SUPPLIER+POA_SUPPLIERS' THEN 'poa_suppliers_v'
  WHEN 'SUPPLIER+POA_SUPPLIER_SITES' THEN 'poa_supplier_sites_v'
  WHEN 'ITEM+POA_COMMODITIES' THEN 'po_commodities_tl'
  WHEN 'ORGANIZATION+OPI_INV_UNSEC_ORGANIZATION' THEN '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG''))'
  WHEN 'LOOKUP+RETURN_REASON' THEN 'mtl_transaction_reasons'
  WHEN 'LOOKUP+CONTRACT_DOCTYPE' THEN 'poa_dbi_contract_type_v'
  WHEN 'POA_PERSON+REQUESTER' THEN '(select person_id id, substrb(first_name,1,1) || ''. ''|| last_name value from per_all_people_f where sysdate between effective_start_date and effective_end_date)'
  WHEN 'FII_COMPANIES+FII_COMPANIES' THEN
       '(select t.flex_value_id id, t.description value, f.summary_flag
         from fnd_flex_values_tl t, fii_com_pmv_agrt_nodes c, fnd_flex_values f
         where c.company_id = t.flex_value_id and t.language = userenv(''LANG'') and t.flex_value_id = f.flex_value_id)'
  WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
       '(select t.flex_value_id id, t.description value, f.summary_flag
         from fnd_flex_values_tl t, fii_cc_pmv_agrt_nodes c, fnd_flex_values f
         where c.cost_center_id = t.flex_value_id and t.language = userenv(''LANG'') and t.flex_value_id = f.flex_value_id)'
  WHEN 'POA_PERSON+NEG_CREATOR' THEN '(select person_id id, substrb(first_name,1,1) || ''. ''|| last_name value from per_all_people_f where sysdate between effective_start_date and effective_end_date)'
  WHEN 'LOOKUP+NEG_DOCTYPES' THEN 'poa_neg_doctypes_v'
  ELSE ''
  END);

  return l_table;
end;



PROCEDURE get_join_info(p_view_by IN varchar2,
		p_dim_map IN poa_dbi_util_pkg.poa_dbi_dim_map,
		x_join_tbl OUT NOCOPY poa_dbi_util_pkg.POA_DBI_JOIN_TBL,
		p_func_area IN varchar2, p_version IN varchar2)
IS
	l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;

BEGIN
	x_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
	if(NOT p_dim_map.exists(p_view_by)) then
		return;
	end if;

	l_join_rec.table_name := p_dim_map(p_view_by).view_by_table;
	l_join_rec.table_alias := 'v';
	l_join_rec.fact_column := p_dim_map(p_view_by).col_name;

	if(p_view_by ='ITEM+POA_COMMODITIES') then
		l_join_rec.additional_where_clause :=
			' (v.language=USERENV(''LANG'') or v.language is null) ';
		l_join_rec.column_name := 'commodity_id';
		l_join_rec.dim_outer_join := 'Y';
	elsif(p_view_by = 'LOOKUP+RETURN_REASON') then
  		l_join_rec.column_name := 'reason_id(+)';
	else
		l_join_rec.column_name := 'id';
	end if;

	if(p_view_by = 'HRI_PERSON+HRI_PER' and p_func_area = 'AP') then
		l_join_rec.dim_outer_join := 'Y';
	end if;
        if(p_view_by = 'POA_PERSON+INV_CREATOR' and p_func_area = 'AP') then
		l_join_rec.dim_outer_join := 'Y';
	end if;
	--Added to handle the unassigned row issue
        if(p_func_area = 'PO' and p_version = '7.1') then
	   if ((p_view_by = 'HRI_PERSON+HRI_PER')
           or (p_view_by = 'SUPPLIER+POA_SUPPLIERS') ) then
	       l_join_rec.dim_outer_join := 'Y';
	   end if;
	end if;

	  if(p_func_area = 'PO' and p_version = '8.0') then
	   if ((p_view_by = 'POA_PERSON+NEG_CREATOR')
           or (p_view_by = 'LOOKUP+NEG_DOCTYPES') ) then
	       l_join_rec.dim_outer_join := 'Y';
	   end if;
	end if;

        if(p_view_by = 'FII_COMPANIES+FII_COMPANIES')then
          l_join_rec.inner_alias := 'com';
        elsif (p_view_by = 'ORGANIZATION+HRI_CL_ORGCC') then
          l_join_rec.inner_alias := 'cc';
        end if;

	x_join_tbl.extend;
  	x_join_tbl(x_join_tbl.count) := l_join_rec;

	if(p_view_by = 'ITEM+POA_ITEMS' and
		(p_version = '6.0' or p_version = '7.0' or p_version='7.1' or p_version='8.0')) then
		l_join_rec.table_name := 'mtl_units_of_measure_vl';
  		l_join_rec.table_alias := 'v2';
  		l_join_rec.fact_column :='base_uom';
  		l_join_rec.column_name := 'unit_of_measure';
		l_join_rec.dim_outer_join := 'Y';

  		x_join_tbl.extend;
  		x_join_tbl(x_join_tbl.count) := l_join_rec;
	end if;

END;


PROCEDURE populate_in_join_tbl(
	p_in_join_tbl out NOCOPY poa_dbi_util_pkg.poa_dbi_in_join_tbl
        , p_param in BIS_PMV_PAGE_PARAMETER_TBL
	, p_dim_map in poa_dbi_util_pkg.poa_dbi_dim_map
	, p_context_code VARCHAR2
	, p_version in VARCHAR2
        , p_mv_set in varchar2
        , p_where_clause in out nocopy varchar2)
 IS
 l_ou_value VARCHAR2(10);
 l_commodity_value VARCHAR2(10);
 l_in_join_rec poa_dbi_util_pkg.POA_DBI_IN_JOIN_REC;
 l_company_value varchar2(30) := 'All';
 l_cost_ctr_value varchar2(30) := 'All';
 l_region_code varchar2(40);
 l_viewby varchar2(50);
 l_sql varchar2(2000);
 l_agg_flag varchar2(1);
 BEGIN

 p_in_join_tbl := poa_dbi_util_pkg.poa_dbi_in_join_tbl();

 IF(p_context_code = 'OU/COM' or p_context_code = 'OU' or p_context_code = 'NEG'
    OR p_context_code = 'OUX'
) THEN
  l_ou_value := p_dim_map('ORGANIZATION+FII_OPERATING_UNITS').value;
  if(l_ou_value is null or
    l_ou_value = '' or
    l_ou_value = 'All') then
     null;
   --l_in_join_rec.table_name := 'per_organization_list';
   --l_in_join_rec.table_alias := 'orgl';
   --p_in_join_tbl.extend;
   --p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

  end if;

   IF(p_context_code = 'OU/COM'  or p_context_code = 'NEG') THEN
    if(p_version = '6.0' or p_version = '7.0' or p_version = '8.0') then
     l_commodity_value := p_dim_map('ITEM+POA_COMMODITIES').value;
     if(l_commodity_value is null or
        l_commodity_value = '' or
        l_commodity_value = 'All') then
         null;
       /* Commented out, as the Security Clauses are handled in Util Package itself
	      l_in_join_rec.table_name := 'po_commodity_grants';
	      l_in_join_rec.table_alias := 'sec';
	      p_in_join_tbl.extend;
	     p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

	      l_in_join_rec.table_name := 'fnd_user';
	      l_in_join_rec.table_alias := 'u';
	      p_in_join_tbl.extend;
	      p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

	      l_in_join_rec.table_name := 'fnd_menu_entries';
	      l_in_join_rec.table_alias := 'poa_me';
	      p_in_join_tbl.extend;
	      p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

  	    l_in_join_rec.table_name := 'fnd_form_functions';
	      l_in_join_rec.table_alias := 'f';
	      p_in_join_tbl.extend;
	      p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec; */
     end if;
    end if;
   END IF;
 ELSIF(p_context_code = 'SUPPLIER') THEN
   null;
 /*         l_in_join_rec.table_name := 'ak_web_user_sec_attr_values';
	    l_in_join_rec.table_alias := 'isp';
	    p_in_join_tbl.extend;
	    p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

 	    l_in_join_rec.table_name := 'fnd_application';
	    l_in_join_rec.table_alias := 'appl';
	    p_in_join_tbl.extend;
	    p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;
  */
  ELSIF(p_context_code = 'COMP') THEN
    /*get ak-region, company, cost-center values*/
    for i in 1..p_param.count loop
      if (p_param(i).parameter_name = 'BIS_REGION_CODE') then
        l_region_code := p_param(i).parameter_value;
      elsif (p_param(i).parameter_name = 'FII_COMPANIES+FII_COMPANIES') then
        l_company_value := nvl(p_param(i).parameter_id,'All');
      elsif (p_param(i).parameter_name = 'ORGANIZATION+HRI_CL_ORGCC') then
        l_cost_ctr_value := nvl(p_param(i).parameter_id,'All');
      elsif (p_param(i).parameter_name = 'VIEW_BY') then
        l_viewby := p_param(i).parameter_value;
      end if;
    end loop;
    if (l_company_value = '''''')then
      l_company_value := 'All';
    end if;
    if (l_cost_ctr_value = '''''')then
      l_cost_ctr_value := 'All';
    end if;
    l_company_value := translate(l_company_value,'''',' ');
    l_cost_ctr_value := translate(l_cost_ctr_value,'''',' ');
    get_company_sql(l_viewby, l_company_value, l_region_code, l_sql, l_agg_flag);
    p_where_clause := p_where_clause || ' and com.child_company_id = fact.company_id ';
    if(p_mv_set = 'APIA' or p_mv_set = 'PODA' or p_mv_set = 'PQCA' or p_mv_set = 'IDLA' or p_mv_set = 'PODCUTA') then
      if(l_sql like '%fii_company_hierarchies%') then
        l_in_join_rec.table_name := '(select /*+no_merge*/ a.parent_company_id, a.company_id, a.company_id child_company_id '||
                                    'from ('||l_sql||')a '||
                                    'where a.com_agg_flag = ''Y'')';
        p_where_clause := p_where_clause || ' and fact.parent_company_id = com.parent_company_id ';
      else
        l_in_join_rec.table_name := '(select /*+no_merge*/ a.company_id, a.company_id child_company_id '||
                                    'from ('||l_sql||')a '||
                                    'where a.com_agg_flag = ''Y'')';
      end if;
    else
      l_in_join_rec.table_name := '(select /*+no_merge*/ a.company_id, com.child_company_id, a.com_agg_flag '||
                                  'from ('||l_sql||')a, '||
                                  'fii_company_hierarchies com '||
                                  'where a.company_id = com.parent_company_id)';
    end if;
    l_in_join_rec.table_alias := 'com';
    l_in_join_rec.aggregated_flag := l_agg_flag;
    p_in_join_tbl.extend;
    p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

    get_cost_ctr_sql(l_viewby, l_cost_ctr_value, l_region_code, l_sql, l_agg_flag);
    p_where_clause := p_where_clause || ' and cc.child_cc_id = fact.cost_center_id ';
    if(p_mv_set = 'APIA' or p_mv_set = 'PODA' or p_mv_set = 'PQCA' or p_mv_set = 'IDLA' or p_mv_set = 'PODCUTA') then
      if(l_sql like '%fii_cost_ctr_hierarchies%') then
        l_in_join_rec.table_name := '(select /*+no_merge*/ b.parent_cc_id, b.cost_center_id, b.cost_center_id child_cc_id '||
                                    'from ('||l_sql||')b '||
                                    'where b.cc_agg_flag = ''Y'')';
        p_where_clause := p_where_clause || ' and fact.parent_cc_id = cc.parent_cc_id ';
      else
        l_in_join_rec.table_name := '(select /*+no_merge*/ b.cost_center_id, b.cost_center_id child_cc_id '||
                                    'from ('||l_sql||')b '||
                                    'where b.cc_agg_flag = ''Y'')';
      end if;
    else
      l_in_join_rec.table_name := '(select /*+no_merge*/ b.cost_center_id, cc.child_cc_id, b.cc_agg_flag '||
                                  'from ('||l_sql||')b, '||
                                  'fii_cost_ctr_hierarchies cc '||
                                  'where b.cost_center_id = cc.parent_cc_id)';
    end if;
    l_in_join_rec.table_alias := 'cc';
    l_in_join_rec.aggregated_flag := l_agg_flag;
    p_in_join_tbl.extend;
    p_in_join_tbl(p_in_join_tbl.count) := l_in_join_rec;

    if(p_mv_set = 'APIB' or p_mv_set = 'PODB' or p_mv_set = 'PQCB' or p_mv_set = 'IDLB' or p_mv_set = 'PODCUTB') then
      p_where_clause := p_where_clause || ' and (com.com_agg_flag = ''N'' or cc.cc_agg_flag = ''N'' ) ';
    end if;

  END IF;
 END;

FUNCTION get_viewby_select_clause(p_viewby IN VARCHAR2, p_func_area IN VARCHAR2,
	p_version IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF(p_func_area = 'PO' and p_version = '7.1') THEN
    IF ((p_viewby = 'HRI_PERSON+HRI_PER')
        or (p_viewby = 'SUPPLIER+POA_SUPPLIERS') ) THEN
       return
         'select decode(v.value,null,fnd_message.get_string'
	|| '(''POA'', ''POA_DBI_APL_UNASSIGNED''),v.value) VIEWBY,'
	|| fnd_global.newline
	|| '	decode(v.id, null, -1, v.id) VIEWBYID,'
	|| fnd_global.newline;
    end if;
  end if;

 IF(p_func_area = 'PO' and p_version = '8.0') THEN
    IF ((p_viewby = 'POA_PERSON+NEG_CREATOR')
        or (p_viewby = 'LOOKUP+NEG_DOCTYPES') ) THEN
       return
         'select decode(v.value,null,fnd_message.get_string'
	|| '(''POA'', ''POA_DBI_APL_UNASSIGNED''),v.value) VIEWBY,'
	|| fnd_global.newline
	|| '	decode(v.id, null, -1, v.id) VIEWBYID,'
	|| fnd_global.newline;
    end if;
  end if;

  if(p_viewby = 'ITEM+POA_COMMODITIES') then
	 return
		'select decode(v.name, null, fnd_message.get_string(''POA'',''POA_DBI_APL_UNASSIGNED''), v.name) VIEWBY,
		        decode(v.commodity_id,null, -1, v.commodity_id) VIEWBYID,';
  elsif(p_viewby = 'LOOKUP+RETURN_REASON') then
	return
		'select decode(v.reason_name, null, fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.reason_name) VIEWBY,
			decode(v.reason_id, null, -1, v.reason_id) VIEWBYID,';
  else
	return
		'select v.value VIEWBY,v.id VIEWBYID,';
  end if;
END;

FUNCTION get_fact_hint(p_mv IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
	return '/*+ INDEX_COMBINE(fact '|| p_mv || ' ' || p_mv ||'_n1) */';
END;


FUNCTION get_agg_level(p_dim_bmap IN NUMBER,
                       p_mv_set IN VARCHAR2)
RETURN NUMBER
IS
 l_index NUMBER:= 1;
 l_cost NUMBER;
 l_agg_lvl_tbl POA_DBI_AGG_LEVEL_TBL;
BEGIN
 populate_agg_level(l_agg_lvl_tbl,p_mv_set);
 l_cost := l_agg_lvl_tbl(1).agg_bmap;
 FOR i IN l_agg_lvl_tbl.FIRST .. l_agg_lvl_tbl.LAST
 LOOP
  IF (bitand(l_agg_lvl_tbl(i).agg_bmap, p_dim_bmap) = p_dim_bmap) THEN
    IF(l_agg_lvl_tbl(i).agg_bmap < l_cost) THEN
       l_cost := l_agg_lvl_tbl(i).agg_bmap;
       l_index := i;
    END IF;
  END IF;
 END LOOP;
 return l_agg_lvl_tbl(l_index).agg_level;
END;

 PROCEDURE populate_agg_level(
                              p_agg_lvl_tbl OUT NOCOPY 	POA_DBI_AGG_LEVEL_TBL,
                              p_mv_set IN VARCHAR2
                             )
  IS
   l_rec POA_DBI_AGG_LEVEL_REC;
  BEGIN
   p_agg_lvl_tbl := POA_DBI_AGG_LEVEL_TBL();
   if(p_mv_set = 'POD'  or p_mv_set='PODCUT') then
      p_agg_lvl_tbl.extend(5);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP
			+ SUPPLIER_BMAP + SUPPLIER_SITE_BMAP
			+ DOCTYPE_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 15;
      l_rec.agg_bmap := OPER_UNIT_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 7;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(4) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP
			+ SUPPLIER_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(5) := l_rec;
   elsif(p_mv_set = 'PODA' or p_mv_set='PODCUTA') then
     p_agg_lvl_tbl.extend(2);
     l_rec.agg_level := 0;
     l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
                       + CATEGORY_BMAP + ITEM_BMAP
                       + SUPPLIER_BMAP + DOCTYPE_BMAP
                       + COMPANY_BMAP + COSTCTR_BMAP;
      p_agg_lvl_tbl(1) := l_rec;
     l_rec.agg_level := 1;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
                       + COMMODITY_BMAP + CATEGORY_BMAP;
     p_agg_lvl_tbl(2) := l_rec;
   elsif(p_mv_set = 'PODB' or p_mv_set='PODCUTB') then
     p_agg_lvl_tbl.extend(4);
     l_rec.agg_level := 0;
     l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
                       + CATEGORY_BMAP + ITEM_BMAP
                       + SUPPLIER_BMAP + DOCTYPE_BMAP
                       + COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(1) := l_rec;
     l_rec.agg_level := 3;
     l_rec.agg_bmap := COMMODITY_BMAP + CATEGORY_BMAP
                       + COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(2) := l_rec;
     l_rec.agg_level := 5;
     l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP
                       + COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(3) := l_rec;
     l_rec.agg_level := 7;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(4) := l_rec;
   ELSIF(p_mv_set = 'REQMP' or p_mv_set = 'REQMF' or p_mv_set ='REQS') THEN
      p_agg_lvl_tbl.extend(4);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + REQUESTER_BMAP
			+ BUYER_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP
			+ REC_ORG_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP
			+ BUYER_BMAP ;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP + BUYER_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

      l_rec.agg_level := 7;
      l_rec.agg_bmap := OPER_UNIT_BMAP;
      p_agg_lvl_tbl(4) := l_rec;

   ELSIF(p_mv_set = 'IDL') THEN
      p_agg_lvl_tbl.extend(3);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP
			+ SUPPLIER_SITE_BMAP + CLERK_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

     l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

   ELSIF(p_mv_set = 'IDLA') THEN
     p_agg_lvl_tbl.extend(2);

     l_rec.agg_level := 0;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
                       + OPER_UNIT_BMAP + SUPPLIER_BMAP
                       + CLERK_BMAP;
     p_agg_lvl_tbl(1) := l_rec;
     l_rec.agg_level := 1;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(2) := l_rec;
   ELSIF(p_mv_set = 'IDLB') THEN
     p_agg_lvl_tbl.extend(2);

     l_rec.agg_level := 0;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
                       + OPER_UNIT_BMAP + SUPPLIER_BMAP
                       + CLERK_BMAP;
     p_agg_lvl_tbl(1) := l_rec;
     l_rec.agg_level := 1;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP;
     p_agg_lvl_tbl(2) := l_rec;
   ELSIF(p_mv_set = 'PQC') THEN
     p_agg_lvl_tbl.extend(3);

     l_rec.agg_level := 0;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ REC_ORG_BMAP + BUYER_BMAP
			+ CATEGORY_BMAP + ITEM_BMAP
			+ SUPPLIER_BMAP + SUPPLIER_SITE_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ CATEGORY_BMAP + SUPPLIER_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

   ELSIF(p_mv_set = 'PQCA') then
     p_agg_lvl_tbl.extend(2);

     l_rec.agg_level := 0;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ CATEGORY_BMAP + ITEM_BMAP
			+ SUPPLIER_BMAP + COMPANY_BMAP
                        + COSTCTR_BMAP;
      p_agg_lvl_tbl(1) := l_rec;
     l_rec.agg_level := 1;
     l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
                       + COMMODITY_BMAP + CATEGORY_BMAP;
     p_agg_lvl_tbl(2) := l_rec;
   ELSIF(p_mv_set = 'PQCB') then
     p_agg_lvl_tbl.extend(4);

     l_rec.agg_level := 0;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ CATEGORY_BMAP + ITEM_BMAP
			+ SUPPLIER_BMAP + COMPANY_BMAP
                        + COSTCTR_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

     l_rec.agg_level := 1;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
			+ SUPPLIER_BMAP + OPER_UNIT_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

     l_rec.agg_level := 2;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
			+ COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

     l_rec.agg_level := 3;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP;
      p_agg_lvl_tbl(4) := l_rec;
   ELSIF(p_mv_set = 'RTX') THEN
      p_agg_lvl_tbl.extend(4);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP
			+ REC_ORG_BMAP
			+ BUYER_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP
			+ SUPPLIER_SITE_BMAP + REASON_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP
			+ CATEGORY_BMAP + SUPPLIER_BMAP ;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP
			+ SUPPLIER_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

      l_rec.agg_level := 7;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP;
      p_agg_lvl_tbl(4) := l_rec;


   ELSIF(p_mv_set = 'MID') THEN

    p_agg_lvl_tbl.extend(3);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP
			+ SUPPLIER_SITE_BMAP + CLERK_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

     l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

   ELSIF(p_mv_set = 'API') THEN
      p_agg_lvl_tbl.extend(3);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP
			+ COMMODITY_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP;
      p_agg_lvl_tbl(3) := l_rec;
    ELSIF(p_mv_set = 'APIA') THEN
      p_agg_lvl_tbl.extend(2);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP + COMMODITY_BMAP
                        + COMPANY_BMAP + COSTCTR_BMAP;
      p_agg_lvl_tbl(1) := l_rec;
      l_rec.agg_level := 1;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP
                        + COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(2) := l_rec;
    ELSIF(p_mv_set = 'APIB') THEN
      p_agg_lvl_tbl.extend(3);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP + COMMODITY_BMAP
                        + COMPANY_BMAP + COSTCTR_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP +
                        SUPPLIER_BMAP + OPER_UNIT_BMAP +
                        COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := COMPANY_BMAP + COSTCTR_BMAP;
      p_agg_lvl_tbl(3) := l_rec;

    ---Begin Spend Analysis Trend Changes
    ELSIF(p_mv_set = 'FIIIV' or p_mv_set = 'FIIPA') THEN
      p_agg_lvl_tbl.extend(2);
      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP ;
      p_agg_lvl_tbl(1) := l_rec ;

      l_rec.agg_level := 4;
      l_rec.agg_bmap := OPER_UNIT_BMAP;
      p_agg_lvl_tbl(2) := l_rec ;
    ---End Spend Analysis Trend Changes

    ---Begin Sourcing Management Change
       ELSIF(p_mv_set = 'NEG') THEN
      p_agg_lvl_tbl.extend(3);

      l_rec.agg_level := 0;
      l_rec.agg_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP
			+ ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP
			+ COMMODITY_BMAP + DOCTYPE_BMAP;
      p_agg_lvl_tbl(1) := l_rec;

      l_rec.agg_level := 1;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP + CATEGORY_BMAP + SUPPLIER_BMAP;
      p_agg_lvl_tbl(2) := l_rec;

      l_rec.agg_level := 3;
      l_rec.agg_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP + CATEGORY_BMAP;
      p_agg_lvl_tbl(3) := l_rec;
    ---End Sourcing Management Change
    end if;
    EXCEPTION
     WHEN OTHERS THEN
       POA_LOG.debug_line('populate_agg_lvl ' || Sqlerrm || sqlcode || sysdate);
       raise;
  END populate_agg_level;

  PROCEDURE get_binds(
			 p_trend	IN VARCHAR2,
			 p_mv_set	IN VARCHAR2,
			 p_xtd IN VARCHAR2,
			 p_comparison_type IN VARCHAR2,
                         x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
                         p_context_code IN VARCHAR2,
                         p_param IN BIS_PMV_PAGE_PARAMETER_TBL
                          )
  IS
   l_custom_rec BIS_QUERY_ATTRIBUTES;
  BEGIN
     /* special case for PQC Cumulative trend, which cannot have the normal trend binds */
     if(p_trend = 'Y' and p_mv_set <> 'PQC') then
	poa_dbi_util_pkg.get_custom_trend_binds(p_xtd, p_comparison_type,x_custom_output);
     else
	poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
     end if;

     if(p_xtd like 'RL%') then
	poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output, p_xtd);
     end if;

     if(p_mv_set = 'REQS') then
	bind_reqfact_date(x_custom_output);
     end if;

     /* for reports having company and cost center security, we have to bind five variables:
      * report_region_code, company_id, top_company_id, cost_center_id and top_cost_center_id
      */
     if (p_context_code = 'COMP') then
        bind_com_cc_values(x_custom_output, p_param);
     end if;


  END get_binds;


/* THIS FUNCTION get_mv IS NOW OBSOLETE because of the ROLLUP_CHANGES */

FUNCTION get_mv(p_dim_bmap IN NUMBER,
	p_func_area in VARCHAR2,
	p_version in VARCHAR2,
	p_mv_set in VARCHAR2) return VARCHAR2 IS

l_index NUMBER := 1;
l_cost NUMBER;
l_mv_bmap_tbl POA_DBI_MV_BMAP_TBL;

begin

  populate_mv_bmap(l_mv_bmap_tbl, p_mv_set);

  l_cost := l_mv_bmap_tbl(1).mv_bmap;

  FOR i IN l_mv_bmap_tbl.FIRST .. l_mv_bmap_tbl.LAST
  LOOP
      IF (bitand(l_mv_bmap_tbl(i).mv_bmap, p_dim_bmap) = p_dim_bmap) THEN
          IF(l_mv_bmap_tbl(i).mv_bmap < l_cost) THEN
            l_cost := l_mv_bmap_tbl(i).mv_bmap;
            l_index := i;
          END IF;
      END IF;
  END LOOP;

return l_mv_bmap_tbl(l_index).mv_name;

END;


/* This function is now obsolete because of the rollup arch */
 PROCEDURE populate_mv_bmap(p_mv_bmap_tbl out NOCOPY poa_dbi_mv_bmap_tbl,
	p_mv_set in varchar2)
  IS

  l_rec POA_DBI_MV_BMAP_REC;

  BEGIN

  p_mv_bmap_tbl := POA_DBI_MV_BMAP_TBL();

  if(p_mv_set = 'POD') then
  p_mv_bmap_tbl.extend(5);

  l_rec.mv_name := 'poa_pod_bs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_pod_o_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP;
  p_mv_bmap_tbl(2) := l_rec;

  l_rec.mv_name := 'poa_pod_oc_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP;
  p_mv_bmap_tbl(3) := l_rec;

  l_rec.mv_name := 'poa_pod_obc_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP;
  p_mv_bmap_tbl(4) := l_rec;

  l_rec.mv_name := 'poa_pod_ocs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP + SUPPLIER_BMAP;
  p_mv_bmap_tbl(5) := l_rec;

  elsif(p_mv_set = 'IDL') then

  p_mv_bmap_tbl.extend(4);

  l_rec.mv_name := 'poa_idl_bs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CLERK_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_idl_os_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP;
  p_mv_bmap_tbl(2) := l_rec;

  l_rec.mv_name := 'poa_idl_o_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP;
  p_mv_bmap_tbl(3) := l_rec;

  l_rec.mv_name := 'poa_idl_osy_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP + CLERK_BMAP;
  p_mv_bmap_tbl(4) := l_rec;

  elsif(p_mv_set = 'MID') then

  p_mv_bmap_tbl.extend(4);

  l_rec.mv_name := 'poa_mid_bs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CLERK_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_mid_os_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP;
  p_mv_bmap_tbl(2) := l_rec;

  l_rec.mv_name := 'poa_mid_o_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP;
  p_mv_bmap_tbl(3) := l_rec;

  l_rec.mv_name := 'poa_mid_osy_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + SUPPLIER_BMAP + CLERK_BMAP;
  p_mv_bmap_tbl(4) := l_rec;

 elsif(p_mv_set = 'RTX') then

  p_mv_bmap_tbl.extend(4);

  l_rec.mv_name := 'poa_rtx_bs_mv';
  l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP + REASON_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_rtx_3_mv';
  l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP;
  p_mv_bmap_tbl(2) := l_rec;

  l_rec.mv_name := 'poa_rtx_4_mv';
  l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + SUPPLIER_BMAP;
  p_mv_bmap_tbl(3) := l_rec;

  l_rec.mv_name := 'poa_rtx_5_mv';
  l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + CATEGORY_BMAP;
  p_mv_bmap_tbl(4) := l_rec;

 elsif(p_mv_set = 'PQC') then

     p_mv_bmap_tbl.extend(5);

     l_rec.mv_name := 'poa_pqc_bs_mv';
     l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + REC_ORG_BMAP + BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP;
     p_mv_bmap_tbl(1) := l_rec;

     l_rec.mv_name := 'poa_pqc_3_mv';
     l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP;
     p_mv_bmap_tbl(2) := l_rec;

     l_rec.mv_name := 'poa_pqc_4_mv';
     l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + CATEGORY_BMAP ;
     p_mv_bmap_tbl(3) := l_rec;

     l_rec.mv_name := 'poa_pqc_5_mv';
     l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + SUPPLIER_BMAP;
     p_mv_bmap_tbl(4) := l_rec;

     l_rec.mv_name := 'poa_pqc_6_mv';
     l_rec.mv_bmap := COMMODITY_BMAP + OPER_UNIT_BMAP + CATEGORY_BMAP + SUPPLIER_BMAP;
     p_mv_bmap_tbl(5) := l_rec;

else
 if(p_mv_set = 'PODCUT') then
	  p_mv_bmap_tbl.extend(4);

  l_rec.mv_name := 'poa_pod_bs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP + COMMODITY_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_pod_11_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP;
  p_mv_bmap_tbl(2) := l_rec;

  l_rec.mv_name := 'poa_pod_12_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP + SUPPLIER_BMAP + COMMODITY_BMAP;
  p_mv_bmap_tbl(3) := l_rec;

  l_rec.mv_name := 'poa_pod_13_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + CATEGORY_BMAP + COMMODITY_BMAP;
  p_mv_bmap_tbl(4) := l_rec;

 elsif (p_mv_set = 'API') then
	  p_mv_bmap_tbl.extend(2);

  l_rec.mv_name := 'poa_api_bs_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + BUYER_BMAP + CATEGORY_BMAP + ITEM_BMAP + SUPPLIER_BMAP + SUPPLIER_SITE_BMAP + COMMODITY_BMAP;
  p_mv_bmap_tbl(1) := l_rec;

  l_rec.mv_name := 'poa_api_3_mv';
  l_rec.mv_bmap := OPER_UNIT_BMAP + COMMODITY_BMAP + CATEGORY_BMAP ;
  p_mv_bmap_tbl(2) := l_rec;

 end if;
end if;

EXCEPTION
   WHEN OTHERS THEN
   POA_LOG.debug_line('populate_mv_bmap ' || Sqlerrm || sqlcode || sysdate);
   raise;

  END populate_mv_bmap;

  /* Function name: get_display_category
   *
   * This function is used to restrict the values in the category LOV
   * to only the values the user has access to
   */
  function get_display_category(
             p_category_code in varchar2,
             p_selected_commodity in varchar2,
             p_context_code in varchar2,
             p_restrict_lov in varchar2 := 'Y'
           ) return varchar2
  is
    l_exists number;
  begin
    l_exists := 0;
    if(p_restrict_lov = 'N' and p_context_code = 'OU/COM') then
     return '1';
    end if;

    if(p_context_code = 'OUX') then
      return '1';
    end if;

    if(p_context_code = 'SUPPLIER' or p_context_code='OU' or p_context_code = 'COMP') then
      if(p_selected_commodity = 'ALL' or p_selected_commodity = '-1') then
        return '1';
      else
        select count(*) into l_exists
        from po_commodity_categories cat
        where cat.commodity_id = p_selected_commodity
        and   cat.category_id = p_category_code;
      end if;
    else
       select count(*) into l_exists
       from po_commodity_categories cat,
       po_commodity_grants gr,
       fnd_user usr
       where usr.user_id = fnd_global.user_id
       and   gr.person_id = usr.employee_id
       and   cat.commodity_id = gr.commodity_id
       and   cat.category_id = p_category_code
       and   (to_char(gr.commodity_id) = p_selected_commodity or p_selected_commodity = 'ALL');
    end if;

    if(l_exists = 0) then
      return '0';
    else
      return '1';
    end if;
  exception
    when others then
      return '2';
  end get_display_category;

  /* Function name: get_display_supplier
   *
   * This function is used to restrict the values in the supplier LOV
   * to only the values the user has access to
   */
  function get_display_supplier(p_supplier_id in varchar2,
                                p_context_code in varchar2
             ) return varchar2
  is
    l_exists number;
  begin
    -- Non-Supplier View
    if(p_context_code <> 'SUPPLIER') then
      return '1';
    end if;

    -- Supplier View of Supplier Management Page
    l_exists := 0;
    /* Check if user has access to p_supplier_id based on iSP Securing Attributes */
    select count(*) into l_exists
    from ak_web_user_sec_attr_values isp,
         fnd_application appl
    where isp.web_user_id = fnd_global.user_id
    and isp.attribute_application_id = appl.application_id
    and appl.application_short_name = 'POS'
    and isp.attribute_code = 'ICX_SUPPLIER_ORG_ID'
    and isp.number_value = p_supplier_id;

    if(l_exists = 0) then
     return '0';
    else
     return '1';
    end if;

  exception
   when others then
     return '2';
  end get_display_supplier;

  /* Function name: get_display_supplier_sites
   *
   * This function is used to restrict the values in the supplier site LOV
   * to only the values the user has access to
   */
  function get_display_supplier_site(p_supplier_site_id in varchar2,
                                      p_context_code in varchar2
             ) return varchar2
  is
    l_exists number;
  begin
    -- Non-Supplier View
    if(p_context_code <> 'SUPPLIER') then
      return '1';
    end if;

    -- Supplier View of Supplier Management Page
    l_exists := 0;
    /* Check if user has access to p_supplier_id based on iSP Securing Attributes */
    select count(*)
    into l_exists
    from
    poa_supplier_sites_v sup,
    ak_web_user_sec_attr_values isp,
    fnd_application appl
    where isp.attribute_application_id = appl.application_id
    and   isp.number_value = sup.vendor_id
    and   isp.web_user_id = fnd_global.user_id
    and   isp.attribute_code = 'ICX_SUPPLIER_ORG_ID'
    and   to_char(sup.id) = p_supplier_site_id
    and   appl.application_short_name = 'POS';

    if(l_exists = 0) then
     return '0';
    else
     return '1';
    end if;

  exception
   when others then
     return '2';
  end get_display_supplier_site;


  /* Function name: get_display_ou
   *
   * This function is used to restrict the values in the OU LOV
   * to only the values the user has access to
   */
  function get_display_ou(p_ou_id in varchar2,
                         p_context_code in varchar2
                     ) return varchar2
  is
    l_exists number;
    l_sec_profile_id number ;
  begin
    -- for Supplier Management and Spend Analysis dashboards
    if(p_context_code = 'SUPPLIER' or p_context_code = 'COMP') then
      return '1';
    end if;
    ---Begin changes for MOAC
    l_sec_profile_id := poa_dbi_util_pkg.get_sec_profile ;
    ---End changes for MOAC

    -- for OU Secured dashboards
    l_exists := 0;
    ---Begin changes for MOAC
    IF  NVL(l_sec_profile_id,-1) <> -1
    THEN
    ---End changes for MOAC
       select count(*) into l_exists
       from fii_operating_units_v v,
       per_organization_list per
       where v.id = p_ou_id
       and v.id = per.organization_id
       and security_profile_id = l_sec_profile_id ;
    ---Begin changes for MOAC
   ELSE
       SELECT COUNT(*)
       INTO l_exists
       FROM fii_operating_units_v v
       WHERE v.id = p_ou_id
       AND   v.id = poa_dbi_util_pkg.get_ou_org_id ;
   END IF ;
    ---End changes for MOAC

    if(l_exists = 0) then
     return '0';
    else
     return '1';
    end if;

  exception
    when others then
      return '2';
  end get_display_ou;

  /* Function name: get_display_com
   *
   * This function is used to restrict the values in the company LOV
   * to only the values the user has access to and enforce the standard
   * hierarchical LOV behaviour
   */
  function get_display_com(p_id in varchar2, p_parent_id in varchar2, p_selected_company in varchar2) return varchar2
  is
    l_count number;
  begin
    if (p_selected_company = 'ALL') then
      if (p_id <> p_parent_id) then
        /* we want to consider only those rows that represent a
         * self relation
         */
        return '0';
      else
        select count(*) into l_count
        from fii_company_grants
        where user_id = fnd_global.user_id
        and company_id = to_number(p_id)
        and report_region_code = 'POA_DBI_INV_STATUS';
        /* we are using Invoice Amount report as a reference to determine the
         * companies the user has access to
         */

        if (l_count > 0) then
          return '1';
        else
          return '0';
        end if;

      end if;
    else /* p_selected_company <> 'ALL' */
      if (p_parent_id = p_selected_company) then
        return '1';
      else
        return '0';
      end if;
    end if;
  end get_display_com;

  /* Function name: get_display_cc
   *
   * This function is used to restrict the values in the cost-center LOV
   * to only the values the user has access to and enforce the standard
   * hierarchical LOV behaviour
   */
  function get_display_cc(p_id in varchar2, p_parent_id in varchar2, p_selected_cc in varchar2) return varchar2
  is
    l_count number;
  begin
    if (p_selected_cc = 'ALL') then
      if (p_id <> p_parent_id) then
        /* we want to consider only those rows that represent a
         * self relation
         */
        return '0';
      else
        select count(*) into l_count
        from fii_cost_center_grants
        where user_id = fnd_global.user_id
        and cost_center_id = to_number(p_id)
        and report_region_code = 'POA_DBI_INV_STATUS';
        /* we are using Invoice Amount report as a reference to determine the
         * cost centers the user has access to
         */

        if (l_count > 0) then
          return '1';
        else
          return '0';
        end if;

      end if;
    else
      if (p_parent_id = p_selected_cc) then
        return '1';
      else
        return '0';
      end if;
    end if;
  end get_display_cc;

  /* Function name: get_display_commodity
   *
   * This function is used to restrict the values in the commodity LOV
   * to only the values the user has access to in case of dashboards that
   * are secured by commodity
   */
  function get_display_commodity(p_commodity_id in varchar2,
                               p_context_code in varchar2
                         ) return varchar2
  is
    l_exists NUMBER;
  begin
    -- for Supplier Management and Spend Analysis dashboard
    if(p_context_code = 'SUPPLIER' or p_context_code='OU' or p_context_code = 'COMP') then
      return '1';
    end if;

    -- for Commodity Secured dashboards
    l_exists := 0;
    /* select count(*) into l_exists
    from
    po_commodity_grants sec,
    fnd_user,
    fnd_menu_entries me,
    fnd_form_functions f
    where
    user_id=fnd_global.user_id
    and person_id=employee_id
    and sec.commodity_id=p_commodity_id
    and f.function_name='POA_DBI_COMMODITY_RPTS_VIEW'
    and me.function_id=f.function_id
    and sec.menu_id=me.menu_id; */
    select count(*) into l_exists
    from  po_commodity_grants sec,
          fnd_menus menu,
          fnd_user usr
    where usr.user_id = fnd_global.user_id
    and   sec.person_id = usr.employee_id
    and   sec.commodity_id = p_commodity_id
    and   menu.menu_name = 'PO_COMMODITY_MANAGER'
    and   sec.menu_id = menu.menu_id;

    if(l_exists = 0) then
     return '0';
    else
     return '1';
    end if;

  exception
    when others then
      return '2';
  end get_display_commodity;

  procedure hide_parameter(p_param in bis_pmv_page_parameter_tbl, hideParameter out nocopy varchar2)
  is
   l_bis_calling_parameter varchar2(100) := 'NA';
   l_context_code varchar2(10) := 'OU/COM';
   l_flag varchar2(1) := 'N';
   l_region_code varchar2(100) := 'NA';
  begin
    l_context_code := get_sec_context(p_param);
    l_bis_calling_parameter := get_bis_calling_parameter(p_param);
    for i in 1..p_param.count loop
       if (p_param(i).parameter_name = 'BIS_REGION_CODE') then
         l_region_code := p_param(i).parameter_value;
       end if;
    end loop;
    if(l_context_code = 'OU' or l_context_code = 'SUPPLIER') then
      if(l_bis_calling_parameter IN ('TIME+FII_TIME_DAY', 'TIME+FII_TIME_WEEK', 'TIME+FII_TIME_ENT_PERIOD',
                                 'TIME+FII_TIME_ENT_QTR','TIME+FII_TIME_ENT_YEAR')) then
         l_flag := 'Y';
      end if;
      if(l_region_code = 'POA_DBI_SPND_TREND' AND l_bis_calling_parameter = 'SUPPLIER+POA_SUPPLIER_SITES') THEN
        l_flag := 'Y';
     end if;
   end if;
     if(l_context_code = 'OU/COM' or l_context_code = 'COMP' or l_context_code = 'NEG'
        OR l_context_code = 'OUX'
     )  then
      if(l_bis_calling_parameter IN ('TIME+FII_ROLLING_WEEK', 'TIME+FII_ROLLING_MONTH',
                                 'TIME+FII_ROLLING_QTR','TIME+FII_ROLLING_YEAR')) then
         l_flag := 'Y';
      end if;
     end if;
    hideParameter := l_flag;
 end hide_parameter;

  /* Procedure name: hide_parameter2
   *
   * This procedure is called by PMV for company, cost-center and FUD1
   * dimensions to determine whether they should be hidden or not. This
   * procedure returns a 'N' (meaning show) if the context code is COMP. Hence the three
   * dimensions are hidden on the Commodity Spend Analysis dashboard but
   * shown on the Spend Analysis (Public Sector) dashboard.
   */
  procedure hide_parameter2(p_param in bis_pmv_page_parameter_tbl, hideParameter out nocopy varchar2)
  is
   l_context_code varchar2(10) := 'OU/COM';
   l_flag varchar2(1) := 'Y';
  begin
    l_context_code := get_sec_context(p_param);
    if(l_context_code='COMP') then
      l_flag := 'N';
    else
      l_flag := 'Y';
    end if;
    hideParameter := l_flag;
  end hide_parameter2;

  /* Procedure name: hide_parameter3
   *
   * This procedure is called by PMV for organization, buyer and supplier-site
   * dimensions to determine whether they should be hidden or not. This
   * procedure returns a 'Y' (meaning hide) if the context code is COMP. Hence the three
   * dimensions are shown on the Commodity Spend Analysis dashboard but
   * hidden on the Spend Analysis (Public Sector) dashboard.
   */
  procedure hide_parameter3(p_param in bis_pmv_page_parameter_tbl, hideParameter out nocopy varchar2)
  is
   l_context_code varchar2(10) := 'OU/COM';
   l_bis_calling_parameter varchar2(100);
   l_flag varchar2(1) := 'Y';
  begin
    l_context_code := get_sec_context(p_param);
    l_bis_calling_parameter := get_bis_calling_parameter(p_param);
    if(l_context_code='COMP') then
      l_flag := 'Y';
    else
      l_flag := 'N';
    end if;
    if(l_context_code = 'NEG' and l_bis_calling_parameter = 'SUPPLIER+POA_SUPPLIER_SITES') then
     l_flag := 'Y';
    end if;

    hideParameter := l_flag;
  end hide_parameter3;

  /* Procedure name: hide_commodity
   *
   * This procedure is called by PMV for the commodity region item of PO Purchases
   * report to determine whether the parameter should be hidden or not.
   */
  procedure hide_commodity(p_param in bis_pmv_page_parameter_tbl, hideParameter out nocopy varchar2)
  is
   l_function_name varchar2(30);
   l_bis_calling_parameter varchar2(100) := 'NA';
   l_context_code varchar2(10) := 'OU/COM';
   l_flag varchar2(1) := 'N';
  begin
    l_context_code := get_sec_context(p_param);
    l_bis_calling_parameter := get_bis_calling_parameter(p_param);
    if(l_context_code = 'OUX' and l_bis_calling_parameter = 'ITEM+POA_COMMODITIES') then
      l_flag := 'Y';
    else
      l_flag := 'N';
    end if;
    hideParameter := l_flag;
  end hide_commodity;

  /* Procedure name: get_company_sql
   *
   * This procedure determines the subquery for the company dimension
   * which is used by the reports of the Spend Analysis dashboard. It takes
   * the report viewby and the selected company as input and returns the
   * subquery and a flag which indicates whether all the nodes accessed are
   * aggregated or not.
   */
  procedure get_company_sql(p_viewby in varchar2,
                            p_company_id in varchar2,
                            p_region_code in varchar2,
                            p_company_sql out nocopy varchar2,
                            p_agg_flag out nocopy varchar2)
  is
    l_leaf_flag varchar2(1);
    l_viewby_sql varchar2(1000);
    l_company_count number;
    l_rtn varchar2(5);
    l_top_node varchar2(20);
    l_non_agrt_nodes number;
  begin
    l_rtn := fnd_global.newline;
    l_non_agrt_nodes := 0;

    if(p_viewby <> 'FII_COMPANIES+FII_COMPANIES') then
      if(p_company_id = 'All') then
        l_viewby_sql := 'select company_id, aggregated_flag com_agg_flag '||l_rtn||
                        'from fii_company_grants '||l_rtn||
                        'where user_id = fnd_global.user_id '||l_rtn||
                        'and report_region_code = &REGIONCODE';
        select count(*) into l_non_agrt_nodes
        from fii_company_grants
        where user_id = fnd_global.user_id
        and report_region_code = p_region_code
        and aggregated_flag = 'N';
      else
        l_viewby_sql := 'select company_id, aggregated_flag com_agg_flag '||l_rtn||
                        'from fii_com_pmv_agrt_nodes '||l_rtn||
                        'where company_id = &COMPANYID';
        select count(*) into l_non_agrt_nodes
        from fii_com_pmv_agrt_nodes
        where company_id = to_number(p_company_id)
        and aggregated_flag = 'N';
      end if;
    else
      if(p_company_id = 'All') then

        select count(1) into l_company_count
        from fii_company_grants
        where user_id = fnd_global.user_id
        and report_region_code = p_region_code;

        if(l_company_count = 1) then

          select to_char(company_id) into l_top_node
          from fii_company_grants
          where user_id = fnd_global.user_id
          and report_region_code = p_region_code;

          select is_leaf_flag into l_leaf_flag
          from fii_company_hierarchies
          where parent_company_id = to_number(l_top_node)
          and parent_company_id = child_company_id;

          if(l_leaf_flag = 'Y') then
            l_viewby_sql := 'select company_id, aggregated_flag com_agg_flag '||l_rtn||
                            'from fii_com_pmv_agrt_nodes '||l_rtn||
                            'where company_id = &TOPCOMPANYID';
            select count(*) into l_non_agrt_nodes
            from fii_com_pmv_agrt_nodes
            where company_id = l_top_node
            and aggregated_flag = 'N';
          else
            l_viewby_sql := 'select parent_company_id, child_company_id company_id, aggregate_next_level_flag com_agg_flag '||l_rtn||
                            'from fii_company_hierarchies '||l_rtn||
                            'where child_level = parent_level+1 '||l_rtn||
                            'and parent_company_id = &TOPCOMPANYID';
            select count(*) into l_non_agrt_nodes
            from fii_company_hierarchies
            where child_level = parent_level + 1
            and parent_company_id = l_top_node
            and aggregate_next_level_flag = 'N';
          end if;
        else
          l_viewby_sql := 'select company_id, aggregated_flag com_agg_flag '||l_rtn||
                          'from fii_company_grants '||l_rtn||
                          'where user_id = fnd_global.user_id '||l_rtn||
                          'and report_region_code = &REGIONCODE';
          select count(*) into l_non_agrt_nodes
          from fii_company_grants
          where user_id = fnd_global.user_id
          and report_region_code = p_region_code
          and aggregated_flag = 'N';
        end if;
      else
        select is_leaf_flag into l_leaf_flag
        from fii_company_hierarchies
        where parent_company_id = to_number(p_company_id)
        and parent_company_id = child_company_id;
        if(l_leaf_flag = 'Y') then
          l_viewby_sql := 'select company_id, aggregated_flag com_agg_flag '||l_rtn||
                          'from fii_com_pmv_agrt_nodes '||l_rtn||
                          'where company_id = &COMPANYID';
          select count(*) into l_non_agrt_nodes
          from fii_com_pmv_agrt_nodes
          where company_id = to_number(p_company_id)
          and aggregated_flag = 'N';
        else
          l_viewby_sql := 'select parent_company_id, child_company_id company_id, aggregate_next_level_flag com_agg_flag '||l_rtn||
                          'from fii_company_hierarchies '||l_rtn||
                          'where child_level = parent_level+1 '||l_rtn||
                          'and parent_company_id = &COMPANYID';
          select count(*) into l_non_agrt_nodes
          from fii_company_hierarchies
          where child_level = parent_level + 1
          and parent_company_id = p_company_id
          and aggregate_next_level_flag = 'N';
        end if;
      end if;
    end if;
    p_company_sql := l_viewby_sql;
    if(l_non_agrt_nodes = 0) then
      p_agg_flag := 'Y';
    else
      p_agg_flag := 'N';
    end if;
  end;

  /* Procedure name: get_cost_ctr_sql
   *
   * This procedure determines the subquery for the cost center dimension
   * which is used by the reports of the Spend Analysis dashboard. It takes
   * the report viewby and the selected cost-center as input and returns the
   * subquery and a flag which indicates whether all the nodes accessed are
   * aggregated or not.
   */
  procedure get_cost_ctr_sql(p_viewby in varchar2,
                             p_cost_center_id in varchar2,
                             p_region_code in varchar2,
                             p_cost_ctr_sql out nocopy varchar2,
                             p_agg_flag out nocopy varchar2)
  is
    l_leaf_flag varchar2(1);
    l_viewby_sql varchar2(1000);
    l_cost_center_count number;
    l_rtn varchar2(5);
    l_top_node varchar2(20);
    l_non_agrt_nodes number;
  begin
    l_rtn := fnd_global.newline;
    l_non_agrt_nodes := 0;

    if(p_viewby <> 'ORGANIZATION+HRI_CL_ORGCC') then
      if(p_cost_center_id = 'All') then
        l_viewby_sql := 'select cost_center_id, aggregated_flag cc_agg_flag '||l_rtn||
                        'from fii_cost_center_grants '||l_rtn||
                        'where user_id = fnd_global.user_id '||l_rtn||
                        'and report_region_code = &REGIONCODE';
        select count(*) into l_non_agrt_nodes
        from fii_cost_center_grants
        where user_id = fnd_global.user_id
        and report_region_code = p_region_code
        and aggregated_flag = 'N';
      else
        l_viewby_sql := 'select cost_center_id, aggregated_flag cc_agg_flag '||l_rtn||
                        'from fii_cc_pmv_agrt_nodes '||l_rtn||
                        'where cost_center_id = &COSTCTRID';
        select count(*) into l_non_agrt_nodes
        from fii_cc_pmv_agrt_nodes
        where cost_center_id = p_cost_center_id
        and aggregated_flag = 'N';
      end if;
    else
      if(p_cost_center_id = 'All') then

        select count(1) into l_cost_center_count
        from fii_cost_center_grants
        where user_id = fnd_global.user_id
        and report_region_code = p_region_code;

        if(l_cost_center_count = 1) then

          select to_char(cost_center_id) into l_top_node
          from fii_cost_center_grants
          where user_id = fnd_global.user_id
          and report_region_code = p_region_code;

          select is_leaf_flag into l_leaf_flag
          from fii_cost_ctr_hierarchies
          where parent_cc_id = to_number(l_top_node)
          and parent_cc_id = child_cc_id;

          if(l_leaf_flag = 'Y') then
            l_viewby_sql := 'select cost_center_id, aggregated_flag cc_agg_flag '||l_rtn||
                            'from fii_cc_pmv_agrt_nodes '||l_rtn||
                            'where cost_center_id = &TOPCOSTCTRID';
            select count(*) into l_non_agrt_nodes
            from fii_cc_pmv_agrt_nodes
            where cost_center_id = l_top_node
            and aggregated_flag = 'N';
          else
            l_viewby_sql := 'select parent_cc_id, child_cc_id cost_center_id, aggregate_next_level_flag cc_agg_flag '||l_rtn||
                            'from fii_cost_ctr_hierarchies '||l_rtn||
                            'where child_level = parent_level+1 '||l_rtn||
                            'and parent_cc_id = &TOPCOSTCTRID';
            select count(*) into l_non_agrt_nodes
            from fii_cost_ctr_hierarchies
            where child_level = parent_level + 1
            and parent_cc_id = l_top_node
            and aggregate_next_level_flag = 'N';
          end if;
        else
          l_viewby_sql := 'select cost_center_id, aggregated_flag cc_agg_flag '||l_rtn||
                          'from fii_cost_center_grants '||l_rtn||
                          'where user_id = fnd_global.user_id '||l_rtn||
                          'and report_region_code = &REGIONCODE';
          select count(*) into l_non_agrt_nodes
          from fii_cost_center_grants
          where user_id = fnd_global.user_id
          and report_region_code = p_region_code
          and aggregated_flag = 'N';
        end if;
      else
        select is_leaf_flag into l_leaf_flag
        from fii_cost_ctr_hierarchies
        where parent_cc_id = p_cost_center_id
        and parent_cc_id = child_cc_id;
        if(l_leaf_flag = 'Y') then
          l_viewby_sql := 'select cost_center_id, aggregated_flag cc_agg_flag '||l_rtn||
                          'from fii_cc_pmv_agrt_nodes '||l_rtn||
                          'where cost_center_id = &COSTCTRID';
          select count(*) into l_non_agrt_nodes
          from fii_cc_pmv_agrt_nodes
          where cost_center_id = p_cost_center_id
          and aggregated_flag = 'N';
        else
          l_viewby_sql := 'select parent_cc_id, child_cc_id cost_center_id, aggregate_next_level_flag cc_agg_flag '||l_rtn||
                          'from fii_cost_ctr_hierarchies '||l_rtn||
                          'where child_level = parent_level+1 '||l_rtn||
                          'and parent_cc_id = &COSTCTRID';
          select count(*) into l_non_agrt_nodes
          from fii_cost_ctr_hierarchies
          where child_level = parent_level + 1
          and parent_cc_id = p_cost_center_id
          and aggregate_next_level_flag = 'N';
        end if;
      end if;
    end if;
    p_cost_ctr_sql := l_viewby_sql;
    if(l_non_agrt_nodes = 0) then
      p_agg_flag := 'Y';
    else
      p_agg_flag := 'N';
    end if;
  end;

  /* function name: get_sec_context
   *
   * This function takes the parameter table passed by PMV as input as returns
   * the context code. The context code is the value associated with the
   * POA_CONTEXT1 parameter
   */
  function get_sec_context(p_param in BIS_PMV_PAGE_PARAMETER_TBL) return varchar2
  is
    l_value varchar2(10) := 'OU/COM';
  begin
    for i in 1..p_param.count loop
      if(p_param(i).parameter_name = 'POA_CONTEXT1' and p_param(i).parameter_id is not null) then
	      l_value := p_param(i).parameter_value;
      end if;
    end loop;
    IF(l_value is NULL or l_value = 'ALL') THEN
      l_value := 'OU/COM';
    END IF;
    return (l_value);
  end;

  /* function name: get_bis_calling_parameter
   *
   * This function takes the parameter table passed by PMV as input and returns
   * the calling parameter string. The calling parameter is the value associated with the
   * BIS_CALLING_PARAMETER parameter. This is available only in Show/Hide
   * Function
   */
  function get_bis_calling_parameter(p_param in BIS_PMV_PAGE_PARAMETER_TBL) return varchar2
  is
    l_value varchar2(100);
  begin
    for i in 1..p_param.count loop
      if(p_param(i).parameter_name = 'BIS_CALLING_PARAMETER' and p_param(i).parameter_id is not null) then
	      l_value := p_param(i).parameter_value;
      end if;
    end loop;
    return (l_value);
  end;

 /* function name: get_supplier_id_ou
  *
  * This function is used by the OU context page, wherein the Supplier LOV in the Supplier
  * Management Dashboard should not be secured. It must pick up the first alphabetical
  * Supplier Value and must pass it back to the calling function.
  */
  function get_supplier_id_ou return varchar2
  is
    l_supplier_id number;
    l_return_string varchar2(100);
  begin
    SELECT id into l_supplier_id
    FROM (
    SELECT id
    FROM poa_suppliers_v
    ORDER BY value)
    WHERE ROWNUM=1;
    l_return_string := '&POA_SUPPLIERS='||l_supplier_id;
  return l_return_string;
 end;

 /* function name: get_supplier_id_sup
  *
  * This function is used by the Supplier context page, wherein the Supplier LOV in the Supplier
  * Management Dashboard should be secured. It must pick up the first alphabetical
  * Supplier Value and must pass it back to the calling function.
  */
  function get_supplier_id_sup return  varchar2
  is
    l_supplier_id number;
    l_return_string varchar2(100);
  begin
    SELECT id into l_supplier_id
    FROM (
    SELECT id
    FROM
     poa_suppliers_v v,
     ak_web_user_sec_attr_values isp,
     fnd_application appl
    WHERE
        fnd_global.user_id = isp.web_user_id
    AND isp.attribute_application_id = appl.application_id
    AND appl.application_short_name =  'POS'
    AND isp.attribute_code = 'ICX_SUPPLIER_ORG_ID'
    AND v.id = isp.number_value
    ORDER BY value)
    WHERE ROWNUM=1;
    l_return_string := '&POA_SUPPLIERS='||l_supplier_id;
  return l_return_string;
 end;

  /* function name: get_curr_label
   *
   * This function is called by POA_DBI_PQC_TREND ak region to get the column
   * heading suffix for current period columns
   */
  function get_curr_label return varchar2 is
    stmt varchar2(240);
  begin
    stmt := get_msg('Y');
    return stmt;
  end get_curr_label;

  /* function name: get_pri_label
   *
   * This function is called by POA_DBI_PQC_TREND ak region to get the column
   * heading suffix for prior period columns
   */
  function get_pri_label return varchar2 is
    stmt varchar2(240);
  begin
    stmt := get_msg('N');
    return stmt;
  end get_pri_label;

  /* function name: get_msg
   *
   * This function is called by get_curr_label and get_pri_label to get the
   * label to be displayed in Cumulative price savings report's column headings
   */
  function get_msg (p_current in varchar2)return varchar2 is
    stmt                varchar2(240);
    l_asof_date         date;
    l_week              varchar2(10);
    l_year              varchar2(10);
  begin
    if (p_current = 'Y') then
      l_asof_date:=g_as_of_date;
    else
      l_asof_date:=g_previous_asof_date;
    end if;

    if g_page_period_type = 'FII_TIME_ENT_YEAR' then
      select name into stmt
      from fii_time_ent_year
      where l_asof_date between start_date and end_date;
    elsif g_page_period_type = 'FII_TIME_ENT_QTR' then
      select name into stmt
      from fii_time_ent_qtr
      where l_asof_date between start_date and end_date;
    elsif g_page_period_type = 'FII_TIME_ENT_PERIOD' then
      select name into stmt
      from fii_time_ent_period
      where l_asof_date between start_date and end_date;
    elsif g_page_period_type = 'FII_TIME_WEEK' then
      select to_char(sequence) into l_week
      from fii_time_week
      where l_asof_date between start_date and end_date;

      select substr(week_id,3,2) into l_year
      from fii_time_week
      where l_asof_date between start_date and end_date;

      stmt := fnd_message.get_string('FII', 'FII_AR_WEEK')||' '||l_week||' '||l_year;
    end if;
    return stmt;
  end get_msg;

  /* function name: get_parameters
   *
   * This procedure is called by poa_dbi_pqc_pkg.trend_sql to set the values
   * of three global variables which are used by get_msg function
   */
  procedure get_parameters (p_page_parameter_tbl in bis_pmv_page_parameter_tbl) is
    l_lob_enabled_flag varchar2(1);
  begin
    -- -------------------------------------------------
    -- Parse through the parameter table and set globals
    -- -------------------------------------------------
    if (p_page_parameter_tbl.count > 0) then
      for i in p_page_parameter_tbl.first..p_page_parameter_tbl.last loop
        if p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' then
          g_page_period_type := p_page_parameter_tbl(i).parameter_value;
        elsif p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' then
          g_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
        elsif p_page_parameter_tbl(i).parameter_name = 'BIS_PREVIOUS_ASOF_DATE' then
          g_previous_asof_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
        end if;
      end loop;
    end if;

    if g_as_of_date is null then
      g_as_of_date := trunc(sysdate);
    end if;

    if g_previous_asof_date is null then
      g_previous_asof_date := trunc(sysdate);
    end if;

    if g_page_period_type is null then
      g_page_period_type := 'FII_TIME_ENT_QTR';
    end if;

  end get_parameters;

  /* procedure name: bind_com_cc_values
   *
   * This procedure populates x_custom_output with five binds that are
   * required for reports having company and cost center security.
   */
  procedure bind_com_cc_values(
              x_custom_output in out nocopy bis_query_attributes_tbl,
              p_param in bis_pmv_page_parameter_tbl
            )
  is
    l_company_value varchar2(30) := 'All';
    l_top_company_value varchar2(30) := 'All';
    l_cost_ctr_value varchar2(30) := 'All';
    l_top_cost_ctr_value varchar2(30) := 'All';
    l_region_code varchar2(40);
    l_custom_rec BIS_QUERY_ATTRIBUTES;
    l_count number;
  begin

    for i in 1..p_param.count loop
      if (p_param(i).parameter_name = 'BIS_REGION_CODE') then
        l_region_code := p_param(i).parameter_value;
      elsif (p_param(i).parameter_name = 'FII_COMPANIES+FII_COMPANIES') then
        l_company_value := nvl(p_param(i).parameter_id,'All');
      elsif (p_param(i).parameter_name = 'ORGANIZATION+HRI_CL_ORGCC') then
        l_cost_ctr_value := nvl(p_param(i).parameter_id,'All');
      end if;
    end loop;

    if (l_company_value = '''''')then
      l_company_value := 'All';
    end if;

    if (l_cost_ctr_value = '''''')then
      l_cost_ctr_value := 'All';
    end if;

    l_company_value := translate(l_company_value,'''',' ');
    l_cost_ctr_value := translate(l_cost_ctr_value,'''',' ');

    /* check how many companies the user has access to
     */
    select count(1) into l_count
    from fii_company_grants
    where user_id = fnd_global.user_id
    and report_region_code = l_region_code;

    if (l_count = 1) then
      select to_char(company_id) into l_top_company_value
      from fii_company_grants
      where user_id = fnd_global.user_id
      and report_region_code = l_region_code;
    else
      /* if the user does not have access to exactly one company, then the
       * l_top_company_value should have an unused value
       */
      l_top_company_value := '-9999';
    end if;

    /* check how many cost-centers the user has access to
     */
    select count(1) into l_count
    from fii_cost_center_grants
    where user_id = fnd_global.user_id
    and report_region_code = l_region_code;

    if (l_count = 1) then
      select to_char(cost_center_id) into l_top_cost_ctr_value
      from fii_cost_center_grants
      where user_id = fnd_global.user_id
      and report_region_code = l_region_code;
    else
      /* if the user does not have access to exactly one cost-center, then the
       * l_top_cost_ctr_value should have an unused value
       */
      l_top_cost_ctr_value := '-9999';
    end if;

    l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

    if x_custom_output is null then
      x_custom_output := bis_query_attributes_tbl();
    end if;

    l_custom_rec.attribute_name := '&REGIONCODE';
    l_custom_rec.attribute_value := l_region_code;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := '&COMPANYID';
    l_custom_rec.attribute_value := l_company_value;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := '&TOPCOMPANYID';
    l_custom_rec.attribute_value := l_top_company_value;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := '&COSTCTRID';
    l_custom_rec.attribute_value := l_cost_ctr_value;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := '&TOPCOSTCTRID';
    l_custom_rec.attribute_value := l_top_cost_ctr_value;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.CHARACTER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  end bind_com_cc_values;

end poa_dbi_sutil_pkg;

/
