--------------------------------------------------------
--  DDL for Package Body GR_PROCESS_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_PROCESS_ORDERS" AS
/*$Header: GRPORDRB.pls 120.1 2005/09/22 14:25:48 methomas noship $*/
/*
**
**
**
*/
PROCEDURE Build_OPM_Selections
   				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
   				 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 p_process_all_flag IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_return_status OUT NOCOPY VARCHAR2,
				 p_msg_count OUT NOCOPY NUMBER,
				 p_msg_data OUT NOCOPY VARCHAR2)
 IS

/*	Alpha Variables */
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS	VARCHAR2(1);
L_MSG_DATA			VARCHAR2(2000);

L_API_NAME			CONSTANT VARCHAR2(30) := 'Build OPM Selections';

L_CURRENT_DATE		DATE := SYSDATE;

L_OM_INTEGRATION	VARCHAR2(1);

x_return_status		VARCHAR2(100);
x_msg_count		NUMBER;
X_msg_data		VARCHAR2(2000);
pg_fp   		utl_file.file_type;

/* 	Numeric Variables */
L_ORACLE_ERROR		NUMBER;
L_API_VERSION		CONSTANT NUMBER := 1.0;

/*	Exceptions */
INCOMPATIBLE_API_VERSION_ERROR	EXCEPTION;
BATCH_NUMBER_NULL_ERROR				EXCEPTION;
INVALID_BATCH_NUMBER_ERROR			EXCEPTION;
INVALID_BATCH_STATUS_ERROR			EXCEPTION;
SELECTION_INSERT_ERROR				EXCEPTION;
PROCESS_SELECTIONS_ERROR			EXCEPTION;

/*
**  Define the cursors
**
**  Shipment information by shipment number
*/
/* GK Changes B2286375*/
CURSOR c_get_shipment_detail
 IS
   SELECT   	om.order_id,
   		om.line_no,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		mtl.segment1 item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		mtl_system_items mtl
    WHERE	om.bol_id >= GlobalBatchHeader.shipment_from
    AND         om.bol_id <= GlobalBatchHeader.shipment_to
    AND		om.from_whse = TO_CHAR(g_default_orgid)
    AND		om.shipaddr_id = cust.of_ship_to_site_use_id
    AND		mtl.inventory_item_id = om.item_id
    AND		om.shipping_ind = 0
    AND		om.delete_mark = 0
    UNION
    SELECT   	om.order_id,
   		om.line_no,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		ic.item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		ic_item_mst ic
    WHERE	om.bol_id >= GlobalBatchHeader.shipment_from
    AND         om.bol_id <= GlobalBatchHeader.shipment_to
    AND		om.from_whse = g_default_whse
    AND		om.shipcust_id = cust.cust_id
    AND		ic.item_id = om.item_id
    AND		om.shipping_ind = 0
    AND		om.delete_mark = 0;
LocalShipmentDetail		c_get_shipment_detail%ROWTYPE;
/*
**  Shipment information by date
*/
/* GK Changes B2286375*/
CURSOR c_get_shipment_date
 IS
   SELECT   	om.order_id,
   		om.line_no,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		mtl.segment1 item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		mtl_system_items mtl
    WHERE	om.actual_shipdate >= GlobalBatchHeader.shipment_date_from
    AND         om.actual_shipdate <= GlobalBatchHeader.shipment_date_to
    AND		om.from_whse = TO_CHAR(g_default_orgid)
    AND		om.shipaddr_id = cust.of_ship_to_site_use_id
    AND		mtl.inventory_item_id = om.item_id
    AND		om.shipping_ind = 0
    AND		om.delete_mark = 0
    UNION
    SELECT   	om.order_id,
   		om.line_no,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		ic.item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		ic_item_mst ic
    WHERE	om.actual_shipdate >= GlobalBatchHeader.shipment_date_from
    AND         om.actual_shipdate <= GlobalBatchHeader.shipment_date_to
    AND		om.from_whse = g_default_whse
    AND		om.shipcust_id = cust.cust_id
    AND		ic.item_id = om.item_id
    AND		om.shipping_ind = 0
    AND		om.delete_mark = 0;
LocalShipmentDate		c_get_shipment_date%ROWTYPE;
/*
**  Order header information
*/
/* GK Changes B2286375*/
CURSOR c_get_order_detail
 IS
   SELECT   	om.order_id,
   		om.line_no,
   		om.line_id,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		om.hold_code,
		mtl.segment1 item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		mtl_system_items mtl
    WHERE	om.order_id >= GlobalBatchHeader.order_from
    AND         om.order_id <= GlobalBatchHeader.order_to
    AND		om.from_whse = TO_CHAR(g_default_orgid)
    AND		om.shipaddr_id = cust.of_ship_to_site_use_id
    AND		mtl.inventory_item_id = om.item_id
    UNION
    SELECT DISTINCT  om.order_id,
   		om.line_no,
   		om.line_id,
            	om.bol_id,
		om.item_id,
		om.shipcust_id,
		om.holdreas_code,
		om.hold_code,
		ic.item_no,
		om.shipping_ind,
		om.picking_ind,
		om.order_no,
                om.bol_no,
		cust.cust_no
    FROM	op_cust_mst cust,
    		gr_order_info_v om,
    		ic_item_mst ic
    WHERE	om.order_id >= GlobalBatchHeader.order_from
    AND         om.order_id <= GlobalBatchHeader.order_to
    AND		om.from_whse = g_default_whse
    AND		om.shipcust_id = cust.cust_id
    AND		ic.item_id = om.item_id;
LocalOrderDetail		c_get_order_detail%ROWTYPE;

/*  GK Changes B2286375: Get organization id */
CURSOR c_get_org_id
  IS
   SELECT 	organization_id
   FROM	        mtl_parameters
   WHERE	organization_code = g_default_whse;
LocalOrgId			c_get_org_id%ROWTYPE;

CURSOR c_get_hold
  IS
   SELECT   ooh.order_hold_id
   FROM     oe_order_holds_all ooh
   WHERE    (LocalOrderDetail.order_id = ooh.header_id
   OR	    LocalOrderDetail.line_id = ooh.line_id)
   AND	    ooh.hold_release_id IS NULL;
LocalHoldRecord		c_get_hold%ROWTYPE;

BEGIN
   SAVEPOINT Build_OPM_Selections;
/*
**		Initialize the message list if true
*/
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;
g_report_type := 2;
/*		Check the API version passed in matches the
**		internal API version.
*/
   IF NOT FND_API.Compatible_API_Call
					(l_api_version,
					 p_api_version,
					 l_api_name,
					 g_pkg_name) THEN
      RAISE Incompatible_API_Version_Error;
   END IF;
/*
**		Set return status to successful
*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
**  B2286375		Check if using OM or OF
*/
   l_om_integration := FND_PROFILE.VALUE('GML_OM_INTEGRATION');

      FND_FILE.PUT(FND_FILE.LOG, 'OM Integration' || l_om_integration);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

/*
**		Check the passed in batch number is not null
**		and exists on the batch selection header and the
**		status is set to '1' indicating entered.
*/
   l_code_block := 'Validate the batch number';
   g_batch_number := p_batch_number;


   IF g_batch_number IS NULL THEN
      RAISE Batch_Number_Null_Error;
   ELSE
      OPEN g_get_batch_status;
         FETCH g_get_batch_status INTO GlobalBatchHeader;
	   IF g_get_batch_status%NOTFOUND THEN
	      CLOSE g_get_batch_status;
	      RAISE Invalid_Batch_Number_Error;
	   ELSIF GlobalBatchHeader.status <> 1 THEN
	      CLOSE g_get_batch_status;
	      RAISE Invalid_Batch_Status_Error;
	   END IF;
	 CLOSE g_get_batch_status;
   END IF;
/*
**		Set the territory, organizaton and warehouse defaults
*/
   g_default_country := GlobalBatchHeader.territory_code;--utl_file.put_line(pg_fp, 'terr '||GlobalBatchHeader.territory_code);
   g_default_orgn := GlobalBatchHeader.orgn_code;
   g_default_whse := GlobalBatchHeader.whse_code;

   /* Bug #2286375 GK Changes*/
   OPEN c_get_org_id;
   FETCH c_get_org_id INTO LocalOrgId;
   g_default_orgid := LocalOrgId.organization_id;
   CLOSE c_get_org_id;
   /* End Changes*/
/*
**		Get the default country profile
*/
   OPEN g_get_country_profile;
   FETCH g_get_country_profile INTO GlobalCountryRecord;
   IF g_get_country_profile%NOTFOUND THEN
      g_default_document := NULL;
   ELSE
      g_default_document := GlobalCountryRecord.document_code;--utl_file.put_line(pg_fp, 'doc '||GlobalCountryRecord.document_code);
   END IF;
   CLOSE g_get_country_profile;
/*
**		Clear any existing rows from the detail table
*/
   DELETE
   FROM		gr_selection sd
   WHERE	sd.batch_no = p_batch_number;
/*
**		Determine whether to process orders or shipments
*/
   IF GlobalBatchHeader.order_from IS NULL AND
      GlobalBatchHeader.order_to IS NULL THEN
      l_code_block := 'Process shipments';
      IF GlobalBatchHeader.shipment_from IS NULL AND
         GlobalBatchHeader.shipment_to IS NULL THEN
         l_code_block := 'Process by shipment date';
			 FND_FILE.PUT(FND_FILE.LOG, l_code_block);
         FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

         OPEN c_get_shipment_date;
         FETCH c_get_shipment_date INTO LocalShipmentDate;
         IF c_get_shipment_date%FOUND THEN
            WHILE c_get_shipment_date%FOUND LOOP
               g_item_code := LocalShipmentDate.item_no;
               IF LocalShipmentDate.shipping_ind <> 0 THEN
                  FND_FILE.PUT(FND_FILE.LOG, ' Shipment : '||LocalShipmentDate.bol_no||' Order : '||LocalShipmentDate.order_no||' - '||TO_CHAR(LocalShipmentDate.line_no));
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  l_code_block := 'Hold reason does not allow order to be shipped';

 			          FND_FILE.PUT(FND_FILE.LOG, l_code_block);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  l_return_status := FND_API.G_RET_STS_SUCCESS;
                  Insert_Selection_Row
                              ('GR_ON_HOLD_NO_SHIP',
                               'CODE',
                               LocalShipmentDate.holdreas_code,
                               LocalShipmentDate.order_id,
                               LocalShipmentDate.line_no,
                               g_default_document,
                               'N',
                               LocalShipmentDate.cust_no,
                               LocalShipmentDate.bol_no,
                               l_return_status);

                  IF l_return_status <> 'S' THEN
                     RAISE Selection_Insert_Error;
                  END IF;
               ELSE
                  g_order_no := LocalShipmentDate.order_no;
                  g_order_number := LocalShipmentDate.order_id;
                  g_order_line := LocalShipmentDate.line_no;
                  g_recipient_code := LocalShipmentDate.cust_no;
                  g_item_code := LocalShipmentDate.item_no;
                  g_shipment_number := LocalShipmentDate.bol_no;
                  l_return_status := FND_API.G_RET_STS_SUCCESS;

                  Check_Selected_Line
                              (l_return_status,
                               x_msg_count,
                               x_msg_data);

                  IF l_return_status <> 'S' THEN
                     RAISE Process_Selections_Error;
                  END IF;
               END IF;
            FETCH c_get_shipment_date INTO LocalShipmentDate;
            END LOOP;
         END IF;
         CLOSE c_get_shipment_date;
      ELSE
         l_code_block := 'Process by shipment number';

  	   FND_FILE.PUT(FND_FILE.LOG, l_code_block);
         FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

	IF c_get_shipment_detail%ISOPEN THEN
		CLOSE c_get_shipment_detail;
	END IF;

         OPEN c_get_shipment_detail;
         FETCH c_get_shipment_detail INTO LocalShipmentDetail;
         IF c_get_shipment_detail%FOUND THEN
             WHILE c_get_shipment_detail%FOUND LOOP
               FND_FILE.PUT(FND_FILE.LOG, ' Shipment : '||LocalShipmentDetail.bol_no||' Order : '||LocalShipmentDetail.order_no||' - '||TO_CHAR(LocalShipmentDetail.line_no));
               FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
               g_item_code := LocalShipmentDetail.item_no;
               IF LocalShipmentDetail.shipping_ind <> 0 THEN
                  l_code_block := 'Hold reason does not allow order to be shipped';

			          FND_FILE.PUT(FND_FILE.LOG, l_code_block);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  l_return_status := FND_API.G_RET_STS_SUCCESS;
                  Insert_Selection_Row
                              ('GR_ON_HOLD_NO_SHIP',
                               'CODE',
                               LocalShipmentDetail.holdreas_code,
                               LocalShipmentDetail.order_id,
                               LocalShipmentDetail.line_no,
                               g_default_document,
                               'N',
                               LocalShipmentDetail.cust_no,
                               LocalShipmentDetail.bol_no,
                               l_return_status);
                  IF l_return_status <> 'S' THEN
                     RAISE Selection_Insert_Error;
                  END IF;
               ELSE
                  g_order_no := LocalShipmentDetail.order_no;
                  g_order_number := LocalShipmentDetail.order_id;
                  g_order_line := LocalShipmentDetail.line_no;
                  g_recipient_code := LocalShipmentDetail.cust_no;
                  g_item_code := LocalShipmentDetail.item_no;
                  g_shipment_number := LocalShipmentDetail.bol_no;
                  l_return_status := FND_API.G_RET_STS_SUCCESS;

                  Check_Selected_Line
                              (l_return_status,
                               x_msg_count,
                               x_msg_data);

                  IF l_return_status <> 'S' THEN
                     RAISE Process_Selections_Error;
                  END IF;
               END IF;
            FETCH c_get_shipment_detail INTO LocalShipmentDetail;
            END LOOP;
         END IF;
         CLOSE c_get_shipment_detail;
      END IF;
   ELSE
      l_code_block := 'Process orders';
      FND_FILE.PUT(FND_FILE.LOG, l_code_block);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

      OPEN c_get_order_detail;
      FETCH c_get_order_detail INTO LocalOrderDetail;
         IF c_get_order_detail%FOUND THEN

	    WHILE c_get_order_detail%FOUND LOOP
            FND_FILE.PUT(FND_FILE.LOG, ' Order : '||LocalOrderDetail.order_no||' - '||TO_CHAR(LocalOrderDetail.line_no));
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

            g_item_code := LocalOrderDetail.item_no;
	   IF  l_om_integration = 'N' THEN  /*Added for OM Integration B2286375*/
--utl_file.put_line(pg_fp, 'integrn ' ||l_om_integration);
    	    IF LocalOrderDetail.holdreas_code <> 'NONE' OR  LocalOrderDetail.hold_code <> 'NONE' THEN
    		    -- utl_file.put_line(pg_fp, 'hold found' ||Localofhold.holdreas_code);
	       IF LocalOrderDetail.picking_ind <> 0 AND
	           LocalOrderDetail.picking_ind IS NOT NULL THEN
	              l_code_block := 'Hold reason does not allow order to be picked';

		      FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               	      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

		      l_return_status := FND_API.G_RET_STS_SUCCESS;
		      Insert_Selection_Row
		         ('GR_ON_HOLD_NO_PICK',
			 'CODE',
			 LocalOrderDetail.holdreas_code,
			 LocalOrderDetail.order_id,
			 LocalOrderDetail.line_no,
			 '',
			 'N',
			 LocalOrderDetail.cust_no,
			 '',
			 l_return_status);
			    IF l_return_status <> 'S' THEN
			       RAISE Selection_Insert_Error;
			    END IF;
			    /* Fix for B1449278 */
			   /* Added code to check for the hold for shipping_ind on the order. */
		ELSIF LocalOrderDetail.shipping_ind <> 0 AND
		   LocalOrderDetail.shipping_ind IS NOT NULL THEN
		      l_code_block := 'Hold reason does not allow order to be shipped';
--utl_file.put_line(pg_fp, 'code '||l_code_block);
		      FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               	      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

		      l_return_status := FND_API.G_RET_STS_SUCCESS;
		      Insert_Selection_Row
		         ('GR_ON_HOLD_NO_SHIP',
			 'CODE',
			 LocalOrderDetail.holdreas_code,
			 LocalOrderDetail.order_id,
			 LocalOrderDetail.line_no,
			 '',
			 'N',
			 LocalOrderDetail.cust_no,
			 '',
			 l_return_status);
			    IF l_return_status <> 'S' THEN
			       RAISE Selection_Insert_Error;
			    END IF;

	          END IF;

	    ELSE
	        IF LocalOrderDetail.bol_id <> 0 AND
		       LocalOrderDetail.bol_id IS NOT NULL THEN
		          l_code_block := '   Line already shipped';

               		  FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               		  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

			  l_return_status := FND_API.G_RET_STS_SUCCESS;
			  Insert_Selection_Row
			     ('GR_ORDER_ALREADY_SHIPPED',
			     '',
			     '',
			     LocalOrderDetail.order_id,
			     LocalOrderDetail.line_no,
			     '',
			     'N',
			     LocalOrderDetail.cust_no,
			     '',
			     l_return_status);
			        IF l_return_status <> 'S' THEN
			           RAISE Selection_Insert_Error;
			        END IF;
		  ELSE
		   -- utl_file.put_line(pg_fp, 'else bol_id');
		       g_order_no := LocalOrderDetail.order_no;
		       g_order_number := LocalOrderDetail.order_id;
	               g_order_line := LocalOrderDetail.line_no;
               	       g_recipient_code := LocalOrderDetail.cust_no;
               	       g_item_code := LocalOrderDetail.item_no;
               	       g_shipment_number := NULL;

               	       l_return_status := FND_API.G_RET_STS_SUCCESS;

               	       Check_Selected_Line
                          (l_return_status,
                          x_msg_count,
                          x_msg_data);

               	          IF l_return_status <> 'S' THEN
                             RAISE Process_Selections_Error;
               	          END IF;

		   END IF; /* LocalOrderDetail.bol_id <> 0 */
		 END IF; /*holdreas_code*/
	         ELSIF  l_om_integration = 'Y' THEN  /*Added for OM Integration B2286375*/
--utl_file.put_line(pg_fp, 'integrnOM ' ||l_om_integration);
	           IF LocalOrderDetail.holdreas_code = 0 THEN
	               OPEN c_get_hold;
	               FETCH c_get_hold INTO LocalHoldRecord;
	               IF c_get_hold%FOUND THEN
	               l_code_block := 'Hold reason does not allow order to be picked';
		--utl_file.put_line(pg_fp,'code blk ' ||l_code_block);
		       FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               	       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

		       l_return_status := FND_API.G_RET_STS_SUCCESS;
		       Insert_Selection_Row
		         ('GR_ON_HOLD_NO_PICK',
			 'CODE',
			 LocalHoldRecord.order_hold_id,
			 LocalOrderDetail.order_id,
			 LocalOrderDetail.line_no,
			 '',
			 'N',
			 LocalOrderDetail.cust_no,
			 '',
			 l_return_status);
			    IF l_return_status <> 'S' THEN
			       RAISE Selection_Insert_Error;
			    END IF;
		       ELSE
			  g_order_no := LocalOrderDetail.order_no;
			  g_order_number := LocalOrderDetail.order_id;
	            	  g_order_line := LocalOrderDetail.line_no;
               	    	  g_recipient_code := LocalOrderDetail.cust_no;
               	    	  g_item_code := LocalOrderDetail.item_no;
               	     	  g_shipment_number := NULL;
