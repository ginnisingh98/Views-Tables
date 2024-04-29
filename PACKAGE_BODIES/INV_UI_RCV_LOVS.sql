--------------------------------------------------------
--  DDL for Package Body INV_UI_RCV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_UI_RCV_LOVS" AS
/* $Header: INVRCVLB.pls 120.31.12010000.21 2011/01/10 10:53:41 schiluve ship $ */

--      Name: GET_PO_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_number   which restricts LOV SQL to the user input text
--       p_manual_po_num_type  NUMERIC or ALPHANUMERIC
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_po_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns PO number for a given org
--

PROCEDURE GET_PO_LOV(x_po_num_lov OUT NOCOPY t_genref,
         p_organization_id IN NUMBER,
         p_po_number IN VARCHAR2,
         p_mobile_form IN VARCHAR2,
         p_shipment_header_id IN VARCHAR2)

   IS
   l_append varchar2(2):='';

BEGIN
   IF (WMS_DEPLOY.wms_deployment_mode='L') THEN --LSP
      l_append:='%';
   END IF;
   IF p_mobile_form = 'RCVTXN' THEN
      OPEN x_po_num_lov FOR

/*        SELECT DISTINCT poh.segment1
  , poh.po_header_id
  , poh.type_lookup_code
  , MO_GLOBAL.get_ou_name(poh.org_id)  --<R12 MOAC>
  , PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID)
  , poh.vendor_id
  , poh.vendor_site_id
  , 'Vendor'
  , poh.note_to_receiver
  , to_char(poh.org_id)               --<R12 MOAC>
  FROM rcv_supply ms
  , rcv_transactions rt
  , po_headers_all poh
  , po_lines_all pol
        , po_line_types plt
        , mtl_parameters mp
  WHERE poh.po_header_id = ms.po_header_id
  AND ms.quantity > 0
  AND ms.supply_type_code = 'RECEIVING'
  AND ms.to_organization_id = p_organization_id
  AND ms.supply_source_id = rt.transaction_id
  AND rt.organization_id = ms.to_organization_id
  AND rt.transaction_type <> 'UNORDERED'
  AND mp.organization_id = ms.to_organization_id
  AND poh.po_header_id = pol.po_header_id
  AND pol.line_type_id = plt.line_type_id
  AND (mp.wms_enabled_flag = 'N' OR (mp.wms_enabled_flag = 'Y'
             AND (plt.outside_operation_flag = 'Y'
            OR pol.item_id is NULL
            OR exists (SELECT 1
                 FROM mtl_system_items_kfv msik
                 WHERE msik.inventory_item_id = pol.item_id
                 AND msik.organization_id = p_organization_id
                 AND msik.mtl_transactions_enabled_flag = 'N'))))
        AND poh.segment1 LIKE (p_po_number)
        AND (exists
       (SELECT 1
          FROM rcv_transactions rt1
         WHERE rt1.transaction_id = rt.transaction_id
           AND rt1.inspection_status_code <> 'NOT INSPECTED'
           AND rt1.routing_header_id = 2)
       OR rt.routing_header_id <> 2
       OR rt.routing_header_id IS NULL)
  ORDER BY   decode(rtrim(poh.segment1,'0123456789'),null,null,poh.segment1),
  decode(rtrim(poh.segment1,'0123456789'),null,to_number(poh.segment1),null); --<R12 MOAC>  */

  /* Modified the above Query for Bug # 7113772. Removed the join from po_lines_all and po_line_types due to bad performance */

  SELECT DISTINCT poh.Segment1                            ,
        poh.po_Header_Id                                  ,
        poh.Type_LookUp_Code                              ,
        wms_deploy.get_po_client_name(poh.po_header_id)   ,--LSP
        MO_GLOBAL.get_ou_name(poh.org_id)                 ,--<R12 MOAC>
        po_Vendors_sv2.Get_vendor_name_func(poh.Vendor_Id),
        poh.Vendor_Id                                     ,
        poh.Vendor_Site_Id                                ,
        'Vendor'                                          ,
        poh.Note_To_Receiver                              ,
        to_char(poh.org_id)               --<R12 MOAC>

FROM    rcv_Supply ms      ,
        rcv_Transactions rt,
        po_Headers_trx_v poh , -- CLM, bug 9403291
        mtl_Parameters mp
WHERE   poh.po_Header_Id    = ms.po_Header_Id
    AND ms.Quantity         > 0
    AND ms.Supply_Type_Code = 'RECEIVING'
    AND ms.To_Organization_Id = p_organization_id
    AND ms.Supply_Source_Id  = rt.Transaction_Id
    AND rt.Organization_Id   = ms.To_Organization_Id
    AND rt.Transaction_Type <> 'UNORDERED'
    AND mp.Organization_Id   = ms.To_Organization_Id
    AND (mp.wms_Enabled_Flag = 'N'
     OR (mp.wms_Enabled_Flag = 'Y'
    AND ( EXISTS
        (SELECT 1
        FROM    po_Line_Types
        WHERE   Outside_Operation_Flag = 'Y'
            AND Line_Type_Id          IN
                (SELECT Line_Type_Id
                FROM    po_Lines_trx_v
                WHERE   po_Header_Id = poh.po_Header_Id
                )
        )
     OR EXISTS
        (SELECT 1
        FROM    po_Lines_trx_v -- CLM project, bug 9403291
        WHERE   po_Header_Id = poh.po_Header_Id
            AND Item_Id     IS NULL
        )
     OR EXISTS
        (SELECT 1
        FROM    mtl_System_Items_kfv msik
        WHERE   msik.Inventory_Item_Id IN
                (SELECT Item_Id
                FROM    po_Lines_trx_v
                WHERE   po_Header_Id = poh.po_Header_Id
                )
                AND msik.Organization_Id = p_organization_id
            AND msik.mtl_Transactions_Enabled_Flag = 'N'
        ))))
    AND poh.Segment1 LIKE (p_po_number||l_append)
    AND (EXISTS
        (SELECT 1
        FROM    rcv_Transactions rt1
        WHERE   rt1.Transaction_Id          = rt.Transaction_Id
            AND rt1.Inspection_Status_Code <> 'NOT INSPECTED'
            AND rt1.RoutIng_Header_Id       = 2
        )
     OR rt.RoutIng_Header_Id <> 2
     OR rt.RoutIng_Header_Id IS NULL )
  ORDER BY   decode(rtrim(poh.segment1,'0123456789'),null,null,poh.segment1),
  decode(rtrim(poh.segment1,'0123456789'),null,to_number(poh.segment1),null); --<R12 MOAC>


    ELSIF p_mobile_form = 'RECEIPT' THEN
      OPEN x_po_num_lov FOR

    SELECT DISTINCT poh.segment1
  , poh.po_header_id
  , poh.type_lookup_code
  , wms_deploy.get_po_client_name(poh.po_header_id)        --LSP
  , MO_GLOBAL.get_ou_name(poh.org_id)     --<R12 MOAC>
  , PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID)
  , poh.vendor_id
  , poh.vendor_site_id
  , 'Vendor'
  , poh.note_to_receiver
  , to_char(poh.org_id)                   --<R12 MOAC>
  FROM po_headers_trx_v poh      -- CLM project, bug 9403291
  WHERE exists (SELECT 'Valid PO Shipments'
            FROM po_line_locations_trx_v poll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
               , mtl_parameters mp,
                 rcv_parameters rp
--  End for Bug 7440217
           WHERE poh.po_header_id = poll.po_header_id
             AND Nvl(poll.approved_flag,'N') =  'Y'
             AND Nvl(poll.cancel_flag,'N') = 'N'
             AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
             AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
          AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
          AND mp.organization_id = p_organization_id
          AND rp.organization_id = p_organization_id
          AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                     OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                        OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
              )
--  End for Bug 7440217
          )
  AND poh.segment1 LIKE (p_po_number||l_append)
  AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
  AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
  AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
ORDER BY   decode(rtrim(poh.segment1,'0123456789'),null,null,poh.segment1),
  decode(rtrim(poh.segment1,'0123456789'),null,to_number(poh.segment1),null);--<R12 MOAC>

    ELSIF p_mobile_form = 'RCPTASN' THEN
      OPEN x_po_num_lov FOR

  SELECT DISTINCT poh.segment1
  , poh.po_header_id
  , poh.type_lookup_code
  , wms_deploy.get_po_client_name(poh.po_header_id)        --LSP
  , MO_GLOBAL.get_ou_name(poh.org_id)    --<R12 MOAC>
  , PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID)
  , poh.vendor_id
  , poh.vendor_site_id
  , 'Vendor'
  , poh.note_to_receiver
  , to_char(poh.org_id)                  --<R12 MOAC>
  FROM po_headers_trx_v poh              -- CLM project, bug 9403291
  , rcv_shipment_lines rsl
  WHERE exists (SELECT 'Valid PO Shipments'
          FROM po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
             , mtl_parameters mp,
               rcv_parameters rp
--  End for Bug 7440217
          WHERE poh.po_header_id = poll.po_header_id
          AND Nvl(poll.approved_flag,'N') =  'Y'
          AND Nvl(poll.cancel_flag,'N') = 'N'
          AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
          AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
          AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
          AND mp.organization_id = p_organization_id
          AND rp.organization_id = p_organization_id
          AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                     OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                        OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
              )
--  End for Bug 7440217
          )
  AND  poh.segment1 LIKE (p_po_number||l_append)
  AND poh.po_header_id = rsl.po_header_id
  AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
  AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
  AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
  AND rsl.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsl.shipment_header_id)
  ORDER BY Decode(rtrim(poh.segment1,'0123456789'),null,null,poh.segment1),
  Decode(rtrim(poh.segment1,'0123456789'),null,to_number(poh.segment1),null); --<R12 MOAC>

   ELSIF p_mobile_form = 'INSPECT' THEN
      OPEN x_po_num_lov FOR
      /*Bug: 4951739
      Modified query: Referencing base table instead of
      RCV_TRANSACTIONS_V
      */
      SELECT    DISTINCT poh.segment1   ,
              poh.po_header_id   ,
              poh.type_lookup_code   ,
              wms_deploy.get_po_client_name(poh.po_header_id)        ,--LSP
              MO_GLOBAL.get_ou_name(poh.org_id)   ,
              PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID)   ,
              poh.vendor_id   ,
              poh.vendor_site_id   ,
              'Vendor'   ,
              poh.note_to_receiver   ,
              to_char(poh.org_id)
      FROM    RCV_SUPPLY RSUP,
              RCV_TRANSACTIONS RT,
              PO_LOOKUP_CODES PLC,
              PO_LINES_trx_v pol, -- CLM project, bug 9403291
              PO_LINE_LOCATIONS_trx_v PLL,   -- CLM project, bug 9403291
              PO_HEADERS_trx_v POH,   -- CLM project, bug 9403291
              po_line_types plt,--BUG 5166887
              mtl_parameters mp --BUG 5166887
--  For Bug 7440217 Added RCV_PRAMETERS to find out if the organization is LCM enabled or not
            , rcv_parameters rp
--  End for Bug 7440217
      WHERE          RSUP.SUPPLY_TYPE_CODE                  =  'RECEIVING'
              AND    RT.TRANSACTION_TYPE                    <>  'UNORDERED'
              AND    RT.TRANSACTION_TYPE                    =  PLC.LOOKUP_CODE
              AND    PLC.LOOKUP_TYPE                        =  'RCV TRANSACTION TYPE'
              AND    RT.TRANSACTION_ID                      =  RSUP.RCV_TRANSACTION_ID
              AND    PLL.LINE_LOCATION_ID(+)                =  RSUP.PO_LINE_LOCATION_ID
              AND    NVL(PLL.MATCHING_BASIS(+),'QUANTITY')  <>  'AMOUNT'
              AND    PLL.PAYMENT_TYPE IS NULL
              AND    RSUP.po_header_id                =  poh.po_header_id
              AND    RSUP.to_organization_id          =  p_organization_id
              AND    RT.inspection_status_code        =  'NOT INSPECTED'
              AND    RT.routing_header_id             =  2  /* Inspection routing */
              AND    poh.segment1 LIKE (p_po_number||l_append)

              -- BUG 5166887: Do not return any rows if user access WMS org through the
              -- MSCA menu option
              AND    poh.po_header_id = pol.po_header_id
              AND    pol.line_type_id = plt.line_type_id
              AND    nvl(pol.item_id,-1) = nvl(rsup.item_id,-1)
              AND    mp.organization_id = p_organization_id
              AND    (mp.wms_enabled_flag = 'N'
                      OR (mp.wms_enabled_flag = 'Y'
                          AND (plt.outside_operation_flag = 'Y'
                               OR pol.item_id is NULL
                               OR exists (SELECT 1
                                          FROM mtl_system_items_kfv msik
                                          WHERE msik.inventory_item_id = pol.item_id
                                          AND msik.organization_id = p_organization_id
                                          AND msik.mtl_transactions_enabled_flag = 'N'))))
              -- END BUG 5166887
      ORDER BY   Decode(rtrim(poh.segment1,'0123456789'),          null,null,          poh.segment1),
                 Decode(rtrim(poh.segment1,'0123456789'),          null,to_number(poh.segment1),          null);  --<R12 MOAC>
   END IF;

END get_po_lov;



PROCEDURE GET_PO_RELEASE_LOV(x_po_release_num_lov OUT NOCOPY t_genref,
           p_organization_id IN NUMBER,
           p_po_header_id IN NUMBER,
           p_mobile_form IN VARCHAR2,
           p_po_release_num IN VARCHAR2)
  IS
 po_release_number VARCHAR2(20);
BEGIN
    BEGIN
       /* Start - Fix for Bug# 6640083 */
       -- po_release_number := to_char(to_number(p_po_release_num));
       -- This will convert String to number - Bug#6012703
       -- Commented the code for  Bug#6640083
       SELECT TRIM(LEADING '0' FROM p_po_release_num ) INTO po_release_number FROM Dual;
           -- This will trim leading zeroes - Bug#6640083
       /* End - Fix for Bug# 6640083 */
    EXCEPTION
     WHEN OTHERS then
       po_release_number := p_po_release_num;
    END;
   IF p_mobile_form = 'RECEIPT' THEN
      OPEN x_po_release_num_lov FOR
        select distinct pr.release_num
        , pr.po_release_id
        , pr.release_date
        from po_releases_all pr
        where pr.po_header_id = p_po_header_id
        --AND pr.org_id = p_organization_id
        and nvl(pr.cancel_flag, 'N') = 'N'
        and nvl(pr.approved_flag, 'N') <> 'N'
        and nvl(pr.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
        AND exists (SELECT 'Valid PO Shipments' --Added the exists to fix bug4350175
                    FROM po_line_locations_all poll
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                       , mtl_parameters mp,
                         rcv_parameters rp
--  End for Bug 7440217
                    WHERE pr.po_header_id = poll.po_header_id
                    AND pr.po_release_id = poll.po_release_id
                    AND Nvl(poll.approved_flag,'N') =  'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING','CLOSED')
                    AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
                    AND mp.organization_id = p_organization_id
                    AND rp.organization_id = p_organization_id
                    AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                   )
	AND pr.release_num LIKE (po_release_number)
        order by pr.release_num;
    ELSE
      OPEN x_po_release_num_lov FOR
        select distinct pr.release_num
        , pr.po_release_id
        , pr.release_date
        from rcv_supply rsup
        , po_releases_all pr
        where rsup.po_header_id = p_po_header_id
        --AND pr.org_id = p_organization_id
        and nvl(pr.cancel_flag, 'N') = 'N'
        and nvl(pr.approved_flag, 'N') <> 'N'
        AND rsup.po_release_id = pr.po_release_id
	AND pr.release_num LIKE (po_release_number)
        order by pr.release_num;
   END IF;
END GET_PO_RELEASE_LOV;



--      Name: GET_PO_LINE_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_header_id      which restricts LOV SQL to the PO
--       p_po_line_num which restricts the LOV to the user input text.
--
--      Output parameters:
--       x_po_line_num_lov returns LOV rows as reference cursor
--
--      Functions: This API returns PO Line numbers for a given PO
--
PROCEDURE GET_PO_LINE_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_po_header_id IN NUMBER,
            p_mobile_form IN VARCHAR2,
            p_po_line_num IN VARCHAR2)
  IS
  po_line_number VARCHAR2(20);
BEGIN
  -- Added for bug 9776756
  if PO_CLM_INTG_GRP.is_clm_po(p_po_header_id,null,null,null) = 'Y' THEN
     po_line_number := p_po_line_num;
  else
  -- End of Bug 9776756
    BEGIN
      /* Start - Fix for Bug# 6640083 */
       --  po_line_number := to_char(to_number(p_po_line_num));
       -- This will convert String to number - Bug#6012703
       -- Commented the code for  Bug#6640083
        SELECT TRIM(LEADING '0' FROM p_po_line_num ) INTO po_line_number FROM Dual;
           -- This will trim leading zeroes - Bug#6640083
       /* End - Fix for Bug# 6640083 */
     EXCEPTION
     WHEN OTHERS then
       po_line_number := p_po_line_num;
     END;
   END IF; -- bug 9776756

   IF p_mobile_form = 'RECEIPT' THEN
      OPEN x_po_line_num_lov FOR
  select distinct pl.line_num
             , pl.po_line_id
             --Bug 7274407
             , NVL(msi.description, pl.item_description)
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
       , msi.outside_operation_flag
  from po_lines_trx_v pl   -- CLM project, bug 9403291
             , mtl_system_items_vl msi
         where pl.item_id = msi.inventory_item_id (+)
           and Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and pl.po_header_id = p_po_header_id
     and exists (SELECT 'Valid PO Shipments'
                        FROM po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                           , mtl_parameters mp,
                             rcv_parameters rp
--  End for Bug 7440217
                       WHERE poll.po_header_id = pl.po_header_id
       AND poll.po_line_id = pl.po_line_id
                         AND Nvl(poll.approved_flag,'N') =  'Y'
                         AND Nvl(poll.cancel_flag,'N') = 'N'
             AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                         --AND poll.closed_code = 'OPEN'
                         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                         AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
                         AND mp.organization_id = p_organization_id
                         AND rp.organization_id = p_organization_id
                         AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                  OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                      OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                              )
--  End for Bug 7440217
                         )
           AND pl.line_num LIKE (po_line_number)
         order by 1;
    ELSE
      OPEN x_po_line_num_lov FOR
  select distinct pl.line_num
             , pl.po_line_id
             --Bug 7274407
             , NVL(msi.description, pl.item_description)
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
       , msi.outside_operation_flag
         -- bug 2805640
             , inv_ui_item_lovs.get_conversion_rate(mum.uom_code,
                                   p_organization_id,
                                   pl.Item_Id)
               uom_code
  FROM rcv_supply rsup
         -- bug 2805640
             , mtl_units_of_measure mum
       , po_lines_trx_v pl -- CLM project, bug 9403291
             , mtl_system_items_vl msi
   WHERE rsup.po_line_id = pl.po_line_id
         -- bug 2805640
     and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
     AND pl.item_id = msi.inventory_item_id (+)
           and Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and rsup.po_header_id = p_po_header_id
           AND pl.line_num LIKE (po_line_number)
           AND rsup.to_organization_id = p_organization_id  --BUG 4108624
         order by 1;
   END IF;
END GET_PO_LINE_NUM_LOV;




--      Name: GET_LOCATION_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_location_code   which restricts LOV SQL to the user input text
--
--
--      Output parameters:
--       x_location      returns LOV rows as reference cursor
--
--      Functions: This API returns location for given org


PROCEDURE get_location_lov (x_location OUT NOCOPY t_genref,
          p_organization_id IN NUMBER,
          p_location_code IN VARCHAR2)
  IS
BEGIN
   -- this query is returning more than 50,000 record in dom1151
   -- it is caused by nvl(inventory_organization_id,0) = 0 )
   -- need to confirm
   OPEN x_location FOR
     SELECT location_code
          , location_id
          , description
       FROM hr_locations hrl
      WHERE (inventory_organization_id = p_organization_id
       OR Nvl(inventory_organization_id,0) = 0)
        AND receiving_site_flag = 'Y'
        AND (inactive_date IS NULL OR inactive_date > Sysdate)
        AND location_code LIKE (p_location_code)
      ORDER BY Upper(location_code);
END get_location_lov;



--      Name: get_freight_carrier_lov
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_freight_carrier  which restricts LOV SQL to the user input text
--
--
--      Output parameters:
--       x_location      returns LOV rows as reference cursor
--
--      Functions: This API returns freight carrier for given org


PROCEDURE get_freight_carrier_lov (x_freight_carrier OUT NOCOPY t_genref,
           p_organization_id IN NUMBER,
           p_freight_carrier IN VARCHAR2)
  IS
BEGIN
   OPEN x_freight_carrier FOR
     select freight_code
          , description
       from org_freight
      where organization_id = p_organization_id
        and nvl(disable_date, sysdate+1) > sysdate
        AND freight_code LIKE (p_freight_carrier)
      order by upper(freight_code);
END get_freight_carrier_lov;


--      Name: GET_SHIPMENT_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_shipment_num   which restricts LOV SQL to the user input text
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_shipment_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns Shipment number for a given org
--                 Also it returns an ASN numner for ASN receipt

PROCEDURE GET_SHIPMENT_NUM_LOV(x_shipment_num_lov OUT NOCOPY t_genref,
             p_organization_id IN NUMBER,
             p_shipment_num IN VARCHAR2,
             p_mobile_form IN VARCHAR2,
             p_po_header_id IN VARCHAR2)

   IS

BEGIN


   IF p_mobile_form = 'RCVTXN' THEN
      OPEN x_shipment_num_lov FOR

  SELECT DISTINCT rsh.shipment_num,
  rsh.shipment_header_id,
  rsh.shipped_date,
  rsh.expected_receipt_date,
  rsl.from_organization_id,
  ood.organization_name,
  'Organization',
  rsh.packing_slip,
  rsh.bill_of_lading,
  rsh.waybill_airbill_num,
  rsh.freight_carrier_code
  FROM
  rcv_shipment_headers rsh,
  rcv_shipment_lines rsl,
  rcv_supply ms,
  rcv_transactions rt,
  org_organization_definitions ood
  WHERE rsh.shipment_header_id = ms.shipment_header_id
  AND ms.to_organization_id = p_organization_id
  AND rt.organization_id = p_organization_id
  AND rsl.from_organization_id = ood.organization_id(+)
  AND ms.supply_source_id = rt.transaction_id
  AND ms.supply_type_code = 'RECEIVING'
  AND rt.transaction_type <> 'UNORDERED'
  AND rsl.shipment_header_id = rsh.shipment_header_id
  AND Nvl(ms.quantity,0) > 0
        AND (exists
       (SELECT 1
          FROM rcv_transactions rt1
         WHERE rt1.transaction_id = rt.transaction_id
           AND rt1.inspection_status_code <> 'NOT INSPECTED'
           AND rt1.routing_header_id = 2)
       OR rt.routing_header_id <> 2
       OR rt.routing_header_id IS NULL)
  AND rsh.shipment_num IS NOT NULL
  AND rsh.shipment_num LIKE (p_shipment_num)
  ORDER BY rsh.shipment_header_id DESC;

    ELSIF p_mobile_form = 'RECEIPT' THEN
      OPEN x_shipment_num_lov FOR

  SELECT DISTINCT sh.shipment_num,
  sh.shipment_header_id,
  sh.shipped_date,
  sh.expected_receipt_date,
  Decode(sh.receipt_source_code,'VENDOR',sh.vendor_id, sl.from_organization_id) from_organization_id,
  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id,sl.from_organization_id),1,80) organization_name,
  /* Bug 4253199 ** Receipt source code is fetched properly
  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization'),
  */
  Decode(sh.receipt_source_code,'VENDOR','Vendor',sh.receipt_source_code),
  sh.packing_slip,
  sh.bill_of_lading,
  sh.waybill_airbill_num,
  sh.freight_carrier_code
  FROM rcv_shipment_headers sh,
  rcv_shipment_lines sl
  WHERE sh.shipment_num IS NOT NULL
    AND sh.shipment_header_id = sl.shipment_header_id
    AND sl.to_organization_id = p_organization_id
    AND sh.receipt_source_code IN ('INTERNAL ORDER','INVENTORY')
    AND exists
         (SELECT 'available supply'
    FROM mtl_supply ms
    WHERE ms.to_organization_id = p_organization_id
    AND ms.shipment_header_id = sh.shipment_header_id)
    -- This was fix for bug 2740648/2752094
    AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
    AND sh.shipment_num LIKE (p_shipment_num)
    ORDER BY sh.shipment_num;

    ELSIF p_mobile_form = 'RCPTASN' THEN
      OPEN x_shipment_num_lov FOR

  SELECT DISTINCT sh.shipment_num,
  sh.shipment_header_id,
  sh.shipped_date,
  sh.expected_receipt_date,
  Decode(sh.receipt_source_code,'VENDOR',sh.vendor_id, sl.from_organization_id) from_organization_id,
  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id,sl.from_organization_id),1,80) organization_name,
  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization'),
  sh.packing_slip,
  sh.bill_of_lading,
  sh.waybill_airbill_num,
  sh.freight_carrier_code
  FROM rcv_shipment_headers sh,
  rcv_shipment_lines sl
  WHERE sh.shipment_num IS NOT NULL
    AND sh.shipment_header_id = sl.shipment_header_id
    AND sl.to_organization_id = p_organization_id
    AND sl.po_header_id = Nvl(To_number(p_po_header_id), sl.po_header_id)
    AND sh.receipt_source_code = 'VENDOR'
    AND sl.shipment_line_status_code <> 'CANCELLED'
    AND sh.shipment_header_id = sl.shipment_header_id
    -- This was fix for bug 2740648/2752094
    AND sh.asn_type in ('ASN','ASBN')
    AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
    AND sl.to_organization_id = p_organization_id
    AND sh.shipment_num LIKE (p_shipment_num)
    ORDER BY sh.shipment_num;
    ELSIF p_mobile_form = 'INSPECT' THEN
      OPEN x_shipment_num_lov FOR
      /*Bug: 4951739
      Modified query: Referencing base table instead of
      RCV_TRANSACTIONS_V
      */
      SELECT  DISTINCT   rsh.shipment_num,
              rsh.shipment_header_id,
              rsh.shipped_date,
              rsh.expected_receipt_date,
              rsl.from_organization_id,
              ood.name organization_name,
              'Organization',
              rsh.packing_slip,
              rsh.bill_of_lading,
              rsh.waybill_airbill_num,
              rsh.freight_carrier_code
      FROM      RCV_SUPPLY RSUP,
              RCV_SHIPMENT_LINES RSL,
              RCV_TRANSACTIONS RT,
              RCV_SHIPMENT_HEADERS RSH,
              PO_LOOKUP_CODES PLC,
              PO_LINE_LOCATIONS_ALL PLL,
              HR_ALL_ORGANIZATION_UNITS_TL OOD
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
            , mtl_parameters mp,
              rcv_parameters rp
