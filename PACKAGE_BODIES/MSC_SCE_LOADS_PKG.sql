--------------------------------------------------------
--  DDL for Package Body MSC_SCE_LOADS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCE_LOADS_PKG" AS
/* $Header: MSCXLDB.pls 120.20.12010000.2 2008/05/07 09:59:16 hbinjola ship $ */

  G_DAY_DESC               varchar2(80);
  G_USER_IS_ADMIN          number;
  SYS_YES         CONSTANT number := 1;
  SYS_NO          CONSTANT number := 2;

  G_OVERWRITE_OF  varchar2(1) := nvl(fnd_profile.value('MSC_X_OVERWRITE_OF'),'N');
  G_MSC_CP_DEBUG  VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
   --Consigned CVMI Enh : Bug # 4562914
  G_CVMI_PROFILE  VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('MSC_X_CVMI_CA_MAND'), 'N') ;

PROCEDURE get_user_id (
  p_int_control_number IN NUMBER,
  p_user_id OUT NOCOPY NUMBER
) IS
BEGIN
   SELECT usr.user_id
     INTO p_user_id
     FROM fnd_user usr,
     ecx_doclogs ecx
     WHERE usr.user_name = upper(ecx.username)
     AND ecx.internal_control_number = p_int_control_number;
EXCEPTION
   WHEN OTHERS THEN
      p_user_id := -1;
END get_user_id;

-- This procesure prints out debug information
PROCEDURE LOG_DEBUG(
    p_debug_info IN VARCHAR2
  )IS
  BEGIN
    IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
    END IF;
     --dbms_output.put_line(p_debug_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END LOG_DEBUG;

Function is_user_admin( pUSER_ID   in  number)
return number
IS
lv_admin     number;
BEGIN

    select 1
      into lv_admin
      from fnd_user_resp_groups  furg,
           fnd_responsibility_vl  frv
     where furg.USER_ID = pUSER_ID
       and frv.RESPONSIBILITY_NAME like '%Supply Chain Collaboration Administrator%'
       and frv.APPLICATION_ID = 724
       and frv.APPLICATION_ID = furg.RESPONSIBILITY_APPLICATION_ID
       and frv.RESPONSIBILITY_ID = furg.RESPONSIBILITY_ID
       and trunc(nvl(furg.end_date,sysdate)) >= trunc(sysdate)
       and rownum = 1;

       return lv_admin;

EXCEPTION
  when others then
     return SYS_NO;
END is_user_admin;

PROCEDURE update_errors (
  p_header_id IN NUMBER,
  p_language  IN VARCHAR2,
  p_build_err IN NUMBER,
  p_date_format IN VARCHAR2
  , p_consumption_advice_exists OUT NOCOPY BOOLEAN -- bug 3551850
) IS
   l_err_msg                  VARCHAR2(2000);
   l_row_status               NUMBER;
  l_posting_party            VARCHAR2(255);
  l_min                      NUMBER;
  l_max                      NUMBER;
  l_loops_reqd               NUMBER;
  l_start_line               NUMBER;
  l_end_line                 NUMBER;
  l_log_message              VARCHAR2(4000);
  t_line_id                  lineidList;
  t_line_id1                 lineidList;
  t_order_type               lineidList;
  t_err_line_id              lineidList;
  t_log_line_id              lineidList;
  t_log_item_name            itemList;
  t_log_order_type           otdescList;
  t_log_err_msg              errmsgList;

  t_pub                      publisherList;
  t_pub_site                 pubsiteList;
  t_cust                     customerList;
  t_cust_site                custsiteList;
  t_supp                     supplierList;
  t_supp_site                suppsiteList;
  t_order_type_desc          otdescList;
  t_key_date                 keydateList;
  t_bucket_type              bktypeList;
  t_item_id                  numlist;
  t_order_number             ordernumlist;
  t_rel_number               relnumlist;
  t_line_number              linenumlist;
  t_end_order_number         endordlist;
  t_end_order_rel_number     endrellist;
  t_end_order_line_number    endlinelist;
  t_tmp_line_id              lineidlist;
  t_tmp_ot                   lineidlist;

  t_del_pub_id               numlist;
  t_del_pub_site_id          numlist;
  t_del_cust_id              numlist;
  t_del_cust_site_id         numlist;
  t_del_item_id              numlist;
  t_del_supp_id              numlist;
  t_del_supp_site_id         numlist;

  CURSOR c_dates (
    p_header_id IN NUMBER,
    p_start_line IN NUMBER,
    p_end_line IN NUMBER,
    p_date_format IN VARCHAR2
  ) IS
     SELECT l.line_id
       FROM   msc_supdem_lines_interface l
       WHERE  l.parent_header_id = p_header_id
       AND    l.line_id BETWEEN p_start_line AND p_end_line
       AND    NVL(l.row_status, G_PROCESS) = G_PROCESS
       AND    checkdates(p_header_id,l.line_id,p_date_format) = 1;

  CURSOR c_err_msg(
    p_header_id  IN Number,
    p_start_line IN Number,
    p_end_line   IN Number
  ) IS
     select line_id,
       nvl(item_name,
	   nvl(owner_item_name,
	       nvl(customer_item_name,
		   supplier_item_name))),
       substrb(order_type,1,80) ,
       err_msg
       from   msc_supdem_lines_interface
       where  parent_header_id = p_header_id and
       line_id between p_start_line and p_end_line and
       row_status = 4;

  cursor c_exec_keys
    (
     p_header_id number,
     p_language varchar2
     ) is
	select distinct upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id,
	  ln.order_identifier,
	  ln.release_number,
	  ln.line_number,
	  ln.pegging_order_identifier,
	  ln.ref_release_number,
	  ln.ref_line_number
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_PURCHASE_ORDER,
				  G_SALES_ORDER,
				  G_ASN,
				  G_SHIP_RECEIPT,
				  G_REQUISITION,
				  G_PO_ACKNOWLEDGEMENT)
	  and upper(ln.sync_indicator) = 'R';

  cursor c_onhand_keys
    (
     p_header_id number,
     p_language varchar2
     ) is
	select distinct upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_ALLOC_ONHAND, g_unallocated_onhand)
	  and upper(ln.sync_indicator) = 'R';

  CURSOR c_work_order_keys
    (
     p_header_id NUMBER,
     p_language VARCHAR2
     ) IS
        SELECT DISTINCT Upper(ln.publisher_company),
          Upper(ln.publisher_site),
          Upper(ln.customer_company),
          Upper(ln.customer_site),
          Upper(ln.order_type),
          ln.inventory_item_id,
          ln.order_identifier
          FROM msc_supdem_lines_interface ln,
          fnd_lookup_values flv
          WHERE ln.parent_header_id = p_header_id
          and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
          and flv.language = p_language
          and flv.lookup_type = 'MSC_X_ORDER_TYPE'
          and upper(flv.meaning) = upper(ln.order_type)
          and flv.lookup_code = g_work_order
          and upper(ln.sync_indicator) = 'R';

  cursor c_daily_keys
    (
     p_header_id number,
     p_language varchar2,
     p_date_format VARCHAR2
     ) is
	select upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id,
	  trunc(to_date(ln.key_date,p_date_format)),
	  upper(ln.bucket_type)
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv,
	  fnd_lookup_values flv1
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_SALES_FORECAST,
				  G_ORDER_FORECAST,
				  G_SUPPLY_COMMIT,
				  G_HIST_SALES,
				  G_SELL_THRO_FCST,
				  G_SUPPLIER_CAP,
				  G_SAFETY_STOCK,
				  G_INTRANSIT,
				  g_replenishment,
				  g_proj_avai_bal)
	  and flv1.language = flv.language
	  and flv1.lookup_type = 'MSC_X_BUCKET_TYPE'
	  and flv1.lookup_code = G_DAY
	  and upper(flv1.meaning) = upper(ln.bucket_type)
	  and upper(ln.sync_indicator) = 'R'
	  union
	  select upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id,
	  trunc(to_date(ln.key_date,p_date_format)),
	  upper(ln.bucket_type)
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_SALES_FORECAST,
				  G_ORDER_FORECAST,
				  G_SUPPLY_COMMIT,
				  G_HIST_SALES,
				  G_SELL_THRO_FCST,
				  G_SUPPLIER_CAP,
				  G_SAFETY_STOCK,
				  G_INTRANSIT,
				  g_replenishment,
				  g_proj_avai_bal)
	  and ln.bucket_type is null
	  and upper(ln.sync_indicator) = 'R';

  cursor c_weekly_keys
    (
     p_header_id number,
     p_language varchar2,
     p_date_format VARCHAR2
     ) is
	select upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id,
	  trunc(to_date(ln.key_date,p_date_format)),
	  upper(ln.bucket_type)
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv,
	  fnd_lookup_values flv1
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_SALES_FORECAST,
				  G_ORDER_FORECAST,
				  G_SUPPLY_COMMIT,
				  G_HIST_SALES,
				  G_SELL_THRO_FCST,
				  G_SUPPLIER_CAP,
				  G_SAFETY_STOCK,
				  G_INTRANSIT,
				  g_replenishment,
				  g_proj_avai_bal)
	  and flv1.language = flv.language
	  and flv1.lookup_type = 'MSC_X_BUCKET_TYPE'
	  and flv1.lookup_code = G_WEEK
	  and upper(flv1.meaning) = upper(ln.bucket_type)
	  and upper(ln.sync_indicator) = 'R';

  cursor c_monthly_keys
    (
     p_header_id number,
     p_language varchar2,
     p_date_format VARCHAR2
     ) is
	select upper(ln.publisher_company),
	  upper(ln.publisher_site),
	  upper(ln.customer_company),
	  upper(ln.customer_site),
	  upper(ln.supplier_company),
	  upper(ln.supplier_site),
	  upper(ln.order_type),
	  ln.inventory_item_id,
	  trunc(to_date(ln.key_date,p_date_format)),
	  upper(ln.bucket_type)
	  from msc_supdem_lines_interface ln,
	  fnd_lookup_values flv,
	  fnd_lookup_values flv1
	  where ln.parent_header_id = p_header_id
	  and nvl(ln.row_status, G_PROCESS) = G_SUCCESS
	  and flv.language = p_language
	  and flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  and upper(flv.meaning) = upper(ln.order_type)
	  and flv.lookup_code in (G_SALES_FORECAST,
				  G_ORDER_FORECAST,
				  G_SUPPLY_COMMIT,
				  G_HIST_SALES,
				  G_SELL_THRO_FCST,
				  G_SUPPLIER_CAP,
				  G_SAFETY_STOCK,
				  G_INTRANSIT,
				  g_replenishment,
				  g_proj_avai_bal)
	  and flv1.language = flv.language
	  and flv1.lookup_type = 'MSC_X_BUCKET_TYPE'
	  and flv1.lookup_code = G_MONTH
	  and upper(flv1.meaning) = upper(ln.bucket_type)
	  and upper(ln.sync_indicator) = 'R';

   CURSOR key_dates(p_header_id IN number,
		    p_start_line IN number,
		    p_end_line IN number,
		    p_language IN varchar2)
     IS
	SELECT ln.line_id, flv.lookup_code
	  FROM msc_supdem_lines_interface ln
	       , fnd_lookup_values flv
	  WHERE ln.parent_header_id = p_header_id
	  AND   ln.line_id BETWEEN p_start_line AND p_end_line
	  AND   Nvl(ln.row_status, g_process) = g_process
	  AND   flv.lookup_type = 'MSC_X_ORDER_TYPE'
	  AND   flv.language = p_language
	  AND   Upper(flv.meaning) = Upper(ln.order_type);

   --Added for bug 3103879
  CURSOR c_delete_supply_commit (
    p_header_id IN NUMBER,
    p_language IN VARCHAR2
  ) IS
  SELECT DISTINCT c.company_id,
    cs.company_site_id,
    c1.company_id,
    cs1.company_site_id,
    ln.inventory_item_id
    FROM msc_companies c,
    msc_company_sites cs,
    msc_companies c1,
    msc_company_sites cs1,
    fnd_lookup_values flv,
    msc_supdem_lines_interface ln
    WHERE ln.parent_header_id = p_header_id
    AND ln.row_status = G_SUCCESS
    AND Upper(c.company_name) = Upper(ln.publisher_company)
    AND c.company_id = cs.company_id
    AND Upper(cs.company_site_name) = Upper(ln.publisher_site)
    AND Upper(c1.company_name) = Upper(ln.customer_company)
    AND c1.company_id = cs1.company_id
    AND Upper(cs1.company_site_name) = Upper(ln.customer_site)
    AND flv.lookup_type = 'MSC_X_ORDER_TYPE'
    AND Upper(flv.meaning) = Upper(ln.order_type)
    AND flv.language = p_language
    AND flv.lookup_code = g_supply_commit;

   --Added for bug 3304493
  CURSOR c_delete_order_forecast (
    p_header_id IN NUMBER,
    p_language IN VARCHAR2
  ) IS
  SELECT DISTINCT c.company_id,
                  cs.company_site_id,
                  c1.company_id,
                  cs1.company_site_id,
                  ln.inventory_item_id
   FROM msc_companies c,
        msc_company_sites cs,
        msc_companies c1,
        msc_company_sites cs1,
        fnd_lookup_values flv,
        msc_supdem_lines_interface ln
  WHERE ln.parent_header_id = p_header_id
    AND ln.row_status = G_SUCCESS
    AND Upper(c.company_name) = Upper(ln.publisher_company)
    AND c.company_id = cs.company_id
    AND Upper(cs.company_site_name) = Upper(ln.publisher_site)
    AND Upper(c1.company_name) = Upper(ln.supplier_company)
    AND c1.company_id = cs1.company_id
    AND Upper(cs1.company_site_name) = Upper(ln.supplier_site)
    AND flv.lookup_type = 'MSC_X_ORDER_TYPE'
    AND Upper(flv.meaning) = Upper(ln.order_type)
    AND flv.language = p_language
    AND flv.lookup_code = G_ORDER_FORECAST;

  calendar_is_not_seeded number;

BEGIN
/* BEGIN
      select 1 into calendar_is_not_seeded
	from dual
	where exists ( select 'exists'
		       from msc_calendar_dates
		       where calendar_code = 'CP-Mon-70'
		       and exception_set_id = -1
		       and sr_instance_id = 0 );
   EXCEPTION
      WHEN OTHERS THEN
	 calendar_is_not_seeded := 0;
   END;

   if calendar_is_not_seeded = 0 then
      begin
	 select min(line_id) into l_min
	   from msc_supdem_lines_interface
	   where parent_header_id = p_header_id;
      exception
	 when others then
	    return;
      end;

      l_err_msg := get_message('MSC', 'MSC_X_CALENDAR_NOT_SEEDED', p_language);

      update msc_supdem_lines_interface
	set row_status = 4,
        err_msg = substrb(l_err_msg,1,1000)
	where parent_header_id = p_header_id
	and line_id = l_min;

      update msc_supdem_lines_interface
	set row_status = 1
	where parent_header_id = p_header_id
	and line_id <> l_min;

   end if; */

    p_consumption_advice_exists := FALSE; -- bug 3551850

   BEGIN
      SELECT min(line_id), max(line_id)
	INTO   l_min, l_max
	FROM   msc_supdem_lines_interface
	WHERE  parent_header_id = p_header_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 return;
   END;

   IF l_min IS NULL OR l_max IS NULL THEN
     RETURN;
   END IF;

   l_loops_reqd := 1 + trunc((l_max - l_min)/G_BATCH_SIZE);

   FOR i IN 1..l_loops_reqd LOOP
      l_start_line := l_min + ((i-1)*G_BATCH_SIZE);
      IF ((l_min -1 + i*G_BATCH_SIZE) <= l_max) THEN
	 l_end_line := l_min -1 + i*G_BATCH_SIZE;
       ELSE
	 l_end_line := l_max;
      END IF;


      --=========================================================================
      -- select and validate the order type first
      --=========================================================================

      SELECT line_id
	BULK COLLECT INTO t_line_id
	FROM   msc_supdem_lines_interface
	WHERE  parent_header_id = p_header_id AND
	line_id BETWEEN l_start_line and l_end_line;


      IF t_line_id IS NOT NULL AND t_line_id.COUNT > 0 THEN
	 --======================================================================
	 -- Validation: Check if order type is valid
	 --======================================================================


	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_ORDER_TYPE', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	   NOT EXISTS (SELECT l.lookup_code
		       FROM   fnd_lookup_values l
		       WHERE  l.lookup_type = 'MSC_X_ORDER_TYPE' AND
		       UPPER(l.meaning) = NVL(UPPER(ln.order_type), G_NULL_STRING) AND
		       l.language = p_language);

      END IF;

      --====================================================================================

      	SELECT flv.lookup_code,
	       ln.line_id
	BULK COLLECT into t_order_type, t_line_id
	FROM fnd_lookup_values flv,
	     msc_supdem_lines_interface ln
	WHERE flv.lookup_type = 'MSC_X_ORDER_TYPE' and
	      flv.language = p_language and
	      Upper(flv.meaning(+)) = Upper(ln.order_type) and
	      nvl(ln.row_status, G_PROCESS) = G_PROCESS and
	      ln.parent_header_id = p_header_id and
	      ln.line_id between l_start_line and l_end_line;

      l_log_message := substrb(get_message('MSC','MSC_X_API_NOW_PROCESSING',p_language),1,500)
	|| '... ' || to_char(l_start_line - l_min + 1) || ' ' ||
	substrb(get_message('MSC','MSC_X_API_THROUGH',p_language),1,40) ||
	' ' || to_char(l_end_line -l_min + 1);

      log_message(l_log_message);

      IF t_line_id IS NOT NULL AND t_line_id.COUNT > 0 THEN
	 --=============================================================
	 -- Independent Errors for sync indicator 'R' and 'D'
	 --
	 -- Validation: Check if the posting party exists
	 --=======================================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_POSTING_PARTY', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	   NOT EXISTS (SELECT c.company_id
		       FROM msc_companies c
 		       WHERE UPPER(c.company_name) = UPPER(NVL(ln.posting_party_name, G_NULL_STRING)));

	 --=======================================================================
	 -- Validation: Check if the sync indicator is valid
	 --=======================================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_SYNC_INDICATOR', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	   UPPER(NVL(ln.sync_indicator, G_NULL_STRING)) NOT IN ('R','D');

	 --======================================================================
	 -- Validation: Check if atleast one item is provided in the flat-
	 -- file or XML document.
	 --======================================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_NO_ITEM', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   update msc_supdem_lines_interface ln
	   set    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   where ln.parent_header_id = p_header_id and
	   ln.line_id = t_line_id(j) and
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS and
	   ln.item_name is NULL and
	   ln.owner_item_name is NULL and
	   ln.supplier_item_name is NULL and
	   ln.customer_item_name is NULL;

	 --======================================================================
	 -- Validation: Check if order type is valid
	 --======================================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_ORDER_TYPE', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	   t_order_type(j) is NULL;

