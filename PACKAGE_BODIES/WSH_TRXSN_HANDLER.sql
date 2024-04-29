--------------------------------------------------------
--  DDL for Package Body WSH_TRXSN_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRXSN_HANDLER" AS
/* $Header: WSHIISNB.pls 115.6 2004/06/08 02:12:56 anxsharm ship $ */

--
-- PACKAGE VARIABLES
--

   g_userid		NUMBER;
   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRXSN_HANDLER';
   --

--HVOP heali
PROCEDURE INSERT_ROW_BULK (
                p_mtl_ser_txn_if_rec    IN              WSH_SHIP_CONFIRM_ACTIONS.mtl_ser_txn_if_rec_type,
                x_return_status         OUT NOCOPY      VARCHAR2) IS

l_debug_on BOOLEAN;
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW_BULK';

l_start_index		NUMBER ;
l_end_index		NUMBER ;

BEGIN
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;

  IF l_debug_on IS NULL THEN
     l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
     WSH_DEBUG_SV.push(l_module_name);
     WSH_DEBUG_SV.log(l_module_name,'p_mtl_ser_txn_if_rec.count',p_mtl_ser_txn_if_rec.source_line_id.count);
  END IF;

  x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_start_index := p_mtl_ser_txn_if_rec.source_line_id.first;
  l_end_index := p_mtl_ser_txn_if_rec.source_line_id.last;

  fnd_profile.get('USER_ID',g_userid);

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'g_userid',g_userid);
     WSH_DEBUG_SV.log(l_module_name,'l_start_index',l_start_index);
     WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
  END IF;


  FORALL i IN l_start_index..l_end_index
       INSERT INTO mtl_serial_numbers_interface (
         source_code,
         source_line_id,
         transaction_interface_id,
         fm_serial_number,
         to_serial_number,
         process_flag,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         attribute_category, -- Bug 3628620
         attribute1,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15
      ) VALUES (
         p_mtl_ser_txn_if_rec.source_code(i),
         p_mtl_ser_txn_if_rec.source_line_id(i),
         p_mtl_ser_txn_if_rec.transaction_interface_id(i),
         p_mtl_ser_txn_if_rec.fm_serial_number(i),
         p_mtl_ser_txn_if_rec.to_serial_number(i),
         1,
         SYSDATE,
         g_userid,
         SYSDATE,
         g_userid,
         p_mtl_ser_txn_if_rec.attribute_category(i), -- Bug 3628620
         p_mtl_ser_txn_if_rec.attribute1(i),
         p_mtl_ser_txn_if_rec.attribute2(i),
         p_mtl_ser_txn_if_rec.attribute3(i),
         p_mtl_ser_txn_if_rec.attribute4(i),
         p_mtl_ser_txn_if_rec.attribute5(i),
         p_mtl_ser_txn_if_rec.attribute6(i),
         p_mtl_ser_txn_if_rec.attribute7(i),
         p_mtl_ser_txn_if_rec.attribute8(i),
         p_mtl_ser_txn_if_rec.attribute9(i),
         p_mtl_ser_txn_if_rec.attribute10(i),
         p_mtl_ser_txn_if_rec.attribute11(i),
         p_mtl_ser_txn_if_rec.attribute12(i),
         p_mtl_ser_txn_if_rec.attribute13(i),
         p_mtl_ser_txn_if_rec.attribute14(i),
         p_mtl_ser_txn_if_rec.attribute15(i));

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows inserted in mtl_serial_numbers_interface',SQL%ROWCOUNT);
    END IF;


 IF l_debug_on THEN
   WSH_DEBUG_SV.pop(l_module_name);
 END IF;

EXCEPTION
 WHEN OTHERS THEN
    x_return_status:= WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;

    IF l_debug_on THEN
       WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
       WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END insert_row_bulk;
--HVOP heali

