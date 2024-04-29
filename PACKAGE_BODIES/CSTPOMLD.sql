--------------------------------------------------------
--  DDL for Package Body CSTPOMLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPOMLD" AS
/* $Header: CSTOMLDB.pls 120.2 2006/06/09 05:10:57 srayadur noship $ */

-- PROCEDURE
--  load_om_margin_data      Loads Margin data for OM
--
procedure load_om_margin_data(
I_FROM_DATE     IN      VARCHAR2,
I_TO_DATE       IN      VARCHAR2,
I_OVERLAP_DAYS  IN      NUMBER,
I_LOAD_OPTION   IN      NUMBER,
I_USER_ID       IN      NUMBER,
I_TRACE_MODE    IN      VARCHAR2
) IS
  l_program_id         NUMBER;
  l_program_appl_id    NUMBER;
  l_request_id         NUMBER;
  l_stmt_id            NUMBER;
  l_build_id           NUMBER;
  l_first_build        NUMBER;
  l_from_date          DATE;
  l_to_date            DATE;
  l_last_load_date     DATE;
  errmsg               VARCHAR2(2240);
  l_le_id              NUMBER;
  l_ou_id              NUMBER;
  l_le_name            VARCHAR2(240);
  l_build_name         VARCHAR2(255);
  l_build_descr        VARCHAR2(255);
  app_col_name         varchar2(50);
  app_col_name1         varchar2(50);
  sql_stmt             varchar2(5000);
  OM_NOT_ACTIVE_ERROR    EXCEPTION;

/*---------------------------------------------------------------+
 |  Get all Legal Entities
 +---------------------------------------------------------------*/

  CURSOR all_le is
         SELECT distinct organization_id,name
         FROM   hr_legal_entities;

/*---------------------------------------------------------------+
 |  Get all Operating Units for a given Legal Entity
 +---------------------------------------------------------------*/

  CURSOR all_ous(c_le_id NUMBER) is
         SELECT distinct hoi.organization_id
         FROM   hr_organization_information hoi
         WHERE  hoi.org_information2 = to_char(c_le_id)
         AND hoi.org_information_context = 'Operating Unit Information';

BEGIN
  -- Initialize local variables

  l_stmt_id      := 0;
  l_first_build  := 0;
  app_col_name := NULL;

       begin

        select application_column_name
        into app_col_name
        from bis_flex_mappings_v where
        id_flex_code = 'RA_ADDRESSES' and level_id =
        ( select dimension_level_id from bisbv_dimension_levels where
        dimension_level_short_name = 'REGION');

        exception
                when others then
                        app_col_name := NULL;
        end;

      OPEN all_le;

 LOOP

--   DBMS_OUTPUT.ENABLE(100000);
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('ENTER LEGAL ENTITY LOOP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');

    FETCH all_le into l_le_id,l_le_name;

    EXIT WHEN all_le%NOTFOUND;



/*  Setting values for "from date", "to date", and "overlap days" */


--  DBMS_OUTPUT.PUT_LINE('.*******************************************');
--  DBMS_OUTPUT.PUT_LINE('Get last update date');
--  DBMS_OUTPUT.PUT_LINE('.*******************************************');


    select MAX(last_update_date), NVL(MAX(0),1), NVL(MAX(build_id),0)
    into   l_last_load_date, l_first_build, l_build_id
    from CST_BIS_MARGIN_BUILD
    where legal_entity_id = l_le_id;


--  DBMS_OUTPUT.PUT_LINE('l_last_load_date = ' || to_char(l_last_load_date));
--  DBMS_OUTPUT.PUT_LINE('l_first_build = ' || to_char(l_first_build));

   l_from_date := fnd_date.canonical_to_date(i_from_date);
   l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);


    if (l_first_build = 1) then

       select NVL(fnd_date.canonical_to_date(i_from_date),to_date('1900/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')),
              NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE)
       into   l_from_date,
              l_to_date
       from   dual;

    elsif (i_from_date is NULL) then
            if (i_load_option = 1) then
               l_from_date := to_date('1900/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS');
               l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);
            else
               l_from_date := l_last_load_date - i_overlap_days;
               l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);
            end if;
   end if;


--  DBMS_OUTPUT.PUT_LINE('l_le_name = ' || l_le_name);
--  DBMS_OUTPUT.PUT_LINE('l_from_date = ' || to_char(l_from_date));
--  DBMS_OUTPUT.PUT_LINE('l_to_date = ' || to_char(l_to_date));


/*---------------------------------------------------------------+
 | Delete from CST_BIS_MARGIN_SUMMARY for the given Legal Entity
 +---------------------------------------------------------------*/

  BEGIN

--  DBMS_OUTPUT.PUT_LINE('.*******************************************');
--  DBMS_OUTPUT.PUT_LINE('DELETE from TEMP.');
--  DBMS_OUTPUT.PUT_LINE('.*******************************************');

      DELETE from CST_BIS_MARGIN_SUMMARY
      WHERE legal_entity_id = l_le_id
      and   gl_date between l_from_date and l_to_date;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_program_id      := NULL;
         l_request_id      := NULL;
         l_program_appl_id := NULL;
      WHEN OTHERS THEN
         raise;
 END;



/*---------------------------------------------------------------+
 | Insert into CST_BIS_MARGIN_BUILD, if required
 +---------------------------------------------------------------*/

   BEGIN

      if l_first_build = 1 THEN
         SELECT cst_margin_build_s.nextval
         INTO   l_build_id
         FROM   sys.dual;

         l_build_name := to_char(l_build_id);
         l_build_descr := l_le_name;
      END IF;


   EXCEPTION
       WHEN NO_DATA_FOUND THEN
          NULL;
       WHEN OTHERS THEN
         raise;
   END;


--  DBMS_OUTPUT.PUT_LINE('.*******************************************');
--  DBMS_OUTPUT.PUT_LINE('INSERT into BUILD.');
--  DBMS_OUTPUT.PUT_LINE('.*******************************************');

  if l_first_build = 1 THEN

   INSERT INTO CST_BIS_MARGIN_BUILD (
          build_id,
          build_name,
          build_description,
	  legal_entity_id,
          legal_entity_name,
          header_id,
          org_id,
          organization_id,
          from_date,
          to_date,
          cost_type_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date
          )
    SELECT l_build_id,
           l_build_name,
           l_build_descr,
     	   l_le_id,
           l_le_name,
           NULL,
           NULL,
           l_le_id,
           l_from_date,
           l_to_date,
           NULL,
           SYSDATE,
           i_user_id,
           SYSDATE,
           i_user_id,
           i_user_id,
           l_request_id,
           l_program_appl_id,
           l_program_id,
           SYSDATE
    FROM
           sys.dual;

else

    UPDATE CST_BIS_MARGIN_BUILD
    SET    FROM_DATE = l_from_date,
           TO_DATE = l_to_date,
           LAST_UPDATE_DATE = SYSDATE
    WHERE  legal_entity_id = l_le_id;
END IF;

/* Do for each Operating unit for the above legal entity */

     OPEN all_ous(l_le_id);

 LOOP

--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('ENTER OPERATING UNIT LOOP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');

    FETCH all_ous into l_ou_id;

    EXIT WHEN all_ous%NOTFOUND;


/*---------------------------------------------------------------+
 | Insert into CST_BIS_MARGIN_SUMMARY for all the invoices booked
 | against regular orders
 +---------------------------------------------------------------*/

    l_stmt_id := 30;

