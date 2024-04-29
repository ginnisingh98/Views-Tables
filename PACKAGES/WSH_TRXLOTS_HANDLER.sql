--------------------------------------------------------
--  DDL for Package WSH_TRXLOTS_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRXLOTS_HANDLER" AUTHID CURRENT_USER AS
/* $Header: WSHIIXLS.pls 120.0 2005/05/26 19:32:22 appldev noship $ */

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
      p_secondary_trx_quantity         IN NUMBER DEFAULT NULL,
      p_grade_code                     IN VARCHAR2 DEFAULT NULL
      );


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
      p_grade_code                     IN VARCHAR2 DEFAULT NULL);

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
        x_rowid				IN OUT NOCOPY  VARCHAR2 );

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
      p_grade_code                     IN VARCHAR2 DEFAULT NULL );

--HVOP heali
PROCEDURE INSERT_ROW_BULK (
     p_mtl_lot_txn_if_rec    IN              WSH_SHIP_CONFIRM_ACTIONS.mtl_lot_txn_if_rec_type,
     x_return_status         OUT NOCOPY      VARCHAR2);
--HVOP heali

END WSH_TRXLOTS_HANDLER;

 

/
