--------------------------------------------------------
--  DDL for Package Body CSFW_ORDER_PARTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_ORDER_PARTS" AS
/* $Header: csfwordb.pls 120.3 2007/12/18 13:52:02 htank ship $ */
--
-- Purpose: To create parts order for Field Service Wireless
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- ---------   ------   ------------------------------------------
-- mmerchan    10/23/01 Created new package body
-- mmerchan	05/23/02	Added task_id, task_assignment_id
-- htank       20-Jun-2006    Bug # 5171584
-- hgotur	20-Feb-2006	Bug 5465343: TRANSACT_MOVE_ORDER - returning messages from TRANSACT_MATERIAL
-- htank    18-Dec-2007    Bug # 5242440

G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'csfw_order_parts';
G_FILE_NAME CONSTANT    VARCHAR2(30) := 'csfwordb.pls';

  -- This procedure is to create single order line.
PROCEDURE process_order (
order_type_id             IN NUMBER,
ship_to_location_id       IN NUMBER,
shipping_method_code      IN VARCHAR2,
task_id                   IN NUMBER,
task_assignment_id        IN NUMBER,
need_by_date              IN DATE ,
dest_organization_id      IN NUMBER,
operation                 IN VARCHAR2,
resource_type             IN VARCHAR2,
resource_id               IN NUMBER,
inventory_item_id         IN NUMBER,
revision                  IN VARCHAR2,
unit_of_measure           IN VARCHAR2,
source_organization_id    IN NUMBER,
source_subinventory       IN VARCHAR2,
ordered_quantity          IN NUMBER,
order_number		  OUT NOCOPY NUMBER,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2
 )IS

CURSOR C_ORDER_NUMBER(v_header_id NUMBER)
IS
SELECT order_number
FROM oe_order_headers_all
where header_id = v_header_id;

l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_header_rec             csp_parts_requirement.header_rec_type;
l_line_rec               csp_parts_requirement.line_rec_type;
l_line_tbl               csp_parts_requirement.line_tbl_type;
v_OPEN_REQUIREMENT varchar2(240);
l_destination_org_id number;
l_dest_sub_inv varchar2(30);

cursor c_default_org (v_resource_id Number) is
Select ORGANIZATION_ID ,SUBINVENTORY_CODE
from csp_inv_loc_assignments
where resource_id =  v_resource_id
and DEFAULT_CODE = 'IN'
and sysdate between nvl(EFFECTIVE_DATE_START, sysdate) and nvl(EFFECTIVE_DATE_END, sysdate);

r_default_org c_default_org%ROWTYPE;


