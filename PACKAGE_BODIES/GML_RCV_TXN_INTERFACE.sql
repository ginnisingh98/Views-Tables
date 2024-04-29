--------------------------------------------------------
--  DDL for Package Body GML_RCV_TXN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RCV_TXN_INTERFACE" AS
/* $Header: GMLTISVB.pls 120.0 2005/05/25 16:27:15 appldev noship $*/

 x_interface_type                       varchar2(25) := 'RCV-856';
 x_dummy_flag                           varchar2(1)  := 'Y';

 g_pkg_name CONSTANT VARCHAR2(30) := 'GML_RCV_TXN_INTERFACE';

PROCEDURE matching_logic
  (
   x_return_status         OUT nocopy VARCHAR2
   ,x_msg_count            OUT nocopy NUMBER
   ,x_msg_data             OUT nocopy VARCHAR2
   ,x_cascaded_table    IN OUT NOCOPY cascaded_trans_tab_type
   ,n                   IN OUT nocopy BINARY_INTEGER
   ,temp_cascaded_table IN OUT nocopy cascaded_trans_tab_type
   ,p_receipt_num          IN         VARCHAR2
   ,p_shipment_header_id   IN         NUMBER
   ,p_lpn_id               IN         NUMBER)
  IS
     CURSOR asn_shipments
       (
        v_item_id                 NUMBER
        , v_po_line_id            NUMBER
        , v_po_line_location_id   NUMBER
        , v_po_release_id         NUMBER
        , v_ship_to_org_id        NUMBER
        , v_ship_to_location_id   NUMBER
        , v_shipment_header_id    NUMBER
        , v_lpn_id                NUMBER
        , v_item_desc             VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)
       IS
          SELECT
            pll.line_location_id
            , pll.unit_meas_lookup_code
            , Nvl(pll.promised_date,pll.need_by_date)   promised_date
            , pll.quantity_shipped
            , pll.receipt_days_exception_code
            , pll.qty_rcv_exception_code
            , pll.days_early_receipt_allowed
            , pll.days_late_receipt_allowed
            , 0                                                 po_distribution_id
            , pll.ship_to_location_id
            , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
            , 0 rcv_transaction_id -- only need it for std_deliver
            , pl.item_revision --only needed for std_deliver
            FROM
            po_line_locations   pll,
            po_lines            pl,
            po_headers          ph,
            rcv_shipment_lines  rsl,
            (SELECT DISTINCT source_line_id
             FROM wms_lpn_contents
             WHERE parent_lpn_id = v_lpn_id) wlc
            WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
            AND pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            --AND pl.item_id                      = v_item_id
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            AND NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND rsl.shipment_header_id            = v_shipment_header_id
            AND rsl.po_line_location_id           = pll.line_location_id
            AND pll.po_line_id                    = wlc.source_line_id (+)
            AND pll.line_location_id in
             ( select pod.line_location_id from po_distributions pod
                         where (v_project_id is null or
                                         (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                      pod.project_id = v_project_id
                     )
                                  and (v_task_id is null or pod.task_id = v_task_id)
              and  pod.po_header_id = pll.po_header_id
                       )
            ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_asn_shipments
       (
        v_item_id                 NUMBER
        , v_po_line_id            NUMBER
        , v_po_line_location_id   NUMBER
        , v_po_release_id         NUMBER
        , v_ship_to_org_id        NUMBER
        , v_ship_to_location_id   NUMBER
        , v_shipment_header_id    NUMBER
        , v_lpn_id                NUMBER
        , v_item_desc             VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)
       IS
          SELECT COUNT(*)
            FROM
            po_line_locations   pll,
            po_lines            pl,
            po_headers          ph,
            rcv_shipment_lines  rsl,
            (SELECT DISTINCT source_line_id
             FROM wms_lpn_contents
             WHERE parent_lpn_id = v_lpn_id) wlc
            WHERE pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
            AND pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            --AND pl.item_id                      = v_item_id
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            AND NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND rsl.shipment_header_id            = v_shipment_header_id
            AND rsl.po_line_location_id           = pll.line_location_id
            AND pll.po_line_id                    = wlc.source_line_id (+)
            AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions pod
                            where ( v_project_id is null or
                                  (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
                          and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                );

     CURSOR asn_shipments_w_po
       (
          header_id               NUMBER
        , v_item_id               NUMBER
        , v_po_line_id            NUMBER
        , v_po_line_location_id   NUMBER
        , v_po_release_id         NUMBER
        , v_ship_to_org_id        NUMBER
        , v_ship_to_location_id   NUMBER
        , v_shipment_header_id    NUMBER
        , v_lpn_id                NUMBER
        , v_item_desc             VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)
       IS
          SELECT
            pll.line_location_id
            , pll.unit_meas_lookup_code
            , Nvl(pll.promised_date,pll.need_by_date)   promised_date
            , pll.quantity_shipped
            , pll.receipt_days_exception_code
            , pll.qty_rcv_exception_code
            , pll.days_early_receipt_allowed
            , pll.days_late_receipt_allowed
            , 0                                                 po_distribution_id
            , pll.ship_to_location_id
            , Nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
            , 0 rcv_transaction_id -- only need it for std_deliver
            , pl.item_revision --only needed for std_deliver
            FROM
            po_line_locations   pll,
            po_lines            pl,
            po_headers          ph,
            rcv_shipment_lines  rsl,
            (SELECT DISTINCT source_line_id
             FROM wms_lpn_contents
             WHERE parent_lpn_id = v_lpn_id) wlc
            WHERE ph.po_header_id                 = header_id
            AND pll.po_header_id                  = header_id
            AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
            AND pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            --AND pl.item_id                      = v_item_id
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            AND NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND rsl.shipment_header_id            = v_shipment_header_id
            AND rsl.po_line_location_id           = pll.line_location_id
            AND pll.po_line_id                    = wlc.source_line_id (+)
            AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions pod
                            where ( v_project_id is null or
                                  (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
                          and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                )
            ORDER BY Nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_asn_shipments_w_po
       (
          header_id               NUMBER
        , v_item_id               NUMBER
        , v_po_line_id            NUMBER
        , v_po_line_location_id   NUMBER
        , v_po_release_id         NUMBER
        , v_ship_to_org_id        NUMBER
        , v_ship_to_location_id   NUMBER
        , v_shipment_header_id    NUMBER
        , v_lpn_id                NUMBER
        , v_item_desc             VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)
       IS
          SELECT COUNT(*)
            FROM
            po_line_locations   pll,
            po_lines            pl,
            po_headers          ph,
            rcv_shipment_lines  rsl,
            (SELECT DISTINCT source_line_id
             FROM wms_lpn_contents
             WHERE parent_lpn_id = v_lpn_id) wlc
            WHERE ph.po_header_id                 = header_id
            AND pll.po_header_id                  = header_id
            AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            AND Nvl(pll.po_release_id,0)          = Nvl(v_po_release_id,Nvl(pll.po_release_id,0))
            AND pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            --AND pl.item_id                      = v_item_id
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            AND NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            AND NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            AND NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            AND pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            AND pll.ship_to_organization_id       = Nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            AND pll.ship_to_location_id           = Nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND rsl.shipment_header_id            = v_shipment_header_id
            AND rsl.po_line_location_id           = pll.line_location_id
            AND pll.po_line_id                    = wlc.source_line_id (+)
            AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions pod
                            where ( v_project_id is null or
                                  (v_project_id = -9999 and pod.project_id is null) or --Bug# 2669021
                         pod.project_id = v_project_id
                        )
                          and (v_task_id is null or pod.task_id = v_task_id)
                 and   pod.po_header_id = pll.po_header_id
                ) ;

     cursor shipments
       (
          header_id              NUMBER
        , v_item_id              NUMBER
        , v_revision             VARCHAR2
        , v_po_line_id           NUMBER
        , v_po_line_location_id  NUMBER
        , v_po_release_id        NUMBER
        , v_ship_to_org_id       NUMBER
        , v_ship_to_location_id  NUMBER
        , v_item_desc            VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)
       is
          select
            pll.line_location_id
            , pll.unit_meas_lookup_code
            , nvl(pll.promised_date,pll.need_by_date)   promised_date
            , pll.quantity_shipped
            , pll.receipt_days_exception_code
            , pll.qty_rcv_exception_code
            , pll.days_early_receipt_allowed
            , pll.days_late_receipt_allowed
            , 0                                                 po_distribution_id
            , pll.ship_to_location_id
            , nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
            , 0 rcv_transaction_id -- only need it for std_deliver
            , pl.item_revision --only needed for std_deliver
            from        po_line_locations_all   pll,
            po_lines_all                pl,
            po_headers_all              ph
            where ph.po_header_id                 = header_id
            and pll.po_header_id                  = header_id
            AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
            and pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            AND ((v_revision IS NOT NULL
                  AND Nvl(pl.item_revision, v_revision) = v_revision)
                 OR (v_revision IS NULL))
            and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions pod
                  where (v_project_id is null
                         or ((v_project_id = -9999 and pod.project_id is null)--Bug# 2669021
                             or (nvl(pod.project_id,-99) = v_project_id )))
                  and   (v_task_id is null or nvl(pod.task_id,-9999) = v_task_id)
                  and   pod.po_header_id = pll.po_header_id
                 )
            order by pl.item_revision, nvl(pll.promised_date,pll.need_by_date);


     CURSOR count_shipments
       (  header_id               NUMBER
        , v_item_id               NUMBER
        , v_revision              VARCHAR2
        , v_po_line_id            NUMBER
        , v_po_line_location_id   NUMBER
        , v_po_release_id         NUMBER
        , v_ship_to_org_id        NUMBER
        , v_ship_to_location_id   NUMBER
        , v_item_desc            VARCHAR2
        , v_project_id            NUMBER
        , v_task_id               NUMBER)

       IS
          SELECT COUNT(*)
            from  po_line_locations_all pll,
                  po_lines_all                  pl
            WHERE pll.po_header_id                = header_id
            AND pll.po_line_id                    = Nvl(v_po_line_id, pll.po_line_id)
            AND pll.line_location_id              = Nvl(v_po_line_location_id, pll.line_location_id)
            and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
            and pll.po_line_id                    = pl.po_line_id
            -- change for non item master receipts.
            and (   pl.item_id                    = v_item_id
                 OR (    v_item_id IS NULL
                     AND pl.item_id IS NULL
                     AND pl.item_description = v_item_desc))
            -- and pl.item_id                        = v_item_id
            AND ((v_revision IS NOT NULL
                  AND Nvl(pl.item_revision, v_revision) = v_revision)
                 OR (v_revision IS NULL))
            and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
            and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
            and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
            and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
            and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
            and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
            AND pll.line_location_id in
                ( select pod.line_location_id
                  from po_distributions pod
                  where (v_project_id is null
                         or ((v_project_id = -9999 and pod.project_id is null)--Bug# 2669021
                             or (nvl(pod.project_id,-99) = v_project_id )))
                  and   (v_task_id is null or nvl(pod.task_id,-9999) = v_task_id)
                  and   pod.po_header_id = pll.po_header_id
                 );

 cursor distributions (
  header_id             number
 ,v_item_id             number
 ,v_revision            VARCHAR2
 ,v_po_line_id          NUMBER
 ,v_po_line_location_id NUMBER
 ,v_po_distribution_id  NUMBER
 ,v_po_release_id       number
 ,v_ship_to_org_id      number
 ,v_ship_to_location_id NUMBER
 ,v_item_desc           VARCHAR2
 , v_project_id           NUMBER
 , v_task_id              NUMBER) is
 select
  pll.line_location_id
 ,pll.unit_meas_lookup_code
 ,nvl(pll.promised_date,pll.need_by_date)       promised_date
 ,pll.quantity_shipped
 ,pll.receipt_days_exception_code
 ,pll.qty_rcv_exception_code
 ,pll.days_early_receipt_allowed
 ,pll.days_late_receipt_allowed
 ,pod.po_distribution_id
 ,pll.ship_to_location_id
 ,nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
 ,0 rcv_transaction_id -- only need it for std_deliver
 ,pl.item_revision --only needed for std_deliver
 from  po_distributions    pod,
       po_line_locations   pll,
       po_lines            pl,
       po_headers          ph
 where ph.po_header_id                 = header_id
 and pod.po_header_id                  = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and ph.po_header_id                   = pl.po_header_id
 and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
 and pll.po_line_id                    = pl.po_line_id
 --and pl.item_id                              = v_item_id
 -- change for non item master receipts.
 and (   pl.item_id                    = v_item_id
      OR (  v_item_id IS NULL
               AND pl.item_id IS NULL
               AND pl.item_description = v_item_desc))
 AND ((v_revision IS NOT NULL
       AND Nvl(pl.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.line_location_id              = pod.line_location_id
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 and (v_project_id is null or
       ( v_project_id = -9999 and pod.project_id is null ) or --Bug# 2669021
         pod.project_id = v_project_id)
 and (v_task_id is null or pod.task_id = v_task_id)
 order by pl.item_revision, nvl(pll.promised_date,pll.need_by_date);

 cursor count_distributions (
   header_id                    number
 , v_item_id                    number
 , v_revision                   VARCHAR2
 , v_po_line_id                 NUMBER
 , v_po_line_location_id        NUMBER
 , v_po_distribution_id         NUMBER
 , v_po_release_id              number
 , v_ship_to_org_id             number
 , v_ship_to_location_id        number
 , v_item_desc                  VARCHAR2
 , v_project_id                 NUMBER
 , v_task_id                    NUMBER) is
 select count(*)
 from po_distributions  pod,
      po_line_locations pll,
      po_lines          pl
 where pll.po_header_id                = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and nvl(pll.po_release_id,0)          = nvl(v_po_release_id,nvl(pll.po_release_id,0))
 and pll.po_line_id                    = pl.po_line_id
 --and pl.item_id                              = v_item_id
 -- change for non item master receipts.
 and (   pl.item_id                    = v_item_id
      OR (  v_item_id IS NULL
               AND pl.item_id IS NULL
               AND pl.item_description = v_item_desc))
 AND ((v_revision IS NOT NULL
       AND Nvl(pl.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.line_location_id              = pod.line_location_id
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 and (v_project_id is null or
       ( v_project_id = -9999 and pod.project_id is null ) or --Bug# 2669021
         pod.project_id = v_project_id)
 and (v_task_id is null or pod.task_id = v_task_id) ;

 ----
 cursor std_distributions (
  header_id             number
 ,v_item_id             number
 ,v_revision            varchar2
 ,v_po_line_id          NUMBER
 ,v_po_line_location_id NUMBER
 ,v_po_distribution_id  NUMBER
 ,v_po_release_id       number
 ,v_ship_to_org_id      number
 ,v_ship_to_location_id number
 ,v_receipt_num         varchar2
 ,v_txn_date            DATE
 ,v_inspection_status   VARCHAR2
 ,v_lpn_id              NUMBER) is
 select
  pll.line_location_id
 ,pll.unit_meas_lookup_code
 ,nvl(pll.promised_date,pll.need_by_date)       promised_date
 ,0 --pll.quantity_shipped
 ,pll.receipt_days_exception_code
 ,pll.qty_rcv_exception_code
 ,pll.days_early_receipt_allowed
 ,pll.days_late_receipt_allowed
 ,pod.po_distribution_id
 ,pll.ship_to_location_id
 ,nvl(pll.enforce_ship_to_location_code,'NONE') enforce_ship_to_location_code
 ,rs.rcv_transaction_id
 ,rs.item_revision
 from  po_distributions     pod,
       po_line_locations    pll,
       po_lines             pl,
       po_headers           ph,
       rcv_supply           rs,
       rcv_shipment_headers rsh,
--       rcv_shipment_lines   rsl,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
 AND ph.po_header_id                   = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
-- and pl.item_id                      = v_item_id
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 -- for all the transactions in rt for which we can putaway, the
 -- transfer_lpn_id should match the lpn being putaway.
 --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
 -- Fix for 1865886. Commented the above and added the following for lpn
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                            from rcv_transactions rt2
                           where rt2.transaction_type <> 'DELIVER'
                           start with rt2.transaction_id = rs.supply_source_id
                         connect by prior rt2.transaction_id = rt2.parent_transaction_id
                        union all
                          select nvl(rt2.lpn_id,-1)
                            from rcv_transactions rt2
                           where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                           start with rt2.transaction_id = rs.supply_source_id
                         connect by prior rt2.transaction_id = rt2.parent_transaction_id
                          )
  --
 and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 --and rt.transaction_type <> 'UNORDERED'
 --
 and rs.po_header_id = header_id
 and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)))
 --
 order by rs.item_revision, nvl(pll.promised_date,pll.need_by_date);

 cursor count_std_distributions (
   header_id                    number
 , v_item_id                    NUMBER
 , v_revision                   varchar2
 , v_po_line_id                 NUMBER
 , v_po_line_location_id        NUMBER
 , v_po_distribution_id         NUMBER
 , v_po_release_id              number
 , v_ship_to_org_id             number
 , v_ship_to_location_id        number
 , v_receipt_num                VARCHAR2
 , v_txn_date                   DATE
 , v_inspection_status          VARCHAR2
 , v_lpn_id                     NUMBER) is
select count(*)
 from  po_distributions     pod,
       po_line_locations    pll,
       po_lines             pl,
       po_headers           ph,
       rcv_supply           rs,
       rcv_shipment_headers rsh,
--       rcv_shipment_lines   rsl,
       rcv_transactions     rt
 where rsh.receipt_source_code         = 'VENDOR'
 AND ph.po_header_id                   = header_id
 AND pod.po_line_id                    = Nvl(v_po_line_id, pod.po_line_id)
 AND pod.line_location_id              = Nvl(v_po_line_location_id, pod.line_location_id)
 AND pod.po_distribution_id            = Nvl(v_po_distribution_id, pod.po_distribution_id)
 and pl.po_line_id                     = rs.po_line_id
 and pll.line_location_id              = rs.po_line_location_id
 and pod.line_location_id              = rs.po_line_location_id
-- and NVL(pl.item_id,0)               = nvl(v_item_id,nvl(pl.item_id,0))
 and NVL(pll.APPROVED_FLAG,'N')        = 'Y'
 and NVL(pll.CANCEL_FLAG, 'N')         = 'N'
 and NVL(pll.CLOSED_CODE,'OPEN')       <> 'FINALLY CLOSED'
 and pll.SHIPMENT_TYPE                 IN ('STANDARD','BLANKET','SCHEDULED')
 and pll.ship_to_organization_id       = nvl(v_ship_to_org_id,pll.ship_to_organization_id)
 and pll.ship_to_location_id           = nvl(v_ship_to_location_id,pll.ship_to_location_id)
 AND RT.TRANSACTION_TYPE               <> 'UNORDERED'
 -- for all the transactions in rt for which we can putaway, the
 -- transfer_lpn_id should match the lpn being putaway.
 --AND Nvl(rt.transfer_lpn_id,-1)        = Nvl(v_lpn_id,-1)
 -- Fix for 1865886. Commented the above and added the following for lpn
 AND Nvl(v_lpn_id,-1) IN (select nvl(rt2.transfer_lpn_id,-1)
                            from rcv_transactions rt2
                           where rt2.transaction_type <> 'DELIVER'
                           start with rt2.transaction_id = rs.supply_source_id
                         connect by prior rt2.transaction_id = rt2.parent_transaction_id
                        union all
                          select nvl(rt2.lpn_id,-1)
                            from rcv_transactions rt2
                           where rt2.transaction_type not in ('RECEIVE', 'DELIVER')
                           start with rt2.transaction_id = rs.supply_source_id
                         connect by prior rt2.transaction_id = rt2.parent_transaction_id
                          )
  --
 and rs.supply_type_code               = 'RECEIVING'
 --and rsl.shipment_line_id   = rs.shipment_line_id
 and rsh.shipment_header_id            = rs.shipment_header_id
 AND (Nvl(rsh.receipt_num,'@@@'))      = Nvl(v_receipt_num,Nvl(rsh.receipt_num,'@@@'))
 and rt.transaction_id                 = rs.rcv_transaction_id
 AND rt.transaction_date               < Nvl(v_txn_date,(rt.transaction_date + 1))
 --and rt.transaction_type <> 'UNORDERED'
 --
 and rs.po_header_id = header_id
 and rs.item_id      = v_item_id
 AND ((v_revision IS NOT NULL
       AND Nvl(rs.item_revision, v_revision) = v_revision)
      OR (v_revision IS NULL))
 AND (rt.routing_header_id IS NULL OR
      rt.routing_header_id <> 2 OR
      (rt.routing_header_id = 2
       AND rt.inspection_status_code <> 'NOT INSPECTED'
       AND rt.inspection_status_code = Nvl(v_inspection_status,rt.inspection_status_code)));
 ----


    l_item_no VARCHAR(100);

    CURSOR Get_Item_No (p_item_id NUMBER, p_organization_id NUMBER) IS
         select segment1
         from mtl_system_items
         where inventory_item_id = p_item_id and
               organization_id=p_organization_id;

/*
** Debug: had to change this to the distribution record
** Might be a compatibility issue between the two record definitions
*/
 x_ShipmentDistributionRec      distributions%rowtype;
 x_record_count                 number;

 x_remaining_quantity           number := 0;
 x_remaining_qty_po_uom         number := 0;
 x_bkp_qty                      number := 0;
 x_progress                     varchar2(3);
 x_converted_trx_qty            number := 0;
 transaction_ok                 boolean := FALSE;
 x_expected_date                rcv_transactions_interface.expected_receipt_date%TYPE;
 high_range_date                DATE;
 low_range_date                 DATE;
 rows_fetched                   number := 0;
 x_tolerable_qty                number := 0;
 x_first_trans                  boolean := TRUE;
 x_sysdate                      DATE    := sysdate;
 current_n                      binary_integer := 0;
 insert_into_table              boolean := FALSE;
 x_qty_rcv_exception_code       po_line_locations.qty_rcv_exception_code%type;
 tax_amount_factor              number;
 lastrecord                     boolean := FALSE;

 po_asn_uom_qty                 number;
 po_primary_uom_qty             number;

 already_allocated_qty          number := 0;

 x_item_id                      number;
 x_approved_flag                varchar(1);
 x_cancel_flag                  varchar(1);
 x_closed_code                  varchar(25);
 x_shipment_type                varchar(25);
 x_ship_to_location_id          number;
 x_vendor_product_num           varchar(25);
 x_temp_count                   number;
 l_asn_received_qty             NUMBER := 0;

 l_api_name             CONSTANT VARCHAR2(30) := 'matching_logic';


BEGIN

   x_return_status := fnd_api.g_ret_sts_success;

   SAVEPOINT rcv_transactions_sa;
   -- the following steps will create a set of rows linking the line_record with
   -- its corresponding po_line_location rows until the quantity value from
   -- the asn is consumed.  (Cascade)
   if ((x_cascaded_table(n).po_header_id is not null)           AND
       ((x_cascaded_table(n).item_id is not NULL
         OR (x_cascaded_table(n).item_desc IS NOT NULL
             AND x_cascaded_table(n).transaction_type in ('DELIVER','RECEIVE'))))       AND
       (x_cascaded_table(n).error_status in ('S','W'))) then

       -- Copy record from main table to temp table

       current_n := 1;
       temp_cascaded_table(current_n) := x_cascaded_table(n);

       -- Get all rows which meet this condition

       IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN

          IF (p_shipment_header_id IS NOT NULL) THEN -- matching is called from ASN shipment matching
             IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
                OPEN asn_shipments
                  (temp_cascaded_table(current_n).item_id,
                   temp_cascaded_table(current_n).po_line_id,
                   temp_cascaded_table(current_n).po_line_location_id,
                   temp_cascaded_table(current_n).po_release_id,
                   temp_cascaded_table(current_n).to_organization_id,
                   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                   p_shipment_header_id,
                   p_lpn_id,
                   temp_cascaded_table(current_n).item_desc,
                   temp_cascaded_table(current_n).project_id,
                   temp_cascaded_table(current_n).task_id);

                OPEN count_asn_shipments
                  (temp_cascaded_table(current_n).item_id,
                   temp_cascaded_table(current_n).po_line_id,
                   temp_cascaded_table(current_n).po_line_location_id,
                   temp_cascaded_table(current_n).po_release_id,
                   temp_cascaded_table(current_n).to_organization_id,
                   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                   p_shipment_header_id,
                   p_lpn_id,
                   temp_cascaded_table(current_n).item_desc,
                   temp_cascaded_table(current_n).project_id,
                   temp_cascaded_table(current_n).task_id);
              ELSE
                OPEN asn_shipments_w_po
                  (temp_cascaded_table(current_n).po_header_id,
                   temp_cascaded_table(current_n).item_id,
                   temp_cascaded_table(current_n).po_line_id,
                   temp_cascaded_table(current_n).po_line_location_id,
                   temp_cascaded_table(current_n).po_release_id,
                   temp_cascaded_table(current_n).to_organization_id,
                   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                   p_shipment_header_id,
                   p_lpn_id,
                   temp_cascaded_table(current_n).item_desc,
                   temp_cascaded_table(current_n).project_id,
                   temp_cascaded_table(current_n).task_id);

                OPEN count_asn_shipments_w_po
                  (temp_cascaded_table(current_n).po_header_id,
                   temp_cascaded_table(current_n).item_id,
                   temp_cascaded_table(current_n).po_line_id,
                   temp_cascaded_table(current_n).po_line_location_id,
                   temp_cascaded_table(current_n).po_release_id,
                   temp_cascaded_table(current_n).to_organization_id,
                   NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                   p_shipment_header_id,
                   p_lpn_id,
                   temp_cascaded_table(current_n).item_desc,
                   temp_cascaded_table(current_n).project_id,
                   temp_cascaded_table(current_n).task_id);
             END IF;
           ELSE -- normal PO receipt
             OPEN shipments (temp_cascaded_table(current_n).po_header_id,
                             temp_cascaded_table(current_n).item_id,
                             temp_cascaded_table(current_n).revision,
                             temp_cascaded_table(current_n).po_line_id,
                             temp_cascaded_table(current_n).po_line_location_id,
                             temp_cascaded_table(current_n).po_release_id,
                             temp_cascaded_table(current_n).to_organization_id,
                             NULL, --temp_cascaded_table(current_n).ship_to_location_id,
                             temp_cascaded_table(current_n).item_desc,
                temp_cascaded_table(current_n).project_id,
                temp_cascaded_table(current_n).task_id);

             -- count_shipments just gets the count of rows found in shipments

             OPEN count_shipments (temp_cascaded_table(current_n).po_header_id,
                                   temp_cascaded_table(current_n).item_id,
                                   temp_cascaded_table(current_n).revision,
                                   temp_cascaded_table(current_n).po_line_id,
                                   temp_cascaded_table(current_n).po_line_location_id,
                                   temp_cascaded_table(current_n).po_release_id,
                                   temp_cascaded_table(current_n).to_organization_id,
                                   NULL, --temp_cascaded_table(current_n).ship_to_location_id,
                                   temp_cascaded_table(current_n).item_desc,
                temp_cascaded_table(current_n).project_id,
                temp_cascaded_table(current_n).task_id);
          END IF;

       ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN

          open distributions (temp_cascaded_table(current_n).po_header_id,
                              temp_cascaded_table(current_n).item_id,
                              temp_cascaded_table(current_n).revision,
                              temp_cascaded_table(current_n).po_line_id,
                              temp_cascaded_table(current_n).po_line_location_id,
                              temp_cascaded_table(current_n).po_distribution_id,
                              temp_cascaded_table(current_n).po_release_id,
                              temp_cascaded_table(current_n).to_organization_id,
                              NULL, --temp_cascaded_table(current_n).ship_to_location_id,
                              temp_cascaded_table(current_n).item_desc,
                temp_cascaded_table(current_n).project_id,
                temp_cascaded_table(current_n).task_id);

          -- count_distributions just gets the count of rows found in distributions

          open count_distributions (temp_cascaded_table(current_n).po_header_id,
                                    temp_cascaded_table(current_n).item_id,
                                    temp_cascaded_table(current_n).revision,
                                    temp_cascaded_table(current_n).po_line_id,
                                    temp_cascaded_table(current_n).po_line_location_id,
                                    temp_cascaded_table(current_n).po_distribution_id,
                                    temp_cascaded_table(current_n).po_release_id,
                                    temp_cascaded_table(current_n).to_organization_id,
                                    NULL, --temp_cascaded_table(current_n).ship_to_location_id,
                                    temp_cascaded_table(current_n).item_desc,
                temp_cascaded_table(current_n).project_id,
                temp_cascaded_table(current_n).task_id);

       ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
          open std_distributions (
                              temp_cascaded_table(current_n).po_header_id,
                              temp_cascaded_table(current_n).item_id,
                              temp_cascaded_table(current_n).revision,
                              temp_cascaded_table(current_n).po_line_id,
                              temp_cascaded_table(current_n).po_line_location_id,
                              temp_cascaded_table(current_n).po_distribution_id,
                              temp_cascaded_table(current_n).po_release_id,
                              temp_cascaded_table(current_n).to_organization_id,
                              NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                              p_receipt_num,
                              temp_cascaded_table(current_n).expected_receipt_date,
                              temp_cascaded_table(current_n).inspection_status_code,
                              temp_cascaded_table(current_n).p_lpn_id);

          -- count_distributions just gets the count of rows found in distributions

          open count_std_distributions (temp_cascaded_table(current_n).po_header_id,
                                        temp_cascaded_table(current_n).item_id,
                                        temp_cascaded_table(current_n).revision,
                                        temp_cascaded_table(current_n).po_line_id,
                                        temp_cascaded_table(current_n).po_line_location_id,
                                        temp_cascaded_table(current_n).po_distribution_id,
                                        temp_cascaded_table(current_n).po_release_id,
                                        temp_cascaded_table(current_n).to_organization_id,
                                        NULL,--temp_cascaded_table(current_n).ship_to_location_id,
                                        p_receipt_num,
                                        temp_cascaded_table(current_n).expected_receipt_date,
                                        temp_cascaded_table(current_n).inspection_status_code,
                                        temp_cascaded_table(current_n).p_lpn_id);


       END IF;

       -- Assign shipped quantity to remaining quantity
       x_remaining_quantity     := temp_cascaded_table(current_n).quantity;

       -- used for decrementing cum qty for first record
       x_bkp_qty                 := x_remaining_quantity;
       x_remaining_qty_po_uom    := 0;

       -- Calculate tax_amount_factor for calculating tax_amount for
       -- each cascaded line

       if nvl(temp_cascaded_table(current_n).tax_amount,0) <> 0 THEN
          tax_amount_factor := temp_cascaded_table(current_n).tax_amount/x_remaining_quantity;
        else
          tax_amount_factor := 0;
       end if;

       x_first_trans    := TRUE;
       transaction_ok   := FALSE;


       -- Get the count of the number of records depending on the
       -- the transaction type

       IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN

          IF p_shipment_header_id IS NOT NULL THEN
             IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
                FETCH count_asn_shipments INTO x_record_count;
              ELSE
                FETCH count_asn_shipments_w_po INTO x_record_count;
             END IF;
           ELSE
             FETCH count_shipments INTO x_record_count;
          END IF;

        ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN

          FETCH count_distributions INTO x_record_count;

        ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN

          FETCH count_std_distributions INTO x_record_count;

       END IF;


       LOOP
          -- Fetch the appropriate record
          IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN

             IF p_shipment_header_id IS NOT NULL THEN
                IF temp_cascaded_table(current_n).po_header_id IS NULL THEN
                   FETCH asn_shipments INTO x_ShipmentDistributionRec;
                   -- Check if this is the last record
                   IF (asn_shipments%NOTFOUND) THEN
                      lastrecord := TRUE;
                   END IF;
                   rows_fetched := asn_shipments%rowcount;
                 ELSE
                   FETCH asn_shipments_w_po INTO x_shipmentdistributionrec;
                   -- Check if this is the last record
                   IF (asn_shipments_w_po%NOTFOUND) THEN
                      lastrecord := TRUE;
                   END IF;
                   rows_fetched := asn_shipments_w_po%rowcount;
                END IF;
              ELSE

                FETCH shipments INTO x_ShipmentDistributionRec;
                -- Check if this is the last record
                IF (shipments%NOTFOUND) THEN
                   lastrecord := TRUE;
                END IF;
                rows_fetched := shipments%rowcount;
             END IF;


           ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN

             fetch distributions into x_ShipmentDistributionRec;

             -- Check if this is the last record
             if (distributions%NOTFOUND) THEN
                lastrecord := TRUE;
             END IF;

             rows_fetched := distributions%rowcount;
           ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN

             fetch std_distributions into x_ShipmentDistributionRec;

             -- Check if this is the last record
             if (std_distributions%NOTFOUND) THEN
                lastrecord := TRUE;
             END IF;

             rows_fetched := std_distributions%rowcount;
          END IF;
          if (lastrecord or x_remaining_quantity <= 0) then

             if not x_first_trans  then
                -- x_first_trans has been reset which means some cascade has
                -- happened. Otherwise current_n = 1
                current_n := current_n -1 ;
             end if;

            -- do the tolerance act here

            -- lastrecord...we have run out of rows and
            -- we still have quantity to allocate

             if x_remaining_quantity > 0   then
                if not x_first_trans then
                   -- we had got atleast some rows from our shipments cursor
                   -- we have atleast one row cascaded (not null line_location_id)
                  IF x_cascaded_table(n).transaction_type IN  ('RECEIVE', 'DELIVER') THEN
                     x_qty_rcv_exception_code := temp_cascaded_table(current_n).qty_rcv_exception_code;
                   ELSE
                     x_qty_rcv_exception_code := 'REJECT';
                  END IF;

                  if x_qty_rcv_exception_code IN ('NONE','WARNING')  then
                     temp_cascaded_table(current_n).quantity :=
                       temp_cascaded_table(current_n).quantity +
                       x_remaining_quantity;

                     temp_cascaded_table(current_n).quantity_shipped :=
                       temp_cascaded_table(current_n).quantity_shipped +
                       x_remaining_quantity;

                     temp_cascaded_table(current_n).source_doc_quantity :=
                       temp_cascaded_table(current_n).source_doc_quantity +
                       x_remaining_qty_po_uom;
                     IF temp_cascaded_table(1).primary_unit_of_measure IS
                        NULL THEN
                        temp_cascaded_table(1).primary_unit_of_measure :=
                          x_ShipmentDistributionRec.unit_meas_lookup_code;
                     END IF;
                     temp_cascaded_table(current_n).primary_quantity :=
                       temp_cascaded_table(current_n).primary_quantity +
                       rcv_transactions_interface_sv.convert_into_correct_qty(
                                     x_remaining_quantity,
                                     temp_cascaded_table(1).unit_of_measure,
                                     temp_cascaded_table(1).item_id,
                                     temp_cascaded_table(1).primary_unit_of_measure);

                     temp_cascaded_table(current_n).tax_amount :=
                       round(temp_cascaded_table(current_n).quantity * tax_amount_factor,6);

                     if x_qty_rcv_exception_code = 'WARNING' then
                        -- bug 2787530
                        IF temp_cascaded_table(current_n).error_status = 'W' THEN
                           temp_cascaded_table(current_n).error_message :=
                             'INV_RCV_GEN_TOLERANCE_EXCEED';
                         ELSE
                           temp_cascaded_table(current_n).error_status := 'W';
                           temp_cascaded_table(current_n).error_message :=
                             'INV_RCV_QTY_OVER_TOLERANCE';
                        END IF;
                     end if;

                   elsif x_qty_rcv_exception_code = 'REJECT' then
                     x_cascaded_table(n).error_status := 'E';
                     x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';

                     if temp_cascaded_table.count > 0 then
                        for i in 1..temp_cascaded_table.count loop
                           temp_cascaded_table.delete(i);
                        end loop;
                     end if;
                  end if;

                 ELSE -- for if  remaining_qty > 0 and not x_first_trans

                   x_cascaded_table(n).error_status := 'E';
                   x_cascaded_table(n).error_message := 'INV_RCV_QTY_OVER_TOLERANCE';

                  if rows_fetched = 0 then
                     x_cascaded_table(n).error_message := 'INV_RCV_NO_ROWS';
                   elsif x_first_trans then
                     x_cascaded_table(n).error_message := 'INV_RCV_GEN_TOLERANCE_EXCEED';
                  end if;

                  -- Delete the temp_cascaded_table just to be sure
                  if temp_cascaded_table.count > 0 then
                     for i in 1..temp_cascaded_table.count loop
                        temp_cascaded_table.delete(i);
                     end loop;
                  end if;
               END IF;
             else
               null;

            end if; -- x_remaining_qty > 0
            -- close cursors
            if shipments%isopen then
               close shipments;
            end if;

            if count_shipments%isopen then
               close count_shipments;
            end if;

            IF asn_shipments%isopen THEN
               CLOSE asn_shipments;
            END IF;

            IF count_asn_shipments%isopen THEN
               CLOSE count_asn_shipments;
            END IF;

            IF asn_shipments_w_po%isopen THEN
               CLOSE asn_shipments_w_po;
            END IF;

            IF count_asn_shipments_w_po%isopen THEN
               CLOSE count_asn_shipments_w_po;
            END IF;

            if distributions%isopen then
               close distributions;
            end if;

            if count_distributions%isopen then
               close count_distributions;
            end if;

            IF std_distributions%isopen THEN
               CLOSE std_distributions;
            END IF;

            IF count_std_distributions%isopen THEN
               CLOSE count_std_distributions;
            END IF;

            exit;

         end if; -- if (lastrecord or x_remaining_quantity <= 0)

         -- eliminate the row if it fails the date check
         if (temp_cascaded_table(1).expected_receipt_date is not null) then
            if (x_ShipmentDistributionRec.promised_date is not null) then
               -- bug 2750081
               -- the null days early allowed and days late allowed should
               -- be interpreted as infinite and not zero.
               IF x_ShipmentDistributionRec.days_early_receipt_allowed IS NULL THEN
                  low_range_date := Trunc(temp_cascaded_table(1).expected_receipt_date);
                else
                  low_range_date  := x_ShipmentDistributionRec.promised_date -
                                        nvl(x_ShipmentDistributionRec.days_early_receipt_allowed,0);
               END IF;
               IF x_ShipmentDistributionRec.days_late_receipt_allowed IS NULL THEN
                  high_range_date := Trunc(temp_cascaded_table(1).expected_receipt_date);
                else
                  high_range_date :=  x_ShipmentDistributionRec.promised_date +
                                        nvl(x_ShipmentDistributionRec.days_late_receipt_allowed,0);
               END IF;
             else
               IF x_ShipmentDistributionRec.days_early_receipt_allowed IS NULL THEN
                  low_range_date :=  Trunc(temp_cascaded_table(1).expected_receipt_date);
                else
                  low_range_date  :=  x_sysdate -
                                         nvl(x_ShipmentDistributionRec.days_early_receipt_allowed,0);
               END IF;
               IF x_ShipmentDistributionRec.days_late_receipt_allowed IS NULL THEN
                  high_range_date :=  Trunc(temp_cascaded_table(1).expected_receipt_date);
                else
                  high_range_date :=  x_sysdate +
                                         nvl(x_ShipmentDistributionRec.days_late_receipt_allowed,0);
               END IF;
            end if;
            if (Trunc(temp_cascaded_table(1).expected_receipt_date) >= low_range_date and
                Trunc(temp_cascaded_table(1).expected_receipt_date) <= high_range_date) then
                x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
            end if;
          else
            x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
         end if;
         if x_ShipmentDistributionRec.receipt_days_exception_code is null then
            x_ShipmentDistributionRec.receipt_days_exception_code := 'NONE';
         end if;

         -- if the row does not fall within the date tolerance we just
         -- leave it aside and then take the next row. If the date
         -- tolerance is just set to warning then we continue with this
         -- row. The same applies to the ship to location check too.


         -- Check ship_to_location enforcement
         IF x_shipmentdistributionrec.enforce_ship_to_location_code <> 'NONE' THEN
            IF nvl(temp_cascaded_table(1).ship_to_location_id,x_ShipmentDistributionRec.ship_to_location_id) = x_ShipmentDistributionRec.ship_to_location_id THEN
               x_shipmentdistributionrec.enforce_ship_to_location_code := 'NONE';
            END IF;
         END IF;

         if (x_ShipmentDistributionRec.receipt_days_exception_code IN ('NONE', 'WARNING')) and
           (x_ShipmentDistributionRec.enforce_ship_to_location_code IN ('NONE','WARNING')) THEN
            -- derived by the date tolerance procedure
            -- derived by shipto_enforcement

            insert_into_table := FALSE;
            already_allocated_qty := 0;
            -- Get the available quantity for the shipment or distribution
            -- that is available for allocation by this interface transaction
            IF (x_cascaded_table(n).transaction_type = 'RECEIVE') THEN
               rcv_quantities_s.get_available_quantity(
                                                       'RECEIVE',
                                                       x_ShipmentDistributionRec.line_location_id,
                                                       'VENDOR',
                                                       null,
                                                       null,
                                                       null,
                                                       x_converted_trx_qty,
                                                       x_tolerable_qty,
                                                       x_ShipmentDistributionRec.unit_meas_lookup_code);
               -- If qtys have already been allocated for this po_line_location_id
               -- during a cascade process which has not been written to the db yet,
               -- we need to decrement it from the total available quantity
               -- We traverse the actual pl/sql table and accumulate the quantity by
               -- matching the po_line_location_id

               l_asn_received_qty := 0;
               IF n > 1 THEN    -- We will do this for all rows except the 1st
                  FOR i in 1..(n-1) LOOP
                     IF x_cascaded_table(i).po_line_location_id =
                       x_ShipmentDistributionRec.line_location_id THEN
                        already_allocated_qty := already_allocated_qty +
                          x_cascaded_table(i).source_doc_quantity;
                        IF p_shipment_header_id IS NOT NULL THEN
                           l_asn_received_qty := already_allocated_qty;
                        END IF;
                     END IF;
                  END LOOP;
               END IF;

             ELSIF (x_cascaded_table(n).transaction_type = 'DELIVER') THEN
               rcv_quantities_s.get_available_quantity(
                                                       'DIRECT RECEIPT',
                                                       x_ShipmentDistributionRec.po_distribution_id,
                                                       'VENDOR',
                                                       null,
                                                       null,
                                                       null,
                                                       x_converted_trx_qty,
                                                       x_tolerable_qty,
                                                       x_ShipmentDistributionRec.unit_meas_lookup_code);

               --- Commented out the following line to fix the lolerence checking bug
               ---x_tolerable_qty := x_converted_trx_qty;

               -- If qtys have already been allocated for this po_distribution_id
               -- during
               -- a cascade process which has not been written to the db yet, we need to
               -- decrement it from the total available quantity
               -- We traverse the actual pl/sql table and accumulate the quantity by
               -- matching the
               -- po_distribution_id
               IF n > 1 THEN    -- We will do this for all rows except the 1st
                  FOR i in 1..(n-1) LOOP
                     IF x_cascaded_table(i).po_distribution_id =
                       x_ShipmentDistributionRec.po_distribution_id THEN
                        already_allocated_qty := already_allocated_qty +
                          x_cascaded_table(i).source_doc_quantity;
                     END IF;
                  END LOOP;
               END IF;

             ELSIF (x_cascaded_table(n).transaction_type = 'STD_DELIVER') THEN
               rcv_quantities_s.get_available_quantity(
                                                       'STANDARD DELIVER',
                                                       x_ShipmentDistributionRec.po_distribution_id,
                                                       'VENDOR',
                                                       null,
                                                       x_ShipmentDistributionRec.rcv_transaction_id,
                                                       null,
                                                       x_converted_trx_qty,
                                                       x_tolerable_qty,
                                                       x_ShipmentDistributionRec.unit_meas_lookup_code);
               x_tolerable_qty := x_converted_trx_qty;
               -- If qtys have already been allocated for this po_distribution_id
               -- during
               -- a cascade process which has not been written to the db yet, we need to
               -- decrement it from the total available quantity
               -- We traverse the actual pl/sql table and accumulate the quantity by
               -- matching the
               -- po_distribution_id
               IF n > 1 THEN    -- We will do this for all rows except the 1st
                  FOR i in 1..(n-1) LOOP
                     IF x_cascaded_table(i).po_distribution_id =
                       x_ShipmentDistributionRec.po_distribution_id AND
                       x_cascaded_table(i).parent_transaction_id =
                       x_ShipmentDistributionRec.rcv_transaction_id THEN
                        already_allocated_qty := already_allocated_qty +
                          x_cascaded_table(i).source_doc_quantity;
                     END IF;
                  END LOOP;
               END IF;
            END IF;
            -- if qty has already been allocated then reduce available and tolerable
            -- qty by the allocated amount
            IF nvl(already_allocated_qty,0) > 0 THEN
               x_converted_trx_qty := x_converted_trx_qty - already_allocated_qty;
               x_tolerable_qty     := x_tolerable_qty     - already_allocated_qty;
               IF x_converted_trx_qty < 0 THEN
                  x_converted_trx_qty := 0;
               END IF;
               IF x_tolerable_qty < 0 THEN
                  x_tolerable_qty := 0;
               END IF;
            END IF;

            -- We can use the first record since the item_id and uom are not going to
            -- change
            -- Check that we can convert between ASN-> PO  uom
            --                                   PO -> ASN uom
            --                                   PO -> PRIMARY uom
            -- If any of the conversions fail then we cannot use that record

            x_remaining_qty_po_uom := 0;  -- initialize
            po_asn_uom_qty         := 0;  -- initialize
            po_primary_uom_qty     := 0;  -- initialize

            -- converts from temp_cascaded_table(1).unit_of_measure to
            -- x_ShipmentDistributionRec.unit_meas_lookup_code
            x_remaining_qty_po_uom :=
              rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_quantity,
                                                                     temp_cascaded_table(1).unit_of_measure,
                                                                     temp_cascaded_table(1).item_id,
                                                                     x_ShipmentDistributionRec.unit_meas_lookup_code);

            IF x_remaining_qty_po_uom <> 0 THEN
               -- If last row set available = tolerable - shipped
               -- else                      = available - shipped
               -- Debug: Were a bit troubled here.  How do we know if the shipment
               -- is taken into account here.  I guess if the transaction
               -- has the shipment line id then we should take the quantity from
               -- the shipped quantity.  Need to walk through the different
               -- scenarios
               IF p_shipment_header_id IS NULL THEN
                  l_asn_received_qty := 0;
               END IF;

              if rows_fetched = x_record_count then
                 -- Bug 2496230
                 -- For asn receipts, the shipped quantity also includes
                 -- the current quantity being received. So the converted
                 -- and the tolerable quantity should add the
                 -- l_asn_received_qty as already_allocated_qty has been
                 -- reduced from the converted and tolerable qty above.
                 -- Otherwise it will resuly in double decrementing.
                 x_converted_trx_qty := x_tolerable_qty -
                   nvl(x_ShipmentDistributionRec.quantity_shipped,0) +
                   l_asn_received_qty;
               else
                 x_converted_trx_qty := x_converted_trx_qty -
                   nvl(x_ShipmentDistributionRec.quantity_shipped,0) +
                   l_asn_received_qty;
              end if;

              if x_converted_trx_qty > 0  then
                 if (x_converted_trx_qty < x_remaining_qty_po_uom) then
                    -- compare like uoms

                    x_remaining_qty_po_uom  := x_remaining_qty_po_uom -
                      x_converted_trx_qty;

                    -- change asn uom qty so both qtys are in sync

                    x_remaining_quantity :=
                      rcv_transactions_interface_sv.convert_into_correct_qty(x_remaining_qty_po_uom,
                                  x_ShipmentDistributionRec.unit_meas_lookup_code,
                                  temp_cascaded_table(1).item_id,
                                  temp_cascaded_table(1).unit_of_measure);

                    insert_into_table := TRUE;
                  else
                    x_converted_trx_qty  := x_remaining_qty_po_uom;
                    insert_into_table := TRUE;
                    x_remaining_qty_po_uom := 0;
                    x_remaining_quantity   := 0;

                 end if;

               else  -- no qty for this record but if last row we need it
                 if rows_fetched = x_record_count then
                    -- last row needs to be inserted anyway
                    -- so that the row can be used based on qty tolerance
                    -- checks

                    insert_into_table := TRUE;
                    x_converted_trx_qty := 0;

                  else
                    x_remaining_qty_po_uom := 0;
                    -- we may have a diff uom on the next iteration
                    insert_into_table := FALSE;
                 end if;

              end if;

            end if;   -- remaining_qty_po_uom <> 0

            if insert_into_table then
               if (x_first_trans) then
                  x_first_trans                         := FALSE;
                else
                  temp_cascaded_table(current_n) := temp_cascaded_table(current_n - 1);
               end if;

               -- source_doc_quantity -> in po_uom
               --   primary_quantity    -> in primary_uom
               --   cum_qty             -> in primary_uom
               --   quantity,quantity_shipped -> in ASN uom

               temp_cascaded_table(current_n).source_doc_quantity :=
                 x_converted_trx_qty;   -- in po uom
               temp_cascaded_table(current_n).source_doc_unit_of_measure :=
                 x_ShipmentDistributionRec.unit_meas_lookup_code;

               temp_cascaded_table(current_n).quantity :=
                 rcv_transactions_interface_sv.convert_into_correct_qty(
                               x_converted_trx_qty,
                               x_ShipmentDistributionRec.unit_meas_lookup_code,
                                 temp_cascaded_table(current_n).item_id,
                                 temp_cascaded_table(current_n).unit_of_measure);  -- in asn uom

               temp_cascaded_table(current_n).quantity_shipped  :=
                 temp_cascaded_table(current_n).quantity; -- in asn uom

               -- Primary qty in Primary UOM
               IF temp_cascaded_table(current_n).primary_unit_of_measure IS
                  NULL THEN
                  temp_cascaded_table(current_n).primary_unit_of_measure :=
                    x_ShipmentDistributionRec.unit_meas_lookup_code;
               END IF;
               temp_cascaded_table(current_n).primary_quantity :=
                 rcv_transactions_interface_sv.convert_into_correct_qty(
                               x_converted_trx_qty,
                               x_ShipmentDistributionRec.unit_meas_lookup_code,
                               temp_cascaded_table(current_n).item_id,
                               temp_cascaded_table(current_n).primary_unit_of_measure);

               temp_cascaded_table(current_n).tax_amount :=
                 round(temp_cascaded_table(current_n).quantity * tax_amount_factor,4);

               IF x_shipmentdistributionrec.qty_rcv_exception_code IS NULL THEN
                  temp_cascaded_table(current_n).qty_rcv_exception_code := 'NONE';
                ELSE
                  temp_cascaded_table(current_n).qty_rcv_exception_code :=
                    x_shipmentdistributionrec.qty_rcv_exception_code;
               END IF;

               temp_cascaded_table(current_n).po_line_location_id  :=
                 x_ShipmentDistributionRec.line_location_id;

               IF x_ShipmentDistributionRec.enforce_ship_to_location_code =
                 'WARNING' AND (x_cascaded_table(n).transaction_type IN
                 ('RECEIVE', 'DELIVER')) THEN
                  -- bug 2787530
                  IF temp_cascaded_table(current_n).error_status = 'W' THEN
                     temp_cascaded_table(current_n).error_message :=
                       'INV_RCV_GEN_TOLERANCE_EXCEED';
                   ELSE
                     temp_cascaded_table(current_n).error_status := 'W';
                     temp_cascaded_table(current_n).error_message := 'INV_RCV_WARN_SHIP_TO_LOC';
                  END IF;
               END IF;

               IF x_ShipmentDistributionRec.receipt_days_exception_code =
                 'WARNING' AND (x_cascaded_table(n).transaction_type IN
                 ('RECEIVE', 'DELIVER')) THEN
                  -- bug 2787530
                  IF temp_cascaded_table(current_n).error_status = 'W' THEN
                     temp_cascaded_table(current_n).error_message :=
                       'INV_RCV_GEN_TOLERANCE_EXCEED';
                   ELSE
                     temp_cascaded_table(current_n).error_status := 'W';
                     temp_cascaded_table(current_n).error_message := 'INV_RCV_WARN_RECEIPT_DATE';
                  END IF;
               END IF;
               -- Copy the distribution specific information only if this is a
               -- direct receipt.
               IF (x_cascaded_table(n).transaction_type in ('DELIVER','STD_DELIVER')) THEN

                  temp_cascaded_table(current_n).po_distribution_id  :=
                    x_ShipmentDistributionRec.po_distribution_id;
                  temp_cascaded_table(current_n).parent_transaction_id  :=
                    x_ShipmentDistributionRec.rcv_transaction_id;
               END IF;

               current_n := current_n + 1;

            end if;
         end if;
      end loop;

      -- current_n := current_n - 1;
      -- point to the last row in the record structure before going back

    else
      -- error_status and error_message are set after validate_quantity_shipped

      if x_cascaded_table(n).error_status in ('S','W','F') then
         x_cascaded_table(n).error_status       := 'E';

        if (x_cascaded_table(n).error_message IS NULL) THEN
             x_cascaded_table(n).error_message  := 'RCV_ASN_NO_PO_LINE_LOCATION_ID';
        END IF;
      end if;
      return;
  end if;       -- of (asn quantity_shipped was valid)



  -- OPM change.Bug# 3061052
  -- if original receiving transaction line is split and secondary quantity is specified then
  -- calculate secondary quantity for the split lines.


  ---IF x_cascaded_table(n).secondary_quantity IS NOT NULL THEN
    ---IF temp_cascaded_table.EXISTS(1) AND temp_cascaded_table.COUNT > 1 THEN
    IF temp_cascaded_table.COUNT > 1 THEN
      FOR j IN 1 .. temp_cascaded_table.COUNT LOOP


        OPEN Get_Item_No (temp_cascaded_table(j).item_id, temp_cascaded_table(j).to_organization_id);
        FETCH Get_Item_No INTO l_item_no;
        CLOSE Get_Item_No;

        GML_MOBILE_RECEIPT.Calculate_Secondary_Qty(
                               p_item_no => l_item_no,
                               p_unit_of_measure => temp_cascaded_table(j).unit_of_measure,
                               p_quantity => temp_cascaded_table(j).quantity,
                               p_lot_no   => NULL,
                               p_sublot_no => NULL,
                               p_secondary_unit_of_measure => temp_cascaded_table(j).secondary_unit_of_measure,
                               x_secondary_quantity => temp_cascaded_table(j).secondary_quantity);

      END LOOP;
    END IF;
  ---END IF;


  if shipments%isopen then
     close shipments;
  end if;

  if count_shipments%isopen then
     close count_shipments;
  end if;

  IF asn_shipments%isopen THEN
     CLOSE asn_shipments;
  END IF;

  IF count_asn_shipments%isopen THEN
     CLOSE count_asn_shipments;
  END IF;

  IF asn_shipments_w_po%isopen THEN
     CLOSE asn_shipments_w_po;
  END IF;

  IF count_asn_shipments_w_po%isopen THEN
     CLOSE count_asn_shipments_w_po;
  END IF;

  if distributions%isopen then
     close distributions;
  end if;

  if count_distributions%isopen then
     close count_distributions;
  end if;

  IF std_distributions%isopen THEN
     CLOSE std_distributions;
  END IF;

  IF count_std_distributions%isopen THEN
     CLOSE count_std_distributions;
  END IF;

 exception
    WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_error;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
          CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
          CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
          CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
          CLOSE count_asn_shipments_w_po;
       END IF;

       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
          CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
          CLOSE count_std_distributions;
       END IF;

     WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
          CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
          CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
          CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
          CLOSE count_asn_shipments_w_po;
       END IF;

       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
          CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
          CLOSE count_std_distributions;
       END IF;

    WHEN OTHERS THEN
        ROLLBACK TO rcv_transactions_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , l_api_name
              );
        END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

       if shipments%isopen then
          close shipments;
       end if;

       if count_shipments%isopen then
          close count_shipments;
       end if;

       IF asn_shipments%isopen THEN
          CLOSE asn_shipments;
       END IF;

       IF count_asn_shipments%isopen THEN
          CLOSE count_asn_shipments;
       END IF;

       IF asn_shipments_w_po%isopen THEN
          CLOSE asn_shipments_w_po;
       END IF;

       IF count_asn_shipments_w_po%isopen THEN
          CLOSE count_asn_shipments_w_po;
       END IF;

       if distributions%isopen then
          close distributions;
       end if;

       if count_distributions%isopen then
          close count_distributions;
       end if;

       IF std_distributions%isopen THEN
          CLOSE std_distributions;
       END IF;

       IF count_std_distributions%isopen THEN
          CLOSE count_std_distributions;
       END IF;

       x_cascaded_table(n).error_status := 'E';

 END matching_logic;


END GML_rcv_txn_interface;

/