--  End for Bug 7440217
      WHERE    RSH.receipt_source_code                     <>  'VENDOR'
              AND    RSUP.SUPPLY_TYPE_CODE                  =  'RECEIVING'
              AND    RT.TRANSACTION_TYPE                    <>  'UNORDERED'
              AND    RT.TRANSACTION_TYPE                    =  PLC.LOOKUP_CODE
              AND    PLC.LOOKUP_TYPE                        =  'RCV TRANSACTION TYPE'
              AND    RSL.SHIPMENT_LINE_ID                   =  RSUP.SHIPMENT_LINE_ID
              AND    RT.TRANSACTION_ID                      =  RSUP.RCV_TRANSACTION_ID
              AND    RSH.SHIPMENT_HEADER_ID                 =  RSUP.SHIPMENT_HEADER_ID
              AND    PLL.LINE_LOCATION_ID(+)                =  RSUP.PO_LINE_LOCATION_ID
              AND    NVL(PLL.MATCHING_BASIS(+),'QUANTITY') <>  'AMOUNT'
              AND    PLL.PAYMENT_TYPE IS NULL
              AND    RSUP.to_organization_id          =  p_organization_id
              AND    RT.inspection_status_code        =  'NOT INSPECTED'
              AND    RT.routing_header_id             =  2 /* Inspection Routing */
              AND    RSL.from_organization_id   =  OOD.organization_id(+)
              AND    OOD.LANGUAGE(+)            =  USERENV('LANG')
              AND    RSL.shipment_header_id     =  rsh.shipment_header_id
              AND    RSH.shipment_num IS NOT NULL
              AND    RSH.shipment_num LIKE (p_shipment_num)
      ORDER BY RSH.shipment_header_id DESC;
   END IF;

END GET_SHIPMENT_NUM_LOV;


--      Name: GET_REQ_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_requisition_num   which restricts LOV SQL to the user input text
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_requisition_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns Shipment number for a given org
--                 Also it returns an ASN numner for ASN receipt


PROCEDURE GET_REQ_NUM_LOV(x_requisition_num_lov OUT NOCOPY t_genref,
        p_organization_id IN NUMBER,
        p_requisition_num IN VARCHAR2,
        p_mobile_form IN VARCHAR2
        )
  IS

BEGIN

   IF p_mobile_form = 'RCVTXN' THEN
      OPEN x_requisition_num_lov FOR

  SELECT DISTINCT
  prh.segment1,
  MO_GLOBAL.get_ou_name(prh.org_id), --<R12 MOAC>
  prh.requisition_header_id,
  prh.description,
  NULL,
  to_char(prh.org_id) --<R12 MOAC>
  FROM
  po_req_headers_trx_v prh, -- CLM project, bug 9403291
  rcv_supply ms,
  po_req_lines_trx_v prl,  -- CLM project, bug 9403291
  rcv_transactions rt
  WHERE
  prh.requisition_header_id = ms.req_header_id
  AND prl.requisition_header_id = prh.requisition_header_id
  AND prl.destination_organization_id = p_organization_id
  AND prl.source_type_code = 'INVENTORY'
  AND ms.supply_source_id = rt.transaction_id
  AND rt.transaction_type <> 'UNORDERED'
  AND ms.quantity > 0
  AND ms.supply_type_code = 'RECEIVING'
  AND ms.to_organization_id = p_organization_id
  AND rt.organization_id = p_organization_id
  -- Bug# 3631580: Performance Fixes
  -- Added the following line to avoid a full table scan
  AND rt.requisition_line_id = prl.requisition_line_id
        AND (exists
       (SELECT 1
          FROM rcv_transactions rt1
         WHERE rt1.transaction_id = rt.transaction_id
           AND rt1.inspection_status_code <> 'NOT INSPECTED'
           AND rt1.routing_header_id = 2)
       OR rt.routing_header_id <> 2
       OR rt.routing_header_id IS NULL)
  AND prh.segment1 LIKE (p_requisition_num)
  ORDER BY prh.segment1;

    ELSIF p_mobile_form = 'RECEIPT' THEN
      OPEN x_requisition_num_lov FOR

  SELECT DISTINCT
  prh.segment1,
  MO_GLOBAL.get_ou_name(prh.org_id),   --<R12 MOAC>
  prh.requisition_header_id,
  prh.description,
  null,
  to_char(prh.org_id)                 --<R12 MOAC>
  FROM
  po_req_headers_trx_v prh, -- CLM project, bug 9403291
  po_req_lines_trx_v prl    -- CLM project, bug 9403291
  WHERE
  Nvl(prl.cancel_flag,'N') = 'N'
  AND prl.destination_organization_id = p_organization_id
  AND prh.requisition_header_id = prl.requisition_header_id
  AND prh.authorization_status || '' = 'APPROVED'
  AND prh.segment1 LIKE (p_requisition_num)
  AND exists
  (SELECT 1
   FROM rcv_shipment_lines rsl
   WHERE rsl.requisition_line_id = prl.requisition_line_id
         AND rsl.routing_header_id > 0
         AND rsl.shipment_line_status_code <> 'FULLY RECEIVED')
  ORDER BY prh.segment1;
    ELSIF p_mobile_form = 'INSPECT' THEN
      --BUG 3421219: Returns the IR that needs to be inspected
      --Look at RTV for routing_id = 2 and inspection_status_code =
      --'NOT INSPECTED'
      OPEN x_requisition_num_lov FOR
  SELECT DISTINCT
  prh.segment1,
  MO_GLOBAL.get_ou_name(prh.org_id), --<R12 MOAC>
  prh.requisition_header_id,
  prh.description,
  null,
  to_char(prh.org_id)                --<R12 MOAC>
  FROM
  po_req_headers_trx_v prh, -- CLM project, bug 9403291
  po_req_lines_trx_v prl  -- CLM project, bug 9403291
  WHERE
  Nvl(prl.cancel_flag,'N') = 'N'
  AND prl.destination_organization_id = p_organization_id
  AND prh.requisition_header_id = prl.requisition_header_id
  AND prh.authorization_status || '' = 'APPROVED'
  AND prh.segment1 LIKE (p_requisition_num)
  AND exists
  (SELECT 1
   FROM rcv_shipment_lines rsl,
   rcv_shipment_headers rsh,
   rcv_transactions_v rtv
   WHERE rsl.requisition_line_id = prl.requisition_line_id
   AND rsh.shipment_header_id = rsl.shipment_header_id
   AND rtv.shipment_header_id = rsh.shipment_header_id
   AND rtv.shipment_line_id = rsl.shipment_line_id
   AND rtv.receipt_source_code <> 'VENDOR'
   AND rtv.inspection_status_code = 'NOT INSPECTED'
   AND rtv.routing_id = 2
         AND rsl.routing_header_id > 0
   )
  ORDER BY prh.segment1;
   END IF;

END get_req_num_lov;



-- LOV for the pack slip numbers of a shipment (mainly sfor ASN)
-- Almost exactly same as shipment LOV


PROCEDURE  GET_PACK_SLIP_NUM_LOV(x_pack_slip_num_lov OUT NOCOPY t_genref,
         p_organization_id IN NUMBER,
         p_pack_slip_num IN VARCHAR2,
         p_po_header_id IN VARCHAR2)
    IS

BEGIN
   IF p_po_header_id IS NOT NULL THEN
      OPEN x_pack_slip_num_lov FOR
  SELECT DISTINCT sh.packing_slip,
  sh.shipment_num,
  sh.shipment_header_id,
  sh.shipped_date,
  sh.expected_receipt_date,
  Decode(sh.receipt_source_code,'VENDOR',sh.vendor_id, sl.from_organization_id) from_organization_id,
  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id,sl.from_organization_id),1,80) organization_name,
  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization')
  FROM rcv_shipment_headers sh,
  rcv_shipment_lines sl
  WHERE sh.packing_slip IS NOT NULL
    AND sh.shipment_header_id = sl.shipment_header_id
    AND sl.to_organization_id = p_organization_id
    AND sl.po_header_id = To_number(p_po_header_id)
    AND ( sh.receipt_source_code = 'VENDOR'
    AND sl.shipment_line_status_code <> 'CANCELLED')
    AND sh.packing_slip LIKE (p_pack_slip_num)
    ORDER BY sh.packing_slip;
    ELSE
      OPEN x_pack_slip_num_lov FOR
  SELECT DISTINCT sh.packing_slip,
  sh.shipment_num,
  sh.shipment_header_id,
  sh.shipped_date,
  sh.expected_receipt_date,
  Decode(sh.receipt_source_code,'VENDOR',sh.vendor_id, sl.from_organization_id) from_organization_id,
  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id,sl.from_organization_id),1,80) organization_name,
  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization')
  FROM rcv_shipment_headers sh,
  rcv_shipment_lines sl
  WHERE sh.packing_slip IS NOT NULL
    AND sh.shipment_header_id = sl.shipment_header_id
    AND sl.to_organization_id = p_organization_id
    AND sl.po_header_id = Nvl(To_number(p_po_header_id), sl.po_header_id)
    AND ( sh.receipt_source_code = 'VENDOR'
    AND sl.shipment_line_status_code <> 'CANCELLED')
    AND sh.packing_slip LIKE (p_pack_slip_num)
    ORDER BY sh.packing_slip;
   END IF;
END GET_PACK_SLIP_NUM_LOV;


-- LOV for the possible receipt numbers that can be used.
PROCEDURE GET_RECEIPT_NUMBER_LOV(x_getRcptNumLOV OUT NOCOPY t_genref,
         p_organization_id IN NUMBER,
         p_receipt_number IN VARCHAR2)
  IS
BEGIN
   OPEN x_getRcptNumLOV FOR
     SELECT DISTINCT rsh.receipt_num
          , Trunc(ms.receipt_date)
          , rsh.shipment_header_id
          , rsh.shipment_num
          , rt.po_header_id
          , rt.oe_order_header_id
          , rt.po_release_id --bug6594996 add PO release header ID associated with the receip
          , ms.from_organization_id    -- bug #6917248
       FROM rcv_supply ms
          , rcv_transactions rt
          , rcv_shipment_headers rsh
          , rcv_shipment_lines rsl
          , mtl_parameters mp
      WHERE rsh.shipment_header_id = ms.shipment_header_id
        AND rsh.shipment_header_id = rt.shipment_header_id
        AND ms.to_organization_id = p_organization_id
        and mp.organization_id = ms.to_organization_id
        and rsl.to_organization_id = ms.to_organization_id
        and rsl.shipment_header_id = rsh.shipment_header_id
        and (mp.wms_enabled_flag = 'N'
             OR (mp.wms_enabled_flag = 'Y' AND (rsl.item_id is NULL
            OR exists (SELECT 1
                 FROM mtl_system_items_kfv msik
                 WHERE msik.inventory_item_id = rsl.item_id
                 AND msik.organization_id = p_organization_id
                 AND msik.mtl_transactions_enabled_flag = 'N')
                                                OR exists
                                                (select '1' from po_headers_all poh
                                                          , po_lines_all pol
                                                          , po_line_types plt
                                                        where rt.po_header_id is not null
                                                        and rt.po_header_id = poh.po_header_id
                                                        and poh.po_header_id = pol.po_header_id
                                                        and pol.line_type_id = plt.line_type_id
                                                        and rsl.item_id = pol.item_id
                                                        AND plt.outside_operation_flag = 'Y'))))
        AND rt.transaction_id = ms.supply_source_id
  AND ms.quantity > 0
        AND ms.supply_type_code = 'RECEIVING'
        --and rt.SOURCE_DOCUMENT_CODE <> 'RMA'
        AND rt.transaction_type IN ('ACCEPT','MATCH','RECEIVE',
            'REJECT','RETURN TO RECEIVING','TRANSFER')
        AND (exists
       (SELECT 1
          FROM rcv_transactions rt1
         WHERE rt1.transaction_id = rt.transaction_id
           AND rt1.inspection_status_code <> 'NOT INSPECTED'
           AND rt1.routing_header_id = 2)
       OR rt.routing_header_id <> 2
       OR rt.routing_header_id IS NULL)
        AND rsh.receipt_num LIKE (p_receipt_number)
   ORDER BY Decode(rtrim(rsh.receipt_num,'0123456789'),null,null,rsh.receipt_num),
   Decode(rtrim(rsh.receipt_num,'0123456789'),null,to_number(rsh.receipt_num),null);
                                                                        --<R12 MOAC>

END GET_RECEIPT_NUMBER_LOV;

-- This LOV is used in ORG Tranfer Transaction
-- for Mobile Inventory.


PROCEDURE GET_CARRIER(x_getcarrierLOV OUT NOCOPY t_genref,
          p_FromOrganization_Id IN NUMBER,
          p_ToOrganization_Id IN NUMBER,
          p_carrier IN VARCHAR2)
  IS
BEGIN
   OPEN x_getcarrierLOV FOR
     select freight_code, description, distribution_account
     from
     org_enabled_freight_val_v
     where organization_id = (SELECT decode(FOB_POINT,1,TO_ORGANIZATION_ID,2, FROM_ORGANIZATION_ID) from mtl_interorg_parameters where TO_ORGANIZATION_ID = p_ToOrganization_Id and from_organization_id =p_FromOrganization_Id )
     AND freight_code LIKE (p_carrier)
     order by freight_code;
END GET_CARRIER;

--
-- LOV for the possible quality codes for mobile inspection form
--
PROCEDURE GET_QUALITY_CODES_LOV(
 x_getQltyCodesLOV      OUT NOCOPY t_genref
,p_quality_code         IN  VARCHAR2)
is
begin
  open x_getQltyCodesLOV for
  select
          code
        , ranking
  , description
  from po_quality_codes
  where nvl(inactive_date,sysdate + 1) > sysdate
        and   code like (p_quality_code)
  order by ranking;
end GET_QUALITY_CODES_LOV;

--
-- LOV for the possible reason codes for mobile inspection form
--
PROCEDURE GET_REASON_CODES_LOV(
 x_getReasonCodesLOV    OUT NOCOPY t_genref
,p_reason_code         IN  VARCHAR2)
IS
BEGIN
  OPEN   x_getReasonCodesLOV FOR
  SELECT reason_name ,description ,reason_id
  FROM   mtl_transaction_reasons
  WHERE  NVL(disable_date,SYSDATE + 1) > SYSDATE
  AND    reason_name LIKE (p_reason_code)
  ORDER BY upper(reason_name);

END GET_REASON_CODES_LOV;

--
-- Procedure overloaded for Transaction Reason Security build.
-- 4505091, nsrivast

PROCEDURE GET_REASON_CODES_LOV(
           x_getReasonCodesLOV    OUT NOCOPY t_genref
          ,p_reason_code          IN  VARCHAR2
          ,p_txn_type_id          IN  VARCHAR2 )

IS
BEGIN
  OPEN   x_getReasonCodesLOV FOR
  SELECT reason_name ,description ,reason_id
  FROM   mtl_transaction_reasons
  WHERE  NVL(disable_date,SYSDATE + 1) > SYSDATE
  AND    reason_name LIKE (p_reason_code)
   -- nsrivast, invconv , transaction reason security
  AND   ( NVL  ( fnd_profile.value_wnps('INV_TRANS_REASON_SECURITY'), 'N') = 'N'
          OR
          reason_id IN (SELECT  reason_id FROM mtl_trans_reason_security mtrs
                              WHERE(( responsibility_id = fnd_global.resp_id OR NVL(responsibility_id, -1) = -1 )
                                        AND
                                    ( mtrs.transaction_type_id =  p_txn_type_id OR  NVL(mtrs.transaction_type_id, -1) = -1 )
                                    )-- where ends
                            )-- select ends
          ) -- and condn ends ,-- nsrivast, invconv
   ORDER BY upper(reason_name);

END GET_REASON_CODES_LOV;




-- LOV for the possible receipt numbers for inspection
PROCEDURE GET_RECEIPT_NUMBER_INSPECT_LOV(
  x_getRcptNumLOV   OUT NOCOPY t_genref
, p_organization_id   IN  NUMBER
, p_receipt_number  IN  VARCHAR2)
is
begin
     OPEN x_getRcptNumLOV FOR
     /*Bug: 4951739
      Modified query: Referencing base table instead of
      RCV_TRANSACTIONS_V
      */
     SELECT  DISTINCT   rsh.receipt_num   ,
        null   ,
        rsup.shipment_header_id   ,
        null   ,
        null   ,
        null
        , null     -- bug # 6917248
        ,  rsup.from_organization_id -- bug # 6917248
     FROM    RCV_SUPPLY RSUP,
             RCV_TRANSACTIONS RT,
             RCV_SHIPMENT_HEADERS RSH,
             RCV_SHIPMENT_LINES RSL,
             PO_LOOKUP_CODES PLC,
             PO_LINE_LOCATIONS_ALL PLL,
             mtl_parameters mp --BUG 5166887
     WHERE         RSUP.SUPPLY_TYPE_CODE              =  'RECEIVING'
            AND    RT.TRANSACTION_TYPE                   <>  'UNORDERED'
            AND    RT.TRANSACTION_TYPE                    =  PLC.LOOKUP_CODE
            AND    PLC.LOOKUP_TYPE                        =  'RCV TRANSACTION TYPE'
            AND    RT.TRANSACTION_ID                      =  RSUP.RCV_TRANSACTION_ID
            AND    RSH.SHIPMENT_HEADER_ID                 =  RSUP.SHIPMENT_HEADER_ID
            AND    PLL.LINE_LOCATION_ID(+)                =  RSUP.PO_LINE_LOCATION_ID
            AND    NVL(PLL.MATCHING_BASIS(+),'QUANTITY') <>  'AMOUNT'
            AND    PLL.PAYMENT_TYPE IS NULL
            AND    RSUP.to_organization_id          =  p_organization_id
            AND    RT.inspection_status_code        =  'NOT INSPECTED'
            AND    RT.routing_header_id             =  2  /* Inspection Routing */
            AND    RSH.receipt_num LIKE (p_receipt_number)

            -- BUG 5166887: Do not return any rows if user access WMS org through the
            -- MSCA menu option
            AND    rsl.shipment_header_id = rsh.shipment_header_id
            AND    rsl.to_organization_id = rsup.to_organization_id
            AND    mp.organization_id = rsup.to_organization_id
            AND    (mp.wms_enabled_flag = 'N'
                    OR (mp.wms_enabled_flag = 'Y'
                        AND (rsl.item_id is NULL
                             OR exists (SELECT 1
                                        FROM mtl_system_items_kfv msik
                                        WHERE msik.inventory_item_id = rsl.item_id
                                        AND msik.organization_id = p_organization_id
                                        AND msik.mtl_transactions_enabled_flag = 'N')
                             OR exists (select '1'
                                        from po_headers_all poh
                                           , po_lines_all pol
                                           , po_line_types plt
                                        where rt.po_header_id is not null
                                        and rt.po_header_id = poh.po_header_id
                                        and poh.po_header_id = pol.po_header_id
                                        and pol.line_type_id = plt.line_type_id
                                        and rsl.item_id = pol.item_id
                                        AND plt.outside_operation_flag = 'Y'))))
            -- END BUG 5166887
             ORDER BY   Decode(rtrim(RSH.receipt_num,'0123456789'),          null,null,          RSH.receipt_num),
             Decode(rtrim(RSH.receipt_num,'0123456789'),          null,to_number(RSH.receipt_num),          null);                                                                      --<R12 MOAC>
end GET_RECEIPT_NUMBER_INSPECT_LOV;


-- LOV for RMA
PROCEDURE get_rma_lov
  (x_getRMALOV  OUT NOCOPY t_genref,
   p_organization_id  IN  NUMBER,
   p_rma_number IN VARCHAR,
   p_mobile_form IN VARCHAR2)
  IS
BEGIN

   IF p_mobile_form = 'RCVTXN' THEN
      OPEN x_getrmalov FOR

  SELECT DISTINCT
  oeh.order_number ,
  oeh.header_id ,
  --  oet.name ,
  --  oet.ORDER_CATEGORY_CODE ,
        OTT_TL.NAME ORDER_TYPE, --OLT.NAME  ORDER_TYPE,
        OTT_ALL.ORDER_CATEGORY_CODE ORDER_TYPE_CODE, --OLT.ORDER_CATEGORY_CODE ORDER_TYPE_CODE,
  oec.customer_id,
  oec.name customer_name,
  oec.customer_number
  FROM rcv_transactions rt,
  rcv_supply ms,
  oe_order_headers_all oeh,
  oe_order_lines_all oel,
  --  oe_line_types_v oet,
  OE_TRANSACTION_TYPES_TL OTT_TL,
        OE_TRANSACTION_TYPES_ALL OTT_ALL,
  oe_sold_to_orgs_v oec
  WHERE oeh.header_id = rt.oe_order_header_id
  --  AND   oet.order_category_code = 'RETURN'
  AND   rt.source_document_code = 'RMA'
  AND   rt.oe_order_header_id = ms.oe_order_header_id
  AND   ms.quantity > 0
  AND   ms.supply_type_code = 'RECEIVING'
  AND   ms.to_organization_id = p_organization_id
  AND   ms.supply_source_id = rt.transaction_id
  AND   rt.organization_id = ms.to_organization_id
  AND   rt.transaction_type <> 'UNORDERED'
  AND   oeh.HEADER_ID = oel.HEADER_ID
  and   oeh.order_type_id = ott_all.transaction_type_id
        and   ott_all.order_category_code in ('MIXED', 'RETURN')
        and   ott_all.transaction_type_id = ott_tl.transaction_type_id
        and   ott_tl.language = userenv('LANG')
  --  AND   oel.line_type_id    =  oet.line_type_id
  AND   oeh.sold_to_org_id   =  oec.customer_id
        AND (exists
       (SELECT 1
          FROM rcv_transactions rt1
         WHERE rt1.transaction_id = rt.transaction_id
           AND rt1.inspection_status_code <> 'NOT INSPECTED'
           AND rt1.routing_header_id = 2)
       OR rt.routing_header_id <> 2
       OR rt.routing_header_id IS NULL)
        AND   oeh.order_number LIKE (p_rma_number)
  ORDER BY oeh.order_number;

    ELSIF  p_mobile_form = 'RECEIPT' THEN

      OPEN x_getrmalov FOR
  SELECT  DISTINCT
  OEH.ORDER_NUMBER OE_ORDER_NUM,
  OEL.HEADER_ID OE_ORDER_HEADER_ID,
  --  OLT.NAME  ORDER_TYPE,
  OTT_TL.NAME ORDER_TYPE,
  --  OLT.ORDER_CATEGORY_CODE ORDER_TYPE_CODE,
  OTT_ALL.ORDER_CATEGORY_CODE ORDER_TYPE_CODE,
  OESOLD.CUSTOMER_ID,
  --TCA Cleanup
  --OEC.customer_name,
  --OEC.customer_number
  PARTY.PARTY_NAME CUSTOMER_NAME,
  PARTY.PARTY_NUMBER CUSTOMER_NUMBER
  FROM
  OE_ORDER_LINES_all OEL,
  OE_ORDER_HEADERS_all OEH,
  OE_TRANSACTION_TYPES_TL OTT_TL,
        OE_TRANSACTION_TYPES_ALL OTT_ALL,

  --  OE_LINE_TYPES_V OLT,
  OE_SOLD_TO_ORGS_V OESOLD,
  WF_ITEM_ACTIVITY_STATUSES WF,
  WF_PROCESS_ACTIVITIES WPA,
  --RA_CUSTOMERS OEC /*TCA Cleanup */
  HZ_PARTIES PARTY,
  HZ_CUST_ACCOUNTS CUST_ACCT
  WHERE
  OEL.LINE_CATEGORY_CODE='RETURN'
  AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
  AND OEL.HEADER_ID = OEH.HEADER_ID
  AND OEL.SOLD_TO_ORG_ID = OESOLD.ORGANIZATION_ID
  --AND OESOLD.CUSTOMER_ID = oec.customer_id  /*TCA Cleanup */
  --Bug5417779: oesold.customer_id should be joined with cust_acct.cust_account_id
  AND OESOLD.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
  AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
  and oeh.order_type_id = ott_all.transaction_type_id
        and ott_all.order_category_code in ('MIXED', 'RETURN')
        and ott_all.transaction_type_id = ott_tl.transaction_type_id
        and ott_tl.language = userenv('LANG')

  --  AND OEL.LINE_TYPE_ID = OLT.LINE_TYPE_ID
  AND OEH.BOOKED_FLAG='Y'
  AND OEH.OPEN_FLAG='Y'
  AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
  AND WPA.ACTIVITY_ITEM_TYPE = 'OEOL'
  AND WPA.ACTIVITY_NAME = 'RMA_WAIT_FOR_RECEIVING'
  AND WF.ITEM_TYPE = 'OEOL'
  AND WF.PROCESS_ACTIVITY = WPA.INSTANCE_ID
  AND WF.ACTIVITY_STATUS = 'NOTIFIED'
  AND OEL.LINE_ID = TO_NUMBER(WF.ITEM_KEY)
  AND oeh.order_number LIKE (p_rma_number)
  ORDER BY oeh.order_number;

    ELSIF  p_mobile_form = 'INSPECT' THEN

      OPEN x_getrmalov FOR
  SELECT DISTINCT
  oeh.order_number ,
  oeh.header_id ,
  OTT_TL.NAME ORDER_TYPE, --OLT.NAME  ORDER_TYPE,
        OTT_ALL.ORDER_CATEGORY_CODE ORDER_TYPE_CODE,
  --  oet.name ,
  --  oet.ORDER_CATEGORY_CODE ,
  oec.customer_id,
  oec.name customer_name,
  oec.customer_number
  FROM rcv_transactions_v rtv,
  oe_order_headers_all    oeh,
  OE_TRANSACTION_TYPES_TL OTT_TL,
        OE_TRANSACTION_TYPES_ALL OTT_ALL,
  oe_order_lines_all      oel,
  --  oe_line_types_v         oet,
  oe_sold_to_orgs_v       oec
  WHERE oeh.header_id              = rtv.oe_order_header_id
        AND   rtv.receipt_source_code    = 'CUSTOMER'
        AND   rtv.to_organization_id     = p_organization_id
    AND   rtv.inspection_status_code = 'NOT INSPECTED'
        AND   rtv.routing_id             = 2 /* Inspection Routing */
  AND   oeh.HEADER_ID      = oel.HEADER_ID
  --  AND   oel.line_type_id           =  oet.line_type_id
  --  AND   oet.order_category_code    = 'RETURN'
  and   oeh.order_type_id = ott_all.transaction_type_id
        and   ott_all.order_category_code in ('MIXED', 'RETURN')
        and   ott_all.transaction_type_id = ott_tl.transaction_type_id
        and   ott_tl.language = userenv('LANG')

  AND   oeh.sold_to_org_id         =  oec.customer_id
        AND   oeh.order_number LIKE (p_rma_number);

   END IF;
