--------------------------------------------------------
--  DDL for Package Body AHL_OSP_SHIPMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_OSP_SHIPMENT_PUB" AS
  /* $Header: AHLPOSHB.pls 120.31.12010000.3 2010/04/12 23:14:17 jaramana ship $ */

  G_PKG_NAME            CONSTANT  VARCHAR2(30) := 'Ahl_OSP_Shipment_Pub';
  G_APP_NAME            CONSTANT  VARCHAR2(3)  := 'AHL';
  G_LOG_PREFIX          CONSTANT  VARCHAR2(100) := 'ahl.plsql.AHL_OSP_SHIPMENT_PUB';

  /** IB Transaction Related constants **/
  -- Ship-only transaction type
  G_OM_ORDER            CONSTANT  VARCHAR2(30) := 'OM_SHIPMENT';
  -- Return transaction type
  G_OM_RETURN           CONSTANT  VARCHAR2(30) := 'RMA_RECEIPT';
  -- Transaction sub type for Ship-only lines (Service, Loan and Borrow)
  --G_SUBTXN_ORDER        CONSTANT  VARCHAR2(30) := 'Ship Loaner';
  -- Transaction sub type for Return lines (Service, Loan and Borrow)
  --G_SUBTXN_RETURN       CONSTANT  VARCHAR2(30) := 'Return for Repair';
  -- Transaction sub type for Exchange order's Ship-only lines
  --G_SUBTXN_EXC_ORDER    CONSTANT  VARCHAR2(30) := 'Ship Replacement';
  -- Transaction sub type for Exchange order's Return lines
  --G_SUBTXN_EXC_RETURN   CONSTANT  VARCHAR2(30) := 'Return for Replacement';
  -- Source transaction table
  G_TRANSACTION_TABLE   CONSTANT  VARCHAR2(30) := 'OE_ORDER_LINES_ALL';
  G_CSI_T_SOURCE_LINE_REF CONSTANT  VARCHAR2(50) := 'AHL_OSP_ORDER_LINES';


   x_header_rec                    OE_ORDER_PUB.Header_Rec_Type;
   x_header_val_rec                OE_ORDER_PUB.Header_Val_Rec_Type;
   x_Header_Adj_tbl                OE_ORDER_PUB.Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl            OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl          OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl            OE_ORDER_PUB.Header_Adj_Att_Tbl_Type ;
   x_Header_Adj_Assoc_tbl          OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl            OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl        OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                      OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl                  OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl                  OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl              OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl            OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl              OE_ORDER_PUB.Line_Adj_Att_Tbl_Type ;
   x_Line_Adj_Assoc_tbl            OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl              OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl          OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl                OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl            OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	           OE_ORDER_PUB.Request_Tbl_Type;

------------------------------
-- Declare Local Procedures --
------------------------------

PROCEDURE Convert_Header_Rec(
	p_header_rec     IN  AHL_OSP_SHIPMENT_PUB.SHIP_HEADER_REC_TYPE,
	p_module_type    IN            VARCHAR2 ,
        x_header_rec     OUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE,
	x_header_val_rec OUT NOCOPY OE_ORDER_PUB.HEADER_VAL_REC_TYPE);

PROCEDURE Convert_Line_Tbl(
	p_line_tbl       IN AHL_OSP_SHIPMENT_PUB.SHIP_LINE_TBL_TYPE,
	p_module_type    IN            VARCHAR2 ,
	x_line_tbl       OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE,
	x_line_val_tbl   OUT NOCOPY OE_ORDER_PUB.LINE_VAL_TBL_TYPE,
	x_lot_serial_tbl OUT NOCOPY OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE,
    x_del_oe_lines_tbl OUT NOCOPY SHIP_ID_TBL_TYPE);

PROCEDURE Process_Line_Tbl(
        p_osp_order_id     IN NUMBER,
        p_operation_flag   IN VARCHAR,
        p_module_type    IN            VARCHAR2,
	p_x_line_tbl       IN OUT NOCOPY  AHL_OSP_SHIPMENT_PUB.SHIP_LINE_TBL_TYPE );

PROCEDURE Update_OSP_Order(
	p_osp_order_id   IN NUMBER,
        p_oe_header_id   IN NUMBER
       );

PROCEDURE Delete_OSP_Order(
        p_oe_header_id   IN NUMBER
       );

PROCEDURE Update_OSP_Order_Lines(
	p_osp_order_id  IN NUMBER,
      	p_item_instance_id   IN NUMBER,
        p_oe_ship_line_id       IN NUMBER,
        p_oe_return_line_id     IN NUMBER
       );


PROCEDURE Update_OSP_Order_Lines(
	p_osp_order_id  IN NUMBER,
	p_osp_line_id   IN NUMBER,
        p_oe_ship_line_id       IN NUMBER,
        p_oe_return_line_id     IN NUMBER
       );

-- yazhou 10-Apr-2006 starts
-- Bug fix #4998349

PROCEDURE Update_OSP_Line_Exch_Instance(
	p_osp_order_id   IN NUMBER,
    p_osp_line_id    IN NUMBER,
    p_exchange_instance_id   IN NUMBER
      );
-- yazhou 10-Apr-2006 ends

PROCEDURE Delete_OE_Lines(p_oe_line_id       IN NUMBER);

--Commented by mpothuku on 05-Feb-2007 to implement the Osp Receiving ER
/*
-- Create IB Sub transaction for a order line based on osp_order_type and
-- line type.
PROCEDURE Create_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_OSP_order_type         IN            VARCHAR2,
    p_oe_line_type           IN            VARCHAR2,
    p_oe_line_id             IN            NUMBER,
    p_csi_instance_id        IN            NUMBER);


-- Delete IB sub transaction for a shipment line.
PROCEDURE Delete_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_oe_line_id             IN            NUMBER);
*/
--mpothuku End

PROCEDURE Convert_Ship_Only_Lines(
    p_osp_order_id        IN         NUMBER,
    p_old_order_type_code IN         VARCHAR2,
    p_new_order_type_code IN         VARCHAR2);

FUNCTION GET_INSTANCE_NUM_FROM_ID(p_instance_id IN NUMBER )
   RETURN VARCHAR2;
FUNCTION get_user_profile_option_name(p_profile_option_name IN VARCHAR2 )
   RETURN VARCHAR2;

/***********************************************************************
Local Procedures for usage of the Process_Osp_SerialNum_Change API
************************************************************************/
--------------------------------------------------------
-- Procedure to return lookup code  given the meaning --
--------------------------------------------------------
PROCEDURE Convert_To_LookupCode (p_lookup_type     IN   VARCHAR2,
                                 p_lookup_meaning  IN   VARCHAR2,
                                 x_lookup_code     OUT  NOCOPY VARCHAR2,
                                 x_return_val      OUT  NOCOPY BOOLEAN)  IS

	CURSOR fnd_lookup_csr (p_lookup_type     IN  VARCHAR2, p_lookup_meaning  IN  VARCHAR2)  IS
	SELECT lookup_code
	  FROM fnd_lookup_values_vl
	 WHERE lookup_type = p_lookup_type
	   AND meaning = p_lookup_meaning
	   AND TRUNC(SYSDATE) >= TRUNC(NVL(start_date_active, SYSDATE))
	   AND TRUNC(SYSDATE) < TRUNC(NVL(end_date_active, SYSDATE+1));

	l_lookup_code   fnd_lookups.lookup_code%TYPE DEFAULT NULL;
	l_return_val    BOOLEAN  DEFAULT  TRUE;

  BEGIN

	OPEN fnd_lookup_csr(p_lookup_type, p_lookup_meaning);
	FETCH  fnd_lookup_csr INTO l_lookup_code;
	IF (fnd_lookup_csr%NOTFOUND) THEN
		l_return_val := FALSE;
		l_lookup_code := NULL;
	END IF;
	CLOSE fnd_lookup_csr;

	 x_lookup_code := l_lookup_code;
	 x_return_val  := l_return_val;

END  Convert_To_LookupCode;
--
PROCEDURE Validate_SerialNumber(p_Inventory_id           IN  NUMBER,
                                p_Serial_Number          IN  VARCHAR2,
                                p_serial_number_control  IN  NUMBER,
                                p_serialnum_tag_code     IN  VARCHAR2,
                                p_concatenated_segments  IN  VARCHAR2) IS

  CURSOR mtl_serial_numbers_csr(c_Inventory_id  IN  NUMBER,
                                c_Serial_Number IN  VARCHAR2) IS
  SELECT 1
    FROM mtl_serial_numbers
   WHERE inventory_item_id = c_Inventory_id
     AND Serial_Number = c_Serial_Number;

  l_junk       VARCHAR2(1);

BEGIN

  -- Validate serial number.(1 = No serial number control; 2 = Pre-defined;
  --                         3 = Dynamic Entry at inventory receipt.)
  IF (nvl(p_serial_number_control,0) IN (2,5,6)) THEN
    -- serial number is mandatory.
    IF (p_Serial_Number IS NULL) OR (p_Serial_Number = FND_API.G_MISS_CHAR) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_NULL');
        FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Serial Number is null');
    /*
    ELSE
        -- If serial tag code = INVENTORY  then validate serial number against inventory.
        IF (p_serialnum_tag_code = 'INVENTORY') THEN
          OPEN  mtl_serial_numbers_csr(p_Inventory_id,p_Serial_Number);
          FETCH mtl_serial_numbers_csr INTO l_junk;
          IF (mtl_serial_numbers_csr%NOTFOUND) THEN
             FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_INVALID');
             FND_MESSAGE.Set_Token('SERIAL',p_Serial_Number);
             FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
             FND_MSG_PUB.ADD;
             --dbms_output.put_line('Serial Number does not exist in master ');
          END IF;
          CLOSE mtl_serial_numbers_csr;
        END IF;
    */
    END IF;
  ELSE
     -- if not serialized item, then serial number must be null.
     IF (p_Serial_Number <> FND_API.G_MISS_CHAR) AND (p_Serial_Number IS NOT NULL) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_SERIAL_NOTNULL');
        FND_MESSAGE.Set_Token('SERIAL',p_Serial_Number);
        FND_MESSAGE.Set_Token('INV_ITEM',p_concatenated_segments);
        FND_MSG_PUB.ADD;
        --dbms_output.put_line('Serial Number is not null');
     END IF;

  END IF; /* for serial number control */
END Validate_SerialNumber;

/***********************************************************************
End Local Procedures for usage of the Process_Osp_SerialNum_Change API
************************************************************************/

------------------------
-- Define Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Process_Order
--  Type              : Public
--  Function          : For one Shipment Header and a set of Shipment
-- Lines, call 1) SO API 2) Update IB with IB trxns.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT NOCOPY Parameters :
--      x_return_status                 OUT NOCOPY      VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY      NUMBER               Required
--      x_msg_data                      OUT NOCOPY      VARCHAR2             Required
--
--  Process Order Parameters:
--       p_x_Header_rec          IN OUT NOCOPY  Ship_Header_rec_type    Required
--         All parameters for SO Shipment Header
--       p_x_Lines_tbl        IN OUT NOCOPY  ship_line_tbl_type   Required
--         List of all parameters for shipment lines
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_x_header_rec         IN OUT NOCOPY    AHL_OSP_SHIPMENT_PUB.Ship_Header_Rec_Type,
    p_x_lines_tbl 	   IN OUT NOCOPY    AHL_OSP_SHIPMENT_PUB.Ship_Line_Tbl_Type,
    x_return_status         OUT NOCOPY            VARCHAR2,
    x_msg_count             OUT NOCOPY            NUMBER,
    x_msg_data              OUT NOCOPY            VARCHAR2)
IS

-- yazhou 07-Aug-2006 starts
-- bug fix#5448191
-- Find all the OSP lines with no shipments associated, while for the same physical item
-- other OSP lines do have shipments associated

CURSOR ahl_osp_line_no_ship_csr(p_osp_order_id IN NUMBER) IS

Select osp_order_line_id,
       OSP_LINE_NUMBER,
       inventory_item_id,
       inventory_org_id,
       serial_number
from AHL_OSP_ORDER_LINES a
where OSP_ORDER_ID = p_osp_order_id
/* Modified by jaramana on January 11, 2008 to fix the Bug 5688387/5842229
changed the "and" operation in the line below to "Or" */
and (oe_ship_line_id is null or oe_return_line_id is null)
and serial_number is not null
and exists (select 1
            from ahl_osp_order_lines
            where osp_order_id = p_osp_order_id
            and inventory_item_id = a.inventory_item_id
            and inventory_org_id = a.inventory_org_id
            and serial_number = a.serial_number
            and (oe_ship_line_id is not null
             or  oe_return_line_id is not null)
             /* Modified by jaramana on January 11, 2008 to fix the Bug 5688387/5842229. Apart from a.osp_order_line_id we need
             another line that exists with the same item and serial */
            and osp_order_line_id <> a.osp_order_line_id);

l_osp_line_no_ship_type ahl_osp_line_no_ship_csr%rowtype;

CURSOR ahl_osp_line_ship_id_csr(p_osp_order_id IN NUMBER, p_inventory_item_id IN NUMBER, p_inventory_org_id IN NUMBER,
p_serial_number IN VARCHAR2) IS

--Modified by jaramana on January 11, 2008 to fix the new issue raised by AE in the Bug 5688387/5842229
Select distinct nvl(oe_ship_line_id,-1) oe_ship_line_id, nvl(oe_return_line_id,-1) oe_return_line_id
from AHL_OSP_ORDER_LINES a
where OSP_ORDER_ID = p_osp_order_id
and (oe_ship_line_id is not null
     or oe_return_line_id is not null)
and inventory_item_id = p_inventory_item_id
and inventory_org_id = p_inventory_org_id
and serial_number = p_serial_number
order by 1, 2 desc;

l_osp_line_ship_id_type ahl_osp_line_ship_id_csr%rowtype;

--mpothuku modified on 14-Sep-2007 to fix the Bug 6398921
CURSOR is_oe_item_IB_tracked(c_oe_line_id IN NUMBER, c_oe_org_id IN NUMBER) IS
SELECT 1
  FROM mtl_system_items_b mtl,
       oe_order_lines_all oel
 WHERE oel.line_id = c_oe_line_id
   AND mtl.inventory_item_id = oel.inventory_item_id
   AND mtl.organization_id =  c_oe_org_id
   AND nvl(mtl.comms_nl_trackable_flag,'N') = 'Y' ;
--mpothuku End


-- yazhou 07-Aug-2006 ends

--
  l_api_name       CONSTANT VARCHAR2(30)  := 'Process_Order';
  l_api_version    CONSTANT NUMBER        := 1.0;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_Order';


   l_header_rec 		   OE_ORDER_PUB.header_rec_type;
   l_line_tbl 			   OE_ORDER_PUB.line_tbl_type;
   l_header_val_rec        OE_ORDER_PUB.header_val_rec_type;
   l_line_val_tbl          OE_ORDER_PUB.line_val_tbl_type;
   l_lot_serial_tbl        OE_ORDER_PUB.lot_serial_tbl_type;
   l_del_oe_lines_tbl      SHIP_ID_TBL_TYPE;
   l_osp_order_id          NUMBER;
   l_line_type             VARCHAR2(80);
   l_msg_data              VARCHAR2(2000);
   l_msg_index_out         NUMBER;
   l_msg_count             NUMBER;
   l_dummy                 NUMBER;
