--------------------------------------------------------
--  DDL for Package Body GML_RCV_STD_RCPT_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RCV_STD_RCPT_APIS" AS
/* $Header: GMLSTDRB.pls 120.1 2005/08/30 10:09:57 nchekuri noship $*/

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'GML_RCV_STD_RCPT_APIS';

--g_rcpt_lot_qty_rec_tb rcpt_lot_qty_rec_tb_tp;
--g_prev_lot_number VARCHAR2(30) := NULL;


PROCEDURE get_project_task (
   p_po_line_location_id IN NUMBER,
   p_oe_order_line_id IN NUMBER,
   x_project_id OUT NOCOPY NUMBER,
   x_task_id   OUT NOCOPY NUMBER
)
IS
   l_project_id NUMBER := '';
   l_task_id NUMBER := '';
BEGIN

   NULL;


EXCEPTION
   WHEN OTHERS THEN
   NULL;
END get_project_task;


  FUNCTION insert_txn_interface(
    p_rcv_transaction_rec  IN OUT NOCOPY  rcv_transaction_rec_tp
  , p_rcv_rcpt_rec         IN OUT NOCOPY  rcv_enter_receipts_rec_tp
  , p_group_id             IN             NUMBER
  , p_transaction_type     IN             VARCHAR2
  , p_organization_id      IN             NUMBER
  , p_location_id          IN             NUMBER
  , p_source_type          IN             VARCHAR2
  , p_qa_routing_id        IN             NUMBER DEFAULT -1
  , p_project_id           IN             NUMBER DEFAULT NULL
  , p_task_id              IN             NUMBER DEFAULT NULL

  )
    RETURN NUMBER IS
  BEGIN

   NULL;

    RETURN NULL;

  END insert_txn_interface;



 /****************************************************
 *  This procedure populates the data structure that
 *  stores received lot quantity.
 *  It retrieves this info  from wms_LPN_contents table
 ****************************************************/

   PROCEDURE  populate_lot_rec(p_lot_number IN VARCHAR2,
			       p_primary_qty IN NUMBER,
			       p_txn_uom_code IN VARCHAR2,
			       p_org_id NUMBER,
			       p_item_id IN NUMBER)
   IS
      l_primary_uom VARCHAR2(3);
      l_txn_qty NUMBER;
      l_counter NUMBER;
      l_create_new NUMBER := 1;
   BEGIN

    NULL;


   END populate_lot_rec;




 /****************************************************
 *  This procedure splits the input transaction qty
 *  based on received lot qty
 *  It retrieves this info  from global variable g_rcpt_lot_qty_rec_tb
 ****************************************************/

 PROCEDURE split_qty_for_lot(p_txn_qty         IN     NUMBER,
			     p_splitted_qty_rec_tb    OUT NOCOPY rcpt_lot_qty_rec_tb_tp)
   IS
      l_new_txn_quantity NUMBER;  -- the quanity user wants to split
      l_new_counter NUMBER := 0;
 BEGIN
    NULL;


 END split_qty_for_lot;



 PROCEDURE create_po_rcpt_intf_rec
   (p_move_order_header_id IN OUT NOCOPY NUMBER,
    p_organization_id      IN     NUMBER,
    p_po_header_id         IN     NUMBER,
    p_po_release_number_id IN     NUMBER,
    p_po_line_id           IN     NUMBER,
    p_item_id              IN     NUMBER,
    p_location_id          IN     NUMBER,
    p_rcv_qty              IN     NUMBER,
    p_rcv_uom              IN     VARCHAR2,
    p_rcv_uom_code         IN     VARCHAR2,
    p_source_type          IN     VARCHAR2,
    p_lpn_id               IN     NUMBER,
    p_lot_control_code     IN     NUMBER,
    p_revision             IN     VARCHAR2,
    p_inspect              IN     NUMBER,
    x_status                  OUT NOCOPY VARCHAR2,
    x_message                 OUT NOCOPY VARCHAR2,
    p_inv_item_id          IN     NUMBER DEFAULT NULL,
    p_item_desc            IN     VARCHAR2 DEFAULT NULL,
    p_project_id	   IN	  NUMBER DEFAULT NULL,
    p_task_id		   IN	  NUMBER DEFAULT NULL,
    p_country_code         IN     VARCHAR2 DEFAULT NULL
    )
   IS

     l_rcpt_match_table_detail GML_RCV_TXN_INTERFACE.cascaded_trans_tab_type;  -- output for matching algorithm

     l_rcv_transaction_rec rcv_transaction_rec_tp; -- rcv_transaction block

     l_interface_transaction_id NUMBER := NULL;
     -- this is used to keep track of the id used to insert the row in rti

     l_transaction_type VARCHAR2(20) := 'RECEIVE';
     l_total_primary_qty NUMBER := 0;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