-- ===========================================================================
--
-- Name:
--
--   insert_row
--
-- Description:
--
--   Called by the client to insert a row into the
--   MTL_SERIAL_NUMBERS_INTERFACE table.
--
-- ===========================================================================
   PROCEDURE Insert_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      x_trx_interface_id			IN OUT NOCOPY  NUMBER,
      p_source_code                       	IN VARCHAR2,
      p_source_line_id                 		IN NUMBER,
      p_fm_serial_number                 	IN VARCHAR2,
      p_to_serial_number                 	IN VARCHAR2,
      p_creation_date                   	IN DATE,
      p_created_by                      	IN NUMBER,
      p_last_updated_by                		IN NUMBER,
      p_last_update_date                	IN DATE,
      p_last_update_login              		IN NUMBER DEFAULT NULL,
      p_request_id				IN NUMBER DEFAULT NULL,
      p_program_application_id                  IN NUMBER DEFAULT NULL,
      p_program_id                              IN NUMBER DEFAULT NULL,
      p_program_update_date                     IN DATE DEFAULT NULL,
      p_parent_serial_number                    IN VARCHAR2 DEFAULT NULL,
      p_vendor_serial_number                    IN VARCHAR2 DEFAULT NULL,
      p_vendor_lot_number                       IN VARCHAR2 DEFAULT NULL,
      p_error_code                       	IN VARCHAR2 DEFAULT NULL,
      p_process_flag                     	IN NUMBER DEFAULT 1)
   IS

      CURSOR row_id IS
         SELECT rowid FROM mtl_serial_numbers_interface
         WHERE transaction_interface_id = x_trx_interface_id
         AND NVL(fm_serial_number,'-1') =
            NVL(p_fm_serial_number, NVL(fm_serial_number,'-1'))
         AND NVL(to_serial_number,'-1') =
            NVL(p_to_serial_number, NVL(to_serial_number,'-1'));

      CURSOR get_interface_id IS
         SELECT mtl_material_transactions_s.nextval
         FROM sys.dual;

 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
 --
   BEGIN

/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.INSERT_ROW',
         'START',
         'Start of procedure INSERT_ROW, input parameters:
            source_code='||p_source_code||
            ',source_line_id='||to_char(p_source_line_id)||
            ', transaction_interface_id='||to_char(x_trx_interface_id)||
            ', fm_serial_number='||p_fm_serial_number||
            ', to_serial_number='||p_to_serial_number||
            ', creation_date='||p_creation_date||
            ', created_by='||to_char(p_created_by));
      wsh_server_debug.debug_message(
            ', last_updated_by='||to_char(p_last_updated_by)||
            ', last_update_date='||p_last_update_date||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date||
            ', parent_serial_number='||p_parent_serial_number||
            ', vendor_serial_number='||p_vendor_serial_number||
            ', vendor_lot_number='||p_vendor_lot_number||
            ', error_code='||p_error_code||
            ', process_flag='||to_char(p_process_flag) );
*/

      -- if from serial number is NULL, raise exception
      --
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'X_TRX_INTERFACE_ID',X_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_FM_SERIAL_NUMBER',P_FM_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_SERIAL_NUMBER',P_TO_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_SERIAL_NUMBER',P_PARENT_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_SERIAL_NUMBER',P_VENDOR_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
      END IF;
      --
      IF (p_fm_serial_number IS NULL) THEN
