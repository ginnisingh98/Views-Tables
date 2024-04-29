--------------------------------------------------------
--  DDL for Package Body RCV_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRANSACTIONS_HISTORY_PKG" as
/* $Header: RCVTXHSB.pls 120.0.12010000.11 2010/04/13 11:23:19 smididud noship $ */

g_asn_debug       VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'RCV_TRANSACTIONS_HISTORY_PKG';
--

PROCEDURE Create_Update_Txns_History(
p_txns_history_rec     IN OUT NOCOPY  Txns_History_Record_Type,
P_xml_document_id      IN  NUMBER,
x_txns_id              OUT NOCOPY   NUMBER,
x_return_status        OUT NOCOPY   VARCHAR2
) IS

-- local variables
l_txns_id            NUMBER;
l_exist_check        NUMBER := 0;

l_transaction_id     NUMBER;
x_transaction_id     NUMBER;
l_transaction_status VARCHAR2(2);
l_trans_status       VARCHAR2(5);
l_msg_data           VARCHAR2(3000);
l_xml_document_id    NUMBER;
l_return_status      VARCHAR2(2);

--exceptions
invalid_status          exception;
invalid_action          exception;
invalid_entity_type     exception;
invalid_direction       exception;
invalid_document_type   exception;

--cursors
CURSOR txn_cur IS
SELECT transaction_id, transaction_status
FROM MTL_TXNS_HISTORY
WHERE        document_type = p_txns_history_rec.document_type  AND
             document_number = p_txns_history_rec.document_number  AND
             document_direction = p_txns_history_rec.document_direction  AND
        action_type = p_txns_history_rec.action_type  AND
        entity_number = p_txns_history_rec.entity_number  AND
        entity_type = p_txns_history_rec.entity_type  AND
        trading_partner_id = p_txns_history_rec.trading_partner_id AND
        event_name = p_txns_history_rec.event_name AND
        event_key = p_txns_history_rec.event_key AND
        transaction_status = 'IP'
FOR UPDATE NOWAIT;



