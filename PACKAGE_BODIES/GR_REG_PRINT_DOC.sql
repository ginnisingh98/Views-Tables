--------------------------------------------------------
--  DDL for Package Body GR_REG_PRINT_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_REG_PRINT_DOC" AS
/*  $Header: GROMPRTB.pls 120.5 2006/01/16 15:27:24 methomas noship $    */

/*===========================================================================
--  PROCEDURE:
--    print_shipping_doc
--
--  DESCRIPTION:
--  This procedure is used to print the documents attached to an object - Regulatory Item,
--  Linked Inventory Item, Sales Order, etc. It is meant to be called from the
--  Order Management Ship Confirm.
--
--  PARAMETERS:
--    p_delivery_id IN  NUMBER       - Delivery ID key to the workflow record
--
--  RETURNS:
--    errbuf        OUT VARCHAR2     - Returns error message only when this procedure is submitted from a concurrent program.
--    retcode       OUT VARCHAR2     - Returns error code only when this procedure is submitted from a concurrent program.
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.printing_shipping_doc(p_delivery_id);
--
--  HISTORY
--    M. Grosser 13-Jun-2005  Added cursor to retrieve the recipient id
--               from the shipment based upon the ship_to_location_id.
--=========================================================================== */
PROCEDURE print_shipping_doc  (errbuf          OUT NOCOPY VARCHAR2,
                               retcode         OUT NOCOPY VARCHAR2,
                               p_delivery_id    IN NUMBER) IS

/* Bug 4912043 created new bind variables */
l_bind_var_msds	             VARCHAR2(2000);
l_bind_var_hazard            VARCHAR2(2000);
l_bind_var_safety            VARCHAR2(2000);
l_bind_var_msds_rejected     VARCHAR2(2000);

   /*  ------------------ CURSORS ---------------------- */

   /* M.Grosser 12-Apr-2005  Added retrieval of inventory_item_id, organization_id and ship_to_location_id
                             for 3rd Party Integration project.
   */
   /* Used to get the Delivery Information */
   CURSOR c_get_delivery_details IS
       SELECT delivery_detail_id,
              source_header_id,
              source_line_id,
              source_header_number,
              source_line_number,
              inventory_item_id,
              organization_id,
              ship_to_location_id
       FROM WSH_DLVY_DELIVERABLES_V
       WHERE delivery_id = p_delivery_id
       Order by delivery_detail_id;
       LocalDeliverydetail     c_get_delivery_details%ROWTYPE;

    --  M. Grosser 13-Jun-2005  Added cursor to retrieve the recipient id
    --             from the shipment based upon the ship_to_location_id.
    /* Used to retrieve the party id that will actually recieve the document */
    CURSOR c_get_recipient_id (p_ship_to_location_id NUMBER) IS
        SELECT  party_id
         FROM hz_party_sites
        WHERE party_site_id = p_ship_to_location_id;

   /* M.Grosser 12-Apr-2005  Added retrieval of document_id for 3rd Party Integration project.
   */
   /* Used to get the attached document information for a Delivery Detail Line */
   CURSOR c_get_attch_doc_details IS
       SELECT DISTINCT CATEGORY_DESCRIPTION,
              FILE_NAME,
              USER_ENTITY_NAME,
              MEDIA_ID,
              DOCUMENT_ID
       FROM   FND_ATTACHED_DOCS_FORM_VL
       WHERE (security_type=4 OR publish_flag='Y')
       AND  ((entity_name= 'OE_ORDER_LINES'
       AND    pk1_value = LocalDeliverydetail.source_line_id )
       OR   (entity_name= 'WSH_DELIVERY_DETAILS'
       AND    pk1_value = LocalDeliverydetail.delivery_detail_id ))
       AND    CATEGORY_ID IN (SELECT category_id
                              FROM FND_DOCUMENT_CATEGORIES_VL
                              WHERE UPPER(user_name) like l_bind_var_msds
                              OR    UPPER(user_name) like l_bind_var_safety
                              OR    UPPER(user_name) like l_bind_var_hazard)
/*
**     28-May-2004 Mercy Thomas 3211481 removed the column seq_num from the order by clause
*/
       order by user_entity_name;

       LocalAttachDocDetail c_get_attch_doc_details%ROWTYPE;

--, seq_num;
/*
**     28-May-2004 Mercy Thomas 3211481 End of the changes.
 */

   /* M.Grosser 12-Apr-2005  Added for 3rd Party Integration project */

   /* Used to retrieve Item Code */
   CURSOR c_get_item_code(p_organization_id NUMBER, p_item_id NUMBER)IS
       Select segment1
        from mtl_system_items
        where inventory_item_id = p_item_id
          and organization_id = p_organization_id;

   /* M.Grosser 12-Apr-2005  End of changes */


/*  ------------- LOCAL VARIABLES ------------------- */
L_CONCURRENT_ID              NUMBER(15);
L_CODE_BLOCK		     VARCHAR2(2000);
L_MSG_DATA	             VARCHAR2(2000);
L_ORACLE_ERROR		     NUMBER;
l_item_code                  VARCHAR2(32);
l_recipient_id               NUMBER;
l_return_status              VARCHAR2(3);
l_msg_count                  NUMBER;
l_user_id                    NUMBER;
l_error_msg                  VARCHAR2(2000);

/*  ------------------ EXCEPTIONS ---------------------- */
No_Delivery_Details          EXCEPTION;
Concurrent_Request_Error     EXCEPTION;

