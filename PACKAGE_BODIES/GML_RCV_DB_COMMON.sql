--------------------------------------------------------
--  DDL for Package Body GML_RCV_DB_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RCV_DB_COMMON" AS
/* $Header: GMLRCVCB.pls 120.2 2006/03/02 10:36:40 pbamb noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

G_PKG_NAME     CONSTANT VARCHAR2(30) :='GML_RCV_DB_COMMON';
g_module_prefix  CONSTANT VARCHAR2(40) := 'gml.plsql.' || g_pkg_name || '.';

  /*##########################################################################
  #
  #  FUNCTION
  #   raise_quality_event
  #
  #  DESCRIPTION
  #
  #     This function raises the OPM Quality to create samples if and OPM item
  #	is received into a receiving location of a process org. This procedure
  # 	is called from rvtth.lpc.
  #
  #
  # MODIFICATION HISTORY
  # 31-OCT-2002  PBamb	Created
  #
  ## #######################################################################*/

PROCEDURE RAISE_QUALITY_EVENT(	x_transaction_id IN NUMBER,
				x_item_id	IN NUMBER,
				x_organization_id IN NUMBER) IS

l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
l_event_name	VARCHAR2(120);
l_event_key	VARCHAR2(240);
l_process_org	VARCHAR2(2);
l_process_qlty_flag VARCHAR2(2);

CURSOR 	cr_check_process_qlty_flag IS
 	SELECT  PROCESS_QUALITY_ENABLED_FLAG
     	FROM   	mtl_system_items_b mi
     	WHERE  	mi.inventory_item_id = x_item_id
     	AND	mi.organization_id = x_organization_id;

BEGIN
     	/*Check if the organization is process enabled */
     	BEGIN
	     	Select	process_enabled_flag
	     	Into	l_process_org
	     	From	mtl_parameters
	     	Where	organization_id = x_organization_id;

	     	EXCEPTION WHEN NO_DATA_FOUND THEN
	     	   l_process_org := 'N';
	END;


      	/*Check if the item is process quality enabled */
      	Open 	cr_check_process_qlty_flag;
      	Fetch	cr_check_process_qlty_flag into l_process_qlty_flag;
      	If	cr_check_process_qlty_flag%NOTFOUND Then
      		l_process_qlty_flag:='N';
      	End if;
      	Close cr_check_process_qlty_flag;

	IF l_process_org = 'Y' and l_process_qlty_flag= 'Y' THEN


		wf_event.AddParameterToList(	p_name=>'TRANSACTION_ID',
						p_value=> X_Transaction_id ,
						p_parameterlist=> l_parameter_list);


		l_event_name := 'oracle.apps.gml.po.receipt.created';

		l_event_key := X_Transaction_id;

		wf_event.raise(	p_event_name => l_event_name,
				p_event_key => l_event_key,
				p_parameters => l_parameter_list);
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
	      	null;


END RAISE_QUALITY_EVENT;

  /*##########################################################################
  #
  #  PROCEDURE
  #   validate_rma_lot_quantities
  #
  #  DESCRIPTION
  #
  #     This function gets input of receiving lot quantity and validates whether
  #     RMA OE line has that quantity to be received by checking the rma lot
  #     quantity and the received quantity against that lot.
  # 	Its called from ROI and RCVGMLCR.pld
  #
  #
  # MODIFICATION HISTORY
  # 16-OCT-2003  PBamb	Created
  #
  ## #######################################################################*/

Procedure VALIDATE_RMA_LOT_QUANTITIES( p_api_version   IN  NUMBER,
                                       p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                                       p_opm_item_id  IN NUMBER,
                                       p_lot_id       IN NUMBER,
                                       p_lot_no       IN VARCHAR2,
                                       p_sublot_no    IN VARCHAR2,
                                       p_oe_header_id IN NUMBER,
                                       p_oe_line_id   IN NUMBER,
                                       p_trx_qty      IN NUMBER,
                                       p_trx_uom      IN VARCHAR2,
                                       p_rma_lot_qty  IN NUMBER,
                                       p_rma_lot_uom  IN VARCHAR2,
                                       p_line_set_id  IN NUMBER,
                                       p_called_from  IN VARCHAR2 DEFAULT 'FORM',
                                       X_allowed          OUT NOCOPY VARCHAR2,
                                       X_allowed_quantity OUT NOCOPY NUMBER,
                                       x_return_status    OUT NOCOPY VARCHAR2)


