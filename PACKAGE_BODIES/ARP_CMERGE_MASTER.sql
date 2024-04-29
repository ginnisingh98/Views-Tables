--------------------------------------------------------
--  DDL for Package Body ARP_CMERGE_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMERGE_MASTER" as
/* $Header: ARHCMSTB.pls 120.31.12010000.2 2009/02/25 10:10:14 vsegu ship $ */

--Global variable to catch the name of product raising exception
G_PRODUCT_RAISING_EXCEPTION varchar2(255) ;

--delete customer's alternative names
procedure delete_customer_alt_names(
          req_id                 NUMBER,
          set_num                NUMBER
);

--merge crm products.
procedure merge_crm_products(
          req_id                 NUMBER,
          set_num                NUMBER,
          process_mode           VARCHAR2
);

-- dynamically call ERP merge rountine.
procedure merge_product (
          package_name             VARCHAR2,
          api_name                 VARCHAR2,
          req_id                   NUMBER,
          set_num                  NUMBER,
          process_mode             VARCHAR2,
          product_code		   VARCHAR2
);

g_excluded_apps VARCHAR2(200);

--added for debug
procedure read_temporary_table;

--For identifying the bad merge records
procedure update_merge_as_failed(
        p_request_id                        NUMBER,
        p_set_num                           NUMBER,
        p_customer_merge_header_id          NUMBER,
        p_error_text                        VARCHAR2
);

-- Called from the Customer Merger Concurrent program Parameter(Operating unit)
FUNCTION operating_unit RETURN VARCHAR2 IS

	l_operating_unit	VARCHAR2(2000):= NULL;
	l_count			NUMBER:=0;
	l_exit_count		NUMBER:=0;
	l_temp_variable		VARCHAR2(2000):=NULL;

	CURSOR get_operating_unit_csr IS
	SELECT	hr.name
	FROM	hr_operating_units hr
	WHERE	mo_global.check_access(hr.organization_id) = 'Y'
	ORDER BY hr.name;

BEGIN

	BEGIN
		SELECT COUNT(*) INTO l_count
		FROM	hr_operating_units hr
		WHERE	mo_global.check_access(hr.organization_id) = 'Y';
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;
	l_exit_count:=0;
	l_operating_unit:=NULL;
	l_temp_variable:=NULL;
	IF l_count > 5 THEN
		FOR get_operating_unit_rec IN get_operating_unit_csr LOOP
			l_operating_unit:=l_operating_unit||get_operating_unit_rec.name;
			l_exit_count:=l_exit_count+1;
			IF l_exit_count = 5 THEN
				l_operating_unit:=l_operating_unit||'...';
				EXIT;
			END IF;
			l_operating_unit:=l_operating_unit||',';
		END LOOP;

	ELSE
		OPEN get_operating_unit_csr;
		LOOP
			FETCH get_operating_unit_csr INTO l_temp_variable;
			EXIT WHEN get_operating_unit_csr%NOTFOUND;
			l_operating_unit:=l_operating_unit||l_temp_variable;
			l_operating_unit:=l_operating_unit||',';
		END LOOP;
		CLOSE get_operating_unit_csr;
		l_operating_unit:=SUBSTRB(l_operating_unit,1,LENGTH(l_operating_unit)-1);

	END IF;

	IF LENGTH(l_operating_unit) > 240 THEN
		l_operating_unit:=SUBSTRB(l_operating_unit,1,237)||'...';
	END IF;

	RETURN l_operating_unit;

EXCEPTION
	WHEN OTHERS THEN
		RETURN NULL;
END;

/*===========================================================================+
 | PROCEDURE
 |              merge_products
 |
 | DESCRIPTION
 |              Merges ERP and CRM's account related products.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mode
 |              OUT:
 |                    status
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES      : For backward compatibility the original signature without
 |              the out NOCOPY parameter error_text calls the modified procedure
 |              with the out NOCOPY parameter for error_text
 |
 | MODIFICATION HISTORY: 02-14-2002 Jyoti Pandey  Created.
  +===========================================================================*/

PROCEDURE merge_products (
          req_id                  NUMBER,
          set_num                 NUMBER,
          process_mode            VARCHAR2,
          status             OUT NOCOPY  NUMBER

) IS

 x_message_text  varchar2(1000);

BEGIN

  merge_products(req_id,set_num,process_mode,status,x_message_text);

END merge_products;

/*===========================================================================+
 | PROCEDURE
 |              merge_products
 |
 | DESCRIPTION
 |              Merges ERP and CRM's account related products.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mode
 |              OUT:
 |                    status
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rashmi Goyal    02-APR-00  Commented out NOCOPY call to asp_cmerge because
 |                       product Oracle Sales (AS) is not expected to work
 |                       in 11i. Commented out NOCOPY call to rla_cmerge because
 |                       product RLA (Automotive) is obsoleted in 11i.
 |    Jianying Huang  13-OCT-00  Bug 1410555: added calls to CRM products.
 |    Jianying Huang  19-OCT-00  Added calls to Property Manager's merge.
 |    Jianying Huang  07-DEC-00  Bug 1391134: Changed procedure createSites to
 |                       set-based and call it here.
 |    Jianying Huang  20-DEC-00  Bug 1535542: Since we will call customer merge
 |                       before merging products, we should move 'createSites'
 |                       in merge_customers. However, to avoid later calling order
 |                       change, I rename it to 'create_same_sites', move it to
 |                       arplbcus.sql(because it is related to customer tables),
 |                       make it public and call it from merge report.
 |    Jianying Huang  10-JAN-01  Added callout to merge pricing.
 |    Jianying Huang  23-JAN-01  Added callout to merge shipping.
 |    Jianying Huang  26-MAR-01  Bug 1706718: Added callout to OM (Order
 |                       Management) merge routines.
 |    Jianying Huang  10-APR-01  Bug 1730028: Add GMS customer merge callout
 |                       (gms_cmerge.merge).
 |    Jianying Huang  10-APR-01  Bug 1730649: Add RLM customer merge callout
 |                       (rlm_cust_merge.merge).
 |    Govind Jayanth  21-JUN-01  Bug 1838214: Added Exchange Billing customer
 |                       merge callout (arp_exchange_merge.cmerge).
 |    Jianying Huang  02-JUL-01  Added callout to jl_cmerge (Bug 1848339).
 |    Jianying Huang  06-AUG-01  Call merge_product to check if product
 |                       merge rountine exist. Only call these routines
 |                       when they exist.
 |    Jianying Huang  06-AUG-01  Added callout to qa_customer.merge (bug 1848406)
 |    Jianying Huang  10-AUG-01  Added callout to csp_merge_pkg.merge_cust_account (bug 1848401).
 |    Jianying Huang  14-AUG-01  Added callout to igi_cmerge.merge (bug 1887139).
 |    Jianying Huang  30-AUG-01  Added callout to fv_cmerge.merge (bug 1870383).
 |    Jianying Huang  19-OCT-01  Removed the callout to Spares Management.
 |                               It is part of CRM (csp_merge_pkg).
 |
 |    Jyoti Pandey    14-FEB-02  Bug: 2228450 Added an OUT NOCOPY parameter error_text
 |                               to catch exceptions raised by merge_products
 |    Ramesh Ch       22-OCT-03  Bug#3178951.Added calls to disable and enable
 |                                Commit in merge_products procedure.
 |    S V Sowjanya    19-NOV-04  Bug 3897822: Commented the statements
 |                                execute immediate 'alter session disable commit in procedure'
 |                                execute immediate 'alter session enable commit in procedure'
 |                                in the procedure merge_products.
 |
 +===========================================================================*/

PROCEDURE merge_products (
          req_id                  NUMBER,
          set_num                 NUMBER,
          process_mode            VARCHAR2,
          status             OUT NOCOPY  NUMBER,
          error_text         OUT NOCOPY  VARCHAR2

) IS

 v_message_text  varchar2(1000);
 success  varchar2(1) := 'N' ;
 l_str_exe VARCHAR2(2000);

BEGIN

