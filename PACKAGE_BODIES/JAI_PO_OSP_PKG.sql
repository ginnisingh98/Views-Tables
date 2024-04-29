--------------------------------------------------------
--  DDL for Package Body JAI_PO_OSP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PO_OSP_PKG" AS
/* $Header: jai_po_osp.plb 120.4.12010000.8 2010/04/28 14:53:52 nprashar ship $ */

 /* --------------------------------------------------------------------------------------
Filename:

Change History:

Date         Bug         Remarks
---------    ----------  -------------------------------------------------------------
08-Jun-2005  Version 116.3 jai_po_osp -Object is Modified to refer to New DB Entity names in place of Old DB Entity Names
		as required for CASE COMPLAINCE.

13-Jun-2005    File Version: 116.4
                 Ramananda for bug#4428980. Removal of SQL LITERALs is done

10-MAR-2009  bug 8303018 vumaasha
             Included the issue_date column in the insert statement
			 insert into JAI_PO_OSP_HDRS, with value as sysdate.
--------------------------------------------------------------------------------------*/

PROCEDURE ja_in_57F4_process_header
  (p_po_header_id    po_headers_all.po_header_id%type ,
   p_po_release_id   po_releases_all.po_release_id%type,
   p_vendor_id       po_vendors.vendor_id%type ,
   p_vendor_site_id  po_vendor_sites_all.vendor_site_id%type,
   p_called_from     varchar2
  )
  is
  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_osp_pkg.ja_in_57F4_process_header';

  lv_called_release VARCHAR2(10);
  lv_called_po 	    VARCHAR2(10);
  begin
  /*
  ----------------------------------------------------------------------------------------------------------------------
  CHANGE HISTORY:             FILENAME: jai_po_osp_pkg.sql
  S.No    Date                 Author and Details
  ------------------------------------------------------------------------------------------------------------------------

  1.     08/03/2005     Bug# 4218628 File Version 116.0 (115.1)

                         Issue:-
                          For a PO with multiple OSP lines, only the first lines components were part of the 57F4 challan.
                        Fix :-
                          The issue was happening because of the incorrect check done to see if the PO has already been
                          processed.There was a header level check done , because of which only the first line was being
                          picked up.

                          This issue has been resolved by making a line level check

  3. 10/05/2005   Vijay Shankar for Bug#4346453. Version: 116.1
                   Code is modified due to the Impact of Receiving Transactions DFF Elimination
                   A 57F4 form is getting created if Generate Excise Invoice value of DFF Field is 'Y'. with DFF Elimination
                   the code is moved from ja_in_create_rcV_57f4 trigger to create_rcv_57f4 procedure of this package

                * High Dependancy for future Versions of this object *

  4. 15/02/2007    Vkaranam for bug#4607506,File version 120.2
                   Forward porting the changes done in 11i bug 4559836(osp receipt errors:-ora-01476: divisor is equal to zero)
                   Changes are done in the cursor c_get_lines.

  5. 23/02/07	   bduvarag for bug#4609260,File version 120.3
		   Forward porting the changes done in 11i bug 4404917
		   Changes are done in the cursor c_component_rec

	6. 11/05/2007		CSahoo for bug#5699863, File Version 120.4
									Forward porting R11i BUG#5620085
									Added a procedure to cancel an OSP Challan
									modified the cursors c_check_57f4_exists and c_header_exists.
  7.  9-Feb-2009  Bug 8220196 File version 120.1.12000000.5 / 120.4.12010000.3 / 120.8
                  Issue : Exception thrown when trying to create 57F4 form for a PO.
		  Cause : Variables ln_original_quantity and ln_despatch_quantity
		          (introduced in the fix done for bug 7028169) are not
		          defined for PO Entry and Manual Entry cases, resulting in the
			  "Cannot insert null into ..." error.
		  Fix   : Added an ELSE part to define those variables for cases which were
		          not handled.

  8.  16-Jul-2009  Bug 8602495  File version 120.1.12000000.8 / 120.4.12010000.6 / 120.11
                   Issue : The 57F4 form shows  the PO item (defined as OSP item), even if
		           it is the first item in routing sequence.
		   Fix   : Forward ported changes done for 11i bugs 4680221 and 5017903
		           (corresponding R12 FP bugs - 4940629 and 5072683).
			   Following changes are done:
			   1)Cursor c_get_rout_status will get the data from wip_operations
			     instead of bom_operation_sequences.
			   2)Cursor c_discrete_bill_seq_id (and its use) is removed. Data
			     from the po_dist record will be used instead.
			   3)Modified the filter condition in the cursor of c_component_rec.
  9.  23-Jul-2009 Bug 8678948 AFTER RTV PRIMARY FORM IN APPROVE 57F4 CHALLAN NOT ABLE TO APPROVE THE DISPATCH.
                  issue : The original_qty column is not populated in the table JAI_PO_OSP_LINES in the procedure
				  create_rcv_57f4
				  Fix: populated rtv_qty in the column original_qty
  ----------------------------------------------------------------------------------------*/
    /* Added by Ramananda for removal of SQL LITERALs */
    lv_called_release := 'RELEASE';
    lv_called_po      := 'PO';

     For c_Line_rec in
     (Select distinct po_line_id
      from   po_distributions_all
      where  po_header_id = p_po_header_id
      and
            (       ( p_called_from  = lv_called_release and po_release_id = p_po_release_id) --'RELEASE'      /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
              OR
                    ( p_called_from  = lv_called_po) --'PO'
            )
     )
     Loop
        ja_in_57f4_lines_insert
        (
          p_po_header_id            ,
          c_Line_rec.po_line_id     ,
          p_po_release_id           ,
          p_vendor_id               ,
          p_vendor_site_id          ,
          p_called_from
        );
     End loop;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  end ja_in_57F4_process_header;

