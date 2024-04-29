--------------------------------------------------------
--  DDL for Package Body WSH_TRANSACTIONS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRANSACTIONS_HISTORY_PKG" as
/* $Header: WSHTXHSB.pls 120.1.12010000.3 2009/12/03 10:27:26 mvudugul ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRANSACTIONS_HISTORY_PKG';
--

PROCEDURE Create_Update_Txns_History(
p_txns_history_rec	IN OUT NOCOPY  Txns_History_Record_Type,
x_txns_id		OUT NOCOPY 	NUMBER,
x_return_status		OUT NOCOPY 	VARCHAR2
) IS

-- local variables
l_txns_id 		NUMBER;
l_exist_check 		NUMBER := 0;

l_transaction_id	NUMBER;
x_transaction_id 	NUMBER;
l_transaction_status 	VARCHAR2(2);

--exceptions
invalid_status 		exception;
invalid_action 		exception;
invalid_entity_type 	exception;
invalid_direction 	exception;
invalid_document_type 	exception;

--cursors
CURSOR txn_cur IS
SELECT transaction_id, transaction_status
FROM wsh_transactions_history
WHERE	document_type = p_txns_history_rec.document_type  AND
     	document_number = p_txns_history_rec.document_number  AND
     	document_direction = p_txns_history_rec.document_direction  AND
	action_type = p_txns_history_rec.action_type  AND
	entity_number = p_txns_history_rec.entity_number  AND
	entity_type = p_txns_history_rec.entity_type  AND
	trading_partner_id = p_txns_history_rec.trading_partner_id
FOR UPDATE NOWAIT;
     --k proj bmso

     l_status_code  VARCHAR2(5);
     l_trans_status  VARCHAR2(5);
     l_loc_interface_error_rec WSH_INTERFACE_VALIDATIONS_PKG.interface_errors_rec_type;
     l_msg_data              VARCHAR2(3000);
     l_number_of_warnings    NUMBER := 0;
     l_number_of_errors      NUMBER := 0;
     l_return_status         VARCHAR2(2);

     CURSOR c_get_del_status (v_doc_number varchar2) IS
     SELECT wnd.status_code
     FROM   wsh_new_deliveries wnd,
            wsh_transactions_history wth
     WHERE  wth.document_number = v_doc_number
     AND wth.entity_type = 'DLVY'
     AND wth.document_type = 'SR'
     AND wth.document_direction = 'O'
     AND wth.action_type = 'A'
     AND wth.entity_number = wnd.name
     ORDER BY wth.transaction_id desc;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_UPDATE_TXNS_HISTORY';
--
BEGIN
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
	wsh_debug_sv.push(l_module_name,'Create_Update_Txns_History');
	wsh_debug_sv.log (l_module_name, 'Transaction ID', p_txns_history_Rec.transaction_id);
	wsh_debug_sv.log (l_module_name, 'document Type', p_txns_history_rec.document_type);
	wsh_debug_sv.log (l_module_name, 'Doc Direction', p_txns_history_Rec.document_direction);
	wsh_debug_sv.log (l_module_name, 'Doc number', p_txns_history_Rec.document_number);
	wsh_debug_sv.log (l_module_name, 'Orig doc num', p_txns_history_Rec.orig_document_number);
	wsh_debug_sv.log (l_module_name, 'Entity Type', p_txns_history_Rec.entity_type);
	wsh_debug_sv.log (l_module_name, 'Entity number', p_txns_history_Rec.entity_number);
	wsh_debug_sv.log (l_module_name, 'TP id', p_txns_history_Rec.trading_partner_id);
	wsh_debug_sv.log (l_module_name, 'Action type', p_txns_history_Rec.action_type);
	wsh_debug_sv.log (l_module_name, 'Transaction status', p_txns_history_Rec.transaction_status);
	wsh_debug_sv.log (l_module_name, 'ECX Message ID', p_txns_history_Rec.ecx_message_id);
	wsh_debug_sv.log (l_module_name, 'Event Name', p_txns_history_Rec.event_name);
	wsh_debug_sv.log (l_module_name, 'Event Key', p_txns_history_Rec.event_key);
	wsh_debug_sv.log (l_module_name, 'Item Type', p_txns_history_Rec.item_type);
	wsh_debug_sv.log (l_module_name, 'In. control num', p_txns_history_Rec.internal_control_number);
        --R12.1.1 STANDALONE PROJECT
	wsh_debug_sv.log (l_module_name, 'Doc Revision', p_txns_history_Rec.document_revision);
     END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

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

		-- validate the values
		--Added Document Type SS for ShipScreening for ITM -AJPRABHA
		IF(p_txns_history_rec.document_type NOT IN('SR', 'SA', 'SS')) THEN
			raise invalid_document_type;
		END IF;

		IF(p_txns_history_rec.document_direction NOT IN('I', 'O')) THEN
			raise invalid_direction;
		END IF;
                --R12.1.1 STANDALONE PROJECT
		IF(p_txns_history_rec.entity_type NOT IN('DLVY', 'DLVY_INT', 'ORDER')) THEN
			raise invalid_entity_type;
		END IF;
                --R12.1.1 STANDALONE PROJECT
		IF(p_txns_history_rec.action_type NOT IN('A', 'D', 'C')) THEN
			raise invalid_action;
		END IF;
                --R12.1.1 STANDALONE PROJECT
		IF(p_txns_history_rec.transaction_status NOT IN('ST', 'IP', 'ER', 'SC', 'AP')) THEN
			raise invalid_status;
		END IF;

		-- Check if a record already exists

		OPEN txn_cur;

		FETCH txn_cur INTO l_transaction_id,l_transaction_status;

		IF (txn_cur%NOTFOUND) THEN
                    IF l_debug_on THEN
	             wsh_debug_sv.log (l_module_name,'Record does not exist.
                                        So create a new record in wsh_transactions_history');
	             wsh_debug_sv.log (l_module_name,'document_direction ',
                                      p_txns_history_rec.document_direction);
	             wsh_debug_sv.log (l_module_name,'document_type ',
                                      p_txns_history_rec.document_type);
	             wsh_debug_sv.log (l_module_name,'entity_number ',
                                      p_txns_history_rec.entity_number);
                    END IF;
                    --bmso k proj
                        l_trans_status :=
                                     p_txns_history_rec.transaction_status;
                        IF p_txns_history_rec.document_type = 'SA'
                          AND p_txns_history_rec.document_direction = 'I'
                        THEN --{
                           --
                           OPEN c_get_del_status(to_number(p_txns_history_rec.orig_document_number));
                           FETCH c_get_del_status INTO l_status_code;
                           CLOSE c_get_del_status;
                           --
                           IF l_debug_on THEN
	                      wsh_debug_sv.log (l_module_name,
                                       'entity_number ',
                                          p_txns_history_rec.entity_number);
	                      wsh_debug_sv.log (l_module_name,
                                       'l_status_code ', l_status_code);
                           END IF;
                           --
                           IF l_status_code NOT IN ('SC','SR') THEN --{

                             -- the delivery has been unlocked , set the status
                             -- to error and insert an error message.

                             l_trans_status := 'SX';
                             l_loc_interface_error_rec.p_interface_table_name
                                                   := 'WSH_NEW_DEL_INTERFACE';
                             l_loc_interface_error_rec.p_interface_id :=
                                   to_number(p_txns_history_rec.entity_number);
                             l_msg_data :=  FND_MESSAGE.GET_STRING('WSH',
                                    'WSH_DEL_OPEN');

                             WSH_INTERFACE_VALIDATIONS_PKG.Log_Interface_Errors(
                                   p_interface_errors_rec   =>
                                                   l_loc_interface_error_rec,
                                   p_msg_data      => l_msg_data,
                                   p_api_name      => 'WSH_TRANSACTIONS_HISTORY_PKG.Create_Update_Txns_History',
                                   x_return_status => l_return_status);

                             wsh_util_core.api_post_call(
                                  p_return_status => l_return_status,
                                  x_num_warnings       => l_number_of_warnings,
                                  x_num_errors         => l_number_of_errors);

                           END IF; --}
                           --
                        END IF; --}
			-- Record does not exist. So create a new record

			-- Before Insert Check for validity of data
			-- Need to validate document_direction, entity_type, action_type
			-- ctd.. transaction_status, document_type

			SELECT WSH_TRANSACTION_S.nextval
			INTO x_transaction_id
			FROM dual;

			INSERT INTO wsh_transactions_history(
			TRANSACTION_ID,
			DOCUMENT_TYPE,
			DOCUMENT_NUMBER,
			ORIG_DOCUMENT_NUMBER,
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
                        --R12.1.1 STANDALONE PROJECT
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
				p_txns_history_rec.orig_document_number,
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
                                --R12.1.1 STANDALONE PROJECT
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

		ELSE
                    IF l_debug_on THEN
	             wsh_debug_sv.log (l_module_name,'Record already exists. So Need to Update in wsh_transactions_history');
                    END IF;
			-- Record already exists. So Need to Update
			-- Before Update Check for validity of status

			IF(l_transaction_status = 'ST' AND p_txns_history_rec.transaction_status <> 'SC') THEN

				raise invalid_status;
                        -- R12.1.1 STANDALONE PROJECT
			ELSIF(l_transaction_status in ('IP', 'AP') AND p_txns_history_rec.transaction_status NOT IN('ER', 'SC', 'ST')) THEN
				raise invalid_status;

			ELSIF(l_transaction_status = 'ER' AND p_txns_history_rec.transaction_status NOT IN('IP','ER', 'SC')) THEN
				raise invalid_status;
			ELSIF(l_transaction_status = 'SC') THEN
				raise invalid_status;

			END IF; -- if l_transaction_status checks


			UPDATE wsh_transactions_history
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
                                --R12.1.1 STANDALONE PROJECT
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


		END IF; -- if txn_cur%notfound

		IF(txn_cur%ISOPEN) THEN
			CLOSE txn_cur;
		END IF;
	ELSE

		-- Not Null checks failed. Return Error
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;

	END IF; -- if p_txns_history_rec columns are not null

        IF l_debug_on THEN
	 wsh_debug_sv.pop(l_module_name);
        END IF;
EXCEPTION
	WHEN invalid_status THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'invalid_status exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_status');
                END IF;
	WHEN invalid_action THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'invalid_action exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_action');
                END IF;
	WHEN invalid_entity_type THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'invalid_entity_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_entity_type');
                END IF;
	WHEN invalid_direction THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'invalid_direction exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_direction');
                END IF;
	WHEN invalid_document_type THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'invalid_document_type exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:invalid_document_type');
                END IF;
	WHEN Others THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                IF l_debug_on THEN
                 WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
                 WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
                END IF;

END Create_Update_Txns_History;


PROCEDURE Get_Txns_History(
p_item_type		IN	VARCHAR2,
p_event_key		IN	VARCHAR2,
p_direction		IN	VARCHAR2,
p_document_type		IN	VARCHAR2,
p_txns_history_rec	OUT NOCOPY 	Txns_History_Record_Type,
x_return_status		OUT NOCOPY 	VARCHAR2
) IS
-- LSP PROJECT : Added wndi table to get client_code
CURSOR txns_history_cur IS
SELECT wth.transaction_id,
	wth.document_type,
	wth.document_direction,
	wth.document_number,
	wth.orig_document_number,
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
        --R12.1.1 STANDALONE PROJECT
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
        wndi.client_code
FROM wsh_transactions_history wth,
     wsh_new_del_interface wndi
WHERE wth.item_type 	= p_item_type
and wth.event_key		= p_event_key
and wth.document_direction 	= p_direction
and wth.document_type	= p_document_type
and wth.entity_number = wndi.delivery_interface_id (+);

--exceptions
no_record_found exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'GET_TXNS_HISTORY';
--
BEGIN
       --
       l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
       --
       IF l_debug_on IS NULL
       THEN
           l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
       END IF;
       --
       IF l_debug_on THEN
	wsh_debug_sv.push(l_module_name,'Get_Txns_History');
	wsh_debug_sv.log (l_module_name, 'Item Type', p_item_type);
	wsh_debug_sv.log (l_module_name, 'Event Key', p_event_key);
	wsh_debug_sv.log (l_module_name, 'Direction' , p_direction);
	wsh_debug_sv.log (l_module_name, 'Document Type', p_document_type);
       END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	OPEN txns_history_cur;
	FETCH txns_history_cur INTO p_txns_history_rec;

	IF(txns_history_cur%NOTFOUND) THEN
		raise no_record_found;
	END IF;

	CLOSE txns_history_cur;

       IF l_debug_on THEN
	wsh_debug_sv.pop(l_module_name);
       END IF;

EXCEPTION
WHEN no_record_found THEN

	IF(txns_history_cur%ISOPEN) THEN
		CLOSE txns_history_cur;
	END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'RECORD_LOCKED exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:RECORD_LOCKED');
        END IF;
WHEN Others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
         WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,
                                                                          WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
         WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
        END IF;
END Get_Txns_History;

/*
-----------------------------------------------------------------------------
   PROCEDURE  : Create_Txns_History
   PARAMETERS :
  DESCRIPTION : This procedure is written for use by the inbound mapping.
Since XML gateway does not support calls to procedures with record types as
parameters, we need this wrapper. This takes in the individual columns,
creates a txns-history record and calls the create_update_txns_history
procedure with that record
-----------------------------------------------------------------------------
*/
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
        --R12.1.1 STANDALONE PROJECT
        p_document_revision     IN     NUMBER DEFAULT NULL,
	x_return_status		OUT NOCOPY 	VARCHAR2) IS