BEGIN
	x_return_status := 'S'; order_number := -1;

	l_header_rec.order_type_id := order_type_id;
	l_header_rec.ship_to_location_id := ship_to_location_id;

	IF (task_id <> 0) then
		l_header_rec.task_id                   := task_id;
	end if;

	if (task_assignment_id <> 0) then
		l_header_rec.task_assignment_id        :=task_assignment_id;
	end if;

	l_header_rec.need_by_date              := need_by_date;
	l_header_rec.dest_organization_id      := dest_organization_id;

	l_header_rec.operation                 := operation;
	l_header_rec.resource_type             := resource_type;
	l_header_rec.resource_id               := resource_id;

	-- Adding the resource default sub inventory
	open c_default_org(l_header_rec.resource_id);
	fetch c_default_org into r_default_org;
	close c_default_org;

	l_destination_org_id := r_default_org.ORGANIZATION_ID;
	l_dest_sub_inv := r_default_org.SUBINVENTORY_CODE;


	l_header_rec.dest_organization_id := l_destination_org_id ;
	l_header_rec.dest_subinventory := l_dest_sub_inv;

	--END OF HEADER RECORD. Lets Set the Line record

	l_line_rec.inventory_item_id         := inventory_item_id;
	l_line_rec.revision                  := revision;
	l_line_rec.unit_of_measure           := unit_of_measure;
	l_line_rec.ordered_quantity          := ordered_quantity;
	l_line_rec.quantity                  := ordered_quantity;
	l_line_rec.source_organization_id    := source_organization_id;

	if (source_subinventory is not null and source_subinventory <> '') then
		l_line_rec.source_subinventory         := source_subinventory;
	end if;

	l_line_rec.shipping_method_code      := shipping_method_code;
	l_line_rec.order_by_date             :=sysdate;
	l_line_rec.line_num := 1;
	l_line_tbl(1) := l_line_rec;

	--we would call with true commit flag
	CSP_PARTS_REQUIREMENT.process_requirement(p_api_version => 1.0
		 ,p_Init_Msg_List           => FND_API.G_TRUE
		 ,p_commit                  => FND_API.G_TRUE
		 ,px_header_rec             => l_header_rec
		 ,px_line_table             => l_Line_Tbl
		 ,p_create_order_flag            => 'Y'
		 ,x_return_status           => l_return_Status
		 ,x_msg_count               => l_msg_count
		 ,x_msg_data                => l_msg_data
		);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := 'E';
	x_error_msg := l_msg_data;

	-- This if is only for  the Debug purpose
	if l_msg_count > 0 THEN
		FOR l_counter IN 1 .. l_msg_count
		LOOP
			fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_msg_data
			, p_msg_index_out => l_msg_count
			);
		END  LOOP;
	--dbms_output.put_line(x_error_msg || 'API error');
	end if;
   ELSE
	-- This is successful. But if there is a message data then it's a failure
	IF l_msg_data IS NOT NULL THEN
		x_return_status := 'E';
		x_error_msg := l_msg_data;
	ELSE
		-- we can get the Order Number here
		BEGIN
			OPEN C_ORDER_NUMBER(l_header_rec.order_header_id);
			FETCH C_ORDER_NUMBER INTO order_number;
			IF C_ORDER_NUMBER%NOTFOUND THEN
				order_number := -2; /* Fatal Error */
			END IF;
			CLOSE C_ORDER_NUMBER;

		EXCEPTION
			WHEN OTHERS THEN
			order_number := -3; /* Fatal Error */
		END;
	END IF;

   END IF;

 END PROCESS_ORDER;



PROCEDURE process_order
 ( order_type_id             IN NUMBER,
   ship_to_location_id       IN NUMBER,
   dest_organization_id      IN NUMBER,
   operation                 IN VARCHAR2,
   need_by_date		     IN DATE,
   inventory_item_id         IN NUMBER,
   revision                  IN VARCHAR2,
   unit_of_measure           IN VARCHAR2,
   ordered_quantity          IN NUMBER,
   task_id		     IN NUMBER,
   task_assignment_id	     IN NUMBER,
   order_number		     OUT NOCOPY NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_error_msg               OUT NOCOPY VARCHAR2
  ) IS

CURSOR C_ORDER_NUMBER(v_header_id NUMBER)
IS
SELECT order_number
FROM oe_order_headers_all
where header_id = v_header_id;


   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);
   l_header_rec             csp_parts_requirement.header_rec_type;
   l_line_rec               csp_parts_requirement.line_rec_type;
   l_line_tbl               csp_parts_requirement.line_tbl_type;
   v_OPEN_REQUIREMENT varchar2(240);
   l_resource_id number;
   l_resource_type varchar2(30);
   l_destination_org_id NUMBER;
   l_dest_sub_inv VARCHAR2(30);

cursor c_default_org (v_resource_id Number) is
Select ORGANIZATION_ID ,SUBINVENTORY_CODE
from csp_inv_loc_assignments
where resource_id =  v_resource_id
and DEFAULT_CODE = 'IN'
and sysdate between nvl(EFFECTIVE_DATE_START, sysdate) and nvl(EFFECTIVE_DATE_END, sysdate);

r_default_org c_default_org%ROWTYPE;

cursor c_resource( v_user_id number) is
select a.resource_id resource_id,
       b.resource_type resource_type
from jtf_rs_resource_extns a, CSP_RS_RESOURCES_V  b
where a.user_id = v_user_id
  and a.resource_id = b.resource_id;

r_resource c_resource%ROWTYPE;