--
BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Process_Order_Pub;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Start processing

  IF (FND_PROFILE.VALUE('AHL_OSP_OE_MIXED_ID') IS NULL OR FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID') = '') THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
    --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: OE Mixed Order Type ID');
    FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_OE_MIXED_ID'));
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  IF (FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID') IS NULL OR FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID') = '' ) THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
    --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: OE Ship Only Line Type ID');
    FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_OE_SHIP_ONLY_ID'));
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  IF (FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID') IS NULL OR FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID') = '') THEN
    FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
    --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: OE Return Line Type ID');
    FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_OE_RETURN_ID'));
    FND_MSG_PUB.ADD;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Got profile values, About to Convert_Header_rec');
  END IF;

  Convert_Header_rec(p_header_rec  => p_x_header_rec,
                     p_module_type => p_module_type,
                     x_header_rec  => l_header_rec,
                     x_header_val_rec => l_header_val_rec );

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Convert_Header_rec, About to Process_Line_Tbl');
  END IF;

  Process_Line_Tbl(p_osp_order_id => p_x_header_rec.osp_order_id,
                   p_operation_flag => p_x_header_rec.operation,
  	           p_module_type => p_module_type,
                   p_x_line_tbl  => p_x_lines_tbl);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Process_Line_Tbl, About to Convert_Line_Tbl');
  END IF;

  Convert_Line_Tbl(p_line_tbl  => p_x_lines_tbl,
                   p_module_type => p_module_type,
                   x_line_tbl  => l_line_tbl,
                   x_line_val_tbl => l_line_val_tbl,
                   x_lot_serial_tbl => l_lot_serial_tbl,
                   x_del_oe_lines_tbl => l_del_oe_lines_tbl  -- Additional Parameter to get the lines to be deleted
                   );

  /*
  Added by jaramana on January 11, 2008 to raise any validation errors that may have been accumulated by the AHL_OSP_ORDERS_PVT procedure
  We do not have any warning messages hence if the message count is > 0 then it means there are validation errors and since
  we call a Public API in this procedure, its better we throw the error here itself.
  */
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error Count Before calling OE_ORDER_GRP.PROCESS_ORDER: '||l_msg_count);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- jaramana End

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Convert_Line_Tbl, About to OE_ORDER_GRP.PROCESS_ORDER');
  END IF;

  --OE_ORDER_GRP uses its own message stack OE_MSG_PUB, so we should pass p_init_msg_list as true to this API
  --Note that this also does an FND_MSG_PUB.initialize along with clearing its own error stack
  OE_ORDER_GRP.PROCESS_ORDER(
    p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_header_rec	      => l_header_rec,
    p_header_val_rec      => l_header_val_rec,
    p_line_tbl            => l_line_tbl,
    p_line_val_tbl        => l_line_val_tbl,
    p_lot_serial_tbl      => l_lot_serial_tbl,
    x_header_rec          => x_header_rec,
    x_header_val_rec      => x_header_val_rec,
    x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
    x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
    x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
    x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
    x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
    x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
    x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
    x_line_tbl               =>     x_line_tbl      ,
    x_line_val_tbl           =>    x_line_val_tbl ,
    x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
    x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
    x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
    x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
    x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
    x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
    x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
    x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
    x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
    x_action_request_tbl     => x_action_request_tbl  );


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed OE_ORDER_GRP.PROCESS_ORDER, x_return_status = ' || x_return_status);
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FOR i IN 1..x_msg_count LOOP
      OE_MSG_PUB.Get(p_msg_index => i,
                     p_encoded => FND_API.G_FALSE,
                     p_data    => l_msg_data,
                     p_msg_index_out => l_msg_index_out);
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                              p_procedure_name => 'processOrder',
                              p_error_text     => substr(l_msg_data,1,240));
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
      END IF;

    END LOOP;
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  /*
  Modified by jaramana on January 11, 2008 to fix the Bug 5935388/6504122
  If success is returned by the Public API, clear the message stack to eat up any warning messages from OM API.
  Otherwise, OAExceptionUtils.checkErrors will consider these as errors.
  Also note that had there been any validation errors that had been accumulated we would have thrown before the call to
  OE_ORDER_GRP.PROCESS_ORDER
  */

  ELSIF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
        FND_MSG_PUB.get (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'OE: Warning ' || i || ': ' || l_msg_data);
      END LOOP;
    END IF;
    FND_MSG_PUB.Initialize;
  -- jaramana End
  END IF;

  IF (p_x_header_rec.operation = 'C') THEN
    p_x_header_rec.header_id := x_header_rec.header_id;

    --Update AHL_OSP_ORDERS tables with ids/new id
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Update_OSP_Order');
    END IF;
    Update_OSP_Order(p_osp_order_id => p_x_header_rec.osp_order_id,
                     p_oe_header_id => p_x_header_rec.header_id );
  ELSIF (p_x_header_rec.operation = 'D') THEN
     --Update AHL_OSP_ORDERS/OSP_ORDER_LINES tables with ids/new id
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_OSP_Order');
    END IF;
    Delete_OSP_Order(p_oe_header_id => p_x_header_rec.header_id);
  END IF;

  -- Handle Shipment Line Deletions
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_del_oe_lines_tbl.COUNT = ' || l_del_oe_lines_tbl.COUNT);
  END IF;
  IF (l_del_oe_lines_tbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_Cancel_Order');
    END IF;
    Delete_Cancel_Order (
          p_api_version              => 1.0,
          p_init_msg_list            => FND_API.G_FALSE, -- Don't initialize the Message List
          p_commit                   => FND_API.G_FALSE, -- Don't commit independently
          p_oe_header_id             => null,  -- Not deleting the shipment header: Only the lines
          p_oe_lines_tbl             => l_del_oe_lines_tbl,  -- Lines to be deleted/Cancelled
          p_cancel_flag              => FND_API.G_FALSE,  -- Do Deletes if possible, Cancels if not
          x_return_status            => x_return_status ,
          x_msg_count                => x_msg_count ,
          x_msg_data                 => x_msg_data
      );
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from Delete_Cancel_Order, x_return_status = ' || x_return_status);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;   -- Delete Line Count > 0

  -- Handle New Shipment Lines
  IF (p_x_lines_tbl.COUNT > 0) THEN
    FOR i IN p_x_lines_tbl.FIRST..p_x_lines_tbl.LAST  LOOP
      IF (p_x_lines_tbl(i).operation = 'C') THEN
        -- Update the line_id
        p_x_lines_tbl(i).line_id := x_line_tbl(i).line_id;
        IF (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
          l_line_type := 'ORDER';
        ELSIF (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
          l_line_type := 'RETURN';
        END IF;

        IF p_x_lines_tbl(i).csi_item_instance_id IS NOT NULL THEN

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Create_IB_Transaction');
          END IF;
        /*
           Modified by jaramana on January 11, 2008 for fixing the Bug 5935388/6504122
           The "Create Shipment" action passes p_init_msg_list as TRUE as it is the starting point.
           p_init_msg_list is passed as FALSE otherwise. So the "Create Shipment" action is flushing the
           warning messages generated by OE_ORDER_GRP.PROCESS_ORDER. So the shipment is created without
           any errors (Warning converted to errors by OAExceptionUtils.checkErrors in the absence of
           certain tokens).
        */
          Create_IB_Transaction(
              p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
              p_commit                => p_commit,
              p_validation_level      => p_validation_level,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
              p_osp_order_type        => p_x_lines_tbl(i).order_type,
              p_oe_line_type          => l_line_type,
              p_oe_line_id            => p_x_lines_tbl(i).line_id,
              p_csi_instance_id       => p_x_lines_tbl(i).csi_item_instance_id);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status from Create_IB_Transaction: ' || x_return_status);
          END IF;
          IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          --Update OSP Order Lines with the new line_id
          --FIX LINE TYPE ID validation

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Update_OSP_Order_Lines');
          END IF;
          IF (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
            Update_OSP_Order_Lines(
                p_osp_order_id      => p_x_lines_tbl(i).osp_order_id,
                p_item_instance_id  => p_x_lines_tbl(i).csi_item_instance_id,
                p_oe_ship_line_id   => p_x_lines_tbl(i).line_id,
                p_oe_return_line_id  =>  FND_API.G_MISS_NUM);
          ELSIF  (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling Update_OSP_Order_Lines with p_oe_return_line_id = ' || p_x_lines_tbl(i).line_id );
            END IF;
            Update_OSP_Order_Lines(
                p_osp_order_id      => p_x_lines_tbl(i).osp_order_id,
                p_item_instance_id  => p_x_lines_tbl(i).csi_item_instance_id,
                p_oe_ship_line_id   => FND_API.G_MISS_NUM ,
                p_oe_return_line_id => p_x_lines_tbl(i).line_id);
          END IF;

        ELSE -- instance id is null

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Update_OSP_Order_Lines');
          END IF;
          IF p_x_lines_tbl(i).osp_line_id IS NOT NULL THEN
            IF (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
              Update_OSP_Order_Lines(
                  p_osp_order_id      => p_x_lines_tbl(i).osp_order_id,
                  p_osp_line_id  => p_x_lines_tbl(i).osp_line_id,
                  p_oe_ship_line_id   => p_x_lines_tbl(i).line_id,
                  p_oe_return_line_id  =>  FND_API.G_MISS_NUM);
            ELSIF  (p_x_lines_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
              --mpothuku modified on 14-Sep-2007 to fix the Bug 6398921
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_lines_tbl(i).order_type :' ||p_x_lines_tbl(i).order_type);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_lines_tbl(i).line_id :' ||p_x_lines_tbl(i).line_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_lines_tbl(i).ship_from_org_id :' ||p_x_lines_tbl(i).ship_from_org_id);
              END IF;
              IF(p_x_lines_tbl(i).order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
                /*
                For exchange orders, the return line's sub-transaction record is to be created by ourselves even though
                the instance is not updated as part of the order line's exchange instance. Otherwise OM creates it with
                the default sub-transction and not use the AHL IB profile.
                We check whether the OE Line item is IB tracked on the receiving org and, if so create the
                Installation details with the instance as null.
                */
                OPEN is_oe_item_IB_tracked(p_x_lines_tbl(i).line_id, p_x_lines_tbl(i).ship_from_org_id);
                FETCH is_oe_item_IB_tracked into l_dummy;
                IF(is_oe_item_IB_tracked%FOUND) THEN
                  CLOSE is_oe_item_IB_tracked;
                  Create_IB_Transaction(
                      p_init_msg_list         => p_init_msg_list,
                      p_commit                => p_commit,
                      p_validation_level      => p_validation_level,
                      x_return_status         => x_return_status,
                      x_msg_count             => x_msg_count,
                      x_msg_data              => x_msg_data,
                      p_osp_order_type        => p_x_lines_tbl(i).order_type,
                      p_oe_line_type          => l_line_type,
                      p_oe_line_id            => p_x_lines_tbl(i).line_id,
                      p_csi_instance_id       => NULL);
                  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status from Create_IB_Transaction: ' || x_return_status);
                  END IF;
                  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
                  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                ELSE
                  CLOSE is_oe_item_IB_tracked;
                END IF;
                --mpothuku End
              END IF;
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling Update_OSP_Order_Lines with p_oe_return_line_id = ' || p_x_lines_tbl(i).line_id );
              END IF;
              Update_OSP_Order_Lines(
                  p_osp_order_id      => p_x_lines_tbl(i).osp_order_id,
                  p_osp_line_id  => p_x_lines_tbl(i).osp_line_id,
                  p_oe_ship_line_id   => FND_API.G_MISS_NUM ,
                  p_oe_return_line_id => p_x_lines_tbl(i).line_id);
            END IF;
          END IF; -- OSP Line Id not null
        END IF; -- if instance id is not null

/*
      -- July 23, 2003: Deletion of lines should go through the Delete_Cancel_Order API
      -- Not through the regular process.
      -- This is to support the Post-Shipment Conversion process where deletion of shipment (return) lines
      -- from the UI (after the order has been booked) is necessary.
      -- If the shipment is booked, Delete_Cancel_Order just zeroes out the ordered quantity.
      -- If not, it actually deletes the shipment line.
      ELSIF (p_x_lines_tbl(i).operation = 'D') THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_IB_Transaction');
        END IF;
        Delete_IB_Transaction(
           p_init_msg_list         => p_init_msg_list,
           p_commit                => p_commit,
           p_validation_level      => p_validation_level,
           x_return_status         => x_return_status,
           x_msg_count             => x_msg_count,
           x_msg_data              => x_msg_data,
           p_oe_line_id            => p_x_lines_tbl(i).line_id );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status from Delete_IB_Transaction: ' || x_return_status);
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_OE_Lines');
        END IF;
        --Remove all instances of Shipment Line from OSP_ORDER_LINES table
        Delete_OE_Lines(p_oe_line_id => p_x_lines_tbl(i).line_id);
*/
      END IF;  -- If Operation = 'C'
    END LOOP;  -- For all Create and Update Lines lines
  END IF;  -- If Create/Update Line Count > 0


-- yazhou 07-Aug-2006 starts
-- bug fix#5448191

-- When OSP lines already exist for a physical item and another OSP line is created
-- for this physical itme for a different service, no shipment will be created.
-- However, the corresponding oe_ship_line_id and oe_return_line_id should be associated to
-- the new OSP line


  /* Modified by jaramana on January 11, 2008 to fix the Bug 5688387/5842229
  p_x_header_rec will have the osp_order_id when
  1. "Create Shipment" action from Edit Osp Order is used
  2. If user is creating multiple services for the same physical item from the "Create Item Order Line" on the Edit Osp Order UI.
  Note that in this case, AHL_OSP_ORDERS_PVT will not populate the p_x_lines_tbl if a shipment already exists for the first line

  p_x_lines_tbl will have the osp_order_id when "Create Shipment Line" UI is used for creating the ship lines.
  In this case, the p_x_header_rec will not have been populated.
  Instead of the l_osp_order_id we were directly using p_x_header_rec.osp_order_id before.
  */

  l_osp_order_id := null;
  l_osp_order_id := p_x_header_rec.osp_order_id;

  IF(l_osp_order_id is null AND p_x_lines_tbl.COUNT > 0) THEN
    l_osp_order_id := p_x_lines_tbl(p_x_lines_tbl.FIRST).osp_order_id;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Going to loop for multiple services for the Order = ' || l_osp_order_id );
  END IF;

  IF(l_osp_order_id is not null) THEN

    FOR l_osp_line_no_ship_type IN ahl_osp_line_no_ship_csr(l_osp_order_id) LOOP

      OPEN ahl_osp_line_ship_id_csr(l_osp_order_id,l_osp_line_no_ship_type.inventory_item_id,
                l_osp_line_no_ship_type.inventory_org_id, l_osp_line_no_ship_type.serial_number);
      FETCH ahl_osp_line_ship_id_csr into l_osp_line_ship_id_type;
      CLOSE ahl_osp_line_ship_id_csr;

      -- Modified by jaramana on January 11, 2008 to fix the new issue raised by AE in the Bug 5688387/5842229
      IF (l_osp_line_ship_id_type.oe_ship_line_id is not null and l_osp_line_ship_id_type.oe_ship_line_id = -1) THEN
        l_osp_line_ship_id_type.oe_ship_line_id := NULL;
      END IF;

      IF (l_osp_line_ship_id_type.oe_return_line_id is not null and l_osp_line_ship_id_type.oe_return_line_id = -1) THEN
        l_osp_line_ship_id_type.oe_return_line_id := NULL;
      END IF;

      IF (l_osp_line_ship_id_type.oe_ship_line_id is not null
         OR l_osp_line_ship_id_type.oe_return_line_id is not null) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling Update_OSP_Order_Lines with p_oe_ship_line_id = ' || l_osp_line_ship_id_type.oe_ship_line_id );
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Calling Update_OSP_Order_Lines with p_oe_return_line_id = ' || l_osp_line_ship_id_type.oe_return_line_id );
        END IF;

        Update_OSP_Order_Lines(
                      p_osp_order_id       => l_osp_order_id,
                      p_osp_line_id        => l_osp_line_no_ship_type.osp_order_line_id,
                      p_oe_ship_line_id    => l_osp_line_ship_id_type.oe_ship_line_id,
                      p_oe_return_line_id  => l_osp_line_ship_id_type.oe_return_line_id);
      END IF;

    END LOOP;
  END IF;

-- yazhou 07-Aug-2006 ends

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to commit work');
    END IF;
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_Order_Pub;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Order',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
END Process_Order;


-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Book_Order
--  Type              : Public
--  Function          : For multiple Shipment Headers, book the orders
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Book_Order Parameters:
--       p_oe_header_tbl          IN NUMBER TABLE
--         The array of header_id for the Shipment Headers
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Book_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_oe_header_tbl         IN        SHIP_ID_TBL_TYPE,
    x_return_status         OUT NOCOPY        VARCHAR2,
    x_msg_count             OUT NOCOPY        NUMBER,
    x_msg_data              OUT NOCOPY        VARCHAR2 ) IS
--
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Book_Order';
   l_action_request_tbl    OE_ORDER_PUB.request_tbl_type;
   l_action_request_rec    OE_ORDER_PUB.request_rec_type;
   l_msg_data              VARCHAR2(2000);
   l_msg_index_out         NUMBER;
   l_msg_count             NUMBER;
--
BEGIN
  SAVEPOINT Book_Order_Pub;

   -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  --LOOP throught all header ids
 IF (p_oe_header_tbl.COUNT > 0) THEN
  FOR i IN p_oe_header_tbl.FIRST..p_oe_header_tbl.LAST  LOOP
    l_action_request_rec := OE_ORDER_PUB.G_MISS_REQUEST_REC;
    l_action_request_rec.entity_code := OE_GLOBALS.G_ENTITY_HEADER;
    l_action_request_rec.entity_id := p_oe_header_tbl(i);
    l_action_request_rec.request_type := OE_GLOBALS.G_BOOK_ORDER;
    l_action_request_tbl(i) := l_action_request_rec;
  END LOOP;
 END IF;

  /*
  Added by jaramana on January 11, 2008 to raise any validation errors that may have been accumulated by the AHL_OSP_ORDERS_PVT procedure
  We do not have any warning messages hence if the message count is > 0 then it means there are validation errors and since
  we call a Public API in this procedure, its better we throw the error here itself.
  */
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error Count Before calling OE_ORDER_GRP.PROCESS_ORDER: '||l_msg_count);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- jaramana End

  --OE_ORDER_GRP uses its own message stack OE_MSG_PUB, so we should pass p_init_msg_list as true to this API
  --Note that this also does an FND_MSG_PUB.initialize along with clearing its own error stack
  OE_ORDER_GRP.PROCESS_ORDER(
    p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_action_request_tbl  => l_action_request_tbl,
    x_header_rec          => x_header_rec,
    x_header_val_rec      => x_header_val_rec,
    x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
    x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
    x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
    x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
    x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
    x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
    x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
    x_line_tbl               =>     x_line_tbl      ,
    x_line_val_tbl           =>    x_line_val_tbl ,
    x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
    x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
    x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
    x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
    x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
    x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
    x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
    x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
    x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
    x_action_request_tbl     => x_action_request_tbl  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FOR i IN 1..x_msg_count LOOP
     OE_MSG_PUB.Get( 	p_msg_index => i,
			p_encoded => FND_API.G_FALSE,
			p_data    => l_msg_data,
			p_msg_index_out => l_msg_index_out);
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                             p_procedure_name => 'bookOrder',
                             p_error_text     => substr(l_msg_data,1,240));
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
      END IF;

    END LOOP;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status at the end of all processing: ' || x_return_status);
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  /*
  Modified by jaramana on January 11, 2008 to fix the Bug 5935388/6504122
  If success is returned by the Public API, clear the message stack to eat up any warning messages from OM API.
  Otherwise, OAExceptionUtils.checkErrors will consider these as errors
  Also note that had there been any validation errors that had been accumulated we would have thrown before the call to
  OE_ORDER_GRP.PROCESS_ORDER
  */
  ELSIF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
        FND_MSG_PUB.get (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'OE: Warning ' || i || ': ' || l_msg_data);
      END LOOP;
    END IF;
    FND_MSG_PUB.Initialize;
  -- jaramana End
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Book_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Book_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Book_Order_Pub;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Book_Order',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
END Book_Order;

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Delete_Cancel_Order
--  Type              : Public
--  Function          : For one Shipment Header and a set of Shipment
-- Lines, Cancel if booked. Process either the header or the lines
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY      VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY      NUMBER               Required
--      x_msg_data                      OUT NOCOPY      VARCHAR2             Required
--
--  Delete_Cancel_Order Parameters:
--       p_oe_header_id          IN NUMBER
--         The header_id for the Shipment Header
--       p_oe_lines_tbl        IN   ship_id_tbl_type
--         All shipment line ids for delete or cancel
--       p_cancel_flag         IN VARCHAR2
--         If true, only do cancels, no deletes.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Delete_Cancel_Order (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_oe_header_id          IN        NUMBER,
    p_oe_lines_tbl 	    IN        SHIP_ID_TBL_TYPE,
    p_cancel_flag           IN        VARCHAR2  := FND_API.G_FALSE,
    x_return_status         OUT NOCOPY            VARCHAR2,
    x_msg_count             OUT NOCOPY            NUMBER,
    x_msg_data              OUT NOCOPY            VARCHAR2)
IS
--
 CURSOR ahl_is_header_deleteable_csr(p_header_id IN NUMBER) IS
    SELECT order_type_id
    FROM oe_order_headers_all
    WHERE header_id = p_header_id
     AND booked_flag = 'N';

 CURSOR ahl_is_line_deleteable_csr(p_line_id IN NUMBER) IS
    SELECT 1
    FROM oe_order_lines_all
    WHERE line_id = p_line_id
     AND shipped_quantity IS NULL
     AND booked_flag = 'N';

--
   L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Delete_Cancel_Order';
   l_header_rec     OE_ORDER_PUB.header_rec_type;
   l_line_rec       OE_ORDER_PUB.line_rec_type;
   l_line_tbl       OE_ORDER_PUB.line_tbl_type;
   l_osp_order_id   NUMBER;
   l_dummy          NUMBER;
   l_type           VARCHAR2(1);
   l_order_type_id  NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_msg_index_out  NUMBER;
   l_msg_count      NUMBER;
--
BEGIN

  SAVEPOINT Delete_Cancel_Order_Pub;

   -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
  l_line_tbl   := OE_ORDER_PUB.G_MISS_LINE_TBL;

  -- Try delete/cancel header first.
  IF (p_oe_header_id IS NOT NULL AND
      p_oe_header_id <> FND_API.G_MISS_NUM) THEN

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_OSP_Order with p_oe_header_id = ' || p_oe_header_id);
    END IF;

    -- Remove references in OSP tables
    Delete_OSP_Order(p_oe_header_id => p_oe_header_id );

    -- Convert header into cancel or delete
    OPEN ahl_is_header_deleteable_csr(p_oe_header_id);
    FETCH ahl_is_header_deleteable_csr INTO l_order_type_id;
    l_type := OE_Header_Util.Get_ord_seq_type(l_order_type_id);

    -- If deleteable and not gapless type
    IF (ahl_is_header_deleteable_csr%FOUND
        AND l_type <> 'G') THEN
       l_header_rec := OE_HEADER_UTIL.QUERY_ROW(p_header_id => p_oe_header_id);
       l_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;
    ELSE
       l_header_rec := OE_HEADER_UTIL.QUERY_ROW(p_header_id => p_oe_header_id);
       l_header_rec.cancelled_flag := 'Y';
       l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    END IF;

    CLOSE ahl_is_header_deleteable_csr;

  ELSIF (p_oe_lines_tbl.COUNT > 0) THEN

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_oe_lines_tbl.COUNT = ' || p_oe_lines_tbl.COUNT);
    END IF;

    -- Process lines into cancel or delete
    FOR i IN p_oe_lines_tbl.FIRST..p_oe_lines_tbl.LAST  LOOP

      l_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_OE_Lines with p_oe_line_id = ' || p_oe_lines_tbl(i));
      END IF;
      --Remove line_id references in OSP tables
      Delete_OE_Lines(p_oe_line_id => p_oe_lines_tbl(i));

      l_line_rec := OE_LINE_UTIL.QUERY_ROW(p_line_id => p_oe_lines_tbl(i));

      OPEN ahl_is_line_deleteable_csr(p_oe_lines_tbl(i));
      FETCH ahl_is_line_deleteable_csr INTO l_dummy;
      -- If deleteable
      IF (ahl_is_line_deleteable_csr%FOUND) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Line is deletable: Deleting line');
        END IF;
        l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Line is not deletable: Setting Quantity to 0 and change_reason to Not provided');
        END IF;
        l_line_rec.ordered_quantity := 0;
        l_line_rec.change_reason := 'Not provided';  --No reason provided
        l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
      END IF;
      CLOSE ahl_is_line_deleteable_csr;

      l_line_tbl(i) := l_line_rec;

    END LOOP;  -- For all lines
  END IF;  -- Elsif line table count > 0

--
  /*
  Added by jaramana on January 11, 2008 to raise any validation errors that may have been accumulated by the AHL_OSP_ORDERS_PVT procedure
  We do not have any warning messages hence if the message count is > 0 then it means there are validation errors and since
  we call a Public API in this procedure, its better we throw the error here itself.
  */
  l_msg_count := FND_MSG_PUB.count_msg;
  IF l_msg_count > 0 THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error Count Before calling OE_ORDER_GRP.PROCESS_ORDER: '||l_msg_count);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --OE_ORDER_GRP uses its own message stack OE_MSG_PUB, so we should pass p_init_msg_list as true to this API
  --Note that this also does an FND_MSG_PUB.initialize along with clearing its own error stack
  OE_ORDER_GRP.PROCESS_ORDER(
    p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_header_rec	  => l_header_rec,
    p_line_tbl            => l_line_tbl,
    x_header_rec          => x_header_rec,
    x_header_val_rec      => x_header_val_rec,
    x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
    x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
    x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
    x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
    x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
    x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
    x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
    x_line_tbl               =>     x_line_tbl      ,
    x_line_val_tbl           =>    x_line_val_tbl ,
    x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
    x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
    x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
    x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
    x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
    x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
    x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
    x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
    x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
    x_action_request_tbl     => x_action_request_tbl  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   FOR i IN 1..x_msg_count LOOP
     OE_MSG_PUB.Get( 	p_msg_index => i,
			p_encoded => FND_API.G_FALSE,
			p_data    => l_msg_data,
			p_msg_index_out => l_msg_index_out);
     fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                             p_procedure_name => 'deleteCancelOrder',
                             p_error_text     => substr(l_msg_data,1,240));
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
      END IF;
    END LOOP;
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  /*
  Modified by jaramana on January 11, 2008 to fix the Bug 5935388/6504122
  If success is returned by the Public API, clear the message stack to eat up any warning messages from OM API.
  Otherwise, OAExceptionUtils.checkErrors will consider these as errors
  Also note that had there been any validation errors that had been accumulated we would have thrown before the call to
  OE_ORDER_GRP.PROCESS_ORDER
  */
  ELSIF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
        FND_MSG_PUB.get (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'OE: Warning ' || i || ': ' || l_msg_data);
      END LOOP;
    END IF;
    FND_MSG_PUB.Initialize;
  END IF;

  IF (l_line_tbl.COUNT >0) THEN
   FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST  LOOP
    Delete_IB_Transaction(
      -- Changed by jaramana on January 11, 2008 for the Requisition ER 6034236.
      p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
      p_commit                => p_commit,
      p_validation_level      => p_validation_level,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data,
      p_oe_line_id            => l_line_tbl(i).line_id );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   END LOOP;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Delete_Cancel_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Delete_Cancel_Order_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Delete_Cancel_Order_Pub;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Delete_Cancel_Order',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);
END Delete_Cancel_Order;

---------------------------------------------------------------------
-- FUNCTION
--    is_order_header_closed
--
-- PURPOSE
--    This function checks if the shipment header is closed.
--
-- NOTES
--    1. It will return FND_API.g_true/g_false.
--    2. Exception encountered will be raised to the caller.
---------------------------------------------------------------------
FUNCTION is_order_header_closed(
   p_oe_header_id IN NUMBER )
RETURN VARCHAR2
IS
--Modified by mpothuku on 18-Sep-06 for fixing the Bug 5673483
/*
 CURSOR ahl_osp_header_id_csr(p_header_id IN NUMBER) IS
    SELECT 1
    FROM oe_order_headers_all
    WHERE header_id = p_header_id;
*/
--
 CURSOR ahl_osp_oe_closed_csr(p_header_id IN NUMBER) IS
    SELECT open_flag, nvl(flow_status_code,'XXX') flow_status_code, nvl(cancelled_flag,'N') cancelled_flag
    FROM oe_order_headers_all
    WHERE header_id = p_header_id;
    --Modified by mpothuku on 18-Sep-06 for fixing the Bug 5673483
    /*
    AND open_flag = 'N'
    AND flow_status_code = 'CLOSED';
    */
--
 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.is_order_header_closed';
 l_closed VARCHAR2(30);
 --l_dummy NUMBER;
 l_ahl_osp_oe_closed_csr ahl_osp_oe_closed_csr%rowtype;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY , 'p_oe_header_id is: '||p_oe_header_id);
  END IF;
  --Modified by mpothuku on 18-Sep-06 for fixing the Bug 5673483
  /*
   OPEN ahl_osp_header_id_csr(p_oe_header_id);
   FETCH ahl_osp_header_id_csr INTO l_dummy;
   IF (ahl_osp_header_id_csr%NOTFOUND) THEN
      CLOSE ahl_osp_header_id_csr;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AHL', 'AHL_OSP_HEADER_ID_INV');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE ahl_osp_header_id_csr;
  */

  --Modified by mpothuku on 18-Sep-06 for fixing the Bug 5673483
  l_closed := FND_API.G_FALSE;
  IF(p_oe_header_id is not null) THEN
      OPEN ahl_osp_oe_closed_csr (p_oe_header_id);
      FETCH ahl_osp_oe_closed_csr INTO l_ahl_osp_oe_closed_csr;
      IF (ahl_osp_oe_closed_csr%FOUND) THEN
         IF((l_ahl_osp_oe_closed_csr.open_flag = 'N' AND l_ahl_osp_oe_closed_csr.flow_status_code = 'CLOSED')
            OR (l_ahl_osp_oe_closed_csr.cancelled_flag = 'Y' AND l_ahl_osp_oe_closed_csr.flow_status_code = 'CANCELLED'))
         THEN
              l_closed := FND_API.G_TRUE;
         END IF;
      ELSE --This may mean that the Sales Order has been deleted from the OM Forms and Synch has not been done
        CLOSE ahl_osp_oe_closed_csr;
        l_closed := FND_API.G_FALSE;
        FND_MESSAGE.Set_Name('AHL', 'AHL_OSP_HEADER_ID_INV');
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
      END IF;
    CLOSE ahl_osp_oe_closed_csr;
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

  RETURN l_closed;

END is_order_header_closed;

--Added by mpothuku on 14-Dec-05 to derive the user profile option name
------------------------------------------------------------------------------------
-- FUNCTION
--    get_user_profile_option_name
--
-- PURPOSE
--    This function returns the user profile option name given a profile option name.
--
-- NOTES
--    1. It will return user profile option name.
-------------------------------------------------------------------------------------
FUNCTION get_user_profile_option_name(p_profile_option_name IN VARCHAR2 )
RETURN VARCHAR2
IS
 CURSOR get_user_prf_opt_name_csr(c_prf_opt_name IN VARCHAR2) IS
    SELECT USER_PROFILE_OPTION_NAME
    FROM fnd_profile_options_vl
    WHERE profile_option_name = c_prf_opt_name;

 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.get_user_profile_option_name';
 l_usr_prf_opt_name VARCHAR2(240);

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

   OPEN get_user_prf_opt_name_csr(p_profile_option_name);
   FETCH get_user_prf_opt_name_csr INTO l_usr_prf_opt_name;
   IF (get_user_prf_opt_name_csr%NOTFOUND) THEN
      l_usr_prf_opt_name := null;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error: '||p_profile_option_name|| ' needs to be defined');
      END IF;
   END IF;
   CLOSE get_user_prf_opt_name_csr;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure. l_usr_prf_opt_name is: ' || l_usr_prf_opt_name);
  END IF;

  RETURN l_usr_prf_opt_name;

END get_user_profile_option_name;

------------------------------
-- Define Local Procedures --
------------------------------

PROCEDURE Convert_Header_rec(
	p_header_rec  IN AHL_OSP_SHIPMENT_PUB.SHIP_HEADER_REC_TYPE,
	p_module_type         IN            VARCHAR2 ,
	x_header_rec  OUT NOCOPY OE_ORDER_PUB.HEADER_REC_TYPE,
	x_header_val_rec OUT NOCOPY OE_ORDER_PUB.HEADER_VAL_REC_TYPE)
IS
---
  --Commented by mpothuku to fix the Perf Bug #4919255
  /*
  CURSOR ahl_salesrep_id_csr IS
    SELECT salesrep_id
    FROM ra_salesreps
    WHERE commissionable_flag = 'N';
  */

  CURSOR ahl_trxn_curr_code_csr IS
    SELECT GSB.currency_code
    FROM FINANCIALS_SYSTEM_PARAMETERS FSP,
      GL_SETS_OF_BOOKS GSB
    WHERE FSP.set_of_books_id = GSB.set_of_books_id;

   --Used inv_organization_info_v instead of org_organization_definitions to fix the Perf Bug #4919255
   CURSOR ahl_ship_from_orgs_csr(p_name IN VARCHAR2) IS
    SELECT org.organization_id
    FROM OE_SHIP_FROM_ORGS_V org, inv_organization_info_v def
    WHERE org.organization_id = def.organization_id
    -- Changed by jaramana on Sep 9, 2005 for MOAC Uptake
    -- AND def.operating_unit = FND_PROFILE.VALUE('DEFAULT_ORG_ID')
    AND def.operating_unit = MO_GLOBAL.get_current_org_id()
    AND org.name = p_name;

   CURSOR ahl_sold_to_orgs_csr(p_cust_number IN VARCHAR2) IS
    SELECT organization_id
    FROM OE_SOLD_TO_ORGS_V
    WHERE customer_number = p_cust_number;

 CURSOR ahl_ship_to_orgs_csr(p_name IN VARCHAR2, p_sold_to_org_id IN NUMBER) IS
    SELECT organization_id
    FROM OE_SHIP_TO_ORGS_V
    WHERE customer_id = p_sold_to_org_id
    AND name = p_name;

  CURSOR ahl_sold_to_contact_count_csr(p_sold_to_contact IN VARCHAR2, p_sold_to_org_id IN NUMBER) IS
    SELECT COUNT(CONTACT_ID)
    FROM OE_CONTACTS_V
    WHERE NAME = p_sold_to_contact
      AND CUSTOMER_ID = p_sold_to_org_id;

  CURSOR ahl_order_vendor_detls_csr(p_osp_order_id IN NUMBER) IS
  SELECT osp.vendor_id,
	 osp.vendor_site_id,
	 osp.vendor_contact_id,
	 osp.osp_order_number,
	 cust.customer_site_id,
	 cust.customer_id
    FROM ahl_osp_orders_b osp,
         ahl_vendor_customer_rels_v cust
   WHERE osp.osp_order_id = p_osp_order_id
     AND osp.vendor_site_id = cust.vendor_site_id;

     l_vendor_cust_dtls ahl_order_vendor_detls_csr%ROWTYPE;


  CURSOR ahl_customer_info_csr(p_customer_site_id IN NUMBER) IS
  /*
  SELECT cust_account_id
   FROM  hz_cust_acct_sites_all acc,
         HZ_CUST_SITE_USES_ALL site
  WHERE  site.cust_acct_site_id = acc.cust_acct_site_id
  and SITE_USE_ID = p_customer_site_id;*/

  select customer_id from OE_SHIP_TO_ORGS_V
  where organization_id = p_customer_site_id;

  CURSOR ahl_get_ship_from_org_csr(p_osp_order_id IN NUMBER) IS
  SELECT inventory_org_id
    FROM ahl_osp_order_lines
   WHERE osp_order_id = p_osp_order_id
   ORDER BY osp_order_line_id;

  l_cust_id   NUMBER;

---
 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Convert_Header_Rec';

 l_trxn_curr_code    VARCHAR2(30);
 l_org_id            NUMBER;
 l_contact_count     NUMBER;
---
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (p_header_rec.operation = 'D') THEN
    x_header_rec := OE_HEADER_UTIL.QUERY_ROW(p_header_id => p_header_rec.header_id);
    x_header_val_rec :=  OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;
    x_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;

  ELSE

    -- Changed by jaramana on Sep 9, 2005 for MOAC Uptake
    l_org_id := MO_GLOBAL.get_current_org_id();

    --Convert our rec type into OE_ORDER_PUB entities

    x_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    x_header_val_rec := OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

    --Added by mpothuku on 08-may-06 for fixing the Bug 5212130
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_header_rec.operation = ' || p_header_rec.operation);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_header_rec.osp_order_id = ' || p_header_rec.osp_order_id);
    END IF;

    --If no operation, then invalid order
    IF (p_header_rec.operation IS NULL OR
      p_header_rec.operation = FND_API.G_MISS_CHAR) THEN
      RETURN;
    END IF;

    IF (p_header_rec.header_id IS NOT NULL) THEN
        x_header_rec.header_id := p_header_rec.header_id;
    END IF;

    IF (p_header_rec.order_number IS NOT NULL) THEN
        x_header_rec.order_number := p_header_rec.order_number;
    END IF;

    IF (p_header_rec.booked_flag IS NOT NULL)  THEN
        x_header_rec.booked_flag := p_header_rec.booked_flag;
    END IF;

    IF (p_header_rec.cancelled_flag IS NOT NULL)  THEN
        x_header_rec.cancelled_flag := p_header_rec.cancelled_flag;
    END IF;

    IF (p_header_rec.open_flag IS NOT NULL)  THEN
        x_header_rec.open_flag := p_header_rec.open_flag;
    END IF;

/* OE to default
    IF (p_header_rec.price_list_id IS NOT NULL AND
        p_header_rec.price_list IS NULL) THEN
        x_header_rec.price_list_id := p_header_rec.price_list_id;
    END IF;
    IF (p_module_type = 'JSP' AND p_header_rec.price_list IS NOT NULL)  THEN
        x_header_val_rec.price_list := p_header_rec.price_list;
    END IF;
*/

    --Org section
    x_header_rec.org_id := l_org_id;
    x_header_rec.sold_from_org_id   := l_org_id;

    IF p_header_rec.osp_order_id IS NOT NULL THEN

       OPEN ahl_order_vendor_detls_csr(p_header_rec.osp_order_id);
       FETCH ahl_order_vendor_detls_csr INTO l_vendor_cust_dtls;
       CLOSE ahl_order_vendor_detls_csr;

       --Added by mpothuku on 08-may-06 for fixing the Bug 5212130
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.vendor_id = ' || l_vendor_cust_dtls.vendor_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.vendor_site_id = ' || l_vendor_cust_dtls.vendor_site_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.customer_id = ' || l_vendor_cust_dtls.customer_id);
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.customer_site_id = ' || l_vendor_cust_dtls.customer_site_id);
       END IF;

       IF l_vendor_cust_dtls.customer_site_id IS NULL THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_VENDOR_INFO_NULL');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
       END IF;

       OPEN ahl_customer_info_csr(l_vendor_cust_dtls.customer_site_id);
       FETCH ahl_customer_info_csr INTO l_cust_id;
       CLOSE ahl_customer_info_csr;

    END IF;

    --Sold to org id from sold_to_custom_number
    /*
    IF (p_module_type = 'JSP') THEN
      IF (p_header_rec.sold_to_custom_number IS NOT NULL) THEN
       OPEN ahl_sold_to_orgs_csr(p_header_rec.sold_to_custom_number);
       FETCH ahl_sold_to_orgs_csr INTO x_header_rec.sold_to_org_id;
       IF (ahl_sold_to_orgs_csr%NOTFOUND) THEN
          CLOSE ahl_sold_to_orgs_csr;
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name('AHL', 'AHL_OSP_SOLD_TO_ORG_INV');
             FND_MESSAGE.SET_TOKEN('SOLD_TO_ORG',p_header_rec.sold_to_custom_number);
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.g_exc_error;
       END IF;
       CLOSE ahl_sold_to_orgs_csr;
     END IF;
     x_header_val_rec.customer_number   := p_header_rec.sold_to_custom_number;
   ELSE
     x_header_rec.sold_to_org_id    := p_header_rec.sold_to_org_id;
   END IF;
   */
    --x_header_rec.sold_to_org_id := l_cust_id;
    x_header_rec.sold_to_org_id := l_vendor_cust_dtls.customer_id;
    x_header_rec.ship_to_org_id := l_vendor_cust_dtls.customer_site_id;

    /*

    IF (p_module_type = 'JSP') THEN
     IF (p_header_rec.ship_to_org IS NOT NULL AND
         x_header_rec.sold_to_org_id IS NOT NULL) THEN
       OPEN ahl_ship_to_orgs_csr(p_header_rec.ship_to_org,
				 x_header_rec.sold_to_org_id);
       FETCH ahl_ship_to_orgs_csr INTO x_header_rec.ship_to_org_id;
       IF (ahl_ship_to_orgs_csr%NOTFOUND) THEN
          CLOSE ahl_ship_to_orgs_csr;
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_TO_ORG_INV');
             FND_MESSAGE.SET_TOKEN('SHIP_TO_ORG',p_header_rec.ship_to_org);
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.g_exc_error;
       END IF;
       CLOSE ahl_ship_to_orgs_csr;
     END IF;
     x_header_val_rec.ship_to_org   := p_header_rec.ship_to_org;
    ELSE
     x_header_rec.ship_to_org_id    := p_header_rec.ship_to_org_id;
    END IF;

    */

    -- Hack to find ship_from_org_id because the OE Value_to_ID converter
    -- does not exist.
    IF (p_module_type = 'JSP') THEN
     IF (p_header_rec.ship_from_org IS NOT NULL) THEN
       OPEN ahl_ship_from_orgs_csr(p_header_rec.ship_from_org);
       FETCH ahl_ship_from_orgs_csr INTO x_header_rec.ship_from_org_id;
       IF (ahl_ship_from_orgs_csr%NOTFOUND) THEN
          CLOSE ahl_ship_from_orgs_csr;
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
             Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_FROM_ORG_INV');
             FND_MESSAGE.SET_TOKEN('SHIP_FROM_ORG',p_header_rec.ship_from_org);
             Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.g_exc_error;
       END IF;
       CLOSE ahl_ship_from_orgs_csr;
     END IF;
     x_header_val_rec.ship_from_org  := p_header_rec.ship_from_org;
    ELSE
     x_header_rec.ship_from_org_id    := p_header_rec.ship_from_org_id;
    END IF;

    IF x_header_rec.ship_from_org_id IS NULL THEN
       OPEN ahl_get_ship_from_org_csr(p_header_rec.osp_order_id);
       FETCH ahl_get_ship_from_org_csr INTO x_header_rec.ship_from_org_id;
       CLOSE ahl_get_ship_from_org_csr;
    END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'x_header_rec.ship_from_org_id = ' || x_header_rec.ship_from_org_id);
   END IF;

    --Sold to contact (Uses ship_to_contact param name)
    OPEN ahl_sold_to_contact_count_csr(p_header_rec.ship_to_contact,
                                       x_header_rec.sold_to_org_id);
    FETCH ahl_sold_to_contact_count_csr INTO l_contact_count;
    IF (l_contact_count < 2) THEN
       x_header_rec.sold_to_contact_id   := FND_API.G_MISS_NUM;
       x_header_val_rec.sold_to_contact     := p_header_rec.ship_to_contact;
    ELSE
       x_header_rec.sold_to_contact_id   := p_header_rec.ship_to_contact_id;
    END IF;
    CLOSE ahl_sold_to_contact_count_csr;

    --Nullable LOV parameters
   IF (p_module_type = 'JSP') THEN
      x_header_rec.fob_point_code    := FND_API.G_MISS_CHAR;
    x_header_val_rec.fob_point   := p_header_rec.fob_point;
    ELSE
      x_header_rec.fob_point_code    := p_header_rec.fob_point_code;
    END IF;
-- No used as of now . COmmented in JSP
    IF (p_module_type = 'JSP') THEN
      x_header_rec.freight_carrier_code   :=  FND_API.G_MISS_CHAR;
    x_header_val_rec.freight_carrier   := p_header_rec.freight_carrier;
    ELSE
      x_header_rec.freight_carrier_code   := p_header_rec.freight_carrier_code;
    END IF;


    IF (p_module_type = 'JSP') THEN
	x_header_rec.freight_terms_code  := FND_API.G_MISS_CHAR ;
    x_header_val_rec.freight_terms  := p_header_rec.freight_terms;
    ELSE
	x_header_rec.freight_terms_code  := p_header_rec.freight_terms_code;
    END IF;


/* To be fetched from Profile */
    IF (p_module_type = 'JSP') THEN
	  x_header_rec.shipment_priority_code  := FND_API.G_MISS_CHAR;
      x_header_val_rec.shipment_priority  := p_header_rec.shipment_priority;
    ELSE
    	x_header_rec.shipment_priority_code  := p_header_rec.shipment_priority_code;
    END IF;

    IF (p_module_type = 'JSP') THEN
	x_header_rec.shipping_method_code  := FND_API.G_MISS_CHAR;
    x_header_val_rec.shipping_method    := p_header_rec.shipping_method;
    ELSE
	x_header_rec.shipping_method_code  := p_header_rec.shipping_method_code;
    END IF;

    -- Added by jaramana on June 3, 2005 to default Header Values from setup
    IF (p_header_rec.operation = 'C') THEN
      -- Allow these values to be defaulted when creating a Shipment
      x_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
      x_header_rec.freight_terms_code := FND_API.G_MISS_CHAR;
      x_header_rec.freight_carrier_code := FND_API.G_MISS_CHAR;
      x_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
      -- Get this from the profile
      x_header_rec.shipment_priority_code := FND_PROFILE.VALUE('AHL_OSP_OE_SHIPMENT_PRIORITY');
    END IF;

/*
    -- JR: Coded on 8/19/2003 as fix for Bug 3095543
    -- Payment Term is mandatory
    IF ((p_module_type = 'JSP') AND (p_header_rec.payment_term = FND_API.G_MISS_CHAR)) THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_PAYMENT_TERM_NULL');
          Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
    END IF;
    IF (p_module_type = 'JSP') THEN
  	   x_header_rec.payment_term_id  := FND_API.G_MISS_NUM;
       x_header_val_rec.payment_term := p_header_rec.payment_term;
    ELSE
        x_header_rec.payment_term_id := p_header_rec.payment_term_id;
    END IF;
*/


/* To be fetched from Profile */

    IF (p_header_rec.tax_exempt_flag IS NOT NULL) THEN
	x_header_rec.tax_exempt_flag := p_header_rec.tax_exempt_flag;
    END IF;
    IF (p_header_rec.tax_exempt_number IS NOT NULL) THEN
	x_header_rec.tax_exempt_number := p_header_rec.tax_exempt_number;
    END IF;
    IF (p_module_type = 'JSP') THEN
      x_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
      x_header_val_rec.tax_exempt_reason  := p_header_rec.tax_exempt_reason;
    ELSE
      x_header_rec.tax_exempt_reason_code := p_header_rec.tax_exempt_reason_code;
    END IF;
    IF x_header_rec.tax_exempt_flag IS NULL THEN
      IF (p_header_rec.operation = 'C') THEN
        x_header_rec.tax_exempt_flag := 'E'; -- Default is Exempted.
        x_header_rec.tax_exempt_reason_code := FND_PROFILE.VALUE('AHL_OSP_TAX_EXEMPT_REASON');
      END IF;
    END IF;
    x_header_rec.shipping_instructions := p_header_rec.shipping_instructions;
    x_header_rec.packing_instructions := p_header_rec.packing_instructions;

    --------------------Hard coded Values------------------------

    --Transaction currency code
    OPEN ahl_trxn_curr_code_csr;
    FETCH ahl_trxn_curr_code_csr INTO l_trxn_curr_code;
    IF (ahl_trxn_curr_code_csr%FOUND) THEN
        x_header_rec.transactional_curr_code := l_trxn_curr_code;
    END IF;
    CLOSE ahl_trxn_curr_code_csr;

    --Set the ORDER_TYPE to 'MIXED'
    IF (p_header_rec.operation = 'C') THEN
       x_header_rec.order_type_id := FND_PROFILE.VALUE('AHL_OSP_OE_MIXED_ID');

       x_header_rec.ordered_date := sysdate;
       x_header_rec.pricing_date := sysdate;
    END IF;

    --Fetch AHL_OSP_ORDER source document type id
    --AHL_ORDER_TYPE is defined to be 21 now.
    x_header_rec.source_document_type_id := 21;

    --Commented by mpothuku to fix the Perf Bug #4919255
    --Fetch salesrep id
    /*
    OPEN ahl_salesrep_id_csr;
    FETCH ahl_salesrep_id_csr INTO x_header_rec.salesrep_id;
    CLOSE ahl_salesrep_id_csr;
    */
    --'-3' corresponds to a non-commisionable salesrep in any org and its seeded according to the OM contact.
    x_header_rec.salesrep_id := -3;
    x_header_rec.source_document_id := p_header_rec.osp_order_id;
    x_header_rec.orig_sys_document_ref := p_header_rec.osp_order_number;

    ------------- Operations ----------------
    IF (p_header_rec.operation = 'C') THEN
      x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    ELSIF (p_header_rec.operation = 'U') THEN
      x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    END IF;
  END IF; -- Not 'D'

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Convert_Header_rec;



PROCEDURE Process_Line_Tbl(
        p_osp_order_id     IN            NUMBER,
        p_operation_flag   IN            VARCHAR,
        p_module_type      IN            VARCHAR2,
        p_x_line_tbl       IN OUT NOCOPY AHL_OSP_SHIPMENT_PUB.SHIP_LINE_TBL_TYPE
    ) IS
--
--Commented by mpothuku on 06-Mar-06 to fix the Perf Bug 4919255 as the cursor below is not being used.
/*
  CURSOR ahl_osp_wo_csr(p_wo_name IN VARCHAR2, p_osp_id IN NUMBER) IS
   SELECT wo.inventory_item_id,
          wo.serial_number,
          wo.item_instance_uom,
          wo.quantity,
          wo.item_instance_id,
          wo.project_id,
          wo.project_task_id,
          wo.ORGANIZATION_ID,
          ospl.osp_order_id,
          ospl.osp_order_line_id,
          ospl.osp_line_number,
          ospl.exchange_instance_id
   FROM AHL_WORKORDERS_OSP_V wo, AHL_OSP_ORDER_LINES ospl
   WHERE ospl.workorder_id = wo.workorder_id
     AND wo.job_number = p_wo_name
     AND ospl.osp_order_id = p_osp_id
     AND ospl.status_code IS NULL;
--
*/

--yazhou 31-Jul-2006 starts
-- bug fix#5442904

l_service_duration  NUMBER;

-- if multiple service lines are created for the same physical item, use the max service duration

CURSOR ahl_max_service_duration_csr(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER,
p_osp_order_id IN NUMBER, p_inventory_item_id IN NUMBER, p_inventory_org_id IN NUMBER,
p_serial_number IN VARCHAR2) IS
   select max(service_duration) from ahl_item_vendor_rels
   where vendor_certification_id = (select vendor_certification_id from ahl_vendor_certifications_v
   where vendor_id =p_vendor_id and vendor_site_id =p_vendor_site_id)
   and active_start_date <= sysdate
   and (active_end_date is null or active_end_date > sysdate)
   and inv_service_item_rel_id in (select inv_service_item_rel_id
                                    from ahl_inv_service_item_rels
                                   where service_item_id in (select service_item_id
                                                               from ahl_osp_order_lines
                                                              where osp_order_id = p_osp_order_id
				                                               and inventory_item_id = p_inventory_item_id
			                                                   and inventory_org_id = p_inventory_org_id
                                                               and serial_number = p_serial_number
                                                               and status_code is null)
                                      AND inv_item_id = p_inventory_item_id
                                      AND inv_org_id  = p_inventory_org_id);

--yazhou 31-Jul-2006 ends


--Commented by mpothuku on 21-Feb-06 to fix the Perf Bug 4919255 as the cursor below is not being used.
/*
CURSOR ahl_osp_instance_csr(p_instance_id IN NUMBER, p_osp_id IN NUMBER) IS
   SELECT wo.inventory_item_id,
          wo.serial_number,
          wo.item_instance_uom,
          wo.quantity,
          wo.item_instance_id,
          wo.project_id,
          wo.project_task_id,
          ospl.osp_order_id,
          ospl.osp_order_line_id,
          ospl.osp_line_number,
          ospl.exchange_instance_id
   FROM AHL_WORKORDERS_OSP_V wo, AHL_OSP_ORDER_LINES ospl
   WHERE ospl.workorder_id = wo.workorder_id
     AND wo.item_instance_id = p_instance_id
     AND ospl.osp_order_id = p_osp_id
     AND ospl.status_code IS NULL;
  */
  CURSOR ahl_exc_inst_details(p_instance_id IN NUMBER) IS
   SELECT inventory_item_id,
          serial_number,
          quantity,
          unit_of_measure,
          lot_number --jeli 12/01/05
   FROM csi_item_instances
   WHERE instance_id = p_instance_id;

--yazhou 06-Jun-2006 starts
--bug fix#5304095

--For a given osp line id, check if shipment line exists
CURSOR ahl_oe_ship_id_csr(p_osp_id    IN NUMBER,
                          p_osp_line_id    IN NUMBER)IS
    SELECT 1
     FROM AHL_OSP_ORDER_LINES
    WHERE osp_order_id = p_osp_id
      AND osp_order_line_id = p_osp_line_id
      AND oe_ship_line_id IS NOT NULL;

--For a given osp line id, check if return line exists
CURSOR ahl_oe_return_id_csr(p_osp_id    IN NUMBER,
                            p_osp_line_id IN NUMBER) IS
   SELECT 1
     FROM AHL_OSP_ORDER_LINES
    WHERE osp_order_id = p_osp_id
      AND osp_order_line_id = p_osp_line_id
      AND oe_return_line_id IS NOT NULL;

/*
  CURSOR ahl_oe_ship_id_csr(p_osp_id    IN NUMBER,
                            p_csi_ii_id IN NUMBER) IS
    --Modified by mpothuku on 21-Feb-06 to fix the Perf Bug #4919255

   SELECT 1
     FROM AHL_OSP_ORDER_LINES ospl,
          AHL_WORKORDERS wo,
          ahl_visit_tasks_b vts
    WHERE ospl.workorder_id = wo.workorder_id
      AND ospl.osp_order_id = p_osp_id
      AND wo.visit_task_id = vts.visit_task_id
      AND vts.instance_id = p_csi_ii_id
      AND ospl.oe_ship_line_id IS NOT NULL;


  CURSOR ahl_oe_ship_id_Inv_csr(p_osp_id         IN NUMBER,
                                p_inv_item_id    IN NUMBER,
                                p_inv_org_id     IN NUMBER,
                                p_sub_inventory  IN VARCHAR2,
                                p_serial_number  IN VARCHAR2,
                                p_lot_number     IN VARCHAR2,
                                p_inv_item_uom   IN VARCHAR2) IS
    SELECT 1
     FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.inventory_item_id = p_inv_item_id
      AND a.inventory_org_id= p_inv_org_id
      AND NVL(a.sub_inventory, 'X') = NVL(p_sub_inventory, 'X')
      AND NVL(a.serial_number, 'X') = NVL(p_serial_number, 'X')
      AND NVL(a.lot_number, 'X') = NVL(p_lot_number, 'X')
      AND a.oe_ship_line_id IS NOT NULL;

  CURSOR ahl_oe_return_id_csr(p_osp_id    IN NUMBER,
                              p_csi_ii_id IN NUMBER) IS

   --Modified by mpothuku on 21-Feb-06 to fix the Perf Bug #4919255
   SELECT 1
     FROM AHL_OSP_ORDER_LINES ospl,
          AHL_WORKORDERS wo,
          ahl_visit_tasks_b vts
    WHERE ospl.workorder_id = wo.workorder_id
      AND ospl.osp_order_id = p_osp_id
      AND wo.visit_task_id = vts.visit_task_id
      AND vts.instance_id = p_csi_ii_id
      AND ospl.oe_return_line_id IS NOT NULL;

  CURSOR ahl_oe_inv_return_id_csr(p_osp_id         IN NUMBER,
                                  p_inv_item_id    IN NUMBER,
                                  p_inv_org_id     IN NUMBER,
                                  p_sub_inventory  IN VARCHAR2,
                                  p_serial_number  IN VARCHAR2,
                                  p_lot_number     IN VARCHAR2,
                                  p_inv_item_uom   IN VARCHAR2) IS
    SELECT 1
     FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.inventory_item_id = p_inv_item_id
      AND a.inventory_org_id= p_inv_org_id
      AND NVL(a.sub_inventory, 'X') = NVL(p_sub_inventory, 'X')
      AND NVL(a.serial_number, 'X') = NVL(p_serial_number, 'X')
      AND NVL(a.lot_number, 'X') = NVL(p_lot_number, 'X')
      AND a.oe_return_line_id IS NOT NULL;

*/
--yazhou 06-Jun-2006 ends

   -- Cursor to check if an instance is independent (not an installed component)
   CURSOR ahl_csi_unit_test_csr (p_csi_ii_id IN NUMBER) IS
    SELECT 1
    FROM CSI_ITEM_INSTANCES CII
    WHERE CII.INSTANCE_ID = p_csi_ii_id AND
          NOT EXISTS
           (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
             WHERE CIR.SUBJECT_ID = CII.INSTANCE_ID AND
                   CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF' AND
                   NVL(CIR.ACTIVE_START_DATE, SYSDATE - 1) < SYSDATE AND
                   NVL(CIR.ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE);

   CURSOR ahl_oe_schedule_date_csr(p_osp_id    IN NUMBER,
                                   p_csi_ii_id IN NUMBER) IS
    --Modified by mpothuku on 21-Feb-06 to fix the Perf Bug #4919255
     /*
     SELECT distinct oe1.line_id, oe1.schedule_ship_date,
                     oe2.line_id, oe2.schedule_ship_date
     FROM AHL_OSP_ORDER_LINES a, OE_ORDER_LINES_ALL oe1,
          OE_ORDER_LINES_ALL oe2, AHL_WORKORDERS_OSP_V b
    WHERE a.oe_ship_line_id = oe1.line_id (+)
      AND a.oe_return_line_id = oe2.line_id (+)
      AND a.workorder_id = b.workorder_id
      AND a.osp_order_id = p_osp_id
      AND b.item_instance_id = p_csi_ii_id;
    */
    SELECT distinct oe1.line_id, oe1.schedule_ship_date,
                     oe2.line_id, oe2.schedule_ship_date
     FROM AHL_OSP_ORDER_LINES ospl,
          OE_ORDER_LINES_ALL oe1,
          OE_ORDER_LINES_ALL oe2,
          AHL_WORKORDERS wo,
          ahl_visit_tasks_b vts
    WHERE ospl.oe_ship_line_id = oe1.line_id (+)
      AND ospl.oe_return_line_id = oe2.line_id (+)
      AND ospl.workorder_id = wo.workorder_id
      AND ospl.osp_order_id = p_osp_id
      AND wo.visit_task_id = vts.visit_task_id
      AND vts.instance_id = p_csi_ii_id;

   CURSOR ahl_oe_Inv_schedule_date_csr(p_osp_id         IN NUMBER,
                                       p_inv_item_id    IN NUMBER,
                                       p_inv_org_id     IN NUMBER,
                                       p_sub_inventory  IN VARCHAR2,
                                       p_serial_number  IN VARCHAR2,
                                       p_lot_number     IN VARCHAR2,
                                       p_inv_item_uom   IN VARCHAR2) IS
     SELECT oe1.line_id, oe1.schedule_ship_date,
            oe2.line_id, oe2.schedule_ship_date
     FROM AHL_OSP_ORDER_LINES a, OE_ORDER_LINES_ALL oe1,
          OE_ORDER_LINES_ALL oe2
    WHERE a.oe_ship_line_id = oe1.line_id (+)
      AND a.oe_return_line_id = oe2.line_id (+)
      AND a.osp_order_id = p_osp_id
      AND a.inventory_item_id = p_inv_item_id
      AND a.inventory_org_id = p_inv_org_id
      AND NVL(a.sub_inventory, 'X') = NVL(p_sub_inventory, 'X')
      AND NVL(a.serial_number, 'X') = NVL(p_serial_number, 'X')
      AND NVL(a.lot_number, 'X') = NVL(p_lot_number, 'X');

   CURSOR get_osp_order_type_csr(c_osp_id IN NUMBER) IS
   SELECT order_type_code from ahl_osp_orders_b
   where osp_order_id = c_osp_id;

   CURSOR osp_order_header_csr(p_osp_order_id IN NUMBER) IS
   SELECT *
   from ahl_osp_orders_b
   where osp_order_id = p_osp_order_id;

   l_osp_header_det osp_order_header_csr%ROWTYPE;

   CURSOR osp_line_details_csr(p_osp_order_id IN NUMBER,
                               p_osp_line_id  IN NUMBER) IS
   select osp_order_line_id,
          object_version_number,
          osp_order_id,
          osp_line_number,
          workorder_id,
          status_code,
          service_item_id,
          service_item_description,
          service_item_uom_code,
          need_by_date,
          ship_by_date,
          po_line_id,
          po_line_type_id,
          oe_ship_line_id,
          oe_return_line_id,
          operation_id,
          quantity,
          exchange_instance_id,
          inventory_item_id,
          inventory_org_id,
          sub_inventory,
          serial_number,
          lot_number,
          inventory_item_uom,
          inventory_item_quantity
   from ahl_osp_order_lines
   where osp_order_id = p_osp_order_id
     and osp_order_line_id = p_osp_line_id;

--yazhou 26-Jul-2006 starts
-- bug fix #5412158

   CURSOR osp_line_details_csr2(p_osp_order_id IN NUMBER)
   IS
   select osp_order_line_id       ,
          object_version_number   ,
          osp_order_id            ,
          osp_line_number         ,
          workorder_id            ,
          status_code             ,
          service_item_id         ,
          service_item_description,
          service_item_uom_code   ,
          need_by_date            ,
          ship_by_date            ,
          po_line_id              ,
          po_line_type_id         ,
          oe_ship_line_id         ,
          oe_return_line_id       ,
          operation_id            ,
          quantity                ,
          exchange_instance_id    ,
          inventory_item_id       ,
          inventory_org_id        ,
          sub_inventory           ,
          serial_number           ,
          lot_number              ,
          inventory_item_uom      ,
          inventory_item_quantity
   from ahl_osp_order_lines a
   where osp_order_id = p_osp_order_id
   AND ((osp_line_number = (select min(osp_line_number)
                          from ahl_osp_order_lines
                          where osp_order_id = p_osp_order_id
                            and inventory_item_id = a.inventory_item_id
                            and inventory_org_id = a.inventory_org_id
                            and serial_number = a.serial_number))
        -- Added by jaramana on January 11, 2008 as without this the non-serialized items are not getting picked for shipments
        --for the Bug 5688387/5842229
        OR serial_number is null)
     AND oe_ship_line_id IS NULL
     AND oe_return_line_id IS NULL;

--yazhou 26-Jul-2006 ends

   /*
   CURSOR osp_line_details_csr3(p_osp_order_id IN NUMBER,
                                p_line_id IN NUMBER) IS
   select osp_order_line_id       ,
          object_version_number   ,
          osp_order_id            ,
          osp_line_number         ,
          workorder_id            ,
          status_code             ,
          service_item_id         ,
          service_item_description,
          service_item_uom_code   ,
          need_by_date            ,
          ship_by_date            ,
          po_line_id              ,
          po_line_type_id         ,
          oe_ship_line_id         ,
          oe_return_line_id       ,
          operation_id            ,
          quantity                ,
          exchange_instance_id    ,
          inventory_item_id       ,
          inventory_org_id        ,
          sub_inventory           ,
          serial_number           ,
          lot_number              ,
          inventory_item_uom      ,
          inventory_item_quantity
   from ahl_osp_order_lines
   where osp_order_id = p_osp_order_id
     AND (NVL(oe_ship_line_id, -9) = NVL(p_line_id, -8)
     OR   NVL(oe_return_line_id, -9) = NVL(p_line_id, -8));
   */

   /*
   mpothuku changed the cursor definition on 18-Jul-2007 for the Bug 5676360
   Some of the details collected from this cursor ex: the inventory_item_id etc over-write the ones retrieved from the
   shipment line. Because of the part number change ER, if the part number change is done,
   these details will not match the ones on the shipment line and lead to inconsistencies.
   So if the installation details are present we pick the information from IB or else we pick it from the osp order
   line itself. Please note that because of this, if someone chages the part from the OM UIs and then try to update
   other details from Shipment Line Details UI, the information on the osp order lines will over-write this.
   But this seem to be the existing behavior.
   */
   CURSOR osp_line_details_csr3(p_osp_order_id IN NUMBER,
                                p_line_id IN NUMBER) IS
   select ospl.osp_order_line_id       ,
          ospl.object_version_number   ,
          ospl.osp_order_id            ,
          ospl.osp_line_number         ,
          ospl.workorder_id            ,
          ospl.status_code             ,
          ospl.service_item_id         ,
          ospl.service_item_description,
          ospl.service_item_uom_code   ,
          ospl.need_by_date            ,
          ospl.ship_by_date            ,
          ospl.po_line_id              ,
          ospl.po_line_type_id         ,
          ospl.oe_ship_line_id         ,
          ospl.oe_return_line_id       ,
          ospl.operation_id            ,
          ospl.quantity                ,
          ospl.exchange_instance_id    ,
          decode(csi.instance_id, null, ospl.inventory_item_id, csi.inventory_item_id) inventory_item_id,
          ospl.inventory_org_id        ,
          ospl.sub_inventory           ,
          decode(csi.instance_id, null, ospl.serial_number, csi.serial_number) serial_number,
          decode(csi.instance_id, null, ospl.lot_number, csi.lot_number) lot_number,
          ospl.inventory_item_uom      ,
          ospl.inventory_item_quantity
     from ahl_osp_order_lines ospl,
          oe_order_lines_all oel,
          csi_t_transaction_lines tl,
          csi_t_txn_line_details tld,
          csi_item_instances csi
    where ospl.osp_order_id = p_osp_order_id
      AND (NVL(oe_ship_line_id, -9) = NVL(p_line_id, -8)
       OR NVL(oe_return_line_id, -9) = NVL(p_line_id, -8))
      AND oel.line_id = p_line_id
      AND oel.source_document_line_id = ospl.osp_order_line_id
      AND tl.source_transaction_id (+)= oel.line_id
      AND tl.source_transaction_table (+) = G_TRANSACTION_TABLE
      AND tl.transaction_line_id = tld.transaction_line_id(+)
      AND tld.instance_id = csi.instance_id(+);
  --mpothuku End

   CURSOR ahl_osp_work_csr(p_workorder_id IN NUMBER) IS
   --Modified by mpothuku on 22-Feb-06 to fix the Perf Bug #4919255
   /*
    SELECT wo.inventory_item_id,
           wo.serial_number,
           wo.item_instance_uom,
           wo.quantity,
           wo.item_instance_id,
           wo.project_id,
           wo.project_task_id,
           wo.ORGANIZATION_ID,
           wo.lot_number --jeli 12/01/05
    FROM AHL_WORKORDERS_OSP_V wo
    WHERE wo.workorder_id = p_workorder_id ;
   */
    SELECT vts.inventory_item_id,
        csii.serial_number,
        csii.unit_of_measure item_instance_uom,
        csii.quantity,
        vts.instance_id item_instance_id,
        vst.project_id,
        vts.project_task_id,
        vst.ORGANIZATION_ID,
        csii.lot_number
    FROM AHL_WORKORDERS wo,
        ahl_visits_b vst,
        ahl_visit_tasks_b vts,
        csi_item_instances csii
    WHERE wo.workorder_id = p_workorder_id
    AND wo.visit_task_id = vts.visit_task_id(+)
    AND vts.visit_id = vst.visit_id(+)
    AND vts.instance_id = csii.instance_id(+)
    AND wo.master_workorder_flag = 'N';

    l_work_det ahl_osp_work_csr%rowtype;

-- Changed by jaramana on June 3, 2005
/*
   CURSOR get_inv_inst_csr(p_inv_item_id   IN NUMBER,
                           p_inv_org_id    IN NUMBER,
                           p_serial_number IN VARCHAR2) IS
   SELECT INSTANCE_ID
     FROM csi_item_instances csi
    WHERE p_inv_item_id = csi.inventory_item_id
      and p_inv_org_id = csi.last_vld_organization_id
      and p_serial_number = csi.serial_number;
*/
   CURSOR get_inv_inst_csr(p_inv_item_id   IN NUMBER,
                           p_serial_number IN VARCHAR2) IS
   SELECT INSTANCE_ID
     FROM csi_item_instances csi
    WHERE p_inv_item_id = csi.inventory_item_id
      and p_serial_number = csi.serial_number;

   CURSOR get_inv_inst_from_lot_csr(p_inv_item_id IN NUMBER,
                                    p_lot_number  IN VARCHAR2) IS
   SELECT INSTANCE_ID
     FROM csi_item_instances csi
    WHERE csi.inventory_item_id = p_inv_item_id
      and csi.lot_number = p_lot_number;

--Modified by mpothuku on 06-Mar-06 to fix the Perf Bug #4919255
/*
   CURSOR validate_item(p_inventory_item_id IN NUMBER,
                        p_inventory_org_id  IN NUMBER,
                        p_serial_number     IN VARCHAR2,
                        p_lot_number        IN VARCHAR2) IS
   SELECT 1
   FROM  AHL_OSP_INV_ITEMS_V
   WHERE ORGANIZATION_ID = p_inventory_org_id
     AND INV_ITEM_ID = p_inventory_item_id
     AND NVL(SERIAL_NUMBER, 'X') = NVL(p_serial_number, 'X')
     AND NVL(LOT_NUMBER, 'X') = NVL(p_lot_number, 'X');
*/
   CURSOR validate_item(p_inventory_item_id IN NUMBER,
                        p_inventory_org_id  IN NUMBER
                       ) IS
   SELECT 1
   FROM  MTL_SYSTEM_ITEMS_B
   WHERE ORGANIZATION_ID = p_inventory_org_id
     AND INVENTORY_ITEM_ID = p_inventory_item_id;

   -- Cursor to get the exchange instance and all its details from a OSP Line Id.
   CURSOR exchange_instance_dtls_csr(p_osp_order_line_id IN NUMBER) IS
   select ospl.exchange_instance_id,
          csi.inventory_item_id,
          csi.serial_number,
          csi.lot_number,
          csi.quantity,
          csi.unit_of_measure,
          csi.last_vld_organization_id
   FROM ahl_osp_order_lines ospl, csi_item_instances csi
   WHERE ospl.osp_order_line_id = p_osp_order_line_id and
         csi.instance_id = ospl.exchange_instance_id;

   l_exchange_inst_dtls exchange_instance_dtls_csr%rowtype;

   --Added by mpothuku on 16-Jul-2007 to fix the Bug 6185894
   --Cursor to get the so line details
   CURSOR get_so_line_details(c_line_id IN NUMBER) IS
   SELECT open_flag,
          flow_status_code,
          ordered_quantity,
          cancelled_quantity
     FROM oe_order_lines_all
    WHERE line_id = c_line_id;

    l_get_so_line_details get_so_line_details%rowtype;
    --mpothuku End
--
  l_dummy NUMBER;
  I PLS_INTEGER;
  l_ship_date DATE;
  l_return_date DATE;
  l_ship_line_id NUMBER;
  l_return_line_id NUMBER;
  /*
  mpothuku updated on 06-Mar-06 to remove the ref to l_wo_rec as its not being used
  l_wo_rec ahl_osp_wo_csr%ROWTYPE;
  */
  l_curr_osp_type AHL_OSP_ORDERS_B.order_type_code%type;
  l_osp_line_det_type osp_line_details_csr%rowtype;
  l_index NUMBER;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_Line_Tbl';
  --Jerry added on 11/01/05 in order to fix bug 4580226
  l_old_inv_item_id NUMBER;
  l_old_serial_number VARCHAR2(100);
  l_old_quantity NUMBER;
  l_old_uom VARCHAR2(20);
  l_old_lot_number VARCHAR2(80); --jeli 12/01/05
  l_ship_index NUMBER;
  --Bug fix 4580226 ends
--
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
-- use user defined vendor service duration if available


    OPEN osp_order_header_csr(p_osp_order_id);
    FETCH osp_order_header_csr INTO l_osp_header_det;
    CLOSE osp_order_header_csr;

-- yazhou 31-Jul-2006 ends

  /*
  Added by mpothuku on 04-May-06
  The following Logic is used when creating shipment directly from Inventory item Search/Workorder Search UI
  Also its being used when creating shipments from the Create/Edit Shipment Line UI
  */

  IF (p_x_line_tbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_line_tbl.COUNT = ' || p_x_line_tbl.COUNT);
    END IF;
    FOR i IN p_x_line_tbl.FIRST..p_x_line_tbl.LAST LOOP
      -- Get the OSP Order Type if not known
      IF(p_x_line_tbl(i).osp_order_id IS NOT NULL AND
         p_x_line_tbl(i).osp_order_id <> FND_API.G_MISS_NUM AND
         l_curr_osp_type IS NULL) THEN
        OPEN get_osp_order_type_csr(p_x_line_tbl(i).osp_order_id);
        FETCH get_osp_order_type_csr into l_curr_osp_type;
        CLOSE get_osp_order_type_csr;
      END IF;

      -- Set the Order Type field in the Line Record
      IF (p_x_line_tbl(i).order_type IS NULL OR p_x_line_tbl(i).order_type = FND_API.G_MISS_CHAR) THEN
        p_x_line_tbl(i).order_type := l_curr_osp_type;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_line_tbl(i).order_type = ' || p_x_line_tbl(i).order_type ||
                                                           ', p_x_line_tbl(i).osp_order_id = ' || p_x_line_tbl(i).osp_order_id ||
                                                           ', p_x_line_tbl(i).osp_line_id = ' || p_x_line_tbl(i).osp_line_id ||
                                                           ', p_x_line_tbl(i).osp_line_flag = ' || p_x_line_tbl(i).osp_line_flag ||
                                                           ', p_x_line_tbl(i).line_id = ' || p_x_line_tbl(i).line_id);
      END IF;
      IF ((p_x_line_tbl(i).osp_order_id IS NOT NULL AND p_x_line_tbl(i).osp_order_id <> FND_API.G_MISS_NUM) AND
          p_x_line_tbl(i).osp_line_id IS NOT NULL AND p_x_line_tbl(i).osp_line_flag = 'Y') THEN
        -- Shipment Line is for a OSP Line
        IF p_x_line_tbl(i).line_id IS NULL THEN
          -- Ship Line Id is not known: Get the OSP Line Details from the OSP Line Id
          OPEN osp_line_details_csr(p_x_line_tbl(i).osp_order_id,
                                    p_x_line_tbl(i).osp_line_id);
          FETCH osp_line_details_csr INTO l_osp_line_det_type;
          IF osp_line_details_csr%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_PRIMARY_KEY_NULL');
            Fnd_Msg_Pub.ADD;
            CLOSE osp_line_details_csr;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          CLOSE osp_line_details_csr;
        ELSE
          /*
          One an SO is booked, it will not be possible to delete any of its lines. But the quantity can be set to 0.
          Once this is done, the status of the SO line becomes cancelled. We still show such lines on the
          Shipment Lines UI (The VO uses the source_document_id on the cancelled lines to get the osp_line_id.
          This association we do not delete when cancelling a booked line) and when user tries to update/delete
          such lines, the error reported in the Bug 6185894 is being ensued. It is because, the following cursor
          does not retrieve any records for such lines.
          OM does not happen to anyway allow deletes on booked lines and updates on cancelled lines.
          So we can check the status and throw an error up-front instead of changing the logic to make such records
          hit OM.
          */
          --Modified on 16-Jul-2007
          --Get the Shipment Line status.
          OPEN get_so_line_details(p_x_line_tbl(i).line_id);
          FETCH get_so_line_details INTO l_get_so_line_details;
          IF get_so_line_details%NOTFOUND THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Details not found for Shipment Line ID: '||p_x_line_tbl(i).line_id);
            END IF;
            FND_MESSAGE.SET_NAME('AHL', 'AHL_COM_NO_DATA_FOUND');
            FND_MSG_PUB.ADD;
            CLOSE get_so_line_details;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          CLOSE get_so_line_details;

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_get_so_line_details.open_flag: '||l_get_so_line_details.open_flag);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_get_so_line_details.flow_status_code: '||l_get_so_line_details.flow_status_code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_get_so_line_details.ordered_quantity: '||l_get_so_line_details.ordered_quantity);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_get_so_line_details.cancelled_quantity: '||l_get_so_line_details.cancelled_quantity);
          END IF;

          IF(nvl(l_get_so_line_details.open_flag,'Y') = 'N') THEN
            FND_MESSAGE.SET_NAME('AHL', 'AHL_OSP_OM_LINE_CLOSED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          --mpothuku End
          -- Get the OSP Line Details from the Ship Line Id
          OPEN osp_line_details_csr3(p_x_line_tbl(i).osp_order_id,
                                     p_x_line_tbl(i).line_id);
          FETCH osp_line_details_csr3 INTO l_osp_line_det_type;
          IF osp_line_details_csr3%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_PRIMARY_KEY_NULL');
            Fnd_Msg_Pub.ADD;
            CLOSE osp_line_details_csr3;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          CLOSE osp_line_details_csr3;
        END IF;

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
-- use user defined vendor service duration if available

        l_service_duration := null;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_header_det.vendor_id is '||l_osp_header_det.vendor_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_header_det.vendor_site_id is' ||l_osp_header_det.vendor_site_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_line_det_type.service_item_id is ' ||l_osp_line_det_type.service_item_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_line_det_type.inventory_item_id is ' ||l_osp_line_det_type.inventory_item_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_line_det_type.inventory_org_id is ' ||l_osp_line_det_type.inventory_org_id);
        END IF;

        IF l_osp_header_det.vendor_id is not null
        AND l_osp_header_det.vendor_site_id is not NULL
        AND l_osp_line_det_type.service_item_id is not null THEN

            OPEN ahl_max_service_duration_csr(l_osp_header_det.vendor_id, l_osp_header_det.vendor_site_id, p_osp_order_id,l_osp_line_det_type.inventory_item_id, l_osp_line_det_type.inventory_org_id, l_osp_line_det_type.serial_number);
            FETCH ahl_max_service_duration_csr INTO l_service_duration;
            CLOSE ahl_max_service_duration_csr;

        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_service_duration is '||l_service_duration);
        END IF;

        IF l_service_duration is null THEN
            -- Check if the Default Duration Profile has been Set
            IF (FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION') IS NULL OR FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION') = '') THEN
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
                --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: Vendor Service Duration');
                FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_VENDOR_SERVICE_DURATION'));
                FND_MSG_PUB.ADD;
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;

            l_service_duration := FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION');

        END IF;
-- yazhou 31-Jul-2006 ends


      END IF; -- Shipment Line is for a OSP Line

      IF p_x_line_tbl(i).osp_line_flag = 'Y' THEN
        -- Shipment Line is for an OSP Line
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'osp_line_flag is Y: Shipment Line is for an OSP Line');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_line_det_type.workorder_id = ' || l_osp_line_det_type.workorder_id ||
                                                               ', l_osp_line_det_type.osp_order_line_id = ' || l_osp_line_det_type.osp_order_line_id);
        END IF;

        --Jerry added on 11/01/05 in order to fix bug 4580226
        l_old_inv_item_id := p_x_line_tbl(i).inventory_item_id;
        l_old_serial_number := p_x_line_tbl(i).serial_number;
        l_old_quantity := p_x_line_tbl(i).ordered_quantity;
        l_old_uom :=p_x_line_tbl(i).order_quantity_uom;
        l_old_lot_number :=p_x_line_tbl(i).lot_number; --jeli 12/01/05
        --Debug statements added by mpothuku on 14-Dec-05
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_inv_item_id: ' || l_old_inv_item_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_serial_number: ' || l_old_serial_number);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_quantity: ' || l_old_quantity);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_uom: ' || l_old_uom);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_old_lot_number: ' || l_old_lot_number);
        END IF;
        --Bug fix 4580226 ends

        IF l_osp_line_det_type.workorder_id IS NOT NULL THEN
          -- Shipment Line Corresponds to an Work order
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_line_det_type.workorder_id is not null');
          END IF;

          -- Get the Workorder Details
          OPEN ahl_osp_work_csr(l_osp_line_det_type.workorder_id);
          FETCH ahl_osp_work_csr INTO l_work_det;
          CLOSE ahl_osp_work_csr;

          -- Get Details for Shipment Line from the Work order
          p_x_line_tbl(i).inventory_item_id    := l_work_det.inventory_item_id;
          p_x_line_tbl(i).serial_number        := l_work_det.serial_number;
          p_x_line_tbl(i).order_quantity_uom   := l_work_det.item_instance_uom;
          -- Changed by jaramana on 02-MAR-2010 for Bug 9307889
          -- Get the Quantity from the OSP Line instead of from the instance
          -- p_x_line_tbl(i).ordered_quantity     := l_work_det.quantity;
          p_x_line_tbl(i).ordered_quantity     := l_osp_line_det_type.inventory_item_quantity;
          p_x_line_tbl(i).project_id           := l_work_det.project_id;
          p_x_line_tbl(i).task_id              := l_work_det.project_task_id;
          p_x_line_tbl(i).osp_line_id          := l_osp_line_det_type.osp_order_line_id;
          p_x_line_tbl(i).osp_line_number      := l_osp_line_det_type.osp_line_number;
          p_x_line_tbl(i).csi_item_instance_id := l_work_det.item_instance_id;
          p_x_line_tbl(i).lot_number           := l_work_det.lot_number; --jeli 12/01/05