IS

l_lot_recv_qty NUMBER;
l_rma_answer BOOLEAN := FALSE;

Cursor Cr_lot_recv_qty IS
Select 	Sum(trans_qty),trans_um
From    ic_tran_pnd itp,
        rcv_transactions rcv
Where   rcv.oe_order_header_id = p_oe_header_id
And     (rcv.oe_order_line_id = p_oe_line_id
         or
         rcv.oe_order_line_id in
                          (select line_id
                           from   oe_order_lines_all
                           where  header_id = p_oe_header_id
                           and    line_set_id = p_line_set_id
                           )
        )
And     rcv.shipment_header_id = itp.doc_id
And     rcv.transaction_id = itp.line_id
And     itp.doc_type = 'PORC'
And     itp.lot_id = p_lot_id
And     itp.delete_mark = 0
Group by trans_um;


l_api_name           	 CONSTANT VARCHAR2(30)   := 'Validate_Rma_Lot_Quantities' ;
l_api_version        	 CONSTANT NUMBER         := 1.0 ;
l_progress		 VARCHAR2(3) := '000';

l_trx_opm_uom SY_UOMS_MST.UM_CODE%TYPE;
l_rma_lot_opm_uom SY_UOMS_MST.UM_CODE%TYPE;
l_lot_recv_uom SY_UOMS_MST.UM_CODE%TYPE;
l_trx_opm_qty NUMBER;
l_rma_lot_opm_qty NUMBER;

l_rma_lot_uom VARCHAR2(25);
l_rma_lot_qty NUMBER;

BEGIN

