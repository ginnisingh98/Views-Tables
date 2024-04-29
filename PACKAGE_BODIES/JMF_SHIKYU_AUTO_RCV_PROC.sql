--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_AUTO_RCV_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_AUTO_RCV_PROC" AS
--$Header: JMFRSKUB.pls 120.25 2006/12/16 01:51:06 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :           JMFRSKUB.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Body file of the Auto-Receive Subcontracting        |
--|                       Components Processor package.                       |
--|                       This processor automatically receives               |
--|                       Subcontracting components for manufacturing         |
--|                       outsourced assemblies into the Manufacturing        |
--|                       Partner organization, after the predefined          |
--|                       in-transit lead time.                               |
--|                                                                           |
--|  FUNCTION/PROCEDURE:  auto_rcv_subcon_comp                                |
--|                       auto_receive_by_inventory                           |
--|                       auto_receive                                        |
--|                       validate_ship_from_to                               |
--|                       validate_receive_date                               |
--|                       validate_rcv_error                                  |
--|                       compare_lines_quantity                              |
--|                       get_in_transit                                      |
--|                       get_customer_id                                     |
--|                       get_supplier_id                                     |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    19-MAY-2005        jizheng   Created.                                  |
--|    05-OCT_2005        jizheng   Delete the parameter 'p_org_id'           |
--|    13-OCT-2005        jizheng   add some log for debug                    |
--|    31-OCT-2005        jizheng   add input parameter po_line_location_id   |
--|                                 when invoke JMF_SHIKYU_RCV_PVT.           |
--|                                 process_rcv_trx in process_rcv_interface  |
--|    22-Nov-2005        jizheng   add a new logic for get shipping method   |
--|                                 from replenishment SO 's header           |
--|    22-Nov-2005        jizheng   get transit date from shipping net work   |
--|    05-Dec-2005        jizheng   add a new method for back ordered line    |
--|    15-Dec-2005        jizheng   remove full table scan for performance    |
--|    18-Jan-2006        jizheng   fix bug 4961147, HQAX1:SCMX1DM2 : AUTO    |
--|                                 RECEIVING INSERT DUPLICATE RECORDS IN RCV |
--|                                 INTERFACE                                 |
--|    07-Feb-2006        jizheng   remove all fnd_file.put_line()            |
--|    14-Mar-2006        SHU       remove all Commented code                 |
--|    10-May-2006        Amy       updated procecure .get_backorder_shipped_ |
--|                                 quantity to fix bug #5212672              |
--|    19-May-2006        THE2      pick up the Sales Order Lines whose status|
--|                                 is 'Closed' to fix #5231430               |
--|    08-Jun-2006        THE2      correct the hard code of operation unit   |
--|    15-JUN-2006        THE2      Add locator_id process logic              |
--|    27-JUN-2006        THE2      Removed the logic for checking duplicated |
--|                                 RCV transactions.                         |
--|    28-JUN-2006        THE2      Met the interface change of procedure     |
--|                              jmf_shikyu_util.Get_Replenish_So_Returned_Qty|
--|                                 and JMF_SHIKYU_RCV_PVT.process_rcv_trx    |
--|    03-AUG-2006        THE2      Modified cursor po_distributions_c to fix |
--|                                 bug #5434983                              |
--|    18-AUG-2006        THE2      Modified cursor po_distributions_c again  |
--|                                 to fix bug #5434983                       |
--|    25-AUG-2006        THE2      Modified cursor po_distributions_c again  |
--|                                 and Changed process_rcv_interface()       |
--|                                 logic to process receiving against each SO|
--|                                 line to fix bug #5434983                  |
--|    06-SEP-2006        THE2      Modified cursor all_inventory_c to fix bug|
--|                                 #5510525                                  |
--|    10-OCT-2006        THE2      Bug fix for 5592230: Changed              |
--|                                 get_supplier_id() from function to        |
--|                                 procedure in order to get the supplier    |
--|                                 site id and pass to the newly added       |
--|                                 parameter p_vendor_site_id of             |
--|                                 JMF_SHIKYU_RCV_PVT.process_rcv_header()   |
--|    09-NOV-2006        THE2      Modified source to fix bug#5647346        |
--|    14-NOV-2006        VCHU      Bug fix for 5659317: This package became  |
--|                                 invalid in xBuild 16, since the changes   |
--|                                 in version 120.22, including changes to   |
--|                                 the call to                               |
--|                                 JMF_SHIKYU_RCV_PVT.process_rcv_header()   |
--|                                 because of a signature change resulted    |
--|                                 from bug fix for 5592230, got overwritten.|
--|    14-DEC-2006        THE2      Modified source to fix bug#5708707        |
--+===========================================================================+

--==========================================================================
--  API NAME:  AUTO_RCV_SUBCON_COMP
--
--  DESCRIPTION:    the procedure is the main procedure of this package, it will be
--                  run in concurrent program.
--
--  PARAMETERS:  In:  p_org_id        OMAC
--                    p_tp_org_id     inventory org

--
--              Out:  errbuf     OUT  NOCOPY       varchar2
--                    retcode    OUT  NOCOPY       VARCHAR2
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================

PROCEDURE 	AUTO_RCV_SUBCON_COMP
( errbuf         OUT NOCOPY	VARCHAR2
, retcode	       OUT NOCOPY	VARCHAR2
, p_tp_org_id    IN         NUMBER
)
IS

l_api_name                         VARCHAR2(30) := 'AUTO_RCV_SUBCON_COMP';
l_inventory_org_id                 NUMBER;
l_shikyu_not_enable                VARCHAR2(500);
l_conc_succ                        BOOLEAN;
l_org_id                           NUMBER := MO_GLOBAL.get_current_org_id;
--find all TP inventory by org_id
CURSOR all_inventory_c IS
SELECT haou.organization_id
  FROM mtl_parameters               mp,
       hr_organization_information  hoi,
       hr_all_organization_units    haou,
       HR_ALL_ORGANIZATION_UNITS_TL haoutl
 WHERE mp.organization_id = hoi.organization_id
   AND haou.organization_id = hoi.organization_id
   AND haou.organization_id = haoutl.organization_id
   AND mp.trading_partner_org_flag = 'Y'
   AND hoi.org_information_context = 'Accounting Information'
   AND hoi.org_information3 = MO_GLOBAL.get_current_org_id
   AND haoutl.LANGUAGE = USERENV('LANG');

