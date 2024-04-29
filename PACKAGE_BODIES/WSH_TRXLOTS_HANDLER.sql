--------------------------------------------------------
--  DDL for Package Body WSH_TRXLOTS_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_TRXLOTS_HANDLER" AS
/* $Header: WSHIIXLB.pls 120.0 2005/05/26 18:00:49 appldev noship $ */

--
-- PACKAGE VARIABLES
--

   g_userid                 NUMBER;

-- ===========================================================================
--
-- Name:
--
--   insert_row
--
-- Description:
--
--   Called by the client to insert a row into the
--   MTL_TRANSACTION_LOTS_INTERFACE table.
--
-- ===========================================================================

   --
   G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_TRXLOTS_HANDLER';
   --

--HVOP heali
PROCEDURE INSERT_ROW_BULK (
     p_mtl_lot_txn_if_rec    IN              WSH_SHIP_CONFIRM_ACTIONS.mtl_lot_txn_if_rec_type,
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
     WSH_DEBUG_SV.log(l_module_name,'p_mtl_lot_txn_if_rec.count',p_mtl_lot_txn_if_rec.source_line_id.count);
  END IF;

  x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  l_start_index := p_mtl_lot_txn_if_rec.source_line_id.first;
  l_end_index := p_mtl_lot_txn_if_rec.source_line_id.last;

  fnd_profile.get('USER_ID',g_userid);

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'g_userid',g_userid);
     WSH_DEBUG_SV.log(l_module_name,'l_start_index',l_start_index);
     WSH_DEBUG_SV.log(l_module_name,'l_end_index',l_end_index);
  END IF;


  FORALL i IN l_start_index..l_end_index
       INSERT INTO mtl_transaction_lots_interface (
         source_code,
         source_line_id,
         transaction_interface_id,
         lot_number,
         transaction_quantity,
         serial_transaction_temp_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
-- HW OPMCONV. Added secondary_qty and grade
         SECONDARY_TRANSACTION_QUANTITY,
         GRADE_CODE
      ) VALUES (
         p_mtl_lot_txn_if_rec.source_code(i),
         p_mtl_lot_txn_if_rec.source_line_id(i),
         p_mtl_lot_txn_if_rec.transaction_interface_id(i),
         p_mtl_lot_txn_if_rec.lot_number(i),
         p_mtl_lot_txn_if_rec.trx_quantity(i),
         p_mtl_lot_txn_if_rec.serial_transaction_temp_id(i),
         SYSDATE,
         g_userid,
         SYSDATE,
         g_userid,
-- HW OPMCONV. Added secondary_qty and grade
         p_mtl_lot_txn_if_rec.secondary_trx_quantity(i),
         p_mtl_lot_txn_if_rec.grade_code(i)
         );

    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'Rows inserted in mtl_transaction_lots_interface',SQL%ROWCOUNT);
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

   PROCEDURE Insert_Row(
      x_rowid				IN OUT NOCOPY  VARCHAR2,
      x_trx_interface_id		IN OUT NOCOPY  NUMBER,
      p_source_code        		IN VARCHAR2,
      p_source_line_id                 	IN NUMBER,
      p_lot_number			IN VARCHAR2,
      p_trx_quantity			IN NUMBER,
      p_last_update_date		IN DATE,
      p_last_updated_by			IN NUMBER,
      p_creation_date			IN DATE,
      p_created_by			IN NUMBER,
      p_serial_trx_id			IN NUMBER,
      p_error_code			IN VARCHAR2,
      p_last_update_login               IN NUMBER DEFAULT NULL,
      p_request_id                      IN NUMBER DEFAULT NULL,
      p_program_application_id          IN NUMBER DEFAULT NULL,
      p_program_id                      IN NUMBER DEFAULT NULL,
      p_program_update_date             IN DATE DEFAULT NULL,
      p_lot_expiration_date             IN DATE DEFAULT NULL,
      p_primary_quantity                IN NUMBER DEFAULT NULL,
      p_process_flag			IN VARCHAR2 DEFAULT 'Y',
-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_grade_code
      p_secondary_trx_quantity          IN NUMBER DEFAULT NULL,
      p_grade_code                      IN VARCHAR2 DEFAULT NULL)
   IS

      CURSOR row_id IS
         SELECT rowid FROM mtl_transaction_lots_interface
         WHERE transaction_interface_id = x_trx_interface_id
         AND lot_number = p_lot_number;

      CURSOR get_interface_id IS
         SELECT mtl_material_transactions_s.nextval
         FROM sys.dual;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
--
   BEGIN