--   execute immediate 'alter session disable commit in procedure';  bug 3897822

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_products()+' );


    g_excluded_apps := FND_PROFILE.VALUE('HZ_CMERGE_EXCLUDED_APPS');

    IF g_excluded_apps IS NULL THEN
      g_excluded_apps := 'NONE';
    END IF;

    IF g_excluded_apps = 'ALL' THEN
      status := 0;
      arp_message.set_line( 'ARP_CMERGE_MASTER.merge_products()-' );
      RETURN;
    ELSE
      g_excluded_apps := replace(g_excluded_apps,' ')||',';
    END IF;

    --Oracle Account Receivables
    --arp_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'ARP_CMERGE', 'merge',
        req_id, set_num, process_mode,'AR' );

    --Oracle Account Payables
    --app_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'APP_CMERGE', 'merge',
        req_id, set_num, process_mode,'AP' );

    --commented out NOCOPY call to asp_cmerge because product
    --Oracle Sales (AS) is not expected to work in 11i.
    --asp_cmerge.merge ( req_id, set_num, process_mode );

    --Oracle Service
    --csp_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'CSP_CMERGE', 'merge',
        req_id, set_num, process_mode,'CSP' );

    --Oracle Inventory
    --invp_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'INVP_CMERGE', 'merge',
        req_id, set_num, process_mode,'INV' );

    merge_product (
        'INV_CMERGE_ITEMS', 'merge',
        req_id, set_num, process_mode,'INV');

    --Oracle Master Scheduling/MRP
    --mrpp_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'MRPP_CMERGE', 'merge',
        req_id, set_num, process_mode,'MRP' );

    --Commented out NOCOPY the call out NOCOPY to Order Entry.
    --It has been replaced by Order Managment's merge package.
    --Oracle Order Entry
    --oep_cmerge.merge ( req_id, set_num, process_mode );

    --Oracle Projects
    --pap_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'PAP_CMERGE', 'merge',
        req_id, set_num, process_mode,'PA' );

    --Oracle Purchasing
    --pop_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'POP_CMERGE', 'merge',
        req_id, set_num, process_mode,'PO' );

    --Oracle Training Administration
    --otap_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'OTAP_CMERGE', 'merge',
        req_id, set_num, process_mode,'OTA' );

    --Commented out NOCOPY call to rla_cmerge because product RLA
    --(Automotive) is obsoleted in 11i.
    --rla_cmerge.merge ( req_id, set_num, process_mode );

    --Oracle Property Manager
    --pnp_cmerge.merge( req_id, set_num, process_mode );
    merge_product (
        'PNP_CMERGE', 'merge',
        req_id, set_num, process_mode,'PN' );

    --Pricing
    --qp_cust_merge.merge( req_id, set_num, process_mode );
    merge_product (
        'QP_CUST_MERGE', 'merge',
        req_id, set_num, process_mode,'QP' );

    --Shipping
    --wsh_cust_merge.merge( req_id, set_num, process_mode );
    merge_product (
        'WSH_CUST_MERGE', 'merge',
        req_id, set_num, process_mode,'WSH' );

    --Grants Accounting (GMS)
    --Bug 1730028: Add callout to GMS. Only a stub version
    --has been provided for now.
    --gms_cmerge.merge( req_id, set_num, process_mode );
    merge_product (
        'GMS_CMERGE', 'merge',
        req_id, set_num, process_mode,'GMS' );

    --Oracle Release Management (RLM)
    --Bug 1730649: Add callout to RLM. Only a stub version
    --has been provided for now.
    --rlm_cust_merge.merge( req_id, set_num, process_mode );
    merge_product (
        'RLM_CUST_MERGE', 'merge',
        req_id, set_num, process_mode,'RLM' );

    --Oracle Exchange Billing (currently in AR source control).
    -- customer merge routine.
    --arp_exchange_merge.cmerge( req_id, set_num, process_mode );
    merge_product (
        'ARP_EXCHANGE_MERGE', 'cmerge',
        req_id, set_num, process_mode,'AR_EXCHANGE' );

    -- JL customer merge callout.
    --jl_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'JL_CMERGE', 'merge',
        req_id, set_num, process_mode,'JL' );

    -- Bug 1848406: Oracle Quality
    merge_product (
        'QA_CUSTOMER', 'merge',
        req_id, set_num, process_mode,'QA' );

/* remove the callout to Spares Management. It is part of CRM.
    -- Bug 1848401: Spares Management
    merge_product (
        'CSP_MERGE_PKG', 'merge_cust_account',
        req_id, set_num, process_mode );
*/

    -- Bug 1887139 : Public sector financials
    merge_product (
        'IGI_CMERGE', 'merge',
        req_id, set_num, process_mode,'IGI' );

    -- Bug 1870383: Federal Financials

    merge_product (
        'FV_CMERGE', 'merge',
        req_id, set_num, process_mode,'FV' );

    -- Bug 2057511: Multi Currency Credit Checking
    merge_product (
        'OE_MGD_MCC_MERGE', 'customer_merge',
        req_id, set_num, process_mode,'MCC' );

    -- Bug 2177889: Added AX Merge Procedure
    -- Bug 4661029: AX is obsoleted.Remove it
  /*  merge_product (
        'AX_SC_MERGE_PKG','MergeTCA',
        req_id, set_num, process_mode,'AX' );
  */

     --Bug 2236975:Oracle Student System Product(IGS)
     merge_product (
        'IGS_FI_MERGE_CUST', 'MERGE',
        req_id, set_num, process_mode,'IGS' );

     --Bug 2469023: JG
     -- Bug 4778792 - JG_ZZ_MERGE_CUSTOMERS is obsoleted
   /*  merge_product (
        'JG_ZZ_MERGE_CUSTOMERS', 'MERGE',
        req_id, set_num, process_mode,'JG' );
   */

    IF instrb(g_excluded_apps,'CRM,') = 0 THEN

      --Bug 1410555: Added calls to CRM products.
      merge_crm_products( req_id, set_num, process_mode );
    END IF;

--Bug Fix 2669389
--Oracle Order Managment
    --oe_cust_merge.merge( req_id, set_num, process_mode );
    merge_product (
        'OE_CUST_MERGE', 'merge',
        req_id, set_num, process_mode,'ONT' );

    --Generic merge package. (see arplbst9.sql)
    -- arp_generic_cmerge.merge ( req_id, set_num, process_mode );
    merge_product (
        'ARP_GENERIC_CMERGE', 'merge',
        req_id, set_num, process_mode,'GENERIC');


    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_products()-' );

--    execute immediate 'alter session enable commit in procedure'; bug 3897822

EXCEPTION

    WHEN OTHERS THEN
       begin
        status := -1;
        v_message_text := arp_message.get_last_few_messages(2);
        error_text := G_PRODUCT_RAISING_EXCEPTION ||' '||v_message_text;
        arp_message.set_line(v_message_text);
        exception
        when others then
         null;
      end;

END merge_products;

/*===========================================================================+
 | PROCEDURE
 |               update_merge_as_failed
 |
 | DESCRIPTION
 |         Update a bad merge record as failed.
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    customer_merge_header_id
 |                    p_error_text
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |  04-02-2003             Rajeshwari        Bug 2669389 Created.
 |  04-07-2003             Rajeshwari        Removed the update of set_number
 |                                           to -1.
 +===========================================================================*/

procedure update_merge_as_failed(
        p_request_id                  IN      NUMBER,
        p_set_num                     IN      NUMBER,
        p_customer_merge_header_id    IN      NUMBER,
        p_error_text                  IN      VARCHAR2
) IS

BEGIN
       UPDATE ra_customer_merges set process_flag = 'FAILED'
       WHERE request_id = p_request_id
       AND customer_merge_header_id = p_customer_merge_header_id
       ;

       UPDATE ra_customer_merge_headers
       SET process_flag = 'FAILED',merge_fail_msg = p_error_text
       WHERE request_id = p_request_id
       AND customer_merge_header_id = p_customer_merge_header_id
       ;


EXCEPTION
WHEN OTHERS THEN
NULL;
END update_merge_as_failed;

/*===========================================================================+
 | PROCEDURE
 |              merge_product
 |
 | DESCRIPTION
 |              Merges a perticular product using dynamic sql to lower the
 |              dependencies.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    package_name
 |                    api_name
 |                    req_id
 |                    set_num
 |                    process_mode
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |    Jianying Huang  06-AUG-01  Created.
 |    Rajeshwari P    02-APR-03  Modified the code to identify bad merge
 |                               records by running each record in the set
 |                               individually for a product call which failed.
 |     Ramesh Ch      22-OCT-03  Bug#3178951.Changed savepoint name from start
 |                               start_merge_product.
 |     S V Sowjanya   28-OCT-04  Bug 3751217 : In merge_product procedure, removed variable ok.
 |                                Replaced literals with bind variables in dynamic sqls.
 |                                Removed exception handling code at parse time.
 |                                Exception ORA-6550 is handled.
 +===========================================================================*/

PROCEDURE merge_product (
          package_name             VARCHAR2,
          api_name                 VARCHAR2,
          req_id                   NUMBER,
          set_num                  NUMBER,
          process_mode             VARCHAR2,
          product_code             VARCHAR2
) IS

--raji
          l_dummy                  VARCHAR2(1):= 'N' ;
          success                 VARCHAR2(1):= 'N' ;
          v_last_set              NUMBER;
          OTHERS                  EXCEPTION;
          error_text              VARCHAR2(2000);
          l_customer_merge_header_id NUMBER;

          l_sql                    VARCHAR2(200);
	  c			   NUMBER;
	  n			   NUMBER;
l_count    NUMBER;

BEGIN
--raji
while ( success <> 'Y' ) LOOP

SAVEPOINT "start_merge_product";

IF l_dummy = 'N' then


    IF instrb(g_excluded_apps,product_code||',') > 0 THEN
      RETURN;
    END IF;

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_product(' ||
        package_name || ')+' );

    BEGIN
        c := dbms_sql.open_cursor;
	l_sql :=  'BEGIN  ' ||
                  package_name || '.' || api_name ||
                           '(:req_id, :set_num, :process_mode ); END; ';

	dbms_sql.parse(c,l_sql,2);
        dbms_sql.bind_variable(c, 'req_id',to_char(req_id));
        dbms_sql.bind_variable(c, 'set_num',to_char(set_num));
        dbms_sql.bind_variable(c, 'process_mode',process_mode);
        n := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
--        EXECUTE IMMEDIATE l_sql;
--raji
        success := 'Y' ;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