END get_rma_lov;

--
--
-- Bug 2192815
-- UOM Lov for Expense Items
--
--
FUNCTION get_conversion_rate_expense(p_from_uom_code   varchar2,
                             p_organization_id NUMBER,
                             p_item_id         NUMBER,
                             p_primary_uom_code varchar2 )
  RETURN VARCHAR2 IS
     l_primary_uom_code VARCHAR2(3) := p_primary_uom_code;
     l_conversion_rate NUMBER;
     l_return_string VARCHAR2(50);
BEGIN
      inv_convert.inv_um_conversion(p_from_uom_code,
                                    l_primary_uom_code,
                                    p_item_id,
                                    l_conversion_rate);
      IF l_conversion_rate IS NOT NULL AND l_conversion_rate > 0 THEN
         l_return_string :=
           p_from_uom_code||'('||To_char(TRUNC(l_conversion_rate,4))||' '||l_primary_uom_code||')';
         RETURN l_return_string;
      END IF;
      RETURN p_from_uom_code;
END;

PROCEDURE get_uom_lov_expense(x_uoms OUT NOCOPY t_genref,
                          p_organization_id IN NUMBER,
                          p_item_id IN NUMBER,
                          p_uom_type IN NUMBER,
                          p_uom_code IN VARCHAR2,
                          p_primary_uom_code IN VARCHAR2)
IS
p_primary_uom_class varchar2(10);
l_code VARCHAR2(20):=p_UOM_Code;
BEGIN

    IF (INSTR(l_code,'(') > 0) THEN
      l_code := SUBSTR(p_UOM_Code,1,INSTR(p_UOM_Code,'(')-1);
    END IF;


-- Find the Class from Primary UOM
Begin

select uom_class
  into p_primary_uom_class
from  mtl_units_of_measure muom
where muom.uom_code = p_primary_uom_code;

Exception
 When others then p_primary_uom_class := '';
End;

OPEN x_uoms FOR
SELECT
      get_conversion_rate_expense(muom.uom_code,
                                   p_Organization_Id,
                                   0,
                                   p_primary_uom_code )
      uom_code
      , muc.unit_of_measure unit_of_measure
      , ''
      , muc.uom_class uom_class
from
 mtl_uom_conversions_val_v muc ,
 mtl_units_of_measure muom
where muc.uom_class = p_primary_uom_class
and muc.item_id = 0
and nvl(muc.disable_date,sysdate+1)>sysdate
and muc.unit_of_measure = muom.unit_of_measure
and nvl(muom.disable_date,sysdate+1) > sysdate
and muom.uom_code like (l_code)
order by muc.unit_of_measure;

--FROM mtl_units_of_measure
--WHERE base_uom_flag = 'Y'
--AND uom_code LIKE (p_uom_code || '%')
--ORDER BY Upper(uom_code);

END get_uom_lov_expense;


/* Direct Shipping */
-- LOV for Location (used in Delivery Info Page )
PROCEDURE get_directship_location_lov (
    x_location OUT NOCOPY t_genref
   ,    p_organization_id IN NUMBER
   ,    p_location_code IN VARCHAR2) IS
BEGIN

   OPEN x_location FOR
       SELECT   address1
          ,   wsh_location_id
          ,   ui_location_code
       FROM wsh_locations
      WHERE (inactive_date IS NULL OR inactive_date > Sysdate)
        AND address1 LIKE (p_location_code)
      ORDER BY Upper (address1);

END get_directship_location_lov;


-- LOV for Location Code
PROCEDURE get_locationcode_lov (
    x_locationcode OUT NOCOPY t_genref
   ,    p_location_code IN VARCHAR2) IS
BEGIN

   OPEN x_locationcode FOR
      SELECT lookup_code, meaning, description
      FROM   ar_lookups
      WHERE  lookup_type = 'FOB'
      AND    nvl(start_date_active, sysdate)<=sysdate
      AND    nvl(end_date_active,sysdate)>=sysdate
      AND    enabled_flag = 'Y'
      AND    meaning like (p_location_code)
      ORDER BY Upper (lookup_code);
 --Bug 2961355:Changed the query to query from ar_lookups as fnd_lookup_values_vl had duplicate entries based on application id
 END get_locationcode_lov;

/* Direct Shipping */

--      Name: GET_DOC_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_doc_number   which restricts LOV SQL to the user input text
--       p_manual_po_num_type  NUMERIC or ALPHANUMERIC
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_doc_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns PO number for a given org
--

PROCEDURE GET_DOC_LOV
          (
          x_doc_num_lov        OUT NOCOPY t_genref,
          p_organization_id    IN  NUMBER,
          p_doc_number         IN  VARCHAR2,
          p_mobile_form        IN  VARCHAR2,
          p_shipment_header_id IN  VARCHAR2,
          p_inventory_item_id  IN  VARCHAR2,
          p_item_description   IN  VARCHAR2,
          p_doc_type           IN  VARCHAR2,
          p_vendor_prod_num    IN  VARCHAR2
          )
   IS

/* bug 4638235
   New local variables
*/

l_doc_num_passed  BOOLEAN := FALSE ;
l_doc_num_length  NUMBER  := NVL(LENGTH(p_doc_number),0) ;
l_instr_pos       NUMBER  := INSTR(p_doc_number , '%' , 1 , 1) ;
l_append varchar2(2):='';

BEGIN

/*
As part of the fix for the Performance Bug 3908402 the following changes have
been done with the help of Apps Performance Team.
1. The single query has been split into multiple queries based on the Doc Type
   and the original query has been placed at last if the Doc Type is ALL.
2. Removed the following  condition " AND nvl(p_doc_type,'ALL') in ('PO', 'ALL') "
   because this check has been already incorporated through if/else.
3. For the Doc Type of PO and ASN, query has been split further based on the
   value passed for p_inventory_item_id and p_item_description parameters.

The following changes have been done while selecting Purchase Orders.
i.e. doc type of PO.
   a. In the condition, "AND NVL(poll.approved_flag,'N') = 'Y' " ,
      nvl() has been removed.
   b. Removed the tables mtl_system_items_kfv and mtl_units_of_measure which are
      joined with po_lines_all table through outer join.
   c. Added the hint " +index(POH PO_HEADERS_U2) " to use the  index PO_HEADERS_U2.
   d. Removed the Distinct clause from the select statement.
*/

-- Fix for the performance Bug 4638235
-- We are determining whether the Doc Number has been passed with some value
-- other than % and the % shouldn't be at the beginning.
-- For Eg. P101% or % or %P101% or %P1%01% or P1%01
-- Based on the variable l_doc_num_passed and parameter p_inventory_item_id
-- the queries have been formed.
IF (WMS_DEPLOY.wms_deployment_mode='L') THEN --LSP
   l_append:='%';
END IF;
IF p_doc_number IS NOT NULL  THEN
   IF  l_doc_num_length > 1
       AND
       (
            l_instr_pos = l_doc_num_length
         OR (l_instr_pos = 0 OR l_instr_pos > 1)
       )
       THEN
      l_doc_num_passed := TRUE ;
   END IF;
ELSE
 l_doc_num_passed := FALSE ;
END IF;
-- End of fix

    IF p_mobile_form = 'RECEIPT' THEN
       IF  NVL(p_doc_type,'ALL') = 'PO' THEN
	  IF l_doc_num_passed AND p_inventory_item_id IS NOT NULL THEN
	   --bug 4638235  added checking for l_doc_number passed
           -- This select takes care of Vendor Item and any non-expense item
           -- and cross ref item case.
           OPEN x_doc_num_lov FOR
            SELECT /*+index(POH PO_HEADERS_U2) */
                -- DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)   FIELD4,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,  --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
                lookup_code FIELD14 ,
                to_char(poh.org_id) FIELD15  --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND EXISTS
                (
                SELECT
                    'Valid PO Shipments'
                FROM po_lines_trx_v pl, -- CLM project, bug 9403291
                     po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                   , mtl_parameters mp,
                     rcv_parameters rp
--  End for Bug 7440217
                WHERE pl.item_id = p_inventory_item_id
                    AND pl.po_header_id = poh.po_header_id
                    AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num, Nvl(pl.vendor_product_num,' '))
                    AND poh.po_header_id = poll.po_header_id
                    AND pl.po_line_id = poll.po_line_id
                    AND poll.approved_flag = 'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    -- AND poll.closed_code = 'OPEN' -- Bug 2859335
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                 AND poll.ship_to_organization_id = p_organization_id
                 AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                 AND mp.organization_id = p_organization_id
                 AND rp.organization_id = p_organization_id
                 AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                          OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                              OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                     )
--  End for Bug 7440217
                )
            UNION
            -- This Select Handles Substitute Items
            SELECT /*+index(POH PO_HEADERS_U2) */
                -- DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)   FIELD4,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,   --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
                lookup_code FIELD14 ,
                to_char(poh.org_id) FIELD15  --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND EXISTS
                (
                SELECT
                    'Valid PO Shipments'
                FROM po_lines_trx_v pl , -- CLM project, bug 9403291
                    mtl_related_items mri ,
                    mtl_system_items_kfv msi ,
                    po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                  , mtl_parameters mp,
                    rcv_parameters rp
--  End for Bug 7440217
                WHERE msi.organization_id = p_organization_id
                    AND pl.po_header_id = poh.po_header_id
                    AND
                    (
                        (
                            mri.related_item_id = msi.inventory_item_id
                            AND pl.item_id = mri.inventory_item_id
                            AND msi.inventory_item_id LIKE p_inventory_item_id
                        )
                        OR
                        (
                            mri.inventory_item_id = msi.inventory_item_id
                            AND pl.item_id = mri.related_item_id
                            AND mri.reciprocal_flag = 'Y'
                            AND msi.inventory_item_id LIKE p_inventory_item_id
                        )
                    )
                    AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                    AND poh.po_header_id = poll.po_header_id
                    AND pl.po_line_id = poll.po_line_id
                    AND poll.approved_flag = 'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                   AND poll.ship_to_organization_id = p_organization_id
                   AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                   AND mp.organization_id = p_organization_id
                   AND rp.organization_id = p_organization_id
                   AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                           OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                              OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                       )
--  End for Bug 7440217
                )
            ORDER BY 1,2 ;

          ELSIF NOT l_doc_num_passed AND p_inventory_item_id IS NOT NULL THEN
           -- This select takes care of Vendor Item and any non-expense item
           -- and cross ref item case.

           -- Added the Hint /*+LEADING(PL)*/ as part of Fix for Bug 4638235
           -- incase Item ID is given and Doc No is not given.
           -- Query needs to be driven from PO_LINES_ALL table. Here subquery
           -- has been made as join.
           OPEN x_doc_num_lov FOR
            SELECT /*+LEADING(PL)*/
                -- DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,  --<R12 MOAC>
	        PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
	        NULL FIELD11,
	        NULL FIELD12,
                NULL FIELD13,
	        lookup_code FIELD14,
	        to_char(poh.org_id) FIELD15  --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv ,
                po_lines_trx_v pl, -- CLM project, bug 9403291
                po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
              , mtl_parameters mp,
                rcv_parameters rp
--  End for Bug 7440217
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND pl.item_id = p_inventory_item_id
                AND pl.po_header_id = poh.po_header_id
                AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num, Nvl(pl.vendor_product_num,' '))
                AND poh.po_header_id = poll.po_header_id
                AND pl.po_line_id = poll.po_line_id
                AND poll.approved_flag = 'Y'
                AND Nvl(poll.cancel_flag,'N') = 'N'
             -- AND poll.closed_code = 'OPEN' -- Bug 2859335
                AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                AND poll.ship_to_organization_id = p_organization_id
                AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                AND mp.organization_id = p_organization_id
                AND rp.organization_id = p_organization_id
                AND (    (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                          OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                              OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                    )
--  End for Bug 7440217
            UNION
                -- This Select Handles Substitute Items
            SELECT /*+LEADING(MRI)*/				-- Bug 6600650
                -- DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)   FIELD4,--LSP
		MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,   --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
	        lookup_code FIELD14,
		to_char(poh.org_id) FIELD15  --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv ,
                po_lines_trx_v pl ,   -- CLM project, bug 9403291
                mtl_related_items mri ,
                mtl_system_items_kfv msi ,
                po_line_locations_trx_v poll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
             ,  mtl_parameters mp,
                rcv_parameters rp
