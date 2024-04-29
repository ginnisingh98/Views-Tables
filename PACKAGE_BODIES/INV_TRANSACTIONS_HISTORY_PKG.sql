--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTIONS_HISTORY_PKG" as
/* $Header: INVTXHSB.pls 120.0.12010000.5 2010/04/09 21:00:41 kdong noship $ */

g_debug      NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'INV_TRANSACTIONS_HISTORY_PKG';
--

PROCEDURE Create_Update_Txns_History(
p_txns_history_rec	IN OUT NOCOPY  Txns_History_Record_Type,
P_xml_document_id       IN  NUMBER,
x_txns_id		OUT NOCOPY 	NUMBER,
x_return_status		OUT NOCOPY 	VARCHAR2
) IS

-- local variables
l_txns_id 		NUMBER;
l_exist_check 		NUMBER := 0;

l_transaction_id	NUMBER;
x_transaction_id 	NUMBER;
l_transaction_status 	VARCHAR2(2);
l_trans_status       VARCHAR2(5);
l_msg_data           VARCHAR2(3000);
l_xml_document_id    NUMBER;
l_return_status      VARCHAR2(2);
l_dummy              NUMBER := 0;

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
WHERE	document_type = p_txns_history_rec.document_type  AND
     	document_number = p_txns_history_rec.document_number  AND
     	document_direction = p_txns_history_rec.document_direction  AND
	action_type = p_txns_history_rec.action_type  AND
	entity_number = p_txns_history_rec.entity_number  AND
	entity_type = p_txns_history_rec.entity_type  AND
	trading_partner_id = p_txns_history_rec.trading_partner_id AND
        transaction_status = 'IP'
FOR UPDATE NOWAIT;
     --k proj bmso

l_status_code  VARCHAR2(5);
l_number_of_warnings    NUMBER := 0;
l_number_of_errors      NUMBER := 0;