BEGIN
   NULL;

EXCEPTION

   WHEN OTHERS THEN
     NULL;

END create_po_rcpt_intf_rec;


 PROCEDURE create_intship_rcpt_intf_rec
   (p_move_order_header_id IN OUT NOCOPY NUMBER,
    p_organization_id      IN     NUMBER,
    p_shipment_header_id   IN     NUMBER,
    p_req_header_id        IN     NUMBER,
    p_item_id              IN     NUMBER,
    p_location_id          IN     NUMBER,
    p_rcv_qty              IN     NUMBER,
    p_rcv_uom              IN     VARCHAR2,
    p_rcv_uom_code         IN     VARCHAR2,
    p_source_type          IN     VARCHAR2,
    p_lpn_id               IN     NUMBER,
    p_lot_control_code     IN     NUMBER,
    p_revision             IN     VARCHAR2,
    p_inspect              IN     NUMBER,
    x_status               OUT    NOCOPY VARCHAR2,
    x_message              OUT    NOCOPY VARCHAR2,
    p_project_id	         IN	    NUMBER DEFAULT NULL,
    p_task_id		         IN     NUMBER DEFAULT NULL,
    p_country_code         IN     VARCHAR2 DEFAULT NULL
    )
   IS



 BEGIN

    NULL;



EXCEPTION


    WHEN OTHERS THEN

     NULL;
 END create_intship_rcpt_intf_rec;



 PROCEDURE create_rma_rcpt_intf_rec
   (p_move_order_header_id IN OUT NOCOPY NUMBER,
    p_organization_id      IN     NUMBER,
    p_oe_order_header_id   IN     NUMBER,
    p_item_id              IN     NUMBER,
    p_location_id          IN     NUMBER,
    p_rcv_qty              IN     NUMBER,
    p_rcv_uom              IN     VARCHAR2,
    p_rcv_uom_code         IN     VARCHAR2,
    p_source_type          IN     VARCHAR2,
    p_lpn_id               IN     NUMBER,
    p_lot_control_code     IN     NUMBER,
    p_revision             IN     VARCHAR2,
    p_inspect              IN     NUMBER,
    x_status                  OUT NOCOPY VARCHAR2,
    x_message                 OUT NOCOPY VARCHAR2,
    p_project_id	  IN	  NUMBER DEFAULT NULL,
    p_task_id		  IN      NUMBER DEFAULT NULL,
    p_country_code        IN      VARCHAR2 DEFAULT NULL
    )
   IS


 BEGIN
     NULL;
EXCEPTION

    WHEN OTHERS THEN
        NULL;

 END create_rma_rcpt_intf_rec;




