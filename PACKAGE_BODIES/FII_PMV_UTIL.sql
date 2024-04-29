--------------------------------------------------------
--  DDL for Package Body FII_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PMV_UTIL" AS
/* $Header: FIIPMVUB.pls 120.10 2006/09/15 05:24:17 sajgeo ship $ */

g_prim_global_currency_code VARCHAR2(15) := get_prim_global_currency_code;
g_sec_global_currency_code  VARCHAR2(15) := get_sec_global_currency_code;
g_sec_profile NUMBER := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);

g_all_operating_unit VARCHAR2(240) ;
g_operating_unit VARCHAR2(240);
g_common_functional_currency VARCHAR2(3) ;
g_functional_currency_code VARCHAR2(3) ;

g_det_ou_lov	NUMBER;
g_security_profile_id 	NUMBER;
g_security_org_id	NUMBER;
g_business_group_id 	NUMBER;
g_p_as_of_date DATE;
g_gid NUMBER;
g_previous_date DATE;


FUNCTION get_msg (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2 IS
   stmt                VARCHAR2(20);
BEGIN
stmt := BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id,
p_session_id, p_function_name);
RETURN stmt;
END get_msg;

FUNCTION get_msg1 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2 IS
   stmt                VARCHAR2(20);
BEGIN
stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' ' ||BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);
RETURN stmt;
END get_msg1;

FUNCTION get_curr RETURN VARCHAR2 IS
   stmt                VARCHAR2(20);
BEGIN
  --fix for repository bug 4945663
--select id into stmt from fii_currencies_v where id = 'FII_GLOBAL1';
stmt := 'FII_GLOBAL1';
RETURN stmt;
END get_curr;

FUNCTION get_manager RETURN NUMBER IS
   stmt                NUMBER(10);
BEGIN
  --fix for repository bug 4945663
--select distinct id into stmt from HRI_CL_PER_CCMGR_V where id = fnd_global.employee_id;
stmt := -1;
RETURN stmt;
END get_manager;

FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2 IS
     employee_id    NUMBER(10);
     employee_name  VARCHAR2(240);
     currency       FII_CURRENCIES_V.ID%TYPE;
     period_id      NUMBER;
  BEGIN
     employee_id := fnd_global.employee_id;
       --fix for repository bug 4945663
     --select  id into currency from fii_currencies_v where id = 'FII_GLOBAL1';
     currency := 'FII_GLOBAL1';
     select ENT_PERIOD_ID into period_id from fii_time_ent_period where sysdate
between START_DATE and END_DATE;
     IF    (region_id = 'FII_PMV_MGR_PARAMETER_PORTLET') THEN
            RETURN '&'||'AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
                   '&'||'BIS_MANAGER='||employee_id||
                   '&'||'CURRENCY='||currency||
		   '&'||'YEARLY=TIME_COMPARISON_TYPE+YEARLY&PERIOD_MONTH_FROM='||period_id||'&PERIOD_MONTH_TO='||period_id;
     ELSE
            RETURN NULL;
     END IF;
END get_dbi_params;

FUNCTION get_sec_profile RETURN NUMBER IS
  stmt NUMBER;
BEGIN
  stmt := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
  RETURN stmt;
END get_sec_profile;

FUNCTION get_prim_global_currency_code RETURN VARCHAR2 IS
BEGIN
  RETURN bis_common_parameters.get_currency_code;
END get_prim_global_currency_code;

FUNCTION get_sec_global_currency_code RETURN VARCHAR2 IS
BEGIN
  RETURN bis_common_parameters.get_secondary_currency_code;
END get_sec_global_currency_code;