/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE ja_in_57f4_lines_insert
  (p_po_header_id    po_headers_all.po_header_id%type ,
   p_po_line_id      po_lines_all.po_line_id%type ,
   p_po_release_id   po_releases_all.po_release_id%type,
   p_vendor_id       po_vendors.vendor_id%type ,
   p_vendor_site_id  po_vendor_sites_all.vendor_site_id%type,
   p_called_from     varchar2
  )
  IS
  cursor c_check_osp_po_distrib(cp_line_type_id number) is
  select outside_operation_flag
  from   po_line_types_b
  where  line_type_id = cp_line_type_id ;

  lv_called_release VARCHAR2(10);
  lv_called_po 	    VARCHAR2(10);

   lv_src_release     JAI_PO_OSP_HDRS.SOURCE%type;
   lv_src_po_release  JAI_PO_OSP_HDRS.SOURCE%type;
   lv_src_po          JAI_PO_OSP_HDRS.SOURCE%type;
   lv_src_pur_ord     JAI_PO_OSP_HDRS.SOURCE%type;

  cursor c_check_57f4_exists is
  select 1
  from   JAI_PO_OSP_HDRS hdr , JAI_PO_OSP_LINES lines
  where  hdr.form_id = lines.form_id
  AND    hdr.po_header_id = p_po_header_id
  AND (
         (      p_called_from = lv_called_po --'PO'	 /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
           AND  lines.po_line_id =  p_po_line_id /* This condition added by ssumaith - bug# 4218628 */
         )
    OR   (      hdr.oth_doc_id = p_po_release_id
           and  p_Called_from = lv_called_release --'RELEASE'
           AND  lines.po_line_id =  p_po_line_id /* This condition added by ssumaith - bug# 4218628 */
         )
      )
  AND nvl(cancel_flag,'N') = 'N'    ;/*5699863 - csahoo */

  CURSOR  c_Excise_Flag(cp_org_id NUMBER, cp_item_id NUMBER) IS
   SELECT excise_flag, item_tariff
   FROM   JAI_INV_ITM_SETUPS
   WHERE  inventory_item_id = cp_item_id
   AND    organization_id   = cp_org_id;

  --******************FETCHING FORM ID FROM SEQUENCE************
  CURSOR  c_form_id IS
   SELECT JAI_PO_OSP_HDRS_S.NEXTVAL
   FROM   dual;

  --******************FETCHING LINE ID FROM SEQUENCE************
  CURSOR  c_line_id IS
   SELECT JAI_PO_OSP_LINES_S.NEXTVAL
   FROM   dual;
  --*****************OSP RETURN DAYS****************************
   CURSOR  c_osp_days(cp_org_id NUMBER) IS
   SELECT  osp_return_days, osp_excise_percent
   FROM    JAI_CMN_INVENTORY_ORGS
   WHERE   organization_id = cp_org_id;
  --******************CHECK IF 57F4 HEADER EXISTS***************** VNK
   CURSOR  c_header_exists(cp_org_id NUMBER, cp_loc_id NUMBER) IS
   SELECT  count(*)
   FROM    JAI_PO_OSP_HDRS
   WHERE   ( po_header_id  = p_po_header_id   and p_called_from = 'PO')
   OR      ( oth_doc_id    = p_po_release_id  and p_called_from = 'RELEASE')
   AND       organization_id = cp_org_id
   AND       location_id     = cp_loc_id
   AND     nvl(cancel_flag,'N') = 'N';/*5699863*/
  --******************FETCH HEADER ID***************** VNK
  CURSOR  c_header_id(cp_org_id NUMBER, cp_loc_id NUMBER) IS
   SELECT form_id
   FROM   JAI_PO_OSP_HDRS
   WHERE  ( po_header_id  = p_po_header_id   and p_called_from = 'PO')
   OR     ( oth_doc_id    = p_po_release_id  and p_called_from = 'RELEASE')
   AND    organization_id = cp_org_id
   AND    location_id     = cp_loc_id;

   /* Bug 7028169. Changed the cursor definition  */
   CURSOR c_get_item_details(cp_org_id NUMBER, cp_item_id NUMBER) IS
   SELECT *
   FROM   mtl_system_items
   WHERE  organization_id = cp_org_id
   AND    inventory_item_id = cp_item_id;

  --**********************ITEM VALUE*****************************
  CURSOR  c_item_value(cp_item_id NUMBER, cp_vendor NUMBER, cp_vendor_site NUMBER, cp_uom_code Varchar2) IS
   SELECT pll.operand
   FROM   qp_list_lines_v pll,
          JAI_CMN_VENDOR_SITES jvs
   WHERE  pll.list_header_id = jvs.price_list_id
   AND    pll.product_attr_value = to_char(cp_item_id)
   and    product_attribute_context = 'ITEM'
   AND    jvs.vendor_id = cp_vendor
   AND    jvs.vendor_site_id = cp_vendor_site
   AND    pll.product_uom_Code = cp_uom_code
   AND    NVL( Start_Date_Active, SYSDATE - 1 ) <= SYSDATE
   AND    NVL( End_Date_Active, SYSDATE + 1 ) >= SYSDATE;
  --**********************ITEM VALUE1*****************************
  CURSOR  c_item_value1(cp_item_id NUMBER, cp_vendor NUMBER, cp_uom_code varchar2) IS
   SELECT pll.operand
   FROM   qp_list_lines_v pll,
          JAI_CMN_VENDOR_SITES jvs
   WHERE  pll.list_header_id = jvs.price_list_id
   AND    pll.product_attr_value = to_char(cp_item_id)
   AND    product_attribute_context = 'ITEM'
   AND    jvs.vendor_id = cp_vendor
   and    jvs.vendor_site_id = 0
   AND    pll.product_uom_Code = cp_uom_code
   AND    NVL( Start_Date_Active, SYSDATE - 1 ) <= SYSDATE
   AND    NVL( End_Date_Active, SYSDATE + 1 ) >= SYSDATE;
  --**********************ITEM VALUE2*****************************
  CURSOR  c_item_value2(cp_item_id NUMBER, cp_org_id NUMBER) IS
   SELECT list_price_per_unit
   FROM   mtl_system_items
   WHERE  inventory_item_id = cp_item_id AND organization_id = cp_org_id;
  --**********************ITEM COST******************************* GSN
  CURSOR  c_item_cost(cp_item_id NUMBER, cp_org_id NUMBER) IS
   SELECT cic.item_cost
   FROM   CST_ITEM_COSTS CIC,
          CST_COST_TYPES CCT
   WHERE  cic.cost_type_id = cct.cost_type_id
   AND    cic.inventory_item_id = cp_item_id
   AND    cic.organization_id = cp_org_id
   AND    cct.allow_updates_flag = 2;


  cursor  c_parent_item_cur ( cp_component_sequence_id number)is
  select  assembly_item_id
  from    bom_bill_of_materials
  where   bill_sequence_id in
  (
     select  bill_sequence_id
     from    bom_inventory_components
     where   component_Sequence_id = cp_component_sequence_id
  );

  cursor c_assembly_id_cur ( cp_wip_entity_id number)is
  select primary_item_id
  from   wip_discrete_jobs
  where  wip_entity_id = cp_wip_entity_id;


  cursor  c_po_line_cur is
  SELECT  po_line_id , item_id, unit_meas_lookup_code,
          unit_price , line_type_id
  FROM    po_lines_all
  WHERE   po_line_id = p_po_line_id;


  cursor  c_location_id is
  SELECT  ship_to_location_id
  FROM    po_line_locations_all
  WHERE   po_header_id = p_po_header_id
  AND     po_line_id   = p_po_line_id;


  /* to get the routing sequence id*/
  /*this cursor is commented for bug 8602495*/
  /*CURSOR c_discrete_bill_seq_id(cp_wip_entity NUMBER) IS
  SELECT common_routing_sequence_id
  FROM   wip_discrete_jobs
  WHERE  wip_entity_id = cp_wip_entity;*/

  /*  to check if this is the first operation. */
  /*This cursor re-written for bug 8602495*/
  CURSOR c_get_rout_status(cp_wip_entity_id NUMBER, cp_wip_operation NUMBER) IS
  SELECT COUNT(1)
  FROM   wip_operations
  WHERE  wip_entity_id     = cp_wip_entity_id
  AND    operation_seq_num < cp_wip_operation ;

  CURSOR  c_check_reqmt_ops( cp_wip_entity_id po_distributions_all.wip_entity_id%TYPE , cp_wip_op_seq_num po_distributions_all.wip_operation_seq_num%TYPE) IS
  SELECT  count(1)
  FROM    wip_requirement_operations
  WHERE   wip_entity_id =  cp_wip_entity_id
  AND     operation_seq_num = cp_wip_op_seq_num
  AND     wip_supply_type <> 6;

  CURSOR c_check_ja_osp(cp_item_id NUMBER) IS
  SELECT COUNT(1)
  FROM   JAI_PO_OSP_ITM_DTLS dtl
  WHERE  osp_item_id = cp_item_id;

  ln_check_57f4_exists   number;
  ln_form_id             number;
  ln_header_ins_flag     number;
  ln_header              number;
  ln_vendor              number;
  ln_vendor_site         number;
  ln_osp_return_days     number;
  ln_osp_excise_percent  number;
  ln_line_id             number;
  ln_parent_item_id      number;
  ln_assembly_id         number;
  ln_po_distribution_id  number;
  lv_item_uom            varchar2(3);
  ln_item_Value          number;
  ln_excise_rate         number;
  ln_bal_parent_item_qty number;
  ln_po_qty              number;
  lv_source_code         varchar2(1) ;
  ln_item_unit_price     number;
  lv_osp_po              varchar2(1);
  lv_Excise_flag         JAI_INV_ITM_SETUPS.excise_flag%type;
  lv_tariff_code         JAI_INV_ITM_SETUPS.item_tariff%type;
  rec_po_line_cur        c_po_line_cur%rowtype;
  ln_location_id         number;
  ln_routing_seq_id      number;
  ln_routing_ctr         number;
  ln_ja_ctr              NUMBER;
  ln_reqmt_op_ctr        NUMBER;

/*bug 9626826 by nprashar */
cursor c_get_resource_usage_rate (cp_wip_entity_id number, cp_op_seq_num number, cp_item_id number) is
select usage_rate_or_amount
from wip_operation_resources
where wip_entity_id = cp_wip_entity_id
and operation_seq_num = cp_op_seq_num
and resource_id in (select resource_id
                    from bom_resources
                    where purchase_item_id = cp_item_id);

