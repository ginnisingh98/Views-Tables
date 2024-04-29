--------------------------------------------------------
--  DDL for Package Body INV_ROI_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ROI_INTEGRATION_GRP" AS
   /* $Header: INVPROIB.pls 120.4.12010000.2 2009/01/28 15:17:12 plowe ship $*/

  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N')      ;

  g_pkg_name     CONSTANT VARCHAR2(30) :='INV_ROI_INTEGRATION_GRP'            ;
  g_module_prefix  CONSTANT VARCHAR2(40) := 'inv.plsql.' || g_pkg_name || '.' ;
  l_progress		          VARCHAR2(3) := '000'                              ;


   /*##########################################################################
  #
  #  PROCEDURE :  print_debug
  #
  #
  #  DESCRIPTION  : This is a local procedure used to log errors
  #
  #
  #
  #
  # MODIFICATION HISTORY
  # 10-AUG-2004  Punit Kumar 	Created
  #
  #########################################################################*/

  PROCEDURE print_debug(
                        p_err_msg VARCHAR2         ,
                        p_level NUMBER DEFAULT 1
                        )
     IS

  BEGIN
     IF (g_debug = 1) THEN
        inv_mobile_helper_functions.tracelog(
                                             p_err_msg => p_err_msg                 ,
                                             p_module => 'INV_ROI_INTEGRATION_GRP'  ,
                                             p_level => p_level
                                             );
        DBMS_OUTPUT.PUT_LINE(p_err_msg);
     END IF;

  END print_debug;

   /*##########################################################################
  #
  #  PROCEDURE :  print_stacked_messages
  #
  #
  #  DESCRIPTION  : This is a local procedure used to log errors
  #
  #
  #
  #
  # MODIFICATION HISTORY
  # 09-SEP-2004  Punit Kumar 	Created
  #
  #########################################################################*/


  PROCEDURE print_stacked_messages IS
     l_error_message VARCHAR2(4000) := '';
  BEGIN
     inv_mobile_helper_functions.get_stacked_messages(l_error_message);
     print_debug('STACKED ERROR MESSAGES : '||l_error_message,1);
  END print_stacked_messages;


/*##########################################################################
  #
  #  PROCEDURE  INV_VALIDATE_LOT
  #
  #  DESCRIPTION :
  #
  #    Additional Validations/defaulting needs to be done on MTL_TRANSACTION_LOTS_TEMP are:
  #    Default origination type to 'Purchasing' , RMA Validations and do separate validations
  #     for new and existing lots.
  #    First the RMA set of validations will be performed so that incase of any error we need
  #     not carry out the remaining set of validations.
  #    For a new lot:
  #    If lot secondary quantity is not null then check  item level deviation.
  #    If  lot secondary quantity is null then check if item is dual uom cotrolled, if yes then
  #     default the lot secondary quantity.
  #    For an existing lot :
  #    Check lot indivisibility. (Call INV_LOT_API_PUB.validate_lot_indivisible )
  #    If lot secondary quantity is not null then check lot level deviation.
  #    If  lot secondary quantity is null then check if item is dual uom cotrolled, if yes then
  #     default the lot secondary quantity .
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  #   MODIFICATION HISTORY
  #   10-AUG-2004  Punit Kumar 	Created
  #   08-Feb-2005  Punit Kumar   Moved the lot indivisibility check to INV_LOT_API_PUB.PO_CHECK_INDIVISIBILITY.
  #
  #########################################################################*/


   PROCEDURE INV_VALIDATE_LOT(
                              x_return_status      		   OUT NOCOPY VARCHAR2              ,
                              x_msg_data           		   OUT NOCOPY VARCHAR2              ,
                              x_msg_count          		   OUT NOCOPY NUMBER                ,
                              p_api_version	 		         IN  NUMBER DEFAULT 1.0           ,
                              p_init_msg_lst	 		         IN  VARCHAR2 := FND_API.G_FALSE  ,
                              p_mtlt_rowid	 		         IN  ROWID                        ,
                              p_transaction_type_id 		   IN  VARCHAR2                     ,
                              p_new_lot			            IN  VARCHAR2                     ,
                              p_item_id	 		            IN  NUMBER                       ,
                              p_to_organization_id		      IN  NUMBER                       ,
                              p_lot_number			         IN  VARCHAR2                     ,
                              p_parent_lot_number			   IN  VARCHAR2               ,
                              p_lot_quantity			         IN  NUMBER                       ,
                              x_lot_secondary_quantity	   IN  OUT NOCOPY  NUMBER           , ----bug 4025610
                              p_line_secondary_quantity	   IN  NUMBER                       ,
                              p_secondary_unit_of_measure   IN  VARCHAR2                     ,
                              p_transaction_unit_of_measure	IN  VARCHAR2                     ,
                              p_source_document_code		   IN  VARCHAR2                     ,
                              p_OE_ORDER_HEADER_ID	         IN  NUMBER                       ,
                              p_OE_ORDER_LINE_ID	         IN  NUMBER                       ,
                              p_rti_id				            IN  NUMBER                       ,
                              p_revision             		   IN  VARCHAR2                     ,
                              p_subinventory_code    		   IN  VARCHAR2                     ,
                              p_locator_id           		   IN  NUMBER                       ,
                              p_transaction_type            IN  VARCHAR2                     ,
                              p_parent_txn_type             IN  VARCHAR2,
                              p_lot_primary_qty             IN  NUMBER -- Bug# 4233182
                              )
     IS

         l_api_name               VARCHAR2(30) := 'INV_VALIDATE_LOT'                      ;
         l_api_version            CONSTANT NUMBER := 1.0                                  ;
         l_return_status          VARCHAR2(1)                                             ;
         l_msg_data               VARCHAR2(3000)                                          ;
         l_msg_count              NUMBER                                                  ;
         l_count_lots             NUMBER                                                  ;
         l_lot_secondary_quantity NUMBER                                                  ;
         l_enforce_rma_lot_value  VARCHAR2(1)                                             ;
         v_lot_no                 VARCHAR2(80)                                            ;
         l_rma_lot_number         VARCHAR2(80)                                            ;
         l_rma_quantity           NUMBER                                                  ;
         l_deviation_check        NUMBER                                                  ;
         l_count_rma_lots         NUMBER                                                  ;
         l_allowed                VARCHAR2(1)                                             ;
         l_allowed_quantity       NUMBER                                                  ;
         v_lot_number             VARCHAR2(80)                                            ;
         l_from_unit              VARCHAR2(3)       :=NULL                                ;
         l_to_unit                VARCHAR2(3)       :=NULL                                ;
         L_TRANSACTION_TYPE       VARCHAR2(25)      :=NULL                                ;
         l_parent_txn_type        VARCHAR2(25)      :=NULL                                ;
         l_source_document_code   VARCHAR2(25)      :=NULL                                ;
         l_transaction_type_id    NUMBER            :=NULL                                ;

         /*enhancement 4018794. Punit Kumar*/
         l_lot_cont               BOOLEAN   ;
         l_child_lot_cont         BOOLEAN   ;
         /*end 4018794*/

         /*enhancement 4019704. Punit Kumar*/
         l_parent_trx_id          NUMBER              ;
         l_pmy_rcv_qty            NUMBER              ;
         l_lot_qty                NUMBER              ;
         l_pmy_unit_of_meas       VARCHAR2(100)       ;
         /*end 4019704*/

         -- Bug# 4233182
         --l_transaction_type              VARCHAR2(25);
         l_destination_type_code         VARCHAR2(25);
         l_auto_transact_code            VARCHAR2(25);
         l_parent_transaction_id         NUMBER;
         l_parent_transaction_type       VARCHAR2(25);
         l_parent_destination_type_code  VARCHAR2(25);

         -- Bug 5365360
         INVALID_ITEM          EXCEPTION;

         -- Bug 4246448 Added nvl
         CURSOR Cr_lot_exists_line(v_lot_no VARCHAR2) IS
            SELECT  NVL(SUM(QUANTITY),0)
               FROM  oe_lot_serial_numbers
               WHERE (line_id = p_oe_order_line_id
                     OR line_set_id IN
                      (SELECT line_set_id
                         FROM oe_order_lines_all
                         WHERE line_id = p_oe_order_line_id
                         AND header_id = p_oe_order_header_id))
                  AND lot_number = v_lot_no;


         /* Enhancement #4019704 Punit Kumar 02-Dec-2004
            fetching the earlier received quantity for that lot.*/
        /*
         CURSOR Cr_rcv_qty IS
            SELECT primary_quantity , primary_unit_of_measure
               FROM rcv_transactions
               WHERE transaction_id = l_parent_trx_id ;
               /*
               AND transaction_type 'DELIVER'
               AND source_document_code IN ('PO','RMA')
               AND organization_id = p_to_organization_id ;
               */

         /*end #4019704 */

  BEGIN

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       'INV_ROI_INTEGRATION_GRP'
                                       ) THEN
       IF (g_debug = 1) THEN
          print_debug('FND_API not compatible INV_ROI_INTEGRATION_GRP.INV_VALIDATE_LOT: '||l_progress, 1);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_progress := '002';

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*Defaulting of  origination type to 'Purchasing' to be done
      in INV_RCV_INTEGRATION_PVT.MOVE_LOT_SERIAL_INFO */

    ---SAVEPOINT INV_VAL_LOT1;
    l_progress := '003';

    l_lot_secondary_quantity :=x_lot_secondary_quantity ;
   /*
    IF  l_lot_secondary_quantity IS NULL THEN

       -------Checking if the item is dual UOM controlled.
       IF p_line_secondary_quantity > 0 AND p_secondary_unit_of_measure IS NOT NULL THEN
    */
          /* Check total no of lots from MTL_TRANSACTION_LOTS_TEMP against transactuion id
             and product code (RCV).IF there is only one lot for the receipt line and receipt
             line qty (p_line_quantity)  = lot qty THEN default the secondary qty from line
             to lot record. */
    /*
          BEGIN
             SELECT   count(LOT_NUMBER)
                INTO  l_count_lots
                FROM  MTL_TRANSACTION_LOTS_TEMP
                WHERE PRODUCT_TRANSACTION_ID =p_rti_id
                AND   PRODUCT_CODE = 'RCV' ;

             IF  l_count_lots = 1 THEN
                l_lot_secondary_quantity := p_line_secondary_quantity;

                UPDATE mtl_transaction_lots_temp
                   SET secondary_quantity  = l_lot_secondary_quantity
                   WHERE  rowid = p_mtlt_rowid ;

                x_lot_secondary_quantity := l_lot_secondary_quantity ;

             END IF;

             l_progress := '004';

             IF g_debug = 1 THEN
                print_debug('Checking no of lots:' || l_progress, 1);
                print_debug('no of lots and lot secondary quantity is  : ' || l_count_lots|| ' and '|| x_lot_secondary_quantity, 1);
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                IF g_debug = 1 THEN
                   print_debug('Lot count/Sec quant updation failed for single lot case: ' || l_progress, 1);
                END IF;
                RAISE g_exc_unexpected_error;
          END;


       END IF;-------IF p_line_secondary_quantity IS NOT NULL THEN
	 END IF;----------IF  l_lot_secondary_quantity IS NULL THEN
  */