-- yazhou 07-Apr-2006 starts
-- Bug fix #4998349

          -- yazhou 26-Apr-2006 starts
          -- Bug fix#5189285

          -- For Exchange Order Return lines, use the exchange instance id instead
          IF  (p_x_line_tbl(i).operation <> 'D') AND
              ((p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) AND
              (p_x_line_tbl(i).order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE)) THEN

          -- yazhou 26-Apr-2006 ends
           /*
            IF (l_wo_rec.exchange_instance_id IS NULL OR l_wo_rec.exchange_instance_id = FND_API.G_MISS_NUM) THEN
            */
            --mpothuku updated on 06-Mar-06 to remove the ref to l_wo_rec as its not being used


            /* Commented out since exchange instance can be null
			IF (p_x_line_tbl(i).operation <> 'D') THEN
                IF (l_osp_line_det_type.exchange_instance_id IS NULL OR l_osp_line_det_type.exchange_instance_id = FND_API.G_MISS_NUM) THEN
                    -- Need to set exchange instance before creating return shipment line for exchange orders
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                        Fnd_Message.set_name('AHL', 'AHL_OSP_EXC_INST_ID_NULL');
                        Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                END IF;
            END IF;
            */

            IF (l_osp_line_det_type.exchange_instance_id IS NOT NULL AND
			   l_osp_line_det_type.exchange_instance_id <> FND_API.G_MISS_NUM) THEN

                p_x_line_tbl(i).csi_item_instance_id:= l_osp_line_det_type.exchange_instance_id;
                -- Get Details about the Exchange Instance
                OPEN ahl_exc_inst_details(p_x_line_tbl(i).csi_item_instance_id);
                FETCH ahl_exc_inst_details INTO p_x_line_tbl(i).inventory_item_id,
                                            p_x_line_tbl(i).serial_number,
                                            p_x_line_tbl(i).ordered_quantity,
                                            p_x_line_tbl(i).order_quantity_uom,
                                            p_x_line_tbl(i).lot_number; --jeli 12/01/05
                CLOSE ahl_exc_inst_details;
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Fetched Exchange Instance details: ' ||
                                   'item_instance_id = ' || p_x_line_tbl(i).csi_item_instance_id ||
                                   ', inventory_item_id = ' || p_x_line_tbl(i).inventory_item_id ||
                                   ', serial_number = ' || p_x_line_tbl(i).serial_number ||
                                   ', ordered_quantity = ' || p_x_line_tbl(i).ordered_quantity ||
                                   ', order_quantity_uom = ' || p_x_line_tbl(i).order_quantity_uom ||
                                   ', lot_number = ' || p_x_line_tbl(i).lot_number); --jeli 12/01/05
                END IF;
                --jeli 12/01/05

                --(jeli 12/01/05) Jerry added on 11/01/05 in order to fix bug 4580226
               --Added by mpothuku on 14-Dec-05 to fix the following validation that was raised when creating shipment
               --from Inventory Item Search UI.
               -- Validation only required if calling from front-end
               IF  (p_module_type is not null) AND
                    (p_x_line_tbl(i).inventory_item_id <> l_old_inv_item_id OR
                      NVL(p_x_line_tbl(i).serial_number, 'X') <> NVL(l_old_serial_number, 'X') OR
                      p_x_line_tbl(i).ordered_quantity <> l_old_quantity OR
                      p_x_line_tbl(i).order_quantity_uom <> l_old_uom OR
                      NVL(p_x_line_tbl(i).lot_number, 'X') <> NVL(l_old_lot_number, 'X')) THEN
                         Fnd_Message.set_name('AHL', 'AHL_OSP_ITEM_ATTR_NO_CHANGE');
                         Fnd_Msg_Pub.ADD;
                         RAISE Fnd_Api.g_exc_error;
               END IF;
               --Bug fix 4580226 ends

            ELSE    -- Exchange instance is null

             -- yazhou 26-Apr-2006 starts
             -- Bug fix#5189285

             -- restoring to the item entered by user if calling from front-end
             -- also try to derive and set exchange instance
             IF (p_module_type is not null) THEN

                 p_x_line_tbl(i).inventory_item_id :=l_old_inv_item_id;
                 p_x_line_tbl(i).serial_number := l_old_serial_number;
                 p_x_line_tbl(i).lot_number    := l_old_lot_number;
                 p_x_line_tbl(i).csi_item_instance_id := null;

                 -- If the serial number user entered corresponds to a tracked instance, derive the
                 --  instance number and update the Osp Order Line's Exchange Instance column transparently
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Exchange Instance id is null ' ||
                                   'l_osp_line_det_type.exchange_instance_id = ' || l_osp_line_det_type.exchange_instance_id);
                 END IF;


                 IF p_x_line_tbl(i).inventory_item_id IS NOT NULL  THEN

     			    IF p_x_line_tbl(i).serial_number IS NOT NULL  THEN

    			      OPEN get_inv_inst_csr(p_x_line_tbl(i).inventory_item_id, p_x_line_tbl(i).serial_number);
                      FETCH get_inv_inst_csr INTO p_x_line_tbl(i).csi_item_instance_id;
                      CLOSE get_inv_inst_csr;

    			    ELSIF p_x_line_tbl(i).lot_number IS NOT NULL THEN

    			      OPEN get_inv_inst_from_lot_csr(p_x_line_tbl(i).inventory_item_id, p_x_line_tbl(i).lot_number);
	                  FETCH get_inv_inst_from_lot_csr INTO p_x_line_tbl(i).csi_item_instance_id;
                      CLOSE get_inv_inst_from_lot_csr;

    			    END IF;  --  user entered SN AND/OR Lot number

                    --If the SN/LOT user entered corresponds to a non-tracked item
	    			-- simply ignore the serial number entered by the user without throwing an error.
		    	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_line_tbl.csi_item_instance_id = ' || p_x_line_tbl(i).csi_item_instance_id);
                    END IF;

    			    IF p_x_line_tbl(i).csi_item_instance_id IS NOT NULL THEN

    				   -- update the Osp Order Line's Exchange Instance column
        	           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Update_OSP_Line_Exch_Instance');
                       END IF;

    		          Update_OSP_Line_Exch_Instance(
                           p_osp_order_id      => p_x_line_tbl(i).osp_order_id,
                 	       p_osp_line_id       => p_x_line_tbl(i).osp_line_id,
                           p_exchange_instance_id  =>  p_x_line_tbl(i).csi_item_instance_id);

    			    ELSE

    				   -- ignore the SN/LOT number user entered
	     		       p_x_line_tbl(i).serial_number := NULL;
		    	       p_x_line_tbl(i).lot_number := NULL;
			           p_x_line_tbl(i).csi_item_instance_id:= null;

    				END IF; -- exchange instance is derived

    			  END IF;  -- user entered item

              ELSE  -- called from back-end

	     		       p_x_line_tbl(i).serial_number := NULL;
		    	       p_x_line_tbl(i).lot_number := NULL;
			           p_x_line_tbl(i).csi_item_instance_id:= null;


              END IF;  -- called from front-end

             -- yazhou 26-Apr-2006 ends

            END IF; --Exchange instance null check

          END IF;  -- Exchange Order Return Lines

          --Check that ship to or return instance is top node in CSI.
          -- If not unit, then throw error cause can't ship part of a unit.
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to perform Component Check.');
          END IF;

          IF p_x_line_tbl(i).csi_item_instance_id IS NOT NULL THEN
            OPEN ahl_csi_unit_test_csr(p_x_line_tbl(i).csi_item_instance_id);
            FETCH ahl_csi_unit_test_csr INTO l_dummy;
            IF (ahl_csi_unit_test_csr%NOTFOUND) THEN
              -- Instance is installed as a component
              CLOSE ahl_csi_unit_test_csr;
              IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_COMPONENT');
                Fnd_Msg_Pub.ADD;
              END IF;
              RAISE Fnd_Api.g_exc_error;
            END IF;
            CLOSE ahl_csi_unit_test_csr;
          END IF;