ROLLBACK to "start_merge_product";
l_dummy := 'Y' ;
success := 'N' ;
        WHEN OTHERS THEN

          IF SQLCODE = -6550 THEN
            success := 'Y' ;
	   dbms_sql.close_cursor(c);
          ELSIF SQLCODE <> -6550 THEN
--Bug fix 2669389,rollback to run the records individually to identify the bad record.

ROLLBACK to "start_merge_product";
l_dummy := 'Y' ;
success := 'N' ;
END IF;
END ;

--raji
elsif l_dummy = 'Y' then

-- Partition the set into single batch(set size=1)

  unpartiton_merge_data(req_id,v_last_set,set_num);

    FOR v_current_set in 1001..v_last_set LOOP
  BEGIN

        c := dbms_sql.open_cursor;

        l_sql :=  'BEGIN  ' ||
                       package_name || '.' || api_name ||
                           '(:req_id, :v_current_set, :process_mode ); END; ';

        dbms_sql.parse(c,l_sql,2);
        dbms_sql.bind_variable(c, 'req_id',to_char(req_id));
        dbms_sql.bind_variable(c, 'v_current_set',to_char(v_current_set));
        dbms_sql.bind_variable(c, 'process_mode',process_mode);
        n := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
--        EXECUTE IMMEDIATE l_sql;

 EXCEPTION
       WHEN OTHERS THEN
     IF SQLCODE = -6550 THEN
   dbms_sql.close_cursor(c);
    ELSIF SQLCODE <> -6550 THEN
 G_PRODUCT_RAISING_EXCEPTION := product_code||'.'|| package_name || '.' || api_name ;
 error_text := G_PRODUCT_RAISING_EXCEPTION || ' ' || arp_message.get_last_few_messages(2);

--raji

BEGIN
--Get the bad merge records and update them as failed.

    select customer_merge_header_id into l_customer_merge_header_id
    from ra_customer_merges
    where request_id = req_id
    AND set_number = v_current_set
    AND process_flag = 'N'
    AND ROWNUM = 1
    FOR UPDATE NOWAIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
END;

      update_merge_as_failed (
           req_id,
           v_current_set,
           l_customer_merge_header_id,
           error_text
                             );
     END IF;
       END ;

--reset back the original set number

update ra_customer_merges
set set_number = set_num
WHERE request_id = req_id
AND (process_flag = 'N' or process_flag = 'FAILED')
AND set_number = v_current_set;

    END LOOP;

--Finished processing the set in set_size of 1
BEGIN
   SELECT count(*) INTO l_count
   FROM ra_customer_merges
   WHERE request_id = req_id
   AND set_number = set_num
   AND process_flag = 'FAILED'
   ;


IF l_count > 0 then
   success := 'Y' ;
--Since atleast one record has failed we will ROLLBACK the whole set
   RAISE OTHERS;
ELSE
--getting errors from FV_Cmerge
   success := 'Y' ;

END IF;

end;

END IF;

END LOOP;

EXCEPTION
 WHEN OTHERS THEN
--      G_PRODUCT_RAISING_EXCEPTION := product_code||'.'|| package_name || '.' || api_name ;
      raise;

arp_message.set_line( 'ARP_CMERGE_MASTER.merge_product(' || package_name || ')-' );

END merge_product;

/*===========================================================================+
 | PROCEDURE
 |               merge_crm_products
 |
 | DESCRIPTION
 |              Merges CRM products.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mode
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  13-OCT-00  Bug 1410555: the procedure is created to
 |                       call crm customer merge procedure.
 |    Jianying Huang  26-OCT-00  Add exception handler to populate exception
 |                       to caller. Add calls to write log file.
 |    Jianying Huang  14-NOV-00  Remove comparision: product_code = 'AR'
 |                       because CRM register their products using
 |                       different code.
 |    Jianying Huang  15-NOV-00  Modify merge_crm_products. Add condition
 |                       EXECUTE_FLAG = 'Y'.
 |    Jianying Huang  29-MAR-01  Bug 1706869: Modified the procedure to:
 |                        1. simplify the dynamic sql.
 |                        2. add cursor 'ISOPEN' checking in excepion handler.
 |   Rajeshwari P    02-APR-2003 Bug fix2669389.Modified code to call merge_product.
 |
 +===========================================================================*/

PROCEDURE merge_crm_products(
          req_id                   NUMBER,
          set_num                  NUMBER,
          process_mode             VARCHAR2
) IS

          TYPE crm_cursor_type     IS REF CURSOR;
          crm_products             crm_cursor_type;

          l_hook_package           VARCHAR2(40);
          l_hook_api               VARCHAR2(40);

          cur_sql                  VARCHAR2(400);
          l_sql                    VARCHAR2(200);
          l_exist                  VARCHAR2(1);
          l_product_code	   VARCHAR2(10);
          l_bool   BOOLEAN;
          l_status VARCHAR2(255);
          l_schema VARCHAR2(255);
          l_tmp    VARCHAR2(2000);
BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_crm_products()+' );

--To minimize dependency, we need to call CRM's merge procedure
--dynanmically. First we need to check if table jtf_hooks_data
--exists, if yes, we need to see if there are crm's merge procedures
--we need to call and call them sequencially (order by execution order)

    BEGIN

   l_bool := fnd_installation.get_app_info('JTF',l_status,l_tmp,l_schema);

       SELECT 'Y' INTO l_exist
       FROM sys.all_tables
       WHERE table_name = 'JTF_HOOKS_DATA'
       AND ROWNUM = 1 and owner = l_schema;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
         l_exist := 'N';
    END;

    IF l_exist = 'Y' THEN

       cur_sql := 'SELECT hook_package, hook_api,product_code ' ||
                  'FROM jtf_hooks_data '||
                  'WHERE package_name = ''ARP_CMERGE_MASTER'' ' ||
                  'AND api_name = ''MERGE_PRODUCTS'' ' ||
                  'AND execute_flag = ''Y'' ' ||
                  'ORDER BY execution_order ';

       OPEN crm_products FOR cur_sql;
       LOOP

          FETCH crm_products INTO l_hook_package, l_hook_api, l_product_code;
          EXIT WHEN crm_products%NOTFOUND;

          IF instrb(g_excluded_apps,l_product_code||',') = 0 THEN
          begin
--Bug fix 2669389
-- Call Merge_product

          merge_product(l_hook_package,l_hook_api,req_id,set_num,process_mode,l_product_code);

            EXCEPTION
             WHEN OTHERS THEN
             G_PRODUCT_RAISING_EXCEPTION :=  l_product_code||'.'||l_hook_package || '.' || l_hook_api ;
             raise;
           end;
          END IF;

       END LOOP;
       CLOSE crm_products;

    END IF;

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_crm_products()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.merge_crm_products');

      IF crm_products%ISOPEN THEN
         CLOSE crm_products;
      END IF;

      RAISE;

END merge_crm_products;

/*===========================================================================+
 | PROCEDURE
 |              merge_customers
 |
 | DESCRIPTION
 |              Merges customer tables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |                    process_mode
 |              OUT:
 |                    status
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE merge_customers (
          req_id                   NUMBER,
          set_num                  NUMBER,
          process_mode             VARCHAR2,
          status              OUT NOCOPY  NUMBER
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_customers()+' );

    --merge accout site uses, sites, account etc.
    arp_cmerge_arcus.merge(req_id, set_num, process_mode);

    --merge customer profiles, credit histories, etc.
    arp_cmerge_arcpf.merge(req_id, set_num, process_mode);

    status := 0;

    arp_message.set_line( 'ARP_CMERGE_MASTER.merge_customers()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.merge_customers');
      status := -1;

END merge_customers;

/*===========================================================================+
 | PROCEDURE
 |              delete_rows
 |
 | DESCRIPTION
 |              Delete marked rows in customer tables.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |              OUT:
 |                    status
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  20-DEC-00  Created for bug 1535542.
 |
 +===========================================================================*/