BEGIN
  JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'procedure begin'
        );
  JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'p_tp_org_id:'||p_tp_org_id
        );
  JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_org_id :'||l_org_id
        );

  -- get org_id from MOAC
  l_org_id := MO_GLOBAL.get_current_org_id;

  -- is Shikyu is not enable , show a error message.
  IF (FND_PROFILE.VALUE('JMF_SHK_CHARGE_BASED_ENABLED')='Y')-- OR 1=1
  THEN
    IF p_tp_org_id IS NULL
    THEN
      -- begin log
      JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'p_tp_org_id is null. '
            );
      -- end log

      -- select all inventory id, under this OU , find inventory_org_id;
      OPEN all_inventory_c;
      LOOP
        FETCH all_inventory_c
        INTO l_inventory_org_id;
        EXIT WHEN all_inventory_c%NOTFOUND;

        -- begin log
        JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'The inventory org id is : '||l_inventory_org_id
              );
        --end log

        -- begin auto_receive_by_inventory, loop the id
        auto_receive_by_inventory( p_org_id => l_org_id
                                 , p_inventory_org_id  => l_inventory_org_id
                                 );


      END LOOP;
    ELSE /*inverntory is not null*/
      -- use this invertory id
      auto_receive_by_inventory( p_org_id => l_org_id
                               , p_inventory_org_id  => p_tp_org_id
                               );
    END IF; /*inventory id is null*/

  ELSE/*FND_PROFILE.VALUE('JMF_SHIKYU_ENABLED')='Y'*/
    fnd_message.SET_NAME('JMF', 'JMF_SHK_NOT_ENABLE');
    l_shikyu_not_enable := fnd_message.get;

    JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => l_shikyu_not_enable
          );

    l_conc_succ := fnd_concurrent.set_completion_status(status => 'WARNING'
                                                        , message  => l_shikyu_not_enable
                                                       );
  END IF; /*FND_PROFILE.VALUE('JMF_SHIKYU_ENABLED')='Y'*/

  JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'END procedure. '
        );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error : '||SQLCODE||SQLERRM
        );

    l_conc_succ := fnd_concurrent.set_completion_status( status => 'WARNING'
                                                       , message  => SQLCODE||SQLERRM
                                                       );

END 	AUTO_RCV_SUBCON_COMP;

--==========================================================================
--  API NAME:  AUTO_RCVEIVE_by_inventory
--
--  DESCRIPTION:    the procedure is auto receive the SO belong a inventory
--
--  PARAMETERS:  In:  p_org_id
--                    p_inventory_org_id

--              Out:
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE auto_receive_by_inventory
( p_org_id              IN NUMBER
, p_inventory_org_id    IN NUMBER
)
IS

l_api_name                         VARCHAR2(50) := 'auto_receive_by_inventory';
l_header_id                        oe_order_headers_all.header_id%TYPE;
l_customer_id                      NUMBER;
l_customer_site_id                 NUMBER;


CURSOR replenish_so_c(customer_id NUMBER, customer_site VARCHAR2)
IS
  SELECT h.header_id
  FROM oe_order_headers_all h
  WHERE
  h.header_id IN (SELECT DISTINCT r.replenishment_so_header_id FROM jmf_shikyu_replenishments r)
  AND h.org_Id = p_org_id
  AND h.sold_to_org_id = customer_id
  -- AND h.header_id = r.replenishment_so_header_id
  -- AND h.sold_to_site_use_id = customer_site
  AND (h.flow_status_code = 'BOOKED'
  OR h.flow_status_code = 'INVOICED'
  OR h.flow_status_code = 'INVOICE_HOLD'
  OR h.flow_status_code = 'INVOICE_INCOMPLETE'
  OR h.flow_status_code = 'ACTIVE'
  OR h.flow_status_code = 'CUSTOMER_ACCEPTED'
  OR h.flow_status_code = 'INTERNAL_APPROVED'
  OR h.flow_status_code = 'PENDING_CUSTOMER_ACCEPTANCE'
  OR h.flow_status_code = 'PENDING_INTERNAL_APPROVAL'
  OR h.flow_status_code = 'SUBMITTED'
  OR h.flow_status_code = 'WORKING'
  OR h.flow_status_code = 'CLOSED');

BEGIN

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => ' org_id : '||p_org_id||'  inv_org_id:'||p_inventory_org_id
      );

  -- get customer id  and customer site id by org_id
  get_customer_id( p_org_inventory_id => p_inventory_org_id
                 , x_customer_id  => l_customer_id
                 , x_customer_site_id => l_customer_site_id
                 );


  -- debug log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'customer_site_id : '||l_customer_site_id
      );

  -- find regular replenishment SO's header_id, loop by header_id, do auto receive
  OPEN replenish_so_c(l_customer_id, l_customer_site_id);
  LOOP
    FETCH replenish_so_c INTO l_header_id;
    EXIT WHEN replenish_so_c%NOTFOUND;
    -- begin log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'The SO header id is :'||l_header_id
        );
    --end log

    -- do_auto_receive() procedure
    auto_receive(p_inventory_org_id  => p_inventory_org_id
                , p_header_id => l_header_id);   --l_header_id

  END LOOP;
  CLOSE replenish_so_c;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure.'
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error'||SQLCODE||SQLERRM
        );
    RAISE;

END auto_receive_by_inventory;

--==========================================================================
--  API NAME:  AUTO_RECEIVE
--
--  DESCRIPTION:    the procedure is auto receive the so lines belong  one SO
--
--  PARAMETERS:  In:  p_header_id     replenishment SO 's header_id
--                    p_inventory_org_id            inventory org id

--              Out:
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE auto_receive
( p_inventory_org_id    IN NUMBER
, p_header_id           IN NUMBER
)
IS

l_api_name                  VARCHAR2(20):= 'auto_receive';
l_line_id                   oe_order_lines_all.line_id%TYPE;

l_auto_receive_quantity     oe_order_lines_all.shipped_quantity%TYPE;

l_date_flag                 NUMBER;
l_ship_flag                 NUMBER;

l_po_header_id              jmf_shikyu_replenishments.replenishment_po_header_id%TYPE;
l_po_line_id                jmf_shikyu_replenishments.replenishment_po_line_id%TYPE;
l_po_shipment_id            jmf_shikyu_replenishments.replenishment_po_shipment_id%TYPE;

l_ship_date                 oe_order_lines.ACTUAL_SHIPMENT_DATE%TYPE;
l_ship_from_org_id          oe_order_headers_all.ship_from_org_id%TYPE;
l_ship_to_org_id            oe_order_headers_all.ship_to_org_id%TYPE;
l_ship_method               oe_order_headers_all.shipping_method_code%TYPE;
l_sold_to_org_id            oe_order_lines_all.sold_to_org_id%TYPE;

l_primary_uom_code          VARCHAR2(30);

l_lines_id                  line_id_tbl := line_id_tbl();

CURSOR replenish_so_line_c IS
SELECT r.replenishment_so_line_id
FROM jmf_shikyu_replenishments r
WHERE r.replenishment_so_header_id = p_header_id;