--utl_file.put_line(pg_fp,'else ' ||g_order_number);
               	    	  l_return_status := FND_API.G_RET_STS_SUCCESS;

               	    	  Check_Selected_Line
                            (l_return_status,
                             x_msg_count,
                             x_msg_data);

               	          IF l_return_status <> 'S' THEN
                             RAISE Process_Selections_Error;
               	          END IF;

		       END IF;/*c_get_hold%found*/

		      CLOSE c_get_hold;

		    END IF;/* holdreas = 0*/
		  END IF;/* integration*/
		 FETCH c_get_order_detail INTO LocalOrderDetail;
	       END LOOP;
      END IF; /* c_get_order_detail  found*/
      CLOSE c_get_order_detail;
   END IF; /* order_from is NULL */
/*
**			Update the header status to Selected
*/
   UPDATE	gr_selection_header
   SET		status = 2
   WHERE	batch_no = p_batch_number;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;
/*
**		Process all flag set to 1 means automatically chain
**		to process the selected lines.
*/
   IF p_process_all_flag = 1 THEN
      Process_Selections
				(errbuf,
				 retcode,
				 p_commit,
				 'F',
				 p_init_msg_list,
				 p_validation_level,
				 1.0,
				 p_batch_number,
				 p_process_all_flag,
				 p_printer,
				 p_user_print_style,
				 p_number_of_copies,
				 l_return_status,
				 x_msg_count,
				 x_msg_data);
      IF l_return_status <> 'S' THEN
         RAISE Process_Selections_Error;
      END IF;
   END IF;