--   IF (g_fnd_debug = 'Y') THEN Bug 4502018
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.string( FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name,
                    'Entering ' || l_api_name );
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (   l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME
                                     ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status :=FND_API.G_RET_STS_SUCCESS;

   --If any of these parameters are NULL nothing can be done so just
   --returns as if successful.
   IF p_opm_item_id IS NULL OR
      p_oe_header_id IS NULL OR
      p_oe_line_id IS NULL OR
      p_trx_qty IS NULL OR
      p_trx_uom IS NULL THEN

       X_allowed := 'Y';
       RETURN;
   END IF;

   l_progress := '001';

   --Fetch UOM of RMA if not passed and get the corresponding OPM UOM Code.
   --Cannot use po_gml_db_common,get_opm_uom_code because this procedure expects
   --a 25 character unit of measure and OM does not have it.OM has the 4 character
   --uom_code - so derive the corresponding opm uom code.
   IF p_rma_lot_uom IS NULL THEN

      l_progress := '002';

      /*Select ORDER_QUANTITY_UOM
      Into   l_rma_lot_uom
      From   oe_order_lines_all
      Where  header_id = p_oe_header_id
      And line_id = p_oe_line_id;
      --Get corresponding OPM UOM.
      l_rma_lot_opm_uom := PO_GML_DB_COMMON.GET_OPM_UOM_CODE(l_rma_lot_uom);
      */
      BEGIN
         Select decode(length(uom.unit_of_measure), 1, uom.unit_of_measure,
                       2, uom.unit_of_measure, 3, uom.unit_of_measure,
                       4, uom.unit_of_measure, uom.uom_code)
         Into   l_rma_lot_opm_uom
         From   oe_order_lines_all , mtl_units_of_measure uom
         Where  header_id = p_oe_header_id
         And    line_id = p_oe_line_id
         And    uom_code = ORDER_QUANTITY_UOM;

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('GMI','GMI_SQL_ERROR');
               FND_MESSAGE.SET_TOKEN('WHERE','GML_RCV_DB_COMMON.VALIDATE_RMA_LOT_QUANTITIES'||'-'||l_progress);
               FND_MESSAGE.SET_TOKEN('SQL_CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('SQL_ERRM',SQLERRM(SQLCODE));
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;


   ELSE
      l_progress := '003';
      --Get corresponding OPM UOM Code.
      --l_rma_lot_opm_uom := PO_GML_DB_COMMON.GET_OPM_UOM_CODE(p_rma_lot_uom);
      BEGIN
         Select decode(length(uom.unit_of_measure), 1, uom.unit_of_measure,
                       2, uom.unit_of_measure, 3, uom.unit_of_measure,
                       4, uom.unit_of_measure, uom.uom_code)
         Into   l_rma_lot_opm_uom
         From   mtl_units_of_measure uom
         Where  uom_code = p_rma_lot_uom;

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('GMI','GMI_SQL_ERROR');
               FND_MESSAGE.SET_TOKEN('WHERE','GML_RCV_DB_COMMON.VALIDATE_RMA_LOT_QUANTITIES'||'-'||l_progress);
               FND_MESSAGE.SET_TOKEN('SQL_CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('SQL_ERRM',SQLERRM(SQLCODE));
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   END IF;

   --Fetch QTY of the LOT in the RMA if not passed.
   IF p_rma_lot_qty IS NULL THEN
      l_progress := '004';

      BEGIN
         -- PB -- OM allows duplicate entry of lots in their lot serial form. We need to sum up the quantity
         -- since we do not allow duplicate lots on the lot serial form while receiving. So person has to
         -- receive in one lot..sum up the quantities.
         Select nvl(SUM(QUANTITY),0)
         Into   l_rma_lot_qty
         From   oe_lot_Serial_numbers
         Where  (line_id = p_oe_line_id OR line_set_id  = p_line_set_id)
         And    lot_number = p_lot_no
         And    nvl(sublot_number,' ') = nvl(p_sublot_no,' ');

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('GMI','GMI_SQL_ERROR');
               FND_MESSAGE.SET_TOKEN('WHERE','GML_RCV_DB_COMMON.VALIDATE_RMA_LOT_QUANTITIES'||'-'||l_progress);
               FND_MESSAGE.SET_TOKEN('SQL_CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('SQL_ERRM',SQLERRM(SQLCODE));
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
   ELSE
      l_rma_lot_qty := p_rma_lot_qty;

      l_progress := '005';
   END IF;

   --Get the Transaction (receipt) OPM UOM CODE.
   BEGIN
      l_trx_opm_uom := PO_GML_DB_COMMON.GET_OPM_UOM_CODE(p_trx_uom);

      EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   l_progress := '006';

   --If lot id is passed that means it was probably received before
   --or they used an existing lot.
   IF p_lot_id IS NOT NULL THEN

      l_progress := '007';

      --Get received quantity of the Lot.
      Open Cr_lot_recv_qty;
      Fetch Cr_lot_recv_qty Into l_lot_recv_qty, l_lot_recv_uom;
      Close Cr_lot_recv_qty;

      --If this lot was never received then the receiving uom will be null then fetch
      --Primary uom from the ic_item_mst.
      IF l_lot_recv_uom IS NULL THEN
         BEGIN
            Select item_um
            Into   l_lot_recv_uom
            From   ic_item_mst
            Where  item_id = p_opm_item_id;

            EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('GMI','GMI_SQL_ERROR');
               FND_MESSAGE.SET_TOKEN('WHERE','GML_RCV_DB_COMMON.VALIDATE_RMA_LOT_QUANTITIES'||'-'||l_progress);
               FND_MESSAGE.SET_TOKEN('SQL_CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('SQL_ERRM',SQLERRM(SQLCODE));
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         l_lot_recv_qty := 0;
      END IF;

      --IF receipt uom is different than primary uom then convert receipt qty to primary uom.
      IF l_trx_opm_uom <> l_lot_recv_uom THEN

         l_progress := '008';

         l_trx_opm_qty := gmicuom.uom_conversion(p_opm_item_id,
                                                 nvl(p_lot_id,0),
                                                 p_trx_qty,
                                                 l_trx_opm_uom,
                                                 l_lot_recv_uom,
                                                 0);
         IF (l_trx_opm_qty < 0) THEN
            IF (l_trx_opm_qty = -1) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
            ELSIF (l_trx_opm_qty = -3) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
            ELSIF (l_trx_opm_qty = -4) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
            ELSIF (l_trx_opm_qty = -5) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_trx_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_lot_recv_uom);
            ELSIF (l_trx_opm_qty = -6) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
            ELSIF (l_trx_opm_qty = -7) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
            ELSIF (l_trx_opm_qty = -10) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_trx_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_lot_recv_uom);
            ELSIF (l_trx_opm_qty = -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
            ELSIF (l_trx_opm_qty < -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      ELSE
         l_trx_opm_qty := p_trx_qty;

         l_progress := '009';
      END IF;

      --IF RMA uom is different than primary uom then convert RMA qty to primary uom.
      IF l_rma_lot_opm_uom <> l_lot_recv_uom THEN

         l_progress := '010';

         l_rma_lot_opm_qty := gmicuom.uom_conversion(p_opm_item_id,
                                                 nvl(p_lot_id,0),
                                                 l_rma_lot_qty,
                                                 l_rma_lot_opm_uom,
                                                 l_lot_recv_uom,
                                                 0);
         IF (l_rma_lot_opm_qty < 0) THEN
            IF (l_rma_lot_opm_qty = -1) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
            ELSIF (l_rma_lot_opm_qty = -3) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -4) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -5) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_rma_lot_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_lot_recv_uom);
            ELSIF (l_rma_lot_opm_qty = -6) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -7) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
            ELSIF (l_rma_lot_opm_qty = -10) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_rma_lot_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_lot_recv_uom);
            ELSIF (l_rma_lot_opm_qty = -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
            ELSIF (l_rma_lot_opm_qty < -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         l_rma_lot_opm_qty := l_rma_lot_qty;

         l_progress := '011';
      END IF;

      --If receipt quantity is greater than the total rma lot quantity minus the received qty for that lot then
      --pass N no the allowe flag along with the remaining qty for the lot.
      IF l_trx_opm_qty > (l_rma_lot_opm_qty - nvl(l_lot_recv_qty,0)) THEN

         X_allowed := 'N';

         IF l_trx_opm_uom <> l_lot_recv_uom THEN

            l_progress := '012';

            X_allowed_quantity := gmicuom.uom_conversion(p_opm_item_id,
                                                 nvl(p_lot_id,0),
                                                 (l_rma_lot_opm_qty - nvl(l_lot_recv_qty,0)),
                                              l_lot_recv_uom,
                                              l_trx_opm_uom,
                                              0);
         IF (X_allowed_quantity < 0) THEN
            IF (X_allowed_quantity = -1) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
            ELSIF (X_allowed_quantity = -3) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
            ELSIF (X_allowed_quantity = -4) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
            ELSIF (X_allowed_quantity = -5) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_lot_recv_uom);
              FND_MESSAGE.set_token('TOUOM',l_trx_opm_uom);
            ELSIF (X_allowed_quantity = -6) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
            ELSIF (X_allowed_quantity = -7) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
            ELSIF (X_allowed_quantity = -10) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_lot_recv_uom);
              FND_MESSAGE.set_token('TOUOM',l_trx_opm_uom);
            ELSIF (X_allowed_quantity = -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
            ELSIF (X_allowed_quantity < -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         X_allowed_quantity := (l_rma_lot_opm_qty - nvl(l_lot_recv_qty,0));

         l_progress := '013';
      END IF;
   ELSE
      X_allowed := 'Y';
   END IF;

   --Lot ID NULL means that its a new LOT and we need to check only the RMA Lot quantity
   --Since its a new Lot it was never received before.
   ELSE
      --set the receipt quantity into local variable
      l_trx_opm_qty := p_trx_qty;

      --Convert the rma lot quantity into receiving uom to compare
      --if incase the rma and receiving uoms are different.
      IF l_trx_opm_uom <> l_rma_lot_opm_uom THEN
         l_rma_lot_opm_qty := gmicuom.uom_conversion(p_opm_item_id,
                                                     0,
                                                     l_rma_lot_qty,
                                                     l_rma_lot_opm_uom,
                                                     l_trx_opm_uom,
                                                     0);
         IF (l_rma_lot_opm_qty < 0) THEN
            IF (l_rma_lot_opm_qty = -1) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_PACKAGE_ERR');
            ELSIF (l_rma_lot_opm_qty = -3) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -4) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NEWUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -5) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_rma_lot_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_trx_opm_uom);
            ELSIF (l_rma_lot_opm_qty = -6) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUMTYPE_ERR');
            ELSIF (l_rma_lot_opm_qty = -7) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_CURFACTOR_ERR');
            ELSIF (l_rma_lot_opm_qty = -10) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_INVUOMTYPE_ERR2');
              FND_MESSAGE.set_token('FROMUOM',l_rma_lot_opm_uom);
              FND_MESSAGE.set_token('TOUOM',l_trx_opm_uom);
            ELSIF (l_rma_lot_opm_qty = -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_NOITEMID_ERR');
            ELSIF (l_rma_lot_opm_qty < -11) THEN
              FND_MESSAGE.set_name('GMI', 'IC_UOMCV_FATAL_ERR');
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_progress := '014';
      ELSE
         l_rma_lot_opm_qty := l_rma_lot_qty;

         l_progress := '015';
      END IF;

      --If receipt quantity is greater than the total rma lot quantity then
      --pass N the allowed flag along with the qty for the lot in receiving UOM.
      IF l_trx_opm_qty > l_rma_lot_opm_qty  THEN
         X_allowed := 'N';

         X_allowed_quantity := l_rma_lot_opm_qty;

         l_progress := '016';
      ELSE
         X_allowed := 'Y';

         l_progress := '017';
      END IF;
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('GMI','GMI_SQL_ERROR');
       FND_MESSAGE.SET_TOKEN('WHERE','GML_RCV_DB_COMMON.VALIDATE_RMA_LOT_QUANTITIES'||'-'||l_progress);
       FND_MESSAGE.SET_TOKEN('SQL_CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('SQL_ERRM',SQLERRM(SQLCODE));
       FND_MSG_PUB.ADD;
	/* Bug 4502018 */
       -- IF (g_fnd_debug = 'Y') THEN
       if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix || l_api_name || '.' || l_progress, SQLERRM(SQLCODE));
       END IF;

END VALIDATE_RMA_LOT_QUANTITIES;

/*##########################################################################
  #
  #  PROCEDURE
  #   validate_io_lot_quantities
  #
  #  DESCRIPTION
  #
  #     For Internal Orders for process organizations
  #     In the Lot Serial form of Receipts or Receiving transactions form where we
  #	transafer to inventory (Deliver Transaction) we shall validate the lot
  #	quantity by the following formula.
  #	Available quantity  <=  Shipped Quantity- Quantity already received
  #	All the above quantities are for that combination of lot and sublot only.
  #
  #	If the validation fails then an error message is popped up saying
  #	" The quantity being delivered cannot be greater than the available
  #	quantity "and quantity field is focussed again
  #
  # MODIFICATION HISTORY
  # 15-JUN-2004  Punit Kumar 	Created
  #
  ## #######################################################################*/

Procedure VALIDATE_IO_LOT_QUANTITIES   (p_api_version   	IN  NUMBER				,
					p_init_msg_list 	IN  VARCHAR2 := FND_API.G_FALSE		,
					p_opm_item_id  		IN NUMBER				,
					p_lot_id       		IN NUMBER				,
					p_trx_qty      		IN NUMBER				,
					p_trx_uom      		IN VARCHAR2				,
					p_order_num		IN NUMBER				,
					p_req_header_id		IN NUMBER				,
					p_req_line_id		IN NUMBER				,
					p_shipment_header_id	IN NUMBER				,
					p_shipment_line_id	IN NUMBER				,
					p_req_distribution_id	IN NUMBER				,
					p_called_from  		IN VARCHAR2 DEFAULT 'FORM'		,
					X_allowed          	OUT NOCOPY VARCHAR2			,
					X_allowed_quantity 	OUT NOCOPY NUMBER			,
					x_return_status    	OUT NOCOPY VARCHAR2)
IS

l_trx_opm_uom_code  SY_UOMS_MST.UM_CODE%TYPE;
l_lot_shipped_uom   VARCHAR2(25);
l_lot_delivered_uom VARCHAR2(25);
l_lot_shipped_qty   NUMBER;
l_lot_delivered_qty NUMBER;
l_trx_qty	    NUMBER;

l_api_name           	 CONSTANT VARCHAR2(30)   := 'Validate_IO_Lot_Quantities' ;
l_api_version        	 CONSTANT NUMBER         := 1.0 ;

/*
OM may ship duplicate lots. We need to sum up the quantity
since we do not allow duplicate lots on the lot serial form while receiving. So person has to
receive in one lot..sum up the quantities.
*/

/* Selecting the shipped quantity for that Lot and Sublot */

Cursor Cr_Io_lot_shipped_qty IS
SELECT ic.trans_um ,sum(ic.trans_qty)*-1
FROM wsh_delivery_details wdd, wsh_delivery_assignments assign,ic_tran_pnd ic,
oe_order_lines_all ol
WHERE  ic.lot_id = p_lot_id
and assign.delivery_id = p_order_num
and wdd.delivery_detail_id =assign.delivery_detail_id
and wdd.delivery_detail_id = ic.line_detail_id
and wdd.source_header_id = ol.header_id
and wdd.source_line_id = ol.line_id
and ol.source_document_id =p_req_header_id
and ol.source_document_line_id = p_req_line_id
and ic.line_id = ol.line_id
and ic.doc_type ='OMSO'
and ic.delete_mark = 0
and ic.completed_ind = 1
group by ic.trans_um;


/* Selecting the quantity received for that Lot and Sublot*/

Cursor Cr_Io_delivered_quantity IS
SELECT ic.trans_um,sum(ic.trans_qty)
FROM ic_tran_pnd ic ,rcv_transactions rcv
WHERE ic.lot_id = p_lot_id and ic.doc_type ='PORC'
and ic.line_id =rcv.transaction_id
and rcv.requisition_line_id = p_req_line_id
and rcv.shipment_header_id = p_shipment_header_id
and rcv.transaction_type in ('DELIVER')
and rcv.shipment_line_id = p_shipment_line_id
and (rcv.req_distribution_id = p_req_distribution_id or rcv.req_distribution_id is null)
group by ic.trans_um ;

BEGIN
   --initialize x_allowed =
   X_allowed  := 'Y';

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (  l_api_version,
                                         p_api_version,
                                         l_api_name   ,
                                         G_PKG_NAME
                                       ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   ----If any of these parameters are NULL , nothing can be done so just
   ----returns as if successful.
   IF p_order_num 		IS NULL OR
      p_req_header_id 	        IS NULL OR
      p_req_line_id 		IS NULL OR
      p_shipment_header_id 	IS NULL OR
      p_shipment_line_id  	IS NULL OR
      p_lot_id		        IS NULL OR
      p_trx_qty 		IS NULL OR
      p_trx_uom 		IS NULL THEN

      X_allowed := 'Y';
      RETURN;
   END IF;

   --Get the Trx OPM UOM CODE.
   BEGIN
      l_trx_opm_uom_code := PO_GML_DB_COMMON.GET_OPM_UOM_CODE(p_trx_uom);

   EXCEPTION
      WHEN OTHERS THEN
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   ---Get total shipped quantity for that IO.
   Open  Cr_Io_lot_shipped_qty;
   Fetch Cr_Io_lot_shipped_qty Into l_lot_shipped_uom, l_lot_shipped_qty;
   Close Cr_Io_lot_shipped_qty;

   --Get total delivered quantity of the Lot.
   Open  Cr_Io_delivered_quantity;
   Fetch Cr_Io_delivered_quantity Into l_lot_delivered_uom, l_lot_delivered_qty;
   Close Cr_Io_delivered_quantity;

   --If this lot was never received then the delivered uom will be null
   IF l_lot_delivered_uom IS NULL THEN
      l_lot_delivered_uom := l_lot_shipped_uom;
      l_lot_delivered_qty := 0;
   END IF;

   --get lot receipt qty into a local varialbe
   l_trx_qty := p_trx_qty;

   /* If shipped uom is different than transaction uom (Receipt uom) then convert transaction
   quantity  to shipped uom */
   IF l_trx_opm_uom_code <> l_lot_shipped_uom THEN
      BEGIN
         l_trx_qty:= gmicuom.uom_conversion( p_opm_item_id,
					nvl(p_lot_id,0),
					l_trx_qty,
					l_trx_opm_uom_code,
					l_lot_shipped_uom,
		    			0);
      END;
   END IF;

   /* If transaction  quantity is greater than the total shipped lot quantity
   minus the received qty for that lot then
   pass N to the allowed flag along with the allowed qty for that lot. */

   IF l_trx_qty  > (l_lot_shipped_qty - nvl(l_lot_delivered_qty,0)) THEN
      X_allowed := 'N';
      X_allowed_quantity := l_lot_shipped_qty - nvl(l_lot_delivered_qty,0);

	IF l_trx_opm_uom_code <> l_lot_shipped_uom THEN
      		BEGIN
         		X_allowed_quantity := gmicuom.uom_conversion( p_opm_item_id,
					nvl(p_lot_id,0),
					X_allowed_quantity ,
					l_lot_shipped_uom,
					l_trx_opm_uom_code,
		    			0);
		X_allowed_quantity :=round(X_allowed_quantity ,5);
      		END;
   	END IF;
   ELSE
      X_allowed := 'Y';
      X_allowed_quantity := l_lot_shipped_qty;
   END IF;

END VALIDATE_IO_LOT_QUANTITIES;


END GML_RCV_DB_COMMON;

/