-- yazhou 07-Apr-2006 ends


          -- Do additional Validation, Defaulting if not deleting Ship Line
          IF (p_x_line_tbl(i).operation <> 'D') THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Not a Shipment Delete Operation');
            END IF;

            IF (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
              -- Ship-Only Line
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing a Ship-Only Line');
              END IF;
              -- Default the Ship Date if not already Set
              IF (p_x_line_tbl(i).schedule_ship_date IS NULL OR p_x_line_tbl(i).schedule_ship_date = FND_API.G_MISS_DATE) THEN

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
                IF p_x_line_tbl(i).order_type = 'BORROW' THEN
                  -- For Borrow Orders, Shipping Out happens after receiving
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE + l_service_duration;
                ELSE
                  -- For all other Orders, Shipping Date is defaulted to current date
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE;
                END IF;
-- yazhou 31-Jul-2006 ends

              END IF;  -- If Ship Date is not Set

              -- For Create only, check that no previous oe ship line exists for this job
--yazhou 06-Jun-2006 starts
--bug fix#5304095
              -- For Create only, check that no previous oe ship line exists for this job
              OPEN ahl_oe_ship_id_csr(p_x_line_tbl(i).osp_order_id,
                                      p_x_line_tbl(i).osp_line_id);
--yazhou 06-Jun-2006 ends


              FETCH ahl_oe_ship_id_csr INTO l_return_line_id;
              IF (ahl_oe_ship_id_csr%FOUND AND p_x_line_tbl(i).operation = 'C') THEN
                CLOSE ahl_oe_ship_id_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_LINE_DEFINED');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
              CLOSE ahl_oe_ship_id_csr;
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'No Duplicate Shipment Lines Found.');
              END IF;

              OPEN ahl_oe_schedule_date_csr(p_x_line_tbl(i).osp_order_id,
                                            p_x_line_tbl(i).csi_item_instance_id);
              FETCH ahl_oe_schedule_date_csr INTO l_ship_line_id, l_ship_date,
                                                  l_return_line_id, l_return_date;

              --If borrow, return line must be defined first
              -- Commented out by jaramana on June 3, 2005
              -- Since we support auto creation from the Inventory Service Order Project
              -- Ship and Return Lines may be created simultaneously. So cannot do this check