PROCEDURE create_asn_con_rcpt_intf_rec
  (p_move_order_header_id        IN OUT NOCOPY NUMBER,
   p_organization_id             IN NUMBER,
   p_shipment_header_id          IN NUMBER,
   p_po_header_id                IN NUMBER,
   p_item_id                     IN NUMBER,
   p_location_id                 IN NUMBER,
   p_rcv_qty                     IN NUMBER,
   p_rcv_uom                     IN VARCHAR2,
   p_rcv_uom_code                IN VARCHAR2,
   p_source_type                 IN VARCHAR2,
   p_from_lpn_id                 IN NUMBER,
   p_lpn_id                      IN NUMBER,
   p_lot_control_code            IN NUMBER,
   p_revision                    IN VARCHAR2,
   p_inspect                     IN NUMBER,
   x_status                      OUT NOCOPY VARCHAR2,
   x_message                     OUT NOCOPY VARCHAR2,
   p_item_desc                   IN VARCHAR2 DEFAULT NULL,
    p_project_id	         IN NUMBER DEFAULT NULL,
    p_task_id		         IN NUMBER DEFAULT NULL,
   p_country_code                IN VARCHAR2 DEFAULT NULL
   )
  IS

     l_rcpt_match_table_detail INV_RCV_COMMON_APIS.cascaded_trans_tab_type;  -- output for matching algorithm

     l_rcv_transaction_rec rcv_transaction_rec_tp; -- rcv_transaction block

     l_interface_transaction_id NUMBER := NULL;
     -- this is used to keep track of the id used to insert the row in rti

     l_transaction_type VARCHAR2(20) := 'RECEIVE';
     l_total_primary_qty NUMBER := 0;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);

     l_err_message VARCHAR2(100);
     l_temp_message VARCHAR2(100);
     l_msg_prod VARCHAR2(5);

     l_group_id NUMBER;

     l_rcv_rcpt_rec rcv_enter_receipts_rec_tp;
     l_inspect NUMBER;

     l_match_type VARCHAR2(30);
     l_receipt_num VARCHAR2(30);

BEGIN

   NULL;

EXCEPTION

    WHEN OTHERS THEN
      NULL;


END create_asn_con_rcpt_intf_rec;


PROCEDURE create_asn_exp_rcpt_intf_rec
  (p_move_order_header_id        IN OUT NOCOPY NUMBER,
   p_organization_id             IN NUMBER,
   p_shipment_header_id          IN NUMBER,
   p_po_header_id                IN NUMBER,
   p_location_id                 IN NUMBER,
   p_source_type                 IN VARCHAR2,
   p_lpn_id                      IN NUMBER,
   p_inspect                     IN NUMBER,
   x_status                      OUT NOCOPY VARCHAR2,
   x_message                     OUT NOCOPY VARCHAR2,
    p_project_id	  IN	  NUMBER DEFAULT NULL,
    p_task_id		  IN      NUMBER DEFAULT NULL
   )
  IS
BEGIN
   NULL;
EXCEPTION

 WHEN OTHERS THEN
  NULL;