--	   NOT EXISTS (SELECT l.lookup_code
--		       FROM   fnd_lookup_values l
--		       WHERE  l.lookup_type = 'MSC_X_ORDER_TYPE' AND
--		       UPPER(l.meaning) = NVL(UPPER(ln.order_type), G_NULL_STRING) AND
--		       l.language = p_language);

    -- added the following code for bug 3551580
	 FOR j IN t_line_id.FIRST..t_line_id.LAST LOOP
       IF (t_order_type(j) = G_CONS_ADVICE AND ( NOT p_consumption_advice_exists)) THEN
         p_consumption_advice_exists := TRUE;
	   END IF;
     END LOOP;

	log_debug('Validated order type');
	log_debug('Profile :MSC: Order Number-CA Mandatory for CVMI = '||G_CVMI_PROFILE);
	--- Consigned CVMI Enhancements : Bug # 4247230
      --================================================================================
	/* ADD  Validation: Check if Order Number is provided if profile option :
	 MSC: Order Number-CA Mandatory for CVMI is set to YES */
      --================================================================================

   IF (Nvl(fnd_profile.value('MSC_X_CVMI_CA_MAND'),'N') = 'Y') THEN

       log_debug('Order number is Mandatory for Consumption Advice');
	l_err_msg := get_message('MSC', 'MSC_X_INVALID_ORDER_NUMBER', p_language);

	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	   ln.order_identifier is NULL AND
	   t_order_type(j) = G_CONS_ADVICE ;

      log_debug('Validated order number');
   END IF;

	 --=======================================================================
	 -- Validation: Check if publisher company exists
	 --=======================================================================
	 IF p_build_err = 1 THEN
	    l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER', p_language);
	      FORALL j IN t_line_id.FIRST..t_line_id.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	      WHERE ln.parent_header_id = p_header_id AND
	      ln.line_id = t_line_id(j) AND
	      NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	      ln.publisher_company IS NOT NULL AND
	      NOT EXISTS (SELECT c.company_id
			  FROM msc_companies c
			  WHERE UPPER(c.company_name) = UPPER(ln.publisher_company));

	 --=============================================================================
	 -- Validate the company to be consistent if more than two feild has been given
	 --=============================================================================
	    l_err_msg := get_message('MSC', 'MSC_X_PUBLISH_UNMATCH', p_language); --change for export start
	      FORALL j IN t_line_id.FIRST..t_line_id.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	      WHERE  ln.parent_header_id = p_header_id AND
	      ln.line_id = t_line_id(j) AND
	      NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	      ln.publisher_company <> NVL(DECODE(t_order_type(j),G_REQUISITION,ln.customer_company,
	       					       G_ORDER_FORECAST,ln.customer_company,
	      		     G_HIST_SALES,ln.posting_party_name,
	       					       G_SELL_THRO_FCST,ln.posting_party_name,
	       					       G_ALLOC_ONHAND,ln.customer_company,
	       					       G_PURCHASE_ORDER,ln.customer_company,
	       					       G_SHIP_RECEIPT,ln.customer_company,
	       					       G_SUPPLY_COMMIT,ln.supplier_company,
	       					       G_SUPPLIER_CAP,ln.supplier_company,
	       					       G_SAFETY_STOCK,ln.supplier_company,
	       					       G_SALES_ORDER,ln.supplier_company,
	       					       G_ASN,ln.supplier_company,
	       					       G_WORK_ORDER,ln.supplier_company,
	       					       G_REPLENISHMENT,ln.supplier_company,
	       					       G_PO_ACKNOWLEDGEMENT,ln.supplier_company,
	       					       G_SALES_FORECAST,ln.posting_party_name,
	       					       G_UNALLOCATED_ONHAND,nvl(customer_company, supplier_company),
       G_CONS_ADVICE, nvl(customer_company, supplier_company)
	       					 ),publisher_company);
						/* sbala Add CA */


         --=============================================================================
         -- Validate the company sites to be consistent if more than two feild has been given
         --=============================================================================
            l_err_msg := get_message('MSC', 'MSC_X_PUBLISH_SITE_UNMATCH', p_language);
              FORALL j IN t_line_id.FIRST..t_line_id.LAST
              UPDATE msc_supdem_lines_interface ln
              SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
              WHERE  ln.parent_header_id = p_header_id AND
	      ln.line_id = t_line_id(j) AND
	      NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	      ln.publisher_site <> NVL(DECODE(t_order_type(j),G_REQUISITION,ln.customer_site,
	      					       G_ORDER_FORECAST,ln.customer_site,
	    	       G_HIST_SALES,  decode(posting_party_name,customer_company,customer_site,supplier_company,supplier_site,null),
	      					       G_SELL_THRO_FCST,decode(posting_party_name,customer_company,customer_site,supplier_company,supplier_site,null),
	      					       G_ALLOC_ONHAND,ln.customer_site,
	       					       G_PURCHASE_ORDER,ln.customer_site,
	       					       G_SHIP_RECEIPT,ln.customer_site,
	       					       G_SUPPLY_COMMIT,ln.supplier_site,
	       					       G_SUPPLIER_CAP,ln.supplier_site,
	       					       G_SAFETY_STOCK,ln.supplier_site,
	       					       G_SALES_ORDER,ln.supplier_site,
	       					       G_ASN,ln.supplier_site,
	       					       G_WORK_ORDER,ln.supplier_site,
	       					       G_REPLENISHMENT,ln.supplier_site,
	       					       G_PO_ACKNOWLEDGEMENT,ln.supplier_site,
	       					       G_SALES_FORECAST, decode(posting_party_name,customer_company,customer_site,supplier_company,supplier_site,null),
	       					       G_UNALLOCATED_ONHAND,nvl(customer_site, supplier_site),
             G_CONS_ADVICE, nvl(customer_site, supplier_site)
	       					 ),publisher_site);

						/* sbala add CA */
	--==============================================================================
	-- Populate the Publisher Information
	--============================================================================
	      FORALL j IN t_line_id.FIRST..t_line_id.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.publisher_company = NVL(decode(t_order_type(j),
              			                        G_SALES_FORECAST, ln.posting_party_name,
                                		        G_ORDER_FORECAST, ln.customer_company,
                                        	        G_SUPPLY_COMMIT, ln.supplier_company,
                                		G_HIST_SALES, ln.posting_party_name,
                                        		G_SELL_THRO_FCST, ln.posting_party_name,
                                        		G_SUPPLIER_CAP, ln.supplier_company,
                                        		G_SAFETY_STOCK, ln.supplier_company,
                                        		G_ALLOC_ONHAND, ln.customer_company,
                                        		G_UNALLOCATED_ONHAND,
                                           		nvl(ln.customer_company, ln.supplier_company),
                                        		G_PURCHASE_ORDER, ln.customer_company,
                                        		G_SALES_ORDER, ln.supplier_company,
                                        		G_ASN, ln.supplier_company,
                                        		G_SHIP_RECEIPT, ln.customer_company,
                                        		G_REPLENISHMENT, ln.supplier_company,
                                        		G_REQUISITION, ln.customer_company,
	                                		G_PO_ACKNOWLEDGEMENT, ln.supplier_company,
                                        		G_WORK_ORDER, ln.supplier_company),ln.publisher_company),
	             					ln.publisher_site = NVL(decode(t_order_type(j),
                                        		G_SALES_FORECAST,
                                           		decode(ln.posting_party_name,
                                                  		ln.customer_company,
                                                  		ln.customer_site,
                                                  		ln.supplier_company,
                                                  		ln.supplier_site,
                                                  		null),
                                        		G_ORDER_FORECAST, ln.customer_site,
                                        		G_SUPPLY_COMMIT, ln.supplier_site,
                                        		G_HIST_SALES,
					decode(ln.posting_party_name,
                                		ln.customer_company,
                                       		ln.customer_site,
                                       		ln.supplier_company,
                                            		ln.supplier_site,
                                           		null),

                                        		G_SELL_THRO_FCST,
                                        		        decode(ln.posting_party_name,
                                                                  ln.customer_company,
                                                                  ln.customer_site,
                                                                  ln.supplier_company,
                                                                  ln.supplier_site,
                                                                  null),
                                        		G_SUPPLIER_CAP, ln.supplier_site,
                                        		G_SAFETY_STOCK, ln.supplier_site,
                                        		G_ALLOC_ONHAND, ln.customer_site,
                                        		G_UNALLOCATED_ONHAND,
                                           		nvl(ln.customer_site, ln.supplier_site),
                                        		G_PURCHASE_ORDER, ln.customer_site,
                                        		G_SALES_ORDER, ln.supplier_site,
                                        		G_ASN, ln.supplier_site,
                                        		G_SHIP_RECEIPT, ln.customer_site,
                                        		G_REPLENISHMENT, ln.supplier_site,
                                        		G_REQUISITION, ln.customer_site,
	                                		G_PO_ACKNOWLEDGEMENT, ln.supplier_site,
                                        		G_WORK_ORDER, ln.supplier_site,
G_CONS_ADVICE, nvl(ln.customer_site,
                  ln.supplier_site)),
			ln.publisher_site)
	      WHERE  ln.parent_header_id = p_header_id AND
	             ln.line_id = t_line_id(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                     ln.publisher_company IS NOT NULL AND
                     ln.publisher_site IS NOT NULL;

	      --======================================================================
	      -- Validation: Check if Posting Party is one of the Trading partners
              -- added for bug # 2565412
	      --======================================================================
	     if (G_USER_IS_ADMIN <> SYS_YES) then
		/* only for users who do not have SC Admin Responsibility */
		l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER', p_language);
	        FORALL j IN t_line_id.FIRST..t_line_id.LAST
		  UPDATE msc_supdem_lines_interface ln
		  SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000),
			 ln.row_status = G_FAILURE
		  WHERE  ln.parent_header_id = p_header_id AND
			 ln.line_id = t_line_id(j) AND
			 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
			 not exists ( select 1
			                    from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.supplier_company,G_NULL_STRING))
				    union select 1
				            from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.customer_company,G_NULL_STRING))
				    union select 1
				            from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.publisher_company,G_NULL_STRING))
					   );
	     end if;

                    /* sbala ADD CA */

      --=============================================================================
      -- Remove the extra Columns . Added for export/import
      --=============================================================================
	     FORALL j IN t_line_id.FIRST..t_line_id.LAST
	     UPDATE msc_supdem_lines_interface ln
	     SET ln.customer_company = DECODE(t_order_type(j),
                                       G_SALES_FORECAST,
                                           DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_ORDER_FORECAST, null,
                                        G_HIST_SALES,
						DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_SELL_THRO_FCST,
						DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_ALLOC_ONHAND, null,
                                        G_UNALLOCATED_ONHAND, null,
                                        G_PURCHASE_ORDER, null,
                                        G_SHIP_RECEIPT, null,
                                        G_REQUISITION, null,
					G_SAFETY_STOCK, null,
					g_proj_avai_bal, NULL,
                                        ln.customer_company),
                   ln.customer_site = DECODE(t_order_type(j),
                                        G_SALES_FORECAST,
                                           DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_ORDER_FORECAST, null,
                                        G_HIST_SALES,
						DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_SELL_THRO_FCST,
						DECODE(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_ALLOC_ONHAND, null,
                                        G_UNALLOCATED_ONHAND, null,
					G_CONS_ADVICE, null,
                                        G_PURCHASE_ORDER, null,
                                        G_SHIP_RECEIPT, null,
                                        G_REQUISITION, null,
					G_SAFETY_STOCK, null,
					g_proj_avai_bal, NULL,
                                        ln.customer_site),
                   ln.supplier_company = DECODE(t_order_type(j),
                                        G_SALES_FORECAST,
                                          DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
					G_HIST_SALES,
						DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
					G_SELL_THRO_FCST,
						DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
                                        G_SUPPLY_COMMIT, null,
                                        G_SUPPLIER_CAP, null,
                                        G_SAFETY_STOCK, null,
					g_proj_avai_bal, NULL,
                                        G_UNALLOCATED_ONHAND, null,
				        G_CONS_ADVICE, null,
                                        G_SALES_ORDER, null,
                                        G_ASN, null,
                                        G_REPLENISHMENT, null,
					G_PO_ACKNOWLEDGEMENT, null,
					/* Added for work order support */
					G_WORK_ORDER, NULL,
                                        ln.supplier_company),
                   ln.supplier_site = DECODE(t_order_type(j),
                                        G_SALES_FORECAST,
                                          DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
					G_HIST_SALES,
					  DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
					G_SELL_THRO_FCST,
					  DECODE(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
                                        G_SUPPLY_COMMIT, null,
                                        G_SUPPLIER_CAP, null,
                                        G_SAFETY_STOCK, null,
					g_proj_avai_bal, NULL,
                                        G_UNALLOCATED_ONHAND, null,
				        G_CONS_ADVICE, null,
                                        G_SALES_ORDER, null,
                                        G_ASN, null,
                                        G_REPLENISHMENT, null,
					G_PO_ACKNOWLEDGEMENT, null,
					/* Added for work order support */
					G_WORK_ORDER, NULL,
					G_CONS_ADVICE, NULL,
                                        ln.supplier_site)
	     WHERE ln.parent_header_id = p_header_id AND
	           ln.line_id = t_line_id(j) AND
	           NVL(ln.row_status, G_PROCESS) = G_PROCESS  AND
                   ln.publisher_company IS NOT NULL AND
                   ln.publisher_site IS NOT NULL;
      END IF; --change for export end

	/* sbala ADD CA */
      --======================================================================
      -- Validation: Check if bucket type is valid
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_BUCKET_TYPE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.bucket_type IS NOT NULL AND
               NOT EXISTS (SELECT l.lookup_code
                           FROM   fnd_lookup_values l
                           WHERE  l.lookup_type = 'MSC_X_BUCKET_TYPE' AND
                                  UPPER(l.meaning) = NVL(UPPER(ln.bucket_type),
                                                         G_NULL_STRING) AND
		 	          l.language = p_language);

      --======================================================================
      -- Validation: Check if date formats are valid
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_DATE_FORMAT', p_language);

      OPEN c_dates(p_header_id, l_start_line, l_end_line,p_date_format);
      FETCH c_dates BULK COLLECT INTO t_err_line_id;
      CLOSE c_dates;

      IF t_err_line_id IS NOT NULL AND t_err_line_id.COUNT > 0 THEN
        FORALL j in t_err_line_id.FIRST..t_err_line_id.LAST
          UPDATE msc_supdem_lines_interface ln
          SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
          WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_err_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS;
      END IF;


      --=======================================================================
      -- End of independent errors for sync indicator D
      -- Set row status = G_FAILURE for records with sync indicator 'D'
      -- where err_msg is not null
      --=======================================================================
      forall j IN t_line_id.first..t_line_id.last
	UPDATE msc_supdem_lines_interface ln
	SET ln.row_status = g_failure
	WHERE ln.err_msg IS NOT NULL
	  AND Upper(ln.sync_indicator) = 'D'
	  AND ln.parent_header_id = p_header_id
	  AND ln.line_id = t_line_id(j);

      --=======================================================================
      -- Dependent validations for sync indicator D
      --
      --Validation: Item check for records with sync indicator 'D'
      --========================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_ITEM', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
	update msc_supdem_lines_interface ln
	set    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	where  ln.parent_header_id = p_header_id and
	       ln.line_id = t_line_id(j) and
	       NVL(ln.row_status, G_PROCESS) = G_PROCESS and
	       ln.sync_indicator = 'D' and
	       not exists (select i.inventory_item_id
		  	   from   msc_items i
			   where  i.item_name = ln.item_name
			   UNION
			   select msi.inventory_item_id
			   from   msc_system_items msi
			   where  msi.item_name = NVL(ln.owner_item_name,
                                                      NVL(ln.customer_item_name,
                                                           ln.supplier_item_name)) and
                                  msi.plan_id = -1
			   UNION
			   select mis.inventory_item_id
			   from   msc_item_suppliers mis
			   where  mis.supplier_item_name = NVL(ln.owner_item_name,
                                                             NVL(ln.customer_item_name,
                                                               ln.supplier_item_name)) and
                                  mis.plan_id = -1
			   UNION
			   select mic.inventory_item_id
			   from   msc_item_customers mic
			   where  mic.customer_item_name = NVL(ln.owner_item_name,
                                                             NVL(ln.customer_item_name,
                                                               ln.supplier_item_name)) and
	                          mic.plan_id = -1 );

      --======================================================================
      -- Validation: Check if publisher site exists
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER_SITE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
	       ln.line_id = t_line_id(j) AND
	       Upper(ln.sync_indicator) = 'D' AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               NOT EXISTS (SELECT cs.company_site_id
                         FROM   msc_company_sites cs,
                                msc_companies c
                         WHERE  UPPER(c.company_name) = UPPER(ln.publisher_company) AND
                                c.company_id = cs.company_id AND
			        UPPER(cs.company_site_name) = UPPER(ln.publisher_site));

      --========================================================
      -- Validation: Check if customer company exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_CUSTOMER', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               Upper(ln.sync_indicator) = 'D' AND
	       NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.customer_company IS NOT NULL AND
               NOT EXISTS (SELECT c.company_id
			   FROM   msc_companies c,
                                    msc_companies c1,
                                    msc_company_relationships r
                             WHERE  UPPER(c.company_name) = UPPER(ln.customer_company) and
                                    UPPER(c1.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
                                    r.subject_id = c1.company_id and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 1);

      --========================================================
      -- Validation: Check if customer site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_CUST_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
	       ln.line_id = t_line_id(j) AND
	       Upper(ln.sync_indicator) = 'D' AND
                 NVL(ln.row_status, G_PROCESS)  = G_PROCESS AND
                 ln.customer_company IS NOT NULL AND
                 NOT EXISTS (SELECT cs.company_site_id
                             FROM   msc_company_sites cs,
                                    msc_companies c
                             WHERE  UPPER(c.company_name) = UPPER(ln.customer_company) AND
                                    c.company_id = cs.company_id AND
                                    UPPER(cs.company_site_name) = UPPER(NVL(ln.customer_site,
                                                                        G_NULL_STRING)));

      --========================================================
      -- Validation: Check if supplier company exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SUPPLIER', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
	       ln.line_id = t_line_id(j) AND
	       Upper(ln.sync_indicator) = 'D' AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 ln.supplier_company IS NOT NULL AND
                 NOT EXISTS (SELECT c.company_id
                             FROM   msc_companies c,
                                    msc_companies c1,
                                    msc_company_relationships r
                             WHERE  UPPER(c.company_name) = UPPER(ln.supplier_company) and
                                    UPPER(c1.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
                                    r.subject_id = c1.company_id and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 2);

      --========================================================
      -- Validation: Check if supplier site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SUPP_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
	       ln.line_id = t_line_id(j) AND
	       Upper(ln.sync_indicator) = 'D' AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.supplier_company IS NOT NULL AND
               NOT EXISTS (SELECT cs.company_site_id
                           FROM   msc_company_sites cs,
                                  msc_companies c
                           WHERE  UPPER(c.company_name) = UPPER(ln.supplier_company) AND
                                  c.company_id = cs.company_id AND
                                  UPPER(cs.company_site_name) = UPPER(NVL(ln.supplier_site,
                                                                      G_NULL_STRING)));

      --============================================================================
      -- Populate the Key Date. This is required for c_delete in PROCEDURE validate
      -- Verify that the bucket end date is greater than the key date.
      --============================================================================
      OPEN key_dates(p_header_id, l_start_line, l_end_line, p_language);
      FETCH key_dates bulk collect INTO t_tmp_line_id, t_tmp_ot;
      CLOSE key_dates;

      IF t_tmp_line_id IS NOT NULL AND t_tmp_line_id.COUNT > 0 THEN
	 forall j IN t_tmp_line_id.first..t_tmp_line_id.last

            UPDATE msc_supdem_lines_interface ln
           SET    ln.key_date = Decode(t_tmp_ot(j),
                                      G_WORK_ORDER,ln.wip_end_date,
                                      G_PURCHASE_ORDER,  -- jguo
                                          DECODE(ln.shipping_control,
                                                  1, ln.receipt_date,
                                          2, ln.ship_date,
                                          ln.receipt_date),
                                      G_SHIP_RECEIPT, ln.receipt_date,
                                      G_ORDER_FORECAST,-- jguo
                                          DECODE(ln.shipping_control,
                                                  1, ln.receipt_date,
                                          2, ln.ship_date,
                                          ln.receipt_date),
                                      G_REQUISITION, -- jguo
                                          DECODE(ln.shipping_control,
                                                  1, ln.receipt_date,
                                          2, ln.ship_date,
                                          ln.receipt_date),
                                      G_SELL_THRO_FCST, ln.ship_date,
                                      G_SUPPLIER_CAP, ln.ship_date,
                                      G_HIST_SALES, ln.new_schedule_date,
                                      G_SAFETY_STOCK, ln.new_schedule_date,
                                      G_ALLOC_ONHAND, ln.new_schedule_date,
                                       G_UNALLOCATED_ONHAND, ln.new_schedule_date,
                                       g_safety_stock, ln.new_schedule_date,
                                       g_proj_avai_bal, ln.new_schedule_date,
                                       G_CONS_ADVICE, ln.new_schedule_date,
                                      G_SUPPLY_COMMIT, -- jguo Nvl(ln.ship_date, ln.receipt_date),
                                          DECODE(ln.shipping_control,
                                              1, ln.receipt_date,
                                                  2, ln.ship_date,
                                              Nvl(ln.receipt_date, ln.ship_date)),
                                      G_ASN, -- jguo Nvl(ln.ship_date, ln.receipt_date),
                                          DECODE(ln.shipping_control,
                                              1, ln.receipt_date,
                                          2, ln.receipt_date,
                                              nvl(ln.receipt_date, ln.ship_date)),
                                      G_SALES_FORECAST, -- jguo Nvl(ln.ship_date, ln.receipt_date),
                                          DECODE(ln.shipping_control,
                                              1, ln.ship_date,
                                                  2, ln.ship_date,
                                          Nvl(ln.ship_date, ln.receipt_date)),
                                      G_SALES_ORDER, -- jguo Nvl(ln.ship_date, ln.receipt_date),
                                      DECODE(ln.shipping_control,
                                                  1, ln.receipt_date,
                                          2, ln.ship_date,
                                          Nvl(ln.receipt_date, ln.ship_date)), -- jguo
                                      NULL)
           WHERE  ln.parent_header_id = p_header_id
           AND    ln.line_id = t_tmp_line_id(j)
           AND    Upper(ln.sync_indicator) = 'D';



      END IF;


	/* sbala ADD CA */
      --======================================================================
      -- Validation: Check if key date <= new schedule end date
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_END_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
	       ln.line_id = t_line_id(j) AND
	       Upper(ln.sync_indicator) = 'D' AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.key_date IS NOT NULL AND
               ln.new_schedule_end_date IS NOT NULL AND
               to_date(ln.new_schedule_end_date, p_date_format) <
		 to_date(ln.key_date, p_date_format);


      --=======================================================================
      -- End of Validations for sync indicator 'D'
      --=======================================================================
      forall j IN t_line_id.first..t_line_id.last
	UPDATE msc_supdem_lines_interface ln
	SET ln.row_status = g_failure
	WHERE ln.err_msg IS NOT NULL
	  AND Upper(ln.sync_indicator) = 'D'
	  AND ln.parent_header_id = p_header_id
	  AND ln.line_id = t_line_id(j);

      forall j IN t_line_id.first..t_line_id.last
	UPDATE msc_supdem_lines_interface ln
	SET ln.row_status = g_success
	WHERE ln.err_msg IS NULL
	  AND Upper(ln.sync_indicator) = 'D'
	  AND ln.parent_header_id = p_header_id
	  AND ln.line_id = t_line_id(j);

      END IF;

      --=======================================================================
      -- Other Independent validations for sync indicator 'R'
      --=======================================================================
      --Perform remaining validations for records with sync indicator equal to 'R'
      SELECT line_id
	BULK COLLECT INTO t_line_id
	FROM msc_supdem_lines_interface
	WHERE sync_indicator = 'R' AND
	NVL(row_status, G_PROCESS) = G_PROCESS AND
	parent_header_id = p_header_id AND
	line_id BETWEEN l_start_line and l_end_line;

      IF t_line_id IS NOT NULL AND t_line_id.COUNT > 0 THEN
	 --=======================================================================
	 -- Validation: Check that exactly two parties are involved in the transaction
	 --=======================================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_MULTIPLE_PARTIES', p_language);
	 FORALL j IN t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE  ln.parent_header_id = p_header_id AND
                  ln.line_id = t_line_id(j) AND
                  NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                  ln.publisher_company IS NOT NULL and
                  ln.supplier_company IS NOT NULL and
                  ln.customer_company IS NOT NULL;

	 --========================================================
         -- Validation: Check if posted quantity is positive
         --========================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_QUANTITY', p_language);
	 FORALL j in t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE  ln.parent_header_id = p_header_id AND
                  ln.line_id = t_line_id(j) AND
                  nVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                  NVL(ln.quantity,-1) < 0;

	 --========================================================
	 -- Validation: Check if ship from company exists
	 --========================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_FROM_PARTY', p_language);
	 FORALL j in t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE  ln.parent_header_id = p_header_id AND
                  ln.line_id = t_line_id(j) AND
                  NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                  ln.ship_from_party_name IS NOT NULL AND
                  NOT EXISTS (SELECT c.company_id
			      FROM   msc_companies c
			      WHERE  UPPER(c.company_name) = UPPER(ln.ship_from_party_name));

	 --========================================================
	 -- Validation: Check if ship to company exists
	 --========================================================
	 l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_TO_PARTY', p_language);
	 FORALL j in t_line_id.FIRST..t_line_id.LAST
	   UPDATE msc_supdem_lines_interface ln
	   SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	   WHERE  ln.parent_header_id = p_header_id AND
	          ln.line_id = t_line_id(j) AND
        	  NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
	          ln.ship_to_party_name IS NOT NULL AND
                  NOT EXISTS (SELECT c.company_id
                              FROM   msc_companies c
                              WHERE  UPPER(c.company_name) = UPPER(ln.ship_to_party_name));

	--========================================================
        -- Validation: Check if end order publisher exists
        --========================================================
	l_err_msg := get_message('MSC', 'MSC_X_INVALID_END_ORDER_PUB', p_language);
	FORALL j in t_line_id.FIRST..t_line_id.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 ln.end_order_publisher_name IS NOT NULL AND
                 NOT EXISTS (SELECT c.company_id
                             FROM   msc_companies c
                             WHERE  UPPER(c.company_name) = UPPER(ln.end_order_publisher_name));

      --========================================================
      -- Validation: Check if end order type is valid
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_END_ORDER_TYPE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.pegging_order_identifier IS NOT NULL AND
               ln.end_order_type IS NULL;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.end_order_type IS NOT NULL AND
               NOT EXISTS (SELECT l.lookup_code
                           FROM   fnd_lookup_values l
                           WHERE  l.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                  UPPER(l.meaning) = NVL(UPPER(ln.end_order_type), G_NULL_STRING) AND
		       	          l.language = p_language);


      --======================================================================
      -- Validation: Check if uom codes are valid. If no uom code is
      --                specified the default uom 'Ea' is used.
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_UOM_CODE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               NOT EXISTS (SELECT u.uom_code
                           FROM   msc_units_of_measure u
                           WHERE  u.uom_code = NVL(ln.uom, G_UOM));

      --=======================================================================
      --End of independent errors for sync indicator R
      --=======================================================================
      forall j IN t_line_id.first..t_line_id.last
	UPDATE msc_supdem_lines_interface ln
	SET ln.row_status = g_failure
	WHERE ln.err_msg IS NOT NULL
	  AND Upper(ln.sync_indicator) = 'R'
	  AND ln.parent_header_id = p_header_id
	  AND ln.line_id = t_line_id(j);

      --=======================================================================
      -- Dependent validations for sync indicator R
      --=======================================================================
      --Performing MOE validations
      if p_build_err = 2 THEN
	 SELECT flv.lookup_code,
	        ln.line_id
	   BULK COLLECT into t_order_type, t_line_id1
	   FROM   fnd_lookup_values flv,
	          msc_supdem_lines_interface ln
	   WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                  flv.language = p_language and
                  flv.meaning = ln.order_type and
                  nvl(ln.row_status, G_PROCESS) = G_PROCESS and
                  ln.parent_header_id = p_header_id and
                  ln.line_id between l_start_line and l_end_line;

	 IF t_line_id1 IS NOT NULL AND t_line_id1.COUNT > 0 THEN
	    l_err_msg := get_message('MSC', 'MSC_X_INVALID_FEW_PARTIES', p_language);
	    FORALL j in t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	      WHERE  ln.parent_header_id = p_header_id AND
                     ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                     (ln.customer_company IS NULL OR
                     ln.supplier_company IS NULL) AND
                     t_order_type(j) NOT IN (g_unallocated_onhand, g_work_order, g_safety_stock, g_proj_avai_bal, G_CONS_ADVICE);

	    FORALL j in t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	      WHERE  ln.parent_header_id = p_header_id AND
	             ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                     ln.customer_company IS NULL AND
                     ln.supplier_company IS NULL AND
		     t_order_type(j) IN (g_unallocated_onhand, g_work_order, g_safety_stock, g_proj_avai_bal, G_CONS_ADVICE);

	    l_err_msg := get_message('MSC', 'MSC_X_INVALID_PROXY_SF', p_language);
	    FORALL j in t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	      WHERE  ln.parent_header_id = p_header_id AND
                     ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                     ln.customer_company <> ln.posting_party_name AND
                     ln.supplier_company <> ln.posting_party_name AND
                     G_SALES_FORECAST = t_order_type(j);

	    FORALL j in t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.publisher_company = decode(t_order_type(j),
                                        G_SALES_FORECAST, ln.posting_party_name,
                                        G_ORDER_FORECAST, ln.customer_company,
                                        G_SUPPLY_COMMIT, ln.supplier_company,
                                        G_HIST_SALES, ln.posting_party_name,
                                        G_SELL_THRO_FCST, ln.posting_party_name,
                                        G_SUPPLIER_CAP, ln.supplier_company,
                                        G_ALLOC_ONHAND, ln.customer_company,
                                        G_UNALLOCATED_ONHAND,
						   nvl(ln.customer_company, ln.supplier_company),
					g_safety_stock,
						   nvl(ln.customer_company, ln.supplier_company),
					g_proj_avai_bal,
						   nvl(ln.customer_company, ln.supplier_company),
					G_CONS_ADVICE, nvl(ln.customer_company,
							   ln.supplier_company),
                                        G_PURCHASE_ORDER, ln.customer_company,
                                        G_SALES_ORDER, ln.supplier_company,
                                        G_ASN, ln.supplier_company,
                                        G_SHIP_RECEIPT, ln.customer_company,
                                        G_REPLENISHMENT, ln.supplier_company,
                                        G_REQUISITION, ln.customer_company,
	                                G_PO_ACKNOWLEDGEMENT, ln.supplier_company,
                                        G_WORK_ORDER, ln.supplier_company),
	             ln.publisher_site = decode(t_order_type(j),
                                        G_SALES_FORECAST,
                                           decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  ln.customer_site,
                                                  ln.supplier_company,
                                                  ln.supplier_site,
                                                  null),
                                        G_ORDER_FORECAST, ln.customer_site,
                                        G_SUPPLY_COMMIT, ln.supplier_site,
                                        G_HIST_SALES,
						decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  ln.customer_site,
                                                  ln.supplier_company,
                                                  ln.supplier_site,
                                                  null),
                                        G_SELL_THRO_FCST,
                                          decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  ln.customer_site,
                                                  ln.supplier_company,
                                                  ln.supplier_site,
                                                  null),
                                        G_SUPPLIER_CAP, ln.supplier_site,
                                        G_ALLOC_ONHAND, ln.customer_site,
                                        G_UNALLOCATED_ONHAND,
	                                      nvl(ln.customer_site, ln.supplier_site),
	                                g_safety_stock,
	                                      nvl(ln.customer_site, ln.supplier_site),
	                                g_proj_avai_bal,
	                                      nvl(ln.customer_site, ln.supplier_site),
					G_CONS_ADVICE,
					nvl(ln.customer_site, ln.supplier_site),
                                        G_PURCHASE_ORDER, ln.customer_site,
                                        G_SALES_ORDER, ln.supplier_site,
                                        G_ASN, ln.supplier_site,
                                        G_SHIP_RECEIPT, ln.customer_site,
                                        G_REPLENISHMENT, ln.supplier_site,
                                        G_REQUISITION, ln.customer_site,
	                                G_PO_ACKNOWLEDGEMENT, ln.supplier_site,
                                        G_WORK_ORDER, ln.supplier_site)
	      WHERE  ln.parent_header_id = p_header_id AND
	             ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS;

	      --======================================================================
	      -- Validation: Check if Posting Party is one of the Trading partners
	      --======================================================================
	     if (G_USER_IS_ADMIN <> SYS_YES) then
		/* only for users who do not have SC Admin Responsibility */
		l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER', p_language);
		FORALL j IN t_line_id1.FIRST..t_line_id1.LAST
		  UPDATE msc_supdem_lines_interface ln
		  SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000),
			 ln.row_status = G_FAILURE
		  WHERE  ln.parent_header_id = p_header_id AND
			 ln.line_id = t_line_id1(j) AND
			 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
			 not exists ( select 1
			                    from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.supplier_company,G_NULL_STRING))
				    union select 1
				            from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.customer_company,G_NULL_STRING))
				    union select 1
				            from dual
			                   where upper(ln.posting_party_name) =
					   upper(nvl(ln.publisher_company,G_NULL_STRING))
					   );
	     end if;

		/* sbala ADD CA */
	    FORALL j in t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.customer_company = decode(t_order_type(j),
                                       G_SALES_FORECAST,
                                           decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_ORDER_FORECAST, null,
                                        G_HIST_SALES,
				           decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_SELL_THRO_FCST,
						decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_company),
                                        G_ALLOC_ONHAND, null,
					G_UNALLOCATED_ONHAND, null,
					g_safety_stock, NULL,
					g_proj_avai_bal, NULL,
					G_CONS_ADVICE, NULL,
                                        G_PURCHASE_ORDER, null,
                                        G_SHIP_RECEIPT, null,
                                        G_REQUISITION, null,
                                        ln.customer_company),
	             ln.customer_site = decode(t_order_type(j),
                                        G_SALES_FORECAST,
                                           decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_ORDER_FORECAST, null,
                                        G_HIST_SALES,
					   decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_SELL_THRO_FCST,
				          decode(ln.posting_party_name,
                                                  ln.customer_company,
                                                  null,
                                                  ln.customer_site),
                                        G_ALLOC_ONHAND, null,
                                        G_UNALLOCATED_ONHAND, null,
                                        g_safety_stock, NULL,
					g_proj_avai_bal, NULL,
					G_PURCHASE_ORDER, null,
                                        G_SHIP_RECEIPT, null,
                                        G_REQUISITION, null,
					G_CONS_ADVICE, null,
                                        ln.customer_site),
                     ln.supplier_company = decode(t_order_type(j),
                                        G_SALES_FORECAST,
                                          decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
				        G_HIST_SALES,
				          decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
					G_SELL_THRO_FCST,
					  decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_company),
                                        G_SUPPLY_COMMIT, null,
                                        G_SUPPLIER_CAP, null,
                                        G_UNALLOCATED_ONHAND, null,
					g_safety_stock, NULL,
					g_proj_avai_bal, NULL,
					G_CONS_ADVICE, null,
                                        G_SALES_ORDER, null,
                                        G_ASN, null,
                                        G_REPLENISHMENT, null,
					G_PO_ACKNOWLEDGEMENT, null,
                                        G_WORK_ORDER, null,
                                        ln.supplier_company),
                     ln.supplier_site = decode(t_order_type(j),
                                        G_SALES_FORECAST,
                                          decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
					G_HIST_SALES,
					  decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
					G_SELL_THRO_FCST,
					  decode(ln.posting_party_name,
                                                 ln.supplier_company,
                                                 null,
                                                 ln.supplier_site),
                                        G_SUPPLY_COMMIT, null,
                                        G_SUPPLIER_CAP, null,
                                        G_UNALLOCATED_ONHAND, null,
					G_CONS_ADVICE, null,
					g_safety_stock, NULL,
					g_proj_avai_bal, NULL,
					G_SALES_ORDER, null,
                                        G_ASN, null,
                                        G_REPLENISHMENT, null,
					G_PO_ACKNOWLEDGEMENT, null,
                                        G_WORK_ORDER, null,
                                        ln.supplier_site)
	      WHERE  ln.parent_header_id = p_header_id AND
                     ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS;
 /* sbala ADD CA */

	    l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER', p_language);
	    FORALL j IN t_line_id1.FIRST..t_line_id1.LAST
	      UPDATE msc_supdem_lines_interface ln
	      SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000),
	             ln.row_status = G_FAILURE
	      WHERE  ln.parent_header_id = p_header_id AND
                     ln.line_id = t_line_id1(j) AND
                     NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                     ln.publisher_company IS NOT NULL AND
                     NOT EXISTS (SELECT c.company_id
                                 FROM   msc_companies c
                                 WHERE  UPPER(c.company_name) = UPPER(ln.publisher_company));

	 end if; -- if t_line_id1
      end if; -- if MOE

  --======================================================================
  -- Validation: Check if publisher site exists
  --======================================================================
  l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER_SITE', p_language);
  FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE msc_supdem_lines_interface ln
    SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
    WHERE  ln.parent_header_id = p_header_id AND
	   ln.line_id = t_line_id(j) AND
	   NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               NOT EXISTS (SELECT cs.company_site_id
                         FROM   msc_company_sites cs,
                                msc_companies c
                         WHERE  UPPER(c.company_name) = UPPER(ln.publisher_company) AND
                                c.company_id = cs.company_id AND
                                UPPER(cs.company_site_name) = UPPER(ln.publisher_site));

      --========================================================
      -- Validation: Check if either customer company or the
      -- supplier company is populated if the order type is NOT
      -- unallocated onhand or work order.
      --             Check if both customer and supplier company
      -- is null for unallocated onhand records.
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_NULL_SUBSCRIBER', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
	        ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 ln.customer_company IS NULL AND
		 ln.supplier_company IS NULL AND
		 not exists (SELECT 1
                                          FROM   fnd_lookup_values flv
                                          WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                                 UPPER(flv.meaning) = UPPER(ln.order_type) AND
					         flv.language = p_language AND
						 flv.lookup_code in (G_UNALLOCATED_ONHAND,G_CONS_ADVICE,g_work_order,g_safety_stock,g_proj_avai_bal));
 /* sbala ADD CA */
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_MULT_PARTIES_UO', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               (ln.supplier_company IS NOT NULL or
               ln.customer_company IS NOT NULL) and
               (G_UNALLOCATED_ONHAND = (SELECT flv.lookup_code
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              UPPER(flv.meaning) = UPPER(ln.order_type) AND
					      flv.language = p_language) OR
	        G_CONS_ADVICE = (SELECT flv.lookup_code
                                       FROM   fnd_lookup_values flv
                       WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                UPPER(flv.meaning) = UPPER(ln.order_type) AND
                       flv.language = p_language) OR
		g_safety_stock = (SELECT flv.lookup_code
                                    FROM   fnd_lookup_values flv
                                    WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                           UPPER(flv.meaning) = UPPER(ln.order_type) AND
				           flv.language = p_language) OR
		g_proj_avai_bal = (SELECT flv.lookup_code
                                     FROM   fnd_lookup_values flv
                                     WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                            UPPER(flv.meaning) = UPPER(ln.order_type) AND
				            flv.language = p_language));
	        /* sbala ADD CA */
      --========================================================
      -- Validation: Check if customer company exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_CUSTOMER', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.customer_company IS NOT NULL AND
               NOT EXISTS (SELECT c.company_id
			   FROM   msc_companies c,
                                    msc_companies c1,
                                    msc_company_relationships r
                             WHERE  UPPER(c.company_name) = UPPER(ln.customer_company) and
			            UPPER(c1.company_name) = UPPER(NVL(ln.publisher_company,
								       ln.posting_party_name)) and
                                    r.subject_id = c1.company_id and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 1);

      --========================================================
      -- Validation: Check if customer site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_CUST_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS)  = G_PROCESS AND
                 ln.customer_company IS NOT NULL AND
                 NOT EXISTS (SELECT cs.company_site_id
                             FROM   msc_company_sites cs,
                                    msc_companies c
                             WHERE  UPPER(c.company_name) = UPPER(ln.customer_company) AND
                                    c.company_id = cs.company_id AND
                                    UPPER(cs.company_site_name) = UPPER(NVL(ln.customer_site,
                                                                        G_NULL_STRING)));

      --========================================================
      -- Validation: Check if supplier company exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SUPPLIER', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
	UPDATE msc_supdem_lines_interface ln
	SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 ln.supplier_company IS NOT NULL AND
                 NOT EXISTS (SELECT c.company_id
                             FROM   msc_companies c,
                                    msc_companies c1,
                                    msc_company_relationships r
                             WHERE  UPPER(c.company_name) = UPPER(ln.supplier_company) and
                                    UPPER(c1.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
                                    r.subject_id = c1.company_id and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 2);

      --========================================================
      -- Validation: Check if supplier site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SUPP_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.supplier_company IS NOT NULL AND
               NOT EXISTS (SELECT cs.company_site_id
                           FROM   msc_company_sites cs,
                                  msc_companies c
                           WHERE  UPPER(c.company_name) = UPPER(ln.supplier_company) AND
                                  c.company_id = cs.company_id AND
                                  UPPER(cs.company_site_name) = UPPER(NVL(ln.supplier_site,
                                                                      G_NULL_STRING)));

      --========================================================
      -- Validation: Check if ship from site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_FROM_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.ship_from_party_name IS NOT NULL AND
               NOT EXISTS (SELECT cs.company_site_id
                           FROM   msc_company_sites cs,
                                  msc_companies c
                           WHERE  UPPER(c.company_name) = UPPER(ln.ship_from_party_name) AND
                                  c.company_id = cs.company_id AND
                                  UPPER(cs.company_site_name) = UPPER(NVL(ln.ship_from_party_site, G_NULL_STRING)));


      --========================================================
      -- Validation: Check if ship to site exists
      --========================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_TO_SITE', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.ship_to_party_name IS NOT NULL AND
               NOT EXISTS (SELECT cs.company_site_id
                           FROM   msc_company_sites cs,
                                  msc_companies c
                           WHERE  UPPER(c.company_name) = UPPER(ln.ship_to_party_name) AND
                                  c.company_id = cs.company_id AND
                                  UPPER(cs.company_site_name) = UPPER(NVL(ln.ship_to_party_site, G_NULL_STRING)));

     --========================================================
     -- Validation: Check if end order publisher site exists
     --========================================================
     l_err_msg := get_message('MSC', 'MSC_X_INV_END_ORD_PUB_SITE', p_language);
     FORALL j in t_line_id.FIRST..t_line_id.LAST
       UPDATE msc_supdem_lines_interface ln
       SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
       WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.end_order_publisher_name IS NOT NULL AND
               NOT EXISTS (SELECT cs.company_site_id
                           FROM   msc_company_sites cs,
                                  msc_companies c
                           WHERE  UPPER(c.company_name) = UPPER(ln.end_order_publisher_name) AND
                                  c.company_id = cs.company_id AND
                                  UPPER(cs.company_site_name) = UPPER(NVL(ln.end_order_publisher_site, G_NULL_STRING)));

      --========================================================================
      --Validation: Item check for records with sync indicator 'R'
      --========================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_ITEM', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        update msc_supdem_lines_interface ln
        set    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        where  ln.parent_header_id = p_header_id and
               ln.line_id = t_line_id(j) and
               NVL(ln.row_status, G_PROCESS) = G_PROCESS and
               ln.sync_indicator = 'R' and
               not exists ( select i.inventory_item_id
                            from   msc_items i
                            where  i.item_name = ln.item_name
                            UNION
                            select msi.inventory_item_id
                            from   msc_system_items msi,
                                   msc_trading_partners part,
                                   msc_trading_partner_maps map,
                                   msc_company_sites cs,
                                   msc_companies c
                            where  msi.plan_id = -1 and
                                   msi.item_name = nvl(ln.owner_item_name,
                                                       nvl(ln.customer_item_name,
                                                           ln.supplier_item_name)) and
                                   msi.organization_id = part.sr_tp_id and
                                   msi.sr_instance_id = part.sr_instance_id and
                                   part.partner_type = 3 and
                                   part.partner_id = map.tp_key and
                                   map.map_type = 2 and
                                   map.company_key = cs.company_site_id and
                                   UPPER(cs.company_site_name) = UPPER(decode(ln.owner_item_name,
                                                                 null,
                                                                 decode(ln.customer_item_name,
                                                                        null,
                                                                        nvl(ln.supplier_site,
                                                                            ln.publisher_site),
                                                                        nvl(ln.customer_site,
                                                                            ln.publisher_site)),
                                                                 ln.publisher_site)) and
                                   cs.company_id = c.company_id and
                                   UPPER(c.company_name) = UPPER(decode(ln.owner_item_name,
                                                           null,
                                                           decode(ln.customer_item_name,
                                                                  null,
                                                                  nvl(ln.supplier_company,
                                                                      ln.publisher_company),
                                                                  nvl(ln.customer_company,
                                                                      ln.publisher_company)),
                                                           ln.publisher_company)) and
                                   NVL(part.company_id,1) = c.company_id  and
                                   ln.item_name IS NULL
                             UNION
                             select mis.inventory_item_id
                             from   msc_item_suppliers mis,
                                    msc_trading_partners mtp,
                                    msc_trading_partner_maps map,
                                    msc_trading_partner_maps map1,
                                    msc_trading_partner_maps map2,
                                    msc_company_relationships r,
                                    msc_company_sites cs,
                                    msc_companies c,
                                    msc_company_sites cs1
                             where  mis.plan_id = -1 and
                                    mis.supplier_item_name = nvl(ln.owner_item_name,
                                                                 ln.supplier_item_name) and
                                    mis.organization_id = mtp.sr_tp_id and
                                    mis.sr_instance_id = mtp.sr_instance_id and
                                    mtp.partner_id = map2.tp_key and
                                    map2.map_type = 2 and
                                    map2.company_key = cs1.company_site_id and
                                    cs1.company_id = 1 and
                                    mis.supplier_id = map.tp_key and
                                    mis.supplier_site_id = map1.tp_key and
                                    map.map_type = 1 and
                                    map.company_key = r.relationship_id and
                                    r.subject_id = 1 and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 2 and
                                    UPPER(c.company_name) = UPPER(decode(ln.owner_item_name, null,
                                                            nvl(ln.supplier_company,
                                                                ln.publisher_company),
                                                            ln.publisher_company)) and
                                    map1.map_type = 3 and
                                    map1.company_key = cs.company_site_id and
                                    UPPER(cs.company_site_name) = UPPER(decode(ln.owner_item_name, null,
                                                            nvl(ln.supplier_site,
                                                                ln.publisher_site),
                                                            ln.publisher_site)) and
                                    cs.company_id = c.company_id   AND
                                    ln.item_name IS NULL
                             UNION
                             select mic.inventory_item_id
                             from   msc_item_customers mic,
                                    msc_trading_partner_maps map,
                                    msc_trading_partner_maps map1,
                                    msc_company_relationships r,
                                    msc_company_sites cs,
                                    msc_companies c
                             where  mic.plan_id = -1 and
                                    mic.customer_item_name = nvl(ln.owner_item_name,
                                                                 ln.customer_item_name) and
                                    mic.customer_id = map.tp_key and
				    --nvl(mic.customer_site_id, map1.tp_key) = map1.tp_key and
				    mic.customer_site_id = map1.tp_key and
                                    map.map_type = 1 and
                                    map.company_key = r.relationship_id and
                                    r.subject_id = 1 and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 1 and
                                    UPPER(c.company_name) = UPPER(decode(ln.owner_item_name, null,
                                                            nvl(ln.customer_company,
                                                                ln.publisher_company),
                                                            ln.publisher_company)) and
                                    map1.map_type = 3 and
                                    map1.company_key = cs.company_site_id and
                                    UPPER(cs.company_site_name) = UPPER(decode(ln.owner_item_name, null,
                                                            nvl(ln.customer_site,    --bug #4292548
                                                                ln.publisher_site),
                                                            ln.publisher_site)) and
                                    cs.company_id = c.company_id   AND
                                    ln.item_name IS NULL
			       );

      --========================================================================
      --Validation: Item check in OEM org
      --========================================================================

       IF t_order_type IS NOT NULL AND t_order_type.COUNT > 0 THEN
	      l_err_msg := get_message('MSC', 'MSC_X_INVALID_ITEM', p_language);
	      FORALL j IN t_line_id.FIRST..t_line_id.LAST
		update msc_supdem_lines_interface ln
		set    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
		where  ln.parent_header_id = p_header_id and
		       ln.line_id = t_line_id(j) and
		       NVL(ln.row_status, G_PROCESS) = G_PROCESS and
		       not exists ( select msi.inventory_item_id
				    from   msc_system_items msi,
					   msc_trading_partners part,
					   msc_trading_partner_maps map,
					   msc_company_sites cs,
					   msc_companies c
				    where  msi.plan_id = -1 and
					   msi.item_name = ln.item_name and
					   msi.organization_id = part.sr_tp_id and
					   msi.sr_instance_id = part.sr_instance_id and
					   part.partner_type = 3 and
					   part.partner_id = map.tp_key and
					   map.map_type = 2 and
					   map.company_key = cs.company_site_id and
					   UPPER(cs.company_site_name) = upper(ln.publisher_site) and
					   cs.company_id = c.company_id and
					   UPPER(c.company_name) = upper(ln.publisher_company) and
					   c.company_id = 1 and
					   NVL(part.company_id,1) = c.company_id
				    union  select 1
				     from  msc_companies c
				     where  c.company_id <> 1 and G_CONS_ADVICE <> t_order_type(j) and
				           UPPER(c.company_name) = upper(ln.publisher_company)
				    /* For Consumption Advice, Item should be valid in the Org modelled as the customer (publisher) */
				    union  select 1
				     from msc_system_items msi,
					msc_trading_partners part,
					msc_trading_partner_maps map,
					msc_company_sites cs,
					msc_companies c
				     where
				       msi.plan_id = -1 and
				       msi.item_name = ln.item_name and
				       msi.organization_id = part.sr_tp_id and
				       msi.sr_instance_id = part.sr_instance_id and
				       part.partner_type = 3 and
				       part.modeled_customer_site_id = map.tp_key and
				       map.map_type = 3 and
				       map.company_key = cs.company_site_id and
				       UPPER(cs.company_site_name) = upper(ln.publisher_site) and
				       cs.company_id = c.company_id and
				       UPPER(c.company_name) = upper(ln.publisher_company) and
				       c.company_id <> 1 and
				       G_CONS_ADVICE = t_order_type(j) and
				       msi.consigned_flag = 1 and -- bug 4744103
				       msi.inventory_planning_code = 7 -- bug 4744108
				       );
END IF;
	--=========================================================
	-- If publisher is a modeled org in the OEM's company, they
        -- should not be allowed to publish unallocated onhand
        --=========================================================
        l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUB_UO', p_language);
        FORALL j IN t_line_id.FIRST..t_line_id.LAST
          UPDATE msc_supdem_lines_interface ln
          SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
          WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 (G_UNALLOCATED_ONHAND = (SELECT flv.lookup_code
                                          FROM   fnd_lookup_values flv
                                          WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                                 UPPER(flv.meaning) = UPPER(ln.order_type) AND
					         flv.language = p_language)) AND
                 exists (SELECT 'exists'
                         FROM   msc_companies c0,
                                msc_company_sites s0,
                                msc_trading_partners mtp,
                                msc_trading_partners mtp1,
                                msc_trading_partner_maps maps,
                                msc_trading_partner_maps maps1,
                                msc_trading_partner_maps maps2,
                                msc_trading_partner_sites mtps,
                                msc_company_sites cs,
                                msc_companies c,
                                msc_company_relationships rel
                         WHERE  rel.relationship_type = 2
                         AND    rel.subject_id = 1
                         AND    Upper(c0.company_name) = Upper(ln.publisher_company)
                         AND    rel.object_id = c0.company_id
                         AND    maps.company_key = rel.relationship_id
                         AND    maps.map_type = 1
                         AND    maps.tp_key = mtp.partner_id
                         AND    s0.company_id = c0.company_id
                         AND    Upper(s0.company_site_name) = Upper(ln.publisher_site)
                         AND    maps1.company_key = s0.company_site_id
                         AND    maps1.map_type = 3
                         AND    mtps.partner_site_id = maps1.tp_key
                         AND    mtps.partner_id = mtp.partner_id
                         AND    mtp1.partner_type = 3
	                 AND    mtp1.modeled_supplier_id = mtp.partner_id
	                 AND    mtp1.modeled_supplier_site_id = mtps.partner_site_id
                         AND    maps2.tp_key = mtp1.partner_id
                         AND    maps2.map_type = 2
                         AND    cs.company_site_id = maps2.company_key
                         AND    cs.company_id = c.company_id
	                 AND    c.company_id = 1);

	FORALL j IN t_line_id.FIRST..t_line_id.LAST
          UPDATE msc_supdem_lines_interface ln
          SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
          WHERE  ln.parent_header_id = p_header_id AND
                 ln.line_id = t_line_id(j) AND
                 NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
                 (G_UNALLOCATED_ONHAND = (SELECT flv.lookup_code
                                          FROM   fnd_lookup_values flv
                                          WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                                 UPPER(flv.meaning) = UPPER(ln.order_type) AND
					         flv.language = p_language)) AND
                 exists( select 'exist'
                         from   msc_companies c,
                                msc_company_sites s,
                                msc_trading_partner_maps m,
                                msc_trading_partners t
                         where  upper(c.company_name) = upper(ln.publisher_company)
                         and    c.company_id = s.company_id
                         and    upper(s.company_site_name) = upper(ln.publisher_site)
                         and    m.company_key = s.company_site_id
                         and    m.map_type = 2
                         and    m.tp_key = t.partner_id
                         and    t.partner_type = 3
                         and    t.modeled_supplier_id is not null
                         and    t.modeled_supplier_site_id is not NULL);


      --======================================================================
      -- Validation: Check if wip completion date is populated if the order type is
      --             Work order
      --
      --             Check if wip completion date is populated if the order type is
      --             Work order
      --======================================================================
      l_err_msg := get_message('MSC','MSC_X_INVALID_WIP_DATE', p_language);
      forall j IN t_line_id.first..t_line_id.last
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id
        AND    ln.line_id = t_line_id(j)
        AND    Nvl(ln.row_status, g_process) = g_process
        AND    g_null_string = (SELECT Nvl(ln1.wip_end_date, g_null_string)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code = g_work_order);

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.wip_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) = (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code = g_work_order);

     l_err_msg := get_message('MSC','MSC_X_INVALID_WIP_ST_DATE', p_language);
       forall j IN t_line_id.first..t_line_id.last
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id
        AND    ln.line_id = t_line_id(j)
        AND    Nvl(ln.row_status, g_process) = g_process
        AND    ln.wip_start_date IS NOT NULL
        AND    to_date(ln.wip_start_date, p_date_format) >
	  to_date(ln.wip_end_date, p_date_format);

      -- jguo: call API to validate receipt/ship date for TP as a cusotmer
         validate_rs_dates_customer(
           t_line_id -- IN lineidList
         , p_header_id -- IN NUMBER
         , p_language
         );

      -- jguo: call API to validate receipt/ship date for TP as a supplier
         validate_rs_dates_supplier(
           t_line_id -- IN lineidList
         , p_header_id -- IN NUMBER
         , p_language
         );

      --=================================================================================
      -- Validation: Check if new_schedule date (aka actual date) is populated if the
      --                order type is historical sales, safety stock, allocated onhand
      --=================================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_ACT_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.new_schedule_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_HIST_SALES,
                                                           G_SAFETY_STOCK,
                                                           G_ALLOC_ONHAND,
                                                           G_PROJ_AVAI_BAL));
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.new_schedule_date,
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code IN (G_CONS_ADVICE,
								G_HIST_SALES,
                                                                  G_SAFETY_STOCK,
                                                                  G_ALLOC_ONHAND,
                                                                  G_PROJ_AVAI_BAL));
-- jguo: change starts here
      --==============================================================================
      -- Validation: Check if either ship date or receipt date is
      --                populated if the order type is supply commit,
      --                sales order, ASN
      --==============================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_RCPT_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.ship_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_SUPPLY_COMMIT,
                                                           G_ASN,
                                                           G_SALES_FORECAST,
                                                           G_SALES_ORDER)) AND
               G_NULL_STRING = (SELECT NVL(ln1.receipt_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_SUPPLY_COMMIT,
                                                           G_ASN,
                                                           G_SALES_FORECAST,
                                                           G_SALES_ORDER))

       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
                                                                       ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date =  NVL(ln.receipt_date, ln.ship_date), -- jguo NVL(ln.ship_date, ln.receipt_date),
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code IN (G_SUPPLY_COMMIT,
                                                                  G_ASN,
                                                                  ---G_SALES_FORECAST,
                                                                  G_SALES_ORDER))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      );


        FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date =  NVL(ln.ship_date, ln.receipt_date),
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code  = G_SALES_FORECAST)
         AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      );