/*
              IF (p_x_line_tbl(i).order_type = 'BORROW' AND l_return_line_id IS NULL) THEN
                CLOSE ahl_oe_schedule_date_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_BORROW_ORDER');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
*/
              -- Check that the schedule ship dates are correct.
              IF (l_return_date IS NOT NULL) THEN
                --For Borrow, return date must not be > ship date
                IF(p_x_line_tbl(i).order_type = 'BORROW') THEN
                  IF (l_return_date > p_x_line_tbl(i).schedule_ship_date) THEN  -- Note that we are in the context of a Ship-only line
                    CLOSE ahl_oe_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;
                -- For exchange orders, the ship date can be after the return date (Advance Exchange)
                ELSIF (p_x_line_tbl(i).order_type <> AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
                  --For others, ship date must be before return date
                  IF (l_return_date < p_x_line_tbl(i).schedule_ship_date) THEN
                    CLOSE ahl_oe_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;  -- Return Date < Ship Date
                END IF; -- Borrow or Exchange or Other
              END IF; -- Return Date is not null
              CLOSE ahl_oe_schedule_date_csr;
            ELSIF  (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
              -- Return Line
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing a Return Line');
              END IF;
              IF (p_x_line_tbl(i).schedule_ship_date IS NULL OR p_x_line_tbl(i).schedule_ship_date = FND_API.G_MISS_DATE) THEN

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
                IF p_x_line_tbl(i).order_type = 'BORROW' THEN
                  -- For Borrow Orders, Receiving Date is defaulted to current date
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE;
                ELSE
                  -- For all other Orders, Receiving happens after Shipping
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE + l_service_duration;
                END IF;
-- yazhou 31-Jul-2006 ends

              END IF;  -- If Return Date is not Set

              IF p_x_line_tbl(i).return_reason_code IS NULL THEN
                 p_x_line_tbl(i).return_reason_code := FND_PROFILE.VALUE('AHL_OSP_OE_LINE_RET_REASON_CODE');
              END IF;

              -- For Create only, check that no previous oe return line exists for this job
--yazhou 06-Jun-2006 starts
--bug fix#5304095

              -- For Create only, check that no previous oe return line exists for this job
              OPEN ahl_oe_return_id_csr(p_x_line_tbl(i).osp_order_id,
                                        p_x_line_tbl(i).osp_line_id);
--yazhou 06-Jun-2006 ends
              FETCH ahl_oe_return_id_csr INTO l_dummy;
              IF (ahl_oe_return_id_csr%FOUND AND p_x_line_tbl(i).operation = 'C') THEN
                CLOSE ahl_oe_return_id_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_RETURN_LINE_DEFINED');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
              CLOSE ahl_oe_return_id_csr;

              OPEN ahl_oe_schedule_date_csr(p_x_line_tbl(i).osp_order_id,
                                            p_x_line_tbl(i).csi_item_instance_id);
              FETCH ahl_oe_schedule_date_csr INTO l_ship_line_id, l_ship_date,
                                                  l_return_line_id, l_return_date;

              -- Loan Order ship line check removed by jaramana on June 3, 2005

              -- Check that the schedule ship dates are correct.
              IF (l_ship_date IS NOT NULL) THEN
                --For Borrow, ship date must not be < return date
                IF(p_x_line_tbl(i).order_type = 'BORROW') THEN
                  IF (l_ship_date < p_x_line_tbl(i).schedule_ship_date) THEN  -- Note that we are in the context of a Return line
                    CLOSE ahl_oe_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;
                -- For exchange orders, the ship date can be after the return date (Advance Exchange)
                ELSIF (p_x_line_tbl(i).order_type <> AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
                  --For others, return date must be after the ship date
                  IF (l_ship_date > p_x_line_tbl(i).schedule_ship_date) THEN
                    CLOSE ahl_oe_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF; -- Ship Date > Return Date
                END IF; -- Borrow or Exchange or Other
              END IF; -- Ship Date is not null
              CLOSE ahl_oe_schedule_date_csr;
            END IF; -- Line Type Check: Ship or Return
          END IF; -- Line Operation is not 'D'
        ELSIF l_osp_line_det_type.osp_order_line_id IS NOT NULL THEN   -- workorder_id is null
          -- Shipment Line does not correspond to a work order, But still corresponds to a OSP Line
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Workorder Id is null and osp_order_line_id is not null');
          END IF;
          -- Begin changes by jaramana on August 27, 2005 to fix the bug for exchange orders
          -- (without work orders), where the return line incorrectly picks up the item of the ship line
          -- If the user had picked a new item, save it in a temporary variable so that
          -- it can be used later if found applicable.
          l_dummy := p_x_line_tbl(i).inventory_item_id;
          -- End changes by jaramana on August 27, 2005
          -- Get Details for Shipment Line from the OSP Order Line
          p_x_line_tbl(i).inventory_item_id := l_osp_line_det_type.inventory_item_id;
          p_x_line_tbl(i).serial_number := l_osp_line_det_type.serial_number;
          p_x_line_tbl(i).order_quantity_uom:= l_osp_line_det_type.INVENTORY_ITEM_UOM;
          p_x_line_tbl(i).ordered_quantity:= l_osp_line_det_type.inventory_item_quantity;
          p_x_line_tbl(i).project_id:= null;
          p_x_line_tbl(i).task_id:= null;
          p_x_line_tbl(i).osp_line_id := l_osp_line_det_type.osp_order_line_id;
          p_x_line_tbl(i).osp_line_number := l_osp_line_det_type.osp_line_number;
	      --Added by mpothuku on 9-Nov-05 to fix the Sub-Inventory not getting defaulted issue.
          -- Additional condition for defaulting added by yazhou on July 26, 2006 bug fix#5109272
          -- Default the subinventory from the OSP Line only if
          -- creating Shipment for the Entire OSP Order.
          IF (p_x_line_tbl.COUNT > 1) THEN
		  p_x_line_tbl(i).subinventory := l_osp_line_det_type.sub_inventory;
          END IF;
		  p_x_line_tbl(i).lot_number := l_osp_line_det_type.lot_number; --jeli 12/01/05

          IF l_osp_line_det_type.serial_number IS NOT NULL THEN
            OPEN get_inv_inst_csr(l_osp_line_det_type.inventory_item_id,
                                  -- l_osp_line_det_type.inventory_org_id,  -- Changed by jaramana on June 3, 2005
                                  l_osp_line_det_type.serial_number);
            FETCH get_inv_inst_csr INTO p_x_line_tbl(i).csi_item_instance_id;
            CLOSE get_inv_inst_csr;
          ELSE
            p_x_line_tbl(i).csi_item_instance_id:= null;
          END IF;
          -- Begin changes by jaramana on August 27, 2005 to fix the bug for exchange orders
          -- (without work orders), where the return line incorrectly picks up the values
          -- corresponding to the ship line: Serial Number even if the Exch. Instance
          -- is not set and Item even if the Exch Instance is set and is of a different
          -- item than the ship item.
          -- For Exchange Order Return lines, use the exchange instance id instead

-- yazhou 07-Apr-2006 starts
-- Bug fix #4998349

          -- yazhou 26-Apr-2006 starts
          -- Bug fix#5189285

          -- For Exchange Order Return lines, use the exchange instance id instead
          IF  (p_x_line_tbl(i).operation <> 'D') AND
              ((p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) AND
              (p_x_line_tbl(i).order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE)) THEN

          -- yazhou 26-Apr-2006 ends

            /*
            IF (l_wo_rec.exchange_instance_id IS NULL OR l_wo_rec.exchange_instance_id = FND_API.G_MISS_NUM) THEN
            */
            --mpothuku updated on 06-Mar-06 to remove the ref to l_wo_rec as its not being used


            /* Commented out since exchange instance can be null
			IF (p_x_line_tbl(i).operation <> 'D') THEN
                IF (l_osp_line_det_type.exchange_instance_id IS NULL OR l_osp_line_det_type.exchange_instance_id = FND_API.G_MISS_NUM) THEN
                    -- Need to set exchange instance before creating return shipment line for exchange orders
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                        Fnd_Message.set_name('AHL', 'AHL_OSP_EXC_INST_ID_NULL');
                        Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                END IF;
            END IF;
            */

            IF (l_osp_line_det_type.exchange_instance_id IS NOT NULL AND
			   l_osp_line_det_type.exchange_instance_id <> FND_API.G_MISS_NUM) THEN

                p_x_line_tbl(i).csi_item_instance_id:= l_osp_line_det_type.exchange_instance_id;
                -- Get Details about the Exchange Instance
                OPEN ahl_exc_inst_details(p_x_line_tbl(i).csi_item_instance_id);
                FETCH ahl_exc_inst_details INTO p_x_line_tbl(i).inventory_item_id,
                                            p_x_line_tbl(i).serial_number,
                                            p_x_line_tbl(i).ordered_quantity,
                                            p_x_line_tbl(i).order_quantity_uom,
                                            p_x_line_tbl(i).lot_number; --jeli 12/01/05
                CLOSE ahl_exc_inst_details;
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Fetched Exchange Instance details: ' ||
                                   'item_instance_id = ' || p_x_line_tbl(i).csi_item_instance_id ||
                                   ', inventory_item_id = ' || p_x_line_tbl(i).inventory_item_id ||
                                   ', serial_number = ' || p_x_line_tbl(i).serial_number ||
                                   ', ordered_quantity = ' || p_x_line_tbl(i).ordered_quantity ||
                                   ', order_quantity_uom = ' || p_x_line_tbl(i).order_quantity_uom ||
                                   ', lot_number = ' || p_x_line_tbl(i).lot_number); --jeli 12/01/05
                END IF;
                --jeli 12/01/05

                --(jeli 12/01/05) Jerry added on 11/01/05 in order to fix bug 4580226
               --Added by mpothuku on 14-Dec-05 to fix the following validation that was raised when creating shipment
               --from Inventory Item Search UI.
               -- Validation only required if calling from front-end
               IF  (p_module_type is not null) AND
                    (p_x_line_tbl(i).inventory_item_id <> l_old_inv_item_id OR
                      NVL(p_x_line_tbl(i).serial_number, 'X') <> NVL(l_old_serial_number, 'X') OR
                      p_x_line_tbl(i).ordered_quantity <> l_old_quantity OR
                      p_x_line_tbl(i).order_quantity_uom <> l_old_uom OR
                      NVL(p_x_line_tbl(i).lot_number, 'X') <> NVL(l_old_lot_number, 'X')) THEN
                         Fnd_Message.set_name('AHL', 'AHL_OSP_ITEM_ATTR_NO_CHANGE');
                         Fnd_Msg_Pub.ADD;
                         RAISE Fnd_Api.g_exc_error;
               END IF;
               --Bug fix 4580226 ends

            ELSE    -- Exchange instance is null

             -- yazhou 26-Apr-2006 starts
             -- Bug fix#5189285

             -- restoring to the item entered by user if calling from front-end
             -- also try to derive and set exchange instance
             IF (p_module_type is not null) THEN

                 p_x_line_tbl(i).inventory_item_id :=l_old_inv_item_id;
                 p_x_line_tbl(i).serial_number := l_old_serial_number;
                 p_x_line_tbl(i).lot_number    := l_old_lot_number;
                 p_x_line_tbl(i).csi_item_instance_id := null;

                 -- If the serial number user entered corresponds to a tracked instance, derive the
                 --  instance number and update the Osp Order Line's Exchange Instance column transparently
                 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Exchange Instance id is null ' ||
                                   'l_osp_line_det_type.exchange_instance_id = ' || l_osp_line_det_type.exchange_instance_id);
                 END IF;


                 IF p_x_line_tbl(i).inventory_item_id IS NOT NULL  THEN

     			    IF p_x_line_tbl(i).serial_number IS NOT NULL  THEN

    			      OPEN get_inv_inst_csr(p_x_line_tbl(i).inventory_item_id, p_x_line_tbl(i).serial_number);
                      FETCH get_inv_inst_csr INTO p_x_line_tbl(i).csi_item_instance_id;
                      CLOSE get_inv_inst_csr;

    			    ELSIF p_x_line_tbl(i).lot_number IS NOT NULL THEN

    			      OPEN get_inv_inst_from_lot_csr(p_x_line_tbl(i).inventory_item_id, p_x_line_tbl(i).lot_number);
	                  FETCH get_inv_inst_from_lot_csr INTO p_x_line_tbl(i).csi_item_instance_id;
                      CLOSE get_inv_inst_from_lot_csr;

    			    END IF;  --  user entered SN AND/OR Lot number

                    --If the SN/LOT user entered corresponds to a non-tracked item
	    			-- simply ignore the serial number entered by the user without throwing an error.
		    	    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_x_line_tbl.csi_item_instance_id = ' || p_x_line_tbl(i).csi_item_instance_id);
                    END IF;

    			    IF p_x_line_tbl(i).csi_item_instance_id IS NOT NULL THEN

    				   -- update the Osp Order Line's Exchange Instance column
        	           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Update_OSP_Line_Exch_Instance');
                       END IF;

    		          Update_OSP_Line_Exch_Instance(
                           p_osp_order_id      => p_x_line_tbl(i).osp_order_id,
                 	       p_osp_line_id       => p_x_line_tbl(i).osp_line_id,
                           p_exchange_instance_id  =>  p_x_line_tbl(i).csi_item_instance_id);

    			    ELSE

    				   -- ignore the SN/LOT number user entered
	     		       p_x_line_tbl(i).serial_number := NULL;
		    	       p_x_line_tbl(i).lot_number := NULL;
			           p_x_line_tbl(i).csi_item_instance_id:= null;

    				END IF; -- exchange instance is derived

    			  END IF;  -- user entered item

              ELSE  -- called from back-end

	     		       p_x_line_tbl(i).serial_number := NULL;
		    	       p_x_line_tbl(i).lot_number := NULL;
			           p_x_line_tbl(i).csi_item_instance_id:= null;


              END IF;  -- called from front-end

             -- yazhou 26-Apr-2006 ends

            END IF; --Exchange instance null check

          END IF;  -- Exchange Order Return Lines

          --Check that ship to or return instance is top node in CSI.
          -- If not unit, then throw error cause can't ship part of a unit.
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to perform Component Check.');
          END IF;

        IF p_x_line_tbl(i).csi_item_instance_id IS NOT NULL THEN
          OPEN ahl_csi_unit_test_csr(p_x_line_tbl(i).csi_item_instance_id);
          FETCH ahl_csi_unit_test_csr INTO l_dummy;
          IF (ahl_csi_unit_test_csr%NOTFOUND) THEN
            -- Instance is installed as a component
            CLOSE ahl_csi_unit_test_csr;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_COMPONENT');
              Fnd_Msg_Pub.ADD;
            END IF;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          CLOSE ahl_csi_unit_test_csr;
        END IF;

-- yazhou 07-Apr-2006 ends



          -- Do additional Validation, Defaulting if not deleting Ship Line
          IF (p_x_line_tbl(i).operation <> 'D') THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Not a Shipment Delete Operation');
            END IF;
            IF (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
              -- Ship-Only Line
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing a Ship-Only Line');
              END IF;
              -- Default the Ship Date if not already Set
              IF (p_x_line_tbl(i).schedule_ship_date IS NULL OR p_x_line_tbl(i).schedule_ship_date = FND_API.G_MISS_DATE) THEN

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
                IF p_x_line_tbl(i).order_type = 'BORROW' THEN
                  -- For Borrow Orders, Shipping Out happens after receiving
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE + l_service_duration;
                ELSE
                  -- For all other Orders, Shipping Date is defaulted to current date
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE;
                END IF;
-- yazhou 31-Jul-2006 ends

              END IF;  -- If Ship Date is not Set

              --For Create only, check that no previous oe ship line for the Item
--yazhou 06-Jun-2006 starts
--bug fix#5304095

              -- For Create only, check that no previous oe return line exists for this job
              OPEN ahl_oe_ship_id_csr(p_x_line_tbl(i).osp_order_id,
                                        p_x_line_tbl(i).osp_line_id);
/*
              OPEN ahl_oe_ship_id_Inv_csr(p_x_line_tbl(i).osp_order_id,
                                          p_x_line_tbl(i).inventory_item_id,
                                          p_x_line_tbl(i).inventory_org_id,
                                          p_x_line_tbl(i).subinventory,
                                          p_x_line_tbl(i).serial_number,
                                          p_x_line_tbl(i).lot_number,
                                          p_x_line_tbl(i).inventory_item_uom);
*/
              FETCH ahl_oe_ship_id_csr INTO l_return_line_id;
              IF (ahl_oe_ship_id_csr%FOUND AND p_x_line_tbl(i).operation = 'C') THEN
                CLOSE ahl_oe_ship_id_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_LINE_DEFINED');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
              CLOSE ahl_oe_ship_id_csr;

--yazhou 06-Jun-2006 ends

              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'No Duplicate Shipment Lines Found.');
              END IF;

              OPEN ahl_oe_Inv_schedule_date_csr(p_x_line_tbl(i).osp_order_id,
                                                p_x_line_tbl(i).inventory_item_id,
                                                p_x_line_tbl(i).inventory_org_id,
                                                p_x_line_tbl(i).subinventory,
                                                p_x_line_tbl(i).serial_number,
                                                p_x_line_tbl(i).lot_number,
                                                p_x_line_tbl(i).inventory_item_uom);
              FETCH ahl_oe_Inv_schedule_date_csr INTO l_ship_line_id, l_ship_date,
                                                      l_return_line_id, l_return_date;

              --If borrow, return line must be defined first
              -- Commented out by jaramana on June 3, 2005
              -- Since we support auto creation from the Inventory Service Order Project
              -- Ship and Return Lines may be created simultaneously. So cannot do this check
/*
              IF (p_x_line_tbl(i).order_type = 'BORROW' AND l_return_line_id IS NULL) THEN
                CLOSE ahl_oe_Inv_schedule_date_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_BORROW_ORDER');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
*/
              --Check that the schedule ship dates are correct.
              IF (l_return_date IS NOT NULL) THEN
                --For Borrow, return date must not be > ship date
                IF(p_x_line_tbl(i).order_type = 'BORROW') THEN
                  IF (l_return_date > p_x_line_tbl(i).schedule_ship_date) THEN -- Note that we are in the context of a Ship-only line
                    CLOSE ahl_oe_Inv_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;
                  -- For exchange orders, the ship date can be after the return date (Advance Exchange)
                ELSIF (p_x_line_tbl(i).order_type <> AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
                  --For others, ship date must be before return date
                  IF (l_return_date < p_x_line_tbl(i).schedule_ship_date) THEN
                    CLOSE ahl_oe_Inv_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;  -- Return Date < Ship Date
                END IF;  -- Borrow or Exchange or Other
              END IF; -- Return Date is not null
              CLOSE ahl_oe_Inv_schedule_date_csr;
            ELSIF  (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Processing a Return Line');
              END IF;
              IF (p_x_line_tbl(i).schedule_ship_date IS NULL OR p_x_line_tbl(i).schedule_ship_date = FND_API.G_MISS_DATE) THEN

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
                IF p_x_line_tbl(i).order_type = 'BORROW' THEN
                  -- For Borrow Orders, Receiving Date is defaulted to current date
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE;
                ELSE
                  -- For all other Orders, Receiving happens after Shipping
                  p_x_line_tbl(i).schedule_ship_date := SYSDATE + l_service_duration;
                END IF;
-- yazhou 31-Jul-2006 ends

              END IF;  -- If Return Date is not Set

              IF p_x_line_tbl(i).return_reason_code IS NULL THEN
                 p_x_line_tbl(i).return_reason_code := FND_PROFILE.VALUE('AHL_OSP_OE_LINE_RET_REASON_CODE');
              END IF;

              --For Create only, check that no previous oe return line exists for the Item
--yazhou 06-Jun-2006 starts
--bug fix#5304095

              -- For Create only, check that no previous oe return line exists for this job
              OPEN ahl_oe_return_id_csr(p_x_line_tbl(i).osp_order_id,
                                        p_x_line_tbl(i).osp_line_id);
/*              OPEN ahl_oe_inv_return_id_csr(p_x_line_tbl(i).osp_order_id,
                                            p_x_line_tbl(i).inventory_item_id,
                                            p_x_line_tbl(i).inventory_org_id,
                                            p_x_line_tbl(i).subinventory,
                                            p_x_line_tbl(i).serial_number,
                                            p_x_line_tbl(i).lot_number,
                                            p_x_line_tbl(i).inventory_item_uom);
  */


              FETCH ahl_oe_return_id_csr INTO l_dummy;

              IF (ahl_oe_return_id_csr%FOUND AND p_x_line_tbl(i).operation = 'C') THEN

                CLOSE ahl_oe_return_id_csr;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                  Fnd_Message.set_name('AHL', 'AHL_OSP_RETURN_LINE_DEFINED');
                  Fnd_Msg_Pub.ADD;
                END IF;
                RAISE Fnd_Api.g_exc_error;
              END IF;
              CLOSE ahl_oe_return_id_csr;

--yazhou 06-Jun-2006 ends

              OPEN ahl_oe_Inv_schedule_date_csr(p_x_line_tbl(i).osp_order_id,
                                                p_x_line_tbl(i).inventory_item_id,
                                                p_x_line_tbl(i).inventory_org_id,
                                                p_x_line_tbl(i).subinventory,
                                                p_x_line_tbl(i).serial_number,
                                                p_x_line_tbl(i).lot_number,
                                                p_x_line_tbl(i).inventory_item_uom);
              FETCH ahl_oe_Inv_schedule_date_csr INTO l_ship_line_id, l_ship_date,
                                                      l_return_line_id, l_return_date;

              -- Loan Order ship line check removed by jaramana on June 3, 2005

              -- Check that the schedule ship dates are correct.
              IF (l_ship_date IS NOT NULL) THEN
                --For Borrow, ship date must not be < return date
                IF(p_x_line_tbl(i).order_type = 'BORROW') THEN
                  IF (l_ship_date < p_x_line_tbl(i).schedule_ship_date) THEN  -- Note that we are in the context of a Return line
                    CLOSE ahl_oe_Inv_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;
                -- For exchange orders, the ship date can be after the return date (Advance Exchange)
                ELSIF (p_x_line_tbl(i).order_type <> AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
                  --For others, return date must be after the ship date
                  IF (l_ship_date > p_x_line_tbl(i).schedule_ship_date) THEN
                    CLOSE ahl_oe_Inv_schedule_date_csr;
                    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                      Fnd_Message.set_name('AHL', 'AHL_OSP_SCHEDULE_DATE_ERROR');
                      Fnd_Msg_Pub.ADD;
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
                  END IF;  -- Ship Date > Return Date
                END IF;  -- Borrow or Exchange or Other
              END IF;  -- Ship Date is not null
              CLOSE ahl_oe_Inv_schedule_date_csr;
            END IF;  -- Line Type Check: Ship or Return
          END IF;  -- Line Operation is not 'D'
        END IF;  -- Work Order or OSP Order Line Id is not Null
      ELSE
        -- OSP Line Flag is Not Y: Shipment Line is for a spare part or tool.
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'osp_line_flag is NOT Y: Shipment Line is for a spare part or tool.');
        END IF;
        p_x_line_tbl(i).osp_line_id := null;
        p_x_line_tbl(i).osp_line_number := null;

        IF p_x_line_tbl(i).schedule_ship_date < TRUNC(sysdate) THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_DATE_LT_SYS');
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.g_exc_error;
        END IF;

        IF (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID')) THEN
          p_x_line_tbl(i).line_type := 'SHIP';
        ELSIF (p_x_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID')) THEN
          p_x_line_tbl(i).line_type := 'RETURN';
        ELSE
          Fnd_Message.set_name('AHL', 'AHL_OSP_LINE_TYPE_NULL');
          Fnd_Msg_Pub.ADD;
        END IF;
        IF p_x_line_tbl(i).line_type IS NULL THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_LINE_TYPE_NULL');
          Fnd_Msg_Pub.ADD;
        ELSIF p_x_line_tbl(i).line_type = 'RETURN' AND p_x_line_tbl(i).return_reason_code IS NULL THEN
           Fnd_Message.set_name('AHL', 'AHL_OSP_RETURN_REASON_NULL');
           Fnd_Msg_Pub.ADD;
        END IF;

        IF p_x_line_tbl(i).osp_order_id IS NULL THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_PRIMARY_KEY_NULL');
            Fnd_Msg_Pub.ADD;
        END IF;


        -- Validate the Spare part to be shipped
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to validate spare item to be shipped with ' ||
                            'p_x_line_tbl(i).inventory_item_id = ' || p_x_line_tbl(i).inventory_item_id ||
                            ', p_x_line_tbl(i).inventory_org_id = ' || p_x_line_tbl(i).inventory_org_id ||
                            ', p_x_line_tbl(i).serial_number = ' || p_x_line_tbl(i).serial_number ||
                            ', p_x_line_tbl(i).LOT_NUMBER = ' || p_x_line_tbl(i).LOT_NUMBER);
        END IF;
        IF p_x_line_tbl(i).line_id IS NULL THEN

        OPEN validate_item(p_x_line_tbl(i).inventory_item_id,
                           p_x_line_tbl(i).inventory_org_id);
        --Following arguments are removed by mpothuku on 06-Mar-06 to fix the Perf Bug #4919255
        --We are deliberately escaping the Validations of serial number and lot number for now.
                           --p_x_line_tbl(i).serial_number,
                           --p_x_line_tbl(i).LOT_NUMBER
        FETCH validate_item INTO l_dummy;
        IF validate_item%NOTFOUND THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_INV_ITEM');
          Fnd_Msg_Pub.ADD;
          CLOSE validate_item;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE validate_item;
        END IF; -- IF p_x_line_tbl(i).line_id IS NULL
      END IF; -- OSP Line Flag is Y or Not Y

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed Processing Ship Line with index i = ' || i);
      END IF;
    END LOOP;

  /*
  Added by mpothuku on 04-May-06
  The following Logic is used when creating shipment from Edit Osp Order UI's "Create Shipment" Action
  */

  ELSIF p_operation_flag = 'C' THEN  -- Line Table Count is Zero
    -- Creating Shipment using OSP Header
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Line Table Count is Zero: Creating Shipment using OSP Header');
    END IF;

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
/*
    OPEN osp_order_header_csr(p_osp_order_id => p_osp_order_id);
    FETCH osp_order_header_csr INTO l_osp_header_det;
    CLOSE osp_order_header_csr;
*/
-- yazhou 31-Jul-2006 ends

    l_index := 0;
    FOR I IN osp_line_details_csr2(p_osp_order_id) LOOP
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Getting details for OSP Line with id ' || I.osp_order_line_id);
      END IF;
      -- Modified by jaramana on January 11, 2008 to fix the Bug 5688387/5842229
      l_index := l_index + 2;
      -- First Prepare data for Return Lines
      p_x_line_tbl(l_index).line_id := NULL;
      p_x_line_tbl(l_index).line_number := NULL;
      p_x_line_tbl(l_index).header_id := l_osp_header_det.OE_HEADER_ID;
      p_x_line_tbl(l_index).order_type := l_osp_header_det.ORDER_TYPE_CODE;
      p_x_line_tbl(l_index).line_type_id := FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID');
      p_x_line_tbl(l_index).line_type := 'RETURN';
      p_x_line_tbl(l_index).operation := 'C';
      /* NOTE: Exchange Order is handled in a special way below
         after the ship-only lines are created*/
      p_x_line_tbl(l_index).inventory_item_id := I.inventory_item_id;
      p_x_line_tbl(l_index).inventory_org_id := I.INVENTORY_ORG_ID;
      p_x_line_tbl(l_index).inventory_item := NULL;
      p_x_line_tbl(l_index).LOT_NUMBER := I.LOT_NUMBER;
      p_x_line_tbl(l_index).INVENTORY_ITEM_UOM := NULL;
      p_x_line_tbl(l_index).INVENTORY_ITEM_QUANTITY := NULL;
      p_x_line_tbl(l_index).serial_number := I.SERIAL_NUMBER;
      p_x_line_tbl(l_index).csi_item_instance_id := NULL;
      p_x_line_tbl(l_index).ordered_quantity := I.INVENTORY_ITEM_QUANTITY;
      p_x_line_tbl(l_index).order_quantity_uom := I.INVENTORY_ITEM_UOM;

      -- Default the Return Reason from the Profile
      p_x_line_tbl(l_index).return_reason_code := FND_PROFILE.VALUE('AHL_OSP_OE_LINE_RET_REASON_CODE');
      IF p_x_line_tbl(l_index).return_reason_code IS NULL THEN
        FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
        -- @@@@@ jaramana June 4, 2004: May become a translation issue
        --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: OM Line Return Reason');
        FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_OE_LINE_RET_REASON_CODE'));
        FND_MSG_PUB.ADD;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      p_x_line_tbl(l_index).return_reason := NULL;

-- yazhou 31-Jul-2006 starts
-- bug fix#5442904
-- use user defined vendor service duration if available

        l_service_duration := null;

        IF l_osp_header_det.vendor_id is not null
        AND l_osp_header_det.vendor_site_id is not NULL THEN

            OPEN ahl_max_service_duration_csr(l_osp_header_det.vendor_id, l_osp_header_det.vendor_site_id, p_osp_order_id,I.inventory_item_id,I.INVENTORY_ORG_ID,I.SERIAL_NUMBER );
            FETCH ahl_max_service_duration_csr INTO l_service_duration;
            CLOSE ahl_max_service_duration_csr;

        END IF;

        IF l_service_duration is null THEN
            -- Check if the Default Duration Profile has been Set
            IF (FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION') IS NULL OR FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION') = '') THEN
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
                --FND_MESSAGE.SET_TOKEN('PROFILE', 'AHL: Vendor Service Duration');
                FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_VENDOR_SERVICE_DURATION'));
                FND_MSG_PUB.ADD;
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;

            l_service_duration := FND_PROFILE.VALUE('AHL_VENDOR_SERVICE_DURATION');

        END IF;


      IF p_x_line_tbl(l_index).order_type = 'BORROW' THEN
        -- For Borrow Orders, the Return Shipment is defaulted to current date
        p_x_line_tbl(l_index).schedule_ship_date := SYSDATE;
      ELSE
        -- For all other types of orders, the Return Shipment happens x days after current date
        p_x_line_tbl(l_index).schedule_ship_date := SYSDATE + l_service_duration;
      END IF;
-- yazhou 31-Jul-2006 ends

      p_x_line_tbl(l_index).packing_instructions := NULL;
      p_x_line_tbl(l_index).ship_from_org := NULL;
      p_x_line_tbl(l_index).ship_from_org_id := I.INVENTORY_ORG_ID;
      p_x_line_tbl(l_index).fob_point := NULL;
      p_x_line_tbl(l_index).fob_point_code := NULL;
      p_x_line_tbl(l_index).freight_carrier := NULL;
      p_x_line_tbl(l_index).freight_carrier_code := NULL;
      p_x_line_tbl(l_index).freight_terms := NULL;
      p_x_line_tbl(l_index).freight_terms_code := NULL;
      p_x_line_tbl(l_index).shipment_priority_code := NULL;
      p_x_line_tbl(l_index).shipment_priority := NULL;
      p_x_line_tbl(l_index).shipping_method_code := NULL;
      p_x_line_tbl(l_index).shipping_method := NULL;
      --Jeli updated the following line for fixing the sub-inventory default issue
      --found by AE on 11-08-05
      --p_x_line_tbl(l_index).subinventory := NULL;
      p_x_line_tbl(l_index).subinventory := I.sub_inventory;
      p_x_line_tbl(l_index).osp_order_id := I.OSP_ORDER_ID;
      p_x_line_tbl(l_index).osp_order_number := NULL;
      p_x_line_tbl(l_index).osp_line_id := I.OSP_ORDER_LINE_ID;
      p_x_line_tbl(l_index).osp_line_number := I.OSP_LINE_NUMBER;
      p_x_line_tbl(l_index).instance_id := NULL;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line based and sub_inv='||p_x_line_tbl(l_index).subinventory);
      END IF;

      -- Get additional details from the Work order, if the OSP Line is work order based
      IF I.WORKORDER_ID IS NOT NULL THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line is Work order based. Getting details from Workorder with id ' || I.WORKORDER_ID);
        END IF;
        OPEN ahl_osp_work_csr(I.WORKORDER_ID);
        FETCH ahl_osp_work_csr INTO l_work_det;
        -- jaramana June 4, 2005: Added check for Workorder
        IF(ahl_osp_work_csr%NOTFOUND) THEN
          FND_MESSAGE.Set_Name(G_APP_NAME, 'AHL_OSP_LN_INV_WO');
          FND_MESSAGE.Set_Token('WORKORDER_ID', I.WORKORDER_ID);
          CLOSE ahl_osp_work_csr;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE ahl_osp_work_csr;
        p_x_line_tbl(l_index).inventory_item_id :=  l_work_det.inventory_item_id;
        p_x_line_tbl(l_index).serial_number :=  l_work_det.serial_number;
        p_x_line_tbl(l_index).order_quantity_uom:=  l_work_det.item_instance_uom;
        -- Changed by jaramana on 02-MAR-2010 for Bug 9307889
        -- Get the Quantity from the OSP Line instead of from the instance
        -- p_x_line_tbl(l_index).ordered_quantity:=  l_work_det.quantity;
        p_x_line_tbl(l_index).ordered_quantity := I.inventory_item_quantity;
        p_x_line_tbl(l_index).project_id := l_work_det.project_id;
        p_x_line_tbl(l_index).task_id := l_work_det.project_task_id;
        p_x_line_tbl(l_index).csi_item_instance_id:=  l_work_det.item_instance_id;
        p_x_line_tbl(l_index).ship_from_org_id:= l_work_det.ORGANIZATION_ID;

        --Added by mpothuku on 04-May-06 to fix the Bug 5113542
        --Check that ship to or return instance is top node in CSI.
        -- If not unit, then throw error cause can't ship part of a unit.
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to perform Component Check.');
        END IF;

        IF p_x_line_tbl(l_index).csi_item_instance_id IS NOT NULL THEN
          OPEN ahl_csi_unit_test_csr(p_x_line_tbl(l_index).csi_item_instance_id);
          FETCH ahl_csi_unit_test_csr INTO l_dummy;
          IF (ahl_csi_unit_test_csr%NOTFOUND) THEN
            -- Instance is installed as a component
            CLOSE ahl_csi_unit_test_csr;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.set_name('AHL', 'AHL_OSP_SHIP_COMPONENT');
              Fnd_Msg_Pub.ADD;
            END IF;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          CLOSE ahl_csi_unit_test_csr;
        END IF;
        --mpothuku on 04-May-06 Ends

      ELSIF p_x_line_tbl(l_index).serial_number IS NOT NULL THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line is not Work order based. Getting details for Serial Number ' || p_x_line_tbl(l_index).serial_number);
        END IF;
        OPEN get_inv_inst_csr(p_x_line_tbl(l_index).inventory_item_id ,
                              -- p_x_line_tbl(l_index).inventory_org_id,
                              p_x_line_tbl(l_index).serial_number);
        FETCH get_inv_inst_csr INTO p_x_line_tbl(l_index).csi_item_instance_id;
        CLOSE get_inv_inst_csr;
      -- Added by jaramana on June 4, 2005 to get details about lot controlled items
      ELSIF p_x_line_tbl(l_index).lot_number IS NOT NULL THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Line is not Work order based. Getting details for Lot Number ' || p_x_line_tbl(l_index).lot_number);
        END IF;
        OPEN get_inv_inst_from_lot_csr(p_x_line_tbl(l_index).inventory_item_id ,
                              p_x_line_tbl(l_index).lot_number);
        FETCH get_inv_inst_from_lot_csr INTO p_x_line_tbl(l_index).csi_item_instance_id;
        CLOSE get_inv_inst_from_lot_csr;
      END IF;

      -- Added by jaramana on January 11, 2008 for the Bug 5688387/5842229.
      -- All return lines were being created upfront and then the ship lines
      -- which was creating confusion with the sequencing of the ship/return lines
      -- Changing the logic henceforth.
      l_ship_index := l_index-1;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Defaulting the shipline: index ' || l_ship_index );
      END IF;

      -- Copy all the details about from the Return Line
      p_x_line_tbl(l_ship_index) := p_x_line_tbl(l_index);
      p_x_line_tbl(l_ship_index).line_type_id:=FND_PROFILE.VALUE('AHL_OSP_OE_SHIP_ONLY_ID');
      p_x_line_tbl(l_ship_index).line_type:='SHIP';
      p_x_line_tbl(l_ship_index).return_reason_code:=NULL;

      IF p_x_line_tbl(l_ship_index).order_type = 'BORROW' THEN
        p_x_line_tbl(l_ship_index).schedule_ship_date := SYSDATE + l_service_duration;
      ELSE
        p_x_line_tbl(l_ship_index).schedule_ship_date := SYSDATE;
      END IF;

      /* For Exchange Orders, the return lines must reflect the exchange instance.
         l_index corresponds to the index of the return line
      */
      IF (p_x_line_tbl(l_index).order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
        -- Get the exchange instance and the instance details
        OPEN exchange_instance_dtls_csr(p_x_line_tbl(l_index).osp_line_id);
        FETCH exchange_instance_dtls_csr INTO l_exchange_inst_dtls;

        -- exchange instance can be null
        IF (exchange_instance_dtls_csr%FOUND) THEN
          -- exchange instance is not null
          p_x_line_tbl(l_index).inventory_item_id :=    l_exchange_inst_dtls.inventory_item_id;
          p_x_line_tbl(l_index).inventory_org_id :=     l_exchange_inst_dtls.last_vld_organization_id;
          p_x_line_tbl(l_index).lot_number :=           l_exchange_inst_dtls.lot_number;
          p_x_line_tbl(l_index).serial_number :=        l_exchange_inst_dtls.serial_number;
          p_x_line_tbl(l_index).ordered_quantity :=     l_exchange_inst_dtls.quantity;
          p_x_line_tbl(l_index).order_quantity_uom :=   l_exchange_inst_dtls.unit_of_measure;
          p_x_line_tbl(l_index).csi_item_instance_id := l_exchange_inst_dtls.exchange_instance_id;
          --@@@@@ Need to check if p_x_line_tbl(l_index).ship_from_org_id is valid
        ELSE
          -- exchange instance is null
          p_x_line_tbl(l_index).serial_number := NULL;
          p_x_line_tbl(l_index).lot_number    := NULL;
          p_x_line_tbl(l_index).csi_item_instance_id := null;
        END IF;
        CLOSE exchange_instance_dtls_csr;
      END IF;
      -- jaramana End

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed details for OSP Line with id ' || I.osp_order_line_id);
      END IF;
    END LOOP;

  END IF;  -- Line Table Count is Zero or c_operation_flag = 'C'
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;
END Process_Line_Tbl;


PROCEDURE Convert_Line_Tbl(p_line_tbl  IN AHL_OSP_SHIPMENT_PUB.SHIP_LINE_TBL_TYPE,
                           p_module_type         IN            VARCHAR2 ,
                           x_line_tbl  OUT NOCOPY OE_ORDER_PUB.LINE_TBL_TYPE,
                           x_line_val_tbl OUT NOCOPY OE_ORDER_PUB.LINE_VAL_TBL_TYPE,
                           x_lot_serial_tbl OUT NOCOPY OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE,
                           x_del_oe_lines_tbl OUT NOCOPY SHIP_ID_TBL_TYPE) IS
--
  l_count          NUMBER;
  l_line_rec       OE_ORDER_PUB.LINE_REC_TYPE;
  l_line_val_rec   OE_ORDER_PUB.LINE_VAL_REC_TYPE;
  l_lot_serial_rec OE_ORDER_PUB.LOT_SERIAL_REC_TYPE;
  l_lot_serial_id  NUMBER;
  l_del_count      NUMBER := 0;
  l_line_table_index NUMBER := 0;
--
  CURSOR ahl_oe_header_csr(p_oe_header_id IN NUMBER) IS
   SELECT ship_to_org_id,
          sold_to_org_id,
          sold_from_org_id,
          price_list_id,
          payment_term_id
    FROM  oe_order_headers_all
   WHERE  header_id = p_oe_header_id;

 --Used inv_organization_info_v instead of org_organization_definitions to fix the Perf Bug #4919255
  CURSOR ahl_ship_from_orgs_csr(p_name IN VARCHAR2) IS
   SELECT org.organization_id
   FROM OE_SHIP_FROM_ORGS_V org, inv_organization_info_v def
   WHERE org.organization_id = def.organization_id
   -- Changed by jaramana on Sep 9, 2005 for MOAC Uptake
   -- AND def.operating_unit = FND_PROFILE.VALUE('DEFAULT_ORG_ID')
    AND def.operating_unit = MO_GLOBAL.get_current_org_id()
   AND org.name = p_name;

  CURSOR ahl_oe_lot_serial_id (p_oe_line_id IN NUMBER) IS
    SELECT lot_serial_id
     FROM oe_lot_serial_numbers
    WHERE line_id = p_oe_line_id;

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Convert_Line_Tbl';
--
BEGIN
  l_count := 1;
  --Convert our rec type into OE_ORDER_PUB entities

  x_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
  x_line_val_tbl := OE_ORDER_PUB.G_MISS_LINE_VAL_TBL;
  x_lot_serial_tbl := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF (p_line_tbl.COUNT > 0) THEN
    FOR i IN p_line_tbl.FIRST..p_line_tbl.LAST  LOOP
      --Handle Delete operations first, differently than the rest/
      IF (p_line_tbl(i).operation = 'D') THEN
        /*
        -- July 23, 2003: Deletion of lines should go through the Delete_Cancel_Order API
        -- Not through the regular process.
        -- This is to support the Post-Shipment Conversion process where deletion of shipment (return) lines
        -- from the UI (after the order has been booked) is necessary.
        -- If the shipment is booked, Delete_Cancel_Order just zeroes out the ordered quantity.
        -- If not, it actually deletes the shipment line.
        l_line_rec := OE_LINE_UTIL.QUERY_ROW(p_line_id => p_line_tbl(i).line_id);
        l_line_val_rec :=  OE_ORDER_PUB.G_MISS_LINE_VAL_REC;
        l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        */
        l_del_count := l_del_count + 1;
        x_del_oe_lines_tbl(l_del_count) := p_line_tbl(i).line_id;
      ELSE
        l_line_rec :=  OE_ORDER_PUB.G_MISS_LINE_REC;
        l_line_val_rec :=  OE_ORDER_PUB.G_MISS_LINE_VAL_REC;

        IF (p_line_tbl(i).line_id IS NOT NULL) THEN
          l_line_rec.line_id := p_line_tbl(i).line_id;
        END IF;

        IF (p_line_tbl(i).line_number IS NOT NULL) THEN
          l_line_rec.line_number := p_line_tbl(i).line_number;
        END IF;

        IF (p_line_tbl(i).header_id IS NOT NULL)  THEN
          l_line_rec.header_id := p_line_tbl(i).header_id;
        END IF;

        IF (p_line_tbl(i).line_type_id IS NOT NULL)  THEN
          l_line_rec.line_type_id := p_line_tbl(i).line_type_id;
        END IF;
        IF (p_line_tbl(i).line_type IS NOT NULL)  THEN
          l_line_val_rec.line_type := p_line_tbl(i).line_type;
        END IF;

        IF (p_line_tbl(i).inventory_item_id IS NOT NULL)  THEN
          l_line_rec.inventory_item_id := p_line_tbl(i).inventory_item_id;
        END IF;
        IF (p_line_tbl(i).inventory_item IS NOT NULL)  THEN
          l_line_val_rec.inventory_item := p_line_tbl(i).inventory_item;
        END IF;

        IF (p_line_tbl(i).ordered_quantity IS NOT NULL)  THEN
          l_line_rec.ordered_quantity := p_line_tbl(i).ordered_quantity;
        END IF;
        IF (p_line_tbl(i).order_quantity_uom IS NOT NULL)  THEN
          l_line_rec.order_quantity_uom := p_line_tbl(i).order_quantity_uom;
        END IF;

        IF (p_line_tbl(i).return_reason_code IS NOT NULL)  THEN
          l_line_rec.return_reason_code := p_line_tbl(i).return_reason_code;
        END IF;
        IF (p_line_tbl(i).return_reason IS NOT NULL)  THEN
          l_line_val_rec.return_reason := p_line_tbl(i).return_reason;
        END IF;

        l_line_rec.schedule_ship_date := p_line_tbl(i).schedule_ship_date;

        --NEED TO FIX: CHANGE TO ADD SERIAL NUMBER MESSAGE.
        l_line_rec.shipping_instructions := p_line_tbl(i).serial_number;
        l_line_rec.packing_instructions := p_line_tbl(i).packing_instructions;

        l_line_val_rec.project   := p_line_tbl(i).project;
        l_line_rec.project_id    := p_line_tbl(i).project_id;
        l_line_val_rec.task      := p_line_tbl(i).task;
        l_line_rec.task_id       := p_line_tbl(i).task_id ;

        -- Hack to find ship_from_org_id because the OE Value_to_ID converter
        -- does not exist.
        IF (p_module_type = 'JSP') THEN
          IF (p_line_tbl(i).ship_from_org IS NOT NULL) THEN
            OPEN ahl_ship_from_orgs_csr(p_line_tbl(i).ship_from_org);
            FETCH ahl_ship_from_orgs_csr INTO l_line_rec.ship_from_org_id;
            IF (ahl_ship_from_orgs_csr%NOTFOUND) THEN
              CLOSE ahl_ship_from_orgs_csr;
              IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('AHL', 'AHL_OSP_SHIP_FROM_ORG_INV');
                FND_MESSAGE.SET_TOKEN('SHIP_FROM_ORG', p_line_tbl(i).ship_from_org);
                FND_MSG_PUB.ADD;
              END IF;
              RAISE Fnd_Api.g_exc_error;
            END IF;
            CLOSE ahl_ship_from_orgs_csr;
          END IF;
        ELSE
          l_line_rec.ship_from_org_id    := p_line_tbl(i).ship_from_org_id;
        END IF;
        l_line_val_rec.ship_from_org  := p_line_tbl(i).ship_from_org;

        l_line_rec.subinventory := p_line_tbl(i).subinventory;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_line_rec.ship_from_org_id = ' || l_line_rec.ship_from_org_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_line_val_rec.ship_from_org = ' || l_line_val_rec.ship_from_org);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_line_rec.subinventory = ' || l_line_rec.subinventory);
        END IF;

        IF (p_module_type = 'JSP') THEN
          -- Set all Ids to G_MISS Values
          l_line_rec.fob_point_code   := FND_API.G_MISS_CHAR ;
          l_line_rec.freight_carrier_code:= FND_API.G_MISS_CHAR ;
          l_line_rec.freight_terms_code  :=  FND_API.G_MISS_CHAR ;
          l_line_rec.shipment_priority_code  := FND_API.G_MISS_CHAR;
          l_line_rec.shipping_method_code  := FND_API.G_MISS_CHAR ;
        ELSE
          l_line_rec.fob_point_code   := p_line_tbl(i).fob_point_code;
          l_line_rec.freight_carrier_code := p_line_tbl(i).freight_carrier_code;
          l_line_rec.freight_terms_code  := p_line_tbl(i).freight_terms_code;
          l_line_rec.shipment_priority_code  := p_line_tbl(i).shipment_priority_code;
          l_line_rec.shipping_method_code  := p_line_tbl(i).shipping_method_code;
        END IF;
        l_line_val_rec.fob_point    := p_line_tbl(i).fob_point;
        l_line_val_rec.freight_carrier   := p_line_tbl(i).freight_carrier;
        l_line_val_rec.freight_terms  := p_line_tbl(i).freight_terms;
        l_line_val_rec.shipment_priority  := p_line_tbl(i).shipment_priority;
        l_line_val_rec.shipping_method    := p_line_tbl(i).shipping_method;

        --Set values
        l_line_rec.item_type_code := 'STANDARD';

        --Fetch AHL_OSP_ORDER source document type id
        --AHL Document_type is defined to be 21
        l_line_rec.source_document_type_id := 21;

        l_line_rec.unit_selling_price := 0;
        l_line_rec.unit_list_price := 0;
        l_line_rec.calculate_price_flag := 'N';

        l_line_rec.source_document_id := p_line_tbl(i).osp_order_id;
        l_line_rec.source_document_line_id := p_line_tbl(i).osp_line_id;
        l_line_rec.orig_sys_document_ref := p_line_tbl(i).osp_order_number;
        l_line_rec.orig_sys_line_ref := p_line_tbl(i).osp_line_number;

        IF (p_line_tbl(i).operation = 'C') THEN
          OPEN ahl_oe_header_csr(p_line_tbl(i).header_id);
          FETCH ahl_oe_header_csr INTO l_line_rec.ship_to_org_id,
                                       l_line_rec.sold_to_org_id,
                                       l_line_rec.sold_from_org_id,
                                       l_line_rec.price_list_id,
                                       l_line_rec.payment_term_id;
          CLOSE ahl_oe_header_csr;
        END IF;

        IF (p_line_tbl(i).operation = 'C') THEN
          l_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
        ELSIF (p_line_tbl(i).operation = 'U') THEN
          l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
        END IF;

        -- NEED TO FIX: 'Return'
        IF (p_line_tbl(i).line_type_id = FND_PROFILE.VALUE('AHL_OSP_OE_RETURN_ID') AND
            p_line_tbl(i).serial_number IS NOT NULL AND
            p_line_tbl(i).serial_number <> FND_API.G_MISS_CHAR) THEN
          IF (p_line_tbl(i).operation = 'C') THEN
            l_lot_serial_rec := OE_ORDER_PUB.G_MISS_LOT_SERIAL_REC;
            l_lot_serial_rec.from_serial_number := p_line_tbl(i).serial_number;
            l_lot_serial_rec.lot_number := p_line_tbl(i).lot_number;
            l_lot_serial_rec.quantity := p_line_tbl(i).ordered_quantity;
            l_lot_serial_rec.line_index := i;
            l_lot_serial_rec.operation := OE_GLOBALS.G_OPR_CREATE;
            x_lot_serial_tbl(l_count) := l_lot_serial_rec;
            l_count := l_count + 1;
          ELSIF (p_line_tbl(i).operation = 'U') THEN
            OPEN ahl_oe_lot_serial_id (p_line_tbl(i).line_id);
            FETCH ahl_oe_lot_serial_id INTO l_lot_serial_id;
            IF (ahl_oe_lot_serial_id%FOUND) THEN
              OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id => l_lot_serial_id,
                                           x_lot_serial_rec =>l_lot_serial_rec);
              l_lot_serial_rec.from_serial_number := p_line_tbl(i).serial_number;
              l_lot_serial_rec.lot_number := p_line_tbl(i).lot_number;
              l_lot_serial_rec.quantity := p_line_tbl(i).ordered_quantity;
              l_lot_serial_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
              x_lot_serial_tbl(l_count) := l_lot_serial_rec;
              l_count := l_count + 1;
            END IF;
            CLOSE ahl_oe_lot_serial_id;
          END IF;
        END IF;  --return line type
        l_line_table_index := l_line_table_index + 1;
        x_line_tbl(l_line_table_index) := l_line_rec;
        x_line_val_tbl(l_line_table_index) := l_line_val_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_line_rec.ship_from_org_id = ' || l_line_rec.ship_from_org_id);
        END IF;
      END IF;  -- Operation is not 'D'
    END LOOP;  -- For all lines in Line Table
  END IF;  -- Line Table Count > 0
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Convert_Line_Tbl;

---
PROCEDURE Delete_OSP_Order(
        p_oe_header_id   IN NUMBER
       ) IS
--
  CURSOR ahl_osp_order_id_csr(p_header_id IN NUMBER) IS
    SELECT osp_order_id
    FROM ahl_osp_orders_b
    WHERE oe_header_id = p_header_id;

--
  CURSOR ahl_osp_order_line_csr(p_order_id IN NUMBER) IS
    SELECT *
    FROM AHL_OSP_ORDER_LINES
    WHERE osp_order_id = p_order_id;
--
  l_osp_order_id NUMBER;
  l_osp_line_rec ahl_osp_order_line_csr%ROWTYPE;
--
BEGIN
    --Update AHL_OSP_ORDERS/OSP_ORDER_LINES tables with ids/new id
    OPEN ahl_osp_order_id_csr(p_oe_header_id);
    FETCH ahl_osp_order_id_csr INTO l_osp_order_id;
    IF (ahl_osp_order_id_csr%FOUND) THEN
      Update_OSP_Order(p_osp_order_id => l_osp_order_id,
                       p_oe_header_id => NULL );

    --Update the lines
    FOR l_osp_line_rec IN ahl_osp_order_line_csr(l_osp_order_id) LOOP
     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => NULL,
            P_OE_RETURN_LINE_ID        => NULL,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
	P_INVENTORY_ITEM_ID            	       => l_osp_line_rec.INVENTORY_ITEM_ID,
	P_INVENTORY_ORG_ID             	       => l_osp_line_rec.INVENTORY_ORG_ID,
	P_INVENTORY_ITEM_UOM           	       => l_osp_line_rec.INVENTORY_ITEM_UOM,
	P_INVENTORY_ITEM_QUANTITY      	       => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
	P_SUB_INVENTORY                	       => l_osp_line_rec.SUB_INVENTORY,
	P_LOT_NUMBER                   	       => l_osp_line_rec.LOT_NUMBER,
	P_SERIAL_NUMBER          	       => l_osp_line_rec.SERIAL_NUMBER,
-- Begin Changes by jaramana on January 11, 2008 for the Requisition ER 6034236
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 11, 2008 for the Requisition ER 6034236
            P_EXCHANGE_INSTANCE_ID     => l_osp_line_rec.EXCHANGE_INSTANCE_ID,
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
     END LOOP;

    END IF;
    CLOSE ahl_osp_order_id_csr;

END Delete_OSP_Order;

--

PROCEDURE Update_OSP_Order(
	p_osp_order_id   IN NUMBER,
        p_oe_header_id   IN NUMBER
       ) IS
--
  CURSOR ahl_osp_order_csr(p_osp_id IN NUMBER) IS
    SELECT *
    FROM AHL_OSP_ORDERS_VL
    WHERE osp_order_id = p_osp_id;

--
  l_osp_order ahl_osp_order_csr%ROWTYPE;
--
BEGIN

  --Now fetch information corresponding to osp_order_id
   OPEN ahl_osp_order_csr(p_osp_order_id);
   FETCH ahl_osp_order_csr INTO l_osp_order;
   IF (ahl_osp_order_csr%NOTFOUND) THEN
      CLOSE ahl_osp_order_csr;
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
         Fnd_Message.set_name('AHL', 'AHL_OSP_OSP_ID_NULL');
         Fnd_Msg_Pub.ADD;
      END IF;
      RAISE Fnd_Api.g_exc_error;
   END IF;
   CLOSE ahl_osp_order_csr;

  AHL_OSP_ORDERS_PKG.UPDATE_ROW(
   X_OSP_ORDER_ID   =>    l_osp_order.OSP_ORDER_ID,
   X_OBJECT_VERSION_NUMBER   =>    l_osp_order.OBJECT_VERSION_NUMBER+1,
   X_OSP_ORDER_NUMBER   =>    l_osp_order.OSP_ORDER_NUMBER,
   X_ORDER_TYPE_CODE   =>     l_osp_order.ORDER_TYPE_CODE,
   X_SINGLE_INSTANCE_FLAG   =>     l_osp_order.SINGLE_INSTANCE_FLAG,
   X_PO_HEADER_ID   =>         l_osp_order.PO_HEADER_ID,
   X_OE_HEADER_ID   =>         p_oe_header_id,
   X_VENDOR_ID   =>    l_osp_order.VENDOR_ID,
   X_VENDOR_SITE_ID   =>    l_osp_order.VENDOR_SITE_ID,
   X_VENDOR_CONTACT_ID  => l_osp_order.VENDOR_CONTACT_ID,
   X_CUSTOMER_ID   =>    l_osp_order.CUSTOMER_ID,
   X_ORDER_DATE   =>     l_osp_order.ORDER_DATE,
   X_CONTRACT_ID   =>    l_osp_order.CONTRACT_ID,
   X_CONTRACT_TERMS   =>     l_osp_order.CONTRACT_TERMS,
   X_OPERATING_UNIT_ID   =>    l_osp_order.OPERATING_UNIT_ID,
   X_PO_SYNCH_FLAG   =>     l_osp_order.PO_SYNCH_FLAG,
   X_STATUS_CODE   =>     l_osp_order.STATUS_CODE,
   X_PO_BATCH_ID   =>    l_osp_order.PO_BATCH_ID,
   X_PO_REQUEST_ID   =>    l_osp_order.PO_REQUEST_ID,
   X_PO_AGENT_ID   =>    l_osp_order.PO_AGENT_ID,
   X_PO_INTERFACE_HEADER_ID   =>    l_osp_order.PO_INTERFACE_HEADER_ID,
   X_ATTRIBUTE_CATEGORY   =>     l_osp_order.ATTRIBUTE_CATEGORY,
   X_ATTRIBUTE1   =>     l_osp_order.ATTRIBUTE1,
   X_ATTRIBUTE2   =>     l_osp_order.ATTRIBUTE2,
   X_ATTRIBUTE3   =>     l_osp_order.ATTRIBUTE3,
   X_ATTRIBUTE4   =>     l_osp_order.ATTRIBUTE4,
   X_ATTRIBUTE5   =>     l_osp_order.ATTRIBUTE5,
   X_ATTRIBUTE6   =>     l_osp_order.ATTRIBUTE6,
   X_ATTRIBUTE7   =>     l_osp_order.ATTRIBUTE7,
   X_ATTRIBUTE8   =>     l_osp_order.ATTRIBUTE8,
   X_ATTRIBUTE9   =>     l_osp_order.ATTRIBUTE9,
   X_ATTRIBUTE10   =>     l_osp_order.ATTRIBUTE10,
   X_ATTRIBUTE11   =>     l_osp_order.ATTRIBUTE11,
   X_ATTRIBUTE12   =>     l_osp_order.ATTRIBUTE12,
   X_ATTRIBUTE13   =>     l_osp_order.ATTRIBUTE13,
   X_ATTRIBUTE14   =>     l_osp_order.ATTRIBUTE14,
   X_ATTRIBUTE15   =>     l_osp_order.ATTRIBUTE15,
   X_DESCRIPTION   =>     l_osp_order.DESCRIPTION,
   X_PO_REQ_HEADER_ID  => l_osp_order.PO_REQ_HEADER_ID, -- Added by jaramana on January 11, 2008 for the Requisition ER 6034236
   X_LAST_UPDATE_DATE   =>     l_osp_order.LAST_UPDATE_DATE,
   X_LAST_UPDATED_BY   =>    l_osp_order.LAST_UPDATED_BY,
   X_LAST_UPDATE_LOGIN   =>    l_osp_order.LAST_UPDATE_LOGIN
   );

END Update_OSP_Order;
---


PROCEDURE Update_OSP_Order_Lines(
	p_osp_order_id  IN NUMBER,
	p_osp_line_id   IN NUMBER,
        p_oe_ship_line_id       IN NUMBER,
        p_oe_return_line_id     IN NUMBER
       ) IS
--
--Since one item instance can not be in multiple ship lines for given
--osp order, fetch all the ship/return lines for item instance
--
 CURSOR ahl_osp_lines_csr(p_osp_id IN NUMBER, p_osp_line_id IN NUMBER) IS
 --mpothuku removed the usage of AHL_OSP_ORDER_LINES_V usage for fixing the perf Bug# 4919255 on 21-Feb-06
    SELECT  a.OSP_ORDER_LINE_ID,
            a.OBJECT_VERSION_NUMBER,
            a.LAST_UPDATE_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_LOGIN,
            a.OSP_ORDER_ID,
            a.OSP_LINE_NUMBER,
            a.STATUS_CODE,
            a.PO_LINE_TYPE_ID,
            a.SERVICE_ITEM_ID,
            a.SERVICE_ITEM_DESCRIPTION,
            a.SERVICE_ITEM_UOM_CODE,
            a.NEED_BY_DATE,
            a.SHIP_BY_DATE,
            a.PO_LINE_ID,
            a.OE_SHIP_LINE_ID,
            a.OE_RETURN_LINE_ID,
            a.WORKORDER_ID,
            a.OPERATION_ID,
            a.EXCHANGE_INSTANCE_ID,
            a.INVENTORY_ITEM_ID,
            a.INVENTORY_ORG_ID,
            --a.ITEM_NUMBER,
            --a.ITEM_DESCRIPTION,
            a.SERIAL_NUMBER,
            a.LOT_NUMBER,
            a.INVENTORY_ITEM_UOM,
            a.INVENTORY_ITEM_QUANTITY,
            a.SUB_INVENTORY,
            a.QUANTITY,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
           a.PO_REQ_LINE_ID
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
    FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.osp_order_line_id = p_osp_line_id;
--
  l_oe_ship_line_id    	 NUMBER;
  l_oe_return_line_id 	 NUMBER;
  l_row_check      VARCHAR2(1):='N';
--
BEGIN

   FOR l_osp_line_rec IN ahl_osp_lines_csr(p_osp_order_id, p_osp_line_id)
  LOOP
     l_row_check := 'Y';
     IF ( p_oe_ship_line_id IS NOT NULL
 	AND p_oe_ship_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_ship_line_id := p_oe_ship_line_id;
     ELSE
          l_oe_ship_line_id := l_osp_line_rec.oe_ship_line_id;
     END IF;

     IF (p_oe_return_line_id IS NOT NULL
 	AND p_oe_return_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_return_line_id := p_oe_return_line_id;
     ELSE
          l_oe_return_line_id := l_osp_line_rec.oe_return_line_id;
     END IF;

     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_oe_ship_line_id,
            P_OE_RETURN_LINE_ID        => l_oe_return_line_id,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_EXCHANGE_INSTANCE_ID     => l_osp_line_rec.EXCHANGE_INSTANCE_ID,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
    END LOOP;

    IF l_row_check = 'N' THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_LINE_ITEM');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
    END IF;

END Update_OSP_Order_Lines;


PROCEDURE Update_OSP_Order_Lines(
	p_osp_order_id  IN NUMBER,
	p_item_instance_id   IN NUMBER,
        p_oe_ship_line_id       IN NUMBER,
        p_oe_return_line_id     IN NUMBER
       ) IS
--
--Since one item instance can not be in multiple ship lines for given
--osp order, fetch all the ship/return lines for item instance
--
 CURSOR ahl_osp_lines_csr(p_osp_id IN NUMBER, p_csi_ii_id IN NUMBER) IS
 --mpothuku removed the usage of AHL_OSP_ORDER_LINES_V usage for fixing the perf Bug# 4919255 on 21-Feb-06
 /*
    SELECT  a.OSP_ORDER_LINE_ID,
            a.OBJECT_VERSION_NUMBER,
            a.LAST_UPDATE_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_LOGIN,
            a.OSP_ORDER_ID,
            a.OSP_LINE_NUMBER,
            a.STATUS_CODE,
            a.PO_LINE_TYPE_ID,
            a.SERVICE_ITEM_ID,
            a.SERVICE_ITEM_DESCRIPTION,
            a.SERVICE_ITEM_UOM_CODE,
            a.NEED_BY_DATE,
            a.SHIP_BY_DATE,
            a.PO_LINE_ID,
            a.OE_SHIP_LINE_ID,
            a.OE_RETURN_LINE_ID,
            a.WORKORDER_ID,
            a.OPERATION_ID,
            a.EXCHANGE_INSTANCE_ID,
            a.INVENTORY_ITEM_ID,
            a.INVENTORY_ORG_ID,
            a.ITEM_NUMBER,
            a.ITEM_DESCRIPTION,
            a.SERIAL_NUMBER,
            a.LOT_NUMBER,
            a.INVENTORY_ITEM_UOM,
            a.INVENTORY_ITEM_QUANTITY,
            a.SUB_INVENTORY,
            a.QUANTITY,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15

--    FROM AHL_OSP_ORDER_LINES a, AHL_WORKORDERS_V b
--    WHERE a.workorder_id = b.workorder_id
--      AND a.osp_order_id = p_osp_id
--     AND b.item_instance_id = p_csi_ii_id;

    FROM AHL_OSP_ORDER_LINES_V a
    WHERE a.osp_order_id = p_osp_id
      AND (a.item_instance_id = p_csi_ii_id OR a.exchange_instance_id = p_csi_ii_id);
*/

    SELECT  a.OSP_ORDER_LINE_ID,
            a.OBJECT_VERSION_NUMBER,
            a.LAST_UPDATE_DATE,
            a.LAST_UPDATED_BY,
            a.LAST_UPDATE_LOGIN,
            a.OSP_ORDER_ID,
            a.OSP_LINE_NUMBER,
            a.STATUS_CODE,
            a.PO_LINE_TYPE_ID,
            a.SERVICE_ITEM_ID,
            a.SERVICE_ITEM_DESCRIPTION,
            a.SERVICE_ITEM_UOM_CODE,
            a.NEED_BY_DATE,
            a.SHIP_BY_DATE,
            a.PO_LINE_ID,
            a.OE_SHIP_LINE_ID,
            a.OE_RETURN_LINE_ID,
            a.WORKORDER_ID,
            a.OPERATION_ID,
            a.EXCHANGE_INSTANCE_ID,
            a.INVENTORY_ITEM_ID,
            a.INVENTORY_ORG_ID,
            a.SERIAL_NUMBER,
            a.LOT_NUMBER,
            a.INVENTORY_ITEM_UOM,
            a.INVENTORY_ITEM_QUANTITY,
            a.SUB_INVENTORY,
            a.QUANTITY,
            a.ATTRIBUTE_CATEGORY,
            a.ATTRIBUTE1,
            a.ATTRIBUTE2,
            a.ATTRIBUTE3,
            a.ATTRIBUTE4,
            a.ATTRIBUTE5,
            a.ATTRIBUTE6,
            a.ATTRIBUTE7,
            a.ATTRIBUTE8,
            a.ATTRIBUTE9,
            a.ATTRIBUTE10,
            a.ATTRIBUTE11,
            a.ATTRIBUTE12,
            a.ATTRIBUTE13,
            a.ATTRIBUTE14,
            a.ATTRIBUTE15,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            a.PO_REQ_LINE_ID
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
    FROM AHL_OSP_ORDER_LINES a,
         ahl_workorders wo,
         csi_item_instances csii,
         ahl_visit_tasks_b vts
    WHERE a.osp_order_id = p_osp_id
      AND wo.workorder_id(+) = a.workorder_id
      AND wo.visit_task_id = vts.visit_task_id(+)
      AND csii.last_vld_organization_id(+) = a.inventory_org_id
      AND csii.inventory_item_id(+) = a.inventory_item_id
      AND csii.serial_number(+) = a.serial_number
      AND (decode(a.workorder_id, NULL, csii.instance_id, vts.instance_id) = p_csi_ii_id OR a.exchange_instance_id = p_csi_ii_id);

--
  l_oe_ship_line_id    	 NUMBER;
  l_oe_return_line_id 	 NUMBER;
  l_row_check      VARCHAR2(1):='N';
--
BEGIN

   FOR l_osp_line_rec IN ahl_osp_lines_csr(p_osp_order_id, p_item_instance_id)
  LOOP
     l_row_check := 'Y';
     IF ( p_oe_ship_line_id IS NOT NULL
 	AND p_oe_ship_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_ship_line_id := p_oe_ship_line_id;
     ELSE
          l_oe_ship_line_id := l_osp_line_rec.oe_ship_line_id;
     END IF;

     IF (p_oe_return_line_id IS NOT NULL
 	AND p_oe_return_line_id <> FND_API.G_MISS_NUM) THEN
          l_oe_return_line_id := p_oe_return_line_id;
     ELSE
          l_oe_return_line_id := l_osp_line_rec.oe_return_line_id;
     END IF;

     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_oe_ship_line_id,
            P_OE_RETURN_LINE_ID        => l_oe_return_line_id,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_EXCHANGE_INSTANCE_ID     => l_osp_line_rec.EXCHANGE_INSTANCE_ID,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
    END LOOP;

    IF l_row_check = 'N' THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_LINE_ITEM');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
    END IF;

END Update_OSP_Order_Lines;

-- yazhou 10-Apr-2006 starts
-- Bug fix #4998349

PROCEDURE Update_OSP_Line_Exch_Instance(
	p_osp_order_id   IN NUMBER,
    p_osp_line_id    IN NUMBER,
    p_exchange_instance_id   IN NUMBER
)IS


-- Check if the instance is a valid IB instance
-- Also not part of relationship

    CURSOR val_exg_instance_id_csr(p_instance_id IN NUMBER) IS
      SELECT 'x' FROM csi_item_instances csi
        WHERE instance_id = p_instance_id
          AND nvl(csi.active_end_date, sysdate + 1) > sysdate
          AND NOT EXISTS (select subject_id from csi_ii_relationships where
                           subject_id = p_instance_id and
                           relationship_type_code = 'COMPONENT-OF' and
                           NVL(ACTIVE_START_DATE, SYSDATE - 1) < SYSDATE AND
						   NVL(ACTIVE_END_DATE, SYSDATE + 1) > SYSDATE
                          ) ;

    l_exist VARCHAR2(1);

-- retrieve order line details

 CURSOR ahl_osp_lines_csr(p_osp_id IN NUMBER, p_osp_line_id IN NUMBER) IS
    SELECT a.OSP_ORDER_LINE_ID,
           a.OBJECT_VERSION_NUMBER,
           a.LAST_UPDATE_DATE,
           a.LAST_UPDATED_BY,
           a.LAST_UPDATE_LOGIN,
           a.OSP_ORDER_ID,
           a.OSP_LINE_NUMBER,
           a.STATUS_CODE,
           a.PO_LINE_TYPE_ID,
           a.SERVICE_ITEM_ID,
           a.SERVICE_ITEM_DESCRIPTION,
           a.SERVICE_ITEM_UOM_CODE,
           a.NEED_BY_DATE,
           a.SHIP_BY_DATE,
           a.PO_LINE_ID,
           a.OE_SHIP_LINE_ID,
           a.OE_RETURN_LINE_ID,
           a.WORKORDER_ID,
           a.OPERATION_ID,
           a.EXCHANGE_INSTANCE_ID,
           a.INVENTORY_ITEM_ID,
           a.INVENTORY_ORG_ID,
           a.SERIAL_NUMBER,
           a.LOT_NUMBER,
           a.INVENTORY_ITEM_UOM,
           a.INVENTORY_ITEM_QUANTITY,
           a.SUB_INVENTORY,
           a.QUANTITY,
           a.ATTRIBUTE_CATEGORY,
           a.ATTRIBUTE1,
           a.ATTRIBUTE2,
           a.ATTRIBUTE3,
           a.ATTRIBUTE4,
           a.ATTRIBUTE5,
           a.ATTRIBUTE6,
           a.ATTRIBUTE7,
           a.ATTRIBUTE8,
           a.ATTRIBUTE9,
           a.ATTRIBUTE10,
           a.ATTRIBUTE11,
           a.ATTRIBUTE12,
           a.ATTRIBUTE13,
           a.ATTRIBUTE14,
           a.ATTRIBUTE15,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
           a.PO_REQ_LINE_ID
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236

    FROM AHL_OSP_ORDER_LINES a
    WHERE a.osp_order_id = p_osp_id
      AND a.osp_order_line_id = p_osp_line_id;

--
  l_row_check      VARCHAR2(1):='N';
--
BEGIN

  -- Validate exchange instance
  OPEN val_exg_instance_id_csr(p_exchange_instance_id);
  FETCH val_exg_instance_id_csr INTO l_exist;
  IF (val_exg_instance_id_csr %NOTFOUND) THEN
        FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_SHIP_COMPONENT');
        FND_MSG_PUB.ADD;
        CLOSE val_exg_instance_id_csr;
        RAISE Fnd_Api.g_exc_error;
  END IF;
  CLOSE val_exg_instance_id_csr;

  FOR l_osp_line_rec IN ahl_osp_lines_csr(p_osp_order_id, p_osp_line_id)
   LOOP
     l_row_check := 'Y';

     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_osp_line_rec.OE_SHIP_LINE_ID,
            P_OE_RETURN_LINE_ID        => l_osp_line_rec.OE_RETURN_LINE_ID,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_EXCHANGE_INSTANCE_ID     => p_exchange_instance_id,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );
    END LOOP;

    IF l_row_check = 'N' THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_INVALID_LINE_ITEM');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.g_exc_error;
    END IF;

END Update_OSP_Line_Exch_Instance;

-- yazhou 10-Apr-2006 ends

--
--Clears all osp_order_lines with either ship_line_id or return_line_id
--
PROCEDURE Delete_OE_Lines(p_oe_line_id       IN NUMBER) IS
--
--Fetch all osp lines with reference to p_oe_line_id
  CURSOR ahl_osp_lines_csr(p_line_id   IN NUMBER) IS
    SELECT  *
     FROM AHL_OSP_ORDER_LINES
    WHERE oe_ship_line_id = p_line_id
      OR  oe_return_line_id = p_line_id;

--
  l_oe_ship_line_id    	 NUMBER;
  l_oe_return_line_id 	 NUMBER;
--
BEGIN

   FOR l_osp_line_rec IN ahl_osp_lines_csr(p_oe_line_id) LOOP

     --Remove all references to p_oe_line_id
     IF (p_oe_line_id = l_osp_line_rec.oe_ship_line_id) THEN
         l_oe_ship_line_id := NULL;
     ELSE
         l_oe_ship_line_id := l_osp_line_rec.oe_ship_line_id;
     END IF;

     IF (p_oe_line_id = l_osp_line_rec.oe_return_line_id) THEN
         l_oe_return_line_id := NULL;
     ELSE
         l_oe_return_line_id := l_osp_line_rec.oe_return_line_id;
     END IF;
     AHL_OSP_ORDER_LINES_PKG.UPDATE_ROW (
            P_OSP_ORDER_LINE_ID        => l_osp_line_rec.OSP_ORDER_LINE_ID,
            P_OBJECT_VERSION_NUMBER    => l_osp_line_rec.OBJECT_VERSION_NUMBER+1,
            P_LAST_UPDATE_DATE         => l_osp_line_rec.LAST_UPDATE_DATE,
            P_LAST_UPDATED_BY          => l_osp_line_rec.LAST_UPDATED_BY,
            P_LAST_UPDATE_LOGIN        => l_osp_line_rec.LAST_UPDATE_LOGIN,
            P_OSP_ORDER_ID             => l_osp_line_rec.OSP_ORDER_ID,
            P_OSP_LINE_NUMBER          => l_osp_line_rec.OSP_LINE_NUMBER,
            P_STATUS_CODE              => l_osp_line_rec.STATUS_CODE,
            P_PO_LINE_TYPE_ID          => l_osp_line_rec.PO_LINE_TYPE_ID,
            P_SERVICE_ITEM_ID          => l_osp_line_rec.SERVICE_ITEM_ID,
            P_SERVICE_ITEM_DESCRIPTION => l_osp_line_rec.SERVICE_ITEM_DESCRIPTION,
            P_SERVICE_ITEM_UOM_CODE    => l_osp_line_rec.SERVICE_ITEM_UOM_CODE,
            P_NEED_BY_DATE             => l_osp_line_rec.NEED_BY_DATE,
            P_SHIP_BY_DATE             => l_osp_line_rec.SHIP_BY_DATE,
            P_PO_LINE_ID               => l_osp_line_rec.PO_LINE_ID,
            P_OE_SHIP_LINE_ID          => l_oe_ship_line_id,
            P_OE_RETURN_LINE_ID        => l_oe_return_line_id,
            P_WORKORDER_ID             => l_osp_line_rec.WORKORDER_ID,
            P_OPERATION_ID             => l_osp_line_rec.OPERATION_ID,
            P_QUANTITY                 => l_osp_line_rec.QUANTITY,
            P_INVENTORY_ITEM_ID        => l_osp_line_rec.INVENTORY_ITEM_ID,
            P_INVENTORY_ORG_ID         => l_osp_line_rec.INVENTORY_ORG_ID,
            P_INVENTORY_ITEM_UOM       => l_osp_line_rec.INVENTORY_ITEM_UOM,
            P_INVENTORY_ITEM_QUANTITY  => l_osp_line_rec.INVENTORY_ITEM_QUANTITY,
            P_SUB_INVENTORY            => l_osp_line_rec.SUB_INVENTORY,
            P_LOT_NUMBER               => l_osp_line_rec.LOT_NUMBER,
            P_SERIAL_NUMBER            => l_osp_line_rec.SERIAL_NUMBER,
-- Begin Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_PO_REQ_LINE_ID           => l_osp_line_rec.PO_REQ_LINE_ID,
-- End Changes by jaramana on January 14, 2008 for the Requisition ER 6034236
            P_EXCHANGE_INSTANCE_ID     => l_osp_line_rec.EXCHANGE_INSTANCE_ID,
            P_ATTRIBUTE_CATEGORY       => l_osp_line_rec.ATTRIBUTE_CATEGORY,
            P_ATTRIBUTE1               => l_osp_line_rec.ATTRIBUTE1,
            P_ATTRIBUTE2               => l_osp_line_rec.ATTRIBUTE2,
            P_ATTRIBUTE3               => l_osp_line_rec.ATTRIBUTE3,
            P_ATTRIBUTE4               => l_osp_line_rec.ATTRIBUTE4,
            P_ATTRIBUTE5               => l_osp_line_rec.ATTRIBUTE5,
            P_ATTRIBUTE6               => l_osp_line_rec.ATTRIBUTE6,
            P_ATTRIBUTE7               => l_osp_line_rec.ATTRIBUTE7,
            P_ATTRIBUTE8               => l_osp_line_rec.ATTRIBUTE8,
            P_ATTRIBUTE9               => l_osp_line_rec.ATTRIBUTE9,
            P_ATTRIBUTE10              => l_osp_line_rec.ATTRIBUTE10,
            P_ATTRIBUTE11              => l_osp_line_rec.ATTRIBUTE11,
            P_ATTRIBUTE12              => l_osp_line_rec.ATTRIBUTE12,
            P_ATTRIBUTE13              => l_osp_line_rec.ATTRIBUTE13,
            P_ATTRIBUTE14              => l_osp_line_rec.ATTRIBUTE14,
            P_ATTRIBUTE15              => l_osp_line_rec.ATTRIBUTE15 );

    END LOOP;

END Delete_OE_Lines;

-- Create IB sub-txn for OSP order.
PROCEDURE Create_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_OSP_order_type         IN            VARCHAR2,
    p_oe_line_type           IN            VARCHAR2,
    p_oe_line_id             IN            NUMBER,
    p_csi_instance_id        IN            NUMBER)
IS

    -- get csi transaction type.
    CURSOR csi_txn_types_csr(p_source_txn_type IN VARCHAR2) IS
      SELECT transaction_type_id
      FROM csi_txn_types
      WHERE source_transaction_type = p_source_txn_type;

    /* Commented out by jeli on 11/30/05 for ER 4746426
    -- get sub-type id based on transaction.
    CURSOR csi_txn_sub_types_csr(p_transaction_type_id IN NUMBER,
                                 p_sub_type_name       IN VARCHAR2) IS
      SELECT sub_type_id
      FROM csi_txn_sub_types
      WHERE transaction_type_id = p_transaction_type_id
        AND name = p_sub_type_name;
    */

    -- get oe line details.
    CURSOR oe_order_lines_csr (p_oe_line_id IN NUMBER) IS
      SELECT inventory_item_id, ordered_quantity, ship_from_org_id, order_quantity_uom
      FROM oe_order_lines_all
      WHERE line_id = p_oe_line_id;

    -- get instance details.
    CURSOR csi_item_instances_csr (p_instance_id IN NUMBER) IS
      SELECT serial_number, inventory_revision, lot_number, mfg_serial_number_flag
      FROM csi_item_instances
      WHERE instance_id = p_instance_id;

    -- get value for return by date.
    CURSOR ahl_osp_order_lines_csr (p_oe_line_id   IN NUMBER) IS
      SELECT nvl(need_by_date, ship_by_date)
      FROM ahl_osp_order_lines
      WHERE oe_ship_line_id = p_oe_line_id;

    CURSOR get_internal_party_csr IS
      SELECT internal_party_id from csi_install_parameters;

    CURSOR get_sold_to_org(p_oe_line_id IN NUMBER) IS
      SELECT HZ.PARTY_ID, HZ.CUST_ACCOUNT_ID from HZ_CUST_ACCOUNTS HZ,
                              OE_ORDER_HEADERS_ALL OE,
                              oe_order_lines_all OEL
      WHERE OEL.line_id = p_oe_line_id AND
            OE.HEADER_ID = OEL.HEADER_ID AND
            HZ.CUST_ACCOUNT_ID = OE.SOLD_TO_ORG_ID;

    CURSOR get_owner_ip_id(p_instance_id IN NUMBER) IS
      SELECT INSTANCE_PARTY_ID, PARTY_ID from csi_i_parties
      WHERE INSTANCE_ID = p_instance_id AND
            RELATIONSHIP_TYPE_CODE = 'OWNER' AND
            NVL(ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
            NVL(ACTIVE_END_DATE, SYSDATE + 1) >= SYSDATE;



    l_txn_line_rec             csi_t_datastructures_grp.txn_line_rec;
    l_txn_line_dtl_tbl         csi_t_datastructures_grp.txn_line_detail_tbl;
    l_txn_party_tbl            csi_t_datastructures_grp.txn_party_detail_tbl;
    l_txn_pty_acct_tbl         csi_t_datastructures_grp.txn_pty_acct_detail_tbl;
    l_txn_org_assgn_tbl        csi_t_datastructures_grp.txn_org_assgn_tbl;

    l_txn_ii_reln_tbl          csi_t_datastructures_grp.txn_ii_rltns_tbl;
    l_txn_ext_attrib_vals_tbl  csi_t_datastructures_grp.txn_ext_attrib_vals_tbl;
    l_txn_systems_tbl          csi_t_datastructures_grp.txn_systems_tbl;

    --l_subtxn_name              VARCHAR2(30); --for ER 4746426
    l_om_order_id              NUMBER;
    l_subtxn_id                NUMBER;
    l_return_by_date           DATE;
    l_party_dtl_rec            csi_t_datastructures_grp.txn_party_detail_rec;
    l_new_party_id             NUMBER;
    l_new_party_account_id     NUMBER;
    l_internal_party_id        NUMBER;
    l_curr_inst_pty_id         NUMBER;
    l_curr_pty_id              NUMBER;
    l_party_account_rec        csi_t_datastructures_grp.txn_pty_acct_detail_rec;

    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Create_IB_Transaction';

BEGIN

   -- Initialize return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
   END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_OSP_order_type = ' || p_OSP_order_type || ', p_oe_line_type = ' || p_oe_line_type ||
                                                          ', p_oe_line_id = ' || p_oe_line_id || ', p_csi_instance_id = ' || p_csi_instance_id);
   END IF;

   -- Check input order and line types.
   -- If types not valid , return.
   IF (p_oe_line_type NOT IN ('ORDER','RETURN')) OR
      (p_OSP_order_type NOT IN (AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE,
                                AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_LOAN,
                                AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_BORROW,
                                AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE)) THEN
      RETURN;
   END IF;

   IF (p_oe_line_type = 'ORDER') THEN

      -- get transaction type ID for OM-Shipment.
      OPEN csi_txn_types_csr(G_OM_ORDER);
      FETCH csi_txn_types_csr INTO l_om_order_id;
      IF (csi_txn_types_csr%NOTFOUND) THEN
         CLOSE csi_txn_types_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_TXN_NOTFOUND');
         FND_MESSAGE.Set_Token('TYPE',G_OM_ORDER);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN;
      END IF;
      CLOSE csi_txn_types_csr;

      -- get csi transaction ID for sub type based on OSP Order type
      IF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE THEN
        --l_subtxn_name := G_SUBTXN_EXC_ORDER; --for ER 4746426
        l_subtxn_id := FND_PROFILE.VALUE('AHL_OSP_IB_SUBTXN_EXC_SHIP');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Exchange Order Ship');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_EXC_SHIP'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
        OPEN get_sold_to_org(p_oe_line_id);
        FETCH get_sold_to_org INTO l_new_party_id, l_new_party_account_id;
        IF (get_sold_to_org%NOTFOUND) THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_NEW_PARTY');
            FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER', GET_INSTANCE_NUM_FROM_ID(p_csi_instance_id));
            Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE get_sold_to_org;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE get_sold_to_org;
        -- Populate Party Details
        l_party_dtl_rec.PARTY_SOURCE_TABLE := 'HZ_PARTIES';
        l_party_dtl_rec.PARTY_SOURCE_ID := l_new_party_id;
        l_party_dtl_rec.RELATIONSHIP_TYPE_CODE := 'OWNER';
        l_party_dtl_rec.CONTACT_FLAG := 'N';
        l_party_dtl_rec.TXN_LINE_DETAILS_INDEX := 1;
        -- Populate Party Account Details
        l_party_account_rec.ACCOUNT_ID := l_new_party_account_id;
        l_party_account_rec.RELATIONSHIP_TYPE_CODE := 'OWNER';
        l_party_account_rec.TXN_PARTY_DETAILS_INDEX := 1;
        OPEN get_owner_ip_id(p_csi_instance_id);
        FETCH get_owner_ip_id INTO l_curr_inst_pty_id,
                                        l_curr_pty_id;
        IF (get_owner_ip_id%NOTFOUND) THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_CURR_PARTY');
            FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER', GET_INSTANCE_NUM_FROM_ID(p_csi_instance_id));
            Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE get_owner_ip_id;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE get_owner_ip_id;
        l_party_dtl_rec.INSTANCE_PARTY_ID := l_curr_inst_pty_id;

        l_txn_party_tbl(1) := l_party_dtl_rec;
        l_txn_pty_acct_tbl(1) := l_party_account_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_party_dtl_rec:');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  PARTY_SOURCE_TABLE = ' || l_party_dtl_rec.PARTY_SOURCE_TABLE);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  PARTY_SOURCE_ID = ' || l_party_dtl_rec.PARTY_SOURCE_ID);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  RELATIONSHIP_TYPE_CODE = ' || l_party_dtl_rec.RELATIONSHIP_TYPE_CODE);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  CONTACT_FLAG = ' || l_party_dtl_rec.CONTACT_FLAG);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  TXN_LINE_DETAILS_INDEX = ' || l_party_dtl_rec.TXN_LINE_DETAILS_INDEX);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INSTANCE_PARTY_ID = ' || l_party_dtl_rec.INSTANCE_PARTY_ID);

          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_party_account_rec:');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  ACCOUNT_ID = ' || l_party_account_rec.ACCOUNT_ID);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  RELATIONSHIP_TYPE_CODE = ' || l_party_account_rec.RELATIONSHIP_TYPE_CODE);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  TXN_PARTY_DETAILS_INDEX = ' || l_party_account_rec.TXN_PARTY_DETAILS_INDEX);
        END IF;
      ELSIF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE THEN
        l_subtxn_id := FND_PROFILE.VALUE('AHL_OSP_IB_SUBTXN_SER_SHIP');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Service Order Ship');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_SER_SHIP'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
      ELSIF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_BORROW THEN
        --l_subtxn_name := G_SUBTXN_ORDER;
        l_subtxn_id := FND_PROFILE.VALUE('AHL_OSP_IB_SUBTXN_BOR_SHIP');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Borrow Order Ship');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_BOR_SHIP'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
      END IF;

      /* Commented out by jeli on 11/30/05 for ER 4746426
      OPEN csi_txn_sub_types_csr(l_om_order_id, l_subtxn_name);
      FETCH csi_txn_sub_types_csr INTO l_subtxn_id;
      IF (csi_txn_sub_types_csr%NOTFOUND) THEN
         CLOSE csi_txn_sub_types_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
         FND_MESSAGE.Set_Token('TYPE',l_subtxn_name);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN;
      END IF;
      CLOSE csi_txn_sub_types_csr;
      */
   ELSIF (p_oe_line_type = 'RETURN') THEN

      -- get transaction type ID for RMA-Receipt.
      OPEN csi_txn_types_csr(G_OM_RETURN);
      FETCH csi_txn_types_csr INTO l_om_order_id;
      IF (csi_txn_types_csr%NOTFOUND) THEN
         CLOSE csi_txn_types_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_TXN_NOTFOUND');
         FND_MESSAGE.Set_Token('TYPE',G_OM_RETURN);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN;
      END IF;
      CLOSE csi_txn_types_csr;

      -- get csi transaction ID for sub type based on OSP Order type
      IF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE THEN
        --l_subtxn_name := G_SUBTXN_EXC_RETURN; --for ER 4746426
        l_subtxn_id := fnd_profile.VALUE('AHL_OSP_IB_SUBTXN_EXC_RETURN');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Exchange Order Return');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_EXC_RETURN'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
        -- Get internal Party Id
        OPEN get_internal_party_csr;
        FETCH get_internal_party_csr INTO l_internal_party_id;
        IF (get_internal_party_csr%NOTFOUND) THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_INT_PARTY');
            Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE get_internal_party_csr;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE get_internal_party_csr;
        l_party_dtl_rec.PARTY_SOURCE_TABLE := 'HZ_PARTIES';
        l_party_dtl_rec.PARTY_SOURCE_ID := l_internal_party_id;
        l_party_dtl_rec.RELATIONSHIP_TYPE_CODE := 'OWNER';
        l_party_dtl_rec.CONTACT_FLAG := 'N';
        l_party_dtl_rec.TXN_LINE_DETAILS_INDEX := 1;
        --mpothuku modified on 14-Sep-2007 to fix the Bug 6398921
        --we are creating the IB transactions even if the instance is not present on the order line
        IF(p_csi_instance_id is not null) THEN
          OPEN get_owner_ip_id(p_csi_instance_id);
          FETCH get_owner_ip_id INTO l_curr_inst_pty_id,
                                          l_curr_pty_id;
          IF (get_owner_ip_id%NOTFOUND) THEN
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
              Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_CURR_PARTY');
              FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER', GET_INSTANCE_NUM_FROM_ID(p_csi_instance_id));
              Fnd_Msg_Pub.ADD;
            END IF;
            CLOSE get_owner_ip_id;
            RAISE Fnd_Api.g_exc_error;
          END IF;
          CLOSE get_owner_ip_id;
        END IF;
        ---mpothuku End
        l_party_dtl_rec.INSTANCE_PARTY_ID := l_curr_inst_pty_id;
        l_txn_party_tbl(1) := l_party_dtl_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_party_dtl_rec:');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  PARTY_SOURCE_TABLE = ' || l_party_dtl_rec.PARTY_SOURCE_TABLE);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  PARTY_SOURCE_ID = ' || l_party_dtl_rec.PARTY_SOURCE_ID);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  RELATIONSHIP_TYPE_CODE = ' || l_party_dtl_rec.RELATIONSHIP_TYPE_CODE);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  CONTACT_FLAG = ' || l_party_dtl_rec.CONTACT_FLAG);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  TXN_LINE_DETAILS_INDEX = ' || l_party_dtl_rec.TXN_LINE_DETAILS_INDEX);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INSTANCE_PARTY_ID = ' || l_party_dtl_rec.INSTANCE_PARTY_ID);
        END IF;
      ELSIF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE THEN
        l_subtxn_id := FND_PROFILE.VALUE('AHL_OSP_IB_SUBTXN_SER_RETURN');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Service Order Return');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_SER_RETURN'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
      ELSIF p_OSP_order_type = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_BORROW THEN
        l_subtxn_id := FND_PROFILE.VALUE('AHL_OSP_IB_SUBTXN_BOR_RETURN');
        IF l_subtxn_id IS NULL THEN
          --FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
          --FND_MESSAGE.Set_Token('TYPE','Borrow Order Return');
          FND_MESSAGE.set_name('AHL', 'AHL_OSP_PROFILE_NULL');
          FND_MESSAGE.SET_TOKEN('PROFILE', get_user_profile_option_name('AHL_OSP_IB_SUBTXN_BOR_RETURN'));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RETURN;
        END IF;
        --l_subtxn_name := G_SUBTXN_RETURN; for ER 4746426
      END IF;
      /* Commented out by jeli on 11/30/05 for ER 4746426
      OPEN csi_txn_sub_types_csr(l_om_order_id, l_subtxn_name);
      FETCH csi_txn_sub_types_csr INTO l_subtxn_id;
      IF (csi_txn_sub_types_csr%NOTFOUND) THEN
         CLOSE csi_txn_sub_types_csr;
         FND_MESSAGE.Set_Name('AHL','AHL_OSP_IB_SUBTXN_NOTFOUND');
         FND_MESSAGE.Set_Token('TYPE',l_subtxn_name);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         RETURN;
      END IF;
      CLOSE csi_txn_sub_types_csr;
      */
   END IF;

   l_txn_line_rec.TRANSACTION_LINE_ID := fnd_api.g_miss_num;
   l_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID := l_om_order_id;
   l_txn_line_rec.SOURCE_TRANSACTION_ID := p_oe_line_id;
   l_txn_line_rec.SOURCE_TRANSACTION_TABLE :=  G_TRANSACTION_TABLE;


   -- get order line details.
   OPEN oe_order_lines_csr (p_oe_line_id);
   FETCH oe_order_lines_csr INTO l_txn_line_dtl_tbl(1).INVENTORY_ITEM_ID,
                                 l_txn_line_dtl_tbl(1).QUANTITY,
                                 l_txn_line_dtl_tbl(1).INV_ORGANIZATION_ID,
                                 l_txn_line_dtl_tbl(1).UNIT_OF_MEASURE;
   CLOSE oe_order_lines_csr;

   -- get instance details.
   /*
    mpothuku modified on 14-Sep-2007 to fix the Bug 6398921
    we are creating the IB transactions even if the instance is not present on the order line for Exchange Return Lines
    we do not need to any clauses for exchange orders below.
   */
   IF(p_csi_instance_id is not null) THEN
     OPEN csi_item_instances_csr (p_csi_instance_id);
     FETCH csi_item_instances_csr INTO l_txn_line_dtl_tbl(1).SERIAL_NUMBER,
                                       l_txn_line_dtl_tbl(1).INVENTORY_REVISION,
                                       l_txn_line_dtl_tbl(1).LOT_NUMBER,
                                       l_txn_line_dtl_tbl(1).MFG_SERIAL_NUMBER_FLAG;
     CLOSE csi_item_instances_csr;
   ELSE
     l_txn_line_dtl_tbl(1).SERIAL_NUMBER := NULL;
     l_txn_line_dtl_tbl(1).INVENTORY_REVISION := NULL;
     l_txn_line_dtl_tbl(1).LOT_NUMBER := NULL;
     l_txn_line_dtl_tbl(1).MFG_SERIAL_NUMBER_FLAG := NULL;
   END IF;
   --mpothuku End

   l_txn_line_dtl_tbl(1).SOURCE_TRANSACTION_FLAG := 'Y';