ln_usage_rate number;
/*end bug 9626826 by  nprashar */

  lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_osp_pkg.ja_in_57f4_lines_insert';

  -- Bug 7028169. Added by Lakshmi Gopalsami
  r_get_po_item_details    c_get_item_details%ROWTYPE;
  r_get_comp_item_details  c_get_item_details%ROWTYPE;
  ln_original_quantity  NUMBER;
  ln_despatch_quantity  NUMBER;



  BEGIN
    ln_check_57f4_exists := 0;

    /* Added by Ramananda for removal of SQL LITERALs */
    lv_called_release := 'RELEASE';
    lv_called_po      := 'PO';

    open   c_check_57f4_exists;
    fetch  c_check_57f4_exists into ln_check_57f4_exists;
    close  c_check_57f4_exists;


    ln_vendor := p_vendor_id;
    ln_vendor_site := p_vendor_site_id;


    if nvl(ln_check_57f4_exists,0) = 1 then
       return;
    end if;

    open  c_po_line_cur;
    fetch c_po_line_cur into rec_po_line_cur;
    close c_po_line_cur;


    lv_osp_po := 'N';
    open  c_check_osp_po_distrib(rec_po_line_cur.line_type_id);
    fetch c_check_osp_po_distrib into lv_osp_po;
    close c_check_osp_po_distrib;

    if nvl(lv_osp_po,'N') <> 'Y' then
       goto continue_with_next;
    end if;

    ln_item_unit_price := rec_po_line_cur.unit_price;

    For c_po_dist In
    (SELECT SUM(quantity_ordered) quantity_ordered,
              destination_organization_id orgn_id ,
              deliver_to_location_id      loc_id  ,
              wip_entity_id, wip_operation_seq_num,
              wip_repetitive_schedule_id, wip_line_id
     FROM   po_distributions_all
     WHERE  po_header_id = p_po_header_id
     and    po_line_id = rec_po_line_cur.po_line_id
     and
      (       ( p_called_from  = 'RELEASE' and po_release_id = p_po_release_id)
         OR
               ( p_called_from  = 'PO' )
      )
      GROUP  BY destination_organization_id,deliver_to_location_id,
                wip_entity_id, wip_operation_seq_num,
                wip_repetitive_schedule_id, wip_line_id
      )
       Loop

          open  c_location_id;
          fetch c_location_id into ln_location_id;
          close c_location_id;

          OPEN  c_header_exists( c_po_dist.orgn_id, nvl(c_po_dist.loc_id,ln_location_id));
          FETCH c_header_exists INTO ln_header;
          CLOSE c_header_exists;

          OPEN  c_check_reqmt_ops(c_po_dist.wip_entity_id  , c_po_dist.wip_operation_seq_num );
          FETCH c_check_reqmt_ops INTO ln_reqmt_op_ctr;
          CLOSE c_check_reqmt_ops;

          OPEN  c_check_ja_osp(rec_po_line_cur.item_id);
          FETCH c_check_ja_osp INTO ln_ja_ctr;
          CLOSE c_check_ja_osp;

          IF ln_reqmt_op_ctr IS NULL THEN
             ln_reqmt_op_ctr := 0;
          END IF;

          IF ln_ja_ctr IS NULL THEN
             ln_ja_ctr := 0;
          END IF;

          IF ln_header = 0 THEN
             OPEN  c_form_id;
             FETCH c_form_id INTO ln_form_id;
             CLOSE c_form_id;
             ln_header_ins_flag := 1;
          ELSIF ln_header > 0 THEN
              OPEN c_header_id(c_po_dist.orgn_id, nvl(c_po_dist.loc_id,ln_location_id));
              FETCH c_header_id INTO ln_form_id;
              CLOSE c_header_id;
              ln_header_ins_flag := 0;
          END IF;

      /*bug 9626826  by nprashar */
        ln_usage_rate := 1;

        open c_get_resource_usage_rate(c_po_dist.wip_entity_id, c_po_dist.wip_operation_seq_num, rec_po_line_cur.item_id);
        fetch c_get_resource_usage_rate into ln_usage_rate;
        close c_get_resource_usage_rate;

        if ln_usage_rate is null or ln_usage_rate = 0
        then
          ln_usage_rate := 1;
        end if;
        /*end bug 9626826  by nprashar*/

          ln_bal_parent_item_qty := c_po_dist.quantity_ordered;
          ln_po_qty              := c_po_dist.quantity_ordered;

          open  c_osp_days(c_po_dist.orgn_id);
          fetch c_osp_days into  ln_osp_return_days , ln_osp_excise_percent;
          close c_osp_days;

          open  c_location_id;
          fetch c_location_id into ln_location_id;
          close c_location_id;

	  /*below cursor block commented for bug 8602495*/
          /*open  c_discrete_bill_seq_id(c_po_dist.wip_entity_id);
          fetch c_discrete_bill_seq_id into ln_routing_seq_id;
          close c_discrete_bill_seq_id;*/

          ln_routing_ctr := 0;
          open  c_get_rout_status(c_po_dist.wip_entity_id, c_po_dist.wip_operation_seq_num); /*changed for bug 8602495*/
          fetch c_get_rout_status into ln_routing_ctr;
          close c_get_rout_status;

          /* Bug 7028169. Added by Lakshmi Gopalsami */

           open  c_get_item_details(c_po_dist.orgn_id , rec_po_line_cur.item_id);
           fetch c_get_item_details into  r_get_po_item_details ;
           close c_get_item_details;

         /*
          insert into JAI_PO_OSP_HDRS
         */
         if ln_header_ins_flag = 1 then

	 lv_src_release    := 'RELEASE' ;
	 lv_src_po_release := 'PO RELEASE';
	 lv_src_po         := 'PO';
	 lv_src_pur_ord    := 'PURCHASE ORDER';

           INSERT INTO JAI_PO_OSP_HDRS (
                 FORM_ID,
                 PO_HEADER_ID,
                 VENDOR_ID,
                 VENDOR_SITE_ID,
                 PROCESS_TIME,
                 ORGANIZATION_ID,
                 LOCATION_ID,
                 SOURCE,
                 ISSUE_APPROVED,
                 RECEIPT_APPROVED,
                 CANCEL_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 OTH_DOC_ID,
                 PRIMARY_FLAG,
				 ISSUE_DATE -- added for bug 8303018
				 )
           VALUES
           (
                 ln_form_id          ,
                 p_po_header_id     ,
                 ln_vendor           ,
                 ln_vendor_site      ,
                 ln_osp_return_days  ,
                 c_po_dist.orgn_id  ,
                 nvl(c_po_dist.loc_id,ln_location_id)   ,
                 decode(p_called_from , lv_src_release ,lv_src_po_release,lv_src_po,lv_src_pur_ord),	/* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
                 'N',
                 'N',
                 'N',
                 sysdate,
                 fnd_global.user_id ,
                 sysdate ,
                 fnd_global.user_id ,
                 fnd_global.login_id,
                 p_po_release_id,
                 'Y',
				 sysdate -- added for bug 8303018
           );

         end if;

         For c_component_rec in
         ( SELECT  required_quantity ,quantity_per_assembly,inventory_item_id ,
                   component_sequence_id , 'W' item_type, comments
            FROM   wip_requirement_operations wro
           WHERE   wro.wip_entity_id = c_po_dist.wip_entity_id
             AND   wro.operation_seq_num = c_po_dist.wip_operation_seq_num
             AND   wip_supply_type <> 6
           UNION
           select  c_po_dist.quantity_ordered , 1 , rec_po_line_cur.item_id , 1 ,
	           'P' item_type, 'PO Entry' comments
           from    dual
	   where   ( ln_routing_ctr > 0 OR ln_reqmt_op_ctr + ln_ja_ctr = 0) /*Bug 4609260*/
	   /*above condition changed for bug 8602495*/
           union
           select 1 , dtl.quantity , dtl.item_id , 1 , 'M' item_type,'Manual Entry' comments
           from   JAI_PO_OSP_ITM_DTLS dtl
           where  osp_item_id = rec_po_line_cur.item_id
         ) /*
           The wip_supply_type != 6 indicates that phantom kit itself should not come in the 57F4 challan instead the
           components should feature in the 57F4. Supply Type = 6 indicates a phantom supply type.

           The query after the first union takes care of the scenario where the PO item needs to be part of the 57F4 if it
           is not the first operation.

           The query after the second union takes care of the manual BOM setup by the user.
           */
        Loop

           ln_line_id := 0;
           open  c_excise_flag(c_po_dist.orgn_id , c_component_rec.inventory_item_id);
           fetch c_excise_flag into lv_Excise_flag , lv_tariff_code;
           close c_excise_flag;

           if nvl(lv_Excise_flag,'N') <> 'Y' then
              goto continue_with_next_item;
           end if;


           open  c_line_id;
           fetch c_line_id into ln_line_id;
           close c_line_id;

           ln_parent_item_id := 0;

           /*
           for the items which are part of the WIP , we get the parent item based on the wip bom tables
           for the po items and items used in manual bom , the po item is itself the parent item.
           */
           if c_component_rec.item_type = 'W' then
             open  c_parent_item_cur(c_component_rec.component_sequence_id);
             fetch c_parent_item_cur into ln_parent_item_id;
             close c_parent_item_cur;
           elsif c_component_rec.item_type in ('P', 'M') then
             ln_parent_item_id := rec_po_line_cur.item_id;
           end if;

           open  c_assembly_id_cur(c_po_dist.wip_entity_id);
           fetch c_assembly_id_cur into ln_assembly_id;
           close c_assembly_id_cur;

           open  c_get_item_details(c_po_dist.orgn_id , c_component_rec.inventory_item_id);
           fetch c_get_item_details into  r_get_comp_item_details ;
           close c_get_item_details;

           ln_item_Value := Null;
           OPEN  c_item_value(c_component_rec.inventory_item_id,
                              ln_vendor,
                              ln_vendor_site,
                              r_get_comp_item_details.primary_uom_code);
           FETCH c_item_value INTO ln_item_Value;
           CLOSE c_item_value;

           IF NVL(ln_item_Value,0) = 0 THEN
                OPEN  c_item_value1(c_component_rec.inventory_item_id,
                                    ln_vendor,
                                    r_get_comp_item_details.primary_uom_code);
                FETCH c_item_value1 INTO ln_item_Value;
                CLOSE c_item_value1;


                IF NVL(ln_item_Value,0) = 0 THEN
                    OPEN  c_item_value2(c_component_rec.inventory_item_id, c_po_dist.orgn_id);
                    FETCH c_item_value2 INTO ln_item_Value;
                    CLOSE c_item_value2;

                    IF NVL(ln_item_Value,0) = 0 THEN

                       OPEN c_item_cost(c_component_rec.inventory_item_id, c_po_dist.orgn_id);
                       FETCH c_item_cost INTO ln_item_Value;
                       CLOSE c_item_cost;
                       ln_item_Value := NVL(ln_item_Value,0);
                       /*IF NVL(ln_item_Value,0) = 0 THEN
                          ln_item_Value := NVL(ln_item_unit_price,0);
                       end if;*/
                    END IF;
                END IF;
           END IF;

           IF NVL(c_component_rec.inventory_item_id,0)  = NVL(ln_parent_item_id,1) THEN
                   ln_item_Value := NVL(ln_item_unit_price,0);
           END IF;

           lv_source_code := c_component_rec.item_type;

           /* Bug 7028169. Added by Lakshmi Gopalsami
            * Calculate the original quantity and despatch quantity.
            */

           IF  lv_source_code = 'W' THEN --1
             IF r_get_po_item_details.outside_operation_uom_type = 'ASSEMBLY' THEN --2

                 ln_original_quantity :=  round(ln_po_qty * c_component_rec.quantity_per_assembly/ln_usage_rate ,6); --Added by nprashar fo  bug # 9626826
                 ln_despatch_quantity :=  round(ln_po_qty * c_component_rec.quantity_per_assembly/ln_usage_rate,6);  --Added by nprashar for bug # 9626826

             ELSIF r_get_po_item_details.outside_operation_uom_type = 'RESOURCE' THEN
                 ln_original_quantity :=  round(c_component_rec.required_quantity * c_component_rec.quantity_per_assembly/ln_usage_rate,6); --Added by nprashar for bug # 9626826
                 ln_despatch_quantity :=  round(c_component_rec.required_quantity * c_component_rec.quantity_per_assembly/ln_usage_rate,6);--Added by nprashar for bug # 9626826

             END IF; /* outside_operation_uom_type */  --2
	   /*bug 8220196 - calculate the quantities for PO entry / manual entry cases*/
	   ELSE
	     ln_original_quantity := ln_po_qty * c_component_rec.quantity_per_assembly;
	     ln_despatch_quantity := ln_po_qty * c_component_rec.quantity_per_assembly;
	   /*end bug 8220196*/
           END IF; /* lv_source_code ='W' */ --1

           INSERT INTO JAI_PO_OSP_LINES (
                   FORM_ID                                                  ,
                   LINE_ID                                                  ,
                   PO_LINE_ID                                               ,
                   PO_DISTRIBUTION_ID                                       ,
                   ITEM_ID                                                  ,
                   WIP_ENTITY_ID                                            ,
                   WIP_LINE_ID                                              ,
                   WIP_REPETITIVE_SCHEDULE_ID                               ,
                   WIP_OPERATION_SEQUENCE_NUM                               ,
                   ASSEMBLY_ID                                              ,
                   DESPATCH_QTY                                             ,
                   ITEM_UOM                                                 ,
                   ITEM_VALUE                                               ,
                   TARIFF_CODE                                              ,
                   EXCISE_RATE                                              ,
                   LAST_UPDATE_DATE                                         ,
                   LAST_UPDATED_BY                                          ,
                   CREATED_BY                                               ,
                   CREATION_DATE                                            ,
                   LAST_UPDATE_LOGIN                                        ,
                   PARENT_ITEM_ID                                           ,
                   COMP_QTY_PA                                              ,
                   BAL_PARENT_ITEM_QTY                                      ,
                   SOURCE_CODE                                              ,
                   ORIGINAL_QTY,
		   PROCESS_REQD)
            VALUES                      (
                   ln_form_id                                                ,
                   ln_line_id                                                ,
                   rec_po_line_cur.po_line_id                                ,
                   NULL                                                      ,
                   c_component_rec.inventory_item_id                         ,
                   c_po_dist.wip_entity_id                                   ,
                   c_po_dist.wip_line_id                                     ,
                   c_po_dist.wip_repetitive_schedule_id                      ,
                   c_po_dist.wip_operation_seq_num                           ,
                   ln_assembly_id                                            ,
                    -- Bug 7028169. Added by Lakshmi Gopalsami
                   ln_despatch_quantity         ,
                   r_get_comp_item_details.primary_uom_code                                               ,
                   ln_item_Value                                             ,
                   lv_tariff_code                                            ,
                   nvl(ln_osp_excise_percent,0)                              ,
                   sysdate                                                   ,
                   fnd_global.user_id                                        ,
                   fnd_global.user_id                   ,
                   sysdate                              ,
                   fnd_global.login_id                  ,
                   ln_parent_item_id                     ,
                   c_component_rec.quantity_per_assembly,
                   ln_bal_parent_item_qty                ,
                   lv_source_code                        ,
                    -- Bug 7028169. Added by Lakshmi Gopalsami
                   ln_original_quantity,
                   c_component_rec.comments
                   );

        << continue_with_next_item >>
         Null;

        End Loop;
    End Loop;


  << continue_with_next >>
         Null;
  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;
  end ja_in_57f4_lines_insert;

