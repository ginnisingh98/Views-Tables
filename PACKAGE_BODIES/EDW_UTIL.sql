--------------------------------------------------------
--  DDL for Package Body EDW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_UTIL" AS
/* $Header: EDWSRGTB.pls 115.15 2003/02/28 02:01:37 rjin ship $  */
VERSION                 CONSTANT CHAR(80) := '$Header: EDWSRGTB.pls 115.15 2003/02/28 02:01:37 rjin ship $';

FUNCTION get_base_currency( p_organization_id  IN NUMBER)
		RETURN VARCHAR2  IS

l_currency_code  VARCHAR2(15);

BEGIN
		SELECT	gsob.currency_code
		INTO	l_currency_code
		FROM	hr_all_organization_units hou,
			hr_organization_information hoi,
			gl_sets_of_books gsob
		WHERE   hou.organization_id                             = hoi.organization_id
		        AND ( hoi.org_information_context || '')        ='Accounting Information'
        		AND hoi.org_information1                        = to_char(gsob.set_of_books_id)
        		AND hou.organization_id                         = p_organization_id;

 		return  l_currency_code;

EXCEPTION when others then
        return( 'Invalid - ' || p_organization_id);

END get_base_currency;

FUNCTION get_item_cost(p_item_id in number,
                       p_org_id  in number)
		return NUMBER IS

l_cost        NUMBER;

BEGIN

  SELECT NVL(cst.item_cost,0)
  INTO l_cost
  FROM cst_cost_types cct,
       mtl_parameters mtl,
       cst_item_costs cst
  WHERE (cst.cost_type_id = cct.cost_type_id
        OR (cst.cost_type_id = cct.default_cost_type_id
        AND (NOT EXISTS (SELECT 'Primary Cost Type Row'
                        FROM cst_item_costs cst1
                        WHERE cst1.inventory_item_id = cst.inventory_item_id
                          AND cst1.organization_id = cst.organization_id
                          AND cst1.cost_type_id = cct.cost_type_id))))
    AND cct.costing_method_type = mtl.primary_cost_method
    AND cct.cost_type_id = DECODE(mtl.primary_cost_method,1,1,2,2,1)
    AND mtl.organization_id = p_org_id
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = mtl.cost_organization_id;

	return(l_cost);

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           return 0;

END get_item_cost;

/*
FUNCTION get_item_price(p_item_id in number,
                        p_org_id  in number,
                        p_price_list_id in number default null,
                        p_currency in varchar2 default null)
		 return NUMBER  IS

l_price number;

BEGIN
   SELECT round(list_price *
--          (1 - (NVL(FND_PROFILE.Value_Specific('MRP_BIS_AV_DISCOUNT'),0)/100)),
          (1 - (NVL( fval1.profile_option_value, 0)/100)),
                NVL(spl.rounding_factor,2))
   INTO l_price
   FROM so_price_list_lines sopl,
        fnd_profile_option_values fval1,
        fnd_profile_options fpo1,
        fnd_profile_option_values fval2,
        fnd_profile_options fpo2,
        mtl_system_items msi,
        so_price_lists spl
   WHERE spl.price_list_id  		= fval2.profile_option_value
--   WHERE spl.price_list_id  		= FND_PROFILE.Value_Specific('MRP_BIS_PRICE_LIST')
   AND   sopl.price_list_id  		= spl.price_list_id
   AND   sopl.inventory_item_id 	= p_item_id
   AND   msi.inventory_item_id 		= p_item_id
   AND   msi.organization_id 		= p_org_id
   AND   nvl(sopl.unit_code,' ') 	= nvl(msi.primary_uom_code,' ')
   AND   sysdate between nvl(sopl.start_date_active, sysdate-1)
                  and nvl(sopl.end_date_active, sysdate+1)
  AND   fval1.profile_option_id = fpo1.profile_option_id
  AND   fval1.application_id = fpo1.application_id
  AND   fval1.level_id = 10001  -- Site level
  AND   fval1.level_value = 0
  AND   nvl(fpo1.end_date_active,sysdate) >= sysdate
  AND   fpo1.start_date_active <= sysdate
  AND   fpo1.profile_option_name = 'MRP:MRP_BIS_AV_DISCOUNT'
  AND   fval2.profile_option_id = fpo2.profile_option_id
  AND   fval2.application_id = fpo2.application_id
  AND   fval2.level_id = 10001  -- Site level
  AND   fval2.level_value = 0
  AND   nvl(fpo2.end_date_active,sysdate) >= sysdate
  AND   fpo2.start_date_active <= sysdate
  AND   fpo2.profile_option_name = 'MRP:MRP_BISPRICE_LIST'
  AND   rownum 			= 1;

    return l_price;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           return EDW_UTIL.get_item_cost(p_item_id, p_org_id);

END get_item_price;
*/