-- jguo: change ends here

      --======================================================================
      -- Validation: Check if key date <= new schedule end date
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_END_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.key_date IS NOT NULL AND
               ln.new_schedule_end_date IS NOT NULL AND
               to_date(ln.new_schedule_end_date, p_date_format) <
		 to_date(ln.key_date, p_date_format);

      --=========================================================================
      -- Check if the ship date > the receipt date
      --=========================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_DATE1', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               ln.ship_date is not null AND
               ln.receipt_date is not null AND
               to_date(ln.ship_date, p_date_format) >
		 to_date(ln.receipt_date, p_date_format);


      --=========================================================================
      -- Check if the SO has already been entered via iSP (PO-Ack validation)
      --=========================================================================
      l_err_msg := get_message('MSC', 'MSC_X_SO_EXISTS', p_language);
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) = (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code IN (G_SALES_ORDER)) AND
               exists (SELECT 'exists'
                       FROM msc_sup_dem_entries sd
                       WHERE Upper(sd.publisher_name) = Upper(ln.publisher_company)
                       AND Upper(sd.publisher_site_name) = Upper(ln.publisher_site)
                       AND Upper(sd.customer_name) = Upper(ln.customer_company)
                       AND Upper(sd.customer_site_name) = Upper(ln.customer_site)
                       AND (sd.item_name = nvl(ln.item_name, nvl(ln.owner_item_name, nvl(ln.customer_item_name, ln.supplier_item_name))) OR
                            sd.owner_item_name = nvl(ln.owner_item_name, nvl(ln.item_name, nvl(ln.customer_item_name, ln.supplier_item_name))) OR
                            sd.customer_item_name = nvl(ln.customer_item_name, nvl(ln.item_name, nvl(ln.owner_item_name, ln.supplier_item_name))) OR
                            sd.supplier_item_name = nvl(ln.supplier_item_name, nvl(ln.item_name, nvl(ln.owner_item_name, ln.customer_item_name))))
                       AND Upper(sd.publisher_order_type_desc) = Upper(ln.order_type)
                       --AND Nvl(sd.order_number, g_null_string) = Nvl(ln.order_identifier, g_null_string)
                       --AND Nvl(sd.line_number, g_null_string) = Nvl(ln.line_number, g_null_string)
                       --AND Nvl(sd.release_number, g_null_string) = Nvl(ln.release_number, g_null_string)
                       AND Nvl(sd.end_order_number, g_null_string) = Nvl(ln.pegging_order_identifier, g_null_string)
                       AND Nvl(sd.end_order_line_number, g_null_string) = Nvl(ln.ref_line_number, g_null_string)
                       AND Nvl(sd.end_order_rel_number, g_null_string) = Nvl(ln.ref_release_number, g_null_string)
                       AND nvl(sd.ack_flag, 'N') = 'Y');

      --=========================================================================
      -- End of Dependent Validations
      -- Update row status in MSC_SUPDEM_LINES_INTERFACE to G_FAILURE (4) if
      -- the err_msg is not null
      --=========================================================================
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.row_status = G_FAILURE
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
	       NVL(ln.row_status, G_PROCESS) = g_process AND
	       ln.err_msg IS NOT NULL;

      --=========================================================================
      -- Update row status in MSC_SUPDEM_LINES_INTERFACE to G_SUCCESS (3) if
      -- the err_msg is null
      --=========================================================================
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.row_status = G_SUCCESS
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = g_process AND
               Nvl(ln.err_msg, g_null_string) = g_null_string;

      --=========================================================================
      -- Post Validation steps
      -- Populate the item id column for validated records
      --=========================================================================
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        update msc_supdem_lines_interface l
        set    l.inventory_item_id =
                           (select i.inventory_item_id
                            from   msc_items i,
                                   msc_supdem_lines_interface ln
                            where  i.item_name = ln.item_name and
                                   ln.parent_header_id = p_header_id AND
                                   ln.line_id = t_line_id(j) AND
                                   NVL(ln.row_status, G_PROCESS) = G_SUCCESS
                            UNION
                            select msi.inventory_item_id
                            from   msc_system_items msi,
                                   msc_trading_partners part,
                                   msc_trading_partner_maps map,
                                   msc_company_sites cs,
                                   msc_companies c,
                                   msc_supdem_lines_interface ln
                            where  msi.plan_id = -1 and
                                   ln.parent_header_id = p_header_id AND
                                   ln.line_id = t_line_id(j) AND
                                   NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
                                   msi.item_name = nvl(ln.owner_item_name,
                                                       nvl(ln.customer_item_name,
                                                           ln.supplier_item_name)) and
                                   msi.organization_id = part.sr_tp_id and
                                   msi.sr_instance_id = part.sr_instance_id and
                                   part.partner_type = 3 and
                                   part.partner_id = map.tp_key and
                                   map.map_type = 2 and
                                   map.company_key = cs.company_site_id and
                                   cs.company_site_name = decode(ln.owner_item_name,
                                                                 null,
                                                                 decode(ln.customer_item_name,
                                                                        null,
                                                                        nvl(ln.supplier_site,
                                                                            ln.publisher_site),
                                                                        nvl(ln.customer_site,
                                                                            ln.publisher_site)),
                                                                 ln.publisher_site) and
                                   cs.company_id = c.company_id and
                                   c.company_name = decode(ln.owner_item_name,
                                                           null,
                                                           decode(ln.customer_item_name,
                                                                  null,
                                                                  nvl(ln.supplier_company,
                                                                      ln.publisher_company),
                                                                  nvl(ln.customer_company,
                                                                      ln.publisher_company)),
                                                           ln.publisher_company) and
                                   NVL(part.company_id,1) = c.company_id  and
                                   ln.item_name IS NULL
                             UNION
                             select mis.inventory_item_id
                             from   msc_item_suppliers mis,
                                    msc_trading_partner_maps map,
                                    msc_trading_partner_maps map1,
                                    msc_company_relationships r,
                                    msc_company_sites cs,
                                    msc_companies c,
                                    msc_supdem_lines_interface ln
                             where  mis.plan_id = -1 and
                                    ln.parent_header_id = p_header_id AND
                                    ln.line_id = t_line_id(j) AND
                                    NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
                                    mis.supplier_item_name = nvl(ln.owner_item_name,
                                                                 ln.supplier_item_name) and
                                    mis.supplier_id = map.tp_key and
                                    mis.supplier_site_id = map1.tp_key and
                                    map.map_type = 1 and
                                    map.company_key = r.relationship_id and
                                    r.subject_id = 1 and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 2 and
                                    c.company_name = decode(ln.owner_item_name, null,
                                                            nvl(ln.supplier_company,
                                                                ln.publisher_company),
                                                            ln.publisher_company) and
                                    map1.map_type = 3 and
                                    map1.company_key = cs.company_site_id and
                                    cs.company_site_name = decode(ln.owner_item_name, null,
                                                            nvl(ln.supplier_site,
                                                                ln.publisher_site),
                                                            ln.publisher_site) and
                                    cs.company_id = c.company_id   AND
                                    ln.item_name IS NULL
                             UNION
                             select mic.inventory_item_id
                             from   msc_item_customers mic,
                                    msc_trading_partner_maps map,
                                    msc_trading_partner_maps map1,
                                    msc_company_relationships r,
                                    msc_company_sites cs,
                                    msc_companies c,
                                    msc_supdem_lines_interface ln
                             where  mic.plan_id = -1 and
                                    ln.parent_header_id = p_header_id AND
                                    ln.line_id = t_line_id(j) AND
                                    NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
                                    mic.customer_item_name = nvl(ln.owner_item_name,
                                                                 ln.customer_item_name) and
                                    mic.customer_id = map.tp_key and
				    --nvl(mic.customer_site_id, map1.tp_key) = map1.tp_key and
				    mic.customer_site_id = map1.tp_key and
                                    map.map_type = 1 and
                                    map.company_key = r.relationship_id and
                                    r.subject_id = 1 and
                                    r.object_id = c.company_id and
                                    r.relationship_type = 1 and
                                    c.company_name = decode(ln.owner_item_name, null,
                                                            nvl(ln.customer_company,
                                                                ln.publisher_company),
                                                            ln.publisher_company) and
                                    map1.map_type = 3 and
                                    map1.company_key = cs.company_site_id and
                                    cs.company_site_name = decode(ln.owner_item_name, null,
                                                            nvl(ln.customer_site,
                                                                ln.publisher_site),
                                                            ln.publisher_site) and
                                    cs.company_id = c.company_id   AND
                                    ln.item_name IS NULL
                            )
        where  l.parent_header_id = p_header_id AND
               l.line_id = t_line_id(j) AND
               NVL(l.row_status, G_PROCESS) = G_SUCCESS;

    END IF; --End of sync indicator R validations

  END LOOP; --End of the main 'for' loop

  IF p_build_err <> 2 then
     OPEN c_exec_keys(p_header_id, p_language);
     FETCH c_exec_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_supp,
       t_supp_site,
       t_order_type_desc,
       t_item_id,
       t_order_number,
       t_rel_number,
       t_line_number,
       t_end_order_number,
       t_end_order_rel_number,
       t_end_order_line_number;
     CLOSE c_exec_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEYS_EXEC', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 then
	forall j IN t_pub.first..t_pub.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.supplier_company),-99) = Nvl(t_supp(j),-99)
             AND Nvl(Upper(ln1.supplier_site),-99) = Nvl(t_supp_site(j),-99)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND Nvl(Upper(ln1.order_identifier),-99) = Nvl(t_order_number(j),-99)
             AND Nvl(Upper(ln1.release_number),-99) = Nvl(t_rel_number(j),-99)
             AND Nvl(Upper(ln1.line_number),-99) = Nvl(t_line_number(j),-99)
             AND Nvl(Upper(ln1.pegging_order_identifier),-99) = Nvl(t_end_order_number(j),-99)
             AND Nvl(Upper(ln1.ref_release_number),-99) = Nvl(t_end_order_rel_number(j),-99)
             AND Nvl(Upper(ln1.ref_line_number),-99) = Nvl(t_end_order_line_number(j),-99)
             AND 1 < (SELECT COUNT(*)
                      FROM msc_supdem_lines_interface ln2
                      WHERE ln2.parent_header_id = p_header_id
                      AND Upper(ln2.publisher_company) = t_pub(j)
                      AND Upper(ln2.publisher_site) = t_pub_site(j)
                      AND Nvl(Upper(ln2.supplier_company),-99) = Nvl(t_supp(j),-99)
                      AND Nvl(Upper(ln2.supplier_site),-99) = Nvl(t_supp_site(j),-99)
                      AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                      AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                      AND Upper(ln2.order_type) = t_order_type_desc(j)
                      AND ln2.inventory_item_id = t_item_id(j)
                      AND Nvl(Upper(ln2.order_identifier),-99) = Nvl(t_order_number(j),-99)
                      AND Nvl(Upper(ln2.release_number),-99) = Nvl(t_rel_number(j),-99)
                      AND Nvl(Upper(ln2.line_number),-99) = Nvl(t_line_number(j),-99)
                      AND Nvl(Upper(ln2.pegging_order_identifier),-99) = Nvl(t_end_order_number(j),-99)
                      AND Nvl(Upper(ln2.ref_release_number),-99) = Nvl(t_end_order_rel_number(j),-99)
                      AND Nvl(Upper(ln2.ref_line_number),-99) = Nvl(t_end_order_line_number(j),-99)));
     END IF;

     OPEN c_work_order_keys(p_header_id, p_language);
     FETCH c_work_order_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_order_type_desc,
       t_item_id,
       t_order_number;
     CLOSE c_work_order_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEYS_WIP', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 THEN
	forall j IN t_pub.first..t_pub.last
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND Nvl(ln1.order_identifier, '-99') = Nvl(t_order_number(j), '-99')
             AND 1 < (SELECT COUNT(*)
                      FROM msc_supdem_lines_interface ln2
                      WHERE ln2.parent_header_id = p_header_id
                      AND Upper(ln2.publisher_company) = t_pub(j)
                      AND Upper(ln2.publisher_site) = t_pub_site(j)
                      AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                      AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                      AND Upper(ln2.order_type) = t_order_type_desc(j)
                      AND ln2.inventory_item_id = t_item_id(j)
                      AND Nvl(ln2.order_identifier, '-99') = Nvl(t_order_number(j), '-99')));
     END IF;

     OPEN c_onhand_keys(p_header_id, p_language);
     FETCH c_onhand_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_supp,
       t_supp_site,
       t_order_type_desc,
       t_item_id;
     CLOSE c_onhand_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEY_PLANNING', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 then
	forall j IN t_pub.first..t_pub.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.supplier_company),-99) = Nvl(t_supp(j),-99)
             AND Nvl(Upper(ln1.supplier_site),-99) = Nvl(t_supp_site(j),-99)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND 1 < (SELECT COUNT(*)
                 FROM msc_supdem_lines_interface ln2
                 WHERE ln2.parent_header_id = p_header_id
                 AND Upper(ln2.publisher_company) = t_pub(j)
                 AND Upper(ln2.publisher_site) = t_pub_site(j)
                 AND Nvl(Upper(ln2.supplier_company),-99) = Nvl(t_supp(j),-99)
                 AND Nvl(Upper(ln2.supplier_site),-99) = Nvl(t_supp_site(j),-99)
                 AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                 AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                 AND Upper(ln2.order_type) = t_order_type_desc(j)
                 AND ln2.inventory_item_id = t_item_id(j)));
     END IF;

     OPEN c_daily_keys(p_header_id, p_language,p_date_format);
     FETCH c_daily_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_supp,
       t_supp_site,
       t_order_type_desc,
       t_item_id,
       t_key_date,
       t_bucket_type;
     CLOSE c_daily_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEY_PLANNING', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 then
	forall j IN t_pub.first..t_pub.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.supplier_company),-99) = Nvl(t_supp(j),-99)
             AND Nvl(Upper(ln1.supplier_site),-99) = Nvl(t_supp_site(j),-99)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND Nvl(Upper(ln1.bucket_type),1) = Nvl(t_bucket_type(j),1)
             AND t_key_date(j) = trunc(to_date(ln1.key_date,p_date_format))
             AND 1 < (SELECT COUNT(*)
                 FROM msc_supdem_lines_interface ln2
                 WHERE ln2.parent_header_id = p_header_id
                 AND Upper(ln2.publisher_company) = t_pub(j)
                 AND Upper(ln2.publisher_site) = t_pub_site(j)
                 AND Nvl(Upper(ln2.supplier_company),-99) = Nvl(t_supp(j),-99)
                 AND Nvl(Upper(ln2.supplier_site),-99) = Nvl(t_supp_site(j),-99)
                 AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                 AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                 AND Upper(ln2.order_type) = t_order_type_desc(j)
                 AND ln2.inventory_item_id = t_item_id(j)
                 AND Nvl(Upper(ln2.bucket_type),1) = Nvl(t_bucket_type(j),1)
                 AND t_key_date(j) = trunc(to_date(ln2.key_date,p_date_format))
		 ));
     END IF;

     OPEN c_weekly_keys(p_header_id, p_language,p_date_format);
     FETCH c_weekly_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_supp,
       t_supp_site,
       t_order_type_desc,
       t_item_id,
       t_key_date,
       t_bucket_type;
     CLOSE c_weekly_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEY_PLANNING', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 then
	forall j IN t_pub.first..t_pub.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.supplier_company),-99) = Nvl(t_supp(j),-99)
             AND Nvl(Upper(ln1.supplier_site),-99) = Nvl(t_supp_site(j),-99)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND Upper(ln1.bucket_type) = t_bucket_type(j)
             AND t_key_date(j) = trunc(to_date(ln1.key_date,p_date_format))
             AND 1 < (SELECT COUNT(*)
                 FROM msc_supdem_lines_interface ln2
                 WHERE ln2.parent_header_id = p_header_id
                 AND Upper(ln2.publisher_company) = t_pub(j)
                 AND Upper(ln2.publisher_site) = t_pub_site(j)
                 AND Nvl(Upper(ln2.supplier_company),-99) = Nvl(t_supp(j),-99)
                 AND Nvl(Upper(ln2.supplier_site),-99) = Nvl(t_supp_site(j),-99)
                 AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                 AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                 AND Upper(ln2.order_type) = t_order_type_desc(j)
                 AND ln2.inventory_item_id = t_item_id(j)
                 AND Upper(ln2.bucket_type) = t_bucket_type(j)
                 AND t_key_date(j) = trunc(to_date(ln2.key_date,p_date_format))
		 ));
     END IF;

     OPEN c_monthly_keys(p_header_id, p_language,p_date_format);
     FETCH c_monthly_keys
       bulk collect INTO t_pub,
       t_pub_site,
       t_cust,
       t_cust_site,
       t_supp,
       t_supp_site,
       t_order_type_desc,
       t_item_id,
       t_key_date,
       t_bucket_type;
     CLOSE c_monthly_keys;

     l_err_msg := get_message('MSC', 'MSC_X_DUPLICATE_KEY_PLANNING', p_language);
     IF t_pub IS NOT NULL AND t_pub.COUNT > 0 then
	forall j IN t_pub.first..t_pub.LAST
	  UPDATE msc_supdem_lines_interface ln
	  SET ln.row_status = g_failure,
	  ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
	  WHERE ln.line_id IN (SELECT DISTINCT ln1.line_id
             FROM msc_supdem_lines_interface ln1
             WHERE ln1.parent_header_id = p_header_id
             AND Upper(ln1.publisher_company) = t_pub(j)
             AND Upper(ln1.publisher_site) = t_pub_site(j)
             AND Nvl(Upper(ln1.supplier_company),-99) = Nvl(t_supp(j),-99)
             AND Nvl(Upper(ln1.supplier_site),-99) = Nvl(t_supp_site(j),-99)
             AND Nvl(Upper(ln1.customer_company),-99) = Nvl(t_cust(j),-99)
             AND Nvl(Upper(ln1.customer_site),-99) = Nvl(t_cust_site(j),-99)
             AND Upper(ln1.order_type) = t_order_type_desc(j)
             AND ln1.inventory_item_id = t_item_id(j)
             AND Upper(ln1.bucket_type) = t_bucket_type(j)
             AND t_key_date(j) = trunc(to_date(ln1.key_date,p_date_format))
             AND 1 < (SELECT COUNT(*)
                 FROM msc_supdem_lines_interface ln2
                 WHERE ln2.parent_header_id = p_header_id
                 AND Upper(ln2.publisher_company) = t_pub(j)
                 AND Upper(ln2.publisher_site) = t_pub_site(j)
                 AND Nvl(Upper(ln2.supplier_company),-99) = Nvl(t_supp(j),-99)
                 AND Nvl(Upper(ln2.supplier_site),-99) = Nvl(t_supp_site(j),-99)
                 AND Nvl(Upper(ln2.customer_company),-99) = Nvl(t_cust(j),-99)
                 AND Nvl(Upper(ln2.customer_site),-99) = Nvl(t_cust_site(j),-99)
                 AND Upper(ln2.order_type) = t_order_type_desc(j)
                 AND ln2.inventory_item_id = t_item_id(j)
                 AND Upper(ln2.bucket_type) = t_bucket_type(j)
                 AND t_key_date(j) = trunc(to_date(ln2.key_date,p_date_format))
		 ));
     END IF;

  END IF; /* if p_build_err <> 2 */

  --Added for bug 3103879
  log_debug('MSC_X_OVERWRITE_SC := ' || fnd_profile.value('MSC_X_OVERWRITE_SC'));
  IF (Nvl(fnd_profile.value('MSC_X_OVERWRITE_SC'),'N') = 'Y') THEN
     OPEN c_delete_supply_commit(p_header_id, p_language);
     FETCH c_delete_supply_commit
       bulk collect INTO t_del_pub_id,
       t_del_pub_site_id,
       t_del_cust_id,
       t_del_cust_site_id,
       t_del_item_id;
     CLOSE c_delete_supply_commit;
     IF t_del_pub_id IS NOT NULL AND t_del_pub_id.COUNT > 0 THEN
	forall j IN t_del_pub_id.first..t_del_pub_id.last
	  DELETE FROM msc_sup_dem_entries sd
	  WHERE sd.publisher_id = t_del_pub_id(j)
	  AND sd.publisher_site_id = t_del_pub_site_id(j)
	  AND sd.customer_id = t_del_cust_id(j)
	  AND sd.customer_site_id = t_del_cust_site_id(j)
	  AND sd.inventory_item_id = t_del_item_id(j)
	  AND sd.publisher_order_type = g_supply_commit;
     END IF;
  END IF;

  --Added for bug 3304493
  log_debug('MSC_X_OVERWRITE_OF := ' || G_OVERWRITE_OF);
  --log_debug('MSC_X_OVERWRITE_OF := ' || G_OVERWRITE_OF);
  IF (G_OVERWRITE_OF = 'Y') THEN
     OPEN c_delete_order_forecast(p_header_id, p_language);
     FETCH c_delete_order_forecast
       bulk collect INTO t_del_pub_id,
       t_del_pub_site_id,
       t_del_supp_id,
       t_del_supp_site_id,
       t_del_item_id;
     CLOSE c_delete_order_forecast;
     IF t_del_pub_id IS NOT NULL AND t_del_pub_id.COUNT > 0 THEN
	forall j IN t_del_pub_id.first..t_del_pub_id.last
	  DELETE FROM msc_sup_dem_entries sd
	  WHERE sd.publisher_id = t_del_pub_id(j)
	  AND sd.publisher_site_id = t_del_pub_site_id(j)
	  AND sd.supplier_id = t_del_supp_id(j)
	  AND sd.supplier_site_id = t_del_supp_site_id(j)
	  AND sd.inventory_item_id = t_del_item_id(j)
	  AND sd.publisher_order_type = G_ORDER_FORECAST;
     END IF;
  END IF;

  --===========================================================================
  -- Print error messages to the log file
  --===========================================================================

  FOR i IN 1..l_loops_reqd LOOP
     l_start_line := l_min + ((i-1)*G_BATCH_SIZE);
     IF ((l_min -1 + i*G_BATCH_SIZE) <= l_max) THEN
	l_end_line := l_min -1 + i*G_BATCH_SIZE;
      ELSE
	l_end_line := l_max;
     END IF;

     --=========================================================================
     -- Writing error messages to the log file
     --=========================================================================
     open c_err_msg(p_header_id, l_start_line, l_end_line);
     fetch c_err_msg bulk collect
       into  t_log_line_id,
             t_log_item_name,
             t_log_order_type,
             t_log_err_msg;
     close c_err_msg;

     if t_log_line_id is not null and t_log_line_id.COUNT > 0 then
	for j in t_log_line_id.FIRST..t_log_line_id.LAST loop
	   l_log_message :=
               substrb(get_message('MSC','MSC_X_UI_VOD_ORD_LINE_NUM',p_language),1,500) ||
               ': ' || to_char(t_log_line_id(j) - l_min + 1) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_ITEM',p_language),1,500) ||
               ': ' || t_log_item_name(j) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_SDD_ORDER_TYPE',p_language),1,500) ||
                 ': ' || t_log_order_type(j) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_LSD_ERROR', p_language),1,500) ||
               ': ' || t_log_err_msg(j) || fnd_global.local_chr(10) ;

	   log_message(l_log_message);
	end loop;
     end if;

  END LOOP;

END update_errors;


FUNCTION checkdates (
  p_header_id IN NUMBER,
  p_line_id   IN NUMBER,
  p_date_format IN VARCHAR2
) RETURN NUMBER IS
  DATE_FORMAT_ERROR EXCEPTION;
  PRAGMA EXCEPTION_INIT(DATE_FORMAT_ERROR, -1861);
  x_date1 DATE;
  x_date2 DATE;
  x_date3 DATE;
  x_date4 DATE;
  x_date5 DATE;
  x_date6 DATE;
  x_date7 DATE;
  /* Added for work order support */
  x_date8 DATE;
  x_date9 DATE;
BEGIN
 SELECT DECODE(ln.new_schedule_date, NULL, SYSDATE,
               to_date(ln.new_schedule_date, p_date_format)),
        DECODE(ln.new_schedule_end_date, NULL, SYSDATE,
               to_date(ln.new_schedule_end_date, p_date_format)),
        DECODE(ln.receipt_date, NULL, SYSDATE,
               to_date(ln.receipt_date, p_date_format)),
        DECODE(ln.ship_date, NULL, SYSDATE,
               to_date(ln.ship_date, p_date_format)),
        DECODE(ln.new_order_placement_date, NULL, SYSDATE,
               to_date(ln.new_order_placement_date, p_date_format)),
        DECODE(ln.request_date, NULL, SYSDATE,
               to_date(ln.request_date, p_date_format)),
        DECODE(ln.original_promised_date, NULL, SYSDATE,
               to_date(ln.original_promised_date, p_date_format)),
        DECODE(ln.wip_start_date, NULL, SYSDATE,
               to_date(ln.wip_start_date, p_date_format)),
        DECODE(ln.wip_end_date, NULL, SYSDATE,
               to_date(ln.wip_end_date, p_date_format))
 INTO   x_date1,
        x_date2,
        x_date3,
        x_date4,
        x_date5,
        x_date6,
        x_date7,
        x_date8,
        x_date9
 FROM   msc_supdem_lines_interface ln
 WHERE  ln.parent_header_id = p_header_id and
        ln.line_id = p_line_id;

 return 0;

EXCEPTION
  WHEN DATE_FORMAT_ERROR THEN
    return 1;
  WHEN OTHERS THEN
    return 1;
END CHECKDATES;


FUNCTION get_message (
  p_app  IN VARCHAR2,
  p_name IN VARCHAR2,
  p_lang IN VARCHAR2
) RETURN VARCHAR2 IS
  msg VARCHAR2(2000) := NULL;
  CURSOR c1(app_name VARCHAR2, msg_name VARCHAR2, lang VARCHAR2) IS
  SELECT m.message_text
  FROM   fnd_new_messages m,
         fnd_application a
  WHERE  m.message_name = msg_name AND
         m.language_code = lang AND
         a.application_short_name = app_name AND
         m.application_id = a.application_id;
BEGIN
  OPEN c1(p_app, p_name, p_lang);
  FETCH c1 INTO msg;
  IF (c1%NOTFOUND) then
    msg := p_name;
  END IF;
  CLOSE c1;
  RETURN msg;
END get_message;



PROCEDURE send_ntf (
  p_header_id IN NUMBER,
  p_file_name IN VARCHAR2,
  p_status    IN NUMBER,
  p_user_name IN VARCHAR2,
  p_event_key IN VARCHAR2
) IS
  parameter_list WF_PARAMETER_LIST_T;
  event_name VARCHAR2(50):= 'oracle.apps.msc.txn.loads';
  msg_txt  VARCHAR2(2000) := NULL;
  full_language VARCHAR2(80) := NULL;
  language VARCHAR2(10);
  msg_name VARCHAR2(40) := NULL;
  date_format VARCHAR2(80);
  mailDate VARCHAR2(80);
BEGIN
  log_debug('In send_ntf');
  --language := fnd_preference.get(UPPER(p_user_name),'WF','LANGUAGE');

/*  BUG #3845796 :Using Applications Session Language in preference to ICX_LANGUAGE profile value */

        language := USERENV('LANG');
	IF(language is null) THEN

	full_language := fnd_profile.value('ICX_LANGUAGE');

    IF full_language IS NOT NULL THEN
      SELECT language_code
      INTO   language
      FROM   fnd_languages
      WHERE  nls_language = full_language;
    ELSE
      language := 'US';
    END IF;
    END IF;
/*
  if language is null then
    language := 'US';
  end if;
*/
   date_format := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY');
   mailDate := to_char(sysdate, date_format) ;

  IF p_status = G_SUCCESS THEN
    msg_txt := get_message('MSC', 'MSC_X_LOADS_SUCCESS', language);
    msg_name := 'LOADS_SUCCESS_NTF';
  ELSIF p_status = G_FAILURE THEN
    msg_txt := build_error_string(p_header_id, language);
    msg_name := 'LOADS_ERROR_NTF';
  END IF;

  wf_event.AddParameterToList(p_name => 'USER_NAME',
                              p_value => p_user_name,
                              p_parameterlist => parameter_list);
  wf_event.AddParameterToList(p_name => 'MESG',
                              p_value => msg_name,
                              p_parameterlist => parameter_list);
  wf_event.AddParameterToList(p_name => 'MESG_BODY',
                              p_value => msg_txt,
                              p_parameterlist => parameter_list);
  wf_event.AddParameterToList(p_name => 'HEADER_ID',
                              p_value => p_header_id,
                              p_parameterlist => parameter_list);
  wf_event.AddParameterToList(p_name => 'CREATION_DATE',
                              p_value => mailDate,
                              p_parameterlist => parameter_list);
  wf_event.AddParameterToList(p_name => 'FILENAME',
                              p_value => p_file_name,
                              p_parameterlist => parameter_list);
  wf_event.raise(p_event_name => event_name,
                 p_event_key => p_event_key,
                 p_parameters => parameter_list);
END send_ntf;



FUNCTION build_error_string (
  p_header_id IN NUMBER,
  p_lang IN VARCHAR2
) RETURN VARCHAR2 IS

  CURSOR errors (header_id NUMBER) IS
  SELECT line_id,
         nvl(item_name, nvl(owner_item_name, nvl(supplier_item_name, customer_item_name))),
         substrb(err_msg,1,240),
         substrb(order_type,1,240),
         order_identifier,
         release_number,
         line_number
  FROM   msc_supdem_lines_interface
  WHERE  parent_header_id = header_id AND
         row_status = G_FAILURE;

  err_buf             VARCHAR2(2000) := NULL;
  line_id             NUMBER;
  min_line_id         NUMBER;
  err_msg             VARCHAR2(240);
  item_name           VARCHAR2(240);
  order_type          VARCHAR2(240);
  order_number        VARCHAR2(240);
  release_number      VARCHAR2(20);
  line_number         VARCHAR2(20);
BEGIN
  SELECT min(line_id)
  INTO   min_line_id
  FROM   msc_supdem_lines_interface
  WHERE  parent_header_id = p_header_id;

  OPEN errors(p_header_id);
  LOOP
    FETCH errors
    INTO  line_id,
          item_name,
          err_msg,
          order_type,
          order_number,
          release_number,
          line_number;
    EXIT WHEN errors%NOTFOUND OR lengthb(err_buf) > 1500;
    err_buf := err_buf || fnd_global.local_chr(10) ||
               substrb(get_message('MSC','MSC_X_UI_VOD_ORD_LINE_NUM',p_lang),1,40) ||
               ': ' || to_char(line_id - min_line_id + 1) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_ITEM',p_lang),1,40) ||
               ': ' || item_name || ', ' ;

    IF order_type IS NOT NULL THEN
      err_buf := err_buf || substrb(get_message('MSC','MSC_X_UI_SDD_ORDER_TYPE',p_lang),1,40) ||
                 ': ' || order_type || ', ';
    END IF;

    IF order_number IS NOT NULL THEN
      err_buf := err_buf || substrb(get_message('MSC','MSC_X_UI_SDD_TH_ORDER', p_lang),1,40) ||
                 ': ' || order_number || ', ';
    END IF;

    IF release_number IS NOT NULL THEN
      err_buf := err_buf || substrb(get_message('MSC','MSC_X_UI_VOD_ORD_REL_NUM', p_lang),1,40) ||
                 ': ' || release_number || ', ';
    END IF;

    IF line_number IS NOT NULL THEN
      err_buf := err_buf || substrb(get_message('MSC','MSC_X_UI_VOD_EX_ORD_LINE', p_lang),1,40) ||
                 ': ' || line_number || ', ';
    END IF;

    err_buf := err_buf || substrb(get_message('MSC','MSC_X_UI_LSD_ERROR', p_lang),1,40) ||
               ': ' || err_msg ;
    IF (lengthb(err_buf) > 1500) THEN
       err_buf := err_buf || fnd_global.local_chr(10) || substrb(get_message('MSC','MSC_X_API_ERRORS_STOPPED', p_lang),1,(2000 - lengthb(err_buf)));
    END IF;
  END LOOP;
  CLOSE errors;
  RETURN err_buf;
END build_error_string;



PROCEDURE validate (

  p_err_msg   OUT NOCOPY VARCHAR2,
  p_status    OUT NOCOPY NUMBER,
  p_header_id IN NUMBER,
  p_build_err IN NUMBER
) IS