l_txn_hist_rec 		Txns_History_Record_Type;
l_return_status 	VARCHAR2(30);
l_txn_id 		NUMBER;

create_update_failed	exception;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_TXNS_HISTORY';
--
BEGIN
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
        IF l_debug_on THEN
	 wsh_debug_sv.push(l_module_name,'Get_Txns_History');
	 wsh_debug_sv.log (l_module_name, 'Transaction ID', p_transaction_id);
	 wsh_debug_sv.log (l_module_name, 'document Type', p_document_type);
	 wsh_debug_sv.log (l_module_name, 'Doc Direction', p_document_direction);
	 wsh_debug_sv.log (l_module_name, 'Doc number', p_document_number);
	 wsh_debug_sv.log (l_module_name, 'Orig doc num', p_orig_document_number);
	 wsh_debug_sv.log (l_module_name, 'Entity Type', p_entity_type);
	 wsh_debug_sv.log (l_module_name, 'Entity number', p_entity_number);
	 wsh_debug_sv.log (l_module_name, 'TP id', p_trading_partner_id);
	 wsh_debug_sv.log (l_module_name, 'Action type', p_action_type);
	 wsh_debug_sv.log (l_module_name, 'Transaction status', p_transaction_status);
	 wsh_debug_sv.log (l_module_name, 'ECX Message ID', p_ecx_message_id);
	 wsh_debug_sv.log (l_module_name, 'Event Name', p_event_name);
	 wsh_debug_sv.log (l_module_name, 'Event Key', p_event_key);
	 wsh_debug_sv.log (l_module_name, 'Item Type', p_item_type);
	 wsh_debug_sv.log (l_module_name, 'In. control num', p_internal_control_number);
        --R12.1.1 STANDALONE PROJECT
	 wsh_debug_sv.log (l_module_name, 'Document Revision', p_document_revision);
        END IF;

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

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

        IF l_debug_on THEN
	  wsh_debug_sv.log (l_module_name, 'Return status from 	Create_Update_Txns_History', l_return_status);
        END IF;

	IF(l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
		raise create_update_failed;
	END IF;
	IF l_debug_on THEN
           wsh_debug_sv.pop(l_module_name);
        END IF;
EXCEPTION
WHEN create_update_failed THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        IF l_debug_on THEN
	  wsh_debug_sv.pop(l_module_name);
        END IF;
WHEN Others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        IF l_debug_on THEN
	  wsh_debug_sv.pop(l_module_name,'EXCEPTION: '||SUBSTR(SQLERRM,1,200));
        END IF;
END Create_Txns_History;

END WSH_TRANSACTIONS_HISTORY_PKG;

/