--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('INSERT into TEMP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
           ,order_number
           ,header_id
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,inventory_item_id
           ,organization_id
           ,line_id
           ,line_type_code
           ,line_number
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           )
    SELECT
	   'INV-'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'INVOICE',
           '1',
           '1',
           rctl.interface_line_context,
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
	   l_le_id,
           NVL(l_ou_id, sl_parent.org_id),
           sh.order_type_id,
           sh.sold_to_org_id,
           sh.salesrep_id,
           sh.sales_channel_code,
           sl_parent.inventory_item_id,
           sl_parent.ship_from_org_id,
           sl_parent.line_id,
           sl_parent.line_number,
           sl_parent.item_type_code,
	   decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
           sl_child.inventory_item_id,
           sl_child.ship_from_org_id,
           sl_child.line_id,
           sl_child.line_category_code,
           sl_child.line_number,
           sl_child.ship_to_org_id,
           sh.invoice_to_org_id,
           rct.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           inv_convert.inv_um_convert (sl_child.inventory_item_id, 7,
                                       rctl.quantity_invoiced, rctl.uom_code,
                                       msi.primary_uom_code, TO_CHAR(NULL),
                                       TO_CHAR(NULL)),
           decode(rctl.inventory_item_id,
                  sl_parent.inventory_item_id,
                  inv_convert.inv_um_convert (sl_child.inventory_item_id, 7,
                                              rctl.quantity_invoiced,
                                              rctl.uom_code,
                                              msi.primary_uom_code,
                                              TO_CHAR(NULL),
                                              TO_CHAR(NULL))
                  * rctlgd.percent / 100,
                  0),
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all rctl,
           oe_order_headers_all sh,
           oe_order_lines_all sl_parent,
           oe_order_lines_all sl_child,
           mtl_system_items msi,
           ra_customer_trx_all rct,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rct.org_id = l_ou_id
           and   rctlgd.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   rctl.interface_line_context = 'ORDER ENTRY'
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between cr.from_date and cr.to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   msi.inventory_item_id = sl_child.inventory_item_id
           and   sh.org_id = l_ou_id
           and   sl_parent.org_id = l_ou_id
           and   sl_child.org_id = l_ou_id
           and   msi.organization_id = sl_child.ship_from_org_id
           and   sl_child.line_id = DECODE(INTERFACE_LINE_CONTEXT,'ORDER ENTRY',
		 to_number(rctl.interface_line_attribute6), -99999)
	   AND   SH.ORDER_NUMBER = DECODE(INTERFACE_LINE_CONTEXT,'ORDER ENTRY',
		 TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1), -99999)
           and   sl_child.line_category_code = 'ORDER'
           and   sl_parent.line_category_code = 'ORDER'
           and   sl_parent.line_id = nvl(sl_child.top_model_line_id, sl_child.line_id)
           and   sh.header_id = sl_child.header_id
           and   sh.header_id = sl_parent.header_id
	   /* INVCONV  umoogala  17-oct-2004 */
	   and   mp.organization_id = sl_child.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.

/*---------------------------------------------------------------+
 | Insert into CST_BIS_MARGIN_SUMMARY for IC-AR
 +---------------------------------------------------------------*/

    l_stmt_id := 35;

--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('INSERT into TEMP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');


    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
           ,order_number
           ,header_id
           ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,inventory_item_id
           ,organization_id
           ,line_id
           ,line_type_code
           ,line_number
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           )
    SELECT
	   'ICAR-'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'IC-AR',
           '7',
           '1',
           rctl.interface_line_context,
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
           l_le_id,
           NVL(l_ou_id, sl_parent.org_id),
           sh.order_type_id,
           sh.sold_to_org_id,
           sh.salesrep_id,
           sh.sales_channel_code,
           sl_parent.inventory_item_id,
           sl_parent.ship_from_org_id,
           sl_parent.line_id,
           sl_parent.line_number,
           sl_parent.item_type_code,
	   decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
           sl_child.inventory_item_id,
           sl_child.ship_from_org_id,
           sl_child.line_id,
           sl_child.line_category_code,
           sl_child.line_number,
           sl_child.ship_to_org_id,
           sh.invoice_to_org_id,
           rct.customer_trx_id,
           rctl.customer_trx_line_id,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           inv_convert.inv_um_convert (sl_child.inventory_item_id, 7,
                                       rctl.quantity_invoiced, rctl.uom_code,
                                       msi.primary_uom_code, TO_CHAR(NULL),
                                       TO_CHAR(NULL)),
           decode(rctl.inventory_item_id,
                  sl_parent.inventory_item_id,
                  inv_convert.inv_um_convert (sl_child.inventory_item_id, 7,
                                              rctl.quantity_invoiced,
                                              rctl.uom_code,
                                              msi.primary_uom_code,
                                              TO_CHAR(NULL),
                                              TO_CHAR(NULL))
                  * rctlgd.percent / 100,
                  0),
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all rctl,
           oe_order_headers_all sh,
           oe_order_lines_all sl_parent,
           oe_order_lines_all sl_child,
           mtl_system_items msi,
           ra_customer_trx_all rct,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rct.org_id = l_ou_id
           and   rctlgd.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.batch_source_id = 8
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   rctl.interface_line_context = 'INTERCOMPANY'
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between cr.from_date and cr.to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   msi.inventory_item_id = sl_child.inventory_item_id
           and   msi.organization_id = sl_child.ship_from_org_id
           and   sl_child.line_id = DECODE(INTERFACE_LINE_CONTEXT, 'INTERCOMPANY',
		 to_number(rctl.interface_line_attribute6), -99999)
	   AND   SH.ORDER_NUMBER = DECODE(INTERFACE_LINE_CONTEXT, 'INTERCOMPANY',
	 	 TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1), -99999)
	   and   sl_child.line_category_code = 'ORDER'
	     AND   ( sl_child.source_document_type_id IS NULL
		     OR sl_child.source_document_type_id <> 10  )
           and   sl_parent.line_category_code = 'ORDER'
           and   sl_parent.line_id = nvl(sl_child.top_model_line_id,sl_child.line_id)
           and   sh.header_id = sl_child.header_id
           and   sh.header_id = sl_parent.header_id
	   /* INVCONV  umoogala  17-oct-2004 */
	   and   mp.organization_id = sl_child.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.