--   l_txn_line_dtl_tbl(1).TRANSACTION_LINE_ID := p_oe_line_id;
   l_txn_line_dtl_tbl(1).SUB_TYPE_ID := l_subtxn_id;
   /*
    mpothuku modified on 14-Sep-2007 to fix the Bug 6398921
    we are creating the IB transactions even if the instance is not present on the order line for Exchange Return Lines
    we do not need to any clauses for exchange orders below.
   */
   IF(p_csi_instance_id is not null) THEN
    l_txn_line_dtl_tbl(1).INSTANCE_EXISTS_FLAG := 'Y';
    l_txn_line_dtl_tbl(1).INSTANCE_ID := p_csi_instance_id;
   END IF;
   --mpothuku End

   l_txn_line_dtl_tbl(1).PRESERVE_DETAIL_FLAG := 'Y';

   -- get return by date.
   IF (p_oe_line_type = 'ORDER') THEN
      OPEN ahl_osp_order_lines_csr(p_oe_line_id);
      FETCH ahl_osp_order_lines_csr INTO l_return_by_date;
      CLOSE ahl_osp_order_lines_csr;

      -- if null then initialise to system date.
      IF (l_return_by_date IS NULL) THEN
         l_return_by_date := SYSDATE;
      END IF;

      l_txn_line_dtl_tbl(1).RETURN_BY_DATE := l_return_by_date;

   END IF;

   IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_txn_line_rec:');
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SOURCE_TRANSACTION_TYPE_ID = ' || l_txn_line_rec.SOURCE_TRANSACTION_TYPE_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SOURCE_TRANSACTION_ID = ' || l_txn_line_rec.SOURCE_TRANSACTION_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SOURCE_TRANSACTION_TABLE = ' || l_txn_line_rec.SOURCE_TRANSACTION_TABLE);

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_txn_line_dtl_tbl(1):');
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INVENTORY_ITEM_ID = ' || l_txn_line_dtl_tbl(1).INVENTORY_ITEM_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  QUANTITY = ' || l_txn_line_dtl_tbl(1).QUANTITY);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INV_ORGANIZATION_ID = ' || l_txn_line_dtl_tbl(1).INV_ORGANIZATION_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  UNIT_OF_MEASURE = ' || l_txn_line_dtl_tbl(1).UNIT_OF_MEASURE);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SERIAL_NUMBER = ' || l_txn_line_dtl_tbl(1).SERIAL_NUMBER);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INVENTORY_REVISION = ' || l_txn_line_dtl_tbl(1).INVENTORY_REVISION);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  LOT_NUMBER = ' || l_txn_line_dtl_tbl(1).LOT_NUMBER);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  MFG_SERIAL_NUMBER_FLAG = ' || l_txn_line_dtl_tbl(1).MFG_SERIAL_NUMBER_FLAG);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SOURCE_TRANSACTION_FLAG = ' || l_txn_line_dtl_tbl(1).SOURCE_TRANSACTION_FLAG);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  TRANSACTION_LINE_ID = ' || l_txn_line_dtl_tbl(1).TRANSACTION_LINE_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  SUB_TYPE_ID = ' || l_txn_line_dtl_tbl(1).SUB_TYPE_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INSTANCE_EXISTS_FLAG = ' || l_txn_line_dtl_tbl(1).INSTANCE_EXISTS_FLAG);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  INSTANCE_ID = ' || l_txn_line_dtl_tbl(1).INSTANCE_ID);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  PRESERVE_DETAIL_FLAG = ' || l_txn_line_dtl_tbl(1).PRESERVE_DETAIL_FLAG);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  RETURN_BY_DATE = ' || l_txn_line_dtl_tbl(1).RETURN_BY_DATE);
   END IF;


   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call csi_t_txn_details_grp.create_transaction_dtls.');
   END IF;
   csi_t_txn_details_grp.create_transaction_dtls(
      p_api_version           => 1.0,
      p_commit                => p_commit,
      -- Changed by jaramana on January 14, 2008 for the Requisition ER 6034236
      p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
      px_txn_line_rec         => l_txn_line_rec,
      px_txn_line_detail_tbl  => l_txn_line_dtl_tbl,
      px_txn_party_detail_tbl => l_txn_party_tbl,
      px_txn_pty_acct_detail_tbl  => l_txn_pty_acct_tbl,
      px_txn_ii_rltns_tbl     => l_txn_ii_reln_tbl,
      px_txn_org_assgn_tbl    => l_txn_org_assgn_tbl,
      px_txn_ext_attrib_vals_tbl  => l_txn_ext_attrib_vals_tbl,
      px_txn_systems_tbl      => l_txn_systems_tbl,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);


   IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to csi_t_txn_details_grp.create_transaction_dtls. x_return_status = ' || x_return_status);
   END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Create_IB_Transaction;


-- Delete IB sub-txn for the oe line.
PROCEDURE Delete_IB_Transaction(
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN            VARCHAR2  := FND_API.G_FALSE,
    p_validation_level       IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status          OUT NOCOPY            VARCHAR2,
    x_msg_count              OUT NOCOPY            NUMBER,
    x_msg_data               OUT NOCOPY            VARCHAR2,
    p_oe_line_id             IN            NUMBER)

IS

  CURSOR csi_txn_lines_csr (p_oe_line_id IN  NUMBER) IS
    SELECT transaction_line_id
    FROM csi_t_transaction_lines
    WHERE SOURCE_TRANSACTION_ID = p_oe_line_id
    -- 3/3/03: Corrected to include txn table
    AND SOURCE_TRANSACTION_TABLE = G_TRANSACTION_TABLE;

  l_transaction_line_id  NUMBER;

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Delete_IB_Transaction';