/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.INSERT_ROW',
         'START',
         'Start of procedure INSERT_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', transaction_interface_id='||x_trx_interface_id||
            ', lot_number='||p_lot_number||
            ', transaction_quantity='||p_trx_quantity||
            ', last_update_date='||p_last_update_date||
            ', last_updated_by='||p_last_updated_by);
      wsh_server_debug.debug_message(
            ', creation_date='||p_creation_date||
            ', created_by='||p_created_by||
            ', serial_transaction_temp_id='||p_serial_trx_id||
            ', error_code='||p_error_code||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date||
            ', lot_expiration_date='||p_lot_expiration_date||
            ', primary_quantity='||p_primary_quantity||
            ', process_flag='||p_process_flag );
*/
      --
      -- Debug Statements
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
          WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_QUANTITY',P_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATION_DATE',P_CREATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_CREATED_BY',P_CREATED_BY);
          WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_TRX_ID',P_SERIAL_TRX_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
          WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_LOT_EXPIRATION_DATE',P_LOT_EXPIRATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
-- HW OPMCONV. Added debugging msgs
          WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_GRADE_CODE',P_GRADE_CODE);
      END IF;
      --
      fnd_profile.get('USER_ID',g_userid);

      -- Set interface id if necessary
      IF x_trx_interface_id IS NULL THEN
         OPEN get_interface_id;
         FETCH get_interface_id INTO x_trx_interface_id;
         CLOSE get_interface_id;
      END IF;

      INSERT INTO mtl_transaction_lots_interface(
         source_code,
         source_line_id,
         transaction_interface_id,
         lot_number,
         transaction_quantity,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         serial_transaction_temp_id,
         error_code,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         lot_expiration_date,
         primary_quantity,
         process_flag,
-- HW OPMCONV. Added secondary_qty and grade
         SECONDARY_TRANSACTION_QUANTITY,
         GRADE_CODE

      ) VALUES (
         p_source_code,
         p_source_line_id,
         x_trx_interface_id,
         p_lot_number,
         p_trx_quantity,
         NVL(p_last_update_date,SYSDATE),
         NVL(p_last_updated_by,g_userid),
         NVL(p_creation_date,SYSDATE),
         NVL(p_created_by,g_userid),
         p_serial_trx_id,
         p_error_code,
         p_last_update_login,
         p_request_id,
         p_program_application_id,
         p_program_id,
         p_program_update_date,
         p_lot_expiration_date,
         p_primary_quantity,
         p_process_flag,
-- HW OPMCONV. Added secondary_qty and grade
         p_secondary_trx_quantity,
         p_grade_code
      );

      OPEN row_id;

      FETCH row_id INTO x_rowid;

      IF (row_id%NOTFOUND) then
/*         wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.INSERT_ROW',
            'END',
            'No rowid found. Raising NO_DATA_FOUND.');
*/
         CLOSE row_id;
         RAISE  NO_DATA_FOUND;
      END IF;

      CLOSE row_id;

/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.INSERT_ROW',
         'END',
         'End of procedure INSERT_ROW');
*/
--
-- Debug Statements
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
--   MTL_TRANSACTION_LOTS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Update_Row (
      x_rowid				IN OUT NOCOPY  VARCHAR2,
      p_trx_interface_id		IN NUMBER,
      p_source_code                    	IN VARCHAR2,
      p_source_line_id 			IN NUMBER,
      p_lot_number			IN VARCHAR2,
      p_trx_quantity			IN NUMBER,
      p_last_update_date		IN DATE,
      p_last_updated_by			IN NUMBER,
      p_serial_trx_id			IN NUMBER,
      p_error_code			IN VARCHAR2,
      p_last_update_login               IN NUMBER DEFAULT NULL,
      p_request_id                      IN NUMBER DEFAULT NULL,
      p_program_application_id          IN NUMBER DEFAULT NULL,
      p_program_id                      IN NUMBER DEFAULT NULL,
      p_program_update_date             IN DATE DEFAULT NULL,
      p_lot_expiration_date             IN DATE DEFAULT NULL,
      p_primary_quantity                IN NUMBER DEFAULT NULL,
      p_process_flag			IN VARCHAR2 DEFAULT 'Y',
-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_grade_code
      p_secondary_trx_quantity          IN NUMBER DEFAULT NULL,
      p_grade_code                      IN VARCHAR2 DEFAULT NULL
      )
   IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
   --
   BEGIN