/*---------------------------------------------------------------+
 | Insert in temp table for all the RMA Invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 40;

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
	   ,organization_id
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,order_number
	   ,rma_number
	   ,header_id
	   ,rma_header_id
	   ,inventory_item_id
	   ,rma_inventory_item_id
	   ,line_id
	   ,rma_line_id
	   ,line_number
	   ,rma_line_number
	   ,rma_ship_to_site_use_id
	   ,line_type_code
           ,rma_line_type_code
           ,link_to_line_id
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           )
    SELECT
	   'RMA-INV_'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'RMA-INVOICE',
           '3',
           '2',
           rctl.interface_line_context,
           rma_line.rowid,
 	   l_le_id,
           NVL(l_ou_id, rma.org_id),
           rma.order_type_id,
           rma.sold_to_org_id,
           rma.salesrep_id,
           rma.sales_channel_code,
           rma_line.inventory_item_id,
           rma_line.ship_from_org_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.item_type_code,
	   decode(rma_line.ato_line_id, NULL, 'N', 'Y'),
	   rma.ship_from_org_id,
           rma_line.ship_to_org_id,
           rma.invoice_to_org_id,
           rct.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           rma.order_number,
           rma.order_number,
           rma.header_id,
           rma.header_id,
           rctl.inventory_item_id,
           rctl.inventory_item_id,
           rma_line.line_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           (-1) * rma_line.SHIPPED_QUANTITY,
           (-1) * rma_line.SHIPPED_QUANTITY * rctlgd.percent / 100,
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all rctl,
           oe_order_headers_all rma,
           oe_order_lines_all rma_line,
           --hr_organization_information hoi,
           ra_customer_trx_all rct,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rct.org_id = l_ou_id
           and   rctlgd.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   rctl.interface_line_context = 'ORDER ENTRY'
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between cr.from_date and cr.to_date
           and   rma.org_id = l_ou_id
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   rma_line.org_id = l_ou_id
           and   rma_line.line_id = DECODE(INTERFACE_LINE_CONTEXT, 'ORDER ENTRY',
		TO_NUMBER(rctl.interface_line_attribute6), -99999)
	   AND   rma.ORDER_NUMBER = DECODE(INTERFACE_LINE_CONTEXT, 'ORDER ENTRY',
		 TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1), -99999)
           and   rma_line.line_category_code = 'RETURN'
	     and   rma.header_id = rma_line.header_id
	     /* INVCONV  umoogala  17-oct-2004 */
	     and   mp.organization_id = rma_line.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.
	   --and ( hoi.org_information_context || '')  ='Accounting Information'
           --and hoi.organization_id = rma_line.SHIP_FROM_ORG_ID
           --and hoi.org_information3 = NVL(l_ou_id,NVL(rct.org_id, -999));

/*---------------------------------------------------------------+
 | Insert RMA invoices for non-invenory items
 +---------------------------------------------------------------*/

     l_stmt_id := 45;
/*
    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,rma_number
           ,rma_header_id
           ,rma_inventory_item_id
           ,rma_line_id
           ,rma_line_number
           ,rma_ship_to_site_use_id
           ,rma_line_type_code
           ,link_to_line_id
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           )
    SELECT
	   'RMA-INV-'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'RMA-INVOICE',
           '3',
           '2',
           rctl.interface_line_context,
           rma_line.rowid,
	   l_le_id,
           NVL(l_ou_id, rma.org_id),
           rma.order_type_id,
           rma.sold_to_org_id,
           rma.salesrep_id,
           rma.sales_channel_code,
           rma_line.inventory_item_id,
           rma_line.ship_from_org_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.item_type_code,
	   decode(rma_line.ato_line_id, NULL, 'N', 'Y'),
           rma_line.ship_to_org_id,
           rma.invoice_to_org_id,
           rct.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           rma.order_number,
           rma.header_id,
           rctl.inventory_item_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           (-1)*inv_convert.inv_um_convert (rma_line.inventory_item_id, 7,
                                            rma_line.invoiced_quantity,
                                            rctl.uom_code,
                                            msi.primary_uom_code, TO_CHAR(NULL),
                                            TO_CHAR(NULL)),
           (-1)*inv_convert.inv_um_convert (rma_line.inventory_item_id, 7,
                                            rma_line.invoiced_quantity,
                                            rctl.uom_code, msi.primary_uom_code,
                                            TO_CHAR(NULL), TO_CHAR(NULL))
            * rctlgd.percent / 100,
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all rctl,
           oe_order_headers_all rma,
           oe_order_lines_all rma_line,
           mtl_system_items msi,
-- new changes for intercompany invoicing
           org_organization_definitions ood,
           ra_customer_trx_all rct
    WHERE
                 cr.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rct.org_id = l_ou_id
           and   rctlgd.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between cr.from_date and cr.to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   rctl.interface_line_context = 'ORDER ENTRY'
           and   rma.org_id = l_ou_id
           and   msi.inventory_item_id = rma_line.inventory_item_id
           and   msi.organization_id = rma_line.ship_from_org_id
           and   msi.inventory_item_flag = 'N'
           and   rma_line.org_id = l_ou_id
           and   rma_line.line_id = DECODE(INTERFACE_LINE_CONTEXT, 'ORDER ENTRY',
		TO_NUMBER(rctl.interface_line_attribute6), -99999)
	   AND   rma.ORDER_NUMBER = DECODE(INTERFACE_LINE_CONTEXT, 'ORDER ENTRY',
	   	 TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1), -99999)
           and   rma_line.line_category_code = 'RETURN'
-- and rma_line.s5+0 in (5,9)
-- work flow issue to be resolved with OM team
           and   rma.header_id = rma_line.header_id
-- new changes for intercompany invoicing
           and   ood.organization_id = msi.organization_id
           and   ood.operating_unit = NVL(l_ou_id,NVL(rct.org_id, -999));
*/

/*---------------------------------------------------------------+
 | Update all the rows with parent_line_id if link_to_line_id is
 | not null
 +---------------------------------------------------------------*/

     l_stmt_id := 50;

     UPDATE CST_BIS_MARGIN_SUMMARY  rma
     SET   (
           parent_rowid ,
           order_number,
           header_id,
           order_type_id,
           customer_id ,
           primary_salesrep_id,
           sales_channel_code,
           parent_inventory_item_id,
           parent_organization_id,
           parent_line_id,
           parent_line_number,
           parent_ato_flag,
           parent_item_type_code,
           inventory_item_id,
           organization_id,
           line_id,
           line_number,
           line_type_code,
           ship_to_site_use_id,
           invoice_to_site_use_id,
           invoice_quantity,
           return_reference_type_code,
           return_reference_id) =

           (SELECT

                 sl_parent.rowid,
                 sh.order_number,
                 sh.header_id ,
                 sh.order_type_id,
                 sh.sold_to_org_id,
                 sh.salesrep_id,
                 sh.sales_channel_code,
                 sl_parent.inventory_item_id,
                 sl_parent.ship_from_org_id,
                 sl_parent.line_id,
                 sl_parent.line_number,
	         decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
                 sl_parent.item_type_code,
                 sl_child.inventory_item_id,
                 sl_child.ship_from_org_id,
                 sl_child.line_id,
                 sl_child.line_number,
                 sl_child.line_category_code,
                 sl_child.ship_to_org_id,
                 sh.invoice_to_org_id,
                 decode (rma.rma_inventory_item_id, sl_parent.inventory_item_id,
                                                         rma.invoice_quantity, 0),
                 sl_child.return_context,
                 sl_child.reference_line_id
           FROM
                 oe_order_lines_all sl_parent,
                 oe_order_lines_all sl_child,
                 oe_order_headers_all sh
           WHERE
                       sl_parent.org_id = l_ou_id
                 and   sl_child.org_id = l_ou_id
                 and   sl_child.line_category_code = 'ORDER'
                 and   sl_parent.line_category_code = 'ORDER'
                 and   sl_parent.line_id = nvl(sl_child.top_model_line_id,
                                               sl_child.line_id)
                 and   sl_parent.line_id = rma.link_to_line_id
                 and   sl_child.line_id = rma.link_to_line_id
                 and   sh.org_id = l_ou_id
                 and   sh.header_id = sl_child.header_id
                 and   sh.header_id = sl_parent.header_id
           )
     WHERE
               rma.link_to_line_id is not null
           and rma.row_type = 3
           and rma.source='RMA-INVOICE'
	   and rma.gl_date between l_from_date and l_to_date
           and rma.build_id = l_build_id;