BEGIN

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
   END IF;

   -- Initialize return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN csi_txn_lines_csr (p_oe_line_id);
  FETCH csi_txn_lines_csr INTO l_transaction_line_id;
  CLOSE csi_txn_lines_csr;

  IF (l_transaction_line_id IS NOT NULL) THEN

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'About to call csi_t_txn_details_grp.delete_transaction_dtls.');
    END IF;

    csi_t_txn_details_grp.delete_transaction_dtls
       ( p_api_version           => 1.0,
         p_commit                => p_commit,
         -- Changed by jaramana on January 14, 2008 for the Requisition ER 6034236
         p_init_msg_list         => FND_API.G_FALSE,--p_init_msg_list,
         p_validation_level      => p_validation_level,
         p_transaction_line_id   => l_transaction_line_id,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EVENT, L_DEBUG_KEY, 'Returned from call to csi_t_txn_details_grp.delete_transaction_dtls. x_return_status = ' || x_return_status);
    END IF;

  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Delete_IB_Transaction;

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Convert_SubTxn_Type
--  Type              : Public
--  Function          : API to delete OSP shipment return lines and change IB transaction
--                      sub types for ship-only lines while converting an OSP Order from
--                      Exchange to Service type or vice versa.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Convert_SubTxn_Type Parameters:
--       p_osp_order_id          IN NUMBER
--         The header_id for the OSP Order that is going through a type change
--       p_old_order_type_code   IN VARCHAR2(30)
--         The old type of the OSP Order. Can be SERVICE or EXCHANGE only
--       p_new_order_type_code   IN VARCHAR2(30)
--         The new type of the OSP Order. Can be EXCHANGE or SERVICE only.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Convert_SubTxn_Type (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN        VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN        VARCHAR2  := NULL,
    p_osp_order_id          IN        NUMBER,
    p_old_order_type_code   IN        VARCHAR2,
    p_new_order_type_code   IN        VARCHAR2,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2) IS

  CURSOR validate_osp_id_csr (p_osp_order_id IN  NUMBER) IS
    SELECT 'X' from ahl_osp_orders_b where
    OSP_ORDER_ID = p_osp_order_id and
    status_code <> AHL_OSP_ORDERS_PVT.G_OSP_CLOSED_STATUS and
    ORDER_TYPE_CODE IN (AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE,
                        AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE);

  CURSOR get_return_line_ids_csr (p_osp_order_id IN  NUMBER) IS
    --mpothuku added distinct on 13-Feb-2007 for implementing the Osp Receiving feature.
    --If there are multiple services for the same physical item, the following query will return the same return line id multiple
    --times, and this leads to calls to Delete_Cancel_Order multiple times leading to a run-time error.
    SELECT DISTINCT OSPL.OE_RETURN_LINE_ID, OE.shipped_quantity, OE.booked_flag
    from ahl_osp_order_lines OSPL, oe_order_lines_all OE
    where OSPL.osp_order_id = p_osp_order_id AND
    OSPL.OE_RETURN_LINE_ID IS NOT NULL AND
    OE.line_id = OSPL.OE_RETURN_LINE_ID;

  l_api_name       CONSTANT VARCHAR2(30) := 'Convert_SubTxn_Type';
  l_api_version    CONSTANT NUMBER       := 1.0;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Convert_SubTxn_Type';
  l_dummy          VARCHAR2(1);
  l_oe_return_line_id NUMBER;
  l_shipped_quantity  NUMBER;
  l_booked_flag       VARCHAR2(1);
  l_oe_line_ids_tbl   SHIP_ID_TBL_TYPE;
  l_temp_count        NUMBER := 0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Convert_SubTxn_Type_Pub;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  -- Validate the OSP Order Id
  OPEN validate_osp_id_csr(p_osp_order_id);
  FETCH validate_osp_id_csr INTO l_dummy;
  IF (validate_osp_id_csr%NOTFOUND) THEN
    CLOSE validate_osp_id_csr;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
       Fnd_Message.set_name('AHL', 'AHL_OSP_HEADER_ID_INV');
       Fnd_Msg_Pub.ADD;
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;
  CLOSE validate_osp_id_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OSP Id validated.');
  END IF;

  -- Validate the type codes
  IF ((p_old_order_type_code IS NULL) OR
     (p_new_order_type_code IS NULL) OR
     (p_old_order_type_code = p_new_order_type_code) OR
     (p_old_order_type_code NOT IN (AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE,
                                    AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE)) OR
     (p_new_order_type_code NOT IN (AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE,
                                    AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE))) THEN
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
      Fnd_Message.set_name('AHL', 'AHL_OSP_INV_TYPE_CHANGE');
      Fnd_Msg_Pub.ADD;
    IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
    END IF;
    END IF;
    RAISE Fnd_Api.g_exc_error;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Validated Order type codes.');
  END IF;

  -- Validate that the return quantity is zero
  OPEN get_return_line_ids_csr(p_osp_order_id);
  LOOP
    FETCH get_return_line_ids_csr INTO l_oe_return_line_id,
                                       l_shipped_quantity,
                                       l_booked_flag;
    EXIT WHEN get_return_line_ids_csr%NOTFOUND;
    IF (l_shipped_quantity IS NOT NULL AND
        l_shipped_quantity > 0) THEN
      -- Return line is already shipped: Too late to convert!
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
        Fnd_Message.set_name('AHL', 'AHL_OSP_ALREADY_SHIPPED');
        Fnd_Msg_Pub.ADD;
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
        END IF;
      END IF;
      CLOSE get_return_line_ids_csr;
      RAISE Fnd_Api.g_exc_error;
    END IF;
    -- Return line not yet shipped: Prepare to delete it
    l_temp_count := l_temp_count + 1;
    l_oe_line_ids_tbl(l_temp_count) := l_oe_return_line_id;
  END LOOP;
  CLOSE get_return_line_ids_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Validated return quantities.');
  END IF;

  IF (l_temp_count > 0) THEN
    -- Delete all return shipment lines
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_Cancel_Order.');
    END IF;

    Delete_Cancel_Order (p_api_version      => 1.0,
                         p_init_msg_list    => FND_API.G_FALSE,
                         p_commit           => FND_API.G_FALSE,
                         p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                         p_oe_header_id     => NULL, -- Don't delete the shipment header!
                         p_oe_lines_tbl     => l_oe_line_ids_tbl,  -- Delete only the return lines
                         p_cancel_flag      => FND_API.G_FALSE,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Delete_Cancel_Order: x_return_status = ' || x_return_status);
    END IF;
  ELSE
    null;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Not calling Delete_Cancel_Order since there are no return shipment lines');
    END IF;
  END IF;

  -- If the deletion has succeeded, proceed with converting the
  -- Ship only lines
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    Convert_Ship_Only_Lines(p_osp_order_id        => p_osp_order_id,
                            p_old_order_type_code => p_old_order_type_code,
                            p_new_order_type_code => p_new_order_type_code);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Convert_Ship_Only_Lines returned with no exception');
    END IF;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Convert_SubTxn_Type_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Convert_SubTxn_Type_Pub;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Convert_SubTxn_Type_Pub;
    fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                            p_procedure_name => 'Convert_SubTxn_Type',
                            p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
END Convert_SubTxn_Type;


-- Local helper method that deletes IB sub transactions for ship only lines
-- and creates new ones based on the new OSP Order type.
-- This method also changes the ownership if the shipment has already occurred.
PROCEDURE Convert_Ship_Only_Lines(
    p_osp_order_id        IN         NUMBER,
    p_old_order_type_code IN         VARCHAR2,
    p_new_order_type_code IN         VARCHAR2) IS

  CURSOR get_ship_only_lines_csr (p_osp_order_id IN  NUMBER) IS
  --Modified by mpothuku on 21-Feb-06 to fix the Perf Bug #4919255
  /*
    SELECT OSPL.OE_SHIP_LINE_ID,
           ospl.item_instance_id,
           --wo.item_instance_id, --Jeli on 01/24/2006 for ER 4746426
           NVL(OE.shipped_quantity, 0)
    from ahl_osp_order_lines_v OSPL, oe_order_lines_all OE --, AHL_WORKORDERS_OSP_V wo
    where OSPL.osp_order_id = p_osp_order_id AND
    --ospl.workorder_id = wo.workorder_id AND
    OSPL.OE_SHIP_LINE_ID IS NOT NULL AND
    OE.line_id = OSPL.OE_SHIP_LINE_ID;
  */
    SELECT OSPL.OE_SHIP_LINE_ID,
           decode(wo.workorder_id, null, csii.instance_id, vts.instance_id) item_instance_id,
           NVL(OE.shipped_quantity, 0)
      from ahl_osp_order_lines OSPL,
           oe_order_lines_all OE,
           ahl_workorders wo,
           ahl_visit_tasks_b vts,
           csi_item_instances csii
     where OSPL.osp_order_id = p_osp_order_id
       AND OSPL.OE_SHIP_LINE_ID IS NOT NULL
       AND OE.line_id = OSPL.OE_SHIP_LINE_ID
       AND wo.workorder_id(+) = ospl.workorder_id
       AND wo.visit_task_id = vts.visit_task_id(+)
       AND csii.last_vld_organization_id(+) = ospl.inventory_org_id
       AND csii.inventory_item_id(+) = ospl.inventory_item_id
       AND csii.serial_number(+) = ospl.serial_number;

  CURSOR get_internal_party_csr IS
    SELECT internal_party_id from csi_install_parameters;

  CURSOR get_owner_ip_id(p_instance_id IN NUMBER) IS
    SELECT INSTANCE_PARTY_ID, PARTY_ID, OBJECT_VERSION_NUMBER from csi_i_parties where
    INSTANCE_ID = p_instance_id AND
    relationship_type_code = 'OWNER' AND
    NVL(ACTIVE_START_DATE, SYSDATE - 1) <= SYSDATE AND
    NVL(ACTIVE_END_DATE, SYSDATE + 1) >= SYSDATE;

  CURSOR get_sold_to_org(p_oe_line_id IN NUMBER) IS
    SELECT HZ.PARTY_ID, HZ.CUST_ACCOUNT_ID from HZ_CUST_ACCOUNTS HZ,
                            OE_ORDER_HEADERS_ALL OE,
                            oe_order_lines_all OEL
    WHERE OEL.line_id = p_oe_line_id AND
          OE.HEADER_ID = OEL.HEADER_ID AND
          HZ.CUST_ACCOUNT_ID = OE.SOLD_TO_ORG_ID;


  l_oe_ship_line_id   NUMBER;
  l_shipped_quantity  NUMBER;
  l_item_instance_id  NUMBER;
  l_temp_count        NUMBER := 0;
  l_internal_party_id NUMBER;
  l_curr_inst_pty_id  NUMBER;
  l_curr_pty_id       NUMBER;
  l_new_party_id      NUMBER;
  l_new_party_acc_id  NUMBER;
  l_party_ovn         NUMBER;
  l_party_tbl         CSI_DATASTRUCTURES_PUB.PARTY_TBL;
  l_party_rec         CSI_DATASTRUCTURES_PUB.PARTY_REC;
  l_party_account_tbl CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_TBL;
  l_party_account_rec CSI_DATASTRUCTURES_PUB.PARTY_ACCOUNT_REC;
  l_transaction_rec   CSI_DATASTRUCTURES_PUB.TRANSACTION_REC;
  l_instance_rec          csi_datastructures_pub.instance_rec;
  l_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
  l_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
  l_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
  l_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
  l_instance_id_lst       csi_datastructures_pub.id_tbl;

  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Convert_Ship_Only_Lines';

  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;
  -- Get internal Party Id
  OPEN get_internal_party_csr;
  FETCH get_internal_party_csr INTO l_internal_party_id;
  IF (get_internal_party_csr%NOTFOUND) THEN
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
      Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_INT_PARTY');
      Fnd_Msg_Pub.ADD;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
      END IF;
    END IF;
    CLOSE get_internal_party_csr;
    RAISE Fnd_Api.g_exc_error;
  END IF;
  CLOSE get_internal_party_csr;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Got Internal Party Id: ' || l_internal_party_id);
  END IF;

  -- Process ship only lines
  OPEN get_ship_only_lines_csr(p_osp_order_id);
  LOOP
    FETCH get_ship_only_lines_csr INTO l_oe_ship_line_id,
                                       l_item_instance_id,
                                       l_shipped_quantity;
    EXIT WHEN get_ship_only_lines_csr%NOTFOUND;
    l_temp_count := l_temp_count + 1;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'index = ' || l_temp_count || ', l_oe_ship_line_id = ' || l_oe_ship_line_id || ', l_shipped_quantity = ' || l_shipped_quantity || ', l_item_instance_id = ' || l_item_instance_id);
    END IF;
    --IF (l_shipped_quantity > 0) THEN --Jeli on 01/24/2006 for ER47
    IF (l_shipped_quantity > 0 AND l_item_instance_id IS NOT NULL) THEN
      -- Already shipped: Need to change ownership
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Since l_shipped_quantity > 0, need to change owner');
      END IF;
      OPEN get_owner_ip_id(l_item_instance_id);
      FETCH get_owner_ip_id INTO l_curr_inst_pty_id,
                                 l_curr_pty_id,
                                 l_party_ovn;
      IF (get_owner_ip_id%NOTFOUND) THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_CURR_PARTY');
          FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER', GET_INSTANCE_NUM_FROM_ID(l_item_instance_id));
          Fnd_Msg_Pub.ADD;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
          END IF;
        END IF;
        CLOSE get_owner_ip_id;
        CLOSE get_ship_only_lines_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE get_owner_ip_id;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Got current owner, l_curr_pty_id = ' || l_curr_pty_id || ', l_curr_inst_pty_id = ' || l_curr_inst_pty_id);
      END IF;

      IF (p_new_order_type_code = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE) THEN
        -- Exchange to Service conversion: New owner will be internal
        l_new_party_id := l_internal_party_id;
        -- l_new_party_acc_id will be null
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Exchange to Service conversion: New internal owner = ' || l_new_party_id);
        END IF;
      ELSIF (p_new_order_type_code = AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_EXCHANGE) THEN
        -- Service to Exchange conversion: New owner will be the ship to org
        -- Determine the id of this party
        OPEN get_sold_to_org(l_oe_ship_line_id);
        FETCH get_sold_to_org INTO l_new_party_id, l_new_party_acc_id;
        IF (get_sold_to_org%NOTFOUND) THEN
          IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
            Fnd_Message.set_name('AHL', 'AHL_OSP_CANT_GET_NEW_PARTY');
            FND_MESSAGE.SET_TOKEN('INSTANCE_NUMBER', GET_INSTANCE_NUM_FROM_ID(l_item_instance_id));
            Fnd_Msg_Pub.ADD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, L_DEBUG_KEY, FALSE);
            END IF;
          END IF;
          CLOSE get_sold_to_org;
          CLOSE get_ship_only_lines_csr;
          RAISE Fnd_Api.g_exc_error;
        END IF;
        CLOSE get_sold_to_org;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Service to Exchange conversion: New external owner (party) = ' || l_new_party_id || ', New Party Account = ' || l_new_party_acc_id);
        END IF;
      ELSE
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.set_name('AHL', 'AHL_OSP_INV_TYPE_CHANGE');
          Fnd_Msg_Pub.ADD;
          IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, L_DEBUG_KEY, FALSE);
          END IF;
        END IF;
        CLOSE get_ship_only_lines_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
      -- Call CSI API CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE
      -- Populate the Party Rec
      l_party_rec.instance_id := l_item_instance_id;
      l_party_rec.party_source_table := 'HZ_PARTIES';
      l_party_rec.party_id := l_new_party_id;
      l_party_rec.relationship_type_code := 'OWNER';
      l_party_rec.instance_party_id := l_curr_inst_pty_id;
      l_party_rec.object_version_number := l_party_ovn;
      l_party_tbl(1) := l_party_rec;
      -- Populate the Party Account Rec only if new Party is external
      IF (l_new_party_id <> l_internal_party_id) THEN
        l_party_account_rec.instance_party_id := l_curr_inst_pty_id;
        l_party_account_rec.party_account_id := l_new_party_acc_id;
        l_party_account_rec.relationship_type_code := 'OWNER';
        l_party_account_rec.call_contracts := FND_API.G_FALSE;
        l_party_account_rec.parent_tbl_index := 1;
        l_party_account_tbl(1) := l_party_account_rec;
      END IF;
      -- Populate the Transaction Rec
      l_transaction_rec.transaction_date := sysdate;
      l_transaction_rec.source_transaction_date := sysdate;
      l_transaction_rec.transaction_type_id := 1;
      -- Call the API
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE');

        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_party_rec:');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  instance_id = ' || l_party_rec.instance_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  party_source_table = ' || l_party_rec.party_source_table);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  party_id = ' || l_party_rec.party_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  relationship_type_code = ' || l_party_rec.relationship_type_code);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  instance_party_id = ' || l_party_rec.instance_party_id);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  object_version_number = ' || l_party_rec.object_version_number);

        IF (l_new_party_id <> l_internal_party_id) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_party_account_rec:');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  instance_party_id = ' || l_party_account_rec.instance_party_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  party_account_id = ' || l_party_account_rec.party_account_id);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  relationship_type_code = ' || l_party_account_rec.relationship_type_code);
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, '  call_contracts = ' || l_party_account_rec.call_contracts);
        END IF;
      END IF;

--Updated by Jerry on 07/26/05 after the discussion with CSI Srini. From his suggestion,
--replacing the call to CSI_PARTY_RELATIONSHIPS_PUB.UPDATE_INST_PARTY_RELATIONSHIP with
-- CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE, and keep the original existing parameter i
--(no change) and just adding some new parameters with blank values.
      CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE(
          p_api_version           => 1.0,
          p_commit                => FND_API.G_FALSE,
          p_init_msg_list         => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          p_instance_rec          => l_instance_rec,
          p_ext_attrib_values_tbl => l_ext_attrib_values_tbl,
          p_party_tbl             => l_party_tbl,
          p_account_tbl           => l_party_account_tbl,
          p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
          p_org_assignments_tbl   => l_org_assignments_tbl,
          p_asset_assignment_tbl  => l_asset_assignment_tbl,
          p_txn_rec               => l_transaction_rec,
          x_instance_id_lst       => l_instance_id_lst,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from CSI_ITEM_INSTANCE_PUB.UPDATE_ITEM_INSTANCE, x_return_status = ' || l_return_status);
      END IF;
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        CLOSE get_ship_only_lines_csr;
        RAISE Fnd_Api.g_exc_error;
      END IF;
    ELSE
      -- Not yet shipped: No need to change ownership
      -- Delete existing IB subtransaction (with old type)
      -- Jeli added the instance_id nullable check on 01/24/2006 for ER 4746426
      IF (l_item_instance_id IS NULL) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Non-tracked item, so without IB transaction deletion or creation');
        END IF;
      ELSE
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Since l_shipped_quantity = 0, No need to change owner. Calling Delete_IB_Transaction.');
        END IF;
        Delete_IB_Transaction(
          p_init_msg_list    => FND_API.G_FALSE,
          p_commit           => FND_API.G_FALSE,
          p_validation_level => FND_API.G_VALID_LEVEL_FULL,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          p_oe_line_id       => l_oe_ship_line_id);
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from Delete_IB_Transaction, x_return_status = ' || l_return_status);
        END IF;
        IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          -- Create new IB subtransaction (with new type)
          Create_IB_Transaction(
            p_init_msg_list    => FND_API.G_FALSE,
            p_commit           => FND_API.G_FALSE,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            p_OSP_order_type   => p_new_order_type_code,
            p_oe_line_type     => 'ORDER',
            p_oe_line_id       => l_oe_ship_line_id,
            p_csi_instance_id  => l_item_instance_id);
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from Create_IB_Transaction, x_return_status = ' || l_return_status);
          END IF;
          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            -- Error creating IB Subtransaction: throw exception
            CLOSE get_ship_only_lines_csr;
            RAISE Fnd_Api.g_exc_error;
          END IF;
        ELSE
          -- Error deleting IB Subtransaction: throw exception
          CLOSE get_ship_only_lines_csr;
          RAISE Fnd_Api.g_exc_error;
        END IF;
      END IF; --Jeli added this END IF; on 01/24/2006 for ER 4746426
    END IF;
  END LOOP;
  CLOSE get_ship_only_lines_csr;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

END Convert_Ship_Only_Lines;

FUNCTION GET_INSTANCE_NUM_FROM_ID(p_instance_id IN NUMBER )
RETURN VARCHAR2
IS
 CURSOR csi_instance_num_csr(p_instance_id IN NUMBER) IS
    SELECT INSTANCE_NUMBER
    FROM CSI_ITEM_INSTANCES
    WHERE INSTANCE_ID = p_instance_id;

  p_instance_num CSI_ITEM_INSTANCES.INSTANCE_NUMBER%TYPE;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.GET_INSTANCE_NUM_FROM_ID';

BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'GET_INSTANCE_NUM_FROM_ID: p_instance_id = ' || p_instance_id);
  END IF;
  IF p_instance_id IS NULL THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'GET_INSTANCE_NUM_FROM_ID: returning NULL');
    END IF;
    RETURN NULL;
  ELSE
    OPEN csi_instance_num_csr(p_instance_id);
    FETCH csi_instance_num_csr into p_instance_num;
    CLOSE csi_instance_num_csr;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'GET_INSTANCE_NUM_FROM_ID: returning ' || p_instance_num);
    END IF;
    RETURN p_instance_num;
  END IF;
END;

--FP Bug fix: 5380842 for the Customer Change when Vendor Changes: By mpothuku on 22nd August, 2006

PROCEDURE Handle_Vendor_Change (
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_default               IN        VARCHAR2  := FND_API.G_TRUE,
    p_module_type           IN        VARCHAR2  := NULL,
    p_osp_order_id          IN        NUMBER,
    p_vendor_id             IN        NUMBER,
    p_vendor_loc_id         IN        NUMBER,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2) AS


  l_api_name       CONSTANT VARCHAR2(30)  := 'Handle_Vendor_Change';
  l_api_version    CONSTANT NUMBER        := 1.0;
  L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Handle_Vendor_Change';

    CURSOR get_shipment_det_csr
    IS
    SELECT OE_HEADER_ID
    FROM   AHL_OSP_ORDERS_B
    WHERE  OSP_ORDER_ID = p_osp_order_id;

    CURSOR check_vendor_site_valid_csr
    IS
    SELECT 1
    FROM   po_vendor_sites_all
    WHERE  VENDOR_SITE_ID =   p_vendor_loc_id
      AND  VENDOR_ID =  p_vendor_id;

    CURSOR check_cust_vendor_rel
    IS
    SELECT CUSTOMER_SITE_ID
    FROM   AHL_VENDOR_CUSTOMER_RELS
    WHERE VENDOR_SITE_ID = p_vendor_loc_id;

    CURSOR ahl_order_vendor_detls_csr(p_osp_order_id IN NUMBER) IS
    SELECT osp.vendor_id,
     osp.vendor_site_id,
     osp.vendor_contact_id,
     osp.osp_order_number,
     cust.customer_site_id,
     cust.customer_id
      FROM ahl_osp_orders_b osp,
           ahl_vendor_customer_rels_v cust
     WHERE osp.osp_order_id = p_osp_order_id
       AND osp.vendor_site_id = cust.vendor_site_id;

    CURSOR get_oe_order_lines(c_oe_header_id IN NUMBER) IS
    select line_id from oe_order_lines_all
     where header_id = c_oe_header_id;

    l_vendor_cust_dtls ahl_order_vendor_detls_csr%ROWTYPE;
    l_oe_header_id NUMBER;
    l_oe_line_id NUMBER;

   l_header_rec            OE_ORDER_PUB.header_rec_type;
   l_line_tbl              OE_ORDER_PUB.line_tbl_type;
   l_msg_data              VARCHAR2(2000);
   l_msg_index_out         NUMBER;
   l_index                 NUMBER;
   l_oe_line_rec           OE_ORDER_PUB.line_rec_type;
   l_count                 NUMBER := 0;

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Handle_Vendor_Change;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Added by mpothuku on 11-Jul-06 to raise any validation errors that may have been accumulated by the AHL_OSP_ORDERS_PVT procedure
  --We do not have any warning messages hence if the message count is > 0 then it means there are validation errors and since
  --we call a Public API in this procedure, its better we throw the errore here itself.

  IF FND_MSG_PUB.count_msg > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --mpothuku End

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  IF p_osp_order_id IS NOT NULL THEN
    OPEN get_shipment_det_csr;
    FETCH get_shipment_det_csr INTO l_oe_header_id;
    IF get_shipment_det_csr%NOTFOUND THEN
    CLOSE get_shipment_det_csr;
    RETURN;
    END IF;
    CLOSE get_shipment_det_csr;
  END IF;

  --Added by mpothuku on 08-may-06 for fixing the Bug 5212130
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_osp_order_id = ' || p_osp_order_id);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_vendor_id = ' || p_vendor_id);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_vendor_loc_id = ' || p_vendor_loc_id);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_oe_header_id = ' || l_oe_header_id);
  END IF;

  OPEN ahl_order_vendor_detls_csr(p_osp_order_id);
  FETCH ahl_order_vendor_detls_csr INTO l_vendor_cust_dtls;
  CLOSE ahl_order_vendor_detls_csr;

  --Added by mpothuku on 08-may-06 for fixing the Bug 5212130
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.vendor_id = ' || l_vendor_cust_dtls.vendor_id);
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.vendor_site_id = ' || l_vendor_cust_dtls.vendor_site_id);
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.customer_id = ' || l_vendor_cust_dtls.customer_id);
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_vendor_cust_dtls.customer_site_id = ' || l_vendor_cust_dtls.customer_site_id);
  END IF;

  IF l_vendor_cust_dtls.customer_site_id IS NULL THEN
      Fnd_Message.set_name('AHL', 'AHL_OSP_CUST_SETUP_NOTFOUND');
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.g_exc_error;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to OE_ORDER_GRP.PROCESS_ORDER');
  END IF;

  l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
  l_line_tbl   := OE_ORDER_PUB.G_MISS_LINE_TBL;

  l_header_rec.header_id := l_oe_header_id;
  l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
  l_header_rec.sold_to_org_id := l_vendor_cust_dtls.customer_id;
  l_header_rec.ship_to_org_id := l_vendor_cust_dtls.customer_site_id;

  --Retrieve all the order lines
  --Fix for the customer site change related Bug 6521712 fix, by jaramana on January 14, 2008
  OPEN get_oe_order_lines(l_oe_header_id);
  LOOP
    FETCH get_oe_order_lines INTO l_oe_line_id;
    EXIT WHEN get_oe_order_lines%NOTFOUND;
    l_oe_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_oe_line_id = ' || l_oe_line_id);
    END IF;
    l_oe_line_rec.line_id := l_oe_line_id;
    l_oe_line_rec.sold_to_org_id := l_vendor_cust_dtls.customer_id;
    l_oe_line_rec.ship_to_org_id := l_vendor_cust_dtls.customer_site_id;
    l_oe_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    l_line_tbl(l_count) := l_oe_line_rec;
    l_count := l_count + 1;
  END LOOP;
  CLOSE get_oe_order_lines;

  --OE_ORDER_GRP uses its own message stack OE_MSG_PUB, so we should pass p_init_msg_list as true to this API
  --Note that this also does an FND_MSG_PUB.initialize along with clearing its own error stack
  OE_ORDER_GRP.PROCESS_ORDER(
    p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_TRUE,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data,
    p_header_rec          => l_header_rec,
    --p_header_val_rec      => x_header_val_rec,
    --Following line uncommented for the customer site change related Bug 6521712 fix, by jaramana on January 14, 2008
    p_line_tbl            => l_line_tbl,
    --p_line_val_tbl        => x_line_val_tbl,
    --p_lot_serial_tbl      => l_lot_serial_tbl,
    x_header_rec          => x_header_rec,
    x_header_val_rec      => x_header_val_rec,
    x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
    x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
    x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
    x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
    x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
    x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
    x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
    x_line_tbl               =>     x_line_tbl      ,
    x_line_val_tbl           =>    x_line_val_tbl ,
    x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
    x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
    x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
    x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
    x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
    x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
    x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
    x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
    x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
    x_action_request_tbl     => x_action_request_tbl  );


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed OE_ORDER_GRP.PROCESS_ORDER, x_return_status = ' || x_return_status);
  END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    FOR i IN 1..x_msg_count LOOP
      OE_MSG_PUB.Get(p_msg_index => i,
                     p_encoded => FND_API.G_FALSE,
                     p_data    => l_msg_data,
                     p_msg_index_out => l_msg_index_out);
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                              p_procedure_name => 'processOrder',
                              p_error_text     => substr(l_msg_data,1,240));
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
      END IF;

    END LOOP;
  END IF;

  /*
  x_msg_count := FND_MSG_PUB.count_msg;

  IF x_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
  END IF;
  */

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  /*
  If success is returned by the Public API, clear the message stack to eat up any warning messages from OM API.
  Note that we may need to revise this approach at a later point to show the warning messages too
  If this is not done, AHL_OSP_ORDERS_PVT assumes that there is an error if the message stack count is > 0
  Also note that had there been any validation errors that had been accumulated we would have thrown at the beginning
  of this procedure
  */

  ELSIF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    --Added the message logging on January 14, 2008 to fix the Bug 5935388/6504122
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..FND_MSG_PUB.count_msg LOOP
        FND_MSG_PUB.get (
            p_msg_index      => i,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out );
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY,'OE: Warning ' || i || ': ' || l_msg_data);
      END LOOP;
    END IF;
    FND_MSG_PUB.Initialize;
  END IF;

  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Handle_Vendor_Change;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Handle_Vendor_Change;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Handle_Vendor_Change;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Handle_Vendor_Change',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);

END;


--Added by mpothuku on 01-Jun-2007 to support the part number and serial number change for osp lines
----------------------------------------------------------------------------------------------------
-- FUNCTION
--    Is_part_chg_valid_for_ospline
--
-- PURPOSE
--    This function checks that the osp line is valid for part number/serial number change.
--
-- NOTES
--    It returns 'N' if
--       1. There is no ship line for the osp line
--       2. Item is not IB tracked
--       3. Line status is PO Deleted/PO Cancelled/Req Deleted/Req Cancelled
--       4. Item is not shipped
--       5. Item has already been received
--    Otherwise it will return 'Y'
-----------------------------------------------------------------------------------------------------

FUNCTION Is_part_chg_valid_for_ospline(p_osp_order_line_id IN NUMBER)
RETURN VARCHAR2
IS

CURSOR get_inventory_flags(c_inv_item_id IN NUMBER, c_inv_org_id IN NUMBER) IS
SELECT serial_number_control_code,
       comms_nl_trackable_flag
  FROM mtl_system_items_b
 WHERE inventory_item_id = c_inv_item_id
   AND organization_id =  c_inv_org_id;

CURSOR get_ship_line_instance(c_osp_order_line_id IN NUMBER) IS
SELECT csi.instance_id,
       csi.inventory_item_id,
       csi.serial_number,
       csi.last_vld_organization_id
  FROM csi_t_transaction_lines tl,
       csi_t_txn_line_details tld,
       ahl_osp_order_lines ospl,
       csi_item_instances csi
 WHERE tl.source_transaction_id = ospl.oe_ship_line_id
   AND tl.source_transaction_table = G_TRANSACTION_TABLE
   AND tl.transaction_line_id = tld.transaction_line_id
   AND ospl.osp_order_line_id = c_osp_order_line_id
   AND tld.instance_id = csi.instance_id;

CURSOR get_order_details(c_osp_order_line_id IN NUMBER) IS
SELECT ospl.inventory_item_id,
       ospl.inventory_org_id,
       ospl.serial_number,
       ospl.oe_ship_line_id,
       nvl(oesh.shipped_quantity,0) shipped_quantity,
       ospl.oe_return_line_id,
       nvl(oert.shipped_quantity,0) returned_quantity,
       ospl.status_code osp_line_status_code,
       osph.status_code osp_header_status_code,
       osph.order_type_code
  FROM ahl_osp_order_lines ospl,
       ahl_osp_orders_b osph,
       oe_order_lines_all oesh,
       oe_order_lines_all oert
 WHERE ospl.osp_order_line_id = c_osp_order_line_id
   AND ospl.osp_order_id = osph.osp_order_id
   AND ospl.oe_ship_line_id = oesh.line_id(+)
   AND ospl.oe_return_line_id = oert.line_id(+);

 L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Is_part_chg_valid_for_ospline';
 l_get_order_details get_order_details%ROWTYPE;
 l_serial_number_control_code mtl_system_items_b.serial_number_control_code%TYPE;
 l_comms_nl_trackable_flag mtl_system_items_b.comms_nl_trackable_flag%TYPE;
 l_serial_status NUMBER;
 l_instance_id NUMBER;
 l_dummy NUMBER;
 l_ship_line_instance get_ship_line_instance%ROWTYPE;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Function');
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'p_osp_order_line_id: '||p_osp_order_line_id);
  END IF;

  --Retrieve the shipment line information. If data is not retrieved, then the osp_order_line_id is invalid.
  OPEN get_order_details(p_osp_order_line_id);
  FETCH get_order_details INTO l_get_order_details;
  IF (get_order_details%NOTFOUND) THEN
    CLOSE get_order_details;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Invalid Order Line, Failed to retrieve order line/shipment information');
    END IF;
    return 'N';
  END IF;
  CLOSE get_order_details;

  /*
  Check that the Order Type is Service and the status of the order is not 'CLOSED' and the status of the order line is not populated, which would mean that the related purchase line details have been cancelled or deleted.
  */
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'order_type_code -> ' ||l_get_order_details.order_type_code ||
    'osp_header_status_code -> ' ||l_get_order_details.osp_header_status_code ||
    'osp_line_status_code -> ' ||l_get_order_details.osp_line_status_code);
  END IF;

  IF(l_get_order_details.order_type_code <> AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE OR
     l_get_order_details.osp_header_status_code = AHL_OSP_ORDERS_PVT.G_OSP_CLOSED_STATUS OR
     l_get_order_details.osp_line_status_code is not NULL) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Invalid Osp Order Type or Status');
    END IF;
    return 'N';
  END IF;

  /*
  Check that the onward shipment line is 'Shipped'. Note that if the line is cancelled, we do not want to allow the part number
  change for this order line.
  Return 'N' if, the quantity is not shipped yet.
  */
  IF(l_get_order_details.oe_ship_line_id is NULL OR l_get_order_details.shipped_quantity = 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Ship Line not present or is not valid to allow Part Number Change: '||
        ' oe_ship_line_id ->' ||l_get_order_details.oe_ship_line_id ||
        ' shipped_quantity ->' ||l_get_order_details.shipped_quantity) ;
      END IF;
      return 'N';
  END IF;

  /*
  Check that the return shipment line is 'Open'. Note that if the line is cancelled, we will allow the Part Number change.
  Return 'N' if the return line is already shipped.
  */
  IF(l_get_order_details.oe_return_line_id is NOT NULL AND l_get_order_details.returned_quantity > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return Line already shipped'||
        ' oe_return_line_id ->' ||l_get_order_details.oe_return_line_id ||
        ' returned_quantity ->' ||l_get_order_details.returned_quantity ) ;
      END IF;
      return 'N';
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Item Details as present on the osp order line: '||
    ' inventory_item_id ->' ||l_get_order_details.inventory_item_id ||
    ' inventory_org_id ->' ||l_get_order_details.inventory_org_id ||
    ' serial_number ->' ||l_get_order_details.serial_number) ;
  END IF;

  /*
  Get the instance_id corresponding to the osp_order_line_id.
  We are assuming that this instance_id details are not manually updated/deleted by the user from
	OM forms or elsewhere. If the item is IB tracked, at the time of ship line creation, we create the IB installation
	details as well. Since the item and serial on the osp order line can undergo multiple part number/serial number changes,
	and we are not storing the instance information we are retrieving it from IB transactions.
	We need this instance to be present, otherwise we will not be able to pass the same to the PartNumber/Serial Number
	change UI. If there is an issue with this approach, we may need to retrieve the instance details from
	the history/consider storing the instance_id in the ahl_osp_order_lines table.
  */
  OPEN get_ship_line_instance(p_osp_order_line_id);
  FETCH get_ship_line_instance INTO l_ship_line_instance;
  IF (get_ship_line_instance%NOTFOUND) THEN
    CLOSE get_ship_line_instance;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Failed to find instance details for the ship line');
    END IF;
    return 'N';
  END IF;
  CLOSE get_ship_line_instance;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Shipped instance attributes : '||
    ' inventory_item_id ->' ||l_ship_line_instance.inventory_item_id ||
    ' last_vld_organization_id ->' || l_ship_line_instance.last_vld_organization_id) ;
  END IF;

  --Retrieve the item information corresponding to item. The IB tracked checks may be redundant as, if get_ship_line_instance
  --has an instance, it will surely be IB tracked
  OPEN get_inventory_flags(l_ship_line_instance.inventory_item_id,l_ship_line_instance.last_vld_organization_id );
  FETCH get_inventory_flags INTO l_serial_number_control_code, l_comms_nl_trackable_flag;
  IF (get_inventory_flags%NOTFOUND) THEN
    CLOSE get_inventory_flags;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Invalid Item, Failed to retrieve item information');
    END IF;
    return 'N';
  END IF;
  CLOSE get_inventory_flags;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'osp order line: Item Number flags : '||
    ' l_serial_number_control_code ->' || l_serial_number_control_code ||
    ' l_comms_nl_trackable_flag ->' || l_comms_nl_trackable_flag) ;
  END IF;

  --Item has to serial controlled and IB trackable
  IF (l_serial_number_control_code NOT IN (2,5,6) OR nvl(l_comms_nl_trackable_flag,'N') <> 'Y') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Invalid Item: Has to be serial controlled and IB trackable');
    END IF;
    return 'N';
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returning Y');
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Function');
  END IF;

  return 'Y';

END;

-------------------------------------------------------------
-- Start of Comments --
--  Procedure name    :
--  Type              : Public
--  Function          : API to delete or cancel OSP shipment return lines and/or the IB installation
--                      details before the part number/serial number change is performed from production
--
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--  Standard OUT Parameters :
--      x_return_status                 OUT NOCOPY     VARCHAR2             Required
--      x_msg_count                     OUT NOCOPY     NUMBER               Required
--      x_msg_data                      OUT NOCOPY     VARCHAR2             Required
--
--  Cancel_retline_For_PartNum_Chg Parameters:
--       p_osp_order_line_id          IN NUMBER
--         The osp_line_id for of OSP Order for which the part number/serial number change
--       p_inv_item_id                IN NUMBER
--         The inv_item_id chosen by the user to replace the existint item.
--       p_serial_number              IN VARCHAR2
--         The serial_number chosen by the user to replace the existint serial.
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.