BEGIN


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Entering Create_Update_Txns_History');
          asn_debug.put_line('Entity Type is '||p_txns_history_Rec.entity_type);
          asn_debug.put_line('Entity number is '||p_txns_history_Rec.entity_number);
          asn_debug.put_line('Transaction status is '||p_txns_history_Rec.transaction_status);
      END IF;

      x_return_status := rcv_error_pkg.g_ret_sts_success;
      l_xml_document_id := P_xml_document_id;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_xml_document_id is '|| to_char(l_xml_document_id));
      END IF;


        -- First check for null values
        IF (
             p_txns_history_rec.document_type IS NOT NULL AND
             p_txns_history_rec.document_number IS NOT NULL AND
             p_txns_history_rec.document_direction IS NOT NULL AND
             p_txns_history_rec.transaction_status IS NOT NULL AND
             p_txns_history_rec.entity_type IS NOT NULL AND
             p_txns_history_rec.entity_number IS NOT NULL AND
             p_txns_history_rec.action_type IS NOT NULL AND
             p_txns_history_rec.trading_partner_id IS NOT NULL
           ) THEN

                IF(p_txns_history_rec.document_type NOT IN('RC')) THEN
                        raise invalid_document_type;
                END IF;


                IF(p_txns_history_rec.document_direction NOT IN('I', 'O')) THEN
                        raise invalid_direction;
                END IF;


                IF(p_txns_history_rec.entity_type NOT IN('RCPT')) THEN
                        raise invalid_entity_type;
                END IF;

                IF(p_txns_history_rec.action_type NOT IN('A', 'D', 'C')) THEN
                        raise invalid_action;
                END IF;

                IF(p_txns_history_rec.transaction_status NOT IN('ST', 'IP', 'ER', 'SC', 'AP')) THEN
                        raise invalid_status;
                END IF;

                -- Check if a record already exists


                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Opening txn_cur');
                END IF;

                OPEN txn_cur;


                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Fetching txn_cur');
                END IF;



                FETCH txn_cur INTO l_transaction_id,l_transaction_status;

                IF (txn_cur%NOTFOUND) THEN

                        l_trans_status :=  p_txns_history_rec.transaction_status;

                        -- Record does not exist. So create a new record

                        -- Before Insert Check for validity of data
                        -- Need to validate document_direction, entity_type, action_type
                        -- ctd.. transaction_status, document_type


                        SELECT MTL_TXNS_HISTORY_S.nextval
                        INTO x_transaction_id
                        FROM dual;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Transaction ID is '|| x_transaction_id);
                            asn_debug.put_line('Inserting into MTL_TXNS_HISTORY');
                        END IF;


                        INSERT INTO MTL_TXNS_HISTORY(
                        TRANSACTION_ID,
                        DOCUMENT_TYPE,
                        DOCUMENT_NUMBER,
                        DOCUMENT_DIRECTION,
                        TRANSACTION_STATUS,
                        ACTION_TYPE,
                        ENTITY_NUMBER,
                        ENTITY_TYPE,
                        TRADING_PARTNER_ID,
                        EVENT_NAME,
                        EVENT_KEY,
                        ITEM_TYPE,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        DOCUMENT_REVISION,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        REQUEST_ID,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
			CLIENT_CODE)
                        VALUES( x_transaction_id,
                                p_txns_history_rec.document_type,
                                p_txns_history_rec.document_number,
                                p_txns_history_rec.document_direction,
                                -- k proj bmso p_txns_history_rec.transaction_status,
                                l_trans_status,
                                p_txns_history_rec.action_type,
                                p_txns_history_rec.entity_number,
                                p_txns_history_rec.entity_type,
                                p_txns_history_rec.trading_partner_id,
                                p_txns_history_rec.EVENT_NAME,
                                p_txns_history_rec.EVENT_KEY,
                                p_txns_history_rec.ITEM_TYPE,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                SYSDATE,
                                FND_GLOBAL.USER_ID,
                                FND_GLOBAL.USER_ID,
                                p_txns_history_rec.DOCUMENT_REVISION,
                                fnd_global.prog_appl_id,
                                fnd_global.conc_program_id,
                                SYSDATE,
                                fnd_global.conc_request_id,
                                p_txns_history_rec.ATTRIBUTE_CATEGORY,
                                p_txns_history_rec.ATTRIBUTE1,
                                p_txns_history_rec.ATTRIBUTE2,
                                p_txns_history_rec.ATTRIBUTE3,
                                p_txns_history_rec.ATTRIBUTE4,
                                p_txns_history_rec.ATTRIBUTE5,
                                p_txns_history_rec.ATTRIBUTE6,
                                p_txns_history_rec.ATTRIBUTE7,
                                p_txns_history_rec.ATTRIBUTE8,
                                p_txns_history_rec.ATTRIBUTE9,
                                p_txns_history_rec.ATTRIBUTE10,
                                p_txns_history_rec.ATTRIBUTE11,
                                p_txns_history_rec.ATTRIBUTE12,
                                p_txns_history_rec.ATTRIBUTE13,
                                p_txns_history_rec.ATTRIBUTE14,
                                p_txns_history_rec.ATTRIBUTE15,
				p_txns_history_rec.client_code);


                        x_txns_id := x_transaction_id;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Record inserted into MTL_TXNS_HISTORY');
                            asn_debug.put_line('x_transaction_id is '||x_transaction_id);
                        END IF;

                ELSE

                        IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('transaction_id is ' || l_transaction_id);
                        asn_debug.put_line('l_transaction_status is ' || l_transaction_status);
                        asn_debug.put_line('p_txns_history_rec.transaction_status is ' || p_txns_history_rec.transaction_status);
                        asn_debug.put_line('Record already exists. So need to update in MTL_TXNS_HISTORY');
                        END IF;

                        -- Record already exists. So Need to Update
                        -- Before Update Check for validity of status

                        IF(l_transaction_status in ('IP', 'AP') AND p_txns_history_rec.transaction_status NOT IN('ER','ST','IP')) THEN
                                raise invalid_status;

                        ELSIF(l_transaction_status = 'ER' AND p_txns_history_rec.transaction_status NOT IN('IP','ER','ST')) THEN
                                raise invalid_status;

                        END IF; -- if l_transaction_status checks

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Updating MTL_TXNS_HISTORY');
                        END IF;


                        UPDATE MTL_TXNS_HISTORY
                        SET        entity_number            = p_txns_history_rec.entity_number,
                                entity_type                   = p_txns_history_rec.entity_type,
                                transaction_status      = p_txns_history_rec.transaction_status,
                                event_name                    = p_txns_history_rec.event_name,
                                event_key               = p_txns_history_rec.event_key,
                                item_type                = p_txns_history_rec.item_type,
                                last_update_date        = SYSDATE,
                                last_updated_by         = fnd_global.user_id,
                                program_application_id  = fnd_global.prog_appl_id,
                                program_id              = fnd_global.conc_program_id,
                                program_update_date     = SYSDATE,
                                request_id              = fnd_global.conc_request_id,
                                attribute_category      = p_txns_history_rec.ATTRIBUTE_CATEGORY,
                                attribute1                 = p_txns_history_rec.ATTRIBUTE1,
                                attribute2                = p_txns_history_rec.ATTRIBUTE2,
                                attribute3                = p_txns_history_rec.ATTRIBUTE3,
                                attribute4                = p_txns_history_rec.ATTRIBUTE4,
                                attribute5                = p_txns_history_rec.ATTRIBUTE5,
                                attribute6                = p_txns_history_rec.ATTRIBUTE6,
                                attribute7                = p_txns_history_rec.ATTRIBUTE7,
                                attribute8                = p_txns_history_rec.ATTRIBUTE8,
                                attribute9                = p_txns_history_rec.ATTRIBUTE9,
                                attribute10                = p_txns_history_rec.ATTRIBUTE10,
                                attribute11                = p_txns_history_rec.ATTRIBUTE11,
                                attribute12                = p_txns_history_rec.ATTRIBUTE12,
                                attribute13                = p_txns_history_rec.ATTRIBUTE13,
                                attribute14                = p_txns_history_rec.ATTRIBUTE14,
                                attribute15                = p_txns_history_rec.ATTRIBUTE15
                        WHERE transaction_id = l_transaction_id;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('MTL_TXNS_HISTORY record updated');
                        END IF;


                 IF  (l_xml_document_id is null) THEN

                          IF (p_txns_history_rec.client_code is not null) THEN

                            IF (g_asn_debug = 'Y') THEN
                                asn_debug.put_line('LSP : Updating RT.receipt_confirmation_extracted to Y');
                            END IF;

                            UPDATE rcv_transactions rt
                            SET rt.receipt_confirmation_extracted  = 'Y',
                                rt.xml_document_id = p_txns_history_rec.document_number
                            WHERE rt.shipment_header_id = p_txns_history_rec.document_number
                            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'P'
                            AND xml_document_id is null
                            AND (rt.TRANSACTION_TYPE = 'DELIVER' OR
                                       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                                        AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                                    WHERE rt.parent_transaction_id = rt2.transaction_id
                                                    AND rt2.transaction_type = 'DELIVER')
                                       )  OR
                                       (rt.TRANSACTION_TYPE IN ('CORRECT')
                                        AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                                    WHERE rt.parent_transaction_id = rt3.transaction_id
                                                    AND rt3.transaction_type = 'RETURN TO RECEIVING')
                                       )
                               )
                            AND EXISTS (SELECT '1' FROM rcv_shipment_lines rsl
                                        WHERE rsl.shipment_line_id = rt.shipment_line_id
                                        AND wms_deploy.get_client_code(rsl.item_id) =  p_txns_history_rec.client_code);

                        ELSE

                            IF (g_asn_debug = 'Y') THEN
                               asn_debug.put_line('Distributed : Updating RT.receipt_confirmation_extracted to Y');
                            END IF;


                            UPDATE rcv_transactions rt
                            SET rt.receipt_confirmation_extracted  = 'Y',
                                rt.xml_document_id = p_txns_history_rec.document_number
                            WHERE rt.shipment_header_id = p_txns_history_rec.document_number
                            AND nvl(rt.receipt_confirmation_extracted, 'N') = 'P'
                            and xml_document_id is null
                            AND (rt.TRANSACTION_TYPE = 'DELIVER' OR
                                       (rt.TRANSACTION_TYPE IN ('CORRECT', 'RETURN TO RECEIVING')
                                        AND EXISTS (SELECT '1' FROM rcv_transactions rt2
                                                    WHERE rt.parent_transaction_id = rt2.transaction_id
                                                    AND rt2.transaction_type = 'DELIVER')
                                       ) OR
                                       (rt.TRANSACTION_TYPE IN ('CORRECT')
                                        AND EXISTS (SELECT '1' FROM rcv_transactions rt3
                                                    WHERE rt.parent_transaction_id = rt3.transaction_id
                                                    AND rt3.transaction_type = 'RETURN TO RECEIVING')
                                       )
                               );


                        END IF;

                 END IF;


                END IF; -- if txn_cur%notfound


                IF(txn_cur%ISOPEN) THEN
                        CLOSE txn_cur;

                        IF (g_asn_debug = 'Y') THEN
                            asn_debug.put_line('Closing txn_cur');
                        END IF;

                END IF;
        ELSE

                -- Not Null checks failed. Return Error
                x_return_status := rcv_error_pkg.g_ret_sts_error;

        END IF; -- if p_txns_history_rec columns are not null

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Exiting Create_Update_Txns_History call');
        END IF;