--  End for Bug 7440217
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND msi.organization_id = p_organization_id
                AND pl.po_header_id = poh.po_header_id
                AND mri.related_item_id = msi.inventory_item_id
                AND pl.item_id = mri.inventory_item_id
                AND msi.inventory_item_id = TO_NUMBER(p_inventory_item_id)
                AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                AND poh.po_header_id = poll.po_header_id
                AND pl.po_line_id = poll.po_line_id
                AND poll.approved_flag = 'Y'
                AND Nvl(poll.cancel_flag,'N') = 'N'
             -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                AND poll.ship_to_organization_id = p_organization_id
                AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                AND mp.organization_id = p_organization_id
                AND rp.organization_id = p_organization_id
                AND (    (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                          OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                              OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                    )
--  End for Bug 7440217
           UNION
            SELECT /*+LEADING(MRI)*/				-- Bug 6600650
                -- DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
		poh.type_lookup_code FIELD3 ,
      wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
		MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,   --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
		lookup_code FIELD14,
	        to_char(poh.org_id) FIELD15  --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv ,
                po_lines_trx_v pl ,    -- CLM project, bug 9403291
                mtl_related_items mri ,
                mtl_system_items_kfv msi ,
                po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
              , mtl_parameters mp,
                rcv_parameters rp
--  End for Bug 7440217
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND msi.organization_id = p_organization_id
                AND pl.po_header_id = poh.po_header_id
                AND mri.inventory_item_id = msi.inventory_item_id
                AND pl.item_id = mri.related_item_id
                AND mri.reciprocal_flag = 'Y'
                AND msi.inventory_item_id = TO_NUMBER(p_inventory_item_id)
                AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                AND poh.po_header_id = poll.po_header_id
                AND pl.po_line_id = poll.po_line_id
                AND poll.approved_flag = 'Y'
                AND Nvl(poll.cancel_flag,'N') = 'N'
             -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                AND poll.ship_to_organization_id = p_organization_id
                AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                AND mp.organization_id = p_organization_id
                AND rp.organization_id = p_organization_id
                AND (    (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                          OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                              OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                     )
--  End for Bug 7440217
            ORDER BY 1,2 ;

         ELSIF p_item_description IS NOT NULL THEN
            OPEN x_doc_num_lov FOR
            -- This Select Handles Expense Items
              SELECT /*+index(POH PO_HEADERS_U2) */
                  -- DISTINCT
                  -- DOCTYPE PO
                  meaning FIELD0 ,
                  poh.segment1 FIELD1 ,
                  to_char(poh.po_header_id) FIELD2 ,
                  poh.type_lookup_code FIELD3 ,
                  wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                  MO_GLOBAL.get_ou_name(poh.org_id) FIELD5 ,  --<R12 MOAC>
                  PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                  to_char(poh.vendor_id) FIELD7 ,
                  to_char(poh.vendor_site_id) FIELD8 ,
                  'Vendor' FIELD9 ,
                  poh.note_to_receiver FIELD10 ,
                  NULL FIELD11 ,
                  NULL FIELD12 ,
                  NULL FIELD13 ,
                  lookup_code FIELD14 ,
                  to_char(poh.org_id) FIELD15    --<R12 MOAC>
              FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                  fnd_lookup_values_vl flv
              WHERE flv.lookup_code = 'PO'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  -- Bug 2859355 Added the Extra conditions for poh.
                  AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                  AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                  AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                  AND poh.segment1 LIKE (p_doc_number||l_append)
                  AND EXISTS
                  (
                  SELECT
                      'Valid PO Shipments'
                  FROM po_lines_trx_v pl , -- CLM project, bug 9403291
                       po_line_locations_trx_v poll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                     , mtl_parameters mp,
                       rcv_parameters rp
--  End for Bug 7440217
                  WHERE pl.ITEM_ID IS NULL
                      AND pl.item_description LIKE p_item_description||'%'
                      AND pl.po_header_id = poh.po_header_id
                      AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                      AND poh.po_header_id = poll.po_header_id
                      AND pl.po_line_id = poll.po_line_id
                      AND poll.approved_flag = 'Y'
                      AND Nvl(poll.cancel_flag,'N') = 'N'
                      -- AND poll.closed_code = 'OPEN' --Bug 2859355
                      AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                      AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                      AND poll.ship_to_organization_id = p_organization_id
                      AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND (    (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                  )
             ORDER BY 1,2 ;
         ELSE
           --Both Inventory Item Id and Item Desc are Null
           --And also Both Item Id and Item Desc won't be passed together.
            OPEN x_doc_num_lov FOR
              SELECT /*+index(POH PO_HEADERS_U2) */
                  -- DISTINCT
                  -- DOCTYPE PO
                  meaning FIELD0 ,
                  poh.segment1 FIELD1 ,
                  to_char(poh.po_header_id) FIELD2 ,
                  poh.type_lookup_code FIELD3 ,
                  wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                  MO_GLOBAL.get_ou_name(poh.org_id) FIELD5 ,   --<R12 MOAC>
                  PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                  to_char(poh.vendor_id) FIELD7 ,
                  to_char(poh.vendor_site_id) FIELD8 ,
                  'Vendor' FIELD9 ,
                  poh.note_to_receiver FIELD10 ,
                  NULL FIELD11 ,
                  NULL FIELD12 ,
                  NULL FIELD13 ,
                  lookup_code FIELD14 ,
                  to_char(poh.org_id) FIELD15    --<R12 MOAC>
              FROM po_headers_trx_v poh,  -- CLM project, bug 9403291
                  fnd_lookup_values_vl flv
              WHERE flv.lookup_code = 'PO'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  -- Bug 2859355 Added the Extra conditions for poh.
                  AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                  AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                  AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                  AND poh.segment1 LIKE (p_doc_number||l_append)
                  AND EXISTS
                  (
                  SELECT
                      'Valid PO Shipments'
                  FROM po_line_locations_trx_v poll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                     , mtl_parameters mp,
                       rcv_parameters rp
--  End for Bug 7440217
                  WHERE poh.po_header_id = poll.po_header_id
                      AND poll.approved_flag = 'Y'
                      AND Nvl(poll.cancel_flag,'N') = 'N'
                      -- AND poll.closed_code = 'OPEN' --Bug 2859355
                      AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                      AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                      AND poll.ship_to_organization_id = p_organization_id
                      AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND (    (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                  )
             ORDER BY 1,2 ;
         END IF;  --Check for Item Id or Desc value
       ELSIF NVL(p_doc_type,'ALL') = 'RMA' THEN
          OPEN x_doc_num_lov FOR
            -- This Select Handles RMAs
            SELECT DISTINCT
                -- DOCTYPE RMA
                meaning FIELD0,
                to_char(OEH.ORDER_NUMBER) FIELD1,
                to_char(OEL.HEADER_ID) FIELD2,
                OTT_TL.NAME FIELD3, --OLT.NAME                FIELD3,--bug3173013
                NULL FIELD4, --LSP
                NULL FIELD5,
                OTT_ALL.ORDER_CATEGORY_CODE FIELD6, --OLT.ORDER_CATEGORY_CODE FIELD5,
                to_char(OESOLD.CUSTOMER_ID) FIELD7,
                /*TCA Cleanup */
                --OEC.customer_name FIELD6,
                --OEC.customer_number FIELD7,
                PARTY.party_name FIELD8,
                PARTY.party_number FIELD9,
                NULL FIELD10,
                NULL FIELD11,
                NULL FIELD12,
                NULL FIELD13,
                lookup_code FIELD14 ,
                to_char(oel.org_id) FIELD15
            FROM fnd_lookup_values_vl flv,
                OE_ORDER_LINES_all OEL,
                OE_ORDER_HEADERS_all OEH,
                --OE_LINE_TYPES_V OLT,    --bug3173013
                OE_TRANSACTION_TYPES_TL OTT_TL,
                OE_TRANSACTION_TYPES_ALL OTT_ALL,
                OE_SOLD_TO_ORGS_V OESOLD,
                --WF_ITEM_ACTIVITY_STATUSES WF,
                --WF_PROCESS_ACTIVITIES WPA,
                --RA_CUSTOMERS OEC
                HZ_PARTIES PARTY,
                HZ_CUST_ACCOUNTS CUST_ACCT
            WHERE flv.lookup_code = 'RMA'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND OEL.LINE_CATEGORY_CODE='RETURN'
                AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
                AND OEL.HEADER_ID = OEH.HEADER_ID
                AND OEL.SOLD_TO_ORG_ID = OESOLD.ORGANIZATION_ID
                --AND OESOLD.CUSTOMER_ID = oec.customer_id /*TCA Cleanup */
		--Bug5417779: oesold.customer_id should be joined with cust_acct.cust_account_id
		AND OESOLD.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                AND CUST_ACCT.party_id = PARTY.party_id
                --AND OEL.LINE_TYPE_ID = OLT.LINE_TYPE_ID--bug3173013
                AND OEH.ORDER_TYPE_ID = OTT_ALL.TRANSACTION_TYPE_ID
                AND OTT_ALL.ORDER_CATEGORY_CODE in ('MIXED', 'RETURN')
                AND OTT_ALL.TRANSACTION_TYPE_ID = OTT_TL.TRANSACTION_TYPE_ID
                AND OTT_TL.LANGUAGE = USERENV('LANG')
                AND OEH.BOOKED_FLAG='Y'
                AND OEH.OPEN_FLAG='Y'
                AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
                AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
                --
                -- The following lines are commented for Performance Improvement
                -- instead flow_status_code is used from oel
                --AND WPA.ACTIVITY_ITEM_TYPE = 'OEOL'
                --AND WPA.ACTIVITY_NAME = 'RMA_WAIT_FOR_RECEIVING'
                --AND WF.ITEM_TYPE = 'OEOL'
                --AND WF.PROCESS_ACTIVITY = WPA.INSTANCE_ID
                --AND WF.ACTIVITY_STATUS = 'NOTIFIED'
                --AND OEL.LINE_ID = TO_NUMBER(WF.ITEM_KEY)
                --
                AND oeh.order_number LIKE (p_doc_number)
                AND OEL.inventory_item_id LIKE Nvl(p_inventory_item_id,'%')
            ORDER BY 1,2 ;
       ELSIF NVL(p_doc_type,'ALL') = 'INTSHIP' THEN
          OPEN x_doc_num_lov FOR
            -- This Select Handles Internal Sales Order , Org Transfer
            SELECT DISTINCT
                -- DOCTYPE INTSHIP
                meaning FIELD0,
                sh.shipment_num FIELD1,
                to_char(sh.shipment_header_id) FIELD2,
                to_char(sh.shipped_date) FIELD3,
                NULL FIELD4, --LSP
                NULL FIELD5 ,   --<R12 MOAC>
                to_char(sh.expected_receipt_date) FIELD6,
                to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                Decode(sh.receipt_source_code,'VENDOR','Vendor',sh.receipt_source_code) FIELD9, --bug fix 3939003
                sh.packing_slip FIELD10,
                sh.bill_of_lading FIELD11,
                sh.waybill_airbill_num FIELD12,
                sh.freight_carrier_code FIELD13,
                lookup_code FIELD14,
                NULL FIELD15    --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                rcv_shipment_headers sh,
                rcv_shipment_lines sl
            WHERE flv.lookup_code = 'INTSHIP'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND sh.shipment_num IS NOT NULL
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                AND sh.receipt_source_code IN ('INTERNAL ORDER','INVENTORY')
                AND EXISTS
                (
                SELECT
                    'available supply'
                FROM mtl_supply ms
                WHERE ms.to_organization_id = p_organization_id
                    AND ms.shipment_header_id = sh.shipment_header_id
                )
                -- This was fix for bug 2740648/2752094
                AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                AND sh.shipment_num LIKE (p_doc_number)
                AND sl.item_id LIKE Nvl(p_inventory_item_id,'%')
                AND p_item_description IS NULL
            ORDER BY 1,2 ;
       ELSIF NVL(p_doc_type,'ALL') = 'ASN' THEN
         IF p_inventory_item_id IS NOT NULL THEN
            OPEN x_doc_num_lov FOR
              -- This Select Handles ASN
              SELECT DISTINCT
                  -- DOCTYPE ASN
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,   --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14,
                  NULL FIELD15    --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'ASN'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type in ('ASN','ASBN')
                  AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
                  -- This was fix for bug 2774080
                  AND sl.item_id = p_inventory_item_id
              ORDER BY 1,2 ;
         ELSIF p_item_description IS NOT NULL THEN
            OPEN x_doc_num_lov FOR
              -- This Select Handles ASN
              SELECT DISTINCT
                  -- DOCTYPE ASN
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,  --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14,
                  NULL FIELD15    --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'ASN'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type in ('ASN','ASBN')
                  AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
                  -- This was fix for bug 2774080
                  AND sl.item_description like p_item_description || '%'
              ORDER BY 1,2 ;
         ELSE
         --Both Inventory Item Id and Item Desc are Null
         --And also Both Item Id and Item Desc won't be passed together.
            OPEN x_doc_num_lov FOR
              SELECT DISTINCT
                  -- DOCTYPE ASN
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,    --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14 ,
                  NULL FIELD15      --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'ASN'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type IN ('ASN','ASBN')
                  AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
               ORDER BY 1,2 ;
         END IF ;  --Check for Item Id or Desc value
--  For Bug 7440217 Added a the followign code for the documnet type as LCM
     ELSIF NVL(p_doc_type,'ALL') = 'LCM' THEN
         IF p_inventory_item_id IS NOT NULL THEN
            OPEN x_doc_num_lov FOR
              -- This Select Handles LCM
              SELECT DISTINCT
                  -- DOCTYPE LCM
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,   --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14,
                  NULL FIELD15    --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'LCM'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type in ('LCM')
                  AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
                  -- This was fix for bug 2774080
                  AND sl.item_id = p_inventory_item_id
              ORDER BY 1,2 ;
         ELSIF p_item_description IS NOT NULL THEN
            OPEN x_doc_num_lov FOR
              -- This Select Handles LCM
              SELECT DISTINCT
                  -- DOCTYPE LCM
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,  --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14,
                  NULL FIELD15    --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'LCM'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type in ('LCM')
                  AND sl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
                  -- This was fix for bug 2774080
                  AND sl.item_description like p_item_description || '%'
              ORDER BY 1,2 ;
         ELSE
         --Both Inventory Item Id and Item Desc are Null
         --And also Both Item Id and Item Desc won't be passed together.
            OPEN x_doc_num_lov FOR
              SELECT DISTINCT
                  -- DOCTYPE LCM
                  meaning FIELD0,
                  sh.shipment_num FIELD1,
                  to_char(sh.shipment_header_id) FIELD2,
                  to_char(sh.shipped_date) FIELD3,
                  NULL FIELD4, --LSP
                  NULL FIELD5 ,    --<R12 MOAC>
                  to_char(sh.expected_receipt_date) FIELD6,
                  to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                  Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                  Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                  sh.packing_slip FIELD10,
                  sh.bill_of_lading FIELD11,
                  sh.waybill_airbill_num FIELD12,
                  sh.freight_carrier_code FIELD13,
                  lookup_code FIELD14 ,
                  NULL FIELD15      --<R12 MOAC>
              FROM fnd_lookup_values_vl flv,
                  rcv_shipment_headers sh,
                  rcv_shipment_lines sl
              WHERE flv.lookup_code = 'LCM'
                  AND flv.lookup_type = 'DOC_TYPE'
                  AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                  AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                  AND flv.enabled_flag = 'Y'
                  AND sh.shipment_num IS NOT NULL
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  AND sh.receipt_source_code = 'VENDOR'
                  AND sl.shipment_line_status_code <> 'CANCELLED'
                  AND sh.shipment_header_id = sl.shipment_header_id
                  AND sl.to_organization_id = p_organization_id
                  -- This was fix for bug 2740648/2752094
                  AND sh.asn_type IN ('LCM')
                  AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                  AND sh.shipment_num LIKE (p_doc_number)
               ORDER BY 1,2 ;
         END IF ;  --Check for Item Id or Desc value
--  End for Bug 7440217
       ELSIF NVL(p_doc_type,'ALL') = 'REQ' THEN
         OPEN x_doc_num_lov FOR
            -- This Select Handles Requisitions
          SELECT DISTINCT
              meaning FIELD0,
              prh.segment1 FIELD1,
              to_char(prh.requisition_header_id) FIELD2,
              prh.description FIELD3,
              NULL FIELD4, --LSP
              MO_GLOBAL.get_ou_name (prh.org_id) FIELD5 ,     --<R12 MOAC>
              NULL FIELD6,
              NULL FIELD7,
              NULL FIELD8,
              NULL FIELD9,
              NULL FIELD10,
              NULL FIELD11,
              NULL FIELD12,
              NULL FIELD13,
              lookup_code FIELD14 ,
              to_char(prh.org_id) FIELD15        --<R12 MOAC>
          FROM fnd_lookup_values_vl flv,
              po_req_headers_trx_v prh,  -- CLM project, bug 9403291
              po_req_lines_trx_v prl     -- CLM project, bug 9403291
          WHERE flv.lookup_code = 'REQ'
              AND flv.lookup_type = 'DOC_TYPE'
              AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
              AND nvl(flv.end_date_active,sysdate) >= SYSDATE
              AND flv.enabled_flag = 'Y'
              AND Nvl(prl.cancel_flag,'N') = 'N'
              AND prl.destination_organization_id = p_organization_id
              AND prh.requisition_header_id = prl.requisition_header_id
              AND prh.authorization_status || '' = 'APPROVED'
              AND prh.segment1 LIKE (p_doc_number)
              AND EXISTS
              (
              SELECT
                  1
              FROM rcv_shipment_lines rsl
              WHERE rsl.requisition_line_id = prl.requisition_line_id
                  AND rsl.routing_header_id > 0 --Bug 3349131
                  AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                  AND rsl.item_id LIKE Nvl(p_inventory_item_id,rsl.item_id)
              )
              AND p_item_description IS NULL
          ORDER BY 1,2 ;
       ELSIF NVL(p_doc_type,'ALL') = 'ALL' THEN
           OPEN x_doc_num_lov FOR
             -- This select takes care of Vendor Item and any non-expense item
             -- and cross ref item case.
             SELECT /*+index(POH PO_HEADERS_U2) */
                DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5 ,     --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
                lookup_code FIELD14 ,
                to_char(poh.org_id) FIELD15       --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND EXISTS
                (
                SELECT
                    'Valid PO Shipments'
                FROM po_lines_trx_v pl , -- CLM project, bug 9403291
                     po_line_locations_trx_v poll --CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                   , mtl_parameters mp,
                     rcv_parameters rp
--  End for Bug 7440217
                WHERE pl.po_header_id = poh.po_header_id
                    AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num, Nvl(pl.vendor_product_num,' '))
                    AND Nvl(pl.item_id,-999) LIKE Nvl(p_inventory_item_id,'%')
                    AND poh.po_header_id = poll.po_header_id
                    AND pl.po_line_id = poll.po_line_id
                    AND poll.approved_flag = 'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    -- AND poll.closed_code = 'OPEN' -- Bug 2859335
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                    AND poll.ship_to_organization_id = p_organization_id
                    AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                    AND mp.organization_id = p_organization_id
                    AND rp.organization_id = p_organization_id
                    AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                )
                AND p_item_description IS NULL
            UNION
            -- This Select Handles Substitute Items
            SELECT /*+index(POH PO_HEADERS_U2) */
                DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5,     --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
                lookup_code FIELD14 ,
                to_char(poh.org_id) FIELD15       --<R12 MOAC>
            FROM po_headers_trx_v poh, --CLM project, bug 9403291
                fnd_lookup_values_vl flv
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND EXISTS
                (
                SELECT
                    'Valid PO Shipments'
                FROM po_lines_trx_v pl , -- CLM project, bug 9403291
                    mtl_related_items mri ,
                    mtl_system_items_kfv msi ,
                    po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                  , mtl_parameters mp,
                    rcv_parameters rp
--  End for Bug 7440217
                WHERE msi.organization_id = p_organization_id
                    AND
                    (
                        (
                            mri.related_item_id = msi.inventory_item_id
                            AND pl.item_id = mri.inventory_item_id
                            AND msi.inventory_item_id LIKE p_inventory_item_id
                        )
                        OR
                        (
                            mri.inventory_item_id = msi.inventory_item_id
                            AND pl.item_id = mri.related_item_id
                            AND mri.reciprocal_flag = 'Y'
                            AND msi.inventory_item_id LIKE p_inventory_item_id
                        )
                    )
                    AND pl.po_header_id = poh.po_header_id
                    AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                    AND poh.po_header_id = poll.po_header_id
                    AND pl.po_line_id = poll.po_line_id
                    AND poll.approved_flag = 'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                    AND poll.ship_to_organization_id = p_organization_id
                    AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                    AND mp.organization_id = p_organization_id
                    AND rp.organization_id = p_organization_id
                    AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                )
                AND p_item_description IS NULL
            UNION
            -- This Select Handles Expense Items
            SELECT /*+index(POH PO_HEADERS_U2) */
                DISTINCT
                -- DOCTYPE PO
                meaning FIELD0 ,
                poh.segment1 FIELD1 ,
                to_char(poh.po_header_id) FIELD2 ,
                poh.type_lookup_code FIELD3 ,
                wms_deploy.get_po_client_name(poh.po_header_id)  FIELD4 ,--LSP
                MO_GLOBAL.get_ou_name(poh.org_id) FIELD5 ,    --<R12 MOAC>
                PO_VENDORS_SV2.GET_VENDOR_NAME_FUNC(POH.VENDOR_ID) FIELD6 ,
                to_char(poh.vendor_id) FIELD7 ,
                to_char(poh.vendor_site_id) FIELD8 ,
                'Vendor' FIELD9 ,
                poh.note_to_receiver FIELD10 ,
                NULL FIELD11 ,
                NULL FIELD12 ,
                NULL FIELD13 ,
                lookup_code FIELD14 ,
                to_char(poh.org_id) FIELD15        --<R12 MOAC>
            FROM po_headers_trx_v poh, -- CLM project, bug 9403291
                fnd_lookup_values_vl flv
            WHERE flv.lookup_code = 'PO'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                -- Bug 2859355 Added the Extra conditions for poh.
                AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','PLANNED', 'BLANKET','CONTRACT')
                AND NVL(POH.CANCEL_FLAG, 'N') IN ('N', 'I')
                AND NVL(POH.CLOSED_CODE, 'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3152693
                AND poh.segment1 LIKE (p_doc_number||l_append)
                AND EXISTS
                (
                SELECT
                    'Valid PO Shipments'
                FROM po_lines_trx_v pl ,  -- CLM project, bug 9403291
                     po_line_locations_trx_v poll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                   , mtl_parameters mp,
                     rcv_parameters rp
--  End for Bug 7440217
                WHERE pl.item_id IS NULL
                    AND pl.item_description LIKE p_item_description||'%'
                    AND pl.po_header_id = poh.po_header_id
                    AND Nvl(pl.vendor_product_num,' ') = Nvl(p_vendor_prod_num,Nvl(pl.vendor_product_num,' '))
                    AND poh.po_header_id = poll.po_header_id
                    AND pl.po_line_id = poll.po_line_id
                    AND Nvl(poll.approved_flag,'N') = 'Y'
                    AND Nvl(poll.cancel_flag,'N') = 'N'
                    -- AND poll.closed_code = 'OPEN' --Bug 2859355
                    AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                    AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                    AND poll.ship_to_organization_id = p_organization_id
                    AND poll.payment_type IS NULL  --R12 excludes all Complex Work POs (Bug4236155)
--  For Bug 7440217 Checking if it is LCM enabled
                    AND mp.organization_id = p_organization_id
                    AND rp.organization_id = p_organization_id
                    AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                )
                AND p_item_description IS NOT NULL
            UNION ALL
            -- This Select Handles RMAs
            SELECT DISTINCT
                -- DOCTYPE RMA
                meaning FIELD0,
                to_char(OEH.ORDER_NUMBER) FIELD1,
                to_char(OEL.HEADER_ID) FIELD2,
                OTT_TL.NAME FIELD3, --OLT.NAME                FIELD3,--bug3173013
                NULL FIELD4, --LSP
                NULL FIELD5,                    --<R12 MOAC>
                OTT_ALL.ORDER_CATEGORY_CODE FIELD6, --OLT.ORDER_CATEGORY_CODE FIELD5,
                to_char(OESOLD.CUSTOMER_ID) FIELD7,
                /* TCA Cleanup */
                PARTY.party_name FIELD8,
                PARTY.party_number FIELD9,
                --OEC.customer_name FIELD7,
                --OEC.customer_number FIELD8,
                NULL FIELD10,
                NULL FIELD11,
                NULL FIELD12,
                NULL FIELD13,
                lookup_code FIELD14 ,
                to_char(oel.org_id) FIELD15     --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                OE_ORDER_LINES_all OEL,
                OE_ORDER_HEADERS_all OEH,
                --OE_LINE_TYPES_V OLT,    --bug3173013
                OE_TRANSACTION_TYPES_TL OTT_TL,
                OE_TRANSACTION_TYPES_ALL OTT_ALL,
                OE_SOLD_TO_ORGS_V OESOLD,
                --WF_ITEM_ACTIVITY_STATUSES WF,
                --WF_PROCESS_ACTIVITIES WPA,
                --RA_CUSTOMERS OEC /*TCA Cleanup */
                HZ_PARTIES PARTY,
                HZ_CUST_ACCOUNTS CUST_ACCT
            WHERE flv.lookup_code = 'RMA'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND OEL.LINE_CATEGORY_CODE='RETURN'
                AND nvl(OEL.SHIP_FROM_ORG_ID, OEH.SHIP_FROM_ORG_ID) = p_organization_id
                AND OEL.HEADER_ID = OEH.HEADER_ID
                AND OEL.SOLD_TO_ORG_ID = OESOLD.ORGANIZATION_ID
                --AND OESOLD.CUSTOMER_ID = oec.customer_id /*TCA Cleanup */
		--Bug5417779: oesold.customer_id should be joined with cust_acct.cust_account_id
	        AND OESOLD.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                AND CUST_ACCT.PARTY_ID = PARTY.party_id
                --AND OEL.LINE_TYPE_ID = OLT.LINE_TYPE_ID--bug3173013
                AND OEH.ORDER_TYPE_ID = OTT_ALL.TRANSACTION_TYPE_ID
                AND OTT_ALL.ORDER_CATEGORY_CODE in ('MIXED', 'RETURN')
                AND OTT_ALL.TRANSACTION_TYPE_ID = OTT_TL.TRANSACTION_TYPE_ID
                AND OTT_TL.LANGUAGE = USERENV('LANG')
                AND OEH.BOOKED_FLAG='Y'
                AND OEH.OPEN_FLAG='Y'
                AND OEL.ORDERED_QUANTITY > NVL(OEL.SHIPPED_QUANTITY,0)
                AND OEL.FLOW_STATUS_CODE = 'AWAITING_RETURN'
                --
                -- The following lines are commented for Performance Improvement
                -- instead flow_status_code is used from oel
                --AND WPA.ACTIVITY_ITEM_TYPE = 'OEOL'
                --AND WPA.ACTIVITY_NAME = 'RMA_WAIT_FOR_RECEIVING'
                --AND WF.ITEM_TYPE = 'OEOL'
                --AND WF.PROCESS_ACTIVITY = WPA.INSTANCE_ID
                --AND WF.ACTIVITY_STATUS = 'NOTIFIED'
                --AND OEL.LINE_ID = TO_NUMBER(WF.ITEM_KEY)
                --
                AND oeh.order_number LIKE (p_doc_number)
                AND OEL.inventory_item_id LIKE Nvl(p_inventory_item_id,'%')
                AND p_item_description IS NULL
            UNION ALL
             -- This Select Handles Internal Sales Order , Org Transfer
            SELECT DISTINCT
                -- DOCTYPE INTSHIP
                meaning FIELD0,
                sh.shipment_num FIELD1,
                to_char(sh.shipment_header_id) FIELD2,
                to_char(sh.shipped_date) FIELD3,
                NULL FIELD4, --LSP
                NULL FIELD5 ,     --<R12 MOAC>
                to_char(sh.expected_receipt_date) FIELD6,
                to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                Decode(sh.receipt_source_code,'VENDOR','Vendor',sh.receipt_source_code) FIELD9, --bug fix 3939003
                sh.packing_slip FIELD10,
                sh.bill_of_lading FIELD11,
                sh.waybill_airbill_num FIELD12,
                sh.freight_carrier_code FIELD13,
                lookup_code FIELD14,
                NULL FIELD15     --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                rcv_shipment_headers sh,
                rcv_shipment_lines sl
            WHERE flv.lookup_code = 'INTSHIP'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE )<= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND sh.shipment_num IS NOT NULL
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                AND sh.receipt_source_code IN ('INTERNAL ORDER','INVENTORY')
                AND EXISTS
                (
                SELECT
                    'available supply'
                FROM mtl_supply ms
                WHERE ms.to_organization_id = p_organization_id
                    AND ms.shipment_header_id = sh.shipment_header_id
                )
                -- This was fix for bug 2740648/2752094
                AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                AND sh.shipment_num LIKE (p_doc_number)
                AND sl.item_id like Nvl(p_inventory_item_id,'%')
                AND p_item_description IS NULL
            UNION ALL
            -- This Select Handles ASN
            SELECT DISTINCT
                -- DOCTYPE ASN
                meaning FIELD0,
                sh.shipment_num FIELD1,
                to_char(sh.shipment_header_id) FIELD2,
                to_char(sh.shipped_date) FIELD3,
                NULL FIELD4, --LSP
                NULL FIELD5 ,      --<R12 MOAC>
                to_char(sh.expected_receipt_date) FIELD6,
                to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                sh.packing_slip FIELD10,
                sh.bill_of_lading FIELD11,
                sh.waybill_airbill_num FIELD12,
                sh.freight_carrier_code FIELD13,
                lookup_code FIELD14,
                NULL FIELD15      --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                rcv_shipment_headers sh,
                rcv_shipment_lines sl
            WHERE flv.lookup_code = 'ASN'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND sh.shipment_num IS NOT NULL
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                AND sh.receipt_source_code = 'VENDOR'
                AND sl.shipment_line_status_code <> 'CANCELLED'
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                -- This was fix for bug 2740648/2752094
                AND sh.asn_type in ('ASN','ASBN')
                AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                AND sh.shipment_num LIKE (p_doc_number)
                -- This was fix for bug 2774080
                AND
                (
                    (
                            p_item_description IS NULL
                        AND sl.item_id LIKE Nvl(p_inventory_item_id,'%')

                    )
                    OR
                    (
                            p_inventory_item_id IS NULL
                        AND sl.item_description LIKE Nvl(p_item_description , '%' )
                    )
                )
--  For Bug 7440217 adding all LCM Docs also to the LOV query
       UNION ALL
            -- This Select Handles LCM
            SELECT DISTINCT
                -- DOCTYPE LCM
                meaning FIELD0,
                sh.shipment_num FIELD1,
                to_char(sh.shipment_header_id) FIELD2,
                to_char(sh.shipped_date) FIELD3,
                NULL FIELD4, --LSP
                NULL FIELD5 ,      --<R12 MOAC>
                to_char(sh.expected_receipt_date) FIELD6,
                to_char(Decode(sh.receipt_source_code, 'VENDOR',sh.vendor_id, sl.from_organization_id)) FIELD7,
                Substr( rcv_intransit_sv.rcv_get_org_name(sh.receipt_source_code,sh.vendor_id, sl.from_organization_id),1,80) FIELD8,
                Decode(sh.receipt_source_code,'VENDOR','Vendor','Organization') FIELD9,
                sh.packing_slip FIELD10,
                sh.bill_of_lading FIELD11,
                sh.waybill_airbill_num FIELD12,
                sh.freight_carrier_code FIELD13,
                lookup_code FIELD14,
                NULL FIELD15      --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                rcv_shipment_headers sh,
                rcv_shipment_lines sl
            WHERE flv.lookup_code = 'LCM'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND sh.shipment_num IS NOT NULL
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                AND sh.receipt_source_code = 'VENDOR'
                AND sl.shipment_line_status_code <> 'CANCELLED'
                AND sh.shipment_header_id = sl.shipment_header_id
                AND sl.to_organization_id = p_organization_id
                -- This was fix for bug 2740648/2752094
                AND sh.asn_type in ('LCM')
                AND sl.shipment_line_status_code IN ('EXPECTED','PARTIALLY RECEIVED')
                AND sh.shipment_num LIKE (p_doc_number)
                -- This was fix for bug 2774080
                AND
                (
                    (
                            p_item_description IS NULL
                        AND sl.item_id LIKE Nvl(p_inventory_item_id,'%')

                    )
                    OR
                    (
                            p_inventory_item_id IS NULL
                        AND sl.item_description LIKE Nvl(p_item_description , '%' )
                    )
                )
--  End for Bug 7440217
            UNION ALL
            -- This Select Handles Requisitions
            SELECT DISTINCT
                meaning FIELD0,
                prh.segment1 FIELD1,
                to_char(prh.requisition_header_id) FIELD2,
                prh.description FIELD3,
                NULL FIELD4, --LSP
                MO_GLOBAL.get_ou_name (prh.org_id) FIELD5 ,  --<R12 MOAC>
                NULL FIELD6,
                NULL FIELD7,
                NULL FIELD8,
                NULL FIELD9,
                NULL FIELD10,
                NULL FIELD11,
                NULL FIELD12,
                NULL FIELD13,
                lookup_code FIELD14 ,
                to_char(prh.org_id) FIELD15             --<R12 MOAC>
            FROM fnd_lookup_values_vl flv,
                po_req_headers_trx_v prh, -- CLM project, bug 9403291
                po_req_lines_trx_v prl    -- CLM project, bug 9403291
            WHERE flv.lookup_code = 'REQ'
                AND flv.lookup_type = 'DOC_TYPE'
                AND nvl(flv.start_date_active, SYSDATE) <= SYSDATE
                AND nvl(flv.end_date_active,sysdate) >= SYSDATE
                AND flv.enabled_flag = 'Y'
                AND Nvl(prl.cancel_flag,'N') = 'N'
                AND prl.destination_organization_id = p_organization_id
                AND prh.requisition_header_id = prl.requisition_header_id
                AND prh.authorization_status || '' = 'APPROVED'
                AND prh.segment1 LIKE (p_doc_number)
                AND EXISTS
                (
                SELECT
                    1
                FROM rcv_shipment_lines rsl
                WHERE rsl.requisition_line_id = prl.requisition_line_id
                    AND rsl.routing_header_id > 0 --Bug 3349131
                    AND rsl.shipment_line_status_code <> 'FULLY RECEIVED'
                    AND rsl.item_id LIKE Nvl(p_inventory_item_id,rsl.item_id)
                )
                AND p_item_description IS NULL
            ORDER BY 1,2 ;
       END IF;  -- Check for p_doc_type
     END IF ; --  Check for p_mobile_form
  END GET_DOC_LOV ;

--      Name: GET_PO_LINE_ITEM NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_header_id      which restricts LOV SQL to the PO
--       p_po_line_num which restricts the LOV to the user input text.
--
--      Output parameters:
--       x_po_line_num_lov returns LOV rows as reference cursor
--
--      Functions: This API returns PO Line numbers for a given PO and Item Id
--
PROCEDURE GET_PO_LINE_ITEM_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
            p_organization_id IN NUMBER,
            p_po_header_id IN NUMBER,
            p_mobile_form IN VARCHAR2,
            p_po_line_num IN VARCHAR2,
                              p_inventory_item_id IN VARCHAR2)
  IS
  po_line_number VARCHAR2(20);
BEGIN
   -- Added for bug 9776756
  if PO_CLM_INTG_GRP.is_clm_po(p_po_header_id,null,null,null) = 'Y' THEN
     po_line_number := p_po_line_num;
  else
  -- End of Bug 9776756
    BEGIN
      /* Start - Fix for Bug# 6640083 */
       -- po_line_number := to_char(to_number(p_po_line_num));
       -- This will convert String to number - Bug#6012703
       -- Commented the code for  Bug#6640083
      SELECT TRIM(LEADING '0' FROM p_po_line_num ) INTO po_line_number FROM Dual;
           -- This will trim leading zeroes - Bug#6640083
       /* End - Fix for Bug# 6640083 */
     EXCEPTION
     WHEN OTHERS then
       po_line_number := p_po_line_num;
     END;
  END IF; -- bug 9776756
   --  CLM project
   IF p_mobile_form = 'RECEIPT' THEN
     /*Bug#5612236. In the below query, replaced 'MTL_SYSTEM_ITEMS_KFV' with
       'MTL_SYSTEM_ITEMS_VL' and item desc is selected from this table.*/

      /*Bug # 8687063  : Because of the fix done for bug 6437363, the query was returning
       zero row for expense item (We do not enter item while creating PO in this case).
       For this case,we have value if item_id in po_lines_all table as null,
       Modified the AND clasue in such a way that MSI should not be checked for organization_id
       if po_lines_all.item_id is null */

      OPEN x_po_line_num_lov FOR
      -- Bug 6437363 : Modified the query for better performance.
  select distinct pl.line_num
             , pl.po_line_id
             , NVL(msi.description, pl.item_description)  -- Bug 10004703
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
             , msi.outside_operation_flag
             , inv_ui_item_lovs.get_conversion_rate(mum.uom_code,
                                   p_organization_id,
                                   pl.Item_Id)
               uom_code
          from po_lines_trx_v pl -- CLM project, bug 9403291
             , mtl_units_of_measure mum
             , mtl_system_items_vl msi
         where pl.item_id = msi.inventory_item_id (+)
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
 --        and msi.organization_id = p_organization_id -- Bug 6437363
           and (pl.item_id is null or msi.organization_id = p_organization_id)  --Bug 8687063
           and pl.po_header_id = p_po_header_id
     and exists (SELECT 'Valid PO Shipments'
                        FROM po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                           , mtl_parameters mp,
                             rcv_parameters rp
--  End for Bug 7440217
                       WHERE poll.po_header_id = pl.po_header_id
                         AND poll.po_line_id = pl.po_line_id
                         AND Nvl(poll.approved_flag,'N') =  'Y'
                         AND Nvl(poll.cancel_flag,'N') = 'N'
                         -- AND poll.closed_code = 'OPEN' -- Bug 2859355
                         AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                         AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
                         AND mp.organization_id = p_organization_id
                         AND rp.organization_id = p_organization_id
                         AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                  OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                     OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                             )
--  End for Bug 7440217
                         )
           AND pl.line_num LIKE (po_line_number)
           AND nvl(pl.item_id,-999) LIKE nvl(p_inventory_item_id,'%')
           UNION ALL
     select distinct pl.line_num
             , pl.po_line_id
             , NVL(msi.description, pl.item_description)  -- Bug 10004703
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
             , msi.outside_operation_flag
             , inv_ui_item_lovs.get_conversion_rate(mum.uom_code,
                                   p_organization_id,
                                   pl.Item_Id)
               uom_code
          from po_lines_trx_v pl -- CLM project, bug 9403291
             , mtl_units_of_measure mum
             , mtl_system_items_vl msi
             , mtl_related_items mri
         where msi.organization_id = p_organization_id -- Bug 6437363
           and msi.inventory_item_id = p_inventory_item_id -- Bug 6311550
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
           and pl.po_header_id = p_po_header_id
     and exists (SELECT 'Valid PO Shipments'
                        FROM po_line_locations_trx_v poll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                           , mtl_parameters mp,
                             rcv_parameters rp
--  End for Bug 7440217
                       WHERE poll.po_header_id = pl.po_header_id
                         AND poll.po_line_id = pl.po_line_id
                         AND Nvl(poll.approved_flag,'N') =  'Y'
                         AND Nvl(poll.cancel_flag,'N') = 'N'
                         -- AND poll.closed_code = 'OPEN' --Bug 2859355
                         AND Nvl(poll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                         AND poll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED')
                         AND poll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
                         AND mp.organization_id = p_organization_id
                         AND rp.organization_id = p_organization_id
                         AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                  OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                      OR (NVL(poll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                             )
--  End for Bug 7440217
                         )
                         AND pl.line_num LIKE (po_line_number)
                         AND exists (select 'c'                               -- Bug 6437363
                                    from  MTL_RELATED_ITEMS MRI
                                    where MRI.RELATED_ITEM_ID = MSI.INVENTORY_ITEM_ID
                                      AND PL.ITEM_ID =  MRI.INVENTORY_ITEM_ID
                                    union all
                                    select 'c'
                                     from  MTL_RELATED_ITEMS MRI
                                     where MRI.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
                                       AND PL.ITEM_ID = MRI.RELATED_ITEM_ID
                                       AND MRI.RECIPROCAL_FLAG = 'Y'  )
                        order by 1;
    ELSE
      OPEN x_po_line_num_lov FOR
  select distinct pl.line_num
             , pl.po_line_id
             -- Bug 7274407
             , NVL(msi.description, pl.item_description)
             , pl.item_id
             , pl.item_revision
             , msi.concatenated_segments
       , msi.outside_operation_flag
             , inv_ui_item_lovs.get_conversion_rate(mum.uom_code,
                                   p_organization_id,
                                   pl.Item_Id)
               uom_code
  FROM rcv_supply rsup
             , mtl_units_of_measure mum
       , po_lines_trx_v pl -- CLM project, bug 9403291
             , mtl_system_items_vl msi
   WHERE rsup.po_line_id = pl.po_line_id
           and mum.UNIT_OF_MEASURE(+) = pl.UNIT_MEAS_LOOKUP_CODE
     AND pl.item_id = msi.inventory_item_id (+)
           and Nvl(msi.organization_id, p_organization_id) = p_organization_id
           and rsup.po_header_id = p_po_header_id
           AND pl.line_num LIKE (po_line_number)
         order by 1;
   END IF;
END GET_PO_LINE_ITEM_NUM_LOV;


PROCEDURE get_job_lov (x_job_lov OUT NOCOPY t_genref,
           p_organization_id IN NUMBER,
           p_po_header_id IN NUMBER,
           p_po_line_id IN NUMBER,
           p_item_id IN NUMBER,
           p_Job IN VARCHAR2,
                       p_po_release_id IN NUMBER DEFAULT NULL,  --Bug #3883926
		       p_shipment_header_id IN NUMBER DEFAULT NULL)--Added for Bug 9525003
  IS
BEGIN
  --Fix for Bug # 3883926
  --Added the IF clause to check whether Release Id is
  --passed or not and execute the appropriate query.
  IF p_po_release_id IS NOT NULL THEN
   OPEN x_job_lov FOR
     SELECT wojv.wip_entity_name
     , wojv.wip_entity_id
     , wolv.line_code
     , woov.operation_seq_num
     , woov.department_code
     , pda.po_distribution_id
     , (pda.quantity_ordered - pda.quantity_delivered)
     , woov.repetitive_schedule_id
     FROM po_headers_all phl
     , po_lines_all pla
     , po_distributions_all pda
     , po_releases_all prl
     , wip_osp_jobs_val_v wojv
     , wip_osp_lines_val_v wolv
     , wip_osp_operations_val_v woov
     WHERE phl.po_header_id = p_po_header_id
     AND phl.po_header_id = pla.po_header_id
     AND pla.po_line_id = nvl (p_po_line_id, pla.po_line_id)
     AND pla.item_id = nvl (p_item_id, pla.item_id)
     AND pla.po_line_id = pda.po_line_id
     --Bug # 3883926
     AND prl.po_header_id = phl.po_header_id
     AND prl.po_release_id = p_po_release_id
     AND prl.po_release_id = pda.po_release_id
     --Bug # 3883926
     AND wojv.wip_entity_id = pda.wip_entity_id
     AND wojv.organization_id = pda.destination_organization_id
     AND wojv.organization_id = p_organization_id
     AND wolv.line_id (+) = pda.wip_line_id
     AND wolv.organization_id (+) = pda.destination_organization_id
     AND woov.wip_entity_id = pda.wip_entity_id
     AND woov.organization_id = pda.destination_organization_id
     AND woov.operation_seq_num (+) = pda.wip_operation_seq_num
     AND nvl (woov.repetitive_schedule_id, -1) = nvl (pda.wip_repetitive_schedule_id, -1)
     AND wojv.wip_entity_name like (p_job)
     ORDER BY wojv.wip_entity_name;

      --Added for bug 9525003 - Start
  ELSIF p_shipment_header_id IS NOT NULL THEN
   OPEN x_job_lov FOR
     SELECT wojv.wip_entity_name
     , wojv.wip_entity_id
     , wolv.line_code
     , woov.operation_seq_num
     , woov.department_code
     , pda.po_distribution_id
     , (pda.quantity_ordered - pda.quantity_delivered)
     , woov.repetitive_schedule_id
     FROM po_headers_all phl
     , po_lines_all pla
     , po_distributions_all pda
     , wip_osp_jobs_val_v wojv
     , wip_osp_lines_val_v wolv
     , wip_osp_operations_val_v woov
     , rcv_shipment_headers shh
     , rcv_shipment_lines shl
     WHERE shh.shipment_header_id = p_shipment_header_id
     AND shl.shipment_header_id = shh.shipment_header_id
     AND phl.po_header_id =shl.po_header_id
     AND phl.po_header_id = pla.po_header_id
     AND pla.po_line_id = nvl (p_po_line_id, pla.po_line_id)
     AND pla.item_id = nvl (p_item_id, pla.item_id)
     AND pla.po_line_id = pda.po_line_id
     AND wojv.wip_entity_id = pda.wip_entity_id
     AND wojv.organization_id = pda.destination_organization_id
     AND wojv.organization_id = p_organization_id
     AND wolv.line_id (+) = pda.wip_line_id
     AND wolv.organization_id (+) = pda.destination_organization_id
     AND woov.wip_entity_id = pda.wip_entity_id
     AND woov.organization_id = pda.destination_organization_id
     AND woov.operation_seq_num (+) = pda.wip_operation_seq_num
     AND nvl (woov.repetitive_schedule_id, -1) = nvl (pda.wip_repetitive_schedule_id, -1)
     AND wojv.wip_entity_name like (p_job)
     ORDER BY wojv.wip_entity_name;
     --  End of bug 9525003

 ELSE
   OPEN x_job_lov FOR
     SELECT wojv.wip_entity_name
     , wojv.wip_entity_id
     , wolv.line_code
     , woov.operation_seq_num
     , woov.department_code
     , pda.po_distribution_id
     , (pda.quantity_ordered - pda.quantity_delivered)
     , woov.repetitive_schedule_id
     FROM po_headers_all phl
     , po_lines_all pla
     , po_distributions_all pda
     , wip_osp_jobs_val_v wojv
     , wip_osp_lines_val_v wolv
     , wip_osp_operations_val_v woov
     WHERE phl.po_header_id = p_po_header_id
     AND phl.po_header_id = pla.po_header_id
     AND pla.po_line_id = nvl (p_po_line_id, pla.po_line_id)
     AND pla.item_id = nvl (p_item_id, pla.item_id)
     AND pla.po_line_id = pda.po_line_id
     AND wojv.wip_entity_id = pda.wip_entity_id
     AND wojv.organization_id = pda.destination_organization_id
     AND wojv.organization_id = p_organization_id
     AND wolv.line_id (+) = pda.wip_line_id
     AND wolv.organization_id (+) = pda.destination_organization_id
     AND woov.wip_entity_id = pda.wip_entity_id
     AND woov.organization_id = pda.destination_organization_id
     AND woov.operation_seq_num (+) = pda.wip_operation_seq_num
     AND nvl (woov.repetitive_schedule_id, -1) = nvl (pda.wip_repetitive_schedule_id, -1)
     AND wojv.wip_entity_name like (p_job)
     ORDER BY wojv.wip_entity_name;
 END IF;
END get_job_lov;

PROCEDURE GET_PO_RELEASE_ITEM_LOV(x_po_release_num_lov OUT NOCOPY t_genref,
          p_organization_id IN NUMBER,
          p_po_header_id IN NUMBER,
          p_mobile_form IN VARCHAR2,
          p_po_release_num IN VARCHAR2,
          p_item_id IN NUMBER)
  IS
  po_release_number VARCHAR2(20);
BEGIN
    BEGIN
       /* Start - Fix for Bug# 6640083 */
       -- po_release_number := to_char(to_number(p_po_release_num));
       -- This will convert String to number - Bug#6012703
       -- Commented the code for  Bug#6640083
       SELECT TRIM(LEADING '0' FROM p_po_release_num ) INTO po_release_number FROM Dual;
           -- This will trim leading zeroes - Bug#6640083
       /* End - Fix for Bug# 6640083 */
     EXCEPTION
     WHEN OTHERS then
       po_release_number := p_po_release_num;
    END;
   IF p_mobile_form = 'RECEIPT' THEN
      OPEN x_po_release_num_lov FOR
        select distinct pr.release_num
        , pr.po_release_id
        , pr.release_date
        from po_releases_all pr
        , po_line_locations_all pll
        , po_lines_all pl
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
        , mtl_parameters mp
        , rcv_parameters rp
--  End for Bug 7440217
        where pr.po_header_id = p_po_header_id
        and nvl(pr.cancel_flag, 'N') = 'N'
        and nvl(pr.approved_flag, 'N') <> 'N'
        --and nvl(pr.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
        and nvl(pll.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED') --4350175
        AND pll.po_release_id = pr.po_release_id
        AND pll.po_header_id = pr.po_header_id
        AND pll.po_line_id = pl.po_line_id
        AND pll.po_header_id = pl.po_header_id
        AND ((p_item_id IS NOT NULL AND pl.item_id = p_item_id) OR
             p_item_id IS NULL)
        AND pr.release_num LIKE (po_release_number)
--  For Bug 7440217 Checking if it is LCM enabled
        AND mp.organization_id = p_organization_id
        AND rp.organization_id = p_organization_id
        AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                 OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                     OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
             )
--  End for Bug 7440217
               order by pr.release_num;
    ELSE
      OPEN x_po_release_num_lov FOR
        select distinct pr.release_num
        , pr.po_release_id
        , pr.release_date
        from rcv_supply rsup
        , po_releases_all pr
        where rsup.po_header_id = p_po_header_id
        --AND pr.org_id = p_organization_id
        and nvl(pr.cancel_flag, 'N') = 'N'
        and nvl(pr.approved_flag, 'N') <> 'N'
        AND rsup.po_release_id = pr.po_release_id
	AND pr.release_num LIKE (po_release_number)
        order by pr.release_num;
   END IF;
END GET_PO_RELEASE_ITEM_LOV;

-- Start of Bug 2442518

PROCEDURE GET_ITEM_LOV_RECEIVING (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER,
p_Concatenated_Segments               IN VARCHAR2,
p_poHeaderID                          IN VARCHAR2,
p_poReleaseID                         IN VARCHAR2,
p_poLineID                            IN VARCHAR2,
p_shipmentHeaderID                    IN VARCHAR2,
p_oeOrderHeaderID                     IN VARCHAR2,
p_reqHeaderID                         IN VARCHAR2,
p_projectId                           IN VARCHAR2,
p_taskId                              IN VARCHAR2,
p_pjmorg                              IN VARCHAR2,
p_crossreftype                        IN VARCHAR2,
p_from_lpn_id                         IN VARCHAR2
)

IS
-- Changes for GTIN CrossRef Type
--
g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;
g_crossref         VARCHAR2(40) := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
l_from_lpn_id VARCHAR2(400) := p_from_lpn_id;
l_append varchar2(2):='';

BEGIN

l_append:=wms_deploy.get_item_suffix_for_lov(p_Concatenated_Segments);

-- if  ( ( p_doctype = 'PO') or  (p_doctype = 'RMA') or (p_doctype = 'REQ') or (p_doctype = 'SHIP') )
-- then

-- CLM Project, change PO tables to PO views

if  (p_poHeaderID is not null       or
     p_poReleaseID is not null      or
     p_oeOrderHeaderID is not null  or
     p_shipmentHeaderID is not null or
     p_reqHeaderID is not null      or
     p_projectId is not null        or
     p_taskId is not null )
then

IF (p_from_lpn_id IS NULL) THEN
  l_from_lpn_id := NULL;
ELSIF (p_from_lpn_id IS NOT NULL AND p_from_lpn_id = '0') THEN
  l_from_lpn_id := NULL;
END IF;

-- *****************************
---- Case for Document Info already entered in the session , txn starts with document ID
-- *****************************

if (p_poHeaderID is not null ) then
-- *****************************
--- START  OF PO HEADER  ID SECTION
-- *****************************

  if  ( p_pjmorg = 1) then --and ( p_projectId is not null ) )  then

-- *****************************
---- Start of  PJM BASED Tran.
-- *****************************

      if (p_poReleaseID is not null) then
-- *****************************
--- releaseBased  PJM Transaction
-- *****************************
         open x_items for
         -- Bug# 6747729
         -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
         select concatenated_segments,
         inventory_item_id,
         description,
         Nvl(revision_qty_control_code,1),
         Nvl(lot_control_code, 1),
         Nvl(serial_number_control_code, 1),
         Nvl(restrict_subinventories_code, 2),
         Nvl(restrict_locators_code, 2),
         Nvl(location_control_code, 1),
         primary_uom_code,
         Nvl(inspection_required_flag, 'N'),
         Nvl(shelf_life_code, 1),
         Nvl(shelf_life_days,0),
         Nvl(allowed_units_lookup_code, 2),
         Nvl(effectivity_control,1),
         0,
         0,
         Nvl(default_serial_status_id,1),
         Nvl(serial_status_enabled,'N'),
         Nvl(default_lot_status_id,0),
         Nvl(lot_status_enabled,'N'),
         '',
         'N',
         inventory_item_flag,
         0,
	   wms_deploy.get_item_client_name(inventory_item_id),
         inventory_asset_flag,
         outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
         stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
         from mtl_system_items_vl /* Bug 5581528 */
         WHERE organization_id = p_Organization_Id
         and concatenated_segments like p_concatenated_segments||l_append
         and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
         and inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol
         where pol.po_header_id =   p_poHeaderID
         and exists (select 1
                       from po_line_locations_trx_v pll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                          , mtl_parameters mp,
                            rcv_parameters rp
--  End for Bug 7440217
                     WHERE NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                     and pll.po_header_id = p_poHeaderID
                     and pll.po_release_id = p_poReleaseID
                     and pll.po_line_id = pol.po_line_id
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                         )
--  End for Bug 7440217
                    )--Bug 3972931-Added the filter condition based on ship_to_organization_id
         and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
         where pd.po_header_id =  p_poHeaderID
         and pd.po_line_id = pol.po_line_id
         and pd.po_release_id = p_poReleaseID
         and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- Substitute Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
         msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        ,mtl_related_items mri
        ,mtl_system_items_vl msi /* Bug 5581528 */
        /*,mtl_system_items_kfv msia */ /* Bug 6334679*/
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1
                      from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                           where NVL(pll.closed_code,'OPEN')
                           not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                           and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                           and   pll.po_header_id = pol.po_header_id
                           and   pll.po_line_id = pol.po_line_id
                           and   pll.po_release_id = p_poReleaseID
                           and   pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                           AND   mp.organization_id = p_Organization_Id
                           AND   rp.organization_id = p_Organization_Id
                           AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                    OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                        OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                               )
--  End for Bug 7440217
                     )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
         msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_system_items_vl msi   /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     WHERE NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_release_id = p_poReleaseID
                     and pll.po_line_id = pol.po_line_id
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
        )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
  /* Bug 3972931-Added the following exists condition to restrict the PO receipt
  to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_Organization_Id
                      AND rp.organization_id = p_Organization_Id
                      AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                               OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                   OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                      )
  --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
         msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol  -- CLM project, bug 9403291
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll --CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     WHERE NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                     and pll.po_header_id = p_poHeaderID
                     and pll.po_release_id = p_poReleaseID
                     and pll.po_line_id = pol.po_line_id
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                    )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id = p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_release_id = p_poReleaseID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        ;
      elsif  (p_poLineID IS NOT NULL) then
-- *****************************
----- lineBased PJM Transaction
-- *****************************
        open x_items for
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag,
        outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
        stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from mtl_system_items_vl /* Bug 5581528 */
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments||l_append
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol -- CLM project, bug 9403291
        WHERE pol.po_header_id = p_poHeaderID
        and pol.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code, 'OPEN')
                     not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' )
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_line_id = p_poLineID
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                   )--Bug 3972931-Added the filter condition based on ship_to_organization_id
  and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- Substitute Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_related_items mri
       ,mtl_system_items_vl msi /* Bug 5581528 */
       /*,mtl_system_items_kfv msia */ /* Bug 6334679 */
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and pol.po_line_id = p_poLineID
         and exists (select 1
                      from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                          , mtl_parameters mp,
                            rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED') -- 3687249
                      and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                      and   pll.po_header_id = pol.po_header_id
                      and   pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_Organization_Id
                      AND rp.organization_id = p_Organization_Id
                      AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                               OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                   OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                         )