FUNCTION get_display_currency(p_selected_operating_unit      IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    IF g_sec_profile is null then
        g_sec_profile := nvl(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
    END IF;

    IF g_det_ou_lov IS NULL THEN
    	g_det_ou_lov := determine_OU_LOV;
    END IF;

    IF g_business_group_id IS NULL THEN
        g_business_group_id := fii_pmv_util.get_business_group;
    END IF;

    IF(p_selected_operating_unit <> 'ALL') then
        IF (g_operating_unit is null or g_operating_unit <> p_selected_operating_unit) THEN
           g_operating_unit := p_selected_operating_unit;

  	   select currency_code
           into g_functional_currency_code
           from financials_system_params_all fsp,
                gl_ledgers_public_v gsob
           where fsp.org_id = p_selected_operating_unit
           and fsp.set_of_books_id = gsob.ledger_id;
     	END IF;

/*	Bug 3890938. Added condition that if functional currency = primary/secondary global
	currency, return NULL
*/
	IF (g_functional_currency_code = g_prim_global_currency_code) OR
		(g_functional_currency_code = g_sec_global_currency_code) THEN
	return NULL;
	ELSE
        return g_functional_currency_code;
	END IF;

    ELSE  -- operating unit is 'All'
        IF g_all_operating_unit is null THEN                  -- subsequent runs are prevented
           g_all_operating_unit := p_selected_operating_unit; ---gets set a value for the first run

           select distinct currency_code
           into g_common_functional_currency
           from financials_system_params_all fsp,
             gl_ledgers_public_v gsob
           where fsp.set_of_books_id = gsob.ledger_id
	AND (
		(
			g_det_ou_lov=1 AND fsp.org_id = fsp.org_id
		)
		OR (
			g_det_ou_lov=2
			AND fsp.org_id in (
				SELECT organization_id
				FROM hr_operating_units
				WHERE business_group_id = fii_pmv_util.g_business_group_id
			)
		)
		OR (
			g_det_ou_lov=3
			AND fsp.org_id in (
				SELECT organization_id
				FROM per_organization_list
				WHERE security_profile_id = g_sec_profile
			)
		)
		OR(
			g_det_ou_lov=4 AND fsp.org_id = nvl(fnd_profile.value('ORG_ID'), -1)
		)
	);

        END IF;

/*	Bug 3890938. Added condition that if functional currency = primary/secondary global
	currency, return NULL
*/
	IF (g_common_functional_currency =  g_prim_global_currency_code) OR
		(g_common_functional_currency = g_sec_global_currency_code) THEN
	return NULL;
	ELSE
        return g_common_functional_currency;
	END IF;

    END IF;

EXCEPTION
  when too_many_rows then
    g_common_functional_currency := 'N/A';
    return 'N/A';
  when others then
    return 'N/A';
END get_display_currency;

PROCEDURE get_parameters (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_as_of_date  OUT NOCOPY Date,
                            p_operating_unit  OUT NOCOPY Varchar2,
                            p_supplier  OUT NOCOPY Varchar2,
                            p_invoice_number  OUT NOCOPY Number,
                            p_period_type OUT NOCOPY Varchar2,
                            p_record_type_id OUT NOCOPY NUMBER,
                            p_view_by OUT NOCOPY Varchar2,
                            p_currency OUT NOCOPY Varchar2,
                            p_column_name OUT NOCOPY VARCHAR2,
                            p_table_name OUT NOCOPY VARCHAR2,
                            p_gid OUT NOCOPY NUMBER,
                            p_org_where OUT NOCOPY Varchar2,
                            p_supplier_where OUT NOCOPY Varchar2
                            ) IS
    l_currency Varchar2(50);
 -- l_invoice_number Varchar2(50);
    l_org_list       Varchar2(240);
    l_org_count      Number;
--    l_security_profile_id   Number;
--    l_security_org_id NUMBER;
    l_all_org_flag  VARCHAR2(30);
    l_business_group_id NUMBER;
    l_org_id NUMBER;


BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
          IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
             p_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
              --added by vkazhipu
             g_p_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
             g_previous_date := add_months (p_as_of_date, -11);
         END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
             p_operating_unit := p_page_parameter_tbl(i).parameter_value;
          END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'SUPPLIER+POA_SUPPLIERS' THEN
             p_supplier := p_page_parameter_tbl(i).parameter_value;
          END IF;
          IF p_page_parameter_tbl(i).parameter_name= 'FII_INVOICE_ID' OR p_page_parameter_tbl(i).parameter_name= 'FII_AP_INVOICE_ID' THEN
         -- Removed on 30-May as part of enhancement 4234120
	 -- l_invoice_number := p_page_parameter_tbl(i).parameter_value;
             get_invoice_id(p_page_parameter_tbl,p_invoice_number);
          END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
             l_currency := p_page_parameter_tbl(i).parameter_id;
          END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
             p_period_type := p_page_parameter_tbl(i).parameter_value;
          END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
             p_view_by := p_page_parameter_tbl(i).parameter_value;
          END IF;
     END LOOP;
  END IF;

  If p_period_type is not null then
    CASE p_period_type
      WHEN 'FII_TIME_WEEK'       THEN p_record_type_id := 32;
      WHEN 'FII_TIME_ENT_PERIOD' THEN p_record_type_id := 64;
      WHEN 'FII_TIME_ENT_QTR'    THEN p_record_type_id := 128;
      WHEN 'FII_TIME_ENT_YEAR'   THEN p_record_type_id := 256;
    END CASE;
  End if;
     If l_currency is not null then
        IF substr(l_currency,2,11) = 'FII_GLOBAL1' THEN
           p_currency := '_prim_g';
        ELSIF substr(l_currency,2,11) = 'FII_GLOBAL2' THEN
           p_currency := '_sec_g';
        ELSE
           p_currency := '_b';
        END IF;
     End if;
     If p_view_by is not null then
      IF p_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' then
        p_column_name := 'ORG_ID';
        p_table_name := '(select organization_id id, name value from hr_all_organization_units)';
      Elsif p_view_by = 'SUPPLIER+POA_SUPPLIERS' then
        p_column_name := 'SUPPLIER_ID';
        p_table_name := '(select id, value from POA_SUPPLIERS_V)';
      End if;
     End if;
  IF (p_view_by = 'ORGANIZATION+FII_OPERATING_UNITS' AND p_supplier = 'All') THEN
    p_gid := 4;
  ELSE
    p_gid := 0;
  END IF;

  --added by vkazhipu

 IF p_supplier is not null and p_supplier <> 'All' then
    g_gid := 0;
 ELSE
    g_gid := 4;
 END IF;


/* Added for R12 MOAC */

IF g_security_profile_id IS NULL THEN
	g_security_profile_id := fii_pmv_util.get_sec_profile;
END IF;

IF g_security_org_id IS NULL THEN
	g_security_org_id := fnd_profile.value('ORG_ID');
END IF;

IF g_business_group_id IS NULL THEN
	g_business_group_id := fii_pmv_util.get_business_group;
END IF;

IF p_operating_unit = 'All' THEN

  /* Security is dictated by 'MO: Security Profile'. */
  IF g_security_profile_id is not null  AND g_security_profile_id <> -1 THEN

    SELECT view_all_organizations_flag, business_group_id
    INTO l_all_org_flag, l_business_group_id
    FROM per_security_profiles
    WHERE security_profile_id = g_security_profile_id;

  	/*  Case 1: User has access to all organizations. */
  	IF l_all_org_flag = 'Y' and l_business_group_id is NULL THEN
		p_org_where := ' ';
  	ELSIF l_all_org_flag = 'Y' and l_business_group_id is NOT NULL THEN

      		SELECT COUNT(1) INTO l_org_count
      		FROM hr_operating_units hr, ap_system_parameters_all ap
      		WHERE hr.business_group_id = l_business_group_id
      		AND hr.organization_id = ap.org_id;

   	/*  Case 2: User has access to more than 5 organizations. */
  		IF l_org_count > 5 THEN
      		p_org_where := ' and f.org_id in (select organization_id from hr_operating_units hr, ap_system_parameters_all ap where hr.business_group_id = :BUSINESS_GROUP and hr.organization_id = ap.org_id) ';

   	/*  Case 3: User has access to 2-5 organizations. */
  	ELSIF (l_org_count >= 2 and l_org_count <= 5) THEN
        	FOR C1_Rec in (select organization_id from hr_operating_units hr, ap_system_parameters_all ap where hr.business_group_id = l_business_group_id and hr.organization_id = ap.org_id)
		LOOP
        		l_org_list := l_org_list||C1_Rec.organization_id||',';
        	END LOOP;
        l_org_list := substr(l_org_list, 1, length(l_org_list)-1);
        p_org_where := ' and f.org_id in ('||l_org_list||') ';

   	/*  CASE 4: User has access to a single organization. */
  	ELSIF l_org_count = 1 THEN
        	SELECT organization_id INTO l_org_id FROM hr_operating_units hr, ap_system_parameters_all ap WHERE hr.business_group_id = l_business_group_id AND hr.organization_id = ap.org_id;
        	p_org_where := ' and f.org_id = ' || l_org_id;

   	/*  CASE 5: User has access to no organizations. */
  	ELSIF l_org_count = 0 THEN
        	p_org_where := ' and f.org_id = -1 ';

  	END IF;

  ELSE

      SELECT COUNT(1)
      INTO l_org_count
      FROM per_organization_list per, ap_system_parameters_all ap
      WHERE per.security_profile_id = g_security_profile_id
      AND per.organization_id = ap.org_id;

   	/*  Case 2: User has access to more than 5 organizations. */
      	IF l_org_count > 5 THEN
        	p_org_where := ' and f.org_id in (select organization_id from per_organization_list per, ap_system_parameters_all ap where per.security_profile_id = :SEC_ID and per.organization_id = ap.org_id) ';

   	/*  Case 3: User has access to 2-5 organizations. */
      	ELSIF (l_org_count >= 2 and l_org_count <= 5) THEN
        	FOR C1_Rec in (select organization_id from per_organization_list per, ap_system_parameters_all ap where per.security_profile_id = g_security_profile_id and   per.organization_id = ap.org_id)
		LOOP
         		l_org_list := l_org_list||C1_Rec.organization_id||',';
         END LOOP;
        l_org_list := substr(l_org_list, 1, length(l_org_list)-1);
        p_org_where := ' and f.org_id in ('||l_org_list||') ';

   	/*  CASE 4: User has access to a single organization. */
      	ELSIF l_org_count = 1 THEN
      		SELECT organization_id INTO l_org_id FROM per_organization_list per, ap_system_parameters_all ap WHERE security_profile_id = g_security_profile_id AND per.organization_id = ap.org_id;
        	p_org_where := ' and f.org_id = ' || l_org_id;
   /*  CASE 5: User has access to no organizations. */
      	ELSIF l_org_count = 0 THEN
        	p_org_where := ' and f.org_id = -1 ';
      	END IF;

 END IF;

--Security is dictated by 'MO: Security Profile'.
  ELSIF g_security_org_id is not null THEN
    -- CASE 4: User has access to a single organization.
    p_org_where := 'and f.org_id = :SEC_ORG_ID';
  ELSE
    -- CASE 5: User has access to no organizations.
    p_org_where := ' and f.org_id = -1 ';
  END IF;

END IF;
IF p_operating_unit is not null and p_operating_unit <> 'All' then
     p_org_where := ' and f.org_id = &ORGANIZATION+FII_OPERATING_UNITS ';
END IF;
IF p_supplier is not null and p_supplier <> 'All' then
     p_supplier_where := ' and f.supplier_id = &SUPPLIER+POA_SUPPLIERS ';
END IF;

END get_parameters;

  /*public procedure.  binding variables is done here.*/
PROCEDURE Bind_Variable
     (p_sqlstmt IN Varchar2,
     p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
     p_sql_output OUT NOCOPY Varchar2,
     p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL,
     p_invoice_number IN Varchar2 Default null,
     p_record_type_id IN Number Default Null,
     p_view_by IN Varchar2 Default Null,
     p_gid IN Number Default Null,
     p_period_start   IN Date     Default null,
     p_check_id       IN Number Default null,

     p_created        IN Varchar2 Default null,
     p_stopped        IN Varchar2 Default null,
     p_stop_released  IN Varchar2 Default null,
     p_cleared        IN Varchar2 Default null,
     p_reconciled     IN Varchar2 Default null,
     p_unreconciled   IN Varchar2 Default null,
     p_uncleared      IN Varchar2 Default null,
     p_voided         IN Varchar2 Default null ,

     p_entry          IN Varchar2 Default null,
     p_hold_placed    IN Varchar2 Default null,
     p_hold_released  IN Varchar2 Default null,
     p_prepay_applied IN Varchar2 Default null,
     p_prepay_unapplied IN Varchar2 Default null,
     p_payment        IN Varchar2 Default null,
     p_paymt_void     IN Varchar2 Default null,
     p_paymt_stop     IN Varchar2 Default null,
     p_paymt_release  IN Varchar2 Default null,
     p_line_number    IN Number Default null,

     p_fiibind1          IN Varchar2 Default null,
     p_fiibind2          IN Varchar2 Default null,
     p_fiibind3          IN Varchar2 Default null,
     p_fiibind4          IN Varchar2 Default null,
     p_fiibind5          IN Varchar2 Default null,
     p_fiibind6          IN Varchar2 Default null
      ) IS
     l_bind_rec       BIS_QUERY_ATTRIBUTES;

BEGIN
       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND1';
       l_bind_rec.attribute_value := to_char(p_fiibind1);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND2';
       l_bind_rec.attribute_value := to_char(p_fiibind2);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND3';
       l_bind_rec.attribute_value := to_char(p_fiibind3);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND4';
       l_bind_rec.attribute_value := to_char(p_fiibind4);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND5';
       l_bind_rec.attribute_value := to_char(p_fiibind5);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIIBIND6';
       l_bind_rec.attribute_value := to_char(p_fiibind6);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENTRY';
       l_bind_rec.attribute_value := to_char(p_entry);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':HOLD_PLACED';
       l_bind_rec.attribute_value := to_char(p_hold_placed);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':HOLD_RELEASED';
       l_bind_rec.attribute_value := to_char(p_hold_released);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREPAY_APPLIED';
       l_bind_rec.attribute_value := to_char(p_prepay_applied);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
        p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREPAY_UNAPPLIED';
       l_bind_rec.attribute_value := to_char(p_prepay_unapplied);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PAYMT';
       l_bind_rec.attribute_value := to_char(p_payment);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
        p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PAYMT_VOID';
       l_bind_rec.attribute_value := to_char(p_paymt_void);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PAYMT_STOP';
       l_bind_rec.attribute_value := to_char(p_paymt_stop);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PAYMT_RELEASE';
       l_bind_rec.attribute_value := to_char(p_paymt_release);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CREATED';
       l_bind_rec.attribute_value := to_char(p_created);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':STOPPED';
       l_bind_rec.attribute_value := to_char(p_stopped);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':STOP_RELEASED';
       l_bind_rec.attribute_value := to_char(p_stop_released);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CLEARED';
       l_bind_rec.attribute_value := to_char(p_cleared);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':RECONCILED';
       l_bind_rec.attribute_value := to_char(p_reconciled);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':UNRECONCILED';
       l_bind_rec.attribute_value := to_char(p_unreconciled);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':UNCLEARED';
       l_bind_rec.attribute_value := to_char(p_uncleared);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':VOIDED';
       l_bind_rec.attribute_value := to_char(p_voided);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':INVOICE_ID';
       l_bind_rec.attribute_value := to_char(p_invoice_number);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':VIEW_BY';
       l_bind_rec.attribute_value := to_char(p_view_by);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':RECORD_TYPE_ID';
       l_bind_rec.attribute_value := to_char(p_record_type_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':GID';
       l_bind_rec.attribute_value := to_char(p_gid);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SEC_ID';
       l_bind_rec.attribute_value := fii_pmv_util.get_sec_profile;
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PERIOD_START';
       l_bind_rec.attribute_value := to_char(p_period_start, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CHECK_ID';
       l_bind_rec.attribute_value := to_char(p_check_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':LINE_NUMBER';
       l_bind_rec.attribute_value := to_char(p_line_number);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':BUSINESS_GROUP';
       l_bind_rec.attribute_value := to_char(g_business_group_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':SEC_ORG_ID';
       l_bind_rec.attribute_value := g_security_org_id;
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

              --added by vkazhipu
       l_bind_rec.attribute_name := ':ASOF_DATE_JULIEN';
       l_bind_rec.attribute_value := to_number(to_char(g_p_as_of_date,'J'));
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':GID2';
       l_bind_rec.attribute_value := to_char(g_gid);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':PREVIOUS_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_date, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;


END;

/*public function which gets invoice id for a given invoice number */
PROCEDURE get_invoice_id(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_invoice_id OUT NOCOPY Number)
IS
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_INVOICE_ID' OR p_page_parameter_tbl(i).parameter_name= 'FII_AP_INVOICE_ID' THEN
          p_invoice_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
END;
/*

PROCEDURE get_period_start(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_period_start OUT NOCOPY Date,
                           p_days_into_period OUT NOCOPY Number,
                           p_cur_period OUT NOCOPY Number,
                           p_id_column OUT NOCOPY Varchar2)
IS
   l_as_of_date Date;
BEGIN
   IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
          IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
             l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
            END IF;
          IF p_page_parameter_tbl(i).parameter_name = 'FII_TIME_WEEK_FROM' THEN
             p_cur_period := to_number(p_page_parameter_tbl(i).parameter_id);
             p_id_column := 'week_id';
             select (to_date(l_as_of_date,'DD-MM-YYYY') - start_date) into p_days_into_period from fii_time_week where week_id = p_cur_period;
            p_period_start := fii_time_api.cwk_start(l_as_of_date);
          ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_TIME_ENT_PERIOD_FROM' THEN
             p_cur_period := p_page_parameter_tbl(i).parameter_id;
             p_id_column := 'ent_period_id';
             select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_period where ent_period_id = p_cur_period;
            p_period_start := fii_time_api.ent_cper_start(l_as_of_date);
          ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_TIME_ENT_QTR_FROM' THEN
             p_cur_period := p_page_parameter_tbl(i).parameter_id;
             p_id_column := 'ent_qtr_id';
             select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_qtr where ent_qtr_id = p_cur_period;
            p_period_start := fii_time_api.ent_cqtr_start(l_as_of_date);
           ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_TIME_ENT_YEAR_FROM' THEN
             p_cur_period := p_page_parameter_tbl(i).parameter_id;
             p_id_column := 'ent_year_id';
             select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_year where ent_year_id = p_cur_period;
            p_period_start := fii_time_api.ent_cyr_start(l_as_of_date);
          END IF;
     END LOOP;
    END IF;
    p_days_into_period := l_as_of_date - p_period_start;
END;
*/

PROCEDURE get_period_start(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_period_start OUT NOCOPY Date,
                           p_days_into_period OUT NOCOPY Number,
                           p_cur_period OUT NOCOPY Number,
                           p_id_column OUT NOCOPY Varchar2)
IS
   l_as_of_date         DATE;
   l_record_type_id     NUMBER;
   l_start_date date;
   l_period_type varchar2(200);

BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
        l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
        l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_WEEK_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'week_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_PERIOD_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_period_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_QTR_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_qtr_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'TIME+FII_TIME_ENT_YEAR_FROM' THEN
         p_cur_period := p_page_parameter_tbl(i).parameter_id;
         p_id_column := 'ent_year_id';
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'BIS_CURRENT_REPORT_START_DATE' THEN
         p_period_start := to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
       END IF;

     END LOOP;
  END IF;

 CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN
      select (l_as_of_date - start_date) into p_days_into_period from fii_time_week where week_id = p_cur_period;
    WHEN 'FII_TIME_ENT_PERIOD' THEN
      select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_period where ent_period_id = p_cur_period;
    WHEN 'FII_TIME_ENT_QTR' THEN
      select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_qtr where ent_qtr_id = p_cur_period;
    WHEN 'FII_TIME_ENT_YEAR'   THEN
      select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_year where ent_year_id = p_cur_period;
    ELSE
      select (l_as_of_date - start_date) into p_days_into_period from fii_time_ent_year where ent_year_id = p_cur_period;
   END CASE;

END;

PROCEDURE get_period_strt(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_period_start OUT NOCOPY Date,
                           p_days_into_period OUT NOCOPY Number,
                           p_cur_period OUT NOCOPY Number,
                           p_id_column OUT NOCOPY Varchar2)
IS
   l_as_of_date         DATE;
   l_period_type        VARCHAR2(32000);

BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
        l_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value, 'DD-MM-YYYY');
       END IF;
       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
         l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
     END LOOP;

     IF l_as_of_date is not null then
       If l_period_type is not null then
         CASE l_period_type
           WHEN 'FII_TIME_WEEK'       THEN
             select week_id into p_cur_period from fii_time_day where report_date=l_as_of_date;
             p_id_column := 'week_id';
             BEGIN
                p_period_start := fii_time_api.cwk_start(l_as_of_date);
             EXCEPTION
                When no_data_found then
                p_period_start := fii_time_api.cwk_start(sysdate);
             END;
           WHEN 'FII_TIME_ENT_PERIOD' THEN
             select ent_period_id into p_cur_period from fii_time_day where report_date=l_as_of_date;
             p_id_column := 'ent_period_id';
             BEGIN
                p_period_start := fii_time_api.ent_cper_start(l_as_of_date);
             EXCEPTION
                When no_data_found then
                p_period_start := fii_time_api.ent_cper_start(sysdate);
             END;
           WHEN 'FII_TIME_ENT_QTR'    THEN
             select ent_qtr_id into p_cur_period from fii_time_day where report_date=l_as_of_date;
             p_id_column := 'ent_qtr_id';
             BEGIN
                p_period_start := fii_time_api.ent_cqtr_start(l_as_of_date);
             EXCEPTION
                When no_data_found then
                p_period_start := fii_time_api.ent_cqtr_start(sysdate);
             END;
           WHEN 'FII_TIME_ENT_YEAR'   THEN
             select ent_year_id into p_cur_period from fii_time_day where report_date=l_as_of_date;
             p_id_column := 'ent_year_id';
             BEGIN
                p_period_start := fii_time_api.ent_cyr_start(l_as_of_date);
             EXCEPTION
                When no_data_found then
                p_period_start := fii_time_api.ent_cyr_start(sysdate);
             END;
         END CASE;
       End if;
     END IF;
  END IF;
  p_days_into_period := l_as_of_date - p_period_start;
END;

PROCEDURE get_report_source(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_report_source OUT NOCOPY Varchar2)
IS
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_REPORT_SOURCE' THEN
          p_report_source := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
END;

PROCEDURE get_check_id(p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
                            p_check_id OUT NOCOPY Number)
IS
  l_check_number Number;
BEGIN
  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
       IF p_page_parameter_tbl(i).parameter_name = 'FII_CHECK_ID' THEN
          p_check_id := p_page_parameter_tbl(i).parameter_id;
       END IF;
     END LOOP;
  END IF;
END;

FUNCTION get_base_curr_colname(p_currency IN Varchar2, p_column_name IN Varchar2) return Varchar2
IS
      p_curr_amt_col VARCHAR2(100);
BEGIN
      If p_currency is not null then
           IF p_currency = '_prim_g' THEN
              p_curr_amt_col := 'prim_'||p_column_name;
           ELSIF p_currency = '_sec_g' THEN
              p_curr_amt_col := 'sec_'||p_column_name;
           ELSE
              p_curr_amt_col := p_column_name||'_b';
           END IF;
        End if;
        RETURN p_curr_amt_col;
END;

FUNCTION get_period_type_suffix (p_period_type IN Varchar2) return Varchar2
IS
       l_per_type Varchar2(100);
BEGIN
       IF p_period_type = 'FII_TIME_WEEK'   then
          l_per_type       := '_wtd';
       ELSIF p_period_type = 'FII_TIME_ENT_PERIOD' then
          l_per_type       := '_mtd';
       ELSIF p_period_type = 'FII_TIME_ENT_QTR' then
          l_per_type       := '_qtd';
       ELSIF p_period_type = 'FII_TIME_ENT_YEAR' then
          l_per_type       := '_ytd';
       END IF;
       return l_per_type;
END;

PROCEDURE get_yes_no_msg(p_yes OUT NOCOPY Varchar2, p_no OUT NOCOPY Varchar2)
IS
BEGIN
    p_yes := FND_MESSAGE.get_string('FND', 'FND_DEFAULT_CUST_YES');
    p_no  := FND_MESSAGE.get_string('FND', 'FND_DEFAULT_CUST_NO');
END;

PROCEDURE get_format_mask(p_date_format_mask OUT NOCOPY Varchar2)
IS
BEGIN
   p_date_format_mask := FND_DATE.output_mask;
END;

FUNCTION determine_OU_LOV RETURN NUMBER IS
--	l_security_profile_id   Number;
--	l_security_org_id   Number;
    	l_all_org_flag  VARCHAR2(30);
    	l_business_group_id NUMBER;

BEGIN
	IF g_security_profile_id IS NULL THEN
		g_security_profile_id := fii_pmv_util.get_sec_profile;
	END IF;

	IF g_security_org_id IS NULL THEN
		g_security_org_id := fnd_profile.value('ORG_ID');
	END IF;

-- Bug 5527135: Added the condition to also handle  g_security_profile_id <> -1
	IF g_security_profile_id is NOT NULL AND  g_security_profile_id <> -1 THEN
		SELECT view_all_organizations_flag, business_group_id
		INTO l_all_org_flag, l_business_group_id
		FROM per_security_profiles
		WHERE security_profile_id = g_security_profile_id;

	/* 'MO: Security Profile' is defined with a global view all security profile.*/
		IF l_all_org_flag = 'Y' and l_business_group_id is NULL THEN
			return 1;
	/* 'MO: Security Profile' is defined with a business group view all security profile.*/
		ELSIF l_all_org_flag = 'Y' and l_business_group_id is NOT NULL THEN
			return 2;
		ELSE
	/* 'MO: Security Profile' is not defined with a view all security profile.*/
			return 3;
		END IF;
	ELSE
	/* 'MO: Security Profile' is not defined. */
		return 4;
	END IF;

END;

FUNCTION get_business_group RETURN NUMBER IS
--	l_security_profile_id NUMBER;
	l_business_group_id NUMBER;
BEGIN
		g_security_profile_id := fii_pmv_util.get_sec_profile;

	SELECT business_group_id
	INTO l_business_group_id
	FROM per_security_profiles
	WHERE security_profile_id = g_security_profile_id;

        return NVL(l_business_group_id,-1);
EXCEPTION
  when too_many_rows then
    return -1;
  when others then
   return -1;

END;

END fii_pmv_util;

/