END create_asn_exp_rcpt_intf_rec;


 PROCEDURE create_std_rcpt_intf_rec(p_move_order_header_id IN OUT NOCOPY NUMBER,
				    p_organization_id      IN     NUMBER,
				    p_po_header_id         IN     NUMBER,
				    p_po_release_number_id IN     NUMBER,
				    p_po_line_id           IN     NUMBER,
				    p_shipment_header_id   IN     NUMBER,
				    p_req_header_id        IN     NUMBER,
				    p_oe_order_header_id   IN     NUMBER,
				    p_item_id              IN     NUMBER,
				    p_location_id          IN     NUMBER,
				    p_rcv_qty              IN     NUMBER,
				    p_rcv_uom              IN     VARCHAR2,
				    p_rcv_uom_code         IN     VARCHAR2,
				    p_source_type          IN     VARCHAR2,
				    p_from_lpn_id          IN     NUMBER,
				    p_lpn_id               IN     NUMBER,
				    p_lot_control_code     IN     NUMBER,
				    p_revision             IN     VARCHAR2,
				    p_inspect              IN     NUMBER,
				    x_status                  OUT NOCOPY VARCHAR2,
				    x_message                 OUT NOCOPY VARCHAR2,
				    p_inv_item_id          IN     NUMBER DEFAULT NULL,
                                    p_item_desc            IN     VARCHAR2 DEFAULT NULL,
				    p_project_id	   IN     NUMBER DEFAULT NULL,
				    p_task_id		   IN     NUMBER DEFAULT NULL,
                                    p_country_code         IN     VARCHAR2 DEFAULT NULL
				    )
   IS
      l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(4000);
      l_progress VARCHAR2(10);
      l_label_status VARCHAR2(500);
      l_txn_id_tbl inv_label.transaction_id_rec_type;
      l_counter NUMBER := 0;
      /* Bug 2200851 */
      /* Changed min to max */
      /* Group BY LPN_ID is changed for Express Receipts */
      /* Also  duplicate print of LPN labels is avoided */

      CURSOR c_rti_txn_id IS
	 SELECT MAX(rti.interface_transaction_id)
	   FROM rcv_transactions_interface rti
	  WHERE rti.group_id = INV_rcv_common_apis.g_rcv_global_var.interface_group_id
	  GROUP BY decode(p_source_type,'ASNEXP',rti.interface_transaction_id,'SHIPMENTEXP',rti.interface_transaction_id,null) ;
	  -- GROUP BY rti.lpn_id;
 BEGIN
    NULL;




 EXCEPTION
  WHEN OTHERS THEN
   NULL;


 END create_std_rcpt_intf_rec;


PROCEDURE create_mo_for_correction(p_move_order_header_id IN OUT NOCOPY NUMBER,
                p_po_line_location_id  IN     NUMBER DEFAULT NULL,
		p_po_distribution_id   IN     NUMBER DEFAULT NULL,
	        p_shipment_line_id     IN     NUMBER DEFAULT NULL,
		p_oe_order_line_id     IN     NUMBER DEFAULT NULL,
                p_routing              IN     NUMBER,
                p_lot_control_code     IN     NUMBER,
                p_org_id               IN     NUMBER,
                p_item_id              IN     NUMBER,
                p_qty                  IN     NUMBER,
                p_uom_code             IN     VARCHAR2,
                p_lpn                  IN     NUMBER,
                p_revision             IN     VARCHAR2 DEFAULT NULL,
                p_inspect              IN     NUMBER,
                p_txn_source_id        IN     NUMBER,
                x_status               OUT    NOCOPY VARCHAR2,
                x_message              OUT    NOCOPY VARCHAR2,
		p_transfer_org_id      IN     NUMBER   DEFAULT NULL,
		p_wms_process_flag     IN     NUMBER   DEFAULT NULL
	        )
  IS
BEGIN
    NULL;


END create_mo_for_correction;

PROCEDURE create_move_order(p_move_order_header_id IN OUT NOCOPY NUMBER,
			    p_po_line_location_id  IN     NUMBER,
			    p_po_distribution_id   IN     NUMBER,
			    p_shipment_line_id     IN     NUMBER,
			    p_oe_order_line_id     IN     NUMBER,
			    p_routing              IN     VARCHAR2,
			    p_lot_control_code     IN     NUMBER,
			    p_org_id               IN     NUMBER,
			    p_item_id              IN     NUMBER,
			    p_qty                  IN     NUMBER,
			    p_uom_code             IN     VARCHAR2,
			    p_lpn                  IN     NUMBER,
			    p_project_id           IN     NUMBER   DEFAULT NULL,
			    p_task_id              IN     NUMBER   DEFAULT NULL,
			    p_revision             IN     VARCHAR2 DEFAULT NULL,
			    p_inspect              IN     NUMBER,
			    p_txn_source_id        IN     NUMBER,
			    x_status               OUT    NOCOPY VARCHAR2,
			    x_message              OUT    NOCOPY VARCHAR2,
			    p_transfer_org_id      IN     NUMBER   DEFAULT NULL,
			    p_wms_process_flag     IN     NUMBER   DEFAULT NULL)
  IS