-- Added fix for bug 2408610 (Sync'd up delete and replace behavior)

	/* sbala ADD CA */
   CURSOR c_delete
     (
      p_header_id NUMBER,
      p_language VARCHAR2,
      p_start_line NUMBER,
      p_end_line NUMBER,
      p_date_format VARCHAR2
      ) IS
	 select sd.transaction_id
	   from msc_supdem_lines_interface ln,
	   msc_companies c,
	   msc_company_sites s ,
	   fnd_lookup_values flv,
	   msc_sup_dem_entries sd
	   where  ln.parent_header_id = p_header_id and
	   ln.line_id between p_start_line and p_end_line and
	   NVL(ln.row_status, G_PROCESS) = G_SUCCESS and
	   UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
	   s.company_id = c.company_id and
	   UPPER(s.company_site_name) = UPPER(ln.publisher_site) and
	   flv.lookup_type = 'MSC_X_ORDER_TYPE' and
	   flv.language = p_language and
	   UPPER(flv.meaning) = UPPER(ln.order_type) and
	   UPPER(ln.sync_indicator) = 'D' and
	   sd.publisher_id = c.company_id and
	   sd.publisher_site_id = s.company_site_id AND

	   upper(nvl(sd.supplier_name,G_NULL_STRING)) = upper(nvl(ln.supplier_company,
								  nvl(sd.supplier_name,G_NULL_STRING))) and
	   upper(nvl(sd.supplier_site_name,G_NULL_STRING)) = upper(nvl(ln.supplier_site,
								       nvl(sd.supplier_site_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_name,G_NULL_STRING)) = upper(nvl(ln.customer_company,
								  nvl(sd.customer_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_site_name,G_NULL_STRING)) = upper(nvl(ln.customer_site,
								       nvl(sd.customer_site_name,G_NULL_STRING))) and
	   (
	    sd.item_name = NVL(ln.item_name,
			       Nvl(ln.owner_item_name,
				   Nvl(ln.customer_item_name, ln.supplier_item_name))) or
	    sd.owner_item_name = NVL(ln.owner_item_name,
				     Nvl(ln.item_name,
					 Nvl(ln.customer_item_name,ln.supplier_item_name))) or
	    sd.customer_item_name = NVL(ln.customer_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.supplier_item_name)))  or
	    sd.supplier_item_name = NVL(ln.supplier_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.customer_item_name)))
	    ) and
	   sd.publisher_order_type = flv.lookup_code and
	   sd.publisher_order_type in (G_SALES_FORECAST,
			       G_ORDER_FORECAST,
			       G_SUPPLY_COMMIT,
			       G_HIST_SALES,
			       G_SELL_THRO_FCST,
			       G_SUPPLIER_CAP,
			       G_SAFETY_STOCK,
			       G_INTRANSIT,
			       g_replenishment,
			       g_alloc_onhand,
			       g_unallocated_onhand,
			      g_proj_avai_bal,        --Consigned CVMI Enh : Bug # 4247230
	          decode(G_CVMI_PROFILE  , 'N' , G_CONS_ADVICE , null , G_CONS_ADVICE , -1  ))
	   and upper(nvl(sd.bucket_type_desc, G_NULL_STRING)) = upper(nvl(ln.bucket_type, Nvl(sd.bucket_type_desc,G_NULL_STRING)))
	   and sd.key_date between Decode(ln.key_date,NULL,sd.key_date, trunc(to_date(ln.key_date, p_date_format)))
		  and decode(ln.new_schedule_end_date, NULL, sd.key_date,trunc(to_date(ln.new_schedule_end_date, p_date_format)))
	   AND Nvl(sd.last_update_login,-1) <> G_DELETED
	   UNION
	   select sd.transaction_id
	   from msc_supdem_lines_interface ln,
	   msc_companies c,
	   msc_company_sites s ,
	   fnd_lookup_values flv,
	   msc_sup_dem_entries sd
	   where  ln.parent_header_id = p_header_id and
	   ln.line_id between p_start_line and p_end_line and
	   NVL(ln.row_status, G_PROCESS) = G_SUCCESS and
	   UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
	   s.company_id = c.company_id and
	   UPPER(s.company_site_name) = UPPER(ln.publisher_site) and
	   flv.lookup_type = 'MSC_X_ORDER_TYPE' and
	   flv.language = p_language and
         ---  flv.meaning = 'Consumption Advice' and
	   UPPER(flv.meaning) = UPPER(ln.order_type) and
	   UPPER(ln.sync_indicator) = 'D' and
	   sd.publisher_id = c.company_id and
	   sd.publisher_site_id = s.company_site_id and
	   upper(nvl(sd.supplier_name,G_NULL_STRING)) = upper(nvl(ln.supplier_company,
								  nvl(sd.supplier_name,G_NULL_STRING))) and
	   upper(nvl(sd.supplier_site_name,G_NULL_STRING)) = upper(nvl(ln.supplier_site,
								       nvl(sd.supplier_site_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_name,G_NULL_STRING)) = upper(nvl(ln.customer_company,
								  nvl(sd.customer_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_site_name,G_NULL_STRING)) = upper(nvl(ln.customer_site,
								       nvl(sd.customer_site_name,G_NULL_STRING))) and
	   (
	    sd.item_name = NVL(ln.item_name,
			       Nvl(ln.owner_item_name,
				   Nvl(ln.customer_item_name, ln.supplier_item_name))) or
	    sd.owner_item_name = NVL(ln.owner_item_name,
				     Nvl(ln.item_name,
					 Nvl(ln.customer_item_name,ln.supplier_item_name))) or
	    sd.customer_item_name = NVL(ln.customer_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.supplier_item_name)))  or
	    sd.supplier_item_name = NVL(ln.supplier_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.customer_item_name)))
	    ) and
	   sd.publisher_order_type = flv.lookup_code and
	   sd.publisher_order_type = G_WORK_ORDER
	   and sd.key_date = decode(ln.key_date, NULL,sd.key_date, Trunc(To_date(ln.key_date, p_date_format)))
	   and NVL(sd.order_number, G_NULL_STRING) = NVL(ln.order_identifier,Nvl(sd.order_number,G_NULL_STRING))
	   AND Nvl(sd.last_update_login,-1) <> G_DELETED
	   UNION
	   select sd.transaction_id
	   from msc_supdem_lines_interface ln,
	   msc_companies c,
	   msc_company_sites s ,
	   fnd_lookup_values flv,
	   msc_sup_dem_entries sd
	   where  ln.parent_header_id = p_header_id and
	   ln.line_id between p_start_line and p_end_line and
	   NVL(ln.row_status, G_PROCESS) = G_SUCCESS and
	   UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) and
	   s.company_id = c.company_id and
	   UPPER(s.company_site_name) = UPPER(ln.publisher_site) and
	   flv.lookup_type = 'MSC_X_ORDER_TYPE' and
	   flv.language = p_language and
	   UPPER(flv.meaning) = UPPER(ln.order_type) and
	   UPPER(ln.sync_indicator) = 'D' and
	   sd.publisher_id = c.company_id and
	   sd.publisher_site_id = s.company_site_id and
	   upper(nvl(sd.supplier_name,G_NULL_STRING)) = upper(nvl(ln.supplier_company,
								  nvl(sd.supplier_name,G_NULL_STRING))) and
	   upper(nvl(sd.supplier_site_name,G_NULL_STRING)) = upper(nvl(ln.supplier_site,
								       nvl(sd.supplier_site_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_name,G_NULL_STRING)) = upper(nvl(ln.customer_company,
								  nvl(sd.customer_name,G_NULL_STRING))) and
	   upper(nvl(sd.customer_site_name,G_NULL_STRING)) = upper(nvl(ln.customer_site,
								       nvl(sd.customer_site_name,G_NULL_STRING))) and
	   (
	    sd.item_name = NVL(ln.item_name,
			       Nvl(ln.owner_item_name,
				   Nvl(ln.customer_item_name, ln.supplier_item_name))) or
	    sd.owner_item_name = NVL(ln.owner_item_name,
				     Nvl(ln.item_name,
					 Nvl(ln.customer_item_name,ln.supplier_item_name))) or
	    sd.customer_item_name = NVL(ln.customer_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.supplier_item_name)))  or
	    sd.supplier_item_name = NVL(ln.supplier_item_name,
					Nvl(ln.item_name,
					    Nvl(ln.owner_item_name, ln.customer_item_name)))
	    ) and
	   sd.publisher_order_type = flv.lookup_code and
	   sd.publisher_order_type IN (G_PURCHASE_ORDER,
				 G_SALES_ORDER,
				 G_ASN,
				 G_SHIP_RECEIPT,
				 G_REQUISITION,
				 G_PO_ACKNOWLEDGEMENT,
		decode(G_CVMI_PROFILE  , 'Y' , G_CONS_ADVICE , -1 )) AND  --Consigned CVMI Enh
	   NVL(sd.order_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
						 g_purchase_order,
						 nvl(ln.order_identifier,G_NULL_STRING),
						 G_SALES_ORDER,
						 nvl(ln.order_identifier,G_NULL_STRING),
						 G_ASN,
						 nvl(ln.order_identifier,G_NULL_STRING),
						 G_SHIP_RECEIPT,
						 nvl(ln.order_identifier,G_NULL_STRING),
						 G_REQUISITION,
						 nvl(ln.order_identifier, G_NULL_STRING),
						 G_PO_ACKNOWLEDGEMENT,
						 nvl(ln.order_identifier, g_null_string),
						 G_CONS_ADVICE,
						 nvl(ln.order_identifier,G_NULL_STRING),
						 G_NULL_STRING) AND
	   NVL(sd.line_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
						g_purchase_order,
						nvl(ln.line_number, g_null_string),
						G_SALES_ORDER,
						nvl(ln.line_number, g_null_string),
						G_ASN,
						nvl(ln.line_number, g_null_string),
						G_SHIP_RECEIPT,
						Nvl(ln.line_number, g_null_string),
						G_REQUISITION,
						Nvl(ln.line_number, g_null_string),
						G_PO_ACKNOWLEDGEMENT,
						Nvl(ln.line_number, g_null_string),
						G_CONS_ADVICE,
						nvl(ln.line_number, g_null_string),
						G_NULL_STRING) AND
	   NVL(sd.release_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
						 g_purchase_order,
						 Nvl(ln.release_number, g_null_string),
						 G_SALES_ORDER,
						 Nvl(ln.release_number, g_null_string),
						 G_ASN,
						 Nvl(ln.release_number, g_null_string),
						 G_SHIP_RECEIPT,
						 Nvl(ln.release_number, g_null_string),
						 G_REQUISITION,
						 Nvl(ln.release_number, g_null_string),
						 G_PO_ACKNOWLEDGEMENT,
						 Nvl(ln.release_number, g_null_string),
						 G_CONS_ADVICE,
						 Nvl(ln.release_number, g_null_string),
						 G_NULL_STRING) AND
	   NVL(sd.end_order_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
						   g_purchase_order,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_SALES_ORDER,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_ASN,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_SHIP_RECEIPT,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_REQUISITION,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_PO_ACKNOWLEDGEMENT,
						  Nvl(ln.pegging_order_identifier, g_null_string),
						   G_CONS_ADVICE,
						   Nvl(ln.pegging_order_identifier, g_null_string),
						   G_NULL_STRING) AND
	   NVL(sd.end_order_rel_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
						       g_purchase_order,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_SALES_ORDER,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_ASN,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_SHIP_RECEIPT,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_REQUISITION,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_PO_ACKNOWLEDGEMENT,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_CONS_ADVICE,
						       Nvl(ln.ref_release_number, g_null_string),
						       G_NULL_STRING) AND
	   NVL(sd.end_order_line_number, G_NULL_STRING) = Decode(sd.publisher_order_type,
							g_purchase_order,
							Nvl(ln.ref_line_number, g_null_string),
							G_SALES_ORDER,
							Nvl(ln.ref_line_number, g_null_string),
							G_ASN,
							Nvl(ln.ref_line_number, g_null_string),
							G_SHIP_RECEIPT,
							Nvl(ln.ref_line_number, g_null_string),
							G_REQUISITION,
							Nvl(ln.ref_line_number, g_null_string),
							G_PO_ACKNOWLEDGEMENT,
							Nvl(ln.ref_line_number, g_null_string),
							 G_CONS_ADVICE,
							 Nvl(ln.ref_line_number, g_null_string),
							G_NULL_STRING) and
	   Nvl(sd.last_update_login,-1) <> G_DELETED;

  /* Added for work order support */

  CURSOR c_work_order_without_cust(
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         ln.customer_company,
         ln.customer_company,
         ln.customer_site,
         ln.customer_site,
         ln.customer_address,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         null,
         --ln.end_order_type,
         --ln.bucket_type,
         flv.meaning,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         null,
         null,
         null,
/*
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
*/
         DECODE(ln.key_date, NULL, NULL,
                to_date(ln.key_date, p_date_format)),
         DECODE(ln.new_schedule_date, NULL, NULL,
                to_date(ln.new_schedule_date, p_date_format)),
         DECODE(ln.ship_date, NULL, NULL,
                to_date(ln.ship_date, p_date_format)),
         DECODE(ln.receipt_date, NULL, NULL,
                to_date(ln.receipt_date, p_date_format)),
         DECODE(ln.new_order_placement_date, NULL, NULL,
                to_date(ln.new_order_placement_date, p_date_format)),
         DECODE(ln.original_promised_date, NULL, NULL,
                to_date(ln.original_promised_date, p_date_format)),
         DECODE(ln.request_date,NULL,NULL,
                to_date(ln.request_date,p_date_format)),
         Decode(ln.wip_start_date, NULL, NULL,
                to_date(ln.wip_start_date,p_date_format)),
         Decode(ln.wip_end_date, NULL, NULL,
                to_date(ln.wip_end_date,p_date_format)),
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         ln.customer_company IS NULL and
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         flv.language = p_language AND
	 flv.lookup_code = g_day and
	 flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
	 flv1.language = p_language AND
	 UPPER(flv1.meaning) = UPPER(ln.order_type) AND
	 flv1.lookup_code = G_WORK_ORDER AND
	 UPPER(ln.sync_indicator) = 'R';

	 CURSOR c_work_order_with_cust(
	    p_header_id  NUMBER,
	    p_language   VARCHAR2,
	    p_start_line NUMBER,
	    p_end_line   NUMBER,
	    p_date_format VARCHAR2
	  ) IS
	  SELECT ln.line_id ,
		 c.company_name,
		 c.company_id,
		 s.company_site_name,
		 s.company_site_id,
		 ln.publisher_address,
		 c1.company_name,
		 c1.company_id,
		 s1.company_site_name,
		 s1.company_site_id,
		 ln.customer_address,
		 c.company_name,
		 c.company_id,
		 s.company_site_name,
		 s.company_site_id,
		 ln.supplier_address,
		 ln.ship_from_party_name,
		 ln.ship_from_party_site,
		 ln.ship_from_party_address,
		 ln.ship_to_party_name,
		 ln.ship_to_party_site,
		 ln.ship_to_party_address,
		 ln.ship_to_address,
		 ln.end_order_publisher_name,
		 ln.end_order_publisher_site,
		 flv1.lookup_code,
		 flv1.meaning,
		 null,
		 --ln.end_order_type,
		 --ln.bucket_type,
		 flv.meaning,
		 flv.lookup_code,
		 ln.inventory_item_id,
		 ln.order_identifier,
		 ln.line_number,
		 ln.release_number,
		 null,
		 null,
			  null,
	/*
		 ln.pegging_order_identifier,
		 ln.ref_line_number,
		 ln.ref_release_number,
	*/
		 DECODE(ln.key_date, NULL, NULL,
			to_date(ln.key_date, p_date_format)),
		 DECODE(ln.new_schedule_date, NULL, NULL,
			to_date(ln.new_schedule_date, p_date_format)),
		 DECODE(ln.ship_date, NULL, NULL,
			to_date(ln.ship_date, p_date_format)),
		 DECODE(ln.receipt_date, NULL, NULL,
			to_date(ln.receipt_date, p_date_format)),
		 DECODE(ln.new_order_placement_date, NULL, NULL,
			to_date(ln.new_order_placement_date, p_date_format)),
		 DECODE(ln.original_promised_date, NULL, NULL,
			to_date(ln.original_promised_date, p_date_format)),
		 DECODE(ln.request_date,NULL,NULL,
			to_date(ln.request_date,p_date_format)),
		 Decode(ln.wip_start_date, NULL, NULL,
			to_date(ln.wip_start_date,p_date_format)),
		 Decode(ln.wip_end_date, NULL, NULL,
			to_date(ln.wip_end_date,p_date_format)),
		 round(ln.quantity, 6),
		 ln.uom,
		 ln.comments,
		 ln.carrier_code,
		 ln.bill_of_lading_number,
		 ln.tracking_number,
		 ln.vehicle_number,
		 ln.container_type,
		 round(ln.container_qty, 6),
		 ln.serial_number,
		 ln.attachment_url,
		 ln.version,
		 ln.designator,
		 ln.context,
		 ln.attribute1,
		 ln.attribute2,
		 ln.attribute3,
		 ln.attribute4,
		 ln.attribute5,
		 ln.attribute6,
		 ln.attribute7,
		 ln.attribute8,
		 ln.attribute9,
		 ln.attribute10,
		 ln.attribute11,
		 ln.attribute12,
		 ln.attribute13,
		 ln.attribute14,
		 ln.attribute15,
		 ln.posting_party_name
	  FROM   msc_supdem_lines_interface ln,
		 fnd_lookup_values flv,
		 fnd_lookup_values flv1,
		 msc_companies c,
		 msc_company_sites s,
		 msc_companies c1,
		 msc_company_sites s1,
		 msc_company_relationships r
	  WHERE  ln.parent_header_id = p_header_id AND
		 ln.line_id between p_start_line and p_end_line AND
		 NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
		 UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
		 s.company_id = c.company_id AND
		 UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
		 ln.customer_company IS NOT NULL AND
		 UPPER(c1.company_name) = UPPER(ln.customer_company) AND
		 r.subject_id = c.company_id AND
		 r.object_id = c1.company_id AND
		 r.relationship_type = 1 AND
		 s1.company_id = c1.company_id AND
		 UPPER(s1.company_site_name) = UPPER(ln.customer_site) AND
		 flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
		 flv.language = p_language AND
		 flv.lookup_code = g_day and
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         flv1.lookup_code = G_WORK_ORDER AND
         UPPER(ln.sync_indicator) = 'R';

  CURSOR c_unallocated_onhand(
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         ln.customer_company,
         ln.customer_company,
         ln.customer_site,
         ln.customer_site,
         ln.customer_address,
         ln.supplier_company,
         ln.supplier_company,
         ln.supplier_site,
         ln.supplier_site,
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
	 decode(lookup_code, G_CONS_ADVICE,NVL(ln.bucket_type,G_DAY_DESC),
                      NULL),
         NULL,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
	 /* for bug# 3271374, populate the new_schedule_date as key_date for unallocated OH */
         DECODE(ln.new_schedule_date, NULL, NULL,
                to_date(ln.new_schedule_date, p_date_format)),
         DECODE(ln.new_schedule_date, NULL, NULL,
                to_date(ln.new_schedule_date, p_date_format)),
         DECODE(ln.ship_date, NULL, NULL,
                to_date(ln.ship_date, p_date_format)),
         DECODE(ln.receipt_date, NULL, NULL,
                to_date(ln.receipt_date, p_date_format)),
         DECODE(ln.new_order_placement_date, NULL, NULL,
                to_date(ln.new_order_placement_date, p_date_format)),
         DECODE(ln.original_promised_date, NULL, NULL,
                to_date(ln.original_promised_date, p_date_format)),
         DECODE(ln.request_date,NULL,NULL,
                to_date(ln.request_date,p_date_format)),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         flv1.lookup_code IN (g_unallocated_onhand,
				G_CONS_ADVICE) AND
         UPPER(ln.sync_indicator) = 'R';

  CURSOR c_bktless_key (
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         decode(ln.customer_company, NULL, c.company_name, c1.company_name),
         decode(ln.customer_company, NULL, c.company_id, c1.company_id),
         decode(ln.customer_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.customer_site, NULL, s.company_site_id, s1.company_site_id),
         ln.customer_address,
         decode(ln.supplier_company, NULL, c.company_name, c1.company_name),
         decode(ln.supplier_company, NULL, c.company_id, c1.company_id),
         decode(ln.supplier_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.supplier_site, NULL, s.company_site_id, s1.company_site_id),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         --Fix for bug 2606288 (Default bucket type to day for planning order types)
         Decode(flv1.lookup_code,
		g_purchase_order, to_number(NULL),
		G_SALES_ORDER, to_number(NULL),
		G_ASN, to_number(NULL),
		G_SHIP_RECEIPT, to_number(NULL),
		G_REQUISITION, to_number(NULL),
		G_PO_ACKNOWLEDGEMENT, to_number(NULL),
		G_DAY),
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
         DECODE(ln.key_date, NULL,to_date(NULL),
                to_date(ln.key_date, p_date_format)),
         DECODE(ln.new_schedule_date, NULL,to_date(NULL),
                to_date(ln.new_schedule_date, p_date_format)),
         DECODE(ln.ship_date, NULL,to_date(NULL),
                to_date(ln.ship_date, p_date_format)),
         DECODE(ln.receipt_date, NULL,to_date(NULL),
                to_date(ln.receipt_date, p_date_format)),
         DECODE(ln.new_order_placement_date, NULL,to_date(NULL),
                to_date(ln.new_order_placement_date, p_date_format)),
         DECODE(ln.original_promised_date, NULL,to_date(NULL),
                to_date(ln.original_promised_date, p_date_format)),
         DECODE(ln.request_date,NULL,to_date(NULL),
                to_date(ln.request_date,p_date_format)),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s,
         msc_companies c1,
         msc_company_sites s1,
         msc_company_relationships r
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         ln.bucket_type IS NULL AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         UPPER(c1.company_name) = UPPER(NVL(ln.customer_company, ln.supplier_company)) AND
         r.subject_id = c.company_id AND
         r.object_id = c1.company_id AND
         r.relationship_type = DECODE(ln.customer_company,NULL,2,1) AND
         s1.company_id = c1.company_id AND
         UPPER(s1.company_site_name) = UPPER(NVL(ln.customer_site, ln.supplier_site)) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
	 flv1.language = p_language AND
	 /* Added for work order support */
         flv1.lookup_code <> G_WORK_ORDER AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
	 UPPER(ln.sync_indicator) = 'R'
  UNION
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
	 ln.customer_company,
	 to_number(NULL),
	 ln.customer_site,
	 to_number(NULL),
         ln.customer_address,
         ln.supplier_company,
         to_number(NULL),
         ln.supplier_site,
         to_number(NULL),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         --Fix for bug 2606288 (Default bucket type to day for planning order types)
         Decode(flv1.lookup_code,
		g_purchase_order, to_number(NULL),
		G_SALES_ORDER, to_number(NULL),
		G_ASN, to_number(NULL),
		G_SHIP_RECEIPT, to_number(NULL),
		G_REQUISITION, to_number(NULL),
		G_PO_ACKNOWLEDGEMENT, to_number(NULL),
		G_DAY),
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
         DECODE(ln.key_date, NULL, to_date(NULL),
                to_date(ln.key_date, p_date_format)),
         DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                to_date(ln.new_schedule_date, p_date_format)),
         DECODE(ln.ship_date, NULL, to_date(NULL),
                to_date(ln.ship_date, p_date_format)),
         DECODE(ln.receipt_date, NULL, to_date(NULL),
                to_date(ln.receipt_date, p_date_format)),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL),
                to_date(ln.new_order_placement_date, p_date_format)),
         DECODE(ln.original_promised_date, NULL, to_date(NULL),
                to_date(ln.original_promised_date, p_date_format)),
         DECODE(ln.request_date,NULL,to_date(NULL),
                to_date(ln.request_date,p_date_format)),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         ln.bucket_type IS NULL AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
	 flv1.language = p_language AND
         flv1.lookup_code in (g_safety_stock, g_proj_avai_bal) AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
	 UPPER(ln.sync_indicator) = 'R';

  CURSOR c_daily_bkt_key (
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT DISTINCT ln.line_id,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         decode(ln.customer_company, NULL, c.company_name, c1.company_name),
         decode(ln.customer_company, NULL, c.company_id, c1.company_id),
         decode(ln.customer_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.customer_site, NULL, s.company_site_id, s1.company_site_id),
         ln.customer_address,
         decode(ln.supplier_company, NULL, c.company_name, c1.company_name),
         decode(ln.supplier_company, NULL, c.company_id, c1.company_id),
         decode(ln.supplier_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.supplier_site, NULL, s.company_site_id, s1.company_site_id),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
         mlb.bucket_date,
         DECODE(flv1.lookup_code, /* sbala ADD CA */
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
	        G_CONS_ADVICE, mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, NULL,
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT,  -- SBALACHANGE
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
			 2, mlb.bucket_date,
		 decode(ln.ship_date, null, null, decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                         trunc(to_date(ln.ship_date, p_date_format))))),
                G_ASN,
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
                         2, trunc(to_date(ln.ship_date,p_date_format)),
	decode(ln.ship_date, null, to_date(null), decode(ln.receipt_date, null,
						mlb.bucket_date,
		trunc(to_date(ln.ship_date,p_date_format))))),
                G_SALES_FORECAST,
                  DECODE(ln.shipping_control,
			 1, mlb.bucket_date,
			 2, mlb.bucket_date,
			 decode(ln.ship_date, null, to_date(null), mlb.bucket_date)),
                G_SALES_ORDER,
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
			 2, mlb.bucket_date,
	        decode(ln.ship_date, null, to_date(null), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                                trunc(to_date(ln.ship_date,p_date_format))))),
                G_PURCHASE_ORDER,
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
			 2, mlb.bucket_date,
			 to_date(null)),
                G_SHIP_RECEIPT, to_date(null),
                G_ORDER_FORECAST,
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
			 2, mlb.bucket_date,
			 to_date(null)),
                G_REQUISITION,
		  DECODE(ln.shipping_control,
			 1, trunc(to_date(ln.ship_date,p_date_format)),
			 2, mlb.bucket_date,
			 to_date(null)),
                DECODE(ln.ship_date, NULL, to_date(null),
                       trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST,
		 DECODE(ln.shipping_control,
			1, mlb.bucket_date,
			2, trunc(to_date(ln.receipt_date, p_date_format)),
			mlb.bucket_date),
                G_PURCHASE_ORDER,
		  DECODE(ln.shipping_control,
			1, mlb.bucket_date,
			2, trunc(to_date(ln.receipt_date, p_date_format)),
			mlb.bucket_date),
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION,
	       	  DECODE(ln.shipping_control,
			1, mlb.bucket_date,
			2, trunc(to_date(ln.receipt_date, p_date_format)),
		        mlb.bucket_date),
                G_SUPPLY_COMMIT,
		  DECODE(ln.shipping_control,
		        1, mlb.bucket_date,
			2, trunc(to_date(ln.receipt_date, p_date_format)),
	               decode(ln.receipt_date, null, to_date(null), mlb.bucket_date)),
                G_ASN,
		DECODE(ln.shipping_control,
	               1, mlb.bucket_date,
		       2, mlb.bucket_date,
		decode(ln.receipt_date, null, to_date(null), mlb.bucket_date)),
                G_SALES_FORECAST,
		DECODE(ln.shipping_control,
		       1, trunc(to_date(ln.receipt_date, p_date_format)),
	               2, trunc(to_date(ln.receipt_date, p_date_format)),
	decode(ln.receipt_date, null, to_date(null), decode(ln.ship_date, null, mlb.bucket_date, to_date(null)))),
                G_SALES_ORDER,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
		2, trunc(to_date(ln.receipt_date, p_date_format)),
		decode(ln.receipt_date, null, to_date(null), mlb.bucket_date)),
                DECODE(ln.receipt_date, NULL, to_date(NULL),
                       trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL),
                trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL),
                trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL),
                trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
	 MSC_LOAD_BUCKETS_TEMP  mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s,
         msc_companies c1,
         msc_company_sites s1,
         msc_company_relationships r
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_DAY AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         UPPER(c1.company_name) = UPPER(NVL(ln.customer_company, ln.supplier_company)) AND
         r.subject_id = c.company_id AND
         r.object_id = c1.company_id AND
         r.relationship_type = DECODE(ln.customer_company,NULL,2,1) AND
         s1.company_id = c1.company_id AND
	 UPPER(s1.company_site_name) = UPPER(NVL(ln.customer_site, ln.supplier_site)) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         /* Added for work order support */
         flv1.lookup_code <> g_work_order
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
         AND UPPER(ln.sync_indicator) = 'R'
  UNION
  SELECT DISTINCT ln.line_id,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         ln.customer_company,
         to_number(NULL),
         ln.customer_site,
         to_number(NULL),
         ln.customer_address,
         ln.supplier_company,
         to_number(NULL),
         ln.supplier_site,
         to_number(NULL),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
         mlb.bucket_date,
         DECODE(flv1.lookup_code, /* sbala ADD CA */
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
	        G_CONS_ADVICE, mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_ASN, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_FORECAST, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_ORDER, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_PURCHASE_ORDER, to_date(NULL),
                G_SHIP_RECEIPT, to_date(NULL),
                G_ORDER_FORECAST, to_date(NULL),
                G_REQUISITION, to_date(NULL),
                DECODE(ln.ship_date, NULL, to_date(NULL),
                       trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST, mlb.bucket_date,
                G_PURCHASE_ORDER, mlb.bucket_date,
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_ASN, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_FORECAST, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_ORDER, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                DECODE(ln.receipt_date, NULL, to_date(NULL), trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL), trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL), trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL), trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
	 MSC_LOAD_BUCKETS_TEMP  mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_DAY AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         flv1.lookup_code in (g_safety_stock, g_proj_avai_bal)
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
         AND UPPER(ln.sync_indicator) = 'R';

  CURSOR c_weekly_bkt_key (
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         decode(ln.customer_company, NULL, c.company_name, c1.company_name),
         decode(ln.customer_company, NULL, c.company_id, c1.company_id),
         decode(ln.customer_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.customer_site, NULL, s.company_site_id, s1.company_site_id),
         ln.customer_address,
         decode(ln.supplier_company, NULL, c.company_name, c1.company_name),
         decode(ln.supplier_company, NULL, c.company_id, c1.company_id),
         decode(ln.supplier_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.supplier_site, NULL, s.company_site_id, s1.company_site_id),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
	 mlb.bucket_date,   /* sbala ADD CA */
         DECODE(flv1.lookup_code,
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
	        G_CONS_ADVICE, mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT,
		DECODE(ln.shipping_control,
	           1, trunc(to_date(ln.ship_date, p_date_format)),
	           2, mlb.bucket_date,
		   decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                               trunc(to_date(ln.ship_date, p_date_format))))),
                G_ASN,
		DECODE(ln.shipping_control,
		  1, trunc(to_date(ln.ship_date, p_date_format)),
	          2, trunc(to_date(ln.ship_date, p_date_format)),
		decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                            trunc(to_date(ln.ship_date, p_date_format))))),
                G_SALES_FORECAST,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
                2, mlb.bucket_date,
	        decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date)),
                G_SALES_ORDER,
		DECODE(ln.shipping_control,
                1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
	         decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                                trunc(to_date(ln.ship_date, p_date_format))))),
                G_PURCHASE_ORDER,
	        decode(ln.shipping_control,
                1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
                to_date(NULL)),
                G_SHIP_RECEIPT, to_date(NULL),
                G_ORDER_FORECAST,
		decode(ln.shipping_control,
                1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
                to_date(NULL)),
                G_REQUISITION,
                decode(ln.shipping_control,
                1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
                to_date(NULL)),
                DECODE(ln.ship_date, NULL, to_date(NULL),
                       trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
                2,trunc(to_date(ln.receipt_date, p_date_format)),
                mlb.bucket_date),
                G_PURCHASE_ORDER,
		DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2, trunc(to_date(ln.receipt_date, p_date_format)),
                mlb.bucket_date),
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION,
                DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2, trunc(to_date(ln.receipt_date, p_date_format)),
                mlb.bucket_date),
                G_SUPPLY_COMMIT,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
		2, trunc(to_date(ln.receipt_date, p_date_format)),
	        decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                G_ASN,
                DECODE(ln.shipping_control,
		1, mlb.bucket_date,
                2, mlb.bucket_date,
                decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                G_SALES_FORECAST,
		DECODE(ln.shipping_control,
	        1, trunc(to_date(ln.receipt_date, p_date_format)),
                2, trunc(to_date(ln.receipt_date, p_date_format)),
                decode(ln.receipt_date, null, to_date(NULL),
		decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL)))),
                G_SALES_ORDER,
		DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2, trunc(to_date(ln.receipt_date, p_date_format)),
	        decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                DECODE(ln.receipt_date, NULL, to_date(NULL), trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL), trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL), trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL), trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
	 MSC_LOAD_BUCKETS_TEMP  mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s,
         msc_companies c1,
         msc_company_sites s1,
         msc_company_relationships r
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_WEEK AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         UPPER(c1.company_name) = UPPER(NVL(ln.customer_company, ln.supplier_company)) AND
         r.subject_id = c.company_id AND
         r.object_id = c1.company_id AND
         r.relationship_type = DECODE(ln.customer_company,NULL,2,1) AND
         s1.company_id = c1.company_id AND
         UPPER(s1.company_site_name) = UPPER(NVL(ln.customer_site, ln.supplier_site)) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         /* Added for work order support */
         flv1.lookup_code <> g_work_order
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
         AND UPPER(ln.sync_indicator) = 'R'
  UNION
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         ln.customer_company,
         to_number(NULL),
         ln.customer_site,
         to_number(NULL),
         ln.customer_address,
         ln.supplier_company,
         to_number(NULL),
         ln.supplier_site,
         to_number(NULL),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
	 mlb.bucket_date,  /* sbala ADD CA */
         DECODE(flv1.lookup_code,
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
	        G_CONS_ADVICE, mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_ASN, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_FORECAST, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_ORDER, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_PURCHASE_ORDER, to_date(NULL),
                G_SHIP_RECEIPT, to_date(NULL),
                G_ORDER_FORECAST, to_date(NULL),
                G_REQUISITION, to_date(NULL),
                DECODE(ln.ship_date, NULL, to_date(NULL),
                       trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST, mlb.bucket_date,
                G_PURCHASE_ORDER, mlb.bucket_date,
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_ASN, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_FORECAST, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_ORDER, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                DECODE(ln.receipt_date, NULL, to_date(NULL), trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL), trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL), trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL), trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
	 MSC_LOAD_BUCKETS_TEMP  mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_WEEK AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         flv1.lookup_code IN (g_safety_stock, g_proj_avai_bal)
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
	 AND UPPER(ln.sync_indicator) = 'R';

  CURSOR c_monthly_bkt_key (
    p_header_id  NUMBER,
    p_language   VARCHAR2,
    p_start_line NUMBER,
    p_end_line   NUMBER,
    p_date_format VARCHAR2
  ) IS
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         decode(ln.customer_company, NULL, c.company_name, c1.company_name),
         decode(ln.customer_company, NULL, c.company_id, c1.company_id),
         decode(ln.customer_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.customer_site, NULL, s.company_site_id, s1.company_site_id),
         ln.customer_address,
         decode(ln.supplier_company, NULL, c.company_name, c1.company_name),
         decode(ln.supplier_company, NULL, c.company_id, c1.company_id),
         decode(ln.supplier_site, NULL, s.company_site_name, s1.company_site_name),
         decode(ln.supplier_site, NULL, s.company_site_id, s1.company_site_id),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
	 mlb.bucket_date,  /* sbala ADD CA */
         DECODE(flv1.lookup_code,
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
	        G_CONS_ADVICE, mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT,
		DECODE(ln.shipping_control,
		1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
                decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                             trunc(to_date(ln.ship_date, p_date_format))))),
                G_ASN,
		DECODE(ln.shipping_control,
		1,  trunc(to_date(ln.ship_date, p_date_format)),
                2,   trunc(to_date(ln.ship_date, p_date_format)),
                decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                             trunc(to_date(ln.ship_date, p_date_format))))),
                G_SALES_FORECAST,
                DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2, mlb.bucket_date,
                decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date)),
                G_SALES_ORDER,
		DECODE(ln.shipping_control,
		1,  trunc(to_date(ln.ship_date, p_date_format)),
	        2, mlb.bucket_date,
		decode(ln.ship_date, null, to_date(NULL), decode(ln.receipt_date, null,
                                                mlb.bucket_date,
                          trunc(to_date(ln.ship_date, p_date_format))))),
                G_PURCHASE_ORDER,
                DECODE(ln.shipping_control,
		1,  trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
                to_date(NULL)),
                G_SHIP_RECEIPT, to_date(NULL),
                G_ORDER_FORECAST,
                DECODE(ln.shipping_control,
		1, trunc(to_date(ln.ship_date, p_date_format)),
                2, mlb.bucket_date,
		to_date(NULL)),
                G_REQUISITION,
		DECODE(ln.shipping_control,
		1, trunc(to_date(ln.ship_date, p_date_format)),
		2, mlb.bucket_date,
		to_date(NULL)),
                DECODE(ln.ship_date, NULL, to_date(NULL),
                       trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
		2,  trunc(to_date(ln.receipt_date, p_date_format)),
		mlb.bucket_date),
                G_PURCHASE_ORDER,
		DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2, trunc(to_date(ln.receipt_date, p_date_format)),
                mlb.bucket_date),
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION,
		DECODE(ln.shipping_control,
                1, mlb.bucket_date,
                2,  trunc(to_date(ln.receipt_date, p_date_format)),
                mlb.bucket_date),
                G_SUPPLY_COMMIT,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
                2,  trunc(to_date(ln.receipt_date, p_date_format)),
		decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                G_ASN,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
		2, mlb.bucket_date,
		decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                G_SALES_FORECAST,
		DECODE(ln.shipping_control,
		1,  trunc(to_date(ln.receipt_date, p_date_format)),
		2,  trunc(to_date(ln.receipt_date, p_date_format)),
		decode(ln.receipt_date, null, to_date(NULL),
		decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL)))),
                G_SALES_ORDER,
		DECODE(ln.shipping_control,
		1, mlb.bucket_date,
		2,  trunc(to_date(ln.receipt_date, p_date_format)),
		decode(ln.receipt_date, null, to_date(NULL), mlb.bucket_date)),
                DECODE(ln.receipt_date, NULL, to_date(NULL), trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL), trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL), trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL), trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         MSC_LOAD_BUCKETS_TEMP mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s,
         msc_companies c1,
         msc_company_sites s1,
         msc_company_relationships r
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_MONTH AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         UPPER(c1.company_name) = UPPER(NVL(ln.customer_company, ln.supplier_company)) AND
         r.subject_id = c.company_id AND
         r.object_id = c1.company_id AND
         r.relationship_type = DECODE(ln.customer_company,NULL,2,1) AND
         s1.company_id = c1.company_id AND
         UPPER(s1.company_site_name) = UPPER(NVL(ln.customer_site, ln.supplier_site)) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         /* Added for work order support */
         flv1.lookup_code <> g_work_order
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
         AND UPPER(ln.sync_indicator) = 'R'
  UNION
  SELECT ln.line_id ,
         c.company_name,
         c.company_id,
         s.company_site_name,
         s.company_site_id,
         ln.publisher_address,
         ln.customer_company,
         to_number(null),
         ln.customer_site,
         to_number(null),
         ln.customer_address,
         ln.supplier_company,
         to_number(null),
         ln.supplier_site,
         to_number(null),
         ln.supplier_address,
         ln.ship_from_party_name,
         ln.ship_from_party_site,
         ln.ship_from_party_address,
         ln.ship_to_party_name,
         ln.ship_to_party_site,
         ln.ship_to_party_address,
         ln.ship_to_address,
         ln.end_order_publisher_name,
         ln.end_order_publisher_site,
         flv1.lookup_code,
         flv1.meaning,
         ln.end_order_type,
         ln.bucket_type,
         flv.lookup_code,
         ln.inventory_item_id,
         ln.order_identifier,
         ln.line_number,
         ln.release_number,
         ln.pegging_order_identifier,
         ln.ref_line_number,
         ln.ref_release_number,
	 mlb.bucket_date,  /* sbala ADD CA */
         DECODE(flv1.lookup_code,
                G_HIST_SALES, mlb.bucket_date,
                G_SAFETY_STOCK, mlb.bucket_date,
                G_ALLOC_ONHAND, mlb.bucket_date,
                G_UNALLOCATED_ONHAND, mlb.bucket_date,
		G_CONS_ADVICE,mlb.bucket_date,
		g_proj_avai_bal, mlb.bucket_date,
                DECODE(ln.new_schedule_date, NULL, to_date(NULL),
                       trunc(to_date(ln.new_schedule_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_SELL_THRO_FCST, mlb.bucket_date,
                G_SUPPLIER_CAP, mlb.bucket_date,
                G_PROJ_SS, mlb.bucket_date,
                G_PROJ_ALLOC_AVAIL, mlb.bucket_date,
                G_PROJ_UNALLOC_AVAIL, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_ASN, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_FORECAST, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_SALES_ORDER, decode(ln.ship_date, null, to_date(NULL), mlb.bucket_date),
                G_PURCHASE_ORDER, to_date(NULL),
                G_SHIP_RECEIPT, to_date(NULL),
                G_ORDER_FORECAST, to_date(NULL),
                G_REQUISITION, to_date(NULL),
                DECODE(ln.ship_date, NULL, to_date(NULL), trunc(to_date(ln.ship_date, p_date_format)))),
         DECODE(flv1.lookup_code,
                G_ORDER_FORECAST, mlb.bucket_date,
                G_PURCHASE_ORDER, mlb.bucket_date,
                G_SHIP_RECEIPT, mlb.bucket_date,
                G_REQUISITION, mlb.bucket_date,
                G_SUPPLY_COMMIT, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_ASN, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_FORECAST, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                G_SALES_ORDER, decode(ln.receipt_date, null, to_date(NULL), decode(ln.ship_date, null, mlb.bucket_date, to_date(NULL))),
                DECODE(ln.receipt_date, NULL, to_date(NULL), trunc(to_date(ln.receipt_date, p_date_format)))),
         DECODE(ln.new_order_placement_date, NULL, to_date(NULL), trunc(to_date(ln.new_order_placement_date, p_date_format))),
         DECODE(ln.original_promised_date, NULL, to_date(NULL), trunc(to_date(ln.original_promised_date, p_date_format))),
         DECODE(ln.request_date, NULL, to_date(NULL), trunc(to_date(ln.request_date, p_date_format))),
         NULL,
         NULL,
         round(ln.quantity, 6),
         ln.uom,
         ln.comments,
         ln.carrier_code,
         ln.bill_of_lading_number,
         ln.tracking_number,
         ln.vehicle_number,
         ln.container_type,
         round(ln.container_qty, 6),
         ln.serial_number,
         ln.attachment_url,
         ln.version,
         ln.designator,
         ln.context,
         ln.attribute1,
         ln.attribute2,
         ln.attribute3,
         ln.attribute4,
         ln.attribute5,
         ln.attribute6,
         ln.attribute7,
         ln.attribute8,
         ln.attribute9,
         ln.attribute10,
         ln.attribute11,
         ln.attribute12,
         ln.attribute13,
         ln.attribute14,
         ln.attribute15,
         ln.posting_party_name
  FROM   msc_supdem_lines_interface ln,
         MSC_LOAD_BUCKETS_TEMP mlb,
         fnd_lookup_values flv,
         fnd_lookup_values flv1,
         msc_companies c,
         msc_company_sites s
  WHERE  ln.parent_header_id = p_header_id AND
         ln.line_id between p_start_line and p_end_line AND
         flv.lookup_type = 'MSC_X_BUCKET_TYPE' AND
         UPPER(flv.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING) AND
         flv.language = p_language AND
         flv.lookup_code = G_MONTH AND
         NVL(ln.row_status, G_PROCESS) = G_SUCCESS AND
         UPPER(c.company_name) = UPPER(NVL(ln.publisher_company, ln.posting_party_name)) AND
         s.company_id = c.company_id AND
         UPPER(s.company_site_name) = UPPER(ln.publisher_site) AND
         flv1.lookup_type = 'MSC_X_ORDER_TYPE' AND
         flv1.language = p_language AND
         UPPER(flv1.meaning) = UPPER(ln.order_type) AND
         flv1.lookup_code in (g_safety_stock, g_proj_avai_bal)
	 AND mlb.parent_header_id = ln.parent_header_id
	 AND mlb.line_id = ln.line_id
	 AND UPPER(ln.sync_indicator) = 'R';

  CURSOR c_moe_reqs(
    p_header_id in number
  ) IS
  select sd.inventory_item_id,
         sd.primary_quantity,
         to_char(sd.receipt_date,NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY')),
         nvl(sd.customer_id, sd.publisher_id),
         nvl(sd.customer_site_id, sd.publisher_site_id),
         nvl(sd.supplier_id, sd.publisher_id),
         nvl(sd.supplier_site_id, sd.publisher_site_id),
         sd.primary_uom
  from   msc_sup_dem_entries sd
  where  sd.ref_header_id = p_header_id and
    sd.publisher_order_type = G_REQUISITION;

  CURSOR c_sc_admins
    (
     p_header_id IN NUMBER
     ) IS
   SELECT DISTINCT u.user_name
     , u.user_id
     FROM fnd_user u,
     fnd_user_resp_groups g,
     fnd_responsibility r,
     msc_company_users cu,
     msc_companies c,
     msc_supdem_lines_interface ln
     WHERE ln.parent_header_id = p_header_id
     AND ln.publisher_company = c.company_name
     AND cu.company_id = c.company_id
     AND cu.user_id = u.user_id
     AND g.user_id = u.user_id
     AND g.responsibility_id = r.responsibility_id
     AND r.responsibility_key = 'MSCX_SC_ADMIN_FULL';

   CURSOR  c_bucket_data ( p_language    VARCHAR2,
                           p_header_id   NUMBER,
			   l_date_format VARCHAR2,
			   p_bucket_type NUMBER)
       IS
   SELECT ln.parent_header_id,
	  ln.line_id,
          to_char(trunc(to_date(ln.key_date,l_date_format)),'J') from_date,
	  to_char(trunc(to_date(nvl(ln.key_end_date,key_date),l_date_format)),'J') to_date
    FROM  msc_supdem_lines_interface ln,
	  fnd_lookup_values flv,
	  fnd_lookup_values flv1
   WHERE  ln.key_date is not null
     and  ln.parent_header_id = p_header_id
     and  nvl(ln.row_status, G_PROCESS) = G_SUCCESS
     and  flv.language = p_language
     and  flv.lookup_type = 'MSC_X_ORDER_TYPE'
     and  upper(flv.meaning) = upper(ln.order_type)
     and  flv.lookup_code <> g_work_order
     and  flv1.language = flv.language
     and  flv1.lookup_type = 'MSC_X_BUCKET_TYPE'
     and  flv1.lookup_code = p_bucket_type
     and  UPPER(flv1.meaning) = NVL(UPPER(ln.bucket_type), G_NULL_STRING)
     and  upper(ln.sync_indicator) = 'R'
   order  by parent_header_id,line_id;

  /* Local variables */
  l_sync_ind                 VARCHAR2(1);
  l_posting_party_name       VARCHAR2(255);
  l_resp_id                  NUMBER;
  l_app_id                   NUMBER;
  l_user_id                  NUMBER;
  l_user_name                VARCHAR2(100);
  l_language                 VARCHAR2(30);
  l_language_code            VARCHAR2(4);
  l_posting_party_id         NUMBER;
  l_header_status            NUMBER;
  l_error_count              NUMBER;
  l_event_key                VARCHAR2(30);
  l_min                      NUMBER;
  l_max                      NUMBER;
  l_loops_reqd               NUMBER;
  l_start_line               NUMBER;
  l_end_line                 NUMBER;
  l_conversion_found         BOOLEAN;
  l_conversion_rate          NUMBER;
  l_file_name                VARCHAR2(255);
  l_comp_avg_dmd             NUMBER;
  l_date_format              VARCHAR2(80);

  /* Variables added for moe requisitions cursor */
  l_item_id                  NUMBER;
  l_quantity                 NUMBER;
  l_rec_date                 VARCHAR2(40);
  l_cust_id                  NUMBER;
  l_cust_site_id             NUMBER;
  l_sup_id                   NUMBER;
  l_sup_site_id              NUMBER;
  l_uom                      VARCHAR2(3);
  l_err_msg                  VARCHAR2(1000);

  /* Collection variables */
  t_line_id                  lineidList;
  t_pub                      publisherList;
  t_pub_id                   publishidList;
  t_pub_site                 pubsiteList;
  t_pub_site_id              pubsiteidList;
  t_pub_addr                 pubaddrList;
  t_cust                     customerList;
  t_cust_id                  custidList;
  t_cust_site                custsiteList;
  t_cust_site_id             custsiteidList;
  t_cust_addr                custaddrList;
  t_supp                     supplierList;
  t_supp_id                  suppidList;
  t_supp_site                suppsiteList;
  t_supp_site_id             suppsiteidList;
  t_supp_addr                suppaddrList;
  t_shipfrom                 shipfromList;
  t_shipfrom_id              shipfromidList := shipfromidList();
  t_shipfrom_site            shipfromsiteList;
  t_shipfrom_site_id         shipfromsidList := shipfromsidList();
  t_shipfrom_addr            shipfromaddrList;
  t_shipto                   shiptoList;
  t_shipto_id                shiptoidList := shiptoidList();
  t_shipto_site              shiptositeList;
  t_shipto_site_id           shiptosidList := shiptosidList();
  t_shipto_party_addr        shiptopaddrList;
  t_shipto_addr              shiptoaddrList;
  t_end_order_pub            endordpubList;
  t_end_ord_pub_id           endordpubidList := endordpubidList();
  t_end_ord_pub_site         endordpubsiteList;
  t_end_ord_pub_site_id      endordpubsidList := endordpubsidList();
  t_order_type               ordertypeList;
  t_ot_desc                  otdescList;
  t_end_order_type           endordertypeList := endordertypeList();
  t_end_ot_desc              endotdescList;
  t_bkt_type_desc            bktypedescList;
  t_bkt_type                 bktypeList;
  t_item_name                itemList;
  t_owner_item_name          itemList;
  t_cust_item_name           itemList;
  t_supp_item_name           itemList;
  t_item_id                  itemidList;
  t_item_desc                itemdescList;
  t_pri_uom                  uomList;
  t_pri_qty                  qtyList := qtyList();
  t_category                 categoryList;
  t_ref_item_name            itemList;
  t_ref_item_desc            itemdescList;
  t_ref_uom                  uomList;
  t_ord_num                  ordernumList;
  t_rel_num                  relnumList;
  t_line_num                 linenumList;
  t_end_ord                  endordList;
  t_end_line                 endlineList;
  t_end_rel                  endrelList;
  t_key_date                 keydateList;
  t_key_end_date             keydatelist;
  t_new_sched_date           newschedList;
  t_ship_date                shipdateList;
  t_receipt_date             receiptdateList;
  t_new_ord_plac_date        newordplaceList;
  t_orig_prom_date           origpromList;
  t_req_date                 reqdateList;
  /* Added for work order support */
  t_wip_st_date              wipstdatelist;
  t_wip_end_date             wipenddatelist;
  t_quantity                 qtyList;
  t_uom                      uomList;
  t_comments                 commentList;
  t_carrier_code             carrierList;
  t_bill_of_lading           billofladList;
  t_tracking_number          trackingList;
  t_vehicle_number           vehicleList;
  t_container_type           containerList;
  t_container_qty            contqtyList;
  t_serial_number            serialnumList;
  t_attach_url               attachurlList;
  t_version                  versionList;
  t_designator               designatorList;
  t_context         contextList;
  t_attribute1         attributeList;
  t_attribute2               attributeList;
  t_attribute3               attributeList;
  t_attribute4               attributeList;
  t_attribute5               attributeList;
  t_attribute6               attributeList;
  t_attribute7               attributeList;
  t_attribute8               attributeList;
  t_attribute9               attributeList;
  t_attribute10              attributeList;
  t_attribute11              attributeList;
  t_attribute12              attributeList;
  t_attribute13              attributeList;
  t_attribute14              attributeList;
  t_attribute15              attributeList;
  t_posting_party_name       postingpartyList;
  t_posting_party_id         numList := numList();
  t_user_name                usernameList;
  t_user_id                  numList;
  t_event_key                eventkeyList := eventkeyList();
  t_transaction_id           transactionIdList;

  /* variables added for Bucketing changes */
  t_header_id_lst            headeridList;
  t_line_id_lst              lineidList;
  t_key_date_lst             numList;
  t_ket_end_date_lst         numList;

  lv_bucket_index            number;
  lv_new_date                number;

  l_consumption_advice_exists BOOLEAN; -- bug 3551850

BEGIN

  ---------------------------------------------------------------
  --- Call custom validations code to perform custom validations
  ---------------------------------------------------------------

  msc_custom_validation_pkg.call_validations_pre(p_header_id);

  log_debug('In validate');
  --========================================================
  --Get the user's language
  --========================================================
  BEGIN
    SELECT distinct u.user_name,
           l.created_by
    INTO   l_user_name,
           l_user_id
    FROM   fnd_user u,
           msc_supdem_lines_interface l
    WHERE  u.user_id = l.created_by and
           l.parent_header_id = p_header_id;

/*  BUG #3845796 :Using Applications Session Language in preference to ICX_LANGUAGE profile value */

    l_language_code := USERENV('LANG');
    G_USER_IS_ADMIN := is_user_admin(l_user_id);

    IF(l_language_code is null) THEN
       l_language := fnd_profile.value('ICX_LANGUAGE');

    IF l_language IS NOT NULL THEN
      SELECT language_code
      INTO   l_language_code
      FROM   fnd_languages
      WHERE  nls_language = l_language;
    ELSE
      l_language_code := 'US';
    END IF;
   END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_language_code := 'US';
  END;

	execute immediate
		'select meaning from FND_LOOKUP_VALUES '
		|| ' where LOOKUP_TYPE = ''MSC_X_BUCKET_TYPE'' '
		|| ' and   LOOKUP_CODE = 1 '
		|| ' and   LANGUAGE = :l_language_code '
		into  G_DAY_DESC
		USING  l_language_code;

  IF p_build_err = 1 THEN
    l_date_format := NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY HH24:MI:SS');
  ELSE
    l_date_format := 'DD/MM/YYYY HH24:MI:SS';
  END IF;

  --==========================================================
  --Get the file name. In case of XML or MOE default correctly
  --==========================================================
  BEGIN
    SELECT file_name
    INTO   l_file_name
    FROM   msc_files
    WHERE  plan_id = -1 AND
           header_id = p_header_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_file_name := substrb(get_message('MSC','MSC_X_XML_FILE', l_language_code),1,240);
  END;

  log_debug('File name:' || l_file_name);

  BEGIN
    SELECT min(line_id), max(line_id)
    INTO   l_min, l_max
    FROM   msc_supdem_lines_interface
    WHERE  parent_header_id = p_header_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       p_status := 0;
       p_err_msg := NULL;
       return;
  END;

  l_loops_reqd := 1 + trunc((l_max - l_min)/G_BATCH_SIZE);

  --==========================================================
  --Insert/update/delete records into/from the transaction
  --table in batches of 500
  --==========================================================
  IF l_loops_reqd IS NOT NULL THEN

     --==========================================================
     --Perform validations on the data
     --==========================================================
     -- bug 3551850 update_errors(p_header_id, l_language_code, p_build_err,l_date_format);
     update_errors(p_header_id, l_language_code, p_build_err,l_date_format, l_consumption_advice_exists);

     --==========================================================
     --Insert/update/delete records into/from the transaction
     --table in batches of 500
     --==========================================================
     FOR i IN 1..l_loops_reqd LOOP
	l_start_line := l_min + (i-1)*G_BATCH_SIZE;
	IF ((l_min -1 + i*G_BATCH_SIZE) <= l_max) THEN
	   l_end_line := l_min -1 + i*G_BATCH_SIZE;
	 ELSE
	   l_end_line := l_max;
	END IF;
	log_debug('Loop: ' || i);

	--==========================================================
	-- Records with Sync indicator D
	--==========================================================
	log_debug('Opening c_delete');
        log_debug('Date format = ' || l_date_format);
	OPEN c_delete(p_header_id, l_language_code, l_start_line, l_end_line,l_date_format);
	FETCH c_delete BULK COLLECT INTO t_transaction_id;
	CLOSE c_delete;


	log_debug('Count = ' || t_transaction_id.COUNT);
	log_debug('-- p_header_id :'||p_header_id);
	log_debug('-- l_start_line :'||l_start_line);
	log_debug('-- l_end_line :'||l_end_line);
	log_debug('-- l_language_code :'||l_language_code);

	if (t_transaction_id is not null) and  (t_transaction_id.COUNT > 0) then
	   log_debug('RecordS fetched: ' || t_transaction_id.COUNT);
           BEGIN
	      FORALL i IN t_transaction_id.FIRST..t_transaction_id.LAST
		UPDATE msc_sup_dem_entries msde
		SET    msde.quantity = 0,
		msde.tp_quantity = 0,
		msde.primary_quantity = 0,
		msde.ref_header_id = p_header_id,
		msde.last_refresh_number = msc_cl_refresh_s.nextval,
		msde.last_update_login = G_DELETED
		WHERE  msde.transaction_id  = t_transaction_id(i);

	      -- Disable all the corresponding serial Details
	      FORALL i IN t_transaction_id.FIRST..t_transaction_id.LAST
		UPDATE  msc_serial_numbers msn
		SET     msn.disable_date = sysdate
		WHERE  msn.serial_txn_id = t_transaction_id(i) AND
		NVL(msn.disable_date,sysdate+1) > sysdate ;
	   END;
	   --COMMIT;
	end if;

	log_debug('After c_delete');

    /* Added for work order support */

    OPEN c_work_order_without_cust(
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
    FETCH c_work_order_without_cust bulk collect INTO
              t_line_id,
              t_pub,
              t_pub_id,
              t_pub_site,
              t_pub_site_id,
              t_pub_addr,
              t_cust,
              t_cust_id,
              t_cust_site,
              t_cust_site_id,
              t_cust_addr,
              t_supp,
              t_supp_id,
              t_supp_site,
              t_supp_site_id,
              t_supp_addr,
              t_shipfrom,
              t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_work_order_without_cust;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
        t_posting_party_id,
        t_cust,
        t_cust_site,
        t_key_date
      );

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
	t_cust_id,
	t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
        /* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;

    OPEN c_work_order_with_cust(
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
    FETCH c_work_order_with_cust bulk collect INTO
              t_line_id,
              t_pub,
              t_pub_id,
              t_pub_site,
              t_pub_site_id,
              t_pub_addr,
              t_cust,
              t_cust_id,
              t_cust_site,
              t_cust_site_id,
              t_cust_addr,
              t_supp,
              t_supp_id,
              t_supp_site,
              t_supp_site_id,
              t_supp_addr,
              t_shipfrom,
              t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_work_order_with_cust;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
        t_posting_party_id,
        t_cust,
        t_cust_site,
	t_key_date
      );

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
	t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
        /* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;

    --==========================================================
    -- Valid unallocated onhand records. This order type is
    -- handled specially because neither the customer nor the
    -- supplier fields are populated.
    --==========================================================
  log_debug('Opening c_unallocated_onhand');
    OPEN c_unallocated_onhand(
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
	    FETCH c_unallocated_onhand BULK COLLECT INTO
		      t_line_id,
		      t_pub,
		      t_pub_id,
		      t_pub_site,
		      t_pub_site_id,
		      t_pub_addr,
		      t_cust,
		      t_cust_id,
		      t_cust_site,
		      t_cust_site_id,
		      t_cust_addr,
		      t_supp,
		      t_supp_id,
		      t_supp_site,
		      t_supp_site_id,
		      t_supp_addr,
		      t_shipfrom,
		      t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_unallocated_onhand;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
	t_posting_party_id,
	t_cust,
        t_cust_site,
        t_key_date
      );

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
	/* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;

    log_debug('Opening c_bktless_key');
    OPEN c_bktless_key (
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
    FETCH c_bktless_key BULK COLLECT INTO
              t_line_id,
              t_pub,
              t_pub_id,
              t_pub_site,
              t_pub_site_id,
              t_pub_addr,
              t_cust,
              t_cust_id,
              t_cust_site,
              t_cust_site_id,
              t_cust_addr,
              t_supp,
              t_supp_id,
              t_supp_site,
              t_supp_site_id,
              t_supp_addr,
              t_shipfrom,
              t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
         t_context,
         t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_bktless_key;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
 log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
        t_posting_party_id,
        t_cust,
        t_cust_site,
        t_key_date
	);

    log_debug('Calling replace_supdem_entries');
      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
	/* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
      t_context,
   t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );
   log_debug('After replace');
    end if;

     /* for Daily buckets data     */
     OPEN  c_bucket_data( l_language_code ,
                          p_header_id,
			  l_date_format,
			  G_DAY);
     FETCH c_bucket_data
      BULK COLLECT INTO
           t_header_id_lst,
	   t_line_id_lst,
	   t_key_date_lst,
	   t_ket_end_date_lst;
     CLOSE c_bucket_data;

     if (t_line_id_lst.COUNT > 0 ) then
	     FOR i in 1..t_line_id_lst.COUNT LOOP

	       lv_bucket_index := 0;

		       LOOP

			   lv_new_date := t_key_date_lst(i) + lv_bucket_index;

			   EXIT WHEN lv_new_date > t_ket_end_date_lst(i);

			   insert into MSC_LOAD_BUCKETS_TEMP
			     (PARENT_HEADER_ID,
			      LINE_ID,
			      BUCKET_DATE,
			      BUCKET_TYPE)
			      values ( t_header_id_lst(i),
				       t_line_id_lst(i),
				       to_date(lv_new_date,'J'),
				       1);

			   lv_bucket_index := lv_bucket_index + 1;

		       END LOOP;

	     END LOOP;
     end if;

  log_debug('Opening c_daily_bkt_key');
    OPEN c_daily_bkt_key (
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
    FETCH c_daily_bkt_key BULK COLLECT INTO
              t_line_id,
              t_pub,
              t_pub_id,
              t_pub_site,
              t_pub_site_id,
              t_pub_addr,
              t_cust,
              t_cust_id,
              t_cust_site,
              t_cust_site_id,
              t_cust_addr,
              t_supp,
              t_supp_id,
              t_supp_site,
              t_supp_site_id,
              t_supp_addr,
              t_shipfrom,
              t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;

    CLOSE c_daily_bkt_key;

    commit;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
	t_posting_party_id,
	t_cust,
        t_cust_site,
        t_key_date
      );

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
	/* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;

     /* for weekly buckets data     */
     OPEN  c_bucket_data( l_language_code ,
                          p_header_id,
			  l_date_format,
			  G_WEEK);
     FETCH c_bucket_data
      BULK COLLECT INTO
           t_header_id_lst,
	   t_line_id_lst,
	   t_key_date_lst,
	   t_ket_end_date_lst;
     CLOSE c_bucket_data;

     if (t_line_id_lst.COUNT > 0 ) then
	     FOR i in 1..t_line_id_lst.COUNT LOOP

	       lv_bucket_index := 0;

		       LOOP

			   lv_new_date := t_key_date_lst(i) + (7 * lv_bucket_index);

			   EXIT WHEN lv_new_date > t_ket_end_date_lst(i);

			   insert into MSC_LOAD_BUCKETS_TEMP
			     (PARENT_HEADER_ID,
			      LINE_ID,
			      BUCKET_DATE,
			      BUCKET_TYPE)
			      values ( t_header_id_lst(i),
				       t_line_id_lst(i),
				       to_date(lv_new_date,'J'),
				       2);

			   lv_bucket_index := lv_bucket_index + 1;

		       END LOOP;

	     END LOOP;
     end if;

  log_debug('Opening c_weekly_bkt_key');
    OPEN c_weekly_bkt_key (
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
    FETCH c_weekly_bkt_key BULK COLLECT INTO
              t_line_id,
              t_pub,
              t_pub_id,
              t_pub_site,
              t_pub_site_id,
              t_pub_addr,
              t_cust,
              t_cust_id,
              t_cust_site,
              t_cust_site_id,
              t_cust_addr,
              t_supp,
              t_supp_id,
              t_supp_site,
              t_supp_site_id,
              t_supp_addr,
              t_shipfrom,
              t_shipfrom_site,
              t_shipfrom_addr,
              t_shipto,
              t_shipto_site,
              t_shipto_party_addr,
              t_shipto_addr,
              t_end_order_pub,
              t_end_ord_pub_site,
              t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_weekly_bkt_key;

    commit;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
	t_posting_party_id,
	t_cust,
        t_cust_site,
        t_key_date
      );

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
	/* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;

     /* for Monthly buckets data     */
     OPEN  c_bucket_data( l_language_code ,
                          p_header_id,
			  l_date_format,
			  G_MONTH);
     FETCH c_bucket_data
      BULK COLLECT INTO
           t_header_id_lst,
	   t_line_id_lst,
	   t_key_date_lst,
	   t_ket_end_date_lst;
     CLOSE c_bucket_data;

     if (t_line_id_lst.COUNT > 0 ) then
	     FOR i in 1..t_line_id_lst.COUNT LOOP

	       lv_bucket_index := 0;

		       LOOP

			   lv_new_date := to_char(add_months(to_date(t_key_date_lst(i),'J') , lv_bucket_index) ,'J') ;

			   EXIT WHEN lv_new_date > t_ket_end_date_lst(i);

			   insert into MSC_LOAD_BUCKETS_TEMP
			     (PARENT_HEADER_ID,
			      LINE_ID,
			      BUCKET_DATE,
			      BUCKET_TYPE)
			      values ( t_header_id_lst(i),
				       t_line_id_lst(i),
				       to_date(lv_new_date,'J') ,
				       3);

			   lv_bucket_index := lv_bucket_index + 1;

		       END LOOP;

	     END LOOP;
    end if;

  log_debug('Opening c_monthly_bkt_key');
    OPEN c_monthly_bkt_key (
          p_header_id,
          l_language_code,
          l_start_line,
          l_end_line,
          l_date_format);
	    FETCH c_monthly_bkt_key BULK COLLECT INTO
		      t_line_id,
		      t_pub,
		      t_pub_id,
		      t_pub_site,
		      t_pub_site_id,
		      t_pub_addr,
		      t_cust,
		      t_cust_id,
		      t_cust_site,
		      t_cust_site_id,
		      t_cust_addr,
		      t_supp,
		      t_supp_id,
		      t_supp_site,
		      t_supp_site_id,
		      t_supp_addr,
		      t_shipfrom,
		      t_shipfrom_site,
		      t_shipfrom_addr,
		      t_shipto,
		      t_shipto_site,
		      t_shipto_party_addr,
		      t_shipto_addr,
		      t_end_order_pub,
		      t_end_ord_pub_site,
		      t_order_type,
              t_ot_desc,
              t_end_ot_desc,
              t_bkt_type_desc,
              t_bkt_type,
              t_item_id,
              t_ord_num,
              t_line_num,
              t_rel_num,
              t_end_ord,
              t_end_line,
              t_end_rel,
              t_key_date,
              t_new_sched_date,
              t_ship_date,
              t_receipt_date,
              t_new_ord_plac_date,
              t_orig_prom_date,
              t_req_date,
              /* Added for work order support */
              t_wip_st_date,
              t_wip_end_date,
              t_quantity,
              t_uom,
              t_comments,
              t_carrier_code,
              t_bill_of_lading,
              t_tracking_number,
              t_vehicle_number,
              t_container_type,
              t_container_qty,
              t_serial_number,
              t_attach_url,
              t_version,
              t_designator,
              t_context,
              t_attribute1,
              t_attribute2,
              t_attribute3,
              t_attribute4,
              t_attribute5,
              t_attribute6,
              t_attribute7,
              t_attribute8,
              t_attribute9,
              t_attribute10,
              t_attribute11,
              t_attribute12,
              t_attribute13,
              t_attribute14,
              t_attribute15,
              t_posting_party_name;
    CLOSE c_monthly_bkt_key;

    commit;

    if (t_line_id is not null) and (t_line_id.COUNT > 0) then
    log_debug('Records fetched: ' || t_line_id.COUNT);
      get_optional_info(
        p_header_id,
        l_language_code,
        t_line_id,
        t_end_order_pub,
        t_end_ord_pub_site,
        t_shipfrom,
        t_shipfrom_site,
        t_shipto,
        t_shipto_site,
        t_end_ot_desc,
        t_posting_party_name,
        t_cust_id,
        t_cust_site_id,
        t_supp_id,
        t_supp_site_id,
        t_item_id,
        t_order_type,
        t_ship_date,
        t_receipt_date,
        t_end_order_type,
        t_end_ord_pub_id,
        t_end_ord_pub_site_id,
        t_shipfrom_id,
        t_shipfrom_site_id,
        t_shipto_id,
        t_shipto_site_id,
        t_posting_party_id,
        t_cust,
        t_cust_site,
        t_key_date
	);

      replace_supdem_entries (
        p_header_id,
        t_line_id,
        t_pub,
        t_pub_id,
        t_pub_site,
        t_pub_site_id,
        t_pub_addr,
        t_cust,
        t_cust_id,
        t_cust_site,
        t_cust_site_id,
        t_cust_addr,
        t_supp,
        t_supp_id,
        t_supp_site,
        t_supp_site_id,
        t_supp_addr,
        t_shipfrom,
        t_shipfrom_id,
        t_shipfrom_site,
        t_shipfrom_site_id,
        t_shipfrom_addr,
        t_shipto,
        t_shipto_id,
        t_shipto_site,
        t_shipto_site_id,
        t_shipto_party_addr,
        t_shipto_addr,
        t_end_order_pub,
        t_end_ord_pub_id,
        t_end_ord_pub_site,
        t_end_ord_pub_site_id,
        t_order_type,
        t_ot_desc,
        t_end_order_type,
        t_end_ot_desc,
        t_bkt_type_desc,
        t_bkt_type,
        t_item_id,
        t_ord_num,
        t_line_num,
        t_rel_num,
        t_end_ord,
        t_end_line,
        t_end_rel,
        t_key_date,
        t_new_sched_date,
        t_ship_date,
        t_receipt_date,
        t_new_ord_plac_date,
        t_orig_prom_date,
        t_req_date,
	/* Added for work order support */
        t_wip_st_date,
        t_wip_end_date,
        t_uom,
        t_quantity,
        t_comments,
        t_carrier_code,
        t_bill_of_lading,
        t_tracking_number,
        t_vehicle_number,
        t_container_type,
        t_container_qty,
        t_serial_number,
        t_attach_url,
        t_version,
        t_designator,
        t_context,
        t_attribute1,
        t_attribute2,
        t_attribute3,
        t_attribute4,
        t_attribute5,
        t_attribute6,
        t_attribute7,
        t_attribute8,
        t_attribute9,
        t_attribute10,
        t_attribute11,
        t_attribute12,
        t_attribute13,
        t_attribute14,
        t_attribute15,
        t_posting_party_name,
        t_posting_party_id,
        l_user_id,
        l_language_code
      );

    end if;
     END LOOP;
  END IF;

  --After all lines in the flat file have been processed.
  COMMIT;
  --============================================================================
  --Raise event that launches the workflow process that sends the error message
  --============================================================================
  BEGIN
     SELECT 1 INTO l_error_count
       FROM dual
       WHERE exists(
          SELECT 'exists'
          FROM   msc_supdem_lines_interface
          WHERE  parent_header_id = p_header_id AND
          row_status IN (G_PROCESS,G_FAILURE)
          );
  EXCEPTION
     WHEN OTHERS THEN
	l_error_count := 0;
  END;


  --dbms_output.enable(1000000);
  -- if the data was uploaded using flat-file loads or manual order entry
  if l_user_id <> -1 then
     l_event_key := 'LOADS' || '-' || p_header_id || '-' || l_user_id;
     if l_error_count > 0 THEN
	p_status := 1;
	if p_build_err = 2 then
	   SELECT err_msg INTO p_err_msg
	     FROM   msc_supdem_lines_interface
	     WHERE  parent_header_id = p_header_id;
	 else
	   send_ntf(p_header_id, l_file_name, G_FAILURE, l_user_name, l_event_key);
	end if;
      else
	p_status := 0;
	if p_build_err = 2 then
	   OPEN c_moe_reqs(p_header_id);
	   LOOP
	      FETCH c_moe_reqs
		INTO l_item_id,
		l_quantity,
		l_rec_date,
		l_cust_id,
		l_cust_site_id,
		l_sup_id,
		l_sup_site_id,
		l_uom;
	      EXIT WHEN c_moe_reqs%NOTFOUND;
	      log_debug('Calling API to move reqs to ERP');
	      log_debug('Item id := ' || l_item_id);
	      log_debug('Cust id := ' || l_cust_id);
	      log_debug('Cust site id := ' || l_cust_site_id);
	      log_debug('Supplier id := ' || l_sup_id);
	      log_debug('Supp site id := ' || l_sup_site_id);

	      MSC_X_REPLENISH.CREATE_REQUISITION(
                   l_item_id,
                   l_quantity,
                   l_rec_date,
                   l_cust_id,
                   l_cust_site_id,
                   l_sup_id,
                   l_sup_site_id,
                   l_uom,
                   l_err_msg
                   );
	   END LOOP;
	   CLOSE c_moe_reqs;

	   p_err_msg := nvl(l_err_msg, 'MSC_X_VALID_SUCCESS');

	   --p_err_msg := 'MSC_X_VALID_SUCCESS';
	 else
		 send_ntf(p_header_id, l_file_name, G_SUCCESS, l_user_name, l_event_key);
	end if;
     end if;
   ELSE
	--For files uploaded via XML the notifications are sent to the users
	--having the Supply Chain Administrator responsibility
	OPEN c_sc_admins(p_header_id);
	FETCH c_sc_admins bulk collect INTO
	  t_user_name,
	  t_user_id;
	CLOSE c_sc_admins;

	IF t_user_name IS NOT NULL AND t_user_name.COUNT > 0 THEN
	   FOR j IN t_user_name.first..t_user_name.last LOOP
	      t_event_key.extend;
	      t_event_key(j) := 'LOADS' || '-' || p_header_id || '-' || t_user_id(j);
	      IF l_error_count > 0 THEN
		 send_ntf(p_header_id, l_file_name, G_FAILURE, t_user_name(j), t_event_key(j));
	       ELSE
		 send_ntf(p_header_id, l_file_name, G_SUCCESS, t_user_name(j), t_event_key(j));
	      END IF;
	   END LOOP;
	END IF;

  END IF;


  --============================================================================================
  -- Starting post processing steps
  --============================================================================================
  IF (l_consumption_advice_exists) THEN
    LOG_MESSAGE('Creating Sales orders for Consumption Advice');
    begin
	  MSC_X_CVMI_REPLENISH.vmi_release_api_load(p_header_id);
    exception
      when others then
	  LOG_MESSAGE('Error in Sales orders for Consumption Advice: '||SQLERRM);
    end;
  END IF;

  log_message('Performing Consumption');
  POST_PROCESS(p_header_id);


  /*****************************************
  Not needed since average daily demand is calculated in
  the VMI engine from 11.5.10
  log_message('Calculating average demand');
  BEGIN
    select 1
    into   l_comp_avg_dmd
    from   dual
    where  exists (
           select 'exists'
           from   msc_supdem_lines_interface ln,
                  fnd_lookup_values flv
           where  ln.parent_header_id = p_header_id
           and    ln.row_status = G_SUCCESS
           and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
           and    flv.lookup_code = 2
           and    UPPER(flv.meaning) = UPPER(ln.order_type)
           );
    log_debug('l_comp_avg_dmd := ' || l_comp_avg_dmd);
  EXCEPTION
    WHEN OTHERS THEN
      l_comp_avg_dmd := 0;
  END;

  IF l_comp_avg_dmd = 1 THEN
    BEGIN
      MSC_X_PLANNING.CALCULATE_AVERAGE_DEMAND;
    EXCEPTION
      WHEN OTHERS THEN
        LOG_MESSAGE('Error in MSC_X_PLANNING.CALCULATE_AVERAGE_DEMAND');
        LOG_MESSAGE(SQLERRM);
    END;
  END IF;


  ***************/
  /* Delete the work orders that have been deleted */
  BEGIN
    delete from msc_sup_dem_entries sd
    where sd.plan_id = -1
    and   sd.publisher_order_type = G_WORK_ORDER
    and   sd.last_update_login = G_DELETED;

  EXCEPTION
    WHEN OTHERS THEN
      LOG_MESSAGE(SQLERRM);
  END;

  -- launch SCEM engine
  LOG_MESSAGE('Check to see if need to launch SCEM engine ...');
  DECLARE
    l_order_type_flag NUMBER;
    l_msc_x_auto_scem_mode NUMBER;
    l_msc_x_configuration NUMBER;
  BEGIN
    l_order_type_flag := 0;
    l_msc_x_auto_scem_mode := FND_PROFILE.VALUE('MSC_X_AUTO_SCEM_MODE');
    l_msc_x_configuration := FND_PROFILE.VALUE('MSC_X_CONFIGURATION');
    BEGIN
      select 1
      into   l_order_type_flag
      from   dual
      where  exists (
           select 'exists'
           from   msc_supdem_lines_interface ln,
                  fnd_lookup_values flv
           where  ln.parent_header_id = p_header_id
           and    ln.row_status = G_SUCCESS
           and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
           and    flv.lookup_code IN (2, 3)
           and    UPPER(flv.meaning) = UPPER(ln.order_type)
           );
    EXCEPTION
      WHEN OTHERS THEN
      l_order_type_flag := 0;
    END;

    log_debug('flag/profile: ' || l_order_type_flag
               || '-' || l_msc_x_auto_scem_mode || '-' || l_msc_x_configuration);

     IF ( l_order_type_flag = 1 ) THEN
      IF ( ( l_msc_x_auto_scem_mode = 1
           OR l_msc_x_auto_scem_mode = 3
           ) -- LOAD or ALL
         AND (l_msc_x_configuration = 2 OR l_msc_x_configuration = 3) -- APS+CP or CP
      ) THEN
        LOG_MESSAGE('About to Launching SCEM engine ...');
        MSC_X_CP_FLOW.Start_SCEM_Engine_WF;
        LOG_MESSAGE('After launching SCEM engine ...');
      END IF;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
        LOG_MESSAGE('Error in MSC_X_CP_FLOW.Start_SCEM_Engine_WF');
        LOG_MESSAGE(SQLERRM);
 END;

  --==================================================================
  -- Load the Serial Number data
  --===================================================================
  serial_validation(p_header_id,l_language_code);


  -----------------------------------------------------------------------
  --- Call the custom validations code to perform custom validations
  ----------------------------------------------------------------------

	msc_custom_validation_pkg.call_validations_post(p_header_id);

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      LOG_MESSAGE('Error in msc_sce_loads_pkg.validate');
      LOG_MESSAGE(SQLERRM);

END validate;



PROCEDURE get_optional_info
  (
    p_header_id           IN     Number,
    p_language_code       IN     Varchar2,
    t_line_id             IN     lineidList,
    t_end_order_pub       IN     endordpubList,
    t_end_ord_pub_site    IN     endordpubsiteList,
    t_shipfrom            IN     shipfromList,
    t_shipfrom_site       IN     shipfromsiteList,
    t_shipto              IN     shiptoList,
    t_shipto_site         IN     shiptositeList,
    t_end_ot_desc         IN     endotdescList,
    t_posting_party_name  IN     postingpartyList,
    t_cust_id             IN OUT NOCOPY custidList,
    t_cust_site_id        IN OUT NOCOPY custsiteidList,
    t_supp_id             IN     suppidList,
    t_supp_site_id        IN     suppsiteidList,
    t_item_id             IN     itemidList,
    t_order_type          IN     ordertypeList,
    t_ship_date           IN OUT NOCOPY shipdateList,
    t_receipt_date        IN OUT NOCOPY receiptdateList,
    t_end_order_type      IN OUT NOCOPY endordertypeList,
    t_end_ord_pub_id      IN OUT NOCOPY endordpubidList,
    t_end_ord_pub_site_id IN OUT NOCOPY endordpubsidList,
    t_shipfrom_id         IN OUT NOCOPY shipfromidList,
    t_shipfrom_site_id    IN OUT NOCOPY shipfromsidList,
    t_shipto_id           IN OUT NOCOPY shiptoidList,
    t_shipto_site_id      IN OUT NOCOPY shiptosidList,
    t_posting_party_id    IN OUT NOCOPY numlist,
    t_cust                IN OUT NOCOPY customerList,
    t_cust_site           IN OUT NOCOPY custsitelist,
    t_key_date		  IN OUT NOCOPY keydateList
  ) IS

  l_conversion_found         BOOLEAN;
  l_conversion_rate          NUMBER;

BEGIN
   log_debug('In get_optional_info');
  IF t_line_id is not null and t_line_id.COUNT > 0 then
  log_debug('Lines fetched by cursor := ' || t_line_id.COUNT);

     FOR j in t_line_id.FIRST..t_line_id.LAST LOOP

      --=============================================================
      -- Figure out modeled org for work orders
      --=============================================================
      IF (t_order_type(j) = g_work_order) AND (t_supp_id(j) <> 1) AND (t_cust_id(j) is null) AND (t_cust_site_id(j) is null) THEN
         BEGIN
           SELECT c.company_name,
                  c.company_id,
                  cs.company_site_name,
                  cs.company_site_id
           INTO   t_cust(j),
                  t_cust_id(j),
                  t_cust_site(j),
                  t_cust_site_id(j)
           FROM   msc_trading_partners mtp,
                  msc_trading_partners mtp1,
                  msc_trading_partner_maps maps,
                  msc_trading_partner_maps maps1,
                  msc_trading_partner_maps maps2,
                  msc_trading_partner_sites mtps,
                  msc_company_sites cs,
                  msc_companies c,
                  msc_company_relationships rel
           WHERE  rel.relationship_type = 2
           AND    rel.subject_id = 1
           AND    rel.object_id = t_supp_id(j)
           AND    maps.company_key = rel.relationship_id
           AND    maps.map_type = 1
           AND    maps.tp_key = mtp.partner_id
           AND    maps1.company_key = t_supp_site_id(j)
           AND    maps1.map_type = 3
           AND    mtps.partner_site_id = maps1.tp_key
           AND    mtps.partner_id = mtp.partner_id
           AND    mtp1.partner_type = 3
           AND    mtp1.modeled_supplier_id = mtp.partner_id
           AND    mtp1.modeled_supplier_site_id = mtps.partner_site_id
           AND    maps2.tp_key = mtp1.partner_id
           AND    maps2.map_type = 2
           AND    cs.company_site_id = maps2.company_key
           AND    cs.company_id = c.company_id
           AND    c.company_id = 1;
	 EXCEPTION
           WHEN OTHERS THEN
              t_cust(j)                 := null;
              t_cust_id(j)              := null;
              t_cust_site(j)            := null;
              t_cust_site_id(j)         := null;
         END;
      END IF;



     if(t_cust_id(j) = 1) /* Customer is OEM */ then


      --=============================================================
      --  Obtain the ship date
      --=============================================================
      if t_ship_date(j) is null and t_order_type(j) in (G_SALES_FORECAST, G_SUPPLY_COMMIT,
        G_SALES_ORDER, G_ASN, G_PO_ACKNOWLEDGEMENT, G_ORDER_FORECAST, G_PURCHASE_ORDER, G_SHIP_RECEIPT,
        G_REQUISITION) then
        t_ship_date(j) := msc_x_util.update_ship_rcpt_dates(
                            t_cust_id(j),
                            t_cust_site_id(j),
                            t_supp_id(j),
                            t_supp_site_id(j),
                            t_order_type(j),
                            t_item_id(j),
                            null,
                            t_receipt_date(j)
                          );

	if(t_order_type(j) = G_SALES_FORECAST) then

	 t_key_date(j)  := t_ship_date(j);

	end if;

      end if;


      --=============================================================
      --  Obtain the receipt date
      --=============================================================
      if t_receipt_date(j) is null and t_order_type(j) in (G_SALES_FORECAST, G_SUPPLY_COMMIT,
        G_SALES_ORDER, G_ASN, G_PO_ACKNOWLEDGEMENT) then
        t_receipt_date(j) := msc_x_util.update_ship_rcpt_dates(
                            t_cust_id(j),
                            t_cust_site_id(j),
                            t_supp_id(j),
                            t_supp_site_id(j),
                            t_order_type(j),
                            t_item_id(j),
                            t_ship_date(j),
                            null
                          );

	if(t_order_type(j) <> G_SALES_FORECAST) then
	    t_key_date(j) := t_receipt_date(j);
	end if;

      end if;


      end if; /* Customer is OEM */


      --=============================================================
      --  Obtain end order type
      --=============================================================

      t_end_order_type.EXTEND;
      IF (j > 1) AND (nvl(t_end_ot_desc(j),-1) = nvl(t_end_ot_desc(j-1),-1)) THEN
        t_end_order_type(j) := t_end_order_type(j-1);
      ELSIF t_end_ot_desc(j) is null THEN
        t_end_order_type(j) := null;
      ELSE
        SELECT flv.lookup_code
        INTO   t_end_order_type(j)
        FROM   fnd_lookup_values flv,
               msc_supdem_lines_interface ln
        WHERE  flv.lookup_type = 'MSC_X_ORDER_TYPE' and
               flv.language = p_language_code and
               UPPER(flv.meaning) = UPPER(ln.end_order_type) and
               ln.parent_header_id = p_header_id and
               ln.line_id = t_line_id(j);
      END IF;

      --=============================================================
      --Obtain end order publisher id
      --=============================================================

      t_end_ord_pub_id.EXTEND;
      IF (j > 1) AND (nvl(t_end_order_pub(j),-1) = nvl(t_end_order_pub(j-1),-1)) THEN
        t_end_ord_pub_id(j) := t_end_ord_pub_id(j-1);
      ELSE
       BEGIN
        SELECT c.company_id
        INTO   t_end_ord_pub_id(j)
        FROM   msc_companies c,
               msc_supdem_lines_interface l
        WHERE  UPPER(c.company_name) = UPPER(l.end_order_publisher_name) AND
               l.parent_header_id = p_header_id and
               l.line_id = t_line_id(j);
       EXCEPTION
        WHEN OTHERS THEN
         t_end_ord_pub_id(j) := null;
       END;
      END IF;

      --=============================================================
      --Obtain ship from party's id
      --=============================================================

      t_shipfrom_id.EXTEND;
      IF (j > 1) AND (nvl(t_shipfrom(j),-1) = nvl(t_shipfrom(j-1),-1)) THEN
        t_shipfrom_id(j) := t_shipfrom_id(j-1);
      ELSE
       BEGIN
        SELECT c.company_id
        INTO   t_shipfrom_id(j)
        FROM   msc_companies c,
               msc_supdem_lines_interface l
        WHERE  UPPER(c.company_name) = UPPER(l.ship_from_party_name) AND
               l.parent_header_id = p_header_id and
               l.line_id = t_line_id(j);
       EXCEPTION
        WHEN OTHERS THEN
         t_shipfrom_id(j) := null;
       END;
      END IF;

      --=============================================================
      --Obtain ship to party id
      --=============================================================

      t_shipto_id.EXTEND;
      IF (j > 1) AND (nvl(t_shipto(j),-1) = nvl(t_shipto(j-1),-1)) THEN
        t_shipto_id(j) := t_shipto_id(j-1);
      ELSE
       BEGIN
        SELECT c.company_id
        INTO t_shipto_id(j)
        FROM   msc_companies c,
               msc_supdem_lines_interface l
        WHERE  UPPER(c.company_name) = UPPER(l.ship_to_party_name) AND
               l.parent_header_id = p_header_id and
               l.line_id = t_line_id(j);
       EXCEPTION
        WHEN OTHERS THEN
         t_shipto_id(j) := null;
       END;
      END IF;

      --=============================================================
      --Obtain end order publisher's site id
      --=============================================================
      t_end_ord_pub_site_id.EXTEND;
      IF (j > 1) AND (nvl(t_end_ord_pub_site(j),-1) = nvl(t_end_ord_pub_site(j-1),-1)) THEN
         t_end_ord_pub_site_id(j) := t_end_ord_pub_site_id(j-1);
      ELSE
       BEGIN
        SELECT s.company_site_id
        INTO   t_end_ord_pub_site_id(j)
        FROM   msc_company_sites s,
               msc_supdem_lines_interface l
        WHERE  s.company_id = t_end_ord_pub_id(j) AND
               UPPER(s.company_site_name) = UPPER(l.end_order_publisher_site) AND
               l.parent_header_id = p_header_id and
               l.line_id = t_line_id(j);
       EXCEPTION
        WHEN OTHERS THEN
          t_end_ord_pub_site_id(j) := null;
       END;
      END IF;


      --=============================================================
      --Obtain ship from party's site id
      --=============================================================

      t_shipfrom_site_id.EXTEND;
      IF (j > 1) AND (nvl(t_shipfrom_site(j),-1) = nvl(t_shipfrom_site(j-1),-1)) THEN
         t_shipfrom_site_id(j) := t_shipfrom_site_id(j-1);
      ELSE
       BEGIN
         SELECT s.company_site_id
         INTO   t_shipfrom_site_id(j)
         FROM   msc_company_sites s,
                msc_supdem_lines_interface l
         WHERE  s.company_id = t_shipfrom_id(j) AND
                UPPER(s.company_site_name) = UPPER(l.ship_from_party_site) AND
                l.parent_header_id = p_header_id and
                l.line_id = t_line_id(j);
       EXCEPTION
         WHEN OTHERS THEN
           t_shipfrom_site_id(j) := null;
       END;
      END IF;

      --=============================================================
      --Obtain ship to party's site id
      --=============================================================

      t_shipto_site_id.EXTEND;

      IF (j > 1) AND (nvl(t_shipto_site(j),-1) = nvl(t_shipto_site(j-1),-1)) THEN
        t_shipto_site_id(j) := t_shipto_site_id(j-1);
      ELSE
       BEGIN
        SELECT s.company_site_id
        INTO   t_shipto_site_id(j)
        FROM   msc_company_sites s,
               msc_supdem_lines_interface l
        WHERE  s.company_id = t_shipto_id(j) AND
               UPPER(s.company_site_name) = UPPER(l.ship_to_party_site) AND
               l.parent_header_id = p_header_id and
               l.line_id = t_line_id(j);
       EXCEPTION
         WHEN OTHERS THEN
           t_shipto_site_id(j) := null;
       END;
      END IF;

      t_posting_party_id.EXTEND;

      IF (j > 1) AND (nvl(t_posting_party_name(j),-1) = nvl(t_posting_party_name(j-1),-1)) THEN
        t_posting_party_id(j) := t_posting_party_id(j-1);
      ELSE
        SELECT c.company_id
        INTO   t_posting_party_id(j)
        FROM   msc_companies c
        WHERE  c.company_name = t_posting_party_name(j);
	--Bug 5116681: there is no need no check the upper as posting party gets itself populated thru msc_companies table.
      END IF;

    END LOOP;

  END IF;

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      LOG_MESSAGE('Error in msc_sce_loads_pkg.get_optional_info');
      LOG_MESSAGE(SQLERRM);

END get_optional_info;

PROCEDURE replace_supdem_entries (
    p_header_id            IN Number,
    t_line_id              IN lineidList,
    t_pub                  IN publisherList,
    t_pub_id               IN publishidList,
    t_pub_site             IN pubsiteList,
    t_pub_site_id          IN pubsiteidList,
    t_pub_addr             IN pubaddrList,
    t_cust                 IN customerList,
    t_cust_id              IN custidList,
    t_cust_site            IN custsiteList,
    t_cust_site_id         IN custsiteidList,
    t_cust_addr            IN custaddrList,
    t_supp                 IN supplierList,
    t_supp_id              IN suppidList,
    t_supp_site            IN suppsiteList,
    t_supp_site_id         IN suppsiteidList,
    t_supp_addr            IN suppaddrList,
    t_shipfrom             IN shipfromList,
    t_shipfrom_id          IN shipfromidList,
    t_shipfrom_site        IN shipfromsiteList,
    t_shipfrom_site_id     IN shipfromsidList,
    t_shipfrom_addr        IN shipfromaddrList,
    t_shipto               IN shiptoList,
    t_shipto_id            IN shiptoidList,
    t_shipto_site          IN shiptositeList,
    t_shipto_site_id       IN shiptosidList,
    t_shipto_party_addr    IN shiptopaddrList,
    t_shipto_addr          IN shiptoaddrList,
    t_end_order_pub        IN endordpubList,
    t_end_ord_pub_id       IN endordpubidList,
    t_end_ord_pub_site     IN endordpubsiteList,
    t_end_ord_pub_site_id  IN endordpubsidList,
    t_order_type           IN ordertypeList,
    t_ot_desc              IN otdescList,
    t_end_order_type       IN endordertypeList,
    t_end_ot_desc          IN endotdescList,
    t_bkt_type_desc        IN bktypedescList,
    t_bkt_type             IN bktypeList,
    t_item_id              IN itemidList,
    t_ord_num              IN ordernumList,
    t_line_num             IN linenumList,
    t_rel_num              IN relnumList,
    t_end_ord              IN endordList,
    t_end_line             IN endlineList,
    t_end_rel              IN endrelList,
    t_key_date             IN keydateList,
    t_new_sched_date       IN newschedList,
    t_ship_date            IN shipdateList,
    t_receipt_date         IN receiptdateList,
    t_new_ord_plac_date    IN newordplaceList,
    t_orig_prom_date       IN origpromList,
    t_req_date             IN reqdateList,
    /* Added for work order support */
    t_wip_st_date          IN wipstdatelist,
    t_wip_end_date         IN wipenddatelist,
    t_uom                  IN uomList,
    t_quantity             IN qtyList,
    t_comments             IN commentList,
    t_carrier_code         IN carrierList,
    t_bill_of_lading       IN billofladList,
    t_tracking_number      IN trackingList,
    t_vehicle_number       IN vehicleList,
    t_container_type       IN containerList,
    t_container_qty        IN contqtyList,
    t_serial_number        IN serialnumList,
    t_attach_url           IN attachurlList,
    t_version              IN versionList,
    t_designator           IN designatorList,
    t_context        IN contextList,
    t_attribute1     IN attributeList,
    t_attribute2     IN attributeList,
    t_attribute3     IN attributeList,
    t_attribute4     IN attributeList,
    t_attribute5     IN attributeList,
    t_attribute6     IN attributeList,
    t_attribute7     IN attributeList,
    t_attribute8     IN attributeList,
    t_attribute9     IN attributeList,
    t_attribute10    IN attributeList,
    t_attribute11    IN attributeList,
    t_attribute12    IN attributeList,
    t_attribute13    IN attributeList,
    t_attribute14    IN attributeList,
    t_attribute15    IN attributeList,
    --p_posting_party_name   IN VARCHAR2,
    --p_posting_party_id     IN NUMBER,
    t_posting_party_name   IN postingpartyList,
    t_posting_party_id     IN numList,
    p_user_id              IN NUMBER,
    p_language_code        IN VARCHAR2
  ) IS

  CURSOR publisher_is_supplier_c(
    p_item_id      in number,
    p_cust_site_id in number,
    p_pub_id       in number,
    p_pub_site_id  in number
  ) IS
  select mis.supplier_item_name,
         nvl(mis.description,itm1.description) ,
         nvl(mis.uom_code,msi.uom_code),
         msi.base_item_id,
         itm.item_name,
	 msi.planner_code
  from   msc_item_suppliers mis,
         msc_system_items msi,
	 msc_items itm,
	 msc_items itm1,
         msc_trading_partner_maps map,
         msc_trading_partner_maps map1,
         msc_trading_partner_maps map2,
         msc_trading_partners mtp,
         msc_company_relationships r
  where  itm.inventory_item_id (+)= msi.base_item_id and
         msi.organization_id = mis.organization_id and
         msi.sr_instance_id = mis.sr_instance_id and
         msi.inventory_item_id = mis.inventory_item_id and
         msi.plan_id = mis.plan_id and
         mis.plan_id = -1 and
         mis.inventory_item_id = p_item_id and
         mis.plan_id = -1 and
         mis.organization_id = mtp.sr_tp_id and
         mis.sr_instance_id = mtp.sr_instance_id and
	 itm1.inventory_item_id(+) = mis.inventory_item_id and
         mtp.partner_id = map2.tp_key and
         mtp.partner_type = 3 and
         map2.company_key = p_cust_site_id and
         map2.map_type = 2 and
         mis.supplier_id = map.tp_key and
         --Nvl(mis.supplier_site_id, map1.tp_key) = map1.tp_key and
         mis.supplier_site_id = map1.tp_key and
         map.map_type = 1 and
         map.company_key = r.relationship_id and
         r.relationship_type = 2 and
         r.subject_id = 1 and
         r.object_id = p_pub_id and
         map1.map_type = 3 and
         map1.company_key = p_pub_site_id
  order by mis.using_organization_id desc;

  CURSOR supplier_item_c (
    p_item_id      in number,
    p_cust_site_id in number,
    p_pub_id       in number,
    p_pub_site_id  in number,
    p_supp_id      in number,
    p_supp_site_id in number
  ) IS
  select mis.supplier_item_name,
         nvl(mis.description,itm.description),
         mis.uom_code
  from   msc_item_suppliers mis,
         msc_items          itm,
         msc_trading_partner_maps map,
         msc_trading_partner_maps map1,
         msc_trading_partner_maps map2,
         msc_trading_partners mtp,
         msc_company_relationships r
  where  mis.inventory_item_id = p_item_id and
         mis.plan_id = -1 and
         mis.organization_id = mtp.sr_tp_id and
         mis.sr_instance_id = mtp.sr_instance_id and
	 itm.inventory_item_id(+) = mis.inventory_item_id and
         mtp.partner_id = map2.tp_key and
         mtp.partner_type = 3 and
         map2.company_key = nvl(p_cust_site_id, p_pub_site_id) and
         map2.map_type = 2 and
         mis.supplier_id = map.tp_key and
         --Nvl(mis.supplier_site_id, map1.tp_key) = map1.tp_key and
         mis.supplier_site_id = map1.tp_key and
         map.map_type = 1 and
         map.company_key = r.relationship_id and
         r.relationship_type = 2 and
         r.subject_id = 1 and
         r.object_id = nvl(p_supp_id, p_pub_id) and
         map1.map_type = 3 and
         map1.company_key = nvl(p_supp_site_id, p_pub_site_id)
  order by mis.using_organization_id desc;

  CURSOR c_vmi_item
     (
      p_supplier IN VARCHAR2,
      p_supplier_site IN VARCHAR2,
      p_customer_site IN VARCHAR2,
      p_item_id IN NUMBER
      ) IS
	 SELECT mis.vmi_flag,
	   mis.enable_vmi_auto_replenish_flag
	   FROM msc_trading_partners mtp,
	   msc_trading_partner_sites mtps,
	   msc_trading_partners mtp1,
	   msc_item_suppliers mis
	   WHERE Upper(mtp.partner_name) = Upper(p_supplier)
	   AND mtp.partner_type = 1
	   AND mtps.partner_id = mtp.partner_id
	   AND Upper(mtps.tp_site_code) = Upper(p_supplier_site)
	   AND Upper(mtp1.organization_code) = Upper(p_customer_site)
	   AND mtp1.partner_type = 3
	   AND mis.plan_id = -1
	   AND mis.organization_id = mtp1.sr_tp_id
	   AND mis.sr_instance_id = mtp1.sr_instance_id
	   AND mis.supplier_id = mtp.partner_id
	   AND Nvl(mis.supplier_site_id, -99) = Decode(mis.supplier_site_id, NULL, -99, mtps.partner_site_id)
	   AND mis.inventory_item_id = p_item_id
	   ORDER BY mis.using_organization_id DESC;

  -- jguo: added cursor below
  CURSOR c_shipping_control_meaning
    ( p_shipping_control_code IN NUMBER
    ) IS
    SELECT meaning,to_number(lookup_code)
    FROM fnd_lookup_values
    WHERE lookup_type = 'MSC_X_SHIPPING_CONTROL'
    AND language = p_language_code
    AND lookup_code = p_shipping_control_code
    ;
  l_conversion_found         BOOLEAN;
  l_conversion_rate          NUMBER;
  l_item_name                VARCHAR2(240);
  l_base_item_id 	     NUMBER;
  l_base_item_name           VARCHAR2(240);
  l_desc                     VARCHAR2(240);
  l_uom                      VARCHAR2(3);
  l_vmi_flag                 NUMBER;
  l_vmi_auto_replenish_flag  VARCHAR2(100);

  l_planner_code           VARCHAR2(240);--Bug 4424426


  t_insert_id                lineidList        := lineidList();
  t_ins_line_id              lineidList        := lineidList();
  t_ins_pub                  publisherList     := publisherList();
  t_ins_pub_id               publishidList     := publishidList();
  t_ins_pub_site             pubsiteList       := pubsiteList();
  t_ins_pub_site_id          pubsiteidList     := pubsiteidList();
  t_ins_pub_addr             pubaddrList       := pubaddrList();
  t_ins_cust                 customerList      := customerList();
  t_ins_cust_id              custidList        := custidList();
  t_ins_cust_site            custsiteList      := custsiteList();
  t_ins_cust_site_id         custsiteidList    := custsiteidList();
  t_ins_cust_addr            custaddrList      := custaddrList();
  t_ins_supp                 supplierList      := supplierList();
  t_ins_supp_id              suppidList        := suppidList();
  t_ins_supp_site            suppsiteList      := suppsiteList();
  t_ins_supp_site_id         suppsiteidList    := suppsiteidList();
  t_ins_supp_addr            suppaddrList      := suppaddrList();
  t_ins_shipfrom             shipfromList      := shipfromList();
  t_ins_shipfrom_id          shipfromidList    := shipfromidList();
  t_ins_shipfrom_site        shipfromsiteList  := shipfromsiteList();
  t_ins_shipfrom_site_id     shipfromsidList   := shipfromsidList();
  t_ins_shipfrom_addr        shipfromaddrList  := shipfromaddrList();
  t_ins_shipto               shiptoList        := shiptoList();
  t_ins_shipto_id            shiptoidList      := shiptoidList();
  t_ins_shipto_site          shiptositeList    := shiptositeList();
  t_ins_shipto_site_id       shiptosidList     := shiptosidList();
  t_ins_shipto_party_addr    shiptopaddrList   := shiptopaddrList();
  t_ins_shipto_addr          shiptoaddrList    := shiptoaddrList();
  t_ins_end_order_pub        endordpubList     := endordpubList();
  t_ins_end_ord_pub_id       endordpubidList   := endordpubidList();
  t_ins_end_ord_pub_site     endordpubsiteList := endordpubsiteList();
  t_ins_end_ord_pub_site_id  endordpubsidList  := endordpubsidList();
  t_ins_order_type           ordertypeList     := ordertypeList();
  t_ins_ot_desc              otdescList        := otdescList();
  t_ins_end_order_type       endordertypeList  := endordertypeList();
  t_ins_end_ot_desc          endotdescList     := endotdescList();
  t_ins_bkt_type_desc        bktypedescList    := bktypedescList();
  t_ins_bkt_type             bktypeList        := bktypeList();
  t_ins_item_id              itemidList        := itemidList();
  t_ins_base_item_id         itemidList        := itemidList();
  t_ins_pri_uom              uomList           := uomList();
  t_ins_pri_qty              qtyList           := qtyList();
  t_ins_ref_uom              uomList           := uomList();
  t_ins_ord_num              ordernumList      := ordernumList();
  t_ins_rel_num              relnumList        := relnumList();
  t_ins_line_num             linenumList       := linenumList();
  t_ins_end_ord              endordList        := endordList();
  t_ins_end_line             endlineList       := endlineList();
  t_ins_end_rel              endrelList        := endrelList();
  t_ins_key_date             keydateList       := keydateList();
  t_ins_new_sched_date       newschedList      := newschedList();
  t_ins_ship_date            shipdateList      := shipdateList();
  t_ins_receipt_date         receiptdateList   := receiptdateList();
  t_ins_new_ord_plac_date    newordplaceList   := newordplaceList();
  t_ins_orig_prom_date       origpromList      := origpromList();
  t_ins_req_date             reqdateList       := reqdateList();
  /* Added for work order support */
  t_ins_wip_st_date          wipstdatelist     := wipstdatelist();
  t_ins_wip_end_date         wipenddatelist    := wipenddatelist();
  t_ins_uom                  uomList           := uomList();
  t_ins_quantity             qtyList           := qtyList();
  t_ins_tp_quantity          qtyList           := qtyList();
  t_ins_comments             commentList       := commentList();
  t_ins_carrier_code         carrierList       := carrierList();
  t_ins_bill_of_lading       billofladList     := billofladList();
  t_ins_tracking_number      trackingList      := trackingList();
  t_ins_vehicle_number       vehicleList       := vehicleList();
  t_ins_container_type       containerList     := containerList();
  t_ins_container_qty        contqtyList       := contqtyList();
  t_ins_serial_number        serialnumList     := serialnumList();
  t_ins_attach_url           attachurlList     := attachurlList();
  t_ins_item_desc            itemdescList      := itemdescList();
  t_ins_cust_item_desc       itemdescList      := itemdescList();
  t_ins_supp_item_desc       itemdescList      := itemdescList();
  t_ins_owner_item_desc      itemdescList      := itemdescList();
  t_ins_item_name            itemList          := itemList();
  t_ins_cust_item_name       itemList          := itemList();
  t_ins_supp_item_name       itemList          := itemList();
  t_ins_owner_item_name      itemList          := itemList();
  t_ins_base_item_name       itemList          := itemList();
  t_ins_version              versionList       := versionList();
  t_ins_designator           designatorList    := designatorList();
  t_ins_context           contextList       := contextList();
  t_ins_attribute1           attributeList     := attributeList();
  t_ins_attribute2           attributeList     := attributeList();
  t_ins_attribute3           attributeList     := attributeList();
  t_ins_attribute4           attributeList     := attributeList();
  t_ins_attribute5           attributeList     := attributeList();
  t_ins_attribute6           attributeList     := attributeList();
  t_ins_attribute7           attributeList     := attributeList();
  t_ins_attribute8           attributeList     := attributeList();
  t_ins_attribute9           attributeList     := attributeList();
  t_ins_attribute10          attributeList     := attributeList();
  t_ins_attribute11          attributeList     := attributeList();
  t_ins_attribute12          attributeList     := attributeList();
  t_ins_attribute13          attributeList     := attributeList();
  t_ins_attribute14          attributeList     := attributeList();
  t_ins_attribute15          attributeList     := attributeList();
  t_ins_posting_party_name   postingpartyList  := postingpartyList();
  t_ins_posting_party_id     numList           := numList();
  t_ins_vmi_flag             numlist           := numlist();
  t_ins_shipping_control     shipCtrlList          := shipCtrlList();
  t_ins_shipping_control_code     numlist          := numlist();
   t_ins_planner_code     plannerCode          := plannerCode();--Bug 4424426

BEGIN
log_debug('In replace_supdem_entries');
  if t_line_id is not null and t_line_id.COUNT > 0 then
log_debug('Records fetched :' || t_line_id.COUNT);
  BEGIN
  log_debug('At 1');
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_sup_dem_entries
        SET    number1 = primary_quantity
	WHERE ROWID IN
	      (SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
		WHERE  plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
               publisher_order_type IN (G_SALES_FORECAST,
				    G_ORDER_FORECAST,
				    G_SUPPLY_COMMIT,
				    G_HIST_SALES,
				    G_SELL_THRO_FCST,
				    G_SUPPLIER_CAP,
				    G_SAFETY_STOCK,
				    G_INTRANSIT,
				    g_replenishment,
				    G_PROJ_AVAI_BAL) AND
               NVL(key_date, sysdate) = NVL(t_key_date(j), sysdate) AND
               NVL(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(j), G_NULL_STRING)
	 UNION ALL
	       SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
		WHERE  plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
               publisher_order_type IN (G_PURCHASE_ORDER,
				    G_SALES_ORDER,
				    G_ASN,
				    G_SHIP_RECEIPT,
				    G_REQUISITION,
				    G_PO_ACKNOWLEDGEMENT,
				    G_ALLOC_ONHAND,
				    g_unallocated_onhand,
                                    G_CONS_ADVICE) AND
               NVL(order_number, G_NULL_STRING) = NVL(t_ord_num(j), G_NULL_STRING) AND
               NVL(line_number, G_NULL_STRING) = NVL(t_line_num(j), G_NULL_STRING) AND
               NVL(release_number, G_NULL_STRING) = NVL(t_rel_num(j), G_NULL_STRING) AND
               NVL(end_order_number, G_NULL_STRING) = NVL(t_end_ord(j), G_NULL_STRING) AND
               NVL(end_order_rel_number, G_NULL_STRING) = NVL(t_end_rel(j), G_NULL_STRING) AND
	       NVL(end_order_line_number, G_NULL_STRING) = NVL(t_end_line(j), G_NULL_STRING)
	 UNION ALL
	      SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
		WHERE  plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
	       publisher_order_type = G_WORK_ORDER AND
               NVL(order_number, G_NULL_STRING) = NVL(t_ord_num(j), G_NULL_STRING)
		 );

  log_debug('At 2');
      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_sup_dem_entries
        SET    last_refresh_number = msc_cl_refresh_s.nextval,
               ref_header_id = p_header_id,
               ref_line_id = t_line_id(j),
               quantity = round(nvl(t_quantity(j),0),6),
               tp_quantity = get_quantity(t_quantity(j), nvl(t_uom(j),'Ea'), tp_uom_code, inventory_item_id),
               primary_quantity = get_quantity(t_quantity(j), nvl(t_uom(j),'Ea'), primary_uom, inventory_item_id),
               comments = t_comments(j),
               key_date = t_key_date(j),
               -- added the following line for bug 3596556
               need_by_date = DECODE(t_order_type(j), G_PURCHASE_ORDER, t_key_date(j), NULL),
               new_schedule_date = t_new_sched_date(j),
               ship_date = t_ship_date(j),
               receipt_date = t_receipt_date(j),
               new_order_placement_date = t_new_ord_plac_date(j),
               original_promised_date = t_orig_prom_date(j),
               request_date = t_req_date(j),
               posting_party_id = t_posting_party_id(j),
               carrier_code = t_carrier_code(j),
               vehicle_number = t_vehicle_number(j),
               container_type = t_container_type(j),
               container_qty = t_container_qty(j),
               tracking_number = t_tracking_number(j),
  	       end_order_publisher_id = t_end_ord_pub_id(j),
               ship_to_address = t_shipto_addr(j),
               ship_from_party_id = t_shipfrom_id(j),
               ship_to_party_id = t_shipto_id(j),
               ship_to_party_site_id = t_shipto_site_id(j),
               ship_to_party_name = t_shipto(j),
               ship_to_party_site_name = t_shipto_site(j),
               ship_from_party_site_id = t_shipfrom_site_id(j),
               ship_from_party_name = t_shipfrom(j),
               ship_from_party_site_name = t_shipfrom_site(j),
               end_order_publisher_site_id = t_end_ord_pub_site_id(j),
               end_order_publisher_site_name = t_end_ord_pub_site(j),
               end_order_publisher_name = t_end_order_pub(j),
               order_number = t_ord_num(j),
               release_number = t_rel_num(j),
               line_number = t_line_num(j),
               end_order_number = t_end_ord(j),
               end_order_rel_number = t_end_rel(j),
               end_order_line_number = t_end_line(j),
               ship_from_address = t_shipfrom_addr(j),
               publisher_address = t_pub_addr(j),
               customer_address = t_cust_addr(j),
               supplier_address = t_supp_addr(j),
               bill_of_lading_number = t_bill_of_lading(j),
               serial_number = t_serial_number(j),
               attachment_url = t_attach_url(j),
               version = t_version(j),
               designator = t_designator(j),
               context = t_context(j),
 	       attribute1 = t_attribute1(j),
               attribute2 = t_attribute2(j),
               attribute3 = t_attribute3(j),
               attribute4 = t_attribute4(j),
               attribute5 = t_attribute5(j),
               attribute6 = t_attribute6(j),
               attribute7 = t_attribute7(j),
               attribute8 = t_attribute8(j),
               attribute9 = t_attribute9(j),
               attribute10 = t_attribute10(j),
               attribute11 = t_attribute11(j),
               attribute12 = t_attribute12(j),
               attribute13 = t_attribute13(j),
               attribute14 = t_attribute14(j),
               attribute15 = t_attribute15(j),
               posting_party_name = t_posting_party_name(j),
               uom_code = nvl(t_uom(j),'Ea'),
               last_update_date = sysdate,
               last_updated_by = p_user_id
        WHERE  ROWID IN
	(SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
	  WHERE plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
               publisher_order_type IN (G_SALES_FORECAST,
				        G_ORDER_FORECAST,
				        G_SUPPLY_COMMIT,
				        G_HIST_SALES,
				        G_SELL_THRO_FCST,
				        G_SUPPLIER_CAP,
				        G_SAFETY_STOCK,
				        G_INTRANSIT,
				        g_replenishment,
				        G_PROJ_AVAI_BAL) AND
               NVL(key_date, sysdate) = NVL(t_key_date(j), sysdate) AND
               NVL(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(j), G_NULL_STRING)
       UNION ALL
	SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
	  WHERE plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
               publisher_order_type IN (G_PURCHASE_ORDER,
				        G_SALES_ORDER,
				        G_ASN,
				        G_SHIP_RECEIPT,
				        G_REQUISITION,
				        G_PO_ACKNOWLEDGEMENT,
			decode(G_CVMI_PROFILE  , 'Y' , G_CONS_ADVICE , -1 )) AND
			--Consigned CVMI Enh
               NVL(order_number, G_NULL_STRING) = NVL(t_ord_num(j), G_NULL_STRING) AND
               NVL(line_number, G_NULL_STRING) = NVL(t_line_num(j), G_NULL_STRING) AND
               NVL(release_number, G_NULL_STRING) = NVL(t_rel_num(j), G_NULL_STRING) AND
               NVL(end_order_number, G_NULL_STRING) = NVL(t_end_ord(j), G_NULL_STRING) AND
               NVL(end_order_rel_number, G_NULL_STRING) = NVL(t_end_rel(j), G_NULL_STRING) AND
	       NVL(end_order_line_number, G_NULL_STRING) = NVL(t_end_line(j), G_NULL_STRING)
       UNION ALL
	SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
	  WHERE plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
	       publisher_order_type = G_WORK_ORDER AND
               NVL(order_number, G_NULL_STRING) = NVL(t_ord_num(j), G_NULL_STRING)
       UNION ALL
	SELECT ROWID FROM MSC_SUP_DEM_ENTRIES
	  WHERE plan_id = G_PLAN_ID AND
               sr_instance_id = G_SR_INSTANCE_ID AND
               (nvl(quantity,0) <> 0 OR (Nvl(quantity,0) = 0 AND t_order_type(j) IN (G_ORDER_FORECAST, G_SUPPLY_COMMIT))) AND
               publisher_id = t_pub_id(j) AND
               publisher_site_id = t_pub_site_id(j) AND
               NVL(customer_id, G_NULL_STRING) = NVL(t_cust_id(j), G_NULL_STRING) AND
               NVL(customer_site_id, G_NULL_STRING) = NVL(t_cust_site_id(j), G_NULL_STRING) AND
               NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
               NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
               publisher_order_type = t_order_type(j) AND
               inventory_item_id = t_item_id(j) AND
               publisher_order_type IN (G_ALLOC_ONHAND,
				        G_UNALLOCATED_ONHAND)
	       );
  END;
	 /* sbala ADD CA */

  --log_debug('At 3');
      FOR j in t_line_id.FIRST..t_line_id.LAST LOOP
	 IF SQL%BULK_ROWCOUNT(j) = 0 THEN
	log_debug('j := ' ||  j);
            t_insert_id.EXTEND;
            t_ins_line_id.EXTEND;
            t_ins_pub.EXTEND;
            t_ins_pub_id.EXTEND;
            t_ins_pub_site.EXTEND;
            t_ins_pub_site_id.EXTEND;
            t_ins_pub_addr.EXTEND;
            t_ins_cust.EXTEND;
            t_ins_cust_id.EXTEND;
            t_ins_cust_site.EXTEND;
            t_ins_cust_site_id.EXTEND;
            t_ins_cust_addr.EXTEND;
            t_ins_supp.EXTEND;
            t_ins_supp_id.EXTEND;
            t_ins_supp_site.EXTEND;
            t_ins_supp_site_id.EXTEND;
            t_ins_supp_addr.EXTEND;
            t_ins_shipfrom.EXTEND;
            t_ins_shipfrom_id.EXTEND;
            t_ins_shipfrom_site.EXTEND;
            t_ins_shipfrom_site_id.EXTEND;
            t_ins_shipfrom_addr.EXTEND;
            t_ins_shipto.EXTEND;
            t_ins_shipto_id.EXTEND;
            t_ins_shipto_site.EXTEND;
            t_ins_shipto_site_id.EXTEND;
            t_ins_shipto_party_addr.EXTEND;
            t_ins_shipto_addr.EXTEND;
            t_ins_end_order_pub.EXTEND;
            t_ins_end_ord_pub_id.EXTEND;
            t_ins_end_ord_pub_site.EXTEND;
            t_ins_end_ord_pub_site_id.EXTEND;
            t_ins_order_type.EXTEND;
            t_ins_ot_desc.EXTEND;
            t_ins_end_order_type.EXTEND;
            t_ins_end_ot_desc.EXTEND;
            t_ins_bkt_type_desc.EXTEND;
            t_ins_bkt_type.EXTEND;
            t_ins_item_id.EXTEND;
            t_ins_base_item_id.EXTEND;
            t_ins_pri_uom.EXTEND;
            t_ins_pri_qty.EXTEND;
            t_ins_ref_uom.EXTEND;
            t_ins_ord_num.EXTEND;
            t_ins_rel_num.EXTEND;
            t_ins_line_num.EXTEND;
            t_ins_end_ord.EXTEND;
            t_ins_end_line.EXTEND;
            t_ins_end_rel.EXTEND;
            t_ins_key_date.EXTEND;
            t_ins_new_sched_date.EXTEND;
            t_ins_ship_date.EXTEND;
            t_ins_receipt_date.EXTEND;
            t_ins_new_ord_plac_date.EXTEND;
            t_ins_orig_prom_date.EXTEND;
            t_ins_req_date.EXTEND;
	    t_ins_wip_st_date.extend;
            t_ins_wip_end_date.extend;
            t_ins_uom.EXTEND;
            t_ins_quantity.EXTEND;
            t_ins_tp_quantity.EXTEND;
            t_ins_comments.EXTEND;
            t_ins_carrier_code.EXTEND;
            t_ins_bill_of_lading.EXTEND;
            t_ins_tracking_number.EXTEND;
            t_ins_vehicle_number.EXTEND;
            t_ins_container_type.EXTEND;
            t_ins_container_qty.EXTEND;
            t_ins_serial_number.EXTEND;
            t_ins_attach_url.EXTEND;
            t_ins_item_desc.EXTEND;
            t_ins_cust_item_desc.EXTEND;
            t_ins_supp_item_desc.EXTEND;
            t_ins_owner_item_desc.EXTEND;
            t_ins_item_name.EXTEND;
            t_ins_cust_item_name.EXTEND;
            t_ins_supp_item_name.EXTEND;
            t_ins_owner_item_name.EXTEND;
            t_ins_base_item_name.EXTEND;
            t_ins_version.EXTEND;
            t_ins_designator.EXTEND;
            t_ins_context.EXTEND;
	    t_ins_attribute1.EXTEND;
	    t_ins_attribute2.EXTEND;
	    t_ins_attribute3.EXTEND;
	    t_ins_attribute4.EXTEND;
	    t_ins_attribute5.EXTEND;
	    t_ins_attribute6.EXTEND;
	    t_ins_attribute7.EXTEND;
	    t_ins_attribute8.EXTEND;
	    t_ins_attribute9.EXTEND;
            t_ins_attribute10.EXTEND;
	    t_ins_attribute11.EXTEND;
	    t_ins_attribute12.EXTEND;
	    t_ins_attribute13.EXTEND;
	    t_ins_attribute14.EXTEND;
	    t_ins_attribute15.EXTEND;
            t_ins_posting_party_name.EXTEND;
            t_ins_posting_party_id.EXTEND;
	    t_ins_vmi_flag.extend;
	    t_ins_shipping_control.extend;
 	    t_ins_shipping_control_code.extend;
	    t_ins_planner_code.extend; --Bug 4424426

            t_insert_id(t_insert_id.COUNT)                := j;
            t_ins_line_id(t_insert_id.COUNT)              := t_line_id(j);
            t_ins_pub(t_insert_id.COUNT)                  := t_pub(j);
            t_ins_pub_id(t_insert_id.COUNT)               := t_pub_id(j);
            t_ins_pub_site(t_insert_id.COUNT)             := t_pub_site(j);
            t_ins_pub_site_id(t_insert_id.COUNT)          := t_pub_site_id(j);
            t_ins_pub_addr(t_insert_id.COUNT)             := t_pub_addr(j);
            t_ins_cust(t_insert_id.COUNT)                 := t_cust(j);
            t_ins_cust_id(t_insert_id.COUNT)              := t_cust_id(j);
            t_ins_cust_site(t_insert_id.COUNT)            := t_cust_site(j);
            t_ins_cust_site_id(t_insert_id.COUNT)         := t_cust_site_id(j);
            t_ins_cust_addr(t_insert_id.COUNT)            := t_cust_addr(j);
            t_ins_supp(t_insert_id.COUNT)                 := t_supp(j);
            t_ins_supp_id(t_insert_id.COUNT)              := t_supp_id(j);
            t_ins_supp_site(t_insert_id.COUNT)            := t_supp_site(j);
            t_ins_supp_site_id(t_insert_id.COUNT)         := t_supp_site_id(j);
            t_ins_supp_addr(t_insert_id.COUNT)            := t_supp_addr(j);
            t_ins_shipfrom(t_insert_id.COUNT)             := t_shipfrom(j);
            t_ins_shipfrom_id(t_insert_id.COUNT)          := t_shipfrom_id(j);
            t_ins_shipfrom_site(t_insert_id.COUNT)        := t_shipfrom_site(j);
            t_ins_shipfrom_site_id(t_insert_id.COUNT)     := t_shipfrom_site_id(j);
            t_ins_shipfrom_addr(t_insert_id.COUNT)        := t_shipfrom_addr(j);
            t_ins_shipto(t_insert_id.COUNT)               := t_shipto(j);
            t_ins_shipto_id(t_insert_id.COUNT)            := t_shipto_id(j);
            t_ins_shipto_site(t_insert_id.COUNT)          := t_shipto_site(j);
            t_ins_shipto_site_id(t_insert_id.COUNT)       := t_shipto_site_id(j);
            t_ins_shipto_party_addr(t_insert_id.COUNT)    := t_shipto_party_addr(j);
            t_ins_shipto_addr(t_insert_id.COUNT)          := t_shipto_addr(j);
            t_ins_end_order_pub(t_insert_id.COUNT)        := t_end_order_pub(j);
            t_ins_end_ord_pub_id(t_insert_id.COUNT)       := t_end_ord_pub_id(j);
            t_ins_end_ord_pub_site(t_insert_id.COUNT)     := t_end_ord_pub_site(j);
            t_ins_end_ord_pub_site_id(t_insert_id.COUNT)  := t_end_ord_pub_site_id(j);
            t_ins_order_type(t_insert_id.COUNT)           := t_order_type(j);
            t_ins_ot_desc(t_insert_id.COUNT)              := t_ot_desc(j);
            t_ins_end_order_type(t_insert_id.COUNT)       := t_end_order_type(j);
            t_ins_end_ot_desc(t_insert_id.COUNT)          := t_end_ot_desc(j);
            t_ins_bkt_type_desc(t_insert_id.COUNT)        := t_bkt_type_desc(j);
            t_ins_bkt_type(t_insert_id.COUNT)             := t_bkt_type(j);
	    log_debug('Bkt Type = ' || t_ins_bkt_type(t_insert_id.COUNT));
            t_ins_item_id(t_insert_id.COUNT)              := t_item_id(j);
            t_ins_ord_num(t_insert_id.COUNT)              := t_ord_num(j);
            t_ins_rel_num(t_insert_id.COUNT)              := t_rel_num(j);
            t_ins_line_num(t_insert_id.COUNT)             := t_line_num(j);
            t_ins_end_ord(t_insert_id.COUNT)              := t_end_ord(j);
            t_ins_end_line(t_insert_id.COUNT)             := t_end_line(j);
            t_ins_end_rel(t_insert_id.COUNT)              := t_end_rel(j);
            t_ins_key_date(t_insert_id.COUNT)             := t_key_date(j);
            t_ins_new_sched_date(t_insert_id.COUNT)       := t_new_sched_date(j);
            t_ins_ship_date(t_insert_id.COUNT)            := t_ship_date(j);
            t_ins_receipt_date(t_insert_id.COUNT)         := t_receipt_date(j);
            t_ins_new_ord_plac_date(t_insert_id.COUNT)    := t_new_ord_plac_date(j);
            t_ins_orig_prom_date(t_insert_id.COUNT)       := t_orig_prom_date(j);
            t_ins_req_date(t_insert_id.COUNT)             := t_req_date(j);
	    /* Added for work order support */
            t_ins_wip_st_date(t_insert_id.COUNT)          := t_wip_st_date(j);
            t_ins_wip_end_date(t_insert_id.COUNT)         := t_wip_end_date(j);
            t_ins_uom(t_insert_id.COUNT)                  := nvl(t_uom(j),'Ea');
            t_ins_quantity(t_insert_id.COUNT)             := t_quantity(j);
            t_ins_comments(t_insert_id.COUNT)             := t_comments(j);
            t_ins_carrier_code(t_insert_id.COUNT)         := t_carrier_code(j);
            t_ins_bill_of_lading(t_insert_id.COUNT)       := t_bill_of_lading(j);
            t_ins_tracking_number(t_insert_id.COUNT)      := t_tracking_number(j);
            t_ins_vehicle_number(t_insert_id.COUNT)       := t_vehicle_number(j);
            t_ins_container_type(t_insert_id.COUNT)       := t_container_type(j);
            t_ins_container_qty(t_insert_id.COUNT)        := t_container_qty(j);
            t_ins_serial_number(t_insert_id.COUNT)        := t_serial_number(j);
            t_ins_attach_url(t_insert_id.COUNT)           := t_attach_url(j);
            t_ins_version(t_insert_id.COUNT)              := t_version(j);
            t_ins_designator(t_insert_id.COUNT)           := t_designator(j);
            t_ins_context(t_insert_id.COUNT)              := t_context(j);
            t_ins_attribute1(t_insert_id.COUNT)           := t_attribute1(j);
            t_ins_attribute2(t_insert_id.COUNT)           := t_attribute2(j);
            t_ins_attribute3(t_insert_id.COUNT)           := t_attribute3(j);
            t_ins_attribute4(t_insert_id.COUNT)           := t_attribute4(j);
            t_ins_attribute5(t_insert_id.COUNT)           := t_attribute5(j);
            t_ins_attribute6(t_insert_id.COUNT)           := t_attribute6(j);
            t_ins_attribute7(t_insert_id.COUNT)           := t_attribute7(j);
            t_ins_attribute8(t_insert_id.COUNT)           := t_attribute8(j);
            t_ins_attribute9(t_insert_id.COUNT)           := t_attribute9(j);
            t_ins_attribute10(t_insert_id.COUNT)          := t_attribute10(j);
            t_ins_attribute11(t_insert_id.COUNT)          := t_attribute11(j);
            t_ins_attribute12(t_insert_id.COUNT)          := t_attribute12(j);
            t_ins_attribute13(t_insert_id.COUNT)          := t_attribute13(j);
            t_ins_attribute14(t_insert_id.COUNT)          := t_attribute14(j);
            t_ins_attribute15(t_insert_id.COUNT)          := t_attribute15(j);
            t_ins_posting_party_name(t_insert_id.COUNT)   := t_posting_party_name(j);
            t_ins_posting_party_id(t_insert_id.COUNT)     := t_posting_party_id(j);

	    --===========================================================
	    -- Determine if item is VMI enabled for requisitions,
	    -- purchase orders, allocated onhand, shipment receipts,
	    -- and ASN's
	    --===========================================================
	log_debug('At 4');
	    l_vmi_flag := 0;
	    l_vmi_auto_replenish_flag := 'N';
	    IF (t_ins_order_type(t_insert_id.COUNT) in (g_purchase_order,
					g_requisition,
					g_alloc_onhand,
					g_ship_receipt,
					G_ASN)) THEN
	       OPEN c_vmi_item(t_supp(j),
			       t_supp_site(j),
			       t_cust_site(j),
			       t_item_id(j));
	       FETCH c_vmi_item
		 INTO l_vmi_flag,
		 l_vmi_auto_replenish_flag;

	       CLOSE c_vmi_item;

	       IF (l_vmi_flag = 1)THEN
		  t_ins_vmi_flag(t_insert_id.COUNT) := 1;
		ELSE
		  t_ins_vmi_flag(t_insert_id.COUNT) := NULL;
	       END IF;
	     ELSE
	       t_ins_vmi_flag(t_insert_id.COUNT) := NULL;
	    END IF;

	log_debug('At 5');
            --==========================================================================
            -- Obtain master item information
            --==========================================================================
            select item_name,
                   description
            into   l_item_name,
                   l_desc
            from   msc_items
            where  inventory_item_id = t_item_id(j);

            t_ins_item_desc(t_insert_id.COUNT) := l_desc;
            t_ins_item_name(t_insert_id.COUNT) := l_item_name;

            --==========================================================================
            -- Obtain owner item information
            --==========================================================================
            BEGIN
                 select msi.item_name,
                       msi.description,
                       msi.uom_code,
                       msi.base_item_id,
                       itm.item_name,
		       msi.planner_code--Bug 4424426
                into   l_item_name,
                       l_desc,
                       l_uom,
                       l_base_item_id,
                       l_base_item_name,
		       l_planner_code--Bug 4424426
                from   msc_system_items msi,
                       msc_items itm,
                       msc_trading_partners part,
                       msc_trading_partner_maps map
                where  msi.inventory_item_id = t_item_id(j) and
                       msi.organization_id = part.sr_tp_id and
                       msi.sr_instance_id = part.sr_instance_id and
                       msi.plan_id = -1 and
                       itm.inventory_item_id (+)= msi.base_item_id and
                       part.partner_id = map.tp_key and
                       map.map_type = 2 and
                       map.company_key = t_pub_site_id(j) and
                       nvl(part.company_id,1) = t_pub_id(j);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
		   open publisher_is_supplier_c(
			  t_item_id(j),
                        t_cust_site_id(j),
                        t_pub_id(j),
                        t_pub_site_id(j)
                      );
                 fetch publisher_is_supplier_c
                 into  l_item_name,
                       l_desc,
                       l_uom,
                       l_base_item_id,
                       l_base_item_name,
		       l_planner_code;--Bug 4424426

                 if publisher_is_supplier_c%NOTFOUND then
                   close publisher_is_supplier_c;
                   BEGIN
                      select distinct mic.customer_item_name,
                             mic.description,
                             mic.uom_code,
                             to_number(null),
                             to_char(null),
			     mic.planner_code--Bug 4424426
                      into   l_item_name,
                             l_desc,
                             l_uom,
                             l_base_item_id,
                             l_base_item_name,
			     l_planner_code--Bug 4424426
                      from   msc_item_customers mic,
                             msc_trading_partner_maps map,
                             msc_trading_partner_maps map1,
                             msc_company_relationships r
                      where  mic.inventory_item_id = t_item_id(j) and
                             mic.plan_id = -1 and
                             mic.customer_id = map.tp_key and
			     --NVL(mic.customer_site_id, map1.tp_key) = map1.tp_key and
			     mic.customer_site_id = map1.tp_key and
                             map.map_type = 1 and
                             map.company_key = r.relationship_id and
                             r.relationship_type = 1 and
                             r.subject_id = 1 and
                             r.object_id = t_pub_id(j) and
                             map1.map_type = 3 and
                             map1.company_key = t_pub_site_id(j);
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                        l_item_name := null;
                        l_base_item_id := null;
                        l_base_item_name := null;
			l_planner_code := null;--Bug 4424426
                        l_desc      := null;
                        --l_uom       := nvl(t_uom(j),'Ea');
                        begin
			   select msi.uom_code,
	                          msi.base_item_id,
                                  itm.item_name
			   into   l_uom,
				  l_base_item_id,
				  l_base_item_name
			   from   msc_system_items msi,
	                          msc_items itm,
			          msc_trading_partners part,
                                  msc_trading_partner_maps map
                           where  itm.inventory_item_id (+)=
					msi.base_item_id and
                                  msi.inventory_item_id = t_item_id(j) and
                                  msi.organization_id = part.sr_tp_id and
                                  msi.sr_instance_id = part.sr_instance_id and
                                  msi.plan_id = -1 and
                                  part.partner_id = map.tp_key and
                                  map.map_type = 2 and
			          map.company_key = Decode(t_supp_id(j),
						      t_pub_id(j), t_cust_site_id(j),
						      t_supp_site_id(j)) and
			          nvl(part.company_id,1) = Decode(t_supp_id(j),
							     t_pub_id(j), t_cust_id(j),
							     t_supp_id(j));
			exception
			   when others then
			      l_uom := 'Ea';
			end;
                    END;
                 else
                   close publisher_is_supplier_c;
                 end if;
            END;
            t_ins_owner_item_name(t_insert_id.COUNT) := l_item_name;
            t_ins_owner_item_desc(t_insert_id.COUNT) := l_desc;
            t_ins_pri_uom(t_insert_id.COUNT)         := l_uom; --NVL(l_uom, nvl(t_uom(j),'Ea'));

            t_ins_base_item_name(t_insert_id.COUNT) := l_base_item_name;
            t_ins_base_item_id(t_insert_id.COUNT) := l_base_item_id;

	     t_ins_planner_code(t_insert_id.COUNT) := l_planner_code; --Bug 4424426

	     log_debug('Planner Code = ' || l_planner_code);--Bug 4424426


            if t_ins_order_type(t_insert_id.COUNT) NOT IN (G_UNALLOCATED_ONHAND, g_safety_stock, g_proj_avai_bal) then
              --==================================================================================
              --Obtain customer item information
              --==================================================================================
              BEGIN
                select msi.item_name,
                       msi.description,
                       msi.uom_code
                into   l_item_name,
                       l_desc,
                       l_uom
                from   msc_system_items msi,
                       msc_trading_partners part,
                       msc_trading_partner_maps map
                where  msi.plan_id = -1 and
                       msi.inventory_item_id = t_item_id(j) and
                       msi.organization_id = part.sr_tp_id and
                       msi.sr_instance_id = part.sr_instance_id and
                       part.partner_id = map.tp_key and
                       map.map_type = 2 and
                       map.company_key = nvl(t_cust_site_id(j), t_pub_site_id(j))  and
                       nvl(part.company_id,1) = nvl(t_cust_id(j), t_pub_id(j));
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  BEGIN
                    select distinct mic.customer_item_name,
                           mic.description,
                           mic.uom_code
                    into   l_item_name,
                           l_desc,
                           l_uom
                    from   msc_item_customers mic,
                           msc_trading_partner_maps map,
                           msc_trading_partner_maps map1,
                           msc_company_relationships r
                    where  mic.inventory_item_id = t_item_id(j) and
                           mic.plan_id = -1 and
                           mic.customer_id = map.tp_key and
		           --NVL(mic.customer_site_id, map1.tp_key) = map1.tp_key and
		           mic.customer_site_id = map1.tp_key and
                           map.map_type = 1 and
                           map.company_key = r.relationship_id and
                           r.relationship_type = 1 and
                           r.subject_id = 1 and
                           r.object_id = nvl(t_cust_id(j), t_pub_id(j)) and
                           map1.map_type = 3 and
                           map1.company_key = nvl(t_cust_site_id(j), t_pub_site_id(j));
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      l_item_name := null;
                      l_desc := null;
                      l_uom := null;
                  END;
              END;
              t_ins_cust_item_name(t_insert_id.COUNT) := l_item_name;
              t_ins_cust_item_desc(t_insert_id.COUNT) := l_desc;

              if t_cust_id(j) <> t_pub_id(j) then
                 --t_ins_ref_uom(t_insert_id.COUNT) := NVL(l_uom, t_uom(j));
                 t_ins_ref_uom(t_insert_id.COUNT) := NVL(l_uom, t_ins_pri_uom(t_insert_id.COUNT));
              end if;

              --=============================================================================
              -- Obtain supplier item information
              --=============================================================================
              BEGIN
                select msi.item_name,
                       msi.description,
                       msi.uom_code
                into   l_item_name,
                       l_desc,
                       l_uom
                from   msc_system_items msi,
                       msc_trading_partners part,
                       msc_trading_partner_maps map
                where  msi.plan_id = -1 and
                       msi.inventory_item_id = t_item_id(j) and
                       msi.organization_id = part.sr_tp_id and
                       msi.sr_instance_id = part.sr_instance_id and
                       part.partner_id = map.tp_key and
                       map.map_type = 2 and
                       map.company_key = nvl(t_supp_site_id(j), t_pub_site_id(j)) and
                       nvl(part.company_id,1) = nvl(t_supp_id(j), t_pub_id(j)) ;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  OPEN supplier_item_c (
                         t_item_id(j),
                         t_cust_site_id(j),
                         t_pub_id(j),
                         t_pub_site_id(j),
                         t_supp_id(j),
                         t_supp_site_id(j)
                       );
                  FETCH supplier_item_c
                  INTO  l_item_name,
                        l_desc,
                        l_uom;

                  IF supplier_item_c%NOTFOUND then
                    l_item_name := null;
                    l_desc := null;
                    l_uom := null;
                  END IF;

                  CLOSE supplier_item_c;
              END;
              t_ins_supp_item_name(t_insert_id.COUNT) := l_item_name;
              t_ins_supp_item_desc(t_insert_id.COUNT) := l_desc;

              if t_supp_id(j) <> t_pub_id(j) then
                 --t_ins_ref_uom(t_insert_id.COUNT) := NVL(l_uom, t_uom(j));
                 t_ins_ref_uom(t_insert_id.COUNT) := NVL(l_uom, t_ins_pri_uom(t_insert_id.COUNT));
              end if;

            END IF; --if t_ins_order_type <> Unalloc

            --================================================================
            --Obtain the tp uom, primary quantity and tp quantity
            --================================================================

            msc_x_util.get_uom_conversion_rates(t_uom(j),
                                                t_ins_pri_uom(t_insert_id.COUNT),
                                                t_item_id(j),
                                                l_conversion_found,
                                                l_conversion_rate);
            IF l_conversion_found THEN
              t_ins_pri_qty(t_insert_id.COUNT) := round(t_quantity(j)*l_conversion_rate, 6);
            ELSE
              t_ins_pri_qty(t_insert_id.COUNT) := round(t_quantity(j), 6);
            END IF;

            IF t_ins_order_type(t_insert_id.COUNT) NOT IN (g_unallocated_onhand, g_safety_stock, g_proj_avai_bal) THEN
              msc_x_util.get_uom_conversion_rates(t_uom(j),
                                                t_ins_ref_uom(t_insert_id.COUNT),
                                                t_item_id(j),
                                                l_conversion_found,
                                                l_conversion_rate);
              IF l_conversion_found THEN
                t_ins_tp_quantity(t_insert_id.COUNT) := round(t_quantity(j)*l_conversion_rate, 6);
              ELSE
                t_ins_tp_quantity(t_insert_id.COUNT) := round(t_quantity(j), 6);
              END IF;

            END IF; --t_ins_order_type <> Unalloc

       -- jguo: added code starts here

       IF t_ins_order_type(t_insert_id.COUNT) IN ( G_PURCHASE_ORDER
                                                 , G_ORDER_FORECAST
                                                 , G_REQUISITION
                                                 , G_SUPPLY_COMMIT
                                                 , G_NEGOTIATED_CAPACITY
                                                 , G_PO_ACKNOWLEDGEMENT
                                                 , G_SALES_ORDER
                                                 , G_SHIP_RECEIPT
                                                 , G_ASN
                                                 ) THEN
		  IF ((t_ins_supp_id (t_insert_id.COUNT) = 1) OR -- if OEM is supplier or supplier=publisher
				(t_ins_supp_id (t_insert_id.COUNT) = t_ins_pub_id (t_insert_id.COUNT))) THEN --- Bug #6274985
        OPEN c_shipping_control_meaning (
		     MSC_X_UTIL.GET_SHIPPING_CONTROL_ID
             ( NVL(t_ins_cust_id(t_insert_id.COUNT), t_ins_pub_id(t_insert_id.COUNT))
             , NVL(t_ins_cust_site_id(t_insert_id.COUNT), t_ins_pub_site_id(t_insert_id.COUNT))
             , NVL(t_ins_supp_id(t_insert_id.COUNT), t_ins_pub_id(t_insert_id.COUNT))
             , NVL(t_ins_supp_site_id(t_insert_id.COUNT), t_ins_pub_site_id(t_insert_id.COUNT))
             )
           );
           FETCH c_shipping_control_meaning INTO t_ins_shipping_control(t_insert_id.COUNT),
						 t_ins_shipping_control_code(t_insert_id.COUNT);
           CLOSE c_shipping_control_meaning;
         END IF;
       END IF;

      -- jguo: added code ends here

          END IF;
        END LOOP;
      end if;

      log_debug('Before Insert');
      if t_insert_id IS NOT NULL and t_insert_id.COUNT > 0 THEN
	 log_debug('At 6' || ' t_insert_id.COUNT := ' || t_insert_id.COUNT);
        FORALL i in t_insert_id.FIRST..t_insert_id.LAST

          INSERT INTO msc_sup_dem_entries (
           ref_header_id,
           ref_line_id,
           transaction_id,
           plan_id,
           sr_instance_id,
           publisher_name,
           publisher_id,
           publisher_site_name,
           publisher_site_id,
           publisher_address,
           customer_name,
           customer_id,
           customer_site_name,
           customer_site_id,
           customer_address,
           supplier_name,
           supplier_id,
           supplier_site_name,
           supplier_site_id,
           supplier_address,
           ship_from_party_name,
           ship_from_party_id,
           ship_from_party_site_name,
           ship_from_party_site_id,
           ship_from_address,
           ship_to_party_name,
           ship_to_party_id,
           ship_to_party_site_name,
           ship_to_party_site_id,
           ship_to_address,
           end_order_publisher_name,
           end_order_publisher_id,
           end_order_publisher_site_name,
           end_order_publisher_site_id,
           publisher_order_type,
           publisher_order_type_desc,
           end_order_type,
	   end_order_type_desc,
           tp_order_type_desc,
           bucket_type_desc,
           bucket_type,
           inventory_item_id,
           primary_uom,
           primary_quantity,
           tp_uom_code,
           order_number,
           release_number,
           line_number,
           end_order_number,
           end_order_line_number,
           end_order_rel_number,
           key_date,
           need_by_date, -- bug 3596556
           new_schedule_date,
           ship_date,
           receipt_date,
           new_order_placement_date,
           original_promised_date,
	   request_date,
	   /* Added for work order support */
           wip_start_date,
           wip_end_date,
           uom_code,
           quantity,
           tp_quantity,
           comments,
           carrier_code,
           bill_of_lading_number,
           tracking_number,
           vehicle_number,
           container_type,
           container_qty,
           serial_number,
           attachment_url,
           last_refresh_number,
           posting_party_name,
           posting_party_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           item_name,
           owner_item_name,
           customer_item_name,
           supplier_item_name,
           item_description,
           customer_item_description,
           supplier_item_description,
           owner_item_description,
           version,
           designator,
	   context,
	   vmi_flag,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
	   base_item_id,
           base_item_name
           , shipping_control
           , shipping_control_code
	   ,planner_code--Bug 4424426
          ) VALUES (
           p_header_id,
           t_ins_line_id(i),
           msc_sup_dem_entries_s.nextval,
           G_PLAN_ID,
           G_SR_INSTANCE_ID,
           t_ins_pub(i),
           t_ins_pub_id(i),
           t_ins_pub_site(i),
           t_ins_pub_site_id(i),
           t_ins_pub_addr(i),
           t_ins_cust(i),
           t_ins_cust_id(i),
           t_ins_cust_site(i),
           t_ins_cust_site_id(i),
           t_ins_cust_addr(i),
           t_ins_supp(i),
           t_ins_supp_id(i),
           t_ins_supp_site(i),
           t_ins_supp_site_id(i),
           t_ins_supp_addr(i),
           t_ins_shipfrom(i),
           t_ins_shipfrom_id(i),
           t_ins_shipfrom_site(i),
           t_ins_shipfrom_site_id(i),
           t_ins_shipfrom_addr(i),
           t_ins_shipto(i),
           t_ins_shipto_id(i),
           t_ins_shipto_site(i),
           t_ins_shipto_site_id(i),
           t_ins_shipto_addr(i),
           t_ins_end_order_pub(i),
           t_ins_end_ord_pub_id(i),
           t_ins_end_ord_pub_site(i),
           t_ins_end_ord_pub_site_id(i),
           t_ins_order_type(i),
           t_ins_ot_desc(i),
           t_ins_end_order_type(i),
        t_ins_end_ot_desc(i),
           t_ins_end_ot_desc(i),
           t_ins_bkt_type_desc(i),
           t_ins_bkt_type(i),
           t_ins_item_id(i),
           t_ins_pri_uom(i),
           t_ins_pri_qty(i),
           t_ins_ref_uom(i),
           t_ins_ord_num(i),
           t_ins_rel_num(i),
           t_ins_line_num(i),
           t_ins_end_ord(i),
           t_ins_end_line(i),
           t_ins_end_rel(i),
           t_ins_key_date(i),
           DECODE(t_ins_order_type(i), G_PURCHASE_ORDER, t_ins_key_date(i), NULL), -- need_by_date bug 3596556
           t_ins_new_sched_date(i),
           t_ins_ship_date(i),
           t_ins_receipt_date(i),
           t_ins_new_ord_plac_date(i),
           t_ins_orig_prom_date(i),
	   t_ins_req_date(i),
	   /* Added for Work order support */
           Nvl(t_ins_wip_st_date(i), t_ins_wip_end_date(i)),
           t_ins_wip_end_date(i),
           t_ins_uom(i),
           nvl(t_ins_quantity(i),0),
           t_ins_tp_quantity(i),
           t_ins_comments(i),
           t_ins_carrier_code(i),
           t_ins_bill_of_lading(i),
           t_ins_tracking_number(i),
           t_ins_vehicle_number(i),
           t_ins_container_type(i),
           t_ins_container_qty(i),
           t_ins_serial_number(i),
           t_ins_attach_url(i),
           msc_cl_refresh_s.nextval,
           t_posting_party_name(i),
           t_posting_party_id(i),
           p_user_id,
           sysdate,
           p_user_id,
           sysdate,
           t_ins_item_name(i),
           t_ins_owner_item_name(i),
           t_ins_cust_item_name(i),
           t_ins_supp_item_name(i),
           nvl(t_ins_item_desc(i), t_ins_owner_item_desc(i)),
           t_ins_cust_item_desc(i),
           t_ins_supp_item_desc(i),
           t_ins_owner_item_desc(i),
           t_ins_version(i),
           t_ins_designator(i),
	   t_ins_context(i),
	   t_ins_vmi_flag(i),
	   t_ins_attribute1(i),
           t_ins_attribute2(i),
           t_ins_attribute3(i),
           t_ins_attribute4(i),
           t_ins_attribute5(i),
           t_ins_attribute6(i),
           t_ins_attribute7(i),
           t_ins_attribute8(i),
           t_ins_attribute9(i),
           t_ins_attribute10(i),
           t_ins_attribute11(i),
           t_ins_attribute12(i),
           t_ins_attribute13(i),
           t_ins_attribute14(i),
           t_ins_attribute15(i),
           t_ins_base_item_id(i),
	   t_ins_base_item_name(i)
           , t_ins_shipping_control(i)
           , t_ins_shipping_control_code(i)
	   , t_ins_planner_code(i)--Bug 4424426
          );
    end if;

    --commit;

END replace_supdem_entries;


PROCEDURE change_date_format (
  p_string IN OUT NOCOPY VARCHAR2
) IS
 tmpDate DATE;
BEGIN
  SELECT to_date(p_string, 'YYYYMMDD HH24MISS')
  INTO   tmpDate
  FROM   dual;

  SELECT to_char(tmpDate, 'DD/MM/YYYY HH24:MI:SS')
  INTO   p_string
  FROM   dual;

EXCEPTION when others then
   LOG_MESSAGE('Error in msc_sce_loads_pkg.change_date_format');
   LOG_MESSAGE(SQLERRM);

END change_date_format;


PROCEDURE LOG_MESSAGE(
    p_string IN VARCHAR2
) IS
BEGIN
  IF fnd_global.conc_request_id > 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_string);
  ELSE
    --DBMS_OUTPUT.PUT_LINE( p_string);
    null;
  END IF;
END LOG_MESSAGE;


PROCEDURE POST_PROCESS(
  p_header_id IN NUMBER
) IS

  t_pri_qty           qtyList;
  t_tp_qty            qtyList;
  t_number1           qtyList;
  t_item_id           itemidList;
  t_end_order_num     endordList;
  t_end_ord_rel_num   endrelList;
  t_end_ord_line_num  endlineList;
  t_end_order_num1    endordList;
  t_end_ord_rel_num1  endrelList;
  t_end_ord_line_num1 endlineList;
  t_extract_date      keydateList;
  t_pub_id            publishidList;
  t_pub_site_id       pubsiteidList;
  t_supp_id           suppidList;
  t_supp_site_id      suppsiteList;
  t_cust_id           custidList;
  t_cust_site_id      custsiteidList;
  t_last_update_date  lastupdatedateList;  --Fix for bug 5599903
  t_last_updated_by   lastupdatedbyList;
  t_sync_id           syncList; --- Fix for bug 6147298
  t_del_qty           delqtyList; --- Fix for bug 6147298

  --=====================================
  --All the ASN's pegged to PO's
  --=====================================
  cursor c_asn_pegged_to_po(
    p_header_id IN NUMBER
  ) IS
  select sd1.primary_quantity,
         sd1.tp_quantity,
         sd1.number1,
         sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.customer_id,
         sd1.customer_site_id,
         sd1.end_order_number,
         sd1.end_order_rel_number,
         sd1.end_order_line_number,
	 sd1.last_update_date,  --Fix for bug 5599903
	 sd1.last_updated_by,
	 ln.sync_indicator, --Fix for bug 6147298
         ln.quantity
  from   msc_sup_dem_entries sd1,
	 msc_supdem_lines_interface ln
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type = 15  and --ASN
         sd1.end_order_type = 13 and  --PO
	 ln.parent_header_id = p_header_id and
	 sd1.item_name = ln.item_name and
         sd1.end_order_number = ln.pegging_order_identifier and
         nvl(sd1.end_order_rel_number, -99) = nvl(ln.ref_release_number, -99) and
         nvl(sd1.end_order_line_number, -99) = nvl(ln.ref_line_number, -99) and
	 nvl(sd1.order_number, -99) = nvl(ln.order_identifier, -99) and
         nvl(sd1.release_number, -99) = nvl(ln.release_number, -99) and
         nvl(sd1.line_number, -99) = nvl(ln.line_number, -99); --- Fix for bug 6147298


  --=====================================
  --All the ASN's pegged to SO's
  --=====================================
  cursor c_asn_pegged_to_so(
    p_header_id IN NUMBER
  ) IS
  select sd1.primary_quantity,
         sd1.tp_quantity,
         sd1.number1,
         sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.customer_id,
         sd1.customer_site_id,
         sd1.end_order_number,
         sd1.end_order_rel_number,
         sd1.end_order_line_number,
         sd2.end_order_number,
         sd2.end_order_rel_number,
         sd2.end_order_line_number
  from   msc_sup_dem_entries sd1,
         msc_sup_dem_entries sd2
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type = 15  and --ASN
         sd1.end_order_type = 14 and  --SO pegged to the ASN
         sd2.plan_id = sd1.plan_id and
         sd2.publisher_order_type = 14 and
         sd2.end_order_type = 13 and --PO pegged to the SO
         sd2.inventory_item_id = sd1.inventory_item_id and
         sd2.publisher_id = sd1.publisher_id and
         sd2.publisher_site_id = sd1.publisher_site_id and
         sd2.customer_id = sd1.customer_id and
         sd2.customer_site_id = sd1.customer_site_id and
         sd2.order_number = sd1.end_order_number and
         nvl(sd2.release_number, -99) = nvl(sd1.end_order_rel_number, -99) and
         nvl(sd2.line_number, -99) = nvl(sd1.end_order_line_number,-99);

  --=====================================
  --All the Receipt's pegged to ASN's
  --=====================================
  CURSOR c_receipts_pegged_to_asn(
    p_header_id IN Number
  ) IS
  select sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.supplier_id,
         sd1.supplier_site_id,
         sd1.end_order_number,
         sd1.end_order_rel_number,
         sd1.end_order_line_number
  from   msc_sup_dem_entries sd1
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type = 16 and --Shipment Receipt
         sd1.end_order_type = 15; --ASN

  --=====================================
  --All the Receipt's pegged to PO's
  --=====================================
  CURSOR c_receipts_pegged_to_po(
    p_header_id IN Number
  ) IS
  select sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.supplier_id,
         sd1.supplier_site_id,
         sd1.end_order_number,
         sd1.end_order_rel_number,
         sd1.end_order_line_number
  from   msc_sup_dem_entries sd1
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type = 16 and --Shipment Receipt
         sd1.end_order_type = 13; --PO

  CURSOR c_receipts_pegged_to_po1(
    p_header_id IN Number
  ) IS
  select sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.supplier_id,
         sd1.supplier_site_id,
         sd2.order_number,
         sd2.release_number,
         sd2.line_number
  from   msc_sup_dem_entries sd1,
         msc_sup_dem_entries sd2
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type = 16 and
         sd1.end_order_type = 13 and
         sd2.plan_id = sd1.plan_id and
         sd2.inventory_item_id = sd1.inventory_item_id and
         sd2.publisher_id = sd1.supplier_id and
         sd2.publisher_site_id = sd1.supplier_site_id and
         sd2.customer_id = sd1.publisher_id and
         sd2.customer_site_id = sd1.publisher_site_id and
         sd2.publisher_order_type = 14 and
         sd2.end_order_type = 13 and
         sd2.end_order_number = sd1.end_order_number and
         nvl(sd2.end_order_rel_number, -99) = nvl(sd1.end_order_rel_number, -99) and
         nvl(sd2.end_order_line_number, -99) = nvl(sd1.end_order_line_number, -99);

  --=====================================
  --All the Onhand records
  --=====================================
  CURSOR c_onhand_records(
    p_header_id IN Number
  ) IS
  select sd1.inventory_item_id,
         sd1.publisher_id,
         sd1.publisher_site_id,
         sd1.new_schedule_date
  from   msc_sup_dem_entries sd1
  where  sd1.ref_header_id = p_header_id and
         sd1.plan_id = -1 and
         sd1.publisher_order_type in (9,10); --Allocated + Unallocated onhand

BEGIN
  --==================================
  --ASN's pegged to PO's
  --==================================
  --dbms_output.put_line('Opening c_asn_pegged_to_po');
  open c_asn_pegged_to_po(p_header_id);
  fetch c_asn_pegged_to_po
  bulk collect into  t_pri_qty,
        t_tp_qty,
        t_number1,
        t_item_id,
        t_pub_id,
        t_pub_site_id,
        t_cust_id,
        t_cust_site_id,
        t_end_order_num,
        t_end_ord_rel_num,
        t_end_ord_line_num,
	t_last_update_date,
	t_last_updated_by, --Fix for bug 5599903
	t_sync_id,
        t_del_qty; --Fix for bug 6147298

  close c_asn_pegged_to_po;

  --dbms_output.put_line('Records fetched := ' || t_pri_qty.COUNT);

  --==================================
  --Consume PO quantity
  --==================================
  if (t_pri_qty is not null) and (t_pri_qty.COUNT > 0 ) THEN

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.number1 = DECODE(t_sync_id(j),'R',sd.primary_quantity,'D',sd.number1) --Fix for bug 6147298
    where  sd.publisher_order_type = 13 and --PO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.primary_quantity = DECODE(t_sync_id(j),'R',round(sd.primary_quantity - decode(t_number1(j),NULL,t_tp_qty(j),Decode(t_pri_qty(j),0, -t_number1(j), t_tp_qty(j) - (t_number1(j)/Decode(t_pri_qty(j),0,1,t_pri_qty(j)))*t_tp_qty(j))), 6),
				'D',round(sd.primary_quantity + t_del_qty(j),6)),
           sd.tp_quantity = DECODE(t_sync_id(j),'R',round(sd.tp_quantity - decode(t_number1(j),NULL,t_pri_qty(j),t_pri_qty(j)-t_number1(j)), 6),'D',round(sd.tp_quantity + t_del_qty(j),6)) --Fix for bug 6147298
    where  sd.publisher_order_type = 13 and --PO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = get_quantity(sd.primary_quantity, sd.primary_uom, sd.uom_code, sd.inventory_item_id),
	   sd.last_updated_by = t_last_updated_by(j),
	   sd.last_update_date = t_last_update_date(j)   --Fix for bug 5599903
    where  sd.publisher_order_type = 13 and --PO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;



   --==================================
   --Consume SO quantity
   --==================================
   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.number1 = sd.primary_quantity
    where  sd.publisher_order_type = 14 and --SO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.end_order_number = t_end_order_num(j) and
           nvl(sd.end_order_rel_number, -99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.end_order_line_number, -99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;


   FORALL j in t_pri_qty.FIRST..t_pri_qty.last
    update msc_sup_dem_entries sd
    set    sd.primary_quantity = round(sd.primary_quantity - decode(t_number1(j),NULL,t_pri_qty(j),t_pri_qty(j)-t_number1(j)), 6),
           sd.tp_quantity = round(sd.tp_quantity - decode(t_number1(j), NULL, t_tp_qty(j), Decode(t_pri_qty(j),0,-t_number1(j),t_tp_qty(j) - (t_number1(j)/Decode(t_pri_qty(j),0,1,t_pri_qty(j)))*t_tp_qty(j))), 6)
    where  sd.publisher_order_type = 14 and --SO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.end_order_number = t_end_order_num(j) and
           nvl(sd.end_order_rel_number, -99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.end_order_line_number, -99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = get_quantity(sd.primary_quantity, sd.primary_uom, sd.uom_code, sd.inventory_item_id)
    where  sd.publisher_order_type = 14 and --SO
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.end_order_number = t_end_order_num(j) and
           nvl(sd.end_order_rel_number, -99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.end_order_line_number, -99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;


  end if;

  --==================================
  --Open ASN's pegged to SO's
  --==================================
  --dbms_output.put_line('Opening c_asn_pegged_to_so');
  open c_asn_pegged_to_so(p_header_id);
  fetch c_asn_pegged_to_so
  bulk collect into  t_pri_qty,
        t_tp_qty,
        t_number1,
        t_item_id,
        t_pub_id,
        t_pub_site_id,
        t_cust_id,
        t_cust_site_id,
        t_end_order_num,
        t_end_ord_rel_num,
        t_end_ord_line_num,
        t_end_order_num1,
        t_end_ord_rel_num1,
        t_end_ord_line_num1;
  close c_asn_pegged_to_so;

  --dbms_output.put_line('Records fetched := ' || t_pri_qty.COUNT);

  --==================================
  --Consume SO quantity
  --==================================
  if (t_pri_qty is not NULL) and (t_pri_qty.COUNT > 0) then
   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.number1 = sd.primary_quantity
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 14 and --SO
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
	   sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.primary_quantity = round(sd.primary_quantity - decode(t_number1(j),NULL,t_pri_qty(j),t_pri_qty(j)-t_number1(j)), 6),
           sd.tp_quantity = round(sd.tp_quantity - decode(t_number1(j), NULL, t_tp_qty(j), Decode(t_pri_qty(j),0, -t_number1(j), t_tp_qty(j) - (t_number1(j)/Decode(t_pri_qty(j),0,1,t_pri_qty(j)))*t_tp_qty(j))), 6)
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 14 and --SO
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = get_quantity(sd.primary_quantity, sd.primary_uom, sd.uom_code, sd.inventory_item_id)
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 14 and --SO
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.customer_id = t_cust_id(j) and
           sd.customer_site_id = t_cust_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;



   --==================================
   --Consume PO quantity
   --==================================
   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.number1 = sd.primary_quantity
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 13 and --PO
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num1(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num1(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num1(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.primary_quantity = round(sd.primary_quantity - decode(t_number1(j),NULL,t_tp_qty(j), Decode(t_pri_qty(j),0,-t_number1(j), t_tp_qty(j)-(t_number1(j)/Decode(t_pri_qty(j),0,1,t_pri_qty(j)))*t_tp_qty(j))), 6),
           sd.tp_quantity = round(sd.tp_quantity - decode(t_number1(j), NULL, t_pri_qty(j), t_pri_qty(j)-t_number1(j)), 6)
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 13 and --PO
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num1(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num1(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num1(j), -99) and
           sd.quantity > 0;

   FORALL j in t_pri_qty.FIRST..t_pri_qty.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = get_quantity(sd.primary_quantity, sd.primary_uom, sd.uom_code, sd.inventory_item_id),
    	   sd.last_updated_by = t_last_updated_by(j),
	   sd.last_update_date = t_last_update_date(j) --Fix for bug 5599903
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 13 and --PO
           sd.publisher_id = t_cust_id(j) and
           sd.publisher_site_id = t_cust_site_id(j) and
           sd.supplier_id = t_pub_id(j) and
           sd.supplier_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num1(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num1(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num1(j), -99) and
           sd.quantity > 0;

  end if;

  --==================================
  --Open Receipt's pegged to ASN's
  --==================================
  OPEN c_receipts_pegged_to_asn(p_header_id);
  FETCH c_receipts_pegged_to_asn
  BULK COLLECT INTO t_item_id,
         t_pub_id,
         t_pub_site_id,
         t_supp_id,
         t_supp_site_id,
         t_end_order_num,
         t_end_ord_rel_num,
         t_end_ord_line_num;
  CLOSE c_receipts_pegged_to_asn;

  --==================================
  --Consume ASN quantity
  --==================================
  if (t_item_id is not null ) and (t_item_id.COUNT > 0) then
   FORALL j in t_item_id.FIRST..t_item_id.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = 0,
           sd.primary_quantity = 0,
           sd.tp_quantity = 0,
           sd.last_update_login = -99
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 15 and --ASN
           sd.publisher_id = t_supp_id(j) and
           sd.publisher_site_id = t_supp_site_id(j) and
           sd.customer_id = t_pub_id(j) and
           sd.customer_site_id = t_pub_site_id(j) and
           sd.order_number = t_end_order_num(j) and
           nvl(sd.release_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.line_number,-99) = nvl(t_end_ord_line_num(j), -99);
  end if;

  --==================================
  --Open Receipt's pegged to PO's
  --==================================
  OPEN c_receipts_pegged_to_po(p_header_id);
  FETCH c_receipts_pegged_to_po
  BULK COLLECT INTO
         t_item_id,
         t_pub_id,
         t_pub_site_id,
         t_supp_id,
         t_supp_site_id,
         t_end_order_num,
         t_end_ord_rel_num,
         t_end_ord_line_num;
  CLOSE c_receipts_pegged_to_po;

  --Update ASN's pegged to the PO
  if (t_item_id is not null ) and (t_item_id.COUNT > 0) then
   FORALL j in t_item_id.FIRST..t_item_id.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = 0,
           sd.primary_quantity = 0,
           sd.tp_quantity = 0,
           sd.last_update_login = -99
    where  sd.inventory_item_id = t_item_id(j) and
           sd.plan_id = -1 and
           sd.publisher_order_type = 15 and --ASN
           sd.end_order_type = 13 and  --PO
           sd.publisher_id = t_supp_id(j) and
           sd.publisher_site_id = t_supp_site_id(j) and
           sd.customer_id = t_pub_id(j) and
           sd.customer_site_id = t_pub_site_id(j) and
           sd.end_order_number = t_end_order_num(j) and
           nvl(sd.end_order_rel_number,-99) = nvl(t_end_ord_rel_num(j),-99) and
           nvl(sd.end_order_line_number,-99) = nvl(t_end_ord_line_num(j), -99) and
           sd.quantity > 0;
  end if;

  --Update ASN's pegged to the SO
  OPEN c_receipts_pegged_to_po1(p_header_id);
  FETCH c_receipts_pegged_to_po1
  BULK COLLECT INTO  t_item_id,
         t_pub_id,
         t_pub_site_id,
         t_supp_id,
         t_supp_site_id,
         t_end_order_num,
         t_end_ord_rel_num,
         t_end_ord_line_num;
  CLOSE c_receipts_pegged_to_po1;
  if (t_item_id IS NOT NULL) and (t_item_id.COUNT > 0) then
  FORALL j in t_item_id.FIRST..t_item_id.LAST
    UPDATE msc_sup_dem_entries sd
    SET    sd.quantity = 0,
           sd.primary_quantity = 0,
           sd.tp_quantity = 0,
           sd.last_update_login = -99
    WHERE  sd.publisher_order_type = 15 and  --ASN
           sd.plan_id = -1 and
           sd.inventory_item_id = t_item_id(j) and
           sd.end_order_type = 14 and  --SO
           sd.publisher_id = t_supp_id(j) and
           sd.publisher_site_id = t_supp_site_id(j) and
           sd.customer_id = t_pub_id(j) and
           sd.customer_site_id = t_pub_site_id(j) and
           sd.end_order_number = t_end_order_num(j) and
           nvl(sd.end_order_rel_number, -99) = nvl(t_end_ord_rel_num(j), -99) and
           nvl(sd.end_order_line_number, -99) = nvl(t_end_ord_line_num(j), -99)and
           sd.quantity > 0;
  end if;


  --=====================================
  --Logic to delete receipts
  --=====================================
  OPEN c_onhand_records(p_header_id);
  FETCH c_onhand_records
  BULK COLLECT INTO t_item_id,
        t_pub_id,
        t_pub_site_id,
        t_extract_date;
  CLOSE c_onhand_records;

  if (t_item_id is not NULL) and (t_item_id.COUNT > 0) then
   FORALL j in t_item_id.FIRST..t_item_id.LAST
    update msc_sup_dem_entries sd
    set    sd.quantity = 0,
           sd.primary_quantity = 0,
           sd.tp_quantity = 0,
           sd.last_update_login = -99
    where  sd.inventory_item_id = t_item_id(j) and
           sd.publisher_order_type = 16 and
           sd.plan_id = -1 and
           sd.publisher_id = t_pub_id(j) and
           sd.publisher_site_id = t_pub_site_id(j) and
           sd.quantity > 0 and
           sd.new_schedule_date <= t_extract_date(j); --Fix for bug 2308128
  end if;

  COMMIT;

END POST_PROCESS;


PROCEDURE update_qty_from_ui(
  p_item_id IN number,
  p_qty     IN number,
  p_uom     IN varchar2,
  p_pri_uom IN varchar2,
  p_tp_uom  IN varchar2,
  p_pri_qty OUT NOCOPY number,
  p_tp_qty  OUT NOCOPY number
) IS
  l_conv_found boolean := NULL;
  l_conv_rate1 number;
  l_conv_rate2 number;
BEGIN
  IF p_pri_uom <> p_uom THEN
    msc_x_util.get_uom_conversion_rates(
      p_uom,
      p_pri_uom,
      p_item_id,
      l_conv_found,
      l_conv_rate1
    );
    IF NOT l_conv_found THEN
      l_conv_rate1 := 1;
      p_pri_qty := round(p_qty,6);
    ELSE
      p_pri_qty := round(l_conv_rate1*p_qty, 6);
    END IF;
  ELSE
    p_pri_qty := round(p_qty,6);
  END IF;

  IF p_tp_uom <> p_uom THEN
    msc_x_util.get_uom_conversion_rates(
      p_uom,
      p_tp_uom,
      p_item_id,
      l_conv_found,
      l_conv_rate2
    );
    IF NOT l_conv_found THEN
      l_conv_rate2 := 1;
      p_tp_qty := round(p_qty, 6);
    ELSE
      p_tp_qty := round(l_conv_rate2*p_qty, 6);
    END IF;
  ELSE
    p_tp_qty := round(p_qty, 6);
  END IF;

END update_qty_from_ui;


FUNCTION GET_QUANTITY(
 p_qty IN NUMBER,
 p_uom IN VARCHAR2,
 p_uom1 IN VARCHAR2,
 p_item_id IN NUMBER
) RETURN NUMBER IS
 p_qty1 number;
 l_conv_found boolean;
 l_conv_rate number;
BEGIN
  IF p_uom <> p_uom1 THEN
    msc_x_util.get_uom_conversion_rates(
      p_uom,
      p_uom1,
      p_item_id,
      l_conv_found,
      l_conv_rate
    );
    IF NOT l_conv_found THEN
      l_conv_rate := 1;
      p_qty1 := p_qty;
    ELSE
      p_qty1 := l_conv_rate*p_qty;
    END IF;
  ELSE
    p_qty1 := p_qty;
  END IF;
  return round(p_qty1,6);
END GET_QUANTITY;

PROCEDURE serial_validation(
        p_header_id IN NUMBER,
   p_language  IN VARCHAR2
) IS

  l_err_msg                  VARCHAR2(240);
  l_min             NUMBER;
  l_max             NUMBER;
  l_log_message              VARCHAR2(4000);
  l_start_line         NUMBER;
  l_end_line           NUMBER;
  l_loops_reqd               NUMBER;
  t_serial_txn_id            serialTxnId;
  t_serial_number            serialNumber;
  t_disable_date             disableDate;
  t_plan_id                  planid;
  t_attachment_url           attachmentUrl;
  t_sync_indicator           syncIndicator;
  t_row_status               rowStatus;
  t_err_msg                  errMsg;
  t_user_defined1            userDefined;
  t_user_defined2            userDefined;
  t_user_defined3            userDefined;
  t_user_defined4            userDefined;
  t_user_defined5            userDefined;
  t_user_defined6            userDefined;
  t_user_defined7            userDefined;
  t_user_defined8            userDefined;
  t_user_defined9            userDefined;
  t_user_defined10           userDefined;
  t_creation_date            creationDate;
  t_created_by               createdBy;
  t_last_update_date         lastUpdateDate;
  t_last_updated_by          lastUpdatedBy;
  t_last_update_login        lastUpdateLogin;
  t_context                  context;
  t_attribute1               attribute;
  t_attribute2               attribute;
  t_attribute3               attribute;
  t_attribute4               attribute;
  t_attribute5               attribute;
  t_attribute6               attribute;
  t_attribute7               attribute;
  t_attribute8               attribute;
  t_attribute9               attribute;
  t_attribute10              attribute;
  t_attribute11              attribute;
  t_attribute12              attribute;
  t_attribute13              attribute;
  t_attribute14              attribute;
  t_attribute15              attribute;
  t_line_id                  serialLineId;
  t_line_id1           serialLineId;

  t_log_line_id        serialLineId;
  t_log_item_name            itemList;
  t_log_order_type           serialOrderType;
  t_log_err_msg              serialErrMsg;
  t_log_serial_number        serialNumber;


  lv_dummy1                      varchar2(32)                := '';
  lv_dummy2                      varchar2(32)                := '';
  v_applsys_schema               varchar2(32)                ;
  v_retval         boolean                     ;

  CURSOR c_err_msg(
    p_header_id  IN Number,
    p_start_line IN Number,
    p_end_line   IN Number
  ) IS
  select line_id, nvl(master_item_name,publisher_item_name), order_type,serial_number, err_msg
  from   msc_st_serial_numbers
  where  parent_header_id = p_header_id and
         row_status = G_FAILURE    AND
         line_id BETWEEN p_start_line and p_end_line;


  BEGIN
    BEGIN
       SELECT min(line_id),max(line_id)
       INTO   l_min,l_max
       FROM   msc_st_serial_numbers
       WHERE  parent_header_id = p_header_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_min := 0;
    END;



    v_retval := FND_INSTALLATION.GET_APP_INFO(
                   'FND', lv_dummy1,lv_dummy2, v_applsys_schema);



    --==============================================================================================================
    -- create index on publisher_company,publisher_order_type,publisher_item_name,master_item_name,publisher_site_id
    --===============================================================================================================
    create_index(v_applsys_schema);


    l_loops_reqd := 1 + trunc((l_max - l_min)/G_BATCH_SIZE);

    IF l_loops_reqd IS NOT NULL THEN
    FOR i IN 1..l_loops_reqd LOOP
      l_start_line := l_min + ((i-1)*G_BATCH_SIZE);
      IF ((l_min - 1 + i*G_BATCH_SIZE) <= l_max) THEN
        l_end_line := l_min - 1 + i*G_BATCH_SIZE;
      ELSE
        l_end_line := l_max;
      END IF;



    l_log_message := substrb(get_message('MSC','MSC_X_API_NOW_PROCESSING',p_language),1,500)
                     || '... ' || to_char(l_start_line - l_min + 1) || ' ' ||
                     substrb(get_message('MSC','MSC_X_API_THROUGH',p_language),1,500) ||
                     ' ' || to_char(l_end_line - l_min + 1);
    log_message(l_log_message);


    SELECT  /*+ parallel(mssn,5) */
           line_id
    BULK   COLLECT INTO t_line_id
    FROM   msc_st_serial_numbers
    WHERE  parent_header_id = p_header_id    AND
            line_id BETWEEN l_start_line and l_end_line;



    IF t_line_id IS NOT NULL AND t_line_id.COUNT > 0 THEN
    --================================================
    -- Validation 1: Check for valid sync indicator
    --=================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_SYNC_INDICATOR', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg      = substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
         UPPER(NVL(mssn.sync_indicator, G_NULL_STRING)) NOT IN ('R','D');

    --========================================================
    --Validation 2: Check for the order type
    --======================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_ORDER_TYPE', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg ,
                           --      mssn.err_msg || ' ' || l_err_msg ),
                          substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           NOT EXISTS (SELECT /*+ parallel(l,5) */
                              l.lookup_code
                         FROM fnd_lookup_values l
                        WHERE l.lookup_type = 'MSC_X_ORDER_TYPE' AND
                              UPPER(l.meaning) = NVL(UPPER(mssn.order_type), G_NULL_STRING) AND
                              l.language = p_language       AND
                              l.lookup_code = G_UNALLOCATED_ONHAND);

    --======================================================================
    -- Validation 3: Check for the number of item name is 0
    --======================================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_NO_ITEM', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg,
                           --      mssn.err_msg || ' ' || l_err_msg ),
                           substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.master_item_name IS NULL     AND
           mssn.publisher_item_name IS NULL;


    --===============================================================
    -- Validation 4: Check for serial number
    --==============================================================
    l_err_msg := get_message('MSC', 'MSC_X_NO_SERIAL_NUMBER',p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg ,
                           --      mssn.err_msg || ' ' || l_err_msg),
                          substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.serial_number IS NULL;


    --=============================================================
    -- Derive the publisher id
    --=============================================================
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET mssn.publisher_id = (SELECT /*+ parallel(mc,5)  */
                                   mc.company_id
                              FROM msc_companies mc
                              WHERE UPPER(mssn.publisher_company) = UPPER(mc.company_name)
                            )
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS;

    --==============================================================
    -- Validation 5: Check for existence of publisher company
    --==============================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg,
                           --      mssn.err_msg || ' ' || l_err_msg),
                          substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.publisher_id IS NULL;



    --=============================================================
    --Derive the publisher site id
    --==========================================================
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET mssn.publisher_site_id = (SELECT /*+ parallel(mcs,5) */
                                   mcs.company_site_id
                              FROM msc_company_sites mcs
                              WHERE mssn.publisher_id=mcs.company_id      AND
                                    UPPER(mssn.publisher_site) = UPPER(mcs.company_site_name)
                            )
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS;


    --============================================================
    -- Validation 6: Check for existence of publisher site
    --============================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_PUBLISHER_SITE', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg,
                           --      mssn.err_msg || ' ' || l_err_msg ),
                          substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.publisher_site_id IS NULL;



    --======================================================
    -- Derive the inventory_item_id
    --====================================================
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET mssn.inventory_item_id = (SELECT /*+ parallel(mi,5) */
                                         mi.inventory_item_id
                                   FROM  msc_items mi
                                  WHERE mi.item_name = mssn.master_item_name     AND
                                        mssn.master_item_name IS NOT NULL

                                 UNION ALL
                                   SELECT msi.inventory_item_id
                                     FROM msc_system_items msi,
                                          msc_trading_partners mtp,
                                          msc_trading_partner_maps mtpm,
                                          msc_company_sites mcs,
                                          msc_companies mc
                                    WHERE msi.plan_id = -1    AND
                                          mssn.parent_header_id = p_header_id AND
                                          mssn.line_id = t_line_id(j) AND
                                          NVL(mssn.row_status, G_PROCESS) = G_PROCESS    AND
                                          msi.item_name = mssn.publisher_item_name    AND
                                          msi.organization_id = mtp.sr_tp_id     AND
                                          msi.sr_instance_id = mtp.sr_instance_id     AND
                                          mtp.partner_type = 3    AND
                                          mtp.partner_id = mtpm.tp_key     AND
                                          mtpm.map_type = 2     AND
                                          mtpm.company_key = mcs.company_site_id     AND
                                          mcs.company_site_name = mssn.publisher_site    AND
                                          mcs.company_id = mc.company_id    AND
                                          mc.company_name = mssn.publisher_company    AND
                                          NVL(mtp.company_id,1) = mc.company_id     AND
                                          mssn.publisher_item_name IS NOT NULL     AND
                                          mssn.master_item_name IS NULL

                                 UNION ALL
                                   SELECT mis.inventory_item_id
                                     FROM msc_item_suppliers mis,
                                    	  msc_trading_partner_maps map,
                                    	  msc_trading_partner_maps map1,
                                    	  msc_company_relationships r,
                                    	  msc_company_sites cs,
                                    	  msc_companies c
                                    WHERE mis.plan_id = -1 and
                                    	  mssn.parent_header_id = p_header_id AND
                                    	  mssn.line_id = t_line_id(j) AND
                                    	  NVL(mssn.row_status, G_PROCESS) = G_PROCESS AND
                                    	  mis.supplier_item_name = mssn.publisher_item_name  AND
                                    	  mis.supplier_id = map.tp_key and
					  --nvl(mis.supplier_site_id, map1.tp_key) = map1.tp_key and
					  mis.supplier_site_id = map1.tp_key and
                                          map.map_type = 1 and
                                          map.company_key = r.relationship_id and
                                          r.subject_id = 1 and
                                          r.object_id = c.company_id and
                                          r.relationship_type = 2 and
                                          c.company_name = mssn.publisher_company  AND
                                    	  map1.map_type = 3 and
                                    	  map1.company_key = cs.company_site_id and
                                    	  cs.company_site_name = mssn.publisher_site  AND
                                    	  cs.company_id = c.company_id  and
				    	  mssn.publisher_item_name IS NOT NULL  AND
                                          mssn.master_item_name IS NULL

                                 UNION ALL
                                   SELECT mic.inventory_item_id
                             	     FROM msc_item_customers mic,
                                    	  msc_trading_partner_maps map,
                                    	  msc_trading_partner_maps map1,
                                    	  msc_company_relationships r,
                                    	  msc_company_sites cs,
                                    	  msc_companies c
                                    WHERE mic.plan_id = -1 and
                                    	  mssn.parent_header_id = p_header_id AND
                                    	  mssn.line_id = t_line_id(j) AND
                                    	  NVL(mssn.row_status, G_PROCESS) = G_PROCESS AND
                                    	  mic.customer_item_name = mssn.publisher_item_name  AND
                                          mic.customer_id = map.tp_key and
					  --nvl(mic.customer_site_id, map1.tp_key) = map1.tp_key and
					  mic.customer_site_id = map1.tp_key and
                                    	  map.map_type = 1 and
                                    	  map.company_key = r.relationship_id and
                                    	  r.subject_id = 1 and
                                    	  r.object_id = c.company_id and
                                    	  r.relationship_type = 1 and
                                    	  c.company_name = mssn.publisher_company  AND
                                    	  map1.map_type = 3 and
                                    	  map1.company_key = cs.company_site_id and
                                    	  cs.company_site_name = mssn.publisher_site  AND
                                    	  cs.company_id = c.company_id   and
				          mssn.publisher_item_name IS NOT NULL  AND
                                          mssn.master_item_name IS NULL
                                   )
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS;

    --============================================================
    -- Check if inventory_item_id exist
    --=======================================================
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_ITEM', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg ,
                           --      mssn.err_msg || ' ' || l_err_msg),
                           substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.inventory_item_id IS NULL;

    --=======================================================
    -- Validation 7: check for the serial_number_flag if the profile is
    --========================================================
    IF NVL(FND_PROFILE.VALUE('MSC_DEFAULT_SERIAL_CONTROL'),'Y') ='Y' THEN
    l_err_msg := get_message('MSC', 'MSC_X_INVALID_SERIAL_FLAG', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg ,
                           --      mssn.err_msg || ' ' || l_err_msg),
                          substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           NOT EXISTS (SELECT msi.serial_number_control_code
                        FROM  msc_system_items msi,
                              msc_trading_partners mtp,
                              msc_trading_partner_maps mtpm
                        WHERE msi.plan_id = -1        AND
                              msi.inventory_item_id = mssn.inventory_item_id       AND
                              msi.sr_instance_id = mtp.sr_instance_id       AND
                              msi.organization_id = mtp.sr_tp_id        AND
                              mtp.partner_type = 3       AND
                              mtp.partner_id = mtpm.tp_key       AND
                              mtpm.map_type = 2       AND
                              mtpm.company_key = mssn.publisher_site_id       AND
                              msi.serial_number_control_code = G_SERIAL_ITEM
                      );
    END IF;
    --==========================================================
    -- Derive transaction id
    --===============================================================
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.serial_txn_id =  (SELECT /*+ parallel(msde,5) */
                                         msde.transaction_id
                                    FROM msc_sup_dem_entries msde
                                   WHERE msde.plan_id = -1       AND
                                         msde.publisher_id = mssn.publisher_id      AND
                                         msde.publisher_site_id = mssn.publisher_site_id      AND
                                         msde.inventory_item_id = mssn.inventory_item_id      AND
                                         msde.publisher_order_type = (SELECT /*+ parallel(flv,5) */
                                                                             flv.lookup_code
                                                                        FROM fnd_lookup_values flv
                                                                       WHERE flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                                                             UPPER(flv.meaning) = NVL(UPPER(mssn.order_type), G_NULL_STRING) AND
                                                                             flv.language = p_language)
                                  )
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS ;

    --========================================================
    -- Validation 8: Check if the serial_txn_id exist
    --=======================================================
    l_err_msg := get_message('MSC', 'MSC_X_ONHAND_NOT_FOUND', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = --DECODE(mssn.err_msg, NULL, l_err_msg,
                           --      mssn.err_msg || ' ' || l_err_msg ),
                           substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           mssn.serial_txn_id IS NULL;


    --========================================================
    -- Validation 9: Check if the record exists for the
    --                    sync_indicator 'D'
    --========================================================
    l_err_msg := get_message('MSC', 'MSC_X_SERIAL_DATA_NOT_FOUND', p_language);
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(mssn,5) */
           msc_st_serial_numbers mssn
    SET    mssn.err_msg = -- DECODE(mssn.err_msg, NULL, l_err_msg,
                            --     mssn.err_msg || ' ' || l_err_msg),
                           substrb(l_err_msg,1,1000),
           mssn.row_status   = G_FAILURE
    WHERE  mssn.parent_header_id = p_header_id AND
           mssn.line_id = t_line_id(j) AND
           NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
           UPPER(NVL(mssn.sync_indicator, G_NULL_STRING))='D'      AND
           NOT EXISTS (SELECT /*+ parallel(msn,5) */
                              msn.serial_txn_id
                         FROM msc_serial_numbers msn
                        WHERE msn.serial_txn_id = mssn.serial_txn_id      AND
                              msn.serial_number = mssn.serial_number
                       );

    --======================================================
    -- Delete the record if the sync_indicator is 'D;
    --=====================================================
    FORALL j IN t_line_id.FIRST..t_line_id.LAST
    UPDATE /*+ parallel(msn,5) */
           msc_serial_numbers msn
    SET msn.disable_date = sysdate
    WHERE (msn.serial_txn_id,msn.serial_number) IN
                                                  (SELECT /*+ parallel(mssn,5) */
                                                          mssn.serial_txn_id,mssn.serial_number
                                                     FROM msc_st_serial_numbers mssn
                                                    WHERE mssn.parent_header_id = p_header_id AND
                             mssn.line_id = t_line_id(j) AND
                             NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
                                                          UPPER(NVL(mssn.sync_indicator, G_NULL_STRING))='D'
                                                   )    AND
           NVL(msn.disable_date,sysdate+1) > sysdate ;


    --=========================================================
     -- Delete the previous record if the sync_indicator is 'R'
     --=========================================================
     FORALL j IN t_line_id.FIRST..t_line_id.LAST
     DELETE FROM msc_serial_numbers msn
     WHERE  msn.serial_txn_id = (SELECT /*+ parallel(mssn,5) */
                                       mssn.serial_txn_id
                                  FROM msc_st_serial_numbers mssn
                                 WHERE mssn.parent_header_id = p_header_id AND
                         mssn.line_id = t_line_id(j) AND
                         NVL(mssn.row_status, G_PROCESS) = G_PROCESS   AND
                                       UPPER(NVL(mssn.sync_indicator, G_NULL_STRING))='R'
                               )      AND
            NVL(msn.disable_date,sysdate+1) > sysdate   AND
       msn.parent_header_id <> p_header_id ;

    END IF;  --End of validation


     SELECT /*+ parallel(mssn,5) */
     mssn.line_id,
     mssn.serial_txn_id,
     mssn.serial_number,
     mssn.attachment_url,
     mssn.sync_indicator,
     mssn.row_status,
     mssn.user_defined1,
     mssn.user_defined2,
     mssn.user_defined3,
     mssn.user_defined4,
     mssn.user_defined5,
     mssn.user_defined6,
     mssn.user_defined7,
     mssn.user_defined8,
     mssn.user_defined9,
     mssn.user_defined10,
     mssn.creation_date,
     mssn.created_by,
     mssn.last_update_date,
     mssn.last_updated_by,
     mssn.last_update_login,
     mssn.context,
     mssn.attribute1,
     mssn.attribute2,
     mssn.attribute3,
     mssn.attribute4,
     mssn.attribute5,
     mssn.attribute6,
     mssn.attribute7,
     mssn.attribute8,
     mssn.attribute9,
     mssn.attribute10,
     mssn.attribute11,
     mssn.attribute12,
     mssn.attribute13,
     mssn.attribute14,
     mssn.attribute15
     BULK COLLECT INTO
     t_line_id1,
     t_serial_txn_id,
     t_serial_number,
     t_attachment_url,
     t_sync_indicator,
     t_row_status,
     t_user_defined1,
     t_user_defined2,
     t_user_defined3,
     t_user_defined4,
     t_user_defined5,
     t_user_defined6,
     t_user_defined7,
     t_user_defined8,
     t_user_defined9,
     t_user_defined10,
     t_creation_date,
     t_created_by,
     t_last_update_date,
     t_last_updated_by,
     t_last_update_login,
     t_context,
     t_attribute1,
     t_attribute2,
     t_attribute3,
     t_attribute4,
     t_attribute5,
     t_attribute6,
     t_attribute7,
     t_attribute8,
     t_attribute9,
     t_attribute10,
     t_attribute11,
     t_attribute12,
     t_attribute13,
     t_attribute14,
     t_attribute15
     FROM msc_st_serial_numbers mssn
     WHERE mssn.parent_header_id = p_header_id   AND
         NVL(mssn.row_status, G_PROCESS) = G_PROCESS AND
           UPPER(NVL(mssn.sync_indicator, G_NULL_STRING))='R'  AND
         mssn.line_id BETWEEN l_start_line and l_end_line;


     --====================================================
     -- Insert the record if the sync_indicator is 'R'
     --===================================================

     IF t_serial_number IS NOT NULL AND  t_serial_number.COUNT > 0 THEN
     FORALL i IN t_serial_number.FIRST..t_serial_number.LAST
     INSERT /*+ parallel(msn,5)  */
     INTO msc_serial_numbers msn
     (
     serial_txn_id,
     serial_number,
     plan_id,
     attachment_url,
     user_defined1,
     user_defined2,
     user_defined3,
     user_defined4,
     user_defined5,
     user_defined6,
     user_defined7,
     user_defined8,
     user_defined9,
     user_defined10,
     parent_header_id,
     line_id,
     creation_date,
     created_by,
     last_update_date,
     last_updated_by,
     last_update_login,
     context,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15
     )
     VALUES (
     t_serial_txn_id(i),
     t_serial_number(i),
     -1,
     t_attachment_url(i),
     t_user_defined1(i),
     t_user_defined2(i),
     t_user_defined3(i),
     t_user_defined4(i),
     t_user_defined5(i),
     t_user_defined6(i),
     t_user_defined7(i),
     t_user_defined8(i),
     t_user_defined9(i),
     t_user_defined10(i),
     p_header_id,
     t_line_id(i),
     t_creation_date(i),
     t_created_by(i),
     t_last_update_date(i),
     t_last_updated_by(i),
     t_last_update_login(i),
     t_context(i),
     t_attribute1(i),
     t_attribute2(i),
     t_attribute3(i),
     t_attribute4(i),
     t_attribute5(i),
     t_attribute6(i),
     t_attribute7(i),
     t_attribute8(i),
     t_attribute9(i),
     t_attribute10(i),
     t_attribute11(i),
     t_attribute12(i),
     t_attribute13(i),
     t_attribute14(i),
     t_attribute15(i)
     );
     END IF;
     COMMIT;





    --=========================================================================
    -- Writing error messages to the log file
    --=========================================================================
    open c_err_msg(p_header_id, l_start_line, l_end_line);
    fetch c_err_msg bulk collect
    into  t_log_line_id,
          t_log_item_name,
          t_log_order_type,
          t_log_serial_number,
          t_log_err_msg;
    close c_err_msg;

    if t_log_line_id is not null and t_log_line_id.COUNT > 0 then
      for j in t_log_line_id.FIRST..t_log_line_id.LAST loop
        l_log_message :=
               substrb(get_message('MSC','MSC_X_UI_VOD_ORD_LINE_NUM',p_language),1,100) ||
               ': ' || to_char(t_log_line_id(j) - l_min + 1) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_ITEM',p_language),1,100) ||
               ': ' || t_log_item_name(j) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_SDD_ORDER_TYPE',p_language),1,100) ||
                 ': ' || t_log_order_type(j) || ', ' ||
               substrb(get_message('MSC','MSC_X_UI_SERIAL_NUMBER',p_language),1,100) ||
                 ': ' || t_log_serial_number(j) || ', '||
               substrb(get_message('MSC','MSC_X_UI_LSD_ERROR', p_language),1,100) ||
               ': ' || t_log_err_msg(j) || fnd_global.local_chr(10) ;

        log_message(l_log_message);
      END LOOP;
    END IF;

  END LOOP;
  END IF;

    --=====================================================
    -- drop index
    --==================================================
    drop_index(v_applsys_schema);

    --=====================================================
    -- Delete all the record which has not errored out
    --=====================================================
    DELETE FROM msc_st_serial_numbers mssn
    WHERE NVL(mssn.row_status, G_PROCESS) = G_PROCESS    AND
        mssn.parent_header_id = p_header_id ;


END serial_validation;


PROCEDURE create_index (v_applsys_schema IN VARCHAR2) IS
BEGIN
            ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                           application_short_name => 'MSC',
                           statement_type => AD_DDL.CREATE_INDEX,
                           statement =>
                                     'create index MSC_ST_SERIAL_NUMBER_N1'
                                   ||' on MSC_ST_SERIAL_NUMBERS '
                                   ||'(publisher_company,publisher_site,publisher_item_name,master_item_name,order_type) '
                                   ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
                           object_name =>'MSC_ST_SERIAL_NUMBER_N1'
                         );
EXCEPTION
   WHEN OTHERS THEN
      log_message('Error creating Index MSC_ST_SERIAL_NUMBER_N1. Error:'||substr(SQLERRM,1,240));
END create_index;


PROCEDURE drop_index(v_applsys_schema IN VARCHAR2) IS
BEGIN
            ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                           application_short_name => 'MSC',
                           statement_type => AD_DDL.DROP_INDEX,
                           statement =>
                                     'drop index MSC_ST_SERIAL_NUMBER_N1',
                           object_name =>'MSC_ST_SERIAL_NUMBER_N1'
                         );
EXCEPTION
   WHEN OTHERS THEN
       log_message('Error deleting Index MSC_ST_SERIAL_NUMBER_N1. Error:'||substr(SQLERRM,1,240));
END drop_index;

-- jguo: API to validate receipt/ship date for TP as a supplier
PROCEDURE validate_rs_dates_supplier(
           t_line_id IN lineidList
         , p_header_id IN NUMBER
         , p_language IN VARCHAR2
         ) IS

  l_err_msg VARCHAR2(200);

BEGIN

      --======================================================================
      -- Validation: Check if receipt date is populated if the order type is
      --                PO, Receipt, Order forecast and Requisition
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_RCPT_DATE', p_language);
      --dbms_output.put_line( 'In ' || l_err_msg);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.receipt_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_PURCHASE_ORDER,
                                                           G_SHIP_RECEIPT,
                                                           G_ORDER_FORECAST,
                                                           G_REQUISITION,
							   G_REPLENISHMENT)) -- bug #4070061
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
                                                           ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.receipt_date,
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code IN (G_PURCHASE_ORDER,
                                                           G_SHIP_RECEIPT,
                                                           G_ORDER_FORECAST,
                                                           G_REQUISITION,
							   G_REPLENISHMENT))  -- bug #4070061
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
                                                           ;

      --======================================================================
      -- Validation: Check if ship date is populated if the order type is
      --                Sales Forecast, Sell through forecast, supplier capacity,
      --                projected safety stock and projected available balances.
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.ship_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_SELL_THRO_FCST,
                                                           G_SUPPLIER_CAP,
                                                           G_PROJ_SS,
                                                           G_PROJ_ALLOC_AVAIL,
                                                           G_PROJ_UNALLOC_AVAIL))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
                                                           ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.ship_date,
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code IN (G_SELL_THRO_FCST,
                                                                  G_SUPPLIER_CAP,
                                                                  G_PROJ_SS,
                                                                  G_PROJ_ALLOC_AVAIL,
                                                                  G_PROJ_UNALLOC_AVAIL))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
                                                                  ;

  --==============================================================================
      -----bug #4070061 -------
      -- Validation: Check if either ship date or receipt date is
      --                populated if the order type = POA
     --==============================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_RCPT_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.ship_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code = G_PO_ACKNOWLEDGEMENT) AND
               G_NULL_STRING = (SELECT NVL(ln1.receipt_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code = G_PO_ACKNOWLEDGEMENT)
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      );

