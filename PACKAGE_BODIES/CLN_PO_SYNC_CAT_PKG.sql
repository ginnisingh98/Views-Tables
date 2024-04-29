--------------------------------------------------------
--  DDL for Package Body CLN_PO_SYNC_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_PO_SYNC_CAT_PKG" AS
/* $Header: CLNPOCSB.pls 120.2 2006/04/03 08:28:29 smuthuav noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
-- Package
--   CLN_PO_SYNC_CAT_PKG
--
-- Purpose
--    Package body for the package specification: CLN_PO_CATALOG_SYNC.
--    This package functions facilitate in Catalog sync operation
--    An inbound catalog will result in a Blanket purchase order
--    creation or updation
--
-- History
--    Jun-03-2003       Viswanthan Umapathy         Created



   -- Name
   --    PROCESS_HEADER
   -- Purpose
   --    Creates a row in  PO_HEADERS_INTERFACE and updates the collaboration
   --    based on Catalog header details
   -- Arguments
   --   Catalog header details
   -- Notes
   --    No specific notes

     PROCEDURE PROCESS_HEADER (
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_po_hdr_id            OUT NOCOPY NUMBER,
         x_operation            OUT NOCOPY VARCHAR2,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_sync_id          IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_batch_id             IN  NUMBER,
         p_doc_type             IN  VARCHAR2,
         p_tp_id                IN  NUMBER,
         p_tp_site_id           IN  NUMBER,
         p_ctg_name             IN  VARCHAR2,
         p_eff_date             IN  DATE,
         p_exp_date             IN  DATE,
         p_currency             IN  NUMBER
      )
      IS
         l_ctg_sync_id      VARCHAR2(10);
         l_ctg_name         VARCHAR2(255);
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_msg_text         VARCHAR2(1000);
         l_org_id           NUMBER;
      BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         --  Initialize API return status to success
         x_return_status := 'S';
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_HEADER', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_int_cont_num:' || p_int_cont_num, 1);
                 cln_debug_pub.Add('p_ctg_sync_id:' || p_ctg_sync_id, 1);
                 cln_debug_pub.Add('p_itf_hdr_id:' || p_itf_hdr_id, 1);
                 cln_debug_pub.Add('p_batch_id:' || p_batch_id, 1);
                 cln_debug_pub.Add('p_doc_type:' || p_doc_type, 1);
                 cln_debug_pub.Add('p_tp_id:' || p_tp_id, 1);
                 cln_debug_pub.Add('p_tp_site_id:' || p_tp_site_id, 1);
                 cln_debug_pub.Add('p_ctg_name:' || p_ctg_name, 1);
                 cln_debug_pub.Add('p_eff_date:' || p_eff_date, 1);
                 cln_debug_pub.Add('p_exp_date:' || p_exp_date, 1);
                 cln_debug_pub.Add('p_currency:' || p_currency, 1);
         END IF;

         -- No need to create collaboration since XMLGateway Event handler will create
         -- a collaboration if XMLGateway receives an inbound CLN document otherthan CBOD

         -- Need to reomve the sysdate
         -- l_ctg_name := substr(p_ctg_name, 1, instr(p_ctg_name, ':', 1, 3)-1);

         l_ctg_name := p_ctg_name;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_ctg_name:' || l_ctg_name, 1);
         END IF;


         -- If the sysnc id is anything other than A,R,U error out
         l_ctg_sync_id := upper(p_ctg_sync_id);
         IF (l_ctg_sync_id IS NULL) OR (   l_ctg_sync_id <> 'A'
                                       AND l_ctg_sync_id <> 'U'
                                       AND l_ctg_sync_id <> 'R') THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Invalid Transaction Code - ' || l_ctg_sync_id, 1);
            END IF;

            -- Invalid Transaction Code - "CODE"
            FND_MESSAGE.SET_NAME('CLN','CLN_INVALID_TXN_CODE');
            FND_MESSAGE.SET_TOKEN('CODE', l_ctg_sync_id);
            x_msg_data := FND_MESSAGE.GET;
            RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => p_app_ref_id,
                 p_doc_no            => NULL,
                 p_part_doc_no       => l_ctg_name,
                 p_msg_text          => x_msg_data,
                 p_status_code       => 1,
                 p_int_ctl_num       => p_int_cont_num);
            IF l_return_status <> 'S' THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add(x_msg_data, 1);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_HEADER', 2);
            END IF;

            RETURN;
         END IF;

         -- BUG 3155860 - MULTIPLE BPO FOR THE SAME VENDOR DOC NUMBER CAN ALSO BE TAKEN CARE
         -- Canceled and Closed BPO are not taken into consideration.
         BEGIN
            x_operation := 'UPDATE';
            SELECT po_header_id
            INTO   x_po_hdr_id
            FROM   PO_HEADERS_ALL
            WHERE  VENDOR_ORDER_NUM = l_ctg_name
	           AND vendor_id = p_tp_id  -- Bug #5006663
                   AND NVL(CANCEL_FLAG, 'N') = 'N'
                   AND NVL(CLOSED_CODE, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED');
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  x_operation := 'INSERT';
               WHEN OTHERS THEN
                  IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add('Exception while trying to obtain the BPO number',5);
                  END IF;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  l_error_code    := SQLCODE;
                  l_error_msg     := SQLERRM;
                  x_msg_data  := l_error_code||' : '||l_error_msg;
                  IF (l_Debug_Level <= 5) THEN
                          cln_debug_pub.Add(x_msg_data, 5);
                  END IF;

                  x_msg_data :=  'While trying to obtain BPO number'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
                  CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
                  IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add('EXITING PROCESS_HEADER', 2);
                  END IF;
                  RETURN;
         END;

         -- Update the collaboration
         FND_MESSAGE.SET_NAME('CLN','CLN_DOCUMENT_PROCESSED');
         -- Document Processed
         l_msg_text := FND_MESSAGE.GET;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_msg_text:' || l_msg_text, 1);
         END IF;


         RAISE_UPDATE_COLLABORATION(
             x_return_status     => l_return_status,
             x_msg_data          => l_return_msg,
             p_ref_id            => p_app_ref_id,
             p_doc_no            => NULL,
             p_part_doc_no       => l_ctg_name,
             p_msg_text          => l_msg_text,
             p_status_code       => 0,
             p_int_ctl_num       => p_int_cont_num);
         IF l_return_status <> 'S' THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('RAISE_UPDATE_COLLABORATION CALL FAILED',1);
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         SELECT org_id
         INTO   l_org_id
         FROM   po_vendor_sites_all
         WHERE  vendor_site_id = p_tp_site_id;


         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('x_operation:' || x_operation, 1);
         END IF;

         SAVEPOINT PO_UPDATE_TXN;

         -- Insert in to PO_HEADERS_INTERFACE
         IF x_operation = 'INSERT' THEN
            -- Create a new BPO
            -- While creating a new po, vendor document num
            -- needs to be filled with catalog name
            -- Need to insert a row with action as ORIGINAL

            /* Bug : 3630042. In case of multiple messages due to
            grouping factor, we never know the action is create.
            We will populate it in the workflow using the procedure
            SET_ACTION_CREATE_OR_UPDATE
            */
            INSERT INTO po_headers_interface(interface_header_id,
                                             batch_id,
                                             --action,
                                             document_type_code,
                                             vendor_id,
                                             vendor_site_id,
                                             effective_date,
                                             expiration_date,
                                             vendor_doc_num,
					     org_id,
					     amount_agreed
					     )
                                      values(p_itf_hdr_id,
                                             p_itf_hdr_id,
                                             --'ORIGINAL',
                                             'BLANKET',
                                             p_tp_id,
                                             p_tp_site_id,
                                             p_eff_date,
                                             p_exp_date,
                                             l_ctg_name,
					     l_org_id,
					     0);
         ELSE
            -- Update an existing BPO
            -- Need to insert a row in this case also
            -- Action UPDATE
            INSERT INTO po_headers_interface(interface_header_id,
                                             batch_id,
                                             action,
                                             document_type_code,
                                             vendor_id,
                                             vendor_site_id,
                                             effective_date,
                                             expiration_date,
                                             vendor_doc_num,
					     org_id,
					     amount_agreed
					     )
                                      values(p_itf_hdr_id,
                                             p_itf_hdr_id,
                                             'UPDATE',
                                             'BLANKET',
                                             p_tp_id,
                                             p_tp_site_id,
                                             p_eff_date,
                                             p_exp_date,
                                             l_ctg_name,
					     l_org_id,
					     0);
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_HEADER', 2);
         END IF;

         EXCEPTION
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK TO PO_UPDATE_TXN;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               -- Assaign global error info and set return values
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_data := l_return_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process header details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('EXITING PROCESS_HEADER', 2);
               END IF;

            WHEN OTHERS THEN
               ROLLBACK TO PO_UPDATE_TXN;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               x_msg_data  := l_error_code||' : '||l_error_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process header details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('EXITING PROCESS_HEADER', 2);
               END IF;

      END PROCESS_HEADER;



  -- Name
   --    PROCESS_LINE
   -- Purpose
   --    Creates or updates a BPO Line
   --    By creating a row in  PO_LINES_INTERFACE
   --    Updates the collaboration,
   --    Based on Catalog line details
   -- Arguments
   --    Catalog line header details
   -- Notes
   --   No Specific Notes

      PROCEDURE PROCESS_LINE(
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_line_num             OUT NOCOPY NUMBER,
         p_operation            IN  VARCHAR2,
         p_hdr_id               IN  NUMBER,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_name             IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_itf_lin_id           IN  NUMBER,
         p_vdr_part_num         IN  VARCHAR2,
         p_item_desc            IN  VARCHAR2,
         p_item                 IN  VARCHAR2,
         p_item_rev             IN  VARCHAR2,
         p_category             IN  VARCHAR2,
         p_uom                  IN  VARCHAR2,
         p_item_min_ord_quan    IN  VARCHAR2,
         p_price                IN  NUMBER,
         p_price_uom            IN  VARCHAR2,
         p_price_currency       IN  VARCHAR2,
         p_attribute1           IN  VARCHAR2,
         p_attribute2           IN  VARCHAR2,
         p_attribute3           IN  VARCHAR2,
         p_attribute4           IN  VARCHAR2,
         p_attribute5           IN  VARCHAR2,
         p_attribute6           IN  VARCHAR2,
         p_attribute7           IN  VARCHAR2,
         p_attribute8           IN  VARCHAR2,
         p_attribute9           IN  VARCHAR2,
         p_attribute10          IN  VARCHAR2,
         p_attribute11          IN  VARCHAR2,
         p_attribute12          IN  VARCHAR2,
         p_attribute13          IN  VARCHAR2,
         p_attribute14          IN  VARCHAR2,
         p_attribute15          IN  VARCHAR2)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_ctg_name         VARCHAR2(50);
         l_count            NUMBER;
         l_line_num         NUMBER;
         l_uom_code         VARCHAR2(500);
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         --  Initialize API return status to success
         x_return_status := 'S';
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_LINE', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_operation:' || p_operation, 1);
                 cln_debug_pub.Add('p_hdr_id:' || p_hdr_id, 1);
                 cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_int_cont_num:' || p_int_cont_num, 1);
                 cln_debug_pub.Add('p_ctg_name:' || p_ctg_name, 1);
                 cln_debug_pub.Add('p_itf_hdr_id:' || p_itf_hdr_id, 1);
                 cln_debug_pub.Add('p_itf_lin_id:' || p_itf_lin_id, 1);
                 cln_debug_pub.Add('p_vdr_part_num:' || p_vdr_part_num, 1);
                 cln_debug_pub.Add('p_item_desc:' || p_item_desc, 1);
                 cln_debug_pub.Add('p_item:' || p_item, 1);
                 cln_debug_pub.Add('p_item_rev:' || p_item_rev, 1);
                 cln_debug_pub.Add('p_category:' || p_category, 1);
                 cln_debug_pub.Add('p_uom:' || p_uom, 1);
                 cln_debug_pub.Add('p_item_min_ord_quan:' || p_item_min_ord_quan, 1);
                 cln_debug_pub.Add('p_price:' || p_price, 1);
                 cln_debug_pub.Add('p_price_uom:' || p_price_uom, 1);
                 cln_debug_pub.Add('p_price_currency:' || p_price_currency, 1);
         END IF;


         -- Need to reomve the sysdate
         -- l_ctg_name := substr(p_ctg_name, 1, instr(p_ctg_name, ':', 1, 3)-1);
         l_ctg_name := p_ctg_name;

         /*
         -- Whatever that comes in XML is itself is the uom code ?
         SELECT UOM_CODE
         INTO   l_uom_code
         FROM   MTL_UNITS_OF_MEASURE_VL
         WHERE  UNIT_OF_MEASURE = p_uom;
         */

         l_uom_code := p_uom;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_uom_code:' || l_uom_code, 1);
         END IF;

         -- Need to find if it a duplicate item
         BEGIN
            SELECT line_num
            INTO   l_line_num
            FROM   PO_LINES_INTERFACE
            WHERE  interface_header_id = p_itf_hdr_id
                   AND nvl(ITEM, '-1') = nvl(p_item, '-1')
                   AND nvl(UOM_CODE, '-1') = nvl(l_uom_code, '-1')
                   AND ROWNUM < 2; -- All the rows returned by this query have either the same line_num or no rows
         EXCEPTION  WHEN NO_DATA_FOUND THEN
            -- No rows found. So go ahead and do the insertion
            l_line_num := null;
         END;

         IF l_line_num IS NOT NULL THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Duplicate item:' || p_item, 1);
                    cln_debug_pub.Add('UOM - ' || l_uom_code, 1);
                    cln_debug_pub.Add('Line number found : ' || l_line_num, 1);
            END IF;
            x_line_num := l_line_num;

            /****** Need not throw error as per bug 3430538
            -- Duplicate Item in the Catalog: ITEM UOM - CODE
            FND_MESSAGE.SET_NAME('CLN','CLN_DUPLICATE_ITEM');
            FND_MESSAGE.SET_TOKEN('ITEM', p_item);
            FND_MESSAGE.SET_TOKEN('CODE', l_uom_code);
            x_msg_data := FND_MESSAGE.GET;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('x_msg_data:' || x_msg_data, 1);
            END IF;

            RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => p_app_ref_id,
                 p_doc_no            => NULL,
                 p_part_doc_no       => NULL,
                 p_msg_text          => x_msg_data,
                 p_status_code       => 1,
                 p_int_ctl_num       => p_int_cont_num);
            IF l_return_status <> 'S' THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := 'DIE';
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add(x_msg_data, 1);
            END IF;
            ********* End of commenting*/

            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER, WITHOUT CREATION LINE', 2);
            END IF;

            RETURN;

         END IF;

         SELECT cln_generic_s.nextval
         INTO   l_line_num
         FROM DUAL;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_line_num:' || l_line_num, 1);
         END IF;

         x_line_num := l_line_num;

         INSERT INTO po_lines_interface(interface_header_id,
                                           interface_line_id,
                                           item,
                                           ITEM_REVISION,
                                           CATEGORY,
                                           ITEM_DESCRIPTION,
                                           MIN_ORDER_QUANTITY,
                                           UOM_CODE,
                                           line_num,
                                           VENDOR_PRODUCT_NUM,
                                           PRICE_BREAK_LOOKUP_CODE,
                                           LINE_ATTRIBUTE1,
                                           LINE_ATTRIBUTE2,
                                           LINE_ATTRIBUTE3,
                                           LINE_ATTRIBUTE4,
                                           LINE_ATTRIBUTE5,
                                           LINE_ATTRIBUTE6,
                                           LINE_ATTRIBUTE7,
                                           LINE_ATTRIBUTE8,
                                           LINE_ATTRIBUTE9,
                                           LINE_ATTRIBUTE10,
                                           LINE_ATTRIBUTE11,
                                           LINE_ATTRIBUTE12,
                                           LINE_ATTRIBUTE13,
                                           LINE_ATTRIBUTE14,
                                           LINE_ATTRIBUTE15)
                                    values(p_itf_hdr_id,
                                           p_itf_lin_id,
                                           p_item,
                                           p_item_rev,
                                           p_category,
                                           p_item_desc,
                                           p_item_min_ord_quan,
                                           l_uom_code,
                                           l_line_num,
                                           p_vdr_part_num,
                                           'NON CUMULATIVE',
                                           p_attribute1,
                                           p_attribute2,
                                           p_attribute3,
                                           p_attribute4,
                                           p_attribute5,
                                           p_attribute6,
                                           p_attribute7,
                                           p_attribute8,
                                           p_attribute9,
                                           p_attribute10,
                                           p_attribute11,
                                           p_attribute12,
                                           p_attribute13,
                                           p_attribute14,
                                           p_attribute15);

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Inserted a row into for the line', 1);
         END IF;


         /*
         IF p_operation = 'INSERT' THEN
            -- Create a new BPO Line
            SELECT cln_generic_s.nextval
            INTO   l_line_num
            FROM DUAL;
            x_line_num := l_line_num;
            INSERT INTO po_lines_interface(interface_header_id,
                                           interface_line_id,
                                           item,
                                           ITEM_REVISION,
                                           CATEGORY,
                                           ITEM_DESCRIPTION,
                                           MIN_ORDER_QUANTITY,
                                           -- UOM_CODE, How to get uom code from uom ?
                                           line_num,
                                           VENDOR_PRODUCT_NUM,
                                           LINE_ATTRIBUTE1,
                                           LINE_ATTRIBUTE2,
                                           LINE_ATTRIBUTE3,
                                           LINE_ATTRIBUTE4,
                                           LINE_ATTRIBUTE5,
                                           LINE_ATTRIBUTE6,
                                           LINE_ATTRIBUTE7,
                                           LINE_ATTRIBUTE8,
                                           LINE_ATTRIBUTE9,
                                           LINE_ATTRIBUTE10,
                                           LINE_ATTRIBUTE11,
                                           LINE_ATTRIBUTE12,
                                           LINE_ATTRIBUTE13,
                                           LINE_ATTRIBUTE14,
                                           LINE_ATTRIBUTE15)
                                    values(p_itf_hdr_id,
                                           p_itf_lin_id,
                                           p_item,
                                           p_item_rev,
                                           p_category,
                                           p_item_desc,
                                           p_item_min_ord_quan,
                                           l_line_num,
                                           p_vdr_part_num,
                                           p_attribute1,
                                           p_attribute2,
                                           p_attribute3,
                                           p_attribute4,
                                           p_attribute5,
                                           p_attribute6,
                                           p_attribute7,
                                           p_attribute8,
                                           p_attribute9,
                                           p_attribute10,
                                           p_attribute11,
                                           p_attribute12,
                                           p_attribute13,
                                           p_attribute14,
                                           p_attribute15);
         ELSE
            -- BPO Line already exist
            -- Need to return the original line number
            -- Should insert the line details with the existing line num ?
            BEGIN
               SELECT line_num
               INTO   x_line_num
               FROM   PO_LINES_ALL POL ,
                      MTL_SYSTEM_ITEMS_KFV MIS,
                      FINANCIALS_SYSTEM_PARAMS_ALL FSP
                      --       MTL_CATEGORIES_KFV MCT
               WHERE  POL.ITEM_ID = MIS.INVENTORY_ITEM_ID (+)
                  AND NVL(MIS.ORGANIZATION_ID, FSP.INVENTORY_ORGANIZATION_ID)
                                     = FSP.INVENTORY_ORGANIZATION_ID
                  AND FSP.ORG_ID = POL.ORG_ID
                  AND POL.PO_HEADER_ID = p_hdr_id
                  --  (SELECT PO_HEADER_ID FROM PO_HEADERS_ALL WHERE VENDOR_ORDER_NUM = l_ctg_name)
                  AND upper(MIS.CONCATENATED_SEGMENTS) = upper(p_item)
                  AND upper(POL.UNIT_MEAS_LOOKUP_CODE) = upper(p_uom);
                  -- NO need to compare category
                  -- AND MCT.CATEGORY_ID = POL.CATEGORY_ID
                  -- AND upper(MCT.CONCATENATED_SEGMENTS) = upper(p_category);

                  cln_debug_pub.Add('x_line_num:' || x_line_num, 1);
                  -- Insert the line if necessary ?

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- Line does not exist, create a new line
                     cln_debug_pub.Add('Line number does not exist, creating a new row', 1);
                     SELECT cln_generic_s.nextval
                     INTO   l_line_num
                     FROM DUAL;
                     x_line_num := l_line_num;
                     cln_debug_pub.Add('x_line_num:' || x_line_num, 1);
                     INSERT INTO po_lines_interface(interface_header_id,
                                           interface_line_id,
                                           item,
                                           line_num)
                                    values(p_itf_hdr_id,
                                           p_itf_lin_id,
                                           p_item,
                                           l_line_num);
            END;
         END IF;
         */

    -- In the message we can put insertion or updation
         RAISE_ADD_MESSAGE(
            x_return_status    => l_return_status,
            x_msg_data         => l_return_msg,
            p_ictrl_no         => p_int_cont_num,
            p_ref1             => p_item,
            p_ref2             => p_item_rev,
            p_ref3             => p_uom,
            p_ref4             => p_item_min_ord_quan,
            p_ref5             => p_vdr_part_num,
            p_dtl_msg          => NULL);
         IF l_return_status <> 'S' THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_LINE', 2);
         END IF;

         EXCEPTION
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK TO PO_UPDATE_TXN;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_data := l_return_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process line details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 2) THEN
                       cln_debug_pub.Add('EXITING PROCESS_LINE', 2);
               END IF;

            WHEN OTHERS THEN
               ROLLBACK TO PO_UPDATE_TXN;
               -- More descriptive line details ?
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               x_msg_data  := l_error_code||' : '||l_error_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process line details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('EXITING PROCESS_LINE', 2);
               END IF;

      END PROCESS_LINE;



   -- Name
   --    PROCESS_PRICE_BREAKS
   -- Purpose
   --    Creates a PRICE BREAK row in  PO_LINES_INTERFACE
   --    based on Catalog line details
   -- Arguments
   --   Catalog line details and price break details
   -- Notes
   --   No Specific Notes

   -- BUG 3138217 - CURRENCY VALIDATION TO BE DONE ON THE BUY SIDE
   -- Added parameter x_bpo_cur_updated      IN OUT NOCOPY VARCHAR2

      PROCEDURE PROCESS_PRICE_BREAKS(
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_data             OUT NOCOPY VARCHAR2,
         x_bpo_cur_updated      IN OUT NOCOPY VARCHAR2,
         p_app_ref_id           IN  VARCHAR2,
         p_int_cont_num         IN  VARCHAR2,
         p_ctg_name             IN  VARCHAR2,
         p_itf_hdr_id           IN  NUMBER,
         p_itf_lin_id           IN  NUMBER,
         p_line_num             IN  NUMBER,
         p_item                 IN  VARCHAR2,
         p_item_rev             IN  VARCHAR2,
         p_eff_date             IN  DATE,
         p_exp_date             IN  DATE,
         p_quantity             IN  NUMBER,
         p_price                IN  NUMBER,
         p_price_uom            IN  VARCHAR2,
         p_price_currency       IN  VARCHAR2)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_ctg_name         VARCHAR2(50);
         l_line_ship_num    NUMBER;
         l_line_price       NUMBER;
         l_count            NUMBER;
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

         --  Initialize API return status to success
         x_return_status := 'S';
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_PRICE_BREAKS', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_int_cont_num:' || p_int_cont_num, 1);
                 cln_debug_pub.Add('p_ctg_name:' || p_ctg_name, 1);
                 cln_debug_pub.Add('p_itf_hdr_id:' || p_itf_hdr_id, 1);
                 cln_debug_pub.Add('p_itf_lin_id:' || p_itf_lin_id, 1);
                 cln_debug_pub.Add('p_line_num:' || p_line_num, 1);
                 cln_debug_pub.Add('p_item:' || p_item, 1);
                 cln_debug_pub.Add('p_item_rev:' || p_item_rev, 1);
                 cln_debug_pub.Add('p_eff_date:' || p_eff_date, 1);
                 cln_debug_pub.Add('p_exp_date:' || p_exp_date, 1);
                 cln_debug_pub.Add('p_quantity:' || p_quantity, 1);
                 cln_debug_pub.Add('p_price:' || p_price, 1);
                 cln_debug_pub.Add('p_price_uom:' || p_price_uom, 1);
                 cln_debug_pub.Add('p_price_currency:' || p_price_currency, 1);
                 cln_debug_pub.Add('x_bpo_cur_updated:' || x_bpo_cur_updated, 1);
         END IF;


         -- Need to reomve the sysdate
         -- l_ctg_name := substr(p_ctg_name, 1, instr(p_ctg_name, ':', 1, 3)-1);
         l_ctg_name := p_ctg_name;


         -- BUG 3138217 - CURRENCY VALIDATION TO BE DONE ON THE BUY SIDE
         -- Need to update PO interface header table with currency code.

         IF x_bpo_cur_updated = 'NO' AND p_price_currency IS NOT NULL THEN

            UPDATE po_headers_interface
            SET    currency_code = p_price_currency
            WHERE  interface_header_id = p_itf_hdr_id;

            x_bpo_cur_updated := 'YES';

         END IF;


         -- As per the map timephase price break will come first
         -- and then the volumephase price break

         -- Is this the first timephase price break
         SELECT count(*)
         INTO   l_count
         FROM   po_lines_interface
         WHERE  interface_header_id = p_itf_hdr_id
            AND interface_line_id = interface_line_id
            AND line_num = p_line_num;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_count:' || l_count, 1);
         END IF;


         IF l_count = 1 THEN -- First timephase price break

            -- Get the unit price at line level
            SELECT unit_price
            INTO   l_line_price
            FROM   po_lines_interface
            WHERE  interface_header_id = p_itf_hdr_id
            AND interface_line_id = interface_line_id
            AND line_num = p_line_num;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_line_price:' || l_line_price, 1);
            END IF;


            IF l_line_price IS NULL OR l_line_price = 0 THEN
               -- Update the line price because price at line level is not available
               -- it comes as the first timephase price break
               UPDATE po_lines_interface
               SET    unit_price = p_price
               WHERE  interface_header_id = p_itf_hdr_id
                  AND interface_line_id = interface_line_id
                  AND line_num = p_line_num;
            END IF;
         END IF;

         -- Create a new BPO Line Price Break
         -- No need to check,if this exists
         SELECT cln_generic_s.nextval
         INTO   l_line_ship_num
         FROM DUAL;

         INSERT INTO po_lines_interface(interface_header_id,
                                           interface_line_id,
                                           item,
                                           ITEM_REVISION,
                                           line_num,
                                           shipment_num,
                                           unit_price,
                                           effective_date,
                                           expiration_date,
                                           quantity,
                                           PRICE_BREAK_LOOKUP_CODE)
                                    values(p_itf_hdr_id,
                                           p_itf_lin_id,
                                           p_item,
                                           p_item_rev,
                                           p_line_num,
                                           l_line_ship_num,
                                           p_price,
                                           p_eff_date,
                                           p_exp_date,
                                           p_quantity,
                                           'NON CUMULATIVE');

         RAISE_ADD_MESSAGE(
            x_return_status    => l_return_status,
            x_msg_data         => l_return_msg,
            p_ictrl_no         => p_int_cont_num,
            p_ref1             => p_itf_hdr_id,
            p_ref2             => p_itf_lin_id,
            p_ref3             => p_line_num,
            p_ref4             => p_item,
            p_ref5             => p_item_rev,
            p_dtl_msg          => NULL);
         IF l_return_status <> 'S' THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;


         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_PRICE_BREAKS', 2);
         END IF;

         EXCEPTION
            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               ROLLBACK TO PO_UPDATE_TXN;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               x_msg_data := l_return_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process line price break details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('EXITING PROCESS_PRICE_BREAKS', 2);
               END IF;

            WHEN OTHERS THEN
               ROLLBACK TO PO_UPDATE_TXN;
               -- More descriptive line details ?
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',5);
               END IF;

               x_return_status := FND_API.G_RET_STS_ERROR;
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               x_msg_data  := l_error_code||' : '||l_error_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 5);
               END IF;

               x_msg_data :=  'While trying to process line price break details'
                                       || ' for the inbound sync catalog#'
                                       || p_ctg_name
                                       || ', the following error is encountered:'
                                       || x_msg_data;
               CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(x_msg_data);
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add('EXITING PROCESS_PRICE_BREAKS', 2);
               END IF;

      END PROCESS_PRICE_BREAKS;



   -- Name
   --   CALL_TAKE_ACTIONS
   -- Purpose
   --   Invokes Notification Processor TAKE_ACTIONS according to the parameter.
   -- Arguments
   --   Description - Error message if errored out else 'SUCCESS'
   --   Sales Order Status
   --   Order Line Closed - YES/NO
   -- Notes
   --   No specific notes.

      PROCEDURE CALL_TAKE_ACTIONS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_doc_status         VARCHAR2(100);
         l_description        VARCHAR2(1000);
         l_trp_id             VARCHAR2(100);
         l_app_ref_id         VARCHAR2(255);
         l_return_status      VARCHAR2(1000);
         l_return_msg         VARCHAR2(2000);
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_tp_id              NUMBER;
         l_ret_status         VARCHAR2(5);
         l_ctg_sync_id        VARCHAR2(5);
         l_int_hdr_id         NUMBER;
         l_count              NUMBER;
         l_int_ctl_num        NUMBER;
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

         x_resultout:='Yes';

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING CALL_TAKE_ACTIONS API', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Parameters:', 1);
         END IF;


         -- Should be S for sucess
         l_ret_status := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_ret_status:' || l_ret_status, 1);
         END IF;

         l_int_hdr_id := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER9', TRUE));
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_int_hdr_id:' || l_int_hdr_id, 1);
         END IF;

         l_int_ctl_num := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER1', TRUE));
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_int_ctl_num:' || l_int_ctl_num, 1);
         END IF;

         IF (l_ret_status = 'S') THEN
            l_doc_status :=  'SUCCESS';
            -- Successfully processed product catalog
            FND_MESSAGE.SET_NAME('CLN','CLN_PO_CATALOG_SYNC_SUCCESS');
            l_description := FND_MESSAGE.GET;
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER12', l_doc_status);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', l_description);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER2', '00');
         ELSE
       l_doc_status :=  'ERROR';
       l_msg_data := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER7', TRUE);
       IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_msg_data:' || l_msg_data, 1);
            END IF;

       -- Error while processing product catalog
            FND_MESSAGE.SET_NAME('CLN','CLN_PO_CATALOG_SYNC_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR', l_msg_data);
            l_description := FND_MESSAGE.GET;
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER12', l_doc_status);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', l_description);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER2', '99');
    END IF;

         l_trp_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_tp_id:' || l_trp_id, 1);
            END IF;

         l_app_ref_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_app_ref_id:' || l_app_ref_id, 1);
            END IF;

         CLN_UTILS.GET_TRADING_PARTNER(l_trp_id, l_tp_id);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Trading Partner ID:' || l_tp_id, 1);
            END IF;

         l_ctg_sync_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER8', TRUE);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_ctg_sync_id:' || l_ctg_sync_id, 1);
            END IF;


         -- All situations and codes ?
         -- Error occured
         IF l_ret_status <> 'S' THEN
            -- Invalid Transaction Code
            IF (l_ctg_sync_id IS NULL) OR (l_ctg_sync_id <> 'A'
                                       AND l_ctg_sync_id <> 'U'
                                       AND l_ctg_sync_id <> 'R') THEN
               FND_MESSAGE.SET_NAME('CLN','CLN_INVALID_TXN_CODE');
               FND_MESSAGE.SET_TOKEN('CODE', l_ctg_sync_id);
               l_msg_data := FND_MESSAGE.GET;
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Invalid Trnsaction Code',1);
               END IF;

               CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                  x_ret_code            => l_return_status,
                  x_ret_desc            => l_return_msg,
                  p_notification_code   => 'PC_IN04',
                  p_notification_desc   => l_msg_data,
                  p_status              => 'ERROR',
                  p_tp_id               => to_char(l_tp_id),
                  p_reference           => l_app_ref_id,
                  p_coll_point          => 'APPS',
                  p_int_con_no          => NULL);
               IF l_return_status <> 'S' THEN
                  IF (l_Debug_Level <= 1) THEN
                          cln_debug_pub.Add('CALL_TAKE_ACTIONS CALL FAILED', 1);
                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               RETURN;
            END IF;


            -- Duplicate Item Error
            IF l_ret_status = 'DIE' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Duplicate Item Error',1);
               END IF;

               FND_MESSAGE.SET_NAME('CLN','CLN_DUPLICATE_ITEM');
               l_msg_data := FND_MESSAGE.GET;
               CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                  x_ret_code            => l_return_status,
                  x_ret_desc            => l_return_msg,
                  p_notification_code   => 'PC_IN03',
                  p_notification_desc   => l_msg_data,
                  p_status              => 'SUCCESS',
                  p_tp_id               => to_char(l_tp_id),
                  p_reference           => l_app_ref_id,
                  p_coll_point          => 'APPS',
                  p_int_con_no          => NULL);
               IF l_return_status <> 'S' THEN
                  IF (l_Debug_Level <= 1) THEN
                          cln_debug_pub.Add('CALL_TAKE_ACTIONS CALL FAILED', 1);
                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               RETURN;
            END IF;


            -- Error
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Global Error' || l_description,1);
            END IF;

            CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
               x_ret_code            => l_return_status,
               x_ret_desc            => l_return_msg,
               p_notification_code   => 'PC_IN02',
               p_notification_desc   => l_description,
               p_status              => 'ERROR',
               p_tp_id               => to_char(l_tp_id),
               p_reference           => l_app_ref_id,
               p_coll_point          => 'APPS',
               p_int_con_no          => NULL);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('CALL_TAKE_ACTIONS CALL FAILED', 1);
               END IF;

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            RETURN;
         END IF;

         -- Success
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         l_msg_data := FND_MESSAGE.GET;
         CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
            x_ret_code            => l_return_status,
            x_ret_desc            => l_return_msg,
            p_notification_code   => 'PC_IN01',
            p_notification_desc   =>  l_msg_data,
            p_status              => 'SUCCESS',
            p_tp_id               => to_char(l_tp_id),
            p_reference           => l_app_ref_id,
            p_coll_point          => 'APPS',
            p_int_con_no          => NULL);
         IF l_return_status <> 'S' THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('CALL_TAKE_ACTIONS CALL FAILED', 1);
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;

            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;

            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
            END IF;
    END CALL_TAKE_ACTIONS;


   -- Name
   --   SET_ITEM_ATTRIBUTES
   -- Purpose
   --   Sets the workflow item attributes requires
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE SET_ITEM_ATTRIBUTES(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_approval_status    VARCHAR2(255);
         l_create_src_rules   VARCHAR2(255);
         l_create_upd_items   VARCHAR2(255);
         l_doc_types          VARCHAR2(255);
         l_rel_gen_method     VARCHAR2(255);
         l_def_buyer          VARCHAR2(255);
         l_tp_header_id       NUMBER;
         l_org_id             NUMBER;
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

         x_resultout:='Yes';

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING SET_ITEM_ATTRIBUTES API', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Parameters:', 1);
         END IF;


         -- Get Profile Option values
         l_approval_status  := FND_PROFILE.VALUE('CLN_2A1_PO_APPROVAL_STATUS');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_approval_status:' || l_approval_status, 1);
            END IF;

         l_create_src_rules := FND_PROFILE.VALUE('CLN_2A1_PO_CREATE_SOURCING_RULES');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_create_src_rules:' || l_create_src_rules, 1);
            END IF;

         l_create_upd_items := FND_PROFILE.VALUE('CLN_2A1_PO_CREATE_UPDATE_ITEMS');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_create_upd_items:' || l_create_upd_items, 1);
            END IF;

         l_doc_types        := FND_PROFILE.VALUE('CLN_2A1_PO_PDOI_DOCUMENT_TYPES');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_doc_types:' || l_doc_types, 1);
            END IF;

         l_rel_gen_method   := FND_PROFILE.VALUE('CLN_2A1_PO_PDOI_REL_GEN_METHOD');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_rel_gen_method:' || l_rel_gen_method, 1);
            END IF;

         l_def_buyer        := FND_PROFILE.VALUE('CLN_2A1_PO_PDOI_VALID_AGENTS');
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_def_buyer:' || l_def_buyer, 1);
            END IF;

         l_tp_header_id := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_tp_header_id:' || l_tp_header_id, 1);
         END IF;

         -- The following statement should not throw any exception
         SELECT org_id
         INTO   l_org_id
         FROM   ecx_tp_headers eth, po_vendor_sites_all povs
         WHERE  eth.tp_header_id = l_tp_header_id
           and  povs.vendor_site_id = eth.party_site_id;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_org_id:' || l_org_id, 1);
         END IF;

         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG1', l_def_buyer);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG3', l_create_upd_items);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG4', l_create_src_rules);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG5', l_approval_status);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG6', l_rel_gen_method);
         wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ORG_ID', l_org_id);
         -- Global Agreement ?
         -- wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'ARG7', TRUE);

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING SET_ITEM_ATTRIBUTES API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;

            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;

            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING SET_ITEM_ATTRIBUTES API', 2);
            END IF;

      END SET_ITEM_ATTRIBUTES;


   -- Name
   --   SET_ACTION_INTERNAL
   -- Purpose
   --   Sets the ACTION column of po_heasers_interface to either CREATE or UPDATE
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE SET_ACTION_INTERNAL(
         x_resultout       IN OUT NOCOPY VARCHAR2,
         p_catalog_name    IN VARCHAR2,
         p_batch_id        IN NUMBER,
	 p_vendor_id       IN NUMBER)
     IS
         PRAGMA AUTONOMOUS_TRANSACTION;
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_po_header_id       NUMBER;
         l_interface_hdr_rec_count NUMBER;
     BEGIN

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING SET_ACTION_INTERNAL API', 2);
		 cln_debug_pub.Add('p_catalog_name:'||p_catalog_name, 2);
		 cln_debug_pub.Add('p_batch_id:'||p_batch_id, 2);
		 cln_debug_pub.Add('p_vendor_id:'||p_vendor_id, 2);

         END IF;
         -- To lock the rows
         UPDATE po_headers_interface
         SET    vendor_doc_num = p_catalog_name
         WHERE  vendor_doc_num = p_catalog_name
	        AND  vendor_id = p_vendor_id
                AND  ACTION is NULL;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Locked the pending rows of interface tables of the same catalog', 1);
         END IF;

         BEGIN
            SELECT po_header_id
            INTO   l_po_header_id
            FROM   po_headers_all
            WHERE  vendor_order_num = p_catalog_name
	           AND vendor_id = p_vendor_id;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_po_header_id := NULL;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('PO not found in po_headers_all', 1);
            END IF;
         END;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_po_header_id:' || l_po_header_id, 1);
         END IF;

         IF (l_po_header_id > 0 ) THEN
            --There is an existing PO, set the action to UPDATE and retrun from this procedure
            UPDATE po_headers_interface
            SET action = 'UPDATE'
            WHERE  batch_id = p_batch_id;
            x_resultout := 'Y';
            COMMIT;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING SET_ACTION_INTERNAL API', 2);
            END IF;
            RETURN;
         END IF;

         BEGIN
            l_interface_hdr_rec_count := 0;
            -- Check whether there is any row, which is in process, for the same catalog. If so, then Wait.
            SELECT count('x')
            INTO   l_interface_hdr_rec_count
            FROM   po_headers_interface
            WHERE  vendor_doc_num = p_catalog_name
	           AND vendor_id = p_vendor_id
                   AND ACTION = 'ORIGINAL'
                   AND nvl(process_code,'~') NOT IN ('ACCEPTED', 'REJECTED');
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_interface_hdr_rec_count := 0;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('No catalogs found', 1);
            END IF;
         END;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_interface_hdr_rec_count:' || l_interface_hdr_rec_count, 1);
         END IF;

         IF l_interface_hdr_rec_count > 0 THEN
            --There is already a row which is in process. So wait for some time
            x_resultout := 'N';
         ELSE
            BEGIN
               SELECT po_header_id
               INTO   l_po_header_id
               FROM   po_headers_all
               WHERE  vendor_order_num = p_catalog_name
	              AND vendor_id = p_vendor_id;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_po_header_id := NULL;
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('PO not found in po_headers_all', 1);
               END IF;
            END;

            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_po_header_id:' || l_po_header_id, 1);
            END IF;

            IF (l_po_header_id > 0 ) THEN
               --There is an existing PO, set the action to UPDATE and retrun from this procedure
               UPDATE po_headers_interface
               SET action = 'UPDATE'
               WHERE  batch_id = p_batch_id;
            ELSE
               UPDATE po_headers_interface
               SET action = 'ORIGINAL'
               WHERE  batch_id = p_batch_id;
            END IF;
            x_resultout := 'Y';
         END IF;

         COMMIT;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING SET_ACTION_INTERNAL API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;
            ROLLBACK;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING SET_ACTION_INTERNAL API', 2);
            END IF;
     END SET_ACTION_INTERNAL;


   -- Name
   --   SET_ACTION_CREATE_OR_UPDATE
   -- Purpose
   --   Sets the ACTION column of po_heasers_interface to either CREATE or UPDATE
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE SET_ACTION_CREATE_OR_UPDATE(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_batch_id           NUMBER;
         l_po_header_id       NUMBER;
	 l_vendor_id          NUMBER;
	 l_tp_hdr_id          NUMBER;
         l_catalog_name       VARCHAR2(255);
         l_action             VARCHAR2(255);
         l_operation          VARCHAR2(255);

      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');


         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING SET_ACTION_CREATE_OR_UPDATE API', 2);
         END IF;

         -- Get the batch ID, which is being imported
         l_operation := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER3', TRUE);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_operation:' || l_operation, 1);
         END IF;

         IF (l_operation = 'UPDATE') THEN
             --If the operation is already update, then need not do anything
             IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Operation is update. Nothing to do.', 1);
             END IF;
             IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING SET_ACTION_CREATE_OR_UPDATE API', 2);
             END IF;
             x_resultout:='Y';
             RETURN;
         END IF;

         -- Get the batch ID, which is being imported
         l_batch_id := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER9', TRUE));
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_batch_id:' || l_batch_id, 1);
         END IF;

         l_catalog_name :=wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', TRUE);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_catalog_name:' || l_catalog_name, 1);
	 END IF;

         l_tp_hdr_id :=to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_tp_hdr_id:' || l_tp_hdr_id, 1);
		 cln_debug_pub.Add('About to call CLN_UTILS.GET_TRADING_PARTNER', 1);
         END IF;

	 CLN_UTILS.GET_TRADING_PARTNER(l_tp_hdr_id, l_vendor_id);

	 IF (l_Debug_Level <= 1) THEN
	            cln_debug_pub.Add('Out of CLN_UTILS.GET_TRADING_PARTNER', 1);
                    cln_debug_pub.Add('Vendor ID:' || l_vendor_id, 1);
         END IF;

	 SET_ACTION_INTERNAL( x_resultout => x_resultout,
         	              p_catalog_name => l_catalog_name,
			      p_batch_id => l_batch_id,
			      p_vendor_id => l_vendor_id);

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Returned from SET_ACTION_INTERNAL', 1);
         END IF;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING SET_ACTION_CREATE_OR_UPDATE API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;

            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING SET_ACTION_CREATE_OR_UPDATE API', 2);
            END IF;

      END SET_ACTION_CREATE_OR_UPDATE;


   -- Name
   --   IS_PROCESSING_ERROR
   -- Purpose
   --   Checks if any error has occured and returns the same
   -- Arguments
   -- Notes
   --   No specific notes.

      PROCEDURE IS_PROCESSING_ERROR(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_ret_status         VARCHAR2(100);
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');

	 x_resultout := 'COMPLETE:F';

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING IS_PROCESSING_ERROR API', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Parameters:', 1);
         END IF;

         -- Should be S for sucess
         l_ret_status := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', TRUE);
	 IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_ret_status:' || l_ret_status, 1);
         END IF;

         IF l_ret_status <> 'S' THEN
               x_resultout := 'COMPLETE:T';
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('x_resultout:' || x_resultout, 1);
         END IF;


         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING IS_PROCESSING_ERROR API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            x_resultout := 'COMPLETE:T';
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING IS_PROCESSING_ERROR API', 2);
            END IF;

      END IS_PROCESSING_ERROR;


   -- Name
   --   LOG_PO_OI_ERRORS
   -- Purpose
   --   Quries PO Open Interface error table and captures the errors
   --   in collaboration addmessages
   -- Arguments
   --   Interface Header ID available as a item attribute
   -- Notes
   --   No specific notes.

      PROCEDURE LOG_PO_OI_ERRORS(
         p_itemtype        IN VARCHAR2,
         p_itemkey         IN VARCHAR2,
         p_actid           IN NUMBER,
         p_funcmode        IN VARCHAR2,
         x_resultout       IN OUT NOCOPY VARCHAR2)
     IS
         l_return_status      VARCHAR2(100);
         l_return_msg         VARCHAR2(2000);
         l_app_ref_id         VARCHAR2(255);
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_error_status       VARCHAR2(255);
         l_int_hdr_id         NUMBER;
         l_count              NUMBER;
         l_int_ctl_num        NUMBER;
	 l_vendor_id          NUMBER;
	 l_tp_hdr_id          NUMBER;
         l_catalog_name       VARCHAR2(255);
         l_bpo_number         VARCHAR2(255);
          -- Cursor to retrieve all the user defined actions
         CURSOR PO_OPI_ERRORS(p_int_hdr_id NUMBER) IS
         SELECT INTERFACE_LINE_ID, BATCH_ID,
                TABLE_NAME, COLUMN_NAME, ERROR_MESSAGE, ERROR_MESSAGE_NAME
         FROM   PO_INTERFACE_ERRORS
         WHERE  INTERFACE_HEADER_ID = p_int_hdr_id;
      BEGIN

         -- Sets the debug mode to be FILE
         --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');
         x_resultout:='Yes';

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING LOG_PO_OI_ERRORS API', 2);
         END IF;

         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Parameters:', 1);
         END IF;


    l_int_hdr_id := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER9', TRUE));
    IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_int_hdr_id:' || l_int_hdr_id, 1);
         END IF;


         l_app_ref_id := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER4', TRUE);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_app_ref_id:' || l_app_ref_id, 1);
         END IF;


    l_int_ctl_num := to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER1', TRUE));
    IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_int_ctl_num:' || l_int_ctl_num, 1);
         END IF;

	 -- Does PO Open Interface errored out
    select count(*)
    into   l_count
    from   po_interface_errors
    where  interface_header_id = l_int_hdr_id;

    -- If errored out, open a cursor ? and get all the error rows in po_interface_errors
    -- and add them to collaboration message
    IF l_count = 0 THEN

            --Bug : 3732150
            --Get BPO Number from po headers all
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Trying to get BPO Number from PO Headers All', 1);
            END IF;

            l_catalog_name := wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER5', TRUE);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_catalog_name:' || l_catalog_name, 1);
            END IF;

	    l_tp_hdr_id :=to_number(wf_engine.GetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER10', TRUE));
	    IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_tp_hdr_id:' || l_tp_hdr_id, 1);
		 cln_debug_pub.Add('About to call CLN_UTILS.GET_TRADING_PARTNER', 1);
            END IF;

	    CLN_UTILS.GET_TRADING_PARTNER(l_tp_hdr_id, l_vendor_id);

	    IF (l_Debug_Level <= 1) THEN
	            cln_debug_pub.Add('Out of CLN_UTILS.GET_TRADING_PARTNER', 1);
                    cln_debug_pub.Add('Vendor ID:' || l_vendor_id, 1);
            END IF;

            -- Query for BPO number based on Catalog name
            -- BUG 3155860 - MULTIPLE BPO FOR THE SAME VENDOR DOC NUMBER CAN ALSO BE TAKEN CARE
            -- Canceled and Closed BPO are not taken into consideration
            BEGIN
               SELECT segment1
               INTO   l_bpo_number
               FROM   PO_HEADERS_ALL
               WHERE  VENDOR_ORDER_NUM = l_catalog_name
	              AND vendor_id = l_vendor_id  -- Bug #5006663
                      AND NVL(CANCEL_FLAG, 'N') = 'N'
                      AND NVL(CLOSED_CODE, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED');
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_bpo_number := NULL;
                  WHEN OTHERS THEN
                     l_bpo_number := NULL;
                     IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add('Exception while trying to obtain the BPO number',5);
                     END IF;
                     l_error_code    := SQLCODE;
                     l_error_msg     := SQLERRM;
                     l_msg_data  := l_error_code||' : '||l_error_msg;
                     IF (l_Debug_Level <= 5) THEN
                             cln_debug_pub.Add(l_msg_data, 5);
                     END IF;

                     l_msg_data :=  'While trying to obtain BPO number'
                                          || ' for the inbound sync catalog#'
                                          || l_catalog_name
                                          || ', the following error is encountered:'
                                          || l_msg_data;
                     IF (l_Debug_Level <= 5) THEN
                             cln_debug_pub.Add(l_msg_data, 5);
                     END IF;
            END;

            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_bpo_number:' || l_bpo_number, 1);
            END IF;

            FND_MESSAGE.SET_NAME('CLN','CLN_OPEN_IF_SUCCESS');-- Imported product catalog
            l_msg_data := FND_MESSAGE.GET;
            RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => l_app_ref_id,
                 p_doc_no            => l_bpo_number,
                 p_part_doc_no       => NULL,
                 p_msg_text          => l_msg_data,
                 p_status_code       => 0,
                 p_int_ctl_num       => l_int_ctl_num);
            IF l_return_status <> 'S' THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         ELSE
            FND_MESSAGE.SET_NAME('CLN','CLN_OPEN_IF_ERROR');
            l_msg_data := FND_MESSAGE.GET;
            l_error_status := FND_API.G_RET_STS_ERROR;
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER6', l_error_status);
            wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PARAMETER7', l_msg_data);
            RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => l_app_ref_id,
                 p_doc_no            => NULL,
                 p_part_doc_no       => NULL,
                 p_msg_text          => l_msg_data,
                 p_status_code       => 1,
                 p_int_ctl_num       => l_int_ctl_num);
            IF l_return_status <> 'S' THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            FOR ERRORS IN PO_OPI_ERRORS(l_int_hdr_id) LOOP
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Obtained cursor row for each error', 1);
               END IF;

               RAISE_ADD_MESSAGE(
                  x_return_status    => l_return_status,
                  x_msg_data         => l_return_msg,
                  p_ictrl_no         => l_int_ctl_num,
                  p_ref1             => l_int_hdr_id,
                  p_ref2             => ERRORS.INTERFACE_LINE_ID,
                  p_ref3             => ERRORS.BATCH_ID,
                  p_ref4             => ERRORS.TABLE_NAME,
                  p_ref5             => ERRORS.COLUMN_NAME,
                  p_dtl_msg          => ERRORS.ERROR_MESSAGE);
               IF l_return_status <> 'S' THEN
                  IF (l_Debug_Level <= 1) THEN
                          cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
                  END IF;

                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END LOOP;
    END IF;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING LOG_PO_OI_ERRORS API', 2);
         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            x_resultout := 'ERROR:' || l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add( l_error_code || ':' || l_error_msg, 5);
            END IF;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING LOG_PO_OI_ERRORS API', 2);
            END IF;

      END LOG_PO_OI_ERRORS;


   -- Name
   --    GET_TRADING_PARTNER_DETAILS
   -- Purpose
   --    This procedure returns back the trading partner id
   --    and trading partner site id based the header id
   --
   -- Arguments
   --    Header ID
   -- Notes
   --    No specific notes.

   PROCEDURE GET_TRADING_PARTNER_DETAILS(
      x_tp_id              OUT NOCOPY NUMBER,
      x_tp_site_id         OUT NOCOPY NUMBER,
      p_tp_header_id       IN  NUMBER)
   IS
      l_debug_mode         VARCHAR2(255);
      l_tp_id              NUMBER;
      l_tp_site_id         NUMBER;
   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('ENTERING GET_TRADING_PARTNER_DETAILS', 2);
      END IF;


      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('p_tp_header_id:' || p_tp_header_id, 1);
      END IF;


      SELECT  PARTY_ID, PARTY_SITE_ID
      INTO    l_tp_id, l_tp_site_id
      FROM    ECX_TP_HEADERS
      WHERE   TP_HEADER_ID = p_tp_header_id;

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('l_tp_id:' || l_tp_id, 1);
      END IF;

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('l_tp_site_id:' || l_tp_site_id, 1);
      END IF;


      x_tp_id := l_tp_id;
      x_tp_site_id := l_tp_site_id;

      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('GET_TRADING_PARTNER_DETAILS', 2);
      END IF;

   END GET_TRADING_PARTNER_DETAILS;


   -- Name
   --    RAISE_UPDATE_COLLABORATION
   -- Purpose
   --    This procedure raises an event to update a collaboration.
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

   PROCEDURE RAISE_UPDATE_COLLABORATION(
      x_return_status      OUT NOCOPY VARCHAR2,
      x_msg_data           OUT NOCOPY VARCHAR2,
      p_ref_id             IN  VARCHAR2,
      p_doc_no             IN  VARCHAR2,
      p_part_doc_no        IN  VARCHAR2,
      p_msg_text           IN  VARCHAR2,
      p_status_code        IN  NUMBER,
      p_int_ctl_num        IN  VARCHAR2)
   IS
      l_cln_ch_parameters  wf_parameter_list_t;
      l_event_key          NUMBER;
      l_error_code         NUMBER;
      l_error_msg          VARCHAR2(2000);
      l_debug_mode         VARCHAR2(255);
      l_doc_status         VARCHAR2(255);
   BEGIN
      -- Sets the debug mode to be FILE
      --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('ENTERING RAISE_UPDATE_COLLABORATION', 2);
      END IF;


      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FND_MESSAGE.SET_NAME('CLN','CLN_CH_EVENT_RAISED');
      FND_MESSAGE.SET_TOKEN('EVENT','Update');
      x_msg_data := FND_MESSAGE.GET;

      SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('With the following parameters', 1);
              cln_debug_pub.Add('p_ref_id' || p_ref_id, 1);
              cln_debug_pub.Add('p_doc_no:' || p_doc_no, 1);
              cln_debug_pub.Add('p_status_code:' || p_status_code, 1);
              cln_debug_pub.Add('p_msg_text:' || p_msg_text, 1);
              cln_debug_pub.Add('p_part_doc_no:' || p_part_doc_no, 1);
              cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
      END IF;


      IF p_status_code = 0 THEN
         l_doc_status := 'SUCCESS';
      ELSE
         l_doc_status := 'ERROR';
      END IF;

      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('l_doc_status:' || l_doc_status, 1);
      END IF;


      l_cln_ch_parameters := wf_parameter_list_t();

      WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_int_ctl_num, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('REFERENCE_ID', p_ref_id, l_cln_ch_parameters);

      WF_EVENT.AddParameterToList('DOCUMENT_NO', p_doc_no, l_cln_ch_parameters);

      WF_EVENT.AddParameterToList('PARTNER_DOCUMENT_NO', p_part_doc_no, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('ORIGINATOR_REFERENCE', p_doc_no, l_cln_ch_parameters);

      WF_EVENT.AddParameterToList('DOCUMENT_STATUS', l_doc_status, l_cln_ch_parameters);
      WF_EVENT.AddParameterToList('MESSAGE_TEXT', p_msg_text, l_cln_ch_parameters);

      WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.update',
                          l_event_key, NULL, l_cln_ch_parameters, NULL);
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.update raised', 1);
      END IF;


      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('EXITING RAISE_UPDATE_COLLABORATION', 2);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         l_error_code    := SQLCODE;
         l_error_msg     := SQLERRM;
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data      := l_error_code || ':' || l_error_msg;
         IF (l_Debug_Level <= 5) THEN
                 cln_debug_pub.Add(x_msg_data, 4);
                 cln_debug_pub.Add('EXITING RAISE_UPDATE_COLLABORATION', 2);
         END IF;

   END RAISE_UPDATE_COLLABORATION;


   -- Name
   --    RAISE_ADD_MESSAGE
   -- Purpose
   --    This procedure raises an event to add messages into collaboration history
   --
   -- Arguments
   --
   -- Notes
   --    No specific notes.

         PROCEDURE RAISE_ADD_MESSAGE(
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_ictrl_no             IN  NUMBER,
            p_ref1                 IN  VARCHAR2,
            p_ref2                 IN  VARCHAR2,
            p_ref3                 IN  VARCHAR2,
            p_ref4                 IN  VARCHAR2,
            p_ref5                 IN  VARCHAR2,
            p_dtl_msg              IN  VARCHAR2)
         IS
            l_cln_ch_parameters    wf_parameter_list_t;
            l_event_key            NUMBER;
            l_error_code           NUMBER;
            l_error_msg            VARCHAR2(2000);
            l_debug_mode           VARCHAR2(255);
            l_dtl_coll_id          NUMBER;
            l_msg_data            VARCHAR2(2000);
         BEGIN
            -- Sets the debug mode to be FILE
            --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('ENTERING RAISE_ADD_MESSAGE', 2);
            END IF;

            -- Parameters received
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('With the following parameters',1);
                    cln_debug_pub.Add('p_ictrl_no           - ' || p_ictrl_no,1);
                    cln_debug_pub.Add('p_ref1               - ' || p_ref1,1);
                    cln_debug_pub.Add('p_ref2               - ' || p_ref2,1);
                    cln_debug_pub.Add('p_ref3               - ' || p_ref3,1);
                    cln_debug_pub.Add('p_ref4               - ' || p_ref4,1);
                    cln_debug_pub.Add('p_ref5               - ' || p_ref5,1);
                    cln_debug_pub.Add('p_dtl_msg            - ' || p_dtl_msg,1);
            END IF;


            -- Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            FND_MESSAGE.SET_NAME('CLN', 'CLN_G_RET_MSG_SUCCESS');
            x_msg_data := FND_MESSAGE.GET;


            SELECT cln_generic_s.nextval INTO l_event_key FROM dual;

            l_cln_ch_parameters := wf_parameter_list_t();
            WF_EVENT.AddParameterToList('COLLABORATION_DETAIL_ID', l_dtl_coll_id, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID1', p_ref1, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID2', p_ref2, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID3', p_ref3, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID4', p_ref4, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('REFERENCE_ID5', p_ref5, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('DETAIL_MESSAGE', p_dtl_msg, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER', p_ictrl_no, l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('DOCUMENT_TYPE', 'SALES_ORDER', l_cln_ch_parameters);
            WF_EVENT.AddParameterToList('DOCUMENT_DIRECTION', 'IN', l_cln_ch_parameters);
            -- Not required since defaulted to APPS
            -- WF_EVENT.AddParameterToList('COLLABORATION_POINT', 'APPS', l_cln_ch_parameters);

            WF_EVENT.Raise('oracle.apps.cln.ch.collaboration.addmessage',
                               l_event_key, NULL, l_cln_ch_parameters, NULL);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Workflow event- oracle.apps.cln.ch.collaboration.addmessage', 1);
            END IF;


            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING RAISE_ADD_MESSAGE', 2);
            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_data        := l_error_code || ':' || l_error_msg;
               IF (l_Debug_Level <= 5) THEN
                       cln_debug_pub.Add(x_msg_data, 4);
                       cln_debug_pub.Add('EXITING RAISE_ADD_MESSAGE', 2);
               END IF;

         END RAISE_ADD_MESSAGE;

END CLN_PO_SYNC_CAT_PKG;

/