BEGIN

      if (g_debug = 1) then
        inv_trx_util_pub.TRACE('Entering Create_Update_Txns_History', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        inv_trx_util_pub.TRACE('Entity Type is '||p_txns_history_Rec.entity_type, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        inv_trx_util_pub.TRACE('Entity number is '||p_txns_history_Rec.entity_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        inv_trx_util_pub.TRACE('Transaction status is '||p_txns_history_Rec.transaction_status, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
      end if;

      x_return_status := rcv_error_pkg.g_ret_sts_success;
      l_xml_document_id := P_xml_document_id;

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


		IF(p_txns_history_rec.document_type NOT IN('ADJ','ONHAND')) THEN
			raise invalid_document_type;
		END IF;

		IF(p_txns_history_rec.document_direction NOT IN('I', 'O')) THEN
			raise invalid_direction;
		END IF;

		IF(p_txns_history_rec.entity_type NOT IN('INVADJ','INVMOQD')) THEN
			raise invalid_entity_type;
		END IF;

		IF(p_txns_history_rec.action_type NOT IN('A', 'D', 'C')) THEN
			raise invalid_action;
		END IF;

		IF(p_txns_history_rec.transaction_status NOT IN('ST', 'IP', 'ER', 'SC', 'AP')) THEN
			raise invalid_status;
		END IF;

		-- Check if a record already exists

                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('Opening txn_cur', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;

                OPEN txn_cur;

                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('Fetching txn_cur', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;

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

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('Transaction ID is '|| x_transaction_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                           inv_trx_util_pub.TRACE('Inserting into MTL_TXNS_HISTORY', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

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
			ECX_MESSAGE_ID,
			EVENT_NAME,
			EVENT_KEY,
			ITEM_TYPE,
			INTERNAL_CONTROL_NUMBER,
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
			ATTRIBUTE15)
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
				p_txns_history_rec.ECX_MESSAGE_ID,
				p_txns_history_rec.EVENT_NAME,
				p_txns_history_rec.EVENT_KEY,
				p_txns_history_rec.ITEM_TYPE,
				p_txns_history_rec.INTERNAL_CONTROL_NUMBER,
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
				p_txns_history_rec.ATTRIBUTE15);


                        x_txns_id := x_transaction_id;

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('Record inserted into MTL_TXNS_HISTORY', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                           inv_trx_util_pub.TRACE('x_transaction_id is '||x_transaction_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

		ELSE

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('transaction_id is ' || l_transaction_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                           inv_trx_util_pub.TRACE('l_transaction_status is ' || l_transaction_status, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                           inv_trx_util_pub.TRACE('p_txns_history_rec.transaction_status is ' || p_txns_history_rec.transaction_status, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                           inv_trx_util_pub.TRACE('Record already exists. So need to update in MTL_TXNS_HISTORY', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

			-- Record already exists. So Need to Update
			-- Before Update Check for validity of status

			IF(l_transaction_status in ('IP', 'AP') AND p_txns_history_rec.transaction_status NOT IN('ER', 'ST','IP')) THEN
				raise invalid_status;

			ELSIF(l_transaction_status = 'ER' AND p_txns_history_rec.transaction_status NOT IN('IP','ER')) THEN
				raise invalid_status;

			END IF; -- if l_transaction_status checks

                        if (g_debug = 1) then
                          inv_trx_util_pub.TRACE('Updating MTL_XML_TXNS_HISTORY', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

			UPDATE MTL_TXNS_HISTORY
			SET	entity_number    	= p_txns_history_rec.entity_number,
				entity_type   	        = p_txns_history_rec.entity_type,
				transaction_status      = p_txns_history_rec.transaction_status,
				ecx_message_id 	        = p_txns_history_rec.ecx_message_id,
				event_name    	        = p_txns_history_rec.event_name,
				event_key       	= p_txns_history_rec.event_key,
				internal_control_number = p_txns_history_rec.internal_control_number,
				item_type	        = p_txns_history_rec.item_type,
				last_update_date        = SYSDATE,
				last_updated_by         = fnd_global.user_id,
				program_application_id  = fnd_global.prog_appl_id,
				program_id              = fnd_global.conc_program_id,
				program_update_date     = SYSDATE,
				request_id              = fnd_global.conc_request_id,
				attribute_category      = p_txns_history_rec.ATTRIBUTE_CATEGORY,
				attribute1 	        = p_txns_history_rec.ATTRIBUTE1,
				attribute2	        = p_txns_history_rec.ATTRIBUTE2,
				attribute3	        = p_txns_history_rec.ATTRIBUTE3,
				attribute4	        = p_txns_history_rec.ATTRIBUTE4,
				attribute5	        = p_txns_history_rec.ATTRIBUTE5,
				attribute6	        = p_txns_history_rec.ATTRIBUTE6,
				attribute7	        = p_txns_history_rec.ATTRIBUTE7,
				attribute8	        = p_txns_history_rec.ATTRIBUTE8,
				attribute9	        = p_txns_history_rec.ATTRIBUTE9,
				attribute10	        = p_txns_history_rec.ATTRIBUTE10,
				attribute11	        = p_txns_history_rec.ATTRIBUTE11,
				attribute12	        = p_txns_history_rec.ATTRIBUTE12,
				attribute13	        = p_txns_history_rec.ATTRIBUTE13,
				attribute14	        = p_txns_history_rec.ATTRIBUTE14,
				attribute15	        = p_txns_history_rec.ATTRIBUTE15
			WHERE transaction_id = l_transaction_id;

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('MTL_TXNS_HISTORY record updated', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

                        if p_txns_history_rec.document_type ='ADJ' then --added for onhand
                        select count(*)
                        into l_dummy
                        from mtl_adjustment_sync_temp
                        where entity_id = p_txns_history_rec.entity_number;

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('temp table count: '||l_dummy, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

                        UPDATE mtl_material_transactions
                           SET transaction_extracted = 'Y',
                               xml_document_id = p_txns_history_rec.entity_number
                         WHERE NVL(transaction_extracted, 'N') = 'P'
                           AND xml_document_id is null
                           AND transaction_id IN (select transaction_number
                                                    from mtl_adjustment_sync_temp
                                                   where entity_id = p_txns_history_rec.entity_number);

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('No of rows in MMT updated: '||SQL%ROWCOUNT, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('MMT updated, now delete the temp table', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

                        INV_INVENTORY_ADJUSTMENT.delete_temp_table(p_txns_history_rec.entity_number);

                        end if; --added for onhand
		END IF; -- if txn_cur%notfound

		IF(txn_cur%ISOPEN) THEN
			CLOSE txn_cur;

                        if (g_debug = 1) then
                           inv_trx_util_pub.TRACE('Closing txn_cur', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                        end if;

		END IF;
	ELSE

		-- Not Null checks failed. Return Error
		x_return_status := rcv_error_pkg.g_ret_sts_error;

	END IF; -- if p_txns_history_rec columns are not null

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Exiting Create_Update_Txns_History', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

EXCEPTION
	WHEN invalid_status THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('invalid_status exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;
	WHEN invalid_action THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('invalid_action exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;
	WHEN invalid_entity_type THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('invalid_entity_type exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;
	WHEN invalid_direction THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('invalid_direction exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;
	WHEN invalid_document_type THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('invalid_document_type exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;
	WHEN Others THEN
		x_return_status := rcv_error_pkg.g_ret_sts_error;
                if (g_debug = 1) then
                  inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
                end if;

END Create_Update_Txns_History;


PROCEDURE Get_Txns_History(
p_item_type		IN	VARCHAR2,
p_event_key		IN	VARCHAR2,
p_direction		IN	VARCHAR2,
p_document_type		IN	VARCHAR2,
p_txns_history_rec	OUT NOCOPY 	Txns_History_Record_Type,
x_return_status		OUT NOCOPY 	VARCHAR2
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
	wth.ecx_message_id,
	wth.event_name,
	wth.event_key ,
	wth.item_type,
	wth.internal_control_number,
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
        ''
FROM MTL_TXNS_HISTORY wth
WHERE wth.item_type 	= p_item_type
and wth.event_key		= p_event_key
and wth.document_direction 	= p_direction
and wth.document_type	= p_document_type
and rownum = 1;

--exceptions
no_record_found exception;


BEGIN

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Entering Get_Txns_History', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

	x_return_status := rcv_error_pkg.g_ret_sts_success;

	OPEN txns_history_cur;
	FETCH txns_history_cur INTO p_txns_history_rec;

	IF(txns_history_cur%NOTFOUND) THEN
		raise no_record_found;
	END IF;

	CLOSE txns_history_cur;

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Exiting Get_Txns_History', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

EXCEPTION
WHEN no_record_found THEN

	IF(txns_history_cur%ISOPEN) THEN
		CLOSE txns_history_cur;
	END IF;

	x_return_status := rcv_error_pkg.g_ret_sts_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('no_record_found exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

WHEN Others THEN
	x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;
END Get_Txns_History;

/* should be deleted, if not needed.
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Txns_History
   PARAMETERS :
  DESCRIPTION : This procedure is written for use by the inbound mapping.
Since XML gateway does not support calls to procedures with record types as
parameters, we need this wrapper. This takes in the individual columns,
creates a txns-history record and calls the create_update_txns_history
procedure with that record
-----------------------------------------------------------------------------

PROCEDURE Create_Txns_History(
	p_transaction_id	IN	NUMBER,
	p_document_type		IN	VARCHAR2,
	p_document_direction 	IN	VARCHAR2,
	p_document_number 	IN	VARCHAR2,
	p_orig_document_number 	IN	VARCHAR2,
	p_entity_number		IN	VARCHAR2,
	p_entity_type		IN 	VARCHAR2,
	p_trading_partner_id 	IN	NUMBER,
	p_action_type 		IN	VARCHAR2,
	p_transaction_status 	IN	VARCHAR2,
	p_ecx_message_id	IN	VARCHAR2,
	p_event_name  		IN	VARCHAR2,
	p_event_key 		IN	VARCHAR2,
	p_item_type		IN	VARCHAR2,
	p_internal_control_number IN	VARCHAR2,
	p_document_revision     IN     NUMBER DEFAULT NULL,
	x_return_status		OUT NOCOPY 	VARCHAR2) IS

	l_txn_hist_rec 		Txns_History_Record_Type;
	l_return_status 	VARCHAR2(30);
	l_txn_id 		NUMBER;

	create_update_failed	exception;

BEGIN

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Entering Create_Txns_History', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Transaction ID is '||p_transaction_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('document Type is '||p_document_type, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Doc Direction is '||p_document_direction, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Doc number is '||p_document_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Orig doc num is '||p_orig_document_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Entity Type is '||p_entity_type, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Entity number is '||p_entity_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Trading Partner id is '||p_trading_partner_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Action type is '||p_action_type, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Transaction status is '||p_transaction_status, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('ECX Message ID is '||p_ecx_message_id, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Event Name is '||p_event_name, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Event Key is '||p_event_key, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Item Type is '||p_item_type, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('In. control num is '||p_internal_control_number, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
           inv_trx_util_pub.TRACE('Document Revision is '||p_document_revision, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

	x_return_status := rcv_error_pkg.g_ret_sts_success;

	l_txn_hist_rec.transaction_id 	:= p_transaction_id;
	l_txn_hist_rec.document_type	:= p_document_type;
	l_txn_hist_rec.document_direction := p_document_direction;
	l_txn_hist_rec.document_number	:= p_document_number;
	l_txn_hist_rec.orig_document_number := p_orig_document_number;
	l_txn_hist_rec.entity_number 	:= p_entity_number;
	l_txn_hist_rec.entity_type	:= p_entity_type;
	l_txn_hist_rec.trading_partner_id := p_trading_partner_id;
	l_txn_hist_rec.action_type	:= p_action_type;
	l_txn_hist_rec.transaction_status := p_transaction_status;
	l_txn_hist_rec.ecx_message_id	:= p_ecx_message_id;
	l_txn_hist_rec.event_name	:= p_event_name;
	l_txn_hist_rec.event_key	:= p_event_key;
	l_txn_hist_rec.item_type	:= p_item_type;
	l_txn_hist_rec.internal_control_number := p_internal_control_number;

	l_txn_hist_rec.document_revision := p_document_revision;

	Create_Update_Txns_History(
	p_txns_history_rec	=> l_txn_hist_rec,
	x_txns_id		=> l_txn_id,
	x_return_status		=> l_return_status);

        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('l_return_status is '||l_return_status, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;

	IF(l_return_status <> rcv_error_pkg.g_ret_sts_success) THEN
		raise create_update_failed;
	END IF;

EXCEPTION
WHEN create_update_failed THEN
	x_return_status := rcv_error_pkg.g_ret_sts_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('create_update_failed exception has occured.', 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;
WHEN Others THEN
        x_return_status := rcv_error_pkg.g_ret_sts_unexp_error;
        if (g_debug = 1) then
           inv_trx_util_pub.TRACE('Unexpected error has occured. Oracle error message is '|| SQLERRM, 'INV_TRANSACTIONS_HISTORY_PKG', 9);
        end if;
END Create_Txns_History;

*/

END INV_TRANSACTIONS_HISTORY_PKG;

/