/*---------------------------------------------------------------+
 | Insert in temp table for all the ICAR - RMA Invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 60;

/*--------------------------------------------------------------+
| Date: 09-Mar-2004
| Developer: ADWAJAN
| Comments: Code for collecting AR for IC RMA transactions
+-------------------------------------------------------------*/

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk
           ,build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,order_number
           ,rma_number
           ,header_id
           ,rma_header_id
           ,inventory_item_id
           ,rma_inventory_item_id
           ,line_id
           ,rma_line_id
           ,line_number
           ,rma_line_number
           ,rma_ship_to_site_use_id
           ,line_type_code
           ,rma_line_type_code
           ,link_to_line_id
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           )
    SELECT
	   'RMA-ICAR_'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'RMA-ICAR',
           '7',
           '2',
           rctl.interface_line_context,
           rma_line.rowid,
 	   l_le_id,
           NVL(l_ou_id, rma.org_id),
           rma.order_type_id,
           rma.sold_to_org_id,
           rma.salesrep_id,
           rma.sales_channel_code,
           rma_line.inventory_item_id,
           rma_line.ship_from_org_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.item_type_code,
	   decode(rma_line.ato_line_id, NULL, 'N', 'Y'),
           rma_line.ship_to_org_id,
           rma.invoice_to_org_id,
           rct.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           rma.order_number,
           rma.order_number,
           rma.header_id,
           rma.header_id,
	   rctl.inventory_item_id,
           rctl.inventory_item_id,
           rma_line.line_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           (-1) * rma_line.SHIPPED_QUANTITY,
           (-1) * rma_line.SHIPPED_QUANTITY * rctlgd.percent / 100,
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all rctl,
           oe_order_headers_all rma,
           oe_order_lines_all rma_line,
           --hr_organization_information hoi,
           ra_customer_trx_all rct,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rct.org_id = l_ou_id
           and   rctlgd.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.batch_source_id = 8
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   rctl.interface_line_context = 'INTERCOMPANY'
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between cr.from_date and cr.to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   rma_line.line_id = DECODE(INTERFACE_LINE_CONTEXT, 'INTERCOMPANY',
			TO_NUMBER(rctl.interface_line_attribute6), -99999)
	   and  rma.ORDER_NUMBER = DECODE(INTERFACE_LINE_CONTEXT, 'INTERCOMPANY',
		 	TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1), -99999)
	   and   (rma_line.source_document_type_id IS NULL
	   		OR rma_line.source_document_type_id <> 10)
           and   rma_line.line_category_code = 'RETURN'
	     and   rma.header_id = rma_line.header_id
	     /* INVCONV  umoogala  17-oct-2004 */
	     and   mp.organization_id = rma_line.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.


/*---------------------------------------------------------------+
 | Insert in temp table all data for CR-memos not related to any
 | RMA but related to an invoice selected earlier
 +---------------------------------------------------------------*/

    l_stmt_id := 80;

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,invoice_source
           ,parent_rowid
           ,order_number
           ,header_id
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,inventory_item_id
           ,organization_id
           ,line_id
           ,line_type_code
           ,line_number
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,customer_trx_id
           ,customer_trx_line_id
           ,original_gl_date
           ,gl_date
           ,invoice_line_quantity
           ,invoice_quantity
           ,invoiced_amount
           ,sales_account
           ,cr_trx_id
           ,cr_trx_line_id
           )
    SELECT
	   'CR_INV-'||rctlgd.CUST_TRX_LINE_GL_DIST_ID,
           l_build_id,
           'CR-INVOICE',
           '5',
           '3',
           rctl.interface_line_context,
           temp.parent_rowid,
           temp.order_number,
           temp.header_id,
	   l_le_id,
           NVL(l_ou_id, rct.org_id),
           temp.order_type_id,
           temp.customer_id,
           temp.primary_salesrep_id,
           temp.sales_channel_code,
           temp.parent_inventory_item_id,
           temp.parent_organization_id,
           temp.parent_line_id,
           temp.parent_line_number,
           temp.parent_item_type_code,
           temp.parent_ato_flag,
           temp.inventory_item_id,
           temp.organization_id,
           temp.line_id,
           temp.line_type_code,
           temp.line_number,
           temp.ship_to_site_use_id,
           temp.invoice_to_site_use_id,
           temp.customer_trx_id,
           temp.customer_trx_line_id,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           0,
           0,
           rctlgd.acctd_amount,
           rctlgd.code_combination_id,
           rct.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID
    FROM
           CST_BIS_MARGIN_SUMMARY temp,
           ra_customer_trx_all rct,
           ra_customer_trx_lines_all rctl,
           ra_cust_trx_line_gl_dist_all rctlgd
    WHERE
                 temp.build_id = l_build_id
           and   rctl.org_id = l_ou_id
           and   rctl.line_type = 'LINE'
           and   rct.org_id = l_ou_id
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   EXISTS ( select '1' from ra_cust_trx_types rctt
                          where rct.cust_trx_type_id = rctt.cust_trx_type_id
                          and rctt.type = 'CM')
           and   rctlgd.org_id = l_ou_id
           and   rctlgd.gl_date is not NULL
	   -- fix for bug 2609688
	   and   rctlgd.gl_date BETWEEN l_from_date AND l_to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   rctl.LINK_TO_CUST_TRX_LINE_ID  is null
           and   rctl.previous_customer_trx_line_id = temp.CUSTOMER_TRX_LINE_ID
           and   rctl.previous_customer_trx_id = temp.customer_trx_id
	   /* new conditions added to improve performance bug 2554225 */
           and   temp.SOURCE = 'INVOICE'
	   /* added join to org_id bug 2554225 */
           and   temp.org_id = l_ou_id
           /* bug 2397230 */
           and   temp.rowid in (select max(rowid) from CST_BIS_MARGIN_SUMMARY t1
                                    where  t1.build_id = temp.build_id
                                      and  t1.source   = 'INVOICE'
                                      /* added join to org_id bug 2554225 */
                                      and t1.org_id = l_ou_id
                                      and t1.header_id = temp.header_id
                                      and t1.line_id = temp.line_id
				      and t1.CUSTOMER_TRX_LINE_ID =
					  temp.CUSTOMER_TRX_LINE_ID
                                    group  by t1.order_number ,
					   t1.line_number,
					   t1.CUSTOMER_TRX_LINE_ID )
           and   not exists
                (select 'x'
                         from CST_BIS_MARGIN_SUMMARY t2,
                              oe_order_lines_all oel
                  where  t2.source   =    'RMA-INVOICE'
                    and  t2.build_id =     temp.build_id
		    /* added join to org_id bug 2554225 */
                    and  t2.org_id = l_ou_id
                    and  temp.header_id = oel.reference_header_id
                    and  temp.line_id = oel.reference_line_id
                    and  oel.header_id = t2.rma_header_id
                    and oel.line_id   = t2.rma_line_id
                  );

/*---------------------------------------------------------------+
 | Insert in temp table all data for Cost of Goods Sold for
 | regular invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 90;

/*--------------------------------------------------------------+
| Date: 03-Nov-2003
| Developer: ADWAJAN
| Comments: Additional condition in the where clause to
|           calculate COGS for the logical txns in the
|	    Drop Ship scenario - 11.5.10 Impact Analysis
+-------------------------------------------------------------*/