/*        wsh_server_debug.log_event('WSH_TRXSN_HANDLER.INSERT_ROW',
            'END',
            'Insert failed.  From serial number is NULL.
             Raising WSH_FM_SERIALNO_NULL');
*/
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'WSH_FM_SERIALNO_NULL');
         END IF;
         RAISE WSH_FM_SERIALNO_NULL;
      END IF;

      fnd_profile.get('USER_ID',g_userid);

      -- Set interface id if necessary
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'USER_ID',g_userid);
      END IF;
      IF x_trx_interface_id IS NULL THEN
         OPEN get_interface_id;
         FETCH get_interface_id INTO x_trx_interface_id;
         CLOSE get_interface_id;
      END IF;

      INSERT INTO mtl_serial_numbers_interface (
         source_code,
         source_line_id,
         transaction_interface_id,
         fm_serial_number,
         to_serial_number,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         parent_serial_number,
         vendor_serial_number,
         vendor_lot_number,
         error_code,
         process_flag
      ) VALUES (
         p_source_code,
         p_source_line_id,
         x_trx_interface_id,
         p_fm_serial_number,
         p_to_serial_number,
         NVL(p_creation_date,SYSDATE),
         NVL(p_created_by,g_userid),
         NVL(p_last_updated_by,g_userid),
         NVL(p_last_update_date,SYSDATE),
         p_last_update_login,
         p_request_id,
         p_program_application_id,
         p_program_id,
         p_program_update_date,
         p_parent_serial_number,
         p_vendor_serial_number,
         p_vendor_lot_number,
         p_error_code,
         p_process_flag
      );
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows inserted',SQL%ROWCOUNT);
      END IF;
      OPEN row_id;

      FETCH row_id INTO x_rowid;

      IF (row_id%NOTFOUND) then
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.INSERT_ROW',
            'END',
            'No rowid found. Raising NO_DATA_FOUND.');
*/
         CLOSE row_id;
         IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE  NO_DATA_FOUND;
      END IF;

      CLOSE row_id;

/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.INSERT_ROW',
         'END',
         'End of procedure INSERT_ROW');
*/

       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Insert_Row;

-- ===========================================================================
--
-- Name:
--
--   update_row
--
-- Description:
--
--   Called by the client to update a row in the
--   MTL_SERIAL_NUMBERS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Update_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      p_trx_interface_id			IN NUMBER,
      p_source_code                    		IN VARCHAR2,
      p_source_line_id                 		IN NUMBER,
      p_fm_serial_number                 	IN VARCHAR2,
      p_to_serial_number                 	IN VARCHAR2,
      p_last_updated_by      	          	IN NUMBER,
      p_last_update_date                	IN DATE,
      p_last_update_login                       IN NUMBER DEFAULT NULL,
      p_request_id				IN NUMBER DEFAULT NULL,
      p_program_application_id                  IN NUMBER DEFAULT NULL,
      p_program_id                              IN NUMBER DEFAULT NULL,
      p_program_update_date                     IN DATE DEFAULT NULL,
      p_parent_serial_number                    IN VARCHAR2 DEFAULT NULL,
      p_vendor_serial_number                    IN VARCHAR2 DEFAULT NULL,
      p_vendor_lot_number                       IN VARCHAR2 DEFAULT NULL,
      p_error_code                              IN VARCHAR2 DEFAULT NULL,
      p_process_flag                            IN NUMBER DEFAULT 1)
   IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
   --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.UPDATE_ROW',
         'START',
         'Start of procedure UPDATE_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', transaction_interface_id='||p_trx_interface_id||
            ', fm_serial_number='||p_fm_serial_number||
            ', to_serial_number='||p_to_serial_number);
      wsh_server_debug.debug_message(
            ', last_updated_by='||p_last_updated_by||
            ', last_update_date='||p_last_update_date||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date||
            ', parent_serial_number='||p_parent_serial_number||
            ', vendor_serial_number='||p_vendor_serial_number||
            ', vendor_lot_number='||p_vendor_lot_number||
            ', error_code='||p_error_code||', process_flag='||p_process_flag );
*/

      --
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_INTERFACE_ID',P_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_FM_SERIAL_NUMBER',P_FM_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_SERIAL_NUMBER',P_TO_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_SERIAL_NUMBER',P_PARENT_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_SERIAL_NUMBER',P_VENDOR_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
      END IF;
      --
      IF (p_fm_serial_number IS NULL) THEN
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.UPDATE_ROW',
            'END',
            'UPDATE failed.  From serial number is NULL.
             Raising WSH_FM_SERIALNO_NULL');