BEGIN
   NULL;


END create_move_order;



  PROCEDURE rcv_update_rti_from_header(
    p_shipment_num                      VARCHAR
  , p_freight_carrier_code              VARCHAR2
  , p_bill_of_lading                    VARCHAR2
  , p_packing_slip                      VARCHAR2
  , p_num_of_containers                 NUMBER
  , p_waybill_airbill_num               VARCHAR2
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_msg_count             OUT NOCOPY  NUMBER
  , x_msg_data              OUT NOCOPY  VARCHAR2
  ) IS
    l_return_status  VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_msg_count      NUMBER;
    l_msg_data       VARCHAR2(4000);
    l_progress       VARCHAR2(10);
    l_process_status VARCHAR2(10);
  BEGIN
    NULL;

  END rcv_update_rti_from_header;


  PROCEDURE rcv_update_header_interface(
    p_organization_id                     NUMBER
  , p_header_intf_id                      NUMBER
  , p_source_type                         VARCHAR2
  , p_receipt_num                         VARCHAR2
  , p_vendor_id                           NUMBER
  , p_vendor_site_id                      NUMBER
  , p_shipment_num                        VARCHAR2
  , p_ship_to_location_id                 NUMBER
  , p_bill_of_lading                      VARCHAR2
  , p_packing_slip                        VARCHAR2
  , p_shipped_date                        DATE
  , p_freight_carrier_code                VARCHAR2
  , p_expected_receipt_date               DATE
  , p_num_of_containers                   NUMBER
  , p_waybill_airbill_num                 VARCHAR2
  , p_comments                            VARCHAR2
  , p_ussgl_transaction_code              VARCHAR2
  , p_program_request_id                  NUMBER
  , p_customer_id                         NUMBER
  , p_customer_site_id                    NUMBER
  , x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count               OUT NOCOPY  NUMBER
  , x_msg_data                OUT NOCOPY  VARCHAR2
  ) IS

    l_sysdate       DATE                           := SYSDATE;
    l_return_status VARCHAR2(1)                    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);

    l_debug         NUMBER                         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    NULL;

  EXCEPTION
   WHEN OTHERS THEN
  NULL;
  END rcv_update_header_interface;

  PROCEDURE rcv_insert_header_interface(
    p_organization_id                     NUMBER
  , p_source_type                         VARCHAR2
  , p_receipt_num             OUT NOCOPY  VARCHAR2
  , p_vendor_id                           NUMBER
  , p_vendor_site_id                      NUMBER
  , p_shipment_num                        VARCHAR2
  , p_ship_to_location_id                 NUMBER
  , p_bill_of_lading                      VARCHAR2
  , p_packing_slip                        VARCHAR2
  , p_shipped_date                        DATE
  , p_freight_carrier_code                VARCHAR2
  , p_expected_receipt_date               DATE
  , p_num_of_containers                   NUMBER
  , p_waybill_airbill_num                 VARCHAR2
  , p_comments                            VARCHAR2
  , p_ussgl_transaction_code              VARCHAR2
  , p_government_context                  VARCHAR2
  , p_request_id                          NUMBER
  , p_program_application_id              NUMBER
  , p_program_id                          NUMBER
  , p_program_update_date                 DATE
  , p_customer_id                         NUMBER
  , p_customer_site_id                    NUMBER
  , x_return_status           OUT NOCOPY  VARCHAR2
  , x_msg_count               OUT NOCOPY  NUMBER
  , x_msg_data                OUT NOCOPY  VARCHAR2
  ) IS
    l_header        rcv_headers_interface%ROWTYPE;
    l_rowid         VARCHAR2(40);
    l_sysdate       DATE                           := SYSDATE;
    l_return_status VARCHAR2(1)                    := fnd_api.g_ret_sts_success;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(4000);
    l_progress      VARCHAR2(10);
  BEGIN
    NULL;

  EXCEPTION

    WHEN OTHERS THEN
       NULL;

  END rcv_insert_header_interface;