/*------------------------------------------------------------------------------------------------------------*/

/* Start - Added by csahoo for bug#5699863 */
procedure cancel_osp
(p_form_id         JAI_PO_OSP_HDRS.form_id%type)
is
 lv_rtv_source    VARCHAR2(30) := 'RETURN TO VENDOR';


  cursor c_57f4_lines is
  select hdr.primary_flag, hdr.primary_form_id, dtl.despatch_qty, dtl.po_line_id, dtl.item_id
  from JAI_PO_OSP_HDRS hdr, JAI_PO_OSP_LINES dtl
  where hdr.form_id = dtl.form_id
  and hdr.form_id = p_form_id;

begin
   /* cancel the OSP Challan */
   UPDATE JAI_PO_OSP_HDRS
   SET    cancel_flag      = 'Y'
         ,last_update_date = sysdate
         ,last_updated_by  = fnd_global.user_id
         ,last_update_login= fnd_global.login_id
   WHERE  form_id     = p_form_id
   OR     (primary_form_id = p_form_id
   AND    source <> lv_rtv_source
   );


  FOR i_rec in c_57f4_lines LOOP
    IF nvl(i_rec.primary_flag,'N') = 'N' THEN
	UPDATE JAI_PO_OSP_LINES set dispatched_qty = dispatched_qty - i_rec.despatch_qty
	where form_id = i_rec.primary_form_id
	and item_id = i_rec.item_id
	and po_line_id = i_rec.po_line_id;
    END IF;
  END LOOP;


end cancel_osp;
/* End - Added by csahoo for bug#5699863*/