EXCEPTION
        WHEN invalid_status THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('invalid_status exception has occured.');
                END IF;
        WHEN invalid_action THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('invalid_action exception has occured.');
                END IF;
        WHEN invalid_entity_type THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('invalid_entity_type exception has occured.');
                END IF;
        WHEN invalid_direction THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('invalid_direction exception has occured.');
                END IF;
        WHEN invalid_document_type THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('invalid_document_type exception has occured.');
                END IF;
        WHEN Others THEN
                x_return_status := rcv_error_pkg.g_ret_sts_error;
                IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
                END IF;

END Create_Update_Txns_History;


PROCEDURE Get_Txns_History(
p_item_type          IN  VARCHAR2,
p_event_key          IN  VARCHAR2,
p_direction          IN  VARCHAR2,
p_document_type      IN  VARCHAR2,
p_txns_history_rec   OUT NOCOPY  Txns_History_Record_Type,
x_return_status      OUT NOCOPY  VARCHAR2
) IS

CURSOR txns_history_cur IS
SELECT wth.transaction_id,
        wth.document_type,
        wth.document_direction,
        wth.document_number,
        wth.entity_number,
        wth.entity_type,
        wth.trading_partner_id,
        wth.action_type,
        wth.transaction_status,
        wth.event_name,
        wth.event_key ,
        wth.item_type,
        wth.document_revision,
        wth.attribute_category,
        wth.attribute1,
        wth.attribute2,
        wth.attribute3,
        wth.attribute4,
        wth.attribute5,
        wth.attribute6,
        wth.attribute7,
        wth.attribute8,
        wth.attribute9,
        wth.attribute10,
        wth.attribute11,
        wth.attribute12,
        wth.attribute13,
        wth.attribute14,
        wth.attribute15,
        wth.client_code