*/
         RAISE WSH_FM_SERIALNO_NULL;
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'WSH_FM_SERIALNO_NULL');
         END IF;

      END IF;

      fnd_profile.get('USER_ID',g_userid);

      UPDATE mtl_serial_numbers_interface SET
         source_code			= p_source_code,
         source_line_id            	= p_source_line_id,
         transaction_interface_id	= p_trx_interface_id,
         fm_serial_number		= p_fm_serial_number,
         to_serial_number		= p_to_serial_number,
         last_updated_by		= NVL(p_last_updated_by,g_userid),
         last_update_date		= NVL(p_last_update_date,SYSDATE),
         last_update_login		= p_last_update_login,
         request_id                     = p_request_id,
         program_application_id         = p_program_application_id,
         program_id		        = p_program_id,
         program_update_date            = p_program_update_date,
         parent_serial_number           = p_parent_serial_number,
         vendor_serial_number           = p_vendor_serial_number,
         vendor_lot_number	        = p_vendor_lot_number,
         error_code			= p_error_code,
         process_flag			= p_process_flag
      WHERE rowid = x_rowid;
      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows Updated',SQL%ROWCOUNT);
      END IF;

      IF (SQL%NOTFOUND) THEN
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.UPDATE_ROW',
            'END',
            'No rows updated. Raising NO_DATA_FOUND.');
*/
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE NO_DATA_FOUND;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.UPDATE_ROW',
         'END',
         'End of procedure UPDATE_ROW');
*/
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Update_Row;

-- ===========================================================================
--
-- Name:
--
--   delete_row
--
-- Description:
--
--   Called by the client to delete a row in the
--   MTL_SERIAL_NUMBERS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Delete_Row (
	x_rowid					IN OUT NOCOPY  VARCHAR2 )
   IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
   --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.DELETE_ROW',
         'START',
         'Start of procedure DELETE_ROW');
*/
      --
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
      END IF;
      --
      DELETE FROM mtl_serial_numbers_interface WHERE rowid = x_rowid;

      IF l_debug_on THEN
         WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
      END IF;
      IF (SQL%NOTFOUND) THEN
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.DELETE_ROW',
            'END',
            'No rows deleted.  Raising NO_DATA_FOUND');
*/
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
         END IF;
         RAISE NO_DATA_FOUND;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.DELETE_ROW',
         'END',
         'End of procedure DELETE_ROW');
*/
       --
       IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
       END IF;
       --
   END Delete_Row;

-- ===========================================================================
--
-- Name:
--
--   lock_row
--
-- Description:
--
--   Called by the client to lock a row in the
--   MTL_SERIAL_NUMBERS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Lock_Row (
      x_rowid					IN OUT NOCOPY  VARCHAR2,
      p_source_code 	                        IN VARCHAR2,
      p_source_line_id       	          	IN NUMBER,
      p_trx_interface_id			IN NUMBER,
      p_vendor_serial_number             	IN VARCHAR2,
      p_vendor_lot_number               	IN VARCHAR2,
      p_fm_serial_number                 	IN VARCHAR2,
      p_to_serial_number                 	IN VARCHAR2,
      p_error_code                       	IN VARCHAR2,
      p_process_flag                     	IN NUMBER,
      p_parent_serial_number               	IN VARCHAR2 )
   IS
      CURSOR lock_record IS
         SELECT * FROM mtl_serial_numbers_interface
         WHERE rowid = x_rowid
         FOR UPDATE NOWAIT;

      rec_info lock_record%ROWTYPE;

 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
 --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRXSN_HANDLER.LOCK_ROW',
         'START',
         'Start of procedure LOCK_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', transaction_interface_id='||p_trx_interface_id||
            ', vendor_serial_number='||p_vendor_serial_number||
            ', vendor_lot_number='||p_vendor_lot_number||
            ', fm_serial_number='||p_fm_serial_number||
            ', to_serial_number='||p_to_serial_number||
            ', error_code='||p_error_code||', process_flag='||p_process_flag||
            ', parent_serial_number='||p_parent_serial_number );