/*   wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.UPDATE_ROW',
      'START',
      'Start of procedure UPDATE_ROW, input parameters:
            source_code='||p_source_code||
            ', source_line_id='||p_source_line_id||
            ', transaction_interface_id='||p_trx_interface_id||
            ', lot_number='||p_lot_number||
            ', transaction_quantity='||p_trx_quantity||
            ', last_update_date='||p_last_update_date||
            ', last_updated_by='||p_last_updated_by);
   wsh_server_debug.debug_message(
            ', serial_transaction_temp_id='||p_serial_trx_id||
            ', error_code='||p_error_code||
            ', last_update_login='||p_last_update_login||
            ', request_id='||p_request_id||
            ', program_application_id='||p_program_application_id||
            ', program_id='||p_program_id||
            ', program_update_date='||p_program_update_date||
            ', lot_expiration_date='||p_lot_expiration_date||
            ', primary_quantity='||p_primary_quantity||
            ',  process_flag='||p_process_flag );
*/

   --
   -- Debug Statements
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
       WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
       WSH_DEBUG_SV.log(l_module_name,'P_TRX_QUANTITY',P_TRX_QUANTITY);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_DATE',P_LAST_UPDATE_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATED_BY',P_LAST_UPDATED_BY);
       WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_TRX_ID',P_SERIAL_TRX_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
       WSH_DEBUG_SV.log(l_module_name,'P_LAST_UPDATE_LOGIN',P_LAST_UPDATE_LOGIN);
       WSH_DEBUG_SV.log(l_module_name,'P_REQUEST_ID',P_REQUEST_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_APPLICATION_ID',P_PROGRAM_APPLICATION_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_ID',P_PROGRAM_ID);
       WSH_DEBUG_SV.log(l_module_name,'P_PROGRAM_UPDATE_DATE',P_PROGRAM_UPDATE_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_LOT_EXPIRATION_DATE',P_LOT_EXPIRATION_DATE);
       WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
       WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
-- HW OPMCONV. Added debugging msgs
       WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
       WSH_DEBUG_SV.log(l_module_name,'P_GRADE_CODE',P_GRADE_CODE);
   END IF;
   --
   fnd_profile.get('USER_ID',g_userid);

   UPDATE mtl_transaction_lots_interface SET
      source_code 			= p_source_code,
      source_line_id 			= p_source_line_id,
      transaction_interface_id		= p_trx_interface_id,
      lot_number			= p_lot_number,
      transaction_quantity		= p_trx_quantity,
      last_updated_by 			= NVL(p_last_updated_by,g_userid),
      last_update_date 			= NVL(p_last_update_date,SYSDATE),
      serial_transaction_temp_id	= p_serial_trx_id,
      error_code			= p_error_code,
      last_update_login                 = p_last_update_login,
      request_id                        = p_request_id,
      program_application_id            = p_program_application_id,
      program_id                        = p_program_id,
      program_update_date               = p_program_update_date,
      lot_expiration_date               = p_lot_expiration_date,
      primary_quantity                  = p_primary_quantity,
      process_flag			= p_process_flag,
-- HW OPMCONV. Added secondary_qty and grade
      SECONDARY_TRANSACTION_QUANTITY    = p_secondary_trx_quantity,
      GRADE_CODE                        = p_grade_code
   WHERE rowid = x_rowid;

   IF (SQL%NOTFOUND) THEN
/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.UPDATE_ROW',
         'END',
         'No rows updated. Raising NO_DATA_FOUND.');
*/
      RAISE NO_DATA_FOUND;
   END IF;

/*   wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.UPDATE_ROW',
      'END',
      'End of procedure UPDATE_ROW');
*/
--
-- Debug Statements
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
--   MTL_TRANSACTION_LOTS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Delete_Row (
        x_rowid				IN OUT NOCOPY  VARCHAR2 )
   IS
   --
l_debug_on BOOLEAN;
   --
   l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
   --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
         'START',
         'Start of procedure DELETE_ROW');

      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
         'START',
         'Deleting from mtl_serial_numbers_interface, if any');
*/

      --
      -- Debug Statements
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
      DELETE FROM mtl_serial_numbers_interface
      WHERE transaction_interface_id IN
        ( SELECT serial_transaction_temp_id
          FROM mtl_transaction_lots_interface
          WHERE rowid = x_rowid);

/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
         'END',
         'Finish with call to DELETE mtl_serial_numbers_interface');

      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
         'START',
         'Delete from mtl_transaction_lots_interface ');
*/
      DELETE FROM mtl_transaction_lots_interface WHERE rowid = x_rowid;

      IF (SQL%NOTFOUND) THEN
/*         wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
            'END',
            'No rows deleted.  Raising NO_DATA_FOUND');
*/
         RAISE NO_DATA_FOUND;
      END IF;

/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.DELETE_ROW',
         'END',
         'End of procedure DELETE_ROW');