BEGIN

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_header_id :'||p_header_id
      );

    -- init l_lines_id
  l_lines_id := line_id_tbl();
  OPEN replenish_so_line_c;
  LOOP
    FETCH replenish_so_line_c INTO l_line_id;
    EXIT WHEN replenish_so_line_c%NOTFOUND;

    -- begin log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_line_id'||l_line_id
        );
    -- end log

    BEGIN
      --select line_ship_from_org_id  by  line_id
      SELECT
             r.replenishment_po_header_id
             , r.replenishment_po_line_id
             , r.replenishment_po_shipment_id
      INTO
            l_po_header_id
           , l_po_line_id
           , l_po_shipment_id
      FROM jmf_shikyu_replenishments r
      WHERE r.replenishment_so_line_id = l_line_id;
    EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data find when select PO info by so_line_id in jmf_shikyu_replenishments'
            );
    END;

    -- begin debug log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_po_header_id'||l_po_header_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_po_line_id'||l_po_line_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_po_shipment_id'||l_po_shipment_id
        );
    -- end debug log

    BEGIN
      --select actual_shipment_date by line id
      SELECT l.actual_shipment_date  --actual_shipment_date
             , l.ship_from_org_id
             , l.ship_to_org_id
             , l.sold_to_org_id
             , l.shipping_method_code
      INTO  l_ship_date
            , l_ship_from_org_id
            , l_ship_to_org_id
            , l_sold_to_org_id
            , l_ship_method
      FROM oe_order_lines_all l
      WHERE l.line_id = l_line_id;

      EXCEPTION
        WHEN no_data_found THEN
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'no data find when select ship org id or other info by line_id in oe_order_lines_all'
              );
    END;

    --get ship method from SO header
    IF l_ship_method IS NULL
    THEN
      SELECT
        shipping_method_code
      INTO
        l_ship_method
      FROM oe_order_headers_all
      WHERE header_id = p_header_id;

    END IF;

    -- begin debug log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_ship_date'||l_ship_date
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_ship_from_org_id'||l_ship_from_org_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_ship_to_org_id'||l_ship_to_org_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_ship_method'||l_ship_method
        );
    -- end debug log

    validate_ship_from_to(p_line_id                  => l_line_id
                         , p_header_id               => p_header_id
                         , p_line_ship_from_org_id   => l_ship_from_org_id
                         , p_line_ship_to_org_id     => l_ship_to_org_id
                         , x_ship_flag               => l_ship_flag
                         );


    validate_receive_date(p_line_ship_from_org_id   => l_ship_from_org_id
                         , p_line_ship_to_org_id     => l_sold_to_org_id   -- because the sold_to_org_id is the customer id
                         , p_actual_shipment_date    => l_ship_date
                         , p_ship_method             => l_ship_method
                         , x_date_flag               => l_date_flag
                         );


    -- begin log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_ship_flag is '|| l_ship_flag||'  l_date_flag is '||l_date_flag
        );
    --end log

    IF l_ship_flag=1 AND l_date_flag=1
    THEN
      --add line id to l_lines_id
      l_lines_id.EXTEND;
      l_lines_id(l_lines_id.COUNT) := l_line_id;
    ELSE  /*l_ship_flag=0 OR l_date_flag=0*/
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'complete'
          );
    END IF;  /*end if l_ship_flag=1 AND l_date_flag=1*/

  END LOOP; /* end loop replenish_so_line_c*/
  CLOSE replenish_so_line_c;

  -- log the line count
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'lines count '|| l_lines_id.COUNT
      );

  IF l_lines_id.COUNT > 0
  THEN
    compare_lines_quantity(p_so_header_id         => p_header_id
                           , p_inventory_org_id   => p_inventory_org_id
                           , p_lines_id           => l_lines_id
                           , p_po_header_id       => l_po_header_id
                           , p_po_line_id         => l_po_line_id
                           , p_po_shipment_id     => l_po_shipment_id
                           , p_ship_from_org_id   => l_ship_from_org_id
                           , x_receive_quantity   => l_auto_receive_quantity
                           , x_uom_code           => l_primary_uom_code
                           );

    -- log the quantity should be auto receive
    -- begin log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'p_header_id'||p_header_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'p_inventory_org_id'||p_inventory_org_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_po_header_id'||l_po_header_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_po_line_id'||l_po_line_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'the quantity should be auto receive is '|| l_auto_receive_quantity
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'the primary uom code is : '|| l_primary_uom_code
        );
    -- end log

    IF l_auto_receive_quantity > 0
    THEN
        process_rcv_interface(p_inventory_org_id      => p_inventory_org_id
                              , p_lines_id            => l_lines_id
                              , p_po_header_id        => l_po_header_id
                              , p_po_line_id          => l_po_line_id
                              , p_po_shipment_id      => l_po_shipment_id
                              , p_ship_from_org_id    => l_ship_from_org_id
                              , p_ship_to_org_id      => l_ship_to_org_id
                              , p_receive_quantity    => l_auto_receive_quantity
                              , p_primary_uom_code    => l_primary_uom_code
                              );

    ELSE -- /*l_auto_receive_quantity <= 0*/
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'the quantity should be auto receive is <= 0'
          );
    END IF; /*l_auto_receive_quantity > 0 */


  END IF; /*end if l_lines_id.count > 0 */

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error '||SQLCODE||SQLERRM
        );
    RAISE;


END auto_receive;

--==========================================================================
--  API NAME:  validate_ship_from_to
--
--  DESCRIPTION:    the procedure is validate the ship from and ship to in the
--                  replenishment SO line and SO header, if it is same , retrun  1
--                  ElSE return 0;
--                  the warehouse at line level is same as warehouse at header level
--                  the ship-to org is same as MP organiztion
--
--  PARAMETERS:  In:  p_header_id     replenishment SO 's header_id
--                    p_line_id       replenishment SO 's line_id
--                    p_line_ship_from_org_id
--                    p_line_ship_to_org_id

--              Out:  x_ship_flag     validate flag of ship from to
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE validate_ship_from_to
( p_line_id                  IN         NUMBER
, p_header_id                IN         NUMBER
, p_line_ship_from_org_id    IN         NUMBER
, p_line_ship_to_org_id      IN         NUMBER
, x_ship_flag                OUT NOCOPY NUMBER
)
IS
l_api_name  VARCHAR2(30) := 'validate_ship_from_to';

l_ship_from_org_id_h        oe_order_headers_all.ship_from_org_id%TYPE;
l_ship_to_org_id_h          oe_order_headers_all.ship_to_org_id%TYPE;

l_ship_flag                 NUMBER;

BEGIN
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );
  -- init l_ship_flag
  l_ship_flag := 0;
  BEGIN
    SELECT h.ship_from_org_id
         , h.ship_to_org_id
    INTO l_ship_from_org_id_h
         , l_ship_to_org_id_h
    FROM oe_order_headers_all h
    WHERE h.header_id = p_header_id;
  EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'can find ship from, or ship to by SO_header_id'
            );
      RAISE;
  END;

  IF p_line_ship_from_org_id = l_ship_from_org_id_h AND p_line_ship_to_org_id = l_ship_to_org_id_h
  THEN
    l_ship_flag := 1;
  END IF;

  x_ship_flag := l_ship_flag;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error, and ship flag is 0 '||SQLCODE||SQLERRM
        );
    x_ship_flag := 0;

END validate_ship_from_to;

--==========================================================================
--  API NAME:  validate_receive_date
--
--  DESCRIPTION:    the procedure is validate the receive date of SO line receive
--                  date and current date, if receive date < = current date then return
--                  1 else , return 0
--
--  PARAMETERS:  In:
--                    p_line_id                       in   number
--                    p_line_ship_from_org_id         IN   NUMBER
--                    p_line_ship_to_org_id           IN   Date
--                    p_actual_shipment_date          IN   Varchar2
--                    p_ship_method

--              Out:  x_date_flag     if receive date <= current date return 1 ,
--                                    else return 0
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE validate_receive_date
( p_line_ship_from_org_id   IN         NUMBER
, p_line_ship_to_org_id     IN         NUMBER
, p_actual_shipment_date    IN         DATE
, p_ship_method             IN         VARCHAR2
, x_date_flag               OUT NOCOPY NUMBER
)
IS

l_api_name                VARCHAR2(30) := 'validate_receive_date';
l_in_transit              MTL_INTERORG_SHIP_METHODS.INTRANSIT_TIME%TYPE;
l_intransit_type          MTL_SHIPPING_NETWORK_VIEW.INTRANSIT_TYPE%TYPE;
l_receive_date            DATE;

l_date_flag               NUMBER;
l_tp_org_id               NUMBER;
l_customer_information    HR_ORGANIZATION_INFORMATION.Org_Information1%TYPE;

