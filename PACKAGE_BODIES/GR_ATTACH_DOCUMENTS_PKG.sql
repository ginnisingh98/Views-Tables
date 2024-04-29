--------------------------------------------------------
--  DDL for Package Body GR_ATTACH_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ATTACH_DOCUMENTS_PKG" AS
/*  $Header: GRATTCHB.pls 115.7 2004/07/12 20:34:49 methomas noship $    */

/*===========================================================================
--  FUNCTION:
--    attach_to_entity
--
--  DESCRIPTION:
--    This PL/SQL function is used to attach a document to an entity (Regulatory Item,
--    Inventory Item, etc) based upon the values stored in the attribute columns.
--    For the moment it only supports attachment to Regulatory Items.
--
--  PARAMETERS:
--    p_itemtype IN  VARCHAR2    - The type of workflow
--    p_itemkey IN  NUMBER       - The key to the workflow record
--
--  RETURNS:
--    YES
--    NO
--
--  SYNOPSIS:
--    x_status := GR_ATTACH_DOCUMENTS.attach_to_entity(p_itemtype,p_itemkey);
--
--  HISTORY
--=========================================================================== */
   PROCEDURE ATTACH_TO_ENTITY(p_itemtype VARCHAR2,
                              p_itemkey VARCHAR2,
                              p_actid NUMBER,
                              p_funcmode VARCHAR2,
                              p_resultout OUT NOCOPY VARCHAR2) AS


      /************* Local Variables *************/

      l_event_key varchar2(240);
      l_file_status varchar2(15);
      l_category_name VARCHAR2(30);
      l_entity_name  VARCHAR2(80);
      l_rowid  VARCHAR2(200);
      l_attached_document_id NUMBER;
      l_document_id NUMBER;
      l_temp_value VARCHAR2(80);
      l_pk1_value VARCHAR2(100);
      l_pk2_value VARCHAR2(100);
      l_pk3_value VARCHAR2(100);
      l_pk4_value VARCHAR2(150);
      l_pk5_value VARCHAR2(150);
      l_seq   NUMBER;
      l_media  NUMBER;
      l_category_id NUMBER;
      l_function_name VARCHAR2(200);
      /* M.Thomas 3756011 07/09/2004 Added the following local variable */
      l_delivery_detail_id NUMBER;
      /* M.Thomas 3756011 07/09/2004 End of the changes */

     /*****************  Cursors  ****************/

     /* Used to get the document information */
     CURSOR  c_doc_info IS
       SELECT  *
         FROM  fnd_documents_vl
        WHERE  document_id = l_document_id;
     l_doc    c_doc_info%ROWTYPE;

     /* Used to see if this attachment already exists */
     CURSOR  c_attachment_exists IS
         SELECT  rowid, attached_document_id, seq_num
           FROM  fnd_attached_documents
          WHERE  entity_name  = l_entity_name AND
                 NVL(pk1_value,'NULL') = NVL(l_pk1_value,'NULL') AND
                 NVL(pk2_value,'NULL') = NVL(l_pk2_value,'NULL') AND
                 NVL(pk3_value,'NULL') = NVL(l_pk3_value,'NULL') AND
                 NVL(pk4_value,'NULL') = NVL(l_pk4_value,'NULL') AND
                 NVL(pk5_value,'NULL') = NVL(l_pk5_value,'NULL') AND
                 attribute_category = l_doc.doc_attribute_category AND
	         attribute1 = l_doc.doc_attribute1 AND
	         attribute2 = l_doc.doc_attribute2 AND
	         attribute3 = l_doc.doc_attribute3 AND
                 attribute4 = l_doc.doc_attribute4 AND
                 attribute5 = l_doc.doc_attribute5;

    /* Used to get the next attached_document_id  for a new attachment */
    CURSOR  c_get_id IS
         SELECT fnd_attached_documents_s.nextval
           FROM dual;

    /* Used to get the next sequence number for a new attachment */
    CURSOR  c_get_seq IS
         SELECT  NVL(max(seq_num),0) + 10
           FROM  fnd_attached_documents
          WHERE  entity_name  = l_entity_name AND
                 NVL(pk1_value,'NULL') = NVL(l_pk1_value,'NULL') AND
                 NVL(pk2_value,'NULL') = NVL(l_pk2_value,'NULL') AND
                 NVL(pk3_value,'NULL') = NVL(l_pk3_value,'NULL') AND
                 NVL(pk4_value,'NULL') = NVL(l_pk4_value,'NULL') AND
                 NVL(pk5_value,'NULL') = NVL(l_pk5_value,'NULL');

     /* Used to get category ID for MSDS_REJECTED */
     CURSOR  c_get_category_id IS
       SELECT  category_id
         FROM  fnd_document_categories
        WHERE  name = 'MSDS_REJECTED';

     /* Used to get list of functions for the categories */
     CURSOR c_get_entity_info IS
       SELECT FUNCTION_NAME
       FROM FND_DOC_CATEGORY_USAGES_VL
       WHERE name in ('MSDS_REG_ITEM', 'MSDS_INV_ITEM', 'MSDS_SALES_ORDER');

     /* M.Thomas 3756011 07/09/2004 The following cursor has been added to get the delivery detail line information */

     /* Used to get the delivery detail id for entity WSH_DELIVERY_DETAILS  */
     CURSOR  c_get_delivery_detail_id IS
       SELECT delivery_detail_id
              FROM WSH_DELIVERABLES_V
             WHERE container_flag = 'N'
             and   source_code = 'OE'
             and released_status in ('N', 'R', 'S', 'Y', 'B', 'X')
             and inventory_item_id = (select distinct inventory_item_id from mtl_system_items where segment1 = l_doc.doc_attribute1)
             and organization_id =  (SELECT organization_id FROM mtl_parameters WHERE	organization_code = l_doc.doc_attribute5)
             and source_header_number = l_doc.doc_attribute8
             and source_line_number   = to_number(l_doc.doc_attribute9)
             Order by delivery_detail_id;
      /* M.Thomas 3756011 07/09/2004 End of the changes */

   BEGIN

      /* M.Thomas 3211481 The following change as been made to the initialization due to the GSCC warning */
      l_event_key   := WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'EVENT_KEY');

      l_file_status := WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname=>'FILE_STATUS');
      /* M.Thomas 3211481 End of the changes */

      /* Get the category name */
      EDR_FILE_UTIL_PUB.get_category_name(l_event_key, l_category_name);

      /* M. Grosser 11-Jan-2004   BUG 3359911 - Modified to account for change
                                  in event status from SUCCESS to NO APPROVAL
                                  for no approval required uploads.
      */
      /* Only execute this code if the document has been approved */
      IF (l_file_status = 'SUCCESS' OR l_file_status = 'NO APPROVAL') THEN

         /* Set up table name for the attachment. Only attaching to regulatory items for this pass */
         IF (l_category_name = 'MSDS_REG_ITEM') THEN
            l_entity_name := 'GR_ITEM_GENERAL';
         /* M. Thomas Bug 3211481 14-May-2004 Added the following to attach the document to the Shipment */
         ELSIF (l_category_name = 'MSDS_SALES_ORDER') THEN
            l_entity_name := 'WSH_DELIVERY_DETAILS';
         /* M. Thomas Bug 3211481 14-May-2004 End of the following changes. */
         END IF;

            IF l_entity_name is NOT NULL THEN

               /* Get the document ID */
               EDR_FILE_UTIL_PUB.get_attribute(l_event_key, 'fnd_document_id',l_temp_value);
               l_document_id := TO_NUMBER(l_temp_value);

               /* Get the document information */
               OPEN c_doc_info;
               FETCH c_doc_info INTO l_doc;
               CLOSE c_doc_info;

               /* Set up the key fields for the table */
               IF (l_category_name = 'MSDS_REG_ITEM') THEN
                  l_pk1_value :=l_doc.doc_attribute1;
                  l_pk2_value := NULL;
                  l_pk3_value := NULL;
                  l_pk4_value := NULL;
                  l_pk5_value := NULL;
               END IF;

               /* Set up the key fields for the table */
               /* M. Thomas Bug 3211481 14-May-2004 Added the following to update the key fields for the attached document for a Shipment */
               IF (l_category_name = 'MSDS_SALES_ORDER') THEN

                  /* M.Thomas 3756011 07/09/2004 the following code has been added in order to insert/update
				     the primary key delivery detail line id instead of sales order number for the entity WSH_DELIVERY_DETAILS  */

                  /* Get the Primary Key delivery Detail Id for the entity WSH_DELIVERY_DETAILS */
                  OPEN c_get_delivery_detail_id;
                  FETCH c_get_delivery_detail_id INTO l_delivery_detail_id;
                  CLOSE c_get_delivery_detail_id;

                  If l_delivery_detail_id IS NOT NULL THEN
                     l_pk1_value :=l_delivery_detail_id;
                  END IF;
                  /* M.Thomas 3756011 07/09/2004 End of the code changes */

				  l_pk2_value := NULL;
                  l_pk3_value := NULL;
                  l_pk4_value := NULL;
                  l_pk5_value := NULL;
               END IF;
               /* M. Thomas Bug 3211481 14-May-2004 End of the changes */

               /* Check to see if a previous version of this document has already been attached */
               OPEN c_attachment_exists;
               FETCH c_attachment_exists INTO l_rowid, l_attached_document_id, l_seq;

               /* If not, attach the new document */
               IF c_attachment_exists%NOTFOUND THEN

                  /* Get the next id for attached documents */
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

                 /* M. Grosser 11-Jan-2004   BUG 3359911 - Modified to correct overwrite of document
                                             description
                 */
                 FND_ATTACHED_DOCUMENTS_PKG.Insert_Row(X_Rowid                      => l_Rowid,
                                                       X_attached_document_id       => l_attached_document_id,
                                                       X_document_id                => l_doc.document_id,
                                                       X_creation_date              => SYSDATE,
                                                       X_created_by                 => l_doc.created_by,
                                                       X_last_update_date           => SYSDATE,
                                                       X_last_updated_by            => l_doc.last_updated_by,
                                                       X_last_update_login          => NULL,
                                                       X_seq_num                    => l_seq,
                                                       X_entity_name                => l_entity_name,
                                                       X_column1                    => NULL,
                                                       X_pk1_value                  => l_pk1_value,
                                                       X_pk2_value                  => l_pk2_value,
                                                       X_pk3_value                  => l_pk3_value,
                                                       X_pk4_value                  => l_pk4_value,
                                                       X_pk5_value                  => l_pk5_value,
                                                       X_automatically_added_flag   => 'Y',
                                                       X_datatype_id                => l_doc.datatype_id,
                                                       X_category_id                => l_doc.category_id,
                                                       X_security_type              => l_doc.security_type,
                                                       X_security_id                => l_doc.security_id,
                                                       X_publish_flag               => l_doc.publish_flag,
                                                       X_storage_type               => l_doc.storage_type,
                                                       X_usage_type                 => l_doc.usage_type,
                                                       X_language                   => l_doc.doc_attribute3,
                                                       X_description                => l_doc.description,
                                                       X_file_name                  => l_doc.file_name,
                                                       X_media_id                   => l_doc.media_id,
                                                       X_attribute_category         => l_doc.doc_attribute_category,
                                                       X_attribute1                 => l_doc.doc_attribute1,
                                                       X_attribute2                 => l_doc.doc_attribute2,
                                                       X_attribute3                 => l_doc.doc_attribute3,
                                                       X_attribute4                 => l_doc.doc_attribute4,
                                                       X_attribute5                 => l_doc.doc_attribute5,
                                                       X_attribute6                 => l_doc.doc_attribute6,
                                                       X_attribute7                 => l_doc.doc_attribute7,
                                                       X_attribute8                 => l_doc.doc_attribute8,
                                                       X_attribute9                 => l_doc.doc_attribute9,
                                                       X_attribute10                => l_doc.doc_attribute10,
                                                       X_attribute11                => l_doc.doc_attribute11,
                                                       X_attribute12                => l_doc.doc_attribute12,
                                                       X_attribute13                => l_doc.doc_attribute13,
                                                       X_attribute14                => l_doc.doc_attribute14,
                                                       X_attribute15                => l_doc.doc_attribute15,
                                                       X_create_doc                 => 'N');
                 ELSE
                    /* The attachment already exists so we will just update it with the new file */
      	         fnd_attached_documents_pkg.update_row(
                                                       X_rowid                      => l_Rowid,
                                                       X_attached_document_id       => l_attached_document_id,
                                                       X_document_id                => l_document_id,
                                                       X_last_update_date           => SYSDATE,
                                                       X_last_updated_by            => l_doc.last_updated_by,
                                                       X_last_update_login          => NULL,
                                                       X_seq_num                    => l_seq,
                                                       X_column1                    => NULL,
                                                       X_entity_name                => l_entity_name,
                                                       X_pk1_value                  => l_pk1_value,
                                                       X_pk2_value                  => l_pk2_value,
                                                       X_pk3_value                  => l_pk3_value,
                                                       X_pk4_value                  => l_pk4_value,
                                                       X_pk5_value                  => l_pk5_value,
                                                       X_automatically_added_flag   => 'Y',
                                                       X_request_id   => NULL,
                                                       X_program_application_id => NULL,
                                                       X_program_id          => NULL,
                                                       X_program_update_date   => NULL,
                                                       X_attribute_category   => l_doc.doc_attribute_category,
                                                       X_attribute1           => l_doc.doc_attribute1,
                                                       X_attribute2           => l_doc.doc_attribute2,
                                                       X_attribute3           => l_doc.doc_attribute3,
                                                       X_attribute4           => l_doc.doc_attribute4,
                                                       X_attribute5           => l_doc.doc_attribute5,
                                                       X_attribute6           => l_doc.doc_attribute6,
                                                       X_attribute7           => l_doc.doc_attribute7,
                                                       X_attribute8           => l_doc.doc_attribute8,
                                                       X_attribute9           => l_doc.doc_attribute9,
                                                       X_attribute10          => l_doc.doc_attribute10,
                                                       X_attribute11          => l_doc.doc_attribute11,
                                                       X_attribute12          => l_doc.doc_attribute12,
                                                       X_attribute13          => l_doc.doc_attribute13,
                                                       X_attribute14          => l_doc.doc_attribute14,
                                                       X_attribute15          => l_doc.doc_attribute15,
                                                       X_datatype_id          => l_doc.datatype_id,
                                                       X_category_id          => l_doc.category_id,
                                                       X_security_type        => l_doc.security_type,
                                                       X_security_id          => l_doc.security_id,
                                                       X_publish_flag         => l_doc.publish_flag,
                                                       X_image_type           => l_doc.image_type,
                                                       X_storage_type         => l_doc.storage_type,
                                                       X_usage_type           => l_doc.usage_type,
                                                       X_start_date_active    => SYSDATE,
                                                       X_end_date_active      => NULL ,
                                                       X_language             => l_doc.doc_attribute3,
                                                       X_description          => l_doc.description,
                                                       X_file_name            => l_doc.file_name,
                                                       X_media_id             => l_doc.media_id);

                    /* M. Grosser 11-Jan-2004   BUG 3359911 - End of changes */

                     END IF;   /* If attachment already exists */
                  END IF; /* If entity name is not NULL */
                  p_resultout := G_YES;
            CLOSE c_get_entity_info;
      ELSE /* Document has not been approved, don't attach it */

            IF (l_category_name in ('MSDS_REG_ITEM','MSDS_INV_ITEM','MSDS_SALES_ORDER','MSDS_RECIPIENT')) THEN
               /* Get the document ID */
               EDR_FILE_UTIL_PUB.get_attribute(l_event_key, 'fnd_document_id',l_temp_value);
               l_document_id := TO_NUMBER(l_temp_value);

               /* Get the category id for MSDS_REJECTED */
               OPEN c_get_category_id;
               FETCH c_get_category_id INTO l_category_id;
               CLOSE c_get_category_id;

               /* Change the document category to the REJECTED category to segregate it out from
                  the approved documents. There is no ther way to determine that is has been rejected  */
               UPDATE fnd_documents
                  SET category_id = l_category_id
                WHERE document_id = l_document_id;

            END IF; /* If this is an MSDS document */

            p_resultout := G_NO;

         END IF;  /* If the document has been approved */


   EXCEPTION
      WHEN OTHERS THEN
          p_resultout := G_NO;

   END attach_to_entity;

END GR_ATTACH_DOCUMENTS_PKG;

/