--  End for Bug 7440217
                     )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists ( select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_system_items_vl msi  /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code, 'OPEN')
                     not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING' , 'CLOSED') -- 3687249
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_line_id = p_poLineID
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                    )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_line_id = p_poLineID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists ( select 1 from po_distributions_trx_v pd
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = p_poLineID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organization entered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_Organization_Id
                       AND rp.organization_id = p_Organization_Id
                       AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                    )
        --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code, 'OPEN')
                      not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' )  -- 3687249
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = p_poLineID
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_Organization_Id
                      AND rp.organization_id = p_Organization_Id
                      AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                               OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                   OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                    )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and pd.po_line_id = p_poLineID
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        ;
      else
-- *****************************
--- headerBased PJM Transaction
--  Bug 4602289
--  In the first query PO_LINES_ALL is
--  joined to enforce a nested loop
--  which would perform better for queries
--  with/without item
--  HeaderBased PJM PO_LINES_U2 is enforced
--  In the query for Vendor item
--
-- *****************************
        open x_items for
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(mtl_system_items_vl.inspection_required_flag, 'N'), -- bug 4610452
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag,
        outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
        stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
	 from mtl_system_items_vl , /* Bug 5581528 */
             po_lines_trx_v pol   --CLM project, bug 9403291 -- bug 4602289
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments||l_append
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id = pol.item_id -- bug 4602289
        and pol.po_header_id = p_poHeaderID -- bug 4602289
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM Project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                          rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_line_id = pol.po_line_id
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                   )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists
        (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )

        UNION ALL
        -- Substitute Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        ,mtl_related_items mri
       ,mtl_system_items_vl msi /* Bug 5581528 */
       /*,mtl_system_items_kfv msia */ /* Bug 6334679 */
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1
                      from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                          , mtl_parameters mp,
                            rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                      and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                      and   pll.po_header_id = pol.po_header_id
                      and   pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_Organization_Id
                      AND rp.organization_id = p_Organization_Id
                      AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                               OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                   OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                      )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        and  exists
        (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        UNION ALL
	-- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
	select /*+ INDEX(PO_LINES_ALL PO_LINES_U2) */	 --bug 4602289
        distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_system_items_vl msi  /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
          WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code,'OPEN')  not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_line_id = pl.po_line_id
                     and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_Organization_Id
                     AND rp.organization_id = p_Organization_Id
                     AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                              OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                  OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                         )
--  End for Bug 7440217
                     )--Bug 3972931-Added the filter condition based on ship_to_organization_id
               and  exists
        (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        and  exists
        (select 1 from po_distributions_trx_v pd -- CLM project, bug 9403291
        where pd.po_header_id =  p_poHeaderID
        and pd.po_line_id = pol.po_line_id
        and ((p_projectId is null or pd.project_id = p_projectId)
               and (p_taskId is null or pd.task_id = p_taskId)
             )
        )
        /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_Organization_Id
                       AND rp.organization_id = p_Organization_Id
                       AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                       )
        --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_vl
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_trx_v pl  -- CLM project, bug 9403291
          WHERE pl.po_header_id = p_poHeaderID
          and exists (select 1
                        from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                           , mtl_parameters mp,
                             rcv_parameters rp
--  End for Bug 7440217
                       where NVL(pll.closed_code,'OPEN')
                       not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')  -- 3687249
                       and  pll.po_header_id =   p_poHeaderID and pll.po_line_id = pl.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_Organization_Id
                       AND rp.organization_id = p_Organization_Id
                       AND (   (NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(pll.lcm_flag,'N') = 'N')        -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                       )--Bug 3972931-Added the filter condition based on ship_to_organization_id
                       and  exists (select 1
                                      from po_distributions_trx_v pd -- CLM project, bug 9403291
                                     where pd.po_header_id =  p_poHeaderID
                                      and pd.po_line_id = pol.po_line_id
                                      and ((p_projectId is null or pd.project_id = p_projectId)
                                      and (p_taskId is null or pd.task_id = p_taskId)
                                   )
                      )
        )
        ;
      end if;
      -- End of PJM Based Tran
  else

-- *****************************
--- Start of not PJM BASED Tran.
-- *****************************

      if (p_poReleaseID is not null) then