/***********************************************************************************************/




  /* following procedure is created as part of Receipt/RTV DFF elimination
    this is a copy of ja_in_create_rcv_57f4 trigger which is removed with DFF elimination
    this will be invoked only if generate_excise_invoice is true and RTV refers a PO document
  Vijay Shankar for Bug#4346453. RCV DFF Elim. Enh. */
  PROCEDURE create_rcv_57f4(
    p_transaction_id                NUMBER,
    p_process_status    OUT NOCOPY  VARCHAR2,
    p_process_message   OUT NOCOPY  VARCHAR2
  ) IS

    CURSOR c_base_trx(cp_transaction_id IN NUMBER) IS
      SELECT shipment_header_id, shipment_line_id, transaction_type, organization_id, location_id,
        quantity, unit_of_measure, subinventory, vendor_id, vendor_site_id,
        source_document_code, po_header_id, po_line_id, po_line_location_id, po_release_id
      FROM rcv_transactions
      WHERE transaction_id = cp_transaction_id;

    r_base_trx      c_base_trx%ROWTYPE;

  CURSOR c_sh_line_info IS
   SELECT item_id, ship_to_location_id
   FROM   rcv_shipment_lines
   WHERE  shipment_line_id = r_base_trx.shipment_line_id;

  CURSOR c_Excise_Flag (v_item_id NUMBER) IS
   SELECT excise_flag, item_tariff
   FROM   JAI_INV_ITM_SETUPS
   WHERE  inventory_item_id = v_item_id
   AND    organization_id   = r_base_trx.organization_id;

  CURSOR c_po_line_info IS
   SELECT unit_meas_lookup_code, unit_price
   FROM   po_lines_all
   WHERE  po_line_id = r_base_trx.po_line_id;

  CURSOR c_po_dist_info IS
   SELECT po_distribution_id, wip_entity_id, wip_line_id,
   wip_repetitive_schedule_id, wip_operation_seq_num
   FROM po_distributions_all
   WHERE line_location_id = r_base_trx.po_line_location_id
   AND  ROWNUM = 1;

  CURSOR c_assembly_id(cp_wip_entity NUMBER) IS
   SELECT primary_item_id
   FROM wip_entities
   WHERE wip_entity_id = cp_wip_entity;

  CURSOR c_osp_days IS
   SELECT osp_return_days, osp_excise_percent
   FROM JAI_CMN_INVENTORY_ORGS
   WHERE organization_id = r_base_trx.organization_id;

  CURSOR c_item_value(cp_item_id NUMBER, cp_uom_code VARCHAR2) IS
   SELECT pll.list_price
   FROM so_price_list_lines pll,
   JAI_CMN_VENDOR_SITES jvs
   WHERE pll.price_list_id = jvs.price_list_id
   AND  pll.inventory_item_id = cp_item_id
   AND  jvs.vendor_id = r_base_trx.vendor_id
   AND  jvs.vendor_site_id = r_base_trx.vendor_site_id
   AND  Unit_Code = cp_uom_code
   AND  NVL( Start_Date_Active, SYSDATE - 1 ) <= SYSDATE
   AND  NVL( End_Date_Active, SYSDATE + 1 ) >= SYSDATE;

  CURSOR c_item_value1(cp_item_id NUMBER, cp_uom_code VARCHAR2) IS
   SELECT pll.list_price
   FROM so_price_list_lines pll,
   JAI_CMN_VENDOR_SITES jvs
   WHERE pll.price_list_id = jvs.price_list_id
   AND  pll.inventory_item_id = cp_item_id
   AND  jvs.vendor_id = r_base_trx.vendor_id
   AND  jvs.vendor_site_id = 0
   AND  Unit_Code = cp_uom_code
   AND  NVL( Start_Date_Active, SYSDATE - 1 ) <= SYSDATE
   AND  NVL( End_Date_Active, SYSDATE + 1 ) >= SYSDATE;

  CURSOR c_get_uom_code(cp_measure_code VARCHAR2) IS
    SELECT  UOM_CODE
    FROM mtl_UNITS_OF_MEASURE
    WHERE UNIT_OF_MEASURE = cp_measure_code;

  CURSOR v_vend_info(cp_header_id NUMBER) IS
    SELECT vendor_site_id
    FROM po_headers_all
    WHERE po_header_id = cp_header_id;

    -- cbabu for Bug# 2746952
    v_primary_form_id JAI_PO_OSP_HDRS.primary_form_id%TYPE;
    CURSOR c_primary_form_id( p_po_header_id IN NUMBER, p_oth_doc_id IN NUMBER) IS
      SELECT form_id
      FROM JAI_PO_OSP_HDRS
      WHERE po_header_id = p_po_header_id
      AND primary_flag = 'Y'
      AND issue_approved = 'Y'
      -- AND receipt_approved = 'N' Sriram - bug# 3303027
      AND (oth_doc_id = p_oth_doc_id OR oth_doc_id is NULL);

  v_organization_id NUMBER;
  v_loc             NUMBER;

  v_item_id         NUMBER;
  v_loc_id          NUMBER;
  v_uom             VARCHAR2(25);
  v_po_unit_price   NUMBER;
  v_unit_price      NUMBER;
  v_po_dist         NUMBER;
  v_wip_entity      NUMBER;
  v_wip_oprn        NUMBER;
  v_wip_line        NUMBER;
  v_wip_sch         NUMBER;
  v_assembly        NUMBER;
  v_process_time    NUMBER;
  v_excise_rate     NUMBER;
  v_item_tariff     VARCHAR2(50);
  v_form_id         NUMBER;
  v_line_id         NUMBER;
  v_excise_flag     VARCHAR2(1);

  v_po_header       NUMBER;
  v_po_release_id   NUMBER;
  v_po_line         NUMBER;
  v_vendor          NUMBER;
  v_vendor_site     NUMBER;
  v_issue_qty       NUMBER;
  v_org_id          NUMBER;

  v_created_by      NUMBER;
  v_creation_dt     DATE;
  v_last_upd_dt     DATE;
  v_last_upd_by     NUMBER;
  v_last_upd_lgin   NUMBER;

  v_source_code     VARCHAR2(1); --File.Sql.35 Cbabu  := 'R';

  v_uom_rate        number ;      -- ssumaith - 3644848
  v_from_uom_code   VARCHAR2(25); -- ssumaith - 3644848
  v_to_uom_code     VARCHAR2(25); -- ssumaith - 3644848

  lv_statement_id   VARCHAR2(4);

  lv_source JAI_PO_OSP_HDRS.source%type ;
  BEGIN
  /*----------------------------------------------------------------------------------------------------------------- -
  FILENAME: ja_in_create_rcv_57F4_trg.sql CHANGE HISTORY:
  S.No      DD-MON-YYYY    Author and Details
  ------------------------------------------------------------------------------------------------------------------- -
  1.    26/05/2004  ssumaith - bug#3644848 file version 115.1

                        When rtv is done in a uom different from the PO uom code , the item rate is not getting
                        recalculated for the rtv uom , instead the uom of the rtv is used with the item rate
                        of the po uom.

                        The call to the inv_convert.inv_um_conversion is done to get the conversion factor
                        and it is used as a factor to calculate the item rate.

  2.    29-nov-2004  ssumaith - bug# 4037690  - File version 115.2

                     Check whether india localization is being used was done using a INR check in every trigger.
                     This check has now been moved into a new package and calls made to this package from this trigger
                     If the function JA_IN_UTIL.CHECK_JAI_EXISTS returns true it means INR is the set of books currency ,
                     Hence if this function returns FALSE , control should return.

  3     This Procedure Created from Trigger ja_in_create_rcv_57F4_trg by Vijay Shankar as part of Receipt DFF Elimination
        Bug#4346453

  ----------------------------------------------------------------------------------------------------------------------*/

  lv_statement_id := '1';
  v_source_code  := 'R';

  open c_base_trx(p_transaction_id);
  fetch c_base_trx into r_base_trx;
  close c_base_trx;

  v_created_by    := fnd_global.user_id;
  v_creation_dt   := sysdate;
  v_last_upd_dt   := sysdate;
  v_last_upd_by   := fnd_global.user_id;
  v_last_upd_lgin := fnd_global.login_id;

  v_organization_id := r_base_trx.organization_id;
  v_po_header     := r_base_trx.po_header_id;
  v_po_release_id := r_base_trx.po_release_id;
  v_po_line       := r_base_trx.po_line_id;
  v_vendor        := r_base_trx.vendor_id;
  v_vendor_site   := r_base_trx.vendor_site_id;
  v_issue_qty     := r_base_trx.quantity;
  v_org_id        := r_base_trx.organization_id;

  lv_statement_id := '2';

  OPEN c_po_dist_info;
  FETCH c_po_dist_info INTO v_po_dist, v_wip_entity, v_wip_line, v_wip_sch, v_wip_oprn;
  CLOSE c_po_dist_info;

  -- cbabu for Bug# 2746952
  OPEN c_primary_form_id(v_po_header, v_po_release_id);
  FETCH c_primary_form_id INTO v_primary_form_id;
  CLOSE c_primary_form_id;

  lv_statement_id := '3';

  IF v_wip_entity IS NOT NULL THEN

    OPEN c_sh_line_info;
    FETCH c_sh_line_info INTO v_item_id, v_loc_id;
    CLOSE c_sh_line_info;

    OPEN c_excise_flag(v_item_id);
    FETCH c_excise_flag INTO v_excise_flag, v_item_tariff;
    CLOSE c_excise_flag;

    lv_statement_id := '4';

    IF v_excise_flag = 'Y' THEN

      lv_statement_id := '5';
      OPEN c_po_line_info;
      FETCH c_po_line_info INTO v_uom, v_po_unit_price;
      CLOSE c_po_line_info;

      OPEN  c_get_uom_code(v_uom);
      FETCH c_get_uom_code INTO v_to_uom_code;
      CLOSE c_get_uom_code;

      lv_statement_id := '6';
      OPEN c_get_uom_code(r_base_trx.unit_of_measure);
      FETCH c_get_uom_code INTO v_from_uom_code;
      CLOSE c_get_uom_code;

      lv_statement_id := '7';
      inv_convert.inv_um_conversion(v_from_uom_code,v_to_uom_code,v_item_id,v_uom_rate);
      -- bug#3644848
      v_uom := r_base_trx.unit_of_measure; -- added by sriram - bug # 3446045

      OPEN  c_get_uom_code(v_uom);
      FETCH c_get_uom_code INTO v_uom;
      CLOSE c_get_uom_code;

      lv_statement_id := '8';
      OPEN  c_assembly_id(v_wip_entity);
      FETCH c_assembly_id INTO v_assembly;
      CLOSE c_assembly_id;

      OPEN  c_osp_days;
      FETCH c_osp_days INTO v_process_time, v_excise_rate;
      CLOSE c_osp_days;

      lv_statement_id := '9';
      OPEN c_item_value(v_item_id,v_uom);
      FETCH c_item_value INTO v_unit_price;
      CLOSE c_item_value;

      OPEN v_vend_info(v_po_header);
      FETCH v_vend_info INTO v_vendor_site;
      CLOSE v_vend_info;

      lv_statement_id := '10';
      IF v_unit_price IS NULL THEN
        lv_statement_id := '11';
        OPEN  c_item_value1(v_item_id,v_uom);
        FETCH c_item_value1 INTO v_unit_price;
        CLOSE c_item_value1;

        IF v_unit_price IS NULL THEN
           v_unit_price := v_po_unit_price * nvl(v_uom_rate,1);  -- ssumaith - 3644848
        END IF;

      END IF;

      lv_statement_id := '12';

      lv_source :=  'RETURN TO VENDOR' ;
      INSERT INTO JAI_PO_OSP_HDRS (
        FORM_ID,
        OTH_DOC_ID,
        PO_HEADER_ID,
        VENDOR_ID,
        VENDOR_SITE_ID,
        PROCESS_TIME,
        ORGANIZATION_ID,
        LOCATION_ID,
        SOURCE,
        ISSUE_APPROVED,
        RECEIPT_APPROVED,
        CANCEL_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        PRIMARY_FORM_ID   -- cbabu for Bug# 2746952
      ) VALUES (
        JAI_PO_OSP_HDRS_S.nextval,
        v_po_release_id,
        v_po_header,
        v_vendor,
        v_vendor_site,
        v_process_time,
        v_org_id,
        v_loc_id,
        lv_source, --'RETURN TO VENDOR', /* Modified by Ramananda for removal of SQL LITERALs :bug#4428980*/
        'N',
        'N',
        'N',
        v_last_upd_dt,
        v_last_upd_by,
        v_creation_dt,
        v_created_by,
        v_last_upd_lgin,
        v_primary_form_id -- cbabu for Bug# 2746952
      ) RETURNING form_id into v_form_id;

      lv_statement_id := '14';
      INSERT INTO JAI_PO_OSP_LINES (
          FORM_ID,
          LINE_ID,
          PO_LINE_ID,
          PO_DISTRIBUTION_ID,
          ITEM_ID,
          WIP_ENTITY_ID,
          WIP_LINE_ID,
          WIP_REPETITIVE_SCHEDULE_ID,
          WIP_OPERATION_SEQUENCE_NUM,
          ASSEMBLY_ID,
		  ORIGINAL_QTY, /* added for bug 8678948 by vumaasha */
          DESPATCH_QTY,
          ITEM_UOM,
          ITEM_VALUE,
          TARIFF_CODE,
          EXCISE_RATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_LOGIN,
          PARENT_ITEM_ID,
          COMP_QTY_PA,
          BAL_PARENT_ITEM_QTY,
          SOURCE_CODE
      ) VALUES(
          v_form_id,
          JAI_PO_OSP_LINES_S.nextval,
          v_po_line,
          v_po_dist,
          v_item_id,
          v_wip_entity,
          v_wip_line,
          v_wip_sch,
          v_wip_oprn,
          v_assembly,
		  v_issue_qty,/* added for bug 8678948 vumaasha */
          v_issue_qty,
          v_uom,
          v_unit_price ,
          v_item_tariff ,
          NVL(v_excise_rate,0),
          v_last_upd_dt,
          v_last_upd_by,
          v_created_by,
          v_creation_dt,
          v_last_upd_lgin,
          v_item_id,
          1,
          v_issue_qty,
          v_source_code
      ) RETURNING line_id into v_line_id;

    END IF;

  END IF;

  p_process_status := jai_constants.successful;

  EXCEPTION
    WHEN OTHERS THEN
      p_process_status  := jai_constants.unexpected_error;
      p_process_message := 'Error in jai_po_osp_pkg.create_rcv_57f4. Stmt:'||lv_statement_id
                            ||', MSG:'||SQLERRM;

  END create_rcv_57f4;