BEGIN
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );
  -- init l_date_flag
  l_date_flag := 0;

  -- get org id of TP org.
  l_customer_information := p_line_ship_to_org_id;
  BEGIN
    SELECT hoi.Organization_Id
    INTO  l_tp_org_id
    FROM  HR_ORGANIZATION_INFORMATION hoi
    WHERE  hoi.org_information1 = l_customer_information;

  EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data found , when find tp org id by ship_to_org_id'
            );
      RAISE;
      WHEN too_many_rows THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'find too many ship from or ship to by p_header_id'
            );
      RAISE;
  END;

  -- get in transit type from shiping network
  BEGIN

  SELECT ship_net.INTRANSIT_TYPE -- 1 is direct and 2 is instrant
  INTO l_intransit_type
  FROM MTL_SHIPPING_NETWORK_VIEW ship_net
  WHERE ship_net.FROM_ORGANIZATION_ID = p_line_ship_from_org_id
  AND ship_net.TO_ORGANIZATION_ID = l_tp_org_id;
  EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data found in-transit type'
            );
        RAISE;
      WHEN too_many_rows THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'too many rows when find in-transit type'
            );
        RAISE;
  END;

  -- get in_transit data
  IF l_intransit_type =1
  THEN
    l_in_transit := 0;
  ELSIF l_intransit_type = 2
  THEN
    get_in_transit(p_ship_from_org_id => p_line_ship_from_org_id
                 , p_ship_to_org_id => l_tp_org_id
                 , p_ship_method    => p_ship_method
                 , x_in_transit     => l_in_transit);

  ELSE  -- the intransit_type is not 1 and 2 (direct and intransit)
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Error: intransit type is not direct nor intransit'
        );
  END IF; /*l_intransit_type = 1 */

  --  begin debug log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'l_in_transit'||l_in_transit
      );
  -- end debug log

  l_receive_date := p_actual_shipment_date + l_in_transit;

  IF l_receive_date <= SYSDATE
  THEN
    l_date_flag := 1;
  END IF; /*l_receive_date <= SYSDATE */

  x_date_flag := l_date_flag;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );
EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error and date flag is 0 '||SQLCODE||SQLERRM
        );
    x_date_flag := 0;

END validate_receive_date;

--==========================================================================
--  API NAME:  validate_rcv_error
--
--  DESCRIPTION:    this procedure avoid process the error line again. if rcv flag
--                  return 1 this line is no error , else if return 0 is error.
--
--  PARAMETERS:  In:
--                    p_po_line_id    replenishment PO 's line_id

--              Out:  x_rcv_flag      if this po line is rcv error , return  0
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================

--==========================================================================
--  API NAME:  compare_lines_quantity
--
--  DESCRIPTION:    the procedure is compare the quantity of SO line and PO shipment
--                  when one SO header has more than one SO lines, return the different of this
--                  two quantity
--
--  PARAMETERS:  In: p_inventory_org_id      IN    NUMBER
--                   p_lines_id              IN    line_id_tbl
--                   p_po_header_id          IN    NUMBER
--                   p_po_line_id            IN    NUMBER
--                   p_po_shipment_id        IN    NUMBER
--
--              Out:  x_receive_quantity  the different of SO quantity and PO quantity
--                    x_uom_code              OUT NOCOPY VARCHAR2
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE compare_lines_quantity
( p_so_header_id        IN          NUMBER
, p_inventory_org_id    IN          NUMBER
, p_lines_id            IN          line_id_tbl
, p_po_header_id        IN          NUMBER
, p_po_line_id          IN          NUMBER
, p_po_shipment_id      IN          NUMBER
, p_ship_from_org_id    IN          NUMBER
, x_receive_quantity    OUT NOCOPY  NUMBER
, x_uom_code            OUT NOCOPY  VARCHAR2
)
IS

l_api_name                VARCHAR2(40) := 'compare_lines_quantity';
l_shipped_quantity        oe_order_lines_all.shipped_quantity%TYPE;
l_line_quantity           oe_order_lines_all.shipped_quantity%TYPE;
l_returned_quantity       NUMBER;
l_received_quantity       NUMBER;

l_primary_uom_code        mtl_units_of_measure_tl.uom_code%TYPE;

l_prm_uom_quantity_so     NUMBER;
l_prm_uom_quantity_po     NUMBER;

l_po_uom                  mtl_units_of_measure_tl.unit_of_measure%TYPE;
l_po_uom_code             mtl_units_of_measure_tl.uom_code%TYPE;

l_item_id                 oe_order_lines_all.inventory_item_id%TYPE;
l_uom_code                oe_order_lines_all.shipping_quantity_uom%TYPE;

l_backorder_shipped_quantity  NUMBER;

l_index                   NUMBER;

BEGIN

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );

  -- init x_receive_quantity
  x_receive_quantity := 0;
  l_line_quantity := 0;
  l_shipped_quantity :=0;
  l_received_quantity := 0;
  l_returned_quantity := 0;
  l_backorder_shipped_quantity := 0;

  l_index := p_lines_id.FIRST;
  WHILE l_index IS NOT NULL
  LOOP
    -- init variable
    l_line_quantity := 0;
    l_prm_uom_quantity_so := 0;
    l_returned_quantity := 0;
    BEGIN
      SELECT NVL(l.shipped_quantity,0)
             , l.inventory_item_id
             --, l.shipping_quantity_uom
             , l.order_quantity_uom      -- Bug#5647346: changed to order_quantity_uom from shipping_quantity_uom since the shipped_quantity is order_quantity_uom
      INTO l_line_quantity
           , l_item_id
           , l_uom_code
      FROM oe_order_lines_all l
      WHERE l.line_id = p_lines_id(l_index);

      EXCEPTION
        WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data found when find shipped_quantity and item_id'
            );
        RAISE;
        WHEN too_many_rows THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'too many rows when find shipped_quantity and item_id'
            );
        RAISE;
    END;

    --convert UOM
    --get primary uom code
    l_primary_uom_code := Jmf_Shikyu_Rpt_Util.get_item_primary_uom_code
                          ( p_org_id  => p_inventory_org_id
                          , p_item_id => l_item_id
                          , p_current_uom_code => l_uom_code
                          );

    x_uom_code := l_primary_uom_code;

    l_prm_uom_quantity_so := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                             ( p_org_id                => p_inventory_org_id
                              , p_item_id              => l_item_id
                              , p_current_uom_code     => l_uom_code
                              , p_current_qty          => l_line_quantity
                              );

    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_prm_uom_quantity_so :' || l_prm_uom_quantity_so
        );

    --get back order line shipped quantity
    get_backorder_shipped_quantity(p_so_header_id                => p_so_header_id
                                  ,p_so_line_id                  => p_lines_id(l_index)
                                  ,p_inventory_org_id            => p_inventory_org_id
                                  ,x_backorder_shipped_quantity  => l_backorder_shipped_quantity
                                  );

    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_backorder_shipped_quantity :' || l_backorder_shipped_quantity
        );

    -- this should be open if this porcedure is avilable.

    -- sub the return quantity (the returned quantity is in primary UOM)

    l_returned_quantity := jmf_shikyu_util.Get_Replenish_So_Returned_Qty(p_replenishment_so_line_id => p_lines_id(l_index));

    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'l_returned_quantity :' || l_returned_quantity
        );

    --l_returned_quantity := 0;   -- this statements is replace the procedure above.
    l_line_quantity := l_prm_uom_quantity_so + l_backorder_shipped_quantity - l_returned_quantity;
    l_shipped_quantity := l_shipped_quantity + l_line_quantity;

    l_index := p_lines_id.NEXT(l_index);
  END LOOP; -- l_index is not null

  BEGIN
    SELECT locate.quantity_received
           , locate.unit_meas_lookup_code
    INTO l_received_quantity
         , l_po_uom
    FROM po_line_locations_all locate
    WHERE locate.line_location_id = p_po_shipment_id;

  EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data found , when find quantity_received by line_location_id'
            );
      RAISE;
  END;

  BEGIN
    SELECT DISTINCT uom.uom_code
    INTO l_po_uom_code
    FROM mtl_units_of_measure_tl  uom
    WHERE uom.unit_of_measure = l_po_uom
    AND uom.LANGUAGE = userenv('LANG');

  EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data found , when find uom_code by unit_of_measure'
            );
      RAISE;
  END;

  -- convery the received quantity to Primary UOM
  l_prm_uom_quantity_po := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                           ( p_org_id             => p_inventory_org_id
                           , p_item_id            => l_item_id
                           , p_current_uom_code   => l_po_uom_code
                           , p_current_qty        => l_received_quantity
                           );

  -- compare
  x_receive_quantity := l_shipped_quantity - l_prm_uom_quantity_po;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );
EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error and x_receive_quantity is 0 '||SQLCODE||SQLERRM
        );
    x_receive_quantity := 0;
END compare_lines_quantity;

--==========================================================================
--  API NAME:  get_backorder_shipped_quantity
--
--  DESCRIPTION:    the procedure can get the back orderer quantity which is shipped
--                  by the split from line id
--
--  PARAMETERS:  In: p_inventory_org_id      IN    NUMBER
--                   p_line_id               IN    NUMBER
--                   p_so_header_id          IN    NUMBER
--
--              Out:  x_backorder_shipped_quantity  OUT NUMBER
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--  CHANGE HISTORY:	10-May-06	Amy   updated procecure .get_backorder_shipped_quantity to fix bug #5212672
--===========================================================================
PROCEDURE get_backorder_shipped_quantity
(p_so_header_id                IN           NUMBER
,p_so_line_id                  IN           NUMBER
,p_inventory_org_id            IN           NUMBER
,x_backorder_shipped_quantity  OUT  NOCOPY  NUMBER
)
IS
l_api_name                 VARCHAR2(100) := 'get_backorder_shipped_quantity';
l_shipped_quantity         NUMBER;
l_shipped_quantity_amount  NUMBER;
l_inventory_item_id        NUMBER;
l_uom                      mtl_units_of_measure_tl.uom_code%TYPE;
l_line_count               NUMBER;
l_prm_uom_quantity_so      NUMBER;

CURSOR back_order_line_c (p_so_header_id  IN  NUMBER,p_line_id  IN  NUMBER)
IS
SELECT NVL(l.shipped_quantity,0)
       , l.inventory_item_id
       --, l.shipping_quantity_uom
       , l.order_quantity_uom      -- Bug#5647346: changed to order_quantity_uom from shipping_quantity_uom since the shipped_quantity is order_quantity_uom

FROM oe_order_lines_all l
WHERE l.split_from_line_id = p_line_id
AND  l.header_id = p_so_header_id;
BEGIN

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );

  -- init the return quantity
  x_backorder_shipped_quantity := 0;
  l_shipped_quantity := 0;
  l_shipped_quantity_amount := 0;
  --get the line count of replenishment so
  SELECT
    COUNT(*)
  INTO
    l_line_count
  FROM
    oe_order_lines_all
  WHERE header_id  = p_so_header_id;

  IF l_line_count < 2
  THEN
    x_backorder_shipped_quantity := 0;
  ELSE
    -- begin log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'back order line exist in '||p_so_header_id
        );
    -- end log
    OPEN back_order_line_c(p_so_header_id,p_so_line_id);
    LOOP
      FETCH back_order_line_c INTO l_shipped_quantity, l_inventory_item_id, l_uom;
      EXIT WHEN back_order_line_c%NOTFOUND;

      --get the shipped quantity in primary quantity
      l_prm_uom_quantity_so := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                               ( p_org_id                => p_inventory_org_id
                                , p_item_id              => l_inventory_item_id
                                , p_current_uom_code     => l_uom
                                , p_current_qty          => l_shipped_quantity
                                );
      l_shipped_quantity_amount := l_shipped_quantity_amount + l_prm_uom_quantity_so;


    END LOOP;

    x_backorder_shipped_quantity := l_shipped_quantity_amount;
  END IF;

  -- begin log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'back order line shipped quantity is  '||l_shipped_quantity_amount
      );
  -- end log

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error and x_receive_quantity is 0 '||SQLCODE||SQLERRM
        );
    x_backorder_shipped_quantity :=0;

END get_backorder_shipped_quantity;

--==========================================================================
--  API NAME:  get_in_transit
--
--  DESCRIPTION:    the procedure is get the in-transit time by shipping network
--
--  PARAMETERS:  In:  p_ship_from_org_id     the ship from org in shipping network
--                    p_ship_to_org_id       the ship to org in shipping network
--                    p_ship_method
--              Out:  x_in_transit           in-transit value
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE get_in_transit
( p_ship_from_org_id    IN         NUMBER
, p_ship_to_org_id      IN         NUMBER
, p_ship_method         IN         VARCHAR2
, x_in_transit          OUT NOCOPY NUMBER
)
IS
l_api_name           VARCHAR2(30):= 'get_in_transit';
l_intransit          MTL_INTERORG_SHIP_METHODS.INTRANSIT_TIME%TYPE;
l_default_flag       NUMBER;
l_ship_method        MTL_INTERORG_SHIP_METHODS.ship_method%TYPE;

CURSOR ship_method_c IS
SELECT
ship_methods.Intransit_Time
, ship_methods.default_flag
, ship_methods.ship_method
FROM
MTL_INTERORG_SHIP_METHODS ship_methods
WHERE
ship_methods.from_organization_id = p_ship_from_org_id
AND ship_methods.To_Organization_Id = p_ship_to_org_id
AND ship_methods.default_flag = 1;

BEGIN
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );

  l_intransit := 0;
  OPEN ship_method_c;
  LOOP
  FETCH ship_method_c INTO l_intransit, l_default_flag, l_ship_method;
  EXIT WHEN ship_method_c%NOTFOUND;
  IF l_default_flag = 1
  THEN
    x_in_transit := l_intransit;
    EXIT;
  END IF;

  END LOOP;
  CLOSE ship_method_c;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

END get_in_transit;

--==========================================================================
--  API NAME:  get_customer_id
--
--  DESCRIPTION: To get customer id and customer site id by p_org_id
--               in org define module
--
--  PARAMETERS:  In:  p_org_inventory_id      IN     NUMBER

--              Out:  x_customer_id           OUT NOCOPY   NUMBER
--                    x_customer_site_id      OUT NOCOPY   NUMBER
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--===========================================================================
PROCEDURE get_customer_id
( p_org_inventory_id    IN          NUMBER
, x_customer_id         OUT  NOCOPY NUMBER
, x_customer_site_id    OUT  NOCOPY NUMBER
)
IS
  l_api_name             VARCHAR2(30)  :=  'get_customer_id';
  l_customer_id          NUMBER;
  l_customer_site_id     NUMBER;