*/
--
-- Debug Statements
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
--   MTL_TRANSACTION_LOTS_INTERFACE table.
--
-- ===========================================================================

   PROCEDURE Lock_Row (
      x_rowid				IN OUT NOCOPY  VARCHAR2,
      p_source_code                    	IN VARCHAR2,
      p_source_line_id              	IN NUMBER,
      p_trx_interface_id		IN NUMBER,
      p_lot_number			IN VARCHAR2,
      p_trx_quantity			IN NUMBER,
      p_lot_expiration_date            	IN DATE,
      p_primary_quantity               	IN NUMBER,
      p_serial_trx_id			IN NUMBER,
      p_error_code			IN VARCHAR2,
      p_process_flag			IN VARCHAR2,
-- HW OPMCONV. Added p_secondary_trx_quantity
-- and p_grade_code
      p_secondary_trx_quantity          IN NUMBER DEFAULT NULL,
      p_grade_code                      IN VARCHAR2 DEFAULT NULL )
   IS
      CURSOR lock_record IS
         SELECT * FROM mtl_transaction_lots_interface
         WHERE rowid = x_rowid
         FOR UPDATE NOWAIT;

      rec_info lock_record%ROWTYPE;

 --
l_debug_on BOOLEAN;
 --
 l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
 --
   BEGIN
/*      wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.LOCK_ROW',
         'START',
         'Start of procedure LOCK_ROW, input parameters:
            source_code='||p_source_code||', source_line_id='||p_source_line_id||
            ', transaction_interface_id='||p_trx_interface_id||
            ', lot_number='||p_lot_number||
            ', transaction_quantity='||p_trx_quantity||
            ', lot_expiration_date='||p_lot_expiration_date||
            ', primary_quantity='||p_primary_quantity||
            ', serial_transaction_temp_id='||p_serial_trx_id||
            ', error_code='||p_error_code||', process_flag='||p_process_flag );
*/

      --
      -- Debug Statements
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
          WSH_DEBUG_SV.log(l_module_name,'P_LOT_NUMBER',P_LOT_NUMBER);
          WSH_DEBUG_SV.log(l_module_name,'P_TRX_QUANTITY',P_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_LOT_EXPIRATION_DATE',P_LOT_EXPIRATION_DATE);
          WSH_DEBUG_SV.log(l_module_name,'P_PRIMARY_QUANTITY',P_PRIMARY_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_SERIAL_TRX_ID',P_SERIAL_TRX_ID);
          WSH_DEBUG_SV.log(l_module_name,'P_ERROR_CODE',P_ERROR_CODE);
          WSH_DEBUG_SV.log(l_module_name,'P_PROCESS_FLAG',P_PROCESS_FLAG);
-- HW OPMCONV. Added debugging msgs
          WSH_DEBUG_SV.log(l_module_name,'P_SECONDARY_TRX_QUANTITY',P_SECONDARY_TRX_QUANTITY);
          WSH_DEBUG_SV.log(l_module_name,'P_GRADE_CODE',P_GRADE_CODE);
      END IF;
      --
      OPEN lock_record;

      FETCH lock_record into rec_info;

      IF (lock_record%NOTFOUND) THEN
/*        wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.LOCK_ROW',
             'END',
             'Lock record failed.  Raising exception FORM_RECORD_DELETED');
*/
         CLOSE lock_record;

         fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
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
         AND (rec_info.lot_number = p_lot_number)
         AND (rec_info.transaction_quantity = p_trx_quantity)
         AND ((rec_info.lot_expiration_date = p_lot_expiration_date)
            OR ((rec_info.lot_expiration_date IS NULL)
               AND (p_lot_expiration_date IS NULL)))
         AND ((rec_info.primary_quantity = p_primary_quantity)
            OR ((rec_info.primary_quantity IS NULL)
               AND (p_primary_quantity IS NULL)))
         AND ((rec_info.serial_transaction_temp_id = p_serial_trx_id)
            OR ((rec_info.serial_transaction_temp_id IS NULL)
               AND (p_serial_trx_id IS NULL)))
         AND ((rec_info.error_code = p_error_code)
            OR ((rec_info.error_code IS NULL) AND (p_error_code IS NULL)))
         AND ((rec_info.process_flag = p_process_flag)
            OR ((rec_info.process_flag IS NULL) AND (p_process_flag IS NULL)))
-- HW OPMCONV. Added secondary_qty and grade
         AND ((rec_info.grade_code = p_grade_code)
            OR ((rec_info.grade_code IS NULL) AND (p_grade_code IS NULL)))
         AND ((rec_info.secondary_transaction_quantity = p_secondary_trx_quantity)
            OR ((rec_info.secondary_transaction_quantity IS NULL) AND (p_secondary_trx_quantity IS NULL)))

      ) THEN
/*         wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.LOCK_ROW',
            'END',
            'End of procedure LOCK_ROW');
*/
         --
         -- Debug Statements
         --
         IF l_debug_on THEN
             WSH_DEBUG_SV.pop(l_module_name);
         END IF;
         --
         return;
      ELSE
/*         wsh_server_debug.log_event('WSH_TRXLOTS_HANDLER.LOCK_ROW',
            'END',
            'Lock record failed.  Raising exception FORM_RECORD_CHANGED');
*/
         fnd_message.set_name('FND','FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
   END Lock_Row;

END WSH_TRXLOTS_HANDLER;

/