*/
      --
      --
      l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
      --
      IF l_debug_on IS NULL
      THEN
          l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
      END IF;
      --
      IF l_debug_on THEN
          WSH_DEBUG_SV.push(l_module_name);
          --
          WSH_DEBUG_SV.log(l_module_name,'X_ROWID',X_ROWID);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_CODE',P_SOURCE_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_SOURCE_LINE_ID',P_SOURCE_LINE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_INTERFACE_ID',P_TRX_INTERFACE_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_SERIAL_NUMBER',P_VENDOR_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_VENDOR_LOT_NUMBER',P_VENDOR_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_FM_SERIAL_NUMBER',P_FM_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TO_SERIAL_NUMBER',P_TO_SERIAL_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
          WSH_DEBUG_SV.log(l_module_name,'P_PARENT_SERIAL_NUMBER',P_PARENT_SERIAL_NUMBER);
      END IF;
      --
      OPEN lock_record;

      FETCH lock_record into rec_info;

      IF (lock_record%NOTFOUND) THEN
/*        wsh_server_debug.log_event('WSH_TRXSN_HANDLER.LOCK_ROW',
             'END',
             'Lock record failed.  Raising exception FORM_RECORD_DELETED');
*/
         CLOSE lock_record;

         fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_DELETED');
         END IF;
         app_exception.raise_exception;
      END IF;

      CLOSE lock_record;

      IF (
         ( (rec_info.source_code = p_source_code)
           OR ((rec_info.source_code IS NULL) AND (p_source_code IS NULL)))
         AND ((rec_info.source_line_id = p_source_line_id)
            OR ((rec_info.source_line_id IS NULL)
               AND (p_source_line_id IS NULL)))
         AND (rec_info.transaction_interface_id = p_trx_interface_id)
         AND ((rec_info.vendor_serial_number = p_vendor_serial_number)
            OR ((rec_info.vendor_serial_number IS NULL)
               AND (p_vendor_serial_number IS NULL)))
         AND ((rec_info.vendor_lot_number = p_vendor_lot_number)
            OR ((rec_info.vendor_lot_number IS NULL)
               AND (p_vendor_lot_number IS NULL)))
         AND ((rec_info.fm_serial_number = p_fm_serial_number)
            OR ((rec_info.fm_serial_number IS NULL)
               AND (p_fm_serial_number IS NULL)))
         AND ((rec_info.to_serial_number = p_to_serial_number)
            OR ((rec_info.to_serial_number IS NULL)
               AND (p_to_serial_number IS NULL)))
         AND ((rec_info.error_code = p_error_code)
            OR ((rec_info.error_code IS NULL) AND (p_error_code IS NULL)))
         AND ((rec_info.process_flag = p_process_flag)
            OR ((rec_info.process_flag IS NULL) AND (p_process_flag IS NULL)))
         AND ((rec_info.parent_serial_number = p_parent_serial_number)
            OR ((rec_info.parent_serial_number IS NULL)
               AND (p_parent_serial_number IS NULL)))
      ) THEN
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.LOCK_ROW',
            'END',
            'End of procedure LOCK_ROW');
*/
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
      ELSE
/*         wsh_server_debug.log_event('WSH_TRXSN_HANDLER.LOCK_ROW',
            'END',
            'Lock record failed.  Raising exception FORM_RECORD_CHANGED');
*/
         fnd_message.set_name('FND','FORM_RECORD_CHANGED');
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_CHANGED');
         END IF;
         app_exception.raise_exception;
      END IF;

      IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name);
      END IF;
      --
   END Lock_Row;

END WSH_TRXSN_HANDLER;

/