EXCEPTION

   WHEN Incompatible_API_Version_Error THEN
      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_API_VERSION_ERROR',
				 'VERSION',
				 p_api_version,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN Batch_Number_Null_Error THEN
      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_NULL_BATCH_NUMBER',
				 '',
				 '',
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN Invalid_Batch_Number_Error THEN
      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_INVALID_BATCH_NUMBER',
				 'BATCH',
				 p_batch_number,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN Invalid_Batch_Status_Error THEN
      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_INVALID_BATCH_STATUS',
				 'STATUS',
				 GlobalBatchHeader.status,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN Selection_Insert_Error THEN

      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_NO_RECORD_INSERTED',
				 'CODE',
				 g_order_number || ' ' || g_order_line,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN Process_Selections_Error THEN

      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

	  Handle_Error_Messages
				('GR_UNEXPECTED_ERROR',
				 'TEXT',
				 l_msg_data,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN OTHERS THEN

      ROLLBACK TO SAVEPOINT Build_OPM_Selections;

      l_oracle_error := SQLCODE;
	  /*l_code_block := SUBSTR(SQLERRM, 1, 200);*/
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
--utl_file.fflush(pg_fp);
      				--utl_file.fclose(pg_fp);
END Build_OPM_Selections;
/*
**	This procedure takes the selections for the batch that are
**	stored in the gr_selection table and generates the cover
**	letters and documents for the items in the selection.
*/
PROCEDURE Process_Selections
				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_called_by_form IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 p_process_all_flag IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*	Alpha Variables */
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS     VARCHAR2(1);
L_MSG_DATA          VARCHAR2(2000);
L_NEW_RECIPIENT		VARCHAR2(2);
L_PRINT_COUNT		NUMBER(5)	DEFAULT 0;
L_LANGUAGE_CODE		FND_LANGUAGES.language_code%TYPE;
L_API_NAME          CONSTANT VARCHAR2(30) := 'Process Selections';
pg_fp   		utl_file.file_type;
/* 	Numeric Variables */
L_HEADER_STATUS     GR_SELECTION_HEADER.status%TYPE;
L_ORACLE_ERROR		NUMBER;
L_USER_ID			NUMBER;

L_API_VERSION     CONSTANT NUMBER := 1.0;

/*  Exceptions */
INCOMPATIBLE_API_VERSION_ERROR      EXCEPTION;
INVALID_BATCH_NUMBER_ERROR          EXCEPTION;
INVALID_BATCH_STATUS_ERROR          EXCEPTION;
BATCH_NUMBER_NULL_ERROR             EXCEPTION;
UPDATE_HISTORY_ERROR                EXCEPTION;
OTHER_API_ERROR						EXCEPTION;

/*  Define the local cursors
**
**  Get the line details. Only select line details
**  marked for print that have been selected and have
**  not been updated.
*/
CURSOR c_get_line_details
 IS
   SELECT   sd.ROWID,
            sd.document_code,
            sd.item_code,
            sd.recipient_code,
            sd.line_status,
	    sd.order_no,
	    sd.order_line_number,
   /*  22-Aug-2003   Mercy Thomas BUG 2932007 - Added the column shipment_no to the cursor */
            sd.shipment_no
   /*  22-Aug-2003   Mercy Thomas BUG 2932007 - End of the code change */
   FROM     gr_selection sd
   WHERE    sd.batch_no = g_batch_number
   AND      sd.print_flag = 'Y'
   AND      sd.line_status <> 0
   AND      sd.line_status <> 8;
LocalDetailRecord       c_get_line_details%ROWTYPE;

/*
** Get the line message if the row cannot be printed
*/
CURSOR c_get_line_message
 IS
   SELECT   SUBSTR(message, 1, 100) message, order_no, order_line_number
   FROM     gr_selection sd
   WHERE    sd.batch_no = g_batch_number;
LocalLineRecord	c_get_line_message%ROWTYPE;

CURSOR c_get_order_dtl
 IS
   SELECT   distinct order_no, line_no
   FROM     gr_order_info_v
   WHERE    order_id = g_order_number;
LocalOrdDtl	c_get_order_dtl%ROWTYPE;

BEGIN
/*
**		Initialize the message list if true
*/
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;
   /*pg_fp := utl_file.fopen('/sqlcom/log/opm115m','order1.log','w');
   utl_file.put_line(pg_fp, 'this is a test statement');*/
/*
**		Check the API version passed in matches the
**		internal API version.
*/
   IF NOT FND_API.Compatible_API_Call
					(l_api_version,
					 p_api_version,
					 l_api_name,
					 g_pkg_name) THEN
      RAISE Incompatible_API_Version_Error;
   END IF;

   /*  17-Jun-2003   Mercy Thomas BUG 2932007 - Added report type for Document Management  */

   FND_FILE.PUT(FND_FILE.LOG, ' Report Type ' || g_report_type);
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
   IF g_report_type = 0 THEN
      g_report_type := 4;
      FND_FILE.PUT(FND_FILE.LOG, ' Report Type ' || g_report_type);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
   END IF;
  /*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of code changes */

/*
**		Set return status to successful and get
**		the required user profiles.
*/
   IF p_called_by_form = 'F' THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;
   g_recipient_code := NULL;
/*
**		Check the passed in batch number is not null
**		and exists on the batch selection header and the
**		status is set to 2, 4, 5 or 6 indicating selected, a
**      a restart, a rerun or printed.
*/
   l_code_block := 'Validate the batch number';
   g_batch_number := p_batch_number;

   IF g_batch_number IS NULL THEN
      RAISE Batch_Number_Null_Error;
   ELSE
      OPEN g_get_batch_status;
      FETCH g_get_batch_status INTO GlobalBatchHeader;
      IF g_get_batch_status%NOTFOUND THEN
         CLOSE g_get_batch_status;
         RAISE Invalid_Batch_Number_Error;
      ELSIF GlobalBatchHeader.status <> 2 AND
         GlobalBatchHeader.status <> 4 AND
         GlobalBatchHeader.status <> 5 AND
         GlobalBatchHeader.status <> 6 THEN
         CLOSE g_get_batch_status;
         RAISE Invalid_Batch_Status_Error;
      END IF;
      CLOSE g_get_batch_status;
   END IF;
/*
**		Set the territory, organizaton and warehouse defaults
*/
   g_default_orgn := GlobalBatchHeader.orgn_code;
   g_default_whse := GlobalBatchHeader.whse_code;
   g_default_country := GlobalBatchHeader.territory_code;

/*
**		Get the default country profile
*/
   OPEN g_get_country_profile;
   FETCH g_get_country_profile INTO GlobalCountryRecord;
   IF g_get_country_profile%NOTFOUND THEN
      g_default_document := NULL;
   ELSE
      g_default_document := GlobalCountryRecord.document_code;
   END IF;
   CLOSE g_get_country_profile;

/*
**			Get the session id and clear print work table
*/
   SELECT 	gr_work_build_docs_s.nextval INTO g_session_id
   FROM 	dual;

   l_return_status := 'S';
   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
        ('F',
         g_session_id,
         l_return_status,
         l_oracle_error,
         l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_Error;
   END IF;
/*
**          Store the batch header status and set the
**          header status to in process - 3
*/
   l_header_status := GlobalBatchHeader.status;
/*utl_file.put_line(pg_fp, 'GlobalBatchHeader.status' ||GlobalBatchHeader.status);*/

   UPDATE	gr_selection_header
   SET		status = 3
   WHERE	batch_no = p_batch_number;
/*
**          Now process the detail lines
*/
   OPEN c_get_line_details;
   FETCH c_get_line_details INTO LocalDetailRecord;
   IF c_get_line_details%FOUND THEN
      WHILE c_get_line_details%FOUND LOOP

         /*
         **  17-Jun-2003   Mercy Thomas BUG 2932007 - If the Process Selections, is done separately, to populate the Global vaiables for Document
         **                                           Management added the following code
         **
         */

         IF g_report_type = 4 THEN
            g_item_code       := LocalDetailRecord.item_code;
            g_order_number    := LocalDetailRecord.order_no;
            /*  22-Aug-2003   Mercy Thomas BUG 2932007 - Added the code to populate the global variable g_shipment_number */
            g_shipment_number := LocalDetailRecord.shipment_no;
            /*  22-Aug-2003   Mercy Thomas BUG 2932007 - End of the code changes*/
            OPEN c_get_order_dtl;
            FETCH c_get_order_dtl INTO LocalOrdDtl;
            IF c_get_order_dtl%FOUND THEN
               g_order_no    := LocalOrdDtl.order_no;
               /*  22-Aug-2003   Mercy Thomas BUG 2932007 - Modified the global variable from g_line_number to g_order_line */
               g_order_line  := LocalOrdDtl.line_no;
               /*  22-Aug-2003   Mercy Thomas BUG 2932007 - End of the code changes */
            END IF;
            CLOSE c_get_order_dtl;
         END IF;

         /*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of code changes */

         IF l_header_status = 4 AND
            (LocalDetailRecord.line_status <> 2 OR
             LocalDetailRecord.line_status <> 3) THEN
            l_code_block := 'Do not print this line';
            FND_FILE.PUT(FND_FILE.LOG, l_code_block||' - '||LocalDetailRecord.order_no||' - '||TO_CHAR(LocalDetailRecord.order_line_number));
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
         ELSE
            SAVEPOINT Process_Document_Selection;
/*
**             Set the line status to printing in process
*/
            UPDATE      gr_selection
            SET         line_status = 3
            WHERE       ROWID = LocalDetailRecord.ROWID;
/*
**				If a change of recipient code, get the new details or
**				build a new record if note there.
*/
            IF g_recipient_code IS NULL OR
               g_recipient_code <> LocalDetailRecord.recipient_code THEN
               g_recipient_code := LocalDetailRecord.recipient_code;
			       /*utl_file.put_line(pg_fp, 'LocalDetailRecord.recipient_code'||LocalDetailRecord.recipient_code);*/
               OPEN g_get_recipient;
               FETCH g_get_recipient INTO GlobalRecipient;
               IF g_get_recipient%NOTFOUND THEN
                  l_code_block := 'Write new recipient record';
               END IF;
               CLOSE g_get_recipient;
               l_language_code := GlobalRecipient.language;
               l_new_recipient := 'YS';
            ELSE
               l_new_recipient := 'NO';
            END IF;
/*
**              Print documents for invoice address
*/
            IF GlobalRecipient.invoice_address = 1 THEN
		/*utl_file.put_line(pg_fp, 'GlobalRecipient.invoice_address'||GlobalRecipient.invoice_address);*/
               IF GlobalRecipient.region_code IS NULL THEN
                  IF l_new_recipient = 'YS' THEN
                     l_return_status := 'S';
                     Read_And_Print_Cover_Letter
                          (l_language_code,
                           LocalDetailRecord.item_code,
                           GlobalRecipient.recipient_code,
                           'I',
                           LocalDetailRecord.order_no,
                           '',
                           l_return_status);
                     IF l_return_status <> 'S' THEN
                        l_code_block := 'Error';
                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                        RAISE Other_API_Error;
                     END IF;
	   /*
	   **           Print the letter and increment the session id
						   */
                     l_return_status := 'S';
                     g_cover_letter := 'Y';
                     Submit_Print_Request
                          (p_printer,
                           p_user_print_style,
                           p_number_of_copies,
                           g_default_document,
                           l_language_code,
                           l_return_status);
                     IF l_return_status <> 'S' THEN
                        FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                     END IF;
                     l_return_status := 'S';
                  END IF;
                  l_code_block := 'Print document in default language';
                  l_return_status := 'S';
                  Print_Document_Selection
                       (LocalDetailRecord.document_code,
                        LocalDetailRecord.item_code,
                        l_language_code,
                        GlobalRecipient.disclosure_code,
                        l_return_status);
                  IF l_return_status <> 'S' THEN
                     l_code_block := 'Print Document Error';
                  ELSE
                     g_cover_letter := 'N';
                     Submit_Print_Request
                          (p_printer,
                           p_user_print_style,
                           p_number_of_copies,
                           g_default_document,
                           l_language_code,
                           l_return_status);
-- Bug #1902822 (JKB) Added above.
                     l_print_count := l_print_count + 1;
                  END IF;
               ELSE
                  OPEN g_get_region_language;
                  FETCH g_get_region_language INTO GlobalRgnLangRecord;
                  IF g_get_region_language%NOTFOUND THEN
                     IF l_new_recipient = 'YS' THEN
                        l_return_status := 'S';
                        Read_And_Print_Cover_Letter
                             (l_language_code,
                              LocalDetailRecord.item_code,
                              GlobalRecipient.recipient_code,
                              'I',
                              LocalDetailRecord.order_no,
                              '',
                              l_return_status);
                        IF l_return_status <> 'S' THEN
                           l_code_block := 'Error';
                           FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                           FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                           RAISE Other_API_Error;
                        END IF;
		   /*
	   **           Print the letter and increment the session id
						   */
                        l_return_status := 'S';
                        g_cover_letter := 'Y';
                        Submit_Print_Request
                             (p_printer,
                              p_user_print_style,
                              p_number_of_copies,
                              g_default_document,
                              l_language_code,
                              l_return_status);
                        IF l_return_status <> 'S' THEN
                           FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
                           FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                        END IF;
                        l_return_status := 'S';
                     END IF;
                     l_code_block := 'Print document in default language';
                     l_return_status := 'S';
                     Print_Document_Selection
                          (LocalDetailRecord.document_code,
                           LocalDetailRecord.item_code,
                           l_language_code,
                           GlobalRecipient.disclosure_code,
                           l_return_status);
                     IF l_return_status <> 'S' THEN
                        l_code_block := 'Print Document Error';
                     ELSE
                     g_cover_letter := 'N';
                        Submit_Print_Request
                             (p_printer,
                              p_user_print_style,
                              p_number_of_copies,
                              g_default_document,
                              l_language_code,
                              l_return_status);
-- Bug #1902822 (JKB) Added above.
                        l_print_count := l_print_count + 1;
                     END IF;
                  ELSE
                     WHILE g_get_region_language%FOUND LOOP
                        l_language_code := GlobalRgnLangRecord.language;
                        IF l_new_recipient = 'YS' THEN
                           l_return_status := 'S';
                           Read_And_Print_Cover_Letter
                                (l_language_code,
                                 LocalDetailRecord.item_code,
                                 GlobalRecipient.recipient_code,
                                 'I',
                                 LocalDetailRecord.order_no,
                                 '',
                                 l_return_status);
                           IF l_return_status <> 'S' THEN
                              l_code_block := 'Error';
                              FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                              FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                              RAISE Other_API_Error;
                           END IF;
	   /*
	   **           Print the letter and increment the session id
						   */
                           l_return_status := 'S';
                     g_cover_letter := 'Y';
                           Submit_Print_Request
                                (p_printer,
                                 p_user_print_style,
                                 p_number_of_copies,
                                 g_default_document,
                                 l_language_code,
                                 l_return_status);
                           IF l_return_status <> 'S' THEN
                              FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
                              FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                           END IF;
                           l_return_status := 'S';
                        END IF;
                        l_code_block := 'Print document in region language';
                        l_return_status := 'S';
                        Print_Document_Selection
                             (LocalDetailRecord.document_code,
                              LocalDetailRecord.item_code,
                              l_language_code,
                              GlobalRecipient.disclosure_code,
                              l_return_status);
                        IF l_return_status <> 'S' THEN
                           l_code_block := 'Print Document Error';
                        ELSE
                     g_cover_letter := 'N';
                           Submit_Print_Request
                                (p_printer,
                                 p_user_print_style,
                                 p_number_of_copies,
                                 g_default_document,
                                 l_language_code,
                                 l_return_status);
-- Bug #1902822 (JKB) Added above.
                           l_print_count := l_print_count + 1;
                        END IF;
                        FETCH g_get_region_language INTO GlobalRgnLangRecord;
                     END LOOP;
                  END IF;
                  CLOSE g_get_region_language;
               END IF;
            END IF;
/*
**              Print documents for shipping address
*/
			IF GlobalRecipient.shipping_address = 1 THEN
			   IF GlobalRecipient.region_code IS NULL THEN
			      IF l_new_recipient = 'YS' THEN
			      /*utl_file.put_line(pg_fp, 'l_new_recipient'||l_new_recipient);*/
				      l_return_status := 'S';
				      Read_And_Print_Cover_Letter
				     				(l_language_code,
						          LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'S',
									 LocalDetailRecord.order_no,
									 '',
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);
					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				   END IF;
				   l_code_block := 'Print document in default language';
				   l_return_status := 'S';
				   Print_Document_Selection
						(LocalDetailRecord.document_code,
						 LocalDetailRecord.item_code,
						 l_language_code,
						 GlobalRecipient.disclosure_code,
						 l_return_status);
				   IF l_return_status <> 'S' THEN
				      l_code_block := 'Print Document Error';
              ELSE
                     g_cover_letter := 'N';
                           Submit_Print_Request
                                (p_printer,
                                 p_user_print_style,
                                 p_number_of_copies,
                                 g_default_document,
                                 l_language_code,
                                 l_return_status);
-- Bug #1902822 (JKB) Added above.
                 l_print_count := l_print_count + 1;
				   END IF;
			   ELSE
			      OPEN g_get_region_language;
			      FETCH g_get_region_language INTO GlobalRgnLangRecord;
			      IF g_get_region_language%NOTFOUND THEN
			         IF l_new_recipient = 'YS' THEN
				        l_return_status := 'S';
				        Read_And_Print_Cover_Letter
				     				(l_language_code,
						             LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'S',
									 LocalDetailRecord.order_no,
									 '',
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);
					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				     END IF;
				     l_code_block := 'Print document in default language';
				     l_return_status := 'S';
				     Print_Document_Selection
						(LocalDetailRecord.document_code,
						 LocalDetailRecord.item_code,
						 l_language_code,
						 GlobalRecipient.disclosure_code,
						 l_return_status);
				     IF l_return_status <> 'S' THEN
				        l_code_block := 'Print Document Error';
                             ELSE
                                g_cover_letter := 'N';
                                Submit_Print_Request
                                     (p_printer,
                                      p_user_print_style,
                                      p_number_of_copies,
                                      g_default_document,
                                      l_language_code,
                                      l_return_status);
-- Bug #1902822 (JKB) Added above.
                                l_print_count := l_print_count + 1;
				     END IF;
			      ELSE
					 WHILE g_get_region_language%FOUND LOOP
					    l_language_code := GlobalRgnLangRecord.language;
			            IF l_new_recipient = 'YS' THEN
				           l_return_status := 'S';
				           Read_And_Print_Cover_Letter
				     				(l_language_code,
						             LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'S',
									 LocalDetailRecord.order_no,
									 '',
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);
					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				        END IF;
				        l_code_block := 'Print document in region language';
				        l_return_status := 'S';
				        Print_Document_Selection
						      (LocalDetailRecord.document_code,
						       LocalDetailRecord.item_code,
						       l_language_code,
						       GlobalRecipient.disclosure_code,
						       l_return_status);
				        IF l_return_status <> 'S' THEN
				           l_code_block := 'Print Document Error';
                          	  ELSE
                                     g_cover_letter := 'N';
                                     Submit_Print_Request
                                          (p_printer,
                                           p_user_print_style,
                                           p_number_of_copies,
                                           g_default_document,
                                           l_language_code,
                                           l_return_status);
-- Bug #1902822 (JKB) Added above.
                                   l_print_count := l_print_count + 1;
				        END IF;
						FETCH g_get_region_language INTO GlobalRgnLangRecord;
					 END LOOP;
				  END IF;
				  CLOSE g_get_region_language;
			   END IF;
        END IF;
/*
**              Print documents for other addresses
*/
			IF GlobalRecipient.additional_address_flag = 1 THEN
			   OPEN g_get_other_addresses;
			   FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
			   WHILE g_get_other_addresses%FOUND LOOP
			      IF GlobalRecipient.region_code IS NULL THEN
			         IF l_new_recipient = 'YS' THEN
				        l_return_status := 'S';
				        Read_And_Print_Cover_Letter
				     				(l_language_code,
                                     LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'O',
									 '',
									 GlobalOtherAddrRecord.addr_id,
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);

					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				     END IF;
				     l_code_block := 'Print document in default language';
				     l_return_status := 'S';
				     Print_Document_Selection
						(LocalDetailRecord.document_code,
						 LocalDetailRecord.item_code,
						 l_language_code,
						 GlobalRecipient.disclosure_code,
						 l_return_status);
				     IF l_return_status <> 'S' THEN
				        l_code_block := 'Print Document Error';
                             ELSE
                                g_cover_letter := 'N';
                                Submit_Print_Request
                                     (p_printer,
                                      p_user_print_style,
                                      p_number_of_copies,
                                      g_default_document,
                                      l_language_code,
                                      l_return_status);
-- Bug #1902822 (JKB) Added above.
	                          l_print_count := l_print_count + 1;
				     END IF;
			      ELSE
			         OPEN g_get_region_language;
			         FETCH g_get_region_language INTO GlobalRgnLangRecord;
			         IF g_get_region_language%NOTFOUND THEN
			            IF l_new_recipient = 'YS' THEN
				           l_return_status := 'S';
				           Read_And_Print_Cover_Letter
				     				(l_language_code,
						             LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'O',
									 '',
									 GlobalOtherAddrRecord.addr_id,
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);

					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				        END IF;
				        l_code_block := 'Print document in default language';
				        l_return_status := 'S';
				        Print_Document_Selection
						      (LocalDetailRecord.document_code,
						       LocalDetailRecord.item_code,
						       l_language_code,
						       GlobalRecipient.disclosure_code,
						       l_return_status);
				        IF l_return_status <> 'S' THEN
				           l_code_block := 'Print Document Error';
                   ELSE
                     g_cover_letter := 'N';
                           Submit_Print_Request
                                (p_printer,
                                 p_user_print_style,
                                 p_number_of_copies,
                                 g_default_document,
                                 l_language_code,
                                 l_return_status);
-- Bug #1902822 (JKB) Added above.
                      l_print_count := l_print_count + 1;
				        END IF;
			         ELSE
					    WHILE g_get_region_language%FOUND LOOP
						   l_language_code := GlobalRgnLangRecord.language;
			               IF l_new_recipient = 'YS' THEN
				              l_return_status := 'S';
				              Read_And_Print_Cover_Letter
				     				(l_language_code,
						             LocalDetailRecord.item_code,
									 GlobalRecipient.recipient_code,
									 'O',
									 '',
									 GlobalOtherAddrRecord.addr_id,
				     				 l_return_status);
					       IF l_return_status <> 'S' THEN
					          l_code_block := 'Error';
                                        FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  				                RAISE Other_API_Error;
					       END IF;
						/*
						**           Print the letter and increment the session id
						*/
						l_return_status := 'S';
                        g_cover_letter := 'Y';
						Submit_Print_Request
						             (p_printer,
						          	  p_user_print_style,
								  p_number_of_copies,
								  g_default_document,
								  l_language_code,
								  l_return_status);

					      IF l_return_status <> 'S' THEN
						  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
						  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
						END IF;
						l_return_status := 'S';
				           END IF;
				           l_code_block := 'Print document in region language';
				           l_return_status := 'S';
				           Print_Document_Selection
						         (LocalDetailRecord.document_code,
						          LocalDetailRecord.item_code,
						          l_language_code,
						          GlobalRecipient.disclosure_code,
						          l_return_status);
				                  IF l_return_status <> 'S' THEN
				                     l_code_block := 'Print Document Error';
                          	ELSE
                                   g_cover_letter := 'N';
                                   Submit_Print_Request
                                        (p_printer,
                                         p_user_print_style,
                                         p_number_of_copies,
                                         g_default_document,
                                         l_language_code,
                                         l_return_status);
-- Bug #1902822 (JKB) Added above.
                            		l_print_count := l_print_count + 1;
				                  END IF;
					            FETCH g_get_region_language INTO GlobalRgnLangRecord;
					         END LOOP;
				         END IF;
				         CLOSE g_get_region_language;
			         END IF;
            	   FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
			      END LOOP;
			      CLOSE g_get_other_addresses;
			    END IF;
			 END IF;
/*
**             Set the line status to printing completed
*/
         UPDATE      gr_selection
         SET         line_status = 6,
                     document_code = NVL(document_code, g_default_document)
         WHERE       ROWID = LocalDetailRecord.ROWID;
/*
**			   Commit the work if the flag is set
*/
         IF FND_API.To_Boolean(p_commit) THEN
		       COMMIT WORK;
		    END IF;
/*
**		Now submit the print job.
*/
--   IF l_print_count > 0 THEN
--      IF p_number_of_copies > 0 THEN
--         g_print_status := FND_REQUEST.SET_PRINT_OPTIONS
--              (p_printer,
--               p_user_print_style,
--               p_number_of_copies, TRUE, 'N');
--      END IF;
--      g_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
--           ('GR', 'GRRPT030_DOC', '', '', FALSE, g_session_id,
-- Bug #1673690 (JKB)
--            g_default_document, l_language_code, CHR(0),
--            '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '',
--            '', '', '', '', '', '', '', '', '', '');
--   END IF;
-- Bug #1902822 (JKB) Commented above.
/*
**                      Get the session id and clear print work table
*/
   SELECT       gr_work_build_docs_s.nextval INTO g_session_id
   FROM         dual;
-- Bug #1902822 (JKB) Added above.

/*
**             Now get the next row
*/
         FETCH c_get_line_details INTO LocalDetailRecord;
      END LOOP;
   ELSE
     OPEN c_get_line_message;
     LOOP
       FETCH c_get_line_message INTO LocalLineRecord;
       EXIT WHEN c_get_line_message%NOTFOUND;
       FND_FILE.PUT(FND_FILE.LOG, LocalLineRecord.message);
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
     END LOOP;
     CLOSE c_get_line_message;

   END IF;
   CLOSE c_get_line_details;
/*
**			Update the header status to Print Completed
*/
   UPDATE	gr_selection_header
   SET		status = 6
   WHERE	batch_no = p_batch_number;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;
/*
**		Process all flag set to 1 means automatically chain
**		to process the selected lines.
*/
   IF p_process_all_flag = 1 THEN
      /* l_return_status := FND_API.G_RET_STS_SUCCESS; */
      /*utl_file.put_line(pg_fp, 'process '|| p_process_all_flag);*/
      Update_Dispatch_History
				(errbuf,
				 retcode,
				 p_commit,
				 p_init_msg_list,
				 p_validation_level,
				 p_api_version,
				 p_batch_number,
				 l_return_status,
				 x_msg_count,
				 x_msg_data);
      IF l_return_status <> 'S' THEN
         RAISE Update_History_Error;
      END IF;
   END IF;

EXCEPTION

   WHEN Incompatible_API_Version_Error THEN
	  Handle_Error_Messages
				('GR_API_VERSION_ERROR',
				 'VERSION',
				 p_api_version,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN Batch_Number_Null_Error THEN
	  Handle_Error_Messages
				('GR_NULL_BATCH_NUMBER',
				 '',
				 '',
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN Invalid_Batch_Number_Error THEN
	  Handle_Error_Messages
				('GR_INVALID_BATCH_NUMBER',
				 'BATCH',
				 p_batch_number,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN Invalid_Batch_Status_Error THEN
	  Handle_Error_Messages
				('GR_INVALID_BATCH_STATUS',
				 'STATUS',
				 GlobalBatchHeader.status,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN Update_History_Error THEN
	  Handle_Error_Messages
				('GR_UNEXPECTED_ERROR',
				 'TEXT',
				 l_msg_data,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN Other_API_Error THEN
	   Handle_Error_Messages
				('GR_UNEXPECTED_ERROR',
				 'TEXT',
				 l_msg_data,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);
     IF p_called_by_form = 'F' THEN
       X_return_status := l_return_status;
     ELSE
	 APP_EXCEPTION.Raise_Exception;
     END IF;
   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	  /*l_code_block := SUBSTR(SQLERRM, 1, 200);*/
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);
      APP_EXCEPTION.Raise_Exception;
/*utl_file.fflush(pg_fp);
      				utl_file.fclose(pg_fp);*/
END Process_Selections;
/*
**		This procedure updates the dispatch history tables for the
**		batch. The selections and print should have been carried out
**		before this procedure is run.
*/
PROCEDURE Update_Dispatch_History
				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_batch_number IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_COMMIT			VARCHAR2(1);
L_CALLED_BY_FORM	VARCHAR2(1);
L_ROWID				VARCHAR2(18);
L_RETURN_STATUS		VARCHAR2(1);
L_STATUS		VARCHAR2(1);
L_MSG_DATA			VARCHAR2(1000);
L_KEY_EXISTS		VARCHAR2(1);
L_BLANK_ATTRIBUTE	gr_dispatch_histories.attribute1%TYPE;
L_BLANK_CATEGORY	gr_dispatch_histories.attribute_category%TYPE;
L_MSDS_DATE			gr_dispatch_histories.date_msds_sent%TYPE;

L_API_NAME			CONSTANT VARCHAR2(30) := 'Update Dispatch History';

L_CURRENT_DATE		CONSTANT DATE := sysdate;
L_LANGUAGE_CODE		gr_document_print.language%TYPE;

pg_fp   		utl_file.file_type;
/*
** 	Numeric Variables
*/
L_ORACLE_ERROR		NUMBER;
L_API_VERSION		CONSTANT NUMBER := 1.0;
L_USER_ID			NUMBER;


/*
**	Exceptions
*/
BATCH_NUMBER_NULL_ERROR			EXCEPTION;
INVALID_BATCH_STATUS_ERROR		EXCEPTION;
INCOMPATIBLE_API_VERSION_ERROR	EXCEPTION;
INVALID_BATCH_NUMBER_ERROR		EXCEPTION;
DISPATCH_HISTORY_INSERT_ERROR	EXCEPTION;

/*
**	Define the cursors
**
**	Get the batch details
*/
CURSOR c_get_batch_details
 IS
   SELECT sd.batch_no,
          sd.order_no,
          sd.order_line_number,
          sd.document_code,
          sd.item_code,
          sd.print_flag,
          sd.recipient_code,
          sd.date_msds_sent,
          sd.user_id,
          sd.user_override
   FROM	 gr_selection sd
   WHERE sd.batch_no = p_batch_number;
BatchDetails           c_get_batch_details%ROWTYPE;
/*
**   Check the recipient exists
*/
CURSOR c_get_recipient
 IS
   SELECT ri.recipient_code
   FROM	  gr_recipient_info ri
   WHERE  ri.recipient_code = BatchDetails.recipient_code;
LocalRecipientRecord	c_get_recipient%ROWTYPE;
/*
**	Get the customer name from the OPM Customer table
*/
CURSOR c_get_customer_name
 IS
   SELECT cm.cust_name
   FROM	  op_cust_mst cm
   WHERE  cm.cust_no = BatchDetails.recipient_code;
LocalCustRecord         c_get_customer_name%ROWTYPE;

CURSOR c_get_language_code
IS
  SELECT  language
  FROM    gr_document_print
  WHERE   document_code = BatchDetails.document_code;
LocalLangRecord         c_get_language_code%ROWTYPE;

/*
** Bug 2342375 Mercy Thomas 08/15/2002 Added the following code columns Recipeint_code and Item_Code to the cursor c_get_status
*/

CURSOR c_get_status
IS
   SELECT recipient_code,
          item_code,
          line_status
   FROM   gr_selection
   WHERE  batch_no = p_batch_number;
LocalStatRecord        c_get_status%ROWTYPE;
/*
** Bug 2342375 Mercy Thomas 08/15/2002 End the code changes
*/

v_item_code        GR_ITEM_GENERAL.ITEM_CODE%TYPE;

CURSOR c_get_item
 IS
   SELECT item_code
   FROM   gr_item_general
   WHERE  item_code = v_item_code;
ItemRecord             c_get_item%ROWTYPE;

/*	Get the generic item information */
CURSOR c_get_generic_item
 IS
   SELECT  ig1.item_code,
           gi.item_no
   FROM    gr_item_general ig1,
           gr_generic_items_b gi
   WHERE   gi.item_no = v_item_code
   AND     gi.item_code = ig1.item_code;
GenericRecord          c_get_generic_item%ROWTYPE;

l_item_code        GR_ITEM_GENERAL.ITEM_CODE%TYPE;
t_item_code        GR_ITEM_GENERAL.ITEM_CODE%TYPE;
t_recipient_code   GR_RECIPIENT_INFO.RECIPIENT_CODE%TYPE;

/*
** Bug 2342375 Mercy Thomas 08/15/2002 End the code changes
*/

BEGIN

/*     Standard API Start */

   SAVEPOINT Update_Dispatch_History;
   l_code_block := 'Initialize';
   l_blank_attribute := NULL;

/*     Initialize the message list if true */

   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

/*     Check the API version passed in matches the
**     internal API version.
*/
   IF NOT FND_API.Compatible_API_Call
                                 (l_api_version,
                                  p_api_version,
                                  l_api_name,
                                  g_pkg_name) THEN
      RAISE Incompatible_API_Version_Error;
   END IF;

/*    Set return status to successful */

   l_return_status := FND_API.G_RET_STS_SUCCESS;

/*    Check the passed in batch number is not null
**    and exists on the batch selection header.
*/
   l_code_block := 'Validate the batch number';
   g_batch_number := p_batch_number;

   IF g_batch_number IS NULL THEN
      RAISE Batch_Number_Null_Error;
   ELSE
      OPEN g_get_batch_status;
      FETCH g_get_batch_status INTO GlobalBatchHeader;
      IF g_get_batch_status%NOTFOUND THEN
         CLOSE g_get_batch_status;
         RAISE Invalid_Batch_Number_Error;
      ELSE
         IF GlobalBatchHeader.status <> 6 THEN
            CLOSE g_get_batch_status;
            RAISE Invalid_Batch_Status_Error;
         ELSE
/*
**    Now update the batch header status to in process
*/

            CLOSE g_get_batch_status;
            l_code_block := 'Update the batch header';
            UPDATE  gr_selection_header
            SET     status = 7
            WHERE   batch_no = p_batch_number;

            FND_FILE.PUT(FND_FILE.LOG, l_code_block);
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
/*
**     Now process the details and update dispatch history
*/
            l_code_block := 'Process the batch details';
            FND_FILE.PUT(FND_FILE.LOG, l_code_block);
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
            OPEN c_get_batch_details;
            FETCH c_get_batch_details INTO BatchDetails;
            WHILE c_get_batch_details%FOUND LOOP
            IF BatchDetails.print_flag = 'Y' OR
              (BatchDetails.print_flag = 'N' AND
               BatchDetails.user_override = 'Y') THEN
               l_code_block := 'Updating ' || BatchDetails.order_no;
               l_code_block := l_code_block || ' ' || BatchDetails.item_code;
               FND_FILE.PUT(FND_FILE.LOG, l_code_block);
               FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
               l_commit := 'F';
               l_called_by_form := 'F';
               l_user_id := FND_GLOBAL.USER_ID;

               OPEN c_get_recipient;
               FETCH c_get_recipient INTO LocalRecipientRecord;
               IF c_get_recipient%NOTFOUND THEN
                  l_code_block := 'Write recipient record ';

                  OPEN c_get_customer_name;
                  FETCH c_get_customer_name INTO LocalCustRecord;
                  IF c_get_customer_name%NOTFOUND THEN
                     CLOSE c_get_customer_name;
                     l_code_block := 'No customer info';
                  END IF; /* c_get_customer_name Not Found */
                  CLOSE c_get_customer_name;

                  GR_RECIPIENT_INFO_PKG.Insert_Row
                                                (l_commit,
                                                 l_called_by_form,
                                                 BatchDetails.recipient_code,
                                                 LocalCustRecord.cust_name,
                                                 BatchDetails.document_code,
                                                 GlobalBatchHeader.territory_code,
                                                 '0',  /* Do not print recipient product code    */
                                                 '0',  /* Do not update address                  */
                                                 '0',  /* Do not disclose all ingredients        */
                                                 'O',  /* Print organization address on document */
                                                 'R',  /* Print documents as required            */
                                                 '',   /* No recipient specific disclosure code  */
                                                 '',   /* No recipient region code               */
                                                 '',   /* No special cover letter                */
                                                 '0',  /* No additional documents                */
                                                 '0',  /* No Other addresses to send to          */
                                                 '1',  /* Send documents to ship address         */
                                                 '0',  /* Do not send to invoice address         */
                                                 l_blank_category,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_user_id,
                                                 l_current_date,
                                                 l_user_id,
                                                 l_current_date,
                                                 l_user_id,
                                                 --LocalRecipientRecord.time_period,
                                                 l_rowid,
                                                 l_return_status,
                                                 l_oracle_error,
                                                 l_msg_data);

                  IF l_return_status <> 'S' THEN
                     RAISE Dispatch_History_Insert_Error;
                  END IF;
               END IF; /* c_get_recipient Not Found */
               CLOSE c_get_recipient;
/*
**         Set the date to the system date if NULL
*/
               IF BatchDetails.date_msds_sent IS NULL THEN
                  l_msds_date := l_current_date;
               ELSE
                  l_msds_date := BatchDetails.date_msds_sent;
               END IF; /* BatchDetails.date_msds_sent IS NULL */
               IF BatchDetails.document_code IS NOT NULL THEN
                  l_return_status := FND_API.G_RET_STS_SUCCESS;
                  FND_FILE.PUT(FND_FILE.LOG, ' Check Primary Key for Dispatch Histories ' );
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                  /*
                  ** Bug 2342375 Mercy Thomas 08/15/2002 Added the following code to check for the validity of the item code before Inserting
                  **                                     the Dispatch History Table.
                  */
                  v_item_code := BatchDetails.item_code;
                  OPEN c_get_item;
                  FETCH c_get_item INTO ItemRecord;
                  IF c_get_item%NOTFOUND THEN

                     l_code_block := 'Non Regulatory Item ' || v_item_code;
                     OPEN c_get_generic_item;
                     FETCH c_get_generic_item INTO GenericRecord;
                     IF c_get_generic_item%NOTFOUND THEN

                        l_code_block := 'Inventory Item ' || ItemRecord.item_code;
                        l_item_code := NULL;
                     ELSE
                        l_item_code  := GenericRecord.item_code;
                     END IF;
                     CLOSE c_get_generic_item;
                  ELSE
                     l_item_code := ItemRecord.item_code;
                  END IF;
                  CLOSE c_get_item;
                  /*
                  ** Bug 2342375 Mercy Thomas 08/15/2002 End of the Code Changes
                  */
                  /*
                  ** Bug 2342375 Mercy Thomas 08/15/2002 Added the following IF condition to check if the Item Code exists or not
                  */

                  IF l_item_code IS NOT NULL THEN
                  /*
                  ** Bug 2342375 Mercy Thomas 08/15/2002 End of the Code Changes
                  */

                     GR_DISPATCH_HISTORIES_PKG.Check_Primary_Key
                                                (BatchDetails.document_code,
                                                 1,  /* Document text id */
                                                 /*
                                                 ** Bug 2342375 Mercy Thomas 08/15/2002 Changed the BatchDetails.item_code to l_item_code
                                                 */
                                                 l_item_code,
                                                 /*
                                                 ** Bug 2342375 Mercy Thomas 08/15/2002 End of the Code Changes
                                                 */
                                                 BatchDetails.recipient_code,
                                                 l_msds_date,
                                                 'F',
                                                 l_rowid,
                                                 l_key_exists);
                     IF NOT FND_API.TO_BOOLEAN(l_key_exists) THEN
                        GR_DISPATCH_HISTORIES_PKG.Insert_Row
                                                (l_commit,
                                                 l_called_by_form,
                                                 BatchDetails.document_code,
                                                 1,  /* Document text id */
                                                 /*
                                                 ** Bug 2342375 Mercy Thomas 08/15/2002 Changed the BatchDetails.item_code to l_item_code
                                                 */
                                                 l_item_code,
                                                 /*
                                                 ** Bug 2342375 Mercy Thomas 08/15/2002 End of the Code Changes
                                                 */
                                                 BatchDetails.recipient_code,
                                                 l_msds_date,
                                                 1,   /* Dispatch method  */
                                                 1,   /* Cover letter text id */
                                                 l_blank_category,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_blank_attribute,
                                                 l_user_id,
                                                 l_current_date,
                                                 l_user_id,
                                                 l_current_date,
                                                 l_user_id,
                                                 l_rowid,
                                                 l_return_status,
                                                 l_oracle_error,
                                                 l_msg_data);

		        IF l_return_status <> 'S' THEN
                           RAISE Dispatch_History_Insert_Error;
                        END IF;
                     END IF; /* NOT FND_API.TO_BOOLEAN(l_key_exists) */
                  END IF; /* l_item_code IS NOT NULL */
               ELSE
                  FND_MESSAGE.SET_NAME('GR', 'GR_NULL_BATCH_NUMBER');
                  FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
               END IF; /* BatchDetails.document_code IS NOT NULL */
/*
**     Update the line status
*/
               UPDATE  gr_selection sd
               SET     sd.line_status = 8
               WHERE   sd.batch_no = BatchDetails.batch_no
               AND     sd.order_no = BatchDetails.order_no
               AND     sd.order_line_number = BatchDetails.order_line_number;
            END IF; /* BatchDetails.print_flag = 'Y' OR (BatchDetails.print_flag = 'N' AND BatchDetails.user_override = 'Y') */
/*
**				Get the next row of data
*/
            FETCH c_get_batch_details INTO BatchDetails;
            END LOOP;
/*
**      Update the header status to Updated
*/
            UPDATE  gr_selection_header
            SET	    status = 8
            WHERE   batch_no = p_batch_number;

/*
**      Getting the language code
*/
            OPEN    c_get_language_code;
            FETCH   c_get_language_code INTO LocalLangRecord;
            l_language_code := LocalLangRecord.language;
            CLOSE   c_get_language_code;

/*
**      Commit the work if the flag is set
*/
            IF FND_API.To_Boolean(p_commit) THEN
               COMMIT WORK;
            END IF;
-- Bug #1902822 (JKB) Added above.
/*
**       Now submit the print job.
*/
   /*       IF p_number_of_copies > 0 THEN
               g_print_status := FND_REQUEST.SET_PRINT_OPTIONS
                                     (p_printer,
                                      p_user_print_style,
                                      p_number_of_copies,
                                      TRUE,
                                      'N');
            END IF;
   */

/* Bug #2286375 Gk Changes*/
            OPEN c_get_status;
            FETCH c_get_status INTO LocalStatRecord;
            WHILE c_get_status%FOUND LOOP
               l_status := LocalStatRecord.line_status;
               /*
               ** Bug 2342375 Mercy Thomas 08/15/2002 Added the following code into the Loop. As the Dispatch History is being Printed
               **                                     only for the last Item Code or Recipient code fetched by the Cursor LocalRecipienRecord.
               */
               v_item_code := LocalStatRecord.item_code;
               OPEN c_get_item;
               FETCH c_get_item INTO ItemRecord;
               IF c_get_item%NOTFOUND THEN

                  l_code_block := 'Non Regulatory Item ' || v_item_code;
                  OPEN c_get_generic_item;
                  FETCH c_get_generic_item INTO GenericRecord;
                  IF c_get_generic_item%NOTFOUND THEN

                     l_code_block := 'Inventory Item ' || ItemRecord.item_code;
                     t_item_code := NULL;
                  ELSE
                     t_item_code  := GenericRecord.item_code;
                  END IF;
                  CLOSE c_get_generic_item;
               ELSE
                  t_item_code := ItemRecord.item_code;
               END IF;
               CLOSE c_get_item;
               IF (t_item_code IS NOT NULL or LocalStatRecord.recipient_code IS NOT NULL) THEN
                  IF l_status = 8 THEN
                     g_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
                                                     ('GR', 'GRRPT024', '', '', FALSE, 0,
-- Bug #1673690 (JKB)
                                                      LocalStatRecord.recipient_code,
                                                      LocalStatRecord.recipient_code,
                                                      t_item_code, t_item_code,
                                                      CHR(0), g_session_id, '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '',
                                                      '', '', '', '', '', '', '', '', '', '');


                     IF FND_API.To_Boolean(p_commit) THEN
                        COMMIT WORK;
                     END IF;
                 END IF;
               END IF;
               /*
               ** Bug 2342375 Mercy Thomas 08/15/2002 End of the code changes
               */

               FETCH c_get_status INTO LocalStatRecord;
            END LOOP;
            CLOSE c_get_status;
        END IF;
      END IF;
   END IF;

EXCEPTION

   WHEN Invalid_Batch_Status_Error THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        Handle_Error_Messages
                    ('GR_INVALID_BATCH_STATUS',
                     'STATUS',
                     GlobalBatchHeader.status,
                     x_msg_count,
                     x_msg_data,
                     x_return_status);

   WHEN Batch_Number_Null_Error THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        Handle_Error_Messages
                    ('GR_NULL_BATCH_NUMBER',
                     '',
                     '',
                     x_msg_count,
                     x_msg_data,
                     x_return_status);

   WHEN Incompatible_API_Version_Error THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        Handle_Error_Messages
                    ('GR_API_VERSION_ERROR',
                     'VERSION',
                     p_api_version,
                     x_msg_count,
                     x_msg_data,
                     x_return_status);

   WHEN Invalid_Batch_Number_Error THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        Handle_Error_Messages
                    ('GR_INVALID_BATCH_NUMBER',
                     'BATCH',
                     p_batch_number,
                     x_msg_count,
                     x_msg_data,
                     x_return_status);

   WHEN Dispatch_History_Insert_Error THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        Handle_Error_Messages
                    ('GR_UNEXPECTED_ERROR',
                     'TEXT',
                     l_msg_data,
                     x_msg_count,
                     x_msg_data,
                     x_return_status);

   WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT Update_Dispatch_History;
        l_oracle_error := SQLCODE;
        l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
        FND_MESSAGE.SET_NAME('GR',
                             'GR_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('TEXT',
                              l_code_block||sqlerrm,
                              FALSE);
END Update_Dispatch_History;
/*
**   This procedure takes the input from form GRFRM037 and processes the
**   recipient and item selections to print cover letters and documents.
**
**   p_items_to_print indicates if master items or inventriy items or both
**   are to be printed.
*/
PROCEDURE Print_Recipients
				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
				 p_recipient_from IN VARCHAR2,
				 p_recipient_to IN VARCHAR2,
				 p_item_code_from IN VARCHAR2,
				 p_item_code_to IN VARCHAR2,
				 p_changed_after IN VARCHAR2,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_items_to_print IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
  IS

/*
**	Alpha Variables
*/
L_CODE_BLOCK		VARCHAR2(2000);
L_RETURN_STATUS		VARCHAR2(1);
L_MSG_DATA			VARCHAR2(2000);
L_PRINT_COUNT		NUMBER(5) DEFAULT 0;

L_LANGUAGE_CODE		FND_LANGUAGES.language_code%TYPE;

/*
**	Number Variables
*/
L_ORACLE_ERROR		NUMBER;

/*
**	Date Variables
*/
L_CHANGED_AFTER		DATE;

/*
**	Exceptions
*/
OTHER_API_ERROR			EXCEPTION;

/*
**	Cursors
**
**	Get the recipient range
*/
CURSOR c_get_recipient_range
 IS
   SELECT	ri.recipient_code,
			   ri.recipient_name,
   			ri.document_code,
           ri.document_print_frequency,
			   ri.disclosure_code,
			   ri.region_code,
			   ri.territory_code,
			   ri.shipping_address,
			   ri.invoice_address,
			   ri.additional_address_flag,
			   cp.language,
			   cp.document_code country_document
   FROM		gr_recipient_info ri,
			   gr_country_profiles cp
   WHERE	ri.recipient_code >= p_recipient_from
   AND		ri.recipient_code <= p_recipient_to
   AND		ri.territory_code = cp.territory_code;
LocalRecipient			c_get_recipient_range%ROWTYPE;

/*
**	Get the region language details
*/
CURSOR c_get_region_language
 IS
   SELECT	rl.language
   FROM		gr_region_languages rl
   WHERE	rl.region_code = LocalRecipient.region_code;
LocalRgnLangRecord		c_get_region_language%ROWTYPE;

/*
**	Get the item code
*/
CURSOR c_get_item
 IS
   SELECT	ig1.item_code
   FROM		gr_item_general ig1
   WHERE	ig1.item_code >= p_item_code_from
   AND		ig1.item_code <= p_item_code_to
   AND		(ig1.ingredient_flag = 'N'
                   OR (ig1.ingredient_flag = 'Y'
                       AND p_item_code_from = p_item_code_to));
LocalItemRec				c_get_item%ROWTYPE;

/*
**	Get the item code and the document.
*/
CURSOR c_get_item_range
 IS
   SELECT	ids.item_code,
			   ids.last_doc_update_date
   FROM     gr_item_doc_statuses ids
   WHERE	ids.item_code = LocalItemRec.item_code
   AND		ids.document_code = g_default_document;
LocalItem				c_get_item_range%ROWTYPE;
/*
**	Get the customer address id
*/
CURSOR c_get_cust_address
 IS
   SELECT	cu.addr_id
   FROM		op_cust_mst cu
   WHERE	cu.cust_no = LocalRecipient.recipient_code;
LocalCustRecord		c_get_cust_address%ROWTYPE;
/*
**   Get the inventory items for a specified master item
*/
CURSOR c_get_master_list
 IS
   SELECT   gib.item_code,
	          gib.item_no
	 FROM     gr_generic_items_b gib
	 WHERE    gib.item_code = LocalItem.item_code;
/*
**   Get the master item for a specified inventory item
*/
CURSOR c_get_invent_items
 IS
   SELECT   gib.item_code,
	          gib.item_no
	 FROM     gr_generic_items_b gib
	 WHERE    gib.item_no >= p_item_code_from
	 AND      gib.item_no <= p_item_code_to;
LocalInventList    c_get_invent_items%ROWTYPE;

BEGIN
/*
**		Initialize
*/
   l_code_block := 'Init';
   l_changed_after := FND_DATE.CANONICAL_TO_DATE(p_changed_after);
g_report_type := 3;
/*
**			Get the session id and clear print work table
*/
   SELECT 	gr_work_build_docs_s.nextval INTO g_session_id
   FROM 	dual;

   l_code_block := 'Session id: ' || TO_CHAR(g_session_id);

   FND_FILE.PUT(FND_FILE.LOG,l_code_block);
   FND_FILE.NEW_LINE(FND_FILE.LOG,1);

   l_return_status := 'S';
   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
				('F',
				 g_session_id,
				 l_return_status,
				 l_oracle_error,
				 l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Other_API_Error;
   END IF;
/*
**			Process the recipient range
*/
   OPEN c_get_recipient_range;
   FETCH c_get_recipient_range INTO LocalRecipient;
   IF c_get_recipient_range%FOUND THEN
      WHILE c_get_recipient_range%FOUND LOOP
         g_recipient_code := LocalRecipient.recipient_code;
	       IF LocalRecipient.document_code IS NULL THEN
		       g_default_document := LocalRecipient.country_document;
		    ELSE
		       g_default_document := LocalRecipient.document_code;
		    END IF;

		    IF p_items_to_print = 'M' OR
			    p_items_to_print = 'S' OR
				 p_items_to_print = 'A' THEN
		       OPEN c_get_item;
		       FETCH c_get_item INTO LocalItemRec;
		       IF c_get_item%FOUND THEN
		          WHILE c_get_item%FOUND LOOP
				  FND_FILE.PUT(FND_FILE.LOG,' PROCESSING ITEM '||LocalItemRec.item_code);
				  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                    g_doc_item_code := LocalItemRec.item_code;
 		          	OPEN c_get_item_range;
		       	FETCH c_get_item_range INTO LocalItem;
		       	IF c_get_item_range%NOTFOUND THEN
				  FND_FILE.PUT(FND_FILE.LOG,'   Document ' || g_default_document || ' not defined for item '||LocalItemRec.item_code);
				  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
				ELSE
			          IF l_changed_after IS NOT NULL AND
			             LocalItem.last_doc_update_date <= l_changed_after THEN
				          l_code_block := 'Do not print';
			          ELSE
			             l_code_block := 'Print this recipient ' || LocalRecipient.recipient_code;
                     FND_FILE.PUT(FND_FILE.LOG,l_code_block);
                     FND_FILE.NEW_LINE(FND_FILE.LOG,1);
/*
**			Print using the default language if the region code is null.
*/
				          IF LocalRecipient.region_code IS NULL THEN
   				          l_language_code := LocalRecipient.language;
				             IF LocalRecipient.shipping_address = '1' OR
				                LocalRecipient.invoice_address = '1' THEN

                           l_code_block := 'Print the shipping or invoice address';
                           FND_FILE.PUT(FND_FILE.LOG,l_code_block);
                           FND_FILE.NEW_LINE(FND_FILE.LOG,1);

					             OPEN c_get_cust_address;
						          FETCH c_get_cust_address INTO LocalCustRecord;
						          IF c_get_cust_address%FOUND THEN

   								/* Fix for B1270176 */
								l_return_status := 'S';
								GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
												('F',
												 g_session_id,
												 l_return_status,
												 l_oracle_error,
												 l_msg_data);

								IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								END IF;

						             l_return_status := 'S';

						             Read_And_Print_Cover_Letter
										      (LocalRecipient.language,
						                   LocalItem.item_code,
										       LocalRecipient.recipient_code,
										       'O',
										       '',
										       LocalCustRecord.addr_id,
										       l_return_status);

							          IF l_return_status <> 'S' THEN
                                 FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 1');
                                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

							             RAISE Other_API_Error;
							          END IF;
/*
**                            Print the letter and increment the session id
*/
										 l_return_status := 'S';
                     g_cover_letter := 'Y';
										 Submit_Print_Request
										              (p_printer,
										              	p_user_print_style,
															p_number_of_copies,
															g_default_document,
															l_language_code,
															l_return_status);

										 IF l_return_status <> 'S' THEN
										    FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										 END IF;

								/* Fix for B1270176 */
								l_return_status := 'S';
							      GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
												('F',
												 g_session_id,
												 l_return_status,
												 l_oracle_error,
												 l_msg_data);

								IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								END IF;

						             l_return_status := 'S';
						             Print_Document_Selection
										               (g_default_document,
										                LocalItem.item_code,
										                LocalRecipient.language,
										                LocalRecipient.disclosure_code,
										                l_return_status);
						             IF l_return_status <> 'S' THEN
                                 FND_FILE.PUT(FND_FILE.LOG,'Document print error - A');
                                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                RAISE Other_API_Error;
                              ELSE
                                 l_print_count := l_print_count + 1;
						             END IF;
/*
**                            Print the document and increment the session id
*/
										 l_return_status := 'S';
                                          g_cover_letter := 'N';
										 Submit_Print_Request
										              (p_printer,
										              	p_user_print_style,
															p_number_of_copies,
															g_default_document,
															l_language_code,
															l_return_status);

										 IF l_return_status <> 'S' THEN
										    FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										 END IF;
/*
**                               Process inventory items if print all
*/
										 IF p_items_to_print = 'A' THEN
										    l_code_block := 'Process generics for ' || LocalItem.item_code;
										 	 OPEN c_get_master_list;
											 FETCH c_get_master_list INTO LocalInventList;
											 IF c_get_master_list%FOUND THEN
											    WHILE c_get_master_list%FOUND LOOP
                                                g_doc_item_code := LocalInventList.item_no;
												/* Fix for B1270176 */
												l_return_status := 'S';
										   		GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
																('F',
																 g_session_id,
																 l_return_status,
																 l_oracle_error,
																 l_msg_data);

												IF l_return_status <> 'S' THEN
												  RAISE Other_API_Error;
												END IF;

						                      l_return_status := 'S';
						                      Print_Document_Selection
										               (g_default_document,
										                LocalInventList.item_no,
										                LocalRecipient.language,
										                LocalRecipient.disclosure_code,
										                l_return_status);
						                      IF l_return_status <> 'S' THEN
                                          FND_FILE.PUT(FND_FILE.LOG,'Document print error - B');
                                          FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                         RAISE Other_API_Error;
                                       ELSE
                                          l_print_count := l_print_count + 1;
						                      END IF;
/*
**                                     Print the document and increment the session id
*/
										          l_return_status := 'S';
                                                  g_cover_letter := 'N';
										          Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										          IF l_return_status <> 'S' THEN
										             FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										          END IF;
										 	       FETCH c_get_master_list INTO LocalInventList;
												 END LOOP;
											 END IF;
											 /* Fix for B1270176 */
											 CLOSE c_get_master_list;
										 END IF;
					             END IF;
						          CLOSE c_get_cust_address;
					          END IF;

					          IF LocalRecipient.additional_address_flag = '1' THEN
					             OPEN g_get_other_addresses;
						          FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
						          IF g_get_other_addresses%FOUND THEN
						             WHILE g_get_other_addresses%FOUND LOOP

                                 l_code_block := 'Other Addresses ';
                                 FND_FILE.PUT(FND_FILE.LOG,l_code_block);
                                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

								/* Fix for B1270176 */
								l_return_status := 'S';
								GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
												('F',
												 g_session_id,
												 l_return_status,
												 l_oracle_error,
												 l_msg_data);
								IF l_return_status <> 'S' THEN
      							  RAISE Other_API_Error;
								END IF;

						                l_return_status := 'S';
						                Read_And_Print_Cover_Letter
										            (LocalRecipient.language,
						                         LocalItem.item_code,
										             LocalRecipient.recipient_code,
										             'O',
										             '',
										             GlobalOtherAddrRecord.addr_id,
										             l_return_status);
							             IF l_return_status <> 'S' THEN
                                    FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 2');
                                    FND_FILE.NEW_LINE(FND_FILE.LOG,1);

							                RAISE Other_API_Error;
							             END IF;
/*
**                               Print the letter and increment the session id
*/
										    l_return_status := 'S';
                                            g_cover_letter := 'Y';
										    Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										    IF l_return_status <> 'S' THEN
										       FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										    END IF;

										/* Fix for B1270176*/
										l_return_status := 'S';
									      GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
													('F',
													 g_session_id,
													 l_return_status,
													 l_oracle_error,
													 l_msg_data);

										IF l_return_status <> 'S' THEN
									        RAISE Other_API_Error;
										END IF;

						                l_return_status := 'S';
						                Print_Document_Selection
										            (g_default_document,
										             LocalItem.item_code,
										             LocalRecipient.language,
										             LocalRecipient.disclosure_code,
										             l_return_status);
						                IF l_return_status <> 'S' THEN
                                    FND_FILE.PUT(FND_FILE.LOG,'Document print error - C');
                                    FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                   RAISE Other_API_Error;
                                 ELSE
                                    l_print_count := l_print_count + 1;
						                END IF;
/*
**                               Print the document and increment the session id
*/
										    l_return_status := 'S';
                                            g_cover_letter := 'N';
										    Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										    IF l_return_status <> 'S' THEN
										       FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										    END IF;
/*
**                               Process inventory items if print all
*/
										    IF p_items_to_print = 'A' THEN
										       l_code_block := 'Process generics for ' || LocalItem.item_code;
										 	    OPEN c_get_master_list;
											    FETCH c_get_master_list INTO LocalInventList;
											    IF c_get_master_list%FOUND THEN
											       WHILE c_get_master_list%FOUND LOOP
                                                     g_doc_item_code := LocalInventList.item_no;
									   /* Fix for B1270176 */
									   l_return_status := 'S';
									   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
														('F',
														 g_session_id,
														 l_return_status,
														 l_oracle_error,
														 l_msg_data);

									   IF l_return_status <> 'S' THEN
									      RAISE Other_API_Error;
									   END IF;
						                         l_return_status := 'S';
						                         Print_Document_Selection
										               (g_default_document,
										                LocalInventList.item_no,
										                LocalRecipient.language,
										                LocalRecipient.disclosure_code,
										                l_return_status);
						                         IF l_return_status <> 'S' THEN
                                             FND_FILE.PUT(FND_FILE.LOG,'Document print error - D');
                                             FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                            RAISE Other_API_Error;
                                          ELSE
                                             l_print_count := l_print_count + 1;
						                         END IF;
/*
**                                        Print the document and increment the session id
*/
										             l_return_status := 'S';
                                                     g_cover_letter := 'N';
										             Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										             IF l_return_status <> 'S' THEN
										                FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											             FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										             END IF;
										 	          FETCH c_get_master_list INTO LocalInventList;
												    END LOOP;
											    END IF;
											    /* Fix for B1270176 */
											    CLOSE c_get_master_list;
										    END IF;
						                FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
							          END LOOP;
						          END IF;
						          CLOSE g_get_other_addresses;
					          END IF;
				          ELSE
/*
**			Print using the languages for the region
*/
				             l_code_block := 'Print for regions';
                        FND_FILE.PUT(FND_FILE.LOG,l_code_block);
                        FND_FILE.NEW_LINE(FND_FILE.LOG,1);

					          OPEN c_get_region_language;
					          FETCH c_get_region_language INTO LocalRgnLangRecord;
					          IF c_get_region_language%FOUND THEN
					             WHILE c_get_region_language%FOUND LOOP
						             l_language_code := LocalRgnLangRecord.language;
				                   IF LocalRecipient.shipping_address = '1' OR
				                      LocalRecipient.invoice_address = '1' THEN
					                   OPEN c_get_cust_address;
						                FETCH c_get_cust_address INTO LocalCustRecord;
						                IF c_get_cust_address%FOUND THEN

								   /* Fix for B1270176 */
								   l_return_status := 'S';
								   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
												('F',
												 g_session_id,
												 l_return_status,
												 l_oracle_error,
												 l_msg_data);

								   IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								   END IF;

						                   l_return_status := 'S';
						                   Read_And_Print_Cover_Letter
										                           (l_language_code,
										                            LocalItem.item_code,
										                            LocalRecipient.recipient_code,
										                            'O',
										                            '',
										                            LocalCustRecord.addr_id,
										                            l_return_status);
							                IF l_return_status <> 'S' THEN
                                       FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 3');
                                       FND_FILE.NEW_LINE(FND_FILE.LOG,1);

													 RAISE Other_API_Error;
							                END IF;
/*
**                                  Print the letter and increment the session id
*/
										       l_return_status := 'S';
                                               g_cover_letter := 'Y';
										       Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										       IF l_return_status <> 'S' THEN
										          FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										       END IF;

											   /* Fix for B1270176  */
											   l_return_status := 'S';
											   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
															('F',
															 g_session_id,
															 l_return_status,
															 l_oracle_error,
															 l_msg_data);
											   IF l_return_status <> 'S' THEN
											      RAISE Other_API_Error;
											   END IF;

						                   l_return_status := 'S';
						                   Print_Document_Selection
										                      (g_default_document,
										                       LocalItem.item_code,
										                       l_language_code,
										                       LocalRecipient.disclosure_code,
										                       l_return_status);
						                   IF l_return_status <> 'S' THEN
                                       FND_FILE.PUT(FND_FILE.LOG,'Document print error - E');
                                       FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                      RAISE Other_API_Error;
                                    ELSE
                                       l_print_count := l_print_count + 1;
						                   END IF;
/*
**                                  Print the document and increment the session id
*/
										       l_return_status := 'S';
                                               g_cover_letter := 'N';
										       Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										       IF l_return_status <> 'S' THEN
										          FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										       END IF;
/*
**                               Process inventory items if print all
*/
										       IF p_items_to_print = 'A' THEN
										          l_code_block := 'Process generics for ' || LocalItem.item_code;
										 	       OPEN c_get_master_list;
											       FETCH c_get_master_list INTO LocalInventList;
											       IF c_get_master_list%FOUND THEN
											          WHILE c_get_master_list%FOUND LOOP
                                                      g_doc_item_code := LocalInventList.item_no;
										   /* Fix for B1270176 */
										   l_return_status := 'S';
										   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
															('F',
															 g_session_id,
															 l_return_status,
															 l_oracle_error,
															 l_msg_data);

										   IF l_return_status <> 'S' THEN
										      RAISE Other_API_Error;
										   END IF;

						                            l_return_status := 'S';
						                            Print_Document_Selection
										                             (g_default_document,
										                              LocalInventList.item_no,
										                              LocalRecipient.language,
										                              LocalRecipient.disclosure_code,
										                              l_return_status);
						                            IF l_return_status <> 'S' THEN
                                                FND_FILE.PUT(FND_FILE.LOG,'Document print error - F');
                                                FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                               RAISE Other_API_Error;
                                             ELSE
                                                l_print_count := l_print_count + 1;
						                            END IF;
/*
**                                           Print the document and increment the session id
*/
										                l_return_status := 'S';
                                                        g_cover_letter := 'N';
										                Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										                IF l_return_status <> 'S' THEN
										                   FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											                FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										                END IF;
										 	             FETCH c_get_master_list INTO LocalInventList;
												       END LOOP;
											       END IF;
											       /* Fix for B1270176 */
											       CLOSE c_get_master_list;
										       END IF;
							             END IF;
						                CLOSE c_get_cust_address;
					                END IF;

					                IF LocalRecipient.additional_address_flag = '1' THEN
					                   OPEN g_get_other_addresses;
						                FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
						                IF g_get_other_addresses%FOUND THEN
						                   WHILE g_get_other_addresses%FOUND LOOP

									   /* Fix for B1270176 */
									   l_return_status := 'S';
									   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
													('F',
													 g_session_id,
													 l_return_status,
													 l_oracle_error,
													 l_msg_data);

									   IF l_return_status <> 'S' THEN
									      RAISE Other_API_Error;
									   END IF;

						                      l_return_status := 'S';
						                      Read_And_Print_Cover_Letter
										                             (l_language_code,
										                              LocalItem.item_code,
										                              LocalRecipient.recipient_code,
										                              'O',
										                              '',
										                              GlobalOtherAddrRecord.addr_id,
										                              l_return_status);
							                   IF l_return_status <> 'S' THEN
													    FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error - 4');
                                          FND_FILE.NEW_LINE(FND_FILE.LOG,1);

							                      RAISE Other_API_Error;
							                   END IF;
/*
**                                     Print the letter and increment the session id
*/
										          l_return_status := 'S';
                                                  g_cover_letter := 'Y';
										          Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										          IF l_return_status <> 'S' THEN
										             FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										          END IF;

								   /* Fix for B1270176 */
								   l_return_status := 'S';
								   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
												('F',
												 g_session_id,
												 l_return_status,
												 l_oracle_error,
												 l_msg_data);

								   IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								   END IF;

						                      l_return_status := 'S';
						                      Print_Document_Selection
										                        (g_default_document,
										                         LocalItem.item_code,
										                         l_language_code,
										                         LocalRecipient.disclosure_code,
										                         l_return_status);
						                      IF l_return_status <> 'S' THEN
                                          FND_FILE.PUT(FND_FILE.LOG,'Document print error - G');
                                          FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                         RAISE Other_API_Error;
                                       ELSE
                                          l_print_count := l_print_count + 1;
						                      END IF;
/*
**												 Print the document and increment the session id
*/
										          l_return_status := 'S';
                                                  g_cover_letter := 'N';
										          Submit_Print_Request
										                     (p_printer,
										              	       p_user_print_style,
															       p_number_of_copies,
															       g_default_document,
															       l_language_code,
															       l_return_status);

										          IF l_return_status <> 'S' THEN
										             FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											          FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										          END IF;
/*
**                               Process inventory items if print all
*/
										          IF p_items_to_print = 'A' THEN
										             l_code_block := 'Process generics for ' || LocalItem.item_code;
										 	          OPEN c_get_master_list;
											          FETCH c_get_master_list INTO LocalInventList;
											          IF c_get_master_list%FOUND THEN
											             WHILE c_get_master_list%FOUND LOOP
                                                     g_doc_item_code := LocalInventList.item_no;
												   /* Fix for B1270176 */
												   l_return_status := 'S';
												   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
															('F',
															 g_session_id,
															 l_return_status,
															 l_oracle_error,
															 l_msg_data);

												   IF l_return_status <> 'S' THEN
												      RAISE Other_API_Error;
												   END IF;

						                               l_return_status := 'S';
						                               Print_Document_Selection
										                                (g_default_document,
										                                 LocalInventList.item_no,
										                                 LocalRecipient.language,
										                                 LocalRecipient.disclosure_code,
										                                 l_return_status);
						                               IF l_return_status <> 'S' THEN
                                                   FND_FILE.PUT(FND_FILE.LOG,'Document print error - H');
                                                   FND_FILE.NEW_LINE(FND_FILE.LOG,1);

						                                  RAISE Other_API_Error;
                                                ELSE
                                                   l_print_count := l_print_count + 1;
						                               END IF;
/*
**                                              Print the document and increment the session id
*/
										                   l_return_status := 'S';
                                                           g_cover_letter := 'N';
										                   Submit_Print_Request
										                              (p_printer,
										              	                p_user_print_style,
															                p_number_of_copies,
															                g_default_document,
															                l_language_code,
															                l_return_status);

										                   IF l_return_status <> 'S' THEN
										                      FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
											                   FND_FILE.NEW_LINE(FND_FILE.LOG,1);
										                   END IF;
										 	                FETCH c_get_master_list INTO LocalInventList;
												          END LOOP;
											          END IF;
											          /* Fix for B1270176 */
											          CLOSE c_get_master_list;
										          END IF;
						                      FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
							                END LOOP;
						                END IF;
							             CLOSE g_get_other_addresses;
					                END IF;
						             FETCH c_get_region_language INTO LocalRgnLangRecord;
					             END LOOP;
				             END IF;
					          CLOSE c_get_region_language;
				          END IF;
			          END IF;
                            END IF;
                            CLOSE c_get_item_range;
			          FETCH c_get_item INTO LocalItemRec;
			       END LOOP;
		       END IF;
		       /* Fix for B1270176 */
		       CLOSE c_get_item;
		    END IF;
/*
**      Print only the inventory items linked to the master
**      Also print if the option for a single item and there was
**      no processing of a master item.
*/
			 IF p_items_to_print = 'I' OR
			   (p_items_to_print = 'S' AND
				 l_print_count = 0)     THEN

		       l_code_block := 'Process generic items';
				 FND_FILE.PUT(FND_FILE.LOG,l_code_block);
				 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				 OPEN c_get_invent_items;
				 FETCH c_get_invent_items INTO LocalInventList;
				 IF c_get_invent_items%FOUND THEN
				    WHILE c_get_invent_items%FOUND LOOP
                        g_doc_item_code := LocalInventList.item_no;
					    IF LocalRecipient.region_code IS NULL THEN
				          l_language_code := LocalRecipient.language;
		       			 IF LocalRecipient.shipping_address = '1' OR
							    LocalRecipient.invoice_address = '1' THEN
				 				 OPEN c_get_cust_address;
								 FETCH c_get_cust_address INTO LocalCustRecord;
								 IF c_get_cust_address%FOUND THEN

								   /* Fix for B1270176 */
								   l_return_status := 'S';
								   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
											('F',
											 g_session_id,
											 l_return_status,
											 l_oracle_error,
											 l_msg_data);

								   IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								   END IF;

				                l_return_status := 'S';
				                Read_And_Print_Cover_Letter
				                                   (l_language_code,
				                                    LocalInventList.item_no,
				                                    LocalRecipient.recipient_code,
				                                    'O',
				                                    '',
				                                    LocalCustRecord.addr_id,
				                                    l_return_status);
				                IF l_return_status <> 'S' THEN
                              FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error');
                              FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                   RAISE Other_API_Error;
				                END IF;
/*
**                         Print the letter and increment the session id
*/
				                l_return_status := 'S';
                                g_cover_letter := 'Y';
				                Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                         IF l_return_status <> 'S' THEN
	                            FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                         END IF;

					   /* Fix for B1270176 */
					   l_return_status := 'S';
					   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
								('F',
								 g_session_id,
								 l_return_status,
								 l_oracle_error,
								 l_msg_data);

					   IF l_return_status <> 'S' THEN
					      RAISE Other_API_Error;
					   END IF;

                           l_return_status := 'S';
                           Print_Document_Selection
                                          (g_default_document,
	                                         LocalInventList.item_no,
						                          l_language_code,
						                          LocalRecipient.disclosure_code,
						                          l_return_status);
				                IF l_return_status <> 'S' THEN
                              FND_FILE.PUT(FND_FILE.LOG,'Document print error - I');
                              FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                   RAISE Other_API_Error;
				                END IF;
/*
**                         Print the document and increment the session id
*/
				                l_return_status := 'S';
                                g_cover_letter := 'N';
				                Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                         IF l_return_status <> 'S' THEN
	                            FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                         END IF;
								 ELSE
								    FND_FILE.PUT(FND_FILE.LOG,'No inv/ship address for ' || LocalRecipient.recipient_code);
									 FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                        END IF;
								 CLOSE c_get_cust_address;
							 END IF;
/*
**                      Process any other addresses
*/
                     IF LocalRecipient.additional_address_flag = '1' THEN
							    OPEN g_get_other_addresses;
							    FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
								 IF g_get_other_addresses%FOUND THEN
								    WHILE g_get_other_addresses%FOUND LOOP

								   /* Fix for B1270176 */
								   l_return_status := 'S';
								   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
										('F',
										 g_session_id,
										 l_return_status,
										 l_oracle_error,
										 l_msg_data);

								   IF l_return_status <> 'S' THEN
								      RAISE Other_API_Error;
								   END IF;

				                   l_return_status := 'S';
				                   Read_And_Print_Cover_Letter
				                                   (l_language_code,
				                                    LocalInventList.item_no,
				                                    LocalRecipient.recipient_code,
				                                    'O',
				                                    '',
				                                    LocalCustRecord.addr_id,
				                                    l_return_status);
				                   IF l_return_status <> 'S' THEN
                                 FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error');
                                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                      RAISE Other_API_Error;
				                   END IF;
/*
**                      Print the letter and increment the session id
*/
				                   l_return_status := 'S';
                                   g_cover_letter := 'Y';
				                   Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                            IF l_return_status <> 'S' THEN
	                               FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                            FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                            END IF;

					   /* Fix for B1270176 */
					   l_return_status := 'S';
					   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
									('F',
									 g_session_id,
									 l_return_status,
									 l_oracle_error,
									 l_msg_data);

					   IF l_return_status <> 'S' THEN
					      RAISE Other_API_Error;
					   END IF;

                              l_return_status := 'S';
                              Print_Document_Selection
                                          (g_default_document,
	                                         LocalInventList.item_no,
						                          l_language_code,
						                          LocalRecipient.disclosure_code,
						                          l_return_status);
				                   IF l_return_status <> 'S' THEN
                                 FND_FILE.PUT(FND_FILE.LOG,'Document print error - J');
                                 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                      RAISE Other_API_Error;
				                   END IF;
/*
**                      Print the document and increment the session id
*/
				                   l_return_status := 'S';
                                   g_cover_letter := 'N';
				                   Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                            IF l_return_status <> 'S' THEN
	                               FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                            FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                            END IF;
								       FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
									 END LOOP;
								 END IF;
								 CLOSE g_get_other_addresses;
							 END IF;
						 ELSE
/*
**                Print for regions
*/
                     OPEN c_get_region_language;
							 FETCH c_get_region_language INTO LocalRgnLangRecord;
							 IF c_get_region_language%FOUND THEN
							    WHILE c_get_region_language%FOUND LOOP
								    l_language_code := LocalRgnLangRecord.language;
		       			       IF LocalRecipient.shipping_address = '1' OR
							          LocalRecipient.invoice_address = '1' THEN
				 				       OPEN c_get_cust_address;
								       FETCH c_get_cust_address INTO LocalCustRecord;
								       IF c_get_cust_address%FOUND THEN

									   /* Fix for B1270176 */
									   l_return_status := 'S';
									   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
													('F',
													 g_session_id,
													 l_return_status,
													 l_oracle_error,
													 l_msg_data);

									   IF l_return_status <> 'S' THEN
									      RAISE Other_API_Error;
									   END IF;

				                      l_return_status := 'S';
				                      Read_And_Print_Cover_Letter
				                                   (l_language_code,
				                                    LocalInventList.item_no,
				                                    LocalRecipient.recipient_code,
				                                    'O',
				                                    '',
				                                    LocalCustRecord.addr_id,
				                                    l_return_status);
				                      IF l_return_status <> 'S' THEN
                                    FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error');
                                    FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                         RAISE Other_API_Error;
				                      END IF;
/*
**                         Print the letter and increment the session id
*/
				                      l_return_status := 'S';
                                     g_cover_letter := 'Y';
				                      Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                               IF l_return_status <> 'S' THEN
	                                  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                               FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                               END IF;

						 /* Fix for B1270176 */
						 l_return_status := 'S';
						 GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
										('F',
										 g_session_id,
										 l_return_status,
										 l_oracle_error,
										 l_msg_data);

						 IF l_return_status <> 'S' THEN
						      RAISE Other_API_Error;
					       END IF;

                                 l_return_status := 'S';
                                 Print_Document_Selection
                                          (g_default_document,
	                                         LocalInventList.item_no,
						                          l_language_code,
						                          LocalRecipient.disclosure_code,
						                          l_return_status);
				                      IF l_return_status <> 'S' THEN
				                         RAISE Other_API_Error;
				                      END IF;
/*
**                         Print the document and increment the session id
*/
				                      l_return_status := 'S';
                                      g_cover_letter := 'N';
				                      Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                               IF l_return_status <> 'S' THEN
	                                  FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                               FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                               END IF;
								       ELSE
								          FND_FILE.PUT(FND_FILE.LOG,'No inv/ship address for ' || LocalRecipient.recipient_code);
									       FND_FILE.NEW_LINE(FND_FILE.LOG,1);
                              END IF;
								       CLOSE c_get_cust_address;
							       END IF;
/*
**                      Process any other addresses
*/
                           IF LocalRecipient.additional_address_flag = '1' THEN
							          OPEN g_get_other_addresses;
							          FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
								       IF g_get_other_addresses%FOUND THEN
								          WHILE g_get_other_addresses%FOUND LOOP

   										/* Fix for B1270176 */
										l_return_status := 'S';
									      GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
													('F',
													 g_session_id,
													 l_return_status,
													 l_oracle_error,
													 l_msg_data);

										IF l_return_status <> 'S' THEN
										      RAISE Other_API_Error;
										END IF;

				                         l_return_status := 'S';
				                         Read_And_Print_Cover_Letter
				                                   (l_language_code,
				                                    LocalInventList.item_no,
				                                    LocalRecipient.recipient_code,
				                                    'O',
				                                    '',
				                                    LocalCustRecord.addr_id,
				                                    l_return_status);
				                         IF l_return_status <> 'S' THEN
                                       FND_FILE.PUT(FND_FILE.LOG,'Cover Letter error');
                                       FND_FILE.NEW_LINE(FND_FILE.LOG,1);

				                            RAISE Other_API_Error;
				                         END IF;
/*
**                      Print the letter and increment the session id
*/
				                         l_return_status := 'S';
                                         g_cover_letter := 'Y';
				                         Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                                  IF l_return_status <> 'S' THEN
	                                     FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                                  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                                  END IF;

						   /* Fix for B1270176 */
						   l_return_status := 'S';
						   GR_PROCESS_DOCUMENTS.Clear_Worksheet_Session
											('F',
											 g_session_id,
											 l_return_status,
											 l_oracle_error,
											 l_msg_data);

						   IF l_return_status <> 'S' THEN
						      RAISE Other_API_Error;
						   END IF;

                                    l_return_status := 'S';
                                    Print_Document_Selection
                                          (g_default_document,
	                                         LocalInventList.item_no,
						                          l_language_code,
						                          LocalRecipient.disclosure_code,
						                          l_return_status);
				                         IF l_return_status <> 'S' THEN
				                            RAISE Other_API_Error;
				                         END IF;
/*
**                      Print the document and increment the session id
*/
				                         l_return_status := 'S';
                                         g_cover_letter := 'N';

				                         Submit_Print_Request
				                             (p_printer,
				     	                        p_user_print_style,
								                  p_number_of_copies,
								                  g_default_document,
								                  l_language_code,
								                  l_return_status);

	                                  IF l_return_status <> 'S' THEN
	                                     FND_FILE.PUT(FND_FILE.LOG,'Submission error for session ' || TO_CHAR(g_session_id));
		                                  FND_FILE.NEW_LINE(FND_FILE.LOG,1);
	                                  END IF;
								             FETCH g_get_other_addresses INTO GlobalOtherAddrRecord;
									       END LOOP;
								       END IF;
								       CLOSE g_get_other_addresses;
									 END IF;
		    					    FETCH c_get_region_language INTO LocalRgnLangRecord;
			 					 END LOOP;
			             END IF;
							 CLOSE c_get_region_language;
						 END IF;
						 FETCH c_get_invent_items INTO LocalInventList;
					 END LOOP;
				 END IF;
				 CLOSE c_get_invent_items;
			 END IF;
	       FETCH c_get_recipient_range INTO LocalRecipient;
      END LOOP;
   END IF;
   CLOSE c_get_recipient_range;
/*
**		Now submit the print job.
*
   IF p_number_of_copies > 0 THEN
      g_print_status := FND_REQUEST.SET_PRINT_OPTIONS
				 			(p_printer,
				 			 p_user_print_style,
			             p_number_of_copies, TRUE, 'N');
   END IF;

   g_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
							('GR', 'GRRPT030_DOC', '', '', FALSE, g_session_id,
-- Bug #1673690 (JKB)
							 g_default_document, l_language_code, CHR(0),
							  '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '',
							 '', '', '', '', '', '', '', '', '', '');
*/
EXCEPTION

   WHEN Other_API_Error THEN
	   Handle_Error_Messages
				('GR_UNEXPECTED_ERROR',
				 'TEXT',
				 l_msg_data,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN OTHERS THEN
      FND_FILE.PUT(FND_FILE.LOG,'Unhandled Exception : ' || sqlerrm);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      l_oracle_error := SQLCODE;
	  /*l_code_block := SUBSTR(SQLERRM, 1, 200);*/
	  l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_code_block||sqlerrm,
	                        FALSE);

END Print_Recipients;
/*
**
**
**
*/
PROCEDURE Insert_Selection_Row
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 p_order_id IN NUMBER,
				 p_order_line_number IN NUMBER,
				 p_document_code IN VARCHAR2,
				 p_print_flag IN VARCHAR2,
				 p_cust_no IN VARCHAR2,
				 p_shipment_no IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
  IS


/*
**Alpha Variables
*/
L_SELECTION_MESSAGE		GR_SELECTION.message%TYPE;

/*
**	Numeric Variables
*/
L_LINE_STATUS			GR_SELECTION.line_status%TYPE;
L_USER_ID				GR_SELECTION.user_id%TYPE;
L_LINES_WRITTEN     NUMBER;
/*
**   Cursors
**
**   Check to see if this row already written
*/
CURSOR c_count_lines
 IS
   SELECT COUNT(*)
	 FROM   gr_selection sd
	 WHERE  sd.batch_no = g_batch_number
	 AND    sd.order_no = p_order_id
	 AND    sd.order_line_number = p_order_line_number;

BEGIN

   x_return_status := 'S';
/*
**	 Read to see if the job, order number and line number combination
**    is already on file.
*/
   l_lines_written := 0;
	 OPEN c_count_lines;
	 FETCH c_count_lines INTO l_lines_written;
	 CLOSE c_count_lines;
/*
**    l_count_lines = zero means no match so write the row
**    otherwise put a message to the log file about a duplicate
*/

	 IF l_lines_written = 0 THEN
/*
**		Get the message string
*/
      IF p_message_code IS NOT NULL THEN
	       FND_MESSAGE.SET_NAME('GR',
	                         p_message_code);
         IF p_token_name IS NOT NULL THEN
	          FND_MESSAGE.SET_TOKEN(p_token_name,
                                  p_token_value,
					    		           FALSE);
         END IF;
	       l_selection_message := FND_MESSAGE.Get;
      END IF;
/*
**		Set the status based on the print flag.
**		If the print flag is set to 'Y' the line status
**		is selected, otherwise the line status is not
**		selected.
*/
      IF p_print_flag = 'Y' THEN
         l_line_status := 2;
      ELSE
         l_line_status := 0;
      END IF;
/*
**		Get the user id.
*/
      l_user_id := FND_GLOBAL.USER_ID;

      INSERT INTO gr_selection
      		(batch_no,
	   		 order_no,
			    order_line_number,
			    line_status,
			    document_code,
			    print_flag,
			    user_id,
			    item_code,
			    recipient_code,
			    shipment_no,
			    message,
			    user_override,
			    date_msds_sent)
		   VALUES
      		(g_batch_number,
	   		 p_order_id,
			    p_order_line_number,
			    l_line_status,
			    p_document_code,
			    p_print_flag,
			    l_user_id,
			    g_item_code,
			    p_cust_no,
			    p_shipment_no,
			    l_selection_message,
			    'N',
			    '');
   ELSE
      FND_FILE.PUT(FND_FILE.LOG,'   *** Duplicate order line record exists ***');
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      FND_FILE.PUT(FND_FILE.LOG,' Selection Insert Error:'||sqlerrm);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
      x_return_status := FND_API.G_RET_STS_ERROR;

END Insert_Selection_Row;
/*
**
**
**
**
*/
PROCEDURE Check_Selected_Line
            (x_return_status OUT NOCOPY VARCHAR2,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data OUT NOCOPY VARCHAR2)
  IS

/*
** Alphanumeric variables
*/
L_CODE_BLOCK               VARCHAR2(2000);
L_PRINT_FLAG			   VARCHAR2(2);
L_RETURN_STATUS            VARCHAR2(1);

L_CURRENT_DATE		         DATE := SYSDATE;
pg_fp		utl_file.file_type;
/*
** Numeric Variables
*/
L_ORACLE_ERROR          NUMBER;
L_TIME_PERIOD		NUMBER(3);
L_DIFF			NUMBER(3);
/*
** Exceptions
*/
SELECTION_INSERT_ERROR     EXCEPTION;


/*
** Define the cursors
**
**	Check order and line are not already selected on an
**	open batch (status 8 is completed, 9 is cancelled)
*/
CURSOR c_check_selections
 IS
   SELECT   sd.batch_no
   FROM	    gr_selection_header sh,
           gr_selection sd
   WHERE	(   (sd.order_no = g_order_number		   /* Same order and line number */
                 AND sd.order_line_number = g_order_line)
             OR (     (NOT EXISTS (SELECT 1
                                   FROM gr_recipient_info
                                   WHERE recipient_code = g_recipient_code)
			                -- AND document_print_frequency = 'A')
                      OR sh.batch_no = g_batch_number
                      )
                 AND  (sd.item_code = g_item_code			   /* Item and recipient selected */
                       AND sd.recipient_code = g_recipient_code)
                 )
            )
   AND	sd.batch_no = sh.batch_no
   AND	sh.status <> 8
   AND	sh.status <> 9
   ORDER BY sd.BATCH_NO DESC;
LocalSelection			c_check_selections%ROWTYPE;
/*
**	Get the dispatch history
*/
CURSOR c_get_last_dispatch
 IS
   SELECT	ids.rebuild_item_doc_flag,
                ids.last_doc_update_date,
	        dh.date_msds_sent
   FROM		gr_dispatch_histories dh,
		gr_item_doc_statuses ids
   WHERE	ids.item_code = g_item_code
   /* Fix for B1255401 */
   AND          dh.dispatch_method_code <> 99
   AND		ids.document_code = GlobalRecipient.document_code
   AND		dh.date_msds_sent = (SELECT MAX(dh1.date_msds_sent)
				     FROM	gr_dispatch_histories dh1
				     WHERE	dh1.item_code = g_item_code
   				     AND	dh1.document_code = GlobalRecipient.document_code
   				     AND	dh1.recipient_code = g_recipient_code);
LocalDispatchRcd 		c_get_last_dispatch%ROWTYPE;

BEGIN
 --pg_fp := utl_file.fopen('/sqlcom/log/opm115m','check.log','w');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_print_flag := 'YS';
   FND_FILE.PUT(FND_FILE.LOG,'Order:'||g_order_number||'Line:'||g_order_line||' Recip:'||g_recipient_code||'Batch:'||g_batch_number||'Item:'||g_item_code);
   FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   --utl_file.put_line(pg_fp, 'docco '||g_default_document);
   OPEN c_check_selections;
   FETCH c_check_selections INTO LocalSelection;
   IF c_check_selections%FOUND THEN
      CLOSE c_check_selections;
      l_code_block := '   Order line already selected in print job ';
      FND_FILE.PUT(FND_FILE.LOG,l_code_block);
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);
--utl_file.put_line(pg_fp, 'cblock' ||l_code_block);
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      Insert_Selection_Row
         ('GR_ORDER_ALREADY_SELECTED',
	  'CODE',
	  LocalSelection.batch_no,
	  g_order_number,
	  g_order_line,
	  g_default_document,
	  'N',
	  g_recipient_code,
	  g_shipment_number,
	  l_return_status);
	  l_print_flag := 'NO';
	  IF l_return_status <> 'S' THEN
	     RAISE Selection_Insert_Error;
	  END IF;
   ELSE
      CLOSE c_check_selections;
      l_code_block := 'Now check the item code has safety info.';
--utl_file.put_line(pg_fp, 'cblock1' ||l_code_block);
      OPEN g_get_item_safety;
      FETCH g_get_item_safety INTO GlobalSafetyRecord;
      IF g_get_item_safety%NOTFOUND THEN
         CLOSE g_get_item_safety;

	 OPEN g_get_generic_item;
	 FETCH g_get_generic_item INTO GlobalGenericRecord;
	 IF g_get_generic_item%NOTFOUND THEN
	    CLOSE g_get_generic_item;
	    l_code_block := '   No safety information for this item';
            FND_FILE.PUT(FND_FILE.LOG,l_code_block);
            FND_FILE.NEW_LINE(FND_FILE.LOG,1);
--utl_file.put_line(pg_fp, 'cblock2' ||l_code_block);
	    l_return_status := FND_API.G_RET_STS_SUCCESS;
	    l_print_flag := 'NO';
	    Insert_Selection_Row
	       ('GR_NO_SAFETY_INFO',
		'ITEM',
		g_item_code,
		g_order_number,
		g_order_line,
		g_default_document,
		'N',
		g_recipient_code,
		g_shipment_number,
		l_return_status);
		IF l_return_status <> 'S' THEN
		   RAISE Selection_Insert_Error;
		END IF;
	  ELSE
	     CLOSE g_get_generic_item;
	  END IF;
      ELSE
	  CLOSE g_get_item_safety;
      END IF;/* c_get_item_safety%NOTFOUND */
/*
**			Only need to process further if item safety information
**			is found.
*/
      IF l_print_flag = 'YS' THEN
         l_code_block := '   Check the dispatch history etc.';
	 FND_FILE.PUT(FND_FILE.LOG,l_code_block);
         FND_FILE.NEW_LINE(FND_FILE.LOG,1);
         --utl_file.put_line(pg_fp, 'cblock3' ||l_code_block);
/*
**			Get the recipient information. If not there then assume we
**			have to generate a document and build the recipient info during
**          the dispatch history update.
*/
	 OPEN g_get_recipient;
	 FETCH g_get_recipient INTO GlobalRecipient;
         IF g_get_recipient%NOTFOUND THEN
	    CLOSE g_get_recipient;
	    l_return_status := FND_API.G_RET_STS_SUCCESS;
	    IF g_default_document IS NOT NULL THEN
               l_return_status := 'S';
	          Insert_Selection_Row
		     ('GR_NO_RECIPIENT_DO_PRINT',
		      '',
		      '',
		      g_order_number,
		      g_order_line,
		      g_default_document,
		      'Y',
		      g_recipient_code,
		      g_shipment_number,
		      l_return_status);
		      IF l_return_status <> 'S' THEN
		         RAISE Selection_Insert_Error;
		      END IF;
	      ELSE
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
                 Insert_Selection_Row
		    ('GR_NO_DEFAULT_DOCUMENT',
		     'CODE',
		     g_default_country,
		     g_order_number,
		     g_order_Line,
		     '',
		     'N',
		     g_recipient_code,
		     g_shipment_number,
		     l_return_status);
		     IF l_return_status <> 'S' THEN
		        RAISE Selection_Insert_Error;
		     END IF;
	       END IF; /*g_default_document IS NOT NULL*/
	    ELSE
	       CLOSE g_get_recipient;
	       l_code_block := 'Check Recipient Print Frequency';--utl_file.put_line(pg_fp, 'cblock4' ||l_code_block);
/*
**	 Check the print frequency on the recipient.
**	 'A' - Always print.
**	 'N' - Never print.
**	 'R' - As required.
**	 'Q' - At least quarterly
**	 'S' - At least every six months
**	 'Y' - At least once a year
*/
               IF GlobalRecipient.document_print_frequency = 'A' THEN
                  l_return_status := FND_API.G_RET_STS_SUCCESS;
                  --utl_file.put_line(pg_fp, 'Always');
                  Insert_Selection_Row
		     ('GR_ALWAYS_PRINT',
		      '',
		      '',
		      g_order_number,
		      g_order_Line,
		      GlobalRecipient.document_code,
		      'Y',
		      g_recipient_code,
		      g_shipment_number,
		      l_return_status);
		      IF l_return_status <> 'S' THEN
		         RAISE Selection_Insert_Error;
		      END IF;
		ELSIF GlobalRecipient.document_print_frequency = 'N' THEN
                   l_return_status := FND_API.G_RET_STS_SUCCESS; --utl_file.put_line(pg_fp, 'never');
                   Insert_Selection_Row
		      ('GR_NEVER_PRINT',
		       '',
		       '',
		       g_order_number,
		       g_order_line,
		       GlobalRecipient.document_code,
		       'N',
		       g_recipient_code,
		       g_shipment_number,
		       l_return_status);
		       IF l_return_status <> 'S' THEN
		          RAISE Selection_Insert_Error;
		       END IF;
		 ELSE
		    OPEN c_get_last_dispatch;
		    FETCH c_get_last_dispatch INTO LocalDispatchRcd;
                    IF c_get_last_dispatch%NOTFOUND THEN
                    --utl_file.put_line(pg_fp, 'not found');
                       l_return_status := FND_API.G_RET_STS_SUCCESS;
                       Insert_Selection_Row
			  ('GR_FIRST_DISPATCH',
			   '',
			   '',
			   g_order_number,
			   g_order_line,
			   GlobalRecipient.document_code,
			   'Y',
			   g_recipient_code,
			   g_shipment_number,
			   l_return_status);
			   IF l_return_status <> 'S' THEN
			      RAISE Selection_Insert_Error;
			   END IF;
		      ELSIF LocalDispatchRcd.last_doc_update_date > LocalDispatchRcd.date_msds_sent THEN
		      --utl_file.put_line(pg_fp, 'doc_update > ');
                         l_return_status := FND_API.G_RET_STS_SUCCESS;
                         Insert_Selection_Row
			    ('GR_DOCUMENT_CHANGED',
			     'DATE',
			     TO_CHAR(LocalDispatchRcd.date_msds_sent,'DD-MON-YYYY'),
			     g_order_number,
			     g_order_line,
			     GlobalRecipient.document_code,
			     'Y',
			     g_recipient_code,
			     g_shipment_number,
			     l_return_status);
			     IF l_return_status <> 'S' THEN
			        RAISE Selection_Insert_Error;
			     END IF;
		       ELSIF GlobalRecipient.document_print_frequency = 'Q' THEN
		       --utl_file.put_line(pg_fp, 'quarter');
		       --utl_file.put_line(pg_fp, 'current_date '|| l_current_date);
		       -- utl_file.put_line(pg_fp, 'msds sent '||LocalDispatchRcd.date_msds_sent);
		       --utl_file.put_line(pg_fp, 'abs ' ||ABS(MONTHS_BETWEEN (l_current_date,
			    -- LocalDispatchRcd.date_msds_sent)) );
			  IF ABS(MONTHS_BETWEEN (l_current_date,
			     LocalDispatchRcd.date_msds_sent)) >= 3 THEN
                             l_return_status := FND_API.G_RET_STS_SUCCESS;
                              --utl_file.put_line(pg_fp, 'in ');
                             Insert_Selection_Row
			        ('GR_DISPATCH_QUARTERLY',
				 '',
				 '',
				 g_order_number,
				 g_order_Line,
				 GlobalRecipient.document_code,
				 'Y',
				  g_recipient_code,
				  g_shipment_number,
				  l_return_status);
			          IF l_return_status <> 'S' THEN
			             RAISE Selection_Insert_Error;
				  END IF;
			   ELSE /* added for 2286375 rework*/
			    --utl_file.put_line(pg_fp, 'else ');
				FND_MESSAGE.SET_NAME('GR', 'GR_ORDER_ALREADY_SELECTED');
				FND_MESSAGE.SET_TOKEN('CODE', '');
                 		FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
                 		FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
			   END IF;
			ELSIF GlobalRecipient.document_print_frequency = 'S' THEN
			--utl_file.put_line(pg_fp, 'S');
			   IF ABS(MONTHS_BETWEEN (l_current_date,
			       LocalDispatchRcd.date_msds_sent)) >= 6 THEN
                               l_return_status := FND_API.G_RET_STS_SUCCESS;
			       Insert_Selection_Row
			          ('GR_DISPATCH_QUARTERLY',
				   '',
				   '',
				   g_order_number,
				   g_order_line,
				   GlobalRecipient.document_code,
				   'Y',
				   g_recipient_code,
				   g_shipment_number,
				   l_return_status);
			           IF l_return_status <> 'S' THEN
			              RAISE Selection_Insert_Error;
				   END IF;
			     ELSE /* added for 2286375 rework*/
				FND_MESSAGE.SET_NAME('GR', 'GR_ORDER_ALREADY_SELECTED');
				FND_MESSAGE.SET_TOKEN('CODE', '');
                 		FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
                 		FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
			    END IF;
			 ELSIF GlobalRecipient.document_print_frequency = 'Y' THEN
			 --utl_file.put_line(pg_fp, 'Y');
			    IF ABS(MONTHS_BETWEEN (l_current_date,
			       LocalDispatchRcd.date_msds_sent)) >= 12 THEN
                               l_return_status := FND_API.G_RET_STS_SUCCESS;
			       Insert_Selection_Row
			          ('GR_DISPATCH_QUARTERLY',
				   '',
				   '',
				   g_order_number,
				   g_order_line,
				   GlobalRecipient.document_code,
				   'Y',
				   g_recipient_code,
				   g_shipment_number,
				   l_return_status);
			           IF l_return_status <> 'S' THEN
			              RAISE Selection_Insert_Error;
				   END IF;
			      ELSE /* added for 2286375 rework*/
				FND_MESSAGE.SET_NAME('GR', 'GR_ORDER_ALREADY_SELECTED');
				FND_MESSAGE.SET_TOKEN('CODE', '');
                 		FND_FILE.PUT(FND_FILE.LOG, FND_MESSAGE.GET);
                 		FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
			      END IF;
			      /* GK B1253943 - added in code for testing print freq for different time periods*/
			/*ELSIF GlobalRecipient.document_print_frequency = 'R' THEN
			        l_time_period := GlobalRecipient.time_period;
			 	l_diff := ABS(l_current_date - LocalDispatchRcd.date_msds_sent);
			 	IF l_time_period = l_diff THEN
			 	   l_return_status := FND_API.G_RET_STS_SUCCESS;
			           Insert_Selection_Row
			             ('GR_DISPATCH_AS_REQUIRED',
				      '',
				      '',
				      g_order_number,
				      g_order_line,
				      GlobalRecipient.document_code,
				      'Y',
				      g_recipient_code,
				      g_shipment_number,
				      l_return_status);
			              IF l_return_status <> 'S' THEN
			                 RAISE Selection_Insert_Error;
				      END IF;
			         END IF;*/
			 ELSE
                            FND_FILE.PUT(FND_FILE.LOG,'      No document required');
                            FND_FILE.NEW_LINE(FND_FILE.LOG,1);
           --utl_file.put_line(pg_fp, 'no doc');
			    l_return_status := FND_API.G_RET_STS_SUCCESS;
                            Insert_Selection_Row
			       ('GR_NO_DOCUMENT_REQUIRED',
				'',
				'',
				g_order_number,
				g_order_line,
				GlobalRecipient.document_code,
				'N',
				g_recipient_code,
				g_shipment_number,
				l_return_status);
			        IF l_return_status <> 'S' THEN
			           RAISE Selection_Insert_Error;
			        END IF;
			   END IF;/* c_get_last_dispatch*/
               END IF;/* c_document_print_frequency */
         END IF; /* g_get_recipient%NOTFOUND */
      END IF; /* print_flag='YS' */
   END IF; /* c_check_selections */

EXCEPTION

   WHEN Selection_Insert_Error THEN
	  Handle_Error_Messages
				('GR_NO_RECORD_INSERTED',
				 'CODE',
				 g_order_number || ' ' || g_order_line,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

   WHEN OTHERS THEN
      l_oracle_error := SQLCODE;
	   /*l_code_block := SUBSTR(SQLERRM, 1, 200); */
	   l_code_block := l_code_block || ' ' || TO_CHAR(l_oracle_error);
	   FND_MESSAGE.SET_NAME('GR',
	                        'GR_UNEXPECTED_ERROR');
	   FND_MESSAGE.SET_TOKEN('TEXT',
	                         l_code_block||sqlerrm,
	                         FALSE);
--utl_file.fflush(pg_fp);
--      				utl_file.fclose(pg_fp);

END Check_Selected_Line;
/*
**		This procedure is called to read the address and cover letter text
**		and build the cover letter information into the print work file.
*/
PROCEDURE Read_And_Print_Cover_Letter
                                    (p_language_code IN VARCHAR2,
                                     p_item_code IN VARCHAR2,
                                     p_recipient_code IN VARCHAR2,
                                     p_print_address IN VARCHAR2,
                                     p_order_no IN NUMBER,
                                     p_other_addr_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2)
  IS

/*
**	Alphanumeric Variables
*/
L_CODE_BLOCK			VARCHAR2(2000);
L_MSG_DATA			VARCHAR2(2000);
L_RETURN_STATUS			VARCHAR2(1);
L_LANGUAGE_CODE			FND_LANGUAGES.language_code%TYPE;
L_WORK_TEXT			GR_COVER_LETTERS_TL.text%TYPE;
L_TEXT_LINE			GR_WORK_WORKSHEETS.text_line%TYPE;

X_MSG_DATA			VARCHAR2(2000);
pg_fp   		utl_file.file_type;
L_INTEGRATION			VARCHAR2(1); /* GK CHANGES*/
/*
**	Numeric Variables
*/
L_CUSTOMER_ID			OP_CUST_MST.cust_id%TYPE;
L_ADDRESS_ID			SY_ADDR_MST.addr_id%TYPE;

X_MSG_COUNT			NUMBER;
L_FIRST_SPACE			NUMBER;

/*
**	Exception
*/
OTHER_API_ERROR			EXCEPTION;

BEGIN
   l_return_status := 'S';

END Read_And_Print_Cover_Letter;
/*
**		This procedure is called to get the document information.
**		If the information does not exist or needs to be rebuilt, the document
**		is rebuilt.
**		Data is read from the document tables into the print work table.
*/
PROCEDURE Print_Document_Selection
                (p_document_code IN VARCHAR2,
				      p_item_code IN VARCHAR2,
				      p_language_code IN VARCHAR2,
				      p_disclosure_code IN VARCHAR2,
				      x_return_status OUT NOCOPY VARCHAR2)
 IS
/*
**	Alphanumeric Variables
*/
L_CODE_BLOCK			VARCHAR2(2000);
L_COMMIT				VARCHAR2(1) := 'F';
L_INIT_MSG_LIST			VARCHAR2(1) := 'F';
L_RETURN_STATUS			VARCHAR2(1);
L_MSG_DATA				VARCHAR2(2000);
L_TELEPHONE_NUMBER 		VARCHAR2(70);

L_LABEL_CODE			GR_LABELS_B.label_code%TYPE;
L_ADDR_LINE				SY_ADDR_MST.addr1%TYPE;
L_DEFAULT_ORGN	    SY_ORGN_MST.orgn_code%TYPE;

X_MSG_DATA				VARCHAR2(2000);

L_INTEGRATION			VARCHAR2(1); /*B2286375 GK Changes*/
/*
**	Numeric Values
*/
L_VALIDATION_LEVEL		NUMBER := 99;
L_API_VERSION			CONSTANT NUMBER := 1.0;
L_LINE_LEN				NUMBER;

L_DOCUMENT_TEXT_ID		GR_DOCUMENT_PRINT.document_text_id%TYPE;
L_DISCLOSURE_CODE		GR_DISCLOSURES.disclosure_code%TYPE;
L_TEXT_LINE				GR_DOCUMENT_DETAILS.text_line%TYPE;

L_LABEL_LEN			NUMBER;


X_MSG_COUNT				NUMBER;
/*
**	Exceptions
*/
BUILD_DOCUMENT_ERROR	EXCEPTION;

/*
**	Cursors
**
**	Get the document details
*/
CURSOR c_get_document
 IS
   SELECT	 dd.print_font,
			    dd.print_size,
			    dd.text_line
   FROM		 gr_document_details dd
   WHERE	 dd.document_text_id = l_document_text_id
   ORDER BY dd.text_line_number;
LocalDocRecord		c_get_document%ROWTYPE;
/*
**  Get the organization name, address and contact information
*/
CURSOR c_get_orgn_info
 IS
   SELECT	om.orgn_name,
           oa.addr1,
           oa.addr2,
			   oa.addr3,
			   oa.addr4,
			   oa.postal_code,
			   oa.state_code,
			   oa.country_code,
			   oc.daytime_contact_name,
			   oc.daytime_telephone,
			   oc.daytime_extension,
			   oc.daytime_area_code,
			   oc.evening_contact_name,
			   oc.evening_telephone,
			   oc.evening_extension,
			   oc.evening_area_code
   FROM		gr_organization_contacts oc,
		      sy_addr_mst_v oa,
			   sy_orgn_mst om
   WHERE	om.orgn_code = g_default_orgn
   AND		om.addr_id = oa.addr_id
   AND		oc.orgn_code = om.orgn_code;
LocalOrgnRecord			c_get_orgn_info%ROWTYPE;

/*  GK B2286375
**  Get the organization name, address and contact information for OM Integration
*/
CURSOR c_get_orgn_info_v
 IS
   SELECT	hou.name,
           	oa.addr1,
           	oa.addr2,
		oa.addr3,
		oa.addr4,
		oa.postal_code,
		oa.state_code,
		oa.country_code,
		oc.daytime_contact_name,
		oc.daytime_telephone,
		oc.daytime_extension,
		oc.daytime_area_code,
		oc.evening_contact_name,
		oc.evening_telephone,
		oc.evening_extension,
		oc.evening_area_code
   FROM		gr_organization_contacts oc,
		sy_addr_mst_v oa,
		hr_operating_units hou,
		gl_plcy_mst gl,
		sy_orgn_mst om
   WHERE	om.orgn_code = g_default_orgn
   AND		oc.orgn_code = om.orgn_code
   AND		om.addr_id = oa.addr_id
   AND		om.co_code = gl.co_code
   AND		gl.org_id = hou.organization_id;
LocalOrgnOMRecord			c_get_orgn_info_v%ROWTYPE;
/*
**	Get the label description and print information
*/
CURSOR c_get_label_info
 IS
   SELECT	lab.data_position_indicator,
			   lat.label_description
   FROM		gr_labels_tl lat,
			   gr_labels_b lab
   WHERE	lab.label_code = l_label_code
   AND		lat.label_code = lab.label_code
   AND		lat.language = p_language_code;
LocalLabelRecord		c_get_label_info%ROWTYPE;

/*
**	Get the country description
*/

CURSOR c_get_country_info (V_country_code VARCHAR2)
 IS
  SELECT geog_desc
  FROM   sy_geog_mst
  WHERE geog_type = 1
    AND geog_code = V_country_code;
LocalCountryRecord	c_get_country_info%ROWTYPE;

BEGIN
/*
**		Initialize the variables
*/
   l_return_status := 'S';

   IF p_disclosure_code IS NULL THEN
      l_disclosure_code := FND_PROFILE.Value('GR_STD_DISCLOSURE');
	    IF l_disclosure_code IS NULL THEN
	       l_disclosure_code := 'STAND';
	    END IF;
   ELSE
	    l_disclosure_code := p_disclosure_code;
   END IF;
/*
**		Check and get the text id of the document.
**		Build item document builds the document if required
*/
	 FND_FILE.PUT(FND_FILE.LOG, 'Processing Build_Item_Document for: ' || p_item_code || ' ' || TO_CHAR(g_session_id));
	 FND_FILE.NEW_LINE(FND_FILE.LOG,1);

	 GR_PROCESS_DOCUMENTS.Build_Item_Document
							(l_commit,
							 l_init_msg_list,
							 l_validation_level,
							 l_api_version,
							 p_item_code,
							 p_document_code,
							 l_disclosure_code,
							 p_language_code,
							 g_session_id,
							 l_document_text_id,
							 l_return_status,
							 x_msg_count,
							 l_msg_data);

   IF l_document_text_id IS NULL THEN
      l_code_block := 'No document id for ' || p_document_code;
	    FND_FILE.PUT(FND_FILE.LOG,l_code_block);
	    FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   END IF;

   IF l_return_status <> 'S' THEN
      RAISE Build_Document_Error;
   END IF;
--   Submit_Print_Request
--         (p_printer,
--          p_user_print_style,
--          p_number_of_copies,
--          g_default_document,
--          l_language_code,
--          l_return_status);

/*
**		Get the organization address and contact info.
*/
   IF g_default_orgn IS NULL THEN
      g_default_orgn := FND_PROFILE.Value('GR_ORGN_DEFAULT');
   END IF;

    /* B2286375 GK Changes*/
   IF l_integration = 'N' THEN
   	OPEN c_get_orgn_info;
  	 FETCH c_get_orgn_info INTO LocalOrgnRecord;
  	 IF c_get_orgn_info%NOTFOUND THEN
      		l_code_block := 'No organization info for ' || g_default_orgn;
	    	FND_FILE.PUT(FND_FILE.LOG,l_code_block);
	    	FND_FILE.NEW_LINE(FND_FILE.LOG,1);
  	 END IF;
   	CLOSE c_get_orgn_info;
   -- ELSE
   	--OPEN c_get_orgn_info_v;
   	--FETCH c_get_orgn_info_v INTO LocalOrgnOMRecord;
   	--IF c_get_orgn_info_v%NOTFOUND THEN
      	--	l_code_block := 'No organization info for ' || g_default_orgn;
	  --  	FND_FILE.PUT(FND_FILE.LOG,l_code_block);
	  --	FND_FILE.NEW_LINE(FND_FILE.LOG,1);
   	--END IF;
   	--CLOSE c_get_orgn_info_v;
   END IF; /* End changes*/
/*
**		Read the document, based on the text id and copy
**		it into the work file.
*/
   OPEN c_get_document;
   FETCH c_get_document INTO LocalDocRecord;
   IF c_get_document%FOUND THEN
      WHILE c_get_document%FOUND LOOP
/*
**			Label code for printing the name and address
*/
	     IF LocalDocRecord.text_line = '01100' THEN
			l_label_code := '01100';
			OPEN c_get_label_info;
			FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the code and ????
*/
			IF c_get_label_info%NOTFOUND THEN
			   l_text_line := l_label_code || ' ???? ' || g_default_orgn;
			   FND_FILE.PUT(FND_FILE.LOG,l_text_line);
			   FND_FILE.NEW_LINE(FND_FILE.LOG,1);
		       l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
			ELSE
			  l_text_line := LocalLabelRecord.label_description;
			  IF LocalLabelRecord.data_position_indicator = 'I' THEN
			     l_text_line := l_text_line || ' '||LocalOrgnRecord.orgn_name;
	                 l_label_len := LENGTH(LocalLabelRecord.label_description) + 16;
      	        ELSIF LocalLabelRecord.data_position_indicator IN ('C', 'R') THEN
            	    l_text_line := RPAD(l_text_line,30)||' '||LocalOrgnRecord.orgn_name;
	                l_label_len := 31;
			  END IF;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
 			    IF LocalLabelRecord.data_position_indicator = 'N' THEN
   			      l_text_line := LocalOrgnRecord.orgn_name;
                        l_label_len := 0;
		            l_return_status := 'S';
                        Insert_Work_Row
		                     	(p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		            IF l_return_status <> 'S' THEN
		              RAISE Build_Document_Error;
		            END IF;
			    END IF;

			   IF LocalOrgnRecord.addr1 IS NOT NULL THEN
	 		     l_addr_line := LocalOrgnRecord.addr1;
		           l_line_len := l_label_len + LENGTH(l_addr_line);
		           l_text_line := LPAD(l_addr_line,l_line_len,' ');

		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   END IF;

			   IF LocalOrgnRecord.addr2 IS NOT NULL THEN
		   	     l_addr_line := LocalOrgnRecord.addr2;
		           l_line_len := l_label_len + LENGTH(l_addr_line);
		           l_text_line := LPAD(l_addr_line,l_line_len,' ');

		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   END IF;

			   IF LocalOrgnRecord.addr3 IS NOT NULL THEN
		           l_addr_line := LocalOrgnRecord.addr3;
		           l_line_len := l_label_len + LENGTH(l_addr_line);
		           l_text_line := LPAD(l_addr_line,l_line_len,' ');

		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   END IF;

                     IF (LocalOrgnRecord.addr4 IS NOT NULL) OR
                        (LocalOrgnRecord.state_code IS NOT NULL) OR
                        (LocalOrgnRecord.postal_code IS NOT NULL) THEN
                       l_addr_line := NULL;
		           IF LocalOrgnRecord.addr4 IS NOT NULL THEN
		             l_addr_line := LocalOrgnRecord.addr4;
                       END IF;
                       IF LocalOrgnRecord.state_code IS NOT NULL THEN
                         l_addr_line := l_addr_line ||' '||LocalOrgnRecord.state_code;
                       END IF;
                       IF LocalOrgnRecord.postal_code IS NOT NULL THEN
                         l_addr_line := l_addr_line||' '||LocalOrgnRecord.postal_code;
                       END IF;
	                 l_line_len := l_label_len + LENGTH(l_addr_line);
		           l_text_line := LPAD(l_addr_line,l_line_len,' ');

		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   END IF;

 		        IF LocalOrgnRecord.country_code IS NOT NULL THEN
		          l_addr_line := LocalOrgnRecord.country_code;
                      OPEN c_get_country_info(l_addr_line);
                      FETCH c_get_country_info INTO LocalCountryRecord;
                      IF c_get_country_info%FOUND THEN
                        l_addr_line := LocalCountryRecord.geog_desc;
                      END IF;
                      CLOSE c_get_country_info;
		          l_line_len := l_label_len + LENGTH(l_addr_line);
		          l_text_line := LPAD(l_addr_line,l_line_len,' ');

		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   END IF;
			END IF;
			CLOSE c_get_label_info;
/*
**			Label code for printing the daytime contact name
*/
		 ELSIF LocalDocRecord.text_line = '01101' THEN
			IF LocalOrgnRecord.daytime_contact_name IS NOT NULL THEN
			   l_label_code := '01101';
			   OPEN c_get_label_info;
			   FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the label code and ??????
*/
			   IF c_get_label_info%NOTFOUND THEN
			      l_text_line := l_label_code || '??????' || ' ';
			      l_text_line := l_text_line || LocalOrgnRecord.daytime_contact_name;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   ELSE
				  l_text_line := RPAD(LocalLabelRecord.label_description,30,' ');
/*
**						Label info and print data on the same line
*/
				  IF LocalLabelRecord.data_position_indicator = 'I' THEN
				     l_text_line := l_text_line || LocalOrgnRecord.daytime_contact_name;
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  ELSE
/*
**						Label info and print data on the next line
*/
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
					 l_text_line := LocalOrgnRecord.daytime_contact_name;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  END IF;
			   END IF;
			   CLOSE c_get_label_info;
			END IF;
/*
**			Label code for printing the daytime contact number
*/
		 ELSIF LocalDocRecord.text_line = '01102' THEN
			IF LocalOrgnRecord.daytime_telephone IS NOT NULL THEN
			   l_label_code := '01102';
			   l_telephone_number := LocalOrgnRecord.daytime_area_code;
			   IF l_telephone_number IS NOT NULL THEN
			      l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.daytime_telephone;
			   ELSE
			      l_telephone_number := LocalOrgnRecord.daytime_telephone;
			   END IF;
			   l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.daytime_extension;
			   OPEN c_get_label_info;
			   FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the label code and ??????
*/
			   IF c_get_label_info%NOTFOUND THEN
			      l_text_line := l_label_code || '??????' || ' ' || l_telephone_number;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   ELSE
				  l_text_line := RPAD(LocalLabelRecord.label_description,30,' ');
/*
**						Label info and print data on the same line
*/
				  IF LocalLabelRecord.data_position_indicator = 'I' THEN
				     l_text_line := l_text_line || l_telephone_number;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  ELSE
/*
**						Label info and print data on the next line
*/
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
					 l_text_line := l_telephone_number;
					 l_return_status := 'S';
					 Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  END IF;
			   END IF;
			   CLOSE c_get_label_info;
			END IF;
/*
**			Label code for printing the evening contact name
*/
		 ELSIF LocalDocRecord.text_line = '01103' THEN
			IF LocalOrgnRecord.evening_contact_name IS NOT NULL THEN
			   l_label_code := '01103';
			   OPEN c_get_label_info;
			   FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the label code and ??????
*/
			   IF c_get_label_info%NOTFOUND THEN
			      l_text_line := l_label_code || '??????' || ' ';
			      l_text_line := l_text_line || LocalOrgnRecord.evening_contact_name;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   ELSE
				  l_text_line := RPAD(LocalLabelRecord.label_description,30,' ');
/*
**						Label info and print data on the same line
*/
				  IF LocalLabelRecord.data_position_indicator = 'I' THEN
				     l_text_line := l_text_line || LocalOrgnRecord.evening_contact_name;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  ELSE
/*
**						Label info and print data on the next line
*/
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
					 l_text_line := LocalOrgnRecord.evening_contact_name;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  END IF;
			   END IF;
			   CLOSE c_get_label_info;
			END IF;
/*
**			Label code for printing the evening contact number
*/
		 ELSIF LocalDocRecord.text_line = '01104' THEN
			IF LocalOrgnRecord.evening_telephone IS NOT NULL THEN
			   l_label_code := '01104';
			   l_telephone_number := LocalOrgnRecord.evening_area_code;
			   IF l_telephone_number IS NOT NULL THEN
			      l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.evening_telephone;
			   ELSE
			      l_telephone_number := LocalOrgnRecord.evening_telephone;
			   END IF;
			   l_telephone_number := l_telephone_number || ' ' || LocalOrgnRecord.evening_extension;
			   OPEN c_get_label_info;
			   FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the label code and ??????
*/
			   IF c_get_label_info%NOTFOUND THEN
			      l_text_line := l_label_code || '??????' || ' ' || l_telephone_number;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   ELSE
				  l_text_line := RPAD(LocalLabelRecord.label_description,30,' ');
/*
**						Label info and print data on the same line
*/
				  IF LocalLabelRecord.data_position_indicator = 'I' THEN
				     l_text_line := l_text_line || l_telephone_number;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  ELSE
/*
**						Label info and print data on the next line
*/
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
					 l_text_line := l_telephone_number;
					 l_return_status := 'S';
					 Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  END IF;
			   END IF;
			   CLOSE c_get_label_info;
			END IF;
/*
**						Print recipient name
*/
         ELSIF LocalDocRecord.text_line = '01006' THEN
		    IF g_cust_name IS NOT NULL THEN
			   l_label_code := '01006';
			   OPEN c_get_label_info;
			   FETCH c_get_label_info INTO LocalLabelRecord;
/*
**				If no label info print the label code and ??????
*/
			   IF c_get_label_info%NOTFOUND THEN
			      l_text_line := l_label_code || '??????' || ' ';
			      l_text_line := l_text_line || g_cust_name;
		          l_return_status := 'S';
                  Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			   ELSE
				  l_text_line := RPAD(LocalLabelRecord.label_description,30,' ');
/*
**						Label info and print data on the same line
*/
				  IF LocalLabelRecord.data_position_indicator = 'I' THEN
				     l_text_line := l_text_line || g_cust_name;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  ELSE
/*
**						Label info and print data on the next line
*/
                     l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
					 l_text_line := g_cust_name;
					 l_return_status := 'S';
                     Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);
		             IF l_return_status <> 'S' THEN
		                RAISE Build_Document_Error;
		             END IF;
				  END IF;
			   END IF;
			   CLOSE c_get_label_info;
            END IF;
		 ELSIF LocalDocRecord.text_line = '01007' THEN
			l_label_code := '01007';
			OPEN c_get_label_info;
			FETCH c_get_label_info INTO LocalLabelRecord;

			IF g_addr1 IS NOT NULL THEN
			   IF LocalLabelRecord.data_position_indicator = 'I' THEN
				  l_addr_line := g_addr1;
				  l_line_len := 30 + LENGTH(l_addr_line);
				  l_text_line := LPAD(l_addr_line,l_line_len,' ');
			   ELSE
				  l_text_line := g_addr1;
			   END IF;
		       l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
			END IF;

			IF g_addr2 IS NOT NULL THEN
			   IF LocalLabelRecord.data_position_indicator = 'I' THEN
				  l_addr_line := g_addr2;
				  l_line_len := 30 + LENGTH(l_addr_line);
				  l_text_line := LPAD(l_addr_line,l_line_len,' ');
			   ELSE
				  l_text_line := g_addr2;
			   END IF;
		       l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
			END IF;

			IF g_addr3 IS NOT NULL THEN
			   IF LocalLabelRecord.data_position_indicator = 'I' THEN
				  l_addr_line := g_addr3;
				  l_line_len := 30 + LENGTH(l_addr_line);
				  l_text_line := LPAD(l_addr_line,l_line_len,' ');
			   ELSE
				  l_text_line := g_addr3;
			   END IF;
		       l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
			END IF;

			IF g_addr4 IS NOT NULL THEN
			   IF LocalLabelRecord.data_position_indicator = 'I' THEN
				  l_addr_line := g_addr4;
				  l_line_len := 30 + LENGTH(l_addr_line);
				  l_text_line := LPAD(l_addr_line,l_line_len,' ');
			   ELSE
				  l_text_line := g_addr4;
			   END IF;
		       l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
			END IF;

			IF g_postal_code IS NOT NULL THEN
			   IF LocalLabelRecord.data_position_indicator = 'I' THEN
				  l_addr_line := g_state_code || ' ' || g_postal_code;
				  l_addr_line := l_addr_line || ' ' || g_country_code;
				  l_line_len := 30 + LENGTH(l_addr_line);
				  l_text_line := LPAD(l_addr_line,l_line_len,' ');
			   ELSE
				  l_text_line := g_postal_code;
			   END IF;
		        l_return_status := 'S';
               Insert_Work_Row
		                     (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              l_text_line,
				              'M',
				              l_return_status);

		          IF l_return_status <> 'S' THEN
		             RAISE Build_Document_Error;
		          END IF;
			    END IF;
			    CLOSE c_get_label_info;
		    ELSIF LocalDocRecord.text_line = '01008' OR
		          LocalDocRecord.text_line = '01009' THEN
			    l_code_block := 'Recipient contact info.';
		    ELSE
		       l_return_status := 'S';
            Insert_Work_Row
		                   (p_item_code,
				              LocalDocRecord.print_font,
				              LocalDocRecord.print_size,
				              LocalDocRecord.text_line,
				              'M',
				              l_return_status);

		       IF l_return_status <> 'S' THEN
		          RAISE Build_Document_Error;
		       END IF;
		    END IF;
	       FETCH c_get_document INTO LocalDocRecord;
	    END LOOP;
   END IF;

EXCEPTION

   WHEN Build_Document_Error THEN
	   Handle_Error_Messages
				('GR_UNEXPECTED_ERROR',
				 'TEXT',
				 l_msg_data,
				 x_msg_count,
				 x_msg_data,
				 l_return_status);

END Print_Document_Selection;
/*
**		This procedure writes the worksheet row.
*/
PROCEDURE Insert_Work_Row
				(p_item_code IN VARCHAR2,
				 p_print_font IN VARCHAR2,
				 p_print_size IN NUMBER,
				 p_text_line IN VARCHAR2,
				 p_line_type IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
 IS

BEGIN

   IF g_line_number IS NULL THEN
      g_line_number := 0;
   END IF;

   g_line_number := g_line_number + 1;

   INSERT INTO gr_work_worksheets
				(session_id,
				 text_line_number,
				 item_code,
				 print_font,
				 text_line,
				 line_type,
				 print_size)
		      VALUES
				(g_session_id,
				 g_line_number,
				 p_item_code,
				 p_print_font,
				 p_text_line,
				 p_line_type,
				 p_print_size);

EXCEPTION

   WHEN OTHERS THEN
      FND_FILE.PUT(FND_FILE.LOG, TO_CHAR(g_session_id) || ' Error inserting work record');
      FND_FILE.NEW_LINE(FND_FILE.LOG,1);

END Insert_Work_Row;
/*
**   This procedure handles the submission of print jobs to the
**   concurrent manager.
**
*/
PROCEDURE Submit_Print_Request
		              (p_printer IN VARCHAR2,
					   	p_user_print_style IN VARCHAR2,
							p_number_of_copies IN NUMBER,
							p_default_document IN VARCHAR2,
							p_language_code IN VARCHAR2,
							x_return_status OUT NOCOPY VARCHAR2)
 IS

/*  17-Jun-2003   Mercy Thomas BUG 2932007 - Added the following local variables for Document Management */

/************* Local Variables *************/
l_document_management  VARCHAR2(2);
l_default_orgn        VARCHAR2(4);
l_category            VARCHAR2(40);
l_request_id          NUMBER;
l_java_concurrent_id  NUMBER;
l_attribute1          VARCHAR2(32) := NULL;
l_attribute2          VARCHAR2(32) := NULL;
l_attribute3          VARCHAR2(32) := NULL;
l_attribute4          VARCHAR2(32) := NULL;
l_attribute5          VARCHAR2(32) := NULL;
l_attribute6          VARCHAR2(32) := NULL;
l_attribute7          VARCHAR2(32) := NULL;
l_attribute8          VARCHAR2(32) := NULL;
l_attribute9          VARCHAR2(32) := NULL;
l_attribute10         VARCHAR2(32) := NULL;
l_rebuild_flag        VARCHAR2(2) := 'N';

/*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of the code changes */

BEGIN

   x_return_status := 'S';

   /*  17-Jun-2003   Mercy Thomas BUG 2932007 - Added following code for Document Management  */

   l_default_orgn        := FND_PROFILE.Value('GR_ORGN_DEFAULT');
   l_document_management := FND_PROFILE.Value('GR_DOC_MANAGEMENT');

   IF g_cover_letter = 'N' THEN

      /* If document management is enabled */
       IF l_document_management <> 'N' THEN
          l_attribute2  := p_default_document;
          l_attribute3  := userenv('LANG');
          l_attribute4  := 'STAND';
          l_attribute5  := l_default_orgn;

          /* Determine if this is for a Recipeint Document or a Sales Order */
          IF g_report_type = 3 THEN
             l_category    := 'MSDS_RECIPIENT';
             l_attribute1  := g_doc_item_code;
             l_attribute6  := ' ';
             l_attribute7  := ' ';
             l_attribute8  := g_recipient_code;
             l_attribute9  := NULL;
             l_attribute10 := NULL;
          ELSE
             l_category    := 'MSDS_SALES_ORDER';
             l_attribute1  := g_item_code;
             l_attribute6  := ' ';
             l_attribute7  := ' ';
             l_attribute8  := g_order_no;
             l_attribute9  := g_order_line;
             l_attribute10 := g_shipment_number;
          END IF;
          l_rebuild_flag := 'Y';
       ELSE
          l_category    := NULL;
          l_attribute1  := NULL;
          l_attribute2  := NULL;
          l_attribute3  := NULL;
          l_attribute4  := NULL;
          l_attribute5  := NULL;
          l_attribute6  := NULL;
          l_attribute7  := NULL;
          l_attribute8  := NULL;
          l_attribute9  := NULL;
          l_attribute10 := NULL;
          l_rebuild_flag := 'N';
       END IF;
    ELSIF g_cover_letter = 'Y' THEN
       l_rebuild_flag := 'N';
    END IF;

    IF l_rebuild_flag = 'Y' THEN
       FND_FILE.PUT(FND_FILE.LOG, '   Rebuild Flag is selected ');
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSE
       FND_FILE.PUT(FND_FILE.LOG, '   Rebuild Flag is not selected ');
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    END IF;

   /*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of the code changes */

    IF p_number_of_copies > 0 THEN
       g_print_status := FND_REQUEST.SET_PRINT_OPTIONS
	                                (p_printer,
	                                 p_user_print_style,
	                                 p_number_of_copies, TRUE, 'N');
    END IF;

    /*  17-Jun-2003   Mercy Thomas BUG 2932007 - Added parameters for the concurrent report to incorporate Document Management */

         g_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
                              ('GR', 'GRRPT030_DOC', '', '', FALSE, g_session_id,
                               p_default_document, p_language_code, 1,
                               l_category, 'PDF', l_attribute1, l_attribute2, l_attribute3, l_attribute4, l_attribute5,
                               l_attribute6, l_attribute7, l_attribute8, l_attribute9, l_attribute10, l_rebuild_flag,'', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '',
                               '', '', '', '', '', '', '', '', '', '');

   /*  17-Jun-2003   Mercy Thomas BUG 2932007 - End of the code changes */

--   g_session_id := g_session_id + 1;
   SELECT       gr_work_build_docs_s.nextval INTO g_session_id
   FROM         dual;
-- Bug #1902822 (JKB)


EXCEPTION

   WHEN OTHERS THEN
	    x_return_status := 'E';

END Submit_Print_Request;
/*
**		This procedure is called from the EXCEPTION handlers
**		in other procedures. It is passed the message code,
**		token name and token value.
**
**		The procedure will then process the error message into
**		the message stack and then return to the calling routine.
**		The procedure assumes all messages used are in the
**		application id 'GR'.
**
*/
PROCEDURE Handle_Error_Messages
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
  IS
/*
**	Alphanumeric variables
*/
L_MSG_DATA		VARCHAR2(2000);


/*
**	Numeric variables
*/
L_MSG_COUNT		NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('GR',
	                    p_message_code);
   IF p_token_name IS NOT NULL THEN
	  FND_MESSAGE.SET_TOKEN(p_token_name,
	                        p_token_value,
							FALSE);
   END IF;

   FND_MSG_PUB.Add;
   FND_MSG_PUB.Count_and_Get
	  					(p_count	=> l_msg_count,
						 p_data		=> l_msg_data);
   FND_FILE.PUT(FND_FILE.LOG, p_message_code||' '||p_token_value);
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
END Handle_Error_Messages;

END GR_PROCESS_ORDERS;

/