FUNCTION get_est_ship_date (p_disposition_id IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_compile_designator IN VARCHAR2)
			RETURN DATE IS

  l_days        NUMBER;

BEGIN

  SELECT max(rec.new_schedule_date - peg2.demand_date)
  INTO l_days
  FROM mrp_gross_requirements greq,
       mrp_recommendations rec,
       mrp_full_pegging peg1,
       mrp_full_pegging peg2
  WHERE greq.disposition_id = p_disposition_id
    AND peg1.demand_id = greq.demand_id
    AND peg1.transaction_id = rec.transaction_id
    AND peg1.pegging_id = peg2.end_pegging_id
    AND peg2.organization_id = p_organization_id
    AND peg2.compile_designator = p_compile_designator;


  RETURN sysdate;

EXCEPTION

  WHEN OTHERS THEN

    RETURN sysdate;

END get_est_ship_date;

FUNCTION get_party_id(p_sold_to_org_id IN NUMBER)
                RETURN NUMBER IS
        l_party_id NUMBER;
BEGIN

SELECT hca.party_id
INTO    l_party_id
FROM
        hz_cust_accounts                hca
WHERE
           hca.cust_account_id = p_sold_to_org_id;

RETURN l_party_id;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           return to_number(NULL);
END get_party_id;

FUNCTION get_line_detail_count(p_line_id IN NUMBER)
                RETURN NUMBER IS
        l_count NUMBER;
BEGIN

SELECT  count(*)
INTO    l_count
FROM
wsh_delivery_details wdd
WHERE
  wdd.SOURCE_LINE_ID = p_line_id
  AND wdd.inv_interfaced_flag = 'Y'
  and wdd.SOURCE_CODE = 'OE';

  /* just in case, there is bad data */
  IF l_count = 0 THEN
     l_count := 1;
  END IF;

RETURN l_count;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           return 1;
END get_line_detail_count;

FUNCTION get_pto_mmt_count(p_line_id IN NUMBER)
                RETURN NUMBER IS
	l_count NUMBER;

BEGIN

   select count(*) INTO l_count
from wsh_delivery_details wdd,
oe_order_lines_all l
where l.top_model_line_id = p_line_id
and wdd.source_line_id = l.line_id
AND wdd.inv_interfaced_flag = 'Y'
and wdd.SOURCE_CODE = 'OE';

   /*
SELECT  count(*)
INTO    l_count
FROM
        mtl_material_transactions
WHERE
        trx_source_line_id = p_line_id;
  */

  /* just in case, there is bad data */
  IF l_count = 0 THEN
     l_count := 1;
  END IF;

RETURN l_count;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           return 1;
END get_pto_mmt_count;


FUNCTION get_wh_global_currency RETURN VARCHAR2 IS
    v_currency_code	VARCHAR2(20);
BEGIN

SELECT warehouse_currency_code
INTO v_currency_code
FROM edw_local_system_parameters;

RETURN (v_currency_code);

EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RETURN('UNKNOWN');

END get_wh_global_currency;

FUNCTION get_rep_sched_scrapped_qty(rep_sched_id number,
				organization_id number) RETURN NUMBER IS
l_scrapped number:=0;
BEGIN
	begin
	select sum(wo.quantity_scrapped) into
		l_scrapped
	from wip_operations wo
	where
		wo.repetitive_schedule_id=rep_sched_id
	and	wo.organization_id=organization_id;
	exception when others then
		l_scrapped:=0;
	end;

	return l_scrapped;
END get_rep_sched_scrapped_qty;

FUNCTION get_app_info return VARCHAR2 is
l_dummy1 Varchar2(32);
l_dummy2 Varchar2(32);
l_retval Boolean;
l_bis_owner Varchar2(32):='BIS';

begin
l_retval := FND_INSTALLATION.GET_APP_INFO('BIS',
				l_dummy1, l_dummy2,
				l_bis_owner);
return l_bis_owner;
exception when others then
	return l_bis_owner;

end get_app_info ;

function get_base_transaction_value(p_transaction_id number,
				p_transfer_transaction_id number,
				p_action_id number,
				p_quantity number) RETURN NUMBER IS
