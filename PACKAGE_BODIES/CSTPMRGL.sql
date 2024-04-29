--------------------------------------------------------
--  DDL for Package Body CSTPMRGL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPMRGL" AS
/* $Header: CSTMRGLB.pls 120.13.12010000.4 2010/02/16 18:56:08 jkwac ship $ */

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
  l_le_name            VARCHAR2(240);-- ST bug 5202441
  l_build_name         VARCHAR2(255);
  l_build_descr        VARCHAR2(255);
  app_col_name         varchar2(50);
  sql_stmt             varchar2(5000);
  OM_NOT_ACTIVE_ERROR    EXCEPTION;
  l_rowid          rowid ;
  l_cust_id             NUMBER ;
  l_cust_name          VARCHAR2(240);
/*---------------------------------------------------------------+
 |  Get all Legal Entities
 +---------------------------------------------------------------*/

  CURSOR all_le is
     SELECT distinct XFI.legal_entity_id,
            XFI.name
     FROM   xle_firstparty_information_v XFI;

/*---------------------------------------------------------------+
 |  Get all Operating Units for a given Legal Entity
 +---------------------------------------------------------------*/

  CURSOR all_ous(c_le_id NUMBER) is
         SELECT distinct hoi.organization_id
         FROM   hr_organization_information hoi
         WHERE  hoi.org_information2 = to_char(c_le_id)
         AND    hoi.org_information_context = 'Operating Unit Information';

/*-------------------------------------------------------------------+
| Bug#2383504.If Order is booked and shipped from two diff. OU belonging
| to the same LE then COGS to be reported against order OU. We need to
| update org_id for all COGS rows which have a different OU then the
| sales order's.
+--------------------------------------------------------------------*/

   Cursor upd_org_cogs is
      select distinct cms1.rowid , cms2.org_id
              from  CST_MARGIN_SUMMARY cms1 ,   CST_MARGIN_SUMMARY cms2
             where  cms2.source          in ('INVOICE' , 'RMA-INVOICE')
               and  cms2.legal_entity_id = cms1.legal_entity_id
               and  cms2.header_id       = cms1.header_id /* Added for bug# 5098340 */
               and  cms2.order_number    = cms1.order_number
               and  cms2.line_number     = cms1.line_number
               and  cms2.org_id         <> cms1.org_id
               and  cms1.source in  ('COGS' , 'RMA-COGS') -- dropship <
               and NOT EXISTS
               (SELECT 'X'
                FROM mtl_intercompany_parameters
                WHERE ship_organization_id = cms1.org_id
                AND sell_organization_id = cms2.org_id
                AND flow_type = 1); -- > dropship

   CURSOR sold_to_cust(l_build_id NUMBER, l_from_date DATE , l_to_date DATE ) is
         SELECT rowid , customer_id
         FROM   cst_margin_summary
         WHERE  build_id = l_build_id
         AND    gl_date between l_from_date and l_to_date
         AND    customer_id is not null ;


BEGIN
  -- Initialize local variables

  l_stmt_id      := 0;
  l_first_build  := 0;
  app_col_name := NULL;

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
    from CST_MARGIN_BUILD
    where legal_entity_id = l_le_id;

--  DBMS_OUTPUT.PUT_LINE('l_last_load_date = ' || to_char(l_last_load_date));
--  DBMS_OUTPUT.PUT_LINE('l_first_build = ' || to_char(l_first_build));

   l_from_date := fnd_date.canonical_to_date(i_from_date);
   l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);

    if (l_first_build = 1) then

       select NVL(fnd_date.canonical_to_date(i_from_date),to_date('1980/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS')),
              NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE)
       into   l_from_date,
              l_to_date
       from   dual;

    elsif (i_from_date is NULL) then
            if (i_load_option = 1) then
               l_from_date := to_date('1980/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS');
               l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);
            else
               l_from_date := l_last_load_date - i_overlap_days;
               l_to_date := NVL(fnd_date.canonical_to_date(i_to_date), SYSDATE);
            end if;
   end if;

   Select trunc(l_from_date) , trunc(l_to_date)+ .99999
     into l_from_date , l_to_date
     from dual ;

--  DBMS_OUTPUT.PUT_LINE('l_le_name = ' || l_le_name);
--  DBMS_OUTPUT.PUT_LINE('l_from_date = ' || to_char(l_from_date));
--  DBMS_OUTPUT.PUT_LINE('l_to_date = ' || to_char(l_to_date));

