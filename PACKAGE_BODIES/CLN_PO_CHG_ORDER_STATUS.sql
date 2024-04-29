--------------------------------------------------------
--  DDL for Package Body CLN_PO_CHG_ORDER_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_PO_CHG_ORDER_STATUS" AS
/*$Header: CLNPOSSB.pls 120.5 2006/11/20 13:07:23 slattupa noship $*/
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
   TYPE t_line_num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   l_line_num_tab t_line_num_tab;
-- Package
--   CLN_PO_CHG_ORDER_STATUS
--
-- Purpose
--    Specification of package body: CLN_PO_CHG_ORDER_STATUS.
--    This package functions facilitate in updating the Purchase order
--
-- History
--    Aug-06-2002       Viswanthan Umapathy         Created
   -- Name
   --    IS_ALREADY_PROCESSED_LINE
   -- Purpose
   --    Checks whether a line is already processed or not
   -- Arguments
   --   PO Line Num
      FUNCTION IS_ALREADY_PROCESSED_LINE(
         p_line_num             IN  VARCHAR2)
         RETURN BOOLEAN
      IS
           i           binary_integer;
      BEGIN
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_ORDER_HEADER,p_line_num:' || p_line_num, 2);
         END IF;
           i := l_line_num_tab.first();
           while i is not null loop
             IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('next element:' || l_line_num_tab(i), 1);
             END IF;
             IF (l_line_num_tab(i) = p_line_num ) THEN
                IF (l_Debug_Level <= 2) THEN
                       cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER:Line is duplicate', 1);
                END IF;
                RETURN TRUE;
             END IF;
             i := l_line_num_tab.next(i);
           end loop;
           l_line_num_tab(l_line_num_tab.count()+1) := p_line_num;
           IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER:Line is not duplicate', 1);
           END IF;
           RETURN FALSE;
      END;
   -- Name
   --    PROCESS_ORDER_HEADER
   -- Purpose
   --    Processes the order header details by creating and updating the collaboration history
   -- Arguments
   --   PO and SO details
   -- Notes
   --    No specific notes
      PROCEDURE PROCESS_ORDER_HEADER(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_so_id                     IN VARCHAR2,
         p_so_status                 IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_tp_id            NUMBER;
         l_so_status        VARCHAR2(100);
         l_user_id          NUMBER;
         l_msg_text         VARCHAR2(1000);
         l_po_type          VARCHAR2(50);
         l_error_id         NUMBER;
         l_error_status     VARCHAR2(1000);
         l_tp_site_id       NUMBER;
         l_doc_no           VARCHAR2(100);  --bug #4889717
      BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
         SAVEPOINT SO_PROCESSING_TXN;
         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;
         G_PO_LINE_NUMBER := -1;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_ORDER_HEADER', 2);
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_app_ref_id:'   || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_po_id:'        || p_po_id, 1);
                 cln_debug_pub.Add('p_po_rel_num:'   || p_po_rel_num, 1);
                 cln_debug_pub.Add('p_po_rev_num:'   || p_po_rev_num, 1);
                 cln_debug_pub.Add('p_so_id:'        || p_so_id, 1);
                 cln_debug_pub.Add('p_so_status:'    || p_so_status, 1);
                 cln_debug_pub.Add('p_tp_id:'        || p_tp_id, 1);
                 cln_debug_pub.Add('p_int_ctl_num:'  || p_int_ctl_num, 1);
         END IF;
         l_line_num_tab.delete;-- Initialize array of PO lines
         CLN_UTILS.GET_TRADING_PARTNER(p_tp_id, l_tp_id);
         SAVEPOINT PO_UPDATE_TXN;
         -- No need to create collaboration since XMLGateway Event handler will create
         -- a collaboration if XMLGateway receives an inbound CLN document otherthan CBOD
         l_so_status := upper(p_so_status);

         IF l_so_status <> 'OPEN' THEN
            FND_MESSAGE.SET_NAME('CLN','CLN_INVALID_ORDER_STATUS');
            FND_MESSAGE.SET_TOKEN('ORDERSTATUS', p_so_status);
            x_msg_data := FND_MESSAGE.GET;
            RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => p_app_ref_id,
                 p_doc_no            => p_po_id,
                 p_part_doc_no       => p_so_id,
                 p_msg_text          => x_msg_data,
                 p_status_code       => 1,
                 p_int_ctl_num       => p_int_ctl_num);
            IF l_return_status <> 'S' THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add(x_msg_data, 1);
            END IF;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER', 2);
            END IF;
            RETURN;
         END IF; -- SO Status
         FND_MESSAGE.SET_NAME('CLN','CLN_PO_UPDATION_SUCCESS');
         l_msg_text := FND_MESSAGE.GET;
         RAISE_UPDATE_COLLABORATION(
              x_return_status     => l_return_status,
              x_msg_data          => l_return_msg,
              p_ref_id            => p_app_ref_id,
              p_doc_no            => p_po_id,
              p_part_doc_no       => p_so_id,
              p_msg_text          => l_msg_text,
              p_status_code       => 0,
              p_int_ctl_num       => p_int_ctl_num);
         IF l_return_status <> 'S' THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         -- New PO API for Change Management
         GET_TRADING_PARTNER_DETAILS(l_tp_id, l_tp_site_id, p_tp_id);
         PO_CHG_REQUEST_GRP.initialize_chn_ack_inbound (
            p_requestor          => fnd_global.user_name,
            p_int_cont_num       => p_int_ctl_num,
            p_request_origin     => '9iAS',
            p_tp_id              => l_tp_id,
            p_tp_site_id         => l_tp_site_id,
            x_error_id           => l_error_id,
            x_error_status       => l_error_status);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('initialize_chn_ack_inbound call',1);
                 cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                 cln_debug_pub.Add('l_error_status:' || l_error_status,1);
         END IF;
         IF l_error_id IS NULL OR l_error_id = 0 THEN
            l_po_type := 'STANDARD';
            l_doc_no := p_po_id;     --bug #4889717
            IF (p_po_rel_num IS NOT NULL AND p_po_rel_num > 0) THEN
               l_po_type := 'RELEASE';
               l_doc_no := concat(concat(p_po_id,':'),p_po_rel_num); --bug #4889717
            END IF;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('l_po_type:' || l_po_type,1);
            END IF;
            PO_CHG_REQUEST_GRP.validate_header (
               p_requestor          => fnd_global.user_name,
               p_int_cont_num       => p_int_ctl_num,
               p_request_origin     => '9iAS',
               p_request_type       => 'CHANGE',
               p_tp_id              => l_tp_id,
               p_tp_site_id         => l_tp_site_id,
               p_po_number          => p_po_id,
               p_release_number     => p_po_rel_num,
               p_po_type            => l_po_type,
               p_revision_num       => p_po_rev_num,
               x_error_id_in        => l_error_id,
               x_error_status_in    => l_error_status,
               x_error_id_out       => l_error_id,
               x_error_status_out   => l_error_status);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('validate_header call',1);
                    cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                    cln_debug_pub.Add('l_error_status:' || l_error_status,1);
            END IF;
         END IF;
         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('PO API call failed',1);
            END IF;
            ROLLBACK TO PO_UPDATE_TXN;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',1);
            END IF;
            x_msg_data := l_error_status;
            RAISE_UPDATE_COLLABORATION(
               x_return_status     => l_return_status,
               x_msg_data          => l_return_msg,
               p_ref_id            => p_app_ref_id,
               --p_doc_no            => p_po_id,
               p_doc_no            => l_doc_no,         --bug #4889717
               p_part_doc_no       => p_so_id,
               p_msg_text          => l_error_status,
               p_status_code       => 1,
               p_int_ctl_num       => p_int_ctl_num);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_UPDATE_COLLABORATION CALL FAILED',1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            RAISE_ADD_MESSAGE(
               x_return_status            => l_return_status,
               x_msg_data                 => l_return_msg,
               p_ictrl_no                 => p_int_ctl_num,
               p_ref1                     => to_char(p_po_rel_num),
               p_ref2                     => p_so_id,
               p_ref3                     => NULL,
               p_ref4                     => NULL,
               p_ref5                     => NULL,
               p_dtl_msg                  => NULL);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add(x_msg_data, 1);
            END IF;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER', 2);
            END IF;
            RETURN;
         END IF; -- if error_id is not zero
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER', 2);
         END IF;
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := l_return_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data := 'While trying to process order header'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER', 2);
            END IF;
         WHEN OTHERS THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data := 'While trying to process order header'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_HEADER', 2);
            END IF;
      END PROCESS_ORDER_HEADER;
   -- Name
   --    PROCESS_ORDER_LINE
   -- Purpose
   --    Processes the order line header details by updating the PO  thru
   --    'Change PO' APIs and collaboration history. Line price gets modified
   -- Arguments
   --   PO and SO Line details
   -- Notes
   --    x_order_line_closed will be 'YES' if the SO Line Status is
   --    equivalent to any of the one defined in the lookup
   --    CLN_ORDER_LINE_CLOSE_STATUS
      PROCEDURE PROCESS_ORDER_LINE(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         x_order_line_closed         OUT NOCOPY VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_po_line_num               IN NUMBER,
         p_so_price                  IN NUMBER,
         p_price_currency            IN VARCHAR2,
         p_price_uom                 IN VARCHAR2,
         p_supplier_part_num         IN VARCHAR2,
         p_so_id                     IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2,
         -- Supplier Doc and Line Reference added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_dtl_coll_id      NUMBER;
         l_count            NUMBER;
         l_po_type          VARCHAR2(50);
         l_error_id         NUMBER;
         l_error_status     VARCHAR2(1000);
         l_tp_id            NUMBER;
         l_tp_site_id       NUMBER;
         l_ack_type         VARCHAR2(50);
         l_doc_no           VARCHAR2(100);    --bug #4889717

      BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;


         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_ORDER_LINE', 2);
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_po_id:' || p_po_id, 1);
                 cln_debug_pub.Add('p_po_rel_num:' || p_po_rel_num, 1);
                 cln_debug_pub.Add('p_po_rev_num:' || p_po_rev_num, 1);
                 cln_debug_pub.Add('p_po_line_num:' || p_po_line_num, 1);
                 cln_debug_pub.Add('p_so_price:' || p_so_price, 1);
                 cln_debug_pub.Add('p_price_currency:' || p_price_currency, 1);
                 cln_debug_pub.Add('p_price_uom:' || p_price_uom, 1);
                 cln_debug_pub.Add('p_supplier_part_num:' || p_supplier_part_num, 1);
                 cln_debug_pub.Add('p_so_id:' || p_so_id, 1);
                 cln_debug_pub.Add('p_so_line_num:' || p_so_line_num, 1);
                 cln_debug_pub.Add('p_so_line_status:' || p_so_line_status, 1);
                 cln_debug_pub.Add('p_reason:' || p_reason, 1);
                 cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_tp_id:' || p_tp_id, 1);
                 cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
                 cln_debug_pub.Add('p_supp_doc_ref:' || p_supp_doc_ref, 1);
                 cln_debug_pub.Add('p_supp_line_ref:' || p_supp_line_ref, 1);
         END IF;
         IF IS_ALREADY_PROCESSED_LINE(p_po_line_num) THEN
               -- Nothing to do since the changes happens only once per each po line
               -- Collaboration history too is not updated
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('Since this an already processed line, Nothing to do', 1);
               END IF;
               RETURN;
         END IF;
         l_po_type := 'STANDARD';
         l_doc_no := p_po_id;           --bug #4889717
         IF (p_po_rel_num IS NOT NULL AND p_po_rel_num > 0) THEN
            l_po_type := 'RELEASE';
            l_doc_no := concat(concat(p_po_id,':'),p_po_rel_num); --bug #4889717
         END IF;
         GET_TRADING_PARTNER_DETAILS(l_tp_id, l_tp_site_id, p_tp_id);
         IF l_po_type = 'RELEASE' THEN
            -- Nothing to do since the changes happens only at shipment level
            -- Collaboration history too is not updated
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Since this a RELEASE, Nothing to do', 1);
            END IF;
            -- Is Order Line Closed ?
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('p_so_line_status:' || p_so_line_status, 1);
            END IF;

            IF upper(p_so_line_status) = 'CANCELLED' OR upper(p_so_line_status) = 'CLOSED' THEN
              x_order_line_closed := 'YES';
            END IF;

            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('x_order_line_closed:' || x_order_line_closed, 1);
            END IF;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE', 2);
            END IF;
            RETURN;
         ELSE
               IF upper(p_reason) = 'CANCELLED' THEN
                  l_ack_type := 'CANCELLATION';
               ELSE
                  l_ack_type := 'MODIFICATION';
               END IF;
            PO_CHG_REQUEST_GRP.store_supplier_request (
               p_requestor         => fnd_global.user_name,
               p_int_cont_num      => p_int_ctl_num,
               p_request_type      => 'CHANGE',
               p_tp_id             => l_tp_id,
               p_tp_site_id        => l_tp_site_id,
               p_level             => 'LINE',
               p_po_number         => p_po_id,
               p_release_number    => p_po_rel_num,
               p_po_type           => 'STANDARD',
               p_revision_num      => NULL,
               p_line_num          => p_po_line_num,
               p_reason            => p_reason,
               p_shipment_num      => NULL,
               p_quantity          => NULL,
               p_quantity_uom      => NULL,
               p_price             => p_so_price,
               p_price_currency    => p_price_currency,
               p_price_uom         => p_price_uom,
               p_promised_date     => NULL,
               p_supplier_part_num => p_supplier_part_num,
               p_so_number         => p_so_id,
               p_so_line_number    => p_so_line_num,
               p_ack_type          => l_ack_type,
               x_error_id_in       => l_error_id,
               x_error_status_in   => l_error_status,
               x_error_id_out      => l_error_id,
               x_error_status_out  => l_error_status,
               -- Supplier Line Reference added for new Change_PO API to
               -- support split lines and cancellation at header and schedule level.
               p_parent_shipment_number  => NULL,
               p_supplier_doc_ref  => p_supp_doc_ref,
               p_supplier_line_ref => p_supp_line_ref,
               p_supplier_shipment_ref => NULL);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('store_supplier_request',1);
                    cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                    cln_debug_pub.Add('l_error_status:' || l_error_status,1);
            END IF;
         END IF;  -- if itz a standard po
         IF l_error_id IS NULL OR l_error_id = 0 THEN
            RAISE_ADD_MESSAGE(
               x_return_status => l_return_status,
               x_msg_data      => l_return_msg,
               p_ictrl_no      => p_int_ctl_num,
               p_ref1          => p_po_line_num,
               p_ref2          => p_so_line_num,
               p_ref3          => p_so_price,
               p_ref4          => p_price_currency,
               p_ref5          => p_price_uom,
               p_dtl_msg       => p_so_line_status);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
         -- PO_CHG_REQUEST_GRP.store_supplier_request call failed
         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('PO API call failed',1);
            END IF;
            ROLLBACK TO PO_UPDATE_TXN;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',1);
            END IF;
            x_msg_data := l_error_status;
            RAISE_UPDATE_COLLABORATION(
               x_return_status     => l_return_status,
               x_msg_data          => l_return_msg,
               p_ref_id            => p_app_ref_id,
               --p_doc_no            => p_po_id,
               p_doc_no            => l_doc_no,       --bug #4889717
               p_part_doc_no       => p_so_id,
               p_msg_text          => l_error_status,
               p_status_code       => 1,
               p_int_ctl_num       => p_int_ctl_num);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_UPDATE_COLLABORATION CALL FAILED',1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            RAISE_ADD_MESSAGE(
               x_return_status    => l_return_status,
               x_msg_data         => l_return_msg,
               p_ictrl_no         => p_int_ctl_num,
               p_ref1             => p_po_line_num,
               p_ref2             => p_so_line_num,
               p_ref3             => p_so_price,
               p_ref4             => p_price_currency,
               p_ref5             => p_price_uom,
               p_dtl_msg          => p_so_line_status);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE', 2);
            END IF;
            RETURN;
         END IF; -- if error_id is not zero
         -- Is Order Line Closed ?
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('p_so_line_status:' || p_so_line_status, 1);
         END IF;
         IF upper(p_so_line_status) = 'CANCELLED' OR upper(p_so_line_status) = 'CLOSED' THEN
            x_order_line_closed := 'YES';
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('x_order_line_closed:' || x_order_line_closed, 1);
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE', 2);
         END IF;
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_data := l_return_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data :=  'While trying to process order line'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', PO Line Number'
                                    || p_po_line_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE', 2);
            END IF;
         WHEN OTHERS THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data :=  'While trying to process order line'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', PO Line Number'
                                    || p_po_line_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE', 2);
            END IF;
      END PROCESS_ORDER_LINE;
   -- Name
   --    PROCESS_ORDER_LINE_SHIPMENT
   -- Purpose
   --    Processes the order line shipment by updating the PO thru 'Change PO' APIs
   --    and collaboration history
   --    Shipment Quantity and Promised date get modified
   --    If it is a RELEASE PO, Line price also gets modified
   -- Arguments
   --   PO and SO Line details
   -- Notes
   --   No Specific Notes
      PROCEDURE PROCESS_ORDER_LINE_SHIPMENT(
         x_return_status             OUT NOCOPY VARCHAR2,
         x_msg_data                  OUT NOCOPY VARCHAR2,
         x_order_line_closed         OUT NOCOPY VARCHAR2,
         p_po_id                     IN VARCHAR2,
         p_po_rel_num                IN NUMBER,
         p_po_rev_num                IN NUMBER,
         p_po_line_num               IN NUMBER,
         p_po_ship_num               IN NUMBER,
         p_po_quantity               IN NUMBER,
         p_po_quantity_uom           IN VARCHAR2,
         p_so_price                  IN NUMBER,
         p_price_currency            IN VARCHAR2,
         p_price_uom                 IN VARCHAR2,
         p_po_promised_date          IN DATE,
         p_supplier_part_num         IN VARCHAR2,
         p_so_id                     IN VARCHAR2,
         p_so_line_num               IN NUMBER,
         p_so_line_status            IN VARCHAR2,
         p_reason                    IN VARCHAR2,
         p_app_ref_id                IN VARCHAR2,
         p_tp_id                     IN VARCHAR2,
         p_int_ctl_num               IN VARCHAR2,
         -- Additional parameters added for new Change_PO API to
         -- support split lines and cancellation at header and schedule level.
         p_supp_doc_ref              IN VARCHAR2 DEFAULT NULL,
         p_supp_line_ref             IN VARCHAR2 DEFAULT NULL,
         p_supplier_shipment_ref     IN VARCHAR2 DEFAULT NULL,
         p_parent_shipment_number    IN VARCHAR2 DEFAULT NULL)
      IS
         l_return_status    VARCHAR2(1000);
         l_return_msg       VARCHAR2(2000);
         l_debug_mode       VARCHAR2(300);
         l_error_code       NUMBER;
         l_error_msg        VARCHAR2(2000);
         l_dtl_coll_id      NUMBER;
         l_count            NUMBER;
         l_po_type          VARCHAR2(50);
         l_error_id         NUMBER;
         l_error_status     VARCHAR2(1000);
         l_tp_id            NUMBER;
         l_tp_site_id       NUMBER;
         l_ack_type         VARCHAR2(50);
	 l_doc_no           VARCHAR2(100);      --bug #4889717
      BEGIN
         -- Sets the debug mode to be FILE
         --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
         --  Initialize API return status to success
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         x_msg_data := FND_MESSAGE.GET;

         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('ENTERING PROCESS_ORDER_LINE_SHIPMENT', 2);
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('With the following parameters:', 1);
                 cln_debug_pub.Add('p_po_id:' || p_po_id, 1);
                 cln_debug_pub.Add('p_po_rel_num:' || p_po_rel_num, 1);
                 cln_debug_pub.Add('p_po_rev_num:' || p_po_rev_num, 1);
                 cln_debug_pub.Add('p_po_line_num:' || p_po_line_num, 1);
                 cln_debug_pub.Add('G_PO_LINE_NUMBER:' || G_PO_LINE_NUMBER, 1);
                 cln_debug_pub.Add('p_po_ship_num:' || p_po_ship_num, 1);
                 cln_debug_pub.Add('p_po_quantity:' || p_po_quantity, 1);
                 cln_debug_pub.Add('p_po_quantity_uom:' || p_po_quantity_uom, 1);
                 cln_debug_pub.Add('p_so_price:' || p_so_price, 1);
                 cln_debug_pub.Add('p_price_currency:' || p_price_currency, 1);
                 cln_debug_pub.Add('p_price_uom:' || p_price_uom, 1);
                 cln_debug_pub.Add('p_po_promised_date:' || p_po_promised_date, 1);
                 cln_debug_pub.Add('p_supplier_part_num:' || p_supplier_part_num, 1);
                 cln_debug_pub.Add('p_so_id:' || p_so_id, 1);
                 cln_debug_pub.Add('p_so_line_num:' || p_so_line_num, 1);
                 cln_debug_pub.Add('p_so_line_status:' || p_so_line_status, 1);
                 cln_debug_pub.Add('p_reason:' || p_reason, 1);
                 cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                 cln_debug_pub.Add('p_tp_id:' || p_tp_id, 1);
                 cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
                 cln_debug_pub.Add('p_supp_doc_ref:' || p_supp_doc_ref, 1);
                 cln_debug_pub.Add('p_supp_line_ref:' || p_supp_line_ref, 1);
                 cln_debug_pub.Add('p_supplier_shipment_ref:' || p_supplier_shipment_ref, 1);
                 cln_debug_pub.Add('p_parent_shipment_number:' || p_parent_shipment_number, 1);
         END IF;
         l_po_type := 'STANDARD';
         l_doc_no := p_po_id;  --bug #4889717
         IF (p_po_rel_num IS NOT NULL AND p_po_rel_num > 0) THEN
            l_po_type := 'RELEASE';
            l_doc_no := concat(concat(p_po_id,':'),p_po_rel_num); --bug #4889717
         END IF;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_po_type:' || l_po_type, 1);
         END IF;
         GET_TRADING_PARTNER_DETAILS(l_tp_id, l_tp_site_id, p_tp_id);
	 IF upper(p_reason) = 'CANCELLED' THEN
	    l_ack_type := 'CANCELLATION';
	 ELSE
	    l_ack_type := 'MODIFICATION';
	 END IF;
         IF l_po_type = 'RELEASE' THEN
            -- Price also gets updated
            PO_CHG_REQUEST_GRP.store_supplier_request (
               p_requestor         => fnd_global.user_name,
               p_int_cont_num      => p_int_ctl_num,
               -- Always change irrespective of, if at all there is any change
               p_request_type      => 'CHANGE',
               p_tp_id             => l_tp_id,
               p_tp_site_id        => l_tp_site_id,
               p_level             => 'SHIPMENT',
               p_po_number         => p_po_id,
               p_release_number    => p_po_rel_num,
               p_po_type           => 'RELEASE',
               -- Should not pass revision nmumber, it keeps changing
               p_revision_num      => NULL,
               p_line_num          => p_po_line_num,
               p_reason            => p_reason,
               p_shipment_num      => p_po_ship_num,
               p_quantity          => p_po_quantity,
               p_quantity_uom      => p_po_quantity_uom,
               p_price             => p_so_price,
               p_price_currency    => p_price_currency,
               p_price_uom         => p_price_uom,
               p_promised_date     => p_po_promised_date,
               p_supplier_part_num => p_supplier_part_num,
               p_so_number         => p_so_id,
               p_so_line_number    => p_so_line_num,
               p_ack_type          => l_ack_type,
               x_error_id_in       => l_error_id,
               x_error_status_in   => l_error_status,
               x_error_id_out      => l_error_id,
               x_error_status_out  => l_error_status,
               -- Supplier Line Reference added for new Change_PO API to
               -- support split lines and cancellation at header and schedule level.
               p_parent_shipment_number  => p_parent_shipment_number,
               p_supplier_doc_ref  => p_supp_doc_ref,
               p_supplier_line_ref => p_supp_line_ref,
               p_supplier_shipment_ref => p_supplier_shipment_ref);
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('store_supplier_request',1);
                    cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                    cln_debug_pub.Add('l_error_status:' || l_error_status,1);
            END IF;
         ELSE
            IF G_PO_LINE_NUMBER <> p_po_line_num THEN
               PO_CHG_REQUEST_GRP.store_supplier_request (
                  p_requestor         => fnd_global.user_name,
                  p_int_cont_num      => p_int_ctl_num,
                  p_request_type      => 'CHANGE',
                  p_tp_id             => l_tp_id,
                  p_tp_site_id        => l_tp_site_id,
                  p_level             => 'LINE',
                  p_po_number         => p_po_id,
                  p_release_number    => p_po_rel_num,
                  p_po_type           => 'STANDARD',
                  p_revision_num      => NULL,
                  p_line_num          => p_po_line_num,
                  p_reason            => p_reason,
                  p_shipment_num      => NULL,
                  p_quantity          => NULL,
                  p_quantity_uom      => NULL,
                  p_price             => p_so_price,
                  p_price_currency    => p_price_currency,
                  p_price_uom         => p_price_uom,
                  p_promised_date     => NULL,
                  p_supplier_part_num => p_supplier_part_num,
                  p_so_number         => p_so_id,
                  p_so_line_number    => p_so_line_num,
                  p_ack_type          => l_ack_type,
                  x_error_id_in       => l_error_id,
                  x_error_status_in   => l_error_status,
                  x_error_id_out      => l_error_id,
                  x_error_status_out  => l_error_status,
                  -- Supplier Line Reference added for new Change_PO API to
                  -- support split lines and cancellation at header and schedule level.
                  p_parent_shipment_number  => p_parent_shipment_number,
                  p_supplier_doc_ref  => p_supp_doc_ref,
                  p_supplier_line_ref => p_supp_line_ref,
                  p_supplier_shipment_ref => p_supplier_shipment_ref);
               IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('store_supplier_request',1);
                    cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                    cln_debug_pub.Add('l_error_status:' || l_error_status,1);
               END IF;
               G_PO_LINE_NUMBER := p_po_line_num;
            END IF;
            IF l_error_id IS NULL OR l_error_id = 0 THEN
               PO_CHG_REQUEST_GRP.store_supplier_request (
                  p_requestor         => fnd_global.user_name,
                  p_int_cont_num      => p_int_ctl_num,
                  -- Always change irrespective of, if at all there is any change
                  p_request_type      => 'CHANGE',
                  p_tp_id             => l_tp_id,
                  p_tp_site_id        => l_tp_site_id,
                  p_level             => 'SHIPMENT',
                  p_po_number         => p_po_id,
                  p_release_number    => p_po_rel_num,
                  p_po_type           => 'STANDARD',
                  -- Should not pass revision nmumber, it keeps changing
                  p_revision_num      => NULL,
                  p_line_num          => p_po_line_num,
                  p_reason            => p_reason,
                  p_shipment_num      => p_po_ship_num,
                  p_quantity          => p_po_quantity,
                  p_quantity_uom      => p_po_quantity_uom,
                  p_price             => NULL,
                  p_price_currency    => NULL,
                  p_price_uom         => NULL,
                  p_promised_date     => p_po_promised_date,
                  p_supplier_part_num => p_supplier_part_num,
                  p_so_number         => p_so_id,
                  p_so_line_number    => p_so_line_num,
                  p_ack_type          => l_ack_type,
                  x_error_id_in       => l_error_id,
                  x_error_status_in   => l_error_status,
                  x_error_id_out      => l_error_id,
                  x_error_status_out  => l_error_status,
                  -- Supplier Line Reference added for new Change_PO API to
                  -- support split lines and cancellation at header and schedule level.
                  p_parent_shipment_number  => p_parent_shipment_number,
                  p_supplier_doc_ref  => p_supp_doc_ref,
                  p_supplier_line_ref => p_supp_line_ref,
                  p_supplier_shipment_ref => p_supplier_shipment_ref);
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('store_supplier_request',1);
                       cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                       cln_debug_pub.Add('l_error_status:' || l_error_status,1);
               END IF;
            END IF;
         END IF;  -- if itz a standard po
         IF l_error_id IS NULL OR l_error_id = 0 THEN
            RAISE_ADD_MESSAGE(
               x_return_status => l_return_status,
               x_msg_data      => l_return_msg,
               p_ictrl_no      => p_int_ctl_num,
               p_ref1          => p_po_line_num,
               p_ref2          => p_po_ship_num,
               p_ref3          => p_so_price,
               p_ref4          => p_price_currency,
               p_ref5          => p_price_uom,
               p_dtl_msg       => p_reason);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
         -- PO_CHG_REQUEST_GRP.store_supplier_request call failed
         IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
            cln_debug_pub.Add('PO API call failed',1);
            ROLLBACK TO PO_UPDATE_TXN;
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',1);
            END IF;
            x_msg_data := l_error_status;
            RAISE_UPDATE_COLLABORATION(
               x_return_status     => l_return_status,
               x_msg_data          => l_return_msg,
               p_ref_id            => p_app_ref_id,
               --p_doc_no            => p_po_id,
               p_doc_no            => l_doc_no,    --bug #4889717
               p_part_doc_no       => p_so_id,
               p_msg_text          => l_error_status,
               p_status_code       => 1,
               p_int_ctl_num       => p_int_ctl_num);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_UPDATE_COLLABORATION CALL FAILED',1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            RAISE_ADD_MESSAGE(
               x_return_status    => l_return_status,
               x_msg_data         => l_return_msg,
               p_ictrl_no         => p_int_ctl_num,
               p_ref1             => p_po_line_num,
               p_ref2             => p_so_line_num,
               p_ref3             => p_po_ship_num,
               p_ref4             => p_po_quantity,
               p_ref5             => p_po_promised_date,
               p_dtl_msg          => p_reason);
            IF l_return_status <> 'S' THEN
               IF (l_Debug_Level <= 1) THEN
                       cln_debug_pub.Add('RAISE_ADD_MESSAGE CALL FAILED', 1);
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (l_Debug_Level <= 2) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE_SHIPMENT', 2);
            END IF;
            -- Is Order Line Closed ?
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('p_so_line_status:' || p_so_line_status, 1);
            END IF;

            IF upper(p_so_line_status) = 'CANCELLED' OR upper(p_so_line_status) = 'CLOSED' THEN
                x_order_line_closed := 'YES';
            END IF;

            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('x_order_line_closed:' || x_order_line_closed, 1);
            END IF;
            RETURN;
         END IF; -- if error_id is not zero
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE_SHIPMENT', 2);
         END IF;
      EXCEPTION
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_data := l_return_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data :=  'While trying to process order line shipment'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', PO Line Number'
                                    || p_po_line_num
                                    || ', PO Line Shipment Number'
                                    || p_po_ship_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE_SHIPMENT', 2);
            END IF;
         WHEN OTHERS THEN
            ROLLBACK TO SO_PROCESSING_TXN;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
            END IF;
            l_error_code    := SQLCODE;
            l_error_msg     := SQLERRM;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data      := l_error_code||' : '||l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(x_msg_data, 5);
            END IF;
            x_msg_data :=  'While trying to process order line shipment'
                                    || ' for the inbound show sales order#'
                                    || p_so_id
                                    || ', purchase order#'
                                    || p_po_id
                                    || ', Revision Number '
                                    || p_po_rel_num
                                    || ', Release Number'
                                    || p_po_rev_num
                                    || ', PO Line Number'
                                    || p_po_line_num
                                    || ', PO Line Shipment Number'
                                    || p_po_ship_num
                                    || ', the following error is encountered:'
                                    || x_msg_data;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING PROCESS_ORDER_LINE_SHIPMENT', 2);
            END IF;
      END PROCESS_ORDER_LINE_SHIPMENT;
     -- Name
     --   LOAD_CHANGES
     -- Purpose
     --   Call Process Supplier Request of Update_PO API to
     --   load all changes in to interface tables
     -- Arguments
     --   Internal Control Number
     -- Notes
     --   No Specific Notes
        PROCEDURE LOAD_CHANGES(
           x_return_status             OUT NOCOPY VARCHAR2,
           x_msg_data                  OUT NOCOPY VARCHAR2,
           p_app_ref_id           IN  VARCHAR2,
           p_po_id                IN  VARCHAR2,
           p_so_num               IN  VARCHAR2,
           p_int_ctl_num          IN  VARCHAR2)
        IS
           l_return_status    VARCHAR2(1000);
           l_return_msg       VARCHAR2(2000);
           l_debug_mode       VARCHAR2(300);
           l_error_code       NUMBER;
           l_error_msg        VARCHAR2(2000);
           l_po_type          VARCHAR2(50);
           l_error_id         NUMBER;
           l_error_status     VARCHAR2(1000);
        BEGIN
            -- Sets the debug mode to be FILE
            --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');
            --  Initialize API return status to success
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
            x_msg_data := FND_MESSAGE.GET;
           IF (l_Debug_Level <= 2) THEN
                   cln_debug_pub.Add('ENTERING LOAD_CHANGES', 2);
           END IF;
           IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('With the following parameters:', 1);
                   cln_debug_pub.Add('p_app_ref_id:' || p_app_ref_id, 1);
                   cln_debug_pub.Add('p_po_id:' || p_po_id, 1);
                   cln_debug_pub.Add('p_so_num:' || p_so_num, 1);
                   cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
           END IF;
           -- If and only if none has failed until now
           PO_CHG_REQUEST_GRP.process_supplier_request (
              p_int_cont_num      => p_int_ctl_num,
              x_error_id_in       => l_error_id,
              x_error_status_in   => l_error_status,
              x_error_id_out      => l_error_id,
              x_error_status_out  => l_error_status);
           IF (l_Debug_Level <= 1) THEN
                   cln_debug_pub.Add('process_supplier_request', 1);
                   cln_debug_pub.Add('l_error_id:' || l_error_id,1);
                   cln_debug_pub.Add('l_error_status:' || l_error_status,1);
           END IF;
           -- PO_CHG_REQUEST_GRP.process_supplier_request call failed
           IF l_error_id IS NOT NULL AND l_error_id <> 0 THEN
              IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('PO API call failed',1);
              END IF;
              ROLLBACK TO PO_UPDATE_TXN;
              IF (l_Debug_Level <= 1) THEN
                      cln_debug_pub.Add('Rolledback PO_UPDATE_TXN transaction',1);
              END IF;
              x_msg_data := l_error_status;
              RAISE_UPDATE_COLLABORATION(
                 x_return_status     => l_return_status,
                 x_msg_data          => l_return_msg,
                 p_ref_id            => p_app_ref_id,
                 p_doc_no            => p_po_id,
                 p_part_doc_no       => p_so_num,
                 p_msg_text          => l_error_status,
                 p_status_code       => 1,
                 p_int_ctl_num       => p_int_ctl_num);
              IF l_return_status <> 'S' THEN
                 IF (l_Debug_Level <= 1) THEN
                         cln_debug_pub.Add('RAISE_UPDATE_COLLABORATION CALL FAILED',1);
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF (l_Debug_Level <= 2) THEN
                      cln_debug_pub.Add('EXITING LOAD_CHANGES', 2);
              END IF;
              RETURN;
           END IF; -- if error_id is not zero
           IF (l_Debug_Level <= 2) THEN
                   cln_debug_pub.Add('EXITING LOAD_CHANGES', 2);
           END IF;
           EXCEPTION
              WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                 ROLLBACK TO SO_PROCESSING_TXN;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
                 END IF;
                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                 x_msg_data := l_return_msg;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add(x_msg_data, 5);
                 END IF;
                 x_msg_data :=  'While trying load changes in to interface tables'
                                      || ' for the inbound show sales order#'
                                      || p_so_num
                                      || ', purchase order#'
                                      || p_po_id
                                      || ', the following error is encountered:'
                                      || x_msg_data;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add('EXITING LOAD_CHANGES', 2);
                 END IF;
              WHEN OTHERS THEN
                 ROLLBACK TO SO_PROCESSING_TXN;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add('Rolledback SO_PROCESSING_TXN transaction',5);
                 END IF;
                 l_error_code    := SQLCODE;
                 l_error_msg     := SQLERRM;
                 x_return_status := FND_API.G_RET_STS_ERROR ;
                 x_msg_data      := l_error_code||' : '||l_error_msg;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add(x_msg_data, 5);
                 END IF;
                 x_msg_data :=  'While trying to load changes in to interface tables'
                                      || ' for the inbound show sales order#'
                                      || p_so_num
                                      || ', purchase order#'
                                      || p_po_id
                                      || ', the following error is encountered:'
                                      || x_msg_data;
                 IF (l_Debug_Level <= 5) THEN
                         cln_debug_pub.Add('EXITING LOAD_CHANGES', 2);
                 END IF;
        END LOAD_CHANGES;
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
              cln_debug_pub.Add('l_tp_site_id:' || l_tp_site_id, 1);
      END IF;
      x_tp_id := l_tp_id;
      x_tp_site_id := l_tp_site_id;
      IF (l_Debug_Level <= 2) THEN
              cln_debug_pub.Add('GET_TRADING_PARTNER_DETAILS', 2);
      END IF;
   END GET_TRADING_PARTNER_DETAILS;
   -- Name
   --   CALL_TAKE_ACTIONS
   -- Purpose
   --   Invokes Notification Processor TAKE_ACTIONS according to the parameter.
   -- Arguments
   --   Status - S/E/U - Sucess, Error, Unexpected Error respectively
   --   Description - Error message if the status if E/U, else 'SUCCESS'
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
         l_status             VARCHAR2(100);
         l_description        VARCHAR2(1000);
         l_so_status          VARCHAR2(100);
         l_order_line_closed  VARCHAR2(100);
         l_trp_id              VARCHAR2(100);
         l_app_ref_id         VARCHAR2(255);
         l_return_status      VARCHAR2(1000);
         l_return_msg         VARCHAR2(2000);
         l_error_code         NUMBER;
         l_error_msg          VARCHAR2(2000);
         l_msg_data           VARCHAR2(1000);
         l_not_msg            VARCHAR2(1000);
         l_debug_mode         VARCHAR2(255);
         l_tp_id              NUMBER;
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
         l_status := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'STATUS');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_status:' || l_status, 1);
         END IF;
         l_description := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'DESCRIPTION');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_description:' || l_description, 1);
         END IF;
         l_so_status := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'SOSTATUS');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_so_status:' || l_so_status, 1);
         END IF;
         l_order_line_closed := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'OLINECLOSED');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_order_line_closed:' || l_order_line_closed, 1);
         END IF;
         l_trp_id := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'TPID');
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_tp_id:' || l_trp_id, 1);
         END IF;
         l_app_ref_id := wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'INTCRTLNO');
         l_app_ref_id := '3A6:' || l_app_ref_id;
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('l_app_ref_id:' || l_app_ref_id, 1);
         END IF;
         CLN_UTILS.GET_TRADING_PARTNER(l_trp_id, l_tp_id);
         IF (l_Debug_Level <= 1) THEN
                 cln_debug_pub.Add('Trading Partner ID:' || l_tp_id, 1);
         END IF;
         -- Error occured
         IF l_status <> 'S' THEN
            -- Invalid Sales Order Status
            IF upper(l_so_status) <> 'OPEN' THEN
               FND_MESSAGE.SET_NAME('CLN','CLN_INVALID_ORDER_STATUS');
               FND_MESSAGE.SET_TOKEN('ORDERSTATUS', l_so_status);
               l_msg_data := FND_MESSAGE.GET;
               CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
                  x_ret_code            => l_return_status,
                  x_ret_desc            => l_return_msg,
                  p_notification_code   => 'SO_IN03',
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
            -- Error
            CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
               x_ret_code            => l_return_status,
               x_ret_desc            => l_return_msg,
               p_notification_code   => 'SO_IN02',
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
         -- Order Line Closed
         IF l_order_line_closed = 'YES' THEN
            FND_MESSAGE.SET_NAME('CLN','CLN_ORDER_LINE_CLOSED');
            l_msg_data := FND_MESSAGE.GET;
            CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
               x_ret_code            => l_return_status,
               x_ret_desc            => l_return_msg,
               p_notification_code   => 'SO_IN04',
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
         -- Success
         FND_MESSAGE.SET_NAME('CLN','CLN_G_RET_MSG_SUCCESS');
         l_msg_data := FND_MESSAGE.GET;
         CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS(
            x_ret_code            => l_return_status,
            x_ret_desc            => l_return_msg,
            p_notification_code   => 'SO_IN01',
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
         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(l_return_msg, 6);
            END IF;
            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
            END IF;
         WHEN OTHERS THEN
            l_error_code  := SQLCODE;
            l_error_msg   := SQLERRM;
            l_not_msg := l_error_code || ':' || l_error_msg;
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add(l_not_msg, 6);
            END IF;
            CLN_NP_PROCESSOR_PKG.NOTIFY_ADMINISTRATOR(l_not_msg);
            IF (l_Debug_Level <= 5) THEN
                    cln_debug_pub.Add('EXITING CALL_TAKE_ACTIONS API', 2);
            END IF;
      END CALL_TAKE_ACTIONS;
   -- Name
   --    RAISE_UPDATE_EVENT
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
      END IF;
      IF (l_Debug_Level <= 1) THEN
              cln_debug_pub.Add('p_ref_id' || p_ref_id, 1);
              cln_debug_pub.Add('p_doc_no:' || p_doc_no, 1);
              cln_debug_pub.Add('p_status_code:' || p_status_code, 1);
              cln_debug_pub.Add('p_msg_text:' || p_msg_text, 1);
              cln_debug_pub.Add('p_part_doc_no:' || p_part_doc_no, 1);
              cln_debug_pub.Add('p_int_ctl_num:' || p_int_ctl_num, 1);
      END IF;
      IF p_status_code = 0 THEN
         l_doc_status := 'SUCCESS';
      -- ELSIF p_status_code = 1 THEN
      --    l_doc_status := 'ERROR';
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
         END IF;
         IF (l_Debug_Level <= 2) THEN
                 cln_debug_pub.Add('EXITING RAISE_UPDATE_COLLABORATION', 2);
         END IF;
   END RAISE_UPDATE_COLLABORATION;
   -- Name
   --    RAISE_ADD_MSG_EVENT
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
END CLN_PO_CHG_ORDER_STATUS;

/