-----------------------------------------------------------------------------------------------------------
      ---for order type = POA : if receipt_date is entered via loads , then set key_date = receipt_date
      ---else receipt_date gets derived from ship_date in get_optional_info procedure
      ---and key_date is populated there
-----------------------------------------------------------------------------------------------------------

 FORALL j in t_line_id.FIRST..t_line_id.LAST
         UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.receipt_date,
               ln.key_end_date = ln.new_schedule_end_date
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
	       ln.receipt_date is not null AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                              flv.lookup_code = G_PO_ACKNOWLEDGEMENT)
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.customer_company, ln.publisher_company))
                        AND c.company_id = 1
                      ) ;

EXCEPTION
   WHEN OTHERS THEN
       log_message('Error when validating receipt/ship date (validate_rs_dates_supplier). Error:'||substr(SQLERRM,1,240));
END validate_rs_dates_supplier;

-- jguo: API to validate receipt/ship date for TP as a customer
PROCEDURE validate_rs_dates_customer(
           t_line_id IN lineidList
         , p_header_id IN NUMBER
         , p_language IN VARCHAR2
         ) IS

  l_err_msg VARCHAR2(200);

BEGIN

      --======================================================================
      -- Validation: Check if receipt date is populated if the order type is
      --                PO, Receipt, Order forecast and Requisition
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_RCPT_DATE', p_language);
      --dbms_output.put_line( 'In ' || l_err_msg);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.receipt_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN (G_PURCHASE_ORDER,
                                                           -- G_SHIP_RECEIPT,
                                                           G_ORDER_FORECAST,
                                                           G_REQUISITION
                                                           , G_SUPPLY_COMMIT
                                                           , G_NEGOTIATED_CAPACITY
                                                           , G_PO_ACKNOWLEDGEMENT
                                                           , G_SALES_ORDER
                                                           ))
            AND MSC_X_UTIL.GET_SHIPPING_CONTROL
            ( NVL(ln.customer_company, ln.publisher_company)
            , NVL(ln.customer_site, ln.publisher_site)
            , NVL(ln.supplier_company, ln.publisher_company)
            , NVL(ln.supplier_site, ln.publisher_site)
            ) = 1 -- supplier
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.receipt_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN ( G_SHIP_RECEIPT
                                                          , G_ASN
                                                          ))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
             ;


      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.receipt_date,
               ln.key_end_date = ln.new_schedule_end_date
               , ln.shipping_control = MSC_X_UTIL.GET_SHIPPING_CONTROL
                                        ( NVL(ln.customer_company, ln.publisher_company)
                                        , NVL(ln.customer_site, ln.publisher_site)
                                        , NVL(ln.supplier_company, ln.publisher_company)
                                        , NVL(ln.supplier_site, ln.publisher_site)
            )
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                       flv.lookup_code IN (G_PURCHASE_ORDER,
                                                           -- G_SHIP_RECEIPT,
                                                           G_ORDER_FORECAST,
                                                           G_REQUISITION
                                                           , G_SUPPLY_COMMIT
                                                           , G_NEGOTIATED_CAPACITY
                                                           , G_PO_ACKNOWLEDGEMENT
                                                           , G_SALES_ORDER
                                                           ))
             AND MSC_X_UTIL.GET_SHIPPING_CONTROL
            ( NVL(ln.customer_company, ln.publisher_company)
            , NVL(ln.customer_site, ln.publisher_site)
            , NVL(ln.supplier_company, ln.publisher_company)
            , NVL(ln.supplier_site, ln.publisher_site)
            ) = 1 -- supplier
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.receipt_date,
               ln.key_end_date = ln.new_schedule_end_date
                  , ln.shipping_control = MSC_X_UTIL.GET_SHIPPING_CONTROL
                                        ( NVL(ln.customer_company, ln.publisher_company)
                                        , NVL(ln.customer_site, ln.publisher_site)
                                        , NVL(ln.supplier_company, ln.publisher_company)
                                        , NVL(ln.supplier_site, ln.publisher_site)
            )
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                       flv.lookup_code IN ( G_SHIP_RECEIPT
                                                          , G_ASN
                                                          ))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      --======================================================================
      -- Validation: Check if ship date is populated if the order type is
      --                Sales Forecast, Sell through forecast, supplier capacity,
      --                projected safety stock and projected available balances.
      --======================================================================
      l_err_msg := get_message('MSC', 'MSC_X_INVALID_SHIP_DATE', p_language);
      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.ship_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN ( -- G_SELL_THRO_FCST,
                                                           -- G_SUPPLIER_CAP,
                                                           -- G_PROJ_SS,
                                                           -- G_PROJ_ALLOC_AVAIL,
                                                           -- G_PROJ_UNALLOC_AVAIL
                                                             G_PURCHASE_ORDER
                                                           , G_ORDER_FORECAST
                                                           , G_SUPPLY_COMMIT
                                                           , G_NEGOTIATED_CAPACITY
                                                           , G_PO_ACKNOWLEDGEMENT
                                                           , G_REQUISITION
                                                           , G_SALES_ORDER
                                                           ))
             AND MSC_X_UTIL.GET_SHIPPING_CONTROL
            ( NVL(ln.customer_company, ln.publisher_company)
            , NVL(ln.customer_site, ln.publisher_site)
            , NVL(ln.supplier_company, ln.publisher_company)
            , NVL(ln.supplier_site, ln.publisher_site)
            ) = 2 -- customer
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      FORALL j IN t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.err_msg = substrb(ln.err_msg || ' ' || l_err_msg,1,1000)
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               G_NULL_STRING = (SELECT NVL(ln1.ship_date, G_NULL_STRING)
                                FROM   msc_supdem_lines_interface ln1,
                                       fnd_lookup_values flv
                                WHERE  ln1.parent_header_id = ln.parent_header_id and
                                       ln1.line_id = ln.line_id and
                                       UPPER(flv.meaning) = UPPER(ln1.order_type) and
                                       flv.lookup_type = 'MSC_X_ORDER_TYPE' and
                                       flv.language = p_language and
                                       flv.lookup_code IN ( G_SALES_FORECAST
                                                          , G_SELL_THRO_FCST
                                                           ))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.ship_date,
               ln.key_end_date = ln.new_schedule_end_date
               , ln.shipping_control = MSC_X_UTIL.GET_SHIPPING_CONTROL
                                        ( NVL(ln.customer_company, ln.publisher_company)
                                        , NVL(ln.customer_site, ln.publisher_site)
                                        , NVL(ln.supplier_company, ln.publisher_company)
                                        , NVL(ln.supplier_site, ln.publisher_site)
            )
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                       flv.lookup_code IN ( -- G_SELL_THRO_FCST,
                                                           -- G_SUPPLIER_CAP,
                                                           -- G_PROJ_SS,
                                                           -- G_PROJ_ALLOC_AVAIL,
                                                           -- G_PROJ_UNALLOC_AVAIL
                                                             G_PURCHASE_ORDER
                                                           , G_ORDER_FORECAST
                                                           , G_SUPPLY_COMMIT
                                                           , G_NEGOTIATED_CAPACITY
                                                           , G_PO_ACKNOWLEDGEMENT
                                                           , G_REQUISITION
                                                           , G_SALES_ORDER
                                                           ))
             AND MSC_X_UTIL.GET_SHIPPING_CONTROL
            ( NVL(ln.customer_company, ln.publisher_company)
            , NVL(ln.customer_site, ln.publisher_site)
            , NVL(ln.supplier_company, ln.publisher_company)
            , NVL(ln.supplier_site, ln.publisher_site)
            ) = 2 -- customer
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;

      FORALL j in t_line_id.FIRST..t_line_id.LAST
        UPDATE msc_supdem_lines_interface ln
        SET    ln.key_date = ln.ship_date,
               ln.key_end_date = ln.new_schedule_end_date
                , ln.shipping_control = MSC_X_UTIL.GET_SHIPPING_CONTROL
                                        ( NVL(ln.customer_company, ln.publisher_company)
                                        , NVL(ln.customer_site, ln.publisher_site)
                                        , NVL(ln.supplier_company, ln.publisher_company)
                                        , NVL(ln.supplier_site, ln.publisher_site)
            )
        WHERE  ln.parent_header_id = p_header_id AND
               ln.line_id = t_line_id(j) AND
               NVL(ln.row_status, G_PROCESS) = G_PROCESS AND
               UPPER(ln.order_type) IN (SELECT UPPER(flv.meaning)
                                       FROM   fnd_lookup_values flv
                                       WHERE  flv.language = p_language AND
                                              flv.lookup_type = 'MSC_X_ORDER_TYPE' AND
                                       flv.lookup_code IN ( G_SALES_FORECAST
                                                          , G_SELL_THRO_FCST
                                                           ))
       	   AND EXISTS ( SELECT ln.customer_company
                        FROM msc_companies c
                        WHERE UPPER(c.company_name) = UPPER(NVL(ln.supplier_company, ln.publisher_company))
                        AND c.company_id = 1
                      )
            ;


EXCEPTION
   WHEN OTHERS THEN
       log_message('Error when validating receipt/ship date (validate_rs_dates_customer). Error:'||substr(SQLERRM,1,240));
END validate_rs_dates_customer;

END msc_sce_loads_pkg;

/