-- *****************************
-- Release Based Transaction
-- *****************************
        open x_items for
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag,
        outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
        stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from mtl_system_items_vl /* Bug 5581528 */
        WHERE organization_id = p_Organization_Id
              and concatenated_segments like p_concatenated_segments||l_append
              and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
              and inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      WHERE NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_release_id = p_poReleaseID
                      and pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                   )
--  End for Bug 7440217
                      )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        UNION ALL
        -- Substitute ITEM SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_related_items mri
        ,mtl_system_items_vl msi /* Bug 5581528 */
       /*,mtl_system_items_kfv msia */ /* Bug 6334679 */
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
         (    mri.inventory_item_id = msi.inventory_item_id
         and pol.item_id = mri.related_item_id
         and mri.reciprocal_flag = 'Y'))
         and exists (select 1
                      from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                          , mtl_parameters mp,
                            rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')  -- 3687249
                      and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                      and   pll.po_header_id = pol.po_header_id
                      and   pll.po_line_id = pol.po_line_id
                      and   pll.po_release_id = p_poReleaseID
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND  mp.organization_id = p_organization_id
                      AND  rp.organization_id = p_organization_id
                      AND  ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                   )
--  End for Bug 7440217
                      )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        UNION ALL
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        , mtl_system_items_vl msi  /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol -- CLM project, bug 9403291
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      WHERE NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                      and pll.po_header_id = p_poHeaderID
                      and pll.po_release_id = p_poReleaseID
                      and pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                    )
--  End for Bug 7440217
                      )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_organization_id
                       AND rp.organization_id = p_organization_id
                       AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                            )
--  End for Bug 7440217

                       )
        --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pol.item_id FROM po_lines_trx_v pol -- CLM project, bug 9403291
        where pol.po_header_id =   p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      WHERE NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')
                      and pll.po_header_id = p_poHeaderID
                      and pll.po_release_id = p_poReleaseID
                      and pll.po_line_id = pol.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                      )--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        ;
      elsif  (p_poLineID IS NOT NULL) then
-- *****************************
--  Deafult Line Based  Tran
--- ***************************
        open x_items for
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag,
        outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
        stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from mtl_system_items_vl  /* Bug 5581528 */
        WHERE organization_id = p_Organization_Id
              and concatenated_segments like p_concatenated_segments||l_append
              and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
              and inventory_item_id IN (SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code, 'OPEN')
                      not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' )  -- 3687249
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = p_poLineID
                      and pll.ship_to_organization_id = p_Organization_Id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                    )
--  End for Bug 7440217
                      ))--Bug 3972931-Added the filter condition based on ship_to_organization_id
        UNION ALL
        -- Substitute Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_related_items mri
        ,mtl_system_items_vl msi /* Bug 5581528 */
        /*,mtl_system_items_kfv msia*/ /* Bug 6334679 */
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
        (    mri.inventory_item_id = msi.inventory_item_id
        and pol.item_id = mri.related_item_id
        and mri.reciprocal_flag = 'Y'))
        and pol.po_line_id = p_poLineID
        and exists (select 1
                     from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')  -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_organization_id
                     AND rp.organization_id = p_organization_id
                     AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                           OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                               OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                     and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                     and   pll.po_header_id = pol.po_header_id
                     and   pll.po_line_id = pol.po_line_id
                     and   pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        UNION ALL
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
         msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        ,mtl_system_items_vl msi  /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN (SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code, 'OPEN')
                      not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' )  -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                     )
--  End for Bug 7440217
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = p_poLineID
                      and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
  )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_organization_id
                       AND rp.organization_id = p_organization_id
                       AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id)
        --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN (SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and pl.po_line_id = p_poLineID
        and exists (select 1
                      from po_line_locations_trx_v pll  -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code, 'OPEN')
                     not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' ) -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_organization_id
                     AND rp.organization_id = p_organization_id
                     AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                           OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                               OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                     and  pll.po_header_id = p_poHeaderID
                     and pll.po_line_id = p_poLineID
                     and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        ;
      else
-- *****************************
--      Deafult headerBased  Tran
-- ***************************

        open x_Items for
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select concatenated_segments,
        inventory_item_id,
        description,
        Nvl(revision_qty_control_code,1),
        Nvl(lot_control_code, 1),
        Nvl(serial_number_control_code, 1),
        Nvl(restrict_subinventories_code, 2),
        Nvl(restrict_locators_code, 2),
        Nvl(location_control_code, 1),
        primary_uom_code,
        Nvl(inspection_required_flag, 'N'),
        Nvl(shelf_life_code, 1),
        Nvl(shelf_life_days,0),
        Nvl(allowed_units_lookup_code, 2),
        Nvl(effectivity_control,1),
        0,
        0,
        Nvl(default_serial_status_id,1),
        Nvl(serial_status_enabled,'N'),
        Nvl(default_lot_status_id,0),
        Nvl(lot_status_enabled,'N'),
        '',
        'N',
        inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag,
        outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
        stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from mtl_system_items_vl /* Bug 5581528 */
        WHERE organization_id = p_Organization_Id
        and concatenated_segments like p_concatenated_segments||l_append
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                      where NVL(pll.closed_code,'OPEN')
                      not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')   -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = pl.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        UNION ALL
        -- Substitute Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct msi.concatenated_segments,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'S',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_related_items mri
        ,mtl_system_items_vl msi /* Bug 5581528 */
       /*,mtl_system_items_kfv msia */ /* Bug 6334679 */
        where msi.organization_id =  p_organization_id
        and msi.concatenated_segments like  p_concatenated_segments||l_append
        and pol.po_header_id = p_poHeaderID
        and pol.item_id = msi.inventory_item_id
        and msi.organization_id = p_organization_id
        and ((    mri.related_item_id = msi.inventory_item_id
        and pol.item_id = mri.inventory_item_id) or
        (    mri.inventory_item_id = msi.inventory_item_id
        and pol.item_id = mri.related_item_id
        and mri.reciprocal_flag = 'Y'))
        and exists (select 1
                     from  po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')  -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_organization_id
                     AND rp.organization_id = p_organization_id
                     AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                           OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                               OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                         )
--  End for Bug 7440217
                     and   Nvl(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                     and   pll.po_header_id = pol.po_header_id
                     and   pll.po_line_id = pol.po_line_id
                     and   pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        UNION ALL
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol  -- CLM project, bug 9403291
        , mtl_system_items_vl msi  /* Bug 5581528 */
        where organization_id =  p_organization_id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and  pol.vendor_product_num IS NOT NULL
        and pol.po_header_id =  p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1
                       from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                          , mtl_parameters mp,
                            rcv_parameters rp
--  End for Bug 7440217
                       where NVL(pll.closed_code,'OPEN')
                       not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')   -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_organization_id
                       AND rp.organization_id = p_organization_id
                       AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                       and  pll.po_header_id = p_poHeaderID
                       and pll.po_line_id = pl.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        UNION ALL
        -- non item Master
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = p_poHeaderID
        and pol.item_description like  p_concatenated_segments
        /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_organization_id
                       AND rp.organization_id = p_organization_id
                       AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id)
        --End of fix for Bug 3972931
        UNION ALL
        -- Cross Ref  SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct mcr.cross_reference,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'C',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
         ' ',
         ' ' -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,mtl_cross_references mcr
        where msi.organization_id = p_organization_id
        and ( (mcr.cross_reference_type = p_crossreftype
               and mcr.cross_reference like  p_concatenated_segments
              ) or
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
        and mcr.inventory_item_id = msi.inventory_item_id
        and pol.item_id = msi.inventory_item_id
        and pol.po_header_id = p_poHeaderID
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
        and msi.inventory_item_id IN
        ( SELECT pl.item_id FROM po_lines_trx_v pl -- CLM project, bug 9403291
        WHERE pl.po_header_id = p_poHeaderID
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where NVL(pll.closed_code,'OPEN')
                     not in ('FINALLY CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED')   -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                     AND mp.organization_id = p_organization_id
                     AND rp.organization_id = p_organization_id
                     AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                           OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                        )
--  End for Bug 7440217
                      and  pll.po_header_id = p_poHeaderID
                      and pll.po_line_id = pl.po_line_id
                      and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
        )
        ;

      end if;

-- *****************************
-- End of not PJM Based Tran
-- *****************************

end if;

-- *****************************
--- END OF PO HEADER  ID SECTION
-- *****************************

elsif  (p_shipmentHeaderID is not null ) then
-- *****************************
--- START  OF SHIPMENT HEADER  ID SECTION
-- *****************************
      open x_Items for
      -- Bug# 6747729
      -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
      select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
         stock_enabled_flag,
        DECODE (p_reqHeaderID,to_char(null),' ',
        rsh.shipment_num),
        DECODE (p_reqHeaderID,to_char(null),' ',
        p_shipmentHeaderID) -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       from mtl_system_items_vl msn, /* Bug 5581528 */
            rcv_shipment_lines rsl,
            rcv_shipment_headers rsh /* Added for Bug9257750 */
       WHERE msn.organization_id = p_Organization_Id
       and msn.concatenated_segments like p_concatenated_segments||l_append
       and (msn.purchasing_enabled_flag = 'Y' OR msn.stock_enabled_flag = 'Y')
       and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
       and rsh.SHIPMENT_HEADER_ID = rsl.SHIPMENT_HEADER_ID /* Added for Bug9257750 */
       -- This was fix for bug 2740648/2752094
       AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
       AND rsl.to_organization_id= p_Organization_Id--Bug 3972931-Added the condiotn to filter based on organization_id
       and rsl.item_id = msn.inventory_item_id
       and ( (l_from_lpn_id is null) or (l_from_lpn_id is not null and
                 exists ( select '1' from wms_lpn_contents wlc
                     where wlc.parent_lpn_id = l_from_lpn_id
                       and wlc.inventory_item_id = rsl.item_id
                        ) )
           )
      UNION
    -- bug 2775596
    -- added unions for the substitute item and vendor item
    -- if receiving an ASN.
        -- Vendor Item SQL
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.vendor_product_num,
        msi.inventory_item_id,
        msi.description,
        Nvl(msi.revision_qty_control_code,1),
        Nvl(msi.lot_control_code, 1),
        Nvl(msi.serial_number_control_code, 1),
        Nvl(msi.restrict_subinventories_code, 2),
        Nvl(msi.restrict_locators_code,2),
        Nvl(msi.location_control_code,1),
        msi.primary_uom_code,
        Nvl(msi.inspection_required_flag,'N'),
        Nvl(msi.shelf_life_code, 1),
        Nvl(msi.shelf_life_days,0),
        Nvl(msi.allowed_units_lookup_code, 2),
        Nvl(msi.effectivity_control,1),
        0,
        0,
        Nvl(msi.default_serial_status_id,1),
        Nvl(msi.serial_status_enabled,'N'),
        Nvl(msi.default_lot_status_id,0),
        Nvl(msi.lot_status_enabled,'N'),
        msi.concatenated_segments,
        'Y',
        msi.inventory_item_flag,
        0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag,
        msi.outside_operation_flag ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
        msi.stock_enabled_flag,
        DECODE (p_reqHeaderID,to_char(null),' ',
        rsh.shipment_num),
        DECODE (p_reqHeaderID,to_char(null),' ',
        p_shipmentHeaderID) -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        ,mtl_system_items_vl msi /* Bug 5581528 */
        ,rcv_shipment_lines rsl
        ,rcv_shipment_headers rsh /* Added for Bug9257750 */
        where msi.organization_id =  p_Organization_Id
        and pol.vendor_product_num like  p_concatenated_segments
        and pol.item_id = msi.inventory_item_id
        and pol.vendor_product_num IS NOT NULL
        and pol.po_header_id = Nvl(p_poheaderid,pol.po_header_id)
        and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
  and inventory_item_id IN (SELECT pl.item_id
          FROM po_lines_trx_v pl
          WHERE pl.po_header_id = rsl.po_header_id
          and pl.po_line_id = rsl.po_line_id
          and exists (select 1
                        from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                           , mtl_parameters mp,
                             rcv_parameters rp
--  End for Bug 7440217
                       where NVL(pll.closed_code,'OPEN')
                       not in ('FINALLY CLOSED' , 'CLOSED FOR RECEIVING', 'CLOSED' ) -- 3687249
--  For Bug 7440217 Checking if it is LCM enabled
                          AND mp.organization_id = p_organization_id
                          AND rp.organization_id = p_organization_id
                          AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                                OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                    OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                               )
--  End for Bug 7440217
                        and  pll.po_header_id = rsl.po_header_id
                        and pll.po_line_id = rsl.po_line_id
                        and pll.ship_to_organization_id = p_Organization_Id)--Bug 3972931-Added the filter condition based on ship_to_organization_id
                 )
  AND pol.po_line_id = rsl.po_line_id
  and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
  and rsh.SHIPMENT_HEADER_ID = rsl.SHIPMENT_HEADER_ID /* Added for Bug9257750 */
  AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
  AND rsl.source_document_code = 'PO'
        and ( (l_from_lpn_id is null) or (l_from_lpn_id is not null and
                 exists ( select '1' from wms_lpn_contents wlc
                     where wlc.parent_lpn_id = l_from_lpn_id
                       and wlc.inventory_item_id = msi.inventory_item_id
                        ) )
           )
       UNION
  -- Bug 2775532
  -- This section is non item master stuff for ASNs
        -- Bug# 6747729
        -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
        select distinct pol.item_description,
        to_number(''),
        pol.item_description,
        1,
        1,
        1,
        2,
        2,
        1,
        mum.uom_code,
        'N',
        1,
        0,
        2,
        1,
        0,
        0,
        1,
        'N',
        0,
        'N',
        '',
        'N',
        'N',
        0,
	  wms_deploy.get_item_client_name(pol.item_id),
        to_char(NULL),
        'N' ,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
        'N',
        DECODE (p_reqHeaderID,to_char(null),' ',
        rsh.shipment_num),
        DECODE (p_reqHeaderID,to_char(null),' ',
        p_shipmentHeaderID)  -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
        from po_lines_trx_v pol -- CLM project, bug 9403291
        , mtl_units_of_measure mum
        ,rcv_shipment_lines rsl
        , rcv_shipment_headers rsh /* Added for Bug9257750 */
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
  where mum.uom_class = (SELECT mum2.uom_class
               FROM mtl_units_of_measure mum2
              WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
        and mum.base_uom_flag = 'Y'
        and pol.ITEM_ID is null
        and pol.item_description is not null
        and pol.po_header_id = Nvl(p_poheaderid,pol.po_header_id)
        and pol.item_description like  p_concatenated_segments
  AND pol.po_line_id = rsl.po_line_id
  and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
  and rsh.SHIPMENT_HEADER_ID = rsl.SHIPMENT_HEADER_ID  /* Added for Bug9257750 */
  AND rsl.shipment_line_status_code in ('EXPECTED','PARTIALLY RECEIVED')
  AND rsl.source_document_code = 'PO'
  /* Bug 3972931-Added the following exists condition to restrict the PO receipt
        to shipments due to be received only in the organizationientered with.*/
        and exists (select 1
                      from po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                         , mtl_parameters mp,
                           rcv_parameters rp
--  End for Bug 7440217
                     where pll.po_header_id = p_poHeaderID
--  For Bug 7440217 Checking if it is LCM enabled
                       AND mp.organization_id = p_organization_id
                       AND rp.organization_id = p_organization_id
                       AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                             OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                 OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                       and pll.po_line_id = pol.po_line_id
                       and pll.ship_to_organization_id = p_Organization_Id)
        --End of fix for Bug 3972931
       UNION
       -- This Section for GTIN Cross Ref
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       select mcr.cross_reference,
       msn.inventory_item_id,
       msn.description,
       Nvl(msn.revision_qty_control_code,1),
       Nvl(msn.lot_control_code, 1),
       Nvl(msn.serial_number_control_code, 1),
       Nvl(msn.restrict_subinventories_code, 2),
       Nvl(msn.restrict_locators_code, 2),
       Nvl(msn.location_control_code, 1),
       msn.primary_uom_code,
       Nvl(msn.inspection_required_flag, 'N'),
       Nvl(msn.shelf_life_code, 1),
       Nvl(msn.shelf_life_days,0),
       Nvl(msn.allowed_units_lookup_code, 2),
       Nvl(msn.effectivity_control,1),
       0,
       0,
       Nvl(msn.default_serial_status_id,1),
       Nvl(msn.serial_status_enabled,'N'),
       Nvl(msn.default_lot_status_id,0),
       Nvl(msn.lot_status_enabled,'N'),
       msn.concatenated_segments,
       'C',
       msn.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msn.inventory_item_id),
       msn.inventory_asset_flag,
       msn.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSN.GRADE_CONTROL_FLAG,'N'),
         NVL(MSN.DEFAULT_GRADE,''),
         NVL(MSN.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSN.EXPIRATION_ACTION_CODE,''),
         NVL(MSN.HOLD_DAYS,0),
         NVL(MSN.MATURITY_DAYS,0),
         NVL(MSN.RETEST_INTERVAL,0),
         NVL(MSN.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSN.CHILD_LOT_FLAG,'N'),
         NVL(MSN.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSN.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSN.SECONDARY_UOM_CODE,''),
         NVL(MSN.SECONDARY_DEFAULT_IND,''),
         NVL(MSN.TRACKING_QUANTITY_IND,'P'),
         NVL(MSN.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSN.DUAL_UOM_DEVIATION_LOW,0),
         msn.stock_enabled_flag,
         DECODE (p_reqHeaderID,to_char(null),' ',
         rsh.shipment_num),
         DECODE (p_reqHeaderID,to_char(null),' ',
         p_shipmentHeaderID)  -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       from mtl_system_items_vl msn, /* Bug 5581528 */
            rcv_shipment_lines rsl,
            rcv_shipment_headers rsh, /* Added for Bug9257750 */
            mtl_cross_references mcr
       WHERE msn.organization_id = p_Organization_Id
        and ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msn.inventory_item_id
       and (msn.purchasing_enabled_flag = 'Y' OR msn.stock_enabled_flag = 'Y')
       and rsl.SHIPMENT_HEADER_ID = p_shipmentHeaderID
       and rsh.SHIPMENT_HEADER_ID = rsl.SHIPMENT_HEADER_ID /* Added for Bug9257750 */
       and rsl.to_organization_id= p_Organization_Id--Bug 3972931-Added the condiotn to filter based on organization_id
       and rsl.item_id = msn.inventory_item_id
       and ( (l_from_lpn_id is null) or (l_from_lpn_id is not null and
                 exists ( select '1' from wms_lpn_contents wlc
                     where wlc.parent_lpn_id = l_from_lpn_id
                       and wlc.inventory_item_id = rsl.item_id
                        ) )
           )
       ;


-- *****************************
--- END  OF SHIPMENT HEADER  ID SECTION
-- *****************************

elsif (p_oeOrderHeaderID is not null) then