l_value number;
begin

	select sum(BASE_TRANSACTION_VALUE) into l_value
	 from
		MTL_TRANSACTION_ACCOUNTS
	where
		ACCOUNTING_LINE_TYPE=1
	and     sign(primary_quantity) 	= decode(p_action_id,2,
                                            sign(p_quantity),
                                            sign(primary_quantity))
	and	TRANSACTION_ID 		= decode(p_action_id,
						2, decode(sign(p_quantity),
								-1,p_transaction_id,
								p_transfer_transaction_id),
						3, decode(sign(p_quantity),
								-1,p_transaction_id,
								p_transfer_transaction_id),
								p_transaction_id);

	return nvl(l_value,0);

exception when others then
	return 0;
end get_base_transaction_value;

/******************************************************************************
 * Convert transactional UOM to EDW Base UOM
 ******************************************************************************/
FUNCTION get_edw_base_uom(p_uom_code IN VARCHAR2,
                     p_inventory_id IN NUMBER)
                RETURN VARCHAR2 IS
l_inventory_id          NUMBER;
l_edw_uom_code          VARCHAR2(20);
CURSOR global_uom_c IS
  SELECT UOM_EDW_BASE_UOM
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT edw_base_uom_fk
    FROM OPI_EDW_LOCAL_UOM_CONV_F, edw_local_instance
   WHERE ((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'|| instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||instance_code);
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_uom_code;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_uom_code;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom - getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_uom_code;
           END IF;
           IF uom_c%NOTFOUND THEN
	     -- Fix for Bug# 1844559
             -- RETURN 'NA_EDW';
		RETURN 'Invalid - '||p_uom_code ;
           ELSE
             RETURN l_edw_uom_code;
           END IF;
        ELSE
           RETURN l_edw_uom_code;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN('Invalid - '||p_uom_code);
END get_edw_base_uom;

/********************************************************************************************************
 * Convert transactional UOM to EDW Base UOM (overloaded version that accepts Instance_Code as Parameter)
 *******************************************************************************************************/


FUNCTION get_edw_base_uom(p_uom_code IN VARCHAR2,
                     p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2)
                RETURN VARCHAR2 IS
l_inventory_id          NUMBER;
l_edw_uom_code          VARCHAR2(20);
CURSOR global_uom_c IS
  SELECT UOM_EDW_BASE_UOM
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT edw_base_uom_fk
    FROM OPI_EDW_LOCAL_UOM_CONV_F
   WHERE ((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'||p_instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||p_instance_code);
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_uom_code;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_uom_code;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom - getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_uom_code;
           END IF;
           IF uom_c%NOTFOUND THEN
	     -- Fix for Bug# 1844559
             -- RETURN 'NA_EDW';
		RETURN 'Invalid - '||p_uom_code ;
           ELSE
             RETURN l_edw_uom_code;
           END IF;
        ELSE
           RETURN l_edw_uom_code;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN('Invalid - '||p_uom_code);
END get_edw_base_uom;


/******************************************************************************
 * Get conversion_rate for conversion from transactional UOM to EDW Base UOM
 ******************************************************************************/
FUNCTION get_uom_conv_rate(p_uom_code IN VARCHAR2,
                           p_inventory_id IN NUMBER)
                RETURN NUMBER IS
l_inventory_id          NUMBER;
l_edw_conv_rate         NUMBER;

CURSOR global_uom_c IS
  SELECT UOM_conversion_rate
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT EDW_CONVERSION_RATE
    FROM OPI_EDW_LOCAL_UOM_CONV_F, edw_local_instance
   WHERE
    CLASS_CONVERSION_FLAG = 'N' AND (
((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'|| instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||instance_code) );
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_conv_rate;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_conv_rate;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom. Getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_conv_rate;
           END IF;
           IF uom_c%NOTFOUND THEN
             RETURN 'NA_EDW';
           ELSE
             RETURN l_edw_conv_rate;
           END IF;
        ELSE
           RETURN l_edw_conv_rate;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN(NULL);

END get_uom_conv_rate;


/****************************************************************************************************************************************
 * Get conversion_rate for conversion from transactional UOM to EDW Base UOM (overloaded version that accepts Instance_Code as Parameter)
 ***************************************************************************************************************************************/

FUNCTION get_uom_conv_rate(p_uom_code IN VARCHAR2,
                           p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2)
                RETURN NUMBER IS
l_inventory_id          NUMBER;
l_edw_conv_rate         NUMBER;

CURSOR global_uom_c IS
  SELECT UOM_conversion_rate
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT EDW_CONVERSION_RATE
    FROM OPI_EDW_LOCAL_UOM_CONV_F
   WHERE
    CLASS_CONVERSION_FLAG = 'N' AND (
((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'|| p_instance_code )
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||p_instance_code) );
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_conv_rate;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_conv_rate;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom. Getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_conv_rate;
           END IF;
           IF uom_c%NOTFOUND THEN
             RETURN 'NA_EDW';
           ELSE
             RETURN l_edw_conv_rate;
           END IF;
        ELSE
           RETURN l_edw_conv_rate;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN(NULL);

END get_uom_conv_rate;

/************************************************************************************
 * Get conversion_rate for conversion from one EDW Base UOM to another EDW Base UOM
 ************************************************************************************/

FUNCTION get_uom_conv_rate(p_inventory_id IN NUMBER,
                           p_from_edw_base_uom_code IN VARCHAR2,
                           p_to_edw_base_uom_code IN VARCHAR2)
                           RETURN NUMBER IS
l_inventory_id          NUMBER;
l_edw_conv_rate         NUMBER;

CURSOR uom_c IS
  SELECT EDW_CONVERSION_RATE
    FROM OPI_EDW_LOCAL_UOM_CONV_F, edw_local_instance
   WHERE
    CLASS_CONVERSION_FLAG = 'Y' AND (
((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_from_edw_base_uom_code||'-'||
         p_to_edw_base_uom_code||'-'||instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'|| p_from_edw_base_uom_code||'-'||
  p_to_edw_base_uom_code||'-'||instance_code) );

BEGIN
        l_inventory_id := p_inventory_id;
        OPEN uom_c;
        FETCH uom_c INTO l_edw_conv_rate;
        IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
           l_inventory_id := 0;
           CLOSE uom_c;
-- no item specific uom. Getting STANDARD uom
           OPEN uom_c;
           FETCH uom_c INTO l_edw_conv_rate;
        END IF;
        IF uom_c%NOTFOUND THEN
              CLOSE uom_c;
              RETURN 'NA_EDW';
        ELSE
              CLOSE uom_c;
              RETURN l_edw_conv_rate;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN(NULL);

END get_uom_conv_rate;


/***********************************************************************************************************************************************
 * Get conversion_rate for conversion from one EDW Base UOM to another EDW Base UOM (overloaded version that accepts Instance_Code as Parameter)
 **********************************************************************************************************************************************/

FUNCTION get_uom_conv_rate(p_inventory_id IN NUMBER,
                           p_from_edw_base_uom_code IN VARCHAR2,
                           p_to_edw_base_uom_code IN VARCHAR2, p_instance_code IN VARCHAR2)
                           RETURN NUMBER IS
l_inventory_id          NUMBER;
l_edw_conv_rate         NUMBER;

CURSOR uom_c IS
  SELECT EDW_CONVERSION_RATE
    FROM OPI_EDW_LOCAL_UOM_CONV_F
   WHERE
    CLASS_CONVERSION_FLAG = 'Y' AND (
((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_from_edw_base_uom_code||'-'||
         p_to_edw_base_uom_code||'-'||p_instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'|| p_from_edw_base_uom_code||'-'||
  p_to_edw_base_uom_code||'-'||p_instance_code) );

BEGIN
        l_inventory_id := p_inventory_id;
        OPEN uom_c;
        FETCH uom_c INTO l_edw_conv_rate;
        IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
           l_inventory_id := 0;
           CLOSE uom_c;
-- no item specific uom. Getting STANDARD uom
           OPEN uom_c;
           FETCH uom_c INTO l_edw_conv_rate;
        END IF;
        IF uom_c%NOTFOUND THEN
              CLOSE uom_c;
              RETURN 'NA_EDW';
        ELSE
              CLOSE uom_c;
              RETURN l_edw_conv_rate;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN(NULL);

END get_uom_conv_rate;

/******************************************************************************
 * Get EDW UOM corresponding to a transactional UOM
 ******************************************************************************/
FUNCTION get_edw_uom(p_uom_code IN VARCHAR2,
                     p_inventory_id IN NUMBER)
                RETURN VARCHAR2 IS
l_inventory_id          NUMBER;
l_edw_uom_code          VARCHAR2(20);
CURSOR global_uom_c IS
  SELECT uom_edw_uom_pk
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT edw_uom_fk
    FROM OPI_EDW_LOCAL_UOM_CONV_F, edw_local_instance
   WHERE ((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'|| instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||instance_code);
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_uom_code;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_uom_code;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom - getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_uom_code;
           END IF;
           IF uom_c%NOTFOUND THEN
	     -- Fix for Bug# 1844559
             -- RETURN 'NA_EDW';
		RETURN 'Invalid - '||p_uom_code ;
           ELSE
             RETURN l_edw_uom_code;
           END IF;
        ELSE
           RETURN l_edw_uom_code;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN('Invalid - '||p_uom_code);
END get_edw_uom;


/***************************************************************************************************************
 * Get EDW UOM corresponding to a transactional UOM (overloaded version that accepts Instance_Code as Parameter)
 **************************************************************************************************************/
FUNCTION get_edw_uom(p_uom_code IN VARCHAR2,
                     p_inventory_id IN NUMBER, p_instance_code IN VARCHAR2)
                RETURN VARCHAR2 IS
l_inventory_id          NUMBER;
l_edw_uom_code          VARCHAR2(20);
CURSOR global_uom_c IS
  SELECT uom_edw_uom_pk
    FROM EDW_MTL_LOCAL_UOM_M
   WHERE
        UOM_EDW_UOM_PK = p_uom_code
        AND UOM_global_flag = 'Y';
CURSOR uom_c IS
  SELECT edw_uom_fk
    FROM OPI_EDW_LOCAL_UOM_CONV_F
   WHERE ((l_inventory_id IS NULL OR l_inventory_id = 0)
        AND uom_conv_pk = 'STANDARD'||'-'|| p_uom_code||'-'|| p_instance_code)
      OR (l_inventory_id <> 0
        AND uom_conv_pk = l_inventory_id||'-'||p_uom_code||'-'||p_instance_code);
BEGIN
        l_inventory_id := p_inventory_id;
        OPEN global_uom_c;
        FETCH global_uom_c INTO l_edw_uom_code;
        IF global_uom_c%NOTFOUND THEN
           CLOSE global_uom_c;
           OPEN uom_c;
           FETCH uom_c INTO l_edw_uom_code;
           IF uom_c%NOTFOUND AND l_inventory_id <> 0 THEN
             l_inventory_id := 0;
             CLOSE uom_c;
-- no item specific uom - getting STANDARD uom
             OPEN uom_c;
             FETCH uom_c INTO l_edw_uom_code;
           END IF;
           IF uom_c%NOTFOUND THEN
	     -- Fix for Bug# 1844559
             -- RETURN 'NA_EDW';
		RETURN 'Invalid - '||p_uom_code ;
           ELSE
             RETURN l_edw_uom_code;
           END IF;
        ELSE
           RETURN l_edw_uom_code;
        END IF;
EXCEPTION WHEN OTHERS THEN
        RETURN('Invalid - '||p_uom_code);
END get_edw_uom;

/******************************************************************************
 * Get the required Id. based on p_type being 1 - 5
 ******************************************************************************/
-- --------------------------------------------------------------
-- For Operating Unit p_type = 1,
-- For Business Unit  p_type = 2,
-- For Legal Entity   p_type = 3,
-- For Set of Books   p_type = 4
-- For Chart of Acct. p_type = 5
-- --------------------------------------------------------------

FUNCTION bus_unit_id (p_type IN NUMBER,
                      p_organization_id IN NUMBER) return NUMBER IS

l_bus_unit_id		NUMBER;

cursor c is
	SELECT decode(p_type,
		1,DECODE(FPG.MULTI_ORG_FLAG,'Y',TO_NUMBER(HOI.ORG_INFORMATION3), NULL),
		2,HOU.BUSINESS_GROUP_ID,
		3,TO_NUMBER(HOI.ORG_INFORMATION2),
		4,GSOB.SET_OF_BOOKS_ID,
		5,GSOB.CHART_OF_ACCOUNTS_ID)
	FROM
		HR_all_ORGANIZATION_UNITS HOU,
		HR_ORGANIZATION_INFORMATION HOI,
		GL_SETS_OF_BOOKS GSOB,
		FND_PRODUCT_GROUPS FPG
	WHERE
		HOU.ORGANIZATION_ID 			= HOI.ORGANIZATION_ID
	AND 	(HOI.ORG_INFORMATION_CONTEXT || '') 	='Accounting Information'
	AND 	HOI.ORG_INFORMATION1 			= TO_CHAR(GSOB.SET_OF_BOOKS_ID)
	AND 	HOU.organization_id			= p_organization_id;
BEGIN
	l_bus_unit_id := -1;

	OPEN c;
	FETCH c INTO l_bus_unit_id;
	CLOSE c;

	return l_bus_unit_id;


EXCEPTION when others then
	close c;
	return -1;

END bus_unit_id;

END EDW_UTIL;


/