BEGIN
   x_return_status := 'S'; order_number := -1;
   l_header_rec.order_type_id := order_type_id;

   l_header_rec.ship_to_location_id := ship_to_location_id;
   l_header_rec.dest_organization_id := dest_organization_id;
   l_header_rec.operation := 'CREATE';
   l_header_rec.need_by_date := need_by_date;
   l_header_rec.task_id := task_id;
   l_header_rec.task_assignment_id := task_assignment_id;

   l_line_rec.inventory_item_id := inventory_item_id;
   l_line_rec.revision := revision;
   l_line_rec.unit_of_measure := unit_of_measure;
   l_line_rec.ordered_quantity := ordered_quantity;
   l_line_rec.quantity := ordered_quantity;
--   l_line_rec.source_organization_id := dest_organization_id;
   l_line_rec.line_num := 1;
   l_line_tbl(1) := l_line_rec;

   -- the Resource_id and type
   open c_resource(FND_GLOBAL.USER_ID);
   fetch c_resource into r_resource;
   close c_resource;

   l_resource_id   := r_resource.resource_id;
   l_resource_type := r_resource.resource_type;


	l_header_rec.resource_id             := l_resource_id;
	l_header_rec.resource_type           := l_resource_type;

	-- Adding the resource default sub inventory
	open c_default_org(l_resource_id);
	fetch c_default_org into r_default_org;
	close c_default_org;

	l_destination_org_id := r_default_org.ORGANIZATION_ID;
	l_dest_sub_inv := r_default_org.SUBINVENTORY_CODE;

	l_header_rec.dest_organization_id := l_destination_org_id ;
	l_header_rec.dest_subinventory := l_dest_sub_inv;




   --CSP_PARTS_ORDER.process_order(p_api_version => 1.0
   CSP_PARTS_REQUIREMENT.process_requirement(p_api_version => 1.0
         ,p_Init_Msg_List           => FND_API.G_TRUE
         ,p_commit                  => FND_API.G_TRUE
         ,px_header_rec             => l_header_rec
         ,px_line_table             => l_Line_Tbl
         ,p_create_order_flag       => 'Y'
         ,x_return_status           => l_return_Status
         ,x_msg_count               => l_msg_count
         ,x_msg_data                => l_msg_data
        );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := 'E';
	x_error_msg := l_msg_data;

	-- This if is only for  the Debug purpose
	if l_msg_count > 0 THEN
		FOR l_counter IN 1 .. l_msg_count
		LOOP
			fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => l_msg_data
			, p_msg_index_out => l_msg_count
			);
		END  LOOP;
	--dbms_output.put_line(x_error_msg || 'API error');
	end if;
   ELSE
	-- This is successful. But if there is a message data then it's a failure
	IF l_msg_data IS NOT NULL THEN
		x_return_status := 'E';
		x_error_msg := l_msg_data;
	ELSE
		-- we can get the Order Number here
		BEGIN
			OPEN C_ORDER_NUMBER(l_header_rec.order_header_id);
			FETCH C_ORDER_NUMBER INTO order_number;
			IF C_ORDER_NUMBER%NOTFOUND THEN
				order_number := -2; /* Fatal Error */
			END IF;
			CLOSE C_ORDER_NUMBER;

		EXCEPTION
			WHEN OTHERS THEN
			order_number := -3; /* Fatal Error */
		END;
	END IF;

   END IF;

 END PROCESS_ORDER;