PROCEDURE rcv_insert_update_header
  (p_organization_id        IN     NUMBER,
   p_shipment_header_id     IN OUT NOCOPY NUMBER,
   p_source_type            IN     VARCHAR2,
   p_receipt_num            IN OUT NOCOPY VARCHAR2,
   p_vendor_id              IN     NUMBER,
   p_vendor_site_id         IN     NUMBER,
   p_shipment_num           IN     VARCHAR2,
   p_ship_to_location_id    IN     NUMBER,
   p_bill_of_lading         IN     VARCHAR2,
   p_packing_slip           IN     VARCHAR2,
   p_shipped_date           IN     DATE,
   p_freight_carrier_code   IN     VARCHAR2,
   p_expected_receipt_date  IN     DATE,
   p_num_of_containers      IN     NUMBER,
   p_waybill_airbill_num    IN     VARCHAR2,
   p_comments               IN     VARCHAR2,
   p_ussgl_transaction_code IN     VARCHAR2,
   p_government_context     IN     VARCHAR2,
   p_request_id             IN     NUMBER,
   p_program_application_id IN     NUMBER,
   p_program_id             IN     NUMBER,
   p_program_update_date    IN     DATE,
   p_customer_id            IN     NUMBER,
   p_customer_site_id       IN     NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
  )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
     l_receipt_number VARCHAR2(12);

BEGIN
   NULL;

EXCEPTION
 WHEN OTHERS THEN
   NULL;

END rcv_insert_update_header;


PROCEDURE PackUnpack_Container
  (p_api_version   	    IN	    NUMBER                        ,
   p_init_msg_list	    IN	    VARCHAR2 := fnd_api.g_false   ,
   p_commit		    IN	    VARCHAR2 := fnd_api.g_false   ,
   x_return_status	    OUT	    NOCOPY VARCHAR2                      ,
   x_msg_count		    OUT	    NOCOPY NUMBER                        ,
   x_msg_data		    OUT	    NOCOPY VARCHAR2                      ,
   p_from_lpn_id            IN      NUMBER   := NULL              ,
   p_lpn_id		    IN	    NUMBER                        ,
   p_content_lpn_id	    IN	    NUMBER   := NULL              ,
   p_content_item_id	    IN	    NUMBER   := NULL              ,
   p_content_item_desc	    IN	    VARCHAR2 := NULL              ,
   p_revision		    IN	    VARCHAR2 := NULL              ,
   p_lot_number		    IN	    VARCHAR2 := NULL              ,
   p_from_serial_number	    IN	    VARCHAR2 := NULL              ,
   p_to_serial_number	    IN	    VARCHAR2 := NULL              ,
   p_quantity		    IN	    NUMBER   := NULL              ,
   p_uom		    IN	    VARCHAR2 := NULL              ,
   p_organization_id	    IN	    NUMBER                        ,
   p_subinventory	    IN	    VARCHAR2 := NULL              ,
   p_locator_id		    IN	    NUMBER   := NULL              ,
   p_enforce_wv_constraints IN	    NUMBER   := 2                 ,
   p_operation		    IN	    NUMBER                        ,
   p_cost_group_id          IN      NUMBER   := NULL              ,
   p_source_type_id         IN      NUMBER   := NULL              ,
   p_source_header_id       IN      NUMBER   := NULL              ,
   p_source_name            IN      VARCHAR2 := NULL              ,
   p_source_line_id         IN      NUMBER   := NULL              ,
   p_source_line_detail_id  IN      NUMBER   := NULL              ,
   p_homogeneous_container  IN      NUMBER   := 2                 ,
   p_match_locations        IN      NUMBER   := 2                 ,
   p_match_lpn_context      IN      NUMBER   := 2                 ,
   p_match_lot              IN      NUMBER   := 2                 ,
   p_match_cost_groups      IN      NUMBER   := 2                 ,
   p_match_mtl_status       IN      NUMBER   := 2
  )
  IS
