--------------------------------------------------------
--  DDL for Package WSH_TRXSN_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_TRXSN_HANDLER" AUTHID CURRENT_USER AS
/* $Header: WSHIISNS.pls 115.2 2003/07/08 01:54:41 heali ship $ */

   --
   -- PACKAGE EXCEPTIONS
   --

   WSH_FM_SERIALNO_NULL                        EXCEPTION;

   --
   -- PUBLIC FUNCTIONS/PROCEDURES
   --

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
      p_process_flag                     	IN NUMBER DEFAULT 1);

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
      p_process_flag                            IN NUMBER DEFAULT 1);

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
	x_rowid					IN OUT NOCOPY  VARCHAR2 );

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
      p_parent_serial_number               	IN VARCHAR2 );

--HVOP heali
PROCEDURE INSERT_ROW_BULK (
      p_mtl_ser_txn_if_rec    IN              WSH_SHIP_CONFIRM_ACTIONS.mtl_ser_txn_if_rec_type,
      x_return_status         OUT NOCOPY      VARCHAR2);
--HVOP heali

END WSH_TRXSN_HANDLER;

 

/