PROCEDURE Process_Osp_SerialNum_Change(
    p_api_version           IN        NUMBER    := 1.0,
    p_init_msg_list         IN        VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN        VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN        NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN        VARCHAR2  := NULL,
    p_serialnum_change_rec  IN        Sernum_Change_Rec_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
    ) IS

    CURSOR get_osp_order_line_dtls(c_osp_order_line_id IN NUMBER) IS
    SELECT ospl.inventory_item_id,
           ospl.serial_number,
           ospl.inventory_org_id,
           ospl.oe_ship_line_id,
           ospl.oe_return_line_id,
           retl.ship_from_org_id receiving_org_id,
           ospl.osp_order_id
      FROM ahl_osp_order_lines ospl,
           oe_order_lines_all retl
     WHERE osp_order_line_id = c_osp_order_line_id
       AND ospl.oe_return_line_id = retl.line_id(+);

    CURSOR get_ship_line_instance(c_osp_order_line_id IN NUMBER) IS
    SELECT tld.instance_id
      FROM csi_t_transaction_lines tl,
           csi_t_txn_line_details tld,
           ahl_osp_order_lines ospl
     WHERE tl.source_transaction_id = ospl.oe_ship_line_id
       AND tl.source_transaction_table = G_TRANSACTION_TABLE
       AND tl.transaction_line_id = tld.transaction_line_id
       AND ospl.osp_order_line_id = c_osp_order_line_id;

   -- Get the current record from csi item instances
   CURSOR get_instance_details (c_instance_id IN NUMBER) IS
   SELECT instance_number,
          instance_id,
          object_version_number,
          inventory_item_id,
          serial_number,
          lot_number,
          inventory_revision
     FROM csi_item_instances
    WHERE instance_id = c_instance_id;

    CURSOR get_item_information(c_inv_item_id IN NUMBER, c_inv_org_id IN NUMBER) IS
    SELECT serial_number_control_code,
           comms_nl_trackable_flag
      FROM mtl_system_items_b
     WHERE inventory_item_id = c_inv_item_id
       AND organization_id = c_inv_org_id;

    CURSOR ahl_oe_lot_serial_id (p_oe_line_id IN NUMBER) IS
      SELECT lot_serial_id
       FROM oe_lot_serial_numbers
      WHERE line_id = p_oe_line_id;

    CURSOR get_same_phyitem_order_lines(c_osp_order_line_id IN NUMBER) IS
    SELECT matched_ol.osp_order_line_id
      FROM ahl_osp_order_lines matched_ol,
           ahl_osp_order_lines passed_ol
     WHERE passed_ol.osp_order_line_id = c_osp_order_line_id
       AND passed_ol.inventory_item_id = matched_ol.inventory_item_id
       AND passed_ol.serial_number = matched_ol.serial_number
       -- Added by jaramana on 12-APR-2010 for bug 9229301
       -- Check only within the current OSP Order
       AND passed_ol.osp_order_id = matched_ol.osp_order_id;

    CURSOR mtl_system_items_csr(c_inventory_id IN NUMBER, c_organization_id IN  NUMBER) IS
    SELECT serial_number_control_code,
           lot_control_code,
           comms_nl_trackable_flag,
           concatenated_segments
      FROM mtl_system_items_vl
     WHERE inventory_item_id   = c_inventory_id
       AND organization_id = c_organization_id;

    CURSOR c_get_inv_item_id(c_item_number VARCHAR2)IS
    SELECT inventory_item_id
      FROM MTL_SYSTEM_ITEMS_KFV
     WHERE CONCATENATED_SEGMENTS = c_item_number;

    l_api_name       CONSTANT VARCHAR2(30)  := 'Process_Osp_SerialNum_Change';
    l_api_version    CONSTANT NUMBER        := 1.0;
    L_DEBUG_KEY      CONSTANT VARCHAR2(150) := G_LOG_PREFIX || '.Process_Osp_SerialNum_Change';

    l_msg_data              VARCHAR2(2000);
    l_msg_index_out         NUMBER;
    l_index                 NUMBER;
    l_osp_order_line_dtls   get_osp_order_line_dtls%ROWTYPE;
    l_instance_dtls_rec     get_instance_details%ROWTYPE;
    l_mtl_system_items_rec  mtl_system_items_csr%ROWTYPE;
    l_lookup_code            fnd_lookups.lookup_code%TYPE;
    l_organization_id        NUMBER;
    l_ship_line_instance_id  NUMBER;
    l_del_oe_lines_tbl      SHIP_ID_TBL_TYPE;
    l_lot_serial_id         NUMBER;

    l_oe_line_rec           OE_ORDER_PUB.line_rec_type;
    l_oe_lot_serial_rec     OE_ORDER_PUB.lot_serial_rec_type;
    l_oe_line_tbl           OE_ORDER_PUB.LINE_TBL_TYPE;
    l_oe_lot_serial_tbl     OE_ORDER_PUB.LOT_SERIAL_TBL_TYPE;
    l_part_num_changed      VARCHAR2(1) := 'N';
    l_serial_num_changed    VARCHAR2(1) := 'N';
    l_order_line_id         NUMBER;
    l_serialnum_change_rec  Sernum_Change_Rec_Type := p_serialnum_change_rec;
    l_inventory_item_id     NUMBER;

    --Variables for Updating the CSI Instance Start
    l_return_val                BOOLEAN;
    l_attribute_value_id        NUMBER;
    l_object_version_number     NUMBER;
    l_attribute_value           csi_iea_values.attribute_value%TYPE;
    l_attribute_id              NUMBER;
    l_idx                       NUMBER := 0;
    l_serial_tag_code           csi_iea_values.attribute_value%TYPE;
    l_serial_tag_rec_found      VARCHAR2(1) DEFAULT 'Y';
    l_transaction_type_id       NUMBER;

    l_csi_instance_id_lst       CSI_DATASTRUCTURES_PUB.Id_Tbl;

    l_csi_instance_rec          csi_datastructures_pub.instance_rec;
    l_csi_party_rec             csi_datastructures_pub.party_rec;
    l_csi_transaction_rec       csi_datastructures_pub.transaction_rec;
    l_csi_extend_attrib_rec     csi_datastructures_pub.extend_attrib_values_rec;
    l_csi_relationship_rec      csi_datastructures_pub.ii_relationship_rec;

    l_csi_ext_attrib_values_tbl csi_datastructures_pub.extend_attrib_values_tbl;
    l_csi_party_tbl             csi_datastructures_pub.party_tbl;
    l_csi_account_tbl           csi_datastructures_pub.party_account_tbl;
    l_csi_pricing_attrib_tbl    csi_datastructures_pub.pricing_attribs_tbl;
    l_csi_org_assignments_tbl   csi_datastructures_pub.organization_units_tbl;
    l_csi_asset_assignment_tbl  csi_datastructures_pub.instance_asset_tbl;
    l_csi_relationship_tbl      csi_datastructures_pub.ii_relationship_tbl;
    l_csi_extend_attrib_rec1     csi_datastructures_pub.extend_attrib_values_rec;
    l_csi_ext_attrib_values_tbl1 csi_datastructures_pub.extend_attrib_values_tbl;
    l_idx1                       NUMBER := 0;
    --Variables for Updating the CSI Instance End

BEGIN

  -- Standard start of API savepoint
  SAVEPOINT Process_Osp_SerialNum_Change;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_oe_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
  l_oe_lot_serial_tbl := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL;


  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Entering Procedure');
  END IF;

  --Dump the input parameters
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY,'p_serialnum_change_rec.osp_line_id -> '||p_serialnum_change_rec.osp_line_id);
    fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY,'p_serialnum_change_rec.instance_id -> '||p_serialnum_change_rec.instance_id);
    fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY,'p_serialnum_change_rec.new_item_number -> '||p_serialnum_change_rec.new_item_number);
    fnd_log.string(fnd_log.level_statement, L_DEBUG_KEY,'p_serialnum_change_rec.new_serial_number -> '||p_serialnum_change_rec.new_serial_number);
  END IF;

  --osp_order_line_id should not be null
  IF(p_serialnum_change_rec.osp_line_id is NULL) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CHG_OSPLID_NLL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --validate the osp_order_line_id
  OPEN get_osp_order_line_dtls(l_serialnum_change_rec.osp_line_id);
  FETCH get_osp_order_line_dtls INTO l_osp_order_line_dtls;
  IF (get_osp_order_line_dtls%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_INVOP_OSP_LN_NFOUND');
    FND_MSG_PUB.ADD;
    CLOSE get_osp_order_line_dtls;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_osp_order_line_dtls;

  --check that the osp line is valid for the part number change
  IF(Is_part_chg_valid_for_ospline(p_serialnum_change_rec.osp_line_id) = 'N') THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CHG_OSPL_INV');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Validate the passed new_item_number
  IF (l_serialnum_change_rec.new_item_number IS NOT NULL and l_serialnum_change_rec.new_item_number <> FND_API.G_MISS_CHAR) THEN
    -- Retrieve inventory_item_id from item_number
    OPEN c_get_inv_item_id(l_serialnum_change_rec.new_item_number);
    FETCH c_get_inv_item_id INTO l_inventory_item_id;
    CLOSE c_get_inv_item_id;
    IF l_inventory_item_id IS NULL THEN
      FND_MESSAGE.Set_Name('AHL','AHL_OSP_ITEM_INVALID');
      FND_MESSAGE.Set_token('ITEM',l_serialnum_change_rec.new_item_number);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.Set_Name('AHL','AHL_OSP_INV_ITEM_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  /*
  Get the instance present at the ship line
  We are assuming that this instance_id details are not manually updated/deleted by the user from
  OM forms or elsewhere. If the item is IB tracked, at the time of ship line creation, we create the IB installation
  details as well. Since the item and serial on the osp order line can undergo multiple part number/serial number changes,
  and we are not storing the instance information we are retrieving it from IB transactions.
  We need this instance to be present, otherwise we will not be able to pass the same to the PartNumber/Serial Number
  change UI. If there is an issue with this approach, we may need to retrieve the instance details from
  the history/consider storing the instance_id in the ahl_osp_order_lines table.
  */

  --If passed instance_id is null, derive it from the osp line, else check that its the one present on the osp line.
  OPEN get_ship_line_instance(l_serialnum_change_rec.osp_line_id);
  FETCH get_ship_line_instance INTO l_ship_line_instance_id;
  IF (get_ship_line_instance%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_SHIPLINE_NO_INST');
    FND_MSG_PUB.ADD;
    CLOSE get_ship_line_instance;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_ship_line_instance;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_ship_line_instance_id =>' ||l_ship_line_instance_id);
  END IF;
  IF (l_serialnum_change_rec.instance_id is NULL) THEN
    l_serialnum_change_rec.instance_id := l_ship_line_instance_id;
  ELSE
    IF(l_serialnum_change_rec.instance_id <> l_ship_line_instance_id) THEN
      FND_MESSAGE.Set_Name('AHL','AHL_INVALID_INSTANCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -------------------------------------------------------------------------------------
  -- retrieve all instance related details and performe related validations
  -------------------------------------------------------------------------------------
  -- retrieve old instance details
  OPEN get_instance_details(l_serialnum_change_rec.instance_id);
  FETCH get_instance_details INTO l_instance_dtls_rec;
  CLOSE get_instance_details;
  IF l_instance_dtls_rec.instance_id IS NULL THEN
    FND_MESSAGE.Set_Name('AHL','AHL_INVALID_INSTANCE');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.inventory_item_id =>' ||l_instance_dtls_rec.inventory_item_id);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.serial_number =>' ||l_instance_dtls_rec.serial_number);
  END IF;

  /*
  --If the l_new_inventory_item_id is null, it means that we are using the older part number itself and new serial number.
  l_inventory_item_id := NVL(l_new_inventory_item_id,l_instance_dtls_rec.inventory_item_id);
  */

  /*
  validate the passed item against the receiving organization, if the return line is present, otherwise
  validate it against the inventory org of the osp order line.
  */
  IF(l_osp_order_line_dtls.oe_return_line_id is not null AND l_osp_order_line_dtls.receiving_org_id is not NULL) THEN
    l_organization_id := l_osp_order_line_dtls.receiving_org_id;
  ELSE
    l_organization_id := l_osp_order_line_dtls.inventory_org_id;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_organization_id =>' ||l_organization_id);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'oe_return_line_id =>' ||l_osp_order_line_dtls.oe_return_line_id);
  END IF;

  --------------------------------------------
  -- Convert meaning to lookup code
  -- For Serialnum_tag_code.
  --------------------------------------------
  IF (l_serialnum_change_rec.New_Serial_Tag_Code IS NULL) OR (l_serialnum_change_rec.New_Serial_Tag_Code = FND_API.G_MISS_CHAR)
  THEN
    -- Check if meaning exists.
    IF (l_serialnum_change_rec.New_Serial_Tag_Mean IS NOT NULL) AND (l_serialnum_change_rec.New_Serial_Tag_Mean <> FND_API.G_MISS_CHAR)
    THEN
    Convert_To_LookupCode('AHL_SERIALNUMBER_TAG',
          l_serialnum_change_rec.New_Serial_Tag_Mean,
          l_lookup_code,
          l_return_val);
      IF NOT(l_return_val) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_PRD_TAGMEANING_INVALID');
        FND_MESSAGE.Set_Token('TAG',l_serialnum_change_rec.New_Serial_Tag_Mean);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        l_serialnum_change_rec.New_Serial_Tag_Code := l_lookup_code;
      END IF;
    END IF;
  END IF;

  --get the item information
  OPEN mtl_system_items_csr(l_inventory_item_id, l_organization_id);
  FETCH mtl_system_items_csr INTO l_mtl_system_items_rec;
  IF (mtl_system_items_csr%NOTFOUND) THEN
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_ITEM_INVALID');
    FND_MESSAGE.Set_token('ITEM',l_inventory_item_id);
    FND_MSG_PUB.ADD;
    CLOSE mtl_system_items_csr;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE mtl_system_items_csr;

  --Item has to serial controlled and IB trackable
  IF (l_mtl_system_items_rec.serial_number_control_code NOT IN (2,5,6) OR nvl(l_mtl_system_items_rec.comms_nl_trackable_flag,'N') <> 'Y') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Invalid Item: Has to be serial controlled and IB trackable '||
      ' l_serial_number_control_code =>' || l_mtl_system_items_rec.serial_number_control_code || 'l_comms_nl_trackable_flag =>'||l_mtl_system_items_rec.comms_nl_trackable_flag );
    END IF;
    FND_MESSAGE.Set_Name(G_APP_NAME,'AHL_OSP_CHG_ITEM_SER_TR');
    FND_MESSAGE.Set_token('ITEM',l_mtl_system_items_rec.concatenated_segments);
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  ------------------------------------------------------
  -- Call local procedure to validate the serial number
  ------------------------------------------------------
  Validate_SerialNumber(l_inventory_item_id,l_serialnum_change_rec.new_serial_number,
                        l_mtl_system_items_rec.serial_number_control_code,
                        l_serialnum_change_rec.New_Serial_Tag_Code,
                        l_mtl_system_items_rec.concatenated_segments);

  IF FND_MSG_PUB.count_msg > 0 THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Error Count after calling Validate_SerialNumber: '||FND_MSG_PUB.count_msg);
    END IF;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  -- Retrieve existing value of serialNum_Tag_Code if present.
  AHL_UTIL_UC_PKG.GetCSI_Attribute_Value (l_serialnum_change_rec.instance_id,
                          'AHL_TEMP_SERIAL_NUM',
                          l_attribute_value,
                          l_attribute_value_id,
                          l_object_version_number,
                          l_return_val);

  IF NOT(l_return_val) THEN
    l_serial_tag_code := null;
    l_serial_tag_rec_found := 'N';
  ELSE
    l_serial_tag_code := l_attribute_value;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serial_tag_code =>'||l_serial_tag_code);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serial_tag_rec_found =>'||l_serial_tag_rec_found);
  END IF;

  -----------------------------------------------------------------------------------------
  -- Delete/Cancel the Return Shipment Line and/or the IB installation details
  -----------------------------------------------------------------------------------------
  --If the return line is present, then only delete the IB installation details, otherwise just update the instance details
  IF (l_osp_order_line_dtls.oe_return_line_id is not null) THEN

    --Whether its part number or serial number change, collect the lot serial record.
    OPEN ahl_oe_lot_serial_id (l_osp_order_line_dtls.oe_return_line_id);
    FETCH ahl_oe_lot_serial_id INTO l_lot_serial_id;
    IF (ahl_oe_lot_serial_id%FOUND) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_lot_serial_id=>'||l_lot_serial_id);
      END IF;
      OE_LOT_SERIAL_UTIL.Query_Row(p_lot_serial_id => l_lot_serial_id, x_lot_serial_rec =>l_oe_lot_serial_rec);
    END IF;
    -- Missed CLOSE statement added by jaramana on 12-APR-2010
    CLOSE ahl_oe_lot_serial_id;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.inventory_item_id =>'||l_instance_dtls_rec.inventory_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.inventory_item_id =>'||l_instance_dtls_rec.inventory_item_id);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.serial_number =>'||l_instance_dtls_rec.serial_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serialnum_change_rec.new_serial_number =>'||l_serialnum_change_rec.new_serial_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.lot_number =>'||l_instance_dtls_rec.lot_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serialnum_change_rec.new_lot_number =>'||l_serialnum_change_rec.new_lot_number);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_instance_dtls_rec.inventory_revision =>'||l_instance_dtls_rec.inventory_revision);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serialnum_change_rec.new_item_rev_number =>'||l_serialnum_change_rec.new_item_rev_number);
    END IF;

    --If it is only a serial number change, just delete the IB transation.
    IF(l_instance_dtls_rec.inventory_item_id = l_inventory_item_id) THEN
      IF((l_instance_dtls_rec.serial_number <> l_serialnum_change_rec.new_serial_number) OR
         (nvl(l_instance_dtls_rec.inventory_revision,FND_API.G_MISS_CHAR) <>
          nvl(l_serialnum_change_rec.new_item_rev_number,FND_API.G_MISS_CHAR)) OR
         (nvl(l_instance_dtls_rec.lot_number,FND_API.G_MISS_CHAR) <>
          nvl(l_serialnum_change_rec.new_lot_number,FND_API.G_MISS_CHAR)))

         THEN --Serial Number/Item Revision/Lot Number Changed
        l_serial_num_changed := 'Y';
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Serial Number has been Changed');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calling Delete_IB_Transaction' );
        END IF;
        Delete_IB_Transaction(
          p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => p_validation_level,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_oe_line_id            => l_osp_order_line_dtls.oe_return_line_id);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'After calling Delete_IB_Transaction: x_return_status =>'||x_return_status );
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSE --Item Number is same and Serial Number are same, rest of the item attributes are same.
        --If the serial tag code is also the same, there is no need to proceed further. Ideally we may also
        --consider making this change in the factory
        IF((l_serial_tag_rec_found = 'Y') AND
          ((l_serialnum_change_rec.New_Serial_Tag_Code IS NULL AND l_serial_tag_code IS NULL) OR
          (l_serial_tag_code IS NOT NULL AND l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL AND
           l_serial_tag_code = l_serialnum_change_rec.New_Serial_Tag_Code))) THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'None of the attributes are changed. Hence Returning');
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serialnum_change_rec.New_Serial_Tag_Code =>'||l_serialnum_change_rec.New_Serial_Tag_Code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serial_tag_code =>' || l_serial_tag_code);
          END IF;
          RETURN;
        END IF;
      END IF;--IF(l_instance_dtls_rec.serial_number <> l_serialnum_change_rec.new_serial_number)
    ELSE --Items are different, need to cancel the current line.

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Item Number has been Changed');
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call Delete_Cancel_Order');
      END IF;
      l_part_num_changed := 'Y';

      --Save the OE Return Line information, before deletion
      l_oe_line_rec := OE_LINE_UTIL.QUERY_ROW(p_line_id => l_osp_order_line_dtls.oe_return_line_id);
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Queried the OM Line Record');
      END IF;

      l_del_oe_lines_tbl(1) := l_osp_order_line_dtls.oe_return_line_id;
      Delete_Cancel_Order (
            p_api_version              => 1.0,
            p_init_msg_list            => FND_API.G_FALSE, -- Don't initialize the Message List
            p_commit                   => FND_API.G_FALSE, -- Don't commit independently
            p_oe_header_id             => null,  -- Not deleting the shipment header: Only the lines
            p_oe_lines_tbl             => l_del_oe_lines_tbl,  -- Lines to be deleted/Cancelled
            p_cancel_flag              => FND_API.G_FALSE,  -- Do Deletes if possible, Cancels if not
            x_return_status            => x_return_status ,
            x_msg_count                => x_msg_count ,
            x_msg_data                 => x_msg_data
        );
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Returned from Delete_Cancel_Order, x_return_status = ' || x_return_status);
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF; --IF(l_instance_dtls_rec.inventory_item_id = l_inventory_item_id)
  END IF; --IF (l_osp_order_line_dtls.oe_return_line_id is not null) THEN


  -----------------------------------------------------------------------------------------
  -- Update the Part Number/Serial Number using IB apis -- Start
  -----------------------------------------------------------------------------------------

-- Build extended attribute record for serialnum_tag_code.

  IF (l_serial_tag_rec_found = 'Y' ) THEN
    IF(l_serialnum_change_rec.New_Serial_Tag_Code IS NULL AND l_serial_tag_code IS NOT NULL) OR
      (l_serial_tag_code IS NULL AND l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL) OR
      (l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL AND l_Serial_tag_code IS NOT NULL AND
       l_serialnum_change_rec.New_Serial_Tag_Code <> FND_API.G_MISS_CHAR AND
       l_serialnum_change_rec.New_Serial_Tag_Code <> l_Serial_tag_code) THEN

      -- changed value. update attribute record.
      l_csi_extend_attrib_rec.attribute_value_id := l_attribute_value_id;
      l_csi_extend_attrib_rec.attribute_value    := l_serialnum_change_rec.New_Serial_Tag_Code;
      l_csi_extend_attrib_rec.object_version_number := l_object_version_number;
      l_idx := l_idx + 1;
      l_csi_ext_attrib_values_tbl(l_idx) := l_csi_extend_attrib_rec;
    END IF;
  ELSIF (l_serial_tag_rec_found = 'N' ) THEN
     IF (l_serialnum_change_rec.New_Serial_Tag_Code IS NOT NULL) THEN
         -- create extended attributes.
         AHL_UTIL_UC_PKG.GetCSI_Attribute_ID('AHL_TEMP_SERIAL_NUM',l_attribute_id, l_return_val);
         IF NOT(l_return_val) THEN
            FND_MESSAGE.Set_Name('AHL','AHL_ATTRIB_CODE_MISSING');
            FND_MESSAGE.Set_Token('CODE', 'AHL_TEMP_SERIAL_NUM');
            FND_MSG_PUB.ADD;
         ELSE
            l_csi_extend_attrib_rec1.attribute_id := l_attribute_id;
            l_csi_extend_attrib_rec1.attribute_value := l_serialnum_change_rec.New_Serial_Tag_Code;
            l_csi_extend_attrib_rec1.instance_id := l_serialnum_change_rec.instance_id;
            l_idx1 := l_idx1 + 1;
            l_csi_ext_attrib_values_tbl1(l_idx1) := l_csi_extend_attrib_rec1;
         END IF;
     END IF;
  END IF;

  -- Populate rest of the attributes needed.
  l_csi_instance_rec.instance_id := l_serialnum_change_rec.instance_id;
  l_csi_instance_rec.object_version_number := l_instance_dtls_rec.object_version_number;
  l_csi_instance_rec.serial_number := l_serialnum_change_rec.new_serial_number;
  l_csi_instance_rec.inventory_item_id := l_inventory_item_id;
  l_csi_instance_rec.inventory_revision := l_serialnum_change_rec.new_item_rev_number;
  l_csi_instance_rec.lot_number := l_serialnum_change_rec.new_lot_number;

  -- Per IB team, this flag should always to 'N'.
  l_csi_instance_rec.mfg_serial_number_flag := 'N';
  -- csi transaction record.
  l_csi_transaction_rec.source_transaction_date := sysdate;

  -- get transaction_type_id .
  -- Balaji modified the transaction id type to 205--ITEM_SERIAL_CHANGE
  AHL_UTIL_UC_PKG.GetCSI_Transaction_ID('ITEM_SERIAL_CHANGE',l_transaction_type_id, l_return_val);
  IF NOT(l_return_val) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_csi_transaction_rec.transaction_type_id := l_transaction_type_id;
  l_csi_transaction_rec.source_line_ref := G_CSI_T_SOURCE_LINE_REF;
  l_csi_transaction_rec.source_line_ref_id := l_serialnum_change_rec.osp_line_id;


  -------------------------------------------------------------
  -- Call IB API for making item/serial change for the instance.
  -------------------------------------------------------------
  CSI_Item_Instance_PUB.Update_Item_Instance(
           p_api_version            => 1.0,
           p_instance_rec           => l_csi_instance_rec,
           p_txn_rec                => l_csi_transaction_rec,
           p_ext_attrib_values_tbl  => l_csi_ext_attrib_values_tbl,
           p_party_tbl              => l_csi_party_tbl,
           p_account_tbl            => l_csi_account_tbl,
           p_pricing_attrib_tbl     => l_csi_pricing_attrib_tbl,
           p_org_assignments_tbl    => l_csi_org_assignments_tbl,
           p_asset_assignment_tbl   => l_csi_asset_assignment_tbl,
           x_instance_id_lst        => l_csi_instance_id_lst,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data );

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -------------------------------------------------------------
  -- for extended attributes.
  -------------------------------------------------------------
  IF (l_idx1 > 0) THEN
     -- Call API to create extended attributes.
     CSI_Item_Instance_PUB.Create_Extended_attrib_values(
             p_api_version            => 1.0,
             p_txn_rec                => l_csi_transaction_rec,
             p_ext_attrib_tbl         => l_csi_ext_attrib_values_tbl1,
             x_return_status          => x_return_status,
             x_msg_count              => x_msg_count,
             x_msg_data               => x_msg_data );

     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  -----------------------------------------------------------------------------------------
  -- Update the Part Number/Serial Number using IB apis -- End
  -----------------------------------------------------------------------------------------

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_part_num_changed =>' ||l_part_num_changed);
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_serial_num_changed =>' ||l_serial_num_changed);
  END IF;

  ----------------------------------------------------------------------------------------------
  -- Create the Return Line/IB Transaction and associate the return line with the Osp Order Line
  ----------------------------------------------------------------------------------------------
  --Only when the return line was present and was deleted/cancelled by us, we need to create the details again.
  IF (l_osp_order_line_dtls.oe_return_line_id is not null) THEN
    IF(l_part_num_changed = 'Y' OR l_serial_num_changed = 'Y') THEN
      IF(l_part_num_changed = 'Y') THEN
        --Create the Return Ship Line by calling the OM API
        /*
        We are not validating the l_oe_line_tbl and the l_oe_lot_serial_tbl as they have been extracted before deletion by us.
        */
        l_oe_line_tbl(1) := l_oe_line_rec;
        l_oe_line_tbl(1).inventory_item_id := l_inventory_item_id;
        l_oe_line_tbl(1).line_id := FND_API.G_MISS_NUM;
        l_oe_line_tbl(1).line_number := FND_API.G_MISS_NUM;
        l_oe_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
        --l_oe_lot_serial_tbl(1) := l_oe_lot_serial_rec;
        --Do not use the lot serial record as is.
        l_oe_lot_serial_tbl(1).lot_serial_id := FND_API.G_MISS_NUM;
        l_oe_lot_serial_tbl(1).lot_number := l_serialnum_change_rec.new_lot_number;
        l_oe_lot_serial_tbl(1).from_serial_number := l_serialnum_change_rec.new_serial_number;
        l_oe_lot_serial_tbl(1).quantity := l_oe_lot_serial_rec.quantity;
        l_oe_lot_serial_tbl(1).line_index := 1;
        l_oe_lot_serial_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

      ELSIF (l_serial_num_changed = 'Y') THEN
        --Part Number change has not happened. Do not create a new shipment line. But only update the serial num record.
        --Just populate the lot serial record to be updated.
        /*
        Note that even though only the revision number is changed and rest of the attributes are un changed,
        we are currently going through the update of the oe_lot_serial table, though this table does not store
        the revision number, so that the logic is kept simple. The serial change page ideally is not meant for
        isolated revision number changes. We are still cateting to it, just that we will be updating the record below
        though it will effectively not have any changes.
        */
        l_oe_lot_serial_rec.from_serial_number := l_serialnum_change_rec.new_serial_number;
        l_oe_lot_serial_rec.lot_number := l_serialnum_change_rec.new_lot_number;
        l_oe_lot_serial_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
        l_oe_lot_serial_tbl(1) := l_oe_lot_serial_rec;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'About to call OE_ORDER_GRP.PROCESS_ORDER');
      END IF;

      OE_ORDER_GRP.PROCESS_ORDER(
        p_api_version_number  => 1.0,
        p_init_msg_list       => FND_API.G_TRUE,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_header_rec          => x_header_rec,
        p_header_val_rec      => x_header_val_rec,
        p_line_tbl            => l_oe_line_tbl,
        p_line_val_tbl        => x_line_val_tbl,
        p_lot_serial_tbl      => l_oe_lot_serial_tbl,
        x_header_rec          => x_header_rec,
        x_header_val_rec      => x_header_val_rec,
        x_Header_Adj_tbl       =>  x_Header_Adj_tbl,
        x_Header_Adj_val_tbl   =>  x_Header_Adj_val_tbl,
        x_Header_price_Att_tbl =>  x_Header_price_Att_tbl,
        x_Header_Adj_Att_tbl   => x_Header_Adj_Att_tbl,
        x_Header_Adj_Assoc_tbl =>  x_Header_Adj_Assoc_tbl,
        x_Header_Scredit_tbl    =>   x_Header_Scredit_tbl,
        x_Header_Scredit_val_tbl =>    x_Header_Scredit_val_tbl,
        x_line_tbl               =>     x_line_tbl      ,
        x_line_val_tbl           =>    x_line_val_tbl ,
        x_Line_Adj_tbl           =>   x_Line_Adj_tbl    ,
        x_Line_Adj_val_tbl       =>  x_Line_Adj_val_tbl,
        x_Line_price_Att_tbl     =>   x_Line_price_Att_tbl,
        x_Line_Adj_Att_tbl       =>  x_Line_Adj_Att_tbl ,
        x_Line_Adj_Assoc_tbl     =>  x_Line_Adj_Assoc_tbl,
        x_Line_Scredit_tbl       => x_Line_Scredit_tbl ,
        x_Line_Scredit_val_tbl   =>  x_Line_Scredit_val_tbl,
        x_Lot_Serial_tbl         => x_Lot_Serial_tbl  ,
        x_Lot_Serial_val_tbl     => x_Lot_Serial_val_tbl   ,
        x_action_request_tbl     => x_action_request_tbl  );

      --populate the return_line_id with the one that was created in the OM API call.
      --A new return line is created only if part number changed happened.
      IF(l_part_num_changed = 'Y') THEN
        l_osp_order_line_dtls.oe_return_line_id := x_line_tbl(1).line_id;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Completed OE_ORDER_GRP.PROCESS_ORDER, x_return_status = ' || x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_osp_order_line_dtls.oe_return_line_id = ' || l_osp_order_line_dtls.oe_return_line_id);
      END IF;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        FOR i IN 1..x_msg_count LOOP
          OE_MSG_PUB.Get(p_msg_index => i,
                         p_encoded => FND_API.G_FALSE,
                         p_data    => l_msg_data,
                         p_msg_index_out => l_msg_index_out);
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'OE_ORDER_PUB',
                                  p_procedure_name => 'processOrder',
                                  p_error_text     => substr(l_msg_data,1,240));
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'OE:Err Msg '||i||'.' || l_msg_data);
          END IF;

        END LOOP;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Before calling Create_IB_Transaction');
      END IF;

      --Whether its the part number and/or the serial number that was changed, we need to call Create_IB_Transaction
      Create_IB_Transaction(
          p_init_msg_list         => FND_API.G_FALSE, --p_init_msg_list,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => p_validation_level,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_osp_order_type        => AHL_OSP_ORDERS_PVT.G_OSP_ORDER_TYPE_SERVICE,
          p_oe_line_type          => 'RETURN',
          p_oe_line_id            => l_osp_order_line_dtls.oe_return_line_id,
          p_csi_instance_id       => l_serialnum_change_rec.instance_id);

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Return status from Create_IB_Transaction: ' || x_return_status);
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /*
      We need to update the osp_order_line with the new return_line_id, if part number change has happened.
      If multiple services are being performed on the same item, we create only one shipment/return line.
      So we need to identify all such lines and update the oe_return_line_id of all such lines.

      How do we identify such lines? They should have the same Item and Serial Number on all the order lines.
      Even if a part number change has been done before, it would have been anyway applicable to all the
      order lines. So this logic of looking at the old item/serial numbers should be sufficient to retrieve all
      the order lines having the same physical item.
      */
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'Getting order lines with same physical item for Osp Order Id: ' ||l_osp_order_line_dtls.osp_order_id);
      END IF;

      --Only if a new return line has been created, update the osp order lines with the oe_return_line_id.
      IF(l_part_num_changed = 'Y') THEN
        OPEN get_same_phyitem_order_lines(l_serialnum_change_rec.osp_line_id);
        LOOP
          FETCH get_same_phyitem_order_lines INTO l_order_line_id;
          EXIT WHEN get_same_phyitem_order_lines%NOTFOUND;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, L_DEBUG_KEY, 'l_order_line_id: ' || l_order_line_id);
          END IF;
          Update_OSP_Order_Lines(
              p_osp_order_id      => l_osp_order_line_dtls.osp_order_id,
              p_osp_line_id  => l_order_line_id,
              p_oe_ship_line_id   => FND_API.G_MISS_NUM ,
              p_oe_return_line_id => l_osp_order_line_dtls.oe_return_line_id);

        END LOOP;
        CLOSE get_same_phyitem_order_lines;
      END IF;
    END IF; --IF(l_part_num_changed = 'Y' OR l_serial_num_changed := 'Y') THEN
  END IF;--IF (l_osp_order_line_dtls.oe_return_line_id is not null) THEN

  IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
    COMMIT;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.begin', 'Exiting Procedure');
  END IF;

  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false);

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, L_DEBUG_KEY || '.end', 'Exiting Procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   Rollback to Process_Osp_SerialNum_Change;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Rollback to Process_Osp_SerialNum_Change;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                               p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Rollback to Process_Osp_SerialNum_Change;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Process_Osp_SerialNum_Change',
                               p_error_text     => SQLERRM);

    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                                p_encoded => fnd_api.g_false);


END Process_Osp_SerialNum_Change;
END AHL_OSP_SHIPMENT_PUB;

/