/*------------------------------------------------------------------------------------------------------------*/
  PROCEDURE update_57f4_on_receiving
  (
    p_shipment_header_id  NUMBER,
    p_shipment_line_id    NUMBER,
    p_to_organization_id  NUMBER,
    p_ship_to_location_id NUMBER,
    p_item_id       NUMBER,
    p_tran_type           RCV_TRANSACTIONS.transaction_type%TYPE,
    p_rcv_tran_qty          RCV_TRANSACTIONS.quantity%TYPE,
    p_new_primary_unit_of_measure RCV_SHIPMENT_LINES.primary_unit_of_measure%TYPE,
    p_old_primary_unit_of_measure RCV_SHIPMENT_LINES.primary_unit_of_measure%TYPE,
    p_unit_of_measure       RCV_SHIPMENT_LINES.unit_of_measure%TYPE,
    p_po_header_id      NUMBER,
    p_po_release_id     NUMBER,
    p_po_line_id      NUMBER,
    p_po_line_location_id   NUMBER,
    p_last_updated_by   NUMBER,
    p_last_update_login   NUMBER,
    p_creation_date     DATE
  )
  IS

     v_debug      BOOLEAN; --File.Sql.35 Cbabu  := false;
     v_myfilehandle UTL_FILE.FILE_TYPE;
     v_utl_file_name  VARCHAR2(100); --File.Sql.35 Cbabu  := 'update_57f4_on_receiving.log';
     v_utl_location VARCHAR2(512);
     v_po_uom         po_line_locations_all.unit_meas_lookup_code%type;

     CURSOR c_po_uom is
       select unit_meas_lookup_code
       from   po_line_locations_all
       where  line_location_id = p_po_line_location_id;

     CURSOR c_po_line_uom is
       select unit_meas_lookup_code
       from   po_lines_all
       where  po_line_id = p_po_line_id;


     --**********TO GET COUNT OF EXISTING 57F4'S**********
     CURSOR c_count_primary_57f4 IS
        SELECT count(1)
        FROM  JAI_PO_OSP_HDRS
        WHERE
        -- nvl(receipt_approved,'N') != 'Y' AND - sriram - bug# 3303027
           cancel_flag = 'N'
        AND   trunc(issue_date) + NVL(process_time,0) >= trunc(sysdate) -- NVL Condition added by sriram - bug# 3021456
        AND   po_header_id = p_po_header_id
        AND   (oth_doc_id IS NULL OR oth_doc_id = p_po_release_id)
        AND   organization_id = p_to_organization_id
        AND   location_id = p_ship_to_location_id
        -- AND   (source = 'PURCHASE ORDER' OR source = 'PO RELEASE' OR source = 'RETURN TO VENDOR')
        AND   NVL(primary_flag,'N') = 'Y'; --added on 06-jan-2000 gaurav.

     --**********TO GET THE FORM ID**********
     CURSOR c_get_primary_form_id IS
        SELECT form_id
        FROM JAI_PO_OSP_HDRS
        WHERE
        --nvl(receipt_approved,'N') != 'Y' AND - sriram - bug# 3303027
        cancel_flag = 'N'
        AND   trunc(issue_date) + NVL(process_time,0) >= trunc(sysdate)
        AND   po_header_id = p_po_header_id
        AND   (oth_doc_id IS NULL OR oth_doc_id = p_po_release_id)
        AND   organization_id = p_to_organization_id
        AND   location_id = p_ship_to_location_id
        -- AND   (source = 'PURCHASE ORDER' OR source = 'PO RELEASE' OR source = 'RETURN TO VENDOR')
        AND   NVL(primary_flag,'N') = 'Y'; --added on 06-jan-2000 gaurav.

     --**********FETCHING VALUES FROM RCV_TRANSACTIONS**********
     CURSOR c_get_rcv_trans IS
        SELECT wip_entity_id
        FROM po_distributions_all
        WHERE line_location_id = p_po_line_location_id
        AND rownum = 1;

    -- 2746952
    v_match_type NUMBER(1); --File.Sql.35 Cbabu  := 1;

     --**********FETCHING ALL LINES FROM JAIN57F4********
     -- CURSOR c_get_lines(v_primary_form_id Number, v_wip_entity_id Number) IS
     CURSOR c_get_lines(p_form_id Number) IS
        SELECT form_id, line_id, parent_item_id, item_id, bal_parent_item_qty,
           comp_qty_pa, despatch_qty, return_qty, item_uom, po_distribution_id
           -- 2746952
           -- , ( despatch_qty - NVL(return_qty,0)) / comp_qty_pa  balance_qty
           , decode( v_match_type, 1, despatch_qty - NVL(return_qty,0), return_qty ) / comp_qty_pa  balance_qty
           , despatch_qty / comp_qty_pa  despatch_parent_item_qty
           -- , po_line_id
        FROM JAI_PO_OSP_LINES
        WHERE form_id = p_form_id
        -- AND bal_parent_item_qty > 0
        -- 2746952
        AND ( ( v_match_type = 1 AND ( despatch_qty - NVL(return_qty,0) ) > 0 )
            OR
            ( v_match_type = -1 AND return_qty > 0 )
            )
        AND po_line_Id = p_po_line_id
        AND nvl(comp_qty_pa,0) <> 0 --vkaranam for bug#4607506
        -- AND wip_entity_id = v_wip_entity_id
        -- ORDER BY form_id, po_line_id;
        ORDER BY form_id, line_id;


     --*********FETCHING UNIT OF MEASURE************
     CURSOR c_get_uom(um varchar2) IS
        Select unit_of_measure
        FROM mtl_units_of_measure
        WHERE uom_code = um;

         -- sriram - bug # 3021456
    cursor c_po_qty_cur(p_po_hdr_id number , p_po_line_id number)  is
         select quantity_ordered
         from   po_distributions_all
         where  po_header_id = p_po_hdr_id
         and    po_line_id   = p_po_line_id;

    v_item_pr_uom_code  mtl_system_items.primary_uom_code%TYPE;     -- eg. Ea
    v_item_pr_uom   mtl_system_items.primary_unit_of_measure%TYPE;  -- eg. Each

    CURSOR c_item_pr_uom( p_organization_id IN NUMBER, p_inv_item_id IN NUMBER) IS
      SELECT primary_uom_code, primary_unit_of_measure
      FROM mtl_system_items
      WHERE organization_id = p_organization_id
      AND inventory_item_id = p_inv_item_id;

     --**********VARIABLE DECLARATION**********
     v_count_57f4       Number;
     v_primary_form_id          Number;
     v_wip_entity_id    Number;

     v_org_id           Number; --File.Sql.35 Cbabu  := p_to_organization_id;
     v_loc_id           Number; --File.Sql.35 Cbabu  := p_ship_to_location_id;

     v_received_qty     Number; --Added by Satya for Receipt Corrections   21/06/2001
     v_temp_qty         Number;
     v_left_received_qty  Number;
     v_bal_qty          Number;
     v_return_qty       Number; --File.Sql.35 Cbabu := 0;


    v_comp_qty_pa NUMBER;
    v_comp_balance_qty NUMBER;
    v_despatch_parent_qty NUMBER;
    v_form_fully_available BOOLEAN; --File.Sql.35 Cbabu  := false;

     v_po_to_rec_conv     Number;
     v_pr_to_57f4_line_conv Number;

     v_to_uom           Varchar2(20);
     v_temp_rcvd_qty    Number;
     v_left_qty         Number;

    v_tran_type    Varchar2(25); --File.Sql.35 Cbabu  := p_tran_type;

    vFormId_ToBeUpdWithRegDate NUMBER;

    v_po_qty number;
    v_ret_fact number;
    v_creation_date DATE;

    /* Start, Vijay Shankar for Bug#3644845 */
    TYPE cNumberTable IS TABLE of NUMBER INDEX BY BINARY_INTEGER;
    vQtyRemaining   cNumberTable;
    v_fun_ret_value   NUMBER;
    v_quantity_applied  NUMBER;

    lv_object_name CONSTANT VARCHAR2 (61) := 'jai_po_osp_pkg.update_57f4_on_receiving';

    /* Bug 7028169. Added by Lakshmi Gopalsami */
   CURSOR c_get_item_details(cp_org_id NUMBER, cp_item_id NUMBER) IS
   SELECT *
   FROM   mtl_system_items
   WHERE  organization_id = cp_org_id
   AND    inventory_item_id = cp_item_id;

   r_get_po_item_details c_get_item_details%ROWTYPE;
    lv_item_unit_type  VARCHAR2(25);

    FUNCTION processCompBalances(pEvent IN NUMBER,
                                 pItemId IN NUMBER,
                                 pQtyToApply IN NUMBER
                                 -- Bug 7028169. Added by Lakshmi Gopalsami
				 ,pPoQty IN NUMBER
                                 ,pItemUnitType IN VARCHAR2
                                 ) RETURN NUMBER IS

      /* Functionality of this Function
       pEvent = 0, plsql table initialization event.
        Allowed parameter values during this event,
          pItemId should be PRIMARY 57F4 FORM_ID,   pQtyToApply = received_quantity

       pEvent = 1, during this event quantity has to be reduced/added for specified item. Called when 57F4 forms other than RTV
        is being matched(applied)
        Allowed parameter values during this event,
          pItemId   = item_id being processed,    pQtyToApply = quantity to be reduced/added for item

       pEvent = 2(RTV), during this event pQtyToApply should be reduced/added for all items of plsql tablem, because this is called
        when 57F4 forms created by RTV is being applied
        Allowed parameter values during this event,
          pItemId   = <value not considered>,   pQtyToApply = quantity to be reduced/added for all items (i.e quantity applied on 57F4 form created during RTV)

       pEvent = 3, calling procedure is expecting the qty remaining of item specified
        Allowed parameter/return values during this event,
          pItemId   = item_id being processed,    pQtyToApply = <value not considered>
          vReturnValue return quantity remaining for item

       pEvent = 4(RTV), calling procedure is expecting the qty remaining to apply, when 57f4 form created by RTV is being applied
        (balance of any item can be returned)
        Allowed parameter/return values during this event,
          pItemId   = <value not considered>,   pQtyToApply = <value not considered>
          vReturnValue return quantity remaining for first item

       pEvent = 5, calling procedure is asking whether all received quantity is appied onto 57F4 forms or not
        Allowed parameter values during this event,
          pItemId   = <value not considered>,   pQtyToApply = <value not considered>
          vRerurnValue = 0 If fully applied else -1
       Always
        vReturnValue = 0 indicates success
        and vReturnValue = -1 indicates Error
      */

      vItemId     NUMBER(15);
      vReturnValue  NUMBER;
      vProQty  NUMBER;
    BEGIN


      IF pEvent = 0 THEN
        FOR ii IN  /* Bug 7028169. Added by Lakshmi Gopalsami
	             * selected all the values
	             */
                   (SELECT *
                     FROM JAI_PO_OSP_LINES WHERE form_id = pItemId AND po_line_id = p_po_line_id) LOOP
          /* Bug 7028169. Added by Lakshmi Gopalsami
	   * Added logic for initializing the pl/sql table for
	   * resource unit type
           * We need to proportionate the receipt quantity
	   * with that of PO qty and 57F4 despatch qty
           */
	    IF r_get_po_item_details.outside_operation_uom_type ='RESOURCE'
	      AND ii.source_code ='W' THEN
	       vProQty := (ii.original_qty/ pPoQty) * pQtyToApply;
	       vQtyRemaining(ii.item_id) := vProQty;
            ELSE
               vQtyRemaining(ii.item_id) := pQtyToApply;
	    END IF ;

        END LOOP;

      ELSIF pEvent = 1 THEN
        vQtyRemaining(pItemId) := vQtyRemaining(pItemId) - pQtyToApply;

      ELSIF pEvent = 2 THEN
        vItemId := vQtyRemaining.FIRST;
        WHILE vItemId IS NOT NULL LOOP
          vQtyRemaining(vItemId) := vQtyRemaining(vItemId) - pQtyToApply;
          vItemId := vQtyRemaining.NEXT(vItemId);
        END LOOP;

      ELSIF pEvent = 3 THEN
        vReturnValue := vQtyRemaining(pItemId);

      ELSIF pEvent = 4 THEN
        vItemId := vQtyRemaining.FIRST;
        IF vItemId IS NOT NULL THEN
          vReturnValue := vQtyRemaining(vItemId);
        ELSE
          vReturnValue := 0;
        END IF;

      ELSIF pEvent = 5 THEN
        vItemId := vQtyRemaining.FIRST;
        WHILE vItemId IS NOT NULL LOOP
          IF vQtyRemaining(vItemId) <> 0 THEN
            vReturnValue := -1;
            exit;
            else
                vReturnValue := 0;
            END IF;
          vItemId := vQtyRemaining.NEXT(vItemId);
        END LOOP;

      END IF;

      RETURN vReturnValue;

    END processCompBalances;
    /* End, Vijay Shankar for Bug#3644845 */

  BEGIN

  /*------------------------------------------------------------------------------------------
  CHANGE HISTORY:     FILENAME: ja_in_update_57F4.sql
  S.No      Date     Author and Details
  ------------------------------------------------------------------------------------------
   1  01-JUN-2001   Satya Added DUAL UOM functionality

   2   29-OCT-2002    Nagaraj.s for Bug2643016
                       As Functionally required, an Update statement is written to update the CR_REG_ENTRY_DATE of
                       the ja_in_57f4_table. This will definitely have implications on Approve 57f4 receipt screen on
                       Modvat claim but since no Modvat claim is available for 57f4 register, this has been approved
                       functionally.
   3   22-JAN-2003    cbabu for Bug#2746952, FileVersion# 615.2
                       During the RETURN TO VENDOR transaction for the shipment line, the code is getting executed and
                       return quantity is getting updated. This is happening when a partial receipt is made and then RTV
                       is made for the same
   4. 08-JAN-2004     ssumaith - bug# 3303027 File Version # 618.1

                       When the primary form is receipt_approved = 'Y' , when a receipt is made , return_quantity
                       field does not get updated for the RTV OSP form . There is a check in this procedure which
                       is preventing the entry of control into the code paths which update the RTV form.

   5. 01-mar-2004     ssumaith - bug# 3446045 file version 618.2.

                       unit_meas_lookup_code column in the po_line_locations_all table is null in the clients
                       instance . The value in this field is being used as a basis of uom comparison. This
                       is causing wrong uom conversion and return quantuty is not getting updated correctly
                       when uom is changed.

                       This has been corrected by using the unit_meas_lookup_code of the po_lines_all table
                       in case the value retreived from the po_line_locations_all table is null.

  6  03-JUN-2004    Vijay Shankar for Bug# 3644845, Version:115.1
             return quantity is not getting updated when one of the OSP component is sent through Secondary form because the
             code assumes that the components related to n OSP items will be sent in one form. Now the code is modified by
             adding an internal function processCompBalances and calling it from code during following events
               1) before main processing loop for initialization of comp balances to be updated on 57f4 lines
               2) after every form, whether any balances for components are left
               3) start of each line being processed, for remaining quantity to be applied on 57f4 line
               4) end of lines loop to update plsql table with quantity applied onto the line
             New function is written as a central code which manages the component quantities remaining to be applied onto 57f4 lines
  --------------------------------------------------------------------------------------------*/

  /*
  --File.Sql.35 Cbabu
  v_utl_file_name  := 'update_57f4_on_receiving.log';

  IF v_debug THEN
     BEGIN

        SELECT DECODE(SUBSTR (value,1,INSTR(value,',') -1),NULL, Value,SUBSTR (value,1,INSTR(value,',') -1))
           INTO v_utl_location
        FROM v$parameter WHERE name = 'utl_file_dir';

        v_myfilehandle := UTL_FILE.FOPEN(v_utl_location, v_utl_file_name, 'A');

     EXCEPTION
        WHEN OTHERS THEN
           v_debug := FALSE;
     END;
  END IF;
  */

 --File.Sql.35 Cbabu
  v_debug := false;
  v_match_type  := 1;
 v_org_id      := p_to_organization_id;
 v_loc_id    := p_ship_to_location_id;
     v_return_qty       := 0;
    v_form_fully_available  := false;
    v_tran_type     := p_tran_type;

  IF v_debug THEN
      jai_cmn_utils_pkg.print_log(v_utl_file_name,'*******START Time Stamp*******' ||TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS')
      ||' Transaction Type is ' || v_tran_type
     );
  END IF;

  v_received_qty := p_rcv_tran_qty;

  -- 2746952
  IF p_rcv_tran_qty >= 0 THEN
    v_match_type := 1;
  ELSE
    v_match_type := -1;
  END IF;

  OPEN  c_get_rcv_trans;
  FETCH c_get_rcv_trans INTO v_wip_entity_id;
  CLOSE c_get_rcv_trans;

  IF v_debug THEN
     jai_cmn_utils_pkg.print_log(v_utl_file_name,'1 line_location_id -> '|| p_po_line_location_id
        ||', v_wip_entity_id -> '|| v_wip_entity_id
     );
  END IF;

  OPEN c_count_primary_57f4;
  FETCH c_count_primary_57f4 INTO v_count_57f4;
  CLOSE c_count_primary_57f4;

  IF v_debug THEN
     jai_cmn_utils_pkg.print_log(v_utl_file_name,'2 po_header_id -> '|| p_po_header_id
        ||', po_release_id -> '|| p_po_release_id ||', to_organization_id -> '|| p_to_organization_id
        ||', ship_to_location_id -> '|| p_ship_to_location_id ||', v_count_57f4 -> '|| v_count_57f4
        ||', shipment_header_id -> '|| p_shipment_header_id ||', shipment_line_id -> '|| p_shipment_line_id
        ||', v_tran_type -> '|| v_tran_type ||', v_received_qty -> '|| v_received_qty
        ||', po_line_id -> '|| p_po_line_id
     );
  END IF;

  /* Bug 7028169. Added by Lakshmi Gopalsami
   * Get the details of unit_type of PO OSP item.
   */
  OPEN c_get_item_details(p_to_organization_id,p_item_id);
    FETCH c_get_item_details INTO r_get_po_item_details;
  CLOSE c_get_item_details;

  IF (v_match_type = 1 AND v_received_qty > 0) OR (v_match_type = -1 AND v_received_qty < 0) THEN

    IF v_count_57f4 = 1 THEN

     OPEN c_get_primary_form_id;
     FETCH c_get_primary_form_id INTO v_primary_form_id;
     CLOSE c_get_primary_form_id;

    open  c_po_qty_cur(p_po_header_id , p_po_line_id);
    fetch c_po_qty_cur into v_po_qty;
    close c_po_qty_cur;

    IF v_debug THEN
      jai_cmn_utils_pkg.print_log(v_utl_file_name,'3 v_primary_form_id -> '|| v_primary_form_id
        ||', v_received_qty -> '|| v_received_qty
        ||', v_po_qty -> '|| v_po_qty
      );
    END IF;

    open  c_po_uom;
    fetch c_po_uom into v_po_uom;
    close c_po_uom;

    IF v_debug THEN
        jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.122 v_po_uom -> '|| v_po_uom);
    END IF;

    -- added for bug#3446045  - sriram
    if v_po_uom is null then
       open  c_po_line_uom;
       fetch c_po_line_uom into v_po_uom;
       close c_po_line_uom;
    end if;

      -- ends here additions for bug# 3446045

      IF v_debug THEN
        jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.123 v_po_uom -> '|| v_po_uom);
    END IF;

    -- Determines the conversion factor between PO and RECEIPT uom's if they are different
    if v_po_uom <> p_unit_of_measure then

      v_po_to_rec_conv := INV_CONVERT.INV_UM_CONVERT
              (p_item_id, NULL, NULL, NULL, NULL,
                p_unit_of_measure, v_po_uom);

      IF v_debug THEN
        jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.124 v_po_uom -> '|| v_po_uom
          ||', p_unit_of_measure -> '|| p_unit_of_measure
          ||', v_po_to_rec_conv -> '|| nvl(v_po_to_rec_conv, -1275)
        );
      END IF;

      IF v_po_to_rec_conv < 0 OR v_po_to_rec_conv IS NULL THEN
        v_po_to_rec_conv := 1;
      END IF;

    ELSE
      v_po_to_rec_conv := 1;
    end if;

    -- this takes care if there is UOM Change beteen PO and RECEIPT
    v_received_qty := v_received_qty * v_po_to_rec_conv;

  v_left_received_qty := v_received_qty;

  -- v_fun_ret_value :=
  -- Initialize PLSQL table, Vijay Shankar for Bug# 3644845
  v_fun_ret_value := processCompBalances(0,
                     v_primary_form_id, v_received_qty
		     -- Bug 7028169. Added by Lakshmi Gopalsami
		     ,v_po_qty
                     ,r_get_po_item_details.outside_operation_uom_type);

  FOR each_form IN
    (
      SELECT '1' seq, form_id, source, form_id*v_match_type order_by
      FROM JAI_PO_OSP_HDRS
      WHERE form_id = v_primary_form_id

      UNION

      SELECT '2' seq, form_id, source, form_id*v_match_type order_by
      FROM JAI_PO_OSP_HDRS
      WHERE primary_form_id = v_primary_form_id
      AND NVL(receipt_approved,'N') <> 'Y'
      AND issue_approved = 'Y'
      ORDER BY order_by

    )
  LOOP

    vFormId_ToBeUpdWithRegDate := null;

    FOR each_line in c_get_lines(each_form.form_id) LOOP

      v_ret_fact := 1;

      --Start, Vijay Shankar for Bug# 3644845
      IF each_form.source = 'RETURN TO VENDOR' THEN
        v_received_qty := processCompBalances(4, null, null
 		          -- Bug 7028169. Added by Lakshmi Gopalsami
			  ,v_po_qty
                          ,r_get_po_item_details.outside_operation_uom_type);

      ELSE
        v_received_qty := processCompBalances(3, each_line.item_id,null
	                  -- Bug 7028169. Added by Lakshmi Gopalsami
			  ,v_po_qty
                          ,r_get_po_item_details.outside_operation_uom_type);
      END IF;
      --End, Vijay Shankar for Bug# 3644845

      OPEN c_item_pr_uom(p_to_organization_id, each_line.item_id);
      FETCH c_item_pr_uom INTO v_item_pr_uom_code, v_item_pr_uom;
      CLOSE c_item_pr_uom;

      -- Determines the conversion factor between Component Primary UOM and 57F4 Line uom's if they are different
      if v_item_pr_uom_code <> each_line.item_uom then

        v_pr_to_57f4_line_conv := INV_CONVERT.INV_UM_CONVERT
                (each_line.item_id, NULL, NULL, v_item_pr_uom_code, each_line.item_uom,
                  null, null);
                  -- p_unit_of_measure, v_to_uom);

        IF v_debug THEN
          jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.1x2 v_po_uom -> '|| v_po_uom
            ||', v_to_uom -> '|| v_to_uom
            ||', v_pr_to_57f4_line_conv -> '|| nvl(v_pr_to_57f4_line_conv, -1275)
          );
        END IF;

        IF v_pr_to_57f4_line_conv < 0 OR v_pr_to_57f4_line_conv IS NULL THEN
          v_pr_to_57f4_line_conv := 1;
        END IF;

      ELSE
        v_pr_to_57f4_line_conv := 1;
      end if;

      v_comp_qty_pa := each_line.comp_qty_pa * v_pr_to_57f4_line_conv;
      v_despatch_parent_qty := each_line.despatch_qty / v_comp_qty_pa ;
      IF v_match_type = 1 THEN
        v_comp_balance_qty  := (each_line.despatch_qty - NVL(each_line.return_qty,0)) / v_comp_qty_pa ;
      ELSE
        v_comp_balance_qty  := NVL(each_line.return_qty, 0) / v_comp_qty_pa ;
      END IF;

        IF v_debug THEN
           jai_cmn_utils_pkg.print_log(v_utl_file_name,'4 form_id -> '|| each_line.form_id
              ||', line_id -> '|| each_line.line_id ||', parent_item_id -> '|| each_line.parent_item_id
              ||', item_id -> '|| each_line.item_id ||', bal_parent_item_qty -> '|| each_line.bal_parent_item_qty
              ||', comp_qty_pa -> '|| each_line.comp_qty_pa ||', despatch_qty -> '|| each_line.despatch_qty
              ||', return_qty -> '|| each_line.return_qty ||', item_uom -> '|| each_line.item_uom
           );
           jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.1.1 unit_of_measure -> '|| p_unit_of_measure
              ||', primary_unit_of_measure -> '|| p_new_primary_unit_of_measure ||', item_id -> '|| p_item_id
              ||', v_temp_rcvd_qty -> '|| v_temp_rcvd_qty ||', v_received_qty -> '|| v_received_qty
              ||', bal_qty -> '|| each_line.balance_qty ||', des_par_itm_qty -> '|| each_line.despatch_parent_item_qty
              ||', bal_par_itm_qty -> '|| each_line.bal_parent_item_qty ||', v_match_type -> '|| v_match_type

           );
           jai_cmn_utils_pkg.print_log(v_utl_file_name,'4.4 v_comp_qty_pa -> '|| v_comp_qty_pa
                     ||', v_despatch_parent_qty -> '|| v_despatch_parent_qty
                     ||', v_comp_balance_qty -> '|| v_comp_balance_qty
                  ||', v_pr_to_57f4_line_conv -> '|| v_pr_to_57f4_line_conv
        );
        END IF;


           v_bal_qty := v_comp_balance_qty;

       IF v_match_type = 1 THEN   -- this handles +ve quantity RECEIVE / CORRECTed through RCV_TRANSACTIONS base form

         IF v_bal_qty >= v_received_qty THEN
          v_temp_qty := v_received_qty * v_comp_qty_pa;
          v_left_received_qty := 0;

          v_quantity_applied := v_received_qty; -- Vijay Shankar for Bug# 3644845, full received quantity applied
          v_bal_qty := v_bal_qty - v_received_qty;

         ELSE
          v_temp_qty := v_bal_qty * v_comp_qty_pa;
          v_left_received_qty := v_received_qty - v_bal_qty;

          v_quantity_applied := v_bal_qty;      -- Vijay Shankar for Bug# 3644845, quantity on 57F4 line is Complete. Should update next 57F4 line with remaining qty
          v_bal_qty := 0;

         END IF;

      -- 2746952
      -- this handles -ve quantity CORRECTed through RCV_TRANSACTIONS base form
      ELSIF v_match_type = -1 THEN

         -- v_bal_qty is +ve and v_received_qty is -ve if code enters this path
         -- v_bal_qty is assigned with return_qty in this case

         IF v_bal_qty > abs(v_received_qty) THEN
          v_temp_qty := v_received_qty * v_comp_qty_pa;
          v_left_received_qty := 0;

          v_quantity_applied := v_received_qty; -- Vijay Shankar for Bug# 3644845, full received quantity applied
          v_bal_qty := v_bal_qty + v_received_qty;
         ELSE
          v_temp_qty := (v_bal_qty * v_match_type) * v_comp_qty_pa;
          v_left_received_qty := v_received_qty + v_bal_qty;

          v_quantity_applied := -v_bal_qty;     -- Vijay Shankar for Bug# 3644845, quantity on 57F4 line is Complete. Should update next 57F4 line with remaining qty
          v_bal_qty := v_despatch_parent_qty;
         END IF;

      END IF;

      -- this will be useful incase of only -ve quantity CORRECTion's
      IF v_bal_qty = v_despatch_parent_qty THEN
        v_form_fully_available := true;
      END IF;

           v_return_qty := v_temp_qty;
  --------

           IF v_debug THEN
              jai_cmn_utils_pkg.print_log(v_utl_file_name,'5.1 v_bal_qty -> '|| v_bal_qty
                 ||', v_return_qty -> '|| v_temp_qty||', v_left_received_qty -> '|| v_left_received_qty
              );
           END IF;

           UPDATE JAI_PO_OSP_LINES
           SET return_qty = round((nvl(return_qty,0) + nvl(v_ret_fact,1) * v_return_qty), 5),
              bal_parent_item_qty = v_bal_qty,
              last_update_date = sysdate,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login
           where line_id = each_line.line_id;

      --Start, Vijay Shankar for Bug# 3644845
      IF each_form.source = 'RETURN TO VENDOR' THEN
        v_fun_ret_value := processCompBalances(2, null, nvl(v_quantity_applied,0)
			   -- Bug 7028169. Added by Lakshmi Gopalsami
			   ,v_po_qty
			   ,r_get_po_item_details.outside_operation_uom_type);
      ELSE
        v_fun_ret_value := processCompBalances(1, each_line.item_id, nvl(v_quantity_applied,0)
   		           -- Bug 7028169. Added by Lakshmi Gopalsami
			   ,v_po_qty
			   ,r_get_po_item_details.outside_operation_uom_type);
      END IF;
      --End, Vijay Shankar for Bug# 3644845

           IF v_debug THEN
              jai_cmn_utils_pkg.print_log(v_utl_file_name,'5.3 updatedCount -> '|| SQL%ROWCOUNT
                ||', v_left_received_qty -> '|| v_left_received_qty
         );
       END IF;

           v_return_qty := 0;
      v_comp_qty_pa := null;
      v_despatch_parent_qty := null;
      v_comp_balance_qty := null;
      v_quantity_applied := null;

      vFormId_ToBeUpdWithRegDate := each_form.form_id;

       END LOOP;

     -- following if condition will get satisfied when balance is available on form which got
     -- updated with this RECEIPT/CORRECT transaction
     IF vFormId_ToBeUpdWithRegDate IS NOT NULL THEN
      IF v_form_fully_available THEN
        v_creation_date := null;
      ELSE
        v_creation_date := p_creation_date;
      END IF;

      UPDATE JAI_PO_OSP_HDRS
      SET CR_REG_ENTRY_DATE = v_creation_date
      WHERE form_id = vFormId_ToBeUpdWithRegDate;

     END IF;

    -- If condition added by Vijay Shankar for Bug# 3644845
    IF processCompBalances(5, null, null
                          -- Bug 7028169. Added by Lakshmi Gopalsami
			  ,v_po_qty
                          ,r_get_po_item_details.outside_operation_uom_type) = 0 THEN
      -- control comes here if all the received quantity is applied onto 57F4 forms
      EXIT;
    END IF;

     /* Vijay Shankar for Bug# 3644845
     EXIT WHEN v_left_received_qty = 0;
     v_received_qty := v_left_received_qty;
     */
     v_form_fully_available := false;

     END LOOP;

    END IF;

  END IF;

  IF v_debug THEN
     UTL_FILE.fclose(v_myfilehandle);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME ('JA','JAI_EXCEPTION_OCCURED');
    FND_MESSAGE.SET_TOKEN ('JAI_PROCESS_MSG',lv_object_name ||'.Err:'||sqlerrm);
    app_exception.raise_exception;

  END update_57f4_on_receiving;

END jai_po_osp_pkg;

/