BEGIN
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );

  BEGIN
    SELECT
      hoi.org_information1 Customer_id
      ,hoi.org_information2 Customer_site_id
      --,hoi.org_information3 Supplier_id
      --,hoi.org_information4 Supplier_site_id
    INTO
      l_customer_id
      , l_customer_site_id
    FROM
      HR_ORGANIZATION_INFORMATION hoi
    WHERE hoi.org_information_context = 'Customer/Supplier Association'
    AND hoi.organization_id = p_org_inventory_id;
    EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data find customer name, customer site name'
            );
        RAISE;
      WHEN too_many_rows THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'too many rows when find customer name, customer site name'
            );
        RAISE;
  END;

  x_customer_id := l_customer_id;
  x_customer_site_id := l_customer_site_id;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error'||SQLCODE||SQLERRM
        );
    x_customer_id := NULL;
    x_customer_site_id := NULL;

END get_customer_id;

--==========================================================================
--  API NAME:  get_supplier_id
--
--  DESCRIPTION:    the procedure is get supplier name by p_org_id in org define module
--
--  PARAMETERS:  In:  p_sold_from_org_id

--             Return : supplier_id
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--                  14-Nov-06   Vincent.Chu Bug 5592230/5659317: Changed type
--                                          from Function to Procedure
--===========================================================================
PROCEDURE  get_supplier_id
( p_sold_from_org_id    IN NUMBER
, x_supplier_id         OUT  NOCOPY NUMBER
, x_supplier_site_id    OUT  NOCOPY NUMBER
)
IS
  l_api_name   VARCHAR2(30)  :=  'get_supplier_name';
  l_supplier_id       po_vendors.vendor_id%TYPE;
  l_supplier_site_id  po_vendor_sites_all.vendor_site_id%TYPE;
  l_supplier_name     po_vendors.vendor_name%TYPE;

BEGIN

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );

  BEGIN
    SELECT
      hoi.org_information3 Supplier_id
    , hoi.org_information4 Supplier_site_id
    INTO
      l_supplier_id
    , l_supplier_site_id
    FROM
      HR_ORGANIZATION_INFORMATION hoi
    WHERE hoi.org_information_context = 'Customer/Supplier Association'
    AND hoi.organization_id = p_sold_from_org_id;
    EXCEPTION
      WHEN no_data_found THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'no data find supplier id'
            );
        RAISE;
      WHEN too_many_rows THEN
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'too many rows when find supplier id'
            );
        RAISE;
  END;

  x_supplier_id := l_supplier_id;
  x_supplier_site_id := l_supplier_site_id;

  BEGIN
    SELECT po_vendors.vendor_name
    INTO l_supplier_name
    FROM po_vendors
    WHERE po_vendors.vendor_id = l_supplier_id;
  EXCEPTION
    WHEN no_data_found THEN
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'no data find supplier name'
          );
      RAISE;
    WHEN too_many_rows THEN
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'too many rows when find supplier name'
          );
      RAISE;

  END;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error '||SQLCODE||SQLERRM
        );

    x_supplier_id := NULL;
    x_supplier_site_id := NULL;

END get_supplier_id;

--==========================================================================
--  API NAME:  process_rcv_interface
--
--  DESCRIPTION: To insert value to rcv_header_interface and
--               rcv_transcation_interface
--
--  PARAMETERS:  In:  p_inventory_org_id          Manufacturing Partner Organization id
--                    p_line_id                   replenishment SO line id
--                    p_po_header_id              replenishment PO header id
--                    p_po_line_id                replenishment PO line id
--                    p_po_shipment_id            replenishment PO shipment id
--                    p_ship_from_org_id          ship from org id
--                    p_ship_to_org_id            ship to org id
--                    p_receive_quantity          the quantity which should auto receive
--                    p_primary_uom_code          primary_uom_code
--
--  DESIGN REFERENCES:	SHIKYU_AutoReceiving_TD_New.doc
--
--  CHANGE HISTORY:	18-May-05	Jim.Zheng   Created.
--                  14-Nov-06   Vincent.Chu Bug 5592230/5659317: Changed the
--                                          calls to get_supplier_id and
--                                          JMF_SHIKYU_RCV_PVT.process_rcv_header
--                                          in order to pass in the supplier
--                                          site id for the RCV transaction.
--===========================================================================
PROCEDURE process_rcv_interface
( p_inventory_org_id    IN NUMBER
--, p_line_id             IN NUMBER
, p_lines_id            IN line_id_tbl
, p_po_header_id        IN NUMBER
, p_po_line_id          IN NUMBER
, p_po_shipment_id      IN NUMBER
, p_ship_from_org_id    IN NUMBER
, p_ship_to_org_id      IN NUMBER
, p_receive_quantity    IN NUMBER
, p_primary_uom_code    IN VARCHAR2
)
IS

l_api_name                       VARCHAR2(50) := 'process_rcv_interface';
l_routing_header_id              PO_LINE_LOCATIONS_ALL.Receiving_Routing_Id%TYPE;
l_dest_subinventory              rcv_transactions_interface.subinventory%TYPE;
l_dest_locator_id                wip_parameters.default_pull_supply_locator_id%TYPE;
l_default_locator_id             wip_parameters.default_pull_supply_locator_id%TYPE;
l_locator_type                   MTL_SECONDARY_INVENTORIES.locator_type%TYPE;
l_project_id                     OE_ORDER_LINES_ALL.project_id%TYPE;
l_task_id                        OE_ORDER_LINES_ALL.task_id%TYPE;

l_group_id                       rcv_headers_interface.group_id%TYPE;
l_return_number                  NUMBER;
--l_unit_of_measure                mtl_units_of_measure_tl.unit_of_measure%TYPE;

l_rcv_header_id                  NUMBER;
l_transaction_type               VARCHAR2(20) := 'RECEIVE';

l_index                          NUMBER;

-- Bug 5592230
l_supplier_id                    NUMBER;
l_supplier_site_id               NUMBER;

CURSOR po_distributions_c(p_location_id IN NUMBER, p_line_id IN NUMBER) IS
SELECT d.po_distribution_id,
       d.distribution_num,
       d.quantity_ordered,
       d.quantity_delivered,
       l.unit_meas_lookup_code,
       oola.shipped_quantity,
       uom.unit_of_measure,
       oola.inventory_item_id
  FROM po_distributions_all      d,
       po_line_locations_all     l,
       MTL_UNITS_OF_MEASURE      uom,
       jmf_shikyu_replenishments jsr,
       oe_order_lines_all        oola
 WHERE d.line_location_id = p_location_id
   AND d.LINE_LOCATION_ID = jsr.replenishment_PO_shipment_ID
   and oola.line_id = jsr.replenishment_so_line_id
   and nvl(oola.shipped_quantity, 0) > 0
   AND l.line_location_id = d.line_location_id
   AND oola.order_quantity_uom = uom.uom_code(+)
   and oola.line_id = p_line_id
   AND not exists (select 1
          from rcv_transactions rt
         where REPLENISH_ORDER_LINE_ID = oola.line_id)
   AND not exists (select 1
          from rcv_transactions_interface rti
         where REPLENISH_ORDER_LINE_ID = oola.line_id
           and TRANSACTION_STATUS_CODE <> 'ERROR'
           AND PROCESSING_STATUS_CODE <> 'ERROR')
ORDER BY d.distribution_num; --If multiple Replenishment PO Distributions exist then handle in their order.