--------------------------------------------RMA Section,Start---------------------------------------
    ---SAVEPOINT INV_VAL_LOT2;
    l_progress := '005';

    IF p_source_document_code = 'RMA' THEN

       IF g_debug = 1 THEN
          print_debug('RMA validation started:' || p_source_document_code, 1);
       END IF;

       -----Fetch the persmission value from rcv_parameters.
       BEGIN
          SELECT ENFORCE_RMA_LOT_NUM
             INTO l_enforce_rma_lot_value
             FROM rcv_parameters
             WHERE organization_id=p_to_organization_id;


          IF g_debug = 1 THEN
              print_debug('ENFORCE_RMA_LOT_NUM value  is  :' || l_enforce_rma_lot_value || ', ' || l_progress, 1);
          END IF;

       EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug('ENFORCE_RMA_LOT_NUM fetch failed ' || l_progress, 1);
             END IF;
             RAISE g_exc_unexpected_error;
       END;

       /* l_enforce_rma_lot_value  can be 'U' , 'R' or 'W'
       (for  unrestricted, restricted or restricted with warning respectively) */

       l_progress := '006';

       IF l_enforce_rma_lot_value IS NULL THEN
          l_enforce_rma_lot_value :='U' ;
       END IF;

             IF  l_enforce_rma_lot_value  = 'R' THEN
                /* for ROI , 'U' and 'W'  are same as we shall not insert any
                  error in po_interface_errors for 'W' (as we do not ask any question from the user) */

                /*check whether lot is specified in the RMA for that Receipt Line.. */

                IF g_debug = 1 THEN
                   print_debug('Before calling INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists:' || l_progress, 1);
                   print_debug('p_oe_order_header_id:' || p_oe_order_header_id, 1);
                   print_debug('p_oe_order_line_id:' || p_oe_order_line_id, 1);
                END IF;


                IF (INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists(
                                                                    x_msg_data               =>l_msg_data
                                                                    ,x_msg_count             =>l_msg_count
                                                                    ,x_count_rma_lots        =>l_count_rma_lots
                                                                    ,p_oe_order_header_id 	=>p_oe_order_header_id
                                                                    ,p_oe_order_line_id	   =>p_oe_order_line_id
                                                                    )) THEN

                   /* Function returns TRUE => lot is entered on RMA so it has to be validated against user entered lot */
                   v_lot_no :=p_lot_number;

                   IF g_debug = 1 THEN
                      print_debug(' INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists returns TRUE : ' || l_progress, 1);
                      print_debug('l_msg_data:' || l_msg_data, 1);
                      print_debug('l_msg_count:' || l_msg_count, 1);
                      print_debug('l_count_rma_lots:' || l_count_rma_lots, 1);
                      print_debug('p_lot_number:' || p_lot_number, 1);
                   END IF;


                   IF p_oe_order_line_id IS NOT NULL THEN
                      /* OM allows duplicate entry of lots in their lot serial form.
                        We need to sum up the quantity.
                        Also Cr_lot_exists_line validates the RMA lot against user entered lot */

                      -- Bug 4246448 pass p_lot_number instead of v_lot_number to the cursor
                      OPEN  Cr_lot_exists_line(p_lot_number);
                      FETCH Cr_lot_exists_line
                         INTO l_rma_quantity;
                      CLOSE Cr_lot_exists_line;

                      IF g_debug = 1 THEN
                         print_debug('Matching user entered lot with RMA lot :' || l_progress, 1);
                         print_debug('RMA quantity is :' || l_rma_quantity, 1);
                      END IF;

                      IF  l_rma_quantity = 0 THEN
                         IF g_debug = 1 THEN
                            print_debug('RMA lot does not match with user lot so error out' || l_progress, 4);
                         END IF;
                         FND_MESSAGE.SET_NAME('PO','PO_RMA_LOT_MISMATCH');
                         FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_ROI_INTEGRATION_GRP.Inv_Validate_lot');
                         fnd_msg_pub.ADD;
                         RAISE g_exc_error;
                      END IF;--------IF  l_rma_quantity = 0 THEN
                   ELSE  ------ IF p_oe_order_line_id IS NOT NULL THEN
                      IF g_debug = 1 THEN
                         print_debug('p_oe_order_line_id is NULL : ' || l_progress, 1);
                      END IF;
                   END IF; -------IF p_oe_order_line_id  IS NOT NULL THEN

                   /*control will come here only if RMA lot matches with user lot
                     so proceed with quantity validation.*/

                   l_progress := '006' ;

                   IF g_debug = 1 THEN
                      print_debug('Before calling INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity : ' || l_progress, 1);
                      print_debug('p_item_id: ' || p_item_id, 1);
                      print_debug('p_lot_number: ' || p_lot_number, 1);
                      print_debug('p_oe_order_header_id: ' || p_oe_order_header_id, 1);
                      print_debug('p_oe_order_line_id: ' || p_oe_order_line_id, 1);
                      print_debug('p_rma_quantity: ' || l_rma_quantity, 1);
                      print_debug('p_trx_unit_of_measure: ' || p_transaction_unit_of_measure, 1);
                      print_debug('p_rti_id: ' || p_rti_id, 1);
                      print_debug('p_to_organization_id: ' || p_to_organization_id, 1);
                   END IF;


                   INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity(
                                                                     x_allowed 		         =>l_allowed                         ,
                                                                     x_allowed_quantity 	   =>l_allowed_quantity                ,
                                                                     x_return_status         =>l_return_status                   ,
                                                                     x_msg_data           	=>l_msg_data                        ,
                                                                     x_msg_count          	=>l_msg_count	                     ,
                                                                     p_api_version			   =>1.0                               ,
                                                                     p_init_msg_list			=>FND_API.G_FALSE                   ,
                                                                     p_item_id  			      =>p_item_id	                        ,
                                                                     p_lot_number 			   =>p_lot_number		                  ,
                                                                     p_oe_order_header_id 	=>p_OE_ORDER_HEADER_ID              ,
                                                                     p_oe_order_line_id 		=>p_OE_ORDER_LINE_ID                ,
                                                                     p_rma_quantity 			=>l_rma_quantity                    ,
                                                                     p_trx_unit_of_measure	=>p_transaction_unit_of_measure     ,
                                                                     p_rti_id				      =>p_rti_id                          ,
                                                                     p_to_organization_id		=>p_to_organization_id              ,
                                                                     p_trx_quantity          =>NULL
                                                                     );

                   IF g_debug = 1 THEN
                      print_debug('Program INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity return ' || l_return_status ||'and ' || l_progress, 1);
                      print_debug('l_allowed: ' || l_allowed, 1);
                      print_debug('l_allowed_quantity: ' || l_allowed_quantity, 1);
                      print_debug('l_return_status: ' || l_return_status, 1);
                      print_debug('l_msg_data: ' || l_msg_data, 1);
                      print_debug('l_msg_count: ' || l_msg_count, 1);
                   END IF;

                   IF l_allowed = 'N' THEN
                      IF g_debug = 1 THEN
                         print_debug('Program INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity has failed
                                     as user quantity is greater than the available RMA quantity ' || l_progress, 1);
                      END IF;
                      FND_MESSAGE.SET_NAME('INV','INV_RMA_QUANTITY_VAL_FAILED');
                      FND_MESSAGE.SET_TOKEN('x_allowed_quantity',l_allowed_quantity );
                      FND_MESSAGE.SET_TOKEN('p_lot_number',p_lot_number );
                      fnd_msg_pub.ADD;
                      RAISE g_exc_error;
                   END IF;

                   l_progress := '007' ;

                   IF l_return_status = fnd_api.g_ret_sts_error THEN
                      IF g_debug = 1 THEN
                         print_debug('Program INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity has failed with a user defined exception '|| l_progress, 1);
                      END IF;
                      FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                      FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity');
                      fnd_msg_pub.ADD;
                      RAISE g_exc_error;

                   l_progress := '008' ;

                   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      IF g_debug = 1 THEN
                         print_debug('Program INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity has failed with a Unexpected exception ' || l_progress , 1);
                      END IF;
                      FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                      FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity');
                      fnd_msg_pub.ADD;
                      RAISE g_exc_unexpected_error;
                   END IF;

                   l_progress :='009';

                ELSE   --------IF (INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists(
                      /*	lot is not present on RMA so user can receive into any valid
                           lot or create new lot and no quantity validation required.
                           Take RMA validation as Success*/
                   IF g_debug = 1 THEN
                      print_debug(' INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists returns FALSE : ' || l_progress, 1);
                      print_debug('l_msg_data: ' || l_msg_data, 1);
                      print_debug('l_msg_count: ' || l_msg_count, 1);
                      print_debug('l_count_rma_lots: ' || l_count_rma_lots, 1);
                      print_debug('lot is not present on RMA so user can receive into any valid
                           lot or create new lot and no quantity validation required.
                           Take RMA validation as Success: ' || l_progress, 1);
                   END IF;

                   x_return_status := FND_API.G_RET_STS_SUCCESS;
                END IF;--------IF (INV_ROI_INTEGRATION_GRP.Inv_Rma_lot_info_exists(

             END IF;--------IF  l_enforce_rma_lot_value  = 'R' THEN

             IF g_debug = 1 THEN
                print_debug('RMA validation finished:' || l_progress, 1);
             END IF;

          END IF;--------------- IF l_source_document_code = 'RMA' THEN



----------------------END OF RMA Section-----Start Lot Validation Logic for an existing Lot-----------------------------------------------
    ---SAVEPOINT INV_VAL_LOT3;
    l_progress := '010';

    IF p_new_lot= 'N' THEN

       /*Enhancement 4018794, Punit Kumar*/

       l_lot_cont        := FALSE ;
       l_child_lot_cont  := FALSE ;


       INV_ROI_INTEGRATION_GRP.Check_Item_Attributes(
                                                     x_return_status          =>  l_return_status
                                                     , x_msg_count            =>  l_msg_count
                                                     , x_msg_data             =>  l_msg_data
                                                     , x_lot_cont             =>  l_lot_cont
                                                     , x_child_lot_cont       =>  l_child_lot_cont
                                                     , p_inventory_item_id    =>  p_item_id
                                                     , p_organization_id      =>  p_to_organization_id
                                                     );

       IF g_debug = 1 THEN
          print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes return ' || l_return_status, 9);
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_error THEN
          IF g_debug = 1 THEN
             print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with error', 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV', 'INV_PROGRAM_ERROR') ;
          FND_MESSAGE.SET_TOKEN('PGM_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
          FND_MSG_PUB.ADD;
          RAISE g_exc_error;
       END IF;

       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF g_debug = 1 THEN
             print_debug('Program Inv_lot_api_pkg.Check_Item_Attributes has failed with a Unexpected exception', 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
          FND_MESSAGE.SET_TOKEN('PGM_NAME','Inv_lot_api_pkg.Check_Item_Attributes');
          fnd_msg_pub.ADD;
          RAISE g_exc_unexpected_error;
       END IF;

       IF (l_lot_cont = FALSE) THEN
          IF g_debug = 1 THEN
             print_debug(' Item is not lot controlled ', 9);
          END IF;
          fnd_message.set_name('INV', 'INV_NO_LOT_CONTROL');
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_error;
          RAISE g_exc_error;
       END IF ;

       IF (l_child_lot_cont = FALSE AND p_parent_lot_number IS NOT NULL) THEN
          IF g_debug = 1 THEN
             print_debug(' Item is not Child lot controlled ', 9);
          END IF;
          fnd_message.set_name('INV', 'INV_ITEM_CLOT_DISABLE_EXP');
          fnd_msg_pub.ADD;
          x_return_status  := fnd_api.g_ret_sts_error;
          RAISE g_exc_error;
       END IF ;


   /******************* End enhancement 4018794  ********************/

    -- BEGIN Bug# 4233182
    IF p_rti_id IS NOT NULL THEN
       print_debug('Get transaction details ' , 1);
       SELECT transaction_type, destination_type_code, auto_transact_code, parent_transaction_id
       INTO l_transaction_type, l_destination_type_code, l_auto_transact_code, l_parent_transaction_id
       FROM rcv_transactions_interface
       WHERE interface_transaction_id = p_rti_id;
    END IF;

    IF l_parent_transaction_id IS NOT NULL OR l_parent_transaction_id <> -1 THEN
       print_debug('Get parent transaction details ' , 1);
       SELECT transaction_type, destination_type_code
       INTO l_parent_transaction_type, l_parent_destination_type_code
       FROM rcv_transactions WHERE transaction_id = l_parent_transaction_id;
    END IF;

    IF ( (l_transaction_type = 'DELIVER' AND l_destination_type_code = 'INVENTORY') OR
         (l_transaction_type = 'RECEIVE' AND l_auto_transact_code = 'DELIVER' AND l_destination_type_code = 'INVENTORY') OR
         (l_transaction_type = 'CORRECT' AND l_parent_transaction_type = 'DELIVER' AND l_parent_destination_type_code = 'INVENTORY') OR
         (l_transaction_type = 'RETURN TO VENDOR' AND l_parent_transaction_type = 'DELIVER' AND l_parent_destination_type_code = 'INVENTORY') OR
         (l_transaction_type = 'RETURN TO CUSTOMER' AND l_parent_transaction_type = 'DELIVER' AND l_parent_destination_type_code = 'INVENTORY') OR
         (l_transaction_type = 'RETURN TO RECEIVING' AND l_parent_transaction_type = 'DELIVER' AND l_parent_destination_type_code = 'INVENTORY')
       ) THEN
       -- its a Inventory transaction
       -- Call check lot indivisible API.

       print_debug('Calling inv_lot_api_pub.CHECK_LOT_INDIVISIBILITY' , 1);
       inv_lot_api_pub.CHECK_LOT_INDIVISIBILITY (
                                p_api_version          => 1.0
                              , p_init_msg_list        => FND_API.G_FALSE
                              , p_commit               => FND_API.G_FALSE
                              , p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                              , p_rti_id               => p_rti_id
                              , p_transaction_type_id  => p_transaction_type_id
                              , p_lot_number           => p_lot_number
                              , p_lot_quantity         => p_lot_primary_qty
                              , p_revision             => p_revision
                              , p_qoh                  => NULL
                              , p_atr                  => NULL
                              , x_return_status        => l_return_status
                              , x_msg_count            => l_msg_count
                              , x_msg_data             => l_msg_data
                            );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         print_debug('Lot Indivisiblity check failure in inv_lot_api_pub.CHECK_LOT_INDIVISIBILITY' , 1);
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- END Bug# 4233182

     /*Moving the lot indiv call from here to INV_LOT_API_PUB.PO_CHECK_INDIVISIBILITY
       Punit Kumar, 08-02-2005 */

       /*I

       L_TRANSACTION_TYPE := p_transaction_type ;
       l_parent_txn_type  := p_parent_txn_type ;


       /*
       IF l_transaction_type IN ('TRANSFER','DELIVER','RETURN TO VENDOR',
                                 'RETURN TO CUSTOMER','RETURN TO RECEIVING') THEN

       */
       /*I
          l_source_document_code :=p_source_document_code;


       /*Call lot indivisibility procedure to check if whether in case of indivisible
         lots we are transacting a quantity less than that specified for that lot.

         Call INV_LOT_API_PUB.validate_lot_indivisible  (@ INVPLOTB.pls) */
       /*I
       IF g_debug = 1 THEN
             print_debug('p_transaction_type_id is  ' || p_transaction_type_id, 9);
             print_debug('l_transaction_type is  ' || l_transaction_type, 9);
             print_debug('l_parent_txn_type is  ' || l_parent_txn_type, 9);
             print_debug('l_source_document_code is  ' || l_source_document_code, 9);

       END IF;

       /* populating the p_transaction_type_id for various transactions */

           /*
       IF p_transaction_type_id IS NULL THEN

          -----Deliver transactions
          IF l_transaction_type ='DELIVER' THEN
             IF (l_source_document_code = 'PO') THEN
                l_transaction_type_id := 18;
             ELSIF (l_source_document_code = 'RMA') THEN
                l_transaction_type_id := 15;
             END IF;
          END IF;

          -----Transfer transactions
          IF l_parent_txn_type IN ('RECEIVE','ACCEPT','TRANSFER','RETURN TO RECEIVING',
                                   'REJECT') THEN
             IF l_transaction_type='TRANSFER' THEN
                l_transaction_type_id := 71;
             END IF;
          END IF;

          ------Return Transactions
          IF l_parent_txn_type ='DELIVER' AND l_transaction_type = 'RETURN TO RECEIVING' THEN
             IF (l_source_document_code = 'PO') THEN
				   l_transaction_type_id := 36;
				 ELSIF (l_source_document_code = 'RMA') THEN
                l_transaction_type_id := 37;
             END IF;

          ELSIF l_parent_txn_type IN ('RECEIVE','ACCEPT','TRANSFER','RETURN TO RECEIVING',
                                   'REJECT') AND  l_transaction_type = 'RETURN TO VENDOR' THEN
             l_transaction_type_id :=36 ;
          ELSIF l_parent_txn_type = 'RETURN TO RECEIVING' AND l_transaction_type = 'RETURN TO CUSTOMER' THEN
             l_transaction_type_id :=37 ;
          END IF;
       END IF;
       */
       /* end ,populating the p_transaction_type_id for various transactions */

       /*I
       IF (l_transaction_type IN ('RECEIVE','ACCEPT','REJECT','TRANSFER','DELIVER')) THEN

          IF (l_source_document_code = 'PO') THEN
             l_transaction_type_id := 18; -- PO
          ELSIF (l_source_document_code = 'RMA') THEN
             l_transaction_type_id := 15; -- RMA
          --ELSIF (l_source_document_code = 'INVENTORY') THEN
             --   l_transaction_type_id := 12; -- Inter Org Intransit
          ELSE
             l_transaction_type_id := 61; -- Internal Req
          END IF;

       ELSIF (l_transaction_type IN ('RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN
          IF (l_source_document_code = 'PO') THEN
             l_transaction_type_id := 36; -- PO
          ELSIF (l_source_document_code = 'RMA') THEN
             l_transaction_type_id := 37; -- RMA
          END IF;
       END IF;

       /*fix for p_trx_id not null and l_trx_id null*/
       /*I
       IF l_transaction_type_id IS NULL AND p_transaction_type_id IS NOT NULL  THEN
          l_transaction_type_id := p_transaction_type_id ;
       END IF;
       /*end fix*/
     /*I
       IF g_debug = 1 THEN
          print_debug(' L_TRANSACTION_TYPE: '||L_TRANSACTION_TYPE , 9);
          print_debug(' l_parent_txn_type: '||l_parent_txn_type , 9);
          print_debug('l_source_document_code : '|| l_source_document_code, 9);
          print_debug('l_transaction_type_id : '||l_transaction_type_id , 9);
       END IF;

       -----IF  l_lot_ind_call = 'Y' THEN

       IF NOT (INV_LOT_API_PUB.validate_lot_indivisible(
                                                        p_api_version 			 =>1.0
                                                        ,p_init_msg_list 		 =>FND_API.G_FALSE
                                                        ,p_commit 			    =>FND_API.G_FALSE
                                                        ,p_validation_level 	 =>FND_API.G_VALID_LEVEL_FULL
                                                        ,p_transaction_type_id =>l_transaction_type_id
                                                        ,p_organization_id		 =>p_to_organization_id
                                                        ,p_inventory_item_id	 =>p_item_id
                                                        ,p_revision			    =>p_revision
                                                        ,p_subinventory_code	 =>p_subinventory_code
                                                        ,p_locator_id			 =>p_locator_id
                                                        ,p_lot_number	       =>p_lot_number
                                                        ,p_primary_quantity 	 =>p_lot_quantity------------the primary quantity of the transaction
                                                        ,p_qoh 	             =>NULL
                                                        ,p_atr 	             =>NULL
                                                        ,x_return_status 	    =>l_return_status
                                                        ,x_msg_count 	       =>l_msg_count
                                                        ,x_msg_data 	          =>l_msg_data
                                                        ))THEN

          ------IF qoh and atr are passed as NULL THEN quantity tree is called in the API.
          IF g_debug = 1 THEN
             print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible return FALSE ' || l_return_status || 'and '|| l_progress, 9);
          END IF;

          l_progress := '100' ;

          /* Enhancement #4019704. Allow Return transactions even if lot indivisibility fails but the
          transaction quantity is equal to the received quantity. Punit Kumar. 02-Dec-2004. */
      /*I
          IF ((l_return_status <> FND_API.G_RET_STS_SUCCESS) AND l_transaction_type IN ('RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN

             l_progress := '101';

             l_lot_qty := p_lot_quantity ;

             ------------------fetching PARENT_TRANSACTION_ID
             SELECT PARENT_TRANSACTION_ID
                INTO l_parent_trx_id
                FROM RCV_TRANSACTIONS_INTERFACE
                WHERE INTERFACE_TRANSACTION_ID = p_rti_id;

             IF l_parent_trx_id IS NULL THEN
                IF g_debug = 1 THEN
                   print_debug('parent txn id cannot be null  '|| l_progress, 1);
                END IF;
                RAISE g_exc_unexpected_error;
             END IF;

             ------------------Get previously received primary quantity for the Lot.
             OPEN Cr_rcv_qty ;
             FETCH Cr_rcv_qty
                INTO l_pmy_rcv_qty,l_pmy_unit_of_meas;
             CLOSE Cr_rcv_qty ;

             IF g_debug = 1 THEN
                print_debug('l_parent_trx_id '|| l_parent_trx_id, 9);
                print_debug('l_lot_qty '|| l_lot_qty, 9);
                print_debug('l_pmy_rcv_qty '|| l_pmy_rcv_qty, 9);
                print_debug('l_pmy_unit_of_meas '|| l_pmy_unit_of_meas, 9);
                print_debug('p_transaction_unit_of_measure '|| p_transaction_unit_of_measure, 9);
             END IF;

             IF l_pmy_unit_of_meas <> p_transaction_unit_of_measure THEN

                l_progress := '102';

                /* Convert transaction qty in p_transaction_unit_of_measure to l_pmy_unit_of_meas */
         /*I
                l_lot_qty := INV_CONVERT.inv_um_convert(
                                                        item_id 			 => p_item_id                       ,
                                                        lot_number 		 => p_lot_number                    ,
                                                        organization_id	 => p_to_organization_id	         ,
                                                        precision		    => 5                               ,
                                                        from_quantity    => l_lot_qty                       ,
                                                        from_unit		    => NULL                            ,
                                                        to_unit    		 => NULL                            ,
                                                        from_name        => p_transaction_unit_of_measure   ,
                                                        to_name          => l_pmy_unit_of_meas
                                                        );

                IF g_debug = 1 THEN
                   print_debug('Program INV_CONVERT.inv_um_convert return: ' || l_progress, 9);
                   print_debug('l_lot_qty: ' || l_lot_qty, 9);
                END IF;

                l_progress := '103';

                IF l_lot_qty = -99999  THEN

                   IF g_debug = 1 THEN
                      print_debug('INV_CONVERT.inv_um_convert has failed '|| l_progress, 1);
                   END IF;

                   FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
                   fnd_msg_pub.ADD;

                   RAISE g_exc_unexpected_error;
                END IF;

             END IF; -----------IF l_pmy_unit_of_meas <> p_transaction_unit_of_measure

             /* If the trx quantity = total received quantity for that parent deliver trx
                then even though lot indivisibily fails , we shall allow the "Return" trx
                */
           /*I
             IF l_lot_qty = l_pmy_rcv_qty  THEN

                IF g_debug = 1 THEN
                   print_debug('l_return_status'|| l_return_status, 9);
                END IF;

                l_return_status := FND_API.G_RET_STS_SUCCESS  ;

                IF g_debug = 1 THEN
                   print_debug('l_return_status'|| l_return_status, 9);
                   print_debug('set return status of validate_lot_indivisible to true'|| l_progress, 9);
                END IF;

             END IF; ----------IF (l_lot_qty = l_pmy_rcv_qty

          END IF;  -------- IF (l_transaction_type IN ('RETURN TO RECEIVING'

          /* end , enhancement */
         /* I
                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                      print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible has failed with a user defined exception '|| l_progress, 9);
                   END IF;

                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_LOT_API_PUB.validate_lot_indivisible');
                   fnd_msg_pub.ADD;
                   RAISE g_exc_error;

                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   l_progress := '012' ;
                   IF g_debug = 1 THEN
                      print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible has failed with a Unexpected exception' || l_progress, 9);
                   END IF;

                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_LOT_API_PUB.validate_lot_indivisible');
                   fnd_msg_pub.ADD;
                   RAISE g_exc_unexpected_error;
                END IF;------------IF l_return_status = fnd_api.g_ret_sts_error THEN

             END IF; ----IF NOT (INV_LOT_API_PUB.validate_lot_indivisible(

             IF g_debug = 1 THEN
                print_debug('Program INV_LOT_API_PUB.validate_lot_indivisible return TRUE ' || l_return_status || 'and '|| l_progress, 9);
             END IF;

         -------- END IF ; ----------IF  l_lot_ind_call = 'Y' THEN

       ----END IF; -------IF l_transaction_type IN ('TRANSFER','DELIVER'........
      I*/


       /*Check for secondary_quantity in receipt line (p_line_secondary_quantity), */
       --IF p_line_secondary_quantity > 0 AND p_secondary_unit_of_measure IS NOT NULL THEN
         IF nvl(p_line_secondary_quantity,0) <> 0 AND p_secondary_unit_of_measure IS NOT NULL THEN  -- 7644869   change check as qty could be a correction and could be negative

          /*item is dual UOM controlled .No need to check it..*/

          IF  l_lot_secondary_quantity IS NOT NULL THEN
             /*Validate the secondary quantity, do lot level deviation check*/

             l_progress := '013' ;

             IF g_debug = 1 THEN
                print_debug('Before calling INV_CONVERT.Within_deviation ' || l_progress, 1);
                print_debug('p_quantity ' || p_lot_quantity, 1);
                print_debug('p_quantity2 ' || l_lot_secondary_quantity, 1);
                print_debug('p_unit_of_measure1 ' || p_transaction_unit_of_measure, 1);
                print_debug('p_unit_of_measure2 ' || p_secondary_unit_of_measure, 1);
             END IF;

             IF NOT (INV_CACHE.set_item_rec(p_to_organization_id, p_item_id)) THEN
                RAISE INVALID_ITEM;
             END IF;

             /* Bug 5365360 for a fixed type of item just recompute the lot secondary quantity)*/
             IF (INV_CACHE.item_rec.secondary_default_ind = 'F') THEN
                l_lot_secondary_quantity:= INV_CONVERT.inv_um_convert (
                                                                    item_id         => p_item_id
 ,
                                                                    lot_number      => p_lot_number
 ,
                                                                    organization_id => p_to_organization_id
 ,
                                                                    precision       => 5
 ,
                                                                    from_quantity   => p_lot_quantity
 ,
                                                                    from_unit       => l_from_unit                      ,
                                                                    to_unit         => l_to_unit                        ,
                                                                    from_name       => p_transaction_unit_of_measure    ,
                                                                    to_name         => p_secondary_unit_of_measure
                                                                    );
                /*update the out variable*/
                x_lot_secondary_quantity :=l_lot_secondary_quantity ;

                ---update table with the defaulted secondary quantity
             BEGIN
                UPDATE mtl_transaction_lots_temp
                   SET secondary_quantity  = l_lot_secondary_quantity
                   WHERE  rowid = p_mtlt_rowid ;
             IF g_debug = 1 THEN
                   print_debug('updated MTLT with the defaulted secondary quantity: ' || l_progress, 9);
                END IF;

               /* No need to update MTLI as rows are deleted from there after moving them to MTLT */


                l_progress := '017' ;

             EXCEPTION
                WHEN OTHERS THEN
                   IF g_debug = 1 THEN
                      print_debug('UPDATE mtl_transaction_lots_temp with not null lot secondary quantity failed for an existing lot' || l_progress, 1);
                   END IF;
                   RAISE g_exc_unexpected_error;
             END;


             ELSE

                l_deviation_check := INV_CONVERT.Within_deviation(
                                                               p_organization_id   	    => p_to_organization_id                    ,
                                                               p_inventory_item_id      => p_item_id                               ,
                                                               p_lot_number  		       => p_lot_number                            ,
                                                               p_precision   		       => 5                                       ,
                                                               p_quantity		          => p_lot_quantity ,--transaction quantity
                                                               p_uom_code1		          => NULL                                    ,
                                                               p_quantity2   		       => l_lot_secondary_quantity                ,
                                                               p_uom_code2		          => NULL                                    ,
                                                               p_unit_of_measure1	    => p_transaction_unit_of_measure           ,
                                                               p_unit_of_measure2	    => p_secondary_unit_of_measure
                                                               );


             /*RETURN Number , 1 for True and 0 for False */

             IF g_debug = 1 THEN
                print_debug('Program INV_CONVERT.Within_deviation return ' || l_progress, 1);
             END IF;
            END IF;


            l_progress := '014';

             IF l_deviation_check = 0 THEN
                IF g_debug = 1 THEN
                   print_debug('Program INV_CONVERT.Within_deviation has failed ' || l_progress, 1);
                END IF;
                FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.Within_deviation return');
                fnd_msg_pub.ADD;
                RAISE g_exc_unexpected_error;
             END IF;

          ELSE  -----if  l_lot_secondary_quantity is NULL THEN default it

             l_progress := '015';

             IF g_debug = 1 THEN
               print_debug('Before calling INV_CONVERT.inv_um_convert ' || l_progress, 1);
               print_debug('from_quantity ' || p_lot_quantity, 1);
               print_debug('from_unit ' || l_from_unit, 1);
               print_debug('to_unit ' || l_to_unit, 1);
               print_debug('from_name ' || p_transaction_unit_of_measure, 1);
               print_debug('to_name ' || p_secondary_unit_of_measure, 1);
            END IF;


             l_lot_secondary_quantity:= INV_CONVERT.inv_um_convert (
                                                                    item_id  			=> p_item_id                        ,
                                                                    lot_number 		=> p_lot_number                     ,
                                                                    organization_id => p_to_organization_id             ,
                                                                    precision 		=> 5                                ,
                                                                    from_quantity   => p_lot_quantity                   ,
                                                                    from_unit		   => l_from_unit                      ,
                                                                    to_unit   		=> l_to_unit                        ,
                                                                    from_name       => p_transaction_unit_of_measure    ,
                                                                    to_name         => p_secondary_unit_of_measure
                                                                    );

             IF g_debug = 1 THEN
                print_debug('Program INV_CONVERT.inv_um_convert return: ' || l_progress, 9);
                print_debug('l_lot_secondary_quantity: ' || l_lot_secondary_quantity, 9);
             END IF;

             l_progress := '016';

             IF l_lot_secondary_quantity = -99999  THEN
                IF g_debug = 1 THEN
                   print_debug('INV_CONVERT.inv_um_convert has failed '|| l_progress, 1);
                END IF;
                FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
                fnd_msg_pub.ADD;

                RAISE g_exc_unexpected_error;
             END IF;

             /*update the out variable*/
             x_lot_secondary_quantity :=l_lot_secondary_quantity ;

             ---update table with the defaulted secondary quantity
             BEGIN
                UPDATE mtl_transaction_lots_temp
                   SET secondary_quantity  = l_lot_secondary_quantity
                   WHERE  rowid = p_mtlt_rowid ;

                IF g_debug = 1 THEN
                   print_debug('updated MTLT with the defaulted secondary quantity: ' || l_progress, 9);
                END IF;

               /* No need to update MTLI as rows are deleted from there after moving them to MTLT */


                l_progress := '017' ;

             EXCEPTION
                WHEN OTHERS THEN
                   IF g_debug = 1 THEN
                      print_debug('UPDATE mtl_transaction_lots_temp with not null lot secondary quantity failed for an existing lot' || l_progress, 1);
                   END IF;
                   RAISE g_exc_unexpected_error;
             END;


          END IF;  ------ IF  l_lot_secondary_quantity IS NOT NULL THEN

       ELSE  ------ IF  p_line_secondary_quantity IS NOT NULL THEN

          l_progress := '018';
          -----blank the lot secondary quantity
          l_lot_secondary_quantity :=NULL;

          /*update the out variable*/
          x_lot_secondary_quantity :=l_lot_secondary_quantity ;

          ---update table with NULL secondary quantity
          BEGIN
             UPDATE mtl_transaction_lots_temp
                SET secondary_quantity  = l_lot_secondary_quantity
                WHERE  rowid = p_mtlt_rowid ;

             IF g_debug = 1 THEN
                print_debug('updated MTLT with NULL secondary quantity: ' || l_progress, 9);
             END IF;


          EXCEPTION
             WHEN OTHERS THEN
                IF g_debug = 1 THEN
                   print_debug('UPDATE mtl_transaction_lots_temp with null lot secondary quantity failed for an existing lot' || l_progress, 1);
                END IF;
                RAISE g_exc_unexpected_error;
          END;

       END IF; ---- IF  p_line_secondary_quantity IS NOT NULL THEN

/* end of  validation for an existing  Lot ("If  p_new_lot= 'N' THEN").Start Lot validation for a new Lot */

    ---SAVEPOINT INV_VAL_LOT4;
    l_progress := '019';

    ELSIF p_new_lot = 'Y' THEN
       --IF p_line_secondary_quantity > 0 AND p_secondary_unit_of_measure IS NOT NULL THEN
       IF nvl(p_line_secondary_quantity,0) <> 0  AND p_secondary_unit_of_measure IS NOT NULL THEN  -- 7644869 -  change check as qty could be negative
          ----item is dual UOM controlled .No need to check it..)
          IF  l_lot_secondary_quantity IS NOT NULL THEN
             ---Validate the secondary quantity

             IF g_debug = 1 THEN
                print_debug('Before calling INV_CONVERT.Within_deviation ' || l_progress, 1);
                print_debug('p_quantity ' || p_lot_quantity, 1);
                print_debug('p_quantity2 ' || l_lot_secondary_quantity, 1);
                print_debug('p_unit_of_measure1 ' || p_transaction_unit_of_measure, 1);
                print_debug('p_unit_of_measure2 ' || p_secondary_unit_of_measure, 1);
             END IF;

             IF NOT (INV_CACHE.set_item_rec(p_to_organization_id, p_item_id)) THEN
                RAISE INVALID_ITEM;
             END IF;

             /* Bug 5365360 for a fixed type of item just recompute the lot secondary quantity)*/
             IF (INV_CACHE.item_rec.secondary_default_ind = 'F') THEN
                l_lot_secondary_quantity:= INV_CONVERT.inv_um_convert (
                                                                    item_id         => p_item_id                        ,
                                                                    lot_number      => p_lot_number                     ,
                                                                    organization_id => p_to_organization_id             ,
                                                                    precision       => 5                                ,
                                                                    from_quantity   => p_lot_quantity                   ,
                                                                    from_unit       => l_from_unit                      ,
                                                                    to_unit         => l_to_unit                        ,
                                                                    from_name       => p_transaction_unit_of_measure    ,
                                                                    to_name         => p_secondary_unit_of_measure
                                                                    );
                /*update the out variable*/
                x_lot_secondary_quantity :=l_lot_secondary_quantity ;

                ---update table with the defaulted secondary quantity
             BEGIN
                UPDATE mtl_transaction_lots_temp
                   SET secondary_quantity  = l_lot_secondary_quantity
                   WHERE  rowid = p_mtlt_rowid ;
                IF g_debug = 1 THEN
                   print_debug('updated MTLT with the defaulted secondary quantity: ' || l_progress, 9);
                END IF;

               /* No need to update MTLI as rows are deleted from there after moving them to MTLT */


                l_progress := '017' ;

             EXCEPTION
                WHEN OTHERS THEN
                   IF g_debug = 1 THEN
                      print_debug('UPDATE mtl_transaction_lots_temp with not null lot secondary quantity failed for an
existing lot' || l_progress, 1);
                   END IF;
                   RAISE g_exc_unexpected_error;
             END;


             ELSE


                ---Do item level deviation check
                l_deviation_check := INV_CONVERT.Within_deviation(
                                                               p_organization_id    	=> p_to_organization_id                      ,
                                                               p_inventory_item_id   	=> p_item_id                                 ,
                                                               p_lot_number  			   => p_lot_number ,---new lot number
                                                               p_precision   			   => 5                                         ,
                                                               p_quantity			      => p_lot_quantity ,----transaction quantity
                                                               p_uom_code1		  	      => NULL                                      ,
                                                               p_quantity2    		   => l_lot_secondary_quantity                  ,
                                                               p_uom_code2		 	      => NULL                                      ,
                                                               p_unit_of_measure1		=> p_transaction_unit_of_measure             ,
                                                               p_unit_of_measure2		=> p_secondary_unit_of_measure
                                                               );

             l_progress := '020';

             /*RETURN Number , 1 for True and 0 for False */

             IF g_debug = 1 THEN
                print_debug('Program INV_CONVERT.Within_deviation return ' || l_progress, 1);
             END IF;

             IF l_deviation_check = 0 THEN
                IF g_debug = 1 THEN
                   print_debug('Program INV_CONVERT.Within_deviation has failed ' || l_progress, 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.Within_deviation return');
                fnd_msg_pub.ADD;
                RAISE g_exc_error;
             END IF;

           END IF;

          ELSE -----if  l_lot_secondary_quantity is NULL

              IF g_debug = 1 THEN
               print_debug('Before calling INV_CONVERT.inv_um_convert ' || l_progress, 1);
               print_debug('from_quantity ' || p_lot_quantity, 1);
               print_debug('from_unit ' || l_from_unit, 1);
               print_debug('to_unit ' || l_to_unit, 1);
               print_debug('from_name ' || p_transaction_unit_of_measure, 1);
               print_debug('to_name ' || p_secondary_unit_of_measure, 1);
            END IF;

             ---Default the secondary quantity.
             l_lot_secondary_quantity:= INV_CONVERT.Inv_um_convert(
                                                                   item_id          => p_item_id                        ,
                                                                   lot_number 		=> p_lot_number,----new lot number
                                                                   organization_id	=> p_to_organization_id             ,
                                                                   precision	 	   => 5                                ,
                                                                   from_quantity    => p_lot_quantity                   ,
                                                                   from_unit		   => l_from_unit                      ,
                                                                   to_unit   		   => l_to_unit                        ,
                                                                   from_name        => p_transaction_unit_of_measure    ,
                                                                   to_name          => p_secondary_unit_of_measure
                                                                   );
             l_progress :='021';

             IF g_debug = 1 THEN
                print_debug('Program INV_CONVERT.inv_um_convert return: '||l_progress , 1);
             END IF;

             IF l_lot_secondary_quantity = -99999  THEN
                IF g_debug = 1 THEN
                   print_debug('INV_CONVERT.inv_um_convert has failed'|| l_progress, 9);
                END IF;
                FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
                FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
                fnd_msg_pub.ADD;
                RAISE g_exc_unexpected_error;
             END IF;

             l_progress :='022';

             /*update the out variable*/
             x_lot_secondary_quantity :=l_lot_secondary_quantity ;

             ---update table with the defaulted secondary quantity
             BEGIN
                UPDATE mtl_transaction_lots_temp
                   SET secondary_quantity  = l_lot_secondary_quantity
                   WHERE  rowid = p_mtlt_rowid ;

                IF g_debug = 1 THEN
                   print_debug('updated MTLT with the defaulted secondary quantity: ' || l_progress, 9);
                END IF;

              /* No need to update MTLI as rows are deleted from there after moving them to MTLT */



             EXCEPTION
                WHEN OTHERS THEN
                   IF g_debug = 1 THEN
                      print_debug('UPDATE mtl_transaction_lots_temp with not null lot secondary quantity failed for a new lot'|| l_progress, 4);
                   END IF;
                   RAISE g_exc_unexpected_error;
             END;

          END IF;  ------ IF  l_lot_secondary_quantity IS NOT NULL THEN

       ELSE  ------ IF  p_line_secondary_quantity IS  NULL THEN
          l_progress :='023';
          ----blank the lot secondary quantity
          l_lot_secondary_quantity :=NULL ;

          /*update the out variable*/
          x_lot_secondary_quantity := l_lot_secondary_quantity ;

          ---update table with NULL secondary quantity
          BEGIN
             UPDATE mtl_transaction_lots_temp
                SET secondary_quantity  = l_lot_secondary_quantity
                WHERE  rowid = p_mtlt_rowid ;

             IF g_debug = 1 THEN
                print_debug('updated MTLT with NULL secondary quantity: ' || l_progress, 9);
             END IF;


             IF g_debug = 1 THEN
                print_debug('update table with NULL secondary quantity:' || l_progress, 1);
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
                IF g_debug = 1 THEN
                   print_debug('UPDATE mtl_transaction_lots_temp with null lot secondary quantity failed for a new lot'|| l_progress, 1);
                END IF;
                RAISE g_exc_unexpected_error;
          END;

       END IF; ------ IF  p_line_secondary_quantity IS NOT NULL THEN

       print_debug('End of the program inv_roi_integration_grp.inv_validate_lot. Program has completed successfully '|| l_progress, 1);

    END IF; ------ IF p_new_lot= 'N' THEN
-------end of validation for a new lot. Start Exception section --------------------------------------

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
          x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(
                                    p_encoded => fnd_api.g_false ,
                                    p_count => x_msg_count       ,
                                    p_data => x_msg_data
                                    );
          IF( x_msg_count > 1 ) THEN
             x_msg_data := fnd_msg_pub.get(
                                           x_msg_count     ,
                                           FND_API.G_FALSE
                                           );
          END IF ;
          IF g_debug = 1 THEN
             print_debug('Exitting INV_VALIDATE_LOT - No data found error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
             -----print_stacked_messages;
          END IF;

      WHEN INVALID_ITEM THEN
       FND_MESSAGE.SET_NAME('INV','INV_INVALID_ITEM');
       FND_MSG_PUB.ADD;
       x_return_status  := fnd_api.g_ret_sts_error;
          fnd_msg_pub.count_and_get(
                                    p_encoded => fnd_api.g_false ,
                                    p_count => x_msg_count       ,
                                    p_data => x_msg_data
                                    );
          IF( x_msg_count > 1 ) THEN
             x_msg_data := fnd_msg_pub.get(
                                           x_msg_count     ,
                                           FND_API.G_FALSE
                                           );
          END IF ;

       IF g_debug = 1 THEN
        print_debug('Exitting INV_VALIDATE_LOT - Invalid Item:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);

       END IF;


      WHEN g_exc_error THEN
         x_return_status  := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count     ,
                                          FND_API.G_FALSE
                                          );
         END IF;

         IF g_debug = 1 THEN
            print_debug('Exitting INV_VALIDATE_LOT - g_exc_error error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            -----print_stacked_messages;
         END IF;


      WHEN g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE
                                          );
         END IF ;

         IF g_debug = 1 THEN
            print_debug('Exitting INV_VALIDATE_LOT - g_exc_unexpected_error error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            --------print_stacked_messages;
         END IF;

      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE);
         END IF;

         IF g_debug = 1 THEN
            print_debug('Exitting INV_VALIDATE_LOT - In others error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            --------print_stacked_messages;
         END IF;


 END  INV_VALIDATE_LOT;



  /*##########################################################################
  #
  #  PROCEDURE  INV_New_lot
  #
  #  DESCRIPTION :-
  #
  #   If the shipped lot is new for destination org , then its attributes will be
  #   picked up from that of shipping org and NOT from  the item master of the
  #   destination org. This shall be done for 'Receive ' transactions and  +ve corrections.
  #
  #    Create the new lot and then update MTLT with the new lot attributes.
  #
  #    Create lot specific conversions for :
  #    Primary UOM and Secondary UOM
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  # MODIFICATION HISTORY
  # 10-AUG-2004  Punit Kumar 	Created
  # 01-SEP-2004  Punit Kumar  Changed the way l_lot_rec was getting populated
  #
  #########################################################################*/


  PROCEDURE INV_New_lot(
                         x_return_status         	   			 OUT NOCOPY VARCHAR2                   ,
                         x_msg_count             	  			    OUT NOCOPY NUMBER                     ,
                         x_msg_data             	    			 OUT NOCOPY VARCHAR2                   ,
                         p_api_version	 		                   IN  NUMBER DEFAULT 1.0                ,
                         p_init_msg_lst	 		                IN  VARCHAR2 := FND_API.G_FALSE       ,
                         p_source_document_code                 IN  VARCHAR2                          ,
                         p_item_id                              IN  NUMBER                            ,
                         p_from_organization_id                 IN  NUMBER                            ,
                         p_to_organization_id                   IN  NUMBER                            ,
                         p_lot_number                           IN  VARCHAR2                          ,
                         p_lot_quantity			                IN  NUMBER                            ,
                         p_lot_secondary_quantity	             IN  NUMBER                            ,
                         p_line_secondary_quantity              IN  NUMBER                            ,
                         p_primary_unit_of_measure              IN  VARCHAR2                          ,
                         p_secondary_unit_of_measure            IN  VARCHAR2                          ,
                         p_uom_code                             IN  VARCHAR2                          ,
                         p_secondary_uom_code                   IN  VARCHAR2                          ,
                         p_reason_id                            IN  NUMBER                            ,
                         P_MLN_REC                              IN  mtl_lot_numbers%ROWTYPE           ,
                         p_mtlt_rowid				                IN  ROWID
                         )

     IS
     /* copy all values from mtl_lot_numbers for inter org transfer */
     CURSOR C_MLN (l_lot_number           VARCHAR2,
                   l_item_id              NUMBER,
                   l_from_organization_id NUMBER
                   ) IS
        SELECT *
           FROM mtl_lot_numbers
           WHERE lot_number = l_lot_number
           AND inventory_item_id=l_item_id
           AND organization_id = l_from_organization_id;

     ---local variables declaration
     l_lot_rec                C_MLN%ROWTYPE                                         ;
     L_MLN_REC                mtl_lot_numbers%ROWTYPE                               ;
     x_lot_rec                MTL_LOT_NUMBERS%ROWTYPE                               ;
     p_lot_uom_conv_rec       mtl_lot_uom_class_conversions%ROWTYPE                 ;
     l_source                 NUMBER                                                ;
     l_permission_value       NUMBER                                                ;
     l_conv_info_exists       NUMBER                                                ;
     l_grade_controlled_flag  VARCHAR2(1)                                           ;
     l_qty_update_tbl         MTL_LOT_UOM_CONV_PUB.quantity_update_rec_type         ;
     l_primary_uom_class      VARCHAR2(10)                                          ;
     l_secondary_uom_class    VARCHAR2(10)                                          ;
     l_api_name               VARCHAR2(30) := 'INV_New_lot'                         ;
     l_api_version            CONSTANT NUMBER := 1.0                                ;
     l_progress		         VARCHAR2(3) := '000'                                  ;
     l_return_status          VARCHAR2(1)                                           ;
     l_msg_data               VARCHAR2(3000)                                        ;
     l_msg_count              NUMBER                                                ;
     l_row_id                 ROWID                                                 ;
     l_secondary_default_ind  VARCHAR2(30)                                          ;
     l_sequence               NUMBER :=NULL                                         ;


  BEGIN

    l_progress := '024';

     -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version  ,
                                       p_api_version  ,
                                       l_api_name     ,
                                       'INV_ROI_INTEGRATION_GRP'
                                       ) THEN
       IF (g_debug = 1) THEN
          print_debug('FND_API not compatible INV_ROI_INTEGRATION_GRP.INV_New_lot'|| l_progress, 1);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE. */
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    /*Initialize the return status */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     /* Checking for Inter-Org transfer */

     IF p_source_document_code IN ( 'INVENTORY','REQ') THEN
        /* It is an Inter-Org Transfers.
        Default the lot attributes from  shipping lot.
        Check if the item is grade controlled in the destination org.  */

        l_progress := '025';
        /*SAVEPOINT inv_new_lot_save2; */

        BEGIN
           SELECT GRADE_CONTROL_FLAG
              INTO l_grade_controlled_flag
              FROM mtl_system_items_b
              WHERE INVENTORY_ITEM_ID = p_item_id
              AND  ORGANIZATION_ID = p_to_organization_id;

        IF g_debug = 1 THEN
           print_debug('p_source_document_code is :' || p_source_document_code|| ':' || l_progress, 1);
           print_debug('It is an Inter-Org Transfers.Defaulting the lot attributes from  shipping lot. :' || l_progress, 1);
           print_debug('grade controlled flag in destination org is :' || l_grade_controlled_flag|| ':' || l_progress, 1);
        END IF;

        EXCEPTION
           WHEN OTHERS THEN
              IF g_debug = 1 THEN
                 print_debug('inv_new_lot::SELECT GRADE_CONTROL_FLAG has failed with a Unexpected exception'|| l_progress, 1);
              END IF;
              RAISE g_exc_unexpected_error;
        END;


        IF g_debug = 1 THEN
           print_debug('p_lot_number:' || p_lot_number, 1);
           print_debug('p_item_id:' || p_item_id, 1);
           print_debug('p_from_organization_id:' || p_from_organization_id, 1);
        END IF;

        IF p_lot_number IS NULL OR p_item_id IS NULL OR p_from_organization_id IS NULL THEN
           IF g_debug = 1 THEN
              print_debug('Any of these 3 parameters as printed above cannot be null:', 1);
           END IF;
           RAISE g_exc_unexpected_error;
        END IF;

        ----Populate l_lot_rec (MTL_LOT_NUMBERS%ROWTYPE ) as follows:
        BEGIN

           OPEN C_MLN(p_lot_number,
                      p_item_id,
                      p_from_organization_id);
           FETCH C_MLN INTO l_lot_rec;

           l_progress :='026';

           /* If the lot in destination org for receive/deliver trx is already existing  in the
            shipping  org then the code works works fine.
           However if the lot is also new in the shipping org then the above cursor will fail as
           mtl_lot-numbers will not have any data.
           In this case erroring out as we cannot do an Inter Org transfer from an org with a new lot.
           We can only transfer in an existing lot.
           Thsi lot can nevertheless be be new in the destination org.
           */
           /*
           IF C_MLN%NOTFOUND THEN

              IF g_debug = 1 THEN
                 print_debug('Inter-Org Xfr::the lot is also new in the shipping org:' || l_progress, 1);
                 print_debug('Erroring Out as we cannot do an Inter Org transfer from an org with a new lot:' || l_progress, 1);
                 print_debug('inv_new_lot:We can only transfer in an existing lot:' || l_progress, 1);
              END IF;
              CLOSE C_MLN;
              RAISE g_exc_unexpected_error;

           ELSE
           */
              IF g_debug = 1 THEN
                 print_debug('inv_new_lot::fetched all records from mtl_lot_numbers(shipping org values)
                             for an Inter Org Transfer:' || l_progress, 1);
              END IF;
              CLOSE C_MLN;
          --- END IF;


           /*override the from_organization_id to to_organization_id and the dates*/
           l_lot_rec.organization_id := p_to_organization_id ;
           l_lot_rec.creation_date   := SYSDATE;
           l_lot_rec.last_update_date :=SYSDATE;

           /*if the item is not grade controlled in the destination org then nullify the grade code*/
           IF l_grade_controlled_flag <> 'Y' THEN
              l_lot_rec.grade_code := NULL;
              IF g_debug = 1 THEN
                 print_debug('item is not grade controlled in the destination org so
                             nullifying the grade code:' || l_lot_rec.grade_code, 1);
              END IF;
           END IF;

        EXCEPTION
           WHEN OTHERS THEN
              IF g_debug = 1 THEN
                 print_debug('Populating p_lot_rec with mtl_lot_number (shipping org values) has
                             failed with a Unexpected exception in INV_ROI_INTEGRATION_GRP.INV_NEW_LOT'|| l_progress, 1);
              END IF;
              RAISE g_exc_unexpected_error;
        END;

     ELSE ---------IF p_source_document_code IN ( 'INVENTORY','REQ') THEN

        /*Not an Inter-Org Transfers.
         Default the lot attributes from destination item master.
         Populate p_lot_rec (MTL_LOT_NUMBERS%ROWTYPE ) with the lot record coming from validate_lot_serial_info.
         All these parameters are to be used in the serias of API calls starting Create_Inv_Lot */

        l_lot_rec  := P_MLN_REC ;

        /* p_mln_rec is coming from validate_lot_serial_info and is already populated
        with MTLT vaules.Assign some of the missing attributes here*/

        l_lot_rec.INVENTORY_ITEM_ID         := p_item_id                                ;
        l_lot_rec.ORGANIZATION_ID           := p_to_organization_id                     ;

        IF g_debug = 1 THEN
           print_debug('inv_new_lot::fetched all records from destination org:' || l_progress, 1);
        END IF;



	  END IF;---------IF p_source_document_code IN ( 'INVENTORY','REQ') THEN

     l_progress := '027';

     IF g_debug = 1 THEN
        print_debug('Printing the values of p_lot_rec before calling inv_lot_api_pub.Create_Inv_lot '|| l_progress, 1);
        print_debug('l_lot_rec.INVENTORY_ITEM_ID: '|| l_lot_rec.INVENTORY_ITEM_ID||':'||l_progress, 1);
        print_debug('l_lot_rec.ORGANIZATION_ID '|| l_lot_rec.ORGANIZATION_ID||':'||l_progress, 1);
        print_debug('l_lot_rec.LOT_NUMBER :'|| l_lot_rec.LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('l_lot_rec.PARENT_LOT_NUMBER :'|| l_lot_rec.PARENT_LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('l_lot_rec.LAST_UPDATE_DATE:'|| l_lot_rec.LAST_UPDATE_DATE||':'|| l_progress, 1);
        print_debug('l_lot_rec.LAST_UPDATED_BY:'|| l_lot_rec.LAST_UPDATED_BY||':'|| l_progress, 1);
        print_debug('l_lot_rec.CREATION_DATE:'|| l_lot_rec.CREATION_DATE||':'|| l_progress, 1);
        print_debug('l_lot_rec.CREATED_BY:'|| l_lot_rec.CREATED_BY||':'|| l_progress, 1);
        print_debug('l_lot_rec.LAST_UPDATE_LOGIN:'||l_lot_rec.LAST_UPDATE_LOGIN ||':'|| l_progress, 1);
        print_debug('l_lot_rec.EXPIRATION_DATE:'|| l_lot_rec.EXPIRATION_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.ATTRIBUTE_CATEGORY:'|| l_lot_rec.ATTRIBUTE_CATEGORY ||':'|| l_progress, 1);
        print_debug('l_lot_rec.REQUEST_ID:'|| l_lot_rec.REQUEST_ID||':'|| l_progress, 1);
        print_debug('l_lot_rec.PROGRAM_APPLICATION_ID:'|| l_lot_rec.PROGRAM_APPLICATION_ID ||':'|| l_progress, 1);
        print_debug('l_lot_rec.PROGRAM_ID:'||  l_lot_rec.PROGRAM_ID ||':'|| l_progress, 1);
        print_debug('l_lot_rec.PROGRAM_UPDATE_DATE:'|| l_lot_rec.PROGRAM_UPDATE_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.DESCRIPTION:'|| l_lot_rec.DESCRIPTION ||':'|| l_progress, 1);
        print_debug('l_lot_rec.VENDOR_NAME:'|| l_lot_rec.VENDOR_NAME ||':'|| l_progress, 1);
        print_debug('l_lot_rec.SUPPLIER_LOT_NUMBER :'|| l_lot_rec.SUPPLIER_LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('l_lot_rec.GRADE_CODE:'|| l_lot_rec.GRADE_CODE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.ORIGINATION_DATE:'|| l_lot_rec.ORIGINATION_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.DATE_CODE:'|| l_lot_rec.DATE_CODE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.STATUS_ID :'|| l_lot_rec.STATUS_ID ||':'|| l_progress, 1);
        print_debug('l_lot_rec.CHANGE_DATE :'|| l_lot_rec.CHANGE_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.AGE:'|| l_lot_rec.AGE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.RETEST_DATE :'|| l_lot_rec.RETEST_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.MATURITY_DATE :'|| l_lot_rec.MATURITY_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.LOT_ATTRIBUTE_CATEGORY:'|| l_lot_rec.LOT_ATTRIBUTE_CATEGORY ||':'|| l_progress, 1);
        print_debug('l_lot_rec.ITEM_SIZE :'|| l_lot_rec.ITEM_SIZE  ||':'|| l_progress, 1);
        print_debug('l_lot_rec.COLOR :'|| l_lot_rec.COLOR ||':'|| l_progress, 1);
        print_debug('l_lot_rec.VOLUME :'|| l_lot_rec.VOLUME ||':'|| l_progress, 1);
        print_debug('l_lot_rec.VOLUME_UOM :'|| l_lot_rec.VOLUME_UOM ||':'|| l_progress, 1);
        print_debug('l_lot_rec.PLACE_OF_ORIGIN :'|| l_lot_rec.PLACE_OF_ORIGIN ||':'|| l_progress, 1);
        print_debug('l_lot_rec.BEST_BY_DATE :'|| l_lot_rec.BEST_BY_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.LENGTH :'|| l_lot_rec.LENGTH ||':'|| l_progress, 1);
        print_debug('l_lot_rec.LENGTH_UOM :'|| l_lot_rec.LENGTH_UOM ||':'|| l_progress, 1);
        print_debug('l_lot_rec.RECYCLED_CONTENT:'|| l_lot_rec.RECYCLED_CONTENT ||':'|| l_progress, 1);
        print_debug('l_lot_rec.THICKNESS :'|| l_lot_rec.THICKNESS ||':'|| l_progress, 1);
        print_debug('l_lot_rec.THICKNESS_UOM :'|| l_lot_rec.THICKNESS_UOM ||':'|| l_progress, 1);
        print_debug('l_lot_rec.WIDTH:'|| l_lot_rec.WIDTH ||':'|| l_progress, 1);
        print_debug('l_lot_rec.WIDTH_UOM :'||  l_lot_rec.WIDTH_UOM ||':'|| l_progress, 1);
        print_debug('l_lot_rec.CURL_WRINKLE_FOLD :'||l_lot_rec.CURL_WRINKLE_FOLD ||':'|| l_progress, 1);
        print_debug('l_lot_rec.VENDOR_ID:'||l_lot_rec.VENDOR_ID ||':'|| l_progress, 1);
        print_debug('l_lot_rec.TERRITORY_CODE :'|| l_lot_rec.TERRITORY_CODE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.ORIGINATION_TYPE :'|| l_lot_rec.ORIGINATION_TYPE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.EXPIRATION_ACTION_DATE:'|| l_lot_rec.EXPIRATION_ACTION_DATE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.EXPIRATION_ACTION_CODE:'|| l_lot_rec.EXPIRATION_ACTION_CODE ||':'|| l_progress, 1);
        print_debug('l_lot_rec.HOLD_DATE :'||l_lot_rec.HOLD_DATE ||':'|| l_progress, 1);
     END IF;

     l_progress := '271';

     /* Call Lot Create API INV_LOT_API_PUB.CREATE_INV_LOT to create the new lot.
      This shall also validate the attributes before creating the new Lot. */

     inv_lot_api_pub.Create_Inv_lot(
                                   x_return_status         	      => l_return_status            ,
                                   x_msg_count             	      => l_msg_count                ,
                                   x_msg_data             	      => l_msg_data                 ,
                                   x_row_id                       => l_row_id                   ,
                                   x_lot_rec       	            => x_lot_rec                  ,
                                   p_lot_rec                      => l_lot_rec                  ,
                                   p_source                       => l_source                    ,
                                   p_api_version                  => l_api_version              ,
                                   p_init_msg_list                => fnd_api.g_false            ,
                                   p_commit                       => fnd_api.g_false            ,
                                   p_validation_level             => fnd_api.g_valid_level_full ,
                                   p_origin_txn_id                => p_to_organization_id
                                   );
     l_progress := '272';

     IF g_debug = 1 THEN
        print_debug('Program inv_lot_api_pub.Create_Inv_lot return ' || l_return_status || ':' || l_progress, 1);
        print_debug('Printing the values of x_lot_rec after calling inv_lot_api_pub.Create_Inv_lot '|| l_progress, 1);
        print_debug('x_lot_rec.INVENTORY_ITEM_ID: '|| x_lot_rec.INVENTORY_ITEM_ID||':'||l_progress, 1);
        print_debug('x_lot_rec.ORGANIZATION_ID '|| x_lot_rec.ORGANIZATION_ID||':'||l_progress, 1);
        print_debug('x_lot_rec.LOT_NUMBER :'|| x_lot_rec.LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('x_lot_rec.LAST_UPDATE_DATE:'|| x_lot_rec.LAST_UPDATE_DATE||':'|| l_progress, 1);
        print_debug('x_lot_rec.LAST_UPDATED_BY:'|| x_lot_rec.LAST_UPDATED_BY||':'|| l_progress, 1);
        print_debug('x_lot_rec.CREATION_DATE:'|| x_lot_rec.CREATION_DATE||':'|| l_progress, 1);
        print_debug('x_lot_rec.CREATED_BY:'|| x_lot_rec.CREATED_BY||':'|| l_progress, 1);
        print_debug('x_lot_rec.LAST_UPDATE_LOGIN:'||x_lot_rec.LAST_UPDATE_LOGIN ||':'|| l_progress, 1);
        print_debug('x_lot_rec.EXPIRATION_DATE:'|| x_lot_rec.EXPIRATION_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.ATTRIBUTE_CATEGORY:'|| x_lot_rec.ATTRIBUTE_CATEGORY ||':'|| l_progress, 1);
        print_debug('x_lot_rec.REQUEST_ID:'|| x_lot_rec.REQUEST_ID||':'|| l_progress, 1);
        print_debug('x_lot_rec.PROGRAM_APPLICATION_ID:'|| x_lot_rec.PROGRAM_APPLICATION_ID ||':'|| l_progress, 1);
        print_debug('x_lot_rec.PROGRAM_ID:'||  x_lot_rec.PROGRAM_ID ||':'|| l_progress, 1);
        print_debug('x_lot_rec.PROGRAM_UPDATE_DATE:'|| x_lot_rec.PROGRAM_UPDATE_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.DESCRIPTION:'|| x_lot_rec.DESCRIPTION ||':'|| l_progress, 1);
        print_debug('x_lot_rec.VENDOR_NAME:'|| x_lot_rec.VENDOR_NAME ||':'|| l_progress, 1);
        print_debug('x_lot_rec.SUPPLIER_LOT_NUMBER :'|| x_lot_rec.SUPPLIER_LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('x_lot_rec.GRADE_CODE:'|| x_lot_rec.GRADE_CODE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.ORIGINATION_DATE:'|| x_lot_rec.ORIGINATION_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.DATE_CODE:'|| x_lot_rec.DATE_CODE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.STATUS_ID :'|| x_lot_rec.STATUS_ID ||':'|| l_progress, 1);
        print_debug('x_lot_rec.CHANGE_DATE :'|| x_lot_rec.CHANGE_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.AGE:'|| x_lot_rec.AGE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.RETEST_DATE :'|| x_lot_rec.RETEST_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.MATURITY_DATE :'|| x_lot_rec.MATURITY_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.LOT_ATTRIBUTE_CATEGORY:'|| x_lot_rec.LOT_ATTRIBUTE_CATEGORY ||':'|| l_progress, 1);
        print_debug('x_lot_rec.ITEM_SIZE :'|| x_lot_rec.ITEM_SIZE  ||':'|| l_progress, 1);
        print_debug('x_lot_rec.COLOR :'|| x_lot_rec.COLOR ||':'|| l_progress, 1);
        print_debug('x_lot_rec.VOLUME :'|| x_lot_rec.VOLUME ||':'|| l_progress, 1);
        print_debug('x_lot_rec.VOLUME_UOM :'|| x_lot_rec.VOLUME_UOM ||':'|| l_progress, 1);
        print_debug('x_lot_rec.PLACE_OF_ORIGIN :'|| x_lot_rec.PLACE_OF_ORIGIN ||':'|| l_progress, 1);
        print_debug('x_lot_rec.BEST_BY_DATE :'|| x_lot_rec.BEST_BY_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.LENGTH :'|| x_lot_rec.LENGTH ||':'|| l_progress, 1);
        print_debug('x_lot_rec.LENGTH_UOM :'|| x_lot_rec.LENGTH_UOM ||':'|| l_progress, 1);
        print_debug('x_lot_rec.RECYCLED_CONTENT:'|| x_lot_rec.RECYCLED_CONTENT ||':'|| l_progress, 1);
        print_debug('x_lot_rec.THICKNESS :'|| x_lot_rec.THICKNESS ||':'|| l_progress, 1);
        print_debug('x_lot_rec.THICKNESS_UOM :'|| x_lot_rec.THICKNESS_UOM ||':'|| l_progress, 1);
        print_debug('x_lot_rec.WIDTH:'|| x_lot_rec.WIDTH ||':'|| l_progress, 1);
        print_debug('x_lot_rec.WIDTH_UOM :'||  x_lot_rec.WIDTH_UOM ||':'|| l_progress, 1);
        print_debug('x_lot_rec.CURL_WRINKLE_FOLD :'||x_lot_rec.CURL_WRINKLE_FOLD ||':'|| l_progress, 1);
        print_debug('x_lot_rec.VENDOR_ID:'||x_lot_rec.VENDOR_ID ||':'|| l_progress, 1);
        print_debug('x_lot_rec.TERRITORY_CODE :'|| x_lot_rec.TERRITORY_CODE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.PARENT_LOT_NUMBER :'|| x_lot_rec.PARENT_LOT_NUMBER ||':'|| l_progress, 1);
        print_debug('x_lot_rec.ORIGINATION_TYPE :'|| x_lot_rec.ORIGINATION_TYPE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.EXPIRATION_ACTION_DATE:'|| x_lot_rec.EXPIRATION_ACTION_DATE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.EXPIRATION_ACTION_CODE:'|| x_lot_rec.EXPIRATION_ACTION_CODE ||':'|| l_progress, 1);
        print_debug('x_lot_rec.HOLD_DATE :'||x_lot_rec.HOLD_DATE ||':'|| l_progress, 1);
     END IF;

     IF l_return_status = fnd_api.g_ret_sts_error THEN
        IF g_debug = 1 THEN
           print_debug('Program inv_lot_api_pub.Create_Inv_lot has failed with a user defined exception : ' || l_progress, 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
        FND_MESSAGE.SET_TOKEN('PGM_NAME','inv_lot_api_pub.Create_Inv_lot');
        fnd_msg_pub.ADD;
        RAISE g_exc_error;

        l_progress  := '028' ;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        IF g_debug = 1 THEN
           print_debug('Program inv_lot_api_pub.Create_Inv_lot has failed with a Unexpected exception :'|| l_progress, 9);
        END IF;
        FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
        FND_MESSAGE.SET_TOKEN('PGM_NAME','inv_lot_api_pub.Create_Inv_lot');
        fnd_msg_pub.ADD;
        RAISE g_exc_unexpected_error;
     END IF;

     l_progress := '029';

     ----Update MTLT with the out record type parameter x_lot_rec
    BEGIN

    UPDATE mtl_transaction_lots_temp
       SET
       lot_expiration_date          = x_lot_rec.expiration_date               ,
       attribute_category           = x_lot_rec.attribute_category            ,
       lot_attribute_category       = x_lot_rec.lot_attribute_category        ,
       grade_code                   = x_lot_rec.grade_code                    ,
       origination_date             = x_lot_rec.origination_date              ,
       date_code                    = x_lot_rec.date_code                     ,
       status_id                    = x_lot_rec.status_id                     ,
       change_date                  = x_lot_rec.change_date                   ,
       age                          = x_lot_rec.age                           ,
       retest_date                  = x_lot_rec.retest_date                   ,
       maturity_date                = x_lot_rec.maturity_date                 ,
       item_size                    = x_lot_rec.item_size                     ,
       color                        = x_lot_rec.color                         ,
       volume                       = x_lot_rec.volume                        ,
       volume_uom                   = x_lot_rec.volume_uom                    ,
       place_of_origin              = x_lot_rec.place_of_origin               ,
       best_by_date                 = x_lot_rec.best_by_date                  ,
       LENGTH                       = x_lot_rec.LENGTH                        ,
       length_uom                   = x_lot_rec.length_uom                    ,
       recycled_content             = x_lot_rec.recycled_content              ,
       thickness                    = x_lot_rec.thickness                     ,
       thickness_uom                = x_lot_rec.thickness_uom                 ,
       width                        = x_lot_rec.width                         ,
       width_uom                    = x_lot_rec.width_uom                     ,
       territory_code               = x_lot_rec.territory_code                ,
       supplier_lot_number          = x_lot_rec.supplier_lot_number           ,
       vendor_name                  = x_lot_rec.vendor_name                   ,
       creation_date                = SYSDATE                                 ,
       created_by                   = x_lot_rec.created_by                    ,
       last_update_date             = SYSDATE                                 ,
       last_updated_by              = x_lot_rec.last_updated_by               ,
       parent_lot_number            = x_lot_rec.parent_lot_number             ,
       origination_type             = x_lot_rec.origination_type              ,
       expiration_action_code       = x_lot_rec.expiration_action_code        ,
       expiration_action_date       = x_lot_rec.expiration_action_date        ,
       hold_date                    = x_lot_rec.hold_date                     ,
       DESCRIPTION                  = x_lot_rec.DESCRIPTION                   ,
       CURL_WRINKLE_FOLD            = x_lot_rec.CURL_WRINKLE_FOLD             ,
       VENDOR_ID                    = x_lot_rec.VENDOR_ID

       WHERE ROWID = p_mtlt_rowid ;

       /*
       Case 1: lot has parent lot:-
               a) Diffrent parent lots in an organization can have the same child lot depending
                  upon the organization_parameter.
               b) For a single transaction with multiple lots,rows in MTLT have the same
                  product_transaction_id.
               c) Same lot-parent_lot combination can be repeated in a transaction.

               Hence there can be multiple rows in MTLT with the same lot_number and
               product_transaction_id.

       Case 2: lot doesn't have a parent lot.
               a) Same lot can be repeated in a transaction.
               b) For a single transaction with multiple lots,rows in MTLT have the same
                  product_transaction_id.
               Hence there can be multiple rows in MTLT with the same lot_number and
               product_transaction_id.

        Hence we cannot have the combination of lot_number and product_transaction_id to uniqely
         identify the row of MTLT for updation.
         So we use MTLT.rowid in the where clause above.
       */

       l_progress := '030';

       IF g_debug = 1 THEN
          print_debug('Update MTLT with the out record type parameter x_lot_rec:' || l_progress, 1);
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
          IF g_debug = 1 THEN
             print_debug('Updating MTLT with x_lot_rec(inv_lot_api_pub.Create_Inv_lot) has failed with a Unexpected exception in INV_ROI_INTEGRATION_GRP.INV_NEW_LOT :'|| l_progress, 1);
          END IF;
          RAISE g_exc_unexpected_error;
    END;

    --------The records from mtl_transaction_lots_temp  finally enter mtl_lot_transactions.
    l_progress := '031';

    -------Create Lot specific conversion

    IF g_debug = 1 THEN
       print_debug('p_line_secondary_quantity:' || p_line_secondary_quantity, 1);
       print_debug('P_PRIMARY_UNIT_OF_MEASURE:' || P_PRIMARY_UNIT_OF_MEASURE, 1);
       print_debug('P_SECONDARY_UNIT_OF_MEASURE:' || P_SECONDARY_UNIT_OF_MEASURE, 1);
    END IF;


	 /* Check to see if the item is dual UOM controlled */



	 --IF p_line_secondary_quantity > 0 AND p_secondary_unit_of_measure IS NOT NULL THEN
     IF nvl(p_line_secondary_quantity,0) <> 0 AND p_secondary_unit_of_measure IS NOT NULL THEN  -- 7644869   change check as qty could be negative

       IF P_PRIMARY_UNIT_OF_MEASURE IS NOT NULL AND P_SECONDARY_UNIT_OF_MEASURE IS NOT NULL THEN

          /*For new lots, lot specific conversion may be created depending upon the
          permission parameter value.
          Fetch permission parameter value from organization parameter for
          creating  lot specfic conversion.
          */

          l_progress := '032';


            SELECT CREATE_LOT_UOM_CONVERSION
               INTO l_permission_value
               FROM mtl_parameters
               WHERE Organization_id = p_to_organization_id;


          /*The values can be as follows:
          Yes -  1
          No -  2
          User Controlled - 3
          ('User Controlled' will give a message to the user to confirm the creation
          of a lot specific UOM ( For ROI this will behave as 'Yes') )
          */

          IF g_debug = 1 THEN
             print_debug('permission parameter CREATE_LOT_UOM_CONVERSION value from organization parameter for
                  creating  lot specfic conversion:' || l_permission_value||':'||l_progress, 1);
          END IF;

          IF l_permission_value IS NULL THEN
             IF g_debug = 1 THEN
                print_debug('l_permission_value is NULL, value =  :' ||l_permission_value , 1);
                print_debug('defaulting l_permission_value to 1 :', 1);
             END IF;
             l_permission_value :=1;
          END IF;

          IF l_permission_value <> 2 THEN

             /* Creating lot specific conversion between Primary and Secondary UOM*/

               --fetch the uom classes for primary and secondary unit_of_measures
                SELECT distinct(uom_class)
                   INTO l_primary_uom_class
                   FROM MTL_UNITS_OF_MEASURE
                   WHERE unit_of_measure = P_PRIMARY_UNIT_OF_MEASURE;

                SELECT distinct(uom_class)
                   INTO l_secondary_uom_class
                   FROM MTL_UNITS_OF_MEASURE
                   WHERE unit_of_measure = p_secondary_unit_of_measure;

                /*Check whether the unit of measure conversion is not fixed in the destination org.
                  Fetch the SECONDARY_DEFAULT_IND from mtl_system_items_b. */

                SELECT secondary_default_ind
                   INTO l_secondary_default_ind
                   FROM mtl_system_items_b
                   WHERE inventory_item_id =p_item_id
                   AND organization_id =p_to_organization_id;

                /* The values are D => default
                                  F => Fixed
                                  N => Not Fixed
                */
                l_progress :='033';

                IF g_debug = 1 THEN
                   print_debug('uom classes for primary and secondary unit_of_measures
                               and SECONDARY_DEFAULT_IND from mtl_system_items_b are:'|| l_primary_uom_class ||':'||l_secondary_uom_class ||':'||l_secondary_default_ind ||':'||l_progress, 1);
                END IF;

                /* Check whether UOM class are different and the dual uom is not of fixed type. */
                IF (l_primary_uom_class <> l_secondary_uom_class) AND (l_secondary_default_ind  <>'F') THEN

                   l_progress := '034';
                   --SAVEPOINT inv_new_lot_save6;

                   /* Populate p_lot_uom_conv_rec record type variable as follows:-
                   All these parameters are to be used in the series of API calls
                   starting MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion */

                   p_lot_uom_conv_rec.LOT_NUMBER             	:= P_LOT_NUMBER                      ;
                   p_lot_uom_conv_rec.ORGANIZATION_ID          := P_TO_ORGANIZATION_ID              ;
                   p_lot_uom_conv_rec.INVENTORY_ITEM_ID        := P_item_id                         ;
                   p_lot_uom_conv_rec.FROM_UNIT_OF_MEASURE     := p_primary_unit_of_measure         ;
                   p_lot_uom_conv_rec.FROM_UOM_CODE            := p_UOM_CODE                        ;
                   p_lot_uom_conv_rec.FROM_UOM_CLASS           := l_primary_uom_class               ;
                   p_lot_uom_conv_rec.TO_UNIT_OF_MEASURE       := p_secondary_unit_of_measure       ;
                   p_lot_uom_conv_rec.TO_UOM_CODE              := p_SECONDARY_UOM_CODE              ;
                   p_lot_uom_conv_rec.TO_UOM_CLASS             := l_secondary_uom_class             ;
                   p_lot_uom_conv_rec.disable_date             := NULL                              ;
                   p_lot_uom_conv_rec.conversion_id            := NULL                              ;
                   p_lot_uom_conv_rec.event_spec_disp_id       := NULL                              ;
                   p_lot_uom_conv_rec.created_by               := fnd_global.user_id                ;
                   p_lot_uom_conv_rec.creation_date            := SYSDATE                           ;
                   p_lot_uom_conv_rec.last_updated_by          := fnd_global.user_id                ;
                   p_lot_uom_conv_rec.last_update_date         := SYSDATE                           ;
                   p_lot_uom_conv_rec.last_update_login        := fnd_global.login_id               ;
                   p_lot_uom_conv_rec.request_id               := NULL                              ;
                   p_lot_uom_conv_rec.program_application_id   := NULL                              ;
                   p_lot_uom_conv_rec.program_id               := NULL                              ;
                   p_lot_uom_conv_rec.program_update_date      := NULL                              ;

                   /* In some cases (where 'NULL' is passed above, we won't populate any of the above
                   parameters with actual values. Conversion_id will actually be returned to us.
                   The others are for very specific cases that we won't hit in this context.
                   We may just want to call the public version of the API because it handles
                   all of these situations and will do the appropriate business rule validations.*/

                   /* Fetching the conversion rate */
                   /*
                   INV_CONVERT.inv_um_conversion(
                                                 from_unit            =>p_lot_uom_conv_rec.FROM_UOM_CODE,
                                                 to_unit              =>p_lot_uom_conv_rec.TO_UOM_CODE,
                                                 item_id              =>p_lot_uom_conv_rec.INVENTORY_ITEM_ID,
                                                 lot_number           =>p_lot_uom_conv_rec.LOT_NUMBER,
                                                 organization_id      =>p_lot_uom_conv_rec.ORGANIZATION_ID,
                                                 uom_rate             =>p_lot_uom_conv_rec.CONVERSION_RATE
                                                 );
                   */
                   /* Calculating the conversion rate by dividing lot secondary quantity with lot transaction
                     quantity to retain teh lot specific conversion rate which might be diffrent from the
                     default conversion rate */

                   p_lot_uom_conv_rec.CONVERSION_RATE := (  p_lot_quantity / p_lot_secondary_quantity ) ;

                   IF g_debug = 1 THEN
                     print_debug('p_lot_secondary_quantity:'||p_lot_secondary_quantity, 1);
                     print_debug('p_lot_quantity:'||p_lot_quantity, 1);
                     print_debug('uom_rate:'||p_lot_uom_conv_rec.CONVERSION_RATE, 1);
                   END IF;

                   IF g_debug = 1 THEN
                      print_debug('Before calling MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion:'||l_progress, 1);
                      print_debug('p_lot_uom_conv_rec.LOT_NUMBER:'||p_lot_uom_conv_rec.LOT_NUMBER, 1);
                      print_debug('p_lot_uom_conv_rec.ORGANIZATION_ID:'||p_lot_uom_conv_rec.ORGANIZATION_ID, 1);
                      print_debug('p_lot_uom_conv_rec.INVENTORY_ITEM_ID:'||p_lot_uom_conv_rec.INVENTORY_ITEM_ID, 1);
                      print_debug('p_lot_uom_conv_rec.FROM_UNIT_OF_MEASURE:'||p_lot_uom_conv_rec.FROM_UNIT_OF_MEASURE, 1);
                      print_debug('p_lot_uom_conv_rec.FROM_UOM_CODE:'||p_lot_uom_conv_rec.FROM_UOM_CODE, 1);
                      print_debug('p_lot_uom_conv_rec.FROM_UOM_CLASS:'||p_lot_uom_conv_rec.FROM_UOM_CLASS, 1);
                      print_debug('p_lot_uom_conv_rec.TO_UNIT_OF_MEASURE:'||p_lot_uom_conv_rec.TO_UNIT_OF_MEASURE, 1);
                      print_debug('p_lot_uom_conv_rec.TO_UOM_CODE:'||p_lot_uom_conv_rec.TO_UOM_CODE, 1);
                      print_debug('p_lot_uom_conv_rec.TO_UOM_CLASS:'||p_lot_uom_conv_rec.TO_UOM_CLASS, 1);
                      print_debug('p_lot_uom_conv_rec.CONVERSION_RATE:'||p_lot_uom_conv_rec.CONVERSION_RATE, 1);
                      print_debug('p_lot_uom_conv_rec.disable_date:'||p_lot_uom_conv_rec.disable_date, 1);
                      print_debug('p_lot_uom_conv_rec.conversion_id:'||p_lot_uom_conv_rec.conversion_id, 1);
                      print_debug('p_lot_uom_conv_rec.event_spec_disp_id:'||p_lot_uom_conv_rec.event_spec_disp_id, 1);
                      print_debug('p_lot_uom_conv_rec.created_by:'||p_lot_uom_conv_rec.created_by, 1);
                      print_debug('p_lot_uom_conv_rec.creation_date:'||p_lot_uom_conv_rec.creation_date, 1);
                      print_debug('p_lot_uom_conv_rec.last_updated_by:'||p_lot_uom_conv_rec.last_updated_by, 1);
                      print_debug('p_lot_uom_conv_rec.last_update_date:'||p_lot_uom_conv_rec.last_update_date, 1);
                      print_debug('p_lot_uom_conv_rec.last_update_login:'||p_lot_uom_conv_rec.last_update_login, 1);
                      print_debug('p_lot_uom_conv_rec.request_id:'||p_lot_uom_conv_rec.request_id, 1);
                      print_debug('p_lot_uom_conv_rec.program_application_id:'||p_lot_uom_conv_rec.program_application_id, 1);
                      print_debug('p_lot_uom_conv_rec.program_id :'|| p_lot_uom_conv_rec.program_id , 1);
                      print_debug('p_lot_uom_conv_rec.program_update_date:'||p_lot_uom_conv_rec.program_update_date, 1);
                      print_debug('p_reason_id:'||p_reason_id, 1);
                      --------print_debug('l_qty_update_tbl:'||l_qty_update_tbl, 1);
                   END IF;


                   MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion(
                                                                  p_api_version            =>1.0                                                              ,
                                                                  p_init_msg_list          =>FND_API.G_FALSE	                                               ,
                                                                  p_commit                 =>FND_API.G_TRUE	                                                  ,
                                                                  p_validation_level       =>FND_API.G_VALID_LEVEL_FULL                                       ,
                                                                  p_action_type            =>'I' /*Database action type ('I' for insert or 'U' for update)*/  ,
                                                                  p_update_type_indicator	 =>5                                                                ,
                                                                  p_reason_id              =>p_reason_id                                                      ,
                                                                  p_batch_id               =>NULL /*(Since we are not updating batch quantities)*/            ,
                                                                  p_process_data           =>'Y', -- Bug 4019726 FND_API.G_TRUE                                                   ,
                                                                  p_lot_uom_conv_rec       =>p_lot_uom_conv_rec                                               ,
                                                                  p_qty_update_tbl         =>l_qty_update_tbl                                                 ,
                                                                  x_return_status          =>l_return_status                                                  ,
                                                                  x_msg_count              =>l_msg_count                                                      ,
                                                                  x_msg_data             	 =>l_msg_data                                                       ,
                                                                  x_sequence               =>l_sequence
                                                                  );

                   /*  p_update_type_indicator  Indicates if there is a quantity change associated with the lot uom conversion change and if so,
                   what kind of change
                   (0 for Update On-Hand Balances,
                   1 for Recalculate Batch Primary Quantity,
                   2  for Recalculate Batch Secondary Quantity,
                   3 for Recalculate On-Hand Primary Quantity,
                   4 for Recalculate On-Hand Secondary Quantity,
                   5 for No Quantity Updates)
                   */

                l_progress := '035';

                IF g_debug = 1 THEN
                   print_debug('Program MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion return :' ||l_progress ||':'|| l_return_status, 1);
                   print_debug('x_return_status:'||l_return_status, 1);
                   print_debug('x_msg_count:'||l_msg_count, 1);
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_error THEN
                   IF g_debug = 1 THEN
                      print_debug('Program MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion has failed with a user defined exception:'||l_progress, 1);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion');
                   fnd_msg_pub.ADD;
                   RAISE g_exc_error;

                l_progress := '036';

                ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   IF g_debug = 1 THEN
                      print_debug('Program MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion has failed with a Unexpected exception :'|| l_progress, 9);
                   END IF;
                   FND_MESSAGE.SET_NAME('INV','INV_PROGRAM_ERROR');
                   FND_MESSAGE.SET_TOKEN('PGM_NAME','MTL_LOT_UOM_CONV_PUB.create_lot_uom_conversion');
                   fnd_msg_pub.ADD;
                   RAISE g_exc_unexpected_error;
                END IF;


             END IF;------- If l_primary_uom_class <> l_secondary_uom_class THEN
		    END IF;------------IF l_permision_value = 'Y'  THEN
       END IF;-----IF P_PRIMARY_UNIT_OF_MEASURE IS NOT NULL AND
    END IF;-------------- If  p_line_secondary_quantity IS NOT NULL THEN

    print_debug('End of the program inv_roi_integration_grp.inv_new_lot. Program has completed successfully: '|| l_progress, 9);

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        /*
        IF l_progress = '002' THEN
           ROLLBACK TO inv_new_lot_save2;
        ELSIF l_progress = '006' THEN
           ROLLBACK TO inv_new_lot_save6;
        END IF;
        */
        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count     ,
                                         FND_API.G_FALSE
                                         );
        END IF ;
        IF g_debug = 1 THEN
     print_debug('Exitting INV_NEW_LOT - No data found error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN g_exc_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        /*
        IF l_progress = '002' THEN
           ROLLBACK TO inv_new_lot_save2;
        ELSIF l_progress = '006' THEN
           ROLLBACK TO inv_new_lot_save6;
        END IF;
        */
        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count     ,
                                         FND_API.G_FALSE
                                         );
        END IF;

        IF g_debug = 1 THEN
           print_debug('Exitting INV_NEW_LOT - g_exc_error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        /*
        IF l_progress = '002' THEN
           ROLLBACK TO inv_new_lot_save2;
        ELSIF l_progress = '006' THEN
           ROLLBACK TO inv_new_lot_save6;
        END IF;
        */
        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count        ,
                                         FND_API.G_FALSE);
        END IF ;

        IF g_debug = 1 THEN
           print_debug('Exitting INV_NEW_LOT - g_exc_unexpected_error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;
        /*
        IF l_progress = '002' THEN
           ROLLBACK TO inv_new_lot_save2;
        ELSIF l_progress = '006' THEN
           ROLLBACK TO inv_new_lot_save6;
        END IF;
        */
        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count        ,
                                         FND_API.G_FALSE);
        END IF;

        IF g_debug = 1 THEN
           print_debug('Exitting INV_NEW_LOT - OTHERS error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;



  END INV_New_lot;


   /*##########################################################################
  #
  #  PROCEDURE  INV_Synch_Quantities
  #
  #  DESCRIPTION  :-
  #
  #     1) For lot controlled items if the receiving UOM class is different from
  #         the Source Doc (PO) uom class then loop through each record in MTLT and
  #         convert  the lot transaction(primary) quantity of each lot record in
  #         Receiving unit of measure to source doc (Purchasing) unit of measure
  #         taking lot specific conversion into consideration.
  #         Sum it up and update the Source Doc primary quantity with this.
  #
  #     2) For lot controlled and dual uom controlled items ,loop through each
  #        record in MTLT and sum the lot_secondary_quantity and update the
  #        secondary receipt line quantity with this.
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  # MODIFICATION HISTORY
  # 13-SEP-2004  Punit Kumar 	Created
  #
  #########################################################################*/


  PROCEDURE INV_Synch_Quantities(
                                         x_return_status      		      OUT NOCOPY VARCHAR2              ,
                                         x_msg_data           		      OUT NOCOPY VARCHAR2              ,
                                         x_msg_count          		      OUT NOCOPY NUMBER                ,
                                         x_sum_sourcedoc_quantity	      OUT NOCOPY NUMBER                ,
                                         x_sum_rti_secondary_quantity   OUT NOCOPY NUMBER                ,
                                         p_api_version	 		         IN  NUMBER DEFAULT 1.0           ,
                                         p_init_msg_lst	 		         IN  VARCHAR2 := FND_API.G_FALSE  ,
                                         p_inventory_item_id    		   IN  NUMBER                       ,
                                         p_to_organization_id		      IN  NUMBER                       ,
                                         p_lot_number  			         IN  VARCHAR2                     ,
                                         p_transaction_unit_of_measure	IN  VARCHAR2                     ,
                                         p_sourcedoc_unit_of_meaure     IN  VARCHAR2                     ,
                                         p_lot_quantity   			      IN  NUMBER                       ,
                                         p_line_secondary_quantity      IN  NUMBER                       ,
                                         p_secondary_unit_of_measure    IN  VARCHAR2                     ,
                                         p_lot_secondary_quantity       IN  NUMBER
                                         )

     IS

     /*local variables declaration*/
     l_api_name                     VARCHAR2(30) := 'INV_Synch_Quantities';
     l_api_version                  CONSTANT NUMBER := 1.0;
     l_recv_uom_class               VARCHAR2(10);
     l_sourcedoc_uom_class          VARCHAR2(10);
     l_rti_sourcedoc_quantity       NUMBER  :=0 ;
     l_sum_sourcedoc_quantity       NUMBER  :=0 ;
     l_sum_rti_secondary_quantity   NUMBER  :=0 ;


  BEGIN

     l_progress :='037';

      -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       'INV_ROI_INTEGRATION_GRP'
                                       ) THEN
       IF (g_debug = 1) THEN
          print_debug('FND_API not compatible INV_ROI_INTEGRATION_GRP.INV_Synch_Quantities:' || l_progress, 1);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_lst) THEN
       fnd_msg_pub.initialize;
    END IF;

    --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN
      l_progress :='038';

   /*Updating source doc quantity*/

      SELECT distinct(uom_class)
         INTO l_recv_uom_class
         FROM MTL_UNITS_OF_MEASURE
         WHERE  UNIT_OF_MEASURE = p_transaction_unit_of_measure;

      SELECT distinct(uom_class)
         INTO l_sourcedoc_uom_class
         FROM MTL_UNITS_OF_MEASURE
         WHERE  UNIT_OF_MEASURE = p_sourcedoc_unit_of_meaure;

      IF g_debug = 1 THEN
         print_debug('Inside inv_synch_quantities :' ||l_progress , 1);
         print_debug('l_recv_uom_class :' ||l_recv_uom_class , 1);
         print_debug('l_sourcedoc_uom_class :' ||l_sourcedoc_uom_class , 1);
      END IF;


   EXCEPTION
      WHEN OTHERS THEN
         IF g_debug = 1 THEN
            print_debug('Fetching uom class failed in synch_secondary_quantity:' || l_progress, 1);
         END IF;
         RAISE fnd_api.g_exc_error;
   END;

   l_progress:='039';

      IF l_recv_uom_class <> l_sourcedoc_uom_class THEN
		   /*i.e. Receiving UOM and Source Doc (Purchasing)
            unit of measures belong to different UOM classes then,
            for each record of MTLT for that item...... */

         /* Convert  p_mtlt_transaction_quantity  (MTLT.TRANSACTION_QUANTITY)
           in p_rti_unit_of_measure  (RTI.UNIT_OF_MEASURE )for each lot of that item into
           RTI.SOURCE_DOC_UNIT_OF_MEASURE  taking lot specific conversion into consideration */


         l_rti_sourcedoc_quantity :=  INV_CONVERT.inv_um_convert(
                                                                item_id  		   => p_inventory_item_id                ,
                                                                lot_number 	   => p_lot_number                       ,
                                                                organization_id	=> p_to_organization_id	              ,
                                                                precision	      => 5                                  ,
                                                                from_quantity    => p_lot_quantity                     ,
                                                                from_unit	      => NULL                               ,
                                                                to_unit   		   => NULL                               ,
                                                                from_name        => p_transaction_unit_of_measure      ,
                                                                to_name          => p_sourcedoc_unit_of_meaure
                                                                );

         l_progress :='040';

         IF g_debug = 1 THEN
            print_debug('Program INV_CONVERT.inv_um_convert return :' ||l_progress , 1);
            print_debug('l_rti_sourcedoc_quantity :' ||l_rti_sourcedoc_quantity , 1);
         END IF;

         IF l_rti_sourcedoc_quantity = -99999 THEN
            IF g_debug = 1 THEN
               print_debug('INV_CONVERT.inv_um_convert has failed in inv_synch_quantities:'|| l_progress, 1);
            END IF;
            FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
            FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
            fnd_msg_pub.ADD;
            RAISE g_exc_unexpected_error;
         END IF;

         l_progress :='041';

         /*This procedure is called in a loop. So using x_sum_rti_secondary_quantity and
          x_sum_sourcedoc_quantity instead of the corresponding local variables as the
          local variables aer initialized to 0 and the sum will repeatedly get initialised to 0
          due to multiple calls in the loop*/

         x_sum_sourcedoc_quantity := nvl(x_sum_sourcedoc_quantity,0) + nvl(l_rti_sourcedoc_quantity,0);

         /*Logic is to get the sum of above quantity here in this procedure and update RTI
           at the the end of validate_lot_serial_info  (where the loop for all MTLT lots ends).*/

         IF g_debug = 1 THEN
            print_debug('x_sum_sourcedoc_quantity :' ||x_sum_sourcedoc_quantity , 1);
         END IF;

      END IF; /*IF l_recv_uom_class <> l_sourcedoc_uom_class THEN */

      /*Updating Secondary Quantity in Receipt line*/


         --IF p_line_secondary_quantity > 0 AND p_secondary_unit_of_measure IS NOT NULL THEN
           IF nvl(p_line_secondary_quantity,0) <> 0 AND p_secondary_unit_of_measure IS NOT NULL THEN  -- 7644869   change check as qty could be negative

            l_progress :='042';

            IF g_debug = 1 THEN
               print_debug('p_lot_secondary_quantity :' ||p_lot_secondary_quantity , 1);
               print_debug('x_sum_rti_secondary_quantity :' ||x_sum_rti_secondary_quantity , 1);
            END IF;


            x_sum_rti_secondary_quantity :=  nvl(x_sum_rti_secondary_quantity,0)  + nvl(p_lot_secondary_quantity,0) ;

            /*Here also logic is to get the sum of above quantity here in this procedure and update
              RTI at the the end of validate_lot_serial_info  (where the loop for all MTLT lots ends).*/

            IF g_debug = 1 THEN
               print_debug('x_sum_rti_secondary_quantity :' ||x_sum_rti_secondary_quantity , 1);
            END IF;

         END IF;
         /*
         x_sum_sourcedoc_quantity := l_sum_sourcedoc_quantity;
         x_sum_rti_secondary_quantity :=l_sum_rti_secondary_quantity;
         */
  EXCEPTION

      WHEN g_exc_unexpected_error THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE
                                          );
         END IF ;

         IF g_debug = 1 THEN
            print_debug('Exitting INV_Synch_Quantities - g_exc_unexpected_error :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            print_stacked_messages;
         END IF;

      WHEN OTHERS THEN
         x_return_status  := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false ,
                                   p_count => x_msg_count       ,
                                   p_data => x_msg_data
                                   );
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(
                                          x_msg_count        ,
                                          FND_API.G_FALSE);
         END IF;

         IF g_debug = 1 THEN
            print_debug('Exitting INV_Synch_Quantities - Others error :'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            print_stacked_messages;
         END IF;


  END INV_Synch_Quantities;





   /*##########################################################################
  #
  #  FUNCTION   inv_rma_lot_info_exists
  #
  #
  #  DESCRIPTION  :- This function checks whether lot exists in the RMA and returns
  #                   'True' or 'False' accordingly.
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  #   MODIFICATION HISTORY
  #   10-AUG-2004  Punit Kumar 	Created
  #
  #########################################################################*/



   FUNCTION inv_rma_lot_info_exists(
                                    x_msg_data              OUT NOCOPY VARCHAR2  ,
                                    x_msg_count          	OUT NOCOPY NUMBER	   ,
                                    x_count_rma_lots    		OUT NOCOPY NUMBER    ,
                                    p_oe_order_header_id 	IN VARCHAR2          ,
                                    p_oe_order_line_id		IN VARCHAR2
                                    )RETURN BOOLEAN IS


      CURSOR Cr_count_lot IS
         SELECT count (*)
            FROM 	oe_lot_serial_numbers
            WHERE	(line_id = p_oe_order_line_id
            OR line_set_id IN
               (SELECT line_set_id
                   FROM oe_order_lines_all
                   WHERE line_id = p_oe_order_line_id
                   AND header_id = p_oe_order_header_id)) ;

   BEGIN
      l_progress := '061';

      IF p_oe_order_line_id IS NOT NULL THEN

         BEGIN
            OPEN  Cr_count_lot;
            FETCH Cr_count_lot
               INTO x_count_rma_lots;
            CLOSE Cr_count_lot;

         EXCEPTION
          WHEN OTHERS THEN
             IF g_debug = 1 THEN
                print_debug('Fetching RMA lot inside inv_roi_integration_grp.inv_rma_lot_info_exists failed:' || l_progress, 1);
             END IF;
             RAISE fnd_api.g_exc_error;
         END;
         l_progress :='062';

         IF  x_count_rma_lots = 0  THEN
            IF g_debug = 1 THEN
                print_debug('lot is not present in RMA so user can receive into any valid lot:'||l_progress, 1);
            END IF;
            RETURN FALSE;
         ELSE  ------- x_count_rma_lots >= 0
            IF g_debug = 1 THEN
                print_debug('inv_rma_lot_info_exists::lot is present in RMA:'|| l_progress, 1);
            END IF;
            RETURN TRUE;
         END IF;
      END IF; -----------IF p_oe_order_line_id IS NOT NULL THEN

   EXCEPTION

      WHEN g_exc_error THEN
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
         END IF ;

         IF g_debug = 1 THEN
            print_debug('Exitting inv_rma_lot_info_exists - g_exc_error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            print_stacked_messages;
         END IF;

         RETURN FALSE;

      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get(
                                   p_encoded => fnd_api.g_false,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);
         IF( x_msg_count > 1 ) THEN
            x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
         END IF ;

         IF g_debug = 1 THEN
            print_debug('Exitting inv_rma_lot_info_exists - OTHERS error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
            print_stacked_messages;
         END IF;
         RETURN FALSE;

   END inv_rma_lot_info_exists;





 /*##########################################################################
  #
  #  PROCEDURE :  Inv_Validate_rma_quantity
  #
  #  DESCRIPTION  : This procedure validates the user entered quantity against the RMA
  #                 quantity ( considering the already received quantity) and returns
  #                 the allowed quantity incase the user quantity exceeds the limit.
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  # MODIFICATION HISTORY
  # 10-AUG-2004  Punit Kumar 	Created
  #
  #########################################################################*/



   PROCEDURE Inv_Validate_rma_quantity(
                                       x_allowed 		         OUT NOCOPY VARCHAR2              ,
                                       x_allowed_quantity 	   OUT NOCOPY NUMBER                ,
                                       x_return_status		   OUT NOCOPY VARCHAR2              ,
                                       x_msg_data           	OUT NOCOPY VARCHAR2              ,
                                       x_msg_count          	OUT NOCOPY NUMBER	               ,
                                       p_api_version	 		   IN  NUMBER DEFAULT 1.0           ,
                                       p_init_msg_list  	      IN  VARCHAR2 := FND_API.G_FALSE  ,
                                       p_item_id  		         IN  NUMBER                       ,
                                       p_lot_number 		      IN	 VARCHAR2                     ,
                                       p_oe_order_header_id 	IN	 NUMBER                       ,
                                       p_oe_order_line_id 		IN	 NUMBER                       ,
                                       p_rma_quantity 		   IN	 NUMBER                       ,
                                       p_trx_unit_of_measure	IN	 VARCHAR2                     ,
                                       p_rti_id		            IN  NUMBER                       ,
                                       p_to_organization_id	   IN	 NUMBER                       ,
                                       p_trx_quantity          IN  NUMBER
                                       )
      IS

      l_api_name                 VARCHAR2(30)      := 'Inv_Validate_rma_quantity'   ;
      l_api_version              CONSTANT NUMBER   := 1.0                           ;
      l_progress		            VARCHAR2(3)       := '000'                         ;
      l_rma_quantity             NUMBER            := 0                             ;
      l_rma_lot_unit_of_measure  VARCHAR2(30)                                       ;
      l_lot_recv_qty             NUMBER            :=0                              ;
      l_line_set_id              NUMBER            :=0                              ;
      l_lot_recv_unit_of_measure VARCHAR2(30)                                       ;
      l_trx_unit_of_measure      VARCHAR2(30)                                       ;
      l_trx_quantity             NUMBER            :=0                              ;
      l_return_status            VARCHAR2(50)                                       ;
      l_precision                NUMBER            := 5                             ;
      l_from_unit                VARCHAR2(3)       := NULL                          ;
      l_to_unit                  VARCHAR2(3)       :=NULL                           ;

         -----fetching the received quantity for that lot if line set id is  not null
      CURSOR Cr_lot_recv_qty_lineset IS
         SELECT SUM(mtln.primary_quantity)
         FROM mtl_material_transactions mmt ,
              mtl_transaction_lot_numbers mtln
         WHERE mmt.trx_source_line_id IN
           (SELECT line_id
               FROM oe_order_lines_all
               WHERE line_set_id = l_line_set_id)
         AND mmt.transaction_source_type_id = 12
         AND mmt.transaction_action_id in (1,27)
         AND mmt.transaction_type_id in (15,36,37)
         AND mmt.inventory_item_id = p_item_id
         AND mmt.organization_id = p_to_organization_id
         AND mtln.TRANSACTION_ID = mmt.transaction_id;


      ------fetching the received quantity for that lot if line set id is null
      CURSOR Cr_lot_recv_qty IS
         SELECT SUM(mtln.primary_quantity)
            FROM mtl_material_transactions mmt ,
                 mtl_transaction_lot_numbers mtln
            WHERE mmt.trx_source_line_id = p_oe_order_line_id
            AND mmt.transaction_source_type_id = 12
            and mmt.transaction_action_id in (1,27)
            and mmt.transaction_type_id in (15,36,37)
            and mmt.inventory_item_id = p_item_id
            and mmt.organization_id = p_to_organization_id
            and mtln.TRANSACTION_ID = mmt.transaction_id;


      /*Fetching the total quantity entered by the user against that RMA
         to be used only for batch/immediate mode
         The below cursor is because the user may receive multiple times into the same lot
         and we need to sum up the quantity of all lots to validate against the actual
         RMA quantity.*/

      CURSOR Cr_user_quantity IS
         SELECT SUM(transaction_quantity)
            FROM mtl_transaction_lots_temp
            WHERE product_code = 'RCV'
               AND product_transaction_id = p_rti_id
               AND lot_number= p_lot_number;

      /*The below cursor willl be used to fetch the RMA quantity for online transactions.*/
      CURSOR Cr_rma_qty_online IS
         SELECT  SUM(QUANTITY)
            FROM  oe_lot_serial_numbers
            WHERE (line_id = p_oe_order_line_id
                  OR line_set_id IN
                  (SELECT line_set_id
                     FROM oe_order_lines_all
                     WHERE line_id = p_oe_order_line_id
                     AND header_id = p_oe_order_header_id))
               AND lot_number = p_lot_number;



   BEGIN
    l_progress :='063';

   -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       'INV_ROI_INTEGRATION_GRP'
                                       ) THEN
       IF (g_debug = 1) THEN
          print_debug('FND_API not compatible INV_ROI_INTEGRATION_GRP.Inv_Validate_rma_quantity:'|| l_progress, 1);
       END IF;
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
       fnd_msg_pub.initialize;
    END IF;

      --Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --SAVEPOINT val_rma_quant1;
    l_progress := '001';
    x_return_status  := g_ret_sts_success;

    --If any of these parameters are NULL nothing can be done so just returns as if successful.
    IF p_item_id              IS NULL OR
       p_oe_order_header_id   IS NULL OR
       p_oe_order_line_id     IS NULL OR
       p_trx_unit_of_measure  IS NULL THEN

       l_progress :='064';

          IF (g_debug = 1) THEN
             print_debug('Exitting Inv_Validate_rma_quantity due to null parameter value:'||l_progress, 1);
             print_debug('Parameter values p_item_id ,p_oe_order_header_id,p_oe_order_line_id and p_trx_unit_of_measure
                          are:' || p_item_id || ':'|| p_oe_order_header_id || ':' ||p_oe_order_line_id || ':'||p_trx_unit_of_measure||':'|| l_progress, 1);
          END IF;
          X_allowed := 'Y';
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          RETURN;

    END IF;

    --- RMA quantity
    IF p_rma_quantity is NULL THEN  -----online mode
       OPEN  Cr_rma_qty_online;
       FETCH Cr_rma_qty_online
          INTO l_rma_quantity;
       CLOSE Cr_rma_qty_online;

       IF g_debug = 1 THEN
          print_debug('RMA quantity fetched for online mode is :'||l_rma_quantity||':'|| l_progress, 1);
       END IF;

    ELSE  ---batch/immediate mode
       l_rma_quantity :=p_rma_quantity;

       IF g_debug = 1 THEN
          print_debug('RMA quantity given for batch/immediate mode is:'||l_rma_quantity||':'|| l_progress, 1);
       END IF;

    END IF;


    l_progress := '002';

    ----Fetch line_set_id

    BEGIN
       SELECT line_set_id
          INTO l_line_set_id
          FROM oe_order_lines_all
          WHERE line_id = p_oe_order_line_id
          AND header_id = p_oe_order_header_id;

       l_progress :='065';

    EXCEPTION
       WHEN OTHERS THEN
          IF g_debug = 1 THEN
             print_debug('Inv_Validate_rma_quantity ::line set id not found :'|| l_progress , 1);
          END IF;
          RAISE g_exc_unexpected_error;

    END;

    ----------Fetch RMA UNIT_OF_MEASURE

    SELECT unit_of_measure
       INTO l_rma_lot_unit_of_measure
       FROM oe_order_lines_all ,mtl_units_of_measure
       WHERE header_id = p_oe_order_header_id
       AND line_id = p_oe_order_line_id
       AND uom_code = order_quantity_uom;


    IF g_debug = 1 THEN
       print_debug('RMA UNIT_OF_MEASURE is :'|| l_rma_lot_unit_of_measure , 1);
    END IF;

    l_lot_recv_qty := 0;

    ------------------Get user entered quantity
    IF p_trx_quantity is NULL THEN  -----batch/immediate mode
       OPEN Cr_user_quantity;
       FETCH Cr_user_quantity
          INTO l_trx_quantity;
       ClOSE Cr_user_quantity;

       IF g_debug = 1 THEN
          print_debug('RMA quantity for batch/immediate mode is :'||l_trx_quantity||':'|| l_progress, 1);
       END IF;

    ELSE --------online mode
       l_trx_quantity := p_trx_quantity;

       IF g_debug = 1 THEN
          print_debug('RMA quantity for online mode is :'||l_trx_quantity||':'|| l_progress, 1);
       END IF;

    END IF;


    ------------------Get previously received quantity for the Lot.
    IF l_line_set_id IS NULL THEN
       --------------- sales order line is not split
       OPEN Cr_lot_recv_qty;
       FETCH Cr_lot_recv_qty
          INTO l_lot_recv_qty;
       CLOSE Cr_lot_recv_qty;

       l_progress :='066';

    ELSIF l_line_set_id IS NOT NULL THEN
       ------------ sales order line is split due to partial receipt of RMA
       OPEN Cr_lot_recv_qty_lineset;
       FETCH Cr_lot_recv_qty_lineset
          INTO l_lot_recv_qty;
       Close Cr_lot_recv_qty_lineset;

       l_progress :='067';

    END IF;

    IF g_debug = 1 THEN
       print_debug('previously received quantity for the Lot is :' || l_lot_recv_qty||':'||l_progress, 1);
    END IF;

    --If lot was previously received then take that quantity also into account.
    -- fetch Primary unit_of_measure of previously received lot from item master (mtl_system_items_b.)
    l_progress := '068';

    BEGIN
       SELECT PRIMARY_UNIT_OF_MEASURE
          INTO l_lot_recv_unit_of_measure
          FROM mtl_system_items_b
          WHERE INVENTORY_ITEM_ID = p_item_id
          AND organization_id = p_to_organization_id;

    EXCEPTION
       WHEN OTHERS THEN
          IF g_debug = 1 THEN
             print_debug('Inv_Validate_rma_quantity :: primary unit of measure not found:'||l_progress, 1);
          END IF;
          RAISE g_exc_unexpected_error;
    END;

    IF g_debug = 1 THEN
       print_debug('primary unit of measure of previously received lot from item master is :' || l_lot_recv_unit_of_measure||':'||l_progress, 1);
    END IF;

    /* Converting all to a single unit of measure (previously received unit of measure)

      IF transaction unit_of_measure is different than previously received primary unit_of_measure then
       convert transaction qty to previously received primary unit_of_measure.*/
    l_progress := '069';
    ---SAVEPOINT val_rma_quant4;

    IF l_trx_unit_of_measure <> l_lot_recv_unit_of_measure THEN

       IF g_debug = 1 THEN
          print_debug('l_trx_unit_of_measure <> l_lot_recv_unit_of_measure :' ||l_progress, 1);
       END IF;


       l_trx_quantity := INV_CONVERT.inv_um_convert(
                                                    item_id 			 => p_item_id                       ,
                                                    lot_number 		 => p_lot_number                    ,
                                                    organization_id	 => p_to_organization_id	         ,
                                                    precision		    => l_precision                     ,
                                                    from_quantity     => l_trx_quantity                  ,
                                                    from_unit		    => l_from_unit                     ,
                                                    to_unit    		 => l_to_unit                       ,
                                                    from_name         => l_trx_unit_of_measure           ,
                                                    to_name           => l_lot_recv_unit_of_measure
                                                    );

       IF g_debug = 1 THEN
          print_debug('quantity when l_trx_unit_of_measure <> l_lot_recv_unit_of_measure is :'|| l_trx_quantity ,1);
          print_debug('Program INV_CONVERT.inv_um_convert return: ' || l_return_status||':'||l_progress, 1);
       END IF;


       IF l_trx_quantity = -99999 THEN

          l_progress := '070';

          IF g_debug = 1 THEN
             print_debug('Inv_Validate_rma_quantity::INV_CONVERT.inv_um_convert has failed:'||l_progress, 1);
          END IF;
          FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
          FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
          fnd_msg_pub.ADD;
          RAISE g_exc_unexpected_error;
       END IF;

    END IF;

    l_progress := '071';
    ---SAVEPOINT val_rma_quant5;

    /* IF RMA unit_of_measure is different than previously received primary unit_of_measure
       then convert RMA qty to previously received primary unit_of_measure. */


    IF l_rma_lot_unit_of_measure <> l_lot_recv_unit_of_measure THEN

       IF g_debug = 1 THEN
          print_debug('l_rma_lot_unit_of_measure <> l_lot_recv_unit_of_measure :' ||l_progress, 1);
       END IF;

       l_rma_quantity :=  INV_CONVERT.inv_um_convert(
                                                        item_id  			   => p_item_id                 ,
                                                        lot_number 		   => p_lot_number              ,
                                                        organization_id		=> p_to_organization_id      ,
                                                        precision	 	      => 5                         ,
                                                        from_quantity      => l_rma_quantity            ,
                                                        from_unit	 	      => l_from_unit               ,
                                                        to_unit   			=> l_to_unit                 ,
                                                        from_name          => l_rma_lot_unit_of_measure ,
                                                        to_name            => l_lot_recv_unit_of_measure
                                                        );

       IF g_debug = 1 THEN
          print_debug('quantity when l_rma_lot_unit_of_measure <> l_lot_recv_unit_of_measure is :'|| l_rma_quantity ,1);
          print_debug('Program INV_CONVERT.inv_um_convert return: ' ||l_progress, 1);
       END IF;


       IF l_rma_quantity = -99999 THEN

          l_progress :='072';

          IF g_debug = 1 THEN
             print_debug('Inv_Validate_rma_quantity::INV_CONVERT.inv_um_convert has failed:'||l_progress, 9);
          END IF;
          FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
          FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_CONVERT.inv_um_convert');
          fnd_msg_pub.ADD;
          RAISE g_exc_unexpected_error;
       END IF;

    END IF;

        -----Quantity Validation Logic:

    /*If  transaction quantity is greater than the total rma lot quantity minus
      the previously received  qty for that lot then pass N to the allow flag
      along with the allowed qty for that lot in the transaction unit of measure.*/

    IF l_trx_quantity > (l_rma_quantity - nvl(l_lot_recv_qty,0)) THEN

       l_progress := '073';

       X_allowed := 'N';

       IF g_debug = 1 THEN
          print_debug('l_trx_quantity > (l_rma_quantity - nvl(l_lot_recv_qty,0)) :'|| l_progress ,1);
          print_debug('X_allowed: ' ||X_allowed, 1);
       END IF;

       IF l_trx_unit_of_measure <> l_lot_recv_unit_of_measure THEN

          l_progress := '074';

          X_allowed_quantity:=  INV_CONVERT.inv_um_convert(
                                                           item_id  			   => p_item_id                                 ,
                                                           lot_number 		   => p_lot_number                              ,
                                                           organization_id 	=> p_to_organization_id                      ,
                                                           precision 	 		=> 5                                         ,
                                                           from_quantity     	=> (l_rma_quantity - nvl(l_lot_recv_qty,0))  ,
                                                           from_unit	 		   => NULL                                      ,
                                                           to_unit   			=> NULL                               	      ,
                                                           from_name 	      => l_lot_recv_unit_of_measure                ,
                                                           to_name            => l_trx_unit_of_measure
                                                           );
          IF g_debug = 1 THEN
             print_debug('x_allowed_quantity when l_trx_unit_of_measure <> l_lot_recv_unit_of_measure is :'|| X_allowed_quantity ,1);
             print_debug('Program INV_CONVERT.inv_um_convert return ' || l_progress, 1);
          END IF;

          IF X_allowed_quantity = -99999 THEN
             l_progress := '075';

             IF g_debug = 1 THEN
                print_debug('Inv_Validate_rma_quantity::INV_CONVERT.inv_um_convert has failed:'|| l_progress, 1);
             END IF;
             FND_MESSAGE.SET_NAME('INV','INV_NO_CONVERSION_ERR');
             FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_ROI_INTEGRATION_GRP.INV_VALIDATE_RMA_QUANTITY');
             fnd_msg_pub.ADD;
             RAISE g_exc_unexpected_error;
          END IF;

       ELSE
          l_progress :='076';
          X_allowed_quantity := (l_rma_quantity - nvl(l_lot_recv_qty,0));

          IF g_debug = 1 THEN
             print_debug('x_allowed_quantity when l_trx_unit_of_measure = l_lot_recv_unit_of_measure is :'|| X_allowed_quantity ,1);
             print_debug('l_progress is:' || l_progress, 1);
          END IF;
       END IF;

       l_progress :='077';

       ---log error in error stack that quantity validation has failed.
       IF g_debug = 1 THEN
          print_debug(' RMA Quantity validation has failed ' || l_progress, 1);
       END IF;
       FND_MESSAGE.SET_NAME('PO','PO_RMA_QUANTITY_VAL_FAILED');
       FND_MESSAGE.SET_TOKEN('PGM_NAME','INV_ROI_INTEGRATION_GRP.INV_VALIDATE_RMA_QUANTITY');
       FND_MESSAGE.SET_TOKEN('TRX_QUANTITY',l_trx_quantity);
       FND_MESSAGE.SET_TOKEN('allowed_quantity',x_allowed_quantity );
       FND_MESSAGE.SET_TOKEN('lot_number',p_lot_number );
       fnd_msg_pub.ADD;
       RAISE g_exc_error;

    ELSE ---------IF l_trx_quantity > (l_rma_quantity - nvl(l_lot_recv_qty,0)) THEN
       l_progress :='078';
       X_allowed := 'Y';
       IF g_debug = 1 THEN
          print_debug('l_trx_quantity <= (l_rma_quantity - nvl(l_lot_recv_qty,0)) :'|| l_progress ,1);
          print_debug('X_allowed: ' ||X_allowed, 1);
          print_debug('quantity validation has passed:' || l_progress, 1);
       END IF;
    END IF;

    print_debug('End of the program inv_roi_integration_grp.inv_new_lot. Program has completed successfully :'|| l_progress, 1);

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
        x_return_status  := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count     ,
                                         FND_API.G_FALSE
                                         );
        END IF ;

        IF g_debug = 1 THEN
           print_debug('Exitting Inv_Validate_rma_quantity - No data found error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN g_exc_error THEN
        x_return_status  := fnd_api.g_ret_sts_error;

        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count     ,
                                         FND_API.G_FALSE
                                         );
        END IF;
        IF g_debug = 1 THEN
           print_debug('Exitting Inv_Validate_rma_quantity - g_exc_error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN g_exc_unexpected_error THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count        ,
                                         FND_API.G_FALSE);
        END IF ;
        IF g_debug = 1 THEN
           print_debug('Exitting Inv_Validate_rma_quantity - g_exc_unexpected_error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

     WHEN OTHERS THEN
        x_return_status  := fnd_api.g_ret_sts_unexp_error;

        fnd_msg_pub.count_and_get(
                                  p_encoded => fnd_api.g_false ,
                                  p_count => x_msg_count       ,
                                  p_data => x_msg_data
                                  );

        IF( x_msg_count > 1 ) THEN
           x_msg_data := fnd_msg_pub.get(
                                         x_msg_count        ,
                                         FND_API.G_FALSE);
        END IF;
        IF g_debug = 1 THEN
           print_debug('Exitting Inv_Validate_rma_quantity - others error:'||TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')||':'||l_progress, 1);
           print_stacked_messages;
        END IF;

 END Inv_Validate_rma_quantity;




 /*##########################################################################
  #
  #  PROCEDURE :  Check_Item_Attributes
  #
  #  DESCRIPTION  : This procedure does lot controlled and  child lot controlled
  #                 validations
  #
  #
  #   DESIGN REFERENCES:
  #   http://files.oraclecorp.com/content/AllPublic/Workspaces/
  #   Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip
  #
  # MODIFICATION HISTORY
  # 23-NOV-2004  Punit Kumar 	Created
  #
  #########################################################################*/


 PROCEDURE Check_Item_Attributes(
                                 x_return_status          OUT    NOCOPY VARCHAR2
                                 , x_msg_count            OUT    NOCOPY NUMBER
                                 , x_msg_data             OUT    NOCOPY VARCHAR2
                                 , x_lot_cont             OUT    NOCOPY BOOLEAN
                                 , x_child_lot_cont       OUT    NOCOPY BOOLEAN
                                 , p_inventory_item_id    IN     NUMBER
                                 , p_organization_id      IN     NUMBER
                                 )
    IS


    /* Cursor definition to check whether item is a valid and it's lot, child lot controlled */
    CURSOR  c_chk_msi_attr IS
    SELECT  lot_control_code,
       child_lot_flag
       FROM  mtl_system_items
       WHERE  inventory_item_id =  p_inventory_item_id
       AND  organization_id   =  p_organization_id;

    l_chk_msi_attr_rec    c_chk_msi_attr%ROWTYPE;

 BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

   /******************* START Item  validation ********************/

    /* Check item attributes in Mtl_system_items Table */

    OPEN  c_chk_msi_attr ;
    FETCH c_chk_msi_attr INTO l_chk_msi_attr_rec;

    IF c_chk_msi_attr%NOTFOUND THEN
       CLOSE c_chk_msi_attr;
       IF (g_debug = 1) THEN
          print_debug('Item not found.  Invalid item. Please re-enter.', 9);
       END IF;

       x_lot_cont        := FALSE ;
       x_child_lot_cont  := FALSE ;
       x_return_status  := fnd_api.g_ret_sts_error;
       fnd_message.set_name('INV', 'INV_INVALID_ITEM');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;

    ELSE

      CLOSE c_chk_msi_attr;

      /* If not lot controlled then error out */
      IF (l_chk_msi_attr_rec.lot_control_code = 1) THEN
         x_lot_cont   := FALSE ;
         IF g_debug = 1 THEN
            print_debug('Check_Item_Attributes. Item is not lot controlled ', 9);
         END IF;
      ELSE
          x_lot_cont   := TRUE ;
          IF g_debug = 1 THEN
             print_debug('Check_Item_Attributes. Item is lot controlled ', 9);
          END IF;
      END IF;  /*  l_chk_msi_attr_rec.lot_control_code = 1 */

      /* If not child lot enabled and p_parent_lot_number IS NOT NULL then error out */
      IF (l_chk_msi_attr_rec.child_lot_flag = 'N' ) THEN
         x_child_lot_cont  := FALSE ;
         IF g_debug = 1 THEN
            print_debug('Check_Item_Attributes. Item is not child lot enabled ', 9);
         END IF;
      ELSE
         x_child_lot_cont   := TRUE ;
         IF g_debug = 1 THEN
            print_debug('Check_Item_Attributes. Item is child lot enabled ', 9);
         END IF;
      END IF; /* l_chk_msi_attr_rec.child_lot_flag = 'N' */
   END IF;


   /******************* End Item validation  ********************/
 EXCEPTION

    WHEN NO_DATA_FOUND THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF( x_msg_count > 1 ) THEN
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      END IF;
      print_debug('In Check_Item_Attributes, No data found ' || SQLERRM, 9);

    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF( x_msg_count > 1 ) THEN
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      END IF;
      print_debug('In Check_Item_Attributes, g_exc_error ' || SQLERRM, 9);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF( x_msg_count > 1 ) THEN
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      END IF ;
      print_debug('In Check_Item_Attributes, g_exc_unexpected_error ' || SQLERRM, 9);

    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      IF( x_msg_count > 1 ) THEN
          x_msg_data := fnd_msg_pub.get(x_msg_count, FND_API.G_FALSE);
      END IF;
      print_debug('In Check_Item_Attributes, Others ' || SQLERRM, 9);

  END Check_Item_Attributes;


END INV_ROI_INTEGRATION_GRP ;


/