-- *****************************
--- START  OF OE ORDER HEADER  ID SECTION
-- *****************************

       open x_items for
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0),
       stock_enabled_flag,
         ' ',
         ' '    -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       from mtl_system_items_vl  /* Bug 5581528 */
       WHERE organization_id = p_Organization_Id
       and concatenated_segments like p_concatenated_segments||l_append
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and inventory_item_id IN (SELECT oel.inventory_item_id FROM
       oe_order_lines_all oel,oe_order_headers_all oeh--Bug 3972931-Added the table oe_order_headers_all
       WHERE oel.HEADER_ID = p_oeOrderHeaderID
       and oel.header_id = oeh.header_id --Bug4060261 -Added the join between the tables.
       and oel.ORDERED_QUANTITY > NVL(oel.SHIPPED_QUANTITY,0)
       and ((p_projectId is null or oel.project_id = p_projectId)
             and (p_taskID is null or oel.task_id = p_taskId ))
       and nvl(oel.ship_from_org_id, nvl(oeh.ship_from_org_id,p_Organization_Id)) = p_Organization_Id
       and    oel.line_category_code = 'RETURN' --added for bug 4417549
       )
       --Bug 3972931-Added the filter condition based on ship_from_org_id
       UNION
       -- This Section Added for GTIN Cross Ref
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       select mcr.cross_reference,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code, 2),
       Nvl(msi.location_control_code, 1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag, 'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       msi.concatenated_segments,
       'C',
       msi.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
       msi.inventory_asset_flag,
       msi.outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(MSI.GRADE_CONTROL_FLAG,'N'),
         NVL(MSI.DEFAULT_GRADE,''),
         NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
         NVL(MSI.EXPIRATION_ACTION_CODE,''),
         NVL(MSI.HOLD_DAYS,0),
         NVL(MSI.MATURITY_DAYS,0),
         NVL(MSI.RETEST_INTERVAL,0),
         NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(MSI.CHILD_LOT_FLAG,'N'),
         NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
         NVL(MSI.SECONDARY_UOM_CODE,''),
         NVL(MSI.SECONDARY_DEFAULT_IND,''),
         NVL(MSI.TRACKING_QUANTITY_IND,'P'),
         NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
         NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
       msi.stock_enabled_flag,
         ' ',
         ' '    -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       from mtl_system_items_vl msi /* Bug 5581528 */
           ,mtl_cross_references mcr
       WHERE msi.organization_id = p_Organization_Id
        and ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref
            )
        and ( (mcr.org_independent_flag = 'Y') or (mcr.org_independent_flag = 'N'
        and mcr.organization_id = p_organization_id
               ) )
       and mcr.inventory_item_id = msi.inventory_item_id
       and (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
       and msi.inventory_item_id IN (SELECT oel.inventory_item_id FROM
       oe_order_lines_all oel,oe_order_headers_all oeh--Bug 3972931-Added the table oe_order_headers_all
       WHERE oel.HEADER_ID = p_oeOrderHeaderID
       and oel.header_id = oeh.header_id --Bug4060261-Added the join between the tables.
       and oel.ORDERED_QUANTITY > NVL(oel.SHIPPED_QUANTITY,0)
       and ((p_projectId is null or oel.project_id = p_projectId)
             and (p_taskID is null or oel.task_id = p_taskId ))
       and nvl(oel.ship_from_org_id, nvl(oeh.ship_from_org_id,p_Organization_id)) = p_Organization_Id);
       --Bug 3972931-Added the filter condition based on ship_from_org_id

-- *****************************
--- END  OF OE ORDER HEADER  ID SECTION
-- *****************************

elsif  (p_reqHeaderID is not null) then

-- *****************************
--- START  OF REQ HEADER  ID SECTION
-- *****************************

       open x_items for
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       --Start of Fix for Bug# 7216416

       SELECT  /*+ leading(rsl1) use_nl(rsl1 mtl_system_items_vl)
        index(mtl_system_items_vl MTL_SYSTEM_ITEMS_B_U1) */

	      concatenated_segments               ,
        inventory_item_id                   ,
        description                         ,
        NVL(revision_qty_control_code,1)    ,
        NVL(lot_control_code, 1)            ,
        NVL(serial_number_control_code, 1)  ,
        NVL(restrict_subinventories_code, 2),
        NVL(restrict_locators_code, 2)      ,
        NVL(location_control_code, 1)       ,
        primary_uom_code                    ,
        NVL(inspection_required_flag, 'N')  ,
        NVL(shelf_life_code, 1)             ,
        NVL(shelf_life_days,0)              ,
        NVL(allowed_units_lookup_code, 2)   ,
        NVL(effectivity_control,1)          ,
        0                                   ,
        0                                   ,
        NVL(default_serial_status_id,1)     ,
        NVL(serial_status_enabled,'N')      ,
        NVL(default_lot_status_id,0)        ,
        NVL(lot_status_enabled,'N')         ,
        ''                                  ,
        'N'                                 ,
        inventory_item_flag                 ,
        0                                   ,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag                ,
        outside_operation_flag              ,
        --Bug 3952081
        --Select DUOM Attributes for every Item
        NVL(GRADE_CONTROL_FLAG,'N')       ,
        NVL(DEFAULT_GRADE,'')             ,
        NVL(EXPIRATION_ACTION_INTERVAL,0) ,
        NVL(EXPIRATION_ACTION_CODE,'')    ,
        NVL(HOLD_DAYS,0)                  ,
        NVL(MATURITY_DAYS,0)              ,
        NVL(RETEST_INTERVAL,0)            ,
        NVL(COPY_LOT_ATTRIBUTE_FLAG,'N')  ,
        NVL(CHILD_LOT_FLAG,'N')           ,
        NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
        NVL(LOT_DIVISIBLE_FLAG,'Y')       ,
        NVL(SECONDARY_UOM_CODE,'')        ,
        NVL(SECONDARY_DEFAULT_IND,'')     ,
        NVL(TRACKING_QUANTITY_IND,'P')    ,
        NVL(DUAL_UOM_DEVIATION_HIGH,0)    ,
        NVL(DUAL_UOM_DEVIATION_LOW,0)     ,
        stock_enabled_flag,
        rsl1.shipment_num,
        to_char(rsl1.shipment_header_id)  -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
FROM    mtl_system_items_vl,
        /* Bug 5581528 */
        (
        SELECT rsl.Item_Id,rsh.shipment_num shipment_num, /* Added by Bug9257750 */
        rsh.shipment_header_id shipment_header_id
        FROM    po_Req_Lines_trx_v prl, -- CLM project, bug 9403291
                rcv_Shipment_Lines rsl      ,
                rcv_shipment_headers rsh,/* Added by Bug9257750 */
                po_req_Distributions_All prd
        WHERE   prl.Requisition_Header_Id = p_reqHeadeRid
            AND rsh.shipment_header_id	= rsl.shipment_header_id /* Added by Bug9257750 */
            AND l_From_lpn_Id            IS NOT NULL
            AND EXISTS
                (SELECT '1'
                FROM    wms_lpn_Contents wlc
                WHERE   wlc.Parent_lpn_Id     = l_From_lpn_Id
                    AND wlc.Inventory_Item_Id = rsl.Item_Id
                )
            AND prl.Requisition_Line_Id         = rsl.Requisition_Line_Id
            AND prl.Requisition_Line_Id         = prd.Requisition_Line_Id
            AND prl.Destination_Organization_Id = p_Organization_Id--Bug 3972931- Added the condition to filter based on destination org
            AND (p_ProjectId                   IS NULL
             OR prd.Project_Id                  = p_ProjectId)
            AND (p_TaskId                      IS NULL
             OR prd.Task_Id                     = p_TaskId)
        ) rsl1
WHERE   organization_id = p_Organization_Id
    AND concatenated_segments LIKE p_concatenated_segments||l_append
    AND (purchasing_enabled_flag = 'Y'
     OR stock_enabled_flag       = 'Y')
    AND Inventory_Item_Id        = rsl1.Item_Id

UNION

SELECT  /*+ leading(rsl1) use_nl(rsl1 msiv1)
        index(msiv1 MTL_SYSTEM_ITEMS_B_U1) */

	      concatenated_segments               ,
        inventory_item_id                   ,
        description                         ,
        NVL(revision_qty_control_code,1)    ,
        NVL(lot_control_code, 1)            ,
        NVL(serial_number_control_code, 1)  ,
        NVL(restrict_subinventories_code, 2),
        NVL(restrict_locators_code, 2)      ,
        NVL(location_control_code, 1)       ,
        primary_uom_code                    ,
        NVL(inspection_required_flag, 'N')  ,
        NVL(shelf_life_code, 1)             ,
        NVL(shelf_life_days,0)              ,
        NVL(allowed_units_lookup_code, 2)   ,
        NVL(effectivity_control,1)          ,
        0                                   ,
        0                                   ,
        NVL(default_serial_status_id,1)     ,
        NVL(serial_status_enabled,'N')      ,
        NVL(default_lot_status_id,0)        ,
        NVL(lot_status_enabled,'N')         ,
        ''                                  ,
        'N'                                 ,
        inventory_item_flag                 ,
        0                                   ,
	  wms_deploy.get_item_client_name(inventory_item_id),
        inventory_asset_flag                ,
        outside_operation_flag              ,
        --Bug 3952081
        --Select DUOM Attributes for every Item
        NVL(GRADE_CONTROL_FLAG,'N')       ,
        NVL(DEFAULT_GRADE,'')             ,
        NVL(EXPIRATION_ACTION_INTERVAL,0) ,
        NVL(EXPIRATION_ACTION_CODE,'')    ,
        NVL(HOLD_DAYS,0)                  ,
        NVL(MATURITY_DAYS,0)              ,
        NVL(RETEST_INTERVAL,0)            ,
        NVL(COPY_LOT_ATTRIBUTE_FLAG,'N')  ,
        NVL(CHILD_LOT_FLAG,'N')           ,
        NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
        NVL(LOT_DIVISIBLE_FLAG,'Y')       ,
        NVL(SECONDARY_UOM_CODE,'')        ,
        NVL(SECONDARY_DEFAULT_IND,'')     ,
        NVL(TRACKING_QUANTITY_IND,'P')    ,
        NVL(DUAL_UOM_DEVIATION_HIGH,0)    ,
        NVL(DUAL_UOM_DEVIATION_LOW,0)     ,
        stock_enabled_flag,
        rsl1.shipment_num,
        to_char(rsl1.shipment_header_id)  -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
FROM    mtl_system_items_vl,
        /* Bug 5581528 */
        (
        SELECT rsl.Item_Id,rsh.shipment_num shipment_num, /* Added by Bug9257750 */
        rsh.shipment_header_id shipment_header_id
        FROM    po_Req_Lines_trx_v prl, -- CLM project, bug 9403291
                rcv_Shipment_Lines rsl      ,
                po_req_Distributions_All prd,
                rcv_shipment_headers rsh /* Added by Bug9257750 */
        WHERE   prl.Requisition_Header_Id       = p_reqHeadeRid
            AND rsh.shipment_header_id	= rsl.shipment_header_id /* Added by Bug9257750 */
            AND l_From_lpn_Id                  IS NULL
            AND prl.Requisition_Line_Id         = rsl.Requisition_Line_Id
            AND prl.Requisition_Line_Id         = prd.Requisition_Line_Id
            AND prl.Destination_Organization_Id = p_Organization_Id--Bug 3972931- Added the condition to filter based on destination org
            AND (p_ProjectId                   IS NULL
             OR prd.Project_Id                  = p_ProjectId)
            AND (p_TaskId                      IS NULL
             OR prd.Task_Id                     = p_TaskId)
        ) rsl1
WHERE   organization_id = p_Organization_Id
    AND concatenated_segments LIKE p_concatenated_segments||l_append
    AND (purchasing_enabled_flag = 'Y'
     OR stock_enabled_flag       = 'Y')
    AND Inventory_Item_Id        = rsl1.Item_Id

UNION

-- Section for GTIN Cross Ref.
-- Bug# 6747729
-- Added code to also fetch stock_enabled_flag from mtl_system_items_v
SELECT  mcr.cross_reference                     ,
        msi.inventory_item_id                   ,
        msi.description                         ,
        NVL(msi.revision_qty_control_code,1)    ,
        NVL(msi.lot_control_code, 1)            ,
        NVL(msi.serial_number_control_code, 1)  ,
        NVL(msi.restrict_subinventories_code, 2),
        NVL(msi.restrict_locators_code, 2)      ,
        NVL(msi.location_control_code, 1)       ,
        msi.primary_uom_code                    ,
        NVL(msi.inspection_required_flag, 'N')  ,
        NVL(msi.shelf_life_code, 1)             ,
        NVL(msi.shelf_life_days,0)              ,
        NVL(msi.allowed_units_lookup_code, 2)   ,
        NVL(msi.effectivity_control,1)          ,
        0                                       ,
        0                                       ,
        NVL(msi.default_serial_status_id,1)     ,
        NVL(msi.serial_status_enabled,'N')      ,
        NVL(msi.default_lot_status_id,0)        ,
        NVL(msi.lot_status_enabled,'N')         ,
        msi.concatenated_segments               ,
        'C'                                     ,
        msi.inventory_item_flag                 ,
        0                                       ,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
        msi.inventory_asset_flag                ,
        msi.outside_operation_flag              ,
        --Bug 3952081
        --Select DUOM Attributes for every Item
        NVL(MSI.GRADE_CONTROL_FLAG,'N')       ,
        NVL(MSI.DEFAULT_GRADE,'')             ,
        NVL(MSI.EXPIRATION_ACTION_INTERVAL,0) ,
        NVL(MSI.EXPIRATION_ACTION_CODE,'')    ,
        NVL(MSI.HOLD_DAYS,0)                  ,
        NVL(MSI.MATURITY_DAYS,0)              ,
        NVL(MSI.RETEST_INTERVAL,0)            ,
        NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N')  ,
        NVL(MSI.CHILD_LOT_FLAG,'N')           ,
        NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
        NVL(MSI.LOT_DIVISIBLE_FLAG,'Y')       ,
        NVL(MSI.SECONDARY_UOM_CODE,'')        ,
        NVL(MSI.SECONDARY_DEFAULT_IND,'')     ,
        NVL(MSI.TRACKING_QUANTITY_IND,'P')    ,
        NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0)    ,
        NVL(MSI.DUAL_UOM_DEVIATION_LOW,0)     ,
        msi.stock_enabled_flag,
        rsl1.shipment_num,
        to_char(rsl1.shipment_header_id)  -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
FROM    mtl_system_items_vl msi
        /* Bug 5581528 */
        ,
        mtl_cross_references mcr,
        -- This Select clause added by Bug9257750 to fetch the values of Shipment Number and Shipment Header id
        (
        SELECT  rsl.Item_Id,rsh.shipment_num shipment_num,
                rsh.shipment_header_id shipment_header_id
        FROM    po_req_lines_trx_v prl,
                rcv_Shipment_Lines rsl      ,
                po_req_Distributions_All prd,
                rcv_shipment_headers  rsh
        WHERE   prl.Requisition_Header_Id       = p_reqHeadeRid
	    AND rsh.shipment_header_id		= rsl.shipment_header_id
            AND l_From_lpn_Id                  IS NULL
            AND prl.Requisition_Line_Id         = rsl.Requisition_Line_Id
	    AND(rsl.shipment_line_status_code IS NULL OR rsl.shipment_line_status_code <> 'FULLY RECEIVED') -- Modified for bug 7273815
            AND prl.Requisition_Line_Id         = prd.Requisition_Line_Id
            AND prl.Destination_Organization_Id = p_Organization_Id--Bug 3972931- Added the condition to filter based on destination org
            AND (p_ProjectId                   IS NULL
             OR prd.Project_Id                  = p_ProjectId)
            AND (p_TaskId                      IS NULL
             OR prd.Task_Id                     = p_TaskId)
        ) rsl1
WHERE   msi.organization_id        = p_Organization_Id
    AND ( mcr.cross_reference_type = g_gtin_cross_ref_type
    AND mcr.cross_reference LIKE g_crossref )
    AND ( (mcr.org_independent_flag = 'Y')
     OR (mcr.org_independent_flag   = 'N'
    AND mcr.organization_id         = p_organization_id ) )
    AND mcr.inventory_item_id       = msi.inventory_item_id
    AND (purchasing_enabled_flag    = 'Y'
     OR stock_enabled_flag          = 'Y')
    AND EXISTS
        (SELECT 1
        FROM    po_req_lines_trx_v prl,
                rcv_shipment_lines rsl      ,
                po_req_distributions_all prd
        WHERE   prl.requisition_header_id = p_reqHeaderID
            AND rsl.item_id               = msi.inventory_item_id
            AND ( (l_from_lpn_id         IS NULL)
             OR (l_from_lpn_id           IS NOT NULL
            AND EXISTS
                (SELECT '1'
                FROM    wms_lpn_contents wlc
                WHERE   wlc.parent_lpn_id     = l_from_lpn_id
                    AND wlc.inventory_item_id = rsl.item_id
                ) ) )
            AND prl.requisition_line_id        = rsl.requisition_line_id
            AND prl.requisition_line_id        = prd.requisition_line_id
            AND prl.destination_organization_id=p_Organization_Id--Bug 3972931- Added the condition to filter based on destination org
            AND (p_projectId                  IS NULL
             OR prd.project_id                 = p_projectId)
            AND (p_taskId                     IS NULL
             OR prd.task_id                    = p_taskId)
        ) ;

       --End of Fix for Bug# 7216416

-- *****************************
--- END  OF REQ HEADER  ID SECTION
-- *****************************

end if;   --- End of doc Entered transaction

else

-- *****************************
---- Case for Document Info is not  entered in the session , i.e transaction starts with Item
-- *****************************

       OPEN x_items FOR
       --Items from Item Master
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       SELECT
       msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code, 2),
       Nvl(msi.location_control_code, 1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag, 'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       '',
       'N',
       msi.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
       msi.inventory_asset_flag,
       msi.outside_operation_flag,
       --Bug 3952081
       --Select DUOM Attributes for every Item
       NVL(msi.GRADE_CONTROL_FLAG,'N'),
       NVL(msi.DEFAULT_GRADE,''),
       NVL(msi.EXPIRATION_ACTION_INTERVAL,0),
       NVL(msi.EXPIRATION_ACTION_CODE,''),
       NVL(msi.HOLD_DAYS,0),
       NVL(msi.MATURITY_DAYS,0),
       NVL(msi.RETEST_INTERVAL,0),
       NVL(msi.COPY_LOT_ATTRIBUTE_FLAG,'N'),
       NVL(msi.CHILD_LOT_FLAG,'N'),
       NVL(msi.CHILD_LOT_VALIDATION_FLAG,'N'),
       NVL(msi.LOT_DIVISIBLE_FLAG,'Y'),
       NVL(msi.SECONDARY_UOM_CODE,''),
       NVL(msi.SECONDARY_DEFAULT_IND,''),
       NVL(msi.TRACKING_QUANTITY_IND,'P'),
       NVL(msi.DUAL_UOM_DEVIATION_HIGH,0),
       NVL(msi.DUAL_UOM_DEVIATION_LOW,0),
       msi.stock_enabled_flag,
       ' ',
       ' '      -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       FROM
       mtl_system_items_vl msi /* Bug 5581528 */
       WHERE msi.organization_id = p_organization_Id
       AND msi.concatenated_segments LIKE p_concatenated_segments||l_append
       AND (msi.purchasing_enabled_flag = 'Y' OR msi.stock_enabled_flag = 'Y')
       UNION -- ALL
       --Bug 7608067 This should Union but not Union ALL which is causing of displaying duplicate items in the LOV
       --This is caused by the 5353920 who has changed this query in one version and reverted back but didnt reverted this.
       --- Substitute Item SQL
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       SELECT
       msi.concatenated_segments,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       '',
       'N',
       msi.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
       msi.inventory_asset_flag,
       msi.outside_operation_flag,
       --Bug 3952081
       --Select DUOM Attributes for every Item
       NVL(MSI.GRADE_CONTROL_FLAG,'N'),
       NVL(MSI.DEFAULT_GRADE,''),
       NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
       NVL(MSI.EXPIRATION_ACTION_CODE,''),
       NVL(MSI.HOLD_DAYS,0),
       NVL(MSI.MATURITY_DAYS,0),
       NVL(MSI.RETEST_INTERVAL,0),
       NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
       NVL(MSI.CHILD_LOT_FLAG,'N'),
       NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
       NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
       NVL(MSI.SECONDARY_UOM_CODE,''),
       NVL(MSI.SECONDARY_DEFAULT_IND,''),
       NVL(MSI.TRACKING_QUANTITY_IND,'P'),
       NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
       NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
       msi.stock_enabled_flag,
       ' ',
       ' '      -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       FROM
       mtl_system_items_vl msi /* Bug 5581528 */
       WHERE msi.organization_id = p_organization_Id
       AND msi.concatenated_segments LIKE  p_concatenated_segments||l_append
       AND (msi.purchasing_enabled_flag = 'Y' OR msi.stock_enabled_flag = 'Y')
       AND EXISTS (SELECT '1'
                     FROM po_lines_trx_v pol, -- CLM project, bug 9403291
                          mtl_related_items mri,
                          po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                        , mtl_parameters mp,
                          rcv_parameters rp
--  End for Bug 7440217
                    WHERE NVL(pll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED')
                      AND NVL(pll.allow_substitute_receipts_flag, 'N') = 'Y'
                      AND pll.po_line_id = pol.po_line_id
                      AND pll.ship_to_organization_id = msi.organization_id
                      AND ((    mri.related_item_id = msi.inventory_item_id
                      AND pol.item_id = mri.inventory_item_id)
                       OR
                       (    mri.inventory_item_id = msi.inventory_item_id
                        AND pol.item_id = mri.related_item_id
                        AND mri.reciprocal_flag = 'Y')
                       )
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                           )
--  End for Bug 7440217
                   )
       UNION ALL
       ---- Vendor Item SQL
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       SELECT DISTINCT
       pol.vendor_product_num,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       msi.concatenated_segments,
       'Y',
       msi.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
       msi.inventory_asset_flag,
       msi.outside_operation_flag,
       --Bug 3952081
       --Select DUOM Attributes for every Item
       NVL(MSI.GRADE_CONTROL_FLAG,'N'),
       NVL(MSI.DEFAULT_GRADE,''),
       NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
       NVL(MSI.EXPIRATION_ACTION_CODE,''),
       NVL(MSI.HOLD_DAYS,0),
       NVL(MSI.MATURITY_DAYS,0),
       NVL(MSI.RETEST_INTERVAL,0),
       NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
       NVL(MSI.CHILD_LOT_FLAG,'N'),
       NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
       NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
       NVL(MSI.SECONDARY_UOM_CODE,''),
       NVL(MSI.SECONDARY_DEFAULT_IND,''),
       NVL(MSI.TRACKING_QUANTITY_IND,'P'),
       NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
       NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
       msi.stock_enabled_flag,
       ' ',
       ' '      -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       FROM
       po_lines_trx_v pol, -- CLM project, bug 9403291
       mtl_system_items_vl msi /* Bug 5581528 */
       WHERE msi.organization_id = p_organization_Id
       AND (msi.purchasing_enabled_flag = 'Y' OR msi.stock_enabled_flag = 'Y')
       AND pol.vendor_product_num like p_concatenated_segments
       AND pol.item_id = msi.inventory_item_id
       AND pol.vendor_product_num IS NOT NULL
       AND EXISTS (SELECT '1'
                     FROM po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                        , mtl_parameters mp,
                          rcv_parameters rp
--  End for Bug 7440217
                    WHERE pll.po_line_id = pol.po_line_id
                      AND pll.ship_to_organization_id = msi.organization_id
                      AND NVL(pll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED')
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                   )
       UNION ALL
       --- Cross Ref Items
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       SELECT DISTINCT
       mcr.cross_reference,
       msi.inventory_item_id,
       msi.description,
       Nvl(msi.revision_qty_control_code,1),
       Nvl(msi.lot_control_code, 1),
       Nvl(msi.serial_number_control_code, 1),
       Nvl(msi.restrict_subinventories_code, 2),
       Nvl(msi.restrict_locators_code,2),
       Nvl(msi.location_control_code,1),
       msi.primary_uom_code,
       Nvl(msi.inspection_required_flag,'N'),
       Nvl(msi.shelf_life_code, 1),
       Nvl(msi.shelf_life_days,0),
       Nvl(msi.allowed_units_lookup_code, 2),
       Nvl(msi.effectivity_control,1),
       0,
       0,
       Nvl(msi.default_serial_status_id,1),
       Nvl(msi.serial_status_enabled,'N'),
       Nvl(msi.default_lot_status_id,0),
       Nvl(msi.lot_status_enabled,'N'),
       msi.concatenated_segments,
       'C',
       msi.inventory_item_flag,
       0,
	  wms_deploy.get_item_client_name(msi.inventory_item_id),
       msi.inventory_asset_flag,
       msi.outside_operation_flag,
       --Bug 3952081
       --Select DUOM Attributes for every Item
       NVL(MSI.GRADE_CONTROL_FLAG,'N'),
       NVL(MSI.DEFAULT_GRADE,''),
       NVL(MSI.EXPIRATION_ACTION_INTERVAL,0),
       NVL(MSI.EXPIRATION_ACTION_CODE,''),
       NVL(MSI.HOLD_DAYS,0),
       NVL(MSI.MATURITY_DAYS,0),
       NVL(MSI.RETEST_INTERVAL,0),
       NVL(MSI.COPY_LOT_ATTRIBUTE_FLAG,'N'),
       NVL(MSI.CHILD_LOT_FLAG,'N'),
       NVL(MSI.CHILD_LOT_VALIDATION_FLAG,'N'),
       NVL(MSI.LOT_DIVISIBLE_FLAG,'Y'),
       NVL(MSI.SECONDARY_UOM_CODE,''),
       NVL(MSI.SECONDARY_DEFAULT_IND,''),
       NVL(MSI.TRACKING_QUANTITY_IND,'P'),
       NVL(MSI.DUAL_UOM_DEVIATION_HIGH,0),
       NVL(MSI.DUAL_UOM_DEVIATION_LOW,0),
       msi.stock_enabled_flag,
       ' ',
       ' '      -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       FROM
       mtl_system_items_vl msi, /* Bug 5581528 */
       mtl_cross_references mcr
       WHERE msi.organization_id = p_organization_Id
       AND ( (mcr.cross_reference_type = p_crossreftype
               AND mcr.cross_reference LIKE  p_concatenated_segments
              ) OR
              ( mcr.cross_reference_type = g_gtin_cross_ref_type
               AND mcr.cross_reference      LIKE g_crossref )
            )
       AND ( (mcr.org_independent_flag = 'Y') OR (mcr.org_independent_flag = 'N'
       AND mcr.organization_id = p_organization_Id
               ) )
       AND mcr.inventory_item_id = msi.inventory_item_id
       AND (msi.purchasing_enabled_flag = 'Y' OR msi.stock_enabled_flag = 'Y')
       UNION ALL
       -- Non Item Master
       -- Bug# 6747729
       -- Added code to also fetch stock_enabled_flag from mtl_system_items_v
       SELECT DISTINCT pol.item_description,
       to_number(''),
       pol.item_description,
       1,
       1,
       1,
       2,
       2,
       1,
       mum.uom_code,
       'N',
       1,
       0,
       2,
       1,
       0,
       0,
        1,
       'N',
       0,
       'N',
       '',
       'N',
       'N',
       0,
	  wms_deploy.get_item_client_name(pol.item_id),
       to_char(NULL),
       'N',
         --Bug 3952081
         --Select DUOM Attributes for every Item
         'N',
         '',
         0,
         '',
         0,
         0,
         0,
         'N',
         'N',
         'N',
         'Y',
         '',
         '',
         'P',
         0,
         0,
         'N',
       ' ',
       ' '      -- Added by Bug9257750 for values corr to Shipment Number and Shipment Header id
       FROM
       po_lines_trx_v pol, -- CLM project, bug 9403291
       mtl_units_of_measure mum
  -- Bug 2619063, 2614016
  -- Modified to select the base uom for the uom class defined on po.
       WHERE mum.uom_class = (SELECT mum2.uom_class
              FROM mtl_units_of_measure mum2
             WHERE mum2.unit_of_measure(+) = pol.unit_meas_lookup_code)
       AND mum.base_uom_flag = 'Y'
       AND pol.ITEM_ID is NULL
       AND pol.item_description IS NOT NULL
       AND pol.item_description LIKE p_concatenated_segments
       AND EXISTS (SELECT '1'
                     FROM po_line_locations_trx_v pll -- CLM project, bug 9403291
--  For Bug 7440217 Added MTL_PARAMETERS and RCV_PRAMETERS to find out if the organization is LCM enabled or not
                        , mtl_parameters mp,
                          rcv_parameters rp
--  End for Bug 7440217
                    WHERE pll.po_line_id = pol.po_line_id
                      AND pll.ship_to_organization_id = p_organization_id
--  For Bug 7440217 Checking if it is LCM enabled
                      AND mp.organization_id = p_organization_id
                      AND rp.organization_id = p_organization_id
                      AND ((NVL(mp.lcm_enabled_flag,'N') = 'N') -- Org is non-lcm enabled
                            OR (NVL(rp.pre_receive,'N') = 'N')      -- Org is lcm enabled and it is post-receiving
                                OR (NVL(pll.lcm_flag,'N') = 'N')       -- Org is lcm enabled, pre-receiving and non-lcm enabled shipment
                          )
--  End for Bug 7440217
                      AND NVL(pll.closed_code,'OPEN') NOT IN ('FINALLY CLOSED','CLOSED FOR RECEIVING', 'CLOSED'));
end if;

END GET_ITEM_LOV_RECEIVING ;
-- ************** End of Bug 2442518

PROCEDURE GET_ITEM_LOV_INVTXN (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER   default null ,
p_Concatenated_Segments               IN VARCHAR2 default null )
IS
   g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
   g_gtin_code_length NUMBER := 14;
   g_crossref         VARCHAR2(40) := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
   l_append varchar2(2):='';
BEGIN

	l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

       open x_items for

       select concatenated_segments,
       inventory_item_id,
       description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       '',
       'N',
       inventory_item_flag,
       0,
	 wms_deploy.get_item_client_name(inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0)
       from mtl_system_items_vl
       WHERE organization_id = p_Organization_Id
       and concatenated_segments like p_concatenated_segments||l_append
       and mtl_transactions_enabled_flag = 'Y'
       and bom_item_type=4

   UNION

   select msik.concatenated_segments,
       msik.inventory_item_id,
       msik.description,
       Nvl(revision_qty_control_code,1),
       Nvl(lot_control_code, 1),
       Nvl(serial_number_control_code, 1),
       Nvl(restrict_subinventories_code, 2),
       Nvl(restrict_locators_code, 2),
       Nvl(location_control_code, 1),
       primary_uom_code,
       Nvl(inspection_required_flag, 'N'),
       Nvl(shelf_life_code, 1),
       Nvl(shelf_life_days,0),
       Nvl(allowed_units_lookup_code, 2),
       Nvl(effectivity_control,1),
       0,
       0,
       Nvl(default_serial_status_id,1),
       Nvl(serial_status_enabled,'N'),
       Nvl(default_lot_status_id,0),
       Nvl(lot_status_enabled,'N'),
       mcr.cross_reference,
       'N',
       inventory_item_flag,
       0,
	 wms_deploy.get_item_client_name(msik.inventory_item_id),
       inventory_asset_flag,
       outside_operation_flag,
         --Bug 3952081
         --Select DUOM Attributes for every Item
         NVL(GRADE_CONTROL_FLAG,'N'),
         NVL(DEFAULT_GRADE,''),
         NVL(EXPIRATION_ACTION_INTERVAL,0),
         NVL(EXPIRATION_ACTION_CODE,''),
         NVL(HOLD_DAYS,0),
         NVL(MATURITY_DAYS,0),
         NVL(RETEST_INTERVAL,0),
         NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
         NVL(CHILD_LOT_FLAG,'N'),
         NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
         NVL(LOT_DIVISIBLE_FLAG,'Y'),
         NVL(SECONDARY_UOM_CODE,''),
         NVL(SECONDARY_DEFAULT_IND,''),
         NVL(TRACKING_QUANTITY_IND,'P'),
         NVL(DUAL_UOM_DEVIATION_HIGH,0),
         NVL(DUAL_UOM_DEVIATION_LOW,0)
       from mtl_system_items_vl msik, /* Bug 5581528 */
            mtl_cross_references mcr
       WHERE msik.organization_id = p_Organization_Id
   AND msik.inventory_item_id   = mcr.inventory_item_id
   AND mcr.cross_reference_type = g_gtin_cross_ref_type
   AND mcr.cross_reference      LIKE g_crossref
   AND (mcr.organization_id     = msik.organization_id
    OR
        mcr.org_independent_flag = 'Y')
   AND mtl_transactions_enabled_flag = 'Y' --Added for bug 5196506
   AND bom_item_type=4; --Added for bug 5196506


END GET_ITEM_LOV_INVTXN;

-- Use of Bind Variables in Inspect Page
-- 2442758

PROCEDURE GET_LPN_LOV_INSPECT
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER ,
   p_projid   IN   NUMBER ,
   p_taskid   IN   NUMBER
)
IS
BEGIN
   OPEN x_lpn_lov FOR
     SELECT DISTINCT wlpn.license_plate_number,
           wlpn.lpn_id,
           NVL(wlpn.inventory_item_id, 0),
           NVL(wlpn.organization_id, 0),
           wlpn.revision,
           wlpn.lot_number,
           wlpn.serial_number,
           wlpn.subinventory_code,
           NVL(wlpn.locator_id, 0),
           NVL(wlpn.parent_lpn_id, 0),
           NVL(wlpn.sealed_status, 2),
           wlpn.gross_weight_uom_code,
           NVL(wlpn.gross_weight, 0),
           wlpn.content_volume_uom_code,
           NVL(wlpn.content_volume, 0),
           milk.concatenated_segments,
           wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv milk,
           wms_lpn_contents wlc
     WHERE wlpn.organization_id = milk.organization_id (+)
       AND wlpn.locator_id = milk.inventory_location_id(+)
       AND wlc.parent_lpn_id (+) = wlpn.lpn_id
       AND wlpn.license_plate_number LIKE p_lpn
       AND wlpn.organization_id = p_orgid
       AND wlpn.lpn_context in (3,5)
       AND (wlpn.lpn_context = 3 and wlpn.lpn_id  IN (Select mtrl.lpn_id from mtl_txn_request_lines mtrl
            where mtrl.lpn_id = wlpn.lpn_id AND NVL(mtrl.project_id, -99)  = p_projid
            AND NVL(mtrl.task_id, -99) = p_taskid ) )
       ORDER BY wlpn.license_plate_number
       ;
END GET_LPN_LOV_INSPECT;

PROCEDURE GET_LPN_LOV_INVTXN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER
)
IS
BEGIN
   OPEN x_lpn_lov FOR
     SELECT DISTINCT wlpn.license_plate_number,
           wlpn.lpn_id,
           NVL(wlpn.inventory_item_id, 0),
           NVL(wlpn.organization_id, 0),
           wlpn.revision,
           wlpn.lot_number,
           wlpn.serial_number,
           wlpn.subinventory_code,
           NVL(wlpn.locator_id, 0),
           NVL(wlpn.parent_lpn_id, 0),
           NVL(wlpn.sealed_status, 2),
           wlpn.gross_weight_uom_code,
           NVL(wlpn.gross_weight, 0),
           wlpn.content_volume_uom_code,
           NVL(wlpn.content_volume, 0),
           milk.concatenated_segments,
           wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv milk,
           wms_lpn_contents wlc
     WHERE wlpn.organization_id = milk.organization_id (+)
       AND wlpn.locator_id = milk.inventory_location_id(+)
       AND wlc.parent_lpn_id (+) = wlpn.lpn_id
       AND wlpn.license_plate_number LIKE p_lpn
       AND wlpn.lpn_context in (1,5)
       AND wlpn.organization_id = p_orgid
       ;