l_po_distribution_id   po_distributions_all.po_distribution_id%TYPE;
l_distribution_num     po_distributions_all.distribution_num%TYPE;
l_quantity_ordered     po_distributions_all.quantity_ordered%TYPE;
l_quantity_delivered   po_distributions_all.quantity_delivered%TYPE;
--l_receive_quantity     NUMBER;
l_insert_quantity      NUMBER;
l_allocated_quantity   NUMBER;

-- Bug#5647346
l_prm_uom_quantity_ordered     po_distributions_all.quantity_ordered%TYPE;
l_prm_uom_quantity_delivered   po_distributions_all.quantity_delivered%TYPE;
l_prm_uom_allocated_quantity   NUMBER;
l_prm_uom_receive_quantity     NUMBER;
l_primary_uom                  mtl_units_of_measure_tl.unit_of_measure%TYPE;
l_po_uom                       mtl_units_of_measure_tl.unit_of_measure%TYPE;
l_so_uom                       mtl_units_of_measure_tl.unit_of_measure%TYPE;
l_item_id                      oe_order_lines_all.inventory_item_id%TYPE;

BEGIN
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'procedure begin'
      );
/*  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_line_id '||p_line_id
      );*/
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_po_header_id '||p_po_header_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_po_line_id'||p_po_line_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_po_shipment_id'||p_po_shipment_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_ship_from_org_id'||p_ship_from_org_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_ship_to_org_id'||p_ship_to_org_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_receive_quantity'||p_receive_quantity
      );

  l_prm_uom_receive_quantity := p_receive_quantity;
  -- get UOM by UOM_code

  BEGIN
    SELECT
      uom.unit_of_measure
    INTO
      l_primary_uom
    FROM
      mtl_units_of_measure_vl uom
    WHERE uom.uom_code = p_primary_uom_code;
  EXCEPTION
    WHEN no_data_found THEN
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'no data found when select receiving_routing_id by line_location_id'
          );
      RAISE;
  END;

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'l_unit_of_measure'||l_primary_uom
      );

  -- get routing_header_id and get received method
  BEGIN
    SELECT
      location.RECEIVING_ROUTING_ID  -- 1 is standard and 2 is inspection, 3 is direct
    INTO
      l_routing_header_id
    FROM
      PO_LINE_LOCATIONS_ALL location
    WHERE location.line_location_id = p_po_shipment_id;
  EXCEPTION
    WHEN no_data_found THEN
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'no data found when select receiving_routing_id by line_location_id'
          );
      RAISE;
  END;

  -- get supplier_id and supplier_site_id
  get_supplier_id( p_sold_from_org_id => p_ship_from_org_id
                 , x_supplier_id  => l_supplier_id
                 , x_supplier_site_id => l_supplier_site_id
                 );

  -- begin debug log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'begin process_rcv_header'
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_vendor_id '||l_supplier_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_vendor_site_id '||l_supplier_site_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'p_ship_to_org_id'||p_inventory_org_id
      );
  -- end debug log

  --process rcv header , insert header data into rcv_headers_interface
  JMF_SHIKYU_RCV_PVT.process_rcv_header( p_vendor_id            => l_supplier_id  --l_customer_name
                                       , p_vendor_site_id       => l_supplier_site_id
                                       , p_ship_to_org_id       => p_inventory_org_id
                                       , x_rcv_header_id        => l_rcv_header_id
                                       , x_group_id             => l_group_id
                                       );

  -- begin debug log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'l_rcv_header_id '||l_rcv_header_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'l_group_id'||l_group_id
      );
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'end process_rcv_header'
      );
  -- end debug log

  -- begin debug log
  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'l_routing_header_id'||l_routing_header_id
      );
  -- end debug log\

  l_index := p_lines_id.FIRST;
  WHILE l_index IS NOT NULL
  LOOP

    -- begin debug log
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Begin cursor po_distributions_c loop'
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'p_po_shipment_id'||p_po_shipment_id
        );
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'p_lines_id(l_index)'||p_lines_id(l_index)
        );
    -- end debug log\

    OPEN po_distributions_c(p_po_shipment_id, p_lines_id(l_index));

    LOOP
      l_insert_quantity := 0;
      FETCH
        po_distributions_c
      INTO
        l_po_distribution_id
        , l_distribution_num
        , l_quantity_ordered
        , l_quantity_delivered
        , l_po_uom
        , l_allocated_quantity
        , l_so_uom
        , l_item_id;
      EXIT WHEN po_distributions_c%NOTFOUND;

      -- Bug#5647346: convert l_quantity_ordered, l_quantity_delivered, l_allocated_quantity to primary UOM
      l_prm_uom_quantity_ordered := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                                         ( p_org_id                => p_inventory_org_id
                                          , p_item_id              => l_item_id
                                          , p_current_uom_code     => JMF_SHIKYU_UTIL.Get_Uom_Code(l_po_uom)
                                          , p_current_qty          => l_quantity_ordered
                                          );
      l_prm_uom_quantity_delivered := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                                         ( p_org_id                => p_inventory_org_id
                                          , p_item_id              => l_item_id
                                          , p_current_uom_code     => JMF_SHIKYU_UTIL.Get_Uom_Code(l_po_uom)
                                          , p_current_qty          => l_quantity_delivered
                                          );
      l_prm_uom_allocated_quantity := Jmf_Shikyu_Rpt_Util.get_item_primary_quantity
                                         ( p_org_id                => p_inventory_org_id
                                          , p_item_id              => l_item_id
                                          , p_current_uom_code     => JMF_SHIKYU_UTIL.Get_Uom_Code(l_so_uom)
                                          , p_current_qty          => l_allocated_quantity
                                          );

      -- begin insert data to interface,
      IF l_prm_uom_quantity_ordered - l_prm_uom_quantity_delivered > 0
      THEN
        -- begin insert data to interface, pay attion to sub inventory
        --quantity
        IF l_prm_uom_receive_quantity > l_prm_uom_quantity_ordered - l_prm_uom_quantity_delivered
        THEN
          --quantity = l_quantity_ordered - l_quantity_delivered
          -- p_receive_quantity := p_receive_quantity - (l_quantity_ordered - l_quantity_delivered)
          l_insert_quantity := l_allocated_quantity;
          l_prm_uom_receive_quantity := l_prm_uom_receive_quantity -  (l_prm_uom_quantity_ordered - l_prm_uom_quantity_delivered);

        ELSE  /*p_receive_quantity <= l_quantity_ordered - l_quantity_delivered*/
          l_insert_quantity := l_allocated_quantity;

        END IF ; /*end if p_receive_quantity > l_quantity_ordered - l_quantity_delivered*/

        /*
         If there is no subinventory associated with PO Distributions then get
         Default Supply Subinventory from WIP Parameters.
        */
        IF l_dest_subinventory IS NULL
        THEN
          -- find the default subinventory
          -- if default is not null
          -- then ok
          -- else send a message.
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'Dest_subinventory is null'
              );

          BEGIN
            SELECT wip_para.default_pull_supply_subinv
            INTO l_dest_subinventory
            FROM  wip_parameters wip_para
            WHERE wip_para.Organization_Id = p_inventory_org_id;
          EXCEPTION
            WHEN no_data_found THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'no data found when found subinventory by org id'
                  );

              -- log a message that the default sub inventory should be setup
              fnd_message.set_name('JMF', 'JMF_SHK_WIP_SUBINV_MIS');
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => fnd_message.GET
                  );

              RAISE;
            WHEN too_many_rows THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'too many rows when found sub inventory by org id'
                  );
              RAISE;
          END;

        END IF;

        -- begin debug log
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'l_dest_subinventory'||l_dest_subinventory
            );
        -- end debug log\

        /*
         Get the Locator ID.
        */
        IF l_dest_locator_id IS NULL
        THEN
          --get the DEFAULT_PULL_SUPPLY_LOCATOR_ID
          BEGIN
            SELECT wip_para.default_pull_supply_locator_id
            INTO l_default_locator_id
            FROM  wip_parameters wip_para
            WHERE wip_para.Organization_Id = p_inventory_org_id;
          EXCEPTION
            WHEN no_data_found THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'no data found when found locator by org id'
                  );

              RAISE;
            WHEN too_many_rows THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'too many rows when found default locator by org id'
                  );
              RAISE;
          END;

          -- begin debug log
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'l_default_locator_id'||l_default_locator_id
              );
          -- end debug log\

          --get the LOCATOR_TYPE column of the subinventory
          BEGIN
            SELECT msi.locator_type
            INTO l_locator_type
            FROM  MTL_SECONDARY_INVENTORIES msi
            WHERE msi.Organization_Id = p_inventory_org_id
            AND msi.SECONDARY_INVENTORY_NAME = l_dest_subinventory;
          EXCEPTION
            WHEN no_data_found THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'no data found when found locator type by org id and locator id'
                  );
              RAISE;
          END;

          -- begin debug log
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'l_locator_type'||l_locator_type
              );
          -- end debug log\

          --get the project id and task id
          BEGIN
            SELECT oola.project_id, oola.task_id
            INTO l_project_id, l_task_id
            FROM  OE_ORDER_LINES_ALL oola
            WHERE oola.line_id = p_lines_id(l_index);
          EXCEPTION
            WHEN no_data_found THEN
              JMF_SHIKYU_UTIL.debug_output
                  (
                    p_output_to => 'FND_LOG.STRING'
                   ,p_api_name  => l_api_name
                   ,p_message   => 'no data found when found project id and task id by org id and locator id'
                  );
              RAISE;
          END;

          -- begin debug log
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'l_project_id'||l_project_id
              );
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'l_task_id'||l_task_id
              );
          -- end debug log\

          --if this LOCATOR_TYPE column = 3 and if the project id of the Replenishment Sales Order Line is not null,
          --then call the PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator procedure.
          --else pass the DEFAULT_PULL_SUPPLY_LOCATOR_ID to RCV_Transaction_Interface.
          IF (l_locator_type = 3 and l_project_id IS NOT NULL)
          THEN
            PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(p_organization_id     => p_inventory_org_id
                                                         , p_locator_id         => l_default_locator_id
                                                         , p_project_id         => l_project_id
                                                         , p_task_id            => l_task_id
                                                         , p_project_locator_id => l_dest_locator_id
                                                         );
          ELSE
            l_dest_locator_id := l_default_locator_id;
          END IF;

          -- begin debug log
          JMF_SHIKYU_UTIL.debug_output
              (
                p_output_to => 'FND_LOG.STRING'
               ,p_api_name  => l_api_name
               ,p_message   => 'l_dest_locator_id'||l_dest_locator_id
              );
          -- end debug log\

        End IF;

      -- get all of the data
      ELSE  /*l_quantity_ordered - l_quantity_delivered <= 0*/
        --begin log
        JMF_SHIKYU_UTIL.debug_output
            (
              p_output_to => 'FND_LOG.STRING'
             ,p_api_name  => l_api_name
             ,p_message   => 'the quantity auto receive finished '
            );
        --end log
      END IF ; /*end if l_quantity_ordered - l_quantity_delivered > 0 */

      -- begin debug log
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'begin process_rcv_trx'
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_rcv_header_id '||l_rcv_header_id
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_insert_quantity'||l_insert_quantity
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_unit_of_measure'||l_so_uom
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'p_po_header_id'||p_po_header_id
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'p_po_line_id'||p_po_line_id
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_dest_subinventory'||l_dest_subinventory
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_transaction_type'||l_transaction_type
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'l_dest_locator_id'||l_dest_locator_id
          );
      JMF_SHIKYU_UTIL.debug_output
          (
            p_output_to => 'FND_LOG.STRING'
           ,p_api_name  => l_api_name
           ,p_message   => 'p_replenish_order_line_id '||p_lines_id(l_index)
          );
      -- end debug log\

      IF l_routing_header_id = 1 OR l_routing_header_id = 2
      THEN
        -- process rcv trx, insert transactions data into rcv_transactions_interface
        JMF_SHIKYU_RCV_PVT.process_rcv_trx(p_rcv_header_id              => l_rcv_header_id
                                          , p_group_id                  => l_group_id
                                          , p_quantity                  => l_insert_quantity
                                          , p_unit_of_measure           => l_so_uom
                                          , p_po_header_id              => p_po_header_id
                                          , p_po_line_id                => p_po_line_id
                                          , p_subinventory              => NULL
                                          , p_transaction_type          => l_transaction_type
                                          , p_auto_transact_code        => 'RECEIVE'
                                          , p_parent_transaction_id     => NULL
                                          , p_po_line_location_id       => p_po_shipment_id
                                          , P_locator_id                => l_dest_locator_id
                                          , p_replenish_order_line_id   => p_lines_id(l_index)
                                          );
       ELSIF l_routing_header_id = 3
       THEN
        -- process rcv trx, insert transactions data into rcv_transactions_interface
        JMF_SHIKYU_RCV_PVT.process_rcv_trx(p_rcv_header_id              => l_rcv_header_id
                                          , p_group_id                  => l_group_id
                                          , p_quantity                  => l_insert_quantity
                                          , p_unit_of_measure           => l_so_uom
                                          , p_po_header_id              => p_po_header_id
                                          , p_po_line_id                => p_po_line_id
                                          , p_subinventory              => l_dest_subinventory
                                          , p_transaction_type          => l_transaction_type
                                          , p_auto_transact_code        => 'DELIVER'
                                          , p_parent_transaction_id     => NULL
                                          , p_po_line_location_id       => p_po_shipment_id
                                          , P_locator_id                => l_dest_locator_id
                                          , p_replenish_order_line_id   => p_lines_id(l_index)
                                          );

       END IF;

    END LOOP;
    CLOSE po_distributions_c;
    l_index := p_lines_id.NEXT(l_index);
  END LOOP;
  -- submit concurrent request in PL/SQL program.

  l_return_number := fnd_request.submit_request(application       => 'PO'
                                                , program         => 'RVCTP'
                                                , description     => 'Receiving Transaction Processor'
                                                , start_time      => SYSDATE
                                                , sub_request     => FALSE
                                                , argument1       => 'BATCH'
                                                , argument2       => l_group_id
                                                );

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'The request id is : ' || l_return_number
      );

  JMF_SHIKYU_UTIL.debug_output
      (
        p_output_to => 'FND_LOG.STRING'
       ,p_api_name  => l_api_name
       ,p_message   => 'END procedure. '
      );

EXCEPTION
  WHEN OTHERS THEN
    JMF_SHIKYU_UTIL.debug_output
        (
          p_output_to => 'FND_LOG.STRING'
         ,p_api_name  => l_api_name
         ,p_message   => 'Unknown error'||SQLCODE||SQLERRM
        );
    RAISE;

END process_rcv_interface;

END JMF_SHIKYU_AUTO_RCV_PROC;

/
