--------------------------------------------------------
--  DDL for Package WSH_TRXLOTS_HANDLER_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRXLOTS_HANDLER_TEST" AUTHID CURRENT_USER AS
/* $Header: WSHTESTS.pls 115.2 2003/12/01 18:47:31 heali noship $ */

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
      p_process_flag			IN VARCHAR2 DEFAULT 'Y');

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
      p_process_flag			IN VARCHAR2 DEFAULT 'Y');

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
      p_process_flag			IN VARCHAR2 );

END WSH_TRXLOTS_HANDLER_TEST;

 

/