BEGIN

   /* Bug 4912043 Populating the bind variables with the message text instead of hardcoding the text in the Query */
   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_MSDS');
   l_bind_var_msds := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_SAFETY');
   l_bind_var_safety := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_HAZARD');
   l_bind_var_hazard := FND_MESSAGE.GET;

   /* Get the Delivery Details for the delivery Id */
   OPEN  c_get_delivery_details;
   FETCH c_get_delivery_details into LocalDeliverydetail;

   /* If Delivery Details exists or not */
   IF c_get_delivery_details%NOTFOUND THEN
   /* Raise a Error, if there are no delivery details */
      RAISE No_Delivery_Details;
      Close c_get_delivery_details;
   ELSE
      /* M.Grosser 12-Apr-2005  Added for 3rd Party Integration project */
      ATTACH_SHIPPING_DOCUMENT(
              p_delivery_id    => p_delivery_id,
              x_return_status  => l_return_status,
              x_msg_data       => l_msg_data );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('GR','GR_SHIPPING_ATTACHMENT_ERROR');
          FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID', LocalDeliverydetail.delivery_detail_id, FALSE);
          l_msg_data := FND_MESSAGE.GET;
          FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
      END IF;

      l_user_id := NVL(FND_PROFILE.VALUE('USER_ID'),0);
      /* M.Grosser 12-Apr-2005  End of changes */

      /* Delivery Details exists */
      WHILE c_get_delivery_details%FOUND LOOP
         /* Post the log with the Delivery Id for which the Shipping Report is executed */
         FND_MESSAGE.SET_NAME('GR','GR_SHIP_CONFIRM_TEXT');
         FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id, FALSE);
         l_msg_data := FND_MESSAGE.GET;
         FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
         FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
         /* Get the attached documents for a delivery detail line */
         OPEN c_get_attch_doc_details;
         FETCH c_get_attch_doc_details into LocalAttachDocDetail;
         /* If attached documents exists or not */
         IF c_get_attch_doc_details%NOTFOUND THEN
            /* No attached documents exists for the delivery detail line, post the log with the information */
            Close c_get_attch_doc_details;
            FND_MESSAGE.SET_NAME('GR','GR_NO_ATTACHED_DOC_TEXT');
            FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID', LocalDeliverydetail.delivery_detail_id, FALSE);
            l_msg_data := FND_MESSAGE.GET;
            FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
            FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
         ELSE
            /* Attached documents exists for the delivery detail line */
            WHILE c_get_attch_doc_details%FOUND LOOP
               /* Submit the java concurrent program, to print the attached document to an output file */
               l_concurrent_id := FND_REQUEST.SUBMIT_REQUEST
                                  ('GR', 'GR_PRINT_SHIP_DOC', '', '', FALSE,
                                   LocalAttachDocDetail.media_id,
                                   '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '');

               IF l_concurrent_id = 0 THEN
                  /* Java concurrent program failed, to print the attached document to an output file */
                  FND_MESSAGE.SET_NAME('GR','GR_CONC_REQ_PRINT_SHIP');
                  FND_MESSAGE.SET_TOKEN('FILE_NAME', LocalAttachDocDetail.file_name, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
               ELSE

                  /* Java concurrent program was succesfull, therefore, post the information with regard to the delivery details and the attached documents to the log */
                  FND_MESSAGE.SET_NAME('GR','GR_REG_DOC_PRINT_TEXT');
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                  /* Post the Delivery Detail ID to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_DELIVERY_DETAIL_ID_TEXT');
                  FND_MESSAGE.SET_TOKEN('DELIVERY_DETAIL_ID', LocalDeliverydetail.delivery_detail_id, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Delivery Detail ID to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_ORDER_ID_TEXT');
                  FND_MESSAGE.SET_TOKEN('ORDER_ID', LocalDeliverydetail.Source_Header_id, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Sales Order Line ID to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_ORDER_LINE_ID_TEXT');
                  FND_MESSAGE.SET_TOKEN('ORDER_LINE_ID', LocalDeliverydetail.Source_Line_id, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Sales Order Number to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_ORD_NUMBER_TEXT');
                  FND_MESSAGE.SET_TOKEN('ORDER_NUMBER', LocalDeliverydetail.Source_Header_Number, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Sales Order Line Number to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_ORD_LINE_NO_TEXT');
                  FND_MESSAGE.SET_TOKEN('ORDER_LINE_NO', LocalDeliverydetail.Source_Line_Number, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Category Description to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_CATEGORY_DESC_TEXT');
                  FND_MESSAGE.SET_TOKEN('CATEGORY_DESC', LocalAttachDocDetail.category_description, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the File Name to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_FILE_NAME_TEXT');
                  FND_MESSAGE.SET_TOKEN('FILE_NAME', LocalAttachDocDetail.file_name, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Concurrent request id for the java concurrent program to the log for which the document was printed */
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                  FND_MESSAGE.SET_NAME('GR','GR_DOC_CONC_REQ_ID_TEXT');
                  FND_MESSAGE.SET_TOKEN('DOC_CONC_REQ_ID', l_concurrent_id, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* Post the Entity Name to the log for which the document was printed */
                  FND_MESSAGE.SET_NAME('GR','GR_ENTITY_NAME_TEXT');
                  FND_MESSAGE.SET_TOKEN('ENTITY_NAME', LocalAttachDocDetail.user_entity_name, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                  /* M.Grosser 12-Apr-2005  Added for 3rd Party Integration project */
                  OPEN c_get_item_code(LocalDeliverydetail.organization_id,LocalDeliverydetail.inventory_item_id);
                  FETCH c_get_item_code into l_item_code;
                  IF c_get_item_code%NOTFOUND then
                     FND_MESSAGE.SET_NAME('GR','GR_INVALID_ITEM_ORG_ID');
                     FND_MESSAGE.SET_TOKEN('ITEM_ID', LocalDeliverydetail.INVENTORY_ITEM_ID, FALSE);
                     FND_MESSAGE.SET_TOKEN('ORGN_ID', LocalDeliverydetail.ORGANIZATION_ID, FALSE);
                     l_msg_data := FND_MESSAGE.GET;
                     FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
	             FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
            	     RETURN;
		  END IF;
                  CLOSE c_get_item_code;

                  --  M. Grosser 13-Jun-2005  Added cursor to retrieve the recipient id
                  --             from the shipment based upon the ship_to_location_id.
                  --
                  OPEN c_get_recipient_id(LocalDeliverydetail.ship_to_location_id);
                  FETCH c_get_recipient_id into l_recipient_id;
                  IF c_get_recipient_id%NOTFOUND then
                     FND_MESSAGE.SET_NAME('GR','GR_INVALID_RECIPIENT_SITE');
                     FND_MESSAGE.SET_TOKEN('RECIPIENT_SITE_ID', LocalDeliverydetail.SHIP_TO_LOCATION_ID, FALSE);
                     l_msg_data := FND_MESSAGE.GET;
                     FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
	             FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
            	     RETURN;
		  END IF;
                  CLOSE c_get_recipient_id;


                  FND_MESSAGE.SET_NAME('GR', 'GR_CREATING_DISPATCH_HISTORY');
                  FND_MESSAGE.SET_TOKEN('FILE_NAME',localAttachDocDetail.File_name, FALSE);
                  l_msg_data := FND_MESSAGE.GET;
                  FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                  FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
	          /*  Call Update Dispatch History API with creation_source = 1 (Internal)*/
                  GR_DISPATCH_HISTORY_PUB.create_dispatch_history (
                         p_api_version          => 1.0,
                  	 p_init_msg_list        => FND_API.G_FALSE,
                         p_commit               => FND_API.G_TRUE,
                         p_item                 => l_item_code,
                         p_organization_id      => LocalDeliverydetail.organization_id,
                         p_inventory_item_id    => LocalDeliverydetail.inventory_item_id,
                         p_recipient_id         => l_recipient_id,
                         p_recipient_site_id    => LocalDeliverydetail.ship_to_location_id,
                         p_date_sent            => SYSDATE,
                         p_dispatch_method_code => 3,
                         p_document_id          => localAttachDocDetail.document_id,
                         p_user_id              => l_user_id,
                         p_creation_source      => 1,
                         p_cas_number           => NULL,
                         p_document_location    => NULL,
                         p_document_name        => NULL,
                         p_document_version     => NULL,
                         p_document_category    => NULL,
                         p_file_format          => NULL,
                         p_file_description     => NULL,
                         p_document_code        => NULL,
                         p_disclosure_code      => NULL,
                         p_language             => NULL,
                         p_organization_code    => NULL,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_error_msg  );

                  --  M. Grosser 13-Jun-2005  End of changes

                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     FND_MESSAGE.SET_NAME('GR', 'GR_DISPATCH_HISTORY_FAILED');
                     FND_MESSAGE.SET_TOKEN('FILE_NAME',localAttachDocDetail.File_name, FALSE);
                     l_msg_data := FND_MESSAGE.GET;
                     FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                     FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                     FND_FILE.PUT(FND_FILE.LOG, l_error_msg);
                     FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                  END IF;
                  /* M.Grosser 12-Apr-2005  End of changes */

               END IF; /* g_concurrent_id */
               FETCH c_get_attch_doc_details INTO LocalAttachDocDetail;
            END LOOP;
            Close c_get_attch_doc_details;
         END IF;   /* c_get_attch_doc_details%NOTFOUND */
         FETCH c_get_delivery_details INTO LocalDeliverydetail;
      END LOOP;
      Close c_get_delivery_details;
   END IF;       /* c_get_delivery_details%NOTFOUND */

   EXCEPTION
      WHEN No_Delivery_Details THEN
         FND_MESSAGE.SET_NAME('GR','GR_NO_DELIVERY_DETAILS');
         FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id, FALSE);
      WHEN OTHERS THEN
         l_code_block :='Print Shipping Doc '  || ' ' ||TO_CHAR(l_oracle_error);
         FND_MESSAGE.SET_NAME('GR','GR_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('TEXT',l_code_block||sqlerrm, FALSE);

END print_shipping_doc;



/*===========================================================================
--  PROCEDURE:
--    attach_shipping_document
--
--  DESCRIPTION:
--    This procedure is used to attach a Regulatory document to a Shipment line
--    if no other Regulatory documents have been attached to that line.
--
--  PARAMETERS:
--    p_delivery_id          IN         NUMBER       - Delivery ID key of Shipment
--    x_return_status        OUT NOCOPY VARCHAR2     - Status of procedure execution
--    x_msg_data             OUT NOCOPY VARCHAR2     - Error message, if error has occurred
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.attach_shipping_document(p_delivery_id, l_return_status, l_msg_data);
--
--  BUG#4431025  : Attachment Convergence Coding
      Removed cursor c_regulatory_item , Modified cursor c_get_last_dispatch_date
      replacing item_code by inventory_item_id.
--  HISTORY
--=========================================================================== */
PROCEDURE ATTACH_SHIPPING_DOCUMENT(
   p_delivery_id             IN         NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2) IS

  /*  ------------- LOCAL VARIABLES ------------------- */
   l_item_code               VARCHAR2(32);
   l_code_block	             VARCHAR2(2000);
   l_msg_data	             VARCHAR2(2000);
   l_return_status           VARCHAR2(2);
   l_create_attachment       VARCHAR2(2);
   l_rowid                   VARCHAR2(200);
   l_msg_count               NUMBER;
   l_user_id                 NUMBER(15);
--removed   l_regulatory_item_exists  NUMBER(5);
   l_attached_document_id    NUMBER(15);
   l_seq                     NUMBER;
   l_last_dispatch_date      DATE;

/* Bug 4912043 created new bind variables */
l_bind_var_msds	             VARCHAR2(2000);
l_bind_var_hazard            VARCHAR2(2000);
l_bind_var_safety            VARCHAR2(2000);
l_bind_var_msds_rejected     VARCHAR2(2000);

  /*  ------------------ CURSORS ---------------------- */
 /*Used to get the Shipment Line Details */
 CURSOR c_get_delivery_details IS
   SELECT delivery_detail_id,
      source_line_id,
      inventory_item_id ,
      organization_id,
      ship_to_location_id,
      customer_id
   FROM WSH_DLVY_DELIVERABLES_V
   WHERE delivery_id = p_delivery_id
   Order by delivery_detail_id;
 LocalDeliverydetail  c_get_delivery_details%ROWTYPE;

 /* Used to get the attached document information for a Delivery Detail Line*/
 CURSOR c_get_attch_doc_details IS
   SELECT
      a.entity_name
   FROM   fnd_attached_documents a,
          fnd_documents d
   WHERE
      d.category_id IN
        (SELECT category_id
          FROM FND_DOCUMENT_CATEGORIES
          WHERE ( UPPER(name) like l_bind_var_msds   or
          UPPER(name) like  l_bind_var_hazard or
          UPPER(name) like  l_bind_var_safety ) AND
          UPPER(name) NOT like  l_bind_var_msds_rejected
         )
      AND d.document_id = a.document_id
      AND (( a.entity_name = 'OE_ORDER_LINES' AND a.pk1_value = LocalDeliverydetail.source_line_id )
            OR (a.entity_name = 'WSH_DELIVERY_DETAILS' AND a.pk1_value = LocalDeliverydetail.delivery_detail_id ));
 LocalAttachDocDetail c_get_attch_doc_details%ROWTYPE;

 /* Used to retrieve Item Code */
   CURSOR c_get_item_code(p_organization_id NUMBER, p_item_id NUMBER)IS
       Select segment1
        from mtl_system_items
        where inventory_item_id = p_item_id
          and organization_id = p_organization_id;

 /* Used to Check the Item Regulatory Item or not
 CURSOR c_regulatory_item IS
    SELECT 1
     FROM dual
    WHERE EXISTS (SELECT 1 FROM gr_item_general where item_code  = l_item_code)
       OR EXISTS (SELECT 1 FROM gr_generic_items_b where item_no = l_item_code);  */

 /* Used to get the Territory Details */
 CURSOR c_territory_details IS
    select p.document_code, p.language, p.disclosure_code
    from GR_COUNTRY_PROFILES p,
         HZ_LOCATIONS l
    where  p.territory_code = l.country and
           l.location_id = LocalDeliverydetail.ship_to_location_id;
 l_territory_details  c_territory_details%ROWTYPE;

 /* Used to get the Country code if there is no territory profile set up */
 CURSOR c_get_country IS
    SELECT country
    FROM   HZ_LOCATIONS
    WHERE  location_id = LocalDeliverydetail.ship_to_location_id;
 CountryRec  c_get_country%ROWTYPE;

 /* Used to get the Latest Details of a Regulatory Item Document */
 CURSOR c_latest_document IS
    SELECT *
    FROM fnd_documents_vl
    WHERE DOC_ATTRIBUTE1 = l_item_code
    and DOC_ATTRIBUTE2 = l_territory_details.DOCUMENT_CODE
    and DOC_ATTRIBUTE3 = l_territory_details.LANGUAGE
    and DOC_ATTRIBUTE4 = l_territory_details.DISCLOSURE_CODE
    and   ( UPPER(DOC_ATTRIBUTE_CATEGORY) like l_bind_var_msds  or
        UPPER(DOC_ATTRIBUTE_CATEGORY) like l_bind_var_hazard or
        UPPER(DOC_ATTRIBUTE_CATEGORY) like l_bind_var_safety )
    AND UPPER(DOC_ATTRIBUTE_CATEGORY) NOT like l_bind_var_msds_rejected
	And publish_flag = 'Y'
    ORDER BY CREATION_DATE DESC;
 LocalLatestDocument  c_latest_document%ROWTYPE;

 /* Used to get the Latest Dispatch details of the Item Document */
 Cursor c_get_last_dispatch_date IS
	Select max(date_sent)
    From GR_DISPATCH_HISTORY_V
    Where INVENTORY_ITEM_ID = LocalDeliverydetail.inventory_item_id   --  BUG#4431025
       and  ORGANIZATION_ID = LocalDeliverydetail.organization_id -- BUG#4431025
       and  DOCUMENT_CODE = l_territory_details.DOCUMENT_CODE
       and  DOCUMENT_LANGUAGE = l_territory_details.LANGUAGE
       and  DISCLOSURE_CODE = l_territory_details.DISCLOSURE_CODE
       and Recipient_id     = LocalDeliveryDetail.customer_id;

 /* Get Sequence number for Next New attachment */
 CURSOR  c_get_seq IS
    SELECT  NVL(max(seq_num),0) + 10
    FROM  fnd_attached_documents
    WHERE entity_name= 'WSH_DELIVERY_DETAILS'
      AND pk1_value = LocalDeliverydetail.delivery_detail_id;

 /*Used to get the next attached_document_id  for a new attachment*/
 CURSOR  c_get_id IS
    SELECT fnd_attached_documents_s.nextval
    FROM dual;


BEGIN

   /* Bug 4912043 Populating the bind variables with the message text instead of hardcoding the text in the Query */
   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_MSDS');
   l_bind_var_msds := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_SAFETY');
   l_bind_var_safety := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_HAZARD');
   l_bind_var_hazard := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_MSDS_REJECTED');
   l_bind_var_msds_rejected := FND_MESSAGE.GET;

   l_user_id := NVL(FND_PROFILE.VALUE('USER_ID'),0);

   OPEN  c_get_delivery_details;
   FETCH c_get_delivery_details into LocalDeliverydetail;

   /* For each line on the given Shipment */
   IF c_get_delivery_details%FOUND THEN

      WHILE c_get_delivery_details%FOUND LOOP

        /* Get item code */
        OPEN c_get_item_code(LocalDeliverydetail.organization_id, LocalDeliverydetail.inventory_item_id);
        FETCH c_get_item_code into l_item_code;
        CLOSE c_get_item_code;

        /* Check to see if the item on this Shipment line is a Regulatory Item
        OPEN c_regulatory_item;
        FETCH c_regulatory_item INTO l_regulatory_item_exists;

        /* If this is a Regulatory Item
        IF c_regulatory_item%FOUND THEN */

           /* Check Regulatory document has already been attached to the Shipment or Sales Order line */
           OPEN c_get_attch_doc_details;
           FETCH c_get_attch_doc_details into LocalAttachDocDetail;

           /* If a document has NOT already been attached*/
           IF c_get_attch_doc_details%NOTFOUND THEN

              /* Retrieve document type, language, disclosure code for territory */
              OPEN c_territory_details;
              FETCH c_territory_details INTO l_territory_details;

              /* If a territory profile for that territory is NOT found */
              IF c_territory_details%NOTFOUND THEN

                 OPEN c_get_country;
                 FETCH c_get_country into CountryRec;
                 CLOSE c_get_country;

                 FND_MESSAGE.SET_NAME('GR', 'GR_NO_TERRITORY_PROFILE');
                 FND_MESSAGE.SET_TOKEN('COUNTRY', CountryRec.country, FALSE);
                 l_msg_data := FND_MESSAGE.GET;
                 FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                 FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

              ELSE
                 /* Retrieve the latest version of the document that matches the item, document_type, language and
                    disclosure code from the territory profile     */
                 OPEN c_latest_document;
                 FETCH c_latest_document  into LocalLatestDocument;

                 /*If no document meets that criteria */
                 IF c_latest_document%NOTFOUND THEN
                    /* Write no document found message to error log */
                    FND_MESSAGE.SET_NAME('GR', 'GR_NO_ATTACH_DOCUMENT');
                    FND_MESSAGE.SET_TOKEN('ITEM', l_item_code, FALSE);
                    FND_MESSAGE.SET_TOKEN('DOC_CODE', l_territory_details.document_code, FALSE);
                    FND_MESSAGE.SET_TOKEN('LANG', l_territory_details.language, FALSE);
                    FND_MESSAGE.SET_TOKEN('DISCLOSURE', l_territory_details.disclosure_code, FALSE);
                    l_msg_data := FND_MESSAGE.GET;
                    FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                    FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

                 ELSE

                   /* Check the dispatch history to see the last time this document was sent to the recipient */
                   OPEN c_get_last_dispatch_date;
                   FETCH c_get_last_dispatch_date into l_last_dispatch_date;

                   /* If a  Dispatch History record is NOT found, attach the document to the shipment line */
                   IF l_last_dispatch_date IS NULL THEN
                      l_create_attachment := 'Y';
                   ELSE
                      /* If the retrieved document is newer than the last one that was sent */
                      IF l_last_dispatch_date < LocalLatestDocument.creation_date THEN
                         l_create_attachment := 'Y';
                      ELSE
                         l_create_attachment := 'N';
                      END IF;
                   END IF;
                   CLOSE c_get_last_dispatch_date;

                   IF l_create_attachment = 'Y' THEN

                      OPEN c_get_id;
                      FETCH c_get_id INTO l_attached_document_id;
                      CLOSE c_get_id;

                      /* Get the next sequence number */
                      OPEN c_get_seq;
                      FETCH c_get_seq INTO l_seq;
                      IF c_get_seq%NOTFOUND THEN
               		l_seq := 10;
                      END IF;
                      CLOSE c_get_seq;

                      FND_ATTACHED_DOCUMENTS_PKG.Insert_Row(
                             X_Rowid                      => l_rowid,
                             X_attached_document_id       => l_attached_document_id,
                             X_document_id                => LocalLatestDocument.document_id,
                             X_creation_date              => SYSDATE,
                             X_created_by                 => l_user_id,
                             X_last_update_date           => SYSDATE,
                             X_last_updated_by            => l_user_id,
                             X_last_update_login          => NULL,
                             X_seq_num                    => l_seq,
                             X_entity_name                => 'WSH_DELIVERY_DETAILS',
                             X_column1                    => NULL,
                             X_pk1_value                  => LocalDeliverydetail.delivery_detail_id,
                             X_pk2_value                  => NULL,
                             X_pk3_value                  => NULL,
                             X_pk4_value                  => NULL,
                             X_pk5_value                  => NULL,
                             X_automatically_added_flag   => 'Y',
                             X_datatype_id                => LocalLatestDocument.datatype_id,
                             X_category_id                => LocalLatestDocument.category_id,
                             X_security_type              => LocalLatestDocument.security_type,
                             X_security_id                => LocalLatestDocument.security_id,
                             X_publish_flag               => LocalLatestDocument.publish_flag,
                             X_storage_type               => LocalLatestDocument.storage_type,
                             X_usage_type                 => LocalLatestDocument.usage_type,
                             X_language                   => LocalLatestDocument.doc_attribute3,
                             X_description                => LocalLatestDocument.description,
                             X_file_name                  => LocalLatestDocument.file_name,
                             X_media_id                   => LocalLatestDocument.media_id,
                             X_attribute_category         => LocalLatestDocument.doc_attribute_category,
                             X_attribute1                 => LocalLatestDocument.doc_attribute1,
                             X_attribute2                 => LocalLatestDocument.doc_attribute2,
                             X_attribute3                 => LocalLatestDocument.doc_attribute3,
                             X_attribute4                 => LocalLatestDocument.doc_attribute4,
                             X_attribute5                 => LocalLatestDocument.doc_attribute5,
                             X_attribute6                 => LocalLatestDocument.doc_attribute6,
                             X_attribute7                 => LocalLatestDocument.doc_attribute7,
                             X_attribute8                 => LocalLatestDocument.doc_attribute8,
                             X_attribute9                 => LocalLatestDocument.doc_attribute9,
                             X_attribute10                => LocalLatestDocument.doc_attribute10,
                             X_attribute11                => LocalLatestDocument.doc_attribute11,
                             X_attribute12                => LocalLatestDocument.doc_attribute12,
                             X_attribute13                => LocalLatestDocument.doc_attribute13,
                             X_attribute14                => LocalLatestDocument.doc_attribute14,
                             X_attribute15                => LocalLatestDocument.doc_attribute15,
                             X_create_doc                 => 'N');

                    END IF;  /* Create attachment */

                 END IF; /*latest document found */
                 CLOSE c_latest_document;

               END IF; /* territory Details */
               CLOSE c_territory_details;

            END IF; /* attachments check */
            CLOSE c_get_attch_doc_details;


         FETCH c_get_delivery_details into LocalDeliverydetail;

      END LOOP;
   END IF;/*DELIVERY DETAILS*/

   l_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
      l_code_block :='Shipping Attachment :'  ;
      FND_MESSAGE.SET_NAME('GR','GR_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',l_code_block||sqlerrm, FALSE);
      x_msg_data := FND_MESSAGE.GET;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


/*===========================================================================
--  PROCEDURE:
--    print_reg_docs
--
--  DESCRIPTION:
--    This procedure is used to print the current version of approved documents
--    that fall within the specified ranges.
--
--  PARAMETERS:
--    errbuf                    OUT NOCOPY VARCHAR2     - Error message, when submitted from concurrent program
--    retcode                   OUT NOCOPY VARCHAR2     - Error code, when submitted from concurrent program
--    p_orgn_id                 IN           NUMBER     - Organization_id to search items in.
--    p_from_item               IN         VARCHAR2     - First item in range
--    p_to_item                 IN         VARCHAR2     - Last item in range
-     p_from_language           IN         VARCHAR2     - First language in range
--    p_to_language             IN         VARCHAR2     - Last language in range
--    p_document_category       IN         VARCHAR2     - Document category to retrict documents to
--    p_update_dispatch_history IN         VARCHAR2     - Update Dispatch History - 'Y'es or 'N'o
--    p_recipent_site           IN         NUMBER       - ID of site receiving the dispatch
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.print_reg_item_docs(errbuf,retcode,p_from_item,p_to_item,p_from_lang,
--                     p_to_lang,p_doc_category,p_upd_disp_hist,p_recipient_site);
--
--  HISTORY
--=========================================================================== */


PROCEDURE PRINT_REG_DOCS(
	    errbuf                    OUT NOCOPY VARCHAR2
	   ,retcode                   OUT NOCOPY VARCHAR2
	   ,p_orgn_id                 IN           NUMBER
	   ,p_from_item               IN         VARCHAR2
	   ,p_to_item                 IN         VARCHAR2
	   ,p_from_language           IN	 VARCHAR2
	   ,p_to_language             IN	 VARCHAR2
	   ,p_document_category       IN         VARCHAR2
	   ,p_update_dispatch_history IN         VARCHAR2
	   ,p_recipient_site          IN         VARCHAR2
	) IS

     l_orgn_code            varchar2(3);

   /* Bug 4912043 created new bind variables */
   l_bind_var_msds	             VARCHAR2(2000);
   l_bind_var_hazard            VARCHAR2(2000);
   l_bind_var_safety            VARCHAR2(2000);
   l_bind_var_msds_rejected     VARCHAR2(2000);

   /*  ------------------ CURSORS ---------------------- */
     /* Used to get the document information for all Regulatory document categories */
     CURSOR  c_get_doc_info   IS
        SELECT *
          FROM fnd_documents_vl a
          WHERE a.creation_date = (SELECT max(b.creation_date) FROM fnd_documents_vl b
                                     WHERE a.doc_attribute1 = b.doc_attribute1
                                       AND a.doc_attribute3 = b.doc_attribute3
                                      AND a.doc_attribute5 = l_orgn_code
                                       AND (UPPER(b.DOC_ATTRIBUTE_CATEGORY)   like   l_bind_var_msds
            	                            OR  UPPER(b.DOC_ATTRIBUTE_CATEGORY)   like    l_bind_var_safety
                                            OR UPPER(b.DOC_ATTRIBUTE_CATEGORY)   like    l_bind_var_hazard)
                                       AND UPPER(b.DOC_ATTRIBUTE_CATEGORY)  not like    l_bind_var_msds_rejected
                                       AND ( (a.DOC_ATTRIBUTE_CATEGORY = p_document_category))
                                       AND b.publish_flag = 'Y')
             AND a.DOC_ATTRIBUTE1   >= nvl(p_from_item,' ')
             AND a.DOC_ATTRIBUTE1   <= nvl(p_to_item,'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ')
             AND a.DOC_ATTRIBUTE3   >= nvl(p_from_language,' ')
             AND a.DOC_ATTRIBUTE3   <= nvl(p_to_language,'ZZZZ')
             AND (UPPER(a.DOC_ATTRIBUTE_CATEGORY)   like   l_bind_var_msds
            	 OR  UPPER(a.DOC_ATTRIBUTE_CATEGORY)   like   l_bind_var_safety
                 OR UPPER(a.DOC_ATTRIBUTE_CATEGORY)   like    l_bind_var_hazard)
             AND UPPER(a.DOC_ATTRIBUTE_CATEGORY)  not like   l_bind_var_msds_rejected
             AND ((a.DOC_ATTRIBUTE_CATEGORY = p_document_category))
             AND a.publish_flag = 'Y';
       DocumentRec c_get_doc_info%ROWTYPE;



    CURSOR c_get_recipient_details IS
        SELECT  party_id, party_site_id
         FROM hz_party_sites
        WHERE party_site_number = p_recipient_site;

    Cursor C_get_organization_code(l_orgn_id number) IS
       SELECT ORGANIZATION_CODE from mtl_parameters
         where ORGANIZATION_ID =  l_orgn_id;

    Cursor C_get_item_id(l_orgn_id number, l_item_code varchar2) IS
       SELECT inventory_item_id from mtl_system_items
         where ORGANIZATION_ID = l_orgn_id
         and SEGMENT1 = l_item_code;


  /*  ------------- LOCAL VARIABLES ------------------- */

     l_item_id              NUMBER;
     l_concurrent_id      NUMBER(15);
     l_user_id            NUMBER(15);
     l_recipient_site_id  NUMBER(15);
     l_recipient_id       NUMBER(15);
     l_msg_data           VARCHAR2(2000);
     l_return_status      VARCHAR2(3);
     l_code_block         VARCHAR2(200);
     l_msg_count          NUMBER;
     l_error_msg          VARCHAR2(2000);

 /*  ------------------ EXCEPTIONS ---------------------- */
     No_Document_To_Print 		EXCEPTION;
     No_Recipient_Exists		EXCEPTION;


BEGIN

   /* Bug 4912043 Populating the bind variables with the message text instead of hardcoding the text in the Query */
   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_MSDS');
   l_bind_var_msds := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_SAFETY');
   l_bind_var_safety := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_HAZARD');
   l_bind_var_hazard := FND_MESSAGE.GET;

   FND_MESSAGE.SET_NAME('GR','GR_BIND_VAR_MSDS_REJECTED');
   l_bind_var_msds_rejected := FND_MESSAGE.GET;

     l_user_id := NVL(FND_PROFILE.VALUE('USER_ID'),0);

 open C_get_organization_code(p_orgn_id);
 fetch C_get_organization_code into l_orgn_code;
     IF C_get_organization_code %NOTFOUND THEN
        l_orgn_code :=' ';
     END IF;
 CLOSE C_get_organization_code;




  /* Select documents  */
     OPEN  c_get_doc_info;
     FETCH c_get_doc_info into DocumentRec;
     IF c_get_doc_info %NOTFOUND THEN
       Close c_get_doc_info;
       RAISE No_Document_To_Print;
     ELSE
         OPEN  C_get_item_id(p_orgn_id, DocumentRec.doc_attribute1);
         FETCH C_get_item_id into l_item_id;
         IF C_get_item_id%NOTFOUND THEN
           l_item_id := 0;
         END IF;
         Close C_get_item_id;
       /* If updating dispatch history, get recipient info */
       IF p_update_dispatch_history   = 'Y' THEN

           OPEN  c_get_recipient_details ;
           FETCH c_get_recipient_details
                   INTO l_recipient_id,l_recipient_site_id;
           IF c_get_recipient_details%NOTFOUND THEN
                RAISE No_Recipient_Exists;
                CLOSE c_get_recipient_details ;
            ELSE
                CLOSE c_get_recipient_details ;
            END IF; /* If recipient is found */
       END IF; /* Updating dispatch history */
       WHILE c_get_doc_info %FOUND LOOP
          /* Post the File Name printed to the file */
          FND_MESSAGE.SET_NAME('GR','GR_ITEM_LANG_CATEGORY');
          FND_MESSAGE.SET_TOKEN('ITEM', DocumentRec.doc_attribute1,FALSE);
          FND_MESSAGE.SET_TOKEN('LANG', DocumentRec.doc_attribute3,FALSE);
          FND_MESSAGE.SET_TOKEN('CATEGORY',DocumentRec.doc_attribute_category,FALSE);
          l_msg_data := FND_MESSAGE.GET;
          FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
          /* Post the File Name printed to the file */
          FND_MESSAGE.SET_NAME('GR','GR_FILE_NAME_TEXT');
          FND_MESSAGE.SET_TOKEN('FILE_NAME', DocumentRec.file_name,FALSE);
          l_msg_data := FND_MESSAGE.GET;
          FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
          FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
          l_concurrent_id :=
            FND_REQUEST.SUBMIT_REQUEST
                 ( 'GR', 'GR_PRINT_SHIP_DOC', '', '', FALSE,
                   DocumentRec.media_id,
                   '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '',
                   '', '', '', '', '', '', '', '', '', '');
            IF l_concurrent_id = 0 THEN
                FND_MESSAGE.SET_NAME('GR','GR_CONC_REQ_PRINT_DOC');
                FND_MESSAGE.SET_TOKEN('FILE_NAME', DocumentRec.file_name,FALSE);
                l_msg_data := FND_MESSAGE.GET;
                FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
	    ELSE
                IF p_update_dispatch_history   = 'Y' THEN

                    FND_MESSAGE.SET_NAME('GR', 'GR_CREATING_DISPATCH_HISTORY');
                    FND_MESSAGE.SET_TOKEN('FILE_NAME', DocumentRec.file_name,FALSE);
                    l_msg_data := FND_MESSAGE.GET;
                    FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                    FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                    GR_DISPATCH_HISTORY_PUB.create_dispatch_history (
                         p_api_version          => 1.0,
                  	 p_init_msg_list        => FND_API.G_FALSE,
                         p_commit               => FND_API.G_TRUE,
                         p_item                 => DocumentRec.doc_attribute1,
                         p_organization_id      => p_orgn_id,
                         p_inventory_item_id    => l_item_id,
                         p_recipient_id         => l_recipient_id,
                         p_recipient_site_id    => l_recipient_site_id,
                         p_date_sent            => SYSDATE,
                         p_dispatch_method_code => 3,
                         p_document_id          => DocumentRec.document_id,
                         p_user_id              => l_user_id,
                         p_creation_source      => 1,
                         p_cas_number           => NULL,
                         p_document_location    => NULL,
                         p_document_name        => NULL,
                         p_document_version     => NULL,
                         p_document_category    => NULL,
                         p_file_format          => NULL,
                         p_file_description     => NULL,
                         p_document_code        => NULL,
                         p_disclosure_code      => NULL,
                         p_language             => NULL,
                         p_organization_code    => NULL,
                         x_return_status        => l_return_status,
                         x_msg_count            => l_msg_count,
                         x_msg_data             => l_error_msg  );
                   IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                      FND_MESSAGE.SET_NAME('GR', 'GR_DISPATCH_HISTORY_FAILED');
                      FND_MESSAGE.SET_TOKEN('FILE_NAME',DocumentRec.File_name, FALSE);
                      l_msg_data := FND_MESSAGE.GET;
                      FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
                      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                      FND_FILE.PUT(FND_FILE.LOG, l_error_msg);
                      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
                   END IF;

       	     END IF; /* update dispatch history */
         END IF; /* g_concurrent_id */
         FND_FILE.PUT(FND_FILE.LOG, '          ');
         FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

         FETCH c_get_doc_info INTO DocumentRec;
      END LOOP;
      CLOSE c_get_doc_info;
   END IF;   /* If documents found */


EXCEPTION
    WHEN No_Document_To_Print THEN
       FND_MESSAGE.SET_NAME('GR','GR_NO_DOCUMENT_TO_PRINT');
       l_msg_data := FND_MESSAGE.GET;
       FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

    WHEN No_Recipient_Exists THEN
       FND_MESSAGE.SET_NAME('GR','GR_INVALID_RECIPIENT_SITE_NUM');
       FND_MESSAGE.SET_TOKEN('SITE_NUM', P_Recipient_site      , FALSE);
       l_msg_data := FND_MESSAGE.GET;
       FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);

    WHEN OTHERS THEN
       l_code_block :='Print Regulatory Doc ' ;
       FND_MESSAGE.SET_NAME('GR','GR_UNEXPECTED_ERROR');
       FND_MESSAGE.SET_TOKEN('TEXT',l_code_block||sqlerrm, FALSE);
       l_msg_data := FND_MESSAGE.GET;
       FND_FILE.PUT(FND_FILE.LOG, l_msg_data);
       FND_FILE.NEW_LINE(FND_FILE.LOG, 1);


END PRINT_REG_DOCS;



END GR_REG_PRINT_DOC;


/