PROCEDURE delete_rows (
          req_id                   NUMBER,
          set_num                  NUMBER,
          status              OUT NOCOPY  NUMBER
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.delete_rows()+' );

    --delete customer tables
    arp_cmerge_arcus.delete_rows( req_id, set_num );

    --delete customer related tables
    arp_cmerge_arcpf.delete_rows( req_id, set_num );

    status := 0;

    arp_message.set_line( 'ARP_CMERGE_MASTER.delete_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.delete_rows');
      status := -1;

END delete_rows;

/*===========================================================================+
 | PROCEDURE
 |               mark_merge_rows
 |
 | DESCRIPTION
 |              Mark rows with request_id. The rows include those
 |              ones which errored out NOCOPY previously.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    p_process_flag
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  29-NOV-00  Bug 1519688: Modified procedure based on
 |                       the change of merge form:
 |                       'display request id instantly after hit merge button'
 |    Jianying Huang  24-JAN-01  Bug 1611300: Marked merge rows based on
 |                       the process_flag passed in.
 |    Jianying Huang  30-MAR-01  Bug 1706869: Modified 'mark_merge_rows'
 |                       to differential the merge processes submited through
 |                       form and submited as a concurrent request.
 |    Jianying Huang  07-APR-01  Bug 1725662: Rewrite some queries based on
 |                       the new added indexes for performance improvements.
 |    Jianying Huang  22-JUL-01  Modified 'mark_merge_rows' to mark only the
 |                       records with current request id if process_flag='PROCESSING'.
 |    S V Sowjanya  19-NOV-04    Bug 3897822: Added parameters p_priority,
 |                               p_number_of_merges to procedure mark_merge_rows and merge rows
 |                               are marked based on parameters p_priority and p_number_of_merges.
 |    S V Sowjanya  16-NOV-04    Bug 4693912: Modified update statement in mark_merge_rows
 |
 +===========================================================================*/

PROCEDURE mark_merge_rows (
          req_id                   NUMBER,
          p_process_flag           VARCHAR2,
          p_merge_rule             VARCHAR2,
          p_priority               VARCHAR2,
          p_number_of_merges       NUMBER
) IS

    CURSOR c_requests(c_priority varchar2) IS
        SELECT distinct request_id, process_flag
        FROM ra_customer_merge_headers
        WHERE process_flag IN ('PROCESSING', 'N')
        AND priority = c_priority;

    l_request_id                   NUMBER;
    l_process_flag                 VARCHAR2(30);
    l_pickup                       BOOLEAN;
    l_new_process_flag             VARCHAR2(30);

    l_conc_phase                   VARCHAR2(80);
    l_conc_status                  VARCHAR2(80);
    l_conc_dev_phase               VARCHAR2(30);
    l_conc_dev_status              VARCHAR2(30);
    l_message                      VARCHAR2(240);
--3897822
    TYPE customer_merge_header_id_tab IS TABLE OF RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE INDEX BY BINARY_INTEGER;
    TYPE process_flag_tab IS TABLE OF RA_CUSTOMER_MERGE_HEADERS.PROCESS_FLAG%TYPE INDEX BY BINARY_INTEGER;
    l_header_id_t customer_merge_header_id_tab;
    l_process_flag_t process_flag_tab;
BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.mark_merge_rows()+' );

    /* >>>MODIFY: need to pick up terminated rows as well */

/** N/A
--Bug 1519688: remove condition 'request_id is NULL'. The
--request_id is unset by  'reset_merge_rows' if there are
--some error occur during merge. If we need to display/query
--the request id even the merge has not been sucessfully done,
--we should not unset request id. So when we pick up the
--previously errored out NOCOPY merge process, we should not use
--'request_id is NULL', instead, we can re-use 'process_flag'
--to indicate those 'merges' are being processed and those
--we need to pick up. (process_flag = 'N' means there is
--another concurrent program who is processing this merge.
--We set process_flag = 'SAVED' in merge form to indicate
--it is a new submitted merge and set process_flag = 'FAILED'
--to indicate those merges were failed by last concurrent
--program)

--Bug 1611300: Marked the merge rows which process_flag is either FAILED
--or equals to the passin process_flag. Right now the passin process_flag
--has 2 values:
      --PROCESSING means the merge has been submitted from merge
                 --form which we should merge during this merge run.
      --SAVED      means the merge has been saved and submitted along with
                 --other processes as a batch.

--Bug 1706869:
      --If end-user submits merge from form, i.e. process_flag is
           --PROCESSING, only the submited one will be processed.
      --If end-user submits a concurrent request of customer merge
           --directly, all of the saved and failed merge processes,
           --i.e. process_flag is 'SAVED' or 'FAILED', will be processed.

--Bug 1725622:Merge header table has much less rows then merge detail table.
--It's better to update header table first, then update merge detail table
--using index.
**/

    -- The process_flag can have 5 different value
       -- PROCESSING merge request is in pending. The flag is used only for
       --            merge submitted from form.
       -- SAVED      merge is saved for later use.
       -- N          merge is being processed.
       -- FAILED     merge failed
       -- Y          merge finished successfully.
    -- The process_flag in header table and process_flag in merge detail table
    -- must be in sync otherwise, user will not see merge details in merge form
    -- when they do query.
    -- This procedure (i.e. mark_merge_rows) is changed to handle:
    -- 1. update process_flag in header and detail tables to make them in sync.
       -- Details:
          -- Select all of request_id from header table. If process_flag = N, but
          -- request is not in running or if process_flag = 'PROCESSING', but
          -- request is not in pending, update the process_flag = 'SAVED'.

          -- if there exists one merge detail which has process_flag = 'Y', update
          -- merge table's process_flag to 'Y'.
    -- 2. mark merge rows by updating process_flag and request_id in detail table.
    -- 3. exclude those addresses in other operating units by checking if address
    --    exists in hz_cust_acct_sites.

    -- Added l_new_process_flag for backward compatible.
    IF p_merge_rule = 'NEW' THEN
        l_new_process_flag := p_process_flag;
    ELSE
        l_new_process_flag := 'N';
    END IF;
    IF p_process_flag = 'PROCESSING' THEN
	UPDATE ra_customer_merge_headers
        SET process_flag = p_process_flag
	WHERE request_id = req_id;
    END IF;

    IF p_process_flag = 'SAVED' THEN
--3897822
        SELECT customer_merge_header_id, process_flag
        BULK COLLECT INTO l_header_id_t,l_process_flag_t
        FROM ra_customer_merge_headers mh
        WHERE process_flag IN ('PROCESSING', 'N')
        AND priority = p_priority;

        OPEN c_requests(p_priority);
        LOOP
            FETCH c_requests INTO l_request_id, l_process_flag;
            EXIT WHEN c_requests%NOTFOUND;

            l_pickup := FALSE;

            IF l_request_id IS NOT NULL THEN
                IF ( FND_CONCURRENT.GET_REQUEST_STATUS(
                        request_id  => l_request_id,
                        phase       => l_conc_phase,
                        status      => l_conc_status,
                        dev_phase   => l_conc_dev_phase,
                        dev_status  => l_conc_dev_status,
                        message     => l_message ) )
                THEN
                    IF (l_process_flag = 'PROCESSING' AND
                        l_conc_dev_phase <> 'PENDING') OR
                       (l_process_flag = 'N' AND
                        l_conc_dev_phase <> 'RUNNING' )
                    THEN
                       l_pickup := TRUE;
                    END IF;
                ELSE
                    l_pickup := TRUE;
                END IF;

                IF l_pickup THEN
                    UPDATE ra_customer_merge_headers
                    SET process_flag = l_new_process_flag
                    WHERE request_id = l_request_id
                    AND process_flag = l_process_flag
                    AND priority = p_priority; --3897822
                END IF;
            ELSE
                UPDATE ra_customer_merge_headers
                SET process_flag = l_new_process_flag
                WHERE request_id IS NULL
                AND process_flag = l_process_flag
                AND priority = p_priority; --3897822
            END IF;
        END LOOP;
        CLOSE c_requests;

    ELSIF p_process_flag = 'FAILED' THEN
        UPDATE ra_customer_merge_headers
        SET process_flag = l_new_process_flag
        WHERE process_flag LIKE 'ERROR%';
    END IF;

    IF p_merge_rule = 'OLD' THEN
        UPDATE ra_customer_merge_headers
        SET process_flag = l_new_process_flag
        WHERE process_flag = p_process_flag;
    END IF;

   IF p_process_flag<> 'PROCESSING' THEN
      UPDATE ra_customer_merge_headers mh
      SET    request_id = req_id  ,
             merge_fail_msg = null
      WHERE  process_flag = l_new_process_flag
      --Start of SSUptake
      AND    NOT EXISTS (
              select 'Y' from ra_customer_merges m
	      where m.customer_merge_header_id = mh.customer_merge_header_id
	      and   mo_global.check_access(m.org_id) <> 'Y'
	      and   rownum =1
             )
      --End of SSUptake
      AND    ( EXISTS (
             SELECT 'Y'
             FROM ra_customer_merges m, hz_cust_acct_sites site
             WHERE m.customer_merge_header_id = mh.customer_merge_header_id
             AND   m.duplicate_address_id = site.cust_acct_site_id
	     AND   ROWNUM = 1)
             OR EXISTS(                                                       --4693912
	     SELECT 'Y'
	     FROM ra_customer_merges m
	     WHERE m.customer_merge_header_id = mh.customer_merge_header_id
	     AND m.duplicate_address_id = -1)
	     )
     AND    customer_merge_header_id in (SELECT customer_merge_header_id             --3897822
                                         FROM   (SELECT customer_merge_header_id
                                                  FROM ra_customer_merge_headers
                                                  WHERE process_flag = l_new_process_flag
                                                  AND   priority = p_priority
                                                  ORDER BY last_update_date)
                                         WHERE ROWNUM <= p_number_of_merges)
      AND    mh.priority = p_priority;

      FORALL i IN 1..l_header_id_t.count
         UPDATE ra_customer_merge_headers mh
         SET process_flag = l_process_flag_t(i)
         WHERE request_id <> req_id
         AND mh.customer_merge_header_id = l_header_id_t(i);
   END IF;

--N/A  --Bug 1519688: Set request_id for merge headers.

--Bug 1725662: Set request_id from ra_customer_merges. Rewrite sql to
--use index.

    UPDATE ra_customer_merge_headers mh
    SET process_flag = 'Y'
    WHERE request_id = req_id
    AND process_flag = l_new_process_flag
    AND priority = p_priority    --3897822
    AND EXISTS (
        SELECT 'Y'
        FROM ra_customer_merges m
        WHERE m.customer_merge_header_id = mh.customer_merge_header_id
        AND   m.process_flag = 'Y'
        AND   ROWNUM = 1 );

    UPDATE ra_customer_merges m
    SET (request_id,
         process_flag) = (
            SELECT mh.request_id, mh.process_flag
            FROM   ra_customer_merge_headers mh
            WHERE  mh.customer_merge_header_id = m.customer_merge_header_id
            AND    mh.process_flag = l_new_process_flag )
    WHERE m.customer_merge_header_id IN (
        SELECT mh.customer_merge_header_id
        FROM   ra_customer_merge_headers mh
        WHERE  mh.process_flag = l_new_process_flag
        AND request_id = req_id
        AND mh.priority = p_priority); --3897822

    arp_message.set_line( 'ARP_CMERGE_MASTER.mark_merge_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.mark_merge_rows');
      RAISE;

END mark_merge_rows;

/*===========================================================================+
 | PROCEDURE
 |              add_request
 |
 | DESCRIPTION
 |          For handling terminated requests, add request to
 |          the AR concurrent request table.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    program_name
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE add_request (
          req_id                      NUMBER,
          program_name                VARCHAR2
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.add_request()+' );

    INSERT into ar_conc_process_requests
      (request_id, concurrent_program_name)
    VALUES
      (req_id, program_name);

    arp_message.set_line( 'ARP_CMERGE_MASTER.add_request()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.add_request' );
      RAISE;

END add_request;

/*===========================================================================+
 | PROCEDURE
 |              validate_merges
 |
 | DESCRIPTION
 |              Validate merge candidate.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    p_process_flag
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |         Procedure to validate the RA_CUSTOMER_MERGE records prior to
 |         using them as the source for the merge process
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  07-DEC-00  Bug 1391134: We modified createSites as
 |                       set-based procedure and call if before merge products
 |                       for each set. We also set not-null columns
 |                       customer_address_id and customer_site_id in table
 |                       ra_customer_merges to -1, so merge form can submit
 |                       the merges. To accommodate that changes, we donot
 |                       validate those records with customer_createsame = 'Y'
 |    Jianying Huang  08-MAR-01  Bug 1610924: Modified the procedure to allow
 |                       merging all of the site uses.
 |    Jianying Huang  07-APR-01  Bug 1725662: Rewrite some queries based on
 |                       the new added indexes for performance improvements.
 |    Ramesh Ch       21-Nov-03  Bug 3186432.Added duplicate_site_id <> -99
 |                               condition in check_invalid_merges cursor.
 |    S V Sowjanya    10-AUG-04  Bug 3705423: Commented (duplicate_site_id <> -99 and
 |                               customer_site_id <> -99), duplicate_site_id <> -99  conditions
 |                               and  added code to join address_id of the customers in
 |                               check_invalid_merges cursor.
 |    S V Sowjanya    16-NOV-05  Bug 4693912: Modified cursor check_invalid_merges to
 |		                 exclude records with duplicate_address_id '-1'
 +===========================================================================*/

PROCEDURE validate_merges (
          req_id                    NUMBER,
          p_process_flag            VARCHAR2
) IS

    --Select statements to select invalid merges

    CURSOR val_all_sites_merged IS
        /** N/A
         If merging to a different customer,
           all SHIP_TO, BILL_TO and MARKET sites must be merged       */

        /** Bug 1610924
         If merging to a different customer,
           all of the site uses much be merged.

         Select
             all sites that must be merged
               MINUS
             all sites specified in ra_customer_merges
         Migration to new customer model.
         -------------------------------
         With the new cust. model, cust acct and sites are already
         striped by ou. The cust accts are no longer global.
         Because the sites will not be referenced in other ou,
         the tables that will replace RA_ADDRESSES and RA_SITE_USES
         will be HZ_CUST_ACCT_SITES and HZ_CUST_SITE_USES.
         Columns will be changed correspondingly.
        */

      --Bug 1725662: rewrite query to use index on
      --ra_customer_merge_headers.(request_id, process_flag);

        SELECT su.site_use_id  site_use_id,
               mh.duplicate_id  duplicate_id
        FROM   hz_cust_acct_sites    addr,
               hz_cust_site_uses     su,
               ra_customer_merge_headers mh
        WHERE  mh.request_id = req_id
        AND    mh.process_flag = p_process_flag
	AND    (mh.org_id = -1 OR (mh.org_id <> -1 AND addr.org_id = mh.org_id)) --SSUptake
        AND    mh.duplicate_id <> mh.customer_id
        AND    su.cust_acct_site_id = addr.cust_acct_site_id
        AND    addr.cust_account_id = mh.duplicate_id
	AND    NOT EXISTS (
               SELECT 'same site in merge detail'
               FROM   ra_customer_merges m
               WHERE  m.customer_merge_header_id = mh.customer_merge_header_id
               AND    m.duplicate_site_id = su.site_use_id
               AND    m.org_id  = su.org_id
	       );

--Bug 1391134: ignore those records with customer_createsame = 'Y'
--in ra_customer_merges table.

    CURSOR check_invalid_merges IS
        /**
         Merge is INVALID if:
         - customer_site_id = duplicate_site_id of another row
         - duplicate_site_id = customer_site_id of another row
         - duplicate_site_id = duplicate_site_id of another row
        */

        SELECT m.duplicate_id duplicate_id
        FROM   ra_customer_merges m
        WHERE  m.process_flag = p_process_flag
        AND    m.request_id = req_id
        AND    duplicate_address_id <> -1 --4693912
--        AND    (m.duplicate_site_id <> -99 AND m.customer_site_id <> -99)
        AND    ((m.customer_createsame <> 'Y'
                 AND (m.customer_site_id IN (
                         SELECT m2.duplicate_site_id
                         FROM   ra_customer_merges m2
                         WHERE  m2.rowid <> m.rowid
                         AND    m2.process_flag = p_process_flag
                         AND    m2.duplicate_address_id = m.customer_address_id )
                      OR m.duplicate_site_id IN (
                         SELECT m2.customer_site_id
                         FROM   ra_customer_merges m2
                         WHERE  m2.rowid <> m.rowid
                         AND    m2.process_flag = p_process_flag
                         AND    m2.customer_address_id = m.duplicate_address_id )))
               OR m.duplicate_site_id IN (
                         SELECT m2.duplicate_site_id
                         FROM   ra_customer_merges m2
                         WHERE  m2.rowid <> m.rowid
                         AND    m2.process_flag = p_process_flag
			 --AND    m2.duplicate_site_id <> -99
                         AND    m2.duplicate_address_id = m.duplicate_address_id));

    missing_sites      val_all_sites_merged%ROWTYPE;
    invalid_merges     check_invalid_merges%ROWTYPE;
    error_msg		VARCHAR2(240); -- Bug No: 3743818
BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.validate_merges()+' );

    FOR missing_sites IN val_all_sites_merged LOOP

        --Mark Invalid Merges
        UPDATE ra_customer_merges
        SET    process_flag = 'ERROR 1'
        WHERE  duplicate_id = missing_sites.duplicate_id
        AND    request_id = req_id
        AND    process_flag = p_process_flag;

--Bug 1725662: Add the following sql to save performance in
--clear_error_merge_rows.

        UPDATE ra_customer_merge_headers
        SET    process_flag = 'ERROR 1'
        WHERE  duplicate_id = missing_sites.duplicate_id
        AND    request_id = req_id
        AND    process_flag = p_process_flag;
	---Start of Bug No : 3743818
	fnd_message.set_name('AR', 'AR_CMERGE_MISSING_SITES');
	error_msg := fnd_message.get();
	arp_message.set_line('Duplicate Id : '|| missing_sites.duplicate_id ||' -- '||error_msg);
	--End Of Bug No: 3743818

    END LOOP;

    FOR invalid_merges IN check_invalid_merges LOOP

         --Mark Invalid Merges
        UPDATE ra_customer_merges
        SET    process_flag = 'ERROR 2'
        WHERE  duplicate_id = invalid_merges.duplicate_id
        AND    request_id = req_id
        AND    process_flag = p_process_flag;

--Bug 1725662: Add the following sql to save performance in
--clear_error_merge_rows.

        UPDATE ra_customer_merge_headers
        SET    process_flag = 'ERROR 2'
        WHERE  duplicate_id = invalid_merges.duplicate_id
        AND    request_id = req_id
        AND    process_flag = p_process_flag;

	---Start of Bug No : 3743818
	fnd_message.set_name('AR', 'AR_CMERGE_DUPLICATE_SITE');
	error_msg := fnd_message.get();
	arp_message.set_line( ' Duplicate Id : '||invalid_merges.duplicate_id ||' -- '||error_msg);
	--End Of Bug No: 3743818

    END LOOP;

    arp_message.set_line( 'ARP_CMERGE_MASTER.validate_merges()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.validate_merges' );
      RAISE;

END validate_merges;

/*===========================================================================+
 | PROCEDURE
 |              partiton_merge_data
 |
 | DESCRIPTION
 |              Partition merge sets
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    p_process_flag
 |              OUT:
 |                    last_set
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE partiton_merge_data(
          req_id                   NUMBER,
          last_set            OUT NOCOPY  NUMBER,
          p_process_flag           VARCHAR2
) IS

    CURSOR partition is
       SELECT rowid, duplicate_id
       FROM   ra_customer_merges
       WHERE  request_id = req_id
       AND    process_flag = p_process_flag
       ORDER BY duplicate_id;

    v_rowid             VARCHAR2(24);
    v_prev_customer_id  NUMBER := null;
    v_customer_id       NUMBER := null;
    v_count             NUMBER := 0;
    v_set_size          NUMBER;
    v_last_set          NUMBER := 1;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.partiton_merge_data()+' );

    v_set_size := fnd_profile.value('AR_CMERGE_SET_SIZE');

    OPEN partition;

    LOOP
      FETCH partition into v_rowid, v_customer_id;
      EXIT when partition%notfound;

      --always group by duplicate_id, even if set limit has been
      --exceeded

      --check if first or new customer
      IF ( v_prev_customer_id is null or
           v_prev_customer_id <> v_customer_id ) then

        --check if set limit has been reached
         IF ( v_count >= v_set_size ) then
              v_last_set := v_last_set + 1;
            v_count := 0;
         END IF;

         v_prev_customer_id := v_customer_id;

      END IF;

      v_count := v_count + 1;

      UPDATE ra_customer_merges
      SET set_number = v_last_set
      WHERE  rowid = v_rowid;

    END loop;

    CLOSE partition;

    last_set := v_last_set;


    arp_message.set_line( 'ARP_CMERGE_MASTER.partiton_merge_data()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.partition_merge_date' );
      RAISE;

END partiton_merge_data;

/*===========================================================================+
 | PROCEDURE
 |              unpartiton_merge_data
 |
 | DESCRIPTION
 |              Partition merge sets to a set size of 1 inorder to
 |              identify the bad merge records.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |              OUT:
 |                    last_set
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |              Rajeshwari    04-02-2003                 Bug 2669389 Created.
 |              Rajeshwari P  04-07-2003                 Modified code to set
 |                                                       the set_number starting
 |                                                       from 1001 to avoid conflict.
 +===========================================================================*/

 PROCEDURE unpartiton_merge_data(
          req_id                   NUMBER,
          last_set            OUT NOCOPY  NUMBER,
          set_num           NUMBER
) IS

    CURSOR partition is
       SELECT rowid, duplicate_id
       FROM   ra_customer_merges
       WHERE  request_id = req_id
       AND    set_number = set_num
       ORDER BY duplicate_id;

    v_rowid             VARCHAR2(24);
    v_prev_customer_id  NUMBER := null;
    v_customer_id       NUMBER := null;
    v_count             NUMBER := 1000;
    v_set_size          NUMBER;
    v_last_set          NUMBER := 1001;
l_count number;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.unpartiton_merge_data()+' );

    v_set_size := 1001;

    OPEN partition;

    LOOP
      FETCH partition into v_rowid, v_customer_id;
      EXIT when partition%notfound;

      --always group by duplicate_id, even if set limit has been
      --exceeded

      --check if first or new customer
      IF ( v_prev_customer_id is null or
           v_prev_customer_id <> v_customer_id ) then

        --check if set limit has been reached
         IF ( v_count >= v_set_size ) then
              v_last_set := v_last_set + 1;
            v_count := 1000;
         END IF;

         v_prev_customer_id := v_customer_id;

      END IF;

     v_count := v_count + 1;

      UPDATE ra_customer_merges
      SET set_number = v_last_set
      WHERE request_id = req_id
      AND rowid = v_rowid;

    begin
    select set_number into l_count
    from ra_customer_merges
    where request_id = req_id
    AND set_number = v_last_set
    AND rowid = v_rowid;
exception
   when no_data_found then
NULL;
end;

    END loop;

    CLOSE partition;

    last_set := v_last_set;


    arp_message.set_line( 'ARP_CMERGE_MASTER.partiton_merge_data()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.partition_merge_date' );
      RAISE;

END unpartiton_merge_data;
/*===========================================================================+
 | PROCEDURE
 |                done_merge_rows
 |
 | DESCRIPTION
 |              Sets process flag to 'Y' in the header and merges table
 |              for successful merges
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  29-NOV-00  Bug 1519688: Modified procedure
 |                       based on the change of merge form:
 |                       'display request id instantly after hit merge button'
 |    Jianying Huang  21-DEC-00  Call read_temporary_table for debug purpose.
 |    Jianying Huang  07-APR-01  Bug 1725662: Rewrite some queries based on
 |                       the new added indexes for performance improvements.
 |
 +===========================================================================*/

PROCEDURE done_merge_rows (
          req_id                   NUMBER,
          set_num                  NUMBER
) IS

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.done_merge_rows()+' );

    --delete customer alternative names
    arp_cmerge_master.delete_customer_alt_names ( req_id , set_num ) ;

    UPDATE ra_customer_merges
    SET process_flag = 'Y',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE request_id = req_id
    AND   set_number = set_num
    AND   process_flag = 'N';

--Bug 1519688: Do not need to set request_id.
--Bug 1725662: replace 'EXISTS' with 'IN' to use index.

    UPDATE ra_customer_merge_headers mh
    SET (process_flag,
--	 request_id,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date) = (
                                 SELECT
                                 m.process_flag,
--                               m.request_id,
                                 sysdate,
                                 m.last_updated_by,
                                 m.last_update_login,
                                 m.program_application_id,
                                 m.program_id,
                                 sysdate
                                 FROM  ra_customer_merges m
                                 WHERE m.request_id = req_id
                                 AND   m.set_number = set_num
				 AND   m.process_flag = 'Y'
                                 AND   mh.customer_merge_header_id =
                                        m.customer_merge_header_id
                                 AND   ROWNUM = 1)
    WHERE mh.customer_merge_header_id IN (
          SELECT m.customer_merge_header_id
          FROM   ra_customer_merges m
          WHERE  m.request_id = req_id
	  AND    m.process_flag = 'Y'
          AND    m.set_number = set_num );

    --Added for debug purpose, should be always commented out.
    --read_temporary_table;

    arp_message.set_line( 'ARP_CMERGE_MASTER.done_merge_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.done_merge_rows' );
      RAISE;

END done_merge_rows;

/*===========================================================================+
 | PROCEDURE
 |              reset_merge_rows
 |
 | DESCRIPTION
 |              Reset rows for reprocessing
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  29-NOV-00  Bug 1519688: Modified procedure
 |                       based on the change of merge form:
 |                       'display request id instantly after hit merge button'
 |    Jianying Huang  07-DEC-00  Reset merge header table.
 |    Jianying Huang  07-APR-01  Bug 1725662: Rewrite some queries based on
 |                       the new added indexes for performance improvements.
 |    Jianying Huang  07-JUN-01  Should not update set_number to NULL when
 |                       update ra_customer_merges. Commented the statement
 |                       out.
 |
 +===========================================================================*/

PROCEDURE reset_merge_rows (
          req_id                      NUMBER,
          set_num                     NUMBER,
          p_process_flag              VARCHAR2
) IS

BEGIN

    --arp_message.set_line( 'ARP_CMERGE_MASTER.reset_merge_rows()+' );

--If its database problem, set back status to 'SAVED'
--Bug fix 2669389
if (p_process_flag = 'SAVED') then

arp_message.set_line('in resetmerge flag is saved');
UPDATE ra_customer_merges
    SET
--      set_number = null,
--      request_id = null,
        process_flag = 'SAVED',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE request_id = req_id
    AND   set_number = set_num
    AND   process_flag = p_process_flag;


UPDATE ra_customer_merge_headers mh
    SET (process_flag,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date) = (
                                 SELECT
                                 m.process_flag,
                                 sysdate,
                                 m.last_updated_by,
                                 m.last_update_login,
                                 m.program_application_id,
                                 m.program_id,
                                 sysdate
                                 FROM  ra_customer_merges m
                                 WHERE m.request_id = req_id
                                 AND   m.set_number = set_num
                                 AND   m.process_flag = 'SAVED'
                                 AND   mh.customer_merge_header_id =
                                        m.customer_merge_header_id
                                 AND   ROWNUM = 1)
    WHERE mh.customer_merge_header_id IN (
          SELECT m.customer_merge_header_id
          FROM   ra_customer_merges m
          WHERE  m.request_id = req_id
          AND    m.process_flag = 'SAVED'
          AND    m.set_number = set_num );
--Bug Fix 2669389
--If business validation failure set process flag to 'FAILED'

else
--Bug 1519688: should not reset request_id to NULL.
--Set process_flag = 'FAILED' indicate this is a failed merge, we need
--to pick it up next time.

    UPDATE ra_customer_merges
    SET
--      set_number = null,
--      request_id = null,
        process_flag = 'FAILED',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE request_id = req_id
    AND   set_number = set_num
    AND   process_flag = p_process_flag;

--reset merge header table.

--Bug 1725662: replace 'EXISTS' with 'IN' to use index.

    UPDATE ra_customer_merge_headers mh
    SET (process_flag,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date) = (
                                 SELECT
                                 m.process_flag,
                                 sysdate,
                                 m.last_updated_by,
                                 m.last_update_login,
                                 m.program_application_id,
                                 m.program_id,
                                 sysdate
                                 FROM  ra_customer_merges m
                                 WHERE m.request_id = req_id
                                 AND   m.set_number = set_num
				 AND   m.process_flag = 'FAILED'
                                 AND   mh.customer_merge_header_id =
                                        m.customer_merge_header_id
                                 AND   ROWNUM = 1)
    WHERE mh.customer_merge_header_id IN (
          SELECT m.customer_merge_header_id
          FROM   ra_customer_merges m
          WHERE  m.request_id = req_id
	  AND    m.process_flag = 'FAILED'
          AND    m.set_number = set_num );

end if;

    --arp_message.set_line( 'ARP_CMERGE_MASTER.reset_merge_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      --arp_message.set_error( 'ARP_CMERGE_MASTER.reset_merge_rows' );
      RAISE;

END reset_merge_rows;

/*===========================================================================+
 | PROCEDURE
 |                clear_error_merge_rows
 |
 | DESCRIPTION
 |              Remove error status from  records that failed validation
 |              so that they maybe re-submitted
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  29-NOV-00  Bug 1519688: Modified procedure
 |                       based on the change of merge form:
 |                       'display request id instantly after hit merge button'
 |    Jianying Huang  07-DEC-00  Reset merge header table.
 |    Jianying Huang  07-APR-01  Bug 1725662: Rewrite some queries based on
 |                       the new added indexes for performance improvements.
 |
 +===========================================================================*/

PROCEDURE clear_error_merge_rows (
          req_id                  NUMBER
) IS

BEGIN

    --arp_message.set_line( 'ARP_CMERGE_MASTER.clear_error_merge_rows()+' );

--Bug 1518688: should not reset request_id to NULL.
--Set process_flag = 'FAILED' indicate this is a failed merge, we need
--to pick it up next time.

--Bug 1725662: rewrite query to use new index.

    UPDATE ra_customer_merge_headers
    SET process_flag = decode(process_flag,
                              'ERROR 1', 'FAILED',
                              'ERROR 2', 'FAILED'),
--      request_id = null,
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE process_flag in ('ERROR 1', 'ERROR 2')
    AND   request_id = req_id;

    UPDATE ra_customer_merges m
    SET (process_flag,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date) = (
                                 SELECT
                                 mh.process_flag,
                                 sysdate,
                                 mh.last_updated_by,
                                 mh.last_update_login,
                                 mh.program_application_id,
                                 mh.program_id,
                                 sysdate
                                 FROM  ra_customer_merge_headers mh
                                 WHERE mh.request_id = req_id
                                 AND   mh.process_flag = 'FAILED'
                                 AND   mh.customer_merge_header_id =
                                        m.customer_merge_header_id
                                 AND   ROWNUM = 1)
    WHERE m.customer_merge_header_id IN (
          SELECT mh.customer_merge_header_id
          FROM   ra_customer_merge_headers mh
          WHERE  mh.request_id = req_id
	  AND    mh.process_flag = 'FAILED' )
    AND   process_flag in ('ERROR 1', 'ERROR 2');

    --arp_message.set_line( 'ARP_CMERGE_MASTER.clear_error_merge_rows()-' );

EXCEPTION

    WHEN OTHERS THEN
      --arp_message.set_error( 'ARP_CMERGE_MASTER.clear_error_merge_rows' );
      RAISE;

END clear_error_merge_rows;

/*===========================================================================+
 | PROCEDURE
 |              remove_request
 |
 | DESCRIPTION
 |          For handling terminated requests, remove request to the AR
 |          concurrent request table
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE remove_request (
          req_id                   NUMBER
) IS

BEGIN

    --arp_message.set_line( 'ARP_CMERGE_MASTER.remove_request()+' );

    DELETE FROM ar_conc_process_requests
    WHERE  request_id = req_id;

    --arp_message.set_line( 'ARP_CMERGE_MASTER.remove_request()-' );

EXCEPTION

    WHEN OTHERS THEN
      --arp_message.set_error( 'ARP_CMERGE_MASTER.remove_request' );
      RAISE;

END remove_request;

/*===========================================================================+
 | PROCEDURE
 |              delete_customer_alt_names
 |
 | DESCRIPTION
 |              Deletes customer alternative names.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    req_id
 |                    set_num
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE delete_customer_alt_names(
          req_id                   NUMBER,
          set_num                  NUMBER
) IS

    v_prev_duplicate_id    NUMBER := null ;
    v_duplicate_id         NUMBER;
    v_customer_id          NUMBER;
    v_duplicate_site_id    NUMBER;
    v_lock_status          NUMBER;

    CURSOR alt_names_deletion IS
        SELECT duplicate_id , customer_id , duplicate_site_id
        FROM ra_customer_merges
        WHERE request_id = req_id
        AND set_number = set_num
        AND process_flag = 'N'
        ORDER BY duplicate_id ;

BEGIN

    arp_message.set_line( 'ARP_CMERGE_MASTER.alt_name_deletion()+' );

    -- Bug 2092530: Removed condition that checked the now-obsolete
    -- 'AR_ALT_NAME_SEARCH' profile option before executing the delete.

    OPEN alt_names_deletion;
    LOOP
      FETCH alt_names_deletion INTO v_duplicate_id, v_customer_id,
            v_duplicate_site_id;
      EXIT WHEN alt_names_deletion%notfound;

      IF ( v_duplicate_id <> v_customer_id ) THEN
        IF ( ( v_prev_duplicate_id IS NULL ) OR
             ( v_prev_duplicate_id <> v_duplicate_id ) )
        THEN
          arp_cust_alt_match_pkg.lock_match (
            v_duplicate_id, NULL, v_lock_status );

          IF ( v_lock_status = 1 ) THEN
            arp_cust_alt_match_pkg.delete_match ( v_duplicate_id, NULL, NULL );
          END IF;

          v_prev_duplicate_id := v_duplicate_id ;

        END IF ;
      ELSE
        arp_cust_alt_match_pkg.lock_match (
          v_duplicate_id, v_duplicate_site_id, v_lock_status );

        IF ( v_lock_status = 1 ) THEN
          arp_cust_alt_match_pkg.delete_match (
            v_duplicate_id, v_duplicate_site_id, NULL );
        END IF;

      END IF;

    END LOOP;
    CLOSE alt_names_deletion;

    arp_message.set_line( 'ARP_CMERGE_MASTER.alt_name_deletion()-' );

EXCEPTION

    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.delete_customer_alt_names' );
      RAISE;

END delete_customer_alt_names;

/*===========================================================================+
 | PROCEDURE
 |              read_temporary_table
 |
 | DESCRIPTION
 |          Read mapping info. from temporary table. Created for debug purpose.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Jianying Huang  21-DEC-00  Created for debug purpose.
 |
 +===========================================================================*/

PROCEDURE read_temporary_table
IS

    l_sql                      VARCHAR2(1000);

BEGIN

    arp_message.set_line('read temporary table');

    l_sql :=
       'DECLARE ' ||
          'CURSOR c IS ' ||
             'SELECT type, old_id, new_id ' ||
             'FROM ' || arp_cmerge_arcus.g_table_name || ';' ||
          'l_old_id                 NUMBER; ' ||
          'l_new_id                 NUMBER; ' ||
          'l_type                   VARCHAR2(30); ' ||
       'BEGIN ' ||
          'arp_message.set_line( ''ORG CONTACT MAPPING : '' );' ||
          'OPEN c; ' ||
          'LOOP ' ||
             'FETCH c INTO l_type, l_old_id, l_new_id; ' ||
             'EXIT WHEN c%NOTFOUND; ' ||
             'arp_message.set_line( ' ||
                   '''type = '' || l_type || '', '' || ' ||
                   '''old = '' || to_char(l_old_id) || '', '' || ' ||
                   '''new = '' || to_char(l_new_id) );' ||
          'END LOOP;' ||
          'CLOSE c; ' ||
       'END; ';

    EXECUTE IMMEDIATE l_sql;

END;
/*===========================================================================+
 | PROCEDURE
 |              veto_delete
 |
 | DESCRIPTION
 |          For preventing the delete of accounts and other records off accounts
 |
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN: req_id NUMBER , set_num NUMBER,  from_customer_id NUMBER
 |                  veto_reason VARCHAR2
 |
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY -
 |                       Jyoti Pandey 02-10-2002 Created.
 |
 +===========================================================================*/
PROCEDURE veto_delete(req_id NUMBER,
                      set_num NUMBER,
                      from_customer_id  NUMBER ,
                      veto_reason  VARCHAR2,
                      part_delete  VARCHAR2 DEFAULT 'N') IS

BEGIN

   arp_message.set_line( 'ARP_CMERGE_MASTER.Veto_Delete()+' );

    /*--Unset the delete_duplicate_flag in ra_customer_merges --*/
       UPDATE ra_customer_merges m
       SET delete_duplicate_flag = 'N'
       WHERE  m.duplicate_id = from_customer_id
       AND    m.process_flag = 'N'
       AND    m.request_id = req_id
       AND    m.set_number = set_num
       AND    part_delete = 'N';  --5747129

   /*--Also unset the delete duplicate flag in merge header table --*/
      UPDATE ra_customer_merge_headers
      SET delete_duplicate_flag = 'N'
      WHERE customer_merge_header_id in
                               (select customer_merge_header_id
                                from ra_customer_merges m
                                where m.duplicate_id = from_customer_id
                                AND    m.process_flag = 'N'
                                AND    m.request_id = req_id
                                AND    m.set_number = set_num)
      AND part_delete = 'N';  --5747129

/*--Unset the status to 'I'for HZ_CUST_SITE_USES which was set to 'D'--*/
  --undo
    UPDATE HZ_CUST_SITE_USES_ALL su --SSUptake
    SET status = 'I',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        request_id =  req_id,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE EXISTS
                       ( select 'Y'
                         from hz_cust_acct_sites_ALL site,ra_customer_merges m --SSUptake
                         where site.cust_account_id = from_customer_id
			 and    m.duplicate_address_id = site.cust_acct_site_id
			 and    su.cust_acct_site_id = site.cust_acct_site_id
			 and    m.request_id = req_id
			 and    m.process_flag = 'N'
                         and    m.set_number = set_num
			 and    m.duplicate_id = from_customer_id
			 and    m.org_id  = site.org_id --SSUptake
			 and    su.org_id = site.org_id --SSUptake
		       )
    AND status = 'D'
    AND part_delete = 'N';  --5747129

 arp_message.set_line(SQL%ROWCOUNT||' '||'Row(s) updated in HZ_CUST_SITE_USES');


 /*--Unset the status to 'I'for HZ_CUST_ACCT_SITES which was set to 'D' --*/
    UPDATE  HZ_CUST_ACCT_SITES_ALL addr --SSUptake
    set status = 'I',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        request_id =  req_id,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    where addr.cust_account_id = from_customer_id
    AND  EXISTS (select 'Y' from ra_customer_merges m
                 where  m.request_id = req_id
		 and    m.process_flag = 'N'
                 and    m.set_number = set_num
		 and    m.duplicate_id = from_customer_id
		 and    m.duplicate_address_id = addr.cust_acct_site_id
		 and    m.org_id  = addr.org_id --SSUptake
                )
    AND addr.status = 'D'
    AND part_delete = 'N';  --5747129

 arp_message.set_line(SQL%ROWCOUNT||' '||'Row(s) updated in HZ_CUST_ACCT_SITES');

   /*--Unset the status to 'I' for HZ_CUST_ACCOUNTS which was set to 'D'*/
    UPDATE HZ_CUST_ACCOUNTS acct
    set status = decode(part_delete,'N','I','A'),
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        request_id =  req_id,
        program_application_id = hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    where acct.cust_account_id = from_customer_id
    and status ='D';

  arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) updated in HZ_CUST_ACCOUNTS');

  /*--Unset the status to 'I' for HZ_CUST_ACCT_RELATE cust_account_id */
    UPDATE HZ_CUST_ACCT_RELATE_ALL rel
    SET status = 'I',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        request_id =  req_id,
        program_application_id =hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE rel.cust_account_id = from_customer_id
    AND  EXISTS (select 'Y' from ra_customer_merges m
                 where  m.request_id = req_id
		 and    m.process_flag = 'N'
                 and    m.set_number = set_num
		 and    m.duplicate_id = rel.cust_account_id
		 and    m.org_id = rel.org_id --SSUptake
                )
    AND status ='D'
    AND part_delete = 'N';  --5747129

  arp_message.set_line( SQL%ROWCOUNT||' '|| 'Row(s) updated in HZ_CUST_ACCT_RELATE for cust_account_id' );

    /*--Unset the status to 'I' for HZ_CUST_ACCT_RELATE
      --related_cust_account_id*/
    UPDATE HZ_CUST_ACCT_RELATE_ALL rel2 --SSUptake
    SET status = 'I',
        last_update_date = sysdate,
        last_updated_by = hz_utility_v2pub.user_id,
        last_update_login = hz_utility_v2pub.last_update_login,
        request_id =  req_id,
        program_application_id =hz_utility_v2pub.program_application_id,
        program_id = hz_utility_v2pub.program_id,
        program_update_date = sysdate
    WHERE related_cust_account_id =  from_customer_id
    AND  EXISTS (select 'Y' from ra_customer_merges m
                 where  m.request_id = req_id
		 and    m.process_flag = 'N'
                 and    m.set_number = set_num
		 and    m.duplicate_id = rel2.related_cust_account_id
		 and    m.org_id = rel2.org_id --SSUptake
                )
    AND status ='D'
    AND part_delete = 'N';  --5747129

   arp_message.set_line( SQL%ROWCOUNT||' '|| 'Rows updated in HZ_CUST_ACCT_RELATE for related_cust_account_id' );

    /*--unset the end_date of RA_CUST_RECEIPT_METHODS at account level
     *--not required at site level as all the site uses get merged for an acct
     *--delete is prevented by delete_duplicate_flag='N'         */

     UPDATE RA_CUST_RECEIPT_METHODS yt
       set end_date = null,
           last_update_date = sysdate,
           last_updated_by = hz_utility_v2pub.user_id,
           last_update_login = hz_utility_v2pub.last_update_login,
           request_id =  req_id,
           program_application_id = hz_utility_v2pub.program_application_id,
           program_id = hz_utility_v2pub.program_id,
           program_update_date = sysdate
       WHERE customer_id = from_customer_id
       AND customer_id IN (
                SELECT m.duplicate_id
                FROM   ra_customer_merges m
                WHERE  m.process_flag = 'N'
	        AND    m.request_id = req_id
                AND    m.set_number = set_num
                AND    m.delete_duplicate_flag = 'N' )
       AND site_use_id IS NULL
       AND NOT EXISTS (
                SELECT 'active accounts exist'
                FROM   hz_cust_accounts acct
                WHERE  acct.cust_account_id = yt.customer_id
                AND    acct.status = 'A' );

   arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) updated in RA_CUST_RECEIPT_METHODS');

   /* ---Unset status to Inactive for HZ_CUSTOMER_PROFILES for both
    * ---acct and site level            */
  UPDATE hz_customer_profiles yt
  SET status = 'I',
      last_update_date = sysdate,
      last_updated_by = hz_utility_v2pub.user_id,
      last_update_login = hz_utility_v2pub.last_update_login,
      request_id =  req_id,
      program_application_id = hz_utility_v2pub.program_application_id,
      program_id = hz_utility_v2pub.program_id,
      program_update_date = sysdate
 WHERE yt.cust_account_id = from_customer_id
 AND status = 'D'
 AND part_delete = 'N';  --5747129

  UPDATE hz_customer_profiles yt       --5634398
     SET status = 'A',
         last_update_date = sysdate,
         last_updated_by = arp_standard.profile.user_id,
         last_update_login = arp_standard.profile.last_update_login,
         request_id =  req_id,
         program_application_id = arp_standard.profile.program_application_id,
         program_id = arp_standard.profile.program_id,
         program_update_date = sysdate
     WHERE part_delete = 'Y'
     AND status = 'D'
     AND yt.cust_account_id = from_customer_id
     AND site_use_id is NULL ;


  arp_message.set_line(SQL%ROWCOUNT||' '|| 'Row(s) updated in HZ_CUSTOMER_PROFILES');


  /*  ---Profile amts in ar_cpa are not getting Inactivated
      ---so delete duplicate flag in merge table can handle that */

 ---Updating the column MERGE_FAIL_MSG with veto reason
  UPDATE RA_CUSTOMER_MERGE_HEADERS
  SET MERGE_FAIL_MSG= veto_reason
  WHERE customer_merge_header_id in
                               (select customer_merge_header_id
                                from ra_customer_merges m
                                where m.duplicate_id = from_customer_id
                                AND    m.process_flag = 'N'
                                AND    m.request_id = req_id
                                AND    m.set_number = set_num);

 arp_message.set_line(  SQL%ROWCOUNT || ' '|| 'Rows updated in RA_CUSTOMER_MERGE_HEADERS with veto reason :' ||' '|| veto_reason );

 arp_message.set_line( 'ARP_CMERGE_MASTER.Veto_Delete()-' );

END  veto_delete;

--4230396
PROCEDURE raise_events(p_req_id NUMBER) IS
    l_key        VARCHAR2(240);
    l_list       WF_PARAMETER_LIST_T;
    l_header_id NUMBER;
    CURSOR merges IS
        SELECT customer_merge_header_id
        FROM ra_customer_merge_headers
        WHERE request_id = p_req_id
        AND   process_flag = 'Y';
BEGIN
    arp_message.set_line( 'ARP_CMERGE_MASTER.raise_events() +');

    OPEN merges;
    LOOP
    	FETCH merges into l_header_id;
	EXIT WHEN merges%NOTFOUND;
  	l_key := HZ_EVENT_PKG.item_key('oracle.apps.ar.hz.CustAccount.merge');
		-- initialization of object variables
  	l_list := WF_PARAMETER_LIST_T();
	wf_event.addParameterToList(p_name  => 'customer_merge_header_id',
                              p_value => l_header_id,
                              p_parameterlist => l_list);
       wf_event.addParameterToList(p_name  => 'Q_CORRELATION_ID',
                                   p_value => 'oracle.apps.ar.hz.CustAccount.merge',
                                   p_parameterlist => l_list);
		-- Raise Event
	HZ_EVENT_PKG.raise_event(
            p_event_name        => 'oracle.apps.ar.hz.CustAccount.merge',
            p_event_key         => l_key,
            p_parameters        => l_list );
   	l_list.DELETE;
    END LOOP;
    CLOSE merges;
    arp_message.set_line( 'ARP_CMERGE_MASTER.raise_events() -');
EXCEPTION
    WHEN OTHERS THEN
      arp_message.set_error( 'ARP_CMERGE_MASTER.raise_events' );
      RAISE;
END raise_events;

END ARP_CMERGE_MASTER;

/