/*
Date	    Author		Comments
05/08/2006  Suhasini	  To enable deferred COGS accounting, 2 new accounting_line_types
			  are being introduced in MTA. As this collection program collects
			  only recognized revenue for COGS and RMA the COGS recognized should
			  also be in proportion to trhe revenue realized. This is attained by
			  the valuations with accounting_line_type as 35, 36. This collection
			  would now collect for accounting_line_type = 2 (COGS valuation in the
			  absence of deferred COGS accounting at customer) and accounting_line_type
			  = 35 (Deferred COGS recognized, in the presence of deferred COGS acc)
*/
    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,parent_rowid
           ,order_number
           ,header_id
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,inventory_item_id
           ,organization_id
           ,line_id
           ,line_type_code
           ,line_number
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,original_gl_date
           ,gl_date
           ,order_line_quantity
           ,ship_quantity
           ,cogs_amount
           ,cogs_account
           )
    SELECT
	   'COGS-'||mta.TRANSACTION_ID||'-'||mta.REFERENCE_ACCOUNT||'-'||mta.COST_ELEMENT_ID||'-'||mta.GL_SL_LINK_ID,
           l_build_id,
           'COGS',
           '2',
           '1',
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
	   l_le_id,
           ood.operating_unit, --NVL(l_ou_id, sh.org_id),
           sh.order_type_id,
           sh.sold_to_org_id,
           sh.salesrep_id,
           sh.sales_channel_code,
           sl_parent.inventory_item_id,
           sl_parent.ship_from_org_id,
           sl_parent.line_id,
           sl_parent.line_number,
           sl_parent.item_type_code,
	   decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
           sl_child.inventory_item_id,
           -- sl_child.ship_from_org_id,
           mmt.organization_id,
           mmt.trx_source_line_id,
           sl_child.line_category_code,
           sl_child.line_number,
           sl_child.ship_to_org_id,
           sh.invoice_to_org_id,
           mta.transaction_date,
           mta.transaction_date,
           sl_child.shipped_quantity,
           decode(decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
                  'N',decode(mmt.inventory_item_id, sl_parent.inventory_item_id,
                           --  (-1) * decode(nvl(mta.cost_element_id,-1), 1,
			    decode(nvl(mta.cost_element_id,-1), 1,
				mmt.primary_quantity,-1,mmt.primary_quantity,0),
			0),
-- may need to decode MODEL and KIT, to be confirmed
                  'Y',decode(sl_parent.item_type_code, 'MODEL',
                          --  (-1) * decode(nvl(mta.cost_element_id,-1),1,
			   decode(nvl(mta.cost_element_id,-1),1,
				mmt.primary_quantity,-1,mmt.primary_quantity,0),
                             decode(mmt.inventory_item_id,
                                    sl_parent.inventory_item_id,
                               --   (-1) * decode(nvl(mta.cost_element_id,-1),1,
			       decode(nvl(mta.cost_element_id,-1),1,
					mmt.primary_quantity,-1,mmt.primary_quantity,0),
                                    0)),
                  decode(mmt.inventory_item_id, sl_parent.inventory_item_id,
                     --    (-1) * decode(nvl(mta.cost_element_id,-1),1,
		      decode(nvl(mta.cost_element_id,-1),1,
			mmt.primary_quantity,-1,mmt.primary_quantity,0),
			0)
                  ),
           mta.base_transaction_value,
           mta.reference_account
    FROM
           oe_order_headers_all sh,
           oe_order_lines_all sl_parent,
           oe_order_lines_all sl_child,
           mtl_material_transactions  mmt,
           mtl_transaction_accounts   mta,
-- new changes for intercompany invoicing
           org_organization_definitions ood,
           CST_BIS_MARGIN_BUILD cr,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   (
			(mmt.transaction_source_type_id = 2        -- Regular Sales Orders
			and   mta.transaction_source_type_id = 2)
			or
			(mmt.transaction_source_type_id = 13       -- Logical Intercompany Sales Issue
			and mmt.transaction_action_id = 9
			and   mta.transaction_source_type_id = 13)
		)
           and   mmt.transaction_id = mta.transaction_id
           and   mta.accounting_line_type in (2,35)  -- Added in R12. To collect COGS when recognized.
--           and   sl_parent.org_id = l_ou_id
--           and   sl_child.org_id = l_ou_id
           and   sl_child.line_id = mmt.trx_source_line_id
           and   sl_child.line_category_code = 'ORDER'
           and   sl_parent.line_category_code = 'ORDER'
           and   sl_parent.line_id = nvl(sl_child.top_model_line_id,
                                         sl_child.line_id)
--           and   sh.org_id = l_ou_id
           and   sh.header_id = sl_child.header_id
           and   mta.transaction_date between  cr.from_date and cr.to_date
-- new changes for intercompany invoicing
           and   ood.organization_id = mmt.organization_id
           and   ood.operating_unit = l_ou_id
	   /* INVCONV  umoogala  17-oct-2004 */
	   and   mp.organization_id = sl_child.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.


/*---------------------------------------------------------------+
 | Insert in temp table all data for IC-AP for
 | regular invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 95;

/*--------------------------------------------------------------+
| Date: 28-Dec-2003
| Developer: ADWAJAN
| Comments: Additional condition in the where clause to
|           filter out the COGS value related to
|           the DropShip Scenarios (logical I/C txns)
|	    The COGS from logical I/C txns are handled
|           in the regular Invoices part of the code
|           (l_stmt_id := 90).
+-------------------------------------------------------------*/

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,parent_rowid
           ,order_number
           ,header_id
           ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,inventory_item_id
           ,organization_id
           ,line_id
           ,line_type_code
           ,line_number
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,original_gl_date
           ,gl_date
           ,order_line_quantity
           ,ship_quantity
           ,cogs_amount
           ,cogs_account
           )
    SELECT
	   'ICAP-'||aid.INVOICE_DISTRIBUTION_ID,
           l_build_id,
           'IC-AP',
           '6',
           '1',
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
           l_le_id,
           NVL(l_ou_id, sh.org_id),
           sh.order_type_id,
           sh.sold_to_org_id,
           sh.salesrep_id,
           sh.sales_channel_code,
           sl_parent.inventory_item_id,
           sl_parent.ship_from_org_id,
           sl_parent.line_id,
           sl_parent.line_number,
           sl_parent.item_type_code,
	   decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
           sl_child.inventory_item_id,
           sl_child.ship_from_org_id,
           sl_child.line_id,
           sl_child.line_category_code,
           sl_child.line_number,
           sl_child.ship_to_org_id,
           sh.invoice_to_org_id,
           aid.accounting_date,
           aid.accounting_date,
           sl_child.shipped_quantity,
           rcl.quantity_invoiced,
           NVL(aid.amount, 0),
           aid.dist_code_combination_id
    FROM
           CST_BIS_MARGIN_BUILD cr,
           ap_invoice_distributions_all aid,
           ap_invoices_all              ai,
           oe_order_headers_all         sh,
           oe_order_lines_all                 sl_parent,
           oe_order_lines_all                 sl_child,
           ra_customer_trx_lines_all    rcl,
           mtl_material_transactions    mmt  ,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 ai.invoice_id = aid.invoice_id
           and   ai.source = 'Intercompany'
           and   ai.org_id = aid.org_id
           and   rcl.customer_trx_line_id = to_number(aid.reference_1)
           and   cr.build_id = l_build_id
           and   sl_parent.org_id = l_ou_id
           and   sl_child.org_id = l_ou_id
           and   sh.org_id = l_ou_id
           and   sl_child.line_id = rcl.interface_line_attribute6
           and   sl_child.line_category_code  = 'ORDER'
      	     AND   ( sl_child.source_document_type_id IS NULL
		     OR sl_child.source_document_type_id <> 10  )
           and   sl_parent.line_category_code = 'ORDER'
           and   sl_parent.line_id = nvl(sl_child.top_model_line_id,sl_child.line_id)
           and   sh.header_id = sl_child.header_id
           and   sh.header_id = sl_parent.header_id
           and   aid.accounting_date between cr.from_date and cr.to_date
           and   aid.line_type_lookup_code IN ('ITEM','ACCRUAL') --Invoice Lines Project
	   and   mmt.transaction_id = rcl.interface_line_attribute7
	   and   nvl(mmt.logical_transaction,0) <> 1
	   /* INVCONV  umoogala  17-oct-2004 */
	   and   mp.organization_id = sl_child.ship_to_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.


/*---------------------------------------------------------------+
 | Insert in temp table all data for Cost of Goods Sold for
 | RMA transactions
 +---------------------------------------------------------------*/

    l_stmt_id := 100;
/*--------------------------------------------------------------+
| Date: 03-Nov-2003
| Developer: ADWAJAN
| Comments: Additional condition in the where clause to
|           calculate COGS for the logical txns in the
|	    Drop Ship scenario - 11.5.10 Impact Analysis
+-------------------------------------------------------------*/

    INSERT INTO CST_BIS_MARGIN_SUMMARY
           (
	   margin_pk,
           build_id
           ,source
           ,row_type
           ,origin
           ,parent_rowid
	   ,legal_entity_id
           ,org_id
           ,order_type_id
           ,customer_id
           ,primary_salesrep_id
           ,sales_channel_code
           ,parent_inventory_item_id
           ,parent_organization_id
           ,parent_line_id
           ,parent_line_number
           ,parent_item_type_code
           ,parent_ato_flag
           ,ship_to_site_use_id
           ,invoice_to_site_use_id
           ,original_gl_date
           ,gl_date
           ,order_number
           ,rma_number
           ,header_id
           ,rma_header_id
           ,inventory_item_id
           ,rma_inventory_item_id
           ,organization_id
           ,rma_organization_id
           ,line_id
           ,rma_line_id
           ,line_number
           ,rma_line_number
           ,rma_ship_to_site_use_id
           ,line_type_code
           ,rma_line_type_code
           ,link_to_line_id
           ,ship_quantity
           ,cogs_amount
           )
    SELECT
	   'RMA-COGS-'||mta.TRANSACTION_ID||'-'||mta.REFERENCE_ACCOUNT||'-'||mta.COST_ELEMENT_ID||'-'||mta.GL_SL_LINK_ID,
           l_build_id,
           'RMA-COGS',
           '4',
           '2',
           rma_line.rowid,
 	   l_le_id,
           ood.operating_unit, -- NVL(l_ou_id, rma.org_id),
           rma.order_type_id,
           rma.sold_to_org_id,
           rma.salesrep_id,
           rma.sales_channel_code,
           rma_line.inventory_item_id,
           rma_line.ship_from_org_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.item_type_code,
	   decode(rma_line.ato_line_id, NULL, 'N', 'Y'),
           rma_line.ship_to_org_id,
           rma.invoice_to_org_id,
           mta.transaction_date,
           mta.transaction_date,
           rma.order_number,
           rma.order_number,
           rma.header_id,
           rma.header_id,
           mmt.inventory_item_id,
           mmt.inventory_item_id,
           mmt.organization_id,
           mmt.organization_id,
           rma_line.line_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           (-1)* decode(nvl(mta.cost_element_id,-1),1,
		mmt.primary_quantity,-1,mmt.primary_quantity,0),
           mta.base_transaction_value
    FROM
           CST_BIS_MARGIN_BUILD cr,
           oe_order_headers_all rma,
           oe_order_lines_all rma_line,
           mtl_material_transactions  mmt,
-- new changes for intercompany invoicing
           org_organization_definitions ood,
           mtl_transaction_accounts  mta,
	   mtl_parameters mp	-- INVCONV  umoogala  17-oct-2004
    WHERE
                 cr.build_id = l_build_id
           and   (
			(mmt.transaction_source_type_id = 12              -- RMA
			and   mta.transaction_source_type_id = 12)
			or
			(mmt.transaction_source_type_id = 13		-- Logical Intercompany Sales Return
			and mmt.transaction_action_id = 14
			and   mta.transaction_source_type_id = 13)
		)
           and   mmt.transaction_id = mta.transaction_id
           and   mta.accounting_line_type in (2,35) -- To collect recognized COGS/RMA alone.
--           and   rma_line.org_id = l_ou_id
           and   rma_line.line_id = mmt.trx_source_line_id
           and   rma_line.line_category_code in ('RETURN')
--           and   rma.org_id = l_ou_id
           and   rma.header_id = rma_line.header_id
           and   mta.transaction_date between  cr.from_date and cr.To_date
-- new changes for intercompany invoicing
           and   ood.organization_id = mmt.organization_id
           and   ood.operating_unit = NVL(l_ou_id,NVL(rma_line.org_id, -999))
	   /* INVCONV  umoogala  17-oct-2004 */
	   and   mp.organization_id = rma_line.ship_from_org_id
	   and   mp.process_enabled_flag <> 'Y';
	   -- This is a NOT NULL column in R12. Hence, no NVL needed here. Using this filter as Discrete orgs
	   -- may have values 'N' or '1'(possibly due to wrong setup). This might be present at customer instances also.


/*---------------------------------------------------------------+
 | Update all the COGS rows with parent_line_id if link_to_line_id
 | is not null
 +---------------------------------------------------------------*/

     l_stmt_id := 110;

     UPDATE CST_BIS_MARGIN_SUMMARY  rma
     SET   (
           parent_rowid ,
           order_number,
           header_id,
           order_type_id,
           customer_id ,
           primary_salesrep_id,
           sales_channel_code,
           parent_inventory_item_id,
           parent_organization_id,
           parent_line_id,
           parent_line_number,
           parent_ato_flag,
           parent_item_type_code,
           inventory_item_id,
           organization_id,
           line_id,
           line_number,
           line_type_code,
           ship_to_site_use_id,
           invoice_to_site_use_id,
           ship_quantity,
           return_reference_type_code,
           return_reference_id) =

           (SELECT

                 sl_parent.rowid,
                 sh.order_number,
                 sh.header_id ,
                 sh.order_type_id,
                 sh.sold_to_org_id,
                 sh.salesrep_id,
                 sh.sales_channel_code,
                 sl_parent.inventory_item_id,
                 sl_parent.ship_from_org_id,
                 sl_parent.line_id,
                 sl_parent.line_number,
	         decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
                 sl_parent.item_type_code,
                 sl_child.inventory_item_id,
                 sl_child.ship_from_org_id,
                 sl_child.line_id,
                 sl_child.line_number,
                 sl_child.line_category_code,
                 sl_child.ship_to_org_id,
                 sh.invoice_to_org_id,
           	 decode(decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
                       'N',decode(rma.rma_inventory_item_id,
                                  sl_parent.inventory_item_id,
                                  rma.ship_quantity, 0),
                       'Y',decode(sl_parent.item_type_code, 'MODEL',
                                  rma.ship_quantity,
                                  decode(rma.rma_inventory_item_id,
                                         sl_parent.inventory_item_id,
                                         rma.ship_quantity,
                                         0)),
                       decode(rma.rma_inventory_item_id, sl_parent.inventory_item_id,
                              rma.ship_quantity, 0)
                       ),
                   sl_child.return_context,
                   sl_child.reference_line_id
           FROM
                 oe_order_lines_all sl_parent,
                 oe_order_lines_all sl_child,
                 oe_order_headers_all sh
           WHERE
                       NVL(sl_parent.org_id, -999) =
                           NVL(l_ou_id, NVL(sl_parent.org_id, -999))
                 and   NVL(sl_child.org_id, -999) =
                           NVL(l_ou_id, NVL(sl_child.org_id, -999))
                 and   sl_child.line_category_code = 'ORDER'
                 and   sl_parent.line_category_code = 'ORDER'
                 and   sl_parent.line_id = nvl(sl_child.top_model_line_id,
                                               sl_child.line_id)
                 and   sl_parent.line_id = rma.link_to_line_id
                 and   sl_child.line_id = rma.link_to_line_id
                 and   NVL(sh.org_id, -999) = NVL(l_ou_id,NVL(sh.org_id, -999))
                 and   sh.header_id = sl_child.header_id
                 and   sh.header_id = sl_parent.header_id
           )
     WHERE
               rma.link_to_line_id is not null
           and rma.row_type = 4
           and rma.source='RMA-COGS'
	   and rma.gl_date between l_from_date and l_to_date
           and rma.build_id = l_build_id;

 END LOOP;   /* Operating Unit Loop */

close all_ous;

/*---------------------------------------------------------------+
 | Update territory_id
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_site_uses_all instead of ra_site_uses_all
 -- as part of Uptake for R12

      l_stmt_id := 140;

      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET territory_id =
         (SELECT territory_id
          FROM   hz_cust_site_uses_all hsu			-- Object ra_site_uses_all obsoleted in R12
          WHERE  NVL(hsu.org_id, -999) = NVL(l_ou_id, NVL(hsu.org_id, -999))
          AND    hsu.site_use_id = temp.ship_to_site_use_id )
	  -- ra_site_uses_all.site_use_id migrated to hz_cust_site_uses_all.site_use_id
      WHERE
          ship_to_site_use_id is not null
	  and gl_date between l_from_date and l_to_date
          and   build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update customer class code
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_accounts instead of ra_customers
 -- as part of Uptake for R12

      l_stmt_id := 150;

      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET customer_class_code =
          (SELECT customer_class_code
           FROM   hz_cust_accounts                    -- Object ra_customers obsoleted in R12
           WHERE  cust_account_id = temp.customer_id) -- ra_customers.customer_id migrated to hz_cust_accounts.cust_account_id
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update sold to customer name
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_accounts and hz_parties instead of ra_customers
 -- as part of Uptake for R12

      l_stmt_id := 160;

      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET sold_to_customer_name =
          (SELECT hp.party_name				-- references ra_customers.customer_name
           FROM   hz_cust_accounts hca, hz_parties hp    -- Object ra_customers obsoleted in R12
           WHERE  hca.party_id = hp.party_id
	   AND hca.cust_account_id = temp.customer_id)
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update bill to customer name
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_accounts, hz_parties,  hz_cust_site_uses_all,
 -- hz_cust_acct_sites_all as part of Uptake for R12

      l_stmt_id := 170;

      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET bill_to_customer_name =
          (SELECT hp.party_name
           FROM   hz_cust_accounts hca
		  , hz_parties hp
		  , hz_cust_site_uses_all hsu
		  , hz_cust_acct_sites_all ha
           WHERE
                 NVL(ha.org_id, -999) = NVL(l_ou_id,NVL(ha.org_id, -999))
           and   hca.party_id = hp.party_id
           and   NVL(hsu.org_id, -999) = NVL(l_ou_id, NVL(hsu.org_id, -999))
	   and   hca.cust_account_id = ha.cust_account_id
	   and   ha.cust_acct_site_id =  hsu.cust_acct_site_id
           and   hsu.site_use_id = temp.invoice_to_site_use_id)
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET bill_to_customer_name =
          (SELECT rc.customer_name
           FROM   ra_customers rc,
                  ra_site_uses_all  rsu,
                  ra_addresses_all ra
           WHERE
                 NVL(ra.org_id, -999) = NVL(l_ou_id,NVL(ra.org_id, -999))
           and   rc.customer_id = ra.customer_id
           and   NVL(rsu.org_id, -999) = NVL(l_ou_id, NVL(rsu.org_id, -999))
           and   ra.address_id = rsu.address_id
           and   rsu.site_use_id = temp.invoice_to_site_use_id)
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;
*/

/*---------------------------------------------------------------+
 | Update ship to customer name
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_accounts, hz_parties,  hz_cust_site_uses_all,
 -- hz_cust_acct_sites_all as part of Uptake for R12

      l_stmt_id := 180;

      UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET ship_to_customer_name =
          (SELECT hp.party_name
           FROM   hz_cust_accounts hca
		  , hz_parties hp
		  , hz_cust_site_uses_all hsu
		  , hz_cust_acct_sites_all ha
           WHERE
                 NVL(ha.org_id, -999) = NVL(l_ou_id,NVL(ha.org_id, -999))
	   and   hca.party_id = hp.party_id
           and   NVL(hsu.org_id, -999) = NVL(l_ou_id, NVL(hsu.org_id, -999))
   	   and   hca.cust_account_id = ha.cust_account_id
	   and   ha.cust_acct_site_id =  hsu.cust_acct_site_id
           and   hsu.site_use_id = temp.ship_to_site_use_id)
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*
  UPDATE CST_BIS_MARGIN_SUMMARY  temp
      SET ship_to_customer_name =
          (SELECT rc.customer_name
           FROM   ra_customers rc,
                  ra_site_uses_all  rsu,
                  ra_addresses_all ra
           WHERE
                 NVL(ra.org_id, -999) = NVL(l_ou_id,NVL(ra.org_id, -999))
           and   rc.customer_id = ra.customer_id
           and   ra.address_id = rsu.address_id
           and   NVL(rsu.org_id, -999) = NVL(l_ou_id, NVL(rsu.org_id, -999))
           and   rsu.site_use_id = temp.ship_to_site_use_id)
      WHERE
           customer_id is not null
	   and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;
*/

/*---------------------------------------------------------------+
 | Update Period Year
 +---------------------------------------------------------------*/

      l_stmt_id := 181;

update CST_BIS_MARGIN_SUMMARY cmt
set (PERIOD_NAME_YEAR, PERIOD_NUM_YEAR) =
(select gp.period_name, gp.PERIOD_YEAR
from
gl_periods gp,
gl_sets_of_books gsob,
hr_organization_information hoi
where
hoi.org_information1 = gsob.SET_OF_BOOKS_ID
and hoi.org_information_context = 'Legal Entity Accounting'
and gsob.period_set_name = gp.period_set_name
and gp.ADJUSTMENT_PERIOD_FLAG = 'N'
and cmt.legal_entity_id = hoi.organization_id
and gp.PERIOD_TYPE = 'Year'
and cmt.gl_date between gp.start_date and gp.end_date)
where
cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;


/*---------------------------------------------------------------+
 | Update Period Quarter
 +---------------------------------------------------------------*/

      l_stmt_id := 182;
update CST_BIS_MARGIN_SUMMARY cmt
set (PERIOD_NAME_QTR, PERIOD_NUM_QTR, PERIOD_SEQ_QTR) =
(select gp.period_name, gp.period_num,
 gp.PERIOD_YEAR * 10 + gp.period_num
from
gl_periods gp,
gl_sets_of_books gsob,
hr_organization_information hoi
where
hoi.org_information1 = gsob.SET_OF_BOOKS_ID
and hoi.org_information_context = 'Legal Entity Accounting'
and gsob.period_set_name = gp.period_set_name
and gp.ADJUSTMENT_PERIOD_FLAG = 'N'
and cmt.legal_entity_id = hoi.organization_id
and gp.PERIOD_TYPE = 'Quarter'
and cmt.gl_date between gp.start_date and gp.end_date)
where
cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update Period Month
 +---------------------------------------------------------------*/

      l_stmt_id := 183;
update CST_BIS_MARGIN_SUMMARY cmt
set (PERIOD_NAME_MONTH, PERIOD_NUM_MONTH, PERIOD_SEQ_MONTH) =
(select gp.period_name, gp.period_num,
 gp.PERIOD_YEAR * 100 + gp.period_num
from
gl_periods gp,
gl_sets_of_books gsob,
hr_organization_information hoi
where
hoi.org_information1 = gsob.SET_OF_BOOKS_ID
and hoi.org_information_context = 'Legal Entity Accounting'
and gsob.period_set_name = gp.period_set_name
and gp.ADJUSTMENT_PERIOD_FLAG = 'N'
and cmt.legal_entity_id = hoi.organization_id
and gp.PERIOD_TYPE = gsob.ACCOUNTED_PERIOD_TYPE
and cmt.gl_date between gp.start_date and gp.end_date)
where
cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update Country level of Geography dimension
 +---------------------------------------------------------------*/
 -- Changed to use hz_cust_accounts, hz_parties,  hz_cust_site_uses_all,
 -- hz_cust_acct_sites_all as part of Uptake for R12

      l_stmt_id := 184;

update CST_BIS_MARGIN_SUMMARY cmt
set COUNTRY_CODE =
(select hl.country
from hz_locations hl
,hz_cust_site_uses_all hcsu
,hz_cust_acct_sites_all hcas
,hz_party_sites hp
where
hcsu.org_id  = cmt.org_id
and hcsu.site_use_id = cmt.ship_to_site_use_id
and hcsu.cust_acct_site_id = hcas.cust_acct_site_id
and hcas.party_site_id = hp.party_site_id
and hp.location_id = hl.location_id)
where
cmt.ship_to_site_use_id is not null
and cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;

/*
update CST_BIS_MARGIN_SUMMARY cmt
set COUNTRY_CODE =
(select raa.country
from ra_site_uses_all rsua,
ra_addresses_all raa
where
rsua.org_id = cmt.org_id
and rsua.site_use_id = cmt.ship_to_site_use_id
and rsua.address_id = raa.address_id)
where
cmt.ship_to_site_use_id is not null
and cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;
*/

/*---------------------------------------------------------------+
 | Update Area level of Geography dimension
 +---------------------------------------------------------------*/


      l_stmt_id := 185;
update CST_BIS_MARGIN_SUMMARY cmt
set (AREA_CODE, COUNTRY_NAME) =
(select bthv.PARENT_TERRITORY_CODE, bthv.CHILD_TERRITORY_NAME
from bis_territory_hierarchies_v bthv
where
bthv.CHILD_TERRITORY_CODE = cmt.country_code)
where
cmt.country_code is not null
and cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update Region level Code of Geography dimension
 +---------------------------------------------------------------*/

      l_stmt_id := 186;

if (app_col_name is not null) then
--app_col_name1 := '''' || app_col_name || '''';

sql_stmt := 'update CST_BIS_MARGIN_SUMMARY cmt set (REGION_CODE, region_name)= '
            || '(select :app_col_name , brv.name from RA_ADDRESSES ra,bis_regions_v brv '
            || 'where cmt.country_code = ra.country'
            || ' and ra.country = brv.COUNTRY_CODE'
            || ' and brv.REGION_CODE = :app_col_name ) where'
            || ' cmt.country_code is not null and'
            || ' cmt.gl_date between :l_from_date and :l_to_date'
            || ' and cmt.build_id = :l_build_id';

   execute immediate sql_stmt using app_col_name, app_col_name,
   l_from_date, l_to_date, l_build_id;

end if;

/*---------------------------------------------------------------+
 | Update Area Name of Geography dimension
 +---------------------------------------------------------------*/


      l_stmt_id := 190;
update CST_BIS_MARGIN_SUMMARY cmt
set AREA_NAME =
(select BAV.name
from bis_areas_v             BAV
where
cmt.area_code          = BAV.area_code )
where
cmt.area_code is not null
and cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;



/*---------------------------------------------------------------+
 | Update Category id for Items
 +---------------------------------------------------------------*/

      l_stmt_id := 200;
update CST_BIS_MARGIN_SUMMARY temp
set OE_ITEM_CATEGORY_ID =
(select max(MC.category_id)
from
        mtl_categories          MC
,       mtl_category_sets       MCS
,       mtl_parameters          MP
,       mtl_item_categories     MIC
,       mtl_default_category_sets MDCS
where
        temp.parent_organization_id = MP.organization_id
AND     MIC.inventory_item_id   = temp.parent_inventory_item_id
AND     MIC.organization_id     = MP.master_organization_id
AND     MC.category_id          = MIC.category_id
AND     MCS.category_set_id     = MIC.category_set_id
AND     MCS.category_set_id     = MDCS.category_set_id
AND     MDCS.functional_area_id = 7
AND     temp.legal_entity_id is not null
)
where
temp.legal_entity_id is not null
and temp.gl_date between l_from_date and l_to_date
and temp.build_id = l_build_id;


/*---------------------------------------------------------------+
 | Update Operating Unit Name
 +---------------------------------------------------------------*/

      l_stmt_id := 210;
update CST_BIS_MARGIN_SUMMARY cmt
set OPERATING_UNIT_NAME =
(select HOU.name
from hr_operating_units      HOU
where
cmt.org_id             = HOU.organization_id)
where
cmt.org_id is not null
and cmt.gl_date between l_from_date and l_to_date
and cmt.build_id = l_build_id;

/*---------------------------------------------------------------+
 | Call ICX package to insert into summary table for WEB inquiry
 | form
 +---------------------------------------------------------------*/

--      icx_margin_web_ana_pkg.build_icx_cst_margin_table;

/*---------------------------------------------------------------+
 | Commit the changes and exit
 +---------------------------------------------------------------*/

      COMMIT;

 END LOOP;  /* Legal Entity Loop */

close all_le;

      icx_margin_web_ana_pkg.build_icx_cst_margin_table;

EXCEPTION

     WHEN OM_NOT_ACTIVE_ERROR THEN

           raise_application_error(-20000, 'CSTPOMLD.load_om_margin_data(): Order Management is not active');

     WHEN OTHERS THEN

            ROLLBACK;

            raise_application_error(-20001, 'CSTPOMLD.load_om_margin_data(' ||
                l_stmt_id || '): ' || SQLERRM);

END load_om_margin_data;

END CSTPOMLD;


/