PROCEDURE CREATE_MOVE_ORDER
(  p_organization_id        IN NUMBER
  ,p_from_subinventory_code IN VARCHAR2
  ,p_from_locator_id        IN NUMBER
  ,p_inventory_item_id      IN NUMBER
  ,p_revision               IN VARCHAR2
  ,p_lot_number             IN VARCHAR2
  ,p_serial_number_start    IN VARCHAR2
  ,p_serial_number_end      IN VARCHAR2
  ,p_quantity               IN NUMBER
  ,p_uom_code               IN VARCHAR2
  ,p_to_subinventory_code   IN VARCHAR2
  ,p_to_locator_id          IN NUMBER
  ,p_date_required          IN DATE
  ,p_comments               IN VARCHAR2
  ,x_move_order_number      OUT NOCOPY VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

	l_api_version_number    CONSTANT NUMBER := 1.0;
	l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
	l_msg_count             NUMBER;
	l_msg_data              VARCHAR2(240);
	l_commit                VARCHAR2(1) := FND_API.G_FALSE;
	l_move_order_id         number;
	lx_line_id             number;
	l_api_name              CONSTANT VARCHAR2(30) := 'CSFW.Create_Move_Order';
	l_locator_id_to        number;
	l_locator_id_from      number;
	l_revision             varchar2(100);
	l_sr_number_start      varchar2(100);
	l_sr_number_end        varchar2(100);
	l_lot_number           varchar2(100);
	EXCP_USER_DEFINED      EXCEPTION;
	l_date_required        DATE;
	l_msg_count2 number;

CURSOR c_REQUEST_NUMBER (v_move_order_id number )IS
SELECT REQUEST_NUMBER
FROM MTL_TXN_REQUEST_HEADERS
WHERE HEADER_ID = v_move_order_id ;


BEGIN

	-- for now lets get the sysdate for p_date_required
	IF (p_date_required  IS NULL) THEN
		l_date_required  := sysdate;
	ELSE
		l_date_required  := p_date_required;
	END IF;


	IF (p_to_locator_id = 0) THEN
		l_locator_id_to := null;
	ELSE
		l_locator_id_to := p_to_locator_id;
	END IF;


	IF (p_from_locator_id = 0) THEN
		l_locator_id_from := null;
	ELSE
		l_locator_id_from := p_from_locator_id;
	END IF;


	IF (p_revision = '') THEN
		l_revision := null;
	ELSE
		l_revision := p_revision;
	END IF;


	IF (p_lot_number = '') THEN
		l_lot_number := null;
	ELSE
		l_lot_number := p_lot_number;
	END IF;


	IF (p_serial_number_start = '') THEN
		l_sr_number_start := null;
	ELSE
		l_sr_number_start := p_serial_number_start;
	END IF;

	IF (p_serial_number_end = '') THEN
		l_sr_number_end := null;
	ELSE
		l_sr_number_end := p_serial_number_end;
	END IF;


-- WE will first call for the header and then for the line
-- after we are done ... we can return the number
CSP_TRANSACTIONS_PUB.CREATE_MOVE_ORDER_HEADER(
px_header_id             => l_move_order_id
,p_request_number         => null
,p_api_version            => l_api_version_number
,p_Init_Msg_List          => FND_API.G_FALSE
,p_commit                 => l_commit
,p_date_required          => l_date_required
,p_organization_id        => p_organization_id
,p_from_subinventory_code => p_from_subinventory_code
,p_to_subinventory_code   => p_to_subinventory_code
,p_address1               => null
,p_address2               => null
,p_address3               => null
,p_address4               => null
,p_city                   => null
,p_postal_code            => null
,p_state                  => null
,p_province               => null
,p_country                => null
,p_freight_carrier        => null
,p_shipment_method        => null
,p_autoreceipt_flag       => null
,x_return_status          => l_return_status
,x_msg_count              => l_msg_count
,x_msg_data               => l_msg_data );

IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

      -- bug # 5171584
      fnd_msg_pub.get
        ( p_msg_index     => l_msg_count
        , p_encoded       => FND_API.G_FALSE
        , p_data          => x_msg_data
        , p_msg_index_out => l_msg_count2
        );

	RAISE FND_API.G_EXC_ERROR;
ELSE

	--call the Line
		CSP_TRANSACTIONS_PUB.CREATE_MOVE_ORDER_LINE
		  (p_api_version            => l_api_version_number
		  ,p_Init_Msg_List          => FND_API.G_FALSE
		  ,p_commit                 => FND_API.G_FALSE
		  ,px_line_id               => lx_line_id
		  ,p_header_id              => l_move_order_id
		  ,p_organization_id        => p_organization_id
		  ,p_from_subinventory_code => p_from_subinventory_code
		  ,p_from_locator_id        => l_locator_id_from
		  ,p_inventory_item_id      => p_inventory_item_id
		  ,p_revision               => l_revision
		  ,p_lot_number             => l_lot_number
		  ,p_serial_number_start    => l_sr_number_start
		  ,p_serial_number_end      => l_sr_number_end
		  ,p_quantity               => p_quantity
		  ,p_uom_code               => p_uom_code
		  ,p_quantity_delivered     => null
		  ,p_to_subinventory_code   => p_to_subinventory_code
		  ,p_to_locator_id          => l_locator_id_to
		  ,p_to_organization_id     => p_organization_id
		  ,p_service_request        => null
		  ,p_task_id                => null
		  ,p_task_assignment_id     => null
		  ,p_customer_po            => null
		  ,p_date_required          => l_date_required
		  ,p_comments               => p_comments
		  ,x_return_status          => l_return_status
		  ,x_msg_count              => l_msg_count
		  ,x_msg_data               => l_msg_data ) ;


	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      -- bug # 5171584
      fnd_msg_pub.get
        ( p_msg_index     => l_msg_count
        , p_encoded       => FND_API.G_FALSE
        , p_data          => x_msg_data
        , p_msg_index_out => l_msg_count2
        );

		RAISE FND_API.G_EXC_ERROR;
	ELSE
		x_return_status := FND_API.G_RET_STS_SUCCESS ;
		COMMIT WORK;
		open c_REQUEST_NUMBER(l_move_order_id);
		fetch c_REQUEST_NUMBER into x_move_order_number;
		close c_REQUEST_NUMBER;
	END IF;

END IF;

 EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

END CREATE_MOVE_ORDER;


PROCEDURE TRANSACT_MOVE_ORDER
(  p_type_of_transaction IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_organization_id   IN NUMBER,
   p_source_sub        IN VARCHAR2,
   p_source_locator    IN NUMBER,
   p_lot               IN VARCHAR2,
   p_revision          IN VARCHAR2,
   p_serial_number     IN VARCHAR2,
   p_qty               IN NUMBER,
   p_uom               IN VARCHAR2,
   p_line_id           IN NUMBER,
   p_dest_sub          IN VARCHAR2,
   p_dest_org_id       IN NUMBER,       -- this will be same as p_organization_id in case of move order
   p_dest_locator      IN NUMBER,
   p_waybill           IN VARCHAR2,
   p_ship_Nr           IN VARCHAR2,
   p_freight_code      IN VARCHAR2,
   p_exp_del_date      IN VARCHAR2
  ,x_return_status          OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2 ) IS

 l_txn_type_id number;
 l_transaction_id          number;
 l_transaction_header_id   number;
 l_msg_count               number;
 l_msg_data                varchar2(4000);
 l_return_status           varchar2(1);
 l_source_locator    NUMBER;
 l_lot               VARCHAR2(100);
 l_revision          VARCHAR2(100);
 l_serial_number     VARCHAR2(100);
 l_dest_locator      NUMBER;
 l_api_name          CONSTANT VARCHAR2(30) := 'CSFW.Transact_Move_Order';
 EXCP_USER_DEFINED   EXCEPTION;

BEGIN
	if (p_source_locator = 0) THEN
		l_source_locator := null;
	else
		l_source_locator := p_source_locator;
	end if;


	if (p_lot = '') THEN
		l_lot := null;
	else
		l_lot := p_lot;
	end if;

	if (p_revision = '') THEN
		l_revision := null;
	else
		l_revision := p_revision;
	end if;

	if (p_serial_number = '') THEN
		l_serial_number := null;
	else
		l_serial_number := p_serial_number;
	end if;

	if (p_dest_locator = 0) THEN
		l_dest_locator := null;
	else
		l_dest_locator := p_dest_locator;
	end if;

	if (p_type_of_transaction = 'MOVE_ORDER') THEN
		l_txn_type_id := 64;
   else
      l_txn_type_id := to_number(p_type_of_transaction);
	end if;


	-- CALL THE API
	  csp_transactions_pub.TRANSACT_MATERIAL
	  (p_api_version                => 1.0
	  ,px_transaction_id            => l_transaction_id
	  ,px_transaction_header_id     => l_transaction_header_id
	  ,p_inventory_item_id          => p_inventory_item_id
	  ,p_organization_id            => p_organization_id
	  ,p_subinventory_code          => p_source_sub
	  ,p_locator_id                 => l_source_locator
	  ,p_lot_number                 => l_lot
	  ,p_lot_expiration_date        => null
	  ,p_revision                   => l_revision
	  ,p_serial_number              => l_serial_number
	  ,p_to_serial_number           => null
	  ,p_quantity                   => p_qty
	  ,p_uom                        => p_uom
	  ,p_source_id                  => null
	  ,p_source_line_id             => p_line_id
	  ,p_transaction_type_id        => l_txn_type_id
	  ,p_account_id                 => null
	  ,p_transfer_to_subinventory   => p_dest_sub
	  ,p_transfer_to_locator        => l_dest_locator
	  ,p_transfer_to_organization   => p_dest_org_id
	  ,p_online_process_flag        => TRUE
	  ,p_transaction_source_id      => null
	  ,p_trx_source_line_id         => null
	  ,p_transaction_source_name	=> null
	  ,p_waybill_airbill		=> p_waybill
	  ,p_shipment_number    	=> p_ship_Nr
	  ,p_freight_code		=> p_freight_code
	  ,p_reason_id			=> null
	  ,p_transaction_reference      => null
     ,p_transaction_date           => sysdate()
     ,p_expected_delivery_date     => to_date(p_exp_del_date,'YYYY-MM-DD')
	  ,x_return_status              => l_return_status
	  ,x_msg_count                  => x_msg_count
	  ,x_msg_data                   => l_msg_data);

	-- Bug 5465343: returning messages from TRANSACT_MATERIAL
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    x_return_status := l_return_status;
	    x_msg_count := l_msg_count;
	    x_msg_data := l_msg_data;
	    RAISE FND_API.G_EXC_ERROR;
	ELSE
		x_return_status := FND_API.G_RET_STS_SUCCESS ;
		x_msg_count := 0;
		x_msg_data := 'Success';
	END IF;

 EXCEPTION
 WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END TRANSACT_MOVE_ORDER;



PROCEDURE RECEIVE_HEADER
(p_header_id in NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2 )IS


receiveRec csp_receive_pvt.rcv_rec_tbl_type;
hdrrec csp_receive_pvt.rcv_hdr_rec_type;

--x_return_status varchar2(1);
--x_msg_count   number;
--x_msg_data    varchar2(2000);
x_message                 VARCHAR2(2000);
i number := 0;
l_api_name                CONSTANT VARCHAR2(30) := 'CSFW:receive_shipments';

cursor c_hdr (v_header_id number ) IS
	select * from csp_receive_headers_v
	where RCV_SHIPMENT_HEADER_ID = v_header_id;
rcvhdrrec c_hdr%rowtype;

cursor c_lines  (v_header_id number ) IS
	select * from csp_receive_lines_v
	where RCV_SHIPMENT_HEADER_ID = v_header_id;
linesrec c_lines%rowtype;

BEGIN

--First LETS GET THE HEADERS
OPEN c_hdr(p_header_id);
FETCH c_hdr into rcvhdrrec;
CLOSE c_hdr;

-- LETS POPULATE THE HEADER REC
hdrrec.header_interface_id      := null;
hdrrec.group_id                 := null;
hdrrec.source_type_code         := rcvhdrrec.source_type_code;
hdrrec.receipt_source_code      := rcvhdrrec.receipt_source_code;
hdrrec.vendor_id                := rcvhdrrec.vendor_id;
hdrrec.vendor_site_id           := rcvhdrrec.vendor_site_id;
hdrrec.ship_to_org_id           := rcvhdrrec.ship_to_organization_id;
hdrrec.rcv_shipment_num         := rcvhdrrec.rcv_shipment_number;
hdrrec.receipt_header_id        := rcvhdrrec.rcv_shipment_header_id;
hdrrec.receipt_num              := null;
hdrrec.bill_of_lading           := rcvhdrrec.bill_of_lading;
hdrrec.packing_slip             := rcvhdrrec.packing_slip;
hdrrec.shipped_date             := rcvhdrrec.shipped_date;
hdrrec.freight_carrier_code     := rcvhdrrec.freight_carrier_code;
hdrrec.expected_receipt_date    := rcvhdrrec.expected_receipt_date;
hdrrec.employee_id              := null;
hdrrec.waybill_airbill_num      := rcvhdrrec.waybill_airbill_num;
hdrrec.usggl_transaction_code   := rcvhdrrec.ussgl_transaction_code;
hdrrec.processing_request_id    := null;
hdrrec.customer_id              := null;
hdrrec.customer_site_id         := null;
--Now for this header id lets find all the lines

for linesrec in c_lines(p_header_id) loop
	i := i + 1;
	receiveRec(i).product_code                  := 'RCV';
	receiveRec(i).source_type_code              := linesrec.source_type_code;
	receiveRec(i).order_type_code               := linesrec.order_type_code;
	receiveRec(i).item_id                       := linesrec.item_id;
	receiveRec(i).item_revision                 := linesrec.item_revision;
	receiveRec(i).item_category_id              := linesrec.item_category_id;
	receiveRec(i).item_description              := linesrec.item_description;
	receiveRec(i).from_organization_id          := linesrec.from_organization_id;
	receiveRec(i).ordered_qty                   := linesrec.ordered_qty;
	receiveRec(i).ordered_uom                   := linesrec.ordered_uom;
	receiveRec(i).serial_number_control_code    := linesrec.serial_number_control_code;

	if (linesrec.SERIAL_NUM IS NOT NULL ) then
		receiveRec(i).transaction_quantity  := 1;
	else
		receiveRec(i).transaction_quantity  := linesrec.transaction_qty;
	end if;

	receiveRec(i).transaction_uom               := linesrec.primary_uom;
	receiveRec(i).rcv_shipment_header_id        := linesrec.rcv_shipment_header_id;
	receiveRec(i).rcv_shipment_line_id          := linesrec.rcv_shipment_line_id;
	receiveRec(i).po_header_id                  := linesrec.po_header_id;
	receiveRec(i).po_line_id                    := linesrec.po_line_id;
	receiveRec(i).po_line_location_id           := linesrec.po_line_location_id;
	receiveRec(i).req_line_id                   := linesrec.req_line_id;
	receiveRec(i).oe_order_header_id            := linesrec.oe_order_header_id;
	receiveRec(i).oe_order_line_id              := linesrec.oe_order_line_id;
	receiveRec(i).receipt_source_code           := linesrec.receipt_source_code;
	receiveRec(i).po_release_id                 := linesrec.po_release_id;
	receiveRec(i).po_distribution_id            := linesrec.po_distribution_id;
	receiveRec(i).lot_number                    := linesrec.lot_num;
	receiveRec(i).lot_control_code              := linesrec.lot_control_code;
	receiveRec(i).vendor_id                     := linesrec.vendor_id;
	receiveRec(i).vendor_site_id                := linesrec.vendor_site_id;
	receiveRec(i).fm_serial_number              := linesrec.serial_num;
	receiveRec(i).to_serial_number              := linesrec.serial_num;
	receiveRec(i).vendor_lot_number             := linesrec.vendor_lot_num;
	receiveRec(i).to_organization_id            := linesrec.to_organization_id;
	receiveRec(i).destination_subinventory      := linesrec.destination_subinventory;
	receiveRec(i).destination_type_code         := linesrec.destination_type_code;
	receiveRec(i).routing_id                    := linesrec.routing_id;
	receiveRec(i).ship_to_location_id           := linesrec.ship_to_location_id;
	receiveRec(i).enforce_ship_to_location_code := linesrec.enforce_ship_to_location_code;
	receiveRec(i).SET_OF_BOOKS_ID_SOB           := linesrec.set_of_books_id_sob;
	receiveRec(i).CURRENCY_CODE_SOB             := linesrec.currency_code_sob;
	receiveRec(i).lot_primary_quantity          := linesrec.lot_primary_quantity;
	receiveRec(i).lot_quantity                  := linesrec.lot_quantity;
	receiveRec(i).locator_id                    := null;
	receiveRec(i).interface_transaction_id      := null;
	receiveRec(i).transaction_interface_id      := null;
	receiveRec(i).header_interface_id           := null;
	receiveRec(i).group_id                      := null;
	receiveRec(i).primary_quantity              := null;
	receiveRec(i).primary_uom                   := linesrec.primary_uom;
	receiveRec(i).primary_uom_class             := linesrec.primary_uom_class;
	receiveRec(i).expiration_date               := null;
	receiveRec(i).status_id                     := null;
	receiveRec(i).product_transaction_id        := null;
	receiveRec(i).att_exist                     := null;
	receiveRec(i).update_mln                    := null;
	receiveRec(i).description                   := null;
	receiveRec(i).vendor_name                   := null;
	receiveRec(i).supplier_lot_number           := null;
	receiveRec(i).origination_date              := null;
	receiveRec(i).date_code                     := null;
	receiveRec(i).grade_code                    := null;
	receiveRec(i).change_date                   := null;
	receiveRec(i).maturity_date                 := null;
	receiveRec(i).retest_date                   := null;
	receiveRec(i).age                           := null;
	receiveRec(i).item_size                     := null;
	receiveRec(i).color                         := null;
	receiveRec(i).volume                        := null;
	receiveRec(i).volume_uom                    := null;
	receiveRec(i).place_of_origin               := null;
	receiveRec(i).best_by_date                  := null;
	receiveRec(i).length                        := null;
	receiveRec(i).length_uom                    := null;
	receiveRec(i).recycled_content              := null;
	receiveRec(i).thickness                     := null;
	receiveRec(i).thickness_uom                 := null;
	receiveRec(i).width                         := null;
	receiveRec(i).width_uom                     := null;
	receiveRec(i).curl_wrinkle_fold             := null;
	receiveRec(i).territory_code                := null;
	receiveRec(i).update_msn                    := null;
	receiveRec(i).vendor_serial_number          := null;
	receiveRec(i).parent_serial_number          := null;
	receiveRec(i).time_since_new                := null;
	receiveRec(i).cycles_since_new              := null;
	receiveRec(i).time_since_overhaul           := null;
	receiveRec(i).cycles_since_overhaul         := null;
	receiveRec(i).time_since_repair             := null;
	receiveRec(i).cycles_since_repair           := null;
	receiveRec(i).time_since_visit              := null;
	receiveRec(i).cycles_since_visit            := null;
	receiveRec(i).time_since_mark               := null;
	receiveRec(i).cycles_since_mark             := null;
	receiveRec(i).number_of_repairs             := null;
	receiveRec(i).employee_id                   := null;
end loop;
--Now Lets Call The API
csp_receive_pvt.receive_shipments
(P_Api_Version_Number => 1.0
 ,P_init_Msg_List     => FND_API.G_TRUE
 ,P_Commit            => FND_API.G_TRUE
 ,P_Validation_Level  => FND_API.G_VALID_LEVEL_FULL
 ,p_receive_hdr_rec   => hdrrec
 ,p_receive_rec_tbl   => receiveRec
 ,X_Return_Status     => x_return_status
 ,X_Msg_Count         => x_msg_count
 ,X_Msg_Data          => x_msg_data);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := x_return_status;
	x_msg_data := x_Msg_Data;
	if x_msg_count > 0 THEN
		FOR l_counter IN 1 .. x_msg_count
		LOOP
			fnd_msg_pub.get
			( p_msg_index     => l_counter
			, p_encoded       => FND_API.G_FALSE
			, p_data          => x_msg_data
			, p_msg_index_out => x_msg_count
			);
		END  LOOP;
	--dbms_output.put_line(x_error_msg || 'API error');
	end if;
  END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
      	x_return_status := FND_API.G_RET_STS_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MESSAGE
              ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MESSAGE
               ,X_RETURN_STATUS => X_RETURN_STATUS);
        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        JTF_PLSQL_API.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => JTF_PLSQL_API.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => JTF_PLSQL_API.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MESSAGE
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END RECEIVE_HEADER;

END CSFW_ORDER_PARTS;

/