END GET_LPN_LOV_INVTXN;

PROCEDURE GET_LPN_LOV_PJM
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER
)
IS
BEGIN
   OPEN x_lpn_lov FOR
     SELECT DISTINCT wlpn.license_plate_number,
           wlpn.lpn_id,
           NVL(wlpn.inventory_item_id, 0),
           NVL(wlpn.organization_id, 0),
           wlpn.revision,
           wlpn.lot_number,
           wlpn.serial_number,
           wlpn.subinventory_code,
           NVL(wlpn.locator_id, 0),
           NVL(wlpn.parent_lpn_id, 0),
           NVL(wlpn.sealed_status, 2),
           wlpn.gross_weight_uom_code,
           NVL(wlpn.gross_weight, 0),
           wlpn.content_volume_uom_code,
           NVL(wlpn.content_volume, 0),
           INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id,milk.organization_id),
           INV_PROJECT.GET_PROJECT_ID,
           INV_PROJECT.GET_PROJECT_NUMBER,
           INV_PROJECT.GET_TASK_ID,
           INV_PROJECT.GET_TASK_NUMBER,
           wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv milk,
           wms_lpn_contents wlc
     WHERE wlpn.organization_id = milk.organization_id (+)
       AND wlpn.locator_id = milk.inventory_location_id(+)
       AND wlc.parent_lpn_id (+) = wlpn.lpn_id
       AND wlpn.license_plate_number LIKE p_lpn
       AND wlpn.lpn_context in (1,5)
       AND wlpn.organization_id = p_orgid
       ;
END GET_LPN_LOV_PJM;

PROCEDURE GET_COUNTRY_LOV
  (x_country_lov OUT NOCOPY t_genref,
   p_country IN VARCHAR2 )
IS
BEGIN
  OPEN x_country_lov FOR
       SELECT  territory_code, territory_short_name
         FROM  fnd_territories_vl
        WHERE  territory_code LIKE p_country || '%'
     ORDER BY  territory_code;
END GET_COUNTRY_LOV;

PROCEDURE get_hr_hz_locations_lov(
  x_location_codes OUT NOCOPY t_genref,
  p_location_code IN VARCHAR2) IS
  -- This procedure will return all HR and HZ Active Locations.
  -- Added as part of eIB Build; Bug# 4348541
BEGIN
  OPEN x_location_codes FOR
  SELECT location_code, location_id, description
  FROM( SELECT hr.location_code location_code,
               hr.location_id location_id,
               hr.description
         FROM hr_locations hr
         WHERE NVL(inactive_date, SYSDATE+1) > SYSDATE
         UNION
         SELECT DECODE (
           inv_check_product_install.check_cse_install,
           'Y', NVL(clli_code, SUBSTR(city, 1, 10) || SUBSTR(location_id, 1, 10)),
           SUBSTR (city, 1, 10)|| SUBSTR (location_id, 1, 10)) location_code,
           hz.location_id location_id,
           hz.short_description
         FROM hz_locations hz
         WHERE (SYSDATE BETWEEN NVL(hz.address_effective_date,  SYSDATE-1) AND
                                NVL(hz.address_expiration_date, SYSDATE+1)))
  WHERE UPPER(location_code) LIKE UPPER(NVL(p_location_code, location_code)||'%')
  ORDER BY location_code;
END get_hr_hz_locations_lov;

--Added for BUG 4309432
PROCEDURE GET_ACTRJTQTY_LOV
  (x_actrjtqty_lov OUT NOCOPY t_genref,
   p_deliver_type IN VARCHAR2)
IS
BEGIN
  OPEN x_actrjtqty_lov FOR
       SELECT lookup_code, meaning
         FROM mfg_lookups
        WHERE lookup_type = 'INV_RCV_DELIVER_TYPE'
          AND meaning LIKE p_deliver_type || '%' ;
END GET_ACTRJTQTY_LOV;

--Added for Bug 4498173
PROCEDURE GET_INV_ITEM_LOV_RECEIVING
(
	x_Items				OUT NOCOPY t_genref,
	p_Organization_Id		IN NUMBER,
	p_Concatenated_Segments		IN VARCHAR2,
	p_receiptNum			IN VARCHAR2,
	p_poHeaderID			IN VARCHAR2,
	p_poReleaseID			IN VARCHAR2,
	p_poLineID			IN VARCHAR2,
	p_shipmentHeaderID		IN VARCHAR2,
	p_oeOrderHeaderID		IN VARCHAR2,
	p_reqHeaderID			IN VARCHAR2,
	p_shipmentHeaderReceipt		IN VARCHAR2
)

IS

g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;
g_crossref         VARCHAR2(40) := lpad(Rtrim(p_concatenated_segments, '%'), g_gtin_code_length, '00000000000000');
l_append varchar2(2):='';

BEGIN
    l_append:=wms_deploy.get_item_suffix_for_lov(p_concatenated_segments);

    IF (p_receiptNum IS NOT NULL ) THEN

        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN	(
					SELECT item_id
					from rcv_supply
					WHERE shipment_header_id = p_shipmentHeaderReceipt
					)
	UNION

	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN	(
					SELECT item_id
					from rcv_supply
					WHERE shipment_header_id = p_shipmentHeaderReceipt
					);

   ELSIF (p_poHeaderID IS NOT NULL ) THEN

      IF (p_poReleaseID IS NOT NULL ) THEN
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id = p_poHeaderID  and po_release_id = p_poReleaseID)
	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik, /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id = p_poHeaderID  and po_release_id = p_poReleaseID);

      ELSIF (p_poLineID IS NOT null ) THEN
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id =  p_poHeaderID and po_line_id = p_poLineID )
	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id =  p_poHeaderID and po_line_id = p_poLineID );

      ELSE
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id = p_poHeaderID )
	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE po_header_id = p_poHeaderID );
      end if;

    ELSIF (p_shipmentHeaderID IS NOT null ) THEN
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE SHIPMENT_HEADER_ID = p_shipmentHeaderID )
	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE SHIPMENT_HEADER_ID = p_shipmentHeaderID );

    ELSIF (p_reqHeaderID IS NOT NULL ) THEN
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM po_requisition_lines prl WHERE prl.requisition_header_id = p_reqHeaderID
  -- Bug 4346684
  -- Add condition to filter the item that dosen't exists in shipments.
  AND EXISTS(SELECT 1 FROM rcv_supply rs WHERE rs.req_line_id=prl.requisition_line_id and rs.supply_type_code = 'RECEIVING'))

	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM po_requisition_lines prl WHERE prl.requisition_header_id = p_reqHeaderID
  -- Bug 4346684
  -- Add condition to filter the item that dosen't exists in shipments.
  AND EXISTS(SELECT 1 FROM rcv_supply rs WHERE rs.req_line_id=prl.requisition_line_id and rs.supply_type_code = 'RECEIVING'));


    ELSIF (p_oeOrderHeaderID IS NOT NULL ) THEN
        open x_items for
	SELECT
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	null,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug 3952081
	--Select DUOM Attributes for every Item
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik /* Bug 5581528 */
	WHERE
	organization_id = p_Organization_Id
	AND concatenated_segments like p_concatenated_segments||l_append
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE OE_ORDER_HEADER_ID = p_oeOrderHeaderID )
	UNION
	select
	concatenated_segments,
	msik.inventory_item_id,
	msik.description,
	Nvl(revision_qty_control_code,1),
	Nvl(lot_control_code, 1),
	Nvl(serial_number_control_code, 1),
	Nvl(restrict_subinventories_code, 2),
	Nvl(restrict_locators_code, 2),
	Nvl(location_control_code, 1),
	primary_uom_code,
	Nvl(inspection_required_flag, 'N'),
	Nvl(shelf_life_code, 1),
	Nvl(shelf_life_days,0),
	Nvl(allowed_units_lookup_code, 2),
	Nvl(effectivity_control,1),
	0,
	0,
	Nvl(default_serial_status_id,1),
	Nvl(serial_status_enabled,'N'),
	Nvl(default_lot_status_id,0),
	Nvl(lot_status_enabled,'N'),
	mcr.cross_reference,
	'N',
	inventory_item_flag,
	0,
      wms_deploy.get_item_client_name(msik.inventory_item_id),
	inventory_asset_flag,
	outside_operation_flag,
	--Bug No 3952081
	--Additional Fields for Process Convergence
	NVL(GRADE_CONTROL_FLAG,'N'),
	NVL(DEFAULT_GRADE,''),
	NVL(EXPIRATION_ACTION_INTERVAL,0),
	NVL(EXPIRATION_ACTION_CODE,''),
	NVL(HOLD_DAYS,0),
	NVL(MATURITY_DAYS,0),
	NVL(RETEST_INTERVAL,0),
	NVL(COPY_LOT_ATTRIBUTE_FLAG,'N'),
	NVL(CHILD_LOT_FLAG,'N'),
	NVL(CHILD_LOT_VALIDATION_FLAG,'N'),
	NVL(LOT_DIVISIBLE_FLAG,'Y'),
	NVL(SECONDARY_UOM_CODE,''),
	NVL(SECONDARY_DEFAULT_IND,''),
	NVL(TRACKING_QUANTITY_IND,'P'),
	NVL(DUAL_UOM_DEVIATION_HIGH,0),
	NVL(DUAL_UOM_DEVIATION_LOW,0)
	FROM
	mtl_system_items_vl msik,  /* Bug 5581528 */
	mtl_cross_references mcr
	WHERE
	msik.organization_id = p_organization_id
	AND msik.inventory_item_id = mcr.inventory_item_id
	AND mcr.cross_reference_type = g_gtin_cross_ref_type
	AND mcr.cross_reference  like g_crossref
	AND (mcr.organization_id = msik.organization_id
	     OR mcr.org_independent_flag = 'Y' )
	AND (purchasing_enabled_flag = 'Y' OR stock_enabled_flag = 'Y')
	AND msik.inventory_item_id IN (SELECT item_id FROM rcv_supply WHERE OE_ORDER_HEADER_ID = p_oeOrderHeaderID );

    END IF;

END GET_INV_ITEM_LOV_RECEIVING;

--Bug No: 5246626:Added the procedures Print_debug and GET_RCV_SHP_FLEX_DETAILS

PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS

l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
   IF (l_debug = 1) THEN
       inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => 'inv_ui_rcv_lovs', p_level => p_level);
   END IF;
END print_debug;

PROCEDURE GET_RCV_SHP_FLEX_DETAILS
     ( p_shipment_num IN VARCHAR2
     , p_orgid    IN   NUMBER
     , x_attribute1           OUT    NOCOPY VARCHAR2
     , x_attribute2           OUT    NOCOPY VARCHAR2
     , x_attribute3           OUT    NOCOPY VARCHAR2
     , x_attribute4           OUT    NOCOPY VARCHAR2
     , x_attribute5           OUT    NOCOPY VARCHAR2
     , x_attribute6           OUT    NOCOPY VARCHAR2
     , x_attribute7           OUT    NOCOPY VARCHAR2
     , x_attribute8           OUT    NOCOPY VARCHAR2
     , x_attribute9           OUT    NOCOPY VARCHAR2
     , x_attribute10          OUT    NOCOPY VARCHAR2
     , x_attribute11          OUT    NOCOPY VARCHAR2
     , x_attribute12          OUT    NOCOPY VARCHAR2
     , x_attribute13          OUT    NOCOPY VARCHAR2
     , x_attribute14          OUT    NOCOPY VARCHAR2
     , x_attribute15          OUT    NOCOPY VARCHAR2
     , x_val_attribute1       OUT    NOCOPY VARCHAR2
     , x_val_attribute2       OUT    NOCOPY VARCHAR2
     , x_val_attribute3       OUT    NOCOPY VARCHAR2
     , x_val_attribute4       OUT    NOCOPY VARCHAR2
     , x_val_attribute5       OUT    NOCOPY VARCHAR2
     , x_val_attribute6       OUT    NOCOPY VARCHAR2
     , x_val_attribute7       OUT    NOCOPY VARCHAR2
     , x_val_attribute8       OUT    NOCOPY VARCHAR2
     , x_val_attribute9       OUT    NOCOPY VARCHAR2
     , x_val_attribute10      OUT    NOCOPY VARCHAR2
     , x_val_attribute11      OUT    NOCOPY VARCHAR2
     , x_val_attribute12      OUT    NOCOPY VARCHAR2
     , x_val_attribute13      OUT    NOCOPY VARCHAR2
     , x_val_attribute14      OUT    NOCOPY VARCHAR2
     , x_val_attribute15      OUT    NOCOPY VARCHAR2
     , x_attribute_category   OUT    NOCOPY VARCHAR2
     , x_concatenated_val     OUT    NOCOPY VARCHAR2
      )
   IS
       TYPE seg_name IS TABLE OF VARCHAR2(1000)
       INDEX BY BINARY_INTEGER;
       l_context          VARCHAR2(1000);
       l_context_r        fnd_dflex.context_r;
       l_contexts_dr      fnd_dflex.contexts_dr;
       l_dflex_r          fnd_dflex.dflex_r;
       l_segments_dr      fnd_dflex.segments_dr;
       l_enabled_seg_name seg_name;
       l_wms_all_segs_tbl seg_name;
       l_nsegments        BINARY_INTEGER;
       l_global_context   BINARY_INTEGER;
       v_index            NUMBER                := 1;
       l_chk_flag         NUMBER                := 0;
       l_char_count       NUMBER;
       l_num_count        NUMBER;
       l_date_count       NUMBER;
       l_wms_attr_chk     NUMBER                := 1;
       l_return_status    VARCHAR2(1);
       l_msg_count        NUMBER;
       l_msg_data         VARCHAR2(1000);

       /* Variables used for Validate_desccols procedure */
       error_segment      VARCHAR2(30);
       errors_received    EXCEPTION;
       error_msg          VARCHAR2(5000);
       s                  NUMBER;
       e                  NUMBER;
       l_null_char_val    VARCHAR2(1000);
       l_null_num_val     NUMBER;
       l_null_date_val    DATE;
       l_global_nsegments NUMBER := 0;

       col NUMBER;

       l_date DATE;

       TYPE char_tbl IS TABLE OF VARCHAR2(1500)
       INDEX BY BINARY_INTEGER;

       l_attributes_tbl char_tbl;
       l_organization_id NUMBER;
       l_shipment_num varchar2(150);
       l_attrib_num NUMBER;

BEGIN

        l_shipment_num := p_shipment_num;
        l_organization_id := p_orgid;

        select
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
              attribute_category
         into
              x_attribute1,
              x_attribute2,
              x_attribute3,
              x_attribute4,
              x_attribute5,
              x_attribute6,
              x_attribute7,
              x_attribute8,
              x_attribute9,
              x_attribute10,
              x_attribute11,
              x_attribute12,
              x_attribute13,
              x_attribute14,
              x_attribute15,
              x_attribute_category
        from  rcv_shipment_headers rsh
       where  rsh.shipment_num = l_shipment_num
         and  rsh.ship_to_org_id = l_organization_id;



  BEGIN
        l_attributes_tbl (1) := x_attribute1;
        l_attributes_tbl (2) := x_attribute2;
        l_attributes_tbl (3) := x_attribute3;
        l_attributes_tbl (4) := x_attribute4;
        l_attributes_tbl (5) := x_attribute5;
        l_attributes_tbl (6) := x_attribute6;
        l_attributes_tbl (7) := x_attribute7;
        l_attributes_tbl (8) := x_attribute8;
        l_attributes_tbl (9) := x_attribute9;
        l_attributes_tbl (10) := x_attribute10;
        l_attributes_tbl (11) := x_attribute11;
        l_attributes_tbl (12) := x_attribute12;
        l_attributes_tbl (13) := x_attribute13;
        l_attributes_tbl (14) := x_attribute14;
        l_attributes_tbl (15) := x_attribute15;

        l_dflex_r.application_id  := 201;
        l_dflex_r.flexfield_name  := 'RCV_SHIPMENT_HEADERS';

        print_debug('BEFORE SETTING THE ATTRIBUTES CONTEXT',4);

        l_dflex_r.application_id  := 201;
        l_dflex_r.flexfield_name  := 'RCV_SHIPMENT_HEADERS';

        print_debug('BEFORE SETTING THE ATTRIBUTES CONTEXT',4);

        /* Get all contexts */
        fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

        print_debug('Found contexts for the Flexfield MTL_LOT_NUMBERS',4);

         /* From the l_contexts_dr, get the position of the global context */
        l_global_context          := l_contexts_dr.global_context;

        print_debug('Found the position of the global context  ',4);

        /* Using the position get the segments in the global context which are enabled */
        l_context                 := l_contexts_dr.context_code(l_global_context);

        /* Prepare the context_r type for getting the segments associated with the global context */

        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;

        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

        print_debug('After successfully getting all the enabled segmenst for the Global Context ',4);

        /* read through the segments */

        l_nsegments               := l_segments_dr.nsegments;
        l_global_nsegments        := l_segments_dr.nsegments;

        print_debug('The number of enabled segments for the Global Context are ' || l_nsegments,4);

     FOR i IN 1 .. l_nsegments LOOP
          l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

          IF l_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
               print_debug('setting column values',4);
               print_debug('Actual Value is ' ||
                       l_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
                 , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)), 4);

             fnd_flex_descval.set_column_value(
               l_segments_dr.application_column_name(i)
             , l_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
                 , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
             );
           ELSE
             fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
           END IF;
           v_index  := v_index + 1;
     END LOOP;

      IF l_enabled_seg_name.COUNT > 0 THEN
           FOR i IN l_enabled_seg_name.FIRST .. l_enabled_seg_name.LAST LOOP
               print_debug('The enabled segment : ' || l_enabled_seg_name(i), 4);
        END LOOP;
      END IF;

        /* Initialise the l_context_value to null */
         l_context                 := NULL;
         l_nsegments               := 0;

         /*Get the context for the item passed */
      IF x_attribute_category IS NOT NULL THEN
           l_context                 := x_attribute_category;
           /* Set flex context for validation of the value set */
           fnd_flex_descval.set_context_value(l_context);
           print_debug('The value of INV context is ' || l_context, 4);

           /* Prepare the context_r type */
           l_context_r.flexfield     := l_dflex_r;
           l_context_r.context_code  := l_context;

           fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

           /* read through the segments */
           l_nsegments               := l_segments_dr.nsegments;

           print_debug('No of segments enabled for context ' || l_context || ' are ' || l_nsegments, 4);
           print_debug('v_index is ' || v_index, 4);

           FOR i IN 1 .. l_nsegments LOOP

             l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

             print_debug('The segment is ' || l_segments_dr.segment_name(i), 4);

             IF l_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                  , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN

               fnd_flex_descval.set_column_value(
                 l_segments_dr.application_column_name(i)
               , l_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
                   , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
               );
             ELSE
               fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
             END IF;
             v_index  := v_index + 1;
      END LOOP;
    END IF;

    IF (l_global_nsegments > 0 AND x_attribute_Category IS NULL ) THEN
             print_debug('global segments > 0', 4);
             l_context                 := l_contexts_dr.context_code(l_global_context);
             fnd_flex_descval.set_context_value(l_context);
    End if;

    IF fnd_flex_descval.validate_desccols(appl_short_name => 'PO',
               desc_flex_name => 'RCV_SHIPMENT_HEADERS', values_or_ids => 'I'
              , validation_date              => SYSDATE) THEN
               print_debug('Value set validation successful', 4);
    ELSE
               error_segment  := fnd_flex_descval.error_segment;
               print_debug('The error segment is : ' || fnd_flex_descval.error_segment, 4);
               RAISE errors_received;
    END IF;

    x_concatenated_val := fnd_flex_descval.concatenated_values;
    print_debug('The concatenated values is : ' || x_concatenated_val , 4);

       /** Retrun the VALUES to java */
       /** This Part of code is kept for future Use **********
       for i in 1..v_index
       Loop
          BEGIN

             l_attrib_num := SUBSTR(l_enabled_seg_name(i)
                   , INSTR(l_enabled_seg_name(i), 'ATTRIBUTE') + 9);

             if l_attrib_num = 1 then
                x_val_attribute1 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 2 then
                x_val_attribute2 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 3 then
                x_val_attribute3 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 4 then
                x_val_attribute4 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 5 then
                x_val_attribute5 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num =6  then
                x_val_attribute6 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 7 then
                x_val_attribute7 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num =8  then
                x_val_attribute8 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 9  then
                x_val_attribute9 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 10 then
                x_val_attribute10 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 11 then
                x_val_attribute11 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 12 then
                x_val_attribute12 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 13 then
                x_val_attribute13 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 14 then
                x_val_attribute14 := fnd_flex_descval.Segment_Value(i);
             End if;
             if l_attrib_num = 15 then
                x_val_attribute15 := fnd_flex_descval.Segment_Value(i);
             End if;
          EXCEPTION
              WHEN OTHERS THEN NULL;
          END;
        End Loop;
        *******************************************/

  EXCEPTION
    WHEN OTHERS THEN
      print_debug('Can not get the concatenatd values due to problem in flexfield data ' , 4);
      print_debug('OTHER EXCEPTION OCCURED AT GET_RCV_SHIP_FLEX_DETAILS' , 4);
  END;

EXCEPTION
    WHEN OTHERS THEN
      print_debug('Can not Obtain the dff values for Shipment. Issue in shipment or org ' , 4);
      print_debug('Value of Shipment = ' || l_shipment_num  , 4);
      print_debug('Value of Org = ' || l_organization_id  , 4);
END GET_RCV_SHP_FLEX_DETAILS;

END INV_UI_RCV_LOVS;

/