FROM MTL_TXNS_HISTORY wth
WHERE wth.item_type         = p_item_type
and wth.event_key                = p_event_key
and wth.document_direction         = p_direction
and wth.document_type        = p_document_type
and rownum = 1;

--exceptions
no_record_found exception;

BEGIN

       IF (g_asn_debug = 'Y') THEN
           asn_debug.put_line('Entering Get_Txns_History');
       END IF;

        x_return_status := rcv_error_pkg.g_ret_sts_success;

        OPEN txns_history_cur;
        FETCH txns_history_cur INTO p_txns_history_rec;

        IF(txns_history_cur%NOTFOUND) THEN
                raise no_record_found;
        END IF;

        CLOSE txns_history_cur;

  IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('Exiting Get_Txns_History');
  END IF;

EXCEPTION
WHEN no_record_found THEN

        IF(txns_history_cur%ISOPEN) THEN
                CLOSE txns_history_cur;
        END IF;

        x_return_status := rcv_error_pkg.g_ret_sts_error;
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('no_record_found exception has occured.');
        END IF;

WHEN Others THEN
        x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;
        IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Unexpected error has occured. Oracle error message is '|| SQLERRM);
        END IF;
END Get_Txns_History;

END RCV_TRANSACTIONS_HISTORY_PKG;

/