/*---------------------------------------------------------------+
 | Delete from CST_MARGIN_SUMMARY for the given Legal Entity
 +---------------------------------------------------------------*/

  BEGIN

--  DBMS_OUTPUT.PUT_LINE('.*******************************************');
--  DBMS_OUTPUT.PUT_LINE('DELETE from TEMP.');
--  DBMS_OUTPUT.PUT_LINE('.*******************************************');

      DELETE from CST_MARGIN_SUMMARY
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
 | Insert into CST_MARGIN_BUILD, if required
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

   INSERT INTO CST_MARGIN_BUILD (
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
    VALUES( l_build_id,
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
           SYSDATE ) ;
else

    UPDATE cst_margin_build
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
 | Insert into CST_MARGIN_SUMMARY for all the invoices booked
 | against regular orders
 +---------------------------------------------------------------*/

    l_stmt_id := 30;

--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('INSERT into TEMP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');

    INSERT INTO CST_MARGIN_SUMMARY
           (
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
           l_build_id,
           'INVOICE',
           '1',
           '1',
           rctl.interface_line_context,
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
           l_le_id,
           l_ou_id,
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
           DECODE(NVL(rctl.interface_line_attribute11, '0'),
                  '0',
                  DECODE(rctl.inventory_item_id,
                         sl_parent.inventory_item_id,
                         inv_convert.inv_um_convert (sl_child.inventory_item_id, 7,
                                                     rctl.quantity_invoiced,
                                                     rctl.uom_code,
                                                     msi.primary_uom_code,
                                                     TO_CHAR(NULL),
                                                     TO_CHAR(NULL)) * rctlgd.percent / 100,
                         0),
                  0),
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           cst_margin_build             cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all    rctl,
           ra_customer_trx_all          rct,
           oe_order_lines_all           sl_child,
           oe_order_lines_all           sl_parent,
           mtl_system_items             msi,
           oe_order_headers_all         sh,
           mtl_parameters               mp    /* INVCONV umoogala 17-oct-2004 */
    WHERE
            cr.build_id                  = l_build_id
      AND   rct.org_id                   = l_ou_id
      AND   rctlgd.org_id                = l_ou_id
      AND   rctl.line_type               = 'LINE'
      AND   rctl.customer_trx_id         = rct.customer_trx_id
      AND   rct.complete_flag            = 'Y'
      AND   rctl.customer_trx_line_id    = rctlgd.customer_trx_line_id
      AND   rctl.interface_line_context  = 'ORDER ENTRY'
      AND   rctlgd.gl_date               IS NOT NULL
      AND   rctlgd.gl_date               BETWEEN cr.from_date AND cr.to_date
      AND   rctlgd.account_class         = 'REV'
      AND   rctlgd.account_set_flag      = 'N'
      AND   msi.inventory_item_id        = sl_child.inventory_item_id
      AND   sl_parent.org_id             = l_ou_id
      AND   msi.organization_id          = sl_child.ship_from_org_id
/*  Modifed for bug 7662078
      AND   sl_child.line_id             = DECODE(rctl.INTERFACE_LINE_CONTEXT,
	                                             'ORDER ENTRY',
                                                 TO_NUMBER(NVL(RCTL.INTERFACE_LINE_ATTRIBUTE6,0)),
                                                 -99999)
      AND   sh.order_number              = DECODE(rctl.INTERFACE_LINE_CONTEXT,
                                                 'ORDER ENTRY',
                                                 TO_NUMBER(NVL(RCTL.INTERFACE_LINE_ATTRIBUTE1,0)),
                                                 -99999) */
      AND   to_char(sl_child.line_id)    = rctl.interface_line_attribute6
      AND   to_char(sh.order_number)     = rctl.sales_order
      AND   sl_child.line_category_code  = 'ORDER'
      AND   sl_parent.line_category_code = 'ORDER'
      AND   sl_parent.line_id            = NVL(sl_child.top_model_line_id, sl_child.line_id)
      AND   sh.header_id                 = sl_child.header_id
      AND   sh.header_id                 = sl_parent.header_id
      ------------------------------------
      -- INVCONV umoogala 17-oct-2004
      ------------------------------------
      AND   mp.organization_id(+)       = sl_parent.ship_from_org_id
      AND   NVL(mp.process_enabled_flag, 'N') = 'N';

/*---------------------------------------------------------------+
 | Insert into CST_MARGIN_SUMMARY for IC-AR
 +---------------------------------------------------------------*/

    l_stmt_id := 35;

--   DBMS_OUTPUT.PUT_LINE('.*******************************************');
--   DBMS_OUTPUT.PUT_LINE('INSERT into TEMP.');
--   DBMS_OUTPUT.PUT_LINE('.*******************************************');

    INSERT INTO CST_MARGIN_SUMMARY
           (
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
           l_build_id,
           'IC-AR',
           '7',
           '1',
           rctl.interface_line_context,
           sl_parent.rowid,
           sh.order_number,
           sh.header_id,
           l_le_id,
           l_ou_id,
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
           mmt.inventory_item_id,
           mmt.organization_id,
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
           cst_margin_build             cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all    rctl,
           oe_order_headers_all         sh,
           oe_order_lines_all           sl_parent,
           oe_order_lines_all           sl_child,
           mtl_system_items             msi,
           ra_customer_trx_all          rct,
           mtl_material_transactions    mmt, -- dropship
           mtl_parameters               mp    /* INVCONV umoogala 17-oct-2004 */
    WHERE
            cr.build_id                      = l_build_id
      AND   rct.org_id                       = l_ou_id
      AND   rctlgd.org_id                    = l_ou_id
      AND   rctl.line_type                   = 'LINE'
      AND   rctl.customer_trx_id             = rct.customer_trx_id
      AND   rct.batch_source_id              = 8    /* Intercompany */
      AND   rct.complete_flag                = 'Y'
      AND   rctl.customer_trx_line_id        = rctlgd.customer_trx_line_id
      AND   rctl.interface_line_context      = 'INTERCOMPANY'
      AND   rctlgd.gl_date                   IS NOT NULL
      AND   rctlgd.gl_date                   BETWEEN cr.from_date AND cr.to_date
      AND   rctlgd.account_class             = 'REV'
      AND   rctlgd.account_set_flag          = 'N'
      AND   msi.inventory_item_id            = sl_child.inventory_item_id
      AND   msi.organization_id              = sl_child.ship_from_org_id
/*  Modifed for bug 7662078
    AND   sl_child.line_id                 = DECODE(INTERFACE_LINE_CONTEXT,
	                                                 'INTERCOMPANY',
                                                     DECODE(rctl.interface_line_attribute2,
                                                            '0',
                                                            0,
                                                            TO_NUMBER(rctl.interface_line_attribute6)),
                                                      -99999)
      -----------------------------------------------------------------
      -- Bug6502607 changes introduced to handle invalid number problem
      -----------------------------------------------------------------
      AND   SH.ORDER_NUMBER                  = DECODE(INTERFACE_LINE_CONTEXT,
                                                     'INTERCOMPANY',
                                                     TO_NUMBER(RCTL.INTERFACE_LINE_ATTRIBUTE1),
                                                     -99999) */
      AND   to_char(sl_child.line_id)        = DECODE(rctl.interface_line_attribute2,
                                                            '0',
                                                            '0',rctl.interface_line_attribute6)
      AND   to_char(sh.order_number)         = rctl.sales_order
      AND   sl_parent.line_category_code     IN ('ORDER','RETURN')
      AND   sl_parent.line_id                = NVL(sl_child.top_model_line_id,sl_child.line_id)
      AND   sh.header_id                     = sl_child.header_id
      AND   sh.header_id                     = sl_parent.header_id
      AND   mmt.transaction_id               = TO_NUMBER(rctl.interface_line_attribute7) -- dropship
      --------------------------------
      -- INVCONV umoogala 17-oct-2004
      --------------------------------
      AND   mp.organization_id(+)            = sl_parent.ship_from_org_id
      AND   NVL(mp.process_enabled_flag, 'N')= 'N';

/*---------------------------------------------------------------+
 | Insert in temp table for all the RMA Invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 40;

-- Bug#2019804.Added to_char to fix Invalid number problem and also changed
-- where clause for performance viz . use  of exist

       INSERT INTO CST_MARGIN_SUMMARY
           (
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
           ,order_number
           ,rma_number
           ,header_id
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
           rctl.CUSTOMER_TRX_ID,
           rctl.CUSTOMER_TRX_LINE_ID,
           decode(rctlgd.original_gl_date, null, rctlgd.gl_date),
           rctlgd.gl_date,
           rma.order_number,
           rma.order_number,
           rma.header_id,
           rma.header_id,
           rctl.inventory_item_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           inv_convert.inv_um_convert (rma_line.inventory_item_id, 7,
                                       rctl.quantity_credited, rctl.uom_code,
                                       msi.primary_uom_code, TO_CHAR(NULL),
                                       TO_CHAR(NULL)),
           decode(nvl(rctl.interface_line_attribute11, '0'),
                  '0', inv_convert.inv_um_convert (rma_line.inventory_item_id, 7,
                                              rctl.quantity_credited,
                                              rctl.uom_code,
                                              msi.primary_uom_code,
                                              TO_CHAR(NULL),
                                              TO_CHAR(NULL)) * rctlgd.percent / 100
                  , 0),
           rctlgd.acctd_amount,
           rctlgd.code_combination_id
    FROM
           cst_margin_build             cr,
           ra_cust_trx_line_gl_dist_all rctlgd,
           ra_customer_trx_lines_all    rctl,
           ra_customer_trx_all          rct,
           oe_order_headers_all         rma,
           oe_order_lines_all           rma_line,
           mtl_system_items             msi,
           mtl_parameters               mp    /* INVCONV umoogala 17-oct-2004 */
    WHERE   cr.build_id                   = l_build_id
      AND   rctl.org_id                   = l_ou_id
      AND   rctl.line_type                = 'LINE'
      AND   rctl.customer_trx_id          = rct.customer_trx_id
      AND   rct.complete_flag             = 'Y'
      AND   rct.org_id                    = l_ou_id
      AND   rctl.customer_trx_line_id     = rctlgd.customer_trx_line_id
      AND   rctl.interface_line_context   = 'ORDER ENTRY'
      AND   rctlgd.gl_date                IS NOT NULL
      AND   rctlgd.gl_date                BETWEEN cr.from_date AND cr.to_date
      AND   rma.org_id                    = l_ou_id
      AND   rctlgd.account_class          = 'REV'
      AND   rctlgd.account_set_flag       = 'N'
      AND   msi.inventory_item_id         = rma_line.inventory_item_id
      AND   msi.organization_id           = rma_line.ship_from_org_id
      AND   rma_line.org_id               = l_ou_id
/*  Modifed for bug 7662078
     AND   rma_line.line_id              = DECODE(rctl.INTERFACE_LINE_CONTEXT,
                                                   'ORDER ENTRY',
                                                   TO_NUMBER(NVL(RCTL.INTERFACE_LINE_ATTRIBUTE6,0)),
                                                   -99999)
      AND   rma.order_number              = DECODE(rctl.INTERFACE_LINE_CONTEXT,
                                                  'ORDER ENTRY',
                                                   TO_NUMBER(NVL(RCTL.INTERFACE_LINE_ATTRIBUTE1,0)),
                                                   -99999) */
      AND   to_char(rma_line.line_id)     = rctl.interface_line_attribute6
      AND   to_char(rma.order_number)     = rctl.sales_order
      AND   rma_line.line_category_code   = 'RETURN'
      AND   rma.header_id = rma_line.header_id
           /* INVCONV umoogala 17-oct-2004 */
      AND   mp.organization_id(+)         = rma_line.ship_from_org_id
      AND   NVL(mp.process_enabled_flag, 'N') = 'N';

/*---------------------------------------------------------------+
 | Update all the rows with parent_line_id if link_to_line_id is
 | not null
 +---------------------------------------------------------------*/

     l_stmt_id := 50;

     UPDATE CST_MARGIN_SUMMARY  rma
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
                 oe_order_lines_all   sl_parent,
                 oe_order_lines_all   sl_child,
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
           and rma.org_id = l_ou_id
           and rma.gl_date between l_from_date and l_to_date
           and rma.build_id = l_build_id;

/*---------------------------------------------------------------+
 | Insert in temp table all data for CR-memos not related to any
 | RMA but related to an invoice selected earlier
 +---------------------------------------------------------------*/

    l_stmt_id := 80;

    INSERT INTO CST_MARGIN_SUMMARY
           (
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
           (
           /*+ no_merge index(temp, cst_margin_summary_n5 )...  Hint suggested by ATANDON of the performance team
               Removed the Hint for perf 6310641 */
         select *
           from
                CST_MARGIN_SUMMARY temp
           where
              temp.source = 'INVOICE'
              and temp.org_id = l_ou_id
              and temp.rowid in (select max(rowid) from cst_margin_summary t1
                                    where  t1.build_id = temp.build_id
                                      and  t1.source   = 'INVOICE'
                                      and t1.org_id = l_ou_id
                                      and t1.header_id = temp.header_id
                                      and t1.line_id = temp.line_id
                                    group  by t1.order_number , t1.line_number )) temp,
           ra_customer_trx_all rct,
           ra_customer_trx_lines_all rctl,
           ra_cust_trx_line_gl_dist_all rctlgd
    WHERE
                 rctl.line_type = 'LINE'
           and   rct.org_id = l_ou_id
           and   rctl.customer_trx_id = rct.customer_trx_id
           and   rct.complete_flag = 'Y'
           and   rctl.customer_trx_line_id = rctlgd.customer_trx_line_id
           and   EXISTS ( select '1' from ra_cust_trx_types rctt
                          where rct.cust_trx_type_id = rctt.cust_trx_type_id
                          and rctt.type = 'CM')
           and   rctlgd.org_id = l_ou_id
           and   rctlgd.gl_date is not null
           and   rctlgd.gl_date between l_from_date and l_to_date
           and   rctlgd.account_class = 'REV'
           and   rctlgd.account_set_flag = 'N'
           and   rctl.LINK_TO_CUST_TRX_LINE_ID  is null
           and   rctl.previous_customer_trx_line_id = temp.CUSTOMER_TRX_LINE_ID
           and   rctl.previous_customer_trx_id = temp.customer_trx_id
           and   not exists
                (select 'x'
                         from cst_margin_summary t2,
                              oe_order_lines_all oel
                  where  t2.source   =    'RMA-INVOICE'
                    and  t2.build_id =     temp.build_id
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

       INSERT INTO CST_MARGIN_SUMMARY
           (
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
    SELECT /*+ ORDERED */  /* asked by the performance team atandon */
           l_build_id,
           'COGS',
           '2',
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
           mmt.inventory_item_id,
           mmt.organization_id,
           mmt.trx_source_line_id,
           sl_child.line_category_code,
           sl_child.line_number,
           sl_child.ship_to_org_id,
           sh.invoice_to_org_id,
           mta.transaction_date,
           mta.transaction_date,
           sl_child.shipped_quantity,
           --{BUG#7215820
           CASE WHEN mmt.transaction_type_id = 10008 THEN
           -- R12 COGS transactions
           DECODE(
              DECODE(sl_parent.ato_line_id, NULL, 'N', 'Y'),
              'N',
              DECODE(mmt.inventory_item_id,
                     sl_parent.inventory_item_id,
                     DECODE(NVL(mta.cost_element_id,-1),
                           1,
                           mmt.primary_quantity,
                           -1,
                           mmt.primary_quantity,
                           0),
                     0),
              ----------------------------------------------------
              -- may need to decode MODEL and KIT, to be confirmed
              ----------------------------------------------------
              'Y',
              DECODE(sl_parent.item_type_code,
                    'MODEL',
                     DECODE(nvl(mta.cost_element_id,-1),
                           1,
                           mmt.primary_quantity,
                           -1,
                           mmt.primary_quantity,
                           0),
                     DECODE(mmt.inventory_item_id,
                            sl_parent.inventory_item_id,
                            DECODE(NVL(mta.cost_element_id,-1),
                                    1,
                                    mmt.primary_quantity,
                                    -1,mmt.primary_quantity,
                                    0),
                            0)),
              DECODE(mmt.inventory_item_id,
                     sl_parent.inventory_item_id,
                     DECODE(NVL(mta.cost_element_id,-1),
                              1,
                              mmt.primary_quantity,
                              -1,
                              mmt.primary_quantity,
                              0),
                     0)
               )
           ELSE
           -- 11i transactions
		   DECODE(decode(sl_parent.ato_line_id, NULL, 'N', 'Y'),
                  'N',decode(mmt.inventory_item_id, sl_parent.inventory_item_id,
                             (-1) * decode(nvl(mta.cost_element_id,-1), 1,
                                mmt.primary_quantity,-1,mmt.primary_quantity,0),
                        0),
           -- may need to decode MODEL and KIT, to be confirmed
                  'Y',decode(sl_parent.item_type_code, 'MODEL',
                             (-1) * decode(nvl(mta.cost_element_id,-1),1,
                                mmt.primary_quantity,-1,mmt.primary_quantity,0),
                             decode(mmt.inventory_item_id,
                                    sl_parent.inventory_item_id,
                                    (-1) * decode(nvl(mta.cost_element_id,-1),1,
                                        mmt.primary_quantity,-1,mmt.primary_quantity,0),
                                    0)),
                  decode(mmt.inventory_item_id, sl_parent.inventory_item_id,
                         (-1) * decode(nvl(mta.cost_element_id,-1),1,
                        mmt.primary_quantity,-1,mmt.primary_quantity,0),
                        0)
                  )
           END,
           mta.base_transaction_value,
           mta.reference_account
    FROM cst_margin_build            cr,
         cst_acct_info_v             ood,
         mtl_material_transactions   mmt,
         mtl_transaction_accounts    mta,
         oe_order_lines_all          sl_child,
         oe_order_lines_all          sl_parent,
         oe_order_headers_all        sh,
         mtl_parameters              mp  /* INVCONV umoogala 17-oct-2004 */
    WHERE  cr.build_id                           =  l_build_id
      AND  (mmt.transaction_source_type_id in (2,8) -- dropship
                                  OR mmt.transaction_action_id = 9)
      AND   transaction_action_id                <> 28
      AND   mta.transaction_source_type_id       =  mmt.transaction_source_type_id -- dropship
      AND   mmt.transaction_id                   =  mta.transaction_id
      AND   mta.accounting_line_type             IN (2,35)
      AND   mta.organization_id                  =  mmt.organization_id
      AND   sl_parent.org_id                     =  sl_child.org_id
      AND   sl_child.line_id                     =  mmt.trx_source_line_id
      AND   sl_child.line_category_code          =  'ORDER'
      AND   sl_parent.line_category_code         =  'ORDER'
      AND   mmt.transaction_date                 BETWEEN cr.from_date AND cr.to_date
      AND   sl_parent.line_id                    =  NVL(sl_child.top_model_line_id,sl_child.line_id)
      AND   sh.header_id                         =  sl_child.header_id
      AND   mmt.organization_id                  =  ood.organization_id
      AND   ood.operating_unit                   =  l_ou_id
      AND   NOT EXISTS -- for internal orders, cogs should be picked up only if src OU <> dest OU
                 (SELECT 'X'
                    FROM po_requisition_headers_all prh
                   WHERE prh.org_id = l_ou_id
                     AND prh.requisition_header_id = sh.source_document_id
                     AND sh.source_document_type_id = 10)
      -------------------------------
      -- INVCONV umoogala 17-oct-2004
      -------------------------------
      AND   mp.organization_id(+)               =  sl_parent.ship_from_org_id
      AND   NVL(mp.process_enabled_flag, 'N')   = 'N';

/*- -------------------------------------------------------------+
 | Insert in temp table all data for IC-AP for
 | regular invoices
 +---------------------------------------------------------------*/

    l_stmt_id := 95;

    INSERT INTO CST_MARGIN_SUMMARY
           (
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
           cst_margin_build             cr,
           ap_invoice_distributions_all aid,
           ap_invoices_all              ai,
           oe_order_headers_all         sh,
           oe_order_lines_all                 sl_parent,
           oe_order_lines_all                 sl_child,
           ra_customer_trx_lines_all    rcl,
           mtl_parameters mp    /* INVCONV umoogala 17-oct-2004 */
    WHERE
                 ai.invoice_id = aid.invoice_id
           and   ai.source = 'Intercompany'
           and   ai.org_id = aid.org_id
           and   rcl.customer_trx_line_id = aid.reference_1
           and   cr.build_id = l_build_id
           and   sl_parent.org_id = decode(SH.SOURCE_DOCUMENT_TYPE_ID, 10, -1, l_ou_id) -- dropship
           and   sl_child.line_id = rcl.interface_line_attribute6
           and   sl_parent.line_category_code  in ('ORDER' , 'RETURN')
           and   sl_parent.line_id = nvl(sl_child.top_model_line_id,sl_child.line_id)
           and   sh.header_id = sl_child.header_id
           and   sh.header_id = sl_parent.header_id
           and   aid.accounting_date between cr.from_date and cr.to_date
           and   aid.line_type_lookup_code IN ('ITEM','ACCRUAL') --Invoice Lines Project
           AND LTRIM(AID.REFERENCE_1,'0123456789') IS NULL -- dropship <
           and NOT EXISTS
           (SELECT 'X'
            FROM mtl_material_transactions
            WHERE transaction_id = rcl.interface_line_attribute7
            AND transaction_source_type_id = 13) -- > dropship
            /* INVCONV umoogala 17-oct-2004 */
            and   mp.organization_id(+) = sl_parent.ship_to_org_id
            and   NVL(mp.process_enabled_flag, 'N') = 'N';

/*---------------------------------------------------------------+
 | Insert in temp table all data for Cost of Goods Sold for
 | RMA transactions
 +---------------------------------------------------------------*/

    l_stmt_id := 100;

       INSERT INTO CST_MARGIN_SUMMARY
           (
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
           ,rma_inventory_item_id
           ,rma_organization_id
           ,rma_line_id
           ,rma_line_number
           ,rma_ship_to_site_use_id
           ,rma_line_type_code
           ,link_to_line_id
           ,ship_quantity
           ,cogs_amount
           ,cogs_account -- added for ER 3007482
           )
    SELECT
           l_build_id,
           'RMA-COGS',
           '4',
           '2',
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
           mta.transaction_date,
           mta.transaction_date,
           rma.order_number,
           rma.order_number,
           rma.header_id,
           rma.header_id,
           mmt.inventory_item_id,
           mmt.organization_id,
           rma_line.line_id,
           rma_line.line_number,
           rma_line.ship_to_org_id,
           rma_line.line_category_code,
           rma_line.link_to_line_id,
           ---------------------------
           -- Comment seems there is no impact of COGS recognitiom transaction here
           -- as the transaction_type_id 10008 and action_id 36 have been filter out in the where clause
           ---------------------------
           (-1)* decode(nvl(mta.cost_element_id,-1),1,
                mmt.primary_quantity,-1,mmt.primary_quantity,0),
           mta.base_transaction_value,
           mta.reference_account -- added for ER 3007482
    FROM
           cst_margin_build             cr,
           oe_order_headers_all         rma,
           oe_order_lines_all           rma_line,
           mtl_material_transactions    mmt,
           cst_organization_definitions cod,
           mtl_transaction_accounts     mta,
           mtl_parameters               mp    /* INVCONV umoogala 17-oct-2004 */
    WHERE  cr.build_id                            =  l_build_id
      AND  (mmt.transaction_source_type_id = 12                                    -- dropship <
                                   OR mmt.transaction_action_id = 14)              -- logical I/C sales return
      AND   mta.transaction_source_type_id        =  mmt.transaction_source_type_id -- > dropship
      AND   mmt.transaction_id                    =  mta.transaction_id
      AND   mta.accounting_line_type              <> 1
      -------------------------------------------------------------------
      -- and   rma_line.org_id = l_ou_id -- comment out for dropshipments
      -------------------------------------------------------------------
      AND   rma_line.line_id                      = mmt.trx_source_line_id
      AND   rma_line.line_category_code           IN ('RETURN')
      ---------------------------------------------------------------
      -- and   rma.org_id = l_ou_id -- comment out for dropshipments
      ---------------------------------------------------------------
      AND   rma.header_id                         =  rma_line.header_id
      AND   mmt.transaction_date                  BETWEEN cr.from_date AND cr.to_date
      AND   cod.organization_id                   =  mmt.organization_id
      AND   cod.operating_unit                    =  NVL(l_ou_id,NVL(rma_line.org_id, -999))
      --------------------------------
      -- INVCONV umoogala 17-oct-2004
      --------------------------------
      AND   mp.organization_id(+)                 =  rma_line.ship_from_org_id
      AND   NVL(mp.process_enabled_flag, 'N')     =  'N';

/*---------------------------------------------------------------+
 | Update all the COGS rows with parent_line_id if link_to_line_id
 | is not null
 +---------------------------------------------------------------*/

     l_stmt_id := 110;

     UPDATE CST_MARGIN_SUMMARY  rma
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

      l_stmt_id := 110;


 END LOOP;   /* Operating Unit Loop */

close all_ous;

/*---------------------------------------------------------------+
 | Update territory_id
 +---------------------------------------------------------------*/

      l_stmt_id := 140;

      UPDATE CST_MARGIN_SUMMARY  temp
      SET territory_id =
         (SELECT territory_id
          FROM   hz_cust_site_uses_all hcsua
          WHERE  NVL(hcsua.org_id, -999) = NVL(l_ou_id, NVL(hcsua.org_id, -999))
          AND    hcsua.site_use_id = temp.ship_to_site_use_id )
      WHERE
          ship_to_site_use_id is not null
          and gl_date between l_from_date and l_to_date
          and   build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update customer class code
 +---------------------------------------------------------------*/

      l_stmt_id := 150;

      UPDATE CST_MARGIN_SUMMARY  temp
      SET customer_class_code =
          (SELECT customer_class_code
           FROM   hz_cust_accounts
           WHERE  cust_account_id = temp.customer_id)
      WHERE
           customer_id is not null
           and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update sold to customer name
 +---------------------------------------------------------------*/

      l_stmt_id := 160;

    OPEN sold_to_cust(l_build_id, l_from_date , l_to_date);
    LOOP
     FETCH sold_to_cust into l_rowid , l_cust_id ;
     EXIT WHEN sold_to_cust%NOTFOUND;
      SELECT SUBSTRB(hp.party_name,1,50) into l_cust_name
        FROM  hz_cust_accounts hca,
              hz_parties hp
       WHERE  hca.cust_account_id = l_cust_id
         AND  hp.party_id = hca.party_id ;

      UPDATE CST_MARGIN_SUMMARY
         SET sold_to_customer_name = l_cust_name
         WHERE
            rowid = l_rowid ;
    END LOOP ;
    close sold_to_cust ;

/*---------------------------------------------------------------+
 | Update bill to customer name
 +---------------------------------------------------------------*/

      l_stmt_id := 170;

      UPDATE CST_MARGIN_SUMMARY  temp
      SET bill_to_customer_name =
          (SELECT SUBSTRB(hp.party_name,1,50)
           FROM   hz_cust_accounts hca,
                  hz_cust_site_uses_all  hcsua,
                  hz_cust_acct_sites_all hcasa,
                  hz_parties hp
           WHERE
                 NVL(hca.org_id, -999) = NVL(l_ou_id,NVL(hca.org_id, -999))
           and   hca.cust_account_id = hcasa.cust_account_id
           and   hp.party_id = hca.party_id
           and   NVL(hcsua.org_id, -999) = NVL(l_ou_id, NVL(hcsua.org_id, -999))
           and   NVL(hcasa.org_id, -999) = NVL(l_ou_id,NVL(hcasa.org_id, -999))
           and   hcsua.site_use_id = temp.invoice_to_site_use_id
           and   hcasa.cust_acct_site_id = hcsua.cust_acct_site_id)
      WHERE
           customer_id is not null
           and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*---------------------------------------------------------------+
 | Update ship to customer name
 +---------------------------------------------------------------*/

      l_stmt_id := 180;

      UPDATE CST_MARGIN_SUMMARY  temp
      SET ship_to_customer_name =
          (SELECT SUBSTRB(hp.party_name,1,50)
           FROM   hz_cust_accounts hca,
                  hz_cust_site_uses_all  hcsua,
                  hz_cust_acct_sites_all hcasa,
                  hz_parties hp
           WHERE
                 NVL(hca.org_id, -999) = NVL(l_ou_id,NVL(hca.org_id, -999))
           and   hca.cust_account_id = hcasa.cust_account_id
           and   hp.party_id = hca.party_id
           and   NVL(hcsua.org_id, -999) = NVL(l_ou_id, NVL(hcsua.org_id, -999))
           and   NVL(hcasa.org_id, -999) = NVL(l_ou_id,NVL(hcasa.org_id, -999))
           and   hcsua.site_use_id = temp.ship_to_site_use_id
           and   hcasa.cust_acct_site_id = hcsua.cust_acct_site_id)
      WHERE
           customer_id is not null
           and gl_date between l_from_date and l_to_date
           and  build_id = l_build_id;

/*---------------------------------------------------------------+
 | Commit the changes and exit
 +---------------------------------------------------------------*/

      COMMIT;

 END LOOP;  /* Legal Entity Loop */

close all_le;

   /* Update the selling  OUs for COGS incase where shipping OU is different from  booking OU  bug 2554225*/

   For   cogs_rec in upd_org_cogs LOOP
         update CST_MARGIN_SUMMARY
           set  org_id = cogs_rec.org_id
          where rowid  = cogs_rec.rowid ;
   End Loop ;

   COMMIT;

EXCEPTION

     WHEN OM_NOT_ACTIVE_ERROR THEN

           raise_application_error(-20000, 'CSTPMRGL.load_om_margin_data(): Order Management is not active');

     WHEN OTHERS THEN

            ROLLBACK;

            raise_application_error(-20001, 'CSTPMRGL.load_om_margin_data(' ||
                l_stmt_id || '): ' || SQLERRM || ' for OU:' || to_char(l_ou_id) || ' and LE:' || to_char(l_le_id));

END load_om_margin_data;

END CSTPMRGL;


/