BEGIN
  NULL;

EXCEPTION
 WHEN OTHERS THEN
  NULL;



END packunpack_container;


PROCEDURE detect_ASN_discrepancy
  (p_shipment_header_id NUMBER,
   p_lpn_id NUMBER,
   p_po_header_id NUMBER,
   x_discrepancy_flag OUT NOCOPY NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2)

IS
BEGIN
  NULL;


END detect_ASN_discrepancy;


PROCEDURE transfer_lpn_contents
  (p_to_lpn_id   IN NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2
   )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
BEGIN
   NULL;


END transfer_lpn_contents;



PROCEDURE remove_lpn_contents
  (p_lpn_id   IN NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2,
   p_routing_id     IN NUMBER DEFAULT NULL
   )
  IS
     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
BEGIN

 NULL;

END remove_lpn_contents;

PROCEDURE clear_LPN_for_ship
  (p_organization_id   IN NUMBER,
   p_shipment_header_id   IN NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2,
   p_routing_id         IN NUMBER DEFAULT NULL
   )
  IS
BEGIN
  NULL;


EXCEPTION

   WHEN OTHERS THEN
      NULL;
End clear_LPN_for_ship;
-- If theres LPN on this shipment, lpn_flag = 1, else lpn_flag = 0

PROCEDURE check_lpn_on_shipment
  (p_shipment_number IN VARCHAR2,
   p_from_organization_id IN NUMBER,
   p_to_organization_id IN NUMBER,
   x_lpn_flag OUT NOCOPY NUMBER,
   x_return_status      OUT        NOCOPY VARCHAR2,
   x_msg_count          OUT        NOCOPY NUMBER,
   x_msg_data           OUT        NOCOPY VARCHAR2)
  IS
     l_lpn_count NUMBER := 0;
     l_lot_serial_flag NUMBER := 1;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
BEGIN
 NULL;


END check_lpn_on_shipment;


PROCEDURE check_lpn_on_ASN
  (p_shipment_header_id IN VARCHAR2,
   x_lpn_flag OUT NOCOPY NUMBER,
   x_return_status       OUT       NOCOPY VARCHAR2,
   x_msg_count           OUT       NOCOPY NUMBER,
   x_msg_data            OUT       NOCOPY VARCHAR2
   )
  IS
     l_lpn_count NUMBER := 0;
     l_lot_serial_flag NUMBER := 1;

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
BEGIN
  NULL;




EXCEPTION
   WHEN OTHERS THEN
  NULL;
END check_lpn_on_ASN;



-- Express Int Req Receiving
PROCEDURE CHECK_LPN_ON_REQ (
                                p_req_num               IN  VARCHAR2,
                                x_lpn_flag              OUT NOCOPY NUMBER,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2
                           ) IS
l_lpn_flag              NUMBER := 0;
l_lpn_id                NUMBER := NULL;
l_order_header_id       NUMBER;
l_order_line_id         NUMBER;
l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_progress              VARCHAR2(10);
l_shipping_org          NUMBER;
l_lpn_org               NUMBER;
l_lpn_context           NUMBER;
l_exit_outer            BOOLEAN := FALSE;

BEGIN
 NULL;



EXCEPTION

   WHEN OTHERS THEN
    NULL;
END;
-- Express Int Req Receiving

PROCEDURE update_LPN_Org (
   p_organization_id IN NUMBER,
   p_lpn_id    IN NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2
)
IS

BEGIN
 NULL;
EXCEPTION
 WHEN OTHERS THEN
  NULL;
END update_LPN_Org;
END GML_RCV_STD_RCPT_APIS;

/
